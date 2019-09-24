import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtCharts 2.13
import QtQml 2.13

ListView {
    id: view
    clip: true
    delegate: transactionDelegate
    header: transactionHeader
    headerPositioning: ListView.OverlayHeader
    highlightFollowsCurrentItem: false

    highlight: Rectangle {
        color: "lightsteelblue"
        radius: 5
        height: 40
        width: parent ? parent.width : 0
        y:  view.currentItem ? view.currentItem.y : 0
    }
    focus: true
    ScrollBar.vertical: ScrollBar {}
    property int selectionStartIndex: 0

    Keys.onPressed: {
        if (event.modifiers & Qt.ShiftModifier &&
            event.key == Qt.Key_Up || event.key == Qt.Key_Down) {

            var lastSelectedIndex = view.currentIndex

            if (event.key == Qt.Key_Up) {
                view.currentIndex = Math.max(0, view.currentIndex - 1)
            } else {
                view.currentIndex += 1
            }

            var val = true;
            var qModelIndex;

            var min = Math.min(lastSelectedIndex, view.selectionStartIndex)
            var max = Math.max(lastSelectedIndex, view.selectionStartIndex)
            // new index between start and last -> last index set val off
            if ( view.currentIndex >= min && view.currentIndex <= max) {
                val = false
                qModelIndex = view.model.index(lastSelectedIndex, 0)
            }
            else {
                var qModelIndex = view.model.index(view.currentIndex, 0)
            }

            view.model.setData(qModelIndex, val, 1263)
            event.accepted = true
        }
    }

    Component {
        id: transactionHeader
        Rectangle {
            width: parent.width - 10
            height: 30
            color: "white"
            anchors.left: parent.left
            anchors.leftMargin: 10
            z: 10


                Text {
                    id: del_transaction_date
                    text: "Date"
                    font.pixelSize: 16
                    font.bold: true
                    width: 120
                }
                Text {
                    id: del_transaction_name
                    text: "Name / Account"
                    font.pixelSize: 16
                    font.bold: true
                    width: 700
                    anchors.left: del_transaction_date.right
                }

                Text {
                    id: del_transaction_cat
                    text: "Category"
                    font.pixelSize: 16
                    font.bold: true
                    width: 150
                    anchors.left: del_transaction_name.right
                }

                Text {
                    horizontalAlignment: Text.AlignRight
                    width: 100
                    text: "Amount"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                }
            }
    }


    QtObject {
        id: fonts
        property font faded: Qt.font({
            family: 'Encode Sans',
            italic: true,
            pointSize: 9
        })
        property font standard: Qt.font({
            family: 'Encode Sans',
            pointSize: 12
        })
        property font small: Qt.font({
            family: 'Encode Sans',
            pointSize: 10
        })
        property font money: Qt.font({
            pointSize: 12,
            bold: true
        })
    }
    Component {
        id: transactionDelegate

        Rectangle {
            id: transactionItem
            width: parent.width - 10
            height: 40
            color: {
                if (selected) {
                    return "lightsteelblue"
                }
                if (flagged) {
                return "gainsboro"
                }
                return "white"
            }
            anchors.left: parent.left
            anchors.leftMargin: 10
            Text {
                id: del_transaction_date
                text: date.toLocaleDateString(Qt.locale(), "yy-MM-dd");
                font: flagged? fonts.small : fonts.standard
                width: 120
            }
            Text {
                id: del_transaction_name
                text: name
                font: flagged? fonts.faded : fonts.standard
                width: 700
                anchors.left: del_transaction_date.right
            }

            Text {
                id: del_transaction_account
                text: account
                font: fonts.small
                anchors.top: del_transaction_name.bottom
                anchors.left: del_transaction_date.right
            }

            TextInput {
                id: del_transaction_cat
                text: category
                font: fonts.standard
                width: 150
                height: 50
                anchors.left: del_transaction_name.right
                verticalAlignment: Text.AlignVCenter
                onEditingFinished: {
                    console.log('editing finished')
                    del_transaction_cat.focus = false
                    var qModelIndex = view.model.index(index, 0)
                    view.model.setData(qModelIndex, text, "category")

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
                color: {
                    if (flagged) {
                        return "gainsboro"
                    }
                    if (amountNum > 0) {
                        return "#027524"
                    }
                    return "#ba0329"
                }

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
                    font: fonts.money
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
              onClicked: {
                  var qModelIndex = view.model.index(index, 0)
                  var val = view.model.data(qModelIndex, 1263)
                  if (mouse.button == Qt.LeftButton) {
                      if (mouse.modifiers & Qt.ShiftModifier) {
                        view.model.setData(qModelIndex, !selected, 1263)
                        view.model.selectBlock(view.selectionStartIndex, index)

                      }
                      else if (mouse.modifiers & Qt.ControlModifier) {
                        view.model.setData(qModelIndex, !selected, 1263)
                      }
                      else {
                        view.model.unselectAll()
                        view.model.setData(qModelIndex, !selected, 1263)
                        view.selectionStartIndex = index
                      }
                  }
                  view.currentIndex = index
                  mouse.accepted=false
              }
              onDoubleClicked: {
                  var qModelIndex = view.model.index(index, 0)
                  var val = view.model.data(qModelIndex, 1262)
                  view.model.setData(qModelIndex, !flagged, 1262)
              }
            }
        }
    }

}


