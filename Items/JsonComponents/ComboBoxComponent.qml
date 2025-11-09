import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: comboBoxComponent

    property string fieldName: ""
    property string fieldLabel: ""
    property string fieldDefault: ""
    property string pageName: ""
    property var fieldOptions: []

    // Динамические размеры
    implicitWidth: Math.max(150, labelText.implicitWidth + 20)
    implicitHeight: labelText.implicitHeight + comboBox.height + 10

    // Стиль
    color: "transparent"
    border.color: "#00CED1"
    border.width: 1
    radius: 3

    signal valueChanged()

    Column {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 3

        ComboBox {
            id: comboBox
            width: parent.width
            height: 25
            model: fieldOptions
            currentIndex: fieldOptions.indexOf(fieldDefault)

            background: Rectangle {
                color: "#2A2A2A"
                border.color: "#606060"
                radius: 2
            }

            contentItem: Text {
                text: comboBox.displayText
                color: "white"
                font.pointSize: 8
                verticalAlignment: Text.AlignVCenter
                leftPadding: 5
                elide: Text.ElideRight
            }

            popup: Popup {
                y: comboBox.height
                width: comboBox.width
                implicitHeight: contentItem.implicitHeight
                padding: 1

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: comboBox.popup.visible ? comboBox.delegateModel : null
                    currentIndex: comboBox.highlightedIndex

                    ScrollIndicator.vertical: ScrollIndicator { }
                }

                background: Rectangle {
                    color: "#2A2A2A"
                    border.color: "#606060"
                    radius: 2
                }
            }

            onCurrentTextChanged: {
                comboBoxComponent.valueChanged()
                console.log("Page:", pageName, "ComboBox", fieldName, "changed to:", currentText)

                if (dataController) {
                    dataController.addDataChange(pageName, fieldName, "combobox", currentText)
                }
            }
        }
    }
}
