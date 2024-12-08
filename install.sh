#!/bin/bash

if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
  echo "Docker or Docker Compose not found. Please install Docker and Docker Compose first."
  exit 1
fi

if [ ! -f .env ]; then
  echo ".env file not found! Copying from .env.example..."

  if [ -f .env.example ]; then
    read -p "Do you want to use the settings from .env.example? (y/n): " choice
    case "$choice" in
      y|Y )
        cp .env.example .env
        echo ".env file created from .env.example."
        ;;
      n|N )
        echo "You chose not to use .env.example. Please create your own .env file."
        exit 1
        ;;
      * )
        echo "Invalid option. Please respond with 'y' or 'n'."
        exit 1
        ;;
    esac
  else
    echo ".env.example not found! Please provide a valid .env.example file."
    exit 1
  fi
fi

echo "Using environment from .env file..."

NEXTCLOUD_PORT=$(grep -m 1 "NEXTCLOUD_PORT" .env | awk -F '=' '{print $2}')
NEXTCLOUD_PORT=${NEXTCLOUD_PORT:-8080}

echo "Creating necessary directories..."
mkdir -p ./nextcloud/config ./nextcloud/data ./redis/config ./db

if [ ! -f ./redis/config/redis.conf ]; then
  cat <<EOF > ./redis/config/redis.conf
# Enable AOF (Append Only File) for persistence, to prevent data loss on crashes.
appendonly yes
appendfsync everysec

# Set maximum memory to 2GB (adjust depending on your server's capacity)
maxmemory 2gb
maxmemory-policy allkeys-lru

# Reduce the frequency of snapshots for better performance
save ""

# Enable Redis to serve in a non-blocking way, to improve throughput
tcp-backlog 511
EOF
  echo "Custom redis.conf has been created with high-performance settings."
fi

echo "Starting Docker Compose..."
docker-compose up -d

echo "You can now access your Nextcloud instance at: http://localhost:${NEXTCLOUD_PORT}"
