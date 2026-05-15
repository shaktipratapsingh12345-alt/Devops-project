#!/bin/bash
set -e

REPO_DIR="/home/ec2-user/aws-three-tier-web-architecture-workshop"
WORKFLOW_DIR="$REPO_DIR/.github/workflows"
SCRIPTS_DIR="$REPO_DIR/scripts"
DEPLOY_SCRIPT="$SCRIPTS_DIR/deploy.sh"
WORKFLOW_FILE="$WORKFLOW_DIR/deploy.yml"

echo "==> Creating directories..."
mkdir -p "$WORKFLOW_DIR"
mkdir -p "$SCRIPTS_DIR"

echo "==> Creating deploy script..."
cat > "$DEPLOY_SCRIPT" << 'EOF'
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
EOF

echo "==> Making deploy script executable..."
chmod +x "$DEPLOY_SCRIPT"

echo "==> Creating GitHub Actions workflow..."
cat > "$WORKFLOW_FILE" << 'EOF'
name: Deploy to EC2

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup SSH key
        shell: bash
        run: |
          echo "${{ secrets.EC2_SSH_KEY }}" > key.pem
          chmod 600 key.pem

      - name: Run deploy script on EC2
        shell: bash
        run: |
          ssh -o StrictHostKeyChecking=no -i key.pem \
            ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} \
            "bash /home/ec2-user/aws-three-tier-web-architecture-workshop/scripts/deploy.sh"

      - name: Cleanup key
        if: always()
        run: rm -f key.pem
EOF

echo "==> Setup complete."
echo
echo "Next run these commands:"
echo "cd $REPO_DIR"
echo "git add scripts/deploy.sh .github/workflows/deploy.yml setup_cicd.sh"
echo 'git commit -m "Add automated EC2 deployment setup"'
echo "git push origin main"
