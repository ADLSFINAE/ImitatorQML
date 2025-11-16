import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: textFieldComponent

    property string fieldName: ""
    property string fieldLabel: ""
    property string fieldDefault: ""
    property string fieldPlaceholder: ""
    property string pageName: ""
    property string mementoMory: ""
    property bool enabled: true

    // Фиксированные размеры для работы в GridLayout
    implicitWidth: parent ? parent.width : 100
    implicitHeight: parent ? parent.height : 60

    // Стиль
    color: "transparent"
    border.color: enabled ? "#00CED1" : "#666666"
    border.width: 1
    radius: 3
    opacity: enabled ? 1.0 : 0.6

    signal valueChanged()

    // Обработчик изменения состояния enabled
    onEnabledChanged: {
        if (dataController) {
            enabled = !enabled
            if(enabled == true){
                mementoMory = textInput.text
                dataController.addDataChange(pageName, fieldName, "textfield", mementoMory)
            }
            else{
                dataController.addDataChange(pageName, fieldName, "textfield", "")
            }
        }

        groupStateChanged(groupEnabled);
    }

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
            validator: DoubleValidator{bottom: -20000000; top: 20000000;}
            horizontalAlignment: TextField.AlignHCenter
            enabled: textFieldComponent.enabled

            background: Rectangle {
                color: "#2A2A2A"
                border.color: textFieldComponent.enabled ? "#606060" : "#666666"
                radius: 2
            }

            color: textFieldComponent.enabled ? "white" : "#666666"
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
