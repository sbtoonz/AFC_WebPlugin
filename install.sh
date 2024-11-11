#!/bin/bash

# Define paths
PLUGIN_SRC="moonraker/components/afc_plugin.py"
PLUGIN_DST="$HOME/moonraker/components/afc_plugin.py"
MAINSAIL_SRC="MainsailworkingCopy.zip"
FLUIDD_SRC="FluiddworkingCopy.zip"
MAINSAIL_DST="$HOME/mainsail"
FLUIDD_DST="$HOME/fluidd"
MOONRAKER_CONF="$HOME/printer_data/config/moonraker.conf"

# Symlink afc_plugin.py
if [ -e "$PLUGIN_SRC" ]; then
    echo "Creating symlink for afc_plugin.py..."
    mkdir -p "$HOME/moonraker/components" && ln -sf "$PWD/$PLUGIN_SRC" "$PLUGIN_DST"
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

# User selection for Mainsail or Fluidd
read -p "Do you want to install Mainsail or Fluidd? (m/f): " USER_CHOICE

if [ "$USER_CHOICE" == "m" ] || [ "$USER_CHOICE" == "M" ]; then
    # Unzip MainsailworkingCopy.zip
    if [ -e "$MAINSAIL_SRC" ]; then
        if [ -d "$MAINSAIL_DST" ]; then
            echo "Moving existing ~/mainsail to ~/mainsail.old..."
            mv "$MAINSAIL_DST" "${MAINSAIL_DST}.old"
        fi
        echo "Unzipping MainsailworkingCopy.zip to ~/mainsail..."
        mkdir -p "$MAINSAIL_DST" && unzip -o "$MAINSAIL_SRC" -d "$MAINSAIL_DST"
        echo "Unzip complete."
    else
        echo "Error: $MAINSAIL_SRC not found. Aborting."
        exit 1
    fi
elif [ "$USER_CHOICE" == "f" ] || [ "$USER_CHOICE" == "F" ]; then
    # Unzip FluiddworkingCopy.zip
    if [ -e "$FLUIDD_SRC" ]; then
        if [ -d "$FLUIDD_DST" ]; then
            echo "Moving existing ~/fluidd to ~/fluidd.old..."
            mv "$FLUIDD_DST" "${FLUIDD_DST}.old"
        fi
        echo "Unzipping FluiddworkingCopy.zip to ~/fluidd..."
        mkdir -p "$FLUIDD_DST" && unzip -o "$FLUIDD_SRC" -d "$FLUIDD_DST"
        echo "Unzip complete."
    else
        echo "Error: $FLUIDD_SRC not found. Aborting."
        exit 1
    fi
else
    echo "Invalid choice. Aborting."
    exit 1
fi

# Modify moonraker.cfg to add afc_plugin configuration
if [ -e "$MOONRAKER_CONF" ]; then
    if ! grep -q "\[afc_plugin\]" "$MOONRAKER_CONF"; then
        echo "Modifying moonraker.cfg to add afc_plugin configuration..."
        sed -i '/\[update_manager\]/a\[afc_plugin]\nspoolman_port: 7912\nspoolman_ip: localhost' "$MOONRAKER_CONF"
        echo "moonraker.cfg modified."
    else
        echo "afc_plugin configuration already exists. Skipping modification."
    fi
else
    echo "Error: $MOONRAKER_CONF not found. Aborting."
    exit 1
fi

# Create a symbolic link for afc_plugin.py to Moonraker directory
if [ -e "$PLUGIN_DST" ]; then
    echo "Creating symbolic link for afc_plugin.py in Moonraker directory..."
    ln -sf "$PWD/$PLUGIN_SRC" "$PLUGIN_DST"
    echo "Symbolic link created."
else
    echo "Error: $PLUGIN_DST not found. Aborting."
    exit 1
fi

# Install httpx using pip
echo "Installing httpx using pip..."
~/moonraker-env/bin/pip install httpx
if [ $? -eq 0 ]; then
    echo "httpx installed successfully."
else
    echo "Error installing httpx. Aborting."
    exit 1
fi

echo "Installation complete."
