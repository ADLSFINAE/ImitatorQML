import QtQuick 2.12
import QtQuick.Controls 2.12

BaseItem {
    id: configurateItem
    itemTitle: "Конфигурация"

    property bool anyPortOpen: backend.anyPortOpen

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "Управление портами"
            color: "white"
            font.pointSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Кнопка для открытия/закрытия всех портов
        Button {
            width: 200
            height: 30
            text: anyPortOpen ? "Закрыть все порты" : "Открыть все порты"
            enabled: portItem.rowCount > 0

            background: Rectangle {
                color: parent.enabled ? (anyPortOpen ? "#FF4444" : "#44FF44") : "#666666"
                radius: 3
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 10
            }

            onClicked: {
                if (!anyPortOpen) {
                    // Открываем все порты
                    openAllPorts()
                } else {
                    // Закрываем все порты
                    backend.closeAllPorts()
                    console.log("All ports closed")
                }
            }
        }

        // Кнопка для отправки тестовых данных во все открытые порты
        Button {
            width: 200
            height: 30
            text: "Отправить тестовые данные"
            enabled: anyPortOpen

            background: Rectangle {
                color: parent.enabled ? "#4444FF" : "#666666"
                radius: 3
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 10
            }

            onClicked: {
                if (anyPortOpen) {
                    // Отправляем тестовую NMEA строку во все открытые порты
                    var testData = "$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47\r\n" + backend.shitten()
                    if (backend.sendDataToAll(testData)) {
                        console.log("Test data sent to all open ports")
                    } else {
                        console.log("Failed to send test data to some ports")
                    }
                }
            }
        }
    }

    // Функция для открытия всех портов
    function openAllPorts() {
        var successCount = 0
        for (var i = 0; i < portItem.rowCount; i++) {
            if (backend.openPort(i)) {
                successCount++
            }
        }
        console.log("Successfully opened", successCount, "out of", portItem.rowCount, "ports")
    }

    // Обработчики сигналов от backend
    Connections {
        target: backend
        function onDataSent(portName, data) {
            console.log("Data sent to port:", portName, "data:", data)
            downIndicatorRightText.text = "Данные отправлены в " + portName + ": " + data.length + " символов"
        }

        function onErrorOccurred(portName, error) {
            console.log("Port error:", portName, error)
        }

        function onPortOpened(portName) {
            console.log("Port opened:", portName)
            downIndicatorRightText.text = "Порт открыт: " + portName
        }

        function onPortClosed(portName) {
            console.log("Port closed:", portName)
            downIndicatorRightText.text = "Порт закрыт: " + portName
        }
    }
}
