-- little hack to get the current interactable name
local lastInteractableName
ZO_PreHook(FISHING_MANAGER, "StartInteraction", function()
    local _, name = GetGameCameraInteractableActionInfo()
    lastInteractableName = name
end)

-- zones for usage
local zones = {
    [821] = true, -- Thieves Den
    [826] = true, -- Dark Brotherhood Sanctuary
}

-- localized names of the quest givers
local questGiver = {
    ["Tip Board"] = true,
    ["Marked for Death"] = true,
}

-- first few characters of the quest dialogs
local dialogTG = {
    ["ors that"] = true, -- Crime Spree
    ["eemed th"] = true, -- The Covetous Countess
}
local dialogTGF = {
    ["The Thalmor"] = false, -- The Covetous Countess
}
local dialog = { -- clean this out to only hold positives
    ["'d think"] = false,
    [" Queen h"] = false,
    ["re's a b"] = false,
    ["en Ayren"] = false,
    ["as passi"] = false,
    ["re is a "] = false,
    ["annot ab"] = false,
    [" Spinner"] = false,
    ["e and Jo"] = false,
    ["g Aerada"] = false,
    [" don't t"] = false,
    ["re's a t"] = false,
    ["spouse b"] = false,
    ["more Tha"] = false,
    ["ry day I"] = false,
    [" of the "] = false,
    ["e fool k"] = false,
    ["kwasten "] = false,
    ["ave a cu"] = false,
    ["s one se"] = false,
    ["en-ja is"] = false,
    ["dbeats. "] = false,
    ["ls of Ju"] = false,
    ["re are s"] = false,
    ["ave been"] = false,
    [" Stone O"] = false,
    [" cheerin"] = false,
    [" at peak"] = false,
    ["e been d"] = false,
    ["m positi"] = false,
    ["py hides"] = false,
    ["an't tol"] = false,
    [" being m"] = false,
    ["oward hi"] = false,
    ["prey has"] = false,
    ["se Dorel"] = false,
    ["advancem"] = false,
    ["t the be"] = false,
    ["se who s"] = false,
    ["ealous b"] = false,
    ["agitator"] = false,
    ["re's an "] = false,
    ["m forced"] = false,
    [" seeds o"] = false,
    ["eek to g"] = false,
    ["elers ma"] = false,
    ["kin dish"] = false,
    [" careles"] = false,
    ["lorious "] = false,
    ["rect the"] = false,
    ["eally ca"] = false,
    ["people m"] = false,
    ["lover—fo"] = false,
    ["losed ar"] = false,
    ["re is a "] = false,
    ["rine dut"] = false,
    ["n the Da"] = false,
    [" losing "] = false,
    ["d slaugh"] = false,
    [" milk-dr"] = false,
    [" suspici"] = false,
}

-- allow debugging based on changes
local DebuggerLog = {}
local function Debugger(key, output)
    if not DebuggerLog[key] or output ~= DebuggerLog[key] then
        DebuggerLog[key] = output
        CHAT_SYSTEM:AddMessage(key .. ": " .. output)
    end
end

-- override the chatter option function, so only the filtered quests can be started
local function OverwritePopulateChatterOption(interaction)
    local PopulateChatterOption = interaction.PopulateChatterOption
    interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
        -- check if the current target is a filtered quest giver
        if not questGiver[lastInteractableName] then
            PopulateChatterOption(self, index, fun, txt, type, ...)
            return
        end
        -- the player has to be on the TG map
        if not zones[GetZoneId(GetUnitZoneIndex("player"))] then
            return PopulateChatterOption(self, index, fun, txt, type, ...)
        end
        -- check if the current dialog starts the Thieves Guild Spree Contract
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
        --lastInteractableName = nil -- set this variable to nil, so the next dialog step isn't manipulated
    end
end

OverwritePopulateChatterOption(GAMEPAD_INTERACTION)
OverwritePopulateChatterOption(INTERACTION) -- keyboard
