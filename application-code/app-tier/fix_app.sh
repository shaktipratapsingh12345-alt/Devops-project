#!/bin/bash

set -e

cd /home/ec2-user/aws-three-tier-web-architecture-workshop/application-code/app-tier

echo "===== Step 1: Creating transactions table if not exists ====="

mysql -h devops-project-instance-1.cdiwyakg4daj.ap-south-1.rds.amazonaws.com -u admin -p <<'EOF'
USE webappdb;

CREATE TABLE IF NOT EXISTS transactions (
    id INT NOT NULL AUTO_INCREMENT,
    amount DECIMAL(10,2) NOT NULL,
    description VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

SHOW TABLES;
EOF

echo "===== Step 2: Restarting backend ====="
pm2 delete all || true
pm2 flush || true
pm2 start index.js --name index

echo "===== Step 3: Waiting for app to boot ====="
sleep 5

echo "===== Step 4: Testing API ====="
curl -i http://localhost:4000/transaction || true

echo
echo "===== Step 5: PM2 logs ====="
pm2 logs --lines 20
