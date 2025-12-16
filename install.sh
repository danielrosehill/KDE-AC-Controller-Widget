#!/bin/bash

# KDE AC Controller Widget Installation Script
# Installs the widget to the local Plasma widgets directory

WIDGET_ID="com.danielrosehill.ac-controller"
INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/$WIDGET_ID"

echo "========================================="
echo "KDE AC Controller Widget Installer"
echo "========================================="
echo ""

# Check if running KDE Plasma
if [ -z "$KDE_SESSION_VERSION" ]; then
    echo "Warning: KDE Plasma session not detected."
    echo "This widget is designed for KDE Plasma 6."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
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
    echo "Installation successful!"
    echo "========================================="
    echo ""
    echo "Next steps:"
    echo "1. Restart Plasma Shell:"
    echo "   plasmashell --replace &"
    echo ""
    echo "2. Add widget to system tray:"
    echo "   - Right-click on system tray"
    echo "   - Select 'Configure System Tray...'"
    echo "   - Click 'Add widgets...'"
    echo "   - Find 'AC Controller' and add it"
    echo ""
    echo "3. Configure the widget:"
    echo "   - Right-click the AC icon"
    echo "   - Select 'Configure AC Controller...'"
    echo "   - Enter your Home Assistant details"
    echo ""

    read -p "Restart Plasma Shell now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Restarting Plasma Shell..."
        plasmashell --replace &
        echo "Done!"
    fi
else
    echo ""
    echo "========================================="
    echo "Installation failed!"
    echo "========================================="
    echo "Please check the error messages above."
    exit 1
fi
