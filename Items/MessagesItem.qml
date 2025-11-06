import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

BaseItem {
    id: messagesItem
    itemTitle: "Сообщения"
    objectName: "messagesItem"

    // Модель для хранения сообщений
    property alias messagesModel: messagesListModel
    property var additionalConfigurateItem: null  // Ссылка на AdditionalConfigurateItem

    // Сигнал при изменении состояния чекбокса
    signal messageToggled(string messageText, bool checked)

    // Прокручиваемая область с сообщениями
    ScrollView {
        width: messagesItem.width
        height: 70
        clip: true

        ListView {
            id: messagesListView
            model: ListModel {
                id: messagesListModel
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
                            // Отправляем сигнал о изменении состояния
                            messagesItem.messageToggled(model.text, checked)
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

    // Функция для добавления сообщения
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

    // Инициализация связи с AdditionalConfigurateItem
    Component.onCompleted: {
        findAdditionalConfigurateItem()
    }

    function findAdditionalConfigurateItem() {
        var parentItem = parent
        while (parentItem) {
            if (parentItem.objectName === "additionalConfigurateItem" || parentItem.hasOwnProperty("messagesWindow")) {
                additionalConfigurateItem = parentItem
                console.log("AdditionalConfigurateItem найден для MessageItem")
                break
            }
            parentItem = parentItem.parent
        }
    }
}

