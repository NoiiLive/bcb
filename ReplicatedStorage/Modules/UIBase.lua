-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local UIBase = {}

local theme = {
	BgStart = Color3.fromRGB(22, 5, 35),
	BgEnd = Color3.fromRGB(8, 0, 15),
	BarStart = Color3.fromRGB(45, 10, 60),
	BarEnd = Color3.fromRGB(25, 5, 35),
	BtnStart = Color3.fromRGB(85, 15, 95),
	BtnEnd = Color3.fromRGB(55, 5, 60),
	GoldLight = Color3.fromRGB(255, 225, 60),
	GoldDark = Color3.fromRGB(180, 150, 15),
	Shadow = Color3.fromRGB(5, 0, 10),
	Text = Color3.fromRGB(255, 250, 255)
}

local tabs = {"Battle", "Collection", "Team", "Draws", "Shop", "Profile"}

local function spawnFloatingDiamonds(parentFrame)
	task.spawn(function()
		local rng = Random.new()
		while true do
			local size = rng:NextInteger(20, 60)
			local startX = rng:NextNumber(0, 1)

			local diamond = Instance.new("Frame")
			diamond.Size = UDim2.new(0, size, 0, size)
			diamond.Position = UDim2.new(startX, 0, 1, 50)
			diamond.Rotation = 45
			diamond.BackgroundColor3 = rng:NextNumber() > 0.7 and theme.GoldDark or theme.BtnStart
			diamond.BackgroundTransparency = rng:NextNumber(0.4, 0.8)
			diamond.BorderSizePixel = 0
			diamond.Parent = parentFrame

			local speed = rng:NextNumber(8, 16)
			local rotationDir = rng:NextNumber() > 0.5 and 180 or -180

			local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
			local floatTween = TweenService:Create(diamond, tweenInfo, {
				Position = UDim2.new(startX, 0, -0.2, 0),
				Rotation = 45 + rotationDir
			})

			floatTween:Play()

			floatTween.Completed:Connect(function()
				diamond:Destroy()
			end)

			task.wait(rng:NextNumber(0.3, 1.2))
		end
	end)
end

function UIBase.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local bgGui = Instance.new("ScreenGui")
	bgGui.Name = "MainMenuBackground"
	bgGui.IgnoreGuiInset = true
	bgGui.DisplayOrder = 0
	bgGui.ResetOnSpawn = false
	bgGui.Parent = playerGui

	local mainGui = Instance.new("ScreenGui")
	mainGui.Name = "MainMenu"
	mainGui.IgnoreGuiInset = false
	mainGui.DisplayOrder = 1
	mainGui.ResetOnSpawn = false
	mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
	mainGui.Parent = playerGui

	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.new(1, 1, 1)
	background.BorderSizePixel = 0
	background.Parent = bgGui

	local bgGradient = Instance.new("UIGradient")
	bgGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, theme.BgStart),
		ColorSequenceKeypoint.new(1, theme.BgEnd)
	}
	bgGradient.Rotation = 90
	bgGradient.Parent = background

	local gameTitle = Instance.new("TextLabel")
	gameTitle.Name = "GameTitle"
	gameTitle.Size = UDim2.new(1, 0, 0, 40)
	gameTitle.Position = UDim2.new(0, 0, 0, 2)
	gameTitle.BackgroundTransparency = 1
	gameTitle.Text = "BIZARRE CARD BATTLER"
	gameTitle.TextColor3 = theme.GoldLight
	gameTitle.FontFace = Font.fromName("Oswald", Enum.FontWeight.Heavy)
	gameTitle.TextSize = 32
	gameTitle.Rotation = -1
	gameTitle.ZIndex = 5
	gameTitle.Parent = background

	local titleStroke = Instance.new("UIStroke")
	titleStroke.Color = theme.Shadow
	titleStroke.Thickness = 3
	titleStroke.Parent = gameTitle

	local titleTweenInfo = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	TweenService:Create(gameTitle, titleTweenInfo, {Rotation = 1}):Play()

	local effectsContainer = Instance.new("Frame")
	effectsContainer.Name = "EffectsContainer"
	effectsContainer.Size = UDim2.new(1, 0, 1, 0)
	effectsContainer.BackgroundTransparency = 1
	effectsContainer.ClipsDescendants = true
	effectsContainer.Parent = bgGui

	spawnFloatingDiamonds(effectsContainer)

	local safeArea = Instance.new("Frame")
	safeArea.Name = "SafeArea"
	safeArea.Size = UDim2.new(1, 0, 1, 0)
	safeArea.BackgroundTransparency = 1
	safeArea.Parent = mainGui

	local topBarContainer = Instance.new("Frame")
	topBarContainer.Name = "TopBarContainer"
	topBarContainer.BackgroundTransparency = 1
	topBarContainer.ZIndex = 10
	topBarContainer.Parent = safeArea

	local topBarShadow = Instance.new("Frame")
	topBarShadow.Name = "TopBarShadow"
	topBarShadow.Size = UDim2.new(1, 0, 1, 0)
	topBarShadow.Position = UDim2.new(0, 0, 0, 6)
	topBarShadow.BackgroundColor3 = theme.Shadow
	topBarShadow.BorderSizePixel = 0
	topBarShadow.Parent = topBarContainer

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 1, 0)
	topBar.BackgroundColor3 = Color3.new(1, 1, 1)
	topBar.BorderSizePixel = 0
	topBar.Parent = topBarContainer

	local barGradient = Instance.new("UIGradient")
	barGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, theme.BarStart),
		ColorSequenceKeypoint.new(1, theme.BarEnd)
	}
	barGradient.Rotation = 90
	barGradient.Parent = topBar

	local topBarStroke = Instance.new("UIStroke")
	topBarStroke.Color = theme.GoldLight
	topBarStroke.Thickness = 4
	topBarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	topBarStroke.Parent = topBar

	local navContainer = Instance.new("Frame")
	navContainer.Name = "NavContainer"
	navContainer.Size = UDim2.new(1, 0, 1, 0)
	navContainer.Position = UDim2.new(0, 0, 0, 0)
	navContainer.BackgroundTransparency = 1
	navContainer.Parent = topBar

	local navPadding = Instance.new("UIPadding")
	navPadding.PaddingLeft = UDim.new(0, 20)
	navPadding.PaddingRight = UDim.new(0, 20)
	navPadding.PaddingTop = UDim.new(0, 6)
	navPadding.PaddingBottom = UDim.new(0, 6)
	navPadding.Parent = navContainer

	local navList = Instance.new("UIListLayout")
	navList.FillDirection = Enum.FillDirection.Vertical
	navList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	navList.VerticalAlignment = Enum.VerticalAlignment.Center
	navList.Padding = UDim.new(0, 5)
	navList.Parent = navContainer

	local row1 = Instance.new("Frame")
	row1.Name = "Row1"
	row1.BackgroundTransparency = 1
	row1.Parent = navContainer

	local row1List = Instance.new("UIListLayout")
	row1List.FillDirection = Enum.FillDirection.Horizontal
	row1List.HorizontalAlignment = Enum.HorizontalAlignment.Center
	row1List.VerticalAlignment = Enum.VerticalAlignment.Center
	row1List.Padding = UDim.new(0, 10)
	row1List.Parent = row1

	local row2 = Instance.new("Frame")
	row2.Name = "Row2"
	row2.BackgroundTransparency = 1
	row2.Parent = navContainer

	local row2List = Instance.new("UIListLayout")
	row2List.FillDirection = Enum.FillDirection.Horizontal
	row2List.HorizontalAlignment = Enum.HorizontalAlignment.Center
	row2List.VerticalAlignment = Enum.VerticalAlignment.Center
	row2List.Padding = UDim.new(0, 10)
	row2List.Parent = row2

	local innerBorder = Instance.new("Frame")
	innerBorder.Name = "InnerBorder"
	innerBorder.BackgroundTransparency = 1
	innerBorder.ZIndex = 5
	innerBorder.Parent = safeArea

	local strokeFrame = Instance.new("Frame")
	strokeFrame.Name = "StrokeFrame"
	strokeFrame.Size = UDim2.new(1, 0, 1, 0)
	strokeFrame.BackgroundTransparency = 1
	strokeFrame.ZIndex = 1
	strokeFrame.Parent = innerBorder

	local innerBorderStroke = Instance.new("UIStroke")
	innerBorderStroke.Color = theme.GoldDark
	innerBorderStroke.Thickness = 3
	innerBorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	innerBorderStroke.Parent = strokeFrame

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.BackgroundTransparency = 1
	contentFrame.ZIndex = 5
	contentFrame.Parent = safeArea

	local btnWrappers = {}

	local function updateLayout()
		local sw = safeArea.AbsoluteSize.X
		local sh = safeArea.AbsoluteSize.Y
		if sw == 0 or sh == 0 then return end

		local isNarrow = sw < sh

		local topBarHeight = isNarrow and 90 or 70
		topBarContainer.Size = UDim2.new(1, 0, 0, topBarHeight)

		local padX = math.clamp(sw * 0.03, 10, 30)
		local padY = math.clamp(sh * 0.03, 10, 25)

		local contentY = topBarHeight + padY
		local contentHeight = sh - contentY - padY

		innerBorder.Position = UDim2.new(0, padX, 0, contentY)
		innerBorder.Size = UDim2.new(1, -(padX * 2), 0, contentHeight)

		contentFrame.Position = innerBorder.Position
		contentFrame.Size = innerBorder.Size

		local safeWidth = sw - 40
		local navH = topBarHeight - 12

		if isNarrow then
			local cellW = math.min(130, (safeWidth / 3) - 10)
			local cellH = (navH / 2) - 5

			row1.Size = UDim2.new(1, 0, 0, cellH)
			row2.Size = UDim2.new(1, 0, 0, cellH)
			row2.Visible = true

			for i, wrapper in ipairs(btnWrappers) do
				wrapper.Size = UDim2.new(0, cellW, 0, cellH)
				wrapper.Parent = (i <= 3) and row1 or row2
			end
		else
			local cellW = math.min(140, (safeWidth / 6) - 10)
			local cellH = navH

			row1.Size = UDim2.new(1, 0, 0, cellH)
			row2.Visible = false

			for i, wrapper in ipairs(btnWrappers) do
				wrapper.Size = UDim2.new(0, cellW, 0, cellH)
				wrapper.Parent = row1
			end
		end
	end

	safeArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)

	local buttons = {}
	local rng = Random.new()

	for i, tabName in ipairs(tabs) do
		local btnWrapper = Instance.new("Frame")
		btnWrapper.Name = tabName .. "Wrapper"
		btnWrapper.BackgroundTransparency = 1
		btnWrapper.LayoutOrder = i
		table.insert(btnWrappers, btnWrapper)

		local btnShadow = Instance.new("Frame")
		btnShadow.Name = "Shadow"
		btnShadow.Size = UDim2.new(1, 0, 1, 0)
		btnShadow.Position = UDim2.new(0, 4, 0, 4)
		btnShadow.BackgroundColor3 = theme.Shadow
		btnShadow.Parent = btnWrapper

		local shadowCorner = Instance.new("UICorner")
		shadowCorner.CornerRadius = UDim.new(0, 2)
		shadowCorner.Parent = btnShadow

		local btnMover = Instance.new("Frame")
		btnMover.Name = "Mover"
		btnMover.Size = UDim2.new(1, 0, 1, 0)
		btnMover.Position = UDim2.new(0, 0, 0, 0)
		btnMover.BackgroundTransparency = 1
		btnMover.Parent = btnWrapper

		local btnBg = Instance.new("Frame")
		btnBg.Name = "Background"
		btnBg.Size = UDim2.new(1, 0, 1, 0)
		btnBg.BackgroundColor3 = Color3.new(1, 1, 1)
		btnBg.Parent = btnMover

		local btnGradient = Instance.new("UIGradient")
		btnGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, theme.BtnStart),
			ColorSequenceKeypoint.new(1, theme.BtnEnd)
		}
		btnGradient.Rotation = 45
		btnGradient.Parent = btnBg

		local bgCorner = Instance.new("UICorner")
		bgCorner.CornerRadius = UDim.new(0, 2)
		bgCorner.Parent = btnBg

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = theme.GoldLight
		btnStroke.Thickness = 2
		btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		btnStroke.Parent = btnBg

		local btn = Instance.new("TextButton")
		btn.Name = tabName .. "Button"
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = string.upper(tabName)
		btn.TextColor3 = theme.Text
		btn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Heavy)
		btn.TextScaled = true
		btn.Parent = btnMover

		local textConstraint = Instance.new("UITextSizeConstraint")
		textConstraint.MaxTextSize = 22
		textConstraint.MinTextSize = 10
		textConstraint.Parent = btn

		local hoverInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local enterTweenColor = TweenService:Create(btnStroke, hoverInfo, {Color = theme.GoldDark})
		local enterTweenText = TweenService:Create(btn, hoverInfo, {TextColor3 = theme.GoldLight})

		local leaveTweenColor = TweenService:Create(btnStroke, hoverInfo, {Color = theme.GoldLight})
		local leaveTweenText = TweenService:Create(btn, hoverInfo, {TextColor3 = theme.Text})

		btn.MouseEnter:Connect(function()
			local randomTilt = rng:NextInteger(-2, 2)

			TweenService:Create(btnMover, hoverInfo, {Position = UDim2.new(0, -2, 0, -2), Rotation = randomTilt}):Play()
			TweenService:Create(btnShadow, hoverInfo, {Position = UDim2.new(0, 6, 0, 6)}):Play()
			enterTweenColor:Play()
			enterTweenText:Play()
		end)

		btn.MouseLeave:Connect(function()
			TweenService:Create(btnMover, hoverInfo, {Position = UDim2.new(0, 0, 0, 0), Rotation = 0}):Play()
			TweenService:Create(btnShadow, hoverInfo, {Position = UDim2.new(0, 4, 0, 4)}):Play()
			leaveTweenColor:Play()
			leaveTweenText:Play()
		end)

		buttons[tabName] = btn
	end

	task.defer(updateLayout)

	return contentFrame, buttons
end

return UIBase