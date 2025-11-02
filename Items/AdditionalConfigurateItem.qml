import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

BaseItem {
    id: additionalConfigurateItem
    itemTitle: "Дополнительно"

    // Окно сообщений
    property var messagesWindow: null

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
            // Можно установить кастомный список сообщений
            // messagesWindow.setMessages(["Мое сообщение 1", "Мое сообщение 2", ...])
            messagesWindow.show()
        }
    }

    // Обработчики сигналов окна сообщений
    function onMessagesSaved(selectedItems) {
        console.log("Сохранены выбранные сообщения:", selectedItems)
        // Здесь можно обработать выбранные сообщения
    }

    function onMessagesCanceled() {
        console.log("Диалог сообщений отменен")
    }
}
