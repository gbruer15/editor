tableUtilities = {}

----------------------------------------------------------------
function tableUtilities.nextk(t,k)
	local n,l = next(t,k)
	while n ~= nil and type(n) == 'number' do 
		n,l = next(t,n)
	end
	
	return n,l
end

function tableUtilities.kpairs(t)
	return tableUtilities.nextk,t,nil
end

function table.length(t)
	local n = 0
	for i,v in pairs(t) do n = n+1 end
	return n
end
----------------------------------------------------------------



function tableUtilities.tabletostring(list, skiplines, excludelist,notfirst)
	local str="{"
	if skiplines then
		skiplines = "\n"
	else
		skiplines = ""
	end
	
	excludelist = excludelist or {}
	local first = true
	for i,v in pairs(list) do
		local skip = false
		
		for b,x in pairs(excludelist) do
			if x == i then
				skip = true
				break
			end
		end
		if not skip then
			if type(v) ~= 'function' and type(v) ~= 'userdata' and type(v) ~= 'thread' then
				if first then
					if type(i) == "string" then
						str = str .. "['" .. i .. "'] = "
					elseif type(i) == 'number' then
						str = str .. "[" .. i .. "] = "
					end
					if type(v) == "string" then
						str = str ..  "'" .. tostring(v) .. "'"
					elseif type(v) == "number" or type(v) == 'boolean' or type(v) == 'nil' then
						str = str ..  tostring(v)
					elseif type(v) == "table" then
						str = str ..  tableUtilities.tabletostring(v,false,{},true)
					elseif type(v) == 'function' then
						str = str .. "'function'"
					end
					first = false
				else 
					if type(i) == "string" then
						if type(v) == "table" then
							str = str .. "," .. skiplines .. "['" .. i .. "'] = " ..  tableUtilities.tabletostring(v,false,{},true)
						elseif type(v) == "number" or type(v) == 'boolean' or type(v) == 'nil' then
							str = str .. "," .. skiplines .. "['" .. i .. "'] = " .. tostring(v)
						elseif type(v) == "string" then
							str = str .. "," .. skiplines .. "['" .. i .. "'] = " .. "'" .. tostring(v) .. "'"
						end
					elseif type(i) == "number" then
						if type(v) == "table" then
							str = str .. "," .. skiplines .. "[" .. i .. "] = " .. tableUtilities.tabletostring(v,false,{},true)
						elseif type(v) == "number" or type(v) == 'boolean' or type(v) == 'nil' then
							str = str .. ", " .. skiplines .. "[" .. i .. "] = " .. tostring(v)
						elseif type(v) == "string" then
							str = str .. ", " .. skiplines .. "[" .. i .. "] = " .. "'" .. tostring(v) .. "'"
						end
					end
				end
			end
		end -- if not skip
	end
	
	str = str .. "}"
	return str
end

function tableUtilities.stringtotable(str, start, stop)
	local list = {}
	local start = start or 1
	local stop = stop or string.len(str)
	local key = false
	
	local index = string.find(str, "{", start)
	local done = false
	index = index + 1 
	while not done and index < stop do		
	
		while string.sub(str,index,index) == " " or string.sub(str,index,index) == "\n" and index < stop do
			index = index + 1
		end
		
		
		
		local first = index
		if string.sub(str,first,first) == "'" or string.sub(str, first, first) == '"' then
			index = index + 1
			local waitfor = string.sub(str,first,first)
			while string.sub(str,index,index) ~= waitfor and index < stop do
				index = index + 1
			end
			
			first = first + 1
			
			
			if key then
				list[key] = string.sub(str, first, index-1)
				key = false
				
			else
				table.insert(list,string.sub(str, first, index-1))
			end
		elseif tonumber(string.sub(str, first, first)) ~= nil or string.sub(str, first, first) == "-" then
			index = index + 1
			while tonumber(string.sub(str,first,index)) ~= nil and index < stop do
				index = index + 1
			end
			
			
			
			
			index = index - 1
			
			
			if key then
				list[key] = tonumber(string.sub(str, first, index))
				key = false
			else
				table.insert(list,tonumber(string.sub(str, first, index)))	
			end
		elseif string.sub(str, first, first) == "{" then
			local tablestarts = 1
			local tablestops = 0
			index = first + 1
			while tablestarts ~= tablestops and index < stop do
				if string.sub(str, index, index) =="{" then
					tablestarts = tablestarts + 1
				elseif string.sub(str, index, index) == "}" then
					tablestops = tablestops + 1
				end
				index = index + 1
			end
			index = index -1
			if key then
				list[key] = stringtotable(str, first, index)
				key = false			
			else
				table.insert(list, stringtotable(str, first, index))
			end
			
		elseif tonumber(string.sub(str, first, first)) == nil then
			if string.sub(str, first, first) == "[" then
				
				while string.sub(str,index,index) ~= "'" and string.sub(str,index,index) ~= '"' and tonumber(string.sub(str,index,index)) == nil  and string.sub(str,index,index) ~= '-' and index < stop do
					index = index + 1
				end
				local waitfor = string.sub(str,index,index)
				
			
				index = index + 1
				first = index
				if tonumber(waitfor) or waitfor == '-' then
					while tonumber(string.sub(str,index,index)) ~= nil and index < stop do
						index = index + 1
					end
				else
					while string.sub(str,index,index) ~= waitfor and index < stop do
						index = index + 1
					end
				end
				
				
				if tonumber(waitfor) or waitfor == '-' then
					key = tonumber(string.sub(str,first-1,index-1))
				else
					key = string.sub(str, first, index-1)
				end
				
				while string.sub(str,index,index) ~= "=" and index < stop do
					index = index + 1
				end
				
			elseif string.sub(str,index,index+4) == 'false' then
				index = index + 4
				if key then
					list[key] = false
					key = false
				else
					table.insert(list,false)
				end
			elseif string.sub(str,index,index+3) == 'true' then
				index = index + 4
				if key then
					list[key] = true
					key = false
				else
					table.insert(list,true)
				end
			else
				while string.sub(str,index,index) ~= " " and string.sub(str, index,index) ~= "=" and index < stop do
					index = index + 1
				end
				index = index - 1
				key = string.sub(str, first, index)
				
				while string.sub(str,index,index) ~= "=" and index < stop do
					index = index + 1
				end
			end
			
		end
		
		index = index + 1

		while string.sub(str,index,index) == " " or string.sub(str, index,index) == "," or string.sub(str, index, index) == "}" or string.sub(str, index,index) == "\n" and index < stop do
			index = index + 1
			
		end
		
		
		
		if index >= stop then
			done = true
		end	
	end
	return list
end




function tableUtilities.load(filename)	
	if not love.filesystem.isFile( filename ) then error("File Does Not Exist") end
	
	local contents, size = love.filesystem.read(filename, all )
	return contents
end




function tableUtilities.save(tab, filename,startstring)

	--local file = love.filesystem.newFile(filename)
	if type(startstring) == 'string' then
		love.filesystem.write( filename, startstring .. tableUtilities.tabletostring(tab, true) , all)
	else
		love.filesystem.write( filename, tableUtilities.tabletostring(tab, true) , all)
	end

end




