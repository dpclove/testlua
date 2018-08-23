
local gt = cc.exports.gt

local SettingMain = class("SettingMain", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function SettingMain:ctor(playerSeatPos)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("SettingMain.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
	
	if gt.isAppStoreInReview then
		local bokehImg = gt.seekNodeByName(csbNode, "Img_bokeh")
		if bokehImg then
			bokehImg:setVisible(false)
		end
	end

 --    -- 音效min
	-- self.soundMinBtn = gt.seekNodeByName(csbNode, "Btn_minSound")
	-- self.soundMaxBtn = gt.seekNodeByName(csbNode, "Btn_maxSound")
	-- -- 音乐min
	-- self.musicMinBtn = gt.seekNodeByName(csbNode, "Btn_minMusic")
	-- self.musicMaxBtn = gt.seekNodeByName(csbNode, "Btn_maxMusic")
	
	-- 关闭按钮
	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:removeFromParent()
	end)

	local function getAppVersion()
		if device.platform == "windows" or device.platform == "mac" then
			return 11
		end
		
		local luaBridge = nil
		local ok, appVersion = nil
		if gt.isIOSPlatform() then
			luaBridge = require("cocos/cocos2d/luaoc")
			ok, appVersion = luaBridge.callStaticMethod("AppController", "getVersionName")
		elseif gt.isAndroidPlatform() then
			luaBridge = require("cocos/cocos2d/luaj")
			ok, appVersion = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")
		end

		local data = string.split(appVersion, ".")

		local versionNumber = 0

		if data[1] then
			versionNumber = versionNumber + tonumber(data[1])*10
		end

		if data[2] then
			versionNumber = versionNumber + tonumber(data[2])
		end

		return versionNumber
	end

	local gmeLogSetNode = gt.seekNodeByName(csbNode, "Node_GameLogSet")
	local AppVersion = getAppVersion()
	if AppVersion > 10 then
		gmeLogSetNode:setVisible(true)
	else
		gmeLogSetNode:setVisible(false)
	end

	if device.platform == "ios" then
		gmeLogSetNode:setVisible(false)
	end
	if gt.release then
		gmeLogSetNode:setVisible(false)
	end
	--上传测试信息
	local UpLoadButton = gt.seekNodeByName(csbNode, "Button_UpLoad")
	gt.addBtnPressedListener(UpLoadButton, function()
  		local GameLog = require("client/game/common/GameLog"):create()
  		self:addChild(GameLog)
	end)

	-- 切换帐号按钮
	local switchBtn = gt.seekNodeByName(csbNode, "Btn_switch")
	gt.addBtnPressedListener(switchBtn, function()
		-- 关闭socket连接时,赢停止当前定时器
		if gt.socketClient.scheduleHandler then
			gt.scheduler:unscheduleScriptEntry( gt.socketClient.scheduleHandler )
		end
		-- 清除活动数据
		gt.lotteryInfoTab = nil
		-- 关闭事件回调
		gt.removeTargetAllEventListener(gt.socketClient)
		-- 调用善后处理函数
		gt.socketClient:clearSocket()
		-- 关闭socket
		gt.socketClient:close()
		gt.log("关闭socket 666666")

		cc.UserDefault:getInstance():setStringForKey("WX_Access_Token", "")
		cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token", "")
		cc.UserDefault:getInstance():setStringForKey("WX_Access_Token_Time", "")
		cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token_Time", "")
		cc.UserDefault:getInstance():setStringForKey("WX_OpenId", "")
		cc.UserDefault:getInstance():setStringForKey("WX_UnionId", "")
		cc.UserDefault:getInstance():setStringForKey("WX_Uuid", "")

		cc.UserDefault:getInstance():setStringForKey("WX_Sex", "")
		cc.UserDefault:getInstance():setStringForKey("WX_Nickname", "")
		cc.UserDefault:getInstance():setStringForKey("WX_ImageUrl", "")
		cc.UserDefault:getInstance():setIntegerForKey("User_Id", 0)

		local loginScene = require("client/game/common/LoginScene"):create()
		cc.Director:getInstance():replaceScene(loginScene)
	end)

	if gt.isAppStoreInReview then
		gmeLogSetNode:setVisible(false)
		switchBtn:setVisible(false)
	end

	local restartBtn = gt.seekNodeByName(csbNode, "Btn_restart")
	-- restartBtn:setVisible(false)
	gt.addBtnPressedListener(restartBtn, function()
		if gt.socketClient.scheduleHandler then
			gt.scheduler:unscheduleScriptEntry( gt.socketClient.scheduleHandler )
		end
		-- 清除活动数据
		gt.lotteryInfoTab = nil
		-- 关闭事件回调
		gt.removeTargetAllEventListener(gt.socketClient)
		-- 调用善后处理函数
		gt.socketClient:clearSocket()
		-- 关闭socket
		gt.socketClient:close()
		gt.log("退出到了LogoScene里面了")


		for k, v in pairs(package.loaded) do
			if string.sub(k, 1, 7) == "client/" then
				package.loaded[k] = nil
			end 
		end


		local loginScene = require("client/game/common/LogoScene"):create()
		cc.Director:getInstance():replaceScene(loginScene)
	end)

	local quiteBtn = gt.seekNodeByName(csbNode, "Btn_quite")
	gt.addBtnPressedListener(quiteBtn, function()
		if gt.socketClient.scheduleHandler then
			gt.scheduler:unscheduleScriptEntry( gt.socketClient.scheduleHandler )
		end
		-- 清除活动数据
		gt.lotteryInfoTab = nil
		-- 关闭事件回调
		gt.removeTargetAllEventListener(gt.socketClient)
		-- 调用善后处理函数
		gt.socketClient:clearSocket()
		-- 关闭socket
		gt.socketClient:close()
		os.exit()
	end)

	local downloadnewversionBtn = gt.seekNodeByName(csbNode, "Btn_downloadnewversion")
	gt.addBtnPressedListener(downloadnewversionBtn, function()
		self:setUpgradeDetect(function ( data )
			local function callbackdownload( )
				local url = data.download_url

				if gt.isIOSPlatform() then
					self.luaBridge = require("cocos/cocos2d/luaoc")
				elseif gt.isAndroidPlatform() then
					self.luaBridge = require("cocos/cocos2d/luaj")
				end
				if gt.isIOSPlatform() then
					local ok = self.luaBridge.callStaticMethod("AppController", "openWebURL", {webURL = url})
				elseif gt.isAndroidPlatform() then
					local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "openWebURL", {url}, "(Ljava/lang/String;)V")
				end
			end
			
			if data.is_upgrade == 0 then
				local NoticeTipsShareDownloadNew = require("client/game/dialog/NoticeTipsShareDownloadNew"):create("您已经安装了最新版，确定重新下载吗？", callbackdownload)
				self:addChild(NoticeTipsShareDownloadNew)
			elseif data.is_upgrade == 1 then
				callbackdownload()
			end
		end)
	end)

	-- 音效调节
	local soundEftSlider = gt.seekNodeByName(csbNode, "Slider_soundEffect")
	local soundEftPercent = gt.soundEngine:getMusicVolume()
	soundEftPercent = math.floor(soundEftPercent)
	soundEftSlider:setPercent(soundEftPercent)
	soundEftSlider:addEventListener(function(sender, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local soundEftPercent = soundEftSlider:getPercent()
			gt.soundEngine:setMusicVolume(soundEftPercent)
		end
		-- self:smVisSet()
	end)

	-- 音乐调节
	local musicSlider = gt.seekNodeByName(csbNode, "Slider_music")
	local musicPercent = gt.soundEngine:getSoundEffectVolume()
	musicPercent = math.floor(musicPercent)
	musicSlider:setPercent(musicPercent)
	musicSlider:addEventListener(function(sender, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local musicPercent = musicSlider:getPercent()
			gt.soundEngine:setSoundEffectVolume(musicPercent)
		end
		-- self:smVisSet()
	end)

	-- gt.addBtnPressedListener(self.soundMinBtn, function()
	-- 	local soundEftSlider = gt.seekNodeByName(self.rootNode, "Slider_soundEffect")
	-- 	soundEftSlider:setPercent(100)
	-- 	gt.soundEngine:setSoundEffectVolume(100)
	-- 	self.soundMinBtn:setVisible(false)
 --        self.soundMaxBtn:setVisible(true)
       
	-- end)
	-- -- 音效max
	-- --local soundMaxBtn = gt.seekNodeByName(csbNode, "Btn_maxSound")
	-- gt.addBtnPressedListener(self.soundMaxBtn, function()
	-- 	local soundEftSlider = gt.seekNodeByName(self.rootNode, "Slider_soundEffect")
	-- 	soundEftSlider:setPercent(0)
	-- 	gt.soundEngine:setSoundEffectVolume(0)
	-- 	self.soundMinBtn:setVisible(true)
 --        self.soundMaxBtn:setVisible(false)
	-- end)
	
	-- gt.addBtnPressedListener(self.musicMinBtn, function()
	-- 	local soundEftSlider = gt.seekNodeByName(self.rootNode, "Slider_music")
	-- 	musicSlider:setPercent(100)
	-- 	gt.soundEngine:setMusicVolume(100)
	-- 	self.musicMinBtn:setVisible(false)
 --        self.musicMaxBtn:setVisible(true)

	-- end)
	-- -- 音乐max
	-- --local musicMaxBtn = gt.seekNodeByName(csbNode, "Btn_maxMusic")
	-- gt.addBtnPressedListener(self.musicMaxBtn, function()
	-- 	local soundEftSlider = gt.seekNodeByName(self.rootNode, "Slider_music")
	-- 	musicSlider:setPercent(0)
	-- 	gt.soundEngine:setMusicVolume(0)
	-- 	self.musicMinBtn:setVisible(true)
 --        self.musicMaxBtn:setVisible(false)
	-- end)
 --    self:smVisSet()
end

function SettingMain:smVisSet()
	-- local soundEftPercent = gt.soundEngine:getSoundEffectVolume()
 --    local musicEftPercent = gt.soundEngine:getMusicVolume()
    
 --    if soundEftPercent==0 then
 --    	self.soundMinBtn:setVisible(true)
 --    	self.soundMaxBtn:setVisible(false)
 --    else
 --    	self.soundMaxBtn:setVisible(true)
 --    end

 --    if musicEftPercent==0 then
 --    	self.musicMinBtn:setVisible(true)
 --    	self.musicMaxBtn:setVisible(false)
 --    else
 --    	self.musicMaxBtn:setVisible(true)
 --    end
end

function SettingMain:clearLoadedFiles()
	for k, v in pairs(package.loaded) do
		if string.sub(k, 1, 7) == "client/" then
			package.loaded[k] = nil
		end 
	end
	cc.SpriteFrameCache:getInstance():removeSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeAllTextures()
end

function SettingMain:setUpgradeDetect(_callback)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local UpgradeDetect = gt.getUrlEncryCode(gt.upgradeDetect, gt.playerData.uid)
	print("------------UpgradeDetect", UpgradeDetect)

	xhr:open("GET", UpgradeDetect)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local response = xhr.response
            local respJson = require("cjson").decode(response)
            gt.dump(respJson)
            if respJson.errno == 0 then
				_callback(respJson.data)
            else
                Toast.showToast(self, respJson.errmsg, 2)
            end
		elseif xhr.readyState == 1 and xhr.status == 0 then
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function SettingMain:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
	end
end

function SettingMain:onTouchBegan(touch, event)
	return true
end

function SettingMain:onTouchEnded(touch, event)
	local bg = gt.seekNodeByName(self.rootNode, "Img_bg")
	if bg then
		local point = bg:convertToNodeSpace(touch:getLocation())
		local rect = cc.rect(0, 0, bg:getContentSize().width, bg:getContentSize().height)
		if not cc.rectContainsPoint(rect, cc.p(point.x, point.y)) then
			self:removeFromParent()
		end
	end
end

return SettingMain



