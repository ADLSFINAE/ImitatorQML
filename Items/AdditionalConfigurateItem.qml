import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

BaseItem {
    id: additionalConfigurateItem
    itemTitle: "Дополнительно"

    // Ссылка на MessagesItem (можно передать через mainWindow или найти по id)
    property var messagesItem: null

    Row {

        // Первый столбец - 3 чекбокса
        Column {
            width: 100  // Уменьшил ширину столбца

            CheckBox {
                width: parent.width
                text: "Опция 1"
                checked: true
                font.pointSize: 8
                indicator.width: 12  // Маленький квадратик
                indicator.height: 12
            }
            CheckBox {
                width: parent.width
                text: "Опция 2"
                checked: false
                font.pointSize: 8
                indicator.width: 12
                indicator.height: 12
            }
            CheckBox {
                width: parent.width
                text: "Опция 3"
                checked: true
                font.pointSize: 8
                indicator.width: 12
                indicator.height: 12
            }
        }

        // Второй столбец - 2 кнопки и текст
        Column {
            width: 100  // Уменьшил ширину столбца
            anchors.centerIn: verticalCenter
            Button {
                id: addSquareButton
                width: parent.width
                text: "Добавить"
                height: 20  // Уменьшил высоту
                font.pointSize: 8
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
                width: parent.width
                text: "Очистить"
                height: 20  // Уменьшил высоту
                font.pointSize: 8
                onClicked: {
                    if (messagesItem) {
                        messagesItem.clearSquares()
                    }
                }
            }

            Text {
                width: parent.width
                text: messagesItem ? "Квадратов: " + messagesItem.squareCount : "Не подключено"
                color: "white"
                font.pointSize: 8
                horizontalAlignment: Text.AlignLeft
            }
        }
    }

    // Инициализация после загрузки компонента
    Component.onCompleted: {
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
