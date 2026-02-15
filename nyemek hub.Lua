--[[
FISH IT SCRIPT - UNIVERSAL EXECUTOR SUPPORT
Support semua executor (Krnl, Synapse, Fluxus, Delta, Arceus X, dll)
Auto update dari GitHub
]]

-- Cek game
if game.PlaceId ~= 121864768012064 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fish It Script",
        Text = "❌ Bukan game Fish It! Script hanya untuk Fish It",
        Duration = 5
    })
    return
end

-- Loadstring dari GitHub (RAW URL)
local scriptUrl = "https://raw.githubusercontent.com/Regall-art/Nyemek-Hub-By-Synx/refs/heads/main/nyemek%20hub.Lua" -- GANTI DENGAN URL GITHUB KALIAN

-- Fungsi untuk load script
local function loadScript()
    local success, result = pcall(function()
        return game:HttpGet(scriptUrl)
    end)
    
    if success and result then
        loadstring(result)()
    else
        -- Fallback script jika gagal load dari GitHub
        loadstring([[
            -- =============================================
            -- FISH IT SCRIPT - FALLBACK VERSION
            -- Support semua executor
            -- =============================================
            
            -- Services
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local RunService = game:GetService("RunService")
            local UserInputService = game:GetService("UserInputService")
            local TweenService = game:GetService("TweenService")
            local VirtualUser = game:GetService("VirtualUser")
            local player = Players.LocalPlayer
            
            -- Variables
            local isFarming = false
            local isSelling = false
            local isAntiAfk = false
            local isInfJump = false
            local fishDelay = 1.5
            
            -- Deteksi Remote Events (Universal)
            local remotes = {}
            local remotePatterns = {"cast", "reel", "fish", "sell", "buy", "collect", "upgrade"}
            
            -- Fungsi untuk cari remote
            local function findRemotes()
                local found = {}
                for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        for _, pattern in ipairs(remotePatterns) do
                            if obj.Name:lower():find(pattern) then
                                found[pattern] = obj
                                break
                            end
                        end
                    end
                end
                return found
            end
            
            remotes = findRemotes()
            
            -- Fungsi Auto Fish
            local function autoFish()
                while isFarming do
                    task.wait(fishDelay)
                    
                    -- Cast
                    if remotes["cast"] then
                        pcall(function()
                            if remotes["cast"]:IsA("RemoteFunction") then
                                remotes["cast"]:InvokeServer()
                            else
                                remotes["cast"]:FireServer()
                            end
                        end)
                    end
                    
                    task.wait(0.5)
                    
                    -- Reel
                    if remotes["reel"] then
                        pcall(function()
                            if remotes["reel"]:IsA("RemoteFunction") then
                                remotes["reel"]:InvokeServer()
                            else
                                remotes["reel"]:FireServer()
                            end
                        end)
                    end
                end
            end
            
            -- Fungsi Auto Sell
            local function autoSell()
                while isSelling do
                    task.wait(30)
                    if remotes["sell"] then
                        pcall(function()
                            if remotes["sell"]:IsA("RemoteFunction") then
                                remotes["sell"]:InvokeServer("sellall")
                            else
                                remotes["sell"]:FireServer("sellall")
                            end
                        end)
                    end
                end
            end
            
            -- Buat GUI Simple (Support semua executor)
            local function createGUI()
                -- ScreenGui
                local screenGui = Instance.new("ScreenGui")
                screenGui.Name = "FishItGUI"
                screenGui.ResetOnSpawn = false
                screenGui.Parent = player:WaitForChild("PlayerGui")
                
                -- Main Frame
                local mainFrame = Instance.new("Frame")
                mainFrame.Size = UDim2.new(0, 400, 0, 500)
                mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
                mainFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
                mainFrame.BorderSizePixel = 0
                mainFrame.Active = true
                mainFrame.Draggable = true
                mainFrame.Parent = screenGui
                
                -- Shadow
                local shadow = Instance.new("ImageLabel")
                shadow.Size = UDim2.new(1, 10, 1, 10)
                shadow.Position = UDim2.new(0, -5, 0, -5)
                shadow.BackgroundTransparency = 1
                shadow.Image = "rbxassetid://1316045217"
                shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
                shadow.ImageTransparency = 0.5
                shadow.ScaleType = Enum.ScaleType.Slice
                shadow.SliceCenter = Rect.new(10, 10, 118, 118)
                shadow.Parent = mainFrame
                
                -- Title Bar
                local titleBar = Instance.new("Frame")
                titleBar.Size = UDim2.new(1, 0, 0, 40)
                titleBar.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
                titleBar.BorderSizePixel = 0
                titleBar.Parent = mainFrame
                
                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, -40, 1, 0)
                title.Position = UDim2.new(0, 10, 0, 0)
                title.BackgroundTransparency = 1
                title.Text = "🎣 FISH IT - ATOMIC HUB"
                title.TextColor3 = Color3.fromRGB(255, 255, 255)
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Font = Enum.Font.GothamBold
                title.TextSize = 16
                title.Parent = titleBar
                
                local closeBtn = Instance.new("TextButton")
                closeBtn.Size = UDim2.new(0, 30, 0, 30)
                closeBtn.Position = UDim2.new(1, -35, 0, 5)
                closeBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 70)
                closeBtn.Text = "✕"
                closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                closeBtn.Font = Enum.Font.GothamBold
                closeBtn.TextSize = 16
                closeBtn.Parent = titleBar
                closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
                
                -- Tab Buttons
                local tabFrame = Instance.new("Frame")
                tabFrame.Size = UDim2.new(1, 0, 0, 40)
                tabFrame.Position = UDim2.new(0, 0, 0, 40)
                tabFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
                tabFrame.BorderSizePixel = 0
                tabFrame.Parent = mainFrame
                
                -- Content Frame
                local contentFrame = Instance.new("ScrollingFrame")
                contentFrame.Size = UDim2.new(1, -20, 1, -100)
                contentFrame.Position = UDim2.new(0, 10, 0, 90)
                contentFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
                contentFrame.BorderSizePixel = 0
                contentFrame.ScrollBarThickness = 6
                contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                contentFrame.Parent = mainFrame
                
                local layout = Instance.new("UIListLayout")
                layout.Padding = UDim.new(0, 8)
                layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                layout.Parent = contentFrame
                
                local padding = Instance.new("UIPadding")
                padding.PaddingTop = UDim.new(0, 10)
                padding.PaddingBottom = UDim.new(0, 10)
                padding.PaddingLeft = UDim.new(0, 10)
                padding.PaddingRight = UDim.new(0, 10)
                padding.Parent = contentFrame
                
                -- Function buat section
                local function addSection(text)
                    local section = Instance.new("TextLabel")
                    section.Size = UDim2.new(1, 0, 0, 25)
                    section.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
                    section.Text = text
                    section.TextColor3 = Color3.fromRGB(100, 200, 255)
                    section.Font = Enum.Font.GothamBold
                    section.TextSize = 14
                    section.Parent = contentFrame
                end
                
                -- Function buat toggle
                local function addToggle(text, callback)
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 0, 35)
                    frame.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
                    frame.BorderSizePixel = 0
                    frame.Parent = contentFrame
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(0.7, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = text
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 14
                    label.Parent = frame
                    
                    local padding = Instance.new("UIPadding")
                    padding.PaddingLeft = UDim.new(0, 10)
                    padding.Parent = label
                    
                    local toggle = Instance.new("TextButton")
                    toggle.Size = UDim2.new(0, 50, 0, 25)
                    toggle.Position = UDim2.new(1, -60, 0.5, -12.5)
                    toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                    toggle.Text = "OFF"
                    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
                    toggle.Font = Enum.Font.GothamBold
                    toggle.TextSize = 12
                    toggle.Parent = frame
                    
                    local enabled = false
                    toggle.MouseButton1Click:Connect(function()
                        enabled = not enabled
                        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(80, 80, 80)
                        toggle.Text = enabled and "ON" or "OFF"
                        callback(enabled)
                    end)
                end
                
                -- Function buat button
                local function addButton(text, callback)
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 35)
                    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                    btn.Text = text
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Font = Enum.Font.GothamBold
                    btn.TextSize = 14
                    btn.Parent = contentFrame
                    btn.MouseButton1Click:Connect(callback)
                end
                
                -- AUTO FARM SECTION
                addSection("⚙️ AUTO FARM")
                
                addToggle("🎣 Auto Fishing", function(state)
                    isFarming = state
                    if state then task.spawn(autoFish) end
                end)
                
                addToggle("💰 Auto Sell", function(state)
                    isSelling = state
                    if state then task.spawn(autoSell) end
                end)
                
                addToggle("💤 Anti AFK", function(state)
                    isAntiAfk = state
                    if state then
                        player.Idled:Connect(function()
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new())
                        end)
                    end
                end)
                
                addToggle("🦘 Infinite Jump", function(state)
                    isInfJump = state
                    if state then
                        UserInputService.JumpRequest:Connect(function()
                            if player.Character and player.Character:FindFirstChild("Humanoid") then
                                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end)
                    end
                end)
                
                -- TELEPORT SECTION
                addSection("📍 TELEPORT")
                
                local locations = {
                    {"Fisherman Island", Vector3.new(0, 50, 0)},
                    {"Tropical Grove", Vector3.new(500, 50, 500)},
                    {"Esoteric Depths", Vector3.new(-500, -100, 300)},
                    {"Crystal Depths", Vector3.new(800, -200, -400)},
                    {"Sell Area", Vector3.new(0, 50, 200)},
                    {"Shop Area", Vector3.new(100, 50, 100)}
                }
                
                for _, loc in ipairs(locations) do
                    addButton("📍 " .. loc[1], function()
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.CFrame = CFrame.new(loc[2])
                        end
                    end)
                end
                
                -- INFO SECTION
                addSection("📝 INFO")
                
                local info = Instance.new("TextLabel")
                info.Size = UDim2.new(1, 0, 0, 60)
                info.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
                info.Text = "Fish It Script\nSupport All Executor\nTekan Insert untuk toggle"
                info.TextColor3 = Color3.fromRGB(200, 200, 200)
                info.Font = Enum.Font.Gotham
                info.TextSize = 12
                info.Parent = contentFrame
                
                return screenGui
            end
            
            -- Create GUI
            local gui = createGUI()
            
            -- Toggle dengan Insert
            UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Insert then
                    gui.Enabled = not gui.Enabled
                end
            end)
            
            -- Notifikasi
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Fish It Script",
                Text = "✅ Script berhasil dimuat! Tekan Insert untuk toggle",
                Duration = 3
            })
        ]])()
    end
end

-- Eksekusi script
loadScript()

-- Notifikasi loading
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Fish It Script",
    Text = "📥 Loading script... Mohon tunggu",
    Duration = 2
})
