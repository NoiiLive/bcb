-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local UIBase = require(Modules:WaitForChild("UIBase"))
local CollectionTab = require(Modules:WaitForChild("CollectionTab"))
local CardData = require(ReplicatedStorage:WaitForChild("CardData"))

local contentFrame, navButtons = UIBase.init()
local currentTab = nil

local collectionUI = CollectionTab.Create(contentFrame)
local collectionData = {}
local activeSort = "Rarity"
local selectedCardId = nil

local getCollectionRemote = ReplicatedStorage:WaitForChild("GetCollectionData")
local actionRemote = ReplicatedStorage:WaitForChild("CollectionAction")

local function GetFormattedImage(imageId)
	local idStr = tostring(imageId)
	local extractedNum = string.match(idStr, "%d+")
	if extractedNum then
		-- rbxthumb ensures Decal IDs render cleanly in ImageLabels
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

	if tabName == "Collection" and not next(collectionData) then
		LoadCollection()
	end
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