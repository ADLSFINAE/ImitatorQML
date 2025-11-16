import QtQuick 2.12
import QtQuick.Controls 2.12
import "scrollBarArea"

Rectangle {
    id: tabArea
    objectName: "tabArea"
    color: "#2D2D30"

    // Свойства для настройки (из старого кода)
    property alias pagesModel: buttonListView.model
    property alias currentPageSource: pageLoader.source

    // Свойство для хранения цвета
    property color currentPageColor: "blue"

    // Новые свойства для данных
    property var currentPageData: ({})
    property string currentPageName: ""
    property var pagesData: ({})

    // Компоненты (старый код)
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

        onPageClicked: function(index) {
            var pageName = getPageName(index)
            loadPageData(pageName)

            // Старая логика цвета
            var colors = ["blue", "green", "red", "purple", "orange", "teal"]
            currentPageColor = colors[index % colors.length]
        }

        onPageAddClicked: function(index, newPageName) {
            var originalPageName = getPageName(index)
            var originalBaseName = getBasePageName(originalPageName)

            // Автоматически загружаем данные для новой страницы
            loadPageData(newPageName)

            console.log("Created copy:", newPageName, "from:", originalPageName, "(base:", originalBaseName + ")")
        }

        onPageDeleteClicked: function(index) {
            deletePage(index)
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

    // Старый PageLoader с новой логикой данных
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

        // Передаем текущий цвет в PageLoader (старая логика)
        pageColor: tabArea.currentPageColor

        // Новая логика - передаем данные для отображения
        pageData: tabArea.currentPageData
        pageName: tabArea.currentPageName
    }

    // Старая функция для получения источника страницы
    function getPageSource(index) {
        var pageNames = ["Page1", "Page2", "Page3", "Page4"];
        if (index >= 0 && index < pageNames.length) {
            return "qrc:/Pages/" + pageNames[index] + ".qml";
        }
        return "qrc:/Pages/Page1.qml";
    }

    // НОВЫЕ ФУНКЦИИ ДЛЯ РАБОТЫ С ДАННЫМИ

    // Функция для получения имени страницы по индексу
    function getPageName(index) {
        if (buttonListView.model && buttonListView.model.get && index >= 0 && index < buttonListView.model.count) {
            var item = buttonListView.model.get(index)
            if (item) {
                return item.pageName + (item.pageNumber > 1 ? " - " + item.pageNumber : "")
            }
        }
        return "Страница " + (index + 1)
    }

    // Функция для получения базового имени страницы (без номера копии)
    function getBasePageName(fullPageName) {
        var baseName = fullPageName
        var dashIndex = baseName.indexOf(" - ")
        if (dashIndex !== -1) {
            baseName = baseName.substring(0, dashIndex)
        }
        return baseName
    }

    // Функция для загрузки данных страницы по имени
    function loadPageData(pageName) {
        var baseName = getBasePageName(pageName)

        if (pagesData[baseName]) {
            // Используем данные базовой страницы
            currentPageData = JSON.parse(JSON.stringify(pagesData[baseName]))
            currentPageData.pageName = pageName
            currentPageName = pageName
            console.log("Loaded data from base page:", baseName, "for page:", pageName)
        } else {
            // Если данных нет - пустая страница
            currentPageData = {}
            currentPageName = pageName
            console.log("No data for page:", pageName, "(base:", baseName + ")")
        }
    }

    // Функция для генерации имени копии
    function generateCopyName(originalName) {
        var baseName = getBasePageName(originalName)
        var copyNumber = 1

        // Считаем сколько уже есть копий с таким базовым именем
        if (buttonListView.model) {
            for (var i = 0; i < buttonListView.model.count; i++) {
                var item = buttonListView.model.get(i)
                var itemBaseName = getBasePageName(item.pageName + (item.pageNumber > 1 ? " - " + item.pageNumber : ""))
                if (itemBaseName === baseName) {
                    copyNumber++
                }
            }
        }

        var newName = baseName
        if (copyNumber > 1) {
            newName += " - " + copyNumber
        }

        return newName
    }

    // Функция для удаления страницы (теперь можно удалять последнюю)
    function deletePage(index) {
        var pageNameToDelete = getPageName(index)
        console.log("Deleting page:", pageNameToDelete, "at index:", index)

        // Удаляем страницу из модели
        buttonListView.model.remove(index)

        // Проверяем, была ли это последняя страница
        if (buttonListView.model.count === 0) {
            // Если удалили последнюю страницу - очищаем содержимое
            clearContent()
            console.log("Last page deleted - content cleared")
        } else {
            // Если остались страницы, переключаемся на другую
            if (currentPageName === pageNameToDelete) {
                var newIndex = Math.min(index, buttonListView.model.count - 1)
                if (newIndex >= 0) {
                    var newPageName = getPageName(newIndex)
                    loadPageData(newPageName)
                    console.log("Switched to page:", newPageName)
                }
            }
        }
    }

    // Функция для очистки содержимого при удалении всех страниц
    function clearContent() {
        currentPageData = {}
        currentPageName = ""
        console.log("All pages deleted - content cleared")
    }

    // Функция для создания новой пустой страницы
    function createNewPage() {
        var newPageName = "Новая страница"
        buttonListView.model.append({pageName: newPageName, pageNumber: 1})
        loadPageData(newPageName)
        console.log("Created new page:", newPageName)
    }

    // Инициализация - загружаем данные для существующих страниц
    Component.onCompleted: {
        initializePagesData()

        // Загружаем первую страницу если есть
        if (buttonListView.model && buttonListView.model.count > 0) {
            var firstName = getPageName(0)
            loadPageData(firstName)
        } else {
            // Если страниц нет, очищаем содержимое
            clearContent()
        }
    }

    // Функция инициализации данных страниц
    function initializePagesData() {
        pagesData = {}

        var availableData = getAvailablePagesData()

        // Сохраняем данные по базовым именам
        for (var dataKey in availableData) {
            var pageData = availableData[dataKey]
            var baseName = getBasePageName(pageData.pageName)
            pagesData[baseName] = JSON.parse(JSON.stringify(pageData))
            console.log("Stored data for base page:", baseName)
        }

        console.log("Available base pages:", Object.keys(pagesData))
    }

    // Функция для получения доступных данных страниц
    function getAvailablePagesData() {
        return {
            "page1": {
                "pageName": "Страница 1 - Основные настройки",
                "layout": {
                    "columns": 6,
                    "rows": 4,
                    "cellWidth": 200,
                    "cellHeight": 80
                },
                "items": [
                    {
                        "type": "textfield",
                        "name": "deviceName",
                        "label": "Имя устройства",
                        "placeholder": "Введите имя устройства",
                        "default": "NMEA Simulator",
                        "enabled": true,
                        "description": "Уникальное имя устройства",
                        "position": {"x": 1, "y": 1, "width": 3, "height": 1}
                    },
                    {
                        "type": "group",
                        "name": "serialGroup",
                        "label": "Настройки порта",
                        "enabled": true,
                        "position": {"x": 1, "y": 2, "width": 3, "height": 2},
                        "items": [
                            {
                                "type": "textfield",
                                "name": "port",
                                "label": "Порт",
                                "placeholder": "COM1, COM2, ...",
                                "default": "COM1",
                                "description": "Имя последовательного порта"
                            },
                            {
                                "type": "combobox",
                                "name": "baudrate",
                                "label": "Скорость",
                                "options": ["4800", "9600", "19200", "38400", "57600", "115200"],
                                "default": "9600",
                                "description": "Скорость передачи (бод)"
                            }
                        ]
                    },
                    {
                        "type": "checkbox",
                        "name": "enableLogging",
                        "label": "Логирование",
                        "default": "true",
                        "enabled": false,
                        "description": "Записывать данные в файл",
                        "position": {"x": 4, "y": 1, "width": 2, "height": 1}
                    }
                ]
            },
            "page2": {
                "pageName": "Страница 2 - Сообщения NMEA",
                "layout": {
                    "columns": 4,
                    "rows": 3,
                    "cellWidth": 250,
                    "cellHeight": 90
                },
                "items": [
                    {
                        "type": "group",
                        "name": "nmeaMessages",
                        "label": "NMEA сообщения",
                        "enabled": true,
                        "position": {"x": 1, "y": 1, "width": 2, "height": 2},
                        "items": [
                            {
                                "type": "checkbox",
                                "name": "enableGGA",
                                "label": "GGA",
                                "default": "true",
                                "description": "Фиксированные данные о местоположении"
                            },
                            {
                                "type": "checkbox",
                                "name": "enableRMC",
                                "label": "RMC",
                                "default": "true",
                                "description": "Рекомендуемые минимальные данные GPS"
                            },
                            {
                                "type": "checkbox",
                                "name": "enableGLL",
                                "label": "GLL",
                                "default": "false",
                                "description": "Данные о широте и долготе"
                            }
                        ]
                    },
                    {
                        "type": "textfield",
                        "name": "updateRate",
                        "label": "Частота обновления",
                        "placeholder": "секунды",
                        "default": "1",
                        "enabled": true,
                        "description": "Интервал между сообщениями",
                        "position": {"x": 3, "y": 1, "width": 1, "height": 1}
                    }
                ]
            }
        }
    }
}
