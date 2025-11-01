import QtQuick 2.12
import QtQuick.Controls 2.12

BaseItem {
    id: messagesItem
    itemTitle: "Сообщения"

    // Свойство для хранения количества квадратов
    property int squareCount: 0
    property int maxWidth: 164  // Максимальная начальная ширина
    property int columnCount: 1  // Количество столбцов
    property int squareSize: 64  // Ширина квадрата
    property int squareHeight: 21 // Высота квадрата
    property int spacing: 5      // Отступ между квадратами

    // Контейнер для квадратов
    Item {
        id: squaresContainer
        anchors.fill: parent
        anchors.margins: 5
    }

    // Функция для добавления квадрата
    function addSquare() {
        var component = Qt.createComponent("MessageSquare.qml")
        if (component.status === Component.Ready) {
            var square = component.createObject(squaresContainer)

            // Рассчитываем позицию нового квадрата
            var column = Math.floor(squareCount / 3)  // В каком столбце (0, 1, 2...)
            var row = squareCount % 3                 // В какой строке столбца (0, 1, 2)

            // Устанавливаем размер и позицию
            square.width = squareSize
            square.height = squareHeight
            square.x = column * (squareSize + spacing)
            square.y = row * (squareHeight + spacing)

            squareCount++

            // Проверяем, нужно ли добавить новый столбец
            var newColumnCount = Math.ceil(squareCount / 3)
            if (newColumnCount > columnCount) {
                columnCount = newColumnCount
                // Увеличиваем ширину только если столбцов стало 4 или больше
                if (columnCount >= 3) {
                    messagesItem.width = maxWidth + (columnCount - 2) * 64
                    console.log("Добавлен столбец. Ширина:", messagesItem.width)
                }
            }
        } else {
            console.log("Ошибка загрузки компонента:", component.errorString())
        }
    }

    // Функция для удаления квадрата
    function removeSquare(index) {
        if (index >= 0 && index < squaresContainer.children.length) {
            // Находим квадрат по индексу
            for (var i = 0; i < squaresContainer.children.length; i++) {
                var child = squaresContainer.children[i]
                if (child.objectName === "messageSquare" && child.squareIndex === index) {
                    child.destroy()
                    squareCount--
                    reorganizeSquares()
                    break
                }
            }
        }
    }

    // Реорганизация квадратов после удаления
    function reorganizeSquares() {
        // Собираем все оставшиеся квадраты
        var squares = []
        for (var i = 0; i < squaresContainer.children.length; i++) {
            var child = squaresContainer.children[i]
            if (child.objectName === "messageSquare") {
                squares.push(child)
            }
        }

        // Пересчитываем количество столбцов
        var newColumnCount = Math.ceil(squares.length / 3)
        columnCount = newColumnCount

        // Устанавливаем ширину только если столбцов 4 или больше
        if (columnCount >= 3) {
            messagesItem.width = maxWidth + (columnCount - 2) * 64
        } else {
            messagesItem.width = maxWidth
        }

        // Перераспределяем квадраты
        for (var j = 0; j < squares.length; j++) {
            var square = squares[j]
            var column = Math.floor(j / 3)
            var row = j % 3

            square.x = column * (squareSize + spacing)
            square.y = row * (squareHeight + spacing)
            square.squareIndex = j
        }
    }

    // Очистка всех квадратов
    function clearSquares() {
        for (var i = squaresContainer.children.length - 1; i >= 0; i--) {
            var child = squaresContainer.children[i]
            if (child.objectName === "messageSquare") {
                child.destroy()
            }
        }
        squareCount = 0
        columnCount = 1
        messagesItem.width = maxWidth
    }
}
