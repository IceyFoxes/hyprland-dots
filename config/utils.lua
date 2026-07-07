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
	local ws, win = hl.get_active_workspace(), hl.get_active_window()
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

return {
	window_x = window_x,
	window_y = window_y,
	lt = lt,
	gt = gt,
	has_neighbor = has_neighbor,
}
