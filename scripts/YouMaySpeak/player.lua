---@omw-context player
local I = require("openmw.interfaces")
local types = require("openmw.types")

local lookingAt = nil

I.SharedRay.subscribe("YouMaySpeak", function(result)
	local object = result.hitObject

	if lookingAt then
		if lookingAt == object then
			return
		end
		lookingAt:sendEvent("YMSMute")
		lookingAt = nil
	end

	if
		result.hit
		and object
		and types.NPC.objectIsInstance(object)
		and types.NPC.stats.ai.hello(object).base > 0
	then
		object:sendEvent("YMSUnmute")
		lookingAt = object

		print(
			object.recordId,
			types.NPC.stats.ai.hello(object).base,
			types.NPC.stats.ai.hello(object).modifier
		)
	end
end)
