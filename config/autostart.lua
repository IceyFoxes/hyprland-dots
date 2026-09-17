-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
local start_cmds = {
	-- important stuff
	"systemctl --user set-environment XDG_SESSION_CLASS=user",
	"systemctl --user start --no-block hyprland-session.target",
	"noctalia",
	"XDG_MENU_PREFIX=arch- kbuildsycoca6",
	"gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
	"systemd-inhibit --what=handle-lid-switch --who='Hyprland' --why='Custom lid handling' --mode=block sleep infinity &",
	"hypridle",
	{ cmd = "Telegram", opts = { workspace = "special:magic" } },
	{ cmd = "thunderbird", opts = { workspace = "special:magic" } },
	"brave-origin-nightly --app=https://web.whatsapp.com",
	"gdbus wait --session org.kde.StatusNotifierWatcher && QT_QPA_PLATFORM=xcb synology-drive start",
	"hyprpm reload",
}

hl.on("hyprland.start", function()
	for _, item in ipairs(start_cmds) do
		if type(item) == "string" then
			hl.exec_cmd(item)
		else
			hl.exec_cmd(item.cmd, item.opts)
		end
	end
end)

hl.on("hyprland.shutdown", function()
	hl.exec_cmd("synology-drive stop")
end)
