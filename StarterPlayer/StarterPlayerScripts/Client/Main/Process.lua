print("Loaded Client.Main.Process")
local client = require(script.Parent.Parent)

--Services
local RunService = game:GetService("RunService")

--Variables
local running = false
local tasks = {}

--Methods
local methods = {}

-- Generic function that properly locks the client from performing actions when doing some sort of yield
-- This is only used in a handful of places through the entirety of the codebase
-- e.g. during initialization when the client is waiting for the server to prepare itself
-- e.g. when a user creates a new account and is waiting for a response from the server

methods.Run = function()
	if not running then
		running = true
		coroutine.wrap(function()
			client.Layers.Yield = true
			while true do
				if #tasks > 0 then
					if client.Menus.Yield.TextLabel.Text ~= tasks[1] then
						client.Menus.Yield.TextLabel.Text = tasks[1]
						client.Util.Align("Center", client.Menus.Yield.ImageLabel, 16, client.Menus.Yield.TextLabel)
					end
					client.Menus.Yield.ImageLabel.Rotation = 360 * ((tick() / 1) % 1)
					RunService.Heartbeat:Wait()
				else
					break
				end
			end
			client.Layers.Yield = false
			running = false
		end)()
	end
end

methods.AddTask = function(task)
	local unique = true
	for i = 1, #tasks do
		if tasks[i] == task then
			unique = false
			break
		end
	end
	if unique then
		table.insert(tasks, task)
		methods.Run()
	end
end

methods.EndTask = function(task)
	for i = #tasks, 1, -1 do
		if tasks[i] == task then
			table.remove(tasks, i)
		end
	end
end

return methods