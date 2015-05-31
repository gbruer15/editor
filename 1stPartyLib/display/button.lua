button = {}
button.__index = button
buttonpic = love.graphics.newImage(IMAGES_PATH .. "/button.png")
buttonpicwidth = buttonpic:getWidth()
buttonpicheight = buttonpic:getHeight()

buttonoutlinepic = love.graphics.newImage(IMAGES_PATH .. "button outline.png")
buttonsmalloutlinepic = love.graphics.newImage(IMAGES_PATH .. "button small outline.png")
function button.make(att) --att stands for attributes
	local b = {}
	setmetatable(b, button)
	b.metatable = 'button'
		
	b.text = att.text or ""
	b.textcolor = att.textcolor or {255,255,255}
	b.font = att.font or love.graphics.newFont(12)
	b.textheight = b.font:getHeight()
	b.textwidth = b.font:getWidth(b.text)	
	
	b.x,b.y = att.x or 0, att.y or 0
	b.width,b.height = att.width or b.textwidth+25,att.height or b.textheight+8
	if att.centerx then
		b.x = att.centerx-b.width/2
	end
	if att.centery then
		b.y = att.centery-b.height/2
	end
	b.image = (att.image==nil and buttonpic) or att.image
	if b.image then
		b.imagewidth = b.image:getWidth()
		b.imageheight = b.image:getHeight()
	end


	b.shadow = att.shadow
	b.imagecolor = att.imagecolor or {255,255,255}
	
	b.dark = {}
	for i,v in ipairs(b.imagecolor) do
		table.insert(b.dark,v*200/255)
	end
	
	b.selectedcolor = att.selectedcolor or {255,255,0}
	if b.shadow then
		b.shadow.x = b.shadow.x or 3
		b.shadow.y = b.shadow.y or 3
		b.shadow.width = b.shadow.width or 0
		b.shadow.height = b.shadow.height or 0
	end
	
	
	b.hover = false
	return b
end
 
function button:changeText(newtext)
	self.text = newtext
	self.textwidth = self.font:getWidth(self.text)	
end

function button:update()
	local x,y = love.mouse.getPosition()
	if collision.pointRectangle(x,y,self.x,self.y,self.width,self.height) then
		self.hover = true
	else
		self.hover = false
	end

end
 
function button:draw()
	if self.shadow then 
		love.graphics.setColor(0,0,0)
		if self.image then
			love.graphics.draw(self.image,self.x+self.shadow.x,self.y+self.shadow.y,0,(self.width+self.shadow.width)/self.imagewidth,(self.height+self.shadow.height)/self.imageheight)
		else
			love.graphics.rectangle('fill',self.x+self.shadow.x,self.y+self.shadow.y,self.width+self.shadow.width,self.height+self.shadow.height)
		end
	end
	
	if self.selected then
		love.graphics.setColor(unpack(self.selectedcolor))
	elseif self.hover then
		love.graphics.setColor(unpack(self.imagecolor))
	else
		love.graphics.setColor(unpack(self.dark))
	end
	if self.image then
		love.graphics.draw(self.image,self.x,self.y,0,self.width/self.imagewidth,self.height/self.imageheight)
	else
		love.graphics.rectangle('fill',self.x,self.y,self.width,self.height)
	end	
	

	
	love.graphics.setFont(self.font)
	love.graphics.setColor(unpack(self.textcolor))
	love.graphics.print(self.text, self.x+self.width/2 - self.textwidth/2, self.y + self.height/2 - self.textheight/2)
end