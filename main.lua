-- Nullity Yield v2.0 - Master Commander

-- Gerekli Servisleri Tanımlayalım
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Global Değişkenleri Tanımlayalım
local LP = Players.LocalPlayer
local Character = LP.Character
local CharacterAddedConnection
local CharacterRemovingConnection
local IsNoclip = false
local IsEsp = false
local IsFlying = false
local IsInvisible = false
local FlightVelocity = Vector3.new(0, 100, 0)
local EspHighlights = {}
local _G = _G or {}

-- 1. COMMAND REGISTRY
local Commands = {}

-- 2. YARDIMCI FONKSİYONLAR
-- Fonksiyon: Oyuncuyu Ara
local function GetPlayer(name)
    if not name or name == "" then return nil end
    name = name:lower()
    for _, ply in ipairs(Players:GetPlayers()) do
        if ply.Name:lower():sub(1, #name) == name or ply.DisplayName:lower():sub(1, #name) == name then
            return ply
        end
    end
    return nil
end

-- Fonksiyon: Komutları Parse Et
local function ParseCommand(input)
    local args = {}
    for word in string.gmatch(input, "%S+") do
        table.insert(args, word)
    end
    local commandName = table.remove(args, 1)
    return commandName, args
end

-- Fonksiyon: Komutu Execute Et
local function ExecuteCommand(input)
    local commandName, args = ParseCommand(input)
    local commandFunction = Commands[commandName]

    if commandFunction then
        local success, err = pcall(commandFunction, unpack(args))
        if success then
            print("[Success] Komut başarıyla çalıştırıldı.")
        else
            warn("[Error] Komut çalıştırılırken hata oluştu: " .. tostring(err))
            Rayfield:Notify({Title = "Hata", Content = "Komut çalıştırılırken hata oluştu: " .. tostring(err)})
        end
    else
        warn("[Info] Belirtilen komut bulunamadı.")
        Rayfield:Notify({Title = "Hata", Content = "Belirtilen komut bulunamadı."})
    end
end

-- Fonksiyon: ESP'yi Güncellemek
local function UpdateEsp()
    for _, highlight in pairs(EspHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    EspHighlights = {}

    if IsEsp then
        for _, ply in ipairs(Players:GetPlayers()) do
            if ply ~= LP and ply.Character then
                local highlight = Instance.new("Highlight", ply.Character)
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                EspHighlights[ply.Name] = highlight
            end
        end
    end
end

-- Fonksiyon: Flight'i Etkinleştirme/Aksitleştirme
local function ToggleFlight(enable)
    if enable then
        IsFlying = true
        local function OnRenderStepped()
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local moveVector = Vector3.new()
                local speed = 15

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + Character.HumanoidRootPart.CFrame.ForwardVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector + (-Character.HumanoidRootPart.CFrame.ForwardVector) * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector + (-Character.HumanoidRootPart.CFrame.RightVector) * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + Character.HumanoidRootPart.CFrame.RightVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, speed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveVector = moveVector + Vector3.new(0, -speed, 0)
                end

                Character.HumanoidRootPart.Velocity = moveVector
            end
        end

        RunService.RenderStepped:Connect(OnRenderStepped)
    else
        IsFlying = false
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- 3. KOMUT DEFINITION (Beyin Kısmı)
-- [[ HIZ VE ZIPLAMA ]]
Commands.speed = function(args)
    local s = tonumber(args[1]) or 16
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = s
        _G.LastWalkSpeed = s
    else
        Rayfield:Notify({Title = "Hata", Content = "Karakter yüklenmemiş veya Humanoid bulunamadı."})
    end
end

Commands.jump = function(args)
    local j = tonumber(args[1]) or 50
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = j
        _G.LastJumpPower = j
    else
        Rayfield:Notify({Title = "Hata", Content = "Karakter yüklenmemiş veya Humanoid bulunamadı."})
    end
end

-- [[ TELEPORT ]]
Commands.tp = function(args)
    local target = GetPlayer(args[1] or "")
    if target and target.Character then
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
        Rayfield:Notify({Title = "Teleport", Content = "Oyuncuya başarıyla ışındınız."})
    else
        Rayfield:Notify({Title = "Hata", Content = "Hedef oyuncu bulunamadı."})
    end
end

-- [[ ESP - OYUNCULARI GÖRME ]]
Commands.esp = function()
    IsEsp = not IsEsp
    UpdateEsp()
    Rayfield:Notify({Title = "ESP Durumu", Content = IsEsp and "ESP Açık" or "ESP Kapalı"})
end

-- [[ KILL - ÖLDÜRME (Kılıç/Tool Gerektirir) ]]
Commands.kill = function(args)
    local target = GetPlayer(args[1] or "")
    local tool = Character:FindFirstChildOfClass("Tool")
    if target and target.Character and tool and tool:FindFirstChild("Handle") then
        local targetPart = target.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            firetouchinterest(targetPart, tool.Handle, 0)
            firetouchinterest(targetPart, tool.Handle, 1)
            Rayfield:Notify({Title = "Hedef Elendi", Content = target.Name .. " başarıyla paketlendi."})
        end
    else
        Rayfield:Notify({Title = "Hata", Content = "Elinizde bir kılıç/eşya bulunmalı veya hedef oyuncu yanlış yazıldı."})
    end
end

-- [[ INVISIBLE - GÖRÜNMEZLİK ]]
Commands.invisible = function()
    IsInvisible = not IsInvisible
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = IsInvisible and 0.5 or 0
            end
        end
        Rayfield:Notify({Title = "Görünmezlik", Content = IsInvisible and "Görünmez" or "Görünür"})
    else
        Rayfield:Notify({Title = "Hata", Content = "Karakter yüklenmemiş!"})
    end
end

-- [[ NOCLIP ]]
Commands.noclip = function()
    IsNoclip = true
    Rayfield:Notify({Title = "Noclip", Content = "Noclip Açık"})
end

Commands.clip = function()
    IsNoclip = false
    Rayfield:Notify({Title = "Noclip", Content = "Noclip Kapalı"})
end

-- [[ FLY / UNFLY ]]
Commands.fly = function()
    ToggleFlight(true)
    Rayfield:Notify({Title = "Uçma", Content = "Uçma Açık"})
end

Commands.unfly = function()
    ToggleFlight(false)
    Rayfield:Notify({Title = "Uçma", Content = "Uçma Kapalı"})
end

-- [[ FLING - Hedef Oyuncuyu Fling Atma ]]
Commands.fling = function(args)
    local target = GetPlayer(args[1] or "")
    if target and target.Character then
        local targetTorso = target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("HumanoidRootPart")
        local localHumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

        if targetTorso and localHumanoidRootPart then
            local Attachment0 = Instance.new("Attachment", localHumanoidRootPart)
            local Attachment1 = Instance.new("Attachment", targetTorso)
            local RopeConstraint = Instance.new("RopeConstraint", localHumanoidRootPart)

            Attachment0.Visible = false
            Attachment1.Visible = false

            Attachment0.Name = "Attachment"
            Attachment1.Name = "Attach"

            RopeConstraint.Visible = false
            RopeConstraint.ConstraintActType = Enum.ActuatorType.On
            RopeConstraint.Attachment0 = Attachment0
            RopeConstraint.Attachment1 = Attachment1
            RopeConstraint.Restitution = 0
            RopeConstraint.Damping = 0
            RopeConstraint.Length = 20
            RopeConstraint.Thickness = 0.5
            RopeConstraint.Thickness0 = 0.5
            RopeConstraint.Thickness1 = 0.5

            wait(0.2)
            localHumanoidRootPart.Velocity = Vector3.new(250, 150, 250)
            wait(1)
            RopeConstraint:Destroy()
            Attachment0:Destroy()
            Attachment1:Destroy()

            Rayfield:Notify({Title = "Fling", Content = target.Name .. " başarıyla fling atıldı."})
        else
            Rayfield:Notify({Title = "Hata", Content = "Hedef karakter parçaları bulunamadı!"})
        end
    else
        Rayfield:Notify({Title = "Hata", Content = "Hedef oyuncu bulunamadı!"})
    end
end

-- [[ GODMODE - Karakter Koruma ]]
Commands.godmode = function()
    _G.GodModeEnabled = true
    local function OnTakeDamage(damage, attacker)
        if _G.GodModeEnabled then
            return 0
        else
            return damage
        end
    end

    if Character and Character:FindFirstChild("Humanoid") then
        local humanoid = Character.Humanoid
        humanoid.Died:Connect(function()
            if _G.GodModeEnabled then
                humanoid:UnequipTools()
                humanoid.Health = humanoid.MaxHealth
            end
        end)

        humanoid.TakeDamage = setmetatable({}, {
            __index = humanoid.TakeDamage,
            __call = function(self, ...)
                return OnTakeDamage(...)
            end
        })

        humanoid.BreakJointsOnDeath = false
    else
        Rayfield:Notify({Title = "Hata", Content = "Karakter yüklenmemiş!"})
    end
    Rayfield:Notify({Title = "God Mode", Content = "God Mode Açık"})
end

Commands.ungodmode = function()
    _G.GodModeEnabled = false
    if Character and Character:FindFirstChild("Humanoid") then
        local humanoid = Character.Humanoid
        humanoid.TakeDamage = humanoid.TakeDamage.__index or nil
    end
    Rayfield:Notify({Title = "God Mode", Content = "God Mode Kapalı"})
end

-- 4. AUTO-RECONNECTION
-- Fonksiyon: Karakter Yenilenme Yönetimi
local function OnCharacterAdded(newCharacter)
    Character = newCharacter
    local primaryPart = Character:FindFirstChild("PrimaryPart")
    local humanoid = Character:FindFirstChild("Humanoid")

    if IsNoclip and primaryPart then
        primaryPart.CanCollide = false
    elseif primaryPart then
        primaryPart.CanCollide = true
    end

    if humanoid then
        humanoid.WalkSpeed = tonumber(_G.LastWalkSpeed) or 16
        humanoid.JumpPower = tonumber(_G.LastJumpPower) or 50
    end

    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = IsInvisible and 0.5 or 0
        end
    end

    UpdateEsp()
end

-- Fonksiyon: Karakter Kaybolma Yönetimi
local function OnCharacterRemoving()
    if Character and Character.PrimaryPart then
        Character.PrimaryPart.CanCollide = true
    end
    Character = nil
end

-- Karakter başlamışsa bağlantıları tazele
if Character then
    OnCharacterAdded(Character)
end

CharacterAddedConnection = LP.CharacterAdded:Connect(OnCharacterAdded)
CharacterRemovingConnection = LP.CharacterRemoving:Connect(OnCharacterRemoving)

-- Heartbeat ile Noclip Durumunu Kontrol Et
RunService.RenderStepped:Connect(function()
    if IsNoclip and Character and Character.PrimaryPart then
        Character.PrimaryPart.CanCollide = false
    end
end)

-- 5. UI (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source', true))()

local Window = Rayfield:CreateWindow({
    Name = "Nullity Yield | Pro Admin",
    LoadingTitle = "Sistemler Hazırlanıyor...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "NullityYieldConfig"
    }
})

local Tab = Window:CreateTab("Komutlar", 4483362458)

local CommandBar = Tab:CreateInput({
    Name = "Command Bar (Örn: tp player)",
    PlaceholderText = "Komutlarınızı buraya yazın...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        ExecuteCommand(text)
    end,
})
