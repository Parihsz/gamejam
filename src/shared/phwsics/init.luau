--!optimize 2

local BallParent = Instance.new('Folder',workspace)

local Physics = {}

local Ball = {}
local Balls = {}

local Debug = Instance.new('Folder',workspace)
Debug.Name = 'Debug'

local function drawLine(startVector, endVector, color)
    local size = (startVector - endVector).Magnitude
    if size > 250 then
        endVector = startVector + (endVector - startVector).Unit * 250
    end
	local linePart = Instance.new("Part")
	linePart.Size = Vector3.new(0.2, 0.2, (startVector - endVector).Magnitude)
	linePart.Anchored = true
	linePart.CanCollide = false
    linePart.Transparency = 0.5
	linePart.Material = Enum.Material.Neon
	linePart.Position = (startVector + endVector) / 2

	local rotation = CFrame.lookAt(startVector + (endVector - startVector) / 2, endVector)
	linePart.CFrame = rotation

	linePart.BrickColor = color or BrickColor.new("Bright red")

	linePart.Parent = Debug
end

function Physics.newBall(pos,size)
    local self = table.clone(Ball)
    self.size = size
    self.position = pos
    self.velocity = Vector3.new()
    self.acceleration = Vector3.new()
    self.gravity = Vector3.new(0, -9.81, 0)
    self.rotation = CFrame.new()
    local part = Instance.new('Part',BallParent)
    part.Size = vector.one*size*2
    part.Position = self.position
    part.Anchored = true
    part.Shape = Enum.PartType.Ball
    part.Position = pos
    self.part = part
    Balls[self.part] = self
    return self
end

local function castRay(ball:ball,dir,mag,params)
    dir = dir.unit
    if dir ~= dir then
        return nil
    end
    local shapeResult = workspace:Shapecast(ball.part,dir*mag,params)
    if shapeResult then
        return shapeResult,true
    end
    local size = ball.size
    local rayResult = workspace:Raycast(ball.position,dir*(mag)+dir*size,params)
    if rayResult then
        return rayResult,false
    end
    return nil
end

function Ball:step()
    Debug:ClearAllChildren()
    self.position = self.part.Position
    local dt = 1/60
    self = self ::ball
    local Part = self.part
    local params = OverlapParams.new()
    params.FilterDescendantsInstances = {BallParent}
    params.FilterType = Enum.RaycastFilterType.Include

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Part}


    self.velocity = self.velocity + self.acceleration + self.gravity*dt

    local position = self.position
    local velocity = self.velocity
    local magnitude = velocity.Magnitude
    local size = self.size
    local checkDist = math.max(size,magnitude*dt)
    local collisions = workspace:GetPartsInPart(self.part,params)
    if #collisions > 0 then
        for _,part in pairs(collisions) do
            local ball = Balls[part]
            if ball == self then
                continue
            end
            local distance = (part.Position - position).Magnitude
            local direction = (part.Position - position).unit
            self.velocity = self.velocity - direction * 0.5
            ball.velocity = ball.velocity + direction * 0.5
        end
    end

    local floor = false
    local friction = 0.05


    if velocity.y <= 0 then
        local floorRay,useShape = castRay(self,Vector3.new(0,-1,0),-self.velocity.Y*dt,rayParams)
        drawLine(self.position,self.position-Vector3.yAxis*checkDist)
        if floorRay then
            floor = floorRay.Instance

            if not Balls[floor] then
                if not useShape then
                    self.position = floorRay.Position + Vector3.new(0,size,0)
                end
                self.velocity = Vector3.new(velocity.X,-self.velocity.Y/2,velocity.Z)
            else
                self.velocity = Vector3.new(velocity.X,10,velocity.Z)
            end
        end
    end
    local ray = castRay(self, velocity, magnitude*dt,rayParams)
    drawLine(self.position,self.position+velocity*dt)
    if ray then
        local part = ray.Instance
        local ball = Balls[part]
        if ball then
            ball.velocity = ball.velocity + self.velocity
            self.velocity = -self.velocity/2
        elseif part ~=floor then
            local normal = ray.Normal
            local dot = velocity:Dot(normal)
            self.velocity = velocity - 1.5 * dot * normal
        end
    end

 
    -- Floor check
    if floor then
        local vx = self.velocity.X
        local vz = self.velocity.Z
        self.velocity = Vector3.new(vx*(1-friction),self.velocity.Y,vz*(1-friction))
    end

    local angularVelocity = self.velocity.magnitude / (size)
    local axisOfRotation = self.velocity.unit
    if axisOfRotation == axisOfRotation then
        local rotation = CFrame.fromAxisAngle(Vector3.new(axisOfRotation.Z,axisOfRotation.Y,axisOfRotation.X), angularVelocity * dt)
        self.rotation *= rotation
    end

    self.position = self.position + self.velocity*dt
    self.part.CFrame = CFrame.new(self.position) * self.rotation
end

function Ball:Destroy()
    self.part:Destroy()
    Balls[self.part] = nil
end

type ball = typeof(Physics.newBall(1))

function Physics.step()
    for _,ball in pairs(Balls) do
        ball:step()
    end
end

return Physics 