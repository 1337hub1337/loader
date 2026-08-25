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
    task.spawn(function()
        local Players = game:GetService("Players")
        local TweenService = game:GetService("TweenService")
        local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

        local gui = Instance.new("ScreenGui")
        gui.Name = "1337Hub_Notify"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 999999

        -- Try multiple parents
        local success = false
        for _, parent in ipairs({
            gethui and gethui(),
            game:GetService("CoreGui"),
            PlayerGui,
        }) do
            if parent then
                local ok = pcall(function() gui.Parent = parent end)
                if ok and gui.Parent then success = true break end
            end
        end
        if not success then return end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 280, 0, 65)
        frame.AnchorPoint = Vector2.new(0.5, 0)
        frame.Position = UDim2.new(0.5, 0, 0, 20)
        frame.BackgroundColor3 = Color3.fromRGB(13, 10, 22)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.ZIndex = 100
        frame.Parent = gui

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = frame

        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(255, 155, 55)
        s.Thickness = 1.5
        s.Transparency = 0.3
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = frame

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -20, 0, 22)
        titleLbl.Position = UDim2.new(0, 10, 0, 8)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = "1337 Hub"
        titleLbl.TextColor3 = Color3.fromRGB(139, 92, 246)
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 14
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 101
        titleLbl.Parent = frame

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -20, 0, 18)
        msgLbl.Position = UDim2.new(0, 10, 0, 33)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = "Script not available for this game."
        msgLbl.TextColor3 = Color3.fromRGB(240, 238, 255)
        msgLbl.Font = Enum.Font.GothamMedium
        msgLbl.TextSize = 12
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        msgLbl.ZIndex = 101
        msgLbl.Parent = frame

        -- Auto destroy after 4 seconds
        task.wait(4)
        pcall(function()
            TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 1}):Play()
            TweenService:Create(titleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(msgLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        end)
        task.wait(0.4)
        gui:Destroy()
    end)
end
