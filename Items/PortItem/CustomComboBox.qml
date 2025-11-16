import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

ComboBox {
    id: control

    // Кастомные свойства
    property color backgroundColor: "black"
    property color textColor: "#00FF00"
    property color borderColor: "#444444"
    property int borderWidth: 1

    // Стилизация
    background: Rectangle {
        color: control.backgroundColor
        border.color: control.borderColor
        border.width: control.borderWidth
        radius: 2
    }

    contentItem: Text {
        text: control.displayText
        color: control.textColor
        font: control.font
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        leftPadding: 10
        rightPadding: control.indicator.width + control.spacing
    }

    indicator: Canvas {
        id: arrowCanvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() { arrowCanvas.requestPaint(); }
        }

        onPaint: {
            var context = getContext("2d");
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.textColor;
            context.fill();
        }
    }

    popup: Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: control.backgroundColor
            border.color: control.borderColor
            border.width: control.borderWidth
            radius: 2
        }
    }

    delegate: ItemDelegate {
        width: control.width
        text: modelData
        highlighted: control.highlightedIndex === index
        background: Rectangle {
            color: highlighted ? "#333333" : "transparent"
        }
        contentItem: Text {
            text: modelData
            color: control.textColor
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }
}
