import QtQuick 2.12
import QtQuick.Controls 2.12

BaseItem {
    id: messagesItem
    itemTitle: "Сообщения"

    // Специфичный для сообщений контент
    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "NMEA Messages"
            color: "white"
            font.pointSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Здесь будут элементы управления сообщениями
    }
}
