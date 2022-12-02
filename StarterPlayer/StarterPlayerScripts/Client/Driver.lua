local client = require(script.Parent)
client.Menus = require(script.Parent:WaitForChild("Menus"))

--Declarations
local MainStep = require(script.Parent:WaitForChild("Main"))

--Services
local RunService = game:GetService("RunService")

--Main Loop
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
while true do
	local dt = RunService.RenderStepped:Wait()
	MainStep(dt)
end