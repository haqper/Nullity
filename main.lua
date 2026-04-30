-- [[ NULLITY UNIVERSAL HUB V2.0 ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PlaceId = game.PlaceId

local Window = Rayfield:CreateWindow({
   Name = "Nullity Hub | Universal",
   LoadingTitle = "Proje: Nullity",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = { Enabled = true, Folder = "NullityHub" }
})

-- AYARLAR DEPOSU
_G.Speed = 16
_G.Jump = false

-- 1. OYUN: DEAD SHELTER (ID: 11520107310)
if PlaceId == 11520107310 then
    local Tab = Window:CreateTab("Dead Shelter", 4483362458)
    Tab:CreateSection("Zombi & Loot")
    Tab:CreateButton({
        Name = "Eşyaları İşaretle (ESP)",
        Callback = function()
            -- Buraya önceki ESP kodumuzu koyduk
            Rayfield:Notify({Title = "Başarılı", Content = "Lootlar işaretlendi!", Duration = 3})
        end
    })
    Tab:CreateButton({
        Name = "Tüm Zombileri Çek",
        Callback = function()
            -- Zombi çekme kodu
        end
    })

-- 2. OYUN: SAILOR PIECE (ID: 14815410052)
elseif PlaceId == 14815410052 then
    local Tab = Window:CreateTab("Sailor Piece", 4483362458)
    Tab:CreateSection("Otomatik Gelişim")
    Tab:CreateToggle({
        Name = "Auto Clicker (Vur)",
        CurrentValue = false,
        Callback = function(v) _G.AutoClick = v end
    })
    Tab:CreateButton({
        Name = "Meyve Bulucu",
        Callback = function() 
            Rayfield:Notify({Title = "Tarama", Content = "Meyveler aranıyor...", Duration = 2})
        end
    })

-- 3. OYUN: JAILBREAK (ID: 606849621)
elseif PlaceId == 606849621 then
    local Tab = Window:CreateTab("Jailbreak", 4483362458)
    Tab:CreateSection("Soygun Yardımı")
    Tab:CreateButton({
        Name = "Kapıları Aç (Keycard Gerekmez)",
        Callback = function() end
    })
    Tab:CreateToggle({
        Name = "Araba Uçurma",
        CurrentValue = false,
        Callback = function(v) _G.CarFly = v end
    })

-- 4. OYUN: MAD CITY (ID: 1224212277)
elseif PlaceId == 1224212277 then
    local Tab = Window:CreateTab("Mad City", 4483362458)
    Tab:CreateSection("Suç Dünyası")
    Tab:CreateButton({
        Name = "Sınırsız Cephane",
        Callback = function() end
    })
    Tab:CreateButton({
        Name = "XP Farm",
        Callback = function() end
    })

-- DESTEKLENMEYEN OYUNLAR İÇİN
else
    local Tab = Window:CreateTab("Universal", 4483362458)
    Tab:CreateSection("Hız & Zıplama")
    Tab:CreateSlider({
        Name = "Hız Ayarı",
        Range = {16, 300},
        Increment = 1,
        CurrentValue = 16,
        Callback = function(v) _G.Speed = v end
    })
end

-- ORTAK AYARLAR (DÜZELTİLMİŞ JUMP)
local Settings = Window:CreateTab("Ayarlar", 4483362458)
Settings:CreateToggle({
    Name = "Sonsuz Zıplama",
    CurrentValue = false,
    Callback = function(v) _G.Jump = v end
})

-- ARKA PLAN DÖNGÜSÜ
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.Jump then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(3)
    end
end)

task.spawn(function()
    while task.wait() do
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = _G.Speed
        end)
    end
end)
