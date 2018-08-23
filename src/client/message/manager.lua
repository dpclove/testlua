--require("app/secure/init")

local manager = class("manager")

local _instance = nil
function manager:getInstance()
	if not _instance then
		_instance = require("client/message/manager"):new()
	end
	return _instance
end

function manager:ctor(...)
	self.managers = secure.managers
	self.managerIdx = 1
end

function manager:init(params)
	self.uuid = params.uuid
	self.succeedCall = params.succeedCall
	self.failedCall = params.failedCall
	if self.succeedCall then
		print("here = = = = = = = = = = = = = = = = succeedCall is not null")
	end
end

function manager:request()
	self:reset()
	self:nextState()
end

function manager:getCurIPState()
	return self.curIPState
end

function manager:nextState()
	if #self.managers <= 0 then
		
		return
	end

	if self.managerIdx > #self.managers then
		self.managerIdx = 1
	end

	local statename = self.managers[self.managerIdx]
	
	if statename == "fanghu" then
		self.curIPState = require("client/message/fanghu").new(handler(self, self.onRespSucceed), handler(self, self.onRespFailed), self.uuid)
	elseif statename == "fangyu" then
		self.curIPState = require("client/message/fangyu").new(handler(self, self.onRespSucceed), handler(self, self.onRespFailed), self.uuid)
	elseif statename == "ddos" then
		self.curIPState = require("client/message/ddos").new(handler(self, self.onRespSucceed), handler(self, self.onRespFailed))
	end

	self.managerIdx = self.managerIdx + 1

	if self.curIPState then
		self.curIPState:request()
	end
end

function manager:reset()
	self.curIPState = nil
	self.managerIdx = 1
end

function manager:getIP()
	if self.curIPState then
		return self.curIPState:getIP()
	end
	return nil
end

function manager:getPort()
	if self.curIPState then
		return self.curIPState:getPort()
	end
end

function manager:getServerId()
	if self.curIPState then
		return self.curIPState:getServerId()
	end
end

function manager:savePlayCount(count)
	require("client/message/fangyu").savePlayCount(count)
end

function manager:onRespSucceed(ipstate)
	
	if self.succeedCall then
		gt.log("ok__________")
		self.succeedCall(ipstate)
	end
end

function manager:onRespFailed(ipstate)
	gt.log("onRespFailed______________")
	--self:nextState()
	if self.failedCall then
		gt.log("notok________________")
		self.failedCall(ipstate)
	end
end

return manager