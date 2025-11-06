import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: comboBoxComponent
    height: 60
    width: parent ? parent.width : 200
    color: "transparent"

    property string fieldName: ""
    property string fieldLabel: ""
    property string fieldDefault: ""
    property var fieldOptions: []

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

    ComboBox {
        id: comboBox
        anchors {
            left: parent.left
            top: label.bottom
            right: parent.right
            margins: 5
        }

        model: fieldOptions
        currentIndex: fieldOptions.indexOf(fieldDefault)

        onCurrentTextChanged: {
            console.log("ComboBox", fieldName, "changed to:", currentText)
        }
    }
}
