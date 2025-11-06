import QtQuick 2.12
import QtQuick.Controls 2.12

BaseItem {
    id: timeDateItem
    itemTitle: "Время"

    // Специфичный для портов контент
    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "Время"
            color: "white"
            font.pointSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Здесь будет функционал выбора порта, скорости и т.д.
    }
}
