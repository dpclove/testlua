
local gt = cc.exports.gt

local ShareCoin = class("ShareCoin", function()
	return gt.createMaskLayer()
end)

function ShareCoin:ctor( desc )
	self:setName("ShareCoin")

	 self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("ShareCoin.csb")
	csbNode:setAnchorPoint(cc.p(0.5, 0.5))
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	local descLabel = gt.seekNodeByName(csbNode, "Label_desc")
	descLabel:setString(desc)

	local enterBtn = gt.seekNodeByName(csbNode, "Btn_enter")
	gt.addBtnPressedListener(enterBtn, function()
		self:removeFromParent()
	end)

	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:removeFromParent()
	end)
end

function ShareCoin:onNodeEvent(eventName)
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

function ShareCoin:onTouchBegan(touch, event)
	return true
end

function ShareCoin:onTouchEnded(touch, event)
	self:removeFromParent()
end

return ShareCoin

