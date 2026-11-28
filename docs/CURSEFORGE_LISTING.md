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

Threat warnings for tanks, DPS, and healers, a swing timer with a range box, and tank tools for marks, pings, and pulls. For WoW: Forever and Classic Era.

## Description

Paste this with the description editor in Markdown mode. Pasted into the rich
text editor, the headings, bullets, and bold show as raw, escaped markdown.

```markdown
I got tired of groups falling apart over threat. The mage pulls a mob off the tank, a mob jumps the healer, or the tank never sees the add that ran to the back. Everyone in the group needs to know who has aggro, and the tank is only one of them. So I made **Dyre's Threat and Combat Tools**. It's on for every player who installs it, and every part has its own on/off switch, so you keep only the parts you use.

These tools used to be part of Dyre's Toolkit. I gave them their own AddOn so players who want only the simple Dyre's AddOns don't get them. If you used them in the Toolkit, your settings come with you the first time you log in.

### Threat on your nameplates
- **Threat on nameplates.** An icon and your threat percent show beside every enemy nameplate and above your target, in green, yellow, or red, so you can read a whole pack at a glance.
- **Tank view.** The icon is a shield. It's green while a mob is on you, yellow when another player gets close, blue when another tank has the mob, and red when you've lost it. An orange LOSING label warns you when a DPS passes you on a mob you still hold.
- **DPS and healer view.** The icon is crossed swords. It's green while you're safe and yellow as you get close on your target. It turns orange when you pass the tank, and red when the mob is on you.
- **Auto view.** This is the default. You get the tank view when you're the group's tank, or in Bear Form, Defensive Stance, or Righteous Fury, and the DPS and healer view the rest of the time.
- **Threat sounds.** A sound plays for red and for LOSING, so you hear it while your eyes are on the boss. The sounds play only in a group, unless you turn on "Threat sounds when solo". Pick a game warning sound, a sound from Dyre's Sounds if you have it, or None.
- **Pull bars.** In a party, the tank view shows a thin bar per party member under each nameplate. The bar is full when that player pulls the mob off you.
- You can move and resize the labels with sliders.

### Swing timer and range box
- **Swing bars.** You get a bar for each swing: main hand, off hand, and ranged. Only the bars you use show, so the frame stays small.
- **Range box.** The box around the bars turns green in range and red out of range, and the text on it says RANGE, MELEE, DEAD ZONE, TOO CLOSE, or TOO FAR.
- **Hunter zones.** A red zone shows when to hold still for Auto Shot. Orange zones show when Aimed Shot or Sniper Shot would clip Auto Shot, and they follow your haste.
- Show the timer in combat, always, or never. Pick one of two themes, the size and width, and the opacity in and out of combat.

### Group warnings
- **Pet taunt on.** Hunters and Warlocks get a message when Growl, Torment, or Suffering is on autocast in a group where they're not the tank, so you can turn it off before your pet takes a mob from the tank.

### Tank tools
- **Marking in combat.** Mark mobs in combat without the "blocked from an action" popup. Skull goes on the mob under your mouse, or on your target. Next marker walks through cross, square, triangle, diamond, circle, and star. Moon stays free for Banish and Polymorph.
- **Pings.** On Forever you get Attack, Warning, Assist, and On my way, plus one button that puts the skull on a mob and pings Attack on it in one press.
- **Pull countdown.** Click PULL or type `/dct pull 10`. If you run Deadly Boss Mods or BigWigs, your boss mod runs the pull. If not, the game's own countdown starts, and the whole group sees it.
- **Dyre's countdown on screen.** A big number pops each second over a bar that drains, with who started the pull and a "PULL!" splash at the end. It hides when your boss mod shows its own pull bar.
- **The tank bar.** All the buttons sit on one bar, and each one has a key binding. The bar shows while you tank, or always, or never. With Dyre's Toolkit 2.18.0 or later, it can be a row or a column.

### Commands
- `/dct` opens the settings.
- `/dct pull 10` starts a 10-second pull, and `/dct pull 0` cancels it.
- `/dct reset` puts the tank bar back where it started, and `/dct swing_reset` does the same for the swing timer.

### Works with
- Dyre's Toolkit is required, and the CurseForge app installs it for you. It gives you the layout mode (`/dyre unlock`), the settings home, and one profile per character for every Dyre's AddOn.
- Dyre's Sounds is optional. It adds more sounds to pick from.

### Compatibility
For World of Warcraft: Forever 1.60.1 and Classic Era 1.15.9. Classic Era has no pings, and the swing bars need Forever, so on Classic Era you get the range box only.

Let me know what you think!

Dyre's AddOns are free. If you enjoy them, you can support them on Ko-fi: https://ko-fi.com/dyre_janelle

Source and issues (MIT): https://github.com/jbedworth/DyresCombatTools
```
