-- BACKUP ATTACH SCRIPT (1 minute 30 second Magic Council condition)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local TARGET_PLACE_ID = 15798401969
local TRIGGER_DELAY = 90 -- 1 minute 30 seconds

if game.PlaceId ~= TARGET_PLACE_ID then
    warn("[Backup] Not in Magic Council. Exiting.")
    return
end

print("[Backup] Waiting 1 minute 30 seconds before activating...")
task.wait(TRIGGER_DELAY)
print("[Backup] 1m30s elapsed. Activating backup attach script.")

local LocalPlayer = Players.LocalPlayer

local attachEnabled = true
local tweenSpeed = 250
local offsetUp = 0
local offsetForward = -6
local offsetRight = 0
local attachLoop = nil
local clickLoop = nil

-- Track whether Roblox window is focused
local windowFocused = true

UserInputService.WindowFocused:Connect(function()
    windowFocused = true
    print("[ClickSpam] Window focused — clicks resumed")
end)

UserInputService.WindowFocusReleased:Connect(function()
    windowFocused = false
    print("[ClickSpam] Window unfocused — clicks paused")
end)

-- ========================
-- GUI
-- ========================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BackupAttachGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 340)
main.Position = UDim2.new(0, 20, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "📎 Attach"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -16, 1, -42)
content.Position = UDim2.new(0, 8, 0, 38)
content.BackgroundTransparency = 1
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.Parent = content

local function makeLabel(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(160, 160, 180)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = content
    return lbl
end

local function makeToggleRow(labelText, defaultOn, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBg.BackgroundColor3 = defaultOn and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(80, 80, 90)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(1, 0)
    tbCorner.Parent = toggleBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = defaultOn
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggleBg

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggleBg, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(80, 80, 90)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        callback(state)
    end)
end

local function makeSlider(labelText, minVal, maxVal, defaultVal, order, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 46)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    container.Parent = content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(160, 160, 180)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.4, 0, 0, 16)
    valLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = string.format("%.1f studs/%.0f studs", defaultVal, maxVal)
    valLabel.TextColor3 = Color3.fromRGB(88, 101, 242)
    valLabel.TextSize = 10
    valLabel.Font = Enum.Font.Gotham
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = container

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 22)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    track.BorderSizePixel = 0
    track.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local range = maxVal - minVal
    local startFill = (defaultVal - minVal) / range

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(startFill, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 0, 20)
    hitbox.Position = UDim2.new(0, 0, 0, 15)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = container

    local dragging = false

    local function update(input)
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local relX = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
        local value = minVal + relX * range
        fill.Size = UDim2.new(relX, 0, 1, 0)
        valLabel.Text = string.format("%.1f studs/%.0f studs", value, maxVal)
        callback(value)
    end

    hitbox.MouseButton1Down:Connect(function(x, y)
        dragging = true
        update({Position = Vector2.new(x, y)})
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function makeButton(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.LayoutOrder = order
    btn.Parent = content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

-- ========================
-- BUILD UI
-- ========================
makeToggleRow("Enable Attach", true, 1, function(state)
    attachEnabled = state
    if not state then
        if attachLoop then attachLoop:Disconnect() end
        if clickLoop then clickLoop:Disconnect() end
        print("[Attach] Disabled")
    else
        print("[Attach] Enabled")
        startAttach()
        startClickSpam()
    end
end)

makeLabel("Approach Mode: Tween", 2)
makeLabel("Retarget Condition: Removed", 3)

makeSlider("Tween Speed", 50, 1200, tweenSpeed, 4, function(val)
    tweenSpeed = val
end)

makeSlider("Up / Down", -10, 10, 0, 5, function(val)
    offsetUp = val
end)

makeSlider("Forward / Back", -10, 10, -6, 6, function(val)
    offsetForward = val
end)

makeSlider("Right / Left", -10, 10, 0, 7, function(val)
    offsetRight = val
end)

makeButton("Reset Offsets To Default", 8, function()
    offsetUp = 0
    offsetForward = -6
    offsetRight = 0
    print("[Attach] Offsets reset to default")
end)

-- ========================
-- CORE LOGIC
-- ========================
local function getEntityRoot()
    local success, result = pcall(function()
        return workspace.Live["Mash Burnedead"].HumanoidRootPart
    end)
    if success and result then return result end
    local success2, result2 = pcall(function()
        return workspace.Live["Mash Burnedead"].PrimaryPart
    end)
    if success2 and result2 then return result2 end
    return nil
end

local function getPlayerRoot()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

function startAttach()
    if attachLoop then attachLoop:Disconnect() end
    attachLoop = RunService.Heartbeat:Connect(function()
        if not attachEnabled then return end
        local entityRoot = getEntityRoot()
        local playerRoot = getPlayerRoot()
        if not entityRoot or not playerRoot then return end

        local targetCFrame = entityRoot.CFrame * CFrame.new(offsetRight, offsetUp, -offsetForward)
        local distance = (playerRoot.Position - targetCFrame.Position).Magnitude
        local tweenTime = math.clamp(distance / tweenSpeed, 0.01, 0.5)

        TweenService:Create(playerRoot, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {
            CFrame = targetCFrame
        }):Play()
    end)
    print("[Attach] Attach loop started, targeting Mash Burnedead")
end

function startClickSpam()
    if clickLoop then clickLoop:Disconnect() end

    if not (mouse1press and mouse1release and keypress and keyrelease) then
        warn("[ClickSpam] Required executor functions not available (mouse1press/mouse1release/keypress/keyrelease)")
        return
    end

    -- Press E to equip weapon before starting
    print("[ClickSpam] Pressing E to equip weapon...")
    keypress(0x45)
    task.wait(0.1)
    keyrelease(0x45)
    task.wait(0.3)

    local tickCount = 0

    clickLoop = RunService.Heartbeat:Connect(function()
        if not attachEnabled then return end
        if not windowFocused then return end

        -- Re-press E every ~3 seconds to maintain equip
        tickCount = tickCount + 1
        if tickCount >= 180 then
            tickCount = 0
            keypress(0x45)
            task.wait(0.05)
            keyrelease(0x45)
        end

        pcall(function()
            mouse1press()
            mouse1release()
        end)
    end)

    print("[ClickSpam] Click spam started — E re-pressed every 3 seconds, pauses when window unfocused")
end

startAttach()
startClickSpam()

print("[Backup] Script fully loaded. Trigger delay was 1m30s.")