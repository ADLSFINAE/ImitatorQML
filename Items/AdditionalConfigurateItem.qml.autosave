import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

BaseItem {
    id: additionalConfigurateItem
    itemTitle: "Дополнительно"

    // Окно сообщений
    property var messagesWindow: null
    property var tabArea: null  // Ссылка на TabArea (старая логика)
    property var messagesItem: null  // Ссылка на MessageItem (новая логика)

    Row{
        Column{
            width: 160
            height: 70
            spacing: 3
            Row {
                spacing: -5
                layoutDirection: Qt.LeftToRight
                height: 20

                CheckBox {
                    indicator.width: 15
                    indicator.height: 15
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "dasdas 1"
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Row {
                spacing: -5
                layoutDirection: Qt.LeftToRight
                height: 20

                CheckBox {
                    indicator.width: 15
                    indicator.height: 15
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "dasdas 2"
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Row {
                spacing: -5
                layoutDirection: Qt.LeftToRight
                height: 20

                CheckBox {
                    indicator.width: 15
                    indicator.height: 15
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "dasdas 3"
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Column {
            width: 120
            height: 70
            anchors.verticalCenter: parent.verticalCenter

            Button {
                id: hammerButton
                width: 50
                height: 50
                background: Rectangle {
                    color: "transparent"
                }

                Image {
                    anchors.centerIn: parent
                    height: 50
                    width: 50
                    source: "qrc:/Images/hammer.png"
                }

                onClicked: {
                    console.log("Открываем окно сообщений")
                    openMessagesWindow()
                }
            }
            Text {
                text: "Виджетс"
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 10
            }
        }
    }

    // Функция открытия окна сообщений
    function openMessagesWindow() {
        if (!messagesWindow) {
            var component = Qt.createComponent("qrc:/Items/AdditionalConfigurateItem/MessagesWindow.qml")
            if (component.status === Component.Ready) {
                messagesWindow = component.createObject(additionalConfigurateItem)
                messagesWindow.saved.connect(onMessagesSaved)
                messagesWindow.canceled.connect(onMessagesCanceled)
            }
        }

        if (messagesWindow) {
            // Передаем текущие сообщения для синхронизации (НОВАЯ ЛОГИКА)
            var currentMessages = getCurrentMessagesFromMessageItem()
            messagesWindow.initializeWithExistingPages(currentMessages)
            messagesWindow.show()
        }
    }

    // Обработчики сигналов окна сообщений
    function onMessagesSaved(selectedItems) {
        console.log("Сохранены выбранные сообщения:", selectedItems)

        // НОВАЯ ЛОГИКА - добавляем в MessageItem
        syncMessagesWithMessageItem(selectedItems)

        // СТАРАЯ ЛОГИКА - добавляем в TabArea (оставляем для обратной совместимости)
        addPagesToTabArea(selectedItems)
    }

    function onMessagesCanceled() {
        console.log("Диалог сообщений отменен")
    }

    // ========== НОВАЯ ЛОГИКА - РАБОТА С MessageItem ==========

    // Функция для получения текущих сообщений из MessageItem
    function getCurrentMessagesFromMessageItem() {
        if (!messagesItem) {
            findMessageItem()
        }

        var currentMessages = []
        if (messagesItem && messagesItem.messagesModel) {
            for (var i = 0; i < messagesItem.messagesModel.count; i++) {
                currentMessages.push(messagesItem.messagesModel.get(i).text)
            }
        }
        return currentMessages
    }

    // Функция синхронизации сообщений с MessageItem
    function syncMessagesWithMessageItem(selectedItems) {
        if (!messagesItem) {
            findMessageItem()
        }

        if (messagesItem && messagesItem.messagesModel) {
            var selectedSet = new Set(selectedItems)

            // Удаляем сообщения, которых нет в выбранных
            for (var i = messagesItem.messagesModel.count - 1; i >= 0; i--) {
                var messageText = messagesItem.messagesModel.get(i).text
                if (!selectedSet.has(messageText)) {
                    console.log("Удаляем сообщение из MessageItem:", messageText)
                    messagesItem.messagesModel.remove(i)
                }
            }

            // Добавляем новые выбранные сообщения
            for (var j = 0; j < selectedItems.length; j++) {
                var newMessageText = selectedItems[j]
                var exists = false

                // Проверяем, есть ли уже такое сообщение
                for (var k = 0; k < messagesItem.messagesModel.count; k++) {
                    if (messagesItem.messagesModel.get(k).text === newMessageText) {
                        exists = true
                        break
                    }
                }

                if (!exists) {
                    console.log("Добавляем сообщение в MessageItem:", newMessageText)
                    messagesItem.messagesModel.append({
                        "text": newMessageText,
                        "checked": true
                    })
                }
            }
        } else {
            console.log("MessageItem не найден или недоступен")
        }
    }

    // Функция поиска MessageItem
    function findMessageItem() {
        var parentItem = parent
        while (parentItem) {
            if (parentItem.objectName === "messagesItem" || parentItem.hasOwnProperty("messagesModel")) {
                messagesItem = parentItem
                console.log("MessageItem найден")
                break
            }
            parentItem = parentItem.parent
        }

        // Альтернативный поиск по id
        if (!messagesItem) {
            var root = parent
            while (root && root.parent) {
                root = root.parent
            }
            messagesItem = findChild(root, "messagesItem")
        }
    }

    // ========== СТАРАЯ ЛОГИКА - РАБОТА С TabArea ==========

    // Функция для добавления страниц в TabArea (СТАРАЯ ЛОГИКА)
    function addPagesToTabArea(selectedItems) {
        if (!tabArea) {
            findTabArea()
        }

        if (tabArea && tabArea.pagesModel) {
            // Добавляем каждое выбранное сообщение как новую страницу
            for (var i = 0; i < selectedItems.length; i++) {
                var pageName = selectedItems[i]

                // Проверяем, нет ли уже такой страницы
                var exists = false
                for (var j = 0; j < tabArea.pagesModel.count; j++) {
                    if (tabArea.pagesModel.get(j).pageName === pageName) {
                        exists = true
                        break
                    }
                }

                if (!exists) {
                    tabArea.pagesModel.append({
                        "pageName": pageName,
                        "pageNumber": 1
                    })
                    console.log("Добавлена страница в TabArea:", pageName)
                }
            }
        } else {
            console.log("TabArea не найден или недоступен")
        }
    }

    // Функция поиска TabArea (СТАРАЯ ЛОГИКА)
    function findTabArea() {
        var parentItem = parent
        while (parentItem) {
            if (parentItem.objectName === "tabArea" || parentItem.hasOwnProperty("pagesModel")) {
                tabArea = parentItem
                console.log("TabArea найден")
                break
            }
            parentItem = parentItem.parent
        }

        // Альтернативный поиск по id
        if (!tabArea) {
            var root = parent
            while (root && root.parent) {
                root = root.parent
            }
            tabArea = findChild(root, "tabArea")
        }
    }

    // Вспомогательная функция для поиска дочерних элементов
    function findChild(item, objectName) {
        if (item.objectName === objectName) {
            return item
        }

        for (var i = 0; i < item.children.length; i++) {
            var child = item.children[i]
            var result = findChild(child, objectName)
            if (result) {
                return result
            }
        }

        return null
    }

    // Инициализация при создании компонента
    Component.onCompleted: {
        findTabArea()    // Старая логика
        findMessageItem() // Новая логика
    }
}

