


local baseView = class("baseView", function()
	return gt.createMaskLayer(0)
end)

function baseView:ctor(m,...)

	local name = self.class.__cname
	name = name..".csb"
	gt.log("csb.........",name)
	self._node = cc.CSLoader:createNode(name)
	self._node:setAnchorPoint(0.5, 0.5)
	self._node:setPosition(gt.winCenter)
	gt.addNode(self,self._node)
	--self._node:setScale(0.1)
	--self._node:runAction(cc.ScaleTo:create(0.1, 1))
	--yl.registerTouchEvent(self,true)
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	if self.init then self:init(m,...) end 

end

function baseView:onNodeEvent(eventName)
	if "enter" == eventName then
		if self.enter then self:enter() end 
		local scene = display.getRunningScene()
		local node = self:findNodeByName("hui_di",scene)

		
		
		if scene and node then 
			node:setLocalZOrder(2500)
			node:setVisible(true)
			
		end

		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

	elseif "exit" == eventName then
		if self.exit then self:exit() end 
		local scene = display.getRunningScene()
		local node = self:findNodeByName("hui_di",scene)
		if scene and node then 
			node:setLocalZOrder(2500)
			node:setVisible(false)
		end

		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)

	end
end

function baseView:onTouchBegan(touch, event)
	return true
end

function baseView:onTouchEnded(touch, event)
	
end

function baseView:findNodeByName(name, parent)
	
	parent = parent or self._node 
	return gt.seekNodeByName(parent,name)
end

return baseView