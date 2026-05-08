-- @ScriptType: ModuleScript
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CardData = require(ReplicatedStorage:WaitForChild("CardData"))

local DrawsTab = {}

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

function DrawsTab.Create(parentGui)
	local mainContainer = Instance.new("Frame")
	mainContainer.Name = "DrawsMenu"
	mainContainer.Size = UDim2.new(1, 0, 1, 0)
	mainContainer.Position = UDim2.new(0, 0, 0, 0)
	mainContainer.BackgroundTransparency = 1
	mainContainer.Visible = false
	mainContainer.Parent = parentGui

	local leftPanel = Instance.new("Frame")
	leftPanel.Name = "LeftPanel"
	leftPanel.Size = UDim2.new(0.25, -5, 1, 0)
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

	local leftPadding = Instance.new("UIPadding")
	leftPadding.PaddingTop = UDim.new(0, 15)
	leftPadding.PaddingBottom = UDim.new(0, 15)
	leftPadding.PaddingLeft = UDim.new(0, 15)
	leftPadding.PaddingRight = UDim.new(0, 15)
	leftPadding.Parent = leftPanel

	local leftTitle = CreateTextLabel("Title", leftPanel, "BANNERS", UDim2.new(1, 0, 0.08, 0), UDim2.new(0, 0, 0, 0), "Oswald", Enum.FontWeight.Heavy, theme.GoldLight)

	local packLayout = Instance.new("UIListLayout")
	packLayout.FillDirection = Enum.FillDirection.Vertical
	packLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	packLayout.Padding = UDim.new(0, 10)
	packLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local packContainer = Instance.new("ScrollingFrame")
	packContainer.Name = "PackContainer"
	packContainer.Size = UDim2.new(1, 0, 0.9, 0)
	packContainer.Position = UDim2.new(0, 0, 0.1, 0)
	packContainer.BackgroundTransparency = 1
	packContainer.ScrollBarThickness = 4
	packContainer.ScrollBarImageColor3 = theme.GoldLight
	packContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	packContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	packContainer.Parent = leftPanel

	local packContainerPadding = Instance.new("UIPadding")
	packContainerPadding.PaddingTop = UDim.new(0, 5)
	packContainerPadding.PaddingBottom = UDim.new(0, 5)
	packContainerPadding.PaddingLeft = UDim.new(0, 5)
	packContainerPadding.PaddingRight = UDim.new(0, 5)
	packContainerPadding.Parent = packContainer

	packLayout.Parent = packContainer

	local packs = {}
	for packId, packInfo in pairs(CardData.Packs) do
		table.insert(packs, {Id = packId, Name = packInfo.Name})
	end

	table.sort(packs, function(a, b)
		return a.Name < b.Name
	end)

	local packButtons = {}

	for i, packData in ipairs(packs) do
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 60)
		container.BackgroundTransparency = 1
		container.LayoutOrder = i
		container.Parent = packContainer

		local btn = CreateInteractiveButton("Pack_" .. string.gsub(packData.Name, " ", ""), packData.Name, container, false)
		btn:SetAttribute("PackId", packData.Id)
		packButtons[packData.Id] = btn
	end

	local centerPanel = Instance.new("Frame")
	centerPanel.Name = "CenterPanel"
	centerPanel.Size = UDim2.new(0.5, -10, 1, 0)
	centerPanel.Position = UDim2.new(0.25, 5, 0, 0)
	centerPanel.BackgroundTransparency = 1
	centerPanel.Parent = mainContainer

	local packVisual = Instance.new("Frame")
	packVisual.Name = "PackVisual"
	packVisual.Size = UDim2.new(0.6, 0, 0.65, 0)
	packVisual.Position = UDim2.new(0.2, 0, 0.05, 0)
	packVisual.BackgroundColor3 = theme.Shadow
	packVisual.Parent = centerPanel

	local visualCorner = Instance.new("UICorner")
	visualCorner.CornerRadius = UDim.new(0, 10)
	visualCorner.Parent = packVisual

	local visualStroke = Instance.new("UIStroke")
	visualStroke.Color = theme.GoldLight
	visualStroke.Thickness = 4
	visualStroke.Parent = packVisual

	local visualGradient = Instance.new("UIGradient")
	visualGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, theme.BgEnd),
		ColorSequenceKeypoint.new(1, theme.BtnEnd)
	}
	visualGradient.Rotation = 90
	visualGradient.Parent = packVisual

	local packTitle = CreateTextLabel("PackTitle", packVisual, packs[1] and string.upper(packs[1].Name) or "NONE", UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.4, 0), "Oswald", Enum.FontWeight.Heavy, theme.GoldLight)

	local actionContainer = Instance.new("Frame")
	actionContainer.Name = "ActionContainer"
	actionContainer.Size = UDim2.new(0.8, 0, 0.15, 0)
	actionContainer.Position = UDim2.new(0.1, 0, 0.75, 0)
	actionContainer.BackgroundTransparency = 1
	actionContainer.Parent = centerPanel

	local actionLayout = Instance.new("UIListLayout")
	actionLayout.FillDirection = Enum.FillDirection.Horizontal
	actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	actionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	actionLayout.Padding = UDim.new(0.05, 0)
	actionLayout.Parent = actionContainer

	local drawButtons = {}
	local draws = {"Open 1", "Open 10"}

	for _, drawType in ipairs(draws) do
		local container = Instance.new("Frame")
		container.Size = UDim2.new(0.45, 0, 1, 0)
		container.BackgroundTransparency = 1
		container.Parent = actionContainer

		local btn = CreateInteractiveButton("Draw_" .. string.gsub(drawType, " ", ""), drawType, container, false)
		drawButtons[drawType] = btn
	end

	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightPanel"
	rightPanel.Size = UDim2.new(0.25, -5, 1, 0)
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

	local rightTitle = CreateTextLabel("Title", rightPanel, "RATES", UDim2.new(1, 0, 0.08, 0), UDim2.new(0, 0, 0, 0), "Oswald", Enum.FontWeight.Heavy, theme.GoldLight)

	local ratesContainer = Instance.new("ScrollingFrame")
	ratesContainer.Name = "RatesContainer"
	ratesContainer.Size = UDim2.new(1, 0, 0.9, 0)
	ratesContainer.Position = UDim2.new(0, 0, 0.1, 0)
	ratesContainer.BackgroundTransparency = 1
	ratesContainer.ScrollBarThickness = 4
	ratesContainer.ScrollBarImageColor3 = theme.GoldLight
	ratesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	ratesContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ratesContainer.Parent = rightPanel

	local ratesContainerPadding = Instance.new("UIPadding")
	ratesContainerPadding.PaddingTop = UDim.new(0, 5)
	ratesContainerPadding.PaddingBottom = UDim.new(0, 5)
	ratesContainerPadding.PaddingLeft = UDim.new(0, 5)
	ratesContainerPadding.PaddingRight = UDim.new(0, 5)
	ratesContainerPadding.Parent = ratesContainer

	local ratesLayout = Instance.new("UIListLayout")
	ratesLayout.FillDirection = Enum.FillDirection.Vertical
	ratesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ratesLayout.Padding = UDim.new(0, 10)
	ratesLayout.Parent = ratesContainer

	local ratesData = {
		{Name = "Mythic", Rate = tostring(CardData.Rates.Mythic) .. "%"},
		{Name = "Legendary", Rate = tostring(CardData.Rates.Legendary) .. "%"},
		{Name = "Epic", Rate = tostring(CardData.Rates.Epic) .. "%"},
		{Name = "Rare", Rate = tostring(CardData.Rates.Rare) .. "%"},
		{Name = "Common", Rate = tostring(CardData.Rates.Common) .. "%"}
	}

	for _, rateInfo in ipairs(ratesData) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 30)
		row.BackgroundTransparency = 1
		row.Parent = ratesContainer

		local line = Instance.new("Frame")
		line.Size = UDim2.new(1, 0, 0, 2)
		line.Position = UDim2.new(0, 0, 1, -2)
		line.BackgroundColor3 = theme.GoldDark
		line.BackgroundTransparency = 0.5
		line.BorderSizePixel = 0
		line.Parent = row

		local rColor = CardData.Rarities[rateInfo.Name] and CardData.Rarities[rateInfo.Name].Color or theme.Text

		local nameLabel = CreateTextLabel("Name", row, string.upper(rateInfo.Name), UDim2.new(0.5, -20, 1, -5), UDim2.new(0, 20, 0, 0), "Montserrat", Enum.FontWeight.Heavy, rColor)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		local nameConstraint = Instance.new("UITextSizeConstraint")
		nameConstraint.MaxTextSize = 20
		nameConstraint.MinTextSize = 8
		nameConstraint.Parent = nameLabel

		local rateLabel = CreateTextLabel("Rate", row, rateInfo.Rate, UDim2.new(0.5, -20, 1, -5), UDim2.new(0.5, 0, 0, 0), "Oswald", Enum.FontWeight.Heavy, theme.Text)
		rateLabel.TextXAlignment = Enum.TextXAlignment.Right
		local rateConstraint = Instance.new("UITextSizeConstraint")
		rateConstraint.MaxTextSize = 20
		rateConstraint.MinTextSize = 8
		rateConstraint.Parent = rateLabel
	end

	local function updateLayout()
		local camera = workspace.CurrentCamera
		if not camera then return end
		local viewport = camera.ViewportSize
		local sw = viewport.X
		local sh = viewport.Y
		if sw == 0 or sh == 0 then return end

		local isPortrait = sw < sh

		if isPortrait then
			centerPanel.Size = UDim2.new(1, 0, 0.5, -5)
			centerPanel.Position = UDim2.new(0, 0, 0, 0)

			leftPanel.Size = UDim2.new(0.5, -5, 0.5, 0)
			leftPanel.Position = UDim2.new(0, 0, 0.5, 5)

			rightPanel.Size = UDim2.new(0.5, -5, 0.5, 0)
			rightPanel.Position = UDim2.new(1, 0, 0.5, 5)
			rightPanel.AnchorPoint = Vector2.new(1, 0)

			packVisual.Size = UDim2.new(0.8, 0, 0.7, 0)
			packVisual.Position = UDim2.new(0.1, 0, 0.05, 0)
			actionContainer.Size = UDim2.new(0.9, 0, 0.15, 0)
			actionContainer.Position = UDim2.new(0.05, 0, 0.8, 0)
		else
			leftPanel.Size = UDim2.new(0.25, -5, 1, 0)
			leftPanel.Position = UDim2.new(0, 0, 0, 0)

			rightPanel.Size = UDim2.new(0.25, -5, 1, 0)
			rightPanel.Position = UDim2.new(1, 0, 0, 0)
			rightPanel.AnchorPoint = Vector2.new(1, 0)

			centerPanel.Size = UDim2.new(0.5, -10, 1, 0)
			centerPanel.Position = UDim2.new(0.25, 5, 0, 0)

			packVisual.Size = UDim2.new(0.6, 0, 0.65, 0)
			packVisual.Position = UDim2.new(0.2, 0, 0.05, 0)
			actionContainer.Size = UDim2.new(0.8, 0, 0.15, 0)
			actionContainer.Position = UDim2.new(0.1, 0, 0.75, 0)
		end
	end

	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLayout)
	task.defer(updateLayout)

	local Elements = {
		MainContainer = mainContainer,
		PackButtons = packButtons,
		DrawButtons = drawButtons,
		Display = {
			Title = packTitle
		}
	}

	for pId, btn in pairs(packButtons) do
		btn.MouseButton1Click:Connect(function()
			local pName = CardData.Packs[pId].Name
			packTitle.Text = string.upper(pName)
			for loopId, pBtn in pairs(packButtons) do
				local stroke = pBtn.Parent.Background.UIStroke
				if loopId == pId then
					pBtn:SetAttribute("IsActive", true)
					stroke.Color = theme.GoldLight
					pBtn.TextColor3 = theme.GoldLight
				else
					pBtn:SetAttribute("IsActive", false)
					stroke.Color = theme.GoldDark
					pBtn.TextColor3 = theme.Text
				end
			end
		end)
	end

	local firstId = packs[1] and packs[1].Id
	if firstId and packButtons[firstId] then
		packButtons[firstId]:SetAttribute("IsActive", true)
		packButtons[firstId].Parent.Background.UIStroke.Color = theme.GoldLight
		packButtons[firstId].TextColor3 = theme.GoldLight
	end

	return Elements
end

return DrawsTab