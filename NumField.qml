import QtQuick

// Labelled themed number input.
Item {
  id: f
  property var theme
  property string label: ""
  property string suffix: ""
  property alias text: input.text
  signal edited()

  implicitWidth: 120
  implicitHeight: caption.implicitHeight + 4 + box.height

  Text {
    id: caption
    text: f.label
    color: f.theme.muted
    font.family: f.theme.font
    font.pixelSize: f.theme.small
  }

  Rectangle {
    id: box
    anchors.top: caption.bottom
    anchors.topMargin: 4
    width: f.width
    height: input.implicitHeight + 12
    radius: f.theme.radius
    color: f.theme.field
    border.width: 1
    border.color: input.activeFocus ? f.theme.fg : f.theme.line

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.IBeamCursor
      onPressed: function(mouse) { input.forceActiveFocus(); mouse.accepted = false }
    }

    TextInput {
      id: input
      anchors.left: parent.left
      anchors.right: sfx.left
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: 8
      anchors.rightMargin: 6
      color: f.theme.fg
      selectionColor: f.theme.fg
      selectedTextColor: f.theme.bg
      font.family: f.theme.font
      font.pixelSize: f.theme.body
      selectByMouse: true
      clip: true
      inputMethodHints: Qt.ImhFormattedNumbersOnly
      onTextEdited: f.edited()
    }

    Text {
      id: sfx
      anchors.right: parent.right
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      text: f.suffix
      color: f.theme.muted
      font.family: f.theme.font
      font.pixelSize: f.theme.small
    }
  }
}
