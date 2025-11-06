import QtQuick 2.12
import "."

Rectangle {
    id: pageTabBar
    color: "transparent"

    property ListModel pagesModel

    ListView {
        id: tabListView
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: 5
        clip: true

        interactive: contentWidth > width
        flickableDirection: contentWidth > width ? Flickable.HorizontalFlick : Flickable.AutoFlickDirection
        boundsBehavior: contentWidth > width ? Flickable.StopAtBounds : Flickable.StopAtBounds

        model: pagesModel

        delegate: PageTabDelegate {
            pageName: model.pageName
            pageNumber: model.pageNumber
            onPageClicked: console.log("Page clicked:", model.pageName)
            onAddClicked: addPageClone(model.pageName, model.index)
            onDeleteClicked: pagesModel.remove(model.index)
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            enabled: tabListView.contentWidth > tabListView.width
            onWheel: {
                if (wheel.angleDelta.y > 0) {
                    tabListView.contentX = Math.max(0, tabListView.contentX - 50)
                } else {
                    tabListView.contentX = Math.min(tabListView.contentWidth - tabListView.width, tabListView.contentX + 50)
                }
            }
        }
    }

    PageTabScrollBar {
        anchors {
            left: tabListView.left
            right: tabListView.right
            top: tabListView.bottom
            topMargin: 1
        }
        listView: tabListView
    }

    function addPageClone(baseName, index) {
        var newPageNumber = 1
        for (var i = 0; i < pagesModel.count; i++) {
            if (pagesModel.get(i).pageName === baseName) {
                newPageNumber = Math.max(newPageNumber, pagesModel.get(i).pageNumber + 1)
            }
        }
        pagesModel.insert(index + 1, {"pageName": baseName, "pageNumber": newPageNumber})
    }
}
