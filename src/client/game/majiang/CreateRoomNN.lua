local gt = cc.exports.gt

local CreateRoomNN = class("CreateRoomNN", function()
	return gt.createMaskLayer()
end)

function CreateRoomNN:ctor(callback)

	--初始化默认设置
	self:_initParameter()

	--初始化UI
	self:_initUI()

	if callback then
		self.callback = callback
	end

	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local createBtn = gt.seekNodeByName(self, "Btn_create")
	
	gt.addBtnPressedListener(createBtn, function()
		local robotNumber = 0

		gt.log("set_______________4",tostring(self._type))

		-- 默认机器人数量
		local data_count = cc.UserDefault:getInstance():getStringForKey("SetTest_Count")
		robotNumber = tonumber(data_count)

		local msgToSend = {}
		msgToSend.kMId = gt.CG_CREATE_ROOM

		msgToSend.kSecret = "123456"
		msgToSend.kGold = 1

		msgToSend.kRobotNum = robotNumber

		msgToSend.kFlag = self.nn_jushu + 1--== 1 and 8 or 16 -- (8 or 16) -- 局数 1 代表 8  2 代表 16
		msgToSend.kState = 103        --   炸金花  102，斗地主  101，牛牛    103，
		msgToSend.kFeeType = self.nn_avarage     --（费用类型 ，0:房主付费 1:玩家分摊）
		msgToSend.kCheatAgainst = 0 -- // 是否防作弊，0:不防作弊 1：防作弊 -- 暂时没用
		msgToSend.kDeskType = 0
		-- msgToSend.kGpsLng = tostring(kGpsLng)
		-- msgToSend.kGpsLat = tostring(kGpsLat)

		msgToSend.kPlayType = {}
		msgToSend.kPlayType[1] = self.nn_guize
		msgToSend.kPlayType[2] = self.nn_guize == 1 and self.nn_moshi1 or (self.nn_moshi2 == 2 and self.nn_moshi2 or self.nn_moshi2 + 3)
		msgToSend.kPlayType[3] = self.nn_wanfa
		msgToSend.kPlayType[4] = self.nn_tuoguan
		msgToSend.kPlayType[5] = 1
		msgToSend.kPlayType[6] = self.nn_renshu == 0 and 6 or 10
		msgToSend.kPlayType[7] = self.nn_guize == 1 and self.nn_qiangzhuang1 or self.nn_qiangzhuang2
		msgToSend.kPlayType[8] = self.nn_guize == 1 and self.nn_beilv1 or self.nn_beilv2
		msgToSend.kPlayType[9] = self.nn_fanbeiRule
		msgToSend.kPlayType[10] = self.nn_xianjiatuizhu*5
		
		msgToSend.kGreater2CanStart = 1              
		gt.log("创建房间________")
		gt.dump(msgToSend)
		gt.socketClient:sendMessage(msgToSend)

		gt.showLoadingTips("房间创建中...")

		--保存设置
		cc.UserDefault:getInstance():setIntegerForKey("nn_jushu", self.nn_jushu)
		cc.UserDefault:getInstance():setIntegerForKey("nn_renshu", self.nn_renshu)
		cc.UserDefault:getInstance():setIntegerForKey("nn_guize", self.nn_guize)
		cc.UserDefault:getInstance():setIntegerForKey("nn_moshi1", self.nn_moshi1)
		cc.UserDefault:getInstance():setIntegerForKey("nn_qiangzhuang1", self.nn_qiangzhuang1)
		cc.UserDefault:getInstance():setIntegerForKey("nn_beilv1", self.nn_beilv1)
		cc.UserDefault:getInstance():setIntegerForKey("nn_moshi2", self.nn_moshi2)
		cc.UserDefault:getInstance():setIntegerForKey("nn_qiangzhuang2", self.nn_qiangzhuang2)
		cc.UserDefault:getInstance():setIntegerForKey("nn_beilv2", self.nn_beilv2)
		cc.UserDefault:getInstance():setIntegerForKey("nn_tuoguan", self.nn_tuoguan)
		cc.UserDefault:getInstance():setIntegerForKey("nn_wanfa", self.nn_wanfa)
		cc.UserDefault:getInstance():setIntegerForKey("nn_avarage", self.nn_avarage)
		cc.UserDefault:getInstance():setIntegerForKey("nn_fanbeiRule", self.nn_fanbeiRule)
		cc.UserDefault:getInstance():setIntegerForKey("nn_xianjiatuizhu", self.nn_xianjiatuizhu)

	end)

	-- 接收创建房间消息
	gt.socketClient:registerMsgListener(gt.GC_CREATE_ROOM, self, self.onRcvCreateRoomNN)

	-- 返回按键
	local backBtn = gt.seekNodeByName(self, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
		self:removeFromParent()
		if self.createSchedule then
 			gt.scheduler:unscheduleScriptEntry(self.createSchedule)
 			self.createSchedule = nil
 		end
	end)

end

function CreateRoomNN:onNodeEvent(eventName)
	if "enter" == eventName then
		gt.soundEngine:Poker_playEffect("res/sfx/sound_nn/createroomNN.mp3",false)
	elseif "exit" == eventName then
		gt.dispatchEvent("show_text")
		if self._time then gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
		gt.socketClient:unregisterMsgListener(gt.GC_CREATE_ROOM)
	end
end

--初始化默认设置
function CreateRoomNN:_initParameter(mahjongType)
	self.nn_jushu  =cc.UserDefault:getInstance():getIntegerForKey("nn_jushu", 0)
	self.nn_renshu  =cc.UserDefault:getInstance():getIntegerForKey("nn_renshu", 0)
	self.nn_guize  =cc.UserDefault:getInstance():getIntegerForKey("nn_guize", 1)
	self.nn_moshi1  =cc.UserDefault:getInstance():getIntegerForKey("nn_moshi1", 0)
	self.nn_qiangzhuang1  =cc.UserDefault:getInstance():getIntegerForKey("nn_qiangzhuang1", 0)
	self.nn_beilv1  =cc.UserDefault:getInstance():getIntegerForKey("nn_beilv1", 0)
	self.nn_moshi2  =cc.UserDefault:getInstance():getIntegerForKey("nn_moshi2", 0)
	self.nn_qiangzhuang2  =cc.UserDefault:getInstance():getIntegerForKey("nn_qiangzhuang2", 0)
	self.nn_beilv2  =cc.UserDefault:getInstance():getIntegerForKey("nn_beilv2", 0)
	self.nn_tuoguan  =cc.UserDefault:getInstance():getIntegerForKey("nn_tuoguan", 1)
	self.nn_wanfa  =cc.UserDefault:getInstance():getIntegerForKey("nn_wanfa", 0)
	self.nn_avarage  =cc.UserDefault:getInstance():getIntegerForKey("nn_avarage", 1)
	self.nn_fanbeiRule  =cc.UserDefault:getInstance():getIntegerForKey("nn_fanbeiRule", 0)
	self.nn_xianjiatuizhu  =cc.UserDefault:getInstance():getIntegerForKey("nn_xianjiatuizhu", 0)
end

--初始化UI
function CreateRoomNN:_initUI()
	self.csbNode = cc.CSLoader:createNode("CreateRoomNN.csb")
	self.csbNode:setAnchorPoint(0.5,0.5)
	self.csbNode:setPosition(gt.winCenter)
	self:addChild(self.csbNode)

	--倍率说明
	local playsExplainImg = gt.seekNodeByName(self.csbNode,"Img_playsExplain")
	if self.nn_fanbeiRule == 0 then
		playsExplainImg:loadTexture("res/zy_zjh/create_room_explain3.png")
	else
		playsExplainImg:loadTexture("res/zy_zjh/create_room_explain4.png")
	end

	-- 局数
	for i = 0 , 1 do
		local node =  gt.seekNodeByName(self.csbNode,"m_jushu"):getChildByTag(i)
		if node then node:setSelected(false) 
		gt.log(type(self.nn_jushu))
		local tmp = self.nn_jushu and self.nn_jushu or 0
		if tmp == i then node:setSelected(true) end end
		node:addEventListener(function(senderBtn, eventType)
			for j = 0, 1 do
				if i == j then 
					self.nn_jushu = j 
					gt.seekNodeByName(self.csbNode,"m_jushu"):getChildByTag(j):setSelected(true)
				else
					gt.seekNodeByName(self.csbNode,"m_jushu"):getChildByTag(j):setSelected(false)
				end
			end
			gt.log(self.nn_jushu)
		end)
	end

	-- 人数
	for i = 0 , 1 do
		local node =  gt.seekNodeByName(self.csbNode,"m_renshu"):getChildByTag(i)
		if node then node:setSelected(false) 
		gt.log(type(self.nn_renshu))
		local tmp = self.nn_renshu and self.nn_renshu or 0
		if tmp == i then node:setSelected(true) end end
		node:addEventListener(function(senderBtn, eventType)
			for j = 0, 1 do
				if i == j then 
					self.nn_renshu = j 
					gt.seekNodeByName(self.csbNode,"m_renshu"):getChildByTag(j):setSelected(true)
				else
					gt.seekNodeByName(self.csbNode,"m_renshu"):getChildByTag(j):setSelected(false)
				end
			end
			gt.log(self.nn_renshu)
		end)
	end

	local function setBeilvControl1( )
		local nodebeilv1 = gt.seekNodeByName(self.csbNode,"m_beilv1"):getChildByTag(0)
		local nodebeilv2 = gt.seekNodeByName(self.csbNode,"m_beilv1"):getChildByTag(1)
		local nodebeilv3 = gt.seekNodeByName(self.csbNode,"m_beilv1"):getChildByTag(2)
		local huayangwanfa = gt.seekNodeByName(self.csbNode,"m_wanfa"):getChildByTag(2)
		local fanbeiRule = gt.seekNodeByName(self.csbNode,"m_fanbeiRule")
		local playsExplainImg = gt.seekNodeByName(self.csbNode,"Img_playsExplain")
		self.nn_beilv1 = 0
		local _scale = 1
		if self.nn_moshi1 == 0 then
			nodebeilv1:setVisible(true)
			nodebeilv1:setSelected(true)
			nodebeilv1:getChildByName("Text_1"):setString("小倍(1 2 3)")
			nodebeilv2:setVisible(false)
			nodebeilv2:setSelected(false)
			nodebeilv3:setVisible(false)
			nodebeilv3:setSelected(false)
			huayangwanfa:setVisible(true)
			fanbeiRule:setVisible(true)
			nodebeilv3:setPositionX(630)
			_scale = 0.93
		elseif self.nn_moshi1 == 1 then
			nodebeilv1:setVisible(true)
			nodebeilv1:setSelected(true)
			nodebeilv1:getChildByName("Text_1"):setString("小倍(2 3 4 5)")
			nodebeilv2:setVisible(true)
			nodebeilv2:setSelected(false)
			nodebeilv2:getChildByName("Text_1"):setString("中倍(6 9 12 15)")
			nodebeilv3:setVisible(true)
			nodebeilv3:setSelected(false)
			nodebeilv3:getChildByName("Text_1"):setString("大倍(5 10 20 30)")
			huayangwanfa:setVisible(true)
			fanbeiRule:setVisible(true)
			nodebeilv3:setPositionX(630)
			_scale = 0.93
		elseif self.nn_moshi1 == 2 then
			nodebeilv1:setVisible(true)
			nodebeilv1:setSelected(true)
			nodebeilv1:getChildByName("Text_1"):setString("小倍(1 2 3)")
			nodebeilv2:setVisible(false)
			nodebeilv2:setSelected(false)
			nodebeilv3:setVisible(false)
			nodebeilv3:setSelected(false)
			huayangwanfa:setVisible(false)
			playsExplainImg:setVisible(false)
			fanbeiRule:setVisible(false)
			self.nn_wanfa = 0
			self.nn_fanbeiRule = 0
			_scale = 1
		end
		nodebeilv1:setScale(_scale)
		nodebeilv2:setScale(_scale)
		nodebeilv3:setScale(_scale)
	end 

	setBeilvControl1()

	-- 模式
	local function setmoshi1( )
		local huayangwanfa = gt.seekNodeByName(self.csbNode,"m_wanfa"):getChildByTag(2)
		huayangwanfa:setVisible(true)
		local fanbeiRule = gt.seekNodeByName(self.csbNode,"m_fanbeiRule")
		fanbeiRule:setVisible(true)
		for i = 0 , 2 do
			local node =  gt.seekNodeByName(self.csbNode,"m_moshi1"):getChildByTag(i)
			if node then 
				node:setSelected(false) 
				local tmp = self.nn_moshi1 and self.nn_moshi1 or 0
				if tmp == i then 
					node:setSelected(true)	
					if tmp == 2 then
						huayangwanfa:setVisible(false)
						local playsExplainImg = gt.seekNodeByName(self.csbNode,"Img_playsExplain")
						playsExplainImg:setVisible(false)
						self.nn_wanfa = 0
						fanbeiRule:setVisible(false)
						self.nn_fanbeiRule = 0
					end
				end 
			end
			node:addEventListener(function(senderBtn, eventType)
				for j = 0, 2 do
					if i == j then 
						self.nn_moshi1 = j 
						gt.seekNodeByName(self.csbNode,"m_moshi1"):getChildByTag(j):setSelected(true)
					else
						gt.seekNodeByName(self.csbNode,"m_moshi1"):getChildByTag(j):setSelected(false)
					end
				end
				setBeilvControl1()
				gt.log(self.nn_moshi1)
			end)
		end
	end

	-- 抢庄
	local function setqiangzhuang1()
		for i = 0 , 3 do
			local node =  gt.seekNodeByName(self.csbNode,"m_qiangzhuang1"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self.nn_qiangzhuang1 and self.nn_qiangzhuang1 or 0
			if tmp == i then node:setSelected(true) end end
			node:addEventListener(function(senderBtn, eventType)
				for j = 0, 3 do
					if i == j then 
						self.nn_qiangzhuang1 = j 
						gt.seekNodeByName(self.csbNode,"m_qiangzhuang1"):getChildByTag(j):setSelected(true)
					else
						gt.seekNodeByName(self.csbNode,"m_qiangzhuang1"):getChildByTag(j):setSelected(false)
					end
				end
				gt.log(self.nn_qiangzhuang1)
			end)
		end
	end

	-- 倍率
	local function setbeilv1()
		for i = 0 , 2 do
			local node =  gt.seekNodeByName(self.csbNode,"m_beilv1"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self.nn_beilv1 and self.nn_beilv1 or 0
			if tmp == i then node:setSelected(true) end end
			node:addEventListener(function(senderBtn, eventType)
				for j = 0, 2 do
					if i == j then 
						self.nn_beilv1 = j 
						gt.seekNodeByName(self.csbNode,"m_beilv1"):getChildByTag(j):setSelected(true)
					else
						gt.seekNodeByName(self.csbNode,"m_beilv1"):getChildByTag(j):setSelected(false)
					end
				end
				gt.log(self.nn_beilv1)
			end)
		end
	end

	-- 轮流坐庄
	local function setBeilvControl2( )
		local nodebeilv1 = gt.seekNodeByName(self.csbNode,"m_beilv2"):getChildByTag(0)
		local nodebeilv2 = gt.seekNodeByName(self.csbNode,"m_beilv2"):getChildByTag(1)
		local nodebeilv3 = gt.seekNodeByName(self.csbNode,"m_beilv2"):getChildByTag(2)
		local huayangwanfa = gt.seekNodeByName(self.csbNode,"m_wanfa"):getChildByTag(2)
		local playsExplainImg = gt.seekNodeByName(self.csbNode,"Img_playsExplain")
		local fanbeiRule = gt.seekNodeByName(self.csbNode,"m_fanbeiRule")
		local _scale = 1
		if self.nn_moshi2 == 0 then
			nodebeilv1:setVisible(true)
			nodebeilv1:setSelected(true)
			nodebeilv1:getChildByName("Text_1"):setString("小倍(2 3 4 5)")
			nodebeilv2:setVisible(true)
			nodebeilv2:setSelected(false)
			nodebeilv2:getChildByName("Text_1"):setString("中倍(6 9 12 15)")
			nodebeilv3:setVisible(true)
			nodebeilv3:setSelected(false)
			nodebeilv3:getChildByName("Text_1"):setString("大倍(5 10 20 30)")
			nodebeilv3:setPositionX(630)
			huayangwanfa:setVisible(true)
			fanbeiRule:setVisible(true)
			_scale = 0.93
		elseif self.nn_moshi2 == 1 then
			nodebeilv1:setVisible(true)
			nodebeilv1:setSelected(true)
			nodebeilv1:getChildByName("Text_1"):setString("小倍(2 3 4 5)")
			nodebeilv2:setVisible(true)
			nodebeilv2:setSelected(false)
			nodebeilv2:getChildByName("Text_1"):setString("中倍(6 9 12 15)")
			nodebeilv3:setVisible(true)
			nodebeilv3:setSelected(false)
			nodebeilv3:getChildByName("Text_1"):setString("大倍(5 10 20 30)")
			nodebeilv3:setPositionX(630)
			huayangwanfa:setVisible(true)
			fanbeiRule:setVisible(true)
			_scale = 0.93
		elseif self.nn_moshi2 == 2 then
			nodebeilv1:setVisible(true)
			nodebeilv1:setSelected(true)
			nodebeilv1:getChildByName("Text_1"):setString("小倍(1 2 3)")
			nodebeilv2:setVisible(false)
			nodebeilv2:setSelected(false)
			nodebeilv3:setVisible(true)
			nodebeilv3:setSelected(false)
			nodebeilv3:getChildByName("Text_1"):setString("大倍(4 5 6)")
			nodebeilv3:setPositionX(395)
			huayangwanfa:setVisible(false)
			playsExplainImg:setVisible(false)
			fanbeiRule:setVisible(false)
			_scale = 1
			self.nn_wanfa = 0
			self.nn_fanbeiRule = 0
		end
		nodebeilv1:setScale(_scale)
		nodebeilv2:setScale(_scale)
		nodebeilv3:setScale(_scale)

	end 

	setBeilvControl2()

	-- 模式
	local function setmoshi2()
		local huayangwanfa = gt.seekNodeByName(self.csbNode,"m_wanfa"):getChildByTag(2)
		huayangwanfa:setVisible(true)
		local fanbeiRule = gt.seekNodeByName(self.csbNode,"m_fanbeiRule")
		fanbeiRule:setVisible(true)
		for i = 0 , 2 do
			local node =  gt.seekNodeByName(self.csbNode,"m_moshi2"):getChildByTag(i)
			if node then 
				node:setSelected(false) 
				local tmp = self.nn_moshi2 and self.nn_moshi2 or 0
				if tmp == i then 
					node:setSelected(true)
					if tmp == 2 then
						huayangwanfa:setVisible(false)
						local playsExplainImg = gt.seekNodeByName(self.csbNode,"Img_playsExplain")
						playsExplainImg:setVisible(false)
						self.nn_wanfa = 0
						fanbeiRule:setVisible(false)
						self.nn_fanbeiRule = 0
					end
				end 
			end
			node:addEventListener(function(senderBtn, eventType)
				gt.log("----i", i)
				for j = 0, 2 do
					if i == j then 
						self.nn_moshi2 = j
						gt.seekNodeByName(self.csbNode,"m_moshi2"):getChildByTag(j):setSelected(true)
					else
						gt.seekNodeByName(self.csbNode,"m_moshi2"):getChildByTag(j):setSelected(false)
					end
				end
				setBeilvControl2()
				gt.log(self.nn_moshi2)
			end)
		end
	end

	-- 抢庄
	local function setqiangzhuang2()
		self.nn_qiangzhuang2 = 0
		gt.seekNodeByName(self.csbNode,"m_qiangzhuang2"):getChildByTag(1):setSelected(true)
	end

	-- 倍率
	local function setbeilv2()
		for i = 0 , 2 do
			local node =  gt.seekNodeByName(self.csbNode,"m_beilv2"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self.nn_beilv2 and self.nn_beilv2 or 0
			if tmp == i then node:setSelected(true) end end
			node:addEventListener(function(senderBtn, eventType)
				for j = 0, 2 do
					if i == j then 
						self.nn_beilv2 = j 
						gt.seekNodeByName(self.csbNode,"m_beilv2"):getChildByTag(j):setSelected(true)
					else
						gt.seekNodeByName(self.csbNode,"m_beilv2"):getChildByTag(j):setSelected(false)
					end
				end
				gt.log(self.nn_beilv2)
			end)
		end
	end

	local function setrule()
		playsExplainImg:setVisible(false)
		if self.nn_guize == 1 then
		    -- 看牌抢庄
			gt.seekNodeByName(self.csbNode,"m_moshi1"):setVisible(true)
			gt.seekNodeByName(self.csbNode,"m_qiangzhuang1"):setVisible(true)
			gt.seekNodeByName(self.csbNode,"m_beilv1"):setVisible(true)
			gt.seekNodeByName(self.csbNode,"m_moshi2"):setVisible(false)
			gt.seekNodeByName(self.csbNode,"m_qiangzhuang2"):setVisible(false)
			gt.seekNodeByName(self.csbNode,"m_beilv2"):setVisible(false)
			-- 模式
			setmoshi1()
		    -- 抢庄
		    setqiangzhuang1()
		    -- 倍率
		    setbeilv1()
		elseif self.nn_guize == 0 then
			-- 轮流坐庄
			gt.seekNodeByName(self.csbNode,"m_moshi1"):setVisible(false)
			gt.seekNodeByName(self.csbNode,"m_qiangzhuang1"):setVisible(false)
			gt.seekNodeByName(self.csbNode,"m_beilv1"):setVisible(false)
			gt.seekNodeByName(self.csbNode,"m_moshi2"):setVisible(true)
			gt.seekNodeByName(self.csbNode,"m_qiangzhuang2"):setVisible(true)
			gt.seekNodeByName(self.csbNode,"m_beilv2"):setVisible(true)
		    -- 模式
		    setmoshi2()
		    -- 抢庄
		    setqiangzhuang2()
		    -- 倍率
		    setbeilv2()
		end
	end

	setrule()

	-- 规则
	for i = 0 , 1 do
		local node =  gt.seekNodeByName(self.csbNode,"m_rule"):getChildByTag(i)
		if node then node:setSelected(false) 
		local tmp = self.nn_guize and self.nn_guize or 1
		if tmp == i then node:setSelected(true) end end
		node:addEventListener(function(senderBtn, eventType)
			for j = 0, 1 do
				if i == j then 
					self.nn_guize = j 
					gt.seekNodeByName(self.csbNode,"m_rule"):getChildByTag(j):setSelected(true)
				else
					gt.seekNodeByName(self.csbNode,"m_rule"):getChildByTag(j):setSelected(false)
				end
			end
			setrule()
			gt.log(self.nn_guize)
		end)
	end

	-- 是否托管
	for i = 1 , 1 do
		local node =  gt.seekNodeByName(self.csbNode,"m_wanfa"):getChildByTag(i)
		if node then node:setSelected(false) 
		local tmp = self.nn_tuoguan and self.nn_tuoguan or 1
		if tmp == i then node:setSelected(true) end end
		node:addEventListener(function(senderBtn, eventType)
			self.nn_tuoguan = node:isSelected() and 1 or 0 
			gt.log(self.nn_tuoguan)
		end)
	end

	-- 花样玩法
	for i = 2 , 2 do
		local node =  gt.seekNodeByName(self.csbNode,"m_wanfa"):getChildByTag(i)
		if node then node:setSelected(false) 
		local tmp = self.nn_wanfa and self.nn_wanfa or 0
		if tmp == i-1 then node:setSelected(true) end end
		node:addEventListener(function(senderBtn, eventType)
			self.nn_wanfa = node:isSelected() and 1 or 0 
			gt.log(self.nn_wanfa)
		end)
	end

	-- 闲家推注
	for i = 0 , 4 do
		local node =  gt.seekNodeByName(self.csbNode,"m_xianjiatuizhu"):getChildByTag(i)
		if node then node:setSelected(false) 
		local tmp = self.nn_xianjiatuizhu and self.nn_xianjiatuizhu or 0
		if tmp == i then node:setSelected(true) end end
		node:addEventListener(function(senderBtn, eventType)
			for j = 0, 4 do
				if i == j then 
					self.nn_xianjiatuizhu = j 
					gt.seekNodeByName(self.csbNode,"m_xianjiatuizhu"):getChildByTag(j):setSelected(true)
				else
					gt.seekNodeByName(self.csbNode,"m_xianjiatuizhu"):getChildByTag(j):setSelected(false)
				end
			end
			gt.log(self.nn_xianjiatuizhu)
		end)
	end

	-- 翻倍规则
	for i = 0 , 1 do
		local node =  gt.seekNodeByName(self.csbNode,"m_fanbeiRule"):getChildByTag(i)
		if node then node:setSelected(false) 
		gt.log(type(self.nn_fanbeiRule))
		local tmp = self.nn_fanbeiRule and self.nn_fanbeiRule or 0
		if tmp == i then node:setSelected(true) end end
		node:addEventListener(function(senderBtn, eventType)
			for j = 0, 1 do
				if i == j then 
					self.nn_fanbeiRule = j 
					gt.seekNodeByName(self.csbNode,"m_fanbeiRule"):getChildByTag(j):setSelected(true)
				else
					gt.seekNodeByName(self.csbNode,"m_fanbeiRule"):getChildByTag(j):setSelected(false)
				end
				local playsExplainImg = gt.seekNodeByName(self.csbNode,"Img_playsExplain")
				if self.nn_fanbeiRule == 0 then
					playsExplainImg:loadTexture("res/zy_zjh/create_room_explain3.png")
				else
					playsExplainImg:loadTexture("res/zy_zjh/create_room_explain4.png")
				end
			end
			gt.log(self.nn_fanbeiRule)
		end)
	end

	local playsExplainImg = gt.seekNodeByName(self.csbNode, "Img_playsExplain")

	gt.addBtnPressedListener(gt.seekNodeByName(self.csbNode,"Btn_question"), function()
		playsExplainImg:setVisible(not playsExplainImg:isVisible())
	end)

	gt.setOnViewClickedListener(self.csbNode:getChildByName("Image_2"), function()
		playsExplainImg:setVisible(false)
	end)

    --返回按钮
    local backBtn = gt.seekNodeByName(self.csbNode, "Btn_back")
	gt.addBtnPressedListener(backBtn,function ()
    	self:removeFromParent()
	end)

    --关闭按钮
    local closeBtn = gt.seekNodeByName(self.csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn,function ()
    	if self.callback then
    		self.callback()
    	end
	end)
end

-- start --
--------------------------------
-- @class function
-- @description 创建房间消息
-- @param msgTbl 消息体
-- end --
function CreateRoomNN:onRcvCreateRoomNN(msgTbl)
	gt.log("创建房间消息 ============== ")
	gt.dump(msgTbl)
	gt.dumploglogin("创建房间消息")
	gt.dumploglogin(msgTbl)
	if self.createSchedule then
		gt.scheduler:unscheduleScriptEntry(self.createSchedule)
		self.createSchedule = nil
	end
	
	if msgTbl.kErrorCode ~= 0 then
		-- 创建失败
		gt.removeLoadingTips()
		-- 房卡不足提示
		gt.log("房卡不足")
		if msgTbl.kErrorCode == 1 then
			require("client/game/dialog/NoticeTipsCommon"):create(2, "房卡不足，请在商城购买")
		elseif msgTbl.kErrorCode == 8 then
			Toast.showToast(self, "房主建房数量超限，解散后重试", 2)
		elseif msgTbl.kErrorCode == 9 then
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "获取GPS信息失败！", nil, nil, true)
		else
			require("client/game/dialog/NoticeTipsCommon"):create(2, "创建房间失败")
		end
	else
		gt.CreateRoomNNFlag = true
	end
end

return CreateRoomNN