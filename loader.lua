local GAMES = {
	[128784467030899] = { "Merge a Nuke!", "https://api.jnkie.com/api/v1/luascripts/public/a110766c7bd5ed95482a4163317711d7655ae41eae3f7b1cac2cc040a5c15906/download", "KEYLESS" },
}

local currentGame = GAMES[game.PlaceId]

if currentGame then
	if currentGame[3] then
		getgenv().SCRIPT_KEY = currentGame[3]
	end
	loadstring(game:HttpGet(currentGame[2]))()
else
	warn("[1337 Hub] Script not available for this game (PlaceId: " .. game.PlaceId .. ")")

	task.spawn(function()
		local Players = game:GetService("Players")
		local TweenService = game:GetService("TweenService")
		local UserInputService = game:GetService("UserInputService")
		local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

		local gui = Instance.new("ScreenGui")
		gui.Name = "1337Hub_Notify"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder = 999999

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
		frame.Size = IS_MOBILE and UDim2.new(0.85, 0, 0, 75) or UDim2.new(0, 300, 0, 70)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.BackgroundColor3 = Color3.fromRGB(13, 10, 22)
		frame.BackgroundTransparency = 0
		frame.BorderSizePixel = 0
		frame.ZIndex = 100
		frame.Parent = gui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = frame

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Color3.fromRGB(255, 155, 55)
		uiStroke.Thickness = IS_MOBILE and 2 or 1.5
		uiStroke.Transparency = 0.3
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = frame

		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.new(1, -24, 0, 24)
		titleLbl.Position = UDim2.new(0, 12, 0, 10)
		titleLbl.BackgroundTransparency = 1
		titleLbl.Text = "1337 Hub"
		titleLbl.TextColor3 = Color3.fromRGB(139, 92, 246)
		titleLbl.Font = Enum.Font.GothamBold
		titleLbl.TextSize = IS_MOBILE and 16 or 14
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.ZIndex = 101
		titleLbl.Parent = frame

		local msgLbl = Instance.new("TextLabel")
		msgLbl.Size = UDim2.new(1, -24, 0, 20)
		msgLbl.Position = UDim2.new(0, 12, 0, 38)
		msgLbl.BackgroundTransparency = 1
		msgLbl.Text = "Script not available for this game."
		msgLbl.TextColor3 = Color3.fromRGB(240, 238, 255)
		msgLbl.Font = Enum.Font.GothamMedium
		msgLbl.TextSize = IS_MOBILE and 14 or 12
		msgLbl.TextXAlignment = Enum.TextXAlignment.Left
		msgLbl.ZIndex = 101
		msgLbl.Parent = frame

		task.wait(10)
		pcall(function()
			TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
			TweenService:Create(uiStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
			TweenService:Create(titleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
			TweenService:Create(msgLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		end)
		task.wait(0.4)
		gui:Destroy()
	end)
end
