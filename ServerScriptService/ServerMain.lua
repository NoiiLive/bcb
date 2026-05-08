-- @ScriptType: Script
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = DataStoreService:GetDataStore("PlayerCardData_v2")
local CardData = require(ReplicatedStorage:WaitForChild("CardData"))

local SessionData = {}

local GetCollectionRemote = Instance.new("RemoteFunction")
GetCollectionRemote.Name = "GetCollectionData"
GetCollectionRemote.Parent = ReplicatedStorage

local ActionRemote = Instance.new("RemoteEvent")
ActionRemote.Name = "CollectionAction"
ActionRemote.Parent = ReplicatedStorage

local DrawRemote = Instance.new("RemoteFunction")
DrawRemote.Name = "DrawPack"
DrawRemote.Parent = ReplicatedStorage

local function GenerateDefaultData()
	return {
		Collection = {
			["Jonathan_Joestar_Young"] = {
				Level = 1,
				Experience = 0,
				Copies = 0,
				Favorited = false
			}
		}
	}
end

local function PlayerAdded(player)
	local success, data = pcall(function()
		return PlayerData:GetAsync(tostring(player.UserId))
	end)

	if success and data then
		if data.Collection then
			for _, charData in pairs(data.Collection) do
				if charData.Shards and not charData.Copies then
					charData.Copies = charData.Shards
					charData.Shards = nil
				elseif not charData.Copies then
					charData.Copies = 0
				end
			end
		end
		SessionData[player.UserId] = data
	else
		SessionData[player.UserId] = GenerateDefaultData()
	end
end

local function PlayerRemoving(player)
	local data = SessionData[player.UserId]
	if data then
		pcall(function()
			PlayerData:SetAsync(tostring(player.UserId), data)
		end)
		SessionData[player.UserId] = nil
	end
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)

GetCollectionRemote.OnServerInvoke = function(player)
	return SessionData[player.UserId]
end

ActionRemote.OnServerEvent:Connect(function(player, action, characterId)
	local data = SessionData[player.UserId]
	if not data or not data.Collection[characterId] then return end

	if action == "Favorite" then
		data.Collection[characterId].Favorited = not data.Collection[characterId].Favorited
	end
end)

local ServerMain = {}

function ServerMain.AddCharacterCopy(player, characterId)
	local data = SessionData[player.UserId]
	if not data then return end

	if data.Collection[characterId] then
		if not data.Collection[characterId].Copies then
			data.Collection[characterId].Copies = data.Collection[characterId].Shards or 0
			data.Collection[characterId].Shards = nil
		end
		data.Collection[characterId].Copies = data.Collection[characterId].Copies + 1
	else
		data.Collection[characterId] = {
			Level = 1,
			Experience = 0,
			Copies = 0,
			Favorited = false
		}
	end
end

function ServerMain.GetPlayerData(player)
	return SessionData[player.UserId]
end

local function GetRandomRarity()
	local roll = math.random(1, 100)
	local cumulative = 0

	cumulative = cumulative + CardData.Rates.Mythic
	if roll <= cumulative then return "Mythic" end

	cumulative = cumulative + CardData.Rates.Legendary
	if roll <= cumulative then return "Legendary" end

	cumulative = cumulative + CardData.Rates.Epic
	if roll <= cumulative then return "Epic" end

	cumulative = cumulative + CardData.Rates.Rare
	if roll <= cumulative then return "Rare" end

	return "Common"
end

DrawRemote.OnServerInvoke = function(player, packName, amount)
	local data = SessionData[player.UserId]
	if not data then return {} end

	local pack = CardData.Packs[packName]
	if not pack then return {} end

	local pulledUnits = {}

	for i = 1, amount do
		local rarity = GetRandomRarity()
		local pool = pack.Pool[rarity]

		while not pool or #pool == 0 do
			if rarity == "Mythic" then rarity = "Legendary"
			elseif rarity == "Legendary" then rarity = "Epic"
			elseif rarity == "Epic" then rarity = "Rare"
			elseif rarity == "Rare" then rarity = "Common"
			else
				break
			end
			pool = pack.Pool[rarity]
		end

		if pool and #pool > 0 then
			local unitId = pool[math.random(1, #pool)]
			table.insert(pulledUnits, unitId)
			ServerMain.AddCharacterCopy(player, unitId)
		end
	end

	return pulledUnits
end

return ServerMain