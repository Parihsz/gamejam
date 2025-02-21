---!optimize 2
local genewation = {}

local RunService = game:GetService("RunService")
local AssetService = game:GetService("AssetService")
local GreedyMesh = require(script.gweedymesh)
local EditableMesh = AssetService:CreateEditableMesh()
local MeshPart 

local GenerationFolder = Instance.new("Folder",workspace)
GenerationFolder.Name = "Generation"

local GenerationParts = {}
local CenterPart 

local Noise = require(script.noisyrawr)
local Ocean = require(script.wavesuwu)

local PART_SIZE = 4
local WAVE_SPEED = 1/4

local plane = Ocean.create_plane(40, 40)
local vertices = {}
local waves = {
	Ocean.create_wave(vector.create(0.2, 0, 0), .7),
	Ocean.create_wave(vector.create(0, 0, 1), .67),
	Ocean.create_wave(vector.create(0.5, 0, 0.5), 0.7),
    -- Ocean.create_wave(vector.create(1, 0, 0), .77),
}
local baseWaves = table.clone(waves)
do
    for i ,wave in waves do
        baseWaves = table.clone(wave)
    end
end


local function createPart()
    local part = Instance.new("Part")
    part.Size = Vector3.new(1,1,1)*PART_SIZE
    part.CFrame = CFrame.new(0,-1000000000,0)
    part.Anchored = true
    part.Parent = GenerationFolder
    return part
end

local PartCache = {}
task.spawn(function()
    local s = os.clock()
    for i = 1, 1000 do
        if os.clock()-s > 0.0014 then
            task.wait()
            s = os.clock()
        end
        table.insert(PartCache,createPart())
    end
end)
local function getPart()
    if #PartCache > 0 then
        return table.remove(PartCache)
    end
    return createPart()
end

local function recyclePart(part)
    if #PartCache > 1000 then
        part:Destroy()
        return
    end
    part.CFrame = CFrame.new(0,-1000000000,0)
    table.insert(PartCache,part)
end

do
    for _, undisturbed_point in plane do
        local vertex = EditableMesh:AddVertex(undisturbed_point)
        vertices[undisturbed_point] = vertex
    end

    local VECTOR10 = Vector3.xAxis
    local VECTOR01 = Vector3.zAxis
    local VECTOR11 = VECTOR10 + VECTOR01

    for _, undisturbed_point in plane do
        local current_vertex = vertices[undisturbed_point]
        local right_vertex = vertices[undisturbed_point+VECTOR10]
        local down_vertex = vertices[undisturbed_point+VECTOR01]
        local diagonal_vertex = vertices[undisturbed_point+VECTOR11]
        local nid = EditableMesh:AddNormal()

        if right_vertex and diagonal_vertex then
            local id = EditableMesh:AddTriangle(current_vertex, diagonal_vertex,right_vertex)
            EditableMesh:SetFaceNormals(id,{nid,nid,nid})
        end
        if down_vertex and diagonal_vertex then
            local id = EditableMesh:AddTriangle(current_vertex,down_vertex,diagonal_vertex)
            EditableMesh:SetFaceNormals(id,{nid,nid,nid})
        end
    end
    MeshPart= AssetService:CreateMeshPartAsync(Content.fromObject(EditableMesh))
    MeshPart.Anchored = true
   -- MeshPart.TextureID = 'http://www.roblox.com/asset/?id=91911324127943'
    MeshPart.Material = Enum.Material.Water
    MeshPart.Color = Color3.fromRGB(0, 162, 255)
    MeshPart.Parent = workspace
    MeshPart.Size = Vector3.new(800,0.001,800)
    MeshPart.Name = "Ocean"
end


function genewation.settings()
    return {
        Blocks = { -- The blocks to use by the color function. Return the Index of the block you want to use
            {Material = Enum.Material.Rock,Color = Color3.fromRGB(121, 121, 121)},
            {Material = Enum.Material.Glass ,Color = Color3.fromRGB(75, 184, 60)}

        }::{{Material:Enum.Material,Color:Color3}},
        ColorFunction = function(x,y,z,highestPoint) -- The color function for the blocks
            if y == highestPoint then
                return 2
            end
            return 1
        end,

        Seed = 1, -- The seed for the noise
        UseCylinder = true, -- Use a cylinder instead of a bunch of parts
        Center = Vector3.new(0, 10, 0), -- The center of the generation
        CenterModel = nil::Model?, -- Use a model instead of a cylinder or parts
        CenterRadius = 30, -- The radius of the center
        InnerSize = 60, -- How far before the wall starts
        OuterSize = 70, -- How far the wall goes

        Waves = baseWaves, -- The settings
        WaveColor = Color3.fromRGB(0, 162, 255), -- The color of the waves
        WaveMaterial = Enum.Material.Water, -- The material of the waves
        WaveSpeed = 1/4, -- The speed of the waves

        CenterYOffset = 4, -- The offset of the center in the Y direction
        WallYOffset = 10, -- The offset of the wall in the Y direction

        WallScale = 20, -- The scale of the wall
        InnerWallHeight = 6, -- The height of the inner wall
        WallNoise = { -- The noise settings for the wall
            firstOctave = -3,
            amplitudes = {2},
            persistance = .5,
            lacunarity = 2,
            salt = "wall"
        }
    }
end

local LEFT = Vector3.new(-1,0,0)
local RIGHT = Vector3.new(1,0,0)
local UP = Vector3.new(0,1,0)
local DOWN = Vector3.new(0,-1,0)
local FORWARD = Vector3.new(0,0,1)
local BACKWARD = Vector3.new(0,0,-1)

local function cullBlocks(blocks)
    local new = {}
    local s = os.clock()
    for position, value in blocks do
        if os.clock()-s > 0.0014 then
            task.wait()
            s = os.clock()
        end
        if blocks[position + LEFT] and blocks[position + RIGHT] and blocks[position + UP] and blocks[position + DOWN] and blocks[position + FORWARD] and blocks[position + BACKWARD] then
            continue
        end
        new[position] = value
    end
    return new
end

function genewation.generate(settings:settings)
    settings = settings or genewation.settings()
    local OuterSize = settings.OuterSize
    local CenterRadius = settings.CenterRadius
    local Center = settings.Center
    local Seed = settings.Seed
    local InnerSize = settings.InnerSize

    local WallYOffset = settings.WallYOffset

    local WallScale = settings.WallScale
    local CenterYOffset = settings.CenterYOffset
    local Height = Center.Y 
    local WallNoise = Noise.parse(Seed, settings.WallNoise)
    local Blocks = settings.Blocks
    local CenterModel = settings.CenterModel

    WAVE_SPEED = settings.WaveSpeed

    MeshPart.Color = settings.WaveColor
    MeshPart.Material = settings.WaveMaterial
    for i, wave in settings.Waves do
        for k,v in wave do
            waves[i][k] = v
        end
    end

    if not settings.UseCylinder and  not CenterModel then
        local Model = Instance.new("Model")
        for x = -CenterRadius, CenterRadius, 1 do
            for z = -CenterRadius, CenterRadius, 1 do
                if math.sqrt(x^2 + z^2) > CenterRadius+.1 then
                    continue
                end

                local position = Vector3.new(x, CenterYOffset, z) + Center
                local part = Instance.new("Part")
                part.Size = Vector3.new(PART_SIZE,position.Y*PART_SIZE,PART_SIZE)
                part.Position = Vector3.new(position.X*PART_SIZE,position.Y/2*PART_SIZE,position.Z*PART_SIZE)
                part.Anchored = true
                part.Parent = Model
                part.Color = Color3.fromRGB(245, 245, 148)
                part.Material = Enum.Material.Sand
                
            end
        end
        Model.Parent = workspace
        CenterPart = Model
    elseif not CenterModel then
        local Cylinder = Instance.new("Part")
        Cylinder.Shape = Enum.PartType.Cylinder
        Cylinder.Orientation = Vector3.new(0,0,90)
        Cylinder.Size = Vector3.new(CenterYOffset+Center.Y,CenterRadius*2,CenterRadius*2)*PART_SIZE
        Cylinder.Position = Vector3.new(Center.X*PART_SIZE,(CenterYOffset+Center.Y)*PART_SIZE/2,Center.Z*PART_SIZE)
        Cylinder.Anchored = true
        Cylinder.Parent = workspace
        Cylinder.Color = Color3.fromRGB(245, 245, 148)
        Cylinder.Material = Enum.Material.Sand
        CenterPart = Cylinder
    else
        local Model = CenterModel:Clone()
        Model:PivotTo(CFrame.new(Center.X*PART_SIZE,(CenterYOffset+Center.Y)*PART_SIZE/2,Center.Z*PART_SIZE)*Model:GetPivot().Rotation)
        Model.Parent = workspace
        CenterPart = Model
    end

    task.wait()

    local blocks = {}
    local s = os.clock()
    local ColorFunction = settings.ColorFunction
    local InnerWallHeight = settings.InnerWallHeight
    for x = -OuterSize, OuterSize, 1 do
        for z = -OuterSize, OuterSize, 1 do
            if os.clock()-s > 0.0014 then
                task.wait()
                s = os.clock()
            end
            local r = math.sqrt(x^2 + z^2) 
            if r > OuterSize+.1 then
                continue
            end
            local scale = WallScale
            local hOffset = WallYOffset
            if r < InnerSize-10 then
                continue
            elseif r<InnerSize then
                scale = WallScale*(r-InnerSize+10)/5
                hOffset = InnerWallHeight
            end
            local noise = Noise.sample(WallNoise, x, z) * scale
            local Offset = hOffset+Height
            local height = noise//1+Offset
            for i = Height,height do 
                blocks[Vector3.new(x, i, z)] = ColorFunction(x,i,z,height) or 1
            end
        end
    end
    MeshPart.Position = Vector3.new(Center.X*PART_SIZE,Center.Y*PART_SIZE+10,Center.Z*PART_SIZE) - Vector3.new(MeshPart.Size.X/2,0,MeshPart.Size.Z/2)
    task.wait()
    local culled = cullBlocks(blocks)
    task.wait()
    local meshed = GreedyMesh.mesh(culled)
    s = os.clock()
    for _,data in meshed do
        if os.clock()-s > 0.0014 then
            task.wait()
            s = os.clock()
        end
        local block = data.data
        local bData = Blocks[block] or {Material = Enum.Material.Rock,Color = Color3.fromRGB(121, 121, 121)}
        local part = getPart()
        part.Size = data.size*PART_SIZE
        part.Position = (data.midPoint) * PART_SIZE
        part.Material = bData.Material
        part.Color = bData.Color
        table.insert(GenerationParts,part)
    end

end

function genewation.clear()
    if not CenterPart then
        warn("No generation to clear")
        return
    end
    for _,part in GenerationParts do
        recyclePart(part)
    end
    table.clear(GenerationParts)
    if CenterPart then
        CenterPart:Destroy()
    end
end

local t = 0
local function update_wave_points(dt)
    t+=dt*WAVE_SPEED
	local solved_plane = Ocean.solve_plane_async(plane, waves, t)
	debug.profilebegin("updating the part points")
	for undisturbed_point, offset in solved_plane do
		local solved_offset = undisturbed_point + offset
        EditableMesh:SetPosition( vertices[undisturbed_point], solved_offset)
	end

    debug.profileend()
end

RunService.Heartbeat:Connect(update_wave_points)

type settings = typeof(genewation.settings())

return genewation