#!/bin/bash
# Clickable Wallpaper Picker using wofi + swww

WALL_DIR="$HOME/walls"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Ensure monitor detected
if [[ -z "$focused_monitor" ]]; then
    notify-send "Error" "Could not detect focused monitor"
    exit 1
fi

# Generate icon size based on monitor height
scale_factor=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .scale')
monitor_height=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .height')
icon_size=$(awk "BEGIN{size=($monitor_height*3)/($scale_factor*150); if(size<15) size=20; if(size>25) size=25; print size}")

# Kill existing swww daemons
pkill swww 2>/dev/null

# Start swww daemon if not running
if ! pgrep -x "swww-daemon" >/dev/null; then
    swww-daemon --format xrgb &
    sleep 1
fi

# Build list of wallpapers
mapfile -t WALLPAPERS < <(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort)

# Add random option
RANDOM_WALL="${WALLPAPERS[RANDOM % ${#WALLPAPERS[@]}]}"
MENU_OPTIONS=("Random" "${WALLPAPERS[@]}")

# Show wofi menu
CHOICE=$(printf '%s\n' "${MENU_OPTIONS[@]}" | wofi -d -p "Select Wallpaper")

# Exit if nothing selected
[[ -z "$CHOICE" ]] && exit 0

# Resolve choice
if [[ "$CHOICE" == "Random" ]]; then
    SELECTED="$RANDOM_WALL"
else
    SELECTED="$CHOICE"
fi

# Apply wallpaper
swww img -o "$focused_monitor" "$SELECTED" --transition-fps 60 --transition-type any --transition-duration 2 --transition-bezier .43,1.19,1,.4

# Optional: show notification
notify-send "Wallpaper Set" "$(basename "$SELECTED")"
