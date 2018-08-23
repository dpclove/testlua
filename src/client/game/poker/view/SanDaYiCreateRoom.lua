local gt = cc.exports.gt

local SanDaYiCreateRoom = class("SanDaYiCreateRoom", function()
	return gt.createMaskLayer()
end)

function SanDaYiCreateRoom:ctor()
	--初始化成员变量
	
	--初始化UI
	self:_initUI()
    

    -- 返回按键
	local Btn_queding = gt.seekNodeByName(self, "Btn_queding")
	gt.addBtnPressedListener(Btn_queding, function()
        gt.showLoadingTips("房间创建中...")
        local msgToSend = {}
		msgToSend.kMId = gt.CG_CREATE_ROOM
		msgToSend.kSecret = "123456"
		msgToSend.kGold = 1
        
		--msgToSend.kState = 107
        msgToSend.kState = 109 ---------------3打1
		msgToSend.kRobotNum = 0

	    msgToSend.kPlayType = {}
        -- 局数
        if(gt.seekNodeByName(self, "CheckBox_3ju"):isSelected()) then
		    msgToSend.kFlag = 1
        end
        if(gt.seekNodeByName(self, "CheckBox_6ju"):isSelected()) then
		    msgToSend.kFlag = 2
        end
        if(gt.seekNodeByName(self, "CheckBox_9ju"):isSelected()) then
		    msgToSend.kFlag = 3
        end
        cc.UserDefault:getInstance():setIntegerForKey("sdy_play1", msgToSend.kFlag )
        -- 底分
        if(gt.seekNodeByName(self, "CheckBox_1fen"):isSelected()) then
		    table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play2", 1 )
        elseif(gt.seekNodeByName(self, "CheckBox_2fen"):isSelected()) then
		    table.insert(msgToSend.kPlayType, 2)
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play2", 2 )
        elseif(gt.seekNodeByName(self, "CheckBox_3fen"):isSelected()) then
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play2", 3 )
		    table.insert(msgToSend.kPlayType, 3)
        end
        
        --2是常主
        if(gt.seekNodeByName(self, "CheckBox_changzhu"):isSelected()) then
		    table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play3_1",1)
        else
            table.insert(msgToSend.kPlayType, 0)
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play3_1",0)
        end
         --相邻外置禁止加入
        if(gt.seekNodeByName(self, "CheckBox_weizhi"):isSelected()) then
		    msgToSend.kGpsLimit = 1
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play3_2",1)
        else
            msgToSend.kGpsLimit = 0
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play3_2",0)
        end
         table.insert(msgToSend.kPlayType, 0) -- 第三位 占位符
         table.insert(msgToSend.kPlayType, 0) -- 第4位 占位符
         --[[
        --对家要牌含10
        if(gt.seekNodeByName(self, "CheckBox_hanshi"):isSelected()) then
		    table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play3_3",1)
        else
            table.insert(msgToSend.kPlayType, 0)
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play3_3",0)
        end
        ]]
        -- 防作弊
        if(gt.seekNodeByName(self, "CheckBox_hanshi_0"):isSelected()) then
            table.insert(msgToSend.kPlayType, 1)
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play3_4",1)
        else
            table.insert(msgToSend.kPlayType, 0)
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play3_4",0)
        end

         -- 观战
        if(gt.seekNodeByName(self, "CheckBox_hanshi_0_0"):isSelected()) then
            msgToSend.kAllowLookOn = 1
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play3_5",1)
        else
            msgToSend.kAllowLookOn = 0
            cc.UserDefault:getInstance():setIntegerForKey("sdy_play3_5",0)
        end

        msgToSend.kFeeType = gt.seekNodeByName(self, "CheckBox_fufei1"):isSelected()  and 1 or 0
        cc.UserDefault:getInstance():setIntegerForKey("sdy_play4",msgToSend.kFeeType)




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
            gt.log("SanDaYiCreateRoom创建房间 ======== ")
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

	local changzhuCheckBox = gt.seekNodeByName(self, "CheckBox_changzhu")
	local weizhiCheckBox = gt.seekNodeByName(self, "CheckBox_weizhi")
	local hanshiCheckBox = gt.seekNodeByName(self, "CheckBox_hanshi")

    sanJuCheckBox:setSelected(true)
    liuJuCheckBox:setSelected(false)
    jiuJuCheckBox:setSelected(false)
    
    yifenCheckBox:setSelected(true)
    erfenCheckBox:setSelected(false)
    sanfenCheckBox:setSelected(false)
    
    changzhuCheckBox:setSelected(false)
    weizhiCheckBox:setSelected(false)
    hanshiCheckBox:setSelected(false)
    ---------------------------------------------------------------------------- 3打1标识  start
    local Text_3ju = self.csbNode:getChildByName("Text_3ju")
    local Text_6ju = self.csbNode:getChildByName("Text_6ju")
    local Text_9ju = self.csbNode:getChildByName("Text_9ju")
    ---------------------------------------------------------------------------- 3打1标识  end

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
            elseif (sender:getName() == "CheckBox_fufei0") then
    
                gt.seekNodeByName(self, "CheckBox_fufei0"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_fufei1"):setSelected(false)
                ---------------------------------------------------------------------------- 3打1标识  start
                Text_3ju:setString("8局(4金币)")
                Text_6ju:setString("12局(6金币)")
                Text_9ju:setString("20局(8金币)")
                ---------------------------------------------------------------------------- 3打1标识  end

            elseif (sender:getName() == "CheckBox_fufei1") then
                gt.seekNodeByName(self, "CheckBox_fufei0"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_fufei1"):setSelected(true)
                ---------------------------------------------------------------------------- 3打1标识  start
                Text_3ju:setString("8局(1金币)")
                Text_6ju:setString("12局(2金币)")
                Text_9ju:setString("20局(3金币)")
                ---------------------------------------------------------------------------- 3打1标识  end

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
            elseif (sender:getName() == "CheckBox_fufei0") then
              
                gt.seekNodeByName(self, "CheckBox_fufei0"):setSelected(true)
                gt.seekNodeByName(self, "CheckBox_fufei1"):setSelected(false)
            elseif (sender:getName() == "CheckBox_fufei1") then
                gt.seekNodeByName(self, "CheckBox_fufei0"):setSelected(false)
                gt.seekNodeByName(self, "CheckBox_fufei1"):setSelected(true)

            end
        end
    end

    sanJuCheckBox:addEventListenerCheckBox(_selectEvent)
    liuJuCheckBox:addEventListenerCheckBox(_selectEvent)
    jiuJuCheckBox:addEventListenerCheckBox(_selectEvent)

    yifenCheckBox:addEventListenerCheckBox(_selectEvent)
    erfenCheckBox:addEventListenerCheckBox(_selectEvent)
    sanfenCheckBox:addEventListenerCheckBox(_selectEvent)

    changzhuCheckBox:addEventListenerCheckBox(_selectEvent)
    weizhiCheckBox:addEventListenerCheckBox(_selectEvent)
    hanshiCheckBox:addEventListenerCheckBox(_selectEvent)
    gt.seekNodeByName(self, "CheckBox_fufei1"):addEventListenerCheckBox(_selectEvent)
    gt.seekNodeByName(self, "CheckBox_fufei0"):addEventListenerCheckBox(_selectEvent)
    self:_init()
	-- 接收创建房间消息
	gt.socketClient:registerMsgListener(gt.GC_CREATE_ROOM, self, self.onRcvCreateRoom)

    local imag = gt.seekNodeByName(self,"desc_1")

    local bool = false
    gt.setOnViewClickedListener( gt.seekNodeByName(self, "Image") , function() bool = not bool imag:setVisible(bool) end)

    gt.setOnViewClickedListener( gt.seekNodeByName(self, "Img_Bk") , function() bool = false imag:setVisible(false) end)

end

--初始化成员变量
function SanDaYiCreateRoom:_init()

    

    for i = 1 , 3 do 
        local node = self.csbNode:getChildByTag(i)
        gt.log("i________",cc.UserDefault:getInstance():getIntegerForKey("sdy_play1", 1))
        node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("sdy_play1", 1) == i)
    end

     for i = 4 , 5 do 
        local node = self.csbNode:getChildByTag(i)
        node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("sdy_play4", 0) == (i-4))
    end

    ---------------------------------------------------------------------------- 3打1标识  start
    -- 3局 
    local Text_3ju = self.csbNode:getChildByName("Text_3ju")
    local Text_6ju = self.csbNode:getChildByName("Text_6ju")
    local Text_9ju = self.csbNode:getChildByName("Text_9ju")

    local _value = cc.UserDefault:getInstance():getIntegerForKey("sdy_play4", 0)
    if _value == 1 then         ------------玩家均摊
        Text_3ju:setString("8局(1金币)")
        Text_6ju:setString("12局(2金币)")
        Text_9ju:setString("20局(3金币)")
    else                        ------------房主支付
        Text_3ju:setString("8局(4金币)")
        Text_6ju:setString("12局(6金币)")
        Text_9ju:setString("20局(8金币)")
    end
    ---------------------------------------------------------------------------- 3打1标识  end
    

    for i = 10 , 12 do 
        local node = self.csbNode:getChildByTag(i)
        node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("sdy_play2", 1) == i-9)
    end



   
    local node = self.csbNode:getChildByTag(20)
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("sdy_play3_1", 0) == 1)

    node = self.csbNode:getChildByTag(21)
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("sdy_play3_2", 0) == 1)

    node = self.csbNode:getChildByTag(22)
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("sdy_play3_3", 0) == 1)

    node = self.csbNode:getChildByTag(23)
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("sdy_play3_4", 1) == 1)

    node = self.csbNode:getChildByTag(24)
    node:setSelected(cc.UserDefault:getInstance():getIntegerForKey("sdy_play3_5", 1) == 1)
    


end

--初始化UI
function SanDaYiCreateRoom:_initUI()
	self.csbNode = cc.CSLoader:createNode("SanDaYiCreateRoom.csb")
	self.csbNode:setAnchorPoint(0.5,0.5)
	self.csbNode:setPosition(gt.winCenter)
	self:addChild(self.csbNode)
	self.ZOrder = 5
end

function SanDaYiCreateRoom:onRcvCreateRoom(msgTbl)
	gt.log("创建房间消息 ============== ")
	dump(msgTbl)
    if self._time then gt.scheduler:unscheduleScriptEntry(self._time) self._time = nil end
	if msgTbl.kErrorCode ~= 0 then
		-- 创建失败
		gt.removeLoadingTips()

		if msgTbl.kErrorCode == 1 then
			require("client/game/dialog/NoticeTipsCommon"):create(2, "金币不足，请在商城购买")
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
return SanDaYiCreateRoom