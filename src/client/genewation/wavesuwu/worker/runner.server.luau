-- Just a glue file
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local compute = require(script.Parent.computeuwu)

local bindable = script.Parent.invoke

bindable.OnInvoke = compute