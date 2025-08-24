local SoulsHub = loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/e7f388d3c065df7a"))();

task.wait(1)

SoulsHub:Loader(nil , 1).yield()

local Window = SoulsHub.new({
	Keybind = "V",
});

local watermark = Window:Watermark();

watermark:AddText({
	Icon = "zap",
	Text = "Souls Hub | 99 Nights in Forest"
})

local vim = watermark:AddText({
	Icon = "clock",
	Text = SoulsHub:GetTimeNow()
})

task.spawn(function()
	while true do task.wait()
		vim:SetText(SoulsHub:GetTimeNow())
		Window.Username =  "User"
	end;
end)

local Combat = Window:DrawTab({
	Icon = "sword",
	Name = "Combat",
	Type = "Double"
});

local Main = Window:DrawTab({
	Icon = "align-left",
	Name = "Main"
});

local Auto = Window:DrawTab({
	Icon = "wrench",
	Name = "Auto"
});

local Esp = Window:DrawTab({
	Icon = "sparkles",
	Name = "Esp"
});

local Bring = Window:DrawTab({
	Icon = "package",
	Name = "Bring"
});

local Teleport = Window:DrawTab({
	Icon = "map",
	Name = "Teleport"
});

local Player = Window:DrawTab({
	Icon = "user",
	Name = "Player"
});

local Environment = Window:DrawTab({
	Icon = "eye",
	Name = "Environment"
});

local Information = Window:DrawTab({
	Icon = "badge-info",
	Name = "Information"
});

Window:DrawCategory({
	Name = "Visual"
})

Window:DrawCategory({
	Name = "Misc"
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if not getgenv().TransparencyEnabled then
    getgenv().TransparencyEnabled = false
end

-- combat

local killAuraToggle = false
local chopAuraToggle = false
local auraRadius = 50
local currentammount = 0

local toolsDamageIDs = {
    ["Old Axe"] = "3_7367831688",
    ["Good Axe"] = "112_7367831688",
    ["Strong Axe"] = "116_7367831688",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016"
}

-- auto food

local autoFeedToggle = false
local selectedFood = {}
local hungerThreshold = 75
local alwaysFeedEnabledItems = {}
local alimentos = {
    "Apple",
    "Berry",
    "Carrot",
    "Cake",
    "Chili",
    "Cooked Morsel",
    "Cooked Steak"
}

-- esp

local ie = {
    "Bandage", "Bolt", "Broken Fan", "Broken Microwave", "Cake", "Carrot", "Chair", "Coal", "Coin Stack",
    "Cooked Morsel", "Cooked Steak", "Fuel Canister", "Iron Body", "Leather Armor", "Log", "MadKit", "Metal Chair",
    "MedKit", "Old Car Engine", "Old Flashlight", "Old Radio", "Revolver", "Revolver Ammo", "Rifle", "Rifle Ammo",
    "Morsel", "Sheet Metal", "Steak", "Tyre", "Washing Machine"
}
local me = {"Bunny", "Wolf", "Alpha Wolf", "Bear", "Cultist", "Crossbow Cultist", "Alien"}

-- bring

 local junkItems = {"Tyre", "Bolt", "Broken Fan", "Broken Microwave", "Sheet Metal", "Old Radio", "Washing Machine", "Old Car Engine"}
local selectedJunkItems = {}
local fuelItems = {"Log", "Chair", "Coal", "Fuel Canister", "Oil Barrel"}
local selectedFuelItems = {}
local foodItems = {"Cake", "Cooked Steak", "Cooked Morsel", "Steak", "Morsel", "Berry", "Carrot"}
local selectedFoodItems = {}
local medicalItems = {"Bandage", "MedKit"}
local selectedMedicalItems = {}
local equipmentItems = {"Revolver", "Rifle", "Leather Body", "Iron Body", "Revolver Ammo", "Rifle Ammo", "Giant Sack", "Good Sack", "Strong Axe", "Good Axe"}
local selectedEquipmentItems = {}

local isCollecting = false
local originalPosition = nil
local autoBringEnabled = false

-- Toggle states for each category
local junkToggleEnabled = false
local fuelToggleEnabled = false
local foodToggleEnabled = false
local medicalToggleEnabled = false
local equipmentToggleEnabled = false

-- Loop control variables to properly stop threads
local junkLoopRunning = false
local fuelLoopRunning = false
local foodLoopRunning = false
local medicalLoopRunning = false
local equipmentLoopRunning = false

-- Enhanced smooth pulling movement with easing
local function smoothPullToItem(startPos, endPos, duration)
    local player = game.Players.LocalPlayer
    local hrp = player.Character.HumanoidRootPart
    
    local startTime = tick()
    local distance = (endPos.Position - startPos.Position).Magnitude
    local direction = (endPos.Position - startPos.Position).Unit
    
    -- Create smooth pulling effect with easing
    spawn(function()
        while tick() - startTime < duration do
            local elapsed = tick() - startTime
            local progress = elapsed / duration
            
            -- Ease-in-out function for smooth acceleration and deceleration
            local easedProgress = progress < 0.5 
                and 2 * progress * progress 
                or 1 - math.pow(-2 * progress + 2, 2) / 2
            
            local currentPos = startPos.Position:lerp(endPos.Position, easedProgress)
            local lookDirection = endPos.Position - currentPos
            
            if lookDirection.Magnitude > 0 then
                hrp.CFrame = CFrame.lookAt(currentPos, currentPos + lookDirection.Unit)
            else
                hrp.CFrame = CFrame.new(currentPos)
            end
            
            wait()
        end
        
        -- Ensure exact final position
        hrp.CFrame = endPos
    end)
    
    wait(duration)
end

-- Enhanced item pulling effect
local function createItemPullEffect(itemPart, targetPos, duration)
    if not itemPart or not itemPart.Parent then return end
    
    local startPos = itemPart.Position
    local startTime = tick()
    
    spawn(function()
        while tick() - startTime < duration do
            if not itemPart or not itemPart.Parent then break end
            
            local elapsed = tick() - startTime
            local progress = elapsed / duration
            
            -- Ease-out effect for item pulling
            local easedProgress = 1 - math.pow(1 - progress, 3)
            
            local currentPos = Vector3.new(
                startPos.X + (targetPos.X - startPos.X) * easedProgress,
                startPos.Y + (targetPos.Y - startPos.Y) * easedProgress,
                startPos.Z + (targetPos.Z - startPos.Z) * easedProgress
            )
            
            pcall(function()
                itemPart.CFrame = CFrame.new(currentPos)
                itemPart.Velocity = Vector3.new(0, 0, 0)
                itemPart.AngularVelocity = Vector3.new(0, 0, 0)
            end)
            
            wait()
        end
        
        -- Final position
        pcall(function()
            itemPart.CFrame = CFrame.new(targetPos)
            itemPart.Velocity = Vector3.new(0, 0, 0)
            itemPart.AngularVelocity = Vector3.new(0, 0, 0)
        end)
    end)
    
    wait(duration)
end

-- Enhanced bypass system with smooth pulling (no noclip)
local function bypassBringSystem(items, stopFlag)
    if isCollecting then 
        return 
    end
    
    isCollecting = true
    local player = game.Players.LocalPlayer
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
        isCollecting = false
        return 
    end
    
    local hrp = player.Character.HumanoidRootPart
    originalPosition = hrp.CFrame
    
    for _, itemName in ipairs(items) do
        -- Check if we should stop
        if stopFlag and not stopFlag() then
            break
        end
        
        local itemsFound = {}
        
        -- Find all items with this name
        for _, item in ipairs(workspace:GetDescendants()) do
            if item.Name == itemName and (item:IsA("BasePart") or item:IsA("Model")) then
                local itemPart = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                if itemPart and itemPart.Parent ~= player.Character then
                    table.insert(itemsFound, {item = item, part = itemPart})
                end
            end
        end
        
        -- Process each found item
        for _, itemData in ipairs(itemsFound) do
            -- Check if we should stop again
            if stopFlag and not stopFlag() then
                break
            end
            
            local item = itemData.item
            local itemPart = itemData.part
            
            if itemPart and itemPart.Parent then
                -- Step 1: Smooth pull to item location with anticipation
                local itemPos = itemPart.CFrame + Vector3.new(0, 5, 0)
                smoothPullToItem(hrp.CFrame, itemPos, 1.2) -- Smooth 1.2 second pull
                
                -- Step 2: Create magnetic pull effect for item
                local playerPos = hrp.Position + Vector3.new(0, -1, 0)
                createItemPullEffect(itemPart, playerPos, 0.8)
                
                -- Step 3: Smooth return journey with item following
                local keepAttached = true
                spawn(function()
                    while keepAttached do
                        if stopFlag and not stopFlag() then
                            keepAttached = false
                            break
                        end
                        
                        if itemPart and itemPart.Parent and hrp and hrp.Parent then
                            pcall(function()
                                local offset = Vector3.new(
                                    math.sin(tick() * 2) * 0.5, -- Slight floating motion
                                    -1 + math.cos(tick() * 3) * 0.2,
                                    math.cos(tick() * 2) * 0.5
                                )
                                itemPart.CFrame = CFrame.new(hrp.Position + offset)
                                itemPart.Velocity = Vector3.new(0, 0, 0)
                                itemPart.AngularVelocity = Vector3.new(0, 0, 0)
                            end)
                        end
                        wait(0.03)
                    end
                end)
                
                -- Smooth return to original position
                smoothPullToItem(hrp.CFrame, originalPosition, 1.0)
                
                -- Stop attachment and place item nearby with gentle landing
                keepAttached = false
                wait(0.1)
                
                pcall(function()
                    local landingPos = originalPosition.Position + Vector3.new(
                        math.random(-4, 4), 
                        2, 
                        math.random(-4, 4)
                    )
                    
                    -- Gentle item placement
                    createItemPullEffect(itemPart, landingPos, 0.5)
                end)
            end
            
            wait(0.5) -- Pause between items
        end
    end
    
    -- Ensure player is at original position
    if originalPosition then
        hrp.CFrame = originalPosition
    end
    
    isCollecting = false
end

-- auto upgrade campfire

local campfireFuelItems = {"Log", "Coal", "Chair", "Fuel Canister", "Oil Barrel", "Biofuel"}
local campfireDropPos = Vector3.new(0, 19, 0)
local selectedCampfireItem = nil -- Single item storage
local autoUpgradeCampfireEnabled = false

-- Added New
local scrapjunkItems = {"Log", "Chair", "Tyre", "Bolt", "Broken Fan", "Broken Microwave", "Sheet Metal", "Old Radio", "Washing Machine", "Old Car Engine"}
local autoScrapPos = Vector3.new(21, 20, -5)
local selectedScrapItem = nil
local autoScrapItemsEnabled = false
-- auto cook

local autocookItems = {"Morsel", "Steak", "Elvis Steak"}
local autoCookEnabledItems = {}
local autoCookEnabled = false

local function getAnyToolWithDamageID(isChopAura)
    for toolName, damageID in pairs(toolsDamageIDs) do
        if isChopAura and toolName ~= "Old Axe" and toolName ~= "Good Axe" and toolName ~= "Strong Axe" then
            continue
        end
        local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil, nil
end

local function equipTool(tool)
    if tool then
        ReplicatedStorage:WaitForChild("RemoteEvents").EquipItemHandle:FireServer("FireAllClients", tool)
    end
end

local function unequipTool(tool)
    if tool then
        ReplicatedStorage:WaitForChild("RemoteEvents").UnequipItemHandle:FireServer("FireAllClients", tool)
    end
end

local function killAuraLoop()
    while killAuraToggle do
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tool, damageID = getAnyToolWithDamageID(false)
            if tool and damageID then
                equipTool(tool)
                for _, mob in ipairs(Workspace.Characters:GetChildren()) do
                    if mob:IsA("Model") then
                        local part = mob:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude <= auraRadius then
                            pcall(function()
                                ReplicatedStorage:WaitForChild("RemoteEvents").ToolDamageObject:InvokeServer(
                                    mob,
                                    tool,
                                    damageID,
                                    CFrame.new(part.Position)
                                )
                            end)
                        end
                    end
                end
                task.wait(0.1)
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end

local function chopAuraLoop()
    while chopAuraToggle do
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tool, baseDamageID = getAnyToolWithDamageID(true)
            if tool and baseDamageID then
                equipTool(tool)
                currentammount = currentammount + 1
                local trees = {}
                local map = Workspace:FindFirstChild("Map")
                if map then
                    if map:FindFirstChild("Foliage") then
                        for _, obj in ipairs(map.Foliage:GetChildren()) do
                            if obj:IsA("Model") and obj.Name == "Small Tree" then
                                table.insert(trees, obj)
                            end
                        end
                    end
                    if map:FindFirstChild("Landmarks") then
                        for _, obj in ipairs(map.Landmarks:GetChildren()) do
                            if obj:IsA("Model") and obj.Name == "Small Tree" then
                                table.insert(trees, obj)
                            end
                        end
                    end
                end
                for _, tree in ipairs(trees) do
                    local trunk = tree:FindFirstChild("Trunk")
                    if trunk and trunk:IsA("BasePart") and (trunk.Position - hrp.Position).Magnitude <= auraRadius then
                        local alreadyammount = false
                        task.spawn(function()
                            while chopAuraToggle and tree and tree.Parent and not alreadyammount do
                                alreadyammount = true
                                currentammount = currentammount + 1
                                pcall(function()
                                    ReplicatedStorage:WaitForChild("RemoteEvents").ToolDamageObject:InvokeServer(
                                        tree,
                                        tool,
                                        tostring(currentammount) .. "_7367831688",
                                        CFrame.new(-2.962610244751, 4.5547881126404, -75.950843811035, 0.89621275663376, -1.3894891459643e-08, 0.44362446665764, -7.994568895775e-10, 1, 3.293635941759e-08, -0.44362446665764, -2.9872644802253e-08, 0.89621275663376)
                                    )
                                end)
                                task.wait(0.5)
                            end
                        end)
                    end
                end
                task.wait(0.1)
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end

function wiki(nome)
    local c = 0
    for _, i in ipairs(Workspace.Items:GetChildren()) do
        if i.Name == nome then
            c = c + 1
        end
    end
    return c
end

function ghn()
    return math.floor(LocalPlayer.PlayerGui.Interface.StatBars.HungerBar.Bar.Size.X.Scale * 100)
end

function feed(nome)
    for _, item in ipairs(Workspace.Items:GetChildren()) do
        if item.Name == nome then
            ReplicatedStorage.RemoteEvents.RequestConsumeItem:InvokeServer(item)
            break
        end
    end
end

function notifeed(nome)
    print("Auto Food Paused: The food is gone")
end

local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(workspace) or not item:IsA("BasePart") and not item:IsA("Model") then return end
    local part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")) or item
    if not part or not part:IsA("BasePart") then return end

    if item:IsA("Model") and not item.PrimaryPart then
        pcall(function() item.PrimaryPart = part end)
    end

    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents").RequestStartDraggingItem:FireServer(item)
        if item:IsA("Model") then
            item:SetPrimaryPartCFrame(CFrame.new(position))
        else
            part.CFrame = CFrame.new(position)
        end
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents").StopDraggingItem:FireServer(item)
    end)
end

local function getChests()
    local chests = {}
    local chestNames = {}
    local index = 1
    for _, item in ipairs(workspace:WaitForChild("Items"):GetChildren()) do
        if item.Name:match("^Item Chest") and not item:GetAttribute("8721081708ed") then
            table.insert(chests, item)
            table.insert(chestNames, "Chest " .. index)
            index = index + 1
        end
    end
    return chests, chestNames
end

local currentChests, currentChestNames = getChests()
local selectedChest = currentChestNames[1] or nil

local function getMobs()
    local mobs = {}
    local mobNames = {}
    local index = 1
    for _, character in ipairs(workspace:WaitForChild("Characters"):GetChildren()) do
        if character.Name:match("^Lost Child") and character:GetAttribute("Lost") == true then
            table.insert(mobs, character)
            table.insert(mobNames, character.Name)
            index = index + 1
        end
    end
    return mobs, mobNames
end

local currentMobs, currentMobNames = getMobs()
local selectedMob = currentMobNames[1] or nil

function tp1()
	(game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart").CFrame =
CFrame.new(0.43132782, 15.77634621, -1.88620758, -0.270917892, 0.102997094, 0.957076371, 0.639657021, 0.762253821, 0.0990355015, -0.719334781, 0.639031112, -0.272391081)
end

local function tp2()
    local targetPart = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Landmarks")
        and workspace.Map.Landmarks:FindFirstChild("Stronghold")
        and workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional")
        and workspace.Map.Landmarks.Stronghold.Functional:FindFirstChild("EntryDoors")
        and workspace.Map.Landmarks.Stronghold.Functional.EntryDoors:FindFirstChild("DoorRight")
        and workspace.Map.Landmarks.Stronghold.Functional.EntryDoors.DoorRight:FindFirstChild("Model")
    if targetPart then
        local children = targetPart:GetChildren()
        local destination = children[5]
        if destination and destination:IsA("BasePart") then
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = destination.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
end

local flyToggle = false
local flySpeed = 1
local FLYING = false
local flyKeyDown, flyKeyUp, mfly1, mfly2
local IYMouse = game:GetService("UserInputService")

-- Fly pc
local function sFLY()
    repeat task.wait() until Players.LocalPlayer and Players.LocalPlayer.Character and Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart") and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    repeat task.wait() until IYMouse
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect(); flyKeyUp:Disconnect() end

    local T = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = flySpeed

    local function FLY()
        FLYING = true
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = T.CFrame
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while FLYING do
                task.wait()
                if not flyToggle and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                    Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                end
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = flySpeed
                elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                    SPEED = 0
                end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = workspace.CurrentCamera.CoordinateFrame
            end
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()
            if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end
    flyKeyDown = IYMouse.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local KEY = input.KeyCode.Name
            if KEY == "W" then
                CONTROL.F = flySpeed
            elseif KEY == "S" then
                CONTROL.B = -flySpeed
            elseif KEY == "A" then
                CONTROL.L = -flySpeed
            elseif KEY == "D" then 
                CONTROL.R = flySpeed
            elseif KEY == "E" then
                CONTROL.Q = flySpeed * 2
            elseif KEY == "Q" then
                CONTROL.E = -flySpeed * 2
            end
            pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
        end
    end)
    flyKeyUp = IYMouse.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local KEY = input.KeyCode.Name
            if KEY == "W" then
                CONTROL.F = 0
            elseif KEY == "S" then
                CONTROL.B = 0
            elseif KEY == "A" then
                CONTROL.L = 0
            elseif KEY == "D" then
                CONTROL.R = 0
            elseif KEY == "E" then
                CONTROL.Q = 0
            elseif KEY == "Q" then
                CONTROL.E = 0
            end
        end
    end)
    FLY()
end

-- Fly mobile
local function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
    if mfly1 then mfly1:Disconnect() end
    if mfly2 then mfly2:Disconnect() end
    if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local function UnMobileFly()
    pcall(function()
        FLYING = false
        local root = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        if root:FindFirstChild("BodyVelocity") then root:FindFirstChild("BodyVelocity"):Destroy() end
        if root:FindFirstChild("BodyGyro") then root:FindFirstChild("BodyGyro"):Destroy() end
        if Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
            Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
        end
        if mfly1 then mfly1:Disconnect() end
        if mfly2 then mfly2:Disconnect() end
    end)
end

local function MobileFly()
    UnMobileFly()
    FLYING = true

    local root = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    local v3none = Vector3.new()
    local v3zero = Vector3.new(0, 0, 0)
    local v3inf = Vector3.new(9e9, 9e9, 9e9)

    local controlModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local bv = Instance.new("BodyVelocity")
    bv.Name = "BodyVelocity"
    bv.Parent = root
    bv.MaxForce = v3zero
    bv.Velocity = v3zero

    local bg = Instance.new("BodyGyro")
    bg.Name = "BodyGyro"
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50

    mfly1 = Players.LocalPlayer.CharacterAdded:Connect(function()
        local newRoot = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        local newBv = Instance.new("BodyVelocity")
        newBv.Name = "BodyVelocity"
        newBv.Parent = newRoot
        newBv.MaxForce = v3zero
        newBv.Velocity = v3zero

        local newBg = Instance.new("BodyGyro")
        newBg.Name = "BodyGyro"
        newBg.Parent = newRoot
        newBg.MaxTorque = v3inf
        newBg.P = 1000
        newBg.D = 50
    end)

    mfly2 = game:GetService("RunService").RenderStepped:Connect(function()
        root = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        camera = workspace.CurrentCamera
        if Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild("BodyVelocity") and root:FindFirstChild("BodyGyro") then
            local humanoid = Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            local VelocityHandler = root:FindFirstChild("BodyVelocity")
            local GyroHandler = root:FindFirstChild("BodyGyro")

            VelocityHandler.MaxForce = v3inf
            GyroHandler.MaxTorque = v3inf
            humanoid.PlatformStand = true
            GyroHandler.CFrame = camera.CoordinateFrame
            VelocityHandler.Velocity = v3none

            local direction = controlModule:GetMoveVector()
            if direction.X > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * (flySpeed * 50))
            end
            if direction.X < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * (flySpeed * 50))
            end
            if direction.Z > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * (flySpeed * 50))
            end
            if direction.Z < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * (flySpeed * 50))
            end
        end
    end)
end

-- Player TP to Items Bring System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Function to teleport player to item, pick it up, then return with item
local function bringItemsByPlayerTP(itemNames, originalPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local itemsFound = {}
    
    -- Collect all matching items first
    for _, itemName in ipairs(itemNames) do
        for _, item in ipairs(workspace:GetDescendants()) do
            if item.Name == itemName and (item:IsA("BasePart") or item:IsA("Model")) then
                local part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                if part and part:IsA("BasePart") then
                    table.insert(itemsFound, {item = item, part = part})
                end
            end
        end
    end
    
    -- Process each item
    for i, itemData in ipairs(itemsFound) do
        local item = itemData.item
        local part = itemData.part
        
        -- Check if item still exists
        if item and item.Parent and part then
            -- Step 1: Teleport player to the item
            local itemPosition = part.Position + Vector3.new(0, 3, 0) -- Slightly above item
            hrp.CFrame = CFrame.new(itemPosition)
            
            task.wait(0.2) -- Wait a moment for teleport to register
            
            -- Step 2: Start dragging the item (this attaches it to player)
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteEvents").RequestStartDraggingItem:FireServer(item)
            end)
            
            task.wait(0.3) -- Wait for item to attach
            
            -- Step 3: Teleport back to original position with the item
            hrp.CFrame = CFrame.new(originalPosition)
            
            task.wait(0.2) -- Wait for teleport
            
            -- Step 4: Stop dragging to drop the item at original position
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteEvents").StopDraggingItem:FireServer(item)
            end)
            
            task.wait(0.5) -- Wait between items to avoid spam detection
        end
    end
    
    -- Final teleport back to original position
    hrp.CFrame = CFrame.new(originalPosition)
end

-- Combat Tab
do
    local auraSection = Combat:DrawSection({
        Name = "Aura",
        Position = 'LEFT'
    });

    local settingsSection = Combat:DrawSection({
        Name = "Settings",
        Position = 'RIGHT'
    });

    auraSection:AddToggle({
        Name = "Kill Aura",
        Flag = "kill_aura_toggle",
        Callback = function(state)
            killAuraToggle = state
            if state then
                task.spawn(killAuraLoop)
            else
                local tool, _ = getAnyToolWithDamageID(false)
                unequipTool(tool)
            end
        end
    });

    auraSection:AddToggle({
        Name = "Chop Aura",
        Flag = "chop_aura_toggle",
        Callback = function(state)
            chopAuraToggle = state
            if state then
                task.spawn(chopAuraLoop)
            else
                local tool, _ = getAnyToolWithDamageID(true)
                unequipTool(tool)
            end
        end
    });

    settingsSection:AddSlider({
        Name = "Aura Radius",
        Min = 50,
        Max = 500,
        Default = 50,
        Flag = "aura_radius",
        Callback = function(value)
            auraRadius = math.clamp(value, 10, 500)
        end
    });
end

-- Main Tab
do
    local autoFeedSection = Main:DrawSection({
        Name = "Auto Feed",
        Position = 'LEFT'
    });

    local miscSection = Main:DrawSection({
        Name = "Misc",
        Position = 'RIGHT'
    });

    autoFeedSection:AddDropdown({
        Name = "Select Food",
        Values = alimentos,
        Default = {},
        Multi = true,
        Flag = "selected_food",
        Callback = function(value)
            selectedFood = value
        end
    });

    autoFeedSection:AddSlider({
        Name = "Feed %",
        Min = 0,
        Max = 100,
        Default = 75,
        Type = "%",
        Flag = "hunger_threshold",
        Callback = function(value)
            hungerThreshold = math.clamp(value, 0, 100)
        end
    });

    autoFeedSection:AddToggle({
        Name = "Auto Feed",
        Flag = "auto_feed_toggle",
        Callback = function(state)
            autoFeedToggle = state
            if state then
                task.spawn(function()
                    while autoFeedToggle do
                        task.wait(0.075)
                        if wiki(selectedFood) == 0 then
                            autoFeedToggle = false
                            notifeed(selectedFood)
                            break
                        end
                        if ghn() <= hungerThreshold then
                            feed(selectedFood)
                        end
                    end
                end)
            end
        end
    });

    local instantInteractEnabled = false
    local instantInteractConnection
    local originalHoldDurations = {}

    miscSection:AddToggle({
        Name = "Instant Interact",
        Flag = "instant_interact",
        Callback = function(state)
            instantInteractEnabled = state

            if state then
                originalHoldDurations = {}
                instantInteractConnection = task.spawn(function()
                    while instantInteractEnabled do
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") then
                                if originalHoldDurations[obj] == nil then
                                    originalHoldDurations[obj] = obj.HoldDuration
                                end
                                obj.HoldDuration = 0
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                if instantInteractConnection then
                    instantInteractEnabled = false
                end
                for obj, value in pairs(originalHoldDurations) do
                    if obj and obj:IsA("ProximityPrompt") then
                        obj.HoldDuration = value
                    end
                end
                originalHoldDurations = {}
            end
        end
    });

    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local torchLoop = nil

    miscSection:AddToggle({
        Name = "Auto Stun Deer",
        Flag = "auto_stun_deer",
        Callback = function(state)
            if state then
                torchLoop = RunService.RenderStepped:Connect(function()
                    pcall(function()
                        local remote = ReplicatedStorage:FindFirstChild("RemoteEvents")
                            and ReplicatedStorage.RemoteEvents:FindFirstChild("DeerHitByTorch")
                        local deer = workspace:FindFirstChild("Characters")
                            and workspace.Characters:FindFirstChild("Deer")
                        if remote and deer then
                            remote:InvokeServer(deer)
                        end
                    end)
                    task.wait(0.1)
                end)
            else
                if torchLoop then
                    torchLoop:Disconnect()
                    torchLoop = nil
                end
            end
        end
    });
end

-- Auto Tab
do
    local campfireSection = Auto:DrawSection({
        Name = "Auto Upgrade Campfire",
        Position = 'LEFT'
    });

    local scrapSection = Auto:DrawSection({
        Name = "Auto Scrap Items",
        Position = 'LEFT'
    });

    local cookSection = Auto:DrawSection({
        Name = "Auto Cook Food",
        Position = 'RIGHT'
    });

    campfireSection:AddDropdown({
        Name = "Select Item",
        Values = campfireFuelItems,
        Default = nil,
        Multi = false,
        Flag = "selected_campfire_item",
        Callback = function(option)
            selectedCampfireItem = option
        end
    });

    campfireSection:AddToggle({
        Name = "Auto Upgrade Campfire",
        Flag = "auto_upgrade_campfire",
        Callback = function(checked)
            autoUpgradeCampfireEnabled = checked
            if checked then
                task.spawn(function()
                    while autoUpgradeCampfireEnabled do
                        if selectedCampfireItem then
                            for _, item in ipairs(workspace:WaitForChild("Items"):GetChildren()) do
                                if item.Name == selectedCampfireItem then
                                    moveItemToPos(item, campfireDropPos)
                                end
                            end
                        end
                        task.wait(2)
                    end
                end)
            end
        end
    });

    scrapSection:AddDropdown({
        Name = "Select Item",
        Values = scrapjunkItems,
        Default = nil,
        Multi = false,
        Flag = "selected_scrap_item",
        Callback = function(option)
            selectedScrapItem = option
        end
    });

    scrapSection:AddToggle({
        Name = "Auto Scrap Items",
        Flag = "auto_scrap_items",
        Callback = function(checked)
            autoScrapItemsEnabled = checked
            if checked then
                task.spawn(function()
                    while autoScrapItemsEnabled do
                        if selectedScrapItem then
                            for _, item in ipairs(workspace:WaitForChild("Items"):GetChildren()) do
                                if item.Name == selectedScrapItem then
                                    moveItemToPos(item, autoScrapPos)
                                end
                            end
                        end
                        task.wait(2)
                    end
                end)
            end
        end
    });

    cookSection:AddDropdown({
        Name = "Select Items",
        Values = autocookItems,
        Default = {},
        Multi = true,
        Flag = "auto_cook_items",
        Callback = function(options)
            for _, itemName in ipairs(autocookItems) do
                autoCookEnabledItems[itemName] = table.find(options, itemName) ~= nil
            end
        end
    });

    cookSection:AddToggle({
        Name = "Auto Cook Food",
        Flag = "auto_cook_enabled",
        Callback = function(state)
            autoCookEnabled = state
        end
    });

    coroutine.wrap(function()
        while true do
            if autoCookEnabled then
                for itemName, enabled in pairs(autoCookEnabledItems) do
                    if enabled then
                        for _, item in ipairs(Workspace:WaitForChild("Items"):GetChildren()) do
                            if item.Name == itemName then
                                moveItemToPos(item, campfireDropPos)
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)()
end

-- Esp Tab
do
    local itemsSection = Esp:DrawSection({
        Name = "Esp Items",
        Position = 'LEFT'
    });

    local entitySection = Esp:DrawSection({
        Name = "Esp Entity",
        Position = 'RIGHT'
    });

    local selectedItems = {}
    local selectedMobs = {}
    local espItemsEnabled = false
    local espMobsEnabled = false
    local espConnections = {}

    itemsSection:AddDropdown({
        Name = "Select Items",
        Values = ie,
        Default = {},
        Multi = true,
        Flag = "selected_items",
        Callback = function(options)
            selectedItems = options
            if espItemsEnabled then
                for _, name in ipairs(ie) do
                    if table.find(selectedItems, name) then
                        Aesp(name, "item")
                    else
                        Desp(name, "item")
                    end
                end
            else
                for _, name in ipairs(ie) do
                    Desp(name, "item")
                end
            end
        end
    });

    itemsSection:AddToggle({
        Name = "Enable Esp",
        Flag = "esp_items_enabled",
        Callback = function(state)
            espItemsEnabled = state
            for _, name in ipairs(ie) do
                if state and table.find(selectedItems, name) then
                    Aesp(name, "item")
                else
                    Desp(name, "item")
                end
            end

            if state then
                if not espConnections["Items"] then
                    local container = workspace:FindFirstChild("Items")
                    if container then
                        espConnections["Items"] = container.ChildAdded:Connect(function(obj)
                            if table.find(selectedItems, obj.Name) then
                                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    createESPText(part, obj.Name, Color3.fromRGB(0, 255, 0))
                                end
                            end
                        end)
                    end
                end
            else
                if espConnections["Items"] then
                    espConnections["Items"]:Disconnect()
                    espConnections["Items"] = nil
                end
            end
        end
    });

    entitySection:AddDropdown({
        Name = "Select Entity",
        Values = me,
        Default = {},
        Multi = true,
        Flag = "selected_mobs",
        Callback = function(options)
            selectedMobs = options
            if espMobsEnabled then
                for _, name in ipairs(me) do
                    if table.find(selectedMobs, name) then
                        Aesp(name, "mob")
                    else
                        Desp(name, "mob")
                    end
                end
            else
                for _, name in ipairs(me) do
                    Desp(name, "mob")
                end
            end
        end
    });

    entitySection:AddToggle({
        Name = "Enable Esp",
        Flag = "esp_mobs_enabled",
        Callback = function(state)
            espMobsEnabled = state
            for _, name in ipairs(me) do
                if state and table.find(selectedMobs, name) then
                    Aesp(name, "mob")
                else
                    Desp(name, "mob")
                end
            end

            if state then
                if not espConnections["Mobs"] then
                    local container = workspace:FindFirstChild("Characters")
                    if container then
                        espConnections["Mobs"] = container.ChildAdded:Connect(function(obj)
                            if table.find(selectedMobs, obj.Name) then
                                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    createESPText(part, obj.Name, Color3.fromRGB(255, 255, 0))
                                end
                            end
                        end)
                    end
                end
            else
                if espConnections["Mobs"] then
                    espConnections["Mobs"]:Disconnect()
                    espConnections["Mobs"] = nil
                end
            end
        end
    });
end

function createESPText(part, text, color)
    if part:FindFirstChild("ESPTexto") then return end

    local esp = Instance.new("BillboardGui")
    esp.Name = "ESPTexto"
    esp.Adornee = part
    esp.Size = UDim2.new(0, 100, 0, 20)
    esp.StudsOffset = Vector3.new(0, 2.5, 0)
    esp.AlwaysOnTop = true
    esp.MaxDistance = 300

    local label = Instance.new("TextLabel")
    label.Parent = esp
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255,255,0)
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    esp.Parent = part
end

local function Aesp(nome, tipo)
    local container
    local color
    if tipo == "item" then
        container = workspace:FindFirstChild("Items")
        color = Color3.fromRGB(0, 255, 0)
    elseif tipo == "mob" then
        container = workspace:FindFirstChild("Characters")
        color = Color3.fromRGB(255, 255, 0)
    else
        return
    end
    if not container then return end

    for _, obj in ipairs(container:GetChildren()) do
        if obj.Name == nome then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                createESPText(part, obj.Name, color)
            end
        end
    end
end

local function Desp(nome, tipo)
    local container
    if tipo == "item" then
        container = workspace:FindFirstChild("Items")
    elseif tipo == "mob" then
        container = workspace:FindFirstChild("Characters")
    else
        return
    end
    if not container then return end

    for _, obj in ipairs(container:GetChildren()) do
        if obj.Name == nome then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                for _, gui in ipairs(part:GetChildren()) do
                    if gui:IsA("BillboardGui") and gui.Name == "ESPTexto" then
                        gui:Destroy()
                    end
                end
            end
        end
    end
end

-- Bring Tab
do
    local junkSection = Bring:DrawSection({
        Name = "Junk",
        Position = 'LEFT'
    });

    local fuelSection = Bring:DrawSection({
        Name = "Fuel",
        Position = 'LEFT'
    });

    local foodSection = Bring:DrawSection({
        Name = "Food",
        Position = 'LEFT'
    });

    local medicalSection = Bring:DrawSection({
        Name = "Medicine",
        Position = 'RIGHT'
    });

    local equipmentSection = Bring:DrawSection({
        Name = "Equipment",
        Position = 'RIGHT'
    });

    junkSection:AddDropdown({
        Name = "Select Junk Items",
        Values = junkItems,
        Default = {},
        Multi = true,
        Flag = "selected_junk_items",
        Callback = function(options)
            selectedJunkItems = options
        end
    });

    junkSection:AddToggle({
        Name = "Bring Junk Items",
        Flag = "junk_toggle_enabled",
        Callback = function(value)
            junkToggleEnabled = value
            
            if value then
                if #selectedJunkItems > 0 then
                    junkLoopRunning = true
                    spawn(function()
                        while junkLoopRunning and junkToggleEnabled do
                            if #selectedJunkItems > 0 and junkToggleEnabled then
                                bypassBringSystem(selectedJunkItems, function() return junkToggleEnabled end)
                            end
                            
                            local waitTime = 0
                            while waitTime < 3 and junkToggleEnabled and junkLoopRunning do
                                wait(0.1)
                                waitTime = waitTime + 0.1
                            end
                        end
                        junkLoopRunning = false
                    end)
                else
                    junkToggleEnabled = false
                end
            else
                junkLoopRunning = false
            end
        end
    }).Link:AddHelper({
        Text = "Before you Bring Unlocked 1 zone first!"
    });

    fuelSection:AddDropdown({
        Name = "Select Fuel Items",
        Values = fuelItems,
        Default = {},
        Multi = true,
        Flag = "selected_fuel_items",
        Callback = function(options)
            selectedFuelItems = options
        end
    });

    fuelSection:AddToggle({
        Name = "Bring Fuel Items",
        Flag = "fuel_toggle_enabled",
        Callback = function(value)
            fuelToggleEnabled = value
            
            if value then
                if #selectedFuelItems > 0 then
                    fuelLoopRunning = true
                    spawn(function()
                        while fuelLoopRunning and fuelToggleEnabled do
                            if #selectedFuelItems > 0 and fuelToggleEnabled then
                                bypassBringSystem(selectedFuelItems, function() return fuelToggleEnabled end)
                            end
                            
                            local waitTime = 0
                            while waitTime < 3 and fuelToggleEnabled and fuelLoopRunning do
                                wait(0.1)
                                waitTime = waitTime + 0.1
                            end
                        end
                        fuelLoopRunning = false
                    end)
                else
                    fuelToggleEnabled = false
                end
            else
                fuelLoopRunning = false
            end
        end
    }).Link:AddHelper({
        Text = "Before you Bring Unlocked 1 Zone First!"
    });

    foodSection:AddDropdown({
        Name = "Select Food Items",
        Values = foodItems,
        Default = {},
        Multi = true,
        Flag = "selected_food_items",
        Callback = function(options)
            selectedFoodItems = options
        end
    });

    foodSection:AddToggle({
        Name = "Bring Food items",
        Flag = "food_toggle_enabled",
        Callback = function(value)
            foodToggleEnabled = value
            
            if value then
                if #selectedFoodItems > 0 then
                    foodLoopRunning = true
                    spawn(function()
                        while foodLoopRunning and foodToggleEnabled do
                            if #selectedFoodItems > 0 and foodToggleEnabled then
                                bypassBringSystem(selectedFoodItems, function() return foodToggleEnabled end)
                            end
                            
                            local waitTime = 0
                            while waitTime < 3 and foodToggleEnabled and foodLoopRunning do
                                wait(0.1)
                                waitTime = waitTime + 0.1
                            end
                        end
                        foodLoopRunning = false                 
                    end)
                else                
                    foodToggleEnabled = false
                end
            else
                foodLoopRunning = false          
            end
        end
    }).Link:AddHelper({
        Text = "Before you Bring Unlocked 1 Zone First!"
    });

    medicalSection:AddDropdown({
        Name = "Select Medical Items",
        Values = medicalItems,
        Default = {},
        Multi = true,
        Flag = "selected_medical_items",
        Callback = function(options)
            selectedMedicalItems = options
        end
    });

    medicalSection:AddToggle({
        Name = "Bring Medical Items",
        Flag = "medical_toggle_enabled",
        Callback = function(value)
            medicalToggleEnabled = value
            
            if value then
                if #selectedMedicalItems > 0 then
                    medicalLoopRunning = true
                    spawn(function()
                        while medicalLoopRunning and medicalToggleEnabled do
                            if #selectedMedicalItems > 0 and medicalToggleEnabled then
                                bypassBringSystem(selectedMedicalItems, function() return medicalToggleEnabled end)
                            end
                            
                            local waitTime = 0
                            while waitTime < 3 and medicalToggleEnabled and medicalLoopRunning do
                                wait(0.1)
                                waitTime = waitTime + 0.1
                            end
                        end
                        medicalLoopRunning = false
                    end)
                else
                    medicalToggleEnabled = false
                end
            else
                medicalLoopRunning = false
            end
        end
    }).Link:AddHelper({
        Text = "Before you Bring Unlocked 1 Zone First!"
    });

    equipmentSection:AddDropdown({
        Name = "Select Equipment Items",
        Values = equipmentItems,
        Default = {},
        Multi = true,
        Flag = "selected_equipment_items",
        Callback = function(options)
            selectedEquipmentItems = options
        end
    });

    equipmentSection:AddToggle({
        Name = "Bring Equipment Items",
        Flag = "equipment_toggle_enabled",
        Callback = function(value)
            equipmentToggleEnabled = value
            
            if value then
                if #selectedEquipmentItems > 0 then
                    equipmentLoopRunning = true
                    spawn(function()
                        while equipmentLoopRunning and equipmentToggleEnabled do
                            if #selectedEquipmentItems > 0 and equipmentToggleEnabled then
                                bypassBringSystem(selectedEquipmentItems, function() return equipmentToggleEnabled end)
                            end
                            
                            local waitTime = 0
                            while waitTime < 3 and equipmentToggleEnabled and equipmentLoopRunning do
                                wait(0.1)
                                waitTime = waitTime + 0.1
                            end
                        end
                        equipmentLoopRunning = false
                    end)
                else
                    equipmentToggleEnabled = false
                end
            else
                equipmentLoopRunning = false
            end
        end
    }).Link:AddHelper({
        Text = "Before you Bring Unlocked 1 Zone First!"
    });
end

-- Teleport Tab
do
    local tpSection = Teleport:DrawSection({
        Name = "Teleport",
        Position = 'LEFT'
    });

    local childrenSection = Teleport:DrawSection({
        Name = "Children",
        Position = 'LEFT'
    });

    local chestSection = Teleport:DrawSection({
        Name = "Chest",
        Position = 'RIGHT'
    });

    tpSection:AddButton({
        Name = "Teleport to Campfire",
        Callback = function()
            tp1()
        end
    });

    tpSection:AddButton({
        Name = "Teleport to Stronghold",
        Callback = function()
            tp2()
        end
    });

    local MobDropdown = childrenSection:AddDropdown({
        Name = "Select Child",
        Values = currentMobNames,
        Default = currentMobNames[1] or nil,
        Multi = false,
        Flag = "selected_mob",
        Callback = function(options)
            selectedMob = options
        end
    });

    childrenSection:AddButton({
        Name = "Refresh List",
        Callback = function()
            currentMobs, currentMobNames = getMobs()
            if #currentMobNames > 0 then
                selectedMob = currentMobNames[1]
                MobDropdown.Values = currentMobNames
            else
                selectedMob = nil
                MobDropdown.Values = { "No child found" }
            end
        end
    });

    childrenSection:AddButton({
        Name = "Teleport to Child",
        Callback = function()
            if selectedMob and currentMobs then
                for i, name in ipairs(currentMobNames) do
                    if name == selectedMob then
                        local targetMob = currentMobs[i]
                        if targetMob then
                            local part = targetMob.PrimaryPart or targetMob:FindFirstChildWhichIsA("BasePart")
                            if part and game.Players.LocalPlayer.Character then
                                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
    });

    local ChestDropdown = chestSection:AddDropdown({
        Name = "Select Chest",
        Values = currentChestNames,
        Default = currentChestNames[1] or nil,
        Multi = false,
        Flag = "selected_chest",
        Callback = function(options)
            selectedChest = options
        end
    });

    chestSection:AddButton({
        Name = "Refresh List",
        Callback = function()
            currentChests, currentChestNames = getChests()
            if #currentChestNames > 0 then
                selectedChest = currentChestNames[1]
                ChestDropdown.Values = currentChestNames
            else
                selectedChest = nil
                ChestDropdown.Values = { "No chests found" }
            end
        end
    });

    chestSection:AddButton({
        Name = "Teleport to Chest",
        Callback = function()
            if selectedChest and currentChests then
                local chestIndex = 1
                for i, name in ipairs(currentChestNames) do
                    if name == selectedChest then
                        chestIndex = i
                        break
                    end
                end
                local targetChest = currentChests[chestIndex]
                if targetChest then
                    local part = targetChest.PrimaryPart or targetChest:FindFirstChildWhichIsA("BasePart")
                    if part and game.Players.LocalPlayer.Character then
                        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                        end
                    end
                end
            end
        end
    });
end

-- Player Tab
do
    local mainSection = Player:DrawSection({
        Name = "Main",
        Position = 'LEFT'
    });

    mainSection:AddSlider({
        Name = "Fly Speed",
        Min = 1,
        Max = 20,
        Default = 1,
        Flag = "fly_speed",
        Callback = function(value)
            flySpeed = value
            if FLYING then
                task.spawn(function()
                    while FLYING do
                        task.wait(0.1)
                        if game:GetService("UserInputService").TouchEnabled then
                            local root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root and root:FindFirstChild("BodyVelocity") then
                                local bv = root:FindFirstChild("BodyVelocity")
                                bv.Velocity = bv.Velocity.Unit * (flySpeed * 50) -- Adjust velocity magnitude
                            end
                        end
                    end
                end)
            end
        end
    });

    mainSection:AddToggle({
        Name = "Enable Fly",
        Flag = "fly_toggle",
        Callback = function(state)
            flyToggle = state
            if flyToggle then
                if game:GetService("UserInputService").TouchEnabled then
                    MobileFly()
                else
                    sFLY()
                end
            else
                NOFLY()
                UnMobileFly()
            end
        end
    });

    local speed = 16

    local function setSpeed(val)
        local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = val end
    end

    mainSection:AddSlider({
        Name = "Speed",
        Min = 16,
        Max = 150,
        Default = 16,
        Flag = "speed_value",
        Callback = function(value)
            speed = value
        end
    });

    mainSection:AddToggle({
        Name = "Enable Speed",
        Flag = "enable_speed",
        Callback = function(state)
            setSpeed(state and speed or 16)
        end
    });

    local RunService = game:GetService("RunService")
    local noclipConnection

    mainSection:AddToggle({
        Name = "Noclip",
        Flag = "noclip_toggle",
        Callback = function(state)
            if state then
                noclipConnection = RunService.Stepped:Connect(function()
                    local char = Players.LocalPlayer.Character
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
            end
        end
    });

    local UserInputService = game:GetService("UserInputService")
    local infJumpConnection

    mainSection:AddToggle({
        Name = "Inf Jump",
        Flag = "inf_jump_toggle",
        Callback = function(state)
            if state then
                infJumpConnection = UserInputService.JumpRequest:Connect(function()
                    local char = Players.LocalPlayer.Character
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            else
                if infJumpConnection then
                    infJumpConnection:Disconnect()
                    infJumpConnection = nil
                end
            end
        end
    });
end

-- Environment Tab
do
    local visionSection = Environment:DrawSection({
        Name = "Vision",
        Position = 'LEFT'
    });

    local originalParents = {
        Sky = nil,
        Bloom = nil,
        CampfireEffect = nil
    }

    local function storeOriginalParents()
        local Lighting = game:GetService("Lighting")
        
        local sky = Lighting:FindFirstChild("Sky")
        local bloom = Lighting:FindFirstChild("Bloom")
        local campfireEffect = Lighting:FindFirstChild("CampfireEffect")
        
        if sky and not originalParents.Sky then
            originalParents.Sky = sky.Parent
        end
        if bloom and not originalParents.Bloom then
            originalParents.Bloom = bloom.Parent
        end
        if campfireEffect and not originalParents.CampfireEffect then
            originalParents.CampfireEffect = campfireEffect.Parent
        end
    end

    storeOriginalParents()

    local originalColorCorrectionParent = nil

    local function storeColorCorrectionParent()
        local Lighting = game:GetService("Lighting")
        local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
        
        if colorCorrection and not originalColorCorrectionParent then
            originalColorCorrectionParent = colorCorrection.Parent
        end
    end

    storeColorCorrectionParent()

    local originalLightingValues = {
        Brightness = nil,
        Ambient = nil,
        OutdoorAmbient = nil,
        ShadowSoftness = nil,
        GlobalShadows = nil,
        Technology = nil
    }

    local function storeOriginalLighting()
        local Lighting = game:GetService("Lighting")
        
        if not originalLightingValues.Brightness then
            originalLightingValues.Brightness = Lighting.Brightness
            originalLightingValues.Ambient = Lighting.Ambient
            originalLightingValues.OutdoorAmbient = Lighting.OutdoorAmbient
            originalLightingValues.ShadowSoftness = Lighting.ShadowSoftness
            originalLightingValues.GlobalShadows = Lighting.GlobalShadows
            originalLightingValues.Technology = Lighting.Technology
        end
    end

    storeOriginalLighting()

    visionSection:AddToggle({
        Name = "Disable Fog",
        Flag = "disable_fog",
        Callback = function(state)
            local Lighting = game:GetService("Lighting")
            
            if state then
                local sky = Lighting:FindFirstChild("Sky")
                local bloom = Lighting:FindFirstChild("Bloom")
                local campfireEffect = Lighting:FindFirstChild("CampfireEffect")
                
                if sky then
                    sky.Parent = nil
                end
                if bloom then
                    bloom.Parent = nil
                end
                if campfireEffect then
                    campfireEffect.Parent = nil
                end
            else
                local sky = game:FindFirstChild("Sky", true)
                local bloom = game:FindFirstChild("Bloom", true) 
                local campfireEffect = game:FindFirstChild("CampfireEffect", true)
                
                if not sky then sky = Lighting:FindFirstChild("Sky") end
                if not bloom then bloom = Lighting:FindFirstChild("Bloom") end
                if not campfireEffect then campfireEffect = Lighting:FindFirstChild("CampfireEffect") end
                
                if sky then
                    sky.Parent = originalParents.Sky or Lighting
                end
                if bloom then
                    bloom.Parent = originalParents.Bloom or Lighting
                end
                if campfireEffect then
                    campfireEffect.Parent = originalParents.CampfireEffect or Lighting
                end
            end
        end
    });

    visionSection:AddToggle({
        Name = "Disable NightCampFire Effect",
        Flag = "disable_night_campfire",
        Callback = function(state)
            local Lighting = game:GetService("Lighting")
            
            if state then
                local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
                
                if colorCorrection then
                    if not originalColorCorrectionParent then
                        originalColorCorrectionParent = colorCorrection.Parent
                    end
                    colorCorrection.Parent = nil
                end
            else
                local colorCorrection = nil
                
                colorCorrection = Lighting:FindFirstChild("ColorCorrection")
                
                if not colorCorrection then
                    colorCorrection = game:FindFirstChild("ColorCorrection", true)
                end
                
                if colorCorrection then
                    colorCorrection.Parent = Lighting
                end
            end
        end
    });

    visionSection:AddToggle({
        Name = "Fullbright",
        Flag = "fullbright",
        Callback = function(state)
            local Lighting = game:GetService("Lighting")
            
            if state then
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.new(1, 1, 1)
                Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                Lighting.ShadowSoftness = 0
                Lighting.GlobalShadows = false
                Lighting.Technology = Enum.Technology.Compatibility
            else
                Lighting.Brightness = originalLightingValues.Brightness
                Lighting.Ambient = originalLightingValues.Ambient
                Lighting.OutdoorAmbient = originalLightingValues.OutdoorAmbient
                Lighting.ShadowSoftness = originalLightingValues.ShadowSoftness
                Lighting.GlobalShadows = originalLightingValues.GlobalShadows
                Lighting.Technology = originalLightingValues.Technology
            end
        end
    });
end

-- Information Tab
do
    Information:AddParagraph({
        Title = "Souls Hub",
        Content = "Souls Hub\nDeveloped by rin, souls Scripts, and souls"
    });

    local InviteCode = "vVhMWE3gAV"
    local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

    local function LoadDiscordInfo()
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync(DiscordAPI))
        end)

        if success and result and result.guild then
            Information:AddParagraph({
                Title = result.guild.name,
                Content = 'Member Count : ' .. tostring(result.approximate_member_count) ..
                    '\nOnline Count : ' .. tostring(result.approximate_presence_count)
            });

            Information:AddButton({
                Name = "Update Info",
                Callback = function()
                    local updated, updatedResult = pcall(function()
                        return game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync(DiscordAPI))
                    end)

                    if updated and updatedResult and updatedResult.guild then
                        print("Discord Info Updated")
                    else
                        print("Update Failed")
                    end
                end
            });

            Information:AddButton({
                Name = "Copy Discord Invite",
                Callback = function()
                    setclipboard("https://discord.gg/" .. InviteCode)
                    print("Copied!")
                end
            });
        else
            Information:AddParagraph({
                Title = "Error fetching Discord Info",
                Content = "Unable to load Discord information. Check your internet connection."
            });
            print("Discord API Error:", result)
        end
    end

    LoadDiscordInfo()
end

Window:Draw()
