import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12
import "../Items/PortItem"

BaseItem {
    id: portItem
    itemTitle: "Порты"

    property int rowCount: 0

    Row {
        anchors.fill: parent

        Column {
            width: 20
            height: parent.height

            Button {
                width: 20
                height: 20
                background: Rectangle {
                    color: "transparent"
                }
                Image {
                    width: 20
                    height: 20
                    source: "qrc:/Images/add.png"
                }
                onClicked: {
                    comboBoxModel.append({
                        "portIndex": -1,
                        "baudRateIndex": -1,
                        "baudRateEnabled": false,
                        "deleteEnabled": false
                    })
                    rowCount = comboBoxModel.count
                }
            }

            Button {
                width: 20
                height: 20
                background: Rectangle {
                    color: "transparent"
                }
                Image {
                    width: 20
                    height: 20
                    source: "qrc:/Images/cancel.png"
                }
                onClicked: {
                    if (comboBoxModel.count > 0) {
                        comboBoxModel.remove(comboBoxModel.count - 1)
                        rowCount = comboBoxModel.count
                    }
                }
            }

            Item {
                width: 20
                height: parent.height - 40
            }
        }

        Column {
            width: portItem.width - 20
            height: parent.height

            Rectangle {
                width: parent.width
                height: 70
                color: "#252525"

                ListModel {
                    id: comboBoxModel
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 5

                    ListView {
                        id: listView
                        model: comboBoxModel
                        clip: true
                        spacing: 5

                        delegate: PortRow {
                            rowIndex: index
                            portIndex: model.portIndex
                            baudRateIndex: model.baudRateIndex
                            baudRateEnabled: model.baudRateEnabled
                            deleteEnabled: model.deleteEnabled

                            onRemoveClicked: {
                                console.log("Removing index:", index)
                                if (index >= 0 && index < comboBoxModel.count) {
                                    comboBoxModel.remove(index)
                                    rowCount = comboBoxModel.count
                                }
                            }

                            onPortChanged: {
                                if (index >= 0 && index < comboBoxModel.count) {
                                    comboBoxModel.setProperty(index, "portIndex", portIndex)
                                    comboBoxModel.setProperty(index, "baudRateEnabled", true)
                                    comboBoxModel.setProperty(index, "deleteEnabled", true)
                                }
                            }

                            onBaudRateChanged: {
                                if (index >= 0 && index < comboBoxModel.count) {
                                    comboBoxModel.setProperty(index, "baudRateIndex", baudRateIndex)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        comboBoxModel.append({
            "portIndex": -1,
            "baudRateIndex": -1,
            "baudRateEnabled": false,
            "deleteEnabled": false
        })
        rowCount = 1
    }
}
