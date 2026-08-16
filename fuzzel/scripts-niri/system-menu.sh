#!/usr/bin/env bash

set -u

if [[ -z "${HOME:-}" ]]; then
    printf 'error: HOME is not set\n' >&2
    exit 1
fi

TCLIENT_DIR="${TCLIENT_DIR:-$HOME/programs/TClient-10.8.7-linux_x86_64}"
TCLIENT_BIN="$TCLIENT_DIR/DDNet"

notify() {
    local urgency="$1"
    local title="$2"
    local body="$3"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u "$urgency" "$title" "$body" || true
    else
        printf '[%s] %s: %s\n' "$urgency" "$title" "$body" >&2
    fi

    return 0
}

require_cmd() {
    local cmd
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            notify critical "Missing dependency" "$cmd is not installed"
            exit 1
        fi
    done
}

launch_tclient() {
    local use_mangohud="$1"

    if [[ ! -e "$TCLIENT_BIN" ]]; then
        notify critical "TClient" "File not found: $TCLIENT_BIN"
        exit 1
    fi

    if [[ ! -x "$TCLIENT_BIN" ]]; then
        notify critical "TClient" "Not executable: $TCLIENT_BIN"
        exit 1
    fi

    if ! cd "$TCLIENT_DIR"; then
        notify critical "TClient" "Cannot change directory to $TCLIENT_DIR"
        exit 1
    fi

    if [[ "$use_mangohud" == "yes" ]]; then
        require_cmd mangohud
        exec mangohud ./DDNet
    else
        exec ./DDNet
    fi
}

restart_user_units() {
    local unit
    local units=()

    for unit in "$@"; do
        if systemctl --user cat "$unit" >/dev/null 2>&1; then
            units+=("$unit")
        fi
    done

    if (( ${#units[@]} == 0 )); then
        notify critical "systemd --user" "No units found: $*"
        return 1
    fi

    if systemctl --user restart "${units[@]}"; then
        notify low "systemd --user" "Restarted: ${units[*]}"
    else
        notify critical "systemd --user" "Failed to restart: ${units[*]}"
        return 1
    fi
}

restart_xdg_portals() {
    local units=()
    local backend
    local unit

    if systemctl --user cat xdg-desktop-portal.service >/dev/null 2>&1; then
        units+=("xdg-desktop-portal.service")
    fi

    for backend in wlr gnome gtk hyprland kde lxqt; do
        unit="xdg-desktop-portal-${backend}.service"
        if systemctl --user cat "$unit" >/dev/null 2>&1 && systemctl --user is-active --quiet "$unit"; then
            units+=("$unit")
        fi
    done

    if (( ${#units[@]} == 0 )); then
        notify critical "xdg-desktop-portal" "No portal units found/active"
        return 1
    fi

    if systemctl --user restart "${units[@]}"; then
        notify low "xdg-desktop-portal" "Restarted: ${units[*]}"
    else
        notify critical "xdg-desktop-portal" "Failed to restart: ${units[*]}"
        return 1
    fi
}

restart_system_unit() {
    local unit="$1"

    require_cmd pkexec

    if pkexec systemctl restart "$unit"; then
        notify low "systemctl" "Restarted system unit: $unit"
    else
        notify critical "systemctl" "Failed to restart system unit: $unit"
        return 1
    fi
}

udisks2_unmask_start() {
    require_cmd pkexec

    if pkexec systemctl unmask udisks2.service \
        && pkexec systemctl start udisks2.service \
        && systemctl is-active --quiet udisks2.service; then
        notify low "udisks2" "Unmasked and started"
    else
        notify critical "udisks2" "Failed to unmask or start"
        return 1
    fi
}

udisks2_stop_mask() {
    require_cmd pkexec

    if pkexec systemctl stop udisks2.service \
        && pkexec systemctl mask udisks2.service \
        && ! systemctl is-active --quiet udisks2.service; then
        notify low "udisks2" "Stopped and masked"
    else
        notify critical "udisks2" "Failed to stop or mask"
        return 1
    fi
}

restart_dunst() {
    if systemctl --user is-active --quiet dunst.service; then
        if systemctl --user restart dunst.service; then
            notify low "dunst" "Restarted via systemd user service"
        else
            notify critical "dunst" "Failed to restart dunst.service"
            return 1
        fi
        return 0
    fi

    if ! command -v dunst >/dev/null 2>&1; then
        notify critical "dunst" "dunst is not installed"
        return 1
    fi

    require_cmd pkill setsid

    pkill -x dunst 2>/dev/null || true
    sleep 0.3
    setsid dunst >/dev/null 2>&1 &

    notify low "dunst" "Restarted manually"
}

require_cmd systemctl fuzzel

options=(
    "TClient (mangohud): launch"
    "TClient: launch"
    "dunst: restart"
    "udisks2: unmask & start"
    "udisks2: stop & mask"
    "udisks2: restart"
    "xdg-desktop-portal: restart"
    "systemd --user: daemon-reload"
    "systemd --user: reset failed"
)

lines=${#options[@]}
(( lines > 12 )) && lines=12

choice=$(printf '%s\n' "${options[@]}" | fuzzel --dmenu \
    --mesg "System actions" \
    --lines "$lines" \
    --width 30)

if [[ -z "$choice" ]]; then
    exit 0
fi

case "$choice" in
    "TClient (mangohud): launch")
        launch_tclient yes
        ;;

    "TClient: launch")
        launch_tclient no
        ;;

    "udisks2: unmask & start")
        udisks2_unmask_start
        ;;

    "udisks2: stop & mask")
        udisks2_stop_mask
        ;;

    "udisks2: restart")
        restart_system_unit udisks2.service
        ;;

    "xdg-desktop-portal: restart")
        restart_xdg_portals
        ;;

    "dunst: restart")
        restart_dunst
        ;;

    "systemd --user: daemon-reload")
        if systemctl --user daemon-reload; then
            notify low "systemd --user" "Daemon reloaded"
        else
            notify critical "systemd --user" "Failed to reload daemon"
            exit 1
        fi
        ;;

    "systemd --user: reset failed")
        if systemctl --user reset-failed; then
            notify low "systemd --user" "Failed units reset"
        else
            notify critical "systemd --user" "Failed to reset failed units"
            exit 1
        fi
        ;;

    *)
        notify critical "Menu" "Unknown action: $choice"
        exit 1
        ;;
esac

exit_status=$?
exit "$exit_status"
