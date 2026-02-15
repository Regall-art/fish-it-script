-- FISH IT SCRIPT - DELTA FRIENDLY VERSION
-- SUPER SIMPLE - 100% WORKING FOR DELTA

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

-- Anti AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- SIMPLE GUI (PASTI JALAN DI DELTA)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItHub"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐟 FISH IT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- TAB BUTTONS
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 40)
TabFrame.Position = UDim2.new(0, 0, 0, 30)
TabFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TabFrame.Parent = MainFrame

-- CONTENT FRAME
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -90)
ContentFrame.Position = UDim2.new(0, 10, 0, 80)
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 8
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = ContentFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 10)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = ContentFrame

-- TAB SYSTEM
local Tabs = {}
local CurrentTab = "Farm"

-- Function to create section
local function AddSection(text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, -10, 0, 25)
    Section.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Section.Text = "   " .. text
    Section.TextColor3 = Color3.fromRGB(100, 200, 255)
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Font = Enum.Font.SourceSansBold
    Section.TextSize = 16
    Section.Parent = ContentFrame
end

-- Function to create toggle
local function AddToggle(text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Frame.Parent = ContentFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 25)
    ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 14
    ToggleBtn.Parent = Frame
    
    local enabled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        ToggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
        ToggleBtn.Text = enabled and "ON" or "OFF"
        callback(enabled)
    end)
end

-- Function to create button
local function AddButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 16
    Btn.Parent = ContentFrame
    Btn.MouseButton1Click:Connect(callback)
end

-- Function to create label
local function AddLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 25)
    Label.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Label.Text = "  " .. text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.Parent = ContentFrame
end

-- CREATE TAB BUTTONS
local TabNames = {"🎣 Farm", "📍 TP", "👤 Player", "⚙️ Misc"}
local TabButtons = {}

for i, name in ipairs(TabNames) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 70, 0, 30)
    TabBtn.Position = UDim2.new(0, ((i-1) * 75) + 5, 0, 5)
    TabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.TextSize = 14
    TabBtn.Parent = TabFrame
    table.insert(TabButtons, TabBtn)
    
    TabBtn.MouseButton1Click:Connect(function()
        -- Reset all buttons
        for _, btn in ipairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        
        -- Clear content
        for _, child in pairs(ContentFrame:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        
        -- Show selected tab content
        if name == "🎣 Farm" then
            AddSection("⚙️ AUTO FISHING")
            
            AddToggle("Auto Fish", function(value)
                _G.AutoFish = value
            end)
            
            AddToggle("Auto Cast", function(value)
                _G.AutoCast = value
            end)
            
            AddToggle("Auto Reel", function(value)
                _G.AutoReel = value
            end)
            
            AddToggle("Auto Shake", function(value)
                _G.AutoShake = value
            end)
            
            AddSection("💰 AUTO FARM")
            
            AddToggle("Auto Sell", function(value)
                _G.AutoSell = value
            end)
            
            AddButton("Sell Now", function()
                SellFish()
            end)
            
            AddSection("📊 STATS")
            AddLabel("Fish: 0")
            AddLabel("Money: $0")
            
        elseif name == "📍 TP" then
            AddSection("📍 QUICK TELEPORT")
            
            AddButton("TP to Sell", function()
                TeleportToSell()
            end)
            
            AddButton("TP to Bait", function()
                TeleportToBait()
            end)
            
            AddButton("TP to Water", function()
                TeleportToWater()
            end)
            
            AddSection("🗺️ LOCATIONS")
            
            AddButton("Spawn", function()
                Root.CFrame = CFrame.new(0, 10, 0)
            end)
            
            AddButton("Beach", function()
                Root.CFrame = CFrame.new(100, 10, 50)
            end)
            
            AddButton("Ocean", function()
                Root.CFrame = CFrame.new(500, 10, 500)
            end)
            
        elseif name == "👤 Player" then
            AddSection("🏃 MOVEMENT")
            
            AddButton("Walk Speed 50", function()
                Humanoid.WalkSpeed = 50
            end)
            
            AddButton("Walk Speed 100", function()
                Humanoid.WalkSpeed = 100
            end)
            
            AddButton("Reset Speed", function()
                Humanoid.WalkSpeed = 16
            end)
            
            AddSection("🕊️ FLY")
            
            AddToggle("Fly Mode", function(value)
                _G.Fly = value
                ToggleFly(value)
            end)
            
        elseif name == "⚙️ Misc" then
            AddSection("🌐 SERVER")
            
            AddButton("Rejoin", function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
            end)
            
            AddSection("ℹ️ INFO")
            AddLabel("Version: 1.0")
            AddLabel("User: " .. Player.Name)
            
            AddButton("Destroy GUI", function()
                ScreenGui:Destroy()
            end)
        end
    end)
end

-- =============================================
-- FISHING FUNCTIONS
-- =============================================

-- Simple remote firing
local function FireRemote(name, ...)
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find(name) then
            pcall(function() obj:FireServer(...) end)
            return true
        end
    end
    return false
end

-- Cast function
local function Cast()
    FireRemote("cast")
    FireRemote("start")
    
    -- Simulate mouse click
    local mouse = Player:GetMouse()
    if mouse then
        mouse1press()
        task.wait(0.1)
        mouse1release()
    end
end

-- Reel function
local function Reel()
    FireRemote("reel")
    FireRemote("catch")
    
    -- Simulate space key
    keypress(32) -- Space key
    task.wait(0.05)
    keyrelease(32)
end

-- Shake function
local function Shake()
    for i = 1, 3 do
        FireRemote("shake")
        task.wait(0.05)
    end
end

-- Check if fishing
local function IsFishing()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("bob") or obj.Name:lower():find("float") then
            return true
        end
    end
    return false
end

-- Get rod
local function GetRod()
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") then return item end
    end
    return nil
end

-- =============================================
-- TELEPORT FUNCTIONS
-- =============================================

function TeleportToSell()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("sell") or obj.Name:lower():find("shop")) then
            local pos = obj:GetPivot().Position
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            return
        end
    end
end

function TeleportToBait()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("bait") then
            local pos = obj:GetPivot().Position
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            return
        end
    end
end

function TeleportToWater()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("water") or obj.Material == Enum.Material.Water) then
            Root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0))
            return
        end
    end
end

-- =============================================
-- SELL FUNCTION
-- =============================================

function SellFish()
    local sold = false
    
    -- Try to find sell NPC
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("sell") or obj.Name:lower():find("shop")) then
            local pos = obj:GetPivot().Position
            local oldPos = Root.CFrame
            
            -- Teleport to NPC
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            task.wait(1)
            
            -- Fire sell remote
            FireRemote("sell", "all")
            
            -- Click detectors
            for _, v in pairs(obj:GetDescendants()) do
                if v:IsA("ClickDetector") then
                    fireclickdetector(v)
                end
            end
            
            task.wait(1)
            Root.CFrame = oldPos
            sold = true
            break
        end
    end
    
    if sold then
        -- Notification
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fish It",
            Text = "Sold all fish! 💰",
            Duration = 2
        })
    end
end

-- =============================================
-- FLY FUNCTION
-- =============================================

local flying = false
local bodyVelocity = nil

function ToggleFly(enable)
    if enable then
        flying = true
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = Root
        
        task.spawn(function()
            while flying and bodyVelocity and bodyVelocity.Parent do
                local vel = Vector3.new(0, 0, 0)
                local cam = Workspace.CurrentCamera
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    vel = vel + (cam.CFrame.LookVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    vel = vel - (cam.CFrame.LookVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    vel = vel - (cam.CFrame.RightVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    vel = vel + (cam.CFrame.RightVector * 50)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    vel = vel + Vector3.new(0, 50, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    vel = vel - Vector3.new(0, 50, 0)
                end
                
                bodyVelocity.Velocity = vel
                task.wait()
            end
        end)
    else
        flying = false
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
end

-- =============================================
-- MAIN AUTO FISH LOOP (SIMPLE)
-- =============================================

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if _G.AutoFish then
                local rod = GetRod()
                
                if not IsFishing() and _G.AutoCast then
                    Cast()
                elseif IsFishing() then
                    if _G.AutoShake then
                        Shake()
                    end
                    if _G.AutoReel then
                        for i = 1, 10 do
                            Reel()
                            task.wait(0.1)
                        end
                    end
                end
            end
            
            if _G.AutoSell then
                -- Sell every 30 seconds
                if not _G.LastSell or tick() - _G.LastSell > 30 then
                    SellFish()
                    _G.LastSell = tick()
                end
            end
        end)
    end
end)

-- =============================================
-- AUTO EQUIP ROD
-- =============================================

task.spawn(function()
    while task.wait(5) do
        pcall(function()
            if not GetRod() then
                -- Try to equip from backpack
                for _, item in pairs(Player.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        Humanoid:EquipTool(item)
                        break
                    end
                end
            end
        end)
    end
end)

-- =============================================
-- FINISH
-- =============================================

-- Click first tab
TabButtons[1].MouseButton1Click:Fire()

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Fish It Hub",
    Text = "✅ Loaded! Press Insert to toggle",
    Duration = 3
})

-- Toggle GUI with Insert
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("✅ Fish It Script Loaded - Delta Friendly Version")
