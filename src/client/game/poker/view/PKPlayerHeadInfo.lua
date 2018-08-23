
local gt = cc.exports.gt

local PKPlayerHeadInfo = class("PKPlayerHeadInfo", function()
	return cc.Layer:create()
end)

function PKPlayerHeadInfo:ctor(roomPlayer, playerSeatIdx)
	gt.log("点击玩家头像")
	dump(roomPlayer)

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    
	self.rootNode = cc.CSLoader:createNode("playerInfo_sde.csb")
	self.rootNode:setAnchorPoint(0.5, 0.5)
	self:addChild(self.rootNode)
	self.rootNode:setPosition(gt.winCenter)

    -- 头像下载管理器
	local playerHeadMgr = gt.include("view/PlayerHeadManager"):create()
	self:addChild(playerHeadMgr)

	local Sprite_head = gt.seekNodeByName(self.rootNode, "Sprite_head")
	local Text_name = gt.seekNodeByName(self.rootNode, "Text_name")
	local Text_ID = gt.seekNodeByName(self.rootNode, "Text_ID")
	local Text_IP = gt.seekNodeByName(self.rootNode, "Text_IP")

	local Y = roomPlayer.displaySeatIdx == 1 and 40 or 0

	Sprite_head:setPositionY(Sprite_head:getPositionY()-Y)
	Text_name:setPositionY(Text_name:getPositionY()-Y)
	Text_ID:setPositionY(Text_ID:getPositionY()-Y)
	Text_IP:setPositionY(Text_IP:getPositionY()-Y)


	playerHeadMgr:attach(Sprite_head, roomPlayer.headURL, nil, roomPlayer.sex, true)
    Text_name:setString(roomPlayer.nickname)
    Text_ID:setString(roomPlayer.uid)
    Text_IP:setString(roomPlayer.ip)

	local Btn_back = gt.seekNodeByName(self.rootNode, "Btn_back")
    gt.addBtnPressedListener(Btn_back, function()
		self:removeFromParent()
    end)

    --动画
    local Btn_flower = gt.seekNodeByName(self.rootNode, "Btn_flower")
    Btn_flower:setVisible(roomPlayer.displaySeatIdx~=1)
    gt.addBtnPressedListener(Btn_flower, function()
        self:setMsgToServer(playerSeatIdx-1, roomPlayer.seatIdx-1, 1)
		self:removeFromParent()
    end)

    local Btn_diamond = gt.seekNodeByName(self.rootNode, "Btn_diamond")
    Btn_diamond:setVisible(roomPlayer.displaySeatIdx~=1)
    gt.addBtnPressedListener(Btn_diamond, function()
        self:setMsgToServer(playerSeatIdx-1, roomPlayer.seatIdx-1, 2)
		self:removeFromParent()
    end)

    local Btn_kiss = gt.seekNodeByName(self.rootNode, "Btn_kiss")
    Btn_kiss:setVisible(roomPlayer.displaySeatIdx~=1)
    gt.addBtnPressedListener(Btn_kiss, function()
        self:setMsgToServer(playerSeatIdx-1, roomPlayer.seatIdx-1, 3)
		self:removeFromParent()
    end)

    local Btn_gold = gt.seekNodeByName(self.rootNode, "Btn_gold")
	Btn_gold:setVisible(roomPlayer.displaySeatIdx~=1)
    gt.addBtnPressedListener(Btn_gold, function()
        self:setMsgToServer(playerSeatIdx-1, roomPlayer.seatIdx-1, 4)
		self:removeFromParent()
    end)



    local Btn_gold = gt.seekNodeByName(self.rootNode, "tea")
	Btn_gold:setVisible(roomPlayer.displaySeatIdx~=1)
    gt.addBtnPressedListener(Btn_gold, function()
        self:setMsgToServer(playerSeatIdx-1, roomPlayer.seatIdx-1, 5)
		self:removeFromParent()
    end)



    local Btn_gold = gt.seekNodeByName(self.rootNode, "good")
	Btn_gold:setVisible(roomPlayer.displaySeatIdx~=1)
    gt.addBtnPressedListener(Btn_gold, function()
        self:setMsgToServer(playerSeatIdx-1, roomPlayer.seatIdx-1, 6)
		self:removeFromParent()
    end)

end

function PKPlayerHeadInfo:setMsgToServer(fromid, toid, index)
    local msgToSend = {}
	msgToSend.kMId = gt.CG_CHAT_MSG
	msgToSend.kType = 5
	msgToSend.kId = toid  -- 发给谁
	msgToSend.kMsg = tostring(index) -- 发的内容
	msgToSend.kPos = fromid  --谁发的
	gt.socketClient:sendMessage(msgToSend)
end

function PKPlayerHeadInfo:onNodeEvent(eventName)
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

function PKPlayerHeadInfo:onTouchBegan(touch, event)
	return true
end

function PKPlayerHeadInfo:onTouchEnded(touch, event)
	self:removeFromParent()
end

return PKPlayerHeadInfo

