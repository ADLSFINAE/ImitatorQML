import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls 2.12
import "dialogs"

Rectangle {
    id: mainTab
    width: parent.width
    height: 100
    color: "#2D2D30"
    clip: true

    property var mainWindow: parent.parent.parent

    Row {
        anchors.fill: parent
        spacing: 7
        anchors.margins: 3

        MessagesItem { width: 164; height: parent.height }

        /*AdditionalConfigurate {
            width: 280;
            height: parent.height
            onOpenMessagesDialog: mainWindow.openMessagesDialog()
        }

        PortItem { width: 356; height: parent.height }
        ConfigurateItem { width: 330; height: parent.height }
        MessagesItem { width: 164; height: parent.height }
        TimeDateItem { width: 100; height: parent.height }*/
    }

    /*Component.onCompleted: {
        if (mainWindow && mainWindow.openMessagesDialog) {
            console.log("MainTab connected to MainWindow")
        }
    }*/
}
