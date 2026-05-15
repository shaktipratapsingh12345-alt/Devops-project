#!/bin/bash
set -e

APP_DIR="/home/ec2-user/aws-three-tier-web-architecture-workshop"
WEB_ROOT="/usr/share/nginx/html"

echo "==> Starting deployment on EC2..."

cd "$APP_DIR"
git pull origin main

echo "==> Deploying backend..."
cd "$APP_DIR/application-code/app-tier"
npm install
if pm2 describe index >/dev/null 2>&1; then
  pm2 restart index
else
  pm2 start index.js --name index
fi
pm2 save

echo "==> Deploying frontend..."
cd "$APP_DIR/application-code/web-tier"
npm install
npm run build

echo "==> Updating Nginx web root..."
sudo rm -rf "$WEB_ROOT"/*
sudo cp -r build/* "$WEB_ROOT"/

echo "==> Testing and reloading Nginx..."
sudo nginx -t
sudo systemctl reload nginx

echo "==> Deployment completed successfully."
