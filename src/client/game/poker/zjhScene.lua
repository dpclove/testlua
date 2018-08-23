

local base = require("client.game.poker.baseGame")


local CompareView = require("client.game.poker.view.CompareView")
local SettingLayer = require("client.game.poker.view.SettingLayer")


local zjhScene = class("zjhScene", base)

-- error 1360
-- wx36201a74410db977

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
local CHIPNUM 				= 100

local MY_VIEWID          = 3
local GAME_PLAYER         = 8



local TIME_USER_ADD_SCORE = 30

zjhScene.ZOrder = {
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

local ptChat = {cc.p(346.50, 699), cc.p(143.50, 550), cc.p(140.50, 321), cc.p(1189.50, 547), cc.p(988.50, 695.00)}
local ptCard

local scale = 0.47
local scale1 = 0.75
local distanceCard = 30.5
local distanceCards = 73 





local _scheduler = gt._scheduler
local log = gt.log


function zjhScene:init(args)

	self.t_time = socket.gettime()

	gt.gameType = "zjh"
	

	MY_VIEWID          = gt.MY_VIEWID 
	GAME_PLAYER         = gt.GAME_PLAYER


	self:switch_bg(cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, 1))

	
	self:initData()
	self:initBtnandNode()	
	self:GameLayerRefresh(args)
	self:addPlayer()
	self._node:getChildByName("Text_23"):setString("v:21")

end



function zjhScene:switch_bg(idx)

	if idx == 1 then 
		self:findNodeByName("bg"):loadTexture(GAME_PLAYER == 5 and "bg2.png" or "bg.png")
		self:findNodeByName("bg1"):setLocalZOrder(9999)
		self:findNodeByName("bg1"):setVisible(false)
	elseif idx == 2 then 
		self:findNodeByName("bg"):loadTexture(GAME_PLAYER == 5 and "bg1.png" or "bg3.png")
		self:findNodeByName("bg1"):setLocalZOrder(9999)
		self:findNodeByName("bg1"):setVisible(true)
	end


end


function zjhScene:OnResetView()
	self:GameLayerRefreshlunshu()
	self:stopAllActions()
	self:KillGameClock()
	self.player_viewid = {}
	self.is_auto = true
	self:switchAuto(1)
	self.usergiveup = false
	--self.game_end = false
	self.btReady:setVisible(false)
	self.iskanpai = false
	self.m_ChipBG:setVisible(false)
	self.nodeButtomButton:setVisible(false)
   -- self.m_GameEndView:setVisible(false)b
   	self:ActionText3(false)
   	self:ActionText7(false)  
   	
   --	self:ActionText5(false)
   	self.text2:setVisible(false)
   	self.text1:setVisible(false)
	self:SetBanker(gt.INVALID_CHAIR)
	self:SetAllTableScore(0)
	self:refreshTotalScore(0)
	self:SetCompareCard(false)
	self:CleanAllJettons()
	self:StopCompareCard()
	self:SetMaxCellScore(0)
	self.btLookCard:setVisible(true)
	self._difen = 0
	self:my_hui(false)
	self.qipai = false
	self.guancha = false
	self._node:getChildByName("Panel_hui"):setVisible(false)

	self.auto_btn:setEnabled(true)
    if self._resule_spr then self._resule_spr:removeFromParent() self._resule_spr = nil end 
	self.card_type_buf = {}

	self:my_win(false)
	self:my_compare_card_win(false)
	self._ready = {false,false,false,false,false}
	

	for i = 1 , #self.tmpCard do
		if self.tmpCard[i] then
			self.tmpCard[i]:removeFromParent()
			self.tmpCard[i] = nil
		end
	end
	self.tmpCard = {}

	
	for k , y in pairs(self.chips) do
		y:setColor(cc.c3b(255,255,255))
		y:setEnabled(true)
	end
	self.chip_num = 0
	self.wait = false
	self.max_chip = false
	

	for i = 1 ,GAME_PLAYER do
		self._mai[i]:setVisible(false)
		self.nodePlayer[i]:setPosition(self.PX[i],self.PY[i]) -- cde
		self:findNodeByName("clock",self.nodePlayer[i]):setVisible(false)
		--self.nodePlayer[i]:setVisible(true)
		-- self._voice[i]:setVisible(false)
		-- self._voice_node[i]:setVisible(false)
		self.sign[i]:setVisible(false)
		self.liuchang_sign[i]:setVisible(false)
		self.hui_bg[i]:setVisible(false)
		self.comPokeLose[i]:setVisible(false)
		self.m_UserHead[i].quanquan:stopAllActions()
		self.m_UserHead[i].quanquan:setVisible(false)
		self.m_UserHead[i].hg:setVisible(false)
		self.nodePlayer[i]:getChildByName("sp_8"):setVisible(false)
		if GAME_PLAYER == 5 then 
		if i == 2 or i == 4 then self.userCard[i].resultScore:setPosition(self._node:getChildByName("Node_"..i):getPosition()) end
		end
		self.userCard[i].resultScore:setVisible(false)
		self:SetLookCard(i, false)
		self:SetUserCardType(i)
		self:SetUserTableScore(i, 0)
		self:SetUserGiveUp(i,false)
		self:SetUserCard(i,nil)
        self:clearCard(i)
        self.qi_pai[i]:setVisible(false)
		local nodeCard = self.userCard[i]
		nodeCard.area:setVisible(false)
	end
	--if self._clockGameStart then _scheduler:unscheduleScriptEntry(self._clockGameStart) self._clockGameStart = nil end
	self:removeActionHuo()
	self.___node = nil
	self.baoji = false
	self.shuohua = false
	self.action = false
	self.action1 = false
	self.action2 = false
	self.compareidx = 0
	self:findNodeByName("mai_text"):setVisible(false)
	log("a______________")
	self.maixiao_btn:setVisible(false)
	self.maida_btn:setVisible(false)

end



function zjhScene:initData()

	self.__clock = 15
	self.fapai = false
	self.usergiveup = false  -- 用户是否主动弃牌
	self.compareidx = 0 
	self.___jushu = 1 
	self._ready = {} -- 准备数组
	self.action = false -- 是否在弃牌动画中
	self.action1 = false -- 是否在比牌动画中
	self.action2 = false -- 是否在自动比牌动画中
	self.card_type_buf = {}
	self.player_viewid = {}
	self.bCompareChoose = false
	self.is_auto = false
	self.m_cbPlayStatus = {0, 0, 0, 0, 0}
		--玩家
	self.tmpCard = {} -- 输牌回收器
	self.look_card = {} -- 看牌标志
	self.nodePlayer = {}
	--比牌判断区域
	self.rcCompare = {}

	self.m_UserHead = {}
	self.Player = {}

		--时钟
	self.m_TimeProgress = {}
	self.m_sprite = {}
	self.head_hui = {}
	self.m_BankerFlag = {}

		--比牌箭头
	self.m_flagArrow = {}
    
    self.jiantouposx = {}
    self.jiantouposy = {}
    self.hui_bg = {}
    self.sign = {}
    self.liuchang_sign = {}
    self.PX = {}
   	self.PY = {}
   	self._voice = {}
   	self._voice_node = {}
   	self._voice_nodes = {}

   	self.__chip = {}
   	self.__chipPosX = {}
   	self.__chipPosY = {}
   	self.qi_pai = {}

   	--手牌显示
	self.userCard = {}
	--下注显示
	self.m_ScoreView = {}
	--准备显示
	self.m_flagReady = {}

	--看牌标示
	self.m_LookCard = {}
	--弃牌标示
	self.m_GiveUp = {}
	self.comPokeLose = {}

		--缓存聊天--聊天泡泡
	self.m_UserChatView = {}
	self._mai = {}
	self.urlName = {}
	self._sche_url = {}
	self._sche_time = {}
	self.MyCardPosY = 0
	self.m_UserChat = {}
	self._sche_buf = {}
	local node = self._node


	if GAME_PLAYER == 8 then 
		ptCard = {cc.p(671,678),  cc.p(375,651.00), cc.p(183.60,482.94), cc.p(134.00,310.02), cc.p(550.89, 88.59), cc.p(1195.18,308.66), cc.p(1155.49,487.66), cc.p(957.64,652.18)} --25
		scale = 0.4
		distanceCard = 25
		distanceCards = 62
	elseif GAME_PLAYER == 5 then 
		 ptCard = {cc.p(397-13, 632+2), cc.p(187-13, 411+2), cc.p(550.89, 103.59), cc.p(1145+8, 410+2), cc.p(941+8, 631+2)} -- 3  122.39  scale(75) else  36.5 scale(47)
		 scale = 0.47
		 distanceCard = 30.5
		 distanceCards = 73
	end

	
   	for i = 1, GAME_PLAYER do
   	

		self["voiceUrl"..(i-1)] = {}
		
		--self._mai[i] = self:findNodeByName("mai"..i)
		self.qi_pai[i] = self:findNodeByName("qi_pai_"..i)
		:setVisible(false)

		self.m_flagArrow[i] = self:findNodeByName("combg_47_"..i)
								:setVisible(false)
		
		self.jiantouposx[i] = self.m_flagArrow[i]:getChildByName("jiantou"):getPositionX()
		self.jiantouposy[i] = self.m_flagArrow[i]:getChildByName("jiantou"):getPositionY()
		self.nodePlayer[i] = self:findNodeByName("player_"..i)
		self.PX[i] = self.nodePlayer[i]:getPositionX()
		self.PY[i] = self.nodePlayer[i]:getPositionY()
		self.nodePlayer[i]:setVisible(false)		
		self.rcCompare[i] = cc.rect(self.m_flagArrow[i]:getPositionX() - 143 , self.m_flagArrow[i]:getPositionY() -98 , 286 , 196)

		self.m_sprite[i] = cc.Sprite:create("player/sp.png")
		self.m_TimeProgress[i] = cc.ProgressTimer:create(self.m_sprite[i])

			 :addTo(self.nodePlayer[i])
             :setReverseDirection(true)
             :setScaleX(-1)
             :setPosition(self.nodePlayer[i]:getChildByName("sp_8"):getPosition())
             :setVisible(false)
             :setPercentage(0)


		

		if GAME_PLAYER == 5 then 
			if i <=MY_VIEWID then
			self.m_UserChatView[i] = display.newSprite("game_chat_0.png"	,{scale9 = true ,capInsets=cc.rect(30, 14, 46, 20)})
				:setAnchorPoint(cc.p(0,0.5))
				:move(ptChat[i])
				:setVisible(false)
				:addTo(self._node)
			else
			self.m_UserChatView[i] = display.newSprite( "game_chat_1.png",{scale9 = true ,capInsets=cc.rect(14, 14, 46, 20)})
				:setAnchorPoint(cc.p(1,0.5))
				:move(ptChat[i])
				:setVisible(false)
				:addTo(self._node)
			end

				self._voice[i] = self:findNodeByName("voice_"..i)
						:setVisible(false)
						:move(ptChat[i])
			
			self._voice_node[i] = self:findNodeByName("FileNode_"..i)
								:setVisible(false)
								:move(ptChat[i].x,ptChat[i].y+2)


			local sprite = i<=3 and "iconhui.png" or "iconhui1.png"
	        self.head_hui[i] = cc.Sprite:create(sprite)
	        				   :addTo(node,1100)
	        				   :setVisible(false)
	        				   :move(self.nodePlayer[i]:getPosition())


		else

			self._voice_node[i] = self:findNodeByName("FileNode_"..i)
							:setVisible(false)
							:setLocalZOrder(999)

			self._voice[i] = self:findNodeByName("voice_"..i)
							:setVisible(false)
							:setLocalZOrder(1000)

			if i <=MY_VIEWID or i == GAME_PLAYER then
				self.m_UserChatView[i] = display.newSprite("game_chat_s0szp.png"	,{scale9 = true ,capInsets=cc.rect(30, 14, 46, 20)})
				:setAnchorPoint(cc.p(0,0))
				:move(self._voice[i]:getPosition())
				:setVisible(false)
				:setLocalZOrder(1001)
				:addTo(self._node)
			else
					self.m_UserChatView[i] = display.newSprite( "game_chat_s1szp.png",{scale9 = true ,capInsets=cc.rect(14, 14, 46, 20)})
					:setAnchorPoint(cc.p(1,1))
					:move(self._voice[i]:getPosition())
					:setVisible(false)
					:setLocalZOrder(1001)
					:addTo(self._node)
			end
			






	        if i == MY_VIEWID then self.m_TimeProgress[i]:setScaleX(-0.8) self.m_TimeProgress[i]:setScaleY(0.8) end
	       	local sprite =(i <= MY_VIEWID or i==GAME_PLAYER) and "iconhui.png" or "iconhui1.png"

	       	log("sprite",sprite)
	       	
	        self.head_hui[i] = cc.Sprite:create(sprite)
	        				   :addTo(node,1100)
	        				   :setVisible(false)
	        				   :setScale(0.8)
	        				   :move(self.nodePlayer[i]:getPosition())




		end

		

		
		self.hui_bg[i] = self:findNodeByName("Image_"..i)
		self.hui_bg[i]:setVisible(false)

		self.Player[i] = {}
		self.Player[i].name = nil
		self.Player[i].score = nil
		self.Player[i].url = nil
		self.Player[i].sex = nil
		self.Player[i].id = nil
		self.Player[i].ip= nil
		self.Player[i].Coins= nil

		if i <=5 then 
		self.__chip[i] = self:findNodeByName("chip__"..i)
						:setVisible(false)
						:setLocalZOrder(100)
		

		self.__chipPosX[i] = self.__chip[i]:getPositionX()
		self.__chipPosY[i] = self.__chip[i]:getPositionY()

	end

		self.m_BankerFlag[i] = self.nodePlayer[i]:getChildByName("zhuang")
							   :setVisible(false)


	    self.m_UserHead[i] = {}
		--昵称
		self.m_UserHead[i].name = self.nodePlayer[i]:getChildByName("name")
			
		--金币
		self.m_UserHead[i].score =  self.nodePlayer[i]:getChildByName("score")
			
		self.m_UserHead[i].hg = self.nodePlayer[i]:getChildByName("hg")
		self.m_UserHead[i].quanquan = self.nodePlayer[i]:getChildByName("quanquan")


		
		
							--:move(ptChat[i].x,ptChat[i].y+2)
		
							
		gt.setOnViewClickedListener(self.nodePlayer[i],function()
			self:PlaySound("sound_res/cli.mp3")
			self:showPlayerinfo(i)

			end)

			
		
		self.sign[i] = self:findNodeByName("sign"..i)
		self.sign[i]:setVisible(false)
		self.sign[i]:setLocalZOrder(101)


		
		self.liuchang_sign[i] = self:findNodeByName("guang"..i)
		self.liuchang_sign[i]:setLocalZOrder(1000)
		self.liuchang_sign[i]:setVisible(false)
		
		


 	








		self.m_ScoreView[i] = self:findNodeByName("score_"..i)
		self.m_ScoreView[i]:setLocalZOrder(1)
		self.m_ScoreView[i]:setVisible(false)


		self.userCard[i] = {}
		self.userCard[i].card = {}
		--牌区域
		self.userCard[i].area = cc.Node:create()
			:setVisible(false)
			:addTo(node)
		--牌显示
		for j = 1, 3 do
			self.userCard[i].card[j] = ccui.ImageView:create("poker/56.png")
					
					:move(ptCard[i].x + (i==MY_VIEWID and 122.39 or distanceCard)*(j- 1),ptCard[i].y)
					:setVisible(false)
					:addTo(self.userCard[i].area)
			if i ~= MY_VIEWID then
				self.userCard[i].card[j]:setScale(scale)
			else
				self.userCard[i].card[j]:setScale(0.75)
				self.MyCardPosY = self.userCard[i].card[j]:getPositionY()
			end
			
        end

		self.userCard[i].cardType = self:findNodeByName("cardtype"..i)
		self.userCard[i].cardType:setVisible(false)
		self.userCard[i].cardType:setLocalZOrder(20)
		self.userCard[i].resultScore = self:findNodeByName("result"..i)
		self.userCard[i].resultScore:setVisible(false)

		self.m_flagReady[i] = self:findNodeByName("state"..i)
							  :setVisible(false)
		if GAME_PLAYER == 5 then 
			-- if i == 1 or i == 5 then 
			-- --	self.userCard[i].cardType:setPosition(self:findNodeByName("card_n"..i):getPosition())
			-- end
			if i == 2 or i == 4 then
				self.userCard[i].resultScore:setPosition(self:findNodeByName("Node_"..i):getPosition())
			end
			self._mai[i] = self:findNodeByName("mai"..i)
			:move(i ~= 3 and self.m_flagReady[i]:getPosition() or self.m_flagReady[i]:getPositionX(), self.m_flagReady[i]:getPositionY()-35)
			:setVisible(false)
		else
			self._mai[i] = self:findNodeByName("mai"..i)
			--:move( self.m_flagReady[i]:getPosition() )
			:setVisible(false)
		end

		
		self.m_flagReady[i] = self:findNodeByName("state"..i)
			:setVisible(false)
			


	

		self.comPokeLose[i] = self:findNodeByName("com"..i)
		self.comPokeLose[i]:setVisible(false)

		--弃牌标示
		self.m_GiveUp[i] =  self:findNodeByName("state1_"..i-1)
							:setVisible(false)
							:move(self.comPokeLose[i]:getPosition())
		--if i == MY_VIEWID then
			self.m_LookCard[i] = self:findNodeByName("state1_4_"..i-1)
		 						 :setVisible(false)
		 						 :setLocalZOrder(2)
		-- else
		-- 	self.m_LookCard[i] = cc.Sprite:create("lookcard.png")
		-- 						 :addTo(node)
		-- 						 :setVisible(false)
		-- 						 :move(self:findNodeByName("state1_4_"..i-1):getPosition())
		-- end
			
		
            
	end

	self.result_min = cc.CSLoader:createNode("result_zjh_min.csb")
	self:addChild(self.result_min)
	self.result_min:setVisible(false)

	self.result_t3= self.result_min:getChildByName("T3")

	

	self.maixiao_btn = self:findNodeByName("maixiao")
	self.maida_btn = self:findNodeByName("maida")

	for i = 2 , 3 do
		gt.setOnViewClickedListener(self:findNodeByName("mai_da"..(i-1)),function()
			self:PlaySound("sound_res/cli.mp3")
			self.maixiao_btn:setVisible(false)
			self.maida_btn:setVisible(false)
			local m = {}
			m.kMId = gt.MSG_C_S_MAIXIA
			m.kFlag = 1
			local _,socre = self:getChip_names(i+1)
			m.kScore = i == 3 and 0 or socre
			gt.dumplog(m)
	        gt.socketClient:sendMessage(m)
			end)
	end

	for i =1 , 3 do
	gt.setOnViewClickedListener(self:findNodeByName("mai_xiao"..i),function()
		self:PlaySound("sound_res/cli.mp3")
		self.maixiao_btn:setVisible(false)
		self.maida_btn:setVisible(false)
		local m = {}
		m.kMId = gt.MSG_C_S_MAIXIA
		m.kFlag = 0 
		local _,socre = self:getChip_names(i)
		m.kScore = i == 1 and 0 or socre
		gt.dumplog(m)
        gt.socketClient:sendMessage(m)
		end)
	end
	self._node:getChildByName("TotalScore"):setVisible(false)
	node:getChildByName("time"):setString(os.date("%H:%M"))
	local ready_time_node = self.nodePlayer[MY_VIEWID]:getChildByName("clock")
							--:setVisible(true)
	local ready_time = ready_time_node:getChildByName("num")
	self.text7 = self:findNodeByName("r_time")
	self.r_time = 15
	self.__time = _scheduler:scheduleScriptFunc(function()
				if node and node:getChildByName("time") then
					node:getChildByName("time"):setString(os.date("%H:%M"))
				end
				if not self.gameBegin then 
					if self.r_time <=0 then  
						if  ready_time_node:isVisible() or self.text7:isVisible() then 
							ready_time_node:setVisible(false) 
							self:ActionText7(false) 
							
						end
					else  
						if not ready_time_node:isVisible() then 
							ready_time_node:setVisible(true) 
							self:ActionText7(true) 
						end
							ready_time:setString(self.r_time)
							self.r_time = self.r_time - 1
					end
				end

			end,1,false)	
	local zjh_day = cc.UserDefault:getInstance():getIntegerForKey("zjh_day",1)
	if (tonumber(os.date("%H", os.time())) > 22 and zjh_day ~= tonumber(os.date("%d", os.time())) )  or ( tonumber(os.date("%H", os.time())) >=0 and tonumber(os.date("%H", os.time())) < 2 and zjh_day ~= tonumber(os.date("%d", os.time())) ) then
		cc.UserDefault:getInstance():setIntegerForKey("zjh_day", tonumber(os.date("%d", os.time())))
		if self:getChildByName("_settinr_node_") then self:getChildByName("_settinr_node_"):removeFromParent() end
		local settingPanel = require("client/game/majiang/Setting"):create(self)
		settingPanel:setName("_settinr_node_")
			self:addChild(settingPanel, zjhScene.ZOrder.SETTING)
	end 

end


--[[kPos    //玩家位置

    kFlag   //买大买小标记：0--买小，1--买大

    kScore  //买大买小下的分数：0--过，>0--买大买小分数
 ]]
function zjhScene:mai_xiao(msg)

	local i = self:getTableId(msg.kPos)
	if msg.kFlag == 0 then 
		--if i <= 3 then 
		if self:l_or_r(i) == "l" then
			self._mai[i]:loadTexture("zy_zjh/l".."xiao"..msg.kScore..".png")
		else
			self._mai[i]:loadTexture("zy_zjh/r".."xiao"..msg.kScore..".png")
		end
	else
		if self:l_or_r(i) == "l" then
			self._mai[i]:loadTexture("zy_zjh/l".."da"..msg.kScore..".png")
		else
			self._mai[i]:loadTexture("zy_zjh/r".."da"..msg.kScore..".png")
		end
	end
	self._mai[i]:setVisible(true)
end




--[[

	kAddScorePos   //开始下注的玩家位置

     kFlag          //最后买大买小的结果

     kScore         //最后买大买小下分的结果

     kBigSmallPos   //最终确定买大买小的玩家

     kNike          //该玩家昵称

]]
function zjhScene:mai_result( msg )
	for i =1, GAME_PLAYER do
		self._mai[i]:setVisible(false)
	end
	
	
	local node = self:findNodeByName("mai_text")
	if msg.kFlag ~= 2 then 
	
		node:setVisible(true)
		self:findNodeByName("Text_10", node):setString((msg.kFlag == 0 and "买小x" or "买大x")..msg.kScore..":"..msg.kNike)
		if msg.kTotalScore then
			self:refreshTotalScore(msg.kTotalScore)
		end
		self:PlayerJetton(self:getTableId(msg.kBigSmallPos),msg.kScore,false,false)
	else
		node:setVisible(true)
		self:findNodeByName("Text_10", node):setString("默认买大")
	end

	self.maixiao_btn:setVisible(false)
	self.maida_btn:setVisible(false)
	self.genxinBtn = false
	if  self.guancha then return end
	if  self.fapai then  
		self.msg = msg 
		log("msg________________")
		return 
	end

	self:SetGameClock(msg.kAddScorePos,TIME_USER_ADD_SCORE)
	self:Updatabtn(msg.kAddScorePos == self.UsePos)

	self.m_lCellScore = msg.kScore
	self:SetCellScore(self.m_lCellScore or 0)
	
end

function zjhScene:mai_da()

	self.maixiao_btn:setVisible(false)
	self.maida_btn:setVisible(true)
	self:SetGameClock(self.UsePos,10,1)
end


function zjhScene:onNodeEvent(eventName)
	log("enter_______",eventName)
	if "enter" == eventName then
		
	elseif "exit" == eventName or "cleanup" == eventName then 

		self:remove_Self()	

	end
end


function zjhScene:remove_Self()
	if self.shareImgFilePath  then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		self.shareImgFilePath = nil
	end

	 if self._time then
        _scheduler:unscheduleScriptEntry(self._time)
        self._time = nil
    end

	if 	self.__time then 
		_scheduler:unscheduleScriptEntry(self.__time)
		self.__time = nil
	end	
	if self.__times then _scheduler:unscheduleScriptEntry(self.__times) self.__times = nil end
	self:ActionText3(false)
		self:ActionText5(false)
		self:ActionText7(false)
		if self.scheduleHandler then  
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end

	for i =1 , GAME_PLAYER do
		if self._sche_url[i] then 
			_scheduler:unscheduleScriptEntry(self._sche_url[i])
			self._sche_url[i] = nil
		end
		if self._sche_buf[i] then 
			_scheduler:unscheduleScriptEntry(self._sche_buf[i])
			self._sche_buf[i] = nil
		end
	end
	if self._clockGameStart then _scheduler:unscheduleScriptEntry(self._clockGameStart) self._clockGameStart = nil end
	-- voicelist
	if self.voiceListListener then
		gt.scheduler:unscheduleScriptEntry(self.voiceListListener)
		self.voiceListListener = nil
	end
end

function zjhScene:initBtnandNode()

	local node = self._node
	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.began then

            --ExternalFun.popupTouchFilter(1, false)
        elseif type == ccui.TouchEventType.canceled then
            --ExternalFun.dismissTouchFilter()
        elseif type == ccui.TouchEventType.ended then
        	--ExternalFun.dismissTouchFilter()
			self:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end

	self:findNodeByName("Panel_hui"):setLocalZOrder(5000)
	self:findNodeByName("Panel_hui"):setVisible(false)

	self.gaoqing = cc.UserDefault:getInstance():getBoolForKey("game_Pattern",true)
	if not self.gaoqing then
		self:findNodeByName("PatternBtn"):loadTexture("liuchuang.png")
	else
		self:findNodeByName("PatternBtn"):loadTexture("gaoqing.png")
	end
	
	gt.setOnViewClickedListener(self:findNodeByName("PatternBtn"), function()
		self.gaoqing = not self.gaoqing
		self:isGaoqing()
		self:PlaySound("sound_res/cli.mp3")
		if not self.gaoqing then
			self:findNodeByName("PatternBtn"):loadTexture("liuchuang.png")
			for i =1 , GAME_PLAYER do
				self:actionSign(i,false)
			end
		else
			for i =1 , GAME_PLAYER do
				self:actionliuchang(i,false)
			end
			self:findNodeByName("PatternBtn"):loadTexture("gaoqing.png")
		end

		cc.UserDefault:getInstance():setBoolForKey("game_Pattern",self.gaoqing)

		end)


	self.playerInfo = cc.CSLoader:createNode("playerInfo.csb")
					  :move(gt.winCenter)
					  :addTo(self,9)
		              :setVisible(false)

	--self:_Scale(self.huoyan,2)

	self.text3 = self:findNodeByName("texttt")
    self:ActionText3(false)

    self.text5 = self:findNodeByName("wait")
    self:ActionText5(false)

    self.text2 = cc.Sprite:create("te3.png")
    self.text2:setScale(1.2)
	:addTo(self._node,1000)
	:setVisible(false)
	:move(667,400.77)




    self.text1 = cc.Sprite:create("text1.png")
    			:addTo(self._node,1000)
    			:setVisible(false)
    			:move(667,353.10)

   	self.moshi_bg = self:findNodeByName("Sprite_13")
   					:setVisible(false)
   					:setLocalZOrder(5000)


	self.hong = cc.Sprite:create("hong.png")
				:setVisible(false)
				:addTo(node,1000)
				:move(10,0)
				






	if GAME_PLAYER == 8  then 
		self.hong:setScale(0.8)
		self.hong1 = cc.Sprite:create("hong1.png")
					:setVisible(false)
					:addTo(node,1000)
	else
		self.hong1 = cc.Sprite:create("hong.png")
				:setVisible(false)
				:addTo(node,1000)
				:move(10,0)
				
	end




    gt.setOnViewClickedListener(self.moshi_bg:getChildByName("Image_20"), function()

   		self.moshi_bg:setVisible(false)
   		end)


    --底部按钮父节点
	self.nodeButtomButton = self:findNodeByName("btn")
		:setVisible(false)
		:setLocalZOrder(5)

	-- --弃牌按钮
	local but_node = self.nodeButtomButton
	self.btGiveUp = but_node:getChildByName("Button_1")
	self.btGiveUp:setEnabled(false)
	self.btGiveUp:setTag(BT_GIVEUP)
		
 	
	self.btorlookcard = but_node:getChildByName("orbtn") 
	self.btorlookcard:setVisible(false)

	--看牌按钮
	self.btLookCard = but_node:getChildByName("Button_6")
	self.btLookCard:setEnabled(false)
	self.btLookCard:setVisible(true)
	--self.btLookCard:setTag(BT_LOOKCARD)

	gt.setOnViewClickedListener(self.btLookCard,function()

		if self.iskanpai then return end
		self:_playSound(MY_VIEWID,"kanpai.mp3")
		self.m_LookCard[MY_VIEWID]:setVisible(true) 
		self.btLookCard:setVisible(false)
		self:onLookCard()

		end,0.5)

	self.btCompare = but_node:getChildByName("Button_3")	
	self.btCompare:setEnabled(false)
	self.btCompare:setTag(BT_COMPARE)
	

	self.quxiao = but_node:getChildByName("Button_10")  -- 取消比牌
				  :setVisible(false)
				  :setTag(QUXIAO)

	--加注按钮
	self.btAddScore = but_node:getChildByName("Button_4")
	self.btAddScore:setEnabled(false)
	self.btAddScore:setTag(BT_ADDSCORE)
	
	
	--跟注按钮
	self.btFollow = but_node:getChildByName("Button_2")
	self.btFollow:setEnabled(false)
	
	gt.setOnViewClickedListener(self.btFollow, function()

		gt.log("下注———————————",self.m_lCellScore)
		self:_playSound(MY_VIEWID,"genzhu.mp3")
		self.shuohua = false
		self:addScore(self.m_lCellScore,0)

		end,0.5)

	self.result_node = require("client/game/poker/view/result"):create("zjh")
	self:addChild(self.result_node)
	self.result_node:setVisible(false)
	
	self.auto_btn = but_node:getChildByName("Button_5")
	self.auto_btn:setTag(BT_AUTO)
	self.auto_btn:setVisible(false)
	
	self.autoAction = self.auto_btn:getChildByName("auto_1")
	self:isGaoqing()

	self.m_btnInvite = self:findNodeByName("Button_9")
	self.m_btnInvite:setVisible(false)
	self.m_btnInvite:setTag(BT_INVITE)
	self.begin_btn = self:findNodeByName("btn_begin")
	self.begin_btn:setTag(BT_BEGIN)
	self.begin_btn:setVisible(false)

	self.readResult = self:findNodeByName("readResult")
	self.readResult:setVisible(false)
	self.readResult:setTag(BT_READ)


		--聊天按钮
	local chat = self:findNodeByName("Button_7")
	chat:setTag(BT_CHAT)
	chat:addTouchEventListener(btcallback)



	local upMenu = node:getChildByName("up_btn")
	upMenu:setLocalZOrder(2001)
	local menu = node:getChildByName("upmenu")
	menu:setLocalZOrder(2000)
	menu:setVisible(false)
	local bools = true
	gt.setOnViewClickedListener(upMenu,function()
		if self.result then return end

		
		menu:setVisible(bools)
		self:PlaySound("sound_res/cli.mp3")
		if bools then upMenu:loadTexture("btn/down.png") else upMenu:loadTexture("btn/up1.png") end
		bools = not bools

		end)

		local cardType_node= node:getChildByName("cardTypebg")
	cardType_node:setVisible(false)
	cardType_node:setLocalZOrder(1000)
	local bool_card = true
	gt.setOnViewClickedListener(menu:getChildByName("Image_13"),function()
			self:PlaySound("sound_res/cli.mp3")

			cardType_node:setVisible(bool_card)
			bool_card = not bool_card 
		end)

	gt.setOnViewClickedListener(node:getChildByName("bg"),function()
		if self.playerInfo then self.playerInfo:setVisible(false) end
		if not bools then
		menu:setVisible(bools)
		if bools then upMenu:loadTexture("btn/down.png") else upMenu:loadTexture("btn/up1.png") end
		bools = not bools
		end
		self:findNodeByName("genzhuBg"):setVisible(false)


		if not bool_card then 
			cardType_node:setVisible(bool_card)
			bool_card = not bool_card 
		end

		self.moshi_bg:setVisible(false)

		end)



	gt.setOnViewClickedListener(menu:getChildByName("Image_12"),function()
		self:PlaySound("sound_res/cli.mp3")
		if self:getChildByName("_settinr_node_") then self:getChildByName("_settinr_node_"):removeFromParent() end
		local settingPanel = require("client/game/majiang/Setting"):create(self)
		settingPanel:setName("_settinr_node_")
			self:addChild(settingPanel, zjhScene.ZOrder.SETTING)
		end)

	local _exit = menu:getChildByName("Button_6")
	_exit:setTag(BT_EXIT) 
	_exit:addTouchEventListener(btcallback)


	local _exit1 = menu:getChildByName("_exit")
	_exit1:setTag(BT_EXIT1) 
	_exit1:addTouchEventListener(btcallback)



	--开始按钮

	self.btReady = self:findNodeByName("Button_11")
				 :setVisible(false)
			 	 :setTag(BT_READY)


   

    self.roominof = self:findNodeByName("roominof")
    self.lunshu = self.roominof:getChildByName("lunshu")


   	self.m_ChipBG = self:findNodeByName("genzhuBg")
   	self.m_ChipBG:setLocalZOrder(10)

	


	self._totalScore = self:findNodeByName("TotalScore"):getChildByName("score")
	self._totalScore:setVisible(false)

	


	
	
		--点击事件
	local touch = display.newLayer()
		:setLocalZOrder(10)
		:addTo(self)
	touch:setTouchEnabled(true)
	touch:registerScriptTouchHandler(function(eventType, x, y)    
		return self:onTouch(eventType, x, y)
	end)


	self.removeCardPos = self:findNodeByName("removeCardPos")

	
	

	self.nodeChipPool = cc.Node:create()
					:addTo(node)


	local huo = self:findNodeByName("FileNode")
	
		--比牌层hs
	self.m_CompareView = CompareView:create(huo)
		:setVisible(false)
		:addTo(self)


	self.huoyan = cc.CSLoader:createNode("quanpinghuo.csb")
				  :move(gt.winCenter)
				  :addTo(self)
	              :setVisible(false)

	self:_Scale(self.huoyan,2)




	-- self.text = cc.Sprite:create("text.png")
	-- 			  :move(gt.winCenter)
	-- 			  :addTo(self,1)
	-- 			  :setVisible(false)

	-- self:_Scale(self.text,2)

	self.btReady:addTouchEventListener(btcallback)
	self.quxiao:addTouchEventListener(btcallback)
	self.auto_btn:addTouchEventListener(btcallback)
	self.readResult:addTouchEventListener(btcallback)
	self.m_btnInvite:addTouchEventListener(btcallback)
	self.begin_btn:addTouchEventListener(btcallback)
	self.btGiveUp:addTouchEventListener(btcallback)
	--self.btLookCard:addTouchEventListener(btcallback)
	self.btCompare:addTouchEventListener(btcallback)
	self.btAddScore:addTouchEventListener(btcallback)


	-- log("init.....ms")
	-- log(1000*(socket.gettime() -  self.t_time))


end



function zjhScene:showPlayerinfo(i)

	if i < 0 or i > GAME_PLAYER then return end

	if not self.Player or not self.Player[i] or  not self.Player[i].name or not self.Player[i].id or not self.Player[i].url or not self.Player[i].ip then return end

	self.playerInfo:setVisible(true)
	local node = self.playerInfo

	node:getChildByName("name"):setString("昵称："..self.Player[i].name)
	node:getChildByName("ID"):setString("ID："..self.Player[i].id)
	node:getChildByName("ip"):setString("IP："..self.Player[i].ip)
	node:getChildByName("score"):setVisible(false) --setString("金币："..self.Player[i].Coins)
	local data = self.Player[i].url
	if node:getChildByName("__ICON___") then  node:getChildByName("__ICON___"):removeFromParent() end
	if data and type(data) ~= nil and  string.len(data) > 10 then
		local icon = node:getChildByName("kuang_2")
		local iamge = gt.imageNamePath(data)
		node:getChildByName("icon_3"):setVisible(false)

	  	if iamge then
	  		local _node = display.newSprite("player/icon.png")
			local head = gt.clippingImage(iamge,_node,false)
			node:addChild(head)
			head:setName("__ICON___")
			head:setPosition(icon:getPositionX(),icon:getPositionY())
	  	else
	  		local function callback(args)
	      		if args.done and self then
					local _node = display.newSprite("player/icon.png")
					local head = gt.clippingImage(args.image,_node,false)
					node:addChild(head)
					head:setName("__ICON___")
					head:setPosition(icon:getPositionX(),icon:getPositionY())
				end
	        end
		    local url = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"
		    url = data
		    gt.downloadImage(url,callback)	
	  	end
	else
		node:getChildByName("icon_3"):setVisible(true)
	end


end

function zjhScene:_playSound(id,str)

	if self.Player[id].sex == 2 then
		self:PlaySound("sound_res/woman/"..str)
	else
		self:PlaySound("sound_res/man/"..str)
	end
end

function zjhScene:ActionText3(bool)


		self.text3:setVisible(bool)
		if not bool then
			if self.__action then
				_scheduler:unscheduleScriptEntry(self.__action)
				self.__action = nil
			end
		else
			if self.__action then
				_scheduler:unscheduleScriptEntry(self.__action)
				self.__action = nil
			end

			for j = 1 , 6 do self.text3:getChildByName("dian_"..j):setVisible(false)  end
			if self.__action then
				_scheduler:unscheduleScriptEntry(self.__action)
				self.__action = nil
			end
			local i = 0
			self.__action = _scheduler:scheduleScriptFunc(function()
				i = i +1 
				
				if i == 7 then i = 1 for j = 1 , 6 do self.text3:getChildByName("dian_"..j):setVisible(false)  end end
				self.text3:getChildByName("dian_"..i):setVisible(true)
			end,0.5,false)	
		end

end


function zjhScene:ActionText7(bool)

		log("b----------",bool)
		self.text7:setVisible(bool)
		if not bool then
			if self.__action_t then
				_scheduler:unscheduleScriptEntry(self.__action_t)
				self.__action_t = nil
			end
		else
			if self.__action_t then
				_scheduler:unscheduleScriptEntry(self.__action_t)
				self.__action_t = nil
			end

			for j = 1 , 6 do self.text7:getChildByName("dian_"..j):setVisible(false)  end
			if self.__action_t then
				_scheduler:unscheduleScriptEntry(self.__action_t)
				self.__action_t = nil
			end
			local i = 0
			self.__action_t = _scheduler:scheduleScriptFunc(function()
				i = i +1 
				
				if i == 7 then i = 1 for j = 1 , 6 do self.text7:getChildByName("dian_"..j):setVisible(false)  end end
				self.text7:getChildByName("dian_"..i):setVisible(true)
			end,0.5,false)	
		end

end


function zjhScene:ActionText5(bool)

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

function zjhScene:isGaoqing()

	if self.gaoqing then
		self.autoAction:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,145)))
	else
		self.autoAction:setVisible(false)
		self.autoAction:stopAllActions()
	end

end


function zjhScene:actionliuchang(id,bool)


	if not id or id == gt.INVALID_CHAIR then return end
	self.liuchang_sign[id]:setVisible(bool)

end

function zjhScene:actionSign(id,bool)

	if not id or id == gt.INVALID_CHAIR then return end
	self.sign[id]:setVisible(bool)
	if not bool then
		self.sign[id]:stopAllActions()
	else			
		self.sign[id]:runAction(cc.RepeatForever:create(cc.Blink:create(2, 2)))
	end


end

function zjhScene:my_hui(bool)

	for i = 1 , 3 do
		if bool then
			self.userCard[MY_VIEWID].card[i]:setColor(cc.c3b(127,127,127))
		else
			self.userCard[MY_VIEWID].card[i]:setColor(cc.c3b(255,255,255))
		end
	end
end


function zjhScene:GameResult(result)
	gt.log("max_result__________________________")
	gt.socketClient:unregisterMsgListener(gt.GC_REMOVE_PLAYER)
	self._node:getChildByName("bg"):stopAllActions()
	self:KillGameClock()

	if not self.action and self.compareidx == 0 and not self.action1 and not self.action2 then 
		gt.dumplog(result)
		self.result = result 
		self._node:getChildByName("upmenu"):setVisible(false)
		self.begin_btn:setVisible(false)
		self.btReady:setVisible(false)
		self.readResult:setVisible(true)
		self.result_t3:setVisible(false)
		self.result_min:getChildByName("Button_333"):loadTextureNormal( "ddz/look_result.png")
		self.result_min:getChildByName("Button_333"):loadTexturePressed( "ddz/look_result.png")
		self.result_min:getChildByName("Button_333"):loadTextureDisabled( "ddz/look_result.png")
		self.nodeButtomButton:setVisible(false)
		if self.applyDimissRoom then self.applyDimissRoom:setVisible(false
			) end
	else
		self.max_result = result
	end
	

end

function zjhScene:disPlaygameResult()

	

	if not self.result then return end
	self:OnResetView()
	self.playerInfo:setVisible(false)
	self.result_node:setVisible(true)
	self.result_min:setVisible(false)

	local message = self.result
	local csbNode = self.result_node:getChildByName("__ZJH_RESULT__")
    
    local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end


   local id = message.kUserIds
    local score = message.kScore
    local names = message.kNikes
    local urls = message.kHeadUrls

    local _name = {}
    local _id = {}
    local _score = {}
    local _url =  {}
    local idx  = 0 

    local chairCount = 0
    for i = 1 ,message.kEffectiveUserCount do
        if message.kUserState[i] ~= 0 then
            --chairCount = chairCount + 1

		    if id[i] == gt.playerData.uid then
		        idx = i
		        table.insert(_url,urls[i])
		        table.insert(_name,names[i])
		        table.insert(_id,id[i])
		        table.insert(_score,score[i])
		        break
		    end

        end
    end
  	
  	for i = 1 ,message.kEffectiveUserCount do
        if message.kUserState[i] ~= 0 then
            --chairCount = chairCount + 1

		    if id[i] ~= gt.playerData.uid then
		        
		        table.insert(_url,urls[i])
		        table.insert(_name,names[i])
		        table.insert(_id,id[i])
		        table.insert(_score,score[i])
		  
		    end

        end
    end


  --   for i = 1 , chairCount do
  --       if id[i] == gt.playerData.uid then
  --           idx = i
  --           table.insert(_url,urls[i])
  --           table.insert(_name,names[i])
  --           table.insert(_id,id[i])
  --           table.insert(_score,score[i])
  --           break
  --       end
  --   end
  --   for i = 1 , chairCount do
  --       if i ~= idx then
        
  --               table.insert(_url,urls[i])
  --               table.insert(_name,names[i])
  --               table.insert(_id,id[i])
  --               table.insert(_score,score[i])
          
  --       end
  --   end

 	-- for i = 1 , 5 do
    	
    	
  --   end

    local tmp = _score[1]
    idx = 1
    for i =1 , #_score do
    
        if _score[i] > tmp then
        	tmp = _score[i]
        	idx = i
        end
    end



    local bg = csbNode:getChildByName("bg")
   	

   	local image_bg = bg
   	local win_ = image_bg:getChildByName("plyer" .. idx):getChildByName("playerWin")
   	win_:setVisible(true)
   	win_:setLocalZOrder(21)
    local quan = image_bg:getChildByName("plyer" .. idx):getChildByName("quanquan_4")
    quan:setLocalZOrder(20)
    quan:setVisible(true)
    quan:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.6,50)))
    

    csbNode:getChildByName("m_roomId"):setString(self.data.kDeskId or "000000")
 
	local str = ""
    if yl.GAMEDATA[4] == 2 then
   		str = "大牌模式"
	elseif yl.GAMEDATA[4] == 1 then
		str = "普通模式"
	end
	csbNode:getChildByName("m_gamenum"):setString(self.result_jushi and self.result_jushi or self.jushu)
    csbNode:getChildByName("m_lunshu"):setString(yl.GAMEDATA[5])
    csbNode:getChildByName("m_moshi"):setString(str)
    csbNode:getChildByName("_time"):setString(os.date("%Y-%m-%d %H:%M"))

    -- -- 分享按钮
    -- local btn = csbNode:getChildByName("Button_2")
    -- btn:setTag(BTN_SHARE)
    -- btn:addTouchEventListener(btncallback)

    -- 退出按钮
   	local btn = csbNode:getChildByName("Button_1")
    btn:setTag(BTN_QUIT)
    btn:addTouchEventListener(btncallback)



     for i = 1, #_score do

        local cellbg = image_bg:getChildByName("plyer" .. i)
        if nil ~= cellbg then

            cellbg:setVisible(true)    
            local id = cellbg:getChildByName("ID")
            id:setVisible(true)
            id:setString("ID:".._id[i])
               
            cellbg:getChildByName("name"):setString(_name[i])
            
            local plyerScore = cellbg:getChildByName("score")
            local tmp
            if _score[i] >= 0 then
                tmp = "/".._score[i]
          
                plyerScore:setProperty(tostring(tmp),"results/win_num.png",36,49,"/")
                cellbg:loadTexture("results/win.png")
            else
            	cellbg:loadTexture("results/lose.png")
                tmp = -_score[i]
                tmp = tostring("/"..tmp)
             	plyerScore:setProperty(tostring(tmp),"results/lose_num.png",36,49,"/")
            end  

        end
    end

   	
    for i = 1, #_score do

        local cellbg = image_bg:getChildByName("plyer" .. i)
        if nil ~= cellbg then

            cellbg:setVisible(true)        
                
            local ispath = gt.imageNamePath(_url[i])
            local icon = cellbg:getChildByName("icon")
            if ispath then
               
                local _node = display.newSprite("icon1.png")
               
                local image = gt.clippingImage(ispath,_node,false)
               -- image:setScale(1.43)
               image:setLocalZOrder(19)
                cellbg:addChild(image)
               
                image:setPosition(icon:getPositionX(),icon:getPositionY())
            else


      			if _url[i] ~= "" and  type(_url[i]) == "string" and string.len(_url[i]) >10 and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self then
      				local function callback(args)
      					if args.done then 
      						local _node = display.newSprite("icon1.png")
							local head = gt.clippingImage(args.image,_node,false)
							cellbg:addChild(head)
							head:setLocalZOrder(19)
							head:setPosition(icon:getPositionX(),icon:getPositionY())
      					end
      				end
      				gt.downloadImage(_url[i], callback)
      			end



            end         
            
        end        
    end

    


  
    
end
-- 这


function zjhScene:refreshTotalScore(num)

	if num then
		self._totalScore:setVisible(true)
		self._totalScore:setString(num)
	end
end


function zjhScene:getChip_names(i)


	if tonumber(yl.GAMEDATA[6]) == 2 then 
		if i == 1 then 
			return "chip/2_chip_2.png" ,2
		elseif i == 2 then
			return "chip/2_chip_4.png" ,4
		elseif i == 3 then 
			return "chip/2_chip_8.png" ,8
		elseif i == 4 then 
			return "chip/2_chip_16.png",16
		elseif i == 5 then 
			return "chip/2_chip_20.png",20
		end 
	elseif tonumber(yl.GAMEDATA[6]) == 3 then
			if i == 1 then 
				return "chip/3_chip_3.png",3
			elseif i == 2 then
				return "chip/3_chip_6.png",6
			elseif i == 3 then 
				return "chip/3_chip_12.png",12
			elseif i == 4 then 
				return "chip/3_chip_18.png",18
			elseif i == 5 then 
				return "chip/3_chip_24.png",24
			end 
	elseif tonumber(yl.GAMEDATA[6]) == 4 then
			if i == 1 then 
				return "chip/4_chip_1.png",1
			elseif i == 2 then
				return "chip/4_chip_2.png",2
			elseif i == 3 then 
				return "chip/4_chip_4.png",4
			elseif i == 4 then 
				return "chip/4_chip_8.png",8
			elseif i == 5 then 
				return "chip/4_chip_10.png",10
			end 
	elseif tonumber(yl.GAMEDATA[6]) == 5 then
			if i == 1 then 
				return "chip/5_chip_5.png",5
			elseif i == 2 then
				return "chip/5_chip_10.png",10
			elseif i == 3 then 
				return "chip/5_chip_15.png",15
			elseif i == 4 then 
				return "chip/5_chip_30.png",30
			elseif i == 5 then 
				return "chip/5_chip_45.png",45
			end 
	else
			if i == 1 then 
				return "chip/1_chip_1.png",1
			elseif i == 2 then
				return "chip/1_chip_2.png",2
			elseif i == 3 then 
				return "chip/1_chip_4.png",3
			elseif i == 4 then 
				return "chip/1_chip_8.png",4
			elseif i == 5 then 
				return "chip/1_chip_10.png",5
			end 
	end

	

end


function zjhScene:GameLayerRefresh(args)

	
	if tonumber(yl.GAMEDATA[17]) == 1 then 
		TIME_USER_ADD_SCORE = 15
	else
		if tonumber(yl.GAMEDATA[19]) == 1 then 
			TIME_USER_ADD_SCORE = 10
		elseif tonumber(yl.GAMEDATA[19]) == 2 then
			 TIME_USER_ADD_SCORE = 15
		else 
			TIME_USER_ADD_SCORE = 30
		end
	end

	
	if yl.GAMEDATA[6] ~= -1  then

		self.chips = {}

		for i = 2 , 5 do
			local k ,y = self:getChip_names(i)
			self.chips[y] = self.m_ChipBG:getChildByName("chip_"..i-1)
			log(k)
			self.m_ChipBG:getChildByName("chip_"..i-1):loadTexture(k)
				gt.setOnViewClickedListener(self.m_ChipBG:getChildByName("chip_"..i-1), function()
					local num = 1
					if self.iskanpai then
						num = 2
					else
						num = 1
					end
					
					self:_playSound(MY_VIEWID,"jiazhu.mp3")
					self.shuohua = false
					self._difen = y
					self:addScore(num*y,y)
					self:findNodeByName("genzhuBg"):setVisible(false)
					
					if i == 5 then 
						self.max_chip = true
						self.btAddScore:setEnabled(false)
					end

				end,1)
		end
		for i = 1 , 5 do
			local k ,y = self:getChip_names(i)
			if i >=2 and i <=3  then 
				log("y..............",y)
				self:findNodeByName("mai_xiao"..i):loadTextureNormal("btn/mai"..y..".png")
				self:findNodeByName("mai_xiao"..i):loadTexturePressed("btn/mai"..y..".png")
				if i == 3 then 
					self:findNodeByName("mai_da1"):loadTextureNormal("btn/maida"..y..".png")
					self:findNodeByName("mai_da1"):loadTexturePressed("btn/maida"..y..".png")
				end
			end
			self.__chip[i]:loadTexture(k)
		end

			
		    local str = ""
		    if yl.GAMEDATA[4] == 2 then
		   		str = "大牌模式"
			elseif yl.GAMEDATA[4] == 1 then
				str = "普通模式"
			end
			if yl.GAMEDATA[6] == 3 or yl.GAMEDATA[6] == 2 then 
				self.roominof:getChildByName("pattern"):setString(str.."     "..yl.GAMEDATA[6].."分")
			elseif yl.GAMEDATA[6] == 1 then
				self.roominof:getChildByName("pattern"):setString(str.."  ".."1分(小)")
			elseif yl.GAMEDATA[6] == 4 then
				self.roominof:getChildByName("pattern"):setString(str.."  ".."1分(大)")
			end

			if tonumber(yl.GAMEDATA[7]) == 0 then 
			self.roominof:getChildByName("Text_2"):setString("无必闷")
			elseif tonumber(yl.GAMEDATA[7]) == 1 then 
				self.roominof:getChildByName("Text_2"):setString("闷1轮")
			elseif tonumber(yl.GAMEDATA[7]) == 2 then
				self.roominof:getChildByName("Text_2"):setString("闷2轮")
			elseif tonumber(yl.GAMEDATA[7]) == 3 then
				self.roominof:getChildByName("Text_2"):setString("闷3轮")

			end

			

			self.m_atlasRoomID = self.roominof:getChildByName("RoomId")

			self.m_atlasRoomID:setString("房号："..args.kDeskId or "000000")

			self._roomId = cc.UserDefault:getInstance():getIntegerForKey("roomid",000000)
			--self._roomId = 000000
			if self._roomId then
				if self._roomId == 000000 then 
					self.moshi_bg:setVisible(true)
				else
					self.moshi_bg:setVisible(false)
				end
			end

			if  tonumber (yl.GAMEDATA[9]) == 1 then 
				self.roominof:getChildByName("Text_5"):setString("可托管")
			else
				self.roominof:getChildByName("Text_5"):setString("")
			end



			local bool = false
			local bool1 = false
			self.roominof:getChildByName("Text_3"):setString("")
			self.roominof:getChildByName("Text_4"):setString("")
			self.roominof:getChildByName("Text_6"):setString("")
			self.roominof:getChildByName("Text_7"):setString("")
			self.roominof:getChildByName("Text_1"):setString("")

			if tonumber (yl.GAMEDATA[11]) == 1 then 
				self.roominof:getChildByName("Text_3"):setString("倍开")
				if tonumber(yl.GAMEDATA[12]) == 1 then 
					self.roominof:getChildByName("Text_4"):setString("天龙地龙")
				end
			else
				if tonumber(yl.GAMEDATA[12]) == 1 then 
					self.roominof:getChildByName("Text_3"):setString("天龙地龙")
				else
					-- if tonumber(yl.GAMEDATA[8]) == 1 then 
					-- 	self.roominof:getChildByName("Text_3"):setString("豹子同花顺加分")
					-- 	bool  = true
					-- 	log("c________c")
					-- else
					-- 	-- self.roominof:getChildByName("Text_3"):setString("豹子同花顺加分")
					-- 	-- bool = true
						
					-- end
					-- bool1 = true
				end
			end
			
			if tonumber (yl.GAMEDATA[14]) == 1 then -- 允许买小
				if tonumber (yl.GAMEDATA[15]) == 1 then -- b豹子最大
					-- if bool1 then 
					-- 	self.roominof:getChildByName("Text_3"):setString("豹子最大")
					-- 	self.roominof:getChildByName("Text_4"):setString("可买小")
					-- else
					-- 	self.roominof:getChildByName("Text_7"):setString("豹子最大")
					-- 	self.roominof:getChildByName("Text_6"):setString("可买小")
					-- end

					if self.roominof:getChildByName("Text_3"):getString() == "" then 
								self.roominof:getChildByName("Text_3"):setString("豹子最大")
								self.roominof:getChildByName("Text_4"):setString("可买小")
					else
					if self.roominof:getChildByName("Text_7"):getString() == "" then 
							self.roominof:getChildByName("Text_7"):setString("豹子最大")
							self.roominof:getChildByName("Text_6"):setString("可买小")
					end
					end

				else
					-- if bool1 then 
					-- 	self.roominof:getChildByName("Text_3"):setString("可买小")
					-- else
					-- 	self.roominof:getChildByName("Text_7"):setString("可买小")
					-- end
					if self.roominof:getChildByName("Text_3"):getString() == "" then 
							self.roominof:getChildByName("Text_3"):setString("可买小")
					else
						if self.roominof:getChildByName("Text_7"):getString() == "" then  
							self.roominof:getChildByName("Text_7"):setString("可买小")
						end
					end

				end
			else
				
			end 
			if not bool then 
				log("b____b")
				if tonumber(yl.GAMEDATA[8]) == 1  then 
					if self.roominof:getChildByName("Text_3"):getString() == "" then 
						self.roominof:getChildByName("Text_3"):setString("豹子同花顺加分")
					elseif self.roominof:getChildByName("Text_7"):getString() == "" then 
						self.roominof:getChildByName("Text_7"):setString("豹子同花顺加分")
					elseif self.roominof:getChildByName("Text_1"):getString() == "" then 
						self.roominof:getChildByName("Text_1"):setString("豹子同花顺加分")
					end
				end
			end

			-- if not bool then 

			-- 	if tonumber(yl.GAMEDATA[8]) == 1 then 
			-- 		self.roominof:getChildByName("Text_1"):setString("豹子同花顺加分")
			-- 	else

			-- 		self.roominof:getChildByName("Text_1"):setString("")

			-- 	end

			-- end


    

		
			local roomid = tonumber(args.kDeskId)
			cc.UserDefault:getInstance():setIntegerForKey("roomid",roomid)
			self._roomId = tonumber(args.kDeskId)

	end 

	self.lunshu:setString("轮数：0 / "..yl.GAMEDATA[5])

    -- 局数
    self.m_atlasCount = self.roominof:getChildByName("roomNum")
    self.jushu = args.kMaxCircle
    local strcount = 0 .. " / " .. args.kMaxCircle
    if strcount then
    	self.m_atlasCount:setString("局数："..strcount)
	end

	self.m_btnInvite:setVisible(true)

end

--屏幕点击
function zjhScene:onTouch(eventType, x, y)

	log("eventType................",eventType,self.bCompareChoose)
	if eventType == "began" then
	


		--比牌选择判断
		if self.bCompareChoose == true then
			for i = 1, GAME_PLAYER do
				if cc.rectContainsPoint(self.rcCompare[i],cc.p(x,y)) then
					print("iii",i)
					return true
				end
			end
		end

		return false
	elseif eventType == "ended" then
		

		--比牌选择
		if self.bCompareChoose == true then
			for i = 1, GAME_PLAYER do
				if cc.rectContainsPoint(self.rcCompare[i],cc.p(x,y)) then
					
					self.text1:setVisible(false)
					self:OnCompareChoose(i)
					break
				end
			end
		end


	end

	return true
end


function  zjhScene:OnCompareChoose(index)
    if not index or index == gt.INVALID_CHAIR then
        log("OnCompareChoose error index")
        return
    end
    if index == self:getTableId(self.UsePos) then return end
   
    for i = 1 ,GAME_PLAYER do
    	log("i,,,,",i,self.m_cbPlayStatus[i],self:SwitchViewChairID(i-1))
        if  self.m_cbPlayStatus[self:SwitchViewChairID(i-1)] == 1 and index == self:SwitchViewChairID(i-1) then
           
            self:SetCompareCard(false)
            self:KillGameClock()
            local score = self.m_lCellScore * (tonumber(yl.GAMEDATA[11]) and tonumber(yl.GAMEDATA[11])+1 or 1) --addnew 
            self:PlayerJetton(MY_VIEWID, score,false,true)
            self:onSendAddScore(score, true, 0)--发送下注消息 -- ccc
         
         	local m = {}
            m.kMId = gt.MSG_C_2_S_POKER_GAME_MESSAGE
			m.kSubId = gt.SUB_S_COMPARE_CARD
            m.kValue = i-1
            gt.dumplog(m)
            gt.socketClient:sendMessage(m)

            break
        end
    end

end




function zjhScene:removeActionHuo()

		log("remove_____node")
		if self.___node then
			log("remove___ok_______")
				self.huoyan:setVisible(false)
				self.huoyan:stopAllActions()
			--	self.text:setVisible(false)
				self.hong:setVisible(false)

				self.hong:stopAllActions()
				self.hong1:setVisible(false)
				
				self.hong1:stopAllActions()
			end
    	
end

function zjhScene:display_qipao(id,num)

	gt.log("GiveUp.....",id,num)
	if num == 1 then
		if id ~= MY_VIEWID then 
			for i = 1 , 3 do 
				self.userCard[id].card[i]:setVisible(false)
			end
		else
			self:my_hui(true)

		end
		self.hui_bg[id]:setVisible(true)
		self.comPokeLose[id]:setVisible(false)
		
			self.m_GiveUp[id]:loadTexture("qipaiicon.png")
			self.m_GiveUp[id]:setVisible(true)
		
		self.m_cbPlayStatus[id] = 0
		self.m_LookCard[id]:setVisible(false)
	elseif num == 2 then
		--self:setuserlose(id)
		if id ~= MY_VIEWID then 
			for i = 1 , 3 do 
				self.userCard[id].card[i]:setVisible(false)
			end
		else
			self:my_hui(true)
		end
		self.m_cbPlayStatus[id] = 0
		self.hui_bg[id]:setVisible(true)
		self.comPokeLose[id]:setVisible(true)
		self.m_GiveUp[id]:setVisible(false)
		self.m_LookCard[id]:setVisible(false)
	else

	end

end

function zjhScene:addTableChip(buf)

	if  tonumber(yl.GAMEDATA[6]) >5 or tonumber(yl.GAMEDATA[6])<1  then return end
	self:CleanAllJettons()
	if self.gaoqing then 

		local chip_num = 0
		for i = 1 , 5 do 
			for j = 1 ,buf[i] do
				local str,_ = self:getChip_names(i)
				--local chip = display.newSprite(str)
				log(str)
				local chip = cc.Sprite:create(str)
					:setScale(0.8)
					:addTo(self.nodeChipPool)
					
				chip:setRotation(math.random(-45,45))
				if gt.GAME_PLAYER == 5 then 
					chip:move(cc.p(450+ math.random(400), 350 + math.random(130)))
				else
					chip:move(cc.p(435+ math.random(475), 335 + math.random(110)))
				end
				chip_num = chip_num  + 1
			end
		end

		local children = self.nodeChipPool:getChildren()
		if #children > 77 then
			for k , v in pairs(children) do 
				if chip_num >= k then
					chip_num = chip_num - 1
					v:removeFromParent()
				end
			end
		end
	else
		for  i = 1 , 5  do
				self.__chip[i]:setVisible(true)
			end

	end

end

function zjhScene:getMax_chip()

	if tonumber(yl.GAMEDATA[6]) == 1 then 
		if self._difen == 5 then return true else return false end
	elseif tonumber(yl.GAMEDATA[6]) == 2 then
		if self._difen == 20 then return true else return false end
	elseif tonumber(yl.GAMEDATA[6]) == 3 then 
		if self._difen == 24 then return true else return false end
	elseif tonumber(yl.GAMEDATA[6]) == 4 then
		if self._difen == 10 then return true else return false end
	elseif tonumber(yl.GAMEDATA[6]) == 5 then  
		if self._difen == 45 then return true else return false end
	end


end



--筹码移动
function zjhScene:PlayerJetton(wViewChairId, num,notani,isbipai)




	if not num or num < 1 or not self._difen  then
		return
	end

	
		--if self.tmpScore >  num
		--self.tmpScore = num
		local bool = false
		local chipscore = num
		local chip_num = 0

		local strChip
		local tmpi = 0
		for i = 1 , 5 do 
				local name, num = self:getChip_names(i)
				if num == self._difen then 
					strChip = name
					tmpi = i
					break
				end
			end

	if self.gaoqing then 

		for  i = 1 , 5  do
			if  self.__chip[i]:isVisible() then 
				self.__chip[i]:setVisible(false)
			end
		end

		while chipscore > 0 
		do
			
			chip_num = chip_num + 1

			log(chipscore)
			log(self._difen)
			chipscore = chipscore - self._difen	
			
			log("add_________________",strChip)

			local chip = display.newSprite(strChip)
				:setScale(0.8)
				:addTo(self.nodeChipPool)

				

			if  self:getMax_chip() then chip:setRotation(math.random(-45,45)) end
	
			if notani == true then
				if gt.GAME_PLAYER == 5 then 
					chip:move(cc.p(450+ math.random(400), 350 + math.random(130)))
				else
					chip:move(cc.p(435+ math.random(475), 335 + math.random(110)))
				end
			else
				log("else_____________",self.baoji,isbipai)
				if not self.baoji and not isbipai and not bool then 
				bool = true
					if self.___node then
						log("not  node_______")
						self.huoyan:setVisible(false)
						self.huoyan:stopAllActions()
						--self.text:setVisible(false)
						self.hong:setVisible(false)
						self.hong:stopAllActions()
						self.hong1:setVisible(false)
						self.hong1:stopAllActions()
						
						gt.soundEngine:stopMusic()
					end
					if self:getMax_chip() and not self.___node then
						log("create____________")
						self.___node = cc.CSLoader:createTimeline("quanpinghuo.csb")
						
						self.huoyan:runAction(self.___node)
						self.___node:gotoFrameAndPlay(0,true)
						self.huoyan:setVisible(true)
						-- self.text:setScale(0.01)
						-- self.text:runAction(cc.ScaleTo:create(1,1))
						-- self.text:setVisible(true)

						if wViewChairId == MY_VIEWID then 
							self.hong1:setPosition(self.nodePlayer[wViewChairId]:getPositionX(),self.nodePlayer[wViewChairId]:getPositionY())
							self.hong1:setVisible(true)
							self.hong1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.3,255),cc.FadeTo:create(0.3,50))))
						else
							self.hong:setPosition(self.nodePlayer[wViewChairId]:getPositionX(),self.nodePlayer[wViewChairId]:getPositionY())
							self.hong:setVisible(true)
							self.hong:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.3,255),cc.FadeTo:create(0.3,50))))
						end
						
						
					
						
							self:playMusic("sound_res/MAX.mp3",true)
							
						
					


						
					end
				end
				chip:move(self.m_ScoreView[wViewChairId]:getPosition())
				
					if self:getMax_chip()  and not isbipai then
						self.max_chip = true
						self.btAddScore:setEnabled(false)
						self:PlaySound("sound_res/jinzhuang.mp3")
					end
					if gt.GAME_PLAYER == 5 then 
						chip:runAction(cc.MoveTo:create(0.2, cc.p(450+ math.random(400), 350 + math.random(130))))
					else
						chip:runAction(cc.MoveTo:create(0.2, cc.p(435+ math.random(475), 335 + math.random(110))))
					end
				
			end
		end

		local children = self.nodeChipPool:getChildren()
		if #children > 77 then
		for k , v in pairs(children) do 
			if chip_num >= k then
				v:removeFromParent()
			end
		end
		end
	else

		gt.log("gaoqing___________________not")
		local children = self.nodeChipPool:getChildren()
		for k , v in pairs(children) do 
			if v then 
				v:removeFromParent()
			end
		end
		for  i = 1 , 5  do
			if  not self.__chip[i]:isVisible() then 
				self.__chip[i]:setVisible(true)
			end
			self.__chip[i]:setPosition(cc.p(self.__chipPosX[i],self.__chipPosY[i]))
		end
		if tmpi ~= 0 then 
		
			local node = self:findNodeByName("add_chip")
						:setVisible(true)
			if chipscore == self._difen then 
				node:loadTexture("add1.png")
			else
				node:loadTexture("add2.png")
			end
			node:stopAllActions()
			node:setPosition(cc.p(self.__chip[tmpi]:getPositionX(),self.__chip[tmpi]:getPositionY()+55))
			node:runAction(cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(0,30)),cc.DelayTime:create(0.3),cc.CallFunc:create(function()
				
				self:actionliuchang(wViewChairId,false)
				
				node:setVisible(false)
				end)))
		end


		if notani == true then
				
				--chip:move(cc.p(450+ math.random(400), 350 + math.random(130)))
		else
			if not self.baoji and not isbipai and not bool then 
				bool = true
				if self.___node then
					log("not  node_______")
					self.huoyan:setVisible(false)
					self.huoyan:stopAllActions()
					--self.text:setVisible(false)
					self.hong:setVisible(false)
						self.hong:stopAllActions()
						self.hong1:setVisible(false)
						self.hong1:stopAllActions()
					
					--AudioEngine.stopMusic()
					gt.soundEngine:stopMusic()
					
				end
				if self:getMax_chip() and not self.___node then
					log("create____________")
															  
					self.___node = cc.CSLoader:createTimeline("quanpinghuo.csb")
					
					self.huoyan:runAction(self.___node)
					self.___node:gotoFrameAndPlay(0,true)
					self.huoyan:setVisible(true)
					-- self.text:setScale(0.01)
					-- self.text:runAction(cc.ScaleTo:create(1,1))
					-- self.text:setVisible(true)
					-- if GAME_PLAYER == 8 then 
					-- 	if wViewChairId == 1 or wViewChairId == 2 or wViewChairId == 3 or wViewChairId == 4 or wViewChairId == 5 or wViewChairId == 8 then
					-- 		self.hong:setPosition(self.nodePlayer[wViewChairId]:getPositionX()+3,self.nodePlayer[wViewChairId]:getPositionY())
					-- 	else
					-- 		self.hong:setPosition(self.nodePlayer[wViewChairId]:getPositionX()+3,self.nodePlayer[wViewChairId]:getPositionY())
					-- 	end
					-- else


					-- end
						if wViewChairId == MY_VIEWID then 
							self.hong1:setPosition(self.nodePlayer[wViewChairId]:getPositionX(),self.nodePlayer[wViewChairId]:getPositionY())
							self.hong1:setVisible(true)
							self.hong1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.3,255),cc.FadeTo:create(0.3,50))))
						else
							self.hong:setPosition(self.nodePlayer[wViewChairId]:getPositionX(),self.nodePlayer[wViewChairId]:getPositionY())
							self.hong:setVisible(true)
							self.hong:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.3,255),cc.FadeTo:create(0.3,50))))
						end
					
					self:playMusic("sound_res/MAX.mp3",true)
				
				


					--self.hong:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.3,255),cc.FadeTo:create(0.3,50))))
				end
			end
			
			
			if self:getMax_chip()  and not isbipai then
				self.max_chip = true
				self.btAddScore:setEnabled(false)
				self:PlaySound("sound_res/jinzhuang.mp3")
			end
			
		end


	end



	if not notani then
		self:PlaySound("sound_res/ADD_SCORE.wav")
	end
end

--停止比牌动画
function zjhScene:StopCompareCard()
	

	gt.log("stop_________sss",self.m_CompareView.node:getNumberOfRunningActions(),self.m_CompareView:getaction_num(),self.compareidx)

	self.m_CompareView:StopCompareCard()

	

	self.m_CompareView:setVisible(false)
	
	--self._node:getChildByName("TotalScore"):stopAllActions()
	self:findNodeByName("Panel_hui"):setVisible(false)
	local removeAction = false
	for i = 1 , GAME_PLAYER do

		if self.nodePlayer[i]:getNumberOfRunningActions() > 0 then removeAction = true end

		self.nodePlayer[i]:stopAllActions()
		self.nodePlayer[i]:setPosition(cc.p(self.PX[i],self.PY[i]))
		
	end

	gt.log("removeAction-------",tostring(removeAction))

	if removeAction and self.compareidx > 0  then self.compareidx = self.compareidx - 1 end
	self.compareidx = self.compareidx - self.m_CompareView:getaction_num()
	if self.m_CompareView:getaction_num() > 0 then 
		self.m_CompareView:setaction_num()
	end
	if self.compareidx < 0 then self.compareidx = 0 end

	for i = 1 , 3 do
		if self.com1 and self.com2 then 
			self.userCard[self.com1].card[i]:setVisible(true)
			self.userCard[self.com2].card[i]:setVisible(true)
			self.m_ScoreView[self.com1]:setVisible(true)
			self.m_ScoreView[self.com2]:setVisible(true)
		end
	end

	if self.com1 and self.com2 and self.zor1 and self.zor2 then 
		self.nodePlayer[self.com1]:setLocalZOrder(self.zor1)
		self.nodePlayer[self.com2]:setLocalZOrder(self.zor2)
	end

	if self.com1 and self.com2 then 
		self.nodePlayer[self.com1]:setVisible(true)
		self.nodePlayer[self.com2]:setVisible(true)
		for k , y in pairs(self.look_card) do
			if k == self.com1 then 
				self.m_LookCard[k]:setVisible(y)
			end

			if k == self.com2  then 
				self.m_LookCard[k]:setVisible(y)
				
			end
		end
	end
	self.action1 = false
	
end

--比牌
function zjhScene:CompareCard(firstuser,seconduser,firstcard,secondcard,bfirstwin,callback) 
	self:StopCompareCard()
	self.nodePlayer[firstuser]:setPosition(self.PX[firstuser],self.PY[firstuser])
	self.nodePlayer[seconduser]:setPosition(self.PX[seconduser],self.PY[seconduser])
	self.m_CompareView:setVisible(true)

	gt.log("compare______________________"..tostring(self.nodePlayer[firstuser]:isVisible()))


	for i = 1 , 3 do
		if firstuser ~= MY_VIEWID then 
			self.userCard[firstuser].card[i]:setVisible(false)
		end
		if seconduser ~= MY_VIEWID then
			self.userCard[seconduser].card[i]:setVisible(false)
		end	
	end

	self.m_LookCard[firstuser]:setVisible(false)
	self.m_LookCard[seconduser]:setVisible(false)
	self.m_ScoreView[firstuser]:setVisible(false)
	self.m_ScoreView[seconduser]:setVisible(false)



	local zor1 = self.nodePlayer[firstuser]:getLocalZOrder()
	local zor2 = self.nodePlayer[seconduser]:getLocalZOrder()

	self.zor1 = zor1
	self.zor2 = zor2

	self.com1 = firstuser
	self.cam2 = seconduser

	self.nodePlayer[firstuser]:setLocalZOrder(1000)
	self.nodePlayer[seconduser]:setLocalZOrder(1000)

	local tmp = 0
	if firstuser <=MY_VIEWID then
		tmp = -200
	else
		tmp = 200
	end

	local tmp1 = 0 
	if seconduser <=MY_VIEWID then
		tmp1 = -200
	else
		tmp1 = 200
	end 
	gt.log("compare______________________1"..tostring(self.nodePlayer[firstuser]:isVisible()))
																		  --1                       -0.5
	self.nodePlayer[firstuser]:runAction(cc.Sequence:create(cc.Blink:create(0.5, 4),cc.MoveTo:create(0.3,cc.p(500,375)),cc.DelayTime:create(0.2), --2.2 + 1.2 + 2.7
						--0.5
		cc.MoveTo:create(0.3,cc.p(-166,375))))
	self.nodePlayer[seconduser]:runAction(cc.Sequence:create(cc.Blink:create(0.5, 4),cc.MoveTo:create(0.3,cc.p(845,375)),cc.DelayTime:create(0.2), -- 
		cc.MoveTo:create(0.3,cc.p(1500,375))))

	self.nodePlayer[firstuser]:setPosition(self.PX[firstuser],self.PY[firstuser])
		self.nodePlayer[seconduser]:setPosition(self.PX[seconduser],self.PY[seconduser])

	
		self.nodePlayer[firstuser]:setLocalZOrder(zor1)
		self.nodePlayer[seconduser]:setLocalZOrder(zor2)


	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),cc.CallFunc:create(function() -- 1.3 + 1.2
		gt.log("compare______________________3"..tostring(self.nodePlayer[firstuser]:isVisible()))
		self.m_CompareView:CompareCard(self.Player[firstuser],self.Player[seconduser],firstcard,secondcard,bfirstwin,callback)

		for i = 1 , 3 do
			self.userCard[firstuser].card[i]:setVisible(true)
			self.userCard[seconduser].card[i]:setVisible(true)
			self.m_ScoreView[firstuser]:setVisible(true)
			self.m_ScoreView[seconduser]:setVisible(true)
		end

		self.nodePlayer[firstuser]:setPosition(self.PX[firstuser],self.PY[firstuser])
		self.nodePlayer[seconduser]:setPosition(self.PX[seconduser],self.PY[seconduser])

	
		self.nodePlayer[firstuser]:setLocalZOrder(zor1)
		self.nodePlayer[seconduser]:setLocalZOrder(zor2)

		for k , y in pairs(self.look_card) do


			if k == firstuser then 
				self.m_LookCard[firstuser]:setVisible(y)

			end

			if k == seconduser  then 
				self.m_LookCard[k]:setVisible(y)
			end
		end

		end)))
	
	
end

--底注显示
function zjhScene:SetCellScore(cellscore)

	if not cellscore then
		--self.txt_CellScore:setString("0")
		for i = 2, 5 do
			local a ,b = self:getChip_names(i)
			if tonumber(yl.GAMEDATA[6]) >= 1 and tonumber(yl.GAMEDATA[6]) <= 5 then
				self.m_ChipBG:getChildByName("chip_"..i-1):loadTexture(a)
			end
		end
	else
		
		log("cellscore...",cellscore)
		self._difen = cellscore
		for k , y in pairs(self.chips) do 
			gt.log("k,,,,,,,,,,",k)
			if cellscore >= k then
				y:setColor(cc.c3b(171,171,171))
				y:setEnabled(false)
			end
 		end

 		if  not self.iskanpai then
 			self.m_lCellScore = cellscore
			self.btFollow:getChildByName("num"):setString(cellscore)  -- 按钮上面数字
			self.btCompare:getChildByName("num"):setString(cellscore*(tonumber(yl.GAMEDATA[11]) and  tonumber(yl.GAMEDATA[11])+1 or 1))  -- addnew
			self.auto_btn:getChildByName("num"):setString(cellscore)
		else
			self.m_lCellScore = cellscore*2
			self.btFollow:getChildByName("num"):setString(cellscore*2)  -- 按钮上面数字
			self.btCompare:getChildByName("num"):setString(cellscore*2*(tonumber(yl.GAMEDATA[11]) and  tonumber(yl.GAMEDATA[11])+1 or 1)) --addnew
			self.auto_btn:getChildByName("num"):setString(cellscore*2)
		end
		log("cellscore...",self.m_lCellScore)
	end
end

--封顶分数
function zjhScene:SetMaxCellScore(cellscore)
	if not cellscore then
		--self.txt_MaxCellScore:setString("")
	else
		--self.txt_MaxCellScore:setString(""..cellscore)
	end
end

--庄家显示
function zjhScene:SetBanker(viewid,call,fun)
	
	if not viewid or viewid == gt.INVALID_CHAIR then
		for i = 1 , GAME_PLAYER  do
			self.m_BankerFlag[i]:setVisible(false)
		end
		return
	end
	for i = 1 ,GAME_PLAYER do
		self.m_flagReady[i]:setVisible(false)
	end
	self.m_BankerFlag[viewid]:setVisible(true)
	-- if call and fun then
	-- self.nodePlayer[viewid]:runAction(cc.Sequence:create(cc.Blink:create(2, 5),cc.CallFunc:create(function() call() end),cc.DelayTime:create(1),cc.CallFunc:create(function() fun() end))) end
	
end

--庄家显示
function zjhScene:SetBanker1(viewid)
	
	gt.log("banker,,,,,,,,",viewid)
	if not viewid or viewid == gt.INVALID_CHAIR then
		for i = 1 , GAME_PLAYER  do
			self.m_BankerFlag[i]:setVisible(false)
		end
		return
	end
	for i = 1 ,GAME_PLAYER do
		self.m_flagReady[i]:setVisible(false)
	end
	self.m_BankerFlag[viewid]:setVisible(true)
	--if call and fun then
	--self.nodePlayer[viewid]:runAction(cc.Sequence:create(cc.Blink:create(2, 5),cc.CallFunc:create(function() call() end),cc.DelayTime:create(1),cc.CallFunc:create(function() fun() end))) end

	self.nodePlayer[viewid]:runAction(cc.Blink:create(2, 5))
	
end

--下注总额
function zjhScene:SetAllTableScore(score)
	if not score or score == 0 then
		--self.m_AllScoreBG:setVisible(false)
	else
		log("下注总金额.......",score)
		--self.m_txtAllScore:setString(score)
		--self.m_AllScoreBG:setVisible(true)
	end
	
end

function zjhScene:SetUserTableScore1(viewid, score)

	if not score or not viewid  then return end
	if  score == 0 then return end
	self.player_viewid[viewid] = score
	

end



function zjhScene:SetUserTableScore2(bool,MaxResult,cbCardData,m)


	if self.player_viewid then
		if bool then
			self:PlaySound("sound_res/RESULT.mp3")
		end
		local num 
		for k , y in pairs(self.player_viewid) do
			local viewid = k 
			local score = y
			gt.log("viewid....",viewid)
			gt.log("score....",tonumber(score))
			--self.userCard[viewid].resultScore:setScale(viewid)
			if viewid == MY_VIEWID then
				if tonumber(score) > 0 then
					if bool then
						gt.log("ss_win__________________")
						self.userCard[viewid].resultScore:loadTexture("_win.png")

						num = "/"..score
						self.userCard[viewid].resultScore:getChildByName("AtlasLabel"):setProperty("/","addNum.png",30,40,"/")
						log("huanguan______________________")
							self.m_UserHead[viewid].quanquan:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.6,50)))
							self.m_UserHead[viewid].quanquan:setVisible(true)
							self.m_UserHead[viewid].hg:setVisible(true)
					end
					
					
				else
					if bool then
						num = "/"..0-tonumber(score)
						gt.log("ss__lose__________________")
						self.userCard[viewid].resultScore:loadTexture("_lose.png")
						self.userCard[viewid].resultScore:getChildByName("AtlasLabel"):setProperty("/","else.png",30,40,"/")
					end

				end
			else
				if tonumber(score) > 0 then
					if bool then 
						num = "/"..score
						gt.log("__win__________________")
						self.userCard[viewid].resultScore:loadTexture("__win.png")
						self.userCard[viewid].resultScore:getChildByName("AtlasLabel"):setProperty("/","addNum.png",30,40,"/")

						self.userCard[viewid].cardType:setVisible(false)
						log("huanguan______________________")
						self.m_UserHead[viewid].quanquan:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.6,50)))
						self.m_UserHead[viewid].quanquan:setVisible(true)
						self.m_UserHead[viewid].hg:setVisible(true)
					end
				
				else
					if bool  then 
						num = "/"..0-tonumber(score)
						gt.log("__lose__________________")
						self.userCard[viewid].resultScore:loadTexture("__lose.png")
						self.userCard[viewid].resultScore:getChildByName("AtlasLabel"):setProperty("/","else.png",30,40,"/")
					end
				end
			end
			if bool then 
				self.userCard[viewid].resultScore:getChildByName("AtlasLabel"):setString(num)
				self.userCard[viewid].resultScore:setVisible(true)
			end
			
		end
		if tonumber(yl.GAMEDATA[17]) == 1 and not MaxResult and tonumber(yl.GAMEDATA[18]) == 1 then 
			self:showViewResult(m,MaxResult,cbCardData)
		end
	end

end

--玩家下注
function zjhScene:SetUserTableScore(viewid, score)
	--增加桌上下注金币
	log("玩家下注",viewid,score)
	if not score or score == 0 then
		
		self.m_ScoreView[viewid]:setVisible(false)
	else
		
		self.m_ScoreView[viewid]:setVisible(true)
		self.m_ScoreView[viewid]:getChildByName("num"):setString(score)
	end
end

function zjhScene:setWinorLose(viewId,score)



end

--发牌
function zjhScene:SendCard(viewid,index,fDelay,i,j)
	if not viewid then
		return
	end
	if viewid < 0 or viewid > GAME_PLAYER then  return end
	local fInterval = 0.1



	local nodeCard = self.userCard[viewid]
	nodeCard.area:setVisible(true)

	local p 

	local str  = self:l_or_r(viewid)

	
	if str == "r"  then
		p = cc.p(ptCard[viewid].x - (viewid==MY_VIEWID and 122.39 or distanceCard)*(index- 1),ptCard[viewid].y)
	else
		p = cc.p(ptCard[viewid].x + (viewid==MY_VIEWID and 122.39 or distanceCard)*(index- 1),ptCard[viewid].y) 
	end

	

	log("viewid>>>..",viewid,index,i,j)
	
	local spriteCard = nodeCard.card[index]
	spriteCard:stopAllActions()
	spriteCard:setScale(0.1)
	spriteCard:setVisible(false)
	spriteCard:loadTexture("poker/56.png")
	spriteCard:move(display.cx, display.cy)
	spriteCard:runAction(
		cc.Sequence:create(
		--setRotated
		cc.DelayTime:create(fDelay),
		cc.CallFunc:create(
			function ()
				spriteCard:setVisible(true)
			end
			),
			cc.Spawn:create(
				cc.ScaleTo:create(0.15,viewid==MY_VIEWID and 0.75 or scale),
				cc.MoveTo:create(0.15, p)),
			cc.CallFunc:create(function() spriteCard:setScale(viewid==MY_VIEWID and 0.75 or scale) 
				
				if index and i and j then 

					if index == 1 and (i + 2) % 3 == 0 and i ~= j then 
						self.a = self:PlaySound("sound_res/CENTER_SEND_CARD.mp3")
					end  
					if index == 3 and i == j and i > 4  then 

						gt.log("stop____",self.a) gt.soundEngine:stopEffect(self.a) 
					end 
					
				end
				end)))

end


function zjhScene:l_or_r(viewid)

	local str = "r"
	if GAME_PLAYER == 8  then 
		if viewid == 6 or viewid == 7  then
			 str = "r" 
		else
			 str = "l"
		end

	elseif  GAME_PLAYER == 5 then 
		if viewid == 1 or viewid == 2 or viewid == 3 then
			 str = "l"
		else
			 str = "r"
		end
	end

	return str

end


--看牌状态
function zjhScene:SetLookCard(viewid , bLook)
	
	



	

	
	self.look_card[viewid] = bLook
	if viewId == MY_VIEWID  then 
		if not self.qipai then 
			self.m_LookCard[viewid]:setVisible(bLook)
		end
	else
		self.m_LookCard[viewid]:setVisible(bLook)
	end
	if bLook then 
		for i = 1, 3 do
			local spCard = self.userCard[viewid].card[i]
			--spCard:runAction(cc.RotateTo:create(0.1,0))
			spCard:setRotation(0)
			log("lookcard__________________________________")
			if str == "l"  then
				if i == 1 then 
					--spCard:runAction(cc.Spawn:create(cc.RotateBy:create(1,-15))
					spCard:runAction(cc.RotateBy:create(0.3,-15))

				elseif i == 2 then 
					--spCard:runAction(cc.Spawn:create(cc.RotateBy:create(1,15))
					spCard:runAction(cc.RotateBy:create(0.3,15))
				elseif i == 3 then 
					--spCard:runAction(cc.Spawn:create(cc.RotateBy:create(1,30))
					spCard:runAction(cc.RotateBy:create(0.3,30))
				end
				spCard:setPositionX(spCard:getPositionX()+5)
			elseif str == "r"  then
				if i == 1 then 
					spCard:runAction(cc.RotateBy:create(0.3,30))
				elseif i == 2 then 
					spCard:runAction(cc.RotateBy:create(0.3,15))
				elseif i == 3 then 
					spCard:runAction(cc.RotateBy:create(0.3,-15))
				end

				spCard:setPositionX(spCard:getPositionX()-12)
			end
		end
	end
	
end

function zjhScene:setuserlose(viewid,fun)


	log("id..................................sssss.",viewid)
	--if not viewid then return end
	--if viewid >5 or viewid < 1 then return end
	local nodeCard = self.userCard[viewid]
	for i = 1, 3 do
        nodeCard.card[i]:loadTexture("poker/57.png")
        nodeCard.card[i]:setVisible(true)
        if viewid == 1 or viewid == 2 then
      --   		if i == 3 then
      --   			local a = cc.Sprite:create("node/sikai.png")
						-- a:setScale(1.55)
    		-- 			nodeCard.card[i]:addChild(a)
    		-- 			a:setPosition(cc.p(75,108))
        			
        			
      --   			self.sd_buf[viewid] = a
      --   		end
        elseif viewid == 4 or viewid == 5 then 
      --   		if i == 3 then
      --   			local a = cc.Sprite:create("node/sikai.png")
						-- a:setScale(1.55)
    		-- 			nodeCard.card[i]:addChild(a)
    		-- 			a:setPosition(cc.p(75,108))
        			
      --   			self.sd_buf[viewid] = a
      --   		end
        end
       
        
        self.comPokeLose[viewid]:setVisible(true)
       
    end
    self:compareLose(viewid,fun)
end

function zjhScene:my_compare_card_win(bool)

	local node = self:findNodeByName("win_quan")
	local node1 =self:findNodeByName("My_win")
	node:setLocalZOrder(99)
	node1:setLocalZOrder(100)
	node:setVisible(bool)
				node1:setVisible(bool)
	if bool then
	node1:setScale(0.1)
	node:setScale(0.1)
	node1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1.2),cc.DelayTime:create(2),cc.CallFunc:create(function()

		node:stopAllActions()
				node1:stopAllActions()
				node:setVisible(false)
				node1:setVisible(false)

		end)))
	node:runAction(cc.ScaleTo:create(0.3,1.2))
	node:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,45)))
else
	node:stopAllActions()
				node1:stopAllActions()
				
end

end

function zjhScene:my_win(bool)

	local node = self:findNodeByName("win_quan")
	local node1 = self:findNodeByName("My_win")
	node:setLocalZOrder(99)
	node1:setLocalZOrder(100)
	node:setVisible(bool)
	node1:setVisible(bool)
	if bool then
		node1:setScale(0.1)
		node:setScale(0.1)

		node1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1.2)))
		node:runAction(cc.ScaleTo:create(0.3,1.2))
		node:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,45)))
    else
	    node:stopAllActions()
	    node1:stopAllActions()		 
    end

end

--弃牌状态
function zjhScene:SetUserGiveUp(viewid ,bGiveup,kanpai)
	local nodeCard = self.userCard[viewid]
	 if kanpai and viewid == MY_VIEWID then
	 	--self:my_hui(true)
	 else

	    for i = 1, 3 do
	        nodeCard.card[i]:loadTexture("poker/57.png")
	        nodeCard.card[i]:setVisible(false)
	    end
	end
		self.m_GiveUp[viewid]:loadTexture("qipaiicon.png")
    	self.m_GiveUp[viewid]:setVisible(bGiveup)
	
	if bGiveup then
		self.hui_bg[viewid]:setVisible(true)
		self.m_LookCard[viewid]:setVisible(false)
		
    if viewid == MY_VIEWID then
    	log("SetUserGiveUp____________________")
    	
    	self.nodeButtomButton:setVisible(false)
    	if kanpai then
    		self.userCard[viewid].cardType:setVisible(false)
    	end
    	 for i = 1, 3 do
    			local spr = cc.Sprite:create("poker/57.png")
	    			:addTo(self._node)
	    			:move(nodeCard.card[i]:getPosition())
	    	table.insert(self.tmpCard,spr)
	    	nodeCard.card[i]:setPositionY(self.MyCardPosY-300)
	    	spr:runAction(cc.Sequence:create(cc.Spawn:create(cc.RotateBy:create(0.5,720),cc.ScaleTo:create(0.5,0.1),cc.MoveTo:create(0.5,cc.p(self.removeCardPos:getPositionX(),self.removeCardPos:getPositionY()))),
	    		cc.CallFunc:create(function() spr:setVisible(false) 
	  				--spr:removeFromParent()
	    			nodeCard.card[i]:setVisible(true)
	    			if kanpai and viewid == MY_VIEWID then
	    				self:my_hui(true)

	    			end		
	    			nodeCard.card[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(nodeCard.card[i]:getPositionX(),self.MyCardPosY)),cc.CallFunc:create(function()

	    				if i == 3 then
							gt.log("auto_________",self.auto_compareCard)
							gt.dump(self.auto_compareCard)
							self.action = false
							if self.auto_compareCard then self:onSubCompareCard1(self.auto_compareCard) self.auto_compareCard = nil else 

								if self.min_result and not self.action and not self.action1 and self.compareidx == 0 and not self.action2 then self:gameEnd(self.min_result) self.min_result = nil end
								if self.max_result and not self.action and not self.action1 and self.compareidx == 0 and not self.action2 then self:GameResult(self.max_result) self.max_result = nil end

							end
							
	    				end
	    			 end)))
	    			 
	    		 end)))

	  
		end 	

    else
   		 for i = 1, 3 do
    	nodeCard.card[i]:setVisible(false)
	    	local spr = cc.Sprite:create("poker/57.png")
	    			:addTo(self._node)
	    			:move(nodeCard.card[i]:getPosition())
	    	table.insert(self.tmpCard,spr)
	    	spr:runAction(cc.Sequence:create(cc.Spawn:create(cc.RotateBy:create(0.7,720),cc.ScaleTo:create(0.7,0.1),cc.MoveTo:create(0.7,cc.p(self.removeCardPos:getPositionX(),self.removeCardPos:getPositionY()))),
	    		cc.CallFunc:create(function() spr:setVisible(false) 
	    				if i == 3 then
	    					gt.log("auto_________",self.auto_compareCard)
	    					gt.dump(self.auto_compareCard)
	    					self.action = false 
	    					if self.auto_compareCard then  self:onSubCompareCard1(self.auto_compareCard) self.auto_compareCard = nil else 
								if self.min_result and not self.action and not self.action1 and self.compareidx == 0 and not self.action2 then self:gameEnd(self.min_result) self.min_result = nil end
								if self.max_result and not self.action and not self.action1 and self.compareidx == 0 and not self.action2 then self:GameResult(self.max_result) self.max_result = nil end
							end
			
	    				end
	    		 end)))
		end 	
    end

end

    if bGiveup == true then
    	self:SetLookCard(viewid, false)
    end
end

function zjhScene:send_finish()

	local m = {}
	m.kMId = gt.MSG_C_2_S_POKER_GAME_MESSAGE
	m.kSubId = gt.SUB_C_FINISH_FLASH
	gt.dumplog(m)
	gt.socketClient:sendMessage(m)
end

function zjhScene:compareLose(id,fun)

	local viewid = id
	local nodeCard = self.userCard[id]
	self.hui_bg[viewid]:setVisible(true)
	self.m_LookCard[viewid]:setVisible(false)
	if id == MY_VIEWID then
		local bool = false
		if self.userCard[viewid].cardType:isVisible() then  bool = true self.userCard[viewid].cardType:setVisible(false) end
		 for i = 1, 3 do
    			local spr = cc.Sprite:create("poker/57.png")
	    			:addTo(self._node)
	    			:move(nodeCard.card[i]:getPosition())
	    	table.insert(self.tmpCard,spr)
	    	nodeCard.card[i]:setPositionY(self.MyCardPosY-300)
	    	spr:runAction(cc.Sequence:create(cc.Spawn:create(cc.RotateBy:create(0.5,720),cc.ScaleTo:create(0.5,0.1),cc.MoveTo:create(0.5,cc.p(self.removeCardPos:getPositionX(),self.removeCardPos:getPositionY()))),
	    		cc.CallFunc:create(function() spr:setVisible(false) 
	  				
	    			nodeCard.card[i]:setVisible(true)
	    			
	    			nodeCard.card[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(nodeCard.card[i]:getPositionX(),self.MyCardPosY)),cc.DelayTime:create(1),cc.CallFunc:create(function()
	    				if i ==3 then
	    					if fun then 
	    						fun()
	    					end
	    				end
	    			 end)))
	    			 
	    		 end)))

	  
		end 	


	else

		 for i = 1, 3 do
		 	nodeCard.card[i]:setVisible(false)
	    	local spr = cc.Sprite:create("poker/57.png")
	    			:addTo(self._node)
	    			:move(nodeCard.card[i]:getPosition())
	    	table.insert(self.tmpCard,spr)
	    	spr:runAction(cc.Sequence:create(cc.Spawn:create(cc.RotateBy:create(0.7,720),cc.ScaleTo:create(0.7,0.1),cc.MoveTo:create(0.7,cc.p(self.removeCardPos:getPositionX(),self.removeCardPos:getPositionY()))),
	    		cc.CallFunc:create(function() spr:setVisible(false) 
	    			
	    		 end),cc.DelayTime:create(1),cc.CallFunc:create(function()
	    		 	if i == 3 then
	    				if fun then
	    					fun()
	    				end
	    			end
	    		end)))

		end 	

	end

end

--清理牌
function zjhScene:clearCard(viewid)
	local nodeCard = self.userCard[viewid]
	for i = 1, 3 do
		nodeCard.card[i]:loadTexture("poker/56.png")
		nodeCard.card[i]:setVisible(false)
	end
	self.m_GiveUp[viewid]:setVisible(false)
end

--显示牌值
function zjhScene:SetUserCard(viewid, cardData)
	if not viewid or viewid == gt.INVALID_CHAIR then
		return
	end



	--if self.sd_buf[viewid] then self.sd_buf[viewid]:setVisible(false) end
 	local iskanpai = false
	
	--纹理
	if not cardData then
		for i = 1, 3 do
			self.userCard[viewid].card[i]:loadTexture("poker/56.png")
			self.userCard[viewid].card[i]:setVisible(false)
			self.userCard[viewid].card[i]:setRotation(0)
		end
	else
		for i = 1, 3 do
			local spCard = self.userCard[viewid].card[i]
			self.userCard[viewid].card[i]:setRotation(0)
			if not cardData[i] or cardData[i] == 0 or cardData[i] == 0xff  then
				spCard:loadTexture("poker/56.png")
				iskanpai = false
			else
				--local strCard = string.format("poker/%02d.png",cardData[i])
				iskanpai = true
				if self.qipai then self:my_hui(true) end
				print(cardData[i])
				local strCard = "poker/"..gt.tonumber(cardData[i])..".png"
				log("strcard...",strCard,viewid)
				spCard:loadTexture(strCard)
				if GAME_PLAYER == 5  then 
					if viewid == 2 or viewid == 4 then
						self.userCard[viewid].resultScore:setPosition(self._node:getChildByName("Node__"..viewid):getPosition())
					end
				end
			end
			self.userCard[viewid].card[i]:setVisible(true)

			spCard:stopAllActions()
			if viewid ~= MY_VIEWID then
				spCard:setScale(scale)
			else
			    spCard:setScale(0.75)
			end
			self.userCard[viewid].card[i]:setRotation(0)
			if iskanpai then        
				if self:l_or_r(viewid) == "r" then                 
					spCard:move(ptCard[viewid].x - (viewid==MY_VIEWID and 122.39 or distanceCards)*(i- 1),ptCard[viewid].y)
				else
					spCard:move(ptCard[viewid].x + (viewid==MY_VIEWID and 122.39 or distanceCards)*(i- 1),ptCard[viewid].y)
					
				end
			else
			
				if self:l_or_r(viewid) == "r" then                  
					spCard:move(ptCard[viewid].x - (viewid==MY_VIEWID and 122.39 or distanceCard)*(i- 1),ptCard[viewid].y) -- 32.89
				else
					spCard:move(ptCard[viewid].x + (viewid==MY_VIEWID and 122.39 or distanceCard)*(i- 1),ptCard[viewid].y)
					
				end
			end

		end
		self:PlaySound("sound_res/fanpai.mp3")
	end



	
end

--显示牌类型

-- //扑克类型
-- #define CT_SINGLE					1									//单 牌 类 型
-- #define CT_DOUBLE					2									//对 子 类 型
-- #define	CT_SHUN_ZI					3									//顺 子 类 型
-- #define CT_JIN_HUA					4									//金 花 类 型
-- #define	CT_SHUN_JIN					5									//顺 金 类 型
-- #define	CT_BAO_ZI					6									//豹 子 类 型
-- #define CT_SPECIAL					7									//特 殊 类 型
  
-- //天龙地龙特殊牌型
-- #define  CT_SHUN_DI_DRAGON          11             //顺子 地龙
-- #define  CT_SHUN_TIAN_DRAGON    	   12            //顺子 天龙
-- #define CT_JIN_DI_DRAGON            13            //金花 地龙
-- #define CT_JIN_TIAN_DRAGON          14           //金花 天龙

function zjhScene:SetUserCardType(i,cardtype)

	if cardtype and cardtype >= 1 and cardtype <= 14 then
		self.userCard[i].cardType:loadTexture("cardType/"..cardtype..".png")
		self.userCard[i].cardType:setVisible(true)
		self.card_type_buf[i] = cardtype
	else
		self.userCard[i].cardType:setVisible(false)
	end
end

function zjhScene:SetUserCardType1(i,cardtype)

	if cardtype and cardtype >= 1 and cardtype <= 14 then
		
		self.userCard[i].cardType:setVisible(false)
		if self._resule_spr then self._resule_spr:removeFromParent() self._resule_spr = nil end 
		self._resule_spr = cc.Sprite:create("cardType/"..cardtype.."s.png")
						   :addTo(self._node)
												  
		if i == MY_VIEWID then self._resule_spr:setPosition(cc.p(self.userCard[i].cardType:getPositionX(),self.userCard[i].cardType:getPositionY()-45)) else self._resule_spr:setPosition(cc.p(self.userCard[i].cardType:getPositionX(),self.userCard[i].cardType:getPositionY())) end									   	

	end
end




--赢得筹码
function zjhScene:WinTheChip(wWinner,MaxResult,_palysoundWin,cbCardData,msg)
	--筹码动作
	-- 播放丁的声音
	if not wWinner or wWinner == gt.INVALID_CHAIR then return end
	log("win.....",wWinner)
	self:PlaySound("sound_res/movechip.mp3")

	if self.gaoqing then 
		local children = self.nodeChipPool:getChildren()
		local num = 0
		log("ch________________",#children)
		for k, v in pairs(children) do

				v:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),--cc.DelayTime:create(0.1*(#children - k)),
				cc.MoveTo:create(0.5, cc.p(self.nodePlayer[wWinner]:getPosition())),
				cc.CallFunc:create(function(node)
					node:removeFromParent()
						
						if k == 1 then
						
							self:PlaySound("sound_res/MY_MENU.mp3")
							self:SetUserTableScore2(true,MaxResult,cbCardData,msg)
							
						end
				end)))
		end

		if #children == 0 then 
			for i = 1 , 5 do

				self.__chip[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),--cc.DelayTime:create(0.1*(#children - k)),
					cc.MoveTo:create(0.5, cc.p(self.nodePlayer[wWinner]:getPosition())),
					cc.CallFunc:create(function(node)
						self.__chip[i]:setVisible(false)
							
							if i == 5 then
							
								self:PlaySound("sound_res/MY_MENU.mp3")
								self:SetUserTableScore2(true,MaxResult,cbCardData,msg)
								
							end
					end)))

			end

		end

	else
		for i = 1 , 5 do

			self.__chip[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),--cc.DelayTime:create(0.1*(#children - k)),
				cc.MoveTo:create(0.5, cc.p(self.nodePlayer[wWinner]:getPosition())),
				cc.CallFunc:create(function(node)
					self.__chip[i]:setVisible(false)
						
						if i == 5 then
						
							self:PlaySound("sound_res/MY_MENU.mp3")
							self:SetUserTableScore2(true,MaxResult,cbCardData,msg)
							
						end
				end)))

		end

	end
end

--清理筹码
function zjhScene:CleanAllJettons()
	self.nodeChipPool:removeAllChildren()
end





function zjhScene:shareWx()



 	local lunshu = ""
   	if yl.GAMEDATA[5] ~= -1 then 
   		lunshu = "轮数:"..yl.GAMEDATA[5]
   	end

   	local men = ""

   	if tonumber(yl.GAMEDATA[7]) == 0 then 
		men = "，必闷轮数:0 "
	elseif tonumber(yl.GAMEDATA[7]) == 1 then 
		men = "，必闷轮数:1 "
	elseif tonumber(yl.GAMEDATA[7]) == 2 then
		men = "，必闷轮数:2 "
	elseif tonumber(yl.GAMEDATA[7]) == 3 then
		men = "，必闷轮数:3 "

	end

	local teshu = ""
	if tonumber(yl.GAMEDATA[8]) == 1 then 
		teshu = "，豹子同花顺加分"
	else
		
	end


   

    local str = ""
    if yl.GAMEDATA[4] == 2 then
   		str = "，大牌模式，"
	elseif yl.GAMEDATA[4] == 1 then
		str = "，普通模式，"
	end

	local strs = "经典玩法，"
   	if yl.GAMEDATA[17] == 1 then
		strs = "爽翻玩法，"
	end

	local strs1 = ""
	if yl.GAMEDATA[18] == 1 then
		strs1 = "，随时进出牌局"
	end


	local fen = ""
	-- 6 or 7
	if yl.GAMEDATA[6] ~= -1 then

	
		if yl.GAMEDATA[6] == 3 or yl.GAMEDATA[6] == 2 then 
			fen = yl.GAMEDATA[6].."分场"
		elseif yl.GAMEDATA[6] == 1 then
			fen = "1分(小)场"
		elseif yl.GAMEDATA[6] == 4 then
			fen = "1分(大)场"
		end

	end
-- 这
	

	local t = ""
	if tonumber(yl.GAMEDATA[19]) == 1 then
		t = ",操作时间10秒,"
	elseif tonumber(yl.GAMEDATA[19]) == 2 then
		t = ",操作时间15秒,"
	elseif tonumber(yl.GAMEDATA[19]) == 3 then
		t = ",操作时间30秒,"
	end

	local shareTxt = "局数："..self.jushu..","..strs..lunshu..men..teshu..str..fen..t..(yl.GAMEDATA[9]==1 and "可托管，" or "")..(yl.GAMEDATA[11]==1 and "倍开，" or "")..(yl.GAMEDATA[12]==1 and "天龙地龙，" or "")..(yl.GAMEDATA[14]==1 and "允许买小，" or "")..(yl.GAMEDATA[15]==1 and "豹子最大，" or "")..(yl.GAMEDATA[13]==1 and "允许动态加入" or "")
   	
   	local ren = ""
   	if GAME_PLAYER then
   		ren = ","..GAME_PLAYER.."人场"
   	end
    local txt = ""

    if yl.GAMEDATA[17] == 1 then
    	txt = self.m_atlasRoomID:getString().."，赢三张,"..strs..fen..strs1
    else
    	txt = self.m_atlasRoomID:getString().."，赢三张"..str..fen..ren
    end

    gt.log(shareTxt)
    gt.log(txt)

    
    local url = string.format(gt.HTTP_INVITE, gt.nickname, self.Player[MY_VIEWID].url, self._roomId, self.m_atlasRoomID:getString().."，赢三张，"..shareTxt)
    gt.log(url)
	Utils.shareURLToHY(url,txt,shareTxt,function(ok)
		if ok == 0 then 
		Toast.showToast(self, "分享成功", 2)
		end

		end)


end

function zjhScene:switchAuto(num,bool)
	
	if tonumber(num) == 1 then
		self.is_auto = not self.is_auto
		if self.is_auto then
			if self.shuohua and not bool then 
		
			log("SUB_S_AUTO_SCORE_RESULT_____________________")
			if not self.iskanpai then
				self:addScore(self._difen,0)
			else
				self:addScore(self._difen*2,0)
			end
			self.shuohua = false
			self:switch_look_card_btn()
			end
			self.btCompare:setEnabled(false)
			if not self.max_chip then 
				self.btAddScore:setEnabled(false)
			end
			--跟注按钮
			self.btFollow:setEnabled(false)

			

			self.auto_btn:loadTextureNormal("btn/quit_auto.png")
			self.auto_btn:loadTexturePressed("btn/quit_auto.png")
			self.auto_btn:getChildByName("num"):setVisible(true)
			if self.gaoqing then 
				self.autoAction:setVisible(true)
			end
		else

			log("SUB_S_AUTO_SCORE_RESULT_____________________11111")
			self.autoAction:setVisible(false)
			self.auto_btn:loadTextureNormal("btn/automatic.png")
			self.auto_btn:loadTexturePressed("btn/automatic.png")
			self.auto_btn:getChildByName("num"):setVisible(true)
			if not self.iscaozuo then 

				self:Updatabtn(true)

			end
		end
	end
end

function zjhScene:switchReady()
	
	if tonumber (yl.GAMEDATA[9]) == 1 then 
		self.btReady:loadTextureNormal("btn/next_game.png")
		self.btReady:loadTexturePressed("btn/next_game.png")
		self:findNodeByName("num", self.btReady):setVisible(true)
	else
		self.btReady:loadTextureNormal("btn/next_game1.png")
		self.btReady:loadTexturePressed("btn/next_game1.png")
		self:findNodeByName("num", self.btReady):setVisible(false)
	end
	self.btReady:setPosition(self.m_btnInvite:getPosition())
	
end

function zjhScene:addPlayer(args)

	if not args then  -- init user

		local pos = self:getTableId(self.UsePos)
		gt.dumplog(self.data)
		log("pos..",pos)
		self.m_UserHead[pos].score:setString(self.data.kScore)

		self.Player[pos].sex = gt.userSex or 1

		self.m_cbPlayStatus[pos] = 1
		self:disBeginBtn(self.data.kStartGameButtonPos)
		--self.m_flagReady[pos]:setVisible(self.data.kReady == 1)
		if self.data.kReady == 1 then 
			local m = {}
			m.kPos = self.UsePos
			self:RcvReady(m)
		else
			self.m_flagReady[pos]:setVisible(false)
		end
		gt.log("ready......",self.data.kReady)
		self.btReady:setVisible(self.data.kReady ~= 1)
		if self.data.kReady ~= 1 then 
		else
			self.r_time = 0
		end
		if GAME_PLAYER == 5 then 
			self.m_flagReady[pos]:setPosition(self._node:getChildByName("ready"..pos):getPosition())
		end
		gt.log("add.....",pos,(self.data.kReady==1))
		self.palyerPos[pos] = self.UsePos
		self.nodePlayer[pos]:setVisible(true)
		gt.log(gt.wxNickName)
		self.Player[pos].score = self.data.kScore or ""
		self.Player[pos].name = gt.wxNickName or cc.UserDefault:getInstance():getStringForKey( "WX_Nickname","")
		self.Player[pos].score = self.data.kScore or ""
		self.Player[pos].id = gt.playerData.uid or ""
		self.Player[pos].ip = self.data.kUserIp or ""
		self.Player[pos].Coins = self.data.kCoins or ""
		--self.m_UserHead[pos].name:setString(gt.wxNickName or "name")
		self.m_UserHead[pos].name:setString(gt.wxNickName)
		
		self.__clock = self.data.kClock

		log("name...",self.data.kNike)
		local url 	= cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl" ,"" )
		--url = "http://thirdwx.qlogo.cn/mmopen/vi_32/vNgRwEkG9cklZ8XluOjGeUraEJicfjZBSiaFSrf7RduNc6NQicX1weXDEkOkUJfXNAFvDEzFgYx8rOGteBm9K0HOA/132"
		self.Player[pos].url = url
		local icon = self.nodePlayer[pos]:getChildByName("icon")
		local _name ,b = string.gsub(url, "[/.:+]", "")

		local iamge = gt.imageNamePath(url)
	  	if iamge then
	  		
	  		local _node = display.newSprite("player/icon.png")
			self.m_UserHead[pos].head = gt.clippingImage(iamge,_node,false)
			self.m_UserHead[pos].head:setLocalZOrder(20)
			if GAME_PLAYER == 8 then 
				self.m_UserHead[pos].head:setScale(0.8)
			end
			if self.nodePlayer[pos]:getChildByName(_name) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(_name):removeFromParent() end
			self.nodePlayer[pos]:addChild(self.m_UserHead[pos].head)
			self:findNodeByName("zhuang", self.nodePlayer[pos]):setLocalZOrder(21)
			self.m_UserHead[pos].head:setName(_name)
			self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())

	  	else

		  	if type(url) ~= nil and  string.len(url) > 10 then
				self.urlName[pos] = string.gsub(url, "[/.:+]", "")
		  		local function callback(args)
		      		if args.done  and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self then

						local _node = display.newSprite("player/icon.png")
						self.m_UserHead[pos].head = gt.clippingImage(args.image,_node,false)
						self.m_UserHead[pos].head:setLocalZOrder(20)
						if GAME_PLAYER == 8 then 
							self.m_UserHead[pos].head:setScale(0.8)
						end
						self:findNodeByName("zhuang", self.nodePlayer[pos]):setLocalZOrder(21)
						if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
						self.nodePlayer[pos]:addChild(self.m_UserHead[pos].head)
						self.m_UserHead[pos].head:setName(self.urlName[pos])
						self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
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
		local pos = self:getTableId(args.kPos)
		gt.log("adds.....",pos)
		self.m_UserHead[pos].score:setString(args.kScore)
		self.Player[pos].sex = args.kSex or 1
		self.m_cbPlayStatus[pos]= (args.kDynamicJoin == 0 and 1 or 0)
		self.Player[pos].name = args.kNike or ""
		self.Player[pos].id = args.kUserId or ""
		self.Player[pos].ip = args.kIp or ""
		self.Player[pos].score = args.kScore or ""
		self.Player[pos].Coins = args.kCoins or ""
		--self.m_flagReady[pos]:setVisible(args.kReady==1)
		-- local m = {}
		-- m.kPos = args.kReady
		-- self:RcvReady(m)

		if args.kReady == 1 then 
			
			self:RcvReady(args)
		else
			self.m_flagReady[pos]:setVisible(false)
		end

		if GAME_PLAYER == 5 then 
			self.m_flagReady[pos]:setPosition(self._node:getChildByName("ready"..pos):getPosition())
		end
		self.nodePlayer[pos]:setVisible(true)
		
		--self.m_UserHead[pos].name:setString(args.nickname or "name")
		self.m_UserHead[pos].name:setString(args.kNike)
		self.Player[pos].url = args.kFace or ""
		self.Player[pos].score = args.kScore or ""
		local url 	= args.kFace or ""
		local icon = self.nodePlayer[pos]:getChildByName("icon")
		local iamge = gt.imageNamePath(url)
		self.urlName[pos] = string.gsub(url, "[/.:+]", "")
	  	if iamge then

	  		local _node = display.newSprite("player/icon.png")
			self.m_UserHead[pos].head = gt.clippingImage(iamge,_node,false)
			self.m_UserHead[pos].head:setLocalZOrder(20)
			--self.m_UserHead[pos].head:setScale(0.8)
			self:findNodeByName("zhuang", self.nodePlayer[pos]):setLocalZOrder(21)
			if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
			self.nodePlayer[pos]:addChild(self.m_UserHead[pos].head)
			self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
	  	else
	  		
	  		 	if type(url) ~= nil and  string.len(url) > 10 then
			
		  		local function callback(args)
		      		if args.done and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self.m_UserHead[pos] and self then

						local _node = display.newSprite("player/icon.png")
						self.m_UserHead[pos].head = gt.clippingImage(args.image,_node,false)
						self.m_UserHead[pos].head:setLocalZOrder(20)
						--self.m_UserHead[pos].head:setScale(0.8)
						self:findNodeByName("zhuang", self.nodePlayer[pos]):setLocalZOrder(21)
						if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
						self.nodePlayer[pos]:addChild(self.m_UserHead[pos].head)
						self.m_UserHead[pos].head:setName(self.urlName[pos])
						self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
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

end

function zjhScene:removePlayer(args)

	gt.dumplog(args)
	if args and args.kPos ~= 21 and args.kPos then 
		self.head_hui[self:getTableId(args.kPos)]:setVisible(false)
		self.nodePlayer[self:getTableId(args.kPos)]:setVisible(false)
		self.m_flagReady[self:getTableId(args.kPos)]:setVisible(false)
		self.m_cbPlayStatus[self:getTableId(args.kPos)] = 0
		if self._sche_url[self:getTableId(args.kPos)] then _scheduler:unscheduleScriptEntry(self._sche_url[self:getTableId(args.kPos)]) self._sche_url[self:getTableId(args.kPos)] = nil end
		if self._sche_buf[self:getTableId(args.kPos)] then _scheduler:unscheduleScriptEntry(self._sche_buf[self:getTableId(args.kPos)]) self._sche_buf[self:getTableId(args.kPos)] = nil end 
		if args.kPos == self.UsePos then self:onExitRoom("房间已解散！") end
	end
end


--按键响应
function zjhScene:OnButtonClickedEvent(tag,ref)
	log("tag..,,,,",tag)
	if tag == BT_EXIT1 then
		if self.action or self.action1 or self.action2 or self.compareidx ~= 0 then return end
		self:PlaySound("sound_res/cli.mp3") 
		if not gt.isCreateUserId and not self.gameBegin  then -- and 游戏没开始
			self:exitRoom(false)
		else
			self:exitRoom(true)
		end
	elseif tag == BT_EXIT then 
		if self.action or self.action1 or self.action2 or self.compareidx ~= 0 then return end
		self:PlaySound("sound_res/cli.mp3")
		self:exitRoom(self.gameBegin)
	elseif tag == BTN_SHARE then
		self:PlaySound("sound_res/cli.mp3")
		--self.result_node:shareWxImage()
	elseif tag == BTN_QUIT then
		self:PlaySound("sound_res/cli.mp3")
		
        self:onExitRoom()
	elseif tag== BT_INVITE then
		self:PlaySound("sound_res/cli.mp3")
		self:shareWx()
	elseif tag == BT_BEGIN then
		self:PlaySound("sound_res/cli.mp3")
		self:onBeginGame()
		self.begin_btn:setVisible(false)
	elseif tag == BT_AUTO then
		self:PlaySound("sound_res/cli.mp3")
		self:autoAddScore(self.is_auto)
		self.btGiveUp:setEnabled(false)
		self.btCompare:setEnabled(false)
	elseif tag == BT_READY then
		self:PlaySound("sound_res/cli.mp3")
		self:onStartGame()
		self:switchReady()
		self:OnResetView()
	elseif tag == BT_READ then
		self:PlaySound("sound_res/cli.mp3")
		
		self:disPlaygameResult()
	elseif tag == BT_GIVEUP then

	
		self:onGiveUp()
	elseif tag == BT_LOOKCARD then
		-- self:_playSound(MY_VIEWID,"kanpai.mp3")
		-- self.m_LookCard[MY_VIEWID]:setVisible(true) 
		-- self.btLookCard:setVisible(false)
		-- self:onLookCard()
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
		self:PlaySound("sound_res/cli.mp3")
		local chatPanel = require("client/game/majiang/ChatPanel"):create(false)
		self:addChild(chatPanel, zjhScene.ZOrder.CHAT)
	elseif tag == BT_MENU then
		self:PlaySound("sound_res/cli.mp3")
		self:ShowMenu(not self.m_bShowMenu)
	elseif tag == BT_HELP then
		
	elseif tag == BT_SET then
		
	elseif tag == BT_BANK then
		showToast(self, "该功能尚未开放，敬请期待...", 1)
	end
end


function zjhScene:_addScore()

	self._node:getChildByName("genzhuBg"):setVisible(true)
	
end


-- function zjhScene:playVoice(curUrl,kPos)
	
-- 	--gt.a_log("url_______________",curUrl)
-- 	local videoTime = 0
-- 	local num1,num2 = string.find(curUrl, "\\")
-- 	if not num2 or num2 == nil then
-- 		Toast.showToast(self, "语音文件错误", 2)
-- 		return
-- 	end

-- 	local curUrls = string.sub(curUrl,1,num2-1)
-- 	videoTime = string.sub(curUrl,num2+1)


-- 	local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "playVoice", {curUrls}, "(Ljava/lang/String;)V")
-- 	self:ShowUserChat1(self:getTableId(kPos),videoTime,function()
-- 			table.remove(self["voiceUrl"..kPos],1)
-- 		--	gt.a_log("remove_______________"..kPos)
-- 			if self["voiceUrl"..kPos][1] then 
-- 				self:playVoice(self["voiceUrl"..kPos][1],kPos)
-- 			end
-- 		end)
-- end

function zjhScene:onRcvChatMsg(msgTbl)
	gt.log("收到聊天消息")
	--dump(msgTbl)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("images/EmotionOut.plist")
	if msgTbl.kType == 5 then -- 互动动画类型
	
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
			self:ShowUserChat(self:getTableId(msgTbl.kPos),gt.getLocationString("LTKey_00299_" .. msgTbl.kId),msgTbl)
		
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
			local animationStr = "res/animation/biaoqing/".. picStr .. ".csb"
			local animationNode, animationAction = gt.createCSAnimation(animationStr)
			animationAction:play("run", false)
			local icon = self.nodePlayer[self:getTableId(msgTbl.kPos)]:getChildByName("icon")
			animationNode:setPosition(cc.p(icon:getPositionX(),icon:getPositionY()))
			self.animationNode = animationNode
			self.animationAction = animationAction
			
			animationNode:setLocalZOrder(21)
			if chatBgNode:getChildByName("__BIAOQING___") then chatBgNode:getChildByName("__BIAOQING___"):removeFromParent() end
			chatBgNode:addChild(animationNode)
			animationNode:setName("__BIAOQING___")
			local chatBgNode_delayTime = cc.DelayTime:create(3)
			local chatBgNode_callFunc = cc.CallFunc:create(function(sender)
				if chatBgNode:getChildByName("__BIAOQING___") then chatBgNode:getChildByName("__BIAOQING___"):removeFromParent() end
				display.removeSpriteFrames("biaoqingbao/biaoqing.plist","biaoqingbao/biaoqing.png")
			end)
			local chatBgNode_Sequence = cc.Sequence:create(chatBgNode_delayTime, 
														 chatBgNode_callFunc)
			chatBgNode1:runAction(chatBgNode_Sequence)
		elseif msgTbl.kType == gt.ChatType.VOICE_MSG then
		end

	
	end
end

--voicelist
function zjhScene:startVoiceSchedule(msgTbl)
	if self.voiceList == nil then
		self.voiceList = {}
	end
	table.insert(self.voiceList, {msgTbl, 0})
	gt.log("zjhScene:playVoice")
	gt.dump(self.voiceList)
	if self.voiceListListener == nil then
		self.voiceListListener = gt.scheduler:scheduleScriptFunc(handler(self, self.playVoice), 1, false)
	end
end

--voicelist
function zjhScene:playVoice()
	gt.log("zjhScene:playVoice")
	gt.dump(self.voiceList)
	gt.log(table.nums(self.voiceList))
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
function zjhScene:stopPlayVoice()
	self:getLuaBridge()
	if gt.isIOSPlatform() then
		local ok = self.luaBridge.callStaticMethod("AppController", "stopPlayVoice", {})
	elseif gt.isAndroidPlatform() then
		local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "stopPlayVoice", {curUrl}, "()V")
	end
end

function zjhScene:ShowUserChat1(viewid,time)

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
function zjhScene:ShowUserChat(viewid ,message,msg)
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
			if self.Player[viewid].sex  == 2 then 
				self:PlaySound("sound/1_"..msg.kId.."ss.mp3", false)
			else
				self:PlaySound("sound/1_"..msg.kId.."s.mp3", false)
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
		self.m_UserChat[viewid]:addTo(self._node)
		if GAME_PLAYER ==  8 then 
			if viewid <= MY_VIEWID or viewid == GAME_PLAYER then
				self.m_UserChat[viewid]:move(self._voice[viewid]:getPositionX()+15,self._voice[viewid]:getPositionY()+17)
					:setAnchorPoint( cc.p(0, 0) )
					:setLocalZOrder(1002)
			else
				self.m_UserChat[viewid]:move(self._voice[viewid]:getPositionX()-15,self._voice[viewid]:getPositionY())
					:setAnchorPoint(cc.p(1,1))
					:setLocalZOrder(1002)
			end
		elseif GAME_PLAYER == 5 then 
			if viewid <= 3 then
				self.m_UserChat[viewid]:move(ptChat[viewid].x + 14 , ptChat[viewid].y + 5)
					:setAnchorPoint( cc.p(0, 0.5) )
			else
				self.m_UserChat[viewid]:move(ptChat[viewid].x - 14 , ptChat[viewid].y + 5)
					:setAnchorPoint(cc.p(1, 0.5))
			end
		end
		--改变气泡大小
		self.m_UserChatView[viewid]:setContentSize(self.m_UserChat[viewid]:getContentSize().width+28, self.m_UserChat[viewid]:getContentSize().height + 27)
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




function zjhScene:Updatabtn(bool)


	gt.log("self.qipai......",self.qipai,tostring(bool),self._lunshu,tonumber(yl.GAMEDATA[7]))

	if self.is_auto then return end

	if self.qipai then return end
	if self.guancha then return end

    self.nodeButtomButton:setVisible(true)
    self.auto_btn:setVisible(true)
   
  
    
    if bool then
        if not self.max_chip then 
        	self.btAddScore:setEnabled(true)
        end
        self.btFollow:setEnabled(true)
        if self._lunshu and self._lunshu > tonumber(yl.GAMEDATA[7]) then
        	self.btGiveUp:setEnabled(bool)
           	if not self.menpai and self._lunshu > 1 then
           		self.btCompare:setEnabled(true)
           	else
           		self.btCompare:setEnabled(false)
           	end
        else
        	self.btGiveUp:setEnabled(false)
        end
    else
        self.btCompare:setEnabled(false)
        if not self.max_chip then 
       		self.btAddScore:setEnabled(false)
    	end
      	self.btGiveUp:setEnabled(false)
        self.btFollow:setEnabled(false)

    end
  
    self.btLookCard:setEnabled(not self.menpai)

end


function zjhScene:clock_time(time)
	if tonumber (yl.GAMEDATA[9]) ~= 1 then return end
	time = time.kCurCircle or 15
	local str = self:findNodeByName("num", self.btReady)
	str:setString(time)
	if self._clockGameStart then _scheduler:unscheduleScriptEntry(self._clockGameStart) self._clockGameStart = nil end
	self._clockGameStart = _scheduler:scheduleScriptFunc(function()
		time = time - 1 
		if time <=0 then  time = 0  if self._clockGameStart then _scheduler:unscheduleScriptEntry(self._clockGameStart) self._clockGameStart = nil end end 
		str:setString(time)

		end,1,false)
	str:setString(time)

end

function zjhScene:switch_look_card_btn()

	if tonumber(yl.GAMEDATA[17]) == 1 and not self.iskanpai then 
	
			self.btorlookcard:setVisible(not self.shuohua)
			self.btLookCard:setVisible(self.shuohua)
		
	end

	if self.iskanpai then 
		self.btorlookcard:setVisible(false)
	end

end

-- 设置计时器
function zjhScene:SetGameClock(chair,time,idx)



    if not self.gameBegin then return end

    self:KillGameClock()


    
    local viewid = self:getTableId(chair)
   
    if viewid == MY_VIEWID then
        self.iscaozuo = false
        self.shuohua = true
    else
        self.iscaozuo = true
        self.shuohua = false
    end
    self:switch_look_card_btn()
    local t_time = time - 0.5  -- 自动下注
    local t__time = time -2 -- 倒计时提示
    
    if viewid and viewid ~= gt.INVALID_CHAIR then
        log("view........",viewid)
        if not idx then 
	        if  self.gaoqing then 
	            self:actionSign(viewid,true)
	        else
	            self:actionliuchang(viewid,true)
	        end
    	end
        local clock 
        local progress = self.m_TimeProgress[viewid]
        if tonumber (yl.GAMEDATA[9]) == 1 or idx then 
        	clock = self:findNodeByName("clock",self.nodePlayer[viewid])
        	clock:setLocalZOrder(22)
        else
        	
        	for i = 1 , GAME_PLAYER do
        		self:findNodeByName("clock",self.nodePlayer[i]):setVisible(false)
        	end
    	end
        if progress ~= nil then
            if self._time then
                _scheduler:unscheduleScriptEntry(self._time)
                self._time = nil
            end
            time = time - 0.5
           
            local max = time
            self._time = _scheduler:scheduleScriptFunc(function()


                    if t_time == time then

                        if viewid == MY_VIEWID then 
                            if self.is_auto and not self.qipai then
                                --log("diu++++++++++++++++++")
                                self:Updatabtn(not self.is_auto)
                                if not self.iskanpai then

                                    self:addScore(self._difen,0)
                                else
                                    self:addScore(self._difen*2,0)
                                end
                                self:_playSound(MY_VIEWID,"genzhu.mp3")
                            end

                            self.shuohua = true
                        else
                            self.shuohua = false
                        end
                    elseif t__time == time then
                         if viewid == MY_VIEWID then 
                            self:PlaySound("sound_res/MY_MENU.mp3")
                        end
                    end

                    time = time - 0.5
                    local tmp = time/max
                    if time <= 0 then
                        if self._time then
                            _scheduler:unscheduleScriptEntry(self._time)
                            self._time = nil
                        end
                    end
                    local g = 255 * tmp
                    local r = 255 - g
                    local b = 0
                    if g <=0 then g = 0 end
                    if r >= 255 then r = 255 end
                    if self.m_sprite[viewid] then 
                    	self.m_sprite[viewid]:setColor(cc.c3b(r,g,b))
                	end
                    if time == 2 then
                        self:PlaySound("sound_res/time.mp3")
                    end
                   	

                    if time % 1 == 0  and (tonumber(yl.GAMEDATA[9]) == 1 or idx) then 
                   		clock:setVisible(true)
                   		self:findNodeByName("num", clock):setString(time)
                   	end
                end,0.5,false)
            progress:setPercentage(0)
            progress:setVisible(true)
            progress:runAction(cc.Sequence:create(cc.ProgressTo:create(time, 100), cc.CallFunc:create(function()
               
               self.nodePlayer[viewid]:getChildByName("sp_8"):setVisible(true)
               self.nodePlayer[viewid]:getChildByName("sp_8"):setColor(cc.c3b(255,0,0))
               
            end)))
        end
    end
end

function zjhScene:KillGameClock()
	if self._time then
        _scheduler:unscheduleScriptEntry(self._time)
        self._time = nil
    end

     for i = 1 ,GAME_PLAYER do
        self.nodePlayer[i]:getChildByName("sp_8"):setVisible(false)
        self:actionSign(i,false)
        self:actionliuchang(i,false)
        if  self.m_TimeProgress[i] then 
             self.m_TimeProgress[i]:setVisible(false)
             self.m_TimeProgress[i]:stopAllActions()
             self.m_TimeProgress[i]:setPercentage(0)
        end
         local clock = self:findNodeByName("clock",self.nodePlayer[i])
         clock:setVisible(false)
     end

end




function zjhScene:OnFlushCardFinish(isFlush)

    

                local myChair = self:GetMeChairID()
                if myChair == self.m_wLostUser then
                    self:PlaySound("sound_res/COMPARE_LOSE.mp3")
                end
                self:setuserlose(self:SwitchViewChairID(self.m_wLostUser))

                local spr = self._node:getChildByName("TotalScore")
               
                spr:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() --1.3 + 1.7

                		gt.log("spr________________")
                      	self:StopCompareCard()
                       
                    	local count = self:getPlayingNum()

                    	if self.genxinBtn then 
	                        if count > 1 then 
	                            self:SetGameClock(self.m_wCurrentUser, TIME_USER_ADD_SCORE)
	                        end
	                     	local bool = (self.m_wCurrentUser == self:GetMeChairID())
							if not self.is_auto then
							    self:Updatabtn(bool)
							end
						end

					    if  self.guancha  then  self.nodeButtomButton:setVisible(false) end

					    if  self.m_wLostUser == self:GetMeChairID() then
					        self.nodeButtomButton:setVisible(false)
					        self.qipai = true
					    end

					    if isFlush == 1 then 
						    self.m_bStartGame = false
						    self.nodeButtomButton:setVisible(false)
						end

 					  	self:findNodeByName("Panel_hui"):setVisible(false)
                   
                    	local myChair = self:GetMeChairID()

                        if myChair == self.m_wWinnerUser then
                            self:PlaySound("sound_res/COMPARE_WIN.mp3")
                            self:my_compare_card_win(true)
                        end



                    end)))

              --  if isFlush == 1 then 

                      spr:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() -- 2
                      
 					   
						
                  		

                      	self.compareidx =  self.compareidx -1 
                      		log("flush_______",self.compareidx)
                      	if self.compareidx < 0 then self.compareidx = 0 end
                      	self.action1 = false 
	    				if self.auto_compareCard then  
	    					self:onSubCompareCard1(self.auto_compareCard) self.auto_compareCard = nil 
	    				else 
	    					if self.min_result and self.compareidx == 0 and not self.action and not self.action1 and not self.action2 then self:gameEnd(self.min_result) self.min_result = nil end if self.max_result  and self.compareidx == 0 and not self.action and not self.action1 and not self.action2 then self:GameResult(self.max_result) self.max_result = nil end 
	    				end
	    				
                    end)))
                -- else
                -- 	self.action1 = false

                -- end


   
end

function zjhScene:renovate(msg)
	if not msg or not msg.kCurCircle or not msg.kCurMaxCircle then return end
	gt.dumplog(msg)

	gt.curCircle = msg.kCurCircle
	gt.log("刷新局数______________")
	self.___jushu = msg.kCurCircle
	if msg.kCurCircle > 0 then self.m_btnInvite:setVisible(false)  self.btReady:setPosition(self.m_btnInvite:getPosition()) self.gameBegin = true end
	self.result_jushi = msg.kCurCircle.." / "..msg.kCurMaxCircle
	gt.log(self.result_jushi)
	if self.m_atlasCount and msg.kCurCircle and msg.kCurMaxCircle then self.m_atlasCount:setString("局数: "..msg.kCurCircle.." / "..msg.kCurMaxCircle) end

end

function zjhScene:GameData(msg)

	gt.dumplog(msg)
	if msg.kSubId == 1 then 
		self:gameStart(msg)
	elseif msg.kSubId == 2 then -- 小结算
		if not self.action and not self.action1 and not self.action2 and self.compareidx == 0  then 
			self:gameEnd(msg)
		else
			self.min_result = msg
		end
	elseif msg.kSubId == gt.SUB_C_AUTO_ADDSCORE then
		self:switchAuto(msg.kValue)
	elseif msg.kSubId == gt.SUB_C_ADD_SCORE then
		self:onSubAddScore(msg)
	elseif msg.kSubId == gt.SUB_C_GIVE_UP then
		if self.onSubGiveUp then 
			self:onSubGiveUp(msg)
		end
	elseif msg.kSubId == gt.SUB_C_COMPARE_CARD then
		self:onSubCompareCard(msg)
	elseif msg.kSubId == gt.SUB_C_LOOK_CARD then
		self:onSubLookCard(msg)
	elseif msg.kSubId == gt.MSG_YINGSANZHANG_S_2_C_LUN then
		self:GameLayerRefreshlunshu(msg)
	elseif msg.kSubId == gt.SUB_S_AUTO_COMPARE_CARD then

		if not self.action and not self.action1 and not self.action2 and self.compareidx == 0  then 
			self:onSubCompareCard1(msg)
		else
			gt.log("auto________________")
			self.auto_compareCard = msg
		end
	end

end



function zjhScene:gameStart(msg)

	--if gt.backGround then return end

	log("gamestart____________")
	self.result_min:setVisible(false)
	self._node:getChildByName("TotalScore"):setVisible(true)
	self.begin_btn:setVisible(false)
	self.auto_compareCard = nil
	self.min_result = nil
	self._duanxian =   false
    self._duanxians = false
	self.genxinBtn = true
	self:OnResetView()
	self.gameBegin = true --- 游戏已经开始啦
	self:ActionText5(false)
	self.m_btnInvite:setVisible(false)
	self.nodeButtomButton:setVisible(false)
	self.fapai = true
	self.userBt = false
	self.msg = false
	log("btnfalse_____________________")
	self:CleanAllJettons()
	if self._resule_spr then self._resule_spr:removeFromParent() self._resule_spr = nil end 
	self.m_lCellScore = msg.kCellScore
	local buf = {}
	local  num = 0 
    for i = 1, GAME_PLAYER  do
    	if msg.kTotalScore and msg.kTotalScore[i] then 
   			self.m_UserHead[self:SwitchViewChairID(i-1)].score:setString(msg.kTotalScore[i])
   			self.Player[self:SwitchViewChairID(i-1)].score =  msg.kTotalScore[i]
   		end
    	gt.log("avcd.....",self:SwitchViewChairID(msg.kStatus[i]),msg.kStatus[i])
    	if msg.kStatus[i] == 1 then 
       		self.m_cbPlayStatus[self:SwitchViewChairID(i-1)] = 1 
       		self.nodePlayer[self:SwitchViewChairID(i-1)]:setVisible(true)
            buf[self:SwitchViewChairID(i-1)] = self.m_lCellScore 
            num = num + 1
        else
       		self.m_cbPlayStatus[self:SwitchViewChairID(i-1)] = 0
        end
    end

    gt.log("num.....",num)

    local m_wBankerUser = msg.kBankerUser
    self._kCurrentUser = msg.kCurrentUser
    self:SetBanker1(self:SwitchViewChairID(msg.kBankerUser))

    local _node = self._node:getChildByName("bg")
   
    _node:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()

    			 self:SetCellScore(self.m_lCellScore or 0) --.2
                 self:refreshTotalScore(msg.kMaxScore)
                 for k ,v in pairs(buf) do
                     self:SetUserTableScore(k,v)
                     self:PlaySound("sound_res/xiazhu.mp3")
                     if not self._duanxian then  
                    	 self:PlayerJetton(k,v,false,false)
                 	 end
                end

        end),cc.DelayTime:create(1),cc.CallFunc:create(function()

               

                    self.a = nil 
                    --发牌
                    local idx = 1
                    local time = 0
                    local indexs = 1 
                    --local tmp = num * 0.5
                    for i = 1, GAME_PLAYER do
                        for index = 1 , 3 do
                            local chair = math.mod(m_wBankerUser + i - 1,GAME_PLAYER) 
                          	gt.log("ccccccc.",chair,self:getTableId(chair),self.m_cbPlayStatus[self:getTableId(chair)],self.UsePos)
                            if self.m_cbPlayStatus[self:getTableId(chair)] == 1 then
                            	if i ~= idx then 
                            		time =time + 0.2
                            		indexs = indexs + 1
                            	end
                                idx = i
                				gt.log("chair..........",chair,self:SwitchViewChairID(chair))
                				
                                self:SendCard(self:SwitchViewChairID(chair),index,time,indexs,num)
                                if self:getTableId(chair) == MY_VIEWID then 
                            		self.guancha = false
                            	end
                            else
                            	if self:getTableId(chair) == MY_VIEWID then
                            		self.guancha = true
                            		self:ActionText3(true)
                            	end
                            end
                        end
                    end


        end),cc.DelayTime:create(num*0.2+0.2),cc.CallFunc:create(function()

        	if not self.guancha then 
	        	if self.genxinBtn then 
	        	
	            	if tonumber (yl.GAMEDATA[14]) == 1 then
	            		if not self._duanxian then  
		            		self:SetGameClock(self.UsePos,10,1)
	            			self.maixiao_btn:setVisible(true)
	            		end
	            	else
	            		self:SetGameClock(msg.kCurrentUser,TIME_USER_ADD_SCORE)
	            		self.maixiao_btn:setVisible(false)
	            		self:Updatabtn(msg.kCurrentUser == self.UsePos)
	            	end
	         	    
	         	end
	         	if self.msg then 
	         		self:SetGameClock(self.msg.kAddScorePos,TIME_USER_ADD_SCORE)
					self:Updatabtn(self.msg.kAddScorePos == self.UsePos)

					self.m_lCellScore = self.msg.kScore
					self:SetCellScore(self.m_lCellScore or 0) --.3
					self.msg = nil
	         	end
	         	if self.userBt then 
	         		log("user_________________")
					self:Updatabtn(self.userBt == self.UsePos)
					self.userBt = nil
				end
	         	self.fapai = false
	        end
        end)))

    self:PlaySound("sound_res/GAME_START.wav")

 

end





function zjhScene:onSubAddScore(msg)

    


    local MyChair = self:GetMeChairID()

  

    local addScoreType = msg.kAddScoreFlag


    local pos = msg.kCurrentUser


    local wAddScoreUser = msg.kAddScoreUser
   
    local lAddScoreCount = msg.kAddScoreCount
    local lCurrentTimes = msg.kCurrentTimes
    

    self.m_lCellScore = lCurrentTimes

    local viewid = self:SwitchViewChairID(wAddScoreUser)
    if viewid ~= MY_VIEWID then 
	    if addScoreType == 1 then
	        self:_playSound(viewid,"genzhu.mp3")
	    elseif addScoreType == 2 then
	        self:_playSound(viewid,"jiazhu.mp3")
	    end
    end
    self:SetUserTableScore(viewid, msg.kUserScoreTotal) -- 更新头像 旁边的 金币
    self:refreshTotalScore(msg.kTableScoreTotal) -- 众筹吗

    self:SetCellScore(lCurrentTimes)  -- 更新按钮上数字  .4
   

   
    if  msg.kAutoAdd == 1 then 
    	  self:PlayerJetton(viewid, lAddScoreCount,false,false)
    else
    if wAddScoreUser ~= MyChair then
        self:PlayerJetton(viewid, lAddScoreCount,false,false)
    end
	end

   if msg.kCompareState == 0 then ---104c

   		self.genxinBtn = false
   		
	    	self:SetGameClock(pos, TIME_USER_ADD_SCORE)
		 	if self.qipai or self.guancha then
		    else
			    if not self.is_auto then
			    --更新操作控件
			    	self.userBt = pos
				    if not self.fapai  then
				    	
				        self:Updatabtn(pos == MyChair)
				    end
			    end
		   
		    end
	   

   end


   


end


--
function zjhScene:onSubGiveUp(msg)

    local isfinal = msg.kIsFinal


  	

    local wGiveUpUser = msg.kGiveUpUser
    local viewid = self:SwitchViewChairID(wGiveUpUser)
    
   if viewid ~=MY_VIEWID then self:_playSound(viewid,"qipai.mp3") end

    self:SetUserGiveUp(viewid,true,self.iskanpai)
    
    self.wait = true

    self.m_cbPlayStatus[self:getTableId(wGiveUpUser)] = 0

   
    if wGiveUpUser == self:GetMeChairID() then

    	if not self.usergiveup then 
    		self:_playSound(MY_VIEWID,"qipai.mp3")
			self:removeActionHuo()
			self.nodeButtomButton:setVisible(false)
			if not self.is_auto then self:switchAuto(1,true) end
		end

        self:KillGameClock()
        log("false______4")
        self.qipai = true
        self:SetCompareCard(false, nil)
        self.m_ChipBG:setVisible(false)
      

    end

    self.action = true
    if isfinal == 1 then 
        self.m_bStartGame = false
        self.nodeButtomButton:setVisible(false)
    end

end

function zjhScene:onSubCompareCard1(msg)


   
  	self.action2 = true
    self.nodeButtomButton:setVisible(false)
    self.ComPare = {}
    self.is_auto = true
    self.auto_btn:setEnabled(false)
    self:switchAuto(1)
    self:KillGameClock()
    if  self.guancha  then  self.nodeButtomButton:setVisible(false) end

    local buf = msg.kInfo
    for i = 1 , #buf do
    	for x = 1 , 2 do
    		table.insert(self.ComPare,buf[i][x])
    	end
    end

    self.ComPareNum = 1
    
    self.text2:setVisible(true)
    self:_playSound(MY_VIEWID,"sound.mp3")
    self.text2:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
    self.text2:setVisible(false)
    self:ActionEndCompare()
        end)))
  

end

function zjhScene:ActionEndCompare()
          
             local bool = true
             local tmp 
             local a  =   math.random(self.ComPareNum,self.ComPareNum+1)
             if a == self.ComPareNum then 
                tmp = a + 1
                bool = true
             elseif a == self.ComPareNum+1 then
                bool = false
                tmp = a -1
            end
            
         self:CompareCard(self:SwitchViewChairID(self.ComPare[a]),self:SwitchViewChairID(self.ComPare[tmp]),nil,nil,bool, function(name) -- 2.5

         	gt.log("name...",name)
		    if name == "_end" then 
		        if bool then
		            self:setuserlose(self:SwitchViewChairID(self.ComPare[tmp]),function() -- 2.7s
		                
		                log("self.ComPareNum...............111",self.ComPareNum,#self.ComPare,tostring(self.action),tostring(self.action1),self.compareidx)
		                self.ComPareNum = self.ComPareNum +2
		                if self.ComPareNum +1 <= #self.ComPare then 
		                    self:ActionEndCompare() 
		                else 
		                	self.action2 = false

		                    if self.min_result and not self.action and not self.action1 and self.compareidx == 0  then self:gameEnd(self.min_result) self.min_result = nil end
		                    if self.max_result and not self.action and not self.action1 and self.compareidx == 0  then self:GameResult(self.max_result) self.max_result = nil end
		                end 
		                
		            end)
		             
		        else
		            self:setuserlose(self:SwitchViewChairID(self.ComPare[a]),function()
		               
		               log("self.ComPareNum...............222",self.ComPareNum,#self.ComPare)
		               self.ComPareNum = self.ComPareNum +2
		                if self.ComPareNum +1 <= #self.ComPare then
		                    self:ActionEndCompare() 
		                else  
		                    self.action2 = false
		                    if self.min_result and not self.action and not self.action1 and self.compareidx == 0  then self:gameEnd(self.min_result) self.min_result = nil end
		                    if self.max_result and not self.action and not self.action1 and self.compareidx == 0  then self:GameResult(self.max_result) self.max_result = nil end
		                end 
                
           			 end)
               
       	  end
       

	    elseif name == "shandian" then
	         self:PlaySound("sound_res/bipaiyin.mp3")
	    end
    end,true) -- true

    

end


function zjhScene:onSubCompareCard(msg)

 --    //服务器端发送用户比牌
	-- Lint                                 kIsFinal;                                       //比牌后是否结束比赛
	-- Lint								 kCurrentUser;						       //当前用户
	-- Lint								 kCompareUser[2];					   //比牌用户
	-- Lint								 kLostUser;							       //输牌用户

    local isFlush = msg.kIsFinal
    log("isFlush................",isFlush)
   

    self.compareidx = self.compareidx + 1
    


    local pos  = msg.kCurrentUser
    self.m_wCurrentUser = pos
    local wCompareUser = msg.kCompareUser
    


    self.m_wLostUser = msg.kLostUser
    
    self.m_wWinnerUser = wCompareUser[1] + wCompareUser[2] - self.m_wLostUser

    if self:SwitchViewChairID(wCompareUser[1]) ~= MY_VIEWID then self:_playSound(self:SwitchViewChairID(wCompareUser[1]),"beginCompare.mp3") end

    self.m_cbPlayStatus[self:getTableId(self.m_wLostUser)] = 0
	self._node:getChildByName("Panel_hui"):setVisible(true)
    if (wCompareUser[1]== self:GetMeChairID())then  self:SetCompareCard(false) end
  
   
    


	self.genxinBtn = true

    if  self.guancha  then  self.nodeButtomButton:setVisible(false) end
    if  self.m_wLostUser == self:GetMeChairID() then
        self.nodeButtomButton:setVisible(false)
        self.qipai = true
    end
  	self:Updatabtn(false)
  	gt.log("a_______________")
    self:CompareCard(self:SwitchViewChairID(wCompareUser[1]),self:SwitchViewChairID(wCompareUser[2]),nil,nil,wCompareUser[1] == self.m_wWinnerUser, function(name)

        	log("name_______________",name)
	        if name == "shandian" then
	           self:PlaySound("sound_res/bipaiyin.mp3")
	        elseif name == "_end" then
	           		
	           		gt.log("end_________________")
	                self:OnFlushCardFinish(isFlush)
	           
	        end
        end)
   
    if isFlush == 1 then 
    
        self.m_bStartGame = false
        self.nodeButtomButton:setVisible(false)

    end
  
end
-- 3080

function zjhScene:onSubLookCard(msg)

    local wLookCardUser = msg.kLookCardUser
    local viewid = self:SwitchViewChairID(wLookCardUser)
    if viewid ~= MY_VIEWID then self:_playSound(viewid,"kanpai.mp3") end
    self:SetLookCard(viewid,true)
    if wLookCardUser == self:GetMeChairID() then
     	
        self:SetUserCard(viewid, msg.kCardData)

        self:SetUserCardType(MY_VIEWID,msg.kCardType)
    end

end





function zjhScene:giveUp(msg)
	
	
end

function zjhScene:showViewResult(m,MaxResult,cbCardData)
	self.result_min:setVisible(true)
	self.playerInfo:setVisible(false)
	self.btReady:setVisible(false)
	self.result_min:getChildByName("T1"):setString("房间号："..(self.data.kDeskId or "000000"))
	self.result_min:getChildByName("T2"):setString(os.date("%m-%d-%H:%M:%S", os.time()))

	self.result_t3:setString("请点击\"准备下一局\"，否则下一局您只能观战")

	gt.setOnViewClickedListener(self.result_min:getChildByName("Button_222"),function()

			 local fileName = "sharewx.png"

 
	       cc.utils:captureScreen(function(succeed, outputFile)  
	           if succeed then  
	             local winSize = cc.Director:getInstance():getWinSize()  
	               Utils.shareImageToWX( outputFile, 849, 450, 32 )
	           else  
	              
	           end  
	       end, fileName)  

		end,0.5)


	gt.setOnViewClickedListener(self.result_min:getChildByName("Button_333"),function()
			if not MaxResult and not self.result then 
				self:onStartGame()
			else
				self:disPlaygameResult()
			end
			self.result_min:setVisible(false)
			for i = 1 , gt.GAME_PLAYER do
			self.result_min:getChildByName("player"..i):getChildByName("quanquan_4"):stopAllActions() end
		end)

	for i = 1 , gt.GAME_PLAYER do

		self.result_min:getChildByName("player"..i):setVisible(false)
		self.result_min:getChildByName("player"..i):getChildByName("ready_108"):setVisible(false)
		self.result_min:getChildByName("player"..i):getChildByName("ready_108"):setLocalZOrder(4)
		self.result_min:getChildByName("player"..i):getChildByName("quanquan_4"):setVisible(false)
		self.result_min:getChildByName("player"..i):getChildByName("quanquan_4"):setLocalZOrder(2)
		self.result_min:getChildByName("player"..i):getChildByName("quanquan_4"):stopAllActions()
		self.result_min:getChildByName("player"..i):getChildByName("playerWin"):setVisible(false)
		self.result_min:getChildByName("player"..i):getChildByName("playerWin"):setLocalZOrder(3)
		self.result_min:getChildByName("player"..i):getChildByName("name"):setString("")
		self.result_min:getChildByName("player"..i):getChildByName("ID"):setString("")
		self.result_min:getChildByName("player"..i):getChildByName("score"):setString("0")
		self.result_min:getChildByName("player"..i):getChildByName("score"):setColor(cc.c3b(255,255,255))
		self.result_min:getChildByName("player"..i):removeChildByName("r_icon_")

		for j = 1, 3 do
			self.result_min:getChildByName("player"..i):getChildByName("card"..j):setVisible(false)
			self.result_min:getChildByName("player"..i):getChildByName("card"..j):setScale(0.3)
		end
	end

	gt.dump(m)

	for k , y in pairs(self.player_viewid) do

		gt.log("k...............",k)
		for i = 1 , gt.GAME_PLAYER do 

			if self:getTableId(i-1) == k then 
				self.result_min:getChildByName("player"..i):setVisible(true)
				self.result_min:getChildByName("player"..i):getChildByName("name"):setString(m.kNikes[i])
				self.result_min:getChildByName("player"..i):getChildByName("ID"):setString(m.kUserIds[i])
				
				if tonumber(y) >= 0 then 
					self.result_min:getChildByName("player"..i):getChildByName("score"):setString("+"..y)
					self.result_min:getChildByName("player"..i):getChildByName("score"):setColor(cc.c3b(197, 75, 32))

					if k == MY_VIEWID then 
						self.result_min:getChildByName("Image_4"):loadTexture("ddz/r_shegnli.png")
					end
					if tonumber(y) ~= 0 then 
						self.result_min:getChildByName("player"..i):getChildByName("playerWin"):setVisible(true)
						self.result_min:getChildByName("player"..i):getChildByName("quanquan_4"):runAction(cc.RepeatForever:create(cc.RotateBy:create(0.6,50)))
						self.result_min:getChildByName("player"..i):getChildByName("quanquan_4"):setVisible(true)
					end
					
				else
					if k == MY_VIEWID then
						self.result_min:getChildByName("Image_4"):loadTexture("ddz/r_shibai.png")
					end
					self.result_min:getChildByName("player"..i):getChildByName("score"):setColor(cc.c3b(4,82,137))
					self.result_min:getChildByName("player"..i):getChildByName("score"):setString(y)
				end

				for j = 1, 3 do 
					self.result_min:getChildByName("player"..i):getChildByName("card"..j):setVisible(true)
					local strCard = "poker/"..gt.tonumber(cbCardData[i][j])..".png"
					self.result_min:getChildByName("player"..i):getChildByName("card"..j):loadTexture(strCard)
				end
				break
			end

		end

	

	end





	for i = 1 , gt.GAME_PLAYER do
		local node = self.result_min:getChildByName("player"..i)
		if node:isVisible() then 
	        local ispath = gt.imageNamePath(m.kHeadUrls[i])
	        local icon = node:getChildByName("icon")
	        if ispath then
	           gt.log("ispath..........",ispath)
	           local _node = display.newSprite("addz_new/touxiang_moren.png")
	           local image = gt.clippingImage(ispath,_node,false)
	           image:setLocalZOrder(1)
	           image:setName("r_icon_")
	           node:addChild(image)
	           icon:setVisible(false)
	           image:setPosition(icon:getPositionX(),icon:getPositionY())
	        else

	  			if m.kHeadUrls[i] ~= "" and  type(m.kHeadUrls[i]) == "string" and string.len(m.kHeadUrls[i]) >10 and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self then
	  				gt.log("down____________")
	  				local function callback(args)
	  					if args.done then 
	  						local _node = display.newSprite("addz_new/touxiang_moren.png")
							local head = gt.clippingImage(args.image,_node,false)
							if gt.addNode(node,head) then 
							--node:addChild(head)
								head:setLocalZOrder(1)
								icon:setVisible(false)
								head:setName("r_icon_")
								head:setPosition(icon:getPositionX(),icon:getPositionY())
							end
	  					end
	  				end
	  				gt.downloadImage(m.kHeadUrls[i], callback)
	  			end
	        end   
        end      
	end



end

function zjhScene:gameEnd(msg)
	



	--if gt.backGround then return end
	gt.soundEngine:stopMusic()
	self:KillGameClock()
    -- self.m_bStartGame = false
   	self._node:getChildByName("bg"):stopAllActions()
    self:switchReady()
    self._node:getChildByName("TotalScore"):setVisible(false)
 	-- ccccc

    --清理界面
    for i = 1 ,GAME_PLAYER do
   		self.m_UserHead[self:SwitchViewChairID(i-1)].score:setString(msg.kTotalScore[i])
   		self.Player[self:SwitchViewChairID(i-1)].score =  msg.kTotalScore[i]
   		
        self.comPokeLose[i]:setVisible(false)
        self.m_GiveUp[i]:setVisible(false)
        self.hui_bg[i]:setVisible(false)
        self.m_LookCard[i]:setVisible(false)
        self:actionSign(i,false)
      
        self:actionliuchang(i,false)
     end

    self:removeActionHuo()
    self:StopCompareCard()
    self:SetCompareCard(false)
    self.m_ChipBG:setVisible(false)
    self.nodeButtomButton:setVisible(false)
  
  
    local MaxResult = false
    if msg.kFinalDw == 1 then
        MaxResult   = true
    end

    --用户扑克
    local cbCardData = {}
    for i = 1, GAME_PLAYER do

        cbCardData[i] = {}
        local data = msg["kCardData"..i-1]
        for j = 1, 3 do
            cbCardData[i][j] = data[j] -- 用户扑克
            
        end
    end

   	
   	gt.dumplog("userpos.......",self.UsePos)

    local bool1 = true
    local bool2 = true
    local win_id = 21
    local _palysoundWin = true
    for i =1 , GAME_PLAYER do
            local cardIndex = {}
            local bool 

            for k = 1 , 3 do
                cardIndex[k] = cbCardData[i][k]
            end

            local viewid = self:SwitchViewChairID(i-1)
         
            self:SetUserCard(viewid, cardIndex)

            if msg.kGameScore[i] < 0 then 
                self:SetUserCardType(viewid, msg.kCardType[i])
            else
                self:SetUserCardType1(viewid, msg.kCardType[i])
            end
           
    end
    

	--  移动筹码
    for j = 1, GAME_PLAYER do
        local viewid = self:SwitchViewChairID(j-1)
        if msg.kGameScore[j] ~= 0 then
            if msg.kGameScore[j] > 0 then
                win_id = viewid
                self:SetUserTableScore1(viewid,msg.kGameScore[j])
              
                if viewid == MY_VIEWID then
                    log("播放胜利音乐")
                    self:my_win(true)
                    self:PlaySound("sound_res/GAME_WIN.wav")
                   	_palysoundWin = true
                else
                    _palysoundWin = false
                end
            else
                self:SetUserTableScore1(viewid,msg.kGameScore[j])
            end

          	self.nodePlayer[viewid]:setVisible(true)
        else
            self:SetUserTableScore1(viewid)
        end
        if msg.kGiveUp[j] == 1 then self.qi_pai[viewid]:setVisible(true) end
    end





    local node = self._node:getChildByName("TotalScore")
    self.addWinScoreAction = true
    node:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
    	self.addWinScoreAction = false
    	if not self._duanxians  then 
        	self:WinTheChip(win_id,MaxResult,_palysoundWin,cbCardData,msg) -- 飞金币	
    	end
        end)))

    if self.qipai or self.guancha then -- 自己
        self:SetUserCardType(MY_VIEWID)
    end

    if tonumber(yl.GAMEDATA[17]) == 1 and tonumber(yl.GAMEDATA[18]) == 1 then 
		--self:showViewResult(msg)
		--self.btReady:setVisible(false)
	else
    	self.btReady:setVisible(not MaxResult)
    	local m = {}
    	m["kCurCircle"] = self.__clock or 15
    	self:clock_time(m)
	end
 
    self.m_cbPlayStatus = {0, 0, 0, 0, 0}
   	

end
function zjhScene:beginBtn(msg)
	
end
function zjhScene:autoScore(msg)
	
	
end

function zjhScene:GameLayerRefreshlunshu(msg)
	
	local num = msg and msg.kValue or 0
	if num == 1 then self.btCompare:setEnabled(false) end
	
	if tonumber(yl.GAMEDATA[7]) == 0 then yl.GAMEDATA[7] = -1 end

	if num > tonumber(yl.GAMEDATA[7]) then
		self.menpai = false
		if self.iskanpai then 
			self.btLookCard:setVisible(false)
		else
			self.btLookCard:setVisible(true)
		end
		self.btLookCard:setEnabled(true)
		if num > 1 then 
			if not self.is_auto then 
				self.btCompare:setEnabled(true)
			end
		end
	else
		self.btLookCard:setEnabled(false)
		if num > 1 then 
			self.btCompare:setEnabled(false)
		end
		self.menpai = true
	end

	
	

	if num and yl.GAMEDATA[5] then
		log("luns___________________",num)
		self.r_time = 0
		self._lunshu = num
		self.lunshu:setString("轮数："..num.." / "..yl.GAMEDATA[5])
	end
		
end

function zjhScene:off_line(args)

	gt.log("off___________________")
	if args and args.kPos then
		self.head_hui[self:getTableId(args.kPos)]:setVisible(0 == args.kFlag)
	end
end

function zjhScene:updata_result(m)

	if self.result_min:isVisible() then 

		if m.kNum == 2 then 
			local time = self.__clock or 8
			self.result_t3:setString("游戏即将开始......"..time)
			if self.__times then _scheduler:unscheduleScriptEntry(self.__times) self.__times = nil end
			self.__times = _scheduler:scheduleScriptFunc(function()
			if time == 0 then if self.__times then _scheduler:unscheduleScriptEntry(self.__times) self.__times = nil end end
			self.result_t3:setString("游戏即将开始......"..time)
			time = time - 1 
			end,1,false)	
		end

		self.result_min:getChildByName("player"..m.kPos+1):getChildByName("ready_108"):setVisible(true)


	end

end

function zjhScene:RcvReady(args) -- csw 

	gt.dumplog(args)
	gt.log("ready_________________",args.kPos,self.UsePos)
	if args.kPos then 
		if args.kPos == self.UsePos then 
			self.btReady:setVisible(false) 
			if  self.___jushu ~= 0 then 
				self:OnResetView() 
			end
			self.r_time = 0
			self.result_min:setVisible(false)
		else
			self:updata_result(args)
		end
		if  self.btReady:isVisible() and  self.gameBegin then 
			if self:getTableId(args.kPos) == MY_VIEWID then self.m_flagReady[MY_VIEWID]:setVisible(true) end
			self._ready[self:getTableId(args.kPos)] = true
		else
			
			self.m_flagReady[self:getTableId(args.kPos)]:setVisible(true) 
		end	
		--self.m_flagReady[self:getTableId(args.kPos)]:setPosition(self._node:getChildByName("ready"..self:getTableId(args.kPos)):getPosition())
    end
	

end

function zjhScene:SetCompareCard(bchoose,status)
	self.bCompareChoose = bchoose



   

     		if not self.max_chip then 
    			self.btAddScore:setEnabled(not bchoose)
    		end
			self.btFollow:setEnabled(not bchoose)
			self.btCompare:setEnabled(not bchoose)

    		self.quxiao:setVisible(bchoose)
    		self.auto_btn:setVisible(not bchoose)
    		self.text1:setVisible(bchoose)

    	


    for i = 1, GAME_PLAYER do
    	if i ~= MY_VIEWID then
			if bchoose and status and status[i] then
		
			 	self.m_flagArrow[i]:setVisible(true)
			 	local jian_node = self.m_flagArrow[i]:getChildByName("jiantou")
			 	jian_node:setPosition(cc.p(self.jiantouposx[i],self.jiantouposy[i]))
			 	--node
			 	if GAME_PLAYER == 8 then 
				 	if i == 3 or i == 4 then
						jian_node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(-7,0)),cc.MoveBy:create(0.2,cc.p(7,0)))))
					elseif i == 6 or i == 7 or i == 8 or i ==1 or i == 2 then
						jian_node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(7,0)),cc.MoveBy:create(0.2,cc.p(-7,0)))))
					end
				else
					if i == 1 or i == 2 then
						jian_node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(-7,0)),cc.MoveBy:create(0.2,cc.p(7,0)))))
					elseif i == 4 or i == 5 then
						jian_node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(7,0)),cc.MoveBy:create(0.2,cc.p(-7,0)))))
					end
				end
 
			else
				self.m_flagArrow[i]:stopAllActions()
			 	self.m_flagArrow[i]:setVisible(false)
			end 
        end
    end
end


function zjhScene:onLookCard()
	local MyChair = self:GetMeChairID()
    if not MyChair or MyChair == gt.INVALID_CHAIR then
        return
    end
   	
   	self.iskanpai = true
    self:SetCellScore(self.m_lCellScore) --.5
    
    self.btLookCard:setVisible(false)
    local m = {}
    m.kMId = gt.MSG_C_2_S_POKER_GAME_MESSAGE

	m.kSubId = gt.SUB_S_LOOK_CARD
    m.kValue = MyChair
    gt.dumplog(m)
    gt.socketClient:sendMessage(m)

end

function zjhScene:disBeginBtn(pos,name)

	log("pos...................",pos)
	if not pos then return end
	if pos == self.UsePos then 
		self.begin_btn:setVisible(true)
	elseif pos ~= 21  then
		log("111111")
		self:ActionText5(false)
		self:ActionText5(true)
		self:ActionText7(false)
		log("pos.............",pos)
		log(self.Player[self:getTableId(pos)].name)
		local str = "等待 "..(name and name or " ")
		log("str...",str)
		self.text5:getChildByName("name"):setString(str)
		
	elseif pos == 21 then 
		log("222222")
		self.begin_btn:setVisible(false)
		self:ActionText5(false)
	end


end

function zjhScene:onBeginGame()

	local msgToSend = {}
	msgToSend.kMId = gt.SUB_S_GAME_START
	msgToSend.kPos = self.UsePos
	gt.dumplog(msgToSend)
	gt.socketClient:sendMessage(msgToSend)

end

function zjhScene:onStartGame()

	local msgToSend = {}
	msgToSend.kMId = gt.CG_READY
	msgToSend.kPos = self.UsePos

	gt.dumplog(msgToSend)
	gt.socketClient:sendMessage(msgToSend)
	for i ,v in pairs(self._ready) do
		if v then self.m_flagReady[i]:setVisible(true) end
	end
	self.btReady:setVisible(false)
	log("==================0")
	self.r_time = 0
end

function zjhScene:onGiveUp()



	local function fun()



		local m = {}
		m.kMId = gt.MSG_C_2_S_POKER_GAME_MESSAGE
		m.kSubId = gt.SUB_S_GIVE_UP
		m.kPos = self.UsePos
		gt.dumplog(m)
		gt.socketClient:sendMessage(m)
		

	end

	self._lunshu = self._lunshu and self._lunshu or 0
	
	if self._lunshu >= 5 then 
		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "是否确认弃牌？", fun, nil)
	else
		fun()
	end

end

function zjhScene:getPlayingNum()
    local num = 0
    for i = 1, GAME_PLAYER do
        if self.m_cbPlayStatus[i] == 1 then
            num = num + 1
        end
    end
    return num
end


--自动比牌
function zjhScene:onAutoCompareCard()

    local MyChair = self:GetMeChairID() + 1

    for i = 0 , GAME_PLAYER-1 do
      
        if self.m_cbPlayStatus[self:getTableId(i)] == 1 and  i ~= self.UsePos then
           
            local m = {}
            m.kMId = gt.MSG_C_2_S_POKER_GAME_MESSAGE
			m.kSubId = gt.SUB_S_COMPARE_CARD
            m.kValue = i
            gt.dumplog(m)
            gt.socketClient:sendMessage(m)
            break
        end
    end
end


--比牌操作
function zjhScene:onCompareCard()

    local playerCount = self:getPlayingNum() 

    gt.log("playerCount",playerCount)
    if playerCount < 2 then
        return
    end
    

    local bAutoCompare = (self:getPlayingNum() == 2)
    
   

    if bAutoCompare then
        
        self:KillGameClock() 
        local score = self.m_lCellScore * (tonumber(yl.GAMEDATA[11]) and  tonumber(yl.GAMEDATA[11])+1 or 1)  --addnew
        log("score...............bipai",score)
        self:PlayerJetton(MY_VIEWID, score,false,true)
        self:onSendAddScore(score, true, 0)--发送下注消息
      
        self:onAutoCompareCard()
    else
        local compareStatus={false,false,false,false,false}
        for i = 1 ,GAME_PLAYER do
            if self.m_cbPlayStatus[i] == 1 and i ~= MY_VIEWID then
                compareStatus[i] = true
            end
        end
        self:SetCompareCard(true,compareStatus)
       
      
    end
end


function zjhScene:autoAddScore(bool)

    local num = bool and 0 or 1 
  
    local m = {}
    m.kMId = gt.MSG_C_2_S_POKER_GAME_MESSAGE
	m.kSubId = gt.SUB_S_AUTO_ADDSCORE  
	m.kValue = num
    log("send__________",num)
    gt.dumplog(m)
   	gt.socketClient:sendMessage(m)

end

-- 发送下注
function zjhScene:addScore(num,_type)



    self:KillGameClock()
    --清理界面
    self.m_ChipBG:setVisible(false)

    self:PlayerJetton(MY_VIEWID, num,false,false)
    
    --发送数据 -- 比牌  true

    self:onSendAddScore(num, false,_type)


end

--发送加注消息
function zjhScene:onSendAddScore(score, bCompareCard,_type)
    
    if bCompareCard then 
        self:_playSound(MY_VIEWID,"bipai.mp3")
    end

  

    local m = {}
    m.kMId = gt.SUB_S_ADD_SCORE
	
    m.kScore = score
	m.kState = bCompareCard and 1 or 0
	m.kAddScore = _type

    self.iscaozuo = true
    self.shuohua = false
    self:switch_look_card_btn()
   	gt.socketClient:sendMessage(m)
end

function zjhScene:removeAllPlayer()
	for i = 1, GAME_PLAYER do
		if (i-1) ~= self:GetMeChairID() then 
			local m = {kPos = (i-1)} self:removePlayer(m)
		end
	end
end

function zjhScene:off_line_data(msg)
		gt.dumplog(msg)

		--self:OnResetView()
		self.iskanpai = false
		for i = 1 ,GAME_PLAYER do
			self._mai[i]:setVisible(false)
			self.nodePlayer[i]:setPosition(self.PX[i],self.PY[i]) -- cde
			self:findNodeByName("clock",self.nodePlayer[i]):setVisible(false)
			--self.nodePlayer[i]:setVisible(true)
			-- self._voice[i]:setVisible(false)
			-- self._voice_node[i]:setVisible(false)
			self.sign[i]:setVisible(false)
			self.liuchang_sign[i]:setVisible(false)
			self.hui_bg[i]:setVisible(false)
			self.comPokeLose[i]:setVisible(false)
			self.m_UserHead[i].quanquan:stopAllActions()
			self.m_UserHead[i].quanquan:setVisible(false)
			self.m_UserHead[i].hg:setVisible(false)
			self.nodePlayer[i]:getChildByName("sp_8"):setVisible(false)
			if GAME_PLAYER == 5 then 
			if i == 2 or i == 4 then self.userCard[i].resultScore:setPosition(self._node:getChildByName("Node_"..i):getPosition()) end
			end
			self.userCard[i].resultScore:setVisible(false)
			self:SetLookCard(i, false)
			self:SetUserCardType(i)
			self:SetUserTableScore(i, 0)
			self:SetUserGiveUp(i,false)
			self:SetUserCard(i,nil)
	        self:clearCard(i)
	        self.qi_pai[i]:setVisible(false)
			local nodeCard = self.userCard[i]
			nodeCard.area:setVisible(false)
		end




		for i = 1 , #self.tmpCard do
			if self.tmpCard[i] then
				self.tmpCard[i]:removeFromParent()
				self.tmpCard[i] = nil
			end
		end
		self.tmpCard = {}

		self:my_win(false)
		self:my_compare_card_win(false)
		if self._resule_spr then self._resule_spr:removeFromParent() self._resule_spr = nil end 



		self.result_min:setVisible(false)
		self.maixiao_btn:setVisible(false)
		self.maida_btn:setVisible(false)
		self._node:getChildByName("TotalScore"):setVisible(true)
	    log("game status is play!")
	    self.m_btnInvite:setVisible(false)
        self.gameBegin = true
        for i = 1 , GAME_PLAYER do

        	self.m_flagReady[i]:setVisible(false)
            local id = self:SwitchViewChairID(i-1)
            gt.log("view_id",id,msg.kPlayStatus[i])
            self.m_cbPlayStatus[id] = msg.kPlayStatus[i]
            if id == MY_VIEWID  then 
                if msg.kUserStatus[i] == 1 or msg.kUserStatus[i] == 2 then-- 1 弃牌 2 比牌输
                    self.qipai = true
                    self.hui_bg[MY_VIEWID]:setVisible(true)
                end
            end 
        end

   

        self._duanxian =   self.fapai 
        self._duanxians = self.addWinScoreAction

        self:SetBanker(self:SwitchViewChairID(msg.kBankerUser))

        self:addTableChip(msg.kTableScoreCount) -- 各个玩家桌上筹码
         
        self:SetUserCardType(MY_VIEWID,msg.kCardType)

        self.action = false 
    	self.action1= false 
    	self.compareidx = 0
    	self.action2 = false 
		
		-- -- self._node:getChildByName("bg"):stopAllActions() -- 断线重连 停止 游戏开始动画  游戏开始动画 导致 买大买小 按钮 出现
		self.min_result = nil -- 断线 重连 回来 不显示 结算  结算导致断线重连筹码 被 回收
		
		-- if self.fapai then 
		-- 	self._node:getChildByName("bg"):stopAllActions()
		-- end

        local MyChair = self:GetMeChairID() + 1

      
        --参数设置
        local guancha =  (msg.kDynamicJoin == 1) -- 动态加入

        self.guancha = guancha



        if guancha then 
        	self.m_cbPlayStatus[MY_VIEWID] = 0	
        	self.btReady:setVisible(false)
            self:ActionText3(true)
           
        else
        	
           --self._gameView.moshi_bg:setVisible(false)
        end



        self:refreshTotalScore(msg.kTableTotalScore) -- 桌上总筹码

      
        self.is_auto = msg.kAutoScore == 0 and true or false
        


        self:switchAuto(1)

        self.m_lMaxCellScore =msg.kMaxCellScore--  -- 没用
        self.m_lCellScore = msg.kCellScore  --- 桌子上底注

        self._difen = self.m_lCellScore

        if self:getMax_chip() then self.baoji = true self.max_chip = true log("暴击————————————————————————") self.btAddScore:setEnabled(false) else  self.baoji = false self.max_chip = false self.btAddScore:setEnabled(true) end

     

        self.m_lAllTableScore = 0


      
        local qipai = false
        for i = 1, GAME_PLAYER do
            --视图位置
            local viewid = self:SwitchViewChairID(i-1)
            --手牌显示
            if  msg.kPlayStatus[i] == 1 then
                self.userCard[viewid].area:setVisible(true)
              	
                if i == MyChair  and msg.kMingZhu[MyChair] == 1 then

                    local cardIndex = {}
                    
                    self.iskanpai = true
                    self.btLookCard:setVisible(false) -- 隐藏看牌按钮
                    self:SetUserCard(MY_VIEWID,msg.kHandCardData)
                    
                else
                    
                    self:SetUserCard(viewid,{0,0,0})
                end

               

            else
                 self.userCard[viewid].area:setVisible(false)
                 self:SetUserCard(viewid,nil)
            end
            --看牌显示
            self:SetLookCard(viewid,(msg.kMingZhu[i]~=0))
            self:SetUserTableScore(viewid, msg.kTableScore[i])
            self.m_lAllTableScore = self.m_lAllTableScore + msg.kTableScore[i]

            
          
           self:display_qipao(viewid,msg.kUserStatus[i])


            --是否弃牌
            if  msg.kPlayStatus[i] ~= 1 and msg.kTableScore[i] > 0 then
                self.userCard[viewid].area:setVisible(true)
                self:SetUserGiveUp(viewid, true)
                if viewid == MY_VIEWID then
                    qipai = true
                end
                
            end
        end
        self:SetCellScore(self.m_lCellScore) -- 看牌更新桌上按钮 .6
        --总下注
        self:SetAllTableScore(self.m_lAllTableScore)

        if msg.kGameStatus == 1 then 
        	--if msg.kIsBuy == 0 then  -- 没点过按钮
        		self.maixiao_btn:setVisible(msg.kIsBuy == 0)
        	if msg.kBuyPos ~= 21 then 
	   			for i = 1, GAME_PLAYER do
	   				self._mai[i]:setVisible(false)
	   			end
	   			
	   		else
	   			for i = 1, GAME_PLAYER do 
	   				local id = self:getTableId(i-1)
	   				--if id <= 5 or id == GAME_PLAYER then 
	   				if self:l_or_r(id) == "l" then
	   					if msg.kUserBuyStatus[i] ~= 255 then 
		   					self._mai[id]:loadTexture("zy_zjh/l".."xiao"..msg.kUserBuyStatus[i]..".png")
		   					self._mai[id]:setVisible(true)
		   				else
		   					self._mai[id]:setVisible(false)
		   				end
	   				else
	   					if msg.kUserBuyStatus[i] ~= 255 then 
	   					self._mai[id]:loadTexture("zy_zjh/r".."xiao"..msg.kUserBuyStatus[i]..".png")
		   				self._mai[id]:setVisible(true)
		   				else
		   					self._mai[id]:setVisible(false)
		   				end
	   				end
	   			end
	   		end
	   		if not guancha  then 
	   		self:SetGameClock(self.UsePos, msg.kRemain_time,1)
	   		end
        elseif msg.kGameStatus == 2 then
        	--if msg.kIsBuy == 0 then  --没点过按钮
        	self.maida_btn:setVisible(msg.kIsBuy == 0)
       
        	if msg.kBuyPos ~= 21 then 
	   			for i = 1, GAME_PLAYER do
	   				self._mai[i]:setVisible(false)
	   			end

			
	   		else
	   			for i = 1, GAME_PLAYER do 
	   				local id = self:getTableId(i-1)
	   				if self:l_or_r(id) == "l" then
	   					if msg.kUserBuyStatus[i] ~= 255 then 
		   				self._mai[id]:loadTexture("zy_zjh/l".."da"..msg.kUserBuyStatus[i]..".png")
		   				self._mai[id]:setVisible(true)
		   				else
		   					self._mai[id]:setVisible(false)
		   				end
	   				else
	   					if msg.kUserBuyStatus[i] ~= 255 then 
	   					self._mai[id]:loadTexture("zy_zjh/r".."da"..msg.kUserBuyStatus[i]..".png")
		   				self._mai[id]:setVisible(true)
		   				else
		   					self._mai[id]:setVisible(false)
		   				end
	   				end
	   			end
	   		end
	   		if not guancha  then 
	   		self:SetGameClock(self.UsePos, msg.kRemain_time,1)
	   		end
        else
	        --控件信息
	        if self:GetMeChairID() == msg.kCurrentUser then
	            self:Updatabtn(not self.is_auto)
	            self.duanxian = true
	        else
	            self:Updatabtn(false)
	        end
	   	      --设置时间
        	self:SetGameClock(msg.kCurrentUser, msg.kRemain_time)
   		end

   	
   		if tonumber (yl.GAMEDATA[14]) == 1 then
   		local node = self:findNodeByName("mai_text")
		if msg.kBuyPos ~= 21 then 
   			for i = 1, GAME_PLAYER do
   				self._mai[i]:setVisible(false)
   			end
   			node:setVisible(true)
			self:findNodeByName("Text_10", node):setString((msg.kBuyType == 0 and "买小x" or "买大x")..msg.kBuyScore..":"..msg.kBuyNike)
   		else
   			node:setVisible(true)
   			self:findNodeByName("Text_10", node):setString("默认买大")
   			-- for i = 1, 5 do 
   			-- 	local id = self:getTableId(i)
   			-- 	if id <=3 then 
	   		-- 		self._mai[id]:loadTexture("zy_zjh/l".."xiao"..msg.kScore..".png")
	   		-- 		self._mai[id]:setVisible(true)
   			-- 	else
   			-- 		self._mai[id]:loadTexture("zy_zjh/r".."xiao"..msg.kScore..".png")
	   		-- 		self._mai[id]:setVisible(true)
   			-- 	end
   			-- end
   		end

       	end
      	



        if self.is_auto then 
        	self.btGiveUp:setEnabled(false)
			self.btCompare:setEnabled(false)
			self.btAddScore:setEnabled(false)
			self.btFollow:setEnabled(false)
        end

        if guancha or qipai or self.qipai or msg.kGameStatus ~= 0 then
            log("false_________________________")
            self.nodeButtomButton:setVisible(false)
        else
        	self.nodeButtomButton:setVisible(true)
        end

       -- if dataBuffer:readbool() then self:send() end -- 少一个 请求 结算 消息的 字段
       self.player_viewid = {}
       if guancha then  self.maixiao_btn:setVisible(false)
			self.maida_btn:setVisible(false) end

	   self:ActionText5(false)
end



return zjhScene




