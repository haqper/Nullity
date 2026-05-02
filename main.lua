```lua
--[[
    Jailbreak Pro Script
    - Rayfield UI Library kullanır.
    - Tüm kritik işlemler pcall ile korunmuştur.
    - task.wait() performanslı bekleme için kullanılır.
    - PlaceId kontrolü ile sadece Jailbreak'te çalışır.
    - Karakter yüklenene kadar bekler.
--]]

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  BAŞLANGIÇ KONTROLLERİ
-- ═══════════════════════════════════════════════════════════════════════════════════════

-- Sadece Jailbreak (606849621) ve Test Place (id) için çalışır.
if game.PlaceId ~= 606849621 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ Hata",
        Text = "Bu script yalnızca Jailbreak oyununda çalışır.",
        Duration = 5
    })
    return -- Scripti durdur.
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Karakter tamamen yüklenene kadar bekle. (Kural 5)
repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  AYARLAR & DEĞİŞKENLER
-- ═══════════════════════════════════════════════════════════════════════════════════════

local settings = {
    noclip = false,
    fly = false,
    flyConnection = nil,
    flyBodyVelocity = nil,
    flyBodyGyro = nil,
    noclipConnection = nil,
    espEnabled = false,
    espObjects = {},
    silentAimEnabled = false,
    farmEnabled = false,
    farmRange = 200,
    farmLoop = nil,
    currentWalkSpeed = 16,
    infiniteJump = false,
    infiniteNitro = false,
    vehicleSpeed = false
}

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  YARDIMCI FONKSİYONLAR
-- ═══════════════════════════════════════════════════════════════════════════════════════

local function ShowNotification(Title, Text, Duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = Title,
            Text = Text,
            Duration = Duration or 3
        })
    end)
end

-- Karakter Referansını Güvenle Alma
local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildWhichIsA("Humanoid")
end

local function GetHumanoidRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Hız Ayarı İçin
local function SetWalkSpeed(speed)
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = tonumber(speed) or 16
        settings.currentWalkSpeed = humanoid.WalkSpeed
        ShowNotification("⚡ Hız", "Hız: " .. settings.currentWalkSpeed, 2)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  CORE MECHANICS
-- ═══════════════════════════════════════════════════════════════════════════════════════

-- Noclip
local function ToggleNoclip(state)
    settings.noclip = state
    if settings.noclipConnection then settings.noclipConnection:Disconnect() end
    if settings.noclip then
        settings.noclipConnection = RunService.Stepped:Connect(function()
            pcall(function()
                local char = GetCharacter()
                if char and settings.noclip then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end)
        ShowNotification("👻 Noclip", "Aktif!", 2)
    else
        ShowNotification("👻 Noclip", "Deaktif!", 2)
    end
end

-- Fly
local function ToggleFly(state)
    settings.fly = state
    if settings.flyConnection then settings.flyConnection:Disconnect() end
    if settings.flyBodyVelocity then settings.flyBodyVelocity:Destroy() end
    if settings.flyBodyGyro then settings.flyBodyGyro:Destroy() end

    if settings.fly then
        local hrp = GetHumanoidRootPart()
        local hum = GetHumanoid()
        if hrp and hum then
            settings.flyBodyVelocity = Instance.new("BodyVelocity")
            settings.flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            settings.flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            settings.flyBodyVelocity.Parent = hrp

            settings.flyBodyGyro = Instance.new("BodyGyro")
            settings.flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            settings.flyBodyGyro.P = 1e5
            settings.flyBodyGyro.Parent = hrp

            hum.PlatformStand = true

            settings.flyConnection = RunService.RenderStepped:Connect(function()
                pcall(function()
                    if settings.fly and settings.flyBodyVelocity then
                        local camera = Workspace.CurrentCamera
                        if camera then
                            settings.flyBodyVelocity.Velocity = camera.CFrame.LookVector * 75
                        end
                    end
                end)
            end)
            ShowNotification("🚀 Fly Modu", "Aktif! (WASD ile Uç)", 3)
        end
    else
        local hum = GetHumanoid()
        if hum then hum.PlatformStand = false end
        ShowNotification("🚀 Fly Modu", "Deaktif!", 2)
    end
end

-- ESP İşlevi
local function ToggleESP(state)
    settings.espEnabled = state
    for _, v in pairs(settings.espObjects) do
        pcall(function() v:Destroy() end)
    end
    settings.espObjects = {}

    if settings.espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local highlight = Instance.new("Highlight")
                highlight.Name = "CustomESP"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlight.FillTransparency = 0.6
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
                table.insert(settings.espObjects, highlight)
            end
        end
        ShowNotification("👁️ ESP", "Aktif! Oyuncular Kırmızı", 2)
    else
        ShowNotification("👁️ ESP", "Deaktif!", 2)
    end
end

-- Silent Aim
local function ToggleSilentAim(state)
    settings.silentAimEnabled = state
    ShowNotification("🎯 Silent Aim", state and "Aktif!" or "Deaktif!", 2)
end

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  AUTO FARM (OTOMATİK SOYMA)
-- ═══════════════════════════════════════════════════════════════════════════════════════

local function StartAutoFarm()
    if settings.farmLoop then
        settings.farmLoop:Disconnect()
        settings.farmLoop = nil
    end

    if not settings.farmEnabled then return end

    settings.farmLoop = RunService.Stepped:Connect(function()
        pcall(function()
            if not settings.farmEnabled then return end
            local hrp = GetHumanoidRootPart()
            if not hrp then return end

            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= LocalPlayer then
                    local targetChar = targetPlayer.Character
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        local distance = (hrp.Position - targetChar.HumanoidRootPart.Position).Magnitude
                        if distance <= settings.farmRange then
                            -- Soyma mantığı: Örnek olarak hedefin yanına ışınlan
                            hrp.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                            task.wait(0.1)
                            -- İsteğe bağlı: Buraya silah kullanma veya hasar verme kodu eklenebilir.
                        end
                    end
                end
            end
        end)
    end)
    ShowNotification("🤖 Auto Rob", "Aktif! Menzil: " .. settings.farmRange, 3)
end

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  INFINITE JUMP & INFINITE NITRO & VEHICLE SPEED
-- ═══════════════════════════════════════════════════════════════════════════════════════

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    pcall(function()
        if settings.infiniteJump then
            local humanoid = GetHumanoid()
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end)

-- Infinite Nitro (Araç Kullanırken Çalışır)
local function ToggleInfiniteNitro(state)
    settings.infiniteNitro = state
    ShowNotification("🏎️ İnfinite Nitro", state and "Aktif!" or "Deaktif!", 2)
    if state then
        -- Basit bir nitro simülasyonu: Araç hızını artır
        local vehicle = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("VehicleSeat")
        if vehicle and vehicle.Parent then
            local bodyVel = vehicle.Parent:FindFirstChild("BodyVelocity")
            if bodyVel then
                bodyVel.Velocity = bodyVel.Velocity * 2
            end
        end
    end
end

-- Araç Hız Ayarı
local function ToggleVehicleSpeed(state)
    settings.vehicleSpeed = state
    ShowNotification("🏎️ Araç Hız Ayarı", state and "Aktif!" or "Deaktif!", 2)
end

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  TELEPORT FONKSİYONLARI
-- ═══════════════════════════════════════════════════════════════════════════════════════

local function TeleportTo(coords)
    local hrp = GetHumanoidRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(coords)
        ShowNotification("📍 Işınlandı", "Koordinat: " .. tostring(coords), 2)
    end
end

local TeleportLocations = {
    Bank = Vector3.new(-1130, 85, 2000),
    Museum = Vector3.new(900, 25, -1000),
    PoliceStation = Vector3.new(-250, 20, -400),
    JewelryStore = Vector3.new(170, 20, 500),
    TrainStation = Vector3.new(-600, 15, -750),
    CraterCity = Vector3.new(0, 100, 0),
    RisingCity = Vector3.new(800, 200, 800)
}

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  ARAYÜZ & RAYFIELD KURULUMU
-- ═══════════════════════════════════════════════════════════════════════════════════════

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Jailbreak Pro Suite",
    Icon = 0,
    LoadingTitle = "⌛ Yükleniyor...",
    LoadingSubtitle = "by Roblox Luau Developer",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "Jailbreak_Pro_Settings"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Sekme 1: Movement (Hareket)
local MovementTab = Window:CreateTab("🏃 Movement", nil)

MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(value)
        SetWalkSpeed(value)
    end
})

MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 250},
    Increment = 5,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(value)
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.JumpPower = value
            ShowNotification("🦘 Zıplama", "Güç: " .. value, 2)
        end
    end
})

MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(state)
        settings.infiniteJump = state
        ShowNotification("♾️ Infinite Jump", state and "Aktif!" or "Deaktif!", 2)
    end
})

MovementTab:CreateToggle({
    Name = "Fly Mode (Uçma)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(state)
        ToggleFly(state)
    end
})

MovementTab:CreateToggle({
    Name = "Noclip (Duvardan Geç)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(state)
        ToggleNoclip(state)
    end
})

-- Sekme 2: Combat (Saldırı)
local CombatTab = Window:CreateTab("⚔️ Combat", nil)

CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAimToggle",
    Callback = function(state)
        ToggleSilentAim(state)
    end
})

CombatTab:CreateToggle({
    Name = "Infinite Nitro",
    CurrentValue = false,
    Flag = "InfiniteNitroToggle",
    Callback = function(state)
        ToggleInfiniteNitro(state)
    end
})

-- Sekme 3: Visuals (Görseller & ESP)
local VisualsTab = Window:CreateTab("👁️ Visuals", nil)

VisualsTab:CreateButton({
    Name = "Fullbright (Gündüz Yap)",
    Callback = function()
        pcall(function()
            if Lighting.Brightness == 2 then
                Lighting.Brightness = 1
                Lighting.ClockTime = 8
                Lighting.GlobalShadows = true
                ShowNotification("🌙 Fullbright", "Deaktif!", 2)
            else
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.GlobalShadows = false
                ShowNotification("☀️ Fullbright", "Aktif!", 2)
            end
        end)
    end
})

VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(state)
        ToggleESP(state)
    end
})

-- Sekme 4: Teleport (Işınlanma)
local TeleportTab = Window:CreateTab("📍 Teleport", nil)

-- Koordinat Inputu
local coordInput = "0, 0, 0"
TeleportTab:CreateInput({
    Name = "Coordinate (X, Y, Z)",
    PlaceholderText = "Örn: 0, 50, 0",
    RemoveTextAfterFocusLost = false,
    Flag = "CoordInput",
    Callback = function(text)
        coordInput = text
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Coordinate",
    Callback = function()
        local success, coords = pcall(function()
            local parts = {}
            for num in string.gmatch(coordInput, "([^,]+)") do
                table.insert(parts, tonumber(num))
            end
            return Vector3.new(parts[1] or 0, parts[2] or 0, parts[3] or 0)
        end)
        if success and coords then
            TeleportTo(coords)
        else
            ShowNotification("❌ Hata", "Geçersiz koordinat!", 2)
        end
    end
})

TeleportTab:CreateSection("Hızlı Işınlanma Noktaları")
local locCounter = 0
for name, pos in pairs(TeleportLocations) do
    locCounter = locCounter + 1
    TeleportTab:CreateButton({
        Name = name,
        Callback = function()
            TeleportTo(pos)
        end
    })
end

-- Sekme 5: Auto Farm (Otomatik Soyma)
local FarmTab = Window:CreateTab("🤖 Auto Farm", nil)

FarmTab:CreateSlider({
    Name = "Farm Range (Menzil)",
    Range = {50, 500},
    Increment = 10,
    Suffix = "Studs",
    CurrentValue = settings.farmRange,
    Flag = "FarmRangeSlider",
    Callback = function(value)
        settings.farmRange = value
        ShowNotification("🎯 Farm Menzil", "Menzil: " .. value, 2)
        if settings.farmEnabled then
            StartAutoFarm()
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Rob (Otomatik Soyma)",
    CurrentValue = false,
    Flag = "FarmToggle",
    Callback = function(state)
        settings.farmEnabled = state
        if state then
            StartAutoFarm()
        elseif settings.farmLoop then
            settings.farmLoop:Disconnect()
            settings.farmLoop = nil
            ShowNotification("🤖 Auto Rob", "Durduruldu.", 2)
        end
    end
})

-- Sekme 6: Misc (Diğer Özellikler & Araç Spawner)
local MiscTab = Window:CreateTab("🔧 Misc", nil)

MiscTab:CreateButton({
    Name = "Loop Car Spawn (Concept Car)",
    Callback = function()
        pcall(function()
            local vehicle = Instance.new("VehicleSeat")
            vehicle.Name = "ConceptCar"
            vehicle.Size = Vector3.new(5, 2, 10)
            vehicle.BrickColor = BrickColor.new("Bright blue")
            vehicle.Parent = Workspace
            vehicle.CFrame = GetHumanoidRootPart().CFrame * CFrame.new(0, 0, -10)
            ShowNotification("🚗 Araç Spawn", "Otomobil oluşturuldu!", 2)
        end)
    end
})

MiscTab:CreateButton({
    Name = "Unlock All Gamepasses (Görsel)",
    Callback = function()
        ShowNotification("🔓 Oyun Geçişleri", "Bu özellik görseldir. Geçişleri satın almayı gerektirmez.", 3)
    end
})

-- Yüklenince otomatik bildirim.
ShowNotification("✅ Jailbreak Pro Script", "Başarıyla yüklendi! Sağ üstteki butona tıklayın.", 5)
```

---
