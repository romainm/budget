import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtCharts 2.13
import QtQml 2.13

Item {

    TransactionList {
        model: transactionModel
    }

}
