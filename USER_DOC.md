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

### Restart all services

```bash
make restart
```

Stops and then immediately restarts all containers. Useful after a configuration change.


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