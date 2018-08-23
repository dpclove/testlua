-- 
local fanghu = class("fanghu")

function fanghu:ctor(...)
	local args = {...}
	self.succeedCall = args[1]
	self.failedCall = args[2]
	self.uuid = args[3]
end

function fanghu:request()
	
	secure.log("fanghu request")
	self:reset()

	--local srcSign = string.format("%s%s", self.uuid, secure.fanghu.servername)
	--local sign = cc.UtilityExtension:generateMD5(srcSign, string.len(srcSign))
	local xhr = cc.XMLHttpRequest:new()
	xhr.timeout = 5
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	--local refreshTokenURL = string.format("http://secureapi.ixianlai.com/security/server/getIPbyZoneUid")
	-- local refreshTokenURL = string.format("http://api.test.ry.haoyunlaiyule.com/client/xianlai?type=tingjian")
	-- local refreshTokenURL = string.format("http://test.api.haoyunlaiyule1.com/client/logon")
	-- local refreshTokenURL = string.format("http://test.api.haoyunlaiyule1.com/client/logon?type=stage")
	local refreshTokenURL = gt.getUrlEncryCode(gt.loginUrl, gt.playerData.uid)
	xhr:open("GET", refreshTokenURL)
	local function onResp()
	
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			
			local respJson = require("cjson").decode(xhr.response)
			gt.dump(respJson)
			if respJson.errno == 0 then -- 服务器现在是 字符"0",应该修改为 数字0
				

   				local ipTable = string.split(respJson.data.ip, "#")
				self.ip = ipTable[1]
				self.port = ipTable[2]
				self.serverId = respJson.data.manager_id;

				gt.LoginServer.ip = self.ip
				gt.LoginServer.port = self.port
				gt.serverId = self.serverId
				
				if self.succeedCall then
					
					self.succeedCall(self)
				else
					
				end
			else
				
				
				if self.failedCall then
					
					self.failedCall(self)
				else
					
				end
			end
		elseif xhr.readyState == 1 and xhr.status == 0 then
			
			if self.failedCall then
				self:failedCall(self)
			end
		else
			if self.failedCall then
				self:failedCall(self)
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
	--xhr:send(string.format("uuid=%s&servername=%s&sign=%s", self.uuid, secure.fanghu.servername, sign))
end

function fanghu:getIP()
	secure.log("fanghu getIP:", self.ip)
	return self.ip
end

function fanghu:getPort()
	secure.log("fanghu getPort:", self.port)
	return self.port
end

function fanghu:getServerId()
	secure.log("server id:", self.serverId)
	return self.serverId
end

function fanghu:getName()
	return "fanghu"
end

function fanghu:reset()
	self.ip = nil
end

return fanghu