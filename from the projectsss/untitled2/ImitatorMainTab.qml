import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

Rectangle {
    id: imitatorBody
    width: parent.width
    height: 100
    color: "#2D2D30"
    clip: true

    property var mainWindow: null

    Row {
        anchors.fill: parent
        spacing: 7
        anchors.topMargin: 3
        anchors.bottomMargin: 3
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        Rectangle {
            id: portItem
            height: parent.height
            width: 356
            color: "white"
        }

        Rectangle {
            id: configurate
            height: parent.height
            width: 330
            color: "white"
        }

        Rectangle {
            id: messages
            height: parent.height
            width: 164
            color:"white"
        }

        Rectangle {
            id: additionalConfigurate
            height: parent.height
            width: 280
            color: "#252525"

        }

        Rectangle {
            id: timeDateItem
            height: parent.height
            width: 100
            color: "#252525"
        }
    }
}


