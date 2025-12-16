# KDE AC Controller Widget

A KDE Plasma 6 widget for controlling your Home Assistant air conditioner directly from the system tray.

## Features

- **System Tray Integration**: Quick access from your system tray
- **Power Control**: Turn your AC on/off with a single click
- **Mode Selection**: Switch between Cool, Heat, and Auto modes
- **Temperature Control**: Adjust temperature with slider or +/- buttons
- **Real-time Status**: See current and target temperatures at a glance
- **Auto-refresh**: Automatically updates AC status every 30 seconds (configurable)

## Requirements

- KDE Plasma 6
- Home Assistant instance with API access
- A climate entity (air conditioner) configured in Home Assistant

## Installation

### Method 1: Install from File (Recommended)

1. Download or clone this repository
2. Package the widget:
   ```bash
   ./install.sh
   ```

3. The script will automatically install the widget to your local Plasma widgets directory

### Method 2: Manual Installation

1. Create the package directory structure
2. Copy the widget files to `~/.local/share/plasma/plasmoids/com.danielrosehill.ac-controller/`
3. Restart Plasma Shell:
   ```bash
   plasmashell --replace &
   ```

## Configuration

1. **Add widget to system tray**:
   - Right-click on system tray
   - Select "Configure System Tray..."
   - Click "Add widgets..."
   - Find "AC Controller" and add it

2. **Configure the widget**:
   - Right-click the AC icon in system tray
   - Select "Configure AC Controller..."
   - Enter your settings:
     - **Home Assistant URL**: Your HA instance URL (e.g., `http://10.0.0.3:8123`)
     - **Access Token**: Long-lived access token from Home Assistant
     - **Climate Entity ID**: Your AC entity ID (e.g., `climate.office_ac`)
     - **Refresh Interval**: How often to update status (default: 30 seconds)

### Getting a Home Assistant Access Token

1. Log into your Home Assistant instance
2. Click on your profile (bottom left)
3. Scroll down to "Long-Lived Access Tokens"
4. Click "Create Token"
5. Give it a name (e.g., "KDE AC Widget")
6. Copy the token and paste it into the widget configuration

### Finding Your Climate Entity ID

1. In Home Assistant, go to Developer Tools → States
2. Search for your air conditioner
3. The entity ID will be something like `climate.office_ac` or `climate.living_room`
4. Copy the entity ID and paste it into the widget configuration

## Usage

### Compact View (System Tray)
- Click the icon to open the control popup
- Icon changes based on current mode:
  - Power icon when off
  - Snowflake when cooling
  - Flame when heating
- Small indicator dot shows when AC is active

### Popup Controls

**Status Display**
- Shows connection status
- Current temperature
- Target temperature

**Power Controls**
- Turn On: Powers on the AC (uses last known mode)
- Turn Off: Completely turns off the AC

**Mode Selection**
- Cool: Cooling mode
- Heat: Heating mode
- Auto: Automatic mode (heat/cool as needed)

**Temperature Control**
- Use slider to adjust temperature (16-30°C)
- Use +/- buttons for precise control
- Changes are sent to Home Assistant immediately

## Troubleshooting

### Widget Not Showing
- Restart Plasma Shell: `plasmashell --replace &`
- Check if files are in correct location: `~/.local/share/plasma/plasmoids/com.danielrosehill.ac-controller/`

### "Disconnected" Status
- Verify Home Assistant URL is correct
- Check that access token is valid and not expired
- Ensure entity ID exists in Home Assistant
- Check network connectivity to Home Assistant

### AC Not Responding
- Verify the entity supports the requested operation (check in HA Developer Tools)
- Check Home Assistant logs for errors
- Ensure the climate entity is available (not unavailable/unknown)

### Widget Configuration Not Saving
- Make sure you click "Apply" or "OK" in the configuration dialog
- Check file permissions in `~/.config/plasma-org.kde.plasma.desktop-appletsrc`

## Development

### Structure
```
com.danielrosehill.ac-controller/
├── metadata.json                   # Widget metadata
├── contents/
│   ├── ui/
│   │   ├── main.qml               # Main logic and state management
│   │   ├── CompactRepresentation.qml  # System tray icon
│   │   ├── FullRepresentation.qml     # Popup UI
│   │   └── configGeneral.qml      # Configuration UI
│   ├── config/
│   │   ├── main.xml               # Configuration schema
│   │   └── config.qml             # Configuration layout
│   └── code/
│       └── homeassistant.js       # Home Assistant API calls
```

### Testing
```bash
# Watch logs for debugging
journalctl -f | grep plasma

# Test Home Assistant API manually
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://YOUR_HA:8123/api/states/climate.YOUR_ENTITY
```

## License

GPL-3.0

## Author

Daniel Rosehill
- Website: [danielrosehill.com](https://danielrosehill.com)
- Email: daniel@danielrosehill.co.il

## Contributing

Issues and pull requests are welcome on GitHub.
