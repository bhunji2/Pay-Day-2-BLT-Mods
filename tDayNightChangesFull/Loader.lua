-- revamped by Tast 

veritas = veritas or 
{
	 mod_path 	= ModPath
	,save_path 	= SavePath .. "veritas.txt"
	,main_menu 	= "veritas_menu"
	,options 	= {}
	,levels		= {}
	,levels_data= {}
	,contracts	= { ["unknow"] = 0 }
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

function veritas:LevelsByVal(fValue, tValue)
	if fValue == "all" then return self.levels end
	local levels = {}
	for k , v in pairs( self.levels_data or {} ) do
		if 		self.levels_data[k][fValue] == tValue 
		then	levels[v.level_id] = self.levels[v.level_id] end
	end
	if levels == {} then return nil end
	return levels
	--log(tostring(levels == {} and nil or levels))
	--return levels == {} and nil or levels
end

function veritas:SetOptions(target, num, by)
	--if num == 1 then num = nil end
	local levels = target or {}
	if by == "contract" then levels = self:LevelsByVal("contact", target) 	end
	if by == "all"		then levels = self:LevelsByVal("all")				end
	
	for level_id, v in pairs( levels or {} ) do 
		self.options[level_id] = num
	end
	self:Save()
	
	return levels
end

--------------------------------------------------------------------------------------------------------------

function GetTableValue(table,value)
	if table ~= nil then return table[value] end
	return nil
end
--[[
function PrintTableNameList(table)
	for k , v in pairs(table) do
		log("/ " .. tostring(k) .. " /// " .. tostring(v) )
	end
end
--]]
--------------------------------------------------------------------------------------------------------------

	 DNF_NarrativeTweakData_init =		DNF_NarrativeTweakData_init or NarrativeTweakData.init
function NarrativeTweakData:init(...) 	DNF_NarrativeTweakData_init(self,...)
	for job_id , v in pairs( self.jobs ) do 
		for i , job_id2 in pairs( self.jobs[job_id].job_wrapper or {} ) do
			if self.jobs[ job_id2 ].name_id == nil then 
				self:ParseJob({ tables = self.jobs[job_id2].chain or {} , job_id = job_id })
			end
		end
	end
	
	for job_id , v in pairs( self.jobs ) do 
		self:ParseJob({ tables = self.jobs[job_id].chain or {} , job_id = job_id })
	end
end

function NarrativeTweakData:ParseJob(data)
	for i , v in pairs( data.tables or {} ) do
		if v.level_id ~= nil then --log("level_id " ..tostring(v.level_id))
			--log("/ " .. v.level_id )
			veritas.levels_data[ v.level_id ] = veritas.levels_data[ v.level_id ] or 
			{
				 level_id 		= v.level_id
				,job_id 		= data.job_id
				,job_name_id	= GetTableValue(self.jobs[ data.job_id ], "name_id")
				,stage			= i + ( ( data.i and data.i - 1 ) or 0 )
				,contact		= GetTableValue(self.jobs[ data.job_id ], "contact") or "unknow"
			}
		elseif type(v) == "table" and v.level_id == nil then 
			self:ParseJob({ tables = v or {} , job_id = data.job_id , i = i })
		end
	end
end

local time_settings = 
{ "",""
	,"environments/pd2_env_hox_02/pd2_env_hox_02"			--凌晨
	,"environments/pd2_env_morning_02/pd2_env_morning_02"	--早上
	,"environments/pd2_env_arm_hcm_02/pd2_env_arm_hcm_02"	--霧夜
	,"environments/pd2_env_n2/pd2_env_n2"					--晚上
	
	,"environments/pd2_env_mid_day/pd2_env_mid_day"			--正午
	,"environments/pd2_env_afternoon/pd2_env_afternoon"		--下午
	,"environments/pd2_env_foggy_bright/pd2_env_foggy_bright"--霧夜亮
}

local Time_Menu_Items = 
{
	 "veritas_default"
	,"veritas_random"
	,"veritas_pd2_env_hox_02"
	,"veritas_pd2_env_morning_02"
	,"veritas_pd2_env_arm_hcm_02"
	,"veritas_pd2_env_n2"
	
	,"veritas_pd2_env_mid_day"
	,"veritas_pd2_env_afternoon"
	,"veritas_pd2_env_foggy_bright"
}

	 DNF_LevelsTweakData_init =		DNF_LevelsTweakData_init or LevelsTweakData.init
function LevelsTweakData:init(...)	DNF_LevelsTweakData_init(self,...)
	local 	CustomLoaded = 0
	for i , level_id in pairs( self._level_index ) do
		-- Get levels id
		if 		self[ level_id ] 
		and 	self[ level_id ].name_id 
		--and not self[ level_id ].env_params 
		then	veritas.levels[ level_id ] = self[ level_id ].name_id end
	end
	self:VeritasSet()
end

function LevelsTweakData:VeritasSet()
	local 	CustomLoaded = 0
	for i , level_id in pairs( self._level_index ) do
		-- Override Set
		if		self[ level_id ] 
		and		veritas.options[ "override" ] ~= nil
		and 	veritas.options[ "override" ] >  1 then	
			if 	veritas.options[ "override" ] == 2 then
					self[ level_id ].env_params = { environment = time_settings[ math.random( 3 , #time_settings ) ] }
			else	self[ level_id ].env_params = { environment = time_settings[ veritas.options[ "override" ] or 1 ] } end
		--end
		-- set per map
		elseif	self[ level_id ] 
		and		veritas.options[ level_id ] ~= nil
		and 	veritas.options[ level_id ] ~= 1 then
			if 	veritas.options[ level_id ] == 2 then
					self[ level_id ].env_params = { environment = time_settings[ math.random( 3 , #time_settings ) ] }
			else	self[ level_id ].env_params = { environment = time_settings[ veritas.options[ level_id ] ] } end
					CustomLoaded = CustomLoaded + 1
			--log( "Custom Time Loaded: " .. level_id )
		end
	end
	if CustomLoaded > 0 then log( "/Custom Time Loaded: " .. tostring( CustomLoaded ) ) end
end

-------------------------------------------------------------------------------------------------------------------
--managers.menu:open_node(veritas.main_menu .. "_" .. type)
Hooks:Add("MenuManagerInitialize", "tDNCF_MMI", function(menu_manager)
	MenuCallbackHandler.DNF_Close_Options 	= function(self)
		--log("// DNF_Close_Options")
		tweak_data.levels:VeritasSet()
	end
	MenuCallbackHandler.DNF_Config_Reset 	= function(self, item) 	
		local type = item:name():sub(string.len("veritasID_Reset_") + 1)
		
		local levels = {}
		if   type == "all" 
		then levels = veritas:SetOptions({}	 , 1, "all")
		else levels = veritas:SetOptions(type, 1, "contract") end
		
		levels["override"] = ""
		
		if type == "all" then
			for k , v in pairs( veritas.contracts or {} ) do 
				local menu = MenuHelper:GetMenu( veritas.main_menu .. "_" .. k )
				ResetItems(menu, levels, 1)
			end
		end
		
		local menu_id = type == "all" and veritas.main_menu or veritas.main_menu .. "_" .. type
		local menu = MenuHelper:GetMenu( menu_id )
		
		ResetItems(menu, levels, 1)
	end
	
	function ResetItems(menu, items, value)
		for k , v in pairs( items or {} ) do 
			local item = menu:item("veritasID_" .. k)
			if   item 
			then item._current_index = value or 1
				 item:dirty()
			end--item:set_enabled(false)
		end
	end
	
	MenuCallbackHandler.DNF_ValueSet 		= function(self, item)
		veritas.options[ item:name():sub(11) ] = item:value()
		veritas:Save()
	end
end)

Hooks:Add("MenuManagerSetupCustomMenus", "tDNCF_MMSC", function( menu_manager, nodes )
	MenuHelper:NewMenu( veritas.main_menu )
	MenuHelper:NewMenu( veritas.main_menu .. "_unknow" )
	
	for k , v in pairs( tweak_data.narrative.contacts ) do 
		veritas.contracts[k] = 0
		MenuHelper.menus = MenuHelper.menus or {}

		local new_menu = deep_clone( MenuHelper.menu_to_clone )
		new_menu._items = {}
		MenuHelper.menus[veritas.main_menu .. "_" .. k] = new_menu
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "tDNCF_MMBCM", function( menu_manager, nodes )
	MenuHelper:AddButton({
		id 			= "veritasID_Reset_all",
		title 		= "veritas_Reset_all",
		desc 		= "veritasDesc_Resetall",
		callback 	= "DNF_Config_Reset",
		menu_id 	= veritas.main_menu,
		priority 	= 100,
		localized	= true
	})
	
	MenuHelper:AddMultipleChoice( {
		id 			= "veritasID_override",
		title 		= "veritas_override",
		desc 		= "veritasDesc_override",
		callback 	= "DNF_ValueSet",
		items 		= Time_Menu_Items,
		menu_id 	= veritas.main_menu,
		value 		= veritas.options[ "override" ] or 1,
		priority 	= 99,
		localized	= true
	} )
	
	MenuHelper:AddDivider({ id = "veritasID_divider_main", size = 20, menu_id = veritas.main_menu, priority = 98 })
	
	for level_id , name_id in pairs( veritas.levels ) do
		local contract	= GetTableValue(veritas.levels_data[ level_id ],"contact") or "unknow"
		local menu_id 	= veritas.main_menu .. "_" .. contract
		
		veritas.contracts[contract] = true
		
		MenuHelper:AddMultipleChoice( {
			id 			= "veritasID_" 		.. level_id,
			title 		= "veritas_" 		.. level_id,
			desc 		= "veritasDesc_" 	.. level_id,
			callback 	= "DNF_ValueSet",
			items 		= Time_Menu_Items,
			menu_id 	= menu_id,
			value 		= veritas.options[ level_id ] or 1,
			localized	= true
		} )
	end
	
	nodes[veritas.main_menu] = 
		MenuHelper:BuildMenu	( veritas.main_menu, { area_bg = "none" , back_callback = "DNF_Close_Options" } )  
		MenuHelper:AddMenuItem	( nodes.lua_mod_options_menu, veritas.main_menu, "veritas_menuTitle", "veritas_menuDesc")
	
	for k , v in pairs( veritas.contracts ) do
		if v == true then
			local menu_id = veritas.main_menu .. "_" .. k
			
			MenuHelper:AddButton({
				id 			= "veritasID_Reset_" 	.. k,
				--title 		= "veritas_Reset_" 		.. k,
				--desc 		= "veritasDesc_Reset_" 	.. k,
				title 		= "veritas_Reset_all",
				desc 		= "veritasDesc_Resetall",
				callback 	= "DNF_Config_Reset",
				menu_id 	= menu_id,
				priority 	= 100,
				localized	= true
			})
			
			MenuHelper:AddDivider({ id = "veritasID_divider_" .. k, size = 20, menu_id = menu_id,priority = 99 })
			
			nodes[menu_id] = 
			MenuHelper:BuildMenu	( menu_id, { area_bg = "half" } )  
			MenuHelper:AddMenuItem	( nodes[veritas.main_menu], menu_id, menu_id, "veritas_menuDesc")
		end
	end

	--nodes[veritas.main_menu]["_items"][1]["_parameters"].color = "Color(1 * (0.94902, 0.94902, 0.313726))"
end)

--------------------------------------------------------------------------------------------------------------

Hooks:Add( "LocalizationManagerPostInit" , "veritasLocalization" , function( self )
	self:add_localized_strings({
		 ["veritas_menuTitle"] 			= "Day/Night Changes"
		,["veritas_menuDesc"] 			= "Change the day/night cycles for certain heists!\nGame Restart Required."
		
		,["veritas_default"] 			= "Default"
		,["veritas_random"] 			= "Random"
		,["veritas_pd2_env_hox_02"] 	= "Early Morning"
		,["veritas_pd2_env_morning_02"]	= "Morning"
		,["veritas_pd2_env_arm_hcm_02"]	= "Foggy Evening"
		,["veritas_pd2_env_n2"] 		= "Night"
		
		,["veritas_pd2_env_mid_day"] 		= "Mid Day"
		,["veritas_pd2_env_afternoon"] 		= "AfterNoon"
		,["veritas_pd2_env_foggy_bright"] 	= "Foggy Bright Evening"
		
		,["veritas_menu_unknow"]		= "Unknow Contracts"
		,["veritas_Reset_all"]			= "Reset All DayNight"
		,["veritasDesc_Resetall"]		= "set all to default"
		,["veritas_override"]			= "override"
		,["veritasDesc_override"]		= "This option will override all map's Day/Night\nUnless set it to default."
	})
	
	--tweak_data.levels[ level_id ].name_id
	
	for k , v in pairs( tweak_data.narrative.contacts ) do 
		self:add_localized_strings({ [veritas.main_menu .. "_" .. k] = k .. " Contracts" })
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
	,"hlm_gate_base"
	,"hlm_door_wooden_white_green"
	
	,"hox_fbi_armory"		--early Morning
	,"hlm_reader" 			--pd2_env_morning_02
	,"hlm_vault"			--pd2_env_arm_hcm_02
	
	,"mus_security_barrier" --pd2_env_mid_day
	,"hlm_box_contraband001"--pd2_env_afternoon
	,"san_box_tree001"		--pd2_env_foggy_bright
}

for i , v in pairs( PackageList ) do
	local  path = PackageBase .. v .. "/world"
	if not PackageManager:loaded(path) then PackageManager:load(path) end
end

if not 	PackageManager:loaded( "levels/narratives/vlad/ukrainian_job/world_sounds" ) then
		PackageManager:load	 ( "levels/narratives/vlad/ukrainian_job/world_sounds" )
		PackageManager:load	 ( "levels/narratives/vlad/jewelry_store/world_sounds" )
end