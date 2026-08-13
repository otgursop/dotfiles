#!/bin/bash

options="TClient (mangohud): launch
TClient: launch
udisks2: unmask & start
udisks2: stop & mask
xdg-desktop-portal: restart"

choice=$(echo -e "$options" | fuzzel \
    --dmenu \
    --mesg "System actions" \
    --lines 5 \
    --width 30)

case "$choice" in
  "TClient (mangohud): launch") exec mangohud ~/programs/TClient-10.8.7-linux_x86_64/DDNet ;;

  "TClient: launch") exec ~/programs/TClient-10.8.7-linux_x86_64/DDNet ;;

  "xdg-desktop-portal: restart") systemctl --user restart xdg-desktop-portal ;;

  "udisks2: unmask & start")
    pkexec systemctl unmask udisks2 \
    && pkexec systemctl start udisks2 \
    && systemctl is-active --quiet udisks2 \
    && notify-send "udisks2 has been unmasked and started" \
    || notify-send "Failed to unmask or start udisks2"
    ;;

  "udisks2: stop & mask")
    pkexec systemctl stop udisks2 \
    && pkexec systemctl mask udisks2 \
    && ! systemctl is-active --quiet udisks2 \
    && notify-send "udisks2 has been stopped and masked" \
    || notify-send "Failed to stop or mask udisks2"
    ;;
esac

########################### Deprecated ###########################
# Zapret: start
# Zapret: stop

  # "Zapret: start")
  #   systemctl start zapret \
  #   && systemctl is-active --quiet zapret \
  #   && notify-send "Zapret has been started" \
  #   || notify-send "Failed to start Zapret"
  #   ;;
  #
  # "Zapret: stop")
  #   systemctl stop zapret && notify-send "Zapret has been stopped" || notify-send "Failed to stop Zapret"
  #   ;;
################################################################


