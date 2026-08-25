--[[
    1337 Hub Loader — Auto-Detect & Auto-Execute
    Execute → Detect Game → Run Script → Done
--]]

--=========================================================================
-- GAME DATABASE
-- [PlaceId] = { "Nama Game", "Script URL", "Script Key" }
--=========================================================================
local GAMES = {
    [128784467030899] = { "Merge a Nuke!", "https://api.jnkie.com/api/v1/luascripts/public/a110766c7bd5ed95482a4163317711d7655ae41eae3f7b1cac2cc040a5c15906/download", "KEYLESS" },

    -- Add more games:
    -- [PlaceId] = { "Game Name", "Script URL", "Key" },
}

--=========================================================================
-- AUTO-DETECT & EXECUTE
--=========================================================================
local currentGame = GAMES[game.PlaceId]

if currentGame then
    local gameName  = currentGame[1]
    local scriptURL = currentGame[2]
    local scriptKey = currentGame[3]

    if scriptKey then
        getgenv().SCRIPT_KEY = scriptKey
    end

    loadstring(game:HttpGet(scriptURL))()
else
    warn("[1337 Hub] Script not available for this game (PlaceId: " .. game.PlaceId .. ")")

    -- On-screen notification
    pcall(function()
        local Players = game:GetService("Players")
        local TweenService = game:GetService("TweenService")
        local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

        local gui = Instance.new("ScreenGui")
        gui.Name = "1337Hub_Notify"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 999
        pcall(function() gui.Parent = (gethui and gethui()) or PlayerGui end)
        if not gui.Parent then gui.Parent = PlayerGui end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 260, 0, 60)
        frame.AnchorPoint = Vector2.new(0.5, 0)
        frame.Position = UDim2.new(0.5, 0, 0, -70)
        frame.BackgroundColor3 = Color3.fromRGB(13, 10, 22)
        frame.BorderSizePixel = 0
        frame.Parent = gui
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = frame
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(255, 155, 55)
        s.Thickness = 1.5
        s.Transparency = 0.3
        s.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 20)
        title.Position = UDim2.new(0, 10, 0, 8)
        title.BackgroundTransparency = 1
        title.Text = "1337 Hub"
        title.TextColor3 = Color3.fromRGB(139, 92, 246)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local msg = Instance.new("TextLabel")
        msg.Size = UDim2.new(1, -20, 0, 18)
        msg.Position = UDim2.new(0, 10, 0, 30)
        msg.BackgroundTransparency = 1
        msg.Text = "Script not available for this game."
        msg.TextColor3 = Color3.fromRGB(240, 238, 255)
        msg.Font = Enum.Font.GothamMedium
        msg.TextSize = 11
        msg.TextXAlignment = Enum.TextXAlignment.Left
        msg.Parent = frame

        -- Slide in
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0, 20)
        }):Play()

        -- Slide out & destroy
        task.delay(4, function()
            TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0, -70)
            }):Play()
            task.wait(0.35)
            gui:Destroy()
        end)
    end)
end
