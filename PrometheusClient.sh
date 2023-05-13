#!/bin/bash

# Installing sudo if it doesn't exist
if ! command -v sudo &> /dev/null; then
  apt-get update && apt-get install -y sudo
fi

# Downloading the latest node_exporter
curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -

# Extracting the tarball
tar -xvf node_exporter-*.linux-amd64.tar.gz

# Moving the node_exporter binary to /usr/local/bin/
sudo mv node_exporter-*.linux-amd64/node_exporter /usr/local/bin/

# Creating a system user for node_exporter
sudo useradd -rs /bin/false node_exporter

# Creating a systemd service for node_exporter
cat << EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reloading systemd daemons
sudo systemctl daemon-reload

# Enabling and starting the node_exporter service
sudo systemctl enable --now node_exporter

# Checking if ufw exists and then allowing port 9100
if command -v ufw &> /dev/null; then
  sudo ufw allow 9100
fi
