local lt = function(a, b) return a < b end
local gt = function(a, b) return a > b end

local function window_x(win)
	local at = win.at
	return type(at) == "table" and (at.x or at[1]) or at
end
local function window_y(win)
	local at = win.at
	return type(at) == "table" and (at.y or at[2]) or 0
end

local function has_neighbor(dir, cmp)
	local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
	local win = hl.get_active_window()
	if not ws or not win then return false end

	local extract, same
	if dir == "x" then
		extract = window_x
		same = window_y
	elseif dir == "y" then
		extract = window_y
		same = window_x
	end

	local pos = extract(win)
	local same_val = same and same(win)
	for _, w in ipairs(ws:get_windows()) do
		if w.address ~= win.address and cmp(extract(w), pos) then
			if not same or same(w) == same_val then return true end
		end
	end
end

local function swap_workspaces(curr_id, target_id)
	if not curr_id or not target_id then return end
	hl.timer(
		function() hl.dispatch(hl.dsp.workspace.change_id({ workspace = target_id, id = 99 })) end,
		{ timeout = 1, type = "oneshot" }
	)
	hl.timer(
		function() hl.dispatch(hl.dsp.workspace.change_id({ workspace = curr_id, id = target_id })) end,
		{ timeout = 10, type = "oneshot" }
	)
	hl.timer(
		function() hl.dispatch(hl.dsp.workspace.change_id({ workspace = 99, id = curr_id })) end,
		{ timeout = 20, type = "oneshot" }
	)
end

local function organize_workspaces()
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

return {
	window_x = window_x,
	window_y = window_y,
	lt = lt,
	gt = gt,
	has_neighbor = has_neighbor,
	swap_workspaces = swap_workspaces,
	organize_workspaces = organize_workspaces,
}
