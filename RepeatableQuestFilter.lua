--------------------------
-- Initialize Variables --
--------------------------

RepeatableQuestFilter = {}
RepeatableQuestFilter.name = "RepeatableQuestFilter"
RepeatableQuestFilter.configVersion = 1
RepeatableQuestFilter.defaults = {
    EnabledTG = true,
    EnabledDB = true,
    CrimeSpree = true,
    Launder = true,
    KillSpreeGC = true,
    KillSpreeAD = true,
    KillSpreeDC = true,
    KillSpreeEP = true,
}
RepeatableQuestFilter.filters = {}

---------------------
--  OnAddOnLoaded  --
---------------------

function RepeatableQuestFilter.OnAddOnLoaded(event, addonName)
    if addonName ~= RepeatableQuestFilter.name then
        return
    end
    RepeatableQuestFilter.Initialize()
end

--------------------------
--  Initialize Function --
--------------------------

function RepeatableQuestFilter.Initialize()
    RepeatableQuestFilter.saveData = ZO_SavedVars:New(RepeatableQuestFilter.name.."Data", RepeatableQuestFilter.configVersion, nil, RepeatableQuestFilter.defaults)
    RepeatableQuestFilter.RepairSaveData()
    RepeatableQuestFilter.CreateSettingsWindow()
    RepeatableQuestFilter.BuildFilters()
    RepeatableQuestFilter.OverwritePopulateChatterOption(GAMEPAD_INTERACTION)
    RepeatableQuestFilter.OverwritePopulateChatterOption(INTERACTION) -- keyboard
    EVENT_MANAGER:UnregisterForEvent(RepeatableQuestFilter.name, EVENT_ADD_ON_LOADED)
end

---------------
-- Libraries --
---------------

local LAM2 = LibStub("LibAddonMenu-2.0")

--------------------
-- Internal Tools --
--------------------

-- allow debugging based on changes
RepeatableQuestFilter.DebuggerLog = {}
function RepeatableQuestFilter.Debugger(key, output)
    if output ~= RepeatableQuestFilter.DebuggerLog[key] then
        RepeatableQuestFilter.DebuggerLog[key] = output
        --CHAT_SYSTEM:AddMessage(key .. ": " .. output)
        d(RepeatableQuestFilter.name .. "." .. key .. ":", output)
    end
end

function RepeatableQuestFilter.RepairSaveData()
    for key, value in pairs(RepeatableQuestFilter.defaults) do
        if(RepeatableQuestFilter.saveData[key] == nil) then
            RepeatableQuestFilter.saveData[key] = value
        end
    end
end

------------------
-- System Hooks --
------------------

local lastInteractableName
ZO_PreHook(FISHING_MANAGER, "StartInteraction", function()
    local _, name = GetGameCameraInteractableActionInfo()
    lastInteractableName = name
end)

----------
-- Data --
----------

function RepeatableQuestFilter.BuildFilters()
    -- zones for usage
    RepeatableQuestFilter.filters.zones = {
        [821] = RepeatableQuestFilter.saveData.EnabledTG, -- Thieves Den
        [826] = RepeatableQuestFilter.saveData.EnabledDB, -- Dark Brotherhood Sanctuary
    }

    -- localized names of the quest givers
    RepeatableQuestFilter.filters.questGiver = {
        ["Tip Board"] = RepeatableQuestFilter.saveData.EnabledTG, -- Thieves Den
        ["Marked for Death"] = RepeatableQuestFilter.saveData.EnabledDB, -- Dark Brotherhood Sanctuary
    }

    -- first few characters of the quest dialogs
    RepeatableQuestFilter.filters.dialog = {
        ["Rumors that"] = RepeatableQuestFilter.saveData.CrimeSpree, -- Any Crime Spree
        ["Esteemed th"] = RepeatableQuestFilter.saveData.Launder, -- The Covetous Countess
        ["Demand for "] = RepeatableQuestFilter.saveData.KillSpreeGC, -- Gold Coast
        ["The Thalmor"] = RepeatableQuestFilter.saveData.KillSpreeAD, -- Auridon
        ["Back to the"] = RepeatableQuestFilter.saveData.KillSpreeAD, -- Grahtwood
        ["The damn El"] = RepeatableQuestFilter.saveData.KillSpreeAD, -- Greenshade
        ["Malabal Tor"] = RepeatableQuestFilter.saveData.KillSpreeAD, -- Malabal Tor
        ["This one do"] = RepeatableQuestFilter.saveData.KillSpreeAD, -- Reaper's March
        ["The Redguar"] = RepeatableQuestFilter.saveData.KillSpreeDC, -- Alik'r Desert
        ["Strained re"] = RepeatableQuestFilter.saveData.KillSpreeDC, -- Bangkorai
        ["Trade is th"] = RepeatableQuestFilter.saveData.KillSpreeDC, -- Glenumbra
        ["The Covenan"] = RepeatableQuestFilter.saveData.KillSpreeDC, -- Rivenspire
        ["Smuggling i"] = RepeatableQuestFilter.saveData.KillSpreeDC, -- Stormhaven
        ["Never forgi"] = RepeatableQuestFilter.saveData.KillSpreeEP, -- Deshaan
        ["The Thanes "] = RepeatableQuestFilter.saveData.KillSpreeEP, -- Eastmarch
        ["The Ebonhea"] = RepeatableQuestFilter.saveData.KillSpreeEP, -- Shadowfen
        ["Brothers an"] = RepeatableQuestFilter.saveData.KillSpreeEP, -- Stonefalls
        ["My exile le"] = RepeatableQuestFilter.saveData.KillSpreeEP, -- The Rift
    }
end

--------------------
-- Menu Functions --
--------------------

function RepeatableQuestFilter.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Quest Filter",
        displayName = "Repeatable Quest Filter",
        author = "Positron",
        version = "1.0",
        website = "https://github.com/alexgurrola/RepeatableQuestFilter",
        slashCommand = "/questfilter",
        registerForDefaults = true,
    }
    local panel = LAM2:RegisterAddonPanel(RepeatableQuestFilter.name.."Config", panelData)
    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Thieves Guild Settings"
    }
    --optionsData[#optionsData + 1] = {
    --    type = "description",
    --    text = "Enable focused farming or leveling by filtering repeatable quests."
    --}
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Filters",
        tooltip = "Turn this off if you want to allow all Thieves Guild Quests through.",
        getFunc = function()
            return RepeatableQuestFilter.saveData.EnabledTG
        end,
        setFunc = function(newValue)
            RepeatableQuestFilter.saveData.EnabledTG = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Crime Spree",
        tooltip = "Turn this on if you want to allow Thieves Guild Crime Sprees through.",
        getFunc = function()
            return RepeatableQuestFilter.saveData.CrimeSpree
        end,
        setFunc = function(newValue)
            RepeatableQuestFilter.saveData.CrimeSpree = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Laundering",
        tooltip = "Turn this on if you want to allow The Covetous Countess through.",
        getFunc = function()
            return RepeatableQuestFilter.saveData.Launder
        end,
        setFunc = function(newValue)
            RepeatableQuestFilter.saveData.Launder = newValue
        end,
    }
    -- Dark Brotherhood Options
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Dark Brotherhood Settings"
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Filters",
        tooltip = "Turn this off if you want to allow all Dark Brotherhood Quests through.",
        getFunc = function()
            return RepeatableQuestFilter.saveData.EnabledDB
        end,
        setFunc = function(newValue)
            RepeatableQuestFilter.saveData.EnabledDB = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Gold Coast Kill Sprees",
        tooltip = "Turn this on if you want to allow Gold Coast Kill Sprees through.",
        getFunc = function()
            return RepeatableQuestFilter.saveData.KillSpreeGC
        end,
        setFunc = function(newValue)
            RepeatableQuestFilter.saveData.KillSpreeGC = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Aldmeri Dominion Kill Sprees",
        tooltip = "Turn this on if you want to allow Aldmeri Dominion Kill Sprees through.",
        getFunc = function()
            return RepeatableQuestFilter.saveData.KillSpreeAD
        end,
        setFunc = function(newValue)
            RepeatableQuestFilter.saveData.KillSpreeAD = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Daggerfall Covenant Kill Sprees",
        tooltip = "Turn this on if you want to allow Daggerfall Covenant Kill Sprees through.",
        getFunc = function()
            return RepeatableQuestFilter.saveData.KillSpreeDC
        end,
        setFunc = function(newValue)
            RepeatableQuestFilter.saveData.KillSpreeDC = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Ebonheart Pact Kill Sprees",
        tooltip = "Turn this on if you want to allow Ebonheart Pact Kill Sprees through.",
        getFunc = function()
            return RepeatableQuestFilter.saveData.KillSpreeEP
        end,
        setFunc = function(newValue)
            RepeatableQuestFilter.saveData.KillSpreeEP = newValue
        end,
    }
    LAM2:RegisterOptionControls(RepeatableQuestFilter.name.."Config", optionsData)
end

------------------------
-- Core Functionality --
------------------------

-- override the chatter option function, so only the filtered quests can be started
function RepeatableQuestFilter.OverwritePopulateChatterOption(interaction)
    local PopulateChatterOption = interaction.PopulateChatterOption
    interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
        -- check if the current target is a filtered quest giver
        if not repeatableQuestFilter.filters.questGiver[lastInteractableName] then
            PopulateChatterOption(self, index, fun, txt, type, ...)
            return
        end
        -- the player has to be on an enabled map
        if not repeatableQuestFilter.filters.zones[GetZoneId(GetUnitZoneIndex("player"))] then
            return PopulateChatterOption(self, index, fun, txt, type, ...)
        end
        -- check if the current dialog starts an enabled quest
        local offerText = GetOfferedQuestInfo()
        if not repeatableQuestFilter.filters.dialog[string.sub(offerText, 5, 12)] then
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

----------------------
--  Register Events --
----------------------

EVENT_MANAGER:RegisterForEvent(RepeatableQuestFilter.name, EVENT_ADD_ON_LOADED, RepeatableQuestFilter.OnAddOnLoaded)
