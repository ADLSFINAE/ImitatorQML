import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: baseComponent

    // Общие свойства для всех компонентов
    property string fieldName: ""
    property string fieldLabel: ""
    property string fieldDefault: ""
    property string fieldPlaceholder: ""
    property string pageName: ""
    property string mementoMory: ""
    property var fieldOptions: []

    // Стилевые свойства
    property color borderColor: "#00CED1"
    property color textColor: "white"
    property color backgroundColor: "transparent"
    property color controlColor: "#00CED1"
    property color disabledColor: "#666666"

    // Состояние
    property bool enabled: true

    // Свойства для работы с группами
    property string groupName: ""  // Название группы, если элемент находится в группе
    property bool isInGroup: groupName !== ""  // Флаг, указывающий что элемент в группе
    property bool groupEnabled: true  // Состояние группы (если элемент в группе)

    // Размеры
    implicitWidth: parent ? parent.width : 100
    implicitHeight: parent ? parent.height : 60

    // Сигналы
    signal valueChanged()
    signal focused()
    signal lostFocus()
    signal groupStateChanged(bool enabled)  // Сигнал изменения состояния группы

    // Вычисляемое свойство для окончательного состояния enabled
    property bool finalEnabled: {
        if (isInGroup) {
            return enabled && groupEnabled;
        } else {
            return enabled;
        }
    }

    // Общий стиль для всех компонентов
    color: backgroundColor
    border.color: finalEnabled ? borderColor : disabledColor
    border.width: 1
    radius: 3
    opacity: finalEnabled ? 1.0 : 0.6

    // Обработчик изменения состояния enabled
    onEnabledChanged: {

    }

    // Обработчик изменения состояния группы
    onGroupEnabledChanged: {

        groupStateChanged(groupEnabled);
    }

    // Обработчик изменения окончательного состояния
    onFinalEnabledChanged: {

    }

    // Функция для установки состояния группы (вызывается из GroupItem)
    function setGroupState(enabled, groupName) {
        baseComponent.groupName = groupName;
        baseComponent.groupEnabled = enabled;
    }

    // Функция для выхода из группы (если нужно)
    function removeFromGroup() {
        baseComponent.groupName = "";
        baseComponent.groupEnabled = true;
    }

    // Базовые функции для наследования
    function getValue() {
        return fieldDefault
    }

    function setValue(value) {
        fieldDefault = value
        valueChanged()
    }

    function resetToDefault() {
        // Должна быть переопределена в дочерних компонентах
    }

    function validate() {
        return true
    }

    // Функция для получения информации о состоянии компонента
    function getComponentInfo() {
        return {
            name: fieldName,
            label: fieldLabel,
            type: "base",
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

