import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12
import "../Items/PortItem"

BaseItem {
    id: portItem
    itemTitle: "Порты"

    // Свойство для хранения количества строк
    property int rowCount: 0

    Row {
        anchors.fill: parent

        // Левая колонка с кнопками
        Column {
            width: 20
            height: parent.height

            Button {
                width: 20
                height: 20
                background: Rectangle {
                    color: "transparent"
                }
                Image {
                    width: 20
                    height: 20
                    source: "qrc:/Images/add.png"
                }
                onClicked: {
                    // Добавляем новую строку
                    comboBoxModel.append({
                        "portIndex": -1,
                        "baudRateIndex": -1,
                        "baudRateEnabled": false,
                        "deleteEnabled": false
                    })
                    rowCount = comboBoxModel.count
                }
            }

            Button {
                width: 20
                height: 20
                background: Rectangle {
                    color: "transparent"
                }
                Image {
                    width: 20
                    height: 20
                    source: "qrc:/Images/cancel.png"
                }
                onClicked: {
                    // Удаляем последнюю строку
                    if (comboBoxModel.count > 0) {
                        comboBoxModel.remove(comboBoxModel.count - 1)
                        rowCount = comboBoxModel.count
                    }
                }
            }

            // Spacer для заполнения оставшегося пространства
            Item {
                width: 20
                height: parent.height - 40
            }
        }

        // Правая колонка с прокручиваемой областью
        Column {
            width: portItem.width - 20
            height: parent.height

            Rectangle {
                width: parent.width
                height: 70
                color: "#252525"

                // Модель для хранения комбобоксов
                ListModel {
                    id: comboBoxModel
                }

                ScrollView {
                    id: scrollView
                    anchors.fill: parent
                    anchors.margins: 5

                    ListView {
                        id: listView
                        model: comboBoxModel
                        clip: true
                        spacing: 5

                        delegate: PortRow {
                            rowIndex: index
                            comboBoxModel: comboBoxModel
                            portIndex: model.portIndex
                            baudRateIndex: model.baudRateIndex
                            baudRateEnabled: model.baudRateEnabled
                            deleteEnabled: model.deleteEnabled

                            onPortIndexChanged: comboBoxModel.setProperty(index, "portIndex", portIndex)
                            onBaudRateIndexChanged: comboBoxModel.setProperty(index, "baudRateIndex", baudRateIndex)
                            onBaudRateEnabledChanged: comboBoxModel.setProperty(index, "baudRateEnabled", baudRateEnabled)
                            onDeleteEnabledChanged: comboBoxModel.setProperty(index, "deleteEnabled", deleteEnabled)
                        }
                    }
                }
            }
        }
    }

    // Инициализация - добавляем первую строку при создании
    Component.onCompleted: {
        comboBoxModel.append({
            "portIndex": -1,
            "baudRateIndex": -1,
            "baudRateEnabled": false,
            "deleteEnabled": false
        })
        rowCount = 1
    }
}
