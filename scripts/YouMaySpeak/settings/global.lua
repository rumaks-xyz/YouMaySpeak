---@omw-context global
local I = require("openmw.interfaces")

I.Settings.registerGroup({
	page = "YouMaySpeak",
	key = "SettingsYouMaySpeak",
	name = "settings_main",
	settings = {
		{
			key = "helloThreshold",
			name = "settings_hello_threshold",
			description = "settings_hello_threshold_desc",
			renderer = "number",
			default = 30,
		},
	},
	permanentStorage = true,
	l10n = "YouMaySpeak",
})
