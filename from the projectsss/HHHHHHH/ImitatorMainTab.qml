import QtQuick 2.12
import QtQuick.Controls 2.12
import "Items"

Rectangle {
    id: imitatorBody
    width: 1440
    height: 100
    color: "#2D2D30"
    clip: true

    property var mainWindow: null

    Row {
        anchors.fill: parent
        spacing: 7
        anchors.margins: 5

        PortItem {
            id: portItem
            height: parent.height
            width: 356
        }

        ConfigurateItem {
            id: configurate
            height: parent.height
            width: 330
        }

        MessagesItem {
            id: messages
            height: parent.height
            width: 164
        }

        AdditionalConfigurateItem {
            id: additionalConfigurate
            height: parent.height
            width: 280
        }

        TimeDateItem {
            id: timeDateItem
            height: parent.height
            width: 100
        }
    }
}
