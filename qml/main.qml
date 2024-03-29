import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13
import QtQuick.Dialogs
// import Qt.labs.platform 1.0
import QtCharts


ApplicationWindow {
    title: "My Application"
    width: 1600
    height: 800
    visible: true

    menuBar: MenuBar {
        Menu {
            title: qsTr("&Account")
            Action { text: qsTr("&New Account...") }
            Action { text: qsTr("&Open Account...") }
            Action { text: qsTr("&Save Account") }
            MenuSeparator { }
            Action { text: qsTr("&Quit") }
        }
        // Menu {
        //     title: qsTr("&Transactions")
        //     Action {
        //         text: qsTr("&Import")
        //         onTriggered: fileDialog.visible = true;
        //         }
        // }
    }

    Rectangle {
        id: side_panel
        width: 150
        height: parent.height
        focus: false
        color: "lightgrey"

        SidePanelItem {
            id: drawer_label_transactions
            text: "Transactions"
            onClicked: { console.log("loading transactions"); pageLoader.source="page_transactions.qml"}
        }

        SidePanelItem {
            id: drawer_label_budgets
            text: "Budgets"
            onClicked: { console.log("loading budgets"); pageLoader.source="page_budgets.qml"}
            anchors.top: drawer_label_transactions.bottom
            anchors.topMargin: 5
        }

        SidePanelItem {
            id: drawer_label_reports
            text: "Reports"
            onClicked: { console.log("loading reports"); pageLoader.source="page_reports.qml"}
            anchors.top: drawer_label_budgets.bottom
            anchors.topMargin: 5
        }

        SidePanelItem {
            id: drawer_label_import
            text: "Import"
            onClicked: { pageLoader.source="page_import.qml"}
            anchors.top: drawer_label_reports.bottom
            anchors.topMargin: 5
        }

        // this will come later
//        Text {
//            id: accounts
//            anchors.top: drawer_label_import.bottom
//            anchors.topMargin: 100
//            text: "Accounts"
//            font.bold: true
//            font.pixelSize: 20
//        }
    }

    Loader {
        id: pageLoader
        anchors.fill: parent
        anchors.leftMargin: 150
        source: "page_transactions.qml"
        focus: true

    }


}
