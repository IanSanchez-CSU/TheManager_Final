print("Loaded Client.Main.Gui.Sink")

-- Used exclusively by the Gui module; handles the proper "sinking" of buttons when they are clicked / released
-- Nonessential; used for UX only.

--Constants
local TRANSPARENCY = 2 / 3
local FADE_RATE = 2

--Services
local RunService = game:GetService("RunService")

--Variables
local processing = false
local released = {}

--Methods
local methods = {}

methods.Process = function()
	if not processing then
		processing = true
		coroutine.wrap(function()
			local dt = 0
			while true do
				local empty = true
				for flash in pairs(released) do
					empty = false
					flash.ImageTransparency = math.min(flash.ImageTransparency + FADE_RATE * dt, 1)
					if flash.ImageTransparency == 1 then
						released[flash] = nil
						flash.Visible = false
					end
				end
				if empty then
					break
				else
					dt = RunService.Heartbeat:Wait()
				end
			end
			processing = false
		end)()
	end
end

methods.Now = function(button)
	local flash = button.Parent and button.Parent:FindFirstChild("Flash")
	if not flash then
		return
	end
	
	released[flash] = nil
	flash.ImageTransparency = TRANSPARENCY
	flash.Visible = true
end

methods.Release = function(button)
	local flash = button.Parent and button.Parent:FindFirstChild("Flash")
	if not flash then
		return
	end
	
	released[flash] = true
	methods.Process()
end

return methods