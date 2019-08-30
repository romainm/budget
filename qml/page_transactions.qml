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
    }

    TextField {
        id: search_box
        placeholderText: "Search something here"
        width: 200

        anchors.top: chart.bottom
        anchors.right: parent.right
        anchors.rightMargin: 10

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

    TransactionList {
        id: view
        anchors.top: search_box.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        model: transactionModel
    }

}
