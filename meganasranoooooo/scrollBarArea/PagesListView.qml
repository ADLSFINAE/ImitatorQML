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
    signal pageAddClicked(int index, string newPageName)
    signal pageDeleteClicked(int index)

    model: ListModel {
        id: defaultModel
        // Начинаем с пустого списка страниц
    }

    delegate: PageButton {
        pageName: model.pageName
        pageNumber: model.pageNumber

        onClicked: {
            pagesListView.pageClicked(index)
        }

        onAddPage: {
            var currentItem = pagesListView.model.get(index)

            // Получаем полное имя текущей страницы
            var currentFullName = currentItem.pageName + (currentItem.pageNumber > 1 ? " - " + currentItem.pageNumber : "")

            // Генерируем имя для новой страницы через tabArea
            var newPageName = tabArea.generateCopyName(currentFullName)

            // Создаем новую страницу с базовым именем и номером 1
            var itemCopy = {
                pageName: newPageName,
                pageNumber: 1
            }

            pagesListView.model.insert(index + 1, itemCopy)
            pagesListView.pageAddClicked(index, newPageName)
        }

        onDeletePage: {
            pagesListView.pageDeleteClicked(index)
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
