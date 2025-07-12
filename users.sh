#!/bin/bash
# Array od Username and passwords
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
  [roya]=Aa123456@
  [arman]=Aa123456@
  [farzad]=Aa123456@
  [mobina]=Aa123456@
)
for username in "${!users[@]}"; do
  sudo useradd -m -s /bin/bash "$username"
  echo "${username}:${users[$username]}" | sudo chpasswd
done
