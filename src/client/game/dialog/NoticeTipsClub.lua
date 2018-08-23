
local gt = cc.exports.gt

local NoticeTipsClub = class("NoticeTipsClub", function()
	return gt.createMaskLayer()
end)

function NoticeTipsClub:ctor(titleText, tipsText, okFunc, cancelFunc, singleBtn, schedule, sendNotHu, tempThink, isWeixin, closeOutside)
	self:setName("NoticeTipsClub")

 	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("NoticeTipsClub.csb")
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
				
	local joinMoreClubBtn = gt.seekNodeByName(csbNode, "Btn_joinMoreClub")
	gt.addBtnPressedListener(joinMoreClubBtn, function()
		local runningScene = cc.Director:getInstance():getRunningScene()
		local joinClubLayer = require("client/game/club/JoinClub"):create(1)
		joinClubLayer:setName("JoinClub")
		runningScene:addChild(joinClubLayer, 99)
        self:onBack()
	end)

	local progressQueryBtn = gt.seekNodeByName(csbNode, "Btn_progressQuery")
	gt.addBtnPressedListener(progressQueryBtn, function()
		local runningScene = cc.Director:getInstance():getRunningScene()
  		local ClubProgressQueryLayer = require("client/game/club/ClubProgressQuery"):create()
		ClubProgressQueryLayer:setName("ClubProgressQuery")
		runningScene:addChild(ClubProgressQueryLayer, 99)
        self:onBack()
	end)

	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
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

	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS)
	end
end

function NoticeTipsClub:onBack()
	self:removeFromParent()
end

function NoticeTipsClub:onNodeEvent(eventName)
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

function NoticeTipsClub:onTouchBegan(touch, event)
	return true
end

function NoticeTipsClub:onTouchEnded(touch, event)
	self:removeFromParent()
end

return NoticeTipsClub

