
local gt = cc.exports.gt
local Utils = cc.exports.Utils
local ClubProgressQuery = class("ClubProgressQuery", function()
	return gt.createMaskLayer()
end)

------------
--param msgTbl ：msgTBl战绩服务器数据
function ClubProgressQuery:ctor()
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("ClubProgressQuery.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

	self:getClubProgressQueryList()

	local function setShakeThePresidentTime( shakeThePresidentBtn, shakeThePresidentFlag)
		if not shakeThePresidentFlag then
			cc.UserDefault:getInstance():setIntegerForKey("shakeThePresidentTime", os.time())
		end

		self.shakeThePresidentTime = 60 - (os.time() - cc.UserDefault:getInstance():getIntegerForKey("shakeThePresidentTime", os.time()))
		if self.shakeThePresidentTime < 0 then
			self.shakeThePresidentTime = 0 
		end
		gt.log("----------------self.shakeThePresidentTime", self.shakeThePresidentTime)
		if shakeThePresidentFlag then
			if shakeThePresidentFlag and  self.shakeThePresidentTime > 0 and self.shakeThePresidentTime < 60 then
				shakeThePresidentBtn:setEnabled(false)
		    	self.shakeThePresidentTimeSchedulerEntry = gt.scheduler:scheduleScriptFunc(function (  )
					self.shakeThePresidentTime = self.shakeThePresidentTime - 1

					if self.shakeThePresidentTime <= 0 then
						shakeThePresidentBtn:setEnabled(true)
						if self.shakeThePresidentTimeSchedulerEntry then
							gt.scheduler:unscheduleScriptEntry(self.shakeThePresidentTimeSchedulerEntry)
							self.shakeThePresidentTimeSchedulerEntry = nil
							cc.UserDefault:getInstance():setIntegerForKey("shakeThePresidentTime", 0)
						end
					end
		    	end, 1, false)
		    else
				shakeThePresidentBtn:setEnabled(true)
		    end
		else
			if self.shakeThePresidentTime > 0 then
		    	self.shakeThePresidentTimeSchedulerEntry = gt.scheduler:scheduleScriptFunc(function (  )
					self.shakeThePresidentTime = self.shakeThePresidentTime - 1

					if self.shakeThePresidentTime <= 0 then
						shakeThePresidentBtn:setEnabled(true)
						if self.shakeThePresidentTimeSchedulerEntry then
							gt.scheduler:unscheduleScriptEntry(self.shakeThePresidentTimeSchedulerEntry)
							self.shakeThePresidentTimeSchedulerEntry = nil
							cc.UserDefault:getInstance():setIntegerForKey("shakeThePresidentTime", 0)
						end
					end
		    	end, 1, false)
		    end
		end
		if shakeThePresidentFlag then
			if self.shakeThePresidentTime > 0 and self.shakeThePresidentTime < 60 then
				shakeThePresidentBtn:setEnabled(false)
			else
				shakeThePresidentBtn:setEnabled(true)
			end
		else
			shakeThePresidentBtn:setEnabled(self.shakeThePresidentTime <= 0)
		end
	end

	-- 抖一下馆长
	self.shakeThePresidentBtn = gt.seekNodeByName(csbNode, "Btn_shakeThePresident")
	self.shakeThePresidentBtn:setVisible(false)
	gt.addBtnPressedListener(self.shakeThePresidentBtn, function()
		self:setClubShakeThePresident()

		local runningScene = cc.Director:getInstance():getRunningScene()
		Toast.showToast(runningScene, "发送成功！", 2)

		self.shakeThePresidentBtn:setEnabled(false)
		setShakeThePresidentTime(self.shakeThePresidentBtn, false)
	end)

	setShakeThePresidentTime(self.shakeThePresidentBtn, true)

	-- 返回按钮
	local backBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(backBtn, function()
		-- 移除界面,返回主界面
		self:removeFromParent()
	end)
end

function ClubProgressQuery:onNodeEvent(eventName)
	if "enter" == eventName then
	elseif "exit" == eventName then
		if self.shakeThePresidentTimeSchedulerEntry then
			gt.scheduler:unscheduleScriptEntry(self.shakeThePresidentTimeSchedulerEntry)
			self.shakeThePresidentTimeSchedulerEntry = nil
		end
	end
end

function ClubProgressQuery:sendHistoryOne(sender, eventType)
	local msgToSend = {}
	msgToSend.m_msgId = gt.CG_HISTORY_ONE
	local data = self.ClubProgressQueryMsgTbl.m_data[sender:getTag()]
	msgToSend.m_time = data.m_time
	msgToSend.m_userId = gt.playerData.uid  --玩家自己id
	gt.dump(self.ClubProgressQueryMsgTbl[sender:getTag()])
	msgToSend.m_pos = self.ClubProgressQueryMsgTbl[sender:getTag()].m_userid[1]  --房主id
	msgToSend.m_deskId = data.m_deskId
	gt.socketClient:sendMessage(msgToSend)
	self.m_sender = sender
	gt.showLoadingTips("读取数据中")
end

function ClubProgressQuery:setClubProgressQuery(msgTbl)
	gt.dump(msgTbl)
	if self.ClubProgressQueryList == nil then
		self.ClubProgressQueryList = gt.seekNodeByName(self.rootNode, "List_content")
	end
	-- local emptyLabel = gt.seekNodeByName(self.rootNode, "Text_tip_noData")
	if #msgTbl == 0 then
		--没有战绩
		-- emptyLabel:show()
		self.ClubProgressQueryList:removeAllItems()
	else
		-- emptyLabel:hide()
		-- 显示战绩列表
		for i, cellData in ipairs(msgTbl) do
			local historyItem = self:createHistoryItem(i, cellData)
			self.ClubProgressQueryList:pushBackCustomItem(historyItem)
		end
	end
end

-- start --
--------------------------------
-- @class function
-- @description 创建战绩条目
-- @param cellData 条目数据
-- end --
function ClubProgressQuery:createHistoryItem(tag, cellData)
	local cellNode = cc.CSLoader:createNode("ClubProgressQueryCell.csb")

	-- 会长
	local Text1 = gt.seekNodeByName(cellNode, "Text1")
	Text1:setString(cellData.nickname)

	-- 棋牌室ID
	local Text2 = gt.seekNodeByName(cellNode, "Text2")
	Text2:setString(cellData.club_no)

	-- 棋牌室名称
	local Text3 = gt.seekNodeByName(cellNode, "Text3")
	Text3:setString(cellData.club_name)

	-- 申请进度
	local Text4 = gt.seekNodeByName(cellNode, "Text4")
	Text4:setString("申请中")

	-- 申请时间
	local Text5 = gt.seekNodeByName(cellNode, "Text5")
	Text5:setString(cellData.ctime)

	local cellSize = cellNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(cellNode)

	return cellItem
end

--获取申请棋牌室进度列表
function ClubProgressQuery:getClubProgressQueryList()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local getClubsURL = gt.getUrlEncryCode(string.format(gt.getClubs, 0), gt.playerData.uid)
	print("------------getClubsURL", getClubsURL)
	xhr:open("GET", getClubsURL)
	local function onResp()
		gt.removeLoadingTips()
		if self then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				-- dump(xhr.response)
		 		local cjson = require "cjson"
				local ret = cjson.decode(xhr.response)
				if ret.errno == 0 then
					if ret.data.clubs and #ret.data.clubs > 0 then
						self:setClubProgressQuery(ret.data.clubs)
						self.shakeThePresidentBtn:setVisible(true)
					end
				else
					require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), ret.errmsg, nil, nil, true)
				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end
--获取申请棋牌室进度列表
function ClubProgressQuery:setClubShakeThePresident()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local getClubShakeThePresidentURL = gt.getUrlEncryCode(gt.ClubShakeThePresident, gt.playerData.uid)
	print("------------getClubShakeThePresidentURL", getClubShakeThePresidentURL)
	xhr:open("GET", getClubShakeThePresidentURL)
	xhr:send()
end
return ClubProgressQuery

