local state = {}

local cursor = require('1stPartyLib/display/cursor')

function state.load()
	love.keyboard.setKeyRepeat(true)

	state.windowX = 20
	state.windowY = 20

	state.width = 600
	state.height = 400

	state.cursor = cursor.make{}

	state.lines = {"hellow evewj","Its nice","","not"}

	------Config Stuff------------------
	state.config = {}

	state.config.lineNumbers = false
	state.config.wordWrap = false

	state.config.lineHeight = 16
	state.config.charWidth = 10

	state.config.fontSize = 16

	state.config.tabWidth = 4

	state.config.smartIndent = true
	-------------------------------------

	state.textX = state.config.lineNumbers and state.windowX+20 or state.windowX+6
	state.textY = state.windowY+5

	state.tabString = string.rep(' ',state.config.tabWidth)

end

function state.update(dt)
	state.cursor:update(dt)
end

function state.draw()

	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill',state.windowX,state.windowY,state.width,state.height)

	if state.config.lineNumbers then

	end

	love.graphics.setColor(0,0,0)
	local _,numTabs = string.gsub(state.lines[state.cursor.line]:sub(1,state.cursor.character-1),'\t','')
	state.cursor:draw(state.textX+ numTabs*state.config.charWidth*(#state.tabString-1),state.textY, state.config.lineHeight,state.config.charWidth)

	love.graphics.setColor(255,255,0,100)
	for i,v in pairs(state.lines) do
		for j=1,#v do
			--love.graphics.print(v,state.textX,state.textY + state.config.lineHeight*(i-1))
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


	love.graphics.setColor(200,0,0,100)
	love.graphics.line(state.textX,state.textY,state.textX,state.textY+state.height-(state.textY-state.windowY))

end



function state.textinput(text)
	state.lines[state.cursor.line] = string.insert(state.lines[state.cursor.line],text,state.cursor.character)
	state.cursor.character = state.cursor.character + 1
end

function state.keypressed(key)
	if key == 'backspace' then
		if state.cursor.character > 1 then
			state.lines[state.cursor.line] = string.remove(state.lines[state.cursor.line],state.controlPressed and state.cursor.character -1 or state.cursor.character,state.cursor.character)
		else
			--remove current line to above line
			if state.cursor.line > 1 then
				state.lines[state.cursor.line-1] = table.concat{state.lines[state.cursor.line-1],state.lines[state.cursor.line]}
				table.remove(state.lines,state.cursor.line)
			end
		end
		state.cursor:moveBack(state.lines)
	elseif key == 'delete' then
		if state.cursor.character < #state.lines[state.cursor.line]+1 then
			state.lines[state.cursor.line] = string.remove(state.lines[state.cursor.line],state.cursor.character+1)
		else
			--remove below line to current line
			if state.cursor.line < #state.lines then
				state.lines[state.cursor.line] = table.concat{state.lines[state.cursor.line],state.lines[state.cursor.line+1]}
				table.remove(state.lines,state.cursor.line+1)
			end
		end
	elseif key == 'return' then
		table.insert(state.lines,state.cursor.line+1,"")
		state.lines[state.cursor.line+1] = state.lines[state.cursor.line]:sub(state.cursor.character)
		state.lines[state.cursor.line] = state.lines[state.cursor.line]:sub(1,state.cursor.character-1)

		state.cursor.line = state.cursor.line + 1
		state.cursor.character = 1

		if state.config.smartIndent then
			 --match start of string to first non-tab character
			local _,numStartTabs = state.lines[state.cursor.line-1]:find('^[\t]*')
			state.lines[state.cursor.line] = string.rep('\t',numStartTabs) .. state.lines[state.cursor.line]
			state.cursor.character = numStartTabs + 1
		end
		
	elseif key == 'tab' then
		state.textinput('\t')
	elseif key == 'rctrl' or key == 'lctrl' then
		state.controlPressed = true
	elseif key == 'up' then
		state.cursor:moveUp(state.lines)
	elseif key == 'down' then
		state.cursor:moveDown(state.lines)
	elseif key == 'left' then
		state.cursor:moveBack(state.lines)
	elseif key =='right' then
		state.cursor:moveForward(state.lines)
	end
end

function state.keyreleased(key)
	if key == 'rctrl' or key == 'lctrl' then
		state.controlPressed = love.keyboard.isDown('lctrl','rctrl')
	end
end



function state.mousepressed(x,y,b)

end


function state.mousereleased(x,y,b)

end

function string.insert(original, toInsert, pos)
	return table.concat{original:sub(1,pos-1), toInsert, original:sub(pos)}
end

function string.remove(original, startPos,endPos)
	endPos = endPos or startPos
	return table.concat{original:sub(1,startPos-2),original:sub(endPos)}
end

return state