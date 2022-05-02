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

    ChartView {
        width: 400
        height: 300
        theme: ChartView.ChartThemeBrownSand
        antialiasing: true

        PieSeries {
            id: pieSeries
            PieSlice { label: "eaten"; value: 94.9 }
            PieSlice { label: "not yet eaten"; value: 5.1 }
        }
    }


}
