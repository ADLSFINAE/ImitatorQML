import QtQuick 2.12
import QtQuick.Controls 2.12

ListView {
    id: pagesListView
    height: 30
    orientation: ListView.Horizontal
    spacing: 5
    clip: true

    interactive: contentWidth > width
    flickableDirection: contentWidth > width ? Flickable.HorizontalFlick : Flickable.AutoFlickDirection
    boundsBehavior: contentWidth > width ? Flickable.StopAtBounds : Flickable.StopAtBounds

    // Сигнал при клике на страницу
    signal pageClicked(int index)
    signal pageAddClicked(int index)

    model: ListModel {
        id: defaultModel
    }

    delegate: PageButton {
        pageName: model.pageName
        pageNumber: model.pageNumber

        onClicked: {
            pagesListView.pageClicked(index)

        }

        onAddPage: {
            var currentItem = pagesListView.model.get(index)

            var newPageNumber = 1
            for (var i = 0; i < pagesListView.model.count; i++) {
                if (pagesListView.model.get(i).pageName === pageName) {
                    newPageNumber = Math.max(newPageNumber, pagesListView.model.get(i).pageNumber + 1)
                }
            }

            // Создаем копию объекта и меняем pageNumber
            var itemCopy = Object.assign({}, currentItem)
            itemCopy.pageNumber = newPageNumber

            pagesListView.model.insert(index + 1, itemCopy)
            pagesListView.pageAddClicked(index)
        }

        onDeletePage: {
            pagesListView.model.remove(index)
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        enabled: pagesListView.contentWidth > pagesListView.width
        onWheel: {
            if (wheel.angleDelta.y > 0) {
                pagesListView.contentX = Math.max(0, pagesListView.contentX - 50)
            } else {
                pagesListView.contentX = Math.min(pagesListView.contentWidth - pagesListView.width, pagesListView.contentX + 50)
            }
        }
    }

    onContentWidthChanged: {
        if (contentWidth <= width) {
            contentX = 0
        }
    }
}
