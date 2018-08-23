
local gt = cc.exports.gt

local JoinClub = class("JoinClub", function()
	return gt.createMaskLayer()
end)

function JoinClub:ctor(clubType, data)
	local csbNode = cc.CSLoader:createNode("JoinClub.csb")
	csbNode:setAnchorPoint(cc.p(0.5,0.5))
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	
	self.csbNode = csbNode

	self.data = data

	if self.data then
		for i = 1, #self.data do
			local clubOnlineUserCount = gt.clubOnlineUserCount or {}
			for j = 1, #clubOnlineUserCount do
				if clubOnlineUserCount[j][1] and clubOnlineUserCount[j][1] == self.data[i].club_no then
					self.data[i].online_user_count = (clubOnlineUserCount[j][2] or 0)
				end
			end
		end
	
		table.sort(self.data, function(a, b)
			return tonumber(a.online_user_count or 0) > tonumber(b.online_user_count or 0)
		end)
	end

	-- if bgShow then
	-- 	local bokehImg = gt.seekNodeByName(self.csbNode, "Img_bokeh")
	-- 	bokehImg:setVisible(false)
	-- end

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	--申请文娱馆
	self.applyClubNode = gt.seekNodeByName(self.csbNode, "Node_applyClub")
	--查询文娱馆
	self.statusNode1 = gt.seekNodeByName(self.csbNode, "Node_status1")
	--找到文娱馆
	self.statusNode2 = gt.seekNodeByName(self.csbNode, "Node_status2")
	--未找到文娱馆
	self.statusNode3 = gt.seekNodeByName(self.csbNode, "Node_status3")

	--加入文娱馆
	self.joinClubNode = gt.seekNodeByName(self.csbNode, "Node_joinClub")

	self:setClubInfo(clubType or 1, 1)

	self:setInputNumber()

	-- 申请进度查询
	local progressQueryBtn = gt.seekNodeByName(self.csbNode, "Btn_progressQuery")
	gt.addBtnPressedListener(progressQueryBtn, function()
  		local layer = require("client/game/club/ClubProgressQuery"):create()
  		self:addChild(layer)
	end)

	-- 关闭按键
	local closeBtn = gt.seekNodeByName(self.csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:removeFromParent()
	end)
end

function JoinClub:onNodeEvent(eventName)
	if "enter" == eventName then
	elseif "exit" == eventName then
	end
end

--界面节点控制
function JoinClub:setClubInfo(_type, status)
	gt.log("--------------------type", type)
	gt.log("--------------------status", status)
	if _type == 1 then
		self.applyClubNode:setVisible(true)
		self.joinClubNode:setVisible(false)
		if status == 1 then
			self.statusNode1:setVisible(true)
			self.statusNode2:setVisible(false)
			self.statusNode3:setVisible(false)
		elseif status == 2 then
			self.statusNode1:setVisible(false)
			self.statusNode2:setVisible(true)
			self.statusNode3:setVisible(false)
		elseif status == 3 then
			self.statusNode1:setVisible(false)
			self.statusNode2:setVisible(false)
			self.statusNode3:setVisible(true)
		end
	elseif _type == 2 then
		self:initPageListView()
		self.applyClubNode:setVisible(false)
		self.joinClubNode:setVisible(true)
		local Btn_joinMoreClub = gt.seekNodeByName(self.csbNode, "Btn_joinMoreClub")
		gt.addBtnPressedListener(Btn_joinMoreClub, function()
			self:setClubInfo(1, 1)
		end)
	end
end

-- 查询结果设置文娱馆信息
function JoinClub:setQueryClubInfo(data)
	self:setClubInfo(1, 2)
	-- 文娱馆名称
	local clubNameLabel = gt.seekNodeByName(self.csbNode, "Label_clubName")
	clubNameLabel:setString(data.club_name)
	
	-- data.avatar = "http://wx.qlogo.cn/mmopen/vi_32/ywQXiakdKQ62MQ60GeZTiadqb0DCqNJico53g3q8qZTYbHvQbDrTicUfLgsrxwQkeQKAP3iaVHSveZz7SAccfM9KK4Q/132"
	-- 会长头像
	local headLayout = gt.seekNodeByName(self.statusNode2, "Head_layout")
	local headSpr = gt.seekNodeByName(headLayout, "Spr_head")
	local headFile = "res/images/sx_club/sx_img_club_headBg.png"
	headSpr:setTexture(headFile)
	local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
	playerHeadMgr:attach(headSpr, headLayout, data.user_id, data.avatar, nil, nil, 100, true)
	self:addChild(playerHeadMgr)
	self.id = data.id
	
	-- 会长名字
	local nickNameLabel = gt.seekNodeByName(self.csbNode, "Label_nickName")
	nickNameLabel:setString("会长："..(data.nickname or ""))

	-- 会友数量
	local plyerCountLabel = gt.seekNodeByName(self.csbNode, "Label_plyerCount")
	plyerCountLabel:setString(data.user_count.." 名会友")

	-- 房费支付类型
	local payTypeLabel = gt.seekNodeByName(self.csbNode, "Label_payType")
	payTypeLabel:setString(data.feeType)

	-- 申请加入按钮
	self.applyJoinBtn = gt.seekNodeByName(self.csbNode, "Btn_applyJoin")
	gt.addBtnPressedListener(self.applyJoinBtn, function()
		self.applyJoinBtn:setEnabled(false)
		self:joinClub()
	end)
end

--输入数字
function JoinClub:setInputNumber()
    -- 最大输入6个数字
	self.inputMaxCount = 5
	-- 数字文本
	self.inputNumLabels = {}
	self.curInputIdx = 1
	for i = 1, self.inputMaxCount do
		local numLabel = gt.seekNodeByName(self.csbNode, "Img_num_" .. i)
		numLabel:setVisible(false)
		self.inputNumLabels[i] = numLabel
	end

	-- 数字按键
	for i = 0, 9 do
		local numBtn = gt.seekNodeByName(self.csbNode, "Btn_num_" .. i)  --遍历数字按键
		numBtn:setTag(i)  --设置标记为0-9
		-- numBtn:addClickEventListener(handler(self, self.numBtnPressed))  --添加点击事件
		gt.addBtnPressedListener( numBtn, handler(self,self.numBtnPressed))
	end

	-- 重置按键
	local resetBtn = gt.seekNodeByName(self.csbNode, "Btn_reset")
	gt.addBtnPressedListener(resetBtn, function()
		for i = self.inputMaxCount, 1 , -1 do
			local numLabel = gt.seekNodeByName(self.csbNode, "Img_num_" .. i)
			numLabel:setVisible(false)
			--numLabel:setString("")
		end
		self.curInputIdx = 1  --光标设置在第一位
	end)

   -- 删除按键
	local delBtn = gt.seekNodeByName(self.csbNode, "Btn_del")
	gt.addBtnPressedListener(delBtn, function()
		for i = self.curInputIdx - 1, 1 , -1 do
			if self.curInputIdx - 1  >= 1 then
				local numLabel = gt.seekNodeByName(self.csbNode, "Img_num_" .. i)
				numLabel:setVisible(false)
				--numLabel:setString("")
				self.curInputIdx = self.curInputIdx - 1
			end
			break
		end
	end)
end

function JoinClub:numBtnPressed(senderBtn)
	local btnTag = senderBtn:getTag()
	print("current tag:"..btnTag)
	local numLabel = self.inputNumLabels[self.curInputIdx]
	if numLabel ~= nil then
		numLabel:loadTexture("join_room/"..btnTag..".png")
		numLabel:setTag(btnTag)
		numLabel:setVisible(true)
		if self.curInputIdx >= #self.inputNumLabels then
			local clubID = 0
			local tmpAry = {10000, 1000, 100, 10, 1}
			for i = 1, self.inputMaxCount do
				local inputNum = tonumber(self.inputNumLabels[i]:getTag())
				clubID = clubID + inputNum * tmpAry[i]
			end
			-- 发送查询文娱馆消息
			-- local msgToSend = {}
			-- msgToSend.kMId = gt.CG_JOIN_ROOM
			-- msgToSend.kDeskId = clubID
			-- gt.socketClient:sendMessage(msgToSend)

	 		-- self:schedule()

			-- gt.showLoadingTips(gt.getLocationString("LTKey_0052"))
			self.clubID = clubID
			self:queryClub(clubID)
		end
		self.curInputIdx = self.curInputIdx + 1
	end
end

function JoinClub:queryClubResult()
	self:setClubInfo(1, 2)
end

function JoinClub:initPageListView()
	local pageButtonPosition = {
		{x = 100, y = 0},
		{x = 500, y = 0},
	}
	self.maxNum 		= math.ceil(#self.data/2) --最大页数
	self.currIdx 		= 0 --当前页数
	self.paddingMaxTime = 5 -- 切换的间隔时间
	self.paddingTime 	= 0 --计时时间
	self.pageListView 	= gt.seekNodeByName(self.csbNode, "PageView_List")
	self.pageNode 		= gt.seekNodeByName(self.csbNode, "Node_page")
	self.pageListView:setSwallowTouches(true)
	local listSize = self.pageListView:getContentSize()
	local clubInfoCellCount = 0
	-- self:_changePlayType(self.mahjongType)
	for i = 1, self.maxNum do
		self.pageWidget = ccui.Layout:create()
		self.pageWidget:setTouchEnabled(true)
		self.pageWidget:setSwallowTouches(false)
		self.pageWidget:setContentSize(cc.size(255,500))
		self.pageWidget:addTouchEventListener(handler(self, self.onTouchPageHandler))
		-- local pageImg = ccui.ImageView:create("background/sx_ag_item_"..(i+1)..".png")
		-- pageImg:setTouchEnabled(true)
		-- pageImg:setPosition(cc.p(listSize.width*0.5, listSize.height*0.5))

    	-- local Button = cc.Sprite:create("res/images/otherImages/haoyouqun.png")

    	for j = 1, 2 do
    		clubInfoCellCount = clubInfoCellCount + 1
    		if self.data[clubInfoCellCount] then
		    	local clubInfoCell, bgBtn = self:createClubInfoCell(self.data[clubInfoCellCount])
		    	clubInfoCell:setPosition(cc.p(pageButtonPosition[j].x, pageButtonPosition[j].y))
				bgBtn:setTouchEnabled(true)

				bgBtn:setTag(clubInfoCellCount)
				self.pageWidget:addChild(clubInfoCell)
				bgBtn:addTouchEventListener(handler(self, self.onTouchPageHandler))
			end
    	end
		self.pageListView:addPage(self.pageWidget)
	end
	self.pageListView:scrollToPage(self.currIdx)

	self:updatePageNode(self.currIdx)

	--向左箭头
	local arrow1Btn = gt.seekNodeByName(self.csbNode, "Btn_arrow1")
	gt.addBtnPressedListener(arrow1Btn, function()
			local isJump = false  --是否是临界点，不能通过scroll滚动太多页数
				self.currIdx = self.currIdx - 1
				if self.currIdx < 0 then
					self.currIdx = 0
					isJump = true
				end
			gt.log("self.currIdx: ======== ".. self.currIdx)
			if isJump then
				self.pageListView:setCurrentPageIndex(self.currIdx)
			else
				self.pageListView:scrollToPage(self.currIdx)
			end
			self:updatePageNode(self.currIdx)
	end)
	
	--向右箭头
	local arrow2Btn = gt.seekNodeByName(self.csbNode, "Btn_arrow2")
	gt.addBtnPressedListener(arrow2Btn, function()
		local isJump = false  --是否是临界点，不能通过scroll滚动太多页数
			self.currIdx = self.currIdx + 1
			if self.currIdx >= self.maxNum then
				self.currIdx = self.maxNum - 1
				isJump = true
			end
		if isJump then
			self.pageListView:setCurrentPageIndex(self.currIdx)
		else
			self.pageListView:scrollToPage(self.currIdx)
		end
		self:updatePageNode(self.currIdx)
	end)

end


function JoinClub:createClubInfoCell(data)
	local csbNode = cc.CSLoader:createNode("ClubInfoCell.csb")
	-- csbNode:setAnchorPoint(cc.p(0.5,0.5))
	-- csbNode:setPosition(gt.winCenter)

	-- 文娱馆名称
	local clubNameLabel = gt.seekNodeByName(csbNode, "Label_clubName")
	clubNameLabel:setString(data.club_name)
	
	-- data.avatar = "http://wx.qlogo.cn/mmopen/vi_32/ywQXiakdKQ62MQ60GeZTiadqb0DCqNJico53g3q8qZTYbHvQbDrTicUfLgsrxwQkeQKAP3iaVHSveZz7SAccfM9KK4Q/132"
	--会长头像
	local headSpr = gt.seekNodeByName(csbNode, "Spr_head")
	local headLayout = gt.seekNodeByName(csbNode, "Head_layout")
	local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
	playerHeadMgr:attach(headSpr, headLayout, data.user_id, data.avatar, nil, nil, 100, true)
	self:addChild(playerHeadMgr)
	-- self.id = data.id
	
	-- 会长名字
	local nickNameLabel = gt.seekNodeByName(csbNode, "Label_nickName")
	nickNameLabel:setString("会长："..(data.nickname or ""))

	--在线人数
	local onlineCountLabel = gt.seekNodeByName(csbNode, "Label_onlineCount")
	onlineCountLabel:setString((data.online_user_count or 0).." 人在线")

	-- local clubOnlineUserCount = gt.clubOnlineUserCount or {}
	-- for i = 1, #clubOnlineUserCount do
	-- 	if clubOnlineUserCount[i][1] and clubOnlineUserCount[i][1] == data.club_no then
	-- 		onlineCountLabel:setString((clubOnlineUserCount[i][2] or 0).." 人在线")
	-- 	end
	-- end
	
	-- 会友数量
	local plyerCountLabel = gt.seekNodeByName(csbNode, "Label_plyerCount")
	plyerCountLabel:setString(data.user_count.." 名会友")

	-- 房费支付类型
	local payTypeLabel = gt.seekNodeByName(csbNode, "Label_payType")
	payTypeLabel:setString(data.feeType)

	--进入按钮
	local bgBtn = gt.seekNodeByName(csbNode, "Btn_bg")

	return csbNode, bgBtn
end

function JoinClub:updatePageNode(currentPageIdx)
	if self.pageDots == nil then
		self.pageDots = {}
		local totalWidth = (self.maxNum - 1) * 50
		local firstPosX = -totalWidth*0.5
		for i=1, self.maxNum do
			local pDot = cc.Sprite:create("res/images/sx_club/sx_img_club_dotBg.png")
			table.insert(self.pageDots, pDot)
			-- pDot:setScale(1.2)
			pDot:setAnchorPoint(cc.p(0.5,0.5))
			pDot:setPosition(cc.p(firstPosX,14))
			firstPosX = firstPosX + 50
			self.pageNode:addChild(pDot)
			local dotChoosedImg = cc.Sprite:create("res/images/sx_club/sx_img_club_dotSelect.png")
			pDot:addChild(dotChoosedImg)
			dotChoosedImg:setPosition(cc.p(13,12))
			dotChoosedImg:setName("dotChoosedImg")
		end
	end
	for i, dot in ipairs(self.pageDots) do
		local choosedImg = dot:getChildByName("dotChoosedImg")
		if choosedImg then
			choosedImg:hide()
			if i == (currentPageIdx + 1) then
				choosedImg:show()
			end
		end
	end
end

function JoinClub:onTouchPageHandler(sender, eventType)
	gt.log("----------------------------------onTouchPageHandler")
	if eventType == ccui.TouchEventType.began then
		self.touchBeganPos = sender:getTouchBeganPosition()
	elseif eventType == ccui.TouchEventType.moved then
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self.touchEndedPos = sender:getTouchEndPosition()
		if math.abs(self.touchEndedPos.x - self.touchBeganPos.x) >= 10 then
			local isJump = false  --是否是临界点，不能通过scroll滚动太多页数
			if self.touchBeganPos.x < self.touchEndedPos.x then
				self.currIdx = self.currIdx - 1
				if self.currIdx < 0 then
					self.currIdx = 0
					isJump = true
				end
			else
				self.currIdx = self.currIdx + 1
				if self.currIdx >= self.maxNum then
					self.currIdx = self.maxNum - 1
					isJump = true
				end
			end
			gt.log("self.currIdx: ======== ".. self.currIdx)
			if isJump then
				self.pageListView:setCurrentPageIndex(self.currIdx)
			else
				self.pageListView:scrollToPage(self.currIdx)
			end
			self:updatePageNode(self.currIdx)
		else
			if sender:getTag() > 0 then
				gt.soundEngine:playEffect("common/audio_button_click", false)
				gt.log("切换文娱馆选择："..sender:getTag())

				gt.showLoadingTips(gt.getLocationString("LTKey_0053"))
				local runningScene = display.getRunningScene()
				if runningScene:getChildByName("ClubLayer") == nil then
					local ClubLayer = require("client/game/club/ClubLayer"):create(self.data[sender:getTag()].club_no, true)
					ClubLayer:setName("ClubLayer")
					runningScene:addChild(ClubLayer, 16)
				end

				self.kClubId = self.data[sender:getTag()].club_no
			end
    	end
	end
end

--查询文娱馆
function JoinClub:queryClub(clubID)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local queryClubURL = gt.getUrlEncryCode(string.format(gt.queryClub, clubID), gt.playerData.uid)
	print("------------queryClubURL", queryClubURL)
	-- gt.dumploglogin("------------queryClubURL"..queryClubURL)
	xhr:open("GET", queryClubURL)
	local function onResp()
		if self then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				-- gt.dumploglogin("------------queryClubURLSUCCESS")
				gt.dump(xhr.response)
		 		local cjson = require "cjson"
				local ret = cjson.decode(xhr.response)
				if ret.errno == 0 then
					if ret.data.club.is_exist then
						if self.applyJoinBtn then
						self.applyJoinBtn:setEnabled(true)
					end
						self:setQueryClubInfo(ret.data.club)
					else
						self:setClubInfo(1, 3)
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

--加入文娱馆
function JoinClub:joinClub()
	if self.id == nil then
		return
	end
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local joinClubURL = gt.getUrlEncryCode(string.format(gt.joinClub, self.id), gt.playerData.uid)
	print("------------joinClubURL", joinClubURL)
	-- gt.dumploglogin("------------joinClubURL"..joinClubURL)
	xhr:open("GET", joinClubURL)
	local function onResp()
		if self then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				gt.dump(xhr.response)
		 		local cjson = require "cjson"
				local ret = cjson.decode(xhr.response)
				-- gt.dumploglogin(ret)
				if ret.errno == 0 then			
  					require("client/game/club/ClubCommitApplyTips"):create(function ( )
  						if not tolua.isnull(self) then 
  							self:removeFromParent()
  						end
					end)
				else
					require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), ret.errmsg, nil, nil, true)
					self.applyJoinBtn:setEnabled(true)
				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

return JoinClub

