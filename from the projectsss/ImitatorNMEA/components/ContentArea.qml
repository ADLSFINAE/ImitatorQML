import QtQuick 2.12
import "PageTabs"

Rectangle {
    id: contentArea
    color: "#2D2D30"

    property ListModel pagesModel

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        PageTabBar {
            id: pageTabBar
            width: parent.width
            height: 50
            pagesModel: contentArea.pagesModel
        }

        Rectangle {
            id: blueStrip
            width: parent.width
            height: 5
            color: "#40E0D0"
        }

        Loader {
            id: pageLoader
            width: parent.width
            height: parent.height - pageTabBar.height - blueStrip.height - 20
            source: "qrc:/pages/Page1.qml"
        }
    }
}
