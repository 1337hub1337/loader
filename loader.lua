--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║   1337 Hub Loader  —  Auto-Detect Script Loader             ║
    ║   Black + Neon Purple  •  Mobile Friendly  •  Anti-Lag      ║
    ║   Author: 1337Hub                                           ║
    ║                                                             ║
    ║   Flow: Execute → Detect Game → Show Scripts → Load         ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

--=========================================================================
-- ANTI DOUBLE-EXECUTE
--=========================================================================
if _G._1337Loader_Running then
    if _G._1337Loader_Kill then _G._1337Loader_Kill() task.wait(0.3) end
end
_G._1337Loader_Running = true
local Running = true
_G._1337Loader_Kill = function()
    Running = false
    _G._1337Loader_Running = nil
    _G._1337Loader_Kill = nil
    pcall(function()
        if _G._1337Loader_AllConns then
            for _, c in ipairs(_G._1337Loader_AllConns) do pcall(function() c:Disconnect() end) end
            _G._1337Loader_AllConns = nil
        end
    end)
    pcall(function()
        local g = (gethui and gethui() or game:GetService("Players").LocalPlayer.PlayerGui):FindFirstChild("1337Loader_UI")
        if g then g:Destroy() end
    end)
    pcall(function()
        local g = game:GetService("CoreGui"):FindFirstChild("1337Loader_UI")
        if g then g:Destroy() end
    end)
end

--=========================================================================
-- SERVICES
--=========================================================================
local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local Workspace          = game:GetService("Workspace")
local TweenService       = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService        = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local IS_MOBILE   = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local GameName = "Unknown"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then GameName = info.Name end
end)

local AllConns = {}
_G._1337Loader_AllConns = AllConns

--=========================================================================
-- SCRIPT DATABASE
-- Script disimpan di GitHub, loader fetch otomatis via BASE_URL
--=========================================================================
local BASE_URL = "https://raw.githubusercontent.com/1337hub1337/loader/refs/heads/main/"

-- Helper: bikin full URL dari path relatif
-- Contoh: scriptURL("indovoice/speed.lua") → BASE_URL .. "indovoice/speed.lua"
local function scriptURL(path)
    return BASE_URL .. path
end

--=========================================================================
-- SCRIPT DATABASE
-- Tambahin game di sini. Script URL otomatis ngarah ke repo GitHub lo.
-- Struktur folder di repo:
--   scripts/namagame/namascript.lua
--
-- [PlaceId] = {
--     name = "Nama Game",
--     status = "updated" / "testing" / "outdated",
--     scripts = {
--         { name = "Nama Script", path = "scripts/namagame/namascript.lua" },
--     },
-- },
--=========================================================================
local ScriptDB = {

    -- Contoh (hapus/ganti sesuai game lo):
    -- [123456789] = {
    --     name = "Indovoice",
    --     status = "updated",
    --     scripts = {
    --         { name = "Auto Farm",  path = "scripts/indovoice/autofarm.lua" },
    --         { name = "Teleport",   path = "scripts/indovoice/teleport.lua" },
    --         { name = "ESP",        path = "scripts/indovoice/esp.lua" },
    --     },
    -- },

}

--=========================================================================
-- DETECT CURRENT GAME
--=========================================================================
local CurrentGame = ScriptDB[game.PlaceId]
local IsSupported = (CurrentGame ~= nil)

--=========================================================================
-- THEME
--=========================================================================
local Theme = {
    Bg        = Color3.fromRGB(13, 10, 22),
    Sidebar   = Color3.fromRGB(9, 7, 18),
    Card      = Color3.fromRGB(22, 16, 40),
    CardHover = Color3.fromRGB(35, 25, 60),
    Accent    = Color3.fromRGB(139, 92, 246),
    Accent2   = Color3.fromRGB(167, 139, 250),
    Text      = Color3.fromRGB(240, 238, 255),
    TextDim   = Color3.fromRGB(150, 140, 190),
    TextHint  = Color3.fromRGB(90, 80, 130),
    Stroke    = Color3.fromRGB(45, 30, 80),
    Good      = Color3.fromRGB(80, 230, 180),
    Red       = Color3.fromRGB(235, 65, 75),
    Orange    = Color3.fromRGB(255, 155, 55),
    Yellow    = Color3.fromRGB(250, 210, 70),
    BottomBar = Color3.fromRGB(11, 8, 20),
    LogoBg    = Color3.fromRGB(18, 12, 35),
}

local BRAND = {
    Title   = "1337 Hub",
    Discord = "discord.gg/ctqcB4JvxB",
    Version = "v2.0.0",
}

--=========================================================================
-- UI HELPERS
--=========================================================================
local function corner(inst, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 10) c.Parent = inst return c end
local function stroke(inst, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end
local function pad(inst, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or l or 0)
    p.PaddingTop = UDim.new(0, t or l or 0)
    p.PaddingBottom = UDim.new(0, b or l or 0)
    p.Parent = inst
    return p
end
local function tween(inst, time, props, style, dir)
    local ti = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(inst, ti, props)
    t:Play()
    return t
end

--=========================================================================
-- SCREENGUI
--=========================================================================
if PlayerGui:FindFirstChild("1337Loader_UI") then PlayerGui["1337Loader_UI"]:Destroy() end
pcall(function()
    if gethui then
        for _, g in ipairs(gethui():GetChildren()) do
            if g:IsA("ScreenGui") and g.Name == "1337Loader_UI" then g:Destroy() end
        end
    end
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
-- TOAST NOTIFICATIONS
--=========================================================================
local ToastHolder = Instance.new("Frame")
ToastHolder.Size = IS_MOBILE and UDim2.new(0.7, 0, 1, 0) or UDim2.new(0, 280, 1, 0)
ToastHolder.AnchorPoint = IS_MOBILE and Vector2.new(0.5, 0) or Vector2.zero
ToastHolder.Position = IS_MOBILE and UDim2.new(0.5, 0, 0, 0) or UDim2.new(1, -290, 0, 0)
ToastHolder.BackgroundTransparency = 1
ToastHolder.Parent = ScreenGui
local toastLayout = Instance.new("UIListLayout")
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.Padding = UDim.new(0, 8)
toastLayout.Parent = ToastHolder
pad(ToastHolder, 0, 0, 0, 90)

local function notify(msg, color)
    local t = Instance.new("Frame")
    t.Size = UDim2.new(1, 0, 0, 40)
    t.BackgroundColor3 = Theme.Card
    t.BackgroundTransparency = 1
    t.Parent = ToastHolder
    corner(t, 8)
    local toastGrad = Instance.new("UIGradient")
    toastGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 22, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 12, 35)),
    })
    toastGrad.Rotation = 90
    toastGrad.Parent = t
    local s = stroke(t, color or Theme.Accent, 1.2, 1)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0.6, 0)
    bar.Position = UDim2.new(0, 6, 0.2, 0)
    bar.BackgroundColor3 = color or Theme.Accent
    bar.BorderSizePixel = 0
    bar.Parent = t
    corner(bar, 2)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -22, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tostring(msg)
    lbl.TextColor3 = Theme.Text
    lbl.TextTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = t
    tween(t, 0.3, {BackgroundTransparency = 0.1})
    tween(s, 0.3, {Transparency = 0.35})
    tween(lbl, 0.3, {TextTransparency = 0})
    task.delay(2.8, function()
        tween(t, 0.35, {BackgroundTransparency = 1})
        tween(s, 0.35, {Transparency = 1})
        tween(lbl, 0.35, {TextTransparency = 1})
        task.wait(0.4) t:Destroy()
    end)
end

--=========================================================================
-- MAIN WINDOW
--=========================================================================
local WIN_W = IS_MOBILE and 420 or 480
local WIN_H = IS_MOBILE and 340 or 380
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

local ClickAbsorber = Instance.new("TextButton")
ClickAbsorber.Size = UDim2.new(1, 0, 1, 0)
ClickAbsorber.BackgroundTransparency = 1
ClickAbsorber.Text = ""
ClickAbsorber.ZIndex = 0
ClickAbsorber.Active = true
ClickAbsorber.Parent = Window

local WinScale = Instance.new("UIScale")
WinScale.Scale = 1
WinScale.Parent = Window

local baseScale = 1
local function computeScale()
    local vp = Workspace.CurrentCamera.ViewportSize
    local margin = IS_MOBILE and 0.97 or 0.94
    local sx = (vp.X * margin) / WIN_W
    local sy = (vp.Y * margin) / WIN_H
    local s = math.min(sx, sy, IS_MOBILE and 1.15 or 1)
    return math.max(s, 0.45)
end
baseScale = computeScale()
WinScale.Scale = baseScale
table.insert(AllConns, Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    baseScale = computeScale()
    if Window.Visible then WinScale.Scale = baseScale end
end))

-- Glow
local Glow = Instance.new("ImageLabel")
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5028857084"
Glow.ImageColor3 = Theme.Accent
Glow.ImageTransparency = 0.85
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(24, 24, 276, 276)
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
Glow.Size = UDim2.new(1, 50, 1, 50)
Glow.ZIndex = 0
Glow.Parent = Window

--=========================================================================
-- TOP BAR (Header)
--=========================================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BorderSizePixel = 0
TopBar.Parent = Window
corner(TopBar, 14)
-- Cover bottom corners
local topCover = Instance.new("Frame")
topCover.Size = UDim2.new(1, 0, 0, 16)
topCover.Position = UDim2.new(0, 0, 1, -16)
topCover.BackgroundColor3 = Theme.Sidebar
topCover.BorderSizePixel = 0
topCover.Parent = TopBar

-- Logo badge
local logoDot = Instance.new("Frame")
logoDot.Size = UDim2.new(0, 34, 0, 34)
logoDot.Position = UDim2.new(0, 10, 0.5, -17)
logoDot.BackgroundColor3 = Theme.LogoBg
logoDot.BorderSizePixel = 0
logoDot.Parent = TopBar
corner(logoDot, 10)
local logoStroke = stroke(logoDot, Theme.Accent, 1.5, 0.2)
local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "1337"
logoText.TextColor3 = Theme.Accent
logoText.Font = Enum.Font.GothamBold
logoText.TextSize = 11
logoText.Parent = logoDot

task.spawn(function()
    while ScreenGui and ScreenGui.Parent and Running do
        local a = tween(logoStroke, 1.3, {Transparency = 0.7}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) a.Completed:Wait()
        if not Running then break end
        local b = tween(logoStroke, 1.3, {Transparency = 0.15}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) b.Completed:Wait()
    end
end)

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -140, 0, 20)
titleLabel.Position = UDim2.new(0, 52, 0.5, -10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = BRAND.Title
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TopBar
local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.6, Theme.Accent2),
    ColorSequenceKeypoint.new(1, Theme.Accent),
})
titleGrad.Parent = titleLabel

-- Minimize & Close
local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 30, 0, 30)
btnMin.Position = UDim2.new(1, -70, 0.5, -15)
btnMin.BackgroundColor3 = Color3.fromRGB(35, 25, 60)
btnMin.Text = "-"
btnMin.TextColor3 = Theme.Yellow
btnMin.Font = Enum.Font.GothamBlack
btnMin.TextSize = 20
btnMin.AutoButtonColor = false
btnMin.Parent = TopBar
corner(btnMin, 8)
stroke(btnMin, Theme.Yellow, 1, 0.3)

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -36, 0.5, -15)
btnClose.BackgroundColor3 = Color3.fromRGB(35, 25, 60)
btnClose.Text = "X"
btnClose.TextColor3 = Theme.Red
btnClose.Font = Enum.Font.GothamBlack
btnClose.TextSize = 13
btnClose.AutoButtonColor = false
btnClose.Parent = TopBar
corner(btnClose, 8)
stroke(btnClose, Theme.Red, 1, 0.3)

--=========================================================================
-- CONTENT AREA (scrollable)
--=========================================================================
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, 0, 1, -48 - 34)
ContentArea.Position = UDim2.new(0, 0, 0, 48)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 4
ContentArea.ScrollBarImageColor3 = Theme.Accent
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.ScrollingDirection = Enum.ScrollingDirection.Y
ContentArea.Parent = Window
local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = ContentArea
pad(ContentArea, 12, 12, 10, 14)

--=========================================================================
-- BOTTOM BAR
--=========================================================================
local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1, 0, 0, 34)
BottomBar.Position = UDim2.new(0, 0, 1, -34)
BottomBar.BackgroundColor3 = Theme.BottomBar
BottomBar.BorderSizePixel = 0
BottomBar.ClipsDescendants = true
BottomBar.Parent = Window
corner(BottomBar, 14)

local barCover = Instance.new("Frame")
barCover.Size = UDim2.new(1, 0, 0, 16)
barCover.BackgroundColor3 = Theme.BottomBar
barCover.BorderSizePixel = 0
barCover.Parent = BottomBar

local barLine = Instance.new("Frame")
barLine.Size = UDim2.new(1, 0, 0, 1)
barLine.BackgroundColor3 = Theme.Accent
barLine.BorderSizePixel = 0
barLine.Parent = BottomBar
local barLineGrad = Instance.new("UIGradient")
barLineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.85),
    NumberSequenceKeypoint.new(0.5, 0.3),
    NumberSequenceKeypoint.new(1, 0.85),
})
barLineGrad.Parent = barLine

-- Bottom left: game name rotating with discord
local animHolder = Instance.new("Frame")
animHolder.Size = UDim2.new(1, -80, 0, 18)
animHolder.Position = UDim2.new(0, 10, 0.5, -9)
animHolder.BackgroundTransparency = 1
animHolder.ClipsDescendants = true
animHolder.Parent = BottomBar

local animLabel = Instance.new("TextLabel")
animLabel.Size = UDim2.new(1, 0, 1, 0)
animLabel.BackgroundTransparency = 1
animLabel.Text = GameName
animLabel.TextColor3 = Theme.TextDim
animLabel.Font = Enum.Font.GothamMedium
animLabel.TextSize = 10
animLabel.TextXAlignment = Enum.TextXAlignment.Left
animLabel.TextTruncate = Enum.TextTruncate.AtEnd
animLabel.Parent = animHolder

local isShowingDiscord = false
local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(1, 0, 1, 0)
discordBtn.BackgroundTransparency = 1
discordBtn.Text = ""
discordBtn.ZIndex = 10
discordBtn.AutoButtonColor = false
discordBtn.Parent = animHolder
discordBtn.MouseButton1Click:Connect(function()
    if isShowingDiscord then
        pcall(function() setclipboard("https://" .. BRAND.Discord) end)
        pcall(function() toclipboard("https://" .. BRAND.Discord) end)
        animLabel.TextColor3 = Theme.Good
        animLabel.Text = "Copied!"
        task.wait(1)
        animLabel.TextColor3 = Theme.Accent2
        animLabel.Text = BRAND.Discord
    end
end)

task.spawn(function()
    local idx = 1
    while ScreenGui and ScreenGui.Parent and Running do
        local items = {
            {text = GameName, color = Theme.TextDim, dc = false},
            {text = BRAND.Discord, color = Theme.Accent2, dc = true},
        }
        local item = items[idx]
        isShowingDiscord = item.dc
        tween(animLabel, 0.3, {Position = UDim2.new(0, 0, -1, 0), TextTransparency = 1})
        task.wait(0.3)
        animLabel.Text = item.text
        animLabel.TextColor3 = item.color
        animLabel.Position = UDim2.new(0, 0, 1, 0)
        tween(animLabel, 0.3, {Position = UDim2.new(0, 0, 0, 0), TextTransparency = 0})
        task.wait(3.5)
        idx = idx % #items + 1
    end
end)

-- Version badge
local barVersion = Instance.new("TextLabel")
barVersion.Size = UDim2.new(0, 52, 0, 18)
barVersion.Position = UDim2.new(1, -58, 0.5, -9)
barVersion.BackgroundColor3 = Theme.Card
barVersion.Text = BRAND.Version
barVersion.TextColor3 = Theme.Good
barVersion.Font = Enum.Font.GothamBold
barVersion.TextSize = 9
barVersion.Parent = BottomBar
corner(barVersion, 6)
local vStroke = stroke(barVersion, Theme.Good, 1, 0.6)
task.spawn(function()
    while ScreenGui and ScreenGui.Parent and Running do
        local a = tween(vStroke, 2, {Transparency = 0.2}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) a.Completed:Wait()
        if not Running then break end
        local b = tween(vStroke, 2, {Transparency = 0.7}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) b.Completed:Wait()
    end
end)

--=========================================================================
-- LOADING OVERLAY
--=========================================================================
local LoadOverlay = Instance.new("Frame")
LoadOverlay.Size = UDim2.new(1, 0, 1, 0)
LoadOverlay.BackgroundColor3 = Color3.fromRGB(9, 7, 18)
LoadOverlay.BackgroundTransparency = 0.05
LoadOverlay.ZIndex = 50
LoadOverlay.Visible = false
LoadOverlay.Parent = Window
corner(LoadOverlay, 14)

local loadLogo = Instance.new("Frame")
loadLogo.Size = UDim2.new(0, 56, 0, 56)
loadLogo.AnchorPoint = Vector2.new(0.5, 0.5)
loadLogo.Position = UDim2.new(0.5, 0, 0.32, 0)
loadLogo.BackgroundColor3 = Theme.LogoBg
loadLogo.BorderSizePixel = 0
loadLogo.ZIndex = 51
loadLogo.Parent = LoadOverlay
corner(loadLogo, 14)
stroke(loadLogo, Theme.Accent, 2)
local llText = Instance.new("TextLabel")
llText.Size = UDim2.new(1, 0, 1, 0)
llText.BackgroundTransparency = 1
llText.Text = "1337"
llText.TextColor3 = Theme.Accent
llText.Font = Enum.Font.GothamBold
llText.TextSize = 18
llText.ZIndex = 52
llText.Parent = loadLogo

local loadTitle = Instance.new("TextLabel")
loadTitle.AnchorPoint = Vector2.new(0.5, 0)
loadTitle.Position = UDim2.new(0.5, 0, 0.5, -8)
loadTitle.Size = UDim2.new(0.8, 0, 0, 20)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "Loading Scripts..."
loadTitle.TextColor3 = Theme.Text
loadTitle.Font = Enum.Font.GothamBold
loadTitle.TextSize = 15
loadTitle.ZIndex = 51
loadTitle.Parent = LoadOverlay

local loadStatus = Instance.new("TextLabel")
loadStatus.AnchorPoint = Vector2.new(0.5, 0)
loadStatus.Position = UDim2.new(0.5, 0, 0.5, 14)
loadStatus.Size = UDim2.new(0.8, 0, 0, 16)
loadStatus.BackgroundTransparency = 1
loadStatus.Text = "Initializing..."
loadStatus.TextColor3 = Theme.TextDim
loadStatus.Font = Enum.Font.GothamMedium
loadStatus.TextSize = 11
loadStatus.ZIndex = 51
loadStatus.Parent = LoadOverlay

local loadBarBg = Instance.new("Frame")
loadBarBg.AnchorPoint = Vector2.new(0.5, 0)
loadBarBg.Position = UDim2.new(0.5, 0, 0.5, 38)
loadBarBg.Size = UDim2.new(0, 220, 0, 6)
loadBarBg.BackgroundColor3 = Theme.Card
loadBarBg.BorderSizePixel = 0
loadBarBg.ZIndex = 51
loadBarBg.Parent = LoadOverlay
corner(loadBarBg, 3)
stroke(loadBarBg, Theme.Stroke, 1, 0.5)

local loadBarFill = Instance.new("Frame")
loadBarFill.Size = UDim2.new(0, 0, 1, 0)
loadBarFill.BackgroundColor3 = Theme.Accent
loadBarFill.BorderSizePixel = 0
loadBarFill.ZIndex = 52
loadBarFill.Parent = loadBarBg
corner(loadBarFill, 3)
local fillGrad = Instance.new("UIGradient")
fillGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.Accent2),
})
fillGrad.Parent = loadBarFill

local loadPct = Instance.new("TextLabel")
loadPct.AnchorPoint = Vector2.new(0.5, 0)
loadPct.Position = UDim2.new(0.5, 0, 0.5, 50)
loadPct.Size = UDim2.new(0.5, 0, 0, 14)
loadPct.BackgroundTransparency = 1
loadPct.Text = "0%"
loadPct.TextColor3 = Theme.Accent2
loadPct.Font = Enum.Font.GothamBold
loadPct.TextSize = 10
loadPct.ZIndex = 51
loadPct.Parent = LoadOverlay

local function showLoading(scriptName, callback)
    LoadOverlay.Visible = true
    loadBarFill.Size = UDim2.new(0, 0, 1, 0)
    local steps = {
        {pct = 15,  msg = "Connecting..."},
        {pct = 35,  msg = "Detecting: " .. GameName},
        {pct = 55,  msg = "Fetching: " .. scriptName},
        {pct = 75,  msg = "Verifying integrity..."},
        {pct = 90,  msg = "Injecting..."},
        {pct = 100, msg = "Done!"},
    }
    task.spawn(function()
        for _, step in ipairs(steps) do
            loadStatus.Text = step.msg
            loadPct.Text = step.pct .. "%"
            tween(loadBarFill, 0.25, {Size = UDim2.new(step.pct / 100, 0, 1, 0)})
            task.wait(0.35)
        end
        task.wait(0.4)
        LoadOverlay.Visible = false
        if callback then callback() end
    end)
end

--=========================================================================
-- BUILD CONTENT: AUTO-DETECT GAME & SHOW SCRIPTS
--=========================================================================
local function buildContent()
    -- Game detected header
    local headerCard = Instance.new("Frame")
    headerCard.Size = UDim2.new(1, 0, 0, 0)
    headerCard.AutomaticSize = Enum.AutomaticSize.Y
    headerCard.BackgroundColor3 = Theme.Card
    headerCard.BorderSizePixel = 0
    headerCard.LayoutOrder = 1
    headerCard.Parent = ContentArea
    corner(headerCard, 10)
    pad(headerCard, 12, 12, 10, 10)
    local hLay = Instance.new("UIListLayout")
    hLay.Padding = UDim.new(0, 4)
    hLay.SortOrder = Enum.SortOrder.LayoutOrder
    hLay.Parent = headerCard

    if IsSupported then
        -- ✅ Game supported
        stroke(headerCard, Theme.Good, 1, 0.35)

        local hRow = Instance.new("Frame")
        hRow.Size = UDim2.new(1, 0, 0, IS_MOBILE and 46 or 40)
        hRow.BackgroundTransparency = 1
        hRow.LayoutOrder = 1
        hRow.Parent = headerCard

        -- Game thumbnail
        local thumb = Instance.new("ImageLabel")
        thumb.Size = UDim2.new(0, IS_MOBILE and 40 or 36, 0, IS_MOBILE and 40 or 36)
        thumb.Position = UDim2.new(0, 0, 0.5, -(IS_MOBILE and 20 or 18))
        thumb.BackgroundColor3 = Theme.LogoBg
        thumb.BorderSizePixel = 0
        thumb.Parent = hRow
        corner(thumb, 10)
        stroke(thumb, Theme.Accent, 1.5)
        task.spawn(function()
            pcall(function()
                thumb.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. game.PlaceId .. "&width=150&height=150&format=png"
            end)
        end)

        local hName = Instance.new("TextLabel")
        hName.Size = UDim2.new(1, -60, 0, 18)
        hName.Position = UDim2.new(0, IS_MOBILE and 48 or 44, 0, IS_MOBILE and 4 or 2)
        hName.BackgroundTransparency = 1
        hName.Text = CurrentGame.name
        hName.TextColor3 = Theme.Text
        hName.Font = Enum.Font.GothamBlack
        hName.TextSize = 15
        hName.TextXAlignment = Enum.TextXAlignment.Left
        hName.Parent = hRow

        local hSub = Instance.new("TextLabel")
        hSub.Size = UDim2.new(1, -60, 0, 14)
        hSub.Position = UDim2.new(0, IS_MOBILE and 48 or 44, 0, IS_MOBILE and 24 or 22)
        hSub.BackgroundTransparency = 1
        hSub.Text = tostring(#CurrentGame.scripts) .. " scripts available  ·  PlaceId: " .. game.PlaceId
        hSub.TextColor3 = Theme.TextDim
        hSub.Font = Enum.Font.Gotham
        hSub.TextSize = 10
        hSub.TextXAlignment = Enum.TextXAlignment.Left
        hSub.Parent = hRow

        -- Status
        local statusColors = {
            updated  = {color = Theme.Good,   label = "SUPPORTED"},
            testing  = {color = Theme.Yellow, label = "TESTING"},
            outdated = {color = Theme.Red,    label = "OUTDATED"},
        }
        local sc = statusColors[CurrentGame.status] or statusColors.updated
        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, 0, 0, 16)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Status: " .. sc.label
        statusLbl.TextColor3 = sc.color
        statusLbl.Font = Enum.Font.GothamBold
        statusLbl.TextSize = 11
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.LayoutOrder = 2
        statusLbl.Parent = headerCard

        --━━━━━ SCRIPT LIST ━━━━━
        local scriptTitle = Instance.new("TextLabel")
        scriptTitle.Size = UDim2.new(1, 0, 0, 24)
        scriptTitle.BackgroundTransparency = 1
        scriptTitle.Text = "SCRIPTS"
        scriptTitle.TextColor3 = Theme.TextDim
        scriptTitle.Font = Enum.Font.GothamBold
        scriptTitle.TextSize = 10
        scriptTitle.TextXAlignment = Enum.TextXAlignment.Left
        scriptTitle.LayoutOrder = 2
        scriptTitle.Parent = ContentArea

        local loadedScripts = {}

        for i, scriptData in ipairs(CurrentGame.scripts) do
            local sRow = Instance.new("Frame")
            sRow.Size = UDim2.new(1, 0, 0, IS_MOBILE and 44 or 38)
            sRow.BackgroundColor3 = Theme.Card
            sRow.BorderSizePixel = 0
            sRow.LayoutOrder = 2 + i
            sRow.Parent = ContentArea
            corner(sRow, 8)
            stroke(sRow, Theme.Stroke, 1, 0.55)

            -- Status dot
            local dot = Instance.new("Frame")
            dot.Name = "Dot"
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.Position = UDim2.new(0, 12, 0.5, -4)
            dot.BackgroundColor3 = Theme.TextHint
            dot.BorderSizePixel = 0
            dot.Parent = sRow
            corner(dot, 4)

            -- Script name
            local sLabel = Instance.new("TextLabel")
            sLabel.Name = "Label"
            sLabel.Size = UDim2.new(1, -110, 1, 0)
            sLabel.Position = UDim2.new(0, 28, 0, 0)
            sLabel.BackgroundTransparency = 1
            sLabel.Text = scriptData.name
            sLabel.TextColor3 = Theme.Text
            sLabel.Font = Enum.Font.GothamMedium
            sLabel.TextSize = IS_MOBILE and 13 or 12
            sLabel.TextXAlignment = Enum.TextXAlignment.Left
            sLabel.Parent = sRow

            -- Execute button
            local sBtn = Instance.new("TextButton")
            sBtn.Size = UDim2.new(0, IS_MOBILE and 74 or 68, 0, IS_MOBILE and 28 or 24)
            sBtn.Position = UDim2.new(1, -(IS_MOBILE and 82 or 76), 0.5, -(IS_MOBILE and 14 or 12))
            sBtn.BackgroundColor3 = Theme.Accent
            sBtn.Text = "Execute"
            sBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            sBtn.Font = Enum.Font.GothamBold
            sBtn.TextSize = IS_MOBILE and 11 or 10
            sBtn.AutoButtonColor = false
            sBtn.Parent = sRow
            corner(sBtn, 6)

            local loaded = false
            sBtn.MouseButton1Click:Connect(function()
                if loaded then return end

                showLoading(scriptData.name, function()
                    loaded = true
                    table.insert(loadedScripts, scriptData.name)
                    sBtn.Text = "Active \226\156\147"
                    tween(sBtn, 0.25, {BackgroundColor3 = Theme.Good})
                    tween(dot, 0.25, {BackgroundColor3 = Theme.Good})
                    tween(sLabel, 0.25, {TextColor3 = Theme.Good})
                    tween(sRow, 0.25, {BackgroundColor3 = Color3.fromRGB(16, 30, 25)})
                    stroke(sRow, Theme.Good, 1, 0.5)
                    notify("Loaded: " .. scriptData.name, Theme.Good)

                    -- Execute the actual script from GitHub
                    if scriptData.path and scriptData.path ~= "" then
                        pcall(function()
                            loadstring(game:HttpGet(scriptURL(scriptData.path)))()
                        end)
                    end
                end)
            end)

            -- Hover effect
            sRow.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and not loaded then
                    tween(sRow, 0.15, {BackgroundColor3 = Theme.CardHover})
                end
            end)
            sRow.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and not loaded then
                    tween(sRow, 0.15, {BackgroundColor3 = Theme.Card})
                end
            end)
        end

        --━━━━━ EXECUTE ALL BUTTON ━━━━━
        local execAllBtn = Instance.new("TextButton")
        execAllBtn.Size = UDim2.new(1, 0, 0, IS_MOBILE and 44 or 38)
        execAllBtn.BackgroundColor3 = Theme.Accent
        execAllBtn.Text = "\226\154\161 Execute All Scripts"
        execAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        execAllBtn.Font = Enum.Font.GothamBold
        execAllBtn.TextSize = IS_MOBILE and 14 or 13
        execAllBtn.AutoButtonColor = false
        execAllBtn.LayoutOrder = 100
        execAllBtn.Parent = ContentArea
        corner(execAllBtn, 8)

        local allLoaded = false
        execAllBtn.MouseButton1Click:Connect(function()
            if allLoaded then return end
            allLoaded = true
            execAllBtn.Text = "Loading..."
            tween(execAllBtn, 0.2, {BackgroundColor3 = Theme.CardHover})

            showLoading("All Scripts", function()
                execAllBtn.Text = "All Scripts Active \226\156\147"
                tween(execAllBtn, 0.25, {BackgroundColor3 = Theme.Good})
                notify("All " .. #CurrentGame.scripts .. " scripts loaded!", Theme.Good)

                -- Execute all scripts from GitHub
                for _, s in ipairs(CurrentGame.scripts) do
                    if s.path and s.path ~= "" then
                        pcall(function()
                            loadstring(game:HttpGet(scriptURL(s.path)))()
                        end)
                    end
                end

                -- Update all rows visually
                for _, child in ipairs(ContentArea:GetChildren()) do
                    if child:IsA("Frame") and child:FindFirstChild("Dot") then
                        local d = child:FindFirstChild("Dot")
                        local l = child:FindFirstChild("Label")
                        if d then tween(d, 0.25, {BackgroundColor3 = Theme.Good}) end
                        if l then tween(l, 0.25, {TextColor3 = Theme.Good}) end
                        tween(child, 0.25, {BackgroundColor3 = Color3.fromRGB(16, 30, 25)})
                        for _, btn in ipairs(child:GetChildren()) do
                            if btn:IsA("TextButton") then
                                btn.Text = "Active \226\156\147"
                                tween(btn, 0.25, {BackgroundColor3 = Theme.Good})
                            end
                        end
                    end
                end
            end)
        end)

        execAllBtn.MouseButton1Down:Connect(function() tween(execAllBtn, 0.08, {Size = UDim2.new(1, -4, 0, (IS_MOBILE and 44 or 38) - 2)}) end)
        execAllBtn.MouseButton1Up:Connect(function() tween(execAllBtn, 0.12, {Size = UDim2.new(1, 0, 0, IS_MOBILE and 44 or 38)}, Enum.EasingStyle.Back) end)

        -- Outdated warning
        if CurrentGame.status == "outdated" then
            local warnCard = Instance.new("Frame")
            warnCard.Size = UDim2.new(1, 0, 0, 0)
            warnCard.AutomaticSize = Enum.AutomaticSize.Y
            warnCard.BackgroundColor3 = Color3.fromRGB(40, 15, 18)
            warnCard.BorderSizePixel = 0
            warnCard.LayoutOrder = 101
            warnCard.Parent = ContentArea
            corner(warnCard, 8)
            stroke(warnCard, Theme.Red, 1, 0.5)
            pad(warnCard, 12, 12, 10, 10)
            local wLbl = Instance.new("TextLabel")
            wLbl.Size = UDim2.new(1, 0, 0, 0)
            wLbl.AutomaticSize = Enum.AutomaticSize.Y
            wLbl.BackgroundTransparency = 1
            wLbl.Text = "\226\154\160 Scripts for this game are outdated and may not work correctly."
            wLbl.TextColor3 = Theme.Red
            wLbl.Font = Enum.Font.GothamMedium
            wLbl.TextSize = 11
            wLbl.TextWrapped = true
            wLbl.TextXAlignment = Enum.TextXAlignment.Left
            wLbl.Parent = warnCard
        end

    else
        --━━━━━ GAME NOT SUPPORTED ━━━━━
        stroke(headerCard, Theme.Orange, 1, 0.4)

        local noIcon = Instance.new("TextLabel")
        noIcon.Size = UDim2.new(1, 0, 0, 36)
        noIcon.BackgroundTransparency = 1
        noIcon.Text = "\226\154\160"
        noIcon.TextSize = 28
        noIcon.LayoutOrder = 1
        noIcon.Parent = headerCard

        local noTitle = Instance.new("TextLabel")
        noTitle.Size = UDim2.new(1, 0, 0, 20)
        noTitle.BackgroundTransparency = 1
        noTitle.Text = "No Scripts Found"
        noTitle.TextColor3 = Theme.Orange
        noTitle.Font = Enum.Font.GothamBlack
        noTitle.TextSize = 16
        noTitle.LayoutOrder = 2
        noTitle.Parent = headerCard

        local noSub = Instance.new("TextLabel")
        noSub.Size = UDim2.new(1, 0, 0, 0)
        noSub.AutomaticSize = Enum.AutomaticSize.Y
        noSub.BackgroundTransparency = 1
        noSub.Text = "Game: " .. GameName .. "\nPlaceId: " .. game.PlaceId .. "\n\nThis game is not yet supported.\nJoin our Discord for script requests!"
        noSub.TextColor3 = Theme.TextDim
        noSub.Font = Enum.Font.GothamMedium
        noSub.TextSize = 12
        noSub.TextWrapped = true
        noSub.TextXAlignment = Enum.TextXAlignment.Left
        noSub.LayoutOrder = 3
        noSub.Parent = headerCard

        -- Copy Discord button
        local dcBtn = Instance.new("TextButton")
        dcBtn.Size = UDim2.new(1, 0, 0, IS_MOBILE and 40 or 34)
        dcBtn.BackgroundColor3 = Theme.Accent
        dcBtn.Text = "Copy Discord Link"
        dcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        dcBtn.Font = Enum.Font.GothamBold
        dcBtn.TextSize = 12
        dcBtn.AutoButtonColor = false
        dcBtn.LayoutOrder = 4
        dcBtn.Parent = headerCard
        corner(dcBtn, 8)
        dcBtn.MouseButton1Click:Connect(function()
            pcall(function() setclipboard("https://" .. BRAND.Discord) end)
            pcall(function() toclipboard("https://" .. BRAND.Discord) end)
            dcBtn.Text = "Copied! \226\156\147"
            tween(dcBtn, 0.2, {BackgroundColor3 = Theme.Good})
            notify("Discord link copied!", Theme.Good)
            task.wait(1.5)
            dcBtn.Text = "Copy Discord Link"
            tween(dcBtn, 0.2, {BackgroundColor3 = Theme.Accent})
        end)
    end
end

buildContent()

--=========================================================================
-- DRAG WINDOW
--=========================================================================
do
    local dragging, dragStart, startPos = false, nil, nil
    local function beginDrag(input) dragging = true; dragStart = input.Position; startPos = Window.Position end
    local function updateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    for _, zone in ipairs({TopBar, BottomBar}) do
        zone.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then beginDrag(input) end
        end)
    end
    table.insert(AllConns, UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then updateDrag(input) end
    end))
    table.insert(AllConns, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

--=========================================================================
-- FLOAT BUTTON
--=========================================================================
local FLOAT_SZ = IS_MOBILE and 52 or 46
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, FLOAT_SZ, 0, FLOAT_SZ)
FloatBtn.Position = UDim2.new(0, 16, 1, -(FLOAT_SZ + 16))
FloatBtn.BackgroundColor3 = Theme.LogoBg
FloatBtn.Text = "1337"
FloatBtn.TextColor3 = Theme.Accent
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 14
FloatBtn.AutoButtonColor = false
FloatBtn.Visible = false
FloatBtn.Parent = ScreenGui
corner(FloatBtn, 12)
local fStroke = stroke(FloatBtn, Theme.Accent, 1.5, 0.2)
local fScale = Instance.new("UIScale")
fScale.Scale = 1
fScale.Parent = FloatBtn

task.spawn(function()
    while ScreenGui and ScreenGui.Parent and Running do
        if FloatBtn.Visible then
            local a = tween(fStroke, 1.5, {Transparency = 0.7}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) a.Completed:Wait()
            if not Running then break end
            local b = tween(fStroke, 1.5, {Transparency = 0.15}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) b.Completed:Wait()
        else task.wait(0.5) end
    end
end)

local function showFloat() FloatBtn.Visible = true; fScale.Scale = 0; tween(fScale, 0.32, {Scale = 1}, Enum.EasingStyle.Back) end
local function hideFloat()
    local t = tween(fScale, 0.16, {Scale = 0}, Enum.EasingStyle.Quad)
    t.Completed:Once(function() FloatBtn.Visible = false; fScale.Scale = 1 end)
end

--=========================================================================
-- OPEN / MINIMIZE / EXIT
--=========================================================================
local busy = false
local function openWindow()
    if busy then return end; busy = true
    hideFloat(); Window.Visible = true; Window.GroupTransparency = 1; WinScale.Scale = baseScale * 0.92
    tween(Window, 0.28, {GroupTransparency = 0}, Enum.EasingStyle.Quad)
    local t = tween(WinScale, 0.42, {Scale = baseScale}, Enum.EasingStyle.Back)
    t.Completed:Once(function() busy = false end)
end
local function minimizeWindow()
    if busy then return end; busy = true
    tween(Window, 0.22, {GroupTransparency = 1}, Enum.EasingStyle.Quad)
    local t = tween(WinScale, 0.22, {Scale = baseScale * 0.9}, Enum.EasingStyle.Quad)
    t.Completed:Once(function() Window.Visible = false; busy = false; showFloat() end)
end
local function exitUI()
    if busy then return end; busy = true
    Running = false; _G._1337Loader_Running = nil
    tween(Window, 0.22, {GroupTransparency = 1}, Enum.EasingStyle.Quad)
    local t = tween(WinScale, 0.22, {Scale = baseScale * 0.88}, Enum.EasingStyle.Quad)
    t.Completed:Once(function() ScreenGui:Destroy() end)
end

btnMin.MouseButton1Click:Connect(minimizeWindow)
btnClose.MouseButton1Click:Connect(exitUI)
FloatBtn.MouseButton1Click:Connect(openWindow)
btnMin.MouseEnter:Connect(function() tween(btnMin, 0.15, {BackgroundColor3 = Theme.Yellow, TextColor3 = Color3.fromRGB(20,20,20)}) end)
btnMin.MouseLeave:Connect(function() tween(btnMin, 0.15, {BackgroundColor3 = Color3.fromRGB(35, 25, 60), TextColor3 = Theme.Yellow}) end)
btnClose.MouseEnter:Connect(function() tween(btnClose, 0.15, {BackgroundColor3 = Theme.Red, TextColor3 = Color3.fromRGB(255,255,255)}) end)
btnClose.MouseLeave:Connect(function() tween(btnClose, 0.15, {BackgroundColor3 = Color3.fromRGB(35, 25, 60), TextColor3 = Theme.Red}) end)

-- Drag float
do
    local dg, ds, sp, moved = false, nil, nil, false
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dg, ds, sp, moved = true, input.Position, FloatBtn.Position, false
        end
    end)
    table.insert(AllConns, UserInputService.InputChanged:Connect(function(input)
        if dg and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - ds
            if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then moved = true end
            FloatBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end))
    table.insert(AllConns, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dg and not moved then openWindow() end; dg = false
        end
    end))
end

--=========================================================================
-- KEYBIND (RightCtrl / F5)
--=========================================================================
table.insert(AllConns, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.F5 then
        if Window.Visible then minimizeWindow() else openWindow() end
    end
end))

--=========================================================================
-- INIT — Open window with animation
--=========================================================================
Window.Visible = true; Window.GroupTransparency = 1; WinScale.Scale = baseScale * 0.92
tween(Window, 0.25, {GroupTransparency = 0}, Enum.EasingStyle.Quad)
tween(WinScale, 0.3, {Scale = baseScale}, Enum.EasingStyle.Back)

task.delay(0.5, function()
    if IsSupported then
        notify("Game detected: " .. CurrentGame.name, Theme.Good)
    else
        notify("No scripts for this game", Theme.Orange)
    end
end)

print("[1337 Hub] Loader ready — " .. (IsSupported and ("Game: " .. CurrentGame.name) or "Unsupported game") .. " (PlaceId: " .. game.PlaceId .. ")")
