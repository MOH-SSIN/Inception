# DEV_DOC.md — Developer Documentation

> **Who is this document for?**
> This guide is written for **developers** who want to set up, build, run, and understand the Inception infrastructure from a technical perspective.
> It covers environment setup, configuration files, secrets, the Makefile, Docker Compose, and data persistence.

---

## Table of Contents

- [1. Environment Setup from Scratch](#1-environment-setup-from-scratch)
  - [Project Overview](#project-overview)
  - [Directory Structure Explanation](#directory-structure-explanation)
  - [Prerequisites](#prerequisites)
  - [Cloning and Configuring the Project](#cloning-and-configuring-the-project)
  - [Setting Up Secrets](#setting-up-secrets)
- [2. Building and Launching](#2-building-and-launching)
  - [Using the Makefile](#using-the-makefile)
  - [Using Docker Compose Directly](#using-docker-compose-directly)
  - [Build Process Details](#build-process-details)
- [3. Managing Containers and Volumes](#3-managing-containers-and-volumes)
  - [Container Management](#container-management)
  - [Network Management](#network-management)
- [4. Project Data Storage and Persistence](#4-project-data-storage-and-persistence)
  - [Data Persistence Strategy](#data-persistence-strategy)
  - [Data Locations](#data-locations)
  - [How Data Persists](#how-data-persists)
  - [Data Recovery](#data-recovery)
- [5. Service-Specific Details](#5-service-specific-details)
  - [NGINX Service](#nginx-service)
  - [WordPress Service](#wordpress-service)
  - [MariaDB Service](#mariadb-service)
  - [Network Issues](#network-issues)
- [6. Startup Order and Container Dependencies](#6-startup-order-and-container-dependencies)
- [7. Docker Secrets — How They Work Internally](#7-docker-secrets--how-they-work-internally)
- [8. Common Development Issues and Solutions](#8-common-development-issues-and-solutions)
- [9. Useful One-Liners Cheat Sheet](#9-useful-one-liners-cheat-sheet)

---

## 1. Environment Setup from Scratch

### Project Overview

Inception is a **Docker-based web infrastructure** composed of 3 mandatory services:

### Directory Structure Explanation

```
inception/
├── Makefile
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        │       └── setup.sh
        └── mariadb/
            ├── Dockerfile
            └── tools/
                └── mariadb.sh
```

Each service has:
- A **Dockerfile** — builds the image from Debian Linux
- A **setup.sh** — the entrypoint script that initializes the service at runtime

---

### Prerequisites

The following must be installed and available on your Virtual Machine before starting:

| Tool              | Minimum version | Check command             |
|-------------------|-----------------|---------------------------|
| Docker Engine     | 20.x or higher  | `docker --version`        |
| Docker Compose    | v2.x or higher  | `docker compose version`  |
| make              | any             | `make --version`          |
| openssl           | any             | `openssl version`         |
| git               | any             | `git --version`           |

**Install on Debian / Ubuntu:**

```bash
sudo apt update
sudo apt install -y make git openssl curl vim

# Docker Engine
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
```

**Install on Alpine:**

```bash
sudo apk update
sudo apk add make git openssl curl docker docker-compose vim
sudo rc-update add docker default
sudo service docker start
```

**Verify Installation** (all distributions):

```bash
docker --version
docker compose version
```

---

### Cloning and Configuring the Project

1. Clone the repository:

```bash
git clone <repository-url>
cd inception
```

2. Configure your environment:

**a. Update domain name in `/etc/hosts`:**

```bash
sudo vim /etc/hosts
```

Add this line:

```
127.0.0.1 <your_login>.42.fr
```

**b. Update paths in Makefile:**

```bash
vim Makefile
```

Change `/home/mez-zahi/data` to match your username:

```makefile
/home/YOUR_USERNAME/data
```

**c. Update paths in docker-compose.yml:**

```bash
vim srcs/docker-compose.yml
```

Replace all instances of `/home/mez-zahi/data` with `/home/YOUR_USERNAME/data`

**d. Update environment variables:**

```bash
nano srcs/.env
```

Update `DOMAIN_NAME` if needed (currently `mez-zahi.42.fr`)

---

### Setting Up Secrets

The project uses Docker secrets for sensitive data. Secrets are already configured in the `secrets/` directory with default passwords.

**Important**: Never commit actual secret files to Git. The `.gitignore` should exclude them.

---

## 2. Building and Launching

### Using the Makefile

The Makefile provides convenient commands for managing the infrastructure:

**Build and start everything:**

```bash
make
# or
make all
```

This command:
1. Creates data directories (`/home/YOUR_USERNAME/data/`)
2. Sets proper ownership and permissions
3. Builds all Docker images
4. Starts all containers

**Other Makefile targets:**

```bash
make up         # Start existing containers (no rebuild)
make down       # Stop all containers
make logs       # Follow logs for all services
make status     # Show container status
make fclean     # Complete cleanup (WARNING: destroys data)
make re         # Rebuild everything from scratch
```

---

### Using Docker Compose Directly

You can also use Docker Compose commands directly:

```bash
# Navigate to srcs directory
cd srcs

# Build images
docker compose build

# Start services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# View running containers
docker compose ps
```

---

### Build Process Details

When you run `make`, the following happens:

1. **Directory Creation**: Creates persistent data directories
   ```bash
   mkdir -p /home/YOUR_USERNAME/data/mariadb
   mkdir -p /home/YOUR_USERNAME/data/wordpress
   ```

2. **Image Building**: Builds each service's Docker image
   - Reads each Dockerfile
   - Downloads Debian Linux base image
   - Installs required packages
   - Copies configuration files
   - Sets up entrypoints

3. **Container Creation**: Creates containers from images

4. **Network Setup**: Creates the `inception` bridge network

5. **Volume Mounting**: Mounts host directories into containers

6. **Service Startup**: Starts containers in dependency order

---

## 3. Managing Containers and Volumes

### Container Management

**List running containers:**

```bash
docker ps
```

**List all containers (including stopped):**

```bash
docker ps -a
```

**View container details:**

```bash
docker inspect <container_name>
```

**Access container shell:**

```bash
docker exec -it <container_name> sh
```

**View container logs:**

```bash
docker logs <container_name>
docker logs -f <container_name>        # Follow logs in real time
docker logs --tail 100 <container_name> # Last 100 lines only
```

**Restart a specific container:**

```bash
docker restart <container_name>
```

**Stop a specific container:**

```bash
docker stop <container_name>
```

**Remove a stopped container:**

```bash
docker rm <container_name>
```

**This project uses bind mounts, not Docker volumes.** Data locations:

- **MariaDB data**: `/home/YOUR_USERNAME/data/mariadb`
- **WordPress files**: `/home/YOUR_USERNAME/data/wordpress`

**Check data directory sizes:**

```bash
du -sh /home/YOUR_USERNAME/data/*
```

**Backup data directories:**

```bash
sudo tar -czf backup-$(date +%Y%m%d).tar.gz /home/YOUR_USERNAME/data/
```

---

### Network Management

**List networks:**

```bash
docker network ls
```

**Inspect the inception network:**

```bash
docker network inspect inception
```

**Check container connectivity:**

```bash
# From inside a container
docker exec -it wordpress sh
ping mariadb
ping nginx
```

---

## 4. Project Data Storage and Persistence

### Data Persistence Strategy

The project uses **bind mounts** to persist data on the host filesystem:

```yaml
volumes:
  mariadb-data:
    driver: local
    driver_opts:
        type: none
        o: bind
        device: /home/${USER}/data/mariadb
```

---

### Data Locations

**Host System → Container:**

1. **MariaDB Database:**
   - Host: `/home/YOUR_USERNAME/data/mariadb`
   - Container: `/var/lib/mysql`
   - Contains: Database files, transaction logs

2. **WordPress Files:**
   - Host: `/home/YOUR_USERNAME/data/wordpress`
   - Container: `/var/www/html`
   - Contains: WordPress core, themes, plugins, uploads

---

### How Data Persists

1. **Container Restart**: Data remains intact (bind mounts are not affected)
2. **Container Removal**: Data remains on host filesystem
3. **Complete Rebuild**: Data persists unless you run `make fclean`
4. **System Reboot**: Data persists (just restart containers with `make up`)

---

### Data Recovery

If containers are corrupted or removed:

```bash
# Stop containers
make down

# Remove containers and images
docker container prune -f
docker image prune -af

# Your data still exists
ls -la /home/YOUR_USERNAME/data/

# Rebuild and restart
make re
```

Your WordPress site and database will be restored automatically from the persistent data.

---

## 5. Service-Specific Details

### NGINX Service

**Purpose**: Reverse proxy and TLS termination

**Key Configuration:**
- Listens on port 443 (HTTPS only)
- TLSv1.2 / TLSv1.3 protocol
- Self-signed SSL certificates
- Proxies requests to backend services

**Configuration File**: `srcs/requirements/nginx/conf/nginx.conf`

**Virtual Hosts:**
1. `YOUR_LOGIN.42.fr` → WordPress (FastCGI to port 9000)

**SSL Certificate Generation** — handled automatically by `setup.sh`:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out    /etc/nginx/ssl/nginx.crt \
    -subj "/C=MA/ST=Khouribga/L=Khouribga/O=42/CN=YOUR_LOGIN.42.fr"
```

**Testing NGINX:**

```bash
docker exec -it nginx sh
nginx -t                        # Test configuration syntax
cat /etc/nginx/nginx.conf       # View the config
ls -la /etc/nginx/ssl/nginx.crt # Verify certificate exists
```

---

### WordPress Service

**Purpose**: Content Management System

**Key Components:**
- PHP 8.2 with PHP-FPM
- WP-CLI for automation

**Configuration File**: `srcs/requirements/wordpress/conf/www.conf`

**Setup Process (`setup.sh`):**
1. Download WordPress if not present
2. Install WP-CLI
3. Create `wp-config.php` with database credentials
4. Install WordPress core
5. Create admin and author users
6. Set file permissions

**Useful Commands:**

```bash
# Access WordPress container
docker exec -it wordpress sh

# Run WP-CLI commands
wp --info --allow-root
wp plugin list --allow-root
wp user list --allow-root
wp cache flush --allow-root

# Check PHP-FPM status
ps aux | grep php-fpm
netstat -tulpn | grep 9000
```

---

### MariaDB Service

**Purpose**: MySQL-compatible database

**Key Configuration:**
- Listens on port 3306
- UTF8MB4 character set
- Configured for Docker environment
- Health checks via mysqladmin

**Configuration File**: `srcs/requirements/mariadb/conf/server.conf`

**Setup Process (`setup.sh`):**
1. Initialize database if not present
2. Secure installation (remove test database, anonymous users)
3. Create WordPress database
4. Create database user with privileges
5. Set root password

**Database Backup:**

```bash
# Dump the database from the host
docker exec mariadb mysqldump \
  -u YOUR_LOGIN -p$(cat secrets/db_password.txt) wordpress > backup.sql

# Restore from a dump
docker exec -i mariadb mysql \
  -u YOUR_LOGIN -p$(cat secrets/db_password.txt) wordpress < backup.sql
```

**Access the database directly:**

```bash
docker exec -it mariadb sh
mysql -u YOUR_LOGIN -p$(cat /run/secrets/db_password) wordpress
```

---

### Network Issues

**Test connectivity between containers:**

```bash
docker exec wordpress ping mariadb
docker exec nginx ping wordpress
```

**Inspect network:**

```bash
docker network inspect inception
```

**Check DNS resolution:**

```bash
docker exec wordpress nslookup mariadb
docker exec wordpress cat /etc/resolv.conf
```

---

## 6. Startup Order and Container Dependencies

Docker Compose starts services in the correct order using `depends_on` and health checks.
Understanding this order helps diagnose startup failures.

```
docker compose up -d --build
        │
        ├──► Build all 3 images simultaneously (from Dockerfiles)
        │
        ├──► Start MariaDB
        │         └── healthcheck: mysqladmin ping every 10s
        │                   └── healthy ──► WordPress is allowed to start
        │                                       │
        │                                       └── setup.sh:
        │                                           1. Wait for MariaDB
        │                                           2. Download WordPress core
        │                                           3. Generate wp-config.php
        │                                           4. wp core install
        │                                           5. wp user create
        │                                           6. exec php-fpm (foreground)
        │                                                     │
        └─────────────────────────────────────────────────── └──► Start NGINX
                                                                       │
                                                                       └── nginx.conf loads
                                                                       └── Accepts HTTPS :443
```

**What happens if MariaDB is slow to start?**

The health check retries up to 5 times with a 10-second interval.
If MariaDB is still not healthy after all retries, Docker Compose stops and reports an error.
In that case, run:

```bash
make logs
# Look for MariaDB errors

make re
# Full rebuild if the issue persists
```

---

## 7. Docker Secrets — How They Work Internally

Understanding how secrets flow through the system helps debug credential issues.

```
Host filesystem           Docker runtime              Inside container
──────────────────        ───────────────             ────────────────────────
secrets/
├── db_password.txt  ───► Docker mounts as ─────────► /run/secrets/db_password
├── db_root_password.txt  read-only tmpfs              /run/secrets/db_root_password
├── wp_admin_password.txt (in memory only,             /run/secrets/wp_admin_password
└── wp_user_password.txt   never on disk               /run/secrets/wp_user_password
                           inside container)
```

Inside the entrypoint scripts, secrets are read like this:

```bash
# Read the password from the secret file — never from an environment variable
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
```

**Why secrets and not environment variables?**

| Method               | Visible in `docker inspect`? | Visible in process list? | Risk of log exposure? |
|----------------------|------------------------------|--------------------------|----------------------|
| Environment variable | ✅ Yes                       | ✅ Yes                   | ✅ Yes               |
| Docker secret        | ❌ No                        | ❌ No                    | ❌ No                |

**Verify a secret is correctly mounted inside a container:**

```bash
docker exec wordpress ls /run/secrets/
# Expected: db_password  wp_admin_password  wp_user_password

docker exec wordpress cat /run/secrets/db_password
# Expected: the password you wrote in secrets/db_password.txt
```

---

## 8. Common Development Issues and Solutions

### MariaDB exits immediately on first run

```bash
# Read the crash reason
docker compose -f srcs/docker-compose.yml logs mariadb

# Common fix: wrong permissions on data directory
sudo chown -R 999:999 /home/<your_login>/data/mariadb/

# If still failing — full reset
make fclean && make
```

---

### WordPress shows "Error establishing a database connection"

```bash
# Check if MariaDB passed its health check
docker compose -f srcs/docker-compose.yml ps mariadb

# Do the credentials match between .env and secrets/?
grep MYSQL_USER srcs/.env
cat secrets/db_password.txt

# Test the connection from inside the WordPress container
docker exec -it wordpress sh
mysqladmin ping -h mariadb \
  -u $(grep MYSQL_USER /run/secrets/../../../srcs/.env | cut -d= -f2) \
  -p$(cat /run/secrets/db_password)
```

---

### NGINX returns 502 Bad Gateway

PHP-FPM is not running or not listening on port 9000.

```bash
# Verify PHP-FPM processes are running
docker exec -it wordpress ps aux
# Expected: php-fpm master process + 2 worker processes

# Check NGINX error log for the exact upstream error
docker exec -it nginx cat /var/log/nginx/error.log
```

---

### A container keeps restarting

```bash
# See which container is cycling
docker compose -f srcs/docker-compose.yml ps

# Read its logs to find the crash cause
docker compose -f srcs/docker-compose.yml logs <service_name>

# Nuclear option — full rebuild
make re
```

---

### Build fails with "Unable to fetch packages"

The VM has no internet access or DNS is broken.

```bash
# Test internet from the VM
ping -c 2 8.8.8.8
curl -I https://deb.debian.org

# Fix DNS if needed
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Retry
make re
```

---

### wp-config.php is missing after startup

```bash
# Verify the bind mount is correctly configured
docker inspect wordpress | grep -A 10 Mounts

# Check the host directory
ls -lah /home/<your_login>/data/wordpress/

# If empty — DATA_PATH mismatch between .env and Makefile
grep DATA_PATH srcs/.env
grep DATA_PATH Makefile
```

---

## 9. Useful One-Liners Cheat Sheet

A quick reference for the most common operations during development.

### Stack Management

```bash
make                    # Build and start everything
make up                 # Start without rebuilding
make down               # Stop all containers (data safe)
make re                 # Full wipe and rebuild from scratch
make logs               # Stream all logs live
make status             # Quick overview of all containers
```

### Container Operations

```bash
docker exec -it nginx sh          # Shell into NGINX
docker exec -it wordpress sh      # Shell into WordPress
docker exec -it mariadb sh        # Shell into MariaDB
docker stats                      # Live CPU/RAM usage per container
docker inspect <name>             # Full container configuration
```

### Database

```bash
# Check database is alive
docker exec mariadb mysqladmin \
  -u root -p$(cat secrets/db_root_password.txt) status

# List all WordPress tables
docker exec mariadb mysql \
  -u root -p$(cat secrets/db_root_password.txt) \
  -e "USE wordpress; SHOW TABLES;"

# Full DB dump
docker exec mariadb mysqldump \
  -u root -p$(cat secrets/db_root_password.txt) \
  wordpress > dump-$(date +%Y%m%d).sql
```

### WordPress / WP-CLI

```bash
docker exec wordpress wp --info --allow-root          # WP-CLI version info
docker exec wordpress wp user list --allow-root       # List all WP users
docker exec wordpress wp plugin list --allow-root     # List all plugins
docker exec wordpress wp db check --allow-root        # Verify DB integrity
```

### NGINX

```bash
docker exec nginx nginx -t                            # Test config syntax
docker exec nginx cat /var/log/nginx/error.log        # View error log
curl -k https://<your_login>.42.fr                    # Test HTTPS response
openssl s_client -connect <your_login>.42.fr:443      # Inspect TLS certificate
```

### Data and Volumes

```bash
ls -lah /home/<your_login>/data/wordpress/            # WordPress files on host
ls -lah /home/<your_login>/data/mariadb/              # MariaDB files on host
du -sh /home/<your_login>/data/*                      # Disk usage per service
docker system df                                       # Total Docker disk usage
docker volume ls                                       # List all Docker volumes
docker network inspect inception                      # Inspect internal network
```

---

<div align="center">

For end-user documentation (accessing the site, managing credentials, health checks), see **USER_DOC.md**.

</div>