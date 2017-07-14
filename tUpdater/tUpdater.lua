dofile("mods/tUpdater/tUtils.lua")

tlog("/ tUpdater")
tUpdater = tUpdater or 
{
	 mods 		= { }
	,path_mod	= ModPath
	,path_save	= SavePath
	,theard 	= 4
	,counter	= 0
}

--------------------------------------------------------------------------------------------------------------------
-- Load All mod.txt
function tUpdater:LoadingAll() tlog("/ tUpdater:LoadingAll")
	for i, file in ipairs( SystemFS:list("mods/",true) ) do self:LoadMod( file ) end
	self:UpdateCheck()
end

function tUpdater:LoadMod( fileName ) --tlog("/ tUpdater:LoadMod " .. fileName)
	local  file = io.open("mods/" .. fileName .. "/mod.txt", "r")
	if not file   then return end
	local  fileT= file:read("*all"):gsub("%[%]","{}") 
		   file : close()
	
	if fileT == "[]" or fileT == "" then return end
	
	local json = json.decode(fileT)
	if json["tUpdates"] ~= nil then 
		tlog("/ tUpdater:LoadMod " .. json.name)
		table.insert(self.mods,json)
		self.mods[#self.mods].dir_mod 	= fileName
		self.mods[#self.mods].index 	= #self.mods
	end
end

function tUpdater:UpdateCheck(counter)
	if counter == nil then
		for i = 1 , self.theard , 1 do self:UpdateCheck(i) end
		return
	elseif not self.mods[counter] then return end
	--for i, mod in ipairs( self.mods ) do end	
	
	
end

tUpdater:LoadingAll()

--------------------------------------------------------------------------------------------------------------------