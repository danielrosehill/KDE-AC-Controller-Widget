import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.notification
import "../code/homeassistant.js" as HomeAssistant

PlasmoidItem {
    id: root

    // Plasmoid configuration
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground

    // Properties
    property string haUrl: Plasmoid.configuration.haUrl
    property string haToken: Plasmoid.configuration.haToken
    property string entityId: Plasmoid.configuration.entityId
    property int refreshInterval: Plasmoid.configuration.refreshInterval

    // State properties
    property bool isConnected: false
    property string hvacMode: "off"
    property var hvacModes: []
    property real currentTemperature: 0
    property real targetTemperature: 22
    property date lastUpdate: null

    // UI Components
    compactRepresentation: CompactRepresentation {
        isActive: root.hvacMode !== "off"
        currentMode: root.hvacMode
        currentTemp: root.currentTemperature
        targetTemp: root.targetTemperature
    }

    fullRepresentation: FullRepresentation {}

    // Refresh timer
    Timer {
        id: refreshTimer
        interval: root.refreshInterval * 1000
        running: true
        repeat: true
        onTriggered: root.refreshState()
    }

    // Initial load timer (delayed to ensure config is loaded)
    Timer {
        id: initialLoadTimer
        interval: 1000
        running: true
        repeat: false
        onTriggered: root.refreshState()
    }

    // Functions
    function refreshState() {
        if (!haUrl || !haToken || !entityId) {
            console.warn("Missing configuration");
            isConnected = false;
            return;
        }

        HomeAssistant.getState(haUrl, haToken, entityId, function(success, data) {
            if (success && data) {
                isConnected = true;
                hvacMode = data.state || "off";
                currentTemperature = data.attributes.current_temperature || 0;
                targetTemperature = data.attributes.temperature || 22;
                hvacModes = data.attributes.hvac_modes || [];
                lastUpdate = new Date();

                // Update compact representation
                if (compactRepresentation) {
                    compactRepresentation.isActive = (hvacMode !== "off");
                    compactRepresentation.currentMode = hvacMode;
                    compactRepresentation.currentTemp = currentTemperature;
                    compactRepresentation.targetTemp = targetTemperature;
                }
            } else {
                isConnected = false;
                console.error("Failed to get state");
            }
        });
    }

    function setMode(mode) {
        if (!isConnected) return;

        HomeAssistant.setHvacMode(haUrl, haToken, entityId, mode, function(success, data) {
            if (success) {
                showNotification(i18n("Mode Changed"), i18n("AC mode set to %1", mode));
                // Refresh state after a short delay
                Qt.callLater(root.refreshState);
            } else {
                showNotification(i18n("Error"), i18n("Failed to change mode"), true);
            }
        });
    }

    function setTemperature(temp) {
        if (!isConnected || hvacMode === "off") return;

        HomeAssistant.setTemperature(haUrl, haToken, entityId, temp, function(success, data) {
            if (success) {
                showNotification(i18n("Temperature Set"), i18n("Target temperature: %1°C", temp.toFixed(0)));
                Qt.callLater(root.refreshState);
            } else {
                showNotification(i18n("Error"), i18n("Failed to set temperature"), true);
            }
        });
    }

    function turnOn() {
        if (!isConnected) return;

        HomeAssistant.turnOn(haUrl, haToken, entityId, function(success, data) {
            if (success) {
                showNotification(i18n("AC Turned On"), i18n("Office AC is now on"));
                Qt.callLater(root.refreshState);
            } else {
                showNotification(i18n("Error"), i18n("Failed to turn on AC"), true);
            }
        });
    }

    function turnOff() {
        if (!isConnected) return;

        HomeAssistant.turnOff(haUrl, haToken, entityId, function(success, data) {
            if (success) {
                showNotification(i18n("AC Turned Off"), i18n("Office AC is now off"));
                Qt.callLater(root.refreshState);
            } else {
                showNotification(i18n("Error"), i18n("Failed to turn off AC"), true);
            }
        });
    }

    function showNotification(title, message, isError) {
        var notification = notificationComponent.createObject(root, {
            title: title,
            text: message,
            urgency: isError ? Notification.CriticalUrgency : Notification.LowUrgency
        });
        notification.sendEvent();
    }

    Component {
        id: notificationComponent
        Notification {
            componentName: "plasma_applet_com.danielrosehill.ac-controller"
            eventId: "ac-controller-event"
            iconName: "preferences-system-power-management"
        }
    }

    // Watch for configuration changes
    Connections {
        target: Plasmoid.configuration
        function onHaUrlChanged() { Qt.callLater(root.refreshState); }
        function onHaTokenChanged() { Qt.callLater(root.refreshState); }
        function onEntityIdChanged() { Qt.callLater(root.refreshState); }
        function onRefreshIntervalChanged() {
            refreshTimer.interval = root.refreshInterval * 1000;
        }
    }
}
