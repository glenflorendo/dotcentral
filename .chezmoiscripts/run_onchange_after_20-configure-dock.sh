#!/bin/bash

set -euo pipefail

echo "Configuring the Dock..."

if ! command -v dockutil >/dev/null 2>&1; then
  echo "dockutil is required to configure the Dock." >&2
  exit 1
fi

# Finder and Trash are managed by macOS and remain at either end of the Dock.
dockutil --remove all --no-restart

apps=(
  "/System/Applications/iPhone Mirroring.app"
  "/Applications/Notion.app"
  "/Applications/ClickUp.app"
  "/Applications/Google Chrome.app"
  "/Applications/Discord.app"
  "/System/Applications/Messages.app"
  "/System/Applications/Notes.app"
  "/Applications/Slack.app"
)

default_folder_options=(
  --section others
  --display folder
  --no-restart
)

for app in "${apps[@]}"; do
  if [[ -d "$app" ]]; then
    dockutil --add "$app" --section apps --no-restart
  else
    echo "Skipping missing Dock app: $app" >&2
  fi
done

add_folder() {
  local folder=$1
  shift

  if [[ -d "$folder" ]]; then
    dockutil --add "$folder" "${default_folder_options[@]}" "$@"
  else
    echo "Skipping missing Dock folder: $folder" >&2
  fi
}

add_folder "/Applications" --sort name --view grid
add_folder "$HOME/Downloads" --sort dateadded --view list

killall Dock
