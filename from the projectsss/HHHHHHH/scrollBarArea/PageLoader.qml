import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: pageLoader
    color: "transparent"

    property string source: ""
    property color pageColor: "blue"  // Свойство для цвета

    // Основной Loader для загрузки QML страниц
    Loader {
        id: loader
        anchors.fill: parent
        source: parent.source
    }

    // Цветной прямоугольник
    Rectangle {
        id: colorRect
        anchors.fill: parent
        color: pageColor
        opacity: 0.3  // Немного прозрачности чтобы видеть содержимое

    }

    // Текст с номером страницы (опционально)
    Text {
        text: "abcdefg"
        color: "white"
        font.pointSize: 16
        font.bold: true
        anchors.centerIn: parent
    }
}
