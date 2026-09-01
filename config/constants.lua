local terminal = "ghostty +new-window"
local fileManager = "nautilus"
local noctPrefix = "noctalia msg"
local menu = noctPrefix .. " panel-toggle launcher"
local browser = "brave-origin-nightly"
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

local timeout = {
	short = 1500,
	medium = 3000,
	long = 5000,
}

return {
	terminal = terminal,
	fileManager = fileManager,
	noctPrefix = noctPrefix,
	menu = menu,
	browser = browser,
	mainMod = mainMod,
	timeout = timeout,
}
