--[[
    DELTA LOCAL ADMIN PANEL - Düzeltilmiş Versiyon
    Butonla aç/kapa • Sürüklenebilir • Mobile Destekli
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")

-- RENKLER
local Colors = {
    Bg = Color3.fromRGB(18, 18, 28),
    BgLight = Color3.fromRGB(28, 28, 42),
    BgTab = Color3.fromRGB(38, 38, 58),
    Accent = Color3.fromRGB(88, 86, 255),
    AccentH = Color3.fromRGB(108, 106, 275),
    Text = Color3.fromRGB(220, 220, 240),
    TextD = Color3.fromRGB(130, 130, 155),
    Green = Color3.fromRGB(65, 195, 95),
    Red = Color3.fromRGB(195, 65, 65),
}

-- YARDIMCI FONKSİYONLAR
local function Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function Stroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Accent
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function Padding(parent, top, bottom, left, right)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, top or 8)
    pad.PaddingBottom = UDim.new(0, bottom or 8)
    pad.PaddingLeft = UDim.new(0, left or 8)
    pad.PaddingRight = UDim.new(0, right or 8)
    pad.Parent = parent
    return pad
end

local function CreateLabel(parent, text, x, y, w, h, size)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, w, 0, h)
    label.Position = UDim2.new(0, x, 0, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Text
    label.TextSize = size or 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function CreateButton(parent, name, text, x, y, w, h, callback, bgColor)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, w, 0, h)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = bgColor or Colors.Accent
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Corner(btn, 6)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.AccentH}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = bgColor or Colors.Accent}):Play()
    end)
    
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    
    return btn
end

local function CreateInput(parent, placeholder, x, y, w, h)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, w, 0, h)
    frame.Position = UDim2.new(0, x, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Corner(frame, 6)
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -8, 1, 0)
    input.Position = UDim2.new(0, 4, 0, 0)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.PlaceholderText = placeholder
    input.PlaceholderColor3 = Color3.fromRGB(90, 90, 115)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 11
    input.Font = Enum.Font.Gotham
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.Parent = frame
    
    return input
end

local function CreateSlider(parent, text, x, y, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 38)
    frame.Position = UDim2.new(0, x, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(1, 0, 0, 14)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = text .. ": " .. default
    valLabel.TextColor3 = Colors.Text
    valLabel.TextSize = 10
    valLabel.Font = Enum.Font.Gotham
    valLabel.TextXAlignment = Enum.TextXAlignment.Left
    valLabel.Parent = frame
    
    local back = Instance.new("Frame")
    back.Size = UDim2.new(1, 0, 0, 6)
    back.Position = UDim2.new(0, 0, 0, 18)
    back.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    back.BorderSizePixel = 0
    back.Parent = frame
    Corner(back, 3)
    
    local fill = Instance.new("Frame")
    local ratio = (default - min) / (max - min)
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = back
    Corner(fill, 3)
    
    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 14, 0, 14)
    handle.Position = UDim2.new(ratio, -7, 0.5, -7)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.Text = ""
    handle.BorderSizePixel = 0
    handle.Parent = frame
    Corner(handle, 7)
    
    local dragging = false
    
    handle.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((input.Position.X - back.AbsolutePosition.X) / back.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            handle.Position = UDim2.new(rel, -7, 0.5, -7)
            local value = math.floor(min + (max - min) * rel)
            valLabel.Text = text .. ": " .. value
            if callback then
                callback(value)
            end
        end
    end)
    
    return frame
end

-- DRAG FONKSİYONU
local function MakeDraggable(dragFrame, targetFrame)
    local dragging = false
    local startPos, startInput
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = targetFrame.Position
            startInput = input.Position
        end
    end)
    
    dragFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            local delta = input.Position - startInput
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- NOTİFİKASYON FONKSİYONU
local function ShowNotification(title, message, duration)
    duration = duration or 3
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 260, 0, 55)
    notif.Position = UDim2.new(1, 280, 0.5, 0)
    notif.BackgroundColor3 = Colors.Bg
    notif.BorderSizePixel = 0
    notif.ZIndex = 99999
    notif.Parent = PlayerGui
    Corner(notif, 10)
    Stroke(notif, Colors.Accent, 1)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 8, 0.5, -15)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "✓"
    iconLabel.TextColor3 = Colors.Green
    iconLabel.TextSize = 18
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notif
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 195, 0, 20)
    titleLabel.Position = UDim2.new(0, 45, 0, 7)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(0, 195, 0, 18)
    msgLabel.Position = UDim2.new(0, 45, 0, 27)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Colors.TextD
    msgLabel.TextSize = 11
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = notif
    
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -140, 0.5, 0)
    }):Play()
    
    task.delay(duration, function()
        local tween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = UDim2.new(1, 280, 0.5, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════
-- AÇMA BUTONU
-- ═══════════════════════════════════════════════════════════
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "AdminToggleButton"
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -27)
ToggleButton.BackgroundColor3 = Colors.Accent
ToggleButton.Text = "⚡"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 26
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = false
ToggleButton.ZIndex = 99998
ToggleButton.Parent = PlayerGui
Corner(ToggleButton, 27)

ToggleButton.MouseEnter:Connect(function()
    TweenService:Create(ToggleButton, TweenInfo.new(0.15), {BackgroundColor3 = Colors.AccentH}):Play()
end)
ToggleButton.MouseLeave:Connect(function()
    TweenService:Create(ToggleButton, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Accent}):Play()
end)

-- ═══════════════════════════════════════════════════════════
-- PANEL DEĞİŞKENLERİ
-- ═══════════════════════════════════════════════════════════
local MainGui = nil
local IsPanelOpen = false

local FlyActive = false
local FlyConnection = nil
local FlyBodyVelocity = nil
local FlyBodyGyro = nil

local NoclipActive = false
local NoclipConnection = nil

local ESPActive = false

-- ═══════════════════════════════════════════════════════════
-- PANELİ KAPAT
-- ═══════════════════════════════════════════════════════════
local function ClosePanel()
    if MainGui then
        MainGui:Destroy()
        MainGui = nil
        IsPanelOpen = false
    end
end

-- ═══════════════════════════════════════════════════════════
-- PANELİ AÇ
-- ═══════════════════════════════════════════════════════════
local function OpenPanel()
    ClosePanel()
    IsPanelOpen = true
    
    -- Ana GUI
    MainGui = Instance.new("ScreenGui")
    MainGui.Name = "DeltaAdminPanel"
    MainGui.ResetOnSpawn = false
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.Parent = PlayerGui
    
    -- Ana Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 520, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
    MainFrame.BackgroundColor3 = Colors.Bg
    MainFrame.BorderSizePixel = 0
    MainGui.Parent = MainGui
    Corner(MainFrame, 12)
    Stroke(MainFrame, Colors.Accent, 2)
    MainFrame.Parent = MainGui
    
    -- Header
    local HeaderFrame = Instance.new("Frame")
    HeaderFrame.Name = "Header"
    HeaderFrame.Size = UDim2.new(1, 0, 0, 42)
    HeaderFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 45)
    HeaderFrame.BorderSizePixel = 0
    HeaderFrame.Parent = MainFrame
    Corner(HeaderFrame, 12)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "⚡ DELTA ADMIN"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = HeaderFrame
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 32, 0, 32)
    CloseButton.Position = UDim2.new(1, -37, 0.5, -16)
    CloseButton.BackgroundColor3 = Colors.Red
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 15
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = HeaderFrame
    Corner(CloseButton, 8)
    
    CloseButton.MouseButton1Click:Connect(ClosePanel)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "Tabs"
    TabContainer.Size = UDim2.new(0, 115, 1, -50)
    TabContainer.Position = UDim2.new(0, 6, 0, 48)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "Content"
    ContentArea.Size = UDim2.new(1, -130, 1, -56)
    ContentArea.Position = UDim2.new(0, 122, 0, 50)
    ContentArea.BackgroundColor3 = Colors.BgLight
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = MainFrame
    Corner(ContentArea, 8)
    
    -- Sayfalar
    local Pages = {}
    
    local function CreatePage()
        local page = Instance.new("ScrollingFrame")
        page.Name = "Page" .. #Pages + 1
        page.Size = UDim2.new(1, -8, 1, -8)
        page.Position = UDim2.new(0, 4, 0, 4)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = Colors.Accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = false
        page.Parent = ContentArea
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 6)
        pageLayout.Parent = page
        
        page:GetPropertyChangedSignal("CanvasSize"):Connect(function()
            pageLayout:Layout()
        end)
        
        table.insert(Pages, page)
        return page
    end
    
    local function SelectPage(index)
        for i, page in pairs(Pages) do
            page.Visible = (i == index)
        end
    end
    
    local function CreateTab(name, icon, index)
        local tab = Instance.new("TextButton")
        tab.Name = name
        tab.Size = UDim2.new(1, 0, 0, 36)
        tab.BackgroundColor3 = Colors.BgTab
        tab.Text = icon .. " " .. name
        tab.TextColor3 = Colors.Text
        tab.TextSize = 12
        tab.Font = Enum.Font.GothamBold
        tab.AutoButtonColor = false
        tab.Parent = TabContainer
        Corner(tab, 8)
        
        tab.MouseButton1Click:Connect(function()
            SelectPage(index)
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Colors.BgTab
                end
            end
            tab.BackgroundColor3 = Colors.Accent
        end)
        
        return tab
    end
    
    -- ═══════════════════════════════════════════════════════════
    -- SEKME 1: LOKAL ARAÇLAR
    -- ═══════════════════════════════════════════════════════════
    local Page1 = CreatePage()
    Padding(Page1, 10, 10, 10, 10)
    
    CreateLabel(Page1, "🎒 LOKAL ARAÇLAR", 0, 0, 180, 22, 15)
    
    -- FLY
    CreateButton(Page1, "Fly", "🚀 FLY", 0, 30, 100, 32, function()
        if FlyActive then
            FlyActive = false
            if FlyConnection then
                FlyConnection:Disconnect()
                FlyConnection = nil
            end
            if FlyBodyVelocity then
                FlyBodyVelocity:Destroy()
                FlyBodyVelocity = nil
            end
            if FlyBodyGyro then
                FlyBodyGyro:Destroy()
                FlyBodyGyro = nil
            end
            if Player.Character then
                local hum = Player.Character:FindFirstChild("Humanoid")
                if hum then
                    hum.PlatformStand = false
                end
            end
            ShowNotification("Fly", "Kapatıldı!", 2)
        else
            if not Player.Character then return end
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            local hum = Player.Character:FindFirstChild("Humanoid")
            if not hrp or not hum then return end
            
            FlyActive = true
            
            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            FlyBodyVelocity.Parent = hrp
            
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            FlyBodyGyro.P = 9e4
            FlyBodyGyro.Parent = hrp
            
            hum.PlatformStand = true
            
            FlyConnection = RunService.RenderStepped:Connect(function()
                if FlyActive and FlyBodyVelocity and FlyBodyVelocity.Parent then
                    FlyBodyVelocity.Velocity = Workspace.CurrentCamera.CFrame.LookVector * 50
                else
                    if FlyConnection then
                        FlyConnection:Disconnect()
                    end
                end
            end)
            
            ShowNotification("Fly", "Aktif! WASD ile uç!", 3)
        end
    end)
    
    -- NOCLIP
    CreateButton(Page1, "Noclip", "👻 NOCLIP", 110, 30, 100, 32, function()
        if NoclipActive then
            NoclipActive = false
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
            ShowNotification("Noclip", "Kapatıldı!", 2)
        else
            NoclipActive = true
            NoclipConnection = RunService.Stepped:Connect(function()
                if NoclipActive and Player.Character then
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            ShowNotification("Noclip", "Aktif! Duvarlardan geç!", 3)
        end
    end)
    
    -- SPEED
    CreateButton(Page1, "Speed", "⚡ HIZ", 0, 72, 100, 32, function()
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            if humanoid.WalkSpeed == 100 then
                humanoid.WalkSpeed = 16
                ShowNotification("Hız", "Normal hız: 16", 2)
            else
                humanoid.WalkSpeed = 100
                ShowNotification("Hız", "Hızlı hız: 100", 2)
            end
        end
    end)
    
    -- JUMP
    CreateButton(Page1, "Jump", "🦘 ZIPLA", 110, 72, 100, 32, function()
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            if humanoid.JumpPower == 150 then
                humanoid.JumpPower = 50
                ShowNotification("Zıplama", "Düşük zıplama: 50", 2)
            else
                humanoid.JumpPower = 150
                ShowNotification("Zıplama", "Yüksek zıplama: 150", 2)
            end
        end
    end)
    
    -- HEAL
    CreateButton(Page1, "Heal", "💚 CAN", 0, 114, 100, 32, function()
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
            ShowNotification("Can", "Can yenilendi!", 2)
        end
    end)
    
    -- GOD MODE
    CreateButton(Page1, "GodMode", "⭐ GOD MODE", 110, 114, 100, 32, function()
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 100
            humanoid.JumpPower = 150
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
            ShowNotification("God Mode", "Ölümsüz!", 3)
        end
    end)
    
    -- ESP
    CreateButton(Page1, "ESP", "👁️ ESP", 0, 156, 100, 32, function()
        ESPActive = not ESPActive
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                local highlight = player.Character:FindFirstChild("DeltaESP")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        
        if ESPActive then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "DeltaESP"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                end
            end
            ShowNotification("ESP", "Tüm oyuncular görünür!", 3)
        else
            ShowNotification("ESP", "Kapatıldı!", 2)
        end
    end)
    
    -- TP TOOL
    CreateButton(Page1, "TpTool", "📍 TP TOOL", 110, 156, 100, 32, function()
        local tool = Instance.new("Tool")
        tool.Name = "Teleport"
        tool.RequiresHandle = true
        
        local handle = Instance.new("Part")
        handle.Size = Vector3.new(1, 0.5, 1)
        handle.BrickColor = BrickColor.new("Bright violet")
        handle.Material = Enum.Material.Neon
        handle.Parent = tool
        
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = 1000
        clickDetector.Parent = handle
        
        clickDetector.MouseClick:Connect(function(playerWhoClicked)
            if playerWhoClicked == Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = handle.CFrame * CFrame.new(0, 3, 0)
            end
        end)
        
        tool.Parent = Player.Backpack
        ShowNotification("Verildi", "Teleport çubuğu alındı!", 3)
    end)
    
    -- ═══════════════════════════════════════════════════════════
    -- SEKME 2: IŞIK KONTROL
    -- ═══════════════════════════════════════════════════════════
    local Page2 = CreatePage()
    Padding(Page2, 10, 10, 10, 10)
    
    CreateLabel(Page2, "☀️ IŞIK KONTROL", 0, 0, 180, 22, 15)
    
    CreateSlider(Page2, "Gün Saati", 0, 30, 0, 24, 14, function(value)
        Lighting.ClockTime = value
    end)
    
    CreateSlider(Page2, "Parlaklık", 0, 76, 0, 10, 2, function(value)
        Lighting.Brightness = value
    end)
    
    CreateSlider(Page2, "Ambient", 0, 122, 0, 10, 5, function(value)
        Lighting.Ambient = Color3.fromRGB(value * 25, value * 25, value * 25)
    end)
    
    CreateLabel(Page2, "🌦️ HAVA DURUMU", 0, 176, 120, 18, 12)
    
    CreateButton(Page2, "Sunny", "☀️", 0, 200, 50, 26, function()
        pcall(function()
            local atmo = Instance.new("Atmosphere")
            atmo.Color = Color3.fromRGB(135, 206, 250)
            atmo.Decay = Color3.fromRGB(200, 220, 240)
            atmo.Dense = 0
            atmo.Offset = 0
            atmo.Scale = 0.5
        end)
        ShowNotification("Hava", "Güneşli!", 2)
    end)
    
    CreateButton(Page2, "Rainy", "🌧️", 55, 200, 50, 26, function()
        pcall(function()
            local atmo = Instance.new("Atmosphere")
            atmo.Color = Color3.fromRGB(100, 100, 120)
            atmo.Decay = Color3.fromRGB(80, 80, 100)
            atmo.Dense = 0.8
            atmo.Offset = 0.1
            atmo.Scale = 1
        end)
        ShowNotification("Hava", "Yağmurlu!", 2)
    end)
    
    CreateButton(Page2, "Foggy", "🌫️", 110, 200, 50, 26, function()
        pcall(function()
            local atmo = Instance.new("Atmosphere")
            atmo.Color = Color3.fromRGB(180, 180, 180)
            atmo.Decay = Color3.fromRGB(160, 160, 160)
            atmo.Dense = 0.6
            atmo.Offset = 0.3
            atmo.Scale = 0.8
        end)
        ShowNotification("Hava", "Sisli!", 2)
    end)
    
    CreateButton(Page2, "Shadows", "🌑 GÖLGELER", 0, 236, 160, 30, function()
        Lighting.GlobalShadows = not Lighting.GlobalShadows
        if Lighting.GlobalShadows then
            ShowNotification("Gölgeler", "Açık!", 2)
        else
            ShowNotification("Gölgeler", "Kapalı!", 2)
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════
    -- SEKME 3: İTEMLER
    -- ═══════════════════════════════════════════════════════════
    local Page3 = CreatePage()
    Padding(Page3, 10, 10, 10, 10)
    
    CreateLabel(Page3, "🎁 İTEMLER", 0, 0, 160, 22, 15)
    
    CreateButton(Page3, "Gun", "🔫 SİLAH", 0, 30, 100, 32, function()
        local tool = Instance.new("Tool")
        tool.Name = "Admin Gun"
        tool.RequiresHandle = true
        local handle = Instance.new("Part")
        handle.Size = Vector3.new(1, 0.5, 3)
        handle.BrickColor = BrickColor.new("Really black")
        handle.Material = Enum.Material.Metal
        handle.Parent = tool
        tool.Parent = Player.Backpack
        ShowNotification("Verildi", "Silah alındı!", 2)
    end)
    
    CreateButton(Page3, "Sword", "⚔️ KILIÇ", 110, 30, 100, 32, function()
        local tool = Instance.new("Tool")
        tool.Name = "Admin Sword"
        tool.RequiresHandle = true
        local handle = Instance.new("Part")
        handle.Size = Vector3.new(0.5, 4, 0.5)
        handle.BrickColor = BrickColor.new("Bright red")
        handle.Material = Enum.Material.Metal
        handle.Parent = tool
        tool.Parent = Player.Backpack
        ShowNotification("Verildi", "Kılıç alındı!", 2)
    end)
    
    CreateButton(Page3, "Tool", "🔧 ARAÇ", 0, 72, 100, 32, function()
        local tool = Instance.new("Tool")
        tool.Name = "Building Tool"
        tool.RequiresHandle = true
        local handle = Instance.new("Part")
        handle.Size = Vector3.new(1, 1, 1)
        handle.BrickColor = BrickColor.new("Bright orange")
        handle.Material = Enum.Material.Wood
        handle.Parent = tool
        tool.Parent = Player.Backpack
        ShowNotification("Verildi", "Araç alındı!", 2)
    end)
    
    CreateButton(Page3, "AllTools", "📦 HEPSİ", 110, 72, 100, 32, function()
        local items = {
            {Name = "Admin Gun", Color = BrickColor.new("Really black")},
            {Name = "Admin Sword", Color = BrickColor.new("Bright red")},
            {Name = "Admin Tool", Color = BrickColor.new("Bright orange")}
        }
        for _, item in ipairs(items) do
            local tool = Instance.new("Tool")
            tool.Name = item.Name
            tool.RequiresHandle = true
            local handle = Instance.new("Part")
            handle.BrickColor = item.Color
            handle.Parent = tool
            tool.Parent = Player.Backpack
        end
        ShowNotification("Verildi", "Tüm araçlar alındı!", 2)
    end)
    
    CreateButton(Page3, "Trail", "✨ IŞIK İZİ", 0, 114, 210, 32, function()
        if Player.Character then
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Temizle
                for _, child in pairs(hrp:GetChildren()) do
                    if child:IsA("Trail") then
                        child:Destroy()
                    end
                end
                
                local trail = Instance.new("Trail")
                local a1 = Instance.new("Attachment")
                a1.Position = Vector3.new(0, -0.5, 0)
                a1.Parent = hrp
                local a2 = Instance.new("Attachment")
                a2.Position = Vector3.new(0, -1, 0)
                a2.Parent = hrp
                trail.Attachment0 = a1
                trail.Attachment1 = a2
                trail.Color = ColorSequence.new(Color3.fromRGB(255, 100, 255))
                trail.Lifetime = 0.5
                trail.Parent = hrp
                
                ShowNotification("Trail", "Işık izi eklendi!", 2)
            end
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════
    -- SEKME 4: TELEPORT
    -- ═══════════════════════════════════════════════════════════
    local Page4 = CreatePage()
    Padding(Page4, 10, 10, 10, 10)
    
    CreateLabel(Page4, "📍 TELEPORT", 0, 0, 160, 22, 15)
    
    local PlayerInput = CreateInput(Page4, "Oyuncu adı...", 0, 30, 200, 30)
    
    CreateButton(Page4, "ToPlayer", "👉 Oyuncuya TP", 0, 70, 100, 30, function()
        local target = Players:FindFirstChild(PlayerInput.Text)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                ShowNotification("TP", target.Name .. " yanına gidildi!", 2)
            end
        else
            ShowNotification("Hata", "Oyuncu bulunamadı!", 2)
        end
    end)
    
    CreateButton(Page4, "BringPlayer", "🌀 Getir", 105, 70, 100, 30, function()
        local target = Players:FindFirstChild(PlayerInput.Text)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                target.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                ShowNotification("Bring", target.Name .. " getirildi!", 2)
            end
        else
            ShowNotification("Hata", "Oyuncu bulunamadı!", 2)
        end
    end)
    
    CreateButton(Page4, "To0", "🏠 0,0,0", 0, 110, 100, 30, function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            ShowNotification("TP", "0,0,0'e gidildi!", 2)
        end
    end)
    
    CreateButton(Page4, "Spawn", "🔄 RESPAWN", 105, 110, 100, 30, function()
        if Player.Character then
            Player.Character:BreakJoints()
        end
        ShowNotification("Respawn", "Respawn!", 2)
    end)
    
    CreateButton(Page4, "Freeze", "❄️ DONDUR", 0, 150, 100, 30, function()
        local target = Players:FindFirstChild(PlayerInput.Text)
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local freeze = hrp:FindFirstChild("DeltaFreeze")
                if freeze then
                    freeze:Destroy()
                    ShowNotification("Çöz", "Serbest bırakıldı!", 2)
                else
                    local bp = Instance.new("BodyPosition")
                    bp.Name = "DeltaFreeze"
                    bp.Position = hrp.Position
                    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bp.Parent = hrp
                    ShowNotification("Don", "Donduruldu!", 2)
                end
            end
        else
            ShowNotification("Hata", "Oyuncu bulunamadı!", 2)
        end
    end)
    
    CreateButton(Page4, "Kick", "🔨 KICK", 105, 150, 100, 30, function()
        local target = Players:FindFirstChild(PlayerInput.Text)
        if target then
            target:Kick("Admin tarafından atıldın!")
            ShowNotification("Kick", target.Name .. " atıldı!", 2)
        else
            ShowNotification("Hata", "Oyuncu bulunamadı!", 2)
        end
    end, Colors.Red)
    
    CreateLabel(Page4, "👥 Çevrimiçi: " .. #Players:GetPlayers(), 0, 192, 200, 18, 11)
    
    -- ═══════════════════════════════════════════════════════════
    -- SEKME 5: DİĞER
    -- ═══════════════════════════════════════════════════════════
    local Page5 = CreatePage()
    Padding(Page5, 10, 10, 10, 10)
    
    CreateLabel(Page5, "⚙️ DİĞER", 0, 0, 160, 22, 15)
    
    CreateButton(Page5, "Rejoin", "🔄 REJOIN", 0, 30, 100, 30, function()
        ShowNotification("Rejoin", "Yeniden bağlanılıyor...", 3)
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end)
    
    CreateButton(Page5, "CopyJob", "📋 JOB ID", 105, 30, 100, 30, function()
        if setclipboard then
            setclipboard(game.JobId)
        elseif clipboard and clipboard.set then
            clipboard.set(game.JobId)
        end
        ShowNotification("Kopyalandı", "Job ID kopyalandı!", 2)
    end)
    
    CreateButton(Page5, "CopyServer", "🖥️ SERVER ID", 0, 70, 205, 30, function()
        if setclipboard then
            setclipboard(tostring(game.PlaceId))
        end
        ShowNotification("Kopyalandı", "Server ID kopyalandı!", 2)
    end)
    
    CreateButton(Page5, "ClearTools", "🗑️ TEMİZLE", 0, 110, 100, 30, function()
        if Player.Backpack then
            for _, tool in pairs(Player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    tool:Destroy()
                end
            end
        end
        ShowNotification("Temizlendi", "Envanter temizlendi!", 2)
    end)
    
    CreateButton(Page5, "Replicate", "🌐 REPLİKATE", 105, 110, 100, 30, function()
        local replicates = Instance.new("Frame")
        replicates.Size = UDim2.new(0.5, 0, 0.3, 0)
        replicates.Position = UDim2.new(0.25, 0, 0.35, 0)
        replicates.BackgroundColor3 = Colors.Bg
        replicates.BorderSizePixel = 0
        replicates.Parent = MainGui
        Corner(replicates, 12)
        Stroke(replicates, Colors.Accent, 2)
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, -20, 1, -20)
        infoLabel.Position = UDim2.new(0, 10, 0, 10)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "Place ID: " .. game.PlaceId .. "\nJob ID: " .. string.sub(game.JobId, 1, 20) .. "..."
        infoLabel.TextColor3 = Colors.Text
        infoLabel.TextSize = 14
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextWrapped = true
        infoLabel.Parent = replicates
        
        task.delay(5, function()
            replicates:Destroy()
        end)
    end)
    
    -- ═══════════════════════════════════════════════════════════
    -- TAB BUTONLARI
    -- ═══════════════════════════════════════════════════════════
    local Tab1 = CreateTab("Lokal", "🎒", 1)
    local Tab2 = CreateTab("Işık", "☀️", 2)
    local Tab3 = CreateTab("İtem", "🎁", 3)
    local Tab4 = CreateTab("TP", "📍", 4)
    local Tab5 = CreateTab("Diğer", "⚙️", 5)
    
    -- İlk sekmeyi seç
    SelectPage(1)
    Tab1.BackgroundColor3 = Colors.Accent
    
    -- Sürüklenebilir yap
    MakeDraggable(HeaderFrame, MainFrame)
    
    -- Açılış animasyonu
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 520, 0, 400)
    }):Play()
end

-- ═══════════════════════════════════════════════════════════
-- AÇMA BUTONU FONKSİYONU
-- ═══════════════════════════════════════════════════════════
ToggleButton.MouseButton1Click:Connect(function()
    if IsPanelOpen then
        ClosePanel()
    else
        OpenPanel()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- BAŞLANGIÇ
-- ═══════════════════════════════════════════════════════════
task.wait(1)

-- Panel'i aç
OpenPanel()
ShowNotification("Admin Panel", "Açıldı! ⚡", 4)

print("✅ Delta Admin Panel başarıyla yüklendi!")
print("📌 Sağ üstteki ⚡ butonuna tıkla")
