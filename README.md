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

</div>

---

## Description

Inception is a system administration project that focuses on Docker containerization and orchestration. The project involves setting up a complete web infrastructure using Docker Compose, with multiple services running in isolated containers. The infrastructure includes a WordPress website with a MariaDB database and an NGINX reverse proxy with TLS encryption.

The main goal is to understand Docker concepts, container networking, volume management, secrets handling, and service orchestration while following security best practices.

---

## Instructions

### Prerequisites

Before starting, make sure you have:

- A **Virtual Machine** running a Linux distribution (Alpine or Debian recommended)
- **Docker** and **Docker Compose** installed
- `sudo` or root access
- Minimum: **4 GB RAM** and **20 GB** free disk space
- `make` installed on the system