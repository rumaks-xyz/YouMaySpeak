---@omw-context local
local self = require("openmw.self")
local types = require("openmw.types")

if types.Actor.isDead(self) then
	return
end

local storage = require("openmw.storage")

local hello = types.Actor.stats.ai.hello(self)
local helloThreshold = storage.globalSection("SettingsYouMaySpeak"):get("helloThreshold")
if hello.base == 0 or hello.base > helloThreshold then
	return
end

local applied = true

local function apply()
	-- at 0 hello value, NPCs won't say idle dialogue, therefore we'll set it to 1.
	hello.modifier = -hello.base + 1
	applied = true
end

local function unapply()
	hello.modifier = 0
	applied = false
end

apply()

local I = require("openmw.interfaces")

-- lazy fix for a minor incompatibility with tamriel rebuilt's Distract spell.
-- will only work on OpenMW 0.52+
if I.SpellCasting then
	I.SpellCasting.addApplyMagicEffectsHandler(function()
		if applied then
			apply()
		end
	end)
end

return {
	engineHandlers = {
		-- this should avoid any permanent effects on the save file
		onInactive = unapply,
		onSave = function()
			if applied then
				unapply()
				self:sendEvent("YMSApply")
			end
		end,
	},
	eventHandlers = {
		YMSApply = apply,
		YMSUnapply = unapply,
	},
}
