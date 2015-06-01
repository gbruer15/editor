local state = {}


local textEditor = require('editorStuff/textEditor')
function state.load()
	state.textEditor = textEditor.make()
end

function state.update(dt)
	state.textEditor:update(dt)
end

function state.draw()
	state.textEditor:draw()
end

function state.textinput(text)
	state.textEditor:textinput(text)
end
function state.keypressed(key)
	state.textEditor:keypressed(key)
end

function state.keyreleased(key)
	state.textEditor:keyreleased(key)
end

function state.mousepressed(x,y,b)
	state.textEditor:mousepressed(x,y,b)
end

function state.mousereleased(x,y,b)
	state.textEditor:mousereleased(x,y,b)
end

return state