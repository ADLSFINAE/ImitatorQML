import QtQuick 2.12
import QtQuick.Controls 2.12
import "BaseCustomTabAreaComponent"

BaseCustomTabAreaComponent {
    id: radioButtonComponent

    property string selectedValue: fieldDefault

    // Устанавливаем бирюзовые цвета
    controlColor: "#00CED1"  // Бирюзовый
    textColor: "#00CED1"     // Бирюзовый текст
    disabledColor: "#008B8B" // Темно-бирюзовый для disabled состояния

    // Динамические размеры - рассчитываем на основе количества опций
    implicitHeight: (fieldOptions.length * 25) + 15

    onSelectedValueChanged: {
        if (selectedValue !== fieldDefault) {
            fieldDefault = selectedValue
            valueChanged()
            console.log("Page:", pageName, "RadioButton", fieldName, "changed to:", selectedValue)

            if (dataController) {
                dataController.addDataChange(pageName, fieldName, "radiobutton", selectedValue)
            }
        }
    }

    onEnabledChanged: {
        if (dataController) {
            if (enabled) {
                // Восстанавливаем значение из mementoMory при включении
                if (mementoMory !== "") {
                    selectedValue = mementoMory
                    dataController.addDataChange(pageName, fieldName, "radiobutton", mementoMory)
                }
            } else {
                // Сохраняем текущее значение в mementoMory при выключении
                mementoMory = getValue()
                dataController.addDataChange(pageName, fieldName, "radiobutton", "")
            }
        }
    }

    onGroupEnabledChanged: {
        if (dataController) {
            if (groupEnabled) {
                // Восстанавливаем значение из mementoMory при включении группы
                if (mementoMory !== "") {
                    selectedValue = mementoMory
                    dataController.addDataChange(pageName, fieldName, "radiobutton", mementoMory)
                }
            } else {
                // Сохраняем текущее значение в mementoMory при выключении группы
                mementoMory = getValue()
                dataController.addDataChange(pageName, fieldName, "radiobutton", "")
            }
        }

        groupStateChanged(groupEnabled);
    }

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 5

        Column {
            width: parent.width
            spacing: 3

            Repeater {
                model: fieldOptions

                delegate: RadioButton {
                    id: radioDelegate
                    text: modelData
                    checked: modelData === selectedValue
                    width: parent.width
                    height: 20
                    enabled: radioButtonComponent.finalEnabled

                    onCheckedChanged: {
                        if (checked) {
                            selectedValue = modelData
                        }
                    }

                    contentItem: Text {
                        text: radioDelegate.text
                        color: radioButtonComponent.finalEnabled ? radioButtonComponent.controlColor : radioButtonComponent.disabledColor
                        font.pointSize: 7
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: radioDelegate.indicator.width + 6
                        elide: Text.ElideRight
                        wrapMode: Text.WrapAnywhere
                    }

                    indicator: Rectangle {
                        implicitWidth: 12
                        implicitHeight: 12
                        x: radioDelegate.leftPadding
                        y: parent.height / 2 - height / 2
                        radius: 6
                        border.color: radioDelegate.checked ? radioButtonComponent.controlColor : "#888888"
                        border.width: 1

                        Rectangle {
                            width: 6
                            height: 6
                            x: 3
                            y: 3
                            radius: 3
                            color: radioButtonComponent.controlColor
                            visible: radioDelegate.checked
                        }
                    }
                }
            }
        }
    }

    function getValue() {
        return selectedValue
    }

    function setValue(value) {
        selectedValue = value
    }

    function resetToDefault() {
        selectedValue = fieldDefault
    }
}
