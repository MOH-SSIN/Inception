# USER_DOC.md — User & Administrator Documentation

> **Who is this document for?**
> This guide is written for **end users and administrators** who want to use, access, and manage the Inception web infrastructure.
> No deep Docker knowledge is required — every step is explained clearly.

---

## Table of Contents

- [Overview](#overview)

---

## Overview

The Inception stack runs **3 services**, each isolated in its own container.
Together they form a complete and secure web infrastructure.

```
                    ┌──────────────────────────────────────────────┐
                    │           Docker Network: inception          │
                    │                                              │
  Internet          │  ┌─────────────┐        ┌──────────────┐     │
  ───► NGINX:443 ───┼─►│  WordPress  │───────►│   MariaDB    │     │
       (HTTPS)      │  │  (PHP-FPM)  │  SQL   │  (Database)  │     │
                    │  │   :9000     │        │    :3306     │     │
                    │  └─────────────┘        └──────────────┘     │
                    │                                              │
                    └──────────────────────────────────────────────┘
```
---

#### NGINX — The Front Door

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

#### WordPress — The Website

**WordPress** is the **Content Management System (CMS)** that powers the website.
It handles all the logic: pages, posts, users, themes, and plugins.

- Runs via **PHP-FPM** (a PHP processor) — it has no built-in web server of its own
- Listens on **port 9000** (internal only — not accessible from outside)
- Communicates with MariaDB to read and write all website content
- Fully installed and configured automatically on first startup via **WP-CLI**

> Think of WordPress as the **engine** of the website — it generates the pages that users see.

---

#### MariaDB — The Database

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

## Getting Started

### Prerequisites

Before you start, make sure the following are in place on your machine or Virtual Machine:

- Docker and Docker Compose are installed and running
- The `make` command is available
- The project repository has been cloned
- Your login has been added to `/etc/hosts`:

```bash
grep "<your_login>.42.fr" /etc/hosts
# If the line is missing, add it:
echo "127.0.0.1 <your_login>.42.fr" | sudo tee -a /etc/hosts
```

- The `secrets/` directory exists at the root of the repository and contains the 4 password files:

```
secrets/
├── db_password.txt
├── db_root_password.txt
├── wp_admin_password.txt
└── wp_user_password.txt
```

If any of these files are missing, refer to the **DEV_DOC.md** to set up the environment from scratch.

### Starting the Project

All commands must be run from the **root of the repository** (the `inception/` folder).

Open a terminal and navigate to the root of the repository:

```bash
cd /path/to/inception
```
Start the full stack with a single command:
```bash
make
```
This command builds the Docker images (if not already built) and starts all 3 containers.

**What happens step by step:**

| Step | What Docker does                                                         |
|------|--------------------------------------------------------------------------|
| 1    | Creates the data directories on the host if they don't exist yet         |
| 2    | Builds the 3 Docker images (NGINX, WordPress, MariaDB) from Dockerfiles  |
| 3    | Starts MariaDB first — initializes the database, user, and permissions   |
| 4    | Starts WordPress — waits for MariaDB, then installs WordPress via WP-CLI |
| 5    | Starts NGINX — begins accepting HTTPS connections on port 443            |

> The **first build** takes 2 to 5 minutes depending on your machine and internet speed.
> All subsequent starts are much faster since images are already built.

Once all containers are up, verify everything is running:

```bash
make status
```

### Start without rebuilding

If the images are already built and you just want to start the containers:

```bash
make up
```

### Stop all services (without deleting data)

```bash
make down
```

This stops and removes the running containers.
**All data is preserved** — the WordPress files and the database are untouched.

### Full cleanup (warning: deletes all data)

```bash
make fclean
```

> **This command is destructive.**
> It removes all containers, all Docker images, and **all data stored in the volumes**.
> The WordPress installation and the entire database will be permanently deleted.
> Only use this if you want to start completely from scratch.

### Rebuild everything from scratch

```bash
make re
```

Equivalent to running `make fclean` followed by `make`.
All images are rebuilt and the stack is started fresh with a clean database.

---

## Accessing Services

### WordPress Website

Once the stack is running, open your browser and go to:

```
https://<your_login>.42.fr
```

**The browser shows a security warning — is that normal?**

Yes, this is completely expected.
The TLS certificate is **self-signed** (generated locally) and not issued by a trusted Certificate Authority.
Browsers always warn about self-signed certificates.

**How to bypass the warning:**

| Browser             | Steps                                                              |
|---------------------|--------------------------------------------------------------------|
| **Chrome**          | Click **"Advanced"** → **"Proceed to \<your_login\>.42.fr"**      |
| **Firefox**         | Click **"Advanced..."** → **"Accept the Risk and Continue"**       |
| **Safari**          | Click **"Show Details"** → **"visit this website"** → **"Visit"** |

After clicking through once, the browser remembers your choice for that session.

**What you should see:**

The WordPress homepage — a working website with at least one published post and a default theme.
If the page does not load at all, jump to the [Troubleshooting](#troubleshooting) section.

---

### WordPress Admin Panel

The admin dashboard allows you to manage all website content, users, themes, plugins, and settings.

**URL:**

```
https://<your_login>.42.fr/wp-admin
```

**Login credentials:**

| Field    | Value                                                      |
|----------|------------------------------------------------------------|
| Username | The value of `WP_ADMIN_USER` in `srcs/.env`                |
| Password | The content of `secrets/wp_admin_password.txt`             |

**Steps:**

1. Go to `https://<your_login>.42.fr/wp-admin`
2. Enter your username and password
3. Click **"Log In"**

---

**What you can do in the admin panel:**

| Section        | What you can do                                                    |
|----------------|--------------------------------------------------------------------|
| **Posts**      | Create, edit, publish, and delete blog posts                       |
| **Pages**      | Create and manage static pages (About, Contact, etc.)             |
| **Media**      | Upload and organize images, videos, and documents                  |
| **Comments**   | Moderate, approve, and reply to visitor comments                   |
| **Appearance** | Change the website theme, menus, and widgets                       |
| **Plugins**    | Install and activate WordPress plugins                             |
| **Users**      | Create, edit, and delete user accounts and assign roles            |
| **Settings**   | Configure the site title, URL, reading, writing, and more          |

---

**The second user account (non-admin):**

A second, regular WordPress user is also created automatically during setup.
This account can log in to WordPress but has limited access — it cannot change site settings.

| Field    | Value                                                  |
|----------|--------------------------------------------------------|
| Username | The value of `WP_USER` in `srcs/.env`                  |
| Password | The content of `secrets/wp_user_password.txt`          |

---

## Managing Credentials

### Location of All Credentials

All credentials used by the stack are stored in the `secrets/` directory at the **root of the repository**.
Each file contains exactly one password in plain text.

```
inception/
├── secrets/
│   ├── db_password.txt          ← Password for the MariaDB WordPress user
│   ├── db_root_password.txt     ← Password for the MariaDB root account
│   ├── wp_admin_password.txt    ← Password for the WordPress administrator
│   └── wp_user_password.txt     ← Password for the WordPress regular user
└── srcs/
    └── .env                     ← Usernames, database name, domain (no passwords here)
```

**Full reference table:**

| What                   | Username / identifier                     | Password file                      |
|------------------------|-------------------------------------------|------------------------------------|
| WordPress Admin        | `WP_ADMIN_USER` value in `srcs/.env`      | `secrets/wp_admin_password.txt`    |
| WordPress User         | `WP_USER` value in `srcs/.env`            | `secrets/wp_user_password.txt`     |
| MariaDB WordPress user | `MYSQL_USER` value in `srcs/.env`         | `secrets/db_password.txt`          |
| MariaDB root           | `root`                                    | `secrets/db_root_password.txt`     |

---

### How to Read a Credential

```bash
cat secrets/wp_admin_password.txt
# Output example: StrongWpAdminPass42!

cat secrets/db_password.txt
# Output example: StrongMariaDBUserPass42!
```

---

### How to Change a Password

> **Changing a password requires a full rebuild of the stack** because the passwords are baked into the database during the first initialization.

**Step 1 — Update the secret file:**

```bash
echo "MyBrandNewPassword!" > secrets/wp_admin_password.txt
```

**Step 2 — Rebuild and restart everything:**

```bash
make re
```

> ⚠️ `make re` will **delete all data** (WordPress files and the entire database) and reinstall from scratch.
> Back up any important content before doing this.

**Important security rules:**

- ❌ **Never share** the contents of the `secrets/` directory
- ❌ **Never commit** the `secrets/` directory to Git — it must be listed in `.gitignore`
- ❌ **Never put passwords** directly in `srcs/.env`, in any Dockerfile, or in `docker-compose.yml`
- ✅ Treat the `secrets/` folder with the same care as SSH private keys

---

## Checking Service Health

### Method 1 — Using Make

The fastest way to check if everything is running:

```bash
make status
```

**What to look for:**

| Status      | Meaning                                              |
|-------------|------------------------------------------------------|
| `Up`        | Container is running normally                        |
| `healthy`   | Container passed its health check                    |
| `Exited`    | Container stopped — there is a problem               |
| `Restarting`| Container keeps crashing and restarting              |

All 3 containers should show `Up` or `healthy`.

---

### Method 2 — Checking Logs

View live logs from all services combined:

```bash
make logs
```

Press `Ctrl + C` to stop streaming.

View logs for one specific service:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

**What to look for in the logs:**

| Service       | Signs of healthy startup                                          |
|---------------|-------------------------------------------------------------------|
| **MariaDB**   | `ready for connections` — the database is accepting queries       |
| **WordPress** | `WordPress installed successfully` — WP-CLI finished the install  |
| **NGINX**     | No errors — NGINX is accepting HTTPS connections on port 443      |

---

### Method 3 — Testing Services Manually

**Is NGINX responding on port 443?**

```bash
curl -k https://<your_login>.42.fr
# Expected: HTML content of the WordPress homepage printed in the terminal
```

The `-k` flag tells curl to ignore the self-signed certificate warning.

**Is WordPress's PHP engine running?**

```bash
docker compose -f srcs/docker-compose.yml exec wordpress php -v
# Expected: PHP version information, e.g. PHP 8.2.x (fpm-fcgi)
```

**Is MariaDB alive and accepting connections?**

```bash
docker compose -f srcs/docker-compose.yml exec mariadb \
  mysqladmin -u root -p$(cat secrets/db_root_password.txt) status
# Expected: Uptime: ..., Threads: ..., Questions: ..., etc.
```

---

## Common Tasks

### Back Up Your WordPress Files

```bash
sudo tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz \
  /home/<your_login>/data/wordpress
```

This creates a compressed archive of all WordPress files (themes, plugins, uploads, core).

---

### Back Up the Database

Run a database dump directly from the MariaDB container:

```bash
docker compose -f srcs/docker-compose.yml exec mariadb \
  mysqldump -u root -p$(cat secrets/db_root_password.txt) wordpress \
  > backup-db-$(date +%Y%m%d).sql
```

This creates a `.sql` file containing the full contents of the WordPress database.

---

### Restore WordPress Files from Backup

```bash
make down
sudo rm -rf /home/<your_login>/data/wordpress/*
sudo tar -xzf wordpress-backup-YYYYMMDD.tar.gz -C /
make up
```

---

### Restore the Database from Backup

```bash
docker compose -f srcs/docker-compose.yml exec -T mariadb \
  mysql -u root -p$(cat secrets/db_root_password.txt) wordpress \
  < backup-db-YYYYMMDD.sql
```

---

### Check Disk Usage

```bash
# Check how much space the data directories use
du -sh /home/<your_login>/data/wordpress/
du -sh /home/<your_login>/data/mariadb/

# Check Docker's overall disk usage
docker system df
```

---

## Troubleshooting

### SSL Certificate Warning — Is it dangerous?

No. The warning appears because the certificate is **self-signed** (not from a trusted authority like Let's Encrypt).
This is expected in a local 42 project environment.

- The connection is still **fully encrypted** with TLSv1.2 or TLSv1.3
- The only difference from a "trusted" certificate is that no authority has verified the domain name

To proceed: click **"Advanced"** → **"Proceed to site"** in your browser.

---

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

### I forgot the admin password

Read it directly from the secrets file:

```bash
cat secrets/wp_admin_password.txt
```

If the file was lost or overwritten with the wrong value, you can reset the password through a `make re` (full rebuild) with a new value in the file.

---
<div align="center">

📘 For developer documentation (environment setup, Makefile internals, Docker Compose structure), please refer to **DEV_DOC.md**.
</div>