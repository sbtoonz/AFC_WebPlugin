#!/bin/bash

MOONRAKER_COMPONENTS_DIR="$HOME/moonraker/moonraker/components"
FLUIDD_UI_DIR="$HOME/fluidd/config/custom_cards"
MAISAIL_UI_DIR="$HOME/mainsail/config/custom_cards"

echo "Linking AFC Moonraker Plugin..."
ln -sfn $(pwd)/components/afc_plugin.py "$MOONRAKER_COMPONENTS_DIR/afc_plugin.py"
echo "Moonraker Plugin linked at: $MOONRAKER_COMPONENTS_DIR"

echo "Do you want to install the custom card for Fluidd or Mainsail?"
echo "Type 1 for Fluidd, 2 for Mainsail, or 3 for Both:"
read ui_choice

if [ "$ui_choice" -eq "1" ] || [ "$ui_choice" -eq "3" ]; then
    echo "Linking custom card for Fluidd..."
    mkdir -p "$FLUIDD_UI_DIR"
    ln -sfn $(pwd)/interface/afc_spools.html "$FLUIDD_UI_DIR/afc_spools.html"
    echo "Custom card linked for Fluidd at: $FLUIDD_UI_DIR"
fi

if [ "$ui_choice" -eq "2" ] || [ "$ui_choice" -eq "3" ]; then
    echo "Linking custom card for Mainsail..."
    mkdir -p "$MAISAIL_UI_DIR"
    ln -sfn $(pwd)/interface/afc_spools.html "$MAISAIL_UI_DIR/afc_spools.html"
    echo "Custom card linked for Mainsail at: $MAISAIL_UI_DIR"
fi

echo "Restarting Moonraker service to apply changes..."
sudo systemctl restart moonraker
echo "Installation complete. Moonraker has been restarted."
