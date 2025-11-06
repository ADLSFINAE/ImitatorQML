import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: pageButton
    height: 23
    color: "lightgray"
    radius: 3

    property string pageName: ""
    property int pageNumber: 1

    // Сигналы
    signal clicked()
    signal addPage()
    signal deletePage()

    width: pageText.contentWidth + 25

    MouseArea {
        anchors.fill: parent
        onClicked: {
            pageButton.clicked()
        }
    }

    Text {
        id: pageText
        text: pageNumber > 1 ? pageName + " - " + pageNumber : pageName
        anchors.centerIn: parent
        font.pointSize: 8

        TextMetrics {
            id: textMetrics
            font: pageText.font
            text: pageText.text
        }
    }

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
            onClicked: {
                pageButton.addPage()
            }
        }
    }

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
            onClicked: {
                pageButton.deletePage()
            }
        }
    }
}
