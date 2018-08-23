

local base = require("client.game.poker.baseView")

local createRoom = class("createRoom",base)

function createRoom:onRcvCreateRoom(msgTbl)
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

function createRoom:init(m)

	local close = self:findNodeByName("close")
	gt.setOnViewClickedListener(close,function()
		self:removeFromParent()
		end)

	gt.socketClient:registerMsgListener(gt.GC_CREATE_ROOM, self, self.onRcvCreateRoom)

	gt.setOnViewClickedListener(self:findNodeByName("determine"),function()
	self:sendCreateRoom()end)


	local play_num = 1
	self.play_type = 1
	self.play_num = play_num
	for i =1 , play_num do 
		self["jiushu"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_jiushu"..i, 1)
		
		self["zhu"..i] = cc.UserDefault:getInstance():getIntegerForKey("zhu"..i, 1)
		self["difen"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_difen"..i, 1)
		self["xuanze"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_xuanze"..i, 0)
		self["xuanze1"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_xuanze1"..i, 0)
		self["xuanze2"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_xuanze2"..i, 0)

		
		-- self["xuanze2"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_xuanze2"..i, 1) -- 默认轮流
		-- self["xuanze3"..i] = cc.UserDefault:getInstance():getIntegerForKey("ddz_xuanze3"..i, 1) -- 默认轮流



		local jiushu = self._node:getChildByName("checkBoxBg_"..i):getChildByName("TexT_1")
		for j =1 , 3 do
			
			local node = jiushu:getChildByTag(j)
			node:setSelected(self["jiushu"..i] == j)
			gt.setOnViewClickedListener(node, function()
				for x = 1 , 3 do
					if x == j then 
						self["jiushu"..i] = j 
						self._node:getChildByName("checkBoxBg_"..i):getChildByName("TexT_1"):getChildByTag(x):setSelected(true)
					else
						self._node:getChildByName("checkBoxBg_"..i):getChildByName("TexT_1"):getChildByTag(x):setSelected(false)
					end
				end
					gt.log("jiushu...",self["jiushu"..i],i)
			end)
		end 


		local difen = self._node:getChildByName("checkBoxBg_"..i):getChildByName("TexT_2")
		for j =1 , 3 do
			local node = difen:getChildByTag(j)
			node:setSelected(self["difen"..i] == j)

			gt.setOnViewClickedListener(node, function()
				for x = 1 , 3 do
					if x == j then 
						self["difen"..i] = j 
						difen:getChildByTag(x):setSelected(true)
					else
						difen:getChildByTag(x):setSelected(false)
					end
				end
				gt.log("difen...",self["difen"..i],j)
			end)
		end 

		local zhu = self._node:getChildByName("checkBoxBg_"..i):getChildByName("TexT_4")
		zhu:getChildByTag(2):getChildByName("Text"):setString(self["xuanze2"..i] == 1 and "从3开始" or "从2开始")
		for j =1 , 2 do
			
			local node = zhu:getChildByTag(j)
			node:setSelected(self["zhu"..i] == j)
			gt.setOnViewClickedListener(node, function()
				for x = 1 , 2 do
					if x == j then 
						self["zhu"..i] = j 
						zhu:getChildByTag(x):setSelected(true)
					else
						zhu:getChildByTag(x):setSelected(false)
					end
				end
					gt.log("zhu...",self["zhu"..i],i)
			end)
		end 


		local xuanze = self._node:getChildByName("checkBoxBg_"..i):getChildByName("TexT_3")
		for j =1 , 1 do
			local node = xuanze:getChildByTag(j)
			node:setSelected(self["xuanze"..i] == j)
			gt.setOnViewClickedListener(node, function()
				
				self["xuanze"..i] = 1 - self["xuanze"..i] 
				xuanze:getChildByTag(1):setSelected(self["xuanze"..i] == 1)
						gt.log("a...",self["xuanze"..i])
			end)

		end 
		for j =2 , 2 do
			local node = xuanze:getChildByTag(j)
			node:setSelected(self["xuanze1"..i] == j-1)
			gt.log("xuanze1..",self["xuanze1"..i])
			gt.setOnViewClickedListener(node, function()
				
				self["xuanze1"..i] = 1 - self["xuanze1"..i] 
				xuanze:getChildByTag(2):setSelected(self["xuanze1"..i] == 1)

				gt.log("b...",self["xuanze1"..i])
						
			end)
		end 

		for j =3 , 3 do
			local node = xuanze:getChildByTag(j)
			node:setSelected(self["xuanze2"..i] == 1)
			gt.setOnViewClickedListener(node, function()
				
				self["xuanze2"..i] = 1 - self["xuanze2"..i] 
				xuanze:getChildByTag(j):setSelected(self["xuanze2"..i] == 1)

				gt.log("c...",self["xuanze2"..i])
				zhu:getChildByTag(2):getChildByName("Text"):setString(self["xuanze2"..i] == 1 and "从3开始" or "从2开始")
			end)
		end 

		-- for j =3 , 3 do
		-- 	local node = xuanze:getChildByTag(j)
		-- 	node:setSelected(self["xuanze2"..i] == j-2)
		-- 	gt.setOnViewClickedListener(node, function()
				
		-- 		self["xuanze2"..i] = 1 - self["xuanze2"..i] 
		-- 		self.csbNode:getChildByName("Node_"..i):getChildByName("t_xuanze"):getChildByTag(j):setSelected(self["xuanze2"..i] == 1)

		-- 		gt.log("c...",self["xuanze2"..i])
						
		-- 	end)
		-- end 

		
		-- for j = 4 , 4 do
		-- 	local node = xuanze:getChildByTag(j)
		-- 	gt.log("node",node,i,self["xuanze3"..i])
		--     node:setSelected(self["xuanze3"..i] == j-3)
		-- 	gt.setOnViewClickedListener(node, function()
				
		-- 		self["xuanze3"..i] = 1 - self["xuanze3"..i] 
		-- 		self.csbNode:getChildByName("Node_"..i):getChildByName("t_xuanze"):getChildByTag(j):setSelected(self["xuanze3"..i] == 1)

		-- 		gt.log("d...",self["xuanze3"..i])
						
		-- 	end)
		-- end
		

	end




end


function createRoom:sendCreateRoom()
	
			local kGpsLng = "0"
			local kGpsLat = "0"

			
			
			
			local msgToSend = {}
			msgToSend.kGpsLimit = self["xuanze"..self.play_type]
			msgToSend.kMId = gt.CG_CREATE_ROOM

			if self["xuanze"..self.play_type] == 1 then 
				--gt.showLoadingTips(gt.getLocationString("LTKey_0059"))
				local data = ""
				local time = 0
				gt.showLoadingTips("房间创建中...")
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
						msgToSend.kState =   106        --   炸金花  102，斗地主  101，牛牛    103， 106   升级
						msgToSend.kFeeType =  1     --（费用类型 ，0:房主付费 1:玩家分摊）
						msgToSend.kDeskType = 0
						msgToSend.kGpsLng = tostring(kGpsLng)
						msgToSend.kGpsLat = tostring(kGpsLat)
						msgToSend.kGreater2CanStart = 0       

						msgToSend.kPlayType[1] = self["difen"..self.play_type] -- 底分 1 or 2 or 3
						msgToSend.kPlayType[2] = self["zhu"..self.play_type] -- 1 开始随机主 or 2 从3开始
						msgToSend.kPlayType[3] = self["xuanze1"..self.play_type] -- 1 防作弊场 or 0 相反
						msgToSend.kPlayType[4] = self["xuanze2"..self.play_type] -- 1 2是常主 or 0 相反
						msgToSend.kPlayType[5] = 0
						msgToSend.kPlayType[6] = 0
						msgToSend.kPlayType[7] = 0
						msgToSend.kPlayType[8] = 0
						msgToSend.kPlayType[9] = 0 
						msgToSend.kPlayType[10] = 0
						msgToSend.kPlayType[11] = 0
						msgToSend.kPlayType[12] = 0
						msgToSend.kPlayType[13] = 0
						msgToSend.kPlayType[14] = 0
						msgToSend.kPlayType[15] = 0

						
						gt.log("创建房间________",self.wanfa)
						gt.dump(msgToSend)

						

						gt.socketClient:sendMessage(msgToSend)

						

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
				msgToSend.kState =   106        --   炸金花  102，斗地主  101，牛牛    103，
				msgToSend.kFeeType =  1     --（费用类型 ，0:房主付费 1:玩家分摊）
				msgToSend.kDeskType = 0
				msgToSend.kGpsLng = tostring(0)
				msgToSend.kGpsLat = tostring(0)
				msgToSend.kGreater2CanStart = 0

				msgToSend.kPlayType[1] = self["difen"..self.play_type] -- 底分 1 or 2 or 3
				msgToSend.kPlayType[2] = self["zhu"..self.play_type] -- 1 开始随机主 or 2 从3开始
				msgToSend.kPlayType[3] = self["xuanze1"..self.play_type] -- 1 防作弊场 or 0 相反
				msgToSend.kPlayType[4] = self["xuanze2"..self.play_type] -- 1 2是常主 or 0 相反
				msgToSend.kPlayType[5] = 0
				msgToSend.kPlayType[6] = 0
				msgToSend.kPlayType[7] = 0
				msgToSend.kPlayType[8] = 0
				msgToSend.kPlayType[9] = 0 
				msgToSend.kPlayType[10] = 0
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
		
		
end


function createRoom:exit()
		for i =1 , self.play_num do 
			self["jiushu"..i] = cc.UserDefault:getInstance():setIntegerForKey("ddz_jiushu"..i, self["jiushu"..i])
			self["zhu"..i] = cc.UserDefault:getInstance():setIntegerForKey("zhu"..i, self["zhu"..i])
			self["difen"..i] = cc.UserDefault:getInstance():setIntegerForKey("ddz_difen"..i, self["difen"..i])
			self["xuanze"..i] = cc.UserDefault:getInstance():setIntegerForKey("ddz_xuanze"..i, self["xuanze"..i])
			self["xuanze1"..i] = cc.UserDefault:getInstance():setIntegerForKey("ddz_xuanze1"..i, self["xuanze1"..i])
			self["xuanze2"..i] = cc.UserDefault:getInstance():setIntegerForKey("ddz_xuanze2"..i, self["xuanze2"..i])
		end
		gt.log("exit_________")
		if self.createSchedule then
 			gt.scheduler:unscheduleScriptEntry(self.createSchedule)
 			self.createSchedule = nil
 		end
 		gt.dispatchEvent("show_text")

 		gt.socketClient:unregisterMsgListener(gt.GC_CREATE_ROOM)

end



return createRoom