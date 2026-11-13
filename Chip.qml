import QtQuick

// Small themed toggle/button. Selected = inverted theme colours.
Rectangle {
  id: chip
  property var theme
  property string text: ""
  property bool selected: false
  signal clicked()

  implicitWidth: label.implicitWidth + 16
  implicitHeight: label.implicitHeight + 8
  radius: theme.radius
  color: selected ? theme.fg : (mouse.containsMouse ? theme.hover : "transparent")
  border.width: 1
  border.color: selected ? theme.fg : theme.line

  Text {
    id: label
    anchors.centerIn: parent
    text: chip.text
    color: chip.selected ? chip.theme.bg : chip.theme.fg
    font.family: chip.theme.font
    font.pixelSize: chip.theme.small
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: chip.clicked()
  }
}
