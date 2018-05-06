--------------------------
-- Initialize Variables --
--------------------------

RepeatableQuestFilter = {}
RepeatableQuestFilter.name = "RepeatableQuestFilter"
RepeatableQuestFilter.configVersion = 3
RepeatableQuestFilter.controls = {
    KillSpree = {
        AldmeriDominion = {},
        DaggerfallCovenant = {},
        EbonheartPact = {},
    }
}
RepeatableQuestFilter.defaults = {
    ThievesGuild = true,
    DarkBrotherhood = true,
    CrimeSpree = true,
    Launder = true,
    KillSpree = {
        -- Gold Coast
        GoldCoast = true,
        -- Aldmeri Dominion
        Auridon = true,
        Grahtwood = true,
        Greenshade = true,
        MalabalTor = true,
        ReapersMarch = true,
        -- Daggerfall Covenant
        AlikrDesert = true,
        Bangkorai = true,
        Glenumbra = true,
        Rivenspire = true,
        Stormhaven = true,
        -- Ebonheart Pact
        Deshaan = true,
        Eastmarch = true,
        Shadowfen = true,
        Stonefalls = true,
        TheRift = true,
    }
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
    self.saveData = ZO_SavedVars:New(self.name .. "Data", self.configVersion, nil, self.defaults)
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
        if (self.saveData[key] == nil) then
            self.saveData[key] = value
        end
    end
    --[[
    for key, value in pairs(self.defaults.KillSpree) do
        if (self.saveData.KillSpree[key] == nil) then
            self.saveData.KillSpree[key] = value
        end
    end
    ]]
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
        ["Rumors that"] = self.saveData.CrimeSpree, -- Crime Spree
        ["Esteemed th"] = self.saveData.Launder, -- The Covetous Countess
        -- Marked for Death
        ["Demand for "] = self.saveData.KillSpree.GoldCoast, -- Gold Coast
        -- Aldmeri Dominion
        ["The Thalmor"] = self.saveData.KillSpree.Auridon, -- Auridon
        ["Back to the"] = self.saveData.KillSpree.Grahtwood, -- Grahtwood
        ["The damn El"] = self.saveData.KillSpree.Greenshade, -- Greenshade
        ["Malabal Tor"] = self.saveData.KillSpree.MalabalTor, -- Malabal Tor
        ["This one do"] = self.saveData.KillSpree.ReapersMarch, -- Reaper's March
        -- Daggerfall Covenant
        ["The Redguar"] = self.saveData.KillSpree.AlikrDesert, -- Alik'r Desert
        ["Strained re"] = self.saveData.KillSpree.Bangkorai, -- Bangkorai
        ["Trade is th"] = self.saveData.KillSpree.Glenumbra, -- Glenumbra
        ["The Covenan"] = self.saveData.KillSpree.Rivenspire, -- Rivenspire
        ["Smuggling i"] = self.saveData.KillSpree.Stormhaven, -- Stormhaven
        -- Ebonheart Pact
        ["Never forgi"] = self.saveData.KillSpree.Deshaan, -- Deshaan
        ["The Thanes "] = self.saveData.KillSpree.Eastmarch, -- Eastmarch
        ["The Ebonhea"] = self.saveData.KillSpree.Shadowfen, -- Shadowfen
        ["Brothers an"] = self.saveData.KillSpree.Stonefalls, -- Stonefalls
        ["My exile le"] = self.saveData.KillSpree.TheRift, -- The Rift
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
        version = "1.2",
        website = "https://github.com/alexgurrola/RepeatableQuestFilter",
        slashCommand = "/questfilter",
        registerForDefaults = true,
    }
    -- local panel =
    LAM2:RegisterAddonPanel(self.name .. "Config", panelData)
    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Thieves Guild Settings"
    }
    --[[
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "Enable focused farming or leveling by filtering repeatable quests."
    }
    ]]
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Filters",
        tooltip = "Turn this off if you want to allow all Thieves Guild Quests through.",
        default = self.defaults.ThievesGuild,
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
        default = self.defaults.CrimeSpree,
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
        default = self.defaults.Launder,
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
        default = self.defaults.DarkBrotherhood,
        getFunc = function()
            return self.saveData.DarkBrotherhood
        end,
        setFunc = function(newValue)
            self.saveData.DarkBrotherhood = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Gold Coast Kill Spree",
        tooltip = "Turn this on if you want to allow Gold Coast Kill Sprees through.",
        default = self.defaults.KillSpree.GoldCoast,
        getFunc = function()
            return self.saveData.KillSpree.GoldCoast
        end,
        setFunc = function(newValue)
            self.saveData.KillSpree.GoldCoast = newValue
        end,
    }
    -- Aldmeri Dominion
    optionsData[#optionsData + 1] = {
        type = "submenu",
        name = "Aldmeri Dominion Kill Sprees",
        tooltip = "Decide which places you wish to have Kill Sprees available in the Aldmeri Dominion.",
        controls = self.controls.KillSpree.AldmeriDominion
    }
    self.controls.KillSpree.AldmeriDominion[#self.controls.KillSpree.AldmeriDominion + 1] = {
        type = "checkbox",
        name = "Auridon Kill Sprees",
        tooltip = "Turn this on if you want to allow Auridon Kill Sprees through.",
        default = self.defaults.KillSpree.Auridon,
        getFunc = function()
            return self.saveData.KillSpree.Auridon
        end,
        setFunc = function(newValue)
            self.saveData.KillSpree.Auridon = newValue
        end,
    }
    -- Daggerfall Covenant
    optionsData[#optionsData + 1] = {
        type = "submenu",
        name = "Daggerfall Covenant Kill Sprees",
        tooltip = "Decide which places you wish to have Kill Sprees available in the Daggerfall Covenant.",
        controls = self.controls.KillSpree.DaggerfallCovenant
    }
    self.controls.KillSpree.DaggerfallCovenant[#self.controls.KillSpree.DaggerfallCovenant + 1] = {
        type = "checkbox",
        name = "Alik'r Desert Kill Sprees",
        tooltip = "Turn this on if you want to allow Alik'r Desert Kill Sprees through.",
        default = self.defaults.KillSpree.AlikrDesert,
        getFunc = function()
            return self.saveData.KillSpree.AlikrDesert
        end,
        setFunc = function(newValue)
            self.saveData.KillSpree.AlikrDesert = newValue
        end,
    }
    -- Ebonheart Pact
    optionsData[#optionsData + 1] = {
        type = "submenu",
        name = "Ebonheart Pact Kill Sprees",
        tooltip = "Decide which places you wish to have Kill Sprees available in the Ebonheart Pact.",
        controls = self.controls.KillSpree.EbonheartPact
    }
    self.controls.KillSpree.EbonheartPact[#self.controls.KillSpree.EbonheartPact + 1] = {
        type = "checkbox",
        name = "Deshaan Kill Sprees",
        tooltip = "Turn this on if you want to allow Deshaan Kill Sprees through.",
        default = self.defaults.ThievesGuild,
        getFunc = function()
            return self.saveData.KillSpree.Deshaan
        end,
        setFunc = function(newValue)
            self.saveData.KillSpree.Deshaan = newValue
        end,
    }
    LAM2:RegisterOptionControls(self.name .. "Config", optionsData)
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
