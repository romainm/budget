import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtCharts 2.13
import QtQml 2.13

Rectangle {
    id: container

    property var model
    property ListView view
    property int nbMonths: 12

    ColumnLayout {
        anchors.fill: parent
        spacing: 1

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: parent
            Layout.preferredHeight: 30

//            Button {
//                id: y5
//                anchors.right: parent.right
//                anchors.rightMargin: 10
//                text: "5y"
//                width: 40
//                onClicked: {
//                    nbMonths = 12;
//                    mySeries.refreshHeaders();
//                    mySeries.refreshData();
//                }
//            }
            Button {
                id: m24
//                anchors.right: y5.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 10
                text: "24m"
                width: 40
                onClicked: {
                    nbMonths = 24;
                    mySeries.refreshHeaders();
                    mySeries.refreshData();
                }
            }
            Button {
                anchors.right: m24.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 10
                text: "12m"
                width: 40
                onClicked: {
                    nbMonths = 12;
                    mySeries.refreshHeaders();
                    mySeries.refreshData();
                }
            }
        }

        ChartView {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: parent
            Layout.preferredHeight: 200
            Layout.minimumWidth: 800
            Layout.minimumHeight: 200
            Layout.margins: -9
            antialiasing: true
            legend.visible: false

            property var months: []

            StackedBarSeries {
                id: mySeries

                property var months: []
                property var totalPerMonth: Array(nbMonths).fill(0)
                property var totalPerMonthNeg: Array(nbMonths).fill(0)

                axisX: BarCategoryAxis { categories: mySeries.months }
                axisY: ValueAxis { id: valueAxis }

                BarSet { color: "green"; values: mySeries.totalPerMonth; labelColor: "black"}
                BarSet { color: "red"; values: mySeries.totalPerMonthNeg; labelColor: "black" }

                labelsFormat: "@value"
                labelsVisible: true
                labelsPosition: AbstractBarSeries.LabelsOutsideEnd

                Component.onCompleted: function() {
                    mySeries.refreshHeaders()
                    mySeries.refreshData()
                }

                onClicked: function() {
                    console.log("clicked")
                }

                function refreshData() {
                    var totalPerMonth = Array(nbMonths).fill(0)
                    var today = new Date();
                    var currentMonth = today.getMonth()
                    var currentYear = today.getYear()
                    for (var i=0; i<view.count; i++) {
                        var idx = model.index(i, 0);
                        var amount = model.data(idx, 1261);
                        var date = model.data(idx, 1258);

                        var nbMonths_ = currentMonth - date.getMonth();
                        var nbYears = currentYear - date.getYear();
                        nbMonths_ += nbYears * 12

                        if (nbMonths_ >= nbMonths) {
                            continue;
                        }

                        totalPerMonth[nbMonths_] += amount;
                    }
                    var min = Math.min(...totalPerMonth)
                    var max = Math.max(...totalPerMonth)
                    totalPerMonth.reverse();
                    mySeries.totalPerMonth = totalPerMonth.map(x => Math.max(0, x));
                    mySeries.totalPerMonthNeg = totalPerMonth.map(x => Math.min(0, x));
                    valueAxis.min = min;
                    valueAxis.max = max;
                    valueAxis.applyNiceNumbers()
                }

                function refreshHeaders() {
                    var date = new Date()
                    var month;
                    var months_ = [];
                    for (var i=0; i<nbMonths; i++) {
                        month = date.toLocaleDateString(Qt.locale(), "MMM yy");
                        months_.unshift(month);
                        date.setMonth(date.getMonth() - 1);
                    }
                    months = months_;
                }

                Connections {
                    target: view
                    function onCountChanged() {
                        mySeries.refreshData()
                    }
                }
            }
        }
    }
}
