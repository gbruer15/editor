slider = {}
slider.__index = slider
function slider.make(att) --att stands for attributes
	local s = {}
	setmetatable(s, slider)
	s.metatable = 'slider'
	
	s.x,s.y = att.x or 0, att.y or 0
	s.text = att.text or ""
	s.textcolor = att.textcolor or {255,255,255}
	s.font = att.font or love.graphics.newFont(12)
	s.textheight = s.font:getHeight()
	s.textwidth = s.font:getWidth(s.text)	
	
	s.width,s.height = att.width or 300,att.height or 20
	s.image = att.image or sliderpic.pic
	s.imagewidth = s.image:getWidth()
	s.imageheight = s.image:getHeight()
	s.shadow = att.shadow
	if s.shadow then
		s.shadow.x = s.shadow.x or 3
		s.shadow.y = s.shadow.y or 3
		s.shadow.width = s.shadow.width or 0
		s.shadow.height = s.shadow.height or 0
	end
	
	s.arrowpic = att.sliderpic or sliderpic.arrowpic
	s.arrowpicheight = s.arrowpic:getHeight()
	s.arrowpicwidth = s.arrowpic:getWidth()
	s.arrowheight = att.height or 30
	s.arrowwidth = att.width or 15
	
	s.color = att.color or {255,255,255}
	s.value = att.value or 0
	s.round = att.round
	s.hover = false
	s.mouseoffx = 0
	
	s.multiplyer = att.multiplyer or 100
	s.multiplyerwidth = s.font:getWidth(s.multiplyer)
	
	return s
end

function slider:update()
	local x,y = love.mouse.getPosition()
	if collision.pointRectangle(x,y,self.x,self.y,self.width,self.height) then
		self.hover = true
	else
		self.hover = false
	end
	if self.selected and love.mouse.isDown('l') then
		self.value = (x + self.mouseoffx - self.x)/self.width
		if self.value > 1 then
			self.value = 1
		elseif self.value < 0 then
			self.value = 0
		end
	end
	if self.round then
		self.value = math.round(self.value,self.round)
	end
 end

function slider:draw()
	if self.shadow then
		love.graphics.setColor(0,0,0)
		love.graphics.draw(self.image,self.x+self.shadow.x,self.y+self.shadow.y,0,(self.width+self.shadow.width)/self.imagewidth,(self.height+self.shadow.height)/self.imageheight)			
	end
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", self.x,self.y,self.width,self.height)
	
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.image,self.x,self.y,0,self.width/self.imagewidth,self.height/self.imageheight)	
	
	if not self.hover and not self.selected then
		love.graphics.setColor(200,200,200,200)
		--love.graphics.draw(self.image,self.x,self.y,0,self.width/self.imagewidth,self.height/self.imageheight)	
	elseif self.selected then
		love.graphics.setColor(200,255,0,100)
		--love.graphics.draw(self.image,self.x,self.y,0,self.width/self.imagewidth,self.height/self.imageheight)	
	end

	love.graphics.setColor(255,255,255)
	--love.graphics.rectangle("fill", self.x+self.value*self.width - 1, self.y, 3,self.height)
	love.graphics.draw(self.arrowpic, self.x + self.value*self.width-self.arrowwidth/2, self.y-self.arrowheight*0.6,0,  self.arrowwidth/self.arrowpicwidth, self.arrowheight/self.arrowpicheight)
	
	love.graphics.setFont(self.font)
	love.graphics.setColor(unpack(self.textcolor))
	--love.graphics.print(self.text, self.x+self.width/2 - self.textwidth/2, self.y + self.height)
	love.graphics.print(self.text, self.x, self.y + self.height)
	love.graphics.print(math.round(self.value * self.multiplyer,1),self.x +self.width - self.multiplyerwidth, self.y + self.height )
end