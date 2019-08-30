import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtCharts 2.13
import QtQml 2.13
import QtQuick.Dialogs 1.1

Item {

    Rectangle {
        id: actionBar
        width: parent.width
        height: 34
        color: "grey"
        Button {
            text: "Record Transactions"
            icon.name: "download"
            visible: transactionImportModel.rowCount() > 0
            height: 30
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.left: parent.left
            anchors.leftMargin: 2

            onClicked: messageDialogRecord.visible=true
        }
    }

    TransactionList {
        id: view
        model: transactionImportModel
        header: transactionHeader
        anchors.top: actionBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Component {
        id: transactionHeader
        Rectangle {
            width: parent.width
            height: 45
            color: "lightgrey"

            Rectangle {
                width: 200
                height: 30

                TextField {
                    id: search_box
                    placeholderText: "Search something here"
                    width: 200

                    property bool keepFocus: false

                    onTextChanged: {
                        search_box.keepFocus = true
                        view.model.setFilterString(text)
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

    MessageDialog {
        id: messageDialogRecord
        icon: StandardIcon.Question
        title: "Recording Transactions"
        text: "You are about to record selected transactions. Are you sure?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            visible = false
            backend.recordTransactions();
        }
        onNo: {
            visible = false
        }
}

}