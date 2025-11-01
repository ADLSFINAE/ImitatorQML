import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

BaseItem {
    id: additionalConfigurateItem
    itemTitle: "Дополнительно"

    // Ссылка на MessagesItem (можно передать через mainWindow или найти по id)
    property var messagesItem: null

    Column {
        anchors.centerIn: parent
        spacing: 10

        Button {
            id: addSquareButton
            text: "Добавить квадрат"
            onClicked: {
                console.log("Добавляем квадрат в MessagesItem")
                if (messagesItem) {
                    messagesItem.addSquare()
                } else {
                    console.log("MessagesItem не установлен")
                }
            }
        }

        Button {
            text: "Очистить все"
            onClicked: {
                if (messagesItem) {
                    messagesItem.clearSquares()
                }
            }
        }

        Text {
            text: messagesItem ? "Квадратов: " + messagesItem.squareCount : "Не подключено"
            color: "white"
        }
    }

    // Инициализация после загрузки компонента
    Component.onCompleted: {
        // Находим MessagesItem (нужно будет настроить в зависимости от вашей структуры)
        findMessagesItem()
    }

    function findMessagesItem() {
        // Ищем MessagesItem в родительских элементах
        var parentItem = parent
        while (parentItem) {
            if (parentItem.hasOwnProperty("messages")) {
                messagesItem = parentItem.messages
                break
            }
            parentItem = parentItem.parent
        }

        // Альтернативный способ - через mainWindow если он есть
        if (!messagesItem && typeof mainWindow !== "undefined" && mainWindow) {
            // Предполагаем, что в mainWindow есть ссылка на messagesItem
        }
    }
}
