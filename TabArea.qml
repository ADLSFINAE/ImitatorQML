import QtQuick 2.12
import QtQuick.Controls 2.12
import "scrollBarArea"

Rectangle {
    id: tabArea
    color: "#2D2D30"

    // Свойства для настройки
    property alias pagesModel: buttonListView.model
    property alias currentPageSource: pageLoader.source

    // Свойство для хранения цвета
    property color currentPageColor: "blue"

    // Компоненты
    PagesListView {
        id: buttonListView
        anchors {
            top: parent.top
            topMargin: 8
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
        }

        onPageClicked: function(index) {
            pageLoader.source = getPageSource(index)

            // Меняем цвет в зависимости от страницы
            var colors = ["blue", "green", "red", "purple", "orange", "teal"]
            currentPageColor = colors[index % colors.length]
        }
    }

    PagesScrollBar {
        listView: buttonListView
        anchors {
            left: buttonListView.left
            right: buttonListView.right
            top: buttonListView.bottom
            topMargin: 1
        }
    }

    BlueStrip {
        id: blueStrip
        anchors {
            left: parent.left
            right: parent.right
            top: buttonListView.bottom
            topMargin: 6
            leftMargin: 25
            rightMargin: 25
        }
    }

    PageLoader {
        id: pageLoader
        anchors {
            top: blueStrip.bottom
            topMargin: 12
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
            bottom: parent.bottom
            bottomMargin: 10
        }

        // Передаем текущий цвет в PageLoader
        pageColor: tabArea.currentPageColor
    }

    // Функция для получения источника страницы
    function getPageSource(index) {
        var pageNames = ["Page1", "Page2", "Page3", "Page4"];
        if (index >= 0 && index < pageNames.length) {
            return "qrc:/Pages/" + pageNames[index] + ".qml";
        }
        return "qrc:/Pages/Page1.qml";
    }
}
