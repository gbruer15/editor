local state = {}


local fileDialog = require('FileDialogStuff/fileDialog')
function state.load()
	state.fileDialog = fileDialog.make({
							currentDirectory = 'C:/Users/Grant'
				})
end

function state.update(dt)
	state.fileDialog:update(dt)
end

function state.draw()
	state.fileDialog:draw()
end

function state.textinput(text)
	state.fileDialog:textinput(text)
end
function state.keypressed(key)
	state.fileDialog:keypressed(key)
end

function state.keyreleased(key)
	state.fileDialog:keyreleased(key)
end

function state.mousepressed(x,y,b)
	state.fileDialog:mousepressed(x,y,b)
end

function state.mousereleased(x,y,b)
	state.fileDialog:mousereleased(x,y,b)
end

return state