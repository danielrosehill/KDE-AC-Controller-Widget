#!/bin/bash

# KDE AC Controller Widget Update Script
# Uninstalls old version and installs new version

WIDGET_ID="com.danielrosehill.ac-controller"
INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/$WIDGET_ID"

echo "========================================="
echo "KDE AC Controller Widget Updater"
echo "========================================="
echo ""

# Check if widget is currently installed
if [ -d "$INSTALL_DIR" ]; then
    echo "Found existing installation at:"
    echo "$INSTALL_DIR"
    echo ""
    echo "Removing old version..."
    rm -rf "$INSTALL_DIR"
    echo "Old version removed."
    echo ""
else
    echo "No existing installation found."
    echo "This will perform a fresh install."
    echo ""
fi

# Create installation directory
echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"

# Copy widget files
echo "Copying widget files..."
cp -r contents "$INSTALL_DIR/"
cp metadata.json "$INSTALL_DIR/"

# Set proper permissions
echo "Setting permissions..."
chmod -R 755 "$INSTALL_DIR"

# Verify installation
if [ -f "$INSTALL_DIR/metadata.json" ] && [ -d "$INSTALL_DIR/contents" ]; then
    echo ""
    echo "========================================="
    echo "Update successful!"
    echo "========================================="
    echo ""
    echo "The widget has been updated to the latest version."
    echo ""
    echo "IMPORTANT: You must restart Plasma Shell for changes to take effect:"
    echo "   plasmashell --replace &"
    echo ""
    echo "Note: Your existing configuration (HA URL, token, entity ID) will be preserved."
    echo ""

    read -p "Restart Plasma Shell now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Restarting Plasma Shell..."
        plasmashell --replace &
        echo "Done!"
    else
        echo ""
        echo "Remember to restart Plasma Shell when ready:"
        echo "   plasmashell --replace &"
    fi
else
    echo ""
    echo "========================================="
    echo "Update failed!"
    echo "========================================="
    echo "Please check the error messages above."
    exit 1
fi
