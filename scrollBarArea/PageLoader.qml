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
    property bool someBoolProperty: false // или удалите проблемное свойство

    // Основной Loader для загрузки QML страниц (старая логика)
    Loader {
        id: loader
        anchors.fill: parent
        source: parent.source
    }

    // НОВАЯ ЛОГИКА - отображение JSON данных с GridLayout
    Rectangle {
        id: jsonContent
        anchors.fill: parent
        color: "transparent"
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

    // Сообщение когда нет данных (новая логика)
    Text {
        text: "Нет данных для отображения"
        color: "gray"
        font.pointSize: 12
        anchors.centerIn: parent
        visible: loader.status !== Loader.Ready && (!pageData.items || pageData.items.length === 0)
    }
}
