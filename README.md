# 🚀 Nextcloud Docker Setup

This repository provides a streamlined setup for deploying Nextcloud in a Docker environment. It includes configuration for **Nextcloud**, **Redis**, and **MariaDB**, as well as automated configuration using the `docker-compose` setup.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Getting Started](#getting-started)
3. [Configuration](#configuration)
4. [Contributing](#contributing)
5. [License](#license)

## 🔧 Prerequisites

Before you start, ensure the following software is installed:

- **Docker**: A containerization platform to run applications in isolated environments.
- **Docker Compose**: A tool for defining and running multi-container Docker applications.

You can install Docker and Docker Compose by following the [official installation guides](https://docs.docker.com/get-docker/).

## 🛠️ Getting Started

To get your Nextcloud instance up and running, follow the steps below:

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/zckyachmd/nextcloud-docker-setup.git
cd nextcloud-docker-setup
```

### 2. Prepare the Environment
Make sure the `.env` file is present. If it's missing, a copy will be created from the `.env.example` file. If both files are missing, you will be prompted to create a valid `.env` file.

```bash
# Install required Docker containers
./install.sh
```

This script will:

- Check if Docker and Docker Compose are installed.
- Copy .env.example to .env if needed.
- Create necessary directories for Nextcloud, Redis, and MariaDB.
- Start the Docker containers via docker-compose up -d.

3. Access Nextcloud
Once the installation completes successfully, you can access your Nextcloud instance by navigating to:

```
http://localhost:<NEXTCLOUD_PORT>
```
where `<NEXTCLOUD_PORT>` is the port specified in your .env file (default: 8080).

## ⚙️ Configuration
The following configurations are automatically set after installation:

- Redis Configuration: A custom redis.conf file is created to optimize Redis for performance.
- MariaDB: MariaDB is pre-configured and ready to use.
- Nextcloud: Essential Nextcloud settings are configured.

For advanced configurations, edit the .env file to suit your needs.

## 🛠️ Customizing Redis
If you want to tweak the Redis configuration for better performance, the custom redis.conf file can be found under:

```bash
./redis/config/redis.conf
```

Edit this file to suit your environment and restart the Docker containers with:

```bash
docker-compose down
docker-compose up -d
```

## 🧑‍💻 Stack References

- [Nextcloud Documentation](https://docs.nextcloud.com) - Official documentation for Nextcloud.
- [Redis Documentation](https://redis.io/documentation) - Official documentation for Redis.
- [MariaDB Documentation](https://mariadb.org/documentation) - Official documentation for MariaDB.

## 📜 License
This project is licensed under the [MIT License](./LICENSE) - see the LICENSE file for details.

