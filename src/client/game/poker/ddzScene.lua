
--b614bbccf07b8e20323bfecb4db0a0eb3fcdde02

local ddzScene = class("ddzScene",gt.include("baseGame"))
local CardSprite = gt.include("ddzCard.CardSprite")
local CardsNode = gt.include("ddzCard.CardsNode")

local GameLogic =  gt.include("ddzCard.GameLogic")
local GameLaiziLogic =  gt.include("ddzCard.GameLaiziLogic")


local BT_EXIT 				= 1
local BT_EXIT1 				= 28
local BT_VOICE              = 27
local BT_CHAT 				= 2
local BT_GIVEUP				= 3
local BT_READY				= 4
local BT_LOOKCARD			= 5
local BT_FOLLOW				= 6
local BT_ADDSCORE			= 7
local BT_CHIP				= 8
local BT_CHIP_1				= 9
local BT_CHIP_2				= 10
local BT_CHIP_3				= 11
local BT_COMPARE 			= 12
local BT_CARDTYPE			= 13
local BT_SET				= 14
local BT_MENU				= 15
local BT_BANK 				= 16
local BT_VOICE_ENDED		= 17
local BT_VOICE_BEGAN		= 18
local BT_HELP 				= 19
local BT_INVITE             = 20
local BT_BEGIN              = 21
local BT_AUTO               = 22
local BT_READ               = 23
local BTN_SHARE             = 24
local BTN_QUIT              = 25
local QUXIAO                = 26

local PUSH_CARD             = 30
local PASS_CARD             = 31 
local PROMPT                = 29
local CHIPNUM 				= 100

ddzScene.ZOrder = {
	MJTABLE						= 1,
	MJTILES						= 2,
	DECISION_BTN				= 6,
	DECISION_SHOW				= 7,
	OUTMJTILE_SIGN				= 8,
	CHUTAIANIMATE 				= 9,
	PLAYER_INFO					= 10,
	PLAYER_INFO_TIPS			= 11,
	REPORT						= 16,
	DISMISS_ROOM				= 17,
	SETTING						= 18,
	CHAT						= 100,
	MJBAR_ANIMATION				= 21,
	FLIMLAYER           	    = 16,
	HAIDILAOYUE					= 23,
	GANG_AFTER_CHI_PENG			= 15,

	ROUND_REPORT				= 66,-- 单局结算界面显示在总结算界面之上
	DECISION_NEW                = 67,
	MOON_FREE_CARD              = 80,-- 中秋节免费送房卡活动弹框
}


-- 4 82 137     197 75 32

-- 133.76

local actionPos = {
	cc.p(413+70-80,396),
	cc.p(650,480),
	cc.p(870+80,396)
}
local _scheduler = gt._scheduler
local log = gt.log
local TIME = 30 
local tabCardPosition = 
    {
        cc.p(148.77+54.66, 530),
        cc.p(667, 110),
        cc.p(1129.90+54.66, 530)
    }


local win_action = {
	
	cc.p(240.09,522.88),
	cc.p(242.92,283.05),
	cc.p(1044.82,527.04)
}

-- local ptChat = {cc.p(169.64,615.51),cc.p(169.12,358.19),cc.p(1108.58,621.10)}
local ptChat = {cc.p(100,720),cc.p(100,510),cc.p(1176.38,720)}


function ddzScene:init(args)

	self._node:getChildByName("Text_35"):setString("v:12")

	gt.SCENE_TYPE = "PLAY"
    self.beishu = 0
	self:roominfo(args)
	self:initNode()
	self:addPlayer()
	if gt.csw_app_store then
		self:app_store()
	end
	
end

function ddzScene:reloginWhenError(_,m)
	gt.dumplog(m)
	local err = gt.err_dump(m)
	local  err_text  = self:findNodeByName("err")
	gt.log("err...........",err)
	if err ~= "" and err_text then 
		err_text:setLocalZOrder(5555)
		err_text:setVisible(true)
		err_text:setString(err)
	end
end




function ddzScene:switch_bg(i)
	if i == 3 then
			local xincaoId = math.random(1, 3)
			self._node:getChildByName("bg"):loadTexture("ddz/bg_ddz_xincao_"..xincaoId..".jpg")
			self:findNodeByName("fengd_b"):setVisible(false)
			self:findNodeByName("f_zuibi"):setVisible(false)
	else
		self._node:getChildByName("bg"):loadTexture("ddz/bg_ddz"..i..".png")
	end
end

function ddzScene:show_map()

		--if msgTbl.kUserGPSList then 
			local name = {"匿名","匿名","匿名","匿名"}
			local long = {"","","",""}
			local lan  = {"","","",""}
			local checkMapUrl = ""
			for i = 1 , gt.GAME_PLAYER do
				--local data = string.split(player[i],",")
				local data = string.split(self.Player[i].pos, ",") 
				long[i] = data[1]
				lan[i] = data[2]
			end
			for i = 1 , gt.GAME_PLAYER do
				gt.log("name.....",name[i])
				gt.log("long.....",long[i])
				gt.log("lan.....",lan[i])
				
			end
			--if #player >=1 then 
				checkMapUrl = 	gt.getUrlEncryCode(string.format(gt.CheckMapUrl, name[1], long[1], lan[1],name[2], long[2], lan[2],name[3], long[3], lan[3],name[4], long[4], lan[4]), gt.playerData.uid)
				if gt.isIOSPlatform() then
					local ok = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "NativeStartMap", {mapUrl = checkMapUrl, notice = ""})
				elseif gt.isAndroidPlatform() then
					require("client/game/common/mapView"):create(checkMapUrl,2)
				end
				
			--end
		--end

end

function ddzScene:initNode()

	-- gt.log("init______________")
	gt.log("gt.gameType-========",gt.gameType)
	gt.bgType = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType)
	--默认是新潮
	gt.log("默认是新潮")
	gt.dump(gt.bgType)
	gt.log("gt.gameType-========",gt.gameType)
	if tonumber(gt.bgType) ~= 1 and tonumber(gt.bgType) ~= 2 and tonumber(gt.bgType) ~= 3 then
		self:switch_bg(3)
		gt.log("self:switch_bg(gt.bgType)333333333333333")
		cc.UserDefault:getInstance():setIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, 3)
	else
		self:switch_bg(gt.bgType)
		gt.log("self:switch_bg(gt.bgType)")
	end


	  -- -- 加载动画纹理
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ddz/animation.plist")
	   -- 飞机
  --  self:loadAnimationFromFrame("plane_%d.png", 0, 5, "airship_key")
    -- 火箭
  --  self:loadAnimationFromFrame("rocket_%d.png", 0, 5, "rocket_key")
    -- 报警
    self:loadAnimationFromFrame("game_alarm_0%d.png", 0, 5, "alarm_key")
    -- 炸弹
    --self:loadAnimationFromFrame("game_bomb_0%d.png", 0, 5, "bomb_key")
   -- self:createAnimation()
    for i =1 , #gt.poker_node do
        cc.Director:getInstance():getTextureCache():addImage(gt.poker_node[i])
        cc.Director:getInstance():getTextureCache():addImage(gt.poker_node1[i])
    end
    --庄家不回，与回踢 气泡显示
	self.tmpPaoImage =""


    self.bomb = self:findNodeByName("bomb")
    self.spring = self:findNodeByName("spring")
    self.rocket = self:findNodeByName("rocket")
    self.plane = self:findNodeByName("plane")
    self.sunzi = self:findNodeByName("sunzi")
    self.sandaiyi = self:findNodeByName("sandaiyi")
    self.sidaier = self:findNodeByName("sidaier")
    self.liandui = self:findNodeByName("liandui")
    self.sandaiyidui = self:findNodeByName("sandaiyidui")
    self.sanzhang = self:findNodeByName("sanzhang")
	self.dz_win = self:findNodeByName("dz_win")
	self.nm_win = self:findNodeByName("nm_win")

	self.btnSender = self:findNodeByName("Txt_ChatSender")
	self.btnSender:setVisible(false)

	local node = self._node
	self:findNodeByName("game_info"):setVisible(false)

	local upMenu = node:getChildByName("up_btn")
	-- upMenu:setRotation(90)
	upMenu:setLocalZOrder(2001)
	local menu = node:getChildByName("upmenu")
	menu:setLocalZOrder(2000)
	menu:setVisible(false)
	-- menu:setRotation(90)
	-- menu:setScale(0.85)
	-- menu:setPosition(cc.p(menu:getPositionX() - menu:getContentSize().height / 2  - upMenu:getContentSize().width/2 -45,menu:getPositionY() + menu:getContentSize().height / 2 + upMenu:getContentSize().height/2  +20))
	self.pos =  self:findNodeByName("pos")
	self.pos:setVisible(false)
	gt.addBtnPressedListener(self.pos,function()
			self:removeRoom_node( )
			self:show_map()
		end)

	local bools = true
	gt.setOnViewClickedListener(upMenu,function()
					-- self:setPlayerAction( 2, "run_win_action" )
		self:removeRoom_node( )
		if self.result then return end

		menu:setVisible(bools)
		self:PlaySound("sound_res/cli.mp3")
		if bools then upMenu:loadTexture("ddz/set1.png") else upMenu:loadTexture("ddz/set.png") end
		bools = not bools

		end)


	gt.setOnViewClickedListener(node:getChildByName("bg"),function()
		if self.playerInfo then self.playerInfo:setVisible(false) end
		if not bools then
		menu:setVisible(bools)
		if bools then upMenu:loadTexture("ddz/set1.png") else upMenu:loadTexture("ddz/set.png") end
		bools = not bools
		end
		--log("nil_______________-")
		--self.tmp_card_select = nil
	end)
	
	gt.setOnViewClickedListener(menu:getChildByName("Image_12"),function()
		self:PlaySound("sound_res/cli.mp3")
		if self:getChildByName("_settinr_node_") then self:getChildByName("_settinr_node_"):removeFromParent() end
		local settingPanel = require("client/game/majiang/Setting"):create(self)
		settingPanel:setName("_settinr_node_")
		self:addChild(settingPanel, ddzScene.ZOrder.SETTING)
	end)

	local  btcallback = function(ref, type)
	if type == ccui.TouchEventType.ended then
			self:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end
	local _exit1 = menu:getChildByName("_exit")
	_exit1:setTag(BT_EXIT1)
	-- _exit1:setRotation(-90)
	
	_exit1:addTouchEventListener(btcallback)

	local _exit = menu:getChildByName("Button_6")
	_exit:setTag(BT_EXIT) 
	_exit:addTouchEventListener(btcallback)

	self.textnot = self:findNodeByName("textnot")

	self.btReady = self:findNodeByName("Button_11")
				 :setVisible(false)
			 	 :setTag(BT_READY)

	self.m_btnInvite = self:findNodeByName("Button_9")
	self.m_btnInvite:setVisible(true)
	self.m_btnInvite:setTag(BT_INVITE)
	self.begin_btn = self:findNodeByName("btn_begin")
	self.begin_btn:setTag(BT_BEGIN)
	self.begin_btn:setVisible(false)

	-- self.readResult = self:findNodeByName("readResult")
	-- self.readResult:setVisible(false)
	-- self.readResult:setTag(BT_READ)


		--聊天按钮
	local chat = self:findNodeByName("chat")
	chat:setTag(BT_CHAT)
	chat:addTouchEventListener(btcallback)




	self.huankuai = false
	self.gameBegin = false
	self.m_bLastCompareRes = false
	    -- 一轮提示组合
    self.m_promptIdx = 0
    self.m_promptIdxs = 0

    self.node_buf_l= {}
    self.node_buf_r= {}
    self.m_tabLastCards = {}
    self.card_banker_data = {}
    self.player_num = {}
	self.m_tabCurrentCards = {}
	self.m_UserHead = {}
	self.nodePlayer = {}
	self.Player = {}
	self._ti = {}
	self._clock = {}
	
	self.card = {}
	self.m_flagReady  = {}
	self.head_hui = {}
	self.m_tabNodeCards = {}
	self.m_tabCardCount = {}
	self.call_score = {}
	self.m_tabPromptList = {}
	self.m_tabSpAlarm = {}

	self._voice = {}
   	self._voice_node = {}
   	self._voice_nodes = {}

	self.m_UserChat = {}

	self.m_UserChatView = {}


	self.playingAni = {}
	self.playingNode = {}
	self.tallScore = {}

	self.m_outCardsControl = self:findNodeByName("outcards_control")

	self.d_card = self:findNodeByName("card_d")
	:setVisible(false)

	self.d_card1 = self:findNodeByName("card_d_1111")
	:setVisible(false)


	self.d_card_center = self:findNodeByName("card_d_center"):setVisible(false)
	self.d_card_center_hua = self:findNodeByName("card_d_center_hua"):setVisible(false)
	
	

    self.text5 = self:findNodeByName("wait")
    self:ActionText5(false)



    self.m_cardControl = self:findNodeByName("card_control")
    self.m_tabCardCount[1] = self.m_cardControl:getChildByName("AtlasLabel_1")
    self.m_tabCardCount[1]:setLocalZOrder(20)
    self.m_tabCardCount[3] = self.m_cardControl:getChildByName("AtlasLabel_3")
    self.m_tabCardCount[3]:setLocalZOrder(20)

    


    self.result_node = cc.CSLoader:createNode("resultsNode_ddz.csb")
    :setVisible(false)
    :addTo(self)

    self.result_min_node = cc.CSLoader:createNode("min_result_ddz.csb")
    :setVisible(false)
    :addTo(self)


    self.callscore_control = self:findNodeByName("callscore_control")
    self.callscore_control1 = self:findNodeByName("callscore_control_1")
    self.operation = self:findNodeByName("btn_operation")

    self.ti_btn = self:findNodeByName("t_btn")

    gt.setOnViewClickedListener(self.ti_btn:getChildByName("not_t"),function()
    		 self.ti_btn:setVisible(false)
    		 if self.ti_type == 125 then 
    		 	self:_playSound(gt.MY_VIEWID,"t5.mp3")
    		 		 local m = {}
		    		 m.kIsYes = 0
		    		 m.kMId = 62102
					 m.kSubCmd = (self.ti_type - 118)
					 gt.dumplog(m)
					 gt.socketClient:sendMessage(m)
					 self.m_tabNodeCards[gt.MY_VIEWID]:reSetCards()
    		 elseif self.ti_type == 124 or self.ti_type == 123 then 
    		 	self:_playSound(gt.MY_VIEWID,"t4.mp3")
    		 		 local m = {}
		    		 m.kIsYes = 0
		    		 m.kMId = 62102
					 m.kSubCmd = (self.ti_type - 118)
					 gt.dumplog(m)
					 gt.socketClient:sendMessage(m)
					 self.m_tabNodeCards[gt.MY_VIEWID]:reSetCards()
    		 end
    	end)


    gt.setOnViewClickedListener(self.ti_btn:getChildByName("t_t"),function()
    		self.ti_btn:setVisible(false)

    		if self.ti_type == 123 then 
    				 local m = {}
		    		 m.kIsYes = 1
		    		 m.kMId = 62102
					 m.kSubCmd = (self.ti_type - 118)
					 gt.dumplog(m)
					 gt.socketClient:sendMessage(m)
					 self:_playSound(gt.MY_VIEWID,"t1.mp3")
					 self.m_UserHead[self:getTableId(self.UsePos)].t_icon:loadTexture("ddz/ttt.png")
					 self.m_UserHead[self:getTableId(self.UsePos)].t_icon:setVisible(true)
					 self.m_tabNodeCards[gt.MY_VIEWID]:reSetCards()

					-- if self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)) then
			  		local ani_id = self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)):getTag() - 1000
			  		gt.log("ani_id======",ani_id)
				  	if tonumber(ani_id) > 0 then
				  		self.playingNode[ani_id]:getChildByName("Image_1"):setVisible(true)
				  		self.playingNode[ani_id]:getChildByName("Image_1"):loadTexture("ddz/ttt.png")
				  	end




					--  if self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)) then
					-- 	ani_id = self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)):getTag() - 1000
					-- 	if tonumber(ani_id) > 0  then
					-- 		local nodes = cc.Sprite:create("ddz/ttt.png")
					-- 		nodes:setPosition(cc.p(30,30))
					-- 		self.playingNode[ani_id]:addChild(nodes)
					-- 	end
					-- end
					-- if i == j then
					-- 	-- local ani_id = self:getChildByName("wanjia" .. j):getTag() - 100
					-- 	--此时变为思考状态
					-- 	if self._node:getChildByName("wanjia_" .. j) then
					--   		ani_id = self._node:getChildByName("wanjia_" .. j):getTag() - 1000
					-- 	  	if tonumber(ani_id) > 0 then
					-- 			self:setPlayerAction(ani_id ,"run_sikao_action")
					-- 	 	end
					-- 	end
					-- end

					--  if self._node:getChildByName("wanjia_" .. j) then
					-- 	ani_id = self._node:getChildByName("wanjia_" .. j):getTag() - 1000
					-- 	if tonumber(ani_id) > 0 then
					-- 		self:setPlayerAction(ani_id ,"run_daiji_action")
					-- 	end
					-- end
					-- if i == j then
					-- 	-- local ani_id = self:getChildByName("wanjia" .. j):getTag() - 100
					-- 	--此时变为思考状态
					-- 	if self._node:getChildByName("wanjia_" .. j) then
					--   		ani_id = self._node:getChildByName("wanjia_" .. j):getTag() - 1000
					-- 	  	if tonumber(ani_id) > 0 then
					-- 			self:setPlayerAction(ani_id ,"run_sikao_action")
					-- 	 	end
					-- 	end
					-- end



    		elseif self.ti_type == 124 then 
    				 local m = {}
		    		 m.kIsYes = 1
		    		 m.kMId = 62102
					 m.kSubCmd = (self.ti_type - 118)
					 gt.dumplog(m)
					 gt.socketClient:sendMessage(m)
					 self:_playSound(gt.MY_VIEWID,"t2.mp3")
					 self.m_UserHead[self:getTableId(self.UsePos)].t_icon:loadTexture("ddz/ttt.png")
					 self.m_UserHead[self:getTableId(self.UsePos)].t_icon:setVisible(true)
					 self.m_tabNodeCards[gt.MY_VIEWID]:reSetCards()

					-- if self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)) then
			  		local ani_id = self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)):getTag() - 1000
			  		gt.log("ani_id======",ani_id)
				  	if tonumber(ani_id) > 0 then
				  		self.playingNode[ani_id]:getChildByName("Image_1"):setVisible(true)
				  		self.playingNode[ani_id]:getChildByName("Image_1"):loadTexture("ddz/ttt.png")
				  	end
    		elseif self.ti_type == 125 then 
    				 local m = {}
		    		 m.kIsYes = 1
		    		 m.kMId = 62102
					 m.kSubCmd = (self.ti_type - 118)
					 gt.dumplog(m)
					 gt.socketClient:sendMessage(m)
					 self:_playSound(gt.MY_VIEWID,"t3.mp3")
					 self.m_UserHead[self:getTableId(self.UsePos)].t_icon:loadTexture("ddz/hhh.png")
					 self.m_UserHead[self:getTableId(self.UsePos)].t_icon:setVisible(true)
					 self.m_tabNodeCards[gt.MY_VIEWID]:reSetCards()
					-- if self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)) then
			  		local ani_id = self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)):getTag() - 1000
			  		gt.log("ani_id======",ani_id)
				  	if tonumber(ani_id) > 0 then
				  		self.playingNode[ani_id]:getChildByName("Image_1"):setVisible(true)
				  		self.playingNode[ani_id]:getChildByName("Image_1"):loadTexture("ddz/hhh.png")
				  	end
    		end
    	end)

	----出牌按钮
   	self.push_btn = self.operation:getChildByName("push")
   	self.push_btn:setTag(PUSH_CARD)
   	self.push_btn:addTouchEventListener(btcallback)

   	self.pass = self.operation:getChildByName("pass")
   	self.pass:setTag(PASS_CARD)
   	self.pass:addTouchEventListener(btcallback)

   	self.prompt = self.operation:getChildByName("Prompt")
   	self.prompt:setTag(PROMPT)
   	self.prompt:addTouchEventListener(btcallback)


    local btn = self.result_node:getChildByName("Button_2")
    btn:setTag(BTN_SHARE)
    btn:addTouchEventListener(btcallback)

    local btn = self.result_node:getChildByName("Button_1")
    btn:setTag(BTN_QUIT)
    btn:addTouchEventListener(btcallback)


    local UserInfo = require("client/game/majiang/UserInfo"):create(self.Player[i])
	self:addChild(UserInfo,1000)

	self.UserInfo = UserInfo
	self.UserInfo:setVisible(false)

	for i = 1 , gt.GAME_PLAYER do

		self.player_num[i] = false
		self.Player[i] = {}
		self.Player[i].name = ""
		self.Player[i].score = nil
		self.Player[i].url = nil
		self.Player[i].sex = nil
		self.Player[i].id = nil
		self.Player[i].ip= nil
		self.Player[i].pos= ""..","..""
		self.Player[i].Coins= nil
		self.Player[i]._pos = nil

		self.m_flagReady[i] = self:findNodeByName("ready_"..i)
		:setVisible(false)


		self._ti[i] = self:findNodeByName("t_"..i)
		:setVisible(false)
		self._ti[i]:setScale(0.65)

		self._clock[i] = self:findNodeByName("clock_"..i)
		:setVisible(false)

		

    	self.call_score[i] = self:findNodeByName("x"..i)
    	:setVisible(false)
		self.call_score[i]:setScale(0.8)

		self.head_hui[i] = self:findNodeByName("l_off_"..i)
		self.head_hui[i]:setLocalZOrder(2009)
		:setVisible(false)
		self.nodePlayer[i] = self:findNodeByName("player_"..i)
		self.nodePlayer[i]:setVisible(false)

		self.m_UserHead[i] = {}
		--昵称
		self.m_UserHead[i].name = self.nodePlayer[i]:getChildByName("name")
								
		--金币
		self.m_UserHead[i].score =  self.nodePlayer[i]:getChildByName("score")
				
		self.m_UserHead[i].t_icon = self.nodePlayer[i]:getChildByName("t_icon")


		self.m_UserHead[i].maozi = self.nodePlayer[i]:getChildByName("maozi")
		:setVisible(false)


		       -- 扑克牌
        self.m_tabNodeCards[i] = CardsNode:createEmptyCardsNode(i)

        self.m_tabNodeCards[i]:setPosition(tabCardPosition[i])
        self.m_tabNodeCards[i]:setListener(self)
        self.m_cardControl:addChild(self.m_tabNodeCards[i])
       	self.m_cardControl:setVisible(false)
        self.m_tabSpAlarm[i] = self.m_cardControl:getChildByName("alarm_" .. i)
       -- cc.rect(30, 14, 46, 20)
        self.m_UserChatView[i] = display.newSprite((i<= gt.MY_VIEWID and "game_chat_s0.png" or "game_chat_s1.png")	,{scale9 = true ,capInsets=cc.rect(30, 14, 46, 20)})
				:setAnchorPoint(i<= gt.MY_VIEWID  and cc.p(0,0.5) or cc.p(1,0.5))
				:move(ptChat[i])
				:setVisible(false)
				:addTo(self._node)

		self.m_UserChatView[i]:setPositionY(self.m_UserChatView[i]:getPositionY()-120)
		self._voice[i] = self:findNodeByName("voice_"..i)
				:setVisible(false)
		self._voice[i]:setScaleX(0.5)
		self._voice[i]:setScaleY(0.75)
				-- :move(ptChat[i])
		-- self._voice_node[i] = self:findNodeByName("FileNode_"..i)
		-- 					:setVisible(false)
		-- 					:move(ptChat[i].x,ptChat[i].y+2)
		self._voice_node[i] = self:findNodeByName("FileNode_"..i)
					:setVisible(false)
							-- :move(ptChat[i].x,ptChat[i].y+2)
		self._voice_node[i] = self:findNodeByName("FileNode_" .. i)
		self._voice_node[i]:setPosition(self._voice[i]:getPositionX(),self._voice[i]:getPositionY() + 2)
		if i == 1 or i == 3 then
			self._voice_node[i]:setRotation(180)
		end

		gt.setOnViewClickedListener(self.nodePlayer[i]:getChildByName("bg"),function()
			self:PlaySound("sound_res/cli.mp3")
			self:showPlayerinfo(i)
			end)
	end
	self.room_node = self:findNodeByName("room_info_bg")
	-- self.room_node_pos = self.room_node:getPosition()
	self.iMenu = node:getChildByName("i_btn")
	-- self.iMenu:setScale(1.5)MenuMenu


	-- self.room_node:setVisible(false)
	-- self.room_node:setOpacity(0)
	-- self.room_node:setScale(0.01)
	-- self.iMenu:setVisible(false)
	self.iscanTouch = false
	local spawnAction = cc.Spawn:create(cc.MoveTo:create(0.2,cc.p(454.86,685.15 + 50)),cc.ScaleTo:create(0.2,0.01),cc.FadeOut:create(0.2))
	local seqAction = cc.Sequence:create(cc.DelayTime:create(3),spawnAction,cc.CallFunc:create(function()
			-- self.iMenu:setVisible(true)
			self.iMenu:setTouchEnabled(true)
			self.iscanTouch = true
			gt.log("num_beishu_1=======",self:findNodeByName("num_beishu_1"):getString())
			if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
				-- self:findNodeByName("num_beishu_1"):getString()
				self:findNodeByName("room_beishu_lbl"):setString(self:findNodeByName("num_beishu_1"):getString())
			else
				self:findNodeByName("room_beishu_lbl"):setString(self:findNodeByName("num_beishu_1"):getString())
			end
		end))
	self.room_node:runAction(seqAction)
	gt.setOnViewClickedListener(self.iMenu,function()
		self:PlaySound("sound_res/cli.mp3")
		-- self:showThreeCardAction(  )

		-- local action_icon = self.nodePlayer[2]:getChildByName("action_" .. 2)
		-- local playingNode, playingAni = gt.createCSAnimation("res/animation/bianshen_action/bianshen_action.csb")
		-- playingAni:play("run_action", true)
		-- action_icon:addChild(playingNode)
		-- playingAni:setFrameEventCallFunc(function(frameEventName)
		-- 	local name = frameEventName:getEvent()
		-- 	if name == "_end" then
		-- 		playingNode:stopAllActions()
		-- 		playingNode:removeFromParent()
		-- 		self:addPlayerAction(2, "dizhu", "run_daiji_action" )
		-- 	end
		-- end)

		self.iscanTouch = false
		if not self.room_node:isVisible() then
			self.room_node:setVisible(true)
		end
		-- self:findNodeByName("game_info"):setVisible(false)
		-- self.iMenu:setVisible(false)
		self.iMenu:setTouchEnabled(false)
		local spawnAction = cc.Spawn:create(cc.MoveTo:create(0.2,cc.p(638.97,375.78)),cc.ScaleTo:create(0.2,1),cc.FadeIn:create(0.2))
		local seqAction = cc.Sequence:create(spawnAction,cc.CallFunc:create(function()
				-- self.iMenu:setVisible(false)
				self.iMenu:setTouchEnabled(false)
				-- self.iscanTouch = true
				self.iscanTouch = true
				if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
					-- self:findNodeByName("num_beishu_1"):getString()
					self:findNodeByName("room_beishu_lbl"):setString(self:findNodeByName("num_beishu_1"):getString())
				else
					self:findNodeByName("room_beishu_lbl"):setString(self:findNodeByName("num_beishu_1"):getString())
				end
			end))
		self.room_node:runAction(seqAction)
	end)

	for i=1,3 do
		local player_action = self:findNodeByName("player_action_" .. i)
		gt.setOnViewClickedListener(player_action:getChildByName("touch_bg"),function()
			self:PlaySound("sound_res/cli.mp3")
			self:showPlayerinfo(i)
		end)
		player_action:getChildByName("touch_bg"):setOpacity(0)
		player_action:setVisible(false)
	end

	for i = 1, 4 do
		self.callscore_control:getChildByName("score_btn"..(i-1)):setTag(999+i)
    	self.callscore_control:getChildByName("score_btn"..(i-1)):addTouchEventListener(btcallback)
	end

	self.callscore_control1:getChildByName("score_btn"..0):setTag(999+1)
	self.callscore_control1:getChildByName("score_btn"..0):addTouchEventListener(btcallback)
	self.callscore_control1:getChildByName("score_btn"..3):setTag(999+4)
	self.callscore_control1:getChildByName("score_btn"..3):addTouchEventListener(btcallback)

	self.btReady:addTouchEventListener(btcallback)
	--self.readResult:addTouchEventListener(btcallback)
	self.m_btnInvite:addTouchEventListener(btcallback)
	self.begin_btn:addTouchEventListener(btcallback)


	self.playerInfo = cc.CSLoader:createNode("playerInfo.csb")
					  :move(gt.winCenter)
					  :addTo(self,9)
		              :setVisible(false)

	local node = self:findNodeByName("times")
	-- node:setPositionX(self.result_node:getChildByName("bg"):getContentSize().width/2 + node:getContentSize().width)

		local FileName = cc.FileUtils:getInstance():getWritablePath() .. "Q.apk"

	

	

	

	if node then node:setString(os.date("%H:%M")) end
	self.__time = _scheduler:scheduleScriptFunc(function()

		
		if node then node:setString(os.date("%H:%M")) end

		if self.huankuai and os.time() - self.huankuai_time >=30 then 
			 gt.soundEngine:playMusic_poker("sound_res/ddz/bg_zc.wav",true)
		     self.huankuai = false
	    end

	  -- spr1:loadTexture("bg1.png")
	  

	end,1,false)

	-- local spr = cc.Sprite:create("a.png")
	-- self:addChild(spr)


	if not gt.csw_app_store then
		--self:findNodeByName("voice"):setVisible(self.data.kPlaytype[5] == 0)
		self:findNodeByName("voice"):loadTextureNormal(self.data.kPlaytype[5] == 0 and "ddz/voice.png" or "ddz/voice1.png")
		self:findNodeByName("voice"):loadTexturePressed(self.data.kPlaytype[5] == 0 and "ddz/voice.png" or "ddz/voice1.png")
		self:findNodeByName("voice"):loadTextureDisabled(self.data.kPlaytype[5] == 0 and "ddz/voice.png" or "ddz/voice1.png")
	end
	self:findNodeByName("f_zuibi"):setVisible(self.data.kPlaytype[5] == 1)
	if (tonumber(gt.bgType) ~= 1 and tonumber(gt.bgType) ~= 2 and tonumber(gt.bgType) ~= 3)  or tonumber(gt.bgType) == 3 then
		self:findNodeByName("f_zuibi"):setVisible(false)
	end
	if self.data.kPlaytype[5] == 1 then 
		-- for i = 1 , #self.node_buf_l do
		-- 	log("pos________________x")
		-- 	self.node_buf_l[i]:setPositionX(self.node_buf_l[i]:getPositionX()-133.76)
		-- end
		-- for i = 1 , #self.node_buf_r do
		-- 	self.node_buf_l[i]:setPositionX(self.node_buf_l[i]:getPositionX()+133.76)
		-- end
		self.m_UserHead[1].name:setVisible(false)
		self.m_UserHead[1].score:setVisible(false)
		self.m_UserHead[3].name:setVisible(false)
		self.m_UserHead[3].score:setVisible(false)
		-- self.nodePlayer[1]:getChildByName("bg"):setVisible(false)
		-- self.nodePlayer[3]:getChildByName("bg"):setVisible(false)
	end

	local playingNode1, playingAni1 = gt.createCSAnimation("res/animation/".. "nongmin" .."_action/" .. "nongmin" .. "_action.csb")
	playingAni1:play("run_daiji_action", true)
	-- playingNode1:setPosition(self:findNodeByName("chat_head_action_1"):getPosition())
	-- local pos =cc.p(0,0)
	local posX = 0
	local posY = 0
	-- if id == 3 then
	-- 	pos = cc.p(self:findNodeByName("chat_head_action_" .. id):getPositionX(),self:findNodeByName("chat_head_action_" .. id):getPositionY() + 15)
	-- else
	-- 	pos = cc.p(self:findNodeByName("chat_head_action_" .. id):getPositionX(),self:findNodeByName("chat_head_action_" .. id):getPositionY() - 15)
	-- end
	gt.addNode(self._node,playingNode1)
	self.playingNode[1] = playingNode1
	self.playingAni[1] = playingAni1
	self.playingNode[1]:setVisible(false)
	self.playingNode[1]:setTag(1001)
	self.playingNode[1]:setPosition(cc.p(posX,posY))

	local playingNode2, playingAni2 = gt.createCSAnimation("res/animation/".. "nongmin" .."_action/" .. "nongmin" .. "_action.csb")
	playingAni2:play("run_daiji_action", true)
	gt.addNode(self._node,playingNode2)
	-- playingNode2:setPosition(self:findNodeByName("chat_head_action_2"):getPosition())
	self.playingNode[2] = playingNode2
	self.playingAni[2] = playingAni2
	self.playingNode[2]:setVisible(false)
	self.playingNode[2]:setTag(1002)
	self.playingNode[2]:setPosition(cc.p(posX,posY))

	local playingNode3, playingAni3 = gt.createCSAnimation("res/animation/".. "dizhu" .."_action/" .. "dizhu" .. "_action.csb")
	playingAni3:play("run_daiji_action", true)
	playingNode3:setLocalZOrder(2008)
	gt.addNode(self._node,playingNode3)
	-- playingNode3:setPosition(self:findNodeByName("chat_head_action_3"):getPosition())
	self.playingNode[3] = playingNode3
	self.playingAni[3] = playingAni3
	self.playingNode[3]:setVisible(false)
	self.playingNode[3]:setTag(1003)
	self.playingNode[3]:setPosition(cc.p(posX,posY))


	self.playingNode[1]:getChildByName("Image_1"):setVisible(false)
	self.playingNode[2]:getChildByName("Image_1"):setVisible(false)
	self.playingNode[3]:getChildByName("Image_1"):setVisible(false)


	if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
		self:findNodeByName("num_beishu_1"):setString("倍数:"..self.beishu)
		self:findNodeByName("room_beishu_lbl"):setString("倍数:".. self.beishu)
	else
		self:findNodeByName("num_beishu_1"):setString("叫分:"..self.beishu)
		self:findNodeByName("room_beishu_lbl"):setString("叫分:".. self.beishu)
	end
	self.playingNode[1]:setScale(0.85)
	self.playingNode[2]:setScale(0.85)
	self.playingNode[3]:setScale(0.85)

	if self.data.kPlaytype[5] == 1 then
		for i=1,3 do
			self.playingNode[i]:getChildByName("name"):setVisible(false)
			self.playingNode[i]:getChildByName("bg"):setVisible(false)
			local player_action = self:findNodeByName("player_action_" .. i)
			player_action:getChildByName("score"):setVisible(false)
			player_action:getChildByName("bg"):setVisible(false)
			player_action:getChildByName("name"):setVisible(false)
			player_action:getChildByName("bg_0"):setVisible(false)
			if i == 2 then
				player_action:getChildByName("score"):setVisible(true)
				player_action:getChildByName("bg"):setVisible(true)
				player_action:getChildByName("name"):setVisible(true)
				player_action:getChildByName("bg_0"):setVisible(true)
			end
		end
	end

	--当防作弊时候，取消语音和表情
	if self.data.kPlaytype[5] and self.data.kPlaytype[5] == 1 then
		self:findNodeByName("chat"):setVisible(false)
		self:findNodeByName("voice"):setVisible(false)
	else
		self:findNodeByName("chat"):setVisible(true)
		self:findNodeByName("voice"):setVisible(true)
	end

end


function ddzScene:removeRoom_node( )
	if not self.iscanTouch then return end
		self.iscanTouch = false
		local spawnAction = cc.Spawn:create(cc.MoveTo:create(0.2,cc.p(454.86,685.15 + 50)),cc.ScaleTo:create(0.2,0.01),cc.FadeOut:create(0.2))
		local seqAction = cc.Sequence:create(spawnAction,cc.CallFunc:create(function()
		    	self.room_node:setVisible(false)
				-- self.iMenu:setVisible(true)
				self.iMenu:setTouchEnabled(true)
				self.iscanTouch = true
		   end))
		self.room_node:runAction(seqAction)

end

function ddzScene:nil_card()

	gt.log("nil__________________s")
	self.tmp_card_select = nil

end
function ddzScene:setPlayerAction( id, _action )
	gt.log("id====" , id)
	gt.log("_action====",_action)
	-- if self.playingNode[id] then
	-- 	self.playingNode[id]:setVisible(true)
	-- end
	if self.playingAni[id] and self.playingNode[id]:isVisible() then
		self.playingAni[id]:play(_action,true)
	end
end 

function ddzScene:showPlayerinfo(i)
	self:removeRoom_node()
	if gt.csw_app_store then return end
	if self.data.kPlaytype[5] == 1 then local scene = display.getRunningScene() if scene then Toast.showToast(scene, "当前防作弊房间，禁止查看玩家信息！", 1) return end end 
 
	if i < 0 or i > gt.GAME_PLAYER then return end
	-- self.Player[i].headURL  = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"
	-- self.Player[i].headURL = self.Player[i].url
	-- local roomPlayer = self.Player[i]
	-- roomPlayer.headURL =  self.Player[i].url
	if self.Player[i].id and self.UserInfo.init then
		self.UserInfo:init(self.Player[i])
	end



	
	-- self.playerInfo:setVisible(true)
	-- local node = self.playerInfo
	-- node:getChildByName("name"):setString("昵称："..self.Player[i].name)
	-- node:getChildByName("ID"):setString("ID："..self.Player[i].id)
	-- node:getChildByName("ip"):setString("IP："..self.Player[i].ip)
	-- node:getChildByName("score"):setVisible(false) --setString("金币："..self.Player[i].Coins)
	-- local data = self.Player[i].url
	-- if node:getChildByName("__ICON___") then  node:getChildByName("__ICON___"):removeFromParent() end
	-- if data and type(data) ~= nil and  string.len(data) > 10 then
	-- 	local icon = node:getChildByName("kuang_2")
	-- 	local iamge = gt.imageNamePath(data)
	-- 	node:getChildByName("icon_3"):setVisible(false)

	--   	if iamge then
	--   		local _node = display.newSprite("player/icon.png")
	-- 		local head = gt.clippingImage(iamge,_node,false)
	-- 		node:addChild(head)
	-- 		head:setName("__ICON___")
	-- 		head:setPosition(icon:getPositionX(),icon:getPositionY())
	--   	else
	--   		local function callback(args)
	--       		if args.done  then
	-- 				local _node = display.newSprite("player/icon.png")
	-- 				local head = gt.clippingImage(args.image,_node,false)
	-- 				node:addChild(head)
	-- 				head:setName("__ICON___")
	-- 				head:setPosition(icon:getPositionX(),icon:getPositionY())
	-- 			end
	--         end
	-- 	    local url = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"
	-- 	    url = data
	-- 	    gt.downloadImage(url,callback)	
	--   	end
	-- else
	-- 	node:getChildByName("icon_3"):setVisible(true)
	-- end
end



function ddzScene:onRcvChatMsg(msgTbl)
	gt.log("收到聊天消息")
	--dump(msgTbl)
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("images/EmotionOut.plist")
	if msgTbl.kType == 5 then -- 互动动画类型

		local sendRoomPlayer = self.Player[self:getTableId(msgTbl.kPos)]
	-- sendRoomPlayer.displaySeatIdx = self:getTableId(msgTbl.kPos) 


	local receiveRoomPlayer = nil  --发送互动的玩家
		-- local temp1 = 1
		-- local temp2 = 1
		sendRoomPlayer.displaySeatIdx = self:getTableId(msgTbl.kPos)

  		table.foreach(self.Player, function(i, v)
  			if v.id == tonumber(msgTbl.kUserId) then
  				-- sendRoomPlayer.displaySeatIdx = i
  				sendRoomPlayer.displaySeatIdx = i
  				-- gt.log("sendRoomPlayer.displaySeatIdx====================1111111",sendRoomPlayer.displaySeatIdx)
  			end
  			if v.id == tonumber(msgTbl.kMsg) then
				receiveRoomPlayer = v
				receiveRoomPlayer.displaySeatIdx = i
  				return true
  			end
  		end)

  		if not receiveRoomPlayer or not receiveRoomPlayer.displaySeatIdx then
  			return
  		end
  		if not sendRoomPlayer.displaySeatIdx then
  			return
  		end
	

		local aniNames = {{"hudong1/hua01.png", "hudong1.csb", "common/hudong1"},
		{"hudong2/zuanshi01.png", "hudong2.csb", "common/hudong2"},
		{"hudong3/kiss01.png", "hudong3.csb", "common/hudong3"},
		{"hudong5/jinbi01.png", "hudong5.csb", "common/hudong5"}}

		gt.dump(sendRoomPlayer)
		gt.dump(receiveRoomPlayer)



		local sendPlayerNode = self:findNodeByName("biaoqing_" .. sendRoomPlayer.displaySeatIdx)
		local receivePlayerNode = self:findNodeByName("biaoqing_" .. receiveRoomPlayer.displaySeatIdx)
		receivePlayerNode:setVisible(true)
		local sendNodePos = cc.p(sendPlayerNode:getPositionX(),sendPlayerNode:getPositionY())
		local receiveNodePos = cc.p(receivePlayerNode:getPositionX(),receivePlayerNode:getPositionY())
		gt.dump(gt.playerData)
		if sendRoomPlayer.id == gt.playerData.uid then  --发送者为自己
		
			if receiveRoomPlayer.id ~= gt.playerData.uid then
			
				local feiSpr = cc.Sprite:create("animation/"..aniNames[msgTbl.kId][1])
				gt.log("msgTbl.kId===" , msgTbl.kId)
				if  msgTbl.kId == 4 then 
					feiSpr:setScale(0.7)
				end
				local completeFunc = cc.CallFunc:create(function()
						feiSpr:stopAllActions()
						feiSpr:removeFromParent(true)
						
						local boNode, boAni = gt.createCSAnimation("animation/"..aniNames[msgTbl.kId][2])

						local num = 0 
						if  msgTbl.kId == 2 then 
							num = 10
						end
						if  msgTbl.kId == 4 then 
						boNode:setScale(0.7)
						end

						gt.log("msgTbl.kId____________",msgTbl.kId)

						
						boNode:setPosition(cc.p(receiveNodePos.x+num, receiveNodePos.y))
						self:addChild(boNode, 1000)
						boAni:gotoFrameAndPlay(0, false)
						if aniNames[msgTbl.kId][3] then
							gt.soundEngine:playEffect(aniNames[msgTbl.kId][3], false, true)
						end
						-- boNode:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function(sender)
						-- 	sender:stopAllActions()
						-- 	sender:removeFromParent(true)
						-- end)))
						boAni:setFrameEventCallFunc(function(frameEventName)
							gt.dump(frameEventName)
						   local name = frameEventName:getEvent()
						   gt.log("name======...............",name)
							if name == "_end" then
							   	boNode:stopAllActions()
							   	boNode:removeFromParent()
						   	end
						end)
					end)
				local time = 0.8
				if receiveRoomPlayer.displaySeatIdx == 1 then
					time = 0.3
				end
				-- local moveAni = cc.MoveTo:create(time, cc.p(receiveNodePos.x+x, receiveNodePos.y+y))
				local moveAni = cc.MoveTo:create(time, cc.p(receiveNodePos.x, receiveNodePos.y))

				gt.log("receiveNodePos....x",receiveNodePos.x)
				gt.log("receiveNodePos....y",receiveNodePos.y)



				gt.log("sendNodePos....x",sendNodePos.x)
				gt.log("sendNodePos....y",sendNodePos.y)


				feiSpr:setPosition(cc.p(sendNodePos.x, sendNodePos.y))
				feiSpr:runAction(cc.Sequence:create(moveAni, completeFunc))
				-- feiAni:gotoFrameAndPlay(0, true)
				self:addChild(feiSpr, 1000)
				-- feiSpr:setPosition(cc.p(sendNodePos.x+x, sendNodePos.y))

			end
			
		else
			if receiveRoomPlayer.id == gt.playerData.uid then --接受者方才播放
				-- local btnSender = self:findNodeByName("Txt_ChatSender")
				-- gt.log("sendRoomPlayer.name===",sendRoomPlayer.name)
				-- gt.dump(sendRoomPlayer)
				self.btnSender:setText("\"".. sendRoomPlayer.name.."\"馈赠给你的表情")
				self.btnSender:setVisible(true)
				local playingNode, playingAni = gt.createCSAnimation("animation/"..aniNames[msgTbl.kId][2])
				playingNode:setScale(2)
				if msgTbl.kId == 4 then 
					playingNode:setScale(1.3)
				end
				self:addChild(playingNode, 1000)
				playingNode:setPosition(gt.winCenter)
				playingAni:gotoFrameAndPlay(0, false)
				if aniNames[msgTbl.kId][3] then
					gt.soundEngine:playEffect(aniNames[msgTbl.kId][3], false, true)
				end
				self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function(sender)
					self.btnSender:setVisible(false)
				end)))
				playingAni:setFrameEventCallFunc(function(frameEventName)
				   	local name = frameEventName:getEvent()
				   	gt.log("name======...............",name)
					if name == "_end" then
					   	playingNode:stopAllActions()
					   	playingNode:removeFromParent()
				   	end
				end)
			else
				local feiSpr = cc.Sprite:create("animation/"..aniNames[msgTbl.kId][1])
				if  msgTbl.kId == 4 then 
					feiSpr:setScale(0.7)
					end
					local completeFunc = cc.CallFunc:create(function()
							feiSpr:stopAllActions()
							feiSpr:removeFromParent(true)
							
							local boNode, boAni = gt.createCSAnimation("animation/"..aniNames[msgTbl.kId][2])
							-- boNode:setPosition(cc.p(receiveNodePos.x+x, receiveNodePos.y+y))

							local num = 0 
							if  msgTbl.kId == 2 then 
								num = 10
							end
							if msgTbl.kId == 4 then 
								boNode:setScale(0.7)
							end

							boNode:setPosition(cc.p(receiveNodePos.x+num, receiveNodePos.y))
							self:addChild(boNode, 1000)
							boAni:gotoFrameAndPlay(0, false)
							if aniNames[msgTbl.kId][3] then
								gt.soundEngine:playEffect(aniNames[msgTbl.kId][3], false, true)
							end
							-- boNode:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function(sender)
							-- 	sender:stopAllActions()
							-- 	sender:removeFromParent(true)
							-- end)))
					boAni:setFrameEventCallFunc(function(frameEventName)
					   local name = frameEventName:getEvent()
					   gt.log("name======...............",name)
						if name == "_end" then
						   	boNode:stopAllActions()
						   	boNode:removeFromParent()
					   	end
					end)
						end)
					local time = 0.8
					if receiveRoomPlayer.displaySeatIdx == 2 then
						time = 0.3
					end
					
					-- local moveAni = cc.MoveTo:create(time, cc.p(receiveNodePos.x+x, receiveNodePos.y+y))
					local moveAni = cc.MoveTo:create(time, cc.p(receiveNodePos.x, receiveNodePos.y))
					feiSpr:runAction(cc.Sequence:create(moveAni, completeFunc))
					-- feiAni:gotoFrameAndPlay(0, true)
					self:addChild(feiSpr, 1000)
					-- feiSpr:setPosition(cc.p(sendNodePos.x+x, sendNodePos.y))
					feiSpr:setPosition(cc.p(sendNodePos.x, sendNodePos.y))
			end
		end

	elseif msgTbl.kType == 4 then
		--语音
		--voicelist
		self:startVoiceSchedule(msgTbl)
		
		-- gt.log("暂停音乐 222222")
		-- require("cjson")

		-- local videoTime = 0
		-- local num1,num2 = string.find(msgTbl.kMusicUrl, "\\")
		-- if not num2 or num2 == nil then
		-- 	Toast.showToast(self, "语音文件错误", 2)
		-- 	return
		-- end
		-- local curUrl = string.sub(msgTbl.kMusicUrl,1,num2-1)
		-- videoTime = string.sub(msgTbl.kMusicUrl,num2+1)
		-- gt.log("the play voide url is .." , curUrl)
		-- gt.log("the play voide videoTime is .." , videoTime)



		-- self:getLuaBridge()
		-- if gt.isIOSPlatform() then
		-- 	local ok = self.luaBridge.callStaticMethod("AppController", "playVoice", {voiceUrl = curUrl})
		-- 	self:ShowUserChat1(self:getTableId(msgTbl.kPos),videoTime)
		-- elseif gt.isAndroidPlatform() then
		
		-- 	local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "playVoice", {curUrl}, "(Ljava/lang/String;)V")
		-- 	self:ShowUserChat1(self:getTableId(msgTbl.kPos),videoTime)
		-- end
		
		
	else
		local chatBgNode = self.nodePlayer[self:getTableId(msgTbl.kPos)]
		local _node = self:findNodeByName("player_"..self:getTableId(msgTbl.kPos))
		
		local chatBgNode1 = self:findNodeByName("icon",_node)

		
	
		if msgTbl.kType == gt.ChatType.FIX_MSG then
			--emojiImg:setVisible(false)
			self:ShowUserChat(self:getTableId(msgTbl.kPos),gt.getLocationString("LTKey_00" .. msgTbl.kId+58),msgTbl)
		
		elseif msgTbl.kType == gt.ChatType.INPUT_MSG then
		
			self:ShowUserChat(self:getTableId(msgTbl.kPos),msgTbl.kMsg)
		elseif msgTbl.kType == gt.ChatType.EMOJI then
			gt.log("播放动画表情 =========== ")
			--chatBgImg:setVisible(false)

			if self.animationNode then
				chatBgNode:removeChild(self.animationNode)
			end
			local picStr = string.sub(msgTbl.kMsg,1,10)
			gt.log("EmotionName 111111:" .. picStr)
			if picStr == "biaoqing1." then
				picStr = "biaoqing01"
			elseif picStr == "biaoqing2." then
				picStr = "biaoqing02"
			elseif picStr == "biaoqing3." then
				picStr = "biaoqing03"
			elseif picStr == "biaoqing4." then
				picStr = "biaoqing04"
			elseif picStr == "biaoqing5." then
				picStr = "biaoqing05"
			elseif picStr == "biaoqing6." then
				picStr = "biaoqing06"
			elseif picStr == "biaoqing7." then
				picStr = "biaoqing07"
			elseif picStr == "biaoqing8." then
				picStr = "biaoqing08"
			elseif picStr == "biaoqing9." then
				picStr = "biaoqing09"
			end
			-- local animationStr = "res/animation/biaoqing/"..picStr.."/".. picStr .. ".csb"
			local animationStr = "res/animation/biaoqing/".. picStr .. ".csb"
			gt.log("animationStr===",animationStr)
			local animationNode, animationAction = gt.createCSAnimation(animationStr)
			animationAction:play("run", true)
			self.animationNode = animationNode
			self.animationAction = animationAction
			
			local chat_head_action = self:findNodeByName("chat_head_action_" .. self:getTableId(msgTbl.kPos))
			chat_head_action:stopAllActions()
			chat_head_action:removeAllChildren()
			gt.addNode(chat_head_action,animationNode)
			local chatBgNode_delayTime = cc.DelayTime:create(3)
			local chatBgNode_callFunc = cc.CallFunc:create(function(sender)
				chat_head_action:stopAllActions()
				chat_head_action:removeAllChildren()
			end)
			local chatBgNode_Sequence = cc.Sequence:create(chatBgNode_delayTime,chatBgNode_callFunc)
			chat_head_action:runAction(chatBgNode_Sequence)
		elseif msgTbl.kType == gt.ChatType.VOICE_MSG then
		end

	
	end
end

--voicelist
function ddzScene:startVoiceSchedule(msgTbl)
	if self.voiceList == nil then
		self.voiceList = {}
	end
	table.insert(self.voiceList, {msgTbl, 0})
	gt.log("ddzScene:playVoice")
	gt.dump(self.voiceList)
	if self.voiceListListener == nil then
		self.voiceListListener = gt.scheduler:scheduleScriptFunc(handler(self, self.playVoice), 1, false)
	end
end

--voicelist
function ddzScene:playVoice()

	if self.voiceList ~= nil and #self.voiceList > 0 then
		--语音
		gt.soundEngine:pauseAllSound()
		gt.log("暂停音乐 222222")
		require("cjson")

		local msgTbl = self.voiceList[1][1]
		local status = self.voiceList[1][2]
		if status == 0 then---未播放
			self.voiceList[1][2] = 1----播放中

			local videoTime = 0
			local num1,num2 = string.find(msgTbl.kMusicUrl, "\\")
			if not num2 or num2 == nil then
				Toast.showToast(self, "语音文件错误", 2)
				return
			end
			local curUrl = string.sub(msgTbl.kMusicUrl,1,num2-1)
			videoTime = string.sub(msgTbl.kMusicUrl,num2+1)
			gt.log("the play voide url is .." , curUrl)
			gt.log("the play voide videoTime is .." , videoTime)



			self:getLuaBridge()
			if gt.isIOSPlatform() then
				local ok = self.luaBridge.callStaticMethod("AppController", "playVoice", {voiceUrl = curUrl})
				self:ShowUserChat1(self:getTableId(msgTbl.kPos),videoTime)
			elseif gt.isAndroidPlatform() then
				local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "playVoice", {curUrl}, "(Ljava/lang/String;)V")
				self:ShowUserChat1(self:getTableId(msgTbl.kPos),videoTime)
			end
		end
	end
end

--voicelist
function ddzScene:stopPlayVoice()
	self:getLuaBridge()
	if gt.isIOSPlatform() then
		local ok = self.luaBridge.callStaticMethod("AppController", "stopPlayVoice", {})
	elseif gt.isAndroidPlatform() then
		local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "stopPlayVoice", {curUrl}, "()V")
	end
end

function ddzScene:ShowUserChat1(viewid,time)


	time = tonumber(time) or 30

	self._voice[viewid]:setVisible(true)
	self._voice_node[viewid]:setVisible(true)
	self._voice_nodes[viewid] = cc.CSLoader:createTimeline("yy.csb")
	self._voice_node[viewid]:runAction(self._voice_nodes[viewid])
	self._voice_nodes[viewid]:gotoFrameAndPlay(0,true)
	self._voice[viewid]:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
		if not self.isRecording then
			self._voice_node[viewid]:stopAllActions()
			self._voice_node[viewid]:setVisible(false)
			self._voice[viewid]:setVisible(false)
			--voicelist
			table.remove(self.voiceList, 1)
			if #self.voiceList <= 0 then
				gt.soundEngine:resumeAllSound()
				gt.log("恢复音乐 333333")
			end
		end
	end)))

end

--显示聊天
function ddzScene:ShowUserChat(viewid ,message,msg)
	if message and #message > 0 then
		--self.m_GameChat:showGameChat(false) --设置聊天不可见，要显示私有房的邀请按钮（如果是房卡模式）
		--取消上次
		if self.m_UserChat[viewid] then
			self.m_UserChat[viewid]:stopAllActions()
			self.m_UserChat[viewid]:removeFromParent()
			self.m_UserChat[viewid] = nil
		end

		if msg then
			local _tpye = 10 - msg.kId + 1
			gt.log("_toye_____message",_tpye)
				
			if self.Player[viewid].sex == 1 then 
				self:PlaySound("sound_res/ddz/chat/".._tpye.."_.mp3")
			else
				self:PlaySound("sound_res/ddz/chat/_".._tpye..".mp3")
			end
		end

		--创建label
		local limWidth = 20*12
		local labCountLength = cc.Label:createWithSystemFont(message,"Arial", 20)  
		if labCountLength:getContentSize().width > limWidth then
			self.m_UserChat[viewid] = cc.Label:createWithSystemFont(message,"Arial", 20, cc.size(limWidth, 0))
		else
			self.m_UserChat[viewid] = cc.Label:createWithSystemFont(message,"Arial", 20)
		end
		if self.m_UserChat[viewid] then
			self.m_UserChat[viewid]:setColor(cc.c3b(51,51,51))
		end
		self.m_UserChat[viewid]:addTo(self._node)

		gt.log(viewid)
		if viewid > gt.MY_VIEWID then 

				self.m_UserChat[viewid]:move(ptChat[viewid].x-13 - 15,  ptChat[viewid].y + 3 - 120)
					:setAnchorPoint( cc.p(1, 0.5) )
					:setLocalZOrder(1002)

				
		else
				self.m_UserChat[viewid]:move(  ptChat[viewid].x+13 + 15,  ptChat[viewid].y + 3 - 120)
					:setAnchorPoint( cc.p(0, 0.5) )
					:setLocalZOrder(1002)
		end
		--改变气泡大小
		self.m_UserChatView[viewid]:setContentSize(self.m_UserChat[viewid]:getContentSize().width+20 + 15, self.m_UserChat[viewid]:getContentSize().height+28)
			:setVisible(true)
		--动作
		self.m_UserChat[viewid]:runAction(cc.Sequence:create(
						cc.DelayTime:create(3),
						cc.CallFunc:create(function()
							self.m_UserChatView[viewid]:setVisible(false)
							self.m_UserChat[viewid]:removeFromParent()
							self.m_UserChat[viewid]=nil
						end)
				))
	end
end



function ddzScene:ActionText5(bool)

	log("text5___________",bool)

	self.text5:setVisible(bool)
		if not bool then
			if self.___action then
				_scheduler:unscheduleScriptEntry(self.___action)
				self.___action = nil
			end
		else
			if self.___action then
				_scheduler:unscheduleScriptEntry(self.___action)
				self.___action = nil
			end
			for j = 1 , 6 do self.text5:getChildByName("dian_"..j):setVisible(false)  end
			if self.___action then
				_scheduler:unscheduleScriptEntry(self.___action)
				self.___action = nil
			end
			local i = 0
			self.___action = _scheduler:scheduleScriptFunc(function()
				i = i +1 
				
				if i == 7 then i = 1 for j = 1 , 6 do self.text5:getChildByName("dian_"..j):setVisible(false)  end end
				self.text5:getChildByName("dian_"..i):setVisible(true)
			end,0.5,false)	
		end

end
--清理桌面
function ddzScene:OnResetView()

	-- for i =1 , gt.GAME_PLAYER do
	-- 	self.m_flagReady[i]:setVisible(false)
	-- end
	self.callscore_control:getChildByName("score_btn0"):setEnabled(true)
					self.callscore_control1:getChildByName("score_btn0"):setEnabled(true)
	self:KillGameClock()
	for k,v in pairs(self.m_tabCardCount) do
        v:setString("")
    end

    for i = 1 , 3 do
		self.callscore_control:getChildByName("score_btn"..i):setEnabled(true)
	end

    -- 清理桌面
    self.m_outCardsControl:removeAllChildren()
    -- 庄家叫分
   	-- local node = self:findNodeByName("game_info")
	-- self:findNodeByName("t2",node):setString("叫分:".."0")
	gt.log("num_beishu_1  chongzhi ....num_beishu_1")
	
	self.beishu = 0
	if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then
		self:findNodeByName("num_beishu_1"):setString("倍数:"..self.beishu)
		self:findNodeByName("room_beishu_lbl"):setString("倍数:".. self.beishu)
	else
		self:findNodeByName("num_beishu_1"):setString("叫分:"..self.beishu)
		self:findNodeByName("room_beishu_lbl"):setString("叫分:".. self.beishu)

	end

   	
   	gt.log("0_____________")
   	self.d_card:setVisible(false)
   	self.d_card1:setVisible(false)
	self:findNodeByName("times"):setVisible(true)

    for i = 1, gt.GAME_PLAYER do 
    	local icon = self.nodePlayer[i]:getChildByName("icon")
    	self.m_UserHead[i].maozi:setVisible(false)
    	icon:setVisible(true)
    	self.m_UserHead[i].t_icon:setVisible(false)
    end

       -- 清理手牌
    for k,v in pairs(self.m_tabNodeCards) do
        v:removeAllCards()
        self.m_tabSpAlarm[k]:stopAllActions()
        self.m_tabSpAlarm[k]:setVisible(false)
    end
    self:showX()

    self.spring:stopAllActions()
	self.spring:setVisible(false)
 	self.plane:stopAllActions()
	self.plane:setVisible(false)
	self.rocket:stopAllActions()
	self.rocket:setVisible(false)
	self.bomb:stopAllActions()
	self.bomb:setVisible(false)

	self.sunzi:stopAllActions()
	self.sunzi:setVisible(false)

	self.sandaiyi:stopAllActions()
	self.sandaiyi:setVisible(false)

	self.sidaier:stopAllActions()
	self.sidaier:setVisible(false)

	self.liandui:stopAllActions()
	self.liandui:setVisible(false)

	self.sandaiyidui:setVisible(false)
	self.sandaiyidui:stopAllActions()

	self.sanzhang:setVisible(false)
	self.sanzhang:stopAllActions()

	self.dz_win:stopAllActions()
	self.nm_win:stopAllActions()
	self.dz_win:setVisible(false)
	self.nm_win:setVisible(false)

end

	--按键响应
function ddzScene:OnButtonClickedEvent(tag,ref)
	self:removeRoom_node()
	log("tag..,,,,",tag)
	if tag == BT_EXIT1 then
		self:PlaySound("sound_res/cli.mp3") 
		if not gt.isCreateUserId and not self.gameBegin  then -- and 游戏没开始
			self:exitRoom(false)
		else
			self:exitRoom(true)
		end
	elseif tag == BT_EXIT then 
		self:PlaySound("sound_res/cli.mp3")
		self:exitRoom(self.gameBegin)
	elseif tag == BTN_QUIT then
		self:PlaySound("sound_res/cli.mp3")
		self.result_node:getChildByName("Button_1"):runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.9),cc.ScaleTo:create(0.1,1)))
        self:onExitRoom()
	elseif tag== BT_INVITE then
		self:PlaySound("sound_res/cli.mp3")
		self:shareWx()
	elseif tag == BT_BEGIN then
		self:PlaySound("sound_res/cli.mp3")
		self:onBeginGame()
		self.begin_btn:setVisible(false)
	elseif tag == BT_READY then
		self:PlaySound("sound_res/cli.mp3")
		self:onStartGame()
		self:OnResetView()
	
	elseif tag == BTN_SHARE then
		self:PlaySound("sound_res/cli.mp3")
		self:shareImage()
	elseif tag == BT_LOOKCARD then
		self:_playSound(gt.MY_VIEWID,"kanpai.mp3")
		self.m_LookCard[gt.MY_VIEWID]:setVisible(true) 
		self.btLookCard:setVisible(false)
		self:onLookCard()
	elseif tag == BT_ADDSCORE then
		self:PlaySound("sound_res/cli.mp3")
		self:_addScore()
	elseif tag == BT_COMPARE then
		self:removeActionHuo()
		self:PlaySound("sound_res/cli.mp3")
		self.btCompare:setEnabled(false)
		self:onCompareCard()

	elseif tag == QUXIAO then
		self:PlaySound("sound_res/cli.mp3")
		self:SetCompareCard(false)
	elseif tag == BT_CARDTYPE then
		
	elseif tag == BT_FOLLOW then -- 跟住
		
	elseif tag == BT_CHIP_1 then	
	elseif tag == BT_CHAT then

		--local a = ""..b
		self:PlaySound("sound_res/cli.mp3")
		local chatPanel = require("client/game/majiang/ChatPanel"):create(false,self.data.kPlaytype[5])
		self:addChild(chatPanel, ddzScene.ZOrder.CHAT)
	elseif tag == BT_MENU then
		self:PlaySound("sound_res/cli.mp3")
		self:ShowMenu(not self.m_bShowMenu)
	elseif tag == BT_HELP then
		
	elseif tag == BT_SET then
		
	elseif tag == BT_BANK then

	elseif tag == PROMPT then 
		self:PlaySound("sound_res/cli.mp3")
		self:reSetBankeeCard()
		self:onPromptOut()
	elseif tag == PUSH_CARD then 
		self:PlaySound("sound_res/cli.mp3")
		self:push_card()
	elseif tag == PASS_CARD then --自己不出按钮
		self:PlaySound("sound_res/cli.mp3")
		local m = {}	
		m.kMId = 62102
		m.kSubCmd = 3
		gt.dumplog(m)
	   	gt.socketClient:sendMessage(m)
	   	self.operation:setVisible(false)
	   	self.textnot:setVisible(false)
	   	gt.log("播放不要音效")
	   	self:_playSound(gt.MY_VIEWID,"pass" .. math.random(0, 1) .. ".mp3")
	   	self.m_tabNodeCards[gt.MY_VIEWID]:reSetCards()
	   	self.tmp_card_select = nil

	end

	if tag >= 1000 then 
		for i = 0 , 3 do
			if tag == 1000 + i then
				-- if self.data.kPlaytype[1] ~= 3 then 
				-- 	self:_playSound(gt.MY_VIEWID,"cs"..i..".mp3")
				-- else
				-- 	gt.log("iiiiiiiiii,",i)
				-- 	self:_playSound(gt.MY_VIEWID,"ccs"..i..".mp3")
				-- end
				if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
					self:_playSound(gt.MY_VIEWID,"ccs"..i..".mp3")
				else
					self:_playSound(gt.MY_VIEWID,"cs"..i..".mp3")
				end
				local m = {}
				m.kMId = 62102
				m.kSubCmd = 1
				m.kCallScore = i
				gt.dumplog(m)

				gt.socketClient:sendMessage(m)
				self.callscore_control:setVisible(false)
				self.callscore_control1:setVisible(false)
			end
		end
	end

end


function ddzScene:switch_clock()

	local pos =( self.UsePos + 1 )%3
	self:gameClock(pos)
end

--发送出牌消息 打什么牌
function ddzScene:push_card()
	local sel = self.m_tabNodeCards[gt.MY_VIEWID]:getSelectCards()
	self.xuanzepuke = {}
	self.tmp_card_select = nil
    if #sel == 0 then return end
    self.operation:setVisible(false)
    local vec = self.m_tabNodeCards[gt.MY_VIEWID]:outCard(sel,false)

	local bug = self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:getChildren()
    self:outCardEffect(gt.MY_VIEWID, sel, vec)
    if self.bankerViewId == gt.MY_VIEWID then 
	    for i =  #bug  , 1 ,-1 do 
	    	local bool = false
	    	for x = 1 , #sel do
				if bug[i]:getCardData() == sel[x] then
					bool = true
		  			break
				end
			end
			if not bool then 
				local spr = cc.Sprite:create("ddz/dizhu_i.png")
	    	 	spr:setAnchorPoint(cc.p(1,1))
	    	 	if spr then 
	    	 		bug[i]:addChild(spr)
	    	 		spr:setPosition(cc.p(153,234))
	    	 	end
	    	 	break
			end
		end
	end
	local m = {}	
	m.kMId = 62102
	m.kSubCmd = 2
	m.kCardCount = #sel
	m.kCardData = sel
	gt.dumplog(m)
   	gt.socketClient:sendMessage(m)
   	self:KillGameClock()
       
end


function ddzScene:shareWx() -- 1604788

	self.m_btnInvite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.9),cc.ScaleTo:create(0.1,1)))
	local a = self.data.kPlaytype

	local ruleText = ""

	if a[1] == 1 then 
		ruleText = ruleText .. "经典玩法，"
	elseif a[1] == 2 then 
		ruleText = ruleText .. "带花玩法，"
	elseif a[1] == 3 then 
		ruleText = ruleText .. "临汾玩法，"
	end


	local man = ""
	if a[6] == 3 then 
		man = "，满3人开局"
	elseif a[6] == 6 then 
		man = "，满6人开局"
	end

	if self.data.kFlag == 2 then
		 ruleText = ruleText .. "9局，"
	elseif self.data.kFlag == 3 then 
		ruleText = ruleText .. "18局，"
	elseif self.data.kFlag == 1 then 
		ruleText = ruleText .. "6局，"
	end

	local ptpye = ""
	if a[7] == 1 then 
		ptpye = ",轮流叫地主"
	elseif a[7] == 0 then
		ptpye = ",赢家叫地主"
	end 

	local tipai = ""
	if a[1] ~= 3 then 
		if a[8] == 1 then 
			tipai = ",可踢和回踢"
		end
	end


	local txt = (string.len(self.data.kDeskId) == 6 and "房号：" or "文娱馆桌号：")..(--[[self.data.kPlaytype[1] == 3 and "xxxxxx" or ]]self.data.kDeskId..",")..ruleText.."缺"..self:get_num()

	local tifengding = ""
	if a[1] == 3 and a[10] == 1 then
		tifengding = ",踢和回踢算入封顶"
	end

	ruleText = ruleText .. (a[2] == 2 and "暗牌（开牌后），" or "明牌（开牌后），").. (a[3] == 0 and  "不封顶，" or tostring(a[3]).."炸封顶，")..(a[4].."分场")..(a[5] == 1 and "，斗地主专属防作弊房"or "")..man..ptpye..tipai..tifengding


	if self.data.kGpsLimit == 1 then 
		ruleText = ruleText.."，【相邻位置禁止进入房间】"
	end



    local url = string.format(gt.HTTP_INVITE, gt.nickname, self.Player[gt.MY_VIEWID].url, self.data.kDeskId, (string.len(self.data.kDeskId) == 6 and "房号：" or "文娱馆桌号：")..(--[[self.data.kPlaytype[5] == 1 and "xxxxxx" or ]]self.data.kDeskId).."，斗地主，"..ruleText)
    gt.log(url)
    gt.log(txt)
	Utils.shareURLToHY(url,txt,ruleText,function(ok)
		if ok == 0 then 
		Toast.showToast(self, "分享成功", 2)
		end

		end)


end


-- 效果
-- @param[outViewId]        出牌视图id
-- @param[outCards]         出牌数据
-- @param[vecCards]         扑克精灵
--出牌效果
function ddzScene:outCardEffect(outViewId, outCards, vecCards)

	


	local controlSize = self.m_outCardsControl:getContentSize()
	--- self:compareWithLastCards(outCards, outViewId,self.data.kPlaytype[1])

    -- 移除出牌
    self.m_outCardsControl:removeChildByTag(outViewId)
    local holder = cc.Node:create()
    self.m_outCardsControl:addChild(holder)
    holder:setTag(outViewId)

    local outCount = #outCards
    -- 计算牌型
	local cardType = -1
    local qulaier = {}
    local _ = 0
    local cardTypes = -1 



    qulaier,_ = GameLaiziLogic:GetCardType1(outCards,outCount,self.data.kPlaytype[1])
    local shuang = false
    if #qulaier == 2 and qulaier[1] == 7 and qulaier[2] == 10 and outCount == 8  then 
    	shuang = true
    end
    shuang = false
    for k ,v in pairs(qulaier) do
        cardType = k 
        cardTypes = v
        if shuang then 
        	break
    	end
    end



    if 7 == cardType then --  -- 三带一单
        if outCount > 4 then
            cardType = 6
        end        
    end
    if 8 == cardType then
        if outCount > 5 then
            cardType = 6
        end        
    end

    -- 出牌

    local targetPos = cc.p(0, 0)
    local center = outCount * 0.5
    local scale = 0.5
    holder:setPosition(self.m_tabNodeCards[outViewId]:getPosition())
    if gt.MY_VIEWID == outViewId then
        scale = 0.6
        targetPos = holder:convertToNodeSpace(cc.p(controlSize.width * 0.5, controlSize.height * 0.42))
    elseif 1 == outViewId then
        center = 0
        holder:setAnchorPoint(cc.p(0, 0.5))
        targetPos = holder:convertToNodeSpace(cc.p(controlSize.width * 0.33-130, controlSize.height * 0.58+50))
    elseif 3 == outViewId then
        center = outCount
        holder:setAnchorPoint(cc.p(1, 0.5))
        targetPos = holder:convertToNodeSpace(cc.p(controlSize.width * 0.67+100, controlSize.height * 0.58+50))
    end
    local isAction = true
    for k,v in pairs(vecCards) do
    	isAction = false
        v:retain()
        v:removeFromParent()
        holder:addChild(v)
        v:release()

        v:showCardBack(false)
        local pos = cc.p((k - center) * CardsNode.CARD_X_DIS * scale + targetPos.x, targetPos.y)
        if k == 1 then 
        	if GameLogic.CT_SINGLE == cardType then
		        -- 音效
		        local poker = yl.POKER_VALUE[outCards[1]]
		        log("poker________",poker,cardTypes)
		        if poker == 16 and cardTypes == 18 then 
		        	self:_playSound(outViewId,poker .. ".mp3") 
		        end
		        if nil ~= poker then
		          self:_playSound(outViewId,poker .. ".mp3") 
		        end
		    elseif GameLogic.CT_DOUBLE == cardType then
		        local poker = yl.POKER_VALUE[outCards[2]]

		        if nil ~= poker then
		        	gt.log("sound________________")
		             self:_playSound(outViewId,poker .. "_.mp3") 
		        end
		    else
	            self:_playSound(outViewId, "type" .. cardType .. ".mp3")			 
	        end
	    end
        local moveTo = cc.MoveTo:create(0.2, pos)
        local spa = cc.Spawn:create(moveTo , cc.Sequence:create(cc.ScaleTo:create(0.05, 2),cc.ScaleTo:create(0.15, scale)  ,cc.CallFunc:create(function()


        	end) , cc.DelayTime:create(0.1), cc.CallFunc:create(function()

        		if k == #vecCards then 
			        self:PlaySound("sound_res/ddz/push_card.mp3")
			    end


        	end)   ))
        v:stopAllActions()
        v:runAction(spa)

       if k == #vecCards then 
    	if self.bankerViewId == outViewId then 
    		v:removeAllChildren()	
    	 	local spr = cc.Sprite:create("ddz/dizhu_i.png")
    	 	spr:setAnchorPoint(cc.p(1,1))
    	 	if spr then 
    	 		v:addChild(spr)
    	 		spr:setPosition(cc.p(153,234))
    	 	end
    	end
    	end

    end

    if isAction then return end

    log("## 出牌类型")
    log(cardType)
    log("## 出牌类型")
 	

	self.plane:stopAllActions()
	self.plane:setVisible(false)
	self.rocket:stopAllActions()
	self.rocket:setVisible(false)
	self.bomb:stopAllActions()
	self.bomb:setVisible(false)


	self.sunzi:stopAllActions()
	self.sunzi:setVisible(false)
	self.sandaiyi:stopAllActions()
	self.sandaiyi:setVisible(false)
	self.sidaier:stopAllActions()
	self.sidaier:setVisible(false)
	self.liandui:stopAllActions()
	self.liandui:setVisible(false)
	self.sandaiyidui:setVisible(false)
	self.sandaiyidui:stopAllActions()

	self.sanzhang:setVisible(false)
	self.sanzhang:stopAllActions()

    --if not bool then 
	    -- 牌型音效
	    if GameLogic.CT_SINGLE == cardType then
	        -- 音效
	        -- local poker = yl.POKER_VALUE[outCards[1]]
	        -- if nil ~= poker then
	        --   self:_playSound(outViewId,poker .. ".mp3") 
	        -- end
	    elseif GameLogic.CT_DOUBLE == cardType then

	        -- local poker = yl.POKER_VALUE[outCards[1]]
	        -- if nil ~= poker then
	        --      self:_playSound(outViewId,poker .. "_.mp3") 
	        -- end
	    else
       
         --    -- 音效
         --    if cardType == 5  or cardType == 12 then 
         --    	self:_playSound(outViewId, "type" .. cardType .. ".wav")
         --    else
         --    	self:_playSound(outViewId, "type" .. cardType .. ".mp3")
        	-- end

 			
            if cardType == 3 then 

        		    self.___node = cc.CSLoader:createTimeline("sanzhang.csb")	
			        self.sanzhang:runAction(self.___node)
			        self.sanzhang:setVisible(true)
			        self.___node:gotoFrameAndPlay(0,false)
			        if outViewId == 1 then 
			        	--self.sanzhang:setAnchorPoint(cc.p(0, 0.5))
			        	self.sanzhang:setPosition(actionPos[outViewId])
			        elseif outViewId == 3 then
			        	--self.sanzhang:setAnchorPoint(cc.p(1, 0.5))
			        	self.sanzhang:setPosition(actionPos[outViewId].x-40,actionPos[outViewId].y)
			        else
			         	--self.sanzhang:setAnchorPoint(cc.p(0.5, 0.5))
			        	self.sanzhang:setPosition(actionPos[outViewId])
			        end

        	end

            if cardType == 7 then
            	    self.___node = cc.CSLoader:createTimeline("sandaiyi.csb")	
			        self.sandaiyi:runAction(self.___node)
			        self.sandaiyi:setVisible(true)
			        self.___node:gotoFrameAndPlay(0,false)
			       
			         if outViewId == 1 then 
			        	--self.sidaier:setAnchorPoint(cc.p(0, 0.5))
			        	self.sandaiyi:setPosition(actionPos[outViewId].x+10,actionPos[outViewId].y)
			        elseif outViewId == 3 then
			        	--self.sidaier:setAnchorPoint(cc.p(1, 0.5))
			        	self.sandaiyi:setPosition(actionPos[outViewId].x-45,actionPos[outViewId].y)
			        else
			        	
			        	self.sandaiyi:setPosition(actionPos[outViewId])
			        end
			        
            end

           	if   cardType == 8 then -- 三代一
           			self.___node = cc.CSLoader:createTimeline("sandaiyidui.csb")	
			        self.sandaiyidui:runAction(self.___node)
			        self.sandaiyidui:setVisible(true)
			        self.___node:gotoFrameAndPlay(0,false)
			        if outViewId == 1 then 
			        	self.sandaiyidui:setPosition(actionPos[outViewId].x+30,actionPos[outViewId].y)
			        elseif outViewId == 3 then
			        	self.sandaiyidui:setPosition(actionPos[outViewId].x-60,actionPos[outViewId].y)
			        else
			        	self.sandaiyidui:setPosition(actionPos[outViewId])
			        end
           	end

            if cardType == 9  or cardType == 10 then -- 4 dai 2 
            	    self.___node = cc.CSLoader:createTimeline("sidaier.csb")	
			        self.sidaier:runAction(self.___node)
			        self.sidaier:setVisible(true)
			        self.___node:gotoFrameAndPlay(0,false)
			       
			         if outViewId == 1 then 
			        	self.sidaier:setPosition(actionPos[outViewId].x+30,actionPos[outViewId].y)
			        elseif outViewId == 3 then
			        	self.sidaier:setPosition(actionPos[outViewId].x-90,actionPos[outViewId].y)
			        else
			        	self.sidaier:setPosition(actionPos[outViewId])
			        end
			        self:PlaySound("sound_res/ddz/w/type9.mp3")
            end

            if cardType == 4 then -- 单连类型
            	 self.___node = cc.CSLoader:createTimeline("sunzi.csb")	
			        self.sunzi:runAction(self.___node)
			        self.sunzi:setVisible(true)
			        self.___node:gotoFrameAndPlay(0,false)
			        if outViewId == 1 then 
			        	
			        	self.sunzi:setPosition(actionPos[outViewId].x+(outCount-4)*CardsNode.CARD_X_DIS * scale -10 ,actionPos[outViewId].y)
			        elseif outViewId == 3 then
			        	self.sunzi:setPosition(actionPos[outViewId].x-(outCount-3)*CardsNode.CARD_X_DIS * scale -20 ,actionPos[outViewId].y)
			        else
			        	self.sunzi:setPosition(actionPos[outViewId])
			        end
            end

            if cardType == 5 then -- 对连类型
            		self.___node = cc.CSLoader:createTimeline("liandui.csb")	
			        self.liandui:runAction(self.___node)
			        self.liandui:setVisible(true)
			        self.___node:gotoFrameAndPlay(0,false)
			      
  					if outViewId == 1 then 
			        	self.liandui:setPosition(actionPos[outViewId].x+(outCount-4)*CardsNode.CARD_X_DIS * scale -20 ,actionPos[outViewId].y)
			        elseif outViewId == 3 then
			        	
			        	self.liandui:setPosition(actionPos[outViewId].x-(outCount-4)*CardsNode.CARD_X_DIS * scale -20 ,actionPos[outViewId].y)
			        else
			 
			        	self.liandui:setPosition(actionPos[outViewId])
			        end


            end


	         
	    end

	    	--[[
	
	self.sunzi = self:findNodeByName("sunzi")
    self.sandaiyi = self:findNodeByName("sandaiyi")
    self.sidaier = self:findNodeByName("sidaier")
    self.liandui = self:findNodeByName("liandui")
	
	]]

	   -- self:removeChildByName("__effect_ani_name__")


	    --  self.bomb = self:findNodeByName("bomb")
	    -- self.spring = self:findNodeByName("spring")
	    -- self.rocket = self:findNodeByName("rocket")
	    -- self.plane = self:findNodeByName("plane")
	     
		
	    -- 牌型动画/牌型音效
	    if GameLogic.CT_THREE_LINE == cardType then             -- 飞机
	        -- local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("plane_0.png")
	        --  gt.log("飞机",frame)
	        -- if nil ~= frame then
	        --     local sp = cc.Sprite:createWithSpriteFrame(frame)
	        --     sp:setPosition(yl.WIDTH * 0.5, yl.HEIGHT * 0.5)
	        --     sp:setName("__effect_ani_name__")
	        --     self:addToRootLayer(sp, 100)
	        --     sp:runAction(self.m_actPlaneShoot)
	        -- end
	        self:PlaySound("sound_res/ddz/common_plane.mp3")

	        self.___node = cc.CSLoader:createTimeline("plane.csb")	
	        self.plane:runAction(self.___node)
	        self.plane:setVisible(true)
	        self.___node:gotoFrameAndPlay(0,false)
	    elseif GameLogic.CT_BOMB_CARD == cardType then          -- 炸弹
	        -- local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("game_bomb_01.png")
	        --  gt.log("炸弹",frame)
	        -- if nil ~= frame then
	        --     local sp = cc.Sprite:createWithSpriteFrame(frame)
	        --     sp:setPosition(yl.WIDTH * 0.5, yl.HEIGHT * 0.5)
	        --     sp:setName("__effect_ani_name__")
	        --     self:addToRootLayer(sp, 200)

	        --     sp:runAction(self.m_actBomb)
	        --     -- 音效
	        gt.log("播放炸弹效果")
	        self:PlaySound( "sound_res/ddz/common_bomb.mp3" ) 
	        gt.soundEngine:playMusic_poker("sound_res/ddz/bg_hk.mp3",true)

	        self.huankuai_time = os.time()
	        self.huankuai = true
	        self.___node = cc.CSLoader:createTimeline("bomb.csb")	
	        self.bomb:runAction(self.___node)
	        self.bomb:setVisible(true)
	        self.___node:gotoFrameAndPlay(0,false)



	    elseif GameLogic.CT_MISSILE_CARD == cardType then       -- 火箭

	        -- local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("rocket_0.png")
	        -- gt.log("火箭",frame)
	        -- if nil ~= frame then
	        --     local sp = cc.Sprite:createWithSpriteFrame(frame)
	        --     sp:setPosition(yl.WIDTH * 0.5, yl.HEIGHT * 0.5)
	        --     sp:setName("__effect_ani_name__")
	        --     self:addToRootLayer(sp, 300)
	        --     sp:runAction(self.m_actRocketShoot)
	        -- end



	        self:PlaySound("sound_res/ddz/common_bomb.mp3")
	        gt.soundEngine:playMusic_poker("sound_res/ddz/bg_hk.mp3",true)
	        self.huankuai_time = os.time()
	        self.huankuai = true
	        self.___node = cc.CSLoader:createTimeline("rocket.csb")	
	        self.rocket:runAction(self.___node)
	        self.rocket:setVisible(true)
	        if outViewId == 1 then 
	        	self.rocket:getChildByName("Sprite_4"):setPositionX(-600)
	        elseif outViewId == 2 then 
	        	self.rocket:getChildByName("Sprite_4"):setPositionX(0)
	        elseif outViewId == 3 then 
	        	self.rocket:getChildByName("Sprite_4"):setPositionX(600)
	        end
	        self.___node:gotoFrameAndPlay(0,false)
	    end

	--end

end


-- 扑克对比
-- @param[cards]        当前出牌
-- @param[outView]      出牌视图id
--？？？？？？
function ddzScene:compareWithLastCards( cards, outView,landType)
    self.m_bLastCompareRes = false
    local outCount = #cards
    if outCount > 0 then
        if outView ~= self.m_nLastOutViewId then
            --返回true，表示cards数据大于m_tagLastCards数据
			if landType == 1 then
				self.m_bLastCompareRes = GameLogic:CompareCard(self.m_tabLastCards, #self.m_tabLastCards, cards, outCount)
			elseif landType == 2 then
				self.m_bLastCompareRes = GameLaiziLogic:CompareCard(self.m_tabLastCards, #self.m_tabLastCards, cards, outCount)
			end
            self.m_nLastOutViewId = outView
        end
        self.m_tabLastCards = cards
    end
end



function ddzScene:addToRootLayer( node , zorder)
    if nil == node then
    	gt.log("return______________")
        return
    end
    self:addChild(node)
    if type(zorder) == "number" then
        node:setLocalZOrder(zorder)
    end    
end



function ddzScene:createAnimation()
    local param = self:getAnimationParam()
    param.m_fDelay = 0.1
    -- -- 火箭动画
    -- param.m_strName = "rocket_key"
    -- local animate = self:getAnimate(param)
    -- gt.log("animate______",animate)
    -- if nil ~= animate then
    --     local rep = cc.RepeatForever:create(animate)
    --     self.m_actRocketRepeat = rep
    --     self.m_actRocketRepeat:retain()
    --     local moDown = cc.MoveBy:create(0.1, cc.p(0, -20))
    --     local moBy = cc.MoveBy:create(2.0, cc.p(0, 500))
    --     local fade = cc.FadeOut:create(2.0)
    --     local seq = cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function()
    --         self:PlaySound("sound_res/ddz/common_rocket.mp3")
    --         end), fade)
    --     local spa = cc.Spawn:create(cc.EaseExponentialIn:create(moBy), seq)
    --     self.m_actRocketShoot = cc.Sequence:create(cc.CallFunc:create(function( ref )

    --         ref:runAction(rep)
    --     end), moDown, spa, cc.RemoveSelf:create(true))
    --     self.m_actRocketShoot:retain()
    -- end

    -- 飞机动画    
    param.m_strName = "airship_key"
    local animate = self:getAnimate(param)
    if nil ~= animate then
        local rep = cc.RepeatForever:create(animate)
        self.m_actPlaneRepeat = rep
        self.m_actPlaneRepeat:retain()
        local moTo = cc.MoveTo:create(3.0, cc.p(0, yl.HEIGHT * 0.5))
        local fade = cc.FadeOut:create(1.5)
        local seq = cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
            self:PlaySound("sound_res/ddz/common_plane.mp3")
            end), fade)
        local spa = cc.Spawn:create(moTo, seq)
        self.m_actPlaneShoot = cc.Sequence:create(cc.CallFunc:create(function( ref )
            ref:runAction(rep)
        end), spa, cc.RemoveSelf:create(true))
        self.m_actPlaneShoot:retain()
    end

    -- 炸弹动画
    param.m_strName = "bomb_key"
    local animate = self:getAnimate(param)
    if nil ~= animate then
        
        local fade = cc.FadeOut:create(1.0)
        self.m_actBomb = cc.Sequence:create(animate, fade, cc.RemoveSelf:create(true))
        self.m_actBomb:retain()
    end    

	gt.log("str.....",str)end


--播放音效
function ddzScene:_playSound(id,str)

	self:PlaySound("sound_res/ddz/w/"..str)

	-- if self.Player[id].sex == 2 then
	-- 	self:PlaySound("sound_res/ddz/w/"..str)
	-- else
	-- 	self:PlaySound("sound_res/ddz/m/"..str)
	-- end
end

--服务器广播
function ddzScene:GameData_ddz(msg)

	gt.dump(msg)
	gt.dumplog(msg)
	gt.log("msg.kSubCmd=======",msg.kSubCmd)
	if  msg.kSubCmd == 100 then -- 游戏开始
		self:gameStart(msg)
	elseif msg.kSubCmd ==  101 then 
		self:notice_call_socre(msg) --广播叫分1
	elseif msg.kSubCmd == 102 then 
		self:banker_info(msg) --叫完3分后确定地主   
	elseif msg.kSubCmd == 103 then 
		--将所有语言气泡隐藏
		for i = 1, gt.GAME_PLAYER do
			self._ti[i]:setVisible(false)
		end
		self:notice_push_card(msg) --广播出牌
	elseif msg.kSubCmd == 104 then 
		self:notice_pass(msg) --广播 不出
	elseif msg.kSubCmd == 105 then -- 小结算
		self:result_min(msg)
	elseif msg.kSubCmd == 123 or msg.kSubCmd == 124  or msg.kSubCmd == 125 then --123 
		self:tiPoker(msg) --踢
	elseif msg.kSubCmd == 131 or msg.kSubCmd == 132 or msg.kSubCmd == 133 then 
		self:notice_ti(msg) --广播踢牌结果
	elseif msg.kSubCmd == 126 then 
		self:banker_operation(msg)--广播该谁出牌
	elseif msg.kSubCmd == 130 then 
		gt.log(">?????????>>>>>>>>>>>")
		if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
			-- local node = self:findNodeByName("game_info")
			-- --self._times = msg.kActUser
			-- self:findNodeByName("t2",node):setString("倍数:"..msg.kActUser)
			gt.log("num_beishu_1 pplllllllmsg.kActUser=" ,msg.kActUser )
			self:findNodeByName("num_beishu_1"):setString("倍数:"..msg.kActUser)
			self.beishu = msg.kActUser
		else
			-- self:findNodeByName("num_beishu_1"):setString("叫分:"..msg.kActUser)
			-- self.beishu = msg.kActUser
		end
	end

end
--庄家出牌
function ddzScene:banker_operation(m)

	self:notice_ti()
	if m.kPos == self.UsePos then 
		self:switch_operation(0, 1, 0)
		self:onSelectedCards(self.xuanzepuke)
		self.operation:setVisible(true)
	end
	self:gameClock(m.kPos)
end
--广播踢牌  气泡
function ddzScene:notice_ti(m)
	if not m then 
		-- for i = 1, gt.GAME_PLAYER do
		-- 	self._ti[i]:setVisible(false)
		-- end
	else
		local id = self:getTableId(m.kActUser)
		gt.log("走了这会提示不回，和回踢 id=",id)
		gt.log("m.kActSelect=",m.kActSelect)
		gt.log("m.kSubCmd====",m.kSubCmd)
		local img_res = ""
		if id <= 2 then
			img_res = "res/ddz/l"..m.kActSelect..m.kSubCmd..".png"
		else
			img_res = "res/ddz/r"..m.kActSelect..m.kSubCmd..".png"
		end
		gt.log("img_res=======",img_res)
		-- self._ti[id]:loadTexture(id <= 2 and "res/ddz/l"..m.kActSelect..m.kSubCmd..".png" or "res/ddz/r"..m.kActSelect..m.kSubCmd..".png")
		if img_res ~= "" then
			gt.log("111111111  showid======",id)
			gt.log("11111111111111img_res===",img_res)
			self._ti[id]:loadTexture(img_res)
			self._ti[id]:setVisible(true)
			--地主不回，回踢的气泡没显示
			if id == 2 and img_res ~= "" then
				self.tmpPaoImage = img_res
				gt.log("self.tmpPaoImage///==============",self.tmpPaoImage)
			end
		end
		if m.kActUser ~= self.UsePos then 
			if m.kActSelect == 1 then 
				if m.kSubCmd == 131 then 
						 self:_playSound(id,"t1.mp3")
						 self.m_UserHead[id].t_icon:loadTexture("ddz/ttt.png")
						 self.m_UserHead[id].t_icon:setVisible(true)
						-- if self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)) then
						if self._node:getChildByName("wanjia_" .. id) then
					  		local ani_id = self._node:getChildByName("wanjia_" .. id):getTag() - 1000
					  		gt.log("ani_id======",ani_id)
						  	if tonumber(ani_id) > 0 then
						  		self.playingNode[ani_id]:getChildByName("Image_1"):setVisible(true)
						  		self.playingNode[ani_id]:getChildByName("Image_1"):loadTexture("ddz/ttt.png")
						  	end
						  end
	    		elseif m.kSubCmd == 132 then 
						 self:_playSound(id,"t2.mp3")
						 self.m_UserHead[id].t_icon:loadTexture("ddz/ttt.png")
						 self.m_UserHead[id].t_icon:setVisible(true)
						-- if self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)) then
						if self._node:getChildByName("wanjia_" .. id) then
					  		local ani_id = self._node:getChildByName("wanjia_" .. id):getTag() - 1000
					  		gt.log("ani_id======",ani_id)
						  	if tonumber(ani_id) > 0 then
						  		self.playingNode[ani_id]:getChildByName("Image_1"):setVisible(true)
						  		self.playingNode[ani_id]:getChildByName("Image_1"):loadTexture("ddz/ttt.png")
						  	end
					  	end
	    		elseif m.kSubCmd == 133 then 
						 self:_playSound(id,"t3.mp3")
						 self.m_UserHead[id].t_icon:loadTexture("ddz/hhh.png")
						 self.m_UserHead[id].t_icon:setVisible(true)
						-- if self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)) then
						if self._node:getChildByName("wanjia_" .. id) then
					  		local ani_id = self._node:getChildByName("wanjia_" .. id):getTag() - 1000
					  		gt.log("ani_id======",ani_id)
						  	if tonumber(ani_id) > 0 then
						  		self.playingNode[ani_id]:getChildByName("Image_1"):setVisible(true)
						  		self.playingNode[ani_id]:getChildByName("Image_1"):loadTexture("ddz/hhh.png")
					  		end
					  	end
	    		end
	    	else
	    		if m.kSubCmd == 133 then 
    		 		self:_playSound(id,"t5.mp3")
	    		elseif m.kSubCmd == 131 or m.kSubCmd == 132 then 
	    		 	self:_playSound(id,"t4.mp3")
	    		end
	    	end
		end
	end
	--处理地主不回与回踢气泡显示
	self:dizhuQiPao(2)
	--重置自己的牌
	gt.log("???????>..................")
	self.m_tabNodeCards[gt.MY_VIEWID]:reSetCards()
end
--显示踢牌按钮
function ddzScene:tiPoker(m)

	if not m then return end

	log("vvvvvvv",type(m))

	-- if type(m) ~= "table" then 
	-- 	self.ti_type = m
	-- 	self.ti_btn:setVisible(true)
	-- 	self.ti_btn:getChildByName("t_t"):loadTexture("ddz/bt_"..m..".png")
	-- 	self.ti_btn:getChildByName("not_t"):loadTexture(m == 125 and "ddz/not_t1.png" or "ddz/not_t.png")
	-- 	return
	-- end

	if not m.kpos then 
		self.ti_type = m.kSubCmd
		self.ti_btn:setVisible(true)
		self.ti_btn:getChildByName("t_t"):loadTexture("ddz/bt_"..m.kSubCmd..".png")
		self.ti_btn:getChildByName("not_t"):loadTexture(m.kSubCmd == 125 and "ddz/not_t1.png" or "ddz/not_t.png")
	else
		self:gameClock(m.kpos)
		if m.kpos == self.UsePos then 
			self.ti_type = m.kSubCmd
			self.ti_btn:setVisible(true)
			self.ti_btn:getChildByName("t_t"):loadTexture("ddz/bt_"..m.kSubCmd..".png")
			self.ti_btn:getChildByName("not_t"):loadTexture(m.kSubCmd == 125 and "ddz/not_t1.png" or "ddz/not_t.png")
		end
	end
end
--广播谁不出
function ddzScene:notice_pass(m)
	log("pass_____________")
	local curView = self:SwitchViewChairID(m.kCurrentUser)
    local passView = self:SwitchViewChairID(m.kPassCardUser)
 --   self:compareWithLastCards({}, curView,self.data.kPlaytype[1])
    if passView == gt.MY_VIEWID then 	self.operation:setVisible(false) self.textnot:setVisible(false) end
   	local landType = self.data.kPlaytype[1]
   	self:onGetPassCard(m.kPassCardUser)
   	-- -- 设置倒计时
    self:gameClock(m.kCurrentUser)
    if 1 == m.kTurnOver then

        if m.kCurrentUser == self.UsePos then
	        local handCards = self.m_tabNodeCards[gt.MY_VIEWID]:getHandCards()
	        self:updatePromptList({}, handCards, curView, curView,landType)
	          -- 移除上轮出牌
		    self.m_outCardsControl:removeChildByTag(gt.MY_VIEWID)
		    self.operation:setVisible(true)
		    --xyc去除自动出牌
		    self:auto_push_card(self.m_tabPromptList)
		    self:switch_operation(0, 1, 0)
		    self:showX()
		    self.m_outCardsControl:removeChildByTag(1)
           	self.m_outCardsControl:removeChildByTag(3)
		    self:onSelectedCards(self.xuanzepuke)
	    end
	       
    else
    	gt.log("自己出牌")
    		   -- 自己出牌
	    if m.kCurrentUser == self.UsePos then 
            -- 移除上轮出牌
            self.m_outCardsControl:removeChildByTag(gt.MY_VIEWID)
            self.operation:setVisible(true)
            if m.kCurrentUser ~= m.kPassCardUser  then
               local promptList = self.m_tabPromptList
               gt.log("######",#promptList)
               if #promptList == 0 then
                    self:switch_operation(1, 0, 0)
                    self.textnot:setVisible(true)
               else
               		-- self:auto_push_card(promptList)
               	 --    self:switch_operation(1, 1, 0)
               		self:auto_push_card(promptList)
               	    self:switch_operation(1, 1, 0)
               	 --   self:onPromptOut()
               end
           
            end

            self:onSelectedCards(self.xuanzepuke)
          
	    end


    end
    -- 不出牌
    --自己不出牌控制
	if m.kPassCardUser == self.UsePos then
		self:showX()
		--上面已经给提示不出了，这个不出音效屏蔽
		-- self:_playSound(self:SwitchViewChairID(passViewId),"pass" .. math.random(0, 1) .. ".mp3")
		self:showX(self.UsePos,4)
	end
end

-- 用户pass
-- @param[passViewId]       放弃视图id
--显示不出文字--并播放音效
function ddzScene:onGetPassCard( passViewId )
    if self:SwitchViewChairID(passViewId) ~= gt.MY_VIEWID then
      	self:_playSound(self:SwitchViewChairID(passViewId),"pass" .. math.random(0, 1) .. ".mp3")
        self:showX(passViewId,4)       
    end
    self.m_outCardsControl:removeChildByTag(self:SwitchViewChairID(passViewId))


end
--广播叫分1，2，3分
function ddzScene:notice_call_socre(m)


	gt.log("userpos......",self.UsePos)
	self:gameClock(m.kCurrentUser)
	if m.kCurrentUser == self.UsePos and m.kUserCallScore ~= 3  then 
		if self.data.kPlaytype[1] ~= 3   then 
			self.callscore_control:setVisible(true)
			if m.kUserCallScore ~= 0 then 
				for i = 1 , 3 do
					if i <= m.kUserCallScore then 
						self.callscore_control:getChildByName("score_btn"..i):setEnabled(false)
					else
						self.callscore_control:getChildByName("score_btn"..i):setEnabled(true)
					end
				end
			end
			
		else
			self.callscore_control1:setVisible(true)
		end

		if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
			self.callscore_control1:setVisible(true)
			self.callscore_control:setVisible(false)
		else
			self.callscore_control1:setVisible(false)
			self.callscore_control:setVisible(true)
		end

		if m.kOnlyCall == 1 then 
			self.callscore_control:getChildByName("score_btn0"):setEnabled(false)
			self.callscore_control1:getChildByName("score_btn0"):setEnabled(false)
		end

	end
	if m.kCallScoreUser ~= self.UsePos  then 
		if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
			
			self:_playSound(self:SwitchViewChairID(m.kCallScoreUser),"ccs"..m.kCurrentScore..".mp3")
		else
			self:_playSound(self:SwitchViewChairID(m.kCallScoreUser),"cs"..m.kCurrentScore..".mp3")
		end
	end
	self:showX(m.kCallScoreUser,m.kCurrentScore)

end
--广播出牌
function ddzScene:notice_push_card(m)


 	local tmp = {}
    for i = 1 , m.kCardCount do
    	table.insert(tmp,m.kCardData[i])
    end
	
 	 -- 构造提示
    local handCards = self.m_tabNodeCards[gt.MY_VIEWID]:getHandCards()
    self:updatePromptList(tmp, handCards, self:getTableId(m.kOutCardUser), gt.MY_VIEWID,self.data.kPlaytype[1])
    self:gameClock(m.kCurrentUser)
    -- 自己出牌
    if m.kCurrentUser == self.UsePos then

        -- 移除上轮出牌
        self.m_outCardsControl:removeChildByTag(self:getTableId(m.kCurrentUser))
        self.operation:setVisible(true)

        if m.kCurrentUser ~= m.kOutCardUser  then
           local promptList = self.m_tabPromptList
           if #promptList == 0 then
               self:switch_operation(1, 0, 0)
               gt.log("没有能大过的牌————————————")
               self.textnot:setVisible(true)
           else
           	   --xyc去除自动出牌
           	   self:auto_push_card(promptList)
           	   self:switch_operation(1, 1, 0)
           	  -- self:onPromptOut()
           end
        else -- 自己出牌
        	--xyc去除自动出牌
        	self:auto_push_card(self.m_tabPromptList) --- csw
           	self:switch_operation(0, 1, 0)
           	self:showX()
           	self.m_outCardsControl:removeChildByTag(1)
           	self.m_outCardsControl:removeChildByTag(3)
           --	gt.soundEngine:playMusic_poker("sound_res/ddz/bg_zc.wav",true)
        end
        self:onSelectedCards(self.xuanzepuke)
   
    end

    -- 出牌消息
    if m.kOutCardUser ~= self.UsePos and #tmp > 0 then
        local vec = self.m_tabNodeCards[self:getTableId(m.kOutCardUser)]:outCard(tmp,false)
        self:outCardEffect(self:getTableId(m.kOutCardUser), tmp, vec)
    end

end
--自动出牌
function ddzScene:auto_push_card(promptList)

	-- log("promptList",#promptList)
	-- gt.dump(promptList)
	-- --if (#promptList == 1 or #promptList == 3) and #self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:getChildren() == 2 then 
	-- local card = self.m_tabNodeCards[gt.MY_VIEWID]:getHandCards()
	-- if #card == 2 then 
	-- 	if GameLaiziLogic:Verification_missile(card) then 
	-- 		self.m_tabNodeCards[gt.MY_VIEWID]:suggestShootCards(promptList[1])
	-- 		self:push_card()
	-- 	end
	-- end

end
--取消闹钟
function ddzScene:KillGameClock()
	if self._time then
        _scheduler:unscheduleScriptEntry(self._time)
        self._time = nil
    end

    for i = 1 ,gt.GAME_PLAYER do
    	self._clock[i]:stopAllActions()
       	self._clock[i]:setVisible(false)
    end

end

--显示地主不回与回踢气泡
function ddzScene:dizhuQiPao( id )
	-- if id == 2 and self.tmpPaoImage ~= "" then
	-- 	self._ti[id]:loadTexture(img_res)
	-- 	self._ti[id]:setVisible(true)
	-- end
	-- gt.log("showQipaoTishi  self.tmpPaoImage=",self.tmpPaoImage)

	-- if self.tmpPaoImage == "" then
	-- 	self._ti[id]:setVisible(false)
	-- else
	-- 	-- self.call_score[id]:setVisible(false)
	-- 	-- self.call_score[id]:loadTexture(self.tmpPaoImage)
	-- 	-- self.tmpPaoImage = ""


	-- end
end

--游戏闹钟
function ddzScene:gameClock(id, time)
	time = time or TIME
	gt.log("id===" , id)
	if not id then return end
	local i = self:getTableId(id)
	if i == 21 then return end

	if not self._clock[i] then return end
	self._clock[i]:stopAllActions()
	self._clock[i]:setRotation(0)
	self.call_score[i]:setVisible(false)
	gt.log("clock....",id,i)
	self:KillGameClock()
	self._clock[i]:getChildByName("time"):setString(time)
	self._clock[i]:setVisible(true)
	self._time = _scheduler:scheduleScriptFunc(function()
		time = time - 1
		self._clock[i]:getChildByName("time"):setString(time)
		if time == 2 then 
			
			self:PlaySound("sound_res/ddz/clock.mp3")
			self._clock[i]:runAction( cc.RepeatForever:create( cc.Sequence:create(cc.RotateTo:create(0.01,10),cc.RotateTo:create(0.01,0),cc.RotateTo:create(0.01,-10),cc.RotateTo:create(0.01,0))))

		end
		if time <= 0 then 
			time = 0
			if self._time then
		        _scheduler:unscheduleScriptEntry(self._time)
		        self._time = nil
		    end
		    self._clock[i]:getChildByName("time"):setString(time)
		end
	end,1,false)
	for j=1,gt.GAME_PLAYER do
		gt.log("j=======",j)
		--其他玩家为待机状态
		local ani_id = -100
		if self._node:getChildByName("wanjia_" .. j) then
		  ani_id = self._node:getChildByName("wanjia_" .. j):getTag() - 1000
		  if tonumber(ani_id) > 0 then
		  	self:setPlayerAction(ani_id ,"run_daiji_action")
		  end
		end
		if i == j then
			-- local ani_id = self:getChildByName("wanjia" .. j):getTag() - 100
			gt.log("此时变为思考状态  i ===",i)
			--此时变为思考状态
			if self._node:getChildByName("wanjia_" .. i) then
		  		ani_id = self._node:getChildByName("wanjia_" .. i):getTag() - 1000
		  		gt.log("ani_id======",ani_id)
			  	if tonumber(ani_id) > 0 then
					self:setPlayerAction(ani_id ,"run_sikao_action")
			 	end
			end
		end
	end
	-- if id == 2 and self.tmpPaoImage ~= "" then
	-- 	self.tmpPaoImage = ""
	-- 	self._ti[id]:setVisible(false)
	-- end

end



function ddzScene:showX(id,_type)

	gt.log("xxxxxxx",id)
	if not id then 
		for i = 1, gt.GAME_PLAYER do
			local node = self.call_score[i]
			node:setVisible(false)
			--node:setScaleX(1.5)
		end
	else
		local node = self.call_score[self:getTableId(id)]
		if node then 
			node:setVisible(true)
			gt.log("_type================",_type)
			gt.log("image====","ddz/x".._type.."0.png")
			-- if  self.data.kPlaytype[8] and  self.data.kPlaytype[8] == 1 and _type == 0 then 
			-- 	node:loadTexture("ddz/x".._type.."0.png")
			-- else
			-- 	node:loadTexture("ddz/x".._type..".png")
			-- end
			gt.log("self.data.kPlaytype[8]=======" , self.data.kPlaytype[8])
			gt.log("self:getTableId(id)=",self:getTableId(id))
			gt.log("id=",id)
			if  self.data.kPlaytype[8] and  self.data.kPlaytype[8] == 1 and _type == 0 then 
				gt.log("11111111111self:getTableId(id)----------------===========",self:getTableId(id))
				if self:getTableId(id) == 3 then
					node:loadTexture("ddz/x".._type.."0_r.png")
					gt.log("右。。。。。。。111111111111111。。。。。。。")
				else
					node:loadTexture("ddz/x".._type.."0_l.png")
					gt.log("左。。。。。。。111111111111111。。。。。。。。")
				end
			else
				gt.log("2222222222222self:getTableId(id)----------------===========",self:getTableId(id))
				if self:getTableId(id) == 3 then
					node:loadTexture("ddz/x".._type.."_r.png")
					gt.log("右。。。。。。。22222222222222222。。。。。。。")
				else
					node:loadTexture("ddz/x".._type.."_l.png")
					gt.log("左。。。。。。。22222222222222222。。。。。。。")
				end
			end
		end
	end
end

-- function ddzScene:Foreground()

	

-- end




--庄家信息
function ddzScene:banker_info(m)

	--if self.start_action then self.msg_banker = m return end

	self.callscore_control:setVisible(false)
	self.callscore_control1:setVisible(false)
	for i = 1 , gt.GAME_PLAYER do
		gt.log("i.....",i)
		local id = self:getTableId(i-1)
		gt.log(id)
		self.nodePlayer[id]:setVisible(false)
		local player_action = self:findNodeByName("player_action_" .. id)
		local action_icon = player_action:getChildByName("action_" .. id)
		player_action:setVisible(true)
		player_action:getChildByName("score"):setString(self.tallScore[id])
		-- self.m_UserHead[id].maozi:setVisible(true)
		local playingNode, playingAni = gt.createCSAnimation("res/animation/bianshen_action/bianshen_action.csb")
		playingAni:play("run_action", false)
		  -- action_icon:addChild(playingNode)
		 gt.log("jfkjdifjeijfiejieji")
		gt.addNode(action_icon,playingNode)
		if (i-1) == m.kBankerUser then 
			-- self.m_UserHead[id].maozi:loadTexture("ddz/dizhu_m.png")
			-- local action_icon = self.nodePlayer[id]:getChildByName("action_" .. id)
			gt.log("show  iiiiiid=======" , id)
			playingAni:setFrameEventCallFunc(function(frameEventName)
			   local name = frameEventName:getEvent()
			   gt.log("name======",name)
			   if name == "start_renwu" then
			   			   		gt.log("走了startrenwu.....")

			    	self.playingNode[3]:setVisible(true)
			    	-- self.playingNode[3]:setPosition(self:findNodeByName("chat_head_action_" .. id):getPosition())
			    	-- local pos =cc.p(0,0)
			    	local posX = self:findNodeByName("chat_head_action_" .. id):getPositionX()
			    	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY()
			    	if id == 3 then
			    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() + 100
			    	else
			    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() - 100
				    	-- if viewId == 2 then
			    		-- 	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY() + 20
			    		-- end
			    	end
			    				    	gt.log("333posX=========",posX)
			    				    	gt.log("333posY=========",posY)

			    	self.playingNode[3]:setPosition(cc.p(posX,posY))
			    	self.playingAni[3]:play("run_daiji_action", true)
			    	self.playingNode[3]:setName("wanjia_" .. id)
                    --玩家昵称
			    	--self.playingNode[3]:getChildByName("name"):setString(gt.checkName(self.Player[id].name,3))
			    	self.playingNode[3]:getChildByName("name"):setString(self.Player[id].name)
                    
			   end
				  if name == "_end" then
				   	playingNode:stopAllActions()
				   	playingNode:removeFromParent()
			   	end
			  end)
		else
		  	playingAni:setFrameEventCallFunc(function(frameEventName)
		   	local name = frameEventName:getEvent()
		   	gt.log("show  111111111id=======" , id)
		   	gt.log("name======",name)
		   	if name == "start_renwu" then
		   		if id == 1 or (self:SwitchViewChairID(m.kBankerUser) == 1 and id == 2) then
		   			self.playingNode[1]:setVisible(true)
			    	-- self.playingNode[1]:setPosition(self:findNodeByName("chat_head_action_" .. id):getPosition())
					local posX = self:findNodeByName("chat_head_action_" .. id):getPositionX()
			    	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY()
			    	if id == 3 then
			    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() + 100
			    	else
			    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() - 100
			    		-- if viewId == 2 then
			    		-- 	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY() + 20
			    		-- end
			    	end
			    				    				    	gt.log("1111posX=========",posX)
			    				    	gt.log("111posY=========",posY)
			    	self.playingNode[1]:setPosition(cc.p(posX,posY))
			    	self.playingAni[1]:play("run_daiji_action", true)
			    	self.playingNode[1]:setName( "wanjia_" .. id)
			    	-- self.playingNode[1]:getChildByName("name"):setString(self.Player[id].name)



			  --   	local player_action = self:findNodeByName("player_action_" .. id)
					-- player_action:setVisible(true)
					-- player_action:getChildByName("score"):setString(self.tallScore[id])
					-- player_action:getChildByName("name"):setString(self.Player[id].name)
			    				-- self:findNodeByName("player_action_" .. pos):getChildByName("score"):setString(msg.kScore[i])
			    else
			    	self.playingNode[2]:setVisible(true)
			    	-- self.playingNode[2]:setPosition(self:findNodeByName("chat_head_action_" .. id):getPosition())
					local posX = self:findNodeByName("chat_head_action_" .. id):getPositionX()
			    	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY()
			    	if id == 3 then
			    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() + 100
			    	else
			    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() - 100
			      --  		if viewId == 2 then
			    		-- 	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY() + 20
			    		-- end
			    	end
			    	self.playingNode[2]:setPosition(cc.p(posX,posY))
			    	self.playingAni[2]:play("run_daiji_action", true)
			    	self.playingNode[2]:setName( "wanjia_" .. id)
			    	-- self.playingNode[2]:getChildByName("name"):setString(self.Player[id].name)
		   		end
		   	end
		   	if name == "_end" then
			   	playingNode:stopAllActions()
			   	playingNode:removeFromParent()
		   	end
			end)
		end

	   	local player_action = self:findNodeByName("player_action_" .. id)
		player_action:setVisible(true)
		player_action:getChildByName("score"):setString(self.tallScore[id])
        --玩家昵称
		--player_action:getChildByName("name"):setString(gt.checkName(self.Player[id].name,3))
		player_action:getChildByName("name"):setString(self.Player[id].name)
	end
	if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
		self:findNodeByName("num_beishu_1"):setString("倍数:"..m.kBankerScore)
		self.beishu = m.kBankerScore
	else
		-- local node = self:findNodeByName("game_info")
		-- self:findNodeByName("t2",node):setString("叫分:"..m.kBankerScore)
		self:findNodeByName("num_beishu_1"):setString("叫分:"..m.kBankerScore)
		self.beishu = m.kBankerScore
	end


	self:showX()
	-- self.d_card:setVisible(gt.di_card == 3)
	-- self.d_card1:setVisible(gt.di_card == 4)
	self.card_banker_data = {}
	self.card_banker_Sp = {}
	if self.d_card:isVisible() or self.d_card1:isVisible() then
		self:findNodeByName("times"):setVisible(false)
	end
	gt.actionTouch = false
	self:showThreeCardAction(m.kBankerCard)

	for i=1,#self.card_banker_Sp do
		self.card_banker_Sp:setScale(3)
	end
	-- local times = 1.5
	-- gt.log("..............玩法：")
	-- if self.data.kPlaytype[1] == 1 then 
	-- 	gt.log("经典玩法")
 --    	times = 0.5
 --    elseif self.data.kPlaytype[1] == 2 then 
	-- 	gt.log("带花玩法")
 --    	times = 1.5
 --    elseif self.data.kPlaytype[1] == 3 then 
	-- 	gt.log("临汾玩法")
 --    	times = 1.5
 --    end
	-- if self.data.kPlaytype[1] == 2 then
	-- 	times = 1.5
	-- else
	-- end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
				local bankerViewId = self:getTableId(m.kBankerUser)
				self.bankerViewId = bankerViewId
				  -- 庄家增加牌
				self.isReset = false
			    local handCards = self.m_tabNodeCards[bankerViewId]:getHandCards()
			    local count = #handCards
			    local tmp = {}
			    if bankerViewId == gt.MY_VIEWID then
			      
					for i = 1, gt.di_card do
						handCards[count + i] = m.kBankerCard[i]
						tmp[i] = m.kBankerCard[i]
						log("bankercardDta+.............",m.kBankerCard[i])
					end
					handCards = GameLogic:SortCardList(handCards, gt.card_num_max, 0)
					self.m_tabNodeCards[bankerViewId]:addCards(tmp, handCards,true)


			    else
			    	for i = 1, gt.di_card do
						handCards[count + i] = 0
						tmp[i] = 0
					end
					self.m_tabNodeCards[bankerViewId]:addCards(tmp, handCards)
			    end
			    if bankerViewId == gt.MY_VIEWID then
			    	local bug = self.m_tabNodeCards[bankerViewId].m_cardsHolder:getChildren()
			    	local tmp = 0
			    	local idx = 0 
			    	for i =  1  , #bug do 
			    		log("crad___data.............",bug[i]:getLocalZOrder(),bug[i]:getCardData())
			    		if bug[i]:getLocalZOrder()  > tmp then
			    			tmp = bug[i]:getLocalZOrder()
			    			idx = i 
			    		end

			    	end

					local spr = cc.Sprite:create("ddz/dizhu_i.png")
				 	spr:setAnchorPoint(cc.p(1,1))
				 	if spr then 
				 		bug[idx]:addChild(spr)
				 		spr:setPosition(cc.p(153,234))
				 	end

			    	local handCards = self.m_tabNodeCards[bankerViewId]:getHandCards()
			        self:updatePromptList({}, handCards, gt.MY_VIEWID, self.data.kPlaytype[1]) --ABC
			    
			    end
			    -- 设置倒计时
			   -- self:SetGameClock(cmd_table.wBankerUser, cmd.TAG_COUNTDOWN_OUTCARD, cmd.COUNTDOWN_HANDOUTTIME)
			   	if  self.data.kPlaytype[1] ~= 3  then 
			   		if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then return end
				    self:findNodeByName("addcardRun"):runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
					    self:gameClock(m.kCurrentUser)
					    if self.UsePos == m.kCurrentUser then 
					    	self.operation:setVisible(true)
					    	self:switch_operation(0, 1, 0)
						end
				    	end)))
				end
	    	end),cc.DelayTime:create(1),cc.CallFunc:create(function ()
	    		gt.actionTouch = true
	    	end)))
end
--三张牌复位
function ddzScene:reSetBankeeCard()

	if self.bankerViewId ~= gt.MY_VIEWID  or  self.isReset or #self.card_banker_data == 0 then return end
		log("reset_____________")
		
		local buf = self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:getChildren()
		for i = 1 , #buf do
			for j = 1 , #self.card_banker_data do
				if buf[i]:getCardData() == self.card_banker_data[j] then
					buf[i]:setPositionY(0)
					self.isReset = true
				end
			end
		end

		if self.isReset then
			self.card_banker_data = {}
			self.m_tabNodeCards[gt.MY_VIEWID]:reSetCards()
			self.xuanzepuke = {}
		end

end

-- 翻牌动画
function ddzScene:flopAnimation( node, image, callback )
	local function FlipSpriteComplete()
		if callback then
			callback()
		end
	end

	local function FlipSpriteCallback()
		--node:setTexture(image)
		node:loadTexture(image)
	    local action = CCOrbitCamera:create(0.1, 1, 0, 270, 90, 0, 0)
	    node:runAction(cc.Sequence:create(action, cc.CallFunc:create(FlipSpriteComplete)))
	end

	if image == "poker/56.png" then
		return
	end

    local action = CCOrbitCamera:create(0.1, 1, 0, 0, 90, 0, 0)
    local callback = FlipSpriteCallback
    node:runAction(cc.Sequence:create(action, cc.CallFunc:create(FlipSpriteCallback)))
end

-- 提示出牌

function ddzScene:onPromptOut(  ) -- tishi
 	
          if 0 >= self.m_promptIdx then
              self.m_promptIdx = #self.m_tabPromptList   -- 提示数组
          end
          if 0 ~= self.m_promptIdx then
                -- 提示回位
                local sel = self.m_tabNodeCards[gt.MY_VIEWID]:getSelectCards() -- 选择的扑克
                if #sel > 0 
                    and self.m_tabNodeCards[gt.MY_VIEWID].m_bSuggested
                    and #self.m_tabPromptList > 1 then
                   	gt.dump(sel)
                    self.m_tabNodeCards[gt.MY_VIEWID]:suggestShootCards(sel)
                end
                -- 提示扑克
                local prompt = self.m_tabPromptList
              
                if #prompt > 0 then
                    gt.dump(prompt[self.m_promptIdx])
                    self.m_tabNodeCards[gt.MY_VIEWID]:suggestShootCards(prompt[self.m_promptIdx])
                else
                   -- self:onPassOutCard(2)
                end
                self.m_promptIdx = self.m_promptIdx - 1
           else
               -- self:onPassOutCard(2)
           end
   
end



function ddzScene:onPassOutCard( num )

end



-- 刷新提示列表
-- @param[cards]        出牌数据
-- @param[handCards]    手牌数据
-- @param[outViewId]    出牌视图id
-- @param[curViewId]    当前视图id
--提示按钮出牌（提示牌数组）提示按钮相应
function ddzScene:updatePromptList(cards, handCards, outViewId, curViewId,landType) -- dnf
    self.m_tabCurrentCards = cards
    self.m_tabPromptList = {} -- 提示数组

    local result = {}
    if outViewId == curViewId then
        self.m_tabCurrentCards = {}
        result = GameLaiziLogic:getMaxCardType1(handCards,{},landType)
        --self:switch_operation(nil, 1, nil)
    else
        result = GameLaiziLogic:getMaxCardType1(handCards,cards,landType)
       -- self:switch_operation(nil, 1, nil)
    end

    log("提示1.。。。。。。。。。",#result)
    self.m_tabPromptList = result
    self.m_promptIdx = 0
end



--选择的牌 运算 按钮是否可出牌
function ddzScene:onSelectedCards(selectCards,bool)
	self:removeRoom_node()
	bool = bool or false
	self.xuanzepuke =selectCards

	gt.log("xuanzepuke____________s")
	gt.dump(self.xuanzepuke)
	local a = selectCards

    local outCards = self.m_tabCurrentCards  -- 但前出牌
    local outCount = #outCards
   
    local selectCount = #selectCards
	local selectType = -1
    local cardsNum = 1

    local cardNum = self.m_tabNodeCards[gt.MY_VIEWID]:getcardsCount() -- 玩家剩余牌的数量

    gt.log("type...........",self.data.kPlaytype[1])
    if self.data.kPlaytype[1] == 3 then 

	    if cardNum  then
	    	
	        selectType,cardsNum = GameLaiziLogic:GetCardType1(selectCards,cardNum,self.data.kPlaytype[1])   
	    end
	else
		if #selectCards ~= 1 then 
			if cardNum  and cardNum >= #selectCards then
		        selectType,cardsNum = GameLaiziLogic:GetCardType1(selectCards,#selectCards,self.data.kPlaytype[1])   
		    end
		else
			if cardNum  then
		        selectType,cardsNum = GameLaiziLogic:GetCardType1(selectCards,cardNum,self.data.kPlaytype[1])   
		    end
		end
	end

    local enable = 0
    

   	if #selectCards == 0 then 
    	self.tmp_card_selects = nil
    	--self.tmp_card_select = nil
    	gt.log("c_______________nil")
    end

    if 0 == outCount  then -- 
        if  cardsNum ~= -1 then -- 可以出
            enable = 1
        end

        log("________________________")

        -- auto 
        if not bool and #selectCards > 4 and enable == 0 then 
	        local sunzi = GameLaiziLogic:auto_sunzi(selectCards)
	        

	        if #sunzi > 4 and self:compare_card_data(self.tmp_card_selects,sunzi) then  -- 相同返回 false
	        	gt.log("here________!!!!!!!!!!!!")
	        	self.m_tabNodeCards[gt.MY_VIEWID]:reSetCards(true)								
				self.m_tabNodeCards[gt.MY_VIEWID]:suggestShootCards(sunzi,true)
				if cardNum then
					self.tmp_card_selects = sunzi
					selectType,cardsNum = GameLaiziLogic:GetCardType1(sunzi,cardNum,self.data.kPlaytype[1])  
				end 
	        end
	        if cardsNum ~= -1 then -- 可以出
	            enable = 1
	        end
    	end


    else

    	-- auto 
    	local cardType
	    for k ,v in pairs(GameLaiziLogic:GetCardType1(outCards,outCount,self.data.kPlaytype[1])) do
	        cardType = k 
	    end

	    if cardType == 4 then 
	    	log("1________________________")
	    	local result = GameLaiziLogic:getMaxCardType1(selectCards,outCards,self.data.kPlaytype[1])
	    	log("2________________________")
	    	if #result ~= 0 and not bool then
	    		log("3________________________")
 				self.__num = #result
	    		local bools = true
	    		if #result >1 then 
	    			self.__num = #result 
		    		if self:find(self.tmp_card,selectCards) then -- 判断 顺子 向上 还是向下选择
		    			self.__num = #result
		    		else
		    			self.__num = 1
		    		end
		    		log("5________________________")
	    		else
	    			log("6________________________")
	    			self.__num = 1
	    			bools = self:compare_card_data(self.tmp_card_select,result[1]) --判断两次智能选牌 结果是否一样   一样会卡主
	    		end

	    		if bools then 
	    			log("4________________________")
					self.tmp_card_select = result[self.__num]
			   	  	self.m_tabNodeCards[gt.MY_VIEWID]:reSetCards(true)								
			   		self.m_tabNodeCards[gt.MY_VIEWID]:suggestShootCards(result[self.__num],true)
		       		selectCards = result[self.__num]
		    		self.tmp_card = selectCards
   			    end
	   		end
   		end
   		-- auto 


        local num  =  GameLaiziLogic:CompareCard1(outCards,selectCards,self.data.kPlaytype[1])
        gt.log("csw_____csw",num)
        if num == 1  then
            enable = 1
        end
    end
    
    self:switch_operation(nil,nil,enable)

end

function ddzScene:find(a,b)
	if not a then return true end

	

	if a[#a] ~= b[#b] and a[1] ~= b[1] then 
		return false
	end

	if a[#a] == b[#b] then --- 
		return false
	end

	if a[1] == b[1] then 
		return true
	end
end



--比牌
function ddzScene:compare_card_data(a,b) 

	if not a then return true end

	log("_____________________________ss")
	gt.dump(a)
	gt.dump(b)

	if #a == #b then 
		for i = 1 , #a do
	  		if a[i] ~= b[#a+1-i] then 
	  			return true
	  		end
		end
	end
	return false

end

--过 。提示 。出牌按钮是否可切换
function ddzScene:switch_operation(a,b,c)

	gt.log("abc...........",c)
	if a then  self.pass:setEnabled(a==1) end
	if b then  self.prompt:setEnabled(b==1) end
	if c then  self.push_btn:setEnabled(c==1) end

end
--所有人准备后游戏开始
function ddzScene:gameStart(msg)
	--   15985
	--	self.start_action = true
	--self.msg_banker = nil
	self:findNodeByName("run_spring_nod"):stopAllActions()
	self.xuanzepuke = {}
	gt.soundEngine:playMusic_poker("sound_res/ddz/bg_zc.wav",true)
		self.m_cardControl:setVisible(true)
		self.result_min_node:setVisible(false)
		self:OnResetView()
		if not  gt.csw_app_store then 
		for i =1 , gt.GAME_PLAYER do
			local pos = self:getTableId(i-1)
			self.m_UserHead[pos].score:setString(msg.kScore[i])
			self.tallScore[pos] = msg.kScore[i]
			self.m_flagReady[i]:setVisible(false)
			self.nodePlayer[i]:getChildByName("icon"):setVisible(true)
			self:findNodeByName("player_action_" .. pos):getChildByName("score"):setString(msg.kScore[i])
		end
		end
		self:showX()
		self:PlaySound("sound_res/ddz/start.wav")
		self.gameBegin = true
		local _send_card_ = nil
		local dispatch = nil
	    --local call = cc.CallFunc:create(function()
    		
        	dispatch = self:PlaySound("sound_res/ddz/dispatch.wav")
            local empTyCard = self:emptyCardList(self.card_num)
            if type(empTyCard) ~= "table" or #empTyCard == 0 then 
            	self._node:getChildByName("Text_35"):setString(self._node:getChildByName("Text_35"):getString().."B")
            end
            self.m_tabNodeCards[1]:updateCardsNode(empTyCard, false, true)
            self.m_tabNodeCards[3]:updateCardsNode(empTyCard, false, true)

            -- 自己扑克
            local buf = {}
            for i = 1 , self.card_num do
            	buf[i] = msg.kCardData[i]
            end
            if type(buf) ~= "table" or #buf == 0  then
            	self._node:getChildByName("Text_35"):setString(self._node:getChildByName("Text_35"):getString().."A")
            end
            local carddata = GameLogic:SortCardList(buf, self.card_num, 0)
            --carddata = 1
            self.m_tabNodeCards[gt.MY_VIEWID]:updateCardsNode(carddata, true, true)
           
        --end)
        local call2 = cc.CallFunc:create(function()
          
            gt.soundEngine:stopEffect(dispatch)

        	_send_card_ = self:PlaySound("sound_res/ddz/send_card.mp3",true)

        end)
        local call1 = cc.CallFunc:create(function()
        	
        	
        	gt.log("c___________",_send_card_)
        	if msg.kStartUser == self.UsePos then 
        		-- if self.data.kPlaytype[1] ~= 3 then 
        		-- 	self.callscore_control:setVisible(true)
        		-- 	self.callscore_control1:setVisible(false)
        		-- 	if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
	        	-- 		self.callscore_control1:setVisible(true)
	        	-- 	else
	        	-- 		self.callscore_control1:setVisible(false)
	        	-- 	end
        		-- else
        		-- 	self.callscore_control:setVisible(false)
        		-- 	self.callscore_control1:setVisible(true)
        		-- end
        		if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
        			self.callscore_control1:setVisible(true)
        			self.callscore_control:setVisible(false)
        		else
        			self.callscore_control1:setVisible(false)
        			self.callscore_control:setVisible(true)
        		end
        		local handCards = self.m_tabNodeCards[gt.MY_VIEWID]:getHandCards()
	       		self:updatePromptList({}, handCards, curView, curView,landType)
        	end
        	
        	self:gameClock(msg.kStartUser)
        	--self.start_action = false
        	--if self.msg_banker then self:banker_info(self.msg_banker) self.msg_banker = nil end
        end)

        local call3 = cc.CallFunc:create(function()
        	gt.soundEngine:stopEffect(_send_card_)
       	end)

        local seq = cc.Sequence:create(cc.DelayTime:create(1.5),call2,cc.DelayTime:create(2),call3,cc.DelayTime:create(0.5),call1)
        self:stopAllActions()
        self:runAction(seq)
        -- 1004696
        if msg.kOnlyCall == 1 then 
			self.callscore_control:getChildByName("score_btn0"):setEnabled(false)
			self.callscore_control1:getChildByName("score_btn0"):setEnabled(false)
		end
end

--实时检测牌数量  牌有变化会走这里
function ddzScene:onCountChange( count, cardsNode, isOutCard ) -- biandong
    isOutCard = isOutCard or false
    local viewId = cardsNode.m_nViewId
    gt.log("viewId....",viewId)
    if nil ~= self.m_tabCardCount[viewId] then
    	self.m_tabCardCount[cardsNode.m_nViewId]:setVisible(true)
        self.m_tabCardCount[cardsNode.m_nViewId]:setString(count)
    end



    if count <= 2 and nil ~= self.m_tabSpAlarm[viewId] and isOutCard then -- 报警
        local param = self:getAnimationParam()
        param.m_fDelay = 0.1
        param.m_strName = "alarm_key"
        local animate = self:getAnimate(param)
        local rep = cc.RepeatForever:create(animate)
        self.m_tabSpAlarm[viewId]:runAction(rep)
        self.m_tabSpAlarm[viewId]:setVisible(true)
        -- -- 音效
        self:PlaySound( "sound_res/ddz/common_alert.mp3" )
    end
	gt.log("当前剩余牌数：",count)
   if count == 1 and nil ~= self.m_tabSpAlarm[viewId] and isOutCard then
   		gt.log("播放1  sound_res/ddz/one_card_women.ogg")
    	self:PlaySound("sound_res/ddz/one_card_women.mp3")
    end
    if count == 2 and nil ~= self.m_tabSpAlarm[viewId] and isOutCard then
    	gt.log("播放2  sound_res/ddz/two_card_women.ogg")
    	self:PlaySound("sound_res/ddz/two_card_women.mp3")
    end

    if count == 0  then  
    	if viewId ~= gt.MY_VIEWID then
    		self.m_tabCardCount[cardsNode.m_nViewId]:setVisible(false)
    		
    	end
    	if viewId ~= self.bankerViewId then 
    		self.nm_win:setVisible(true)
    		local __node = cc.CSLoader:createTimeline("nm_win.csb")
    		self.nm_win:runAction(__node)
    		__node:gotoFrameAndPlay(0,false)
    		self.nm_win:setPosition(win_action[viewId])
    		--农民赢
    		self.playingAni[1]:play("run_win_action",true)
    		self.playingAni[2]:play("run_win_action",true)
    		self.playingAni[3]:play("run_fail_action",true)
    	else
    		self.dz_win:setVisible(true)
    		local __node = cc.CSLoader:createTimeline("dz_win.csb")
    		self.dz_win:runAction(__node)
    		__node:gotoFrameAndPlay(0,false)
    		self.dz_win:setPosition(win_action[viewId])
    		--地主赢
    		self.playingAni[1]:play("run_fail_action",true)
    		self.playingAni[2]:play("run_fail_action",true)
			self.playingAni[3]:play("run_win_action",true)
    	end
  --   	for j=1,gt.GAME_PLAYER do
		-- 	--其他玩家为失败状态
		-- 	local ani_id = -100
		-- 	if self._node:getChildByName("wanjia_" .. j) then
		--   		ani_id = self._node:getChildByName("wanjia_" .. j):getTag() - 1000
		--   	end
		-- 	self:setPlayerAction(ani_id ,"run_fail_action")
		-- 	if viewId == j then
		-- 		--此时变为胜利状态
		-- 		if self._node:getChildByName("wanjia_" .. j) then
		--   			ani_id = self._node:getChildByName("wanjia_" .. j):getTag() - 1000
		--   		end
		-- 		self:setPlayerAction(ani_id ,"run_win_action")
		-- 	end
		-- end

    	self.m_tabSpAlarm[viewId]:stopAllActions()
        self.m_tabSpAlarm[viewId]:setVisible(false)
    end

end
--大结算面板
function ddzScene:GameResult(result)
	gt.log("max_result__________________________")
	gt.socketClient:unregisterMsgListener(gt.GC_REMOVE_PLAYER)
	self.kIsFinalDraw = 1
	self.max_result = result
	self:switch_result()
	self:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create( function()

				if not self.result_min_node:isVisible() and not self.result_node:isVisible() then self:showresult_max() end

		end)))
	
end

function ddzScene:shareImage()

	   self.result_node:getChildByName("Button_2"):runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.9),cc.ScaleTo:create(0.1,1)))

	   local fileName = "sharewx.png" 
		       cc.utils:captureScreen(function(succeed, outputFile)  
		           if succeed then  
		             local winSize = cc.Director:getInstance():getWinSize()  
		               Utils.shareImageToWX( outputFile, 849, 450, 32 )
		           else  
		              
		           end  
		       end, fileName)  

end
--小结算（大结算） 停留后弹出界面
function ddzScene:runaction_DelayTime(time)

	if not self.result_min_node or not self._m then self:onStartGame()
				self:OnResetView()  self:showresult_max() return end


		if time ~= 2 then
	    	self.___node = cc.CSLoader:createTimeline("spring.csb")	
     	    self.spring:runAction(self.___node)
     	    self.spring:setVisible(true)
        	self.___node:gotoFrameAndPlay(0,false)
    	end
        self:findNodeByName("run_spring_nod"):runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
        		self:showResult_min(self._m)
        	end)))
        


end


function ddzScene:showResult_min(msg)
	gt.log("显示小结算数据")
	gt.dump(msg)
	gt.soundEngine:stopMusic()
	self:KillGameClock()
	self.dz_win:stopAllActions()
	self.nm_win:stopAllActions()
	self.dz_win:setVisible(false)
	self.nm_win:setVisible(false)

	self.spring:stopAllActions()
	self.spring:setVisible(false)
 	self.plane:stopAllActions()
	self.plane:setVisible(false)
	self.rocket:stopAllActions()
	self.rocket:setVisible(false)
	self.bomb:stopAllActions()
	self.bomb:setVisible(false)

	self.sunzi:stopAllActions()
	self.sunzi:setVisible(false)
	self.sandaiyi:stopAllActions()
	self.sandaiyi:setVisible(false)
	self.sidaier:stopAllActions()
	self.sidaier:setVisible(false)
	self.liandui:stopAllActions()
	self.liandui:setVisible(false)
	self.sandaiyidui:setVisible(false)
	self.sandaiyidui:stopAllActions()
	self.sanzhang:setVisible(false)
	self.sanzhang:stopAllActions()


	self:PlaySound("sound_res/ddz/gameconclude.wav")
	self:removeChildByName("__effect_ani_name__")
	self.result_min_node:setVisible(true)



	if not  gt.csw_app_store then 
		for i = 1, gt.GAME_PLAYER do
			local pos = self:getTableId(i-1)
			self.m_UserHead[pos].score:setString(msg.kScore[i])
			self.nodePlayer[i]:getChildByName("icon"):setVisible(true)
			self.m_UserHead[i].maozi:setVisible(false)
			self.m_UserHead[i].t_icon:setVisible(false)
			if msg.kScore[i] then
				self.tallScore[pos] = msg.kScore[i]
			end
		end
	end

	if msg.kRestCardData then 
	for i = 1 , gt.di_card do
		local data = msg.kRestCardData[i]
		local card = self.result_min_node:getChildByName("card"..i)
		if data and card then 
			card:setVisible(true)
			card:loadTexture("poker_ddz1/"..gt.tonumber(msg.kRestCardData[i])..".png")
		end
	end
	end

	for i = 1,  gt.GAME_PLAYER do
		local node = self.result_min_node:getChildByName("Node_"..i)
		self.result_min_node:getChildByName("r_shegnli_"..i):setVisible(false)
		node:getChildByName("score"):setString("")
		node:getChildByName("name"):setString("")
		node:getChildByName("id"):setString("")
		node:getChildByName("Image"):setVisible(false)
		local icon = node:getChildByName("icon")
		icon:loadTexture("ddz/p_icon.png")
		node:getChildByName("card"):setVisible(false)
		self.result_min_node:getChildByName("min_r_line_"..i):setVisible(false)
		for j = 2 , gt.card_num_max do
			if node:getChildByName("card"..j) then 
				node:getChildByName("card"..j):removeFromParent()
			end
		end

	end

	local kGameScore = {}
	local kUserNames = {}
	local kActSelect = {}
	local kUserIds = {}
	local kCardCount = {}
	local kHeadUrl = {}
	local kHandCardData = {}
	local kBankerUser_buf = {}


	for i = 1 , gt.GAME_PLAYER do
		if msg.kBankerUser == (i-1) then 
			kBankerUser_buf[i] = 1
		else
			kBankerUser_buf[i] = 0
		end
		log("kBankerUser_buf",kBankerUser_buf[i])
	end

	local kBankerUser = 0
	local x = 1 
	for i =1 , gt.GAME_PLAYER do
		if (i-1) == self.UsePos then 
			x = i 
			kHandCardData[1] = {}
			kCardCount[1] = msg.kCardCount[x]
			kGameScore[1] = msg.kGameScore[x]
			kUserNames[1] = msg.kUserNames[x]
			kActSelect[1] = msg.kActSelect[x]
			kUserIds[1]  = msg.kUserIds[x]
			kHeadUrl[1]  = msg.kHeadUrl[x]
			for j = 1 , msg.kCardCount[x] do 
				kHandCardData[1][j] = msg.kHandCardData[x][j]
			end
			if msg.kBankerUser == self.UsePos then 
				kBankerUser = 1
			end
		end
	
	end
	local t = 1 
	for i =1 , gt.GAME_PLAYER do
		if i ~= x then 
		
			t = t + 1 
			kHandCardData[t] = {}
			kCardCount[t] = msg.kCardCount[i]
			kGameScore[t] = msg.kGameScore[i]
			kUserNames[t] = msg.kUserNames[i]
			kActSelect[t] = msg.kActSelect[i]
			kUserIds[t]  = msg.kUserIds[i]
			kHeadUrl[t]  = msg.kHeadUrl[i]
			for j = 1 , msg.kCardCount[i] do 
				kHandCardData[t][j] = msg.kHandCardData[i][j]
			end
			if kBankerUser_buf[i] == 1 and kBankerUser ~= 1 then 
				kBankerUser = t
			end

		end
	end



	log("kBankerUser.............",kBankerUser)

	for i = 1 , gt.GAME_PLAYER do
		local node = self.result_min_node:getChildByName("Node_"..i)
		if self.data.kPlaytype[5] == 1 and i ~= 1 then node:getChildByName("icon"):loadTexture("ddz/p_icon1.png") end

		if kBankerUser == i then 
			node:getChildByName("man"):loadTexture("ddz/dizhu_m.png")
			-- self:addPlayerAction(i, "dizhu", "run_daiji_action" )
		else
			node:getChildByName("man"):loadTexture("ddz/pingmin_m.png")
			-- self:addPlayerAction(i, "nongmin", "run_daiji_action" )
		end
		node:getChildByName("man"):setScale(0.85)
		--kActSelect 0,1，2，3 不踢 ，踢，跟踢，回踢
		if self.data.kPlaytype[1] == 3 then 
			if kActSelect  and #kActSelect ~= 0 then 
				
				if kActSelect[i] ~= 0 then 
					node:getChildByName("Image"):setVisible(true)
					if kActSelect[i] == 1 or kActSelect[i] == 2 then 
						node:getChildByName("Image"):loadTexture("ddz/ttt.png")
					elseif kActSelect[i] == 3 then
						node:getChildByName("Image"):loadTexture("ddz/hhh.png")
					end
				else
					node:getChildByName("Image"):setVisible(false)
				end
			end
		else
			if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then
				if kActSelect  and #kActSelect ~= 0 then 
					
					if kActSelect[i] ~= 0 then 
						node:getChildByName("Image"):setVisible(true)
						if kActSelect[i] == 1 or kActSelect[i] == 2 then 
							node:getChildByName("Image"):loadTexture("ddz/ttt.png")
						elseif kActSelect[i] == 3 then
							node:getChildByName("Image"):loadTexture("ddz/hhh.png")
						end
					else
						node:getChildByName("Image"):setVisible(false)
					end
				end
			end
		end

		if i==1 then 
			if kGameScore[i] >= 0 then 
				self:PlaySound("sound_res/ddz/victory.mp3")
				self.result_min_node:getChildByName("Image_4"):loadTexture("ddz/r_shegnli.png")
			else
				self:PlaySound("sound_res/ddz/lose.mp3")
				self.result_min_node:getChildByName("Image_4"):loadTexture("ddz/r_shibai.png")
			end
			self.result_min_node:getChildByName("min_r_line_"..i):setVisible(true)
		else
			self.result_min_node:getChildByName("min_r_line_"..i):setVisible(false)
		end

		if tonumber(kGameScore[i]) >= 0 then 
			node:getChildByName("score"):setString("+"..kGameScore[i])
			node:getChildByName("score"):setColor(cc.c3b(197, 75, 32))
			
		else
			node:getChildByName("score"):setString(kGameScore[i])
			node:getChildByName("score"):setColor(cc.c3b(4,82,137))
		end

		
		node:getChildByName("name"):setString((i ~= 1 and self.data.kPlaytype[5] == 1 ) and "" or kUserNames[i])
		node:getChildByName("id"):setString((i~= 1 and self.data.kPlaytype[5] == 1 ) and "" or "ID:"..kUserIds[i])


		if kCardCount[i] == 0 then self.result_min_node:getChildByName("r_shegnli_"..i):setVisible(true) end
		for j = 1 , kCardCount[i] do
			local card = node:getChildByName("card")
			local tmp
			if j > 1 then 
				tmp = card:clone()
				node:addChild(tmp)
				tmp:setName("card"..j)
				tmp:setPositionX(card:getPositionX()+28*(j-1))
				if tmp then tmp:loadTexture("poker_ddz/"..gt.tonumber(kHandCardData[i][j])..".png") end
			else
				card:setVisible(true)
				card:loadTexture("poker_ddz/"..gt.tonumber(kHandCardData[i][j])..".png")
			end
		end
	end

	local share = self.result_min_node:getChildByName("share")
	local _next = self.result_min_node:getChildByName("next")

	

	gt.setOnViewClickedListener(share, function()
			self:PlaySound("sound_res/cli.mp3")
			self:shareImage()
		end,0,"zoom")

	self.kIsFinalDraw = msg.kIsFinalDraw
	self:switch_result()
	gt.setOnViewClickedListener(_next, function()
			self:PlaySound("sound_res/cli.mp3")	
			if self.kIsFinalDraw == 1 then 
				self:showresult_max()
			else

				self:onStartGame()
				self:OnResetView()
			end
			self.result_min_node:setVisible(false)
		end)

    self.result_min_node:getChildByName("T1"):setString(self.data.kDeskId or "000000")
	--self.result_min_node:getChildByName("T1"):setString((self.data.kPlaytype[5] == 1 and self.data.kPlaytype[6] ~= 0 ) and "xxxxxx" or (self.data.kDeskId or "000000"))
	self.result_min_node:getChildByName("T2"):setString(self.data.kPlaytype[4] or "")
	
	if self.data.kPlaytype[1] == 3 then 
		self.result_min_node:getChildByName("T4"):setString("1")
	else
		self.result_min_node:getChildByName("T4"):setString(msg.kBankerScore or "")
	end
	self.result_min_node:getChildByName("T5"):setString(self.data.kPlaytype[3] == 0 and "不封顶" or tostring(self.data.kPlaytype[3]).."炸")
	self.result_min_node:getChildByName("T6"):setString(msg.kBombCount or "")
	self.result_min_node:getChildByName("T7"):setString((msg.kChunTian == 1 or msg.kFanChunTian == 1) and "1" or "0")
	self.result_min_node:getChildByName("T8"):setString(self.result_jushi or "")
	self.result_min_node:getChildByName("T9"):setString(os.date("%m-%d %H:%M"))




	for i = 1, gt.GAME_PLAYER do
		if self.data.kPlaytype[5] == 0 or ( self.data.kPlaytype[5] == 1 and  i == 1 ) then 
			gt.log("url______________________")
			local node = self.result_min_node:getChildByName("Node_"..i)
			node:setVisible(true)

			local icon = node:getChildByName("icon")
			local url = kHeadUrl[i]
			local iamge = gt.imageNamePath(url)
		  	if iamge then
		  		icon:loadTexture(iamge)
		  	else
			  	if type(url) ~= nil and  string.len(url) > 10 then
			  		local function callback(args)
			      		if args.done  and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self then
			      			icon:loadTexture(args.iamge)	
						end
			        end    
				    gt.downloadImage(url,callback)	
				  	
				end
			end
		end
	end


end

function ddzScene:result_min(msg)
	self:KillGameClock()
	if not self.result_min_node then self:onStartGame()
				self:OnResetView() self:showresult_max() return end

	if msg.kChunTian == 1 or msg.kFanChunTian == 1 then 
		self._m = msg
		self:runaction_DelayTime(2.5)
		return 
	end

	if 1 == 1 then self._m = msg self:runaction_DelayTime(2) return  end


	self:showResult_min(msg)

end

--[[
	
Lint kScore[MAX_CHAIR_COUNT]; //总结算分数
Lint kUserIds[MAX_CHAIR_COUNT; //游戏 I D
Lstring kNikes[MAX_CHAIR_COUNT]; //游戏玩家昵称
Lstring kHeadUrls[MAX_CHAIR_COUNT]; //游戏玩家头像

Llong kTime;
Lint kCreatorId;
Lstring kCreatorNike;
Lstring kCreatorHeadUrl;


]]
--是否下一局还是开始按钮
function ddzScene:switch_result()
	local _next = self.result_min_node:getChildByName("next")
	if self.kIsFinalDraw == 1 then 
		_next:loadTexture("ddz/look_result.png")
	else
		_next:loadTexture("ddz/next.png")
	end

end

function ddzScene:showresult_max()
	if not self.result_node or not self.max_result  then return end
	self.result_node:setVisible(true)

	local m = self.max_result
	local idx = -1 
	local  tmp = -1
	for i = 1 , gt.GAME_PLAYER do
		local node = self.result_node:getChildByName("bg"):getChildByName("player"..i)
		local id  = self:getTableId(i-1)
		node:getChildByName("name"):setString(m.kNikes[id])
		node:getChildByName("ID"):setString("ID:"..m.kUserIds[id])
		if tonumber(m.kScore[id]) >= 0 then 
			if tonumber(m.kScore[id]) > 0 and tonumber(m.kScore[id]) > tmp  then 
				tmp = tonumber(m.kScore[id])
				idx = i
			end
			node:getChildByName("score"):setString("+"..m.kScore[id])
			node:getChildByName("score"):setColor(cc.c3b(197, 75, 32))
		else
			node:getChildByName("score"):setString(m.kScore[id])
			node:getChildByName("score"):setColor(cc.c3b(4,82,137))
		end

	end

	for i = 1 , gt.GAME_PLAYER do
		local id  = self:getTableId(i-1)
		if tmp ~= -1 and idx ~= -1 then 
			if tmp == tonumber(m.kScore[id]) and i ~= idx then 
				local win_ = self.result_node:getChildByName("bg"):getChildByName("player"..i):getChildByName("playerWin")
			   	win_:setVisible(true)
			   	win_:setLocalZOrder(21)
			    local quan = self.result_node:getChildByName("bg"):getChildByName("player"..i):getChildByName("quanquan_4")
			    quan:setLocalZOrder(20)
			    quan:setVisible(true)
			    quan:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.6,50)))
			end
		end
	end

	if idx ~= -1 then 

		local win_ = self.result_node:getChildByName("bg"):getChildByName("player"..idx):getChildByName("playerWin")
	   	win_:setVisible(true)
	   	win_:setLocalZOrder(21)
	    local quan = self.result_node:getChildByName("bg"):getChildByName("player"..idx):getChildByName("quanquan_4")
	    quan:setLocalZOrder(20)
	    quan:setVisible(true)
	    quan:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.6,50)))
	end


    local wanfa = ""
    gt.log("playtype________________",self.data.kPlaytype[1])
    if self.data.kPlaytype[1] == 1 then 
    	wanfa = "经典玩法"
    elseif self.data.kPlaytype[1] == 2 then 
    	wanfa = "带花玩法"
    elseif self.data.kPlaytype[1] == 3 then 
    	wanfa = "临汾玩法"
    end

    self.result_node:getChildByName("m_roomId"):setString(self.data.kDeskId and self.data.kDeskId or "")
    self.result_node:getChildByName("m_lunshu"):setString(wanfa)  -- 玩法
    self.result_node:getChildByName("m_gamenum"):setString(self.result_jushi and self.result_jushi or "") -- 轮数
    self.result_node:getChildByName("_time"):setString(os.date("%Y-%m-%d %H:%M"))



	for i = 1 , gt.GAME_PLAYER do
			local node = self.result_node:getChildByName("bg"):getChildByName("player"..i)
			local id  = self:getTableId(i-1)
            local ispath = gt.imageNamePath(m.kHeadUrls[id])
            local icon = node:getChildByName("icon")
            if ispath then
               local _node = display.newSprite("icon1.png")
               local image = gt.clippingImage(ispath,_node,false)
               image:setLocalZOrder(19)
               node:addChild(image)
               icon:setVisible(false)
               image:setPosition(icon:getPositionX(),icon:getPositionY())
            else
      			if m.kHeadUrls[id] ~= "" and  type(m.kHeadUrls[id]) == "string" and string.len(m.kHeadUrls[id]) >10 and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self then
      				local function callback(args)
      					if args.done then 
      						local _node = display.newSprite("icon1.png")
							local head = gt.clippingImage(args.image,_node,false)
							node:addChild(head)
							head:setLocalZOrder(19)
							icon:setVisible(false)
							head:setPosition(icon:getPositionX(),icon:getPositionY())
      					end
      				end
      				gt.downloadImage(m.kHeadUrls[id], callback)
      			end
            end         
	end

	self.max_result = nil

end

function ddzScene:emptyCardList(num)

	local buf = {}
	for i = 1, num do
		buf[i] = 0
	end

	return buf
end
--没用了 两人就开始游戏按钮
function ddzScene:onBeginGame()

	local msgToSend = {}
	msgToSend.kMId = gt.SUB_S_GAME_START
	msgToSend.kPos = self.UsePos
	gt.dumplog(msgToSend)
	gt.socketClient:sendMessage(msgToSend)

end
--服务器广播谁准备了
function ddzScene:RcvReady(args) -- csww

	for i=1,3 do
		if self.nodePlayer[i] and self.Player[i].id then
			self.nodePlayer[i]:setVisible(true)
			self.nodePlayer[i]:getChildByName("t_icon"):setVisible(false)
		end
		if self.playingNode[i] then
			self.playingNode[i]:setVisible(false)
			self.playingNode[i]:getChildByName("Image_1"):setVisible(false)
		end
		local player_action = self:findNodeByName("player_action_" .. i)
		player_action:setVisible(false)
	end


	gt.dumplog(args)
	gt.log("ready_________________",args.kPos,self.UsePos)
	

	if args.kPos then 
		if args.kPos == self.UsePos then 
			self.btReady:setVisible(false) 
			--if  self.___jushu ~= 0 then 
				self:OnResetView() 
		--	self.m_btnInvite:setPosition(self.btReady:getPosition())
			--end
			--self.r_time = 0
			if self.showX then 
				self:showX()
			end
			if self.notice_ti then 
				self:notice_ti()
			end
			gt.soundEngine:playMusic_poker("sound_res/ddz/bg_zc.wav",true)
		end

		self.m_flagReady[self:getTableId(args.kPos)]:setVisible(true) 
    end
	

end
--点击准备走
function ddzScene:onStartGame()

	local msgToSend = {}
	msgToSend.kMId = gt.CG_READY
	msgToSend.kPos = self.UsePos
	gt.dumplog(msgToSend)
	gt.socketClient:sendMessage(msgToSend)
	
	self.m_flagReady[gt.MY_VIEWID]:setVisible(true) 
--	self.m_btnInvite:setPosition(self.btReady:getPosition())
	self.btReady:setVisible(false)
	-- log("==================0")
	--self.r_time = 0
end


function ddzScene:roominfo(args)

	-- local node = self:findNodeByName("game_info")
	-- self.roomid = (args.kPlaytype[5] == 1 and args.kPlaytype[6] ~= 0 ) and "xxxxxx" or args.kDeskId
	-- if self.room_node and self.room_node:setVisible(true) then
	self.room_node = self:findNodeByName("room_info_bg")
	self.roomid = "xxxxxx"
	if args.kDeskId then
		self.roomid = args.kDeskId
	end
	self.dizhu = args.kPlaytype[4]
	-- self.beishu = m.kBankerScore
	-- self.beishu = args.kBankerScore
	-- gt.log("args.kBankerScore=========",args.kBankerScore)
	-- self.beishu = self:findNodeByName("num_beishu_1"):getString()
	self.beishu = 0
	if not self.jushu then
		self.jushu = 0
	end
	-- node:getChildByName("room_id_lbl"):setString("房间号:" .. self.roomid)
	self:findNodeByName("room_id_lbl"):setString("房间号:" .. self.roomid)
	self:findNodeByName("room_dizhu_lbl"):setString("底注:".. args.kPlaytype[4])
	self:findNodeByName("room_jushu_lbl"):setString("局数:".. self.jushu)
	-- self:findNodeByName("t2",node):setString("叫分:".."0")
			-- self:findNodeByName("num_beishu_1"):setString("叫分:"..m.kBankerScore)
	if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
		self:findNodeByName("room_beishu_lbl"):setString("倍数:".. self.beishu)
		self:findNodeByName("num_beishu_1"):setString("倍数:"..self.beishu)
	else
		self:findNodeByName("room_beishu_lbl"):setString("叫分:".. self.beishu)
		self:findNodeByName("num_beishu_1"):setString("叫分:"..self.beishu)
	end
	self:findNodeByName("room_fengding_lbl"):setString(self.data.kPlaytype[3] == 0 and "封顶:不封顶" or tostring("封顶:" .. self.data.kPlaytype[3]).."炸")
	if self.data.kPlaytype[3] > 0 then
		self:findNodeByName("fengd_b"):setVisible(false)
	end

	-- self:findNodeByName("room_wanfa_lbl"):setString(args.kPlaytype[7] == 1 and "玩法:轮流叫地主" or "玩法:赢家叫地主")
	local wanfa_str = "玩法:"
	if self.data.kPlaytype[1] == 3 then ---- 临汾去俩二
		gt.card_num_max = 20
		self.card_num = 16
		gt.di_card = 4
		wanfa_str = "玩法:临汾斗地主"
		--score:loadTexture("ddz/t_beishu.png")
	elseif self.data.kPlaytype[1] == 2 then --癞子 
		gt.card_num_max = 21
		self.card_num = 17
		gt.di_card = 4
		wanfa_str = "玩法:带花斗地主"
		--score:loadTexture("ddz/jiaofen.png")
	else -- 经典
		self.card_num = 17
		gt.card_num_max = 20
		gt.di_card = 3
		wanfa_str = "玩法:经典斗地主"
		--score:loadTexture("ddz/jiaofen.png")
	end
	self:findNodeByName("room_wanfa_lbl"):setString(wanfa_str)

	gt.log("self.beishu=====倍数====",self.beishu)
	gt.three_bomb  =  self.data.kPlaytype[9] == 1 
	gt.log("three_bomb",tostring(gt.three_bomb))



	self:findNodeByName("room_show_id"):setString(self.roomid)
end

--显示准备按钮  不用了
function ddzScene:disBeginBtn(pos,name)

	log("pos...................",pos)
	if not pos then return end
	if pos == self.UsePos then 
		self.begin_btn:setVisible(true)
		self.m_btnInvite:setVisible(false)
	elseif pos ~= 21  then
		log("111111")
		self:ActionText5(false)
		self:ActionText5(true)
		--self:ActionText7(false)
		log("pos.............",pos)
		log(self.Player[self:getTableId(pos)].name)
		local str = "等待 "..(name and name or " ")
		log("str...",str)
		self.text5:getChildByName("name"):setString(str)
		self.m_btnInvite:setVisible(false)
	elseif pos == 21 then 
		log("222222")
		self.begin_btn:setVisible(false)
		self:ActionText5(false)
	end


end
--服务器广播其他玩家是否断线
function ddzScene:off_line(args)

	gt.log("off___________________",self:getTableId(args.kPos))
	self.head_hui[self:getTableId(args.kPos)]:setVisible(0 == args.kFlag)
end

function ddzScene:checkShareBtn()
	if gt.csw_app_store then return end
	if not  self.gameBegin then 
	local idx = 0
	for i = 1 , gt.GAME_PLAYER do

		if self.player_num[i] then
			log("iiiii.",i)
			idx = idx + 1
		end
	end
	log("idxx...............",idx)
	if self.data.kGpsLimit == 1 then 
		if idx > 1 then 
			self.pos:setVisible(true)
		else
			self.pos:setVisible(false)
		end
	end
	self.m_btnInvite:setVisible(idx ~= gt.GAME_PLAYER)
	self.btReady:setPositionX(idx ~= gt.GAME_PLAYER and  900.00 or 1152.00)
	end
end
--房间人数  
function ddzScene:get_num()
	local idx = 0
	for i = 1 , gt.GAME_PLAYER do
		if self.player_num[i] then
			idx = idx + 1
		end
	end

	return (3-idx)
end
-- initNode()中初始化自己传空值   广播其他玩家进入房间
function ddzScene:addPlayer(args)
	
	log("addplayer______________________s")

	if not args then  -- init user

		local pos = self:getTableId(self.UsePos)
		self.player_num[pos] = true
		self:checkShareBtn()
		gt.dumplog(self.data)
		log("pos..",pos)
		self.m_UserHead[pos].score:setString(gt.csw_app_store and "ID:"..gt.playerData.uid or self.data.kScore)
		self.Player[pos].sex = gt.userSex
		self:disBeginBtn(self.data.kStartGameButtonPos)
		self.m_flagReady[pos]:setVisible(self.data.kReady == 1)
	
		gt.log("ready......",self.data.kReady)
		self.btReady:setVisible(self.data.kReady ~= 1)
		
		if self.data.kReady ~= 1 then 
		else
			self.r_time = 0
		end
	
		gt.log("add.....",pos,(self.data.kReady==1))
		self.nodePlayer[pos]:setVisible(true)
		gt.log(gt.wxNickName)
		self.Player[pos].score = self.data.kScore
		self.tallScore[pos] = self.data.kScore
		self.Player[pos].name = gt.wxNickName
		-- self.Player[pos].score = self.data.kScore
		self.Player[pos].id = gt.playerData.uid
		self.Player[pos].ip = self.data.kUserIp
		self.Player[pos].Coins = self.data.kCoins
		self.Player[pos].pos= self.data.kUserGps
		self.Player[pos]._pos = pos
		-- if self.data.kPlaytype[5] == 1 then 
		-- 	self.m_UserHead[pos].name:setString(self.UsePos)
		-- 	self.Player[pos].name = self.UsePos
		-- 	self.nodePlayer[pos]:getChildByName("icon"):loadTexture("ddz/p_icon1.png")
		-- 	return 
		-- else
			self.Player[pos].name = gt.wxNickName
			self.m_UserHead[pos].name:setString(gt.wxNickName)
		--end
		
		log("return____________________")
		-- action_icon:getChildByName("score"):setString(self.Player[pos].score)

		log("name...",self.data.kNike)
		local url 	= cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl","" )
		self.Player[pos].url = url
		local icon = self.nodePlayer[pos]:getChildByName("icon")
		local _name ,b = string.gsub(url, "[/.:+]", "")
		local iamge = gt.imageNamePath(url)
	  	if iamge then
	  		icon:loadTexture(iamge)
	  	else

		  	if type(url) ~= nil and  string.len(url) > 10 then
				--self.urlName[pos] = string.gsub(url, "[/.:+]", "")
		  		local function callback(args)
		      		if args.done  and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self then
		      			icon:loadTexture(args.image)
					end
		        end
			    
			    gt.downloadImage(url,callback)	
			  	
			end

	  -- 		self.urlName[pos] = string.gsub(url, "[/.:+]", "")
			-- local res = cc.UtilityExtension:DownloadImage(url,self.urlName[pos])
			-- if not res then return end
			-- self._sche_time[pos] = 0 
			-- if self._sche_url[pos] then  _scheduler:unscheduleScriptEntry(self._sche_url[pos])  self._sche_url[pos] = nil end 
			-- self._sche_url[pos] = _scheduler:scheduleScriptFunc(function(dt)
			-- 		local iamge = cc.FileUtils:getInstance():getWritablePath() .. self.urlName[pos]..".png"
			-- 		if  cc.FileUtils:getInstance():isFileExist(iamge) then
						
			-- 			local _node = display.newSprite("player/icon.png")
			-- 			self.m_UserHead[pos].head = gt.clippingImage(iamge,_node,false)
			-- 			self.m_UserHead[pos].head:setLocalZOrder(20)
			-- 			if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
			-- 			self.nodePlayer[pos]:addChild(self.m_UserHead[pos].head)
			-- 			self.m_UserHead[pos].head:setName(self.urlName[pos])
			-- 			self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
			-- 			if self._sche_url[pos] then  _scheduler:unscheduleScriptEntry(self._sche_url[pos])  self._sche_url[pos] = nil end 
			-- 		else
			-- 			self._sche_time[pos] = self._sche_time[pos] + dt
			-- 			if self._sche_time[pos] >= 10 then if self._sche_url[pos] then  _scheduler:unscheduleScriptEntry(self._sche_url[pos])  self._sche_url[pos] = nil end end
			-- 		end 
			-- 	end,1/60,false)	
			-- gt.log("self._sche_url[pos]",self._sche_url[pos],pos)
	  	end

	else
		gt.dumplog(args)
		gt.dump(args)
		--self.player_num[]
		local pos = self:getTableId(args.kPos)
		self.player_num[pos] = true
		self:checkShareBtn()
		gt.log("adds.....",pos)
		self.m_UserHead[pos].score:setString(gt.csw_app_store and "ID:"..args.kUserId or args.kScore)
		self.Player[pos].sex = args.kSex
		--self.Player[pos].name = args.kNike
		self.Player[pos]._pos = pos
		self.Player[pos].id = args.kUserId
		self.Player[pos].ip = args.kIp
		self.Player[pos].score = args.kScore
		self.tallScore[pos] = args.kScore
		self.Player[pos].Coins = args.kCoins
		self.Player[pos].pos= args.kUserGps
		self.m_flagReady[pos]:setVisible(args.kReady==1)
		
		self.nodePlayer[pos]:setVisible(true)
		
		--self.m_UserHead[pos].name:setString(args.nickname or "name")
		self.m_UserHead[pos].name:setString(args.kNike)
		self.Player[pos].url = args.kFace
		self.Player[pos].score = args.kScore
		self.head_hui[pos]:setVisible(not args.kOnline)
		if self.data.kPlaytype[5] == 1 then 
			self.m_UserHead[pos].name:setString(args.kPos)
			self.Player[pos].name = args.kPos
			self.nodePlayer[pos]:getChildByName("icon"):loadTexture("ddz/p_icon1.png")
			return 
		else
			self.Player[pos].name = args.kNike
			self.m_UserHead[pos].name:setString(args.kNike)
		end

		gt.log("downImage_____________")

		local url 	= self.Player[pos].url
		local icon = self.nodePlayer[pos]:getChildByName("icon")
		local iamge = gt.imageNamePath(url)
		--self.urlName[pos] = string.gsub(url, "[/.:+]", "")
	  	if iamge then
				icon:loadTexture(iamge)
	  	else
	  		
	  		 	if type(url) ~= nil and  string.len(url) > 10 then
			
		  		local function callback(args)
		      		if args.done and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self then
		      				icon:loadTexture(args.image)
					end
		        end
			   	
			    gt.downloadImage(url,callback)	
			  	
			end

			-- cc.UtilityExtension:DownloadImage(url,self.urlName[pos])
			-- self._sche_time[pos] = 0 
			-- if self._sche_url[pos] then  _scheduler:unscheduleScriptEntry(self._sche_url[pos])  self._sche_url[pos] = nil end 
			-- self._sche_url[pos] = _scheduler:scheduleScriptFunc(function(dt)
			-- 		local iamge = cc.FileUtils:getInstance():getWritablePath() .. self.urlName[pos]..".png"
			-- 		if  cc.FileUtils:getInstance():isFileExist(iamge) then
			-- 			local _node = display.newSprite("player/icon.png")
			-- 			self.m_UserHead[pos].head = gt.clippingImage(iamge,_node,false)
			-- 			self.m_UserHead[pos].head:setLocalZOrder(20)
			-- 			if self.nodePlayer[pos]:getChildByName(_name) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(_name):removeFromParent() end
			-- 			self.nodePlayer[pos]:addChild(self.m_UserHead[pos].head)
			-- 			self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
			-- 			if self._sche_url[pos] then  _scheduler:unscheduleScriptEntry(self._sche_url[pos])  self._sche_url[pos] = nil end 
			-- 		else
			-- 			self._sche_time[pos] = self._sche_time[pos] + dt
			-- 			if self._sche_time[pos] >=10 then _scheduler:unscheduleScriptEntry(self._sche_url[pos]) end
			-- 		end
			-- 	end,1/60,false)	
	  	end

	end
	log("addplayer______________________")
	
end

function ddzScene:removePlayer(args)


	gt.log("remove________________player")

	gt.dumplog(args)
	if args and args.kPos ~= 21 and args.kPos then 
		--self.head_hui[self:getTableId(args.kPos)]:setVisible(false)
		self.nodePlayer[self:getTableId(args.kPos)]:setVisible(false)
		self.player_num[self:getTableId(args.kPos)]	= false
		self.Player[self:getTableId(args.kPos)].ip = nil
		local i = self:getTableId(args.kPos)
		self.Player[i].name = ""
		self.Player[i].score = nil
		self.Player[i].url = nil
		self.Player[i].sex = nil
		self.Player[i].id = nil
		self.Player[i].ip= nil
		self.Player[i].pos= ""..","..""
		self.Player[i].Coins= nil
		self.Player[i]._pos = nil

		self:checkShareBtn()
		self.m_flagReady[self:getTableId(args.kPos)]:setVisible(false)
		-- if self._sche_url[self:getTableId(args.kPos)] then _scheduler:unscheduleScriptEntry(self._sche_url[self:getTableId(args.kPos)]) self._sche_url[self:getTableId(args.kPos)] = nil end
		-- if self._sche_buf[self:getTableId(args.kPos)] then _scheduler:unscheduleScriptEntry(self._sche_buf[self:getTableId(args.kPos)]) self._sche_buf[self:getTableId(args.kPos)] = nil end 
		if args.kPos == self.UsePos then self:onExitRoom("房间已解散！") end
	end
end



function ddzScene:renovate(msg)
	gt.dumplog(msg)
	
	gt.log("刷新局数______________")
	gt.curCircle = msg.kCurCircle
	--self.___jushu = msg.kCurCircle
	if msg.kCurCircle > 0 then self.m_btnInvite:setVisible(false)  self.gameBegin = true end
	self.result_jushi = msg.kCurCircle.." / "..msg.kCurMaxCircle
	self.jushu = msg.kCurCircle
	self:findNodeByName("num_beishu_2"):setString(self.result_jushi)
	self:findNodeByName("room_jushu_lbl"):setString("局数:".. msg.kCurCircle)
	local node = self:findNodeByName("game_info")
	-- self.m_atlasCount = self:findNodeByName("num",node)
	-- if self.m_atlasCount and msg.kCurCircle and msg.kCurMaxCircle then self.m_atlasCount:setString(self.result_jushi) end

end

--断线重连
function ddzScene:off_line_data_ddz(m)
	self:findNodeByName("run_spring_nod"):stopAllActions()
	self.operation:setVisible(false)
	--gt.dump(m)
	log("off_________________________")
	self.tmp_card_select = nil
	self:showX()
	self:notice_ti()
	self.m_cardControl:setVisible(true)
	for i = 1 , gt.GAME_PLAYER do
		self.m_outCardsControl:removeChildByTag(i)
		self.m_flagReady[i]:setVisible(false)
		--self.head_hui[i]:setVisible(false)
	end
	self.xuanzepuke = {}
	self.result_min_node:setVisible(false)
	--初始化玩家手中的牌  bengin
	local countlist = m.kHandCardCount
	for i = 1, gt.GAME_PLAYER do
	    local chair = i - 1
	    local viewId = self:SwitchViewChairID(chair)
	    local cards = {}
	    local count = countlist[i]
	  
	    if gt.MY_VIEWID == viewId then
	        local tmp = m.kHandCardData
	        for j = 1, count do
	            table.insert(cards, tmp[j])
	        end
	        self.PokerNum = count
	        cards = GameLogic:SortCardList(cards, count, 0)
	    else
	        cards = self:emptyCardList(count)
	    end
	    self.m_tabNodeCards[viewId]:updateCardsNode(cards, (viewId == gt.MY_VIEWID), false)
	end
	---------end
	gt.log("m.kPlayStatus=========",m.kPlayStatus)
	if m.kPlayStatus == 1 then -- 叫分 阶段 
		for i =1 , gt.GAME_PLAYER do
			self.nodePlayer[i]:getChildByName("icon"):setVisible(true)
			local id = self:getTableId(i-1)
			local num = m.kScoreInfo[i]
			if num ~= 255 then 
				self:showX((i-1),m.kScoreInfo[i])
			end
		end
		if m.kCurrentUser == self.UsePos then 
			if self.data.kPlaytype[1] ~= 3 then  
				for i = 1 , 3 do
					if i <= m.kBankerScore then 
						self.callscore_control:getChildByName("score_btn"..i):setEnabled(false)
					else
						self.callscore_control:getChildByName("score_btn"..i):setEnabled(true)
					end
				end
				self.callscore_control:setVisible(true)
			else
				self.callscore_control1:setVisible(true)
			end
			if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 then 
    			self.callscore_control1:setVisible(true)
    			self.callscore_control:setVisible(false)
    		else
    			self.callscore_control1:setVisible(false)
    			self.callscore_control:setVisible(true)
    		end
		end
		if m.kOnlyCall == 1 then 
			self.callscore_control:getChildByName("score_btn0"):setEnabled(false)
			self.callscore_control1:getChildByName("score_btn0"):setEnabled(false)
		end
	elseif m.kPlayStatus == 2 then  -- t踢牌阶段
		if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 and m.kBankerScore then
			self:findNodeByName("num_beishu_1"):setString("倍数:"..m.kBankerScore)
			self:findNodeByName("room_beishu_lbl"):setString("倍数:".. m.kBankerScore)
			self.beishu = m.kBankerScore
		end


		--local node = self:findNodeByName("game_info")	self:findNodeByName("t2",node):setString(m.kBankerScore)
		for i = 1, gt.GAME_PLAYER do
			local id = self:getTableId(i-1)
			if m.ktype[i] ~= 0 then 
				self._ti[id]:loadTexture(id <= 2 and "ddz/l"..m.kActSelect[i]..m.ktype[i]..".png" or "ddz/r"..m.kActSelect[i]..m.ktype[i]..".png")
				self._ti[id]:setVisible(true)
				
				self.m_UserHead[id].t_icon:loadTexture(tonumber(m.ktype[i]) == 133 and "ddz/hhh.png" or "ddz/ttt.png")
				self.m_UserHead[id].t_icon:setVisible(tonumber(m.kActSelect[i]) ~= 0)

				-- if self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)) then
		  		-- local ani_id = self._node:getChildByName("wanjia_" .. id):getTag() - 1000
		  		-- -- gt.log("ani_id======",ani_id)
			  	-- if tonumber(ani_id) > 0 then
			  	-- 	self.playingNode[ani_id]:getChildByName("Image_1"):setVisible(true)
			  	-- 	self.playingNode[ani_id]:getChildByName("Image_1"):loadTexture(tonumber(m.ktype[i]) == 133 and "ddz/hhh.png" or "ddz/ttt.png")
			  	-- end
			else

				self._ti[id]:setVisible(false)
				self.m_UserHead[id].t_icon:setVisible(false)
			end
			-- self.nodePlayer[id]:getChildByName("icon"):setVisible(false)
			self.nodePlayer[id]:setVisible(false)
			 if (i-1) == m.kBankerUser then 
		    	gt.log("c__________")
				-- self.m_UserHead[id].maozi:loadTexture("ddz/dizhu_m.png")
				-- self:addPlayerAction(id, "dizhu", "run_daiji_action" )
				self.playingNode[3]:setVisible(true)
		    	-- self.playingNode[3]:setPosition(self:findNodeByName("chat_head_action_" .. id):getPosition())
				local posX = self:findNodeByName("chat_head_action_" .. id):getPositionX()
		    	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY()
		    	if id == 3 then
		    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() + 100
		    	else
		    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() - 100
		    		-- if viewId == 2 then
		    		-- 	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY() + 20
		    		-- end
		    	end
		    	self.playingNode[3]:setPosition(cc.p(posX,posY))
		    	self.playingAni[3]:play("run_daiji_action", true)
		    	self.playingNode[3]:setName("wanjia_" .. id)
		    	-- self.playingNode[3]:getChildByName("name"):setString(self.Player[id].name)
	    		local player_action = self:findNodeByName("player_action_" .. id)
				player_action:setVisible(true)
				player_action:getChildByName("score"):setString(self.tallScore[id])
                --玩家昵称
				--player_action:getChildByName("name"):setString(gt.checkName(self.Player[id].name,3))
				player_action:getChildByName("name"):setString(self.Player[id].name)
			else
				-- self.m_UserHead[id].maozi:loadTexture("ddz/pingmin_m.png")
				-- self:addPlayerAction(id, "nongmin", "run_daiji_action" )
		   		if id == 1 or (self:SwitchViewChairID(m.kBankerUser) == 1 and id == 2) then
		   			self.playingNode[1]:setVisible(true)
			    	-- self.playingNode[1]:setPosition(self:findNodeByName("chat_head_action_" .. id):getPosition())
					local posX = self:findNodeByName("chat_head_action_" .. id):getPositionX()
			    	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY()
			    	if id == 3 then
			    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() + 100
			    	else
			    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() - 100
			    		-- if viewId == 2 then
			    		-- 	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY() + 20
			    		-- end
			    	end
			    	self.playingNode[1]:setPosition(cc.p(posX,posY))
			    	self.playingAni[1]:play("run_daiji_action", true)
			    	self.playingNode[1]:setName( "wanjia_" .. id)
			    	-- self.playingNode[1]:getChildByName("name"):setString(self.Player[id].name)
			    	local player_action = self:findNodeByName("player_action_" .. id)
					player_action:setVisible(true)
					player_action:getChildByName("score"):setString(self.tallScore[id])
                    --玩家昵称
					--player_action:getChildByName("name"):setString(gt.checkName(self.Player[id].name,3))
					player_action:getChildByName("name"):setString(self.Player[id].name)
			    else
			    	self.playingNode[2]:setVisible(true)
			    	-- self.playingNode[2]:setPosition(self:findNodeByName("chat_head_action_" .. id):getPosition())
					local posX = self:findNodeByName("chat_head_action_" .. id):getPositionX()
			    	local posY = self:findNodeByName("chat_head_action_" .. id):getPositionY()
			    	if id == 3 then
			    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() + 100
			    	else
			    		posX = self:findNodeByName("chat_head_action_" .. id):getPositionX() - 100
			    		-- if viewId == 2 then
			    		-- 	local posY = self:findNodeByName("chat_head_action_" .. viewId):getPositionY() + 20
			    		-- end
			    	end
			    	self.playingNode[2]:setPosition(cc.p(posX,posY))
			    	self.playingAni[2]:play("run_daiji_action", true)
			    	self.playingNode[2]:setName( "wanjia_" .. id)
			    	-- self.playingNode[2]:getChildByName("name"):setString(self.Player[id].name)
			    	local player_action = self:findNodeByName("player_action_" .. id)
					player_action:setVisible(true)
					player_action:getChildByName("score"):setString(self.tallScore[id])
                    --玩家昵称
					--player_action:getChildByName("name"):setString(gt.checkName(self.Player[id].name,3))
					player_action:getChildByName("name"):setString(self.Player[id].name)
		   		end
		   		local ani_id = self._node:getChildByName("wanjia_" .. id):getTag() - 1000
		  		-- gt.log("ani_id======",ani_id)
		  					  		gt.log("i====",i)
			  		gt.log("m.kActSelect[i]=",m.kActSelect[i])
			  	if tonumber(ani_id) > 0 then
			  		self.playingNode[ani_id]:getChildByName("Image_1"):loadTexture(tonumber(m.ktype[i]) == 133 and "ddz/hhh.png" or "ddz/ttt.png")
			  		self.playingNode[ani_id]:getChildByName("Image_1"):setVisible(tonumber(m.kActSelect[i]) ~= 0)
			  		gt.log("11111i====",i)
			  		gt.log("11111m.kActSelect[i]=",m.kActSelect[i])
			  	end
			end
		end

		self.bankerViewId = self:SwitchViewChairID(m.kBankerUser)

		if self.bankerViewId == gt.MY_VIEWID then
			local bug = self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:getChildren()
	    	for i =  1  , #bug do 
	    		if i == #bug then
	    	 	local spr = cc.Sprite:create("ddz/dizhu_i.png")
	    	 	spr:setAnchorPoint(cc.p(1,1))
	    	 	if spr then 
	    	 		spr:setName(gt.MY_VIEWID.."dizhu___"..i)
	    	 		bug[i]:addChild(spr)
	    	 		spr:setPosition(cc.p(153,234))
	    	 	end
	    	 	end
	    	end
		end
		gt.log(">>>>>>>>>>>>>>>>>.....gt.di_card==",gt.di_card)
		gt.dump(m.kBankerCard)
		self.d_card:setVisible(gt.di_card == 3)
		self.d_card1:setVisible(gt.di_card == 4)
		self.card_banker_data = {}
		self.d_card_center:setVisible(false)
		self.d_card_center_hua:setVisible(false)
		for i = 1, gt.di_card do
			if m.kBankerCard[i] then 
				if gt.di_card == 3 then 
					self.d_card:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(m.kBankerCard[i])..".png")
				elseif gt.di_card == 4 then 
					self.d_card1:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(m.kBankerCard[i])..".png")
				end
			end
			-- self.card_banker_data[i] = m.kBankerCard[i]
		end
		if self.d_card:isVisible() or self.d_card1:isVisible() then
			self:findNodeByName("times"):setVisible(false)
		end
	elseif m.kPlayStatus == 3 then -- 游戏中
		gt.log("-- 游戏中")
		if self.data.kPlaytype[8] and self.data.kPlaytype[8] == 1 and m.kBankerScore then
			self:findNodeByName("num_beishu_1"):setString("倍数:"..m.kBankerScore)
			self:findNodeByName("room_beishu_lbl"):setString("倍数:".. m.kBankerScore)
			self.beishu = m.kBankerScore
		else
			-- local node = self:findNodeByName("game_info")	self:findNodeByName("t2",node):setString("叫分:"..m.kBankerScore)
			if m.kBankerScore then
				self:findNodeByName("num_beishu_1"):setString("叫分:"..m.kBankerScore)
				self:findNodeByName("room_beishu_lbl"):setString("叫分:".. m.kBankerScore)
				self.beishu = m.kBankerScore
				gt.log("brank____________")
			end
		end
		for i = 1, gt.GAME_PLAYER do
			local viewId = self:SwitchViewChairID(i-1)
			self.nodePlayer[viewId]:setVisible(false)
			gt.log("m.kBankerUser =======" .. m.kBankerUser)
		    if (i-1) == m.kBankerUser then 
		    	gt.log("c__________")
				-- self.m_UserHead[viewId].maozi:loadTexture("ddz/dizhu_m.png")
				-- self:addPlayerAction(viewId, "dizhu", "run_daiji_action" )
				self.playingNode[3]:setVisible(true)
		    	-- self.playingNode[3]:setPosition(self:findNodeByName("chat_head_action_" .. viewId):getPosition())
				local posX = self:findNodeByName("chat_head_action_" .. viewId):getPositionX()
		    	local posY = self:findNodeByName("chat_head_action_" .. viewId):getPositionY()
		    	if viewId == 3 then
		    		posX = self:findNodeByName("chat_head_action_" .. viewId):getPositionX() + 100
		    	else
		    		posX = self:findNodeByName("chat_head_action_" .. viewId):getPositionX() - 100
		    		-- if viewId == 2 then
		    		-- 	local posY = self:findNodeByName("chat_head_action_" .. viewId):getPositionY() + 20
		    		-- end
		    	end
		    	self.playingNode[3]:setPosition(cc.p(posX,posY))
		    	self.playingAni[3]:play("run_daiji_action", true)
		    	self.playingNode[3]:setName("wanjia_" .. viewId)
		    	self.playingNode[3]:getChildByName("name"):setString(self.Player[viewId].name)
			else
				-- self.m_UserHead[viewId].maozi:loadTexture("ddz/pingmin_m.png")
				-- self:addPlayerAction(viewId, "nongmin", "run_daiji_action" )
				if viewId == 1 or  (self:SwitchViewChairID(m.kBankerUser) == 1 and viewId == 2)  then
		   			self.playingNode[1]:setVisible(true)
			    	-- self.playingNode[1]:setPosition(self:findNodeByName("chat_head_action_" .. viewId):getPosition())
					local posX = self:findNodeByName("chat_head_action_" .. viewId):getPositionX()
			    	local posY = self:findNodeByName("chat_head_action_" .. viewId):getPositionY()
			    	if viewId == 3 then
			    		posX = self:findNodeByName("chat_head_action_" .. viewId):getPositionX() + 100
			    	else
			    		posX = self:findNodeByName("chat_head_action_" .. viewId):getPositionX() - 100
			    		-- if viewId == 2 then
		    			-- 	local posY = self:findNodeByName("chat_head_action_" .. viewId):getPositionY() + 20
		    			-- end
			    	end
			    	self.playingNode[1]:setPosition(cc.p(posX,posY))
			    	self.playingAni[1]:play("run_daiji_action", true)
			    	self.playingNode[1]:setName( "wanjia_" .. viewId)
			    	self.playingNode[1]:getChildByName("name"):setString(self.Player[viewId].name)

			    else
			    	self.playingNode[2]:setVisible(true)
			    	-- self.playingNode[2]:setPosition(self:findNodeByName("chat_head_action_" .. viewId):getPosition())
					local posX = self:findNodeByName("chat_head_action_" .. viewId):getPositionX()
			    	local posY = self:findNodeByName("chat_head_action_" .. viewId):getPositionY()
			    	if viewId == 3 then
			    		posX = self:findNodeByName("chat_head_action_" .. viewId):getPositionX() + 100
			    	else
			    		posX = self:findNodeByName("chat_head_action_" .. viewId):getPositionX() - 100
			    		-- if viewId == 2 then
		    			-- 	local posY = self:findNodeByName("chat_head_action_" .. viewId):getPositionY() + 20
		    			-- end
			    	end
			    	self.playingNode[2]:setPosition(posX,posY)
			    	self.playingAni[2]:play("run_daiji_action", true)
			    	self.playingNode[2]:setName( "wanjia_" .. viewId)
			    	-- self.playingNode[2]:getChildByName("name"):setString(self.Player[viewId].name)
		   		end
			end
			local player_action = self:findNodeByName("player_action_" .. viewId)
			player_action:setVisible(true)
			player_action:getChildByName("score"):setString(self.tallScore[viewId])
			player_action:getChildByName("name"):setString(self.Player[viewId].name)


			-- if self.data.kPlaytype[5] == 1 then
			-- 	local ani_id = self._node:getChildByName("wanjia_" .. gt.MY_VIEWID):getTag()- 1000
			-- 	for i=1,3 do
			-- 		if ani_id ~= i then
			-- 			self.playingNode[i]:getChildByName("name"):setVisible(false)
			-- 			self.playingNode[i]:getChildByName("bg"):setVisible(false)
			-- 		end
			-- 		local player_action = self:findNodeByName("player_action_" .. i)
			-- 		player_action:getChildByName("score"):setVisible(false)
			-- 		player_action:getChildByName("bg"):setVisible(false)
			-- 	end			
			-- end

			-- self.m_UserHead[viewId].maozi:setVisible(true)
			local id = viewId
			if m.ktype[i] ~= 0 then
				self.m_UserHead[id].t_icon:loadTexture(tonumber(m.ktype[i]) == 133 and "ddz/hhh.png" or "ddz/ttt.png")
				self.m_UserHead[id].t_icon:setVisible(tonumber(m.kActSelect[i]) ~= 0)

				-- if self._node:getChildByName("wanjia_" .. self:getTableId(self.UsePos)) then
		  		local ani_id = self._node:getChildByName("wanjia_" .. id):getTag() - 1000
		  		gt.log("ani_id======",ani_id)
			  	if tonumber(ani_id) > 0 then
			  		self.playingNode[ani_id]:getChildByName("Image_1"):loadTexture(tonumber(m.ktype[i]) == 133 and "ddz/hhh.png" or "ddz/ttt.png")
			  		self.playingNode[ani_id]:getChildByName("Image_1"):setVisible(tonumber(m.kActSelect[i]) ~= 0)
			  	end
			else
				self._ti[id]:setVisible(false)
				self.m_UserHead[id].t_icon:setVisible(false)
			end
		end

		self.bankerViewId = self:SwitchViewChairID(m.kBankerUser)
		--如果自己是地主
		if self.bankerViewId == gt.MY_VIEWID then
			local bug = self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:getChildren()
	    	for i =  1  , #bug do 
	    		if i == #bug then
	    	 	local spr = cc.Sprite:create("ddz/dizhu_i.png")
	    	 	spr:setAnchorPoint(cc.p(1,1))
	    	 	if spr then 
	    	 		spr:setName(gt.MY_VIEWID.."dizhu___"..i)
	    	 		bug[i]:addChild(spr)
	    	 		spr:setPosition(cc.p(153,234))
	    	 	end
	    	 	end
	    	end
		end
		gt.log(">>>>>>>>>>>>>>>>>.....gt.di_card==",gt.di_card)
		gt.dump(m.kBankerCard)
		self.d_card:setVisible(gt.di_card == 3)
		self.d_card1:setVisible(gt.di_card == 4)
		self.card_banker_data = {}
		self.d_card_center:setVisible(false)
		self.d_card_center_hua:setVisible(false)
		for i = 1, gt.di_card do
			if m.kBankerCard[i] then 
				if gt.di_card == 3 then 
					self.d_card:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(m.kBankerCard[i])..".png")
				elseif gt.di_card == 4 then 
					self.d_card1:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(m.kBankerCard[i])..".png")
				end
			end
			-- self.card_banker_data[i] = m.kBankerCard[i]
		end
		if self.d_card:isVisible() or self.d_card1:isVisible() then
			self:findNodeByName("times"):setVisible(false)
		end

		-- if gt.di_card == 3 then
		-- 	self.d_card:setVisible(false)
		-- end
			

		   -- 出牌信息          
		gt.log("出牌信息    ........")                             
	    local lastOutView = self:SwitchViewChairID(m.kTurnWiner)
	    local outCards = {}
	    local serverOut = m.kTurnCardData
	    for i = 1, m.kTurnCardCount do
	        table.insert(outCards, serverOut[i])
	    end
	    outCards = GameLogic:SortCardList(outCards, m.kTurnCardCount, 0)
	    gt.log("outCards..................................")
	    gt.dump(outCards)
	    -- self:updatePromptList(tmp, handCards, self:getTableId(m.kOutCardUser), gt.MY_VIEWID,self.data.kPlaytype[1])
	 ---  self:compareWithLastCards(outCards,lastOutView,self.data.kPlaytype[1])
	 	local currentView = self:SwitchViewChairID(m.kCurrentUser)
     	if  #outCards > 0 then
	    	gt.log("lastOutView..........",lastOutView)
	        local vec = self.m_tabNodeCards[lastOutView]:outCard(outCards,true)
	        self:outCardEffect(lastOutView, outCards, vec)
	        if currentView ~= gt.MY_VIEWID then 
	        	self:updatePromptList(outCards, self.m_tabNodeCards[gt.MY_VIEWID]:getHandCards(), currentView, lastOutView,self.data.kPlaytype[1])
	        end
	    end

	   
		local bool = false
		gt.log("显示出牌信息。。。。。。。")
		
		-- self:gameClock(m.kCurrentUser, TIME)

       	if currentView == gt.MY_VIEWID then
            -- 构造提示
            self.m_outCardsControl:removeChildByTag(gt.MY_VIEWID)
            local handCards = self.m_tabNodeCards[gt.MY_VIEWID]:getHandCards()
            
            self:updatePromptList(outCards, handCards, currentView, lastOutView,self.data.kPlaytype[1])
            self.operation:setVisible(true)
            --xyc去除自动出牌
         	if #self.m_tabPromptList > 0 then
         		self:auto_push_card(self.m_tabPromptList)
         		if #outCards == 0 then
         			self:switch_operation(0, 1, 0)
         		else
         			self:switch_operation(1, 1, 0)
         		end
         	--	self:onPromptOut()
			gt.log("显示出牌信息。。。。。。。#self.m_tabPromptList > 0 ")
	        else
	        	self.textnot:setVisible(true)
	            self:switch_operation(1, 0, 0)
	        gt.log("111111显示出牌信息。。。。。。。#self.m_tabPromptList 《= 0 ")

	        end  
	        if #outCards ==0 then -- 上家没有出牌 该自己出 隐藏不出按钮
	        	-- self:auto_push_card(self.m_tabPromptList)
	        	--gt.soundEngine:playMusic_poker("sound_res/ddz/bg_zc.wav",true)
	        	self:showX()
	        	bool = true
            	-- self:switch_operation(0, 1, 0)
            	gt.log("22222显示出牌信息。。。。。。 #outCards ==0")
       		end
        end
	  	
	        

	       -- self:onGetOutCard(currentView, lastOutView, outCards, true)

		  

	        -- 设置倒计时
	        
	 --   end
		if m.kTurnWiner ~= (m.kCurrentUser+2)%3 and not bool then

			self:showX((m.kCurrentUser+2)%3,4)

		end
        -- self:onGetOutCard(currentView, lastOutView, outCards, true)
	end
	gt.log(">>>>>>>>>>>>>>>??????????????? TIME=",TIME)
	gt.dump(m.kCurrentUser)

		--防作弊状态下只有才能显示自己的信息
   -- if self.data.kPlaytype[5] == 1 and gt.MY_VIEWID == id then
   gt.log(">>>>>>?????????????????????==============gt.MY_VIEWID=",gt.MY_VIEWID)
   -- if gt.MY_VIEWID == id then
   --  local ani_id = self._node:getChildByName("wanjia_" .. id):getTag() - 1000
   --  gt.log("ani_id======11111111111",ani_id)
   --    if tonumber(ani_id) > 0 then
   --     self.playingNode[ani_id]:getChildByName("name"):setVisible(true)
   --     self.playingNode[ani_id]:getChildByName("bg"):setVisible(true)
   --     self.playingNode[ani_id]:getChildByName("name"):setString(self.Player[gt.MY_VIEWID].name)
   --    end
   --    player_action = self:findNodeByName("player_action_" .. 2)
   --    player_action:setVisible(true)
   -- end




	self:gameClock(m.kCurrentUser, TIME)
end


function ddzScene:onNodeEvent(eventName)
	log("enter_______",eventName)
	if "enter" == eventName then  --进入场景
		
	elseif "exit" == eventName or "cleanup" == eventName then  --退出场景

		self:remove_Self()	

	end
end

--退出场景  
function ddzScene:remove_Self()
	gt.log("remove)______________")
	if 	self.__time then _scheduler:unscheduleScriptEntry(self.__time) self.__time = nil end	
	self:KillGameClock()
	self:ActionText5(false)
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("ddz/animation.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("ddz/animation.png")
	--self:m_removeAnimation("rocket_key")
	self:m_removeAnimation("alarm_key")
	--self:m_removeAnimation("bomb_key")
	--self:m_removeAnimation("airship_key")
	for i =1 , #gt.poker_node do
        cc.Director:getInstance():getTextureCache():removeTextureForKey(gt.poker_node[i]) 
        cc.Director:getInstance():getTextureCache():removeTextureForKey(gt.poker_node1[i]) 
    end

    if nil ~= self.m_actRocketRepeat then
        self.m_actRocketRepeat:release()
        self.m_actRocketRepeat = nil
    end

    if nil ~= self.m_actRocketShoot then
        self.m_actRocketShoot:release()
        self.m_actRocketShoot = nil
    end

    if nil ~= self.m_actPlaneRepeat then
        self.m_actPlaneRepeat:release()
        self.m_actPlaneRepeat = nil
    end

    if nil ~= self.m_actPlaneShoot then
        self.m_actPlaneShoot:release()
        self.m_actPlaneShoot = nil
    end

    if nil ~= self.m_actBomb then
        self.m_actBomb:release()
        self.m_actBomb = nil
    end

	-- -- voicelist
	-- if self.voiceListListener then
	-- 	gt.scheduler:unscheduleScriptEntry(self.voiceListListener)
	-- 	self.voiceListListener = nil
	-- end
end


function ddzScene:app_store()

	self:findNodeByName("Image_12"):setVisible(false)
	self:findNodeByName("chat"):setVisible(false)
	self:findNodeByName("voice"):setVisible(false)
	self.m_btnInvite:setVisible(false)
	self:findNodeByName("game_info"):setVisible(false)
	self:findNodeByName("_exit"):setPositionY(self:findNodeByName("_exit"):getPositionY()+50)
	self:findNodeByName("Button_6"):setPositionY(self:findNodeByName("Button_6"):getPositionY()+50)
	self:findNodeByName("room_id_0"):setVisible(true)
	log("app______________",self.data.kDeskId)
	self:findNodeByName("room_id_0"):setString("房号："..self.data.kDeskId)

	for i = 1, 3 do
		self.m_UserHead[i].score:setScale(0.7)
		local node = self.result_min_node:getChildByName("Node_"..i)
		node:getChildByName("score"):setVisible(false)
		local node = self.result_node:getChildByName("bg"):getChildByName("player"..i)
		
		node:getChildByName("score"):setVisible(false)
	end
	self._node:getChildByName("Text_35"):setVisible(false)
end


function ddzScene:showThreeCardAction( kBankerCard )
	-- gt.di_card = 3
	-- local kBankerCard = {52,18,27,0}
	-- m.kBankerCard
	-- self.d_card_center:setVisible(gt.di_card == 3)
	gt.dump(kBankerCard)
	gt.log("gt.di_card====",gt.di_card)
	if gt.di_card == 3 then
		self.d_card_center:setVisible(true)
		self.d_card_center_hua:setVisible(false)
	elseif gt.di_card == 4 then
		self.d_card_center_hua:setVisible(true)
		self.d_card_center:setVisible(false)
	end
	-- self.d_card_center:setVisible(true)
	-- self.d_card_center = self:findNodeByName("card_d_center")
	-- self.d_card_center:setVisible(gt.di_card == 3)
	gt.dump(kBankerCard)
	local times = 0
	gt.log("..............玩法：")
	if self.data.kPlaytype[1] == 1 then 
		gt.log("经典玩法")
    	times = 0
    elseif self.data.kPlaytype[1] == 2 then 
		gt.log("带花玩法")
    	times = 2
    elseif self.data.kPlaytype[1] == 3 then 
		gt.log("临汾玩法")
    	times = 2
    end

	for i = 1, gt.di_card do
		if kBankerCard[i] then 
			if gt.di_card == 3 then 
				-- self.d_card:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(kBankerCard[i])..".png")
				self:flopAnimation(self.d_card_center:getChildByName("card_d_"..i), "poker_ddz/"..gt.tonumber(kBankerCard[i])..".png")
			elseif gt.di_card == 4 then 
				-- self.d_card1:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(kBankerCard[i])..".png")
				self:flopAnimation(self.d_card_center_hua:getChildByName("card_d_"..i), "poker_ddz/"..gt.tonumber(kBankerCard[i])..".png")
			end
			-- self.card_banker_data[i] = kBankerCard[i]
		end
	end
	gt.log(".......isVisible")
	if self.d_card_center:isVisible() then
		gt.log("显示self.d_card_center:isVisible()")
		self.d_card_center:setPosition(cc.p(638.18,507.87))
		self.d_card_center:setOpacity(255)
		self.d_card_center:setScale(1)
		local spawnAction = cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(0,200)),cc.ScaleBy:create(0.5,0.2),cc.FadeOut:create(0.5))
		local seqAction = cc.Sequence:create(cc.DelayTime:create(1),spawnAction,cc.DelayTime:create(times),cc.CallFunc:create(function(sender)
					-- sender:stopAllActions()
					-- sender:removeFromParent(true)
					--调取出三张牌显示在中间区域
				self.d_card:setVisible(true)
				self.d_card1:setVisible(false)
				for i = 1, gt.di_card do
					if kBankerCard[i] then 
						if gt.di_card == 3 then 
							self.d_card:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(kBankerCard[i])..".png")
						elseif gt.di_card == 4 then 
							self.d_card1:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(kBankerCard[i])..".png")
						end
					end
					self.card_banker_data[i] = kBankerCard[i]
				end
				if self.d_card:isVisible() or self.d_card1:isVisible() then
					self:findNodeByName("times"):setVisible(false)
				end
				self.d_card_center:stopAllActions()
			end))
		self.d_card_center:runAction(seqAction)
	end
	if self.d_card_center_hua:isVisible() then
		self.d_card_center_hua:setPosition(cc.p(648.18,497.87))
		self.d_card_center_hua:setOpacity(255)
		self.d_card_center_hua:setScale(1)
		gt.log("显示self.d_card_center_hua:isVisible()")
		local spawnAction = cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(0,200)),cc.ScaleBy:create(0.5,0.2),cc.FadeOut:create(0.5))
		local seqAction = cc.Sequence:create(cc.DelayTime:create(1),spawnAction,cc.CallFunc:create(function(sender)
					-- sender:stopAllActions()
					-- sender:removeFromParent(true)
					--调取出三张牌显示在中间区域

				self.d_card1:setVisible(true)
				self.d_card:setVisible(false)
				for i = 1, gt.di_card do
					if kBankerCard[i] then 
						if gt.di_card == 3 then 
							self.d_card:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(kBankerCard[i])..".png")
						elseif gt.di_card == 4 then 
							self.d_card1:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(kBankerCard[i])..".png")
						end
					end
					self.card_banker_data[i] = kBankerCard[i]
				end
				if self.d_card:isVisible() or self.d_card1:isVisible() then
					self:findNodeByName("times"):setVisible(false)
				end
				self.d_card_center_hua:stopAllActions()
			end))
		self.d_card_center_hua:runAction(seqAction)
	end
end


return ddzScene

