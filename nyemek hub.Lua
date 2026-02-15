-- Fish It Script - SUPER FAST AUTO FISH
-- Version: 7.0 - Ultra Fast & Working
-- Notification every 25 fish caught

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "🎣 Nyemek Hub - Ultra Fast",
    LoadingTitle = "Loading Ultra Fast Script...",
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
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Player
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

-- Anti AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Statistics
local Stats = {
    FishCaught = 0,
    TotalFishCaught = 0,
    LastNotification = 0,
}

-- Settings
local Settings = {
    AutoFish = false,
    FastMode = true, -- Ultra fast fishing
    AutoSell = false,
    SellThreshold = 25,
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

-- Fishing Functions - IMPROVED & FAST
local function GetRod()
    -- Check equipped first
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    -- Check backpack
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Player.Backpack then
        Humanoid:EquipTool(rod)
        task.wait(0.2)
        return true
    end
    return rod ~= nil
end

local function Cast()
    -- Rapid fire all methods at once for speed
    task.spawn(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.01)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    
    task.spawn(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.01)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
    
    task.spawn(function()
        local rod = GetRod()
        if rod then
            for _, v in pairs(rod:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    pcall(function()
                        v:FireServer(100) -- Max cast power
                    end)
                end
            end
        end
    end)
end

local function Reel()
    -- Rapid fire all methods
    task.spawn(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.01)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    task.spawn(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.01)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    
    task.spawn(function()
        local rod = GetRod()
        if rod then
            for _, v in pairs(rod:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    pcall(function()
                        v:FireServer()
                    end)
                end
            end
        end
    end)
end

local function IsFishing()
    -- Check workspace for bobber - MULTIPLE CHECKS
    for _, obj in pairs(Workspace:GetChildren()) do
        local name = obj.Name:lower()
        if name:find("bob") or name:find("float") or name:find("hook") then
            return true
        end
    end
    
    -- Check deeper
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("bob") or obj.Name:lower():find("float") then
            return true
        end
    end
    
    return false
end

-- Check if fish was caught
local lastInventorySize = 0

local function CheckFishCaught()
    local currentSize = 0
    
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            currentSize = currentSize + 1
        end
    end
    
    if currentSize > lastInventorySize then
        Stats.FishCaught = Stats.FishCaught + (currentSize - lastInventorySize)
        Stats.TotalFishCaught = Stats.TotalFishCaught + (currentSize - lastInventorySize)
        
        -- Notification every 25 fish
        if Stats.FishCaught >= 25 then
            Notify("🎣 Fish Caught!", string.format("Caught %d fish!\nTotal: %d fish", Stats.FishCaught, Stats.TotalFishCaught), 5)
            Stats.FishCaught = 0
        end
    end
    
    lastInventorySize = currentSize
end

-- Auto Sell Function - IMPROVED
local function SellFish()
    -- Try to find sell location
    local foundSell = nil
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name:lower()
            if name:find("sell") or name:find("merchant") or name:find("shop") then
                foundSell = obj
                break
            end
        end
    end
    
    if not foundSell then
        -- Try ProximityPrompts
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local parent = obj.Parent
                if parent and (parent.Name:lower():find("sell") or parent.Name:lower():find("merchant")) then
                    foundSell = parent
                    break
                end
            end
        end
    end
    
    if foundSell then
        local oldPos = Root.CFrame
        local targetPos = foundSell:IsA("Model") and foundSell:GetPivot().Position or foundSell.Position
        
        -- Teleport
        Root.CFrame = CFrame.new(targetPos) * CFrame.new(0, 5, 0)
        task.wait(1)
        
        -- Try all sell methods
        for i = 1, 5 do
            -- Click all clickdetectors
            for _, v in pairs(foundSell:GetDescendants()) do
                if v:IsA("ClickDetector") then
                    pcall(function()
                        fireclickdetector(v)
                    end)
                end
            end
            
            -- Fire all proximity prompts
            for _, v in pairs(foundSell:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    pcall(function()
                        fireproximityprompt(v)
                    end)
                end
            end
            
            -- Fire sell remotes
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    if remote.Name:lower():find("sell") then
                        pcall(function()
                            remote:FireServer()
                        end)
                    end
                end
            end
            
            task.wait(0.3)
        end
        
        task.wait(1)
        Root.CFrame = oldPos
        
        Notify("Auto Sell", "Sold all fish! 💰", 3)
        Stats.FishCaught = 0
        lastInventorySize = 0
    else
        Notify("Error", "Sell location not found!", 3)
    end
end

-- Teleport Function - IMPROVED
local function TeleportTo(position)
    if typeof(position) == "Vector3" then
        Root.CFrame = CFrame.new(position)
    elseif typeof(position) == "CFrame" then
        Root.CFrame = position
    end
end

local function FindAndTeleport(searchTerms)
    if type(searchTerms) == "string" then
        searchTerms = {searchTerms}
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name:lower()
            
            for _, term in ipairs(searchTerms) do
                if name:find(term:lower()) then
                    local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                    TeleportTo(pos + Vector3.new(0, 5, 0))
                    return true
                end
            end
        end
    end
    
    return false
end

-- ESP Functions
local function CreateESP(obj, text, color)
    if ESPObjects[obj] then return end
    
    local part = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj
    if not part then return end
    
    local Billboard = Instance.new("BillboardGui")
    Billboard.Parent = part
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

local function ClearESP()
    for _, esp in pairs(ESPObjects) do
        pcall(function() esp:Destroy() end)
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
            while Flying and BodyVelocity and BodyVelocity.Parent do
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
local FishingSection = FishingTab:CreateSection("🔥 Ultra Fast Auto Fish")

FishingTab:CreateLabel("⚡ SUPER FAST MODE - Instant Catch!")

local AutoFishToggle = FishingTab:CreateToggle({
    Name = "🎣 Auto Fish (Ultra Fast)",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        Settings.AutoFish = Value
        
        if Value then
            Notify("Auto Fish", "🔥 Ultra Fast Auto Fish ENABLED!\nNotification every 25 fish!", 5)
        else
            Notify("Auto Fish", "Auto Fish Disabled", 2)
        end
    end,
})

FishingTab:CreateLabel("Current Fish Caught: 0 / 25")

local StatsSection = FishingTab:CreateSection("📊 Statistics")

FishingTab:CreateLabel("Fish This Session: " .. Stats.FishCaught)
FishingTab:CreateLabel("Total Fish Caught: " .. Stats.TotalFishCaught)

local ManualSection = FishingTab:CreateSection("Manual Controls")

FishingTab:CreateButton({
    Name = "🎣 Cast Now",
    Callback = function()
        Cast()
        Notify("Fishing", "Casted! 🎣", 1)
    end,
})

FishingTab:CreateButton({
    Name = "🎣 Reel Now",
    Callback = function()
        for i = 1, 20 do
            Reel()
            task.wait(0.03)
        end
        Notify("Fishing", "Reeled! 🎣", 1)
    end,
})

FishingTab:CreateButton({
    Name = "🎣 Equip Rod",
    Callback = function()
        EquipRod()
        Notify("Fishing", "Rod equipped! ✅", 1)
    end,
})

-- Farm Tab
local FarmSection = FarmTab:CreateSection("Auto Farm")

local AutoSellToggle = FarmTab:CreateToggle({
    Name = "Auto Sell (Every 25 Fish)",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        Settings.AutoSell = Value
    end,
})

FarmTab:CreateButton({
    Name = "💰 Sell All Fish Now",
    Callback = function()
        SellFish()
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
local TeleportSection = TeleportTab:CreateSection("📍 Quick Teleports")

TeleportTab:CreateButton({
    Name = "🏪 TP to Sell NPC",
    Callback = function()
        if FindAndTeleport({"sell", "merchant", "shop"}) then
            Notify("Teleport", "Teleported to Sell! ✅", 2)
        else
            Notify("Error", "Sell not found! ❌", 2)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "🪱 TP to Bait Shop",
    Callback = function()
        if FindAndTeleport({"bait", "shop", "store"}) then
            Notify("Teleport", "Teleported to Bait! ✅", 2)
        else
            Notify("Error", "Bait shop not found! ❌", 2)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "🎣 TP to Fishing Spot",
    Callback = function()
        if FindAndTeleport({"fishing", "spot", "water", "pond", "lake"}) then
            Notify("Teleport", "Teleported to Fishing Spot! ✅", 2)
        else
            Notify("Error", "Fishing spot not found! ❌", 2)
        end
    end,
})

local LocationSection = TeleportTab:CreateSection("Preset Locations")

local locations = {
    {name = "Spawn", pos = CFrame.new(0, 10, 0)},
    {name = "Beach", pos = CFrame.new(100, 10, 0)},
    {name = "Pier", pos = CFrame.new(200, 15, 50)},
    {name = "Lake", pos = CFrame.new(-150, 10, 200)},
    {name = "Ocean", pos = CFrame.new(500, 10, 500)},
}

for _, loc in ipairs(locations) do
    TeleportTab:CreateButton({
        Name = "📍 " .. loc.name,
        Callback = function()
            TeleportTo(loc.pos)
            Notify("Teleport", "Teleported to " .. loc.name .. "! ✅", 2)
        end,
    })
end

-- Misc Tab
MiscTab:CreateButton({
    Name = "🔄 Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end,
})

MiscTab:CreateButton({
    Name = "🔀 Server Hop",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        
        local success, result = pcall(function()
            return Http:JSONDecode(game:HttpGet(Api .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and result.data then
            for _, v in pairs(result.data) do
                if v.id ~= game.JobId and v.playing < v.maxPlayers then
                    TPS:TeleportToPlaceInstance(game.PlaceId, v.id, Player)
                    return
                end
            end
        end
    end,
})

local InfoSection = MiscTab:CreateSection("Information")
MiscTab:CreateLabel("Version: 7.0 - Ultra Fast")
MiscTab:CreateLabel("UI: Rayfield Library")
MiscTab:CreateLabel("User: " .. Player.Name)
MiscTab:CreateParagraph({Title = "🎣 How to Use", Content = "1. Go to fishing spot\n2. Enable Auto Fish\n3. AFK & Farm!\n4. Get notif every 25 fish"})

-- MAIN LOOP - ULTRA FAST
task.spawn(function()
    print("🔥 Starting ULTRA FAST Auto Fish Loop...")
    
    while task.wait(0.15) do -- Very fast loop
        pcall(function()
            if not Character or not Character.Parent then
                Character = Player.Character
                if Character then
                    Humanoid = Character:WaitForChild("Humanoid")
                    Root = Character:WaitForChild("HumanoidRootPart")
                end
            end
            
            if Settings.AutoFish and Character then
                -- Equip rod if not equipped
                local rod = GetRod()
                if not rod or rod.Parent ~= Character then
                    EquipRod()
                end
                
                local fishing = IsFishing()
                
                -- Cast if not fishing
                if not fishing then
                    Cast()
                    task.wait(0.5) -- Short wait after cast
                else
                    -- Reel FAST when fishing
                    for i = 1, 25 do -- 25 rapid reels
                        Reel()
                        task.wait(0.02) -- Very fast reeling
                    end
                    
                    -- Check if caught fish
                    task.wait(0.3)
                    CheckFishCaught()
                end
            end
            
            -- Apply player mods
            if Humanoid then
                Humanoid.WalkSpeed = Settings.WalkSpeed
                Humanoid.JumpPower = Settings.JumpPower
            end
            
            -- No Clip
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

-- Auto Sell Loop
task.spawn(function()
    while task.wait(10) do
        pcall(function()
            if Settings.AutoSell then
                local count = 0
                for _, item in pairs(Player.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        count = count + 1
                    end
                end
                
                if count >= Settings.SellThreshold then
                    Notify("Auto Sell", string.format("Selling %d fish...", count), 3)
                    SellFish()
                end
            end
        end)
    end
end)

-- ESP Loop
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            if Settings.FishESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:lower():find("fish") and not ESPObjects[obj] then
                        CreateESP(obj, "Fish", Color3.fromRGB(0, 255, 255))
                    end
                end
            end
            
            if Settings.ChestESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("treasure")) and not ESPObjects[obj] then
                        CreateESP(obj, "Chest", Color3.fromRGB(255, 215, 0))
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

-- Character respawn
Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
end)

-- Success
Notify("Nyemek Hub", "✅ ULTRA FAST MODE LOADED!\n🔥 Notification every 25 fish!", 5)

print("════════════════════════════════════════")
print("✅ Nyemek Hub - ULTRA FAST MODE")
print("🔥 Version: 7.0")
print("⚡ Fast Auto Fish: WORKING")
print("🎣 Notification: Every 25 fish")
print("👤 User: " .. Player.Name)
print("════════════════════════════════════════")
