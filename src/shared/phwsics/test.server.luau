do
    return
end

local physics = require(script.Parent)

local ball = physics.newBall(Vector3.new(0, 50, 0),10)
local ball2 = physics.newBall(Vector3.new(100, 30, 0),10)
local ball3 = physics.newBall(Vector3.new(150, 40, 0),10)
-- ball.velocity = Vector3.new(40, 0, 0)
-- ball3.velocity = Vector3.new(-10, 0, 0)

while task.wait() do
    physics.step()
end
