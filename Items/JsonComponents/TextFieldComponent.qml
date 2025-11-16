import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

Rectangle {
    id: textFieldComponent

    property string fieldName: ""
    property string fieldLabel: ""
    property string fieldDefault: ""
    property string fieldPlaceholder: ""
    property string pageName: ""
    property string mementoMory: ""
    property bool enabled: true

    // Свойства для работы с группами
    property string groupName: ""
    property bool isInGroup: groupName !== ""
    property bool groupEnabled: true
    property bool finalEnabled: enabled && (!isInGroup || groupEnabled)

    // Фиксированные размеры для работы в GridLayout
    implicitWidth: parent ? parent.width : 100
    implicitHeight: parent ? parent.height : 60

    // Стиль
    color: "transparent"
    border.color: finalEnabled ? "#00CED1" : "#666666"
    border.width: 1
    radius: 3
    opacity: finalEnabled ? 1.0 : 0.6

    signal valueChanged()
    signal groupStateChanged(bool enabled)

    // Обработчик изменения состояния enabled
    onEnabledChanged: {

    }

    // Обработчик изменения состояния группы
    onGroupEnabledChanged: {
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

    // Обработчик изменения окончательного состояния
    onFinalEnabledChanged: {
        // Обновляем состояние TextField
        textInput.enabled = finalEnabled;
        textInput.opacity = finalEnabled ? 1.0 : 0.6;
        labelText.color = finalEnabled ? "yellow" : "#666666";
    }

    // Функция для установки состояния группы
    function setGroupState(enabled, groupName) {
        textFieldComponent.groupName = groupName;
        textFieldComponent.groupEnabled = enabled;
    }

    // Функция для выхода из группы
    function removeFromGroup() {
        textFieldComponent.groupName = "";
        textFieldComponent.groupEnabled = true;
    }

    Column {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 3

        Text {
            id: labelText
            width: parent.width
            height: 15
            text: fieldLabel || fieldName
            color: finalEnabled ? "yellow" : "#666666"
            font.pointSize: 7
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            opacity: finalEnabled ? 1.0 : 0.6
        }

        TextField {
            id: textInput
            width: parent.width
            height: 25
            placeholderText: fieldPlaceholder || "0"
            text: fieldDefault
            validator: DoubleValidator{bottom: -20000000; top: 20000000;}
            horizontalAlignment: TextField.AlignHCenter
            enabled: finalEnabled
            opacity: enabled ? 1.0 : 0.6

            background: Rectangle {
                color: "#2A2A2A"
                border.color: finalEnabled ? "#606060" : "#404040"
                radius: 2
            }

            color: finalEnabled ? "white" : "#666666"
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

    // Функция для получения значения
    function getValue() {
        return textInput.text
    }

    // Функция для установки значения
    function setValue(value) {
        textInput.text = value
    }

    // Функция для сброса к значению по умолчанию
    function resetToDefault() {
        textInput.text = fieldDefault
    }

    // Функция для получения информации о компоненте
    function getComponentInfo() {
        return {
            name: fieldName,
            label: fieldLabel,
            type: "textfield",
            enabled: enabled,
            inGroup: isInGroup,
            groupName: groupName,
            groupEnabled: groupEnabled,
            finalEnabled: finalEnabled,
            value: getValue(),
            page: pageName
        }
    }

}
