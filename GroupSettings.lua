local _, ns = ...
-- Off while DCT is off (Core.lua): no frames, events, or commands.
if not ns.active then
    return
end
local DTT = ns.tank

-- Five sections on DCT's settings page (Dyre's Toolkit 2.9.0; John,
-- 2026-11-12): "Threat Indicators: Nameplates" (the threat view and the
-- plate labels), "Threat Indicators: Target Frame", "Threat Indicators:
-- Sounds" (red, losing, solo), "Group Warnings" (pull bars, the countdown,
-- the Pet Taunt warning), and "Tank Tools" (the button bar, the pull
-- length). Proxy settings read and write DyresCombatToolsCharDB. A section header shows where the client has one
-- (CreateSettingsListSectionHeaderInitializer, as Dyre's Buff Reminders
-- uses it); dropdowns only where the client has the dropdown API.
local MODE_LABELS = {auto = "Auto", tank = "Tank", dps = "DPS/Healer"}
local BAR_LABELS = {auto = "Auto (tank only)", always = "Always", never = "Never"}
local PLACE_LABELS = {right = "Right of the bar", left = "Left of the bar", above = "Above the bar",
    below = "Below the bar"}

local category, layout

local function Section(text)
    if type(CreateSettingsListSectionHeaderInitializer) == "function" and type(layout) == "table"
            and type(layout.AddInitializer) == "function" then
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
    end
end

local function Proxy(variable, variableType, name, default, getValue, setValue)
    return Settings.RegisterProxySetting(category, variable, variableType, name, default, getValue, setValue)
end

local function Checkbox(variable, name, key, default, tooltip, after)
    local setting = Proxy(variable, Settings.VarType.Boolean, name, default,
        function() return DTT.db[key] end,
        function(value)
            DTT.db[key] = value == true
            after()
        end)
    Settings.CreateCheckbox(category, setting, tooltip)
end

-- A dropdown over a list of string choices; skipped on a client without the
-- dropdown API (the saved value still works).
local function Dropdown(variable, name, key, choices, labels, tooltip, after, default)
    if type(Settings.CreateDropdown) ~= "function" or type(Settings.CreateControlTextContainer) ~= "function" then
        return
    end
    local setting = Proxy(variable, Settings.VarType.String, name, default or choices[1],
        function() return DTT.db[key] end,
        function(value)
            for _, choice in ipairs(choices) do
                if value == choice then
                    DTT.db[key] = value
                end
            end
            after()
        end)
    local function Options()
        local container = Settings.CreateControlTextContainer()
        for _, choice in ipairs(choices) do
            container:Add(choice, labels[choice])
        end
        return container:GetData()
    end
    Settings.CreateDropdown(category, setting, Options, tooltip)
end

-- A warning sound dropdown: "Game Warnings" (None and the game sounds), then
-- every Dyre's Sounds group when that library is loaded, as a nested menu
-- like Dyre's Sounds' own pickers (its Menu.lua: a submenu per group, a
-- sound without a group at the top). The settings dropdown's control frames
-- are pooled and shared (Dyre's Sounds and others wrap them too), so the
-- nested menu is built only for a dropdown set up here and every other one
-- is handed on. The plain list (every choice by its full label) stays where
-- the client has no menu hooks.
local function SoundMenuInserter()
    return function(setting, rootDescription)
        local function IsSelected(key)
            return setting:GetValue() == key
        end
        local function SetSelected(key)
            setting:SetValue(key)
        end
        local game = rootDescription:CreateButton(DTT.SOUND_GROUP)
        for _, sound in ipairs(DTT.SOUNDS) do
            game:CreateRadio(sound.label, IsSelected, SetSelected, sound.key)
        end
        local library = DTT.SoundLibrary()
        if not library then
            return
        end
        for _, group in ipairs(library.Groups()) do
            if #group.sounds == 1 and not library.Parts(group.sounds[1]) then
                rootDescription:CreateRadio(group.sounds[1].label, IsSelected, SetSelected, group.sounds[1].key)
            else
                local submenu = rootDescription:CreateButton(group.name)
                for _, sound in ipairs(group.sounds) do
                    local _, name = library.Parts(sound)
                    submenu:CreateRadio(name, IsSelected, SetSelected, sound.key)
                end
            end
        end
    end
end

-- Every choice: the game sounds, then Dyre's Sounds' (when loaded).
function DTT.SoundOptions()
    local options = {}
    for _, sound in ipairs(DTT.SOUNDS) do
        options[#options + 1] = {key = sound.key, label = DTT.SOUND_GROUP .. ": " .. sound.label,
            group = DTT.SOUND_GROUP, name = sound.label}
    end
    local library = DTT.SoundLibrary()
    for _, sound in ipairs(library and library.List() or {}) do
        local group, name = library.Parts(sound)
        options[#options + 1] = {key = sound.key, label = sound.label, group = group or sound.label, name = name}
    end
    return options
end

-- Taint (a player's error, 2026-11-19: Blizzard's "Status Text" setting
-- failed with "attempt to compare a secret number value (execution tainted by
-- 'DyresToolkit')"; John chose this fix): the settings list pools its row
-- frames and shares them with Blizzard's own settings, so code here never
-- replaces a method or writes a field on them and leaves no function of ours
-- there (no getSelectionTextFunc). It adds secure hooks only: Blizzard's setup
-- runs first, untainted, then the hook rebuilds the menu only while the row
-- drawn is ours. The dropdown shows the chosen sound's name (the menu's own
-- selection text).
local hookedFrames = setmetatable({}, {__mode = "k"})

local function Call(object, method, ...)
    if type(object) == "table" and type(object[method]) == "function" then
        return object[method](object, ...)
    end
end

local function NestDropdown(frame)
    local initializer = Call(frame, "GetElementData")
    local dropdown = type(initializer) == "table" and initializer.dyreToolkitSoundMenu
        and type(frame.Control) == "table" and frame.Control.Dropdown
    if type(dropdown) ~= "table" then
        return
    end
    local setting = Call(initializer, "GetSetting")
    local initTooltip
    if type(Settings.CreateOptionsInitTooltip) == "function" then
        initTooltip = Settings.CreateOptionsInitTooltip(setting, Call(initializer, "GetName"),
            Call(initializer, "GetTooltip"), Call(initializer, "GetOptions"))
    end
    Settings.InitDropdown(dropdown, setting, SoundMenuInserter(), initTooltip)
end

local function NestSoundMenu(initializer)
    if type(initializer) ~= "table" or type(initializer.InitFrame) ~= "function"
            or type(Settings.InitDropdown) ~= "function" or type(hooksecurefunc) ~= "function" then
        return
    end
    initializer.dyreToolkitSoundMenu = true
    initializer.data = initializer.data or {}
    initializer.data.forceSteppersHidden = true
    hooksecurefunc(initializer, "InitFrame", function(_, frame)
        -- The control sets its menu up again on a value change (InitDropdown).
        if type(frame) == "table" and not hookedFrames[frame] and type(frame.InitDropdown) == "function" then
            hookedFrames[frame] = true
            hooksecurefunc(frame, "InitDropdown", NestDropdown)
        end
        NestDropdown(frame)
    end)
end

-- key: "redSound", "losingSound", "pullTick", or "pullGo". The dropdown
-- shows the choice in effect (no choice, or a saved Dyre's Sounds key
-- without its library, shows the default in effect: a Dyre's Sounds default
-- without the library shows its game fallback); a pick saves and plays once
-- (not in combat). Picking the default (or the settings' Defaults, which
-- sets the default key even without the library) saves nil: the player's
-- own choices only.
local function SoundDropdown(variable, name, key, default, speech, tooltip)
    if type(Settings.CreateDropdown) ~= "function" or type(Settings.CreateControlTextContainer) ~= "function" then
        return
    end
    local setting = Proxy(variable, Settings.VarType.String, name, default,
        function() return DTT.EffectiveSound(DTT.db[key], default) end,
        function(value)
            local choice = (value == default or DTT.SOUND_LABELS[value]) and value or DTT.LibrarySound(value)
            if choice then
                DTT.db[key] = choice ~= default and choice or nil
                DTT.PreviewSound(choice, default, speech)
            end
        end)
    local function Options()
        local container = Settings.CreateControlTextContainer()
        for _, option in ipairs(DTT.SoundOptions()) do
            container:Add(option.key, option.label)
        end
        return container:GetData()
    end
    NestSoundMenu(Settings.CreateDropdown(category, setting, Options, tooltip))
end

-- A slider of whole numbers with its number at the right and the gold
-- default mark (found in client, 2026-11-11: neither showed on a bare one).
local function Slider(variable, name, key, minimum, maximum, default, format, sanitize, tooltip, after)
    local setting = Proxy(variable, Settings.VarType.Number, name, default,
        function() return DTT.db[key] end,
        function(value)
            DTT.db[key] = sanitize(value)
            if after then
                after()
            end
        end)
    local options = Settings.CreateSliderOptions(minimum, maximum, 1)
    if type(options.SetLabelFormatter) == "function" and type(MinimalSliderWithSteppersMixin) == "table"
            and MinimalSliderWithSteppersMixin.Label then
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(value) return string.format(format, value) end)
    end
    ns.AddDefaultTick(Settings.CreateSlider(category, setting, options, tooltip),
        {min = minimum, max = maximum, default = default})
end

local function OffsetSlider(variable, name, key, tooltip)
    Slider(variable, name, key, DTT.OFFSET_MIN, DTT.OFFSET_MAX, 0, "%d px", DTT.SanitizeOffset, tooltip,
        DTT.RefreshThreat)
end

local function ScaleSlider(variable, name, key, tooltip)
    Slider(variable, name, key, DTT.SCALE_MIN, DTT.SCALE_MAX, DTT.DEFAULT_SCALE, "%d%%", DTT.SanitizeScale,
        tooltip, DTT.RefreshThreat)
end

-- A change of owner: the feature turns on or off.
function DTT.OnOwnerChanged(feature)
    if feature == "threat" then
        DTT.RefreshThreat()
    elseif feature == "petTaunt" then
        DTT.CheckPetTaunt()
    elseif feature == "pullDisplay" then
        DTT.ApplyPullDisplay()
    else
        DTT.RefreshBar()
    end
end

function DTT.InitializeGroupSettings()
    category, layout = ns.HomeCategory()
    if not category then
        return
    end
    -- Four sections, then Tank Tools (John, 2026-11-12: "Group warnings has
    -- everything all mixed up; a kitchen sink of settings."). The threat
    -- view sets the labels of both kinds and the sounds: first.
    -- Each feature section starts with its own Enable, on by default (John,
    -- 2026-11-15: "first option under 'Threat Indicators: Nameplates' should
    -- be an enable check-box, on by default"). The two label switches keep
    -- their saved keys.
    Section("Threat Indicators: Nameplates")
    Checkbox("DYRE_PLATE_THREAT", "Enable", "plateThreat", true,
        "Shows the threat icon and your threat percent beside enemy nameplates.",
        DTT.RefreshThreat)
    Dropdown("DYRE_THREAT_MODE", "Threat view", "threatMode", DTT.THREAT_MODES, MODE_LABELS,
        "Auto uses the tank view (shield) while you tank and the DPS/Healer view (crossed swords) at other times.",
        DTT.RefreshThreat)
    Dropdown("DYRE_PLATE_PLACE", "Place on nameplates", "platePlace", DTT.PLATE_PLACES, PLACE_LABELS,
        "Where the threat label sits beside a nameplate's health bar.", DTT.RefreshThreat)
    OffsetSlider("DYRE_PLATE_X", "Nameplate label: left/right", "plateX",
        "Moves the nameplate threat label left or right, in pixels.")
    OffsetSlider("DYRE_PLATE_Y", "Nameplate label: up/down", "plateY",
        "Moves the nameplate threat label up or down, in pixels.")
    ScaleSlider("DYRE_PLATE_SCALE", "Nameplate label size", "plateScale",
        "Sets the size of the nameplate threat label.")
    Section("Threat Indicators: Target Frame")
    Checkbox("DYRE_TARGET_THREAT", "Enable", "targetThreat", true,
        "Shows the threat label above your target frame's health bar.", DTT.RefreshThreat)
    OffsetSlider("DYRE_TARGET_X", "Target label: left/right", "targetX",
        "Moves the target frame's threat label left or right, in pixels.")
    OffsetSlider("DYRE_TARGET_Y", "Target label: up/down", "targetY",
        "Moves the target frame's threat label up or down, in pixels.")
    ScaleSlider("DYRE_TARGET_SCALE", "Target label size", "targetScale",
        "Sets the size of the target frame's threat label.")
    Section("Threat Indicators: Sounds")
    Checkbox("DYRE_THREAT_SOUNDS", "Enable", "threatSounds", true,
        "Plays a sound when a threat label turns red or orange.", function() end)
    SoundDropdown("DYRE_RED_SOUND", "Alert sound (red)", "redSound", DTT.DEFAULT_RED_SOUND, "Aggro",
        "The sound when a threat label turns red.")
    SoundDropdown("DYRE_LOSING_SOUND", "Warning sound (orange)", "losingSound", DTT.DEFAULT_LOSING_SOUND,
        "Losing",
        "The sound when a threat label turns orange.")
    Checkbox("DYRE_SOLO_SOUNDS", "Threat sounds when solo", "soloSounds", false,
        "Plays the threat sounds also when you are not in a group.", function() end)
    Section("Group Warnings")
    Checkbox("DYRE_GROUP_WARNINGS", "Enable", "groupWarnings", true,
        "Turns the pull bars, Dyre's countdown, and the pet taunt warning on or off together.", function()
            DTT.RefreshThreat()
            DTT.ApplyPullDisplay()
            DTT.CheckPetTaunt()
        end)
    Checkbox("DYRE_PULL_BARS", "Pull bars under nameplates", "pullBars", true,
        "Shows a thin threat bar for each party member under enemy nameplates while you tank in a party.",
        DTT.RefreshThreat)
    -- Only Dyre's own display; sending has no setting (John,
    -- 2026-11-11, read the old "Auto" as the send path).
    Checkbox("DYRE_PULL_DISPLAY", "Dyre's countdown on screen", "pullDisplay", true,
        "Shows Dyre's big pull countdown on screen when no boss mod shows one.", DTT.ApplyPullDisplay)
    SoundDropdown("DYRE_PULL_TICK", "Countdown tick sound", "pullTick", DTT.DEFAULT_PULL_TICK, "5",
        "The sound on each of the last 5 seconds of Dyre's countdown.")
    SoundDropdown("DYRE_PULL_GO", "Countdown go sound", "pullGo", DTT.DEFAULT_PULL_GO, "Pull",
        "The sound at the end of Dyre's countdown.")
    local widget = DTT.PullDisplayWidget and DTT.PullDisplayWidget()
    if widget then
        ns.toolkit.AddWidgetSettings(category, layout, widget, {
            labels = {scale = "Countdown size (%)", opacity = "Countdown opacity (%)"}})
    end
    Checkbox("DYRE_PET_TAUNT", "Warn: pet taunt on in a group", "petTaunt", true,
        "Warns you when your pet's taunt is on autocast in a group where you are not the tank.",
        DTT.CheckPetTaunt)

    Section("Tank Tools")
    Checkbox("DYRE_TANK_TOOLS", "Enable", "tankTools", true,
        "Shows the tank button bar.", DTT.RefreshBar)
    Dropdown("DYRE_TANK_BAR_MODE", "Tank button bar", "barMode", DTT.BAR_MODES, BAR_LABELS,
        "Auto shows the tank button bar only while you tank, and Always and Never force it.", DTT.RefreshBar)
    Slider("DYRE_PULL", "Pull countdown (seconds)", "pull", DTT.PULL_MIN, DTT.PULL_MAX, DTT.DEFAULT_PULL, "%d s",
        DTT.SanitizePull,
        "The length of the PULL button's countdown.")

    -- The swing timer and range box (Swing.lua).
    if ns.AddSwingSettings then
        ns.AddSwingSettings(category, layout)
    end

    -- The profile (copy, export, import) stays on Dyre's Toolkit's own page:
    -- DCT's settings are one part of it (Tank.lua).
end
