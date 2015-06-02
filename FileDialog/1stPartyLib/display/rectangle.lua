rectangle = {}
rectangle.__index = rectangle

require("1stPartyLib/physics/collision")
--creates a rectangle with given width and height. 
--dx and dy are the displacement from the top left corner to the anchor, defaulted to center
function rectangle.make(width,height, ax,ay, dx, dy)
	local self = {}
	setmetatable(self,rectangle)
	self.width = width
	self.height = height

	self.dx = dx or self.width/2
	self.dy = dy or self.height/2

	if type(ax) == 'table' and ax.x and ax.y then
		self.anchor = ax
	else
		self.anchor = {x=ax or 0, y=ay or 0}
	end

	return self
end

function rectangle:getLeft()
	return self.anchor.x-self.dx
end

function rectangle:getTop()
	return self.anchor.y-self.dy
end

function rectangle:getRight()
	return self.anchor.x-self.dx+self.width
end

function rectangle:getBottom()
	return self.anchor.y-self.dy+self.height
end

function rectangle:getRect(returnTable)
	if returnTable then
		return {self:getLeft(),self:getTop(),self.width,self.height}
	end
	return self:getLeft(),self:getTop(),self.width,self.height
end


function rectangle:draw(mode)
	xoffset = xoffset or 0
	yoffset = yoffset or 0
	love.graphics.rectangle(mode or 'fill',self.anchor.x-self.dx, self.anchor.y-self.dy, self.width,self.height)
end

function rectangle:collidePoint(x,y)
	return collision.pointRectangle(x,y,self.anchor.x-self.dx, self.anchor.y-self.dy, self.width,self.height)
end

function rectangle:collideRectangle(x,y,w,h)
	if type(x) == 'table' then --assume it's a rectangle object
		y = x:getTop()
		w = x.width
		h = x.height
		x = x:getLeft()
	end
	return collision.rectangles(self.anchor.x-self.dx, self.anchor.y-self.dy, self.width,self.height, x,y,w,h)
end