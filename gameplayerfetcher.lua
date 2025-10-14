local Players = game:GetService("Players")

local function prettyPrintJSON(data, indent, depth)
	indent = indent or ""
	depth = depth or 0
	local nextIndent = indent .. "\t"
	local result = {}
	local compact = depth >= 2

	if type(data) == "table" then
		local isArray = #data > 0 and data[1] ~= nil
		if isArray then
			for i = 2, #data do
				if data[i] == nil then
					isArray = false
					break
				end
			end
		end

		if isArray then
			if #data == 0 then
				return "[]"
			end
			if compact then
				local parts = {}
				for _, val in ipairs(data) do
					table.insert(parts, prettyPrintJSON(val, "", depth + 1))
				end
				return "[" .. table.concat(parts, ", ") .. "]"
			else
				table.insert(result, "[\n")
				for i, val in ipairs(data) do
					table.insert(result, nextIndent .. prettyPrintJSON(val, nextIndent, depth + 1))
					if i < #data then
						table.insert(result, ",\n")
					end
				end
				table.insert(result, "\n" .. indent .. "]")
			end
		else
			if next(data) == nil then
				return "{}"
			end
			if compact then
				local parts = {}
				local keys = {}
				for k in pairs(data) do
					table.insert(keys, k)
				end
				table.sort(keys)
				for _, k in ipairs(keys) do
					local v = data[k]
					table.insert(parts, '"' .. tostring(k) .. '": ' .. prettyPrintJSON(v, "", depth + 1))
				end
				return "{ " .. table.concat(parts, ", ") .. " }"
			else
				table.insert(result, "{\n")
				local keys
				if data.plotNumber and (data.status or data.plotOwnerUsername) then
					if data.status == "Unoccupied" then
						keys = { "plotNumber", "status" }
					else
						keys = { "plotNumber", "plotOwnerDisplayName", "plotOwnerUsername", "brainrots", "plants", "isEmpty" }
					end
				else
					keys = {}
					for k in pairs(data) do
						table.insert(keys, k)
					end
					table.sort(keys)
				end
				for i, k in ipairs(keys) do
					local v = data[k]
					if v ~= nil then
						table.insert(result, nextIndent .. '"' .. tostring(k) .. '": ' .. prettyPrintJSON(v, nextIndent, depth + 1))
						local hasMore = false
						for j = i + 1, #keys do
							if data[keys[j]] ~= nil then
								hasMore = true
								break
							end
						end
						if hasMore then
							table.insert(result, ",\n")
						end
					end
				end
				table.insert(result, "\n" .. indent .. "}")
			end
		end
	elseif type(data) == "string" then
		return '"' .. data:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n") .. '"'
	elseif type(data) == "number" or type(data) == "boolean" then
		return tostring(data)
	elseif typeof(data) == "Vector3" then
		return string.format("[%s, %s, %s]", data.X, data.Y, data.Z)
	else
		return '"' .. tostring(data) .. '"'
	end
	return table.concat(result)
end

local function analyzeBrainrotPlatforms()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then
		return
	end

	local plotsData = {}

	for i = 1, 5 do
		local plot = plots:FindFirstChild(tostring(i))
		local rows = plot and plot:FindFirstChild("Rows")
		local firstRow = rows and rows:FindFirstChild("1")

		if not (firstRow and firstRow:FindFirstChild("Lawn Mower")) then
			table.insert(plotsData, {
				plotNumber = i,
				status = "Unoccupied",
			})
			continue
		end

		local ownerDisplayName = "Unclaimed"
		local ownerUsername = "N/A"

		local playerSign = plot:FindFirstChild("PlayerSign")
		local signGui = playerSign and playerSign:FindFirstChild("BillboardGui")
		local signLabel = signGui and signGui:FindFirstChild("TextLabel")

		if signLabel and signLabel.Text ~= "" then
			local nameFromSign = signLabel.Text
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name == nameFromSign or p.DisplayName == nameFromSign then
					ownerDisplayName = p.DisplayName
					ownerUsername = p.Name
					break
				end
			end
			if ownerUsername == "N/A" then
				ownerDisplayName = nameFromSign
			end
		end

		local plotInfo = {
			plotNumber = i,
			plotOwnerDisplayName = ownerDisplayName,
			plotOwnerUsername = ownerUsername,
			brainrots = {},
			plants = {},
			isEmpty = true,
		}

		local brainrotsFolder = plot:FindFirstChild("Brainrots")
		if brainrotsFolder and #brainrotsFolder:GetChildren() > 0 then
			plotInfo.isEmpty = false
			for _, brainrotInstance in ipairs(brainrotsFolder:GetChildren()) do
				local details = {}
				local name = brainrotInstance.Name

				local brainrotModel = brainrotInstance:FindFirstChild("Brainrot")
				if brainrotModel then
					for attrName, attrValue in pairs(brainrotModel:GetAttributes()) do
						details[attrName] = attrValue
					end

					local platformUI = brainrotModel:FindFirstChild("PlatformUI")
					if platformUI and platformUI:IsA("BillboardGui") then
						for _, uiElement in ipairs(platformUI:GetChildren()) do
							if uiElement:IsA("TextLabel") then
								details[uiElement.Name] = uiElement.Text
							end
						end
					end
				end

				if details.Title and details.Title ~= "" then
					name = details.Title
				elseif details.Brainrot and details.Brainrot ~= "" then
					name = details.Brainrot
				end

				details.Title = nil
				details.Brainrot = nil

				local brainrotData = {
					name = name,
					details = details,
				}
				table.insert(plotInfo.brainrots, brainrotData)
			end
		end

		local plantsFolder = plot:FindFirstChild("Plants")
		if plantsFolder and #plantsFolder:GetChildren() > 0 then
			plotInfo.isEmpty = false
			for _, plantInstance in ipairs(plantsFolder:GetChildren()) do
				local details = {}
				local name = plantInstance.Name

				local plantModel = plantInstance:FindFirstChild("Plant")
				if plantModel then
					for attrName, attrValue in pairs(plantModel:GetAttributes()) do
						details[attrName] = attrValue
					end
				end

				local plantData = {
					name = name,
					details = details,
				}
				table.insert(plotInfo.plants, plantData)
			end
		end

		table.insert(plotsData, plotInfo)
	end

	local finalReport = prettyPrintJSON(plotsData)
	print(finalReport)
	setclipboard(finalReport)
end

pcall(analyzeBrainrotPlatforms)
