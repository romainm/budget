import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtCharts 2.13
import QtQml 2.13

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
            placeholderText: "Search something here"
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
                print("focus changed " + focus)
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
            delegate:
                Text {
                    text: modelData
                    font.pixelSize: 18
                }

            highlight: Rectangle {
                color: "lightsteelblue"
                radius: 5
                height: 40
                width: parent ? parent.width : 0
                y:  category_view.currentItem ? category_view.currentItem.y : 0
            }
        }
    }
}
