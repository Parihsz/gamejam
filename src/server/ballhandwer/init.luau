local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")

local Physics = require(ReplicatedStorage.phwsics)
local Serilizer = require(ReplicatedStorage.sewilizer)

local BallStorage = Instance.new("Folder", ReplicatedStorage)
BallStorage.Name = "BallReplication"
local BallHolder = require(ReplicatedStorage.ballHolder)

local Spawns = workspace:WaitForChild("SpawnLocations")

local IDS = {}
local COUNT = 0

local function pop()
	local id = table.remove(IDS)
	if id then
		return id
	end
	COUNT += 1
	return COUNT
end

local function push(id)
	task.delay(5, table.insert, IDS, id)
end

local Ball = {}
local Balls = {}

function Ball.remove(ball: Physics.ball)
	Balls[ball.ID] = nil
	BallHolder.removeBall(ball)
    ball.objectValue:Destroy()
	push(ball.ID)
	ball:Destroy()
end

function Ball.new(player: Player?)
	local ID = pop()
    local lobby = workspace:WaitForChild("Lobby"):WaitForChild("Spawn")
	local Ball = Physics.newBall(lobby.Position, 5)
	local ObjectValue = Instance.new("ObjectValue", BallStorage)
	Balls[ID] = Ball
	Ball.player = player
	Ball.ID = ID
	ObjectValue.Name = ID
	ObjectValue.Value = player
	Ball.objectValue = ObjectValue
	if player then
		player:SetAttribute("BallID", ID)
	end
	BallHolder.addBall(Ball)
	return Ball
end

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.DevEnableMouseLock = false
	local b = Ball.new(player)
   -- b:setPosition(Spawns:GetChildren()[math.random(1, #Spawns:GetChildren())].Position)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    local ID = player:GetAttribute("BallID")
    local b = Balls[ID]
    if b then
        Ball.remove(b)
    end
end)

local Unreliable: UnreliableRemoteEvent = ReplicatedStorage.repwciatebwall
local Reliable: RemoteEvent = ReplicatedStorage.repwciatebwallSafe
local Tasks: RemoteEvent = ReplicatedStorage.bwallTasks
local abwitys:RemoteEvent = ReplicatedStorage.abwitys

local Writer = Serilizer.newWriter()
Writer:saveLocation()

Tasks.OnServerEvent:Connect(function(player, id, task, ...)
	local Ball = Balls[id]

	if not Ball then
		return
	end
	if task == "v" then
		Ball:applyVelocity(...)
	elseif task == "h" then
		Ball:increaseHits()
	end
end)

Reliable.OnServerEvent:Connect(function(player, cf, vel)
	local ID = player:GetAttribute("BallID")
	local Ball = Balls[ID]
	if Ball then
		Ball.part.CFrame = cf
		Ball.position = cf.Position
		Ball.velocity = vel
	end
end)

local Folder = workspace:FindFirstChild("Powerups") or Instance.new("Folder", workspace)
Folder.Name = "Powerups"

RunService.Heartbeat:Connect(function()
	Physics.step()
	for _, self in Balls do
		local pc = workspace.Powerups:GetChildren()
		for _, powerup in pc do
			if
				powerup:IsA("BasePart")
				and (self.part.position - powerup.Position).Magnitude
					< (self.part.size + powerup.Size).Magnitude / 2
			then
                if self.player then
                    abwitys:FireClient(self.player, powerup.Name)
                end
				table.insert(self.powerUps,powerup.Name)

				if powerup.Name == "Grow" then
					self:setSize(self.size * 1.5)

					task.delay(5, function()
						self:setSize(self.size / 1.5)
					end)
				elseif powerup.Name == "Speed" then
					self:setSpeed(self.speed * 2)

					task.delay(5, function()
						self:setSpeed(self.speed / 2)

                        local x = table.find(self.powerUps, "Speed")
                        if not x then return end 
                        table.remove(self.powerUps, x)
                        Tasks:FireAllClients(self.ID, "networkPowerups", self.powerUps)
					end)
				elseif powerup.Name == "Shrink" then
					self:setSize(self.size / 1.5)

					task.delay(5, function()
						self:setSize(self.size * 1.5)
					end)
				end

				Tasks:FireAllClients(self.ID, "networkPowerups", self.powerUps)

				task.delay(10, function()
                    local x = table.find(self.powerUps, powerup.Name)
                    if not x then return end 
					table.remove(self.powerUps, x)
					Tasks:FireAllClients(self.ID, "networkPowerups", self.powerUps)
				end)
				powerup:Destroy()
			end
		end
	end

	Writer:reuse()
	Writer:writef64(workspace:GetServerTimeNow())
	for ID, Ball in pairs(Balls) do -- 31 bytes per ball ~= 29 balls max for unreliables
		Ball.objectValue:SetAttribute("size", Ball.size)
		Writer:writeuInt(ID)
		Writer:writeCFrame(Ball.part.CFrame)
		Writer:writeVector3(Ball.velocity)
		Writer:writeuInt(Ball.hits)
	end
	local b = Writer:toBuffer()
	if buffer.len(b) > 900 then
		Reliable:FireAllClients(b)
		return
	end
	Unreliable:FireAllClients(b)
end)

return Ball
