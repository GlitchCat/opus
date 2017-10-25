local Event  = require('event')
local Socket = require('socket')

Event.addRoutine(function()
  while true do
    print('proxy: listening on port 188')
    local socket = Socket.server(188)

    print('proxy: connection from ' .. socket.dhost)

	  Event.addRoutine(function()
	    local api = socket:read(2)
	    if api then
				local proxy = _G[api]

		    local methods = { }
				for k,v in pairs(proxy) do
					if type(v) == 'function' then
						table.insert(methods, k)
					end
				end
				socket:write(methods)

			  while true do
			    local data = socket:read()
			    if not data then
			      break
			    end
			    socket:write({ proxy[data.fn](unpack(data.args)) })
			  end
			end
		end)
	end
end)
