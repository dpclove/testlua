local UpdateApk = class("UpdateApk", function()
	return gt.createMaskLayer()
end)

function UpdateApk:ctor(url)


	local csbNode = cc.CSLoader:createNode("UpdateApk.csb")  -- csb有问题使用时候注意
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)


	self.node1 = gt.seekNodeByName(csbNode, "Node_1")
	self.node1:setVisible(false)
	self.node2 = gt.seekNodeByName(csbNode, "Node_2")
	self.node2:setVisible(true)



	--if gt.isIOSPlatform() then


	if gt.isAndroidPlatform() then

		local t = gt.seekNodeByName(csbNode, "Text_1")

		   		gt.setOnViewClickedListeners(gt.seekNodeByName(csbNode, "Button_5"), function()

		   			if t then 
		   				t:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.9),cc.ScaleTo:create(0.1,1)))
		   			end

		   			local ok = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "openWebURL", {url}, "(Ljava/lang/String;)V")

		   		end)
	else

		gt.seekNodeByName(self.node2, "Btn_sure"):setPositionX(381)
		local t = gt.seekNodeByName(csbNode, "Text_1")
		t:setVisible(false)
		gt.seekNodeByName(csbNode, "Button_5"):setVisible(false)

	end

	gt.setOnViewClickedListeners(gt.seekNodeByName(self.node2, "Btn_sure"),function()

		if gt.isIOSPlatform() then
			
			local ok = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "openWebURL", {webURL = url})
		elseif gt.isAndroidPlatform() then
			self.node2:setVisible(false)
			self:down(url)

			 	

		end
		
	end)

end


function UpdateApk:down(url)

	local ok = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "removeApk", {"zypk"}, "(Ljava/lang/String;)Z")
	self.node1:setVisible(true)
	self.node2:setVisible(false)

	gt.downloadApk(url,"zypk")


   	local node  =  gt.seekNodeByName(self.node1, "Slider_update")
   	node:setPercent(0)

   	local Text = gt.seekNodeByName(self.node1, "Text_7")

   	-- local t = gt.seekNodeByName(self.node1, "Text_1")

   	-- gt.setOnViewClickedListeners(gt.seekNodeByName(self.node1, "Button_5"), function()

   	-- 		if t then 
   	-- 			t:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.9),cc.ScaleTo:create(0.1,1)))
   	-- 		end

   	-- 		local ok = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "openWebURL", {url}, "(Ljava/lang/String;)V")

   	-- 	end)

	local _scheduler = gt.scheduler
	local bool = false
	self.__time = gt.scheduler:scheduleScriptFunc(function(dt)
	 local n1, n2, n3 = gt.getBytesAndStatus()


	 	if n1 ~= "err" then 

		 	local num = (tonumber(n1))/(tonumber(n2))*100

		 	
		 	num = math.ceil(num)
		 	


		 	Text:setString(num.."%")


		 	node:setPercent(num)
			if  bool then 
				gt.install_apk("zypk")
				if self.__time then  _scheduler:unscheduleScriptEntry(self.__time) self.__time = nil end
			end
			bool = tonumber(n1) == tonumber(n2)

		else
			Toast.showToast(self, "下载失败请扫码下载", 2)
			if self.__time then  _scheduler:unscheduleScriptEntry(self.__time) self.__time = nil end
		end


	end,1,false)

end


return UpdateApk