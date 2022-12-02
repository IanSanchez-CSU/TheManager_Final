print("Loaded Client.Main.Gui")
local client = require(script.Parent.Parent)

-- Gui / 2D Interface input handling module that was developed for another project but is being
-- recycled for this one, since doing so helps save a lot of time
-- Why are we using this? Rbx native tools are rather limited, but a lot of the power users opt to
-- develop their own tools to expand on their own specific usecases
-- This module makes it a lot easier to handle layered interfaces
-- As an added bonus, it comes with function button state event callbacks that can be used for UX purposes (like OnEnter and OnLeave)
-- This was originally developed by Ian, but for another project completely unrelated to this course. We are simply adapting it for our use.

--Services
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

--Modules
local sink = require(script:WaitForChild("Sink"))

--Variables
local inputType -- Mouse, Touch, Gamepad
local escapeMenuOpen = false

local touchObject
local touchObjectConnection
local touchCursorX, touchCursorY = 0, 0

local navLock
local autoFocus

local refreshLayers = true -- automatically refresh w/ first update
local internal = {}
local layers = {
	Reference = {}, -- {[layer] = {Show = {}, Priority = ..., Callback = ...}
	Elements = {},
	Order = {}
}

local refreshOpen = true -- automatically refresh w/ first update
local open = {} -- what can be currently highlighted

local highlighted

local linked = {} -- controls the visibility links
local buttons = {} -- all buttons are cached here
local scrolls = {} -- all scrolls are cached here

--Methods
local methods = {}

methods.Button = {
	Add = function(button, links, focus, dynamic, scroll, states)
		--[[
			button = Instance,
			links = {...},
			focus = int (priority),
			dynamic = true/nil,
			scroll = {Frame = ..., Lock = string/nil, Height = int, Y = int)
		]]
		
		local data = {}
		
		for i, parent in pairs(links) do
			if i == (scroll and scroll.LinkIgnore or 0) then
				break
			end
			if not linked[parent] then
				linked[parent] = {}
				parent:GetPropertyChangedSignal("Visible"):Connect(methods.Refresh)
			end
			if scroll then
				local duplicate = false
				for i = #linked[parent], 1, -1 do
					if linked[parent][i] == scroll.Frame then
						duplicate = true
						break
					end
				end
				if not duplicate then
					table.insert(linked[parent], scroll.Frame)
				end
			else
				table.insert(linked[parent], button)
			end
		end
		data.Links = links
		
		if not scroll then
			data.Focus = focus
		end
		data.Dynamic = dynamic
		
		if scroll then
			if not scrolls[scroll.Frame] then
				local active
				if scroll.LinkIgnore then
					active = {}
					for i = 1, scroll.LinkIgnore - 1 do
						table.insert(active, links[i])
					end
				else
					active = links
				end
				scrolls[scroll.Frame] = {Links = active, Lock = scroll.Lock, Focus = focus, Map = {}, Rows = {}}
			end
			table.insert(scrolls[scroll.Frame].Map, button)
			if not scrolls[scroll.Frame].Rows[scroll.Y] then
				scrolls[scroll.Frame].Rows[scroll.Y] = {Height = scroll.Height, Buttons = {}}
			end
			table.insert(scrolls[scroll.Frame].Rows[scroll.Y].Buttons, button)
			data.Scroll = {Frame = scroll.Frame, Y = scroll.Y}
		end
				
		data.States = states
		data.Input = {}
		data.Input.Began = button.InputBegan:Connect(function(input)
			if input.UserInputState ~= Enum.UserInputState.Begin or data.Input.Ended or not data.States.Clicked then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA then
				--client.Sound.Screen("ButtonDown", true)
				sink.Now(button)
				data.Input.Ended = input:GetPropertyChangedSignal("UserInputState"):Connect(function()
					if input.UserInputState ~= Enum.UserInputState.End or not data.Input.Ended then
						return
					end
					data.Input.Ended:Disconnect()
					data.Input.Ended = nil
					sink.Release(button)
					
					if not data.Highlighted then
						--return
					end
					--client.Sound.Screen("ButtonUp", true)
					if data.States.Clicked then
						data.States.Clicked()
					end
				end)
			end
		end)
		
		buttons[button] = data		
	end,
	
	Change = function(button, states)
		local data = buttons[button]
		if not data then
			return
		end
		
		for state, func in pairs(states) do
			data.States[state] = func
		end
	end,
	
	Destroy = function(button)
		local data = buttons[button]
		if not data then
			return
		end
		
		if data.Scroll then
			local subdata = scrolls[data.Scroll.Frame]
			for i = #subdata.Map, 1, -1 do
				if subdata.Map[i] == button then
					table.remove(subdata.Map, i)
				end
			end
			for i = #subdata.Rows[data.Scroll.Y].Buttons, 1, -1 do
				if subdata.Rows[data.Scroll.Y].Buttons[i] == button then
					table.remove(subdata.Rows[data.Scroll.Y].Buttons, i)
				end
			end
			if #subdata.Rows[data.Scroll.Y].Buttons == 0 then
				subdata.Rows[data.Scroll.Y] = nil
			end
		end
		for _, parent in pairs(data.Links) do
			for i = #linked[parent], 1, -1 do
				if linked[parent][i] == button then
					table.remove(linked[parent], i)
				end
			end
		end
		-- extend this here in the future to clear from scrolls and linked, too (not needed for now)
		-- e.g. #scrolls.Map == 0, remove scrolls[scroll]
		-- e.g. #linked[parent] == 0, remove linked[parent]
		
		data.Input.Began:Disconnect()
		if data.Input.Ended then
			data.Input.Ended:Disconnect()
			sink.Release(button)
		end
		if data.Highlighted and data.States.OnLeave then
			data.States.OnLeave()
		end		
		
		data = nil
		buttons[button] = nil
		methods.Refresh()
	end
}

methods.AddLayer = function(name, priority, show, callback)
	if name ~= "Default" and internal[name] == nil then
		print("Could not add layer: " .. tostring(name))
		return
	end
	
	if layers.Reference[name] then
		print("Layer already added: " .. tostring(name))
		return
	end
	
	for i = 1, #show do
		local duplicate = false
		for j = 1, #layers.Elements do
			if layers.Elements[j] == show[i] then
				duplicate = true
				break
			end
		end
		if not duplicate then
			table.insert(layers.Elements, show[i])
		end
	end
	
	layers.Reference[name] = {Priority = priority, Show = show, Callback = callback}
	table.insert(layers.Order, name)
	table.sort(layers.Order, function(a, b)
		return layers.Reference[a].Priority > layers.Reference[b].Priority
	end)
end

methods.CreateNavMap = function(lock, map, override)
	if override or (not lock or lock ~= navLock) then
		navLock = lock
		print("NavMap Created:", navLock)
		if lock == "Generic" then
			GuiService:RemoveSelectionGroup("Navigation")
			GuiService:AddSelectionTuple("Navigation", unpack(map))
		else
			local active = {}
			for _, sample in pairs(map) do
				if methods.LinksAreActive((buttons[sample] or scrolls[sample]).Links) then
					table.insert(active, sample)
				end
			end
			GuiService:RemoveSelectionGroup("Navigation")
			GuiService:AddSelectionTuple("Navigation", unpack(active))
			active = nil
		end
	end
end

methods.GetCursorPosition = function()
	if inputType == "Touch" then
		return touchCursorX, touchCursorY
	elseif inputType == "Mouse" then
		return Mouse.X, Mouse.Y
	end
end

methods.GetClosestButtonToCorner = function(frame)
	local data = scrolls[frame]
	if not data then
		return
	end
	
	local canvasY = frame.CanvasPosition.Y
	local prospective, weight
	for y, row in pairs(data.Rows) do
		local consider = false
		for _, sample in pairs(row.Buttons) do
			if methods.LinksAreActive(buttons[sample].Links) then
				consider = true
				break
			end
		end
		if consider then
			local w = math.abs(y - canvasY)
			if not weight or w < weight then
				prospective, weight = row, w
			end
		end
	end
	if not prospective then
		return
	end
	
	weight = nil
	local selection
	for _, sample in pairs(prospective.Buttons) do
		if methods.LinksAreActive(buttons[sample].Links) then
			if not weight or sample.AbsolutePosition.X < weight then
				selection, weight = sample, sample.AbsolutePosition.X
			end
		end
	end
	return selection
end

methods.UpdateInputType = function(last)
	if last == Enum.UserInputType.Touch then
		last = "Touch"
	elseif last == Enum.UserInputType.Gamepad1 then
		last = "Gamepad"
	else
		last = "Mouse"
	end
	if inputType ~= last then
		inputType = last
	end
end

methods.LinksAreActive = function(links)
	for _, parent in pairs(links) do
		if not parent.Visible then
			return false
		end
	end
	return true
end

methods.TestPoint = function(x, y, position, size)
	if x > position.X and y > position.Y and x < position.X + size.X and y < position.Y + size.Y then
		return true
	end
	return false
end

methods.TestHighlight = function(x, y, button, scroll)
	if (not scroll or methods.TestPoint(x, y, scroll.AbsolutePosition, scroll.AbsoluteSize)) and methods.TestPoint(x, y, button.AbsolutePosition, button.AbsoluteSize) then
		return true
	end
	return false
end

methods.Refresh = function()
	refreshOpen = true
end

methods.Update = function()
	if refreshLayers then
		refreshLayers = false
		for _, element in pairs(layers.Elements) do
			element.Visible = false
		end
		for i = 1, #layers.Order do
			local name = layers.Order[i]
			if internal[name] or name == "Default" then
				if layers.Reference[name].Callback then
					layers.Reference[name].Callback()
				end
				for _, element in pairs(layers.Reference[name].Show) do
					element.Visible = true
				end
				break
			end
		end
		
	end
	
	if refreshOpen then
		refreshOpen = false
		table.clear(open)
		local sampled = {}
		local focus, priority
		for parent, children in pairs(linked) do
			if parent.Visible then
				for _, child in pairs(children) do
					if not sampled[child] then
						sampled[child] = true
						local data = child.ClassName == "ScrollingFrame" and scrolls[child] or buttons[child]
						if methods.LinksAreActive(data.Links) then
							if data.Focus and (not priority or priority < data.Focus) then
								focus, priority = child, data.Focus
							end
							table.insert(open, child)
						end
					end
				end
			end
		end
		sampled = nil
		autoFocus = focus
		methods.CreateNavMap("Generic", open, true)
	end
	
	if inputType == "Gamepad" then
		local sample = GuiService.SelectedObject
		local data = sample and (sample.ClassName == "ScrollingFrame" and scrolls[sample] or buttons[sample]) or nil
		if not (data and methods.LinksAreActive(data.Links)) then
			--print("AUTO-FOCUSED HERE")
			GuiService.SelectedObject = autoFocus
		end
		
		sample = GuiService.SelectedObject
		data = sample and (sample.ClassName == "ScrollingFrame" and scrolls[sample] or buttons[sample]) or nil
		if data then
			if data.Scroll then
				if data.Scroll.Y < data.Scroll.Frame.CanvasPosition.Y then
					data.Scroll.Frame.CanvasPosition = Vector2.new(0, data.Scroll.Y)
				else
					local bottom = data.Scroll.Y + scrolls[data.Scroll.Frame].Rows[data.Scroll.Y].Height
					local window = data.Scroll.Frame.AbsoluteWindowSize.Y
					if bottom > (data.Scroll.Frame.CanvasPosition.Y + window) then
						data.Scroll.Frame.CanvasPosition = Vector2.new(0, bottom - window)
					end
				end
				data = scrolls[data.Scroll.Frame]
				methods.CreateNavMap(data.Lock, data.Map, false)
			else
				methods.CreateNavMap("Generic", open, false)
			end
			UserInputService.MouseIconEnabled = false
		else
			UserInputService.MouseIconEnabled = true
		end
	else
		GuiService.SelectedObject = nil
		UserInputService.MouseIconEnabled = true
	end
	
	if touchObject then
		touchCursorX, touchCursorY = touchObject.Position.X, touchObject.Position.Y
	end
	
	if highlighted then
		local valid = false
		local data = buttons[highlighted]
		if not escapeMenuOpen and data and methods.LinksAreActive(data.Links) then
			
			if inputType == "Gamepad" then
				valid = GuiService.SelectedObject == highlighted
			else
				local x, y
				if inputType == "Touch" then
					x, y = touchCursorX, touchCursorY
				else
					x, y = Mouse.X, Mouse.Y
				end
				valid = methods.TestHighlight(x, y, highlighted, data.Scroll and data.Scroll.Frame or nil)
			end
			
		end
		if valid then
			if data.Dynamic and data.States.OnEnter then
				data.States.OnEnter()
			end
		else
			if data then
				data.Highlighted = nil
				if data.Input.Ended then
					data.Input.Ended:Disconnect()
					data.Input.Ended = nil
					sink.Release(highlighted)
				end
				if data.States.OnLeave then
					data.States.OnLeave()
				end
			end
			highlighted = nil
		end
	end
	
	if not (highlighted or escapeMenuOpen) then
		
		if inputType == "Gamepad" then
			local sample = GuiService.SelectedObject
			if sample and sample.ClassName ~= "ScrollingFrame" then
				local data = buttons[sample]
				local search = data and data.Scroll and data.Scroll.Frame or sample
				for _, child in pairs(open) do
					if child == search then
						highlighted = sample
						break
					end
				end
			end
		else
			for _, sample in pairs(open) do
				local x, y
				if inputType == "Touch" then
					x, y = touchCursorX, touchCursorY
				else
					x, y = Mouse.X, Mouse.Y
				end
				if methods.TestHighlight(x, y, sample) then
					if sample.ClassName == "ScrollingFrame" then
						local canvasY = (y - sample.AbsolutePosition.Y) + sample.CanvasPosition.Y
						local data = scrolls[sample]

						local prospective
						for y, row in pairs(data.Rows) do
							if y < canvasY and y + row.Height >= canvasY then
								prospective = row
								break
							end
						end
						if prospective then
							for _, subsample in pairs(prospective.Buttons) do
								if methods.TestHighlight(x, y, subsample) then
									if methods.LinksAreActive(buttons[subsample].Links) then
										highlighted = subsample
									end
									break
								end
							end
						end

					else
						highlighted = sample
					end
				end
				if highlighted then
					break
				end
			end
		end
		
		if highlighted then
			local data = buttons[highlighted]
			if data then
				data.Highlighted = true
				--client.Sound.Screen("ButtonHover")
				if data.States.OnEnter then
					data.States.OnEnter()
				end
			end
		end
	end
end

for layer, bool in pairs(client.Layers) do
	internal[layer] = bool
	client.Layers[layer] = nil
end
setmetatable(client.Layers, {
	__index = function(self, index)
		return internal[index]
	end,

	__newindex = function(self, index, value)
		internal[index] = value
		refreshLayers = true
	end
})

methods.UpdateInputType(UserInputService:GetLastInputType())
UserInputService.LastInputTypeChanged:Connect(methods.UpdateInputType)

UserInputService.InputBegan:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.Touch then
		if not touchObject then
			touchObject = input
			touchObjectConnection = input:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if input.UserInputState ~= Enum.UserInputState.End then
					return
				end
				if touchObjectConnection then
					touchObjectConnection:Disconnect()
					touchObjectConnection = nil
				end
				touchObject = nil
			end)
		end
	elseif input.KeyCode == Enum.KeyCode.ButtonX or input.KeyCode == Enum.KeyCode.ButtonB then -- make sure to change this if I ever want to add a dedicated back function in the future
		if scrolls[GuiService.SelectedObject] and input.KeyCode == Enum.KeyCode.ButtonX then
			local button = methods.GetClosestButtonToCorner(GuiService.SelectedObject)
			if button then
				GuiService.SelectedObject = button
			end
		elseif buttons[GuiService.SelectedObject] then
			local data = buttons[GuiService.SelectedObject]
			if data.Scroll then
				GuiService.SelectedObject = data.Scroll.Frame
			end
		end
	elseif input.KeyCode == Enum.KeyCode.ButtonSelect then
		if not (client.Menus.Hotbar.Visible and client.Menus.Hotbar.ImageLabel.Visible) then
			return
		end
		if GuiService.SelectedObject then
			GuiService.SelectedObject = nil
		else
			GuiService.SelectedObject = client.Menus.Hotbar.MyPlayer.Button
		end
	-- any more cases here
	end
end)

GuiService.MenuOpened:Connect(function()
	escapeMenuOpen = true
	if touchObjectConnection then
		touchObjectConnection:Disconnect()
		touchObjectConnection = nil
	end
	touchObject = nil
end)

GuiService.MenuClosed:Connect(function()
	escapeMenuOpen = false
end)

GuiService.AutoSelectGuiEnabled = false

return methods