import QtQuick 2.12
import QtQuick.Controls 2.12

BaseItem {
    id: configurateItem
    itemTitle: "Конфигурация"

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "Настройки"
            color: "white"
            font.pointSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }


    }
}
