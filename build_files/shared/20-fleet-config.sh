#!/usr/bin/env bash
# fleet-config.sh - Configure fleet settings (locale, SSH, Tailscale)
# Applied to all avisblue images.
#
# User environment split:
#   - skel here: shell-only (.bashrc + .bashrc.d/) — applies to NEW accounts.
#   - Managed env vars + ssh-agent service: shipped via system_files/usr/
#     (tmpfiles.d/avisblue-user.conf force-symlinks managed env files into
#     ~/.config/environment.d/ on every login; ssh-agent.service is a
#     system-installed user unit globally enabled via
#     /etc/systemd/user/default.target.wants/). This path covers BOTH new
#     and rebased existing accounts (VISION §8b — Theme C priority-1).

set -euo pipefail

echo "=== Applying fleet configuration ==="

# Locale configuration
# en_US.UTF-8 with C collation for consistent sorting
echo "Configuring locale..."
cat > /etc/locale.conf << 'EOF'
LANG=en_US.UTF-8
LC_COLLATE=C
LC_NUMERIC=C
LC_TIME=C
LC_MONETARY=C
LC_MEASUREMENT=C
LC_PAPER=C
LC_NAME=C
LC_ADDRESS=C
LC_TELEPHONE=C
EOF

# Ensure Tailscale is enabled (installed in the Aurora-dx base)
echo "Enabling Tailscale..."
systemctl enable tailscaled.service || true

# Default bashrc additions for fleet
echo "Configuring default shell environment..."
cat >> /etc/skel/.bashrc << 'EOF'

# Avisblue fleet configuration
# Source additional bash configs
for f in ~/.bashrc.d/*.sh; do
    [[ -r "$f" ]] && source "$f"
done

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
EOF

# Create bashrc.d directory
mkdir -p /etc/skel/.bashrc.d

# Starship prompt hook (user installs starship via Homebrew)
cat > /etc/skel/.bashrc.d/90-starship.sh << 'EOF'
# Starship prompt (install with: brew install starship)
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi
EOF

# Direnv hook (user installs direnv via Homebrew)
cat > /etc/skel/.bashrc.d/10-direnv.sh << 'EOF'
# Direnv (install with: brew install direnv)
if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi
EOF

echo "=== Fleet configuration complete ==="
