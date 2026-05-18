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

### Using the Makefile

The Makefile provides convenient commands for managing the infrastructure:

**Build and start everything**:
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

**Other Makefile targets**:

```bash
make up         # Start existing containers (no rebuild)
make down       # Stop all containers
make logs       # Follow logs for all services
make status     # Show container status
make fclean     # Complete cleanup (WARNING: destroys data)
make re         # Rebuild everything from scratch
```

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

### Build Process Details

When you run `make `, the following happens:

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

## Managing Containers and Volumes

### Container Management

**List running containers**:
```bash
docker ps
```

**List all containers (including stopped)**:
```bash
docker ps -a
```

**View container details**:
```bash
docker inspect <container_name>
```

**Access container shell**:
```bash
docker exec -it <container_name> sh
```

**View container logs**:
```bash
docker logs <container_name>
docker logs -f <container_name>  # Follow logs
docker logs --tail 100 <container_name>  # Last 100 lines
```

**Restart a specific container**:
```bash
docker restart <container_name>
```

**Stop a specific container**:
```bash
docker stop <container_name>
```

**Remove a stopped container**:
```bash
docker rm <container_name>
```

**This project uses bind mounts, not Docker volumes**. Data locations:

- **MariaDB data**: `/home/YOUR_USERNAME/data/mariadb`
- **WordPress files**: `/home/YOUR_USERNAME/data/wordpress`

**Check data directory sizes**:
```bash
du -sh /home/YOUR_USERNAME/data/*
```

**Backup data directories**:
```bash
sudo tar -czf backup-$(date +%Y%m%d).tar.gz /home/YOUR_USERNAME/data/
```

### Network Management

**List networks**:
```bash
docker network ls
```

**Inspect the inception network**:
```bash
docker network inspect inception
```

**Check container connectivity**:
```bash
# From inside a container
docker exec -it wordpress sh
ping mariadb
ping redis
ping nginx
```
---

## Project Data Storage and Persistence

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