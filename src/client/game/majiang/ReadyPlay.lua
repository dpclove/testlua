local gt = cc.exports.gt

local ReadyPlay = class("ReadyPlay")

--gameType    玩法选项
function ReadyPlay:ctor(parent, csbNode, paramTbl)
	gt.log("房间内按钮 ReadyPlay =============")
	gt.dump(paramTbl)

	self.csbNode = csbNode
	
	self.isRoomCreater = false
	
	-- 房间号
	self.roomID = paramTbl.roomID
	self.m_clubId = paramTbl.m_clubId

	-- 准备节点（子节点：邀请好友，解散房间，返回大厅）
	local readyPlayNode = gt.seekNodeByName(csbNode, "Node_readyPlay")

	-- 邀请好友
	local inviteFriendBtn = gt.seekNodeByName(readyPlayNode, "Btn_inviteFriend")
	gt.addBtnPressedListener(inviteFriendBtn, function()
		gt.log("----------------------table.nums(parent.roomPlayers)", table.nums(parent.roomPlayers))
		gt.log("----------------------table.nums(parent.unSeatRoomPlayers)", table.nums(parent.unSeatRoomPlayers))
        gt.log("--------------------------gt.shareContentWeb[self.roomID]", gt.shareContentWeb[self.roomID])
        local url = string.format(gt.HTTP_INVITE, gt.nickname, gt.headURL, self.roomID, gt.shareContentWeb[self.roomID])
        gt.log("--------------------------url", url)
        gt.log("--------------------------paramTbl.title_show", paramTbl.title_show)
        local playerCount = table.nums(parent.roomPlayers) + table.nums(parent.unSeatRoomPlayers)
        local sharetext = "" 
        if paramTbl.m_clubId and paramTbl.m_clubId > 0 then
        	sharetext = "文娱馆桌号:"
        else
        	sharetext = "房号:"
        end
		Utils.shareURLToHY(url, string.format(sharetext.."%d，%s(%d局)", self.roomID, paramTbl.title_show..Utils.getNeedPlayerCount(playerCount, paramTbl.m_Greater2CanStart, paramTbl.m_state), paramTbl.roundMaxCount), gt.shareContentWeiXin[self.roomID])
	end)

	if gt.isAppStoreInReview then
		inviteFriendBtn:setVisible(false)
	else
		inviteFriendBtn:setVisible(true)
	end

	-- 复制房间号
	local copyBtn = gt.seekNodeByName(readyPlayNode, "Btn_copy")
	local copybtnFun = function()
		gt.log("复制房间号")
		local txt = "好运来山西麻将:"..paramTbl.title_show..paramTbl.playTypeDesc.."\n房号["..self.roomID.."],"..paramTbl.roundMaxCount.."局".."\n(全选复制此消息打开游戏可直接进入该房间)"
		gt.CopyText(tostring(txt))
		require("client/game/dialog/NoticeTips"):create(
			gt.getLocationString("LTKey_0007"),
			gt.getLocationString("LTKey_0049"),
			nil,nil,true)
	end
	gt.addBtnPressedListener(copyBtn, copybtnFun)

	-- 解散房间
	-- self.dimissRoomBtn = gt.seekNodeByName(readyPlayNode, "Btn_dimissRoom")

	-- local ls_12 = gt.getLocationString("LTKey_0012")
	-- if gt.isIOSPlatform() and gt.isInReview then
	-- 	ls_12 = gt.getLocationString("LTKey_0012_1")
	-- end

	-- gt.addBtnPressedListener(self.dimissRoomBtn, function()
	-- 	require("client/game/dialog/NoticeTips"):create(
	-- 		gt.getLocationString("LTKey_0011"),
	-- 		ls_12,
	-- 		function()
	-- 			local msgToSend = {}
	-- 			msgToSend.m_msgId = gt.CG_DISMISS_ROOM
	-- 			msgToSend.m_pos = paramTbl.playerSeatPos
	-- 			gt.socketClient:sendMessage(msgToSend)
	-- 			gt.CopyText(" ")
	-- 		end)

	-- end)
	-- gt.socketClient:registerMsgListener(gt.GC_DISMISS_ROOM, self, self.onRcvDismissRoom)

	-- 解散房间
	local backBtn = gt.seekNodeByName(csbNode, "Btn_back")

	local ls_12 = gt.getLocationString("LTKey_0012")
	-- if gt.isIOSPlatform() and gt.isInReview then
	-- 	ls_12 = gt.getLocationString("LTKey_0012_1")
	-- end

	gt.addBtnPressedListener(backBtn, function()
		if gt.gameStart == false then
			if gt.CreateRoomFlag == true then
				if gt.isCreateUserId then
					require("client/game/dialog/NoticeTips"):create(
						gt.getLocationString("LTKey_0011"),
						ls_12,
						function()
							local msgToSend = {}
							msgToSend.kMId = gt.CG_DISMISS_ROOM
							msgToSend.kPos = paramTbl.playerSeatPos
							gt.socketClient:sendMessage(msgToSend)
							--gt.CopyText(" ")
						end)
				else
					require("client/game/dialog/NoticeTips"):create(
						"",
						gt.getLocationString("LTKey_0051"),
						function()
							local msgToSend = {}
							msgToSend.kMId = gt.CG_QUIT_ROOM
							msgToSend.kPos = paramTbl.playerSeatPos
							gt.socketClient:sendMessage(msgToSend)
							--gt.CopyText(" ")
						end)
				end
			else
				require("client/game/dialog/NoticeTips"):create(
					"",
					gt.getLocationString("LTKey_0051"),
					function()
						local msgToSend = {}
						msgToSend.kMId = gt.CG_QUIT_ROOM
						msgToSend.kPos = paramTbl.playerSeatPos
						gt.socketClient:sendMessage(msgToSend)
						--gt.CopyText(" ")
					end)
			end
		else
			if gt.curCircle ~= nil and gt.curCircle > 1 then
				ls_12 = gt.getLocationString("LTKey_0012_1")
			end
			require("client/game/dialog/NoticeTips"):create(
				gt.getLocationString("LTKey_0011"),
				ls_12,
				function()
					local msgToSend = {}
					msgToSend.kMId = gt.CG_DISMISS_ROOM
					msgToSend.kPos = paramTbl.playerSeatPos
					gt.socketClient:sendMessage(msgToSend)
					--gt.CopyText(" ")
				end)
		end
	end)
	gt.socketClient:registerMsgListener(gt.GC_DISMISS_ROOM, self, self.onRcvDismissRoom)

	-- 返回大厅
	self.backSalaBtn = gt.seekNodeByName(csbNode, "Btn_outRoom")
	gt.addBtnPressedListener(self.backSalaBtn, function()
		-- 返回大厅提示
		local tipsContentKey = "LTKey_0019"
		if gt.isCreateUserId then
			tipsContentKey = "LTKey_0010"
		end

		if gt.CreateRoomFlag == true then
			if gt.isCreateUserId then
				require("client/game/dialog/NoticeTips"):create(
				gt.getLocationString("LTKey_0009"),
				gt.getLocationString(tipsContentKey),
				function()
					gt.showLoadingTips(gt.getLocationString("LTKey_0016"))
					local msgToSend = {}
					msgToSend.kMId = gt.CG_QUIT_ROOM
					msgToSend.kPos = paramTbl.playerSeatPos
					gt.socketClient:sendMessage(msgToSend)
					--gt.CopyText(" ")
				end)
			else
				require("client/game/dialog/NoticeTips"):create(
					"",
					gt.getLocationString("LTKey_0051"),
					function()
						local msgToSend = {}
						msgToSend.kMId = gt.CG_QUIT_ROOM
						msgToSend.kPos = paramTbl.playerSeatPos
						gt.socketClient:sendMessage(msgToSend)
						--gt.CopyText(" ")
					end)
			end
		else
			require("client/game/dialog/NoticeTips"):create(
				"",
				gt.getLocationString("LTKey_0051"),
				function()
					local msgToSend = {}
					msgToSend.kMId = gt.CG_QUIT_ROOM
					msgToSend.kPos = paramTbl.playerSeatPos
					gt.socketClient:sendMessage(msgToSend)
					--gt.CopyText(" ")
				end)
		end
	end)
	gt.socketClient:registerMsgListener(gt.GC_QUIT_ROOM, self, self.onRcvQuitRoom)

	-- 隐藏非房主无法操作的按钮
	-- if not self.isRoomCreater then
	-- 	self.dimissRoomBtn:setVisible(false)
	-- end

	-- 设置按钮
	local settingBtn = gt.seekNodeByName(readyPlayNode, "Btn_setting_Ready")
	if settingBtn then
		gt.addBtnPressedListener(settingBtn, function()
			local settingPanel = require("client/game/common/Setting"):create(gt.winCenter)
			csbNode:getParent():addChild(settingPanel, 666)

			local dismissRoom = gt.seekNodeByName(settingPanel.rootNode, "Btn_dismissRoom")
			if dismissRoom then
				dismissRoom:setVisible( false )
			end
		end)

		settingBtn:setVisible( false )
	end

	-- 播放互动动画按钮
	-- local csbHudongNode = gt.seekNodeByName(csbNode, "Node_hudong")
	-- local btnNames = {"qumo", "shaoxiang","xishou"}
	-- self.playingNode = nil --正在播放的动画节点
	-- for i=1, 3 do
	-- 	local btn = gt.seekNodeByName(csbHudongNode, "Btn_hd_"..btnNames[i])
	-- 	if btn ~= nil then
	-- 		btn:setTag(i)
	-- 		gt.addBtnPressedListener(btn, function (sender, event)
	-- 			dump("sender = " .. btnNames[sender:getTag()])
	-- 			if self.playingNode ~= nil then
	-- 				self.playingNode:stopAllActions()
	-- 				self.playingNode:removeFromParent()
	-- 				self.playingNode = nil
	-- 			end
	-- 			self.playingNode, self.playingAni = gt.createCSAnimation("animation/ani_"..btnNames[sender:getTag()]..".csb")
	-- 			self.playingAni:gotoFrameAndPlay(0, false)
	-- 			self.playingNode:setPosition(gt.winCenter)
	-- 			csbNode:getParent():addChild(self.playingNode, gt.PlayZOrder.MJBAR_ANIMATION)
	-- 		end)
	-- 	end
	-- end

	--test骨骼动画
	-- local csbHudongNode = gt.seekNodeByName(csbNode, "Node_hudong")
	-- self.playingNode = nil --正在播放的动画节点
	-- local btn = gt.seekNodeByName(csbHudongNode, "Btn_hd_xishou")
	-- if btn ~= nil then
	-- 	gt.addBtnPressedListener(btn, function (sender, event)
	-- 		if self.playingNode ~= nil then
	-- 			self.playingNode:stopAllActions()
	-- 			self.playingNode:removeFromParent()
	-- 			self.playingNode = nil
	-- 		end
	-- 		self.playingNode, self.playingAni = gt.createCSAnimation("res/Skeleton.csb")
	-- 		self.playingAni:gotoFrameAndPlay(0, false)
	-- 		self.playingNode:setPosition(gt.winCenter)
	-- 		csbNode:getParent():addChild(self.playingNode, gt.PlayZOrder.MJBAR_ANIMATION)
	-- 	end)
	-- end

	--转运
	self.playingNode = nil --正在播放的动画节点
	local zhuanyunBtn = gt.seekNodeByName(csbNode, "Btn_zhuanyun")
	if zhuanyunBtn ~= nil then
		gt.addBtnPressedListener(zhuanyunBtn, function (sender, event)
			gt.soundManager:PlayZhuanyunSound(gt.wxSex)
			self:playAnimation(2)
			self.playingNode, self.playingAni = gt.createCSAnimation("res/animation/baiguangong/baiguangong.csb")
			self.playingAni:play("run", true)
			self.playingNode:setScale(1.5)
			self.playingNode:setPosition(gt.winCenter)
			self.playingNode:setPosition(cc.p(gt.winCenter.x + 14, gt.winCenter.y - 60))
			csbNode:getParent():addChild(self.playingNode, gt.PlayZOrder.MJBAR_ANIMATION)
		end)
	end

	gt.socketClient:registerMsgListener(gt.GC_FZ_DISMISS, self, self.onRcvFzDismiss)

	-- 播放互动动画按钮
	-- local csbHudongNode = gt.seekNodeByName(csbNode, "Node_hudong")
	-- local btnNames = {"qumo", "shaoxiang","xishou"}
	-- local aniNames = {"diaojinbi", "baiguangong","baiguangong"}
	-- self.playingNode = nil --正在播放的动画节点
	-- for i=1, 3 do
	-- 	local btn = gt.seekNodeByName(csbHudongNode, "Btn_hd_"..btnNames[i])
	-- 	if btn ~= nil then
	-- 		btn:setTag(i)
	-- 		gt.addBtnPressedListener(btn, function (sender, event)
	-- 			dump("sender = " .. btnNames[sender:getTag()])
	-- 			if self.playingNode ~= nil then
	-- 				self.playingNode:stopAllActions()
	-- 				self.playingNode:removeFromParent()
	-- 				self.playingNode = nil
	-- 			end
	-- 			self:playAnimation(sender:getTag())
	-- 			self.playingNode, self.playingAni = gt.createCSAnimation("res/animation/"..aniNames[sender:getTag()].."/"..aniNames[sender:getTag()]..".csb")
	-- 			-- self.playingAni:gotoFrameAndPlay(0, false)
	-- 			if sender:getTag() == 1 then
	-- 				self.playingAni:play("run", false)
	-- 			elseif sender:getTag() == 2 then
	-- 				self.playingAni:play("run", true)
	-- 				self.playingNode:setScale(1.5)
	-- 			end
	-- 			self.playingNode:setPosition(cc.p(gt.winCenter.x + 14, gt.winCenter.y - 60))
	-- 			csbNode:getParent():addChild(self.playingNode, gt.PlayZOrder.MJBAR_ANIMATION)
	-- 		end)
	-- 	end
	-- end
end

function ReadyPlay:playAnimation(type)
	if type == 1 then
	 	local update1 = function()
	 		print("---------------------------------update")	
			if self.playingNode ~= nil then
				self.playingNode:stopAllActions()
				self.playingNode:removeFromParent()
				self.playingNode = nil
			end
			if self.scheduleHandler1 then
				gt.scheduler:unscheduleScriptEntry(self.scheduleHandler1)
				self.scheduleHandler1 = nil
			end
			if self.faguang ~= nil then
				self.faguang:stopAllActions()
				self.faguang:removeFromParent()
				self.faguang = nil
			end
			if self.bufaguang ~= nil then
				self.bufaguang:stopAllActions()
				self.bufaguang:removeFromParent()
				self.bufaguang = nil
			end
			if self.guangong ~= nil then
				self.guangong:removeFromParent()
				self.guangong = nil
			end
			if self.scheduleHandler2 then
				gt.scheduler:unscheduleScriptEntry(self.scheduleHandler2)
				self.scheduleHandler2 = nil
			end
	 	end
	 	update1()
		self.scheduleHandler1 = gt.scheduler:scheduleScriptFunc(update1, 2.5, false)
	elseif type == 2 then
	 	local update2 = function()
	 		print("---------------------------------update")	
			if self.playingNode ~= nil then
				self.playingNode:stopAllActions()
				self.playingNode:removeFromParent()
				self.playingNode = nil
			end
			if self.faguang ~= nil then
				self.faguang:stopAllActions()
				self.faguang:removeFromParent()
				self.faguang = nil
			end
			if self.bufaguang ~= nil then
				self.bufaguang:stopAllActions()
				self.bufaguang:removeFromParent()
				self.bufaguang = nil
			end
			if self.guangong ~= nil then
				self.guangong:removeFromParent()
				self.guangong = nil
			end
			if self.scheduleHandler1 then
				gt.scheduler:unscheduleScriptEntry(self.scheduleHandler1)
				self.scheduleHandler1 = nil
			end
			if self.scheduleHandler2 then
				gt.scheduler:unscheduleScriptEntry(self.scheduleHandler2)
				self.scheduleHandler2 = nil
			end
	 	end
	 	update2()
		-- self.schedulerEntry = gt.scheduler:scheduleScriptFunc(setPoints, 0.5, false)
		self.scheduleHandler2 = gt.scheduler:scheduleScriptFunc(update2, 5.5, false)
		self.faguang = cc.Sprite:createWithSpriteFrameName("faguang.png")
        self.faguang:setPosition(cc.p(640,500))
        self.csbNode:getParent():addChild(self.faguang)
        self.faguang:setOpacity(0)
		self.faguang:setScale(1.5)

		self.bufaguang = cc.Sprite:createWithSpriteFrameName("bufaguang.png")
        self.bufaguang:setPosition(cc.p(640,500))
        self.csbNode:getParent():addChild(self.bufaguang)
        self.bufaguang:setOpacity(255)
		self.bufaguang:setScale(1.5)

        self.faguang:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 255), cc.FadeTo:create(0.5, 0))))

		self.guangong = cc.Sprite:createWithSpriteFrameName("guangong.png")
        self.guangong:setPosition(cc.p(640,460))
        self.csbNode:getParent():addChild(self.guangong)
		self.guangong:setScale(1.5)
    end
end

-- function ReadyPlay:setDimissRoomVisible(isVisible)
-- 	print("-------------------------------------------------setDimissRoomVisible")
-- 	if isVisible then
		-- self.dimissRoomBtn:setVisible(isVisible)
		-- self.backSalaBtn:setPositionY(self.dimissRoomBtn:getPositionY() - 80)
	-- else
		-- self.dimissRoomBtn:setVisible(isVisible)
-- 	end
-- end

-- start --
--------------------------------
-- @class function
-- @description 返回大厅
-- end --
function ReadyPlay:onRcvQuitRoom(msgTbl)
	gt.removeLoadingTips()

	if msgTbl.kErrorCode == 0 then
		if (self.m_clubId and self.m_clubId > 0) or not gt.isCreateUserId then
			cc.UserDefault:getInstance():setIntegerForKey("tipsTime", 0)
		end
		gt.dispatchEvent(gt.EventType.BACK_MAIN_SCENE, self.isRoomCreater, self.roomID)
	else
		-- 提示返回大厅失败
		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0045"), nil, nil, true)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 房间创建者解散房间
-- end --
function ReadyPlay:onRcvDismissRoom(msgTbl)
	gt.log("ReadyPlay 创建房间者解散房间 ================= ")
	gt.dump(msgTbl)

	if msgTbl.kErrorCode == 1 then
		-- 游戏未开始解散成功
		cc.UserDefault:getInstance():setIntegerForKey("tipsTime", 0)
		gt.dispatchEvent(gt.EventType.BACK_MAIN_SCENE)
		gt.CreateRoomFlag = false
	else
		-- 游戏中玩家申请解散房间
		gt.dispatchEvent(gt.EventType.APPLY_DIMISS_ROOM, msgTbl)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 房主建房房主解散房间
-- end --
function ReadyPlay:onRcvFzDismiss(msgTbl)
	gt.log("ReadyPlay 房主建房房主解散房间 ================= ")
	gt.dump(msgTbl)

	if msgTbl.kErrorCode == 0 then
		-- 游戏未开始解散成功
		gt.dispatchEvent(gt.EventType.BACK_MAIN_SCENE)
	else
	 	local runningScene = cc.Director:getInstance():getRunningScene()
		Toast.showToast(runningScene, msgTbl.kStrErrorDes, 2)
	end
end

return ReadyPlay


