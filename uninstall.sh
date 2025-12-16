#!/bin/bash

# KDE AC Controller Widget Uninstall Script
# Removes the widget from the system

WIDGET_ID="com.danielrosehill.ac-controller"
INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/$WIDGET_ID"

echo "========================================="
echo "KDE AC Controller Widget Uninstaller"
echo "========================================="
echo ""

# Check if widget is installed
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Widget is not installed."
    echo "Nothing to uninstall."
    exit 0
fi

echo "Found widget installation at:"
echo "$INSTALL_DIR"
echo ""

read -p "Are you sure you want to uninstall? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Remove widget directory
echo ""
echo "Removing widget files..."
rm -rf "$INSTALL_DIR"

# Verify removal
if [ ! -d "$INSTALL_DIR" ]; then
    echo ""
    echo "========================================="
    echo "Uninstall successful!"
    echo "========================================="
    echo ""
    echo "The widget has been removed from your system."
    echo ""
    echo "IMPORTANT: You must restart Plasma Shell for changes to take effect:"
    echo "   plasmashell --replace &"
    echo ""
    echo "Note: If the widget is still in your system tray after restart,"
    echo "you can remove it by:"
    echo "1. Right-click on system tray"
    echo "2. Select 'Configure System Tray...'"
    echo "3. Remove 'AC Controller' from the list"
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
    echo "Uninstall failed!"
    echo "========================================="
    echo "Could not remove widget directory."
    echo "You may need to remove it manually:"
    echo "   rm -rf $INSTALL_DIR"
    exit 1
fi
