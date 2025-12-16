import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    Layout.minimumWidth: Kirigami.Units.iconSizes.small
    Layout.minimumHeight: Kirigami.Units.iconSizes.small
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    property bool isActive: false
    property string currentMode: "off"
    property real currentTemp: 0
    property real targetTemp: 0

    Kirigami.Icon {
        id: icon
        anchors.fill: parent
        source: getIconName()
        active: compactMouseArea.containsMouse

        function getIconName() {
            if (currentMode === "off") {
                return "preferences-system-power-management";
            } else if (currentMode === "cool") {
                return "temperature-cold";
            } else if (currentMode === "heat") {
                return "temperature-warm";
            } else {
                return "temperature-normal";
            }
        }
    }

    MouseArea {
        id: compactMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            Plasmoid.expanded = !Plasmoid.expanded;
        }
    }

    // Visual indicator when AC is active
    Rectangle {
        width: 8
        height: 8
        radius: 4
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 2
        color: {
            if (currentMode === "cool") return Kirigami.Theme.positiveTextColor;
            if (currentMode === "heat") return Kirigami.Theme.negativeTextColor;
            return "transparent";
        }
        visible: currentMode !== "off"
    }
}
