local base = require("client.game.poker.baseGame")

local nnScene = class("nnScene",base)

local BT_DISSOLVE 				= 1
local BT_LEAVE 				= 28
local BT_VOICE              = 27
local BT_CHAT 				= 2
local BT_GIVEUP				= 3
local BT_READY				= 4
local BT_NEXT 				= 29
local BT_CALLBANKER			= 30
local BT_LOOKCARD			= 5
local BT_FOLLOW				= 6
local BT_ADDSCORE			= 7
local BT_CHIP				= 8
local BT_CHIP_1				= 9
local BT_CHIP_2				= 10
local BT_CHIP_3				= 11
local BT_COMPARE 			= 12
local BT_CARDTYPE			= 13
local BT_SETTING				= 14
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

local GAME_PLAYER = 6 
local MY_VIEWID = 4

nnScene.ZOrder = {
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

	ROUND_REPORT				= 66, -- 单局结算界面显示在总结算界面之上
	DECISION_NEW                = 67,
	MOON_FREE_CARD              = 80, -- 中秋节免费送房卡活动弹框
}

local ptChat = {{cc.p(740, 680), cc.p(285, 595), cc.p(990, 595), cc.p(195, 440), cc.p(1080, 440), cc.p(185, 245)},
	{cc.p(566, 590), cc.p(376, 573), cc.p(756, 573), cc.p(180, 556), cc.p(955, 556), cc.p(10, 418), cc.p(1266, 408), cc.p(10, 260), cc.p(1266, 250), cc.p(25, 77)},
}
local ptCard = {{cc.p(640, 526), cc.p(388, 505), cc.p(890, 505), cc.p(303, 355), cc.p(974, 354), cc.p(640, 100)},
	{cc.p(640, 587), cc.p(450, 573), cc.p(830, 573), cc.p(255, 556), cc.p(1025, 556), cc.p(80, 417), cc.p(1200, 417), cc.p(80, 259), cc.p(1200, 259), cc.p(640, 100)},
}
local ptClock = {cc.p(185, -8), cc.p(233, -8), cc.p(212, -8), cc.p(185, -8), cc.p(212, -8), cc.p(185, -8), cc.p(205, -8), cc.p(212, -8)}

local pointPlayer = {
	{cc.p(590, 622), cc.p(137, 510), cc.p(1140, 510), cc.p(53, 361), cc.p(1226, 361), cc.p(43, 170)},
	{cc.p(605, 650), cc.p(415, 636), cc.p(795, 636), cc.p(219, 618), cc.p(989, 618), cc.p(144, 480), cc.p(1235, 480), cc.p(44, 322), cc.p(1235, 322), cc.p(64, 155)}
}

local zhuangtimesPositionX = {
	[2] = {-100, 100},
	[3] = {-180.00, 0.00, 180.00},
	[4] = {-250.00, -83.33, 83.33, 250.00},
	[5] = {-316.00, -158.00, 0.00, 158.00, 316.00},
}
local betScoresPositionX = {
	[3] = {-180.00, 0.00, 180.00, 360.00},
	[4] = {-250.00, -83.33, 83.33, 250.00, 417.00},
}
local betScores = {
	-- 轮流当庄
	[0] = {
		-- 明牌下注
		[0] = {
			-- 小倍
			[0] = {2, 3, 4, 5},
			-- 中倍
			[1] = {6, 9, 12, 15},
			-- 大倍
			[2] = {5, 10, 20, 30},
		},
		-- 暗牌下注
		[1] = {
			-- 小倍
			[0] = {2, 3, 4, 5},
			-- 中倍
			[1] = {6, 9, 12, 15},
			-- 大倍
			[2] = {5, 10, 20, 30},
		},
		-- 扫雷模式
		[2] = {
			-- 小倍
			[0] = {1, 2, 3},
			-- 大倍
			[2] = {4, 5, 6},
		},
	},
    -- 看牌抢庄
	[1] = {
		-- 普通模式1
		[0] = {
			-- 小倍
			[0] = {1, 2, 3},
		},
		-- 普通模式2
		[1] = {
			-- 小倍
			[0] = {2, 3, 4, 5},
			-- 中倍
			[1] = {6, 9, 12, 15},
			-- 大倍
			[2] = {5, 10, 20, 30},
		},
		-- 扫雷模式
		[2] = {
			-- 小倍
			[0] = {1, 2, 3},
		},
	},
}

local _scheduler = gt._scheduler
local log = gt.log

function nnScene:init(args)
	gt.log("ok____")

	gt.gameType = "nn"

	self:initData()
	if args.kIsLookOn and args.kIsLookOn == 0 then
		self:addPlayer()
	end
	self.kIsLookOn = args.kIsLookOn
	self:GameLayerRefresh(args)

	-- if not gt.release then
	-- 	local function timerWriteLog( )
	-- 		if gt.timerWriteLog then
	-- 			gt.timerWriteLog()
	-- 		end
	-- 	end
	-- 	--开定时器写log
	--     self.timerWriteLogScheduler = gt.scheduler:scheduleScriptFunc(handler(self, timerWriteLog), 0.1, false)
	-- end
end

function nnScene:onEnterBackground()
	if gt.gameType == "nn" then
		-- gt.socketClient:close()
	    if yl.GAMEDATA[4] == 1 then
			self.Background = true
		    cc.UserDefault:getInstance():setIntegerForKey("currCountdownTime", os.time())
		end
		-- local function socketClientClose( )
		-- 	gt.socketClient:close()
		-- end
	 --    self.socketClientCloseScheduler = gt.scheduler:scheduleScriptFunc(handler(self, socketClientClose), 5, false)
	end
end

function nnScene:onEnterForeground()
	if gt.gameType == "nn" then
	    if yl.GAMEDATA[4] == 1 then
			if self.Background then
				self.Background = false
			    self.currCountdownTimeInterval = os.time() - cc.UserDefault:getInstance():getIntegerForKey("currCountdownTime", os.time())
				if self.currCountdownTimeInterval > 8 then
					self.currCountdownTimeInterval = self.currCountdownTimeInterval - 8
				end
			end
		end

		for i = 1 , GAME_PLAYER do
			if self.getTableIdNN then
				local pos = self:getTableIdNN(i-1)
				if self.m_cbPlayStatus[pos] and self.m_cbPlayStatus[pos] == 1 then 
					if self.m_UserHead and self.m_UserHead[pos] and self.m_UserHead[pos].score and self.TotleScore and self.TotleScore[i] then
						self.m_UserHead[pos].score:setString(self.TotleScore[i])
					end
				end
			end
		end
	end
end

function nnScene:switch_bg(idx)
	if idx == 1 then 
	   	if yl.GAMEDATA[6] == 6 then
			self._node:getChildByName("bg"):loadTexture("nn/scene6peoplesbg.png")
		elseif yl.GAMEDATA[6] == 10 then
			self._node:getChildByName("bg"):loadTexture("nn/scene10peoplesbg.png")
		end
		self:findNodeByName("bg_gray"):setLocalZOrder(999)
		self:findNodeByName("bg_gray"):setVisible(false)
	elseif idx == 2 then 
	   	if yl.GAMEDATA[6] == 6 then
			self._node:getChildByName("bg"):loadTexture("nn/scene6peoplesbggray.png")
		elseif yl.GAMEDATA[6] == 10 then
			self._node:getChildByName("bg"):loadTexture("nn/scene10peoplesbggray.png")
		end
		self:findNodeByName("bg_gray"):setLocalZOrder(999)
		self:findNodeByName("bg_gray"):setVisible(true)
	end
end

function nnScene:initData()
	self.nodePlayer = {}
	self._ready = {}
	self.urlName = {}
	self.m_UserHead = {}
	self.m_flagReady = {}
	self.kanpai = {}
	self.m_BankerFlag = {}
	self.zhuangmask = {}
	self.player_qiangscore = {}
	self.m_betscoresbg = {}
	self.m_betscoresvalue = {}
	self.userCard = {}
	self.m_cbPlayStatus = {}
	self.head_hui = {}
	self.player_score = {}
	self._card = {}
	self.currCountdownTimeInterval = 0
	self.remainTime = 0
	self.curPlayerStatus = 0
	self.xianjiatuizhuScore = 0
	--缓存聊天--聊天泡泡
	self.m_UserChatView = {}
	self.m_UserChat = {}
   	self._voice = {}
   	self._voice_node = {}
   	self._voice_nodes = {}
   	self.currentZhuangtimes = {}
   	self.currentBetScores = {}
   	self.dianAction = {}
   	self.spriteCard = {}
   	self.sendCardData_nn = {}
	gt.m_userId = 0

	local chatImageLeftPath = ""
	local chatImageRightPath = ""

	self:switch_bg(cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, 1))

   	if yl.GAMEDATA[6] == 6 then
		self.currentNode = cc.CSLoader:createNode("nnNode6peoples.csb")
					  	-- :move(gt.winCenter)
					  	:addTo(self:findNodeByName("Node_peoples"))
		GAME_PLAYER = 6
		self.ptChat = ptChat[1]
		self.ptCard = ptCard[1]
		self.pointPlayer = pointPlayer[1]
		chatImageLeftPath = "nn/nn_chat6peoplesbg_left.png"
		chatImageRightPath = "nn/nn_chat6peoplesbg_right.png"
	elseif yl.GAMEDATA[6] == 10 then
		self.currentNode = cc.CSLoader:createNode("nnNode10peoples.csb")
					  	-- :move(gt.winCenter)
					  	:addTo(self:findNodeByName("Node_peoples"))
		GAME_PLAYER = 10
		self.ptChat = ptChat[2]
		self.ptCard = ptCard[2]
		self.pointPlayer = pointPlayer[2]
		chatImageLeftPath = "nn/nn_chat10peoplesbg_left.png"
		chatImageRightPath = "nn/nn_chat10peoplesbg_right.png"
	end

	MY_VIEWID = GAME_PLAYER

	for i =1 , GAME_PLAYER do
	   	if yl.GAMEDATA[6] == 6 then
			if i == 3 or i == 5 then
				self.m_UserChatView[i] = display.newSprite( chatImageRightPath,{scale9 = true ,capInsets=cc.rect(5, 5, 5, 5)})
					:setAnchorPoint(cc.p(1,0.5))
					:move(self.ptChat[i])
					:setVisible(false)
					:addTo(self._node)
			else
				self.m_UserChatView[i] = display.newSprite(chatImageLeftPath,{scale9 = true ,capInsets=cc.rect(5, 5, 5, 5)})
					:setAnchorPoint(cc.p(0,0.5))
					:move(self.ptChat[i])
					:setVisible(false)
					:addTo(self._node)
			end
		elseif yl.GAMEDATA[6] == 10 then
			if i == 7 or i == 9 then
				self.m_UserChatView[i] = display.newSprite( chatImageRightPath,{scale9 = true ,capInsets=cc.rect(30, 30, 30, 30)})
					:setAnchorPoint(cc.p(1,0.5))
					:move(self.ptChat[i])
					:setVisible(false)
					:addTo(self._node)
			else
				self.m_UserChatView[i] = display.newSprite(chatImageLeftPath,{scale9 = true ,capInsets=cc.rect(27, 27, 27, 27)})
					:setAnchorPoint(cc.p(0,0.5))
					:move(self.ptChat[i])
					:setVisible(false)
					:addTo(self._node)
			end
		end

		self.m_cbPlayStatus[i] = 0 
		self.nodePlayer[i] = gt.seekNodeByName(self.currentNode, "player"..i)
		:setVisible(false)	

		gt.setOnViewClickedListener(self.nodePlayer[i],function()
			self:PlaySound("sound_res/cli.mp3")
			self:showPlayerinfo(i)
		end)

		self.playerInfo = cc.CSLoader:createNode("playerInfo.csb")
					  	:move(gt.winCenter)
					  	:addTo(self,9)
		              	:setVisible(false)

		-- 庄
		self.m_BankerFlag[i] = self.nodePlayer[i]:getChildByName("zhuang")
							   :setVisible(false)
		-- 庄的框
		self.zhuangmask[i] = self.nodePlayer[i]:getChildByName("zhuangmask")
							   :setVisible(false)
		-- 抢庄时抢庄倍数
		self.player_qiangscore[i] = self.nodePlayer[i]:getChildByName("qiangtimes")
							   :setVisible(false)
		-- 抢庄倍数
		self.player_score[i] = self.nodePlayer[i]:getChildByName("times")
							   :setVisible(false)
		-- 下注分数
		self.m_betscoresbg[i] = self.nodePlayer[i]:getChildByName("betscoresbg")
							   :setVisible(false)
		self.m_betscoresvalue[i] = self.m_betscoresbg[i]:getChildByName("betscoresvalue")
		self.m_UserHead[i] = {}

		-- 昵称
		self.m_UserHead[i].name = self.nodePlayer[i]:getChildByName("name")
			
		-- 金币
		self.m_UserHead[i].score =  self.nodePlayer[i]:getChildByName("totalscores")
		self.m_UserHead[i].hg = self.nodePlayer[i]:getChildByName("hg")
		self.m_UserHead[i].quanquan = self.nodePlayer[i]:getChildByName("quanquan")

		self._voice[i] = gt.seekNodeByName(self.currentNode, "voice_"..i)
						:setVisible(false)
		
		self._voice_node[i] = self._voice[i]:getChildByName("FileNode")
							:setVisible(false)
		
		self.m_flagReady[i] = self.nodePlayer[i]:getChildByName("readyIm")

		self.kanpai[i] = gt.seekNodeByName(self.currentNode, "wancheng"..i)
		self.kanpai[i]:setVisible(false)

		self.PlayerNN[i] = {}
		self.PlayerNN[i].name = nil
		self.PlayerNN[i].score = nil
		self.PlayerNN[i].url = nil
		self.PlayerNN[i].sex = nil
		self.PlayerNN[i].id = nil
		self.PlayerNN[i].ip= nil
		self.PlayerNN[i].Coins= nil

		-- self.m_ScoreView[i] = gt.seekNodeByName(self.currentNode, "score_"..i)
		-- self.m_ScoreView[i]:setVisible(false)

		self.userCard[i] = {}
		self.userCard[i].card = {}
		--牌区域
		self.userCard[i].area = cc.Node:create()
			:setVisible(false)
			:addTo(self._node:getChildByName("Panel_cards"))
		--牌显示
		for j = 1, 5 do
			self.userCard[i].card[j] = cc.Sprite:create("poker/56.png")
					:move(self.ptCard[i].x + (i==MY_VIEWID and 144 or 30)*(j- 3), self.ptCard[i].y)
					:setVisible(false)
					:addTo(self.userCard[i].area)
			if i ~= MY_VIEWID then
   				if yl.GAMEDATA[6] == 6 then
					self.userCard[i].card[j]:setScale(0.45)
				elseif yl.GAMEDATA[6] == 10 then
					self.userCard[i].card[j]:setScale(0.27)
   				end
			else
				self.userCard[i].card[j]:setScale(0.9)
				--self.MyCardPosY = self.userCard[i].card[j]:getPositionY()
			end
        end

        self.head_hui[i] = self.nodePlayer[i]:getChildByName("off")

        self._card[i] = gt.seekNodeByName(self.currentNode, "cards_"..i)
        			:setVisible(false)

		self.userCard[i].cardType = self:findNodeByName("card_type",self._card[i] )
		self.userCard[i].cardType:setVisible(false)
		self.userCard[i].roundScoreBg = self:findNodeByName("roundScoreBg",self._card[i] )
		self.userCard[i].roundScoreBg:setVisible(false)
		self.userCard[i].roundScore = self:findNodeByName("roundScore",self._card[i] )
		self.userCard[i].roundScore:setVisible(false)
	end

	self:findNodeByName("Node_voice"):setVisible(true)
	self.readyclockImg = self:findNodeByName("Img_readyclock")
	self.readyclockImg:setVisible(false)
	self.readyclockText = self:findNodeByName("Text_readyclock")
	self.readyTipsText = self:findNodeByName("Text_readyTips")
	self.lookonTipsText = self:findNodeByName("Text_lookonTips")

	-- if gt.isCreateUserId then
	-- 	self.readyTipsText:setVisible(true)
	-- 	self.lookonTipsText:setVisible(false)
	-- else
		if self.guancha then
			self.readyTipsText:setVisible(false)
			if gt.curCircle > 0 then 
				self:ActionDian(self.lookonTipsText, false)
			else
				self:ActionDian(self.lookonTipsText, true)
			end
		else
			if gt.curCircle > 0 then 
				self:ActionDian(self.readyTipsText, false)
			else
				self:ActionDian(self.readyTipsText, true)
			end
			self:ActionDian(self.lookonTipsText, false)
		end
	-- end

	self:setReadyClock()

	self.clock = self:findNodeByName("clock")
	self.clock:setVisible(false)
	gt.log("------yl.GAMEDATA")
	dump(yl.GAMEDATA)
	if yl.GAMEDATA[4] == 1 then
		self:setCountdownTime()
	end

	local btnBg = self:findNodeByName("downBg")
	local downorup = self:findNodeByName("down")
	gt.setOnViewClickedListener(self._node:getChildByName("bg"), function()
		if self.playerInfo then self.playerInfo:setVisible(false) end
		log("touch___________________")
		btnBg:setVisible(false)
	end)

	gt.setOnViewClickedListener(downorup, function()
			btnBg:setVisible(not btnBg:isVisible())
			downorup:loadTexture(btnBg:isVisible() and "nn/up.png" or "nn/down.png")
		end)

	local  btncallback = function(ref, type)
        if type == ccui.TouchEventType.began then
        elseif type == ccui.TouchEventType.canceled then
        elseif type == ccui.TouchEventType.ended then
			self:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end

	--聊天按钮
	self.chatbtn = self:findNodeByName("btn_chat")
	self.chatbtn:setTag(BT_CHAT)
	self.chatbtn:addTouchEventListener(btncallback)
	self.yuyinBtn = self:findNodeByName("voice")
	if self.guancha then
		self.chatbtn:setVisible(false)
		self.yuyinBtn:setVisible(false)
	else
		self.chatbtn:setVisible(true)
		self.yuyinBtn:setVisible(true)
	end

    self.jushu = self:findNodeByName("txt_roundCount")
    self.wanfa = self:findNodeByName("txt_playmode")
    self.moshi = self:findNodeByName("txt_selectmode")
    self.roomId = self:findNodeByName("txt_roomID")

    self.text1 = self:findNodeByName("clocks1") -- 请抢庄
    self.text2 = self:findNodeByName("clocks2") -- 等待其他玩家抢庄
    self.text3 = self:findNodeByName("clocks3") -- 等待闲家下注
    self.text4 = self:findNodeByName("clocks4") -- 请下注
    self.text5 = self:findNodeByName("clocks5") -- 等待其他玩家下注
    self.text6 = self:findNodeByName("clocks6") -- 亮牌中
    self.text7 = self:findNodeByName("clocks7") -- 等待下一局
    self.text8 = self:findNodeByName("clocks8") -- 等待其他玩家亮牌
    self.text9 = self:findNodeByName("began") -- 请开始游戏
    self.text10 = self:findNodeByName("waitbegan") -- 等待房主开始游戏
    
    self.xiafen = self:findNodeByName("cellscore_node")
    self.callbankernode = self:findNodeByName("select_banker_node")
    self.nodeopencard = self:findNodeByName("opencard_node")
	self.nodeopencard:setVisible(false)

    for i = 1 , 5 do
    	gt.setOnViewClickedListener(self:findNodeByName("btn_call_"..i-1), function()
    			self:PlaySound("sound_res/cli.mp3")
    		end,0,"zoom")

		self:findNodeByName("btn_call_"..i-1):setPressedActionEnabled(true)
		self:findNodeByName("btn_call_"..i-1):setZoomScale(-0.1)
    end

    gt.setOnViewClickedListener(self:findNodeByName("showcard"), function()
		self:_playSound_nn(0, "GAME_BUTTON")
	 -- //牛牛：玩家请求发牌、亮牌消息

	 -- MSG_C_2_S_NIUNIU_OPEN_CARD = 62075

	 -- kPos  //玩家位置
    	local msgToSend = {}
    	msgToSend.kMId = gt.MSG_C_2_S_NIUNIU_OPEN_CARD 
    	msgToSend.kPos = self.UsePos
		gt.socketClient:sendMessage(msgToSend)
		if gt.dumplog_nn then
			gt.dumplog_nn(msgToSend)
		end
    end,0,"zoom")
		self:findNodeByName("showcard"):setPressedActionEnabled(true)
		self:findNodeByName("showcard"):setZoomScale(-0.1)

	self.result_node = require("client/game/poker/view/result"):create("nn")
	self:addChild(self.result_node, 99)
	self.result_node:setVisible(false)
	
    self.sharebtn = self:findNodeByName("btn_share")
    self.sharebtn:setVisible(false)
	self.sharebtn:setTag(BT_INVITE)
	self.sharebtn:setPressedActionEnabled(true)
	self.sharebtn:setZoomScale(-0.1)

    self.startbtn = self:findNodeByName("btn_start")
    				:setVisible(false)
			 	 	:setTag(BT_BEGIN)
	self.startbtn:setPressedActionEnabled(true)
	self.startbtn:setZoomScale(-0.1)

	self.readybtn = self:findNodeByName("btn_ready")
	 			 :setVisible(false)
			 	 :setTag(BT_READY)
	self.readybtn:setPressedActionEnabled(true)
	self.readybtn:setZoomScale(-0.1)

	self.lookonImg = self:findNodeByName("Img_lookon")
	 			 :setVisible(false)

	self.btNext = self:findNodeByName("btn_next")
	 			 :setVisible(false)
			 	 :setTag(BT_NEXT)
	self.btNext:setPressedActionEnabled(true)
	self.btNext:setZoomScale(-0.1)

	-- if yl.GAMEDATA[4] == 0 then
	-- 	self.btNext:loadTextures("res/nn/next.png", "res/nn/next.png")
	-- elseif yl.GAMEDATA[4] == 1 then
	-- 	self.btNext:loadTextures("res/nn/next_trusteeship.png", "res/nn/next_trusteeship.png")
	-- end

	self.resultbtn = self:findNodeByName("btn_result")
	self.resultbtn:setVisible(false)
	self.resultbtn:setTag(BT_READ)

	--坐下
	if self.guancha and not self.playerFull then
		self.readybtn:setVisible(true)
	end

	--叫庄
	self.callbankernode = self:findNodeByName ("select_banker_node")

	-- 抢庄
	for i = 1, 5 do
		self.callbankernode:getChildByName("btn_call_" .. tostring(i - 1)):setVisible(false)
	end
	self.currentZhuangtimes = yl.GAMEDATA[7] + 2
	for i = 1, self.currentZhuangtimes do
		local btn = self.callbankernode:getChildByName("btn_call_" .. tostring(i - 1))
		btn:setTag(BT_CALLBANKER + i - 1)
		btn:setVisible(true)
		btn:addTouchEventListener(btncallback)
		if self.currentZhuangtimes == 2 and i == 2 then
			btn:loadTextures("res/nn/nn_zhuang.png", "res/nn/nn_zhuang.png")
		end
		btn:setPositionX(zhuangtimesPositionX[self.currentZhuangtimes][i])
	end

	--下注
	for i = 1, 4 do
		self:findNodeByName("btn_cell_score_"..i):setVisible(false)
	end
    for i = 1 , 4 do
    	gt.setOnViewClickedListener(self:findNodeByName("btn_cell_score_"..i), function()
				self:_playSound_nn(0, "ADD_SCORE")
				 -- //牛牛：玩家下注消息

				 --    MSG_C_2_S_NIUNIU_ADD_SCROE = 62073

				 --    kScore  //玩家下注分数
    			local msgToSend = {}
    			msgToSend.kMId = gt.MSG_C_2_S_NIUNIU_ADD_SCROE
    			
    			msgToSend.kScore = self.currentBetScores[i]
				gt.socketClient:sendMessage(msgToSend)
				self:clearText()
    			self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text5)
    			self:showAddScoreBtn(false)

				if gt.dumplog_nn then
					gt.dumplog_nn(msgToSend)
				end
    		end,0,"zoom")
		self:findNodeByName("btn_cell_score_"..i):setPressedActionEnabled(true)
		self:findNodeByName("btn_cell_score_"..i):setZoomScale(-0.1)
    end

	self.btn_cell_score_xianjiatuizhu = self:findNodeByName("btn_cell_score_xianjiatuizhu")
	self.btn_cell_score_xianjiatuizhu:setVisible(false)
	gt.setOnViewClickedListener(self.btn_cell_score_xianjiatuizhu, function()
			self:_playSound_nn(0, "ADD_SCORE")
			 -- //牛牛：玩家下注消息

			 --    MSG_C_2_S_NIUNIU_ADD_SCROE = 62073

			 --    kScore  //玩家下注分数
			local msgToSend = {}
			msgToSend.kMId = gt.MSG_C_2_S_NIUNIU_ADD_SCROE
			
			msgToSend.kScore = self.xianjiatuizhuScore
			gt.socketClient:sendMessage(msgToSend)
			self:clearText()
			self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text5)
			self:showAddScoreBtn(false)

			if gt.dumplog_nn then
				gt.dumplog_nn(msgToSend)
			end
		end,0,"zoom")
	self.btn_cell_score_xianjiatuizhu:setPressedActionEnabled(true)
	self.btn_cell_score_xianjiatuizhu:setZoomScale(-0.1)

   	self.currentBetScores = betScores[yl.GAMEDATA[1]][(yl.GAMEDATA[2] > 2 and yl.GAMEDATA[2] - 3 or yl.GAMEDATA[2])][yl.GAMEDATA[8]] or {}
	for i = 1, table.nums(self.currentBetScores) do
		self:findNodeByName("btn_cell_score_"..i):loadTextures("res/nn/nn_scores"..self.currentBetScores[i]..".png", "res/nn/nn_scores"..self.currentBetScores[i]..".png")
		self:findNodeByName("btn_cell_score_"..i):setVisible(true)
		self:findNodeByName("btn_cell_score_"..i):setPositionX(betScoresPositionX[table.nums(self.currentBetScores)][i])
	end

	local settingbtn = self:findNodeByName("btn_setting")
	settingbtn:setTag(BT_SETTING) 
	settingbtn:addTouchEventListener(btncallback)

	self.dissolvebtn = self:findNodeByName("btn_dissolve")
	self.dissolvebtn:setTag(BT_DISSOLVE) 
	self.dissolvebtn:addTouchEventListener(btncallback)
	if self.guancha then
		self.dissolvebtn:setEnabled(false)
	else
		self.dissolvebtn:setEnabled(true)
	end

	local leavelbtn = self:findNodeByName("btn_leavel")
	leavelbtn:setTag(BT_LEAVE) 
	leavelbtn:addTouchEventListener(btncallback)

	self.sharebtn:addTouchEventListener(btncallback)
 	self.readybtn:addTouchEventListener(btncallback)
 	self.btNext:addTouchEventListener(btncallback)
 	self.startbtn:addTouchEventListener(btncallback)
	self.resultbtn:addTouchEventListener(btncallback)

	--版本
	self:findNodeByName("Txt_version"):setString("1.0.6"..(self:getAppVersionShow() or ""))
end 

function nnScene:getAppVersionShow()
	local luaBridge = nil
	local ok, appVersion = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		ok, appVersion = luaBridge.callStaticMethod("AppController", "getVersionName")
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		ok, appVersion = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")
	end

	return appVersion
end

function nnScene:showAddScoreBtn(bool)
	gt.log(debug.traceback())
	gt.log("--------bool", bool)
	self.xiafen:setVisible(bool)

end

function nnScene:setReadyClock()
	if cc.UserDefault:getInstance():getIntegerForKey("readyClockTime", 0) == 0 then
		gt.log("---------------------setReadyClock")
		cc.UserDefault:getInstance():setIntegerForKey("readyClockTime", os.time())
	end

	self.readyClockTime = 15 - (os.time() - cc.UserDefault:getInstance():getIntegerForKey("readyClockTime", os.time()))
	if self.readyClockTime > 0 then
    	self.readyClockTimeSchedulerEntry = gt.scheduler:scheduleScriptFunc(function (  )
			self.readyClockTime = self.readyClockTime - 1

			self.readyClockTime = 15 - (os.time() - cc.UserDefault:getInstance():getIntegerForKey("readyClockTime", 0))

			self.readyclockText:setString(self.readyClockTime >= 0 and self.readyClockTime or 0)

			if self.readyClockTime <= 0 then
				if self.readyClockTimeSchedulerEntry then
					gt.scheduler:unscheduleScriptEntry(self.readyClockTimeSchedulerEntry)
					self.readyClockTimeSchedulerEntry = nil
					cc.UserDefault:getInstance():setIntegerForKey("readyClockTime", 0)
				end
			end
    	end, 1, false)
    end

		gt.log("---------------------self.readyClockTime", self.readyClockTime)
	self.readyclockText:setString((self.readyClockTime >= 0 and self.readyClockTime or 0))
	-- self.readyclockImg:setVisible(true)

	-- if gt.isCreateUserId then
	-- 	self:ActionDian(self.readyTipsText, true)
	-- 	self:ActionDian(self.lookonTipsText, false)
	-- else
		if self.guancha then
			self:ActionDian(self.readyTipsText, false)
			if gt.curCircle > 0 then 
				self:ActionDian(self.lookonTipsText, false)
			else
				self:ActionDian(self.lookonTipsText, true)
			end
		else
			if gt.curCircle > 0 then 
				self:ActionDian(self.readyTipsText, false)
			else
				self:ActionDian(self.readyTipsText, true)
			end
			self:ActionDian(self.lookonTipsText, false)
		end
	-- end
	
end

function nnScene:clock_time(msg)
	if gt.dumplog_nn then
		gt.dumplog_nn(msg)
	end

	self:clearUI()
	
	self:ActionText(true, self.text7)
    if yl.GAMEDATA[4] == 1 then
	    if msg.kCurCircle > 0 then
	    	self.remainTime = msg.kRemainTime
			self.currCountdownTime = self.remainTime > 0 and self.remainTime or self.CountdownTime[4]
			self:setCountdownSchedule(self.currCountdownTime, self.clock)
	    end
	end
end

function nnScene:setCountdownTime()
	self.CountdownTime = {}
	-- 抢庄，为7s
	self.CountdownTime[1] = 7
	-- 下注，为5s
	self.CountdownTime[2] = 5
	-- 亮牌，为4s
	self.CountdownTime[3] = 4
	-- 下一局，为8s
	self.CountdownTime[4] = 8
end

function nnScene:setCountdownSchedule(_time, _node)
	gt.log(debug.traceback())
	local time = _time
	self.currTimeInterval = time
	self.currCountdownTime = time
	gt.log("---self.currCountdownTime", self.currCountdownTime)

	-- if self.playclock then
	-- 	gt.soundEngine:stopEffect(self.playclock)
	-- 	self.playclock = nil
	-- end
	-- self.playclock = gt.soundEngine:playEffect("sound_nn/CLOCK", true, true)

	local function countdownTime( showCards )
		self.currCountdownTime = self.currCountdownTime - 1 - self.currCountdownTimeInterval
		self.currCountdownTimeInterval = 0
		if _node and _node.setString then
			_node:setString((self.currCountdownTime > 0 and self.currCountdownTime or 0).."s")
		end
		if self.currCountdownTime == 0 then
			if self.scheduleShowCountdownHandler then
				gt.scheduler:unscheduleScriptEntry(self.scheduleShowCountdownHandler)
				self.scheduleShowCountdownHandler = nil
			end

			-- if self.playclock then
			-- 	gt.soundEngine:stopEffect(self.playclock)
			-- 	self.playclock = nil
			-- end
		end		
	end

	if _node and _node.setString then
		_node:setString((self.currCountdownTime > 0 and self.currCountdownTime or 0).."s")
	end
	
	if self.scheduleShowCountdownHandler then
		gt.scheduler:unscheduleScriptEntry(self.scheduleShowCountdownHandler)
		self.scheduleShowCountdownHandler = nil
	end

	self.remainTime = 0
	self.scheduleShowCountdownHandler = gt.scheduler:scheduleScriptFunc(handler(self, countdownTime), 1, false)
end

function nnScene:addScore_nn(args)
-- //牛牛：服务器返回玩家下注消息

--     MSG_S_2_C_NIUNIU_ADD_SCORE = 62074

--     kPos  //玩家位置

--     kScore  //玩家下注分数
	
	if gt.dumplog_nn then
		gt.dumplog_nn(args)
	end

	for i , v in pairs(self.zhuangmask) do
		v:stopAllActions()
	end

	local timeshow = false
	if self.clock:isVisible() then
		timeshow = true
	end
	
	self:clearUI("addScore_nn")
	
	if timeshow then
		self.clock:setVisible(true)
	end

	local score = args.kScore
	local p = self:getTableIdNN(args.kPos)
	local node = self.m_betscoresvalue[p]
	node:setString(score)
	self.m_betscoresbg[p]:setVisible(true)

	if args.kPos == self.UsePos then
		self:clearText()
    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text5)
    	self:showAddScoreBtn(false)
    else
		if self.guancha then
	    	self:ActionText(true, self.text7)
	    end
	end

end

function nnScene:showReady(bool,pos)

	if pos then 
		-- if pos > =0 and  pos < 6 then 
		-- 	self.m_flagReady[pos]:setVisible(false)
		-- end
	else
		for i = 1, GAME_PLAYER do
			self.m_flagReady[i]:setVisible(false)
		end
	end

end

-- 明牌下注发牌
function nnScene:sendCard_bet()

end

-- 翻牌动画
function nnScene:flopAnimation( node, image, callback )
	local function FlipSpriteComplete()
		if callback then
			callback()
		end
	end

	local function FlipSpriteCallback()
		node:setTexture(image)
	    local action = CCOrbitCamera:create(0.1, 1, 0, 270, 90, 0, 0)
	    node:runAction(cc.Sequence:create(action, cc.CallFunc:create(FlipSpriteComplete)))
	end

	if image == "poker/56.png" then
		return
	end

	node:setVisible(true)
    local action = CCOrbitCamera:create(0.1, 1, 0, 0, 90, 0, 0)
    local callback = FlipSpriteCallback
    node:runAction(cc.Sequence:create(action, cc.CallFunc:create(FlipSpriteCallback)))
end

function nnScene:sendCard_nn(msg, reconnectFlag)
	if gt.dumplog_nn then
		gt.dumplog_nn(msg)
	end
	gt.log("-----------------sendCard_nnmsg.kPos", msg.kPos)
	self.sendCardData_nn[msg.kPos] = msg
-- //牛牛：服务器返回发牌、亮牌消息

--     MSG_S_2_C_NIUNIU_OPEN_CARD = 62076

--     kShow  //发牌 or 亮牌  0-发牌  1-亮牌

--     kPos   //玩家位置

--     kOxNum //玩家牛牛数

--     kPlayerHandCard[5]  //玩家手牌

--     kPlayerStatus[6]  //有几个人玩

	local timeshow = false
	if self.clock:isVisible() then
		timeshow = true
	end
	
	self:clearUI("sendCard_nn")
	
	self.curPlayerStatus = (msg.kPlayerStatus[self.UsePos + 1] == 1)

	if timeshow then
		self.clock:setVisible(true)
	end

	gt.log("-----------------self.m_BankerFlag", self:getTableIdNN(self.m_wBankerUser))
	self.player_score[self:getTableIdNN(self.m_wBankerUser)]:setVisible(true)
	self.player_qiangscore[self:getTableIdNN(self.m_wBankerUser)]:setVisible(false)

	self:showReady()

	if self.sendCardData_nn[msg.kPos].kShow == 0 then --发牌
		self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text6)
		if not reconnectFlag then
		    if yl.GAMEDATA[4] == 1 then
				self.currCountdownTime = self.remainTime > 0 and self.remainTime or self.CountdownTime[3]
				self:setCountdownSchedule(self.currCountdownTime, self.clock)
			end
		end
		local status = self.sendCardData_nn[msg.kPos].kPlayerStatus
		for i=1 , #status do
			self.m_cbPlayStatus[self:getTableIdNN(i-1)] = status[i]
			log("....",self.m_cbPlayStatus[i],i,self:getTableIdNN(i-1))
		end
		local function noLocalFlopAnimation( flopflag, pos, index)
			if self.sendCardData_nn[pos] then
				if MY_VIEWID == self:getTableIdNN(self.sendCardData_nn[pos].kPos) then
					local cardData = self.sendCardData_nn[pos].kPlayerHandCard
					-- for i = 1 , #cardData do
						log("poker/"..gt.tonumber(cardData[index])..".png")
						-- self:findNodeByName("card"..i, self._card[MY_VIEWID]):loadTexture("poker/"..gt.tonumber(cardData[i])..".png")
						if flopflag and i == #cardData then
							self:flopAnimation(self.userCard[MY_VIEWID].card[index], "poker/"..gt.tonumber(cardData[index])..".png")
						else
							self.userCard[MY_VIEWID].card[index]:setTexture("poker/"..gt.tonumber(cardData[index])..".png")
							self.userCard[MY_VIEWID].card[index]:setVisible(true)
						end
					-- end
				end
			end
		end

		local function localFlopAnimation( flopflag, pos, index )
			if self.sendCardData_nn[pos] then
				if MY_VIEWID == self:getTableIdNN(self.sendCardData_nn[pos].kPos) then
					local cardData = self.sendCardData_nn[pos].kPlayerHandCard
					if flopflag then
						if (yl.GAMEDATA[1] == 1 or (yl.GAMEDATA[1] == 0 and yl.GAMEDATA[2] == 3)) and index < 5 then
							self.userCard[MY_VIEWID].card[index]:setTexture("poker/"..gt.tonumber(cardData[index])..".png")
						end

						self:flopAnimation(self.userCard[MY_VIEWID].card[5], "poker/"..gt.tonumber(cardData[5])..".png")
					else
						for i = 1 , #cardData do
							-- self._card[MY_VIEWID]:findNodeByName("card"..i):loadTexture("poker/"..gt.tonumber(cardData[i])..".png")
							self:flopAnimation(self.userCard[MY_VIEWID].card[i], "poker/"..gt.tonumber(cardData[i])..".png")
						end
					end
				end
			end
		end 
		local CenterSendCardFlag = false
		self.sendCardFlag = false
        local delayCount = 1
        local delayTime = 0.1
		self.spriteCard  = {}
        for i = 1, GAME_PLAYER do
        	local chair = math.mod(self.m_wBankerUser + i - 1,GAME_PLAYER) 
			self.spriteCard[self:SwitchViewChairIDNN(chair)] = {}
        	if self.m_cbPlayStatus[self:getTableIdNN(chair)] == 1 then
            	for index = 1 , 5 do
                	if reconnectFlag then
		                if yl.GAMEDATA[1] == 1 then 
							if not CenterSendCardFlag then
								CenterSendCardFlag = true
								gt.log("----------------CENTER_SEND_CARD1")
								self:PlaySound("sound_res/CENTER_SEND_CARD.mp3")
							end
		                    -- self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,false,localFlopAnimation(true, chair, index))
			            	self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,false,function ( )
								local cardData = self.sendCardData_nn[chair].kPlayerHandCard
					            for i = 1 , #cardData do
			            			self:flopAnimation(self.userCard[MY_VIEWID].card[i], "poker/"..gt.tonumber(cardData[i])..".png")
					            end
			            	end)
		                elseif yl.GAMEDATA[1] == 0 then
							if not CenterSendCardFlag then
								CenterSendCardFlag = true
								gt.log("----------------CENTER_SEND_CARD2")
								self:PlaySound("sound_res/CENTER_SEND_CARD.mp3")
							end
			            	-- self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,false,localFlopAnimation(false, chair, index))
			            	self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,false,function ( )
								local cardData = self.sendCardData_nn[chair].kPlayerHandCard
					            for i = 1 , #cardData do
			            			self:flopAnimation(self.userCard[MY_VIEWID].card[i], "poker/"..gt.tonumber(cardData[i])..".png")
					            end
			            	end)
		                end
		            else
		            	if yl.GAMEDATA[1] == 1 then
		                    self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,true,localFlopAnimation(true, chair, index))
		                elseif yl.GAMEDATA[1] == 0 then
		                	if gt.curCircle <= 1 then 
			                	if yl.GAMEDATA[2] == 4 or (yl.GAMEDATA[1] == 0 and yl.GAMEDATA[2] == 2) then
									if not CenterSendCardFlag then
										CenterSendCardFlag = true
								gt.log("----------------CENTER_SEND_CARD3")
										self:PlaySound("sound_res/CENTER_SEND_CARD.mp3")
									end
				                    -- self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,true,noLocalFlopAnimation(true, chair, index))
					            	self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,false,function ( )
										local cardData = self.sendCardData_nn[chair].kPlayerHandCard
							            for i = 1 , #cardData do
					            			self:flopAnimation(self.userCard[MY_VIEWID].card[i], "poker/"..gt.tonumber(cardData[i])..".png")
							            end
					            	end)
			                	else
									local nodeCard = self.userCard[self:SwitchViewChairIDNN(chair)]
									nodeCard.area:setVisible(true)
									if self:SwitchViewChairIDNN(chair) == MY_VIEWID then 
										dump(msg.kPlayerStatus)
										if not self.sendCardFlag and not self.guancha and msg.kPlayerStatus[self.UsePos + 1] == 1 then
											self.nodeopencard:setVisible(true)
										end
										self.sendCardFlag = false
									end
				                    self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,true,localFlopAnimation(true, chair, index))
								end
			                else
			                	if yl.GAMEDATA[2] == 3 then
									local nodeCard = self.userCard[self:SwitchViewChairIDNN(chair)]
									nodeCard.area:setVisible(true)
									if self:SwitchViewChairIDNN(chair) == MY_VIEWID then 
										dump(msg.kPlayerStatus)
										if not self.sendCardFlag and not self.guancha and msg.kPlayerStatus[self.UsePos + 1] == 1 then
											self.nodeopencard:setVisible(true)
										end
										self.sendCardFlag = false
									end
				                    self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,true,localFlopAnimation(true, chair, index))
			                	elseif yl.GAMEDATA[2] == 4 or (yl.GAMEDATA[1] == 0 and yl.GAMEDATA[2] == 2) then
									if not CenterSendCardFlag then
										CenterSendCardFlag = true
								gt.log("----------------CENTER_SEND_CARD4")
										self:PlaySound("sound_res/CENTER_SEND_CARD.mp3")
									end
				                    -- self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,false,localFlopAnimation(false, chair, index))
					            	self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,false,function ( )
										local cardData = self.sendCardData_nn[chair].kPlayerHandCard
							            for i = 1 , #cardData do
					            			self:flopAnimation(self.userCard[MY_VIEWID].card[i], "poker/"..gt.tonumber(cardData[i])..".png")
							            end
					            	end)
			                	else
				                    self:SendCard(self:SwitchViewChairIDNN(chair),index,delayCount*delayTime,true,localFlopAnimation(true, chair, index))
				                end
			                end
		                end
                	end
		    	end
	     		delayCount = delayCount + 1
            end
        end
	elseif self.sendCardData_nn[msg.kPos].kShow == 1 then  --亮牌
		local i = self:getTableIdNN(self.sendCardData_nn[msg.kPos].kPos)
		if not reconnectFlag then
			local function showCardType( )
				local strFile = string.format("nn_type/ox_%d.png", self.sendCardData_nn[msg.kPos].kOxNum)
				self.userCard[i].cardType:loadTexture(strFile)
				self:_playSound_nn(gt.MY_VIEWID, string.format("ox_%d", self.sendCardData_nn[msg.kPos].kOxNum))
				self.userCard[i].cardType:stopAllActions()
				self.userCard[i].cardType:setPositionX(-200)
				self.userCard[i].cardType:setVisible(true)
				self.userCard[i].cardType:runAction(
					cc.Sequence:create(
						cc.MoveTo:create(0.1, cc.p(0, self.userCard[i].cardType:getPositionY())),
						cc.MoveTo:create(0.1, cc.p(-30, self.userCard[i].cardType:getPositionY())),
						cc.MoveTo:create(0.1, cc.p(0, self.userCard[i].cardType:getPositionY()))
						))
			end

			gt.log("------------------self.UsePos", self.UsePos)
			gt.log("------------------self.sendCardData_nn[msg.kPos].kPos", self.sendCardData_nn[msg.kPos].kPos)
			if self.UsePos == self.sendCardData_nn[msg.kPos].kPos then
				self:clearText()
		    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text8)
		    	self.nodeopencard:setVisible(false)
		    	showCardType()
			else
				self.kanpai[i]:setVisible(true)
			end
		else
			local i = self:getTableIdNN(self.sendCardData_nn[msg.kPos].kPos)
			gt.log("------------------self.UsePos", self.UsePos)
			gt.log("------------------self.sendCardData_nn[msg.kPos].kPos", self.sendCardData_nn[msg.kPos].kPos)
			if self.UsePos == self.sendCardData_nn[msg.kPos].kPos then
				self:clearText()
		    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text8)
		    	self.nodeopencard:setVisible(false)
				local strFile = string.format("nn_type/ox_%d.png", self.sendCardData_nn[msg.kPos].kOxNum)
				self.userCard[i].cardType:setVisible(true)
				self.userCard[i].cardType:loadTexture(strFile)
				self:_playSound_nn(i, string.format("ox_%d", self.sendCardData_nn[msg.kPos].kOxNum))
			else
				self.kanpai[i]:setVisible(true)
			end
		end
	end
end

function nnScene:clearText(clearUIType)
	if clearUIType ~= "noifyqiangzhuang" then
		self:ActionText(false,self.text1)
		self:ActionText(false,self.text2)
	end
	if clearUIType ~= "addScore_nn" then
		self:ActionText(false,self.text3)
		self:ActionText(false,self.text4)
		self:ActionText(false,self.text5)
	end
	self:ActionText(false,self.text7)
	if clearUIType ~= "sendCard_nn" then
		self:ActionText(false,self.text6)
		self:ActionText(false,self.text8)
	end
	self:ActionText(false,self.text9)
	self:ActionText(false,self.text10)
end

function nnScene:OnResetView()  -- f5
	if self.guancha and not self.playerFull then
		self.readybtn:setVisible(true)
	else
		self.readybtn:setVisible(false)
	end
   	self:ActionText(false)
   	self.text3:setVisible(false)
   	self.text4:setVisible(false)
	if self.dismissFlyCoins then
		self:dismissFlyCoins()
	end

	if GAME_PLAYER == 6 then
		self._ready = {false,false,false,false,false,false}
	elseif GAME_PLAYER == 10 then
		self._ready = {false,false,false,false,false,false,false,false,false,false}
	end

	for i = 1 ,GAME_PLAYER do
		--self.nodePlayer[i]:setPosition(self.PX[i],self.PY[i]) -- cde
		--self:findNodeByName("clock",self.nodePlayer[i]):setVisible(false)
		--self.nodePlayer[i]:setVisible(true)
		-- self._voice[i]:setVisible(false)
		-- self._voice_node[i]:setVisible(false)
		--self.sign[i]:setVisible(false)
		--self.liuchang_sign[i]:setVisible(false)
		--self.hui_bg[i]:setVisible(false)
		--self.comPokeLose[i]:setVisible(false)
		self.m_UserHead[i].quanquan:stopAllActions()
		self.m_UserHead[i].quanquan:setVisible(false)
		self.m_UserHead[i].hg:setVisible(false)
		-- self.nodePlayer[i]:getChildByName("sp_8"):setVisible(false)
		--if i == 2 or i == 4 then self.userCard[i].roundScore:setPosition(self._node:getChildByName("Node_"..i):getPosition()) end
		self.userCard[i].roundScore:setVisible(false)
		for j = 1, 5 do
			self.userCard[i].card[j]:setVisible(false)
		end
		-- self:SetLookCard(i, false)
		-- self:SetUserCardType(i)
		-- self:SetUserTableScore(i, 0)
		-- self:SetUserGiveUp(i,false)
		-- self:SetUserCard(i,nil)
        -- self:clearCard(i)
        -- self.qi_pai[i]:setVisible(false)
	end
	--if self._clockGameStart then _scheduler:unscheduleScriptEntry(self._clockGameStart) self._clockGameStart = nil end
	-- self:removeActionHuo()
	-- self.___node = nil
	-- self.baoji = false
	-- self.shuohua = false
	-- self.action = false
	-- self.action1 = false
	-- self.action2 = false
	-- self.compareidx = 0
end

function nnScene:onBeginGame()

	local msgToSend = {}
	msgToSend.kMId = gt.SUB_S_GAME_START
	msgToSend.kPos = self.UsePos
	gt.socketClient:sendMessage(msgToSend)
	
	if gt.dumplog_nn then
		gt.dumplog_nn(msgToSend)
	end
end
function nnScene:sendBanker(QiangScore)
	
	local msgToSend = {}
	msgToSend.kMId = gt.MSG_C_2_S_NIUNIU_SELECT_ZHUANG
	msgToSend.kQiangScore = QiangScore
	gt.socketClient:sendMessage(msgToSend)
	if gt.dumplog_nn then
		gt.dumplog_nn(msgToSend)
	end
	self:_playSound_nn(0, "ADD_SCORE")
end

function nnScene:onAddRoomSeatDown(msgTbl)
		gt.log("-------------msgTbl.kErrorCode", msgTbl.kErrorCode)
	if msgTbl.kErrorCode ~= 0 then
		self.guancha = true
		self.playerFull = true
		self.dissolvebtn:setEnabled(false)
		self.chatbtn:setVisible(false)
		self.yuyinBtn:setVisible(false)
		self:ActionDian(self.lookonTipsText, false)
		self.readybtn:setVisible(false)
	 	self.lookonImg:setVisible(true)
	else
		gt.log("-------------onAddRoomSeatDown")
		--坐下成功
		self.guancha = false
		self:ActionDian(self.readyTipsText, false)
		self:ActionDian(self.lookonTipsText, false)
		self.readybtn:setVisible(false)
		self.lookonImg:setVisible(false)
		self.dissolvebtn:setEnabled(true)
		self.chatbtn:setVisible(true)
		self.yuyinBtn:setVisible(true)
		self:onNextRoundGame()
		self.UsePos = msgTbl.kPos
		for i = 1, gt.MY_VIEWID do
			self.head_hui[self:getTableIdNN(i-1)]:setVisible(false)
			self.nodePlayer[self:getTableIdNN(i-1)]:setVisible(false)
			self.m_flagReady[self:getTableIdNN(i-1)]:setVisible(false)
			self.m_cbPlayStatus[self:getTableIdNN(i-1)] = 0
			self.PlayerNN[self:getTableIdNN(i-1)] = nil
		end
		for i = 1, gt.MY_VIEWID do
			if self.playersDataNN[i] and self.playersDataNN[i].kUserId then
				self:addPlayer(self.playersDataNN[i])
			end
		end
	end
end

function nnScene:onNNLookonPlayerFull(msgTbl)
	if msgTbl.kErrorCode == 0 then
		self.guancha = true
		self.playerFull = false
		self.dissolvebtn:setEnabled(false)
		self.chatbtn:setVisible(false)
		self.yuyinBtn:setVisible(false)
		self:ActionDian(self.lookonTipsText, true)
		self.readybtn:setVisible(true)
	 	self.lookonImg:setVisible(true)
	elseif msgTbl.kErrorCode == 1 then
		self.guancha = true
		self.playerFull = true
		self.dissolvebtn:setEnabled(false)
		self.chatbtn:setVisible(false)
		self.yuyinBtn:setVisible(false)
		self:ActionDian(self.lookonTipsText, false)
		self.readybtn:setVisible(false)
	 	self.lookonImg:setVisible(true)
	end

	self:setBtnShare()
end

function nnScene:off_line(args)

	gt.log("off___________________")
	self.head_hui[self:getTableIdNN(args.kPos)]:setVisible(0 == args.kFlag)
end

--按键响应
function nnScene:OnButtonClickedEvent(tag,ref)
	log("tag..,,,,",tag)
	if tag == BT_DISSOLVE then
		self:PlaySound("sound_res/cli.mp3") 
		if not gt.isCreateUserId and not self.gameBegin  then -- and 游戏没开始
			self:exitRoom(false)
		else
			self:exitRoom(true)
		end
	elseif tag == BT_LEAVE then 
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
	elseif tag == BT_CALLBANKER then
		self:sendBanker(0)
	elseif tag == BT_CALLBANKER + 1 then
		self:sendBanker(1)
	elseif tag == BT_CALLBANKER + 2 then
		self:sendBanker(2)
	elseif tag == BT_CALLBANKER + 3 then
		self:sendBanker(3)
	elseif tag == BT_CALLBANKER + 4 then
		self:sendBanker(4)
	elseif tag == BT_BEGIN then
		self:PlaySound("sound_res/cli.mp3")
		self:onBeginGame()
		self.startbtn:setVisible(false)
	elseif tag == BT_AUTO then
		self:PlaySound("sound_res/cli.mp3")
		self:autoAddScore(self.is_auto)
	elseif tag == BT_READY then
		self:PlaySound("sound_res/cli.mp3")
		self:onStartGame()
		--self:switchReady()
		-- self:OnResetView()
	elseif tag == BT_NEXT then
		self:PlaySound("sound_res/cli.mp3")
		self:onNextRoundGame()
		-- self:OnResetView()
		self.btNext:setVisible(false)
	elseif tag == BT_READ then
		self:PlaySound("sound_res/cli.mp3")
		
		self:disPlaygameResult()
	elseif tag == BT_GIVEUP then

	
		self:onGiveUp()
	elseif tag == BT_LOOKCARD then
		self:_playSound(3,"kanpai.mp3")
		self.m_LookCard[3]:setVisible(true) 
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
		self:PlaySound("sound_res/cli.mp3")
		local chatPanel = require("client/game/majiang/ChatPanel"):create(false)
		self:addChild(chatPanel, nnScene.ZOrder.CHAT)
	elseif tag == BT_MENU then
		self:PlaySound("sound_res/cli.mp3")
		self:ShowMenu(not self.m_bShowMenu)
	elseif tag == BT_HELP then
		
	elseif tag == BT_SETTING then
		self:PlaySound("sound_res/cli.mp3")
		local settingPanel = require("client/game/majiang/Setting"):create(self)
		self:addChild(settingPanel, nnScene.ZOrder.SETTING)
	elseif tag == BT_BANK then
		Toast.showToast(self, "该功能尚未开放，敬请期待...", 1)
	end
end

function nnScene:onRcvChatMsg(msgTbl)
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
		-- elseif gt.isAndroidPlatform() then
		-- 	local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "playVoice", {curUrl}, "(Ljava/lang/String;)V")
		-- end
		-- self:ShowUserChat1(self:getTableIdNN(msgTbl.kPos),videoTime)
		
	else
		local chatBgNode = self.nodePlayer[self:getTableIdNN(msgTbl.kPos)]
		local _node = gt.seekNodeByName(self.currentNode, "player_"..self:getTableIdNN(msgTbl.kPos))
		
		local chatBgNode1 = self:findNodeByName("kuang",_node)

		
	
		if msgTbl.kType == gt.ChatType.FIX_MSG then
			--emojiImg:setVisible(false)
			self:ShowUserChat(self:getTableIdNN(msgTbl.kPos),gt.getLocationString("LTKey_0070_" .. msgTbl.kId),msgTbl)
		
		elseif msgTbl.kType == gt.ChatType.INPUT_MSG then
		
			self:ShowUserChat(self:getTableIdNN(msgTbl.kPos),msgTbl.kMsg)
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
			local kuang = self.nodePlayer[self:getTableIdNN(msgTbl.kPos)]:getChildByName("kuang")
			animationNode:setPosition(cc.p(kuang:getPositionX(),kuang:getPositionY()))
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
function nnScene:startVoiceSchedule(msgTbl)
	if self.voiceList == nil then
		self.voiceList = {}
	end
	table.insert(self.voiceList, {msgTbl, 0})
	gt.log("nnScene:playVoice")
	gt.dump(self.voiceList)
	if self.voiceListListener == nil then
		self.voiceListListener = gt.scheduler:scheduleScriptFunc(handler(self, self.playVoice), 1, false)
	end
end

--voicelist
function nnScene:playVoice()
	gt.log("nnScene:playVoice")
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
				self:ShowUserChat1(self:getTableIdNN(msgTbl.kPos),videoTime)
			elseif gt.isAndroidPlatform() then
				local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "playVoice", {curUrl}, "(Ljava/lang/String;)V")
				self:ShowUserChat1(self:getTableIdNN(msgTbl.kPos),videoTime)
			end
		end
	end
end

--voicelist
function nnScene:stopPlayVoice()
	self:getLuaBridge()
	if gt.isIOSPlatform() then
		local ok = self.luaBridge.callStaticMethod("AppController", "stopPlayVoice", {})
	elseif gt.isAndroidPlatform() then
		local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "stopPlayVoice", {curUrl}, "()V")
	end
end

function nnScene:ShowUserChat1(viewid,time)

	time = tonumber(time) or 30
	self._voice[viewid]:setVisible(true)
	self._voice_node[viewid]:setVisible(true)
	self._voice_nodes[viewid] = cc.CSLoader:createTimeline("yy.csb")
	self._voice_node[viewid]:runAction(self._voice_nodes[viewid])
	self._voice_nodes[viewid]:gotoFrameAndPlay(0,true)
	self._voice[viewid]:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
		self._voice_node[viewid]:stopAllActions()
		self._voice_node[viewid]:setVisible(false)
		self._voice[viewid]:setVisible(false)
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
function nnScene:ShowUserChat(viewid ,message,msg)
	if message and #message > 0 then
		--self.m_GameChat:showGameChat(false) --设置聊天不可见，要显示私有房的邀请按钮（如果是房卡模式）
		--取消上次
		if self.m_UserChat[viewid] then
			self.m_UserChat[viewid]:stopAllActions()
			self.m_UserChat[viewid]:removeFromParent()
			self.m_UserChat[viewid] = nil
		end

		if msg then
			if self.PlayerNN[viewid].sex == 2 then 
				self:PlaySound("sfx/sound_nn/chat/woman/"..msg.kId..".mp3", false)
			else
				self:PlaySound("sfx/sound_nn/chat/man/"..msg.kId..".mp3", false)
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
		gt.log("-------------viewid", viewid)
		self.m_UserChat[viewid]:addTo(self._node)

	   	if yl.GAMEDATA[6] == 6 then
			if viewid == 3 or viewid == 5 then
				self.m_UserChat[viewid]:move(self.ptChat[viewid].x - 15 , self.ptChat[viewid].y + 7)
					:setAnchorPoint(cc.p(1, 0.5))
			else
				self.m_UserChat[viewid]:move(self.ptChat[viewid].x + 13 , self.ptChat[viewid].y + 7)
					:setAnchorPoint( cc.p(0, 0.5) )
			end
			--改变气泡大小
			self.m_UserChatView[viewid]:setContentSize(self.m_UserChat[viewid]:getContentSize().width+28, self.m_UserChat[viewid]:getContentSize().height + 30)
				:setVisible(true)
		elseif yl.GAMEDATA[6] == 10 then
			if viewid == 7 or viewid == 9 then
				self.m_UserChat[viewid]:move(self.ptChat[viewid].x - 15 , self.ptChat[viewid].y - 3)
					:setAnchorPoint(cc.p(1, 0.5))
			else
				self.m_UserChat[viewid]:move(self.ptChat[viewid].x + 13 , self.ptChat[viewid].y - 3)
					:setAnchorPoint( cc.p(0, 0.5) )
			end
			--改变气泡大小
			self.m_UserChatView[viewid]:setContentSize(self.m_UserChat[viewid]:getContentSize().width+28, self.m_UserChat[viewid]:getContentSize().height + 30)
				:setVisible(true)
		end
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

function nnScene:qiangzhuang(msg, reconnectFlag)
	if gt.dumplog_nn then
		gt.dumplog_nn(msg)
	end
    -- 牛牛：服务器返回玩家看牌选庄的结果

    -- gt.MSG_S_2_C_NIUNIU_SELECT_ZHUANG = 62072

    -- kPos    //玩家位置
 
    -- QiangZhuang    //庄家模式：0：非看牌抢庄，1：看牌抢庄

    -- kPlayerHandCard[5]    //玩家看牌抢庄的前4张牌

    -- kPlayerStatus[6]    //有几个人玩

	self:clearUI()
	
	self.curPlayerStatus = (msg.kPlayerStatus[self.UsePos + 1] == 1)

	if not reconnectFlag then
	    if yl.GAMEDATA[4] == 1 then
			self.currCountdownTime = self.remainTime > 0 and self.remainTime or self.CountdownTime[1]
			self:setCountdownSchedule(self.currCountdownTime, self.clock)
		end
	end

					gt.log("----------------local CenterSendCardFlag = false")
	for i =1 , GAME_PLAYER do
		-- 准备标志
		self.m_flagReady[i]:setVisible(false)
		
		-- 庄
		self.m_BankerFlag[i] = self.nodePlayer[i]:getChildByName("zhuang")
							   :setVisible(false)
		-- 庄的框
		self.zhuangmask[i] = self.nodePlayer[i]:getChildByName("zhuangmask")
							   :setVisible(false)
		-- 抢庄时抢庄倍数
		self.player_qiangscore[i] = self.nodePlayer[i]:getChildByName("qiangtimes")
							   :setVisible(false)
		-- 抢庄倍数
		self.player_score[i] = self.nodePlayer[i]:getChildByName("times")
							   :setVisible(false)
		-- 下注分数
		self.m_betscoresbg[i] = self.nodePlayer[i]:getChildByName("betscoresbg")
							   :setVisible(false)
		self.m_betscoresvalue[i] = self.m_betscoresbg[i]:getChildByName("betscoresvalue")

	    -- 赢者标志
		self.m_UserHead[i].hg:setVisible(false)
		self.m_UserHead[i].quanquan:setVisible(false)

		-- 牌型
		self.userCard[i].cardType = self:findNodeByName("card_type",self._card[i] )
		self.userCard[i].cardType:setVisible(false)
		
		-- 分数
		self.userCard[i].roundScoreBg = self:findNodeByName("roundScoreBg",self._card[i] )
		self.userCard[i].roundScoreBg:setVisible(false)
		self.userCard[i].roundScore = self:findNodeByName("roundScore",self._card[i] )
		self.userCard[i].roundScore:setVisible(false)

		-- 已完成
		self.kanpai[i] = gt.seekNodeByName(self.currentNode, "wancheng"..i)
		self.kanpai[i]:setVisible(false)
		gt.seekNodeByName(self.currentNode, "kanpai_node"):setLocalZOrder(99)
	end
	gt.log("------------------msg.kPos", msg.kPos)
	gt.log("------------------self.UsePos", self.UsePos)
    if msg.kPos == self.UsePos or self.guancha then
    	if not self.guancha and msg.kPlayerStatus[self.UsePos + 1] == 1 then 
		    self.callbankernode:setVisible(true)
		end
	 	--for i = 1 , GAME_PLAYER do
			-- local args = {}
			-- args.kShow = 0
			-- args.kPos = msg.kPos
			-- args.kPlayerStatus = msg.kPlayerStatus
			-- args.kPlayerHandCard = {}
			-- for j = 1, 5 do
			-- 	args.kPlayerHandCard[j] = msg["kPlayerHandCard"][j]
			-- end 	
			-- gt.log("--------args")
			-- dump(args)
			-- if args.kShow == 1 then
			-- 	self.sendCardFlag = true 

			-- 	args.kShow= 0
			-- 	self:sendCard_nn(args)
			-- 	args.kShow = 1
			-- 	self:sendCard_nn(args)	
			-- elseif args.kShow == 0 then
				-- self:sendCard_nn(args, true)
			--end
			gt.log("-------------chair1", chair)
			dump(self.m_cbPlayStatus)
	        if not (yl.GAMEDATA[2] == 4 or (yl.GAMEDATA[1] == 0 and yl.GAMEDATA[2] == 2))  then 
				local status = msg.kPlayerStatus
				for i=1 , #status do
					self.m_cbPlayStatus[self:getTableIdNN(i-1)] = status[i]
					log("....",self.m_cbPlayStatus[i],i,self:getTableIdNN(i-1))
				end

				if not self.CenterSendCardFlag then	
					self.CenterSendCardFlag = true
					gt.log("----------------CENTER_SEND_CARD5")
					self:PlaySound("sound_res/CENTER_SEND_CARD.mp3")
				end
		        local delayCount = 1
				self.spriteCard  = {}
		        for i = 1, GAME_PLAYER do
					self.spriteCard[self:getTableIdNN(i - 1)] = {}
			gt.log("-------------self:getTableIdNN(i - 1)", self:getTableIdNN(i - 1))
		            if self.m_cbPlayStatus[self:getTableIdNN(i - 1)] == 1 then 
			            for index = 1 , 5 do 
							self.sendCardFlag = true 
							self.selectBankerFlag = true 
		                    self:SendCard(self:getTableIdNN(i - 1),index,delayCount*0.1,false,function ( )
		                    	if index == 5 then
									if MY_VIEWID == self:getTableIdNN(msg.kPos) then
										local cardData = msg.kPlayerHandCard
										for i = 1 , #cardData do
											log("--------cardData[i]", cardData[i])
											log("poker/"..gt.tonumber(cardData[i])..".png")
											-- self._card[MY_VIEWID]:findNodeByName("card"..i):loadTexture("poker/"..gt.tonumber(cardData[i])..".png")
											-- self:findNodeByName("card"..i, self._card[MY_VIEWID]):loadTexture("poker/"..gt.tonumber(cardData[i])..".png")
											-- self:flopAnimation(self:findNodeByName("card"..i, self._card[MY_VIEWID]), "poker/"..gt.tonumber(cardData[i])..".png")
											self:flopAnimation(self.userCard[MY_VIEWID].card[i], "poker/"..gt.tonumber(cardData[i])..".png")
											
										end
									end
								end
		                    end)
			            end
		            	delayCount = delayCount + 1
		            end
		        end
		    end

			self:clearText()
			if not reconnectFlag then
		    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text1)
			else
		    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text1, true)
			end
		--end
	end
end

function nnScene:noifyqiangzhuang(msg)
	if gt.dumplog_nn then
		gt.dumplog_nn(msg)
	end
-- gt.MSG_S_2_C_NIUNIU_NOIFY_QIANG_ZHUNG = 62080,              //抢庄通知
-- kPos : 0 - 5 叫分位置
-- kQiangScore:  0 -3 叫的分数

	local timeshow = false
	if self.clock:isVisible() then
		timeshow = true
	end
	
	self:clearUI("noifyqiangzhuang")

	if timeshow then
		self.clock:setVisible(true)
	end

	if msg.kPos == self.UsePos then
		self:clearText()
    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text2)
		self.callbankernode:setVisible(false)
	else
		if self.guancha then
	    	self:ActionText(true, self.text7)
	    end
	end

	local score = msg.kQiangScore
	local p = self:getTableIdNN(msg.kPos)
	local node = self.player_qiangscore[p]
	node:loadTexture("nn/qiang"..score.."times.png")
	node:setVisible(true)
end

function nnScene:game_start(msg, reconnectFlag)
    -- 牛牛：服务器发送游戏开始消息

    -- MSG_S_2_C_NIUNIU_START_GAME =  62077

    -- kZhuangPos  //庄家位置

    -- kScoreTimes  //玩家选庄分数

    -- kQiangScore  //所有玩家选庄分数

    -- kplayerTuiScore  //所有玩家推注分数

    -- kPlayerStatus[6]  //有几个人玩

    -- kPlayerHandCard[5]   //玩家手牌

	if gt.dumplog_nn then
		gt.dumplog_nn(msg)
	end
	
	self.sendCardFlag = false

	self:clearUI()
	
	self.curPlayerStatus = (msg.kPlayerStatus[self.UsePos + 1] == 1)

	if msg.kPlayerTuiScore then
		self.xianjiatuizhuScore = msg.kPlayerTuiScore[self.UsePos + 1]
	end

	if not self.xianjiatuizhuScore or self.xianjiatuizhuScore == 0 then
		self.btn_cell_score_xianjiatuizhu:setVisible(false)
	else
		self.btn_cell_score_xianjiatuizhu:setVisible(true)
		self.btn_cell_score_xianjiatuizhu:setPositionX(betScoresPositionX[table.nums(self.currentBetScores)][table.nums(self.currentBetScores) + 1])
		self.btn_cell_score_xianjiatuizhu:setTitleText(self.xianjiatuizhuScore.."分")
	end

	if not reconnectFlag then
	    if yl.GAMEDATA[4] == 1 then
			self.currCountdownTime = self.remainTime > 0 and self.remainTime or self.CountdownTime[2]
			self:setCountdownSchedule(self.currCountdownTime, self.clock)
		end
	end

	self:ActionText(false,self.text9)
	self:ActionText(false,self.text10)
	self:ActionText(false,self.text1)
	self:ActionText(false,self.text2)

	for i =1 , GAME_PLAYER do
		-- 准备标志
		self.m_flagReady[i]:setVisible(false)
		
		-- 庄
		self.m_BankerFlag[i] = self.nodePlayer[i]:getChildByName("zhuang")
							   :setVisible(false)
		-- 庄的框
		self.zhuangmask[i] = self.nodePlayer[i]:getChildByName("zhuangmask")
							   :setVisible(false)

		-- 抢庄时抢庄倍数
		self.player_qiangscore[i] = self.nodePlayer[i]:getChildByName("qiangtimes")
							   :setVisible(false)
		-- 抢庄倍数
		self.player_score[i] = self.nodePlayer[i]:getChildByName("times")
								:setVisible(false)

		-- 下注分数
		self.m_betscoresbg[i] = self.nodePlayer[i]:getChildByName("betscoresbg")
								:setVisible(false)
		self.m_betscoresvalue[i] = self.m_betscoresbg[i]:getChildByName("betscoresvalue")

	    -- 赢者标志
		self.m_UserHead[i].hg:setVisible(false)
		self.m_UserHead[i].quanquan:setVisible(false)

	    -- 牌型
		self.userCard[i].cardType = self:findNodeByName("card_type",self._card[i] )
		self.userCard[i].cardType:setVisible(false)

		-- 分数
		self.userCard[i].roundScoreBg = self:findNodeByName("roundScoreBg",self._card[i] )
		self.userCard[i].roundScoreBg:setVisible(false)
		self.userCard[i].roundScore = self:findNodeByName("roundScore",self._card[i] )
		self.userCard[i].roundScore:setVisible(false)

		-- 已完成
		self.kanpai[i] = gt.seekNodeByName(self.currentNode, "wancheng"..i)
		self.kanpai[i]:setVisible(false)
		gt.seekNodeByName(self.currentNode, "kanpai_node"):setLocalZOrder(99)
	end

	local m_wBankerUser = msg.kZhuangPos < GAME_PLAYER and msg.kZhuangPos or 0
	self.m_wBankerUser = m_wBankerUser
	self.m_betscoresbg[self:getTableIdNN(m_wBankerUser)]:setVisible(false)

	local function sendcards( )
		if yl.GAMEDATA[2] == 3 then 
			-- 明牌下注
			if not reconnectFlag then
				if gt.curCircle > 1 then
					local status = msg.kPlayerStatus
					for i=1 , #status do
						self.m_cbPlayStatus[self:getTableIdNN(i-1)] = status[i]
						log("....",self.m_cbPlayStatus[i],i,self:getTableIdNN(i-1))
					end

					local cardData = msg.kPlayerHandCard

			        local delayCount = 1
					self.spriteCard  = {}
								gt.log("----------------CENTER_SEND_CARD6")
					self:PlaySound("sound_res/CENTER_SEND_CARD.mp3")
			        for i = 1, GAME_PLAYER do
						self.spriteCard[self:getTableIdNN(i - 1)] = {}
			            if self.m_cbPlayStatus[self:getTableIdNN(i - 1)] == 1 then 
				            for index = 1 , 5 do 
								self.sendCardFlag = true 
								self.selectBankerFlag = true 
			                    self:SendCard(self:getTableIdNN(i - 1),index,delayCount*0.1,false,function ( )
									for i = 1 , #cardData do
										log("--------cardData[i]", cardData[i])
										log("poker/"..gt.tonumber(cardData[i])..".png")
										-- self._card[MY_VIEWID]:findNodeByName("card"..i):loadTexture("poker/"..gt.tonumber(cardData[i])..".png")
										-- self:flopAnimation(self:findNodeByName("card"..i, self._card[MY_VIEWID]), "poker/"..gt.tonumber(cardData[i])..".png")
										self:flopAnimation(self.userCard[MY_VIEWID].card[i], "poker/"..gt.tonumber(cardData[i])..".png")

									end
			                    end)
				            end
			            	delayCount = delayCount + 1
			            end
			        end
				end
			else
				local status = msg.kPlayerStatus
				for i=1 , #status do
					self.m_cbPlayStatus[self:getTableIdNN(i-1)] = status[i]
					log("....",self.m_cbPlayStatus[i],i,self:getTableIdNN(i-1))
				end

				local cardData = msg["kPlayerHandCard"..self.UsePos]

								gt.log("----------------CENTER_SEND_CARD7")
				self:PlaySound("sound_res/CENTER_SEND_CARD.mp3")
		        local delayCount = 1
				self.spriteCard  = {}
		        for i = 1, GAME_PLAYER do
					self.spriteCard[self:getTableIdNN(i - 1)] = {}
		            if self.m_cbPlayStatus[self:getTableIdNN(i - 1)] == 1 then 
			            for index = 1 , 5 do 
							self.sendCardFlag = true 
							self.selectBankerFlag = true 
		                    self:SendCard(self:getTableIdNN(i - 1),index,delayCount*0.1,false,function ( )
								for i = 1 , #cardData do
									log("--------cardData[i]", cardData[i])
									log("poker/"..gt.tonumber(cardData[i])..".png")
									-- self._card[MY_VIEWID]:findNodeByName("card"..i):loadTexture("poker/"..gt.tonumber(cardData[i])..".png")
									-- self:flopAnimation(self:findNodeByName("card"..i, self._card[MY_VIEWID]), "poker/"..gt.tonumber(cardData[i])..".png")
									self:flopAnimation(self.userCard[MY_VIEWID].card[i], "poker/"..gt.tonumber(cardData[i])..".png")

								end
		                    end)
			            end
		            	delayCount = delayCount + 1
		            end
		        end
			end
		end
	end

	if reconnectFlag then
		if m_wBankerUser ~= self.UsePos then
			if msg.kPlayerStatus[self.UsePos + 1] == 0 then
				self:showAddScoreBtn(false)
			else
				self:showAddScoreBtn(not self.guancha)
			end
			self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text4, true)
		else
			self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text3, true)
		end
		sendcards()
	else
		local betSoundFlag = false
		local QiangScore = clone(msg.kQiangScore)
		table.sort(QiangScore, function(a, b)
			return a > b
		end)

		local maxQiangScore = QiangScore[1]

		for i , v in pairs(msg.kQiangScore) do
			local pos = i - 1
			if v == maxQiangScore then
				self:_playSound_nn(0, "GAME_SELECTBANKER")
				local function callback( )
					if pos == m_wBankerUser then
						self.m_BankerFlag[self:getTableIdNN(m_wBankerUser)]:setVisible(true)
						local p = self:getTableIdNN(m_wBankerUser)
						local node = self.player_score[p]
						node:loadTexture("nn/"..msg.kScoreTimes.."times.png")
						node:setVisible(true)
						self.player_qiangscore[self:getTableIdNN(m_wBankerUser)]:setVisible(false)
						self.zhuangmask[self:getTableIdNN(pos)]:setVisible(true)
					else
						self.zhuangmask[self:getTableIdNN(pos)]:setVisible(false)
					end

					if m_wBankerUser ~= self.UsePos then
						if msg.kPlayerStatus[self.UsePos + 1] == 0 then
							self:showAddScoreBtn(false)
						else
							self:showAddScoreBtn(not self.guancha)
						end
						if not betSoundFlag then
							betSoundFlag = true
							self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text4)
						end
					else
						self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text3)
					end
					sendcards()
				end
				if yl.GAMEDATA[1] == 0 and gt.curCircle > 1 then
					if self.zhuangmask[self:getTableIdNN(pos)] then
						callback()
					end
				else
					if self.zhuangmask[self:getTableIdNN(pos)] then
						self.zhuangmask[self:getTableIdNN(pos)]:setVisible(true)
						self.zhuangmask[self:getTableIdNN(pos)]:runAction(
							cc.Sequence:create(
								cc.Sequence:create(cc.Blink:create(1, 5)),
								cc.CallFunc:create(
									function ()
										callback()
									end
								)
							)
						)
					end
				end
			end
		end
	end
end

function nnScene:switch()

	self:ActionText()

end

--发牌
function nnScene:SendCard(viewid,index,fDelay,noAnimation,callback)
	if gt.dumplog_nn then
		gt.dumplog_nn("-------------viewid"..viewid)
	end

	gt.log("-------------viewid", viewid)
	gt.log(debug.traceback())
	if not viewid then
		return
	end

	if viewid < 0 or viewid > GAME_PLAYER then  return end
	local fInterval = 0.1

	local nodeCard = self.userCard[viewid]
	nodeCard.area:setVisible(true)

	log("viewid......",viewid)

	local p
	if yl.GAMEDATA[6] == 6 then
		p = cc.p(self.ptCard[viewid].x + (viewid==MY_VIEWID and 144 or 35)*(index - 3),self.ptCard[viewid].y)
	elseif yl.GAMEDATA[6] == 10 then
		p = cc.p(self.ptCard[viewid].x + (viewid==MY_VIEWID and 144 or 21)*(index - 3),self.ptCard[viewid].y)
	end

	if noAnimation then
		if gt.dumplog_nn then
			gt.dumplog_nn("-------------noAnimation")
		end
		self._card[viewid]:setVisible(true)
		-- self:findNodeByName("card"..index, self._card[viewid]):setVisible(true)

		self.userCard[viewid].card[index]:setVisible(true)
		
		if index == 5 then 
			if not self.sendCardFlag and not self.guancha then
				self.nodeopencard:setVisible(true)
			end
			self.sendCardFlag = false
			if not self.selectBankerFlag then
				self:clearText()
				self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text6)
			end
			self.selectBankerFlag = false
		end
		
		if callback then
			callback()
		end
	else
		if gt.dumplog_nn then
			gt.dumplog_nn("-------------Animation")
		end
		gt.log("--------------viewid", viewid)
		gt.log("--------------MY_VIEWID", MY_VIEWID)
		if viewid == MY_VIEWID then 
			if not self.sendCardFlag and not self.guancha then
		gt.log("--------------show")
				self.nodeopencard:setVisible(true)
			end
			self.sendCardFlag = false
		end
		if not self.selectBankerFlag then
			self:clearText()
			self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text6)
		end
		self.selectBankerFlag = false
		if gt.dumplog_nn then
			gt.dumplog_nn("--------------show1")
		end
		if nodeCard and nodeCard.card and nodeCard.card[index] then
			if gt.dumplog_nn then
				gt.dumplog_nn("--------------show2")
			end
			self.spriteCard[viewid][index] = nodeCard.card[index]
			if self.spriteCard and self.spriteCard[viewid] and self.spriteCard[viewid][index] then
				if gt.dumplog_nn then
					gt.dumplog_nn("--------------show3")
				end
				self.spriteCard[viewid][index]:stopAllActions()
				self.spriteCard[viewid][index]:setScale(0.1)
				self.spriteCard[viewid][index]:setVisible(false)
				self.spriteCard[viewid][index]:setTexture("poker/56.png")
				self.spriteCard[viewid][index]:move(display.cx, display.cy)
				self.spriteCard[viewid][index]:runAction(
					cc.Sequence:create(
						cc.DelayTime:create(fDelay),
						cc.CallFunc:create(
							function ()
								if self.spriteCard and self.spriteCard[viewid] and self.spriteCard[viewid][index] then
									self.spriteCard[viewid][index]:setVisible(true)
								end
							end
							),
							cc.Spawn:create(
								cc.ScaleTo:create(0.25,viewid==MY_VIEWID and 0.9 or (yl.GAMEDATA[6] == 6 and 0.45 or 0.27)),
								cc.MoveTo:create(0.25, p)),
								cc.CallFunc:create(function() 
									if self.spriteCard and self.spriteCard[viewid] and self.spriteCard[viewid][index] then
										self.spriteCard[viewid][index]:setScale(viewid==MY_VIEWID and 0.9 or (yl.GAMEDATA[6] == 6 and 0.45 or 0.27))
										if viewid == MY_VIEWID then 
											if index == 5 then 
												self._card[viewid]:setVisible(true)
												if callback then
													callback()
												end
											end
										end
									end
							 end)))
			end
		end
	end

end

function nnScene:setCard(pos,data)

	for i = 1 , 5 do
		-- self:findNodeByName("card"..i, self._card[pos]):setTexture("poker/56.png")
		self.userCard[pos].card[i]:setTexture("poker/56.png")
		self.userCard[pos].card[i]:setVisible(true)

		self._card[pos]:setVisible(false)
	end

	for i =1 , 5 do
		-- self:findNodeByName("card"..i, self._card[pos]):setTexture("poker/"..gt.tonumber(data[i])..".png")
		self.userCard[pos].card[i]:setTexture("poker/"..gt.tonumber(data[i])..".png")
		self.userCard[pos].card[i]:setVisible(true)
				-- self:flopAnimation(self:findNodeByName("card"..i, self._card[pos]), "poker/"..gt.tonumber(data[i])..".png")
		self._card[pos]:setVisible(true)
		-- self:findNodeByName("card"..i, self._card[pos]):setVisible(false)
	end

end

function nnScene:disBeginBtn(pos, name)
	if not pos then return end
	if pos == self.UsePos then 
		self.startbtn:setVisible(true)
		self:clearText()
		self:ActionDian(self.readyTipsText, false)
		self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text9)
	elseif pos ~= 21 and pos ~= GAME_PLAYER then
		self:clearText()
		self.startGameUserName = name
		self:ActionDian(self.readyTipsText, false)
		self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text10)
	elseif pos == 21 or pos == GAME_PLAYER  then 
		self.startbtn:setVisible(false)
		self:ActionDian(self.readyTipsText, false)
    	self:ActionText(false,self.text9)
		self:ActionText(false,self.text10)
	end
end

function nnScene:showPlayerinfo(i)

	if i < 0 or i > GAME_PLAYER then return end
	self.playerInfo:setVisible(true)
	local node = self.playerInfo
	node:getChildByName("name"):setString("昵称："..self.PlayerNN[i].name)
	node:getChildByName("ID"):setString("ID："..self.PlayerNN[i].id)
	node:getChildByName("ip"):setString("IP："..self.PlayerNN[i].ip)
	node:getChildByName("score"):setVisible(false) --setString("金币："..self.PlayerNN[i].Coins)
	local data = self.PlayerNN[i].url
	if node:getChildByName("__ICON___") then  node:getChildByName("__ICON___"):removeFromParent() end
	if type(data) ~= nil and  string.len(data) > 10 then
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
	      		if args.done  and self then
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

function nnScene:_playSound(id,str)

	if self.PlayerNN[id].sex == 2 then
		self:PlaySound("sound_res/woman/"..str)
	else
		self:PlaySound("sound_res/man/"..str)
	end
end

function nnScene:_playSound_nn(id,str,filetype)
	if self.PlayerNN[id] and self.PlayerNN[id].sex then
		if self.PlayerNN[id].sex == 2 then
			gt.soundEngine:playEffect("sound_nn/woman/"..str, false, true, filetype or "mp3")
		else
			gt.soundEngine:playEffect("sound_nn/man/"..str, false, true, filetype or "mp3")
		end
	else
		gt.soundEngine:playEffect("sound_nn/"..str, false, true, filetype or "mp3")
	end
end

function nnScene:ActionText(bool, node, nosound)
	if node and not self.guancha then 
		local diancount = 0 
		if node:getTag() == 10 then
			diancount = 6
		else
			diancount = 3
		end
		node:setVisible(bool)
		if not bool then
			if self.dianAction[node:getTag()] then
				_scheduler:unscheduleScriptEntry(self.dianAction[node:getTag()])
				self.dianAction[node:getTag()] = nil
			end
			self.clock:setVisible(false)
		else
			if self.dianAction[node:getTag()] then
				_scheduler:unscheduleScriptEntry(self.dianAction[node:getTag()])
				self.dianAction[node:getTag()] = nil
			end
			for j = 1 , diancount do node:getChildByName("dian_"..j):setVisible(false)  end
			local i = 0
			self.dianAction[node:getTag()] = _scheduler:scheduleScriptFunc(function()
				i = i +1 
				
				if i == diancount + 1 then i = 1 for j = 1 , diancount do node:getChildByName("dian_"..j):setVisible(false)  end end
				node:getChildByName("dian_"..i):setVisible(true)
			end,0.5,false)
			if node:getTag() <= 8 and yl.GAMEDATA[4] == 1 and (not self.guancha) then
				self.clock:setVisible(bool)
			else
				self.clock:setVisible(false)
			end
			-- self.clock:setPosition(ptClock[node:getTag()] or cc.p(0, 0))
			if node:getTag() == 7 then
			   	if yl.GAMEDATA[6] == 6 then
					self.clock:setPositionY(-75)
			   	elseif yl.GAMEDATA[6] == 10 then
			   		node:setPositionY(150)
					self.clock:setPositionY(142)
			   	end
			else
				self.clock:setPositionY(-8)
			end
			if node:getTag() == 10 then
   				self:findNodeByName("createrName"):setString("等待"..(self.startGameUserName or ""))	
			end
			if not nosound then
				if node:getTag() == 1 then
					self:_playSound_nn(gt.MY_VIEWID, "selectbanker")
				elseif node:getTag() == 4 then
					gt.log("-----------------bet")
					gt.log(debug.traceback())
					self:_playSound_nn(gt.MY_VIEWID, "bet")
				end
			end
		end
	end
end

function nnScene:ActionDian(node, bool)
	if not self.guancha and gt.curCircle > 0 then
		node:setVisible(false)
		return
	end
	node:setVisible(bool)
	if not bool then
		if self.actiondian then
			_scheduler:unscheduleScriptEntry(self.actiondian)
			self.actiondian = nil
		end
	else
		if self.actiondian then
			_scheduler:unscheduleScriptEntry(self.actiondian)
			self.actiondian = nil
		end

		for j = 1 , 6 do node:getChildByName("dian_"..j):setVisible(false)  end
		if self.actiondian then
			_scheduler:unscheduleScriptEntry(self.actiondian)
			self.actiondian = nil
		end
		local i = 0
		self.actiondian = _scheduler:scheduleScriptFunc(function()
			i = i +1 
			
			if i == 7 then i = 1 for j = 1 , 6 do node:getChildByName("dian_"..j):setVisible(false)  end end
			node:getChildByName("dian_"..i):setVisible(true)
		end,0.5,false)	
	end
end

function nnScene:addPlayer(args)
	if not args then  -- init user
		local pos = self:getTableIdNN(self.UsePos)
		if gt.dumplog_nn then
			gt.dumplog_nn(args)
		end

		if not pos then
			return
		end

		if not self.nodePlayer[pos] then
			return
		end

		self.nodePlayer[pos]:setVisible(true)
		
		self.playersDataNN[pos] = args
		self.PlayerNN[pos] = {}
		self.m_UserHead[pos].score:setString(self.data.kScore)
		self.PlayerNN[pos].sex = gt.userSex
		self.m_cbPlayStatus[pos] = 1
		if self.data.kReady == 1 then 
			local m = {}
			m.kPos = self.UsePos
			self:RcvReady(m)
		else
			self.m_flagReady[pos]:setVisible(false)
		end
		-- self.readybtn:setVisible(self.data.kReady ~= 1)
		
		self.PlayerNN[pos].score = self.data.kScore
		self.PlayerNN[pos].name = gt.wxNickName
		self.PlayerNN[pos].score = self.data.kScore
		self.PlayerNN[pos].id = gt.playerData.uid
		self.PlayerNN[pos].ip = self.data.kUserIp
		self.PlayerNN[pos].Coins = self.data.kCoins
		self.m_UserHead[pos].name:setString(gt.wxNickName)
		
		local url 	= cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl" )
		self.PlayerNN[pos].url = url
		local icon = self.nodePlayer[pos]:getChildByName("kuang")
		local _name ,b = string.gsub(url, "[/.:+]", "")
		local iamge = gt.imageNamePath(url)
	  	if iamge then
	  		local _node = display.newSprite("nn/head.png")
			self.m_UserHead[pos].head = gt.clippingImage(iamge,_node,false)
			self.m_UserHead[pos].head:setLocalZOrder(20)
			if self.nodePlayer[pos]:getChildByName(_name) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(_name):removeFromParent() end
			self.nodePlayer[pos]:addChild(self.m_UserHead[pos].head)
			self:findNodeByName("zhuang", self.nodePlayer[pos]):setLocalZOrder(21)
			self.m_UserHead[pos].head:setName(_name)
			self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
	  	else
		  	if type(url) ~= nil and  string.len(url) > 10 then
				self.urlName[pos] = string.gsub(url, "[/.:+]", "")
		  		local function callback(args)
		      		if args.done and self then
						local _node = display.newSprite("nn/head.png")
						self.m_UserHead[pos].head = gt.clippingImage(args.image,_node,false)
						self.m_UserHead[pos].head:setLocalZOrder(20)
						self:findNodeByName("zhuang", self.nodePlayer[pos]):setLocalZOrder(21)
						if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
						self.nodePlayer[pos]:addChild(self.m_UserHead[pos].head)
						self.m_UserHead[pos].head:setName(self.urlName[pos])
						self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
					end
		        end
			    gt.downloadImage(url,callback)	
			end
	  	end
	else
		if gt.dumplog_nn then
			gt.dumplog_nn(args)
		end
		local pos = self:getTableIdNN(args.kPos)

		self.nodePlayer[pos]:setVisible(true)
		
		self.playersDataNN[pos] = args
		self.PlayerNN[pos] = {}
		self.m_UserHead[pos].score:setString(args.kScore)
		self.PlayerNN[pos].sex = args.kSex
		self.m_cbPlayStatus[pos]= 1
		self.PlayerNN[pos].name = args.kNike
		self.PlayerNN[pos].id = args.kUserId
		self.PlayerNN[pos].ip = args.kIp
		self.PlayerNN[pos].score = args.kScore
		self.PlayerNN[pos].Coins = args.kCoins
		
		if args.kReady == 1 then
			self:RcvReady(args)
		else
			self.m_flagReady[pos]:setVisible(false)
		end
		
		self.m_UserHead[pos].name:setString(args.kNike)
		self.PlayerNN[pos].url = args.kFace
		self.PlayerNN[pos].score = args.kScore
		local url 	= self.PlayerNN[pos].url
		local icon = self.nodePlayer[pos]:getChildByName("kuang")
		local iamge = gt.imageNamePath(url)
		self.urlName[pos] = string.gsub(url, "[/.:+]", "")
	  	if iamge then
	  		local _node = display.newSprite("nn/head.png")
			self.m_UserHead[pos].head = gt.clippingImage(iamge,_node,false)
			self.m_UserHead[pos].head:setLocalZOrder(20)
			self:findNodeByName("zhuang", self.nodePlayer[pos]):setLocalZOrder(21)
			if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
			self.nodePlayer[pos]:addChild(self.m_UserHead[pos].head)
			self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
	  	else
  		 	if type(url) ~= nil and string.len(url) > 10 then
		  		local function callback(args)
		      		if args.done and self then
						local _node = display.newSprite("nn/head.png")
						self.m_UserHead[pos].head = gt.clippingImage(args.image,_node,false)
						self.m_UserHead[pos].head:setLocalZOrder(20)
						self:findNodeByName("zhuang", self.nodePlayer[pos]):setLocalZOrder(21)
						if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
						self.nodePlayer[pos]:addChild(self.m_UserHead[pos].head)
						self.m_UserHead[pos].head:setName(self.urlName[pos])
						self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
					end
		        end
			   	
			    gt.downloadImage(url,callback)
			end
	  	end
	end
	self:setBtnShare()
end

function nnScene:GameLayerRefresh(args)
    self.wanfa = self:findNodeByName("txt_playmode")
    self.moshi = self:findNodeByName("txt_selectmode")
    self.jushu = self:findNodeByName("txt_roundCount")
    self.roomId = self:findNodeByName("txt_roomID")

    gt.deskId = self.data.kDeskId
    self.roomId:setString("房号："..self.data.kDeskId or "000000")

    local str = ""
    if yl.GAMEDATA[1] == 0 then 
		str = "玩法：轮流坐庄"
    elseif yl.GAMEDATA[1] == 1 then
    	str = "玩法：看牌抢庄"
    end
	self.wanfa:setString(str)

	str = ""
	if yl.GAMEDATA[2] == 0 then
		str = "模式：普通模式1 "
	elseif yl.GAMEDATA[2] == 1 then 
		str = "模式：普通模式2 "
	elseif yl.GAMEDATA[2] == 2 then 
		str = "模式：扫雷模式 "
	elseif yl.GAMEDATA[2] == 3 then 
		str = "模式：明牌下注 "
	elseif yl.GAMEDATA[2] == 4 then 
		str = "模式：暗牌下注 "
	end
	self.moshi:setString(str)

	self.MaxCircle = args.kMaxCircle
    local strcount = 0 .. " / " .. args.kMaxCircle
    if strcount then
    	self.jushu:setString("局数："..strcount)
	end

	self.sharebtn:setVisible(true)
end

function nnScene:shareWx()
    local str = ""

    if yl.GAMEDATA[2] == 0 then
		str = "普通模式1"
	elseif yl.GAMEDATA[2] == 1 then 
		str = "普通模式2"
	elseif yl.GAMEDATA[2] == 2 then 
		str = "扫雷模式"
	elseif yl.GAMEDATA[2] == 3 then 
		str = "明牌下注"
	elseif yl.GAMEDATA[2] == 4 then 
		str = "暗牌下注"
	end

	local playerCount = 0
	for i , v in pairs(self.m_cbPlayStatus) do
		if v == 1 then
			playerCount = playerCount + 1
		end
	end
	
	str = str..(yl.GAMEDATA[6] == 6 and "，"..playerCount.."/6人" or "，"..playerCount.."/10人")
		..(yl.GAMEDATA[1] == 0 and "，轮流坐庄" or "，看牌抢庄")
		..(yl.GAMEDATA[4] == 1 and "，托管" or "")
		..(yl.GAMEDATA[3] == 1 and "，花样玩法" or "")
		..(yl.GAMEDATA[9] == nil and "" or (yl.GAMEDATA[9] == 1 and "，牛牛4倍" or (yl.GAMEDATA[2] ~= 2 and "，牛牛3倍" or "")))
		..(yl.GAMEDATA[10] == nil and "" or (yl.GAMEDATA[10] == 0 and "" or "，"..yl.GAMEDATA[10].."倍推注"))

	local shareTxt = "局数："..self.MaxCircle.."，"..str

    local txt = self.data.kDeskId.."，牛牛，"..str

    gt.log(shareTxt)
    gt.log(txt)

    local url = string.format(gt.HTTP_INVITE, gt.nickname or gt.playerNickname, self.PlayerNN[gt.MY_VIEWID] == nil and gt.playerHeadURL or (self.PlayerNN[gt.MY_VIEWID].url or gt.playerHeadURL), self.data.kDeskId, self.data.kDeskId.."，牛牛，"..shareTxt)
    gt.log(url)
	Utils.shareURLToHY(url,txt,shareTxt,function(ok)
		if ok == 0 then 
			Toast.showToast(self, "分享成功", 2)
		end
	end)
end

function nnScene:renovate(msg)

	if gt.dumplog_nn then
		gt.dumplog_nn(msg)
	end
	if msg.kCurCircle == 1 then
		self:_playSound_nn(0, "GAME_START")
		self.startbtn:setVisible(false)
	end
	gt.curCircle = msg.kCurCircle
	gt.CurMaxCircle = msg.kCurMaxCircle
	gt.log("刷新局数______________")
	if msg.kCurCircle > 0 then 
		self.gameBegin = true    -- 游戏已经开始啦

		self:setBtnShare()

		self.sendCardFlag = false

		self:ActionDian(self.lookonTipsText, false)

	    if self.guancha then
	    	self.lookonImg:setVisible(true)
	    else
			self.lookonImg:setVisible(false)
			self:ActionDian(self.readyTipsText, false)
	    end
	else
		self.lookonImg:setVisible(false)
	end
	self.result_jushi = msg.kCurCircle.."/"..msg.kCurMaxCircle
	gt.log(self.result_jushi)
	if self.jushu and msg.kCurCircle and msg.kCurMaxCircle then self.jushu:setString("局数："..msg.kCurCircle.." / "..msg.kCurMaxCircle) end

end

function nnScene:GameData(msg)

	if gt.dumplog_nn then
		gt.dumplog_nn(msg)
	end
	if msg.kSubId == 2 then -- 小结算
		--if not self.action and not self.action1 and not self.action2 and self.compareidx == 0  then 
			self:gameEnd(msg)
		--else
			self.min_result = msg
		--end
	end
	
end

function nnScene:gameEnd(msg)
	
	-- gt.soundEngine:stopMusic()
	--self:KillGameClock()
   	-- self.currentNode:getChildByName("bg"):stopAllActions()
   	self:stopAllActions()
    --self:switchReady()
    
 	-- ccccc

    --清理界面
    for i = 1 ,GAME_PLAYER do
   		self.m_UserHead[self:SwitchViewChairIDNN(i-1)].score:setString(msg.kTotalScore[i])
   		self.PlayerNN[self:SwitchViewChairIDNN(i-1)].score = msg.kTotalScore[i]
     end

    --self:removeActionHuo()
    --self:StopCompareCard()
    --self:SetCompareCard(false)
    --self.m_ChipBG:setVisible(false)
    --self.nodeButtomButton:setVisible(false)
  
  
 --    local savetype = {}
  
 --    local MaxResult = false
 --    if msg.kFinalDw == 1 then
 --        MaxResult   = true
 --    end

 --    --用户扑克
 --    local cbCardData = {}
 --    for i = 1, GAME_PLAYER do

 --        cbCardData[i] = {}
 --       -- local data = msg.kCardData..(i-1)
 --        local data = msg["kCardData"..i-1]
 --        for j = 1, 3 do
 --            cbCardData[i][j] = data[j] -- 用户扑克
            
 --        end
 --    end

   	
 --   	gt.dumplog_nn("userpos.......",self.UsePos)

 --    local bool1 = true
 --    local bool2 = true
 --    local win_id = 21
 --    local _palysoundWin = true
 --    for i =1 , GAME_PLAYER do
 --            local cardIndex = {}
 --            local bool 

 --            for k = 1 , 3 do

 --                cardIndex[k] = cbCardData[i][k]
 --                gt.dumplog_nn("cardData............",cardIndex[k])
 --                log("cardData............",cardIndex[k])
 --                if cardIndex[k] == 0 or cardIndex[k] == 0xff then
 --                        bool = true 
 --                else
 --                        bool = false
 --                end
 --            end

 --            local viewid = self:SwitchViewChairIDNN(i-1)
 --            gt.dumplog_nn("viewid....",viewid)
 --        	gt.log("viewid.........",viewid)
 --            self:SetUserCard(viewid, cardIndex,bool)

 --            if msg.kGameScore[i] < 0 then 
 --                self:SetUserCardType(viewid, msg.kCardType[i])
 --            else
 --                self:SetUserCardType1(viewid, msg.kCardType[i])
 --            end
           
 --    end
    

	-- --  移动筹码
 --    for j = 1, GAME_PLAYER do
 --        local viewid = self:SwitchViewChairIDNN(j-1)
 --        if msg.kGameScore[j] ~= 0 then
 --            if msg.kGameScore[j] > 0 then
 --                win_id = viewid
 --                self:SetUserTableScore1(viewid,msg.kGameScore[j])
              
 --                if viewid == MY_VIEWID then
 --                    log("播放胜利音乐")
 --                    self:my_win(true)
 --                    self:PlaySound("sound_res/GAME_WIN.wav")
 --                   _palysoundWin = true
 --                else
 --                    _palysoundWin = false
 --                end
 --            else
 --                self:SetUserTableScore1(viewid,msg.kGameScore[j])
 --            end

 --          	self.nodePlayer[viewid]:setVisible(true)
 --        else
 --            self:SetUserTableScore1(viewid)
 --        end
 --        if msg.kGiveUp[j] == 1 then self.qi_pai[viewid]:setVisible(true) end
 --    end




    -- local node = self._node:getChildByName("TotalScore")
    -- node:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()

    --     self:WinTheChip(win_id,MaxResult,_palysoundWin) -- 飞金币
    --     end)))

    -- if self.qipai or self.guancha then -- 自己
    --     self:SetUserCardType(3)
    -- end

   
    -- self.readybtn:setVisible(not MaxResult)
   	-- local m = {}
    -- m["kCurCircle"] = 15
    -- self:clock_time(m)
	if GAME_PLAYER == 6 then
    	self.m_cbPlayStatus = {0, 0, 0, 0, 0, 0}
	elseif GAME_PLAYER == 10 then
    	self.m_cbPlayStatus = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	end

end
function nnScene:RcvReady(args) -- csw 

	if gt.dumplog_nn then
		gt.dumplog_nn(args)
	end
	gt.log("ready_________________",args.kPos,self.UsePos)
	
	if args.kPos then 
		if args.kPos == self.UsePos then 
			for i , v in pairs(self._ready) do
				if v then self.m_flagReady[i]:setVisible(true) end
			end
			for i = 1 , GAME_PLAYER do
				for j = 1 , 5 do
					if self.userCard[j].card[i] then
					self.userCard[j].card[i]:setTexture("poker/56.png")
					self.userCard[j].card[i]:setVisible(true)
				end

					self._card[i]:setVisible(false)
				end
			end

			gt.log("---------self.UsePos", self.UsePos)
			-- self.readyclockImg:setVisible(false)

			-- if gt.isCreateUserId then
			-- 	self:ActionDian(self.readyTipsText, false)
			-- else
				if self.guancha then
					if gt.curCircle > 0 then 
						self:ActionDian(self.lookonTipsText, false)
					else
						self:ActionDian(self.lookonTipsText, true)
					end
				else
					self:ActionDian(self.lookonTipsText, false)
				end
			-- end
	
			self.guancha = false
			if self.guancha then
				self.dissolvebtn:setEnabled(false)
				self.chatbtn:setVisible(false)
				self.yuyinBtn:setVisible(false)
			else
				self.dissolvebtn:setEnabled(true)
				self.chatbtn:setVisible(true)
				self.yuyinBtn:setVisible(true)
			end
			self.readybtn:setVisible(false) 
			self.btNext:setVisible(false)
			self:stopAllActions()
			-- self.readybtn:setPositionX(880)
			if self.spine then
		        self.spine:removeFromParent()
		        self.spine = nil
			end
			if gt.curCircle ~= 0 then 
				self:OnResetView() 
			end
		end
		if self.readybtn:isVisible() and self.gameBegin then 
			if self:getTableIdNN(args.kPos) == gt.MY_VIEWID then 
				if self.m_flagReady[gt.MY_VIEWID] then
					self.m_flagReady[gt.MY_VIEWID]:setVisible(true)
				end
			end
			self._ready[self:getTableIdNN(args.kPos)] = true
		else
			self.m_flagReady[self:getTableIdNN(args.kPos)]:setVisible(true) 
		end	
    end

end

function nnScene:onNodeEvent(eventName)
	log("enter_______",eventName)
	if "enter" == eventName then
		
	elseif "exit" == eventName or "cleanup" == eventName then 

		self:remove_self()	

	end
end

function nnScene:remove_self()
	if self.scheduleShowCountdownHandler then
		gt.scheduler:unscheduleScriptEntry(self.scheduleShowCountdownHandler)
		self.scheduleShowCountdownHandler = nil
	end

	for i , v in pairs(self.dianAction) do
		_scheduler:unscheduleScriptEntry(v)
		v = nil
	end

	if self.shareImgFilePath  then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		self.shareImgFilePath = nil
	end

	if 	self.__time then 
		_scheduler:unscheduleScriptEntry(self.__time)
		self.__time = nil
	end	

	if self.scheduleHandler then  
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end

	-- if self.timerWriteLogScheduler then
	-- 	gt.scheduler:unscheduleScriptEntry(self.timerWriteLogScheduler)
	-- 	self.timerWriteLogScheduler = nil
	-- end

	-- if self.socketClientCloseScheduler then
	-- 	gt.scheduler:unscheduleScriptEntry(self.socketClientCloseScheduler)
	-- 	self.socketClientCloseScheduler = nil
	-- end

	if self._waitingTime1 then
		_scheduler:unscheduleScriptEntry(self._waitingTime1)
		self._waitingTime1 = nil
	end

	if self._waitingTime2 then
		_scheduler:unscheduleScriptEntry(self._waitingTime2)
		self._waitingTime2 = nil
	end

	if self.actiondian then
		_scheduler:unscheduleScriptEntry(self.actiondian)
		self.actiondian = nil
	end

	self:ActionText(false)

	if self.readyClockTimeSchedulerEntry then
		gt.scheduler:unscheduleScriptEntry(self.readyClockTimeSchedulerEntry)
		self.readyClockTimeSchedulerEntry = nil
	end

	if self.spine then
        self.spine:removeFromParent()
        self.spine = nil
	end
		
	self:dismissFlyCoins()

	cc.UserDefault:getInstance():setIntegerForKey("readyClockTime", 0)

	if self._clockGameStart then _scheduler:unscheduleScriptEntry(self._clockGameStart) self._clockGameStart = nil end

	-- voicelist
	if self.voiceListListener then
		gt.scheduler:unscheduleScriptEntry(self.voiceListListener)
		self.voiceListListener = nil
	end

	-- 播放背景音乐
	gt.soundEngine:playMusic("bgm1", true)
end

function nnScene:onStartGame()
 	
	local msgToSend = {}
	msgToSend.kMId = gt.MSG_C_2_S_ADD_ROOM_SEAT_DOWN
	msgToSend.kDeskId = gt.deskId
	gt.socketClient:sendMessage(msgToSend)

	if gt.dumplog_nn then
		gt.dumplog_nn(msgToSend)
	end

end

function nnScene:onNextRoundGame()
 	
	local msgToSend = {}
	msgToSend.kMId = gt.CG_READY
	-- msgToSend.kPos = self.UsePos
	gt.socketClient:sendMessage(msgToSend)

	if gt.dumplog_nn then
		gt.dumplog_nn(msgToSend)
	end

end

function nnScene:gameend_nn(msg)
-- //牛牛：返回小结算

--     MSG_S_2_C_NIUNIU_DRAW_RESULT = 62078

--     kZhuangPos  //庄家位置

--     kPlayerHandCard[6][5]   //所有玩家手牌

--     kPlayScore[6]   //每个玩家本局得分

--     kTotleScore[6]   //每个玩家总得分

--     kOxNum[6]        //每个玩家的牛牛数据

--     kOxTimes[6]      //每个玩家的倍数

	if gt.dumplog_nn then
		gt.dumplog_nn(args)
	end
	
	self:clearUI()
	
	self.sendCardFlag = true
    local lGameScore = {}
    local settlementCoins = {}
    for i = 1, GAME_PLAYER do
        lGameScore[i] = msg.kPlayScore[i]
        if self.m_cbPlayStatus[self:SwitchViewChairIDNN(i - 1)] == 1 then
            local wViewChairId = self:SwitchViewChairIDNN(i - 1)
            settlementCoins[wViewChairId] = tonumber(lGameScore[i])
        end
    end

	self:clearText()

    if yl.GAMEDATA[4] == 1 then
		self.currCountdownTime = self.remainTime > 0 and self.remainTime or self.CountdownTime[4]
		self:setCountdownSchedule(self.currCountdownTime, self.clock)
	end

	self.TotleScore = msg.kTotleScore

	gt.log("------------self.m_cbPlayStatus")
	dump(self.m_cbPlayStatus)

	local PlayScore = 0
	local scoreMaxPlayer = 1
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			for i = 1 , GAME_PLAYER do
				local pos = self:getTableIdNN(i-1)
				dump(self.m_cbPlayStatus)
				dump(msg.kOxNum)
				if self.m_cbPlayStatus[pos] == 1 and msg.kOxNum[i] > -1 then 
					local tmp = msg.kPlayScore[i]
					self.userCard[pos].roundScore:setVisible(true)
					self.userCard[pos].roundScoreBg:setVisible(true)
					if tmp < 0 then
						tmp = -tmp
						tmp = "/"..tmp
						self.userCard[pos].roundScoreBg:loadTexture("nn/nn_scorereducebg.png")
						self.userCard[pos].roundScore:setProperty(tostring(tmp),"nn/reduce.png",38,50,"/")
					else
						tmp = "/"..tmp
						self.userCard[pos].roundScoreBg:loadTexture("nn/nn_scoreaddbg.png")
						self.userCard[pos].roundScore:setProperty(tostring(tmp),"nn/add.png",38,50,"/")
					end
					gt.log("-----------pos", pos)
					gt.log("-----------msg.kTotleScore[i]", msg.kTotleScore[i])
					self.m_UserHead[pos].score:setString(msg.kTotleScore[i])
				end
			end

			self.m_UserHead[scoreMaxPlayer].hg:setVisible(true)
			self.m_UserHead[scoreMaxPlayer].quanquan:setVisible(true)
			self.m_UserHead[scoreMaxPlayer].quanquan:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,45)))
			self:actionScore(settlementCoins)
		end),
		cc.DelayTime:create(1),
		cc.CallFunc:create(function()
			if self.spine then
		        self.spine:removeFromParent()
		        self.spine = nil
			end

			if not self.guancha and self.curPlayerStatus then
				self.spine = sp.SkeletonAnimation:create("res/animation/nn/shengli_shibai.json", "res/animation/nn/shengli_shibai.atlas")
			   	if yl.GAMEDATA[6] == 6 then
					self.spine:setPosition(cc.p(gt.winCenter.x, gt.winCenter.y + 15))
					self.spine:setScale(0.7)
				elseif yl.GAMEDATA[6] == 10 then
					self.spine:setPosition(cc.p(gt.winCenter.x, gt.winCenter.y - 15))
					self.spine:setScale(0.7)
				end
				self:addChild(self.spine)
				if msg.kPlayScore[self.UsePos + 1] >= 0 then
					self:_playSound_nn(0, "GAME_WIN")
					self.spine:setAnimation(0, "shengli", false)
				else
					self.spine:setAnimation(0, "shibai", false)
					self:_playSound_nn(0, "GAME_LOST")
				end
			end

			if gt.curCircle < gt.CurMaxCircle and not self.guancha then
	   			self:ActionText(true, self.text7)
				self.btNext:setVisible(true)
			end
		end)
	))

	for i = 1 , GAME_PLAYER do
		if self.m_cbPlayStatus[self:getTableIdNN(i-1)] == 1 then 
			local pos = self:getTableIdNN(i-1)
			if msg.kOxNum[i] > -1 then
				if pos ~= MY_VIEWID then
					local function showCardType( )
						self.userCard[pos].cardType:stopAllActions()
						local strFile = string.format("nn_type/ox_%d.png", msg.kOxNum[i])
						self.userCard[pos].cardType:setPositionX(-200)
						self.userCard[pos].cardType:setVisible(true)
						self.userCard[pos].cardType:loadTexture(strFile)
					
						self.userCard[pos].cardType:runAction(
							cc.Sequence:create(
								cc.MoveTo:create(0.1, cc.p(0, self.userCard[pos].cardType:getPositionY())),
								cc.MoveTo:create(0.1, cc.p(-30, self.userCard[pos].cardType:getPositionY())),
								cc.MoveTo:create(0.1, cc.p(0, self.userCard[pos].cardType:getPositionY()))
								))
					end

					showCardType()
				else
					if self.curPlayerStatus then
						local strFile = string.format("nn_type/ox_%d.png", msg.kOxNum[i])
						self.userCard[pos].cardType:setVisible(true)
						self.userCard[pos].cardType:loadTexture(strFile)
					end
				end
			end
			self:setCard(pos,msg["kPlayerHandCard"..(i-1)])
		end

		if PlayScore < msg.kPlayScore[i] then
			scoreMaxPlayer = self:getTableIdNN(i-1)
			PlayScore = msg.kPlayScore[i]
		end

		--已完成
		self.kanpai[i] = gt.seekNodeByName(self.currentNode, "wancheng"..i)
		self.kanpai[i]:setVisible(false)
	end

end

function nnScene:clearUI(clearUIType)
	self:clearText(clearUIType)
	self.startbtn:setVisible(false)
	if self.guancha and not self.playerFull then
		self.readybtn:setVisible(true)
	else
		self.readybtn:setVisible(false)
	end
	self.btNext:setVisible(false)
	self.clock:setVisible(false)
	if clearUIType ~= "addScore_nn" then
		self.xiafen:setVisible(false)
	end
	if clearUIType ~= "noifyqiangzhuang" then
		self.callbankernode:setVisible(false)
	end

	if clearUIType ~= "sendCard_nn" then
		self.nodeopencard:setVisible(false)
	end

	if clearUIType ~= "GameResult" then
		if self._waitingTime1 then
			_scheduler:unscheduleScriptEntry(self._waitingTime1)
			self._waitingTime1 = nil
		end

		if self._waitingTime2 then
			_scheduler:unscheduleScriptEntry(self._waitingTime2)
			self._waitingTime2 = nil
		end

		if self.actiondian then
			_scheduler:unscheduleScriptEntry(self.actiondian)
			self.actiondian = nil
		end

		if self.spine then
	        self.spine:removeFromParent()
	        self.spine = nil
		end
	end

	if self.applyDimissRoom then self.applyDimissRoom:setVisible(false) end
end

function nnScene:GameResult(result)
	gt.log("max_result__________________________")
	gt.socketClient:unregisterMsgListener(gt.GC_REMOVE_PLAYER)

	if gt.dumplog_nn then
		gt.dumplog_nn(result)
	end

	self._node:getChildByName("downBg"):setVisible(false)

	self:clearUI("GameResult")
	self.resultbtn:setVisible(true)

	self.result = result 
end

function nnScene:disPlaygameResult()

	if not self.result then return end
	self:OnResetView()
	self.result_node:setVisible(true)


	local message = self.result
	local csbNode = self.result_node:getChildByName("NN_RESULT")
    
    local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end


    local id = message.kUserIds
    local score = message.kScore
    local names = message.kNikes
    local urls = message.kHeadUrls
    local userIds = message.kUserIds

    local _name = {}
    local _id = {}
    local _score = {}
    local _url =  {}
    local _userIds =  {}
    local idx  = 0 

    local chairCount = 0
    for i = 1 ,message.kEffectiveUserCount do
        if message.kUserState[i] ~= 0 then
		    if id[i] == gt.playerData.uid then
		        idx = i
		        table.insert(_url,urls[i])
		        table.insert(_name,names[i])
		        table.insert(_id,id[i])
		        table.insert(_score,score[i])
		        table.insert(_userIds,userIds[i])
		        
		        break
		    end

        end
    end
  	
  	for i = 1 ,message.kEffectiveUserCount do
        if message.kUserState[i] ~= 0 then
		    if id[i] ~= gt.playerData.uid then
		        table.insert(_url,urls[i])
		        table.insert(_name,names[i])
		        table.insert(_id,id[i])
		        table.insert(_score,score[i])
		        table.insert(_userIds,userIds[i])
		    end
        end
    end

    local tmp = _score[1]
    idx = 1
    for i =1 , #_score do
        if _score[i] > tmp then
        	tmp = _score[i]
        	idx = i
        end
    end

   	local image_bg
   	if yl.GAMEDATA[6] == 6 then
    	image_bg = csbNode:getChildByName("Node_6peoples")
	elseif yl.GAMEDATA[6] == 10 then
    	image_bg = csbNode:getChildByName("Node_10peoples")
	end
	self.currentNode:setVisible(true)

    gt.log("-------idx", idx)

   	local win_ = image_bg:getChildByName("player" .. idx):getChildByName("playerWin")
   	win_:setVisible(true)
   	win_:setLocalZOrder(21)
    local quan = image_bg:getChildByName("player" .. idx):getChildByName("quan")
    quan:setLocalZOrder(20)
    quan:setVisible(true)
    quan:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.6,50)))

    csbNode:getChildByName("Label_room_Id"):setString("房间号:"..self.data.kDeskId or "000000")

    csbNode:getChildByName("Label_create_user"):setString("房主:"..(self.result.kCreatorNike or ""))

    local betscores = ""
    if yl.GAMEDATA[1] == 0 then
    	if yl.GAMEDATA[2] == 2 then
	    	if yl.GAMEDATA[8] == 0 then
	    		betscores = "小倍(1 2 3)"
	    	elseif yl.GAMEDATA[8] == 2 then
	    		betscores = "大倍(4 5 6)"
	    	end
    	elseif yl.GAMEDATA[2] == 3 then
	    	if yl.GAMEDATA[8] == 0 then
	    		betscores = "小倍(2 3 4 5)"
	    	elseif yl.GAMEDATA[8] == 1 then
	    		betscores = "中倍(6 9 12 15)"
	    	elseif yl.GAMEDATA[8] == 2 then
	    		betscores = "大倍(5 10 20 30)"
	    	end
    	elseif yl.GAMEDATA[2] == 4 then
	    	if yl.GAMEDATA[8] == 0 then
	    		betscores = "小倍(2 3 4 5)"
	    	elseif yl.GAMEDATA[8] == 1 then
	    		betscores = "中倍(6 9 12 15)"
	    	elseif yl.GAMEDATA[8] == 2 then
	    		betscores = "大倍(5 10 20 30)"
	    	end
    	end
	elseif yl.GAMEDATA[1] == 1 then
    	if yl.GAMEDATA[2] == 0 then
    		betscores = "小倍(1 2 3)"
    	elseif yl.GAMEDATA[2] == 1 then
	    	if yl.GAMEDATA[8] == 0 then
	    		betscores = "小倍(2 3 4 5)"
	    	elseif yl.GAMEDATA[8] == 1 then
	    		betscores = "中倍(6 9 12 15)"
	    	elseif yl.GAMEDATA[8] == 2 then
	    		betscores = "大倍(5 10 20 30)"
	    	end
    	elseif yl.GAMEDATA[2] == 2 then
    		betscores = "小倍(1 2 3)"
    	end
	end
    csbNode:getChildByName("Label_room_type"):setString("牛牛:"..(yl.GAMEDATA[1] == 0 and "轮流坐庄 " or "看牌抢庄 ")..betscores)

    csbNode:getChildByName("lbl_draw_limit"):setString("局数:"..(self.result_jushi and self.result_jushi or self.jushu))

    csbNode:getChildByName("lbl_end_time"):setString(tostring(os.date("%m-%d %H:%M", self.result.kTime / 1000)).."结束")

    -- 退出按钮
   	local btn = csbNode:getChildByName("Btn_back")
    btn:setTag(BTN_QUIT)
    btn:addTouchEventListener(btncallback)
	btn:setPressedActionEnabled(true)
	btn:setZoomScale(-0.1)

    self.resultPalyer = {}
    for i = 1, #_score do
        local cellbg = image_bg:getChildByName("player" .. i)
        if nil ~= cellbg then
     		table.insert(self.resultPalyer, cellbg)
            cellbg:setVisible(true)

            local id = cellbg:getChildByName("Text_ID")
            id:setString(_id[i])
               
            cellbg:getChildByName("name"):setString(_name[i])
            
            local plyerScore = cellbg:getChildByName("score")
            local tmp
            if _score[i] >= 0 then
				plyerScore:setString("+"..tostring(_score[i]))
				plyerScore:setColor(cc.c3b(255, 67, 1))
            else
				plyerScore:setString(tostring(_score[i]))
				plyerScore:setColor(cc.c3b(86, 184, 47))
            end

		    --显示解散人
			local applyDismissImg = cellbg:getChildByName("Img_applyDismiss")
			if applyDismissImg then
				applyDismissImg:setVisible(false)
				if gt.m_userId and gt.m_userId > 0 then
					if tonumber(_userIds[i]) == tonumber(gt.m_userId) then
						applyDismissImg:setVisible(true)
					end
				end
			end
        end
    end

    for i = 1, #_score do
        local cellbg = image_bg:getChildByName("player" .. i)
        if nil ~= cellbg then

            cellbg:setVisible(true)        
                
            local ispath = gt.imageNamePath(_url[i])
            local icon = cellbg:getChildByName("icon")
            if ispath then
                local _node
			   	if yl.GAMEDATA[6] == 6 then
					_node = display.newSprite("result_nn/result_icon_6peoples.png")
				elseif yl.GAMEDATA[6] == 10 then
					_node = display.newSprite("result_nn/result_icon_10peoples.png")
				end
               
                local image = gt.clippingImage(ispath,_node,false)
                image:setLocalZOrder(19)
                cellbg:addChild(image)
               
                image:setPosition(icon:getPositionX(),icon:getPositionY())
            else
      			if _url[i] ~= "" and  type(_url[i]) == "string" and string.len(_url[i]) >10 then
      				local function callback(args)
      					if args.done and self then 
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

   	if yl.GAMEDATA[6] == 6 then
	    if table.nums(self.resultPalyer) == 2 then
	    	self.resultPalyer[1]:setPositionX(388)
	    	self.resultPalyer[2]:setPositionX(838)
	    elseif table.nums(self.resultPalyer) == 3 then
	    	self.resultPalyer[1]:setPositionX(388)
	    	self.resultPalyer[2]:setPositionX(613)
	    	self.resultPalyer[3]:setPositionX(838)
	    elseif table.nums(self.resultPalyer) == 4 then
	    	self.resultPalyer[1]:setPositionX(312)
	    	self.resultPalyer[2]:setPositionX(504)
	    	self.resultPalyer[3]:setPositionX(696)
	    	self.resultPalyer[4]:setPositionX(888)
	    elseif table.nums(self.resultPalyer) == 5 then
	    	self.resultPalyer[1]:setPositionX(163)
	    	self.resultPalyer[2]:setPositionX(388)
	    	self.resultPalyer[3]:setPositionX(613)
	    	self.resultPalyer[4]:setPositionX(838)
	    	self.resultPalyer[5]:setPositionX(1063)
	    end
	end

end

function nnScene:removePlayer(args)
	if gt.dumplog_nn then
		gt.dumplog_nn(args)
	end
	if args and args.kPos and args.kPos ~= 21 and args.kPos ~= GAME_PLAYER then 
		self.head_hui[self:getTableIdNN(args.kPos)]:setVisible(false)
		self.nodePlayer[self:getTableIdNN(args.kPos)]:setVisible(false)
		self.m_flagReady[self:getTableIdNN(args.kPos)]:setVisible(false)
		self.m_cbPlayStatus[self:getTableIdNN(args.kPos)] = 0
		self.PlayerNN[self:getTableIdNN(args.kPos)] = nil
		self.playersDataNN[self:getTableIdNN(args.kPos)] = nil
	
		self:setBtnShare()

		if args.kPos == self.UsePos then self:onExitRoom("房间已解散！") end
	end
	if  args and args.kPos and args.kPos == self.UsePos and args.kPos == GAME_PLAYER then
		self:onExitRoom("您已退出房间！")
	end
end

function nnScene:actionScore(settlementCoins)

	if not self.m_wBankerUser then return end

	local lastExecution = {}
	local firstExecution = {}
	local executionTime = 0
	local waitingTime = 0
	local max = -1000
	local maxId = -1
	for key,value in pairs(settlementCoins) do
		local zPoint = self.pointPlayer[self:SwitchViewChairIDNN(self.m_wBankerUser)]
		if key ~= self:SwitchViewChairIDNN(self.m_wBankerUser) then
			local point = self.pointPlayer[key]
			if value ~= 0 then
				if value < 0 then
					waitingTime = 1
					table.insert(firstExecution,{point,zPoint})
				else
					table.insert(lastExecution,{zPoint,point})
				end
			end
		end
		if value > max then
			max = value
			maxId = key
		end
	end

	if self._waitingTime1 then
		_scheduler:unscheduleScriptEntry(self._waitingTime1)
		self._waitingTime1 = nil
	end

	if self._waitingTime2 then
		_scheduler:unscheduleScriptEntry(self._waitingTime2)
		self._waitingTime2 = nil
	end

	if self.dismissFlyCoins then
		self:dismissFlyCoins()
	end

	self._waitingTime1 = _scheduler:scheduleScriptFunc(function()
		for i = 1,#firstExecution do
			if self.flyCoinsAnimation then 
				self:flyCoinsAnimation(firstExecution[i][1],firstExecution[i][2])
			end
		end
		-- if #firstExecution > 0 then
		-- 	self._scene:PlaySound(nnScene.RES_PATH.."sound/GAME_LOST.WAV")
		-- end
		if self._waitingTime1 then
			_scheduler:unscheduleScriptEntry(self._waitingTime1)
			self._waitingTime1 = nil
		end
	end,executionTime,false)

	self._waitingTime2 = _scheduler:scheduleScriptFunc(function()
		for i = 1,#lastExecution do
			if self.flyCoinsAnimation then 
				self:flyCoinsAnimation(lastExecution[i][1],lastExecution[i][2])
			end
		end
		-- if #lastExecution > 0 then
		-- 	self._scene:PlaySound(nnScene.RES_PATH.."sound/GAME_WIN.mp3")
		-- end
		if self._waitingTime2 then
			_scheduler:unscheduleScriptEntry(self._waitingTime2)
			self._waitingTime2 = nil
		end
	end,executionTime + waitingTime,false)

end

function nnScene:flyCoinsAnimation(sPoint,ePoint)
	log("sPoint_____",sPoint)
	dump(sPoint)
	log("ePoint——————",ePoint)
	dump(ePoint)

	self:_playSound_nn(0, "FLY_GOLD")
	if not self._coins then
		self._coins = {}
	end
	local delayTime = 0
	local flyCoinsUpdate = nil

	local function callback()
		if not ePoint or not sPoint then  _scheduler:unscheduleScriptEntry(flyCoinsUpdate) flyCoinsUpdate = nil return end
	
		for i = 1 , 1 do
			local ep = ePoint
			local p1 = sPoint
			local p2 = cc.p((ep.x + p1.x)/2, ep.y)
			if p1.y < ep.y then
				p2.y = ep.y
			end
			local actionMove = cc.BezierTo:create(1 + (0.5 - delayTime)*0.3, {p1,p2,ep})

			local psp = display.newSprite("nn/jinbixiao.png")
			psp:setPosition(sPoint.x,sPoint.y)
			psp:setLocalZOrder(6)
			-- psp:setOpacity(0)
			self._node:addChild(psp)
			psp:setLocalZOrder(10)
			table.insert(self._coins,psp)

			psp:runAction(transition.sequence({
			cc.Spawn:create{
				-- cc.FadeIn:create(1),
				cc.EaseInOut:create(actionMove,2),
			},
				cc.FadeOut:create(0.1)
			}))
		end
		delayTime = delayTime + 0.18
		if delayTime >= 1 and flyCoinsUpdate then
			_scheduler:unscheduleScriptEntry(flyCoinsUpdate)	
			flyCoinsUpdate = nil
		end
	end

	flyCoinsUpdate = _scheduler:scheduleScriptFunc(callback,0.1,false)

	if not self._flyCoinsUpdates then
		self._flyCoinsUpdates = {}
	end
	table.insert(self._flyCoinsUpdates,flyCoinsUpdate)
end

--随机范围位置
function nnScene:randomLocation(x,y,lx,ly)
	local rx = math.random(x-lx,x+lx)
	local ry = math.random(y-ly,y+ly)
	return cc.p(rx,ry)
end

--销毁金币
function nnScene:dismissFlyCoins()
	if self._coins then
		for i = 1,#self._coins do
			self._node:removeChild(self._coins[i])
			self._coins[i] = nil
		end
	end
	self._coins = nil

	if self._flyCoinsUpdates then
		for i = 1,#self._flyCoinsUpdates do
			if self._flyCoinsUpdates[i] then
				_scheduler:unscheduleScriptEntry(self._flyCoinsUpdates[i])
			end
		end
	end
	self._flyCoinsUpdates = nil

end

function nnScene:setBtnShare()
	local playerCount = 0
	for i , v in pairs(self.m_cbPlayStatus) do
		if v == 1 then
			playerCount = playerCount + 1
		end
	end
	
	if playerCount == GAME_PLAYER or gt.curCircle > 0 then
    	self.sharebtn:setVisible(false)
	else
    	self.sharebtn:setVisible(true)
	end
end

function nnScene:off_line_data_nn(msg)
 --    gt.MSG_S_2_C_NIUNIU_RECON = 62079 -- 断线重连

 --	   kPlayStatus   //游戏阶段， 0-选庄， 1-下注，  2-开牌

 --    kRemainTime   //阶段剩余时间

 --    kZhuangPos    //庄位置

 --    kHasScore     //是否已下注  0-没有   1-已下注

 --    kHasOpenCard  //是否已经开牌  0-没有开牌   1-已经开牌

 --    kHasSelectZhuang  //是否已经选庄  0-没有选庄  1-已经选庄

 --    kAddZhuang[6]  //玩家抢庄下注分数

 --    kAddScore[6]   //玩家下注分数

 --    kplayerTuiScore  //所有玩家推注分数

 --    kPlayerHandCard[6][5]  //所有玩家手牌

--     kPlayerStatus[6]  //有几个人玩
-- 请开始游戏
-- 等待房主开始游戏
-- 亮牌中

 --    log("game status is play!")
 --    self.sharebtn:setVisible(false)
 --    self.gameBegin = true
 --    for i = 1 , GAME_PLAYER do
 --    	self.m_flagReady[i]:setVisible(false)
 --        local id = self:SwitchViewChairIDNN(i-1)
 --        gt.log("view_id",id,msg.kPlayStatus)
 --        self.m_cbPlayStatus[id] = msg.kPlayStatus
 --    end

	if gt.dumplog_nn then
		gt.dumplog_nn(msg)
	end

	self:clearUI()
	if self.dismissFlyCoins then
		self:dismissFlyCoins()
	end

    if yl.GAMEDATA[4] == 1 then
		self.remainTime = msg.kRemainTime

		if self.remainTime > 0 then
			self.currCountdownTime = msg.kRemainTime > 0 and msg.kRemainTime or self.CountdownTime[msg.kPlayStatus + 1]
			self:setCountdownSchedule(self.currCountdownTime, self.clock)
		end
	end

	if msg.kPlayerTuiScore then
		self.xianjiatuizhuScore = msg.kPlayerTuiScore[self.UsePos + 1]
	end

	if not self.xianjiatuizhuScore or self.xianjiatuizhuScore == 0 then
		self.btn_cell_score_xianjiatuizhu:setVisible(false)
	else
		self.btn_cell_score_xianjiatuizhu:setVisible(true)
		self.btn_cell_score_xianjiatuizhu:setPositionX(betScoresPositionX[table.nums(self.currentBetScores)][table.nums(self.currentBetScores) + 1])
		self.btn_cell_score_xianjiatuizhu:setTitleText(self.xianjiatuizhuScore.."分")
	end

	self.curPlayerStatus = (msg.kPlayerStatus[self.UsePos + 1] == 1)

    local guancha = (msg.kIsLookOn == 1) -- 动态加入

    self.guancha = guancha
	if self.guancha or not self.curPlayerStatus then
		if not self.playerFull then
			self.readybtn:setVisible(true)
		else
			self.readybtn:setVisible(false)
		end
		self.dissolvebtn:setEnabled(false)
		self.chatbtn:setVisible(false)
		self.yuyinBtn:setVisible(false)
	else
		self.readybtn:setVisible(false)
		self.dissolvebtn:setEnabled(true)
		self.chatbtn:setVisible(true)
		self.yuyinBtn:setVisible(true)
	end

    if guancha then
    	self.m_cbPlayStatus[MY_VIEWID] = 0
		self:clearText()
    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text1)
    	self.clock:setVisible(false)

		for i =1 , GAME_PLAYER do
			-- 准备标志
			self.m_flagReady[i]:setVisible(false)
		end
    end

	-- self.readyclockImg:setVisible(false)
	-- if gt.isCreateUserId then
	-- 	self:ActionDian(self.readyTipsText, false)
	-- else
		if self.guancha then
			if gt.curCircle > 0 then 
				self:ActionDian(self.lookonTipsText, false)
			else
				self:ActionDian(self.lookonTipsText, true)
			end
		else
			self:ActionDian(self.lookonTipsText, false)
		end
	-- end

	local function gamestartclear( )
        for i = 1 , GAME_PLAYER do
		end
	end

	self.gameBegin = true    -- 游戏已经开始啦
	if msg.kPlayStatus == 0 then
		gt.log("----------msg.kPlayStatus", msg.kPlayStatus)
		self.CenterSendCardFlag = false
		self:_playSound_nn(gt.MY_VIEWID, "selectbanker")
        for i = 1 , GAME_PLAYER do
			local args = {}
			args.kPos = i - 1
			args.kPlayerStatus = msg.kPlayerStatus 
        	--if args.kPlayerStatus[i] == 1 then
		gt.log("----------args.kPos", args.kPos)
		gt.log("----------self.UsePos", self.UsePos)
				if args.kPos == self.UsePos or self.guancha or not self.curPlayerStatus then
		gt.log("----------self.guancha", self.guancha)
					args.kPlayerHandCard = msg["kPlayerHandCard"..(i-1)]
					self:qiangzhuang(args, true)	
					local score = msg.kAddZhuang[i]
					if score > -1 then
						local p = self:getTableIdNN(i-1)
						local node = self.player_qiangscore[p]
						node:loadTexture("nn/qiang"..score.."times.png")
						node:setVisible(true)
 						self.callbankernode:setVisible(false)
						self:clearText()
						self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text2)
					end
					if self.guancha or not self.curPlayerStatus then
						self.callbankernode:setVisible(false)
					end
				end
			--end
        end
        for i = 1 , GAME_PLAYER do
			local args = {}
			args.kPos = i - 1
			args.kPlayerStatus = msg.kPlayerStatus 
			if args.kPos ~= self.UsePos then
				local score = msg.kAddZhuang[i]
				if score > -1 then
					local p = self:getTableIdNN(i-1)
					local node = self.player_qiangscore[p]
					node:loadTexture("nn/qiang"..score.."times.png")
					node:setVisible(true)
				end
			end
        end
		return
	end

	self:game_start(msg, true)

    -- 等待闲家下注中
    -- 请下注
    -- kPos  //玩家位置
    -- kScore  //玩家下注分数
	if msg.kPlayStatus == 1 then
		if msg.kZhuangPos ~= self.UsePos then 
			self:_playSound_nn(gt.MY_VIEWID, "bet")
		end
		if yl.GAMEDATA[1] == 1 then
			-- for i = 1 , GAME_PLAYER do
				local args = {}
				args.kPos = self.UsePos
				args.kPlayerStatus = msg.kPlayerStatus 
	  --       	if args.kPlayerStatus[i] == 1 then
					-- if args.kPos == self.UsePos then
						args.kPlayerHandCard = msg["kPlayerHandCard"..self.UsePos]
						self.CenterSendCardFlag = false
						self:qiangzhuang(args, true)
						self.callbankernode:setVisible(false)
					-- end
				-- end
	   --      end
		end
		gt.log("----------self.UsePos", self.UsePos)
		self:clearText()
		if msg.kHasScore[self.UsePos + 1] == 1 then
			self:clearText()
	    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text5)
			self:showAddScoreBtn(false)
		else
			self:clearText()
	    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text4)
			self:showAddScoreBtn(not self.guancha and self.curPlayerStatus)
		end
	    -- 庄位置
	    local m_wBankerUser = msg.kZhuangPos
		self.m_wBankerUser = m_wBankerUser
		gt.log("---------------------self:getTableIdNN(m_wBankerUser)", self:getTableIdNN(m_wBankerUser))
		self.m_BankerFlag[self:getTableIdNN(m_wBankerUser)]:setVisible(true)
		self.zhuangmask[self:getTableIdNN(m_wBankerUser)]:setVisible(true)
		-- 抢庄倍数
		local score = msg.kAddZhuang[msg.kZhuangPos + 1]
		if score > -1 then
			local p = self:getTableIdNN(msg.kZhuangPos)
			local node = self.player_score[p]
			node:loadTexture("nn/"..score.."times.png")
			node:setVisible(true)
			local node = self.player_qiangscore[p]
			node:setVisible(false)
		end
	    for i = 1 , GAME_PLAYER do
	    	if msg.kZhuangPos ~= i - 1 then
		        -- 下注分数
				local score = msg.kAddScore[i]
				local p = self:getTableIdNN(i-1)
				local node = self.m_betscoresvalue[p]
				if score > 0 then
					node:setString(score)
					self.m_betscoresbg[p]:setVisible(true)
				end
			end
	    end
	end
			 	
	if msg.kPlayStatus == 2 then
	   self:showAddScoreBtn(false)

--     kShow  //发牌 or 亮牌  0-发牌  1-亮牌

--     kPos   //玩家位置

--     kOxNum //玩家牛牛数

--     kPlayerHandCard[5]  //玩家手牌

--     kPlayerStatus[6]  //有几个人玩
	    -- 庄位置
	    local m_wBankerUser = msg.kZhuangPos
		self.m_wBankerUser = m_wBankerUser
		gt.log("---------------------self:getTableIdNN(m_wBankerUser)", self:getTableIdNN(m_wBankerUser))
		self.m_BankerFlag[self:getTableIdNN(m_wBankerUser)]:setVisible(true)
		self.zhuangmask[self:getTableIdNN(m_wBankerUser)]:setVisible(true)
	
		for i = 1 , GAME_PLAYER do
			local args = {}
			args.kShow = msg.kHasOpenCard[i]
			--args.kShow = msg.kHasOpenCard
			args.kPos = i-1
			args.kOxNum = msg.kOxNum[i]
			args.kPlayerStatus = msg.kPlayerStatus
			--args.kOxNum = 5
			args.kPlayerHandCard = {}
			for j = 1, 5 do
				args.kPlayerHandCard[j] = msg["kPlayerHandCard"..(i-1)][j]
			end 	
			if args.kPlayerStatus[i] == 1 then
				if args.kShow == 1 then
					self.sendCardFlag = true 

					args.kShow= 0
					self:sendCard_nn(args, true)
					args.kShow = 1
					self:sendCard_nn(args, true)	
				elseif args.kShow == 0 then
					self:sendCard_nn(args, true)
				end
			end
		end
	    for i = 1 , GAME_PLAYER do
	    	if msg.kZhuangPos ~= i - 1 then
		        -- 下注分数
				local score = msg.kAddScore[i]
				local p = self:getTableIdNN(i-1)
				local node = self.m_betscoresvalue[p]
				if score > 0 then
					node:setString(score)
					self.m_betscoresbg[p]:setVisible(true)
				end
			end
	    end
	    gt.log("-------------------self.UsePos", self.UsePos)
		if msg.kHasOpenCard[self.UsePos + 1] == 1 then 
			self.nodeopencard:setVisible(false)
			self:clearText()
	    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text8)
		else
			if not self.guancha and msg.kPlayerStatus[self.UsePos + 1] == 1 then
				self.nodeopencard:setVisible(true)
			end
			self:clearText()
	    	self:ActionText(true, (self.guancha or not self.curPlayerStatus) and self.text7 or self.text6)
        end
        if self.guancha or not self.curPlayerStatus then
			self.nodeopencard:setVisible(false)
		end
	end
end


return nnScene