import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

BaseItem {
    id: additionalConfigurateItem
    itemTitle: "Дополнительно"

    // Окно сообщений
    property var messagesWindow: null
    property var tabArea: null
    property var messagesItem: null

    // Свойства для чекбоксов
    property bool checksumEnabled: false
    property bool crEnabled: false
    property bool lfEnabled: false
    property bool syncEnabled: false

    Row{
        Column{
            width: 160
            height: 70
            spacing: 3
            Row {
                spacing: -5
                layoutDirection: Qt.LeftToRight
                height: 15

                CheckBox {
                    id: checksumCheckBox
                    indicator.width: 15
                    indicator.height: 15
                    anchors.verticalCenter: parent.verticalCenter
                    checked: additionalConfigurateItem.checksumEnabled
                    onCheckedChanged: {
                        additionalConfigurateItem.checksumEnabled = checked
                        console.log("Контрольная сумма:", checked ? "включена" : "выключена")
                    }
                }

                Text {
                    text: "Контрольная сумма"
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Row {
                spacing: -5
                layoutDirection: Qt.LeftToRight
                height: 15

                CheckBox {
                    id: crCheckBox
                    indicator.width: 15
                    indicator.height: 15
                    anchors.verticalCenter: parent.verticalCenter
                    checked: additionalConfigurateItem.crEnabled
                    onCheckedChanged: {
                        additionalConfigurateItem.crEnabled = checked
                        console.log("CR:", checked ? "включен" : "выключен")
                    }
                }

                Text {
                    text: "CR"
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Row {
                spacing: -5
                layoutDirection: Qt.LeftToRight
                height: 15

                CheckBox {
                    id: lfCheckBox
                    indicator.width: 15
                    indicator.height: 15
                    anchors.verticalCenter: parent.verticalCenter
                    checked: additionalConfigurateItem.lfEnabled
                    onCheckedChanged: {
                        additionalConfigurateItem.lfEnabled = checked
                        console.log("LF:", checked ? "включен" : "выключен")
                        backend.shitten()
                    }
                }

                Text {
                    text: "LF"
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Row {
                spacing: -5
                layoutDirection: Qt.LeftToRight
                height: 15

                CheckBox {
                    id: syncCheckBox
                    indicator.width: 15
                    indicator.height: 15
                    anchors.verticalCenter: parent.verticalCenter
                    checked: additionalConfigurateItem.syncEnabled
                    onCheckedChanged: {
                        additionalConfigurateItem.syncEnabled = checked
                        console.log("Синхронизация параметров:", checked ? "включена" : "выключена")
                    }
                }

                Text {
                    text: "Синхронизация параметров"
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

    // Функция для модификации данных перед отправкой
    function processDataBeforeSending(data) {
        var processedData = data

        // Удаляем возможные завершающие символы CR/LF если они уже есть
        processedData = processedData.replace(/\r\n$/, '')
        processedData = processedData.replace(/\r$/, '')
        processedData = processedData.replace(/\n$/, '')

        // Добавляем контрольную сумму если включена
        if (checksumEnabled) {
            processedData = addChecksum(processedData)
        }

        // Добавляем CR если включен
        if (crEnabled) {
            processedData += '\r'
        }

        // Добавляем LF если включен
        if (lfEnabled) {
            processedData += '\n'
        }

        console.log("Данные после обработки:", JSON.stringify(processedData))
        return processedData
    }

    // Функция для расчета контрольной суммы NMEA
    function addChecksum(data) {
        // Для NMEA сообщений контрольная сумма рассчитывается как XOR всех байт между $ и *
        var checksum = 0
        var startIndex = data.indexOf('$')
        var endIndex = data.indexOf('*')

        if (startIndex !== -1 && endIndex === -1) {
            // Если нет существующей контрольной суммы, рассчитываем
            for (var i = startIndex + 1; i < data.length; i++) {
                var charCode = data.charCodeAt(i)
                checksum ^= charCode
            }

            // Добавляем контрольную сумму в формате *XX
            data += '*' + checksum.toString(16).toUpperCase().padStart(2, '0')
        }

        return data
    }

    // Остальные функции остаются без изменений
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

    function onMessagesSaved(selectedItems) {
        console.log("Сохранены выбранные сообщения:", selectedItems)
        syncMessagesWithMessageItem(selectedItems)
        addPagesToTabArea(selectedItems)
    }

    function onMessagesCanceled() {
        console.log("Диалог сообщений отменен")
    }

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

    function syncMessagesWithMessageItem(selectedItems) {
        if (!messagesItem) {
            findMessageItem()
        }

        if (messagesItem && messagesItem.messagesModel) {
            var selectedSet = new Set(selectedItems)

            for (var i = messagesItem.messagesModel.count - 1; i >= 0; i--) {
                var messageText = messagesItem.messagesModel.get(i).text
                if (!selectedSet.has(messageText)) {
                    console.log("Удаляем сообщение из MessageItem:", messageText)
                    messagesItem.messagesModel.remove(i)
                }
            }

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

        if (!messagesItem) {
            var root = parent
            while (root && root.parent) {
                root = root.parent
            }
            messagesItem = findChild(root, "messagesItem")
        }
    }

    function addPagesToTabArea(selectedItems) {
        if (!tabArea) {
            findTabArea()
        }

        if (tabArea && tabArea.pagesModel) {
            for (var i = 0; i < selectedItems.length; i++) {
                var pageName = selectedItems[i]

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

    Component.onCompleted: {
        findTabArea()
        findMessageItem()
    }
}
