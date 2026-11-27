-- DCT's own tests: the gate (off while Dyre's Toolkit still has these
-- features, or is missing), the one-time copy from DyresToolkitCharDB, the
-- commands, the settings page, and the package rules. tests/run.lua loads
-- this file with its helpers and tests/tank.lua's client harness.
local test, equal, contains, fixture = ...

local function ReadFile(path)
    local file = assert(io.open(path, "rb"))
    local text = file:read("*a")
    file:close()
    return text
end

local function CountMatches(text, pattern)
    local count = 0
    for _ in text:gmatch(pattern) do
        count = count + 1
    end
    return count
end

-- The gate --------------------------------------------------------------------------

test("with a Toolkit that has no tank features, DCT runs: commands, owners, a page, a banner", function()
    local state = fixture()
    equal(state.core.active, true)
    equal(state.ns.available, true)
    equal(type(state.env.SlashCmdList.DYRESCOMBATTOOLS), "function", "/dct")
    equal(state.env.SLASH_DYRESCOMBATTOOLS1, "/dct")
    equal(state.env.SLASH_DYRESCOMBATTOOLS2, nil, "/dct only: no /tanktools")
    for key in pairs(state.env.SlashCmdList) do
        for index = 1, 10 do
            local alias = rawget(state.env, "SLASH_" .. key .. index)
            if key ~= "DYRESTOOLKITTANK" and type(alias) == "string" then
                assert(alias ~= "/dtt" and alias ~= "/tanktools", "DCT registers no " .. alias)
            end
        end
    end
    equal(state.toolkit.KindOwner("threat"), "DyresCombatTools")
    equal(state.category.name, "Threat and Combat Tools", "a page under Dyre's AddOns")
    contains(state.find("Dyre's Threat and Combat Tools 1.0.0 by Dyre"), "/dct opens the settings")
    equal(state.env.BINDING_HEADER_DYRESCOMBATTOOLS, nil, "no binding header of DCT's")
end)

local function AssertOff(state, why)
    equal(state.core.active, false, why)
    equal(state.ns, nil, why .. ": no tank table")
    equal(state.env.SlashCmdList.DYRESCOMBATTOOLS, nil, why .. ": no /dct")
    equal(state.env.SLASH_DYRESCOMBATTOOLS1, nil, why .. ": no /dct alias")
    for _, frame in ipairs(state.frames) do
        if frame.name then
            equal(frame.name:find("DyresCombatTools", 1, true), nil, why .. ": no DCT frame " .. frame.name)
        end
    end
    for _, name in ipairs({"Skull", "SkullMouseover", "NextMarker", "MarkPing", "PingAttack", "Pull"}) do
        equal(state.env["DyresToolkit" .. name], nil, why .. ": no bound button " .. name)
    end
    -- No frame of DCT's has an event left (the "missing" line's frame
    -- unregisters PLAYER_LOGIN once it spoke).
    for _, frame in ipairs(state.frames) do
        if frame.madeBy == "dct" then
            equal(next(frame.events), nil, why .. ": a DCT frame with an event")
        end
    end
    equal(state.env.DyresCombatToolsCharDB, nil, why .. ": nothing saved")
end

test("while the Toolkit still has the features (before 2.16.0), DCT stays off and says nothing", function()
    for _, version in ipairs({"2.15.1", "2.15.0", "2.9.0", "1.0.0"}) do
        local framesBefore
        local state = fixture({toolkitVersion = version, noLogin = true})
        framesBefore = #state.frames
        state.fire("ADDON_LOADED", "DyresToolkit")
        state.fire("ADDON_LOADED", "DyresCombatTools")
        state.fire("PLAYER_LOGIN")
        equal(state.core.state, "toolkit", version)
        AssertOff(state, version)
        equal(state.find("DCT:"), nil, version .. ": no chat line")
        equal(#state.frames, framesBefore, version .. ": no frame made at login")
    end
end)

test("DCT stays off while the Toolkit's /dtt is registered, whatever its version", function()
    for _, version in ipairs({"2.16.0", "3.0.0", "@project-version@"}) do
        local state = fixture({toolkitVersion = version, toolkitHasTank = true})
        equal(state.core.state, "toolkit", version)
        AssertOff(state, version)
        state.env.SlashCmdList.DYRESTOOLKITTANK("pull")
        equal(state.toolkitTank, true, "the Toolkit's /dtt stays the Toolkit's")
    end
end)

test("a Toolkit version that does not read counts only by its /dtt", function()
    local state = fixture({toolkitVersion = "@project-version@"})
    equal(state.core.active, true)
end)

test("the gate compares versions by number", function()
    local state = fixture()
    local before = state.core.VersionBefore
    equal(before("2.15.1", "2.16.0"), true)
    equal(before("2.16.0", "2.16.0"), false)
    equal(before("2.16.1", "2.16.0"), false)
    equal(before("2.9.9", "2.16.0"), true, "not by text")
    equal(before("10.0", "2.16.0"), false)
    equal(before("2.16", "2.16.0"), false, "a missing patch is 0")
    equal(before("x", "2.16.0"), nil)
    equal(before(nil, "2.16.0"), nil)
    equal(state.core.TOOLKIT_WITHOUT_FEATURES, "2.16.0")
end)

test("without Dyre's Toolkit, DCT stays off and says once at login to install it", function()
    local state = fixture({noToolkit = true})
    equal(state.core.state, "missing")
    AssertOff(state, "no toolkit")
    equal(state.count("DCT:"), 1, "one line")
    contains(state.find("install or update it from CurseForge"), "needs Dyre's Toolkit 2.16.0 or later")
    state.fire("PLAYER_LOGIN")
    equal(state.count("DCT:"), 1, "once")
end)

test("a Toolkit without a function DCT uses, or with an older contract, counts as missing", function()
    local state = fixture({noLogin = true})
    local toolkit = state.toolkit
    -- The gate runs as DCT's Core.lua loads: run it again on a changed toolkit.
    toolkit.AddDefaultTick = nil
    equal(state.core.Gate(), "missing", "a missing function")
    local other = fixture({noLogin = true})
    other.toolkit.RequireContract = function() return nil end
    equal(other.core.Gate(), "missing", "an older contract")
end)

-- The one-time copy from Dyre's Toolkit -----------------------------------------------

local TOOLKIT_SAVE = {
    plateThreat = false, targetThreat = true, threatMode = "tank", platePlace = "below", placeSaves = 1,
    plateX = 7, plateY = -3, targetX = 2, targetY = 4, plateScale = 150, targetScale = 80,
    redSound = "bossEmote", losingSound = "none", soundSaves = 1, soloSounds = true, threatSounds = true,
    groupWarnings = true, tankTools = false, pullBars = false, petTaunt = false, barMode = "always",
    pullDisplay = false, pullTick = "none", pullGo = "mapPing", pull = 7, markerOrder = {7, 8},
    bar = {scale = 120, position = {point = "TOP", relativePoint = "TOP", x = 10, y = -20}},
    warning = {scale = 90}, pullTimer = {opacity = 70},
    swing = {show = "always", theme = "tactical", range = false, defaultsVersion = 2, frame = {scale = 110}},
    -- Keys of the Toolkit's own that are not DCT's.
    unrelated = "stays",
}

local function Copy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, item in pairs(value) do copy[key] = Copy(item) end
    return copy
end

test("the first login copies this character's settings from DyresToolkitCharDB, once, and says so", function()
    local source = Copy(TOOLKIT_SAVE)
    local state = fixture({toolkitDb = source})
    local db = state.env.DyresCombatToolsCharDB
    for _, key in ipairs({"plateThreat", "threatMode", "platePlace", "plateX", "plateY", "targetX", "targetY",
            "plateScale", "targetScale", "redSound", "losingSound", "soloSounds", "tankTools", "pullBars",
            "petTaunt", "barMode", "pullDisplay", "pullTick", "pullGo", "pull"}) do
        equal(db[key], TOOLKIT_SAVE[key], key)
    end
    equal(db.markerOrder[1], 7, "marker order")
    equal(db.markerOrder[2], 8, "marker order")
    equal(type(db.bar.position), "table", "the tank bar's place (the widget may store it from its center)")
    equal(db.bar.scale, 120, "the tank bar's size")
    equal(db.swing.show, "always", "a chosen Show")
    equal(db.swing.theme, "tactical")
    equal(db.swing.range, false)
    equal(db.swing.frame.scale, 110, "the swing timer's size")
    equal(db.swing.defaultsVersion, nil, "the Toolkit's marker is not DCT's")
    equal(db.unrelated, nil, "only DCT's keys")
    equal(db.toolkitImported, true)
    equal(state.count("Copied this character's threat, tank, and swing timer settings from Dyre's Toolkit"), 1)
    -- Deep copies; the Toolkit's table is read only.
    equal(db.bar == source.bar, false, "a copy, not the same table")
    equal(source.swing.defaultsVersion, 2, "the source is unchanged")
    equal(source.unrelated, "stays")
    -- The tank bar widget reads the copied place and size (its store).
    equal(state.env.DyresToolkitTankBar.dyre.store, db.bar)
end)

test("the copy runs once: a later login keeps DCT's own settings", function()
    local first = fixture({toolkitDb = Copy(TOOLKIT_SAVE)})
    local saved = first.env.DyresCombatToolsCharDB
    saved.threatMode = "dps"
    local again = fixture({db = saved, toolkitDb = Copy(TOOLKIT_SAVE)})
    equal(again.env.DyresCombatToolsCharDB.threatMode, "dps", "DCT's own choice stays")
    equal(again.find("Copied"), nil, "nothing said")
end)

test("a character with no Toolkit settings gets DCT's defaults, marked, with nothing said", function()
    local state = fixture()
    local db = state.env.DyresCombatToolsCharDB
    equal(db.toolkitImported, true)
    equal(db.plateThreat, true)
    equal(db.swing.show, "combat", "DCT's swing timer: In combat by default")
    equal(state.find("Copied"), nil)
    -- Toolkit settings that turn up later (the Toolkit enabled again) are not copied.
    local later = fixture({db = db, toolkitDb = Copy(TOOLKIT_SAVE)})
    equal(later.env.DyresCombatToolsCharDB.threatMode, "auto")
end)

test("the swing timer's Show: a chosen Off comes with you, the Toolkit 2.15.1 default Off does not", function()
    local function Show(swing)
        return fixture({toolkitDb = {swing = swing}}).env.DyresCombatToolsCharDB.swing.show
    end
    equal(Show({show = "off", defaultsVersion = 2}), "combat", "2.15.1's default Off: DCT's In combat")
    equal(Show({show = "off", defaultsVersion = 2, showChosen = true}), "off", "picked Off in 2.15.1")
    equal(Show({show = "off"}), "off", "an Off from 2.15.0 was chosen")
    equal(Show({show = "combat", defaultsVersion = 2}), "combat")
    equal(Show({show = "always", defaultsVersion = 2}), "always")
    equal(Show({}), "combat", "no Show saved")
    local db = fixture({toolkitDb = {swing = {show = "off", defaultsVersion = 2, showChosen = true}}})
        .env.DyresCombatToolsCharDB.swing
    equal(db.showChosen, nil, "the Toolkit's marker is not kept")
end)

test("a damaged Toolkit save cannot break the copy: DCT repairs what it copied", function()
    local state = fixture({toolkitDb = {threatMode = "bogus", plateX = 999, markerOrder = "x", bar = 5,
        swing = "x", pull = 0.5}})
    local db = state.env.DyresCombatToolsCharDB
    equal(db.threatMode, "auto")
    equal(db.plateX, 50)
    equal(db.markerOrder[1], 8)
    equal(type(db.bar), "table")
    equal(db.swing.show, "combat")
    equal(db.pull, 10)
    equal(state.ns.available, true)
end)

test("old Toolkit saves are read as the Toolkit read them: the old defaults and the old boolean sound", function()
    -- Before SOUND_SAVES 1, the saved defaults were not choices; before 2.9.0, sound = false was "none".
    local db = fixture({toolkitDb = {redSound = "raidWarning", losingSound = "questFailed", platePlace = "right"}})
        .env.DyresCombatToolsCharDB
    equal(db.redSound, nil, "an old default is the default")
    equal(db.losingSound, nil)
    equal(db.platePlace, "left", "an old saved right was the old default")
    local legacy = fixture({toolkitDb = {sound = false}}).env.DyresCombatToolsCharDB
    equal(legacy.redSound, "none")
end)

test("DCT is its own profile part; the copy flag never travels with a profile", function()
    local state = fixture({toolkitDb = Copy(TOOLKIT_SAVE)})
    local parts = state.toolkit.ProfileParts()
    local found = false
    for _, addon in ipairs(parts) do
        if addon == "DyresCombatTools" then found = true end
        equal(addon == "DyresToolkit", false, "the Toolkit has no part for these settings here")
    end
    equal(found, true)
    local text = state.toolkitCore.SerializeSettings("profile", {DyresCombatTools = {toolkitImported = false}})
    equal(type(text), "string")
end)

-- Commands --------------------------------------------------------------------------------

test("/dct has the swing timer's words; unknown words give the usage", function()
    local state = fixture()
    local dtt = state.env.SlashCmdList.DYRESCOMBATTOOLS
    dtt("swing_reset")
    contains(state.find("The swing timer is back"), "default place")
    dtt("debug_swing")
    contains(state.find("swing bars="), "show=combat")
    dtt("nonsense")
    contains(state.find("Use /dct (settings)"), "/dct debug_swing")
    equal(state.find("/dyre pull"), nil, "the /dyre words are the Toolkit's")
end)

test("/dct opens DCT's own page, not the Toolkit's", function()
    local state = fixture()
    state.env.SlashCmdList.DYRESCOMBATTOOLS("")
    equal(state.opened, 8, "the subcategory")
end)

-- The settings page --------------------------------------------------------------------

test("DCT's page has the five sections and the swing timer, and no profile section of its own", function()
    local state = fixture()
    local seen = {}
    for _, entry in ipairs(state.page) do
        if type(entry) == "string" then seen[entry] = true end
    end
    for _, variable in ipairs({"DYRE_PLATE_THREAT", "DYRE_TARGET_THREAT", "DYRE_THREAT_SOUNDS", "DYRE_GROUP_WARNINGS",
            "DYRE_TANK_TOOLS", "DYRE_PULL", "DYRE_SWING_SHOW"}) do
        equal(seen[variable], true, variable)
    end
    equal(state.settings.DYRE_SWING_SHOW.default, "combat", "the gold mark sits on In combat")
end)

-- The package ------------------------------------------------------------------------------

test("the TOC: both clients, OptionalDeps only, the family group, its own saved settings", function()
    local toc = ReadFile("DyresCombatTools.toc")
    contains(toc, "## Interface: 16001, 11509")
    contains(toc, "## OptionalDeps: DyresToolkit, DyresSounds")
    equal(toc:find("## Dependencies", 1, true), nil, "never a hard dependency")
    equal(toc:find("## RequiredDeps", 1, true), nil)
    contains(toc, "## Category: Dyre's AddOns")
    contains(toc, "## Group: DyresToolkit")
    contains(toc, "## SavedVariablesPerCharacter: DyresCombatToolsCharDB")
    local state = fixture()
    equal(table.concat(state.files, ","),
        "Core.lua,Tank.lua,Threat.lua,PetTaunt.lua,TankButtons.lua,Pull.lua,TankProbe.lua,GroupSettings.lua,Swing.lua")
end)

test("DCT ships no Bindings.xml and writes no binding global: Dyre's Toolkit defines the bindings", function()
    equal(io.open("Bindings.xml", "rb"), nil, "no Bindings.xml")
    for _, path in ipairs({"Core.lua", "Tank.lua", "Threat.lua", "PetTaunt.lua", "TankButtons.lua", "Pull.lua",
            "TankProbe.lua", "GroupSettings.lua", "Swing.lua"}) do
        for line in ReadFile(path):gmatch("[^\n]+") do
            if not line:match("^%s*%-%-") then
                equal(line:find("BINDING_", 1, true), nil, path .. ": " .. line)
            end
        end
    end
    local state = fixture()
    for key in pairs(state.env) do
        equal(type(key) == "string" and key:find("^BINDING_") ~= nil, false, "a binding global: " .. tostring(key))
    end
    for _, name in ipairs({"Skull", "SkullMouseover", "NextMarker", "MarkPing", "Pull"}) do
        equal(type(state.env["DyresToolkit" .. name]), "table", "the button " .. name .. " has the bound name")
    end
end)

test("the pull message keeps the Toolkit's prefix, so mixed groups see each other's pulls", function()
    contains(ReadFile("Pull.lua"), 'local PULL_PREFIX = "DyresToolkit"')
end)

test("every runtime file returns at its top while DCT is off", function()
    for _, path in ipairs({"Tank.lua", "Threat.lua", "PetTaunt.lua", "TankButtons.lua", "Pull.lua", "TankProbe.lua",
            "GroupSettings.lua", "Swing.lua"}) do
        local head = ReadFile(path):sub(1, 200)
        contains(head, "if not ns.active then\n    return\nend", path)
    end
end)

test("event-driven only: no OnUpdate, no ticker, no SetRaidTarget, no combat log in the runtime", function()
    for _, path in ipairs({"Core.lua", "Tank.lua", "Threat.lua", "PetTaunt.lua", "TankButtons.lua", "Pull.lua",
            "TankProbe.lua", "GroupSettings.lua", "Swing.lua"}) do
        for line in ReadFile(path):gmatch("[^\n]+") do
            if not line:match("^%s*%-%-") then
                for _, word in ipairs({"OnUpdate", "NewTicker", "SetRaidTarget", "COMBAT_LOG_EVENT", "StaticPopup"}) do
                    equal(line:find(word, 1, true), nil, path .. ": " .. word .. " in " .. line)
                end
            end
        end
    end
end)

test("no sound files: sounds stay in Dyre's Sounds", function()
    for _, path in ipairs({"Tank.lua", "Threat.lua", "PetTaunt.lua", "Pull.lua", "Swing.lua"}) do
        local text = ReadFile(path)
        equal(text:find("%.ogg") or text:find("%.mp3"), nil, path)
    end
end)

test("another AddOn with /dct: DCT says so once at login and names the settings path", function()
    local state = fixture({noLogin = true})
    state.env.SlashCmdList.OTHERADDON = function() end
    state.env.SLASH_OTHERADDON1 = "/DCT"
    state.fire("ADDON_LOADED", "DyresToolkit")
    state.fire("ADDON_LOADED", "DyresCombatTools")
    state.fire("PLAYER_LOGIN")
    local line = state.find("also uses /dct")
    contains(line, "Another AddOn (OTHERADDON)")
    contains(line, "Threat and Combat Tools")
    equal(line:find("tanktools", 1, true), nil, "no backup command to offer")
end)
