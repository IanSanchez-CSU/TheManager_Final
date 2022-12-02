print("Loaded Client.Menus")
local client = require(script.Parent)

--Services
local Players = game:GetService("Players")

-- Preloads all of the menu objects that are referred to in the codebase
-- Unlike other development methodologies, we can create all of our menus within the IDE and save them as objects
-- that persist with the file
-- This means that we can treat 2D intrefaces as assets, and we do not have to create them from scratch through code
-- like we would with HTML and CSS.

local gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Gui")
gui:WaitForChild("Forgot")
gui:WaitForChild("Login")
gui:WaitForChild("Main")
gui:WaitForChild("Prompt")
gui:WaitForChild("Register")
gui:WaitForChild("Yield")

return {
	Gui = gui,
	Forgot = gui.Forgot,
	Login = gui.Login,
	Main = gui.Main,
	Prompt = gui.Prompt,
	Register = gui.Register,
	Yield = gui.Yield
}