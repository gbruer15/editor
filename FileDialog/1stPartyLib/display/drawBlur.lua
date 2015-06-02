drawBlur = {}

function drawBlur.rectangle(x,y,width,height,blurwidth,incolor, outcolor,resolution)

	blurwidth = blurwidth or 10
	incolor = incolor or {0,0,0,255}
	outcolor = outcolor or {0,0,0,0}

	incolor[4] = incolor[4] or 255
	outcolor[4] = outcolor[4] or 255
	
	resolution = resolution or 1
	resolution = resolution * math.abs(blurwidth)/blurwidth
	if resolution*blurwidth <= 0 then
		error("bad argument")
	end
	--multipliers
	local rmult = (incolor[1]-outcolor[1])/blurwidth
	local gmult = (incolor[2]-outcolor[2])/blurwidth
	local bmult = (incolor[3]-outcolor[3])/blurwidth

	local amult = (incolor[4]-outcolor[4])/blurwidth
	
	love.graphics.setLineWidth(resolution)
	for i=0,blurwidth,resolution do
		love.graphics.setColor(rmult*i+outcolor[1],gmult*i+outcolor[2],bmult*i+outcolor[3],amult*i+outcolor[4])
		love.graphics.rectangle("line", x-(blurwidth-i),y-(blurwidth-i),width+2*(blurwidth-i),height+2*(blurwidth-i))
	end
	
end

function drawBlur.rectangleInversePower(x,y,width,height,blurwidth,incolor, outcolor,pow,resolution)

	blurwidth = blurwidth or 10
	local bwsign = math.abs(blurwidth)/blurwidth
	incolor = incolor or {0,0,0,255}
	outcolor = outcolor or {0,0,0,0}

	incolor[4] = incolor[4] or 255
	outcolor[4] = outcolor[4] or 255
	
	pow = pow or 1
	resolution = resolution or 1
	resolution = resolution * bwsign

	--color const
	local rconst = (outcolor[1]*blurwidth^pow-incolor[1])/(blurwidth^pow-1)
	local gconst = (outcolor[2]*blurwidth^pow-incolor[2])/(blurwidth^pow-1)
	local bconst = (outcolor[3]*blurwidth^pow-incolor[3])/(blurwidth^pow-1)
	local aconst = (outcolor[4]*blurwidth^pow-incolor[4])/(blurwidth^pow-1)
	
	--color factors
	local rfact = (incolor[1]-rconst)
	local gfact = (incolor[2]-gconst)
	local bfact = (incolor[3]-bconst)
	local afact = (incolor[4]-aconst)
	
	
	love.graphics.setLineWidth(resolution)
	for i=0,(math.abs(blurwidth)-1)*bwsign,resolution do
		love.graphics.setColor(rfact/(blurwidth-i)+rconst,gfact/(blurwidth-i)^pow+gconst,bfact/(blurwidth-i)^pow+bconst,afact/(blurwidth-i)^pow+aconst)
		love.graphics.rectangle("line", x-(blurwidth-i),y-(blurwidth-i),width+2*(blurwidth-i),height+2*(blurwidth-i))
	end
	love.graphics.setColor(incolor)
	love.graphics.rectangle("line",x,y,width,height)
	
end

--[[ various extraneous drawBlur.rectangle's
function drawBlur.rectangleSquare(x,y,width,height,blurwidth,incolor, outcolor,resolution)

	blurwidth = blurwidth or 10
	incolor = incolor or {0,0,0,255}
	outcolor = outcolor or {0,0,0,0}

	incolor[4] = incolor[4] or 255
	outcolor[4] = outcolor[4] or 255
	
	resolution = resolution or 1
	if resolution <= 0 then
		error("bad argument #8 to function drawBlur.rectangle: resolution must be greater than 0")
	end
	--color factors
	local rfact = -(incolor[1]-outcolor[1])/blurwidth^2
	local gfact = -(incolor[2]-outcolor[2])/blurwidth^2
	local bfact = -(incolor[3]-outcolor[3])/blurwidth^2

	local afact = -(incolor[4]-outcolor[4])/blurwidth^2
	
	love.graphics.setLineWidth(resolution)
	for i=0,blurwidth,resolution do
		love.graphics.setColor(rfact*(blurwidth-i)+incolor[1],gfact*(blurwidth-i)^2 + incolor[2],bfact*(blurwidth-i)^2 + incolor[3],afact*(blurwidth-i)^2 + incolor[4])
		love.graphics.rectangle("line", x-(blurwidth-i),y-(blurwidth-i),width+2*(blurwidth-i),height+2*(blurwidth-i))
	end
	
end

function drawBlur.rectangleInverseSquare(x,y,width,height,blurwidth,incolor, outcolor,resolution)

	blurwidth = blurwidth or 10
	incolor = incolor or {0,0,0,255}
	outcolor = outcolor or {0,0,0,0}

	incolor[4] = incolor[4] or 255
	outcolor[4] = outcolor[4] or 255
	
	resolution = resolution or 1
	if resolution <= 0 then
		error("bad argument #8 to function drawBlur.rectangle: resolution must be greater than 0")
	end	
	--color const
	local rconst = (outcolor[1]*blurwidth^2-incolor[1])/(blurwidth^2-1)
	local gconst = (outcolor[2]*blurwidth^2-incolor[2])/(blurwidth^2-1)
	local bconst = (outcolor[3]*blurwidth^2-incolor[3])/(blurwidth^2-1)
	local aconst = (outcolor[4]*blurwidth^2-incolor[4])/(blurwidth^2-1)
	
	--color factors
	local rfact = (incolor[1]-rconst)
	local gfact = (incolor[2]-gconst)
	local bfact = (incolor[3]-bconst)
	local afact = (incolor[4]-aconst)
	
	
	love.graphics.setLineWidth(resolution)
	for i=0,blurwidth-1,resolution do
		love.graphics.setColor(rfact/(blurwidth-i)+rconst,gfact/(blurwidth-i)^2 + gconst,bfact/(blurwidth-i)^2 + bconst,afact/(blurwidth-i)^2 + aconst)
		love.graphics.rectangle("line", x-(blurwidth-i),y-(blurwidth-i),width+2*(blurwidth-i),height+2*(blurwidth-i))
	end
	
end

function drawBlur.rectangleSquareRoot(x,y,width,height,blurwidth,incolor, outcolor,resolution)

	blurwidth = blurwidth or 10
	incolor = incolor or {0,0,0,255}
	outcolor = outcolor or {0,0,0,0}

	incolor[4] = incolor[4] or 255
	outcolor[4] = outcolor[4] or 255
	resolution = resolution or 1
	if resolution <= 0 then
		error("bad argument #8 to function drawBlur.rectangle: resolution must be greater than 0")
	end	
	--color factors
	local rfact = (outcolor[1]-incolor[1])/math.sqrt(blurwidth)
	local gfact = (outcolor[2]-incolor[2])/math.sqrt(blurwidth)
	local bfact = (outcolor[3]-incolor[3])/math.sqrt(blurwidth)
	local afact = (outcolor[4]-incolor[4])/math.sqrt(blurwidth)
	love.graphics.setLineWidth(resolution)
	for i=0,blurwidth,resolution do
		love.graphics.setColor(rfact*math.sqrt(blurwidth-i)+incolor[1],gfact*math.sqrt(blurwidth-i) + incolor[2],bfact*math.sqrt(blurwidth-i) + incolor[3],afact*math.sqrt(blurwidth-i) + incolor[4])
		love.graphics.rectangle("line", x-(blurwidth-i),y-(blurwidth-i),width+2*(blurwidth-i),height+2*(blurwidth-i))
	end	
end

function drawBlur.circle(x,y,inradius,nseg,blurwidth,incolor, outcolor,resolution)

	blurwidth = blurwidth or 10
	incolor = incolor or {0,0,0,255}
	outcolor = outcolor or {0,0,0,0}

	incolor[4] = incolor[4] or 255
	outcolor[4] = outcolor[4] or 255

	resolution = resolution or 1
	if resolution <= 0 then
		error("bad argument #7 to function drawBlur.circle: resolution must be greater than 0")
	end

	--multipliers
	local rmult = (incolor[1]-outcolor[1])/blurwidth
	local gmult = (incolor[2]-outcolor[2])/blurwidth
	local bmult = (incolor[3]-outcolor[3])/blurwidth
	local amult = (incolor[4]-outcolor[4])/blurwidth
	love.graphics.setLineWidth(resolution)
	for i=0,blurwidth,resolution do
		love.graphics.setColor(rmult*i+outcolor[1],gmult*i+outcolor[2],bmult*i+outcolor[3],amult*i+outcolor[4])
		love.graphics.circle("line", x,y,inradius + blurwidth-i,nseg)
	end
end
--]]


function drawBlur.image(image,centerx,centery,width,height,blurwidth,incolor, outcolor,resolution)
	
	local iwidth,iheight = image:getWidth(), image:getHeight()
	blurwidth = blurwidth or 10
	incolor = incolor or {0,0,0,255}
	outcolor = outcolor or {0,0,0,0}

	incolor[4] = incolor[4] or 255
	outcolor[4] = outcolor[4] or 255
	
	resolution = resolution or 1
	resolution = resolution * math.abs(blurwidth)/blurwidth
	if resolution*blurwidth <= 0 then
		error("bad argument")
	end
	--multipliers
	local rmult = (incolor[1]-outcolor[1])/blurwidth
	local gmult = (incolor[2]-outcolor[2])/blurwidth
	local bmult = (incolor[3]-outcolor[3])/blurwidth
	local amult = (incolor[4]-outcolor[4])/blurwidth

	for i=0,blurwidth,resolution do
		love.graphics.setColor(rmult*i+outcolor[1],gmult*i+outcolor[2],bmult*i+outcolor[3],amult*i+outcolor[4])
		local dwidth = width+blurwidth-i
		local dheight = height+blurwidth-i
		love.graphics.draw(image, centerx-dwidth/2,centery-dheight/2,0,dwidth/iwidth,dheight/iheight)
	end
end

function drawBlur.imageInversePower(image,centerx,centery,width,height,blurwidth,incolor,outcolor,pow,resolution)
	
	local iwidth,iheight = image:getWidth(), image:getHeight()
	blurwidth = blurwidth or 10
	incolor = incolor or {0,0,0,255}
	outcolor = outcolor or {0,0,0,0}

	incolor[4] = incolor[4] or 255
	outcolor[4] = outcolor[4] or 255
	
	pow = pow or 1
	resolution = resolution or 1
	resolution = resolution * math.abs(blurwidth)/blurwidth
	if resolution*blurwidth <= 0 then
		error("bad argument")
	end
	--color const
	local rconst = (outcolor[1]*blurwidth^pow-incolor[1])/(blurwidth^pow-1)
	local gconst = (outcolor[2]*blurwidth^pow-incolor[2])/(blurwidth^pow-1)
	local bconst = (outcolor[3]*blurwidth^pow-incolor[3])/(blurwidth^pow-1)
	local aconst = (outcolor[4]*blurwidth^pow-incolor[4])/(blurwidth^pow-1)
	
	--color factors
	local rfact = (incolor[1]-rconst)
	local gfact = (incolor[2]-gconst)
	local bfact = (incolor[3]-bconst)
	local afact = (incolor[4]-aconst)
	
	
	love.graphics.setLineWidth(resolution)
	for i=0,blurwidth-1,resolution do
		love.graphics.setColor(rfact/(blurwidth-i)+rconst,gfact/(blurwidth-i)^pow+gconst,bfact/(blurwidth-i)^pow+bconst,afact/(blurwidth-i)^pow+aconst)
		local dwidth = width+blurwidth-i
		local dheight = height+blurwidth-i
		love.graphics.draw(image, centerx-dwidth/2,centery-dheight/2,0,dwidth/iwidth,dheight/iheight)
	end
	
end

function drawBlur.ellipse(x,y,xd,yd,angle,nseg,blurwidth,incolor,outcolor,resolution)
	--[[
	love.graphics.push()

	love.graphics.translate(x,y)
	love.graphics.rotate(angle)
	if yd>xd then
		love.graphics.scale(xd/yd,1)
		drawBlur.circle(0,0,xd,math.max(yd,10),blurwidth,incolor,outcolor,resolution)
	else
		love.graphics.scale(yd/xd,1)
		drawBlur.circle(0,0,yd,math.max(xd,10),blurwidth,incolor,outcolor,resolution)
	end
	love.graphics.pop()
	--]]
	angle = angle or 0


	blurwidth = blurwidth or 10
	incolor = incolor or {0,0,0,255}
	outcolor = outcolor or {0,0,0,0}

	incolor[4] = incolor[4] or 255
	outcolor[4] = outcolor[4] or 255

	resolution = resolution or 1
	resolution = resolution * math.abs(blurwidth)/blurwidth
	if resolution*blurwidth <= 0 then
		error("bad argument")
	end

	--multipliers
	local rmult = (incolor[1]-outcolor[1])/blurwidth
	local gmult = (incolor[2]-outcolor[2])/blurwidth
	local bmult = (incolor[3]-outcolor[3])/blurwidth
	local amult = (incolor[4]-outcolor[4])/blurwidth
	love.graphics.setLineWidth(resolution)
	for i=0,blurwidth,resolution do
		love.graphics.setColor(rmult*i+outcolor[1],gmult*i+outcolor[2],bmult*i+outcolor[3],amult*i+outcolor[4])
		love.graphics.ellipse("line", x,y,xd+blurwidth-i,yd+blurwidth-i,angle,nseg)
	end
end