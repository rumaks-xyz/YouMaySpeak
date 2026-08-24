---@omw-context local
local self = require("openmw.self")
local types = require("openmw.types")

if types.Actor.isDead(self) then
	return
end

local hello = types.Actor.stats.ai.hello(self)
if not hello then
	return
end

local storage = require("openmw.storage")
local helloThreshold = storage.globalSection("SettingsYouMaySpeak"):get("helloThreshold")
if hello.base <= 0 or hello.base > helloThreshold then
	return
end

local applied = false
local modifiedBy = 0

local function unapply()
	if applied then
		hello.modifier = hello.modifier - modifiedBy
		modifiedBy = 0
		applied = false
	end
end

local function apply()
	-- unapply the old modifier in case the hello base changed since it was applied
	if applied then
		unapply()
	end

	-- for better compatibility with any mods that might be changing hello.base to 0
	-- (such as Unofficial Tamriel Rebuilt Spells)
	if hello.base <= 0 then
		return
	end

	-- at 0 hello value, NPCs won't say idle dialogue, therefore we'll set it to 1.
	modifiedBy = -hello.base + 1
	hello.modifier = hello.modifier + modifiedBy

	applied = true
end

apply()

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
