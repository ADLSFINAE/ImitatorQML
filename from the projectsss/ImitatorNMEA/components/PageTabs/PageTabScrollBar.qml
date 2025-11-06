import QtQuick 2.12

Rectangle {
    id: scrollBar
    height: 5
    color: "#404040"
    radius: 3
    visible: listView.contentWidth > listView.width

    property ListView listView

    Rectangle {
        height: parent.height
        width: (listView.width / listView.contentWidth) * parent.width
        color: "#808080"
        radius: 3
        x: (listView.contentX / listView.contentWidth) * parent.width

        Behavior on x {
            NumberAnimation { duration: 100 }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            var clickPos = mouseX / parent.width
            listView.contentX = clickPos * (listView.contentWidth - listView.width)
        }
    }
}
