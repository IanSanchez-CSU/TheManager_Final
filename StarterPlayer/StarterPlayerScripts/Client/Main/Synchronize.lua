print("Loaded Client.Main.Synchronize")
local client = require(script.Parent.Parent)

-- Remote signal callback that ensures the client remains synchronized with the server
-- @database: mixed array, a cached version of the database
client.Remotes.SynchronizeDatabase.OnClientEvent:Connect(function(database)
	client.Database = database
	
	-- Check whether our account was deleted
	local deleted = true
	for account, data in pairs(client.Database.Accounts) do
		if data.Id == client.MyId then
			deleted = false
			break
		end
	end
	if deleted then
		for _, i in pairs({"TaskDetails", "ManagerProjects", "ManagerProfile", "ManagerCreate", "EmployeeProjects", "EmployeeProfile"}) do
			client.Layers[i] = false
		end
		client.Layers.Login = true
		client.MyId = nil
		return
	end
	
	-- Ugly way of doing this... but necessary for now.
	-- Consider changing, but also remember that it's easy to add onto this way, too.
	if client.Layers.TaskDetails then
		client.Draw("TaskDetails")
	end
	if client.Layers.ManagerProfile then
		client.Draw("ManagerProfile")
	end
	if client.Layers.EmployeeProfile then
		client.Draw("EmployeeProfile")
	end
	if client.Layers.ManagerProjects then
		client.Draw("ManagerProjects")
	end
	if client.Layers.EmployeeProjects then
		client.Draw("EmployeeProjects")
	end
	
end)

return nil