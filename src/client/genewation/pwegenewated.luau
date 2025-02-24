local Generation = require(script.Parent)::any

local Settings = {}

do
    local Info = Generation.settings()
    Settings.Default = Info
end



do
    local Info = Generation.settings()
    Settings.Lava = Info
    
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
    Settings.Noise = Info
    Info.WallNoise  = {
        firstOctave = -4,
        amplitudes = {6,3,1,1,1,1,1,1,1,1},
        persistance = 0.5,
        lacunarity = 2,
        salt = "salt"
    }
    Info.WaveColor = Color3.fromRGB(42, 177, 255)
end

do
    local Info = Generation.settings()
    Settings.RandomPart = Info
    Info.ColorFunction = function(x,y,z,height)
        local diff = height-y
        if y == height then
            return 2
        end
        if math.random() < .05 then
            return 3
        end
        if  math.random() < .05 then
            return 4
        end
        return 1
     end
     Info.InnerWallHeight = 23
    Info.WaveColor = Color3.fromRGB(143, 214, 255)
end



return Settings