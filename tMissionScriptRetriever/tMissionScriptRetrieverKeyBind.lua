
function showS(textInput)
	if not managers.chat then return end
	managers.chat:_receive_message(1, "MissionScript", textInput, tweak_data.system_chat_color) 
end
--[[
local ret = managers.mission:WriteRetriever()

if ret then
	log("Mission data dumped")
	showS("Mission data dumped")
else
	log("Mission data dumped faild")
	showS("Mission data dumped faild")
end
]]

local path = managers.mission.Retriever.file_path
managers.mission:_serialize_to_script( "mission", path, true)
showS("Mission data dumped")