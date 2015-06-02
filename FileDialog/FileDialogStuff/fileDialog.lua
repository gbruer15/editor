local fileDialog = {}
fileDialog.__index = fileDialog

function fileDialog.make(att)
	local self = {}
	setmetatable(self,fileDialog)

	self.currentDirectory = att.currentDirectory or 'C:/Users/Grant'

	self.files = love.filesystem.getDirectoryItems(self.currentDirectory)

	return self
end


function fileDialog:update(dt)

end


function fileDialog.draw()

end


function fileDialog:textinput(text)


end


function fileDialog:keypressed(key)

end

function fileDialog:keyreleased(key)

end


function fileDialog:mousepressed(x,y,b)

end

function fileDialog:mousereleased(x,y,b)

end

return fileDialog