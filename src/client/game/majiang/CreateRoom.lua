local gt = cc.exports.gt

local CreateRoom = class("CreateRoom", function()
	return gt.createMaskLayer()
end)

function CreateRoom:onNodeEvent(eventName)
	if "enter" == eventName then
		gt.soundEngine:Poker_playEffect("res/sfx/sound_nn/createroomSZP.mp3",false)
	elseif "exit" == eventName then
		if self._time then gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
		gt.dispatchEvent("show_text")
		gt.socketClient:unregisterMsgListener(gt.GC_CREATE_ROOM)
	end
end

function CreateRoom:init()

	-- self.mj_btn = gt.seekNodeByName(self.csbNode, "mj")
	-- self.poker_btn = gt.seekNodeByName(self.csbNode, "poker")
	
	-- self:setBtn()
	-- gt.setOnViewClickedListener(self.poker_btn, function()

			

	-- 		if self._type then return end
	-- 		self._type = true
		
	-- 		self:setBtn()

	-- end)

	-- gt.setOnViewClickedListener(self.mj_btn, function()
	-- 		if not self._type then return end
	-- 		self._type = false
	-- 		self:setBtn()
	-- 		--添加大玩法标题
	-- 		--self:_addTitle()
	-- 		self:_changePlayType(self.mahjongType)
	-- 		self:updatePageNode(self.currIdx)
	-- end)
	self:pokerBtn()

end


function CreateRoom:pokerBtn()


	for o = 1 , 2 do 

		local idx = o - 1
		local nnode = gt.seekNodeByName(self.csbNode,"m_imgBg_"..(o-1))
		local btnNode = gt.seekNodeByName(nnode,"m_nodeContents"..o)

		for i = 1, 4 do 
			local node =  gt.seekNodeByName(btnNode,"m_xiazhu"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["xiazhu"..idx]  and self["xiazhu"..idx] or 1
			if tmp == i then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				gt.log("oooooooo",o)

				for j = 1, 4 do
					if i == j then 
						self["xiazhu"..self.play_types] = j 
						gt.seekNodeByName(btnNode,"m_xiazhu"):getChildByTag(j):setSelected(true)
					else
						gt.seekNodeByName(btnNode,"m_xiazhu"):getChildByTag(j):setSelected(false)
					end
				end
			 end)
		end


		for i = 1, 3 do
			local node =  gt.seekNodeByName(btnNode,"m_jushu"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["jushu"..idx]  and self["jushu"..idx] or 1
			if tmp == i then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				for j = 1, 3 do
					if i == j then 
						self["jushu"..self.play_types] = j 
						gt.seekNodeByName(btnNode,"m_jushu"):getChildByTag(j):setSelected(true)
					else
						gt.seekNodeByName(btnNode,"m_jushu"):getChildByTag(j):setSelected(false)
					end
				end
				
			end)
		end

		for i = 1, 1 do
			local node =  gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["wanfa"..idx]
			gt.log("tmp.......",tmp)
			if tmp == i then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				
				self["wanfa"..self.play_types] = 1 -self["wanfa"..self.play_types] --math.abs(1-(self.wanfa  and 1 or 0))
				
				gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(1):setSelected(self["wanfa"..self.play_types] == 1 and true or false)
			end)

		end


		for i = 2,2 do
			local node =  gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["wanfa1"..0]
			gt.log("tmp.......",tmp)
			if tmp == 1 then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				self["wanfa1"..0] = 1 -self["wanfa1"..0] --math.abs(1-(self.wanfa  and 1 or 0))
				gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(2):setSelected(self["wanfa1"..0] == 1 and true or false)
			end)

		end


			for i = 3, 3 do
			local node =  gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["wanfa2"..idx]
			gt.log("tmp.......",tmp)
			if tmp == 1 then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				self["wanfa2"..idx] = 1 -self["wanfa2"..idx] --math.abs(1-(self.wanfa  and 1 or 0))
				gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(3):setSelected(self["wanfa2"..idx] == 1 and true or false)
			end)

		end


		for i = 4, 4 do
			local node =  gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["wanfa3"..0]
			gt.log("tmp.......",tmp)
			if tmp == 1 then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				self["wanfa3"..0] = 1 -self["wanfa3"..0] --math.abs(1-(self.wanfa  and 1 or 0))
				gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(4):setSelected(self["wanfa3"..0] == 1 and true or false)
			end)

		end


		for i = 5, 5 do
			local node =  gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["wanfa4"..idx]
			gt.log("tmp.......",tmp)
			if tmp == 1 then node:setSelected(true) gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i+1):setVisible(true) else gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i+1):setVisible(false) end end
			gt.setOnViewClickedListener(node, function()
				self["wanfa4"..self.play_types] = 1 -self["wanfa4"..self.play_types] --math.abs(1-(self.wanfa  and 1 or 0))
				gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i):setSelected(self["wanfa4"..self.play_types] == 1 and true or false)
				if self["wanfa4"..self.play_types] == 0 then gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i+1):setSelected(false) self["wanfa5"..self.play_types] = 0 gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i+1):setVisible(false) return  else gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i+1):setVisible(true) end
			end)

		end

		for i = 6, 6 do

			local node =  gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["wanfa5"..idx]
			gt.log("tmp.......",tmp)
			if tmp == 1 then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()

				if self["wanfa4"..self.play_types] == 0 then gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i):setSelected(false) self["wanfa5"..self.play_types] = 0 return end
				self["wanfa5"..self.play_types] = 1 -self["wanfa5"..self.play_types] --math.abs(1-(self.wanfa  and 1 or 0))
				gt.seekNodeByName(btnNode,"m_wanfa"):getChildByTag(i):setSelected(self["wanfa5"..self.play_types] == 1 and true or false)
			end)

		end

		for i = 1, 2 do
			local node =  gt.seekNodeByName(btnNode,"m_moshi"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["moshi"..0]  and self["moshi"..0] or 1
			if tmp == i then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				if self["_renshu"..0] == 2  then gt.seekNodeByName(btnNode,"m_moshi"):getChildByTag(2):setSelected(false) gt.seekNodeByName(btnNode,"m_moshi"):getChildByTag(1):setSelected(true) return end
				for j = 1, 2 do
					if i == j then 
						self["moshi"..0] = j 
						gt.seekNodeByName(btnNode,"m_moshi"):getChildByTag(j):setSelected(true)
					else
						gt.seekNodeByName(btnNode,"m_moshi"):getChildByTag(j):setSelected(false)
					end
				end
			end)
		end


		for i = 1, 4 do
			local node =  gt.seekNodeByName(btnNode,"m_beishu"):getChildByTag(i)
			if node then node:setSelected(false) 
				gt.log("b_______________")
			local tmp = self["beishu"..idx]  and self["beishu"..idx] or 1
			if tmp == i then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				for j = 1, 4 do
					if i == j then 
						self["beishu"..self.play_types] = j 
						gt.seekNodeByName(btnNode,"m_beishu"):getChildByTag(j):setSelected(true)
					else
						gt.seekNodeByName(btnNode,"m_beishu"):getChildByTag(j):setSelected(false)
					end
				end
			end)
		end

		for i = 1, 4 do
			local node =  gt.seekNodeByName(btnNode,"menpai"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["menpai"..idx]  and self["menpai"..idx] or 1
			if tmp == i then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				for j = 1, 4 do
					if i == j then 
						self["menpai"..self.play_types] = j 
						gt.seekNodeByName(btnNode,"menpai"):getChildByTag(j):setSelected(true)
					else
						gt.seekNodeByName(btnNode,"menpai"):getChildByTag(j):setSelected(false)
					end
				end
			end)
		end

		for i = 1, 1 do
			local node =  gt.seekNodeByName(btnNode,"vip"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["vip"..idx]  and self["vip"..idx] or 1
			if tmp == i then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				self["vip"..self.play_types] = math.abs(1-(self["vip"..self.play_types]  and self["vip"..self.play_types] or 1))
				
				gt.seekNodeByName(btnNode,"vip"):getChildByTag(i):setSelected(self["vip"..self.play_types] == 1 and true or false)
			end)
		end


		for i = 2, 2 do
			local node =  gt.seekNodeByName(btnNode,"vip"):getChildByTag(i)
			if node then node:setSelected(false) 
			local tmp = self["vip1"..idx]  and self["vip1"..idx] or 1
			if tmp == (i-1) then node:setSelected(true) end end
			gt.setOnViewClickedListener(node, function()
				self["vip1"..self.play_types] = math.abs(1-(self["vip1"..self.play_types]  and self["vip1"..self.play_types] or 1))
				
				gt.seekNodeByName(btnNode,"vip"):getChildByTag(i):setSelected(self["vip1"..self.play_types] == 1 and true or false)
			end)
		end

		if o == 2 then
			self["_renshu"..1] = 2
			self["moshi"..1] = 1
			self["wanfa1"..1] = 1
			self["wanfa3"..1] = 1
			self["__time"..1] = 2
			
			for i = 3, 3 do
				local node =  gt.seekNodeByName(btnNode,"vip"):getChildByTag(i)
				if node then node:setSelected(false) 
				local tmp = self["vip2"..idx]  and self["vip2"..idx] or 1
				
				if tmp == (i-2) then node:setSelected(true) end end
				gt.setOnViewClickedListener(node, function()
					self["vip2"..self.play_types] = math.abs(1-(self["vip2"..self.play_types]  and self["vip2"..self.play_types] or 1))
					
					gt.seekNodeByName(btnNode,"vip"):getChildByTag(i):setSelected(self["vip2"..self.play_types] == 1 and true or false)
				end)
			end

		else
			
			for i = 1, 3 do 
				local node = gt.seekNodeByName(btnNode, "m_time"):getChildByTag(i)
				if node then node:setSelected(false) 
				local tmp = self["__time"..0] and self["__time"..0] or 3
				if tmp == i then node:setSelected(true) end
				gt.setOnViewClickedListener(node, function()
					for j = 1, 3 do
						if i == j then 
							self["__time"..0] = j 
							gt.seekNodeByName(btnNode,"m_time"):getChildByTag(j):setSelected(true)
						else
							gt.seekNodeByName(btnNode,"m_time"):getChildByTag(j):setSelected(false)
						end
					end
				end)
				end
			end

			for i = 1 , 2 do
				local node = gt.seekNodeByName(btnNode, "renshu"):getChildByTag(i)
				if node then node:setSelected(false) 
				local tmp = self["_renshu"..0]  and self["_renshu"..0] or 1
				if tmp == i then node:setSelected(true) 

					if  i == 2 then 

						gt.seekNodeByName(btnNode,"m_moshi"):getChildByTag(2):setVisible(false)
						
					else
						gt.seekNodeByName(btnNode,"m_moshi"):getChildByTag(2):setVisible(true)

					end


					end end
				gt.setOnViewClickedListener(node, function()
					for j = 1, 2 do
						if i == j then 
							self["_renshu"..0] = j 
							gt.seekNodeByName(btnNode,"renshu"):getChildByTag(j):setSelected(true)
						else
							gt.seekNodeByName(btnNode,"renshu"):getChildByTag(j):setSelected(false)
						end
					end

					if self["_renshu"..0] == 2 then 

						for i = 1, 2 do
							local node =  gt.seekNodeByName(btnNode,"m_moshi"):getChildByTag(i)
							if i == 2 then node:setSelected(false) node:setVisible(false) else node:setSelected(true)  end
						end
						self["moshi"..0] = 1 
					else
						gt.seekNodeByName(btnNode,"m_moshi"):getChildByTag(2):setVisible(true)

					end

				end)
			end
		end


		self.long = gt.seekNodeByName(self.csbNode, "long")
		self.beikai = gt.seekNodeByName(self.csbNode,"beikai")
		self.tuguan = gt.seekNodeByName(self.csbNode, "tuguan")
		self.mai_xiao = gt.seekNodeByName(self.csbNode, "mai_xiao")

		gt.addBtnPressedListener(gt.seekNodeByName(btnNode,"Button__3"), function()
				-- self.beikai:setVisible(not self.beikai:isVisible())
				self:hideTips()
				self.beikai:setVisible(true)

			end)


			gt.addBtnPressedListener(gt.seekNodeByName(btnNode,"Button__2"), function()
				-- self.tuguan:setVisible(not self.tuguan:isVisible())
				self:hideTips()
				self.tuguan:setVisible(true)

			end)


		gt.addBtnPressedListener(gt.seekNodeByName(btnNode,"Button__4"), function()
			-- self.long:setVisible(not self.long:isVisible())
				self:hideTips()
				self.long:setVisible(true)
			end)

		gt.addBtnPressedListener(gt.seekNodeByName(btnNode,"Button__5"), function()
			-- self.mai_xiao:setVisible(not self.mai_xiao:isVisible())
				self:hideTips()
				self.mai_xiao:setVisible(true)
			end)

		-- gt.addBtnPressedListener(gt.seekNodeByName(self.csbNode,"BtnLayer"), function()
		-- 	long:setVisible(false)
		-- 	beikai:setVisible(false)
		-- 	tuguan:setVisible(false)
		-- 	mai_xiao:setVisible(false)
		-- 	end)
		gt.setOnViewClickedListener(self.csbNode:getChildByName("Image_2"),function()
				self:hideTips()
			end)

	end




	for i = 0 , 1 do 
		local node = self.csbNode:getChildByName("jinddian_"..i)
		local node1 = self.csbNode:getChildByName("m_imgBg_"..i)
					
		if node and node1 then
			node1:setVisible(self.play_types == i)
			node:setEnabled(self.play_types ~= i)
		
			gt.setOnViewClickedListeners(node, function()
				self.play_types = i 
				
				self:hideTips()
				for j = 0 , 1 do
					local n = self.csbNode:getChildByName("jinddian_"..j)
					if n then 
						n:setEnabled(j~=i)
					end
					local n1 = self.csbNode:getChildByName("m_imgBg_"..j)
					if n1 then n1:setVisible(j==i) end
				end

			end)


		end
	end





end




function CreateRoom:hideTips( )
	self.long:setVisible(false)
	self.beikai:setVisible(false)
	self.tuguan:setVisible(false)
	self.mai_xiao:setVisible(false)
end

function CreateRoom:getxiazhuNum(num)

	if num == 2 then 
		return 10
	elseif num == 3 then 
		return 15
	elseif num == 4 then 
		return 30
	else 
		return 5
	end

end

function CreateRoom:setBtn()

	self.poker_btn:loadTexture(self._type and "createRoomNew/poker1.png" or "createRoomNew/poker.png")
	self.mj_btn:loadTexture(self._type and "createRoomNew/mj.png" or "createRoomNew/mj1.png")


	self.pageNode:setVisible(not self._type)
	self.pageListView:setVisible(not self._type)
	gt.seekNodeByName(self.csbNode,"poker_node"):setVisible(self._type)
		
	for i = 1 , self.mahjongTypeCount  do	 self["m_nodeContent"..i]:setVisible(not self._type) end

	gt.log("self.mahjongTypeCountPoker.",self.mahjongTypeCountPoker)
	for i = 1 , self.mahjongTypeCountPoker	do  self["m_nodeContents"..i]:setVisible(self._type)  end

	for i = 1, self.mahjongTypeCountPoker do
		-- if  玩法 then 

		--end
		local btn = gt.seekNodeByName(self.csbNode,"poker"..i)
		btn:setTouchEnabled(false)
		btn:setBright(false)

		-- 切换玩法
		gt.setOnViewClickedListener(btn,function()


			end)
	end
	if not self._type then self:updatePageNode(self.currIdx) self:_changePlayType(self.mahjongType) end -- self:_addTitle() end
end

function CreateRoom:ctor(callback, deskType, parent)

	--初始化成员变量
	self:_initParams()

	--初始化默认设置
	self:_initParameter()

	--初始化UI
	self:_initUI()
	
	--添加大玩法标题
	self:_addTitle()

	--新增poker  12-25 csw
	self:init()

	if callback then
		self.callback = callback
	end

	self.deskType = false
	if deskType then
		self.deskType = deskType
	end

	self.parent = nil

	if parent then
		self.parent = parent
	end

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local createBtn = gt.seekNodeByName(self, "Btn_create")
	
	gt.addBtnPressedListener(createBtn, function()


		if self._type == false then 
	    ------------------selfsw 12 -20

	

	    -- csw 12 -20
		
		else

			local kGpsLng = "0"
			local kGpsLat = "0"

			
			
			local isvip = false
			local msgToSend = {}
			msgToSend.kGpsLimit = self["vip"..self.play_types]
			if self.deskType then
				msgToSend.kMId = gt.CG_CREATE_ROOM_FZ
			else
				msgToSend.kMId = gt.CG_CREATE_ROOM
				if self["vip"..self.play_types] == 1 then 
					--gt.showLoadingTips(gt.getLocationString("LTKey_0059"))
					local data = ""
					local time = 0
					isvip = true
					if self._time then 	gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
					self._time = gt.scheduler:scheduleScriptFunc(function(dt)

						data = Utils.getLocationInfo()

						if (data.longitude and data.latitue and data.longitude ~= "" and data.latitue ~= "" and gt.isAndroidPlatform()) or (data.longitude and data.longitude ~= 0 and data.latitue and data.latitue ~= 0 and gt.isIOSPlatform()) then
							gt.removeLoadingTips()
							if self._time then gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
							kGpsLng = data.longitude
							kGpsLat = data.latitue

							msgToSend.kPlayType = {}
							msgToSend.kFlag = self["jushu"..self.play_types] --== 1 and 8 or 16 -- (8 or 16) -- 局数 1 代表 8  2 代表 16
							msgToSend.kState =   102        --   炸金花  102，斗地主  101，牛牛    103，
							msgToSend.kFeeType =  1     --（费用类型 ，0:房主付费 1:玩家分摊）
							msgToSend.kCheatAgainst = 0 -- // 是否防作弊，0:不防作弊 1：防作弊 -- 暂时没用
							msgToSend.kDeskType = 0
							msgToSend.kGpsLng = tostring(kGpsLng)
							msgToSend.kGpsLat = tostring(kGpsLat)

							msgToSend.kPlayType[1] = self["moshi"..self.play_types]    -- //1玩法:      游戏模式   1：普通模式   2：大牌模式
							msgToSend.kPlayType[2] = self:getxiazhuNum(self["xiazhu"..self.play_types])    -- //2下注轮数： 实际数值，5--5轮   10--10轮
							msgToSend.kPlayType[3] = self["beishu"..self.play_types]    -- //3选择倍数            实际数值   1，2，3，
							msgToSend.kPlayType[4] = (self["menpai"..self.play_types]-1)    -- //4闷牌轮数            无必闷0， 闷1轮，闷2轮，闷3轮
							msgToSend.kPlayType[5] = self["wanfa"..self.play_types]    -- //5特殊加分项       用户拿到豹子，同花顺牌型加分 true false
							msgToSend.kPlayType[6] = self["wanfa1"..self.play_types]                --定时器自动操作 0--没有选择 1--选择 9
							msgToSend.kPlayType[7] = self["_renshu"..self.play_types] == 2 and 8 or 5               -- 人数
							msgToSend.kPlayType[8] = self["wanfa2"..self.play_types]	            --倍开  0--没有选择 1--选择 11
							msgToSend.kPlayType[9] = self["wanfa3"..self.play_types]			    --/8天龙地龙       0--没有选择 1--选择 12
							msgToSend.kPlayType[11] = self["wanfa4"..self.play_types]			    --/8买小       0--没有选择 1--选择 12
							msgToSend.kPlayType[12] = self["wanfa5"..self.play_types]			    --/8豹子最大       0--没有选择 1--选择 12
							msgToSend.kPlayType[10] = self["vip1"..self.play_types]			    -- 允许动态加入
							msgToSend.kPlayType[13] = 0
							msgToSend.kPlayType[14] = self.play_types
							msgToSend.kPlayType[15] = self.play_types == 0 and 0 or self["vip2"..self.play_types]
							msgToSend.kPlayType[16] = self["__time"..self.play_types]
							msgToSend.kGreater2CanStart = 1              

							
							
							gt.dump(msgToSend)
							gt.socketClient:sendMessage(msgToSend)

							gt.showLoadingTips("房间创建中...")

						local chutaiAnimateResult = function(delta)
							--print("---------------current time:", self.createTime)
							if self.createTime == nil or self.createTime >= 30 then
								gt.removeLoadingTips()
								if self.createSchedule then
						 			gt.scheduler:unscheduleScriptEntry(self.createSchedule)
						 			self.createSchedule = nil
						 		end
							end
							if self.createTime ~= nil then
								self.createTime = self.createTime + 1
							end
					 	end
					 	self.createTime = 1
						self.createSchedule = gt.scheduler:scheduleScriptFunc(chutaiAnimateResult, 1, false)


						end
						time = time + dt
						if time > 2 then 
							if self._time then 	gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
							gt.removeLoadingTips()
							local str_des = "获取GPS失败，您创建的是【相邻位置禁止进入】的房间，必须开启GPS位置才能进入!"
							require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
							str_des, nil, nil, true)
							
						end
					end,0,false)
				end

			end

			if not isvip then 	
				msgToSend.kPlayType = {}
				msgToSend.kFlag = self["jushu"..self.play_types] --== 1 and 1 or 16 -- (8 or 16) -- 局数 1 代表 8  2 代表 16
				msgToSend.kState =   102        --   炸金花  102，斗地主  101，牛牛    103，
				msgToSend.kFeeType =  1     --（费用类型 ，0:房主付费 1:玩家分摊）
				msgToSend.kCheatAgainst = 0 -- // 是否防作弊，0:不防作弊 1：防作弊 -- 暂时没用
				msgToSend.kDeskType = 0
				msgToSend.kGpsLng = tostring(kGpsLng)
				msgToSend.kGpsLat = tostring(kGpsLat)

				msgToSend.kPlayType[1] = self["moshi"..self.play_types]    -- //1玩法:      游戏模式   1：普通模式   2：大牌模式
				msgToSend.kPlayType[2] = self:getxiazhuNum(self["xiazhu"..self.play_types])    -- //2下注轮数： 实际数值，5--5轮   10--10轮
				msgToSend.kPlayType[3] = self["beishu"..self.play_types]    -- //3选择倍数            实际数值   1，2，3，
				msgToSend.kPlayType[4] = (self["menpai"..self.play_types]-1)    -- //4闷牌轮数            无必闷0， 闷1轮，闷2轮，闷3轮
				msgToSend.kPlayType[5] = self["wanfa"..self.play_types]    -- //5特殊加分项       用户拿到豹子，同花顺牌型加分 true false
				msgToSend.kPlayType[6] = self["wanfa1"..self.play_types]                --定时器自动操作 0--没有选择 1--选择
				msgToSend.kPlayType[7] = self["_renshu"..self.play_types] == 2 and 8 or 5                -- 人数
				msgToSend.kPlayType[8] = self["wanfa2"..self.play_types]	            --倍开  0--没有选择 1--选择
				msgToSend.kPlayType[9] = self["wanfa3"..self.play_types]			    --/8天龙地龙       0--没有选择 1--选择
				msgToSend.kPlayType[11] = self["wanfa4"..self.play_types]			    --/8买小       0--没有选择 1--选择 12
				msgToSend.kPlayType[12] = self["wanfa5"..self.play_types]			    --/8豹子最大       0--没有选择 1--选择 12
				msgToSend.kPlayType[10] = self["vip1"..self.play_types]			    -- 允许动态加入
				msgToSend.kPlayType[13] = 0
				msgToSend.kPlayType[14] = self.play_types
				msgToSend.kPlayType[15] = self.play_types == 0 and 0 or self["vip2"..self.play_types]
				msgToSend.kPlayType[16] = self["__time"..self.play_types]
				msgToSend.kGreater2CanStart = 1

				
				gt.dump(msgToSend)
				gt.socketClient:sendMessage(msgToSend)

				gt.showLoadingTips("房间创建中...")

				local chutaiAnimateResult = function(delta)
				--	print("---------------current time:", self.createTime)
					if self.createTime == nil or self.createTime >= 30 then
						gt.removeLoadingTips()
						if self.createSchedule then
				 			gt.scheduler:unscheduleScriptEntry(self.createSchedule)
				 			self.createSchedule = nil
				 		end
					end
					if self.createTime ~= nil then
						self.createTime = self.createTime + 1
					end
			 	end
			 	self.createTime = 1
				self.createSchedule = gt.scheduler:scheduleScriptFunc(chutaiAnimateResult, 1, false)

			end
		end

	
		
		--保存设置
		--大玩法
		cc.UserDefault:getInstance():setIntegerForKey("mahjongType", self.mahjongType)
		self:setButtonIndex(self.mahjongType)
		--底分
		cc.UserDefault:getInstance():setIntegerForKey("cellScore"..self.mahjongType, self.cellScore)
		--局数
		cc.UserDefault:getInstance():setIntegerForKey("juShuType"..self.mahjongType, self.juShuType)
		--小玩法
		if self.mahjongType == 1 then
			cc.UserDefault:getInstance():setIntegerForKey("playType11", self.playType11)
			cc.UserDefault:getInstance():setIntegerForKey("playType12", self.playType12)
			cc.UserDefault:getInstance():setIntegerForKey("playType13", self.playType13)
			cc.UserDefault:getInstance():setIntegerForKey("renshu11", self.renshu11)
			cc.UserDefault:getInstance():setIntegerForKey("renshu12", self.renshu12)
			cc.UserDefault:getInstance():setIntegerForKey("renshu13", self.renshu13)
	        --动态开局
			cc.UserDefault:getInstance():setIntegerForKey("dynamicStart1", self.dynamicStart1)
		elseif self.mahjongType == 2 then
			cc.UserDefault:getInstance():setIntegerForKey("playType21", self.playType21)
			cc.UserDefault:getInstance():setIntegerForKey("playType22", self.playType22)
			cc.UserDefault:getInstance():setIntegerForKey("playType23", self.playType23)
			cc.UserDefault:getInstance():setIntegerForKey("playType24", self.playType24)
			cc.UserDefault:getInstance():setIntegerForKey("renshu21", self.renshu21)
			cc.UserDefault:getInstance():setIntegerForKey("renshu22", self.renshu22)
			cc.UserDefault:getInstance():setIntegerForKey("renshu23", self.renshu23)
	        --动态开局
			cc.UserDefault:getInstance():setIntegerForKey("dynamicStart2", self.dynamicStart2)
		elseif self.mahjongType == 3 then
			cc.UserDefault:getInstance():setIntegerForKey("playType31", self.playType31)
			cc.UserDefault:getInstance():setIntegerForKey("playType32", self.playType32)
			cc.UserDefault:getInstance():setIntegerForKey("playType33", self.playType33)
			cc.UserDefault:getInstance():setIntegerForKey("playType34", self.playType34)
			cc.UserDefault:getInstance():setIntegerForKey("playType35", self.playType35)
			cc.UserDefault:getInstance():setIntegerForKey("renshu31", self.renshu31)
			cc.UserDefault:getInstance():setIntegerForKey("renshu32", self.renshu32)
			cc.UserDefault:getInstance():setIntegerForKey("renshu33", self.renshu33)
	        --动态开局
			cc.UserDefault:getInstance():setIntegerForKey("dynamicStart3", self.dynamicStart3)
		elseif self.mahjongType == 4 then
			cc.UserDefault:getInstance():setIntegerForKey("playType41", self.playType41)
			cc.UserDefault:getInstance():setIntegerForKey("playType42", self.playType42)
			cc.UserDefault:getInstance():setIntegerForKey("playType43", self.playType43)
			cc.UserDefault:getInstance():setIntegerForKey("playType44", self.playType44)
			cc.UserDefault:getInstance():setIntegerForKey("playType45", self.playType45)
			cc.UserDefault:getInstance():setIntegerForKey("hupai41", self.hupai41)
			cc.UserDefault:getInstance():setIntegerForKey("hupai42", self.hupai42)
			cc.UserDefault:getInstance():setIntegerForKey("renshu41", self.renshu41)
			cc.UserDefault:getInstance():setIntegerForKey("renshu42", self.renshu42)
			cc.UserDefault:getInstance():setIntegerForKey("renshu43", self.renshu43)
	        --动态开局
			cc.UserDefault:getInstance():setIntegerForKey("dynamicStart4", self.dynamicStart4)
		elseif self.mahjongType == 5 then
			cc.UserDefault:getInstance():setIntegerForKey("playType51", self.playType51)
			cc.UserDefault:getInstance():setIntegerForKey("playType52", self.playType52)
			cc.UserDefault:getInstance():setIntegerForKey("playType53", self.playType53)
			cc.UserDefault:getInstance():setIntegerForKey("playType54", self.playType54)
			cc.UserDefault:getInstance():setIntegerForKey("haozi51", self.haozi51)
			cc.UserDefault:getInstance():setIntegerForKey("haozi52", self.haozi52)
			cc.UserDefault:getInstance():setIntegerForKey("haozi53", self.haozi53)
			cc.UserDefault:getInstance():setIntegerForKey("haozi54", self.haozi54)
			cc.UserDefault:getInstance():setIntegerForKey("renshu51", self.renshu51)
			cc.UserDefault:getInstance():setIntegerForKey("renshu52", self.renshu52)
			cc.UserDefault:getInstance():setIntegerForKey("renshu53", self.renshu53)
	        --动态开局
			cc.UserDefault:getInstance():setIntegerForKey("dynamicStart5", self.dynamicStart5)
		elseif self.mahjongType == 6 then
			cc.UserDefault:getInstance():setIntegerForKey("playType61", self.playType61)
			cc.UserDefault:getInstance():setIntegerForKey("playType62", self.playType62)
			cc.UserDefault:getInstance():setIntegerForKey("renshu61", self.renshu61)
			cc.UserDefault:getInstance():setIntegerForKey("renshu62", self.renshu62)
			cc.UserDefault:getInstance():setIntegerForKey("renshu63", self.renshu63)
	        --动态开局
			cc.UserDefault:getInstance():setIntegerForKey("dynamicStart6", self.dynamicStart6)
		elseif self.mahjongType == 7 then
			cc.UserDefault:getInstance():setIntegerForKey("playType71", self.playType71)
			cc.UserDefault:getInstance():setIntegerForKey("playType72", self.playType72)
			cc.UserDefault:getInstance():setIntegerForKey("playType73", self.playType73)
			cc.UserDefault:getInstance():setIntegerForKey("playType74", self.playType74)
		elseif self.mahjongType == 8 then
			cc.UserDefault:getInstance():setIntegerForKey("playType81", self.playType81)
			-- cc.UserDefault:getInstance():setIntegerForKey("renshu81", self.renshu81)
			-- cc.UserDefault:getInstance():setIntegerForKey("renshu82", self.renshu82)
			cc.UserDefault:getInstance():setIntegerForKey("renshu83", self.renshu83)
	        --动态开局
			cc.UserDefault:getInstance():setIntegerForKey("dynamicStart8", self.dynamicStart8)
		elseif self.mahjongType == 9 then
			cc.UserDefault:getInstance():setIntegerForKey("renshu93", self.renshu93)
	        --动态开局
			cc.UserDefault:getInstance():setIntegerForKey("dynamicStart9", self.dynamicStart9)
		elseif self.mahjongType == 10 then 
			cc.UserDefault:getInstance():setIntegerForKey("renshu103", self.renshu103)
	        --动态开局
			cc.UserDefault:getInstance():setIntegerForKey("dynamicStart10", self.dynamicStart10)
			cc.UserDefault:getInstance():setIntegerForKey("playType101", self.playType101)
	
		end
		--均摊
		cc.UserDefault:getInstance():setIntegerForKey("roomchargetype"..self.mahjongType, self.roomchargetype)
	    --VIP
		cc.UserDefault:getInstance():setIntegerForKey("m_vipcheat"..self.mahjongType, self.m_vipcheat)
		-- csw 12 -21
		cc.UserDefault:getInstance():setIntegerForKey("m_vipcheat1"..self.mahjongType, self.m_vipcheat1)

		gt.log("set_______________",self.play_types,self["wanfa2"..self.play_types])

		cc.UserDefault:getInstance():setBoolForKey("play_type",self._type)

		cc.UserDefault:getInstance():setIntegerForKey("play_types",self.play_types)
		cc.UserDefault:getInstance():setIntegerForKey("m_xiazhu"..self.play_types, self["xiazhu"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("m_jushu"..self.play_types, self["jushu"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("m_wanfa0"..self.play_types, self["wanfa"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("m_wanfa1"..self.play_types, self["wanfa1"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("m_wanfa2"..self.play_types, self["wanfa2"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("_renshu"..self.play_types, self["_renshu"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("m_wanfa3"..self.play_types, self["wanfa3"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("m_wanfa4"..self.play_types, self["wanfa4"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("m_wanfa5"..self.play_types, self["wanfa5"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("m_moshi"..self.play_types, self["moshi"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("m_beishu"..self.play_types, self["beishu"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("menpai"..self.play_types, self["menpai"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("vip0"..self.play_types, self["vip"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("vip1"..self.play_types, self["vip1"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("vip2"..self.play_types, self["vip2"..self.play_types])
		cc.UserDefault:getInstance():setIntegerForKey("__time"..self.play_types, self["__time"..self.play_types])
		

	end)

	-- 接收创建房间消息
	gt.socketClient:registerMsgListener(gt.GC_CREATE_ROOM, self, self.onRcvCreateRoom)

	--向左箭头
	local arrow1Btn = gt.seekNodeByName(self, "Btn_arrow1")
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
	local arrow2Btn = gt.seekNodeByName(self, "Btn_arrow2")
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

	-- 返回按键
	local backBtn = gt.seekNodeByName(self, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
		self:removeFromParent()
		if self.createSchedule then
		 			gt.scheduler:unscheduleScriptEntry(self.createSchedule)
		 			self.createSchedule = nil
		 		end
	end)

	--  底部背景条上描述文字
	local Spr_btmTips_text = gt.seekNodeByName(self, "Text_1")
	if gt.isIOSPlatform() and gt.isInReview then
		Spr_btmTips_text:setVisible(false)
	else
		Spr_btmTips_text:setVisible(true)
	end

	-- 显示机器人
	local Btn_PaiType = gt.seekNodeByName(self, "Node_PaiType")
	local Btn_Root = gt.seekNodeByName(self, "Node_Root")
	if Btn_PaiType then
		Btn_PaiType:setVisible( false )
	end
	if Btn_Root then
		Btn_Root:setVisible( false )
	end

	-- --选项简介
	-- local btnIntroduction = gt.seekNodeByName(self.csbNode, "Button_introduce")
	-- if btnIntroduction then
	-- 	gt.addBtnPressedListener(btnIntroduction, function()
	-- 		local rulesData = {}
	-- 		rulesData.m_state = self.mahjongType
	-- 		if self.mahjongType == 2 and self.shuangHaoZi == 1 then
	-- 			rulesData.m_state = 100012
	-- 		elseif self.mahjongType == 2 and self.zhuoHaoZi == 1 then 
	-- 			rulesData.m_state = 100002
	-- 		end
	-- 		rulesData.playTypes = self:getPlaytypesByMState(rulesData.m_state)
	-- 		local layer = require("app/views/GameIntroduction"):create(rulesData)
	--         self:addChild(layer, 1000)
	-- 	end)
	-- end


	-- local mahjongType = cc.UserDefault:getInstance():getIntegerForKey("mahjongType", 1)
	-- if mahjongType == 2 or mahjongType == 3 then
	-- 	mahjongType = 1
	-- end
	-- self:changeMahjongType(mahjongType)

	-- self:refreshCheckOutline()
end

--初始化成员变量
function CreateRoom:_initParams()


	self.cellScore = 1				    --默认底分
	self.juShuType = 1				    --默认局数
	self.playType = {}					--默认玩法

	--做推倒胡新增小选项编号
	self.playType41 = 1 --报听
	self.playType42 = 1 --带风
	self.playType43 = 0 --只可自摸胡
	self.playType44 = 0 --红中癞子
	self.playType45 = 1 --暗杠可见
	--胡牌
	self.hupai41 = 1 --大胡
	self.hupai42 = 0 --小胡
	--人数
	self.renshu41 = 0 --2人
	self.renshu42 = 0 --3人
	self.renshu43 = 1 --4人
	self.dynamicStart4 = 0 -- 动态加入

	--做扣点点新增小选项编号
	self.playType51 = 1 --过胡只可自摸
	self.playType52 = 1 --暗杠可见
	self.playType53 = 0 --一条龙加番
	self.playType54 = 0 --清一色加番
	--耗子
	self.haozi51 = 1 --无耗子
	self.haozi52 = 0 --风耗子
	self.haozi53 = 0 --随机耗子
	self.haozi54 = 0 --双耗子
	--人数
	self.renshu51 = 0 --2人
	self.renshu52 = 0 --3人
	self.renshu53 = 1 --4人
	self.dynamicStart5 = 0 -- 动态加入

	--做硬三嘴新增小选项编号
	self.playType11 = 1 --庄加加2分
	self.playType12 = 1 --暗杠可见
	self.playType13 = 0 --荒庄轮庄
	--人数
	self.renshu11 = 0 --2人
	self.renshu12 = 0 --3人
	self.renshu13 = 1 --4人
	self.dynamicStart1 = 0 -- 动态加入

	--做一门牌新增小选项编号
	self.playType21 = 1 --庄加加1分
	self.playType22 = 1 --暗杠可见
	self.playType23 = 0 --数页
	self.playType24 = 1 --荒庄轮庄
	--人数
	self.renshu21 = 0 --2人
	self.renshu22 = 0 --3人
	self.renshu23 = 1 --4人
	self.dynamicStart2 = 0 -- 动态加入

	--做洪洞王牌新增小选项编号
	self.playType31 = 0 --免碰
	self.playType32 = 0 --色牌
	self.playType33 = 1 --暗杠可见
	self.playType34 = 0 --荒庄不荒杠
	self.playType35 = 0 --色牌
	--人数
	self.renshu31 = 0 --2人
	self.renshu32 = 0 --3人
	self.renshu33 = 1 --4人
	self.dynamicStart3 = 0 -- 动态加入

	--做晋中新增小选项编号
	self.playType61 = 1 --过胡只可自摸
	self.playType62 = 1 --暗杠可见
	--人数
	self.renshu61 = 0 --2人
	self.renshu62 = 0 --3人
	self.renshu63 = 1 --4人
	self.dynamicStart6 = 0 -- 动态加入

	--做拐三角新增小选项编号
	self.playType71 = 1 --带风
	self.playType72 = 0 --硬八张
	self.playType73 = 0 --高分(平胡5分）
	self.playType74 = 1 --暗杠可见

    --做忻州扣点点新增小选项编号
	self.playType81 = 1 --缺一门
	--人数
	-- self.renshu81 = 0 --2人
	-- self.renshu82 = 0 --3人
	self.renshu83 = 1 --4人
	self.dynamicStart8 = 0 -- 动态加入

    --做临汾撵中子新增小选项编号
	self.renshu93 = 1 --4人
	self.dynamicStart9 = 0 -- 动态加入

	self.roomchargetype = 0			    --默认均摊
	
	self.m_vipcheat = 0				    --防作弊

	self.mahjongType = 4  				--默认大玩法为推倒胡

	self.mahjongTypeCount = 10 		    --大玩法数量
	self.mahjongTypeCountPoker = 1 		    --大玩法数量

	self.mahjongTypeBtns = {}  			--大玩法按钮集合
	self.imgLimitFreeIcons = {}			--限时免费图标集合
	self.checkNodeCount = 31 			--全部小选项数量
	self.checkNodes = {} 				--选项框节点集合
	self.checkBoxs = {}					
	self.checkLabels = {}				--选项框文本
	self.checkNodeOriginPos = {}
	self.playerNum = 4 					--玩家人数

	self.mahjongTypeTable = { 4, 5, 10, 9, 8, 1, 2, 3, 6, 7}

	-- 这里的标签跟 cocos studio中的UI一一对应
	-- 报听 ＝ 3
	-- 带风 ＝4
	-- 只可自摸 ＝5
	-- 清一色加番 ＝ 6
	-- 一条龙加番 ＝7
	-- 捉耗子 ＝ 8
	-- 过胡可自摸 ＝9
	-- 抢杠胡 ＝ 10
	-- 荒庄不荒杠 ＝ 12
	-- 未上听杠不算分 ＝13
	-- 一炮多响 ＝14
	-- 15 	   七小对
	-- 16      风一色
	-- 17 	   清一色
	-- 18      凑一色
	-- 19      大胡
	-- 20      平胡
	-- 21      听牌可杠
	-- 22      只有胡牌玩家杠算分
	-- 11-- 暗杠可见
	 ----- 做贴金新增小选项
	-- 23  十三幺
	-- 24  一条龙
	-- 25 4金
	-- 26  8金
	-- 27 上金少者只可自摸
	-- 28 推倒胡补充小选项：边卡吊 
	-- 29 双耗子

	-- self.tuidaohuOptions = {3,4,5,10,14,12,9,11}    		    --推倒胡小选项
	-- self.kouDianOptions = {7,6,15,10,12,13,14,9,11,31}   	  	--扣点点无耗子小选项
	-- self.kouDianDanOptions = {10,12,14,9,13,11,31}   			--扣点点单耗子小选项
	-- self.liSiOptions = {10,11}     			  				--立四
	-- self.jinZhongOptions = {16,17,18,15,21,22,12,9,11}			--晋中
	-- self.tieJinOptions = {15,17,23,27,24,11}     		--贴金
	-- self.guaiSanJiaoOptions = {15,14,11}     				    --拐三角
	-- self.yingSanZuiOptions = {30}  				    --硬三嘴
end

--初始化UI
function CreateRoom:_initUI()
	self.csbNode = cc.CSLoader:createNode("CreateRoomNew.csb")
	self.csbNode:setAnchorPoint(0.5,0.5)
	self.csbNode:setPosition(gt.winCenter)
	self:addChild(self.csbNode)
	self.ZOrder = 5


	 gt.seekNodeByName(self.csbNode, "Text_3V"):setString( gt.v or "")

	if gt.isAppStoreInReview then
		local bokehImg = gt.seekNodeByName(self.csbNode, "Img_bokeh")
		if bokehImg then
			bokehImg:setVisible(false)
		end
	end

    for i = 1, self.mahjongTypeCount do
	    self["m_nodeContent"..i] = gt.seekNodeByName(self.csbNode, "m_nodeContent"..i)
	end

	gt.log("___________")
	for i = 1 , self.mahjongTypeCountPoker do
		 self["m_nodeContents"..i] = gt.seekNodeByName(self.csbNode, "m_nodeContents"..i)
	end

	--self:requestLimitFree()

    --返回按钮
    local backBtn = gt.seekNodeByName(self.csbNode, "Btn_back")
	gt.addBtnPressedListener(backBtn,function ()
    	self:removeFromParent()
	end)

    --关闭按钮
    local btn = gt.seekNodeByName(self.csbNode, "m_btnClose")
	gt.addBtnPressedListener(btn,function ()
    	-- if self.callback then
    	-- 	self.callback()
    	-- end
    	self:removeFromParent()
	end)

	self.pageListView 	= gt.seekNodeByName(self.csbNode, "PageView_List")
	self.pageNode 		= gt.seekNodeByName(self.csbNode, "Node_page")
	-- self.m_nodeContent5:getChildByName("m_renshu"):setVisible(true)
	-- self.m_nodeContent5:getChildByName("m_avarage"):setPositionY(219)

end

--添加底分
function CreateRoom:_addCellScore()
	local text = self.curM_nodeContent:getChildByName("play_difen"):getChildByName("Image"):getChildByName("Text")
	text:setString(self.cellScore)

	local Button_1 = self.curM_nodeContent:getChildByName("play_difen"):getChildByName("Image"):getChildByName("Button_1")
	gt.addBtnPressedListener(Button_1,function ()
		self.cellScore = self.cellScore - 1 < 1 and 1 or self.cellScore - 1
		text:setString(self.cellScore)
	end)

	local Button_2 = self.curM_nodeContent:getChildByName("play_difen"):getChildByName("Image"):getChildByName("Button_2")
	gt.addBtnPressedListener(Button_2,function ()
		self.cellScore = self.cellScore + 1 > 5 and 5 or self.cellScore + 1
		text:setString(self.cellScore)
	end)
end








--初始化默认设置
function CreateRoom:_initParameter(mahjongType)
	--读取设置
	--大玩法
	if mahjongType == nil then
		self.mahjongType = cc.UserDefault:getInstance():getIntegerForKey("mahjongType", 4)

		gt.log("nummm............",self.mahjongType)

		self:getButtonIndex()


			
		self.m_vipcheat1 = cc.UserDefault:getInstance():getIntegerForKey("m_vipcheat1"..self.mahjongType, 0)
		self._type = cc.UserDefault:getInstance():getBoolForKey("play_type", false)
		self._type = true


		self.play_types = cc.UserDefault:getInstance():getIntegerForKey("play_types", 0)


		for i = 0 , 1 do 

				self["xiazhu"..i] = cc.UserDefault:getInstance():getIntegerForKey("m_xiazhu"..i,1)
				self["jushu"..i]=	cc.UserDefault:getInstance():getIntegerForKey("m_jushu"..i,1)
				self["wanfa"..i]=	cc.UserDefault:getInstance():getIntegerForKey("m_wanfa0"..i,1)
				self["wanfa1"..i]=	cc.UserDefault:getInstance():getIntegerForKey("m_wanfa1"..i,1)
				self["wanfa2"..i]=	cc.UserDefault:getInstance():getIntegerForKey("m_wanfa2"..i,0)
				self["_renshu"..i]= cc.UserDefault:getInstance():getIntegerForKey("_renshu"..i,1)
				self["wanfa3"..i]=	cc.UserDefault:getInstance():getIntegerForKey("m_wanfa3"..i,0)
				self["wanfa4"..i]=	cc.UserDefault:getInstance():getIntegerForKey("m_wanfa4"..i,0)
				self["wanfa5"..i]=	cc.UserDefault:getInstance():getIntegerForKey("m_wanfa5"..i,0)
				self["moshi"..i]=	cc.UserDefault:getInstance():getIntegerForKey("m_moshi"..i,1)
				self["beishu"..i]=	cc.UserDefault:getInstance():getIntegerForKey("m_beishu"..i,1)
				self["menpai"..i]=	cc.UserDefault:getInstance():getIntegerForKey("menpai"..i,1)
				self["vip"..i]=	cc.UserDefault:getInstance():getIntegerForKey("vip0"..i,0)
				self["vip1"..i]=	cc.UserDefault:getInstance():getIntegerForKey("vip1"..i,1)
				self["vip2"..i]=	cc.UserDefault:getInstance():getIntegerForKey("vip2"..i,1)
				self["__time"..i] = cc.UserDefault:getInstance():getIntegerForKey("__time"..i, 3)

			gt.log("self.vip2__________________________",i , self["wanfa2"..i])
		end

	else
		self.mahjongType = mahjongType
	end
	--底分
	self.cellScore = cc.UserDefault:getInstance():getIntegerForKey("cellScore"..self.mahjongType, 1)
	--局数
	self.juShuType = cc.UserDefault:getInstance():getIntegerForKey("juShuType"..self.mahjongType, 1)

	--小玩法
	if self.mahjongType == 1 then
		self.playType11 = 1
		self.playType12 = 1
		self.playType13 = 1
		self.renshu11 = 1
		self.renshu12 = 1
		self.renshu13 = 1
		self.dynamicStart1 = 1
	elseif self.mahjongType == 2 then
		self.playType21 = 1
		self.playType22 = 1
		self.playType23 = 1
		self.playType24 = 1
		self.renshu21 =   1
		self.renshu22 =   1
		self.renshu23 =   1
		self.dynamicStart2 = 1
	elseif self.mahjongType == 3 then
		self.playType31 = 1
		self.playType32 = 1
		self.playType33 = 1
		self.playType34 = 1
		self.playType35 = 1
		self.renshu31 =   1
		self.renshu32 =   1
		self.renshu33 =   1
		self.dynamicStart3 = 1
	elseif self.mahjongType == 4 then
		self.playType41 = 1
		self.playType42 = 1
		self.playType43 = 1
		self.playType44 = 1
		self.playType45 = 1
		self.hupai41 =    1
		self.hupai42 =    1
		self.renshu41 =   1
		self.renshu42 =   1
		self.renshu43 =   1
		self.dynamicStart4 = 1
	elseif self.mahjongType == 5 then
		self.playType51 = 1
		self.playType52 = 1
		self.playType53 = 1
		self.playType54 = 1
		self.haozi51 =    1
		self.haozi52 =    1
		self.haozi53 =    1
		self.haozi54 =    1
		self.renshu51 = 1
		self.renshu52 = 1
		self.renshu53 = 1
		self.dynamicStart5 = 1
	elseif self.mahjongType == 6 then
		self.playType61 =1
		self.playType62 =1
		self.renshu61 =  1
		self.renshu62 =  1
		self.renshu63 =  1
		self.dynamicStart6 = 1
	elseif self.mahjongType == 7 then
		self.playType71 =1
		self.playType72 =1
		self.playType73 =1
		self.playType74 =1
		self.playType73 =1
	elseif self.mahjongType == 8 then
		self.playType81 = 1
		-- self.renshu81 = cc.UserDefault:getInstance():getIntegerForKey("renshu81", 0)
		-- self.renshu82 = cc.UserDefault:getInstance():getIntegerForKey("renshu82", 0)
		self.renshu83 = 1
		self.dynamicStart8 = 1
	elseif self.mahjongType == 9 then
		self.renshu93 = 1
		self.dynamicStart9 = 1
	elseif self.mahjongType == 10 then
		self.playType101 = 1
		self.renshu103 = 1
		self.dynamicStart10 = 1
	end
	--均摊
	self.roomchargetype =1
    --VIP
	self.m_vipcheat = 1

end

--添加房间标题窗口
function CreateRoom:_addTitle()


end

function CreateRoom:setMahjongTypeBtn()

end



function CreateRoom:updatePageNode(currentPageIdx)
	if self.pageDots == nil then
		self.pageDots = {}
		local totalWidth = (self.maxNum - 1) * 103
		local firstPosX = -totalWidth*0.34
		for i=1, self.maxNum do
			local pDot = cc.Sprite:createWithSpriteFrameName("dt_create_dotbg.png")
			table.insert(self.pageDots, pDot)
			pDot:setScale(1.2)
			pDot:setAnchorPoint(cc.p(0.5,0.5))
			firstPosX = firstPosX + 35
			pDot:setPosition(cc.p(firstPosX,0))
			self.pageNode:addChild(pDot)
			local dotChoosedImg = cc.Sprite:createWithSpriteFrameName("dt_create_dot.png")
			pDot:addChild(dotChoosedImg)
			dotChoosedImg:setPosition(cc.p(10,10))
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




function CreateRoom:_changePlayType(mahjongType)
	gt.log("aaaaaaaaaaaaaaa,",mahjongType)
	if mahjongType > 0 then
		self.m_nodeContent1:setVisible(mahjongType == 1)
		self.m_nodeContent2:setVisible(mahjongType == 2)
		self.m_nodeContent3:setVisible(mahjongType == 3)
		self.m_nodeContent4:setVisible(mahjongType == 4)
		self.m_nodeContent5:setVisible(mahjongType == 5)
		self.m_nodeContent6:setVisible(mahjongType == 6)
		self.m_nodeContent7:setVisible(mahjongType == 7)
		self.m_nodeContent8:setVisible(mahjongType == 8)
		self.m_nodeContent9:setVisible(mahjongType == 9)
		self.m_nodeContent10:setVisible(mahjongType == 10)

		self.curM_nodeContent = self["m_nodeContent"..mahjongType]

			gt.log("-------------------------mahjongType", mahjongType)
		if mahjongType ~= 7 then
			local explainBtn = self.curM_nodeContent:getChildByName("m_renshu"):getChildByName("dynamicStart"):getChildByName("Btn_explain")

			gt.addBtnPressedListener(explainBtn, function()
				local DynamicStartExplainFrame = require("client/game/majiang/DynamicStartExplainFrame"):create()
				DynamicStartExplainFrame:setPosition(cc.p(-DynamicStartExplainFrame:getContentSize().width, -DynamicStartExplainFrame:getContentSize().height))
				explainBtn:addChild(DynamicStartExplainFrame, 999)
			end)
		end
	end
end



-- start --
--------------------------------
-- @class function
-- @description 创建房间消息
-- @param msgTbl 消息体
-- end --
function CreateRoom:onRcvCreateRoom(msgTbl)
	gt.log("创建房间消息 ============== ")
	gt.dump(msgTbl)
	gt.dumploglogin("创建房间消息")
	if self.createSchedule then
		gt.scheduler:unscheduleScriptEntry(self.createSchedule)
		self.createSchedule = nil
	end
	
	if msgTbl.kErrorCode ~= 0 then
		-- 创建失败
		gt.removeLoadingTips()

		-- 房卡不足提示
		-- require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
			-- gt.getLocationString("LTKey_0046", gt.roomCardBuyInfo), nil, nil, true)
		gt.log("房卡不足")
		if msgTbl.kErrorCode == 1 then
			Toast.showToast(self, "房卡不足，请在商城购买", 2)
			if gt.isShoppingShow then
				--local shoppingPopup = require("app/views/ShoppingLayer"):create()
				--self:addChild(shoppingPopup, self.ZOrder)
			else
				--require("client/game/dialog/NoticeTipsForFangKa"):create("房卡不足", gt.roomCardBuyInfo, nil, nil, true)
				require("client/game/dialog/NoticeTipsCommon"):create(2, "房卡不足，请在商城购买")
			end
		elseif msgTbl.kErrorCode == 8 then
			Toast.showToast(self, "房主建房数量超限，解散后重试", 2)
		elseif msgTbl.kErrorCode == 9 then
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "获取GPS信息失败！", nil, nil, true)
		else
			require("client/game/dialog/NoticeTipsCommon"):create(2, "创建房间失败")
		end
	else
		if self.deskType then
			-- --房主建房
			-- gt.removeLoadingTips()
			-- self.parent:sendFZRecordMsg()
			-- self:removeFromParent()
		else
			gt.CreateRoomFlag = true
		end
	end
end

function CreateRoom:setLimitFree(data)
	for i = 1, self.mahjongTypeCount do 
		local limitfreeiconImg = self.imgLimitFreeIcons[self.mahjongTypeTable[i]]
		if limitfreeiconImg then
			limitfreeiconImg:setVisible(false)
		end
		local limitfreetextImg = gt.seekNodeByName(self.csbNode, "Img_limitfreetext" .. i)
		if limitfreetextImg then
			limitfreetextImg:setVisible(false)
		end
	end

	-- local playTypeTable = string.split(data.play_type, ",")
	local mahjongTypeBtnPlayTypes = {"100008", "100010", "100018", "100017", "100016", "100009", "100001", "100002", "100005", "100006"}

	gt.log("-------------------------data.play_type")
	if data.play_type then
		for i = 1, self.mahjongTypeCount do
			for j = 1, #data.play_type do
				if tonumber(mahjongTypeBtnPlayTypes[i]) == tonumber(data.play_type[j]) then
					local index = 1
					for z = 1, #self.mahjongTypeTable do
						if i == self.mahjongTypeTable[z] then
							index = z
							break
						end
					end
					gt.log("-------------i", i)
					gt.log("-------------index", index)
					gt.log("-------------self.mahjongTypeTable[i]", self.mahjongTypeTable[i])
					local limitfreeiconImg = self.imgLimitFreeIcons[index]
					if limitfreeiconImg then
						limitfreeiconImg:setVisible(true)
					end
					local limitfreetextImg = gt.seekNodeByName(self.csbNode, "Img_limitfreetext" .. i)
					if limitfreetextImg then
						limitfreetextImg:setVisible(true)
						if data.start_time and data.end_time then
							limitfreetextImg:setString("*"..data.start_time.."到"..data.end_time.."免费玩")
						end
					end
				end
			end
		end
	end
end

function CreateRoom:requestLimitFree()
	--gt.log(debug.traceback())
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = gt.getUrlEncryCode(gt.limitFree, gt.playerData.uid)
    xhr:open("GET", url)
    gt.log(url)
    local function onResp()
        local runningScene = display.getRunningScene()
        if runningScene and runningScene.name == "MainScene" and runningScene:getChildByName("CreateRoom") then
            gt.dump(xhr.readyState)
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                local response = xhr.response
                local respJson = require("cjson").decode(response)
                gt.dump(respJson)
                if respJson.errno == 0 then
                	self:setLimitFree(respJson.data)
                else
                    Toast.showToast(self, respJson.errmsg, 2)
                end
            elseif xhr.readyState == 1 and xhr.status == 0 then
                -- 本地网络连接断开
                require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
            end  
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onResp)
    xhr:send()
end

function CreateRoom:setButtonIndex(mahjongType)
	for i = 1, #self.mahjongTypeTable do
		if self.mahjongTypeTable[i] == mahjongType then
			table.remove(self.mahjongTypeTable, i)
			break
		end
	end

	table.insert(self.mahjongTypeTable, 1, mahjongType)

	cc.UserDefault:getInstance():setStringForKey("mahjongTypeTable", require("cjson").encode(self.mahjongTypeTable))
end

function CreateRoom:getButtonIndex(mahjongType)
	local data = cc.UserDefault:getInstance():getStringForKey("mahjongTypeTable", require("cjson").encode(self.mahjongTypeTable))
	 
	local mahjongTypeTable = json.decode(data)
	if self.mahjongTypeTable and mahjongTypeTable then
		if #self.mahjongTypeTable == #mahjongTypeTable then
			self.mahjongTypeTable = mahjongTypeTable
		else
			local newPlayTypeTable = {}
			for i = 1, #self.mahjongTypeTable do
				local newPlayTypeFlag = true
				for j = 1, #mahjongTypeTable do
					if self.mahjongTypeTable[i] == mahjongTypeTable[j] then
						newPlayTypeFlag = false
						break
					end
				end
				if newPlayTypeFlag == true then
					table.insert(newPlayTypeTable, self.mahjongTypeTable[i])
				end
			end
			for i = 1, #newPlayTypeTable do
				if newPlayTypeTable[i] == 10 then
					table.insert(mahjongTypeTable, 3, newPlayTypeTable[i])
				else
					table.insert(mahjongTypeTable, newPlayTypeTable[i])
				end
			end
			if #self.mahjongTypeTable == #mahjongTypeTable then
				self.mahjongTypeTable = mahjongTypeTable
			end
		end
	end
end



return CreateRoom