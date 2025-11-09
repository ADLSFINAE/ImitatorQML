import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

Item {
    id: gridContainer

    property var layoutConfig: ({})
    property var items: []

    Component.onCompleted: {
        console.log("Creating grid with", items.length, "items")
        createItems()
    }

    onItemsChanged: createItems()

    function createItems() {
        // Очищаем контейнер
        for (var i = children.length - 1; i >= 0; i--) {
            children[i].destroy()
        }

        // Создаем элементы
        for (var j = 0; j < items.length; j++) {
            var itemData = items[j]
            if (!itemData) continue

            var position = itemData.position || {x: 1, y: j + 1, width: 1, height: 1}

            // Вычисляем позицию и размеры
            var xPos = (position.x - 1) * (width / (layoutConfig.columns || 1))
            var yPos = (position.y - 1) * (height / (layoutConfig.rows || 1))
            var itemWidth = (position.width || 1) * (width / (layoutConfig.columns || 1))
            var itemHeight = (position.height || 1) * (height / (layoutConfig.rows || 1))

            if (itemData.type === "group") {
                createGroup(itemData, xPos, yPos, itemWidth, itemHeight)
            } else {
                createSingleItem(itemData, xPos, yPos, itemWidth, itemHeight)
            }
        }
    }

    function createGroup(groupData, x, y, width, height) {
        var component = Qt.createComponent("GroupItem.qml")
        if (component.status === Component.Ready) {
            var groupItem = component.createObject(gridContainer, {
                "x": x + 2,
                "y": y + 2,
                "width": width - 4,
                "height": height - 4,
                "groupData": groupData
            })
            console.log("Created group:", groupData.name)
        } else {
            console.error("Error creating group:", component.errorString())
        }
    }

    function createSingleItem(itemData, x, y, width, height) {
        var component = Qt.createComponent("SingleItem.qml")
        if (component.status === Component.Ready) {
            var singleItem = component.createObject(gridContainer, {
                "x": x + 2,
                "y": y + 2,
                "width": width - 4,
                "height": height - 4,
                "itemData": itemData
            })
            console.log("Created item:", itemData.name)
        } else {
            console.error("Error creating item:", component.errorString())
        }
    }
}
