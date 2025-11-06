import QtQuick 2.12

Rectangle {
    id: statusBar
    height: 26
    width: parent.width
    color: "#008000"

    Text {
        id: leftText
        text: "Выходное сообщение: "
        color: "white"
        anchors {
            left: parent.left
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }
    }

    Text {
        id: rightText
        text: "Символов: "
        color: "white"
        anchors {
            right: parent.right
            rightMargin: 5
            verticalCenter: parent.verticalCenter
        }
    }
}
