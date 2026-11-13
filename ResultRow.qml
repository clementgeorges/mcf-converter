import QtQuick

// One clickable "label ........ value" row. Click copies the value.
Rectangle {
  id: row
  property var theme
  property string label: ""
  property string value: ""
  property bool emphasis: false
  signal clicked()

  implicitHeight: valueText.implicitHeight + 10
  radius: theme.radius
  color: mouse.containsMouse ? theme.hover : "transparent"

  Text {
    anchors.left: parent.left
    anchors.leftMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    text: row.label
    color: row.theme.muted
    font.family: row.theme.font
    font.pixelSize: row.theme.small
  }

  Text {
    id: valueText
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    text: row.value
    color: row.theme.fg
    font.family: row.theme.font
    font.pixelSize: row.emphasis ? row.theme.big : row.theme.body
    font.bold: row.emphasis
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: row.clicked()
  }
}
