LevelsTweakData.oinit = LevelsTweakData.oinit or LevelsTweakData.init

local time_settings = {
	"",
	"",
	"environments/pd2_env_hox_02/pd2_env_hox_02",
	"environments/pd2_env_morning_02/pd2_env_morning_02",
	"environments/pd2_env_arm_hcm_02/pd2_env_arm_hcm_02",
	"environments/pd2_env_n2/pd2_env_n2"
}

function LevelsTweakData:init()
	
	LevelsTweakData.oinit()

	veritas:Load()
	veritas.levels = {}

	for _ , level_id in pairs( self._level_index ) do
		if self[ level_id ] and self[ level_id ].name_id and not self[ level_id ].env_params then
			veritas.levels[ level_id ] = self[ level_id ].name_id
		end
	end

	for _ , level_id in pairs( self._level_index ) do

		if veritas and veritas.options and veritas.options[ level_id ] and veritas.options[ level_id ] ~= nil and veritas.options[ level_id ] ~= 1 then
			if veritas.options[ level_id ] == 2 then
				self[ level_id ].env_params = { environment = time_settings[ math.random( 3 , 6 ) ] }
			else
				self[ level_id ].env_params = { environment = time_settings[ veritas.options[ level_id ] ] }
			end
			log( "Custom Time Loaded: " .. level_id )
		end

	end

end

