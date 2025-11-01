import QtQuick 2.12
import QtQuick.Controls 2.12

BaseItem {
    id: portItem
    itemTitle: "Порты"

    // Специфичный для портов контент
    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "COM Port Settings"
            color: "white"
            font.pointSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Здесь будет функционал выбора порта, скорости и т.д.
    }
}
