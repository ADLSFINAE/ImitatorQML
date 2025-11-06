import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12


Rectangle {
    id: singleContainer
    property var itemData: null
    property bool itemEnabled: itemData && itemData.enabled !== undefined ? itemData.enabled : true

    anchors.fill: parent
    anchors.margins: 2
    color: "transparent"
    border.color: itemEnabled ? "#404040" : "#303030"
    border.width: 1
    radius: 4

    Column {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 2

        // CheckBox для активации элемента
        CheckBox {
            id: itemCheckBox
            width: parent.width
            height: 18
            checked: singleContainer.itemEnabled
            text: itemData ? (itemData.label || itemData.name) : "Элемент"

            contentItem: Text {
                text: itemCheckBox.text
                color: itemCheckBox.checked ? "white" : "#888888"
                font.pointSize: 9
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                leftPadding: itemCheckBox.indicator.width + 6
            }

            onCheckedChanged: {
                if (itemData) {
                    singleContainer.itemEnabled = checked
                    fieldContent.enabled = checked
                    console.log("Item", itemData.name, checked ? "enabled" : "disabled")
                }
            }
        }

        // Основной элемент
        Loader {
            id: fieldContent
            width: parent.width
            height: parent.height - itemCheckBox.height - 15
            sourceComponent: getFieldComponent(itemData ? itemData.type : "textfield")
            enabled: singleContainer.itemEnabled
            opacity: enabled ? 1.0 : 0.5

            onLoaded: {
                if (item) {
                    item.fieldData = itemData
                }
            }
        }

        // Подпись под элементом
        Text {
            width: parent.width
            height: 12
            text: itemData ? (itemData.description || "") : ""
            color: singleContainer.itemEnabled ? "#AAAAAA" : "#666666"
            font.pointSize: 7
            wrapMode: Text.Wrap
            elide: Text.ElideRight
        }
    }

    function getFieldComponent(type) {
        console.log("Getting component for type:", type)
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
            background: Rectangle { color: "#1A1A1A"; border.color: "#505050"; radius: 2 }
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
            background: Rectangle { color: "#1A1A1A"; border.color: "#505050"; radius: 2 }
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
