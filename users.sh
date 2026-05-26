#!/bin/bash

set -e

# ====== Root check ======
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (sudo)"
  exit 1
fi

############################
# 1) SSH CONFIG
############################
echo "🔐 Configuring SSH ports..."

SSHCONF="/etc/ssh/sshd_config"
cp "$SSHCONF" "${SSHCONF}.bak.$(date +%F_%T)"

# Remove all existing Port directives
sed -i '/^[[:space:]]*Port[[:space:]]/d' "$SSHCONF"

# Append ports
cat <<EOF >> "$SSHCONF"

# Custom SSH ports
Port 22
Port 2267
EOF

############################
# 2) UFW CONFIG
############################
echo "🔥 Configuring UFW..."

if command -v ufw >/dev/null 2>&1; then
  ufw allow 22/tcp
  ufw allow 2267/tcp
  ufw reload
  echo "✅ UFW rules updated"
else
  echo "⚠️ UFW not installed – skipping firewall config"
fi

############################
# 3) RESTART SSH
############################
echo "🔄 Restarting SSH service..."
systemctl restart ssh || systemctl restart sshd

############################
# 4) DISABLE PASSWORD QUALITY
############################
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

# Disable dictionary path
sed -i 's|^[[:space:]]*dictpath[[:space:]]*=|# dictpath =|g' "$PWFILE"

############################
# 5) USERS
############################
echo "👤 Creating or updating users..."

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
  [sana]=Aa123456@
  [donya]=Aa123456@
)

for username in "${!users[@]}"; do
  if id "$username" &>/dev/null; then
    echo "🔁 User $username exists – updating password"
    echo "${username}:${users[$username]}" | chpasswd
  else
    echo "➕ Creating user $username"
    useradd -m -s /bin/bash "$username"
    echo "${username}:${users[$username]}" | chpasswd
  fi
done

echo "🎉 Setup completed successfully"
