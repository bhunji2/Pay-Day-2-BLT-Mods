
function tlog(data,filename,byDate)
	if type(data) ~= "table" and type(data) ~= "string" then data = tostring(data) end
	--if type(data) ~= "string" then data = tostring(data) end
	if byDate then 
		filename = filename and "_" .. filename or ".lua"
		filename = os.date("%Y_%m_%d" .. filename)
	end
	
	--
	local text = "\n\t"
	if type(data) == "table" then
		for k , v in pairs(data) do
			text = text .. tostring(k) .. " : " .. tostring(v) .. "\n\t"
		end
		data = text
	end
	--]]
	
	local  Path = "mods/logs/"
	local  Name = filename and Path .. filename or Path .. "logs.lua"
	local  file = io.open(Name, "a+")
	if not file then 
		log("LogERROR by Tast's Utils")
		return nil
	end
	
	local Time = os.date("%Y/%m/%d %H:%M:%S: ")
	local Text = Time .. data .. "\n"
	file:write(Text)
	file:close()
	--log(data)
	return Text
end

function tPrintTableNameList(table)
	for k , v in pairs(table) do
		log("/ " .. tostring(k) .. " /// " .. tostring(v) )
	end
end