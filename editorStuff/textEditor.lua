local textEditor = {}
textEditor.__index = textEditor

local cursor = require('1stPartyLib/display/cursor')
local scrollbar = require('1stPartyLib/display/scrollbar')

function textEditor.make(att)
	local self = {}
	setmetatable(self,textEditor)
	love.keyboard.setKeyRepeat(true)


	self.windowX = 20
	self.windowY = 20

	self.width = 600
	self.height = 400

	self.cursor = cursor.make{}
	self.verticalScrollbar = scrollbar.make{
									x = self.windowX+self.width-20
									,y = self.windowY
									,boxWidth = 20
									,boxHeight = self.height
									,contentSize = 800
									}

	--self.lines = {"hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not"}
	self.lines = {}
	--local file = io.open('C:\\Users\\Grant\\scm\\LuaIDE\\debug.lua')
	for line in io.lines('C:\\Users\\Grant\\scm\\SpaceSurvivorsRepo\\Python Space Survivor\\gamel.py') do 
		--table.insert(self.lines,line) 
	end
	for line in io.lines('C:/Users/Grant/scm/SpaceSurvivorsRepo/Python Space Survivor/gamel.py') do 
		table.insert(self.lines,line) 
	end
	self.selection = {}
	self.selection.startCharacter = 1
	self.selection.startLine = 1
	self.selection.endCharacter = 1
	self.selection.endLine = 1
	self.selection.selected = false
	------Config Stuff------------------
	self.config = {}

	self.config.lineNumbers = false
	self.config.wordWrap = false

	self.config.lineHeight = 16
	self.config.charWidth = 8
	self.config.scrollAmount = 48

	self.config.fontSize = 16

	self.config.tabWidth = 4
	self.config.tabsToSpaces = false

	self.config.smartIndent = true
	-------------------------------------

	self.textX = self.config.lineNumbers and self.windowX+20 or self.windowX+6
	self.textY = self.windowY+5
	self.textWidth = self.verticalScrollbar.boxPos[1] - self.textX
	self.textHeight = self.windowY + self.height - self.textY

	self.tabString = string.rep(' ',self.config.tabWidth)

	self.verticalScrollbar:setContentSize((#self.lines-1)*self.config.lineHeight + self.height)

	love.graphics.setBackgroundColor(50,50,50)

	return self
end

function textEditor:update(dt)
	self.cursor:update(dt)
	self.verticalScrollbar:update(dt)

	

	self.hoverCharacter = math.ceil( (MOUSE.x-self.textX-self.config.charWidth/2)  /self.config.charWidth)+1
	self.hoverLine = math.ceil( (MOUSE.y-self.textY+self.verticalScrollbar.scrollPosition)  /self.config.lineHeight)

	if self.selection.selecting then
		--self.selection.endLine = math.constrain(self.hoverLine,1,#self.lines)
		--self.selection.endCharacter = math.constrain(self.hoverCharacter,0,#self.lines[self.selection.endLine])

		self.cursor:setPosition(self.hoverLine,self.hoverCharacter,self.lines)

		self.selection.endCharacter = self.cursor.character
		self.selection.endLine = self.cursor.line

		self.selection.selected = self.selection.endCharacter ~= self.selection.startCharacter
									or self.selection.startLine ~= self.selection.endLine

		self:scrollToCursorSlow(self.config.lineHeight*3*dt)
	end
end

function textEditor:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill',self.windowX,self.windowY,self.width,self.height)

	love.graphics.push()
	love.graphics.translate(0,-self.verticalScrollbar.scrollPosition)
		if self.config.lineNumbers then

		end

		love.graphics.setColor(0,0,0)
		local _,numTabs = string.gsub(self.lines[self.cursor.line]:sub(1,self.cursor.character-1),'\t','')
		self.cursor:draw(self.textX+ numTabs*self.config.charWidth*(#self.tabString-1),self.textY, self.config.lineHeight,self.config.charWidth)

		if debug.drawCharacterBoxes then
			self.textX,save = self.textX-self.config.charWidth/2,self.textX
			for i,v in pairs(self.lines) do
				for j=1,#v+1 do
					if j == self.hoverCharacter and i == self.hoverLine then
						love.graphics.setColor(255,0,100)
					else
						love.graphics.setColor(255,255,0,100)
					end
					love.graphics.rectangle('fill',self.textX+(j-1)*self.config.charWidth+2,self.textY + self.config.lineHeight*(i-1)+2,self.config.charWidth-4,self.config.lineHeight-4)
					love.graphics.setColor(0,0,0,150)
					love.graphics.rectangle('line',self.textX+(j-1)*self.config.charWidth+2,self.textY + self.config.lineHeight*(i-1)+2,self.config.charWidth-4,self.config.lineHeight-4)
					--love.graphics.print(v,self.textX,self.textY + self.config.lineHeight*(i-1))
				end
			end
			self.textX,save = save,nil
		end

		
		if self.selection.selected then
			love.graphics.setColor(255,255,0,100)

			if self.selection.startLine == self.selection.endLine then
				local width = (self.selection.endCharacter-self.selection.startCharacter)*self.config.charWidth
				love.graphics.rectangle('fill',self.textX+(self.selection.startCharacter-1)*self.config.charWidth,self.textY + self.config.lineHeight*(self.selection.startLine-1),width,self.config.lineHeight)
			else
				--highlight first line
				local width = (#self.lines[self.selection.startLine]-self.selection.startCharacter)*self.config.charWidth
				love.graphics.rectangle('fill',self.textX+(self.selection.startCharacter-1)*self.config.charWidth,self.textY + self.config.lineHeight*(self.selection.startLine-1),width,self.config.lineHeight)

				--highlight last line
				local width = (self.selection.endCharacter-1)*self.config.charWidth
				love.graphics.rectangle('fill',self.textX,self.textY + self.config.lineHeight*(self.selection.endLine-1),width,self.config.lineHeight)
				--highlight lines in between
				if self.selection.startLine<self.selection.endLine then
					for i=self.selection.startLine+1,self.selection.endLine-1 do					
						love.graphics.rectangle('fill',self.textX,self.textY + self.config.lineHeight*(i-1),(#self.lines[i])*self.config.charWidth,self.config.lineHeight)
					end
				else
					for i=self.selection.endLine+1,self.selection.startLine-1 do					
						love.graphics.rectangle('fill',self.textX,self.textY + self.config.lineHeight*(i-1),(#self.lines[i])*self.config.charWidth,self.config.lineHeight)
					end
				end
			end
		end

		love.graphics.setColor(0,0,0)
		local firstline = math.floor(self.verticalScrollbar.scrollPosition/self.config.lineHeight)+1
		local lastline = firstline + math.floor(self.verticalScrollbar.viewSize/self.config.lineHeight)
		for i=math.max(firstline,0),math.min(lastline,#self.lines) do
			v = self.lines[i]
			--love.graphics.print(v,self.textX,self.textY + self.config.lineHeight*(i-1))
			local l = v:gsub('\t',self.tabString)
			for j=1,#l do
				--love.graphics.print(v:sub(j,j),self.textX+(j-1)*self.config.charWidth,self.textY + self.config.lineHeight*(i-1))
				love.graphics.printf(l:sub(j,j),self.textX+(j-1)*self.config.charWidth,self.textY + self.config.lineHeight*(i-1),self.config.charWidth,'center')
			end
		end
	love.graphics.pop()

	self.verticalScrollbar:draw()

	love.graphics.setColor(200,0,0,100)
	love.graphics.line(self.textX,self.textY,self.textX,self.textY+self.height-(self.textY-self.windowY))

	love.graphics.setColor(200,255,0)
	love.graphics.print('StartC: ' .. self.selection.startCharacter,700,0)
	love.graphics.print('StartL: ' .. self.selection.startLine,700,15)
	love.graphics.print('EndC: ' .. self.selection.endCharacter,700,30)
	love.graphics.print('EndL: ' .. self.selection.endLine,700,45)

end



function textEditor:textinput(text)
	self.lines[self.cursor.line] = string.insert(self.lines[self.cursor.line],text,self.cursor.character)
	self.cursor.character = self.cursor.character + #text
end

function textEditor:keypressed(key)
	if key == 'backspace' then
		if self.cursor.character > 1 then
			self.lines[self.cursor.line] = string.remove(self.lines[self.cursor.line],self.controlPressed and self.cursor.character-1 or self.cursor.character,self.cursor.character)
			self.cursor:moveBack(self.lines)
		else
			--move up a line, remove previous line to above line
			if self.cursor.line > 1 then
				self.cursor:moveBack(self.lines)
				self.lines[self.cursor.line] = table.concat{self.lines[self.cursor.line],self.lines[self.cursor.line+1]}
				self:removeLine(self.cursor.line+1)
			end
		end
		self:scrollToCursor()
	elseif key == 'delete' then
		if self.cursor.character < #self.lines[self.cursor.line]+1 then
			self.lines[self.cursor.line] = string.remove(self.lines[self.cursor.line],self.cursor.character+1)
		else
			--remove below line to current line
			if self.cursor.line < #self.lines then
				self.lines[self.cursor.line] = table.concat{self.lines[self.cursor.line],self.lines[self.cursor.line+1]}
				self:removeLine(self.cursor.line+1)
			end
		end
	elseif key == 'return' then
		self:addLine(self.cursor.line+1,"")

		self.lines[self.cursor.line+1] = self.lines[self.cursor.line]:sub(self.cursor.character)
		self.lines[self.cursor.line] = self.lines[self.cursor.line]:sub(1,self.cursor.character-1)

		self.cursor.line = self.cursor.line + 1
		self.cursor.character = 1
		self.cursor.flash = 0

		if self.config.smartIndent then
			if not self.config.tabsToSpaces then
				--match start of string to first non-tab character
				local _,numStartTabs = self.lines[self.cursor.line-1]:find('^[\t]*')
				self.lines[self.cursor.line] = string.rep('\t',numStartTabs) .. self.lines[self.cursor.line]
				self.cursor.character = numStartTabs + 1
			else
				--match start of string to first non-tab character
				local _,numStartSpaces = self.lines[self.cursor.line-1]:find('^[%s]*')
				local numStartTabs = math.floor(numStartSpaces/self.config.tabWidth)
				self.lines[self.cursor.line] = string.rep(self.tabString,numStartTabs) .. self.lines[self.cursor.line]
				self.cursor.character = numStartSpaces + 1
			end
		end
		self:scrollToCursor()
	elseif key == 'tab' then
		if self.config.tabsToSpaces then
			self:textinput(self.tabString)
		else
			self:textinput('\t')
		end
	elseif key == 'rctrl' or key == 'lctrl' then
		self.controlPressed = true
	elseif key == 'up' then
		self.cursor:moveUp(self.lines)
		self:scrollToCursor()
	elseif key == 'down' then
		self.cursor:moveDown(self.lines)
		self:scrollToCursor()
	elseif key == 'left' then
		self.cursor:moveBack(self.lines)
		self:scrollToCursor()
	elseif key =='right' then
		self.cursor:moveForward(self.lines)
		self:scrollToCursor()
	elseif self.controlPressed then
		if key == 'c' then
			love.system.setClipboardText(self:getString(self.selection.startCharacter
														,self.selection.startLine
														,self.selection.endCharacter
														,self.selection.endLine)
											)
		elseif key == 'v' then
			self:insertLines(love.system.getClipboardText(),self.cursor.character,self.cursor.line)
		elseif key == 's' then
			self:saveFile()
		end
	end
end

function textEditor:keyreleased(key)
	if key == 'rctrl' or key == 'lctrl' then
		self.controlPressed = love.keyboard.isDown('lctrl','rctrl')
	end
end


function textEditor:mousepressed(x,y,b)
	if b == 'l' then
		if self.verticalScrollbar:mousepressed(x,y,b) then
			return
		else
			self.cursor:setPosition(self.hoverLine,self.hoverCharacter,self.lines)
			
			self.selection.startCharacter = self.cursor.character
			self.selection.startLine = self.cursor.line
			self.selection.endCharacter = self.cursor.character
			self.selection.endLine = self.cursor.line
			self.selection.selecting = true
		end
	elseif b == 'wd' then
		if not self.controlPressed then
			self.verticalScrollbar:setScrollPosition(self.verticalScrollbar.scrollPosition+self.config.scrollAmount)
		else
			self.config.lineHeight = math.max(self.config.lineHeight *0.8,self.config.fontSize)
		end
	elseif b == 'wu' then
		if not self.controlPressed then
			self.verticalScrollbar:setScrollPosition(self.verticalScrollbar.scrollPosition-self.config.scrollAmount)
		else
			self.config.lineHeight = self.config.lineHeight*1.2
		end
	end
end


function textEditor:mousereleased(x,y,b)
	self.verticalScrollbar:mousereleased(x,y,b)

	self.selection.selecting = false
end

function textEditor:addLine(line,s)
	table.insert(self.lines,line,s)
	self.verticalScrollbar:setContentSize(#self.lines*self.config.lineHeight + self.height)
end

function textEditor:removeLine(line)
	table.remove(self.lines,line)
	self.verticalScrollbar:setContentSize(#self.lines*self.config.lineHeight + self.height)
end

function textEditor:scrollToCursor()
	local cursorY = (self.cursor.line-1)*self.config.lineHeight
	if cursorY < self.verticalScrollbar.scrollPosition then
		self.verticalScrollbar:setScrollPosition(cursorY - self.config.lineHeight*3)
	elseif cursorY > self.verticalScrollbar.scrollPosition+self.textHeight then
		self.verticalScrollbar:setScrollPosition(cursorY - self.textHeight+self.config.lineHeight*3)
	end
end

function textEditor:scrollToCursorSlow(amount)
	local cursorY = (self.cursor.line-1)*self.config.lineHeight
	if cursorY < self.verticalScrollbar.scrollPosition then
		self.verticalScrollbar:setScrollPosition(self.verticalScrollbar.scrollPosition - amount)
	elseif cursorY > self.verticalScrollbar.scrollPosition+self.textHeight then
		self.verticalScrollbar:setScrollPosition(self.verticalScrollbar.scrollPosition+amount)
	end
end

function textEditor:getString(startC,startL,endC,endL)
	if not startC and not startL then
		return table.concat(self.lines,'\n')
	end

	endC = endC or (endL and #self.lines[endL]) or #self.lines[#self.lines]
	endL = endL or (endC and startL) or #self.lines  
	local strings = {}

	strings[1] = self.lines[startL]:sub(startC)
	for i=startL+1,endL-1 do
		table.insert(strings,self.lines[i])
	end
	table.insert(strings,self.lines[endL]:sub(1,endL))

	return table.concat(strings,'\n')
end

function textEditor:insertLines(toInsert,startC,startL)
	local char = startC
	local lineNumber = startL

	local strings = string.split(toInsert,'\n')
	self.lines[startL] = self.lines[startL] .. strings[1]
	for i=2,#strings do
		table.insert(self.lines,startL+i-1,strings[i])
	end
end

function textEditor:saveFile()
	local file = io.open('C:\\Users\\Grant\\scm\\LuaIDE\\testWrite.text','w')

	file:write(table.concat(self.lines,'\n'))
	file:close()
end




function string.split(s, charDelimiter)
	local strings = {}
	charDelimiter =charDelimiter or '%s'
	for line in string.gmatch(s,'[^'..charDelimiter..']+' ) do 
		table.insert(strings,line)
	end
	return strings
end
function string.insert(original, toInsert, pos)
	return table.concat{original:sub(1,pos-1), toInsert, original:sub(pos)}
end

function string.remove(original, startPos,endPos)
	endPos = endPos or startPos
	return table.concat{original:sub(1,startPos-2),original:sub(endPos)}
end

return textEditor