import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: radioButtonComponent

    property string fieldName: ""
    property string fieldLabel: ""
    property string fieldDefault: ""
    property var fieldOptions: []
    property string selectedValue: fieldDefault
    property string pageName: ""

    // Динамические размеры - рассчитываем на основе количества опций
    implicitWidth: Math.max(150, labelText.implicitWidth + 20)
    implicitHeight: labelText.implicitHeight + (fieldOptions.length * 25) + 15

    // Стиль
    color: "transparent"
    border.color: "#00CED1"
    border.width: 1
    radius: 3

    signal valueChanged()

    onSelectedValueChanged: {
        valueChanged()
        console.log("Page:", pageName, "RadioButton", fieldName, "changed to:", selectedValue)

        if (dataController) {
            dataController.addDataChange(pageName, fieldName, "radiobutton", selectedValue)
        }
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

                    onCheckedChanged: {
                        if (checked) {
                            selectedValue = modelData
                        }
                    }

                    contentItem: Text {
                        text: radioDelegate.text
                        color: "#00CED1"
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
                        border.color: radioDelegate.checked ? "#00CED1" : "#888888"
                        border.width: 1

                        Rectangle {
                            width: 6
                            height: 6
                            x: 3
                            y: 3
                            radius: 3
                            color: "#00CED1"
                            visible: radioDelegate.checked
                        }
                    }
                }
            }
        }
    }
}
