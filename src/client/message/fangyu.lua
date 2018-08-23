local fangyu = class("fangyu")

fangyu.name_s = "d8dbfeeaf12"
fangyu.name_e = "25f1fd508b1"

function fangyu:ctor(...)
	local args = {...}
	self.succeedCall = args[1]
	self.failedCall = args[2]
	self.unionid = args[3]
	self.chu_wan = 5
	self.zhong_wan = 6
	self.gao_wan = 7
	self.gu_wan = 8
end

function fangyu:getName()
	return "fangyu"
end

function fangyu:request()
	
	secure.log("fangyu request")
	self:reset()

	--local srcSign = string.format("%s%s", self.uuid, secure.fanghu.servername)
	--local sign = cc.UtilityExtension:generateMD5(srcSign, string.len(srcSign))
	local xhr = cc.XMLHttpRequest:new()
	xhr.timeout = 5
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local refreshTokenURL = gt.getUrlEncryCode(gt.loginUrl_gaofang, gt.playerData.uid)
	xhr:open("GET", refreshTokenURL)
	local function onResp()
		secure.log("xhr.readyState = " .. xhr.readyState .. ", xhr.status = " .. xhr.status)
		secure.log("xhr.statusText = " .. xhr.statusText)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			secure.log("fangyu response:" .. xhr.response)
			local respJson = require("cjson").decode(xhr.response)
			dump(respJson)
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

function fangyu:getPlayCount()
	local playCount = cc.UserDefault:getInstance():getStringForKey("yoyo_name")
	if playCount ~= "" then
		local s = string.find(playCount, fangyu.name_s)
		local e = string.find(playCount, fangyu.name_e)
		if s and e then
			return string.sub(playCount, s + string.len(fangyu.name_s), e - 1)
		end
	end
	return 0
end

function fangyu.savePlayCount(count)
	local name = fangyu.name_s .. count .. fangyu.name_e
	cc.UserDefault:getInstance():setStringForKey("yoyo_name", name)
end

function fangyu:getAscii(uuid)
	if not uuid then
		return 1
	end
	local ascii = string.byte(string.sub(uuid, #uuid - 1))
	return (ascii % 4) + 1
end

function fangyu:getFileByNum(num)
	local filename = "s_1_3_1_4_" .. num .. "_2_4_3"
	local md5 = cc.UtilityExtension:generateMD5(filename, string.len(filename))
	local url = gt.getUrlEncryCode(gt.loginUrl, gt.playerData.uid)--"http://allgame.ixianlai.com/" .. secure.fanghu.servername .. "_" .. md5 .. "_" .. num .. "_.txt"
	return url
end

function fangyu:getYoYoFile(filename)
	if self.xhr == nil then
        self.xhr = cc.XMLHttpRequest:new()
        self.xhr:retain()
        self.xhr.timeout = 10 -- 设置超时时间
    end
    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local refreshTokenURL = filename
    self.xhr:open("GET", refreshTokenURL)
    self.xhr:registerScriptHandler(handler(self, self.onYoYoResp))
    self.xhr:send()
end

function fangyu:onYoYoResp()
	-- 默认高防
    if self.xhr.readyState == 4 and (self.xhr.status >= 200 and self.xhr.status < 207) then
		local ret = require("cjson").decode(self.xhr.response)
        -- self.dataRecv = self.xhr.response -- 获取到数据
        -- local ret = tostring(self.xhr.response)
        if ret then
        	if ret.errno == 0 then
   				local ipTable = string.split(ret.data.ip, "#")
				self.ip = ipTable[1]
				self.port = ipTable[2]
				self.serverId = ret.data.manager_id
				
				gt.LoginServer.ip = self.ip
				gt.LoginServer.port = self.port
				gt.serverId = self.serverId

				self.xhr:unregisterScriptHandler()
				if self.succeedCall then
					self.succeedCall(self)
				end
			else
				if self.failedCall then
					self.failedCall(self)
				end
			end
			--local ipTab = string.split(data, ".")
			-- if #ipTab == 4 then -- 正确的ip地址
			-- 	self.ip = data
			-- 	self.xhr:unregisterScriptHandler()
			-- 	if self.succeedCall then
			-- 		self.succeedCall(self)
			-- 	end
			-- else
			-- 	if self.failedCall then
			-- 		self.failedCall(self)
			-- 	end
			-- end
        end
    elseif self.xhr.readyState == 1 and self.xhr.status == 0 then
        -- 网络问题,异常断开
        if self.failedCall then
			self.failedCall(self)
		end
    end
    self.xhr:unregisterScriptHandler()
end

function fangyu:getIP()
	-- secure.log("fangyu getIP:", self.ip)
	return self.ip
end

function fangyu:getPort()
	-- secure.log("fangyu getPort:", self.port)
	return self.port
end

function fangyu:getServerId()
	-- secure.log("server id:", self.serverId)
	return self.serverId
end

function fangyu:reset()
	self.ip = nil
end

return fangyu