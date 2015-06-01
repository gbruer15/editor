local state = {}

local cursor = require('1stPartyLib/display/cursor')
local scrollbar = require('1stPartyLib/display/scrollbar')

function state.load()
	love.keyboard.setKeyRepeat(true)

	state.windowX = 20
	state.windowY = 20

	state.width = 600
	state.height = 400

	state.cursor = cursor.make{}
	state.verticalScrollbar = scrollbar.make{
									x = state.windowX+state.width-20
									,y = state.windowY
									,boxWidth = 20
									,boxHeight = state.height
									,contentSize = 800
									}

	state.lines = {"hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not","hellow evewj","Its nice","","not"}

	state.selection = {}
	state.selection.startCharacter = 1
	state.selection.startLine = 1
	state.selection.endCharacter = 1
	state.selection.endLine = 1
	state.selection.selected = false
	------Config Stuff------------------
	state.config = {}

	state.config.lineNumbers = false
	state.config.wordWrap = false

	state.config.lineHeight = 16
	state.config.charWidth = 8
	state.config.scrollAmount = 48

	state.config.fontSize = 16

	state.config.tabWidth = 4
	state.config.tabsToSpaces = false

	state.config.smartIndent = true
	-------------------------------------

	state.textX = state.config.lineNumbers and state.windowX+20 or state.windowX+6
	state.textY = state.windowY+5
	state.textWidth = state.verticalScrollbar.boxPos[1] - state.textX
	state.textHeight = state.windowY + state.height - state.textY

	state.tabString = string.rep(' ',state.config.tabWidth)

	state.verticalScrollbar:setContentSize((#state.lines-1)*state.config.lineHeight + state.height)

	love.graphics.setBackgroundColor(50,50,50)
end

function state.update(dt)
	state.cursor:update(dt)
	state.verticalScrollbar:update(dt)

	

	state.hoverCharacter = math.ceil( (MOUSE.x-state.textX-state.config.charWidth/2)  /state.config.charWidth)+1
	state.hoverLine = math.ceil( (MOUSE.y-state.textY+state.verticalScrollbar.scrollPosition)  /state.config.lineHeight)

	if state.selection.selecting then
		--state.selection.endLine = math.constrain(state.hoverLine,1,#state.lines)
		--state.selection.endCharacter = math.constrain(state.hoverCharacter,0,#state.lines[state.selection.endLine])

		state.cursor:setPosition(state.hoverLine,state.hoverCharacter,state.lines)

		state.selection.endCharacter = state.cursor.character
		state.selection.endLine = state.cursor.line

		state.selection.selected = state.selection.endCharacter ~= state.selection.startCharacter
									or state.selection.startLine ~= state.selection.endLine

		state.scrollToCursorSlow(state.config.lineHeight*3*dt)
	end
end

function state.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill',state.windowX,state.windowY,state.width,state.height)

	love.graphics.push()
	love.graphics.translate(0,-state.verticalScrollbar.scrollPosition)
		if state.config.lineNumbers then

		end

		love.graphics.setColor(0,0,0)
		local _,numTabs = string.gsub(state.lines[state.cursor.line]:sub(1,state.cursor.character-1),'\t','')
		state.cursor:draw(state.textX+ numTabs*state.config.charWidth*(#state.tabString-1),state.textY, state.config.lineHeight,state.config.charWidth)

		if debug.drawCharacterBoxes then
			state.textX,save = state.textX-state.config.charWidth/2,state.textX
			for i,v in pairs(state.lines) do
				for j=1,#v+1 do
					if j == state.hoverCharacter and i == state.hoverLine then
						love.graphics.setColor(255,0,100)
					else
						love.graphics.setColor(255,255,0,100)
					end
					love.graphics.rectangle('fill',state.textX+(j-1)*state.config.charWidth+2,state.textY + state.config.lineHeight*(i-1)+2,state.config.charWidth-4,state.config.lineHeight-4)
					love.graphics.setColor(0,0,0,150)
					love.graphics.rectangle('line',state.textX+(j-1)*state.config.charWidth+2,state.textY + state.config.lineHeight*(i-1)+2,state.config.charWidth-4,state.config.lineHeight-4)
					--love.graphics.print(v,state.textX,state.textY + state.config.lineHeight*(i-1))
				end
			end
			state.textX,save = save,nil
		end

		
		if state.selection.selected then
			love.graphics.setColor(255,255,0,100)

			if state.selection.startLine == state.selection.endLine then
				local width = (state.selection.endCharacter-state.selection.startCharacter)*state.config.charWidth
				love.graphics.rectangle('fill',state.textX+state.selection.startCharacter*state.config.charWidth,state.textY + state.config.lineHeight*(state.selection.startLine-1),width,state.config.lineHeight)
			else
				--highlight first line
				local width = (#state.lines[state.selection.startLine]-state.selection.startCharacter)*state.config.charWidth
				love.graphics.rectangle('fill',state.textX+state.selection.startCharacter*state.config.charWidth,state.textY + state.config.lineHeight*(state.selection.startLine-1),width,state.config.lineHeight)

				--highlight last line
				local width = (state.selection.endCharacter-1)*state.config.charWidth
				love.graphics.rectangle('fill',state.textX,state.textY + state.config.lineHeight*(state.selection.endLine-1),width,state.config.lineHeight)
				--highlight lines in between
				if state.selection.startLine<state.selection.endLine then
					for i=state.selection.startLine+1,state.selection.endLine-1 do					
						love.graphics.rectangle('fill',state.textX,state.textY + state.config.lineHeight*(i-1),(#state.lines[i])*state.config.charWidth,state.config.lineHeight)
					end
				else
					for i=state.selection.endLine+1,state.selection.startLine-1 do					
						love.graphics.rectangle('fill',state.textX,state.textY + state.config.lineHeight*(i-1),(#state.lines[i])*state.config.charWidth,state.config.lineHeight)
					end
				end
			end
		end

		love.graphics.setColor(0,0,0)
		for i,v in pairs(state.lines) do
			--love.graphics.print(v,state.textX,state.textY + state.config.lineHeight*(i-1))
			local l = v:gsub('\t',state.tabString)
			for j=1,#l do
				--love.graphics.print(v:sub(j,j),state.textX+(j-1)*state.config.charWidth,state.textY + state.config.lineHeight*(i-1))
				love.graphics.printf(l:sub(j,j),state.textX+(j-1)*state.config.charWidth,state.textY + state.config.lineHeight*(i-1),state.config.charWidth,'center')
			end
		end
	love.graphics.pop()

	state.verticalScrollbar:draw()

	love.graphics.setColor(200,0,0,100)
	love.graphics.line(state.textX,state.textY,state.textX,state.textY+state.height-(state.textY-state.windowY))

	love.graphics.setColor(200,255,0)
	love.graphics.print('StartC: ' .. state.selection.startCharacter,700,0)
	love.graphics.print('StartL: ' .. state.selection.startLine,700,15)
	love.graphics.print('EndC: ' .. state.selection.endCharacter,700,30)
	love.graphics.print('EndL: ' .. state.selection.endLine,700,45)

end



function state.textinput(text)
	state.lines[state.cursor.line] = string.insert(state.lines[state.cursor.line],text,state.cursor.character)
	state.cursor.character = state.cursor.character + #text
end

function state.keypressed(key)
	if key == 'backspace' then
		if state.cursor.character > 1 then
			state.lines[state.cursor.line] = string.remove(state.lines[state.cursor.line],state.controlPressed and state.cursor.character-1 or state.cursor.character,state.cursor.character)
			state.cursor:moveBack(state.lines)
		else
			--move up a line, remove previous line to above line
			if state.cursor.line > 1 then
				state.cursor:moveBack(state.lines)
				state.lines[state.cursor.line] = table.concat{state.lines[state.cursor.line],state.lines[state.cursor.line+1]}
				state.removeLine(state.cursor.line+1)
			end
		end
		state.scrollToCursor()
	elseif key == 'delete' then
		if state.cursor.character < #state.lines[state.cursor.line]+1 then
			state.lines[state.cursor.line] = string.remove(state.lines[state.cursor.line],state.cursor.character+1)
		else
			--remove below line to current line
			if state.cursor.line < #state.lines then
				state.lines[state.cursor.line] = table.concat{state.lines[state.cursor.line],state.lines[state.cursor.line+1]}
				state.removeLine(state.cursor.line+1)
			end
		end
	elseif key == 'return' then
		state.addLine(state.cursor.line+1,"")

		state.lines[state.cursor.line+1] = state.lines[state.cursor.line]:sub(state.cursor.character)
		state.lines[state.cursor.line] = state.lines[state.cursor.line]:sub(1,state.cursor.character-1)

		state.cursor.line = state.cursor.line + 1
		state.cursor.character = 1
		state.cursor.flash = 0

		if state.config.smartIndent then
			if not state.config.tabsToSpaces then
				--match start of string to first non-tab character
				local _,numStartTabs = state.lines[state.cursor.line-1]:find('^[\t]*')
				state.lines[state.cursor.line] = string.rep('\t',numStartTabs) .. state.lines[state.cursor.line]
				state.cursor.character = numStartTabs + 1
			else
				--match start of string to first non-tab character
				local _,numStartSpaces = state.lines[state.cursor.line-1]:find('^[%s]*')
				local numStartTabs = math.floor(numStartSpaces/state.config.tabWidth)
				state.lines[state.cursor.line] = string.rep(state.tabString,numStartTabs) .. state.lines[state.cursor.line]
				state.cursor.character = numStartSpaces + 1
			end
		end
		state.scrollToCursor()
	elseif key == 'tab' then
		if state.config.tabsToSpaces then
			state.textinput(state.tabString)
		else
			state.textinput('\t')
		end
	elseif key == 'rctrl' or key == 'lctrl' then
		state.controlPressed = true
	elseif key == 'up' then
		state.cursor:moveUp(state.lines)
		state.scrollToCursor()
	elseif key == 'down' then
		state.cursor:moveDown(state.lines)
		state.scrollToCursor()
	elseif key == 'left' then
		state.cursor:moveBack(state.lines)
		state.scrollToCursor()
	elseif key =='right' then
		state.cursor:moveForward(state.lines)
		state.scrollToCursor()
	elseif state.controlPressed then
		if key == 'c' then
			love.system.setClipboardText(state.getString(state.selection.startCharacter
														,state.selection.startLine
														,state.selection.endCharacter
														,state.selection.endLine)
											)
		elseif key == 'v' then
			state.insertLines(love.system.getClipboardText(),state.cursor.character,state.cursor.line)
		end
	end
end

function state.keyreleased(key)
	if key == 'rctrl' or key == 'lctrl' then
		state.controlPressed = love.keyboard.isDown('lctrl','rctrl')
	end
end


function state.mousepressed(x,y,b)
	if b == 'l' then
		if state.verticalScrollbar:mousepressed(x,y,b) then
			return
		else
			state.cursor:setPosition(state.hoverLine,state.hoverCharacter,state.lines)
			
			state.selection.startCharacter = state.cursor.character
			state.selection.startLine = state.cursor.line
			state.selection.endCharacter = state.cursor.character
			state.selection.endLine = state.cursor.line
			state.selection.selecting = true
		end
	elseif b == 'wd' then
		state.verticalScrollbar:setScrollPosition(state.verticalScrollbar.scrollPosition+state.config.scrollAmount)
	elseif b == 'wu' then
		state.verticalScrollbar:setScrollPosition(state.verticalScrollbar.scrollPosition-state.config.scrollAmount)
	end
end


function state.mousereleased(x,y,b)
	state.verticalScrollbar:mousereleased(x,y,b)

	state.selection.selecting = false
end

function state.addLine(line,s)
	table.insert(state.lines,line,s)
	state.verticalScrollbar:setContentSize(#state.lines*state.config.lineHeight + state.height)
end

function state.removeLine(line)
	table.remove(state.lines,line)
	state.verticalScrollbar:setContentSize(#state.lines*state.config.lineHeight + state.height)
end

function state.scrollToCursor()
	local cursorY = (state.cursor.line-1)*state.config.lineHeight
	if cursorY < state.verticalScrollbar.scrollPosition then
		state.verticalScrollbar:setScrollPosition(cursorY - state.config.lineHeight*3)
	elseif cursorY > state.verticalScrollbar.scrollPosition+state.textHeight then
		state.verticalScrollbar:setScrollPosition(cursorY - state.textHeight+state.config.lineHeight*3)
	end
end

function state.scrollToCursorSlow(amount)
	local cursorY = (state.cursor.line-1)*state.config.lineHeight
	if cursorY < state.verticalScrollbar.scrollPosition then
		state.verticalScrollbar:setScrollPosition(state.verticalScrollbar.scrollPosition - amount)
	elseif cursorY > state.verticalScrollbar.scrollPosition+state.textHeight then
		state.verticalScrollbar:setScrollPosition(cursorY - state.textHeight+amount)
	end
end

function state.getString(startC,startL,endC,endL)
	if not startC and not startL then
		return table.concat(state.lines,'\n')
	end

	endC = endC or (endL and #state.lines[endL]) or #state.lines[#state.lines]
	endL = endL or (endC and startL) or #state.lines  
	local strings = {}

	strings[1] = state.lines[startL]:sub(startC)
	for i=startL+1,endL-1 do
		table.insert(strings,state.lines[i])
	end
	table.insert(strings,state.lines[endL]:sub(1,endL))

	return table.concat(strings,'\n')
end

function state.insertLines(toInsert,startC,startL)
	local char = startC
	local lineNumber = startL

	local strings = string.split(toInsert,'\n')
	state.lines[startL] = state.lines[startL] .. strings[1]
	for i=2,#strings do
		table.insert(state.lines,startL+i-1,strings[i])
	end
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

return state