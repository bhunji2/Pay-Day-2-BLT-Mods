
_MutatorsManagerProfileLoad 	= false
_MutatorsManagerProfileLoaded 	= false

MutatorsManager_globalize_active_mutators 	=  MutatorsManager_globalize_active_mutators 
											or MutatorsManager.globalize_active_mutators
function MutatorsManager:globalize_active_mutators()
	MutatorsManager_globalize_active_mutators(self)
	log("/MutatorsManager:globalize_active_mutators")
end


MutatorsManager_set_enabled =  MutatorsManager_set_enabled 
							or MutatorsManager.set_enabled
function MutatorsManager:set_enabled(mutator, enabled)
	MutatorsManager_set_enabled(self,mutator, enabled)
	log("/MutatorsManager:set_enabled")
	
	--SaveTable(Global.mutators.mutator_values,"Global.mutators.ini")
	if _MutatorsManagerProfileLoaded == false then MutatorsManager.ProfileSave() end
end

function MutatorsManager:ProfileSave()
	if _MutatorsManagerProfileLoaded == true then return end
	log("/MutatorsManager:ProfileSave")
	local  file = io.open(SavePath .. "tMutatorsSetSave.txt", "w+")
	if not file then return false end
	
	file:write(json.encode(Global.mutators.mutator_values))
	file:close()
end

function MutatorsManager:ProfileLoad()
	--if   self.can_enable_mutator == nil then return end
	if 	_MutatorsManagerProfileLoad == true then return end
		_MutatorsManagerProfileLoad  = true
	log("/MutatorsManager:ProfileLoad")
	local  file = io.open(SavePath .. "tMutatorsSetSave.txt", "r")
	if not file then return false end
	local  fileT= file:read("*all")
		   fileT= fileT:gsub("%[%],","{},")
	file:close()
	if string.len(fileT) < 10 then return end
	
	log("string.len " .. tostring(string.len(fileT)))
	
	if not Global.mutators then
		Global.mutators = {
			mutator_values = {},
			active_on_load = {}
		}
	end
	
	Global.mutators.mutator_values = json.decode(fileT)
	--self:init()
	--[[
	_MutatorsManagerProfileLoaded = true
	for k, v in pairs(json.decode(fileT)) do
		if v.enabled == true and Global.mutators.mutator_values[k] ~= nil then
			log(tostring(k) .. " - " .. tostring(v.enabled))
			MutatorsManager.set_enabled(k, true)
			
			_MutatorsManagerProfileLoaded = false
			return true
		end
	end
	_MutatorsManagerProfileLoaded = false
	]]
	
	
	return true
end

MutatorsManager_init 	=  MutatorsManager_init 
						or MutatorsManager.init
function MutatorsManager:init()
	self:ProfileLoad()
	MutatorsManager_init(self)
	log("/MutatorsManager:init")
end

--[[
MutatorsManager_can_enable_mutator 	=  MutatorsManager_can_enable_mutator
									or MutatorsManager.can_enable_mutator
function MutatorsManager:can_enable_mutator(mutator)
	MutatorsManager_can_enable_mutator(self,mutator)
	
	log("/MutatorsManager:can_enable_mutator")
	--MutatorsManager.ProfileLoad()
end
]]
--[[
Hooks:PostHook( MutatorsManager, "can_enable_mutator", "TestPostPlayerManagerInit", function(mutators)
    log("//MutatorsManager can_enable_mutator")

	DelayedCalls:Add( "DelayedCallsExamplesdgasd", 5, function()
		managers.mutators:ProfileLoad()
	end )
end )

]]