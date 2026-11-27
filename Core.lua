local addonName, ns = ...

-- Dyre's Threat and Combat Tools (DCT, /dct): the threat labels and sounds,
-- pull bars, the tank bar (marks, pings, pull button), the pull countdown,
-- the Pet Taunt warning, and the swing timer with its range box. They were
-- part of Dyre's Toolkit (2.9.0 to 2.15.x). John, 2026-11-26, after
-- CurseForge comments that the Toolkit added too many warnings and sounds:
-- they move to their own AddOn, so the Toolkit is a quiet shared library
-- again. DCT is on for everyone who installs it; every part has its own
-- switch.
--
-- This file loads first. It decides once, as the files load, whether DCT runs
-- (ns.active); every other runtime file returns at its top when it does not,
-- so an inactive DCT makes no frames, registers no events and no commands,
-- and joins nothing:
--   * Dyre's Toolkit missing, or without the contract and functions DCT uses:
--     DCT stays off and says once at login to install Dyre's Toolkit.
--   * A Dyre's Toolkit that still has these features (a version before
--     TOOLKIT_WITHOUT_FEATURES, or its /dtt still registered): DCT stays
--     off and says nothing, so nothing shows, sounds, or binds twice. It
--     runs once the Toolkit no longer has them.
-- Then, at PLAYER_LOGIN: the settings (with the one-time copy from Dyre's
-- Toolkit, Tank.lua), the swing timer, and the threat and tank features.

ns.ADDON = addonName
ns.TITLE = "Dyre's Threat and Combat Tools"
ns.PREFIX = "DCT: "

-- The first Dyre's Toolkit release without the threat, tank, and swing
-- features (agreed with the Toolkit lead; docs/RELEASE_PLAN.md). Until then,
-- the Toolkit has them and DCT stays off.
ns.TOOLKIT_WITHOUT_FEATURES = "2.16.0"
-- The Toolkit's slash command key for /dtt while it had these features
-- (its Tank.lua). Present: the Toolkit still has them, whatever its version.
ns.TOOLKIT_TANK_SLASH = "DYRESTOOLKITTANK"
local TOOLKIT_ADDON = "DyresToolkit"
local TOOLKIT_CONTRACT = 2
-- Every Toolkit function DCT calls. A Toolkit without one is too old.
ns.TOOLKIT_FUNCTIONS = {"RegisterAddOn", "RegisterSettingsCategory", "OpenSettings", "IsLocked", "CreateWidget",
    "AddWidgetSettings", "ReapplyWidgets", "RegisterProfilePart", "AddDefaultTick", "OutOfCombat", "KnowsAny",
    "ClaimOwner", "IsOwner", "KindOwner", "OnOwnerChanged", "FindPlateBar", "FindUnitBar", "ClassSpells"}
ns.TOOLKIT_MISSING = "Dyre's Threat and Combat Tools needs Dyre's Toolkit " .. ns.TOOLKIT_WITHOUT_FEATURES
    .. " or later: install or update it from CurseForge. DCT stays off until then."

function ns.Report(message)
    DEFAULT_CHAT_FRAME:AddMessage(ns.PREFIX .. tostring(message))
end

local function Metadata(addon, field)
    if type(C_AddOns) ~= "table" or type(C_AddOns.GetAddOnMetadata) ~= "function" then
        return nil
    end
    local value = C_AddOns.GetAddOnMetadata(addon, field)
    if type(value) == "string" and value:find("%S") then
        return value
    end
end

-- "2.16.0" as {2, 16, 0}; nil for anything else (a development build's
-- placeholder, for one).
function ns.ParseVersion(text)
    if type(text) ~= "string" then
        return nil
    end
    local major, minor, patch = text:match("^%s*(%d+)%.(%d+)%.?(%d*)")
    if not major then
        return nil
    end
    return {tonumber(major), tonumber(minor), tonumber(patch) or 0}
end

-- Whether version text a is older than version text b; nil when either does
-- not read.
function ns.VersionBefore(a, b)
    local left, right = ns.ParseVersion(a), ns.ParseVersion(b)
    if not left or not right then
        return nil
    end
    for index = 1, 3 do
        if left[index] ~= right[index] then
            return left[index] < right[index]
        end
    end
    return false
end

-- Dyre's Toolkit with the contract and every function DCT uses, else nil.
function ns.FindToolkit()
    local toolkit = rawget(_G, "DyresToolkit")
    if type(toolkit) ~= "table" or type(toolkit.RequireContract) ~= "function" then
        return nil
    end
    local ok, api = pcall(toolkit.RequireContract, TOOLKIT_CONTRACT)
    if not ok or type(api) ~= "table" then
        return nil
    end
    for _, name in ipairs(ns.TOOLKIT_FUNCTIONS) do
        if type(api[name]) ~= "function" then
            return nil
        end
    end
    return api
end

-- Whether the loaded Dyre's Toolkit still has the threat, tank, and swing
-- features: its /dtt is registered, or its version is before the release
-- that removed them.
function ns.ToolkitHasFeatures()
    local slash = rawget(_G, "SlashCmdList")
    if type(slash) == "table" and slash[ns.TOOLKIT_TANK_SLASH] ~= nil then
        return true
    end
    return ns.VersionBefore(Metadata(TOOLKIT_ADDON, "Version"), ns.TOOLKIT_WITHOUT_FEATURES) == true
end

-- "active", "toolkit" (the Toolkit still has the features: off, quiet), or
-- "missing" (no usable Toolkit: off, one line at login).
function ns.Gate()
    local toolkit = ns.FindToolkit()
    if not toolkit then
        return "missing"
    end
    if ns.ToolkitHasFeatures() then
        return "toolkit"
    end
    return "active", toolkit
end

ns.state, ns.toolkit = ns.Gate()
ns.active = ns.state == "active"

-- The settings page under the Toolkit's "Dyre's AddOns" home (made once).
local category, layout
function ns.HomeCategory()
    if not category and ns.toolkit then
        category, layout = ns.toolkit.RegisterSettingsCategory(ns.TITLE)
    end
    return category, layout
end

function ns.AddDefaultTick(initializer, range)
    return ns.toolkit.AddDefaultTick(initializer, range)
end

function ns.IsUnlocked()
    return ns.toolkit.IsLocked() == false
end

-- Dyre's Toolkit 2.14.0's "Welcome messages at login" switch.
local function WelcomeOff()
    return type(ns.toolkit.ShowWelcome) == "function" and ns.toolkit.ShowWelcome() == false
end

local function ReportLoaded()
    if WelcomeOff() then
        return
    end
    local banner = Metadata(addonName, "Title") or ns.TITLE
    local version, author = Metadata(addonName, "Version"), Metadata(addonName, "Author")
    if version then
        banner = banner .. " " .. version
    end
    if author then
        banner = banner .. " by " .. author
    end
    ns.Report(banner .. ". /dct opens the settings.")
end

-- Key bindings: Dyre's Toolkit defines them for good (its Bindings.xml and,
-- from 2.16.0, Bindings.lua with the header "Dyre's Threat and Combat Tools"
-- and the binding names; John, 2026-11-26, "B now, service later"). A second
-- Bindings.xml with the same names gave the client nine LUA_WARNING lines at
-- each load, so DCT ships none and writes no BINDING_ global. DCT only keeps
-- the button names those bindings click (TankButtons.lua).

if ns.state == "missing" then
    -- One line, once the chat frame is there.
    local events = CreateFrame("Frame")
    events:RegisterEvent("PLAYER_LOGIN")
    events:SetScript("OnEvent", function(self)
        self:UnregisterEvent("PLAYER_LOGIN")
        ns.Report(ns.TOOLKIT_MISSING)
    end)
elseif ns.active then
    local events = CreateFrame("Frame")
    events:RegisterEvent("PLAYER_LOGIN")
    events:SetScript("OnEvent", function(self)
        self:UnregisterEvent("PLAYER_LOGIN")
        ns.toolkit.RegisterAddOn({addon = addonName, title = ns.TITLE,
            openSettings = function() ns.toolkit.OpenSettings((ns.HomeCategory())) end})
        ReportLoaded()
        ns.InitializeTank()
    end)
end
