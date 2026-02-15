-- Memastikan library terload dengan benar
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then 
    warn("Rayfield Library gagal dimuat! Pastikan internet stabil.")
    return 
end

local Window = Rayfield:CreateWindow({
   Name = "NYEMEK HUB | FISH IT",
   LoadingTitle = "Executing Nyemek Hub...",
   LoadingSubtitle = "by Synx",
   ConfigurationSaving = { Enabled = false }
})

-- Variables
getgenv().AutoFish = false
local Player = game.Players.LocalPlayer

-- Tabs
local MainTab = Window:CreateTab("Main", 4483362458)

-- Fitur Auto Fish
MainTab:CreateToggle({
   Name = "Auto Fishing",
   CurrentValue = false,
   Flag = "AutoFish", 
   Callback = function(Value)
      getgenv().AutoFish = Value
      if Value then
          spawn(function()
              while getgenv().AutoFish do
                  pcall(function()
                      local Character = Player.Character
                      local Rod = Character:FindFirstChildOfClass("Tool")
                      if Rod then
                          Rod:Activate() -- Cast
                          task.wait(2)
                          -- Memanggil Remote Event (Umum untuk Fish It)
                          local Event = Rod:FindFirstChild("events") or Rod:FindFirstChild("Events")
                          if Event then
                              local Reel = Event:FindFirstChild("reelfinished") or Event:FindFirstChild("Reel")
                              if Reel then Reel:FireServer(100, true) end
                          end
                      end
                  end)
                  task.wait(1)
              end
          end)
      end
   end,
})

-- Fitur Speed
MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      if Player.Character and Player.Character:FindFirstChild("Humanoid") then
          Player.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

-- Fitur Anti-AFK (Penting agar tidak DC)
MainTab:CreateButton({
   Name = "Activate Anti-AFK",
   Callback = function()
       local vu = game:GetService("VirtualUser")
       Player.Idled:Connect(function()
           vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
           task.wait(1)
           vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
       end)
       Rayfield:Notify({Title = "Nyemek Hub", Content = "Anti-AFK Aktif!"})
   end,
})

Rayfield:LoadConfiguration()
