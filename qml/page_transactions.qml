import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtCharts 2.13
import QtQml 2.13

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
                text: date.toLocaleDateString(Qt.locale(), "yy-MM-dd");
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

            TextInput {
                id: del_transaction_cat
                text: category
                font.pixelSize: 18
                width: 150
                height: 50
                anchors.left: del_transaction_name.right
                verticalAlignment: Text.AlignVCenter
                onEditingFinished: {
                    console.log('editing finished')
                    del_transaction_cat.focus = false
                    var qModelIndex = transactionModel.index(index, 0)
                    transactionModel.setData(qModelIndex, text, "category")

                }

                MouseArea {
                    anchors.fill: del_transaction_cat
                    visible: !del_transaction_cat.focus
                    onClicked: {
                        del_transaction_cat.focus = true
                    }
                }
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
              propagateComposedEvents: true
              onClicked: { transactionItem.ListView.view.currentIndex = index; mouse.accepted=false }
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
            width: parent.width
            height: 250
            color: "lightgrey"

            ChartView {
                id: chart
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 200
                antialiasing: true
                legend.visible: false
                BarSeries {
                    id: mySeries
                    // last 12 months - configurable in the future
                    property int nbMonths: 12

                    property var months: []
                    property var totalPerMonth: Array(nbMonths).fill(0)

                    axisX: BarCategoryAxis { categories: mySeries.months }
                    axisY: ValueAxis { id: valueAxis }

                    BarSet { values: mySeries.totalPerMonth }

                    Component.onCompleted: {
                        var date = new Date()
                        var month;
                        var months_ = [];
                        for (var i=0; i<nbMonths; i++) {
                            month = date.toLocaleDateString(Qt.locale(), "MMM");
                            months_.unshift(month);
                            date.setMonth(date.getMonth() - 1);
                        }
                        months = months_;
                    }

                    function compute() {
                        var totalPerMonth = Array(mySeries.nbMonths).fill(0)
                        var min = 0, max = 0;
                        var today = new Date();
                        var currentMonth = today.getMonth()
                        var currentYear = today.getYear()
                        for (var i=0; i<view.count; i++) {
                            var idx = view.model.index(i, 0);
                            var amount = view.model.data(idx, 1261);
                            var date = view.model.data(idx, 1258);

                           var nbMonths = currentMonth - date.getMonth();
                           var nbYears = currentYear - date.getYear();
                           nbMonths += nbYears * 12

                            totalPerMonth[nbMonths] += amount;
                            min = Math.min(min, amount);
                            max = Math.max(max, amount);

                            console.log(i + " " + amount + " " + date.getMonth());
                        }
                        totalPerMonth.reverse();
                        mySeries.totalPerMonth = totalPerMonth;
                        valueAxis.min = min;
                        valueAxis.max = max;
                        console.log(totalPerMonth);
                    }

                    Connections {
                        target: view
                        onCountChanged: {
                            mySeries.compute()
                        }
                    }

                }
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
