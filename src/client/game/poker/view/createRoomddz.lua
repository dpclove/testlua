
local createRoomddz = class("createRoomddz", function()
	return gt.createMaskLayer()
end)


function createRoomddz:ctor()


	self.csbNode = cc.CSLoader:createNode("createRoomDdz.csb")
	self.csbNode:setAnchorPoint(0.5,0.5)
	self.csbNode:setPosition(gt.winCenter)
	self:addChild(self.csbNode)

	gt.socketClient:registerMsgListener(gt.GC_CREATE_ROOM, self, self.onRcvCreateRoom)

	self.play_type = cc.UserDefault:getInstance():getIntegerForKey("ddz_play_type", 1)

	self.text = self.csbNode:getChildByName("create_ddz_text")
	self.text1 = self.csbNode:getChildByName("create_ddz_text_0")
	self.text2 = self.csbNode:getChildByName("create_ddz_text1")
	self.text3 = self.csbNode:getChildByName("create_ddz_text2")
	gt.setOnViewClickedListener(self.csbNode:getChildByName("Image_2"),function()
			self:hideTips()
		end)


	for i =1 , 3 do 
		self["jiushu"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_jiushu"..i, 1)
		self["dipai"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_dipai"..i, 1)
		self["fengding"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_fengding"..i, 1)
		self["difen"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_difen"..i, 1)
		self["xuanze"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_xuanze"..i, 0)
		self["xuanze1"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_xuanze1"..i, 0)
		self["xuanze2"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_xuanze2"..i, 1) -- 默认轮流
		self["xuanze3"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_xuanze3"..i, 1) -- 默认轮流
		self["xuanze4"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_xuanze4"..i, 0) -- 默认不选中

		local jiushu = self.csbNode:getChildByName("Node_"..i):getChildByName("t_jushu")
		for j =1 , 3 do
			
			local node = jiushu:getChildByTag(j)
			node:setSelected(self["jiushu"..i] == j)
			gt.setOnViewClickedListener(node, function()
				for x = 1 , 3 do
					if x == j then 
					self["jiushu"..i] = j 
						self.csbNode:getChildByName("Node_"..i):getChildByName("t_jushu"):getChildByTag(x):setSelected(true)
					else
						self.csbNode:getChildByName("Node_"..i):getChildByName("t_jushu"):getChildByTag(x):setSelected(false)
					end
				end
					gt.log("jiushu...",self["jiushu"..i],i)
			end)
		end 


		local dipai = self.csbNode:getChildByName("Node_"..i):getChildByName("t_dipai")
		for j =1 , 2 do
			local node = dipai:getChildByTag(j)
			node:setSelected(self["dipai"..i] == j)

			gt.setOnViewClickedListener(node, function()
				for x = 1 , 2 do
					if x == j then 
					self["dipai"..i] = j 
						self.csbNode:getChildByName("Node_"..i):getChildByName("t_dipai"):getChildByTag(x):setSelected(true)
					else
						self.csbNode:getChildByName("Node_"..i):getChildByName("t_dipai"):getChildByTag(x):setSelected(false)
					end
				end
				gt.log("dipai...",self["dipai"..i],j)
			end)

		end 
		dipai:setVisible(i~=3)

		local fengding = self.csbNode:getChildByName("Node_"..i):getChildByName("t_fending")
		for j =1 , 4 do
			local node = fengding:getChildByTag(j)
			node:setSelected(self["fengding"..i] == j)
			gt.setOnViewClickedListener(node, function()
				for x = 1 , 4 do
					if x == j then 
					self["fengding"..i] = j 
						self.csbNode:getChildByName("Node_"..i):getChildByName("t_fending"):getChildByTag(x):setSelected(true)
					else
						self.csbNode:getChildByName("Node_"..i):getChildByName("t_fending"):getChildByTag(x):setSelected(false)
					end
				end
				gt.log("fengding...",self["fengding"..i],j)
			end)
		end 


		local di = self.csbNode:getChildByName("Node_"..i):getChildByName("t_di")
		for j =1 , 5 do
			local node = di:getChildByTag(j)
			node:setSelected(self["difen"..i] == j)

			gt.setOnViewClickedListener(node, function()
				for x = 1 , 5 do
					if x == j then 
					self["difen"..i] = j 
						self.csbNode:getChildByName("Node_"..i):getChildByName("t_di"):getChildByTag(x):setSelected(true)
					else
						self.csbNode:getChildByName("Node_"..i):getChildByName("t_di"):getChildByTag(x):setSelected(false)
					end
				end
				gt.log("difen...",self["difen"..i],j)
			end)
		end 


		local xuanze = self.csbNode:getChildByName("Node_"..i):getChildByName("t_xuanze")

		gt.setOnViewClickedListener(gt.seekNodeByName(xuanze, "Image"),function()
				self:hideTips()
				if 3 == i then 
					self.text1:setVisible(true)
					-- text:setVisible(false)
				else
					self.text:setVisible(true)
					-- text1:setVisible(false)
				end
			end)

		gt.setOnViewClickedListener(gt.seekNodeByName(xuanze, "Image_0"),function()
				self:hideTips()
				self.text2:setVisible(true)
			end)
		gt.setOnViewClickedListener(gt.seekNodeByName(xuanze, "Image_0_0"),function()
				gt.log("show......Image_0_0")
				self:hideTips()
				self.text3:setVisible(true)
			end)

		for j =1 , 1 do
			local node = xuanze:getChildByTag(j)
			node:setSelected(self["xuanze"..i] == j)
			gt.setOnViewClickedListener(node, function()
				
				self["xuanze"..i] = 1 - self["xuanze"..i] 
				self.csbNode:getChildByName("Node_"..i):getChildByName("t_xuanze"):getChildByTag(1):setSelected(self["xuanze"..i] == 1)
						gt.log("a...",self["xuanze"..i])
			end)

		end 
		for j =2 , 2 do
			local node = xuanze:getChildByTag(j)
			node:setSelected(self["xuanze1"..i] == j-1)
			gt.setOnViewClickedListener(node, function()
				
				self["xuanze1"..i] = 1 - self["xuanze1"..i] 
				self.csbNode:getChildByName("Node_"..i):getChildByName("t_xuanze"):getChildByTag(2):setSelected(self["xuanze1"..i] == 1)

				gt.log("b...",self["xuanze1"..i])
						
			end)
		end 

		for j =3 , 3 do
			local node = xuanze:getChildByTag(j)
			node:setSelected(self["xuanze2"..i] == j-2)
			gt.setOnViewClickedListener(node, function()
				
				self["xuanze2"..i] = 1 - self["xuanze2"..i] 
				self.csbNode:getChildByName("Node_"..i):getChildByName("t_xuanze"):getChildByTag(j):setSelected(self["xuanze2"..i] == 1)

				gt.log("c...",self["xuanze2"..i])
						
			end)
		end 

		
		for j = 4 , 4 do
			local node = xuanze:getChildByTag(j)
			gt.log("node",node,i,self["xuanze3"..i])
		    node:setSelected(self["xuanze3"..i] == j-3)
			gt.setOnViewClickedListener(node, function()
				
				self["xuanze3"..i] = 1 - self["xuanze3"..i] 
				self.csbNode:getChildByName("Node_"..i):getChildByName("t_xuanze"):getChildByTag(j):setSelected(self["xuanze3"..i] == 1)

				gt.log("d...",self["xuanze3"..i])

			end)
		end
		--两红三/黑三炸弹
		if i == 2 then
			for j = 5 , 5 do
				local node = xuanze:getChildByTag(j)
				gt.log("j=====",j)
				gt.log("i=====",i)
				-- node:setVisible(false)
				gt.log("node",node,i,self["xuanze4"..i])
			    node:setSelected(self["xuanze4"..i] == j-4)
				gt.setOnViewClickedListener(node, function()
					self["xuanze4"..i] = 1 - self["xuanze4"..i] 
					self.csbNode:getChildByName("Node_"..i):getChildByName("t_xuanze"):getChildByTag(j):setSelected(self["xuanze4"..i] == 1)
					gt.log("e...",self["xuanze4"..i])
				end)
			end
		end
	end


		-- 返回按键
	local backBtn = gt.seekNodeByName(self.csbNode, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
		self:removeFromParent()
		if self.createSchedule then
		 			gt.scheduler:unscheduleScriptEntry(self.createSchedule)
		 			self.createSchedule = nil
		 		end
	end)



	for i =1 , 3 do
		local btn = self.csbNode:getChildByTag(i)
		local node = self.csbNode:getChildByName("Node_"..i)
		btn:setTouchEnabled(i~=self.play_type)
		btn:setBright(i~=self.play_type)
		node:setVisible(self.play_type == i)
		gt.addBtnPressedListener(btn,function()
			self:hideTips( )
			-- text1:setVisible(false)
			-- text:setVisible(false)
			for j = 1, 3 do
				self.play_type = i
				self.csbNode:getChildByTag(j):setTouchEnabled(i~=j)
				self.csbNode:getChildByTag(j):setBright(i~=j)
				self.csbNode:getChildByName("Node_"..j):setVisible(i==j)
			end
		end)

	end



	gt.addBtnPressedListener(gt.seekNodeByName(self.csbNode, "m_btnClose"),function()

		self:removeFromParent()

		end)

		gt.addBtnPressedListener(gt.seekNodeByName(self.csbNode, "Btn_create"),function()

		self:sendCreateRoom()

		end)
	self:registerScriptHandler(handler(self, self.onNodeEvent))

end

function createRoomddz:hideTips( )
	self.text:setVisible(false)
	self.text1:setVisible(false)
	self.text2:setVisible(false)
	self.text3:setVisible(false)
end

function createRoomddz:onNodeEvent(eventName)
	gt.log("enter_______",eventName)
	if "enter" == eventName then
		
	elseif "exit" == eventName or "cleanup" == eventName then 

		gt.dispatchEvent("show_text")
		gt.socketClient:unregisterMsgListener(gt.GC_CREATE_ROOM)
	end
end




function createRoomddz:sendCreateRoom()
	
			local kGpsLng = "0"
			local kGpsLat = "0"

			
			
			
			local msgToSend = {}
			msgToSend.kGpsLimit = self["xuanze"..self.play_type]
			msgToSend.kMId = gt.CG_CREATE_ROOM

			if self["xuanze"..self.play_type] == 1 then 
				--gt.showLoadingTips(gt.getLocationString("LTKey_0059"))
				local data = ""
				local time = 0
				if self._time then 	gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
				self._time = gt.scheduler:scheduleScriptFunc(function(dt)

					data = Utils.getLocationInfo()

					if (data.longitude and data.latitue and data.longitude ~= "" and data.latitue ~= "" and gt.isAndroidPlatform()) or (data.longitude and data.longitude ~= 0 and data.latitue and data.latitue ~= 0 and gt.isIOSPlatform()) then
						gt.removeLoadingTips()
						if self._time then gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
						kGpsLng = data.longitude
						kGpsLat = data.latitue

						msgToSend.kPlayType = {}
						msgToSend.kFlag = self["jiushu"..self.play_type] --== 1 and 8 or 16 -- (8 or 16) -- 局数 1 代表 8  2 代表 16
						msgToSend.kState =   101        --   炸金花  102，斗地主  101，牛牛    103，
						msgToSend.kFeeType =  1     --（费用类型 ，0:房主付费 1:玩家分摊）
						msgToSend.kDeskType = 0
						msgToSend.kGpsLng = tostring(kGpsLng)
						msgToSend.kGpsLat = tostring(kGpsLat)
						msgToSend.kGreater2CanStart = 0       

						msgToSend.kPlayType[1] = self.play_type -- 1 or 2 o 3 
						msgToSend.kPlayType[2] = self.play_type == 3 and 2 or self["dipai"..self.play_type] -- 1 or 2 
						msgToSend.kPlayType[3] = self:getbobmnum() -- 3 or 4 or 5 or 0 
						msgToSend.kPlayType[4] = self["difen"..self.play_type] -- 1 or 2 or 3 or 4 or 5
						msgToSend.kPlayType[5] = self["xuanze1"..self.play_type] -- 0 or 1
						msgToSend.kPlayType[6] = 0
						msgToSend.kPlayType[7] = self["xuanze2"..self.play_type] -- 0 or 1
						msgToSend.kPlayType[8] = self.play_type == 3 and  1 or self["xuanze3"..self.play_type] -- 0 or 1
						if self.play_type == 2 then
							msgToSend.kPlayType[9] = self["xuanze4"..self.play_type]
						else
							msgToSend.kPlayType[9] = 0
						end
						if self.play_type == 3 then 
							msgToSend.kPlayType[10] = self["xuanze3"..self.play_type]
						else
							msgToSend.kPlayType[10] = 0
						end
						msgToSend.kPlayType[11] = 0
						msgToSend.kPlayType[12] = 0
						msgToSend.kPlayType[13] = 0
						msgToSend.kPlayType[14] = 0
						msgToSend.kPlayType[15] = 0

						
						gt.log("创建房间________",self.wanfa)
						gt.dump(msgToSend)
						gt.socketClient:sendMessage(msgToSend)

						gt.showLoadingTips("房间创建中...")

					local chutaiAnimateResult = function(delta)
						--print("---------------current time:", self.createTime)
						if self.createTime == nil or self.createTime >= 30 then
							gt.removeLoadingTips()
							if self.createSchedule then
					 			gt.scheduler:unscheduleScriptEntry(self.createSchedule)
					 			self.createSchedule = nil
					 		end
						end
						if self.createTime ~= nil then
							self.createTime = self.createTime + 1
						end
				 	end
				 	self.createTime = 1
					self.createSchedule = gt.scheduler:scheduleScriptFunc(chutaiAnimateResult, 1, false)


					end
					time = time + dt
					if time > 2 then 
						if self._time then 	gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
						gt.removeLoadingTips()
						local str_des = "获取GPS失败，您创建的是【相邻位置禁止进入】的房间，必须开启GPS位置才能进入!"
						require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
						str_des, nil, nil, true)
						
					end
				end,0,false)
			end

	
			if self["xuanze"..self.play_type] == 0 then 	
				msgToSend.kPlayType = {}
				msgToSend.kFlag = self["jiushu"..self.play_type] --== 1 and 1 or 16 -- (8 or 16) -- 局数 1 代表 8  2 代表 16
				msgToSend.kState =   101        --   炸金花  102，斗地主  101，牛牛    103，
				msgToSend.kFeeType =  1     --（费用类型 ，0:房主付费 1:玩家分摊）
				msgToSend.kDeskType = 0
				msgToSend.kGpsLng = tostring(kGpsLng)
				msgToSend.kGpsLat = tostring(kGpsLat)
				msgToSend.kGreater2CanStart = 0

				msgToSend.kPlayType[1] = self.play_type
				msgToSend.kPlayType[2] = self.play_type == 3 and 2 or self["dipai"..self.play_type]
				msgToSend.kPlayType[3] = self:getbobmnum()
				msgToSend.kPlayType[4] = self["difen"..self.play_type]
				msgToSend.kPlayType[5] = self["xuanze1"..self.play_type]
				msgToSend.kPlayType[6] = 0
				msgToSend.kPlayType[7] = self["xuanze2"..self.play_type] -- 0 or 1
				msgToSend.kPlayType[8] = self.play_type == 3 and  1 or self["xuanze3"..self.play_type] -- 0 or 1
				if self.play_type == 2 then
					msgToSend.kPlayType[9] = self["xuanze4"..self.play_type]
				else
					msgToSend.kPlayType[9] = 0
				end
				if self.play_type == 3 then 
					msgToSend.kPlayType[10] = self["xuanze3"..self.play_type]
				else
					msgToSend.kPlayType[10] = 0
				end
				msgToSend.kPlayType[11] = 0
				msgToSend.kPlayType[12] = 0
				msgToSend.kPlayType[13] = 0
				msgToSend.kPlayType[14] = 0
				msgToSend.kPlayType[15] = 0
				

				gt.log("创建房间________",self.wanfa)
				gt.dump(msgToSend)
				gt.socketClient:sendMessage(msgToSend)

				gt.showLoadingTips("房间创建中...")

				local chutaiAnimateResult = function(delta)
				--	print("---------------current time:", self.createTime)
					if self.createTime == nil or self.createTime >= 30 then
						gt.removeLoadingTips()
						if self.createSchedule then
				 			gt.scheduler:unscheduleScriptEntry(self.createSchedule)
				 			self.createSchedule = nil
				 		end
					end
					if self.createTime ~= nil then
						self.createTime = self.createTime + 1
					end
			 	end
			 	self.createTime = 1
				self.createSchedule = gt.scheduler:scheduleScriptFunc(chutaiAnimateResult, 1, false)

			end
		
		self:_close()
end


function createRoomddz:getbobmnum()

	return self["fengding"..self.play_type] == 4  and  0 or  self["fengding"..self.play_type] + 2

end

function createRoomddz:onRcvCreateRoom(msgTbl)
	gt.log("创建房间消息 ============== ")

	
	gt.dump(msgTbl)
	gt.dumploglogin("创建房间消息")
	if self.createSchedule then
		gt.scheduler:unscheduleScriptEntry(self.createSchedule)
		self.createSchedule = nil
	end
	
	if msgTbl.kErrorCode ~= 0 then
		-- 创建失败
		gt.removeLoadingTips()

		-- 房卡不足提示
		-- require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
			-- gt.getLocationString("LTKey_0046", gt.roomCardBuyInfo), nil, nil, true)
		gt.log("房卡不足")
		if msgTbl.kErrorCode == 1 then
			Toast.showToast(self, "房卡不足，请在商城购买", 2)
			if gt.isShoppingShow then
				--local shoppingPopup = require("app/views/ShoppingLayer"):create()
				--self:addChild(shoppingPopup, self.ZOrder)
			else
				--require("client/game/dialog/NoticeTipsForFangKa"):create("房卡不足", gt.roomCardBuyInfo, nil, nil, true)
				require("client/game/dialog/NoticeTipsCommon"):create(2, "房卡不足，请在商城购买")
			end
		elseif msgTbl.kErrorCode == 8 then
			Toast.showToast(self, "房主建房数量超限，解散后重试", 2)
		elseif msgTbl.kErrorCode == 9 then
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "获取GPS信息失败！", nil, nil, true)
		else
			require("client/game/dialog/NoticeTipsCommon"):create(2, "创建房间失败")
		end
	else
		if self.deskType then
			-- --房主建房
			-- gt.removeLoadingTips()
			-- self.parent:sendFZRecordMsg()
			-- self:removeFromParent()
		else
			gt.CreateRoomFlag = true
		end
	end
end

function createRoomddz:_close()


	gt.log("close______________")

	for i =1 , 3 do 
		cc.UserDefault:getInstance():setIntegerForKey("ddz_jiushu"..i, self["jiushu"..i])
		cc.UserDefault:getInstance():setIntegerForKey("ddz_dipai"..i, self["dipai"..i])
		cc.UserDefault:getInstance():setIntegerForKey("ddz_fengding"..i, self["fengding"..i])
		cc.UserDefault:getInstance():setIntegerForKey("ddz_difen"..i, self["difen"..i])
		cc.UserDefault:getInstance():setIntegerForKey("ddz_xuanze"..i, self["xuanze"..i])
		cc.UserDefault:getInstance():setIntegerForKey("ddz_xuanze1"..i, self["xuanze1"..i])
		cc.UserDefault:getInstance():setIntegerForKey("ddz_xuanze2"..i, self["xuanze2"..i])
		cc.UserDefault:getInstance():setIntegerForKey("ddz_xuanze3"..i, self["xuanze3"..i])
		cc.UserDefault:getInstance():setIntegerForKey("ddz_xuanze4"..i, self["xuanze4"..i])
	end

	cc.UserDefault:getInstance():setIntegerForKey("ddz_play_type", self.play_type)
	--gt.socketClient:unregisterMsgListener(gt.GC_CREATE_ROOM)
end


return createRoomddz