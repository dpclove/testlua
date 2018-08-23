
local gt = cc.exports.gt

local ChatPanel = class("ChatPanel", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function ChatPanel:ctor(msg,_type)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("ChatPanelNew.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
	self.msg = msg

	local wordBtn = gt.seekNodeByName(csbNode, "Btn_word")
	gt.addBtnPressedListener(wordBtn, function()
		-- local fixMsgNode = gt.seekNodeByName(csbNode, "Node_fixMsg")
		-- fixMsgNode:setVisible(true)

		-- local emojiNode = gt.seekNodeByName(csbNode, "Node_emoji_0")
		-- emojiNode:setVisible(false)
	end)

	local emojiBtn = gt.seekNodeByName(csbNode, "Btn_emoji")
	gt.addBtnPressedListener(emojiBtn, function()
		-- local fixMsgNode = gt.seekNodeByName(csbNode, "Node_fixMsg")
		-- fixMsgNode:setVisible(false)

		-- local emojiNode = gt.seekNodeByName(csbNode, "Node_emoji_0")
		-- emojiNode:setVisible(true)
	end)

	-- 固定短语
	local fixMsgNode = gt.seekNodeByName(csbNode, "Node_fixMsg")
	local fixMsgListVw = gt.seekNodeByName(fixMsgNode, "ListVw_fixMsg")
	if gt.gameType == "zjh" then 
		for i = 1, 13 do
			local fixMsgCell = cc.CSLoader:createNode("FixMsgCellLog.csb")
			local bgSpr = gt.seekNodeByName(fixMsgCell, "Spr_bg")
			local fixMsgLabel = gt.seekNodeByName(fixMsgCell, "Label_fixMsg")
			fixMsgLabel:setString(gt.getLocationString("LTKey_00299_" .. i))
			fixMsgLabel:setFontSize(30)
			local fixMsgItem = ccui.Widget:create()
			fixMsgItem:setTag(i)
			fixMsgItem:setTouchEnabled(true)
			fixMsgItem:setContentSize(bgSpr:getContentSize())
			fixMsgItem:addChild(fixMsgCell)
			fixMsgItem:addClickEventListener(handler(self, self.fixMsgClickEvent))
			fixMsgListVw:pushBackCustomItem(fixMsgItem)
		end
	elseif gt.gameType == "nn" then
		for i = 1, 20 do
			local fixMsgCell = cc.CSLoader:createNode("FixMsgCellLog.csb")
			local bgSpr = gt.seekNodeByName(fixMsgCell, "Spr_bg")
			local fixMsgLabel = gt.seekNodeByName(fixMsgCell, "Label_fixMsg")
			fixMsgLabel:setString(gt.getLocationString("LTKey_0070_" .. i))
			if i == 6 then
				fixMsgLabel:setFontSize(27)
			else
				fixMsgLabel:setFontSize(30)
			end
			fixMsgLabel:setPositionX(5)
			local fixMsgItem = ccui.Widget:create()
			fixMsgItem:setTag(i)
			fixMsgItem:setTouchEnabled(true)
			fixMsgItem:setContentSize(bgSpr:getContentSize())
			fixMsgItem:addChild(fixMsgCell)
			fixMsgItem:addClickEventListener(handler(self, self.fixMsgClickEvent))
			fixMsgListVw:pushBackCustomItem(fixMsgItem)
		end
	elseif gt.gameType == "sj" then
		for i=1,10 do
			local fixMsgCell = cc.CSLoader:createNode("FixMsgCellLog.csb")
			local bgSpr = gt.seekNodeByName(fixMsgCell, "Spr_bg")
			local fixMsgLabel = gt.seekNodeByName(fixMsgCell, "Label_fixMsg")
			fixMsgLabel:setString(gt.getLocationString("LTKey_0000" .. i))
			fixMsgLabel:setFontSize(30)
			local fixMsgItem = ccui.Widget:create()
			fixMsgItem:setTag(i)
			fixMsgItem:setTouchEnabled(true)
			fixMsgItem:setContentSize(bgSpr:getContentSize())
			fixMsgItem:addChild(fixMsgCell)
			fixMsgItem:addClickEventListener(handler(self, self.fixMsgClickEvent))
			fixMsgListVw:pushBackCustomItem(fixMsgItem)
		end
	elseif gt.gameType == "sde" then 
		for i = 1, 9 do
			local fixMsgCell = cc.CSLoader:createNode("FixMsgCellLog.csb")
			local bgSpr = gt.seekNodeByName(fixMsgCell, "Spr_bg")
			local fixMsgLabel = gt.seekNodeByName(fixMsgCell, "Label_fixMsg")
			fixMsgLabel:setString(gt.getLocationString("LTKey_sdr" .. i))
			fixMsgLabel:setFontSize(30)
			local fixMsgItem = ccui.Widget:create()
			fixMsgItem:setTag(i)
			fixMsgItem:setTouchEnabled(true)
			fixMsgItem:setContentSize(bgSpr:getContentSize())
			fixMsgItem:addChild(fixMsgCell)
			fixMsgItem:addClickEventListener(handler(self, self.fixMsgClickEvent))
			fixMsgListVw:pushBackCustomItem(fixMsgItem)
		end
	elseif gt.gameType == "sdy" then 
		for i = 1, 9 do
			local fixMsgCell = cc.CSLoader:createNode("FixMsgCellLog.csb")
			local bgSpr = gt.seekNodeByName(fixMsgCell, "Spr_bg")
			local fixMsgLabel = gt.seekNodeByName(fixMsgCell, "Label_fixMsg")
			fixMsgLabel:setString(gt.getLocationString("LTKey_sdr" .. i))
			fixMsgLabel:setFontSize(30)
			local fixMsgItem = ccui.Widget:create()
			fixMsgItem:setTag(i)
			fixMsgItem:setTouchEnabled(true)
			fixMsgItem:setContentSize(bgSpr:getContentSize())
			fixMsgItem:addChild(fixMsgCell)
			fixMsgItem:addClickEventListener(handler(self, self.fixMsgClickEvent))
			fixMsgListVw:pushBackCustomItem(fixMsgItem)
		end
	elseif gt.gameType == "wrbf" then 
		for i = 1, 9 do
			local fixMsgCell = cc.CSLoader:createNode("FixMsgCellLog.csb")
			local bgSpr = gt.seekNodeByName(fixMsgCell, "Spr_bg")
			local fixMsgLabel = gt.seekNodeByName(fixMsgCell, "Label_fixMsg")
			fixMsgLabel:setString(gt.getLocationString("LTKey_sdr" .. i))
			fixMsgLabel:setFontSize(30)
			local fixMsgItem = ccui.Widget:create()
			fixMsgItem:setTag(i)
			fixMsgItem:setTouchEnabled(true)
			fixMsgItem:setContentSize(bgSpr:getContentSize())
			fixMsgItem:addChild(fixMsgCell)
			fixMsgItem:addClickEventListener(handler(self, self.fixMsgClickEvent))
			fixMsgListVw:pushBackCustomItem(fixMsgItem)
		end
	else
		for i = 1, 10 do
			local fixMsgCell = cc.CSLoader:createNode("FixMsgCellLog.csb")
			local bgSpr = gt.seekNodeByName(fixMsgCell, "Spr_bg")
			local fixMsgLabel = gt.seekNodeByName(fixMsgCell, "Label_fixMsg")
			fixMsgLabel:setString(gt.getLocationString("LTKey_00" .. i+58))
			fixMsgLabel:setFontSize(30)
			local fixMsgItem = ccui.Widget:create()
			fixMsgItem:setTag(i)
			fixMsgItem:setTouchEnabled(true)
			fixMsgItem:setContentSize(bgSpr:getContentSize())
			fixMsgItem:addChild(fixMsgCell)
			fixMsgItem:addClickEventListener(handler(self, self.fixMsgClickEvent))
			fixMsgListVw:pushBackCustomItem(fixMsgItem)
		end
	end
	require("client/tools/ShieldWord")

	if _type == 1 then 
		gt.seekNodeByName(csbNode, "Spr_inputBg"):setVisible(false)
		gt.seekNodeByName(csbNode, "TxtField_inputMsg"):setVisible(false)
		gt.seekNodeByName(csbNode, "Btn_send"):setVisible(false)
		gt.seekNodeByName(csbNode, "Text"):setVisible(true)
	else
		gt.seekNodeByName(csbNode, "Text"):setVisible(false)
		gt.seekNodeByName(csbNode, "Spr_inputBg"):setVisible(true)
		gt.seekNodeByName(csbNode, "TxtField_inputMsg"):setVisible(true
			)
		gt.seekNodeByName(csbNode, "Btn_send"):setVisible(true
			)
	end


	local sendBtn = gt.seekNodeByName(csbNode, "Btn_send")
	gt.addBtnPressedListener(sendBtn, function()
		gt.soundEngine:playEffect("common/SpecOk", false, true)

		if _type == 1 then 

			local scene = display.getRunningScene()
			if scene then 
				Toast.showToast(scene, "当前防作弊房间，禁止发送自定义消息！", 1)
			end
			return

		end


		local inputMsgTxtField = gt.seekNodeByName(csbNode, "TxtField_inputMsg")
		local inputString = inputMsgTxtField:getString()
		
		if string.len(inputString) > 0 then
			self:closeKeyboard()
			self:sendChatMsg(gt.ChatType.INPUT_MSG, 0, inputString)
		end
	end)

	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("images/EmotionOut.plist")
	-- 表情符号新zy
	local emojiNode = gt.seekNodeByName(csbNode, "Node_emoji_0")
	-- emojiNode:setVisible(false)
	local emojiScrollVw = gt.seekNodeByName(emojiNode, "ScrollVw_emoji")
	local emojiNameArray = {
		"biaoqing1.png", "biaoqing2.png", "biaoqing3.png",
		"biaoqing4.png", "biaoqing5.png", "biaoqing6.png",
		"biaoqing7.png", "biaoqing8.png",
	}
	local emojiSpr = gt.seekNodeByName(emojiScrollVw, "Spr_emoji")
	emojiScrollVw:removeChild(emojiSpr)
	local emojiStartPos = cc.p(emojiSpr:getPosition())
	local emojiPos = emojiStartPos
	for i, v in ipairs(emojiNameArray) do
		local emojiSpr = cc.Sprite:create("res/biaoqing_icon/" .. v)
		local emojiSize = emojiSpr:getContentSize()
		-- emojiSpr:setScale(0.6)
		emojiSpr:setPosition(emojiSize.width * 0.5, emojiSize.height * 0.5)
		local emojiWidget = ccui.Widget:create()
		emojiWidget:setTouchEnabled(true)
		emojiWidget:setTag(i)
		emojiWidget:setName(v)
		emojiWidget:setContentSize(emojiSize)
		emojiWidget:addChild(emojiSpr)
		emojiScrollVw:addChild(emojiWidget)
		emojiWidget:setPosition(emojiPos)
		emojiWidget:addClickEventListener(handler(self, self.emojiClickEvent))

		local row = math.floor(i / 2)
		local col = i % 2
		local offset = 0
		if i == 1 then
			offset = 5
		end
		emojiPos = cc.pAdd(emojiStartPos, cc.p(col * (emojiSize.width + 35 - offset), -row * (emojiSize.height + 25)))
	end



	--聊天记录
	local emojiNode = gt.seekNodeByName(csbNode, "Node_emoji")
	emojiNode:setVisible(false)
	local fixMsgListVw = gt.seekNodeByName(emojiNode, "ListVw_fixMsg")
	if msg ~= false then
		for i = #msg, 1, -1 do
			local fixMsgCell = cc.CSLoader:createNode("FixMsgCellLog.csb")
			local bgSpr = gt.seekNodeByName(fixMsgCell, "Spr_bg")
			local fixMsgLabel = gt.seekNodeByName(fixMsgCell, "Label_fixMsg")
			local hasShieldWord,content = gt.CheckShieldWord(msg[i].content)
			fixMsgLabel:setString(msg[i].content)
			gt.log("聊天记录======"..msg[i].content)
			if hasShieldWord == false then
				fixMsgLabel:setString(msg[i].content)
			else
				fixMsgLabel:setString(content)
			end
			
			local fixMsgItem = ccui.Widget:create()
			fixMsgItem:setTag(i)
			fixMsgItem:setTouchEnabled(true)
			fixMsgItem:setContentSize(bgSpr:getContentSize())
			fixMsgItem:addChild(fixMsgCell)
			-- fixMsgItem:addClickEventListener(handler(self, self.fixMsgLogClickEvent))
			fixMsgListVw:pushBackCustomItem(fixMsgItem)
		end
	end
	local inputMsgTxtField = gt.seekNodeByName(csbNode, "TxtField_inputMsg")
	inputMsgTxtField:setPlaceHolderColor(cc.c3b(255,255,255))
	inputMsgTxtField:addEventListener(handler(self, self.TxtFieldClickEvent))

	local msgTabBtn = gt.seekNodeByName(csbNode, "Btn_msgTab")
	msgTabBtn:setTag(1)
	msgTabBtn:addClickEventListener(handler(self, self.switchChatTab))
	local emojiTabBtn = gt.seekNodeByName(csbNode, "Btn_emojiTab")
	emojiTabBtn:setTag(2)
	emojiTabBtn:addClickEventListener(handler(self, self.switchChatTab))
	self.chatTabBtns = {{msgTabBtn, fixMsgNode}, {emojiTabBtn, emojiNode}}

	self:switchChatTab(msgTabBtn)



end

function ChatPanel:onNodeEvent(eventName)
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
		display.removeSpriteFrames("images/chat.plist","images/chat.png")
		-- display.removeSpriteFrames("images/EmotionOut.plist","images/EmotionOut.pvr.ccz")
	end
end

function ChatPanel:onTouchBegan(touch, event)
	return true
end

function ChatPanel:onTouchEnded(touch, event)
	self:removeFromParent()
end

function ChatPanel:switchChatTab(sender)
	local tabTag = sender:getTag()
	for i, tabData in ipairs(self.chatTabBtns) do
		if i == tabTag then
			tabData[1]:setBrightStyle(ccui.BrightStyle.highlight)
			tabData[2]:setVisible(true)
		else
			tabData[1]:setBrightStyle(ccui.BrightStyle.normal)
			tabData[2]:setVisible(false)
		end
	end
	local fixMsgNode = gt.seekNodeByName(csbNode, "Node_fixMsg")
	local emojiNode = gt.seekNodeByName(csbNode, "Node_emoji")
end

function ChatPanel:fixMsgClickEvent(sender, eventType)
	self:closeKeyboard()
	self:sendChatMsg(gt.ChatType.FIX_MSG, sender:getTag())
end

function ChatPanel:emojiClickEvent(sender)
	self:closeKeyboard()
	self:sendChatMsg(gt.ChatType.EMOJI, 0, sender:getName())
end

function ChatPanel:fixMsgLogClickEvent(sender, eventType)
	self:closeKeyboard()
	self:sendChatMsg(gt.ChatType.INPUT_MSG,sender:getTag(),self.msg[sender:getTag()].abstract)
end

function ChatPanel:TxtFieldClickEvent(sender, eventType)

	-- if eventType == 0 then
	-- 	if gt.isIOSPlatform() then
	-- 		local moveTo = cc.MoveTo:create(0.5,cc.p(0,280))
	-- 		self:runAction(moveTo)
	-- 	end
	-- elseif eventType == 1 then
	-- 	if gt.isIOSPlatform() then
	-- 		local moveTo = cc.MoveTo:create(0.5,cc.p(0,0))
	-- 		self:runAction(moveTo)
	-- 	end
	-- end

	if eventType == ccui.TextFiledEventType.attach_with_ime then
        gt.log("TextFiledEventType.attach_with_ime")
        if gt.isIOSPlatform() then
			local moveTo = cc.MoveTo:create(0.5,cc.p(0,250))
			self:runAction(moveTo)
		end
    elseif eventType == ccui.TextFiledEventType.detach_with_ime then
        gt.log("TextFiledEventType.detach_with_ime")
        if gt.isIOSPlatform() then
			local moveTo = cc.MoveTo:create(0.5,cc.p(0,0))
			self:runAction(moveTo)
		end
    elseif eventType == ccui.TextFiledEventType.insert_text then
        gt.log("TextFiledEventType.insert_text")
    elseif eventType == ccui.TextFiledEventType.delete_backward then
        gt.log("TextFiledEventType.delete_backward")
    end
 end 

function ChatPanel:sendChatMsg(chatType, chatIdx, chatString)
gt.log(debug.traceback())
	chatIdx = chatIdx or 1
	chatString = chatString or ""

	local msgToSend = {}
	msgToSend.kMId = gt.CG_CHAT_MSG

	msgToSend.kType = chatType
	msgToSend.kId = chatIdx
	msgToSend.kMsg = chatString
	gt.socketClient:sendMessage(msgToSend)

	self:removeFromParent()
end

function ChatPanel:closeKeyboard()
	local glView = cc.Director:getInstance():getOpenGLView()
    glView:setIMEKeyboardState(false)
end

return ChatPanel


