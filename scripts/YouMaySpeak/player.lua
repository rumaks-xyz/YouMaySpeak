local I = require("openmw.interfaces")
local core = require("openmw.core")
local self = require("openmw.self")
local types = require("openmw.types")

local greetMult = core.getGMST("iGreetDistanceMultiplier")
local lookingAt = nil

I.SharedRay.subscribe("YouMaySpeak", function(result)
	local object = result.hitObject
	if lookingAt then
		if lookingAt == object then
			return
		end
		lookingAt:sendEvent("YMSApply")
		lookingAt = nil
	end
	if not (result.hit and object) then
		return
	end

	if object.type ~= types.NPC and object.type ~= types.Creature then
		return
	end

	-- for better 3rd person compatibility, distance is calculated from the player, not from the camera.
	if (object.position - self.position):length() > greetMult * types.Actor.stats.ai.hello(object).base then
		return
	end

	object:sendEvent("YMSUnapply")
	lookingAt = object
end)
