import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: scrollBar
    height: 5
    color: "#404040"
    radius: 3
    
    property ListView listView: null
    
    visible: listView && listView.contentWidth > listView.width

    Rectangle {
        id: scrollBarHandle
        height: parent.height
        width: listView ? (listView.width / listView.contentWidth) * parent.width : 0
        color: "#808080"
        radius: 3
        x: listView ? (listView.contentX / listView.contentWidth) * parent.width : 0

        Behavior on x {
            NumberAnimation { duration: 100 }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (listView) {
                var clickPos = mouseX / parent.width
                listView.contentX = clickPos * (listView.contentWidth - listView.width)
            }
        }
    }
}
