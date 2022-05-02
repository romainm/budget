import QtQuick 2
import QtQuick.Controls 2
import QtQuick.Layouts 1
import QtCharts 2
import QtQml 2

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

    Menu {
        id: contextMenu

        MenuItem {
            text: 'Flag'
            onTriggered: function() {
                view.model.flagSelectedItems()
            }
        }
        MenuItem {
            text: 'Remove Flag'
            onTriggered: function() {
                view.model.unflagSelectedItems()
            }
        }
    }

    Keys.onPressed: function(event) {
        event.accepted = true;
        var lastSelectedIndex = view.currentIndex

        if (event.key == Qt.Key_Up) {
            view.currentIndex = Math.max(0, view.currentIndex - 1)
        } else if (event.key == Qt.Key_Down){
            view.currentIndex += 1
        }
        if (lastSelectedIndex == view.currentIndex)
            return;

        if (event.modifiers & Qt.ShiftModifier &&
            (event.key == Qt.Key_Up || event.key == Qt.Key_Down)) {

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
        }
        else if (event.key == Qt.Key_Up || event.key == Qt.Key_Down) {
            var qModelIndex = view.model.index(view.currentIndex, 0)
            view.model.unselectAll()
            view.model.setData(qModelIndex, true, 1263)
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
        property color baseColor: "black"
        property color disabledColor: "#9f9f9f"
    }
    Component {
        id: transactionDelegate

        Rectangle {
            id: transactionItem
            width: view.width - 10
            height: 40
            color: {
                if (selected) {
                    return "lightsteelblue"
                }
                return "white"
            }
            // anchors.left: view.left
            anchors.leftMargin: 10
            Text {
                id: del_transaction_date
                text: date.toLocaleDateString(Qt.locale(), "yy-MM-dd");
                font: flagged? fonts.small : fonts.standard
                color: flagged? fonts.disabledColor : fonts.baseColor
                width: 120
            }
            Text {
                id: del_transaction_name
                text: name
                font: flagged? fonts.faded : fonts.standard
                color: flagged? fonts.disabledColor : fonts.baseColor
                width: 700
                anchors.left: del_transaction_date.right
            }

            Text {
                id: del_transaction_account
                text: account
                font: fonts.small
                color: flagged? fonts.disabledColor : fonts.baseColor
                anchors.top: del_transaction_name.bottom
                anchors.left: del_transaction_date.right
            }

            TextInput {
                id: del_transaction_cat
                text: category
                font: fonts.standard
                color: flagged? fonts.disabledColor : fonts.baseColor
                width: 150
                height: 50
                anchors.left: del_transaction_name.right
               onEditingFinished: function() {
                   console.log('hey', text)
                   del_transaction_cat.focus = false
                   var qModelIndex = view.model.index(index, 0)
                   view.model.setData(qModelIndex, text, 1259)

               }

                MouseArea {
                    anchors.fill: del_transaction_cat
                    visible: !del_transaction_cat.focus
                    onClicked: function() {
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
                anchors.rightMargin: 10
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
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: function(mouse) {
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
                  else if (mouse.button == Qt.RightButton) {
                    if (!selected) {
                        view.model.setData(qModelIndex, true, 1263)
                    }
                    console.log(mouse.x + " " + mouse.y)
                    contextMenu.x = mouse.x + transactionItem.x
                    contextMenu.y = mouse.y + transactionItem.y
                    contextMenu.open()
                  }
                  view.currentIndex = index
                  mouse.accepted=false
              }
              onDoubleClicked: function() {
                  var qModelIndex = view.model.index(index, 0)
                  var val = view.model.data(qModelIndex, 1262)
                  view.model.setData(qModelIndex, !flagged, 1262)
              }
            }
        }
    }

}


