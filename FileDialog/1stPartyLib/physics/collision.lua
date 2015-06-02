collision = {}

function collision.rectangles(left1,top1,width1,height1, left2,top2,width2,height2)
	collide = (left1 + width1 > left2 and left1 < left2 + width2 and top1 < top2 + height2 and top1 + height1 > top2)
	return collide
end

function collision.rectanglesOverlap(left1,top1,width1,height1, left2,top2,width2,height2)
	local yoverlap = 0
	if top1 > top2 then
		if top1 + height1 <= top2 + height2 then
			yoverlap = height1
		else
			yoverlap = top2+height2 - top1
		end
	else
		if top2 + height2 <= top1 + height1 then
			yoverlap = height2
		else
			yoverlap = top1+height1 - top2
		end 
	end

	local xoverlap = 0
	if left1 > left2 then
		if left1 + width1 <= left2 + width2 then
			xoverlap = width1
		else
			xoverlap = left2+width2 - left1
		end
	else
		if left2 + width2 <= left1 + width1 then
			xoverlap = width2
		else
			xoverlap = left1+width1 - left2
		end 
	end

	return xoverlap,yoverlap
end

function collision.rotatedRectangles(l1,t1,w1,h1,a1, l2,t2,w2,h2,a2)
	local points1 = collision.getRectanglePoints(l1,t1,w1,h1,a1)
	table.insert(points1,l1)
	table.insert(points1,t1)
	local points2 = collision.getRectanglePoints(l2,t2,w2,h2,a2)
	table.insert(points2,l2)
	table.insert(points2,t2)
	for i=1,#points1-3,2 do
		for j=1,#points2-3,2 do
			if collision.lineSegments(points1[i],points1[i+1],points1[i+2],points1[i+3],points2[i],points2[i+1],points2[i+2],points2[i+3]) then
				return true
			end
		end
	end
	
	return false -- will return false if one is completely inside the other
end

function collision.lineRectangle(ax,ay,bx,by, left,top,width,height)
	if collision.pointRectangle(ax,ay,left,top,width,height) then
		return true,ax,ay,"A in"
	elseif collision.pointRectangle(bx,by,left,top,width,height) then
		return true,bx,by,"B in"
	end
	 
	if bx == ax then
		return (ay < top and by > top+height) or (ay> top+height and by<top),ax,top,"vertical line"
	else
		local m = (ay-by)/(ax-bx)
		local b = ay - m*ax
		
		local lefty = m*left+b
		if (lefty > top and lefty < top+height) and (lefty-ay)*(lefty-by)<=0 then
			return true,left,lefty,"lefty was good"
		end
		
		local righty = m*(left+width)+b
		if (righty > top and righty < top+height) and (righty-ay)*(righty-by)<=0 then
			return true,left+width,righty,"righty was good"
		end
		
		local topx = (top-b)/m
		if (topx > left and topx < left+width) and (topx-ax)*(topx-bx) <= 0 then
			return true,topx,top,"topx was good"
		end
		
		local bottomx = (top+height-b)/m
		if (bottomx > left and bottomx < left+width) and (bottomx-ax)*(bottomx-bx) <= 0 then
			return true,bottomx,top+height,"bottomx was good"
		end
	end
	return false
end

function collision.getRectanglePoints(l,t,w,h,a)
	--[[local points = {{l,t}}
	local inA = math.atan(h/w)
	local hyp = math.sqrt(h*h+w*w)
	
	table.insert(points,{l+w*math.cos(a),t+w*math.sin(a)})
	table.insert(points,{l+hyp*math.cos(a+inA),t+hyp*math.sin(a+inA)})
	table.insert(points,{l-h*math.cos(-a+math.pi/2),t+h*math.sin(-a+math.pi/2)})
	return points
	--]]
	a = a or 0
	local inA = math.atan(h/w)
	local hyp = math.sqrt(h*h+w*w)
	
	local points = {l,t}
	points[3],points[4] = points[1]+w*math.cos(a),points[2]+w*math.sin(a)
	points[5],points[6] = points[1]+hyp*math.cos(a+inA),points[2]+hyp*math.sin(a+inA)
	points[7],points[8] = points[1]-h*math.cos(-a+math.pi/2),points[2]+h*math.sin(-a+math.pi/2)
	return points
end


function collision.rectangleVector(left,top,width,height,  vx,vy,vr,vmag)

end

collision.direction = {}
function collision.direction.rectangles1(left1,top1,width1,height1,xspeed1,yspeed1, left2,top2,width2,height2,xspeed2,yspeed2)
	
	--[
	if (left1 >= left2 + width2 and left1 + width1 >= left2 + width2) then
		return "right"
	elseif (left1 <= left2  and left1 + width1 <= left2) then
		return "left"
	elseif (top1 <= top2 and top1 + height1 <= top2)  then
		return "top"
	elseif (top1 >= top2 + height2 and top1 + height1 >= top2 + height2)  then
		return "bottom"
	end	
	--]]
end

function collision.direction.rectangles2(left1,top1,width1,height1,xspeed1,yspeed1, left2,top2,width2,height2,xspeed2,yspeed2)
	--local xoverlap,yoverlap = collision.rectanglesOverlap(left1,top1,width1,height1,left2,top2,width2,height2)
	--[
	local relxspeed = xspeed1-xspeed2
	local relyspeed = yspeed1-yspeed2
	local xoverlap,yoverlap
	if relxspeed > 0 then
		xoverlap = left1+width1-left2
	else
		xoverlap = left2+width2-left1
	end

	if relyspeed > 0 then
		yoverlap = top1+height1-top2
	else
		yoverlap = top2+height2-top1
	end

	local xtime = math.abs(xoverlap/relxspeed)
	local ytime = math.abs(yoverlap/relyspeed)
	
	if xtime < ytime then --it's an x direction collision
		if relxspeed > 0 then
			return 'left'
		elseif relxspeed < 0 then
			return 'right'
		end
	elseif ytime < xtime then  --it's a y direction collision
		if relyspeed > 0 then
			return 'top'
		elseif relyspeed < 0 then
			return 'bottom'
		end
	end

	--]]
end

function collision.direction.pointRectangle(px,py,pxspeed,pyspeed, left,top,width,height,xspeed,yspeed) 
	
	local relxspeed = pxspeed-xspeed
	local relyspeed = pyspeed-yspeed

	if relxspeed > 0 then
		xoverlap = px-left
	else
		xoverlap = left+width-px
	end

	if relyspeed > 0 then
		yoverlap = py-top
	else
		yoverlap = top+height-py
	end

	local xtime = math.abs(xoverlap/relxspeed)
	local ytime = math.abs(yoverlap/relyspeed)
	
	if xtime < ytime then --it's an x direction collision
		if relxspeed > 0 then
			return 'left'
		else
			return 'right'
		end
	else  --it's a y direction collision
		if relyspeed > 0 then
			return 'top'
		else
			return 'bottom'
		end
	end


	--[[
	if px < left and py > top and py < top + height then
		return 'left'
	elseif px > left + width and py > top and py < top + height then
		return 'right'
	elseif py < top and px > left and px < left + width then
		return 'top'
	elseif py > top + height and px > left and px < left + width then
		return 'bottom'
	end
	--]]
end
--(v.x+(v.width/2)) > (player.x - (player.width/2)) and (v.x-(v.width/2)) < (player.x + (player.width/2)) and (v.y-(v.height/2)) < (player.y+(player.height/2)) and (v.y+(v.height/2)) > (player.y - (player.height/2))


function collision.circles(centerx1,centery1,radius1, centerx2,centery2,radius2)
	return (  ( ((centerx1-centerx2)^2) + ((centery1-centery2)^2) )^0.5 < (radius1 + radius2) )
end

function collision.rectangleCircle(left1,top1,width1,height1, centerx2,centery2,radius2) 
--Just an approximation
	return collision.rectangles(left1,top1,width1,height1, centerx2-radius2,centery2-radius2, radius2*2, radius2*2)
end

function collision.pointRectangle(x,y,  left,top,width,height)
	return (x < left+width and x > left and y > top and y < top + height)
end

function collision.pointCircle(x,y, centerx,centery,radius)
	return (  ( ((x-centerx)^2) + ((y-centery)^2) ) < radius )
end

function collision.lineSegments(ax,ay,bx,by, ox,oy,px,py)
	if (ax > ox and ax > px and bx > ox and bx > px) or (ax < ox and ax < px and bx < ox and bx < px) or (ay > oy and ay > py and by > oy and by > py) or (ay < oy and ay < py and by < oy and by < py) then
		return false
		
	elseif false then
	
		local aprop = (ax - ox)/(ox-px)
		aabove = ay < oy + (oy-py)*aprop
		
		
		local bprop = (bx - ox)/(ox-px)
		babove = by < oy + (oy-py)*bprop
		
		return aabove ~= babove, aabove,babove, aprop, bprop
	else
	
		-- y = mx + b
		-- b = y - mx
		local abslope = (ay-by)/(ax-bx)
		local abyinter = ay - abslope*ax
		
		local opslope = (oy-py)/(ox-px)
		local opyinter = oy - opslope*ox
		
		if abslope == opslope then
			return abyinter == opyinter
			
		else
			--  abslope * x + abyinter = opslope * x + opyinter
			local solux = (opyinter-abyinter)/(abslope-opslope)
			local soluy = abslope * solux + abyinter
			return ((solux > ox and solux < px) or (solux > px and solux < ox)) and ((solux > ax and solux < bx) or (solux < ax and solux > bx)), solux, soluy
		end
		
	end
	
	--[[
	ox + (ox-px) * prop == ax
	prop == (ax - ox)/(ox-px)
	
	linex = ax
	liney = oy + (oy-py)*prop
	--]]
	
	--[[
	x1 =  (ax < ox and bx > px)
	x2 =  (ax < px and bx > ox)
	x3 =  (ax > ox and bx < px)
	x4 =  (ax > px and bx < ox)
	--x =  (ax < ox and bx > px) or (ax < px and bx > ox) or (ax > ox and bx < px) or (ax > px and bx < ox)
	--y =  (ay < oy and by > py) or (ay < py and by > oy) or (ay > oy and by < py) or (ay > py and by < oy)
	y1 =  (ay < oy and by > py)
	y2 =  (ay < py and by > oy)
	y3 =  (ay > oy and by < py)
	y4 =  (ay > py and by < oy)
	return x1,x2,x3,x4,y1,y2,y3,y4	
	--]]
end


function collision.polygons(array1,array2)
	local i = 1
	while i <= #array1-3 do
			
		local n = 1
		while n <=	# array2-3  do
			if collision.lineSegments(array1[i],array1[i+1],array1[i+2], array1[i+3], array2[n],array2[n+1],array2[n+2], array2[n+3]) then
				return true
			end
			n = n + 4
		end
		
		i = i + 4
	end
	
	return false
end
function collision.getBoundingBox(array)
	local left = array[1]
	local right = array[1]
	local top = array[2]
	local bottom = array[2] 
	local odd = true
	for i,v in pairs(array) do
		if odd then
			if v < left then
				left = v
			elseif v > right then
				right = v
			end
		else
			if v < top then
				top = v
			elseif v > bottom then
				bottom = v
			end
		end
		odd = not odd
	end
	
	return left, top, right-left, bottom-top
end
