import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import AppModels 1.0

ApplicationWindow {
    id: window
    width: 600
    height: 700
    visible: true
    title: "Многостраничное приложение"

    property int currentPageIndex: 0
    property int pageCounter: 0

    ListModel {
        id: pagesModel
    }

    // Окно управления страницами
    PageManagerWindow {
        id: pageManagerWindow
        pagesModel: pagesModel
        selectedPageIndex: currentPageIndex
        visible: false

        onPageSelected: {
            currentPageIndex = index
            pageManagerWindow.visible = false
            console.log("Выбрана страница:", index + 1)
        }
    }

    // Инициализация начальных страниц
    Component.onCompleted: {
        for (var i = 0; i < 3; i++) {
            addNewPage()
        }
    }

    // Функция для добавления новой страницы
    function addNewPage() {
        pageCounter++
        var pageNumber = pageCounter

        // Создаем новую модель для страницы
        var newModel = Qt.createQmlObject('
            import AppModels 1.0;
            DisplayModel {}', window)

        // Добавляем страницу в модель
        pagesModel.append({
            "pageModel": newModel,
            "pageName": "Страница " + pageNumber,
            "pageNumber": pageNumber
        })

        // Переключаемся на новую страницу
        currentPageIndex = pagesModel.count - 1

        console.log("Добавлена новая страница:", pageNumber, "Всего страниц:", pagesModel.count)
    }

    // Функция для загрузки данных на текущую страницу
    function loadDataToCurrentPage() {
        if (currentPageIndex < 0 || currentPageIndex >= pagesModel.count) {
            console.log("Нет активной страницы")
            return
        }

        var pageData = pagesModel.get(currentPageIndex)
        var currentModel = pageData.pageModel
        var pageNumber = pageData.pageNumber

        var testData = getTestDataForPage(pageNumber)

        // Временное соединение для загрузки данных в текущую модель
        var connection = function() {
            currentModel.setItems(jsonParser.getItems(), jsonParser.getPageName())
            jsonParser.dataLoaded.disconnect(connection)
            console.log("Данные загружены на страницу:", pageNumber)
        }

        jsonParser.dataLoaded.connect(connection)
        jsonParser.loadJson(testData)
    }

    function getTestDataForPage(pageNumber) {
        var baseData = {
            1: {
                "pageName": "Главная страница",
                "items": [
                    {"name": "welcome", "text": "Добро пожаловать!", "color": "blue"},
                    {"name": "info", "text": "Это главная страница приложения", "color": "green"},
                    {"name": "tip", "text": "Используйте кнопку 'Управление страницами'", "color": "orange"}
                ]
            },
            2: {
                "pageName": "Настройки",
                "items": [
                    {"name": "setting1", "text": "Настройка языка интерфейса", "color": "purple"},
                    {"name": "setting2", "text": "Настройка темы оформления", "color": "darkblue"},
                    {"name": "setting3", "text": "Настройка уведомлений", "color": "darkgreen"}
                ]
            },
            3: {
                "pageName": "Справка",
                "items": [
                    {"name": "help1", "text": "Для загрузки данных нажмите кнопку 'Загрузить данные'", "color": "red"},
                    {"name": "help2", "text": "Данные загружаются только на активную страницу", "color": "brown"},
                    {"name": "help3", "text": "Каждая страница имеет свою собственную модель", "color": "teal"}
                ]
            }
        }

        if (pageNumber > 3) {
            return JSON.stringify({
                "pageName": "Страница " + pageNumber,
                "items": [
                    {"name": "new1", "text": "Это новая страница " + pageNumber, "color": getRandomColor()},
                    {"name": "new2", "text": "Динамически созданная страница", "color": getRandomColor()},
                    {"name": "new3", "text": "Можно загружать разные данные", "color": getRandomColor()}
                ]
            })
        }

        return JSON.stringify(baseData[pageNumber])
    }

    function getRandomColor() {
        var colors = ["red", "blue", "green", "purple", "orange", "teal", "brown", "pink", "cyan", "magenta"]
        return colors[Math.floor(Math.random() * colors.length)]
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Верхняя панель управления
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#e0e0e0"
            border.color: "#cccccc"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // Кнопка открытия менеджера страниц
                Button {
                    text: "Управление страницами"
                    onClicked: pageManagerWindow.visible = true
                    Layout.preferredWidth: 150
                }

                // Информация о текущей странице
                Label {
                    text: "Текущая страница: " + (pagesModel.count > 0 ? pagesModel.get(currentPageIndex).pageName : "Нет страниц")
                    font.bold: true
                    Layout.fillWidth: true
                }

                // Кнопка загрузки данных на текущую страницу
                Button {
                    text: "Загрузить данные"
                    onClicked: loadDataToCurrentPage()
                    Layout.preferredWidth: 120
                    enabled: pagesModel.count > 0
                }

                // Информация о количестве страниц
                Label {
                    text: "Страниц: " + pagesModel.count
                    color: "gray"
                    Layout.preferredWidth: 80
                }
            }
        }

        // Основная область контента
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"

            StackLayout {
                id: stackLayout
                anchors.fill: parent
                anchors.margins: 10
                currentIndex: currentPageIndex

                // Динамические страницы через Repeater
                Repeater {
                    model: pagesModel

                    PageContent {
                        displayModel: pageModel
                        pageNumber: pageNumber
                        pageName: pageName
                    }
                }

                // Заглушка если нет страниц
                Item {
                    Column {
                        anchors.centerIn: parent
                        spacing: 20

                        Label {
                            text: "Нет страниц"
                            font.pixelSize: 24
                            color: "gray"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            text: "Нажмите 'Управление страницами' для создания страниц"
                            color: "lightgray"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Button {
                            text: "Создать первую страницу"
                            onClicked: addNewPage()
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}
