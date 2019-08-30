import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtCharts 2.13
import QtQml 2.13


ChartView {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 200
    antialiasing: true
    legend.visible: false

    property var model: null
    property var months: []
    property ListView view: null

    StackedBarSeries {
        id: mySeries
        // last 12 months - configurable in the future
        property int nbMonths: 12

        property var months: []
        property var totalPerMonth: Array(nbMonths).fill(0)
        property var totalPerMonthNeg: Array(nbMonths).fill(0)

        axisX: BarCategoryAxis { categories: mySeries.months }
        axisY: ValueAxis { id: valueAxis }

        BarSet { color: "green"; values: mySeries.totalPerMonth }
        BarSet { color: "red"; values: mySeries.totalPerMonthNeg }

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
            mySeries.compute()
        }

        function compute() {
            var totalPerMonth = Array(mySeries.nbMonths).fill(0)
            var today = new Date();
            var currentMonth = today.getMonth()
            var currentYear = today.getYear()
            for (var i=0; i<view.count; i++) {
                var idx = model.index(i, 0);
                var amount = model.data(idx, 1261);
                var date = model.data(idx, 1258);

                var nbMonths = currentMonth - date.getMonth();
                var nbYears = currentYear - date.getYear();
                nbMonths += nbYears * 12

                if (nbMonths >= mySeries.nbMonths) {
                    continue;
                }

                totalPerMonth[nbMonths] += amount;
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

        Connections {
            target: view
            onCountChanged: {
                mySeries.compute()
            }
        }
    }
}
