
local gt = cc.exports.gt

local NoticeForSendVideoTips = class("NoticeForSendVideoTips", function()
	return gt.createMaskLayer()
end)

function NoticeForSendVideoTips:ctor(VideoType, tipsText, userId, isOnVideo, deskId)
	self:setName("NoticeForSendVideoTips")

	local csbNode = cc.CSLoader:createNode("NoticeForSendVideoTips.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	if tipsText then
		local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
		tipsLabel:setString(tipsText)
	end
		
	local Node_1 = gt.seekNodeByName(csbNode, "Node_1")
	local Node_2 = gt.seekNodeByName(csbNode, "Node_2")
	if VideoType == 1 then
		Node_1:setVisible(true)
		Node_2:setVisible(false)

		local cancelBtn = gt.seekNodeByName(csbNode, "Btn_cancel")
		gt.addBtnPressedListener(cancelBtn, function()
	        self:onBack()
		end)

		local sendBtn = gt.seekNodeByName(csbNode, "Btn_send")
		gt.addBtnPressedListener(sendBtn, function()
			if isOnVideo then
			gt.log("-------------gt.playerData.nickname", gt.playerData.nickname)
			local runningScene = cc.Director:getInstance():getRunningScene()
    			Toast.showToast(runningScene, gt.playerData.nickname.."正在视频中，请稍候再试", 2)
			else
				gt.log("-------------发送实时视频命令", userId)
				--发送视频消息
				local msgToSend = {}
				msgToSend.kMId = gt.SEND_VIDEO_INVITATION
				msgToSend.kReqUserId = gt.playerData.uid
				msgToSend.kUserId = userId
				-- msgToSend.m_strUUID = gt.socketClient:getPlayerUUID()
				gt.socketClient:sendMessage(msgToSend)

				gt.receiveUserId = userId
				gt.log("-------------gt.receiveUserId6", gt.receiveUserId)
			end
	        self:onBack()
		end)
	elseif VideoType == 2 then
		Node_1:setVisible(false)
		Node_2:setVisible(true)

		local function sendVideo( isVideoPermit )
			--发送视频消息
			local msgToSend = {}
			msgToSend.kMId = gt.UPLOAD_VIDEO_PERMISSION
			msgToSend.kUserId = gt.playerData.uid
			msgToSend.kVideoPermit = isVideoPermit
			gt.socketClient:sendMessage(msgToSend)

            cc.UserDefault:getInstance():setIntegerForKey("IsSendForbidVideo"..deskId, isVideoPermit)
  		    cc.UserDefault:getInstance():setIntegerForKey( "VIPdeskId", deskId )
	        self:onBack()
		end

		local timeCount = 10

	 	local clockTime = function()
	 		timeCount = timeCount - 1
	 		if timeCount <= 0 then
		 		if self.clockTimeScheduler then
		 			gt.scheduler:unscheduleScriptEntry(self.clockTimeScheduler)
		 			self.clockTimeScheduler = nil
		 		end
				
				sendVideo(1)
		 	end

		 	if self.agreeCDLabel then
				self.agreeCDLabel:setString(timeCount)
			end
	 	end
	 	
	    self.clockTimeScheduler = gt.scheduler:scheduleScriptFunc(clockTime, 1, false)

		self.agreeCDLabel = gt.seekNodeByName(csbNode, "Label_agreeCD")
		self.agreeCDLabel:setString(timeCount)

		local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
		gt.addBtnPressedListener(closeBtn, function()
			sendVideo(1)	
		end)

		local agreeBtn = gt.seekNodeByName(csbNode, "Btn_agree")
		gt.addBtnPressedListener(agreeBtn, function()
			sendVideo(1)	
		end)

		local refuseBtn = gt.seekNodeByName(csbNode, "Btn_refuse")
		gt.addBtnPressedListener(refuseBtn, function()
			sendVideo(0)
		end)
	end

	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS)
	end
end

function NoticeForSendVideoTips:onNodeEvent(eventName)
	if "exit" == eventName then
 		if self.clockTimeScheduler then
 			gt.scheduler:unscheduleScriptEntry(self.clockTimeScheduler)
 			self.clockTimeScheduler = nil
 		end
	end
end

function NoticeForSendVideoTips:onBack()
	self:removeFromParent()
end

return NoticeForSendVideoTips

