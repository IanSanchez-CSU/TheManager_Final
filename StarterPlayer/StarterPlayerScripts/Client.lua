print("Loaded Client")

--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage:WaitForChild("Remotes")

-- Shared container of variables, accessible by all scripts that require() this module
return {
	
	MyId = nil,
	ShowTaskId = nil,
	Database = {Skills = {}, Accounts = {}, Projects = {}},
	
	AssignReady = false,
	EditingTree = 0,
	ProjectTree = {},
	
	Remotes = ReplicatedStorage.Remotes,
	Layers = {
		Yield = false,
		
		Prompt = false,
		
		TaskDetails = false,
		
		ManagerProjects = false,
		ManagerProfile = false,
		ManagerCreate = false,
		
		EmployeeProjects = false,
		EmployeeProfile = false,
		
		Register = false,
		Forgot = false,
		Login = false
	}
}