import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

Window {
    id: messagesDialog
    title: "Управление сообщениями"
    width: 500
    height: 600
    color: "#2D2D30"
    flags: Qt.Dialog
    modality: Qt.ApplicationModal

    signal messagesSelected(var selectedMessages)

    Rectangle {
        id: header
        width: parent.width
        height: 40
        color: "#007acc"

        Text {
            text: "Управление сообщениями"
            color: "white"
            font.pointSize: 12
            font.bold: true
            anchors.centerIn: parent
        }
    }

    ScrollView {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: buttonsRow.top
            margins: 10
        }

        ListView {
            id: messagesList
            model: nmeaMessagesModel
            spacing: 8

            delegate: Rectangle {
                width: messagesList.width - 20
                height: 30
                color: "transparent"

                CheckBox {
                    text: model.name
                    checked: model.isChecked

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pointSize: 10
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: parent.indicator.width + parent.spacing
                    }

                    onCheckedChanged: model.isChecked = checked
                }
            }
        }
    }

    Rectangle {
        id: buttonsRow
        width: parent.width
        height: 60
        color: "#252525"
        anchors.bottom: parent.bottom

        Row {
            anchors.centerIn: parent
            spacing: 20

            Button {
                text: "Сохранить"
                onClicked: saveSelection()
            }

            Button {
                text: "Отменить"
                onClicked: messagesDialog.close()
            }
        }

        CheckBox {
            id: selectAllCheckBox
            text: "Отметить все"
            width: 120
            height: 25

            contentItem: Text {
                text: selectAllCheckBox.text
                color: "white"
                font.pointSize: 9
                verticalAlignment: Text.AlignVCenter
                leftPadding: selectAllCheckBox.indicator.width + selectAllCheckBox.spacing
            }

            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }

            onCheckedChanged: {
                for (var i = 0; i < nmeaMessagesModel.count; i++) {
                    nmeaMessagesModel.setProperty(i, "isChecked", checked)
                }
            }
        }
    }

    ListModel {
        id: nmeaMessagesModel
        ListElement { name: "GGA"; isChecked: false }
        ListElement { name: "GLL"; isChecked: false }
        ListElement { name: "GSA"; isChecked: false }
        ListElement { name: "GSV"; isChecked: false }
        ListElement { name: "RMC"; isChecked: false }
        ListElement { name: "VTG"; isChecked: false }
        ListElement { name: "ZDA"; isChecked: false }
        ListElement { name: "DTM"; isChecked: false }
        ListElement { name: "GBS"; isChecked: false }
        ListElement { name: "GNS"; isChecked: false }
    }

    function saveSelection() {
        var selectedMessages = []
        for (var i = 0; i < nmeaMessagesModel.count; i++) {
            if (nmeaMessagesModel.get(i).isChecked) {
                selectedMessages.push(nmeaMessagesModel.get(i).name)
            }
        }
        messagesSelected(selectedMessages)
        close()
    }
}
