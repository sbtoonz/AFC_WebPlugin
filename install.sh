#!/bin/bash

MOONRAKER_COMPONENTS_DIR="~/moonraker/moonraker/components"
FLUIDD_UI_DIR="~/fluidd/config/custom_cards"
MAISAIL_UI_DIR="~/mainsail/config/custom_cards"

echo "Installing AFC Moonraker Plugin..."
cp components/afc_plugin.py $MOONRAKER_COMPONENTS_DIR/
echo "Moonraker Plugin copied to: $MOONRAKER_COMPONENTS_DIR"

echo "Do you want to install the custom card for Fluidd or Mainsail?"
echo "Type 1 for Fluidd, 2 for Mainsail, or 3 for Both:"
read ui_choice

if [ "$ui_choice" -eq "1" ] || [ "$ui_choice" -eq "3" ]; then
    echo "Installing custom card for Fluidd..."
    mkdir -p $FLUIDD_UI_DIR
    cp interface/afc_spools.html $FLUIDD_UI_DIR/
    echo "Custom card installed for Fluidd at: $FLUIDD_UI_DIR"
fi

if [ "$ui_choice" -eq "2" ] || [ "$ui_choice" -eq "3" ]; then
    echo "Installing custom card for Mainsail..."
    mkdir -p $MAISAIL_UI_DIR
    cp interface/afc_spools.html $MAISAIL_UI_DIR/
    echo "Custom card installed for Mainsail at: $MAISAIL_UI_DIR"
fi

echo "Restarting Moonraker service to apply changes..."
sudo systemctl restart moonraker
echo "Installation complete. Moonraker has been restarted."
