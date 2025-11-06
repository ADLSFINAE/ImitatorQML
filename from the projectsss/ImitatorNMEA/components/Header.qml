import QtQuick 2.12

Item {
    id: header
    height: 40

    property string title: ""

    Text {
        text: title
        color: "white"
        font.pointSize: 16
        anchors {
            top: parent.top
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
    }
}
