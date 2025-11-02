import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

BaseItem {
    id: additionalConfigurateItem
    itemTitle: "Дополнительно"

    // Окно сообщений
    property var messagesWindow: null
    property var tabArea: null  // Ссылка на TabArea

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
            // Передаем текущие страницы в окно для синхронизации
            var currentPages = getCurrentPagesFromTabArea()
            messagesWindow.initializeWithExistingPages(currentPages)
            messagesWindow.show()
        }
    }

    // Обработчики сигналов окна сообщений
    function onMessagesSaved(selectedItems) {
        console.log("Сохранены выбранные сообщения:", selectedItems)
        syncPagesWithTabArea(selectedItems)
    }

    function onMessagesCanceled() {
        console.log("Диалог сообщений отменен")
    }

    // Функция для получения текущих страниц из TabArea
    function getCurrentPagesFromTabArea() {
        if (!tabArea) {
            findTabArea()
        }

        var currentPages = []
        if (tabArea && tabArea.pagesModel) {
            for (var i = 0; i < tabArea.pagesModel.count; i++) {
                currentPages.push(tabArea.pagesModel.get(i).pageName)
            }
        }
        return currentPages
    }

    // Функция синхронизации страниц с TabArea
    function syncPagesWithTabArea(selectedItems) {
        if (!tabArea) {
            findTabArea()
        }

        if (tabArea && tabArea.pagesModel) {
            var selectedSet = new Set(selectedItems)
            var currentPages = getCurrentPagesFromTabArea()

            // Удаляем страницы, которых нет в выбранных
            for (var i = tabArea.pagesModel.count - 1; i >= 0; i--) {
                var pageName = tabArea.pagesModel.get(i).pageName
                if (!selectedSet.has(pageName)) {
                    console.log("Удаляем страницу:", pageName)
                    tabArea.pagesModel.remove(i)
                }
            }

            // Добавляем новые выбранные страницы
            for (var j = 0; j < selectedItems.length; j++) {
                var newPageName = selectedItems[j]
                var exists = false

                // Проверяем, есть ли уже такая страница
                for (var k = 0; k < tabArea.pagesModel.count; k++) {
                    if (tabArea.pagesModel.get(k).pageName === newPageName) {
                        exists = true
                        break
                    }
                }

                if (!exists) {
                    console.log("Добавляем страницу:", newPageName)
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
        findTabArea()
    }
}
