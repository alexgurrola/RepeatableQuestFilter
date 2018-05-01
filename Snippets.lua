-- Basic Debugging
local currentZone
if GetZoneId(GetUnitZoneIndex("player")) ~= currentZone then
	currentZone = GetZoneId(GetUnitZoneIndex("player"))
	CHAT_SYSTEM:AddMessage(currentZone)
end

local displayedInteractable
if lastInteractableName ~= displayedInteractable then
	displayedInteractable = lastInteractableName
	CHAT_SYSTEM:AddMessage(displayedInteractable)
end
