
local gt = cc.exports.gt

local LoadingTips = class("LoadingTips", function()
	return cc.LayerColor:create(cc.c4b(0, 0, 0, 150), gt.winSize.width, gt.winSize.height)
	--return gt.createMaskLayer()
end)

function LoadingTips:ctor(tipsText)
	self:setName("LoadingTips")

    local tipsNode, tipsAnimation = gt.createCSAnimation("LoadingTips.csb")
	tipsAnimation:play("run", true)
	tipsNode:setPosition(gt.winCenter)
	local circleSp=gt.seekNodeByName(tipsNode,"Spr_circle")
	self:addChild(tipsNode,100)
	
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
     
	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, 999)
	end

	self.tipsText = tipsText
	self.tipsLabel = gt.seekNodeByName(self, "Label_tips")
	self.tipsLabel:setString(self.tipsText)
	self:loginConnectShow(true)
end

function LoadingTips:remove()
	self:removeFromParent()
end

function LoadingTips:loginConnectShow(isShow)
	local PointsCount = 2
 	local setPoints = function()
 		PointsCount = PointsCount + 1

 		if PointsCount > 4 then
 			PointsCount = 1
 		end

		if self.tipsLabel then
	 		if PointsCount == 1 then
	 			self.tipsLabel:setString(self.tipsText.."")
	 		elseif PointsCount == 2 then
	 			self.tipsLabel:setString(self.tipsText..".")
	 		elseif PointsCount == 3 then
	 			self.tipsLabel:setString(self.tipsText.."..")
	 		elseif PointsCount == 4 then
	 			self.tipsLabel:setString(self.tipsText.."...")
	 		end
		end
	end

	if self.schedulerEntry == nil then
		self.tipsLabel:setString(self.tipsText..".")
		self.schedulerEntry = gt.scheduler:scheduleScriptFunc(setPoints, 0.1, false)
	end
end

function LoadingTips:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
 		if self.schedulerEntry then
 			gt.scheduler:unscheduleScriptEntry(self.schedulerEntry)
 			self.schedulerEntry = nil
 		end
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
	end
end

function LoadingTips:onTouchBegan(touch, event)
	return true
end
return LoadingTips
