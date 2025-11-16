import QtQuick 2.12
import QtQuick.Controls 2.12
import "scrollBarArea"
import QtQml 2.12

Rectangle {
    id: tabArea
    objectName: "tabArea"
    color: "#2D2D30"

    // Связываем свойства с UiModel
    property alias pagesModel: buttonListView.model
    property alias currentPageSource: pageLoader.source

    // Данные из UiModel
    property var currentPageData: uiModel.currentPageData
    property string currentPageName: uiModel.currentPageName
    property color currentPageColor: uiModel.currentPageColor

    // Сигнал для сбора данных (для обратной совместимости)
    signal pageDataChanged(string pageName, var collectedData)

    // Компоненты
    PagesListView {
        id: buttonListView
        anchors {
            top: parent.top
            topMargin: 8
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
        }

        // Модель страниц из UiModel
        model: ListModel {
            id: pagesListModel
        }

        onPageClicked: function(index) {
            console.log("Page clicked, visual index:", index, "name:", pagesListModel.get(index).pageName)

            var pageName = pagesListModel.get(index).pageName

            // Способ 1: Используем метод findPageIndex из UiModel
            if (typeof uiModel.findPageIndex !== 'undefined') {
                var modelIndex = uiModel.findPageIndex(pageName)
                console.log("Found page index via findPageIndex:", modelIndex)
                if (modelIndex !== -1) {
                    uiModel.loadPageByIndex(modelIndex)
                    return
                }
            }

            // Способ 2: Используем прямой поиск в pageNames
            var modelIndex = uiModel.pageNames.indexOf(pageName)
            console.log("Found page index via pageNames:", modelIndex)
            if (modelIndex !== -1) {
                uiModel.loadPageByIndex(modelIndex)
            } else {
                console.error("Page not found in UiModel:", pageName, "Available pages:", uiModel.pageNames)
                // Попробуем загрузить страницу по имени напрямую
                console.log("Trying to load page by name directly...")
                uiModel.loadPage(pageName)
            }
        }

        onPageAddClicked: function(index, newPageName) {
            console.log("Page add clicked, index:", index, "new name:", newPageName)
            var pageName = pagesListModel.get(index).pageName

            var modelIndex = -1
            if (typeof uiModel.findPageIndex !== 'undefined') {
                modelIndex = uiModel.findPageIndex(pageName)
            } else {
                modelIndex = uiModel.pageNames.indexOf(pageName)
            }

            if (modelIndex !== -1) {
                uiModel.duplicatePage(modelIndex)
            } else {
                console.error("Cannot duplicate - page not found in UiModel:", pageName)
            }
        }

        onPageDeleteClicked: function(index) {
            console.log("Page delete clicked, index:", index)
            var pageName = pagesListModel.get(index).pageName

            var modelIndex = -1
            if (typeof uiModel.findPageIndex !== 'undefined') {
                modelIndex = uiModel.findPageIndex(pageName)
            } else {
                modelIndex = uiModel.pageNames.indexOf(pageName)
            }

            if (modelIndex !== -1) {
                uiModel.deletePage(modelIndex)
            } else {
                console.error("Cannot delete - page not found in UiModel:", pageName)
            }
        }
    }

    PagesScrollBar {
        listView: buttonListView
        anchors {
            left: buttonListView.left
            right: buttonListView.right
            top: buttonListView.bottom
            topMargin: 1
        }
    }

    BlueStrip {
        id: blueStrip
        anchors {
            left: parent.left
            right: parent.right
            top: buttonListView.bottom
            topMargin: 6
            leftMargin: 25
            rightMargin: 25
        }
    }

    // PageLoader
    PageLoader {
        id: pageLoader
        anchors {
            top: blueStrip.bottom
            topMargin: 12
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
            bottom: parent.bottom
            bottomMargin: 10
        }

        pageColor: tabArea.currentPageColor
        pageData: tabArea.currentPageData
        pageName: tabArea.currentPageName

        onPageContentChanged: {
            // Собираем данные при изменении на странице
            var collectedData = uiModel.collectPageData()
            // Эмитим сигнал для обратной совместимости
            pageDataChanged(tabArea.currentPageName, collectedData)
        }
    }

    // Состояние когда нет страниц
    Text {
        id: noPagesText
        anchors.centerIn: parent
        text: "Нет доступных страниц\nОткройте окно сообщений для выбора страниц"
        color: "white"
        font.pointSize: 14
        horizontalAlignment: Text.AlignHCenter
        visible: pagesListModel.count === 0
    }

    // Функция для обновления модели страниц
    function updateModel() {
        console.log("=== UPDATING PAGES MODEL ===")
        var oldCount = pagesListModel.count
        pagesListModel.clear()
        var pageNames = uiModel.pageNames
        console.log("Page names from UiModel:", pageNames)
        console.log("UiModel pageNames length:", pageNames.length)

        if (pageNames && pageNames.length > 0) {
            for (var i = 0; i < pageNames.length; i++) {
                var pageName = pageNames[i]
                if (pageName && pageName !== "") {
                    pagesListModel.append({
                        pageName: pageName,
                        pageNumber: 1
                    })
                    console.log("Added page to model:", pageName)
                } else {
                    console.warn("Skipping empty page name at index:", i)
                }
            }
        } else {
            console.log("No pages in UiModel")
        }

        console.log("Updated pages model - was:", oldCount, "now:", pagesListModel.count)

        // Обновляем видимость текста "нет страниц"
        noPagesText.visible = pagesListModel.count === 0

        // Проверяем синхронизацию
        if (pagesListModel.count !== uiModel.pageNames.length) {
            console.error("MODEL SYNC ERROR: Visual count", pagesListModel.count,
                         "!= UiModel count", uiModel.pageNames.length)
        } else {
            console.log("Model synchronization OK")
        }

        // Логируем содержимое обеих моделей для отладки
        console.log("UiModel pages:", uiModel.pageNames)
        console.log("Visual model pages:")
        for (var j = 0; j < pagesListModel.count; j++) {
            console.log("  " + j + ":", pagesListModel.get(j).pageName)
        }
        console.log("=== MODEL UPDATE COMPLETE ===")
    }

    // Функция для получения имени страницы по индексу (для обратной совместимости)
    function getPageName(index) {
        if (pagesListModel && pagesListModel.get && index >= 0 && index < pagesListModel.count) {
            var item = pagesListModel.get(index)
            if (item) {
                return item.pageName + (item.pageNumber > 1 ? " - " + item.pageNumber : "")
            }
        }
        return "Страница " + (index + 1)
    }

    // Функция для получения базового имени страницы (для обратной совместимости)
    function getBasePageName(fullPageName) {
        var baseName = fullPageName
        var dashIndex = baseName.indexOf(" - ")
        if (dashIndex !== -1) {
            baseName = baseName.substring(0, dashIndex)
        }
        return baseName
    }

    // Функция для загрузки данных страницы по имени (для обратной совместимости)
    function loadPageData(pageName) {
        console.log("Loading page data for:", pageName)
        uiModel.loadPage(pageName)
    }

    // Функция для создания новой страницы (для обратной совместимости)
    function createNewPage() {
        uiModel.createNewPage("Новая страница")
    }

    // Функция для удаления страницы (для обратной совместимости)
    function deletePage(index) {
        var pageName = pagesListModel.get(index).pageName
        console.log("Deleting page:", pageName, "at visual index:", index)

        var modelIndex = -1
        if (typeof uiModel.findPageIndex !== 'undefined') {
            modelIndex = uiModel.findPageIndex(pageName)
        } else {
            modelIndex = uiModel.pageNames.indexOf(pageName)
        }

        if (modelIndex !== -1) {
            uiModel.deletePage(modelIndex)
        } else {
            console.error("Cannot delete - page not found in UiModel:", pageName)
        }
    }

    // Функция для генерации имени копии (для обратной совместимости)
    function generateCopyName(originalName) {
        return uiModel.generateCopyName(originalName)
    }

    // Функция для сбора данных со страницы (для обратной совместимости)
    function collectPageData() {
        return uiModel.collectPageData()
    }

    // Функция для очистки содержимого (для обратной совместимости)
    function clearContent() {
        console.log("Clear content requested")
    }

    // Инициализация
    Component.onCompleted: {
        console.log("=== TABAREA COMPONENT COMPLETED ===")
        console.log("UiModel initialized:", uiModel.isInitialized)
        console.log("UiModel has pages:", uiModel.hasPages)
        console.log("UiModel page names:", uiModel.pageNames)
        console.log("JsonParser has data:", jsonParser.hasData)

        // Подключаем сигналы от UiModel
        uiModel.pageNamesChanged.connect(function() {
            console.log("UiModel: pageNamesChanged signal received")
            updateModel()
        })

        uiModel.pagesSynchronized.connect(function() {
            console.log("UiModel: pagesSynchronized signal received")
            updateModel()
        })

        uiModel.pageAdded.connect(function(pageName) {
            console.log("UiModel: pageAdded signal -", pageName)
            updateModel()
        })

        uiModel.pageRemoved.connect(function(index) {
            console.log("UiModel: pageRemoved signal - index:", index)
            updateModel()
        })

        uiModel.pageLoaded.connect(function(pageName) {
            console.log("UiModel: pageLoaded signal -", pageName)
            console.log("Current page data items:", currentPageData && currentPageData.items ? currentPageData.items.length : 0)

            // Подсвечиваем активную страницу в визуальном списке
            updateActivePageHighlight()
        })

        uiModel.currentPageIndexChanged.connect(function() {
            console.log("UiModel: currentPageIndexChanged -", uiModel.currentPageIndex)
            updateActivePageHighlight()
        })

        uiModel.pageDataCollected.connect(function(pageName, data) {
            console.log("UiModel: pageDataCollected signal -", pageName, "items:", data.items ? data.items.length : 0)
            pageDataChanged(pageName, data)
        })

        // Инициализируем модель если UiModel уже готов
        if (uiModel.isInitialized) {
            console.log("UiModel already initialized, updating pages model")
            updateModel()
        } else {
            console.log("Waiting for UiModel initialization...")
            uiModel.isInitializedChanged.connect(function() {
                if (uiModel.isInitialized) {
                    console.log("UiModel initialized signal received, updating pages model")
                    updateModel()
                }
            })
        }

        // Подключаем сигнал dataLoaded от JsonParser
        jsonParser.dataLoaded.connect(function() {
            console.log("JsonParser: dataLoaded signal received")
            console.log("Available pages in parser:", jsonParser.getAvailablePages().length)
        })
    }

    // Функция для обновления подсветки активной страницы
    function updateActivePageHighlight() {
        console.log("Updating active page highlight, current index:", uiModel.currentPageIndex)
    }
}
