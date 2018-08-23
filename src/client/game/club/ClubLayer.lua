
require("client/config/MJRules")
local ClubLayer = class("ClubLayer", function()
	return gt.createMaskLayer()
end)

ClubLayer.ZOrder = {
	FZ_RECORD 				= 4,
	HISTORY_RECORD			= 5,
	CREATE_ROOM				= 6,
	JOIN_ROOM				= 7,
 	INVITATION_CODE         = 8,
	PLAYER_INFO_TIPS		= 9,
	TASK_INVITE				= 15,
	CONFIRM					= 30
}

function ClubLayer:reloginWhenError(_,m)
	--gt.dumplog(m)
	-- local err = gt.err_dump(m)
	-- local  err_text  = gt.seekNodeByName(self.rootNode,"err")
	-- if err ~= "" and err_text then 
	-- 	err_text:setLocalZOrder(5555)
	-- 	err_text:setVisible(true)
	-- 	err_text:setString(err)
	-- end
end



function ClubLayer:ctor(clubId, showLayerFlag)

	if gt.isIOSPlatform() then
		local ok, ret = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "startTrackLocation")
	elseif gt.isAndroidPlatform() then
		
		local ok, ret = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "startTrackLocation",nil,"()V")
	end

	self.kClubId = clubId

	gt.log("clubId_______________",self.kClubId)

	if showLayerFlag then
		self.showLayerFlag = showLayerFlag
	end

	self.m_kcurrent = 1
	self.kPlayTypeid = 0

	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("ClubLayer.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	if self.showLayerFlag then
		csbNode:setVisible(false)
	end
	self.rootNode = csbNode


	self.wait_room = cc.CSLoader:createNode("club_wait_room.csb")
	self:addChild(self.wait_room)
	--self.wait_room:setPosition(gt.winCenter)
	self.wait_room:setVisible(false)
	if gt.seekNodeByName(self.rootNode,"FileNode") then 
		gt.seekNodeByName(self.rootNode,"FileNode"):setVisible(false)
	end
	gt.addBtnPressedListener(gt.seekNodeByName(self.wait_room,"share"),function()

		self:shareWx()

		end)

	gt.addBtnPressedListener(gt.seekNodeByName(self.wait_room,"back"),function()

			local m = {}
			m.kMId = gt.MSG_C_2_S_POKER_EXIT_WAIT
			m.kClubId = self.clubId
			if self.msgTbl and self.msgTbl.kPlayTypeInfo and self.msgTbl.kPlayTypeInfo[self.mahjongType] and self.msgTbl.kPlayTypeInfo[self.mahjongType][1] then
				m.kPlayTypeId = self.msgTbl.kPlayTypeInfo[self.mahjongType][1]
			else
				m.kPlayTypeId = self.kPlayTypeid
			end
			gt.socketClient:sendMessage(m)
		end)

	---- self.ddz_node = gt.seekNodeByName(self.rootNode,"ddz_node")
	---- self.ddz_node:setVisible(false)

	--请选择玩法图片
	-- self.playTypeImg = gt.seekNodeByName(self.rootNode, "Img_playType")
	-- self.playTypeImg:setVisible(false)

	-- 玩法按钮
	self.playTypeListView = gt.seekNodeByName(self.rootNode, "ListView_playType")
	self.playTypeListView:setVisible(false)
	
	-- 文娱馆详情按钮
	self.clubInfoBtn = gt.seekNodeByName(self.rootNode, "Btn_clubInfo")
	self.clubInfoBtn:setVisible(false)
	gt.addBtnPressedListener(self.clubInfoBtn, function(sender)
		self:getClubInfo()
	end)

	-- 查看文娱馆按钮
	self.lookOnClubBtn = gt.seekNodeByName(self.rootNode, "Btn_lookOnClub")
	self.lookOnClubBtn:setVisible(false)
	gt.addBtnPressedListener(self.lookOnClubBtn, function(sender)
		self.lookOnClubFlag = true
		gt.showLoadingTips(gt.getLocationString("LTKey_0055"))
		-- 发送离开文娱馆消息
		local msgToSend = {}
		msgToSend.kMId = gt.CG_LEAVE_CLUB
		msgToSend.kClubId = self.clubId
		if self.msgTbl and self.msgTbl.kPlayTypeInfo and self.msgTbl.kPlayTypeInfo[self.mahjongType] and self.msgTbl.kPlayTypeInfo[self.mahjongType][1] then
			msgToSend.kPlayTypeId = self.msgTbl.kPlayTypeInfo[self.mahjongType][1]
		else
			msgToSend.kPlayTypeId = self.kPlayTypeid
		end
		gt.socketClient:sendMessage(msgToSend)
	end)

	-- 刷新按钮
	self.refreshBtn = gt.seekNodeByName(self.rootNode, "Btn_refresh")
	self.refreshBtn:setVisible(false)
	gt.addBtnPressedListener(self.refreshBtn, function(sender)
		self.switchPlaySceneFlag = true
		gt.showLoadingTips(gt.getLocationString("LTKey_0057"))
		-- 文娱馆界面刷新玩法
		local msgToSend = {}
		msgToSend.kMId = gt.CG_SWITCH_PLAY_SCENE
		msgToSend.kClubId = self.clubId
		msgToSend.kCurrPlayType = self.msgTbl.kPlayTypeInfo[self.mahjongType][1] or 1
		msgToSend.kSwitchToType = self.msgTbl.kPlayTypeInfo[self.mahjongType][1] or 1
		gt.socketClient:sendMessage(msgToSend)
		-- gt.dumploglogin("文娱馆界面刷新玩法")
		-- gt.dumploglogin(msgToSend)
	end)

	-- 公告按钮
	self.gonggaoBtn = gt.seekNodeByName(self.rootNode, "Btn_gonggao")
	gt.addBtnPressedListener(self.gonggaoBtn, function(sender)
		gt.soundEngine:playEffect("common/audio_button_click", false)
		self:getClubPublic()
	end)

	local function callback( )
		gt.log("abcd________")
		gt.soundEngine:playEffect("common/audio_button_click", false)
		self:getClubPublic()
	end
	-- 跑马灯
	local marqueeNode = gt.seekNodeByName(csbNode, "Node_marquee")
	local marqueeMsg = require("client/tools/MarqueeMsg"):create(self, callback)
	marqueeNode:addChild(marqueeMsg)
	self.marqueeMsg = marqueeMsg

	marqueeNode:setVisible(true)
	
	self.g_z = gt.seekNodeByName(csbNode , "g_z")
	self.g_z:setVisible(false)

	-- 进入房间
--	gt.socketClient:registerMsgListener(gt.GC_ENTER_ROOM, self, self.onRcvEnterRoom)

	-- 退出
	local backBtn = gt.seekNodeByName(csbNode, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
		-- 发送离开文娱馆消息
		local msgToSend = {}
		msgToSend.kMId = gt.CG_LEAVE_CLUB
		msgToSend.kClubId = self.clubId
		if self.msgTbl and self.msgTbl.kPlayTypeInfo and self.msgTbl.kPlayTypeInfo[self.mahjongType] and self.msgTbl.kPlayTypeInfo[self.mahjongType][1] then
			msgToSend.kPlayTypeid = self.msgTbl.kPlayTypeInfo[self.mahjongType][1]
		else
			msgToSend.kPlayTypeid = self.kPlayTypeid
		end
		gt.socketClient:sendMessage(msgToSend)
	end)

	self.updateClubTableItemData1 = {}
	self.updateClubTableItemData2 = {}

	gt.registerEventListener(gt.EventType.RELOGIN_WHEN_ERROR, self, self.reloginWhenError)
	-- 注册消息回调
	gt.socketClient:registerMsgListener(gt.GC_LEAVE_CLUB, self, self.onRcvLeaveClub)

	gt.socketClient:registerMsgListener(gt.GC_SWITCH_PLAY_SCENE, self, self.onRcvSwitchPlayScene)

	gt.socketClient:registerMsgListener(gt.GC_CLUB_DESK_INFO, self, self.onRcvClubDeskInfo)

	gt.socketClient:registerMsgListener(gt.GC_CLUB_DESK_PLAYERINFO, self, self.onRcvClubDeskPlayerInfo)

	gt.socketClient:registerMsgListener(gt.GC_JOIN_ROOM, self, self.onRcvJoinRoom)

	gt.socketClient:registerMsgListener(gt.GC_CLUB_SCENE, self, self.onRcvClubScene)

	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_JOIN_ROOM_CHECK, self, self.addGame)

	gt.registerEventListener("addGame",self,self.joinroom)

	gt.registerEventListener("addGameNN",self,self.joinroom)

	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_CLUB_MASTER_RESET_ROOM, self, self.onRcvClubMasterResetRoom)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_POKER_WAIT_JOIN_ROOM,self,self.show_wait)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_POKER_EXIT_WAIT,self,self.hide_wait)
end

-- function ClubLayer:create_NoticeTips()

-- 	self._NoticeTips = cc.CSLoader:create("NoticeTips.csb")

-- end

function ClubLayer:send_anonymous_seat()
	
	
	if self.msgTbl.kGpsLimit == 1 then 
	--	gt.showLoadingTips(gt.getLocationString("LTKey_0059"))
		local data = ""
		local time = 0
		if self._time then 	gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
		self._time = gt.scheduler:scheduleScriptFunc(function(dt)
			data = Utils.getLocationInfo()
			if (data.longitude and data.latitue and data.longitude ~= "" and data.latitue ~= "" and gt.isAndroidPlatform()) or (data.longitude and data.longitude ~= 0 and data.latitue and data.latitue ~= 0 and gt.isIOSPlatform()) then
				if self._time then gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
			
				local msgToSend = {}
				msgToSend.kMId = gt.MSG_S_2_C_DOUDIZHU_JOIN_CLUB_ROOM_ANONYMOUS
				msgToSend.kClubId =self.kClubId or 0
				msgToSend.kPlayTypeId = self.kPlayTypeid or 0
				msgToSend.kGpsLng = tostring(data.longitude)
				msgToSend.kGpsLat = tostring(data.latitue)
				gt.socketClient:sendMessage(msgToSend)
			--	gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
				self.kGpsLng = tostring(data.longitude)
				self.kGpsLat = tostring(data.latitue)
				
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
	else
		local msgToSend = {}
		msgToSend.kMId = gt.MSG_S_2_C_DOUDIZHU_JOIN_CLUB_ROOM_ANONYMOUS
		msgToSend.kClubId =self.kClubId or 0
		msgToSend.kPlayTypeId = self.kPlayTypeid or 0
		msgToSend.kGpsLng = tostring(0)
		msgToSend.kGpsLat = tostring(0)
		gt.socketClient:sendMessage(msgToSend)
		--gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
		
		-- gt.dumploglogin("进入文娱馆桌子")
		-- gt.dumploglogin(msgToSend)
	end


end

function ClubLayer:onRcvClubMasterResetRoom(msgTbl)
	require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), msgTbl.kStrErrorDes, nil, nil, true)
end

function ClubLayer:addGame(msg)

	if msg.kState == 102 then -- zjh
		self:addChild(require("client/game/poker/view/addGame"):create(msg),20)
	elseif msg.kState == 103 then -- nn
		self:addChild(require("client/game/poker/view/addGameNN"):create(msg),20)
	end

end


function ClubLayer:onNodeEvent(eventName)
	if "enter" == eventName then
		-- if showLayerFlag then
		-- 	gt.clubId = 0
		-- 	local runningScene = display.getRunningScene()
		-- 	if runningScene then
		-- 		runningScene:reLogin(self.kClubId)
		-- 	end
		-- else
			local msgToSend = {}
			msgToSend.kMId = gt.CG_ENTER_CLUB
			msgToSend.kClubId = self.kClubId
			gt.socketClient:sendMessage(msgToSend)

			--self.kClubId = gt.clubId
			gt.log("clubid)))))))))))))))))_________")
		-- end
		gt.dumploglogin("进入文娱馆界面")
		gt.dumploglogin(msgToSend)
		self._exit = true
		self.enterClubFlag = false
		local enterClubResult = function(delta)
			if self.enterClubSchedule then
	 			gt.scheduler:unscheduleScriptEntry(self.enterClubSchedule)
	 			self.enterClubSchedule = nil
	 		end
			if not self.enterClubFlag then
				gt.removeLoadingTips()
		 		self:removeFromParent()
			end
	 	end
		self.enterClubSchedule = gt.scheduler:scheduleScriptFunc(enterClubResult, 5, false)
	elseif "exit" == eventName then
		if self.enterClubSchedule then
 			gt.scheduler:unscheduleScriptEntry(self.enterClubSchedule)
 			self.enterClubSchedule = nil
 		end
 		self._exit = false
 		gt.removeTargetAllEventListener(self)
 		if self._time then 	gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
		gt.socketClient:unregisterMsgListener(gt.GC_LEAVE_CLUB)
		gt.socketClient:unregisterMsgListener(gt.GC_SWITCH_PLAY_SCENE)
		gt.socketClient:unregisterMsgListener(gt.GC_CLUB_DESK_INFO)
		gt.socketClient:unregisterMsgListener(gt.GC_CLUB_DESK_PLAYERINFO)
		gt.socketClient:unregisterMsgListener(gt.GC_JOIN_ROOM)
		gt.socketClient:unregisterMsgListener(gt.GC_CLUB_SCENE)
		gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_POKER_WAIT_JOIN_ROOM)
		gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_CLUB_MASTER_RESET_ROOM)
		gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_POKER_EXIT_WAIT)
		gt.removeTargetEventListenerByType(self,"addGame")
		gt.removeTargetEventListenerByType(self,"addGameNN")
		gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_JOIN_ROOM_CHECK)

		gt.removeLoadingTips()

		if self.wait_clock  then 
			 gt.scheduler:unscheduleScriptEntry(self.wait_clock) self.wait_clock = nil 
		end

	end
end

function ClubLayer:onRcvJoinRoom(msgTbl)
	gt.removeLoadingTips()
	if msgTbl.kErrorCode ~= 0 then
		-- 进入房间失败
		if msgTbl.kErrorCode == 1 then
			-- 房间人已满
			local content = gt.getLocationString("LTKey_0018")
			if #msgTbl.kDeskNoSeatPlayerName > 0 then
				content = content .."\n".."待入座："

				for i, cellData in ipairs(msgTbl.kDeskNoSeatPlayerName) do
					content = content..cellData
					if i < #msgTbl.kDeskNoSeatPlayerName then
						content = content.."; "
					end
				end
			else
				content = content .."\n".."待入座：无"
			end
		
			if #msgTbl.kDeskSeatPlayerName > 0 then
				content = content .."\n".."已入座："

				for i, cellData in ipairs(msgTbl.kDeskSeatPlayerName) do
					content = content..cellData
					if i < #msgTbl.kDeskSeatPlayerName then
						content = content.."; "
					end
				end
			else
				content = content .."\n".."已入座：无"
			end
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), content, nil, nil, true)
		elseif msgTbl.kErrorCode == 2 then
			-- 房间不存在
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),string.format("房间号%s不存在！", self.mwCode), nil, nil, true)
		elseif msgTbl.kErrorCode == 3 then
			-- 游戏已经开始
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "游戏已开始，无法加入。", nil, nil, true)

		elseif msgTbl.kErrorCode == 4 then
			-- 玩家房卡不足，请及时充房卡
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "您的房卡不足，请及时充房卡。当前文娱馆为玩家均摊房卡模式！", nil, nil, true)
		elseif msgTbl.kErrorCode == 5 then
			-- 请解散已创建的房间后再进入
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "请解散已创建的房间后再进入！", nil, nil, true)
		elseif msgTbl.kErrorCode == 7 then
			-- 会长房卡不足！
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "会长房卡不足，请提醒会长及时充房卡。当前文娱馆为会长支付房卡模式！", nil, nil, true)
		elseif  msgTbl.kErrorCode == 9 then
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "获取GPS信息失败！", nil, nil, true) 
		elseif  msgTbl.kErrorCode == 10 then 
				--require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "获取GPS信息失败！", nil, nil, true) 
			
			if msgTbl.kUserGPSList then 
				local name = {"","","","","","","","","",""}
				local long = {"","","","","","","","","",""}
				local lan  = {"","","","","","","","","",""}
				local checkMapUrl = ""
				local player = string.split(msgTbl.kUserGPSList, "|")
				for i = 1 , #player do
					local data = string.split(player[i],",")
					name[i] = data[1]
					long[i] = data[2]
					lan[i] = data[3]
				end
				if #player >=1 then 
					checkMapUrl = 	gt.getUrlEncryCode(string.format(gt.CheckMapUrl, name[1], long[1], lan[1],name[2], long[2], lan[2],name[3], long[3], lan[3],name[4], long[4], lan[4],name[5], long[5], lan[5],name[6], long[6], lan[6]
						,name[7], long[7], lan[7]
						,name[8], long[8], lan[8]
						,name[9], long[9], lan[9]
						,name[10], long[10], lan[10]), gt.playerData.uid)

					if gt.isIOSPlatform() then
						local ok = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "NativeStartMap", {mapUrl = checkMapUrl, notice = ""})
					elseif gt.isAndroidPlatform() then
						require("client/game/common/mapView"):create(checkMapUrl)
					end

				end
			end
		end
	end
end

-- 这
-- start --
--------------------------------
-- @class function
-- @description 进入房间消息
-- @param msgTbl 消息体
-- end --
function ClubLayer:onRcvEnterRoom(msgTbl)
	if self.sportDialog then
		self.sportDialog:destroy()
		self.sportDialog = nil
	end
	
	gt.removeLoadingTips()

	gt.removeTargetAllEventListener(self)

	if msgTbl.kSportId and msgTbl.kSportId >= 100 then
		local sportInfo = require("app/views/sport/SportManager").getInstance().curSportInfo
		sportInfo.kSportId = msgTbl.kSportId
		local playScene = require("app/views/sport/SportScene"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	else
		local playScene = nil 
		if msgTbl.kState == 102 then                ----   炸金花  102，斗地主  101，牛牛    103，
			gt.log("scene,..........",display.getRunningScene().name)
			if display.getRunningScene().name ~= "pokerScene" then 
				playScene = require("client/game/poker/zjhScene"):create(msgTbl)
			end
		elseif msgTbl.kState == 103 then
			gt.log("scene,..........",display.getRunningScene().name)
			if display.getRunningScene().name ~= "pokerScene" then 
				playScene = require("client/game/poker/scene/nnScene"):create(msgTbl)
			end
		elseif msgTbl.kState == 101 then
			if display.getRunningScene().name ~= "pokerScene" then 
	         	playScene = require("client/game/poker/ddzScene"):create(msgTbl)
	        end
	    elseif msgTbl.kState == 106 then
	    	if display.getRunningScene().name ~= "pokerScene" then 
	         	playScene = require("client/game/poker/sjScene"):create(msgTbl)
	        end
	    end
	     gt.log("replase__________s",msgTbl.kState)
	    if playScene then 
	    	cc.Director:getInstance():replaceScene(playScene)
		end
	end
end

function ClubLayer:onRcvRemovePlayer(msgTbl)
	if not gt.isCreateUserId and gt.playerData.uid == msgTbl.kUserId then
		if msgTbl.kDismissName and msgTbl.kDismissName ~= "" then
			local runningScene = cc.Director:getInstance():getRunningScene()
		 	Toast.showToast(runningScene, "房主"..msgTbl.kDismissName.."解散了房间！", 2)
		end
	end
end

function ClubLayer:setClubInfo( )
	-- 文娱馆名称
	self.clubNameLabel = gt.seekNodeByName(self.rootNode, "Label_clubName")
	self.clubNameLabel:setString(self.msgTbl.kClubName)

	-- 玩法规则
	self.ruleLabel = gt.seekNodeByName(self.rootNode, "Label_rule")
	
	-- 玩法按钮列表
	self.playTypeListView = gt.seekNodeByName(self.rootNode, "ListView_playType")
	self.playTypeListView:setScrollBarEnabled(false)
	self.playTypeListView:setTouchEnabled(false)

	-- 文娱馆桌子列表
	self.tableListView = gt.seekNodeByName(self.rootNode, "ScrollView_table")

	if self.msgTbl.kState == 102 then -- zjh
		---- self.ddz_node:setVisible(false)
		-- self.tableListView:setInnerContainerSize(cc.size(7500, 500))
		-- self.tableListView:setPositionX(290.00)
	elseif self.msgTbl.kState == 103 then -- nn
		---- self.ddz_node:setVisible(false)
		-- self.tableListView:setInnerContainerSize(cc.size(7500, 500))
		-- self.tableListView:setPositionX(290.00)
	elseif self.msgTbl.kState == 101 then -- ddz
		

		if self.msgTbl.kPlayType[5] == 1 then 
			-- self.tableListView:setInnerContainerSize(cc.size(6450, 500))
			---- self.ddz_node:setVisible(true)
			-- self.tableListView:setPositionX(662.00)
		else
			-- self.tableListView:setInnerContainerSize(cc.size(6100, 500))
			---- self.ddz_node:setVisible(false)
			-- self.tableListView:setPositionX(290.00)
		end
			-- self.tableListView:setInnerContainerSize(cc.size(980, 1300))
			-- self.tableListView:setPositionX(50.00)

	end
	

	self.clubInfoBtn:setVisible(true)
	-- self.clubInfoBtn:setPositionX(self.clubNameLabel:getPositionX()+self.clubNameLabel:getContentSize().width/2+30)

	-- self.playTypeImg:setVisible(true)
	
	self.playTypeListView:setVisible(true)
	
	self.lookOnClubBtn:setVisible(true)

	self.refreshBtn:setVisible(true)

	self:UpdatePlayTypeListView()

	self:UpdateTableListView(self.mahjongType)
	
    local seqAction = cc.Sequence:create(cc.FadeTo:create(2, 100), cc.FadeTo:create(2, 255))
    gt.seekNodeByName(self.rootNode, "Spr_text"):runAction(cc.RepeatForever:create(seqAction))
end

function ClubLayer:UpdatePlayTypeListView()
	self.playTypeListView:removeAllItems()

	local msgTbl = {
	{m_name="玩法玩法玩法1",m_state="100001",m_cellscore="1",m_flag="1",m_playType={1,1,10002},m_feeType = 1,m_Greater2CanStart=1,m_cheatAgainst=0},
	{m_name="玩法玩法玩法2",m_state="100002",m_cellscore="2",m_flag="1",m_playType={1,2,10002},m_feeType = 1,m_Greater2CanStart=1,m_cheatAgainst=0},
	{m_name="玩法玩法玩法3",m_state="100003",m_cellscore="3",m_flag="2",m_playType={1,3,10002},m_feeType = 1,m_Greater2CanStart=1,m_cheatAgainst=1}}

	self.mahjongTypeBtnCount = 0
	self.mahjongTypeBtns = {}

	self.ruleLabel:setString(self:getRuleText(self.msgTbl))
	-- for i, cellData in ipairs(msgTbl) do
	gt.log("self.msgTbl.kPlayTypeInfo ========###==",#self.msgTbl.kPlayTypeInfo)
	for i, cellData in ipairs(self.msgTbl.kPlayTypeInfo) do
		gt.log("-------------testcell")
		local ClubTableItem = self:createPlayTypeItem(i, cellData)
		self.playTypeListView:pushBackCustomItem(ClubTableItem)
	end
end

function ClubLayer:createPlayTypeItem( i, cellData )
	self.mahjongTypeBtnCount = self.mahjongTypeBtnCount + 1
	local mahjongTypeBtn = ccui.Button:create("res/images/sx_club_play/sx_club_play_button1.png",
	 "res/images/sx_club_play/sx_club_play_button2.png", "res/images/sx_club_play/sx_club_play_button2.png")
	mahjongTypeBtn:setTouchEnabled(true)
	mahjongTypeBtn:setTag(i)

	local playTypeLabel = gt.createTTFLabel(cellData[2], 33)
	-- if i == self.mahjongType then
	-- 	playTypeLabel:setColor(cc.c3b(254,110,0))
	-- 	playTypeLabel:enableOutline(cc.c4b(135,78,0,50),1)
	-- else
	-- 	playTypeLabel:setColor(cc.c3b(147,78,23))
	-- 	playTypeLabel:enableOutline(cc.c4b(148,111,61,50),1)
	-- end
	playTypeLabel:setPosition(cc.p(110, 55))
	playTypeLabel:setTag(1)
	mahjongTypeBtn:addChild(playTypeLabel)

	gt.log("--------------cellData")
	dump(cellData)
	-- local tableIndexLabel = gt.createTTFLabel(tostring(i*100+1).."号 - "..tostring(i*100+10).."号桌", 20)
	local tableIndexLabel = gt.createTTFLabel((cellData[3] or "").."号 - "..(cellData[4] or "").."号桌", 20)
	-- if i == self.mahjongType then
	-- 	tableIndexLabel:setColor(cc.c3b(254,110,0))
	-- 	tableIndexLabel:enableOutline(cc.c4b(135,78,0,50),1)
	-- else
	-- 	tableIndexLabel:setColor(cc.c3b(147,78,23))
	-- 	tableIndexLabel:enableOutline(cc.c4b(148,111,61,50),1)
	-- end
	tableIndexLabel:setPosition(cc.p(110, 25))
	tableIndexLabel:setTag(2)
	mahjongTypeBtn:addChild(tableIndexLabel)

	gt.addBtnPressedListener(mahjongTypeBtn, function(sender)
		local tag = sender:getTag()
		for i = 1, #self.mahjongTypeBtns do
			self.mahjongTypeBtns[i]:setTouchEnabled(self.mahjongTypeBtns[i]:getTag() ~= tag)
			self.mahjongTypeBtns[i]:setBright(self.mahjongTypeBtns[i]:getTag() ~= tag)
			if self.mahjongTypeBtns[i]:getTag() == tag then
				self.mahjongTypeBtns[i]:getChildByTag(1):setColor(cc.c3b(254,110,0))
				self.mahjongTypeBtns[i]:getChildByTag(1):enableOutline(cc.c4b(135,78,0,50),1)
				self.mahjongTypeBtns[i]:getChildByTag(2):setColor(cc.c3b(147,78,23))
				self.mahjongTypeBtns[i]:getChildByTag(2):enableOutline(cc.c4b(135,78,0,50),1)
			else
				self.mahjongTypeBtns[i]:getChildByTag(1):setColor(cc.c3b(254,110,0))
				self.mahjongTypeBtns[i]:getChildByTag(1):enableOutline(cc.c4b(148,111,61,50),1)
				self.mahjongTypeBtns[i]:getChildByTag(2):setColor(cc.c3b(147,78,23))
				self.mahjongTypeBtns[i]:getChildByTag(2):enableOutline(cc.c4b(148,111,61,50),1)
			end
		end

		-- gt.playTypeId = tag

		self.switchPlaySceneFlag = true
		gt.showLoadingTips(gt.getLocationString("LTKey_0054"))
		-- 文娱馆界面切换玩法
		local msgToSend = {}
		msgToSend.kMId = gt.CG_SWITCH_PLAY_SCENE
		msgToSend.kClubId = self.clubId
		msgToSend.kCurrPlayType = self.msgTbl.kPlayTypeInfo[self.mahjongType][1]
		msgToSend.kSwitchToType = self.msgTbl.kPlayTypeInfo[tag][1]
		gt.socketClient:sendMessage(msgToSend)
		-- gt.dumploglogin("文娱馆界面切换玩法")
		-- gt.dumploglogin(msgToSend)
	end)

	mahjongTypeBtn:setPressedActionEnabled(false)
	table.insert(self.mahjongTypeBtns, mahjongTypeBtn)
	self.mahjongTypeBtns[self.mahjongTypeBtnCount]:setTouchEnabled(i ~= self.mahjongType)
	self.mahjongTypeBtns[self.mahjongTypeBtnCount]:setBright(i ~= self.mahjongType)

	return mahjongTypeBtn
end

function ClubLayer:UpdateTableListView(playType)
	if self.tableListView then 
		self.tableListView:jumpToLeft()
		self.tableNumberLabel = {}
		self.lookOnBtn = {}
		self.circleNode = {}
		self.circleAtlasLabel = {}
		self.fullImg = {}
		self.dissolveBtn = {}
		self.seatBtn = {}
		self.icon = {}
		self.seatBtn1 = {}
		self.moveSeatBtn = {}
		self.headFrameBtn = {}
		self.moveHeadFrameBtn = {}
		self.headSpr = {}
		self.playType = playType
		self.tableListView:removeAllChildren()
		self.userNode = {}
		self.joinRoomBtn = {}
		self.movejoinRoomBtn = {}
		self.tables = {}
		-- local x = 529
		-- for i, cellData in ipairs(self.msgTbl.kDesksInfo) do
		-- 	local ClubTableItem 

		-- 	if self.msgTbl.kState == 102 then 
		-- 		---- self.ddz_node:setVisible(false)
		-- 		x = 750
		-- 		self.tableListView:setPositionX(290.00)
		-- 	elseif self.msgTbl.kState == 103 then 
		-- 		x = 750
		-- 		---- self.ddz_node:setVisible(false)
		-- 		self.tableListView:setPositionX(290.00)
		-- 	elseif self.msgTbl.kState == 101 then 
		-- 		if self.msgTbl.kPlayType[5] == 1 then 
		-- 			x = 610
		-- 			---- self.ddz_node:setVisible(true)
		-- 			self.tableListView:setPositionX(662.00)
		-- 		else
		-- 			x = 610
		-- 			---- self.ddz_node:setVisible(false)
		-- 			self.tableListView:setPositionX(290.00)
		-- 		end
		-- 	end
		-- 	ClubTableItem = self:createClubTableItem(i, cellData, self.playType)
		-- 	self.tableListView:addChild(ClubTableItem)
		-- 	gt.log("self.msgTbl.kState.....",self.msgTbl.kState,ClubTableItem:getContentSize().width)
		-- 	ClubTableItem:setPosition(cc.p((i-1)*x+ClubTableItem:getContentSize().width/2, ClubTableItem:getContentSize().height/2))
		-- end

		local offset = 30
		local Y = 0
		local x
		local lineCellCount = 0
		local lineHeight = 0
		if self.msgTbl.kState == 102 then -- zjh
			x = 450
			lineCellCount = 2
			lineHeight = 300
		elseif self.msgTbl.kState == 103 then -- nn
			x = 450
			lineCellCount = 2
			lineHeight = 300
		elseif self.msgTbl.kState == 101 then -- ddz
			x = 300
			lineCellCount = 3
			lineHeight = 250
		elseif self.msgTbl.kState == 106 then -- sj
			x = 330
			lineCellCount = 3
			lineHeight = 260
		elseif self.msgTbl.kState == 107 then -- sdr
			x = 320
			lineCellCount = 3
			lineHeight = 250
			offset = 0
			--Y = 50
		elseif self.msgTbl.kState == 109 then -- sdy
			x = 320
			lineCellCount = 3
			lineHeight = 250
			offset = -40
			--Y = 50
		elseif self.msgTbl.kState == 110 then -- wrbf
			x = 320
			lineCellCount = 3
			lineHeight = 250
			offset = -40
			--Y = 50

		end
		local indexX = 1
		local indexY = 1
		local totalCellCount = table.nums(self.msgTbl.kDesksInfo)
		local totalLineCount = math.ceil(totalCellCount/lineCellCount) == 1 and 2 or math.ceil(totalCellCount/lineCellCount)

		if self.msgTbl.kState == 101 and self.msgTbl.kPlayType[5] == 1 then
			local ClubTableItem = self:createClubTableItem(0)
			self.tableListView:addChild(ClubTableItem)
			
		    ClubTableItem:setPosition(cc.p((indexX-1)*x+ClubTableItem:getContentSize().width/2 + offset, totalLineCount*lineHeight-indexY*lineHeight + lineHeight/2-Y))
			indexX = indexX + 1

			if self.tableListView:getChildrenCount()%lineCellCount == 0 then
				indexX = 1
				indexY = indexY + 1
			end
		end


		if self.msgTbl.kState == 106 and self.msgTbl.kPlayType[3] == 1 then
			local ClubTableItem = self:createClubTableItem(0)
			self.tableListView:addChild(ClubTableItem)
			
		    ClubTableItem:setPosition(cc.p((indexX-1)*x+ClubTableItem:getContentSize().width/2 + offset-38, totalLineCount*lineHeight-indexY*lineHeight + lineHeight/2-Y))
			indexX = indexX + 1

			if self.tableListView:getChildrenCount()%lineCellCount == 0 then
				indexX = 1
				indexY = indexY + 1
			end
		end


		if self.msgTbl.kState == 107 and self.msgTbl.kPlayType[5] == 1 then
			local ClubTableItem = self:createClubTableItem(0)
			self.tableListView:addChild(ClubTableItem)
			
		    ClubTableItem:setPosition(cc.p((indexX-1)*x+ClubTableItem:getContentSize().width/2 + offset, totalLineCount*lineHeight-indexY*lineHeight + lineHeight/2-Y))
			indexX = indexX + 1

			if self.tableListView:getChildrenCount()%lineCellCount == 0 then
				indexX = 1
				indexY = indexY + 1
			end
		end

		if self.msgTbl.kState == 109 and self.msgTbl.kPlayType[5] == 1 then -----------------sdy
			local ClubTableItem = self:createClubTableItem(0)
			self.tableListView:addChild(ClubTableItem)
			
		    ClubTableItem:setPosition(cc.p((indexX-1)*x+ClubTableItem:getContentSize().width/2 + offset, totalLineCount*lineHeight-indexY*lineHeight + lineHeight/2-Y))
			indexX = indexX + 1

			if self.tableListView:getChildrenCount()%lineCellCount == 0 then
				indexX = 1
				indexY = indexY + 1
			end
		end

		if self.msgTbl.kState == 110 and self.msgTbl.kPlayType[5] == 1 then
			local ClubTableItem = self:createClubTableItem(0)
			self.tableListView:addChild(ClubTableItem)
			
		    ClubTableItem:setPosition(cc.p((indexX-1)*x+ClubTableItem:getContentSize().width/2 + offset, totalLineCount*lineHeight-indexY*lineHeight + lineHeight/2-Y))
			indexX = indexX + 1

			if self.tableListView:getChildrenCount()%lineCellCount == 0 then
				indexX = 1
				indexY = indexY + 1
			end
		end


		for i, cellData in ipairs(self.msgTbl.kDesksInfo) do
			local ClubTableItem = self:createClubTableItem(i, cellData, self.playType)
			self.tables[i] = ClubTableItem
			self.tableListView:addChild(ClubTableItem)

		    ClubTableItem:setPosition(cc.p((indexX-1)*x+ClubTableItem:getContentSize().width/2 + offset, totalLineCount*lineHeight-indexY*lineHeight + lineHeight/2-Y))
			indexX = indexX + 1

			if self.tableListView:getChildrenCount()%lineCellCount == 0 then
				indexX = 1
				indexY = indexY + 1
			end
		end
		self.tableListView:setInnerContainerSize(cc.size(980, totalLineCount*lineHeight))
	end
end

function ClubLayer:joinroom()
  	

	if self.gpslimit == 1 then 

			-- -- 发送进入房间消息
							local msgToSend = {}
							msgToSend.kMId = gt.CG_JOIN_ROOM
							msgToSend.kDeskId = self._kDeskId
							msgToSend.kGpsLng = self.kGpsLng or "0" 
							msgToSend.kGpsLat =	self.kGpsLat or "0"
							gt.socketClient:sendMessage(msgToSend)
							gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
							gt.dumploglogin("进入文娱馆桌子")
							gt.dumploglogin(msgToSend)


	else


			local msgToSend = {}
			msgToSend.kMId = gt.CG_JOIN_ROOM
			msgToSend.kDeskId = self._kDeskId
			msgToSend.kGpsLng =  "0" 
			msgToSend.kGpsLat =	 "0"
			gt.socketClient:sendMessage(msgToSend)
			gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
			gt.dumploglogin("进入文娱馆桌子")
			gt.dumploglogin(msgToSend)
	end

end



function ClubLayer:createClubTableItem( i, cellData, playType )

	local player_num = 4 

	local curplayTypePanel
	local csbNode

	--self.g_z:setVisible( (self.msgTbl.kState == 107 and  self.msgTbl.kClubOwerLookOn == 1) )
	self.g_z:setVisible( ((self.msgTbl.kState == 107 or self.msgTbl.kState == 109 or self.msgTbl.kState == 110) and  self.msgTbl.kClubOwerLookOn == 1) )

	--if self.msgTbl.kState == 107 and  self.msgTbl.kClubOwerLookOn == 1 then 
	if (self.msgTbl.kState == 107 or self.msgTbl.kState == 109 or self.msgTbl.kState == 110) and  self.msgTbl.kClubOwerLookOn == 1 then 
		gt.log("runaction_________________")
		self.g_z:getChildByName("sj"):runAction( cc.RepeatForever:create(cc.Blink:create(2, 2)))

	end


	if self.msgTbl.kState == 102 then -- zjh 
		gt.log("zjh_______")
		player_num = 5
		
		self.tableListView:setInnerContainerSize(cc.size(7500, 500))

		if self.msgTbl.kPlayType and self.msgTbl.kPlayType[7] and self.msgTbl.kPlayType[7] == 8 then 
			csbNode = cc.CSLoader:createNode("zjh_clubs.csb")
			player_num = 8
		else
			csbNode = cc.CSLoader:createNode("zjh_club.csb")
		end
		self.player_num = player_num

		self.ClubTableCsbNode = csbNode
		curplayTypePanel = self.ClubTableCsbNode
		---- self.ddz_node:setVisible(false)
		-- self.tableListView:setPositionX(290.00)
	elseif self.msgTbl.kState == 103 then -- nn 
		gt.log("nn_______")
		if self.msgTbl.kPlayType[6] == 6 then
			player_num = 6
		elseif self.msgTbl.kPlayType[6] == 10 then
			player_num = 10
		end
		self.player_num = player_num
		self.tableListView:setInnerContainerSize(cc.size(7500, 500))
		self.ClubTableCsbNode = cc.CSLoader:createNode("nn_club.csb")
		-- 玩法
		local playType1Panel = gt.seekNodeByName(self.ClubTableCsbNode, "Panel_6peoples")
		playType1Panel:setVisible(false)
		local playType2Panel = gt.seekNodeByName(self.ClubTableCsbNode, "Panel_10peoples")
		playType2Panel:setVisible(false)
		if self.player_num == 6 then
		gt.log("--------------self.player_num1", self.player_num)
			playType1Panel:setVisible(true)
			playType2Panel:setVisible(false)
			curplayTypePanel = gt.seekNodeByName(self.ClubTableCsbNode, "Panel_6peoples")
		elseif self.player_num == 10 then
		gt.log("--------------self.player_num2", self.player_num)
			playType1Panel:setVisible(false)
			playType2Panel:setVisible(true)
			curplayTypePanel = gt.seekNodeByName(self.ClubTableCsbNode, "Panel_10peoples")
		end
		---- self.ddz_node:setVisible(false)
		--self.tableListView:setPositionX(290.00)

	    -- 已满员点击桌子进入房间
		self.joinRoomBtn[i] = gt.seekNodeByName(self.ClubTableCsbNode, "Btn_joinRoom")
		self.joinRoomBtn[i]:setEnabled(false)
		self.joinRoomBtn[i]:setSwallowTouches(false)
		self.joinRoomBtn[i]:setPressedActionEnabled(true)
		self.joinRoomBtn[i]:setTag(i)
		self.movejoinRoomBtn[i] = {}
		self.movejoinRoomBtn[i].beganPositionX = 0
		self.movejoinRoomBtn[i].endedPositionX = 0
	    self.joinRoomBtn[i]:addTouchEventListener(function(sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            self.movejoinRoomBtn[i].movedCount = 0
	        	self.movejoinRoomBtn[i].beganPositionX = sender:getTouchMovePosition().x
	        elseif eventType == ccui.TouchEventType.ended then
	        	self.movejoinRoomBtn[i].endedPositionX = sender:getTouchMovePosition().x
	        	if math.abs(self.movejoinRoomBtn[i].endedPositionX - self.movejoinRoomBtn[i].beganPositionX) < 10 then
	                --这里加自己按钮事件
	                gt.log("---------------------------这里加自己按钮事件")
					gt.soundEngine:playEffect("common/audio_button_click", false)
					local tag = sender:getTag()
	     
					self.gpslimit = self.msgTbl.kGpsLimit
					self._kDeskId = self.msgTbl.kDesksInfo[i][1]
					if self.msgTbl.kGpsLimit == 1 then 
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
								msgToSend.kDeskId = self.msgTbl.kDesksInfo[i][1]
								msgToSend.kClubId =self.kClubId or 0
								msgToSend.kPlayTypeId = self.kPlayTypeid or 0
								msgToSend.kGpsLng = tostring(data.longitude)
								msgToSend.kGpsLat = tostring(data.latitue)
								gt.socketClient:sendMessage(msgToSend)
								gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
								self.kGpsLng = tostring(data.longitude)
								self.kGpsLat = tostring(data.latitue)
								
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
				    else
						local msgToSend = {}
						msgToSend.kMId = gt.MSG_C_2_S_JOIN_ROOM_CHECK
						msgToSend.kDeskId = self.msgTbl.kDesksInfo[i][1]
						msgToSend.kClubId =self.kClubId or 0
						msgToSend.kPlayTypeId = self.kPlayTypeid or 0
						msgToSend.kGpsLng = tostring(0)
						msgToSend.kGpsLat = tostring(0)
						gt.socketClient:sendMessage(msgToSend)
						gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
						
						gt.dumploglogin("进入文娱馆桌子")
						gt.dumploglogin(msgToSend)
					end
	            end     
	        elseif eventType == ccui.TouchEventType.moved then
	        	self.movejoinRoomBtn[i].movedCount = self.movejoinRoomBtn[i].movedCount + 1
	        	if self.movejoinRoomBtn[i].movedCount == 1 then
	        		self.movejoinRoomBtn[i].beganPositionX = sender:getTouchMovePosition().x
		        end
	        end
	    end)
	elseif self.msgTbl.kState == 101 then
		gt.log("ddz________")
		--self.tableListView:setInnerContainerSize(cc.size(6100, 500))
		--self.tableListView:setInnerContainerSize(cc.size(6450, 500))
		if self.msgTbl.kPlayType[5] == 1 and i == 0 then 
			---- self.ddz_node:setVisible(true)
			-- self.tableListView:setInnerContainerSize(cc.size(980, 1300))
			-- self.tableListView:setPositionX(662.00)

			self.ClubTableCsbNode = cc.CSLoader:createNode("ddz_clubAuto.csb")

			--MSG_S_2_C_DOUDIZHU_JOIN_CLUB_ROOM_ANONYMOUS
			gt.setOnViewClickedListener(gt.seekNodeByName(self.ClubTableCsbNode,"seat"), function()

				self:send_anonymous_seat()

			end,0.5,"zoom")

			local cellSize = self.ClubTableCsbNode:getContentSize()
			local cellItem = ccui.Widget:create()
			-- cellItem:setTag(tag)
			cellItem:setTouchEnabled(true)
			cellItem:setContentSize(cellSize)
			cellItem:addChild(self.ClubTableCsbNode)
			
			return cellItem
		else
			---- self.ddz_node:setVisible(false)
			-- self.tableListView:setInnerContainerSize(cc.size(980, 1300))
			-- self.tableListView:setPositionX(290.00)

			self.ClubTableCsbNode = cc.CSLoader:createNode("ddz_club.csb")
			curplayTypePanel = self.ClubTableCsbNode
			player_num = 3
			self.player_num = player_num
		end
	elseif self.msgTbl.kState == 107 then

	
		if self.msgTbl.kPlayType[5] == 1 and i == 0 then 
			
			self.ClubTableCsbNode = cc.CSLoader:createNode("ddz_clubAuto.csb")

			--MSG_S_2_C_DOUDIZHU_JOIN_CLUB_ROOM_ANONYMOUS
			gt.setOnViewClickedListener(gt.seekNodeByName(self.ClubTableCsbNode,"seat"), function()

				self:send_anonymous_seat()

			end,0.5,"zoom")

			local cellSize = self.ClubTableCsbNode:getContentSize()
			local cellItem = ccui.Widget:create()
			-- cellItem:setTag(tag)
			cellItem:setTouchEnabled(true)
			cellItem:setContentSize(cellSize)
			cellItem:addChild(self.ClubTableCsbNode)
			
			--self.ClubTableCsbNode:getChildByName("look_6"):setVisible( self.msgTbl.kAllowLookOn == 1 )

			return cellItem
		else
			self.ClubTableCsbNode = cc.CSLoader:createNode("sdr_club.csb")

			self.ClubTableCsbNode:getChildByName("look_6"):setVisible( self.msgTbl.kAllowLookOn == 1 )

			curplayTypePanel = self.ClubTableCsbNode
			player_num = 5
			self.player_num = player_num


			self.joinRoomBtn[i] = gt.seekNodeByName(self.ClubTableCsbNode, "Btn_joinRoom")
			self.joinRoomBtn[i]:setEnabled(false)
			self.joinRoomBtn[i]:setSwallowTouches(false)
			self.joinRoomBtn[i]:setPressedActionEnabled(true)
			self.joinRoomBtn[i]:setTag(i)
			self.movejoinRoomBtn[i] = {}
			self.movejoinRoomBtn[i].beganPositionX = 0
			self.movejoinRoomBtn[i].endedPositionX = 0
		    self.joinRoomBtn[i]:addTouchEventListener(function(sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            self.movejoinRoomBtn[i].movedCount = 0
		        	self.movejoinRoomBtn[i].beganPositionX = sender:getTouchMovePosition().x
		        elseif eventType == ccui.TouchEventType.ended then
		        	self.movejoinRoomBtn[i].endedPositionX = sender:getTouchMovePosition().x
		        	if math.abs(self.movejoinRoomBtn[i].endedPositionX - self.movejoinRoomBtn[i].beganPositionX) < 10 then
		                --这里加自己按钮事件
		                gt.log("---------------------------这里加自己按钮事件")
						gt.soundEngine:playEffect("common/audio_button_click", false)
						local tag = sender:getTag()
		     
						self.gpslimit = self.msgTbl.kGpsLimit
						self._kDeskId = self.msgTbl.kDesksInfo[i][1]
						if self.msgTbl.kGpsLimit == 1 then 
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
									msgToSend.kDeskId = self.msgTbl.kDesksInfo[i][1]
									msgToSend.kClubId =self.kClubId or 0
									msgToSend.kPlayTypeId = self.kPlayTypeid or 0
									msgToSend.kGpsLng = tostring(data.longitude)
									msgToSend.kGpsLat = tostring(data.latitue)
									gt.socketClient:sendMessage(msgToSend)
									gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
									self.kGpsLng = tostring(data.longitude)
									self.kGpsLat = tostring(data.latitue)
									
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
					    else
							local msgToSend = {}
							msgToSend.kMId = gt.MSG_C_2_S_JOIN_ROOM_CHECK
							msgToSend.kDeskId = self.msgTbl.kDesksInfo[i][1]
							msgToSend.kClubId =self.kClubId or 0
							msgToSend.kPlayTypeId = self.kPlayTypeid or 0
							msgToSend.kGpsLng = tostring(0)
							msgToSend.kGpsLat = tostring(0)
							gt.socketClient:sendMessage(msgToSend)
							gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
							
							gt.dumploglogin("进入文娱馆桌子")
							gt.dumploglogin(msgToSend)
						end
		            end     
		        elseif eventType == ccui.TouchEventType.moved then
		        	self.movejoinRoomBtn[i].movedCount = self.movejoinRoomBtn[i].movedCount + 1
		        	if self.movejoinRoomBtn[i].movedCount == 1 then
		        		self.movejoinRoomBtn[i].beganPositionX = sender:getTouchMovePosition().x
			        end
		        end
		    end)



		end
	elseif self.msgTbl.kState == 110 then
		if self.msgTbl.kPlayType[5] == 1 and i == 0 then 
			self.ClubTableCsbNode = cc.CSLoader:createNode("ddz_clubAuto.csb")
			--MSG_S_2_C_DOUDIZHU_JOIN_CLUB_ROOM_ANONYMOUS
			gt.setOnViewClickedListener(gt.seekNodeByName(self.ClubTableCsbNode,"seat"), function()
				self:send_anonymous_seat()
			end,0.5,"zoom")

			local cellSize = self.ClubTableCsbNode:getContentSize()
			local cellItem = ccui.Widget:create()
			-- cellItem:setTag(tag)
			cellItem:setTouchEnabled(true)
			cellItem:setContentSize(cellSize)
			cellItem:addChild(self.ClubTableCsbNode)
			
			--self.ClubTableCsbNode:getChildByName("look_6"):setVisible( self.msgTbl.kAllowLookOn == 1 )

			return cellItem
		else
			self.ClubTableCsbNode = cc.CSLoader:createNode("sdr_club.csb")

			self.ClubTableCsbNode:getChildByName("look_6"):setVisible( self.msgTbl.kAllowLookOn == 1 )

			curplayTypePanel = self.ClubTableCsbNode
			player_num = 5
			self.player_num = player_num

			self.joinRoomBtn[i] = gt.seekNodeByName(self.ClubTableCsbNode, "Btn_joinRoom")
			self.joinRoomBtn[i]:setEnabled(false)
			self.joinRoomBtn[i]:setSwallowTouches(false)
			self.joinRoomBtn[i]:setPressedActionEnabled(true)
			self.joinRoomBtn[i]:setTag(i)
			self.movejoinRoomBtn[i] = {}
			self.movejoinRoomBtn[i].beganPositionX = 0
			self.movejoinRoomBtn[i].endedPositionX = 0
		    self.joinRoomBtn[i]:addTouchEventListener(function(sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            self.movejoinRoomBtn[i].movedCount = 0
		        	self.movejoinRoomBtn[i].beganPositionX = sender:getTouchMovePosition().x
		        elseif eventType == ccui.TouchEventType.ended then
		        	self.movejoinRoomBtn[i].endedPositionX = sender:getTouchMovePosition().x
		        	if math.abs(self.movejoinRoomBtn[i].endedPositionX - self.movejoinRoomBtn[i].beganPositionX) < 10 then
		                --这里加自己按钮事件
		                gt.log("---------------------------这里加自己按钮事件")
						gt.soundEngine:playEffect("common/audio_button_click", false)
						local tag = sender:getTag()
		     
						self.gpslimit = self.msgTbl.kGpsLimit
						self._kDeskId = self.msgTbl.kDesksInfo[i][1]
						if self.msgTbl.kGpsLimit == 1 then 
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
									msgToSend.kDeskId = self.msgTbl.kDesksInfo[i][1]
									msgToSend.kClubId =self.kClubId or 0
									msgToSend.kPlayTypeId = self.kPlayTypeid or 0
									msgToSend.kGpsLng = tostring(data.longitude)
									msgToSend.kGpsLat = tostring(data.latitue)
									gt.socketClient:sendMessage(msgToSend)
									gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
									self.kGpsLng = tostring(data.longitude)
									self.kGpsLat = tostring(data.latitue)
									
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
					    else
							local msgToSend = {}
							msgToSend.kMId = gt.MSG_C_2_S_JOIN_ROOM_CHECK
							msgToSend.kDeskId = self.msgTbl.kDesksInfo[i][1]
							msgToSend.kClubId =self.kClubId or 0
							msgToSend.kPlayTypeId = self.kPlayTypeid or 0
							msgToSend.kGpsLng = tostring(0)
							msgToSend.kGpsLat = tostring(0)
							gt.socketClient:sendMessage(msgToSend)
							gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
							
							gt.dumploglogin("进入文娱馆桌子")
							gt.dumploglogin(msgToSend)
						end
		            end     
		        elseif eventType == ccui.TouchEventType.moved then
		        	self.movejoinRoomBtn[i].movedCount = self.movejoinRoomBtn[i].movedCount + 1
		        	if self.movejoinRoomBtn[i].movedCount == 1 then
		        		self.movejoinRoomBtn[i].beganPositionX = sender:getTouchMovePosition().x
			        end
		        end
		    end)
		end
	elseif self.msgTbl.kState == 109 then  --------------sdy

	
		if self.msgTbl.kPlayType[5] == 1 and i == 0 then 
			
			self.ClubTableCsbNode = cc.CSLoader:createNode("ddz_clubAuto.csb")

			--MSG_S_2_C_DOUDIZHU_JOIN_CLUB_ROOM_ANONYMOUS
			gt.setOnViewClickedListener(gt.seekNodeByName(self.ClubTableCsbNode,"seat"), function()

				self:send_anonymous_seat()

			end,0.5,"zoom")

			local cellSize = self.ClubTableCsbNode:getContentSize()
			local cellItem = ccui.Widget:create()
			-- cellItem:setTag(tag)
			cellItem:setTouchEnabled(true)
			cellItem:setContentSize(cellSize)
			cellItem:addChild(self.ClubTableCsbNode)
			
			--self.ClubTableCsbNode:getChildByName("look_6"):setVisible( self.msgTbl.kAllowLookOn == 1 )

			return cellItem
		else
			
			self.ClubTableCsbNode = cc.CSLoader:createNode("sdy_club.csb")

			self.ClubTableCsbNode:setScale(0.9)

			self.ClubTableCsbNode:getChildByName("look_6"):setVisible( self.msgTbl.kAllowLookOn == 1 )

			curplayTypePanel = self.ClubTableCsbNode
			player_num = 4
			self.player_num = player_num


			self.joinRoomBtn[i] = gt.seekNodeByName(self.ClubTableCsbNode, "Btn_joinRoom")
			self.joinRoomBtn[i]:setEnabled(false)
			self.joinRoomBtn[i]:setSwallowTouches(false)
			self.joinRoomBtn[i]:setPressedActionEnabled(true)
			self.joinRoomBtn[i]:setTag(i)
			self.movejoinRoomBtn[i] = {}
			self.movejoinRoomBtn[i].beganPositionX = 0
			self.movejoinRoomBtn[i].endedPositionX = 0
		    self.joinRoomBtn[i]:addTouchEventListener(function(sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            self.movejoinRoomBtn[i].movedCount = 0
		        	self.movejoinRoomBtn[i].beganPositionX = sender:getTouchMovePosition().x
		        elseif eventType == ccui.TouchEventType.ended then
		        	self.movejoinRoomBtn[i].endedPositionX = sender:getTouchMovePosition().x
		        	if math.abs(self.movejoinRoomBtn[i].endedPositionX - self.movejoinRoomBtn[i].beganPositionX) < 10 then
		                --这里加自己按钮事件
		                gt.log("---------------------------这里加自己按钮事件")
						gt.soundEngine:playEffect("common/audio_button_click", false)
						local tag = sender:getTag()
		     
						self.gpslimit = self.msgTbl.kGpsLimit
						self._kDeskId = self.msgTbl.kDesksInfo[i][1]
						if self.msgTbl.kGpsLimit == 1 then 
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
									msgToSend.kDeskId = self.msgTbl.kDesksInfo[i][1]
									msgToSend.kClubId =self.kClubId or 0
									msgToSend.kPlayTypeId = self.kPlayTypeid or 0
									msgToSend.kGpsLng = tostring(data.longitude)
									msgToSend.kGpsLat = tostring(data.latitue)
									gt.socketClient:sendMessage(msgToSend)
									gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
									self.kGpsLng = tostring(data.longitude)
									self.kGpsLat = tostring(data.latitue)
									
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
					    else
							local msgToSend = {}
							msgToSend.kMId = gt.MSG_C_2_S_JOIN_ROOM_CHECK
							msgToSend.kDeskId = self.msgTbl.kDesksInfo[i][1]
							msgToSend.kClubId =self.kClubId or 0
							msgToSend.kPlayTypeId = self.kPlayTypeid or 0
							msgToSend.kGpsLng = tostring(0)
							msgToSend.kGpsLat = tostring(0)
							gt.socketClient:sendMessage(msgToSend)
							gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
							
							gt.dumploglogin("进入文娱馆桌子")
							gt.dumploglogin(msgToSend)
						end
		            end     
		        elseif eventType == ccui.TouchEventType.moved then
		        	self.movejoinRoomBtn[i].movedCount = self.movejoinRoomBtn[i].movedCount + 1
		        	if self.movejoinRoomBtn[i].movedCount == 1 then
		        		self.movejoinRoomBtn[i].beganPositionX = sender:getTouchMovePosition().x
			        end
		        end
		    end)




		end



	elseif self.msgTbl.kState == 106 then
		
		
		if self.msgTbl.kPlayType[3] == 1 and i == 0 then 
			
			self.ClubTableCsbNode = cc.CSLoader:createNode("ddz_clubAuto.csb")

			gt.setOnViewClickedListener(gt.seekNodeByName(self.ClubTableCsbNode,"seat"), function()

				self:send_anonymous_seat()

			end,0.5,"zoom")

			local cellSize = self.ClubTableCsbNode:getContentSize()
			local cellItem = ccui.Widget:create()
			-- cellItem:setTag(tag)
			cellItem:setTouchEnabled(true)
			cellItem:setContentSize(cellSize)
			cellItem:addChild(self.ClubTableCsbNode)

			return cellItem
		else

			self.ClubTableCsbNode = cc.CSLoader:createNode("sj_club.csb")
			curplayTypePanel = self.ClubTableCsbNode
			player_num = 4
			self.player_num = player_num

		end

	end

	-- 桌号
	self.tableNumberLabel[i] = gt.seekNodeByName(self.ClubTableCsbNode, "Label_tableNumber")
	if self.tableNumberLabel and self.tableNumberLabel[i] then
		self.tableNumberLabel[i]:setString((cellData[3] or "").."号桌")
	end

	-- 座位
	self.userNode[i] = {}
	for j = 1, player_num do
		self.userNode[i][j] = gt.seekNodeByName(curplayTypePanel, "Node_user"..j)
		self.userNode[i][j]:setVisible(true)
	end

    -- 观战按钮
	self.lookOnBtn[i] = gt.seekNodeByName(self.ClubTableCsbNode, "Btn_lookOn")
	self.lookOnBtn[i]:setSwallowTouches(false)
	self.lookOnBtn[i]:setPressedActionEnabled(true)
	self.lookOnBtn[i]:setEnabled(false)
	self.lookOnBtn[i]:setVisible(false)
	local moveLookOnBtn = false

	-- 解散牌桌按钮
	self.dissolveBtn[i] = gt.seekNodeByName(self.ClubTableCsbNode, "Btn_dissolve")
	gt.addBtnPressedListener(self.dissolveBtn[i], function()
		require("client/game/dialog/NoticeTips"):create(
		"",
		"是否解散该房间？",
		function()
			-- 发送解散牌桌消息
			local msgToSend = {}
			msgToSend.kMId = gt.MSG_C_2_S_CLUB_MASTER_RESET_ROOM
			msgToSend.kClubId = self.clubId
			msgToSend.kPlayTypeId = self.kPlayTypeid
			msgToSend.kClubDeskId = self.msgTbl.kDesksInfo[i][1]
			msgToSend.kShowDeskId = self.msgTbl.kDesksInfo[i][3]
			gt.socketClient:sendMessage(msgToSend)
		end)
    end)

	
	if self.dissolveBtn and self.dissolveBtn[i] then
		gt.log("a_______")
	    if self.presidentid == gt.playerData.uid then
			if #cellData[2] == 0 then
				
				--if cellData[5] > 0 then
					self.dissolveBtn[i]:setVisible(false)
				--else
				--	self.dissolveBtn[i]:setVisible(false)
				--end
					gt.log("b_______")
			else
					gt.log("c_______")
				self.dissolveBtn[i]:setVisible(true)
			end
	   else
	    	self.dissolveBtn[i]:setVisible(false)
	   end
	end

    -- 当前局数
	self.circleNode[i] = gt.seekNodeByName(self.ClubTableCsbNode, "Node_circle")
	self.circleNode[i]:setVisible(false)

	self.circleAtlasLabel[i] = gt.seekNodeByName(self.ClubTableCsbNode, "AtlasLabel_circle")

    -- 已满员
	self.fullImg[i] = gt.seekNodeByName(self.ClubTableCsbNode, "Img_full")
	self.fullImg[i]:setVisible(false)

	if cellData[4] == 1 then
		self.lookOnBtn[i]:setVisible(true)
		if cellData[5] == 0 then
		    -- 已满员
		    

			self.fullImg[i]:setVisible(true)
		else
	
			self.circleNode[i]:setVisible(true)
			self.circleAtlasLabel[i]:setString(cellData[5].."/"..cellData[6])
		end
		--if self.msgTbl.kState == 107 and self.joinRoomBtn and self.joinRoomBtn[i]  then
		if (self.msgTbl.kState == 107 or self.msgTbl.kState == 109 or self.msgTbl.kState == 110)  and self.joinRoomBtn and self.joinRoomBtn[i]  then
			self.joinRoomBtn[i]:setEnabled(true)
			if self.msgTbl.kPlayType[5] == 1  and self.ClubTableCsbNode and self.ClubTableCsbNode:getChildByName("look_6") then 
				self.ClubTableCsbNode:getChildByName("look_6"):setVisible(true)
			end
		end
	else
		self.lookOnBtn[i]:setVisible(false)
		--if self.msgTbl.kState == 107 and self.joinRoomBtn and self.joinRoomBtn[i] and self.ClubTableCsbNode and self.ClubTableCsbNode:getChildByName("look_6") then
		if (self.msgTbl.kState == 107 or self.msgTbl.kState == 109 or self.msgTbl.kState == 110) and self.joinRoomBtn and self.joinRoomBtn[i] and self.ClubTableCsbNode and self.ClubTableCsbNode:getChildByName("look_6") then
			self.joinRoomBtn[i]:setEnabled(false)
			if self.msgTbl.kPlayType[5] == 1 and self.ClubTableCsbNode and self.ClubTableCsbNode:getChildByName("look_6") then 
				self.ClubTableCsbNode:getChildByName("look_6"):setVisible(false)
			end
		end
	end

	self.headFrameBtn[i] = {}
	self.moveHeadFrameBtn[i] = {}
	self.headSpr[i] = {}
	self.seatBtn[i] = {}
	self.moveSeatBtn[i] = {}
    -- 玩家头像按钮东南西北
    for j = 1, player_num do
		self.headFrameBtn[i][j] = gt.seekNodeByName(curplayTypePanel, "Btn_headFrame"..j)
		self.headFrameBtn[i][j]:setSwallowTouches(false)
		self.headFrameBtn[i][j]:setTag(j)
		self.headFrameBtn[i][j]:setVisible(false)
		self.moveHeadFrameBtn[i][j] = {}
		self.moveHeadFrameBtn[i][j].beganPositionX = 0
		self.moveHeadFrameBtn[i][j].endedPositionX = 0
	    self.headFrameBtn[i][j]:addTouchEventListener(function(sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            self.moveHeadFrameBtn[i][j].movedCount = 0
	        elseif eventType == ccui.TouchEventType.ended then
	        	self.moveHeadFrameBtn[i][j].endedPositionX= sender:getTouchMovePosition().x
	        	if math.abs(self.moveHeadFrameBtn[i][j].endedPositionX - self.moveHeadFrameBtn[i][j].beganPositionX) < 10 then
	                --这里加自己按钮事件
	                gt.log("---------------------------这里加自己按钮事件")
					gt.soundEngine:playEffect("common/audio_button_click", false)
					local tag = sender:getTag()
	                gt.log("---------------------------tag", tag,self.msgTbl.kDesksInfo[i][2])
	                gt.dump(self.msgTbl.kDesksInfo[i])
	                gt.dump(self.msgTbl.kDesksInfo[i][2])
	                local m_userId = 0

	                if self.msgTbl.kDesksInfo[i][2] then
						for i, userCellData in ipairs(self.msgTbl.kDesksInfo[i][2]) do
	                		if userCellData[4] and userCellData[4] + 1 == tag then
	                			m_userId = userCellData[3]
	                		end
						end
	                end

					gt.showLoadingTips(gt.getLocationString("LTKey_0056"))
					-- 发送获取个人信息消息
					-- local msgToSend = {}
					-- msgToSend.kMId = gt.CG_REQUEST_PERSON_INFO
					-- msgToSend.kUserId = m_userId
					-- gt.socketClient:sendMessage(msgToSend)
					self:getClubPersonInfo(m_userId)
	            end     
	        elseif eventType == ccui.TouchEventType.moved then
	            self.moveHeadFrameBtn[i][j].movedCount = self.moveHeadFrameBtn[i][j].movedCount + 1
	        	if self.moveHeadFrameBtn[i][j].movedCount == 1 then
	        		self.moveHeadFrameBtn[i][j].beganPositionX = sender:getTouchMovePosition().x
		        end
	        end
	    end)
    	-- 玩家头像东南西北
		self.headSpr[i][j] = gt.seekNodeByName(self.headFrameBtn[i][j], "Spr_head")
		self.headSpr[i][j]:setVisible(false)
    	-- 入座按钮东南西北
		self.seatBtn[i][j] = gt.seekNodeByName(curplayTypePanel, "Btn_seat"..j)
		self.seatBtn[i][j]:setSwallowTouches(false)
		self.seatBtn[i][j]:setPressedActionEnabled(true)
		-- self.seatBtn[i][j]:setZoomScale(-0.1)
		self.seatBtn[i][j]:setTag(j)
		self.moveSeatBtn[i][j] = {}
		self.moveSeatBtn[i][j].beganPositionX = 0
		self.moveSeatBtn[i][j].endedPositionX = 0
	    self.seatBtn[i][j]:addTouchEventListener(function(sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            self.moveSeatBtn[i][j].movedCount = 0
	        elseif eventType == ccui.TouchEventType.ended then
	        	self.moveSeatBtn[i][j].endedPositionX= sender:getTouchMovePosition().x
	        	if math.abs(self.moveSeatBtn[i][j].endedPositionX - self.moveSeatBtn[i][j].beganPositionX) < 10 then
	                --这里加自己按钮事件
	                gt.log("---------------------------这里加自己按钮事件")
					gt.soundEngine:playEffect("common/audio_button_click", false)
					local tag = sender:getTag()
	                gt.log("---------------------------tag", tag)
	     
				

					self.gpslimit = self.msgTbl.kGpsLimit
					self._kDeskId = self.msgTbl.kDesksInfo[i][1]
					if self.msgTbl.kGpsLimit == 1 then 
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
								msgToSend.kDeskId = self.msgTbl.kDesksInfo[i][1]
								msgToSend.kClubId =self.kClubId or 0
								msgToSend.kPlayTypeId = self.kPlayTypeid or 0
								msgToSend.kGpsLng = tostring(data.longitude)
								msgToSend.kGpsLat = tostring(data.latitue)
								gt.socketClient:sendMessage(msgToSend)
								gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
								self.kGpsLng = tostring(data.longitude)
								self.kGpsLat = tostring(data.latitue)
								
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
				    else
						local msgToSend = {}
						msgToSend.kMId = gt.MSG_C_2_S_JOIN_ROOM_CHECK
						msgToSend.kDeskId = self.msgTbl.kDesksInfo[i][1]
						msgToSend.kClubId =self.kClubId or 0
						msgToSend.kPlayTypeId = self.kPlayTypeid or 0
						msgToSend.kGpsLng = tostring(0)
						msgToSend.kGpsLat = tostring(0)
						gt.socketClient:sendMessage(msgToSend)
						gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
						
						gt.dumploglogin("进入文娱馆桌子")
						gt.dumploglogin(msgToSend)
					end
	            end     
	        elseif eventType == ccui.TouchEventType.moved then
	        	self.moveSeatBtn[i][j].movedCount = self.moveSeatBtn[i][j].movedCount + 1
	        	if self.moveSeatBtn[i][j].movedCount == 1 then
	        		self.moveSeatBtn[i][j].beganPositionX = sender:getTouchMovePosition().x
		        end
	        end
	    end)
    end

	for j, userCellData in ipairs(cellData[2]) do
	    if userCellData and userCellData[4] and userCellData[4] < player_num then
	    	gt.log("------------userCellData", userCellData)
	    	gt.dump(userCellData)
	    	local position = userCellData[4] +1
	    	if self.headSpr and self.headSpr[i] and self.headSpr[i][position] 
	    		and self.headFrameBtn and self.headFrameBtn[i] and self.headFrameBtn[i][position] then
	    		local headFile = "res/images/sx_club_play/sx_club_play_head.png"
   				self.headSpr[i][position]:setTexture(headFile)
				self.headSpr[i][position]:setVisible(true)
				self.headFrameBtn[i][position]:setVisible(true)
				-- -- 头像下载管理器
				-- local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
				-- playerHeadMgr:detach(self.headSpr[i][position])
				-- playerHeadMgr:attach(self.headSpr[i][position], self.headFrameBtn[i][position], userCellData[3], userCellData[2], nil, nil, 97, true, headFile)
				-- self:addChild(playerHeadMgr)
			end
	    	if self.seatBtn[i][position] and not tolua.isnull(self.seatBtn[i][position]) then
				self.seatBtn[i][position]:setVisible(false)
			end
	    end
	end

	local cellSize = self.ClubTableCsbNode:getContentSize()
	local cellItem = ccui.Widget:create()
	-- cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(self.ClubTableCsbNode)
	-- cellItem:addClickEventListener(handler(self, self.sendHistoryOne))

	self.icon[i] = {}
	if (player_num == 3 and self.msgTbl.kPlayType[5] == 1 and self.msgTbl.kState == 101 )or (player_num == 4 and self.msgTbl.kPlayType[3] == 1 and self.msgTbl.kState == 106) or (player_num == 5 and self.msgTbl.kPlayType[5] == 1 and self.msgTbl.kState == 107) or (player_num == 5 and self.msgTbl.kPlayType[5] == 1 and self.msgTbl.kState == 110) or (player_num == 4 and self.msgTbl.kPlayType[5] == 1 and self.msgTbl.kState == 109) then 
		for j = 1 , player_num do
			self.headFrameBtn[i][j]:setVisible(false)
			self.headFrameBtn[i][j]:setEnabled(false)
			-- self.seatBtn[i][j]:setVisible(false)
			self.seatBtn[i][j]:setEnabled(false)
			self.icon[i][j] = gt.seekNodeByName(self.userNode[i][j],"icon")
							  :setVisible(false)
			--self.icon[i][j]:loadTexture("ddz/zjhclub/tmp.png")

		end
	end

	return cellItem
end

function ClubLayer:updateClubTableItem( i, cellData, playType )
	--gt.log(debug.traceback())
	-- local csbNode = cc.CSLoader:createNode("ClubTable.csb")

	self.player_num = self.player_num or 5
	-- 桌号
	if self.tableNumberLabel and self.tableNumberLabel[i] then
		self.tableNumberLabel[i]:setString((cellData[3] or "").."号桌")
	end

	-- 座位
	for j = 1, self.player_num do
		if self.userNode and self.userNode[i] and self.userNode[i][j] then
			self.userNode[i][j]:setVisible(true)
		end
	end
	-- 观战按钮
	if self.lookOnBtn and self.lookOnBtn[i] then
		self.lookOnBtn[i]:setSwallowTouches(false)
		self.lookOnBtn[i]:setPressedActionEnabled(true)
		self.lookOnBtn[i]:setEnabled(false)
		self.lookOnBtn[i]:setVisible(false)
	end


	
	if self.dissolveBtn and self.dissolveBtn[i] then
		
	    if self.presidentid == gt.playerData.uid then
			if #cellData[2] == 0 then
				
				--if cellData[5] > 0 then
					self.dissolveBtn[i]:setVisible(false)
				--else
				--	self.dissolveBtn[i]:setVisible(false)
				--end
			else
				self.dissolveBtn[i]:setVisible(true)
			end
	   else
	    	self.dissolveBtn[i]:setVisible(false)
	   end
	end

	local moveLookOnBtn = false

    -- 当前局数
    if self.circleNode and self.circleNode[i] then
		self.circleNode[i]:setVisible(false)
	end

	if self.circleAtlasLabel and self.circleAtlasLabel[i] then self.circleAtlasLabel[i]:setVisible(false) end

    -- 已满员
    if self.fullImg and self.fullImg[i] then
		self.fullImg[i]:setVisible(false)
	end

	if cellData[4] == 1 then
		if self.lookOnBtn and self.lookOnBtn[i] then
			self.lookOnBtn[i]:setVisible(true)
		end
		if cellData[5] == 0 then
		    -- 已满员
		    if self.fullImg and self.fullImg[i] then
				self.fullImg[i]:setVisible(true)
			end
		else
			if self.circleNode and self.circleNode[i] then
				self.circleNode[i]:setVisible(true)
			end
			if self.circleAtlasLabel and self.circleAtlasLabel[i] then
			    --csw 
				self.circleAtlasLabel[i]:setVisible(true)
				self.circleAtlasLabel[i]:setString(cellData[5].."/"..cellData[6])
			end
		end

		--if self.msgTbl.kState == 107 and self.joinRoomBtn and self.joinRoomBtn[i]  then
		if (self.msgTbl.kState == 107 or self.msgTbl.kState == 109 or self.msgTbl.kState == 110) and self.joinRoomBtn and self.joinRoomBtn[i]  then
			self.joinRoomBtn[i]:setEnabled(true)
			if self.msgTbl.kPlayType[5] == 1 and self.joinRoomBtn[i]:getParent() and self.joinRoomBtn[i]:getParent():getChildByName("look_6") then 
				self.joinRoomBtn[i]:getParent():getChildByName("look_6"):setVisible(true)
			end
		end
		
	else
		if self.lookOnBtn and self.lookOnBtn[i] then
			self.lookOnBtn[i]:setVisible(false)
		end
		--if self.msgTbl.kState == 107 and self.joinRoomBtn and self.joinRoomBtn[i]  then
		if (self.msgTbl.kState == 107 or self.msgTbl.kState == 109 or self.msgTbl.kState == 110) and self.joinRoomBtn and self.joinRoomBtn[i]  then
			self.joinRoomBtn[i]:setEnabled(false)
			if self.msgTbl.kPlayType[5] == 1 and self.joinRoomBtn[i]:getParent() and self.joinRoomBtn[i]:getParent():getChildByName("look_6") then 
				self.joinRoomBtn[i]:getParent():getChildByName("look_6"):setVisible(false)
			end
		end
	end

    -- 玩家头像按钮东南西北
	for j = 1, self.player_num do
		if self.headFrameBtn and self.headFrameBtn[i] and self.headFrameBtn[i][j] then
			self.headFrameBtn[i][j]:setVisible(false)
		end
    	if self.seatBtn and self.seatBtn[i] and self.seatBtn[i][j] then
			self.seatBtn[i][j]:setVisible(true)
		end
	end
	for j, userCellData in ipairs(cellData[2]) do
	    if userCellData and userCellData[4] and userCellData[4] < self.player_num then
	    	local position = userCellData[4] +1
	    	if self.headFrameBtn and self.headFrameBtn[i] and self.headFrameBtn[i][position] then
				self.headFrameBtn[i][position]:setVisible(true)
			end
	    	if self.seatBtn and self.seatBtn[i] and self.seatBtn[i][position] then
				self.seatBtn[i][position]:setVisible(false)
			end
	    	if self.headSpr and self.headSpr[i] and self.headSpr[i][position] 
	    		and self.headFrameBtn and self.headFrameBtn[i] and self.headFrameBtn[i][position] then
	    		local headFile = "res/images/sx_club_play/sx_club_play_head.png"
   				self.headSpr[i][position]:setTexture(headFile)
				self.headSpr[i][position]:setVisible(true)
				-- -- 头像下载管理器
				-- local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
				-- playerHeadMgr:detach(self.headSpr[i][position])
				-- playerHeadMgr:attach(self.headSpr[i][position], self.headFrameBtn[i][position], userCellData[3], userCellData[2], nil, nil, 97, true, headFile)
				-- self:addChild(playerHeadMgr)
			end
	    end
	end
end

-- 刷新所有桌子状态表1
function ClubLayer:refreshTableList1()
	if self.updateClubTableItemData1[1] then
		local ClubTableItemData = self.updateClubTableItemData1[1]
		for i, cellData in ipairs(ClubTableItemData.kDesksInfo) do
			self:updateClubTableItem(i, cellData, self.playType)
		end
		table.remove(self.updateClubTableItemData1, 1)
	end

	if #self.updateClubTableItemData1 > 1 then
		self:refreshTableList1()
	end

	self:refreshTableList2()
end

-- 刷新所有桌子状态表2
function ClubLayer:refreshTableList2()
	if self.updateClubTableItemData2[1] then
		local ClubTableItemData = self.updateClubTableItemData2[1]
		for i, cellData in ipairs(ClubTableItemData.kDesksInfo) do
			self:updateClubTableItem(i, cellData, self.playType)
		end
		table.remove(self.updateClubTableItemData2, 1)
	end

	if #self.updateClubTableItemData2 > 1 then
		self:refreshTableList2()
	end
	
	self.refreshTableListFlag = false
end

--大玩法内容
function ClubLayer:getPlayName(playType)
	self.playerCount = 0
	local playTypeDesc = ""
	if playType == 100001 then
		playTypeDesc = "推倒胡"
		self.playerCount = 4
	elseif playType == 100002 then
		playTypeDesc = "扣点点"
		self.playerCount = 4
	elseif playType == 100008 then
		playTypeDesc = "硬三嘴"
		self.playerCount = 4
    elseif playType == 100009 then
		playTypeDesc = "洪洞王牌"
		self.playerCount = 4
    elseif playType == 100005 then
		playTypeDesc = "晋中"
		self.playerCount = 4
    elseif playType == 100006 then
		playTypeDesc = "拐三角"
		self.playerCount = 3
    elseif playType == 100010 then
		playTypeDesc = "一门牌"	
		self.playerCount = 4
	elseif playType == 100012 then
		playTypeDesc = "二人扣点点"
		self.playerCount = 2
	elseif playType == 100013 then
		playTypeDesc = "三人扣点点"
		self.playerCount = 3
	elseif playType == 100014 then
		playTypeDesc = "二人推倒胡"
		self.playerCount = 2
	elseif playType == 100015 then
		playTypeDesc = "三人推倒胡"
		self.playerCount = 3
	elseif playType == 100016 then
		playTypeDesc = "忻州扣点点"
		self.playerCount = 4
	elseif playType == 100017 then
		playTypeDesc = "临汾撵中子"
		self.playerCount = 4
	elseif playType == 102005 then
		playTypeDesc = "二人晋中"
		self.playerCount = 2
	elseif playType == 103005 then
		playTypeDesc = "三人晋中"
		self.playerCount = 3
	elseif playType == 102008 then
		playTypeDesc = "二人硬三嘴"
		self.playerCount = 2
	elseif playType == 103008 then
		playTypeDesc = "三人硬三嘴"
		self.playerCount = 3
	elseif playType == 102009 then
		playTypeDesc = "二人洪洞王牌"
		self.playerCount = 2
	elseif playType == 103009 then
		playTypeDesc = "三人洪洞王牌"
		self.playerCount = 3
	elseif playType == 102010 then
		playTypeDesc = "二人一门牌"
		self.playerCount = 2
	elseif playType == 103010 then
		playTypeDesc = "三人一门牌"
		self.playerCount = 3
	elseif playType == 100018 then 
		playTypeDesc = "陵川靠八张"
		self.playerCount = 4
	end

	return playTypeDesc
end

function ClubLayer:shareWx()
	


	if self.msgTbl.kState == 101 then 

		local a = self.msgTbl.kPlayType
		--kDesksInfo
		gt.log("________c")
		
		gt.dump(a)

		local ruleText = ""

		if a[1] == 1 then 
			ruleText = ruleText .. "经典玩法，"
		elseif a[1] == 2 then 
			ruleText = ruleText .. "带花玩法，"
		elseif a[1] == 3 then 
			ruleText = ruleText .. "临汾玩法，"
		end


		local man = ""
		if a[6] == 3 then 
			man = "，满3人开局"
		elseif a[6] == 6 then 
			man = "，满6人开局"
		end

		if self.msgTbl.kFlag == 2 then
			 ruleText = ruleText .. "9局，"
		elseif self.msgTbl.kFlag == 3 then 
			ruleText = ruleText .. "18局，"
		elseif self.msgTbl.kFlag == 1 then 
			ruleText = ruleText .. "6局，"
		end

		local ptpye = ""
		if a[7] == 1 then 
			ptpye = ",轮流叫地主"
		elseif a[7] == 0 then
			ptpye = ",赢家叫地主"
		end 

		local tipai = ""
		if a[1] ~= 3 then 
			if a[8] == 1 then 
				tipai = ",可踢和回踢"
			end
		end

		local tifengding = ""
		if a[1] == 3 and a[10] == 1 then
			tifengding = ",踢和回踢算入封顶"
		end
        --去掉判断房间号的条件，直接用房间号
        local txt =  "文娱馆桌号："..(self.msgTbl.kDesksInfo[1][3]..",斗地主，")..ruleText.."缺"..self.m_kcurrent
		--local txt =  "文娱馆桌号："..(a[6] ~= 0 and "xxxxxx" or self.msgTbl.kDesksInfo[1][3]..",斗地主，")..ruleText.."缺"..self.m_kcurrent

		ruleText = ruleText .. (a[2] == 2 and "暗牌（开牌后），" or "明牌（开牌后），").. (a[3] == 0 and  "不封顶，" or tostring(a[3]).."炸封顶，")..(a[4].."分场")..(a[5] == 1 and "，斗地主专属防作弊房"or "")..man..ptpye..tipai..tifengding


		if self.msgTbl.kGpsLimit == 1 then 
			ruleText = ruleText.."，【相邻位置禁止进入房间】"
		end

        --去掉判断房间号的条件，直接用房间号
        local url = string.format(gt.HTTP_INVITE, gt.nickname, cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl","" ), self.msgTbl.kDesksInfo[1][3], "文娱馆桌号："..(self.msgTbl.kDesksInfo[1][3]).."，斗地主，"..ruleText)
	    --local url = string.format(gt.HTTP_INVITE, gt.nickname, cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl","" ), self.msgTbl.kDesksInfo[1][3], "文娱馆桌号："..(a[6] ~= 0 and "xxxxxx" or self.msgTbl.kDesksInfo[1][3]).."，斗地主，"..ruleText)
	    gt.log(url)
	    gt.log(txt)
		Utils.shareURLToHY(url,txt,ruleText,function(ok)
			if ok == 0 then 
			 Toast.showToast(self, "分享成功", 2)
			end

			end)
	elseif self.msgTbl.kState == 106 then

		gt.log("________b")
		
		local a = self.msgTbl.kPlayType

		local b = ""

		if a[1] == 1 then 
			b = b .. ",底分:1"
		elseif a[1] == 2 then 
			b = b .. ",底分:2"
		elseif a[1] == 3 then 
			b = b .. ",底分:3"
		end

		local c = ""
		if a[4] == 1 then 
			c = c .. ",2是常主"
		end

		local d = ""
		if a[3] == 1 then 
			d = d .. ",防作弊场"
		end

		local e = ""
		if a[2] == 1 then 
			e = e .. ",开始随机主"
		elseif a[2] == 2 and a[4] == 1 then
			e = e .. ",从3开始"
		elseif a[2] == 2 and a[4] == 0 then 
			e = e .. ",从2开始"
		end

		-- local man = ""
		-- if a[6] == 3 then 
		-- 	man = "，满3人开局"
		-- elseif a[6] == 6 then 
		-- 	man = "，满6人开局"
		-- end
		local f = ""
		if self.msgTbl.kFlag == 1 then
			f = f .. "3局"
		elseif self.msgTbl.kFlag == 2 then 
			f = f .. "5局"
		elseif self.msgTbl.kFlag == 3 then 
			f = f .. "7局"
		end

		-- local ptpye = ""
		-- if a[7] == 1 then 
		-- 	ptpye = ",轮流叫地主"
		-- elseif a[7] == 0 then
		-- 	ptpye = ",赢家叫地主"
		-- end 

		-- local tipai = ""
		-- if a[1] ~= 3 then 
		-- 	if a[8] == 1 then 
		-- 		tipai = ",可踢和回踢"
		-- 	end
		-- end


		--local txt = "升级"..(string.len(self.msgTbl.kDeskId) == 6 and "房号：" or "文娱馆桌号：")..(--[[self.data.kPlaytype[1] == 3 and "xxxxxx" or ]]self.msgTbl.kDeskId)..b.."缺"..self.m_kcurrent

		local  txt = 		"文娱馆桌号："..(--[[self.data.kPlaytype[1] == 3 and "xxxxxx" or ]]self.msgTbl.kDesksInfo[1][3]..",升级")..b.."，缺"..self.m_kcurrent

		-- local tifengding = ""
		-- if a[1] == 3 and a[10] == 1 then
		-- 	tifengding = ",踢和回踢算入封顶"
		-- end

	

		local g = ""
		if self.msgTbl.kGpsLimit == 1 then 
			g = g.."，【相邻位置禁止进入房间】"
		end

		local ruleText = f..b..c..d..e..g                                                                                                                      
	    local url = string.format(gt.HTTP_INVITE, gt.nickname, cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl","" ), self.msgTbl.kDesksInfo[1][3],  self.msgTbl.kDesksInfo[1][3], "文娱馆桌号："..(--[[self.data.kPlaytype[5] == 1 and "xxxxxx" or ]]self.msgTbl.kDesksInfo[1][3]).."，升级，"..ruleText)
	   	

	    gt.log(txt)
	    gt.log("_____________________\n")
	    gt.log(ruleText)

		Utils.shareURLToHY(url,txt,ruleText,function(ok)
			if ok == 0 then 
			 Toast.showToast(self, "分享成功", 2)
			end

			end)
	elseif self.msgTbl.kState == 107 then

		local a = self.msgTbl.kPlayType
	    local ruleText = ""



	    if self.msgTbl.kFlag == 1 then
	         ruleText = ruleText .. "8局，"
	    elseif self.msgTbl.kFlag == 2 then 
	        ruleText = ruleText .. "12局，"
	    elseif self.msgTbl.kFlag == 3 then 
	        ruleText = ruleText .. "20局，"
	    end
	   


        


	    local txt = "三打二, 文娱馆桌号："..(self.msgTbl.kDesksInfo[1][3]).."，缺"..self.m_kcurrent



	    ruleText = ruleText .. (a[1].."分场")..(a[2] == 1 and "，2是常主"or "")..(a[4] == 1 and "，对家要牌含10" or "").. (a[5] == 1 and "，三打二专属防作弊 ,满"..a[10].."人开局" or "")..(self.msgTbl.kAllowLookOn == 1 and ", 允许观战" or "") .. (self.msgTbl.kClubOwerLookOn == 1 and "，允许会长明牌观战" or "")


	    if self.msgTbl.kGpsLimit == 1 then 
	        ruleText = ruleText.."，【相邻位置禁止进入房间】"
	    end


	    if self.msgTbl.kPlayType[6] == 1 then 
	        ruleText = ruleText..", 允许主副同打（可选无主）"
	    else
	        ruleText = ruleText..", 不允许主副同打"
	    end


	    local url = string.format(gt.HTTP_INVITE, gt.nickname, cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl","" ),  self.msgTbl.kDesksInfo[1][3], ( "文娱馆桌号："..self.msgTbl.kDesksInfo[1][3]).."，三打二，"..ruleText)
	    



	    
	    gt.log(url)
	    gt.log(txt)
	    Utils.shareURLToHY(url,txt,ruleText,function(ok)
	        if ok == 0 then 
	        Toast.showToast(self, "分享成功", 2)
	        end

	        end)
	elseif self.msgTbl.kState == 109 then

		local a = self.msgTbl.kPlayType
	    local ruleText = ""



	    if self.msgTbl.kFlag == 1 then
	         ruleText = ruleText .. "8局，"
	    elseif self.msgTbl.kFlag == 2 then 
	        ruleText = ruleText .. "12局，"
	    elseif self.msgTbl.kFlag == 3 then 
	        ruleText = ruleText .. "20局，"
	    end
	   


        


	    local txt = "三打一, 文娱馆桌号："..(self.msgTbl.kDesksInfo[1][3]).."，缺"..self.m_kcurrent



	    ruleText = ruleText .. (a[1].."分场")..(a[2] == 1 and "，2是常主"or "")..(a[4] == 1 and "，对家要牌含10" or "").. (a[5] == 1 and "，三打一专属防作弊 ,满"..a[10].."人开局" or "")..(self.msgTbl.kAllowLookOn == 1 and ", 允许观战" or "") .. (self.msgTbl.kClubOwerLookOn == 1 and "，允许会长明牌观战" or "")


	    if self.msgTbl.kGpsLimit == 1 then 
	        ruleText = ruleText.."，【相邻位置禁止进入房间】"
	    end


	    local url = string.format(gt.HTTP_INVITE, gt.nickname, cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl","" ),  self.msgTbl.kDesksInfo[1][3], ( "文娱馆桌号："..self.msgTbl.kDesksInfo[1][3]).."，三打一，"..ruleText)
	    



	    
	    gt.log(url)
	    gt.log(txt)
	    Utils.shareURLToHY(url,txt,ruleText,function(ok)
	        if ok == 0 then 
	        Toast.showToast(self, "分享成功", 2)
	        end

	        end)



	elseif self.msgTbl.kState == 110 then
		local a = self.msgTbl.kPlayType
		local ruleText = ""
		if self.msgTbl.kFlag == 1 then
				ruleText = ruleText .. "8局，"
		elseif self.msgTbl.kFlag == 2 then 
			ruleText = ruleText .. "12局，"
		elseif self.msgTbl.kFlag == 3 then 
			ruleText = ruleText .. "20局，"
		end

		local txt = "五人百分, 文娱馆桌号："..(self.msgTbl.kDesksInfo[1][3]).."，缺"..self.m_kcurrent

		ruleText = ruleText .. (a[1].."分场")..(a[2] == 1 and "，2是常主"or "")..(a[4] == 1 and "，对家要牌含10" or "").. (a[5] == 1 and 
		"，五人百分专属防作弊 ,满"..a[10].."人开局" or "")..(self.msgTbl.kAllowLookOn == 1 and ", 允许观战" or "") .. (self.msgTbl.kClubOwerLookOn == 1 and "，允许会长明牌观战" or "")

		if self.msgTbl.kGpsLimit == 1 then 
			ruleText = ruleText.."，【相邻位置禁止进入房间】"
		end

		local url = string.format(gt.HTTP_INVITE, gt.nickname, cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl","" ),  
		self.msgTbl.kDesksInfo[1][3], ( "文娱馆桌号："..self.msgTbl.kDesksInfo[1][3]).."，五人百分，"..ruleText)
		
		gt.log(url)
		gt.log(txt)
		Utils.shareURLToHY(url,txt,ruleText,function(ok)
			if ok == 0 then 
			Toast.showToast(self, "分享成功", 2)
			end

			end)
	end

end



function ClubLayer:getRuleText(MsgTbl)

	gt.log("guize_________________")
	--gt.dump(MsgTbl)
	if MsgTbl.kState == 102 then 
		local a = MsgTbl.kPlayType 

		local ruleText = ""
		if MsgTbl.kGpsLimit == 1 then 
			ruleText = ruleText.."【相邻位置禁止进入房间】,"
		end
		local str = ""
		if MsgTbl.kFlag == 1 then 
			str = "10局，"
		elseif  MsgTbl.kFlag == 2 then 
			str = "20局，"
		elseif  MsgTbl.kFlag == 3 then 
			str = "16局，"
		end
		local fen = ""
		if a[3] == 3 or a[3] == 2 then 
				fen = a[3].."分场"
			elseif a[3] == 1 then
				fen = "1分(小)场"
			elseif a[3] == 4 then
				fen = "1分(大)场"
			end

		local strs = "经典玩法，"
		if tonumber(a[14]) == 1 then
			strs = "爽翻玩法，"
		end

		local s = ""
		if tonumber(a[15]) == 1 then
			s = "随时进出牌局,"
		end

		local t = ""
		if tonumber(a[16]) == 1 then
			t = "操作时间10秒,"
		elseif tonumber(a[16]) == 2 then
			t = "操作时间15秒,"
		elseif tonumber(a[16]) == 3 then
			t = "操作时间30秒,"
		end

		return "规则：赢三张，"..strs..s..t..(a[1] == 1 and "普通模式，" or "大牌模式，").. ("轮数:"..a[2])..("，"..fen)..(a[4]==0 and "，无必闷，" or "，闷"..a[4].."轮，")..(a[5]==1 and "豹子同花顺牌型加分," or "")..(a[6] == 1 and "可托管," or "")..(a[8]==1 and "倍开," or "")..(a[9]==1 and "天龙地龙," or "")..(a[10]==1 and "允许动态加入," or "")..(a[11]==1 and "可买小," or "")..(a[12]==1 and "买小时豹子可压所有牌型," or "")..ruleText..str..(MsgTbl.kFeeType == 1 and "玩家均摊" or "会长支付")
	elseif MsgTbl.kState == 103 then 
		local PlayType = MsgTbl.kPlayType

		local ruleText = ""
		if MsgTbl.kGpsLimit == 1 then 
			ruleText = ruleText.."【相邻位置禁止进入房间】,"
		end

		local content = ""
		if PlayType[2] == 0 then
			content = "普通模式1"
		elseif PlayType[2] == 1 then
			content = "普通模式2"
		elseif PlayType[2] == 2 then
			content = "扫雷模式"
		elseif PlayType[2] == 3 then
			content = "明牌下注"
		elseif PlayType[2] == 4 then
			content = "暗牌下注"
		end

	    local betscores = ""
	    if PlayType[1] == 0 then
	    	if PlayType[2] == 2 then
		    	if PlayType[8] == 0 then
		    		betscores = "小倍(1 2 3)"
		    	elseif PlayType[8] == 2 then
		    		betscores = "大倍(4 5 6)"
		    	end
	    	elseif PlayType[2] == 3 then
		    	if PlayType[8] == 0 then
		    		betscores = "小倍(2 3 4 5)"
		    	elseif PlayType[8] == 1 then
		    		betscores = "中倍(6 9 12 15)"
		    	elseif PlayType[8] == 2 then
		    		betscores = "大倍(5 10 20 30)"
		    	end
	    	elseif PlayType[2] == 4 then
		    	if PlayType[8] == 0 then
		    		betscores = "小倍(2 3 4 5)"
		    	elseif PlayType[8] == 1 then
		    		betscores = "中倍(6 9 12 15)"
		    	elseif PlayType[8] == 2 then
		    		betscores = "大倍(5 10 20 30)"
		    	end
	    	end
		elseif PlayType[1] == 1 then
	    	if PlayType[2] == 0 then
	    		betscores = "小倍(1 2 3)"
	    	elseif PlayType[2] == 1 then
		    	if PlayType[8] == 0 then
		    		betscores = "小倍(2 3 4 5)"
		    	elseif PlayType[8] == 1 then
		    		betscores = "中倍(6 9 12 15)"
		    	elseif PlayType[8] == 2 then
		    		betscores = "大倍(5 10 20 30)"
		    	end
	    	elseif PlayType[2] == 2 then
	    		betscores = "小倍(1 2 3)"
	    	end
		end

		return "规则：牛牛"
		..(MsgTbl.kFlag == 1 and "，10局" or "，20局")
		..(PlayType[6] == 6 and "，6人" or "，10人")
		.."，"..(PlayType[7] + 1).."倍"
		.."，"..content
		.."，"..betscores
		..(PlayType[1] == 0 and "，轮流坐庄" or "，看牌抢庄")
		..(PlayType[4] == 1 and "，托管" or "")
		..(PlayType[3] == 1 and "，花样玩法" or "")
		..(PlayType[9] == nil and "" or (PlayType[9] == 1 and "，牛牛4倍" or (PlayType[2] ~= 2 and "，牛牛3倍" or "")))
		..(PlayType[10] == nil and "" or (PlayType[10] == 0 and "" or "，"..PlayType[10].."倍推注"))
	elseif MsgTbl.kState == 101 then 

		local ruleText = "规则："

		

		local a = MsgTbl.kPlayType


		if a[1] == 1 then 
			ruleText = ruleText .. "经典玩法，"
		elseif a[1] == 2 then 
			ruleText = ruleText .. "带花玩法，"
		elseif a[1] == 3 then 
			ruleText = ruleText .. "临汾玩法，"
		end

		if MsgTbl.kFlag == 2 then
			 ruleText = ruleText .. "9局，"
		elseif MsgTbl.kFlag == 3 then 
			ruleText = ruleText .. "18局，"
		elseif MsgTbl.kFlag == 1 then 
			ruleText = ruleText .. "6局，"
		end

		local man = ""
		if a[6] == 3 then 
			man = "，满3人开局"
		elseif a[6] == 6 then 
			man = "，满6人开局"
		end

		local ptpye = ""
		if a[7] == 1 then 
			ptpye = ",轮流叫地主"
		elseif a[7] == 0 then
			ptpye = ",赢家叫地主"
		end 

		local tipai = ""
		if a[1] ~= 3 then 
			if a[8] == 1 then 
				tipai = ",可踢和回踢"
			end
		end
		ruleText = ruleText .. (a[2] == 2 and "暗牌（开牌后），" or "明牌（开牌后），").. (a[3] == 0 and  "不封顶，" or tostring(a[3]).."炸封顶，")..(a[4].."分场")..(a[5] == 1 and "，斗地主专属防作弊房"or "")..man..ptpye..tipai


		if MsgTbl.kGpsLimit == 1 then 
			ruleText = ruleText.."，【相邻位置禁止进入房间】"
		end

		return ruleText 
	elseif MsgTbl.kState == 106 then 

		local a = MsgTbl.kPlayType

		local b = ""

		if a[1] == 1 then 
			b = b .. "底分:1"
		elseif a[1] == 2 then 
			b = b .. "底分:2"
		elseif a[1] == 3 then 
			b = b .. "底分:3"
		end

		local c = ""
		if a[4] == 1 then 
			c = c .. "，2是常主"
		end

		local d = ""
		if a[3] == 1 then 
			d = d .. "，防作弊场"
		end

		local e = ""
		if a[2] == 1 then 
			e = e .. "，开始随机主"
		elseif a[2] == 2 and a[4] == 1 then
			e = e .. "，从3开始"
		elseif a[2] == 2 and a[4] == 0 then 
			e = e .. "，从2开始"
		end

		local f = ""
		if MsgTbl.kFlag == 1 then
			 f = f .. "，3局"
		elseif MsgTbl.kFlag == 2 then 
			f = f .. "，5局"
		elseif MsgTbl.kFlag == 3 then 
			f = f .. "，7局"
		end

		



		local g = ""
		if MsgTbl.kGpsLimit == 1 then 
			g = g.."，【相邻位置禁止进入房间】"
		end

		local h = ""
		if a[10] == 4 then 
			h = "，满4人开局"
		elseif a[10] == 8 then 
			h = "，满8人开局"
		end

		return "升级"..f..b..c..d..e..g..h
	elseif MsgTbl.kState == 107 then

		    local a = MsgTbl.kPlayType

		    gt.dump(MsgTbl)

		    local ruleText = "三打二，"



		    if MsgTbl.kFlag == 1 then
		         ruleText = ruleText .. "8局，"
		    elseif MsgTbl.kFlag == 2 then 
		        ruleText = ruleText .. "12局，"
		    elseif MsgTbl.kFlag == 3 then 
		        ruleText = ruleText .. "20局，"
		    end
		   

		    ruleText = ruleText .. (a[1].."分场")..(a[2] == 1 and "，2是常主"or "")..(a[4] == 1 and "，对家要牌含10" or "") .. (a[5] == 1 and "，三打二专属防作弊 ,满"..a[10].."人开局" or "") ..(MsgTbl.kAllowLookOn == 1 and ", 允许观战" or "") .. (MsgTbl.kClubOwerLookOn == 1 and "，允许会长明牌观战" or "")


		    if MsgTbl.kGpsLimit == 1 then 
		        ruleText = ruleText.."，【相邻位置禁止进入房间】"
		    end

		    if a[6] == 1 then 
		    	ruleText = ruleText..", 允许主副同打（可选无主）"
		    else
		    	ruleText = ruleText..", 不允许主副同打"
		    end

		    return ruleText
	elseif MsgTbl.kState == 109 then

		    local a = MsgTbl.kPlayType

		    gt.dump(MsgTbl)

		    local ruleText = "三打一，"



		    if MsgTbl.kFlag == 1 then
		         ruleText = ruleText .. "8局，"
		    elseif MsgTbl.kFlag == 2 then 
		        ruleText = ruleText .. "12局，"
		    elseif MsgTbl.kFlag == 3 then 
		        ruleText = ruleText .. "20局，"
		    end
		   

		    ruleText = ruleText .. (a[1].."分场")..(a[2] == 1 and "，2是常主"or "")..(a[4] == 1 and "，对家要牌含10" or "") .. (a[5] == 1 and "，三打一专属防作弊 ,满"..a[10].."人开局" or "") ..(MsgTbl.kAllowLookOn == 1 and ", 允许观战" or "") .. (MsgTbl.kClubOwerLookOn == 1 and "，允许会长明牌观战" or "")


		    if MsgTbl.kGpsLimit == 1 then 
		        ruleText = ruleText.."，【相邻位置禁止进入房间】"
		    end

			return ruleText
	elseif MsgTbl.kState == 110 then
		local a = MsgTbl.kPlayType
		gt.dump(MsgTbl)
		local ruleText = "五人百分，"

		if MsgTbl.kFlag == 1 then ruleText = ruleText .. "8局，"
		elseif MsgTbl.kFlag == 2 then  ruleText = ruleText .. "12局，"
		elseif MsgTbl.kFlag == 3 then  ruleText = ruleText .. "20局，"
		end
	   
		ruleText = ruleText .. (a[1].."分场")..(a[2] == 1 and "，2是常主"or "")..(a[4] == 1 and "，对家要牌含10" or "") .. 
		(a[6] == 1 and "，闲家干抠" or "") .. 
		(a[7] == 0 and "，庄家不交牌" or "") .. (a[7] == 1 and "，交牌8分" or "") .. (a[7] == 2 and  "，交牌12分" or "") ..
		(a[8] == 1 and "任意叫分都可选主花牌为副庄" or "")..
		(a[5] == 1 and "，五人百分专属防作弊 ,满"..a[10].."人开局" or "") ..(MsgTbl.kAllowLookOn == 1 and ", 允许观战" or "") .. 
		(MsgTbl.kClubOwerLookOn == 1 and "，允许会长明牌观战" or "")

		if MsgTbl.kGpsLimit == 1 then 
			ruleText = ruleText.."，【相邻位置禁止进入房间】"
		end
		
		return ruleText
	end

	return ""
end

function ClubLayer:onRcvLeaveClub(msgTbl)
	-- local runningScene = display.getRunningScene()
	-- gt.clubOnlineUserCount = msgTbl.kClubOnlineUserCount or {}
	-- if #gt.clubOnlineUserCount == 0 then
	-- 	runningScene.onlinePlayerCountImg:setVisible(false)
	-- else
	-- 	local clubOnlineUserCount = 0
	-- 	for i = 1, #gt.clubOnlineUserCount do
	-- 		clubOnlineUserCount = clubOnlineUserCount + gt.clubOnlineUserCount[i][2] or 0
	-- 	end
	-- 	runningScene.onlinePlayerCountImg:setVisible(true)
	-- 	runningScene.onlinePlayerCountLabel:setString(clubOnlineUserCount.."人在线")
	-- end
	if self.lookOnClubFlag then
		self.lookOnClubFlag = false
		self:getClubs()
	else
		self._exit = false
		self:removeFromParent()
	end
end

function ClubLayer:switch_node(msgTbl)
	if self.msgTbl and msgTbl and self.msgTbl.kState and  msgTbl.kState then 
		gt.log("state.....")
		gt.log(self.msgTbl.kState)
		gt.log(msgTbl.kState)

		self.msgTbl = msgTbl
			for i = 1, #msgTbl.kPlayTypeInfo do
				if msgTbl.kPlayTypeInfo[i][1] == msgTbl.kPlayTypeid then
					self.mahjongType = i
					
				end
			end
		self:UpdateTableListView(self.mahjongType)

		if self.msgTbl.kPlayType[7] ~= msgTbl.kPlayType[7] then 
			self.msgTbl = msgTbl
				for i = 1, #msgTbl.kPlayTypeInfo do
					if msgTbl.kPlayTypeInfo[i][1] == msgTbl.kPlayTypeid then
						self.mahjongType = i
						
					end
				end
			--log("switchh___________________")
			self:UpdateTableListView(self.mahjongType)
		end
	end
end

function ClubLayer:onRcvSwitchPlayScene(msgTbl)
		-- gt.dumploglogin("文娱馆界面切换玩法")
		-- gt.dumploglogin(msgTbl)
	if msgTbl.kErrorCode == 0 then
		gt.log("文娱馆界面切换玩法")
		--gt.dump(msgTbl)
		gt.log("-------------------onRcvSwitchPlayScene")

		if msgTbl.kState == 102 then 
			self.player_num = msgTbl.kPlayType[7]
			-- if self.tableListView then self.tableListView:setPositionX(290.00) end
			---- self.ddz_node:setVisible(false)
		elseif msgTbl.kState == 103 then 
			if msgTbl.kPlayType[6] == 6 then
				self.player_num = 6
			elseif msgTbl.kPlayType[6] == 10 then
				self.player_num = 10
			end
			-- if self.tableListView then self.tableListView:setPositionX(290.00) end
			---- self.ddz_node:setVisible(false)
		elseif msgTbl.kState == 101 then 
			self.player_num = 3

			

			if msgTbl.kPlayType[5] == 1 then 
				---- self.ddz_node:setVisible(true)
				-- if self.tableListView then self.tableListView:setPositionX(662.00) end
			else
				---- self.ddz_node:setVisible(false)
				-- if self.tableListView then self.tableListView:setPositionX(290.00) end
			end

		elseif msgTbl.kState == 107  then 

		elseif msgTbl.kState == 109  then 


		end

		self:switch_node(msgTbl)
		
		if self.msgTbl ~= msgTbl then self.msgTbl = msgTbl end

		local isaction = false
		if msgTbl.kState == 107 then

			for i = 1 , #msgTbl.kDesksInfo do
			
				if self.tables[i] and not tolua.isnull(self.tables[i]) and  gt.seekNodeByName( self.tables[i],"gz_ing" ) and msgTbl.kDesksInfo[i] then 
					
					  gt.seekNodeByName( self.tables[i],"gz_ing" ):setVisible( msgTbl.kDesksInfo[i][7] == 1 )
					  if msgTbl.kDesksInfo[i][7] == 1 then 
					  	gt.seekNodeByName( self.tables[i],"gz_ing" ):getChildByName("dian"):runAction( cc.RepeatForever:create(cc.Blink:create(2, 2)))
					  	isaction = true
					  else
					  	gt.seekNodeByName( self.tables[i],"gz_ing" ):getChildByName("dian"):stopAllActions()
					  end
				end
			end
		elseif msgTbl.kState == 110 then

			for i = 1 , #msgTbl.kDesksInfo do
			
				if self.tables[i] and not tolua.isnull(self.tables[i]) and  gt.seekNodeByName( self.tables[i],"gz_ing" ) and msgTbl.kDesksInfo[i] then 
					
					  gt.seekNodeByName( self.tables[i],"gz_ing" ):setVisible( msgTbl.kDesksInfo[i][7] == 1 )
					  if msgTbl.kDesksInfo[i][7] == 1 then 
					  	gt.seekNodeByName( self.tables[i],"gz_ing" ):getChildByName("dian"):runAction( cc.RepeatForever:create(cc.Blink:create(2, 2)))
					  	isaction = true
					  else
					  	gt.seekNodeByName( self.tables[i],"gz_ing" ):getChildByName("dian"):stopAllActions()
					  end
				end
			end

		end

		if msgTbl.kState == 109 then

			for i = 1 , #msgTbl.kDesksInfo do
			
				if self.tables[i] and not tolua.isnull(self.tables[i]) and  gt.seekNodeByName( self.tables[i],"gz_ing" ) and msgTbl.kDesksInfo[i] then 
					
					  gt.seekNodeByName( self.tables[i],"gz_ing" ):setVisible( msgTbl.kDesksInfo[i][7] == 1 )
					  if msgTbl.kDesksInfo[i][7] == 1 then 
					  	gt.seekNodeByName( self.tables[i],"gz_ing" ):getChildByName("dian"):runAction( cc.RepeatForever:create(cc.Blink:create(2, 2)))
					  	isaction = true
					  else
					  	gt.seekNodeByName( self.tables[i],"gz_ing" ):getChildByName("dian"):stopAllActions()
					  end
				end
			end

		end

		if isaction then 
			self.g_z:getChildByName("sj"):stopAllActions()
			self.g_z:getChildByName("sj"):setVisible(true)
		else
			self.g_z:getChildByName("sj"):runAction( cc.RepeatForever:create(cc.Blink:create(2, 2)))
		end

		--self.clubId = self.msgTbl.kClubId
		if msgTbl.kClubName then
			if self.clubNameLabel then
				self.clubNameLabel:setString(msgTbl.kClubName)
				-- self.clubInfoBtn:setPositionX(self.clubNameLabel:getPositionX()+self.clubNameLabel:getContentSize().width/2+30)
			end
		end
		if self.switchPlaySceneFlag then
			gt.removeLoadingTips()
			gt.log("++++++=======")
			self.msgTbl = msgTbl
			self.playTypeInfo = msgTbl.kPlayTypeInfo
			for i = 1, #msgTbl.kPlayTypeInfo do
				if msgTbl.kPlayTypeInfo[i][1] == msgTbl.kPlayTypeid then
					self.mahjongType = i
					self.kPlayTypeid = msgTbl.kPlayTypeid
				end
			end

			self:UpdatePlayTypeListView()

			self.playType = self.mahjongType

			if self.refreshTableListFlag then
				if self and self.updateClubTableItemData2 then
					table.insert(self.updateClubTableItemData2, msgTbl)
				end
			else
				if self and self.updateClubTableItemData1 then
					table.insert(self.updateClubTableItemData1, msgTbl)
					self.refreshTableListFlag = true
					self:refreshTableList1()
				end
			end

			if self.tableListView then self.tableListView:jumpToLeft() end
		else
			if self.refreshTableListFlag then
				if self and self.updateClubTableItemData2 then
					table.insert(self.updateClubTableItemData2, msgTbl)
				end
			else
				if self and self.updateClubTableItemData1 then
					table.insert(self.updateClubTableItemData1, msgTbl)
					self.refreshTableListFlag = true
					self:refreshTableList1()
				end
			end
		end

		self.switchPlaySceneFlag = false
	elseif msgTbl.kErrorCode == 2 then
		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "该文娱馆还没有创建玩法！", nil, nil, true)
		self:removeFromParent()
	end
end

--获取文娱馆会员信息
function ClubLayer:getClubPersonInfo(m_userId)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local getClubPlayerInfoURL = gt.getUrlEncryCode(string.format(gt.clubPlayerInfo, m_userId, self.clubId), gt.playerData.uid)
	print("------------getClubPlayerInfoURL", getClubPlayerInfoURL)
	xhr:open("GET", getClubPlayerInfoURL)
	local function onResp()
		gt.removeLoadingTips()
		if self then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				gt.dump(xhr.response)
				-- gt.dumploglogin("------------getClubPlayerInfoURLSUCCESS")
		 		local cjson = require "cjson"
				local ret = cjson.decode(xhr.response)
				if ret.errno == 0 then
					local ClubPersonalCenter = require("client/game/club/ClubPersonalCenter"):create(ret.data.user)
					self:addChild(ClubPersonalCenter, ClubLayer.ZOrder.PLAYER_INFO_TIPS)
				else
					require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), ret.errmsg, nil, nil, true)
				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function ClubLayer:onRcvClubDeskInfo(msgTbl)
	if self.msgTbl and self.msgTbl.kDesksInfo then
		local ShowDeskId
		for k, v in pairs(self.msgTbl.kDesksInfo) do
			if tonumber(v[3]) == tonumber(msgTbl.kShowDeskId) then
				ShowDeskId = k
			end
		end
	
	    -- 当前局数
	    if self.circleNode and self.circleNode[ShowDeskId] then
			self.circleNode[ShowDeskId]:setVisible(false)
		end
	    -- 已满员
	    if self.fullImg and self.fullImg[ShowDeskId] then
			self.fullImg[ShowDeskId]:setVisible(false)
		end
		if msgTbl.kRoomFull == 1 then
	    	if self.lookOnBtn and self.lookOnBtn[ShowDeskId] then
				self.lookOnBtn[ShowDeskId]:setVisible(true)
			end
			if msgTbl.kCurrCircle == 0 then
			    -- 已满员
	    		if self.fullImg and self.fullImg[ShowDeskId] then
					self.fullImg[ShowDeskId]:setVisible(true)
				end
			else
	    		if self.circleNode and self.circleNode[ShowDeskId] then
					self.circleNode[ShowDeskId]:setVisible(true)
				end
	    		if self.circleAtlasLabel and self.circleAtlasLabel[ShowDeskId] then
	    			self.circleAtlasLabel[ShowDeskId]:setVisible(true)
					self.circleAtlasLabel[ShowDeskId]:setString(msgTbl.kCurrCircle.."/"..msgTbl.kTotalCircle)
				end
			end
			--if self.msgTbl and self.msgTbl.kState == 107 and self.joinRoomBtn and self.joinRoomBtn[ShowDeskId]  then
			if self.msgTbl and (self.msgTbl.kState == 107 or self.msgTbl.kState == 109 or self.msgTbl.kState == 110) and self.joinRoomBtn and self.joinRoomBtn[ShowDeskId]  then
				self.joinRoomBtn[ShowDeskId]:setEnabled(true)
				if self.msgTbl.kPlayType[5] == 1 and self.joinRoomBtn[ShowDeskId]:getParent() and self.joinRoomBtn[ShowDeskId]:getParent():getChildByName("look_6") then 
					self.joinRoomBtn[ShowDeskId]:getParent():getChildByName("look_6"):setVisible(true)
				end
			end
		else
		    if self.lookOnBtn and self.lookOnBtn[ShowDeskId] then
				self.lookOnBtn[ShowDeskId]:setVisible(false)
			end
			--if self.msgTbl and self.msgTbl.kState == 107 and self.joinRoomBtn and self.joinRoomBtn[ShowDeskId]  then
			if self.msgTbl and (self.msgTbl.kState == 107 or self.msgTbl.kState == 109 or self.msgTbl.kState == 110) and self.joinRoomBtn and self.joinRoomBtn[ShowDeskId]  then
				self.joinRoomBtn[ShowDeskId]:setEnabled(false)
				if self.msgTbl.kPlayType[5] == 1 and self.joinRoomBtn[ShowDeskId]:getParent() and self.joinRoomBtn[ShowDeskId]:getParent():getChildByName("look_6") then 
					self.joinRoomBtn[ShowDeskId]:getParent():getChildByName("look_6"):setVisible(false)
				end
			end
		end

		if self.dissolveBtn and self.dissolveBtn[ShowDeskId] then
		    if self.presidentid == gt.playerData.uid then
				--if #cellData[2] == 0 then
				--else
				self.dissolveBtn[ShowDeskId]:setVisible(true)
				--end
		    else
		    	self.dissolveBtn[ShowDeskId]:setVisible(false)
		    end
	    end
	end
end

function ClubLayer:onRcvClubDeskPlayerInfo( msgTbl )
	-- gt.dumploglogin("刷新文娱馆桌子信玩家息")
	-- gt.dumploglogin(msgTbl)
	--推送桌子玩家数据
	if self.refreshClubDeskPlayerInfoFlag then
		if self and self.updateClubDeskPlayerInfoData2 then
			table.insert(self.updateClubDeskPlayerInfoData2, msgTbl)
		end
	else
		if self and self.updateClubDeskPlayerInfoData1 then
			table.insert(self.updateClubDeskPlayerInfoData1, msgTbl)
			self.refreshClubDeskPlayerInfoFlag = true
			self:refreshClubDeskPlayerInfo1()
		end
	end
end

function ClubLayer:updateClubDeskPlayerInfoItem(i, cellData, playType)
    -- 玩家头像按钮东南西北
	for j = 1, self.player_num do
		if self.headFrameBtn and self.headFrameBtn[i] and self.headFrameBtn[i][j] then
			self.headFrameBtn[i][j]:setVisible(false)
		end
    	if self.seatBtn and self.seatBtn[i] and self.seatBtn[i][j] then
			self.seatBtn[i][j]:setVisible(true)
		end
	end
	for j, userCellData in ipairs(cellData) do
	    if userCellData and userCellData[3] and userCellData[3] < self.player_num then
	    	local position = userCellData[3] +1
	    	if self.headFrameBtn and self.headFrameBtn[i] and self.headFrameBtn[i][position] and not tolua.isnull(self.headFrameBtn[i][position]) then
				self.headFrameBtn[i][position]:setVisible(true)
			end
	    	if self.seatBtn and self.seatBtn[i] and self.seatBtn[i][position] then
				self.seatBtn[i][position]:setVisible(false)
			end
	    	if self.headSpr and self.headSpr[i] and self.headSpr[i][position] 
	    		and self.headFrameBtn and self.headFrameBtn[i] and self.headFrameBtn[i][position] and not tolua.isnull(self.headFrameBtn[i][position]) then
	    		local headFile = "res/images/sx_club_play/sx_club_play_head.png"
   				self.headSpr[i][position]:setVisible(true)

   				if self.player_num == 5 or self.player_num == 6 or self.player_num == 10 or  self.player_num == 8 or self.player_num == 4 then 

   					local url = userCellData[1]
   					self.headSpr[i][position]:setVisible(false)
   					
   					local node = "zjhclub/icon.png"
   					local image = gt.imageNamePath(url)
   					if self.headFrameBtn[i][position]:getChildByName("_ICON__"..i..position) then 
   						gt.log("remove______________")
   						self.headFrameBtn[i][position]:getChildByName("_ICON__"..i..position):removeFromParent()
   					end
   					if image then 
						local node = cc.Sprite:create("zjhclub/icon.png")
						node:retain()
						local im = gt.clippingImage(image,node,false)
						node:release()
						self.headFrameBtn[i][position]:addChild(im)
						im:setPosition(self.headSpr[i][position]:getPosition())
						im:setName("_ICON__"..i..position)
   					else
   						local function callback(args)
   							if  self._exit and  self and args.done and i and position  and self.headFrameBtn[i][position] and not tolua.isnull(self.headFrameBtn[i][position]) then 
   								local node = cc.Sprite:create("zjhclub/icon.png")
   								node:retain()
   								local image = gt.clippingImage(args.image,node,false)
   								node:release()

   								self.headFrameBtn[i][position]:addChild(image)
   								image:setPosition(self.headSpr[i][position]:getPosition())
   								image:setName("_ICON__"..i..position)
   							end
   						end
   						gt.downloadImage(url,callback)
   					end



   				elseif self.player_num == 3 then 

   					if self.msgTbl.kPlayType[5] == 1 then 

   						gt.log("icon_______________")
	   					if self.icon and self.icon[i] and self.icon[i][position] then
	   						gt.log("icon___________________ss")
	   						self.icon[i][position]:loadTexture("zjhclub/unkonwn.png")
	   						if self.presidentid == gt.playerData.uid then
	   							self.icon[i][position]:setTouchEnabled(true)
	   							self.moveHeadFrameBtn[i][position] = {}
								self.moveHeadFrameBtn[i][position].beganPositionX = 0
								self.moveHeadFrameBtn[i][position].endedPositionX = 0
								self.moveHeadFrameBtn[i][position].tag = self.icon[i][position]:getTag()
		   						self.icon[i][position]:addTouchEventListener(function(sender, eventType)
		   							if eventType == ccui.TouchEventType.began then
							            self.moveHeadFrameBtn[i][position].movedCount = 0
							        elseif eventType == ccui.TouchEventType.ended then
							        	self.moveHeadFrameBtn[i][position].endedPositionX= sender:getTouchMovePosition().x
							        	if math.abs(self.moveHeadFrameBtn[i][position].endedPositionX - self.moveHeadFrameBtn[i][position].beganPositionX) < 10 then
											gt.soundEngine:playEffect("common/audio_button_click", false)
											local tag = sender:getTag()
							                local m_userId = 0
							                -- gt.log("self.msgTbl.kDesksInfo=============")
							                -- gt.dump(self.msgTbl.kDesksInfo)
							                local userCellData = 1
							                if self.msgTbl.kDesksInfo[i][2] then
												-- for j, userCellData in ipairs(self.msgTbl.kDesksInfo[i][2]) do
		          --       							if self.moveHeadFrameBtn[j][position].tag == tag then
		          -- --       								gt.log("tag===",tag)
							     --            			m_userId = userCellData[position]
							     -- --            		end
												-- end
												local userData = self.msgTbl.kDesksInfo[i][2]
												for j=1,#userData do
													if self.moveHeadFrameBtn[j][position].tag == tag then
														gt.log("tag=====",tag)
														m_userId = userData[position][3]
													end
												end
							                end
											self:getClubPersonInfo(m_userId)
							            end     
							        elseif eventType == ccui.TouchEventType.moved then
							            self.moveHeadFrameBtn[i][position].movedCount = self.moveHeadFrameBtn[i][position].movedCount + 1
							        	if self.moveHeadFrameBtn[i][position].movedCount == 1 then
							        		self.moveHeadFrameBtn[i][position].beganPositionX = sender:getTouchMovePosition().x
								        end
							        end
		   						end)
	   						else
		   						self.icon[i][position]:setTouchEnabled(false)
	   						end

	   					end

	   					--for j = 1 , self.player_num do
							self.headFrameBtn[i][position]:setVisible(false)
							self.headFrameBtn[i][position]:setEnabled(false)
							self.seatBtn[i][position]:setVisible(false)
							self.seatBtn[i][position]:setEnabled(false)
							self.icon[i][position] = gt.seekNodeByName(self.userNode[i][j],"icon")
											  :setVisible(true)
							--self.icon[i][j]:loadTexture("ddz/zjhclub/tmp.png")

						--end

	   				else

	   					local url = userCellData[1]
	   					self.headSpr[i][position]:setVisible(false)
	   					
	   					local node = "zjhclub/icon.png"
	   					local image = gt.imageNamePath(url)
	   					if self.headFrameBtn[i][position]:getChildByName("_ICON__"..i..position) then 
	   						gt.log("remove______________")
	   						self.headFrameBtn[i][position]:getChildByName("_ICON__"..i..position):removeFromParent()
	   					end
	   					if image then 
							local node = cc.Sprite:create("zjhclub/icon.png")
							node:retain()
							local im = gt.clippingImage(image,node,false)
							node:release()
							self.headFrameBtn[i][position]:addChild(im)
							im:setPosition(self.headSpr[i][position]:getPosition())
							im:setName("_ICON__"..i..position)
	   					else
	   						local function callback(args)
	   							if  self._exit and self and args.done and self.headFrameBtn[i][position] and not tolua.isnull(self.headFrameBtn[i][position]) then 
	   								local node = cc.Sprite:create("zjhclub/icon.png")
	   								node:retain()
	   								
	   								local image = gt.clippingImage(args.image,node,false)
	   								node:release()

	   								self.headFrameBtn[i][position]:addChild(image)
	   								image:setPosition(self.headSpr[i][position]:getPosition())
	   								image:setName("_ICON__"..i..position)
	   							end
	   						end
	   						gt.downloadImage(url,callback)
	   					end

   					end

	   					-- 头像下载管理器
					-- local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
					-- playerHeadMgr:detach(self.headSpr[i][position])
					-- playerHeadMgr:attach(self.headSpr[i][position], self.headFrameBtn[i][position], userCellData[2], userCellData[1], nil, nil, 97, true, headFile)
					-- self:addChild(playerHeadMgr)
   				end
				
				
			end
	    end
	end
end

-- 刷新所有桌子玩家状态表1
function ClubLayer:refreshClubDeskPlayerInfo1()
	local removeCount = 0
	for i = 1, #self.updateClubDeskPlayerInfoData1 do
		local ClubTableItemData = self.updateClubDeskPlayerInfoData1[i]
		for i, cellData in ipairs(ClubTableItemData.kDeskInfo) do
			self:updateClubDeskPlayerInfoItem(cellData[1], cellData[2], self.playType)
		end
		removeCount = removeCount + 1
	end

	for i = 1, removeCount do 
		table.remove(self.updateClubDeskPlayerInfoData1, 1)
	end

	if #self.updateClubDeskPlayerInfoData1 > 1 then
		self:refreshClubDeskPlayerInfo1()
	end

	self:refreshClubDeskPlayerInfo2()
end

-- 刷新所有桌子玩家状态表2
function ClubLayer:refreshClubDeskPlayerInfo2()
	local removeCount = 0
	for i = 1, #self.updateClubDeskPlayerInfoData2 do
		local ClubTableItemData = self.updateClubDeskPlayerInfoData2[i]
		for i, cellData in ipairs(ClubTableItemData.kDeskInfo) do
			self:updateClubDeskPlayerInfoItem(cellData[1], cellData[2], self.playType)
		end
		removeCount = removeCount + 1
	end
	
	for i = 1, removeCount do 
		table.remove(self.updateClubDeskPlayerInfoData2, 1)
	end

	if #self.updateClubDeskPlayerInfoData2 > 1 then
		self:refreshClubDeskPlayerInfo2()
	end
	
	self.refreshClubDeskPlayerInfoFlag = false
end

--获取文娱馆公告
function ClubLayer:getClubPublic(showNew)
	if showNew then
		local xhr = cc.XMLHttpRequest:new()
		xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
		local getClubPublicURL = gt.getUrlEncryCode(string.format(gt.clubPublic, self.clubId), gt.playerData.uid)
		print("------------getClubPublicURL", getClubPublicURL)
		xhr:open("GET", getClubPublicURL)
		local function onResp()
			if self then
				if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				--	dump(xhr.response)
			 		local cjson = require "cjson"
					local ret = cjson.decode(xhr.response)
					if ret.errno == 0 then
						if ret.data.club.notice and ret.data.club.notice ~= "" then
							if self.marqueeMsg then
								self.marqueeMsg:showMsg(ret.data.club.notice)
							end
							local oldclubnotice = cc.UserDefault:getInstance():getStringForKey("clubnotice"..tostring(self.clubId)..tostring(gt.playerData.uid), "")
							self.clubdata = ret.data.club
							if ret.data.club.notice ~= oldclubnotice then
							  	local layer = require("client/game/club/ClubNotice"):create(ret.data.club)
							  	self:addChild(layer, 999)
							end
			   				cc.UserDefault:getInstance():setStringForKey("clubnotice"..tostring(self.clubId)..tostring(gt.playerData.uid), ret.data.club.notice)
						end
					else
						require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), ret.errmsg, nil, nil, true)
					end
				elseif xhr.readyState == 1 and xhr.status == 0 then
				end
			end
			xhr:unregisterScriptHandler()
		end
		xhr:registerScriptHandler(onResp)
		xhr:send()
	else
		if self.clubdata then
		  	local layer = require("client/game/club/ClubNotice"):create(self.clubdata)
		  	self:addChild(layer, 999)
		end
	end
end

--获取文娱馆信息
function ClubLayer:getClubInfo()
	gt.showLoadingTips(gt.getLocationString("LTKey_0055"))
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local getClubsURL = gt.getUrlEncryCode(string.format(gt.getClubs, 1), gt.playerData.uid)
	print("------------getClubsURL", getClubsURL)
	xhr:open("GET", getClubsURL)
	local function onResp()
		gt.removeLoadingTips()
		if self then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
		 		local cjson = require "cjson"
				local ret = cjson.decode(xhr.response)
				-- dump(ret)
				if ret.errno == 0 then
					if ret.data.clubs then
						for i = 1, #ret.data.clubs do
							gt.log("--------------self.clubId", self.clubId)
							if ret.data.clubs[i].club_no == self.clubId then				
							   	if self then
									local ClubDetail = require("client/game/club/ClubDetail"):create(ret.data.clubs[i], function ( )
										-- 发送离开文娱馆消息
										local msgToSend = {}
										msgToSend.kMId = gt.CG_LEAVE_CLUB
										msgToSend.kClubId = self.clubId
										if self.msgTbl and self.msgTbl.kPlayTypeInfo and self.msgTbl.kPlayTypeInfo[self.mahjongType] and self.msgTbl.kPlayTypeInfo[self.mahjongType][1] then
											msgToSend.kPlayTypeid = self.msgTbl.kPlayTypeInfo[self.mahjongType][1]
										else
											msgToSend.kPlayTypeid = self.kPlayTypeid
										end
										gt.socketClient:sendMessage(msgToSend)
									end)
									self:addChild(ClubDetail, ClubLayer.ZOrder.PLAYER_INFO_TIPS)
							   	end
							end
						end
					end
				else
					require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), ret.errmsg, nil, nil, true)
				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

--获取加入文娱馆列表
function ClubLayer:getClubs()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local getClubsURL = gt.getUrlEncryCode(string.format(gt.getClubs, 1), gt.playerData.uid)
	print("------------getClubsURL", getClubsURL)
	xhr:open("GET", getClubsURL)
	local function onResp()
		gt.removeLoadingTips()
		if self then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				-- dump(xhr.response)
		 		local cjson = require "cjson"
				local ret = cjson.decode(xhr.response)
				if ret.errno == 0 then
					if ret.data.clubs and #ret.data.clubs > 0 then
						local runningScene = cc.Director:getInstance():getRunningScene()
						if runningScene:getChildByName("JoinClub") == nil then
							local JoinClub = require("client/game/club/JoinClub"):create(2, ret.data.clubs)
							JoinClub:setName("JoinClub")
							runningScene:addChild(JoinClub, ClubLayer.ZOrder.CREATE_ROOM)
						end
						self:removeFromParent()
					end
				else
					require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), ret.errmsg, nil, nil, true)
				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function ClubLayer:onRcvClubScene(msgTbl)
	gt.dumploglogin("文娱馆界面内容")
	gt.dumploglogin(msgTbl.kErrorCode)
	self.enterClubFlag = true
	gt.removeLoadingTips()
	if msgTbl.kErrorCode == 0 then
		if self.showLayerFlag then
			self.rootNode:setVisible(true)
		end
		gt.log("文娱馆界面内容")
		gt.dump(msgTbl)

		self.player_num = (msgTbl.kState == 102 and msgTbl.kPlayType[7] or (msgTbl.kState == 103 and (msgTbl.kPlayType[6] == 6 and 6 or 10) or 4))

		if msgTbl.kState == 101 then self.player_num = 3 end

		self.presidentid = msgTbl.kPresidentid
		--self.presidentid = 1004724
		 --self.presidentid = gt.playerData.uid


		self.kClubId = msgTbl.kClubId


		self.updateClubTableItemData1 = {}
		self.updateClubTableItemData2 = {}

		self.refreshTableListFlag = false

		self.updateClubDeskPlayerInfoData1 = {}
		self.updateClubDeskPlayerInfoData2 = {}

		self.refreshClubDeskPlayerInfoFlag = false

	 	self.msgTbl = msgTbl or {}

		self.clubId = clone(msgTbl.kClubId)
		self.playTypeInfo = msgTbl.kPlayTypeInfo

		for i = 1, #msgTbl.kPlayTypeInfo do
			if msgTbl.kPlayTypeInfo[i][1] == msgTbl.kPlayTypeid then
				self.mahjongType = i
				self.kPlayTypeid = msgTbl.kPlayTypeid
			end
		end
		
		self:setClubInfo()

		self:getClubPublic(true)

		-- if self.playTypeId > 1 then
		-- 	gt.log("-------------------文娱馆界面默认玩法", msgTbl.kPlayTypeid)
		-- 	self.switchPlaySceneFlag = true
		-- 	gt.showLoadingTips(gt.getLocationString("LTKey_0054"))
		--     -- 文娱馆界面默认玩法
		-- 	local msgToSend = {}
		-- 	msgToSend.kMId = gt.CG_SWITCH_PLAY_SCENE
		-- 	msgToSend.kClubId = self.clubId
		-- 	msgToSend.kSwitchToType = msgTbl.kPlayTypeInfo[self.playTypeId][1]
		-- 	msgToSend.kCurrPlayType = msgTbl.kPlayTypeid
		-- 	gt.socketClient:sendMessage(msgToSend)
		-- end

		gt.clubId = 0

		self.switchPlaySceneFlag = true
		gt.showLoadingTips(gt.getLocationString("LTKey_0057"))
		-- 文娱馆界面刷新玩法
		local msgToSend = {}
		msgToSend.kMId = gt.CG_SWITCH_PLAY_SCENE
		msgToSend.kClubId = self.clubId
		msgToSend.kCurrPlayType = self.msgTbl.kPlayTypeInfo[self.mahjongType][1] or 1
		msgToSend.kSwitchToType = self.msgTbl.kPlayTypeInfo[self.mahjongType][1] or 1
		gt.socketClient:sendMessage(msgToSend)
		-- gt.dumploglogin("文娱馆界面刷新玩法")
		-- gt.dumploglogin(msgToSend)
	elseif msgTbl.kErrorCode == 1 then
		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "您还没有加入文娱馆！", nil, nil, true)
		self:removeFromParent()
	elseif msgTbl.kErrorCode == 2 then
		require("client/game/dialog/NoticeTipsClub"):create(gt.getLocationString("LTKey_0007"), "文娱馆正在建设中！", nil, nil, true)
		self:removeFromParent()
	elseif msgTbl.kErrorCode == 3 then
		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "文娱馆未找到！", nil, nil, true)
		self:removeFromParent()
	else
		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), msgTbl.kErrorCode, nil, nil, true)
		self:removeFromParent()
	end
end



function ClubLayer:show_wait(m)
	gt.log("c____________")
	gt.dump(m)
	if m.kErrorCode == 0 then 
		gt.log("wait______________________________")
		self.wait_room:setVisible(true)

		self.wait_room:getChildByName("Node_1"):setVisible(m.kMaxmax == 6)
		self.wait_room:getChildByName("Node_2"):setVisible(m.kMaxmax == 3)
		self.wait_room:getChildByName("Node_3"):setVisible(m.kMaxmax == 4)
		self.wait_room:getChildByName("Node_4"):setVisible(m.kMaxmax == 8)
		self.wait_room:getChildByName("Node_5"):setVisible(m.kMaxmax == 5)
		self.wait_room:getChildByName("Node_6"):setVisible(m.kMaxmax == 10)
		local icon = nil
		local node = nil
		for i = 1 , 6 do if self.wait_room:getChildByName("Node_"..i):isVisible() then node = self.wait_room:getChildByName("Node_"..i) end end
		icon = node:getChildByName("wait_i_2")
		for i = 2 , m.kcurrent do 
			node:getChildByName("Image_"..i):loadTexture("ddz/wait_icon1.png")
		end
		for i =m.kcurrent + 1 , m.kMaxmax do 
			node:getChildByName("Image_"..i):loadTexture("ddz/wait_icon.png")
		end

		if m.kcurrent ==  m.kMaxmax  then  
		   self.wait_room:setVisible(false) 
		   if gt.seekNodeByName(self.rootNode,"FileNode") then 
		   		gt.seekNodeByName(self.rootNode,"FileNode"):setVisible(true)
		   else
		        require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "人数已满开始随机分配桌子！", nil, nil, true)
		   end
			--gt.showLoadingTips("正在进入房间中...")
		end
		self.m_kcurrent = m.kMaxmax - m.kcurrent
		local time = m.kTime
		if tonumber(time) < 0 then time = 0 end
		self.wait_room:getChildByName("Text_23"):setString(m.kcurrent.."/"..m.kMaxmax)
		self.wait_room:getChildByName("Text_23_1"):setString(tostring(time).."秒")
		
			
			if self.wait_clock  then  gt.scheduler:unscheduleScriptEntry(self.wait_clock) self.wait_clock = nil end
			self.wait_clock = gt.scheduler:scheduleScriptFunc(function(dt)
				self.wait_room:getChildByName("Text_23_1"):setString(tostring(time).."秒")
				time = time -1
				if time <= 0 then time = 0 
					self.wait_room:getChildByName("Text_23_1"):setString("0".."秒")
					if self.wait_clock  then 
					 	 gt.scheduler:unscheduleScriptEntry(self.wait_clock) self.wait_clock = nil 
					end
				end
			end,1,false)
		
		if not node:getChildByName("WAIT_ICON__") then 
			local url = cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl","")
			--local url = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"
			if string.len(url) > 10 and  node and icon  then  
				local image =  gt.imageNamePath(url)
				if image then 
					local nodes = cc.Sprite:create("ddz/wait_i.png")
					nodes:retain()
					local im = gt.clippingImage(image,nodes,false)
					nodes:release()
					node:addChild(im)
					im:setPosition(icon:getPosition())
					im:setName("WAIT_ICON__")
					icon:setVisible(false)
				else
					local function callback(args)

						if  self._exit and self and args.done and node and not tolua.isnull(node) then 
							local nodes = cc.Sprite:create("ddz/wait_i.png")
							nodes:retain()
							local image = gt.clippingImage(args.image,nodes,false)
							nodes:release()

							node:addChild(image)
							image:setPosition(icon:getPosition())
							image:setName("WAIT_ICON__")
							icon:setVisible(false)
						end
					end
					gt.downloadImage(url,callback)
				end
			end
		end
	else

		local name = {"","","","","","","","","",""}
		local long = {"","","","","","","","","",""}
		local lan  = {"","","","","","","","","",""}
		local checkMapUrl = ""
		local player = string.split(m.kUserGPSList, "|")
		for i = 1 , #player do
			local data = string.split(player[i],",")
			name[i] = "匿名"
			long[i] = data[2]
			lan[i] = data[3]
		end
		if #player >=1 then 
			checkMapUrl = 	gt.getUrlEncryCode(string.format(gt.CheckMapUrl, name[1], long[1], lan[1],name[2], long[2], lan[2],name[3], long[3], lan[3],name[4], long[4], lan[4],name[5], long[5], lan[5],name[6], long[6], lan[6]
				,name[7], long[7], lan[7]
				,name[8], long[8], lan[8]
				,name[9], long[9], lan[9]
				,name[10], long[10], lan[10]), gt.playerData.uid)

			if gt.isIOSPlatform() then
				local ok = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "NativeStartMap", {mapUrl = checkMapUrl, notice = ""})
				local _scene = display.getRunningScene()
				if _scene then 
					Toast.showToast(_scene, "抱歉，您无法入座，有已入座玩家与您距离过近!", 2)
				end
			elseif gt.isAndroidPlatform() then
				require("client/game/common/mapView"):create(checkMapUrl,1)
			end

		end


	end
end

function ClubLayer:hide_wait(m)
	
	if m.kErrorCode == 0 then 
		if m.kType == 1 then 
				local scene = display.getRunningScene()
				if scene then 
					Toast.showToast(scene, "倒计时结束，人数未满，自动退出等待！", 1)
				end
		else
				local scene = display.getRunningScene()
				if scene then 
					Toast.showToast(scene, "您已退出等待", 1)
				end
		end
		self.wait_room:setVisible(false)
	
		for i = 2, 6 do
			local node = self.wait_room:getChildByName("Node_1")
			node:getChildByName("Image_"..i):loadTexture("ddz/wait_icon.png")
			node:getChildByName("wait_i_2"):setVisible(true)
		end
		
		for i = 2 ,3 do
			local node = self.wait_room:getChildByName("Node_2")
			node:getChildByName("Image_"..i):loadTexture("ddz/wait_icon.png")
			node:getChildByName("wait_i_2"):setVisible(true)
		end
		self.wait_room:removeChildByName("WAIT_ICON__")
		if self.wait_clock  then gt.scheduler:unscheduleScriptEntry(self.wait_clock) self.wait_clock = nil end

	else

	end



end

return ClubLayer


