
local gt = cc.exports.gt
local Utils = cc.exports.Utils
local HistoryRecord = class("HistoryRecord", function()
	return gt.createMaskLayer()--cc.Layer:create()
end)

------------
--param msgTbl ：msgTBl战绩服务器数据
function HistoryRecord:ctor(msgTbl,num)
	gt.dump(msgTbl)
	
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_POKER_ROOM_LOG, self, self.onRcvHistoryRecord)
	gt.socketClient:registerMsgListener(gt.GC_HISTORY_RECORD, self, self.onRcvHistoryRecord)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    
	local csbNode = cc.CSLoader:createNode("HistoryRecord.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
	
	if gt.isAppStoreInReview then
		local bokehImg = gt.seekNodeByName(csbNode, "Img_bokeh")
		if bokehImg then
			bokehImg:setVisible(false)
		end
	end

	-- 战绩标题
	-- local titleRoomNode = gt.seekNodeByName(csbNode, "Node_titleRoom")
	-- titleRoomNode:setVisible(false)

	--无战绩提示
	-- local emptyLabel = gt.seekNodeByName(csbNode, "Text_tip_noData")
	-- emptyLabel:hide()

	--第一层标题
	-- self.titleNode = gt.seekNodeByName(csbNode, "Node_title")




	gt.log("type___________________________",num)

	local historyListVw = gt.seekNodeByName(self.rootNode, "ListVw_content")
	local historyListVw1 = gt.seekNodeByName(self.rootNode, "ListVw_content_1")
	self.mineBtn = gt.seekNodeByName(csbNode, "Btn_mine")
	self.otherBtn = gt.seekNodeByName(csbNode, "Btn_other")
	self._type = 2 -- 1 mj 2 扑克 3 
	local bg = gt.seekNodeByName(csbNode, "Image")
	gt.addBtnPressedListener(self.mineBtn,function ()

		
		if not self.historyMsgTbl then 
			gt.showLoadingTips("读取数据中")
			local msgToSend = {}
			msgToSend.kMId = gt.CG_HISTORY_RECORD
			
			gt.socketClient:sendMessage(msgToSend)

		end
			self.otherBtn:setBright(true)
			self.otherBtn:setTouchEnabled(true)

			self.mineBtn:setBright(false)
			self.mineBtn:setTouchEnabled(false)


			self.poker_btn:setBright(true)
			self.poker_btn:setTouchEnabled(true)
			self._type = 1
			gt.seekNodeByName(self.rootNode, "Node_view"):hide()
			historyListVw:show()
			historyListVw1:hide()
			bg:loadTexture("mj_bg.png")
	end)
	self.mineBtn:setPressedActionEnabled(false)
	-- self.mineBtn:setBright(false)
	-- self.mineBtn:setTouchEnabled(false)
	gt.seekNodeByName(self.rootNode, "Node_view"):hide()

	gt.addBtnPressedListener(self.otherBtn,function ()
		self.otherBtn:setBright(false)
		self.otherBtn:setTouchEnabled(false)

		self.mineBtn:setBright(true)
		self.mineBtn:setTouchEnabled(true)

		self.poker_btn:setBright(true)
		self.poker_btn:setTouchEnabled(true)
		self._type = 3
		gt.seekNodeByName(self.rootNode, "Node_view"):show()
		historyListVw:hide()
		historyListVw1:hide()
		bg:loadTexture("mj_bg.png")
	end)
	self.otherBtn:setPressedActionEnabled(false)

	self.poker_btn = gt.seekNodeByName(csbNode, "poker_btn")
	gt.addBtnPressedListener(self.poker_btn,function()
		
		if not self.historyMsgTbl then

			gt.showLoadingTips("读取数据中")
			local m = {}
			m.kMId = 	gt.MSG_C_2_S_POKER_ROOM_LOG
			m.kUserId = gt.playerData.uid
			gt.socketClient:sendMessage(m)

		end
				--todo
			self.poker_btn:setBright(false)
			self.poker_btn:setTouchEnabled(false)

			self.mineBtn:setBright(true)
			self.mineBtn:setTouchEnabled(true)

			self.otherBtn:setBright(true)
			self.otherBtn:setTouchEnabled(true)
			self._type = 2
			gt.seekNodeByName(self.rootNode, "Node_view"):hide()
			historyListVw:hide()
			historyListVw1:show()
			bg:loadTexture("poker_bg.png")
	end)

	if self._type  == 1 then

		self.otherBtn:setBright(true)
		self.otherBtn:setTouchEnabled(true)

		self.mineBtn:setBright(false)
		self.mineBtn:setTouchEnabled(false)


		self.poker_btn:setBright(true)
		self.poker_btn:setTouchEnabled(true)
		self.historyMsgTbl = msgTbl
		self:onRcvHistoryRecord(self.historyMsgTbl)

	elseif self._type == 2 then 
		self.historyMsgTbl = msgTbl
		self:onRcvHistoryRecord(self.historyMsgTbl)

		self.poker_btn:setBright(false)
		self.poker_btn:setTouchEnabled(false)

		self.mineBtn:setBright(true)
		self.mineBtn:setTouchEnabled(true)

		self.otherBtn:setBright(true)
		self.otherBtn:setTouchEnabled(true)

	elseif self._type == 3 then 
		self.historyMsgTbl = msgTbl
		self:onRcvHistoryRecord(self.historyMsgTbl)
		self.poker_btn:setBright(true)
		self.poker_btn:setTouchEnabled(true)

		self.mineBtn:setBright(true)
		self.mineBtn:setTouchEnabled(true)

		self.otherBtn:setBright(false)
		self.otherBtn:setTouchEnabled(false)
	end


	-- 返回按钮
	local backBtn = gt.seekNodeByName(csbNode, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
	
		
		local historyListVw = gt.seekNodeByName(self.rootNode, "ListVw_content")
		if historyListVw:isVisible() then
			-- 移除消息回调
			
			gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_POKER_RESPOND_VIDEO_ID)
			gt.log("exit_________________________1")

			-- 移除界面,返回主界面
			self:removeFromParent()
			
		else
			gt.log("exit_________________________2")
			-- 隐藏详细信息
			--titleRoomNode:hide()
			gt.seekNodeByName(self.rootNode, "Node_text"):setVisible(true)
			historyListVw:show()
			--self.titleNode:show()
			local historyDetailNode = gt.seekNodeByName(self.rootNode, "Node_historyDetail")
			gt.dump(historyDetailNode:getChildren())
			if #historyDetailNode:getChildren() == 0 then
				
				self:removeFromParent()
			else
				historyDetailNode:removeAllChildren()
			end
			-- 显示查看他人战绩节点
			--gt.seekNodeByName(self.rootNode, "Node_view"):show()
		end
		
	end)

	-- 回放码输入
	local inputLabel = gt.seekNodeByName(csbNode, "text_input_view")
	-- 查看他人战绩按钮
	local replayBtn = gt.seekNodeByName(csbNode, "btn_view")
	gt.addBtnPressedListener(replayBtn, function(sender)
		local codeStr = inputLabel:getString()
		local codeNum = tonumber(codeStr)
		if codeNum then
			-- 发送请求战绩消息
			local msgToSend = {}
			msgToSend.kMId =  gt.GC_GET_VIDEO--gt.CG_SHARE_REPLAY
			msgToSend.kVideoId = codeStr--m_shareID
			gt.socketClient:sendMessage(msgToSend)
		else
			Toast.showToast(self, "你输入的回访码有误，请重新输入", 2)
		end
	end)

	--  底部背景条
	local Spr_btmTips = gt.seekNodeByName(self, "Spr_btmTips")
	
	-- 注册消息回调
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_POKER_RESPOND_VIDEO_ID, self, self.onRcvReplay)
	gt.socketClient:registerMsgListener(gt.GC_SHARE_BTN, self, self.onRcvShare)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_POKER_MATCH_LOG, self, self.onRcvHistoryOne)
	gt.socketClient:registerMsgListener(gt.GC_SHARE_REPLAY, self, self.onRcvShareReplay)
end

function HistoryRecord:switch(historyListVw)

	if historyListVw then 
		historyListVw:removeAllChildren()

	end

end

function HistoryRecord:onNodeEvent(eventName)
	if "enter" == eventName then
		-- 触摸事件
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		-- 移除触摸事件
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
		gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_POKER_RESPOND_VIDEO_ID)
		gt.socketClient:unregisterMsgListener(gt.GC_SHARE_BTN)
		gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_POKER_MATCH_LOG)
		gt.socketClient:unregisterMsgListener(gt.GC_SHARE_REPLAY)
	--	cc.UserDefault:getInstance():setIntegerForKey("zj_type", self._type) -- 1 mj 2 扑克 3 
		gt.socketClient:unregisterMsgListener(gt.GC_HISTORY_RECORD)
		gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_POKER_ROOM_LOG)
	end
end

function HistoryRecord:onTouchBegan(touch, event)
	return true
end


function HistoryRecord:sendHistoryOne(sender, eventType)
	local msgToSend = {}
	msgToSend.kMId = gt.MSG_C_2_S_POKER_MATCH_LOG
	local data = self.historyMsgTbl.kData[sender:getTag()]
	msgToSend.kTime = data.kTime
	msgToSend.kUserId = gt.playerData.uid  --玩家自己id
	gt.dump(self.cellDatas[sender:getTag()])
	msgToSend.kPos = self.cellDatas[sender:getTag()].kUserid[1]  --房主id
	msgToSend.kDeskId = data.kDeskId
	gt.socketClient:sendMessage(msgToSend)
	self.m_sender = sender
	gt.showLoadingTips("读取数据中")
end

-- 服务器返回单把(8局)数据
function HistoryRecord:onRcvHistoryOne(msgTbl)
	gt.removeLoadingTips()

	gt.log("tuisong_____________________")
	gt.dump(msgTbl)

	if msgTbl.kSize == 0 then
		return false
	end
	
	self.historyMsgTbl.kData[self.m_sender:getTag()].kMatch = msgTbl.kData

	self:historyItemClickEvent(self.m_sender)
end

function HistoryRecord:onRcvHistoryRecord(msgTbl)
	gt.dump(msgTbl)
	gt.removeLoadingTips()
	-- local emptyLabel = gt.seekNodeByName(self.rootNode, "Text_tip_noData")

	local historyListVw = nil
	if self._type == 2 then 
		self.historyMsgTbl = msgTbl

		historyListVw = gt.seekNodeByName(self.rootNode, "ListVw_content_1")
	else
		self.historyMsgTbl = msgTbl

		historyListVw = gt.seekNodeByName(self.rootNode, "ListVw_content")
	end

	if #msgTbl.kData == 0 then
		--没有战绩
		-- emptyLabel:show()
	else
		-- emptyLabel:hide()
		-- 显示战绩列表
		--self.historyMsgTbl = msgTbl
		if self._type == 2 then 
			self.cellDatas = {}
		else
			self.cellDatas = {}
		end

		historyListVw:setVisible(true)
		for i, cellData in ipairs(msgTbl.kData) do
			if self._type == 2 then 
				table.insert(self.cellDatas, cellData)
			else
				table.insert(self.cellDatas, cellData)
			end
			local historyItem = self:createHistoryItem(i, cellData)
			historyListVw:pushBackCustomItem(historyItem)
		end
	end
end

function HistoryRecord:onRcvReplay(msgTbl)
	gt.log("chaxun__________________________")
	if msgTbl.kState == 101 then 
		local replayLayer = require("client/game/poker/view/playback"):create(msgTbl)
		self:addChild(replayLayer, 6)
	elseif msgTbl.kState == 107 then 
		local replayLayer = require("client/game/poker/view/PKReplayScene"):create(msgTbl, 107)
		self:addChild(replayLayer, 6)
	elseif msgTbl.kState == 109 then 
		local replayLayer = require("client/game/poker/view/PKReplaySceneSdy"):create(msgTbl)
		self:addChild(replayLayer, 6)
	elseif msgTbl.kState == 110 then 
		local replayLayer = require("client/game/poker/view/PKReplayScene"):create(msgTbl, 110)
		self:addChild(replayLayer, 6)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 创建战绩条目
-- @param cellData 条目数据
-- end --
function HistoryRecord:createHistoryItem(tag, cellData)





	gt.log("log________________")
	gt.dump(cellData)
	local cellNode = nil
	local num = 10
	cellNode = cc.CSLoader:createNode("HistoryCell.csb")

	-- 序号
	-- local numLabel = gt.seekNodeByName(cellNode, "Label_num")
	-- numLabel:setString(tostring(tag))
	-- numLabel:hide()
	-- 房间号
	local roomIDLabel = gt.seekNodeByName(cellNode, "Label_roomID")
	--roomIDLabel:setString(gt.getLocationString("LTKey_0039", cellData.m_deskId))
	roomIDLabel:setString(string.format("%d",cellData.kDeskId))
	-- 对战时间
	local timeLabel = gt.seekNodeByName(cellNode, "Label_time")
	local timeTbl = os.date("*t", cellData.kTime)
	timeLabel:setString(gt.getLocationString("LTKey_0040", timeTbl.year, timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min, timeTbl.sec))
	
	-- 玩家昵称+分数
	for i=1, num do
		local nicknameLabel = gt.seekNodeByName(cellNode, "Label_nickname_" .. i)
		nicknameLabel:setString("")
		local scoreLabel = gt.seekNodeByName(cellNode, "Label_score_" .. i)
		scoreLabel:setString("")
	end

	for i, v in ipairs(cellData.kUserid) do
		-- print("玩家们的分数" .. cellData.m_score[i])
		local nicknameLabel = gt.seekNodeByName(cellNode, "Label_nickname_" .. i)
		local scoreLabel = gt.seekNodeByName(cellNode, "Label_score_" .. i)
		
		if v ~= 0 then 
			nicknameLabel:setString(cellData.kNike[i])
			scoreLabel:setString(tostring(cellData.kScore[i]))
		end
	end

	local loopBtn = gt.seekNodeByName(cellNode, "Button_1")
	loopBtn:setScale(0.7)
	-- 类型
	local gameTypeLabel = gt.seekNodeByName(cellNode, "Label_gameType")
	if cellData.kFlag == 102 then
		gameTypeLabel:setString("三张牌")
		loopBtn:setVisible(false)
	elseif cellData.kFlag == 103 then
		gameTypeLabel:setString("牛牛")
		loopBtn:setVisible(false)
	elseif cellData.kFlag == 101 then
		gameTypeLabel:setString("斗地主")
		loopBtn:setVisible(true)
	elseif cellData.kFlag == 106 then
		gameTypeLabel:setString("双升")
		loopBtn:setVisible(false)
	elseif cellData.kFlag == 107 then
		gameTypeLabel:setString("三打二")
		loopBtn:setVisible(true)
	elseif cellData.kFlag == 109 then
		gameTypeLabel:setString("三打一")
	elseif cellData.kFlag == 110 then
		gameTypeLabel:setString("五人百分")
		loopBtn:setVisible(true)
	end



	if loopBtn:isVisible() then 
		loopBtn:setTag(tag)
		gt.addBtnPressedListener(loopBtn, function(sender)
			local msgToSend = {}
			msgToSend.kMId = gt.MSG_C_2_S_POKER_MATCH_LOG
			local data = self.historyMsgTbl.kData[sender:getTag()]
			msgToSend.kTime = data.kTime
			msgToSend.kUserId = gt.playerData.uid  --玩家自己id
			msgToSend.kPos = self.cellDatas[sender:getTag()].kUserid[1]  --房主id
			msgToSend.kDeskId = data.kDeskId
			gt.socketClient:sendMessage(msgToSend)
			self.m_sender = sender
			gt.showLoadingTips("读取数据中")
		end)
	end
	local cellSize = cellNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(cellNode)
	if loopBtn:isVisible() then 
		cellItem:addClickEventListener(handler(self, self.sendHistoryOne))
	end

	return cellItem
end

function HistoryRecord:historyItemClickEvent(sender, eventType)
	--隐藏开始列表界面的标题
	-- self.titleNode:hide()
	gt.seekNodeByName(self.rootNode, "Node_text"):setVisible(false)
	-- 隐藏历史记录
	local historyListVw = gt.seekNodeByName(self.rootNode, "ListVw_content")
	historyListVw:setVisible(false)
	-- 屏蔽查看他人战绩节点
	gt.seekNodeByName(self.rootNode, "Node_view"):hide()
	-- 切换标题
	-- local titleRoomNode = gt.seekNodeByName(self.rootNode, "Node_titleRoom")
	-- titleRoomNode:setVisible(true)

	local itemTag = sender:getTag()
	local cellData = self.historyMsgTbl.kData[itemTag]
	local historyDetailNode = gt.seekNodeByName(self.rootNode, "Node_historyDetail")
	local detailPanel = cc.CSLoader:createNode("HistoryDetail.csb")
	detailPanel:setAnchorPoint(0.5, 0.5)
	historyDetailNode:addChild(detailPanel)
	detailPanel:setPositionY(47)
     --label显示框
 --    self.labelFrame={}
 --    for i=1,4 do
 --    	local frame=gt.seekNodeByName(detailPanel,"Image_frame" .. i)
 --    	table.insert(self.labelFrame,frame)
 --    end
	-- -- 初始化
	-- for i=1, 4 do
	-- 	local nicknameLabel = gt.seekNodeByName(detailPanel, "Label_nickname_" .. i)
	-- 	nicknameLabel:setString("")
	-- end 
	-- -- 玩家昵称
	-- self.labelsWidth={}
	-- for i, v in ipairs(cellData.m_nike) do
	-- 	local nicknameLabel = gt.seekNodeByName(detailPanel, "Label_nickname_" .. i)
	-- 	local framenickLabel=gt.seekNodeByName()
	-- 	if cellData.m_flag == 100006 and i == 4 then
	-- 		break
	-- 	end 
	-- 	--v = string.gsub(v, " ", "")
 --        local name=gt.seekNodeByName(self.labelFrame[i],"Label_"..i)
 --        name:setString(v)
 --        self.labelFrame[i]:setContentSize(cc.size(name:getContentSize().width+8,self.labelFrame[i]:getContentSize().height))
	-- 	self.labelFrame[i]:setPosition(nicknameLabel:getPositionX()-name:getContentSize().width/2,595)
	-- 	--table.insert(self.labelsWidth,self:getStringLen(v)*36)
	-- 	nicknameLabel:setString(self:getCutName(v,8,6))
	-- 	nicknameLabel:setTouchEnabled(true)
	-- 	nicknameLabel:setTag(i)
		
	-- 	nicknameLabel.m_name = v
	-- 	    local function touchEvent(sender, eventType)
	--             if eventType == ccui.TouchEventType.began then  
 --                          self.labelFrame[sender:getTag()]:setVisible(true)
	--             	elseif eventType == ccui.TouchEventType.ended
	--             		or eventType == ccui.TouchEventType.canceled then
 --                          self.labelFrame[sender:getTag()]:setVisible(false)
	--             end
 --            end
 --        nicknameLabel:addTouchEventListener(touchEvent)
 --    end
	
	-- 对应详细记录信息
	local contentListVw = gt.seekNodeByName(detailPanel, "ListVw_content")
	gt.dump(cellData.kMatch)
	for i, v in ipairs(cellData.kMatch) do
		local detailCellNode = cc.CSLoader:createNode("HistoryDetailCell.csb")
		local num = 3

		if cellData.kFlag == 107 then 
			num = 5
			detailCellNode = cc.CSLoader:createNode("HistoryDetailCell_sde.csb")
			gt.seekNodeByName(detailPanel, "Sprite_1"):setVisible(false)
			gt.seekNodeByName(detailPanel, "Sprite_2"):setVisible(true)
			gt.seekNodeByName(detailPanel, "Sprite_4"):setVisible(false)
		elseif cellData.kFlag == 109 then
			num = 4
			detailCellNode = cc.CSLoader:createNode("HistoryDetailCell_sdy.csb")
			gt.seekNodeByName(detailPanel, "Sprite_1"):setVisible(false)
			gt.seekNodeByName(detailPanel, "Sprite_2"):setVisible(false)
			gt.seekNodeByName(detailPanel, "Sprite_4"):setVisible(true)
		elseif cellData.kFlag == 110 then 
			num = 5
			detailCellNode = cc.CSLoader:createNode("HistoryDetailCell_sde.csb")
			gt.seekNodeByName(detailPanel, "Sprite_1"):setVisible(false)
			gt.seekNodeByName(detailPanel, "Sprite_2"):setVisible(true)
			gt.seekNodeByName(detailPanel, "Sprite_4"):setVisible(false)
		else
			gt.seekNodeByName(detailPanel, "Sprite_1"):setVisible(true)
			gt.seekNodeByName(detailPanel, "Sprite_2"):setVisible(false)
			gt.seekNodeByName(detailPanel, "Sprite_4"):setVisible(false)
		end

		-- 序号
		local numLabel = gt.seekNodeByName(detailCellNode, "Label_num")
		numLabel:setString(tostring(i))
		-- 对战时间
		local timeLabel = gt.seekNodeByName(detailCellNode, "Label_time")
		local timeTbl = os.date("*t", v.kTime)
		timeLabel:setString(string.format("%04d-%02d-%02d %02d:%02d:%02d", timeTbl.year, timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min, timeTbl.sec))
		--重置名字和分数
		for i=1, num do
			local scoreLabel = gt.seekNodeByName(detailCellNode, "Label_score_" .. i)
			--local nicknameLabel = gt.seekNodeByName(detailPanel, "Label_nickname_" .. i)
			scoreLabel:setString("")
			--nicknameLabel:setString("")
		end
		-- 对战分数
		for i=1, num do
			local scoreLabel = gt.seekNodeByName(detailCellNode, "Label_score_" .. i)
			--local nicknameLabel = gt.seekNodeByName(detailPanel, "Label_nickname_" .. i)
			if cellData.kFlag == 100006 and i == 4 then  --拐三角
				scoreLabel:setString("")
				--nicknameLabel:setString("")
				break
			end
			scoreLabel:setString(tostring(v.kScore[i]))
			--local nikeName = self:getCutName(cellData.m_nike[i],8,6)
			--nicknameLabel:setString(nikeName)
		end



		-- 查牌按钮
		local replayBtn = gt.seekNodeByName(detailCellNode, "Btn_replay")
		replayBtn:setScale(0.7)
		replayBtn:setTag(v.kVideoId)
		replayBtn.videoId = v.kVideoId
		gt.isShowReplay = false   --正在播放回放时按钮不能再点击
		gt.addBtnPressedListener(replayBtn, function(sender)
			if gt.isShowReplay then return end
			local btnTag = sender.videoId

			-- 请求打牌回放数据
			local msgToSend = {}
			msgToSend.kMId = gt.MSG_C_2_S_POKER_REQUEST_VIDEO_ID
			msgToSend.kVideoId = btnTag
			gt.socketClient:sendMessage(msgToSend)
			gt.isShowReplay = true
		end)


		-- 分享按钮
		-- local shareBtn = gt.seekNodeByName(detailCellNode, "Btn_share")
		-- shareBtn.data = v
		-- gt.addBtnPressedListener(shareBtn, function(sender)
		-- 	local data = sender.data
		-- 	local msgToSend = {}
		-- 	msgToSend.m_msgId = gt.CG_SHARE_BTN
		-- 	msgToSend.m_videoId = data.m_videoId
		-- 	gt.socketClient:sendMessage(msgToSend)
		-- end)

		local cellSize = detailCellNode:getContentSize()
		local detailItem = ccui.Widget:create()
		detailItem:setContentSize(cellSize)
		detailItem:addChild(detailCellNode)
		contentListVw:pushBackCustomItem(detailItem)
	end
end

--获得字符串的长度
function HistoryRecord:getStringLen(str)
	local len = 0
	local byteCount = 0
	local gap = 0
	for i = 1, string.len(str) do
		if gap > 0 then
			gap = gap - 1
		else
			local b = string.byte(string.sub(str, i, i))
			if b > 0 and b <= 127 then
		        byteCount = 1
		        len = len - 0.5
		    elseif b >= 192 and b < 223 then
		        byteCount = 2
		        len = len - 0.5
		    elseif b >= 224 and b < 239 then
		        byteCount = 3
		    elseif b >= 240 and b <= 247 then
		        byteCount = 4
		    end
		    gap = byteCount - 1
		    len = len + 1
		end
	end
	return len
end
--截取字符串
function HistoryRecord:getCutName(sName,nMaxCount,nShowCount)
    if sName == nil or nMaxCount == nil then
        return
    end
    local sStr = sName
    local tCode = {}
    local tName = {}
    local nLenInByte = #sStr
    local nWidth = 0
    if nShowCount == nil then
       nShowCount = nMaxCount - 3
    end
    for i=1,nLenInByte do
        local curByte = string.byte(sStr, i)
        local byteCount = 0;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
        local char = nil
        if byteCount > 0 then
            char = string.sub(sStr, i, i+byteCount-1)
            i = i + byteCount -1
        end
        if byteCount == 1 then
            nWidth = nWidth + 1
            table.insert(tName,char)
            table.insert(tCode,1)
            
        elseif byteCount > 1 then
            nWidth = nWidth + 2
            table.insert(tName,char)
            table.insert(tCode,2)
        end
    end
    
    if nWidth > nMaxCount then
        local _sN = ""
        local _len = 0
        for i=1,#tName do
            _sN = _sN .. tName[i]
            _len = _len + tCode[i]
            if _len >= nShowCount then
                break
            end
        end
        sName = _sN .. ".."
    end
    return sName
end

--接受到服务器返回的回放码
function HistoryRecord:onRcvShare(msgTbl)
	gt.dump(msgTbl)
	if msgTbl.kErrorId == 0 then
		self.m_shareId = msgTbl.kShareId
		if self.m_shareId and self.kShareId ~= "" then

			local nickName = ""
			local tab = {}
			for uchar in string.gfind(gt.wxNickName, "[%z\1-\127\194-\244][\128-\191]*") do 
				tab[#tab+1] = uchar
				if #tab <= 6 then
					nickName = nickName .. uchar
				end
			end
			if #tab > 6 then
				nickName = nickName .. "..."
			end
			self.description = "玩家["..nickName.."]分享了一个回访码:"..self.m_shareId..",在大厅点击进入战绩页面,然后点击查看回访按钮,输入回访码点击确定后即可查看。"
			self.title = "好运来山西麻将"
			
			Utils.shareURLToHY( nil, self.title, self.description )
		else
			Toast.showToast(self, "回访码不存在", 2)
		end
	else
		Toast.showToast(self, "录像不存在", 2)
	end
end

--  请求他人回放服务器返回
function HistoryRecord:onRcvShareReplay(msgTbl)
	if msgTbl.kErrorId == 1 then
		gt.dump(msgTbl)
		local msgToSend = {}
		msgToSend.kMId = gt.GC_GET_VIDEO
		msgToSend.kVideoId = msgTbl.kData[1].kVideoId
		gt.socketClient:sendMessage(msgToSend)
	else
		Toast.showToast(self, "你查询的录像不存在", 2)
	end
end

function HistoryRecord:viewOtherHandler(msgTbl)
	--服务器定义消息msgTbl(m_errorId(0,1),m_match(m_nike(),m_score()[待定],m_time(),m_videoId()))
	gt.dump(msgTbl)
	--隐藏开始列表界面的标题
	self.titleNode:hide()

	-- 隐藏历史记录
	local historyListVw = gt.seekNodeByName(self.rootNode, "ListVw_content")
	historyListVw:hide()
	-- 屏蔽查看他人战绩节点
	gt.seekNodeByName(self.rootNode, "Node_view"):hide()
	-- 切换标题
	local titleRoomNode = gt.seekNodeByName(self.rootNode, "Node_titleRoom")
	titleRoomNode:setVisible(true)

	local historyDetailNode = gt.seekNodeByName(self.rootNode, "Node_historyDetail")
	local detailPanel = cc.CSLoader:createNode("HistoryDetail.csb")
	detailPanel:setAnchorPoint(0.5,0.5)
	historyDetailNode:addChild(detailPanel)
	detailPanel:setPositionY(18)

	local contentListVw = gt.seekNodeByName(detailPanel, "ListVw_content")

	for i,v in ipairs(msgTbl.kData) do
		local detailCellNode = cc.CSLoader:createNode("HistoryDetailCell.csb")
		-- 序号
		local numLabel = gt.seekNodeByName(detailCellNode, "Label_num")
		--numLabel:setTextColor(cc.YELLOW)
		numLabel:setString(tostring(i))
		-- 对战时间
		local timeLabel = gt.seekNodeByName(detailCellNode, "Label_time")
		--timeLabel:setTextColor(cc.YELLOW)
		local timeTbl = os.date("*t", v.kTime)
		timeLabel:setString(string.format("%02d-%02d %02d:%02d", timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min))
		-- 初始化
		for i=1, 4 do
			local scoreLabel = gt.seekNodeByName(detailCellNode, "Label_score_" .. i)
			local nicknameLabel = gt.seekNodeByName(detailPanel, "Label_nickname_" .. i)
			scoreLabel:setString("")
			nicknameLabel:setString("")
		end
		-- 修正显示问题
		for i=1, #v.kScore do
			local scoreLabel = gt.seekNodeByName(detailCellNode, "Label_score_" .. i)
			local nicknameLabel = gt.seekNodeByName(detailPanel, "Label_nickname_" .. i)
			scoreLabel:setString(tostring(v.kScore[i]))
			gt.dump(v.kNike)
			nicknameLabel:setString(self:getCutName(tostring(v.kNike[i]),8,6))
		end

		-- 查牌按钮
		local replayBtn = gt.seekNodeByName(detailCellNode, "Btn_replay")
		replayBtn.videoId = v.kVideoId
		gt.addBtnPressedListener(replayBtn, function(sender)
			local btnTag = sender.videoId
			local msgToSend = {}
			msgToSend.kMId = gt.GC_GET_VIDEO
			msgToSend.kVideoId = btnTag
			gt.socketClient:sendMessage(msgToSend)
		end)

		local shareBtn = gt.seekNodeByName(detailCellNode, "Btn_share")
		shareBtn:hide()

		local cellSize = detailCellNode:getContentSize()
		local detailItem = ccui.Widget:create()
		detailItem:setContentSize(cellSize)
		detailItem:addChild(detailCellNode)
		contentListVw:pushBackCustomItem(detailItem)
	end
end




return HistoryRecord

