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

    // Сигнал для изменения состояния группы
    signal groupEnabledStateChanged(bool enabled)

    // Список для хранения ссылок на все элементы группы
    property var groupItems: ([])

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

                    // Отправляем сигнал об изменении состояния группы
                    handleGroupEnabledChange(checked)

                    console.log("=== GROUP CHECKBOX STATE CHANGE ===")
                    console.log("Group:", groupData.name)
                    console.log("Enabled:", checked ? "true" : "false")
                    console.log("Items count:", groupData.items ? groupData.items.length : 0)
                    console.log("=== END GROUP CHECKBOX CHANGE ===")
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
                            border.color: groupContainer.groupEnabled ? "#505050" : "#404040"
                            border.width: 1
                            radius: 2
                            opacity: groupContainer.groupEnabled ? 1.0 : 0.5

                            Loader {
                                id: fieldLoader
                                anchors.fill: parent
                                anchors.margins: 2
                                sourceComponent: getFieldComponent(modelData.type)
                                enabled: groupContainer.groupEnabled
                                opacity: enabled ? 1.0 : 0.5

                                onLoaded: {
                                    if (item) {
                                        item.fieldName = modelData ? modelData.name : ""
                                        item.fieldLabel = modelData ? (modelData.label || modelData.name) : ""
                                        item.fieldDefault = modelData ? (modelData.default || "") : ""
                                        item.pageName = modelData.pageName || "Unknown Page"
                                        item.enabled = modelData.enabled !== undefined ? modelData.enabled : true

                                        // Устанавливаем состояние группы для элемента
                                        if (item.setGroupState) {
                                            item.setGroupState(groupContainer.groupEnabled, groupData.name)
                                        }

                                        // Добавляем элемент в список группы
                                        if (groupItems.indexOf(item) === -1) {
                                            groupItems.push(item);
                                        }

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

                                        // Логируем создание элемента группы
                                        console.log("=== GROUP ITEM CREATED ===")
                                        console.log("Group:", groupData ? groupData.name : "Unknown")
                                        console.log("Item:", modelData.name)
                                        console.log("Type:", modelData.type)
                                        console.log("Component Enabled:", item.enabled ? "true" : "false")
                                        console.log("Group Enabled:", groupContainer.groupEnabled ? "true" : "false")
                                        console.log("Final State:", item.finalEnabled ? "true" : "false")
                                        console.log("=== END GROUP ITEM CREATION ===")
                                    }
                                }

                                onItemChanged: {
                                    // Удаляем старый элемент из списка при изменении
                                    if (item && groupItems.indexOf(item) === -1) {
                                        groupItems.push(item);
                                    }
                                }
                            }
                        }

                        // Удаляем элемент из списка при уничтожении
                        Component.onDestruction: {
                            if (fieldLoader.item && groupItems.indexOf(fieldLoader.item) !== -1) {
                                var index = groupItems.indexOf(fieldLoader.item);
                                groupItems.splice(index, 1);
                            }
                        }
                    }
                }
            }
        }
    }

    // Функция для обработки изменения состояния группы
    function handleGroupEnabledChange(enabled) {
        console.log("=== UPDATING ALL GROUP ITEMS ===")
        console.log("Group:", groupData ? groupData.name : "Unknown")
        console.log("New State:", enabled ? "enabled" : "disabled")
        console.log("Total items to update:", groupItems.length)
        console.log("=== START GROUP ITEMS UPDATE ===")

        // Обновляем состояние всех элементов в списке группы
        for (var i = 0; i < groupItems.length; i++) {
            var item = groupItems[i];
            if (item && item.setGroupState) {
                console.log("Updating item:", i + 1, "-", item.fieldName)

                // Используем метод setGroupState для установки состояния группы
                item.setGroupState(enabled, groupData.name);

                // Принудительно обновляем вычисляемые свойства
                if (item.groupEnabledChanged) {
                    item.groupEnabledChanged();
                }
                if (item.finalEnabledChanged) {
                    item.finalEnabledChanged();
                }

                console.log("=== GROUP ITEM STATE UPDATE ===")
                console.log("Group:", groupData ? groupData.name : "Unknown")
                console.log("Item:", item.fieldName)
                console.log("Type:", item.fieldType || "Unknown")
                console.log("Component Enabled:", item.enabled ? "true" : "false")
                console.log("Group Enabled:", enabled ? "true" : "false")
                console.log("Final State:", item.finalEnabled ? "true" : "false")
                console.log("=== END GROUP ITEM UPDATE ===")
            } else {
                console.log("Skipping invalid item:", i)
            }
        }

        console.log("=== COMPLETED GROUP ITEMS UPDATE ===")
        console.log("Successfully updated:", groupItems.length, "items")
        console.log("=== END GROUP UPDATE ===")

        // Отправляем сигнал об изменении состояния
        groupEnabledStateChanged(enabled);

        // Также отправляем сигнал изменения контента страницы
        if (pageLoader && pageLoader.item && pageLoader.item.pageContentChanged) {
            pageLoader.item.pageContentChanged();
        }
    }

    // Обработчик автоматически созданного сигнала для groupEnabled
    onGroupEnabledChanged: {
        handleGroupEnabledChange(groupEnabled)
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
            // Сбрасываем локальное состояние при изменении данных
            groupEnabled = groupData.enabled !== undefined ? groupData.enabled : true
            // Очищаем список элементов
            groupItems = [];
            Qt.callLater(updateGroupSizes)
        }
    }

    function updateGroupSizes() {
        groupContainer.width = calculateGroupWidth();
        groupContainer.height = calculateGroupHeight();
    }

    // Функция для получения текущего состояния группы
    function getCurrentState() {
        var itemsState = [];
        for (var i = 0; i < groupItems.length; i++) {
            var item = groupItems[i];
            if (item) {
                itemsState.push({
                    name: item.fieldName,
                    enabled: item.enabled,
                    groupEnabled: item.groupEnabled,
                    finalEnabled: item.finalEnabled,
                    value: item.getValue ? item.getValue() : ""
                });
            }
        }

        return {
            groupName: groupData ? groupData.name : "",
            enabled: groupEnabled,
            items: itemsState
        }
    }

    // Функция для сбора данных всех элементов группы
    function collectGroupData() {
        var collectedData = {
            groupName: groupData ? groupData.name : "",
            groupEnabled: groupEnabled,
            timestamp: new Date().toISOString(),
            items: []
        };

        for (var i = 0; i < groupItems.length; i++) {
            var item = groupItems[i];
            if (item) {
                var itemData = {
                    name: item.fieldName,
                    type: item.fieldType || "unknown",
                    label: item.fieldLabel,
                    enabled: item.enabled,
                    groupEnabled: item.groupEnabled,
                    finalEnabled: item.finalEnabled,
                    value: item.getValue ? item.getValue() : "",
                    pageName: item.pageName
                };
                collectedData.items.push(itemData);
            }
        }

        return collectedData;
    }

    // Очистка при уничтожении
    Component.onDestruction: {
        groupItems = [];
    }
}
