-- little hack to get the current interactable name
local lastInteractableName
ZO_PreHook(FISHING_MANAGER, "StartInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

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
		CHAT_SYSTEM:AddMessage(offerText)
		CHAT_SYSTEM:AddMessage(string.sub(offerText,2,12))
		if dialog[string.sub(offerText,5,12)] then
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
