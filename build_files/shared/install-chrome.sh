#!/usr/bin/env bash
# install-chrome.sh - Install Google Chrome
# Creates repo file and installs chrome

set -euo pipefail

echo "=== Installing Google Chrome ==="

# Check if Chrome is already installed
if command -v google-chrome-stable &> /dev/null; then
    echo "Google Chrome is already installed, skipping..."
    exit 0
fi

# Remove any existing /opt/google directory that might conflict
if [ -d "/opt/google" ]; then
    echo "Removing existing /opt/google directory..."
    rm -rf /opt/google
fi

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
