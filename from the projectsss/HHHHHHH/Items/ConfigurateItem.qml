import QtQuick 2.12
import QtQuick.Controls 2.12

BaseItem {
    id: configurateItem
    itemTitle: "Конфигурация"

    // Специфичный для конфигурации контент
    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "Основные настройки"
            color: "white"
            font.pointSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Здесь будут элементы конфигурации
    }
}
