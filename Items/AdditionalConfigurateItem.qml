import QtQuick 2.12
import QtQuick.Controls 2.12

BaseItem {
    id: additionalConfigurateItem
    itemTitle: "Дополнительно"

    // Специфичный для дополнительных настроек контент
    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "Доп. настройки"
            color: "white"
            font.pointSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Здесь будут дополнительные настройки
    }
}


