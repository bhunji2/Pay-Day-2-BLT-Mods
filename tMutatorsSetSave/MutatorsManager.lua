
Hooks:PreHook ( MutatorsManager, "init"			, "tMSS_MM_init"		, 
	function()	MutatorsManager.ProfileLoad() end )
Hooks:PostHook( MutatorsManager, "set_enabled"	, "tMSS_MM_set_enabled"	, 
	function() 	MutatorsManager.ProfileSave() end )

function MutatorsManager:ProfileLoad()
	local  file = io.open(SavePath .. "tMutatorsSetSave.json", "r")
	if not file   then return false end
	local  fileT= file:read("*all"):gsub("%[%],","{},") 
		   file : close()
	
	if string.len(fileT) < 10 or fileT == "[]" then return end
	
	Global.mutators 				= Global.mutators or { mutator_values = {}, active_on_load = {} }
	Global.mutators.mutator_values 	= json.decode(fileT)
end

function MutatorsManager:ProfileSave()
	local  file = io.open(SavePath .. "tMutatorsSetSave.json", "w+")
	if not file then return false end
		   file:write(json.encode(Global.mutators.mutator_values))
		   file:close()
end