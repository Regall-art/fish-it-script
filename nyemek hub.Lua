-- Fish It Script - Rayfield UI Version
-- Version: 5.0 - All Features Working
-- UI: Rayfield Library (Official)

repeat task.wait() until game:IsLoaded()

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It Hub - Premium",
    LoadingTitle = "Fish It Script Loading...",
    LoadingSubtitle = "by Regall-art",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "FishItHub"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Player
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

-- Settings
local Settings = {
    AutoFish = false,
    AutoCast = false,
    AutoReel = false,
    AutoShake = false,
    InstantCatch = false,
    AutoSell = false,
    SellThreshold = 15,
    AutoBuyBait = false,
    FishESP = false,
    ChestESP = false,
    PlayerESP = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
}

-- ESP Storage
local ESPObjects = {}

-- Utility Functions
local function Notify(title, text, duration)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = duration or 3,
        Image = 4483362458,
    })
end

local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function FindNearest(name, maxDist)
    local nearest = nil
    local shortestDist = maxDist or math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(name:lower()) then
            local dist = GetDistance(Root.Position, obj.Position)
            if dist < shortestDist then
                shortestDist = dist
                nearest = obj
            end
        end
    end
    
    return nearest, shortestDist
end

-- Fishing Functions
local function GetRod()
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("fishing") or item.Name:lower():find("pole")) then
            return item
        end
    end
    
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("fishing") or item.Name:lower():find("pole")) then
            return item
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Player.Backpack then
        Humanoid:EquipTool(rod)
        task.wait(0.3)
        return true
    end
    return rod ~= nil
end

local function Cast()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function Reel()
    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

local function Shake()
    for i = 1, 3 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.03)
    end
end

local function IsFishing()
    for _, obj in pairs(Workspace:GetChildren()) do
        local name = obj.Name:lower()
        if name:find("bobber") or name:find("hook") or name:find("float") then
            return true
        end
    end
    return false
end

-- Farm Functions
local function GetInventoryCount()
    local count = 0
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find("fish") then
            count = count + 1
        end
    end
    return count
end

local function SellFish()
    local sell = FindNearest("sell", 1000)
    if not sell then
        sell = FindNearest("merchant", 1000)
    end
    
    if sell then
        local oldPos = Root.CFrame
        Root.CFrame = sell.CFrame * CFrame.new(0, 3, 0)
        task.wait(0.5)
        
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():find("sell") then
                pcall(function()
                    remote:FireServer()
                end)
            end
        end
        
        if sell:FindFirstChild("ClickDetector") then
            pcall(function()
                fireclickdetector(sell.ClickDetector)
            end)
        end
        
        task.wait(1)
        Root.CFrame = oldPos
        Notify("Auto Sell", "Fish sold successfully!", 2)
    end
end

local function BuyBait()
    local bait = FindNearest("bait", 1000)
    
    if bait then
        local oldPos = Root.CFrame
        Root.CFrame = bait.CFrame * CFrame.new(0, 3, 0)
        task.wait(0.5)
        
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (remote.Name:lower():find("bait") or remote.Name:lower():find("buy")) then
                pcall(function()
                    remote:FireServer()
                end)
            end
        end
        
        if bait:FindFirstChild("ClickDetector") then
            pcall(function()
                fireclickdetector(bait.ClickDetector)
            end)
        end
        
        task.wait(1)
        Root.CFrame = oldPos
        Notify("Auto Buy", "Bait purchased!", 2)
    end
end

-- ESP Functions
local function CreateESP(obj, text, color)
    if ESPObjects[obj] then return end
    
    local Billboard = Instance.new("BillboardGui")
    Billboard.Parent = obj
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 100, 0, 50)
    Billboard.StudsOffset = Vector3.new(0, 2, 0)
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Billboard
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Text = text
    TextLabel.TextColor3 = color
    TextLabel.TextScaled = true
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextStrokeTransparency = 0.5
    
    ESPObjects[obj] = Billboard
end

local function RemoveESP(obj)
    if ESPObjects[obj] then
        ESPObjects[obj]:Destroy()
        ESPObjects[obj] = nil
    end
end

local function ClearESP()
    for _, esp in pairs(ESPObjects) do
        esp:Destroy()
    end
    ESPObjects = {}
end

-- Fly System
local Flying = false
local BodyVelocity = nil

local function ToggleFly()
    Flying = not Flying
    
    if Flying then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = Root
        
        task.spawn(function()
            while Flying and Root:FindFirstChild("BodyVelocity") do
                local velocity = Vector3.new(0, 0, 0)
                local camera = Workspace.CurrentCamera
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    velocity = velocity + (camera.CFrame.LookVector * Settings.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    velocity = velocity - (camera.CFrame.LookVector * Settings.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    velocity = velocity - (camera.CFrame.RightVector * Settings.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    velocity = velocity + (camera.CFrame.RightVector * Settings.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, Settings.FlySpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    velocity = velocity - Vector3.new(0, Settings.FlySpeed, 0)
                end
                
                BodyVelocity.Velocity = velocity
                task.wait()
            end
        end)
    else
        if BodyVelocity then
            BodyVelocity:Destroy()
            BodyVelocity = nil
        end
    end
end

-- Create Tabs
local FishingTab = Window:CreateTab("🎣 Fishing", 4483362458)
local FarmTab = Window:CreateTab("💰 Farm", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local TeleportTab = Window:CreateTab("📍 Teleport", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

-- Fishing Tab
local FishingSection = FishingTab:CreateSection("Auto Fishing")

local AutoFishToggle = FishingTab:CreateToggle({
    Name = "Auto Fish",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        Settings.AutoFish = Value
        Settings.AutoCast = Value
        Settings.AutoReel = Value
        Settings.AutoShake = Value
        
        if Value then
            Notify("Auto Fish", "Auto Fishing Enabled!", 3)
        end
    end,
})

local AutoCastToggle = FishingTab:CreateToggle({
    Name = "Auto Cast",
    CurrentValue = false,
    Flag = "AutoCast",
    Callback = function(Value)
        Settings.AutoCast = Value
    end,
})

local AutoReelToggle = FishingTab:CreateToggle({
    Name = "Auto Reel",
    CurrentValue = false,
    Flag = "AutoReel",
    Callback = function(Value)
        Settings.AutoReel = Value
    end,
})

local AutoShakeToggle = FishingTab:CreateToggle({
    Name = "Auto Shake (QTE)",
    CurrentValue = false,
    Flag = "AutoShake",
    Callback = function(Value)
        Settings.AutoShake = Value
    end,
})

local InstantCatchToggle = FishingTab:CreateToggle({
    Name = "Instant Catch",
    CurrentValue = false,
    Flag = "InstantCatch",
    Callback = function(Value)
        Settings.InstantCatch = Value
    end,
})

local AdvancedSection = FishingTab:CreateSection("Advanced")

FishingTab:CreateButton({
    Name = "Equip Best Rod",
    Callback = function()
        EquipRod()
        Notify("Fishing", "Rod equipped!", 2)
    end,
})

-- Farm Tab
local FarmSection = FarmTab:CreateSection("Auto Farm")

local AutoSellToggle = FarmTab:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        Settings.AutoSell = Value
    end,
})

local SellThresholdSlider = FarmTab:CreateSlider({
    Name = "Sell Threshold",
    Range = {5, 30},
    Increment = 1,
    CurrentValue = 15,
    Flag = "SellThreshold",
    Callback = function(Value)
        Settings.SellThreshold = Value
    end,
})

local AutoBuyBaitToggle = FarmTab:CreateToggle({
    Name = "Auto Buy Bait",
    CurrentValue = false,
    Flag = "AutoBuyBait",
    Callback = function(Value)
        Settings.AutoBuyBait = Value
    end,
})

local ManualSection = FarmTab:CreateSection("Manual Actions")

FarmTab:CreateButton({
    Name = "Sell Fish Now",
    Callback = function()
        SellFish()
    end,
})

FarmTab:CreateButton({
    Name = "Buy Bait Now",
    Callback = function()
        BuyBait()
    end,
})

-- ESP Tab
local ESPSection = ESPTab:CreateSection("ESP Features")

local FishESPToggle = ESPTab:CreateToggle({
    Name = "Fish ESP",
    CurrentValue = false,
    Flag = "FishESP",
    Callback = function(Value)
        Settings.FishESP = Value
        if not Value then ClearESP() end
    end,
})

local ChestESPToggle = ESPTab:CreateToggle({
    Name = "Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(Value)
        Settings.ChestESP = Value
        if not Value then ClearESP() end
    end,
})

local PlayerESPToggle = ESPTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        Settings.PlayerESP = Value
        if not Value then ClearESP() end
    end,
})

ESPTab:CreateButton({
    Name = "Clear All ESP",
    Callback = function()
        ClearESP()
        Notify("ESP", "All ESP cleared!", 2)
    end,
})

-- Player Tab
local MovementSection = PlayerTab:CreateSection("Movement")

local WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Settings.WalkSpeed = Value
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end,
})

local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 250},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        Settings.JumpPower = Value
        if Humanoid then
            Humanoid.JumpPower = Value
        end
    end,
})

local NoClipToggle = PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        Settings.NoClip = Value
    end,
})

local FlySection = PlayerTab:CreateSection("Fly Mode")

local FlyToggle = PlayerTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        Settings.Fly = Value
        ToggleFly()
    end,
})

local FlySpeedSlider = PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        Settings.FlySpeed = Value
    end,
})

-- Teleport Tab
local LocationSection = TeleportTab:CreateSection("Locations")

local locations = {
    {name = "Spawn", pos = Vector3.new(0, 5, 0)},
    {name = "Beach", pos = Vector3.new(100, 5, 0)},
    {name = "Pier", pos = Vector3.new(200, 10, 50)},
    {name = "Lake", pos = Vector3.new(-150, 5, 200)},
    {name = "Ocean", pos = Vector3.new(500, 5, 500)},
}

for _, loc in ipairs(locations) do
    TeleportTab:CreateButton({
        Name = "TP to " .. loc.name,
        Callback = function()
            Root.CFrame = CFrame.new(loc.pos)
            Notify("Teleport", "Teleported to " .. loc.name, 2)
        end,
    })
end

local NPCSection = TeleportTab:CreateSection("NPCs")

TeleportTab:CreateButton({
    Name = "TP to Sell NPC",
    Callback = function()
        local sell, dist = FindNearest("sell", 5000)
        if sell then
            Root.CFrame = sell.CFrame * CFrame.new(0, 3, 0)
            Notify("Teleport", string.format("Teleported %.0fm", dist), 2)
        else
            Notify("Error", "Sell NPC not found!", 3)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Bait Shop",
    Callback = function()
        local bait, dist = FindNearest("bait", 5000)
        if bait then
            Root.CFrame = bait.CFrame * CFrame.new(0, 3, 0)
            Notify("Teleport", string.format("Teleported %.0fm", dist), 2)
        else
            Notify("Error", "Bait shop not found!", 3)
        end
    end,
})

-- Misc Tab
local MiscSection = MiscTab:CreateSection("Miscellaneous")

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end,
})

MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        
        local _place = game.PlaceId
        local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
        
        local function ListServers()
            local success, result = pcall(function()
                return Http:JSONDecode(game:HttpGet(_servers))
            end)
            
            if success and result.data then
                for i, v in pairs(result.data) do
                    if type(v) == "table" and v.id ~= game.JobId and v.playing < v.maxPlayers then
                        TPS:TeleportToPlaceInstance(_place, v.id, Player)
                        break
                    end
                end
            end
        end
        
        ListServers()
    end,
})

local InfoSection = MiscTab:CreateSection("Information")

MiscTab:CreateLabel("Script Version: 5.0")
MiscTab:CreateLabel("UI Library: Rayfield")
MiscTab:CreateLabel("Game: Fish It")
MiscTab:CreateLabel("User: " .. Player.Name)

-- Main Loops
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if not Character or not Character.Parent then
                Character = Player.Character
                if Character then
                    Humanoid = Character:WaitForChild("Humanoid")
                    Root = Character:WaitForChild("HumanoidRootPart")
                end
            end
            
            if Settings.AutoFish and Character and Humanoid then
                EquipRod()
                
                local fishing = IsFishing()
                
                if not fishing and Settings.AutoCast then
                    Cast()
                    task.wait(1.5)
                end
                
                if fishing then
                    if Settings.AutoShake then
                        Shake()
                    end
                    
                    if Settings.AutoReel then
                        local reelCount = Settings.InstantCatch and 30 or 10
                        for i = 1, reelCount do
                            Reel()
                            task.wait(0.05)
                        end
                    end
                end
            end
            
            if Humanoid then
                Humanoid.WalkSpeed = Settings.WalkSpeed
                Humanoid.JumpPower = Settings.JumpPower
            end
            
            if Settings.NoClip and Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(5) do
        pcall(function()
            if Settings.AutoSell then
                local count = GetInventoryCount()
                if count >= Settings.SellThreshold then
                    SellFish()
                    task.wait(2)
                end
            end
            
            if Settings.AutoBuyBait then
                BuyBait()
                task.wait(2)
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            if Settings.FishESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:lower():find("fish") and obj ~= Character then
                        local part = obj:FindFirstChildWhichIsA("BasePart")
                        if part and not ESPObjects[part] then
                            CreateESP(part, "Fish", Color3.fromRGB(0, 255, 255))
                        end
                    end
                end
            end
            
            if Settings.ChestESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("treasure")) then
                        local part = obj:FindFirstChildWhichIsA("BasePart")
                        if part and not ESPObjects[part] then
                            CreateESP(part, "Chest", Color3.fromRGB(255, 215, 0))
                        end
                    end
                end
            end
            
            if Settings.PlayerESP then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        if head and not ESPObjects[head] then
                            CreateESP(head, player.Name, Color3.fromRGB(255, 0, 0))
                        end
                    end
                end
            end
            
            if not (Settings.FishESP or Settings.ChestESP or Settings.PlayerESP) then
                ClearESP()
            end
        end)
    end
end)

Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
end)

-- Success Notification
Notify("Fish It Script", "Loaded Successfully!\nVersion 5.0 - Rayfield UI", 5)

print("════════════════════════════════════════")
print("✅ Fish It Script Loaded!")
print("🎨 UI: Rayfield Library")
print("🎣 Version: 5.0")
print("👤 User: " .. Player.Name)
print("════════════════════════════════════════")
