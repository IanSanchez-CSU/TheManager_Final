-- The auto-assignment algorithm that goes through and assigns a specific task to the best-suited candidate
-- This algorithm prioritizes employees that meet the requirements specific for the task, but then also tries to
-- match employees that have the least number of "responsibilities" (any active task assigned to them)
-- @ptask: mixed array, the task object
-- @database: mixed array, reference of the cached database
local function Assign(ptask, database)
	local open = {}
	for account, data in pairs(database.Accounts) do
		if data.Manager then
			continue
		end
		local availability = 0
		for i = 1, #data.Availability do
			availability += data.Availability[i]
		end
		local skilled = (ptask.Skill == "None")
		for i = 1, #data.Skills do
			if data.Skills[i] == ptask.Skill then
				skilled = true
				break
			end
		end
		if skilled and availability >= ptask.Estimate then
			local responsible = 0
			for _, project in pairs(database.Projects) do
				for _, stask in pairs(project.Tasks) do
					if not stask.Completed and stask.Assigned == data.Id then
						responsible += 1
					end
				end
			end
			open[#open + 1] = {data.Id, responsible}
		end
	end
	table.sort(open, function(a, b)
		return a[2] < b[2]
	end)
	local common = {}
	for i = 1, #open do
		if open[i][2] == open[1][2] then
			common[#common + 1] = open[i][1]
		end
	end
	if #open == 0 then
		ptask.Assigned = "NIL"
	else
		ptask.Assigned = common[math.random(1, #common)]
	end
end

return function(element, database)
	if element.Id then
		-- auto-assign a single task
		local cache = element.Assigned
		Assign(element, database)
		return cache ~= element.Assigned
	else
		-- auto-assign a complete project
		for _, ptask in pairs(element.Tasks) do
			Assign(ptask, database)
		end
	end
end