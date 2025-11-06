import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: checkBoxComponent
    height: 40
    width: parent ? parent.width : 200
    color: "transparent"

    property string fieldName: ""
    property string fieldLabel: ""
    property string fieldDefault: ""

    CheckBox {
        id: checkBox
        text: fieldLabel
        checked: fieldDefault === "true"
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            margins: 5
        }

        onCheckedChanged: {
            console.log("CheckBox", fieldName, "changed to:", checked)
        }

        contentItem: Text {
            text: checkBox.text
            color: "white"
            font.pointSize: 10
            verticalAlignment: Text.AlignVCenter
            leftPadding: checkBox.indicator.width + 10
        }
    }
}
