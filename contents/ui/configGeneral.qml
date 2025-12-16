import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_haUrl: haUrlField.text
    property alias cfg_haToken: haTokenField.text
    property alias cfg_entityId: entityIdField.text
    property alias cfg_refreshInterval: refreshIntervalSpinBox.value

    property var climateEntities: []
    property bool isDiscovering: false

    function discoverEntities() {
        if (!haUrlField.text || !haTokenField.text) {
            statusLabel.text = i18n("Please enter URL and token first");
            statusLabel.color = Kirigami.Theme.negativeTextColor;
            return;
        }

        isDiscovering = true;
        statusLabel.text = i18n("Discovering climate entities...");
        statusLabel.color = Kirigami.Theme.textColor;
        climateEntities = [];

        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isDiscovering = false;
                if (xhr.status === 200) {
                    try {
                        var states = JSON.parse(xhr.responseText);
                        var entities = [];

                        for (var i = 0; i < states.length; i++) {
                            if (states[i].entity_id.startsWith("climate.")) {
                                entities.push({
                                    entity_id: states[i].entity_id,
                                    name: states[i].attributes.friendly_name || states[i].entity_id
                                });
                            }
                        }

                        climateEntities = entities;

                        if (entities.length > 0) {
                            statusLabel.text = i18n("Found %1 climate device(s)", entities.length);
                            statusLabel.color = Kirigami.Theme.positiveTextColor;
                        } else {
                            statusLabel.text = i18n("No climate entities found");
                            statusLabel.color = Kirigami.Theme.neutralTextColor;
                        }
                    } catch (e) {
                        statusLabel.text = i18n("Error parsing response");
                        statusLabel.color = Kirigami.Theme.negativeTextColor;
                    }
                } else {
                    statusLabel.text = i18n("Discovery failed: %1", xhr.status);
                    statusLabel.color = Kirigami.Theme.negativeTextColor;
                }
            }
        };

        xhr.open("GET", haUrlField.text + "/api/states");
        xhr.setRequestHeader("Authorization", "Bearer " + haTokenField.text);
        xhr.send();
    }

    Kirigami.FormLayout {
        QQC2.TextField {
            id: haUrlField
            Kirigami.FormData.label: i18n("Home Assistant URL:")
            placeholderText: "http://homeassistant.local:8123"
        }

        QQC2.TextField {
            id: haTokenField
            Kirigami.FormData.label: i18n("Access Token:")
            echoMode: TextInput.Password
            placeholderText: i18n("Long-lived access token")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Discover Devices:")

            QQC2.Button {
                text: i18n("Discover Climate Entities")
                icon.name: "search"
                enabled: !isDiscovering && haUrlField.text && haTokenField.text
                onClicked: discoverEntities()
            }

            QQC2.BusyIndicator {
                visible: isDiscovering
                running: isDiscovering
                implicitWidth: Kirigami.Units.iconSizes.small
                implicitHeight: Kirigami.Units.iconSizes.small
            }
        }

        QQC2.Label {
            id: statusLabel
            Kirigami.FormData.label: i18n("Status:")
            text: i18n("Click 'Discover' to find climate entities")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        QQC2.ComboBox {
            id: entityComboBox
            Kirigami.FormData.label: i18n("Select Air Conditioner:")
            Layout.fillWidth: true
            visible: climateEntities.length > 0
            textRole: "name"
            valueRole: "entity_id"

            model: climateEntities

            onActivated: {
                if (currentIndex >= 0) {
                    entityIdField.text = climateEntities[currentIndex].entity_id;
                }
            }

            Component.onCompleted: {
                // Set current index based on configured entity
                for (var i = 0; i < climateEntities.length; i++) {
                    if (climateEntities[i].entity_id === entityIdField.text) {
                        currentIndex = i;
                        break;
                    }
                }
            }
        }

        QQC2.TextField {
            id: entityIdField
            Kirigami.FormData.label: i18n("Climate Entity ID:")
            placeholderText: "climate.office_ac"
            visible: climateEntities.length === 0
        }

        QQC2.Label {
            text: i18n("Or enter manually above if discovery fails")
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            color: Kirigami.Theme.disabledTextColor
            visible: climateEntities.length === 0
        }

        QQC2.SpinBox {
            id: refreshIntervalSpinBox
            Kirigami.FormData.label: i18n("Refresh Interval (seconds):")
            from: 5
            to: 300
            stepSize: 5
        }
    }
}
