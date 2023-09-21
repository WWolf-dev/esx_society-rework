function OpenBossMenu(society, close, options)
	options = options or {}
	local elements = {}

	ESX.TriggerServerCallback('esx_society:isBoss', function(isBoss)
		if isBoss then
			local defaultOptions = {
				checkBal = true,
				withdraw = true,
				deposit = true,
				wash = true,
				employees = true,
				salary = true,
				grades = true
			}

			for k,v in pairs(defaultOptions) do
				if options[k] == nil then
					options[k] = v
				end
			end

			if options.checkBal then
				table.insert(elements, {
					title = TranslateCap('check_society_balance'),
					description = TranslateCap('check_society_balance'),
					icon = "fas fa-wallet",
					onSelect = function()
						TriggerServerEvent('esx_society:checkSocietyBalance', society)
					end
				})
			end
			if options.withdraw then
				table.insert(elements, {
					title = TranslateCap('withdraw_society_money'),
					description = TranslateCap('withdraw_society_money'),
					icon = "fas fa-wallet",
					onSelect = function()
						local input = lib.inputDialog(TranslateCap('withdraw_society_money'), {
							{
								type = 'number',
								label = 'Amount',
								description = TranslateCap('withdraw_society_money'),
								icon = 'hashtag',
								required = true
							}
						})

						if input then
							local amount = tonumber(input[1])
							if amount == nil then
								ESX.ShowNotification(TranslateCap('invalid_amount'))
							else
								TriggerServerEvent('esx_society:withdrawMoney', society, amount)
							end
						else
							ESX.ShowNotification("No input")
						end
					end
				})
			end
			if options.deposit then
				table.insert(elements, {
					title = TranslateCap('deposit_society_money'),
					description = TranslateCap('deposit_society_money'),
					icon = "fas fa-wallet",
					onSelect = function()
						local input = lib.inputDialog(TranslateCap('deposit_society_money'), {
							{
								type = 'number',
								label = 'Amount',
								description = TranslateCap('deposit_society_money'),
								icon = 'hashtag',
								required = true
							}
						})

						if input then
							local amount = tonumber(input[1])
							if amount == nil then
								ESX.ShowNotification(TranslateCap('invalid_amount'))
							else
								TriggerServerEvent('esx_society:depositMoney', society, amount)
							end
						else
							ESX.ShowNotification("No input")
						end
					end
				})
			end
			if options.wash then
				table.insert(elements, {
					title = TranslateCap('wash_money'),
					description = TranslateCap('wash_money'),
					icon = "fas fa-wallet",
					onSelect = function()
						local input = lib.inputDialog(TranslateCap('wash_money'), {
							{
								type = 'number',
								label = 'Amount',
								description = TranslateCap('wash_money'),
								icon = 'hashtag',
								required = true
							}
						})

						if input then
							local amount = tonumber(input[1])
							if amount == nil then
								ESX.ShowNotification(TranslateCap('invalid_amount'))
							else
								TriggerServerEvent('esx_society:washMoney', society, amount)
							end
						else
							ESX.ShowNotification("No input")
						end
					end
				})
			end
			if options.employees then
				table.insert(elements, {
					title = TranslateCap('employee_management'),
					description = TranslateCap('employee_management'),
					icon = "fas fa-users",
					onSelect = function()
						OpenManageEmployeesMenu(society, options)
					end
				})
			end
			if options.salary then
				table.insert(elements, {
					title = TranslateCap('salary_management'),
					description = TranslateCap('salary_management'),
					icon = "fas fa-wallet",
					onSelect = function()
						OpenManageSalaryMenu(society, options)
					end
				})
			end
			if options.grades then
				table.insert(elements, {
					title = TranslateCap('grade_management'),
					description = TranslateCap('grade_management'),
					icon = "fas fa-scroll",
					onSelect = function()
						OpenManageGradesMenu(society, options)
					end
				})
			end

			lib.registerContext({
				id = "boss_menu",
				title = "Boss Menu",
				description = "boss menu",
				options = elements
			})

			lib.showContext("boss_menu")

		end
	end, society)
end

function OpenManageEmployeesMenu(society, options)
	lib.registerContext({
		id = "employee_management",
		title = TranslateCap('employee_management'),
		description = TranslateCap('employee_management'),
		icon = "fas fa-users",
		menu = "boss_menu",
		options = {
			{
				title = TranslateCap('employee_list'),
				description = TranslateCap('employee_list'),
				icon = "fas fa-users",
				onSelect = function()
					OpenEmployeeList(society, options)
				end
			},
			{
				title = TranslateCap('recruit'),
				description = TranslateCap('recruit'),
				icon = "fas fa-users",
				onSelect = function()
					OpenRecruitMenu(society, options)
				end
			}
		}
	})

	lib.showContext("employee_management")
end

function OpenEmployeeList(society, options)
	ESX.TriggerServerCallback('esx_society:getEmployees', function(employees)
		
		local elements = {}

		for i = 1, #employees, 1 do
			local gradeLabel = (employees[i].job.grade_label == '' and employees[i].job.label or employees[i].job.grade_label)
			local data = employees[i]

			table.insert(elements, {
				title = employees[i].name .. " | " ..gradeLabel,
				icon = "fas fa-user",
				onSelect = function()
					print("Selected employee: " .. employees[i].name .. " | " ..gradeLabel)
					local employee = data

					lib.registerContext({
						id = "employees_action",
						title = employees[i].name .. " | " ..gradeLabel,
						icon = "fas fa-user",
						menu = "employee_list",
						options = {
							{
								title = TranslateCap('promote'),
								icon = "fas fa-users",
								onSelect = function()
									OpenPromoteMenu(society, employee, options)
								end
							},
							{
								title = TranslateCap('fire'),
								icon = "fas fa-users",
								onSelect = function()
									ESX.ShowNotification(TranslateCap('you_have_fired', employee.name))

									ESX.TriggerServerCallback('esx_society:setJob', function()
										OpenEmployeeList(society, options)
									end, employee.identifier, 'unemployed', 0, 'fire')
								end
							}
						}
					})

					lib.showContext("employees_action")
				end
			})
		end

		lib.registerContext({
			id = "employee_list",
			title = TranslateCap('employees_title'),
			icon = "fas fa-users",
			menu = "employee_management",
			options = elements
		})

		lib.showContext("employee_list")
	end, society)
end

function OpenRecruitMenu(society, options)
	ESX.TriggerServerCallback('esx_society:getOnlinePlayers', function(players)
		local elements = {}

		for i = 1, #players, 1 do
			if players[i].job.name ~= society then
				table.insert(elements, {
					title = players[i].name,
					icon = "fas fa-user",
					onSelect = function()
						ESX.ShowNotification(TranslateCap('you_have_hired', players[i].name))

						ESX.TriggerServerCallback('esx_society:setJob', function()
							OpenRecruitMenu(society, options)
						end, players[i].identifier, society, 0, 'hire')
					end
				})
			end
		end

		lib.registerContext({
			id = "recruit_menu",
			title = TranslateCap('recruiting'),
			icon = "fas fa-users",
			menu = "employee_management",
			options = elements
		})

		lib.showContext("recruit_menu")
	end)
end

function OpenPromoteMenu(society, employee, options)
	ESX.TriggerServerCallback('esx_society:getJob', function(job)
		if not job then
			return
		end

		local elements = {}

		for i = 1, #job.grades, 1 do
			local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)
			table.insert(elements, {
				title = gradeLabel,
				icon = "fas fa-user",
				onSelect = function()
					ESX.ShowNotification(TranslateCap('you_have_promoted', employee.name, elements.title))

					ESX.TriggerServerCallback('esx_society:setJob', function()
						OpenEmployeeList(society, options)
					end, employee.identifier, society, job.grades[i].grade, 'promote')
				end
			})
		end

		lib.registerContext({
			id = "promote_menu",
			title = TranslateCap('promote_employee', employee.name),
			icon = "fas fa-users",
			menu = "employee_list",
			options = elements
		})

		lib.showContext("promote_menu")
	end, society)
end

function OpenManageSalaryMenu(society, options)
	ESX.TriggerServerCallback('esx_society:getJob', function(job)
		if not job then
			return
		end

		local elements = {}

		for i=1, #job.grades, 1 do
			local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)
			table.insert(elements, {
				title = gradeLabel .. " : ".. ESX.Math.GroupDigits(job.grades[i].salary .. TranslateCap("currency")),
				icon = "fas fa-wallet",
				onSelect = function()
					local input = lib.inputDialog(TranslateCap('amount_title'), {
						{
							type = 'number',
							label = 'Amount',
							description = TranslateCap('change_salary_description'),
							icon = 'hashtag',
							required = true
						}
					})

					if input then
						local amount = tonumber(input[1])
						if amount == nil then
							ESX.ShowNotification(TranslateCap('invalid_value_nochanges'))
							OpenManageSalaryMenu(society, options)
						elseif amount > Config.MaxSalary then
							ESX.ShowNotification(TranslateCap('invalid_amount_max'))
							OpenManageSalaryMenu(society, options)
						else
							ESX.TriggerServerCallback('esx_society:setJobSalary', function()
								OpenManageSalaryMenu(society, options)
							end, society, job.grades[i].grade, amount)
						end
					else
						ESX.ShowNotification("No input")
					end
				end
			})
		end

		lib.registerContext({
			id = "manage_salary_menu",
			title = TranslateCap('salary_management'),
			icon = "fas fa-users",
			menu = "boss_menu",
			options = elements
		})

		lib.showContext("manage_salary_menu")
	end, society)
end

function OpenManageGradesMenu(society, options)
	ESX.TriggerServerCallback('esx_society:getJob', function(job)
		if not job then
			return
		end

		local elements = {}

		for i=1, #job.grades, 1 do
			local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)

			table.insert(elements, {
				title = ('%s'):format(gradeLabel),
				icon = "fas fa-wallet",
				onSelect = function()
					local input = lib.inputDialog(TranslateCap('change_label_title'), {
						{
							type = 'input',
							label = 'Name',
							description = TranslateCap('change_label_description'),
							icon = 'hashtag',
							required = true
						}
					})

					if input then
						local label = tostring(input[1])
						ESX.TriggerServerCallback('esx_society:setJobLabel', function()
							OpenManageGradesMenu(society, options)
						end, society, job.grades[i].grade, label)
					else
						ESX.ShowNotification("No input")
					end
				end
			})
		end

		lib.registerContext({
			id = "manage_grades_menu",
			title = TranslateCap('grade_management'),
			icon = "fas fa-wallet",
			menu = "boss_menu",
			options = elements
		})

		lib.showContext("manage_grades_menu")
	end, society)
end

AddEventHandler('esx_society:openBossMenu', function(society, close, options)
	OpenBossMenu(society, close, options)
end)
