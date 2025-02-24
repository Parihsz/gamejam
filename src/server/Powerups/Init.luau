local Init = {}

local RunService = game:GetService("RunService")

local Powerups = {}
local PowerupsFolder = script.Parent

function Init.Create(name: string, parent, position, time: number)
	local powerUpModule = require(PowerupsFolder:GetChildren():FindFirstChild(name))
	if not powerUpModule then
		return
	end

	local powerUp = powerUpModule.new()
	powerUp:Spawn(parent, position)

	Powerups[powerUp.Part] = powerUp
end

return Init
