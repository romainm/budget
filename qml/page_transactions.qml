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
    }

    Rectangle {
        id: left_pane
        anchors.top: chart.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 300
        anchors.bottom: parent.bottom


        TextField {
            id: search_box
            placeholderText: "Search transaction/category"
            width: 200

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10

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
            anchors.top: search_box.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            model: transactionModel
        }
    }

    Rectangle {
        id: right_pane
        anchors.top: chart.bottom
        anchors.left: left_pane.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20

        Text {
            id: title
            text: "Category Selection"
            font.pixelSize: 24
            font.bold: true
        }

        ListView {
            id: category_view
            anchors.top: title.bottom
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            model: categoryModel
            width: parent.width
            delegate:
                Item {
                    width: ListView.view.width
                    height: childrenRect.height
                    Rectangle {
                        Text {
                            text: modelData
                            font.pixelSize: 18
                        }
                        color: index == category_view.currentIndex ? "lightsteelblue": "white"
                        width: childrenRect.width
                        height: childrenRect.height
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onDoubleClicked: function() {
                            category_view.currentIndex = index;
                            console.log("changed to" + modelData)
                            modelAPI.setSelectedTransactionsCategory(modelData)
                        }
                    }
                }
        }
    }

}
