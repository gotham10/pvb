local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local mainGui = playerGui:WaitForChild("Main")
local modules = ReplicatedStorage:WaitForChild("Modules")
local registries = modules:WaitForChild("Registries")

local function runGearBuyer()
	local buyRemote = remotes:FindFirstChild("BuyGear")
	local gearRegistryScript = registries:FindFirstChild("GearRegistry")
	local assetsGears = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Gears")
	local gearsGui = mainGui:FindFirstChild("Gears")

	if not gearsGui or not buyRemote or not gearRegistryScript then
		return
	end

	local scrolling = gearsGui:FindFirstChild("Frame") and gearsGui.Frame:FindFirstChild("ScrollingFrame")
	if not scrolling then
		return
	end

	local restockLabel = gearsGui:FindFirstChild("Restock") or gearsGui.Frame:FindFirstChild("Restock")

	local function parseRegistry(scriptObj)
		local out = {}
		if not scriptObj then return out end
		local src = tostring(scriptObj.Source or "")
		local count = 0
		for name in src:gmatch('%["([^"]-)"%]%s*=%s*{') do
			out[name] = true
			count = count + 1
		end
		if count == 0 then
			for k in src:gmatch('([%w%s%-%_%%]+)%s*=%s*{') do
				if #k > 1 then
					out[k] = true
					count = count + 1
				end
			end
		end
		return out
	end

	local gearList = parseRegistry(gearRegistryScript)
	if assetsGears then
		local added = 0
		for _, g in ipairs(assetsGears:GetChildren()) do
			if not gearList[g.Name] then
				gearList[g.Name] = true
				added = added + 1
			end
		end
	end

	local function isIgnored(i)
		if not i or i.Name == "Padding" then return true end
		local c = i.ClassName
		return c == "UIPadding" or c == "UIListLayout"
	end

	local function findStockLabel(frame)
		if not frame then return nil end
		local direct = frame:FindFirstChild("Stock") or frame:FindFirstChild("StockValue")
		if direct and direct:IsA("TextLabel") then return direct end
		for _, v in ipairs(frame:GetDescendants()) do
			if v:IsA("TextLabel") and v.Text and v.Text:lower():find("in stock") then
				return v
			end
		end
		return nil
	end

	local function parseStock(text)
		if not text then return 0 end
		local n = text:match("x%s*(%d+)") or text:match("(%d+)")
		return tonumber(n) or 0
	end

	local function attemptBuy(gearName)
		local success, err
		
		success, err = pcall(function() buyRemote:FireServer(gearName) end)
		if success then return true end
		task.wait(0.15)
		
		success, err = pcall(function() buyRemote:FireServer({ Name = gearName }) end)
		if success then return true end
		task.wait(0.15)
		
		success, err = pcall(function() buyRemote:FireServer({ ID = gearName }) end)
		if success then return true end
		
		return false
	end

	local function processFrame(frame)
		if isIgnored(frame) then return end
		local gearName = frame.Name
		if not gearName or gearName == "" or not gearList[gearName] then return end
		local stockLabel = findStockLabel(frame)
		if not stockLabel then return end

		while task.wait(0.25) do
			local count = parseStock(stockLabel.Text)
			if count <= 0 then
				break
			end
			if not attemptBuy(gearName) then
				break
			end
		end
	end

	local function scanAll()
		for _, child in ipairs(scrolling:GetChildren()) do
			if not isIgnored(child) then
				coroutine.wrap(processFrame)(child)
				task.wait(0.1)
			end
		end
	end

	local function parseTimeToSeconds(t)
		if not t then return 0 end
		local mm, ss = t:match("(%d+):(%d+)")
		if mm and ss then return tonumber(mm) * 60 + tonumber(ss) end
		local n = t:match("(%d+)")
		return tonumber(n) or 0
	end

	if restockLabel then
		local lastSeconds = parseTimeToSeconds(restockLabel.Text)
		restockLabel:GetPropertyChangedSignal("Text"):Connect(function()
			local s = parseTimeToSeconds(restockLabel.Text)
			if s > lastSeconds then
				task.wait(0.5)
				scanAll()
			end
			lastSeconds = s
		end)
	end

	scanAll()
end

coroutine.wrap(runGearBuyer)()
