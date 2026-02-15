# MycoWriter Deployment Guide

This guide covers deploying MycoWriter to the existing VPS at 85.31.233.192 alongside auto-glossary and mrdbid.

## Prerequisites

- VPS: 85.31.233.192
- Domain: mycowriter.com (DNS pointed to VPS)
- SSH access as root: `ssh root@85.31.233.192`
- Deploy user already exists from previous deployments
- Ruby 3.4.3 via rbenv (already installed)
- MySQL 8.0+ (already installed)
- Nginx (already installed)

## Server Setup (One-Time)

### 1. Create MySQL Database and User

```bash
ssh root@85.31.233.192

# Login to MySQL
mysql -u root -p

# Create database and user
CREATE DATABASE mycowriter_production CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs;
CREATE USER 'mycowriter_user'@'localhost' IDENTIFIED BY 'SECURE_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON mycowriter_production.* TO 'mycowriter_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 2. Create Application Directory

```bash
# As root
mkdir -p /opt/mycowriter
chown deploy:deploy /opt/mycowriter

# Switch to deploy user
su - deploy

# Create shared directories
cd /opt/mycowriter
mkdir -p shared/config shared/log shared/tmp/pids shared/tmp/sockets shared/public/system shared/storage
```

### 3. Create .env File on Server

```bash
# As deploy user
cat > /opt/mycowriter/shared/.env << 'EOF'
MYSQL_DATABASE=mycowriter_production
MYSQL_USER=mycowriter_user
MYSQL_PASSWORD=SECURE_PASSWORD_HERE
DB_HOST=localhost
RAILS_ENV=production
EOF

chmod 600 /opt/mycowriter/shared/.env
```

### 4. Create master.key on Server

```bash
# Copy from local development
# On your local machine:
cat config/master.key

# On server as deploy user:
cat > /opt/mycowriter/shared/config/master.key << 'EOF'
PASTE_MASTER_KEY_HERE
EOF

chmod 600 /opt/mycowriter/shared/config/master.key
```

### 5. Setup Nginx Configuration

```bash
# As root
exit  # Back to root user

# Copy nginx config
cd /opt/mycowriter/current  # Will exist after first deploy
sudo cp config/nginx_site.conf /etc/nginx/sites-available/mycowriter
sudo ln -sf /etc/nginx/sites-available/mycowriter /etc/nginx/sites-enabled/mycowriter

# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### 6. Setup SSL Certificate (Let's Encrypt)

```bash
# As root
sudo certbot --nginx -d mycowriter.com -d www.mycowriter.com

# Auto-renewal is already configured from previous projects
```

## First Deployment

### 1. Deploy Application

```bash
# From your local machine
cd /Users/wrj/Documents/www/public_html/mycowriter

# Deploy to production
cap production deploy
```

### 2. Setup Database on Server

```bash
# SSH to server as deploy user
ssh deploy@85.31.233.192

cd /opt/mycowriter/current

# Run migrations
RAILS_ENV=production bundle exec rails db:migrate

# Import mb_lists data (if needed on production)
# Option 1: Import from dump file
scp /path/to/mb_lists_dump.sql deploy@85.31.233.192:/tmp/
mysql -u mycowriter_user -p mycowriter_production < /tmp/mb_lists_dump.sql

# Option 2: Copy from mrdbid database on server
mysqldump -u root -p mrdbid_production mb_lists | mysql -u mycowriter_user -p mycowriter_production
```

### 3. Install and Start Puma Service

```bash
# As root
sudo cp /opt/mycowriter/current/config/puma.service /etc/systemd/system/puma-mycowriter.service
sudo systemctl daemon-reload
sudo systemctl enable puma-mycowriter.service
sudo systemctl start puma-mycowriter.service

# Check status
sudo systemctl status puma-mycowriter.service

# View logs
sudo journalctl -xeu puma-mycowriter.service
```

### 4. Verify Deployment

```bash
# Check if Puma is running
ps aux | grep puma

# Check if socket exists
ls -la /opt/mycowriter/shared/tmp/sockets/puma.sock

# Test with curl
curl --unix-socket /opt/mycowriter/shared/tmp/sockets/puma.sock http://localhost/

# Test via nginx
curl http://mycowriter.com
curl https://mycowriter.com
```

## Subsequent Deployments

After the initial setup, deploying is simple:

```bash
# From your local machine
cd /Users/wrj/Documents/www/public_html/mycowriter
cap production deploy
```

Capistrano will automatically:
- Pull latest code from GitHub
- Install dependencies
- Run migrations
- Restart Puma via systemd

## Management Commands

### Capistrano Tasks

```bash
# Deploy
cap production deploy

# Check Puma status
cap production systemd_puma:status

# View Puma logs
cap production systemd_puma:logs

# Restart Puma
cap production systemd_puma:restart

# View stderr log
cap production systemd_puma:stderr

# View stdout log
cap production systemd_puma:stdout
```

### Direct Server Commands

```bash
# SSH to server
ssh deploy@85.31.233.192

# View Rails logs
tail -f /opt/mycowriter/shared/log/production.log

# Rails console
cd /opt/mycowriter/current
RAILS_ENV=production bundle exec rails console

# Database console
cd /opt/mycowriter/current
RAILS_ENV=production bundle exec rails dbconsole
```

### Systemd Commands (as root)

```bash
sudo systemctl start puma-mycowriter.service
sudo systemctl stop puma-mycowriter.service
sudo systemctl restart puma-mycowriter.service
sudo systemctl status puma-mycowriter.service
sudo journalctl -xeu puma-mycowriter.service
```

## Troubleshooting

### Puma Won't Start

```bash
# Check logs
sudo journalctl -xeu puma-mycowriter.service -n 100

# Check stderr
tail -50 /opt/mycowriter/shared/log/puma_stderr.log

# Check if socket already exists
ls -la /opt/mycowriter/shared/tmp/sockets/

# Manually remove stale files
sudo rm -f /opt/mycowriter/shared/tmp/sockets/puma.sock
sudo rm -f /opt/mycowriter/shared/tmp/pids/puma.pid
sudo systemctl restart puma-mycowriter.service
```

### 502 Bad Gateway

```bash
# Check if Puma is running
ps aux | grep puma

# Check nginx logs
tail -f /opt/mycowriter/shared/log/nginx_error.log

# Test socket connection
curl --unix-socket /opt/mycowriter/shared/tmp/sockets/puma.sock http://localhost/
```

### Database Connection Issues

```bash
# Check .env file
cat /opt/mycowriter/shared/.env

# Test database connection
cd /opt/mycowriter/current
RAILS_ENV=production bundle exec rails dbconsole
```

### Assets Not Loading

```bash
# Precompile assets manually
cd /opt/mycowriter/current
RAILS_ENV=production bundle exec rails assets:precompile

# Restart Puma
sudo systemctl restart puma-mycowriter.service
```

## Architecture

MycoWriter runs alongside mrdbid and auto-glossary on the same VPS:

```
VPS: 85.31.233.192
├── /opt/mrdbid (mrdbid.com)
│   ├── Puma: puma-mrdbid.service
│   └── MySQL: mrdbid_production
├── /opt/auto-glossary (auto-glossary.com)
│   ├── Puma: puma-auto-glossary.service
│   └── MySQL: auto_glossary_production
└── /opt/mycowriter (mycowriter.com)
    ├── Puma: puma-mycowriter.service
    └── MySQL: mycowriter_production

Nginx → Routes by domain to respective Unix sockets
```

## Security Notes

- All sensitive data is in `/opt/mycowriter/shared/.env` (not in git)
- `master.key` is in `/opt/mycowriter/shared/config/master.key` (not in git)
- All files owned by `deploy` user, not root
- Puma runs as `deploy` user, not root
- SSL certificates managed by Let's Encrypt/Certbot

## Backup Recommendations

```bash
# Database backup
mysqldump -u mycowriter_user -p mycowriter_production > mycowriter_backup_$(date +%Y%m%d).sql

# Config backup
tar -czf mycowriter_config_$(date +%Y%m%d).tar.gz /opt/mycowriter/shared/.env /opt/mycowriter/shared/config/master.key
```
