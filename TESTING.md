# Testing

## Method

1. **Pinned source review.** Client behavior is read from Blizzard's UI source
   at Gethe/wow-ui-source (Forever 1.60.1 build 70888; Classic Era 1.15.9).
2. **Automated mock tests.** `lua5.1 tests/run.lua` runs the threat, tank,
   and Pet Taunt suite (`tests/tank.lua`), the swing timer suite
   (`tests/swing.lua`), and DCT's own tests (`tests/dct.lua`: the gate, the
   one-time copy from Dyre's Toolkit, commands, the page, the package). They
   load Dyre's Toolkit's files from `../DyresToolkit` when that checkout is
   there, else from the copy in `tests/toolkit` (CI). Set
   `DCT_TOOLKIT=vendored` to run against the copy locally. The Python tests
   (`python -m unittest discover -s tests -p "test_*.py"`) cover the release
   helpers.
3. **In-client checks.** The checklist below covers what mocks cannot:
   protected actions, secret values, taint, the settings panel, layout, and
   sound.

## In-client checklist

### The split from Dyre's Toolkit (1.0.0)

A new AddOn folder needs a full client restart, not `/reload`.

- [ ] With Dyre's Toolkit 2.15.x (which still has these features) and DCT
      1.0.0: no DCT chat line, no second threat label, tank bar, countdown,
      or swing timer; `/dtt` is the Toolkit's and `/dct` is unknown; Options > AddOns > Dyre's
      AddOns has no Threat and Combat Tools page.
- [ ] Same setup: no "Binding ... was attempted to be loaded more than
      once" LUA_WARNING at load (DCT ships no Bindings.xml since John's
      2026-11-26 check found nine of them), and Key Bindings > AddOns shows
      the tank rows once, under the Toolkit's header.
- [ ] Without Dyre's Toolkit: one chat line, "needs Dyre's Toolkit 2.16.0 or
      later", and nothing else.
- [ ] With Dyre's Toolkit 2.16.0 or later, first login on a character that
      used the Toolkit's features: one line "Copied this character's threat,
      tank, and swing timer settings from Dyre's Toolkit."; the labels, tank
      bar place, sounds, and swing timer are as they were. A second login
      says nothing.
- [ ] Same, a character whose Toolkit swing timer was Off by 2.15.1's
      default: DCT shows it in combat. A character that picked Off: stays
      Off.
- [ ] Options > AddOns > Dyre's AddOns > Threat and Combat Tools has the five
      sections and Swing Timer; the profile (copy, export, import) is on
      Dyre's Toolkit's page and copies DCT's settings too.
- [ ] With Toolkit 2.16.0: Key Bindings > AddOns > Dyre's Threat and Combat
      Tools (the Toolkit's header, Bindings.lua) lists the eight tank
      bindings once, with "Skull mouseover, else target" and no separate
      mouse row; a key bound before still marks, pings, and pulls through
      DCT's buttons, also a key bound to the old "Skull the mob under your
      mouse" row.
- [ ] A pull started by a player with Dyre's Toolkit 2.15.x shows Dyre's
      countdown for a DCT player in the same group, and the other way round.

### Swing timer and range box (In combat by default)

Settings: Dyre's AddOns → Threat and Combat Tools → "Swing Timer". `/dct debug_swing`
prints the checks and the state; `/dct swing_reset` puts the frame back.

- [ ] A character that had 2.15.0: Show is "Off" after 2.15.1, and no frame
      shows in combat. Choose "In combat" for the checks below.
- [ ] Show "In combat": hidden out of combat, shown when a fight
      starts, hidden when it ends. "Always": shown all the time. "Off": never,
      also while unlocked. `/dyre unlock`: a sample (three bars, RANGE) to move.
- [ ] Melee: the main-hand bar fills once per swing, in step with your swings;
      dual wielding, the off-hand row appears at the first off-hand swing.
- [ ] Hunter, Auto Shot: the ranged bar fills once per shot; its last half
      second is red; the label says HOLD STILL there, STOP while moving.
      Moving in the red part delays the shot.
- [ ] Hunter level 12 or more (Wing Clip), an enemy target, walking in: over
      35 yd TOO FAR (red), then RANGE (green), then DEAD ZONE (red) inside
      8 yd, then MELEE (green). No blinking on an edge. Also in combat.
- [ ] Hunter below level 12 (no Wing Clip): TOO CLOSE inside 8 yd; MELEE
      while your melee swings land, back to TOO CLOSE a few seconds after.
- [ ] Warrior or Rogue with a bow, gun, crossbow, or thrown weapon: RANGE and
      TOO FAR; TOO CLOSE in the dead zone. Wand user: RANGE and TOO FAR, never
      a dead zone. Change weapons: the right check follows (`/dct debug_swing`).
- [ ] Turn "Range box" off: no state text, the theme's edge; `/dct
      debug_swing` says "swing checks: none". Theme "Tactical black and red":
      flat bars, thin red edge. Width, size, and opacity sliders apply at once.
- [ ] Classic Era: no bars (no PLAYER_SWING); the range box still works.
- [ ] Clip zones (level 20 or more, Aimed Shot): first the rule. Run
      `/run CF=CreateFrame("Frame") CF:SetScript("OnEvent",function(_,e,a,b,c) print(format("%.2f",GetTime()),e,a,b,c) end)`
      then `/run CF:RegisterEvent("PLAYER_SWING") CF:RegisterUnitEvent("UNIT_SPELLCAST_START","player") CF:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED","player")`,
      and cast Aimed Shot right after an Auto Shot, then just before the next.
      The zone assumes a late cast pushes the next Auto Shot (PLAYER_SWING
      type 2) back by the overlap; if it restarts the timer instead, the rule
      changes. Then: the orange zone ends at the red zone and is about 2 s
      wide; started before it, no delay; inside it, the next Auto Shot is late.
      Sniper Shot (talent) gets the lighter shade.
- [ ] Ranged haste (a quiver, Rapid Fire): the red zone gets shorter with
      the ranged swing (0.5 s x swing / the bow's Speed). Without haste it is
      0.5 s.
- [ ] Hunter in melee: after a melee swing, the ranged bar starts over and is
      grey; the next Auto Shot comes one full ranged swing after that melee
      swing (if not, Forever does not reset the ranged timer: undo it).
- [ ] Show Always: "Opacity out of combat" fades it out of combat, "Opacity
      in combat" in combat; unlocked it is solid. Ctrl-drag on its top edge
      moves it while locked.
- [ ] Only bars in use: a Hunter shooting sees only the ranged bar (on top);
      melee swings add the main-hand bar under it, and it leaves about two
      seconds after the last swing; the frame grows and shrinks from its top
      edge. A Warrior keeps the main hand, and the ranged bar joins while
      shooting. Turn it off: every bar your weapons can use.


### Group warnings and tank tools

Ported from Dyre's Tank Tools' checklist; none is checked in client yet.

#### Threat sounds when solo

- [ ] Solo, "Threat sounds when solo" off (the default; also on a character
      that had a test build): pull a mob; the label turns red with no
      sound. `/dct debug_threat` shows `soloSounds=false` and `solo=1` (or
      more) on the red line.
- [ ] Join a party with it still off: the red sound plays on a pull.
- [ ] Turn it on: solo pulls play the red sound.

#### Load (both clients)

- [ ] No Lua errors at login with `/console scriptErrors 1`, and no chat line
      from DCT but the welcome line (if on). With Dyre's Tank Tools also installed, disable it
      first: both would show labels and bind the same keys.
- [ ] Options > AddOns > Dyre's AddOns > Threat and Combat Tools shows, in order, "Threat Indicators:
      Nameplates", "Threat Indicators: Target Frame", "Threat Indicators:
      Sounds", "Group Warnings", and "Tank Tools" (John, 2026-11-12), each
      with only its own settings. Each section's first setting is
      "Enable", ticked (John, 2026-11-15). Untick each one in turn: Sounds,
      no threat sounds in a group while the labels still change color;
      Group Warnings, no pull bars, no countdown on screen, no pet taunt
      warning; Tank Tools, no bar, also with `/dyre unlock`, while
      `/dct pull` still works.
- [ ] The "Pull countdown (seconds)" slider shows its number (for example
      "10 s") at the right, and a gold mark at 10.

#### Tank bar (both clients)

- [ ] Tank button bar on "Auto (tank only)": a Warrior's bar shows at once
      in Defensive Stance; in Battle or Berserker Stance it hides after 30
      seconds out of combat, not before.
- [ ] Tank bar on Auto, any class: form a group and take the Tank role
      without changing stance or form; the bar shows within about 2 seconds.
- [ ] Stance dancing (out of Defensive Stance and back within 30 seconds, a
      few times): the bar does not flicker.
- [ ] A fight that starts during the 30 seconds: the bar stays in combat,
      and hides 30 seconds after the fight ends.
- [ ] A Druid's bar shows in Bear Form (Dire Bear Form too) and hides 30
      seconds out of it.
- [ ] A Paladin's bar shows with Righteous Fury and hides 30 seconds after
      it ends or is cancelled.
- [ ] A Mage or Priest with the Tank role in a group (or a raid's main tank):
      the bar shows and never hides while the role stays; it hides 30 seconds
      after the role changes or the group ends.
- [ ] Defensive Stance taken in combat: the bar shows at the end of combat,
      with no "blocked" message and no Lua error.
- [ ] Always: the bar shows for every class. Never: it stays hidden, also in
      Defensive Stance; `/dyre unlock` shows it to move, `/dyre lock` hides it.
- [ ] With the bar hidden, the key bindings still mark, ping, and pull.
- [ ] Key Bindings > AddOns > Dyre's Threat and Combat Tools lists the eight tank bindings (Toolkit 2.16.0).
- [ ] `/dct debug` prints the owners (all
      DyresCombatTools), pings, and the pull runner.

#### Pet taunt (both clients)

- [ ] Hunter with Growl on autocast in a party without the Tank role: the
      message box and the chat line; none solo or as the Tank role.
- [ ] Solo with Growl already on autocast, form a group (also inside an
      instance, as Ruins of Larderon): the message box and the chat line
      within about 2 seconds, without touching Growl (John found it missing,
      2026-11-25; the fix confirmed in client the same day).
- [ ] Warlock with the Voidwalker's Torment on autocast: the same.
- [ ] `/dyre unlock` on a Warlock: the sample says "Torment and Suffering
      are on autocast in a group. Turn it off."; on a Hunter, "Growl is
      ..." (1.0.1).
- [ ] With Dyre's Buff Reminders installed: one warning, not two (once DBR
      yields through "warn:petTaunt").
- [ ] `/dyre unlock` shows the sample message box to move.

#### Focus lines (Forever; John, 2026-11-12)

- [x] `/focus [@mouseover,harm,nodead][@focus,noharm][@focus,dead]` by
      hand: no focus, the target or mouseover becomes the focus; a live
      focus stays (John, in client).
- [ ] Mage: "! Polymorph" one mob, kill it, then in the same fight target
      another mob (no mouseover) and press "! Polymorph": it focuses, marks,
      and sheeps the new mob, and its timer shows.
- [ ] With a live sheep as focus, target another mob and press it: the
      sheep stays the focus. Shift-press, and a right-click on the action
      button: the focus clears, and the target becomes the new focus. A key
      binding with Shift clears it; without Shift it does not.

#### Taunt probe (Forever first, then Era; John, 2026-11-12)

The probe only counts: it sends nothing to chat or the party and saves
nothing. `/reload` first, so the counts start at 0.

- [ ] In a party in a dungeon, out of combat and then in combat, each of
      these once or more (not the tank, where you can):
      - a Warrior who is not the tank casts Taunt (and Mocking Blow or
        Challenging Shout if known);
      - a Druid who is not the tank casts Growl or Challenging Roar in Bear
        Form;
      - a Hunter's pet Growls (autocast on);
      - a Warlock's Voidwalker casts Torment (or Suffering);
      - a Paladin casts Righteous Fury;
      - you cast one of them too (the "player" and "pet" lines are the
        control: your own spell IDs are known to read in combat).
- [ ] Then type `/dct debug_taunts` and paste every "debug_taunts" line.
      What decides the design: on the "party" and "partypet" lines, the
      "combat:" part. "spellRead" above 0 there means party casts read in
      combat; "spellSecret", "guidSecret", or "unitSecret" there means the
      client hides them. "matches:" and the "recent" lines show which
      watched spells were seen (unit token and spell only, no names).
- [ ] `/dct debug` has the line "debug taunt probe: N casts seen, N
      watched".

#### DoT aura confirm (Forever first, then Era; 2.10.1)

On a class with a DoT (Hunter: Serpent Sting), with Dyre's Debuff Tracker.
`/ddt debug` shows the last cast as `candidates=N bound=...`.

- [ ] Two mobs with the same name, in combat: target A, mouseover-DoT B
      (no DoT on it yet). Only B gets a row; `bound=aura`.
- [ ] The same, but cast at A with the mouse resting on B: only A;
      `bound=aura`.
- [ ] Recast on A while it has the DoT, mouse on B: no row for B;
      `bound=refresh`.
- [ ] One mob of the name: its row at once; `bound=single`.
- [ ] A dungeon (secret GUIDs), the first two checks again.
- [ ] In a group: note any wrong mob (another player's aura in the 1.5 s).
- [ ] Era: the first two checks (the aura data reads there).

#### DoT probe (Forever first, then Era; John, 2026-11-16)

The question: when your DoT lands, can AddOn code see which mob got it
(UNIT_AURA for that mob's unit token), in combat? The probe only counts:
it sends nothing and saves nothing. `/reload` first. Use a class with a DoT
(Hunter: Serpent Sting).

- [ ] Out of combat (the control): DoT a mob you target, then type
      `/dct debug_dots`. The "recent" line should show its plate or
      `target` with "ours".
- [ ] In combat, open world: DoT your target; then, with the mouse on
      another mob, DoT it by mouseover (a mob with your target's name is
      best: Bug 2). Then a dungeon, the same.
- [ ] Type `/dct debug_dots` and paste every "debug_dots" line. What
      decides the design, on the "combat:" line and the "recent ... combat"
      lines: a mob's plate (nameplateN) listed with "ours" means the mob is
      known; "unitSecret", "infoSecret", "addedSecret", or "spellSecret"
      mean the client hides that part. "tgt" and "mo" say whether that unit
      is your target or mouseover.
- [ ] `/dct debug` has the line "debug DoT probe: N DoT casts, N with
      UNIT_AURA".

#### Threat (Forever, then Era)

- [x] `/dct debug_threat` in combat in the open world on Forever (John,
      build 70888, 2026-11-11): the target token reads, plate tokens are
      secret except UnitThreatSituation.
- [ ] `/dct debug_threat` in combat in a dungeon on Forever, with an enemy
      target and plates: does UnitThreatSituation still read on a plate?
      Keep the chat lines.
- [ ] In a group on Forever: the plate of your target shows a real percent
      and early yellow when a party member nears the pull point; other
      plates show the percent in the threat color.
- [ ] `/dct debug_threat` in a party in combat in the open world on
      Forever: the "target party1:" and "nameplateN party1:" lines. Keep
      them: nil on a plate means the pull bars cannot work there.
- [ ] The same in combat in a dungeon on Forever.
- [ ] Tank view in a party: a mob where a DPS passes you shows LOSING in
      orange on its plate, with the losing sound once (Cartoon shake, or
      quest failed without Dyre's Sounds 1.5.0; not the red sound); "Sound
      when losing a mob" set to None stops it.
- [ ] Pull bars: under each enemy plate, one thin bar per party member in
      its class color, rising as that member's threat rises; none in a raid,
      in the DPS view, or solo; the label placed Below sits under them.
- [ ] The icons show on both clients: the drawn shield and crossed swords,
      each in the text's color (green, yellow, red, blue, orange for
      LOSING, white when secret), with a dark outline that reads on light
      and dark nameplates; not a green square (a texture that did not load).
      Note whether 14 is a good size.
- [ ] "Alert sound (red)" and "Warning sound (orange)": each
      dropdown lists None and eight sounds; picking one plays it once; in
      combat a pick plays nothing. Listen to each sound on both clients
      (Quest failed plays by number 847; no sound in the list has been
      heard in client yet).
- [ ] With Dyre's Sounds: both menus show Game Warnings first, then its
      groups as submenus, and Text to Speech at the top; a pick plays it
      once; the alarms play it; Text to Speech says "Aggro lost" (tank),
      "Aggro" (DPS), "Losing". Other settings dropdowns (Dyre's Sounds' own
      pickers, other AddOns) still show their own menus and labels.
- [ ] Pick a Dyre's Sounds sound, disable Dyre's Sounds, /reload: the menu
      shows the default sound as chosen and the default plays; enable it
      again: your pick is back.
- [ ] After the update from an earlier 2.9.0 test build with "Warning
      sound (orange)" turned off: it shows None.
- [ ] Defaults with Dyre's Sounds 1.5.0 (John, 2026-11-11): "Alert sound
      (red)" shows "Dyre's Alerts: Bell buzz" and the alarm plays
      it; "Warning sound (orange)" shows "Dyre's Alerts: Cartoon shake"
      and LOSING plays it. A save from an earlier test build that had the
      raid warning (red) or quest failed (losing) now shows these.
- [ ] Defaults without Dyre's Sounds 1.5.0 (disable it, /reload): the menus
      show Raid warning and Quest failed as chosen, and those play; enable
      it again: Bell buzz and Cartoon shake are back. The settings'
      Defaults button gives the same result.
- [ ] The four label sliders (nameplate and target, left/right and up/down)
      show "0 px" and a gold mark at 0; moving one moves the shown labels at
      once, also in combat; at 0 the labels sit where they did before.
- [ ] The two label size sliders show "100%" and a gold mark at 100; at
      200% the icon and text are twice as big, at 50% half, at once, also in
      combat; the gap to the bar and the px offsets stay the same on screen;
      the text stays sharp (not blurred) at 200%. Seen (John, Forever,
      2026-11-13, screenshot: a large nameplate label left of the bar, the
      target label at its default size): "The adjustable size font scales
      well enough, I think it looks fine." The size range and combat are not
      noted as checked.
- [ ] Label left of each enemy nameplate's bar by default (2.9.1; John,
      2026-11-14), not on the mob's name, and DIES right of the bar; Right,
      Above, and Below in the settings move it. A character saved before
      2.9.1 with Right moves to Left once. The target's label sits
      above the target frame's bar. With Dyre's Debuff Tracker or WTF: the
      label and the DIES badge do not cover each other.
- [ ] Tank view (group role Tank, raid main tank, Bear Form, Righteous
      Fury, Defensive Stance, or forced):
      green while you tank, yellow while another has more threat, red when a
      mob leaves you.
- [ ] Tank view, a pack pull (John, 2026-11-25: a siren on almost every
      pull): no siren at the pull; mobs not yet on you show yellow PULLING,
      then green. A mob that goes to another player with more threat turns
      red with the siren. Right after a pull, `/dct debug_threat` lists
      the changes: a red one at the start (pull+0-2s, status=0) means a
      pack's mob read 0, so the 3 s grace period is still needed.
- [ ] Tank view in a group: yellow before a DPS pulls (at 80% of the pull
      point), blue for a mob another Tank-role player or raid main tank holds.
- [ ] DPS view: green below the tank, yellow at 80% of the pull point on
      your target and its nameplate (no sound), orange above the tank,
      red with aggro (John, 2026-11-13). In a group, green or yellow to orange plays "Warning sound
      (orange)" once; orange to red plays "Alert sound (red)". A mob first
      seen already orange plays nothing. Text to Speech says "High threat".
- [ ] In a raid as the tank: no frame rate drop from the group threat read.
- [ ] The red sound when a mob turns red, not again while it stays red, at
      most once in 2 seconds; none with None; none while the status is
      secret; another choice plays that sound instead.
- [ ] The red sound on every pull (fixed 2026-11-11: it played about 1 in
      10): ten pulls in the DPS view (solo caster form, or a DPS in a
      group) each play it once; then `/dct debug_threat` shows "red sound:
      seen=10 played=10" or the skips with their reasons (gap, none, calm,
      view, same). In combat, a new plate already red and a target change
      onto a mob on you play it (2 s gap allowing); a form change that turns
      a label red plays nothing; your target and its plate count as one
      mob.
- [ ] `/dct debug` names the view and why. Auto changes on a role change
      and a form or stance change, at once, and the tank bar agrees (it
      only hides 30 s later).
- [ ] Paladin (John's bug, 2026-11-11): Righteous Fury on, the shield shows
      and a mob on you is green; Righteous Fury off, the crossed swords show
      and a mob on you is red. Protection talents alone do not change it.
- [ ] Warrior: Defensive Stance gives the shield; Battle or Berserker
      Stance gives the crossed swords.
- [ ] Paladin with Righteous Fury, solo, a long fight (John's bug,
      2026-11-11: green turned red at 100% after a few swings): the label
      stays green; then `/dct debug_threat`: "righteous fury reads combat:"
      shows what the game gave in combat (nil proves the cause) and
      ", aura secret ..." what C_Secrets.ShouldSpellAuraBeSecret said
      (expected: true in combat, false out of combat, as Dyre's Buff
      Reminders' probe saw); "view changes in combat=0", and red "view=0".
      Click Righteous Fury off in combat: the view changes at once if
      "aura secret" says false in combat, else when combat ends. Out of
      combat, click it off: the crossed swords show at once (if they do
      not, ShouldSpellAuraBeSecret says true out of combat too; report it).
- [ ] Druid, in combat (John's test, 2026-11-11): Bear Form gives the
      shield, caster or Cat Form the crossed swords, at once each time.
      Warrior, in combat: Defensive Stance and Battle Stance switch at once.
- [ ] Where values are secret: the percent shows in white, the icon still
      shows, no Lua error.
- [ ] With Plater or Platynator: the label sits beside their
      health bar.

#### Marking (both clients, in combat)

- [ ] Skull binding with the mouse over a mob: skull on that mob, not on the
      target; with the mouse over nothing (or a dead or friendly unit): skull
      on the target. No "blocked" popup.
- [ ] Skull button click: skull on the target (no mob under the mouse).
- [ ] Skull and ping binding with the mouse over a mob: skull and the
      Attack ping on that mob; else both on the target.
- [ ] Next marker: skull, cross, square... on each press; the button icon
      shows the next marker; after combat it starts at skull again.
- [ ] Count how many fast presses the game takes before its marker cooldown.
- [ ] In a raid without assist: the game refuses the marker, the toolkit shows no
      error.

#### Pings

- [ ] Forever: Attack, Warning, Assist, On my way on the target; Skull and
      ping in one press.
- [ ] Classic Era: confirm that `/ping` does not exist and that the toolkit shows no
      ping buttons.

#### Pull

- [ ] With DBM, then with BigWigs: PULL and `/dct pull 5` start their timer;
      `/dct pull 0` cancels it.
- [ ] Without both: the game's countdown starts, solo, as leader, and as a
      party member without lead, and as a raid member without assist.
      Record each: does the game take it (all members see its countdown),
      or refuse it (the chat line "The game refused its countdown", and
      what else the game shows: a red error, a chat line, nothing)?
- [ ] No "AddOn blocked" message from `C_PartyInfo.DoCountdown`.
- [ ] Era: the same; does START_PLAYER_COUNTDOWN come there?

#### Dyre's countdown on screen (both clients)

- [ ] Without a boss mod: a pull (another member's /countdown 10, or the
      PULL button) shows Dyre's countdown and NOT the game's own (no game
      bar, no game big numbers): the number pops each second, gold, orange
      at 3 and 2, red at 1; the bar drains smoothly to empty; "Pull in N -
      Name" names the starter; a tick on 5 to 1; "PULL!" grows and fades
      with the go sound.
- [ ] Turn "Dyre's countdown on screen" off: the game's own countdown is
      back at once (out of combat), and Dyre's never shows.
- [ ] /console taint.log 1 (or 2), a few pulls in and out of combat, a PvP
      or Challenge Mode start timer if one is at hand: no taint line names
      DyresToolkit or TimerTracker; no "AddOn blocked" message.
- [ ] DBM only, with DBM's "Do not show Pull/Break Timer bar" and "Do not
      show announce text" on (/dbm > Global Disables & Filters > Disable DBM
      Features): Dyre's countdown shows, the game's numbers do not, and no
      DBM bar or text shows. Does DBM's countdown voice still play? Turn the
      DBM option off again: the next pull after a /reload or a group change
      is DBM's again, with the game's numbers.
- [ ] DBM and BigWigs both loaded (John's setup), DBM's bar off: Dyre's
      countdown stays hidden (BigWigs shows its own).
- [ ] With DBM (its bar on) or BigWigs loaded: Dyre's countdown never shows; theirs
      shows; the game's countdown is as they leave it.
- [ ] A member with DBM pulls (as leader): one countdown, not two.
- [ ] A cancel (/countdown 0, /pull 0, `/dct pull 0`) shows "Pull
      cancelled" for a moment, then hides.
- [ ] Combat during the countdown does not stop it.
- [ ] The tick and go sound menus: Game Warnings first, then Dyre's Sounds;
      None silences each; Text to Speech says the numbers and "Pull".
- [ ] "Countdown size (%)" and "Countdown opacity (%)" change it; the
      checkbox tooltip shows the Sending and On screen parts.
- [ ] The dash in "Pull in 10 - Name" and the font look right; the bar and
      numbers are readable on bright and dark ground.
- [ ] Two players with Dyre's countdown (DCT, or Toolkit 2.15.x), the game refuses the countdown (not the leader):
      the other one sees Dyre's countdown.
- [ ] `/dyre unlock` shows a sample "10" to move; it stays put after
      /reload.
- [ ] In a group with a DBM user and a BigWigs user: a few seconds after
      the group forms, `/dct debug` names each with its version; a member
      with neither is "unknown"; after someone leaves, they are gone from
      the list. In a 5-player party: do BigWigs' messages (sent on "RAID")
      arrive at all?

#### Bar

- [ ] `/dyre unlock` shows the outline; drag by a button; `/dyre lock`.
      Locked: Ctrl-drag by a button. The drag does not click the button (no
      marker, no ping). No drag in combat. `/dct reset`.
- [ ] Hide the bar in combat in the settings: it hides after combat.
- [ ] `/reload`: the place and the settings stay.

