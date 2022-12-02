print("Loaded Client.Main")
-- The "header" files
local client = require(script.Parent)
client.Gui = require(script.Gui)
client.Process = require(script.Process)
client.Draw = require(script.Draw)
client.Synchronize = require(script.Synchronize)

-- Remote signal used to let the client know their account creation signal was recevied
-- @id: string, the id of the new account
local id_buffer = nil
client.Remotes.AccountCreated.OnClientEvent:Connect(function(id)
	if id then
		id_buffer = id
	else
		id_buffer = false
	end
end)

-- Creating the layers of the interface; used internally
-- No need to document everything here as most is self-explanatory
-- Individual layers are created for each unique view / organization of the menus
-- The client sees the active layer with the highest priority; these priorities are fixed
client.Gui.AddLayer("Yield", 11, {
	client.Menus.Yield
}, nil)

client.Gui.AddLayer("Prompt", 10, {
	client.Menus.Prompt
}, nil)

client.Gui.AddLayer("TaskDetails", 9, {
	client.Menus.Main,
	client.Menus.Main.TaskDetails
}, function() -- These functions fed into the constructor fire off whenever a layer is drawn on the client's screen
	for account, data in pairs(client.Database.Accounts) do
		if data.Id == client.MyId then
			if data.Manager then
				client.Menus.Main.Tabs.Size = UDim2.new(0, 640, 0, 60)
				client.Menus.Main.Tabs.Third.Visible = true
				client.Menus.Main.Tabs.First.ImageColor3 = Color3.fromRGB(100, 100, 100)
				client.Menus.Main.Tabs.First.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				client.Menus.Main.Tabs.First.TextLabel.Text = "Projects"
				client.Menus.Main.Tabs.Second.ImageColor3 = Color3.fromRGB(100, 100, 100)
				client.Menus.Main.Tabs.Second.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				client.Menus.Main.Tabs.Second.TextLabel.Text = "Create"
				client.Menus.Main.Tabs.Third.ImageColor3 = Color3.fromRGB(100, 100, 100)
				client.Menus.Main.Tabs.Third.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				client.Menus.Main.Tabs.Third.TextLabel.Text = "Profiles"
			else
				client.Menus.Main.Tabs.Size = UDim2.new(0, 430, 0, 60)
				client.Menus.Main.Tabs.Third.Visible = false
				client.Menus.Main.Tabs.First.ImageColor3 = Color3.fromRGB(100, 100, 100)
				client.Menus.Main.Tabs.First.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				client.Menus.Main.Tabs.First.TextLabel.Text = "Projects"
				client.Menus.Main.Tabs.Second.ImageColor3 = Color3.fromRGB(100, 100, 100)
				client.Menus.Main.Tabs.Second.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				client.Menus.Main.Tabs.Second.TextLabel.Text = "My Profile"
			end
			break
		end
	end
	client.Draw("TaskDetails")
end)

client.Gui.AddLayer("ManagerProjects", 8, {
	client.Menus.Main,
	client.Menus.Main.ManagerProjects
}, function()
	client.Menus.Main.Tabs.Size = UDim2.new(0, 640, 0, 60)
	client.Menus.Main.Tabs.Third.Visible = true
	client.Menus.Main.Tabs.First.ImageColor3 = Color3.fromRGB(50, 125, 50)
	client.Menus.Main.Tabs.First.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	client.Menus.Main.Tabs.First.TextLabel.Text = "Projects"
	client.Menus.Main.Tabs.Second.ImageColor3 = Color3.fromRGB(100, 100, 100)
	client.Menus.Main.Tabs.Second.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	client.Menus.Main.Tabs.Second.TextLabel.Text = "Create"
	client.Menus.Main.Tabs.Third.ImageColor3 = Color3.fromRGB(100, 100, 100)
	client.Menus.Main.Tabs.Third.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	client.Menus.Main.Tabs.Third.TextLabel.Text = "Profiles"
	client.Draw("ManagerProjects")
end)

client.Gui.AddLayer("ManagerProfile", 7, {
	client.Menus.Main,
	client.Menus.Main.ManagerProfile
}, function()
	client.Menus.Main.Tabs.Size = UDim2.new(0, 640, 0, 60)
	client.Menus.Main.Tabs.Third.Visible = true
	client.Menus.Main.Tabs.First.ImageColor3 = Color3.fromRGB(100, 100, 100)
	client.Menus.Main.Tabs.First.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	client.Menus.Main.Tabs.First.TextLabel.Text = "Projects"
	client.Menus.Main.Tabs.Second.ImageColor3 = Color3.fromRGB(100, 100, 100)
	client.Menus.Main.Tabs.Second.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	client.Menus.Main.Tabs.Second.TextLabel.Text = "Create"
	client.Menus.Main.Tabs.Third.ImageColor3 = Color3.fromRGB(50, 125, 50)
	client.Menus.Main.Tabs.Third.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	client.Menus.Main.Tabs.Third.TextLabel.Text = "Profiles"
	client.Draw("ManagerProfile")
end)

client.Gui.AddLayer("ManagerCreate", 6, {
	client.Menus.Main,
	client.Menus.Main.ManagerCreate
}, function()
	client.Menus.Main.Tabs.Size = UDim2.new(0, 640, 0, 60)
	client.Menus.Main.Tabs.Third.Visible = true
	client.Menus.Main.Tabs.First.ImageColor3 = Color3.fromRGB(100, 100, 100)
	client.Menus.Main.Tabs.First.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	client.Menus.Main.Tabs.First.TextLabel.Text = "Projects"
	client.Menus.Main.Tabs.Second.ImageColor3 = Color3.fromRGB(50, 125, 50)
	client.Menus.Main.Tabs.Second.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	client.Menus.Main.Tabs.Second.TextLabel.Text = "Create"
	client.Menus.Main.Tabs.Third.ImageColor3 = Color3.fromRGB(100, 100, 100)
	client.Menus.Main.Tabs.Third.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	client.Menus.Main.Tabs.Third.TextLabel.Text = "Profiles"
end)

client.Gui.AddLayer("EmployeeProjects", 5, {
	client.Menus.Main,
	client.Menus.Main.EmployeeProjects
}, function()
	client.Menus.Main.Tabs.Size = UDim2.new(0, 430, 0, 60)
	client.Menus.Main.Tabs.Third.Visible = false
	client.Menus.Main.Tabs.First.ImageColor3 = Color3.fromRGB(50, 125, 50)
	client.Menus.Main.Tabs.First.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	client.Menus.Main.Tabs.First.TextLabel.Text = "Projects"
	client.Menus.Main.Tabs.Second.ImageColor3 = Color3.fromRGB(100, 100, 100)
	client.Menus.Main.Tabs.Second.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	client.Menus.Main.Tabs.Second.TextLabel.Text = "My Profile"
	client.Draw("EmployeeProjects")
end)

client.Gui.AddLayer("EmployeeProfile", 4, {
	client.Menus.Main,
	client.Menus.Main.EmployeeProfile
}, function()	
	client.Menus.Main.Tabs.Size = UDim2.new(0, 430, 0, 60)
	client.Menus.Main.Tabs.Third.Visible = false
	client.Menus.Main.Tabs.First.ImageColor3 = Color3.fromRGB(100, 100, 100)
	client.Menus.Main.Tabs.First.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	client.Menus.Main.Tabs.First.TextLabel.Text = "Projects"
	client.Menus.Main.Tabs.Second.ImageColor3 = Color3.fromRGB(50, 125, 50)
	client.Menus.Main.Tabs.Second.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	client.Menus.Main.Tabs.Second.TextLabel.Text = "My Profile"
end)

client.Gui.AddLayer("Register", 3, {
	client.Menus.Register
}, function()
	client.Menus.Register.Input1.TextBox.Text = ""
	client.Menus.Register.Input2.TextBox.Text = ""
end)

client.Gui.AddLayer("Forgot", 2, {
	client.Menus.Forgot
}, function()
	client.Menus.Forgot.Input.TextBox.Text = ""
end)

client.Gui.AddLayer("Login", 1, {
	client.Menus.Login
}, function()
	client.Menus.Login.Input.TextBox.Text = ""
end)

-- Background process that waits for the server to prepare itself before initializing operations on the client
coroutine.wrap(function()
	client.Process.AddTask("Connecting")
	repeat
		game:GetService("RunService").Heartbeat:Wait()
	until game:GetService("ReplicatedStorage"):FindFirstChild("Ready")
	client.Process.EndTask("Connecting")
	client.Remotes.SynchronizeDatabase:FireServer()
	client.Layers.Login = true
end)()

-- Defines the behaviors of the buttons in the main login screen
-- 'Access' button: used when accessing an account after a pin was entered
client.Gui.Button.Add(
	client.Menus.Login.Access.Button, {client.Menus.Login}, nil, nil, nil,
	{
		Clicked = function()
			local sample = client.Menus.Login.Input.TextBox.Text
			for account, data in pairs(client.Database.Accounts) do
				if data.Id == sample then
					client.MyId = data.Id
					client.Menus.Prompt.Header.Text = "Welcome,"
					client.Menus.Prompt.Caption.Text = "<font color=\"rgb(255,255,100)\">" .. data.FullName .. "</font>"
					client.Menus.Prompt.Action.ImageColor3 = Color3.fromRGB(50, 125, 50)
					client.Menus.Prompt.Action.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
					client.Menus.Prompt.Action.TextLabel.Text = "Continue"
					if data.Manager then
						client.Layers.ManagerProjects = true
						client.Menus.Main.Identification.Text = data.FullName.. ", Manager"
					else
						client.Layers.EmployeeProjects = true
						client.Menus.Main.Identification.Text = data.FullName.. ", Employee"
					end
					client.Layers.Prompt = true
					client.Layers.Login = false
					break
				end
			end
		end
	}
)
-- 'Register' button: used when trying to create a new account
client.Gui.Button.Add(
	client.Menus.Login.Register.Button, {client.Menus.Login}, nil, nil, nil,
	{
		Clicked = function()
			client.Layers.Register = true
		end
	}
)
-- 'Forgot' button: used when trying to recover a pin associated with an account
client.Gui.Button.Add(
	client.Menus.Login.Forgot.Button, {client.Menus.Login}, nil, nil, nil,
	{
		Clicked = function()
			client.Layers.Forgot = true
		end
	}
)
-- Connecting some nonessential events that help with UX.
-- Updates the color of the 'Access' button based on what is entered in the textbox
-- Also clears the textbox if invalid input is entered
do
	local function Refresh()
		local sample = client.Menus.Login.Input.TextBox.Text
		local highlight = false
		if sample:match("%d%d%d%d") then
			for account, data in pairs(client.Database.Accounts) do
				if data.Id == sample then
					highlight = true
					break
				end
			end
		end
		if highlight then
			client.Menus.Login.Access.ImageColor3 = Color3.fromRGB(50, 125, 50)
			client.Menus.Login.Access.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		else
			client.Menus.Login.Access.ImageColor3 = Color3.fromRGB(100, 100, 100)
			client.Menus.Login.Access.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end
	Refresh()
	client.Menus.Login.Input.TextBox:GetPropertyChangedSignal("Text"):Connect(Refresh)
	client.Menus.Login.Input.TextBox.FocusLost:Connect(function()
		if not (tonumber(client.Menus.Login.Input.TextBox.Text) and client.Menus.Login.Input.TextBox.Text:len() == 4) then
			game:GetService("RunService").Heartbeat:Wait()
			client.Menus.Login.Input.TextBox.Text = ""
		end
	end)
end

-- 'Register Action' button: used in the actual register menu when the necessary inputs are entered and fires off a process to create a new account
client.Gui.Button.Add(
	client.Menus.Register.Action.Button, {client.Menus.Register}, nil, nil, nil,
	{
		Clicked = function()
			if client.Menus.Register.Input1.TextBox.Text == "" then
				return
			end
			client.Layers.Register = false
			local name, key = client.Menus.Register.Input1.TextBox.Text, client.Menus.Register.Input2.TextBox.Text
			id_buffer = nil
			client.Process.AddTask("Creating")
			client.Remotes.RegisterNewAccount:FireServer(name, key)
			repeat
				game:GetService("RunService").Heartbeat:Wait()
			until id_buffer ~= nil
			client.Process.EndTask("Creating")
			if id_buffer then
				client.Menus.Prompt.Header.Text = id_buffer
				client.Menus.Prompt.Caption.Text = "is the account id for <font color=\"rgb(255,255,100)\">" .. name .. "</font>"
			else
				client.Menus.Prompt.Header.Text = "Process Failed"
				client.Menus.Prompt.Caption.Text = "when creating an account for <font color=\"rgb(255,255,100)\">" .. name .. "</font>"
			end
			client.Menus.Prompt.Action.ImageColor3 = Color3.fromRGB(125, 100, 50)
			client.Menus.Prompt.Action.TextLabel.TextColor3 = Color3.fromRGB(255, 170, 100)
			client.Menus.Prompt.Action.TextLabel.Text = "Return"
			client.Layers.Prompt = true
		end
	}
)
-- 'Register Cancel' button: deactivates the register layer
client.Gui.Button.Add(
	client.Menus.Register.Cancel.Button, {client.Menus.Register}, nil, nil, nil,
	{
		Clicked = function()
			client.Layers.Register = false
		end
	}
)
-- More UX processes
-- Controls the color of the 'Register Action' button to reflect whether requirements were filled out
do
	local function Refresh()
		if client.Menus.Register.Input1.TextBox.Text ~= "" then
			client.Menus.Register.Action.ImageColor3 = Color3.fromRGB(50, 125, 50)
			client.Menus.Register.Action.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		else
			client.Menus.Register.Action.ImageColor3 = Color3.fromRGB(100, 100, 100)
			client.Menus.Register.Action.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end
	Refresh()
	client.Menus.Register.Input1.TextBox:GetPropertyChangedSignal("Text"):Connect(Refresh)
end

-- 'Forgot Action' button: fires the processes associated with retrieving a forgotten pin
-- Searches the cached database, should be good because we ensure that it is maintained in-sync
client.Gui.Button.Add(
	client.Menus.Forgot.Action.Button, {client.Menus.Forgot}, nil, nil, nil,
	{
		Clicked = function()
			if client.Menus.Forgot.Input.TextBox.Text == "" then
				return
			end
			client.Layers.Forgot = false
			local found = nil
			local name = client.Menus.Forgot.Input.TextBox.Text:lower()
			for account, data in pairs(client.Database.Accounts) do
				if data.FullName:lower() == name then
					found = data.Id
					break
				end
			end
			if found then
				client.Menus.Prompt.Header.Text = found
				client.Menus.Prompt.Caption.Text = "is the account id for <font color=\"rgb(255,255,100)\">" .. name .. "</font>"
			else
				client.Menus.Prompt.Header.Text = "No Matches"
				client.Menus.Prompt.Caption.Text = "of an account id for <font color=\"rgb(255,255,100)\">" .. name .. "</font>"
			end
			client.Menus.Prompt.Action.ImageColor3 = Color3.fromRGB(125, 100, 50)
			client.Menus.Prompt.Action.TextLabel.TextColor3 = Color3.fromRGB(255, 170, 100)
			client.Menus.Prompt.Action.TextLabel.Text = "Return"
			client.Layers.Prompt = true
		end
	}
)
-- 'Forgot Cancel' button: deactives the forgot layer
client.Gui.Button.Add(
	client.Menus.Forgot.Cancel.Button, {client.Menus.Forgot}, nil, nil, nil,
	{
		Clicked = function()
			client.Layers.Forgot = false
		end
	}
)
-- UX processes
-- Changes color of the 'Forgot Action' button
do
	local function Refresh()
		if client.Menus.Forgot.Input.TextBox.Text ~= "" then
			client.Menus.Forgot.Action.ImageColor3 = Color3.fromRGB(50, 125, 50)
			client.Menus.Forgot.Action.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		else
			client.Menus.Forgot.Action.ImageColor3 = Color3.fromRGB(100, 100, 100)
			client.Menus.Forgot.Action.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end
	Refresh()
	client.Menus.Forgot.Input.TextBox:GetPropertyChangedSignal("Text"):Connect(Refresh)
end

-- Helper function, determines whether the account currently signed in belongs to a manager
local function IsManager()
	for account, data in pairs(client.Database.Accounts) do
		if data.Id == client.MyId then
			return data.Manager
		end
	end
end
-- Button that controls the first tab
client.Gui.Button.Add(
	client.Menus.Main.Tabs.First.Button, {client.Menus.Main}, nil, nil, nil,
	{
		Clicked = function()
			local order = IsManager() and {"ManagerProjects", "ManagerProfile", "ManagerCreate", "TaskDetails"} or {"EmployeeProjects", "EmployeeProfile", "TaskDetails"}
			for i = 1, #order do
				client.Layers[order[i]] = i == 1
			end
		end
	}
)
-- Button that controls the second tab
client.Gui.Button.Add(
	client.Menus.Main.Tabs.Second.Button, {client.Menus.Main}, nil, nil, nil,
	{
		Clicked = function()
			local order = IsManager() and {"ManagerCreate", "ManagerProjects", "ManagerProfile", "TaskDetails"} or {"EmployeeProfile", "EmployeeProjects", "TaskDetails"}
			for i = 1, #order do
				client.Layers[order[i]] = i == 1
			end
		end
	}
)
-- Button that controls the third tab (not always visible)
client.Gui.Button.Add(
	client.Menus.Main.Tabs.Third.Button, {client.Menus.Main, client.Menus.Main.Tabs.Third}, nil, nil, nil,
	{
		Clicked = function()
			if not IsManager() then return end
			local order = {"ManagerProfile", "ManagerCreate", "ManagerProjects", "TaskDetails"}
			for i = 1, #order do
				client.Layers[order[i]] = i == 1
			end
		end
	}
)
-- 'Exit Button': logs out the user from their account
client.Gui.Button.Add(
	client.Menus.Main.Exit.Button, {client.Menus.Main}, nil, nil, nil,
	{
		Clicked = function()
			-- edge case(s)
			if client.Layers.EmployeeProfile then
				for account, data in pairs(client.Database.Accounts) do
					if data.Id == client.MyId then
						client.Remotes.UpdateProfile:FireServer(client.MyId, data.Biography, data.Skills, data.Availability)
						break
					end
				end
			end
			if client.Layers.TaskDetails then
				client.Remotes.TaskDescription:FireServer(client.ShowTaskId, client.Menus.Main.TaskDetails.Description.TextBox.Text)
			end
			
			for _, i in pairs({"TaskDetails", "ManagerProjects", "ManagerProfile", "ManagerCreate", "EmployeeProjects", "EmployeeProfile"}) do
				client.Layers[i] = false
			end
			client.Layers.Login = true
			client.MyId = nil
		end
	}
)

-- Sometimes a generic prompt appears on screen, and this button is used to close it
client.Gui.Button.Add(
	client.Menus.Prompt.Action.Button, {client.Menus.Prompt}, nil, nil, nil,
	{
		Clicked = function()
			client.Layers.Prompt = false
		end
	}
)

local checks = {}
-- Controls some of the essential functions associated within the employee profile layer
do
	local profileopen = false
	checks[#checks + 1] = function()
		if client.Layers.EmployeeProfile and not profileopen then
			profileopen = true
			client.Draw("EmployeeProfile")
		elseif not client.Layers.EmployeeProfile and profileopen then
			profileopen = false
			for account, data in pairs(client.Database.Accounts) do
				if data.Id == client.MyId then
					client.Remotes.UpdateProfile:FireServer(client.MyId, data.Biography, data.Skills, data.Availability)
					break
				end
			end
		end
	end
	for i = 1, 7 do
		i = client.Menus.Main.EmployeeProfile[i].Input.TextBox
		i.FocusLost:Connect(function()
			game:GetService("RunService").Heartbeat:Wait()
			if #i.Text <= 2 and tonumber(i.Text) and tonumber(i.Text) <= 24 then
				local n = tonumber(i.Text:match("%d?%d"))
				i.Text = tostring(n)
			else
				i.Text = ""
			end
			local h = tonumber(i.Parent.Parent.Name)
			for account, data in pairs(client.Database.Accounts) do
				if data.Id == client.MyId then
					data.Availability[h] = tonumber(i.Text) or 0
					break
				end
			end
			client.Draw("EmployeeProfile")
		end)
	end
	client.Menus.Main.EmployeeProfile.Biography.TextBox.FocusLost:Connect(function()
		for account, data in pairs(client.Database.Accounts) do
			if data.Id == client.MyId then
				data.Biography = client.Menus.Main.EmployeeProfile.Biography.TextBox.Text
				break
			end
		end
	end)
end

-- Complex code that handles the proper creation of projects
-- We buld the project on the client, and then we send it to the server to finalize it and replicate it to other clients
do
	local UpdateList, ShowMore, CleanSlate
	-- Updates the current list of tasks
	UpdateList = function()
		for _, old in pairs(client.Menus.Main.ManagerCreate.Tasks:GetChildren()) do
			if old.Name == "X" then
				client.Gui.Button.Destroy(old.Button)
				old:Destroy()
			end
		end
		for i = 1, #client.ProjectTree do
			local entry = client.Menus.Main.ManagerCreate.Tasks.Dupe:Clone()
			entry.Name = "X"
			entry.TextLabel.Text = client.ProjectTree[i].Name
			entry.Position = UDim2.new(0, 20, 0, 50 * (i - 1))
			if i == client.EditingTree then
				entry.ImageColor3 = Color3.fromRGB(125, 125, 50)
				entry.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
			end
			entry.Visible = true
			entry.Parent = client.Menus.Main.ManagerCreate.Tasks
			client.Gui.Button.Add(
				entry.Button, {client.Menus.Main.ManagerCreate}, nil, nil, {Frame = client.Menus.Main.ManagerCreate.Tasks, Lock = nil, Y = 0, Height = 5000},
				{
					Clicked = function()
						client.EditingTree = i
						UpdateList()
						ShowMore()
					end,
				}
			)
		end
		client.Menus.Main.ManagerCreate.Tasks.Bar.Size = UDim2.new(0, 10, 0, math.max(0, #client.ProjectTree * 50 - 10))
		client.Menus.Main.ManagerCreate.Tasks.Add.Position = UDim2.new(0, 0, 0, #client.ProjectTree * 50)
		client.Menus.Main.ManagerCreate.Tasks.CanvasSize = UDim2.new(0, 0, 0, client.Menus.Main.ManagerCreate.Tasks.Add.Position.Y.Offset + 50)
		client.Menus.Main.ManagerCreate.Tasks.CanvasPosition = Vector2.new(0, (client.EditingTree - 1) * 50)
	end
	
	-- Updates the menu that shows more information about a current task
	ShowMore = function()
		if not client.ProjectTree[client.EditingTree] then
			client.Menus.Main.ManagerCreate.More.Visible = false
			return
		end
		
		client.Menus.Main.ManagerCreate.More.Visible = true
		client.Menus.Main.ManagerCreate.More.Input.TextBox.Text = client.ProjectTree[client.EditingTree].Name
		client.Menus.Main.ManagerCreate.More.Description.TextBox.Text = client.ProjectTree[client.EditingTree].Description
		client.Menus.Main.ManagerCreate.More.Skill.Cycle.TextLabel.Text = client.ProjectTree[client.EditingTree].Skill == "" and "None" or client.ProjectTree[client.EditingTree].Skill
		client.Menus.Main.ManagerCreate.More.Estimate.Input.TextBox.Text = client.ProjectTree[client.EditingTree].Estimate > 0 and tostring(client.ProjectTree[client.EditingTree].Estimate) or ""
		
	end
	
	-- Resets the project tree
	CleanSlate = function()
		client.Menus.Main.ManagerCreate.Input.TextBox.Text = ""
		client.EditingTree = 0
		client.ProjectTree = {}
		UpdateList()
		ShowMore()
	end
	
	-- 'Skill Cycle' button: cycle between skills to assign to a specific task
	client.Gui.Button.Add(
		client.Menus.Main.ManagerCreate.More.Skill.Cycle.Button, {client.Menus.Main.ManagerCreate, client.Menus.Main.ManagerCreate.More}, nil, nil, nil,
		{
			Clicked = function()
				local i = 0
				if client.ProjectTree[client.EditingTree].Skill == "" then
					i = 1
				else
					for g, skill in pairs(client.Database.Skills) do
						if skill == client.ProjectTree[client.EditingTree].Skill then
							i = g + 1
							break
						end
					end
				end
				if not client.Database.Skills[i] then
					client.ProjectTree[client.EditingTree].Skill = ""
				else
					client.ProjectTree[client.EditingTree].Skill = client.Database.Skills[i]
				end
				client.Menus.Main.ManagerCreate.More.Skill.Cycle.TextLabel.Text = client.ProjectTree[client.EditingTree].Skill == "" and "None" or client.ProjectTree[client.EditingTree].Skill
			end,
		}
	)
	
	--- 'Delete' button: deletes the current task from the project
	client.Gui.Button.Add(
		client.Menus.Main.ManagerCreate.More.Delete.Button, {client.Menus.Main.ManagerCreate, client.Menus.Main.ManagerCreate.More}, nil, nil, nil,
		{
			Clicked = function()
				table.remove(client.ProjectTree, client.EditingTree)
				client.EditingTree = 0
				UpdateList()
				ShowMore()
			end,
		}
	)
	
	-- Important events associated with writing input in textboxes
	
	client.Menus.Main.ManagerCreate.More.Input.TextBox.FocusLost:Connect(function()
		client.ProjectTree[client.EditingTree].Name = client.Menus.Main.ManagerCreate.More.Input.TextBox.Text
		UpdateList()
	end)
	
	client.Menus.Main.ManagerCreate.More.Description.TextBox.FocusLost:Connect(function()
		client.ProjectTree[client.EditingTree].Description = client.Menus.Main.ManagerCreate.More.Description.TextBox.Text
		--UpdateList()
	end)
	
	client.Menus.Main.ManagerCreate.More.Estimate.Input.TextBox.FocusLost:Connect(function()
		if #client.Menus.Main.ManagerCreate.More.Estimate.Input.TextBox.Text <= 2 and tonumber(client.Menus.Main.ManagerCreate.More.Estimate.Input.TextBox.Text) and tonumber(client.Menus.Main.ManagerCreate.More.Estimate.Input.TextBox.Text) <= 99 then
			local n = tonumber(client.Menus.Main.ManagerCreate.More.Estimate.Input.TextBox.Text:match("%d?%d"))
			client.Menus.Main.ManagerCreate.More.Estimate.Input.TextBox.Text = tostring(n)
		else
			client.Menus.Main.ManagerCreate.More.Estimate.Input.TextBox.Text = ""
		end
		client.ProjectTree[client.EditingTree].Estimate = tonumber(client.Menus.Main.ManagerCreate.More.Estimate.Input.TextBox.Text) or 0
		--UpdateList()
	end)
	
	-- Adds a new task to the project
	client.Gui.Button.Add(
		client.Menus.Main.ManagerCreate.Tasks.Add.Button, {client.Menus.Main.ManagerCreate}, nil, nil, {Frame = client.Menus.Main.ManagerCreate.Tasks, Lock = nil, Y = 0, Height = 5000},
		{
			Clicked = function()
				client.ProjectTree[#client.ProjectTree + 1] = {
					Name = "Task " .. tostring(#client.ProjectTree + 1),
					Skill = "",
					Estimate = 0,
					Description = ""
				}
				client.EditingTree = #client.ProjectTree
				UpdateList()
				ShowMore()
			end,
		}
	)
	
	-- Finalizes the project on the client, now we ship it to the server so it can determine if it's assignable and valid
	client.Gui.Button.Add(
		client.Menus.Main.ManagerCreate.Assign.Button, {client.Menus.Main.ManagerCreate}, nil, nil, nil,
		{
			Clicked = function()
				if client.AssignReady then
					local project = {
						Title = client.Menus.Main.ManagerCreate.Input.TextBox.Text,
						Tasks = {}
					}
					for _, ptask in pairs(client.ProjectTree) do
						project.Tasks[#project.Tasks + 1] = {
							Name = ptask.Name,
							Description = ptask.Description,
							Skill = ptask.Skill == "" and "None" or ptask.Skill,
							Estimate = ptask.Estimate,
							Assigned = "NIL",
							Completed = false
						}
					end
					client.Remotes.CreateProject:FireServer(project) -- sends it to the server
					client.Layers.ManagerCreate = false
					client.Layers.ManagerProjects = true
				end
			end,
		}
	)
	
	-- Some UX processes
	local createopen = false
	checks[#checks + 1] = function()
		if client.Layers.ManagerCreate and not createopen then
			createopen = true
			CleanSlate()
		elseif not client.Layers.ManagerCreate and createopen then
			createopen = false
		end
		if createopen then
			if #client.ProjectTree > 0 and client.Menus.Main.ManagerCreate.Input.TextBox.Text ~= "" then
				client.AssignReady = true
				client.Menus.Main.ManagerCreate.Assign.ImageColor3 = Color3.fromRGB(50, 125, 50)
				client.Menus.Main.ManagerCreate.Assign.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			else
				client.AssignReady = false
				client.Menus.Main.ManagerCreate.Assign.ImageColor3 = Color3.fromRGB(100, 100, 100)
				client.Menus.Main.ManagerCreate.Assign.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
		end
	end
end

-- 'Add Skill' button: adds a new skill to the pool
client.Gui.Button.Add(
	client.Menus.Main.ManagerProfile.Add.Button, {client.Menus.Main.ManagerProfile}, nil, nil, nil,
	{
		Clicked = function()
			local sample = client.Menus.Main.ManagerProfile.Input.TextBox.Text
			client.Menus.Main.ManagerProfile.Input.TextBox.Text = ""
			if sample ~= "" then
				client.Remotes.SkillPool:FireServer(sample, "Add")
			end
		end
	}
)
-- More UX processes, changing more button colors in response to certain requirements
do
	local function Refresh()
		local sample = client.Menus.Main.ManagerProfile.Input.TextBox.Text
		if sample ~= "" then
			client.Menus.Main.ManagerProfile.Add.ImageColor3 = Color3.fromRGB(50, 125, 50)
			client.Menus.Main.ManagerProfile.Add.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		else
			client.Menus.Main.ManagerProfile.Add.ImageColor3 = Color3.fromRGB(100, 100, 100)
			client.Menus.Main.ManagerProfile.Add.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end
	Refresh()
	client.Menus.Main.ManagerProfile.Input.TextBox:GetPropertyChangedSignal("Text"):Connect(Refresh)
end

-- 'Task Complete' button: marks a task as complete
client.Gui.Button.Add(
	client.Menus.Main.TaskDetails.Complete.Button, {client.Menus.Main.TaskDetails, client.Menus.Main.TaskDetails.Complete}, nil, nil, nil,
	{
		Clicked = function()
			for account, data in pairs(client.Database.Accounts) do
				if data.Id == client.MyId then
					if data.Manager then
						client.Layers.ManagerProjects = true
						client.Layers.TaskDetails = false
						client.Remotes.ManipulateTask:FireServer(client.ShowTaskId, "Incomplete")
					else
						client.Layers.EmployeeProjects = true
						client.Layers.TaskDetails = false
						client.Remotes.ManipulateTask:FireServer(client.ShowTaskId, "Complete")
					end
					break
				end
			end
		end
	}
)
-- 'Task Reassign' button: reassigns a task to a new candidate (not always visible)
client.Gui.Button.Add(
	client.Menus.Main.TaskDetails.Reassign.Button, {client.Menus.Main.TaskDetails, client.Menus.Main.TaskDetails.Reassign}, nil, nil, nil,
	{
		Clicked = function()
			client.Layers.ManagerProjects = true
			client.Layers.TaskDetails = false
			client.Remotes.ManipulateTask:FireServer(client.ShowTaskId, "Reassign")
		end,
	}
)
-- 'Task Delete' button: deletes a task
client.Gui.Button.Add(
	client.Menus.Main.TaskDetails.Delete.Button, {client.Menus.Main.TaskDetails, client.Menus.Main.TaskDetails.Delete}, nil, nil, nil,
	{
		Clicked = function()
			client.Layers.ManagerProjects = true
			client.Layers.TaskDetails = false
			client.Remotes.ManipulateTask:FireServer(client.ShowTaskId, "Delete")
		end,
	}
)
-- Sends a signal to the server whenever a task description is changed
do
	client.Menus.Main.TaskDetails.Description.TextBox.FocusLost:Connect(function()
		for account, data in pairs(client.Database.Accounts) do
			if data.Id == client.MyId then
				if data.Manager then
					client.Remotes.TaskDescription:FireServer(client.ShowTaskId, client.Menus.Main.TaskDetails.Description.TextBox.Text)
				end
				break
			end
		end
	end)
end

-- Generic function that can be called in order to perform some internal updates
return function(dt)
	client.Gui.Update(dt)
	for i = 1, #checks do
		checks[i]()
	end
end