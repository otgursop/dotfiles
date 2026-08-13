#!/bin/bash
action=$1
shift

for f in "$@"; do
  dir=$(dirname "$f")
  name=$(basename "$f")
  timestamp=$(date +%Y%m%d_%H%M%S)
  
  cd "$dir" || exit 1
  
  case $action in
    zip)   zip -r "${name%.zip}_${timestamp}.zip" "$name" ;;
    unzip) unzip "$name" ;;
    tar)   tar -cvf "${name%.tar}_${timestamp}.tar" "$name" ;;
    untar) tar -xvf "$name" ;;
    gzip)  gzip -c "$name" > "${name%.gz}_${timestamp}.gz" ;;
    gunzip) gunzip -c "$name" > "${name%.gz}" ;;
    7z)    7z a "${name%.7z}_${timestamp}.7z" "$name" ;;
    7x)    7z x "$name" ;;
  esac
done
