-- Nyemek Hub Script - Nyemek Style Full Features
-- Version: 4.0 Premium
-- All Features Included

repeat task.wait() until game:IsLoaded()

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
getgenv().FishItSettings = getgenv().FishItSettings or {
    -- Auto Fishing
    AutoFish = false,
    AutoCast = false,
    AutoReel = false,
    AutoShake = false,
    InstantCatch = false,
    PerfectCatch = false,
    CastPower = 100,
    ReelSpeed = 10,
    
    -- Auto Farm
    AutoSell = false,
    SellThreshold = 15,
    AutoBuyBait = false,
    AutoEquipBestRod = false,
    AutoCollectTreasure = false,
    AutoCollectChest = false,
    
    -- ESP
    FishESP = false,
    ChestESP = false,
    TreasureESP = false,
    PlayerESP = false,
    NPCESP = false,
    
    -- Player
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteStamina = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 50,
    
    -- Teleport
    TeleportMethod = "Instant",
    
    -- Misc
    AntiAFK = true,
    AutoRejoin = false,
    HideGUI = false,
}

local S = getgenv().FishItSettings

-- ESP Storage
local ESPObjects = {}

-- Utility Functions
local Utils = {}

function Utils:Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
    })
end

function Utils:GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function Utils:Tween(obj, time, properties)
    local tween = TweenService:Create(obj, TweenInfo.new(time), properties)
    tween:Play()
    return tween
end

function Utils:FindNearest(name, maxDist)
    local nearest = nil
    local shortestDist = maxDist or math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(name:lower()) then
            local dist = Utils:GetDistance(Root.Position, obj.Position)
            if dist < shortestDist then
                shortestDist = dist
                nearest = obj
            end
        end
    end
    
    return nearest, shortestDist
end

-- Fishing System
local FishingSystem = {}

function FishingSystem:GetRod()
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

function FishingSystem:EquipRod()
    local rod = self:GetRod()
    if rod and rod.Parent == Player.Backpack then
        Humanoid:EquipTool(rod)
        task.wait(0.5)
        return true
    end
    return rod ~= nil
end

function FishingSystem:Cast()
    if self:GetRod() then
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        return true
    end
    return false
end

function FishingSystem:Reel()
    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

function FishingSystem:Shake()
    for i = 1, 5 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.03)
    end
end

function FishingSystem:IsFishing()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:lower():find("bobber") or obj.Name:lower():find("hook") then
            return true
        end
    end
    return false
end

function FishingSystem:GetBestRod()
    local rods = {}
    
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find("rod") then
            table.insert(rods, item)
        end
    end
    
    table.sort(rods, function(a, b)
        local tiers = {"wooden", "basic", "iron", "steel", "gold", "diamond", "crystal", "mythic", "legendary", "godly"}
        local aValue = 0
        local bValue = 0
        
        for i, tier in ipairs(tiers) do
            if a.Name:lower():find(tier) then aValue = i end
            if b.Name:lower():find(tier) then bValue = i end
        end
        
        return aValue > bValue
    end)
    
    return rods[1]
end

-- Farm System
local FarmSystem = {}

function FarmSystem:GetInventoryCount()
    local count = 0
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find("fish") then
            count = count + 1
        end
    end
    return count
end

function FarmSystem:SellFish()
    local sell, dist = Utils:FindNearest("sell", 1000)
    
    if not sell then
        sell, dist = Utils:FindNearest("merchant", 1000)
    end
    
    if sell then
        local oldPos = Root.CFrame
        
        Root.CFrame = sell.CFrame * CFrame.new(0, 3, 0)
        task.wait(0.5)
        
        -- Try to fire sell event
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():find("sell") then
                remote:FireServer()
            end
        end
        
        -- Try ClickDetector
        if sell:FindFirstChild("ClickDetector") then
            fireclickdetector(sell.ClickDetector)
        end
        
        task.wait(1)
        Root.CFrame = oldPos
        
        Utils:Notify("Auto Sell", "Fish sold successfully!", 2)
    end
end

function FarmSystem:BuyBait()
    local bait, dist = Utils:FindNearest("bait", 1000)
    
    if bait then
        local oldPos = Root.CFrame
        
        Root.CFrame = bait.CFrame * CFrame.new(0, 3, 0)
        task.wait(0.5)
        
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():find("bait") or remote.Name:lower():find("buy") then
                remote:FireServer()
            end
        end
        
        if bait:FindFirstChild("ClickDetector") then
            fireclickdetector(bait.ClickDetector)
        end
        
        task.wait(1)
        Root.CFrame = oldPos
    end
end

function FarmSystem:CollectTreasures()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("treasure") or obj.Name:lower():find("chest")) then
            local part = obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = Utils:GetDistance(Root.Position, part.Position)
                if dist < 50 then
                    Root.CFrame = part.CFrame
                    task.wait(0.3)
                    
                    if part:FindFirstChild("ClickDetector") then
                        fireclickdetector(part.ClickDetector)
                    end
                end
            end
        end
    end
end

-- ESP System
local ESPSystem = {}

function ESPSystem:Create(obj, text, color)
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
    
    task.spawn(function()
        while ESPObjects[obj] and obj.Parent do
            local dist = Utils:GetDistance(Root.Position, obj.Position)
            TextLabel.Text = string.format("%s\n[%.0fm]", text, dist)
            task.wait(1)
        end
    end)
end

function ESPSystem:Remove(obj)
    if ESPObjects[obj] then
        ESPObjects[obj]:Destroy()
        ESPObjects[obj] = nil
    end
end

function ESPSystem:Clear()
    for _, esp in pairs(ESPObjects) do
        esp:Destroy()
    end
    ESPObjects = {}
end

-- Player Mods
local PlayerMods = {}

PlayerMods.Flying = false
PlayerMods.BodyVelocity = nil

function PlayerMods:SetSpeed(speed)
    if Humanoid then
        Humanoid.WalkSpeed = speed
    end
end

function PlayerMods:SetJump(jump)
    if Humanoid then
        Humanoid.JumpPower = jump
    end
end

function PlayerMods:ToggleFly()
    self.Flying = not self.Flying
    
    if self.Flying then
        self.BodyVelocity = Instance.new("BodyVelocity")
        self.BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        self.BodyVelocity.Parent = Root
        
        task.spawn(function()
            while self.Flying and Root:FindFirstChild("BodyVelocity") do
                local velocity = Vector3.new(0, 0, 0)
                local camera = Workspace.CurrentCamera
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    velocity = velocity + (camera.CFrame.LookVector * S.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    velocity = velocity - (camera.CFrame.LookVector * S.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    velocity = velocity - (camera.CFrame.RightVector * S.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    velocity = velocity + (camera.CFrame.RightVector * S.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, S.FlySpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    velocity = velocity - Vector3.new(0, S.FlySpeed, 0)
                end
                
                self.BodyVelocity.Velocity = velocity
                task.wait()
            end
        end)
        
        Utils:Notify("Fly", "Fly Mode: ON", 2)
    else
        if self.BodyVelocity then
            self.BodyVelocity:Destroy()
            self.BodyVelocity = nil
        end
        Utils:Notify("Fly", "Fly Mode: OFF", 2)
    end
end

-- Teleport Locations
local TeleportLocations = {
    ["Spawn"] = Vector3.new(0, 5, 0),
    ["Beach"] = Vector3.new(100, 5, 0),
    ["Pier"] = Vector3.new(200, 10, 50),
    ["Lake"] = Vector3.new(-150, 5, 200),
    ["Ocean"] = Vector3.new(500, 5, 500),
    ["Deep Ocean"] = Vector3.new(1000, 5, 1000),
    ["River"] = Vector3.new(50, 5, 300),
    ["Pond"] = Vector3.new(-300, 5, -200),
}

-- GUI Creation
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FishItHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not ScreenGui.Parent then
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.3, 0, 0.2, 0)
    Main.Size = UDim2.new(0, 500, 0, 600)
    Main.Active = true
    Main.Draggable = true
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Main
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 100, 220)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 60)
    
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Size = UDim2.new(1, -70, 1, 0)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = "🎣 Fish It Script - Premium"
    TitleText.TextColor3 = Color3.new(1, 1, 1)
    TitleText.TextSize = 20
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local Version = Instance.new("TextLabel")
    Version.Parent = TitleBar
    Version.BackgroundTransparency = 1
    Version.Position = UDim2.new(0, 15, 0, 25)
    Version.Size = UDim2.new(1, -70, 0, 20)
    Version.Font = Enum.Font.Gotham
    Version.Text = "v4.0 | Atomic Style"
    Version.TextColor3 = Color3.fromRGB(200, 200, 200)
    Version.TextSize = 12
    Version.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -50, 0, 10)
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.TextSize = 35
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        S.AutoFish = false
        Utils:Notify("Script", "GUI Closed", 2)
    end)
    
    -- Tabs Container
    local TabButtons = Instance.new("Frame")
    TabButtons.Name = "TabButtons"
    TabButtons.Parent = Main
    TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabButtons.BorderSizePixel = 0
    TabButtons.Position = UDim2.new(0, 0, 0, 60)
    TabButtons.Size = UDim2.new(1, 0, 0, 50)
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Main
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 110)
    TabContainer.Size = UDim2.new(1, 0, 1, -110)
    
    -- Tab System
    local CurrentTab = nil
    
    local function CreateTab(name, icon)
        local Tab = Instance.new("Frame")
        Tab.Name = name
        Tab.Parent = TabContainer
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.Visible = false
        
        local ScrollFrame = Instance.new("ScrollingFrame")
        ScrollFrame.Parent = Tab
        ScrollFrame.BackgroundTransparency = 1
        ScrollFrame.BorderSizePixel = 0
        ScrollFrame.Size = UDim2.new(1, -20, 1, -20)
        ScrollFrame.Position = UDim2.new(0, 10, 0, 10)
        ScrollFrame.ScrollBarThickness = 4
        ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(40, 100, 220)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local Layout = Instance.new("UIListLayout")
        Layout.Parent = ScrollFrame
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 10)
        
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
        end)
        
        return Tab, ScrollFrame
    end
    
    local function CreateTabButton(name, icon, tab)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabButtons
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabBtn.BorderSizePixel = 0
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Text = icon .. " " .. name
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.TextSize = 14
        TabBtn.Size = UDim2.new(0, 120, 1, -10)
        TabBtn.Position = UDim2.new(0, (#TabButtons:GetChildren() - 1) * 125 + 10, 0, 5)
        
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
        
        TabBtn.MouseButton1Click:Connect(function()
            if CurrentTab then
                CurrentTab.Visible = false
            end
            
            tab.Visible = true
            CurrentTab = tab
            
            for _, btn in pairs(TabButtons:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            
            TabBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 220)
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
        end)
        
        return TabBtn
    end
    
    -- Create Button Function
    local function CreateButton(parent, text, callback)
        local Button = Instance.new("TextButton")
        Button.Parent = parent
        Button.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, -20, 0, 45)
        Button.Font = Enum.Font.Gotham
        Button.Text = text
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.TextSize = 15
        
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
        
        Button.MouseButton1Click:Connect(callback)
        
        return Button
    end
    
    local function CreateToggle(parent, text, default, callback)
        local Toggle = CreateButton(parent, (default and "✅ " or "❌ ") .. text, function() end)
        
        local state = default
        
        Toggle.MouseButton1Click:Connect(function()
            state = not state
            
            if state then
                Toggle.BackgroundColor3 = Color3.fromRGB(70, 255, 70)
                Toggle.Text = "✅ " .. text
            else
                Toggle.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
                Toggle.Text = "❌ " .. text
            end
            
            callback(state)
        end)
        
        return Toggle
    end
    
    local function CreateSlider(parent, text, min, max, default, callback)
        local Container = Instance.new("Frame")
        Container.Parent = parent
        Container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Container.BorderSizePixel = 0
        Container.Size = UDim2.new(1, -20, 0, 60)
        
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Container
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 10, 0, 5)
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Font = Enum.Font.Gotham
        Label.Text = text .. ": " .. default
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Slider = Instance.new("TextButton")
        Slider.Parent = Container
        Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Slider.BorderSizePixel = 0
        Slider.Position = UDim2.new(0, 10, 0, 30)
        Slider.Size = UDim2.new(1, -20, 0, 20)
        Slider.Text = ""
        
        Instance.new("UICorner", Slider).CornerRadius = UDim.new(0, 10)
        
        local Fill = Instance.new("Frame")
        Fill.Parent = Slider
        Fill.BackgroundColor3 = Color3.fromRGB(40, 100, 220)
        Fill.BorderSizePixel = 0
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 10)
        
        local dragging = false
        
        Slider.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        RunService.RenderStepped:Connect(function()
            if dragging then
                local mouse = UserInputService:GetMouseLocation()
                local relativePos = mouse.X - Slider.AbsolutePosition.X
                local percentage = math.clamp(relativePos / Slider.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * percentage)
                
                Fill.Size = UDim2.new(percentage, 0, 1, 0)
                Label.Text = text .. ": " .. value
                
                callback(value)
            end
        end)
        
        return Container
    end
    
    -- Create Tabs
    local FishingTab, FishingScroll = CreateTab("Fishing", "🎣")
    local FarmTab, FarmScroll = CreateTab("Farm", "💰")
    local ESPTab, ESPScroll = CreateTab("ESP", "👁️")
    local PlayerTab, PlayerScroll = CreateTab("Player", "👤")
    local TeleportTab, TeleportScroll = CreateTab("Teleport", "📍")
    local MiscTab, MiscScroll = CreateTab("Misc", "⚙️")
    
    -- Create Tab Buttons
    CreateTabButton("Fishing", "🎣", FishingTab)
    CreateTabButton("Farm", "💰", FarmTab)
    CreateTabButton("ESP", "👁️", ESPTab)
    CreateTabButton("Player", "👤", PlayerTab)
    CreateTabButton("Teleport", "📍", TeleportTab)
    CreateTabButton("Misc", "⚙️", MiscTab)
    
    -- Show first tab
    FishingTab.Visible = true
    CurrentTab = FishingTab
    TabButtons:GetChildren()[1].BackgroundColor3 = Color3.fromRGB(40, 100, 220)
    
    -- Fishing Tab
    CreateToggle(FishingScroll, "Auto Fish", S.AutoFish, function(v)
        S.AutoFish = v
        S.AutoCast = v
        S.AutoReel = v
        S.AutoShake = v
    end)
    
    CreateToggle(FishingScroll, "Auto Cast", S.AutoCast, function(v)
        S.AutoCast = v
    end)
    
    CreateToggle(FishingScroll, "Auto Reel", S.AutoReel, function(v)
        S.AutoReel = v
    end)
    
    CreateToggle(FishingScroll, "Auto Shake", S.AutoShake, function(v)
        S.AutoShake = v
    end)
    
    CreateToggle(FishingScroll, "Instant Catch", S.InstantCatch, function(v)
        S.InstantCatch = v
    end)
    
    CreateToggle(FishingScroll, "Perfect Catch", S.PerfectCatch, function(v)
        S.PerfectCatch = v
    end)
    
    CreateSlider(FishingScroll, "Cast Power", 1, 100, S.CastPower, function(v)
        S.CastPower = v
    end)
    
    CreateSlider(FishingScroll, "Reel Speed", 1, 20, S.ReelSpeed, function(v)
        S.ReelSpeed = v
    end)
    
    CreateButton(FishingScroll, "🎣 Equip Best Rod", function()
        local rod = FishingSystem:GetBestRod()
        if rod then
            Humanoid:EquipTool(rod)
            Utils:Notify("Fishing", "Equipped: " .. rod.Name, 2)
        end
    end)
    
    -- Farm Tab
    CreateToggle(FarmScroll, "Auto Sell Fish", S.AutoSell, function(v)
        S.AutoSell = v
    end)
    
    CreateSlider(FarmScroll, "Sell Threshold", 5, 30, S.SellThreshold, function(v)
        S.SellThreshold = v
    end)
    
    CreateToggle(FarmScroll, "Auto Buy Bait", S.AutoBuyBait, function(v)
        S.AutoBuyBait = v
    end)
    
    CreateToggle(FarmScroll, "Auto Equip Best Rod", S.AutoEquipBestRod, function(v)
        S.AutoEquipBestRod = v
    end)
    
    CreateToggle(FarmScroll, "Auto Collect Treasure", S.AutoCollectTreasure, function(v)
        S.AutoCollectTreasure = v
    end)
    
    CreateToggle(FarmScroll, "Auto Collect Chest", S.AutoCollectChest, function(v)
        S.AutoCollectChest = v
    end)
    
    CreateButton(FarmScroll, "💰 Sell All Now", function()
        FarmSystem:SellFish()
    end)
    
    CreateButton(FarmScroll, "🪱 Buy Bait Now", function()
        FarmSystem:BuyBait()
        Utils:Notify("Farm", "Buying bait...", 2)
    end)
    
    CreateButton(FarmScroll, "📦 Collect All Treasures", function()
        FarmSystem:CollectTreasures()
        Utils:Notify("Farm", "Collecting treasures...", 2)
    end)
    
    -- ESP Tab
    CreateToggle(ESPScroll, "Fish ESP", S.FishESP, function(v)
        S.FishESP = v
        if not v then ESPSystem:Clear() end
    end)
    
    CreateToggle(ESPScroll, "Chest ESP", S.ChestESP, function(v)
        S.ChestESP = v
        if not v then ESPSystem:Clear() end
    end)
    
    CreateToggle(ESPScroll, "Treasure ESP", S.TreasureESP, function(v)
        S.TreasureESP = v
        if not v then ESPSystem:Clear() end
    end)
    
    CreateToggle(ESPScroll, "Player ESP", S.PlayerESP, function(v)
        S.PlayerESP = v
        if not v then ESPSystem:Clear() end
    end)
    
    CreateToggle(ESPScroll, "NPC ESP", S.NPCESP, function(v)
        S.NPCESP = v
        if not v then ESPSystem:Clear() end
    end)
    
    CreateButton(ESPScroll, "🧹 Clear All ESP", function()
        ESPSystem:Clear()
        Utils:Notify("ESP", "All ESP cleared!", 2)
    end)
    
    -- Player Tab
    CreateSlider(PlayerScroll, "Walk Speed", 16, 250, S.WalkSpeed, function(v)
        S.WalkSpeed = v
        PlayerMods:SetSpeed(v)
    end)
    
    CreateSlider(PlayerScroll, "Jump Power", 50, 250, S.JumpPower, function(v)
        S.JumpPower = v
        PlayerMods:SetJump(v)
    end)
    
    CreateToggle(PlayerScroll, "Infinite Stamina", S.InfiniteStamina, function(v)
        S.InfiniteStamina = v
    end)
    
    CreateToggle(PlayerScroll, "No Clip", S.NoClip, function(v)
        S.NoClip = v
    end)
    
    CreateToggle(PlayerScroll, "Fly Mode", S.Fly, function(v)
        S.Fly = v
        PlayerMods:ToggleFly()
    end)
    
    CreateSlider(PlayerScroll, "Fly Speed", 10, 200, S.FlySpeed, function(v)
        S.FlySpeed = v
    end)
    
    CreateButton(PlayerScroll, "🔄 Reset Character", function()
        Character:BreakJoints()
    end)
    
    -- Teleport Tab
    for name, pos in pairs(TeleportLocations) do
        CreateButton(TeleportScroll, "📍 TP to " .. name, function()
            Root.CFrame = CFrame.new(pos)
            Utils:Notify("Teleport", "Teleported to " .. name, 2)
        end)
    end
    
    CreateButton(TeleportScroll, "🏪 TP to Sell NPC", function()
        local sell, dist = Utils:FindNearest("sell", 5000)
        if sell then
            Root.CFrame = sell.CFrame * CFrame.new(0, 3, 0)
            Utils:Notify("Teleport", string.format("Teleported %.0fm", dist), 2)
        end
    end)
    
    CreateButton(TeleportScroll, "🪱 TP to Bait Shop", function()
        local bait, dist = Utils:FindNearest("bait", 5000)
        if bait then
            Root.CFrame = bait.CFrame * CFrame.new(0, 3, 0)
            Utils:Notify("Teleport", string.format("Teleported %.0fm", dist), 2)
        end
    end)
    
    CreateButton(TeleportScroll, "🎣 TP to Nearest Spot", function()
        local spot, dist = Utils:FindNearest("fish", 5000)
        if spot then
            Root.CFrame = spot.CFrame * CFrame.new(0, 3, 0)
            Utils:Notify("Teleport", string.format("Teleported %.0fm", dist), 2)
        end
    end)
    
    -- Misc Tab
    CreateToggle(MiscScroll, "Anti AFK", S.AntiAFK, function(v)
        S.AntiAFK = v
    end)
    
    CreateToggle(MiscScroll, "Auto Rejoin on Kick", S.AutoRejoin, function(v)
        S.AutoRejoin = v
    end)
    
    CreateButton(MiscScroll, "🔄 Rejoin Server", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end)
    
    CreateButton(MiscScroll, "🔀 Server Hop", function()
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
    end)
    
    CreateButton(MiscScroll, "📋 Copy Game Link", function()
        setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
        Utils:Notify("Misc", "Game link copied!", 2)
    end)
    
    CreateButton(MiscScroll, "❌ Destroy GUI", function()
        ScreenGui:Destroy()
        S.AutoFish = false
        Utils:Notify("Script", "GUI destroyed!", 2)
    end)
    
    -- Info Section
    local Info = Instance.new("TextLabel")
    Info.Parent = MiscScroll
    Info.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Info.BorderSizePixel = 0
    Info.Size = UDim2.new(1, -20, 0, 100)
    Info.Font = Enum.Font.Gotham
    Info.Text = [[
📌 Fish It Script v4.0
🎣 Atomic Style - Full Features
👤 User: ]] .. Player.Name .. [[

💡 Tips:
- Use Auto Fish for AFK farming
- Enable ESP to find rare fish
- Sell fish when inventory is full
    ]]
    Info.TextColor3 = Color3.fromRGB(200, 200, 200)
    Info.TextSize = 12
    Info.TextYAlignment = Enum.TextYAlignment.Top
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextWrapped = true
    
    Instance.new("UICorner", Info).CornerRadius = UDim.new(0, 8)
    Instance.new("UIPadding", Info).PaddingLeft = UDim.new(0, 10)
end

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
            
            if S.AutoFish and Character and Humanoid then
                if S.AutoEquipBestRod then
                    local bestRod = FishingSystem:GetBestRod()
                    if bestRod and bestRod.Parent == Player.Backpack then
                        Humanoid:EquipTool(bestRod)
                    end
                else
                    FishingSystem:EquipRod()
                end
                
                local fishing = FishingSystem:IsFishing()
                
                if not fishing and S.AutoCast then
                    FishingSystem:Cast()
                    task.wait(1.5)
                end
                
                if fishing then
                    if S.AutoShake then
                        FishingSystem:Shake()
                    end
                    
                    if S.AutoReel then
                        local reelCount = S.InstantCatch and 30 or S.ReelSpeed
                        for i = 1, reelCount do
                            FishingSystem:Reel()
                            task.wait(0.05)
                        end
                    end
                end
            end
            
            if Humanoid then
                Humanoid.WalkSpeed = S.WalkSpeed
                Humanoid.JumpPower = S.JumpPower
            end
            
            if S.NoClip and Character then
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
            if S.AutoSell then
                local count = FarmSystem:GetInventoryCount()
                if count >= S.SellThreshold then
                    FarmSystem:SellFish()
                    task.wait(2)
                end
            end
            
            if S.AutoBuyBait then
                FarmSystem:BuyBait()
            end
            
            if S.AutoCollectTreasure or S.AutoCollectChest then
                FarmSystem:CollectTreasures()
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            if S.FishESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:lower():find("fish") and obj ~= Character then
                        local part = obj:FindFirstChildWhichIsA("BasePart")
                        if part and not ESPObjects[part] then
                            ESPSystem:Create(part, "Fish", Color3.fromRGB(0, 255, 255))
                        end
                    end
                end
            end
            
            if S.ChestESP or S.TreasureESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("treasure")) then
                        local part = obj:FindFirstChildWhichIsA("BasePart")
                        if part and not ESPObjects[part] then
                            ESPSystem:Create(part, "Treasure", Color3.fromRGB(255, 215, 0))
                        end
                    end
                end
            end
            
            if S.PlayerESP then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        if head and not ESPObjects[head] then
                            ESPSystem:Create(head, player.Name, Color3.fromRGB(255, 0, 0))
                        end
                    end
                end
            end
            
            if S.NPCESP then
                for _, npc in pairs(Workspace:GetDescendants()) do
                    if npc:IsA("Model") and (npc.Name:lower():find("npc") or npc.Name:lower():find("merchant") or npc.Name:lower():find("shop")) then
                        local part = npc:FindFirstChildWhichIsA("BasePart")
                        if part and not ESPObjects[part] then
                            ESPSystem:Create(part, npc.Name, Color3.fromRGB(0, 255, 0))
                        end
                    end
                end
            end
            
            if not (S.FishESP or S.ChestESP or S.TreasureESP or S.PlayerESP or S.NPCESP) then
                ESPSystem:Clear()
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if S.InfiniteStamina and Player:FindFirstChild("PlayerGui") then
            pcall(function()
                local stamina = Player.PlayerGui:FindFirstChild("StaminaBar") or Player.PlayerGui:FindFirstChild("Stamina")
                if stamina and stamina:FindFirstChild("Bar") then
                    stamina.Bar.Size = UDim2.new(1, 0, 1, 0)
                end
            end)
        end
    end
end)

Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
end)

if S.AutoRejoin then
    game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == 'ErrorPrompt' then
            game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
        end
    end)
end

CreateGUI()

Utils:Notify("🎣 Nyemek Hub Script", "Loaded Successfully!\nVersion 1.0 - Nyemek Style", 5)

print("════════════════════════════════════════")
print("✅ Fish It Script Loaded!")
print("🎣 Version: 4.0 - Atomic Style")
print("📝 Full Features Activated")
print("👤 User: " .. Player.Name)
print("════════════════════════════════════════")

