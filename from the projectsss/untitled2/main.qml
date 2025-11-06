import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4

Window {
    id: mainWindow
    visible: true

    width: 1440
    height: 760
    color: "#202020"

    Text {
        id: topCenterText
        text: "Имитатор NMEA 0183"
        color: "white"
        font.pointSize: 16
        anchors {
            top: parent.top
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
    }

    TabView {
        id: tabWidget
        anchors {
            top: topCenterText.bottom
            topMargin: 10
            left: parent.left
            right: parent.right
        }

        Tab {
            id: mainTab
            title: "Главная"
            active: true
            Row {
                anchors.fill: parent
                spacing: 7
                anchors.topMargin: 3
                anchors.bottomMargin: 3
                anchors.leftMargin: 5
                anchors.rightMargin: 5

                Rectangle {
                    id: portItem
                    height: parent.height
                    width: 356
                    color: "white"
                }

                Rectangle {
                    id: configurate
                    height: parent.height
                    width: 330
                    color: "white"
                }

                Rectangle {
                    id: messages
                    height: parent.height
                    width: 164
                    color: "white"
                }

                Rectangle {
                    id: additionalConfigurate
                    height: parent.height
                    width: 280
                    color: "white"

                }

                Rectangle {
                    id: timeDateItem
                    height: parent.height
                    width: 100
                    color: "white"
                }
            }
        }

        style: TabViewStyle {
            frameOverlap: 1
            tab: Rectangle {
                color: styleData.selected ? "#2D2D30" : "black"
                implicitWidth: 120
                implicitHeight: 25

                Text {
                    id: textTab
                    anchors.centerIn: parent
                    text: styleData.title
                    color: "white"
                    font.pointSize: 13
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            frame: Rectangle {
                color: "#2D2D30"
            }
        }
    }

    Rectangle {
        id: downIndicator
        height: 26
        color: "#008000"
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        Text {
            id: downIndicatorLeftText
            text: "Выходное сообщение: "
            color: "white"
            anchors {
                left: parent.left
                leftMargin: 5
                verticalCenter: parent.verticalCenter
            }
        }

        Text {
            id: downIndicatorRightText
            text:"Символов: "
            color: "white"
            anchors {
                right: parent.right
                rightMargin: 5
                verticalCenter: parent.verticalCenter
            }
        }
    }
}
