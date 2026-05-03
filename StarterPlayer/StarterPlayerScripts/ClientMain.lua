-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local UIBase = require(Modules:WaitForChild("UIBase"))

local contentFrame, navButtons = UIBase.init()
local currentTab = nil

local function switchTab(tabName)
	if currentTab == tabName then return end
	currentTab = tabName
end

for tabName, button in pairs(navButtons) do
	button.MouseButton1Click:Connect(function()
		switchTab(tabName)
	end)
end