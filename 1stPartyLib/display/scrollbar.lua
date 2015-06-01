local scrollbar = {}
scrollbar.__index = scrollbar

function scrollbar.make(att)
	local self = {}
	setmetatable(self,scrollbar)

	self.boxPos = {}
	self.boxPos[1] = att.x or 0
	self.boxPos[2] = att.y or 0

	self.boxSize = {}
	self.boxSize[1] = att.boxWidth or 10
	self.boxSize[2] = att.boxHeight or 10

	self.type = att.type == 'horizontal' and 1 or 2
	self.notType = self.type == 1 and 2 or 1

	self.viewSize = att.viewSize or self.boxSize[self.type]

	self.contentSize = att.contentSize or self.boxSize[self.type]

	self.minHandleSize = att.minHandleSize or 5

	self.maxScrollPosition = self.contentSize-self.viewSize
	self.scrollPosition = att.scrollPosition and math.constrain(att.scrollPosition,0,self.maxScrollPosition) or 0

	self.handleSize = {}
	self.handleSize[self.type] = math.constrain(self.boxSize[self.type]/self.contentSize * self.viewSize,self.minHandleSize,self.boxSize[self.type])
	self.handleSize[self.notType] = self.boxSize[self.notType]*0.7

	self.minHandlePosition = self.boxPos[self.type]
	self.maxHandlePosition = self.boxPos[self.type]+ self.maxScrollPosition * self.boxSize[self.type]/self.contentSize
	self.handlePosition = {}

	self:setHandlefromScroll()
	
	self.handlePosition[self.notType] = self.boxPos[self.notType] + (self.boxSize[self.notType] - self.handleSize[self.notType])/2


	return self
end


function scrollbar:update(dt)
	self.hover = collision.pointRectangle(MOUSE.x,MOUSE.y, self.handlePosition[1],self.handlePosition[2],self.handleSize[1],self.handleSize[2])
	if self.grabbedMousePos then
		local currentPos = self.type==1 and MOUSE.x or MOUSE.y
		self:setHandlePosition(currentPos - self.grabbedMousePos  +self.grabbedhandlePosition)
	end

end

function scrollbar:draw()
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle('fill',self.boxPos[1],self.boxPos[2],self.boxSize[1],self.boxSize[2])

	love.graphics.setColor(0,100,0)
	love.graphics.rectangle('fill',self.handlePosition[1],self.handlePosition[2],self.handleSize[1],self.handleSize[2])
end


function scrollbar:mousepressed(x,y,b)
	if self.hover then
		self.grabbedMousePos = (self.type==1 and MOUSE.x or MOUSE.y)
		self.grabbedhandlePosition = self.handlePosition[self.type]
		return true
	end
end

function scrollbar:mousereleased(x,y,b)
	self.grabbedMousePos = nil
	self.grabbedhandlePosition = nil
end

function scrollbar:setContentSize(size)
	self.contentSize = size

	self.maxScrollPosition = math.max(self.contentSize-self.viewSize,0)
	self.scrollPosition = math.constrain(self.scrollPosition,0,self.maxScrollPosition)

	self.maxHandlePosition = self.boxPos[self.type]+ self.maxScrollPosition * self.boxSize[self.type]/self.contentSize

	self.handleSize[self.type] = math.constrain(self.boxSize[self.type]/self.contentSize * self.viewSize,self.minHandleSize,self.boxSize[self.type])

	self:setHandlefromScroll()	
end

function scrollbar:setScrollPosition(pos)
	self.scrollPosition = math.constrain(pos,0,self.maxScrollPosition)
	self:setHandlefromScroll()
end

function scrollbar:setHandlePosition(pos)
	self.handlePosition[self.type] = math.constrain(pos,self.minHandlePosition,self.maxHandlePosition)
	self:setScrollFromHandle()
end

function scrollbar:setScrollFromHandle()
	self.scrollPosition = math.constrain((self.handlePosition[self.type]-self.boxPos[self.type]) * self.contentSize/self.boxSize[self.type],0,self.maxScrollPosition)
end

function scrollbar:setHandlefromScroll()
	self.handlePosition[self.type] = math.constrain(self.boxPos[self.type]+ self.scrollPosition * self.boxSize[self.type]/self.contentSize,self.minHandlePosition,self.maxHandlePosition)
end

return scrollbar