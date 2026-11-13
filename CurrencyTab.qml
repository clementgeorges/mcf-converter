import QtQuick
import QtQuick.Layouts
import "Converters.js" as C

// Currency conversion. Rates are fetched only when this tab is first shown,
// then kept in memory until the converter is quit.
Column {
  id: tab
  property var theme
  property var rates: null
  property string updated: ""
  property string status: ""
  property string from: "ZAR"
  property string to: "USD"
  signal copyRequested(string value)
  spacing: 10

  readonly property real amount: C.num(amountField.text)
  readonly property bool ready: tab.rates !== null && tab.rates[tab.from] !== undefined && tab.rates[tab.to] !== undefined
  readonly property real result: ready ? tab.amount / tab.rates[tab.from] * tab.rates[tab.to] : NaN

  function fetchRates() {
    tab.status = "Fetching today's rates…"
    var x = new XMLHttpRequest()
    x.onreadystatechange = function() {
      if (x.readyState !== XMLHttpRequest.DONE) return
      if (x.status === 200) {
        try {
          var d = JSON.parse(x.responseText)
          if (d.result === "success") {
            tab.rates = d.rates
            tab.updated = d.time_last_update_utc || ""
            tab.status = ""
          } else {
            tab.status = "The rate service returned an error. Try Refresh."
          }
        } catch (e) {
          tab.status = "Couldn't read the rates. Try Refresh."
        }
      } else {
        tab.status = "No connection to the rate service. Check your network, then Refresh."
      }
    }
    x.open("GET", "https://open.er-api.com/v6/latest/USD")
    x.send()
  }

  onVisibleChanged: if (visible && tab.rates === null && tab.status === "") fetchRates()
  Component.onCompleted: if (visible) fetchRates()

  RowLayout {
    width: parent.width
    spacing: 8
    NumField {
      id: amountField
      theme: tab.theme
      Layout.fillWidth: true
      label: "Amount"
      suffix: tab.from
      text: "100"
    }
    Chip {
      theme: tab.theme
      Layout.alignment: Qt.AlignBottom
      text: "⇄ Swap"
      onClicked: { var f = tab.from; tab.from = tab.to; tab.to = f }
    }
  }

  Text { text: "From"; color: tab.theme.muted; font.family: tab.theme.font; font.pixelSize: tab.theme.small }
  Flow {
    width: parent.width
    spacing: 5
    Repeater {
      model: C.currencies
      delegate: Chip {
        required property var modelData
        theme: tab.theme
        text: modelData
        selected: tab.from === modelData
        onClicked: tab.from = modelData
      }
    }
  }

  Text { text: "To"; color: tab.theme.muted; font.family: tab.theme.font; font.pixelSize: tab.theme.small }
  Flow {
    width: parent.width
    spacing: 5
    Repeater {
      model: C.currencies
      delegate: Chip {
        required property var modelData
        theme: tab.theme
        text: modelData
        selected: tab.to === modelData
        onClicked: tab.to = modelData
      }
    }
  }

  ResultRow {
    theme: tab.theme
    width: parent.width
    emphasis: true
    visible: tab.ready
    label: C.money(tab.amount) + " " + tab.from + " ="
    value: C.money(tab.result) + " " + tab.to
    onClicked: tab.copyRequested(C.money(tab.result).replace(/ /g, ""))
  }

  Text {
    width: parent.width
    visible: tab.ready
    text: "1 " + tab.from + " = " + C.fmt(tab.rates ? tab.rates[tab.to] / tab.rates[tab.from] : NaN) + " " + tab.to
    color: tab.theme.muted
    font.family: tab.theme.font
    font.pixelSize: tab.theme.small
  }

  Text {
    width: parent.width
    visible: tab.status !== ""
    text: tab.status
    color: tab.theme.fg
    font.family: tab.theme.font
    font.pixelSize: tab.theme.small
    wrapMode: Text.WordWrap
  }

  RowLayout {
    width: parent.width
    Text {
      Layout.fillWidth: true
      text: tab.updated !== "" ? "Rates by ExchangeRate-API · updated " + tab.updated : "Rates by ExchangeRate-API"
      color: tab.theme.muted
      font.family: tab.theme.font
      font.pixelSize: Math.max(9, tab.theme.small - 1)
      wrapMode: Text.WordWrap
    }
    Chip { theme: tab.theme; text: "Refresh"; onClicked: tab.fetchRates() }
  }
}
