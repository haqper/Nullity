--[[
    ⚡ EXECUTOR UYUMLU PROFESYONEL ADMIN PANELİ
    - Infinite Yield kalitesinde komut sistemi
    - Modern Luau standartları (pcall, task.wait, vs.)
--]]

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  BAŞLANGIÇ KONTROLLERİ & AYARLAR
-- ═══════════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- Karakter yüklenene kadar bekle
repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- Ayarlar tablosu
local Settings = {
    Fly = false, Noclip = false, Bhop = false, Dash = false,
    WalkSpeed = 16, JumpPower = 50, FlySpeed = 75,
    CurrentTarget = nil,
    Fullbright = false, Esp = false, OriginalFov = 70,
    TeleportHistory = {},
}

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  YARDIMCI FONKSİYONLAR
-- ═══════════════════════════════════════════════════════════════════════════════════════

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildWhichIsA("Humanoid")
end

local function GetHumanoidRoot()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function ShowNotification(Title, Text, Duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = Title,
            Text = Text,
            Duration = Duration or 3,
        })
    end)
end

local function GetPlayerFromString(input)
    if not input or input == "" then return nil end
    input = input:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #input) == input or 
           (player.DisplayName and player.DisplayName:lower():sub(1, #input) == input) then
            return player
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  KOMUT ÇEKİRDEĞİ (COMMAND ENGINE)
-- ═══════════════════════════════════════════════════════════════════════════════════════

local Commands = {}

-- Hız ayarlama
Commands["speed"] = function(args)
    local speedValue = tonumber(args[1])
    if speedValue then
        Settings.WalkSpeed = math.clamp(speedValue, 16, 500)
        ShowNotification("⚡ Speed", "Hız: " .. Settings.WalkSpeed, 2)
    else
        Settings.WalkSpeed = 16
        ShowNotification("⚡ Speed", "Normal hıza dönüldü.", 2)
    end
end

-- Zıplama ayarı
Commands["jump"] = function(args)
    local jumpValue = tonumber(args[1])
    if jumpValue then
        Settings.JumpPower = math.clamp(jumpValue, 50, 500)
        ShowNotification("🦘 Jump", "Zıplama gücü: " .. Settings.JumpPower, 2)
    else
        Settings.JumpPower = 50
        ShowNotification("🦘 Jump", "Normal zıplamaya dönüldü.", 2)
    end
end

-- Uçma (Fly)
Commands["fly"] = function()
    Settings.Fly = not Settings.Fly
    if Settings.Fly then
        local hrp = GetHumanoidRoot()
        local hum = GetHumanoid()
        if hrp and hum then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
            hum.PlatformStand = true
            Settings.FlyBodyVelocity = bv
            ShowNotification("🚀 Fly", "Aktif! (WASD ile uç)", 3)
        end
    else
        if Settings.FlyBodyVelocity then Settings.FlyBodyVelocity:Destroy() end
        local hum = GetHumanoid()
        if hum then hum.PlatformStand = false end
        ShowNotification("🚀 Fly", "Kapatıldı.", 2)
    end
end

-- Noclip (Duvar geçme)
Commands["noclip"] = function()
    Settings.Noclip = not Settings.Noclip
    ShowNotification("👻 Noclip", Settings.Noclip and "Aktif!" or "Kapatıldı!", 2)
end

-- B-Hop (Otomatik zıplama)
Commands["bhop"] = function()
    Settings.Bhop = not Settings.Bhop
    ShowNotification("🔄 B-Hop", Settings.Bhop and "Aktif!" or "Kapatıldı!", 2)
end

-- Dash (Hızlı hareket)
Commands["dash"] = function()
    Settings.Dash = not Settings.Dash
    ShowNotification("💨 Dash", Settings.Dash and "Aktif! (CTRL ile dash)", 2)
end

-- Işınlanma (Teleport)
Commands["tp"] = function(args)
    local target = GetPlayerFromString(args[1])
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = GetHumanoidRoot()
        if myRoot then
            table.insert(Settings.TeleportHistory, myRoot.Position)
            myRoot.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
            ShowNotification("📍 Teleport", target.Name .. " yanına ışınlandı!", 2)
        end
    else
        ShowNotification("⚠️ Teleport", "Oyuncu bulunamadı.", 2)
    end
end

-- Yanına çağırma (Bring)
Commands["bring"] = function(args)
    local target = GetPlayerFromString(args[1])
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = GetHumanoidRoot()
        if myRoot then
            target.Character.HumanoidRootPart.CFrame = myRoot.CFrame * CFrame.new(0, 0, 2)
            ShowNotification("🌀 Bring", target.Name .. " yanına getirildi!", 2)
        end
    else
        ShowNotification("⚠️ Bring", "Oyuncu bulunamadı.", 2)
    end
end

-- Öldürme (Kill)
Commands["kill"] = function()
    local humanoid = GetHumanoid()
    if humanoid then humanoid.Health = 0 end
    ShowNotification("⚡ Kill", "Kendini öldürdün!", 2)
end

-- Yeniden doğma (Respawn)
Commands["respawn"] = function()
    LocalPlayer.Character:BreakJoints()
    ShowNotification("🔄 Respawn", "Yeniden doğuluyor...", 2)
end

-- Geri al (Undo Teleport)
Commands["undo"] = function()
    local myRoot = GetHumanoidRoot()
    if myRoot and #Settings.TeleportHistory > 0 then
        local lastPos = table.remove(Settings.TeleportHistory)
        myRoot.CFrame = CFrame.new(lastPos)
        ShowNotification("↩️ Undo", "Geri alındı!", 2)
    else
        ShowNotification("⚠️ Undo", "Geri alınacak pozisyon yok.", 2)
    end
end

-- ESP (Oyuncu işaretleme)
Commands["esp"] = function()
    Settings.Esp = not Settings.Esp
    if not Settings.Esp then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, obj in pairs(player.Character:GetChildren()) do
                    if obj:IsA("Highlight") then obj:Destroy() end
                end
            end
        end
    end
    ShowNotification("👁️ ESP", Settings.Esp and "Aktif!" or "Kapatıldı!", 2)
end

Commands["fullbright"] = function()
    Settings.Fullbright = not Settings.Fullbright
    if Settings.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        ShowNotification("☀️ Fullbright", "Aktif!", 2)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 8
        Lighting.GlobalShadows = true
        ShowNotification("🌙 Fullbright", "Kapatıldı.", 2)
    end
end

Commands["fov"] = function(args)
    local fovValue = tonumber(args[1])
    if fovValue then
        Camera.FieldOfView = math.clamp(fovValue, 20, 120)
        ShowNotification("👓 FOV", "FOV: " .. Camera.FieldOfView, 2)
    else
        Camera.FieldOfView = Settings.OriginalFov
        ShowNotification("👓 FOV", "Normal FOV'a dönüldü.", 2)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  RUNTIME LOOP (Ana döngü - RunService ile)
-- ═══════════════════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = GetCharacter()
        local hum = GetHumanoid()
        local hrp = GetHumanoidRoot()

        if not char or not hum or not hrp then return end

        -- Hız ve zıplama ayarlarını zorla
        if hum.WalkSpeed ~= Settings.WalkSpeed then hum.WalkSpeed = Settings.WalkSpeed end
        if hum.JumpPower ~= Settings.JumpPower then hum.JumpPower = Settings.JumpPower end

        -- Fly mekaniği
        if Settings.Fly and Settings.FlyBodyVelocity then
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            moveDir = moveDir.Unit * Settings.FlySpeed
            Settings.FlyBodyVelocity.Velocity = moveDir
        end

        -- Noclip mekaniği
        if Settings.Noclip then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        -- ESP mekaniği
        if Settings.Esp then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local highlight = player.Character:FindFirstChild("DeltaESP")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "DeltaESP"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                        highlight.Adornee = player.Character
                        highlight.Parent = player.Character
                        highlight.FillTransparency = 0.5
                    end
                end
            end
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  B-HOP & DASH EVENTLERİ
-- ═══════════════════════════════════════════════════════════════════════════════════════

UserInputService.JumpRequest:Connect(function()
    pcall(function()
        if Settings.Bhop then
            local hum = GetHumanoid()
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    pcall(function()
        if Settings.Dash and input.KeyCode == Enum.KeyCode.LeftControl then
            local hrp = GetHumanoidRoot()
            local cameraCF = Camera.CFrame
            if hrp then
                hrp.CFrame = hrp.CFrame + (cameraCF.LookVector * 100)
                ShowNotification("💨 Dash", "Hızlı hareket!", 1)
            end
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════════════════
--  ARAYÜZ (Rayfield UI Kütüphanesi)
-- ═══════════════════════════════════════════════════════════════════════════════════════

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "⚡ EXECUTOR ADMIN PANEL",
    Icon = 0,
    LoadingTitle = "⚡ Yükleniyor...",
    LoadingSubtitle = "Executor Optimized",
    ConfigurationSaving = {Enabled = true, FileName = "Executor_Admin_Panel"},
    KeySystem = false
})

-- Ana Sekme
local MainTab = Window:CreateTab("🏠 Ana Menü", nil)

MainTab:CreateSection("👤 Yerel Ayarlar")
MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(value) Commands["speed"]({tostring(value)}) end
})
MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 250},
    Increment = 5,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(value) Commands["jump"]({tostring(value)}) end
})
MainTab:CreateToggle({Name = "Fly (Uçma)", CurrentValue = false, Flag = "FlyToggle", Callback = function() Commands["fly"]() end})
MainTab:CreateToggle({Name = "Noclip (Duvar Geçme)", CurrentValue = false, Flag = "NoclipToggle", Callback = function() Commands["noclip"]() end})
MainTab:CreateToggle({Name = "B-Hop (Otomatik Zıplama)", CurrentValue = false, Flag = "BhopToggle", Callback = function() Commands["bhop"]() end})
MainTab:CreateToggle({Name = "Dash (CTRL ile Hızlı Hareket)", CurrentValue = false, Flag = "DashToggle", Callback = function() Commands["dash"]() end})

MainTab:CreateSection("👥 Hedef Yönetimi")
local TargetInput = MainTab:CreateInput({
    Name = "Hedef Oyuncu Adı",
    PlaceholderText = "Oyuncu adını yaz...",
    RemoveTextAfterFocusLost = false,
    Flag = "TargetInput",
    Callback = function(text)
        Settings.CurrentTarget = GetPlayerFromString(text)
        if Settings.CurrentTarget then
            ShowNotification("🎯 Hedef", Settings.CurrentTarget.Name .. " seçildi!", 2)
        end
    end
})
MainTab:CreateButton({Name = "Teleport (Oyuncuya Işınlan)", Callback = function() if Settings.CurrentTarget then Commands["tp"]({Settings.CurrentTarget.Name}) else ShowNotification("⚠️ Hata", "Önce bir oyuncu seçin!", 2) end end})
MainTab:CreateButton({Name = "Bring (Yanına Getir)", Callback = function() if Settings.CurrentTarget then Commands["bring"]({Settings.CurrentTarget.Name}) else ShowNotification("⚠️ Hata", "Önce bir oyuncu seçin!", 2) end end})
MainTab:CreateButton({Name = "Kill (Kendini Öldür)", Callback = function() Commands["kill"]() end})
MainTab:CreateButton({Name = "Respawn (Yeniden Doğ)", Callback = function() Commands["respawn"]() end})

-- Görseller Sekmesi
local VisualTab = Window:CreateTab("👁️ Görseller", nil)
VisualTab:CreateToggle({Name = "ESP (Oyuncuları İşaretle)", CurrentValue = false, Flag = "ESPToggle", Callback = function() Commands["esp"]() end})
VisualTab:CreateButton({Name = "Fullbright (Gündüz Yap)", Callback = function() Commands["fullbright"]() end})
VisualTab:CreateSlider({
    Name = "Field of View (FOV)",
    Range = {20, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 70,
    Flag = "FovSlider",
    Callback = function(value) Commands["fov"]({tostring(value)}) end
})

-- Sohbet Komutları (CMD) için dinleyici
local function OnChat(msg, author)
    if author ~= LocalPlayer then return end
    if msg:sub(1, 1) == ";" then
        local parts = {}
        for part in string.gmatch(msg:sub(2), "[^ ]+") do table.insert(parts, part) end
        local cmdName = parts[1] and parts[1]:lower()
        table.remove(parts, 1)
        if Commands[cmdName] then
            Commands[cmdName](parts)
            ShowNotification("⚡ CMD", "Komut çalıştırıldı: " .. cmdName, 2)
        end
    end
end

LocalPlayer.Chatted:Connect(OnChat)

-- Başlangıç Bildirimi
ShowNotification("✅ Executor Admin Panel", "Başarıyla yüklendi! Chat'e ;help yazarak komutları görebilirsin.", 5)
