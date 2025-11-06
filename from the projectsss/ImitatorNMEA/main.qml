import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml 2.12
import "components"
import "dialogs"

Window {
    id: mainWindow
    visible: true
    width: 1440
    height: 760
    color: "#202020"
    title: "Имитатор NMEA 0183"

    // Модель данных для страниц
    property ListModel pagesModel: ListModel {
        ListElement { pageName: "Страница 1"; pageNumber: 1 }
        ListElement { pageName: "Страница 2"; pageNumber: 1 }
        ListElement { pageName: "Страница 3"; pageNumber: 1 }
        ListElement { pageName: "Страница 4"; pageNumber: 1 }
    }

    Header {
        id: header
        title: "Имитатор NMEA 0183"
    }

    TabBar {
        id: tabBar
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }
        currentTab: "Главная"
    }

    Column{
        Row{
            Rectangle{
                width: 1440
                height: 100
            }
        }
        Row

        ContentArea {
            id: contentArea
            anchors {
                top: tabBar.bottom
                left: parent.left
                right: parent.right
                bottom: statusBar.top
            }
            pagesModel: mainWindow.pagesModel
        }
    }

    StatusBar {
        id: statusBar
        anchors.bottom: parent.bottom
    }

    // Функции управления
    function openMessagesDialog() {
        var component = Qt.createComponent("dialogs/MessagesDialog.qml");
        if (component.status === Component.Ready) {
            var dialog = component.createObject(mainWindow);
            dialog.messagesSelected.connect(handleMessagesSelected);
            dialog.show();
        }
    }

    function handleMessagesSelected(selectedMessages) {
        for (var i = 0; i < selectedMessages.length; i++) {
            var messageName = selectedMessages[i];
            if (!pageExists(messageName)) {
                pagesModel.append({"pageName": messageName, "pageNumber": 1});
            }
        }
    }

    function pageExists(pageName) {
        for (var i = 0; i < pagesModel.count; i++) {
            if (pagesModel.get(i).pageName === pageName) {
                return true;
            }
        }
        return false;
    }

    function getPageSource(pageName) {
        switch(pageName) {
        case "Страница 1": return "qrc:/pages/Page1.qml"
        case "Страница 2": return "qrc:/pages/Page2.qml"
        case "Страница 3": return "qrc:/pages/Page3.qml"
        case "Страница 4": return "qrc:/pages/Page4.qml"
        case "GGA": case "GLL": case "GSA": case "GSV":
        case "RMC": case "VTG": case "ZDA": case "DTM":
        case "GBS": case "GNS": return "qrc:/pages/NMEAPage.qml"
        default: return "qrc:/pages/Page1.qml"
        }
    }


}
