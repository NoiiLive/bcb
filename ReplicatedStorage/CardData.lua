-- @ScriptType: ModuleScript
local CardData = {
	Rarities = {
		Common = {Color = Color3.fromRGB(200, 200, 200), Value = 1},
		Rare = {Color = Color3.fromRGB(50, 150, 255), Value = 2},
		Epic = {Color = Color3.fromRGB(150, 50, 255), Value = 3},
		Legendary = {Color = Color3.fromRGB(255, 200, 0), Value = 4},
		Mythic = {Color = Color3.fromRGB(255, 50, 50), Value = 5}
	},
	Characters = {
		["Jonathan_Joestar_Phantom_Blood"] = {
			Name = "Jonathan Joestar",
			Title = "[Phantom Blood]",
			Rarity = "Legendary",
			BaseAttack = 50,
			BaseHealth = 200,
			BaseDefense = 30,
			GrowthAttack = 5,
			GrowthHealth = 20,
			GrowthDefense = 3,
			ImageId = "rbxassetid://6212362668"
		}
	}
}
return CardData