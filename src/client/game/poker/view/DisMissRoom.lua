
local gt = cc.exports.gt

local Utils = require("app/Utils")
local DisMissRoom = class("DisMissRoom", function()
	return cc.Layer:create()
end)

function DisMissRoom:ctor(roomPlayers, playerSeatIdx, msgTbl)
	gt.log("解散房间消息")
	dump(msgTbl)

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    
	self.rootNode = cc.CSLoader:createNode("ReleaseDesk.csb")
	self.rootNode:setAnchorPoint(0.5, 0.5)
	self:addChild(self.rootNode)

	local playerNum = #roomPlayers   --玩家人数
	-- 具体信息
	for seatIdx, roomPlayer in ipairs(roomPlayers) do
		local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
        -- 昵称
		local nicknameLabel = gt.seekNodeByName(playerReportNode, "Text_name")
		nicknameLabel:setString(roomPlayer.nickname)  
        -- 状态
        local Text_status = gt.seekNodeByName(playerReportNode, "Text_status")
  
        if msgTbl.kUserState[seatIdx] == 1 then
		    Text_status:setString("同意") 
            if playerSeatIdx == seatIdx then
	            local Btn_quxiao = gt.seekNodeByName(self.rootNode, "Btn_jujue")
	            local Btn_queding = gt.seekNodeByName(self.rootNode, "Btn_queding")
                Btn_quxiao:setVisible(false)
                Btn_queding:setVisible(false)
            end
        elseif  msgTbl.kUserState[seatIdx] == 2 then
		    Text_status:setString("拒绝") 
            if playerSeatIdx == seatIdx then
	            local Btn_quxiao = gt.seekNodeByName(self.rootNode, "Btn_jujue")
	            local Btn_queding = gt.seekNodeByName(self.rootNode, "Btn_queding")
                Btn_quxiao:setVisible(false)
                Btn_queding:setVisible(false)
            end
            local msg = {}
		    gt.dispatchEvent(gt.EventType.REMOVE_RELEASE_DESK, msg)
        else
		    Text_status:setString("待确认")
        end
    end

	-- 拒绝
	local Btn_quxiao = gt.seekNodeByName(self.rootNode, "Btn_jujue")
	gt.addBtnPressedListener(Btn_quxiao, function()
		local msgToSend = {}
	    msgToSend.m_msgId = gt.CG_APPLY_DISMISS
	    msgToSend.m_pos = playerSeatIdx - 1
	    msgToSend.m_flag = 2
	    gt.socketClient:sendMessage(msgToSend)
	end)

	-- 同意
	local Btn_queding = gt.seekNodeByName(self.rootNode, "Btn_queding")
	gt.addBtnPressedListener(Btn_queding, function()
    	local msgToSend = {}
	    msgToSend.m_msgId = gt.CG_APPLY_DISMISS
	    msgToSend.m_pos = playerSeatIdx - 1
	    msgToSend.m_flag = 1
	    gt.socketClient:sendMessage(msgToSend)
	end)
end

function DisMissRoom:onNodeEvent(eventName)
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

function DisMissRoom:onTouchBegan(touch, event)
	return true

end
return DisMissRoom

