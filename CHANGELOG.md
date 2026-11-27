# Changelog

Player-facing changes for each Dyre's Threat and Combat Tools release, newest
first. The release builder copies the section for the TOC version into the
GitHub release notes and the CurseForge changelog, and fails if that section
is missing.

## 1.0.1

### Fixes
- The pet taunt warning's sample, shown while frames are unlocked, now names your class's pet taunts in your game's language (a Warlock sees Torment and Suffering, not Growl), worded as the real warning.
- Every settings tooltip is now one short sentence.

## 1.0.0

### Features
- First release. The threat labels and sounds, pull bars, Pet Taunt warning, tank button bar (marks, pings, pull), pull countdown, and swing timer with its range box move here from Dyre's Toolkit, so the Toolkit is a quiet shared library again. Each part has its own switch.
- Your settings come with you: at its first login on a character, this AddOn copies that character's threat, tank, and swing timer settings from Dyre's Toolkit, once.
- The swing timer shows in combat by default. If you turned it off in Dyre's Toolkit, it stays off.
- Your key bindings for the tank buttons stay: the binding names are the same.
- One Skull key: Skull marks the mob under your mouse, else your target, as Next marker does. A key you bound to the old "Skull the mob under your mouse" does the same. Skull and ping marks and pings Attack on that same mob. They are under Key Bindings > AddOns > Dyre's Threat and Combat Tools.
- `/dct` opens the settings, under Options > AddOns > Dyre's AddOns > Threat and Combat Tools.

### Other changes
- Needs Dyre's Toolkit 2.16.0 or later. With an older Dyre's Toolkit, which still has these features, this AddOn stays off, so nothing shows or sounds twice. Update Dyre's Toolkit when 2.16.0 is out and this AddOn turns on.
