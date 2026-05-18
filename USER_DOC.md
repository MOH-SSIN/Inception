# USER_DOC.md — User & Administrator Documentation

> **Who is this document for?**
> This guide is written for **end users and administrators** who want to use, access, or manage the Inception infrastructure. No Docker knowledge is required to follow this guide.

---

## Table of Contents

- [1. What Services Are Provided?](#1-what-services-are-provided)
- [2. Start and Stop the Project](#2-start-and-stop-the-project)
- [3. Access the Website](#3-access-the-website)
- [4. Access the Administration Panel](#4-access-the-administration-panel)
- [5. Locate and Manage Credentials](#5-locate-and-manage-credentials)
- [6. Check That Services Are Running Correctly](#6-check-that-services-are-running-correctly)
- [7. Common Problems and Solutions](#7-common-problems-and-solutions)

---

## 1. What Services Are Provided?

The Inception stack runs **3 services**, each isolated in its own container.
Together they form a complete and secure web infrastructure.

---

### NGINX — The Front Door

```
Internet ──► NGINX (port 443) ──► WordPress ──► MariaDB
```

**NGINX** is the only service directly accessible from the internet.
It acts as a **reverse proxy**: it receives every incoming request and decides where to send it.

- Listens exclusively on **port 443 (HTTPS)**
- All HTTP traffic is rejected — only encrypted connections are accepted
- Uses **TLSv1.2 / TLSv1.3** — modern and secure encryption protocols
- Forwards PHP requests to WordPress using the **FastCGI** protocol
- Serves static files (CSS, images, JS) directly without involving WordPress

> Think of NGINX as the **reception desk** of the infrastructure — every visitor goes through it first.

---

### WordPress — The Website

**WordPress** is the **Content Management System (CMS)** that powers the website.
It handles all the logic: pages, posts, users, themes, and plugins.

- Runs via **PHP-FPM** (a PHP processor) — it has no built-in web server of its own
- Listens on **port 9000** (internal only — not accessible from outside)
- Communicates with MariaDB to read and write all website content
- Fully installed and configured automatically on first startup via **WP-CLI**

> Think of WordPress as the **engine** of the website — it generates the pages that users see.

---

### MariaDB — The Database

**MariaDB** is the **relational database** that stores everything WordPress needs:
posts, pages, comments, users, settings, and plugin data.

- Listens on **port 3306** (internal only — not accessible from outside)
- Only WordPress is allowed to connect to it
- The database and its user are created automatically on first startup
- All data is stored on the host machine and persists across restarts

> Think of MariaDB as the **memory** of the website — all content lives here.

---

### Summary Table

| Service     | What it does                          | Accessible from outside? | Port  |
|-------------|---------------------------------------|--------------------------|-------|
| **NGINX**   | Reverse proxy, HTTPS entry point      | Yes — port `443`         | 443   |
| **WordPress**| PHP CMS, generates web pages         | No — internal only       | 9000  |
| **MariaDB** | Database, stores all website content  | No — internal only       | 3306  |

---

## 2. Start and Stop the Project

All commands must be run from the **root of the repository** (the `inception/` folder).

---

### Start the entire stack

```bash
make
```

This command builds the Docker images (if not already built) and starts all 3 containers.

**What happens during the first start:**

1. Docker builds the NGINX, WordPress, and MariaDB images from their Dockerfiles
2. The MariaDB container starts and initializes the database and user
3. The WordPress container waits for MariaDB, then installs WordPress automatically
4. The NGINX container starts and begins accepting HTTPS connections
5. The site becomes available at `https://<your_login>.42.fr`

The first startup takes **2 to 5 minutes**. Subsequent starts are much faster.

---

### Start without rebuilding

If the images are already built and you just want to start the containers:

```bash
make up
```

---

### Stop all services (without deleting data)

```bash
make down
```

This stops and removes the running containers.
**All data is preserved** — the WordPress files and the database are untouched.

---

### Restart all services

```bash
make restart
```

Stops and then immediately restarts all containers. Useful after a configuration change.

---

### Full cleanup (warning: deletes all data)

```bash
make fclean
```

> **This command is destructive.**
> It removes all containers, all Docker images, and **all data stored in the volumes**.
> The WordPress installation and the entire database will be permanently deleted.
> Only use this if you want to start completely from scratch.

---

### Rebuild everything from scratch

```bash
make re
```

Equivalent to running `make fclean` followed by `make`.
All images are rebuilt and the stack is started fresh with a clean database.

---

## 3. Access the Website

### Open the WordPress site

Once the stack is running, open your web browser and go to:

```
https://<your_login>.42.fr
```

Replace `<your_login>` with the actual 42 login used during setup.

---

### The browser shows a security warning — is that normal?

**Yes, this is completely expected.**

The TLS certificate used by NGINX is **self-signed** — it was generated locally and is not issued by a trusted Certificate Authority (like Let's Encrypt or DigiCert). Browsers display a warning for self-signed certificates.

**How to proceed:**

- **Chrome / Chromium**: Click **"Advanced"** → **"Proceed to \<your_login\>.42.fr (unsafe)"**
- **Firefox**: Click **"Advanced..."** → **"Accept the Risk and Continue"**
- **Safari**: Click **"Show Details"** → **"visit this website"** → **"Visit Website"**

After clicking through the warning once, the browser remembers your choice for that session.

---

### What you should see

After bypassing the certificate warning, you should see the **WordPress homepage** — a working website with at least one post and a default theme.

If the page does not load at all, refer to [Section 6](#6-check-that-services-are-running-correctly) to diagnose the issue.

---

## 4. Access the Administration Panel

The WordPress **admin dashboard** lets you manage all content, users, themes, plugins, and settings.

### Open the admin login page

```
https://<your_login>.42.fr/wp-admin
```

### Log in

Enter your credentials on the login form:

| Field      | Value                                              |
|------------|----------------------------------------------------|
| Username   | The value of `WP_ADMIN_USER` in `srcs/.env`        |
| Password   | The content of `secrets/wp_admin_password.txt`     |

---

### What you can do in the admin panel

Once logged in as administrator, you have full control over the site:

| Section          | What you can do                                              |
|------------------|--------------------------------------------------------------|
| **Posts**        | Create, edit, delete blog posts                              |
| **Pages**        | Create and manage static pages                               |
| **Media**        | Upload and organize images, videos, and documents            |
| **Comments**     | Moderate and reply to visitor comments                       |
| **Appearance**   | Change the website theme, customize menus and widgets        |
| **Plugins**      | Install and activate WordPress plugins                       |
| **Users**        | Create, edit, and delete user accounts and roles             |
| **Settings**     | Configure site title, URL, reading, writing, and more        |

---

### The second (non-admin) user

The stack also creates a **regular subscriber user** during installation.
This account has limited access — it can log in to WordPress but cannot modify site settings.

| Field    | Value                                              |
|----------|----------------------------------------------------|
| Username | The value of `WP_USER` in `srcs/.env`              |
| Password | The content of `secrets/wp_user_password.txt`      |

---

## 5. Locate and Manage Credentials

All credentials used by the stack are stored in the `secrets/` directory at the root of the repository.
Each file contains exactly one password in plain text.

---

### Location of all credentials

```
inception/
├── secrets/
│   ├── db_password.txt          ← Password for the MariaDB WordPress user
│   ├── db_root_password.txt     ← Password for the MariaDB root account
│   ├── wp_admin_password.txt    ← Password for the WordPress administrator
│   └── wp_user_password.txt    ← Password for the WordPress regular user
└── srcs/
    └── .env                     ← Usernames, database name, domain name (no passwords)
```

---

### Full credentials reference

| Service            | Username                                    | Password location                        |
|--------------------|---------------------------------------------|------------------------------------------|
| WordPress Admin    | `WP_ADMIN_USER` value in `srcs/.env`        | `secrets/wp_admin_password.txt`          |
| WordPress User     | `WP_USER` value in `srcs/.env`              | `secrets/wp_user_password.txt`           |
| MariaDB user       | `MYSQL_USER` value in `srcs/.env`           | `secrets/db_password.txt`                |
| MariaDB root       | `root`                                      | `secrets/db_root_password.txt`           |

---

### How to read a credential

```bash
cat secrets/wp_admin_password.txt
# Output: StrongWpAdminPass42!
```

---

### How to change a password

> **Changing a password requires rebuilding the affected service.**

**Step 1** — Update the secret file with the new password:

```bash
echo "MyNewStrongPassword!" > secrets/wp_admin_password.txt
```

**Step 2** — Rebuild and restart the stack so the new secret takes effect:

```bash
make re
```

> When you run `make re`, the database is reset and WordPress is reinstalled.
> All content (posts, pages, uploads) will be **permanently deleted**.
> Make sure to back up any important content before running this command.

---

### Important security rules

- **Never share** the contents of the `secrets/` directory
- **Never commit** the `secrets/` directory to Git — it must be listed in `.gitignore`
- **Never put passwords** directly in `srcs/.env` or in any Dockerfile
- Treat the `secrets/` folder with the same care as you would treat SSH private keys

---

## 6. Check That Services Are Running Correctly

### View the status of all containers

```bash
make status
```

All 3 containers should show the status **`Up`** (or `healthy` if health checks are configured).

Example of a healthy output:

```
NAME           IMAGE               STATUS          PORTS
nginx          inception-nginx     Up 3 minutes    0.0.0.0:443->443/tcp
wordpress      inception-wordpress Up 3 minutes
mariadb        inception-mariadb   Up 4 minutes
```

If a container shows `Exited`, `Restarting`, or is missing from the list, it has a problem.

---

### Stream live logs from all services

```bash
make logs
```

This shows the real-time output of all 3 containers combined.
Press `Ctrl + C` to stop streaming.

---

### View logs for a specific service only

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

Replace the service name with the one you want to inspect.

---

### Quick health checks per service

**Is NGINX responding?**

```bash
curl -k https://<your_login>.42.fr
# Expected: HTML content of the WordPress homepage
```

The `-k` flag tells curl to ignore the self-signed certificate warning.

**Is WordPress running?**

```bash
docker compose -f srcs/docker-compose.yml exec wordpress php -v
# Expected: PHP version information (e.g. PHP 8.x.x)
```

**Is MariaDB running and accessible?**

```bash
docker compose -f srcs/docker-compose.yml exec mariadb \
  mysqladmin -u root -p$(cat secrets/db_root_password.txt) status
# Expected: Uptime, threads, queries per second, etc.
```

---

### Check that the data directories exist and contain data

```bash
ls -lh /home/<your_login>/data/wordpress/
# Expected: WordPress core files (wp-admin/, wp-content/, wp-config.php, ...)

ls -lh /home/<your_login>/data/mariadb/
# Expected: MariaDB database files (wordpress/, ibdata1, ib_logfile0, ...)
```

If these directories are empty, the volumes were not mounted correctly or the initialization failed.
In that case, run `make re` to rebuild from scratch.

---

### Summary — Service health checklist

| Check                                  | Command                               | Expected result                     |
|----------------------------------------|---------------------------------------|-------------------------------------|
| All containers are up                  | `make status`                         | 3 containers with status `Up`       |
| NGINX responds to HTTPS                | `curl -k https://<login>.42.fr`       | WordPress HTML in the response      |
| WordPress PHP is running               | `docker exec wordpress php -v`        | PHP version printed                 |
| MariaDB is alive                       | `mysqladmin status` (see above)       | Server status output                |
| WordPress data exists on host          | `ls /home/<login>/data/wordpress/`    | WordPress files present             |
| MariaDB data exists on host            | `ls /home/<login>/data/mariadb/`      | Database files present              |

---

## 7. Common Problems and Solutions

### The site is not loading — "This site can't be reached"

**Possible causes:**

1. The stack is not running → run `make up` or `make`
2. The domain is not in `/etc/hosts` → add `127.0.0.1 <your_login>.42.fr` to `/etc/hosts`
3. NGINX crashed → check `make logs` for errors

```bash
# Verify the domain is in /etc/hosts
grep "<your_login>.42.fr" /etc/hosts

# If missing, add it:
echo "127.0.0.1 <your_login>.42.fr" | sudo tee -a /etc/hosts
```

---

### The browser shows "ERR_CONNECTION_REFUSED" on port 443

NGINX is not running or failed to start. Check its logs:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
```

Look for any error messages related to SSL certificates, config syntax, or port binding.

---

### WordPress shows "Error establishing a database connection"

WordPress cannot reach MariaDB. Possible causes:

- MariaDB has not finished initializing yet — wait 30 seconds and refresh
- The database credentials do not match between `.env` and `secrets/`
- The MariaDB container crashed — check `make status` and `make logs`

---

### A container keeps restarting

```bash
make status
# If STATUS shows "Restarting":

make logs
# Look for the error that causes the crash
```

If you cannot identify the problem, do a full rebuild:

```bash
make re
```

---

### I forgot the admin password

Read it directly from the secrets file:

```bash
cat secrets/wp_admin_password.txt
```

If the file was lost or overwritten with the wrong value, you can reset the password through a `make re` (full rebuild) with a new value in the file.

---

<div align="center">

For developer documentation (environment setup, Makefile internals, Docker Compose details), see **DEV_DOC.md**.

</div>