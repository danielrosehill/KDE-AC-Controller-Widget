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

        QQC2.TextField {
            id: entityIdField
            Kirigami.FormData.label: i18n("Climate Entity ID:")
            placeholderText: "climate.office_ac"
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
