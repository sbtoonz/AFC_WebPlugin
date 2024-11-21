#!/bin/bash

# Define paths
MAINSAIL_SRC="MainsailworkingCopy.zip"
FLUIDD_SRC="FluiddworkingCopy.zip"
MAINSAIL_DST="$HOME/mainsail"
FLUIDD_DST="$HOME/fluidd"


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
        unzip -o "$MAINSAIL_SRC" -d "$MAINSAIL_DST"
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
        unzip -o "$FLUIDD_SRC" -d "$FLUIDD_DST"
        echo "Unzip complete."
    else
        echo "Error: $FLUIDD_SRC not found. Aborting."
        exit 1
    fi
else
    echo "Invalid choice. Aborting."
    exit 1
fi

echo "Installation complete."
