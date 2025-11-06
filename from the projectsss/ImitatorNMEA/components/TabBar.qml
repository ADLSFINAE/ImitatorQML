import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: tabBar
    height: 35

    property string currentTab: "Главная"

    TabView {
        id: tabView
        anchors.fill: parent

        Tab {
            title: "Главная"
            active: true
            source: "qrc:/pages/MainTab.qml"
        }

        style: TabViewStyle {
            frameOverlap: 1
            tab: Rectangle {
                color: styleData.selected ? "#2D2D30" : "black"
                implicitWidth: 120
                implicitHeight: 25

                Text {
                    anchors.centerIn: parent
                    text: styleData.title
                    color: "white"
                    font.pointSize: 13
                }
            }

            frame: Rectangle {
                color: "#2D2D30"
            }
        }
    }
}
