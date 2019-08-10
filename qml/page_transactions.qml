import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {

    ListModel {

        id: transactionModel
        ListElement { name: "Optus"; amount: 123.00; account: "Smart Access"; category: "phone" }
        ListElement { name: "AnimalLogic"; amount: 234.00; account: "Smart Access"; category: "income>rom" }
        ListElement { name: "Optus"; amount: 44444.34 }
        ListElement { name: "Aldi"; amount: 23.31 }
        ListElement { name: "Peoplecare"; amount: 500.00 }
    }
    // delegate for transaction table
    Component {
        id: transactionDelegate

        Rectangle {
            id: transactionItem
            width: parent.width - 10
            height: 50
            color: ListView.isCurrentItem ? "lightsteelblue" : "white"
            anchors.left: parent.left
            anchors.leftMargin: 10
            Text {
                id: del_transaction_name
                text: name
                font.pixelSize: 24
                width: 400
            }

            Text {
                id: del_transaction_account
                text: account
                font.pixelSize: 14
                anchors.top: del_transaction_name.bottom
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

            Text {
                text: amount
                font.pixelSize: 18
                width: 100
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                height: parent.height - 10
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
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
        clip: true
        anchors.fill: parent
        model: transactionModel
        delegate: transactionDelegate
        header: transactionHeader
        highlightFollowsCurrentItem: true

        highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
        focus: true
    }

    Component {     //instantiated when header is processed
        id: transactionHeader
        Rectangle {
            id: banner
            width: parent.width; height: 50
            color: "lightgrey"
            Text {
                anchors.centerIn: parent
                text: "Transactions"
                font.pixelSize: 32

            }
        }
    }
}
