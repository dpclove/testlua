
local gt = cc.exports.gt

local NoticeForGiftCourtesyTips = class("NoticeForGiftCourtesyTips", function()
	return gt.createMaskLayer()
end)

function NoticeForGiftCourtesyTips:ctor(tipsText)
	self:setName("NoticeForGiftCourtesyTips")

	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("NoticeForGiftCourtesyTips1.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	

	local okBtn = gt.seekNodeByName(csbNode, "Btn_ok")
	gt.addBtnPressedListener(okBtn, function()
		
        self:onBack()
	end)

	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS)
	end
end





function NoticeForGiftCourtesyTips:onBack()
	self:removeFromParent()
end

function NoticeForGiftCourtesyTips:onNodeEvent(eventName)
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

function NoticeForGiftCourtesyTips:onTouchBegan(touch, event)
	return true
end

function NoticeForGiftCourtesyTips:onTouchEnded(touch, event)
	self:removeFromParent()
end

return NoticeForGiftCourtesyTips

