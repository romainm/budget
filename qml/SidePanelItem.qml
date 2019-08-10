import QtQuick 2.13
import QtQuick.Controls 2.13

Label {
    id: root
    font.bold: true
    font.pixelSize: 20

    signal clicked()

    MouseArea {
      hoverEnabled: false
      anchors.fill: parent
      onClicked: { root.clicked() }
    }
}
