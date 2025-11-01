import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: baseItem
    color: "#252525"
    border.color: "#404040"
    border.width: 1
    radius: 3

    // Свойство для заголовка - можно изменять
    property string itemTitle: "Заголовок"

    // Свойство для цвета заголовка
    property color titleColor: "white"

    // Свойство для размера шрифта заголовка
    property int titleFontSize: 10

    // Основной контент - будет переопределяться в наследниках
    property alias content: contentContainer.children

    Column {
        anchors.fill: parent
        anchors.margins: 5

        // Основной контент
        Item {
            id: contentContainer
            width: parent.width
            height: parent.height - 25 // Оставляем место для заголовка
        }

        // Заголовок внизу по центру
        Text {
            id: titleText
            text: itemTitle
            color: titleColor
            font.pointSize: titleFontSize
            anchors.horizontalCenter: parent.horizontalCenter
            height: 20
            verticalAlignment: Text.AlignVCenter
        }
    }
}
