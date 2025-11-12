import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12
import "../Items/JsonComponents"

Rectangle {
    id: singleContainer
    property var itemData: null
    property bool itemEnabled: itemData && itemData.enabled !== undefined ? itemData.enabled : true

    color: "transparent"
    border.color: "transparent"

    // Динамические размеры контейнера
    implicitWidth: Math.max(150, fieldContent.implicitWidth || 0)
    implicitHeight: (itemCheckBox.height + innerContainer.implicitHeight + descriptionText.height + 10)

    // УБИРАЕМ дублирующий сигнал - он уже автоматически создается для itemEnabled

    // Кастомный чекбокс отключения элемента
    CustomCheckBox {
        id: itemCheckBox
        width: parent.width
        height: 16
        checked: singleContainer.itemEnabled
        text: itemData ? (itemData.label || itemData.name) : "Элемент"

        onCheckedChanged: {
            if (itemData) {
                singleContainer.itemEnabled = checked
                innerContainer.enabled = checked

                // Используем автоматически созданный сигнал
                handleItemEnabledChange(checked)

                console.log("=== CHECKBOX STATE CHANGE ===")
                console.log("Page:", itemData.pageName || "Unknown")
                console.log("Item:", itemData.name)
                console.log("Type:", itemData.type)
                console.log("Enabled:", checked ? "true" : "false")
                console.log("=== END CHECKBOX CHANGE ===")

                // Также отправляем сигнал изменения контента страницы
                if (pageLoader && pageLoader.item && pageLoader.item.pageContentChanged) {
                    pageLoader.item.pageContentChanged();
                }
            }
        }
    }

    // Внутренний видимый контейнер для кастомного компонента
    Rectangle {
        id: innerContainer
        anchors {
            top: itemCheckBox.bottom
            topMargin: 2
            left: parent.left
            right: parent.right
        }
        height: implicitHeight
        color: "#1A1A1A"
        border.color: singleContainer.itemEnabled ? "lightgray" : "gray"
        border.width: 1
        radius: 3
        enabled: singleContainer.itemEnabled
        opacity: enabled ? 1.0 : 0.5

        // Динамическая высота внутреннего контейнера
        property real implicitHeight: fieldContent.implicitHeight || 60

        Loader {
            id: fieldContent
            anchors.fill: parent
            anchors.margins: 5
            sourceComponent: getFieldComponent(itemData ? itemData.type : "textfield")
            enabled: singleContainer.itemEnabled
            opacity: enabled ? 1.0 : 0.5

            // Передаем implicit размеры от загруженного компонента
            property real implicitWidth: item ? item.implicitWidth : 150
            property real implicitHeight: item ? item.implicitHeight : 60

            onLoaded: {
                if (item) {
                    // Передаем данные через отдельные свойства
                    item.fieldName = itemData ? itemData.name : ""
                    item.fieldLabel = itemData ? (itemData.label || itemData.name) : ""
                    item.fieldDefault = itemData ? (itemData.default || "") : ""
                    item.pageName = itemData.pageName || "Unknown Page"
                    item.enabled = singleContainer.itemEnabled // Передаем текущее состояние

                    // Передаем опции только для комбобоксов и радиокнопок
                    if (itemData.type === "combobox" || itemData.type === "radiobutton") {
                        if (item.hasOwnProperty("fieldOptions")) {
                            item.fieldOptions = itemData.options || []
                        }
                    }

                    // Передаем placeholder только для текстовых полей
                    if (itemData.type === "textfield") {
                        if (item.hasOwnProperty("fieldPlaceholder")) {
                            item.fieldPlaceholder = itemData.placeholder || ""
                        }
                    }

                    // Обновляем implicit размеры после загрузки
                    implicitWidth = item.implicitWidth
                    implicitHeight = item.implicitHeight

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

            onImplicitWidthChanged: {
                // Обновляем размеры при изменении содержимого
                singleContainer.implicitWidth = Math.max(150, implicitWidth)
                innerContainer.implicitWidth = implicitWidth
            }

            onImplicitHeightChanged: {
                // Обновляем размеры при изменении содержимого
                innerContainer.implicitHeight = implicitHeight
            }
        }
    }

    // Описание
    Text {
        id: descriptionText
        anchors {
            top: innerContainer.bottom
            topMargin: 2
            left: parent.left
            right: parent.right
        }
        height: text ? 12 : 0 // Скрываем если нет описания
        text: itemData ? (itemData.description || "") : ""
        color: singleContainer.itemEnabled ? "#AAAAAA" : "#666666"
        font.pointSize: 7
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        visible: text !== "" // Скрываем если текст пустой
    }

    // Функция для обработки изменения состояния enabled
    function handleItemEnabledChange(enabled) {
        // Обновляем состояние загруженного компонента
        if (fieldContent.item) {
            fieldContent.item.enabled = enabled

            // Логируем изменение состояния для всех компонентов
            console.log("=== COMPONENT STATE UPDATE ===")
            console.log("Page:", itemData ? itemData.pageName : "Unknown")
            console.log("Component:", itemData ? itemData.name : "Unknown")
            console.log("Type:", itemData ? itemData.type : "Unknown")
            console.log("Enabled:", enabled ? "true" : "false")
            console.log("=== END STATE UPDATE ===")
        }
    }

    // Обработчик автоматически созданного сигнала для itemEnabled
    onItemEnabledChanged: {
        handleItemEnabledChange(itemEnabled)
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
        TextFieldComponentWithoutText {
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

    // Обновляем размеры при изменении данных
    onItemDataChanged: {
        if (itemData) {
            Qt.callLater(updateSizes)
        }
    }

    function updateSizes() {
        // Принудительно обновляем размеры
        singleContainer.implicitWidth = Math.max(150, fieldContent.implicitWidth || 0)
        innerContainer.implicitHeight = fieldContent.implicitHeight || 60
    }
}
