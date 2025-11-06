import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ColumnLayout {
    property var displayModel
    property int pageNumber: 1
    property string pageName: ""

    // Заголовок страницы
    Label {
        text: (displayModel && displayModel.pageName) ? displayModel.pageName : (pageName || "Страница " + pageNumber)
        font.bold: true
        font.pixelSize: 20
        Layout.alignment: Qt.AlignHCenter
    }

    // Информация о странице
    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        Label {
            text: "Номер: " + pageNumber
            color: "gray"
        }

        Label {
            text: "•"
            color: "gray"
        }

        Label {
            text: "Элементов: " + (displayModel ? displayModel.count : 0)
            color: "gray"
        }
    }

    // Список элементов
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Column {
            width: parent.width
            spacing: 8

            Repeater {
                model: displayModel || null

                Rectangle {
                    width: parent.width
                    height: 60
                    color: index % 2 === 0 ? "#f8f8f8" : "white"
                    border.color: "lightgray"
                    radius: 5

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        Text {
                            text: name + " (" + (index + 1) + ")"
                            font.bold: true
                            font.pixelSize: 12
                            color: "gray"
                        }

                        Text {
                            text: model.text
                            font.pixelSize: 14
                            color: model.color
                            width: parent.width
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            // Сообщение если нет элементов
            Rectangle {
                width: parent.width
                height: 100
                color: "transparent"
                visible: !displayModel || displayModel.count === 0

                Column {
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        text: "Нет элементов"
                        color: "gray"
                        font.italic: true
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Нажмите 'Загрузить данные' в верхней панели"
                        color: "lightgray"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
