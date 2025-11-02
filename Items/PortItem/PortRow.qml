import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

Rectangle {
    id: portRow
    width: 312
    height: 35
    color: "#252525"

    // Свойства, которые передаются из родительского компонента
    property int rowIndex
    property var comboBoxModel

    property int portIndex: -1
    property int baudRateIndex: -1
    property bool baudRateEnabled: false
    property bool deleteEnabled: false

    Row {
        anchors.fill: parent
        anchors.margins: 2
        spacing: 5

        // ComboBox для выбора порта
        CustomComboBox {
            id: portCombo
            width: 142
            height: 30
            currentIndex: -1

            // Модель с заглушкой
            model: {
                var ports = ["Выберите COM-порт"]
                if (backend && backend.availablePorts) {
                    ports = ports.concat(backend.availablePorts)
                }
                return ports
            }

            displayText: {
                if (currentIndex <= 0) {
                    return "Выберите COM-порт"
                }
                return currentText
            }

            onCurrentIndexChanged: {
                if (currentIndex > 0) {
                    // Выбран реальный порт - разблокируем элементы
                    portRow.portIndex = currentIndex - 1
                    portRow.baudRateEnabled = true
                    portRow.deleteEnabled = true
                } else {
                    // Сброшен выбор - блокируем элементы
                    portRow.portIndex = -1
                    portRow.baudRateEnabled = false
                    portRow.deleteEnabled = false
                    // Сбрасываем выбор скорости
                    baudRateCombo.currentIndex = -1
                }
            }

            Component.onCompleted: {
                // Восстанавливаем состояние если было сохранено
                if (portRow.portIndex !== -1) {
                    currentIndex = portRow.portIndex + 1
                } else {
                    currentIndex = -1
                }
            }
        }

        // Кнопка удаления строки
        Button {
            width: 30
            height: 30
            enabled: portRow.deleteEnabled
            opacity: enabled ? 1.0 : 0.5

            background: Rectangle {
                color: "transparent"
            }

            Image {
                width: 30
                height: 30
                source: "qrc:/Images/cancel.png"
            }

            onClicked: {
                portRow.comboBoxModel.remove(portRow.rowIndex)
            }
        }

        // ComboBox для выбора скорости
        CustomComboBox {
            id: baudRateCombo
            width: 132
            height: 30
            enabled: portRow.baudRateEnabled
            opacity: enabled ? 1.0 : 0.5
            currentIndex: -1

            // Модель с заглушкой
            model: {
                var rates = ["Выберите скорость бит/c"]
                if (backend && backend.getBaudRates) {
                    rates = rates.concat(backend.getBaudRates())
                }
                return rates
            }

            displayText: {
                if (currentIndex <= 0) {
                    return "Выберите скорость бит/c"
                }
                return currentText + " бит/с"
            }

            onCurrentIndexChanged: {
                if (currentIndex > 0) {
                    // Выбрана реальная скорость
                    portRow.baudRateIndex = currentIndex - 1
                } else {
                    // Сброшен выбор
                    portRow.baudRateIndex = -1
                }
            }

            Component.onCompleted: {
                // Восстанавливаем состояние если было сохранено
                if (portRow.baudRateIndex !== -1 && portRow.baudRateEnabled) {
                    currentIndex = portRow.baudRateIndex + 1
                } else {
                    currentIndex = -1
                }
            }
        }
    }
}
