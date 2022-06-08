import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13
import QtCharts 2.15
import QtQml 2.15
import QtQuick.Dialogs

Item {

    FileDialog {
        id: fileDialog
        title: "Please choose files to load"
        // currentFolder: shortcuts.home
        fileMode: FileDialog.OpenFiles
        nameFilters: ["ofx files (*.ofx)"]
        onAccepted: {
            modelAPI.loadFiles(fileDialog.selectedFiles.slice());
            pageLoader.source="page_import.qml";
        }
    }


    Rectangle {
        id: actionBar
        width: parent.width
        height: 34
        color: "grey"
        RowLayout {
            anchors.fill: parent
            ToolButton {
                width: 30
                text: qsTr("Import")
                onClicked: fileDialog.visible = true;
                icon.name: "download"
            }
            ToolButton {
                text: "Record Transactions"
                icon.name: "download"
                // visible: transactionImportModel.rowCount() > 0
                width: 30
                onClicked: messageDialogRecord.visible=true
            }
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

                    onTextChanged: function() {
                        search_box.keepFocus = true
                        view.model.setFilterString(text)
                    }
                    onFocusChanged: function() {
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
        // icon: StandardIcon.Question
        title: "Recording Transactions"
        text: "You are about to record selected transactions. Are you sure?"
        buttons: MessageDialog.Yes | MessageDialog.No
        onAccepted: function() {
            // visible = false
            modelAPI.recordTransactions();
        }
        // onNo: {
        //     visible = false
        // }
}

}
