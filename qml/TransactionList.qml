import QtQuick 2
import QtQuick.Controls 2
import QtQuick.Layouts 1
import QtCharts 2
import QtQml 2

ListView {
    id: view
    clip: true
    delegate: transactionDelegate
    highlightFollowsCurrentItem: false

    focus: true
    ScrollBar.vertical: ScrollBar {}
    property int selectionStartIndex: 0

//    Menu {
//        id: contextMenu
//
//        MenuItem {
//            text: 'Flag'
//            onTriggered: function() {
//                view.model.flagSelectedItems()
//            }
//        }
//        MenuItem {
//            text: 'Remove Flag'
//            onTriggered: function() {
//                view.model.unflagSelectedItems()
//            }
//        }
//    }

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
            width: 600
            height: 50
            color: {
                if (selected) {
                    return "lightsteelblue"
                }
                return "white"
            }
            anchors.left: ListView.view.contentItem.left
            anchors.leftMargin: 5

            Text {
                id: transactionName

                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.top: parent.top
                anchors.topMargin: 2

                text: name
                font: flagged? fonts.faded : fonts.standard
                color: flagged? fonts.disabledColor : fonts.baseColor
            }
            Text {
                id: transactionDate

                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.top: transactionName.bottom
                anchors.bottomMargin: 2

                text: date.toLocaleDateString(Qt.locale(), "yy-MM-dd");
                font: flagged? fonts.small : fonts.small
                color: flagged? fonts.disabledColor : fonts.baseColor
//                width: 120
            }
            Rectangle {
                id: transactionAmount

                anchors.right: parent.right
                anchors.rightMargin: 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin:2

                color: {
                    if (flagged) {
                        return "gainsboro"
                    }
                    if (amountNum > 0) {
                        return "#027524"
                    }
                    return "#ba0329"
                }

                height: 20
                width: 100
                radius: 10

                Text {
                    anchors.fill: parent
                    anchors.rightMargin: 5

                    text: amount
                    color: "white"
                    font: fonts.money
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
            TextInput {
                id: transactionCategory

                anchors.right: transactionAmount.left
                anchors.rightMargin: 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin:2

                text: category
                font: fonts.standard
                color: flagged? fonts.disabledColor : fonts.baseColor
            }

            Text {
                id: transactionAccount

                anchors.top: transactionDate.bottom
                anchors.left: parent.left
                anchors.topMargin: 2
                anchors.leftMargin: 2

                text: account
                font: fonts.small
                color: flagged? fonts.disabledColor : "lightgrey"
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


