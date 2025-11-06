import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

BaseItem {
    id: additionalConfigurateItem
    itemTitle: "Дополнительно"
    objectName: "additionalConfigurateItem"

    // Окно сообщений
    property var messagesWindow: null
    property var tabArea: null
    property var messagesItem: null

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
            var currentMessages = getCurrentMessagesFromMessageItem()
            messagesWindow.initializeWithExistingPages(currentMessages)
            messagesWindow.show()
        }
    }

    // Обработчики сигналов окна сообщений
    function onMessagesSaved(selectedItems) {
        console.log("Сохранены выбранные сообщения:", selectedItems)
        syncMessagesWithMessageItem(selectedItems)
        syncPagesWithTabArea(selectedItems)
    }

    function onMessagesCanceled() {
        console.log("Диалог сообщений отменен")
    }

    // ========== ФУНКЦИИ ДЛЯ MessageItem ==========

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

    // ========== ФУНКЦИИ ДЛЯ TabArea ==========

    // Функция синхронизации страниц с TabArea
    function syncPagesWithTabArea(selectedItems) {
        if (!tabArea) {
            findTabArea()
        }

        if (tabArea && tabArea.pagesModel) {
            var selectedSet = new Set(selectedItems)

            // Удаляем страницы, которых нет в выбранных
            for (var i = tabArea.pagesModel.count - 1; i >= 0; i--) {
                var pageName = tabArea.pagesModel.get(i).pageName
                if (!selectedSet.has(pageName)) {
                    console.log("Удаляем страницу из TabArea:", pageName)
                    tabArea.pagesModel.remove(i)
                }
            }

            // Добавляем новые выбранные страницы
            for (var j = 0; j < selectedItems.length; j++) {
                var newPageName = selectedItems[j]
                var exists = false

                for (var k = 0; k < tabArea.pagesModel.count; k++) {
                    if (tabArea.pagesModel.get(k).pageName === newPageName) {
                        exists = true
                        break
                    }
                }

                if (!exists) {
                    console.log("Добавляем страницу в TabArea:", newPageName)
                    tabArea.pagesModel.append({
                        "pageName": newPageName,
                        "pageNumber": 1
                    })
                }
            }
        } else {
            console.log("TabArea не найден или недоступен")
        }
    }

    // Функция удаления страницы из TabArea
    function removePageFromTabArea(pageName) {
        if (!tabArea) {
            findTabArea()
        }

        if (tabArea && tabArea.pagesModel) {
            for (var i = 0; i < tabArea.pagesModel.count; i++) {
                if (tabArea.pagesModel.get(i).pageName === pageName) {
                    console.log("Удаляем страницу из TabArea:", pageName)
                    tabArea.pagesModel.remove(i)
                    break
                }
            }
        }
    }

    // Функция добавления страницы в TabArea
    function addPageToTabArea(pageName) {
        if (!tabArea) {
            findTabArea()
        }

        if (tabArea && tabArea.pagesModel) {
            var exists = false
            for (var i = 0; i < tabArea.pagesModel.count; i++) {
                if (tabArea.pagesModel.get(i).pageName === pageName) {
                    exists = true
                    break
                }
            }

            if (!exists) {
                console.log("Добавляем страницу в TabArea:", pageName)
                tabArea.pagesModel.append({
                    "pageName": pageName,
                    "pageNumber": 1
                })
            }
        }
    }

    // ========== ОБРАБОТЧИКИ СИГНАЛОВ ==========

    // НОВАЯ ФУНКЦИЯ: Обработка снятия галочки в MessageItem
    function onMessageToggled(messageText, checked) {
        console.log("Сообщение переключено:", messageText, checked)

        if (!checked) {
            // Если сняли галочку - удаляем из TabArea
            removePageFromTabArea(messageText)

            // Обновляем состояние в MessagesWindow (если открыто)
            if (messagesWindow) {
                updateMessagesWindowState(messageText, false)
            }
        } else {
            // Если поставили галочку - добавляем в TabArea
            addPageToTabArea(messageText)

            // Обновляем состояние в MessagesWindow (если открыто)
            if (messagesWindow) {
                updateMessagesWindowState(messageText, true)
            }
        }
    }

    // Функция обновления состояния в MessagesWindow
    function updateMessagesWindowState(messageText, checked) {
        if (messagesWindow && messagesWindow.messagesModel) {
            for (var i = 0; i < messagesWindow.messagesModel.count; i++) {
                if (messagesWindow.messagesModel.get(i).name === messageText) {
                    messagesWindow.messagesModel.setProperty(i, "checked", checked)
                    break
                }
            }
        }
    }

    // ========== ФУНКЦИИ ПОИСКА КОМПОНЕНТОВ ==========

    // Функция поиска MessageItem
    function findMessageItem() {
        var parentItem = parent
        while (parentItem) {
            if (parentItem.objectName === "messagesItem" || parentItem.hasOwnProperty("messagesModel")) {
                messagesItem = parentItem
                console.log("MessageItem найден")
                // Подключаем обработчик сигнала
                messagesItem.messageToggled.connect(onMessageToggled)
                break
            }
            parentItem = parentItem.parent
        }

        if (!messagesItem) {
            var root = parent
            while (root && root.parent) {
                root = root.parent
            }
            messagesItem = findChild(root, "messagesItem")
            if (messagesItem) {
                messagesItem.messageToggled.connect(onMessageToggled)
            }
        }
    }

    // Функция поиска TabArea
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
        findTabArea()
        findMessageItem()
    }
}
