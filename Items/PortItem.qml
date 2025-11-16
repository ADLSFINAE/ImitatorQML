import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12
import "../Items/PortItem"

BaseItem {
    id: portItem
    itemTitle: "Порты"

    property int rowCount: 0

    Row {
        anchors.fill: parent

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
                    if (comboBoxModel.count > 0) {
                        // Удаляем настройки порта из backend при удалении строки
                        var index = comboBoxModel.count - 1
                        backend.closePort(index)
                        comboBoxModel.remove(index)
                        rowCount = comboBoxModel.count
                    }
                }
            }

            Item {
                width: 20
                height: parent.height - 40
            }
        }

        Column {
            width: portItem.width - 20
            height: parent.height
            spacing: 5

            // Контейнер для портов с динамической высотой
            Rectangle {
                id: portsContainer
                width: parent.width
                height: parent.height
                color: "#252525"

                ListModel {
                    id: comboBoxModel
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 5

                    ListView {
                        id: listView
                        model: comboBoxModel
                        clip: true
                        spacing: 5
                        implicitHeight: contentHeight

                        delegate: PortRow {
                            width: listView.width
                            rowIndex: index
                            portIndex: model.portIndex
                            baudRateIndex: model.baudRateIndex
                            baudRateEnabled: model.baudRateEnabled
                            deleteEnabled: model.deleteEnabled

                            onRemoveClicked: {
                                console.log("Removing index:", index)
                                if (index >= 0 && index < comboBoxModel.count) {
                                    // Закрываем порт и удаляем настройки
                                    backend.closePort(index)
                                    comboBoxModel.remove(index)
                                    rowCount = comboBoxModel.count
                                }
                            }

                            onPortChanged: {
                                if (index >= 0 && index < comboBoxModel.count) {
                                    comboBoxModel.setProperty(index, "portIndex", portIndex)
                                    comboBoxModel.setProperty(index, "baudRateEnabled", true)
                                    comboBoxModel.setProperty(index, "deleteEnabled", true)

                                    // Сохраняем настройки порта в backend
                                    if (portIndex !== -1) {
                                        var portName = backend.availablePorts[portIndex]
                                        var baudRate = parseInt(backend.getBaudRates()[baudRateIndex])
                                        backend.setPortSettings(index, portName, baudRate)
                                    }
                                }
                            }

                            onBaudRateChanged: {
                                if (index >= 0 && index < comboBoxModel.count) {
                                    comboBoxModel.setProperty(index, "baudRateIndex", baudRateIndex)

                                    // Сохраняем настройки скорости в backend
                                    if (baudRateIndex !== -1 && portIndex !== -1) {
                                        var portName = backend.availablePorts[portIndex]
                                        var baudRate = parseInt(backend.getBaudRates()[baudRateIndex])
                                        backend.setPortSettings(index, portName, baudRate)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

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
