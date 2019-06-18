local Config = require('config')
local UI     = require('ui')
local Util   = require('util')

local tab = UI.Tab {
	tabTitle = 'Path',
	description = 'Set the shell path',
	tabClose = true,
	entry = UI.TextEntry {
		x = 2, y = 2, ex = -2,
		limit = 256,
		shadowText = 'enter new path',
		accelerators = {
			enter = 'update_path',
		},
		help = 'add a new path',
	},
	grid = UI.Grid {
		y = 4, ey = -3,
		disableHeader = true,
		columns = { { key = 'value' } },
		autospace = true,
		sortColumn = 'index',
		help = 'double-click to remove, shift-arrow to move',
		accelerators = {
			delete = 'remove',
		},
	},
	statusBar = UI.StatusBar { },
	accelerators = {
		[ 'shift-up' ] = 'move_up',
		[ 'shift-down' ] = 'move_down',
	},
}

function tab:updateList(path)
	self.grid.values = { }
	for k,v in ipairs(Util.split(path, '(.-):')) do
		table.insert(self.grid.values, { index = k, value = v })
	end
	self.grid:update()
end

function tab:enable()
	local env = Config.load('shell')
	self:updateList(env.path)
	UI.Tab.enable(self)
end

function tab:save()
	local t = { }
	for _, v in ipairs(self.grid.values) do
		table.insert(t, v.value)
	end
	local env = Config.load('shell')
	env.path = table.concat(t, ':')
	self:updateList(env.path)
	Config.update('shell', env)
end

function tab:eventHandler(event)
	if event.type == 'update_path' then
		table.insert(self.grid.values, {
			value = self.entry.value,
		})
		self:save()
		self.entry:reset()
		self.entry:draw()
		self.grid:draw()
		return true

	elseif event.type == 'grid_select' or event.type == 'remove' then
		local selected = self.grid:getSelected()
		if selected then
			table.remove(self.grid.values, selected.index)
			self:save()
			self.grid:draw()
		end

	elseif event.type == 'focus_change' then
		self.statusBar:setStatus(event.focused.help)

	elseif event.type == 'move_up' then
		local entry = self.grid:getSelected()
		if entry.index > 1 then
			table.insert(self.grid.values, entry.index - 1, table.remove(self.grid.values, entry.index))
			self.grid:setIndex(entry.index - 1)
			self:save()
			self.grid:draw()
		end

	elseif event.type == 'move_down' then
		local entry = self.grid:getSelected()
		if entry.index < #self.grid.values then
			table.insert(self.grid.values, entry.index + 1, table.remove(self.grid.values, entry.index))
			self.grid:setIndex(entry.index + 1)
			self:save()
			self.grid:draw()
		end
	end
end

return tab
