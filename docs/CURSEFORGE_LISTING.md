# CurseForge listing

Copy-ready text for the CurseForge project form. Keep it aligned with README.md
and the tested client; do not advertise clients or versions that have not been
tested.

## Project fields

| Field | Value |
| --- | --- |
| Name | Dyre's Threat and Combat Tools |
| Slug | dyres-threat-and-combat-tools (CurseForge makes it from the name) |
| Project ID | 1833655 |
| Class | Addons |
| Main category | Combat |
| Additional categories | PvE, Unit Frames (optional) |
| Author shown | Dyre, set through the CurseForge account's username |
| License | MIT License |
| Logo | `artwork/dyres-combat-tools-logo-512.png` (1024 master and SVG source in `artwork/`) |
| Relations | Dyre's Toolkit (required dependency, slug dyres-toolkit); Dyre's Sounds (optional dependency, slug dyres-sounds) |
| Source | https://github.com/jbedworth/DyresCombatTools |
| Issues | https://github.com/jbedworth/DyresCombatTools/issues |
| Donation | Ko-fi, https://ko-fi.com/dyre_janelle (the project's Donation field) |

## Summary

Threat warnings for tanks, DPS, and healers, a swing timer with a range box, and tank tools: markers, pings, and pull countdowns, for WoW: Forever.

## Description

Paste this with the description editor in Markdown mode. Pasted into the rich
text editor, the headings, bullets, and bold show as raw, escaped markdown.

```markdown
**Dyre's Threat and Combat Tools** tells you when you pull aggro, or lose it. Tanks, DPS, and healers all need to know, so it is on for everyone who installs it. Every part has its own switch.

The threat labels, swing timer, and tank tools were part of Dyre's Toolkit. They now have their own AddOn, so players who want only the simple Dyre's AddOns do not get them. Your settings come with you.

### Threat
- **Threat beside enemy nameplates and above your target:** an icon for your view and your threat percent, both in green, yellow, or red.
- **Tank view (shield):** green while the mob is on you. Yellow while another player nears the pull point, and yellow PULLING (no sound) while a mob has not turned to you yet. Blue while another tank holds it. Red, with a siren, when someone else has more threat and the mob is not on you. LOSING in orange when another player passes you on a mob you still hold.
- **DPS and healer view (crossed swords):** green below the tank. Yellow near the pull point on your target. Orange when you have more threat than the tank. Red when the mob is on you.
- **Auto** (the default) chooses the view: the tank view for the group's Tank or raid main tank, a Druid in Bear Form, a Paladin with Righteous Fury, or a Warrior in Defensive Stance; else the DPS and healer view.
- **Sounds** play only in a party or raid, unless you turn on "Threat sounds when solo". Choose each one from the game's warning sounds, or from Dyre's Sounds when it is installed, or None.
- **Pull bars** (tank view, in a party): a thin bar per party member under each enemy nameplate, full when that member pulls the mob.
- Move and resize the labels with sliders.

### Swing timer and range box
- A bar for each swing (main hand, off hand, ranged) in a box that turns green in range and red out of range, with the state as text: RANGE, MELEE, DEAD ZONE, TOO CLOSE, or TOO FAR.
- **Hunters:** the red "hold still" zone of Auto Shot, and orange clip zones for Aimed Shot and Sniper Shot, with your haste.
- **Only bars in use:** the frame grows and shrinks with the swings you use.
- Show it in combat, always, or never. Two themes, size and width, and opacity in and out of combat.

### Group warnings
- **Pet taunt on:** Hunters and Warlocks get a message when Growl, Torment, or Suffering is on autocast in a group where they are not the tank.

### Tank tools
- **Marking in combat** with no "blocked from an action" popup: Skull (the mob under your mouse, else your target) and Next marker. Moon stays free for crowd control.
- **Pings:** Attack, Warning, Assist, On my way, and Skull and ping in one press.
- **Pull countdown:** the PULL button or a command. With Deadly Boss Mods or BigWigs, they run the pull; else the game's countdown.
- **Dyre's countdown on screen:** a big countdown with a draining bar, who started it, and a "PULL!" splash. It never overrides another AddOn's pull bar.
- The buttons are on one bar with key bindings. The bar shows while you tank, or always, or never.

### Works with
- **Dyre's Toolkit** (required): one layout mode, snapping and a grid, the minimap button, the settings home, and one profile per character for every Dyre's AddOn.
- **Dyre's Sounds** (optional): more sounds to choose from.

### Compatibility
For World of Warcraft: Forever 1.60.1 (tested on build 70888). On Classic Era, the swing bars need Forever's swing event, so only the range box works.

Source, issues, and license (MIT): https://github.com/jbedworth/DyresCombatTools
```
