import QtQuick
import QtQuick.Layouts
import "Converters.js" as C

// px <-> rem with an editable base (always starts at 16px).
Column {
  id: tab
  property var theme
  property real base: 16
  signal copyRequested(string value)
  spacing: 10

  function fromPx() {
    var px = C.num(pxField.text)
    remField.text = isNaN(px) ? "" : C.fmt(px / tab.base)
  }
  function fromRem() {
    var r = C.num(remField.text)
    pxField.text = isNaN(r) ? "" : C.fmt(r * tab.base)
  }
  function setBase(b) {
    tab.base = b
    baseField.text = C.fmt(b)
    tab.fromPx()
  }

  Component.onCompleted: fromPx()

  RowLayout {
    width: parent.width
    spacing: 8
    NumField {
      id: baseField
      theme: tab.theme
      Layout.fillWidth: true
      label: "Base font size"
      suffix: "px"
      text: "16"
      onEdited: {
        var b = C.num(text)
        if (b > 0) { tab.base = b; tab.fromPx() }
      }
    }
    Chip {
      theme: tab.theme
      Layout.alignment: Qt.AlignBottom
      text: "Reset to 16"
      visible: tab.base !== 16
      onClicked: tab.setBase(16)
    }
  }

  RowLayout {
    width: parent.width
    spacing: 8
    NumField {
      id: pxField
      theme: tab.theme
      Layout.fillWidth: true
      label: "Pixels"
      suffix: "px"
      text: "24"
      onEdited: tab.fromPx()
    }
    Text {
      Layout.alignment: Qt.AlignBottom
      Layout.bottomMargin: 6
      text: "⇄"
      color: tab.theme.muted
      font.family: tab.theme.font
      font.pixelSize: tab.theme.body
    }
    NumField {
      id: remField
      theme: tab.theme
      Layout.fillWidth: true
      label: "Rem"
      suffix: "rem"
      onEdited: tab.fromRem()
    }
  }

  Row {
    spacing: 6
    Chip { theme: tab.theme; text: "Copy rem"; onClicked: tab.copyRequested(remField.text + "rem") }
    Chip { theme: tab.theme; text: "Copy px"; onClicked: tab.copyRequested(pxField.text + "px") }
  }

  Text {
    text: "Common sizes at " + C.fmt(tab.base) + "px base — click to copy"
    color: tab.theme.muted
    font.family: tab.theme.font
    font.pixelSize: tab.theme.small
  }

  Grid {
    width: parent.width
    columns: 3
    columnSpacing: 6
    rowSpacing: 6
    Repeater {
      model: [10, 12, 14, 16, 18, 20, 24, 28, 32, 40, 48, 64]
      delegate: Chip {
        required property var modelData
        theme: tab.theme
        width: (tab.width - 12) / 3
        text: modelData + "px = " + C.fmt(modelData / tab.base) + "rem"
        onClicked: tab.copyRequested(C.fmt(modelData / tab.base) + "rem")
      }
    }
  }
}
