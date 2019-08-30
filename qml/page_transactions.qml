import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtCharts 2.13
import QtQml 2.13

Item {

    TransactionList {
        id: view
        anchors.fill: parent
        model: transactionModel
    }

    Component {
        id: transactionHeader
        Rectangle {
            width: parent.width
            height: 250
            color: "lightgrey"

            TransactionChart{
                id: chart
                model: view.model
            }

            Rectangle {
                width: 200
                height: 30
                anchors.top: chart.bottom

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

}
