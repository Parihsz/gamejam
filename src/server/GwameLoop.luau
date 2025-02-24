local BallHandler = require(script.Parent.ballhandwer)
local Powerups = require(script.Parent.Powerups)
local Physics = require(game:GetService("ReplicatedStorage").Shared.phwsics)
local Holder = require(game:GetService("ReplicatedStorage").Shared.ballHolder)

local LobbySpawn = workspace:WaitForChild("Lobby"):WaitForChild("Spawn")
local Spawns = workspace:WaitForChild("SpawnLocations")
local Loop = {}
local Status:StringValue = game:GetService("ReplicatedStorage"):WaitForChild("Status")::any
local State 
local Seed:IntValue = game:GetService("ReplicatedStorage"):WaitForChild("Seed")::any

local function getInGamePlayers()
    local balls = {}
    for _,ball in Holder.getAll() do
        if ball.ingame then
            table.insert(balls, ball)
        end
    end
    return balls
end

local States = {}
function States.CheckPlayers()
    local Players = game:GetService("Players"):GetPlayers()
    if #Players < 2 then
        Status.Value = "Waiting For Players"
        return
    end

     State = States.StartRound
end

function States.StartRound()
    Status.Value = "Starting Round.."

    Seed.Value = math.random(1, 2^30)
    task.wait(15)
    State = States.InRound
    local set = Spawns:GetChildren()
    local lastIndex = math.random(1, #set)
    for _,ball in Holder.getAll() do
        local index = (lastIndex + math.random(1, #set - 1) - 1) % #set + 1
        lastIndex = index
        local value = set[index]
        ball:setPosition(value.Position)
        ball.ingame = true
        ball.hits = 0
    end
    Powerups.start()
end

function States.InRound()
    local balls = getInGamePlayers()
    Status.Value = "Players Left: "..#balls
    if #balls <= 1 then
        State = States.EndRound
    end
    for i,v:Physics.ball in balls do
        if v.position.Y < 30 then
            v.ingame = false
            v.hits = 0
            v:setPosition(LobbySpawn.Position)
        end
    end
end

function States.EndRound()
    Powerups.stop()
    local plrs = getInGamePlayers()
    local Winner = plrs[1]
    if not Winner then
        Status.Value = "No Winner"
    else
        Status.Value = Winner.player.Name.." Won!"
    end
    task.wait(4)
    for i,v in plrs do
        v.ingame = false
        v.hits = 0
        v:setPosition(LobbySpawn.Position)
    end
    task.wait(7)
    State = States.CheckPlayers
end

State = States.CheckPlayers

task.spawn(function()
    while true do
        task.wait()
        State()
    end
end)
return Loop