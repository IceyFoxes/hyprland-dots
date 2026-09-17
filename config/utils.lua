local M = {}

M.lt = function(a, b) return a < b end
M.gt = function(a, b) return a > b end

local timeout = require("config.constants").timeout

local function get_active_tiled_workspace() return hl.get_active_special_workspace() or hl.get_active_workspace() end

-- Select an action at keypress time so each workspace can use its own layout.
function M.layout_binding(actions)
	return function()
		local workspace = get_active_tiled_workspace()
		if not workspace then
			hl.dispatch(hl.dsp.pass())
			return
		end

		local action = actions[workspace.tiled_layout] or actions.common
		if type(action) == "function" then
			action()
		elseif action then
			hl.dispatch(action)
		else
			hl.notification.create({
				text = "No action defined for layout: " .. workspace.tiled_layout,
				timeout = timeout.short,
			})
		end
	end
end

function M.toggle_tiled_layout()
	local workspace = get_active_tiled_workspace()
	if not workspace then return end

	local next_layout = workspace.tiled_layout == "scrolling" and "dwindle" or "scrolling"
	local selector = workspace.special and tostring(workspace.name) or tostring(workspace.id)
	hl.workspace_rule({ workspace = selector, layout = next_layout })
	hl.notification.create({ text = "Layout: " .. next_layout, timeout = timeout.short })
end

function M.window_x(win)
	local at = win.at
	return type(at) == "table" and (at.x or at[1]) or at
end
function M.window_y(win)
	local at = win.at
	return type(at) == "table" and (at.y or at[2]) or 0
end

local function window_size(win, axis)
	local size = win.size
	return type(size) == "table" and (size[axis] or size[axis == "x" and 1 or 2]) or size
end

function M.has_neighbor(axis, cmp)
	local workspace = get_active_tiled_workspace()
	local win = hl.get_active_window()
	if not workspace or not win then return false end

	local along = axis == "x" and M.window_x or M.window_y
	local across = axis == "x" and M.window_y or M.window_x
	local cross_axis = axis == "x" and "y" or "x"

	local position = along(win)
	local cross_start = across(win)
	local cross_end = cross_start + window_size(win, cross_axis)
	for _, candidate in ipairs(workspace:get_windows()) do
		if candidate.address ~= win.address and cmp(along(candidate), position) then
			local candidate_start = across(candidate)
			local candidate_end = candidate_start + window_size(candidate, cross_axis)
			-- A neighbor must overlap perpendicular to the movement direction.
			if candidate_start < cross_end and candidate_end > cross_start then return true end
		end
	end
	return false
end

function M.has_any_neighbor(axis) return M.has_neighbor(axis, M.lt) or M.has_neighbor(axis, M.gt) end

-- Return a keypress-time action dispatching `primary` when a neighbor exists
-- in the given direction, otherwise `fallback`.
function M.if_neighbor(axis, cmp, primary, fallback)
	return function()
		if M.has_neighbor(axis, cmp) then
			hl.dispatch(primary)
		else
			hl.dispatch(fallback)
		end
	end
end

function M.if_any_neighbor(axis, primary, fallback)
	return function()
		if M.has_any_neighbor(axis) then
			hl.dispatch(primary)
		else
			hl.dispatch(fallback)
		end
	end
end

-- Placeholder ID used to rotate two workspaces without collision.
-- Staged with small delays so Hyprland processes each rename in order.
local SWAP_PLACEHOLDER_ID = 99

function M.swap_workspaces(curr_id, target_id)
	if not curr_id or not target_id then return end
	hl.timer(
		function() hl.dispatch(hl.dsp.workspace.change_id({ workspace = target_id, id = SWAP_PLACEHOLDER_ID })) end,
		{ timeout = 1, type = "oneshot" }
	)
	hl.timer(
		function() hl.dispatch(hl.dsp.workspace.change_id({ workspace = curr_id, id = target_id })) end,
		{ timeout = 10, type = "oneshot" }
	)
	hl.timer(
		function()
			hl.dispatch(hl.dsp.workspace.change_id({ workspace = SWAP_PLACEHOLDER_ID, id = curr_id }))
		end,
		{ timeout = 20, type = "oneshot" }
	)
end

function M.organize_workspaces()
	local monitors = {}
	local monitor_names = {}
	local max_id = 0

	for _, ws in ipairs(hl.get_workspaces()) do
		if ws.id >= 1 and ws.monitor then
			local monitor_name = ws.monitor.name
			local workspace_ids = monitors[monitor_name]
			if not workspace_ids then
				workspace_ids = {}
				monitors[monitor_name] = workspace_ids
				table.insert(monitor_names, monitor_name)
			end
			table.insert(workspace_ids, ws.id)
			max_id = math.max(max_id, ws.id)
		end
	end

	table.sort(monitor_names)
	local workspace_ids = {}
	for _, monitor_name in ipairs(monitor_names) do
		table.sort(monitors[monitor_name])
		for _, workspace_id in ipairs(monitors[monitor_name]) do
			table.insert(workspace_ids, workspace_id)
		end
	end

	local first_temporary_id = max_id + 1
	for index, workspace_id in ipairs(workspace_ids) do
		hl.dispatch(hl.dsp.workspace.change_id({ workspace = workspace_id, id = first_temporary_id + index - 1 }))
	end
	for index = 1, #workspace_ids do
		hl.dispatch(hl.dsp.workspace.change_id({ workspace = first_temporary_id + index - 1, id = index }))
	end
end

return M
