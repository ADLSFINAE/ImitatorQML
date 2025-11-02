import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12

Window {
    id: messagesWindow
    title: "Сообщения"
    width: 400
    height: 500
    modality: Qt.ApplicationModal

    property var selectedMessages: []

    signal saved(var selectedItems)
    signal canceled()

    Rectangle {
        anchors.fill: parent
        color: "#2b2b2b"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            // Синяя полоска с надписью "выбор"
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "darkblue"

                Text {
                    anchors.centerIn: parent
                    text: "ВЫБОР"
                    color: "white"
                    font.bold: true
                    font.pointSize: 12
                }
            }

            // Прокручиваемая область с чекбоксами
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: messagesList
                    model: ListModel {
                        id: messagesModel
                        ListElement { name: "Сообщение 1"; checked: false }
                        ListElement { name: "Сообщение 2"; checked: false }
                        ListElement { name: "Сообщение 3"; checked: false }
                        ListElement { name: "Сообщение 4"; checked: false }
                        ListElement { name: "Сообщение 5"; checked: false }
                        ListElement { name: "Сообщение 6"; checked: false }
                        ListElement { name: "Сообщение 7"; checked: false }
                        ListElement { name: "Сообщение 8"; checked: false }
                    }

                    delegate: Rectangle {
                        width: messagesList.width
                        height: 30
                        color: "transparent"

                        Row {
                            spacing: 10
                            anchors.verticalCenter: parent.verticalCenter

                            CheckBox {
                                checked: model.checked
                                onCheckedChanged: {
                                    messagesModel.setProperty(index, "checked", checked)
                                }
                            }

                            Text {
                                text: model.name
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                                font.pointSize: 10
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                height: 40

                // Кнопки по центру
                Row {
                    //Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Button {
                        text: "Сохранить"
                        width: 100
                        height: 30

                        onClicked: {
                            var selected = []
                            for (var i = 0; i < messagesModel.count; i++) {
                                if (messagesModel.get(i).checked) {
                                    selected.push(messagesModel.get(i).name)
                                }
                            }
                            messagesWindow.selectedMessages = selected
                            messagesWindow.saved(selected)
                            messagesWindow.close()
                        }
                    }

                    Button {
                        text: "Отменить"
                        width: 100
                        height: 30

                        onClicked: {
                            messagesWindow.canceled()
                            messagesWindow.close()
                        }
                    }
                }

                // Чекбокс "Отметить все" в правом нижнем углу
                Row {
                    Layout.alignment: Qt.AlignRight
                    spacing: 5

                    CheckBox {
                        id: selectAllCheckbox
                        anchors.verticalCenter: parent.verticalCenter

                        onCheckedChanged: {
                            for (var i = 0; i < messagesModel.count; i++) {
                                messagesModel.setProperty(i, "checked", selectAllCheckbox.checked)
                            }
                        }
                    }

                    Text {
                        text: "Отметить все"
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 9
                    }
                }
            }
        }
    }

    function setMessages(messages) {
        messagesModel.clear()
        for (var i = 0; i < messages.length; i++) {
            messagesModel.append({"name": messages[i], "checked": false})
        }
    }
}
