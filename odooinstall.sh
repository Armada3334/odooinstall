#!/bin/bash
apt upgrade
sudo apt install postgresql -y
sudo apt install -y python-yaml docker.io vagrant virtualbox p7zip-full
apt install wkhtmltopdf 
wget -q -O - https://nightly.odoo.com/odoo.key | sudo gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/18.0/nightly/deb/ ./' | sudo tee /etc/apt/sources.list.d/odoo.list
sudo apt-get update && sudo apt-get install odoo
