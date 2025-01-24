#!/bin/bash
apt update
apt install postgresql nginx python-yaml docker.io vagrant virtualbox p7zip-full wget wkhtmltopdf -y

mkdir -p /etc/nginx/ssl
openssl genrsa -out /etc/nginx/ssl/self-signed.key 2048
openssl req -new -x509 -key /etc/nginx/ssl/self-signed.key -out /etc/nginx/ssl/self-signed.crt -days 365 \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=yourdomain.com"
chmod 600 /etc/nginx/ssl/self-signed.key
chmod 644 /etc/nginx/ssl/self-signed.crt

apt install nginx

echo 'user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
        # multi_accept on;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    # Redirect HTTP to HTTPS
    server {
        listen 80;

        # Redirect all HTTP traffic to HTTPS
        return 301 https://$host$request_uri;
    }

    # HTTPS Server with SSL Termination
    server {
        listen 443 ssl;

        # Self-signed SSL certificate and key
        ssl_certificate /etc/nginx/ssl/self-signed.crt;
        ssl_certificate_key /etc/nginx/ssl/self-signed.key;

        # Optional: Strong SSL security settings
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Proxy settings
        location / {
            proxy_pass http://127.0.0.1:8069;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto https;
        }
    }
}
' > /etc/nginx/nginx.conf

systemctl restart nginx

wget -q -O - https://nightly.odoo.com/odoo.key | gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/18.0/nightly/deb/ ./' | tee /etc/apt/sources.list.d/odoo.list
apt-get update && apt-get install odoo
