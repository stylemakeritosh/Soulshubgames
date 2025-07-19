if game.PlaceId ~= 7218065222 then
    return
end

local SoulsHub = loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/3a930cb943c37a8e"))()

local Window = SoulsHub:CreateWindow({
   Name = "Souls Hub Dig",
   LoadingTitle = "DiG Game Script",
   LoadingSubtitle = "Join Discord Souls Hub",
   ConfigurationSaving = { Enabled = true, FolderName = "soulshubdigg", FileName = "soulsHubdig" },
   Discord = { Enabled = true, Invite = "fjgqaRSHY8", RememberJoins = true },
   KeySystem = false
})

local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Billboard GUI above player's head
local part = Instance.new("Part", Workspace)
part.Anchored = true
part.CanCollide = false
part.Size = Vector3.new(4, 1, 4)
part.Transparency = 1
part.Name = "DiscordBillboard"
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
part.Position = hrp.Position + Vector3.new(0, 5, 0)
local bb = Instance.new("BillboardGui", part)
bb.Size = UDim2.new(0, 200, 0, 50)
bb.StudsOffset = Vector3.new(0, 6, 0)
bb.AlwaysOnTop = true
local text = Instance.new("TextLabel", bb)
text.Size = UDim2.new(1, 0, 1, 0)
text.BackgroundTransparency = 1
text.Text = "https://discord.gg/fjgqaRSHY8"
text.TextColor3 = Color3.fromRGB(180, 220, 255)
text.TextStrokeTransparency = 0
text.TextStrokeColor3 = Color3.new(0, 0, 0)
text.Font = Enum.Font.GothamBold
text.TextScaled = true
local img = Instance.new("ImageLabel", bb)
img.Size = UDim2.new(0.3, 0, 0.3, 0)
img.Position = UDim2.new(0.35, 0, 1, 0)
img.BackgroundTransparency = 1
img.Image = "rbxassetid://133520378097790"
task.delay(10, function()
    part:Destroy()
end)

-- Initial notifications
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Script Loaded",
    Text = "Have Fun With The Script, " .. player.Name .. ", Enjoyy",
    Duration = 7
})
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Join Discord",
    Text = "DIG",
    Duration = 6.5
})

-- Update Tab
local UpdateTab = Window:CreateTab("Update")
UpdateTab:CreateLabel("What's New? Check Discord for updates.", nil)
UpdateTab:CreateButton({
    Name = "Discord Join",
    Callback = function()
        setclipboard("https://discord.gg/fjgqaRSHY8")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Copied!",
            Text = "Discord link copied to clipboard.",
            Duration = 2
        })
    end,
})

-- Basic GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BasicGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Position = UDim2.new(0, 10, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 0.5, 0)
Label.BackgroundTransparency = 1
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.Text = "Boss"
Label.TextSize = 14
Label.Parent = Frame
local BossStatus = Instance.new("TextLabel")
BossStatus.Size = UDim2.new(1, 0, 0.5, 0)
BossStatus.Position = UDim2.new(0, 0, 0.5, 0)
BossStatus.BackgroundTransparency = 1
BossStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
BossStatus.Text = "Boss Status: Checking..."
BossStatus.TextSize = 12
BossStatus.Parent = Frame
local guiVisible = false
ScreenGui.Enabled = guiVisible
UpdateTab:CreateToggle({
    Name = "Show if boss spawned",
    CurrentValue = true,
    Callback = function(Value)
        guiVisible = Value
        ScreenGui.Enabled = guiVisible
        warn("boss", guiVisible)
    end,
})
task.spawn(function()
    while true do
        if guiVisible then
            local bossSpawns = Workspace:FindFirstChild("Spawns") and Workspace.Spawns:FindFirstChild("BossSpawns")
            local foundBoss = false
            if bossSpawns then
                for _, boss in ipairs(bossSpawns:GetChildren()) do
                    if boss:FindFirstChildWhichIsA("Model") or #boss:GetChildren() > 0 then
                        foundBoss = true
                        break
                    end
                end
            end
            if foundBoss then
                BossStatus.Text = "Boss Status:  Spawned!"
                BossStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
            else
                BossStatus.Text = "Boss Status:  None"
                BossStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
        task.wait(1)
    end
end)

-- Farm Tab: Auto Dig (Fast)
local FarmTab = Window:CreateTab("Farm")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Holes = Workspace:WaitForChild("World"):WaitForChild("Zones"):WaitForChild("_NoDig")
local autoDigFastEnabled = false
local digCount = 0
local connections = {}
function getTool()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
end
function destroyHitbox()
    local hitbox = Holes:FindFirstChild(LocalPlayer.Name .. "_Crater_Hitbox")
    if hitbox then hitbox:Destroy() end
end
function activateTool()
    local tool = getTool()
    if tool then
        destroyHitbox()
        tool:Activate()
    end
end
function setupEvents()
    table.insert(connections, LocalPlayer.PlayerGui.ChildAdded:Connect(function(v)
        if v.Name == "Dig" then
            local strong_bar = v.Safezone.Holder:FindFirstChild("Area_Strong")
            local player_bar = v.Safezone.Holder:FindFirstChild("PlayerBar")
            table.insert(connections, player_bar:GetPropertyChangedSignal("Position"):Connect(function()
                if autoDigFastEnabled then
                    player_bar.Position = strong_bar.Position
                    digCount = digCount + 1
                    activateTool()
                end
            end))
        end
    end))
    table.insert(connections, LocalPlayer:GetAttributeChangedSignal("IsDigging"):Connect(function()
        if autoDigFastEnabled and not LocalPlayer:GetAttribute("IsDigging") then
            activateTool()
        end
    end))
    table.insert(connections, LocalPlayer.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(function(v)
            if autoDigFastEnabled and v:IsA("Tool") and v.Name:lower():find("shovel") then
                task.wait(0.1)
                activateTool()
            end
        end)
    end))
    if LocalPlayer.Character then
        table.insert(connections, LocalPlayer.Character.ChildAdded:Connect(function(v)
            if autoDigFastEnabled and v:IsA("Tool") and v.Name:lower():find("shovel") then
                task.wait(0.01)
                activateTool()
            end
        end))
    end
    table.insert(connections, RunService.Heartbeat:Connect(function()
        if autoDigFastEnabled and digCount >= 3 then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(2), 0)
                activateTool()
            end
        end
    end))
end
function cleanupEvents()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
end
FarmTab:CreateToggle({
    Name = "Auto Dig (Fast)",
    CurrentValue = false,
    Callback = function(Value)
        autoDigFastEnabled = Value
        if Value then
            digCount = 0
            setupEvents()
        else
            cleanupEvents()
        end
    end,
})

-- Farm Tab: Auto Dig (Slow)
getgenv().autoDigSlowEnabled = false
function get_tool()
    return LocalPlayer.Character:FindFirstChildOfClass("Tool")
end
LocalPlayer.Character.ChildAdded:Connect(function(v)
    if getgenv().autoDigSlowEnabled and v:IsA("Tool") and v.Name:find("Shovel") then
        task.wait(1)
        if Holes:FindFirstChild(LocalPlayer.Name .. "_Crater_Hitbox") then
            Holes[LocalPlayer.Name .. "_Crater_Hitbox"]:Destroy()
        end
        v:Activate()
    end
end)
LocalPlayer.PlayerGui.ChildAdded:Connect(function(v)
    if getgenv().autoDigSlowEnabled and v.Name == "Dig" then
        local strong_bar = v:FindFirstChild("Safezone"):FindFirstChild("Holder"):FindFirstChild("Area_Strong")
        local player_bar = v:FindFirstChild("Safezone"):FindFirstChild("Holder"):FindFirstChild("PlayerBar")
        player_bar:GetPropertyChangedSignal("Position"):Connect(function()
            if not getgenv().autoDigSlowEnabled then return end
            if math.abs(player_bar.Position.X.Scale - strong_bar.Position.X.Scale) <= 0.04 then
                local tool = get_tool()
                if tool then
                    tool:Activate()
                    task.wait()
                end
            end
        end)
    end
end)
LocalPlayer:GetAttributeChangedSignal("IsDigging"):Connect(function()
    if not getgenv().autoDigSlowEnabled then return end
    if not LocalPlayer:GetAttribute("IsDigging") then
        if Holes:FindFirstChild(LocalPlayer.Name .. "_Crater_Hitbox") then
            Holes[LocalPlayer.Name .. "_Crater_Hitbox"]:Destroy()
        end
        local tool = get_tool()
        if tool then
            tool:Activate()
        end
    end
end)
FarmTab:CreateToggle({
    Name = "Auto Dig (slow)",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().autoDigSlowEnabled = Value
    end,
})

-- Farm Tab: Auto Equip Shovel
local autoEquipEnabled = false
local backpackConn
local shovelNames = {
    "Wooden Shovel", "Bejeweled Shovel", "Training Shovel", "Toy Shovel",
    "Copper Shovel", "Rock Shovel", "Lucky Shovel", "Ruby Shovel",
    "Abyssal Shovel", "Bell Shovel", "Magnet Shovel", "Jam Shovel",
    "Candlelight Shovel", "Spore Spade", "Slayers Shovel", "Arachnid Shovel",
    "Shortcake Shovel", "Pizza Roller", "Rock Splitter", "Archaic Shovel",
    "Frigid Shovel", "Venomous Shovel", "Gold Digger", "Obsidian Shovel",
    "Prismatic Shovel", "Beast Slayer", "Solstice Shovel", "Glinted Shovel",
    "Draconic Shovel", "Monstrous Shovel", "Starfire Shovel"
}
function equipAnyShovel()
    for _, tool in ipairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, name in ipairs(shovelNames) do
                if tool.Name == name then
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Backpack_Equip"):FireServer(tool)
                    return
                end
            end
        end
    end
end
function unequip()
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Backpack_Equip"):FireServer(nil)
end
FarmTab:CreateToggle({
    Name = "Auto Equip Shovel",
    CurrentValue = false,
    Callback = function(state)
        autoEquipEnabled = state
        if state then
            equipAnyShovel()
            backpackConn = Backpack.ChildAdded:Connect(function(child)
                if autoEquipEnabled then
                    task.wait(0.1)
                    equipAnyShovel()
                end
            end)
        else
            unequip()
            if backpackConn then
                backpackConn:Disconnect()
                backpackConn = nil
            end
        end
    end,
})

-- Mecahnic Tab
local MecahnicTab = Window:CreateTab("Others")
local vehicleList = {
    "ATV", "Golf Cart", "Koi Truck", "Commander", "Silver",
    "Pulse", "Rumbler", "Test", "DMW M3", "Elite 6x6",
    "Forklift", "The Ox", "Roadster RS", "Tornado", "McBruce 700", "Monster Silver"
}
local VehicleSpawn = ReplicatedStorage.Remotes:FindFirstChild("Vehicle_Spawn")
local AvaRoot = Workspace:WaitForChild("World"):WaitForChild("NPCs"):WaitForChild("Ava Carter"):WaitForChild("HumanoidRootPart")
if not VehicleSpawn then
    warn("Vehicle_Spawn remote tidak ditemukan!")
end
for _, vehicleName in ipairs(vehicleList) do
    MecahnicTab:CreateButton({
        Name = "Spawn: " .. vehicleName,
        Callback = function()
            if VehicleSpawn then
                VehicleSpawn:FireServer(vehicleName, AvaRoot, {})
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Spawn Mobil",
                    Text = "Spawned: " .. vehicleName,
                    Duration = 3
                })
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Error",
                    Text = "Remote Vehicle_Spawn tidak ditemukan!",
                    Duration = 3
                })
            end
        end,
    })
end

-- Shop Tab
local ShopTab = Window:CreateTab("Shop")
local noclipConn
local function setNoclip(state)
    if state then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(11)
            end
        end)
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
    end
end
local function tpWithNoclip(x, y, z, name)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        setNoclip(true)
        hrp.CFrame = CFrame.new(x, y, z)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Teleport",
            Text = " Teleported to " .. name,
            Duration = 3
        })
        task.delay(0.5, function()
            setNoclip(false)
        end)
    end
end
local teleports = {
    {"Bejeweled Shovel", 31.2093, 3.0318, 39.8111},
    {"Training Shovel", 2121.1235, 112.5746, -298.7560},
    {"Toy Shovel", 2119.4553, 113.6495, -298.0141},
    {"Copper Shovel", 15.2426, 61.0899, 4.8759},
    {"Rock Shovel", 2112.3464, 112.6290, -294.7606},
    {"Lucky Shovel", 2111.1553, 113.5927, -294.1081},
    {"Ruby Shovel", 1327.8562, 81.1430, 542.9059},
    {"Bell Shovel", 1329.5909, 83.6888, 541.6209},
    {"Magnet Shovel", 2853.4087, -360.5666, -883.8994},
    {"Jam Shovel", 3522.3616, 84.9355, 1528.2647},
    {"Candlelight Shovel", 17.4070, 3.7727, 146.4270},
    {"Spore Shovel", 3987.8251, 227.6757, -141.8380},
    {"Slayers Shovel", 2516.5246, 89.4888, 1301.1907},
    {"Arachnid Shovel", -822.2592, 17.3944, 1260.7221},
    {"Shortcake Shovel", 484.3059, 5.5491, -284.0187},
    {"Rock Splitter", 134.4634, 5.6453, -45.0966},
    {"Archaic Shovel", -6108.1030, 119.4773, -1907.2861},
    {"Frigid Shovel", 6523.1782, 2612.3432, -2949.0361},
    {"Venomous Shovel", 16.9659, 5.5344, 32.9641},
    {"Gold Digger", 62.6586, 5.3908, 51.6359},
    {"Obsidian Shovel", -8022.6240, 342.8148, -1791.4763},
    {"Prismatic Shovel", 5131.5590, 1113.0532, -2105.3071},
    {"Beast Slayer", 128.5010, 7.1945, 19.1139},
    {"Solstice Shovel", 5567.9575, -394.3601, -1912.5024},
    {"Glinted Shovel", -6177.6743, 1630.6092, -1842.7865},
    {"Draconic Shovel", -8571.2793, 391.2796, -2133.6345},
    {"Starline Shovel", -2.5368, -68.4143, 1.2173}
}
for _, data in ipairs(teleports) do
    ShopTab:CreateButton({
        Name = "Teleport To " .. data[1],
        Callback = function()
            tpWithNoclip(data[2], data[3], data[4], data[1])
        end,
    })
end
ShopTab:CreateButton({
    Name = "Teleport to Traveling Merchant",
    Callback = function()
        local merchant = Workspace:FindFirstChild("World")
        if merchant then merchant = merchant:FindFirstChild("NPCs") end
        if merchant then merchant = merchant:FindFirstChild("Merchant Cart") end
        if merchant then merchant = merchant:FindFirstChild("Traveling Merchant") end
        if merchant and merchant:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = merchant.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            warn(" Teleported to Traveling Merchant!")
        else
            warn(" Traveling Merchant not found.")
        end
    end,
})

-- Misc/Player Tab
local MiscTab = Window:CreateTab("Misc/Player")
local staffList = {129332660, 146089324, 556677889}
local notifyStaffEnabled = true
local staffAction = "Notify"
local function handleStaff(p)
    if not notifyStaffEnabled then return end
    for _, id in ipairs(staffList) do
        if p.UserId == id then
            if staffAction == "Notify" then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = " Staff Joined The Server",
                    Text = p.Name .. " (ID: " .. id .. ") terdeteksi sebagai staff.",
                    Duration = 6
                })
            elseif staffAction == "Kick" then
                LocalPlayer:Kick("Staff terdeteksi di server: " .. p.Name)
            end
            break
        end
    end
end
Players.PlayerAdded:Connect(handleStaff)
for _, p in ipairs(Players:GetPlayers()) do
    handleStaff(p)
end
MiscTab:CreateToggle({
    Name = "Anti Staff",
    CurrentValue = true,
    Callback = function(Value)
        notifyStaffEnabled = Value
        if Value then
            for _, p in ipairs(Players:GetPlayers()) do
                handleStaff(p)
            end
        end
    end,
})
MiscTab:CreateDropdown({
    Name = "Choose Staff Method",
    Options = {"Notify", "Kick"},
    CurrentOption = "Notify",
    Callback = function(Option)
        staffAction = Option
    end,
})
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local godModeEnabled = false
local function setGodMode(enable)
    if enable then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
    else
        Humanoid.MaxHealth = 100
        Humanoid.Health = 100
    end
end
Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
    if godModeEnabled and Humanoid.Health < math.huge then
        Humanoid.Health = math.huge
    end
end)
Humanoid.Died:Connect(function()
    if godModeEnabled then
        task.wait(1)
        LocalPlayer:LoadCharacter()
    end
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    if godModeEnabled then
        setGodMode(true)
        Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if godModeEnabled and Humanoid.Health < math.huge then
                Humanoid.Health = math.huge
            end
        end)
        Humanoid.Died:Connect(function()
            if godModeEnabled then
                task.wait(1)
                LocalPlayer:LoadCharacter()
            end
        end)
    end
end)
MiscTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Callback = function(state)
        godModeEnabled = state
        if state then
            setGodMode(true)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "God Mode",
                Text = "God Mode ",
                Duration = 3
            })
        else
            setGodMode(false)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "God Mode",
                Text = "God Mode ",
                Duration = 3
            })
        end
    end,
})
local noclipEnabled = false
MiscTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(state)
        noclipEnabled = state
        if state then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Noclip",
                Text = "Noclip",
                Duration = 3
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Noclip",
                Text = "Noclip.",
                Duration = 3
            })
            if Character then
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})
RunService.Stepped:Connect(function()
    if noclipEnabled and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
getgenv().WalkSpeedEnabled = false
getgenv().JumpPowerEnabled = false
local walkSpeedValue = 16
local jumpPowerValue = 50
MiscTab:CreateToggle({
    Name = "WalkSpeed",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().WalkSpeedEnabled = Value
    end,
})
MiscTab:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(Value)
        walkSpeedValue = Value
    end,
})
MiscTab:CreateToggle({
    Name = "JumpPower",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().JumpPowerEnabled = Value
    end,
})
MiscTab:CreateSlider({
    Name = "JumpPower Value",
    Range = {50, 200},
    Increment = 1,
    Suffix = "Power",
    CurrentValue =50,
    Callback = function(Value)
        jumpPowerValue = Value
    end,
})
RunService.RenderStepped:Connect(function()
    if not Character or not Humanoid or Humanoid.Parent ~= Character then
        Character = LocalPlayer.Character
        if Character then
            Humanoid = Character:FindFirstChildOfClass("Humanoid")
        end
    end
    if Humanoid then
        if getgenv().WalkSpeedEnabled then
            Humanoid.WalkSpeed = walkSpeedValue
        else
            Humanoid.WalkSpeed = 16
        end
        if getgenv().JumpPowerEnabled then
            Humanoid.JumpPower = jumpPowerValue
        else
            Humanoid.JumpPower = 50
        end
    end
end)
MiscTab:CreateButton({
    Name = "Boost FPS",
    Callback = function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        Lighting.Brightness = 1
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then
                v.Enabled = false
            end
        end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0.5
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Boost FPS",
            Text = "Boost FPS .",
            Duration = 3
        })
    end,
})

-- Inventory Tab
local InventoryTab = Window:CreateTab("Inventory")
local Rocky = Workspace:WaitForChild("World"):WaitForChild("NPCs"):WaitForChild("Rocky")
local SellAllItems = ReplicatedStorage:WaitForChild("DialogueRemotes"):WaitForChild("SellAllItems")
getgenv().autoSell = false
getgenv().sellDelay = 3
InventoryTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().autoSell = Value
    end,
})
InventoryTab:CreateSlider({
    Name = "Auto Sell Delay (s)",
    Range = {1, 60},
    Increment = 1,
    Suffix = "s",
    CurrentValue = 3,
    Callback = function(Value)
        getgenv().sellDelay = Value
    end,
})
task.spawn(function()
    while task.wait(1) do
        if getgenv().autoSell then
            SellAllItems:FireServer(Rocky)
            task.wait(getgenv().sellDelay)
        end
    end
end)

-- Magnets Tab
local MagnetsTab = Window:CreateTab("Magnets")
local playerName = player.Name
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local function equipMagnet(magnetName)
    local magnet = ReplicatedStorage:WaitForChild("PlayerStats"):WaitForChild(playerName):WaitForChild("Inventory"):WaitForChild("Magnets"):FindFirstChild(magnetName)
    if magnet then
        remotes:WaitForChild("Magnet_Equip"):FireServer(magnet)
    end
end
MagnetsTab:CreateButton({ Name = "Prismatic Magnet", Callback = function() equipMagnet("Prismatic Magnet") end })
MagnetsTab:CreateButton({ Name = "Crimsonsteel Magnet", Callback = function() equipMagnet("Crimsonsteel Magnet") end })
MagnetsTab:CreateButton({ Name = "Magic Magnet", Callback = function() equipMagnet("Magic Magnet") end })
MagnetsTab:CreateButton({ Name = "Golden Horseshoe", Callback = function() equipMagnet("Golden Horseshoe") end })
MagnetsTab:CreateButton({ Name = "Legendary Magnet", Callback = function() equipMagnet("Legendary Magnet") end })
MagnetsTab:CreateButton({ Name = "Fossil Brush", Callback = function() equipMagnet("Fossil Brush") end })
MagnetsTab:CreateButton({ Name = "Fortuned Magnet", Callback = function() equipMagnet("Fortuned Magnet") end })
MagnetsTab:CreateButton({ Name = "Brass Magnet", Callback = function() equipMagnet("Brass Magnet") end })
MagnetsTab:CreateButton({ Name = "Ghost Magnet", Callback = function() equipMagnet("Ghost Magnet") end })
MagnetsTab:CreateButton({ Name = "Odd Mushroom", Callback = function() equipMagnet("Odd Mushroom") end })
MagnetsTab:CreateButton({ Name = "Green Magnet", Callback = function() equipMagnet("Green Magnet") end })
MagnetsTab:CreateButton({ Name = "Light Bulb", Callback = function() equipMagnet("Light Bulb") end })
MagnetsTab:CreateButton({ Name = "Red Magnet", Callback = function() equipMagnet("Red Magnet") end })
MagnetsTab:CreateButton({ Name = "Basic Magnet", Callback = function() equipMagnet("Basic Magnet") end })

-- Teleport Bosses Tab
local TeleportBossesTab = Window:CreateTab("Teleport Bosses")
TeleportBossesTab:CreateButton({
    Name = "Teleport to King Crab",
    Callback = function()
        local bossSpawns = Workspace:FindFirstChild("Spawns")
        if bossSpawns then bossSpawns = bossSpawns:FindFirstChild("BossSpawns") end
        local boss = bossSpawns and bossSpawns:FindFirstChild("King Crab")
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            warn(" Teleported to King Crab!")
        else
            warn(" King Crab not here.")
        end
    end,
})
TeleportBossesTab:CreateButton({
    Name = "Teleport to Candlelight Phantom",
    Callback = function()
        local boss
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Candlelight Phantom" and obj:FindFirstChild("HumanoidRootPart") then
                boss = obj
                break
            end
        end
        if boss then
            player.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            warn(" Teleported to Candlelight Phantom!")
        else
            warn(" Candlelight Phantom not found.")
        end
    end,
})
TeleportBossesTab:CreateButton({
    Name = "Teleport to Molten Monstrosity",
    Callback = function()
        local charging = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(-8797.094, 434.878, -1919.448, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        end
    end,
})
TeleportBossesTab:CreateButton({
    Name = "Teleport to Basilisk",
    Callback = function()
        local bossSpawns = Workspace:FindFirstChild("Spawns")
        if bossSpawns then bossSpawns = bossSpawns:FindFirstChild("BossSpawns") end
        local boss = bossSpawns and bossSpawns:FindFirstChild("Basilisk")
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            warn(" Teleported to Basilisk!")
        else
            warn(" Basilisk not found.")
        end
    end,
})
TeleportBossesTab:CreateButton({
    Name = "Teleport to Dire Wolf",
    Callback = function()
        local bossSpawns = Workspace:FindFirstChild("Spawns")
        if bossSpawns then bossSpawns = bossSpawns:FindFirstChild("BossSpawns") end
        local boss = bossSpawns and bossSpawns:FindFirstChild("Dire Wolf")
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            warn(" Teleported to Dire Wolf!")
        else
            warn(" Dire Wolf not found.")
        end
    end,
})
TeleportBossesTab:CreateButton({
    Name = "Teleport to Fuzzball",
    Callback = function()
        local bossSpawns = Workspace:FindFirstChild("Spawns")
        if bossSpawns then bossSpawns = bossSpawns:FindFirstChild("BossSpawns") end
        local boss = bossSpawns and bossSpawns:FindFirstChild("Fuzzball")
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            warn(" Teleported to Fuzzball!")
        else
            warn(" Fuzzball not found.")
        end
    end,
})
TeleportBossesTab:CreateButton({
    Name = "Teleport to Giant Spider",
    Callback = function()
        local bossSpawns = Workspace:FindFirstChild("Spawns")
        if bossSpawns then bossSpawns = bossSpawns:FindFirstChild("BossSpawns") end
        local boss = bossSpawns and bossSpawns:FindFirstChild("Giant Spider")
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            warn(" Teleported to Giant Spider!")
        else
            warn(" Giant Spider not found.")
        end
    end,
})

-- Teleport Npc Tab
local TeleportNpcTab = Window:CreateTab("Teleport Npc")
local npcsFolder = Workspace:WaitForChild("World"):WaitForChild("NPCs")
local function teleportToNPC(npcName)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    for _, npc in ipairs(npcsFolder:GetDescendants()) do
        if npc:IsA("Model") and npc.Name:lower():match(npcName:lower()) then
            local targetPart = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if targetPart then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
            end
            break
        end
    end
end
local npcNames = {
    "Sydney", "Roger Star", "Ava Carter", "Berry Dust", "Cole Blood", "Cave Worker", "Carly Enzo", "Malcom Wheels",
    "Annie Rae", "Magnus", "Mushroom Azali", "Penguin Mechanic", "Banker", "Gary Bull", "Tribes Mate", "Discoshroom",
    "John", "Mark Lever", "Max", "Ethan Bands", "Jane", "Blueshroom", "Brooke Kali", "Smith", "Dani Snow", "Grant Thorn",
    "Will", "Stranded Steve", "Drawstick Liz", "Ferry Conductor", "Steve Levi", "Sam Colby", "Mushroom Researcher",
    "Tom Baker", "Penguin Customer", "Pete R.", "Arthur Dig", "Granny Glenda", "Collin", "Cindy", "Jenn Diamond",
    "Tribe Leader", "Mourning Family Member", "Young Guitarist", "Bu Ran", "Billy Joe", "Andy", "Soten Ran", "Mrs.Salty",
    "Merchant Cart.Traveling Merchant", "Rocky", "Nate", "Blueshroom Merchant", "Barry", "Kira Pale", "Kei Ran", "Hale",
    "Darren", "Jim Diamond", "Ben Bones.Ben Bones", "Andrew", "Old Blueshroom", "Jie Ran", "Silver", "O'Myers", "Erin Field",
    "Pizza Penguin", "Lexi Star", "Ninja Deciple", "Mrs.Tiki", "Purple Imp", "Albert"
}
for _, npcName in ipairs(npcNames) do
    TeleportNpcTab:CreateButton({
        Name = "Teleport To NPC " .. npcName,
        Callback = function()
            teleportToNPC(npcName)
        end,
    })
end

-- Teleport Island Tab
local TeleportIslandTab = Window:CreateTab("Teleport Island")
TeleportIslandTab:CreateButton({
    Name = "Teleport to Fox Town",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(2073.82324, 121.487457, -378.836548)
        end
    end,
})
TeleportIslandTab:CreateButton({
    Name = "Teleport to Verdant Vale",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(
                3548.83154, 82.0540695, 1330.61133,
                0.0363482684, 3.42970523e-08, 0.999339163,
                4.76747836e-16, 1, -3.43197293e-08,
                -0.999339163, 1.24746324e-09, 0.0363482684
            )
        end
    end,
})
TeleportIslandTab:CreateButton({
    Name = "Teleport to Mount Cinder",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(
                4576.03955, 1101.71594, -1708.38879,
                -0.978816926, -5.98474876e-08, 0.20473747,
                -5.36289306e-08, 1, 3.59220316e-08,
                -0.20473747, 2.41812401e-08, -0.978816926
            )
        end
    end,
})
TeleportIslandTab:CreateButton({
    Name = "Teleport to Rooftop Woodlands",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(
                3895.53564, 225.724136, 375.536469,
                -0.352712542, -8.26963955e-08, -0.935731709,
                -6.85288555e-08, 1, -6.25450696e-08,
                0.935731709, 4.20641939e-08, -0.352712542
            )
        end
    end,
})

-- Boss Notification System
local bossesFolder = Workspace.World:WaitForChild("NPCs")
local bossesToWatch = {
    ["Molten Monstrosity"] = true,
    ["A King Crab"] = true,
    ["Fuzzball"] = true,
    ["Candlelight Phantom"] = true,
    ["Giant Spider"] = true,
    ["Basilisk"] = true,
}
local function notifyBoss(name)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Boss Spawned!",
        Text = name .. " has spawned!",
        Duration = 5
    })
end
for _, v in ipairs(bossesFolder:GetChildren()) do
    if bossesToWatch[v.Name] then
        notifyBoss(v.Name)
    end
end
bossesFolder.ChildAdded:Connect(function(child)
    if bossesToWatch[child.Name] then
        notifyBoss(child.Name)
    end
end)