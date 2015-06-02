bezier = {}

function bezier.makeFunctions(points)
	local n = #points/2 - 1 -- n is number of points - 1 so that counting starts at 0
	local coeff = bezier.getBezierBinomialCoefficients(n)
	local xStr = "return function(t) return\n"
	local yStr = "return function(t) return\n"

	xStr = xStr .. "     (1-t)^" .. (n-0) .. "*t^" .. 0 .. "*" .. points[0*2+1] .. "\n"
	yStr = yStr .. "     (1-t)^" .. (n-0) .. "*t^" .. 0 .. "*" .. points[0*2+2] .. "\n"
	for i=1,n do
		xStr = xStr .. "    +" .. coeff[i+1] .. "*(1-t)^" .. (n-i) .. "*t^" .. i .. "*" .. points[i*2+1] .. "\n"
		yStr = yStr .. "    +" .. coeff[i+1] .. "*(1-t)^" .. (n-i) .. "*t^" .. i .. "*" .. points[i*2+2] .. "\n"
	end
	xStr = xStr .. "end"
	yStr = yStr .. "end"

	local xFunc,err = loadstring(xStr)
	local yFunc,err1 = loadstring(yStr)
	if err then
		error(err .. "\t" .. err1)
	end
	xFunc = xFunc()
	yFunc = yFunc()
	
	return xFunc,yFunc
end

function bezier.drawBezier(arg)
	local n = #arg/2 - 1 -- n is number of points - 1 so that counting starts at 0
	local coeff = getBezierBinomialCoefficients(n)
	local xStr = "return function(t) return\n"
	local yStr = "return function(t) return\n"

	xStr = xStr .. "     (1-t)^" .. (n-0) .. "*t^" .. 0 .. "*" .. arg[0*2+1] .. "\n"
	yStr = yStr .. "     (1-t)^" .. (n-0) .. "*t^" .. 0 .. "*" .. arg[0*2+2] .. "\n"
	for i=1,n do
		xStr = xStr .. "    +" .. coeff[i+1] .. "*(1-t)^" .. (n-i) .. "*t^" .. i .. "*" .. arg[i*2+1] .. "\n"
		yStr = yStr .. "    +" .. coeff[i+1] .. "*(1-t)^" .. (n-i) .. "*t^" .. i .. "*" .. arg[i*2+2] .. "\n"
	end
	xStr = xStr .. "end"
	yStr = yStr .. "end"
	
	local xFunc,err = loadstring(xStr)
	local yFunc,err1 = loadstring(yStr)
	if err then
		error(err .. "\t" .. err1)
	end
	xFunc = xFunc()
	yFunc = yFunc()
	
	local t = 0
	local dt = 0.01
	
	while t < 1 do
		love.graphics.circle("fill",xFunc(t),yFunc(t),2)
		--print(xFunc(t) .. "\t" .. yFunc(t))
		t = t + dt
	end
end

function bezier.getBezierBinomialCoefficients(n) -- gets binom coeff from n choose 0 to n choose n
	local coeff = {}
	table.insert(coeff,1) -- n choose 0 is 1
	for k=1,n-1 do
		local c = 1
		for i=1,k do
			c = c * (n+1-i)/i
		end
		table.insert(coeff,c)
	end
	table.insert(coeff,1) -- n choose n is 1
	return coeff --coeff goes from 1 to n+1
end
