tileDraw = {}

function tileDraw.image(image, left,top,width,height, tilewidth,tileheight,xoffset,yoffset)
	local iwidth,iheight = image:getWidth(),image:getHeight()

	local xoffset,yoffset = xoffset or 0, yoffset or 0

	local x = left
	local y
	local n = 1
	love.graphics.setScissor(left,top,width,height)
	while x < left+width do
		y = top
		while y < top+height do
			love.graphics.draw(image,x,y,0,tilewidth/iwidth,tileheight/iheight)
			y = y + tileheight
			n = n + 1
		end
		x = x + tilewidth
		
	end

	love.graphics.setScissor()
	return n
end