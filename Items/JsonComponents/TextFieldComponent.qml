import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: textFieldComponent
    height: 60
    width: parent ? parent.width : 200
    color: "transparent"

    property string fieldName: ""
    property string fieldLabel: ""
    property string fieldDefault: ""

    Text {
        id: label
        text: fieldLabel
        color: "white"
        font.pointSize: 10
        anchors {
            left: parent.left
            top: parent.top
            margins: 5
        }
    }

    TextField {
        id: textInput
        placeholderText: "Введите " + fieldLabel.toLowerCase()
        text: fieldDefault
        anchors {
            left: parent.left
            top: label.bottom
            right: parent.right
            margins: 5
        }

        onTextChanged: {
            console.log("Field", fieldName, "changed to:", text)
        }
    }
}
