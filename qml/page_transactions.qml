import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13
import QtCharts
import QtQml 2.15

Item {

    TransactionChart{
        id: chart
        model: transactionModel
        view: view
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 220
    }

    Rectangle {
        id: left_pane

        anchors.top: chart.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: 620

        TextField {
            id: search_box

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            placeholderText: "Search transaction/category"

            property bool keepFocus: false

            onTextChanged: {
                search_box.keepFocus = true
                view.model.setFilterString(text)
                view.selectionStartIndex = 0
            }
            onFocusChanged: {
                if (! focus) {
                    if (search_box.keepFocus) {
                        search_box.focus = true
                    }
                    search_box.keepFocus = false
                }
            }
        }

        TransactionList {
            id: view
            model: transactionModel
            anchors.top: search_box.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }

    Rectangle {
        id: right_pane
        width: 200
        height: 20
        anchors.top: chart.bottom
        anchors.left: left_pane.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.rightMargin:10
        border.width: 1
        border.color: "#a4d2ff"

        Rectangle {
            id: title
            width: parent.width
            height: 20
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin:1
            anchors.leftMargin:1
            anchors.rightMargin:1
            color: "#a4d2ff"

            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                text: "Category"
                font.pixelSize: 16
                font.bold: true
                verticalAlignment: Text.AlignVCenter
            }
        }

        ListView {
            id: category_view

            anchors.top: title.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 2
            anchors.leftMargin: 2
            anchors.rightMargin: 2

            model: categoryModel
            width: 200
            delegate:
                Item {
                    width: ListView.view.width
                    height: 20
                    Rectangle {
                        Text {
                            text: modelData
                            font.pixelSize: 14
                        }
                        color: index == category_view.currentIndex ? "#d2e8ff": "white"
                        width: parent.width
                        height: parent.height
                    }
                    MouseArea {
                        anchors.fill: parent

                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onDoubleClicked: function() {
                            modelAPI.setSelectedTransactionsCategory(modelData)
                        }
                        onEntered: function() {
                            console.log("entering " + modelData)
                            category_view.currentIndex = index;
                        }
                    }
                }
        }
    }

}
