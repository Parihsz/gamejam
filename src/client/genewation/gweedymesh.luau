--!optimize 2

local GreedyMesh = {}

local function createBlock(startV,endV,data)
    local midpoint = (startV+endV)/2
    return {data = data ,startPos = startV,endPos = endV,size = endV-startV+Vector3.one,midPoint = midpoint},midpoint
end
 
local function compare(a,b)
    return (not (a and b) or a == b)
end

function GreedyMesh.mesh(blocks)
    local startX = 15
    local startY = 15
    local startZ = 15

    local endX = 0
    local endY = 0
    local endZ = 0

    for k in blocks do
        startX = math.min(startX,k.X)
        startY = math.min(startY,k.Y)
        startZ = math.min(startZ,k.Z)

        endX = math.max(endX,k.X)
        endY = math.max(endY,k.Y)
        endZ = math.max(endZ,k.Z)
    end

    local data = blocks

    local Checked = {}
    local Meshed = {}

    local currentX = startX
    local currentY = startY
    local currentZ = startZ

    local lastVector = false
    local startVector = false
    local s = os.clock()
    while currentZ <= endZ + 1 do
        while currentX <= endX +1 do
            while currentY <= endY + 1 do
                if os.clock()-s > 0.0014 then
                    task.wait()
                    s = os.clock()
                end
                local currentVector = Vector3.new(currentX, currentY, currentZ)
                local currentData = data[currentVector]
                local lastData = data[lastVector]
                local result = compare(currentData,lastData)

                if currentData and not Checked[currentVector] and result then
                    if not lastData then
                        startVector = currentVector
                    end
                    Checked[currentVector] = true
                elseif (not currentData or not result) and data[startVector] and lastVector and startVector then
                    local meshedData,index = createBlock(startVector,lastVector,lastData)
                    Meshed[index] = meshedData

                    if not result then
                        startVector = currentVector
                    else
                        startVector = false
                    end
                end
                lastVector = currentVector
                currentY += 1
            end
            currentY = startY
            currentX += 1
        end
        currentX = startX
        lastVector = Vector3.new(lastVector.X, lastVector.Y, currentZ)
        currentZ += 1
    end

    
    local function meshAgain(key,isX)
        local startVector = key
        local x,y,z = startVector.X,startVector.Y,startVector.Z
        local info = Meshed[startVector]
        local size = info.size
        local data = info.data
        local sizeX,sizeY,sizeZ = size.X,size.Y,size.Z
        local Start,End = info.startPos,info.endPos

        local currentDir = -1
        while true do
            if isX then
                x += sizeX * currentDir
            else
                z += sizeZ * currentDir
            end
            
            local currentVector = Vector3.new(x,y,z)
            local currentData = Meshed[currentVector]
            if currentData and currentData.size == size and currentData.data == data then
                if currentDir == -1 then
                    Start = currentData.startPos
                else
                    End = currentData.endPos
                end
                Meshed[currentVector] = nil
            elseif currentDir == -1 then
                currentDir = 1
                x,y,z = startVector.X,startVector.Y,startVector.Z
            else
                break
            end
        end
        return createBlock(Start,End,data)
    end

    local NewMeshed = {}
    local s = os.clock()
    for k in Meshed do
        if os.clock()-s > 0.0014 then
            task.wait()
            s = os.clock()
        end
        local bData,key = meshAgain(k,true)    
        NewMeshed[key] = bData
    end
    Meshed = NewMeshed
    NewMeshed = {}
    local s = os.clock()
    for k in Meshed do
        if os.clock()-s > 0.0014 then
            task.wait()
            s = os.clock()
        end
        local bData,key = meshAgain(k,false)    
        NewMeshed[key] = bData
    end
    return NewMeshed
end

return GreedyMesh