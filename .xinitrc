#!/bin/sh

export GSK_RENDERER=vulkan # opengl, cairo or vulkan
export GDK_BACKEND=x11

#export SDL_VIDEODRIVER=x11

export AMD_USERQ=1

export XDG_SESSION_TYPE=x11
export DESKTOP_SESSION=dwm
export XDG_CURRENT_DESKTOP=dwm
export XDG_SESSION_DESKTOP=dwm
export CLUTTER_BACKEND=x11
export QT_QPA_PLATFORM=xcb

export QT_QPA_PLATFORMTHEME=qt6ct
export QT_STYLE_OVERRIDE=kvantum

export ELECTRON_OZONE_PLATFORM_HINT=x11
export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=0

systemctl --user import-environment DISPLAY DBUS_SESSION_BUS_ADDRESS XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
dbus-update-activation-environment --systemd DISPLAY DBUS_SESSION_BUS_ADDRESS XDG_CURRENT_DESKTOP XDG_SESSION_TYPE

exec ~/.local/sl/dwm/scripts/startdwm.sh
