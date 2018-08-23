local gt = cc.exports.gt

local CreateRoomWuren = class("CreateRoomWuren", function()
	return gt.createMaskLayer()
end)

function CreateRoomWuren:ctor()
	--初始化成员变量
	
	--初始化UI
	self:_initUI()
    
    -- 确定按键
	local Btn_queding = gt.seekNodeByName(self, "Btn_queding")
	gt.addBtnPressedListener(Btn_queding, function()
        gt.showLoadingTips("房间创建中...")
        local msgToSend = {}
		msgToSend.kMId = gt.CG_CREATE_ROOM
		msgToSend.kSecret = "123456"
		msgToSend.kGold = 1
        
		msgToSend.kState = 110
		msgToSend.kRobotNum = 0

	    msgToSend.kPlayType = {}
        -- 局数 --8局  12局  20局
        if(gt.seekNodeByName(self, "CheckBox_3ju"):isSelected()) then
		    msgToSend.kFlag = 1
        end
        if(gt.seekNodeByName(self, "CheckBox_6ju"):isSelected()) then
		    msgToSend.kFlag = 2
        end
        if(gt.seekNodeByName(self, "CheckBox_9ju"):isSelected()) then
		    msgToSend.kFlag = 3
        end
        cc.UserDefault:getInstance():setIntegerForKey("wr_jushu", msgToSend.kFlag )
        -- -- 底分  没有底分了，默认传1
        if(gt.seekNodeByName(self, "CheckBox_1fen"):isSelected()) then
		    table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("sde_play2", 1 )
        elseif(gt.seekNodeByName(self, "CheckBox_2fen"):isSelected()) then
		    table.insert(msgToSend.kPlayType, 2)
            cc.UserDefault:getInstance():setIntegerForKey("sde_play2", 2 )
        elseif(gt.seekNodeByName(self, "CheckBox_3fen"):isSelected()) then
            cc.UserDefault:getInstance():setIntegerForKey("sde_play2", 3 )
		    table.insert(msgToSend.kPlayType, 3)
        end
        
        --玩法
        --2是常主
        if(gt.seekNodeByName(self, "CheckBox_changzhu"):isSelected()) then
		    table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("wr_erzhu",1)
        else
            table.insert(msgToSend.kPlayType, 0)
            cc.UserDefault:getInstance():setIntegerForKey("wr_erzhu",0)
        end

        --相邻外置禁止加入
        if(gt.seekNodeByName(self, "CheckBox_weizhi"):isSelected()) then
            msgToSend.kGpsLimit = 1
            cc.UserDefault:getInstance():setIntegerForKey("wr_weizhi",1)
        else
            msgToSend.kGpsLimit = 0
            cc.UserDefault:getInstance():setIntegerForKey("wr_weizhi",0)
        end
        table.insert(msgToSend.kPlayType, 0) --暂时不用，空着

        --对家要牌含10
        if(gt.seekNodeByName(self, "CheckBox_hanshi"):isSelected()) then
            table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("wr_hanshi",1)
        else
            table.insert(msgToSend.kPlayType, 0)
            cc.UserDefault:getInstance():setIntegerForKey("wr_hanshi",0)
        end

        -- 防作弊
        if(gt.seekNodeByName(self, "CheckBox_fangzuobi"):isSelected()) then
            table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("wr_fangzuobi",1)
        else
            table.insert(msgToSend.kPlayType, 0)
            cc.UserDefault:getInstance():setIntegerForKey("wr_fangzuobi",0)
        end

        --闲家干扣底
        if(gt.seekNodeByName(self, "CheckBox_gankoudi"):isSelected()) then
            table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("wr_gankoudi",1)
        else
            table.insert(msgToSend.kPlayType, 0)
            cc.UserDefault:getInstance():setIntegerForKey("wr_gankoudi",0)
        end
        
        --庄家交牌 投降的意思
        if(gt.seekNodeByName(self, "CheckBox_jiaopai_0"):isSelected()) then
		    table.insert(msgToSend.kPlayType, 0)
            cc.UserDefault:getInstance():setIntegerForKey("wr_jiaopai", 0 )
        elseif(gt.seekNodeByName(self, "CheckBox_jiaopai_8"):isSelected()) then
		    table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("wr_jiaopai", 1 )
        elseif(gt.seekNodeByName(self, "CheckBox_jiaopai_12"):isSelected()) then
            table.insert(msgToSend.kPlayType, 2)
            cc.UserDefault:getInstance():setIntegerForKey("wr_jiaopai",  2)
        end

        --任意叫分都可选主花牌为副庄
        if(gt.seekNodeByName(self, "CheckBox_renyifen"):isSelected()) then
            table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("wr_renyifen",1)
        else
            table.insert(msgToSend.kPlayType, 0)
            cc.UserDefault:getInstance():setIntegerForKey("wr_renyifen",0)
        end

        --高级
         -- 观战
        if(gt.seekNodeByName(self, "CheckBox_guanzhan"):isSelected()) then
            msgToSend.kAllowLookOn = 1
            cc.UserDefault:getInstance():setIntegerForKey("wr_guanzhan",1)
        else
            msgToSend.kAllowLookOn = 0
            cc.UserDefault:getInstance():setIntegerForKey("wr_guanzhan",0)
        end

        msgToSend.kFeeType = gt.seekNodeByName(self, "CheckBox_fufei1"):isSelected() and 1 or 0  --1 玩家均摊 0 房主付费
        cc.UserDefault:getInstance():setIntegerForKey("wr_zhifu1",msgToSend.kFeeType)

        if msgToSend.kGpsLimit == 1 then 
                local kGpsLng = "0"
                local kGpsLat = "0"

                local data = ""
                local time = 0
                if self._time then  gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
                self._time = gt.scheduler:scheduleScriptFunc(function(dt)

                    data = Utils.getLocationInfo()

                    if (data.longitude and data.latitue and data.longitude ~= "" and data.latitue ~= "" and gt.isAndroidPlatform()) or (data.longitude and data.longitude ~= 0 and data.latitue and data.latitue ~= 0 and gt.isIOSPlatform()) then
                        gt.removeLoadingTips()
                        if self._time then gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
                        kGpsLng = data.longitude
                        kGpsLat = data.latitue

                        msgToSend.kGpsLng = tostring(kGpsLng)
                        msgToSend.kGpsLat = tostring(kGpsLat)

                        gt.dump(msgToSend)
                        gt.socketClient:sendMessage(msgToSend)
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
                        if self._time then  gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
                        gt.removeLoadingTips()
                        local str_des = "获取GPS失败，您创建的是【相邻位置禁止进入】的房间，必须开启GPS位置才能进入!"
                        require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
                        str_des, nil, nil, true)
                        
                    end
                end,0,false)
        else
            dump(msgToSend)
            msgToSend.kGpsLng = tostring(0)
            msgToSend.kGpsLat = tostring(0)
             gt.showLoadingTips("房间创建中...")
            gt.log("CreateRoomWuren创建房间 ======== ")
            gt.socketClient:sendMessage(msgToSend)
        end 
	end)

	-- 返回按键
	local backBtn = gt.seekNodeByName(self, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
        gt.dispatchEvent("show_text")
		self:removeFromParent()
	end)

	local sanJuCheckBox = gt.seekNodeByName(self, "CheckBox_3ju")
	local liuJuCheckBox = gt.seekNodeByName(self, "CheckBox_6ju")
    local jiuJuCheckBox = gt.seekNodeByName(self, "CheckBox_9ju")
    
    local yifenCheckBox = gt.seekNodeByName(self, "CheckBox_1fen")
	local erfenCheckBox = gt.seekNodeByName(self, "CheckBox_2fen")
	local sanfenCheckBox = gt.seekNodeByName(self, "CheckBox_3fen")

	local jiaopai_0 = gt.seekNodeByName(self, "CheckBox_jiaopai_0")
	local jiaopai_8 = gt.seekNodeByName(self, "CheckBox_jiaopai_8")
	local jiaopai_12 = gt.seekNodeByName(self, "CheckBox_jiaopai_12")

	local changzhuCheckBox = gt.seekNodeByName(self, "CheckBox_changzhu")
	local weizhiCheckBox = gt.seekNodeByName(self, "CheckBox_weizhi")
    local hanshiCheckBox = gt.seekNodeByName(self, "CheckBox_hanshi")
    
    local renyifem = gt.seekNodeByName(self, "CheckBox_renyifen")
    local fangzuobi = gt.seekNodeByName(self, "CheckBox_fangzuobi")
    local gankou = gt.seekNodeByName(self, "CheckBox_gankoudi")
    local gauzhan = gt.seekNodeByName(self, "CheckBox_guanzhan")

    sanJuCheckBox:setSelected(true)
    liuJuCheckBox:setSelected(false)
    jiuJuCheckBox:setSelected(false)

    yifenCheckBox:setSelected(true)
    erfenCheckBox:setSelected(false)
    sanfenCheckBox:setSelected(false)
    
    jiaopai_0:setSelected(false)
    jiaopai_8:setSelected(true)
    jiaopai_12:setSelected(false)
    
    changzhuCheckBox:setSelected(false)
    weizhiCheckBox:setSelected(false)
    hanshiCheckBox:setSelected(false)
    renyifem:setSelected(false)
    fangzuobi:setSelected(true)
    gankou:setSelected(false)
    gauzhan:setSelected(true)
    
    gt.seekNodeByName(self, "CheckBox_renyifen"):isSelected()

    local function _selectEvent(sender, eventType)
        if(eventType == ccui.CheckBoxEventType.selected) then
            if(sender:getName() == "CheckBox_3ju") then
                gt.seekNodeByName(self, "CheckBox_6ju"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_9ju"):setSelected(false)

            elseif(sender:getName() == "CheckBox_6ju") then
                gt.seekNodeByName(self, "CheckBox_3ju"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_9ju"):setSelected(false)

            elseif(sender:getName() == "CheckBox_9ju") then
                gt.seekNodeByName(self, "CheckBox_3ju"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_6ju"):setSelected(false)

            elseif(sender:getName() == "CheckBox_1fen") then
                gt.seekNodeByName(self, "CheckBox_2fen"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_3fen"):setSelected(false)

            elseif(sender:getName() == "CheckBox_2fen") then
                gt.seekNodeByName(self, "CheckBox_1fen"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_3fen"):setSelected(false)

            elseif(sender:getName() == "CheckBox_3fen") then
                gt.seekNodeByName(self, "CheckBox_1fen"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_2fen"):setSelected(false)

            elseif(sender:getName() == "CheckBox_jiaopai_0") then --交牌分数
                gt.seekNodeByName(self, "CheckBox_jiaopai_8"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_jiaopai_12"):setSelected(false)
            elseif(sender:getName() == "CheckBox_jiaopai_8") then
                gt.seekNodeByName(self, "CheckBox_jiaopai_0"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_jiaopai_12"):setSelected(false)
            elseif(sender:getName() == "CheckBox_jiaopai_12") then
                gt.seekNodeByName(self, "CheckBox_jiaopai_0"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_jiaopai_8"):setSelected(false)

            elseif (sender:getName() == "CheckBox_fufei0") then
                gt.seekNodeByName(self, "CheckBox_fufei0"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_fufei1"):setSelected(false)

                gt.seekNodeByName(self, "Text_3ju"):setString("8局(4金币)")
                gt.seekNodeByName(self, "Text_6ju"):setString("12局(6金币)")
                gt.seekNodeByName(self, "Text_9ju"):setString("20局(8金币)")

            elseif (sender:getName() == "CheckBox_fufei1") then
                gt.seekNodeByName(self, "CheckBox_fufei0"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_fufei1"):setSelected(true)

                gt.seekNodeByName(self, "Text_3ju"):setString("8局(1金币)")
                gt.seekNodeByName(self, "Text_6ju"):setString("12局(2金币)")
                gt.seekNodeByName(self, "Text_9ju"):setString("20局(3金币)")
            end
        elseif(eventType == ccui.CheckBoxEventType.unselected) then
            if(sender:getName() == "CheckBox_3ju") then
                gt.seekNodeByName(self, "CheckBox_3ju"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_6ju"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_9ju"):setSelected(false)

            elseif(sender:getName() == "CheckBox_6ju") then
                gt.seekNodeByName(self, "CheckBox_6ju"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_3ju"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_9ju"):setSelected(false)

            elseif(sender:getName() == "CheckBox_9ju") then
                gt.seekNodeByName(self, "CheckBox_9ju"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_3ju"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_6ju"):setSelected(false)

            elseif(sender:getName() == "CheckBox_1fen") then
                gt.seekNodeByName(self, "CheckBox_1fen"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_2fen"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_3fen"):setSelected(false)

            elseif(sender:getName() == "CheckBox_2fen") then
                gt.seekNodeByName(self, "CheckBox_2fen"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_1fen"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_3fen"):setSelected(false)

            elseif(sender:getName() == "CheckBox_3fen") then
                gt.seekNodeByName(self, "CheckBox_3fen"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_1fen"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_2fen"):setSelected(false)

            elseif(sender:getName() == "CheckBox_jiaopai_0") then --交牌分数
                gt.seekNodeByName(self, "CheckBox_jiaopai_0"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_jiaopai_8"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_jiaopai_12"):setSelected(false)
            elseif(sender:getName() == "CheckBox_jiaopai_8") then
                gt.seekNodeByName(self, "CheckBox_jiaopai_8"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_jiaopai_0"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_jiaopai_12"):setSelected(false)
            elseif(sender:getName() == "CheckBox_jiaopai_12") then
                gt.seekNodeByName(self, "CheckBox_jiaopai_12"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_jiaopai_0"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_jiaopai_8"):setSelected(false)

            elseif (sender:getName() == "CheckBox_fufei0") then
                gt.seekNodeByName(self, "CheckBox_fufei0"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_fufei1"):setSelected(false)

                gt.seekNodeByName(self, "Text_3ju"):setString("8局(4金币)")
                gt.seekNodeByName(self, "Text_6ju"):setString("12局(6金币)")
                gt.seekNodeByName(self, "Text_9ju"):setString("20局(8金币)")

            elseif (sender:getName() == "CheckBox_fufei1") then
                gt.seekNodeByName(self, "CheckBox_fufei0"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_fufei1"):setSelected(true)

                gt.seekNodeByName(self, "Text_3ju"):setString("8局(1金币)")
                gt.seekNodeByName(self, "Text_6ju"):setString("12局(2金币)")
                gt.seekNodeByName(self, "Text_9ju"):setString("20局(3金币)")


            end
        end
    end

    sanJuCheckBox:addEventListenerCheckBox(_selectEvent)
    liuJuCheckBox:addEventListenerCheckBox(_selectEvent)
    jiuJuCheckBox:addEventListenerCheckBox(_selectEvent)

    yifenCheckBox:addEventListenerCheckBox(_selectEvent)
    erfenCheckBox:addEventListenerCheckBox(_selectEvent)
    sanfenCheckBox:addEventListenerCheckBox(_selectEvent)

    jiaopai_0:addEventListenerCheckBox(_selectEvent)
    jiaopai_8:addEventListenerCheckBox(_selectEvent)
    jiaopai_12:addEventListenerCheckBox(_selectEvent)

    changzhuCheckBox:addEventListenerCheckBox(_selectEvent)
    weizhiCheckBox:addEventListenerCheckBox(_selectEvent)
    hanshiCheckBox:addEventListenerCheckBox(_selectEvent)
    gt.seekNodeByName(self, "CheckBox_fufei1"):addEventListenerCheckBox(_selectEvent)
    gt.seekNodeByName(self, "CheckBox_fufei0"):addEventListenerCheckBox(_selectEvent)
    self:_init()
	-- 接收创建房间消息
	gt.socketClient:registerMsgListener(gt.GC_CREATE_ROOM, self, self.onRcvCreateRoom)

    gt.setOnViewClickedListener( gt.seekNodeByName(self, "Image"), 
        function() 
            -- self:hideTips() 
        if gt.seekNodeByName(self, "desc_1"):isVisible() then
            gt.seekNodeByName(self, "desc_1"):setVisible(false)
        else
            gt.seekNodeByName(self, "desc_1"):setVisible(true) 
        end 
        -- gt.seekNodeByName(self, "desc_1"):setVisible(true) 
    end)
    gt.setOnViewClickedListener( gt.seekNodeByName(self, "Img_Bk"),  function() self:hideTips() end)
end

function CreateRoomWuren:hideTips()
    gt.seekNodeByName(self, "desc_1"):setVisible(false)
end

--初始化成员变量
function CreateRoomWuren:_init()
    for i = 1 , 3 do 
        local node = self.csbNode:getChildByTag(i)
        gt.log("i________",cc.UserDefault:getInstance():getIntegerForKey("wr_jushu", 1))
        node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("wr_jushu", 1) == i)
    end

     for i = 4 , 5 do 
        local node = self.csbNode:getChildByTag(i)
        node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("wr_zhifu1", 1) == (i-4))
    end

    if cc.UserDefault:getInstance():getIntegerForKey("sde_play4", 0) == 0 then 
        gt.seekNodeByName(self, "Text_3ju"):setString("8局(4金币)")
               gt.seekNodeByName(self, "Text_6ju"):setString("12局(6金币)")
               gt.seekNodeByName(self, "Text_9ju"):setString("20局(8金币)")
   else
        gt.seekNodeByName(self, "Text_3ju"):setString("8局(1金币)")
               gt.seekNodeByName(self, "Text_6ju"):setString("12局(2金币)")
               gt.seekNodeByName(self, "Text_9ju"):setString("20局(3金币)")
   end

    for i = 10 , 12 do 
        local node = self.csbNode:getChildByTag(i)
        node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("sde_play2", 1) == i-9)
    end

    local node = self.csbNode:getChildByTag(20)
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("wr_erzhu", 0) == 1)

    node = self.csbNode:getChildByTag(21)
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("wr_weizhi", 1) == 1)

    node = self.csbNode:getChildByTag(22)
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("wr_hanshi", 0) == 1)  

    for i = 33 , 35 do 
        local node = self.csbNode:getChildByTag(i)
        gt.log(cc.UserDefault:getInstance():getIntegerForKey("wr_jiaopai", 1))
        node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("wr_jiaopai", 1) == i-33)
    end

    node = self.csbNode:getChildByTag(31) --闲家干扣底
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("wr_gankoudi", 0) == 1)

    node = self.csbNode:getChildByTag(52) --任意分 选主花牌为副庄
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("wr_renyifen", 0) == 1)

    node = self.csbNode:getChildByTag(23)
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("wr_fangzuobi", 1) == 1)

    node = self.csbNode:getChildByTag(24)
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("wr_guanzhan", 1) == 1)
end

--初始化UI
function CreateRoomWuren:_initUI()
	self.csbNode = cc.CSLoader:createNode("CreateRoomWuren.csb")
	self.csbNode:setAnchorPoint(0.5,0.5)
	self.csbNode:setPosition(gt.winCenter)
	self:addChild(self.csbNode)
	self.ZOrder = 5
end

function CreateRoomWuren:onRcvCreateRoom(msgTbl)
	gt.log("创建房间消息 ============== ")
	dump(msgTbl)
    if self._time then gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
	if msgTbl.kErrorCode ~= 0 then
		-- 创建失败
		gt.removeLoadingTips()

		if msgTbl.kErrorCode == 1 then
            require("client/game/dialog/NoticeTipsCommon"):create(2, "房卡不足，请在商城购买")
        elseif msgTbl.kErrorCode == 9 then
            require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "获取GPS信息失败！", nil, nil, true)
		else
            require("client/game/dialog/NoticeTipsCommon"):create(2, "创建房间失败")
		end
    else
        if self.deskType then
        else
            gt.CreateRoomFlag = true
        end
	end
end

return CreateRoomWuren

    -- "kAllowLookOn" = 1  1 允许观战 0 不能观战
    -- "kFeeType"     = 0  0 房主付   1 均摊
    -- "kFlag"        = 1  1. 8局  2. 12局   3. 20局
    -- "kGold"        = 1 
    -- "kGpsLimit"    = 0   0  相邻位置不能加入  1 相邻位置可以加入
    -- "kMId"         = 61012  消息号
    -- "kPlayType" = { 
    --     1 = 1     底分默认1
    --     2 = 1     2是常主
    --     3 = 0     不用 传0 
    --     4 = 1     对家含 10 
    --     5 = 0    防作弊
    --     6 = 1     干扣抵
    --     7 = 1      0 不交牌  1 交牌8分  2  交牌12分
    --     8 = 0     任意牌
    -- } 
    -- "kRobotNum"    = 0 
    -- "kSecret"      = "123456" 
    -- "kState"       = 108 