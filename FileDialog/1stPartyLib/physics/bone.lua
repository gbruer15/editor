
bone = {}
bone.__index = bone

function bone.make(att)
	local self = {}
	setmetatable(self,bone)
	
	self.id = att.id or 'no ID'
	self.parent = att.parent or false
	self.children = att.children or false
	
	if self.parent then
		table.insert(self.parent.children, self)
	end
	
	self.startPoint = att.startPoint or (self.parent and self.parent.endPoint) or {0,0} --this should choose between starting at endPoint or startPoint)
	self.relAngle = att.relAngle or 0
	self.bodyRelAngle = att.bodyRelAngle or 0
	
	if not att.endPoint and att.length then
		self.length = att.length
		if not att.absAngle and self.parent and self.relAngle then
			self.absAngle = self.parent.absAngle + self.relAngle
		elseif not att.absAngle and self.parent then
			self.relAngle = 0
			self.absAngle = self.parent.absAngle + self.relAngle
		else
			self.absAngle = att.absAngle or 0
		end
		self.endPoint = {}
		self.endPoint[1] = self.startPoint[1] + self.length*math.cos(self.absAngle)
		self.endPoint[2] = self.startPoint[2] + self.length*math.sin(self.absAngle)
	elseif not att.endPoint and att.absAngle then
		self.length = 10
		self.endPoint = {}
		self.endPoint[1] = self.startPoint[1] + self.length*math.cos(self.absAngle)
		self.endPoint[2] = self.startPoint[2] + self.length*math.sin(self.absAngle)
	elseif not att.endPoint and self.parent and att.relAngle and not self.children then
		self.length = 10
		self.absAngle = self.parent.absAngle + self.relAngle
		
		self.endPoint = {}
		self.endPoint[1] = self.startPoint[1] + self.length*math.cos(self.absAngle)
		self.endPoint[2] = self.startPoint[2] + self.length*math.sin(self.absAngle)
	elseif not att.endPoint and self.children and #self.children == 1 then
		self.endPoint = {}
		self.endPoint[1] = self.children[1].startPoint[1]
		self.endPoint[2] = self.children[1].startPoint[2]
		self.absAngle = math.atan2(self.endPoint[2]-self.startPoint[2],self.endPoint[1]-self.startPoint[1])
		self.length = math.sqrt((self.startPoint[2]-self.endPoint[2])^2+(self.startPoint[1]-self.endPoint[1])^2)
	else
		self.endPoint = att.endPoint or {0,0}
		self.absAngle = math.atan2(self.endPoint[2]-self.startPoint[2],self.endPoint[1]-self.startPoint[1])
		self.length = math.sqrt((self.startPoint[2]-self.endPoint[2])^2+(self.startPoint[1]-self.endPoint[1])^2)
	end
	
	if self.children then
		if not att.noConnection then
			for i,v in ipairs(self.children) do
				v.relAngle = v.absAngle-self.absAngle
				
				--[[
				v.upperConstraint = v.lowerConstraint and v.relAngle+v.lowerConstraint-- -v.relAngle+(v.absAngle-v.lowerConstraint)
				v.lowerConstraint = v.upperConstraint and v.relAngle+v.upperConstraint
				
				v.upperConstraint = v.upperConstraint and v.upperConstraint + math.pi
				v.lowerConstraint = v.lowerConstraint and v.lowerConstraint + math.pi
				--]]
				
				v.lowerConstraint = v.lowerConstraint and v.lowerConstraint-self.absAngle
				v.upperConstraint = v.upperConstraint and v.upperConstraint-self.absAngle
				
				
				v.startPoint = self.endPoint
				v.parent = self
			end
		else
			local oldchildren = {}
			
			for i,v in ipairs(self.children) do
				oldchildren[i] = self.children[i]
			end
			self.children = {}
			for i,v in ipairs(oldchildren) do
				bone.make{id = v.id .. ' struct for ' .. self.id, parent=self,children={v},relAngle=math.atan2(-self.endPoint[2]+v.startPoint[2],-self.endPoint[1]+v.startPoint[1])-self.absAngle}
			end
		end
	end
	self.children = self.children or {}
	--self.pivotPoint = att.pivotPoint or self.startPoint
	
	self.relAngle = self.relAngle or att.relAngle or 0
	
	self.aspeed = att.aspeed or 0
	self.adamp = att.adamp or 1
	
	self.upperConstraint = att.upperConstraint or false
	self.lowerConstraint = att.lowerConstraint or false
	
	return self
end

function bone:setStartPoint(x,y)
	self.startPoint = {x,y}
	self.absAngle = math.atan2(self.endPoint[2]-self.startPoint[2],self.endPoint[1]-self.startPoint[1])
	self.length = math.sqrt((self.startPoint[2]-self.endPoint[2])^2+(self.startPoint[1]-self.endPoint[1])^2)
end

function bone:setEndPoint(x,y)
	self.endPoint = {x,y}
	self.absAngle = math.atan2(self.endPoint[2]-self.startPoint[2],self.endPoint[1]-self.startPoint[1])
	self.length = math.sqrt((self.startPoint[2]-self.endPoint[2])^2+(self.startPoint[1]-self.endPoint[1])^2)
end

function bone:setRelAngle(newRelAngle, changeChildren)
	--self.absAngle = self.absAngle + (newRelAngle - self.relAngle)

	self.relAngle = newRelAngle
	self:update(0)
end

function bone:setParent(parentBone)
	if self.parent then		
		for i,v in ipairs(self.parent.children) do
			if v == self then
				table.remove(self.parent.children,i)
				break
			end
		end
	end
	self.parent = parentBone
	table.insert(parentBone.children, self)
	parentBone:updateChildren()

end

function bone:addChild(childBone)
	table.insert(self.children, childBone)
	
	if childBone.parent then
		for i,v in ipairs(childBone.parent.children) do
			if v == childBone then
				table.remove(childBone.parent.children,i)
				break
			end
		end
	end
	childBone.parent = self
	
	self:updateChildren()
end

function bone:setBodyRelAngle(newAngle)
	self.relAngle = self.relAngle + (newAngle-self.bodyRelAngle)
	self.absAngle = self.absAngle + (newAngle-self.bodyRelAngle)
	self.bodyRelAngle = newAngle
	
	--print(self.id .. ' ' .. self.bodyRelAngle .. ' anim update: ')
	
	self:update(0)
	--print(self.id .. ' ' .. self.bodyRelAngle .. ' anim update: ')
end

function bone:update(dt)
	self.aspeed = self.aspeed*(1 - self.adamp*dt)
	
	if self.parent then
		self.relAngle = self.relAngle + self.aspeed*dt
		if self.upperConstraint and self.relAngle > self.upperConstraint then
			self.relAngle = self.upperConstraint
			self.aspeed = 0
		elseif self.lowerConstraint and self.relAngle < self.lowerConstraint then
			self.relAngle = self.lowerConstraint
			self.aspeed = 0
		end
	else
		self.absAngle = self.absAngle + self.aspeed*dt
	end
	
	if self.body then
		--self.bodyRelAngle = self.absAngle-self.body.angle
	end
	
	self.endPoint[1] = self.startPoint[1] + self.length*math.cos(self.absAngle)
	self.endPoint[2] = self.startPoint[2] + self.length*math.sin(self.absAngle)
	
	self:updateChildren(dt)
end

function bone:updateChildren(dt)
	for i,v in ipairs(self.children) do
		v.absAngle = self.absAngle + v.relAngle
		v.startPoint = self.endPoint
		v:update(dt)
		--v:updateChildren(dt)
	end
end

function bone:draw(drawChildren)
	love.graphics.setColor(255,255,255)
	love.graphics.setLineWidth(1)
	
	love.graphics.line(self.startPoint[1],self.startPoint[2],self.endPoint[1],self.endPoint[2])
	
	love.graphics.setColor(200,200,0,200)
	love.graphics.circle("line", self.startPoint[1],self.startPoint[2],4)
	
	love.graphics.setColor(200,0,0,200)
	love.graphics.circle("fill", self.endPoint[1],self.endPoint[2],2)
	
	if drawChildren and self.children then
		self:drawChildren()
	end
end

function bone:drawChildren()
	for i,v in ipairs(self.children) do
		v:draw(true)
		v:drawChildren()
	end
end

function bone:flipXYChildren(cx,cy)
	for i,b in ipairs(self.children) do
		b:setStartPoint(cx-(b.startPoint[1]-cx),cy-(b.startPoint[2]-cy))
		b:setEndPoint(cx-(b.endPoint[1]-cx),cy-(b.endPoint[2]-cy))
		b.upperConstraint,b.lowerConstraint = b.lowerConstraint and -b.lowerConstraint, b.upperConstraint and -b.upperConstraint
		b:setRelAngle(-b.relAngle)
		--b:setBodyRelAngle(-b.bodyRelAngle)
		b:flipXYChildren(cx,cy)
	end
end

function bone:flipXChildren(cx)
	for i,b in ipairs(self.children) do
		b:setStartPoint(cx-(b.startPoint[1]-cx),b.startPoint[2])
		b:setEndPoint(cx-(b.endPoint[1]-cx),b.endPoint[2])
		b.upperConstraint,b.lowerConstraint = b.lowerConstraint and -b.lowerConstraint, b.upperConstraint and -b.upperConstraint
		b:setRelAngle(-b.relAngle)
		--b:setBodyRelAngle(-b.bodyRelAngle)
		b:flipXChildren(cx)
	end
end




bonePicture = {}
bonePicture.__index = bonePicture

function bonePicture.make(pic,att)
	local self = {}
	setmetatable(self,bonePicture)
	
	self.pic = pic
	self.picwidth = self.pic:getWidth()
	self.picheight = self.pic:getHeight()
	
	if not att.xscale and not att.yscale and (att.scale==nil or type(att.scale)=='boolean') then
		self.drawwidth = att.drawwidth or self.picwidth
		self.drawheight = att.drawheight or self.picheight
		if att.scale then
			if not att.drawwidth then
				self.drawwidth = self.drawwidth*self.drawheight/self.picheight
			elseif not att.drawheight then
				self.drawheight = self.drawheight*self.drawwidth/self.picwidth
			end
		end
	elseif type(att.scale) == 'number' then
		self.drawwidth = self.picwidth*att.scale
		self.drawheight = self.picheight*att.scale
	else
		self.drawwidth = att.xscale and self.picwidth*att.xscale or att.drawwidth or self.picwidth
		self.drawheight = att.yscale and self.picheight*att.yscale or att.drawheight or self.picheight
	end
	
	self.relPivotPoint = att.relPivotPoint or {0,0}
	self.relPivotPoint[1] = self.relPivotPoint[1]*self.drawwidth/self.picwidth
	self.relPivotPoint[2] = self.relPivotPoint[2]*self.drawheight/self.picheight
	
	self.pivotPointPicTheta = math.atan(self.relPivotPoint[2]/self.relPivotPoint[1])
	self.pivotPointPicR = math.sqrt(self.relPivotPoint[2]^2+self.relPivotPoint[1]^2)
	
	self.bonePicAngle = att.bonePicAngle or 0
	
	self.bone = att.bone or bone.make{}
	
	
	self.x, self.y = self.bone.startPoint[1], self.bone.startPoint[2]
	self.angle = self.bone.absAngle --att.angle or 0
	
	self.color = att.color or {255,255,255}
	
	return self
end

function bonePicture:update(dt)
	--self.bone:update(dt)
	self.x,self.y = self.bone.startPoint[1],self.bone.startPoint[2]
	self.angle = self.bone.absAngle
end

function bonePicture:draw(drawBone,drawStructure,width,height,scale)
	
	if drawBone then
		self.bone:draw(true)
	end
	
	scale = scale or 1
	width = width or self.drawwidth*scale
	height = height or self.drawheight*scale
	
	
	local angle = self.angle + self.bonePicAngle

	local drawy = self.y - math.sin(angle + self.pivotPointPicTheta)*self.pivotPointPicR*scale
	local drawx = self.x - math.cos(angle + self.pivotPointPicTheta)*self.pivotPointPicR*scale
	
	if self.drawwidth < 0 then
		 --[[move picture in direction of angle of picture
		local moveAngle = angle
		local moveDistance = -self.drawwidth
		drawy = drawy + moveDistance*math.sin(moveAngle)
		drawx = drawx + moveDistance*math.cos(moveAngle)
--]]
		--the picture is now in the position where the top left corner is where the top right corner was
		--But what I want is for the pivot points to be lined up.

		--move picture in direction of angle of picture to line up pivot points
		local moveAngle = self.angle + self.bonePicAngle
		local moveDistance = self.relPivotPoint[1]*2
		drawy = drawy + moveDistance*math.sin(moveAngle)
		drawx = drawx + moveDistance*math.cos(moveAngle)
	end
	if not drawBone and not drawStructure then
		love.graphics.setColor(self.color)
	else
		love.graphics.setColor(self.color[1],self.color[2],self.color[3],120)
	end
	love.graphics.draw(self.pic,drawx,drawy, angle,width/self.picwidth, height/self.picheight)

	local moveAngle = self.angle + self.bonePicAngle
	local moveDistance = self.relPivotPoint[1]*2
	drawy = drawy - moveDistance*math.sin(moveAngle) +moveDistance*math.sin(self.angle-self.bonePicAngle)
	drawx = drawx - moveDistance*math.cos(moveAngle)+ moveDistance*math.cos(self.angle-self.bonePicAngle)

	love.graphics.setColor(255,255,255,160)
	--love.graphics.draw(self.pic,drawx,drawy, angle,width/self.picwidth, height/self.picheight)

end


body = {}
body.__index = body

function body.make(att)
	local self = {}
	setmetatable(self,body)
	
	self.x,self.y = att.x or 0,att.y or 0
	self.fixedPoint = {self.x,self.y}
	self.angle = att.angle or 0
	self.aspeed = att.aspeed or 0
	
	self.loneBones = att.loneBones
	self.bonePics = att.bonePics
	
	self.structuralBones = {}
	
	for i,v in pairs(att.bonePics) do
		if not v.bone.parent then
			table.insert(self.structuralBones,bone.make{id=v.bone.id .. ' struct',children={v.bone},startPoint={self.x,self.y}})
			self.structuralBones[#self.structuralBones].bodyRelAngle = self.structuralBones[#self.structuralBones].absAngle-self.angle
		end
		v.body = self
		v.bone.bodyRelAngle = v.bone.absAngle-self.angle
		--self.bonePicsRelPos[i] = {r=math.sqrt((v.bone.startPoint[2]-self.y)^2+(v.bone.startPoint[1]-self.x)^2), a=math.atan2(v.bone.startPoint[2]-self.y,v.bone.startPoint[1]-self.x)+self.angle}
		--v.bone.relStartingPoint = {v.bone.startPoint[2]-self.y,v.bone.startPoint[1]-self.x}
	end
	
	self.loneBonesRelPos = {}
	for i,v in pairs(att.loneBones) do
		if not v.parent then
			table.insert(self.structuralBones,bone.make{id=v.id .. ' struct',children={v}, startPoint={self.x,self.y}})
			self.structuralBones[#self.structuralBones].bodyRelAngle = self.structuralBones[#self.structuralBones].absAngle-self.angle
		end
		v.body = self
		v.bodyRelAngle = v.absAngle-self.angle
		--self.loneBonesRelPos[i] = {r=math.sqrt((v.startPoint[2]-self.y)^2+(v.startPoint[1]-self.x)^2), a=math.atan2(v.startPoint[2]-self.y,v.startPoint[1]-self.x)+self.angle}
		--v.relStartingPoint = {v.startPoint[2]-self.y,v.startPoint[1]-self.x}
	end
	
	self.xscale,self.yscale = 1,1
	self.xspeed,self.yspeed = 0,0
	self.airdamping = att.airdamping or 0
	self.aspeed = 0
	self.adamp = att.adamp or 0.5
	return self
end

function body:update(dt)

	self.xspeed = self.xspeed*(1-self.airdamping*dt)
	self.yspeed = self.yspeed*(1-self.airdamping*dt)
	
	self.x = self.x + (self.xspeed)*dt
	self.y = self.y + (self.yspeed)*dt
	
	self.aspeed = self.aspeed*(1 - self.adamp*dt)
	self.angle = self.angle + self.aspeed*dt
	
	for i,b in ipairs(self.structuralBones) do
		b.absAngle = b.absAngle + self.aspeed*dt
		b.startPoint = {self.x,self.y}
		b:update(dt)
		b.bodyRelAngle = b.absAngle-self.angle
	end
	
	for i,b in ipairs(self.bonePics) do
		--b.bone.startPoint[1] = self.x + self.bonePicsRelPos[i].r*math.cos(self.angle+self.bonePicsRelPos[i].a)
		--b.bone.startPoint[2] = self.y + self.bonePicsRelPos[i].r*math.sin(self.angle+self.bonePicsRelPos[i].a)
		b:update(dt)
		--b.bone.bodyRelAngle = b.bone.absAngle-self.angle -- I don't think this line should be commented out, but it doesn't work correctly if it isn't
	end
	for i,b in ipairs(self.loneBones) do
		--b.startPoint[1] = self.x + self.loneBonesRelPos[i].r*math.cos(self.angle+self.loneBonesRelPos[i].a)
		--b.startPoint[2] = self.y + self.loneBonesRelPos[i].r*math.sin(self.angle+self.loneBonesRelPos[i].a)

		--b:update(dt)
		b.bodyRelAngle = b.absAngle-self.angle
	end
end

function body:draw(drawBone,drawStructure,scale)
	
	if drawStructure then
		for i,b in ipairs(self.structuralBones) do
			b:draw()
		end
	end
	
	if drawBone then
		for i,b in ipairs(self.loneBones) do
			b:draw(drawBone)
		end
	end
	
	for i,b in ipairs(self.bonePics) do
		b:draw(drawBone,drawStructure)
	end
end
function bone:scaleChildren(xscale,yscale,cx,cy)
	local cx,cy = cx or self.startPoint[1], cy or self.startPoint[2]
	for i,b in pairs(self.children) do
		b:setStartPoint(xscale*(b.startPoint[1]-cx)+cx,yscale*(b.startPoint[2]-cy)+cy)
		b:setEndPoint(xscale*(b.endPoint[1]-cx)+cx,yscale*(b.endPoint[2]-cy)+cy)
		b:scaleChildren(xscale,yscale)
	end
end
function body:setScale(xscale,yscale)
	local xscale, yscale = xscale/self.xscale, yscale/self.yscale
	for i,b in ipairs(self.structuralBones) do
		b:setStartPoint(xscale*(b.startPoint[1]-self.x)+self.x,yscale*(b.startPoint[2]-self.y)+self.y)
		b:setEndPoint(xscale*(b.endPoint[1]-self.x)+self.x,yscale*(b.endPoint[2]-self.y)+self.y)
		b:scaleChildren(xscale,yscale,self.x,self.y)
	end
	--[[
	for i,b in ipairs(self.loneBones) do
		b:setStartPoint(xscale*(b.startPoint[1]-self.x)/self.xscale+self.x,yscale*(b.startPoint[2]-self.y)/self.yscale+self.y)
		b:setEndPoint(xscale*(b.endPoint[1]-self.x)/self.xscale+self.x,yscale*(b.endPoint[2]-self.y)/self.yscale+self.y)
	end
	--]]
	
	for i,b in ipairs(self.bonePics) do
		--b.bone:setStartPoint(xscale*(b.bone.startPoint[1]-self.x)/self.xscale+self.x,yscale*(b.bone.startPoint[2]-self.y)/self.yscale+self.y)
		--b.bone:setEndPoint(xscale*(b.bone.endPoint[1]-self.x)/self.xscale+self.x,yscale*(b.bone.endPoint[2]-self.y)/self.yscale+self.y)
		b.drawwidth = b.drawwidth*xscale
		b.drawheight = b.drawheight*yscale
		
		b.relPivotPoint[1] = b.relPivotPoint[1]*xscale
		b.relPivotPoint[2] = b.relPivotPoint[2]*yscale
		
		b.pivotPointPicTheta = math.atan(b.relPivotPoint[2]/b.relPivotPoint[1])
		b.pivotPointPicR = math.sqrt(b.relPivotPoint[2]^2+b.relPivotPoint[1]^2)
	end
	
	self.xscale,self.yscale = xscale*self.xscale,yscale*self.yscale
	self:update(0)
end

function body:scale(xscale,yscale)

	for i,b in ipairs(self.structuralBones) do
		b:setStartPoint(xscale*(b.startPoint[1]-self.x)+self.x,yscale*(b.startPoint[2]-self.y)+self.y)
		b:setEndPoint(xscale*(b.endPoint[1]-self.x)+self.x,yscale*(b.endPoint[2]-self.y)+self.y)
		b:scaleChildren(xscale,yscale,self.x,self.y)
	end
	
	for i,b in ipairs(self.bonePics) do
		--b.bone:setStartPoint(xscale*(b.bone.startPoint[1]-self.x)/self.xscale+self.x,yscale*(b.bone.startPoint[2]-self.y)/self.yscale+self.y)
		--b.bone:setEndPoint(xscale*(b.bone.endPoint[1]-self.x)/self.xscale+self.x,yscale*(b.bone.endPoint[2]-self.y)/self.yscale+self.y)
		b.drawwidth = b.drawwidth*xscale
		b.drawheight = b.drawheight*yscale
		
		b.relPivotPoint[1] = b.relPivotPoint[1]*xscale
		b.relPivotPoint[2] = b.relPivotPoint[2]*yscale
		
		b.pivotPointPicTheta = math.atan(b.relPivotPoint[2]/b.relPivotPoint[1])
		b.pivotPointPicR = math.sqrt(b.relPivotPoint[2]^2+b.relPivotPoint[1]^2)
	end
	
	self.xscale,self.yscale = xscale*self.xscale,yscale*self.yscale
	self:update(0)
end

function body:flipXY() --this probably just rotates it 180 degrees, not flipping it
	for i,b in ipairs(self.structuralBones) do
		b:setStartPoint(self.x-(b.startPoint[1]-self.x),self.y-(b.startPoint[2]-self.y))
		b:setEndPoint(self.x-(b.endPoint[1]-self.x),self.y-(b.endPoint[2]-self.y))
		b.upperConstraint,b.lowerConstraint = b.lowerConstraint and -b.lowerConstraint, b.upperConstraint and -b.upperConstraint
		b:setRelAngle(-b.relAngle)
		--b:setBodyRelAngle(-b.bodyRelAngle)
		b:flipXYChildren(self.x,self.y)
	end
	
	for i,bp in ipairs(self.bonePics) do
		--bp.bone:setStartPoint(xscale*(b.bone.startPoint[1]-self.x)/self.xscale+self.x,yscale*(b.bone.startPoint[2]-self.y)/self.yscale+self.y)
		--bp.bone:setEndPoint(xscale*(b.bone.endPoint[1]-self.x)/self.xscale+self.x,yscale*(b.bone.endPoint[2]-self.y)/self.yscale+self.y)
		bp.drawwidth = bp.drawwidth
		bp.drawheight = bp.drawheight
		local b = bp.bone
		b:setStartPoint(self.x-(b.startPoint[1]-self.x),self.y-(b.startPoint[2]-self.y))
		b:setEndPoint(self.x-(b.endPoint[1]-self.x),self.y-(b.endPoint[2]-self.y))
		b.upperConstraint,b.lowerConstraint = b.lowerConstraint and -b.lowerConstraint, b.upperConstraint and -b.upperConstraint
		b:setRelAngle(-b.relAngle)
		
		--b.relPivotPoint[1] = self.x-(b.relPivotPoint[1]-self.x)
		--b.relPivotPoint[2] = self.y-(b.relPivotPoint[2]-self.y)
		
		--b.pivotPointPicTheta = math.atan(b.relPivotPoint[2]/b.relPivotPoint[1])
		--b.pivotPointPicR = math.sqrt(b.relPivotPoint[2]^2+b.relPivotPoint[1]^2)
	end
end

function body:flipY() --A little buggy, but I didn't mean to write it anyway (I was trying to write flipX)
	for i,b in ipairs(self.structuralBones) do
		if not b.parent then
			b:setStartPoint(self.x-(b.startPoint[1]-self.x),b.startPoint[2])
			b:setEndPoint(self.x-(b.endPoint[1]-self.x),b.endPoint[2])
			b.upperConstraint,b.lowerConstraint = b.lowerConstraint and 2*math.pi-b.lowerConstraint, b.upperConstraint and 2*math.pi-b.upperConstraint
			--b:setRelAngle(2*math.pi-b.relAngle)
			b:setBodyRelAngle(2*math.pi-b.bodyRelAngle)
			--b:flipXChildren(self.x)
		else
			b.upperConstraint,b.lowerConstraint = b.lowerConstraint and 2*math.pi-b.lowerConstraint, b.upperConstraint and 2*math.pi-b.upperConstraint
			b:setRelAngle(2*math.pi-b.relAngle)
			--b:setBodyRelAngle(2*math.pi-b.bodyRelAngle)
		end
	end
	
	for i,bp in ipairs(self.bonePics) do
		--bp.bone:setStartPoint(xscale*(b.bone.startPoint[1]-self.x)/self.xscale+self.x,yscale*(b.bone.startPoint[2]-self.y)/self.yscale+self.y)
		--bp.bone:setEndPoint(xscale*(b.bone.endPoint[1]-self.x)/self.xscale+self.x,yscale*(b.bone.endPoint[2]-self.y)/self.yscale+self.y)
		bp.drawwidth = bp.drawwidth
		bp.drawheight = bp.drawheight
		local b = bp.bone
		if not b.parent then
			b:setStartPoint(self.x-(b.startPoint[1]-self.x),b.startPoint[2])
			b:setEndPoint(self.x-(b.endPoint[1]-self.x),b.endPoint[2])
			b.upperConstraint,b.lowerConstraint = b.lowerConstraint and 2*math.pi-b.lowerConstraint, b.upperConstraint and 2*math.pi-b.upperConstraint
			
			b:setRelAngle(2*math.pi-b.relAngle)
			--b:setBodyRelAngle(2*math.pi-b.bodyRelAngle)
		else
			b.upperConstraint,b.lowerConstraint = b.lowerConstraint and 2*math.pi-b.lowerConstraint, b.upperConstraint and 2*math.pi-b.upperConstraint
			
			b:setRelAngle(2*math.pi-b.relAngle)
			--b:setBodyRelAngle(2*math.pi-b.bodyRelAngle)
		end
	end
end

function body:flipX()
	--self:flipXY()
	--self:flipY()


	--[
	for i,bp in ipairs(self.bonePics) do
		--bp.bone:setStartPoint(xscale*(b.bone.startPoint[1]-self.x)/self.xscale+self.x,yscale*(b.bone.startPoint[2]-self.y)/self.yscale+self.y)
		--bp.bone:setEndPoint(xscale*(b.bone.endPoint[1]-self.x)/self.xscale+self.x,yscale*(b.bone.endPoint[2]-self.y)/self.yscale+self.y)
		bp.drawwidth = -bp.drawwidth

		--Actually, I can't just rely on negating the width, because some images may be drawn 
		--with the right side down. I need to take into account the orientation of the image
		--related to how it's being drawn.
		--The orientation is stored in bonePicAngle. I may just need to change the move distance
		--moved in bonePic:draw for negative drawwidth?

		--[[I think this is taken care of by just moving picture in bonePic:draw
		--bp.relPivotPoint[1] = -bp.relPivotPoint[2]
		
		--bp.pivotPointPicTheta = math.atan(bp.relPivotPoint[2]/bp.relPivotPoint[1])
		--bp.pivotPointPicR = math.sqrt(bp.relPivotPoint[2]^2+bp.relPivotPoint[1]^2)
		--]]

		--bp.drawheight = bp.drawheight
		local b = bp.bone

		if not b.parent then
			--b:setStartPoint(self.x-(b.startPoint[1]-self.x),b.startPoint[2])
			--b:setEndPoint(self.x-(b.endPoint[1]-self.x),b.endPoint[2])
			b.upperConstraint,b.lowerConstraint = b.lowerConstraint and 2*math.pi-b.lowerConstraint, b.upperConstraint and 2*math.pi-b.upperConstraint
			
			b:setRelAngle(2*math.pi-b.relAngle)
			--b:setBodyRelAngle(2*math.pi-b.bodyRelAngle)
		else
			b.upperConstraint,b.lowerConstraint = b.lowerConstraint and 2*math.pi-b.lowerConstraint, b.upperConstraint and 2*math.pi-b.upperConstraint
			
			b:setRelAngle(2*math.pi-b.relAngle)
			--b:setBodyRelAngle(2*math.pi-b.bodyRelAngle)
		end
	end
	--]]
end