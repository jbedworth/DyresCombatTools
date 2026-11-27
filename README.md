# Dyre's Threat and Combat Tools

Threat warnings for tanks, DPS, and healers, a swing timer with a range box,
and tank tools (markers, pings, and pull countdowns) for World of Warcraft:
Forever and Classic Era. It is on for everyone who installs it; every part has
its own switch.

These features were part of Dyre's Toolkit (2.9.0 to 2.15.x). They now have
their own AddOn, so players who want only the simple Dyre's AddOns do not get
them. Your settings come with you: at its first login on a character, DCT
copies that character's threat, tank, and swing timer settings from Dyre's
Toolkit, once.

## Needs

- **Dyre's Toolkit 2.16.0 or later** (required; the CurseForge app installs
  it): the layout mode, the settings home, and the profile. Without it, DCT
  says so once in chat and stays off.
- While an older Dyre's Toolkit (which still has these features) is loaded,
  DCT stays off and says nothing, so nothing shows or sounds twice. Update
  Dyre's Toolkit and DCT turns on at the next login.
- **Dyre's Sounds** (optional): more sounds to choose from.

## Threat indicators and group warnings

- **Threat** beside enemy nameplates and above your target: an icon for your
  view and your threat percent, both in green, yellow, or red.
  - Shield, the tank view: green while the mob is on you, yellow while another
    player or pet has more threat or is at 80% of the pull point, blue while
    another tank has it, yellow PULLING while it has not turned to you yet
    but nobody has more threat (no sound), red when someone else has more
    threat and it is not on you.
  - Crossed swords, the DPS and healer view: green below the tank, yellow
    at 80% of the pull point (on your target), orange when you have more
    threat than the tank, red when the mob is on you. Orange and red play
    the same two sounds as the tank view; yellow is silent.
  - Auto (default) uses the tank bar's rule: the tank view for group role
    Tank or raid main tank, a Druid in Bear Form, a Paladin with Righteous
    Fury, or a Warrior in Defensive Stance; else the DPS view. Or choose
    Tank or DPS/Healer.
  - "Alert sound (red)" when a mob turns red (by default "Dyre's Alerts: Bell buzz"
    from Dyre's Sounds 1.5.0 or later; without it, the game's raid
    warning).
  - Tank view on nameplates: LOSING in orange when another player has more
    threat on a mob you still hold, with "Warning sound (orange)" (by default "Dyre's
    Alerts: Cartoon shake" from Dyre's Sounds 1.5.0 or later; without it,
    the game's quest failed sound).
  - Choose each sound from eight game sounds ("Game Warnings"), or None;
    with Dyre's Sounds installed, all of its sounds too, in its groups. A
    choice plays once so you can hear it. The sounds play only in a party
    or raid, unless you turn on "Threat sounds when solo".
  - Pull bars (tank view, in a party): a thin bar per party member under
    each enemy nameplate, full when that member pulls the mob.
  - Where Forever hides the threat state in combat, the percent shows in white.
  - Move the labels: left/right and up/down sliders (-50 to 50 pixels) for
    the nameplate labels and for the target label, which also set the gap.
  - Resize the labels: a size slider (50% to 200%) for the nameplate labels
    and one for the target label.
- **Pet taunt on**: Hunters and Warlocks get a message on screen and in chat
  when Growl, Torment, or Suffering is on autocast in a group where they are
  not the tank.

Each has its own switch, on at first except "Threat sounds when solo". The
settings page has the sections Threat Indicators: Nameplates, Threat
Indicators: Target Frame, Threat Indicators: Sounds, Group Warnings, and Tank
Tools. Each section starts with its own **Enable** switch, on at first, so
you can turn off any feature you do not use (for example the threat sounds)
and keep the rest.

## Tank tools

- **Marking in combat** with no "blocked from an action" popup: Skull (the
  mob under your mouse, else your target), and Next marker
  (skull, cross, square, triangle, diamond, circle, star). Moon stays free for
  Banish and Polymorph.
- **Pings** (Forever): Attack, Warning, Assist, On my way, and Skull and ping
  in one press (on the mob under your mouse, else your target). Classic Era has no pings.
- **Pull countdown**: the PULL button or `/dct pull 10` (`/dct pull 0`
  cancels). With Deadly Boss Mods or BigWigs, they run the pull; else the
  game's countdown, which every group member sees. If the game refuses it
  (it may need the group leader), players in your group with DCT (or Dyre's Toolkit 2.15.x) still
  get Dyre's countdown.
- **Dyre's countdown on screen**: when anyone in your group starts a pull,
  a big number in the middle of the screen that pops each second (gold,
  then orange at 3, red at 1), a bar that drains over the whole pull, who
  started it, and a "PULL!" splash at 0; "Pull cancelled" on a cancel. It
  takes the place of the game's own countdown. It never overrides another
  AddOn: with BigWigs it stays hidden (BigWigs always shows its own pull
  bar); with Deadly Boss Mods it stays hidden unless you turn on DBM's own
  "Do not show Pull/Break Timer bar" (and "Do not show announce text") in
  /dbm > Global Disables & Filters > Disable DBM Features. Choose the
  tick and go sounds (game sounds, or Dyre's Sounds), the size, and the
  opacity; `/dyre unlock` to move it. The checkbox is only the display:
  sending a pull always uses the best path.
- `/dct debug` also lists the boss mod and version each group member runs,
  as heard from Deadly Boss Mods' and BigWigs' own version messages
  (DCT sends nothing to find out).

The buttons are on one bar, and each has a key binding: Key Bindings >
AddOns > Dyre's Threat and Combat Tools (Dyre's Toolkit defines them, with the same names as before, so your keys stay). The bar shows while you tank: group role Tank,
Defensive Stance, Bear Form, or Righteous Fury, and hides 30 seconds out of
combat after the last of them ends. Set it to Always or Never in the settings.
The settings are per character, and are one part of the Dyre's Toolkit
Profile: copy, export, and import it on Dyre's Toolkit's own settings page.


## Swing timer and range box

- A bar for each swing (main hand, off hand, ranged) in a box that turns
  green in range and red out of range, with the state as text: RANGE, MELEE,
  DEAD ZONE, TOO CLOSE, or TOO FAR.
- Hunters: the red "hold still" zone of Auto Shot, and orange clip zones for
  Aimed Shot and Sniper Shot, with your haste.
- Only bars in use: the frame grows and shrinks with the swings you use.
- Show it in combat (the default), always, or never. Two themes, size and
  width, and opacity in and out of combat.
- On Classic Era the swing bars need Forever's swing event, so only the range
  box works.

## Commands

| Command | What it does |
| --- | --- |
| `/dct` | Opens the settings (out of combat) |
| `/dct pull [seconds]` | Starts the pull countdown (1 to 60); `/dct pull 0` cancels |
| `/dct reset` | Puts the tank button bar back in its first place |
| `/dct swing_reset` | Puts the swing timer back in its default place |
| `/dct debug`, `/dct debug_threat`, `/dct debug_taunts`, `/dct debug_dots`, `/dct debug_swing` | Diagnostics |

If another AddOn also uses `/dct`, DCT says so at login; the settings are
always in Options > AddOns > Dyre's AddOns > Threat and Combat Tools. Move the
frames with Dyre's Toolkit's `/dyre unlock` and `/dyre lock`.

## Compatibility

For WoW: Forever 1.60.1 (build 70888, Interface 16001) and Classic Era 1.15.9
(Interface 11509).

## Support

Dyre's AddOns are free. If you enjoy them, you can support them on Ko-fi: https://ko-fi.com/dyre_janelle

## License

MIT; see LICENSE.
