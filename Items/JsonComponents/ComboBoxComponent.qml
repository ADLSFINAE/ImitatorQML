import QtQuick 2.12
import QtQuick.Controls 2.12
import "BaseCustomTabAreaComponent"

BaseCustomTabAreaComponent {
    id: comboBoxComponent

    // Устанавливаем цвета
    textColor: "white"  // Белый цвет для выбранного текста

    implicitHeight: 50

    onEnabledChanged: {
        if (dataController) {
            if (enabled) {
                // Восстанавливаем значение из mementoMory при включении
                if (mementoMory !== "") {
                    setValue(mementoMory)
                    dataController.addDataChange(pageName, fieldName, "combobox", mementoMory)
                }
            } else {
                // Сохраняем текущее значение в mementoMory при выключении
                mementoMory = getValue()
                dataController.addDataChange(pageName, fieldName, "combobox", "")
            }
        }
    }

    onGroupEnabledChanged: {
        if (dataController) {
            if (groupEnabled) {
                // Восстанавливаем значение из mementoMory при включении группы
                if (mementoMory !== "") {
                    setValue(mementoMory)
                    dataController.addDataChange(pageName, fieldName, "combobox", mementoMory)
                }
            } else {
                // Сохраняем текущее значение в mementoMory при выключении группы
                mementoMory = getValue()
                dataController.addDataChange(pageName, fieldName, "combobox", "")
            }
        }

        groupStateChanged(groupEnabled);
    }

    Column {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 3

        ComboBox {
            id: comboBox
            width: parent.width
            height: 25
            model: fieldOptions
            currentIndex: fieldOptions.indexOf(fieldDefault)
            enabled: comboBoxComponent.finalEnabled

            background: Rectangle {
                color: "#2A2A2A"
                border.color: comboBoxComponent.finalEnabled ? "#606060" : comboBoxComponent.disabledColor
                radius: 2
            }

            contentItem: Text {
                text: comboBox.displayText
                color: comboBoxComponent.finalEnabled ? comboBoxComponent.textColor : comboBoxComponent.disabledColor
                font.pointSize: 8
                verticalAlignment: Text.AlignVCenter
                leftPadding: 5
                elide: Text.ElideRight
            }

            delegate: ItemDelegate {
                width: comboBox.width
                height: 25
                highlighted: comboBox.highlightedIndex === index

                contentItem: Text {
                    text: modelData
                    color: comboBoxComponent.finalEnabled ? "green" : comboBoxComponent.disabledColor
                    font.pointSize: 8
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 5
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    color: highlighted ? "#404040" : "#2A2A2A"
                }
            }

            popup: Popup {
                y: comboBox.height
                width: comboBox.width
                implicitHeight: contentItem.implicitHeight
                padding: 1

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: comboBox.popup.visible ? comboBox.delegateModel : null
                    currentIndex: comboBox.highlightedIndex

                    ScrollIndicator.vertical: ScrollIndicator { }
                }

                background: Rectangle {
                    color: "#2A2A2A"
                    border.color: "#606060"
                    radius: 2
                }
            }

            onCurrentTextChanged: {
                if (currentText !== fieldDefault) {
                    fieldDefault = currentText
                    valueChanged()
                    console.log("Page:", pageName, "ComboBox", fieldName, "changed to:", currentText)

                    if (dataController) {
                        dataController.addDataChange(pageName, fieldName, "combobox", currentText)
                    }
                }
            }
        }
    }

    function getValue() {
        return comboBox.currentText
    }

    function setValue(value) {
        comboBox.currentIndex = fieldOptions.indexOf(value)
    }

    function resetToDefault() {
        comboBox.currentIndex = fieldOptions.indexOf(fieldDefault)
    }
}
