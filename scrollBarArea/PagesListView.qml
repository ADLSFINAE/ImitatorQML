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

    model: ListModel {
        id: defaultModel
        ListElement { pageName: "Страница 1"; pageNumber: 1 }
        ListElement { pageName: "Страница 2"; pageNumber: 1 }
        ListElement { pageName: "Страница 3"; pageNumber: 1 }
        ListElement { pageName: "Страница 4"; pageNumber: 1 }
    }

    delegate: PageButton {
        pageName: model.pageName
        pageNumber: model.pageNumber

        onClicked: {
            pagesListView.pageClicked(index)
        }

        onAddPage: {
            var newPageNumber = 1
            for (var i = 0; i < pagesListView.model.count; i++) {
                if (pagesListView.model.get(i).pageName === pageName) {
                    newPageNumber = Math.max(newPageNumber, pagesListView.model.get(i).pageNumber + 1)
                }
            }
            pagesListView.model.insert(index + 1, {"pageName": pageName, "pageNumber": newPageNumber})
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
