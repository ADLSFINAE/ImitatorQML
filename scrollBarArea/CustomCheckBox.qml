import QtQuick 2.12
import QtQuick.Controls 2.12

CheckBox {
    id: customCheckBox

    // Уменьшаем размер индикатора
    indicator: Rectangle {
        implicitWidth: 12
        implicitHeight: 12
        x: customCheckBox.leftPadding
        y: parent.height / 2 - height / 2
        radius: 2
        border.color: customCheckBox.enabled ? "black" : "#666666"  // Черная рамка когда enabled
        border.width: 1
        color: customCheckBox.enabled ? "#D3D3D3" : "#AAAAAA"    // Серый фон (lightgray) когда enabled

        // Галочка (черная когда checked)
        Canvas {
            anchors.fill: parent
            visible: customCheckBox.checked
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = "black";  // Черная галочка
                ctx.lineWidth = 2;          // Толще линия
                ctx.beginPath();
                ctx.moveTo(2, 6);           // Начинаем левее
                ctx.lineTo(5, 9);           // Идем вниз-вправо
                ctx.lineTo(10, 2);          // Заканчиваем в правом нижнем углу
                ctx.stroke();
            }
        }
    }

    // Уменьшаем отступы и размер текста
    contentItem: Text {
        text: customCheckBox.text
        font.pointSize: 8
        font.bold: true
        color: customCheckBox.enabled ?
               (customCheckBox.checked ? "#00FF00" : "white") : "#666666"  // Белый когда enabled но не checked
        verticalAlignment: Text.AlignVCenter
        leftPadding: customCheckBox.indicator.width + 4
        elide: Text.ElideRight
    }
}
