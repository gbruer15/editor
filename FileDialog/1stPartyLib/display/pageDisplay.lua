pageDisplay = {}
pageDisplay.__index = pageDisplay

function pageDisplay.make(att)
	local self = {}
	setmetatable(self,pageDisplay)

	self.x = att.x or 0
	self.y = att.y or 0
	self.width = att.width or -1
	self.height = att.height or -1
	
	self.text = att.text or ""
	self.buttons = att.buttons or {}

	return self
end

function pageDisplay:update(dt)
	for i,b in pairs(self.buttons) do
		b:update(dt)
	end
end

function pageDisplay:draw()

	for i,b in pairs(self.buttons) do
		b:draw()
	end

	love.graphics.setColor(0,0,0)
	love.graphics.printf(self.text,self.x,self.y+self.height*0.4,self.width,'center')
end

