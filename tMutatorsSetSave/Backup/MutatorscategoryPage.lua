

--[[
TMSS_MCP_init = TMSS_MCP_init or MutatorsCategoryPage.init
function MutatorsCategoryPage:init(page_id, page_panel, fullscreen_panel, gui)
	log("/MutatorsCategoryPage:init")
	TMSS_MCP_init(self,page_id, page_panel, fullscreen_panel, gui)
	--managers.mutators:ProfileLoad()
end

TMSS_MCP__setup_mutators_list = TMSS_MCP__setup_mutators_list or MutatorsCategoryPage._setup_mutators_list
function MutatorsCategoryPage:_setup_mutators_list()
	log("/MutatorsCategoryPage:_setup_mutators_list")
	TMSS_MCP__setup_mutators_list(self)
	--managers.mutators:ProfileLoad()
end
]]

--[[
local do_refresh = false

TMSS_MCP_refresh = TMSS_MCP_refresh or MutatorsCategoryPage.refresh
function MutatorsCategoryPage:refresh()
	
	log("/MutatorsCategoryPage:refresh")
	if not 	do_refresh 	 then 
			managers.mutators:ProfileLoad()
			do_refresh = true
			return
	end
	
	TMSS_MCP_refresh(self)
end
]]
--[[
Hooks:PostHook( MutatorsCategoryPage, "_on_mutators_panel_updated", "TestPostPlayerManagerInit", function()
    log("//MutatorsCategoryPage")
	
	DelayedCalls:Add( "DelayedCallsExamplesdgasd", 3, function()
		managers.mutators:ProfileLoad()
	end )
end )
]]