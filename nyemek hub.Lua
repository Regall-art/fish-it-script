-- Fish It Script - Atomic Style (No Jump, Clean)
-- Version: 9.0 - Smooth Auto Fish
-- Based on Atomic Hub functionality

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It Hub - Atomic Style",
    LoadingTitle = "Loading Atomic Style Hub...",
    LoadingSubtitle = "by Regall-art",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "FishItAtomic"
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

-- Settings
local Settings = {
    AutoFish = false,
    AutoSell = false,
    AutoCast = false,
    AutoReel = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
}

-- Stats
local Stats = {
    FishCaught = 0,
    TotalCaught = 0,
}

-- Notify
local function Notify(title, text, duration)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = duration or 3,
        Image = 4483362458,
    })
end

-- Get Rod
local function GetRod()
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    return nil
end

-- Equip Rod
local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Player.Backpack then
        Humanoid:EquipTool(rod)
        task.wait(0.5)
    end
end

-- Cast (Simple Click)
local function Cast()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Reel (Simple Space)
local function Reel()
    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

-- Check if Fishing
local function IsFishing()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:lower():find("bob") or obj.Name:lower():find("float") then
            return true
        end
    end
    return false
end

-- Count Fish
local function CountFish()
    local count = 0
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            count = count + 1
        end
    end
    return count
end

-- Sell Fish
local function SellFish()
    local sell = nil
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and obj.Name:lower():find("sell") then
            sell = obj
            break
        end
    end
    
    if sell then
        local oldPos = Root.CFrame
        local targetPos = sell:IsA("Model") and sell:GetPivot().Position or sell.Position
        
        Root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        task.wait(1)
        
        -- Try sell
        for _, v in pairs(sell:GetDescendants()) do
            if v:IsA("ClickDetector") then
                pcall(function() fireclickdetector(v) end)
            end
            if v:IsA("ProximityPrompt") then
                pcall(function() fireproximityprompt(v) end)
            end
        end
        
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():find("sell") then
                pcall(function() remote:FireServer() end)
            end
        end
        
        task.wait(1)
        Root.CFrame = oldPos
        
        Notify("Sell", "Sold fish! 💰", 2)
    end
end

-- Teleport
local function TeleportTo(pos)
    if typeof(pos) == "Vector3" then
        Root.CFrame = CFrame.new(pos)
    elseif typeof(pos) == "CFrame" then
        Root.CFrame = pos
    end
end

-- Fly
local Flying = false
local BV = nil

local function ToggleFly()
    Flying = not Flying
    
    if Flying then
        BV = Instance.new("BodyVelocity")
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.Parent = Root
        
        task.spawn(function()
            while Flying and BV and BV.Parent do
                local vel = Vector3.new(0, 0, 0)
                local cam = Workspace.CurrentCamera
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    vel = vel + cam.CFrame.LookVector * Settings.FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    vel = vel - cam.CFrame.LookVector * Settings.FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    vel = vel - cam.CFrame.RightVector * Settings.FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    vel = vel + cam.CFrame.RightVector * Settings.FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    vel = vel + Vector3.new(0, Settings.FlySpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    vel = vel - Vector3.new(0, Settings.FlySpeed, 0)
                end
                
                BV.Velocity = vel
                task.wait()
            end
        end)
    else
        if BV then
            BV:Destroy()
            BV = nil
        end
    end
end

-- Tabs
local MainTab = Window:CreateTab("🎣 Main", 4483362458)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local TeleportTab = Window:CreateTab("📍 Teleport", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

-- Main Tab
local FishingSection = MainTab:CreateSection("Auto Fishing")

MainTab:CreateToggle({
    Name = "Auto Fish",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        Settings.AutoFish = Value
        if Value then
            Notify("Auto Fish", "Enabled! Go to water spot", 3)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Cast",
    CurrentValue = false,
    Flag = "AutoCast",
    Callback = function(Value)
        Settings.AutoCast = Value
    end,
})

MainTab:CreateToggle({
    Name = "Auto Reel",
    CurrentValue = false,
    Flag = "AutoReel",
    Callback = function(Value)
        Settings.AutoReel = Value
    end,
})

local FarmSection = MainTab:CreateSection("Farming")

MainTab:CreateToggle({
    Name = "Auto Sell (25 fish)",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        Settings.AutoSell = Value
    end,
})

MainTab:CreateButton({
    Name = "Sell Now",
    Callback = function()
        SellFish()
    end,
})

MainTab:CreateLabel("Fish Caught: 0")

-- Player Tab
local MovementSection = PlayerTab:CreateSection("Movement")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Settings.WalkSpeed = Value
    end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        Settings.JumpPower = Value
    end,
})

PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        Settings.NoClip = Value
    end,
})

local FlySection = PlayerTab:CreateSection("Fly")

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        Settings.Fly = Value
        ToggleFly()
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 150},
    Increment = 5,
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        Settings.FlySpeed = Value
    end,
})

-- Teleport Tab
TeleportTab:CreateButton({
    Name = "Spawn",
    Callback = function()
        TeleportTo(Vector3.new(0, 10, 0))
        Notify("TP", "Teleported", 1)
    end,
})

TeleportTab:CreateButton({
    Name = "Beach",
    Callback = function()
        TeleportTo(Vector3.new(100, 10, 0))
        Notify("TP", "Teleported", 1)
    end,
})

TeleportTab:CreateButton({
    Name = "Pier",
    Callback = function()
        TeleportTo(Vector3.new(200, 10, 50))
        Notify("TP", "Teleported", 1)
    end,
})

TeleportTab:CreateButton({
    Name = "Lake",
    Callback = function()
        TeleportTo(Vector3.new(-150, 10, 200))
        Notify("TP", "Teleported", 1)
    end,
})

-- Misc Tab
MiscTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end,
})

MiscTab:CreateLabel("Version: 9.0 Atomic Style")
MiscTab:CreateLabel("User: " .. Player.Name)

-- Main Loop - ATOMIC STYLE (Smooth, No Jump)
task.spawn(function()
    while task.wait(1) do -- 1 second loop (smooth)
        pcall(function()
            -- Update character
            if not Character or not Character.Parent then
                Character = Player.Character
                if Character then
                    Humanoid = Character:WaitForChild("Humanoid")
                    Root = Character:WaitForChild("HumanoidRootPart")
                end
            end
            
            -- Auto Fish Logic
            if Settings.AutoFish and Character then
                -- Equip rod
                local rod = GetRod()
                if not rod or rod.Parent ~= Character then
                    EquipRod()
                end
                
                local fishing = IsFishing()
                
                -- Cast if not fishing and enabled
                if not fishing and Settings.AutoCast then
                    Cast()
                end
                
                -- Reel if fishing and enabled
                if fishing and Settings.AutoReel then
                    for i = 1, 10 do
                        Reel()
                        task.wait(0.15)
                    end
                    
                    -- Check if caught
                    task.wait(0.5)
                    local newCount = CountFish()
                    if newCount > (Stats.FishCaught or 0) then
                        Stats.TotalCaught = Stats.TotalCaught + 1
                        
                        if Stats.TotalCaught % 25 == 0 then
                            Notify("Fish", "Caught " .. Stats.TotalCaught .. " fish!", 3)
                        end
                    end
                    Stats.FishCaught = newCount
                end
            end
            
            -- Player mods
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
    while task.wait(15) do
        pcall(function()
            if Settings.AutoSell then
                local count = CountFish()
                if count >= 25 then
                    Notify("Sell", "Selling " .. count .. " fish...", 2)
                    SellFish()
                    Stats.FishCaught = 0
                end
            end
        end)
    end
end)

-- Character Update
Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
end)

Notify("Atomic Hub", "Loaded! v9.0", 3)

print("════════════════════════════════════════")
print("✅ Fish It - Atomic Style")
print("🎣 Smooth Auto Fish (No Jump)")
print("👤 User: " .. Player.Name)
print("════════════════════════════════════════")
