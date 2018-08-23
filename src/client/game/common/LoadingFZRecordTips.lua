
local gt = cc.exports.gt

local LoadingFZRecordTips = class("LoadingFZRecordTips", function()
	return cc.LayerColor:create(cc.c4b(0, 0, 0, 150), gt.winSize.width, gt.winSize.height)
	--return gt.createMaskLayer()
end)

function LoadingFZRecordTips:ctor(tipsText)
	self:setName("LoadingFZRecordTips")

    local tipsNode, tipsAnimation = gt.createCSAnimation("LoadingTips.csb")
	tipsAnimation:play("run", true)
	tipsNode:setPosition(gt.winCenter)
	local circleSp=gt.seekNodeByName(tipsNode,"Spr_circle")
	self:addChild(tipsNode,100)
	
    
 --    local tipsNodeCircle, tipsAnimationC = gt.createCSAnimation("loading.csb")
	-- tipsAnimationC:play("loading", true)
	-- tipsNodeCircle:setScale(1.8)
	-- tipsNodeCircle:setPosition(circleSp:getPosition())
	-- circleSp:setVisible(false)
	-- tipsNode:addChild(tipsNodeCircle)
	-- circleSp:setVisible(false)
     
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
     
	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, 999)
	end

	self:setTipsText(tipsText)
end

function LoadingFZRecordTips:setTipsText(tipsText)
	if tipsText then
		local tipsLabel = gt.seekNodeByName(self, "Label_tips")
		tipsLabel:setString(tipsText)
	end
end

function LoadingFZRecordTips:remove()
	self:removeFromParent()
end

function LoadingFZRecordTips:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
	end
end

function LoadingFZRecordTips:onTouchBegan(touch, event)
	return true
end
return LoadingFZRecordTips
