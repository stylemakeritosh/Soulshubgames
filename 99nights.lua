-- Load SoulsHub library
local SoulsHub = loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/3a930cb943c37a8e"))()

-- Main Window
local Window = SoulsHub:CreateWindow({
    Name = "Souls Hub X 99 nights in the forest - Updated",
    LoadingTitle = "Welcome",
    LoadingSubtitle = "Souls Hub Complete",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = true, Invite = "https://discord.gg/5mK7NFXv" },
    KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(chr)
    character = chr
    humanoid = chr:WaitForChild("Humanoid")
end)

-- Global Variables
local teleportTargets = {
    "Alien", "Alien Chest", "Alien Shelf", "Alpha Wolf", "Anvil Base", "Apple", "Bandage", "Bear", "Berry", "Bolt", 
    "Broken Fan", "Broken Microwave", "Bunny", "Cake", "Carrot", "Chair Set", "Chest", "Coal", "Coin Stack", 
    "Crossbow Cultist", "Cultist", "Cultist Gem", "Fuel Canister", "Good Axe", "Item Chest", "Item Chest2", 
    "Item Chest3", "Item Chest4", "Item Chest6", "Laser Fence Blueprint", "Leather Body", "Log", "Lost Child", 
    "Lost Child2", "Lost Child3", "Lost Child4", "Medkit", "Old Flashlight", "Old Radio", 
    "Raygun", "Revolver", "Revolver Ammo", "Rifle", "Rifle Ammo", "Seed Box", "Tyre", "UFO Component", "UFO Junk", 
    "Washing Machine", "Wolf", "MedKit", "Sheet Metal", "Oil Barrel", "Old Car Engine", "Giant Sack", "Strong Axe"
}

local AimbotTargets = {"Alien", "Alpha Wolf", "Wolf", "Crossbow Cultist", "Cultist", "Bunny", "Bear"}

-- 📱 Discord Tab
local TabDiscord = Window:CreateTab("Discord")
TabDiscord:CreateLabel("Join our Discord community!", nil)
TabDiscord:CreateButton({
    Name = "Join Discord",
    Info = "Click to join the Souls Hub Discord server",
    Interact = "Press",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Discord",
            Text = "Join our Discord: https://discord.gg/5mK7NFXv",
            Duration = 5
        })
    end,
})

-- 🛠️ Main Tab
local TabMain = Window:CreateTab("Main Features")
TabMain:CreateLabel("Core Features & Player Modifications", nil)

-- 🔥 Teleport to bonfire at night
local bonfirePosition = Vector3.new(0.32, 6.15, -0.22)
local teleportEnabled = false
local teleportConnection = nil

TabMain:CreateToggle({
    Name = "Teleport to Bonfire at Night",
    Info = "Teleports to bonfire during nighttime",
    CurrentValue = false,
    Flag = "BonfireTeleport",
    Callback = function(value)
        teleportEnabled = value
        
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
        
        if value then
            teleportConnection = RunService.Heartbeat:Connect(function()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    if Lighting.ClockTime >= 18 or Lighting.ClockTime <= 6 then
                        local hrp = character.HumanoidRootPart
                        hrp.CFrame = CFrame.new(bonfirePosition)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        end
    end
})

-- 🕴 Infinite Jump
local infiniteJump = false
local jumpConnection = nil

TabMain:CreateToggle({
    Name = "Infinite Jump",
    Info = "Allows continuous jumping",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(value)
        infiniteJump = value
        
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
        
        if value then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if infiniteJump and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

-- 🏃‍♂️ Speed Control
local speedEnabled = false
local currentSpeed = 16
local speedConnection = nil

local speedToggle = TabMain:CreateToggle({
    Name = "Enable Speed",
    Info = "Enable custom walk speed",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(value)
        speedEnabled = value
        
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        
        if value and humanoid then
            humanoid.WalkSpeed = currentSpeed
            speedConnection = RunService.Heartbeat:Connect(function()
                if humanoid and speedEnabled then
                    humanoid.WalkSpeed = currentSpeed
                end
            end)
        elseif humanoid then
            humanoid.WalkSpeed = 16 -- Default speed
        end
    end
})

local speedSlider = TabMain:CreateSlider({
    Name = "Speed Value",
    Info = "Adjust player walk speed",
    Range = {16, 1000},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = 16,
    Flag = "SpeedValue",
    Callback = function(value)
        currentSpeed = value
        if speedEnabled and humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

-- Jump Power Control
local jumpPowerSlider = TabMain:CreateSlider({
    Name = "Jump Power",
    Info = "Adjust player jump power",
    Range = {50, 700},
    Increment = 1,
    Suffix = " Power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = value
        end
    end
})

-- No Clip
local noclipEnabled = false
local noclipConnection = nil

local function noclipLoop()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

TabMain:CreateToggle({
    Name = "No Clip",
    Info = "Walk through walls",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(value)
        noclipEnabled = value
        
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        if value then
            noclipConnection = RunService.Stepped:Connect(noclipLoop)
        end
    end
})

-- Fly System
local flying = false
local flyConnection = nil
local flySpeed = 60

local function startFlying()
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bodyGyro = Instance.new("BodyGyro", hrp)
    local bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConnection = RunService.RenderStepped:Connect(function()
        local moveVec = Vector3.zero
        local camCF = workspace.CurrentCamera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += camCF.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec -= camCF.UpVector end
        bodyVelocity.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * flySpeed or Vector3.zero
        bodyGyro.CFrame = camCF
    end)
end

local function stopFlying()
    if flyConnection then flyConnection:Disconnect() end
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

TabMain:CreateToggle({
    Name = "Fly Mode (WASD + Space + Ctrl)",
    Info = "Enable fly mode with keyboard controls",
    CurrentValue = false,
    Flag = "FlyMode",
    Callback = function(value)
        flying = value
        if flying then 
            startFlying() 
        else 
            stopFlying() 
        end
    end
})

-- Kill Aura System
local killAuraEnabled = false
local killAuraConnection = nil
local killRadius = 200

local toolsDamageIDs = {
    ["Old Axe"] = "1_8982038982",
    ["Good Axe"] = "112_8982038982",
    ["Strong Axe"] = "116_8982038982",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016",
    ["Katana"] = "2_" .. LocalPlayer.UserId,
    ["Morningstar"] = "2_" .. LocalPlayer.UserId,
    ["Laser Sword"] = "2_" .. LocalPlayer.UserId
}

local function getAnyToolWithDamageID()
    for toolName, damageID in pairs(toolsDamageIDs) do
        local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil, nil
end

local function killAuraLoop()
    while killAuraEnabled do
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tool, damageID = getAnyToolWithDamageID()
            if tool and damageID then
                for _, mob in ipairs(workspace:FindFirstChild("Characters") and workspace.Characters:GetChildren() or {}) do
                    if mob:IsA("Model") then
                        local part = mob:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude <= killRadius then
                            pcall(function()
                                ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                    mob, tool, damageID, CFrame.new(part.Position)
                                )
                            end)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

TabMain:CreateToggle({
    Name = "Kill Aura",
    Info = "Automatically attack nearby enemies",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(value)
        killAuraEnabled = value
        if value then
            task.spawn(killAuraLoop)
        end
    end
})

TabMain:CreateSlider({
    Name = "Kill Aura Radius",
    Info = "Set the attack radius for kill aura",
    Range = {20, 500},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 200,
    Flag = "KillRadius",
    Callback = function(value)
        killRadius = value
    end
})

-- Auto Tree Farm
local autoTreeFarmEnabled = false
local badTrees = {}

local function autoTreeFarm()
    task.spawn(function()
        while autoTreeFarmEnabled do
            local trees = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Trunk" and obj.Parent and obj.Parent.Name == "Small Tree" then
                    local distance = (obj.Position - Vector3.new(0, 0, 0)).Magnitude
                    if distance > 50 and not badTrees[obj:GetFullName()] then
                        table.insert(trees, obj)
                    end
                end
            end

            table.sort(trees, function(a, b)
                return (a.Position - character.HumanoidRootPart.Position).Magnitude < 
                       (b.Position - character.HumanoidRootPart.Position).Magnitude
            end)

            for _, trunk in ipairs(trees) do
                if not autoTreeFarmEnabled then break end
                character:PivotTo(trunk.CFrame + Vector3.new(0, 3, 0))
                task.wait(0.2)
                local startTime = tick()
                while autoTreeFarmEnabled and trunk and trunk.Parent and trunk.Parent.Name == "Small Tree" do
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    task.wait(0.2)
                    if tick() - startTime > 12 then
                        badTrees[trunk:GetFullName()] = true
                        break
                    end
                end
                task.wait(0.3)
            end
            task.wait(1.5)
        end
    end)
end

TabMain:CreateToggle({
    Name = "Auto Tree Farm",
    Info = "Automatically farm small trees",
    CurrentValue = false,
    Flag = "AutoTreeFarm",
    Callback = function(value)
        autoTreeFarmEnabled = value
        if value then
            autoTreeFarm()
        end
    end
})

-- 📦 Items & ESP Tab
local TabItems = Window:CreateTab("Items & ESP")
TabItems:CreateLabel("Item Management & ESP Features", nil)

-- ESP System
local espEnabled = false
local npcEspEnabled = false

local function createItemESP(item)
    if not item:IsA("Model") or item:FindFirstChildWhichIsA("Humanoid") or item:FindFirstChild("ESP") then return end
    local distance = (item:GetPivot().Position - Vector3.new(0, 0, 0)).Magnitude
    if distance < 50 then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = item:FindFirstChildWhichIsA("BasePart")
    billboard.Size = UDim2.new(0, 50, 0, 20)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2, 0)

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = item.Name
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextScaled = true

    billboard.Parent = item
end

local function createNPCESP(npc)
    if not npc:IsA("Model") or npc:FindFirstChild("NPC_ESP") or not npc:FindFirstChild("HumanoidRootPart") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NPC_ESP"
    billboard.Adornee = npc.HumanoidRootPart
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = npc.Name
    label.TextColor3 = Color3.fromRGB(255, 85, 0)
    label.TextStrokeTransparency = 0.5
    label.TextScaled = true

    billboard.Parent = npc
end

local function toggleItemESP(state)
    espEnabled = state
    for _, item in pairs(workspace:GetDescendants()) do
        if table.find(teleportTargets, item.Name) then
            if espEnabled then
                createItemESP(item)
            elseif item:FindFirstChild("ESP") then
                item.ESP:Destroy()
            end
        end
    end
end

local function toggleNPCESP(state)
    npcEspEnabled = state
    for _, obj in ipairs(workspace:GetDescendants()) do
        if table.find(AimbotTargets, obj.Name) and obj:IsA("Model") then
            if state then
                createNPCESP(obj)
            elseif obj:FindFirstChild("NPC_ESP") then
                obj.NPC_ESP:Destroy()
            end
        end
    end
end

TabItems:CreateToggle({
    Name = "Item ESP",
    Info = "Show ESP for important items",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = toggleItemESP
})

TabItems:CreateToggle({
    Name = "NPC/Mob ESP",
    Info = "Show ESP for NPCs and mobs",
    CurrentValue = false,
    Flag = "NPCESP",
    Callback = toggleNPCESP
})

-- Item Bring System
local function bringItems(itemName, offsetY)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local offset = 0
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") and item.Name == itemName then
            local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if part then
                -- Use the dragging system
                pcall(function()
                    ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
                    item:SetPrimaryPartCFrame(root.CFrame * CFrame.new(offset, offsetY or 2, 0))
                    ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
                    offset = offset + 2
                end)
                task.wait(0.1)
            end
        end
    end
end

-- Item Bring Buttons
local itemCategories = {
    ["Basic Resources"] = {"Log", "Coal", "Fuel Canister", "Berry", "Carrot", "Bandage"},
    ["Medical & Food"] = {"MedKit", "Cooked Steak", "Cooked Morsel", "Apple", "Cake"},
    ["Weapons & Tools"] = {"Revolver", "Rifle", "Good Axe", "Strong Axe", "Chainsaw", "Spear"},
    ["Materials"] = {"Sheet Metal", "Bolt", "Oil Barrel", "Old Car Engine", "Broken Fan"},
    ["Valuable Items"] = {"Coin Stack", "Alien Chest", "UFO Component", "Cultist Gem"}
}

for category, items in pairs(itemCategories) do
    TabItems:CreateLabel(category, nil)
    for _, itemName in ipairs(items) do
        TabItems:CreateButton({
            Name = "Bring " .. itemName,
            Info = "Teleport all " .. itemName .. "s to player",
            Interact = "Press",
            Callback = function()
                bringItems(itemName)
            end
        })
    end
end

-- 🛡️ Combat & Defense Tab  
local TabCombat = Window:CreateTab("Combat & Defense")
TabCombat:CreateLabel("Combat Features & Protection", nil)

-- Aimbot System
local aimbotEnabled = false
local FOVRadius = 100
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(128, 255, 0)
FOVCircle.Thickness = 1
FOVCircle.Radius = FOVRadius
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Visible = true
        
        -- Aimbot logic
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local camera = workspace.CurrentCamera
            local closestTarget, shortestDistance = nil, math.huge
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if table.find(AimbotTargets, obj.Name) and obj:IsA("Model") and obj:FindFirstChild("Head") then
                    local screenPos, onScreen = camera:WorldToViewportPoint(obj.Head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDistance and dist <= FOVRadius then
                            shortestDistance = dist
                            closestTarget = obj.Head
                        end
                    end
                end
            end
            
            if closestTarget then
                camera.CFrame = CFrame.new(camera.CFrame.Position, closestTarget.Position)
            end
        end
    else
        FOVCircle.Visible = false
    end
end)

TabCombat:CreateToggle({
    Name = "Aimbot (Right Click)",
    Info = "Auto-aim at enemies when right clicking",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(value)
        aimbotEnabled = value
    end
})

TabCombat:CreateSlider({
    Name = "Aimbot FOV",
    Info = "Set aimbot field of view radius",
    Range = {50, 300},
    Increment = 10,
    Suffix = " px",
    CurrentValue = 100,
    Flag = "AimbotFOV",
    Callback = function(value)
        FOVRadius = value
        FOVCircle.Radius = value
    end
})

-- God Mode
local godModeEnabled = false

TabCombat:CreateToggle({
    Name = "God Mode",
    Info = "Make player invincible",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(value)
        godModeEnabled = value
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:SetAttribute("GodMode", value)
            end
        end
    end
})

-- No Fall Damage
local noFallDamageEnabled = false

TabCombat:CreateToggle({
    Name = "No Fall Damage",
    Info = "Prevent fall damage",
    CurrentValue = false,
    Flag = "NoFallDamage",
    Callback = function(value)
        noFallDamageEnabled = value
        
        if value then
            humanoid.StateChanged:Connect(function(_, newState)
                if newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.PlatformStanding then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
        end
    end
})

-- No Animal Aggro
local noAggroEnabled = false
local noAggroConnection = nil

TabCombat:CreateToggle({
    Name = "No Animal Aggression",
    Info = "Prevent animal attacks",
    CurrentValue = false,
    Flag = "NoAnimalAggro",
    Callback = function(value)
        noAggroEnabled = value
        
        if noAggroConnection then
            noAggroConnection:Disconnect()
            noAggroConnection = nil
        end
        
        if value then
            noAggroConnection = RunService.Heartbeat:Connect(function()
                if character then
                    for _, npc in ipairs(workspace:GetDescendants()) do
                        if npc:IsA("Model") and (npc.Name:find("Wolf") or npc.Name:find("Bunny") or npc.Name:find("Bear")) then
                            local humanoid = npc:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                humanoid:SetAttribute("IgnorePlayer", true)
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- Auto Feed System
local autoFeedEnabled = false
local feedHungerThreshold = 75
local foodItems = {"Cooked Steak", "Cooked Morsel", "Berry", "Carrot", "Apple", "Cake"}

local function getHungerLevel()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if gui and gui:FindFirstChild("Interface") then
        local hungerBar = gui.Interface:FindFirstChild("StatBars") and 
                         gui.Interface.StatBars:FindFirstChild("HungerBar") and
                         gui.Interface.StatBars.HungerBar:FindFirstChild("Bar")
        if hungerBar then
            return math.floor(hungerBar.Size.X.Scale * 100)
        end
    end
    return 100
end

local function feedPlayer()
    for _, foodName in ipairs(foodItems) do
        for _, item in ipairs(workspace:FindFirstChild("Items") and workspace.Items:GetChildren() or {}) do
            if item.Name == foodName then
                pcall(function()
                    ReplicatedStorage.RemoteEvents.RequestConsumeItem:InvokeServer(item)
                end)
                return true
            end
        end
    end
    return false
end

TabCombat:CreateToggle({
    Name = "Auto Feed",
    Info = "Automatically eat food when hungry",
    CurrentValue = false,
    Flag = "AutoFeed",
    Callback = function(value)
        autoFeedEnabled = value
        if value then
            task.spawn(function()
                while autoFeedEnabled do
                    if getHungerLevel() <= feedHungerThreshold then
                        if not feedPlayer() then
                            task.wait(5) -- Wait longer if no food found
                        end
                    end
                    task.wait(3)
                end
            end)
        end
    end
})

TabCombat:CreateSlider({
    Name = "Feed Threshold",
    Info = "Hunger percentage to trigger auto feed",
    Range = {10, 90},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 75,
    Flag = "FeedThreshold",
    Callback = function(value)
        feedHungerThreshold = value
    end
})

-- 👁️ Visual & Teleport Tab
local TabVisual = Window:CreateTab("Visual & Teleport")
TabVisual:CreateLabel("Visual Modifications & Teleportation", nil)

-- Brightness Boost
local brightnessEnabled = false
local originalBrightness = Lighting.Brightness

TabVisual:CreateToggle({
    Name = "Brightness Boost",
    Info = "Increase game brightness",
    CurrentValue = false,
    Flag = "BrightnessBoost",
    Callback = function(value)
        brightnessEnabled = value
        if value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
        else
            Lighting.Brightness = originalBrightness
        end
    end
})

-- Fullbright
local fullbrightEnabled = false

TabVisual:CreateToggle({
    Name = "Fullbright",
    Info = "Maximum visibility",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(value)
        fullbrightEnabled = value
        if value then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.GlobalShadows = true
        end
    end
})

-- Remove Fog
TabVisual:CreateToggle({
    Name = "Remove Fog",
    Info = "Remove fog for better visibility",
    CurrentValue = false,
    Flag = "RemoveFog",
    Callback = function(value)
        if value then
            Lighting:SetAttribute("FogStartOriginal", Lighting.FogStart)
            Lighting:SetAttribute("FogEndOriginal", Lighting.FogEnd)
            Lighting:SetAttribute("FogColorOriginal", Lighting.FogColor)
            
            Lighting.FogStart = 1e10
            Lighting.FogEnd = 1e10
            Lighting.FogColor = Color3.new(1, 1, 1)
        else
            local fogStart = Lighting:GetAttribute("FogStartOriginal") or 0
            local fogEnd = Lighting:GetAttribute("FogEndOriginal") or 100000
            local fogColor = Lighting:GetAttribute("FogColorOriginal") or Color3.new(1, 1, 1)

            Lighting.FogStart = fogStart
            Lighting.FogEnd = fogEnd
            Lighting.FogColor = fogColor
        end
    end
})

-- FOV Changer
local fovEnabled = false
local currentFOV = 70
local fovConnection = nil

local fovToggle = TabVisual:CreateToggle({
    Name = "FOV Changer",
    Info = "Enable custom field of view",
    CurrentValue = false,
    Flag = "FOVChanger",
    Callback = function(value)
        fovEnabled = value
        
        if fovConnection then
            fovConnection:Disconnect()
            fovConnection = nil
        end
        
        if value then
            fovConnection = RunService.RenderStepped:Connect(function()
                if workspace.CurrentCamera then
                    workspace.CurrentCamera.FieldOfView = currentFOV
                end
            end)
        elseif workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = 70
        end
    end
})

local fovSlider = TabVisual:CreateSlider({
    Name = "FOV Value",
    Info = "Adjust field of view",
    Range = {70, 120},
    Increment = 1,
    Suffix = " FOV",
    CurrentValue = 70,
    Flag = "FOVValue",
    Callback = function(value)
        currentFOV = value
        if fovEnabled and workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = value
        end
    end
})

-- Teleport Waypoints
local waypoints = {
    ["Bonfire/Camp"] = CFrame.new(0.32, 6.15, -0.22),
    ["Safe Zone"] = CFrame.new(0, 110, 0),
    ["Stronghold"] = CFrame.new(0, 15, 0)
}

TabVisual:CreateLabel("Quick Teleports", nil)

for name, cf in pairs(waypoints) do
    TabVisual:CreateButton({
        Name = "Teleport to " .. name,
        Info = "Teleport to " .. name .. " location",
        Interact = "Press",
        Callback = function()
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = cf
            end
        end
    })
end

-- Teleport to Stronghold (Advanced)
TabVisual:CreateButton({
    Name = "Teleport to Stronghold Entrance",
    Info = "Teleport to stronghold main entrance",
    Interact = "Press",
    Callback = function()
        local targetPart = workspace:FindFirstChild("Map") and
                          workspace.Map:FindFirstChild("Landmarks") and
                          workspace.Map.Landmarks:FindFirstChild("Stronghold") and
                          workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional") and
                          workspace.Map.Landmarks.Stronghold.Functional:FindFirstChild("EntryDoors") and
                          workspace.Map.Landmarks.Stronghold.Functional.EntryDoors:FindFirstChild("DoorRight") and
                          workspace.Map.Landmarks.Stronghold.Functional.EntryDoors.DoorRight:FindFirstChild("Model")
        
        if targetPart and character and character:FindFirstChild("HumanoidRootPart") then
            local children = targetPart:GetChildren()
            if children[5] and children[5]:IsA("BasePart") then
                character.HumanoidRootPart.CFrame = children[5].CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
})

-- Teleport to Diamond Chest
TabVisual:CreateButton({
    Name = "Teleport to Diamond Chest",
    Info = "Teleport to stronghold diamond chest",
    Interact = "Press",
    Callback = function()
        local chest = workspace:FindFirstChild("Items") and workspace.Items:FindFirstChild("Stronghold Diamond Chest")
        if chest and character and character:FindFirstChild("HumanoidRootPart") then
            local chestLid = chest:FindFirstChild("ChestLid")
            if chestLid then
                local diamondchest = chestLid:FindFirstChild("Meshes/diamondchest_Cube.002")
                if diamondchest then
                    character.HumanoidRootPart.CFrame = diamondchest.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
})

-- Teleport to UFO
TabVisual:CreateButton({
    Name = "Teleport to UFO",
    Info = "Teleport to alien UFO",
    Interact = "Press",
    Callback = function()
        local ufo = workspace:FindFirstChild("Items") and workspace.Items:FindFirstChild("Alien Chest")
        if ufo and character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(ufo.Main.CFrame.Position + Vector3.new(0, 10, 0))
        end
    end
})

-- Teleport to Specific Items
TabVisual:CreateLabel("Item Teleports", nil)

local function teleportToItem(itemName)
    local closest, shortest = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == itemName and obj:IsA("Model") then
            local dist = (obj:GetPivot().Position - Vector3.new(0, 0, 0)).Magnitude
            if dist >= 50 and dist < shortest then
                closest = obj
                shortest = dist
            end
        end
    end
    if closest and character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = closest:GetPivot() + Vector3.new(0, 5, 0)
    end
end

local priorityItems = {"Alien Chest", "Stronghold Diamond Chest", "Raygun", "Laser Sword", "Good Axe", "Strong Axe"}

for _, itemName in ipairs(priorityItems) do
    TabVisual:CreateButton({
        Name = "TP to " .. itemName,
        Info = "Teleport to nearest " .. itemName,
        Interact = "Press",
        Callback = function()
            teleportToItem(itemName)
        end
    })
end

-- 🔧 Automation Tab
local TabAuto = Window:CreateTab("Automation")
TabAuto:CreateLabel("Automated Farming & Processing", nil)

-- Auto-farming variables
local campfireDropPos = Vector3.new(0, 19, 0)
local machineDropPos = Vector3.new(21, 16, -5)

local campfireFuelItems = {"Log", "Coal", "Fuel Canister", "Oil Barrel", "Biofuel"}
local autocookItems = {"Morsel", "Steak"}
local autoGrindItems = {"UFO Junk", "UFO Component", "Old Car Engine", "Broken Fan", "Old Microwave", "Bolt", "Sheet Metal", "Old Radio", "Tyre", "Washing Machine"}

local autoFuelEnabled = false
local autoCookEnabled = false
local autoGrindEnabled = false
local autoBiofuelEnabled = false

-- Move item function
local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(workspace) then return end
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
    if not part then return end

    if not item.PrimaryPart then
        pcall(function() item.PrimaryPart = part end)
    end

    pcall(function()
        ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
        task.wait(0.05)
        item:SetPrimaryPartCFrame(CFrame.new(position))
        task.wait(0.05)
        ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
    end)
end

-- Auto Feed Campfire
TabAuto:CreateToggle({
    Name = "Auto Feed Campfire",
    Info = "Automatically feed fuel to campfire",
    CurrentValue = false,
    Flag = "AutoFuel",
    Callback = function(value)
        autoFuelEnabled = value
        if value then
            task.spawn(function()
                while autoFuelEnabled do
                    for _, itemName in ipairs(campfireFuelItems) do
                        for _, item in ipairs(workspace:FindFirstChild("Items") and workspace.Items:GetChildren() or {}) do
                            if item.Name == itemName then
                                moveItemToPos(item, campfireDropPos)
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

-- Auto Cook Food
TabAuto:CreateToggle({
    Name = "Auto Cook Food",
    Info = "Automatically cook raw meat",
    CurrentValue = false,
    Flag = "AutoCook",
    Callback = function(value)
        autoCookEnabled = value
        if value then
            task.spawn(function()
                while autoCookEnabled do
                    for _, itemName in ipairs(autocookItems) do
                        for _, item in ipairs(workspace:FindFirstChild("Items") and workspace.Items:GetChildren() or {}) do
                            if item.Name == itemName then
                                moveItemToPos(item, campfireDropPos)
                            end
                        end
                    end
                    task.wait(2.5)
                end
            end)
        end
    end
})

-- Auto Grind Items
TabAuto:CreateToggle({
    Name = "Auto Grind Items",
    Info = "Automatically grind items in machine",
    CurrentValue = false,
    Flag = "AutoGrind",
    Callback = function(value)
        autoGrindEnabled = value
        if value then
            task.spawn(function()
                while autoGrindEnabled do
                    for _, itemName in ipairs(autoGrindItems) do
                        for _, item in ipairs(workspace:FindFirstChild("Items") and workspace.Items:GetChildren() or {}) do
                            if item.Name == itemName then
                                moveItemToPos(item, machineDropPos)
                            end
                        end
                    end
                    task.wait(2.5)
                end
            end)
        end
    end
})

-- Auto Biofuel Processing
TabAuto:CreateToggle({
    Name = "Auto Biofuel Processing",
    Info = "Automatically process items into biofuel",
    CurrentValue = false,
    Flag = "AutoBiofuel",
    Callback = function(value)
        autoBiofuelEnabled = value
        if value then
            task.spawn(function()
                while autoBiofuelEnabled do
                    local processor = workspace:FindFirstChild("Structures") and workspace.Structures:FindFirstChild("Biofuel Processor")
                    if processor then
                        local part = processor:FindFirstChild("Part")
                        if part then
                            local biofuelPos = part.Position + Vector3.new(0, 5, 0)
                            local biofuelItems = {"Carrot", "Cooked Morsel", "Morsel", "Steak", "Cooked Steak", "Log"}
                            for _, itemName in ipairs(biofuelItems) do
                                for _, item in ipairs(workspace:FindFirstChild("Items") and workspace.Items:GetChildren() or {}) do
                                    if item.Name == itemName then
                                        moveItemToPos(item, biofuelPos)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

-- Auto Collect System
local autoCollectEnabled = false
local collectRadius = 100

TabAuto:CreateToggle({
    Name = "Auto Collect Items",
    Info = "Automatically collect nearby items",
    CurrentValue = false,
    Flag = "AutoCollect",
    Callback = function(value)
        autoCollectEnabled = value
        if value then
            task.spawn(function()
                while autoCollectEnabled do
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local hrp = character.HumanoidRootPart
                        for _, item in ipairs(workspace:FindFirstChild("Items") and workspace.Items:GetChildren() or {}) do
                            if item:IsA("Model") then
                                local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                                if part and (part.Position - hrp.Position).Magnitude <= collectRadius then
                                    moveItemToPos(item, hrp.Position + Vector3.new(0, 2, 0))
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

TabAuto:CreateSlider({
    Name = "Collect Radius",
    Info = "Set radius for auto collect",
    Range = {50, 300},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 100,
    Flag = "CollectRadius",
    Callback = function(value)
        collectRadius = value
    end
})

-- Tree Bring System
local treesBrought = false
local originalTreeCFrames = {}

local function getAllSmallTrees()
    local trees = {}
    local function scan(folder)
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj.Name == "Small Tree" then
                table.insert(trees, obj)
            end
        end
    end

    local map = workspace:FindFirstChild("Map")
    if map then
        if map:FindFirstChild("Foliage") then scan(map.Foliage) end
        if map:FindFirstChild("Landmarks") then scan(map.Landmarks) end
    end
    return trees
end

local function findTrunk(tree)
    for _, part in ipairs(tree:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Trunk" then return part end
    end
end

local function bringAllTrees()
    if character and character:FindFirstChild("HumanoidRootPart") then
        local target = CFrame.new(character.HumanoidRootPart.Position + character.HumanoidRootPart.CFrame.LookVector * 10)
        for _, tree in ipairs(getAllSmallTrees()) do
            local trunk = findTrunk(tree)
            if trunk then
                if not originalTreeCFrames[tree] then originalTreeCFrames[tree] = trunk.CFrame end
                tree.PrimaryPart = trunk
                trunk.Anchored = false
                trunk.CanCollide = false
                task.wait()
                tree:SetPrimaryPartCFrame(target + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
                trunk.Anchored = true
            end
        end
        treesBrought = true
    end
end

local function restoreTrees()
    for tree, cframe in pairs(originalTreeCFrames) do
        local trunk = findTrunk(tree)
        if trunk then
            tree.PrimaryPart = trunk
            tree:SetPrimaryPartCFrame(cframe)
            trunk.Anchored = true
            trunk.CanCollide = true
        end
    end
    originalTreeCFrames = {}
    treesBrought = false
end

TabAuto:CreateToggle({
    Name = "Bring All Small Trees",
    Info = "Bring all small trees to your location",
    CurrentValue = false,
    Flag = "BringTrees",
    Callback = function(value)
        if value and not treesBrought then
            bringAllTrees()
        elseif not value and treesBrought then
            restoreTrees()
        end
    end
})

-- Stronghold Timer Display
local function getStrongholdTimerLabel()
    return workspace:FindFirstChild("Map") and
           workspace.Map:FindFirstChild("Landmarks") and
           workspace.Map.Landmarks:FindFirstChild("Stronghold") and
           workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional") and
           workspace.Map.Landmarks.Stronghold.Functional:FindFirstChild("Sign") and
           workspace.Map.Landmarks.Stronghold.Functional.Sign:FindFirstChild("SurfaceGui") and
           workspace.Map.Landmarks.Stronghold.Functional.Sign.SurfaceGui:FindFirstChild("Frame") and
           workspace.Map.Landmarks.Stronghold.Functional.Sign.SurfaceGui.Frame:FindFirstChild("Body")
end

local initialLabel = getStrongholdTimerLabel()
local initialText = "Stronghold Timer: " .. tostring(initialLabel and initialLabel.ContentText or "N/A")

TabAuto:CreateLabel(initialText, nil)

-- Update stronghold timer (this would need to be updated in a loop)
task.spawn(function()
    while true do
        local label = getStrongholdTimerLabel()
        local timerText = "Stronghold Timer: " .. tostring(label and label.ContentText or "N/A")
        -- Note: The label update would need to be handled differently in SoulsHub
        task.wait(1)
    end
end)

-- Safe Zone Creation
local safezoneBaseplates = {}
local baseplateSize = Vector3.new(2048, 1, 2048)
local baseY = 100
local centerPos = Vector3.new(0, baseY, 0)

local function createSafeZone()
    for dx = -1, 1 do
        for dz = -1, 1 do
            local pos = centerPos + Vector3.new(dx * baseplateSize.X, 0, dz * baseplateSize.Z)
            local baseplate = Instance.new("Part")
            baseplate.Name = "SafeZoneBaseplate"
            baseplate.Size = baseplateSize
            baseplate.Position = pos
            baseplate.Anchored = true
            baseplate.CanCollide = true
            baseplate.Transparency = 0.8
            baseplate.Color = Color3.fromRGB(255, 255, 255)
            baseplate.Parent = workspace
            table.insert(safezoneBaseplates, baseplate)
        end
    end
end

local function removeSafeZone()
    for _, baseplate in ipairs(safezoneBaseplates) do
        if baseplate then
            baseplate:Destroy()
        end
    end
    safezoneBaseplates = {}
end

TabAuto:CreateToggle({
    Name = "Create Safe Zone",
    Info = "Create a safe zone platform in the sky",
    CurrentValue = false,
    Flag = "SafeZone",
    Callback = function(value)
        if value then
            createSafeZone()
        else
            removeSafeZone()
        end
    end
})

-- Extra Scripts
TabAuto:CreateLabel("Extra Utilities", nil)

TabAuto:CreateButton({
    Name = "Load Infinite Yield",
    Info = "Load Infinite Yield admin commands",
    Interact = "Press",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

TabAuto:CreateButton({
    Name = "Anti AFK",
    Info = "Prevent getting kicked for being AFK",
    Interact = "Press",
    Callback = function()
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Anti AFK",
            Text = "Anti AFK is now active!",
            Duration = 3
        })
    end
})

-- Cleanup on script termination
LocalPlayer.AncestryChanged:Connect(function()
    -- Cleanup connections
    if teleportConnection then teleportConnection:Disconnect() end
    if jumpConnection then jumpConnection:Disconnect() end
    if speedConnection then speedConnection:Disconnect() end
    if noclipConnection then noclipConnection:Disconnect() end
    if noAggroConnection then noAggroConnection:Disconnect() end
    if fovConnection then fovConnection:Disconnect() end
    if flyConnection then flyConnection:Disconnect() end
    
    -- Reset visual changes
    Lighting.Brightness = originalBrightness
    Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    Lighting.GlobalShadows = true
    
    if workspace.CurrentCamera then
        workspace.CurrentCamera.FieldOfView = 70
    end
    
    if humanoid then
        humanoid.WalkSpeed = 16
    end
    
    -- Clean up safe zone
    removeSafeZone()
    
    -- Restore trees
    if treesBrought then
        restoreTrees()
    end
end)

-- Set main tab as default visible
TabMain.Content.Visible = true

-- Completion notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Souls Hub Complete",
    Text = "99 Nights script loaded successfully!",
    Duration = 5
})