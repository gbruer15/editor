
love.graphics.oldRectangle = love.graphics.rectangle
function love.graphics.rectangle(dmode,left,top,width,height,ang) --draws a rectangle
	if ang == nil then
		love.graphics.oldRectangle(dmode,left,top,width,height)
		return
	end


	love.graphics.push()

	love.graphics.translate(left,top)
	love.graphics.rotate(ang)
	love.graphics.translate(-left,-top)

	love.graphics.oldRectangle(dmode,left,top,width,height)

	love.graphics.pop()
end

function love.graphics.ellipse(dmode,left,top,xd,yd, angle,nseg) --Draws an ellipse
	
	--[[love.graphics.push()

	xd = math.abs(xd)/2
	yd = (yd and math.abs(yd)/2) or xd

	love.graphics.translate(x,y)

	love.graphics.rotate(angle or 0)
	love.graphics.scale(xd,yd or xd)

	love.graphics.translate(-x,-y)

	love.graphics.circle(dmode,x,y,1,math.max(math.max(xd,yd),10))

	love.graphics.pop()

	angle = angle or 0
	love.graphics.setLineWidth(2)
	love.graphics.setColor(0,0,0)

	--]]
	angle = angle or  0
	love.graphics.push()

	love.graphics.translate(left,top)
	love.graphics.rotate(angle)
	love.graphics.translate(xd/2,yd/2)
	
	local lwidth = love.graphics.getLineWidth()
	if yd>xd then
		love.graphics.scale(1,yd/xd)
		love.graphics.circle(dmode,0,0,xd/2,math.max(xd/2,10))
	else
		love.graphics.scale(xd/yd,1)
		love.graphics.circle(dmode,0,0,yd/2,math.max(yd/2,10))
	end
	love.graphics.pop()
-----------------------------
--[[
	love.graphics.push()

	love.graphics.translate(x,y)
	love.graphics.rotate(angle)
	love.graphics.translate(-x,-y)


	--local xdif, ydif = xd*math.cos(angle), yd*math.sin(angle)
	--love.graphics.line(x+xdif,y+ydif,x-xdif,y-ydif)

	--love.graphics.line(x-xd,y,x+xd,y)
	--love.graphics.line(x,y-yd,x,y+yd)
	love.graphics.pop()
	--]]
end
