# Dyre's Threat and Combat Tools logo

Original vector artwork: two crossed steel swords with gold hilts over a
gold-edged crimson heater shield, on a rich dark-brown background. It shares
its frame and colors with the other Dyre's logos. The design has no font or
external-image dependencies.

- `dyres-combat-tools-logo.svg`: editable, resolution-independent source.
- `dyres-combat-tools-logo.png`: 1024 x 1024 PNG master.
- `dyres-combat-tools-logo-512.png`: 512 x 512 PNG for square project images.

The PNGs are rendered from the SVG with headless Chrome, for example:

```sh
chrome --headless=new --hide-scrollbars --window-size=1024,1024 --force-device-scale-factor=0.5 --screenshot=dyres-combat-tools-logo-512.png dyres-combat-tools-logo.svg
```

Use these files for project pages and distribution branding. Keep this
directory out of the runtime release ZIP.
