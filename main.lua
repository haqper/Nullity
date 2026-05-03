-- [[ NULLITY YIELD v2.0 - MASTER COMMANDER ]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Rayfield Kütüphanesini Yükleyelim
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source', true))()

local LP = Players.LocalPlayer
local Character = LP.Character or nil
local CharacterAddedConnection
local CharacterRemovingConnection
local IsNoclip = false
local IsEsp = false
local FlightVelocity = Vector3.new(0, 100, 0)
local EspHighlights = {}

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

                if IsFlying then
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
                    if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                        moveVector = moveVector + Vector3.new(0, speed, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                        moveVector = moveVector + Vector3.new(0, -speed, 0)
                    end

                    Character.HumanoidRootPart.Velocity = moveVector
                else
                    Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end

        RunService.RenderStepped:Connect(OnRenderStepped)
    else
        IsFlying = false
    end
end

-- 3. KOMUT REGISTRY (Beyin Kısmı) -- [[ HIZ VE ZIPLAMA ]]
Commands.speed = function(args)
    local s = tonumber(args[1]) or 16
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = s
        _G.LastWalkSpeed = s
    end
end

Commands.jump = function(args)
    local j = tonumber(args[1]) or 50
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = j
        _G.LastJumpPower = j
    end
end

-- [[ TELEPORT ]]
Commands.tp = function(args)
    local target = GetPlayer(args[1] or "")
    if target and target.Character then
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            Rayfield:Notify({Title = "Teleport", Content = "Oyuncuya başarıyla ışındınız."})
        end
    else
        Rayfield:Notify({Title = "Hata", Content = "Hedef oyuncu bulunamadı!"})
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
        else
            Rayfield:Notify({Title = "Hata", Content = "Hedef karakterin HumanoidRootPart bulunamadı!"})
        end
    else
        Rayfield:Notify({Title = "Hata", Content = "Elinizde bir kılıç/eşya bulunmalı veya hedef oyuncu yanlış yazıldı!"})
    end
end

-- [[ INVISIBLE - GÖRÜNMEZLİK ]]
Commands.invisible = function()
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                if part.CanCollide then
                    part.Transparency = part.Transparency == 0 and 0.5 or 0
                else
                    part.Transparency = part.Transparency == 0 and 0.9 or 0
                end
            end
        end
        _G.InvisibleTransparency = Character.HumanoidRootPart.Transparency == 0.5 and 0.5 or 0
        Rayfield:Notify({Title = "Görünmezlik", Content = Character.HumanoidRootPart.Transparency == 0.5 and "Görünmez" or "Görünür"})
    else
        Rayfield:Notify({Title = "Hata", Content = "Karakter yüklenmemiş!"})
    end
end

-- [[ NOCLIP ]] --
Commands.noclip = function()
    IsNoclip = true
    Rayfield:Notify({Title = "Noclip", Content = "Noclip Açık"})
end

Commands.clip = function()
    IsNoclip = false
    Rayfield:Notify({Title = "Noclip", Content = "Noclip Kapalı"})
    if Character then
        Character.PrimaryPart.CanCollide = true
    end
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

-- [[ TP TO TOUCH ]] --
Commands.tptoTouch = function()
    if _G.TpToTouch then
        _G.TpToTouch:Stop()
        _G.TpToTouch = false
    else
        _G.TpToTouch = true
        local function onTouchStarted(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Touch then
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local hit = Workspace:FindPartOnRay(Ray.new(Character.Head.Position, (input.Position - Character.Head.Position).Unit * 300))
                    if hit then
                        Character.HumanoidRootPart.CFrame = hit.CFrame + Vector3.new(0, 5, 0)
                    end
                end
            end
        end

        UserInputService.TouchBegan:Connect(onTouchStarted)
    end
    Rayfield:Notify({Title = "TP to Touch", Content = _G.TpToTouch and "İşlem Başlatıldı" or "İşlem Durduruldu"})
end

-- 4. KARAKTER YENILEME VE STABİLİTE

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
            part.Transparency = part.Transparency == 0 and (_G.InvisibleTransparency or 0) or 0
        end
    end

    UpdateEsp()
end

-- Fonksiyon: Karakter Kaybolma Yönetimi
local function OnCharacterRemoving()
    if Character then
        if IsNoclip then
            local primaryPart = Character:FindFirstChild("PrimaryPart")
            if primaryPart then
                primaryPart.CanCollide = true
            end
        end
        Character = nil
    end
end

-- Karakter başlamışsa bağlantıları tazele
if Character then
    OnCharacterAdded(Character)
end

CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
CharacterRemovingConnection = LocalPlayer.CharacterRemoving:Connect(OnCharacterRemoving)

-- Heartbeat ile Noclip Durumunu Kontrol Et
RunService.RenderStepped:Connect(function()
    if IsNoclip and Character and Character.PrimaryPart then
        Character.PrimaryPart.CanCollide = false
    end
end)

-- 5. ARAYÜZ (UI)

-- Pencere Oluşturalım
local Window = Rayfield:CreateWindow({
    Name = "Nullity Yield | Pro Admin",
    LoadingTitle = "Sistemler Hazırlanıyor...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "NullityYieldConfig"
    }
})

-- Komutlar Tab'ını Oluşturalım
local Tab = Window:CreateTab("Komutlar", 4483362458)

-- Command Bar Textbox'u Oluşturalım
Tab:CreateTextBox({
    Name = "Command Bar (Örn: tp player)",
    PlaceholderText = "Komutlarınızı buraya yazın...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        ExecuteCommand(text)
    end,
})

-- Fonksiyon: Komut Çalıştırma
local function ExecuteCommand(input)
    local args = {}
    for word in input:gmatch("%S+") do
        table.insert(args, word)
    end

    local commandName = table.remove(args, 1)

    local commandFunction = Commands[commandName]

    if commandFunction then
        local success, err = pcall(commandFunction, args)
        if success then
            print("[Success] Komut başarıyla çalıştırıldı.")
        else
            warn("[Error] Komut çalıştırılırken hata oluştu: " .. tostring(err))
        end
    else
        warn("[Info] Belirtilen komut bulunamadı.")
    end
end

-- Ekstra Komutlar
-- [[ GODMODE ]] --
Commands.godmode = function()
    _G.GodModeEnabled = true
    local function OnTakeDamage(damage, attacker, callback)
        if _G.GodModeEnabled then
            callback(0)
        end
    end

    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid:Died:Connect(function()
            if _G.GodModeEnabled then
                Character.Humanoid:UnequipTools()
                Character.Humanoid.Health = Character.Humanoid.MaxHealth
            end
        end)

        Character.Humanoid:Died:Connect(function()
            for _, bodyPart in ipairs(Character:GetDescendants()) do
                if bodyPart:IsA("BasePart") or bodyPart:IsA("Decal") then
                    bodyPart.BreakJointsOnDeath = false
                    bodyPart.Anchored = false
                end
            end
        end)

        Character.Humanoid.TakeDamage = OnTakeDamage
    end
    Rayfield:Notify({Title = "God Mode", Content = "God Mode Açık"})
end

Commands.ungodmode = function()
    _G.GodModeEnabled = false
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.TakeDamage = nil
    end
    Rayfield:Notify({Title = "God Mode", Content = "God Mode Kapalı"})
end

-- [[ TP TO TARGET ]] --
Commands.tptarget = function(args)
    local target = GetPlayer(args[1] or "")
    if target and target.Character then
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            Rayfield:Notify({Title = "Teleport", Content = "Oyuncuya başarıyla ışındınız."})
        end
    else
        Rayfield:Notify({Title = "Hata", Content = "Hedef oyuncu bulunamadı!"})
    end
end

-- [[ FLY WITH TOUCH ]] --
Commands.touchfly = function()
    if _G.TouchFly then
        _G.TouchFly:Stop()
        _G.TouchFly = false
    else
        _G.TouchFly = true
        local flying = false
        local moveVector = Vector3.new()
        local speed = 15

        local function onTouchStarted(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Touch then
                flightPoint = input.Position
                flying = true
            end
        end

        local function onTouchMoved(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Touch and flying then
                local delta = (input.Position - flightPoint)
                moveVector = Vector3.new(delta.X, delta.Y, 0) * speed
            end
        end

        local function onTouchEnded(input, processed)
            if input.UserInputType == Enum.UserInputType.Touch then
                flying = false
                moveVector = Vector3.new(0, 0, 0)
            end
        end

        local function onRenderStepped()
            if flying and Character and Character:FindFirstChild("HumanoidRootPart") then
                Character.HumanoidRootPart.Velocity = moveVector
            else
                moveVector = Vector3.new(0, 0, 0)
            end
        end

        UserInputService.TouchBegan:Connect(onTouchStarted)
        UserInputService.TouchMoved:Connect(onTouchMoved)
        UserInputService.TouchEnded:Connect(onTouchEnded)
        RunService.RenderStepped:Connect(onRenderStepped)
    end
    Rayfield:Notify({Title = "Touch Fly", Content = _G.TouchFly and "İşlem Başlatıldı" or "İşlem Durduruldu"})
end

Commands.untouchfly = function()
    _G.TouchFly = false
    Rayfield:Notify({Title = "Touch Fly", Content = "İşlem Durduruldu"})
end

-- [[ FLING ]] --
Commands.fling = function(args)
    local target = GetPlayer(args[1] or "")
    if target and target.Character then
        local targetTorso = target.Character:FindFirstChild("UpperTorso")
        local targetHumanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
        local localTorso = Character:FindFirstChild("UpperTorso")
        local localHumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

        if targetTorso and targetHumanoidRootPart and localTorso and localHumanoidRootPart then
            local HumanoidRootPart = localHumanoidRootPart
            local TargetHumanoidRootPart = targetHumanoidRootPart
            local Attachment0 = Instance.new("Attachment", HumanoidRootPart)
            local Attachment1 = Instance.new("Attachment", TargetHumanoidRootPart)
            local RopeConstraint = Instance.new("RopeConstraint", HumanoidRootPart)

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
            RopeConstraint.Thickness = .5
            RopeConstraint.Thickness0 = .5
            RopeConstraint.Thickness1 = .5

            wait(0.2)
            HumanoidRootPart.Velocity = Vector3.new(250, 150, 250)
            wait(1)
            RopeConstraint:Destroy()
            Attachment0:Destroy()
            Attachment1:Destroy()

            Rayfield:Notify({Title = "Fling", Content = "Oyuncu başarıyla fling atıldı."})
        else
            Rayfield:Notify({Title = "Hata", Content = "Hedef karakter parçaları bulunamadı!"})
        end
    else
        Rayfield:Notify({Title = "Hata", Content = "Hedef oyuncu bulunamadı!"})
    end
end

-- [[ TÜKET İLE UÇMA ]] --
Commands.jetpack = function()
    if _G.Jetpack then
        _G.Jetpack:Stop()
        _G.Jetpack = false
    else
        _G.Jetpack = true
        local function onJumpRequest()
            if _G.Jetpack and Character and Character:FindFirstChild("HumanoidRootPart") then
                Character.HumanoidRootPart.Velocity = Vector3.new(0, 100, 0)
            end
        end

        UserInputService.JumpRequest:Connect(onJumpRequest)
    end
    Rayfield:Notify({Title = "Jetpack", Content = _G.Jetpack and "İşlem Başlatıldı" or "İşlem Durduruldu"})
end

Commands.unjetpack = function()
    _G.Jetpack = false
    Rayfield:Notify({Title = "Jetpack", Content = "İşlem Durduruldu"})
end

-- Rayfield UI Oluşturduk
local CommandBar = Tab:CreateInput({
    Name = "Command Bar (Örn: tp player)",
    PlaceholderText = "Komutlarınızı buraya yazın...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        ExecuteCommand(text)
    end,
})
