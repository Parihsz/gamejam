
local Holder = {}

local Physics = require(script.Parent.phwsics)
local Balls = {}

function Holder.addBall(ball)
    Balls[ball.ID] = ball 
end

function Holder.removeBall(ball)
    if Balls[ball.ID] then
        Balls[ball.ID] = nil
    end 
end

function Holder.getBall(id):Physics.ball
    return Balls[id]
end

function Holder.getPlayerBall(player:Player):Physics.ball
   local id = player:GetAttribute('BallID')
    return Balls[id]
end

function Holder.getLocalPlayerBall():Physics.ball
    local player = game:GetService('Players').LocalPlayer
    local id = player:GetAttribute('BallID')
    return Balls[id]
end

return Holder
