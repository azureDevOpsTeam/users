#!/bin/bash

set -e

# ====== Check root ======
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (sudo)"
  exit 1
fi

echo "🔧 Disabling password quality restrictions..."

PWFILE="/etc/security/pwquality.conf"

# Backup pwquality.conf
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

# Disable restrictions
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

echo "✅ Password restrictions disabled"

# ====== Users and passwords ======
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

echo "🎉 All done successfully"
