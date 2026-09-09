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
local settings = settingsSection:asTable()

local muted = false
local modifiedBy = 0

local function unmute()
	if muted then
		hello.modifier = hello.modifier - modifiedBy
		modifiedBy = 0
		muted = false
	end
end

local function mute()
	if not settings.enabled then
		return
	end

	unmute()

	if hello.base <= 0 or hello.base > settings.helloThreshold then
		return
	end

	-- at 0 hello value, NPCs won't say idle dialogue, so we'll set it to 1.
	modifiedBy = -hello.base + 1
	hello.modifier = hello.modifier + modifiedBy

	muted = true
end

settingsSection:subscribe(async:callback(function()
	settings = settingsSection:asTable()
	if settings.enabled and hello.base <= settings.helloThreshold then
		mute()
	else
		unmute()
	end
end))

return {
	engineHandlers = {
		onInit = mute,

		onLoad = function(data)
			if data then
				if data.version == 1 then
					-- `muted` used to be named `applied` prior to YMS 1.2.0
					data.muted = data.applied
				end

				muted = data.muted
				modifiedBy = data.modifiedBy
			else
				-- fix potentially broken NPCs from versions 1.0.0-1.0.2
				hello.modifier = 0
			end

			mute()
		end,

		onInactive = unmute,

		onSave = function()
			return {
				muted = muted,
				modifiedBy = modifiedBy,
				version = 2,
			}
		end,
	},
	eventHandlers = {
		YMSMute = mute,
		YMSUnmute = unmute,
	},
}
