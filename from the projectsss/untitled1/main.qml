import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "COM Port Manager"

    // Модель для хранения пар комбобоксов
    ListModel {
        id: comboBoxPairsModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        // Панель управления
        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "Добавить пару"
                onClicked: {
                    // Добавляем новую пару в модель
                    comboBoxPairsModel.append({
                        "portIndex": -1,
                        "baudRateIndex": -1,
                        "baudRateEnabled": false
                    })
                }
            }

            Button {
                text: "Удалить последнюю"
                onClicked: {
                    if (comboBoxPairsModel.count > 0) {
                        comboBoxPairsModel.remove(comboBoxPairsModel.count - 1)
                    }
                }
            }

            Button {
                text: "Обновить порты"
                onClicked: {
                    backend.refreshPorts()
                }
            }

            Item { Layout.fillWidth: true } // Spacer
        }

        // Прокручиваемая область для пар комбобоксов
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: pairsListView
                model: comboBoxPairsModel
                spacing: 10

                delegate: Rectangle {
                    id: pairDelegate
                    width: pairsListView.width
                    height: 50
                    color: index % 2 === 0 ? "#f0f0f0" : "#ffffff"
                    border.color: "#cccccc"
                    radius: 5

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5

                        Text {
                            text: "Пара " + (index + 1)
                            font.bold: true
                            Layout.preferredWidth: 60
                        }

                        ComboBox {
                            id: portComboBox
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width * 0.4

                            model: backend.availablePorts
                            displayText: "Выберите COM порт"

                            onCurrentIndexChanged: {
                                // При выборе порта разблокируем комбобокс Baudrate
                                if (currentIndex !== -1) {
                                    comboBoxPairsModel.setProperty(index, "baudRateEnabled", true)
                                    comboBoxPairsModel.setProperty(index, "portIndex", currentIndex)
                                } else {
                                    comboBoxPairsModel.setProperty(index, "baudRateEnabled", false)
                                    baudRateComboBox.currentIndex = -1
                                }
                            }

                            Component.onCompleted: {
                                if (model.portIndex !== -1) {
                                    currentIndex = model.portIndex
                                }
                            }
                        }

                        ComboBox {
                            id: baudRateComboBox
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width * 0.4

                            enabled: model.baudRateEnabled
                            model: backend.getBaudRates()
                            displayText: currentIndex === -1 ? "Выберите Baudrate" : currentText + " бит/с"

                            onCurrentIndexChanged: {
                                if (currentIndex !== -1) {
                                    comboBoxPairsModel.setProperty(index, "baudRateIndex", currentIndex)
                                }
                            }

                            Component.onCompleted: {
                                if (model.baudRateIndex !== -1) {
                                    currentIndex = model.baudRateIndex
                                }
                            }
                        }

                        Button {
                            text: "Удалить"
                            Layout.preferredWidth: 80
                            onClicked: {
                                comboBoxPairsModel.remove(index)
                            }
                        }
                    }
                }
            }
        }

        // Статус бар
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: "#e0e0e0"
            border.color: "#cccccc"

            Text {
                anchors.centerIn: parent
                text: "Всего пар: " + comboBoxPairsModel.count
                font.bold: true
            }
        }
    }

    Component.onCompleted: {
        // Добавляем первую пару при запуске
        comboBoxPairsModel.append({
            "portIndex": -1,
            "baudRateIndex": -1,
            "baudRateEnabled": false
        })
    }
}
