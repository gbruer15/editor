	
function textinput(maxchar)
	local maxchar = maxchar or 256
	local acceptableinput = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','1','2','3','4','5','6','7','8','9','0',' '}
	local oldkeypressed = love.keypressed
	local oldmousepressed = love.mousepressed

	local inputstring = ""
	local insertat = 0
	function love.keypressed(key)
		if key == 'escape' then
			love.event.quit()
		elseif key == 'backspace' then
			if string.len(inputstring) > 0 and insertat > 0 then
				print(insertat)
				inputstring = string.sub(inputstring,1,insertat-1) .. string.sub(inputstring,insertat+1)
				insertat = math.max(insertat-1,0)
				back = love.timer.getTime()
			end
		elseif key == 'delete' then
			if string.len(inputstring) > 0  then
				inputstring = string.sub(inputstring,1,insertat) .. string.sub(inputstring,insertat+2)
				back = love.timer.getTime()
			end
		elseif key == 'return' and string.len(inputstring) > 0 then
			done = true
		elseif  key == 'left' then
			insertat = math.max(insertat - 1,0)
		elseif  key == 'right' then
			insertat = math.min(insertat + 1,string.len(inputstring))
		else
			for i,v in ipairs(acceptableinput) do
				if key == v then 
					if string.len(inputstring) < maxchar then
						if love.keyboard.isDown('lshift') or love.keyboard.isDown('shift') then
							key = key:upper()
						end
						inputstring = string.sub(inputstring,1,insertat) .. key .. string.sub(inputstring,insertat+1)
						insertat = insertat + 1
					end
					return
				end
			end
		end
	end
	function love.mousepressed(x,y,button)
	end

	love.graphics.setColor(200,200,200,100)
	love.graphics.rectangle("fill", 0,0,window.width,window.height)
	love.graphics.present()
	love.graphics.setColor(200,200,200,100)
	love.graphics.rectangle("fill", 0,0,window.width,window.height)

	done = false

	local rectwidth = 600
	local rectheight = 300

	local lineon = false
	back = true
	while not done and not QUIT do
		next_time = next_time + min_dt

		
		love.processEvents()
		love.timer.step()
		dt = love.timer.getDelta()
		
		love.graphics.setCaption(love.timer.getFPS())
		love.graphics.setColor(220,220,220)
		love.graphics.draw(greenrect.pic,window.width/2-rectwidth/2, window.height*0.4-rectheight/2, 0,rectwidth/greenrect.width,rectheight/greenrect.height)
		
		love.graphics.setColor(0,0,0)
		love.graphics.setFont(impactfont[36])
		love.graphics.print("Type level name and press Enter.",window.width/2 - impactfont[36]:getWidth("Type level name and press Enter.")/2,window.height*0.4-rectheight/2 + 54)
		
		
		love.graphics.setColor(255,255,255)
		love.graphics.rectangle("fill", window.width/2 - rectwidth*0.8/2, window.height*0.4-10, rectwidth*0.8, 40)
		
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("line", window.width/2 - rectwidth*0.8/2, window.height*0.4-10, rectwidth*0.8, 40)
		
		love.graphics.setFont(neographfont[36])
		if lineon then
			love.graphics.printf(string.sub(inputstring,1,insertat) .. "|" .. string.sub(inputstring,insertat+1),0,window.height*0.4-10-6,window.width,'center')
			if love.timer.getTime() - 0.5 > math.floor(love.timer.getTime()) then
				lineon = false
			end
		else
			--love.graphics.print(inputstring, window.width/2-neographfont[36]:getWidth(inputstring)/2, window.height*0.4-10-6)
			love.graphics.printf(inputstring,0,window.height*0.4-10-6,window.width,'center')
			if love.timer.getTime() - 0.5 <= math.floor(love.timer.getTime()) then
				lineon = true
			end
		end
		
		if back ~= true then
			if love.timer.getTime()-back > 0.2 then
				back = true
			end
		end
		
		if love.keyboard.isDown('backspace') then
			if back == true then
				inputstring = string.sub(inputstring,1,string.len(inputstring)-1)
				back = love.timer.getTime()
			end
		end
		
		
		if not done then
			love.graphics.present()
		end
		
		-- FPS cap
		local cur_time = love.timer.getMicroTime()
		if next_time <= cur_time then
			next_time = cur_time
		end
		love.timer.sleep(1*(next_time - cur_time))
	end

	love.keypressed = oldkeypressed
	love.mousepressed = oldmousepressed
	return inputstring
end
