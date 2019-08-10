import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

ApplicationWindow {
    id: window
    Material.theme: Material.Dark
    title: qsTr("Test Invoke")
    visible: true

    width: 1200
    height: 800

    menuBar: MenuBar {
        Menu {
            title: "File"
            MenuItem { text: "Create Account..." }
            MenuItem { text: "Load File..."; onTriggered: loadFileDialog.open()}
            MenuItem { text: "Close" }
        }

        Menu {
            title: "Edit"
            MenuItem { text: "Cut" }
            MenuItem { text: "Copy" }
            MenuItem { text: "Paste" }
        }
    }

    FileDialog {
        id: loadFileDialog
        nameFilters: ["ofx files (*.ofx)"]
        onAccepted: console.log("chosen" + file);

    }

    Drawer {
        id: drawer
        width: 150
        y: menuBar.height
        height: window.height - menuBar.height
        visible: true
        interactive: false

        Text {
            id: menu_transactions
            text: "Transactions"
            anchors.top: parent.top
            font.pointSize: 18; font.bold: true
        }
        Text {
            id: menu_budget
            text: "Budget"
            anchors.top: menu_transactions.bottom
            anchors.topMargin: 2
            font.pointSize: 18; font.bold: true
        }

    }


    Rectangle {
        id: page
        width: parent.width; height: parent.height
        color: "white"
        x: drawer.width;

        Text {
            id: helloText
            text: "Hello world!"
            y: 30
            anchors.horizontalCenter: page.horizontalCenter
            font.pointSize: 24; font.bold: true
        }

        Grid {
            id: colorPicker
            x: 4; anchors.bottom: page.bottom; anchors.bottomMargin: 4
            rows: 2; columns: 3; spacing: 3

            Cell { cellColor: "blue"; onClicked: helloText.color = cellColor }
            Cell { cellColor: "green"; onClicked: helloText.color = cellColor }
            Cell { cellColor: "blue"; onClicked: helloText.color = cellColor }
            Cell { cellColor: "yellow"; onClicked: helloText.color = cellColor }
            Cell { cellColor: "steelblue"; onClicked: helloText.color = cellColor }
            Cell { cellColor: "black"; onClicked: helloText.color = cellColor }
        }
    }
}
