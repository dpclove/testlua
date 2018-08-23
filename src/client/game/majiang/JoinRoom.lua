
local gt = cc.exports.gt

local JoinRoom = class("JoinRoom", function()
	return gt.createMaskLayer()
end)

function JoinRoom:ctor()

	self:setName("__JOINROOM__")
	gt.log("ctor___________")
	local csbNode = cc.CSLoader:createNode("JoinRoom.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	if gt.isAppStoreInReview then
		local bokehImg = gt.seekNodeByName(csbNode, "Img_bokeh")
		if bokehImg then
			bokehImg:setVisible(false)
		end
	end

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	-- 最大输入6个数字
	self.inputMaxCount = 6
	-- 数字文本
	self.inputNumLabels = {}
	self.curInputIdx = 1
	for i = 1, self.inputMaxCount do
		local numLabel = gt.seekNodeByName(csbNode, "Img_num_" .. i)
		numLabel:setVisible(false)
		self.inputNumLabels[i] = numLabel
	end

	-- 数字按键
	for i = 0, 9 do
		local numBtn = gt.seekNodeByName(csbNode, "Btn_num_" .. i)  --遍历数字按键
		numBtn:setTag(i)  --设置标记为0-9
		-- numBtn:addClickEventListener(handler(self, self.numBtnPressed))  --添加点击事件
		gt.addBtnPressedListener( numBtn, handler(self,self.numBtnPressed))
	end

	-- 重置按键
	local resetBtn = gt.seekNodeByName(csbNode, "Btn_reset")
	gt.addBtnPressedListener(resetBtn, function()
		for i = self.inputMaxCount, 1 , -1 do
			local numLabel = gt.seekNodeByName(csbNode, "Img_num_" .. i)
			numLabel:setVisible(false)
			--numLabel:setString("")
		end
		self.curInputIdx = 1  --光标设置在第一位
	end)

   -- 删除按键
	local delBtn = gt.seekNodeByName(csbNode, "Btn_del")
	gt.addBtnPressedListener(delBtn, function()
		for i = self.curInputIdx - 1, 1 , -1 do
			if self.curInputIdx - 1  >= 1 then
				local numLabel = gt.seekNodeByName(csbNode, "Img_num_" .. i)
				numLabel:setVisible(false)
				--numLabel:setString("")
				self.curInputIdx = self.curInputIdx - 1
			end
			break
		end
	end)

	--关闭按键
	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:removeFromParent()
	end)


	gt.socketClient:registerMsgListener(gt.GC_JOIN_ROOM, self, self.onRcvJoinRoom)

	--csw 12 -20
	gt.socketClient:registerMsgListener(gt.MH_MSG_S_2_C_QUERY_ROOM_GPS_LIMIT_RET, self, self.room_tpye)

	--csw 12 -20
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_JOIN_ROOM_CHECK, self, self.addGame)

	gt.registerEventListener("addGame",self,self.room_tpyes)

	gt.registerEventListener("addGameNN",self,self.room_tpye)

end


function JoinRoom:addGame(msg)

	if msg.kState == 102 then -- zjh
		self:addChild(require("client/game/poker/view/addGame"):create(msg),20)
	elseif msg.kState == 103 then -- nn
		self:addChild(require("client/game/poker/view/addGameNN"):create(msg),20)
	end

end

function JoinRoom:onNodeEvent(eventName)
	gt.log("a_____________",eventName)
	if "enter" == eventName then
	elseif "exit" == eventName then
		if self.createSchedule then
 			gt.scheduler:unscheduleScriptEntry(self.createSchedule)
 			self.createSchedule = nil
 		end
 		if self._time then 	gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
  		gt.socketClient:unregisterMsgListener(gt.GC_JOIN_ROOM)

  		--csw 12 -20
  		gt.socketClient:unregisterMsgListener(gt.MH_MSG_S_2_C_QUERY_ROOM_GPS_LIMIT_RET)
  		--csw 12 -20
  		gt.removeTargetEventListenerByType(self,"addGame")
  		gt.removeTargetEventListenerByType(self,"addGameNN")
		gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_JOIN_ROOM_CHECK)
	end
end

function JoinRoom:numBtnPressed(senderBtn)
	local btnTag = senderBtn:getTag()
	gt.log("current tag:"..btnTag)
	local numLabel = self.inputNumLabels[self.curInputIdx]
	if numLabel ~= nil then
		gt.log("join_room___",btnTag)
		numLabel:loadTexture("join_room/"..btnTag..".png")
		numLabel:setTag(btnTag)
		numLabel:setVisible(true)
		if self.curInputIdx >= #self.inputNumLabels then
			local roomID = 0
			local tmpAry = {100000, 10000, 1000, 100, 10, 1}
			for i = 1, self.inputMaxCount do
				local inputNum = tonumber(self.inputNumLabels[i]:getTag())
				roomID = roomID + inputNum * tmpAry[i]
			end

			--csw 12 -20 -- 查询 房间类型 是否 需要 gps
				local msgToSend = {}
				msgToSend.kMId = gt.MH_MSG_C_2_S_QUERY_ROOM_GPS_LIMIT
				msgToSend.kDeskId = roomID
				gt.socketClient:sendMessage(msgToSend)
				self._roomId = roomID
			--csw 12 -20 


			-- 发送进入房间消息  -- 移到 function room_tpye（）
			-- local msgToSend = {}
			-- msgToSend.kMId = gt.CG_JOIN_ROOM
			-- msgToSend.kDeskId = roomID
			-- gt.socketClient:sendMessage(msgToSend)

	 	-- 	self:schedule()

			-- gt.showLoadingTips(gt.getLocationString("LTKey_0006"))

		end
		self.curInputIdx = self.curInputIdx + 1
	end
end

function JoinRoom:onRcvJoinRoom(msgTbl)
	if self.createSchedule then
		gt.scheduler:unscheduleScriptEntry(self.createSchedule)
		self.createSchedule = nil
	end

	
	if msgTbl.kErrorCode ~= 0 then
		-- 进入房间失败
		gt.removeLoadingTips()
		if msgTbl.kErrorCode == 1 then
			-- 房间人已满
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0018"), nil, nil, true)
		elseif msgTbl.kErrorCode == 3 then
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "游戏已开始，无法加入。", nil, nil, true)
		elseif msgTbl.kErrorCode == 4 then
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "房卡不足，请在商城购买！", nil, nil, true)
		elseif msgTbl.kErrorCode == 9 then 
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "获取GPS信息失败！", nil, nil, true) 
		elseif msgTbl.kErrorCode == 10 then
			--require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "获取GPS信息失败！", nil, nil, true) 
			
			if msgTbl.kUserGPSList then 
				local name = {"","","",""}
				local long = {"","","",""}
				local lan  = {"","","",""}
				local checkMapUrl = ""
				local player = string.split(msgTbl.kUserGPSList, "|")
				for i = 1 , #player do
					local data = string.split(player[i],",")
					name[i] = data[1]
					long[i] = data[2]
					lan[i] = data[3]
				end
				for i = 1 , 4 do
					gt.log("name.....",name[i])
					gt.log("long.....",long[i])
					gt.log("lan.....",lan[i])
					
				end
				if #player >=1 then 
					checkMapUrl = 	gt.getUrlEncryCode(string.format(gt.CheckMapUrl, name[1], long[1], lan[1],name[2], long[2], lan[2],name[3], long[3], lan[3],name[4], long[4], lan[4]), gt.playerData.uid)
					if gt.isIOSPlatform() then
						local ok = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "NativeStartMap", {mapUrl = checkMapUrl, notice = ""})
					elseif gt.isAndroidPlatform() then
						require("client/game/common/mapView"):create(checkMapUrl)
					end
					
				end
			end
		else
			-- 房间不存在
			local str=""
			for i,v in ipairs(self.inputNumLabels) do
		        str=str..v:getTag()
	        end
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),string.format("您输入的房间号%s不存在，请重新输入！",str), nil, nil, true)
		end

		self.curInputIdx = 1
		for i = 1, self.inputMaxCount do
			local numLabel = self.inputNumLabels[i]
			numLabel:setVisible(false)
		end
	end
end

function JoinRoom:sendAgain()
	if self.curInputIdx >= #self.inputNumLabels then
		local roomID = 0
		local tmpAry = {100000, 10000, 1000, 100, 10, 1}
		for i = 1, self.inputMaxCount do
			local inputNum = tonumber(self.inputNumLabels[i]:getTag())
			roomID = roomID + inputNum * tmpAry[i]
		end

		--csw 12 -20 -- 查询 房间类型 是否 需要 gps
			local msgToSend = {}
			msgToSend.kMId = gt.MH_MSG_C_2_S_QUERY_ROOM_GPS_LIMIT
			msgToSend.kDeskId = roomID
			gt.socketClient:sendMessage(msgToSend)
			self._roomId = roomID
		--csw 12 -20 

		-- 发送进入房间消息 -- csw 12 -30 注释 移到 function room_tpye
		-- local msgToSend = {}
		-- msgToSend.kMId = gt.CG_JOIN_ROOM
		-- msgToSend.kDeskId = roomID
		-- gt.socketClient:sendMessage(msgToSend)
 
		-- gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
	end
end

function JoinRoom:schedule()
	local chutaiAnimateResult = function(delta)
		print("---------------current time:", self.createTime)
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


function JoinRoom:room_tpye(msg)

	if msg.kErrorCode == 0 then 
		local kGpsLng = 0
		local kGpsLat = 0
		self.kGpsLimit = msg.kGpsLimit
		if msg.kGpsLimit == 0 then  -- 不需要 gps 不做处理

		


			local msgToSend = {}
			msgToSend.kMId = gt.MSG_C_2_S_JOIN_ROOM_CHECK
			msgToSend.kDeskId = self._roomId
			msgToSend.kClubId =self.kClubId or 0
			msgToSend.kPlayTypeId = self.kPlayTypeid or 0
			msgToSend.kGpsLng = tostring(0)
			msgToSend.kGpsLat = tostring(0)
			gt.socketClient:sendMessage(msgToSend)
			gt.showLoadingTips(gt.getLocationString("LTKey_0006"))

		elseif msg.kGpsLimit == 1 then 
		
		
			gt.showLoadingTips(gt.getLocationString("LTKey_0070"))

			local data = ""
			local time = 0
			if self._time then 	gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
			self._time = gt.scheduler:scheduleScriptFunc(function(dt)

				data = Utils.getLocationInfo()

				if (data.longitude and data.latitue and data.longitude ~= "" and data.latitue ~= "" and gt.isAndroidPlatform()) or (data.longitude and data.longitude ~= 0 and data.latitue and data.latitue ~= 0 and gt.isIOSPlatform()) then
					if self._time then gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
				

					local msgToSend = {}
					msgToSend.kMId = gt.MSG_C_2_S_JOIN_ROOM_CHECK
					msgToSend.kDeskId = self._roomId
					msgToSend.kClubId =self.kClubId or 0
					msgToSend.kPlayTypeId = self.kPlayTypeid or 0
					msgToSend.kGpsLng = tostring(data.longitude)
					msgToSend.kGpsLat = tostring(data.latitue)
					self.kGpsLng = tostring(data.longitude)
					self.kGpsLat = tostring(data.latitue)
					gt.socketClient:sendMessage(msgToSend)
					gt.showLoadingTips(gt.getLocationString("LTKey_0006"))

				end
				time = time + dt
				if time > 2 then 
					gt.removeLoadingTips()
					if self._time then 	gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
					local str_des = "获取GPS失败，【相邻位置禁止进入】的房间，必须开启GPS位置才能进入!"
					require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
					str_des, nil, nil, true)
					
				end
				end,0,false)

		
		end
		
	

	else

		local str_des = "您输入的房间号不存在！"

		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
			str_des, nil, nil, true)
	end

end

function JoinRoom:room_tpyes()

		
		if self.kGpsLimit== 1 then 
		
		
			gt.showLoadingTips(gt.getLocationString("LTKey_0070"))
			local msgToSend = {}
			msgToSend.kMId = gt.CG_JOIN_ROOM
			msgToSend.kDeskId = self._roomId
			msgToSend.kGpsLng = self.kGpsLng or "0"
			msgToSend.kGpsLat = self.kGpsLat or "0"
			gt.socketClient:sendMessage(msgToSend)
			self:schedule()
			
			gt.showLoadingTips(gt.getLocationString("LTKey_0006"))

		else

			local msgToSend = {}
			msgToSend.kMId = gt.CG_JOIN_ROOM
			msgToSend.kDeskId = self._roomId
			msgToSend.kGpsLng = tostring(0)
			msgToSend.kGpsLat = tostring(0)
			gt.socketClient:sendMessage(msgToSend)
	 		self:schedule()
			gt.showLoadingTips(gt.getLocationString("LTKey_0006"))

		
		end
		
	



end


return JoinRoom

