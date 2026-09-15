--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

-- local suppressMaximizeRule = hl.window_rule({
-- 	-- Ignore maximize requests from all apps. You'll probably like this.
-- 	name = "suppress-maximize-events",
-- 	match = { class = ".*" },
--
-- 	suppress_event = "maximize",
-- })
-- suppressMaximizeRule:set_enabled(false)

hl.workspace_rule({
	workspace = "s[true]",
	layout = "dwindle",
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
-- 	name = "no-anim-overlay",
-- 	match = { namespace = "^my-overlay$" },
-- 	no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

hl.layer_rule({
	name = "noctalia",
	match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$" },
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

hl.layer_rule({
	name = "hide-notifications",
	match = { namespace = "noctalia-notification$" },
	no_screen_share = true,
})

hl.window_rule({
	match = { initial_title = "Noctalia Settings" },
	no_screen_share = true,
	workspace = "current",
})

hl.window_rule({
	match = { class = "org.mozilla.Thunderbird", initial_title = "negative:.*Mozilla Thunderbird|Write.*" },
	float = true,
	workspace = "current",
})

hl.window_rule({
	match = { title = "Picture-in-Picture" },
	float = true,
	size = { "(monitor_w*0.3)", "(monitor_h*0.3)" },
})

hl.window_rule({
	match = { initial_class = "com.mitchellh.ghostty" },
	workspace = "current",
})

hl.window_rule({
	match = {
		class = "org.telegram.desktop",
		title = "Media viewer",
	},
	float = true,
	workspace = "current",
	fullscreen = true,
})

hl.window_rule({
	match = { class = "org.telegram.desktop", title = "Choose Files" },
	float = true,
})

hl.window_rule({
	match = { initial_class = "^brave-web[.]whatsapp[.]com__-Default$" },
	workspace = "special:magic",
})

-- zoom
hl.window_rule({
	match = { class = "Zoom" },
	no_blur = true,
})

hl.window_rule({
	match = { class = "Zoom", initial_title = "negative:Zoom Workplace|Zoom Workplace - .*|Meeting" },
	float = true,
})

-- hl.window_rule({
-- 	match = { class = "Zoom", title = "Meeting" },
-- 	fullscreen_state = "1 3",
-- 	workspace = "emptynm",
-- })

hl.window_rule({
	match = { class = "Zoom", title = "zoom_linux_float_video_window" },
	float = true,
	pin = true,
	move = { "monitor_w * 0.8", "monitor_h * 0.2" },
})

-- onlyoffice
hl.window_rule({
	match = { class = "DesktopEditors" },
	center = true,
})

-- libreoffice
hl.window_rule({
	match = { class = "libreoffice-impress" },
	scrolling_width = 1,
})

hl.window_rule({
	match = { class = "libreoffice-impress", title = "Console:.*" },
	suppress_event = "activate activatefocus",
})

hl.window_rule({
	match = { class = "libreoffice-impress", title = "Presenting: .*" },
	scrolling_width = 0.75,
	fullscreen_state = "0 3",
})

hl.window_rule({
	match = { class = "com.github.xournalpp.xournalpp" },
	workspace = "current",
})
--
-- hl.on("window.active", function()
-- 	local prev_win = hl.get_last_window()
--
-- 	if prev_win and prev_win.fullscreen >= 2 and prev_win.fullscreen_client == 0 then
-- 		hl.dispatch(hl.dsp.window.fullscreen({
-- 			window = prev_win,
-- 			action = "unset",
-- 			mode = "fullscreen",
-- 		}))
-- 	end
-- end)
