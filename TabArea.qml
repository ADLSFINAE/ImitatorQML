import QtQuick 2.12
import QtQuick.Controls 2.12
import "scrollBarArea"
import QtQml 2.12

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

    // Сигнал для сбора данных при изменении
    signal pageDataChanged(string pageName, var collectedData)

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

        // Собираем данные при изменении на странице
        onPageContentChanged: {
            collectPageData()
        }
    }

    // Функция для сбора всех данных со страницы
    function collectPageData() {
        if (!currentPageData || !currentPageName) return;

        var collectedData = {
            pageName: currentPageName,
            basePageName: getBasePageName(currentPageName),
            timestamp: new Date().toISOString(),
            items: []
        };

        // Получаем базовую структуру страницы
        var baseName = getBasePageName(currentPageName);
        var basePageData = pagesData[baseName];

        if (!basePageData || !basePageData.items) {
            console.log("No base data found for page:", baseName);
            return;
        }

        // Собираем данные в порядке из JSON
        for (var i = 0; i < basePageData.items.length; i++) {
            var itemConfig = basePageData.items[i];
            var itemData = collectItemData(itemConfig);
            if (itemData) {
                collectedData.items.push(itemData);
            }
        }

        // Выводим собранные данные
        console.log("=== COLLECTED PAGE DATA ===");
        console.log("Page:", currentPageName);
        console.log("Base Page:", baseName);
        console.log("Items count:", collectedData.items.length);

        for (var j = 0; j < collectedData.items.length; j++) {
            var item = collectedData.items[j];
            console.log("Item", j + 1 + ":", item.name, "=", item.value, "(type:", item.type + ")");
        }

        console.log("=== END PAGE DATA ===");

        // Отправляем сигнал
        pageDataChanged(currentPageName, collectedData);
    }

    // Функция для сбора данных отдельного элемента
    function collectItemData(itemConfig) {
        if (!itemConfig) return null;

        var itemData = {
            name: itemConfig.name || "",
            type: itemConfig.type || "",
            label: itemConfig.label || "",
            enabled: true, // Будет обновлено из состояния UI
            value: ""
        };

        // Получаем текущее значение из UI
        // Для этого нужно найти соответствующий компонент на странице
        var component = findComponentByName(itemConfig.name);
        if (component) {
            itemData.enabled = component.enabled !== undefined ? component.enabled : true;
            itemData.value = getComponentValue(component, itemConfig.type);
        } else {
            // Если компонент не найден, используем значения по умолчанию
            itemData.enabled = itemConfig.enabled !== undefined ? itemConfig.enabled : true;
            itemData.value = itemConfig.default || "";
        }

        return itemData;
    }

    // Функция для поиска компонента по имени
    function findComponentByName(name) {
        // Ищем в PageLoader'е компонент с указанным именем
        // Это упрощенная реализация - в реальности нужно пройти по всем детям
        if (pageLoader && pageLoader.item) {
            return findChildByName(pageLoader.item, name);
        }
        return null;
    }

    // Рекурсивный поиск по дереву компонентов
    function findChildByName(parent, name) {
        if (!parent) return null;

        // Проверяем текущий компонент
        if (parent.fieldName === name || parent.objectName === name) {
            return parent;
        }

        // Рекурсивно проверяем детей
        for (var i = 0; i < parent.children.length; i++) {
            var child = parent.children[i];
            var found = findChildByName(child, name);
            if (found) return found;
        }

        return null;
    }

    // Функция для получения значения из компонента по его типу
    function getComponentValue(component, type) {
        if (!component) return "";

        switch(type) {
            case "textfield":
                return component.textInput ? component.textInput.text :
                       (component.text !== undefined ? component.text : "");

            case "combobox":
                return component.currentText !== undefined ? component.currentText :
                       (component.displayText !== undefined ? component.displayText : "");

            case "checkbox":
                return component.checked !== undefined ? component.checked.toString() : "false";

            case "radiobutton":
                return component.selectedValue !== undefined ? component.selectedValue : "";

            default:
                return "";
        }
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
            clearContent()
        }

        pageDataChanged.connect(function(pageName, data) {
            console.log("Page data changed for:", pageName);
        });
    }

    function initializePagesData() {
        pagesData = {}

        var availableData = getAvailablePagesData()

        // Проверяем, что данные есть и это объект
        if (availableData && typeof availableData === 'object') {
            for (var dataKey in availableData) {
                var pageData = availableData[dataKey]
                if (pageData && pageData.pageName) {
                    var baseName = getBasePageName(pageData.pageName)
                    pagesData[baseName] = JSON.parse(JSON.stringify(pageData))
                }
            }
            console.log("Successfully initialized pages data, total pages:", Object.keys(pagesData).length)
        } else {
            console.log("No valid pages data available")
        }
    }

    function getAvailablePagesData() {
        var jsonContent = loadJsonFileContent()
        try {
            // Парсим JSON строку в объект
            return JSON.parse(jsonContent)
        } catch (error) {
            console.log("Error parsing JSON, using fallback data:", error.toString())
            return getFallbackPagesData()
        }
    }

    // Функция для загрузки сырого содержимого JSON файла
    function loadJsonFileContent() {
        try {
            var xhr = new XMLHttpRequest();
            var url = "qrc:/JsonDocuments/example.json";

            console.log("Loading JSON file from:", url);

            // Синхронный запрос
            xhr.open("GET", url, false);
            xhr.send();

            if (xhr.status === 200 || xhr.status === 0) {
                var jsonContent = xhr.responseText;
                console.log("Successfully loaded JSON file, content length:", jsonContent.length);
                return jsonContent;
            } else {
                console.log("Failed to load JSON file. Status:", xhr.status);
                return JSON.stringify(getFallbackPagesData());
            }
        } catch (error) {
            console.log("Error loading JSON file:", error.toString());
            return JSON.stringify(getFallbackPagesData());
        }
    }
}
