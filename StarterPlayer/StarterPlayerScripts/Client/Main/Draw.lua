print("Loaded Client.Main.Draw")
local client = require(script.Parent.Parent)

-- This is a function that draws out and displays all of the dynamic elements associated with a certain layer
-- e.g. tasks in the homepage, employees registered, skills available, etc.

return function(menu)
	if menu == "TaskDetails" then
		-- Draw out the details for the Task Details layer
		-- e.g. the buttons that are visible, the description, and other parameters
		local ptask
		for i, project in pairs(client.Database.Projects) do
			for j, t in pairs(project.Tasks) do
				if t.Id == client.ShowTaskId then
					ptask = t
					break
				end
			end
		end
		if ptask then
			client.Menus.Main.TaskDetails.Title.TextLabel.Text = ptask.Name
			client.Menus.Main.TaskDetails.Description.TextBox.Text = ptask.Description
			client.Menus.Main.TaskDetails.Skill.Cycle.TextLabel.Text = ptask.Skill
			client.Menus.Main.TaskDetails.Estimate.Hours.TextLabel.Text = tostring(ptask.Estimate)
			local found = false
			for account, data in pairs(client.Database.Accounts) do
				if data.Id == ptask.Assigned then
					found = true
					client.Menus.Main.TaskDetails.Assigned.Full.TextLabel.Text = data.FullName
					break
				end
			end
			if not found then
				client.Menus.Main.TaskDetails.Assigned.Full.TextLabel.Text = "Nobody"
			end
			for account, data in pairs(client.Database.Accounts) do
				if data.Id == client.MyId then
					if data.Manager then
						local y = 0
						if ptask.Completed then
							client.Menus.Main.TaskDetails.Complete.ImageColor3 = Color3.fromRGB(125, 125, 50)
							client.Menus.Main.TaskDetails.Complete.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
							client.Menus.Main.TaskDetails.Complete.TextLabel.Text = "Incomplete"
							client.Menus.Main.TaskDetails.Complete.Visible = true
							y += 70
						else
							client.Menus.Main.TaskDetails.Complete.Visible = false
						end
						if not found then
							client.Menus.Main.TaskDetails.Reassign.Position = UDim2.new(0, 405, 0, 160 + y)
							client.Menus.Main.TaskDetails.Reassign.Visible = true
							y += 70
						else
							client.Menus.Main.TaskDetails.Reassign.Visible = false
						end
						client.Menus.Main.TaskDetails.Delete.Position = UDim2.new(0, 405, 0, 160 + y)
						client.Menus.Main.TaskDetails.Delete.Visible = true
						client.Menus.Main.TaskDetails.Description.TextBox.TextEditable = true
					else
						if ptask.Assigned == client.MyId and not ptask.Completed then
							client.Menus.Main.TaskDetails.Complete.ImageColor3 = Color3.fromRGB(50, 125, 50)
							client.Menus.Main.TaskDetails.Complete.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
							client.Menus.Main.TaskDetails.Complete.TextLabel.Text = "Complete"
							client.Menus.Main.TaskDetails.Complete.Visible = true
						else
							client.Menus.Main.TaskDetails.Complete.Visible = false
						end
						client.Menus.Main.TaskDetails.Reassign.Visible = false
						client.Menus.Main.TaskDetails.Delete.Visible = false
						client.Menus.Main.TaskDetails.Description.TextBox.TextEditable = false
					end
					break
				end
			end
		end
	elseif menu == "EmployeeProjects" then
		-- Draw out the details for the Employee Projects layer
		-- e.g. active and completed projects and tasks
		local pending, completed = {}, {}
		for _, project in pairs(client.Database.Projects) do
			local associated = not false
			for _, ptask in pairs(project.Tasks) do
				if ptask.Assigned == client.MyId then
					associated = true
					break
				end
			end
			if associated then
				for _, ptask in pairs(project.Tasks) do
					if ptask.Completed then
						local i for x, y in pairs(completed) do if y[1] == project.Title then i = x break end end
						if not i then
							completed[#completed + 1] = {project.Title, {}}
							i = #completed
						end
						table.insert(completed[i][2], ptask)
					else
						local i for x, y in pairs(pending) do if y[1] == project.Title then i = x break end end
						if not i then
							pending[#pending + 1] = {project.Title, {}}
							i = #pending
						end
						table.insert(pending[i][2], ptask)
					end
				end
			end
		end
		for _, old in pairs(client.Menus.Main.EmployeeProjects.Pending:GetChildren()) do
			if old.Name ~= "Dupe" then
				local button = old:FindFirstChildOfClass("TextButton")
				if button then
					client.Gui.Button.Destroy(button)
				end
				old:Destroy()
			end
		end
		for _, old in pairs(client.Menus.Main.EmployeeProjects.Completed:GetChildren()) do
			if old.Name ~= "Dupe" then
				local button = old:FindFirstChildOfClass("TextButton")
				if button then
					client.Gui.Button.Destroy(button)
				end
				old:Destroy()
			end
		end
		if #pending > 0 then
			table.sort(pending, function(a, b) return a[1] < b[1] end)
			local y = 0
			for _, project in pairs(pending) do
				local entry = client.Menus.Main.EmployeeProjects.Pending.Dupe:Clone()
				entry.Name = "X"
				entry.Position = UDim2.new(0, 0, 0, y)
				entry.Title.TextLabel.Text = project[1]
				entry.Bar.Size = UDim2.new(0, 10, 0, #project[2] * 50 - 10)
				entry.Size = UDim2.new(1, 0, 0, #project[2] * 50 - 10 + 70)
				entry.Visible = true
				entry.Parent = client.Menus.Main.EmployeeProjects.Pending
				for i, ptask in pairs(project[2]) do
					local sub = entry.Dupe:Clone()
					sub.Name = "X"
					sub.Position = UDim2.new(0, 20, 0, y + 70 + 50 * (i - 1))
					sub.TextLabel.Text = ptask.Name
					sub.Visible = true
					sub.Parent = client.Menus.Main.EmployeeProjects.Pending
					if ptask.Assigned == client.MyId then
						sub.ImageColor3 = Color3.fromRGB(125, 125, 50)
						sub.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
					end
					client.Gui.Button.Add(
						sub.Button, {client.Menus.Main.EmployeeProjects}, nil, nil, {Frame = client.Menus.Main.EmployeeProjects.Pending, Lock = nil, Y = 0, Height = 5000},
						{
							Clicked = function()
								
								client.ShowTaskId = ptask.Id
								client.Layers.TaskDetails = true
								
							end
						}
					)
				end
				y += entry.Size.Y.Offset + 20
			end
			client.Menus.Main.EmployeeProjects.Pending.CanvasSize = UDim2.new(0, 0, 0, y - 20)
		else
			client.Menus.Main.EmployeeProjects.Pending.CanvasSize = UDim2.new(0, 0, 0, 0)
		end
		if #completed > 0 then
			table.sort(completed, function(a, b) return a[1] < b[1] end)
			local y = 0
			for _, project in pairs(completed) do
				local entry = client.Menus.Main.EmployeeProjects.Pending.Dupe:Clone()
				entry.Name = "X"
				entry.Position = UDim2.new(0, 0, 0, y)
				entry.Title.TextLabel.Text = project[1]
				entry.Bar.Size = UDim2.new(0, 10, 0, #project[2] * 50 - 10)
				entry.Size = UDim2.new(1, 0, 0, #project[2] * 50 - 10 + 70)
				entry.Visible = true
				entry.Parent = client.Menus.Main.EmployeeProjects.Completed
				for i, ptask in pairs(project[2]) do
					local sub = entry.Dupe:Clone()
					sub.Name = "X"
					sub.Position = UDim2.new(0, 20, 0, y + 70 + 50 * (i - 1))
					sub.TextLabel.Text = ptask.Name
					sub.Visible = true
					sub.Parent = client.Menus.Main.EmployeeProjects.Completed
					sub.ImageColor3 = Color3.fromRGB(50, 125, 50)
					sub.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
					client.Gui.Button.Add(
						sub.Button, {client.Menus.Main.EmployeeProjects}, nil, nil, {Frame = client.Menus.Main.EmployeeProjects.Completed, Lock = nil, Y = 0, Height = 5000},
						{
							Clicked = function()
								client.ShowTaskId = ptask.Id
								client.Layers.TaskDetails = true
							end
						}
					)
				end
				y += entry.Size.Y.Offset + 20
			end
			client.Menus.Main.EmployeeProjects.Completed.CanvasSize = UDim2.new(0, 0, 0, y - 20)
		else
			client.Menus.Main.EmployeeProjects.Completed.CanvasSize = UDim2.new(0, 0, 0, 0)
		end
	elseif menu == "ManagerProjects" then
		-- Draw out the details for the Manager Projects layer
		-- e.g. active and completed projects and tasks
		local pending, completed = {}, {}
		for _, project in pairs(client.Database.Projects) do
			local done = true
			for _, ptask in pairs(project.Tasks) do
				if not ptask.Completed then
					done = false
					break
				end
			end
			for _, ptask in pairs(project.Tasks) do
				if done then
					local i for x, y in pairs(completed) do if y[1] == project.Title then i = x break end end
					if not i then
						completed[#completed + 1] = {project.Title, {}}
						i = #completed
					end
					table.insert(completed[i][2], ptask)
				else
					local i for x, y in pairs(pending) do if y[1] == project.Title then i = x break end end
					if not i then
						pending[#pending + 1] = {project.Title, {}}
						i = #pending
					end
					table.insert(pending[i][2], ptask)
				end
			end
		end
		for _, old in pairs(client.Menus.Main.ManagerProjects.Pending:GetChildren()) do
			if old.Name ~= "Dupe" then
				local button = old:FindFirstChildOfClass("TextButton")
				if button then
					client.Gui.Button.Destroy(button)
				end
				old:Destroy()
			end
		end
		for _, old in pairs(client.Menus.Main.ManagerProjects.Completed:GetChildren()) do
			if old.Name ~= "Dupe" then
				local button = old:FindFirstChildOfClass("TextButton")
				if button then
					client.Gui.Button.Destroy(button)
				end
				old:Destroy()
			end
		end
		if #pending > 0 then
			table.sort(pending, function(a, b) return a[1] < b[1] end)
			local y = 0
			for _, project in pairs(pending) do
				local entry = client.Menus.Main.EmployeeProjects.Pending.Dupe:Clone()
				entry.Name = "X"
				entry.Position = UDim2.new(0, 0, 0, y)
				entry.Title.TextLabel.Text = project[1]
				entry.Bar.Size = UDim2.new(0, 10, 0, #project[2] * 50 - 10)
				entry.Size = UDim2.new(1, 0, 0, #project[2] * 50 - 10 + 70)
				entry.Visible = true
				entry.Parent = client.Menus.Main.ManagerProjects.Pending
				for i, ptask in pairs(project[2]) do
					local sub = entry.Dupe:Clone()
					sub.Name = "X"
					sub.Position = UDim2.new(0, 20, 0, y + 70 + 50 * (i - 1))
					sub.TextLabel.Text = ptask.Name
					sub.Visible = true
					sub.Parent = client.Menus.Main.ManagerProjects.Pending
					if ptask.Completed then
						sub.ImageColor3 = Color3.fromRGB(50, 125, 50)
						sub.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
					end
					client.Gui.Button.Add(
						sub.Button, {client.Menus.Main.ManagerProjects}, nil, nil, {Frame = client.Menus.Main.ManagerProjects.Pending, Lock = nil, Y = 0, Height = 5000},
						{
							Clicked = function()
								client.ShowTaskId = ptask.Id
								client.Layers.TaskDetails = true
							end
						}
					)
				end
				y += entry.Size.Y.Offset + 20
			end
			client.Menus.Main.ManagerProjects.Pending.CanvasSize = UDim2.new(0, 0, 0, y - 20)
		else
			client.Menus.Main.ManagerProjects.Pending.CanvasSize = UDim2.new(0, 0, 0, 0)
		end
		if #completed > 0 then
			table.sort(completed, function(a, b) return a[1] < b[1] end)
			local y = 0
			for _, project in pairs(completed) do
				local entry = client.Menus.Main.EmployeeProjects.Pending.Dupe:Clone()
				entry.Name = "X"
				entry.Position = UDim2.new(0, 0, 0, y)
				entry.Title.TextLabel.Text = project[1]
				entry.Bar.Size = UDim2.new(0, 10, 0, #project[2] * 50 - 10)
				entry.Size = UDim2.new(1, 0, 0, #project[2] * 50 - 10 + 70)
				entry.Visible = true
				entry.Parent = client.Menus.Main.ManagerProjects.Completed
				for i, ptask in pairs(project[2]) do
					local sub = entry.Dupe:Clone()
					sub.Name = "X"
					sub.Position = UDim2.new(0, 20, 0, y + 70 + 50 * (i - 1))
					sub.TextLabel.Text = ptask.Name
					sub.Visible = true
					sub.Parent = client.Menus.Main.ManagerProjects.Completed
					sub.ImageColor3 = Color3.fromRGB(50, 125, 50)
					sub.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
					client.Gui.Button.Add(
						sub.Button, {client.Menus.Main.ManagerProjects}, nil, nil, {Frame = client.Menus.Main.ManagerProjects.Completed, Lock = nil, Y = 0, Height = 5000},
						{
							Clicked = function()
								client.ShowTaskId = ptask.Id
								client.Layers.TaskDetails = true
							end
						}
					)
				end
				y += entry.Size.Y.Offset + 20
			end
			client.Menus.Main.ManagerProjects.Completed.CanvasSize = UDim2.new(0, 0, 0, y - 20)
		else
			client.Menus.Main.ManagerProjects.Completed.CanvasSize = UDim2.new(0, 0, 0, 0)
		end
	elseif menu == "EmployeeProfile" then
		-- Draw out the details for the Employee Profile layer
		-- e.g. available skills and time availability
		for account, data in pairs(client.Database.Accounts) do
			if data.Id == client.MyId then
				client.Menus.Main.EmployeeProfile.Full.TextLabel.Text = data.FullName
				client.Menus.Main.EmployeeProfile.Biography.TextBox.Text = data.Biography
				local sum = 0
				for i = 1, 7 do
					sum += data.Availability[i]
					client.Menus.Main.EmployeeProfile[tostring(i)].Input.TextBox.Text = data.Availability[i] ~= 0 and tostring(data.Availability[i]) or ""
				end
				client.Menus.Main.EmployeeProfile.Availability.TextLabel.Text = "Availability (" .. tostring(sum) .. " hr" .. (sum == 1 and "" or "s") .. ")"
				
				for _, old in pairs(client.Menus.Main.EmployeeProfile.Skills:GetChildren()) do
					if old.Name ~= "Dupe" then
						client.Gui.Button.Destroy(old.Button)
						old:Destroy()
					end
				end
				local yes, no = {}, {}
				for i, new in pairs(client.Database.Skills) do
					local has = false
					for _, present in pairs(data.Skills) do
						if present == new then
							has = true
							break
						end
					end
					if has then
						yes[#yes + 1] = new
					else
						no[#no + 1] = new
					end
				end
				table.sort(yes)
				table.sort(no)
				local running = 0
				for i, new in pairs(yes) do
					running += 1
					local entry = client.Menus.Main.EmployeeProfile.Skills.Dupe:Clone()
					entry.Name = "X"
					entry.TextLabel.Text = new
					entry.Context.Text = "Click to remove"
					entry.Position = UDim2.new(0, 0, 0, 50 * (running - 1))
					entry.Visible = true
					entry.Parent = client.Menus.Main.EmployeeProfile.Skills
					entry.ImageColor3 = Color3.fromRGB(50, 125, 50)
					entry.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
					entry.Context.TextColor3 = Color3.fromRGB(100, 255, 100)
					client.Gui.Button.Add(
						entry.Button, {client.Menus.Main.EmployeeProfile}, nil, nil, {Frame = client.Menus.Main.EmployeeProfile.Skills, Lock = nil, Y = 0, Height = 5000},
						{
							Clicked = function()
								for account, data in pairs(client.Database.Accounts) do
									if data.Id == client.MyId then
										for i = #data.Skills, 1, -1 do
											if data.Skills[i] == new then
												table.remove(data.Skills, i)
												break
											end
										end
										client.Draw("EmployeeProfile")
										break
									end
								end
							end,
							
							OnEnter = function()
								entry.ImageColor3 = Color3.fromRGB(125, 50, 50)
								entry.TextLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
								entry.Context.TextColor3 = Color3.fromRGB(255, 100, 100)
							end,
							
							OnLeave = function()
								entry.ImageColor3 = Color3.fromRGB(50, 125, 50)
								entry.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
								entry.Context.TextColor3 = Color3.fromRGB(100, 255, 100)
							end
						}
					)
				end
				for i, new in pairs(no) do
					running += 1
					local entry = client.Menus.Main.EmployeeProfile.Skills.Dupe:Clone()
					entry.Name = "X"
					entry.TextLabel.Text = new
					entry.Context.Text = "Click to add"
					entry.Position = UDim2.new(0, 0, 0, 50 * (running - 1))
					entry.Visible = true
					entry.Parent = client.Menus.Main.EmployeeProfile.Skills
					entry.ImageColor3 = Color3.fromRGB(100, 100, 100)
					entry.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
					entry.Context.TextColor3 = Color3.fromRGB(200, 200, 200)
					client.Gui.Button.Add(
						entry.Button, {client.Menus.Main.EmployeeProfile}, nil, nil, {Frame = client.Menus.Main.EmployeeProfile.Skills, Lock = nil, Y = 0, Height = 5000},
						{
							Clicked = function()
								for account, data in pairs(client.Database.Accounts) do
									if data.Id == client.MyId then
										local has = false
										for i = 1, #data.Skills do
											if data.Skills[i] == new then
												has = true
												break
											end
										end
										if not has then
											table.insert(data.Skills, new)
											client.Draw("EmployeeProfile")
										end
										break
									end
								end
							end,

							OnEnter = function()
								entry.ImageColor3 = Color3.fromRGB(50, 125, 50)
								entry.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
								entry.Context.TextColor3 = Color3.fromRGB(100, 255, 100)
							end,

							OnLeave = function()
								entry.ImageColor3 = Color3.fromRGB(100, 100, 100)
								entry.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
								entry.Context.TextColor3 = Color3.fromRGB(200, 200, 200)
							end
						}
					)
				end
				client.Menus.Main.EmployeeProfile.Skills.CanvasSize = UDim2.new(0, 0, 0, running * 50 - 10)
				
				break
			end
		end
	elseif menu == "ManagerProfile" then
		-- Draw out the details for the Manager Profile layer
		-- e.g. skill pool and registered employees
		for _, old in pairs(client.Menus.Main.ManagerProfile.Skills:GetChildren()) do
			if old.Name ~= "Dupe" then
				client.Gui.Button.Destroy(old.Button)
				old:Destroy()
			end
		end
		for i, new in pairs(client.Database.Skills) do
			local entry = client.Menus.Main.ManagerProfile.Skills.Dupe:Clone()
			entry.Name = "X"
			entry.TextLabel.Text = new
			entry.Position = UDim2.new(0, 0, 0, 50 * (i - 1))
			entry.Visible = true
			entry.Parent = client.Menus.Main.ManagerProfile.Skills
			client.Gui.Button.Add(
				entry.Button, {client.Menus.Main.ManagerProfile}, nil, nil, {Frame = client.Menus.Main.ManagerProfile.Skills, Lock = nil, Y = 0, Height = 5000},
				{
					Clicked = function()
						for i = #client.Database.Skills, 1, -1 do
							if client.Database.Skills[i] == new then
								table.remove(client.Database.Skills, i)
								break
							end
						end
						client.Draw("ManagerProfile")
						client.Remotes.SkillPool:FireServer(new, "Delete")
					end,
					
					OnEnter = function()
						entry.ImageColor3 = Color3.fromRGB(125, 50, 50)
						entry.TextLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
						entry.Context.TextColor3 = Color3.fromRGB(255, 100, 100)
					end,
					
					OnLeave = function()
						entry.ImageColor3 = Color3.fromRGB(100, 100, 100)
						entry.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
						entry.Context.TextColor3 = Color3.fromRGB(200, 200, 200)
					end,
				}
			)
		end
		client.Menus.Main.ManagerProfile.Skills.CanvasSize = UDim2.new(0, 0, 0, #client.Database.Skills * 50 - 10)
		for _, old in pairs(client.Menus.Main.ManagerProfile.Accounts:GetChildren()) do
			if old.Name ~= "Dupe" then
				client.Gui.Button.Destroy(old.Button)
				old:Destroy()
			end
		end
		local running = 0
		for i, employee in pairs(client.Database.Accounts) do
			if not employee.Manager then
				running += 1
				local entry = client.Menus.Main.ManagerProfile.Accounts.Dupe:Clone()
				entry.Name = "X"
				entry.Full.Text = employee.FullName
				entry.Biography.Text = employee.Biography
				entry.Position = UDim2.new(0, 0, 0, 100 * (running - 1))
				entry.Visible = true
				entry.Parent = client.Menus.Main.ManagerProfile.Accounts
				client.Gui.Button.Add(
					entry.Button, {client.Menus.Main.ManagerProfile}, nil, nil, {Frame = client.Menus.Main.ManagerProfile.Accounts, Lock = nil, Y = 0, Height = 5000},
					{
						Clicked = function()
							for i = #client.Database.Accounts, 1, -1 do
								if client.Database.Accounts[i].Id == employee.Id then
									table.remove(client.Database.Accounts, i)
									break
								end
							end
							client.Draw("ManagerProfile")
							client.Remotes.DeleteAccount:FireServer(employee.Id)
						end,
						
						OnEnter = function()
							entry.ImageColor3 = Color3.fromRGB(125, 50, 50)
							entry.Full.TextColor3 = Color3.fromRGB(255, 100, 100)
							entry.Context.TextColor3 = Color3.fromRGB(255, 100, 100)
							entry.Biography.TextColor3 = Color3.fromRGB(255, 100, 100)
						end,
						
						OnLeave = function()
							entry.ImageColor3 = Color3.fromRGB(100, 100, 100)
							entry.Full.TextColor3 = Color3.fromRGB(200, 200, 200)
							entry.Context.TextColor3 = Color3.fromRGB(200, 200, 200)
							entry.Biography.TextColor3 = Color3.fromRGB(200, 200, 200)
						end,
					}
				)
			end
		end
		client.Menus.Main.ManagerProfile.Accounts.CanvasSize = UDim2.new(0, 0, 0, running * 100 - 10)
	end	
end