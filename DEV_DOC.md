# DEV_DOC.md — Developer Documentation

> **Who is this document for?**
> This guide is written for **developers** who want to set up, build, run, and understand the Inception infrastructure from a technical perspective.
> It covers environment setup, configuration files, secrets, the Makefile, Docker Compose, and data persistence.

---
## Environment Setup from Scratch

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
- A **Dockerfile** — builds the image from Alpine Linux
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

### Cloning and Configuring the Project

1. Clone the repository:
```bash
git clone <repository-url>
cd inception
```

2. Configure your environment:

**a. Update domain name in `/etc/hosts`**:
```bash
sudo vim /etc/mez-zahi/hosts
```
```
Add this /home/data
127.0.0.1 <your_login>.42.fr
```

**b. Update paths in Makefile**:
```bash
vim Makefile
```
Change `/home/mez-zahi/data` to match your username:
```makefile
/home/YOUR_USERNAME/data
```

**c. Update paths in docker-compose.yml**:
```bash
vim srcs/docker-compose.yml
```
Replace all instances of `/home/mez-zahi/data` with `/home/YOUR_USERNAME/data`

**d. Update environment variables**:
```bash
nano srcs/.env
```
Update `DOMAIN_NAME` if needed (currently `mez-zahi.42.fr`)

---

### Setting Up Secrets

The project uses Docker secrets for sensitive data. Secrets are already configured in the `secrets/` directory with default passwords.

**Important**: Never commit actual secret files to Git. The `.gitignore` should exclude them.

---

## Building and Launching

