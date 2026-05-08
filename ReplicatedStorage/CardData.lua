-- @ScriptType: ModuleScript
local CardData = {
	Rates = {
		Mythic = 1,
		Legendary = 4,
		Epic = 15,
		Rare = 30,
		Common = 50
	},
	Rarities = {
		Common = {Color = Color3.fromRGB(200, 200, 200), Value = 1},
		Rare = {Color = Color3.fromRGB(50, 150, 255), Value = 2},
		Epic = {Color = Color3.fromRGB(150, 50, 255), Value = 3},
		Legendary = {Color = Color3.fromRGB(255, 200, 0), Value = 4},
		Mythic = {Color = Color3.fromRGB(255, 50, 50), Value = 5}
	},
	Packs = {
		["Standard"] = {
			Name = "Standard",
			Pool = {
				Common = {"Jonathan_Joestar_Young", "Dio_Brando_Young", "Cronin_Tattoo_Thug", "Doobie_Snake_Monster"},
				Rare = {"Wang_Chan_Poison_Dealer", "Tonpetty_Hamon_Master", "Dire_Thunder_Split", "Straizo_Noble_Monk", "Tarkus_Chained_Lion"},
				Epic = {"Dio_Brando_London", "Jonathan_Joestar_London", "Robert_E_O_Speedwagon_Ogre_Street", "Bruford_Luck"},
				Legendary = {"Erina_Pendleton_Sweet_Nurse", "Robert_E_O_Speedwagon_Loyal_Friend", "Will_A_Zeppeli_Baron"},
				Mythic = {"Jonathan_Joestar_Phantom_Blood", "Dio_Brando_Vampire_King"}
			}
		},
		["Phantom_Blood"] = {
			Name = "Phantom Blood",
			Pool = {
				Common = {"Jonathan_Joestar_Young", "Dio_Brando_Young", "Cronin_Tattoo_Thug", "Doobie_Snake_Monster"},
				Rare = {"Wang_Chan_Poison_Dealer", "Tonpetty_Hamon_Master", "Dire_Thunder_Split", "Straizo_Noble_Monk", "Tarkus_Chained_Lion"},
				Epic = {"Dio_Brando_London", "Jonathan_Joestar_London", "Robert_E_O_Speedwagon_Ogre_Street", "Bruford_Luck"},
				Legendary = {"Erina_Pendleton_Sweet_Nurse", "Robert_E_O_Speedwagon_Loyal_Friend", "Will_A_Zeppeli_Baron"},
				Mythic = {"Jonathan_Joestar_Phantom_Blood", "Dio_Brando_Vampire_King"}
			}
		}
	},
	Characters = {
		["Jonathan_Joestar_Young"] = {
			Name = "Jonathan Joestar",
			Title = "[Young]",
			Rarity = "Common",
			BaseAttack = 20,
			BaseHealth = 100,
			BaseDefense = 10,
			GrowthAttack = 2,
			GrowthHealth = 10,
			GrowthDefense = 1,
			ImageId = "rbxassetid://133580259782022"
		},
		["Dio_Brando_Young"] = {
			Name = "Dio Brando",
			Title = "[Young]",
			Rarity = "Common",
			BaseAttack = 22,
			BaseHealth = 95,
			BaseDefense = 8,
			GrowthAttack = 2,
			GrowthHealth = 9,
			GrowthDefense = 1,
			ImageId = "rbxassetid://103309200560294"
		},
		["Cronin_Tattoo_Thug"] = {
			Name = "Cronin",
			Title = "[Tattoo Thug]",
			Rarity = "Common",
			BaseAttack = 18,
			BaseHealth = 110,
			BaseDefense = 12,
			GrowthAttack = 2,
			GrowthHealth = 11,
			GrowthDefense = 1,
			ImageId = "rbxassetid://136749188252562"
		},
		["Doobie_Snake_Monster"] = {
			Name = "Doobie",
			Title = "[Snake Monster]",
			Rarity = "Common",
			BaseAttack = 24,
			BaseHealth = 90,
			BaseDefense = 9,
			GrowthAttack = 3,
			GrowthHealth = 9,
			GrowthDefense = 1,
			ImageId = "rbxassetid://94891343226734"
		},
		["Wang_Chan_Poison_Dealer"] = {
			Name = "Wang Chan",
			Title = "[Poison Dealer]",
			Rarity = "Rare",
			BaseAttack = 30,
			BaseHealth = 120,
			BaseDefense = 15,
			GrowthAttack = 3,
			GrowthHealth = 12,
			GrowthDefense = 2,
			ImageId = "rbxassetid://138766193953062"
		},
		["Tonpetty_Hamon_Master"] = {
			Name = "Tonpetty",
			Title = "[Hamon Master]",
			Rarity = "Rare",
			BaseAttack = 25,
			BaseHealth = 150,
			BaseDefense = 20,
			GrowthAttack = 2,
			GrowthHealth = 15,
			GrowthDefense = 2,
			ImageId = "rbxassetid://121478793671040"
		},
		["Dire_Thunder_Split"] = {
			Name = "Dire",
			Title = "[Thunder Split]",
			Rarity = "Rare",
			BaseAttack = 35,
			BaseHealth = 130,
			BaseDefense = 15,
			GrowthAttack = 4,
			GrowthHealth = 13,
			GrowthDefense = 1,
			ImageId = "rbxassetid://107703879088521"
		},
		["Straizo_Noble_Monk"] = {
			Name = "Straizo",
			Title = "[Noble Monk]",
			Rarity = "Rare",
			BaseAttack = 32,
			BaseHealth = 125,
			BaseDefense = 18,
			GrowthAttack = 3,
			GrowthHealth = 12,
			GrowthDefense = 2,
			ImageId = "rbxassetid://126639311220119"
		},
		["Tarkus_Chained_Lion"] = {
			Name = "Tarkus",
			Title = "[Chained Lion]",
			Rarity = "Rare",
			BaseAttack = 40,
			BaseHealth = 140,
			BaseDefense = 10,
			GrowthAttack = 4,
			GrowthHealth = 14,
			GrowthDefense = 1,
			ImageId = "rbxassetid://129599471747595"
		},
		["Dio_Brando_London"] = {
			Name = "Dio Brando",
			Title = "[London]",
			Rarity = "Epic",
			BaseAttack = 45,
			BaseHealth = 160,
			BaseDefense = 20,
			GrowthAttack = 4,
			GrowthHealth = 16,
			GrowthDefense = 2,
			ImageId = "rbxassetid://108597852793503"
		},
		["Jonathan_Joestar_London"] = {
			Name = "Jonathan Joestar",
			Title = "[London]",
			Rarity = "Epic",
			BaseAttack = 42,
			BaseHealth = 170,
			BaseDefense = 22,
			GrowthAttack = 4,
			GrowthHealth = 17,
			GrowthDefense = 2,
			ImageId = "rbxassetid://135870913280659"
		},
		["Robert_E_O_Speedwagon_Ogre_Street"] = {
			Name = "Robert E.O. Speedwagon",
			Title = "[Ogre Street]",
			Rarity = "Epic",
			BaseAttack = 38,
			BaseHealth = 150,
			BaseDefense = 18,
			GrowthAttack = 3,
			GrowthHealth = 15,
			GrowthDefense = 2,
			ImageId = "rbxassetid://137113584427217"
		},
		["Bruford_Luck"] = {
			Name = "Bruford",
			Title = "[Luck]",
			Rarity = "Epic",
			BaseAttack = 44,
			BaseHealth = 165,
			BaseDefense = 25,
			GrowthAttack = 4,
			GrowthHealth = 16,
			GrowthDefense = 3,
			ImageId = "rbxassetid://96132621343095"
		},
		["Erina_Pendleton_Sweet_Nurse"] = {
			Name = "Erina Pendleton",
			Title = "[Sweet Nurse]",
			Rarity = "Legendary",
			BaseAttack = 20,
			BaseHealth = 250,
			BaseDefense = 40,
			GrowthAttack = 2,
			GrowthHealth = 25,
			GrowthDefense = 4,
			ImageId = "rbxassetid://98080777814974"
		},
		["Robert_E_O_Speedwagon_Loyal_Friend"] = {
			Name = "Robert E.O. Speedwagon",
			Title = "[Loyal Friend]",
			Rarity = "Legendary",
			BaseAttack = 40,
			BaseHealth = 210,
			BaseDefense = 30,
			GrowthAttack = 4,
			GrowthHealth = 21,
			GrowthDefense = 3,
			ImageId = "rbxassetid://112239998649367"
		},
		["Will_A_Zeppeli_Baron"] = {
			Name = "Will A. Zeppeli",
			Title = "[Baron]",
			Rarity = "Legendary",
			BaseAttack = 55,
			BaseHealth = 180,
			BaseDefense = 25,
			GrowthAttack = 6,
			GrowthHealth = 18,
			GrowthDefense = 2,
			ImageId = "rbxassetid://104832250624185"
		},
		["Jonathan_Joestar_Phantom_Blood"] = {
			Name = "Jonathan Joestar",
			Title = "[Phantom Blood]",
			Rarity = "Mythic",
			BaseAttack = 70,
			BaseHealth = 250,
			BaseDefense = 40,
			GrowthAttack = 7,
			GrowthHealth = 25,
			GrowthDefense = 4,
			ImageId = "rbxassetid://79839958368225"
		},
		["Dio_Brando_Vampire_King"] = {
			Name = "Dio Brando",
			Title = "[Vampire King]",
			Rarity = "Mythic",
			BaseAttack = 75,
			BaseHealth = 230,
			BaseDefense = 35,
			GrowthAttack = 8,
			GrowthHealth = 23,
			GrowthDefense = 3,
			ImageId = "rbxassetid://129033601253368"
		}
	}
}
return CardData