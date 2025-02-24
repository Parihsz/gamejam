local Init = {}

local powerups = {
	"Grow",
	"Shrink",
	"Speed",
	"Tank",
	"Strength",
}

task.spawn(function()
	while true do
		task.wait(8)
		local powerUp = powerups[math.random(1, #powerups)]
		local uwu = game.ReplicatedStorage.Powerups:FindFirstChild(powerUp):Clone()
		uwu.Parent = workspace.Powerups
		uwu.Position = Vector3.new(math.random(-10, 10), 45, math.random(-10, 10))

		task.delay(10, function()
			uwu:Destroy()
		end)
	end
end)

return Init
