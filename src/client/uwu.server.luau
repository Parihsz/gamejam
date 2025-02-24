local template = require(script.Parent.genewation.pwegenewated)
local Shared = game:GetService("ReplicatedStorage").Shared
local Replication = require(script.Parent.ballhandwer)
local Physics = require(Shared:WaitForChild("phwsics"))


require(script.Parent.genewation)


local LocalPlayer = game:GetService("Players").LocalPlayer
local Assets = Shared.Parent:WaitForChild("Assets")
local AbilityRecieve = Assets:WaitForChild("AbilityReceive"):Clone()
AbilityRecieve.Parent = LocalPlayer.PlayerGui

local Sprint = Assets:WaitForChild("Sprint")
Sprint.Parent = LocalPlayer.PlayerGui


