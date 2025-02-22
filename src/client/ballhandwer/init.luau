local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Physics = require(ReplicatedStorage.phwsics)
local Serilizer = require(ReplicatedStorage.sewilizer)

local BallStorage = ReplicatedStorage:WaitForChild('BallReplication')


local Ball = {}
local Balls = {}

local PrimaryBall 
for _,child in BallStorage:GetChildren() do
    local id = tonumber(child.Name)
    local player = child.Value
    local ball = Physics.newBall(Vector3.new(), 5)
    ball.ID = id
    Balls[id] = ball
    if LocalPlayer == player then
        PrimaryBall = ball
        ball.isowner = true
    end
end


BallStorage.ChildAdded:Connect(function(child)
    local id = tonumber(child.Name)
    local player = child.Value
    local ball = Physics.newBall(Vector3.new(0,100,0), 5)
    ball.ID = id
    Balls[id] = ball
    if LocalPlayer == player then
        PrimaryBall = ball
        ball.isowner = true
    end
end)

BallStorage.ChildRemoved:Connect(function(child)
    local id = tonumber(child.Name)
    local ball = Balls[id]
    if ball then
        ball:Destroy()
        Balls[id] = nil
        if ball.isowner then
            PrimaryBall = nil
        end
    end
end)


local Unreliable:UnreliableRemoteEvent = ReplicatedStorage.repwciatebwall
local Reliable:RemoteEvent = ReplicatedStorage.repwciatebwallSafe
local Tasks:RemoteEvent = ReplicatedStorage.bwallTasks

Tasks.OnClientEvent:Connect(function(id,...)
    if not PrimaryBall then return end 
    if id == 'v' then
        PrimaryBall:applyVelocity(...)
    elseif id == 'p' then
        PrimaryBall:setPosition(...)
    end
end)

local Reader = Serilizer.newReader(buffer.create(1),0)
Reader:saveLocation()

local function readPacket(b:buffer)
    local size = buffer.len(b)
    Reader.buffer = b
    Reader.cursor = 0
    local time = Reader:readf64()
    while Reader.cursor < size do
        local ID = Reader:readuInt()
        local cframe = Reader:readCFrame()
        local velocity = Reader:readVector3()
        local ball = Balls[ID]
        local lastTime = ball.lasttime
        if ball.isowner and lastTime then continue end 
        lastTime = lastTime or 0
        if ball and time > lastTime then
            ball.lasttime = time
            --ball.rotation = cframe.Rotation
            ball.position = cframe.Position
            ball.velocity = velocity
        end
    end
end

Unreliable.OnClientEvent:Connect(readPacket)
Reliable.OnClientEvent:Connect(readPacket)

local Camera = workspace.CurrentCamera

RunService.Heartbeat:Connect(function()

    
    local RIGHT = Camera.CFrame.RightVector
    local FORWARD = Camera.CFrame.LookVector
    local ZERO = Vector3.new()
    task.spawn(function()
      task.wait(1)-- I do not know why this works
      if not PrimaryBall then return end 
      Camera.CameraSubject = PrimaryBall.part
    end)
    local W = UIS:IsKeyDown(Enum.KeyCode.W) and FORWARD or ZERO
    local A = UIS:IsKeyDown(Enum.KeyCode.A) and -RIGHT or ZERO
    local S = UIS:IsKeyDown(Enum.KeyCode.S) and -FORWARD or ZERO
    local D = UIS:IsKeyDown(Enum.KeyCode.D)  and RIGHT or ZERO

    local dir = W + A + S + D
    if PrimaryBall then 
        if UIS:IsKeyDown(Enum.KeyCode.Space) and PrimaryBall.floor then
            PrimaryBall:applyVelocity( Vector3.new(0, 10, 0))
        end
    end

    PrimaryBall.movedir = dir

    Physics.step()
    Reliable:FireServer(PrimaryBall.part.CFrame, PrimaryBall.velocity)
end)

return Ball