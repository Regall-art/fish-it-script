--[[
    NYEMEK HUB - FISH IT! EDITION
    Support: All Executors (Delta, Vega X, Fluxus, Wave, etc.)
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Configuration & Variables //
getgenv().AutoFish = false
getgenv().AutoSell = false
getgenv().InstantCatch = false
getgenv().AntiAFK = true

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- // UI Window //
local Window = Rayfield:CreateWindow({
   Name = "NYEMEK HUB | FISH IT! V2",
   LoadingTitle = "Initializing Script...",
   LoadingSubtitle = "by Synx & Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "NyemekHub_Fish",
      FileName = "Config"
   }
})

-- // Tabs //
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local TPTab = Window:CreateTab("Teleports", 4483362458)
local MiscTab = Window:CreateTab("Misc/Settings", 4483362458)

-- // LOGIC: AUTO FISHING //
spawn(function()
    while task.wait() do
        if getgenv().AutoFish then
            pcall(function()
                local Rod = Character:FindFirstChildOfClass("Tool")
                if Rod then
                    -- Melempar Umpan
                    Rod:Activate()
                    
                    -- Logika Reel (Tarik Ikan)
                    -- Menyesuaikan dengan RemoteEvent umum di game Fish It
                    local Events = Rod:FindFirstChild("events") or Rod:FindFirstChild("Events")
                    if Events then
                        local ReelEvent = Events:FindFirstChild("reelfinished") or Events:FindFirstChild("Reel")
                        if ReelEvent then
                            -- Memberikan value 100 agar Perfect Catch
                            ReelEvent:FireServer(100, true)
                        end
                    end
                end
            end)
        end
        if not getgenv().AutoFish then task.wait(1) end
    end
end)

-- // FARM TAB //
FarmTab:CreateSection("Main Automation")

FarmTab:CreateToggle({
   Name = "Auto Fishing (Cast & Catch)",
   CurrentValue = false,
   Flag = "ToggleAutoFish",
   Callback = function(Value)
      getgenv().AutoFish = Value
      if Value then
          Rayfield:Notify({Title = "Nyemek Hub", Content = "Auto Fish Aktif!", Duration = 3})
      end
   end,
})

FarmTab:CreateToggle({
   Name = "Instant Catch (Blatant)",
   CurrentValue = false,
   Flag = "ToggleInstant",
   Callback = function(Value)
      getgenv().InstantCatch = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Sell Fish",
   CurrentValue = false,
   Flag = "ToggleSell",
   Callback = function(Value)
      getgenv().AutoSell = Value
      spawn(function()
          while getgenv().AutoSell do
              -- Panggil remote jual (Sesuaikan dengan game)
              game:GetService("ReplicatedStorage").events:FindFirstChild("sellall"):FireServer()
              task.wait(5)
          end
      end)
   end,
})

-- // TELEPORT TAB //
TPTab:CreateSection("Island Teleports")

local Locations = {
    ["Main Island"] = Vector3.new(460, 130, 230),
    ["Great Reef"] = Vector3.new(-3500, 135, 1200),
    ["Mushgrove Swamp"] = Vector3.new(2500, 130, -1500),
    ["Merchant Shop"] = Vector3.new(475, 130, 250)
}

for Name, Pos in pairs(Locations) do
    TPTab:CreateButton({
        Name = "TP to " .. Name,
        Callback = function()
            HumanoidRootPart.CFrame = CFrame.new(Pos)
        end,
    })
end

-- // MISC TAB //
MiscTab:CreateSection("Character Mods")

MiscTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      Character.Humanoid.WalkSpeed = Value
   end,
})

MiscTab:CreateToggle({
   Name = "Infinite Oxygen",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().InfOxygen = Value
       spawn(function()
           while getgenv().InfOxygen do
               if Player:FindFirstChild("Oxygen") then Player.Oxygen.Value = 100 end
               task.wait(1)
           end
       end)
   end,
})

MiscTab:CreateButton({
   Name = "Anti-AFK",
   Callback = function()
       local vu = game:GetService("VirtualUser")
       Player.Idled:Connect(function()
           vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
           task.wait(1)
           vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
       end)
       Rayfield:Notify({Title = "Success", Content = "Anti-AFK Aktif", Duration = 2})
   end,
})

Rayfield:LoadConfiguration()
