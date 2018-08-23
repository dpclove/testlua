
local gt = cc.exports.gt

local DynamicStartExplainFrame = class("DynamicStartExplainFrame", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 0), 348, 192)
end)

function DynamicStartExplainFrame:ctor()
	gt.log("点击进入的")
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("DynamicStartExplainFrame.csb")
	self:addChild(csbNode)
end

function DynamicStartExplainFrame:onNodeEvent(eventName)
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

function DynamicStartExplainFrame:onTouchBegan(touch, event)
	return true
end

function DynamicStartExplainFrame:onTouchEnded(touch, event)
	self:removeFromParent()
end

return DynamicStartExplainFrame