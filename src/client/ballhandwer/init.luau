local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Physics = require(ReplicatedStorage.phwsics)
local Serilizer = require(ReplicatedStorage.sewilizer)

local BallStorage = ReplicatedStorage:WaitForChild("BallReplication")
local BallHolder = require(ReplicatedStorage.ballHolder)

local Ball = {}
local Balls = {}

local PrimaryBall

local function CreateBall(child: ObjectValue)
	local id = tonumber(child.Name)
	local player = child.Value
	local size = child:GetAttribute("size") or 5
	local ball = Physics.newBall(Vector3.new(), size)
	ball.ID = id
	Balls[id] = ball
	if LocalPlayer == player then
		PrimaryBall = ball
		ball.isowner = true
	end

	ball.PlayerModel = player

	BallHolder.addBall(ball)

	local guid = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("BillboardGui"):Clone()
	guid.Parent = ball.part
	ball.text = guid.TextLabel
	ball.text.Text = `{player and player.Name .. "\n" or ""} Hits: {ball.hits}`
end

for _, child in BallStorage:GetChildren() do
	CreateBall(child)
end

BallStorage.ChildAdded:Connect(CreateBall)

BallStorage.ChildRemoved:Connect(function(child)
	local id = tonumber(child.Name)
	local ball = Balls[id]
	if ball then
		ball:Destroy()
		Balls[id] = nil
		if ball.isowner then
			PrimaryBall = nil
		end
		BallHolder.removeBall(ball)
		ball:Destroy()
	end
end)

local Unreliable: UnreliableRemoteEvent = ReplicatedStorage.repwciatebwall
local Reliable: RemoteEvent = ReplicatedStorage.repwciatebwallSafe
local Tasks: RemoteEvent = ReplicatedStorage.bwallTasks

Tasks.OnClientEvent:Connect(function(ball, id, ...)
	local myball = Balls[ball]
	if not myball then
		return
	end
	if id == "v" then
		myball:applyVelocity(...)
	elseif id == "p" then
		myball:setPosition(...)
	elseif id == "h" then
		myball:increaseHits()
	elseif id == "s" then
		myball:setSize(...)
	elseif id == "sp" then
		myball:setSpeed(...)
	elseif id == "networkPowerups" then
		myball.powerUps = ...
	end
end)

local Reader = Serilizer.newReader(buffer.create(1), 0)
Reader:saveLocation()

local function readPacket(b: buffer)
	local size = buffer.len(b)
	Reader.buffer = b
	Reader.cursor = 0
	local time = Reader:readf64()
	while Reader.cursor < size do
		local ID = Reader:readuInt()
		local cframe = Reader:readCFrame()
		local velocity = Reader:readVector3()
		local hits = Reader:readuInt()
		local ball = Balls[ID]
		local lastTime = ball.lasttime
		ball.hits = hits

		ball.text.Text = `{ball.PlayerModel and ball.PlayerModel.Name .. "\n" or ""} Hits: {hits}`
		if ball.isowner and lastTime then
			continue
		end
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

local function showPowerUps(ball:Physics.ball)
	local part = ball.part
	local powerups = ball.powerUps

	local hasSpeed = table.find(powerups, "Speed")
	local hasStrength = table.find(powerups, "Strength")
	local hasTank = table.find(powerups, "Tank")
	local Sphere:SelectionSphere = part:FindFirstChild("SelectionSphere") or Instance.new("SelectionSphere", part)
	Sphere.Adornee = part

	local hasPowerUp = hasSpeed or hasStrength or hasTank

	if hasSpeed then
		Sphere.Color3 = Color3.fromRGB(217, 255, 0)
		Sphere.SurfaceTransparency = 1
		Sphere.Transparency = 0.5
	elseif hasStrength then
		Sphere.Color3 = Color3.fromRGB(255, 0, 0)
		Sphere.SurfaceTransparency = 1
		Sphere.Transparency = 0.5
	elseif hasTank then
		Sphere.SurfaceColor3 = Color3.fromRGB(0, 238, 255)
		Sphere.SurfaceTransparency = 0.5
		Sphere.Transparency = 1
	end
	Sphere.Visible = hasPowerUp
end

local accumulator = 0
local FrameRate = 1/60
RunService.Heartbeat:Connect(function(dt)

	local Character = LocalPlayer.Character

	for _, ball in Balls do
		showPowerUps(ball)
	end

	if Character and Character.PrimaryPart then
		Character.PrimaryPart.Anchored = true
		Camera.CameraSubject = Character.PrimaryPart
	end

	local RIGHT = Camera.CFrame.RightVector * Vector3.new(1, 0, 1)
	local FORWARD = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
	local ZERO = Vector3.new()

	local W = UIS:IsKeyDown(Enum.KeyCode.W) and FORWARD or ZERO
	local A = UIS:IsKeyDown(Enum.KeyCode.A) and -RIGHT or ZERO
	local S = UIS:IsKeyDown(Enum.KeyCode.S) and -FORWARD or ZERO
	local D = UIS:IsKeyDown(Enum.KeyCode.D) and RIGHT or ZERO

	local dir = W + A + S + D

	PrimaryBall.movedir = dir

	accumulator+=dt
    while accumulator >= FrameRate do
        totalTime = 0
		Physics.step()
		Reliable:FireServer(PrimaryBall.part.CFrame, PrimaryBall.velocity)
        accumulator = accumulator - FrameRate
    end

end)

return Ball
