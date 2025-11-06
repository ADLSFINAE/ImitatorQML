import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12
import "../Items/JsonComponents"

Rectangle {
    id: jsonContentView
    color: "transparent"

    property var displayModel: null
    property var jsonParser: null

    onJsonParserChanged: {
        if (jsonParser && displayModel) {
            displayModel.loadFromJsonParser(jsonParser)
        }
    }

    Column {
        id: contentColumn
        anchors {
            fill: parent
            margins: 15
        }
        spacing: 15

        // Заголовок страницы
        Text {
            id: pageTitle
            text: displayModel && displayModel.pageName ? displayModel.pageName : "Выберите страницу"
            color: "white"
            font.pointSize: 16
            font.bold: true
            anchors {
                left: parent.left
                right: parent.right
            }
            wrapMode: Text.Wrap
        }

        // Разделитель
        Rectangle {
            width: parent.width
            height: 1
            color: "#404040"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Список элементов
        ListView {
            id: jsonItemsList
            anchors {
                left: parent.left
                right: parent.right
            }
            height: parent.height - pageTitle.height - 30
            clip: true
            spacing: 10

            model: displayModel

            delegate: Loader {
                width: jsonItemsList.width
                sourceComponent: getComponentForType(model.type)

                property string fieldName: model.name
                property string fieldLabel: model.label || model.name
                property string fieldDefault: model.default || ""
                property var fieldOptions: model.options || []
                property string fieldType: model.type

                function getComponentForType(type) {
                    switch(type) {
                        case "textfield": return textFieldComponent
                        case "combobox": return comboBoxComponent
                        case "checkbox": return checkBoxComponent
                        default: return textFieldComponent
                    }
                }
            }

            Component {
                id: textFieldComponent
                TextFieldComponent {
                    fieldName: model.name
                    fieldLabel: model.label || model.name
                    fieldDefault: model.default || ""
                }
            }

            Component {
                id: comboBoxComponent
                ComboBoxComponent {
                    fieldName: model.name
                    fieldLabel: model.label || model.name
                    fieldDefault: model.default || ""
                    fieldOptions: model.options || []
                }
            }

            Component {
                id: checkBoxComponent
                CheckBoxComponent {
                    fieldName: model.name
                    fieldLabel: model.label || model.name
                    fieldDefault: model.default || ""
                }
            }
        }
    }

    // Сообщение когда нет данных
    Text {
        id: emptyText
        text: "Выберите страницу для отображения содержимого"
        color: "gray"
        font.pointSize: 12
        anchors.centerIn: parent
        visible: !displayModel || displayModel.count === 0
    }
}
