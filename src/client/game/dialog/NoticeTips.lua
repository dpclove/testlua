
local gt = cc.exports.gt

local NoticeTips = class("NoticeTips", function()
	return gt.createMaskLayer()
end)

function NoticeTips:ctor(titleText, tipsText, okFunc, cancelFunc, singleBtn, schedule, sendNotHu, tempThink, isWeixin, closeOutside)
	self:setName("NoticeTips")

	if closeOutside then
	-- 	print("-------------------------------这里是注册节点事件")
	 	self:registerScriptHandler(handler(self, self.onNodeEvent))
	end

	local csbNode = cc.CSLoader:createNode("NoticeTips.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	self.rootNode = csbNode
   	self.okFunc = okFunc
   	self.m_onMainSceneTime = os.time()
   	self.m_time = 0

	if titleText then
		local titleLabel = gt.seekNodeByName(csbNode, "Label_title")
		titleLabel:setString(titleText)
	end

	if tipsText then
		local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
		tipsLabel:setString(tipsText)
	end
	
	local okBtn = gt.seekNodeByName(csbNode, "Btn_ok")
	if isWeixin then
		okBtn:loadTextures("res/images/otherImages/open_wx.png", "res/images/otherImages/open_wx.png")
	end
	gt.addBtnPressedListener(okBtn, function()
		gt.log("二次提示弹窗确认 sendNotHu = "..tostring(sendNotHu))
        self:onBack()
        if sendNotHu then
        	local msgToSend = {}
			msgToSend.kMId = gt.CG_PLAYER_DECISION
			msgToSend.kType = 0
			msgToSend.kThink = tempThink
			gt.socketClient:sendMessage(msgToSend)

			gt.dispatchEvent("EVENT_CONFIRM_HU")
        else
        	if okFunc then
				okFunc()
			end
        end
	end)

	local cancelBtn = gt.seekNodeByName(csbNode, "Btn_cancel")
	gt.addBtnPressedListener(cancelBtn, function()
		self:onBack()
		if sendNotHu then
			gt.dispatchEvent("EVENT_CANCLE_HU")
        else
        	if cancelFunc then
				cancelFunc()
			end
        end
	end)
    
    local oktext=gt.seekNodeByName(okBtn,"Image_1")
	local canceltext=gt.seekNodeByName(cancelBtn,"Image_2")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("images/public_ui.plist")

	if singleBtn then
		-- okBtn:setPositionX(0)
		okBtn:setPosition(0, -150)
		cancelBtn:setVisible(false)
	end

	local runningScene = cc.Director:getInstance():getRunningScene()


	-- csw 12-15  修改叠加bug 
	if runningScene.name == "pokerScene" then 
		self:setName("_NoticeTips_")
		if runningScene and  runningScene:getChildByName("_NoticeTips_")  then runningScene:getChildByName("_NoticeTips_"):removeFromParent() end
	end
	-- csw 12-15 
	gt.log("scene,,",runningScene.name)
	if runningScene then

		runningScene:addChild(self, 3000)
	end

	if schedule then
		local backMainTips = gt.seekNodeByName(csbNode, "back_main_tips")
		backMainTips:setVisible(true)
		self.m_backMainTips = backMainTips
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 1, false)
	end
	gt.log("NoticeTips ctor")
end

function NoticeTips:update()
	-- local curTime = os.time()
	-- if curTime - self.m_onMainSceneTime > 3 then
		
	-- end
	self.m_time = self.m_time + 1
	if self.m_time < 3 then
		self.m_backMainTips:setString( (3-self.m_time) .."秒后自动回到大厅" )
	else
		if self.okFunc then
			self.okFunc()
		end
		self:onBack()
	end
end


function NoticeTips:setYesNoLoadTextures()
	local okBtn = gt.seekNodeByName(self.rootNode, "Btn_ok")
	okBtn:loadTextures("res/images/otherImages/notice_yes.png", "res/images/otherImages/notice_yes.png")
	
	local cancelBtn = gt.seekNodeByName(self.rootNode, "Btn_cancel")
	cancelBtn:loadTextures("res/images/otherImages/notice_no.png", "res/images/otherImages/notice_no.png")
end

function NoticeTips:onBack()
	if self.scheduleHandler then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end	
	self:removeFromParent()
end

function NoticeTips:onNodeEvent(eventName)
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

function NoticeTips:onTouchBegan(touch, event)
	return true
end

function NoticeTips:onTouchEnded(touch, event)
	self:removeFromParent()
end

return NoticeTips

