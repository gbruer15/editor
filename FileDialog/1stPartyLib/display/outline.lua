local outline = {}
outline.__index = outline

function outline.make(att)
	local self = {}
	setmetatable(self,outline)

	self.corner = att.corner
	self.cIWidth = self.corner:getWidth()
	self.cIHeight = self.corner:getHeight()

	self.straight = att.straight
	self.sIWidth = self.straight:getWidth()
	self.sIHeight = self.straight:getHeight()

	self.lineWidth = att.lineWidth or 10

	self.scale = self.lineWidth/self.sIHeight

	self.cScale = self.scale


	self.cWidth = self.cIWidth*self.cScale
	return self
end


function outline:draw(x,y,width,height,lineWidth)
	local scale, cWidth
	if lineWidth then
		scale = lineWidth/self.sIHeight
		cWidth = self.cIWidth*scale
	else
		scale = self.scale
		cWidth = self.cWidth
	end


	local straightWidth = width - cWidth*2
	local straightHeight=height - cWidth*2
	--top left corner
	love.graphics.draw(self.corner,x,y,0,scale,scale)

	love.graphics.draw(self.straight,x+cWidth,y,0, straightWidth/self.sIWidth,scale)


	--top right corner
	love.graphics.draw(self.corner,x+width,y,math.pi/2,scale,scale)

	love.graphics.draw(self.straight,x+width,y+cWidth,math.pi/2, straightHeight/self.sIWidth,scale)


	--bottom right corner
	love.graphics.draw(self.corner,x+width,y+height,math.pi,scale,scale)

	love.graphics.draw(self.straight,x+width-cWidth,y+height,math.pi, straightWidth/self.sIWidth,scale)


	--bottom left corner
	love.graphics.draw(self.corner,x,y+height,-math.pi/2,scale,scale)

	love.graphics.draw(self.straight,x,y+height-cWidth,-math.pi/2, straightHeight/self.sIWidth,scale)

end

return outline