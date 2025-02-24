local Init = {}

local powerups = {
	"Grow",
	"Shrink",
	"Speed",
	"Tank",
	"Strength",
}

local Running = false

function Init.stop()
	Running = false
	workspace.Powerups:ClearAllChildren()
end	

function Init.start()
	Running = true
end

local function spawn()
	local area = workspace:WaitForChild('AbilitySpawn')

		local min = area.Position - area.Size / 2
		local max = area.Position + area.Size / 2

		local randomX = math.random(min.X, max.X)
		local randomZ = math.random(min.Z, max.Z)

		local powerUp = powerups[math.random(1, #powerups)]
		local uwu = game.ReplicatedStorage.Assets.Powerups:FindFirstChild(powerUp):Clone()
		uwu.Parent = workspace.Powerups
		uwu.Position = Vector3.new(randomX, 45, randomZ)

		task.delay(10, function()
			uwu:Destroy()
		end)
end

task.spawn(function()
	while true do
		task.wait(8)
		if not Running then
			continue
		end
		spawn()
		spawn()
	end
end)

return Init
