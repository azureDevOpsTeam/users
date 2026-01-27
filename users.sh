#!/bin/bash

set -e

# ====== Root check ======
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (sudo)"
  exit 1
fi

echo "🔐 Configuring SSH ports..."

SSHCONF="/etc/ssh/sshd_config"

# Backup sshd_config
cp "$SSHCONF" "${SSHCONF}.bak.$(date +%F_%T)"

# Remove existing Port lines
sed -i '/^[[:space:]]*Port[[:space:]]/d' "$SSHCONF"

# Add desired ports
cat <<EOF >> "$SSHCONF"

# Custom SSH ports
Port 22
Port 2267
EOF

# Restart SSH
sudo systemctl restart sshd

echo "✅ SSH configured to listen on ports 22 and 2267"

# ====== Disable password quality ======
echo "🔧 Disabling password quality restrictions..."

PWFILE="/etc/security/pwquality.conf"

cp "$PWFILE" "${PWFILE}.bak.$(date +%F_%T)"

set_or_replace () {
  local key="$1"
  local value="$2"

  if grep -Eq "^[#[:space:]]*${key}[[:space:]]*=" "$PWFILE"; then
    sed -i "s|^[#[:space:]]*${key}[[:space:]]*=.*|${key} = ${value}|g" "$PWFILE"
  else
    echo "${key} = ${value}" >> "$PWFILE"
  fi
}

set_or_replace minlen 1
set_or_replace dcredit 0
set_or_replace ucredit 0
set_or_replace lcredit 0
set_or_replace ocredit 0
set_or_replace minclass 0
set_or_replace dictcheck 0
set_or_replace usercheck 0
set_or_replace enforcing 0

sed -i 's|^[[:space:]]*dictpath[[:space:]]*=|# dictpath =|g' "$PWFILE"

echo "✅ Password restrictions disabled"

# ====== Create users ======
declare -A users
users=(
  [baran]=Aa123456@
  [laleh]=Aa123456@
  [jaleh]=Aa123456@
  [hamed]=Aa123456@
  [mansouri-pedar]=Aa123456@
  [mansouri-madar]=Aa123456@
  [mansouri-khaleh]=Aa123456@
  [meysam]=Aa123456@
  [sadaf]=Aa123456@
  [reza]=Aa123456@
  [zahra]=Aa123456@
  [fatemeh]=Aa123456@
  [arman]=Aa123456@
  [mobina]=Aa123456@
  [kaveh]=Aa123456@
  [sogand]=Aa123456@
)

echo "👤 Creating users..."

for username in "${!users[@]}"; do
  if id "$username" &>/dev/null; then
    echo "⚠️ User $username already exists – skipping"
  else
    useradd -m -s /bin/bash "$username"
    echo "${username}:${users[$username]}" | chpasswd
    echo "✅ User $username created"
  fi
done

echo "🎉 All tasks completed successfully"
