import QtQuick
import QtQuick.Layouts
import "Converters.js" as C

// Fluid typography clamp() generator (root defaults to 16px).
Column {
  id: tab
  property var theme
  property string unit: "vw"
  property bool remOut: true
  property bool remIn: false        // false = inputs in px, true = inputs in rem
  readonly property string inUnit: tab.remIn ? "rem" : "px"
  readonly property real rootPx: C.num(rootFs.text)
  signal copyRequested(string value)
  spacing: 10

  // Convert an input field to px (rem inputs are multiplied by the root size).
  function px(field) {
    var v = C.num(field.text)
    return tab.remIn ? v * tab.rootPx : v
  }

  // Switch input unit and convert the values already typed, so 16px <-> 1rem.
  function setInputUnit(useRem) {
    if (useRem === tab.remIn) return
    var r = tab.rootPx > 0 ? tab.rootPx : 16
    var fields = [minFs, maxFs, minVp, maxVp]
    for (var i = 0; i < fields.length; i++) {
      var v = C.num(fields[i].text)
      if (!isNaN(v)) fields[i].text = C.fmt(useRem ? v / r : v * r)
    }
    tab.remIn = useRem
  }

  readonly property var result: C.fluid(
    px(minVp), px(maxVp), px(minFs), px(maxFs),
    tab.rootPx, tab.unit, tab.remOut)

  Row {
    spacing: 6
    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "Enter values in"
      color: tab.theme.muted
      font.family: tab.theme.font
      font.pixelSize: tab.theme.small
    }
    Chip { theme: tab.theme; text: "px"; selected: !tab.remIn; onClicked: tab.setInputUnit(false) }
    Chip { theme: tab.theme; text: "rem"; selected: tab.remIn; onClicked: tab.setInputUnit(true) }
  }

  GridLayout {
    width: parent.width
    columns: 2
    columnSpacing: 8
    rowSpacing: 8
    NumField { id: minFs; theme: tab.theme; Layout.fillWidth: true; label: "Min font size"; suffix: tab.inUnit; text: "16" }
    NumField { id: maxFs; theme: tab.theme; Layout.fillWidth: true; label: "Max font size"; suffix: tab.inUnit; text: "24" }
    NumField { id: minVp; theme: tab.theme; Layout.fillWidth: true; label: "Min viewport"; suffix: tab.inUnit; text: "320" }
    NumField { id: maxVp; theme: tab.theme; Layout.fillWidth: true; label: "Max viewport"; suffix: tab.inUnit; text: "1240" }
    NumField { id: rootFs; theme: tab.theme; Layout.fillWidth: true; label: "Root font size"; suffix: "px"; text: "16" }
    Text {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignBottom
      Layout.bottomMargin: 6
      visible: tab.remIn
      text: "rem inputs use this root"
      color: tab.theme.muted
      font.family: tab.theme.font
      font.pixelSize: tab.theme.small
      wrapMode: Text.WordWrap
    }
  }

  GridLayout {
    width: parent.width
    columns: 2
    columnSpacing: 10
    rowSpacing: 6

    Text { text: "Output in"; color: tab.theme.muted; font.family: tab.theme.font; font.pixelSize: tab.theme.small }
    Row {
      spacing: 6
      Chip { theme: tab.theme; text: "rem"; selected: tab.remOut; onClicked: tab.remOut = true }
      Chip { theme: tab.theme; text: "px"; selected: !tab.remOut; onClicked: tab.remOut = false }
    }

    Text { text: "Relative to"; color: tab.theme.muted; font.family: tab.theme.font; font.pixelSize: tab.theme.small }
    Row {
      spacing: 6
      Chip { theme: tab.theme; text: "vw (viewport)"; selected: tab.unit === "vw"; onClicked: tab.unit = "vw" }
      Chip { theme: tab.theme; text: "cqi (container)"; selected: tab.unit === "cqi"; onClicked: tab.unit = "cqi" }
    }
  }

  // The output — the one big thing on this tab.
  Rectangle {
    width: parent.width
    height: out.implicitHeight + 20
    radius: tab.theme.radius
    color: tab.theme.field
    border.width: 1
    border.color: outMouse.containsMouse ? tab.theme.fg : tab.theme.line

    Text {
      id: out
      anchors.fill: parent
      anchors.margins: 10
      text: tab.result.ok ? tab.result.css : tab.result.error
      color: tab.result.ok ? tab.theme.fg : tab.theme.muted
      font.family: tab.theme.font
      font.pixelSize: tab.theme.body + 1
      font.bold: tab.result.ok
      wrapMode: Text.WrapAnywhere
      verticalAlignment: Text.AlignVCenter
    }
    MouseArea {
      id: outMouse
      anchors.fill: parent
      hoverEnabled: true
      enabled: tab.result.ok
      cursorShape: Qt.PointingHandCursor
      onClicked: tab.copyRequested(tab.result.css)
    }
  }

  Row {
    spacing: 6
    visible: tab.result.ok
    Chip { theme: tab.theme; text: "Copy clamp()"; onClicked: tab.copyRequested(tab.result.css) }
    Chip { theme: tab.theme; text: "Copy as font-size"; onClicked: tab.copyRequested("font-size: " + tab.result.css + ";") }
  }

  Text {
    visible: tab.result.ok
    text: "Rendered size at common " + (tab.unit === "vw" ? "viewport" : "container") + " widths"
    color: tab.theme.muted
    font.family: tab.theme.font
    font.pixelSize: tab.theme.small
  }

  Column {
    width: parent.width
    visible: tab.result.ok
    Repeater {
      model: [375, 768, 1024, 1280, 1440, 1920]
      delegate: ResultRow {
        required property var modelData
        theme: tab.theme
        width: tab.width
        label: modelData + "px"
        value: tab.result.ok ? C.fmt(tab.result.sizeAt(modelData)) + "px" : ""
        onClicked: tab.copyRequested(value)
      }
    }
  }
}
