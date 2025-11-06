import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    id: pageManagerWindow
    title: "Управление страницами"
    width: 400
    height: 500
    modality: Qt.ApplicationModal
    visible: false

    property var pagesModel
    property int selectedPageIndex: 0

    signal pageSelected(int index)

    function addNewPage() {
        var pageNumber = pagesModel.count + 1

        // Создаем новую модель для страницы
        var newModel = Qt.createQmlObject('
            import AppModels 1.0;
            DisplayModel {}', pageManagerWindow)

        // Добавляем страницу в модель
        pagesModel.append({
            "pageModel": newModel,
            "pageName": "Страница " + pageNumber,
            "pageNumber": pageNumber
        })

        console.log("Добавлена новая страница:", pageNumber)
    }

    function removePage(index) {
        if (index >= 0 && index < pagesModel.count) {
            pagesModel.remove(index)
            if (selectedPageIndex >= pagesModel.count) {
                selectedPageIndex = Math.max(0, pagesModel.count - 1)
            }
        }
    }

    function renamePage(index, newName) {
        if (index >= 0 && index < pagesModel.count && newName.trim() !== "") {
            pagesModel.setProperty(index, "pageName", newName.trim())
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Заголовок
        Label {
            text: "Управление страницами"
            font.bold: true
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
        }

        // Статистика
        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "Всего страниц: " + pagesModel.count
                color: "gray"
            }

            Item { Layout.fillWidth: true }

            Label {
                text: "Выбрана: " + (selectedPageIndex + 1)
                color: "blue"
                font.bold: true
            }
        }

        // Список страниц
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: pagesListView
                width: parent.width
                model: pagesModel
                spacing: 5

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 50
                    color: selectedPageIndex === index ? "#e0e8ff" : (index % 2 === 0 ? "#f8f8f8" : "white")
                    border.color: selectedPageIndex === index ? "blue" : "lightgray"
                    radius: 5

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 10

                        // Номер страницы
                        Label {
                            text: (index + 1)
                            font.bold: true
                            color: "gray"
                            Layout.preferredWidth: 30
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Название страницы
                        TextField {
                            id: nameField
                            text: pageName
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            onEditingFinished: renamePage(index, text)
                        }

                        // Кнопка выбора
                        Button {
                            text: "Выбрать"
                            highlighted: selectedPageIndex === index
                            onClicked: {
                                selectedPageIndex = index
                                pageSelected(index)
                            }
                            Layout.preferredWidth: 70
                        }

                        // Кнопка удаления
                        Button {
                            text: "Удалить"
                            onClicked: removePage(index)
                            enabled: pagesModel.count > 1
                            Layout.preferredWidth: 70
                            background: Rectangle {
                                color: "transparent"
                                border.color: "red"
                            }
                        }
                    }
                }
            }
        }

        // Панель управления
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "+ Добавить страницу"
                onClicked: addNewPage()
                Layout.fillWidth: true
            }

            Button {
                text: "Закрыть"
                onClicked: pageManagerWindow.visible = false
                Layout.fillWidth: true
            }
        }

        // Горячие клавиши
        Label {
            text: "Подсказка: Двойной клик по названию для переименования"
            color: "gray"
            font.italic: true
            font.pixelSize: 10
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
