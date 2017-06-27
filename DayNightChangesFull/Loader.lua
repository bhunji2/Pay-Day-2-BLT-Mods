
-- revamp by Tast 

veritas = veritas or 
{
	 mod_path 	= ModPath
	,save_path 	= SavePath .. "veritas.txt"
	,main_menu 	= "veritas_menu"
	,levels		= {}
	,levels_data= {}
	,options 	= {}
	,Localize	= {}
}

function veritas:Save()
	local  	file = io.open( self.save_path, "w+" )
	if not 	file then return end
	file:write( json.encode( self.options ) )
	file:close()
end

function veritas:Load()
	local 	file = io.open( self.save_path, "r" )
	if not 	file then return end
	self.options = json.decode( file:read("*all") )
	file:close()
end
veritas:Load()

function veritas:GetLevelsData(level_id, value)
	if 		veritas.levels_data[ level_id ]  ~= nil
	then 	return veritas.levels_data[ level_id ][value] end
	return nil
end

function GetTableValue(table,value)
	if table ~= nil then return table[value] end
	return nil
end

--------------------------------------------------------------------------------------------------------------

local time_settings = {
	"",
	"",
	"environments/pd2_env_hox_02/pd2_env_hox_02",
	"environments/pd2_env_morning_02/pd2_env_morning_02",
	"environments/pd2_env_arm_hcm_02/pd2_env_arm_hcm_02",
	"environments/pd2_env_n2/pd2_env_n2"
}

	 DNF_NarrativeTweakData_init =		DNF_NarrativeTweakData_init or NarrativeTweakData.init
function NarrativeTweakData:init(...) 	DNF_NarrativeTweakData_init(self,...)
	for i , job_id in pairs( self._jobs_index ) do 				--log("//" .. job_id)
		for i , v in pairs( self.jobs[job_id].chain or {} ) do 	--log("/" .. v.level_id or "") 
			if v.level_id then self:ParseJobLevelData({ v = v, i = i, job_id = job_id })
			else 
				for i2 , v2 in pairs( v or {} ) do
					if type(v2) == "table" and v2.level_id then 
						self:ParseJobLevelData({ v = v2, i = i2 + i - 1, job_id = job_id }) 
					end
				end
			end
		end
	end
end

function NarrativeTweakData:ParseJobLevelData(data)
	local v = data.v
	veritas.levels_data[ v.level_id ] 				= veritas.levels_data[ v.level_id ] or {}
	veritas.levels_data[ v.level_id ].level_id 	 	= v.level_id
	veritas.levels_data[ v.level_id ].job_id	 	= data.job_id
	veritas.levels_data[ v.level_id ].job_name_id	= self.jobs[ data.job_id ].name_id
	veritas.levels_data[ v.level_id ].stage		 	= data.i
	veritas.levels_data[ v.level_id ].contact		= GetTableValue(self.jobs[ data.job_id ], "contact")
end

	 DNF_LevelsTweakData_init =		DNF_LevelsTweakData_init or LevelsTweakData.init
function LevelsTweakData:init(...)	DNF_LevelsTweakData_init(self,...)
	for i , level_id in pairs( self._level_index ) do
		if 		self[ level_id ] 
		and 	self[ level_id ].name_id 
		and not self[ level_id ].env_params 
		then	veritas.levels[ level_id ] = self[ level_id ].name_id end
		
		if 		veritas.options[ level_id ] ~= nil
		and 	veritas.options[ level_id ] ~= 1 then
			if 	veritas.options[ level_id ] == 2 then
					self[ level_id ].env_params = { environment = time_settings[ math.random( 3 , 6 ) ] }
			else	self[ level_id ].env_params = { environment = time_settings[ veritas.options[ level_id ] ] } end
			log( "Custom Time Loaded: " .. level_id )
		end
	end
end
-- managers.menu:open_node("cWIP_options")
Hooks:Add("MenuManagerInitialize", "", function(menu_manager)
	MenuCallbackHandler.DNF_Close_Options 	= function(this)  		end
	MenuCallbackHandler.DNF_Config_Reset 	= function(this, item) 	end
	MenuCallbackHandler.DNF_ValueSet 		= function(this, item)
		veritas.options[ item:name():sub(11) ] = item:value()
		veritas:Save()
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "", function( menu_manager, nodes )
	MenuHelper:NewMenu( veritas.main_menu )
	
	local 	contacts  		= tweak_data.narrative.contacts
			contacts.Unknow = 0
	
	for k , v in pairs( contacts ) do 
		contacts[k] = 0
		MenuHelper:NewMenu( veritas.main_menu .. "_" .. k ) 
	end
	
	for level_id , name_id in pairs( veritas.levels ) do
		local contract	= GetTableValue(veritas.levels_data[ level_id ],"contact") or "Unknow"
		local menu_id 	= veritas.main_menu .. "_" .. contract
		
		MenuHelper:AddMultipleChoice( {
			id 			= "veritasID_" 		.. level_id,
			title 		= "veritas_" 		.. level_id,
			desc 		= "veritasDesc_" 	.. level_id,
			callback 	= "DNF_ValueSet",
			items 		= {
							"veritas_default",
							"veritas_random",
							"veritas_pd2_env_hox_02",
							"veritas_pd2_env_morning_02",
							"veritas_pd2_env_arm_hcm_02",
							"veritas_pd2_env_n2",
						  },
			menu_id 	= menu_id,
			value 		= veritas.options[ level_id ] or 1,
			localized	= true
		} )
		
		contacts[contract] = contacts[contract] + 1
	end
	
	nodes[veritas.main_menu] = 
		MenuHelper:BuildMenu	( veritas.main_menu, { area_bg = "half" } )  
		MenuHelper:AddMenuItem	( nodes.lua_mod_options_menu, veritas.main_menu, "veritas_menuTitle", "veritas_menuDesc")
	
	for k , v in pairs( contacts ) do
		if contacts[k] > 0 then
			local menu_id = veritas.main_menu .. "_" .. k
			nodes[menu_id] = 
			MenuHelper:BuildMenu	( menu_id, { area_bg = "half" } )  
			MenuHelper:AddMenuItem	( nodes[veritas.main_menu], menu_id, menu_id, "veritas_menuDesc")
		end
	end
end)

--------------------------------------------------------------------------------------------------------------

Hooks:Add( "LocalizationManagerPostInit" , "veritasLocalization" , function( self )
	SaveTable(veritas.Localize,"Localize.lua")
	self:add_localized_strings( veritas.Localize )
	self:add_localized_strings({
		 ["veritas_menuTitle"] 			= "Day/Night Changes"
		,["veritas_menuDesc"] 			= "Change the day/night cycles for certain heists!"
		
		,["veritas_default"] 			= "Default"
		,["veritas_random"] 			= "Random"
		,["veritas_pd2_env_hox_02"] 	= "Early Morning"
		,["veritas_pd2_env_morning_02"]	= "Morning"
		,["veritas_pd2_env_arm_hcm_02"]	= "Foggy Evening"
		,["veritas_pd2_env_n2"] 		= "Night"
		
		,["veritas_menu_Unknow"]		= "Unknow Contracts"
	})
	
	--tweak_data.levels[ level_id ].name_id
	
	for k , v in pairs( tweak_data.narrative.contacts ) do 
		self:add_localized_strings({
			[veritas.main_menu .. "_" .. k] = k .. " Contracts"
		})
	end
	
	for level_id , name_id in pairs( veritas.levels ) do 
		if veritas.levels_data[ level_id ] then
			local job_name_id 	= veritas.levels_data[ level_id ].job_name_id 	or ""
			local stage			= veritas.levels_data[ level_id ].stage			or 0
			local LocText		= level_id
			local LocTextFull	= self:text(job_name_id)
			
			if Localizer:exists(Idstring(job_name_id)) then LocText = Localizer:lookup(Idstring(job_name_id)) end
			LocText = LocText .. " [" .. stage .. "]"
			
			self:add_localized_strings({ 
				 ["veritas_"		.. level_id] = LocText
				,["veritasDesc_" 	.. level_id] = level_id .. " :level_id\n" .. LocTextFull
			}) 
			
			--log("/ " .. level_id .. " //* " .. tostring(job_name_id) .. " */ " .. LocText)
		else
			self:add_localized_strings({ 
				 ["veritas_"		.. level_id] = level_id .. " [?]"
				,["veritasDesc_" 	.. level_id] = level_id .. " : unknow"
			}) 
		end
	end
end )

--------------------------------------------------------------------------------------------------------------
local PackageBase = "levels/instances/unique/"
local PackageList =
{
	 "hlm_random_right003"
	,"hox_fbi_armory"
	,"hlm_vault"
	,"hlm_gate_base"
	,"hlm_reader"
	,"hlm_door_wooden_white_green"
}

for i , v in pairs( PackageList ) do
	local  path = PackageBase .. v .. "/world"
	if not PackageManager:loaded(path) then PackageManager:load(path) end
end

if not PackageManager:load( "levels/narratives/vlad/ukrainian_job/world_sounds" ) then
	PackageManager:load( "levels/narratives/vlad/ukrainian_job/world_sounds" )
	PackageManager:load( "levels/narratives/vlad/jewelry_store/world_sounds" )
end