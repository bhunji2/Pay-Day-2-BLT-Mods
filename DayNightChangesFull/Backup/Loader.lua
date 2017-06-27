

-- Huge mother fucking credit to Dougley/Martini for this
if not _G.veritas then
	_G.veritas = {}
	veritas.mod_path = ModPath
	veritas._data_path = SavePath .. "veritas.txt"
	--veritas._data = {} 
	veritas.options = {}
	veritas.main_menu = "veritas_menu"
end

function veritas:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self.options ) )
		file:close()
	end
end

function veritas:Load()
	local file = io.open( self._data_path, "r" )
	--if file == nil then
	--	log("[veritas] No settings file found, initiating first launch...")
	--	veritas:FirstLaunch()
	--	return
	--end
	if file then
		self.options = json.decode( file:read("*all") )
		file:close()
	end
end

--[[function veritas:FirstLaunch()
	local option = veritas.options
	if veritas.options.veritas_hud_global == nil then 
		veritas.options.veritas_hud_global = true
	end	
	option.veritas_assault_global = true
	veritas:Save()
end]]

Hooks:Add( "LocalizationManagerPostInit" , "veritasLocalization" , function( self )
	
	self:add_localized_strings( {
		[ "veritas_menuTitle" ] = "Day/Night Changes",
		[ "veritas_menuDesc" ] = "Change the day/night cycles for certain heists!",
		
		[ "veritas_default" ] = "Default",
		[ "veritas_random" ] = "Random",
		[ "veritas_pd2_env_hox_02" ] = "Early Morning",
		[ "veritas_pd2_env_morning_02" ] = "Morning",
		[ "veritas_pd2_env_arm_hcm_02" ] = "Foggy Evening",
		[ "veritas_pd2_env_n2" ] = "Night"
	} )

	for level_id , text in pairs( veritas.levels ) do
		self._platform = "WIN32"
		self:add_localized_strings( {
			[ "veritas_" .. level_id ] = self:text( text ) .. ( ( string.find( tweak_data.levels[ level_id ].name_id , "2" ) and " (2)" or string.find( tweak_data.levels[ level_id ].name_id , "3" ) and " (3)" ) or "" ) or "??",
			[ "veritasDesc_" .. level_id ] = "Change the time setting for " .. ( self:text( text ) .. ( ( string.find( tweak_data.levels[ level_id ].name_id , "2" ) and " (2)" or string.find( tweak_data.levels[ level_id ].name_id , "3" ) and " (3)" ) or "" ) or "??" )
		} )
	end

end )

Hooks:Add( "MenuManagerSetupCustomMenus" , "veritasSetupMenu" , function( self , nodes )
    
	MenuHelper:NewMenu( veritas.main_menu )
	
end )

Hooks:Add( "MenuManagerPopulateCustomMenus" , "veritasCallbackFunctions" , function( self , nodes )
	
	if not veritas or veritas and not veritas.levels then return end
	
	for level_id , _ in pairs( veritas.levels ) do
	
		MenuCallbackHandler[ "veritasClbk_" .. level_id ] = function( self, item )
		
			veritas.options[ level_id ] = item:value()
			veritas:Save()
			
		end
	
		MenuHelper:AddMultipleChoice( {
		
			id 			= "veritasID_" .. level_id,
			title 		= "veritas_" .. level_id,
			desc 		= "veritasDesc_" .. level_id,
			callback 	= "veritasClbk_" .. level_id,
			items 		= {
							"veritas_default",
							"veritas_random",
							"veritas_pd2_env_hox_02",
							"veritas_pd2_env_morning_02",
							"veritas_pd2_env_arm_hcm_02",
							"veritas_pd2_env_n2",
						  },
			menu_id 	= veritas.main_menu,
			value 		= veritas.options[ level_id ]
			
		} )
		
	end

end )

Hooks:Add( "MenuManagerBuildCustomMenus" , "veritasBuildMenu" , function( self , nodes )

    nodes[ veritas.main_menu ] = MenuHelper:BuildMenu( veritas.main_menu )
    MenuHelper:AddMenuItem( MenuHelper.menus.lua_mod_options_menu , veritas.main_menu , "veritas_menuTitle" , "veritas_menuDesc" )
	
end )

veritas.dofiles = {}

veritas.hook_files = {
	["lib/tweak_data/levelstweakdata"] = "DayNight.lua",
	["lib/managers/localizationmanager"] = "LocalizationManager.lua"
}

if not veritas.setup then
	veritas:Load()
	if veritas.options.veritas_tod == nil then 
		veritas.options.veritas_tod = true
		veritas:Save()
	end
	veritas:Load()
	for p, d in pairs(veritas.dofiles) do
		dofile(ModPath .. d)
	end
	veritas.setup = true
	log("[veritas] Loaded options")
end

if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if veritas.hook_files[requiredScript] then
		dofile( ModPath .. veritas.hook_files[requiredScript] )
	end
end

if not PackageManager:loaded("levels/instances/unique/hlm_random_right003/world") then
	PackageManager:load("levels/instances/unique/hlm_random_right003/world")
end
if not PackageManager:loaded("levels/instances/unique/hox_fbi_armory/world") then
	PackageManager:load("levels/instances/unique/hox_fbi_armory/world")
end
if not PackageManager:loaded("levels/instances/unique/hlm_vault/world") then
	PackageManager:load("levels/instances/unique/hlm_vault/world")
end
if not PackageManager:loaded("levels/instances/unique/hlm_gate_base/world") then
	PackageManager:load("levels/instances/unique/hlm_gate_base/world")
end
if not PackageManager:loaded("levels/instances/unique/hlm_reader/world") then
	PackageManager:load("levels/instances/unique/hlm_reader/world")
end
if not PackageManager:loaded("levels/instances/unique/hlm_door_wooden_white_green/world") then
	PackageManager:load("levels/instances/unique/hlm_door_wooden_white_green/world")
end
if not PackageManager:load( "levels/narratives/vlad/ukrainian_job/world_sounds" ) then
	PackageManager:load( "levels/narratives/vlad/ukrainian_job/world_sounds" )
	PackageManager:load( "levels/narratives/vlad/jewelry_store/world_sounds" )
end