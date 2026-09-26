#!/bin/bash

action="${1:-}"
shift 2>/dev/null || true

if [[ -z "$action" || $# -eq 0 ]]; then
    echo "Usage: $0 {zip|unzip|tar|untar|gzip|gunzip|7z|7x} <file1> [file2 ...]" >&2
    exit 1
fi

# Strips archive extensions to get the base name (mimics Windows/7-Zip behavior)
get_base_name() {
    local name="$1"
    name="${name%.tar.gz}"; name="${name%.tar.bz2}"; name="${name%.tar.xz}"; name="${name%.tar.zst}"
    name="${name%.zip}"; name="${name%.tar}"; name="${name%.gz}"; name="${name%.bz2}"
    name="${name%.xz}"; name="${name%.7z}"; name="${name%.rar}"; name="${name%.zst}"
    echo "$name"
}

timestamp=$(date +%Y%m%d_%H%M%S)
file_count=$#
first_file="$1"
dir=$(dirname "$first_file")

# ==========================================
# 1. PACKING (zip, tar, 7z)
# Supports selecting multiple files into a SINGLE archive
# ==========================================
if [[ "$action" == "zip" || "$action" == "tar" || "$action" == "7z" ]]; then
    if [[ $file_count -eq 1 ]]; then
        # Single file selected: use its name
        name=$(basename "$first_file")
        base_name=$(get_base_name "$name")
        target_name="${base_name}_${timestamp}"
        files_to_add=("$name")
    else
        # Multiple files selected: create a common "Archive"
        target_name="Archive_${timestamp}"
        files_to_add=()
        for f in "$@"; do
            files_to_add+=("$(basename "$f")")
        done
    fi

    case "$action" in
        zip)
            if ! (cd "$dir" && zip -r -q "${target_name}.zip" "${files_to_add[@]}" > /dev/null); then
                echo "Error: Failed to create zip archive." >&2; exit 1
            fi
            ;;
        tar)
            if ! (cd "$dir" && tar -cf "${target_name}.tar" "${files_to_add[@]}" > /dev/null); then
                echo "Error: Failed to create tar archive." >&2; exit 1
            fi
            ;;
        7z)
            if ! (cd "$dir" && 7z a -t7z "${target_name}.7z" "${files_to_add[@]}" > /dev/null); then
                echo "Error: Failed to create 7z archive." >&2; exit 1
            fi
            ;;
    esac
    exit 0
fi

# ==========================================
# 2. EXTRACTION & COMPRESSION (unzip, untar, gzip, gunzip, 7x)
# Extracts into a SEPARATE FOLDER (Windows/7-Zip style)
# ==========================================
for f in "$@"; do
    if [[ ! -e "$f" ]]; then
        echo "Error: '$f' does not exist. Skipping." >&2
        continue
    fi
    
    f_dir=$(dirname "$f")
    f_name=$(basename "$f")
    base_name=$(get_base_name "$f_name")

    # Determine extraction directory (mimics "Extract to folder" behavior)
    extract_dir="$base_name"
    if [[ -d "$extract_dir" ]]; then
        # If folder already exists, append timestamp to prevent overwriting/mixing
        extract_dir="${base_name}_${timestamp}"
    fi

    case "$action" in
        unzip)
            mkdir -p "$extract_dir"
            # -d specifies the extraction directory
            if ! (cd "$f_dir" && unzip -o -q "$f_name" -d "$extract_dir" > /dev/null); then
                echo "Error: Failed to unzip '$f_name'." >&2
            fi
            ;;
        untar)
            mkdir -p "$extract_dir"
            # -C specifies the extraction directory
            if ! (cd "$f_dir" && tar -xf "$f_name" -C "$extract_dir" > /dev/null); then
                echo "Error: Failed to untar '$f_name'." >&2
            fi
            ;;
        gzip)
            if ! (cd "$f_dir" && gzip -c "$f_name" > "${base_name}_${timestamp}.gz"); then
                echo "Error: Failed to gzip '$f_name'." >&2
            fi
            ;;
        gunzip)
            if ! (cd "$f_dir" && gunzip -c "$f_name" > "${f_name%.gz}"); then
                echo "Error: Failed to gunzip '$f_name'." >&2
            fi
            ;;
        7x)
            mkdir -p "$extract_dir"
            # -o specifies the extraction directory (no space after -o)
            if ! (cd "$f_dir" && 7z x -y "$f_name" -o"$extract_dir" > /dev/null); then
                echo "Error: Failed to extract 7z '$f_name'." >&2
            fi
            ;;
        *)
            echo "Error: Unknown action '$action'." >&2
            exit 1
            ;;
    esac
done
