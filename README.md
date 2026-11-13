# MCF Converter

A converter for the Omarchy 4 (Quattro) bar: px ↔ rem, fluid typography
`clamp()`, metric/imperial measures, and currency. It is a native shell
plugin, so it uses your active Omarchy theme colours and font and re-colours
itself when you switch themes.

## Install

```sh
cd mcf-converter
./install.sh
```

Or, if you push this folder to a git repo:

```sh
omarchy plugin add https://github.com/<you>/mcf-converter.git --enable
```

The icon lands in the right-hand section of the bar. Drag it beside the tray
chevron to set its position.

## Use

- **Click the icon** to start the converter and open it. Nothing beyond the
  icon is loaded until this first click.
- **Close** (or Esc, or click outside) hides the panel but keeps it running,
  with your values intact, until you log out or shut down.
- **Quit** (the button in the panel, or right-click the icon) unloads it.
  The dimmed icon means it isn't running.

Tabs:

- **px ↔ rem** — base defaults to 16px; edit either side.
- **Fluid type** — min/max font size and viewport, entered in px or rem
  (switching converts the values you've typed), root 16px. Outputs
  `clamp()` in rem or px, against `vw` or `cqi`.
- **Measure** — length, volume (ml/l/cups…), weight, temperature, data.
- **Currency** — defaults to ZAR → USD; live rates from ExchangeRate-API (no key), fetched only
  when you open this tab.

Click any result to copy it to the clipboard.

Optional keybinding: bind `omarchy-shell shell toggle superseed.mcf-converter '{}'`.

## Uninstall

```sh
./uninstall.sh
```

or `omarchy plugin remove superseed.mcf-converter`, or **Setup > Plugins** in
the Omarchy menu.
