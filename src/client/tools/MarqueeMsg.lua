
-- Creator ArthurSong
-- Create Time 2016/2/23

local gt = cc.exports.gt

local MarqueeMsg = class("MarqueeMsg", function()
	return cc.CSLoader:createNode("MarqueeBar.csb")
end)

function MarqueeMsg:ctor( parentNode, callback )
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	self.msgTextCache = {}
	self.showNextMsg = true

	self.m_parentNode = parentNode

	--跑马灯点击
	local Btn_bg = ccui.Button:create("res/images/sx_club_play/sx_club_play_notice_bg.png", "res/images/sx_club_play/sx_club_play_notice_bg.png")
	Btn_bg:setLocalZOrder(1)
	gt.seekNodeByName(self, "Panel_bar"):addClickEventListener(callback)
	self:addChild(Btn_bg)
end

function MarqueeMsg:onNodeEvent(eventName)
	if "enter" == eventName then
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
	elseif "exit" == eventName then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function MarqueeMsg:update(delta)
	if not self.showNextMsg then
		return
	end
	if self.m_repeattimes then
		if self.m_parentNode and self.m_repeattimes<=0 then
			self.m_parentNode:setVisible( false )
			return
		end
	end

	if #self.msgTextCache == 0 then
		return
	end

	self.showNextMsg = false

	local msgText = self.msgTextCache[1]
	local msgBarPanel = gt.seekNodeByName(self, "Panel_bar")
	msgBarPanel:setLocalZOrder(2)
	local barSize = msgBarPanel:getContentSize()
	local msgContentLabel = gt.createTTFLabel(msgText, 28)
	msgContentLabel:setColor(cc.c3b(253,236,158))
	local textWidth = msgContentLabel:getContentSize().width
	msgContentLabel:setPosition(barSize.width + textWidth * 0.5, barSize.height * 0.5)
	msgBarPanel:addChild(msgContentLabel)
	msgContentLabel:stopAllActions()
	local moveToAction = cc.MoveTo:create(30, cc.p(-textWidth * 0.5, barSize.height * 0.5))
	local callFunc = cc.CallFunc:create(function(sender)
		self.showNextMsg = true
		sender:removeFromParent()
	end)
	msgContentLabel:runAction(cc.Sequence:create(moveToAction, callFunc))

	if self.m_repeattimes then -- 如果有次数限制
		self.m_repeattimes = self.m_repeattimes - 1
	end
end

function MarqueeMsg:showMsg(_msgText, _repeattimes)
	local msgText = _msgText or "欢迎来到好运来山西麻将。请玩家文明娱乐，严禁赌博，如发现有赌博行为，将封停账号，并向公安机关举报！"

	if not msgText or string.len(msgText) == 0 then
		return
	end

	table.insert(self.msgTextCache, msgText)

	if self.m_repeattimes then
		self.msgTextCache = {}
		table.insert(self.msgTextCache, msgText)
	end
	self.m_repeattimes = _repeattimes
	if self.m_parentNode then
		self.m_parentNode:setVisible( true )
	end
end

return MarqueeMsg

