local gt = cc.exports.gt

cc.exports.Utils = {}

local kCLLocationAccuracyBest = -1.000000
local kCLLocationAccuracyNearestTenMeters = 10.000000
local kCLLocationAccuracyHundredMeters = 100.000000
local kCLLocationAccuracyKilometer = 1000.000000
local kCLLocationAccuracyThreeKilometers = 3000.000000

local function getMJTileResName(displaySeatIdx, color, num, ishzlz, isBig)
	if displaySeatIdx == 2 then displaySeatIdx = 4 end
	
	-- gt.log(" 红中 " .. color .. num)
	if ishzlz == false then
		if color == 4 and num == 5 then
			-- gt.log(" 不带癞字的红中 ")
			if isBig == 1  or ((displaySeatIdx  == 1 or displaySeatIdx == 3) and isBig ~= 2) then
				return string.format("p%db%d_%d.png", displaySeatIdx, 5, 1)
			else
				return string.format("p%ds%d_%d.png", displaySeatIdx, 5, 1)
			end
		end
	else
		-- gt.log(" 不带癞字的红中 ")
	end
	
	-- gt.log(" －－－－－－－－－ ")
	gt.log("-----------------------------displaySeatIdx", displaySeatIdx)
	if isBig == 1 or ((displaySeatIdx  == 1 or displaySeatIdx == 3) and isBig ~= 2) then
		return string.format("p%db%d_%d.png", displaySeatIdx, color, num)
	else
		return string.format("p%ds%d_%d.png", displaySeatIdx, color, num)
	end
end
Utils.getMJTileResName = getMJTileResName

local function verifyPhoneNumber(numberStr)
	local numberStr = tonumber(numberStr)
	return numberStr and string.len(numberStr) == 11
end
Utils.verifyPhoneNumber = verifyPhoneNumber

-- 判断手机号码
local function onVerifyPhoneNumber(phoneNum)
	if not phoneNum or not tonumber(phoneNum) then
		require("client/game/dialog/NoticeTips"):create("提示", "手机号格式错误,请重新输入!", nil, nil, true)
		return false
	end
	if string.len(phoneNum) ~= 11 then
		require("client/game/dialog/NoticeTips"):create("提示", "手机号长度错误,请重新输入!", nil, nil, true)
		return false
	end	
end
Utils.onVerifyPhoneNumber = onVerifyPhoneNumber

-- 判断手机验证码
local function onVerificationCode(verification, serverVerification)
	if not verification or not tonumber(verification) then
		require("client/game/dialog/NoticeTips"):create("提示", "验证码格式错误,请重新输入!", nil, nil, true)
		return false
	end
	if verification ~= serverVerification then
		require("client/game/dialog/NoticeTips"):create("提示", "验证码输入有误,请重新输入!", nil, nil, true)
		return false
	end
	if string.len(phoneNum) ~= 6 then
		require("client/game/dialog/NoticeTips"):create("提示", "验证码长度有误,请重新输入!", nil, nil, true)
		return false
	end	
end
Utils.onVerificationCode = onVerificationCode

-- 判断版本号
local function checkVersion(_bai, _shi, _ge)
	local luaBridge = nil
	local ok, appVersion = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		ok, appVersion = luaBridge.callStaticMethod("AppController", "getVersionName")
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		ok, appVersion = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")
	end
	local versionNumber = string.split(appVersion, '.')
	if tonumber(versionNumber[1]) > tonumber(_bai)
		or versionNumber[2] and tonumber(versionNumber[2]) > tonumber(_shi)
		or versionNumber[3] and tonumber(versionNumber[3]) > tonumber(_ge) then
		return true
	end
	return false
end
Utils.checkVersion = checkVersion

-- 判断热更新版本号
local function checkUpdateVersion(serverAppVersion, localAppVersion)
	local serverVersionNumber = string.split(serverAppVersion, '.')
	--dump(serverVersionNumber)

	local localVersionNumber = string.split(localAppVersion, '.')
	--dump(localVersionNumber)

	local _serverBai = 0
	local _serverShi = 0
	local _serverGe = 0

	local _localBai = 0
	local _localShi = 0
	local _localGe = 0

	if serverVersionNumber[1] then
		_serverBai = tonumber(serverVersionNumber[1])
	end

	if serverVersionNumber[2] then
		_serverShi = tonumber(serverVersionNumber[2])
	end

	if serverVersionNumber[3] then
		_serverGe = tonumber(serverVersionNumber[3])
	end

	if localVersionNumber[1] then
		_localBai = tonumber(localVersionNumber[1])
	end

	if localVersionNumber[2] then
		_localShi = tonumber(localVersionNumber[2])
	end

	if localVersionNumber[3] then
		_localGe = tonumber(localVersionNumber[3])
	end

	if _serverBai > _localBai then
		return true
	elseif _serverBai == _localBai then
		if _serverShi > _localShi then
			return true
		elseif _serverShi == _localShi then
			if _serverGe > _localGe then
				return true
			end
		end
	end

	return false
end
Utils.checkUpdateVersion = checkUpdateVersion

-- 分享给好友缺几人
local function getNeedPlayerCount(PlayerCount, Greater2CanStart, state)
	local needPlayerCount = 0
	local content = ""

	if Greater2CanStart and Greater2CanStart == 1 then
		if state and state == 100006 then
			content = "，随时开局(2-3人)，快来！"
		else
			content = "，随时开局(2-4人)，快来！"
		end
	else
		needPlayerCount = gt.totalPlayerNum - PlayerCount

		if needPlayerCount == 1 then
			content = "，缺一，快来！"
		elseif needPlayerCount == 2 then
			content = "，缺二，快来！"
		elseif needPlayerCount == 3 then
			content = "，缺三，快来！"
		elseif needPlayerCount >= 4 then
			content = "，缺四，快来！"
		else
			content = "，"
		end
	end

	return content
end
Utils.getNeedPlayerCount = getNeedPlayerCount

-- 分享给好友
local function shareURLToHY(url, title, description, callback)
	local androidParam = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
	local luaBridge = nil
	url = url
	gt.log("shareURLToHY", url, title, description, callback)
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		gt.log("require")
		if checkVersion(1, 0, 12) then
			local ok = luaBridge.callStaticMethod("AppController", "shareURLToWX",
				{ url = url, title = title, description = description, scriptHandler = function(authCode)
					if (gt.isIOSPlatform() and authCode == 0) or (gt.isAndroidPlatform() and authCode == "success") then
						if callback then
							callback(0)
						end
					else
						if callback then
							callback(1)
						end
					end
				end })
		else
			local ok = luaBridge.callStaticMethod("AppController", "shareURLToWX",
				{ url = url, title = title, description = description })
		end

	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		if checkVersion(1, 0, 12) then
			luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerGetAuthCodeHandler", { function(authCode)
					if (gt.isIOSPlatform() and authCode == 0) or (gt.isAndroidPlatform() and authCode == "success") then
						if callback then
							callback(0)
						end
					else
						if callback then
							callback(1)
						end
					end
				end }, "(I)V")
		end
		local ok = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "shareURLToWX",
			{ url, title, description },
			androidParam)
	end	
end
Utils.shareURLToHY = shareURLToHY

local function shareImageToWX(shareImgFilePath, width, height, size)
	local androidParam = "(Ljava/lang/String;III)V"
	if gt.isIOSPlatform() then
		local luaoc = require("cocos/cocos2d/luaoc")
		luaoc.callStaticMethod("AppController", "shareImageToWX", { imgFilePath = shareImgFilePath, width = width, height = height, size = size })
	elseif gt.isAndroidPlatform() then
		local luaj = require("cocos/cocos2d/luaj")
		gt.log("------------------------test"..tostring(width)..tostring(height)..tostring(size))
		luaj.callStaticMethod( "org/cocos2dx/lua/AppActivity", "shareImageToWX", { shareImgFilePath, width, height, size }, androidParam )
	end	
end
Utils.shareImageToWX = shareImageToWX

-- 分享到朋友圈
local function shareURLToWXPYQ(url, title, description, callback)
	local androidParam = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
	local luaBridge = nil
	url = url
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		if checkVersion(1, 0, 12) then
			local ok = luaBridge.callStaticMethod("AppController", "shareURLToWXPYQ",
				{ url = url, title = title .. description, description = "", scriptHandler = function(authCode)
					if (gt.isIOSPlatform() and authCode == 0) or (gt.isAndroidPlatform() and authCode == "success") then
						if callback then
							callback(0)
						end
					else
						if callback then
							callback(1)
						end
					end
				end })
		else
			local ok = luaBridge.callStaticMethod("AppController", "shareURLToWXPYQ",
				{ url = url, title = title .. description, description = "" })
		end
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		if checkVersion(1, 0, 12) then
			luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerGetAuthCodeHandler", { function(authCode)
				if (gt.isIOSPlatform() and authCode == 0) or (gt.isAndroidPlatform() and authCode == "success") then
					if callback then
						callback(0)
					end
				else
					if callback then
						callback(1)
					end
				end
			end }, "(I)V")			
		end
		local ok = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "shareURLToWXPYQ",
			{ url, title .. description, "" },
			androidParam)
	end	
end
Utils.shareURLToWXPYQ = shareURLToWXPYQ

-- 分享到朋友圈(自定义ICON)
local function shareURLToWXPYQICON(url, icon, title, description, callback)
	local androidParam = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
	local luaBridge = nil
	url = url
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		local ok = luaBridge.callStaticMethod("AppController", "shareURLToWXPYQICON",
			{ url = url, icon = icon, title = title .. description, description = "", scriptHandler = function(authCode)
				if authCode == 0 then
					if callback then
						callback(0)
					end
				else
					if callback then
						callback(1)
					end
				end
			end })
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerGetAuthCodeHandler", { function(authCode)
			if authCode == "0" then
				if callback then
					callback(0)
				end
			else
				if callback then
					callback(1)
				end
			end
		end }, "(I)V")
		local ok = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "shareURLToWXPYQICON",
			{ url, icon, title .. description, "" },
			androidParam)
	end	
end
Utils.shareURLToWXPYQICON = shareURLToWXPYQICON

local function shareImageToWXPYQ(imagePath, width, height, callback)
	local androidParam = "(Ljava/lang/String;II)V"
	local luaBridge = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		local ok = luaBridge.callStaticMethod("AppController", "shareImageToWXPYQ",
			{ imagePath = imagePath, width = width, height = height, scriptHandler = function(authCode)
				if authCode == 0 then
					if callback then
						callback(0)
					end
				else
					if callback then
						callback(1)
					end
				end
			end })
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerGetAuthCodeHandler", { function(authCode)
			if authCode == "0" then
				if callback then
					callback(0)
				end
			else
				if callback then
					callback(1)
				end
			end
		end }, "(I)V")	
		local ok = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "shareImageToWXPYQ",
			{ imagePath, width, height },
			androidParam)
	end	
end
Utils.shareImageToWXPYQ = shareImageToWXPYQ

local function shareMoreImageToWXPYQ(imagePath, width, height, callback)
	local androidParam = "(Ljava/lang/String;II)V"
	local luaBridge = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		local ok = luaBridge.callStaticMethod("AppController", "shareMoreImageToWXPYQ",
			{ imagePath = imagePath, width = width, height = height, scriptHandler = function(authCode)
				if authCode == 0 then
					if callback then
						callback(0)
					end
				else
					if callback then
						callback(1)
					end
				end
			end })
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerGetAuthCodeHandler", { function(authCode)
			if authCode == "0" then
				if callback then
					callback(0)
				end
			else
				if callback then
					callback(1)
				end
			end
		end }, "(I)V")	
		local ok = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "shareMoreImageToWXPYQ",
			{ imagePath, width, height },
			androidParam)
	end	
end
Utils.shareImageToWXPYQ = shareImageToWXPYQ

-- start --
--------------------------------
-- @class function floatText
-- @description 浮动文本
-- @param content 内容
-- @return
-- end --
local function newFloatText(content, time)
	local showTime = 0.8
	if time then
		showTime = time
	end
	-- dump(textTab)
	if not content or content == "" then
		return
	end
	-- local num = 1
	-- local scheduleHandler = nil
	-- local function onCarousel()
		-- num = num + 1
		-- if num <= #textTab then
			local offsetY = 20
			local rootNode = cc.Node:create()
			rootNode:setPosition(cc.p(gt.winCenter.x, gt.winCenter.y - offsetY))

			local bg = cc.Scale9Sprite:create("res/images/otherImages/distance_tips_bg.png")
			local capInsets = cc.size(200, 5)
			local textWidth = bg:getContentSize().width - gt.winSize.height - 50 -- capInsets.width * 2
			bg:setScale9Enabled(true)
			bg:setCapInsets(cc.rect(capInsets.width, capInsets.height, bg:getContentSize().width - capInsets.width, bg:getContentSize().height - capInsets.height))
			bg:setAnchorPoint(cc.p(0.5, 0.5))
			bg:setGlobalZOrder(gt.golbalZOrder)
			gt.golbalZOrder = gt.golbalZOrder + 1
			rootNode:addChild(bg)

			local ttfConfig = {}
			ttfConfig.fontFilePath = gt.fontNormal
			ttfConfig.fontSize = 32
			local ttfLabel = cc.Label:createWithTTF(ttfConfig, content)
			ttfLabel:setGlobalZOrder(gt.golbalZOrder)
			gt.golbalZOrder = gt.golbalZOrder + 1
			-- ttfLabel:setTextColor(cc.YELLOW)
			ttfLabel:setAnchorPoint(cc.p(0.5, 0.5))
			rootNode:addChild(ttfLabel)

			if ttfLabel:getContentSize().width > textWidth then
				bg:setContentSize(cc.size(bg:getContentSize().width + (ttfLabel:getContentSize().width - textWidth), bg:getContentSize().height))
			end
			
			-- local action = cc.Sequence:create(
			-- 	cc.MoveBy:create(showTime, cc.p(0, 120)),
			-- 	cc.CallFunc:create(function()
			-- 		rootNode:removeFromParent(true)
			-- 	end)
			-- )
			-- cc.Director:getInstance():getRunningScene():addChild(rootNode)
			-- rootNode:runAction(action)	
		-- else
		-- 	gt.scheduler:unscheduleScriptEntry(scheduleHandler)
		-- 	scheduleHandler = nil
		-- 	return
		-- end
	-- end
	-- scheduleHandler = gt.scheduler:scheduleScriptFunc(onCarousel, showTime, false)

end
Utils.newFloatText = newFloatText

Utils.layerZOrder = 1000
function Utils.addToRunningScene(node)
	Utils.layerZOrder = Utils.layerZOrder + 10
	cc.Director:getInstance():getRunningScene():addChild(node, Utils.layerZOrder)
	node:setLocalZOrder(Utils.layerZOrder)
end

-- 初始化定位sdk
function Utils.initLocation()
	if not checkVersion(1, 0, 18) then
		return false
	end
	local luaBridge = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		if not luaBridge then
			return false
		end	
		luaBridge.callStaticMethod("AutonaviLocation", "configLocationManager",
			{key = "16229e61ed314b14b3f3d7e4329e786b", accuracy = kCLLocationAccuracyNearestTenMeters,
				locationTimeout = 10, reGeocodeTimeout = 5})
		luaBridge.callStaticMethod("AutonaviLocation", "initCompleteBlock")
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
	end
end

-- 经纬度定位
function Utils.locAction()
	if not checkVersion(1, 0, 18) then
		return false
	end
	local luaBridge = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		if not luaBridge then
			return false
		end
		luaBridge.callStaticMethod("AutonaviLocation", "locAction")
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
	end
end

-- 逆地理定位
function Utils.reGeocodeAction()
	if not checkVersion(1, 0, 18) then
		return false
	end
	local luaBridge = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		if not luaBridge then
			return false
		end
		luaBridge.callStaticMethod("AutonaviLocation", "reGeocodeAction")
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
	end

end

-- 获取逆地理定位信息
function Utils.getReGeocodeInfo()
	if not checkVersion(1, 0, 18) then
		return false
	end
	local luaBridge = nil
	local ok, address = nil
	local ok, citycode = nil
	local ok, adcode = nil
	local ok, horizontalAccuracy = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		if not luaBridge then
			return nil
		end	
		ok, address = luaBridge.callStaticMethod("AutonaviLocation", "getAddress")
		ok, citycode = luaBridge.callStaticMethod("AutonaviLocation", "getCitycode")
		ok, adcode = luaBridge.callStaticMethod("AutonaviLocation", "getAdcode")
		ok, horizontalAccuracy = luaBridge.callStaticMethod("AutonaviLocation", "getHorizontalAccuracy")		
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
	end

	return {address = address, citycode = citycode, adcode = adcode, horizontalAccuracy = horizontalAccuracy}
end

-- 获取经纬度定位信息
function Utils.getLocationInfo()
	-- if not checkVersion(1, 0, 18) then
	-- 	return false
	-- end
	local luaBridge = nil
	local ok, latitue = nil 
	local ok, longitude = nil
	local ok, horizontalAccuracy = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		if not luaBridge then
			return nil
		end
		ok, latitue = luaBridge.callStaticMethod("AppController", "getLatitude")
		ok, longitude = luaBridge.callStaticMethod("AppController", "getLongitude")
		ok, horizontalAccuracy = luaBridge.callStaticMethod("AppController", "getHorizontalAccuracy")
		
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		ok, latitue = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getLatitueValue", nil, "()Ljava/lang/String;")
		ok, longitude = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getLongitudeValue", nil, "()Ljava/lang/String;")
		ok, horizontalAccuracy = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAltitudeValue", nil, "()Ljava/lang/String;")
		
	end
	return {latitue = latitue, longitude = longitude, horizontalAccuracy = horizontalAccuracy}
end

local EARTH_RADIUS = 6378.137 -- 地球半径
local function rad(d)
   return d * math.pi / 180.0
end

-- 计算两点经纬距离
function Utils.getDistance(lat1, lng1, lat2, lng2)
   local radLat1 = rad(lat1)
   local radLat2 = rad(lat2)
   local a = radLat1 - radLat2
   local b = rad(lng1) - rad(lng2)
   local s = 2 * math.asin(math.sqrt(math.pow(math.sin(a / 2), 2)
   				+ math.cos(radLat1) * math.cos(radLat2) * math.pow(math.sin(b / 2), 2)))
   s = s * EARTH_RADIUS
   s = math.floor(s * 10000) / 10000
   return s * 1000
end

function Utils.getDDHHMMSS(time)
	local day = math.floor(time/86400)
	local hour = math.floor(time%86400/3600)
	local minute = math.floor(time%86400%3600/60)
	local second = math.floor(time%86400%3600%60)
	local ret = {day, hour, minute, second}
    return ret
end

function Utils.getStaticMethod(method)
	local luaBridge = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		local ok, result = luaBridge.callStaticMethod("AppController", method)
		return result
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		local ok, result = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", method, nil, "()Ljava/lang/String;")
		return result
	end
	return nil
end

function Utils.getMWAction()
	return Utils.getStaticMethod("getMWAction") or ""
end

function Utils.cleanMWAction()
	-- if gt.isIOSPlatform() then
	-- 	local luaBridge = require("cocos/cocos2d/luaoc")
	-- 	local ok, result = luaBridge.callStaticMethod("AppController", "cleanMWAction")
	-- 	return result
	-- elseif gt.isAndroidPlatform() then
	-- 	local luaBridge = require("cocos/cocos2d/luaj")
	-- 	local ok, result = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "cleanMWAction", nil, "()V")
	-- 	return result
	-- end
end
--创建房间免费
function Utils.isOpenFreeTip()
	local startTime = os.time({year=2016, month=10, day=12, hour=6,min=0,sec=0,isdst=false})
	local endTime = os.time({year=2016, month=10, day=15, hour=24,min=0,sec=0,isdst=false})
	local curTime = gt.loginServerTime + (os.time() - gt.loginLocalTime)
	return curTime >= startTime and curTime <= endTime
end

--是否在国庆活动期间 
function Utils.isOpenGuoQingActivity()
	local startTime = os.time({year=2016, month=9, day=30, hour=0,min=0,sec=0,isdst=false})
	local endTime = os.time({year=2016, month=10, day=9, hour=24,min=0,sec=0,isdst=false})
	local curTime = gt.loginServerTime + (os.time() - gt.loginLocalTime)
	return curTime >= startTime and curTime <= endTime
end

--获取当前服务器时间
function Utils.getServerTime()
	return gt.loginServerTime + (os.time() - gt.loginLocalTime)
end

--是否输入邀请码
function Utils.requestInvite(commitinvite)
    local account = cc.UserDefault:getInstance():getStringForKey("WX_UnionId", "test")
    local openid = cc.UserDefault:getInstance():getStringForKey("WX_OpenId", "test")
    if nil ~= gt.invitationcodeLayer then
    	gt.invitationcodeLayer = nil
    end

    local xhr = cc.XMLHttpRequest:new()
    xhr:retain()
    xhr.timeout = 30 -- 设置超时时间
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = string.format(gt.HTTP_IS_BIND, openid, account)
    xhr:open("GET", gt.getUrlEncryCode(url, gt.playerData.uid))
    xhr:registerScriptHandler( function( )
    	if xhr.readyState == 4 and xhr.status == 200 then
            local jstable =  require("cjson").decode(xhr.response)
	        if type(jstable) == "table" then
	           -- dump(jstable)
	            local errno = jstable["errno"]
	            local msg = jstable["errmsg"]
	            if errno ~= 0 then
	                Toast.showToast(context, msg, 2)
	                return
	            end
	            local data = jstable["data"]
	          --  dump(data)
	            if data.is_bind == 0 then
	     --            if commitinvite == 0 then
						-- -- gt.invitationcodeLayer = require("client/game/common/InvitationCodeInputLayers"):create()
	     -- --                if gt.invitationcodeLayer ~= nil then
						-- -- 	cc.Director:getInstance():getRunningScene():addChild(gt.invitationcodeLayer, 999)
	     -- --                end
	     --            end
	    			cc.UserDefault:getInstance():setIntegerForKey("InvitationCode"..tostring(gt.playerData.uid), 0) -- 没绑定
	            elseif data.is_bind == 1 then -- 已绑定
	            	cc.UserDefault:getInstance():setIntegerForKey("InvitationCode"..tostring(gt.playerData.uid), 1)
	            end
	        end
	    end
	    xhr:unregisterScriptHandler()
    end )
    xhr:send()
end

--提交邀请码
function Utils.commitInvite(agency_id, context, callback)
	local url = string.format(gt.HTTP_BIND_PROXY,agency_id)
    gt.log("-------------url", url)

    local xhr = cc.XMLHttpRequest:new()
    xhr:retain()
    xhr.timeout = 30 -- 设置超时时间
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("GET", gt.getUrlEncryCode(url, gt.playerData.uid))
    xhr:registerScriptHandler( function( )
    	if xhr.readyState == 4 and xhr.status == 200 then
	 	local cjson = require "cjson"
	 	local jstable = cjson.decode(xhr.response)
	        if type(jstable) == "table" then
	            local errno = jstable["errno"]
	            local msg = jstable["errmsg"]
	            if errno ~= 0 then
					local RunningScene = cc.Director:getInstance():getRunningScene()
	                Toast.showToast(RunningScene, msg, 2)
	                callback(errno, msg)
	            else
	                cc.UserDefault:getInstance():setIntegerForKey("InvitationCode"..tostring(gt.playerData.uid), 1)
	                callback(errno, "您的奖励金币已经放入您的账户，请注意查收！")
	                gt.invitationcodeLayer = nil
	            end
	        end
	    end
	    xhr:unregisterScriptHandler()
    end )
    xhr:send()
end

--代理信息
function Utils.requestAgency(context)
    local xhr = cc.XMLHttpRequest:new()
    xhr:retain()
    xhr.timeout = 30 -- 设置超时时间
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = string.format(gt.setAgency, gt.playerData.uid)
    gt.log("-------------url", url)
    xhr:open("GET", url)
    xhr:registerScriptHandler( function( )
    	if xhr.readyState == 4 and xhr.status == 200 then
	        --require("cjson")
            local jstable =  require("cjson").decode(xhr.response)
	        if type(jstable) == "table" then
	          --  dump(jstable)
	            local errno = jstable["errno"]
	            local msg = jstable["errmsg"]
	            if errno ~= 0 then
	                Toast.showToast(context, msg, 2)
	                return
	            end
	            local data = jstable["data"]
	          --  dump(data)
	        end
	    end
	    xhr:unregisterScriptHandler()
    end )
    xhr:send()
end

--人数
function Utils.setTotalPlayerNum(playType)
	if playType == 100001 then
		gt.totalPlayerNum = 4
	elseif playType == 100002 then
		gt.totalPlayerNum = 4
	elseif playType == 100008 then
		gt.totalPlayerNum = 4
    elseif playType == 100009 then
		gt.totalPlayerNum = 4
    elseif playType == 100010 then
		gt.totalPlayerNum = 4
	elseif playType == 100012 then
		gt.totalPlayerNum = 2
	elseif playType == 100013 then
		gt.totalPlayerNum = 3
	elseif playType == 100014 then
		gt.totalPlayerNum = 2
	elseif playType == 100015 then
		gt.totalPlayerNum = 3
	elseif playType == 102005 then
		gt.totalPlayerNum = 2
	elseif playType == 103005 then
		gt.totalPlayerNum = 3
	elseif playType == 102008 then
		gt.totalPlayerNum = 2
	elseif playType == 103008 then
		gt.totalPlayerNum = 3
	elseif playType == 102009 then
		gt.totalPlayerNum = 2
	elseif playType == 103009 then
		gt.totalPlayerNum = 3
	elseif playType == 102010 then
		gt.totalPlayerNum = 2
	elseif playType == 103010 then
		gt.totalPlayerNum = 3
	end
end

--大玩法内容
function Utils.getplayName(playType)
	local playTypeDesc = ""
	if playType == 100001 then
		playTypeDesc = "推倒胡"
		gt.totalPlayerNum = 4
	elseif playType == 100002 then
		playTypeDesc = "扣点点"
		gt.totalPlayerNum = 4
	elseif playType == 100016 then
		playTypeDesc = "忻州扣点点"
		gt.totalPlayerNum = 4
	elseif playType == 100017 then
		playTypeDesc = "临汾撵中子"
		gt.totalPlayerNum = 4
	elseif playType == 100008 then
		playTypeDesc = "硬三嘴"
		gt.totalPlayerNum = 4
    elseif playType == 100009 then
		playTypeDesc = "洪洞王牌"
		gt.totalPlayerNum = 4
    elseif playType == 100005 then
		playTypeDesc = "晋中"
		gt.totalPlayerNum = 4
    elseif playType == 100006 then
		playTypeDesc = "拐三角"
		gt.totalPlayerNum = 3
    elseif playType == 100010 then
		playTypeDesc = "一门牌"	
		gt.totalPlayerNum = 4
	elseif playType == 100012 then
		playTypeDesc = "二人扣点点"
		gt.totalPlayerNum = 2
	elseif playType == 100013 then
		playTypeDesc = "三人扣点点"
		gt.totalPlayerNum = 3
	elseif playType == 100014 then
		playTypeDesc = "二人推倒胡"
		gt.totalPlayerNum = 2
	elseif playType == 100015 then
		playTypeDesc = "三人推倒胡"
		gt.totalPlayerNum = 3

	elseif playType == 102005 then
		playTypeDesc = "二人晋中"
		gt.totalPlayerNum = 2
	elseif playType == 103005 then
		playTypeDesc = "三人晋中"
		gt.totalPlayerNum = 3

	elseif playType == 102008 then
		playTypeDesc = "二人硬三嘴"
		gt.totalPlayerNum = 2
	elseif playType == 103008 then
		playTypeDesc = "三人硬三嘴"
		gt.totalPlayerNum = 3

	elseif playType == 102009 then
		playTypeDesc = "二人洪洞王牌"
		gt.totalPlayerNum = 2
	elseif playType == 103009 then
		playTypeDesc = "三人洪洞王牌"
		gt.totalPlayerNum = 3

	elseif playType == 102010 then
		playTypeDesc = "二人一门牌"
		gt.totalPlayerNum = 2
	elseif playType == 103010 then
		playTypeDesc = "三人一门牌"
		gt.totalPlayerNum = 3
	elseif playType == 100018 then
		playTypeDesc = "陵川靠八张"
		gt.totalPlayerNum = 4
	end

	return playTypeDesc
end

--邀请好友内容
function Utils.shareContent(table)

	--洪洞王牌，房号653008(8)，底分2【分摊房费】【VIP防作弊】
    --色牌，暗杠可见，国内唯一360'全方位防作弊麻将。
	--<玩法类型>，房号<房号>(<X局>)，底分<底分>【房主支付/分摊房费】【VIP防作弊或者空】
	--<玩法小选项，用逗号分隔>，国内唯一360'全方位防作弊麻将。
	require("client/config/MJRules")
	local content = ""

	local playTypeDesc = ""
	-- if table.m_state == 100001 then
	-- 	playTypeDesc = "推倒胡"
	-- elseif table.m_state == 100002 then
	-- 	playTypeDesc = "扣点点"
	-- elseif table.m_state == 100008 then
	-- 	playTypeDesc = "硬三嘴"
 --    elseif table.m_state == 100009 then
	-- 	playTypeDesc = "洪洞王牌"
 --    elseif table.m_state == 100010 then
	-- 	playTypeDesc = "一门牌"	
	-- end
	playTypeDesc = Utils.getplayName(table.kState)
	-- content = playTypeDesc.."，"

	-- if table.m_flag == 1 then
	-- 	content = content.."房号"..table.m_deskId.."(8局)".."，"
	-- elseif table.m_flag == 2 then
	-- 	content = content.."房号"..table.m_deskId.."(16局)".."，"
	-- end

	-- content = content.."底分"..table.m_cellscore

	if table.kCheatAgainst == 1 then
		content = content.."【视频防作弊】" --【相邻玩家禁止进入】
	end

	if table.kGpsLimit == 1 then 
		
		content = content.."【相邻玩家禁止进入】"
	end
	content = content.."底分"..table.kCellscore

	if table.kFeeType == 0 then
		content = content.."【房主支付】"
	elseif table.kFeeType == 1 then
		content = content.."【分摊房费】"
	end

	

	content =content.."\n"

	local wanfaStr = ""
    for i = 1, #table.kPlaytype do
    	if i == 1 then
    		local firstWanfa = MJRules.Rules[table.kPlaytype[1]].name
    		wanfaStr = wanfaStr .. firstWanfa
 			wanfaStr = string.gsub(wanfaStr, "，", "")
    	elseif MJRules.Rules[table.kPlaytype[i]] ~= nil then
    		wanfaStr = wanfaStr .. MJRules.Rules[table.kPlaytype[i]].name
    	end
    end
    content = content..wanfaStr.."，"
    content = content.."国内唯一360'全方位防作弊麻将。"

    gt.shareContentWeb[table.kDeskId] = playTypeDesc.."，".."底分"..table.kCellscore.."，"..wanfaStr
    gt.shareContentWeiXin[table.kDeskId] = content
    gt.log(content)
    return content
end
-- local list = {}
--     for i=1, 4 do
--     	if self.roomPlayers[i] ~= nil and self.roomPlayers[i].uid ~= gt.playerData.uid then
--     		table.insert(list, {self.roomPlayers[i].uid, self.roomPlayers[i].nickname, self.roomPlayers[i].ip})
--     	end
--     end

--     table.sort(list, function(first, second)
--     	return first[3] > second[3]
--     end)

--     local msg = ""
--     local curIp = ""
--     local sameIpCount = 0
--     local msg_all = ""
--     for idex = 1, #list do
--     	if list[idex].ip ~= curIp then
--     		--这里是下一个不相等的IP了
--     		if sameIpCount > 1 then
--     			--这里是有相同IP
--     			msg_all = msg_all..msg.." IP相同,"
--     		end
--     		msg = ""
--     		sameIpCount = 0
--     		curIp = list[idex].ip
--     	end
--     	msg = msg..list[idex].nickname .. "("..list[idex].ip.."),"
--     	sameIpCount = sameIpCount + 1
--     end

--     --这里需要最后一段的IP
--     if sameIpCount > 1 then
--     	msg_all = msg_all..msg.." IP相同"
--     end
return Utils