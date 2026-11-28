# Agent Guidelines

## Project purpose and scope

Dyre's Threat and Combat Tools (DCT, `/dct`) is a World of
Warcraft: Forever and Classic Era AddOn: threat labels and sounds, pull bars,
the Pet Taunt warning, the tank button bar (marks, pings, pull), the pull
countdown, and the swing timer with its range box. These were part of Dyre's
Toolkit from 2.9.0 to 2.15.x. CurseForge comments on Mage Tools Forever
(2026-11-26) said the Toolkit added too many warnings and sounds; John
decided (2026-11-26) that they move to their own AddOn, so the Toolkit is a
quiet shared library again. CurseForge project ID 1833655
(dyres-threat-and-combat-tools). Keep this feature set; do not add
speculative features without agreement.

Naming: the apostrophe is only in the title; the folder, TOC, repository,
saved variables, and globals use `DyresCombatTools`. Chat prefix `DCT: `.
Listings say plainly that it is for WoW: Forever.

### Approved design (John, 2026-11-26)

- On for everyone who installs it; every part keeps its own switch (the
  section "Enable" checkboxes). The swing timer's Show is "In combat" by
  default in DCT (John, 2026-11-26: "if a user installs this new addon, the
  swing-timer should default to on. Off by default is a stop-gap for the
  current toolkit's behavior, not this addon's."). Toolkit 2.15.1's Off
  default is not copied (below).
- TOC: `## Interface: 16001, 11509`, `## OptionalDeps: DyresToolkit,
  DyresSounds` (never `## Dependencies`), `## Category: Dyre's AddOns`,
  `## Group: DyresToolkit` (needed for owner claims: the Toolkit's
  `ns.InFamily`), `## SavedVariablesPerCharacter: DyresCombatToolsCharDB`.
  CurseForge relations: dyres-toolkit required, dyres-sounds optional
  (scripts/publish_curseforge.py `RELATIONS`).
- Key bindings (John, 2026-11-26, "B now, service later"): DCT ships NO
  Bindings.xml and writes no `BINDING_` global. Dyre's Toolkit keeps its
  Bindings.xml for good (`CLICK DyresToolkit<Name>:LeftButton` names,
  header `DYRESTOOLKIT`; eight from 2.16.0, nine in 2.9-2.15), and from
  2.16.0 its Bindings.lua sets the header text "Dyre's Threat and Combat
  Tools" and the eight labels. Found in
  John's client with Toolkit 2.15.1 and a DCT build that had its own
  Bindings.xml: nine LUA_WARNING lines at each load, "Binding CLICK
  DyresToolkitSkull:LeftButton was attempted to be loaded more than once".
  DCT keeps the button names the bindings click, exactly:
  DyresToolkitSkull, DyresToolkitSkullMouseover, DyresToolkitNextMarker,
  DyresToolkitMarkPing, DyresToolkitPingAttack, DyresToolkitPingWarning,
  DyresToolkitPingAssist, DyresToolkitPingOnmyway, DyresToolkitPull
  (TankButtons.lua `PREFIX`).
- Skull (John, 2026-11-26: "The skull keybind should skull my
  mouseover,harm,nodead or harm,nodead target (like the ones below it)
  instead of two different keybinds"): Skull marks the mob under the mouse,
  else the target (`MarkLine(NEXT_UNITS, SKULL)`, Next marker's order); a
  click on the bar has no mob under the mouse, so it falls to the target.
  Skull and ping uses the same skull line and pings Attack on the same mob
  (`DTT.MarkPingLine`); the four ping buttons stay `@target` (`PingLine`).
  Toolkit 2.16.0 drops the "Skull the mob under your mouse" binding (eight
  rows) and names Skull "Skull mouseover, else target". The hidden
  `DyresToolkitSkullMouseover` button stays, with Skull's text, so a key
  bound to it in Toolkit 2.9-2.15 still marks. A Toolkit key-binding service (AddOns register
  bindings through the Toolkit API) is planned later, not now. Same pull
  addon-message prefix `DyresToolkit` (Pull.lua `PULL_PREFIX`), so a mixed
  group (DCT and Toolkit 2.15.x) sees each other's pulls. Never rename
  either.
- Other global frame names are DCT's own: `DyresCombatToolsSwingTimer`,
  `DyresCombatToolsPullTimer`, `DyresCombatToolsWarning`. The tank bar keeps
  `DyresToolkitTankBar` (PREFIX). Widget positions live in DCT's own saved
  table, not under the frame name.

### The gate (Core.lua; agreed with the Toolkit lead)

Core.lua loads first and decides once, as the files load, `ns.state`:

- `"missing"`: no `DyresToolkit` global, no contract 2, or one of
  `ns.TOOLKIT_FUNCTIONS` absent. DCT stays off and says once at
  PLAYER_LOGIN: "needs Dyre's Toolkit 2.16.0 or later".
- `"toolkit"`: the Toolkit still has these features:
  `SlashCmdList.DYRESTOOLKITTANK` exists (its Tank.lua's `/dtt`), or its TOC
  version is before `ns.TOOLKIT_WITHOUT_FEATURES` ("2.16.0"). A version that
  does not read counts only by the slash key. DCT stays off and silent.
- `"active"`: DCT runs.

Every other runtime file starts with `if not ns.active then return end`, so
an inactive DCT makes no frames, registers no events, no slash commands, no
profile part, and no owner claims. Only Core.lua runs. The Toolkit loads
first because of OptionalDeps.

### The one-time copy (Tank.lua `DTT.ImportFromToolkit`)

At DCT's first active login on a character (`toolkitImported` not true),
before `SanitizeDB`: every key in `DTT.TOOLKIT_KEYS` that DCT does not have
is deep-copied from `DyresToolkitCharDB` (read only; Toolkit 2.16.0 must
keep that SavedVariable and its keys). Then `toolkitImported = true`, saved,
and a profile `characterKeys` entry (never copied with a profile). One chat
line only when something was copied. The swing timer's `show`: Always and In
combat come; Off comes only when chosen (no `defaultsVersion`, a 2.15.0
save, or `showChosen` true, which Toolkit 2.15.1 sets when the player picks
Show); 2.15.1's default Off becomes DCT's default. `defaultsVersion` and
`showChosen` are dropped. `soundSaves`, `placeSaves`, and the old boolean
`sound` come too, so `SanitizeDB` reads an old save as the Toolkit did.
Limits: a profile snapshot taken before DCT (the Toolkit's `DyresToolkit`
part) is not read; copying another character's profile brings DCT settings
only once that character has logged in with DCT.

### Toolkit coupling

Only the public `DyresToolkit` API (contract 2): see `ns.TOOLKIT_FUNCTIONS`.
DCT's page is `RegisterSettingsCategory(ns.TITLE)` ("Threat and Combat
Tools" under "Dyre's AddOns"); the profile UI stays on the Toolkit's page
(no `AddProfileSettings` call). `ns.Report`, `ns.HomeCategory`,
`ns.AddDefaultTick`, and `ns.IsUnlocked` are DCT's own (Core.lua). The
Toolkit's `/dyre` words for these features are not DCT's; `/dct` has
`pull`, `reset`, `swing_reset`, `debug`, `debug_threat`, `debug_taunts`,
`debug_dots`, and `debug_swing`. DCT owns the kinds `threat`,
`warn:petTaunt`, `tank:markers`, `tank:pings`, `tank:pull`, and
`tank:pullDisplay` at 50 as "DyresCombatTools". Never change files in
`../DyresToolkit`; send Toolkit needs to the Toolkit lead.

## Feature notes, moved from Dyre's Toolkit's AGENTS.md

The sections below came with the code. Where they say "the toolkit", read
DCT; where they name `DyresToolkitCharDB` or `/dyre` words for these
features, read `DyresCombatToolsCharDB` and `/dct`. The decisions and
in-client findings in them still hold.

### Group warnings and tank tools (2.9.0; John, 2026-11-10)

Dyre's Tank Tools (src/DyresTankTools, never released) moved here whole
(John: "The DTT "tank only" parts also move into DT"), and Dyre's Buff
Reminders' Pet Taunt warning with it, so they are "universally available"
for tanks and non-tanks alike. Files: Tank.lua (the shared table `ns.tank`,
per-character settings, commands, API checks, owners, startup), Threat.lua,
PetTaunt.lua, TankButtons.lua, Pull.lua, TankProbe.lua, GroupSettings.lua,
and Bindings.xml (loaded by the client, not listed in the TOC). Core's
PLAYER_LOGIN calls `ns.InitializeTank` after the toolkit's own settings.

- Settings: `DyresToolkitCharDB` (`## SavedVariablesPerCharacter`; a tank
  and a DPS character want different views), repaired at login
  (`ns.tank.SanitizeDB`). All warnings on by default but solo sounds, each with a switch
  (John: "Warnings on by default, but a user can toggle them off"). Five
  sections on the toolkit's own page (John, 2026-11-12: "Group warnings has
  everything all mixed up; a kitchen sink of settings."): "Threat
  Indicators: Nameplates" (the threat view first, it sets every label and
  sound), "Threat Indicators: Target Frame", "Threat Indicators: Sounds"
  (red, losing, solo), "Group Warnings" (pull bars, the countdown and its
  sounds and sliders, the Pet Taunt warning), and "Tank Tools"; tests check
  the order (`ns.HomeCategory`). Each section starts with an "Enable"
  checkbox, on by default (unreleased; John, 2026-11-15: "Each of the
  non-core (core is the first group of options, positioning, grid, etc.)
  features of DT need an individual off/on toggle. E.g. first option under
  'Threat Indicators: Nameplates' should be an enable check-box, on by
  default."; a Shields Up user asked how to turn the threat sounds off):
  Nameplates and Target Frame are the old `plateThreat` and `targetThreat`
  switches, renamed "Enable" and moved first (the threat view moved under
  Nameplates' Enable; it still sets every label and sound; "Threat on
  Target Frame", John's 2026-11-12 name, is now the section heading's).
  New: `threatSounds` (Threat.lua `Sound`, counted `off`), `groupWarnings`
  (pull bars, `PullDisplayWanted`, `PetTauntText`; each feature's own switch
  keeps its value), `tankTools` (`BarShown` false, also unlocked; the key
  bindings and `/dct` still work: pressed on purpose). Sending a pull has
  no switch. The core settings above (unlocked, grid, snap, minimap) have
  none. The pull slider has the number at its right and the
  gold default mark (`ns.AddDefaultTick`), as every toolkit slider must.
- Tank bar layout (1.1.0; John, 2026-11-27, Toolkit 2.18.0's button bars,
  after a CurseForge player asked MTF for vertical bars): with
  `DyresToolkit.BAR_LAYOUT_VERSION` 1 (`DTT.HasBarLayout`, a feature test),
  TankButtons.lua `LayOut` hands the shown buttons to
  `bar:LayoutButtons(shown, {size = 30, gap = 4, padding = 4})`: a row or a
  column by the widget's saved `orientation` (in `DyresCombatToolsCharDB.bar`,
  so in the profile part). GroupSettings.lua adds the Toolkit's "Layout" row
  (`AddBarLayoutSetting`, variable `DYRE_DYRESCOMBATTOOLS_TANKBAR_ORIENTATION`)
  after "Tank button bar", greyed while Tank Tools' Enable is off (`modify`,
  `watch = {"DYRE_TANK_TOOLS"}`). An older Toolkit: no row, and the old row
  layout (each button LEFT on the bar). The minimum Toolkit stays 2.16.0.
- Tank bar (`barMode`: "auto" default, "always", "never"; John, 2026-11-11:
  "the Tank Bar should show [if] a) Group Role is Tank, b) Warrior Defensive
  Stance, Druid Bear Form, Paladin with Righteous Fury enabled"). Auto is
  Threat.lua's `TankBarWanted`, which is `DTT.TankReasons` (the one rule the
  threat view shares): group role Tank or raid main tank (also with another
  role set), Warrior form ID 18 or spell 71, Druid form 5/8 or Bear Form
  spells, Paladin aura 25780. Events only: UPDATE_SHAPESHIFT_FORM, GROUP_ROSTER_UPDATE,
  PLAYER_ENTERING_WORLD, PLAYER_ROLES_ASSIGNED (where it exists), UNIT_AURA
  on "player" for Paladins only. Show and hide is protected (the bar holds
  secure buttons): out of combat through `DTT.OutOfCombat`, else at the end
  of combat. No state driver: no macro condition covers the role or
  Righteous Fury. A secret answer keeps the bar as it is. Unlocked frames
  show the bar in every mode, to move it. Key bindings work with it hidden.
  Auto is sticky (John, 2026-11-11: "sticky auto with a 30 second delay", so
  stance dancing does not make it flicker): it shows at once, and hides only
  after 30 continuous seconds out of combat with no reason to show. One
  one-shot `C_Timer.NewTimer` (the handle kept; no ticker, no OnUpdate)
  starts when the reasons end out of combat, or at PLAYER_REGEN_ENABLED
  when they are gone then; a reason that comes back, PLAYER_REGEN_DISABLED,
  or Always/Never cancels it; when it fires it checks again (still no reason,
  not in combat). While the role is Tank or raid main tank it never hides.
- Owners (Owners.lua): the toolkit claims "threat", "warn:petTaunt",
  "tank:markers", "tank:pings", and "tank:pull" as "DyresToolkit" at 50,
  above a class Tools AddOn's 10, so an AddOn with its own copy (DBR's Pet
  Taunt warning, for toolkits before 2.9.0) yields. A feature runs only while
  the toolkit owns its kind; a switch turned off keeps the claim (off means
  off, not "let another AddOn do it"). Owners.lua lets the toolkit itself
  claim (its TOC has no Group line).
- Threat labels (Threat.lua's head has the rules): a shield (tank view) or
  crossed swords (DPS/healer view) and the scaled percent beside nameplate
  bars (right by default; left, above, below) and above the target bar.
  Auto, Tank, or DPS/Healer. Auto is exactly the tank bar's rule (John,
  2026-11-11: "Threat label rules should be exactly the same as Tank bar
  rules. Druid in Bear, Paladin with Righteous Fury up, Warrior in Defensive
  Stance or anyone designated Group Tank or Raid Main Tank get the bar and
  are treated like tanks for aggro indicators."; found: his Paladin with
  Righteous Fury had the DPS view, because the view used Protection
  talents): `DTT.TankReasons` true is the tank view, false the DPS view;
  the bar and the view both call it, so they cannot drift apart. No talent,
  pet, or solo rules (removed: Protection talents, the Warlock and Hunter
  pet rules, and "solo without a pet"). Never read talents to decide a role
  (John, 2026-11-11: "Drop any attempt to look at talent builds to
  determine, that was wrong. Especially given the new tendency towards
  hybrid builds that mix Arms, Prot and Fury."): no GetTalentTabInfo and no
  talent events; a hybrid Warrior is a tank in Defensive Stance and not in
  Battle Stance. The tests keep a talents mock only to prove talents have
  no effect. Warlocks and Hunters have the DPS view for now (John,
  2026-11-11: "I'd actually be ok if we just treated Hunters and Warlocks
  like DPS and played with it that way for a while, and build drain-tank
  support later, too."). Later, not built: solo only, a Warlock with the
  Voidwalker out is DPS and the pet tanks; with another pet out the Warlock
  tanks (drain tanking) and the pet is DPS. A Hunter whose pet has Growl or
  another taunt on autocast is DPS and the pet tanks (PetTaunt.lua already
  reads autocast); no pet, DPS. A secret form or aura answer keeps
  the view it had (DPS before any answer). The view follows the reasons at
  once; the bar's 30 s sticky hide is only the bar's. A view change clears
  the label state silently (the sounds bullet). Events: the form, roster,
  role, and world events, and UNIT_AURA on "player" for a Paladin (a
  refresh only when the view changes). Only the Righteous Fury read is
  held; form and stance answers apply at once, in combat too (John's Druid
  test, 2026-11-11: Bear Form in and out in combat gave green and red at
  once; GetShapeshiftFormID and GetShapeshiftFormInfo are not hidden in
  combat). The aura API hides an aura in combat and gives a plain nil, not
  a secret: Dyre's Buff Reminders' Druid probe in John's client
  (DyresBuffReminders TESTING.md:63-68: out of combat
  GetPlayerAuraBySpellID found Mark of the Wild and Thorns and
  `C_Secrets.ShouldSpellAuraBeSecret` said false; at the first UNIT_AURA in
  combat both read "present=no secret=true"), and John's Paladin test
  (Forever 1.60.1 70888, 2026-11-11: Righteous Fury up the whole fight,
  green turned red at 100% after a few swings; UNIT_AURA=46, red view=6).
  So a nil aura read means (Threat.lua HasAura, NotFound): with
  ShouldSpellAuraBeSecret true, a secret, or an error (pcall), hidden, and
  the view and the bar keep what they had (`held`); with it false, "off",
  at once, in combat too; with no C_Secrets or no such function (Era), or
  another answer, hidden in combat (InCombatLockdown) and "off" out of
  combat. A found aura is always true; a secret form or aura answer is
  hidden, as before. PLAYER_REGEN_ENABLED reads the reasons again (the
  lockdown has ended by then; UnitAffectingCombat is not used, its timing
  at that event is not checked), so a real change in combat takes effect
  at combat's end at the latest. `/dct debug_threat` prints "righteous fury
  reads combat: ..., aura secret ...; calm: ..., aura secret ...; held=N
  view changes in combat=N": the raw C_UnitAuras answer (aura, nil, secret,
  other; or UnitBuff's true, false, secret), ShouldSpellAuraBeSecret's
  answer on every read (true, false, secret, error, other, missing), the
  nil reads held, and the Auto view changes in combat (`DTT.auraReads`,
  `DTT.auraSecretReads`, `DTT.tankCounts`). Not checked in client yet:
  that ShouldSpellAuraBeSecret says false for Righteous Fury out of combat
  (if it says true, a Paladin who clicks it off keeps the tank view).
  Tank view:
  early yellow when another member or pet is at 80% of the pull point;
  blue when another tank holds the mob. Red (LOST) is status 0 only: the
  mob is not on you and someone else has more threat. Status 1 (not on you
  yet, nobody has more) is yellow PULLING, never a sound (John, 2026-11-25:
  the siren played on almost every pull as a Protection Warrior, while the
  pack turned; "For tanks, can't we just siren if someone else is higher
  than me on the threat table?"). `/dct debug_threat` lists the last 10 red
  and PULLING changes (`DTT.threatChanges`: seconds since combat started,
  label, status, word, sound decision). A sound when a label turns red
  (`redSound`, default Dyre's Sounds' Bell buzz, else the raid warning;
  below), at most once in 2 seconds, never for a secret status.
- The sounds come from a change of state, not from an event (John,
  2026-11-11: the red sound "fires only about 10% of the time, randomly";
  found: only a threat event could play it, but every update noted the
  color, so when PLAYER_REGEN_DISABLED or a target, form, or roster event
  came first at a pull, the label turned red silently and the threat event
  then saw it already red). Now a label that turns red plays it on any
  update, while audible: a threat event, PLAYER_REGEN_DISABLED, or in
  combat (InCombatLockdown or UnitAffectingCombat). A first reading plays
  too (John, 2026-11-11, after "seen=8 played=4 ... first=5": "If a mob
  attacks me, and threat turns red, I should still hear the chime that I
  got aggro, right?"): a new plate token shown already red, a target change
  onto a mob on you. Two cases stay silent: red after a view change (a form
  or role change clears every label's state and marks it; the player made
  that change), and the same mob already red on another label (the target
  label and the plate where `UnitIsUnit(plate, "target")` reads true; a
  secret or unknown answer counts as a different mob). The 2 s gap, the
  setting, and the secret rule stay. LOSING (3 to 2) still needs a known 3
  before the 2; a secret status clears its last status. Each
  threat event has one argument, unitTarget (UnitDocumentation.lua:
  Forever 70888 4891-4907, Era 70576 3329-3345); for
  UNIT_THREAT_SITUATION_UPDATE it is the unit whose situation changed (often
  "player"), so every plate is read again on it. `DTT.soundCounts` print in
  `/dct debug_threat`, per mob, not per label: red seen (a mob turned red),
  played, and skipped gap, none, calm (out of combat), then view and same
  (not counted as seen); losing seen, played, gap, none, calm, first (a 2
  with no known 3, or an orange with no known green), and same (DPS: the
  same mob already orange on another label). The view follows the tank bar's rule (Threat.lua
  AutoRole calls `DTT.TankReasons`: a Druid in Bear Form, a Paladin with
  Righteous Fury, or a Warrior in Defensive Stance has the tank view, where
  red means a mob left you; otherwise the DPS view, where red means a mob is
  on you): a link John saw between the bar and the sound is the view, not
  the bar.
- DPS orange (John, 2026-11-13: "Can we make it symmetrical for DPS?
  Green, on threat table, but not 1st or 2nd. Orange, in danger of pulling
  aggro, Red, you pulled aggro. And play the same sounds?"): the DPS view's
  status 1 (more threat than the tank, no aggro) is orange (was yellow) and
  shows the percent, on every plate (the status reads). On a readable
  percent (the target token and the plate of your target), status 0 at
  EARLY_WARNING (80) or more of the pull point is yellow (`VIEWS.dps.early`;
  John, 2026-11-13: "An early yellow for DPS would be nice (no sound, just
  flip it yellow when they get above 80%)"; "A DPS targeting the wrong mob
  will see this on their target and know to back off"); a secret percent
  is not compared, so other plates skip it. "Not 1st or
  2nd" is not read as a rank: a plate's group values are secret on
  Forever, so the rank cannot be known; the status and your own percent
  stand in for it. A change from a known green or yellow (a readable
  status before) to orange plays `losingSound` (Text to Speech "High threat"), with the
  same 2 s gap, setting, and solo rule; a first reading already orange is
  silent (`first`), and the same mob already orange on the other label is
  counted `same` (Threat.lua `SameMob`). Red is unchanged. A view change,
  a plate removed or added, or a label hidden clears `orange`.
- Warning sounds (John, 2026-11-11: "The sound for "turning red" needs to
  be configurable."): "Alert sound (red)" (`redSound`) and "Warning sound (orange)"
  (`losingSound`; it plays at LOSING, orange on a plate; John, 2026-11-13:
  "Use "(orange)" ... Orange is more clear"; it plays at the DPS view's
  orange too) are dropdowns over one list,
  Tank.lua's `DTT.SOUNDS`: None, Raid warning (RAID_WARNING 8959, red's game
  fallback), Quest failed (847, losing's fallback), Ready check (8960), Alarm
  clock (ALARM_CLOCK_WARNING_3 12889), Boss emote (RAID_BOSS_EMOTE_WARNING
  12197), Boss whisper (UI_RAID_BOSS_WHISPER_WARNING 37666), Battleground
  ready (PVP_THROUGH_QUEUE 8459), Map ping (3175). `SOUNDKIT[key]` where it
  is a number, else the number. Every key and number is in
  SoundKitConstants.lua on both clients (Gethe/wow-ui-source forever
  1.60.1 70888 Mainline, classic_era 1.15.9 70576 Vanilla); 847 has no key
  on either (the old `SOUNDKIT.IG_QUEST_FAILED` was always nil), so it plays
  by number. All play on the Master channel. A choice made in the settings
  plays once as a preview, never in combat. Old boolean saves migrate:
  false is "none", true the default (the red one from the old `sound`
  key, which is dropped); a string that is not key-shaped (`[%w_]`, at
  most 64) is the default. These eight and None are the "Game Warnings"
  group.
- Threat sounds when solo (`soloSounds`, checkbox, off by default; John,
  2026-11-12: "super useful in groups, but can get tiresome when solo
  grinding hearing it on every pull"; "Change it to default off. Most
  people, when solo, will not want the sound."; the one warning that is off
  by default): off, the red and losing sounds play
  only while `IsInGroup()` reads true (Threat.lua `Sound`; a secret answer
  counts as solo). The labels still change color. Counted as `solo` in
  `/dct debug_threat`. Read at each sound, so a change needs no refresh.
- Dyre's Sounds in the warning sounds (John, 2026-11-11: "Keep the sounds
  you found in-game in the "Game Warnings" group, but add all the Dyre's
  Sounds as options."): when `DyresSounds.RequireContract(1)` gives its
  interface with Groups, List, Play, Playable, Resolve, Label, and Parts
  (src/DyresSounds 1.4.0 Sounds.lua; `DTT.SoundLibrary`, read each time),
  both dropdowns list Game Warnings first, then every group of its `Groups()`
  (a sound with no group, Text to Speech, at the top), as a nested menu
  built like its Menu.lua (a submenu per group; the pooled control frames
  are wrapped only for the toolkit's own two dropdowns, and another
  dropdown's label is cleared, as its code does). The plain list (full
  labels) stays where the client has no `Settings.InitDropdown`. A pick
  saves its key through `Resolve` and only when `Playable`; it plays through
  `DyresSounds.Play(key, speech, "Master")`, also as the preview (never in
  combat). Text to Speech is offered: Play takes the words (red: "Aggro
  lost" in the tank view, "Aggro" in the DPS view and the preview; losing:
  "Losing"). A Play that returns false plays the default game sound. Without
  the library, with an older contract, or with a key it does not have, the
  saved key stays (SanitizeDB keeps key-shaped strings), the dropdown shows
  the default as chosen (`EffectiveSound`), and the default game sound
  plays until it is back. No file of Dyre's Sounds is copied or named
  here.
- Default warning sounds (John, 2026-11-11, from his settings: "set these
  as the defaults, I like them fairly well"): `DEFAULT_RED_SOUND`
  "alertbellbuzz" ("Dyre's Alerts: Bell buzz") and `DEFAULT_LOSING_SOUND`
  "alertshake" ("Dyre's Alerts: Cartoon shake"), keys of Dyre's Sounds
  1.5.0's "Dyre's Alerts" group (src/DyresSounds Catalog.lua). Without the
  library, with one before 1.5.0 (no such key: `Resolve` gives nil), or
  with `Playable` false, the default in effect is its game fallback
  (`SOUND_FALLBACK`: the raid warning 8959 for red, quest failed 847 for
  losing; `DefaultSound`), and the menu shows that as chosen; a Play that
  returns false plays the fallback too (`GameFallback`). Toolkit 2.9.0
  ships with or after Dyre's Sounds 1.5.0. The pull tick and go defaults
  stay game sounds.
- Saved sound choices since `soundSaves` 1: only a player's own choice is
  saved; nil is the default (`EffectiveSound(nil, default)`). Picking the
  default key (or the settings' Defaults button, which sets it even
  without the library) saves nil. Before, SanitizeDB always wrote the
  default, so a save could not tell a choice from a default: a save
  without `soundSaves` 1 has its old defaults (red "raidWarning", losing
  "questFailed", pull "countdownTick" and "countdownGo") moved to nil once
  (a player who chose the raid warning in a test build gets the new
  default; the lead asked for this move). Other choices stay.
- Label offsets (John, 2026-11-11: "Can we have an adjustable "Gap
  Distance" slider (minimum) or vertical/horizontal adjustments for the
  Threat indicators?"): `plateX`/`plateY` (nameplate labels) and
  `targetX`/`targetY` (the target label), whole pixels -50 to 50, each
  with its own default in `DTT.LABEL_DEFAULTS` (plateX -20 since John,
  2026-11-27: "-20px then, it looks good where it is"; the others 0), repaired to it (`SanitizeOffset(value,
  default)`). A saved value stays: SanitizeDB writes every value, so a save
  from before cannot tell a choice from the old default, and only a missing
  or bad value gets the new one. They add to the place's own
  offsets (BAR_GAP 4, half of it above and below), so 0 moves nothing; X
  and Y also cover the gap. Each slider shows "N px" and the gold default
  mark (GroupSettings.lua `Slider`, which the pull slider uses too). A move
  re-places every label at once (`RefreshThreat`), also in combat: labels
  are plain frames.
- Label size (John, 2026-11-13: "make the size of the threat indicator
  scale up or down, up to 100% (2x) it's default size"): `plateScale` and
  `targetScale`, whole percent 50 to 200, default 100
  (`DTT.LABEL_DEFAULTS`, `SanitizeScale(value, default)`; "down" to half is
  our choice). The nameplate label's base is twice the old size (John,
  2026-11-27: "The size it is now (200% bigger than the original) becomes
  100%, slider stays the same, just the origin moves."): Threat.lua passes
  `plateScale * DTT.PLATE_BASE_SCALE` (2) to `Place`; the target label
  keeps its base. A save before `scaleSaves` 1 (`DTT.SCALE_SAVES`) is moved
  once in SanitizeDB (`PlateScale`): exactly 100, the old default, stays 100
  (the new, bigger look); any other value is halved, rounded, and clamped to
  50 to 200 (the same look; John's 200 becomes 100). This covers the
  one-time Toolkit copy and old profiles too; a new profile carries the
  marker. a slider each ("N%", the gold mark) under
  its section's offsets. Threat.lua `Place` calls `SetScale` on the label
  (icon and text; ICON_SIZE stays 14) and divides the gap and x and y by the
  scale, because a frame's point offsets are in its own scaled units, so
  they stay screen pixels. At once, also in combat. Pull bars are not
  scaled.
- Secret threat values: never compare, concatenate, index, do arithmetic
  on, test for truth, or print a value that may be secret. A secret percent
  shows in white through `SetFormattedText` (`AllowedWhenTainted`);
  `ColorCurve:Evaluate` is `AllowedWhenUntainted`. The icon's shape comes
  from the view, never from a threat value.
- Tinted icons (John, 2026-11-11: "can we make the shield/swords icon
  itself use the color scheme - I realize this means custom images, I'm ok
  with that as long as they are attractive."): Textures/ShieldFill.tga and
  SwordsFill.tga (white to grey, shaded top to bottom, a lit bevel) are
  tinted with `SetVertexColor` from the same constant color as the text
  (green, yellow, red, blue, orange; white for a secret status; never a
  color made from a secret); ShieldEdge.tga and SwordsEdge.tga, a dark
  outline with no tint, lie above them (OVERLAY sublevel 1, `SetAllPoints`
  on the fill), so the icon reads on any background. 64x64 32-bit TGAs,
  drawn by scripts/make_icons.py (pure Python signed distance fields,
  4x4 supersampling; `--preview DIR` writes PNG sheets of all six colors);
  tests/test_icons.py checks them and that the committed files are its
  output. ICON_SIZE stays 14.
- What Forever reads in combat (John's `/dct debug_threat`, 1.60.1 build
  70888, open world, 2026-11-11): on the "target" token every
  `UnitDetailedThreatSituation` value reads; on a "nameplateN" token every
  one is secret, but `UnitThreatSituation("player", plate)` reads. So the
  color comes from the readable status, and `ReadThreat` falls back to
  `UnitThreatSituation` (the color method; closed). `GetThreatStatusColor`
  and `ColorCurve:Evaluate` fail on the secret status: not used. A plate
  shows its secret percent through `SetFormattedText` in the status color
  (white only when both statuses are secret). The plate of your target reads
  the "target" token instead (`ReadUnit`, when `UnitIsUnit(plate, "target")`
  reads true; a secret keeps the plate token): a readable percent, plus early
  yellow and blue. Other plates lose early yellow and blue (the group's
  values on a plate token count as unknown); the target label keeps them.
  Whether party members' values on the "target" token read is not yet seen
  in client. A dungeon may hide more (TESTING.md).
- Losing a mob (John, 2026-11-11: "To effectively tank, I need a visible
  clue that threat is getting low on a mob -- before the visual clue of it
  turning and beating the healer down."; "Yes, all three, go ahead."): on a
  nameplate in the tank view, status 2 shows the word LOSING in orange (the
  percent is always 100 while you hold the mob); the target label keeps its
  percent and early yellow. Status 3 to 2 on a threat event plays the
  `losingSound` choice (default Cartoon shake, else Quest failed 847; not the red
  sound), once per change, at most once in 2 seconds, never for a secret
  status (only a readable status is kept); None turns it off. Status 2 reads on plates in combat
  (UnitThreatSituation), so this works on Forever plates.
- Pull bars (`pullBars`, "Pull bars under nameplates", on by default): tank
  view, in a party, not a raid. Under each enemy plate's health bar, one
  StatusBar (3 px, 1 px gap, 0-100) per party member in its class color,
  `SetValue` with `UnitDetailedThreatSituation(member, mob)`'s scaled
  percent as it comes, secret or plain, never compared or computed (only
  `type` and `issecretvalue`); no value hides that bar, and the shown bars
  close up. The plate of your target reads the "target" token. No pet bars
  (the Pet Taunt warning covers pets; four bars stay small). Plain frames,
  made at a plate's first show and reused, so they change in combat; events
  only (threat, plate, target, group). A label placed below goes under the
  bars. DIES placed "below" on plates (a player's own place) can overlap
  them; the default places cannot. Not yet proven in client: if
  `/dct debug_threat` in a group shows party members' values on a plate as
  nil, the bars never show there; then turn the setting off by default and
  say so here. `/dct debug_threat` prints each party member's and pet's
  values on the target and on the first hostile plate.
- Pet Taunt warning (PetTaunt.lua, DBR 1.5.0's code): in a group where you
  are not the designated tank, Growl, Torment, or Suffering on autocast; a
  message box widget ("DyresCombatToolsWarning") and a chat line, when it
  becomes true or its text changes and once more as combat starts, at most
  once in 30 seconds; checked out of combat only. Unlocked, the box shows
  a sample built by the same words function as the live warning
  (`DTT.PetTauntWords`), with the class's taunts (`DTT.PET_TAUNT_SAMPLES`:
  Hunter Growl; Warlock Torment and Suffering) named by the client
  (`C_Spell.GetSpellName`, else GetSpellInfo; a secret or missing name
  gives the plain English one). 1.0.1 (John, 2026-11-27, "Yes, fix it"): a
  Warlock's sample said Growl.
- Marking: AddOn code never calls `SetRaidTarget` (`HasRestrictions`; in
  combat the game blocks it with a popup). Markers come only from the
  game's `/tm` in secure action buttons' macro text, with `!` and `exists`.
  "Next marker" changes its macrotext in a `SecureHandlerWrapScript` OnClick
  pre-snippet, on the release only; the order starts again at
  `PLAYER_REGEN_ENABLED`; the default order leaves out moon (WTF's Banish,
  MTF's Polymorph).
- Pings only from the game's `/ping` in macro text (`C_PingSecure` is
  secure only). Without `SLASH_PING1` (Classic Era) no ping buttons.
- Pull (John, 2026-11-11: "check that [the in-game pull timer] before
  falling back to nothing"): Deadly Boss Mods (`/dbm pull N`), then BigWigs
  (`/pull N`), else the game's `C_PartyInfo.DoCountdown(N) -> success` (both
  clients: PartyInfoDocumentation.lua, Forever 70888 155-170 with
  HasRestrictions and AllowedWhenUntainted, Era 70576 50-64 with
  HasRestrictions). Every member gets START_PLAYER_COUNTDOWN and sees the
  game's countdown with no AddOn. A false return (refused; who may call it
  is not in the UI source: `/countdown` has no leader check, the raid
  manager's button shows only for leader or assist; John recalls leader
  only), or a client without that event, also sends the toolkit's own
  message and shows it here, with a chat line on a refusal. Without
  DoCountdown: the toolkit's message alone. `/dct pull 0` cancels in each
  path (DoCountdown(0), `/dbm pull 0`, `/pull 0`, the toolkit's CANCEL). The
  toolkit registers no `/pull`.
- What reaches whom (research, 2026-11-11, with sources in the shared notes
  toolkit-2.9.0-pull-countdown-research.md: DBM e903df81, BigWigs
  dccbd7b8): current DBM and BigWigs start a pull only with DoCountdown and
  show one only from START_PLAYER_COUNTDOWN; neither reads the old addon
  formats now (DBM "D5" `Name-Realm\t1\tPT\t<s>\t<areaID>`, D4 `PT\t<s>`,
  BigWigs `P^Pull^<s>`), so the toolkit sends none of them. DBM drops a pull
  from a sender of rank 0 (in a party, anyone but the leader), in combat, in
  PvP or an encounter, under 3 s, or a secret; BigWigs has no rank check
  (an instance ID match), replaces DoCountdown with its own /pull path, and
  hides the game's countdown display for its users. A party member who is
  not the leader therefore reaches BigWigs users and players with no AddOn
  (if the game allows the call) but not DBM users; faking a rank is not
  possible and not tried.
- The pull countdown display (Pull.lua; Owners kind "tank:pullDisplay";
  John: "our own pull timer indicator ... for both tank and party
  members"; round 9: "If we're going to have our own pull experience, it
  should be really good. Otherwise, don't bother."). A widget "Pull
  countdown" (`pullTimer` store; scale and opacity sliders through
  AddWidgetSettings, "Countdown size (%)", "Countdown opacity (%)"; `/dyre
  unlock` shows a sample "10") in the middle of the screen:
  - The number: Friz Quadrata (STANDARD_TEXT_FONT) 72 px THICKOUTLINE with
    a shadow; gold (the toolkit's 1, 0.82, 0) above 3, orange at 3 and 2,
    red at 1. Each second a pop (AnimationGroup: Scale 1.5 to 1 and Alpha 0
    to 1 over 0.2 s, then Alpha to 0.35 from 0.6 s for 0.35 s).
  - The bar: 200 x 6 under it, a 1 px dark edge (the icons' style), in the
    number's color; its length is the time left of the pull's whole length
    (START_PLAYER_COUNTDOWN's totalTime, else the start), and one Scale
    animation (origin LEFT, to 0.001 wide) drains it over the time left +
    0.1 s, so the engine moves it; code only sets its color each second.
  - The line: "Pull in N - Name" (16 px, gold) when the source names the
    starter (the game event's initiatedByName, the addon message's
    sender, your own name for your pull); a secret name is never shown;
    realm dropped on yours, "|" and control characters removed, 24
    characters at most. ASCII " - " (the font's dash support is not
    checked).
  - At 0: "PULL!" (60 px, green) grows 0.7x to 1.6x over 1 s and fades
    from 0.4 s for 0.6 s; its OnFinished hides the display. A cancel
    (CANCEL_PLAYER_COUNTDOWN, a 0 message, `/dct pull 0`) shows "Pull
    cancelled" (28 px, grey) for 1 s, fading for 0.6 s, then hides; a
    cancel with nothing running shows nothing.
  - Sounds: "Countdown tick sound" (`pullTick`, default Countdown tick,
    UI_BATTLEGROUND_COUNTDOWN_TIMER 25477) on each of the last 5 seconds,
    and "Countdown go sound" (`pullGo`, default Countdown go,
    UI_BATTLEGROUND_COUNTDOWN_FINISHED 25478) at 0, each from the same menu
    as the warning sounds (Game Warnings, which now also lists these two,
    then Dyre's Sounds; None). Text to Speech says the number and "Pull".
    Five ticks, not 3-2-1: the game's own countdown and DBM's and BigWigs'
    count the last 5, and the color already marks 3 to 1.
  - It starts on START_PLAYER_COUNTDOWN (initiatedBy, timeRemaining,
    totalTime, informChat, initiatedByName; WorldStateInfoDocumentation.lua
    on both clients; Forever flags it SecretInChatMessagingLockdown, so a
    secret time is ignored), on CHAT_MSG_ADDON from "D5"/"D4" (a "PT"
    field, older DBM), "BigWigs" (`P^Pull^<s>`, older BigWigs), and its own
    prefix "DyresToolkit" (`1\tPULL\t<s>`, `1\tCANCEL`). It registers those
    prefixes itself. A start within 1 s with about the same end is the same
    pull (a later source may name the starter); combat does not cancel it;
    over 300 s is ignored. Code runs once a second: one `C_Timer.NewTimer`
    at a time (the handle kept), never OnUpdate or a ticker; the motion is
    AnimationGroups.
  - The design rule for the pull display (John, 2026-11-11): "We sit
    between other addons and the default experience, only." Never
    override, hook, hide, or change another AddOn's display or settings
    (its frames, its functions, its saved options). The toolkit replaces
    only the game's default countdown, and only when no boss mod shows one.
  - `pullDisplay`, "Dyre's countdown on screen", is a checkbox, on by
    default, and only about this display, never the send path (sending has
    no setting and always takes the best path above). On: it shows only
    when no boss mod shows a pull (`BossModShowingPull`, read at each
    pull): BigWigs loaded always shows its own (its pull bar has no switch:
    Plugins/Pull.lua 429 at dccbd7b8; its chat line always prints, 418), so
    Dyre's steps aside; DBM-Core loaded shows its own unless DBM's own "Do
    not show Pull/Break Timer bar" is on (`DBM.Options.DontShowPT2`,
    DBM-Core/modules/objects/CoreOptions.lua 418 at e903df81; /dbm > Global
    Disables & Filters > Disable DBM Features). With it on (and no
    BigWigs), DBM is not "the" pull timer (John: "If DBM is installed and
    configured to be "the" pull timer, let it."), so Dyre's shows and takes
    the game's countdown (DBM draws no center numbers of its own and never
    touches TimerTracker). `DBM.Options` is read with rawget, fresh each
    time, never written, no hook; a missing or odd table counts as DBM
    showing its own. DBM fires no event when an option changes, so the
    game's countdown is matched to it at login, PLAYER_ENTERING_WORLD,
    GROUP_ROSTER_UPDATE, ADDON_LOADED, and after each START_PLAYER_COUNTDOWN
    (for the next pull; the first pull after a change may show the game's
    numbers or none). DBM's countdown voice may still play: its
    DontPlayPTCountdown option is noted in its own code as not working
    (PBC.lua 11). Research: shared notes
    toolkit-2.9.0-bossmod-pull-settings.md. Off: never. Older saves: "auto"
    and "always" are on, "never" off ("Always" is gone: John, "DBM/Bigwigs
    ... results in two timers at once"). Its tooltip: a Sending part, an On
    screen part, one line on DBM's two options with the menu path, and one
    line that BigWigs always shows its own pull bar.
  - In place of the game's own countdown (John: "Yes, send it"): while it
    shows (no boss mod showing a pull), the toolkit unregisters
    START_PLAYER_COUNTDOWN and CANCEL_PLAYER_COUNTDOWN from TimerTracker,
    as BigWigs does (Loader.lua 1232-1233 at dccbd7b8, at its load). Only
    those two registrations (where the client has the events): no function
    replaced, no frame shown, hidden, or moved, nothing protected touched;
    TimerTracker's PvP and Challenge Mode timers stay. Done out of combat
    (`DTT.OutOfCombat("gameCountdown")`; a change in combat waits). They are
    registered again when it is turned off, when DBM's pull bar is on, or
    when DBM loads later (ADDON_LOADED), but never over BigWigs (its loader
    took them itself, with no condition, and never gives them back).
    The game's chat line "<name> started a countdown" (informChat) goes with
    them, as with BigWigs; the line under the bar names the starter
    instead. Not seen in client yet: that this taints nothing (TESTING.md).
- The game's own countdown display (Blizzard_FrameXML Timer.lua and
  Timer.xml, identical on Forever 70888 and Era 70576, loaded by
  Blizzard_FrameXML.toc and Blizzard_FrameXML_Vanilla.toc): TimerTracker
  registers START_PLAYER_COUNTDOWN and CANCEL_PLAYER_COUNTDOWN (lines
  48-50) and starts a PlayerCountdown timer (181-196; TIMER_DATA line 6: a
  bar from 31 s, big numbers under 11 s, sounds). So a player without a boss
  mod would see the game's numbers and Dyre's countdown at once (BigWigs
  unregisters TimerTracker for its users); since round 9 Dyre's countdown
  takes the game's place (above). On Era, TIMER_DATA's PlayerCountdown sound kits
  (UI_COUNTDOWN_TIMER and friends) are not in its SoundKitConstants, so
  they are nil there; the big-number tick falls back to
  UI_BATTLEGROUND_COUNTDOWN_TIMER (lines 325-329).
- Group boss mods, heard only (John, 2026-11-11: "build the version list
  too"): `/dct debug` lists each other group member and what was heard from
  it. The toolkit sends nothing for it (no hello, no reply). DBM's "D5"
  V (`<Name-Realm>\t<protocol>\tV\t<revision>\t<release>\t<display>...`,
  field 6) gives "DBM <display>"; BigWigs' `Q^<version>^...` or
  `V^<version>^...` gives "BigWigs <version>" (version 0 is DBM's query and
  is skipped); a D5 hello (`\tH\t`) alone gives "DBM or BigWigs"; a toolkit
  pull message gives "Dyre's Toolkit"; nothing heard gives "unknown" (most
  toolkit users). Each boss mod can fake the other's reply, so this is what
  was heard, not proof. Only PARTY, RAID, and INSTANCE_CHAT count (not
  GUILD's GV). Keys are `Ambiguate(sender, "none")`, the form
  `GetUnitName(unit, true)` gives; a member not in the group at
  GROUP_ROSTER_UPDATE is dropped. Payloads are data: patterns only, never
  run; a secret field skips the message; stored text has "|" and control
  characters removed and is cut to 24 characters. The prefixes are the ones
  the display registers (only where `C_ChatInfo.RegisterAddonMessagePrefix`
  exists).
- The bar is a widget (`mouse = "always"`, each button a drag handle); secure
  frames change only out of combat (`ns.tank.OutOfCombat`, the toolkit's
  queue). Buttons and bindings are named `DyresToolkit<Name>`.
- Commands: `/dyre pull [seconds]`, `/dyre tank_reset`, `/dyre tank_debug`,
  `/dyre debug_threat`, `/dyre debug_taunts`, `/dyre debug_dots` (the same
  names as `/dtt`, John, 2026-11-16: "if we're going to expose the same
  command through /dyre, it would be better to have the same name"; `/dyre
  debug` is the toolkit's, so tank_debug and tank_reset stay; 2.9.0's
  `threat_debug` and `taunt_debug` still work, not listed) (Core asks
  `ns.HandleTankCommand` first); the Toolkit's `/dtt` and `/tanktools`
  kept Dyre's Tank Tools' words. In DCT the one command is `/dct` (John,
  2026-11-26: "We never shipped Dyre's Tank Tools, we baked it into Dyre's
  Tools (/dyre); and now we decided to "brand" it "Dyre's Threat and Combat
  Tools" (DCT) - so no user will ever recognize dtt. Use /dct consistently
  from day one."): no `/dtt`, no `/tanktools`, slash key
  `DYRESCOMBATTOOLS` (`/dct pull 10`, `/dct reset`, `/dct debug`,
  `/dct debug_threat`, `/dct debug_taunts`; `/dct` alone opens the
  settings). The login is quiet; a command says why a feature is off.
- Taunt probe (TankProbe.lua, end; John, 2026-11-12: "Can we announce with
  either an emote or in party chat when someone other than the tank
  taunts, growls, pops Righteous Fury, etc.?" ... "Yes, probe first, then
  build it. The list is a good starting point, at least, if not
  complete."). Built: the probe only, `/dct debug_taunts` (and a summary
  line in `/dct debug`). UNIT_SPELLCAST_SUCCEEDED through
  `RegisterUnitEvent`, two units per frame (player; pet; party1-2;
  party3-4; partypet1-2; partypet3-4), so a frame's unit kind is known
  even when the unit argument is secret; without RegisterUnitEvent, one
  frame with RegisterEvent keeps only those tokens (a secret unit is not
  counted there). Each registration's pcall result is printed. Counts per
  kind (player, pet, party, partypet), in combat (InCombatLockdown) and
  out: events, spellRead, spellSecret, spellOther (no number), nameSecret,
  guidSecret, unitSecret. Watched by name, from `C_Spell.GetSpellName` (or
  GetSpellInfo) of a readable spell ID, against each listed rank-1 ID's
  name in the client's language and its English name (`TAUNT_WATCH`):
  Taunt 355, Mocking Blow 694, Challenging Shout 1161, Growl 2649,
  Challenging Roar 5209, Torment 3716, Suffering 17735, Distracting Shot
  20736, Righteous Fury 25780, Defensive Stance 71. Matches per name and
  kind, and the last 10 (time, combat, unit token or "secret", spell; no
  player names), in session memory only: nothing is saved and nothing is
  sent. Known before it (not tested again): an emote is blocked when sent
  from a spell event (WarlockToolsForever TESTING.md:179), so no emote;
  party chat from UNIT_SPELLCAST_SUCCEEDED works (WTF TESTING.md:55-56);
  your own spell IDs read in combat (DCC AGENTS.md:34, WTF
  TESTING.md:199-200). Unknown, the probe's question: whether party
  members' and party pets' arguments read in combat on Forever.
  Later design, not built (waits for John's probe output): only the
  designated tank's toolkit announces (`GroupTank("player")`); by default
  only the tank sees it (on screen and a chat line); party chat is a
  setting, off by default; at most one announcement per player and spell
  in 10 seconds.
- DoT probe (TankProbe.lua, end; John, 2026-11-16: "so there is no way to
  actually know what mob was hit by a dot?" ... "yes, build the probe"):
  `/dct debug_dots` (`/dyre debug_dots`, and a line in `/dct debug`). The DoT
  tracker knows a cast's mob only by name (Bug 2; now the aura confirm). After
  each of your own DoT casts that succeeds (a readable spell ID in your
  class's ClassData `dots`), UNIT_AURA is registered for 2.5 s
  (`DOT_PROBE_WINDOW`, one one-shot timer), then unregistered. It counts,
  per combat and calm: the unit (secret or token), the update info, each
  added aura's spellId, sourceUnit, isFromPlayerOrPlayerPet and
  auraInstanceID (secret or read; "ours" for one of your DoT IDs), and
  `C_UnitAuras.GetAuraDataByAuraInstanceID` (table, secret, nil, error);
  per unit, the delay and UnitIsUnit with target and mouseover. The last 10
  casts in session memory; nothing saved or sent; every event read in
  pcall ("errors"). Unknown, its question: whether UNIT_AURA names the mob a
  DoT landed on, in combat on Forever. Waits for John's output.
- Never register `COMBAT_LOG_EVENT_UNFILTERED`. No popups in combat. No
  `OnUpdate`. Unknown events register only where `C_EventUtils.IsEventValid`
  says they exist (Era lacks some).

### Swing timer and range box (2.15.0; John, 2026-11-24)

John asked for a Hunter range finder and swing timer, then chose the toolkit
for it, every class ("for the same reason we didn't put the tanking stuff in
its own addon"; "with the option to create another addon down the road").
Swing.lua; its settings are a "Swing Timer" section after Tank Tools (before
the Profile section), added from GroupSettings.lua through
`ns.AddSwingSettings`. `ns.InitializeSwing` runs from `ns.InitializeTank`
right after the saved settings load, so it works without the threat API.

- Settings: `DyresToolkitCharDB.swing` (in the toolkit's profile part),
  repaired in place by `ns.SanitizeSwing` (called from Tank.lua's
  SanitizeDB): `show` "off" (default since 2.15.1), "combat", or "always".
  2.15.1 (John, 2026-11-26, after CurseForge comments about noise: "turn the
  Toolkit's swing timer off by default first"): a saved "combat" without
  `defaultsVersion = 2` turns "off" once, since 2.15.0 saved "combat" for
  every character. The swing timer moves to Dyre's Threat and Combat Tools
  (DCT), where it is on by default. Before: "combat", "always", or "off" (John: "Off
  (never show), On In-Combat, Always show"; Off also hides it while
  unlocked, and turns every range check off), `range` (the range box, true),
  `hold` (Auto Shot's hold-still zone, true), `theme` "gold" or "tactical"
  (John: "a wow-gold/black theme and a more tactical black/red theme"), and
  `combatOpacity` and `idleOpacity` (10-100 on steps of 5, 100; John:
  "opacity settings for in and out of combat (if someone sets show
  always)"; full while unlocked; the widget has no opacity size of its own),
  `inUse` (true; John: "hide/show the timer bars that aren't being used and
  have the widget grow/shrink"), and `frame` (the widget's store: place,
  scale, width). No Enable checkbox: Show's Off is the off switch (John named
  the three choices).
- Rows (`Swing.RowOrder`): ranged first for Hunter, Mage, Warlock, and
  Priest (John: "melee is last-resort for them"; the class orders rows only),
  else main hand, off hand, ranged. With `inUse`, the primary row
  (`Swing.PrimaryRow`: ranged for those classes with a ranged weapon, else
  main hand) always shows; another row shows while its swing runs and
  `Swing.LINGER` (2 s) after (a one-shot timer per row shrinks the frame),
  and the main hand also while the state is MELEE. The frame keeps its top
  edge as it grows and shrinks (`SetContentSize(..., "TOP")`).
- Events only (no polling, no OnUpdate); all checked on Forever in John's
  probes, 2026-11-24 (the shared notes' forever-hunter-probe): PLAYER_SWING
  (swingDuration, swingType 0 main hand, 1 off hand, 2 ranged) starts a bar
  through `StatusBar:SetTimerDuration` with a `C_DurationUtil.CreateDuration`
  object (the client fills it). Range from `C_Spell.EnableSpellRangeCheck`
  and SPELL_RANGE_CHECK_UPDATE (spellIdentifier, isInRange, checksRange; the
  identifier comes back as an ID, matched by name). The client keeps a range
  check on across /reload, so every check turned on is turned off when no
  longer wanted (`Swing.SetupProbes`). `C_SwingTimer.EnableRangeCheck` and
  PLAYER_SWING_RANGE_UPDATE never turned on in client (checksRange false,
  also in combat): not used. Forever's own Edit Mode swing timer is left
  alone (John: "it is horribly ugly so we won't touch it").
- Checks (John: "Just follow what weaponswingtimersixfixx does for now",
  then "Melee spell per class"): ranged is Auto Shot when known, else the
  equipped ranged weapon's attack by item subclass (Shoot Bow 2480, Shoot Gun
  7918, Shoot Crossbow 7919, Throw 2764, wand Shoot 5019), by name (Auto Shot
  by ID 75 said "in range" from too far). Melee: one instant melee spell per
  class, each only after an in-client check (`Swing.MELEE_PROBES`): Hunter
  Wing Clip. Raptor Strike's range is true at every distance on Forever:
  never used (a next-swing ability; Heroic Strike and Maul are avoided for
  the same reason until checked).
- The rule (`Swing.RangeState`, SixxFix's order): no live enemy target, no
  state; ranged in range RANGE; melee in range MELEE; no melee check and a
  main-hand swing in the last swing time plus half a second MELEE; ranged
  out of range and near (`CheckInteractDistance(target, 3)`, about 10 yards,
  read once per event) DEAD ZONE with a melee check, TOO CLOSE without (John:
  "Yes, use that"; ForeverHunterDeadzone shows DEAD ZONE in melee there);
  else TOO FAR. Wands have no dead zone (John: every ranged weapon attack
  has one, wands do not). A change waits `Swing.SETTLE` (0.15 s, a one-shot
  timer) and is dropped if it changes back (Wing Clip flipped every 0.3 s on
  the melee edge in client).
- The look: one widget (`DyresToolkitSwingTimer`, key "swing", width
  120-400, scale; a thin strip along its top takes the mouse while locked,
  so Ctrl-drag moves it then), a backdrop box whose edge is green (RANGE,
  MELEE), red (the others), or the theme's color with no state; the state
  text above the bars. Rows possible: main hand always; off hand after its
  first swing (until equipment changes); ranged with a ranged weapon or after
  a ranged swing. Without PLAYER_SWING (Classic Era) no rows, the range box
  only. Unlocked: a sample (all rows, RANGE).
- Hunters (Auto Shot known; John's "Do-Not-Move" zone): the last part of
  each ranged swing, Auto Shot's cast, is red, and two one-shot timers set
  the label HOLD STILL, or STOP while moving (PLAYER_STARTED_MOVING,
  PLAYER_STOPPED_MOVING), then back. Its length scales with ranged haste
  (`Swing.HoldTime`: 0.5 s x this swing / the weapon's base speed, at most
  the swing; 0.5 s without a base speed). The base speed is the weapon
  tooltip's Speed line (`C_TooltipInfo.GetItemByID`, the game's `SPEED`
  label, a decimal point or comma), read once per item. WeaponSwingTimer
  SixxFix's Forever finding (John: "Yes, both"); not checked in client.
- A melee swing (main or off hand) restarts the ranged timer on Forever
  (WeaponSwingTimer SixxFix's finding, its grey "reset"; not checked in
  client): the ranged bar starts over from that swing with the last ranged
  length, grey (`RESET_COLOR`) until the next shot, and the hold-still
  timers start over with it.
- Clip zones (John, 2026-11-24: "What about the aimed shot/sniper shot
  clipping zones?", then "Build it now"; `clip`, true): on the ranged bar,
  orange from (swing - HOLD - cast time) up to the red zone, one per
  cast-time shot known (`Swing.CLIP_SPELLS`: Aimed Shot 19434, by name;
  Sniper Shot 1310687), capped at the whole bar before the red zone.
  Cast times read live at each ranged swing (`C_Spell.GetSpellInfo(name)
  .castTime`, ms; instant, unknown, or secret: no zone). Facts: Forever's
  Aimed Shot is trainable at 20, a 2 s cast, its cooldown shared with
  Multi-Shot (TalentsForeverBook, second-hand); Sniper Shot is a Forever
  Marksmanship talent (row 7). Multi-Shot is instant on Forever (castTime 0
  in client): no zone. NOT CHECKED IN CLIENT: the rule assumes Era's
  behavior (a late cast pushes the next Auto Shot back, not a timer reset);
  John's Hunter was level 18 (TESTING.md has the probe).
- `/dyre debug_swing` (APIs, settings, each check and its answer, the state,
  the weapon subclass, near) and `/dyre swing_reset`.
- Reference AddOns, facts only (no license in either, never copy code):
  ForeverHunterDeadzone (PLAYER_SWING; the four states; polls range) and
  WeaponSwingTimer SixxFix (the class-free order; class spell lists; polls
  range every 0.1 s).
- Later, not built: a melee check for each other class after its in-client
  check (Warrior Rend or Hamstring, Rogue Sinister Strike, ...); swing bars
  on Classic Era from the combat log; a countdown number on the bars.


### Rules

- Event-driven only: no OnUpdate, no polling, no ticker; a one-shot
  `C_Timer.NewTimer` (handle kept) is allowed. No popups in combat. Never
  call SetRaidTarget. Secure buttons never at alpha 0 while they take
  clicks. Sounds stay in Dyre's Sounds (no sound files here). tests/dct.lua
  checks the runtime for OnUpdate, NewTicker, SetRaidTarget,
  COMBAT_LOG_EVENT, and StaticPopup.
- Settings rows are pooled and shared with Blizzard's own settings (the
  Toolkit's 2026-11-19 taint fix): never replace a method on a Blizzard row
  frame or initializer, never write a field on a Blizzard frame, and never
  leave a function of ours on one. `hooksecurefunc` only (GroupSettings.lua
  `NestSoundMenu`).
- Settings tooltips are one plain sentence (John, 2026-11-27: "every one
  of the tooltips seems to start with a good one sentence description, but
  then has nonsensical follow-on text"); tests/tank.lua checks every
  `DYRE_` setting. Details go in README and AGENTS, not the tooltip.
- A settings button row that can be greyed calls
  `DyresToolkit.GreyButtonLabel` (feature-tested, Toolkit 2.17.0), else its
  gold label stays on Forever. DCT has no button row of its own today; the
  widgets' Reset rows are the Toolkit's (`AddWidgetSettings`, which greys
  its own).
- Never compare, print, or index a value that may be secret. Gate on
  required APIs, never on client version (the Toolkit version gate above is
  about the Toolkit's features, not the client).

## Project structure

- Runtime: DyresCombatTools.toc, Core.lua, Tank.lua, Threat.lua,
  PetTaunt.lua, TankButtons.lua, Pull.lua, TankProbe.lua, GroupSettings.lua,
  Swing.lua, loaded in that order (no Bindings.xml: the Toolkit's); the
  threat icons Textures/ShieldFill.tga, ShieldEdge.tga, SwordsFill.tga,
  SwordsEdge.tga (from the Toolkit; made by its scripts/make_icons.py).
- tests/run.lua: the Lua 5.1 entry; it runs tests/tank.lua (threat, tank,
  Pet Taunt; moved from the Toolkit), tests/swing.lua, and tests/dct.lua
  (gate, copy, commands, page, package). They load the Toolkit's files from
  `../DyresToolkit` when present, else `tests/toolkit/` (a vendored copy of
  Core, Layout, Widgets, Settings, Profiles, Spells, Macros, ClassData,
  Owners); `DCT_TOOLKIT=vendored` forces the copy. Refresh the copy from a
  released Toolkit when DCT needs newer Toolkit behavior. No test compares
  files across repositories for byte equality.
- tests/test_*.py: the release helpers. docs/RELEASE_PLAN.md: the release
  process and the release order with the Toolkit.
- Package only the TOC, the nine runtime files, LICENSE, and
  the four textures, under `DyresCombatTools/`, named
  `DyresCombatTools-<version>-forever.zip`, with `release.json` for WowUp.

## Client and API verification

- Target: Forever 1.60.1, build 70888, Interface 16001; Classic Era 1.15.9,
  Interface 11509. Lua 5.1.

## Testing and releases

- Run `lua5.1 tests/run.lua` (with and without `DCT_TOOLKIT=vendored`),
  `luac5.1 -p` on every Lua file, the Python tests, and actionlint on
  workflow changes. Report actual results.
- Read docs/RELEASE_PLAN.md before release steps. Do not create commits,
  tags, uploads, or releases unless asked. Every release needs a CHANGELOG
  section (`## version`, then `### Features` / `### Fixes` / `### Other
  changes`).
- Commit messages: imperative, capitalized subject, at most about 50
  characters, no ending punctuation. No Claude or Anthropic attribution.
