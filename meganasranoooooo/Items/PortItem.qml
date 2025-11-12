import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12
import "../Items/PortItem"

BaseItem {
    id: portItem
    itemTitle: "Порты"

    property int rowCount: 0
    property int selectedPortIndex: -1
    property int selectedBaudRateIndex: -1
    property bool portOpen: false

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
                        comboBoxModel.remove(comboBoxModel.count - 1)
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
                height: parent.height - 60 // Оставляем место для кнопок
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
                                    comboBoxModel.remove(index)
                                    rowCount = comboBoxModel.count
                                }
                            }

                            onPortChanged: {
                                if (index >= 0 && index < comboBoxModel.count) {
                                    comboBoxModel.setProperty(index, "portIndex", portIndex)
                                    comboBoxModel.setProperty(index, "baudRateEnabled", true)
                                    comboBoxModel.setProperty(index, "deleteEnabled", true)

                                    // Обновляем выбранный порт
                                    if (portIndex !== -1) {
                                        portItem.selectedPortIndex = portIndex
                                    }
                                }
                            }

                            onBaudRateChanged: {
                                if (index >= 0 && index < comboBoxModel.count) {
                                    comboBoxModel.setProperty(index, "baudRateIndex", baudRateIndex)

                                    // Обновляем выбранную скорость
                                    if (baudRateIndex !== -1) {
                                        portItem.selectedBaudRateIndex = baudRateIndex
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Контейнер для кнопок
            Column {
                width: parent.width
                height: 55
                spacing: 5

                // Кнопка для открытия/закрытия порта
                Button {
                    width: parent.width
                    height: 25
                    text: portOpen ? "Закрыть порт" : "Открыть порт"
                    enabled: selectedPortIndex !== -1 && selectedBaudRateIndex !== -1

                    background: Rectangle {
                        color: parent.enabled ? (portOpen ? "#FF4444" : "#44FF44") : "#666666"
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 8
                    }

                    onClicked: {
                        if (!portOpen) {
                            // Открываем порт
                            var portName = backend.availablePorts[selectedPortIndex]
                            var baudRate = parseInt(backend.getBaudRates()[selectedBaudRateIndex])

                            if (backend.openPort(portName, baudRate)) {
                                portOpen = true
                                console.log("Port opened:", portName, "with baud rate:", baudRate)
                            }
                        } else {
                            // Закрываем порт
                            backend.closePort()
                            portOpen = false
                            console.log("Port closed")
                        }
                    }
                }

                // Кнопка для отправки тестовых данных
                Button {
                    width: parent.width
                    height: 25
                    text: "Отправить тестовые данные"
                    enabled: portOpen

                    background: Rectangle {
                        color: parent.enabled ? "#4444FF" : "#666666"
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 8
                    }

                    onClicked: {
                        if (portOpen) {
                            // Отправляем тестовую NMEA строку
                            var testData = "$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47\r\n" + backend.shitten.toString()
                            if (backend.sendData(testData)) {
                                console.log("Test data sent successfully")
                                // Обновляем индикатор внизу окна
                                downIndicatorRightText.text = "Данные отправлены: " + testData.length + " символов"
                            } else {
                                console.log("Failed to send test data")
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

    // Обработчики сигналов от backend
    Connections {
        target: backend
        function onDataSent(data) {
            console.log("Data sent to port:", data)
            // Обновляем индикатор внизу окна
            downIndicatorRightText.text = "Данные отправлены: " + data.length + " символов"
        }

        function onErrorOccurred(error) {
            console.log("Port error:", error)
            portOpen = false
        }
    }
}
