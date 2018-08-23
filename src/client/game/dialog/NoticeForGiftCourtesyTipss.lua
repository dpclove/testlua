
local gt = cc.exports.gt

local NoticeForGiftCourtesyTipss = class("NoticeForGiftCourtesyTipss", function()
	return gt.createMaskLayer()
end)

function NoticeForGiftCourtesyTipss:ctor(num)
	--self.giftCourtesyType = num
	self:setName("NoticeForGiftCourtesyTipss")

	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("NoticeForGiftCourtesyTips1.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	
	self.rootNode = csbNode

	-- local okBtn = gt.seekNodeByName(csbNode, "Btn_ok")
	-- gt.addBtnPressedListener(okBtn, function()
 --        if not self.iamge then 
   
 --        	self:adImage1()
 --        else
 --        	-- self:shareImageToWX(self.iamge,function(code)

 --        	-- 		if code == 0 then 
 --        	-- 			self:removeFromParent()
 --        	-- 			gt.dispatchEvent("f5")
 --        	-- 			if type(self.giftCourtesyType) == "number" then 
 --        	-- 				cc.UserDefault:getInstance():setIntegerForKey("Activity_type",self.giftCourtesyType)
 --        	-- 			end
 --        	-- 		end
 --        	-- 	end)
 --        	Utils.shareImageToWX(self.iamge)
 --        end

  	 	
	-- end)

	self:screenshotShareToWX()
	-- self:adImage()

	-- local runningScene = cc.Director:getInstance():getRunningScene()
	-- if runningScene then
	-- 	runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS)
	-- end
end

local writePath = cc.FileUtils:getInstance():getWritablePath()
local resSearchPaths = {
	writePath,
	writePath .. "src_hyl/",
	writePath .. "src/",
	writePath .. "res/",
	writePath .. "res/",
	"src_hyl/",
	"src/",
	"res/",
	"res/"
}
cc.FileUtils:getInstance():setSearchPaths(resSearchPaths)

function NoticeForGiftCourtesyTipss:shareImageToWX(shareImgFilePath, call)
	local androidParam = "(Ljava/lang/String;III)V"
	if gt.isIOSPlatform() then
		local luaoc = require("cocos/cocos2d/luaoc")
		luaoc.callStaticMethod("AppController", "shareImageToWX", { imgFilePath = shareImgFilePath, scriptHandler = function(authCode)
				if (gt.isIOSPlatform() and authCode == 0) or (gt.isAndroidPlatform() and authCode == "success") then
					if call then
						call(0)
					end
				else
					if call then
						call(1)
					end
				end


			end})
	elseif gt.isAndroidPlatform() then
		local luaj = require("cocos/cocos2d/luaj")
		luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerGetAuthCodeHandler", { function(authCode)
			if (gt.isIOSPlatform() and authCode == 0) or (gt.isAndroidPlatform() and authCode == "success") then
				if call then
					call(0)
				end
			else
				if call then
					call(1)
				end
			end
		end }, "(I)V")	
		luaj.callStaticMethod( "org/cocos2dx/lua/AppActivity", "shareImageToWX", { shareImgFilePath, width, height, size }, androidParam )
	end	
end


function NoticeForGiftCourtesyTipss:adImage()
	
	local url = "http://static.player.haoyunlaiyule1.com/img/wx_wanjiafuli.jpg"

	if gt.imageNamePath(url) then
		
		self.iamge = gt.imageNamePath(url)

	else
		local call = function(args)
	    	local runningScene = display.getRunningScene()
			if runningScene and runningScene.name == "MainScene" then
	    		if args.done then
	    			self.iamge = args.iamge
	    		end
	    	end
    	end
    	gt.downloadImage(url,call)
	end

end

function NoticeForGiftCourtesyTipss:adImage1()

	local url = "http://static.player.haoyunlaiyule1.com/img/wx_wanjiafuli.jpg"

	if gt.imageNamePath(url) then
	
		-- self:shareImageToWX(gt.imageNamePath(url),function(code)

	 --        			if code == 0 then 
	 --        				self:removeFromParent()
	 --        				gt.dispatchEvent("f5")
	 --        				if type(self.giftCourtesyType) == "number" then 
	 --        					cc.UserDefault:getInstance():setIntegerForKey("Activity_type",self.giftCourtesyType)
	 --        				end
	 --        			end
	 --        		end)
	 Utils.shareImageToWX(gt.imageNamePath(url))

	else
		local call = function(args)
	    	local runningScene = display.getRunningScene()
	    		
			if runningScene and runningScene.name == "MainScene" then
		    	if args.done then
		    			
		    			-- self:shareImageToWX(self.iamge,function(code)

	        -- 			if code == 0 then 
	        -- 				self:removeFromParent()
	        -- 				gt.dispatchEvent("f5")
	        -- 				if type(self.giftCourtesyType) == "number" then 
	        -- 					cc.UserDefault:getInstance():setIntegerForKey("Activity_type",self.giftCourtesyType)
	        -- 				end
	        -- 			end
	        		--end)
	        		Utils.shareImageToWX(args.iamge)
	    		end
	    	end
    	end
    	gt.downloadImage(url,call)
	end

end



function NoticeForGiftCourtesyTipss:screenshotShareToWX()
	 local screenshotFileName = "wx.jpg"
	-- self.shareImgFilePath = cc.FileUtils:getInstance():getWritablePath() .. screenshotFileName
	
	-- if self.shareImgFilePath and cc.FileUtils:getInstance():isFileExist(self.shareImgFilePath) then
	-- 	-- local shareBtn = gt.seekNodeByName(self.rootNode, "Btn_ok")
	-- 	-- shareBtn:setEnabled(true)
	-- 	local shareImgFilePath = self.shareImgFilePath
	-- 	Utils.shareImageToWX( shareImgFilePath, 849, 450, 32 )
	-- 	self.shareImgFilePath = nil
	-- 	print("aaaa")
	-- else
		local screenshot = cc.RenderTexture:create(gt.winSize.width, gt.winSize.height)
		--local screenshot = cc.RenderTexture:create(258, 258)
		--screenshot:setVirtualViewport(gt.winCenter,cc.rect(0,0,1280,720),cc.rect(0,0,258,258))
		screenshot:begin()
		self.rootNode:visit()
		screenshot:endToLua()

		screenshot:saveToFile(screenshotFileName, cc.IMAGE_FORMAT_JPEG, false)
		self.shareImgFilePath = cc.FileUtils:getInstance():getWritablePath() .. screenshotFileName
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
		print("bbbbb")
	--end
end

function NoticeForGiftCourtesyTipss:update()
	if self.shareImgFilePath and cc.FileUtils:getInstance():isFileExist(self.shareImgFilePath) then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		-- local shareBtn = gt.seekNodeByName(self.rootNode, "Btn_ok")
		-- shareBtn:setEnabled(true)

		local shareImgFilePath = self.shareImgFilePath
		Utils.shareImageToWX( shareImgFilePath, 849, 450, 32 )
		self.shareImgFilePath = nil
	end
end


function NoticeForGiftCourtesyTipss:onBack()
	self:removeFromParent()
end

function NoticeForGiftCourtesyTipss:onNodeEvent(eventName)
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

function NoticeForGiftCourtesyTipss:onTouchBegan(touch, event)
	return true
end

function NoticeForGiftCourtesyTipss:onTouchEnded(touch, event)
	self:removeFromParent()
end

return NoticeForGiftCourtesyTipss

