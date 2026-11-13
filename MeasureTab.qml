import QtQuick
import QtQuick.Layouts
import "Converters.js" as C

// Length, volume, weight, temperature and data. Shows every target unit at once.
Column {
  id: tab
  property var theme
  property int cat: 0
  property string from: C.categories[0].def
  signal copyRequested(string value)
  spacing: 10

  readonly property var units: C.categories[tab.cat].units
  readonly property real value: C.num(valueField.text)

  onCatChanged: tab.from = C.categories[tab.cat].def

  Flow {
    width: parent.width
    spacing: 6
    Repeater {
      model: C.categories
      delegate: Chip {
        required property var modelData
        required property int index
        theme: tab.theme
        text: modelData.label
        selected: tab.cat === index
        onClicked: tab.cat = index
      }
    }
  }

  NumField {
    id: valueField
    theme: tab.theme
    width: parent.width
    label: "Value"
    suffix: tab.from
    text: "1"
  }

  Flow {
    width: parent.width
    spacing: 6
    Repeater {
      model: tab.units
      delegate: Chip {
        required property var modelData
        theme: tab.theme
        text: modelData.id === "m3" ? "m³" : modelData.id === "floz" ? "fl oz" : modelData.id
        selected: tab.from === modelData.id
        onClicked: tab.from = modelData.id
      }
    }
  }

  Rectangle { width: parent.width; height: 1; color: tab.theme.line }

  Column {
    width: parent.width
    Repeater {
      model: tab.units
      delegate: ResultRow {
        required property var modelData
        theme: tab.theme
        width: tab.width
        visible: modelData.id !== tab.from
        label: modelData.label
        value: C.fmt(C.convert(tab.cat, tab.value, tab.from, modelData.id))
        onClicked: tab.copyRequested(value)
      }
    }
  }
}
