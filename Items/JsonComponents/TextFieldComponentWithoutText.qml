import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: textFieldComponent

    property string fieldName: ""
    property string fieldLabel: ""
    property string fieldDefault: ""
    property string fieldPlaceholder: ""
    property string pageName: ""

    // Фиксированные размеры для работы в GridLayout
    implicitWidth: parent ? parent.width : 100
    implicitHeight: parent ? parent.height : 60

    // Стиль
    color: "transparent"
    border.color: "#00CED1"
    border.width: 1
    radius: 3

    signal valueChanged()

    Column {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 3

        TextField {
            id: textInput
            width: parent.width
            height: 25
            placeholderText: fieldPlaceholder || "0"
            text: fieldDefault
            validator: IntValidator{bottom: -20000000; top: 20000000;}
            horizontalAlignment: TextField.AlignHCenter

            background: Rectangle {
                color: "#2A2A2A"
                border.color: "#606060"
                radius: 2
            }

            color: "white"
            font.pointSize: 8

            onTextChanged: {
                textFieldComponent.valueChanged()
                console.log("Page:", textFieldComponent.pageName,
                           "| TextField", fieldName,
                           "changed to:", text)

                if (dataController) {
                    dataController.addDataChange(pageName, fieldName, "textfield", text)
                }
            }
        }
    }
}
