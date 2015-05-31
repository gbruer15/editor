boolBox = {}
boolBox.__index = boolBox
boolBox.pic = love.graphics.newImage(IMAGES_PATH .. "/outline1.png")--Green Rectangle with raised border gray.png")
boolBox.picwidth = boolBox.pic:getWidth()
boolBox.picheight = boolBox.pic:getHeight()
function boolBox.make(att)
	local self = {}
	setmetatable(self,boolBox)
	self.width = att.width or 270
	self.height = att.height or self.width/boolBox.picwidth*boolBox.picheight
	
	self.x = (att.centerx and att.centerx-self.width/2) or att.x or window.width/2-self.width/2
	self.y = (att.centery and att.centery-self.height/2) or att.y or window.height/2-self.width/2
	
	self.titleText = att.titleText or ""
	self.titleTextColor = att.titleTextColor or {255,255,255}

	self.boxColor = att.boxColor or {100,100,100}
	self.outlineColor = att.outlineColor or {200,200,200}

	local cx = self.x+self.width/3
	self.trueButton = button.make{text=att.trueText or "True",centerx=cx,centery=self.y+self.height*0.7}
	self.falseButton = button.make{text=att.falseText or "False",centerx=cx+self.width/3,centery=self.y+self.height*0.7}
	
	self.value = nil
	self.blurwidth = att.blurwidth or 10
	
	return self	
end

function boolBox:update(mx,my)
	local mx,my = mx or love.mouse.getX(), my or love.mouse.getY()
	self.hover = nil
	self.trueButton:update()
	self.falseButton:update()
	self.hover = self.trueButton.hover 
	if not self.hover then
		if self.falseButton.hover then
			self.hover = false
		else
			self.hover = nil
		end
	end
end

function boolBox:draw(blur)
	if blur then
		drawBlur.rectangle(self.x,self.y,self.width,self.height,self.blurwidth,{255,255,255},{255,255,255,0})
	end
	love.graphics.setColor(self.boxColor)
	love.graphics.rectangle('fill',self.x,self.y,self.width,self.height)

	love.graphics.setColor(self.outlineColor)
	love.graphics.draw(boolBox.pic,self.x,self.y,0,self.width/boolBox.picwidth,self.height/boolBox.picheight)
	
	self.trueButton:draw()
	self.falseButton:draw()
	
	love.graphics.setColor(self.titleTextColor)
	love.graphics.printf(self.titleText,self.x,self.y+self.height/boolBox.picheight*35,self.width,'center')
end

function boolBox:mousepressed(x,y,button)
	if button=='l' then
		self.value = self.hover
	end
end

function boolBox.getResponse(att)
	local box = boolBox.make(att)
	box.value = nil
	
	local old = {}
	for i,v in ipairs(lovefunctions) do
		old[v] = love[v]
		love[v] = nil
	end
	
	function love.mousepressed(x,y,button)
		box:mousepressed(x,y,button)
	end
	
	love.mouse.setVisible(true)
	drawBlur.rectangleInversePower(box.x,box.y,box.width,box.height,10,{0,0,0},{255,255,255,0},5)
	while box.value == nil do
		love.processEvents()
		
		local mx,my = love.mouse.getPosition()
		box:update(mx,my)
		box:draw()
		
		love.graphics.present()
	end
	
	for i,v in ipairs(lovefunctions) do
		love[v] = old[v]
	end
	
	return box.value
end
