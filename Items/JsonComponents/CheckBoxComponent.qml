import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: checkBoxComponent

    property string fieldName: ""
    property string fieldLabel: ""
    property string fieldDefault: ""
    property string pageName: ""

    // Динамические размеры
    implicitWidth: Math.max(120, checkBox.implicitWidth + 20)
    implicitHeight: 40 // Фиксированная высота для чекбокса

    // Стиль
    color: "transparent"
    border.color: "#00CED1"
    border.width: 1
    radius: 3

    signal valueChanged()

    CheckBox {
        id: checkBox
        text: fieldLabel
        checked: fieldDefault === "true"
        anchors.centerIn: parent

        onCheckedChanged: {
            checkBoxComponent.valueChanged()
            console.log("Page:", pageName, "CheckBox", fieldName, "changed to:", checked)

            if (dataController) {
                dataController.addDataChange(pageName, fieldName, "checkbox", checked.toString())
            }
        }

        contentItem: Text {
            text: checkBox.text
            color: "#00CED1"
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
            border.color: checkBox.checked ? "#00CED1" : "#888888"
            border.width: 1

            Rectangle {
                width: 8
                height: 8
                x: 4
                y: 4
                radius: 2
                color: "#00CED1"
                visible: checkBox.checked
            }
        }
    }
}

