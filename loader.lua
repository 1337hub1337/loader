--[[
    1337 Hub Loader — Auto-Detect Script Loader
    Execute → Detect Game → Show Scripts → Load
--]]

--=========================================================================
-- ANTI DOUBLE-EXECUTE
--=========================================================================
if _G._1337Loader_Running then
    if _G._1337Loader_Kill then _G._1337Loader_Kill() task.wait(0.3) end
end
_G._1337Loader_Running = true
local Running = true
local AllConns = {}

_G._1337Loader_Kill = function()
    Running = false
    _G._1337Loader_Running = nil
    _G._1337Loader_Kill = nil
    for _, c in ipairs(AllConns) do pcall(function() c:Disconnect() end) end
    pcall(function()
        local parent = (gethui and gethui()) or game:GetService("Players").LocalPlayer.PlayerGui
        local g = parent:FindFirstChild("1337Loader_UI")
        if g then g:Destroy() end
    end)
end

--=========================================================================
-- SERVICES
--=========================================================================
local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local IS_MOBILE   = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local GameName = "Unknown"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then GameName = info.Name end
end)

--=========================================================================
-- GAME DATABASE
-- [PlaceId] = { "Nama Game", "Script URL", "Script Key" }
--=========================================================================
local GAMES = {
    [128784467030899] = { "Merge a Nuke!", "https://api.jnkie.com/api/v1/luascripts/public/a110766c7bd5ed95482a4163317711d7655ae41eae3f7b1cac2cc040a5c15906/download", "KEYLESS" },

    -- Add more games:
    -- [PlaceId] = { "Nama Game", "URL Script", "Key" },
}

local CurrentGame = GAMES[game.PlaceId]
local IsSupported = (CurrentGame ~= nil)

--=========================================================================
-- THEME
--=========================================================================
local Theme = {
    Bg       = Color3.fromRGB(13, 10, 22),
    Card     = Color3.fromRGB(22, 16, 40),
    Accent   = Color3.fromRGB(139, 92, 246),
    Accent2  = Color3.fromRGB(167, 139, 250),
    Text     = Color3.fromRGB(240, 238, 255),
    TextDim  = Color3.fromRGB(150, 140, 190),
    Stroke   = Color3.fromRGB(45, 30, 80),
    Good     = Color3.fromRGB(80, 230, 180),
    Red      = Color3.fromRGB(235, 65, 75),
    Orange   = Color3.fromRGB(255, 155, 55),
    Yellow   = Color3.fromRGB(250, 210, 70),
    LogoBg   = Color3.fromRGB(18, 12, 35),
    Bar      = Color3.fromRGB(11, 8, 20),
}

--=========================================================================
-- HELPERS
--=========================================================================
local function corner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = inst
end

local function stroke(inst, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function tween(inst, time, props)
    local t = TweenService:Create(inst, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

--=========================================================================
-- SCREENGUI
--=========================================================================
pcall(function()
    local parent = (gethui and gethui()) or PlayerGui
    local old = parent:FindFirstChild("1337Loader_UI")
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "1337Loader_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
pcall(function() ScreenGui.Parent = (gethui and gethui()) or PlayerGui end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

--=========================================================================
-- NOTIFY
--=========================================================================
local function notify(msg, color)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, IS_MOBILE and 260 or 280, 0, 38)
    holder.AnchorPoint = Vector2.new(0.5, 1)
    holder.Position = UDim2.new(0.5, 0, 1, -20)
    holder.BackgroundColor3 = Theme.Card
    holder.BackgroundTransparency = 1
    holder.Parent = ScreenGui
    corner(holder, 8)
    local s = stroke(holder, color or Theme.Accent, 1, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = msg
    lbl.TextColor3 = Theme.Text
    lbl.TextTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    tween(holder, 0.3, {BackgroundTransparency = 0.08})
    tween(s, 0.3, {Transparency = 0.3})
    tween(lbl, 0.3, {TextTransparency = 0})

    task.delay(2.5, function()
        tween(holder, 0.3, {BackgroundTransparency = 1})
        tween(s, 0.3, {Transparency = 1})
        tween(lbl, 0.3, {TextTransparency = 1})
        task.wait(0.35)
        holder:Destroy()
    end)
end

--=========================================================================
-- WINDOW
--=========================================================================
local WIN_W = IS_MOBILE and 360 or 400
local WIN_H = IS_MOBILE and 240 or 260

local Window = Instance.new("CanvasGroup")
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.Position = UDim2.new(0.5, 0, 0.5, 0)
Window.Size = UDim2.new(0, WIN_W, 0, WIN_H)
Window.BackgroundColor3 = Theme.Bg
Window.BorderSizePixel = 0
Window.GroupTransparency = 1
Window.Visible = false
Window.Parent = ScreenGui
corner(Window, 14)
stroke(Window, Theme.Accent, 1.5, 0.45)

local WinScale = Instance.new("UIScale")
WinScale.Parent = Window
local function computeScale()
    local vp = game.Workspace.CurrentCamera.ViewportSize
    local s = math.min((vp.X * 0.94) / WIN_W, (vp.Y * 0.94) / WIN_H, IS_MOBILE and 1.15 or 1)
    return math.max(s, 0.45)
end
local baseScale = computeScale()
WinScale.Scale = baseScale

--=========================================================================
-- TOP BAR
--=========================================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Bar
TopBar.BorderSizePixel = 0
TopBar.Parent = Window
corner(TopBar, 14)
local topCover = Instance.new("Frame")
topCover.Size = UDim2.new(1, 0, 0, 14)
topCover.Position = UDim2.new(0, 0, 1, -14)
topCover.BackgroundColor3 = Theme.Bar
topCover.BorderSizePixel = 0
topCover.Parent = TopBar

-- Logo
local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 30, 0, 30)
logo.Position = UDim2.new(0, 8, 0.5, -15)
logo.BackgroundColor3 = Theme.LogoBg
logo.BorderSizePixel = 0
logo.Parent = TopBar
corner(logo, 8)
stroke(logo, Theme.Accent, 1.5, 0.2)
local logoTxt = Instance.new("TextLabel")
logoTxt.Size = UDim2.new(1, 0, 1, 0)
logoTxt.BackgroundTransparency = 1
logoTxt.Text = "1337"
logoTxt.TextColor3 = Theme.Accent
logoTxt.Font = Enum.Font.GothamBold
logoTxt.TextSize = 10
logoTxt.Parent = logo

-- Title
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -110, 1, 0)
titleLbl.Position = UDim2.new(0, 46, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "1337 Hub"
titleLbl.TextColor3 = Theme.Text
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 15
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = TopBar
local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Theme.Accent2),
})
titleGrad.Parent = titleLbl

-- Minimize
local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 28, 0, 28)
btnMin.Position = UDim2.new(1, -64, 0.5, -14)
btnMin.BackgroundColor3 = Color3.fromRGB(35, 25, 60)
btnMin.Text = "-"
btnMin.TextColor3 = Theme.Yellow
btnMin.Font = Enum.Font.GothamBlack
btnMin.TextSize = 18
btnMin.AutoButtonColor = false
btnMin.Parent = TopBar
corner(btnMin, 8)

-- Close
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 28, 0, 28)
btnClose.Position = UDim2.new(1, -32, 0.5, -14)
btnClose.BackgroundColor3 = Color3.fromRGB(35, 25, 60)
btnClose.Text = "X"
btnClose.TextColor3 = Theme.Red
btnClose.Font = Enum.Font.GothamBlack
btnClose.TextSize = 12
btnClose.AutoButtonColor = false
btnClose.Parent = TopBar
corner(btnClose, 8)

--=========================================================================
-- CONTENT
--=========================================================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -42)
Content.Position = UDim2.new(0, 0, 0, 42)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Window

local contentPad = Instance.new("UIPadding")
contentPad.PaddingLeft = UDim.new(0, 14)
contentPad.PaddingRight = UDim.new(0, 14)
contentPad.PaddingTop = UDim.new(0, 10)
contentPad.PaddingBottom = UDim.new(0, 10)
contentPad.Parent = Content

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = Content

--=========================================================================
-- GAME DETECTED → SHOW SCRIPT
--=========================================================================
if IsSupported then
    local gameName  = CurrentGame[1]
    local scriptURL = CurrentGame[2]
    local scriptKey = CurrentGame[3]

    -- Game detected
    local detected = Instance.new("TextLabel")
    detected.Size = UDim2.new(1, 0, 0, 16)
    detected.BackgroundTransparency = 1
    detected.Text = "Game detected"
    detected.TextColor3 = Theme.Good
    detected.Font = Enum.Font.GothamBold
    detected.TextSize = 11
    detected.TextXAlignment = Enum.TextXAlignment.Left
    detected.LayoutOrder = 1
    detected.Parent = Content

    -- Game name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 22)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = gameName
    nameLabel.TextColor3 = Theme.Text
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.TextSize = 18
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.LayoutOrder = 2
    nameLabel.Parent = Content

    -- Script row
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, IS_MOBILE and 44 or 40)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.LayoutOrder = 3
    card.Parent = Content
    corner(card, 8)
    stroke(card, Theme.Stroke, 1, 0.5)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 12, 0.5, -4)
    dot.BackgroundColor3 = Theme.Accent
    dot.BorderSizePixel = 0
    dot.Parent = card
    corner(dot, 4)

    local scriptLabel = Instance.new("TextLabel")
    scriptLabel.Size = UDim2.new(1, -100, 1, 0)
    scriptLabel.Position = UDim2.new(0, 28, 0, 0)
    scriptLabel.BackgroundTransparency = 1
    scriptLabel.Text = "1337Hub " .. gameName
    scriptLabel.TextColor3 = Theme.Text
    scriptLabel.Font = Enum.Font.GothamMedium
    scriptLabel.TextSize = 13
    scriptLabel.TextXAlignment = Enum.TextXAlignment.Left
    scriptLabel.Parent = card

    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0, IS_MOBILE and 70 or 66, 0, IS_MOBILE and 28 or 26)
    execBtn.Position = UDim2.new(1, -(IS_MOBILE and 78 or 74), 0.5, -(IS_MOBILE and 14 or 13))
    execBtn.BackgroundColor3 = Theme.Accent
    execBtn.Text = "Execute"
    execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    execBtn.Font = Enum.Font.GothamBold
    execBtn.TextSize = 11
    execBtn.AutoButtonColor = false
    execBtn.Parent = card
    corner(execBtn, 6)

    local executed = false
    execBtn.MouseButton1Click:Connect(function()
        if executed then return end
        executed = true
        execBtn.Text = "Loading..."
        tween(execBtn, 0.2, {BackgroundColor3 = Theme.Card})
        task.wait(0.5)

        pcall(function()
            if scriptKey then getgenv().SCRIPT_KEY = scriptKey end
            loadstring(game:HttpGet(scriptURL))()
        end)

        execBtn.Text = "Active \226\156\147"
        tween(execBtn, 0.25, {BackgroundColor3 = Theme.Good})
        tween(dot, 0.25, {BackgroundColor3 = Theme.Good})
        tween(scriptLabel, 0.25, {TextColor3 = Theme.Good})
        notify("Script loaded: " .. gameName, Theme.Good)
    end)

--=========================================================================
-- GAME NOT FOUND → SCRIPT TIDAK TERSEDIA
--=========================================================================
else
    local noTitle = Instance.new("TextLabel")
    noTitle.Size = UDim2.new(1, 0, 0, 22)
    noTitle.BackgroundTransparency = 1
    noTitle.Text = "Script not available"
    noTitle.TextColor3 = Theme.Orange
    noTitle.Font = Enum.Font.GothamBlack
    noTitle.TextSize = 16
    noTitle.TextXAlignment = Enum.TextXAlignment.Center
    noTitle.LayoutOrder = 1
    noTitle.Parent = Content

    local noSub = Instance.new("TextLabel")
    noSub.Size = UDim2.new(1, 0, 0, 36)
    noSub.BackgroundTransparency = 1
    noSub.Text = GameName .. " is not supported yet.\nJoin Discord to request scripts!"
    noSub.TextColor3 = Theme.TextDim
    noSub.Font = Enum.Font.GothamMedium
    noSub.TextSize = 12
    noSub.TextWrapped = true
    noSub.TextXAlignment = Enum.TextXAlignment.Center
    noSub.LayoutOrder = 2
    noSub.Parent = Content

    local dcBtn = Instance.new("TextButton")
    dcBtn.Size = UDim2.new(1, 0, 0, IS_MOBILE and 38 or 34)
    dcBtn.BackgroundColor3 = Theme.Accent
    dcBtn.Text = "Copy Discord"
    dcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dcBtn.Font = Enum.Font.GothamBold
    dcBtn.TextSize = 12
    dcBtn.AutoButtonColor = false
    dcBtn.LayoutOrder = 3
    dcBtn.Parent = Content
    corner(dcBtn, 8)

    dcBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/ctqcB4JvxB") end)
        dcBtn.Text = "Copied! \226\156\147"
        tween(dcBtn, 0.2, {BackgroundColor3 = Theme.Good})
        task.wait(1.5)
        dcBtn.Text = "Copy Discord"
        tween(dcBtn, 0.2, {BackgroundColor3 = Theme.Accent})
    end)
end

--=========================================================================
-- DRAG
--=========================================================================
do
    local dragging, dragStart, startPos = false, nil, nil
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, Window.Position
        end
    end)
    table.insert(AllConns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    table.insert(AllConns, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

--=========================================================================
-- FLOAT BUTTON
--=========================================================================
local FLOAT_SZ = IS_MOBILE and 48 or 42
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, FLOAT_SZ, 0, FLOAT_SZ)
FloatBtn.Position = UDim2.new(0, 14, 1, -(FLOAT_SZ + 14))
FloatBtn.BackgroundColor3 = Theme.LogoBg
FloatBtn.Text = "1337"
FloatBtn.TextColor3 = Theme.Accent
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 12
FloatBtn.AutoButtonColor = false
FloatBtn.Visible = false
FloatBtn.Parent = ScreenGui
corner(FloatBtn, 12)
stroke(FloatBtn, Theme.Accent, 1.5, 0.3)

--=========================================================================
-- OPEN / MINIMIZE / EXIT
--=========================================================================
local busy = false

local function openWindow()
    if busy then return end
    busy = true
    FloatBtn.Visible = false
    Window.Visible = true
    Window.GroupTransparency = 1
    WinScale.Scale = baseScale * 0.92
    tween(Window, 0.28, {GroupTransparency = 0})
    local t = tween(WinScale, 0.35, {Scale = baseScale})
    t.Completed:Once(function() busy = false end)
end

local function minimizeWindow()
    if busy then return end
    busy = true
    tween(Window, 0.2, {GroupTransparency = 1})
    local t = tween(WinScale, 0.2, {Scale = baseScale * 0.9})
    t.Completed:Once(function()
        Window.Visible = false
        FloatBtn.Visible = true
        busy = false
    end)
end

local function exitUI()
    if busy then return end
    busy = true
    Running = false
    _G._1337Loader_Running = nil
    tween(Window, 0.2, {GroupTransparency = 1})
    local t = tween(WinScale, 0.2, {Scale = baseScale * 0.88})
    t.Completed:Once(function() ScreenGui:Destroy() end)
end

btnMin.MouseButton1Click:Connect(minimizeWindow)
btnClose.MouseButton1Click:Connect(exitUI)
FloatBtn.MouseButton1Click:Connect(openWindow)

-- Keybind
table.insert(AllConns, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.F5 then
        if Window.Visible then minimizeWindow() else openWindow() end
    end
end))

--=========================================================================
-- INIT
--=========================================================================
openWindow()
task.delay(0.5, function()
    if IsSupported then
        notify("Game detected: " .. CurrentGame[1], Theme.Good)
    else
        notify("Script not available", Theme.Orange)
    end
end)
