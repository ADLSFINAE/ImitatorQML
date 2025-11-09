import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12
import "../Items/JsonComponents"

Rectangle {
    id: groupContainer
    property var groupData: null
    property bool groupEnabled: groupData && groupData.enabled !== undefined ? groupData.enabled : true
    property real cellWidth: 70
    property real cellHeight: 60

    color: "transparent"

    // Размеры рассчитываются исходя из количества элементов
    width: calculateGroupWidth()
    height: calculateGroupHeight()

    function calculateGroupWidth() {
        if (!groupData || !groupData.items) return cellWidth * 2;

        var itemCount = groupData.items.length;
        var spacing = 5; // отступ между элементами
        var margins = 10; // внутренние отступы группы

        // Ширина = (количество элементов * ширина элемента) + отступы
        return (itemCount * cellWidth) + ((itemCount - 1) * spacing) + (margins * 2);
    }

    function calculateGroupHeight() {
        var checkboxHeight = 16;
        var spacing = 5;
        var margins = 10;

        return checkboxHeight + cellHeight + spacing + margins;
    }

    Column {
        anchors.fill: parent
        anchors.margins: 5

        // Кастомный чекбокс для всей группы
        CustomCheckBox {
            id: groupCheckBox
            width: parent.width
            height: 16
            checked: groupContainer.groupEnabled
            text: groupData ? (groupData.label || groupData.name) : "Группа"

            onCheckedChanged: {
                if (groupData) {
                    groupContainer.groupEnabled = checked
                    console.log("Group", groupData.name, checked ? "enabled" : "disabled")
                }
            }
        }

        // Внутренний контейнер для всех элементов группы
        Rectangle {
            id: innerGroupContainer
            width: parent.width
            height: parent.height - groupCheckBox.height - parent.spacing
            color: "#1A1A1A"
            border.color: groupContainer.groupEnabled ? "#404040" : "#303030"
            border.width: 1
            radius: 2
            enabled: groupContainer.groupEnabled
            opacity: enabled ? 1.0 : 0.5

            Row {
                id: itemsFlow
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                Repeater {
                    model: groupData ? (groupData.items || []) : []

                    delegate: Rectangle {
                        id: groupItemContainer
                        width: cellWidth
                        height: cellHeight
                        color: "transparent"

                        // Внутренний контейнер для элемента
                        Rectangle {
                            id: itemInnerContainer
                            anchors.fill: parent
                            color: "#2A2A2A"
                            border.color: "#505050"
                            border.width: 1
                            radius: 2

                            Loader {
                                id: fieldLoader
                                anchors.fill: parent
                                anchors.margins: 2
                                sourceComponent: getFieldComponent(modelData.type)

                                onLoaded: {
                                    if (item) {
                                        item.fieldName = modelData ? modelData.name : ""
                                        item.fieldLabel = modelData ? (modelData.label || modelData.name) : ""
                                        item.fieldDefault = modelData ? (modelData.default || "") : ""
                                        item.pageName = modelData.pageName || "Unknown Page"

                                        // Передаем опции только для комбобоксов и радиокнопок
                                        if (modelData.type === "combobox" || modelData.type === "radiobutton") {
                                            if (item.hasOwnProperty("fieldOptions")) {
                                                item.fieldOptions = modelData.options || []
                                            }
                                        }

                                        // Передаем placeholder только для текстовых полей
                                        if (modelData.type === "textfield") {
                                            if (item.hasOwnProperty("fieldPlaceholder")) {
                                                item.fieldPlaceholder = modelData.placeholder || ""
                                            }
                                        }

                                        // Подключаем сигнал изменения
                                        if (item.valueChanged) {
                                            item.valueChanged.connect(function() {
                                                if (pageLoader && pageLoader.item && pageLoader.item.pageContentChanged) {
                                                    pageLoader.item.pageContentChanged();
                                                }
                                            });
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function getFieldComponent(type) {
        switch(type) {
            case "textfield": return textFieldComponent
            case "combobox": return comboBoxComponent
            case "checkbox": return checkBoxComponent
            case "radiobutton": return radioButtonComponent
            default: return textFieldComponent
        }
    }

    Component {
        id: textFieldComponent
        TextFieldComponent {
            width: parent.width
            height: parent.height
        }
    }

    Component {
        id: comboBoxComponent
        ComboBoxComponent {
            width: parent.width
            height: parent.height
        }
    }

    Component {
        id: checkBoxComponent
        CheckBoxComponent {
            width: parent.width
            height: parent.height
        }
    }

    Component {
        id: radioButtonComponent
        RadioButtonComponent {
            width: parent.width
            height: parent.height
        }
    }

    // Обновляем размеры при изменении данных группы
    onGroupDataChanged: {
        if (groupData) {
            Qt.callLater(updateGroupSizes)
        }
    }

    function updateGroupSizes() {
        groupContainer.width = calculateGroupWidth();
        groupContainer.height = calculateGroupHeight();
    }
}
