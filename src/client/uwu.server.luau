local template = require(script.Parent.genewation.pwegenewated)

require(script.Parent.genewation).generate(template.CustomNoise)

local Shared = game:GetService("ReplicatedStorage").Shared
local Physics = require(Shared.phwsics)

local ball = Physics.newBall(Vector3.new(0, 100, 0),10)
local ball2 = Physics.newBall(Vector3.new(20, 100, 0),10)
local ball3 = Physics.newBall(Vector3.new(20, 150, 0),10)

workspace.CurrentCamera.CameraSubject = ball.part

local UIS = game:GetService("UserInputService")
while task.wait() do
    local Camera = workspace.CurrentCamera
    local RIGHT = Camera.CFrame.RightVector
    local FORWARD = Camera.CFrame.LookVector
    local ZERO = Vector3.new()

    local W = UIS:IsKeyDown(Enum.KeyCode.W) and FORWARD or ZERO
    local A = UIS:IsKeyDown(Enum.KeyCode.A) and -RIGHT or ZERO
    local S = UIS:IsKeyDown(Enum.KeyCode.S) and -FORWARD or ZERO
    local D = UIS:IsKeyDown(Enum.KeyCode.D)  and RIGHT or ZERO

    local dir = W + A + S + D
    if dir ~= Vector3.new() then
        ball.velocity += dir.unit*.5
    end

    Physics.step()
end