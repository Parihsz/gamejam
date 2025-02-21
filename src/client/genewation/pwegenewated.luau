local Generation = require(script.Parent)

local Settings = {}

do
    local Info = Generation.settings()
    Settings.Basic = Info
end

do
    local Info = Generation.settings()
    Settings.PartBased = Info

    Info.UseCylinder = false
end

do
    local Info = Generation.settings()
    Settings.ModelBased = Info
    
    Info.UseCylinder = false
    Info.CenterModel = game.ReplicatedStorage:FindFirstChild('Model')
end
Scene
do
    local Info = Generation.settings()
    Settings.DifferentColor = Info
    
    Info.Blocks = {
        {Material = Enum.Material.Sandstone,Color = Color3.fromRGB(255, 239, 96)},
        {Material = Enum.Material.Mud,Color = Color3.fromRGB(139, 69, 19)},
        {Material = Enum.Material.Grass,Color = Color3.fromRGB(255, 8, 0)},
    }
    Info.WaveColor = Color3.fromRGB(255, 0, 0)
    Info.WaveMaterial = Enum.Material.CrackedLava
    Info.ColorFunction = function(x,y,z,height)
       local diff = height-y
       if diff == 0 then
            return 3
       elseif diff < 2 then
            return 2
       else
            return 1
       end
    end
end

do
    local Info = Generation.settings()
    Settings.InnerWallHeight = Info
    Info.InnerWallHeight = 10
end

do
    local Info = Generation.settings()
    Settings.CustomNoise = Info
    Info.WallNoise  = {
        firstOctave = -4,
        amplitudes = {6,1,1,1,1,1,1,1,1,1},
        persistance = 0.5,
        lacunarity = 2,
        salt = "salt"
    }
end


return Settings