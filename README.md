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

---