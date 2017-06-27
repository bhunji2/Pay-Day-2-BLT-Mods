-- Couldn't place in Loader.lua because the game is being a little bitch.

Hooks:PostHook( LocalizationManager , "init" , "veritasLocaizationHook" , function( self )

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