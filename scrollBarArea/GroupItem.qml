import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

Rectangle {
    id: groupContainer
    property var groupData: null
    property bool groupEnabled: groupData && groupData.enabled !== undefined ? groupData.enabled : true

    color: "#2A2A2A"
    border.color: groupEnabled ? "#404040" : "#303030"
    border.width: 1
    radius: 4

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        // Заголовок группы
        CheckBox {
            id: groupCheckBox
            width: parent.width
            height: 25
            checked: groupContainer.groupEnabled
            text: groupData ? (groupData.label || groupData.name) : "Группа"

            contentItem: Text {
                text: groupCheckBox.text
                color: groupCheckBox.checked ? "white" : "#888888"
                font.pointSize: 10
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                leftPadding: groupCheckBox.indicator.width + 8
            }

            onCheckedChanged: {
                if (groupData) {
                    groupContainer.groupEnabled = checked
                    console.log("Group", groupData.name, checked ? "enabled" : "disabled")
                }
            }
        }

        // Разделитель
        Rectangle {
            width: parent.width
            height: 1
            color: groupCheckBox.checked ? "#404040" : "#2A2A2A"
        }

        // Элементы группы
        Column {
            width: parent.width
            height: parent.height - groupCheckBox.height - 10
            spacing: 6

            Repeater {
                model: groupData ? (groupData.items || []) : []

                delegate: Item {
                    width: parent.width
                    height: 40

                    Column {
                        width: parent.width
                        spacing: 2

                        // Элемент управления
                        Loader {
                            id: fieldLoader
                            width: parent.width
                            height: 25
                            sourceComponent: getFieldComponent(modelData.type)
                            enabled: groupContainer.groupEnabled
                            opacity: groupContainer.groupEnabled ? 1.0 : 0.5

                            onLoaded: {
                                if (item) {
                                    item.fieldData = modelData
                                }
                            }
                        }

                        // Описание
                        Text {
                            width: parent.width
                            height: 12
                            text: modelData ? (modelData.description || "") : ""
                            color: groupContainer.groupEnabled ? "#AAAAAA" : "#666666"
                            font.pointSize: 7
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    // Функция для получения компонентов полей
    function getFieldComponent(type) {
        switch(type) {
            case "textfield": return textFieldComponent
            case "combobox": return comboBoxComponent
            case "checkbox": return checkBoxComponent
            default: return textFieldComponent
        }
    }

    // Компоненты для полей
    Component {
        id: textFieldComponent
        TextField {
            property var fieldData: null

            placeholderText: fieldData ? (fieldData.placeholder || "Введите значение") : ""
            text: fieldData ? (fieldData.default || "") : ""

            background: Rectangle {
                color: "#1A1A1A"
                border.color: "#505050"
                radius: 2
            }

            color: "white"
            font.pointSize: 9
            anchors.fill: parent
        }
    }

    Component {
        id: comboBoxComponent
        ComboBox {
            property var fieldData: null

            model: fieldData ? (fieldData.options || []) : []
            currentIndex: fieldData && fieldData.options ? fieldData.options.indexOf(fieldData.default || "") : 0

            background: Rectangle {
                color: "#1A1A1A"
                border.color: "#505050"
                radius: 2
            }

            contentItem: Text {
                text: parent.displayText
                color: "white"
                font.pointSize: 9
                verticalAlignment: Text.AlignVCenter
                leftPadding: 8
            }

            anchors.fill: parent
        }
    }

    Component {
        id: checkBoxComponent
        CheckBox {
            property var fieldData: null

            text: fieldData ? (fieldData.label || fieldData.name) : ""
            checked: fieldData ? (fieldData.default === "true") : false

            contentItem: Text {
                text: parent.text
                color: "white"
                font.pointSize: 9
                verticalAlignment: Text.AlignVCenter
                leftPadding: parent.indicator.width + 8
            }

            anchors.fill: parent
        }
    }
}

