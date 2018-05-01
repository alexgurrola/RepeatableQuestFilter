--------------
-- Settings --
--------------

RepeatableQuestFilter.version = 1
RepeatableQuestFilter.default = {
    EnabledTG = true,
    EnabledDB = true,
    CrimeSpree = true,
    Launder = true,
    KillSpreeGC = true,
    KillSpreeAD = true,
    KillSpreeDC = true,
    KillSpreeEP = true,
}

---------------
-- Libraries --
---------------

local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

-----------
-- Tools --
-----------

-- allow debugging based on changes
local DebuggerLog = {}
local function Debugger(key, output)
    if not DebuggerLog[key] or output ~= DebuggerLog[key] then
        DebuggerLog[key] = output
        CHAT_SYSTEM:AddMessage(key .. ": " .. output)
    end
end

-----------
-- Hooks --
-----------

local lastInteractableName
ZO_PreHook(FISHING_MANAGER, "StartInteraction", function()
    local _, name = GetGameCameraInteractableActionInfo()
    lastInteractableName = name
end)

----------
-- Data --
----------

-- zones for usage
local zones = {
    [821] = RepeatableQuestFilter.savedVars.EnabledTG, -- Thieves Den
    [826] = RepeatableQuestFilter.savedVars.EnabledDB, -- Dark Brotherhood Sanctuary
}

-- localized names of the quest givers
local questGiver = {
    ["Tip Board"] = RepeatableQuestFilter.savedVars.EnabledTG, -- Thieves Den
    ["Marked for Death"] = RepeatableQuestFilter.savedVars.EnabledDB, -- Dark Brotherhood Sanctuary
}

-- first few characters of the quest dialogs
local dialog = {
    ["Rumors that"] = RepeatableQuestFilter.savedVars.CrimeSpree, -- Any Crime Spree
    ["Esteemed th"] = RepeatableQuestFilter.savedVars.Launder, -- The Covetous Countess
    ["Demand for "] = RepeatableQuestFilter.savedVars.KillSpreeGC, -- Gold Coast
    ["The Thalmor"] = RepeatableQuestFilter.savedVars.KillSpreeAD, -- Auridon
    ["Back to the"] = RepeatableQuestFilter.savedVars.KillSpreeAD, -- Grahtwood
    ["The damn El"] = RepeatableQuestFilter.savedVars.KillSpreeAD, -- Greenshade
    ["Malabal Tor"] = RepeatableQuestFilter.savedVars.KillSpreeAD, -- Malabal Tor
    ["This one do"] = RepeatableQuestFilter.savedVars.KillSpreeAD, -- Reaper's March
    ["The Redguar"] = RepeatableQuestFilter.savedVars.KillSpreeDC, -- Alik'r Desert
    ["Strained re"] = RepeatableQuestFilter.savedVars.KillSpreeDC, -- Bangkorai
    ["Trade is th"] = RepeatableQuestFilter.savedVars.KillSpreeDC, -- Glenumbra
    ["The Covenan"] = RepeatableQuestFilter.savedVars.KillSpreeDC, -- Rivenspire
    ["Smuggling i"] = RepeatableQuestFilter.savedVars.KillSpreeDC, -- Stormhaven
    ["Never forgi"] = RepeatableQuestFilter.savedVars.KillSpreeEP, -- Deshaan
    ["The Thanes "] = RepeatableQuestFilter.savedVars.KillSpreeEP, -- Eastmarch
    ["The Ebonhea"] = RepeatableQuestFilter.savedVars.KillSpreeEP, -- Shadowfen
    ["Brothers an"] = RepeatableQuestFilter.savedVars.KillSpreeEP, -- Stonefalls
    ["My exile le"] = RepeatableQuestFilter.savedVars.KillSpreeEP, -- The Rift
}

--------------------
-- Menu Functions --
--------------------

function RepeatableQuestFilter.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Repeatable Quest Filter",
        displayName = "Repeatable Quest Filter..",
        author = "Positron",
        version = RepeatableQuestFilter.version,
        slashCommand = "/repeatable",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local cntrlOptionsPanel = LAM2:RegisterAddonPanel("RepeatableQuestFilter", panelData)

    local optionsData = {
        [1] = {
            type = "header",
            name = "Repeatable Quest Filter Settings"
        },
        [2] = {
            type = "description",
            text = "Enable focused farming or leveling by filtering repeatable quests."
        },
        [3] = {
            type = "checkbox",
            name = "Thieves Guild Quests",
            tooltip = "Turn this off if you want to allow all Thieves Guild Quests through.",
            default = true,
            getFunc = function()
                return RepeatableQuestFilter.savedVars.EnabledTG
            end,
            setFunc = function(newValue)
                RepeatableQuestFilter.savedVars.EnabledTG = newValue
            end,
        },
        [4] = {
            type = "checkbox",
            name = "Dark Brotherhood Quests",
            tooltip = "Turn this off if you want to allow all Dark Brotherhood Quests through.",
            default = true,
            getFunc = function()
                return RepeatableQuestFilter.savedVars.EnabledDB
            end,
            setFunc = function(newValue)
                RepeatableQuestFilter.savedVars.EnabledDB = newValue
            end,
        },
        [5] = {
            type = "checkbox",
            name = "Thieves Guild Crime Spree",
            tooltip = "Turn this on if you want to allow Thieves Guild Crime Sprees through.",
            default = true,
            getFunc = function()
                return RepeatableQuestFilter.savedVars.CrimeSpree
            end,
            setFunc = function(newValue)
                RepeatableQuestFilter.savedVars.CrimeSpree = newValue
            end,
        },
        [6] = {
            type = "checkbox",
            name = "Thieves Guild Laundering",
            tooltip = "Turn this on if you want to allow The Covetous Countess through.",
            default = true,
            getFunc = function()
                return RepeatableQuestFilter.savedVars.Launder
            end,
            setFunc = function(newValue)
                RepeatableQuestFilter.savedVars.Launder = newValue
            end,
        },
        [7] = {
            type = "checkbox",
            name = "Gold Coast Kill Sprees",
            tooltip = "Turn this on if you want to allow Gold Coast Kill Sprees through.",
            default = true,
            getFunc = function()
                return RepeatableQuestFilter.savedVars.KillSpreeGC
            end,
            setFunc = function(newValue)
                RepeatableQuestFilter.savedVars.KillSpreeGC = newValue
            end,
        },
        [8] = {
            type = "checkbox",
            name = "Aldmeri Dominion Kill Sprees",
            tooltip = "Turn this on if you want to allow Aldmeri Dominion Kill Sprees through.",
            default = true,
            getFunc = function()
                return RepeatableQuestFilter.savedVars.KillSpreeAD
            end,
            setFunc = function(newValue)
                RepeatableQuestFilter.savedVars.KillSpreeAD = newValue
            end,
        },
        [9] = {
            type = "checkbox",
            name = "Daggerfall Covenant Kill Sprees",
            tooltip = "Turn this on if you want to allow Daggerfall Covenant Kill Sprees through.",
            default = true,
            getFunc = function()
                return RepeatableQuestFilter.savedVars.KillSpreeDC
            end,
            setFunc = function(newValue)
                RepeatableQuestFilter.savedVars.KillSpreeDC = newValue
            end,
        },
        [10] = {
            type = "checkbox",
            name = "Ebonheart Pact Kill Sprees",
            tooltip = "Turn this on if you want to allow Ebonheart Pact Kill Sprees through.",
            default = true,
            getFunc = function()
                return RepeatableQuestFilter.savedVars.KillSpreeEP
            end,
            setFunc = function(newValue)
                RepeatableQuestFilter.savedVars.KillSpreeEP = newValue
            end,
        },
    }
    LAM2:RegisterOptionControls("RepeatableQuestFilter", optionsData)
end

function RepeatableQuestFilter:Initialize()
    RepeatableQuestFilter.savedVars = ZO_SavedVars:New("RepeatableQuestFilterVars", RepeatableQuestFilter.version, nil, RepeatableQuestFilter.default)
    RepeatableQuestFilter.CreateSettingsWindow()
end

------------------------
-- Core Functionality --
------------------------

-- override the chatter option function, so only the filtered quests can be started
local function OverwritePopulateChatterOption(interaction)
    local PopulateChatterOption = interaction.PopulateChatterOption
    interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
        -- check if the current target is a filtered quest giver
        if not questGiver[lastInteractableName] then
            PopulateChatterOption(self, index, fun, txt, type, ...)
            return
        end
        -- the player has to be on an enabled map
        if not zones[GetZoneId(GetUnitZoneIndex("player"))] then
            return PopulateChatterOption(self, index, fun, txt, type, ...)
        end
        -- check if the current dialog starts an enabled quest
        local offerText = GetOfferedQuestInfo()
        Debugger('offer', offerText)
        Debugger('identifier', string.sub(offerText, 2, 12))
        if not dialog[string.sub(offerText, 5, 12)] then
            -- if it is a different quest, only display the goodbye option
            if type ~= CHATTER_GOODBYE then
                return
            end
            PopulateChatterOption(self, 1, fun, txt, type, ...)
            return
        end
        PopulateChatterOption(self, index, fun, txt, type, ...)
        lastInteractableName = nil -- set this variable to nil, so the next dialog step isn't manipulated
    end
end

OverwritePopulateChatterOption(GAMEPAD_INTERACTION)
OverwritePopulateChatterOption(INTERACTION) -- keyboard
