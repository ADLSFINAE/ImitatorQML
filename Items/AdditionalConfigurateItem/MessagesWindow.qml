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
    property var existingPages: []  // Существующие страницы в TabArea

    signal saved(var selectedItems)
    signal canceled()

    function initializeWithExistingPages(pages) {
        existingPages = pages || []
        console.log("Initializing with existing pages:", existingPages)
        updateCheckboxes()
    }

    function updateCheckboxes() {
        // Устанавливаем галочки для уже существующих страниц
        for (var i = 0; i < messagesModel.count; i++) {
            var messageName = messagesModel.get(i).name
            var isChecked = existingPages.indexOf(messageName) !== -1
            messagesModel.setProperty(i, "checked", isChecked)
        }
        console.log("Updated checkboxes for", existingPages.length, "existing pages")
    }

    function loadAvailablePages() {
        // Загружаем доступные страницы из UiModel
        if (typeof uiModel !== 'undefined') {
            var availablePages = uiModel.getAllAvailablePageNames()
            console.log("Loading available pages from UiModel:", availablePages)
            setMessages(availablePages)

            // Обновляем существующие страницы
            var currentPages = uiModel.getCurrentPageNames()
            console.log("Current pages in UiModel:", currentPages)
            initializeWithExistingPages(currentPages)
        } else {
            console.log("UiModel not available, using default pages")
            // Используем стандартный набор страниц
            var defaultPages = [
                "Страница 1 - ADJ", "Страница 2 - DBT", "Страница 3 - DPT",
                "Страница 4 - DTM", "Страница 5 - ELH", "Страница 6 - ERR"
            ]
            setMessages(defaultPages)
        }
    }

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
                    Layout.alignment: Qt.AlignHCenter
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
                            console.log("Saving selected pages:", selected)
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
                            console.log("Messages window canceled")
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
        console.log("Loaded", messages.length, "pages to messages window")
    }

    Component.onCompleted: {
        console.log("MessagesWindow component completed")
        loadAvailablePages()
    }

    onVisibleChanged: {
        if (visible) {
            // При каждом открытии окна обновляем список существующих страниц
            console.log("MessagesWindow became visible, refreshing data")
            if (typeof uiModel !== 'undefined') {
                var currentPages = uiModel.getCurrentPageNames()
                console.log("Refreshing with current pages:", currentPages)
                initializeWithExistingPages(currentPages)
            }
        }
    }
}
