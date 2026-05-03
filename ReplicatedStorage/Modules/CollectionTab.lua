-- @ScriptType: ModuleScript
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CardData = require(ReplicatedStorage:WaitForChild("CardData"))

local CollectionTab = {}

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

local function GetFormattedImage(imageId)
	local idStr = tostring(imageId)
	local extractedNum = string.match(idStr, "%d+")
	if extractedNum then
		return "rbxthumb://type=Asset&id=" .. extractedNum .. "&w=150&h=150"
	end
	return idStr
end

local function CreateTextLabel(name, parent, text, size, position, fontName, weight, textColor)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.FontFace = Font.fromName(fontName, weight)
	label.TextColor3 = textColor or theme.Text
	label.TextScaled = true
	label.Parent = parent
	return label
end

local function CreateInteractiveButton(name, text, parentFrame, isGrid)
	local btnWrapper = Instance.new("Frame")
	btnWrapper.Name = name .. "Wrapper"
	btnWrapper.BackgroundTransparency = 1
	if not isGrid then
		btnWrapper.Size = UDim2.new(1, 0, 1, 0)
	end
	btnWrapper.Parent = parentFrame

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
	btnStroke.Color = theme.GoldDark
	btnStroke.Thickness = 2
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnStroke.Parent = btnBg

	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = string.upper(text)
	btn.TextColor3 = theme.Text
	btn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Heavy)

	btn.TextScaled = true
	btn.TextWrapped = true
	btn.Parent = btnMover

	local textConstraint = Instance.new("UITextSizeConstraint")
	textConstraint.MaxTextSize = 60
	textConstraint.MinTextSize = 1
	textConstraint.Parent = btn

	local btnPadding = Instance.new("UIPadding")
	btnPadding.PaddingLeft = UDim.new(0.05, 0)
	btnPadding.PaddingRight = UDim.new(0.05, 0)
	btnPadding.PaddingTop = UDim.new(0.05, 0)
	btnPadding.PaddingBottom = UDim.new(0.05, 0)
	btnPadding.Parent = btn

	local hoverInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local rng = Random.new()

	btn.MouseEnter:Connect(function()
		local tilt = rng:NextInteger(-1, 1)
		TweenService:Create(btnMover, hoverInfo, {Position = UDim2.new(0, -2, 0, -2), Rotation = tilt}):Play()
		TweenService:Create(btnShadow, hoverInfo, {Position = UDim2.new(0, 6, 0, 6)}):Play()
		TweenService:Create(btnStroke, hoverInfo, {Color = theme.GoldLight}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btnMover, hoverInfo, {Position = UDim2.new(0, 0, 0, 0), Rotation = 0}):Play()
		TweenService:Create(btnShadow, hoverInfo, {Position = UDim2.new(0, 4, 0, 4)}):Play()
		if not btn:GetAttribute("IsActive") then
			TweenService:Create(btnStroke, hoverInfo, {Color = theme.GoldDark}):Play()
		end
	end)

	return btn, btnWrapper
end

function CollectionTab.Create(parentGui)
	local mainContainer = Instance.new("Frame")
	mainContainer.Name = "CollectionMenu"
	mainContainer.Size = UDim2.new(1, 0, 1, 0)
	mainContainer.Position = UDim2.new(0, 0, 0, 0)
	mainContainer.BackgroundTransparency = 1
	mainContainer.Visible = false
	mainContainer.Parent = parentGui

	local leftPanel = Instance.new("Frame")
	leftPanel.Name = "LeftPanel"
	leftPanel.Size = UDim2.new(0.6, -10, 1, 0)
	leftPanel.Position = UDim2.new(0, 0, 0, 0)
	leftPanel.BackgroundColor3 = theme.BgStart
	leftPanel.BorderSizePixel = 0
	leftPanel.Parent = mainContainer

	local leftGradient = Instance.new("UIGradient")
	leftGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, theme.BarStart),
		ColorSequenceKeypoint.new(1, theme.BgStart)
	}
	leftGradient.Rotation = 45
	leftGradient.Parent = leftPanel

	local leftStroke = Instance.new("UIStroke")
	leftStroke.Color = theme.GoldDark
	leftStroke.Thickness = 2
	leftStroke.Parent = leftPanel

	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightPanel"
	rightPanel.Size = UDim2.new(0.4, -10, 1, 0)
	rightPanel.Position = UDim2.new(1, 0, 0, 0)
	rightPanel.AnchorPoint = Vector2.new(1, 0)
	rightPanel.BackgroundColor3 = theme.BgStart
	rightPanel.BorderSizePixel = 0
	rightPanel.Parent = mainContainer

	local rightGradient = Instance.new("UIGradient")
	rightGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, theme.BgEnd),
		ColorSequenceKeypoint.new(1, theme.BarEnd)
	}
	rightGradient.Rotation = 90
	rightGradient.Parent = rightPanel

	local rightStroke = Instance.new("UIStroke")
	rightStroke.Color = theme.GoldDark
	rightStroke.Thickness = 2
	rightStroke.Parent = rightPanel

	local rightPadding = Instance.new("UIPadding")
	rightPadding.PaddingTop = UDim.new(0, 15)
	rightPadding.PaddingBottom = UDim.new(0, 15)
	rightPadding.PaddingLeft = UDim.new(0, 15)
	rightPadding.PaddingRight = UDim.new(0, 15)
	rightPadding.Parent = rightPanel

	local rightLayout = Instance.new("UIListLayout")
	rightLayout.FillDirection = Enum.FillDirection.Vertical
	rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rightLayout.Padding = UDim.new(0, 10)
	rightLayout.Parent = rightPanel

	local sortContainer = Instance.new("Frame")
	sortContainer.Name = "SortContainer"
	sortContainer.Size = UDim2.new(1, -20, 0.08, 0)
	sortContainer.Position = UDim2.new(0, 10, 0.02, 0)
	sortContainer.BackgroundTransparency = 1
	sortContainer.Parent = leftPanel

	local sortLayout = Instance.new("UIListLayout")
	sortLayout.FillDirection = Enum.FillDirection.Horizontal
	sortLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sortLayout.Padding = UDim.new(0.02, 0)
	sortLayout.Parent = sortContainer

	local sorts = {"Rarity", "Level", "Name", "Power", "Favorites"}
	local sortButtons = {}

	for _, sortName in ipairs(sorts) do
		local container = Instance.new("Frame")
		container.Size = UDim2.new(0.18, 0, 1, 0)
		container.BackgroundTransparency = 1
		container.Parent = sortContainer

		local btn = CreateInteractiveButton("Sort_" .. sortName, sortName, container, false)
		sortButtons[sortName] = btn
	end

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "CardGrid"
	scrollFrame.Size = UDim2.new(1, -20, 0.88, 0)
	scrollFrame.Position = UDim2.new(0, 10, 0.11, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarImageColor3 = theme.GoldLight
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.Parent = leftPanel

	local gridPadding = Instance.new("UIPadding")
	gridPadding.PaddingTop = UDim.new(0, 10)
	gridPadding.PaddingLeft = UDim.new(0, 10)
	gridPadding.PaddingRight = UDim.new(0, 10)
	gridPadding.PaddingBottom = UDim.new(0, 10)
	gridPadding.Parent = scrollFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = scrollFrame

	scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local width = scrollFrame.AbsoluteSize.X
		if width > 0 then
			local cellWidth = math.clamp((width - 40) / 3, 90, 240)
			gridLayout.CellSize = UDim2.new(0, cellWidth, 0, cellWidth / 0.71)
		end
	end)

	local iconContainer = Instance.new("Frame")
	iconContainer.Name = "IconContainer"
	iconContainer.Size = UDim2.new(1, 0, 0.4, 0)
	iconContainer.BackgroundTransparency = 1
	iconContainer.LayoutOrder = 1
	iconContainer.Parent = rightPanel

	local displayIcon = Instance.new("ImageLabel")
	displayIcon.Name = "DisplayIcon"
	displayIcon.Size = UDim2.new(1, 0, 1, 0)
	displayIcon.BackgroundColor3 = theme.Shadow
	displayIcon.BackgroundTransparency = 0
	displayIcon.ScaleType = Enum.ScaleType.Fit
	displayIcon.ZIndex = 2
	displayIcon.Parent = iconContainer

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 4)
	iconCorner.Parent = displayIcon

	local iconStroke = Instance.new("UIStroke")
	iconStroke.Color = theme.GoldLight
	iconStroke.Thickness = 3
	iconStroke.Parent = displayIcon

	local infoContainer = Instance.new("Frame")
	infoContainer.Name = "InfoContainer"
	infoContainer.Size = UDim2.new(1, 0, 0.15, 0)
	infoContainer.BackgroundTransparency = 1
	infoContainer.LayoutOrder = 2
	infoContainer.Parent = rightPanel

	local displayName = CreateTextLabel("DisplayName", infoContainer, "SELECT A CARD", UDim2.new(1, 0, 0.45, 0), UDim2.new(0, 0, 0, 0), "Oswald", Enum.FontWeight.Heavy, theme.GoldLight)
	displayName.TextXAlignment = Enum.TextXAlignment.Center
	displayName.RichText = true

	local displayLevel = CreateTextLabel("DisplayLevel", infoContainer, "LV. 0", UDim2.new(1, 0, 0.25, 0), UDim2.new(0, 0, 0.5, 0), "Montserrat", Enum.FontWeight.Heavy, theme.Text)

	local expBg = Instance.new("Frame")
	expBg.Name = "ExpBackground"
	expBg.Size = UDim2.new(0.9, 0, 0.15, 0)
	expBg.Position = UDim2.new(0.05, 0, 0.8, 0)
	expBg.BackgroundColor3 = theme.Shadow
	expBg.Parent = infoContainer

	local expCorner = Instance.new("UICorner")
	expCorner.CornerRadius = UDim.new(1, 0)
	expCorner.Parent = expBg

	local expStroke = Instance.new("UIStroke")
	expStroke.Color = theme.GoldDark
	expStroke.Thickness = 1
	expStroke.Parent = expBg

	local expFill = Instance.new("Frame")
	expFill.Name = "ExpFill"
	expFill.Size = UDim2.new(0, 0, 1, 0)
	expFill.BackgroundColor3 = theme.BtnStart
	expFill.Parent = expBg

	local expFillCorner = Instance.new("UICorner")
	expFillCorner.CornerRadius = UDim.new(1, 0)
	expFillCorner.Parent = expFill

	local statsContainer = Instance.new("Frame")
	statsContainer.Name = "StatsContainer"
	statsContainer.Size = UDim2.new(0.9, 0, 0.1, 0)
	statsContainer.BackgroundTransparency = 1
	statsContainer.LayoutOrder = 3
	statsContainer.Parent = rightPanel

	local statsLayout = Instance.new("UIListLayout")
	statsLayout.FillDirection = Enum.FillDirection.Horizontal
	statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	statsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	statsLayout.Padding = UDim.new(0.02, 0)
	statsLayout.Parent = statsContainer

	local function CreateStatRow(statName, color)
		local block = Instance.new("Frame")
		block.Size = UDim2.new(0.32, 0, 1, 0)
		block.BackgroundTransparency = 1
		block.Parent = statsContainer

		local nameLabel = CreateTextLabel("Name", block, statName, UDim2.new(1, 0, 0.4, 0), UDim2.new(0, 0, 0, 0), "Montserrat", Enum.FontWeight.Heavy, theme.Text)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Center

		local valLabel = CreateTextLabel("Value", block, "0", UDim2.new(1, 0, 0.6, 0), UDim2.new(0, 0, 0.4, 0), "Oswald", Enum.FontWeight.Heavy, color)
		valLabel.TextXAlignment = Enum.TextXAlignment.Center

		return valLabel
	end

	local attackVal = CreateStatRow("ATTACK", Color3.fromRGB(255, 100, 100))
	local healthVal = CreateStatRow("HEALTH", Color3.fromRGB(100, 255, 100))
	local defenseVal = CreateStatRow("DEFENSE", Color3.fromRGB(100, 150, 255))

	local actionsContainer = Instance.new("Frame")
	actionsContainer.Name = "ActionsContainer"
	actionsContainer.Size = UDim2.new(1, 0, 0.25, 0)
	actionsContainer.BackgroundTransparency = 1
	actionsContainer.LayoutOrder = 4
	actionsContainer.Parent = rightPanel

	local actionsLayout = Instance.new("UIGridLayout")
	actionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	actionsLayout.CellSize = UDim2.new(0.46, 0, 0.28, 0) 
	actionsLayout.CellPadding = UDim2.new(0.04, 0, 0.05, 0)
	actionsLayout.Parent = actionsContainer

	local actionNames = {"Favorite", "Level Up", "Ascend", "Equip", "Details"}
	local actionButtons = {}

	for _, action in ipairs(actionNames) do
		local btn = CreateInteractiveButton("Action_" .. action, action, actionsContainer, true)
		actionButtons[action] = btn
	end

	local Elements = {
		MainContainer = mainContainer,
		CardGrid = scrollFrame,
		SortButtons = sortButtons,
		ActionButtons = actionButtons,
		Display = {
			Icon = displayIcon,
			Name = displayName,
			Level = displayLevel,
			ExpFill = expFill,
			Attack = attackVal,
			Health = healthVal,
			Defense = defenseVal
		}
	}

	return Elements
end

function CollectionTab.CreateCardElement(parent, charData, pData)
	local rarityData = CardData.Rarities[charData.Rarity] or CardData.Rarities.Common
	local rColor = rarityData.Color

	local wrapper = Instance.new("Frame")
	wrapper.Name = "CardWrapper_" .. charData.Name
	wrapper.BackgroundTransparency = 1
	wrapper.Parent = parent

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 0, 1, 0)
	shadow.Position = UDim2.new(0, 6, 0, 6)
	shadow.BackgroundColor3 = theme.Shadow
	shadow.ZIndex = 1
	shadow.Parent = wrapper

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 4)
	shadowCorner.Parent = shadow

	local mover = Instance.new("Frame")
	mover.Name = "Mover"
	mover.Size = UDim2.new(1, 0, 1, 0)
	mover.Position = UDim2.new(0, 0, 0, 0)
	mover.BackgroundTransparency = 1
	mover.ZIndex = 2
	mover.Parent = wrapper

	local cardBtn = Instance.new("TextButton")
	cardBtn.Name = "Interact"
	cardBtn.Size = UDim2.new(1, 0, 1, 0)
	cardBtn.Text = ""
	cardBtn.BackgroundColor3 = Color3.new(1, 1, 1)
	cardBtn.ZIndex = 3
	cardBtn.Parent = mover

	local cardGradient = Instance.new("UIGradient")
	cardGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, theme.BgStart),
		ColorSequenceKeypoint.new(1, theme.BarEnd)
	}
	cardGradient.Rotation = 90
	cardGradient.Parent = cardBtn

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 4)
	cardCorner.Parent = cardBtn

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = rColor
	cardStroke.Thickness = 4
	cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	cardStroke.Parent = cardBtn

	local innerStrokeContainer = Instance.new("Frame")
	innerStrokeContainer.Size = UDim2.new(1, 0, 1, 0)
	innerStrokeContainer.BackgroundTransparency = 1
	innerStrokeContainer.ZIndex = 6
	innerStrokeContainer.Parent = cardBtn

	local innerCorner = Instance.new("UICorner")
	innerCorner.CornerRadius = UDim.new(0, 4)
	innerCorner.Parent = innerStrokeContainer

	local innerStroke = Instance.new("UIStroke")
	innerStroke.Color = theme.Shadow
	innerStroke.Thickness = 2
	innerStroke.Parent = innerStrokeContainer

	local art = Instance.new("ImageLabel")
	art.Name = "Art"
	art.Size = UDim2.new(0.9, 0, 0.6, 0)
	art.Position = UDim2.new(0.05, 0, 0.05, 0)
	art.BackgroundTransparency = 1
	art.Image = GetFormattedImage(charData.ImageId)
	art.ScaleType = Enum.ScaleType.Fit
	art.ZIndex = 4
	art.Parent = cardBtn

	local textGradientOverlay = Instance.new("Frame")
	textGradientOverlay.Size = UDim2.new(1, 0, 0.4, 0)
	textGradientOverlay.Position = UDim2.new(0, 0, 0.6, 0)
	textGradientOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
	textGradientOverlay.BorderSizePixel = 0
	textGradientOverlay.ZIndex = 5
	textGradientOverlay.Parent = cardBtn

	local overlayCorner = Instance.new("UICorner")
	overlayCorner.CornerRadius = UDim.new(0, 4)
	overlayCorner.Parent = textGradientOverlay

	local overlayGradient = Instance.new("UIGradient")
	overlayGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, theme.Shadow),
		ColorSequenceKeypoint.new(1, theme.Shadow)
	}
	overlayGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 0.2),
		NumberSequenceKeypoint.new(1, 0)
	}
	overlayGradient.Rotation = 90
	overlayGradient.Parent = textGradientOverlay

	local topBadgeFrame = Instance.new("Frame")
	topBadgeFrame.Size = UDim2.new(1, 0, 0.12, 0)
	topBadgeFrame.Position = UDim2.new(0, 0, 0.02, 0)
	topBadgeFrame.BackgroundTransparency = 1
	topBadgeFrame.ZIndex = 6
	topBadgeFrame.Parent = cardBtn

	local lvlLabel = CreateTextLabel("Level", topBadgeFrame, tostring(pData.Level), UDim2.new(0, 30, 1, 0), UDim2.new(0, 8, 0, 0), "Oswald", Enum.FontWeight.Heavy, theme.Text)
	lvlLabel.TextXAlignment = Enum.TextXAlignment.Left

	local rarLabel = CreateTextLabel("Rarity", topBadgeFrame, string.sub(charData.Rarity, 1, 1), UDim2.new(0, 30, 1, 0), UDim2.new(1, -38, 0, 0), "Oswald", Enum.FontWeight.Heavy, rColor)
	rarLabel.TextXAlignment = Enum.TextXAlignment.Right

	local nameText = string.upper(charData.Name)
	if pData.Favorited then
		nameText = '<font color="#FFD700">★</font> ' .. nameText
	end

	local nameLabel = CreateTextLabel("Name", cardBtn, nameText, UDim2.new(0.9, 0, 0.18, 0), UDim2.new(0.05, 0, 0.62, 0), "Oswald", Enum.FontWeight.Heavy, theme.GoldLight)
	nameLabel.RichText = true
	nameLabel.TextWrapped = true
	nameLabel.ZIndex = 6

	local textConstraint = Instance.new("UITextSizeConstraint")
	textConstraint.MaxTextSize = 36
	textConstraint.MinTextSize = 1
	textConstraint.Parent = nameLabel

	local titleLabel = CreateTextLabel("Title", cardBtn, charData.Title, UDim2.new(0.9, 0, 0.12, 0), UDim2.new(0.05, 0, 0.8, 0), "Montserrat", Enum.FontWeight.SemiBold, theme.GoldDark)
	titleLabel.TextWrapped = true
	titleLabel.ZIndex = 6

	local titleConstraint = Instance.new("UITextSizeConstraint")
	titleConstraint.MaxTextSize = 24
	titleConstraint.MinTextSize = 1
	titleConstraint.Parent = titleLabel

	local hoverInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	cardBtn.MouseEnter:Connect(function()
		TweenService:Create(mover, hoverInfo, {Position = UDim2.new(0, -3, 0, -3)}):Play()
		TweenService:Create(shadow, hoverInfo, {Position = UDim2.new(0, 9, 0, 9)}):Play()
		TweenService:Create(cardStroke, hoverInfo, {Thickness = 6}):Play()
	end)

	cardBtn.MouseLeave:Connect(function()
		TweenService:Create(mover, hoverInfo, {Position = UDim2.new(0, 0, 0, 0)}):Play()
		TweenService:Create(shadow, hoverInfo, {Position = UDim2.new(0, 6, 0, 6)}):Play()
		TweenService:Create(cardStroke, hoverInfo, {Thickness = 4}):Play()
	end)

	return wrapper
end

return CollectionTab