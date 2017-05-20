
love.graphics.setBackgroundColor(0,0,0)

love.graphics.clear()

love.graphics.setColor(10,210,150)
love.graphics.rectangle("fill",25,25,100,15)

love.graphics.setColor(0,0,0)
love.graphics.printf("Loading Editor",25,26,100,'center')
	
love.graphics.present()
	

io.stdout:setvbuf("no")

function requireDirectory(dirPath, isRecursive)
	local dirItems = love.filesystem.getDirectoryItems(dirPath)
	for i,v in ipairs(dirItems) do
		if love.filesystem.isFile(dirPath .. '/' .. v) and string.sub(v,string.len(v)-3) == '.lua' then
			require(dirPath .. '/' .. string.sub(v,1,string.len(v)-4))
			print("Required " .. dirPath .. '/' .. string.sub(v,1,string.len(v)-4))
		elseif love.filesystem.isDirectory(dirPath .. '/' .. v) then
			if isRecursive then
				requireDirectory(dirPath .. '/' .. v,true)
			else
				print("Skipped " .. dirPath .. '/' .. v ..  " because we're not doing it recursively")
			end
		else
			print("Is not a file or directory?? : " .. dirPath .. '/' .. v )
		end
	end
end
local path
LUA_PATH, path = "?;?.lua",LUA_PATH
--requireDirectory("game") ---not recursive because Enemies are loaded after enemies.load is called
--requireDirectory("lib", true)
LUA_PATH, path = path, LUA_PATH

require('debug')
require('1stPartyLib/utilities/math')
function love.load()
	IMAGES_PATH = 'Assets/Images/'
	lovefunctions = {'keypressed','keyreleased','mousepressed','mousereleased'}
	--require('1stPartyLib/physics/collision')
	--require('resources')
	requireDirectory('1stPartyLib/display')
	
	window = {}
	window.width, window.height = love.graphics.getDimensions()
	window.fullscreen = false
	
	-- FPS cap
	min_dt = 1/60
	next_time = love.timer.getTime()

	MOUSE = {}
	MOUSE.x, MOUSE.y = love.mouse.getPosition()

	STATE = require('States/editor') --require("Game/States/game")
	STATE.load()
	--resources.load()
	--music.fight.music:play()
	
	--love.mouse.setVisible(false)
	--lovefunctions = {"mousepressed","mousereleased","keypressed","keyreleased"}
	
	--states.loadingscreen.load('titlemenu',1.5)
	--states.empty.load()
	
end

function love.update(dt)
	--  FPS cap
	next_time = next_time + min_dt	

	MOUSE.x, MOUSE.y = love.mouse.getPosition()
	STATE.update(dt)

	
	love.window.setTitle(love.timer.getFPS())

	if QUIT then
		love.event.quit()
	end
end


function love.draw()
	STATE.draw()
	--[[
	states[state].draw()	

	------Draw Cool Cursor Thing--------
	local x,y = love.mouse.getPosition()

	local ang = (love.timer.getTime()*5) or love.timer.getTime()+ math.sin(love.timer.getTime())*5
	
	ang = math.pi/12
	
	love.graphics.setColor((math.sin(ang)+1)*127,(math.cos(ang/2)+1)*127,math.sin(love.timer.getTime())*100+10)
	--local xd,yd = (40*math.cos(ang)),(40*math.cos(ang/2))
	local xd,yd = math.abs(20*math.cos(ang)),math.abs(20*math.cos(ang/2))

	drawBlur.ellipse(x,y,xd,yd,ang,nil,15, {255,255,255},{255,0,0,0})
	love.graphics.setColor(255,255,255)
	love.graphics.ellipse("fill",x,y,xd,yd,ang)
	drawBlur.ellipse(x,y,xd-math.min(10,xd),yd-math.min(10,yd/2),ang,nil,math.min(5,yd,xd), {0,0,0,0},{255,255,255})
	love.graphics.setColor(0,0,0)
	love.graphics.ellipse("fill",x,y,xd-math.min(10,xd/2),yd-math.min(10,yd/2),ang)
	------------------------------------------------------------------------------
	
	love.graphics.setColor(0,0,0)
	love.graphics.circle("fill",x,y,2)

--]]
	--[[
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",0,0,window.width,window.height)
	
	local width,height = 50,50
	local blurwidth = 30
	
	love.graphics.setColor(200,200,200)
	love.graphics.rectangle("fill",window.width/4-width/2,window.height/2-height/2,width,height)
	love.graphics.rectangle("fill",3*window.width/4-width/2,window.height/2-height/2,width,height)
	
	drawBlur.rectangleInversePower(window.width/4-width/2,window.height/2-height/2,width,height, blurwidth,{255,255,0},{255,255,0,0},0.5)
	drawBlur.rectangleInversePower(3*window.width/4-width/2,window.height/2-height/2,width,height, blurwidth,{255,255,0},{255,255,0,0},-0.1)
	--]]
	
	
	-- FPS cap
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(1*(next_time - cur_time))
end


function love.keypressed(key)
	if STATE.keypressed then
		STATE.keypressed(key)
	end
	if key == 'escape' then
		love.event.quit()
	end
end	

function love.keyreleased(key)
	if STATE.keyreleased then
		STATE.keyreleased(key)
	end
end

function love.textinput(test)
	if STATE.textinput then
		STATE.textinput(text)
	end
end

function love.mousepressed(x,y,b)
	if STATE.mousepressed then
		STATE.mousepressed(x,y,b)
	end
end

function love.mousereleased(x,y,b)
	if STATE.mousereleased then
		STATE.mousereleased(x,y,b)
	end
end

function love.textinput(text)
	if STATE.textinput then
		STATE.textinput(text)
	end
	--TYPED = TYPED .. text
end


function love.quit()
	--execute this on quit
	os.execute('echo hat')
end


function love.processEvents()
	if love.event then
		love.event.pump()
		for e,a,b,c,d in love.event.poll() do
			if e == "quit" then
				if not love.quit or not love.quit() then
					if love.audio then
						love.audio.stop()
					end
					QUIT = true
				end
			end
			love.handlers[e](a,b,c,d)
		end
	end
end

function love.run()
    math.randomseed(os.time())
    math.random() math.random()

    if love.load then love.load(arg) end

    local dt = 0
    -- Main loop time.
    while not QUIT do	
        love.processEvents()

        -- Update dt, as we'll be passing it to update
        love.timer.step()
        dt = love.timer.getDelta()

        -- Call update and draw
		love.update(dt)
		
		love.graphics.clear()
		love.draw()
			
		love.graphics.present()
    end
end


function love.filesystem.removeDirectory(directory)
	local files = love.filesystem.getDirectoryItems(directory)

	for i,v in ipairs(files) do
		local ok
		local path = directory .. '/' .. v
		if love.filesystem.isFile(path) then
			ok = love.filesystem.remove(path)
		elseif love.filesystem.isDirectory(path) then
			ok = love.filesystem.removeDirectory(path)
		end
		if not ok then
			return ok, tostring(ok) .. "  " .. path
		end
	end

	return love.filesystem.remove(directory)


end
