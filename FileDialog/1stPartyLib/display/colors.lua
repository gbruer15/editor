colors = {}

function colors.getPulsingColors(incolor,outcolor,timefactor,outsin)
		
	incolor[4] = incolor[4] or 255
	outcolor[4] = outcolor[4] or 255
	timefactor = timefactor or 1
	outsin = outsin or 1
	
	local r = incolor[1] + (outcolor[1]-incolor[1])/2*(1+math.sin(love.timer.getTime()*timefactor)*outsin)
	local g = incolor[2] + (outcolor[2]-incolor[2])/2*(1+math.sin(love.timer.getTime()*timefactor)*outsin)
	local b = incolor[3] + (outcolor[3]-incolor[3])/2*(1+math.sin(love.timer.getTime()*timefactor)*outsin)
	local a = incolor[4] + (outcolor[4]-incolor[4])/2*(1+math.sin(love.timer.getTime()*timefactor)*outsin)
	
	

	return {r,g,b,a}
end