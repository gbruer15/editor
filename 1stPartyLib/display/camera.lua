local camera = {}
camera._index = camera

function camera.make(att)
	att = att or {}

	camera.offset = {x=0,y=0}
	camera.aimoffset = {x=0,y=0}
	camera.offset.speed = 300

	camera.width = att.width or love.window.getWidth()
	camera.height = att.height or love.window.getHeight()

	camera.x = att.x or camera.width/2
	camera.y = att.y or camera.height/2

	camera.lock = true

	return camera
end


function camera.update(dt)

	camera.x, camera.y = player.x, player.y-100
	if camera.y < -50  and camera.lock then
		--camera.offset.y = camera.offset.y + camera.offset.speed
	end
	if camera.offset.y > 100 and camera.lock then
		camera.offset.y = 100
	end
	if player.y - player.height/2 < camera.y - camera.height/2 and camera.lock then
		camera.y = player.y - player.height/2 + camera.height/2
	end
	
	
	if love.keyboard.isDown("left") then
		camera.offset.x = camera.offset.x - camera.offset.speed*dt
	end
	if love.keyboard.isDown("right") then
		camera.offset.x = camera.offset.x + camera.offset.speed*dt
	end
	if love.keyboard.isDown("up") then
		camera.offset.y = camera.offset.y - camera.offset.speed*dt
	end
	if love.keyboard.isDown("down") then
		camera.offset.y = camera.offset.y + camera.offset.speed*dt
	end
	
	if math.abs(camera.offset.y) > camera.height*0.4 then
		camera.offset.y = camera.height*0.4*math.getSign(camera.offset.y)
	end
	if math.abs(camera.offset.x) > camera.width*0.4 then
		camera.offset.x = camera.width*0.4*math.getSign(camera.offset.x)
	end
	if camera.lock then
		camera.offset.x = math.floor(camera.offset.x - camera.offset.speed*dt*math.getSign(camera.offset.x-camera.aimoffset.x)/2)
		camera.offset.y = math.floor(camera.offset.y  - camera.offset.speed*dt*math.getSign(camera.offset.y - camera.aimoffset.y)/2)
	end
	camera.x = camera.x + camera.offset.x
	camera.y = camera.y + camera.offset.y
	
end

function camera.set()
	love.graphics.push()
		
	love.graphics.translate(camera.width/2, camera.height/2)
	love.graphics.scale(1,1)
	love.graphics.translate(-camera.width/2, -camera.height/2)
	
	love.graphics.translate(camera.width/2-camera.x, camera.height/2 - camera.y)
end


function camera.unset()
	love.graphics.pop()
end

function camera.isOffscreen (x,y)
	return not collision.pointRectangle(x,y, camera.x-camera.width/2, camera.y-camera.height/2, camera.width,camera.height)
end

function camera.getRect()
	return camera.x-camera.width/2,camera.y-camera.height/2,camera.width,camera.height
end

return camera