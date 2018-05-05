--------------------------
-- Initialize Variables --
--------------------------

RepeatableQuestFilter = {}
RepeatableQuestFilter.name = "RepeatableQuestFilter"
RepeatableQuestFilter.configVersion = 2
RepeatableQuestFilter.defaults = {
    ThievesGuild = true,
    DarkBrotherhood = true,
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

function OnAddOnLoaded(event, addonName)
    if addonName ~= RepeatableQuestFilter.name then
        return
    end
    RepeatableQuestFilter:Initialize(RepeatableQuestFilter)
end

--------------------------
--  Initialize Function --
--------------------------

function RepeatableQuestFilter:Initialize(self)
    self.saveData = ZO_SavedVars:New(self.name.."Data", self.configVersion, nil, self.defaults)
    self:RepairSaveData(self)
    self:CreateSettingsWindow(self)
    self:BuildFilters(self)
    self:OverwritePopulateChatterOption(self, GAMEPAD_INTERACTION)
    self:OverwritePopulateChatterOption(self, INTERACTION) -- keyboard
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end

---------------
-- Libraries --
---------------

local LAM2 = LibStub("LibAddonMenu-2.0")

--------------------
-- Internal Tools --
--------------------

-- allow debugging based on changes
RepeatableQuestFilter.debugLog = {}
function RepeatableQuestFilter:Debug(self, key, output)
    if output ~= self.debugLog[key] then
        self.debugLog[key] = output
        d(self.name .. "." .. key .. ":", output)
    end
end

function RepeatableQuestFilter:RepairSaveData(self)
    for key, value in pairs(self.defaults) do
        if(self.saveData[key] == nil) then
            self.saveData[key] = value
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

function RepeatableQuestFilter:BuildFilters(self)
    -- zones for usage
    self.filters.zones = {
        [821] = self.saveData.ThievesGuild, -- Thieves Den
        [826] = self.saveData.DarkBrotherhood, -- Dark Brotherhood Sanctuary
    }

    -- localized names of the quest givers
    self.filters.questGiver = {
        ["Tip Board"] = self.saveData.ThievesGuild, -- Thieves Den
        ["Marked for Death"] = self.saveData.DarkBrotherhood, -- Dark Brotherhood Sanctuary
    }

    -- first few characters of the quest dialogs
    self.filters.dialog = {
        -- Tip Board
        ["Some new fa"] = self.saveData.ThievesGuild, -- The Cutpurse's Craft (Required to get Dailies)
        ["Rumors that"] = self.saveData.CrimeSpree, -- Any Crime Spree
        ["Esteemed th"] = self.saveData.Launder, -- The Covetous Countess
        -- Marked for Death
        ["Demand for "] = self.saveData.KillSpreeGC, -- Gold Coast
        -- Aldmeri Dominion
        ["The Thalmor"] = self.saveData.KillSpreeAD, -- Auridon
        ["Back to the"] = self.saveData.KillSpreeAD, -- Grahtwood
        ["The damn El"] = self.saveData.KillSpreeAD, -- Greenshade
        ["Malabal Tor"] = self.saveData.KillSpreeAD, -- Malabal Tor
        ["This one do"] = self.saveData.KillSpreeAD, -- Reaper's March
        -- Daggerfall Covenant
        ["The Redguar"] = self.saveData.KillSpreeDC, -- Alik'r Desert
        ["Strained re"] = self.saveData.KillSpreeDC, -- Bangkorai
        ["Trade is th"] = self.saveData.KillSpreeDC, -- Glenumbra
        ["The Covenan"] = self.saveData.KillSpreeDC, -- Rivenspire
        ["Smuggling i"] = self.saveData.KillSpreeDC, -- Stormhaven
        -- Ebonheart Pact
        ["Never forgi"] = self.saveData.KillSpreeEP, -- Deshaan
        ["The Thanes "] = self.saveData.KillSpreeEP, -- Eastmarch
        ["The Ebonhea"] = self.saveData.KillSpreeEP, -- Shadowfen
        ["Brothers an"] = self.saveData.KillSpreeEP, -- Stonefalls
        ["My exile le"] = self.saveData.KillSpreeEP, -- The Rift
    }
end

--------------------
-- Menu Functions --
--------------------

function RepeatableQuestFilter:CreateSettingsWindow(self)
    local panelData = {
        type = "panel",
        name = "Quest Filter",
        displayName = "Repeatable Quest Filter",
        author = "Positron",
        version = "1.1",
        website = "https://github.com/alexgurrola/RepeatableQuestFilter",
        slashCommand = "/questfilter",
        registerForDefaults = true,
    }
    local panel = LAM2:RegisterAddonPanel(self.name.."Config", panelData)
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
            return self.saveData.ThievesGuild
        end,
        setFunc = function(newValue)
            self.saveData.ThievesGuild = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Crime Spree",
        tooltip = "Turn this on if you want to allow Thieves Guild Crime Sprees through.",
        getFunc = function()
            return self.saveData.CrimeSpree
        end,
        setFunc = function(newValue)
            self.saveData.CrimeSpree = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Laundering",
        tooltip = "Turn this on if you want to allow The Covetous Countess through.",
        getFunc = function()
            return self.saveData.Launder
        end,
        setFunc = function(newValue)
            self.saveData.Launder = newValue
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
            return self.saveData.DarkBrotherhood
        end,
        setFunc = function(newValue)
            self.saveData.DarkBrotherhood = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Gold Coast Kill Sprees",
        tooltip = "Turn this on if you want to allow Gold Coast Kill Sprees through.",
        getFunc = function()
            return self.saveData.KillSpreeGC
        end,
        setFunc = function(newValue)
            self.saveData.KillSpreeGC = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Aldmeri Dominion Kill Sprees",
        tooltip = "Turn this on if you want to allow Aldmeri Dominion Kill Sprees through.",
        getFunc = function()
            return self.saveData.KillSpreeAD
        end,
        setFunc = function(newValue)
            self.saveData.KillSpreeAD = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Daggerfall Covenant Kill Sprees",
        tooltip = "Turn this on if you want to allow Daggerfall Covenant Kill Sprees through.",
        getFunc = function()
            return self.saveData.KillSpreeDC
        end,
        setFunc = function(newValue)
            self.saveData.KillSpreeDC = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Ebonheart Pact Kill Sprees",
        tooltip = "Turn this on if you want to allow Ebonheart Pact Kill Sprees through.",
        getFunc = function()
            return self.saveData.KillSpreeEP
        end,
        setFunc = function(newValue)
            self.saveData.KillSpreeEP = newValue
        end,
    }
    LAM2:RegisterOptionControls(self.name.."Config", optionsData)
end

------------------------
-- Core Functionality --
------------------------

-- override the chatter option function, so only the filtered quests can be started
function RepeatableQuestFilter:OverwritePopulateChatterOption(self, interaction)
    local _self = self
    local PopulateChatterOption = interaction.PopulateChatterOption
    interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
        -- check if the current target is a filtered quest giver
        if not _self.filters.questGiver[lastInteractableName] then
            PopulateChatterOption(self, index, fun, txt, type, ...)
            return
        end
        -- the player has to be on an enabled map
        if not _self.filters.zones[GetZoneId(GetUnitZoneIndex("player"))] then
          PopulateChatterOption(self, index, fun, txt, type, ...)
          return
        end
        -- check if the current dialog starts an enabled quest
        local offerText = GetOfferedQuestInfo()
        if string.len(offerText) == 0 then
          PopulateChatterOption(self, index, fun, txt, type, ...)
          return
        end
        if not _self.filters.dialog[string.sub(offerText, 2, 12)] then
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

EVENT_MANAGER:RegisterForEvent(RepeatableQuestFilter.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
