
local gt = cc.exports.gt

local ShareGift = class("ShareGift", function()
	return cc.Layer:create()
end)

function ShareGift:ctor()
	self.data = {}

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

    self:getshareInfo()
end

function ShareGift:getshareInfo()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local getshareInfoURL = gt.getUrlEncryCode(gt.shareInfo, gt.playerData.uid)
	gt.log("------------getshareInfoURL", getshareInfoURL)
	xhr:open("GET", getshareInfoURL)
	local function onResp()
		local runningScene = display.getRunningScene()
	   	if runningScene and runningScene.name == "MainScene" and runningScene:getChildByName("ShareGift") then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	            local response = xhr.response
	            local respJson = require("cjson").decode(response)
	            gt.dump(respJson)
	            if respJson.errno == 0 then
	            	self.data = respJson.data
	            	self:setShareInfo(self.data)
	            else
	                Toast.showToast(self, respJson.errmsg, 2)
	                self:removeFromParent()
	            end
			elseif xhr.readyState == 1 and xhr.status == 0 then
	    		self:removeFromParent()
			end
			xhr:unregisterScriptHandler()
		end
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function ShareGift:setShareInfo(data)
	data.share.desc = ""

	local function WXHYShareMoreNew( )
		self:getImageNewHY(data.share.type, data.share.url, data.share.image, data.share.width, data.share.height, data.share.title, data.share.desc)
	end

	local function WXPYQShareMoreNew( )
		self:getImageNewPYQ(data.share.type, data.share.url, data.share.image, data.share.width, data.share.height, data.share.title, data.share.desc)
	end

	local appVersion = gt.getAppVersion()
	local function callbackdownload( )
		self:upgradeSetCoin()
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

	local function callbackshareHY( )
		WXHYShareMoreNew()
	end

	local function callbacksharePYQ( )
		if gt.isIOSPlatform() then
			if appVersion > 19 then
				WXPYQShareMoreNew()
			end 
		elseif gt.isAndroidPlatform() then
			if appVersion > 19 then
				WXPYQShareMoreNew()
			end 
		end
	end

	if data.is_upgrade == 0 then
		local NoticeTipsShareDownload = require("client/game/dialog/NoticeTipsShareDownload"):create(0, data.upgrade_hint, nil,  callbackshareHY, callbacksharePYQ)
		self:addChild(NoticeTipsShareDownload)
	elseif data.is_upgrade == 1 then
		local NoticeTipsShareDownload = require("client/game/dialog/NoticeTipsShareDownload"):create(1, data.upgrade_hint, callbackdownload)
		self:addChild(NoticeTipsShareDownload)
	end

end

function ShareGift:upgradeSetCoin()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local upgradeSetCoinURL = gt.getUrlEncryCode(gt.upgradeSetCoin, gt.playerData.uid)
	gt.log("------------upgradeSetCoinURL", upgradeSetCoinURL)
	xhr:open("GET", upgradeSetCoinURL)
	local function onResp()
		local runningScene = display.getRunningScene()
	   	if runningScene and runningScene.name == "MainScene" and runningScene:getChildByName("ShareGift") then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
			xhr:unregisterScriptHandler()
		end
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function ShareGift:getImageNewHY(_type, url, image, width, height, title, description)
	if _type == 0 then
		Utils.shareURLToHY(url or "", title or "", description or "", function(authCode)
        self.scheduler = gt.scheduler:scheduleScriptFunc(function(delta)
            gt.scheduler:unscheduleScriptEntry(self.scheduler)
				local runningScene = cc.Director:getInstance():getRunningScene()
				if authCode == 0 then
	                Toast.showToast(runningScene, "分享到微信好友成功", 2)
				else
	                Toast.showToast(runningScene, "分享到微信好友失败", 2)
				end
	        end, 0.1, false)
		end)
	elseif _type == 1 then
		if gt.imageNamePath(image) then
			local icon = gt.imageNamePath(image)
			if icon and icon ~= "" then
				Utils.shareImageToWX(icon or "", width, height, 32)
			end
		else
			local call = function(args)
		    	local runningScene = display.getRunningScene()
				if runningScene and runningScene.name == "MainScene" then
		    		if args.done then
						local icon = args.image
						if icon and icon ~= "" then
							Utils.shareImageToWX(icon or "", width, height, 32)
						end
		    		end
		    	end
	    	end

	    	gt.downloadImage(image,call)
		end
	end
end

function ShareGift:getImageNewPYQ(_type, url, image, width, height, title, description)
	if _type == 0 then
		if gt.imageNamePath(image) then
			local icon = gt.imageNamePath(image)
			if icon and icon ~= "" then
				Utils.shareURLToWXPYQICON(url or "", icon or "", title or "", description or "", function(authCode)
		        self.scheduler = gt.scheduler:scheduleScriptFunc(function(delta)
		            gt.scheduler:unscheduleScriptEntry(self.scheduler)
						local runningScene = cc.Director:getInstance():getRunningScene()
						if authCode == 0 then
							if runningScene.receiveShareCoin then
								runningScene:receiveShareCoin()
							end
			                Toast.showToast(runningScene, "分享到朋友圈成功", 2)
							self:removeFromParent()
						else
			                Toast.showToast(runningScene, "分享到朋友圈失败", 2)
						end
			        end, 0.1, false)
				end)
			end
		else
			local call = function(args)
		    	local runningScene = display.getRunningScene()
				if runningScene and runningScene.name == "MainScene" then
		    		if args.done then
						local icon = args.image
						if icon and icon ~= "" then
							Utils.shareURLToWXPYQICON(url or "", icon or "", title or "", description or "", function(authCode)
					        self.scheduler = gt.scheduler:scheduleScriptFunc(function(delta)
					            gt.scheduler:unscheduleScriptEntry(self.scheduler)
									local runningScene = cc.Director:getInstance():getRunningScene()
									if authCode == 0 then
										if runningScene.receiveShareCoin then
											runningScene:receiveShareCoin()
										end
						                Toast.showToast(runningScene, "分享到朋友圈成功", 2)
										self:removeFromParent()
									else
						                Toast.showToast(runningScene, "分享到朋友圈失败", 2)
									end
						        end, 0.1, false)
							end)
						end
		    		end
		    	end
	    	end

	    	gt.downloadImage(image,call)
		end
	elseif _type == 1 then
		if gt.imageNamePath(image) then
			local icon = gt.imageNamePath(image)
			if icon and icon ~= "" then
				Utils.shareImageToWXPYQ(icon or "", width, height, function(authCode)
		        self.scheduler = gt.scheduler:scheduleScriptFunc(function(delta)
		            gt.scheduler:unscheduleScriptEntry(self.scheduler)
						local runningScene = cc.Director:getInstance():getRunningScene()
						if authCode == 0 then
							if runningScene.receiveShareCoin then
								runningScene:receiveShareCoin()
							end
			                Toast.showToast(runningScene, "分享到朋友圈成功", 2)
							self:removeFromParent()
						else
			                Toast.showToast(runningScene, "分享到朋友圈失败", 2)
						end
			        end, 0.1, false)
				end)
			end
		else
			local call = function(args)
		    	local runningScene = display.getRunningScene()
				if runningScene and runningScene.name == "MainScene" then
		    		if args.done then
						local icon = args.image
						if icon and icon ~= "" then
							Utils.shareImageToWXPYQ(icon or "", width, height, function(authCode)
					        self.scheduler = gt.scheduler:scheduleScriptFunc(function(delta)
					            gt.scheduler:unscheduleScriptEntry(self.scheduler)
									local runningScene = cc.Director:getInstance():getRunningScene()
									if authCode == 0 then
										if runningScene.receiveShareCoin then
											runningScene:receiveShareCoin()
										end
						                Toast.showToast(runningScene, "分享到朋友圈成功", 2)
										self:removeFromParent()
									else
						                Toast.showToast(runningScene, "分享到朋友圈失败", 2)
									end
						        end, 0.1, false)
							end)
						end
		    		end
		    	end
	    	end

	    	gt.downloadImage(image,call)
		end
	end
end

return ShareGift

