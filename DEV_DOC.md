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

