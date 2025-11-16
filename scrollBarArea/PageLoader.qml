import QtQuick 2.12
import QtQuick.Controls 2.12
import "../Items"

Rectangle {
    id: pageLoader
    color: "transparent"

    property string source: ""
    property color pageColor: "blue"

    property var pageData: ({})
    property string pageName: ""
    property bool someBoolProperty: false

    // Добавить в корневой элемент:
    signal pageContentChanged()

    // И подключить к нему сбор данных:
    onPageContentChanged: {
        if (tabArea) {
            tabArea.collectPageData();
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        source: parent.source
    }

    Rectangle {
        id: jsonContent
        anchors.fill: parent
        color: "#303030"
        visible: loader.status !== Loader.Ready && pageData.items && pageData.items.length > 0

        Column {
            anchors {
                fill: parent
                margins: 15
            }

            // GridLayout контейнер
            GridLayoutContainer {
                id: gridLayout
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: parent.height

                layoutConfig: pageData.layout || {columns: 1, rows: 1}
                items: pageData.items || []
            }
        }
    }
}
