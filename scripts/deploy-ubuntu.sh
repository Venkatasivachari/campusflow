#!/usr/bin/env bash
# ==============================================================================
# Smart College Portal - Automated Ubuntu / EC2 Docker Deployment Script
# ==============================================================================
set -e

echo "=== 1. Checking Docker & Docker Compose on Ubuntu Host ==="
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker on Ubuntu..."
    sudo apt-get update -y
    sudo apt-get install -y docker.io docker-compose-v2 curl
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    echo "Docker installed successfully."
fi

echo "=== 2. Setting up Environment (.env) ==="
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "Created .env from .env.example."
    fi
fi

echo "=== 3. Building and Starting Containers with Docker Compose ==="
sudo docker compose down --remove-orphans || true
sudo docker compose up -d --build

echo "=== 4. Monitoring Container Health ==="
echo "Waiting for MySQL and Spring Boot backend to become healthy..."
sleep 15
sudo docker compose ps

echo "=================================================================="
echo " Smart College Portal is now LIVE on your Ubuntu / EC2 Host!"
echo " Web Portal:  http://$(curl -s http://checkip.amazonaws.com || echo 'localhost'):80"
echo " API Docs:    http://$(curl -s http://checkip.amazonaws.com || echo 'localhost'):80/api/v3/api-docs"
echo "=================================================================="
