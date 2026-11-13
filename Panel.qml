import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "superseed.mcf-converter"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property int tab: 0
  property string toast: ""

  // Everything visual is derived from the live Omarchy theme, so switching
  // themes re-colours the converter instantly.
  property QtObject theme: QtObject {
    readonly property color fg: root.barForeground
    readonly property color bgRaw: root.bar ? root.bar.background : "#1a1b26"
    readonly property color bg: Qt.rgba(bgRaw.r, bgRaw.g, bgRaw.b, 1)
    readonly property color line: Qt.rgba(fg.r, fg.g, fg.b, 0.22)
    readonly property color hover: Qt.rgba(fg.r, fg.g, fg.b, 0.10)
    readonly property color field: Qt.rgba(fg.r, fg.g, fg.b, 0.06)
    readonly property color muted: Qt.rgba(fg.r, fg.g, fg.b, 0.62)
    readonly property string font: root.bar ? root.bar.fontFamily : Style.font.family
    readonly property int body: Style.font.subtitle
    readonly property int small: Math.max(10, Style.font.subtitle - 2)
    readonly property int big: Style.font.subtitle + 4
    readonly property int radius: 4
  }

  function open() {
    root.controller.show()
  }

  function close() {
    root.controller.hide()
  }

  function quitApp() {
    if (root.hostWidget && typeof root.hostWidget.quit === "function") root.hostWidget.quit()
    else root.close()
  }

  function copy(value) {
    if (!value || value === "—") return
    if (root.bar && typeof root.bar.run === "function")
      root.bar.run("printf %s " + Util.shellQuote(value) + " | wl-copy")
    root.toast = "Copied " + value
    toastTimer.restart()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.hostWidget || root, direction)
    return false
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(400))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: content
        width: parent.width
        spacing: Style.space(10)

        Timer {
          id: toastTimer
          interval: 1600
          onTriggered: root.toast = ""
        }

        RowLayout {
          width: parent.width
          spacing: 6
          Text {
            Layout.fillWidth: true
            text: "MCF Converter"
            color: root.theme.fg
            font.family: root.theme.font
            font.pixelSize: root.theme.big
            font.bold: true
          }
          Chip { theme: root.theme; text: "Close"; onClicked: root.close() }
          Chip { theme: root.theme; text: "Quit"; onClicked: root.quitApp() }
        }

        Flow {
          width: parent.width
          spacing: 6
          Repeater {
            model: ["px ↔ rem", "Fluid type", "Measure", "Currency"]
            delegate: Chip {
              required property var modelData
              required property int index
              theme: root.theme
              text: modelData
              selected: root.tab === index
              onClicked: root.tab = index
            }
          }
        }

        Rectangle { width: parent.width; height: 1; color: root.theme.line }

        RemTab {
          width: parent.width
          theme: root.theme
          visible: root.tab === 0
          onCopyRequested: function(value) { root.copy(value) }
        }
        FluidTab {
          width: parent.width
          theme: root.theme
          visible: root.tab === 1
          onCopyRequested: function(value) { root.copy(value) }
        }
        MeasureTab {
          width: parent.width
          theme: root.theme
          visible: root.tab === 2
          onCopyRequested: function(value) { root.copy(value) }
        }
        CurrencyTab {
          width: parent.width
          theme: root.theme
          visible: root.tab === 3
          onCopyRequested: function(value) { root.copy(value) }
        }

        Text {
          width: parent.width
          height: implicitHeight
          text: root.toast !== "" ? root.toast : "Click any result to copy it · Esc to close"
          color: root.theme.muted
          font.family: root.theme.font
          font.pixelSize: root.theme.small
          elide: Text.ElideRight
        }
      }
    }
  }
}
