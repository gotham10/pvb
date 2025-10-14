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
			table.insert(result, "[\n")
			for i, val in ipairs(data) do
				table.insert(result, nextIndent .. prettyPrintJSON(val, nextIndent, depth + 1))
				if i < #data then
					table.insert(result, ",\n")
				end
			end
			table.insert(result, "\n" .. indent .. "]")
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
				local keys = {}
				for k in pairs(data) do
					table.insert(keys, k)
				end
				table.sort(keys)
				for i, k in ipairs(keys) do
					local v = data[k]
					table.insert(result, nextIndent .. '"' .. tostring(k) .. '": ' .. prettyPrintJSON(v, nextIndent, depth + 1))
					if i < #keys then
						table.insert(result, ",\n")
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

local function analyzeBackpackPlants()
	local player = Players.LocalPlayer
	if not player then
		return
	end
	local backpack = player:WaitForChild("Backpack")

	local plantsData = {}

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:GetAttribute("Plant") ~= nil then
			local attributes = tool:GetAttributes()
			local plantInfo = {
				name = tool.Name,
				details = attributes,
			}
			table.insert(plantsData, plantInfo)
		end
	end

	table.sort(plantsData, function(a, b)
		local damageA = a.details.Damage or 0
		local damageB = b.details.Damage or 0
		return damageA > damageB
	end)

	local finalReport = prettyPrintJSON(plantsData)
	print(finalReport)
	setclipboard(finalReport)
end

pcall(analyzeBackpackPlants)
