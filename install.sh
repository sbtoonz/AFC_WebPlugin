#!/bin/bash

# Define paths
PLUGIN_SRC="moonraker/components/afc_plugin.py"
PLUGIN_DST="~/moonraker/components/afc_plugin.py"
MAINSAIL_SRC="MainsailworkingCopy.zip"
MAINSAIL_DST="~/mainsail"

# Symlink afc_plugin.py
if [ -e "$PLUGIN_SRC" ]; then
    echo "Creating symlink for afc_plugin.py..."
    ln -sf "$PWD/$PLUGIN_SRC" "$PLUGIN_DST"
    echo "Symlink created."
else
    echo "Error: $PLUGIN_SRC not found. Aborting."
    exit 1
fi

# Restart Moonraker service
if sudo systemctl restart moonraker; then
    echo "Moonraker restarted successfully."
else
    echo "Error restarting Moonraker. Aborting."
    exit 1
fi

# Unzip MainsailworkingCopy.zip
if [ -e "$MAINSAIL_SRC" ]; then
    if [ -d "$MAINSAIL_DST" ]; then
        echo "Moving existing ~/mainsail to ~/mainsail.old..."
        mv "$MAINSAIL_DST" "${MAINSAIL_DST}.old"
    fi
    echo "Unzipping MainsailworkingCopy.zip to ~/mainsail..."
    unzip -o "$MAINSAIL_SRC" -d "$MAINSAIL_DST"
    echo "Unzip complete."
else
    echo "Error: $MAINSAIL_SRC not found. Aborting."
    exit 1
fi

echo "Installation complete."
