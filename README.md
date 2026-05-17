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

Create the `secrets/` directory at the root of the repository and populate the following files:

```
secrets/
├── db_password.txt          # MariaDB user password
├── db_root_password.txt     # MariaDB root password
├── wp_admin_password.txt    # WordPress admin password
├── wp_user_password.txt     # WordPress regular user password
└── ftp_pass.txt             # FTP user password
```

Example:
```bash
mkdir -p secrets
echo "MySuperSecretDbPass!" > secrets/db_password.txt
```

**4. Configure your `.env` file:**

```bash
cp srcs/.env.example srcs/.env
# Then edit the values to match your setup
```

Key variables:

```env
DOMAIN_NAME=<your_login>.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=<your_login>
WP_ADMIN_USER=<your_login>
WP_USER=soufiane
DATA_PATH=/home/<your_login>/data
```

**5. Update data path in `Makefile`:**

```makefile
DATA_PATH = /home/<your_login>/data
```

### Build and Run

```bash
make        # Build all images and start services
```

All other available commands:

```bash
make up        # Start containers (without rebuilding)
make down      # Stop all running containers
make restart   # Restart the entire stack
make logs      # Tail container logs
make status    # Display current container status
make clean     # Stop containers and prune unused Docker resources
make fclean    # Full cleanup — removes ALL data and volumes
make re        # fclean + full rebuild from scratch
```

> ⚠️ `make fclean` is **destructive** — it deletes all persistent data.

### Access the Services

Once running, access the services at:

| Service          | URL                                         |
|------------------|---------------------------------------------|
| WordPress        | `https://<your_login>.42.fr`                |
| Adminer          | `https://adminer.<your_login>.42.fr`        |
| Static Site      | `https://static.<your_login>.42.fr`         |
| Portainer        | `https://localhost:9443`                    |
| FTP              | `ftp://localhost:21`                        |

> 🔐 Credentials are stored in the `secrets/` directory — never committed to git.

---