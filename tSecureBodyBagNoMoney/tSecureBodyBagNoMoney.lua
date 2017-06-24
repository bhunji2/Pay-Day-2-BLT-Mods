--[[
-- 1.0 2017.06.21
		Initial Release.
-- 1.1 2017.06.24
		Make a stack of bags just like usual.
-- 1.2 2017.06.
		Fix some bug
--]]

if not LuaNetworking:IsHost() then return end
-------------------------------------------------------------------------
local tMSM			= {   }
local BagOn			= false
local SecureZone 	= {   }
local CarryID 	  	= {	"person" 			 , "special_person" 		}
--local Trigger		= {	"state_add_loot_bag" , "state_zipline_enable" 	}
local Trigger		= {	"state_add_loot_bag" }
-------------------------------------------------------------------------
local debugLog		= SystemFS:exists("mods/saves/tSBB.debug")  or  false
function log2(text) if debugLog then log("/" .. tostring(text)) end end
-------------------------------------------------------------------------
Hooks:PostHook( GameStateMachine, "change_state" , "", function(state, params)
	--log2("/change_state " .. tostring(params._name))
	if not string.find(params._name, "ingame_") 
				 then return 	  end
	if not BagOn then tMSM:init() end
end )

function tMSM:init() BagOn = true
	self.LVid 	= managers.job:current_level_id()
	self.LvData	= 
{
  --["Levels Identity"] = { ["State"] = "Mode & Type" , ["Seq"] = "notify_unit_sequence" }
  --["framing_frame_3"] = { ["State"] = "ForceUsable" , ["Seq"] = "state_zipline_enable" }
  
  --["Levels Identity"] = { [elementIDs] = "Mode&Type" }
	["framing_frame_3"] = { [  104570  ] = "ForcePass" }
}
	GetLootBagSecuredEnt()
end

function tMSM:GetData()	return self.LvData[self.LVid] or {} end
function tMSM:sValue(v)	return self:GetData()[v] 	  or "" end

function GetLootBagSecuredEnt()
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
	log2("/GetLootBagSecuredEnt = " .. tostring(count) .. " / " .. tostring(total))
end
--[[
--lib/managers/mission/coremissionscriptelement.lua
tSBB_MSE_OE = tSBB_MSE_OE or MissionScriptElement.on_executed
function MissionScriptElement:on_executed2(instigator, alternative, skip_execute_on_executed)
	log2("tSBB_MSE_OE " .. tostring(self		 :id()) .. " - " .. tostring(self	   :editor_name()))
	
	if not self._values.enabled and tMSM:sValue( self:id() ) == "ForcePass" then
		log2("tSBB_MSE_OE ForceTrigger " .. tostring(self:id()) .. " - " .. tostring(self:editor_name()))
		
		if not skip_execute_on_executed or CoreClass.type_name(skip_execute_on_executed) ~= "boolean" then
			self:_trigger_execute_on_executed(instigator, alternative)
		end

		return
	end
	
	tSBB_MSE_OE(self,instigator, alternative, skip_execute_on_executed)
end
--]]
-- lib/managers/mission/elementareatrigger
tSBB_EAT_PI = tSBB_EAT_PI or ElementAreaTrigger.project_instigators
function ElementAreaTrigger:project_instigators()
	local instigators 	= tSBB_EAT_PI(self)
	local instigator	= self._values.instigator
	
	if 	instigator ~= "loot"
	and	instigator ~= "unique_loot" then return instigators end
	
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
tSBB_EC_OE = tSBB_EC_OE or ElementCarry.on_executed
function ElementCarry:on_executed(instigator) log2("/ElementCarry on_executed")
	if not alive(instigator)
	or not self:values() --then return end
	or not self:enabled()then return end
	
	local	carry_ext = instigator:carry_data() if not	carry_ext	then return end
	local 	carry_id  = carry_ext :carry_id() 	if not	carry_id	then return end
	
	if 	table.contains(CarryID,carry_id)
	then 	SubmitSecuredBag(instigator,self)
	else	tSBB_EC_OE(self  ,instigator) end
	--ElementCarry.super.on_executed(self, instigator)
end

--log2("//current_level_id " 	.. tostring(managers.job:current_level_id	()))
--log2("//current_real_job_id " .. tostring(managers.job:current_real_job_id()))

function SubmitSecuredBag(instigator,ElementCarry) log2("/SubmitSecuredBag")
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

function SubmitRules(Ent,v) log2("/SubmitRules")
	local 	Operation = v.ElementCarry:value("operation")
	
	if 	not Ent:enabled() 
	--	and	tMSM:sValue("State") ~= "ForceUsable"
	--or 	not HasSeq(Ent,v.nuSeq)
	or 	not	string.find(Operation, "secure")
	then	return false end
	
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