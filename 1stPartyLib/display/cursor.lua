local cursor = {}
cursor.__index = cursor

function cursor.make(att)
	local self = {}
	setmetatable(self,cursor)

	self.line = att.line or 1
	self.character = att.character or 1

	self.flashRate = att.flashRate or 2
	self.flash = 0

	self.height = att.height or 14

	return self
end

function cursor:update(dt)
	self.flash = self.flash + self.flashRate*dt
end

function cursor:draw(xoffset,yoffset,lineHeight,charWidth)
	if math.floor(self.flash)%2 == 0 then
		local x = xoffset + (self.character-1)*charWidth
		local y = yoffset + self.line*lineHeight

		love.graphics.setLineWidth(1)
		love.graphics.line(x,y, x,y-lineHeight)
	end
end

function cursor:moveBack(lines)
	if self.character > 1 then
		self.character = self.character - 1
	elseif self.line > 1 then
		self.line = self.line - 1
		self.character = #lines[self.line]+1
	end
	self.flash = 0
end

function cursor:moveForward(lines)
	if self.character < #lines[self.line]+1 then
		self.character = self.character + 1
	elseif self.line < #lines then
		self.line = self.line + 1
		self.character = 1
	end
	self.flash = 0
end

function cursor:moveUp(lines)
	if self.line > 1 then
		self.line = self.line - 1
		self.character = math.min(self.character,#lines[self.line]+1)
	end
	self.flash = 0
end

function cursor:moveDown(lines)
	if self.line < #lines then
		self.line = self.line + 1
		self.character = math.min(self.character,#lines[self.line]+1)
	end
	self.flash = 0
end

return cursor