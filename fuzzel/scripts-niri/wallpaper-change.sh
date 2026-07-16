#!/usr/bin/env bash

wallpaper_dir="/home/hwd/pictures/wallpapers"

if [ ! -d "$wallpaper_dir" ]; then
  fuzzel -d --prompt-only "$wallpaper_dir doesn't exist"
  exit 0
fi

item=$(find "$wallpaper_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" \) | fuzzel --dmenu --prompt="Select wallpaper: ")

if [ -n "$item" ]; then
  awww img "$item"
fi
