import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import "../code/homeassistant.js" as HomeAssistant

ColumnLayout {
    id: fullRoot

    Layout.minimumWidth: Kirigami.Units.gridUnit * 15
    Layout.minimumHeight: Kirigami.Units.gridUnit * 18
    Layout.preferredWidth: Kirigami.Units.gridUnit * 18
    Layout.preferredHeight: Kirigami.Units.gridUnit * 20

    spacing: Kirigami.Units.smallSpacing

    // Header
    PlasmaExtras.PlasmoidHeading {
        Layout.fillWidth: true

        RowLayout {
            anchors.fill: parent

            Kirigami.Heading {
                level: 3
                text: i18n("Office AC")
                Layout.fillWidth: true
            }

            QQC2.ToolButton {
                icon.name: "view-refresh"
                onClicked: root.refreshState()
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: i18n("Refresh")
            }
        }
    }

    // Status Display
    Kirigami.Card {
        Layout.fillWidth: true

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true

                QQC2.Label {
                    text: i18n("Status:")
                    font.weight: Font.Bold
                }

                QQC2.Label {
                    text: {
                        if (!root.isConnected) return i18n("Disconnected");
                        if (root.hvacMode === "off") return i18n("Off");
                        if (root.hvacMode === "cool") return i18n("Cooling");
                        if (root.hvacMode === "heat") return i18n("Heating");
                        return root.hvacMode;
                    }
                    color: {
                        if (!root.isConnected) return Kirigami.Theme.negativeTextColor;
                        if (root.hvacMode === "off") return Kirigami.Theme.disabledTextColor;
                        return Kirigami.Theme.textColor;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.currentTemperature > 0

                QQC2.Label {
                    text: i18n("Current:")
                    font.weight: Font.Bold
                }

                QQC2.Label {
                    text: root.currentTemperature.toFixed(1) + "°C"
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.hvacMode !== "off"

                QQC2.Label {
                    text: i18n("Target:")
                    font.weight: Font.Bold
                }

                QQC2.Label {
                    text: root.targetTemperature.toFixed(0) + "°C"
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                }
            }
        }
    }

    // Power Controls
    Kirigami.Card {
        Layout.fillWidth: true

        header: Kirigami.Heading {
            level: 4
            text: i18n("Power")
            padding: Kirigami.Units.smallSpacing
        }

        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing

            QQC2.Button {
                Layout.fillWidth: true
                text: i18n("Turn On")
                icon.name: "system-run"
                enabled: root.isConnected && root.hvacMode === "off"
                onClicked: root.turnOn()
            }

            QQC2.Button {
                Layout.fillWidth: true
                text: i18n("Turn Off")
                icon.name: "system-shutdown"
                enabled: root.isConnected && root.hvacMode !== "off"
                onClicked: root.turnOff()
            }
        }
    }

    // Mode Selection
    Kirigami.Card {
        Layout.fillWidth: true

        header: Kirigami.Heading {
            level: 4
            text: i18n("Mode")
            padding: Kirigami.Units.smallSpacing
        }

        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing

            QQC2.Button {
                Layout.fillWidth: true
                text: i18n("Cool")
                icon.name: "temperature-cold"
                checkable: true
                checked: root.hvacMode === "cool"
                enabled: root.isConnected && root.hvacMode !== "off"
                onClicked: root.setMode("cool")
            }

            QQC2.Button {
                Layout.fillWidth: true
                text: i18n("Heat")
                icon.name: "temperature-warm"
                checkable: true
                checked: root.hvacMode === "heat"
                enabled: root.isConnected && root.hvacMode !== "off"
                onClicked: root.setMode("heat")
            }

            QQC2.Button {
                Layout.fillWidth: true
                text: i18n("Auto")
                icon.name: "temperature-normal"
                checkable: true
                checked: root.hvacMode === "auto" || root.hvacMode === "heat_cool"
                enabled: root.isConnected && root.hvacMode !== "off"
                onClicked: root.setMode("auto")
            }
        }
    }

    // Temperature Control
    Kirigami.Card {
        Layout.fillWidth: true
        visible: root.hvacMode !== "off"

        header: Kirigami.Heading {
            level: 4
            text: i18n("Temperature")
            padding: Kirigami.Units.smallSpacing
        }

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true

                QQC2.Button {
                    text: "-"
                    icon.name: "list-remove"
                    enabled: root.isConnected && tempSlider.value > tempSlider.from
                    onClicked: {
                        tempSlider.value = Math.max(tempSlider.from, tempSlider.value - 1);
                        root.setTemperature(tempSlider.value);
                    }
                }

                QQC2.Slider {
                    id: tempSlider
                    Layout.fillWidth: true
                    from: 16
                    to: 30
                    stepSize: 1
                    value: root.targetTemperature
                    enabled: root.isConnected && root.hvacMode !== "off"

                    onMoved: {
                        tempValueLabel.text = value.toFixed(0) + "°C";
                    }

                    onPressedChanged: {
                        if (!pressed) {
                            root.setTemperature(value);
                        }
                    }
                }

                QQC2.Button {
                    text: "+"
                    icon.name: "list-add"
                    enabled: root.isConnected && tempSlider.value < tempSlider.to
                    onClicked: {
                        tempSlider.value = Math.min(tempSlider.to, tempSlider.value + 1);
                        root.setTemperature(tempSlider.value);
                    }
                }
            }

            QQC2.Label {
                id: tempValueLabel
                Layout.alignment: Qt.AlignHCenter
                text: tempSlider.value.toFixed(0) + "°C"
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
                font.weight: Font.Bold
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }

    // Footer with last update time
    QQC2.Label {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: root.lastUpdate ? i18n("Updated: %1", Qt.formatTime(root.lastUpdate, "hh:mm:ss")) : ""
        font.pointSize: Kirigami.Theme.smallFont.pointSize
        color: Kirigami.Theme.disabledTextColor
    }
}
