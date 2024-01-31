local stairs = game:GetService("Workspace")["__THINGS"]["__INSTANCE_CONTAINER"].Active.StairwayToHeaven.Stairs

while wait(1) do
    if stairs:FindFirstChild("Goal") ~= nil then
        local http = game:GetService("HttpService")
	game:GetService("StarterGui"):SetCore("SendNotification",{
		Title = "Goal Found!",
		Text = 'wtf how',
		Duration = 10,
	})
	s = false

	local message1 = {
            ['content'] = "@everyone yo congrats on the first huge golden angel dog in a long time",
    	}

    	local jsonMessage = http:JSONEncode(message1)
    	local success, webMessage = pcall(function()
	    http:PostAsync(weburl, jsonMessage)
        end)
    	if success == false then
            local response = request({
                Url = weburl,
           	Method = "POST",
            	Headers = {
                	["Content-Type"] = "application/json"
            	},
           	Body = jsonMessage
        })
    	end
	break
    end
end)
