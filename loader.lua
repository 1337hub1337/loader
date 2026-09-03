local GAMES = {
	[8356562067] = { "Indo Voice", "https://api.jnkie.com/api/v1/luascripts/public/8389ebc255af53e7e510d0b6b3a4408cf647691f7ca35a3dd5263ba0b8b6c9c2/download", nil },
	[9788848685] = { "Indohangot", "https://api.jnkie.com/api/v1/luascripts/public/a6a7eea2c9344af388eb0c8871544b59e00f43231f932c55f102919506362dc2/download", "KEYLESS" },
	[128736949265057] = { "Gakuran", "https://api.jnkie.com/api/v1/luascripts/public/9f06db6f4416c45f59b8d7df7f051043ca050fcd113b26e66f1707ccb51d7651/download", "KEYLESS" },
	[125927821145949] = { "Mine a Mountain", "https://api.jnkie.com/api/v1/luascripts/public/93d6de465112864e06a3dfdcb08e5351aa08b74b46a8f8d219771b1ff934fa66/download", "KEYLESS" },
	[137233438285284] = { "Chicken Farm", "https://api.jnkie.com/api/v1/luascripts/public/5ea054f5e9fee54780ba6c178172ae0e1080e750b2f3598b099b2bdeeda9d4ff/download", "KEYLESS" },
	[128784467030899] = { "Merge a Nuke!", "https://api.jnkie.com/api/v1/luascripts/public/a110766c7bd5ed95482a4163317711d7655ae41eae3f7b1cac2cc040a5c15906/download", "KEYLESS" },
	[115681808123944] = { "Throw a Coin", "https://api.jnkie.com/api/v1/luascripts/public/07b7ae726719e5de5522a393043310a12e8d057a688846430d01705f9c07bf87/download", "KEYLESS" },
	[72042130041700] = { "Throw a Coin", "https://api.jnkie.com/api/v1/luascripts/public/07b7ae726719e5de5522a393043310a12e8d057a688846430d01705f9c07bf87/download", "KEYLESS" },
	[83038462357724] = { "Dig & Clean", "https://api.jnkie.com/api/v1/luascripts/public/6ad58afa8a8dc632299c069f5718afc31d2d1f45c940a114e54340e2a9e57304/download", "KEYLESS" },
	[107778070777162] = { "Steal An Egg", "https://api.jnkie.com/api/v1/luascripts/public/a8ad4dd6a9cac6965c930d04a43d2b433af52e2a4fb84f6e89a20c88165a4771/download", "KEYLESS" },
	[94640181989498] = { "Grow a Chicken Fighter", "https://gist.githubusercontent.com/1337hub1337/dd53c1fe4509f0a7d03510753d4184ea/raw/gacf.lua", nil },
	[124293095895786] = { "Stream A Cheese Pull!", "https://api.jnkie.com/api/v1/luascripts/public/e198f14ce9b7b0fd092a9f816f3bf3fe7d014b89d44978ade993aebaaea56cfc/download", "KEYLESS" },
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
