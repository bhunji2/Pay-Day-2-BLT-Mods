
function showS(textInput)
	if not managers.chat then return end
	managers.chat:_receive_message(1, "MissionScript", textInput, tweak_data.system_chat_color) 
end

local ret = managers.mission:WriteRetriever(true)

if ret then
	log  ("Mission Scripts dumped")
	showS("Mission Scripts dumped")
else
	log  ("Mission Scripts dumped faild")
	showS("Mission Scripts dumped faild")
end