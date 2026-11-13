import QtQuick
import Quickshell
import qs.Ui

// MCF Converter — bar entry point.
// The converter panel is NOT loaded until you first click the icon, and it
// stays loaded (keeping your values) until you Quit or the session ends.
BarWidget {
  id: root
  moduleName: "superseed.mcf-converter"

  // false = not running (panel unloaded, nothing in memory but this icon)
  property bool running: false

  readonly property bool opened: panelLoader.item
    ? panelLoader.item.opened === true
    : false
  readonly property bool popoutSwitchClosing: panelLoader.item
    ? panelLoader.item.popoutSwitchClosing === true
    : false

  function start() {
    if (!root.running) root.running = true
  }

  function open() {
    root.start()
    if (panelLoader.item) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item) panelLoader.item.close()
  }

  function toggle() {
    if (!root.running || !panelLoader.item) { root.open(); return }
    panelLoader.item.toggle()
  }

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  // Close the panel, then unload it completely.
  function quit() {
    root.close()
    quitTimer.restart()
  }

  function injectPanel() {
    if (!panelLoader.item) return
    panelLoader.item.bar = root.bar
    panelLoader.item.anchorItem = button
    panelLoader.item.hostWidget = root
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()

  Timer {
    id: quitTimer
    interval: 260
    onTriggered: root.running = false
  }

  Loader {
    id: panelLoader
    active: root.running
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰑭"
    opacity: root.running ? 1.0 : 0.55
    tooltipText: root.running
      ? "MCF Converter — click to show/hide · right-click to quit"
      : "MCF Converter — click to start"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.LeftButton) root.toggle()
      else if (buttonCode === Qt.RightButton && root.running) root.quit()
    }
  }
}
