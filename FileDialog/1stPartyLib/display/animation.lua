
animation = {}
animation.__index = animation

function animation.make(startv,endv,totaltime,loop,bounceLoop)
	local t = {}
	setmetatable(t,animation)

	t.startv = startv
	t.endv = endv


	t.value = t.startv

	t.totaltime = totaltime

	t.step = (t.endv-t.startv)/t.totaltime -- step per second

	if t.step < 0 then
		t.stepsign = -1
	else
		t.stepsign = 1
	end

	t.loop = loop or false
	t.bounceLoop = bounceLoop or false

	t.numloops = 0

	return t
end

function animation:update(dt)
	self.value = self.value + self.step*dt

	if (self.endv - self.value)*self.stepsign <= 0 then
		if self.loop then
			self.value = (self.value-self.endv)+self.startv
		elseif self.bounceLoop then
			self.value = self.endv - (self.value-self.endv)

			self.step = -self.step
			self.stepsign = -self.stepsign
			self.startv,self.endv = self.endv,self.startv
		else
			self.value = self.endv
		end
		self.numloops = self.numloops + 1
	end
end
