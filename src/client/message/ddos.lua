
local ddos = class("ddos")

function ddos:ctor(...)
	local args = {...}
	self.succeedCall = args[1]
	self.failedCall = args[2]
end

function ddos:request()
	
	self:reset()
	
	self.ip = secure.ddos.ip

	if self.succeedCall then
		self.succeedCall(self)
	end
end

function ddos:getIP()
	
	return self.ip
end

function ddos:getName()
	return "ddos"
end

function ddos:reset()
	self.ip = nil
end

return ddos