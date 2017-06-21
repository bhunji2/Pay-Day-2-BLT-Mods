
if not LuaNetworking:IsHost() then return end
local CarryID = { "person" , "special_person" }

-- lib/managers/mission/elementareatrigger
tSBB_EAT_PI = tSBB_EAT_PI or ElementAreaTrigger.project_instigators
function ElementAreaTrigger:project_instigators() tSBB_EAT_PI(self)
	local instigators 	= tSBB_EAT_PI(self)
	local instigator	= self._values.instigator
	
	if 	instigator ~= "loot" 		and
		instigator ~= "unique_loot" then return instigators end
	
	for _, unit in ipairs( World:find_units_quick("all", 14) ) do
		local 	cData  =  unit:carry_data()
		if 		cData and filter_func(cData,instigator) then table.insert(instigators, unit) end
	end
	
	return instigators
end

function filter_func(cData,cType)
	if  cType == "loot" 		and table.contains(CarryID,cData:carry_id())
	or	cType == "unique_loot" 	and tweak_data.carry	  [cData:carry_id()].is_unique_loot then 
	return true end
	return false
end

-- lib/managers/mission/elementcarry
tSBB_EC_O = tSBB_EC_O or ElementCarry.on_executed
function ElementCarry:on_executed(instigator)
	local	carry_ext = instigator:carry_data() if not	carry_ext	then return end
	local 	carry_id  = carry_ext :carry_id() 	if not	carry_id	then return end
	
	if table.contains(CarryID,carry_id)
	then 	instigator:set_slot(0)
	else	tSBB_EC_O(self,instigator)  end
end