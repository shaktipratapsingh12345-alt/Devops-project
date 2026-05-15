#!/bin/bash
set -euo pipefail

APP_DIR="/home/ec2-user/aws-three-tier-web-architecture-workshop"
WEB_ROOT="/usr/share/nginx/html"
BACKUP_DIR="/tmp/nginx-html-backup"
APP_NAME="index"

echo "Starting deployment..."

cd "$APP_DIR"
git pull origin main

echo "Installing and restarting backend..."
cd "$APP_DIR/application-code/app-tier"
npm install

if pm2 describe "$APP_NAME" >/dev/null 2>&1; then
  pm2 restart "$APP_NAME"
else
  pm2 start index.js --name "$APP_NAME"
fi

pm2 save

echo "Installing and building frontend..."
cd "$APP_DIR/application-code/web-tier"
npm install
npm run build

echo "Taking backup of current nginx files..."
sudo rm -rf "$BACKUP_DIR"
sudo mkdir -p "$BACKUP_DIR"
sudo cp -r "$WEB_ROOT"/* "$BACKUP_DIR"/ 2>/dev/null || true

echo "Deploying new frontend build..."
sudo rm -rf "${WEB_ROOT:?}"/*
sudo cp -r build/* "$WEB_ROOT"/

echo "Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo "Running health check..."
for i in 1 2 3 4 5; do
  HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null http://localhost)
  if [ "$HTTP_CODE" = "200" ]; then
    echo "Health check passed."
    exit 0
  fi
  echo "Attempt $i failed, retrying in 5 seconds..."
  sleep 5
done

echo "Health check failed. Rolling back..."
sudo rm -rf "${WEB_ROOT:?}"/*
sudo cp -r "$BACKUP_DIR"/* "$WEB_ROOT"/ 2>/dev/null || true
sudo systemctl reload nginx
exit 1
