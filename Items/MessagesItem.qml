import QtQuick 2.12
import QtQuick.Controls 2.12

BaseItem {
    id: messagesItem
    itemTitle: "Сообщения"
    objectName: "messagesItem"  // Для поиска

    // Модель для хранения сообщений
    property alias messagesModel: messagesListModel

    // Прокручиваемая область с сообщениями
    ScrollView {
        anchors.fill: parent
        clip: true

        ListView {
            id: messagesListView
            model: ListModel {
                id: messagesListModel
                // Начальные сообщения (можно оставить пустым)
                // ListElement { text: "Пример сообщения"; checked: true }
            }

            delegate: Rectangle {
                width: messagesListView.width
                height: 25
                color: "transparent"
                anchors.margins: 3

                Row {
                    CheckBox {
                        checked: model.checked
                        indicator.width: 10
                        indicator.height: 10
                        onCheckedChanged: {
                            messagesListModel.setProperty(index, "checked", checked)
                        }
                    }

                    Text {
                        text: model.text
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 10
                    }
                }
            }
        }
    }

    // Функция для добавления сообщения (можно вызывать извне)
    function addMessage(text) {
        messagesListModel.append({
            "text": text,
            "checked": true
        })
    }

    // Функция для удаления сообщения
    function removeMessage(text) {
        for (var i = 0; i < messagesListModel.count; i++) {
            if (messagesListModel.get(i).text === text) {
                messagesListModel.remove(i)
                break
            }
        }
    }

    // Функция для получения всех сообщений
    function getAllMessages() {
        var messages = []
        for (var i = 0; i < messagesListModel.count; i++) {
            messages.push(messagesListModel.get(i).text)
        }
        return messages
    }

    // Функция для получения выбранных сообщений
    function getSelectedMessages() {
        var selected = []
        for (var i = 0; i < messagesListModel.count; i++) {
            if (messagesListModel.get(i).checked) {
                selected.push(messagesListModel.get(i).text)
            }
        }
        return selected
    }
}

