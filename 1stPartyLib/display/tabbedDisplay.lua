
tabbedDisplay = {}
tabbedDisplay.__index=tabbedDisplay

function tabbedDisplay.make(att)
	local self = {}
	setmetatable(self,tabbedDisplay)

	self.x = att.x or 0
	self.y = att.y or 0


	self.tabs = att.tabNames or {""}
	self.tabHeight = att.tabHeight

	self.buttons = {}
	self.pageDisplays = {}

	self.backgroundColor = att.backgroundColor or {255,200,100}
	self.selectedTabColor = att.selectedTabColor or self.backgroundColor
	self.defaultTabColor = att.defaultTabColor or {200,100,50}

	local x = self.x
	local lastB

	--Set up tab header
	for i,v in pairs(self.tabs) do
		self.buttons[i] = button.make{
							text=v,x=x
							,y=self.y
							,textcolor={0,0,0}
							,image=bottomlessrect.pic
							,height = self.tabHeight
							,imagecolor = self.defaultTabColor
							,selectedcolor = self.selectedTabColor
						}
		x = x + self.buttons[i].width + 4
		lastB = i
	end

	self.tabHeight = self.tabHeight or self.buttons[lastB].height
	self.width = att.width or (x-self.x)
	self.height = att.height or self.tabHeight*2

	--set up pageDisplays
	for i,v in pairs(self.tabs) do
		if att.pageDisplays and att.pageDisplays[v] then
			att.pageDisplays[v].width = self.width
			att.pageDisplays[v].height = self.height
		end
		self.pageDisplays[i] = (att.pageDisplays and att.pageDisplays[v]) 
								or	pageDisplay.make{
										text = v
										,x = self.x
										,y = self.y+self.tabHeight
										,width = self.width
										,height = self.height
									}
		self.pageDisplays[i].x = self.x
		self.pageDisplays[i].y = self.y+self.tabHeight
		
		print(self.pageDisplays[i].width)
	end

	self.currentTab = att.currentTab or 1
	self.buttons[self.currentTab].selected = true
	return self
end

function tabbedDisplay:update(dt)
	for i,b in pairs(self.buttons) do
		b:update(dt)
	end

	self.pageDisplays[self.currentTab]:update(dt)
end

function tabbedDisplay:draw()
	love.graphics.setColor(self.backgroundColor)
	love.graphics.rectangle('fill', self.x,self.y+self.tabHeight,self.width,self.height-self.tabHeight)
	for i,b in pairs(self.buttons) do
		b:draw()
	end
	self.pageDisplays[self.currentTab]:draw()


end

function tabbedDisplay:mousepressed(x,y,button)
	for i,b in pairs(self.buttons) do
		if b.hover then
			self.buttons[self.currentTab].selected = false
			self.currentTab = i
			b.selected = true
		end
	end
end

function tabbedDisplay:mousereleased(x,y,button)
	
end