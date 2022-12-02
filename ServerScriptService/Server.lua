-- A private key used in the registration of administrative 'manager' accounts
local MANAGER_KEY = "magic"

-- Initializes the database
local TheManager = game:GetService("DataStoreService"):GetDataStore("TheManager_Prototype2")
local database = TheManager:GetAsync("Database")
if not database then
	database = {
		Skills = {},
		Accounts = {},
		Projects = {},
		TaskId = 0,
	}
end

-- Background process that ensures periodic pushes of the app's state to the database
spawn(function()
	game.OnClose = function()
		local done = false
		spawn(function()
			TheManager:SetAsync("Database", database)
			done = true
		end)
		while true do
			wait()
			if done then
				break
			end
		end
	end
	while true do
		wait(30)
		pcall(function() TheManager:SetAsync("Database", database) end)
	end
end)

-- Remote signal used to synchronize the database between the server and the connected clients
local synchronize = game:GetService("ReplicatedStorage").Remotes.SynchronizeDatabase
synchronize.OnServerEvent:Connect(function(client)
	synchronize:FireClient(client, database)
end)

-- Remote signal used in the creation of new accounts
-- @name: string, full name of the new account
-- @key: string, optional manager key
local created = game:GetService("ReplicatedStorage").Remotes.AccountCreated
local register = game:GetService("ReplicatedStorage").Remotes.RegisterNewAccount
register.OnServerEvent:Connect(function(client, name, key)
	for account, data in pairs(database.Accounts) do
		if data.FullName:lower() == name:lower() then
			created:FireClient(client, nil)
			return nil
		end
	end
	
	local id, attempts = nil, 0
	repeat
		local sample = string.format("%04d", math.random(0, 9999))
		local unique = true
		for account, data in pairs(database.Accounts) do
			if data.Id == sample then
				unique = false
				break
			end
		end
		if unique then
			id = sample
		else
			attempts += 1
		end
	until id or attempts == 100
	
	if id then
		database.Accounts[#database.Accounts + 1] = {
			FullName = name,
			Id = id,
			Manager = (key == MANAGER_KEY) and true or false,
			Availability = {0, 0, 0, 0, 0, 0, 0},
			Skills = {},
			Biography = ""
		}
		created:FireClient(client, id)
		synchronize:FireAllClients(database)
		TheManager:SetAsync("Database", database)
	else
		created:FireClient(client, nil)
	end
end)

-- Remote signal used when clients push changes to their own profile
-- @id: string, id of the account
-- @biography: string, contents of biography
-- @skills: string array, contents of skills
-- @availability: int array, contents of availability
local updateprofile = game:GetService("ReplicatedStorage").Remotes.UpdateProfile
updateprofile.OnServerEvent:Connect(function(client, id, biography, skills, availability)
	for account, data in pairs(database.Accounts) do
		if data.Id == id then
			local changed = false
			if biography and biography ~= data.Biography then
				changed = true
				data.Biography = biography
			end
			if skills then
				local different = false
				for _, old in pairs(data.Skills) do
					local present = false
					for _, new in pairs(skills) do
						if old == new then
							present = true
							break
						end
					end
					if not present then
						different = true
						break
					end
				end
				if different or #data.Skills ~= #skills then
					changed = true
					data.Skills = skills
				end
			end
			if availability then
				for i = 1, #data.Availability do
					if data.Availability[i] ~= availability[i] then
						changed = true
						data.Availability[i] = availability[i]
					end
				end
			end
			if changed then
				synchronize:FireAllClients(database)
			end
			return nil
		end
	end
end)

-- Remote signal used when clients push changes to the app's skill pool
-- @skill: string, name of skill being manipulated
-- @action: string, whether adding or removing a skill
local skillpool = game:GetService("ReplicatedStorage").Remotes.SkillPool
skillpool.OnServerEvent:Connect(function(client, skill, action)
	if action == "Add" then
		local present = false
		for _, old in pairs(database.Skills) do
			if old == skill then
				present = true
				break
			end
		end
		if not present then
			database.Skills[#database.Skills + 1] = skill
			synchronize:FireAllClients(database)
		end
	elseif action == "Delete" then
		for i, old in pairs(database.Skills) do
			if old == skill then
				for account, data in pairs(database.Accounts) do
					for j = #data.Skills, 1, -1 do
						if data.Skills[j] == skill then
							table.remove(data.Skills, j)
						end
					end
				end
				table.remove(database.Skills, i)
				synchronize:FireAllClients(database)
				return nil
			end
		end
	end
end)

-- Remote signal used when clients are deleting an account
-- @id: string, id of the account
local deleteaccount = game:GetService("ReplicatedStorage").Remotes.DeleteAccount
deleteaccount.OnServerEvent:Connect(function(client, id)
	for account, data in pairs(database.Accounts) do
		if data.Id == id then
			for _, project in pairs(database.Projects) do
				for _, ptask in pairs(project.Tasks) do
					if ptask.Assigned == id then
						ptask.Assigned = "NIL"
					end
				end
			end
			table.remove(database.Accounts, account)
			synchronize:FireAllClients(database)
			return nil
		end
	end
end)

-- Remote signal used when managers are creating a new project
-- @project: mixed array, contains an organized tree that defines the project and task parameters
local createproject = game:GetService("ReplicatedStorage").Remotes.CreateProject
local AutoAssign = require(script.AutoAssign)
createproject.OnServerEvent:Connect(function(client, project)
	for _, ptask in pairs(project.Tasks) do
		ptask.Id = database.TaskId
		database.TaskId += 1
	end
	AutoAssign(project, database)
	database.Projects[#database.Projects + 1] = project
	synchronize:FireAllClients(database)
end)

-- Remote signal used when manipulating a task object
-- @id: int, the id of the task
-- @action: string, what to do with the actual task object
local manipulatetask = game:GetService("ReplicatedStorage").Remotes.ManipulateTask
manipulatetask.OnServerEvent:Connect(function(client, id, action)
	for i, project in pairs(database.Projects) do
		for j, ptask in pairs(project.Tasks) do
			if ptask.Id == id then
				local changed = false
				if action == "Complete" then
					if not ptask.Completed then
						ptask.Completed = true
						changed = true
					end
				elseif action == "Incomplete" then
					if ptask.Completed then
						ptask.Completed = false
						changed = true
					end
				elseif action == "Reassign" then
					changed = AutoAssign(ptask, database)
				elseif action == "Delete" then
					table.remove(project.Tasks, j)
					if #project.Tasks == 0 then
						table.remove(database.Projects, i)
					end
					changed = true
				end
				if changed then
					synchronize:FireAllClients(database)
				end
				return nil
			end
		end
	end
end)

-- Remote signal used when a client is altering the description of a task
-- @id: int, the id of the task
-- @description: string, the contents of the new description
local taskdescription = game:GetService("ReplicatedStorage").Remotes.TaskDescription
taskdescription.OnServerEvent:Connect(function(client, id, description)
	for i, project in pairs(database.Projects) do
		for j, ptask in pairs(project.Tasks) do
			if ptask.Id == id then
				if ptask.Description ~= description then
					ptask.Description = description
					synchronize:FireAllClients(database)
				end
			end
		end
	end
end)

-- Replicated flag that lets clients know the server is ready
Instance.new("Flag", game:GetService("ReplicatedStorage")).Name = "Ready"