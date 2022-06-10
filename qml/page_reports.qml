import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtCharts 2.13

Item {
    Rectangle {
        id: container
        color: "blue"
        anchors.fill: parent

        property int nbMonths: 12

        ScrollView {
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn


            ColumnLayout {
                anchors.fill: parent
                spacing: 1

                Rectangle {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: parent
                    Layout.preferredHeight: 30

                    Button {
                        id: m24
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        text: "24m"
                        width: 40
                        onClicked: {
                            container.nbMonths = 24;
                            categoryModel.setNbMonths(24);
                        }
                    }
                    Button {
                        anchors.right: m24.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        text: "12m"
                        width: 40
                        onClicked: {
                            container.nbMonths = 12;
                            categoryModel.setNbMonths(12);
                        }
                    }
                }

                Repeater {

                    model: categoryModel
                    Rectangle {
                        border.width: 1
                        color: "yellow"
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: parent
                        Layout.preferredHeight: 200

                        Text {
                            id: title
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            text: modelData
                            font.pixelSize: 16
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }

                        ChartView {
                            anchors.top : title.bottom
                            anchors.left : parent.left
                            anchors.right : parent.right
                            height: 200
    //                        Layout.alignment: Qt.AlignTop
    //                        Layout.fillWidth: parent
    //                        Layout.preferredHeight: 200
    //                        Layout.minimumWidth: 800
    //                        Layout.minimumHeight: 200
    //                        Layout.margins: -9
                            antialiasing: true
                            legend.visible: false

                            property var months: []

                            StackedBarSeries {
                                id: mySeries

                                property var months: []
                                property var totalPerMonth: Array(container.nbMonths).fill(0)
                                property var totalPerMonthNeg: Array(container.nbMonths).fill(0)

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

//                                onClicked: function() {
//                                    console.log("clicked")
//                                }

                                function refreshData() {
                                    var totalPerMonth = monthlySum;
                                    console.log(totalPerMonth)

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
                                    for (var i=0; i<container.nbMonths; i++) {
                                        month = date.toLocaleDateString(Qt.locale(), "MMM yy");
                                        months_.unshift(month);
                                        date.setMonth(date.getMonth() - 1);
                                    }
                                    months = months_;
                                }

    //                            Connections {
    //                                target: view
    //                                function onCountChanged() {
    //                                    mySeries.refreshData()
    //                                }
    //                            }
                            }
                        }
                    }
                }
            }
        }
    }
}
