explosion = {}
explosion.__index = explosion

function explosion.load()
	EXPLOSIONTIME = 1
	EXPLOSIONSCALE = 20/301
	flash = "white" 
end

function explosion.make(x,y,explosionTime,color)
	local self = {}
	setmetatable(self,explosion)
	
	self.x,self.y = x,y
	self.explosionTime = explosionTime or 1
	self.maxExplosionTime = self.explosionTime
	
	self.startWidth = 400
	self.finalWidth = 20
	
	self.e = 1000
	
	self.color = color or {255,255,255}
	
	return self
end
--width(0) = self.startWidth
--width(self.maxExplosionTime) = self.finalWidth *self.startWidth/(e^self.maxExplosionTime)
--width(t) = self.startWidth*e^(-t)
function explosion:update(dt)
	self.explosionTime = self.explosionTime - dt
	if self.explosionTime <= 0 then
		self.destroy = true
	end
end

function explosion:draw()
	--self.scale = self.finalWidth/explosionPic.width * (self.maxExplosionTime-self.explosionTime) ^ -.7
	self.width = (self.startWidth*self.e^(-self.maxExplosionTime+self.explosionTime)) + self.finalWidth
	self.scale = self.width/explosionPic.width
	self.left, self.top = self.x-explosionPic.width*self.scale/2, self.y-explosionPic.height*self.scale/2
	
	self.color[4] = (self.explosionTime)/self.maxExplosionTime*255
	love.graphics.setColor(self.color)
	love.graphics.draw(explosionPic.pic, self.left, self.top, 0, self.scale,self.scale)
end
