
function initializePhysics(meter)
	objects = {}
	metersize = meter/9.8  -- pixel to meter ratio
	GRAVCONSTANT = metersize --meters per second per second
	FORCECONSTANT = metersize --newtons
end


function createObject(traitlist) --grav is pixels per second per second,  rotation speed is in radians per second
	
		
	table.insert(objects, {})
	local n = #objects
	
	objects[n] = {xspeed = traitlist.xspeed or 0, yspeed = traitlist.yspeed or 0,xgravity = traitlist.xgrav or 0, ygravity = traitlist.ygrav or 0, x = traitlist.x or 0, y = traitlist.y or 0, mass = traitlist.mass or 1,rotation = traitlist.rotation or 0, rotationspeed = traitlist.rotationspeed or 0, bounciness = traitlist.bounciness or 1, airdamping = traitlist.airdamping or 0, shapepoints = traitlist.shapepoints or {}, kind = "movable", shape = traitlist.shape or 'polygon', color = traitlist.color}
	return objects[n]
end

function createImmovableObject(traitlist) --grav is pixels per second per second,  rotation speed is in radians per second
	
		
	table.insert(objects, {})
	local n = #objects
	
	if traitlist.shapepoints == nil then
		error("You didn't give me a shape info")
	end
	
	objects[n] = [[xspeed = traitlist.xspeed or 0, 
	yspeed = traitlist.yspeed or 0,
	xgravity = traitlist.xgrav or 0, 
	ygravity = traitlist.ygrav or 0, 
	x = traitlist.x or 0, 
	y = traitlist.y or 0,
	mass = traitlist.mass or 1,
	rotation = traitlist.rotation or 0, 
	rotationspeed = traitlist.rotationspeed or 0, 
	bounciness = traitlist.bounciness or 1, 
	airdamping = traitlist.airdamping or 0, 
	shapepoints = traitlist.shapepoints, 
	kind = "immovable", 
	shape = traitlist.shape or 'polygon', 
	color = traitlist.color]]
	
	return objects[n]
end


function updatePhysics(dt)
	for i,thing in pairs(objects) do
		thing.x = thing.x + thing.xspeed*dt * metersize
		thing.y = thing.y + thing.yspeed*dt * metersize
		
		if mass~=0 then
			--thing.xspeed = thing.xspeed + thing.xgravity*dt*GRAVCONSTANT
			--thing.yspeed = thing.yspeed + thing.ygravity*dt*GRAVCONSTANT
			applyForce(thing,thing.xgravity*thing.mass*GRAVCONSTANT, thing.ygravity*thing.mass*GRAVCONSTANT,dt)
		end
		
		thing.xspeed = thing.xspeed*(1-thing.airdamping)
		thing.yspeed = thing.yspeed*(1-thing.airdamping)
		
		thing.rotation = thing.rotation + thing.rotationspeed*dt
		thing.rotation = thing.rotation - (math.floor(thing.rotation/(2*math.pi))*2*math.pi)
		
	end
	
	
end

function updateObject(thing, dt)

	if thing.mass~=0 then
		applyForce(thing,thing.xgravity*thing.mass*GRAVCONSTANT, thing.ygravity*thing.mass*GRAVCONSTANT,dt)
	end

	thing.x = thing.x + (thing.xspeed)*dt * metersize
	thing.y = thing.y + (thing.yspeed)*dt * metersize
	
	thing.xspeed = thing.xspeed*(1-thing.airdamping)
	thing.yspeed = thing.yspeed*(1-thing.airdamping)
	
	thing.rotation = thing.rotation + thing.rotationspeed*dt
	thing.rotation = thing.rotation - (math.floor(thing.rotation/(2*math.pi))*2*math.pi)
end

function applyForce(object, xforce, yforce,dt)
	if mass ~=0 then
		object.xspeed = object.xspeed + (xforce/object.mass)*dt*FORCECONSTANT
		object.yspeed = object.yspeed + (yforce/object.mass)*dt*FORCECONSTANT
	else
		object.xspeed = object.xspeed + xforce*dt*FORCECONSTANT
		object.yspeed = object.yspeed + yforce*dt*FORCECONSTANT
	end
end

function drawObject(thing)
	if thing.color then
		love.graphics.setColor(unpack(thing.color))
	else
		love.graphics.setColor(255,255,255)
	end
	
	if thing.shape =='circle' then
		love.graphics.circle("fill", thing.x, thing.y, thing.shapepoints)
	elseif thing.shape=='rectangle' then
		love.graphics.rectangle('fill', thing.x + thing.shapepoints[1], thing.y + thing.shapepoints[2], thing.shapepoints[3], thing.shapepoints[4])
	elseif thing.shape=='polygon' then
		local n = 1
		local list = {}
		
		while n <= #thing.shapepoints do
			if n/2 == math.floor(n/2) then
				table.insert(list, thing.shapepoints[n]+thing.y)
			else 
				table.insert(list, thing.shapepoints[n]+thing.x)
			end
			n = n + 1
		end
		
		love.graphics.line(unpack(list))
	end
end

function drawAllObjects()
	for i,thing in pairs(objects) do
		if thing.color then
			love.graphics.setColor(unpack(thing.color))
		else
			love.graphics.setColor(255,255,255)
		end
		if thing.shape =='circle' then
			love.graphics.circle("fill", thing.x, thing.y, thing.shapepoints)
		elseif thing.shape=='rectangle' then
			love.graphics.rectangle('fill', thing.x + thing.shapepoints[1], thing.y + thing.shapepoints[2], thing.shapepoints[3], thing.shapepoints[4])
		elseif thing.shape=='polygon' then
			local n = 1
			local list = {}
			
			while n <= #thing.shapepoints do
				if n/2 == math.floor(n/2) then
					table.insert(list, thing.shapepoints[n]+thing.y)
				else 
					table.insert(list, thing.shapepoints[n]+thing.x)
				end
				n = n + 1
			end
			
			love.graphics.line(unpack(list))
		end
	end
end

function whenObjectsCollide(object1, object2)
	



end
