
local gt = cc.exports.gt

local NoticeTipsReLogin = class("NoticeTipsReLogin", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function NoticeTipsReLogin:ctor(data)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("NoticeTipsReLogin.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

	local text = "网络异常，请重新登录!".."\n"
	text = text.."用户ID:"..(data.uid or "空").."\n"
	text = text.."消息ID:"..(data.m_msgId or "空").."\n"
	text = text.."场景名称:"..(data.name or "空").."\n"..os.date("%Y-%m-%d_%H:%M:%S", os.time())

	local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
	tipsLabel:setString(text)
	
	-- 关闭按钮
	local closeBtn = gt.seekNodeByName(csbNode, "m_btnClose")
	gt.addBtnPressedListener(closeBtn, function()
		self:removeFromParent()
	end)

	local restartBtn = gt.seekNodeByName(csbNode, "Btn_restart")
	gt.addBtnPressedListener(restartBtn, function()
		if gt.socketClient.scheduleHandler then
			gt.scheduler:unscheduleScriptEntry( gt.socketClient.scheduleHandler )
		end
		-- 清除活动数据
		gt.lotteryInfoTab = nil
		-- 关闭事件回调
		gt.removeTargetAllEventListener(gt.socketClient)
		-- 调用善后处理函数
		gt.socketClient:clearSocket()
		-- 关闭socket
		gt.socketClient:close()
		gt.log("退出到了LogoScene里面了")

		self:clearLoadedFiles()
		
		local loginScene = require("client/game/common/LogoScene"):create()
		cc.Director:getInstance():replaceScene(loginScene)
	end)
end

function NoticeTipsReLogin:clearLoadedFiles()
	for k, v in pairs(package.loaded) do
		if string.sub(k, 1, 7) == "client/" then
			package.loaded[k] = nil
		end 
	end
	cc.SpriteFrameCache:getInstance():removeSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeAllTextures()
end

function NoticeTipsReLogin:onNodeEvent(eventName)
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

function NoticeTipsReLogin:onTouchBegan(touch, event)
	return true
end

function NoticeTipsReLogin:onTouchEnded(touch, event)
	local bg = gt.seekNodeByName(self.rootNode, "Img_bg")
	if bg then
		local point = bg:convertToNodeSpace(touch:getLocation())
		local rect = cc.rect(0, 0, bg:getContentSize().width, bg:getContentSize().height)
		if not cc.rectContainsPoint(rect, cc.p(point.x, point.y)) then
			self:removeFromParent()
		end
	end
end

return NoticeTipsReLogin



