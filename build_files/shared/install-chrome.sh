#!/usr/bin/env bash
# install-chrome.sh - Install Google Chrome
# Creates repo file and installs chrome

set -euo pipefail

echo "=== Installing Google Chrome ==="

# Import Google's signing key
echo "Importing Google signing key..."
rpm --import https://dl.google.com/linux/linux_signing_key.pub

# Create Chrome repo file directly
echo "Creating Chrome repository..."
cat > /etc/yum.repos.d/google-chrome.repo << 'EOF'
[google-chrome]
name=Google Chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

# Install Chrome
echo "Installing Google Chrome..."
dnf5 -y install google-chrome-stable

echo "=== Google Chrome installed ==="
