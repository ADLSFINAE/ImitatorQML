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
    property int portIndex: -1
    property int baudRateIndex: -1
    property bool baudRateEnabled: false
    property bool deleteEnabled: false

    // Сигналы для общения с родителем
    signal removeClicked(int index)
    signal portChanged(int index, int portIndex)
    signal baudRateChanged(int index, int baudRateIndex)

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
                    portRow.baudRateEnabled = true
                    portRow.deleteEnabled = true
                    portRow.portChanged(portRow.rowIndex, currentIndex - 1)
                } else {
                    portRow.baudRateEnabled = false
                    portRow.deleteEnabled = false
                    baudRateCombo.currentIndex = -1
                    portRow.portChanged(portRow.rowIndex, -1)
                }
            }

            Component.onCompleted: {
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
                console.log("Remove button clicked, rowIndex:", portRow.rowIndex)
                portRow.removeClicked(portRow.rowIndex)
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
                    portRow.baudRateChanged(portRow.rowIndex, currentIndex - 1)
                } else {
                    portRow.baudRateChanged(portRow.rowIndex, -1)
                }
            }

            Component.onCompleted: {
                if (portRow.baudRateIndex !== -1 && portRow.baudRateEnabled) {
                    currentIndex = portRow.baudRateIndex + 1
                } else {
                    currentIndex = -1
                }
            }
        }
    }
}
