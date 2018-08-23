
local ApplyDismissRoom = class("ApplyDismissRoom", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function ApplyDismissRoom:ctor(roomPlayers, playerSeatIdx)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	self.roomPlayers = roomPlayers
	self.playerSeatIdx = playerSeatIdx

	self:setVisible(false)

	-- 注册解散房间事件
	gt.registerEventListener("_APPLY_DIMISS_ROOM_REMOVE_", self, self.dismissRoomEvt)

	gt.registerEventListener(gt.EventType.APPLY_DIMISS_ROOM, self, self.dismissRoomEvt)
end

function ApplyDismissRoom:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
		
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)

		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)

		-- 事件回调
		gt.removeTargetAllEventListener(self)
	end
end

function ApplyDismissRoom:onTouchBegan(touch, event)
	if not self:isVisible() then
		return false
	end

	return true
end

-- start --
--------------------------------
-- @class function
-- @description 更新解散房间倒计时
-- end --
function ApplyDismissRoom:update(delta)
	if not self.rootNode or not self.dimissTimeCD then
		return
	end

	self.dimissTimeCD = self.dimissTimeCD - delta
	if self.dimissTimeCD < 0 then
		self.dimissTimeCD = 0
	end

	if self.dimissTimeCD == 0 then
		if self.forceOut == nil then
			self.forceOut = true
			self.dimissTimeCD = 10
			gt.seekNodeByName(self.rootNode, "Btn_agree"):setVisible(false)
			gt.seekNodeByName(self.rootNode, "Btn_refuse"):setVisible(false)
			gt.seekNodeByName(self.rootNode, "Img_self_waiting"):setVisible(true)
		end
	end

	local timeCD = math.ceil(self.dimissTimeCD)
	local dismissTimeCDLabel = gt.seekNodeByName(self.rootNode, "Label_dismissCD")
	dismissTimeCDLabel:setString(tostring(timeCD).."秒")

	if self.forceOut and self.dimissTimeCD == 0 then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)

		gt.seekNodeByName(self.rootNode, "Node_normal"):setVisible(false)
		gt.seekNodeByName(self.rootNode, "Node_forceOut"):setVisible(true)

		local Btn_forceOut = gt.seekNodeByName(self.rootNode, "Btn_forceOut")
		gt.addBtnPressedListener(Btn_forceOut, function()
			print("===========================forceOut click")
			gt.CreateRoomFlag = false
			gt.dispatchEvent(gt.EventType.BACK_MAIN_SCENE)
		end)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 接收解散房间消息事件ReadyPlay接收消息以事件方式发送过来
-- @param eventType
-- @param msgTbl
-- end --
function ApplyDismissRoom:dismissRoomEvt(eventType, msgTbl)
	self:setVisible(true)


	gt.log("csw__________")

	gt.dump(msgTbl)

	if msgTbl.kErrorCode == 0 then
		-- 等待操作中
		if not self.rootNode then
			local csbNode = cc.CSLoader:createNode("ApplyDismissRoom.csb")
			csbNode:setPosition(gt.winCenter)
			self:addChild(csbNode)
			self.rootNode = csbNode

			local agreeBtn = gt.seekNodeByName(self.rootNode, "Btn_agree")
			-- 同意
			agreeBtn:setTag(1)
			gt.addBtnPressedListener(agreeBtn, handler(self, self.buttonClickEvt))

			local refuseBtn = gt.seekNodeByName(self.rootNode, "Btn_refuse")
			-- 拒绝
			refuseBtn:setTag(2)
			gt.addBtnPressedListener(refuseBtn, handler(self, self.buttonClickEvt))

			-- 倒计时初始化
			self.dimissTimeCD = msgTbl.kTime
			local dismissTimeCDLabel = gt.seekNodeByName(self.rootNode, "Label_dismissCD")
			dismissTimeCDLabel:setString(tostring(self.dimissTimeCD).."秒")
		end
		
		local applyUserLable = gt.seekNodeByName(self.rootNode, "lbl_apply_user")
		applyUserLable:setString(msgTbl.kApply)
		local agreeBtn = gt.seekNodeByName(self.rootNode, "Btn_agree")
		local refuseBtn = gt.seekNodeByName(self.rootNode, "Btn_refuse")
		local waiting = gt.seekNodeByName(self.rootNode, "Img_self_waiting")
		agreeBtn:setVisible(true)
		refuseBtn:setVisible(true)
		waiting:setVisible(false)
		if msgTbl.kFlag ~= 0 then
			-- 隐藏操作按钮
			agreeBtn:setVisible(false)
			refuseBtn:setVisible(false)
			waiting:setVisible(true)
		end
		--local contentLabel = gt.seekNodeByName(self.rootNode, "Label_content")
		--local contentString = ""
		-- if msgTbl.m_flag == 0 then
		-- 	-- 等待同意或者拒绝
		-- 	contentString = gt.getLocationString("LTKey_0022", msgTbl.m_apply)
		-- else
		-- 	-- 已经同意或者拒绝
		-- 	contentString = gt.getLocationString("LTKey_0023", msgTbl.m_apply)

		-- 	-- 隐藏操作按钮
		-- 	local agreeBtn = gt.seekNodeByName(self.rootNode, "Btn_agree")
		-- 	local refuseBtn = gt.seekNodeByName(self.rootNode, "Btn_refuse")
		-- 	agreeBtn:setVisible(false)
		-- 	refuseBtn:setVisible(false)
		-- end
		-- contentLabel:setString(contentString)
		print("这里显示同意拒绝的玩家")
		gt.dump(msgTbl)
		cc.SpriteFrameCache:getInstance():addSpriteFrames("images/public_ui.plist")
		for i = 1, 4 do
			local player_name = gt.seekNodeByName(self.rootNode, "lbl_name_player_"..i)
			player_name:setVisible(false)
			local player_status = gt.seekNodeByName(self.rootNode, "lbl_status_player_"..i)
			player_status:setVisible(false)
			local headSpr = gt.seekNodeByName(self.rootNode, "Img_player_"..i)
			headSpr:setVisible(false)
			local parent = gt.seekNodeByName(self.rootNode, "Panel"..i)
			parent:setVisible(false)
		end
		local index = 1
		for _, v in ipairs(msgTbl.kAgree) do
			local player_name = gt.seekNodeByName(self.rootNode, "lbl_name_player_"..index)
			player_name:setVisible(true)
			player_name:setString(v)
			local player_status = gt.seekNodeByName(self.rootNode, "lbl_status_player_"..index)
			player_status:setVisible(true)
			player_status:setString("同意")
			player_status:setColor(cc.c3b(86,184,47))

			local headSpr = gt.seekNodeByName(self.rootNode, "Img_player_"..index)
			headSpr:setVisible(true)
			local parent = gt.seekNodeByName(self.rootNode, "Panel"..index)
			parent:setVisible(true)
			local headUrl = msgTbl.kAgreeHeadUrl[index]
			if headUrl ~= "" then
				local uid = msgTbl.kAgreeUserId[index]
				local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
				playerHeadMgr:attach(headSpr, parent, uid, headUrl, nil, nil, 100)
				self:addChild(playerHeadMgr)
			else
				headSpr:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("public_img_head_bg.png"))
			end

			index = index + 1
		end
		for _, v in ipairs(msgTbl.kWait) do
			local player_name = gt.seekNodeByName(self.rootNode, "lbl_name_player_"..index)
			player_name:setVisible(true)
			player_name:setString(v)
			local player_status = gt.seekNodeByName(self.rootNode, "lbl_status_player_"..index)
			player_status:setVisible(true)
			player_status:setString("等待中")
			player_status:setColor(cc.c3b(112,50,21))

			local headSpr =  gt.seekNodeByName(self.rootNode, "Img_player_"..index)
			headSpr:setVisible(true)
			local parent = gt.seekNodeByName(self.rootNode, "Panel"..index)
			parent:setVisible(true)
			local headUrl = msgTbl.kWaitHeadUrl[index-#msgTbl.kAgreeHeadUrl]
			if headUrl ~= "" then
				local uid = msgTbl.kWaitUserId[index-#msgTbl.kAgreeHeadUrl]
				local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
				playerHeadMgr:attach(headSpr, parent, uid, headUrl, nil, nil, 100)
				self:addChild(playerHeadMgr)
			else
				headSpr:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("public_img_head_bg.png"))
			end

			index = index + 1
		end
		gt.m_userId = msgTbl.kUserId
	elseif msgTbl.kErrorCode == 2 then
		-- 三个人同意，解散成功
		gt.CreateRoomFlag = false
		local noticeString = "经玩家【%s】，【%s】，【%s】同意，房间解散成功"
		local agreeNum = #msgTbl.kAgree

		if agreeNum < 3 then
			noticeString = "经玩家【%s】，【%s】同意，房间解散成功"
		end

		if( _G.next({unpack(msgTbl.kAgree)}) ) then
			noticeString = string.format(noticeString, unpack(msgTbl.kAgree))
		end

		local runningScene = cc.Director:getInstance():getRunningScene()
		if runningScene then
			gt.log("remove____________")
			runningScene:removeChildByName("NoticeTipsCommon")
		end



		require("client/game/dialog/NoticeTipsCommon"):create(2,
			noticeString,
			function()
				self:setVisible(false)
			end)
	elseif msgTbl.kErrorCode == 3 then
		-- 时间到，解散成功

		local runningScene = cc.Director:getInstance():getRunningScene()
		if runningScene then
			gt.log("remove____________")
			runningScene:removeChildByName("NoticeTipsCommon")
		end


		gt.CreateRoomFlag = false
		require("client/game/dialog/NoticeTipsCommon"):create(2,
			gt.getLocationString("LTKey_0044"),
			function()
				self:setVisible(false)
			end)
	elseif msgTbl.kErrorCode == 4 then
		-- 有一个人拒绝，解散失败




		local runningScene = cc.Director:getInstance():getRunningScene()
		gt.log("abcd__________",runningScene)

		if runningScene then
			gt.log("remove____________")
			runningScene:removeChildByName("NoticeTipsCommon")
		end


		require("client/game/dialog/NoticeTipsCommon"):create(2,
			gt.getLocationString("LTKey_0026", msgTbl.kRefuse),
			function()
				if not self.rootNode then
					self:setVisible(false)
				else
					local agreeBtn = gt.seekNodeByName(self.rootNode, "Btn_agree")
					if not agreeBtn:isVisible() then
						self:setVisible(false)
					end
				end
			end)
		gt.m_userId = 0
	end

	if msgTbl.kErrorCode ~= 0 then
		if self.rootNode then
			self.rootNode:removeFromParent()
			self.rootNode = nil
		end
	end
end

function ApplyDismissRoom:delete()
	self:setVisible(false)
	if not tolua.isnull(self.rootNode) then
		self.rootNode:removeFromParent()
		self.rootNode = nil
	end
end

function ApplyDismissRoom:buttonClickEvt(sender)
	local agreeBtn = gt.seekNodeByName(self.rootNode, "Btn_agree")
	local refuseBtn = gt.seekNodeByName(self.rootNode, "Btn_refuse")
	agreeBtn:setVisible(false)
	refuseBtn:setVisible(false)

	local msgToSend = {}
	msgToSend.kMId = gt.CG_APPLY_DISMISS
	msgToSend.kPos = self.playerSeatIdx - 1
	msgToSend.kFlag = sender:getTag()
	gt.socketClient:sendMessage(msgToSend)
end

return ApplyDismissRoom

