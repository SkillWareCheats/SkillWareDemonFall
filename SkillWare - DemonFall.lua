-- // Demonfall Hub by SkillWare (AutoFarm + Kill Aura + Hitbox + AttackType)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkillWareCheats/Obsidianv122/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkillWareCheats/Obsidianv122/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkillWareCheats/Obsidianv122/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "SkillWare",
    Footer = "DemonFall",
    Icon = "122751651591691",
    NotifySide = "Left",
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Farm = Window:AddTab("AutoFarm", "target"),
    Misc = Window:AddTab("Misc", "settings"),
    ["UI Settings"] = Window:AddTab("UI Settings", "cog"),
}

-- MOVEMENT
local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Movement", "person-standing")

local jumpConnection = nil -- to store the connection and disconnect later

-- Infinite Jump
LeftGroupBox:AddToggle("InfiniteJumpToggle", {
    Text = "Infinite Jump",
    Default = false,
    Tooltip = "Jump forever",
    Callback = function(Value)
        InfiniteJumpEnabled = Value
    end
})

local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

local noclipConnection = nil
local previouslyTouchedParts = {}

LeftGroupBox:AddToggle("NoclipToggle", {
	Text = "Noclip",
	Tooltip = "Walk through walls",
	Default = false,
	Callback = function(enabled)
		if enabled then
			noclipConnection = RunService.Stepped:Connect(function()
				local character = player.Character
				if character then
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") and part.CanCollide == true then
							part.CanCollide = false
							-- Track parts we modified
							previouslyTouchedParts[part] = true
						end
					end
				end
			end)
			print("[cb] Noclip enabled")
		else
			if noclipConnection then
				noclipConnection:Disconnect()
				noclipConnection = nil
			end

			-- Restore only the parts we modified
			for part in pairs(previouslyTouchedParts) do
				if part and part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
			-- Clear the record
			previouslyTouchedParts = {}

			print("[cb] Noclip disabled")
		end
	end,
})

-- Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

local flying = false
local flyConnection = nil
local bodyGyro, bodyVelocity
local movementInput = Vector3.new(0, 0, 0)
local flySpeed = 50  -- Default fly speed, will be updated by slider

local humanoid

local keysDown = {}

local function updateMovement()
	local x, y, z = 0, 0, 0
	if keysDown.W then z = z + 1 end
	if keysDown.S then z = z - 1 end
	if keysDown.A then x = x - 1 end
	if keysDown.D then x = x + 1 end
	if keysDown.Space then y = y + 1 end
	if keysDown.LeftControl then y = y - 1 end
	movementInput = Vector3.new(x, y, z)
end

local function startFly()
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")

	humanoid.AutoRotate = false
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.CFrame = root.CFrame
	bodyGyro.Parent = root

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = root

	flyConnection = RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		if not camera then return end

		local camCF = camera.CFrame
		local moveDir = (camCF.RightVector * movementInput.X) + (camCF.UpVector * movementInput.Y) + (camCF.LookVector * movementInput.Z)

		if moveDir.Magnitude > 0 then
			bodyVelocity.Velocity = moveDir.Unit * flySpeed
		else
			bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end
		bodyGyro.CFrame = camCF
	end)
end

local function stopFly()
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end

	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end

	if humanoid then
		humanoid.AutoRotate = true
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
		humanoid = nil
	end

	movementInput = Vector3.new(0, 0, 0)
	keysDown = {}
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	local key = input.KeyCode
	if key == Enum.KeyCode.W then keysDown.W = true
	elseif key == Enum.KeyCode.S then keysDown.S = true
	elseif key == Enum.KeyCode.A then keysDown.A = true
	elseif key == Enum.KeyCode.D then keysDown.D = true
	elseif key == Enum.KeyCode.Space then keysDown.Space = true
	elseif key == Enum.KeyCode.LeftControl then keysDown.LeftControl = true
	end
	updateMovement()
end)

UserInputService.InputEnded:Connect(function(input)
	local key = input.KeyCode
	if key == Enum.KeyCode.W then keysDown.W = false
	elseif key == Enum.KeyCode.S then keysDown.S = false
	elseif key == Enum.KeyCode.A then keysDown.A = false
	elseif key == Enum.KeyCode.D then keysDown.D = false
	elseif key == Enum.KeyCode.Space then keysDown.Space = false
	elseif key == Enum.KeyCode.LeftControl then keysDown.LeftControl = false
	end
	updateMovement()
end)

-- UI: Toggle fly on/off
LeftGroupBox:AddToggle("FlyToggle", {
	Text = "Fly",
	Tooltip = "Toggle flying",
	Default = false,
	Callback = function(enabled)
		if enabled then
			startFly()
			print("[cb] Fly enabled")
		else
			stopFly()
			print("[cb] Fly disabled")
		end
	end,
})

-- UI: Slider to control fly speed dynamically
LeftGroupBox:AddSlider("FlySpeedSlider", {
	Text = "Fly Speed",
	Min = 10,
	Max = 200,
	Default = flySpeed,
	Rounding = 0,
	Compact = false,
	Callback = function(value)
		flySpeed = value
		print("[cb] Fly speed set to:", flySpeed)
	end,
})

local LeftGroupBox2 = Tabs.Main:AddRightGroupbox("Visuals", "view")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Master toggle switches
local espEnabled = false
local showBoxes = false
local showTracers = false
local showNames = false
local showDistance = false
local showHealth = false

local ESPObjects = {}

local function createESP(player)
	if player == LocalPlayer or ESPObjects[player] then return end

	local objects = {
		Box = Drawing.new("Square"),
		Tracer = Drawing.new("Line"),
		Name = Drawing.new("Text"),
		Distance = Drawing.new("Text"),
		Health = Drawing.new("Text"),
	}

	objects.Box.Color = Color3.fromRGB(0, 255, 0)
	objects.Box.Thickness = 2
	objects.Box.Filled = false
	objects.Box.Transparency = 1
	objects.Box.Visible = false

	objects.Tracer.Color = Color3.fromRGB(255, 255, 0)
	objects.Tracer.Thickness = 1
	objects.Tracer.Transparency = 1
	objects.Tracer.Visible = false

	for _, text in ipairs({objects.Name, objects.Distance, objects.Health}) do
		text.Size = 12
		text.Center = true
		text.Outline = true
		text.Visible = false
	end

	objects.Name.Color = Color3.fromRGB(255, 255, 255)
	objects.Distance.Color = Color3.fromRGB(200, 200, 200)
	objects.Health.Color = Color3.fromRGB(255, 0, 0)

	ESPObjects[player] = objects
end

local function removeESP(player)
	local obj = ESPObjects[player]
	if obj then
		for _, drawing in pairs(obj) do
			drawing:Remove()
		end
		ESPObjects[player] = nil
	end
end

RunService.RenderStepped:Connect(function()
	if not espEnabled then return end
	for player, drawings in pairs(ESPObjects) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		if hrp and humanoid and humanoid.Health > 0 then
			local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if onScreen then
				local size = Vector2.new(2, 3) * (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y - pos.Y)

				drawings.Box.Size = size
				drawings.Box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
				drawings.Box.Visible = showBoxes

				drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
				drawings.Tracer.Visible = showTracers

				drawings.Name.Text = player.Name
				drawings.Name.Position = Vector2.new(pos.X, pos.Y - size.Y / 2 - 15)
				drawings.Name.Visible = showNames

				local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
				drawings.Distance.Text = string.format("%.0f studs", dist)
				drawings.Distance.Position = Vector2.new(pos.X, pos.Y + size.Y / 2 + 2)
				drawings.Distance.Visible = showDistance

				drawings.Health.Text = "HP: " .. math.floor(humanoid.Health)
				drawings.Health.Position = Vector2.new(pos.X, pos.Y + size.Y / 2 + 15)
				drawings.Health.Visible = showHealth
			else
				for _, v in pairs(drawings) do
					v.Visible = false
				end
			end
		else
			for _, v in pairs(drawings) do
				v.Visible = false
			end
		end
	end
end)

task.spawn(function()
	while true do
		if espEnabled then
			for _, player in ipairs(Players:GetPlayers()) do
				createESP(player)
			end
			for player in pairs(ESPObjects) do
				if not Players:FindFirstChild(player.Name) then
					removeESP(player)
				end
			end
		end
		task.wait(1)
	end
end)

-- Create toggles and keep references
local ESPMasterToggle = LeftGroupBox2:AddToggle("ESPMaster", {
	Text = "ESP Master",
	Default = false,
	Tooltip = "Enable full ESP system",
	Callback = function(value)
		espEnabled = value
	end
})

local ESPBoxesToggle = LeftGroupBox2:AddToggle("ESPBoxes", {
	Text = "ESP Boxes",
	Default = false,
	Tooltip = "Draw boxes around players",
	Callback = function(value)
		showBoxes = value
	end
})

local ESPTracersToggle = LeftGroupBox2:AddToggle("ESPTracers", {
	Text = "ESP Tracers",
	Default = false,
	Tooltip = "Draw tracer lines to players",
	Callback = function(value)
		showTracers = value
	end
})

local ESPNamesToggle = LeftGroupBox2:AddToggle("ESPNames", {
	Text = "ESP Name Tags",
	Default = false,
	Tooltip = "Show player names",
	Callback = function(value)
		showNames = value
	end
})

local ESPDistanceToggle = LeftGroupBox2:AddToggle("ESPDistance", {
	Text = "ESP Distance",
	Default = false,
	Tooltip = "Show distance to player",
	Callback = function(value)
		showDistance = value
	end
})

local ESPHealthToggle = LeftGroupBox2:AddToggle("ESPHealth", {
	Text = "ESP Health",
	Default = false,
	Tooltip = "Show player HP",
	Callback = function(value)
		showHealth = value
	end
})

-- Add color pickers as children of toggles for proper UI nesting
local ESPBoxColorPicker = ESPBoxesToggle:AddColorPicker("ESPBoxColor", {
	Default = Color3.fromRGB(0, 255, 0),
	Title = "Box Color",
	Transparency = 0,
	Callback = function(color)
		for _, obj in pairs(ESPObjects) do
			obj.Box.Color = color
		end
	end
})

local ESPTracerColorPicker = ESPTracersToggle:AddColorPicker("ESPTracerColor", {
	Default = Color3.fromRGB(255, 255, 0),
	Title = "Tracer Color",
	Transparency = 0,
	Callback = function(color)
		for _, obj in pairs(ESPObjects) do
			obj.Tracer.Color = color
		end
	end
})

local ESPNameColorPicker = ESPNamesToggle:AddColorPicker("ESPNameColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Name Color",
	Transparency = 0,
	Callback = function(color)
		for _, obj in pairs(ESPObjects) do
			obj.Name.Color = color
		end
	end
})

local ESPHealthColorPicker = ESPHealthToggle:AddColorPicker("ESPHealthColor", {
	Default = Color3.fromRGB(255, 0, 0),
	Title = "Health Color",
	Transparency = 0,
	Callback = function(color)
		for _, obj in pairs(ESPObjects) do
			obj.Health.Color = color
		end
	end
})

local ESPDistanceColorPicker = ESPDistanceToggle:AddColorPicker("ESPDistanceColor", {
	Default = Color3.fromRGB(200, 200, 200),
	Title = "Distance Color",
	Transparency = 0,
	Callback = function(color)
		for _, obj in pairs(ESPObjects) do
			obj.Distance.Color = color
		end
	end
})

-- End
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local autoFarmEnabled, killAuraEnabled = false, false
local positionMode, safeDistance, skillDelay = "Above", 5, 2.5
local attackType = "Server"
local hitboxSize = 5
local selectedNPC, kills, skillCooldown = nil, 0, 0

local npcList = {}
for _, npc in ipairs(workspace:GetDescendants()) do
    if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
        if not table.find(npcList, npc.Name) then
            table.insert(npcList, npc.Name)
        end
    end
end

-- UI Controls
local FarmGroup = Tabs.Farm:AddLeftGroupbox("⚔ NPC AutoFarm", "sword")
FarmGroup:AddDropdown("NPCDropdown", {
    Values = npcList, Default = npcList[1], Text = "Select NPC",
    Callback = function(v) selectedNPC = v end
})
FarmGroup:AddSlider("SafeDistSlider", {
    Text = "Safe Distance", Min = 1, Max = 25, Default = 5,
    Callback = function(v) safeDistance = v end
})
FarmGroup:AddSlider("SkillDelaySlider", {
    Text = "Skill Delay", Min = 0.1, Max = 5, Default = 2.5,
    Rounding = 1,
    Callback = function(v) skillDelay = v end
})
FarmGroup:AddDropdown("PositionMode", {
    Values = {"Above", "Below", "Same Level", "Behind"}, Default = "Above",
    Text = "Position Mode", Callback = function(v) positionMode = v end
})
FarmGroup:AddDropdown("AttackType", {
    Values = {"Light", "Heavy"},
    Default = "Light",
    Text = "Attack Type",
    Callback = function(v) attackType = (v == "Light" and "Server" or "Heavy") end
})
FarmGroup:AddSlider("HitboxSlider", {
    Text = "Hitbox Size",
    Min = 2, Max = 30, Default = 5,
    Callback = function(v) hitboxSize = v end
})
FarmGroup:AddToggle("AutoFarmToggle", {
    Text = "Enable AutoFarm", Default = false,
    Callback = function(v) autoFarmEnabled = v end
})
FarmGroup:AddToggle("KillAuraToggle", {
    Text = "Enable Kill Aura", Default = false,
    Callback = function(v) killAuraEnabled = v end
})

-- Hit function
local function lightHit()
    local args = {[1]="Katana",[2]=attackType}
    ReplicatedStorage.Remotes.Async:FireServer(unpack(args))
end

-- Nearest NPC
local function nearestNPC()
    local char, hrp = player.Character, player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local nearest, nearestDist = nil, math.huge
    if not hrp then return nil end
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name == selectedNPC and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChildOfClass("Humanoid").Health > 0 then
            local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < nearestDist then
                nearest = npc
                nearestDist = dist
            end
        end
    end
    return nearest
end

-- Resize hitboxes
RunService.RenderStepped:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Hitbox") or (v:IsA("Part") and v.Name == "Hitbox") then
            v.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            v.CanCollide = false
            v.Massless = true
            v.Transparency = 1
        end
    end
end)

-- Main loop
RunService.Heartbeat:Connect(function(dt)
    local char, hrp, hum = player.Character, player.Character and player.Character:FindFirstChild("HumanoidRootPart"), player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    local npc = nearestNPC()
    if npc then
        local npcHRP = npc.HumanoidRootPart
        local offset = Vector3.new(0,0,0)
        if positionMode == "Above" then offset = Vector3.new(0,5,0)
        elseif positionMode == "Below" then offset = Vector3.new(0,-3,0)
        elseif positionMode == "Behind" then
            local lookDir = (npcHRP.CFrame.LookVector) * -safeDistance
            offset = Vector3.new(lookDir.X, 0, lookDir.Z)
        end

        -- AutoFarm: teleport only
        if autoFarmEnabled then
            if positionMode == "Behind" then
                hrp.CFrame = CFrame.new(npcHRP.Position + offset, npcHRP.Position)
            else
                local direction = (npcHRP.Position - hrp.Position).Unit
                local targetPos = npcHRP.Position - direction * safeDistance + offset
                hrp.CFrame = CFrame.new(targetPos, npcHRP.Position + Vector3.new(0, offset.Y, 0))
            end
        end

        -- Kill Aura: hit only when toggle on
        if killAuraEnabled then
            local dist = (npcHRP.Position - hrp.Position).Magnitude
            if dist <= safeDistance + hitboxSize then
                lightHit()
            end
        end
    end
end)
-- end

-- 📌 MISC Tab Features (God Mode + Remove Fog)
local Other = Tabs.Misc:AddLeftGroupbox("Other", "sword")
local Lighting = game:GetService("Lighting")
local godModeEnabled, noFogEnabled = false, false

-- 📌 MISC Tab Features (Fixed God Mode + Constant No Fog)
local Lighting = game:GetService("Lighting")
local godModeEnabled, noFogEnabled = false, false

Other:AddToggle("NoFogToggle", {
    Text = "Remove Fog",
    Default = false,
    Callback = function(v)
        noFogEnabled = v
    end
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

-- Setup UI save & theme
SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/Demonfall")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
Library:Notify("SkillWare Loaded ✅")
