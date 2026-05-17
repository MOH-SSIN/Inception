*This project has been created as part of the 42 curriculum by mez-zahi.*

<div align="center">

```
██╗███╗   ██╗ ██████╗███████╗██████╗ ████████╗██╗ ██████╗ ███╗   ██╗
██║████╗  ██║██╔════╝██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
██║██╔██╗ ██║██║     █████╗  ██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║
██║██║╚██╗██║██║     ██╔══╝  ██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║
██║██║ ╚████║╚██████╗███████╗██║        ██║   ██║╚██████╔╝██║ ╚████║
╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
```

**A secure and minimal web infrastructure, orchestrated with Docker Compose.**

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![NGINX](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-0D597F?style=for-the-badge&logo=alpine-linux&logoColor=white)
![Debian Linux](https://img.shields.io/badge/Debian_Linux-0D597F?style=for-the-badge&logo=alpine-linux&logoColor=white)

</div>

---

## Table of Contents

- [Description](#description)
- [Architecture Overview](#architecture-overview)
- [Instructions](#instructions)
- [Resources](#resources)
- [Project Description](#project-description)

---

## Description

### Overview

Inception is a system administration project that focuses on Docker containerization and orchestration. The project involves setting up a complete web infrastructure using Docker Compose, with multiple services running in isolated containers. The infrastructure includes a WordPress website with a MariaDB database and an NGINX reverse proxy with TLS encryption.

The main goal is to understand Docker concepts, container networking, volume management, secrets handling, and service orchestration while following security best practices.

### Architecture Overview

The project follows a Microservices Architecture where each component is isolated within a private Docker Bridge Network. As shown in the schema, the infrastructure is designed so that only the web server is exposed to the external world, ensuring a high level of security.

```
                                                                        WWW (Internet)
                                                                            │
                                                                            │[Port 443]
                                                                            │
    ┌─────────────────────────────────────────────────────────────────────────────────────┐
    │ Computer HOST                                                         │             │
    │                                                                       │             │
    │   ┌─────────────────────────────────────────────────────────────────────────────┐   │
    │   │ Docker Network (inception)                                        │         │   │
    │   │                                                                   ▼         │   │
    │   │  ┌──────────┐      [3306]      ┌───────────┐      [9000]      ┌──────────┐  │   │
    │   │  │ Container│ <──────────────> │ Container │ <──────────────> │ Container│  │   │
    │   │  │    DB    │                  │  WP + PHP │                  │   NGINX  │  │   │
    │   │  └────┬─────┘                  └─────┬─────┘                  └──────────┘  │   │
    │   │       │                              │                                      │   │
    │   └───────┼──────────────────────────────┼──────────────────────────────────────┘   │
    │           │                              │                                          │
    │     ┌─────┴─────┐                  ┌─────┴─────┐                                    │
    │     │  Volume   │                  │  Volume   │                                    │
    │     │    DB     │                  │ WordPress │                                    │
    │     └───────────┘                  └───────────┘                                    │
    └─────────────────────────────────────────────────────────────────────────────────────┘

    Host machine:
        /home/<your_login>/data/wordpress/  ←──── WordPress volume (bind mount)
        /home/<your_login>/data/mariadb/    ←──── MariaDB volume  (bind mount)

```

**Request flow (step by step):**

1. A browser sends an HTTPS request to `https://<your_login>.42.fr`
2. NGINX receives the request on port `443`, terminates TLS, and checks the URL
3. If it is a PHP file, NGINX forwards the request to WordPress via **FastCGI** on port `9000`
4. WordPress processes the PHP and queries MariaDB on port `3306` to fetch content
5. MariaDB returns the requested data to WordPress
6. WordPress generates the final HTML response, which NGINX sends back to the browser

---

## Instructions

### Prerequisites

Before starting, make sure you have:

- A **Virtual Machine** running a Linux distribution (Alpine or Debian recommended)
- **Docker** and **Docker Compose** installed
- `sudo` or root access
- Minimum: **4 GB RAM** and **20 GB** free disk space
- `make` installed on the system

### Project Structure

```
.
├── Makefile                # The control center: contains commands to build and run the project.
└── srcs                    # The "brain" of the project containing all source files.
    ├── .env                    # Private file containing passwords and sensitive configurations.
    ├── docker-compose.yml      # The master plan that connects all containers together.
    └── requirements            # The specific folders for each service:
        ├── mariadb                 # Database service:
        │   ├── Dockerfile              # Instructions to build the MariaDB image.
        │   └── tools/mariadb.sh        # Script to initialize the database and users.
        ├── nginx                   # Web server service:
        │   ├── Dockerfile              # Instructions to build the NGINX image.
        │   └── conf/nginx.conf         # Rules for HTTPS and website handling.
        └── wordpress               # Website service:
            ├── Dockerfile              # Instructions to build the WordPress image.
            └── tools/setup.sh          # Script to download and install WordPress automatically.

```

### Installation

**1. Clone the repository:**

```bash
git clone 
cd inception
```

**2. Add your domain to /etc/hosts (for local HTTPS) :**

```
# /etc/hosts
127.0.0.1   your-domain.local
```

**3. Ensure the data directory path matches your system :**

   - Edit the `Makefile` and update `/home/login` to match your home directory
   - Edit `srcs/docker-compose.yml` and update all volume source paths

**4. Configure your `srcs/.env` file:**

Key variables:

```env
# Domain & Database Info
DOMAIN_NAME=your-login.42.fr
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=strong_password
MYSQL_ROOT_PASSWORD=root_password

# WordPress Admin
WP_ADMIN_USER=admin_user
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@example.com

# WordPress Normal User
WP_USER=normal_user
WP_USER_EMAIL=user@example.com
WP_USER_PASSWORD=user_password

```

### Build and Run

```bash
make        # Build all images and start services
```

All other available commands:

```bash
make all     # Default target → same as "make up"
make up      # Create folders + build and start containers
make down    # Stop and remove containers (docker compose down)
make fclean  # Stop containers + remove Docker unused data + delete /home/mez-zahi/data
make re      # Full reset (fclean + rebuild everything from scratch)
```

### Access the Services

Once running, access the services at:

| Service          | URL                                         |
|------------------|---------------------------------------------|
| WordPress        | `https://<your_login>.42.fr`                |

> 🔐 Credentials are stored in the `srcs/.env` file — never committed to git.

==> ici je dois faire les secrets

---

## Resources

### Docker & Containers

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Networking Guide](https://docs.docker.com/network/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)
- [Docker Secrets (Swarm)](https://docs.docker.com/engine/swarm/secrets/)
- [OCI Container Specs](https://specs.opencontainers.org/)

### Services

- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/documentation/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)

### Security

- [Mozilla TLS Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS)
- [Docker Security Overview](https://docs.docker.com/engine/security/)
- [Linux Namespaces (containers internals)](https://blog.quarkslab.com/)

### Learning

- [iximiuz Labs — Interactive Docker & K8s labs](https://labs.iximiuz.com/)
- [Alex Ellis' Blog — Docker & serverless](https://blog.alexellis.io/)
- [Play with Docker (browser-based)](https://labs.play-with-docker.com/)

### AI Usage

AI tools were used during this project to help with learning, debugging, and improving the infrastructure setup.

- **Configuration Help** — AI helped me understand and create some configuration files for NGINX, PHP-FPM, MariaDB, and WordPress.

- **Debugging Support** — AI assisted me when I had problems with Docker containers, networking, volumes, and service communication.

- **Learning & Research** — AI was used to quickly understand Docker, Docker Compose, Debian configuration, and best practices related to system administration.

- **Script Review** — AI helped review some shell scripts and Dockerfiles to detect possible mistakes and improve readability.

- **Documentation Assistance** — AI was used to help organize and improve the README documentation and project explanations.

All generated suggestions were reviewed, tested, and adapted manually to make sure they worked correctly and respected the project requirements.

---

## Project Description

### What is Docker and why use it here?

**Docker** is a platform that packages applications and all their dependencies into lightweight, isolated units called **containers**. A container bundles the OS libraries, runtime, configuration files, and application code together — ensuring the service behaves identically regardless of the host machine.

In this project, each service (NGINX, WordPress, MariaDB) runs in its **own container**, built from a custom `Dockerfile`. Docker Compose defines, links, and orchestrates all containers together using a single `docker-compose.yml` file.

This approach provides:

- **Isolation** — a problem in one container cannot directly affect another
- **Reproducibility** — the entire infrastructure can be rebuilt identically from scratch at any time
- **Portability** — the stack runs the same way on any Linux machine
- **Security** — each service exposes only what it needs, nothing more

---

### Virtual Machines vs Docker

Both VMs and Docker containers provide isolation, but they work at fundamentally different levels:

| Feature                | Virtual Machines (VMs)                                      | Docker Containers                                         |
|------------------------|-------------------------------------------------------------|-----------------------------------------------------------|
| **Kernel**             | Each VM runs its own full OS kernel via a hypervisor        | All containers share the host OS kernel                   |
| **Image size**         | Gigabytes (full OS + applications)                          | Megabytes (application + minimal dependencies only)       |
| **Startup time**       | Minutes — must boot a complete operating system             | Seconds — starts a process directly                       |
| **Isolation level**    | Hardware-level isolation via hypervisor (KVM, VirtualBox)   | Process-level isolation via Linux namespaces and cgroups  |
| **Performance**        | Overhead from hardware emulation and full OS                | Near-native — minimal overhead                            |
| **Resource usage**     | High — each VM needs its own dedicated RAM and CPU          | Low — containers share host resources efficiently         |
| **Portability**        | Heavy — OVA or VMDK disk images are large                   | Lightweight — images are layered and easily distributed   |
| **Use case**           | Running different OS types, full system simulation          | Microservices, application packaging, CI/CD pipelines     |

**Why Docker for this project**: We are running 3 interdependent services on a single machine. Docker keeps each service isolated without the overhead of 3 full VMs. Rebuilding is trivial (`make re`), and the resource footprint is minimal. The subject itself asks us to run Docker inside a VM — showing that the two technologies are complementary: the VM provides a controlled host environment, and Docker organizes services within it.

---

### Secrets vs Environment Variables

When a service needs a password (MariaDB, WordPress), there are two common ways to pass it into the container. The choice has important security implications.

**Environment variables** (via `.env` or `environment:` in Compose):

- Values are stored as plain text in the `.env` file and injected directly into the container's environment
- Visible via `docker inspect`, `docker exec env`, process listings (`/proc/<pid>/environ`), and compose files
- Risk of accidental exposure in logs or error messages
- Suitable only for **non-sensitive configuration**: domain names, database names, usernames

**Docker secrets** (via `secrets:` in Compose):

- The secret content lives in a plain file on the host (e.g. `secrets/db_password.txt`)
- Docker mounts it as a **read-only tmpfs file** at `/run/secrets/<name>` inside the authorized container
- The value is **never visible** in environment variables, `docker inspect` output, or container logs
- Only containers explicitly listed under `secrets:` in the Compose file can access it
- Designed specifically for **sensitive data**: passwords, tokens, private keys

| Feature                  | Environment Variables             | Docker Secrets                             |
|--------------------------|-----------------------------------|--------------------------------------------|
| **Storage location**     | `.env` file or compose config     | Host file → mounted at `/run/secrets/`     |
| **Visible in `inspect`** | Yes                               | No                                         |
| **Risk of log exposure** | Yes — can appear in error logs    | No — never part of env or process output   |
| **Access control**       | All processes in the container    | Only containers declared under `secrets:`  |
| **Best for**             | Domain names, ports, DB names     | Passwords, API tokens, private keys        |

**Design choice in this project**: Environment variables hold non-sensitive config (`DOMAIN_NAME`, `MYSQL_DATABASE`, `MYSQL_USER`, `WP_ADMIN_USER`, etc.). All passwords (`db_password`, `db_root_password`, `wp_admin_password`, `wp_user_password`) are passed exclusively as Docker secrets. Entrypoint scripts read them at runtime from `/run/secrets/`.

---

### Docker Network vs Host Network

Docker offers multiple networking modes. The two most relevant are **bridge (custom)** and **host**.

**Host network** (`network_mode: host`):

- The container bypasses Docker networking entirely and shares the host machine's network stack
- No network isolation — the container's ports are directly the host's ports
- Any port the service listens on is immediately exposed on the host
- Simplest to configure, but eliminates all network-level security boundaries
- **Explicitly forbidden by the Inception subject**

**Docker bridge network** (custom, named):

- Docker creates a virtual network interface completely isolated from the host and from other Docker networks
- Each container is assigned its own internal IP address within the network
- Containers on the same bridge network can **resolve each other by name** using Docker's built-in DNS
  - Example: the WordPress container can reach MariaDB using simply `mariadb:3306` as the hostname
- Traffic from outside the Docker network can only reach a container through an explicit `ports:` mapping
- In this project, only NGINX maps port `443` — WordPress and MariaDB have no external ports

| Feature                  | Docker Bridge Network (custom)             | Host Network                            |
|--------------------------|--------------------------------------------|-----------------------------------------|
| **Network isolation**    | Fully isolated from host and other networks| Shares host network stack completely    |
| **Inter-container DNS**  | Yes — containers find each other by name   | Not available at container level        |
| **External access**      | Only via explicitly declared `ports:`      | All ports directly accessible from host |
| **Security**             | Strong — minimal and controlled exposure   | Weak — no isolation from host           |
| **Subject compliance**   | Required                                   | Forbidden                               |

**Design choice**: A custom bridge network named `inception` is declared in `docker-compose.yml`. All 3 containers are attached to it and communicate by container name. NGINX is the only container with a port exposed externally (`443:443`). WordPress and MariaDB are fully unreachable from the internet.

---

### Docker Volumes vs Bind Mounts

Containers are **ephemeral** — when removed, all data written inside the container filesystem is permanently lost. To persist data (WordPress files, MariaDB database), Docker provides two mechanisms.

**Docker Volumes**:

- Created and entirely managed by Docker
- Stored internally by Docker at `/var/lib/docker/volumes/<name>/_data` on the host
- Referenced by a logical name in the Compose file (`volume_name:/path/in/container`)
- Docker handles creation, inspection, backup, and deletion via `docker volume` commands
- Preferred approach for most production deployments because of portability

**Bind Mounts**:

- A specific directory on the **host machine** is directly mounted into the container at a defined path
- Full control: you choose exactly where on the host the data lives
- Changes inside the container are immediately visible on the host (and vice versa)
- Easy to inspect, back up, and debug — files are at a known, accessible location
- Data survives Docker reinstallation because it lives at a regular host filesystem path
- Requires the path to exist on the host before the container starts

| Feature                  | Docker Volumes                                  | Bind Mounts                                      |
|--------------------------|-------------------------------------------------|--------------------------------------------------|
| **Managed by**           | Docker engine                                   | Host operating system directly                   |
| **Host path**            | Internal Docker path (opaque to user)           | Any absolute path defined by the operator        |
| **Portability**          | Platform-independent                            | Host-dependent — path must exist                 |
| **Inspection**           | Via `docker volume inspect` or internal path    | Direct filesystem access with standard tools     |
| **Survives reinstall**   | No — Docker manages and may remove them         | Yes — data is at a regular host path             |
| **Subject requirement**  | Not used for mandatory services                 | Required — data must live in `/home/<login>/data`|

**Design choice**: The subject explicitly requires that persistent data be stored under `/home/<your_login>/data/`. Bind mounts are therefore used for both WordPress and MariaDB:

```
/home/<your_login>/data/
├── wordpress/    ← Contains all WordPress files: wp-core, wp-content, uploads, themes, plugins
└── mariadb/      ← Contains all MariaDB files: .ibd table files, ib_logfile, binary logs
```

These directories are created by the `Makefile` before Docker Compose starts. All data persists across container restarts, rebuilds, and even full Docker reinstallation.

---

### Main Design Choices

Below is a summary of the key technical decisions made in this project and the reasoning behind each:

- **Debian as base image** — Debian is a stable and widely used Linux distribution. It provides strong package support, reliability, and compatibility for server environments. All containers in this project are built using Debian as their base image.

- **TLSv1.2 and TLSv1.3 only** — NGINX is configured to accept only modern TLS versions. Older protocols (TLSv1.0, TLSv1.1, SSLv3) are disabled because of well-known vulnerabilities (POODLE, BEAST). A self-signed certificate is generated at build time using `openssl`.

- **Non-root service users** — Each service runs as a dedicated, unprivileged system user inside its container (`nginx`, `mysql`, `www-data`). Running processes as root inside containers is a security anti-pattern — a compromised process should never have root-level privileges.

- **Health checks** — Each container declares a `healthcheck` in the Compose file. This ensures that WordPress does not attempt to start before MariaDB is fully initialized and ready to accept connections. NGINX waits for WordPress in turn. This prevents race conditions and startup failures.

- **No `latest` tag** — Using the `latest` tag makes builds non-deterministic because the image content may silently change between builds. All images are pinned to an explicit version (e.g. `alpine:3.19`) to guarantee reproducible builds.

- **All secrets in `/run/secrets/`** — No password appears anywhere in any Dockerfile, `docker-compose.yml`, or `.env` file. Entrypoint scripts read passwords at runtime from the mounted secret files, which are removed from memory after use.

- **Single external entry point** — Only the NGINX container has `ports: - "443:443"`. WordPress (`9000`) and MariaDB (`3306`) are never reachable from outside the Docker network. This enforces a clear perimeter.

- **`restart: always`** — All containers are configured to restart automatically whenever they stop or crash. This helps keep the infrastructure continuously available and ensures services start again after failures or system reboots.

- **WP-CLI for automated WordPress setup** — The WordPress container uses [WP-CLI](https://wp-cli.org/) in its entrypoint script to fully automate the WordPress installation (`wp core install`), create both the admin and the regular user, and configure the database connection — with no manual browser interaction required.

- **Security** — each service exposes only what it needs, nothing more

---

