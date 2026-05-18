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