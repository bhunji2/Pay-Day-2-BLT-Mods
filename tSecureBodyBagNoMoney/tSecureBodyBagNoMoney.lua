--[[
-- 1.0 	2017.06.21
	Initial Release.
-- 1.1 	2017.06.24
	Make a stack of bags just like usual.
--]]

if not LuaNetworking:IsHost() then return end

local BagOn			= false
local LogCount		= false
local SecureZone 	= {   }
local CarryID 	  	= {	"person" 			 , "special_person" 		}
local Trigger		= {	"state_add_loot_bag" , "state_zipline_enable" 	}

function GetLootBagSecuredEnt() BagOn = true
	local count 	= 0 
	local total 	= 0
	local elements 	= managers.mission:script("default"):element_group("ElementUnitSequence")
	
	for i,  e in pairs( elements 					or {} ) do total = total + 1
	for i2, t in pairs( e:value("trigger_list") 	or {} ) do
		if  t["name"] == "run_sequence" 
		and table.contains(Trigger,t["notify_unit_sequence"]) 
		then count = count + 1
			 SecureZone[e:id()] = { nuSeq = t["notify_unit_sequence"] }
		end
	end
	end
	if LogCount then log("/GetLootBagSecuredEnt = " .. tostring(count) .. " / " .. tostring(total)) end
end

-- lib/managers/mission/elementareatrigger
tSBB_EAT_PI = tSBB_EAT_PI or ElementAreaTrigger.project_instigators
function ElementAreaTrigger:project_instigators() tSBB_EAT_PI(self)
	local instigators 	= tSBB_EAT_PI(self)
	local instigator	= self._values.instigator

	if 	instigator ~= "loot"
	and	instigator ~= "unique_loot" then return instigators end
	
	if not BagOn then GetLootBagSecuredEnt() end
	
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
	if not alive(instigator)
	or not self._values
	or not self:enabled() then return end
	
	local	carry_ext = instigator:carry_data() if not	carry_ext	then return end
	local 	carry_id  = carry_ext :carry_id() 	if not	carry_id	then return end
	
	if 	table.contains(CarryID,carry_id)
	then 	SubmitSecuredBag(instigator,self)
	else	tSBB_EC_O(self  ,instigator) end
	--ElementCarry.super.on_executed(self, instigator)
end

--log("//current_level_id " 	.. tostring(managers.job:current_level_id	()))
--log("//current_real_job_id " 	.. tostring(managers.job:current_real_job_id()))

local MapSpecificMode 	= 
{---["Levels Identity"] = { State = "Mode & Type" , Seq = "notify_unit_sequence" }
	["framing_frame_3"] = { State = "ForceEnable" , Seq = "state_zipline_enable" }
}

function SubmitSecuredBag(instigator,ElementCarry) 
	local SuccessSecured = false
	
	for k, v in pairs(SecureZone) do v.ElementCarry = ElementCarry
		local element = managers.mission:get_element_by_id(tonumber(k))
		if	  SubmitRules(element , v) 	-- Custom Rules to Decide
		then  element:on_executed() 	-- Make a stack of bags
			  SuccessSecured = true
		end
	end
	
	if not SuccessSecured then return end
	-- Remove Insteraction from secured bag
	if  instigator:damage():has_sequence		("secured") then
		instigator:damage():run_sequence_simple	("secured") end
	-- Remove Bag Directly
	instigator:set_slot(0)
end

function SubmitRules(Ent,v) --if true then return true end
	local 	Enabled	 = 	Ent:enabled()
	local 	Operation=  v.ElementCarry:value("operation")
	local  	LevelID  =  managers.job:current_level_id()
	local  	MapMode  =  MapSpecificMode[LevelID]
	
	if not 	Enabled
	or not 	HasSeq(Ent,v.nuSeq)
	or not	string.find(Operation, "secure")
	then	return false end
	--[[
	if 		MapMode[State] == "ForceEnable" then
		--Ent:set_enabled(true)
		--return true
	end
	--]]
	
	return true
end

function HasSeq(ent,SeqName)
	for i,   t in pairs( ent:value("trigger_list") or {} ) do
		if   t["name"] 					== "run_sequence" 
		and  t["notify_unit_sequence"] 	== SeqName
		then return true end
	end
	return false
end

-------------------------------------------------------------------------------------------------

--[[
function TableContainsBoth(table1,table2)
	for i, v in pairs(table1) do if table.contains(table2,v) 
		return true end end
		return false
end
--]]

--[[
function GetSeqList(ent,SeqName)
	local list = {}
	if type(ent) == "number" then ent = managers.mission:get_element_by_id(ent) end
	
	for i,  t in pairs( ent or {} ) do
		if  t["name"] 					== "run_sequence" 
		and t["notify_unit_sequence"] 	~= nil
		then table.insert(list,)
		end
	end
end
--]]

-------------------------------------------------------------------------------------------------

--carry_ext:set_value(0)
--SaveTable(managers.sequence:get_global_core_unit_element()._sequence_elements,"get_global_core_unit_element.lua")
--SaveTable(managers.sequence:get_event_element_class_map(),"get_event_element_class_map.lua")

--[[
if ( isHost() ) then
element:on_executed(managers.player:player_unit())
else
managers.network:session():send_to_host("to_server_mission_element_trigger", element:id(), managers.player:player_unit())
end
--]]


