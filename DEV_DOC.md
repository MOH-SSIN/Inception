# DEV_DOC.md — Developer Documentation

> **Who is this document for?**
> This guide is written for **developers** who want to set up, build, run, and understand the Inception infrastructure from a technical perspective.
> It covers environment setup, configuration files, secrets, the Makefile, Docker Compose, and data persistence.

---

## 1. Project Overview

Inception is a **Docker-based web infrastructure** composed of 3 mandatory services:

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
---

## 2. Prerequisites

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
sudo apt install -y make git openssl curl

# Docker Engine
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
```

**Install on Alpine:**

```bash
sudo apk update
sudo apk add make git openssl curl docker docker-compose
sudo rc-update add docker default
sudo service docker start
```

---

## 3. Environment Setup from Scratch

Follow these steps in order the very first time you set up the project.
