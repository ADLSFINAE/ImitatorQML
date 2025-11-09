import QtQuick 2.12
import QtQuick.Controls 2.12
import "BaseCustomTabAreaComponent"

BaseCustomTabAreaComponent {
    id: checkBoxComponent

    implicitHeight: 40

    // Переопределяем цвета для чекбокса
    controlColor: "#00CED1"  // Бирюзовый
    textColor: "#00CED1"     // Бирюзовый текст
    disabledColor: "#008B8B" // Темно-бирюзовый для disabled состояния

    CheckBox {
        id: checkBox
        text: fieldLabel
        checked: fieldDefault === "true"
        anchors.centerIn: parent
        enabled: baseComponent.enabled

        onCheckedChanged: {
            fieldDefault = checked.toString()
            valueChanged()
            console.log("Page:", pageName, "CheckBox", fieldName, "changed to:", checked)

            if (dataController) {
                dataController.addDataChange(pageName, fieldName, "checkbox", checked.toString())
            }
        }

        contentItem: Text {
            text: checkBox.text
            color: baseComponent.enabled ? baseComponent.controlColor : baseComponent.disabledColor
            font.pointSize: 9
            verticalAlignment: Text.AlignVCenter
            leftPadding: checkBox.indicator.width + 8
            wrapMode: Text.WrapAnywhere
        }

        indicator: Rectangle {
            implicitWidth: 16
            implicitHeight: 16
            x: checkBox.leftPadding
            y: parent.height / 2 - height / 2
            radius: 3
            border.color: checkBox.checked ? baseComponent.controlColor : "#888888"
            border.width: 1

            Rectangle {
                width: 8
                height: 8
                x: 3
                y: 3
                radius: 2
                color: baseComponent.controlColor
                visible: checkBox.checked
            }
        }
    }

    function getValue() {
        return checkBox.checked.toString()
    }

    function setValue(value) {
        checkBox.checked = value === "true"
    }

    function resetToDefault() {
        checkBox.checked = fieldDefault === "true"
    }
}
