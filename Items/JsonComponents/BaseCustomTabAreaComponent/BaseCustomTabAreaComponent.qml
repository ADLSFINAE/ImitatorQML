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
    property var fieldOptions: []

    // Стилевые свойства
    property color borderColor: "#00CED1"
    property color textColor: "white"
    property color backgroundColor: "transparent"
    property color controlColor: "#00CED1"
    property color disabledColor: "#666666"

    // Состояние
    property bool enabled: true

    // Размеры
    implicitWidth: parent ? parent.width : 100
    implicitHeight: parent ? parent.height : 60

    // Сигналы
    signal valueChanged()
    signal focused()
    signal lostFocus()

    // Общий стиль для всех компонентов
    color: backgroundColor
    border.color: enabled ? borderColor : disabledColor
    border.width: 1
    radius: 3
    opacity: enabled ? 1.0 : 0.6

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
}
