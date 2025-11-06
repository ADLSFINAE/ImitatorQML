import QtQuick 2.12

Rectangle {
    id: tabDelegate
    height: 23
    width: pageText.contentWidth + 25
    color: "lightgray"
    radius: 3

    property string pageName: ""
    property int pageNumber: 1

    signal pageClicked()
    signal addClicked()
    signal deleteClicked()

    Text {
        id: pageText
        text: pageNumber > 1 ? pageName + " - " + pageNumber : pageName
        anchors.centerIn: parent
        font.pointSize: 8
    }

    MouseArea {
        anchors.fill: parent
        onClicked: tabDelegate.pageClicked()
    }

    // Кнопка добавления
    Rectangle {
        id: addButton
        width: 9
        height: 9
        color: "green"
        radius: 1
        anchors {
            right: parent.right
            rightMargin: 2
            top: parent.top
            topMargin: 2
        }

        Text {
            text: "+"
            anchors.centerIn: parent
            font.pointSize: 6
            color: "white"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: tabDelegate.addClicked()
        }
    }

    // Кнопка удаления
    Rectangle {
        id: deleteButton
        width: 9
        height: 9
        color: "red"
        radius: 1
        anchors {
            right: parent.right
            rightMargin: 2
            top: addButton.bottom
            topMargin: 2
        }

        Text {
            text: "-"
            anchors.centerIn: parent
            font.pointSize: 6
            color: "white"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: tabDelegate.deleteClicked()
        }
    }
}
