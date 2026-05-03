-- @ScriptType: Script
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = DataStoreService:GetDataStore("PlayerCardData_v1")

local SessionData = {}

local RemoteFunction = Instance.new("RemoteFunction")
RemoteFunction.Name = "GetCollectionData"
RemoteFunction.Parent = ReplicatedStorage

local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "CollectionAction"
RemoteEvent.Parent = ReplicatedStorage

local function GenerateDefaultData()
	return {
		Collection = {
			["Jonathan_Joestar_Phantom_Blood"] = {
				Level = 1,
				Experience = 0,
				Shards = 0,
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

RemoteFunction.OnServerInvoke = function(player)
	return SessionData[player.UserId]
end

RemoteEvent.OnServerEvent:Connect(function(player, action, characterId)
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
		data.Collection[characterId].Shards = data.Collection[characterId].Shards + 1
	else
		data.Collection[characterId] = {
			Level = 1,
			Experience = 0,
			Shards = 0,
			Favorited = false
		}
	end
end

function ServerMain.GetPlayerData(player)
	return SessionData[player.UserId]
end

return ServerMain