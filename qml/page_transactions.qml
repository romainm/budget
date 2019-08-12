import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {

    // delegate for transaction table
    Component {
        id: transactionDelegate

        Rectangle {
            id: transactionItem
            width: parent.width - 10
            height: 40
            color: ListView.isCurrentItem ? "lightsteelblue" : "white"
            anchors.left: parent.left
            anchors.leftMargin: 10
            Text {
                id: del_transaction_date
                text: date
                font.pixelSize: 16
                width: 120
            }
            Text {
                id: del_transaction_name
                text: name
                font.pixelSize: 16
                width: 700
                anchors.left: del_transaction_date.right
            }

            Text {
                id: del_transaction_account
                text: account
                font.pixelSize: 14
                anchors.top: del_transaction_name.bottom
                anchors.left: del_transaction_date.right
            }

            Text {
                id: del_transaction_cat
                text: category
                font.pixelSize: 18
                width: 150
                height: 50
                anchors.left: del_transaction_name.right
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                color: amountNum > 0 ? "#027524" : "#ba0329"
                height: parent.height - 20
                width: 100
                radius: 10
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                Text {
                    id: text_amount
                    text: amount
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                }
            }

            MouseArea {
              z: 1
              hoverEnabled: false
              anchors.fill: parent
              onClicked: { transactionItem.ListView.view.currentIndex = index }
            }
        }
    }

    ListView {
        id: view
        clip: true
        anchors.fill: parent
        model: transactionModel
        delegate: transactionDelegate
        header: transactionHeader
        highlightFollowsCurrentItem: false

        highlight: Rectangle {
            color: "lightsteelblue"
            radius: 5
            height: 40
            width: parent.width
            y:  view.currentItem ? view.currentItem.y : 0
        }
        focus: true
        ScrollBar.vertical: ScrollBar {}
    }

    Component {     //instantiated when header is processed
        id: transactionHeader
        Rectangle {
                color: "lightgrey"
                width: parent.width
                height: 40

            Rectangle {
                color: "white"
                width: 200
                height: 30

                TextField {
                    id: search_box
                    placeholderText: "Search something here"
                    width: 200

                    property bool keepFocus: false

                    onTextChanged: {
                        search_box.keepFocus = true
                        transactionModel.setFilterString(text)
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
            }
        }
    }
}
