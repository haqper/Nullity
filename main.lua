--====================================================================
-- NULLITY HUB V1.0 | DEAD SHELTER PROFESSIONAL EDITION
--====================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nullity Hub | Dead Shelter",
   LoadingTitle = "Nullity Project",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = { Enabled = true, Folder = "NullityHub" },
   Discord = { Enabled = false, Invite = "", RememberJoins = true },
   KeySystem = false -- Şimdilik anahtar sistemi kapalı
})

-- AYARLAR
_G.Speed = 16
_G.Jump = false
_G.Aimbot = false
_G.FullBright = false

-- SEKMELER
local MainTab = Window:CreateTab("Genel", 4483362458)
local LootTab = Window:CreateTab("Loot", 4483362458)
local CombatTab = Window:CreateTab("Savaş", 4483362458)

-- GENEL SEKME (HIZ VE ZIPLAMA)
MainTab:CreateSection("Hareket")

MainTab:CreateSlider({
   Name = "Yürüme Hızı",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
       _G.Speed = Value
   end,
})

MainTab:CreateToggle({
   Name = "Sonsuz Zıplama",
   CurrentValue = false,
   Callback = function(Value)
       _G.Jump = Value
   end,
})

MainTab:CreateToggle({
   Name = "Gece Görüşü (FullBright)",
   CurrentValue = false,
   Callback = function(Value)
       _G.FullBright = Value
   end,
})

-- LOOT SEKME
LootTab:CreateSection("Eşya Tarayıcı")

LootTab:CreateButton({
   Name = "Eşyaları Tara (Highlight)",
   Callback = function()
       -- Daha önce yazdığımız tarama kodunu buraya ekledik
       local items = {"crate", "ammo", "gun", "rifle", "pistol", "medkit", "scrap", "part"}
       for _, v in pairs(game.Workspace:GetDescendants()) do
           if v:IsA("Model") or v:IsA("BasePart") then
               local name = v.Name:lower()
               for _, itemName in pairs(items) do
                   if name:find(itemName) and not v:FindFirstChild("LootTag") then
                       local h = Instance.new("Highlight", v)
                       h.Name = "LootTag"
                       h.FillColor = Color3.new(1, 1, 0)
                       break
                   end
               end
           end
       end
       Rayfield:Notify({Title = "Başarılı", Content = "Eşyalar işaretlendi!", Duration = 3})
   end,
})

-- SAVAŞ SEKME
CombatTab:CreateSection("Savaş Yardımcısı")

CombatTab:CreateToggle({
   Name = "Aimbot (Kilitlenme)",
   CurrentValue = false,
   Callback = function(Value)
       _G.Aimbot = Value
   end,
})

CombatTab:CreateButton({
   Name = "Tüm Zombileri Yakına Çek",
   Callback = function()
       for _, v in pairs(game.Workspace:GetDescendants()) do
           if v:IsA("Model") and v:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(v) then
               if v:FindFirstChild("HumanoidRootPart") then
                   v.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
               end
           end
       end
   end,
})

-- ARKA PLAN DÖNGÜSÜ
task.spawn(function()
    while task.wait() do
        pcall(function()
            local lp = game.Players.LocalPlayer
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.WalkSpeed = _G.Speed
                if _G.Jump and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                    lp.Character.Humanoid:ChangeState(3)
                end
            end
            if _G.FullBright then
                game:GetService("Lighting").Brightness = 2
                game:GetService("Lighting").ClockTime = 14
            end
        end)
    end
end)
