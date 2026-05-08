-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local UIBase = require(Modules:WaitForChild("UIBase"))
local CollectionTab = require(Modules:WaitForChild("CollectionTab"))
local DrawsTab = require(Modules:WaitForChild("DrawsTab"))
local CardData = require(ReplicatedStorage:WaitForChild("CardData"))

local contentFrame, navButtons = UIBase.init()
local currentTab = nil

local collectionUI = CollectionTab.Create(contentFrame)
local drawsUI = DrawsTab.Create(contentFrame)
local collectionData = {}
local activeSort = "Rarity"
local selectedCardId = nil
local activePackId = nil
local isDrawing = false

local getCollectionRemote = ReplicatedStorage:WaitForChild("GetCollectionData")
local actionRemote = ReplicatedStorage:WaitForChild("CollectionAction")
local drawRemote = ReplicatedStorage:WaitForChild("DrawPack")

for id, btn in pairs(drawsUI.PackButtons) do
	if btn:GetAttribute("IsActive") then
		activePackId = id
	end
	btn.MouseButton1Click:Connect(function()
		activePackId = id
	end)
end

local function GetFormattedImage(imageId)
	local idStr = tostring(imageId)
	local extractedNum = string.match(idStr, "%d+")
	if extractedNum then
		return "rbxthumb://type=Asset&id=" .. extractedNum .. "&w=150&h=150"
	end
	return idStr
end

local function UpdateSortHighlight()
	for sortName, btn in pairs(collectionUI.SortButtons) do
		local stroke = btn.Parent.Background.UIStroke
		if sortName == activeSort then
			btn:SetAttribute("IsActive", true)
			stroke.Color = Color3.fromRGB(255, 225, 60)
			btn.TextColor3 = Color3.fromRGB(255, 225, 60)
		else
			btn:SetAttribute("IsActive", false)
			stroke.Color = Color3.fromRGB(180, 150, 15)
			btn.TextColor3 = Color3.fromRGB(255, 250, 255)
		end
	end
end

local function UpdateDisplay(charId, pData)
	local cData = CardData.Characters[charId]
	if not cData then return end

	selectedCardId = charId

	local favPrefix = pData.Favorited and '<font color="#FFD700">★</font> ' or ""
	collectionUI.Display.Name.Text = favPrefix .. string.upper(cData.Name)

	collectionUI.Display.Icon.Image = GetFormattedImage(cData.ImageId)
	collectionUI.Display.Level.Text = "LV. " .. tostring(pData.Level)

	local currentAtk = cData.BaseAttack + (cData.GrowthAttack * (pData.Level - 1))
	local currentHp = cData.BaseHealth + (cData.GrowthHealth * (pData.Level - 1))
	local currentDef = cData.BaseDefense + (cData.GrowthDefense * (pData.Level - 1))

	collectionUI.Display.Attack.Text = tostring(currentAtk)
	collectionUI.Display.Health.Text = tostring(currentHp)
	collectionUI.Display.Defense.Text = tostring(currentDef)

	collectionUI.Display.ExpFill.Size = UDim2.new(0, 0, 1, 0)

	if pData.Favorited then
		collectionUI.ActionButtons["Favorite"].TextColor3 = Color3.fromRGB(255, 215, 0)
	else
		collectionUI.ActionButtons["Favorite"].TextColor3 = Color3.fromRGB(255, 250, 255)
	end
end

local function GetSortedKeys()
	local keys = {}
	for charId, _ in pairs(collectionData) do
		table.insert(keys, charId)
	end

	table.sort(keys, function(a, b)
		local cDataA = CardData.Characters[a]
		local cDataB = CardData.Characters[b]
		local pDataA = collectionData[a]
		local pDataB = collectionData[b]

		if activeSort == "Favorites" then
			if pDataA.Favorited ~= pDataB.Favorited then
				return pDataA.Favorited
			end
		elseif activeSort == "Level" then
			if pDataA.Level ~= pDataB.Level then
				return pDataA.Level > pDataB.Level
			end
		elseif activeSort == "Power" then
			local pwrA = cDataA.BaseAttack + (cDataA.GrowthAttack * (pDataA.Level - 1))
			local pwrB = cDataB.BaseAttack + (cDataB.GrowthAttack * (pDataB.Level - 1))
			if pwrA ~= pwrB then
				return pwrA > pwrB
			end
		elseif activeSort == "Name" then
			return cDataA.Name < cDataB.Name
		end

		local valA = CardData.Rarities[cDataA.Rarity].Value
		local valB = CardData.Rarities[cDataB.Rarity].Value
		if valA ~= valB then
			return valA > valB
		end

		if pDataA.Level ~= pDataB.Level then
			return pDataA.Level > pDataB.Level
		end
		return cDataA.Name < cDataB.Name
	end)

	return keys
end

local function RenderCollection()
	for _, child in ipairs(collectionUI.CardGrid:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local sortedKeys = GetSortedKeys()

	for _, charId in ipairs(sortedKeys) do
		local pData = collectionData[charId]
		local cData = CardData.Characters[charId]
		if cData then
			local cardWrapper = CollectionTab.CreateCardElement(collectionUI.CardGrid, cData, pData)
			cardWrapper.Mover.Interact.MouseButton1Click:Connect(function()
				UpdateDisplay(charId, pData)
			end)
		end
	end
end

local function LoadCollection()
	local data = getCollectionRemote:InvokeServer()
	if not data then return end
	collectionData = data.Collection
	UpdateSortHighlight()
	RenderCollection()
end

local function switchTab(tabName)
	if currentTab == tabName then return end
	currentTab = tabName

	collectionUI.MainContainer.Visible = (tabName == "Collection")
	drawsUI.MainContainer.Visible = (tabName == "Draws")

	if tabName == "Collection" and not next(collectionData) then
		LoadCollection()
	end
end

local function ShowDrawPopup(pulledIds)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local popupScreen = Instance.new("ScreenGui")
	popupScreen.Name = "DrawPopup"
	popupScreen.DisplayOrder = 100
	popupScreen.IgnoreGuiInset = true
	popupScreen.Parent = playerGui

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(15, 5, 25)
	bg.BackgroundTransparency = 0.1
	bg.Active = true
	bg.Parent = popupScreen

	local tapContainer = Instance.new("Frame")
	tapContainer.Size = UDim2.new(1, 0, 1, 0)
	tapContainer.BackgroundTransparency = 1
	tapContainer.Parent = bg

	local cardBack = Instance.new("TextButton")
	cardBack.Name = "CardBack"
	cardBack.Size = UDim2.new(0, 200, 0, 280)
	cardBack.Position = UDim2.new(0.5, 0, 0.5, 0)
	cardBack.AnchorPoint = Vector2.new(0.5, 0.5)
	cardBack.Text = ""
	cardBack.BackgroundColor3 = Color3.fromRGB(45, 10, 60)
	cardBack.Parent = tapContainer

	local cbCorner = Instance.new("UICorner")
	cbCorner.CornerRadius = UDim.new(0, 10)
	cbCorner.Parent = cardBack

	local cbStroke = Instance.new("UIStroke")
	cbStroke.Color = Color3.fromRGB(180, 150, 15)
	cbStroke.Thickness = 5
	cbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	cbStroke.Parent = cardBack

	local innerStrokeFrame = Instance.new("Frame")
	innerStrokeFrame.Size = UDim2.new(1, -24, 1, -24)
	innerStrokeFrame.Position = UDim2.new(0, 12, 0, 12)
	innerStrokeFrame.BackgroundTransparency = 1
	innerStrokeFrame.Parent = cardBack

	local innerCorner = Instance.new("UICorner")
	innerCorner.CornerRadius = UDim.new(0, 6)
	innerCorner.Parent = innerStrokeFrame

	local innerStroke = Instance.new("UIStroke")
	innerStroke.Color = Color3.fromRGB(255, 225, 60)
	innerStroke.Thickness = 2
	innerStroke.Parent = innerStrokeFrame

	local diamond = Instance.new("Frame")
	diamond.Size = UDim2.new(0, 60, 0, 60)
	diamond.Position = UDim2.new(0.5, 0, 0.5, 0)
	diamond.AnchorPoint = Vector2.new(0.5, 0.5)
	diamond.BackgroundColor3 = Color3.fromRGB(255, 225, 60)
	diamond.BackgroundTransparency = 0.5
	diamond.Rotation = 45
	diamond.Parent = cardBack

	local cbLabel = Instance.new("TextLabel")
	cbLabel.Size = UDim2.new(1, 0, 1, 0)
	cbLabel.BackgroundTransparency = 1
	cbLabel.Text = "TAP"
	cbLabel.TextColor3 = Color3.fromRGB(255, 250, 255)
	cbLabel.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Heavy)
	cbLabel.TextSize = 36
	cbLabel.ZIndex = 2
	cbLabel.Parent = cardBack

	local taps = 0
	local rng = Random.new()

	local resultsContainer = Instance.new("Frame")
	resultsContainer.Size = UDim2.new(1, 0, 1, 0)
	resultsContainer.BackgroundTransparency = 1
	resultsContainer.Visible = false
	resultsContainer.Parent = bg

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 80)
	title.Position = UDim2.new(0, 0, 0.05, 0)
	title.BackgroundTransparency = 1
	title.Text = "PULL RESULTS"
	title.TextColor3 = Color3.fromRGB(255, 225, 60)
	title.FontFace = Font.fromName("Oswald", Enum.FontWeight.Heavy)
	title.TextSize = 60
	title.Parent = resultsContainer

	local gridFrame = Instance.new("ScrollingFrame")
	gridFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
	gridFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
	gridFrame.BackgroundTransparency = 1
	gridFrame.ScrollBarThickness = 6
	gridFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 225, 60)
	gridFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	gridFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	gridFrame.Parent = resultsContainer

	local gridPadding = Instance.new("UIPadding")
	gridPadding.PaddingTop = UDim.new(0, 15)
	gridPadding.PaddingBottom = UDim.new(0, 15)
	gridPadding.Parent = gridFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 160, 0, 225)
	gridLayout.CellPadding = UDim2.new(0, 20, 0, 20)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = gridFrame

	local continueBtn = Instance.new("TextButton")
	continueBtn.Size = UDim2.new(0, 200, 0, 60)
	continueBtn.Position = UDim2.new(0.5, -100, 0.85, 0)
	continueBtn.BackgroundColor3 = Color3.fromRGB(85, 15, 95)
	continueBtn.Text = "CONTINUE"
	continueBtn.TextColor3 = Color3.fromRGB(255, 250, 255)
	continueBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Heavy)
	continueBtn.TextSize = 24
	continueBtn.Parent = resultsContainer

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = continueBtn

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = Color3.fromRGB(255, 225, 60)
	btnStroke.Thickness = 2
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnStroke.Parent = continueBtn

	continueBtn.MouseButton1Click:Connect(function()
		popupScreen:Destroy()
	end)

	cardBack.MouseButton1Click:Connect(function()
		taps = taps + 1
		if taps < 3 then
			local shakeX = rng:NextInteger(-15, 15)
			local shakeY = rng:NextInteger(-15, 15)
			local rot = rng:NextInteger(-10, 10)

			local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, true)
			TweenService:Create(cardBack, tweenInfo, {
				Position = UDim2.new(0.5, shakeX, 0.5, shakeY),
				Rotation = rot,
				Size = UDim2.new(0, 220, 0, 308)
			}):Play()

			cbStroke.Color = Color3.fromRGB(255, 225, 60)
		else
			local flash = Instance.new("Frame")
			flash.Size = UDim2.new(1, 0, 1, 0)
			flash.BackgroundColor3 = Color3.new(1, 1, 1)
			flash.ZIndex = 10
			flash.Parent = bg

			tapContainer.Visible = false
			resultsContainer.Visible = true

			for i, charId in ipairs(pulledIds) do
				local cData = CardData.Characters[charId]
				if cData then
					local pDataMock = {Level = 1, Favorited = false}
					local cardEl = CollectionTab.CreateCardElement(gridFrame, cData, pDataMock)
					cardEl.LayoutOrder = i
					cardEl.Visible = true
				end
			end

			TweenService:Create(flash, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
			task.delay(0.5, function() flash:Destroy() end)
		end
	end)
end

for tabName, button in pairs(navButtons) do
	button.MouseButton1Click:Connect(function()
		switchTab(tabName)
	end)
end

for sortName, btn in pairs(collectionUI.SortButtons) do
	btn.MouseButton1Click:Connect(function()
		activeSort = sortName
		UpdateSortHighlight()
		RenderCollection()
	end)
end

collectionUI.ActionButtons["Favorite"].MouseButton1Click:Connect(function()
	if selectedCardId and collectionData[selectedCardId] then
		actionRemote:FireServer("Favorite", selectedCardId)
		collectionData[selectedCardId].Favorited = not collectionData[selectedCardId].Favorited
		RenderCollection()
		UpdateDisplay(selectedCardId, collectionData[selectedCardId])
	end
end)

drawsUI.DrawButtons["Open 1"].MouseButton1Click:Connect(function()
	if activePackId and not isDrawing then
		isDrawing = true
		local results = drawRemote:InvokeServer(activePackId, 1)
		if results and #results > 0 then
			LoadCollection()
			ShowDrawPopup(results)
		end
		isDrawing = false
	end
end)

drawsUI.DrawButtons["Open 10"].MouseButton1Click:Connect(function()
	if activePackId and not isDrawing then
		isDrawing = true
		local results = drawRemote:InvokeServer(activePackId, 10)
		if results and #results > 0 then
			LoadCollection()
			ShowDrawPopup(results)
		end
		isDrawing = false
	end
end)