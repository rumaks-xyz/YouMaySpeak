---@omw-context local
local async = require("openmw.async")
local self = require("openmw.self")
local storage = require("openmw.storage")
local types = require("openmw.types")

if types.Actor.isDead(self) then
	return
end

local hello = types.Actor.stats.ai.hello(self)
if not hello then
	return
end

local settingsSection = storage.globalSection("SettingsYouMaySpeak")

local helloThreshold = settingsSection:get("helloThreshold")
if hello.base <= 0 or hello.base > helloThreshold then
	return
end

local applied = false
local modifiedBy = 0
local enabled = settingsSection:get("enabled")

local function unapply()
	if applied then
		hello.modifier = hello.modifier - modifiedBy
		modifiedBy = 0
		applied = false
	end
end

local function apply()
	if not enabled then
		return
	end

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

local function setup()
	apply()

	settingsSection:subscribe(async:callback(function()
		enabled = settingsSection:get("enabled")
		if enabled then
			apply()
		else
			unapply()
		end
	end))
end

return {
	engineHandlers = {
		onInit = function()
			-- fix potentially broken NPCs from versions 1.0.0-1.0.2
			hello.modifier = 0

			setup()
		end,

		onLoad = function(data)
			if data and data.applied and data.modifiedBy then
				applied = data.applied
				modifiedBy = data.modifiedBy
			else
				hello.modifier = 0
			end

			setup()
		end,

		onInactive = unapply,

		onSave = function()
			return {
				applied = applied,
				modifiedBy = modifiedBy,
				version = 1,
			}
		end,
	},
	eventHandlers = {
		YMSApply = apply,
		YMSUnapply = unapply,
	},
}
