local Tank = {}

function Tank.new()
	local powerUp = {}

	powerUp.Name = "Tank"
	powerUp.Part = nil
	powerUp.Time = 10 -- The time the powerup lasts for
	powerUp.TimerThread = nil
	powerUp.Ball = nil -- the ball that aquired it

	function powerUp:Spawn(parent, position)
		self.Part.Parent = parent
		self.Part.Position = position
	end

	function powerUp:Acquired(ball)
		self.Ball = ball
		self.Ball.powerUps[self.Part] = powerUp
		self.Part.Parent = nil

		self:StartTimer()

		-- stuff
	end

	function powerUp:Ended()
		if self.Ball.powerUps[self.Part] then
			self.Ball.powerUps[self.Part] = nil
		end

		self.Part:Destroy()

		-- stuff
	end

	function powerUp:StartTimer()
		if not self.Ball then
			return
		end

		if self.TimerThread then
			task.cancel(self.TimerThread)
		end

		self.TimerThread = task.delay(powerUp.Time, self.Ended)
	end

	return Tank
end

return Tank
