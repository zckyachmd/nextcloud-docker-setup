#!/bin/bash

# Memeriksa apakah Docker dan Docker Compose terpasang
if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
  echo "Docker or Docker Compose not found. Please install Docker and Docker Compose first."
  exit 1
fi

# Memeriksa file .env dan menyalin jika perlu
if [ ! -f .env ]; then
  echo ".env file not found! Copying from .env.example..."
  cp .env.example .env || { echo ".env.example not found! Please provide a valid .env.example file."; exit 1; }
  echo ".env file created from .env.example."
fi

echo "Using environment from .env file..."

# Menentukan port Nextcloud dari .env atau default 8080
NEXTCLOUD_PORT=$(grep -m 1 "NEXTCLOUD_PORT" .env | awk -F '=' '{print $2}')
NEXTCLOUD_PORT=${NEXTCLOUD_PORT:-8080}

# Membaca NEXTCLOUD_DOMAIN dari .env
NEXTCLOUD_PROTOCOL=$(grep -m 1 "NEXTCLOUD_PROTOCOL" .env | awk -F '=' '{print $2}')
NEXTCLOUD_DOMAIN=$(grep -m 1 "NEXTCLOUD_DOMAIN" .env | awk -F '=' '{print $2}')

# Jika NEXTCLOUD_DOMAIN kosong, gunakan localhost sebagai fallback
NEXTCLOUD_DOMAIN=${NEXTCLOUD_DOMAIN:-localhost}

# Membuat direktori yang diperlukan
echo "Creating necessary directories..."
mkdir -p ./nextcloud/apps ./nextcloud/config ./nextcloud/data ./nextcloud/html ./nextcloud/themes ./redis/config ./db

# Membuat file konfigurasi Redis jika belum ada
if [ ! -f ./redis/config/redis.conf ]; then
  cat <<EOF > ./redis/config/redis.conf
appendonly yes
appendfsync everysec
maxmemory 2gb
maxmemory-policy allkeys-lru
save ""
tcp-backlog 511
EOF
  echo "Custom redis.conf has been created with high-performance settings."
fi

# Membuat file konfigurasi Apache untuk suppress 'ServerName' warning
echo "Configuring Apache with ServerName..."
cat <<EOF > ./nextcloud/apache-servername.conf
ServerName ${NEXTCLOUD_DOMAIN}
EOF

# Menjalankan Docker Compose
echo "Starting Docker Compose..."
docker-compose up -d

# Proses Waiting yang lebih proper
echo "Waiting for containers to start..."

# Menunggu hingga Nextcloud container siap
WAIT_TIME=0
MAX_WAIT_TIME=60 # Maksimal waktu tunggu dalam detik

while [ $WAIT_TIME -lt $MAX_WAIT_TIME ]; do
  # Memeriksa apakah container Nextcloud sudah berjalan
  if docker-compose ps | grep -q "nextcloud.*Up"; then
    echo "Nextcloud container is up and running."
    break
  fi
  # Jika belum, tunggu beberapa detik dan cek lagi
  echo "Waiting for Nextcloud container to start... ($WAIT_TIME/$MAX_WAIT_TIME)"
  sleep 5
  WAIT_TIME=$((WAIT_TIME + 5))
done

# Jika setelah MAX_WAIT_TIME masih belum siap, berhenti
if [ $WAIT_TIME -ge $MAX_WAIT_TIME ]; then
  echo "Nextcloud container did not start within the expected time. Please check the logs for errors."
  docker-compose logs nextcloud
  exit 1
fi

echo "Proceeding with Apache configuration..."

# Menyalin file konfigurasi Apache ke folder yang tepat dalam container
echo "Copying Apache configuration to the Nextcloud container..."
docker cp ./nextcloud/apache-servername.conf nextcloud:/etc/apache2/conf-available/servername.conf

# Mengaktifkan konfigurasi Apache dan merestart Apache
echo "Enabling Apache configuration and restarting Apache..."
docker-compose exec nextcloud bash -c "a2enconf servername.conf && apache2ctl restart"

# Menyelesaikan instalasi
echo "Nextcloud setup complete!"
echo "You can now access your Nextcloud instance at: ${NEXTCLOUD_PROTOCOL}://${NEXTCLOUD_DOMAIN}"
