
local gt = cc.exports.gt
local Utils = cc.exports.Utils

local Utils = require("client/tools/Utils")
require("client/config/MJRules")

local MJScene = class("MJScene", function()
	return display.newScene("MJScene")
end)

MJScene.__index = MJScene

--[[
Ming bar 明杠
touch tickets 摸牌
明杠与暗杠：杠牌分为名杠与暗杠两种。
Bright bars and dark bars: bar card classified as bars and dark bar two
self-drawn 自摸
--]]
MJScene.DecisionType = {
	-- 接炮胡
	TAKE_CANNON_WIN				= 1,
	-- 自摸胡
	SELF_DRAWN_WIN				= 2,
	-- 明杠
	BRIGHT_BAR					= 3,
	-- 暗杠
	DARK_BAR					= 4,
	-- 碰
	PUNG						= 5,
	-- 吃
	EAT					        = 6,
	--听
	TING                     	= 7
}

MJScene.StartDecisionType = {
	-- 缺一色
	TYPE_QUEYISE				= 1,
	-- 板板胡
	TYPE_BANBANHU				= 2,
	-- 四喜
	TYPE_DASIXI					= 3,
	-- 六六顺
	TYPE_LIULIUSHUN				= 4
}

MJScene.ZOrder = {
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
	CHAT						= 1000,
	MJBAR_ANIMATION				= 21,
	FLIMLAYER           	    = 16,
	HAIDILAOYUE					= 23,
	GANG_AFTER_CHI_PENG			= 15,

	ROUND_REPORT				= 66,-- 单局结算界面显示在总结算界面之上
	DECISION_NEW                = 67,
	MOON_FREE_CARD              = 80,-- 中秋节免费送房卡活动弹框
}

MJScene.FLIMTYPE = {
	FLIMLAYER_BAR				= 1,
	FLIMLAYER_BU				= 2,
	FLIMLAYER_TING				= 3,
}

MJScene.TAG = {
	FLIMLAYER_BAR				= 50,
	FLIMLAYER_BU				= 51,
	FLIMLAYER_TING				= 52,
}

MJScene.positionTip = {
    --东，南，西，北
    positionTip1 = { x = 122, y = 40},
    positionTip2 = { x = 187, y = 79},
    positionTip3 = { x = 122, y = 127},
    positionTip4 = { x = 51, y = 79},
}

--玩法类型说明 --2107-3-1 syz 添加
MJScene.PLAYTYPE_STR = {
	[1] = ",报听",
	[2] = ",带风",
	[3] = ",只能自摸和",
	[4] = ",清一色加番",
	[5] = ",一条龙加番",
	[6]	= ",随机耗子",
	[7] = ",过胡只可自摸",
	[8] = ",抢杠胡",
	[9] = ",荒庄不荒杠",
	[10] = ",未上听杠不算分",
	[11] = ",一炮多响",
	[12] = ",听牌可杠",
	[13] = ",七小对",
	[14] = ",只有胡牌玩家杠算分",
	[15] = ",风一色",
	[16] = ",清一色",
	[17] = ",凑一色",
	[18] = ",暗杠可见",
	[19] = ",十三幺",
	[20] = ",一条龙",
	[21] = ",4金",
	[22] = ",8金",
	[23] = ",上金少者只可自摸",
	[24] = ",边坎吊",
	[45] = ",双耗子",
	[49] = ",风耗子",
	[10001] = ",平胡",
	[10002] = ",大胡",
}
local mjTilePerLine = {}
MJScene.chenzhouPlayType= {piao={},jinniao={0,1}}

function MJScene:ctor(enterRoomMsgTbl)
	
	--csw 1 - 16
	self.isduanxian = true -- 用于 空闲状态 玩家断线 小结算面板 影响大结算面板显示


	-- csw 12 -30 -- 目前 公用弹框 区分游戏类型
	gt.gameType = "mj"
	-- csw 12 -30

	gt.log("进入桌子界面 ================= ")
	gt.dump(enterRoomMsgTbl)
	-- gt.dumplog(enterRoomMsgTbl)
	-- 存储玩家位置信息
	gt.location = {}
	gt.gameStart = false
	gt.m_userId = 0
	self.RoundStart = false
	-- 玩家的距离
	self.juliTab = {}
	-- 记录玩家是否请求过位置
	self.locationNum = 0
	-- 记录定时信息
	self.timerNum = 0
	self.m_numberMark = 0
	self.m_fangzhuPos = nil
	self.m_isTingPai = nil
	self.m_tingState = false
	self.delayTime = 0
	self.headSpr = {}
	self.FinalReportFlag = false
	self.selectedseat = false
	self.offLine = {}
	self.clockSprite = {}
	self.m_clockFrameSprite = {}
	self.m_TimeProgress = {}
	self.m_clockLabel = {}
	self._time = {}
	self.chutaiShowFlag = false
	self.tingSendMessageFlag = false
	self.touchFlag = false
	self.unSeatRoomPlayers = {}
	self.unSeatRoomPlayersIdx = {}
	self.mapRoomPlayers = {}
	self.tingCards = {}
	self.HaoZiCards = nil
	self.KouPaiData = {}
	self.updateBatteryTime = 0
	self.feeType = enterRoomMsgTbl.kFeeType
	self.flag = enterRoomMsgTbl.kFlag
	self.zhiDuiCardList = {}     --支对可选牌
	self.showHuCardsList  = {}	 --可胡牌列表
	gt.clubId =  enterRoomMsgTbl.kClubId or 0
	gt.playTypeClick = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."playTypeClick", 2)
	gt.bgType = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType", 2)
	
	-- gt.playTypeId = enterRoomMsgTbl.m_playTypeId

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    self.gameMark = true
    gt.dynamicStartQuickRoom = false
	-- 加载界面资源
	local csbNode, animation = gt.createCSAnimation("MJScene.csb")
    self.csType=false

    self.csbNode=csbNode
    local chatBgNode = gt.seekNodeByName(csbNode, "Node_chatBg")

   	Utils.shareContent(enterRoomMsgTbl)

   	-- 桌面
	local mahjong_table = gt.seekNodeByName(csbNode, "mahjong_table")
	mahjong_table:setTexture("res/background/sx_bg_play"..gt.bgType..".jpg")

    --语音标志
    self.yuyinNode=gt.seekNodeByName(csbNode,"Node_Yuyin_Dlg")
    self.yuyinPos_2=gt.seekNodeByName(self.yuyinNode,"Image_2")
    self.yuyinPos_4=gt.seekNodeByName(self.yuyinNode,"Image_4")

    self.showHuCardsPanel = gt.seekNodeByName(csbNode,"Panel_hu_list")     --可胡牌容器
    self.showHuCardsImage = gt.seekNodeByName(csbNode,"Image_hu_list")     --可胡牌底图

    self:hideHuCards()    --默认隐藏

    --取消发送标志
    self.yuyinCancle=nil
	-- 胡牌之后,单据结算界面延迟显示时间
	self.reportDelayTime = 1.2
	-- 海底牌展示时间
	self.haidCardShowTime = 1.2
	-- 胡牌特效延迟时间 
	self.huAnimationTime = 0 --过字缩放
	self.passScale = 0.7
	-- 检测定位间隔时间
	self.locationMaxTime = 1800
	self.checkLocationTime = self.locationMaxTime

	-- 牌数不足发送重连消息
	self.flushCardNumFlag = false

	--是否正在录音
	self.isRecording = false

	-- 结算前夕是否有玩家被移除
	-- self.hasRoomPlayerBeRemoved = false
    self.piaoFlag=false
	gt.log("================")
	-- animation:play("run", true)
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

	--房间信息尺寸控制
	self.roomInfoBtn = gt.seekNodeByName(self.rootNode, "Btn_roomInfo")
	self.mjTypeLabel = gt.seekNodeByName(self.rootNode, "Label_mjType")
	self.Text_5 = gt.seekNodeByName(self.rootNode, "Text_5")

	self.roomInfoBtn:addClickEventListener(function(sender)
		self:setRoomInfoBtn(2)
	end)

	-- 房间号
	local roomIDLabel = gt.seekNodeByName(self.rootNode, "Label_roomID")
	roomIDLabel:setString(string.format("房号:%d",enterRoomMsgTbl.kDeskId))
    cc.UserDefault:getInstance():setStringForKey("roomId",enterRoomMsgTbl.kDeskId)
    self.deskId = enterRoomMsgTbl.kDeskId

    gt.deskId = self.deskId

    gt.curCircle = cc.UserDefault:getInstance():getIntegerForKey("curCircle"..gt.deskId, 0)

	--版本号
	gt.versionCodeTxt = "1.2.24"..(self:getAppVersionShow() or "")

    --版本号
	local versionCodeTxt = gt.seekNodeByName(self.rootNode, "Txt_versionCode")
	versionCodeTxt:setString(gt.versionCodeTxt)

	-- 玩法类型
	local playTypeDesc = self:setPlayInfo(enterRoomMsgTbl.kState, enterRoomMsgTbl.kGamePlayerCount)

	self.isAutoOutTile = false
	-- 是否红中赖子
	self.isHZLZ = false
	--当前玩法玩家总数
	-- gt.totalPlayerNum = enterRoomMsgTbl.m_user_count or 4
	
	local realType = enterRoomMsgTbl.kPlaytype
	self.m_playtype = enterRoomMsgTbl.kPlaytype

	self.DarkBarsShow = false
	for i = 1, #self.m_playtype do
		if self.m_playtype[i] == 18 then
			self.DarkBarsShow = true
		end
	end

	gt.log("玩法标题 ===========", gt.playType)
	--dump(realType)
    --2107-3-1 syz 添加
    -- for i,_type in ipairs(realType) do
    -- 	if MJRules.Rules[_type] then
    -- 		playTypeDesc = playTypeDesc .. MJRules.Rules[_type].name
    -- 	end   	
    -- end
	local readySignNode = gt.seekNodeByName(self.rootNode, "Node_readySign")
	readySignNode:setVisible(true)

	--底分
	self.baseScore = enterRoomMsgTbl.kCellscore
	local cellScoreLabel = gt.seekNodeByName(self.rootNode, "Label_cellScore")
	cellScoreLabel:setString("底分:"..self.baseScore)

	--动态开局
	local roundCountLabel = gt.seekNodeByName(self.rootNode, "Label_roundCount")
	if enterRoomMsgTbl.kGreater2CanStart and enterRoomMsgTbl.kGreater2CanStart == 1 and roundCountLabel:getString() == "" then
		roundCountLabel:setString("动态开局")
	end

	self.m_Greater2CanStart = enterRoomMsgTbl.kGreater2CanStart or 0
   	
	-- 跑马灯
	self.marqueeNode = gt.seekNodeByName(csbNode, "Node_marquee")
    --2107-3-1 syz 注释掉
	-- local arrStr={}
	-- --匹配字符串中的所有空格，并把字符串分割成一个数组
	-- for p_str in string.gmatch(playTypeDesc, "%S+") do
	--     table.insert(arrStr,p_str)
 --    end
 	--2107-3-1 syz 注释掉
 	local arrStr={}
	arrStr = string.split(playTypeDesc,",")
	self.mjTypeStr = playTypeDesc
  --   for i,v in ipairs(arrStr) do
  --   	if v=="推倒胡" then
  --   		self.mjTypeStr = "推倒胡" 
  --   	elseif v=="扣点点" then
  --   		self.mjTypeStr = "扣点点"
  --   	elseif v=="立四" then
  --   		self.mjTypeStr = "立四"
  --   	elseif v=="晋中" then
  --   		self.mjTypeStr = "晋中"
  --   	elseif v=="运城贴金" then
  --   		self.mjTypeStr = "运城贴金"
  --   	elseif v=="拐三角" then
  --   		self.mjTypeStr = "拐三角"	
		-- elseif v == "硬三嘴" then
		-- 	self.mjTypeStr = "硬三嘴"	
		-- elseif v == "洪洞王牌" then
		-- 	self.mjTypeStr = "洪洞王牌"
		-- elseif v == "一门牌" then
		-- 	self.mjTypeStr = "一门牌"
  --   	end
  --   end

    local explainNode = gt.seekNodeByName(csbNode,"Node_explain")
    explainNode:setZOrder(999)
    self.Label_tilesCount = gt.seekNodeByName(csbNode,"Label_tilesCount")
    self.Image_tilesCount = gt.seekNodeByName(csbNode,"Image_tilesCount")
    self.Image_tilesCount:setVisible(false)
    -- 设置本局玩法
    -- local wanfaStr = self.mjTypeStr..": "

    local lineflag = 1
    local wanfaStr = self.mjTypeStr.." "
   --  for i=1, #enterRoomMsgTbl.m_playtype do
   --  	lineflag = lineflag + 1
   --  	if i == 1 then
   --  		local firstWanfa = MJRules.Rules[enterRoomMsgTbl.m_playtype[1]].name
   --  		-- firstWanfa = string.sub(firstWanfa, 2)
   --  		wanfaStr = wanfaStr .. firstWanfa.." "
   --  	elseif MJRules.Rules[enterRoomMsgTbl.m_playtype[i]] ~= nil then
   --  		wanfaStr = wanfaStr .. MJRules.Rules[enterRoomMsgTbl.m_playtype[i]].name.." "
   --  	end
 		-- wanfaStr = string.gsub(wanfaStr, ",", "")
   --  	if lineflag%2 == 0 then
   --  		wanfaStr = wanfaStr.."\n"
   --  	end
   --  end
    gt.log("=====wanfaStr:"..wanfaStr.."  len:" .. string.len(wanfaStr))
    -- local showMore = gt.seekNodeByName(csbNode, "Btn_more")
    -- local arrowSp = gt.seekNodeByName(csbNode, "Spr_arrow")
    -- showMore:hide()
    -- arrowSp:hide()
    -- local showStrArr = self:getCutString(wanfaStr,25) -- 最多3行
    -- --dump(showStrArr)
    self.mjTypeLabel:setString("玩法:"..playTypeDesc)
    -- local count = 1
    -- local moreStr = showStrArr[count]
    -- if #showStrArr > 1 then
    -- -- 	showMore:show()
    -- -- 	arrowSp:show()
    -- 	Label_mjType:setString(moreStr)
    -- -- 	-- local bgImg = gt.seekNodeByName(csbNode, "Img_wanfa")
    -- 	local isNext = true --标记是否有剩余的字符串
    -- 	gt.addBtnPressedListener(showMore, function ()
    -- 		if isNext then
    -- 			count = #showStrArr
    -- 			isNext = false
    -- 			arrowSp:setFlippedY(true)
    -- 			for i=2,#showStrArr do
    -- 				moreStr = moreStr.."\n"..showStrArr[i]
    -- 			end
    -- 		else
    -- 			count = 1
    -- 			isNext = true
    -- 			arrowSp:setFlippedY(false)
    -- 			moreStr = showStrArr[1]
    -- 		end
    -- 		Label_mjType:setContentSize(cc.size(550, 30+(count-1)*30))
    -- 		Label_mjType:setString(moreStr)
    -- 		-- bgImg:setContentSize(cc.size(600, 50+(count-1)*30))
    -- 	end)
    -- end
   	-- self.test = cc.Sprite:create("res/test.png")
   	-- self:addChild(self.test,999)
   	-- self.test:setPosition(gt.winCenter)
   	-- self.test:setOpacity(0)

   	local Label_mjType_sub = gt.seekNodeByName(csbNode,"Label_mjTypeSub")
   	local wanfa_sub = ""
   	local lineflag_sub = 1
	for i=1, #enterRoomMsgTbl.kPlaytype do
    	lineflag_sub = lineflag_sub + 1
    	if i == 1 then
    		local firstWanfa_sub = MJRules.Rules[enterRoomMsgTbl.kPlaytype[1]].name
    		-- firstWanfa = string.sub(firstWanfa, 2)
    		firstWanfa_sub = string.gsub(firstWanfa_sub, "，", "")
    		wanfa_sub = wanfa_sub .. firstWanfa_sub
    	elseif MJRules.Rules[enterRoomMsgTbl.kPlaytype[i]] ~= nil then
    		wanfa_sub = wanfa_sub .. MJRules.Rules[enterRoomMsgTbl.kPlaytype[i]].name
    	end
    	wanfa_sub = string.gsub(wanfa_sub, " ", "")
 		--wanfa_sub = string.gsub(wanfa_sub, ",", "")
    	-- if lineflag_sub%2 == 0 then
    	-- 	wanfa_sub = wanfa_sub.."\n"
    	-- end
    end
    Label_mjType_sub:setString(wanfa_sub)
   	
    -- csw 11- 13
    self.isKdd = string.find(playTypeDesc,"扣点点")
   	self.shz  = string.find(wanfa_sub,"双耗子")

   	-- csw 11- 13

   	-- csw 11 -28 
   	self.caidai = cc.CSLoader:createNode("yanhua.csb")
   	self:addChild(self.caidai, 88)
   	self.caidai:setVisible(false)
   	self.caidai:setPosition(gt.winCenter)


    local newStrType=""
	if self.csType then
    	for i,v in ipairs(arrStr) do
    	    if i==1 then
    	    else
    	    	newStrType=newStrType ..","..v
    	    end
        end
    else
    	for i,v in ipairs(arrStr) do
    	 	if i==1 then
    	    else
    	    	newStrType=newStrType ..","..v
    	    end
        end
    end

    cc.UserDefault:getInstance():setStringForKey("playType",self.mjTypeStr..newStrType)

	-- 刚进入房间,隐藏未入坐玩家信息节点
	for i = 1, 4 do
		local playerNode = gt.seekNodeByName(self.rootNode, "Node_unSeatPlayerInfo_" .. i)
		self.rootNode:reorderChild(playerNode, MJScene.ZOrder.PLAYER_INFO)
		playerNode:setVisible(false)
	end

	-- 刚进入房间,隐藏玩家信息节点
	for i = 1, 4 do
		local playerNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. i)
		self.rootNode:reorderChild(playerNode, MJScene.ZOrder.PLAYER_INFO)
		playerNode:setVisible(false)
	end
	self:hidePlayersReadySign()
	-- 隐藏玩家麻将参考位置（麻将参考位置父节点，pos(0，0）)
	local playNode = gt.seekNodeByName(self.rootNode, "Node_play")
	playNode:setVisible(false)
	-- 隐藏轮换位置标识（东南西北信息）
	local turnPosLayerSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosLayer")
	-- turnPosLayerSpr:setTexture("res/images/otherImages/turn_pos_bg_new.png")
    -- turnPosLayerSpr:setVisible(false)
	for i=1,4 do
		local turnPosTipSpr = gt.seekNodeByName(turnPosLayerSpr, "Spr_turnPosTip_" .. i)
		local fadeOut = cc.FadeOut:create(0.8)
		local fadeIn = cc.FadeIn:create(0.8)
		local seqAction = cc.Sequence:create(fadeOut, fadeIn)
		turnPosTipSpr:runAction(cc.RepeatForever:create(seqAction))
	end
	
	-- 隐藏牌局状态（倒计时，剩余牌局，剩余牌数）
	local roundStateNode = gt.seekNodeByName(self.rootNode, "Node_roundState")
	roundStateNode:setVisible(false)
	self.Image_tilesCount:setVisible(false)
	-- 倒计时
	self.playTimeCDLabel = gt.seekNodeByName(roundStateNode, "Label_playTimeCD")
	self.playTimeCDLabel:setString("0")
	-- 隐藏玩家决策按钮（碰，杠，胡，过的父节点）
	local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
	self.rootNode:reorderChild(decisionBtnNode, MJScene.ZOrder.DECISION_BTN)
	decisionBtnNode:setVisible(false)
	-- 隐藏自摸决策暗杠，碰转明杠，自摸胡
	local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
	self.rootNode:reorderChild(selfDrawnDcsNode, MJScene.ZOrder.DECISION_BTN)
	selfDrawnDcsNode:setVisible(false)
	-- -- 隐藏游戏中设置按钮
	-- local playBtnsNode = gt.seekNodeByName(self.rootNode, "Node_playBtns")
	-- playBtnsNode:setVisible(false)
	-- 隐藏准备按钮
	local readyBtn = gt.seekNodeByName(self.rootNode, "Btn_ready")
	readyBtn:setVisible(false)
	gt.addBtnPressedListener(readyBtn, handler(self, self.readyBtnClickEvt))
	-- 隐藏所有玩家对话框
	local chatBgNode = gt.seekNodeByName(self.rootNode, "Node_chatBg")
	self.rootNode:reorderChild(chatBgNode, MJScene.ZOrder.CHAT)
	chatBgNode:setVisible(false)
	-- 隐藏开始胡牌决策按钮
	local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_start_decisionBtn")
	if decisionBtnNode then
		decisionBtnNode:setVisible( false )
	end
	-- 胡牌字隐藏
	local huBtnNode = gt.seekNodeByName(self.rootNode, "Sprite_for_cshupaitype")
	if huBtnNode then
		huBtnNode:setVisible( false )
	end

	local Image_play_bg = gt.seekNodeByName(self.rootNode, "Image_play_bg")
	Image_play_bg:setPositionX(Image_play_bg:getPositionX()+500)
	self.rootNode:reorderChild(Image_play_bg, 999)
	Image_play_bg:setVisible(false)

	self.menuBtn1 = gt.seekNodeByName(self.rootNode, "Btn_menu1")
	gt.addBtnPressedListener(self.menuBtn1, function()
		if Image_play_bg:isVisible() then
			Image_play_bg:setPositionX(Image_play_bg:getPositionX()+500)
			Image_play_bg:setVisible(false)
		else
			Image_play_bg:setPositionX(Image_play_bg:getPositionX()-500)
			Image_play_bg:setVisible(true)
		end
		self.menuBtn1:setVisible(false)
		self.menuBtn2:setVisible(true)
	end)

	self.menuBtn2 = gt.seekNodeByName(self.rootNode, "Btn_menu2")
	gt.addBtnPressedListener(self.menuBtn2, function()
		if Image_play_bg:isVisible() then
			Image_play_bg:setPositionX(Image_play_bg:getPositionX()+500)
			Image_play_bg:setVisible(false)
		else
			Image_play_bg:setPositionX(Image_play_bg:getPositionX()-500)
			Image_play_bg:setVisible(true)
		end
		self.menuBtn1:setVisible(true)
		self.menuBtn2:setVisible(false)
	end)

	local Panel_play = gt.seekNodeByName(self.rootNode, "Panel_play")
	self.rootNode:reorderChild(Panel_play, 999)
	

	local settingBtn = gt.seekNodeByName(self.rootNode, "Btn_setting")
	gt.addBtnPressedListener(settingBtn, function()
		local settingPanel = require("client/game/majiang/Setting"):create(self.rootNode)
		self:addChild(settingPanel, MJScene.ZOrder.SETTING)
	end)

	if cc.UserDefault:getInstance():getIntegerForKey( "Setting"..gt.playerData.uid, 0 ) == 0 then
		local settingPanel = require("client/game/majiang/Setting"):create(self.rootNode)
		self:addChild(settingPanel, MJScene.ZOrder.SETTING)
		cc.UserDefault:getInstance():setIntegerForKey( "Setting"..gt.playerData.uid, 1 )
	end

	local restartBtn = gt.seekNodeByName(self.rootNode, "Btn_restart")
	gt.addBtnPressedListener(restartBtn, function()
		gt.removeTargetAllEventListener(self)
		-- 消息回调
		if self["unregisterAllMsgListener"] then
			self:unregisterAllMsgListener()
		end

		if gt.socketClient.scheduleHandler then
			gt.scheduler:unscheduleScriptEntry( gt.socketClient.scheduleHandler )
		end
		-- 关闭事件回调
		gt.removeTargetAllEventListener(gt.socketClient)
		-- 调用善后处理函数
		gt.socketClient:clearSocket()
		-- 关闭socket
		gt.socketClient:close()

		local loginScene = require("client/game/common/LogoScene"):create()
		cc.Director:getInstance():replaceScene(loginScene)
	end)

	--规则按钮
	local ruleBtn = gt.seekNodeByName(self.rootNode, "Btn_rule")
	ruleBtn:setVisible(false)
	gt.addBtnPressedListener(ruleBtn, function()
		gt.log("点击规则按钮")
		local layer = require("client/game/majiang/RuleIntroduction"):create(enterRoomMsgTbl.kPlaytype, gt.createType)
		self:addChild(layer, 1000)
	end)

	-- 消息按钮
	self.messageBtn = gt.seekNodeByName(self.rootNode, "Btn_message")
	self.rootNode:reorderChild(self.messageBtn, 998)
	gt.addBtnPressedListener(self.messageBtn, function()
		-- local chatPanel = require("app/views/ChatPanel"):create(false)
		local chatPanel
		if #self.ChatLog > 0 then
			chatPanel = require("client/game/majiang/ChatPanel"):create(self.ChatLog)
		else
		 	chatPanel = require("client/game/majiang/ChatPanel"):create(false)
		end
		self:addChild(chatPanel, MJScene.ZOrder.CHAT)
	end)

	-- 动态开局按钮
	self.dynamicStartBtn = gt.seekNodeByName(self.rootNode, "Btn_dynamicStart")
	-- self.dynamicStartBtn:setVisible(false)
	gt.addBtnPressedListener(self.dynamicStartBtn, function(sender)
		-- 发送决策消息
		local msgToSend = {}

		msgToSend.kMId = gt.CG_START_GAME
		msgToSend.kPos = self.playerSeatIdx - 1
		gt.socketClient:sendMessage(msgToSend)
	end)

	-- gt.log("------self.m_Greater2CanStart", self.m_Greater2CanStart)
	-- --动态开局提示和按钮状态
	-- if self.m_Greater2CanStart == 1 then
	-- 	self:setDynamicStartBtn(msgTbl)
	-- end

	-- 动态开局提示
	self.Label_tips = {}
	for i =1, 4 do
		self.Label_tips[i] = gt.seekNodeByName(self.rootNode, "Label_tips"..i)
		self.Label_tips[i]:setVisible(false)
	end

	self.Node_dot = gt.seekNodeByName(self.rootNode, "Node_dot")
	self.Node_dot:setVisible(false)

	self.Label_dot = {}
	for i =1, 6 do
		self.Label_dot[i] = gt.seekNodeByName(self.rootNode, "Label_dot"..i)
		self.Label_dot[i]:setVisible(false)
	end

	-- 按钮
	local hudongNode = gt.seekNodeByName(self.rootNode, "Node_hudong")
	self.rootNode:reorderChild(hudongNode, 999)

	-- 麻将层
	local playMjLayer = cc.Layer:create()
	self.rootNode:addChild(playMjLayer, MJScene.ZOrder.MJTILES)
	self.playMjLayer = playMjLayer

	--手牌麻将节点
	self.holdMjNode = cc.Layer:create()
	self.playMjLayer:addChild(self.holdMjNode)
	self.holdMjNode:setName("holdMjNode")
	self.holdMjNode:setPosition(cc.p(0,0))

	-- 出的牌标识动画
	local outMjtileSignNode = cc.Sprite:createWithSpriteFrameName("sx_img_play_biaoji.png")
	outMjtileSignNode:setVisible(false)
	self.rootNode:addChild(outMjtileSignNode, MJScene.ZOrder.OUTMJTILE_SIGN)
	self.outMjtileSignNode = outMjtileSignNode
   
	-- 头像下载管理器
	local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
	self.rootNode:addChild(playerHeadMgr)
	self.playerHeadMgr = playerHeadMgr

	-- 最大局数
	self.roundMaxCount = enterRoomMsgTbl.kMaxCircle
	-- 准备界面逻辑
	local paramTbl = {}
	paramTbl.roomID = enterRoomMsgTbl.kDeskId
	paramTbl.playerSeatPos = enterRoomMsgTbl.kPos
    
	local playTypeDesc2 = ""
	local s, e = string.find(playTypeDesc, " ")
	if s and e then
		playTypeDesc2 = string.sub(playTypeDesc, e + 1)
	end

	local title_show = ""
	-- if enterRoomMsgTbl.m_state == 100001 then
	-- 	title_show = "推倒胡"
	-- elseif enterRoomMsgTbl.m_state == 100002 then
	-- 	title_show = "扣点点"
	-- elseif enterRoomMsgTbl.m_state == 100008 then
	-- 	title_show = "硬三嘴"
 --    elseif enterRoomMsgTbl.m_state == 100009 then
	-- 	title_show = "洪洞王牌"
 --    elseif enterRoomMsgTbl.m_state == 100010 then
	-- 	title_show = "一门牌"	
	-- end
	title_show = Utils.getplayName(enterRoomMsgTbl.kState)

    paramTbl.title_show = title_show
	paramTbl.playTypeDesc = string.gsub(newStrType, " ", ",")
	paramTbl.roundMaxCount = enterRoomMsgTbl.kMaxCircle
	paramTbl.m_Greater2CanStart = self.m_Greater2CanStart
	paramTbl.m_state = enterRoomMsgTbl.kState
	paramTbl.m_clubId = enterRoomMsgTbl.kClubId
	paramTbl.m_deskId = enterRoomMsgTbl.kDeskId
	self.readyPlay = require("client/game/majiang/ReadyPlay"):create(self, csbNode, paramTbl)
	-- 解散房间
	if self.playerSeatIdx == nil then
		self.playerSeatIdx = enterRoomMsgTbl.kPos + 1
		gt.playerSeatIdx = self.playerSeatIdx
	end
	self.applyDimissRoom = require("client/game/majiang/ApplyDismissRoom"):create(self.roomPlayers, self.playerSeatIdx)
	self:addChild(self.applyDimissRoom, MJScene.ZOrder.DISMISS_ROOM)

	-- 获取luabridge
	self:getLuaBridge()

	--语音提示
	local yuyinNode =  gt.seekNodeByName(self.rootNode, "Node_yuyin")
	if yuyinNode then
		yuyinNode:setVisible(false)
	end

	local yuyinChatNode = gt.seekNodeByName(self.rootNode, "Node_Yuyin_Dlg")
	if yuyinChatNode then
		yuyinChatNode:setVisible(false)
		self.yuyinChatNode = yuyinChatNode
	end

 	self.schedulerEntry = nil
 	local unpause = function()
 		if self.schedulerEntry then
 			gt.scheduler:unscheduleScriptEntry(self.schedulerEntry)
 			self.schedulerEntry = nil
 			self.yuyinBtn:setTouchEnabled(true)
 		end
 	end

 	-- 正式包点击语音按钮回调函数
	local function touchEvent(sender,eventType)
	    
        if eventType == ccui.TouchEventType.began then
    		--调用新语音
            self.sendVocie = false
	        gt.soundEngine:pauseAllSound()
	        self:playYuYinAnimation()
	        self.sendVocie = true
	        self:startAudio()
        elseif eventType == ccui.TouchEventType.moved then
        	
            
        if self.yuyinCancle then
        elseif math.abs(sender:getTouchBeganPosition().y - sender:getTouchMovePosition().y) >= 100 then
		    if self.m_yuyinNode then 
        		self.m_yuyinNode:removeFromParent()
        		self.m_yuyinNode=nil
        	end
        	
		    self.yuyinCancle=display.newSprite("res/images/otherImages/yuyin2.png")
            self.yuyinCancle:setPosition(cc.p(632,362.92))
            self:addChild(self.yuyinCancle)
        end

        elseif eventType == ccui.TouchEventType.ended then
        	-- 防止乱点
        	self.yuyinBtn:setTouchEnabled(false)
        	self.schedulerEntry = gt.scheduler:scheduleScriptFunc(unpause, 1, false)

        	self:stopYuYinAnimation()
	    	gt.soundEngine:resumeAllSound()
	    	gt.log("恢复音乐 111111")
	    	self:stopAudio()
            if self.yuyinCancle then 
	            self.yuyinCancle:removeFromParent()
			    self.yuyinCancle=nil
	        end
        elseif eventType == ccui.TouchEventType.canceled then
        	self:stopYuYinAnimation()
            gt.soundEngine:resumeAllSound()
            gt.log("恢复音乐 222222")
		    self:cancelAudio()
            if self.yuyinCancle then 
			    self.yuyinCancle:removeFromParent()
			    self.yuyinCancle=nil
	        end
        end
    end

    --语音按钮
	self.yuyinBtn = gt.seekNodeByName(self.rootNode, "Btn_voice")
	self.rootNode:reorderChild(self.yuyinBtn, 998)
	if self.yuyinBtn then
	    self.yuyinBtn:addTouchEventListener(touchEvent)
		if gt.isAppStoreInReview then
			self.yuyinBtn:setVisible(false)
		end
	end

	-- 极速连接按钮
	local quickconnectBtn = gt.seekNodeByName(self.rootNode, "Btn_quickconnect")
	gt.addBtnPressedListener(quickconnectBtn, function()
		-- gt.isShowOfflineLoading = false 
		gt.socketClient:reloginServer()
	end)

    --查看胡牌按钮
	local tinghuBtn = gt.seekNodeByName(self.rootNode, "Btn_tinghu")
	gt.addBtnPressedListener(tinghuBtn, function()
		self.showTingHuCardsFlag = true
		self:showTingHuCards()
	end)

	self.AppVersion = self:getAppVersion()
	if self.AppVersion > 10 then
		local function timerWriteLog( )
			if gt.timerWriteLog then
				gt.timerWriteLog()
			end
		end
		--开定时器写log
	    self.timerWriteLogScheduler = gt.scheduler:scheduleScriptFunc(handler(self, timerWriteLog), 0.2, false)
	end

	local Node_dabao = gt.seekNodeByName(self.rootNode, "Node_dabao")
	Node_dabao:setVisible(false)

	local Image_logo = gt.seekNodeByName(self.rootNode, "Image_logo")
	Image_logo:setVisible(true)

	-- 请15秒内入座
	self:setDynamicStartTips(4)

	-- 玩家进入房间
	self:playerEnterRoom(enterRoomMsgTbl)

    -- self:initWifi()
    --self:initPaoMaDeng()

	self.playVideoNode = gt.seekNodeByName(self.rootNode, "Node_playvideo")
	self.playVideoNode:setVisible(true)
	self.rootNode:reorderChild(self.playVideoNode, 999)

	--查看是否为vip防作弊房间
	if enterRoomMsgTbl.kCheatAgainst == 1 then
		self.isVipRoom = true

		if cc.UserDefault:getInstance():getIntegerForKey( "VIPdeskId", 0 ) ~= enterRoomMsgTbl.kDeskId then
			self:UploadGpsInformation()
			local function update( )
				gt.log("------------------update")
				if self.scheduleSendVideoHandler then
					gt.scheduler:unscheduleScriptEntry(self.scheduleSendVideoHandler)
					self.scheduleSendVideoHandler = nil
				end
  		    	require("client/game/dialog/NoticeForSendVideoTips"):create(2, "您现在进入的是防作弊VIP房间，互相可以看到实时视频画面、GPS地图位置。", nil, nil, enterRoomMsgTbl.kDeskId)
			end
			self.scheduleSendVideoHandler = gt.scheduler:scheduleScriptFunc(handler(self, update), 1, false)
  		else
   --          local IsSendForbidVideo = cc.UserDefault:getInstance():getIntegerForKey("IsSendForbidVideo"..enterRoomMsgTbl.m_deskId, 0)
   --          if IsSendForbidVideo == 0 then
			-- 	--发送视频消息
			-- 	local msgToSend = {}
			-- 	msgToSend.m_msgId = gt.UPLOAD_VIDEO_PERMISSION
			-- 	msgToSend.m_userId = gt.playerData.uid
			-- 	msgToSend.m_VideoPermit = 1
			-- 	gt.socketClient:sendMessage(msgToSend)
			-- end
		end

        --请求gps
		self:getLuaBridge()
		if gt.isIOSPlatform() then
			local ok, ret = self.luaBridge.callStaticMethod("AppController", "startTrackLocation")
		elseif gt.isAndroidPlatform() then
			gt.log("------------------------startTrackLocation")
			local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "startTrackLocation",nil,"()V")
		end
        -- JniFun::startTrackLocation();
        
        --请求视频
		self:getLuaBridge()
		if gt.isIOSPlatform() then
			local ok, ret = self.luaBridge.callStaticMethod("AppController", "isVideoPermitted")
			self.luaBridge.callStaticMethod("AppController", "registerIsVideoPermittedHandler", {scriptHandler = handler(self, self.onIsVideoPermittedResult)})
		elseif gt.isAndroidPlatform() then
			gt.log("------------------------isVideoPermitted")
			local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "isVideoPermitted",nil,"()V")
			self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerIsVideoPermittedHandler", {handler(self, self.onIsVideoPermittedResult)}, "(I)V")
		end

        -- JniFun::isVideoPermitted();

		-- local msgToSend = {}
		-- msgToSend.m_msgId = gt.UPDATE_USER_VIP_INF
		-- msgToSend.m_userId = gt.playerData.uid
		-- gt.socketClient:sendMessage(msgToSend)
	else
		local videoBtn = gt.seekNodeByName(self.rootNode, "Btn_video")
		videoBtn:setVisible(false)
		local weizhiBtn = gt.seekNodeByName(self.rootNode, "Btn_weizhi")
		weizhiBtn:setVisible(false)
		local ruleBtn = gt.seekNodeByName(self.rootNode, "Btn_rule")
		ruleBtn:setPositionX(99)
		self.messageBtn:setPositionX(1150)
	end

	--视频窗口
	self.playVideoPanel = gt.seekNodeByName(self.rootNode, "Panel_video")

	--视频中
	self.videoingImg = gt.seekNodeByName(self.rootNode, "Img_videoing")

	-- --关闭视频按钮
	-- local videocloseBtn = gt.seekNodeByName(self.rootNode, "Btn_videoclose")
	-- gt.addBtnPressedListener(videocloseBtn, function()
		-- self.playVideoPanel:setVisible(false)
		-- self.videoingImg:setVisible(false)

		-- self:getLuaBridge()
		-- if gt.isIOSPlatform() then
		-- 	local ok, ret = self.luaBridge.callStaticMethod("AppController", "leaveVideo")
		-- 	self.luaBridge.callStaticMethod("AppController", "registerLeaveVideoHandler", {scriptHandler = handler(self, self.onLeaveVideoResult)})
		-- elseif gt.isAndroidPlatform() then
		-- 	local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "leaveVideo", nil, "()V")
		-- 	self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerLeaveVideoHandler", {handler(self, self.onLeaveVideoResult)}, "(I)V")
		-- end
  --   -- JniFun::leaveVideo();
		-- local msgToSend = {}
		-- msgToSend.m_msgId = gt.SHUTDOWN_VIDEO_INVITATION
		-- msgToSend.m_reqUserId = gt.playerData.uid
		-- msgToSend.m_userId = gt.receiveUserId

		-- -- msgToSend.m_strUUID = gt.socketClient:getPlayerUUID()
		-- gt.socketClient:sendMessage(msgToSend)

  --   	self.isOnVideo = false
	-- end)

	self.setvideoImg = gt.seekNodeByName(self.rootNode, "Img_setvideo")
	--视频按钮
	local videoBtn = gt.seekNodeByName(self.rootNode, "Btn_video")
	gt.addBtnPressedListener(videoBtn, function()
		self:setVideoInfo()
		gt.log("点击视频按钮")
		if self.setvideoImg:isVisible() then
			self.setvideoImg:setVisible(false)
		else
			self.setvideoImg:setVisible(true)
			self.rootNode:reorderChild(self.playVideoNode, 999)
		end
	end)

	for i = 1, 3 do
		--视频按钮
		local playvideoBtn = gt.seekNodeByName(self.rootNode, "Btn_playvideo"..i)
		gt.addBtnPressedListener(playvideoBtn, function()
			gt.log("------------------------playvideoBtn:getTag()"..playvideoBtn:getTag())
			gt.dump(self.videoRoomPlayers)
			gt.log("------------------------self.videoRoomPlayers[playvideoBtn:getTag()].displaySeatIdx"..self.videoRoomPlayers[playvideoBtn:getTag()].displaySeatIdx)
			gt.dump(self.offLine)
		    if self.videoRoomPlayers[playvideoBtn:getTag()] and self.offLine[self.videoRoomPlayers[playvideoBtn:getTag()].displaySeatIdx] then
				Toast.showToast(self, "对方处于离线状态，无法进行视频，请稍后再试", 2)
			else
			    gt.log("---------playvideoBtn:getTag()", playvideoBtn:getTag())
			    gt.dump(self.videoRoomPlayers)
	  		    require("client/game/dialog/NoticeForSendVideoTips"):create(1, "确定发送视频请求？不用担心，对方不会看到你的影像。对方连通后会弹出实时视频。"
	  		    	, self.videoRoomPlayers[playvideoBtn:getTag()].uid, self.isOnVideo)
		    end
		end)
	end

	--地图按钮
	local weizhiBtn = gt.seekNodeByName(self.rootNode, "Btn_weizhi")
	gt.addBtnPressedListener(weizhiBtn, function()
		gt.log("点击地图按钮")
		self:startGameMap()
	end)

	-- 是否是最后一局
	self.lastRound = false

	-- 本次否杠牌
	self.curTypeIsGang = false
	-- 我是否有胡牌决策 用于一炮多响
	self.hasHuPaiDecision = false

	--显示方位
	self:showPosition()

	if self.playerSeatIdx < 5 then
	    local turnPosBgSpr = gt.seekNodeByName(csbNode,"Spr_turnPosBg")
	    turnPosBgSpr:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("sx_img_table_turntable"..self.playerSeatIdx..".png"))
	end

	--是否是房主
	gt.isCreateUserId = self:isRoomCreateUserId(enterRoomMsgTbl.kCreateUserId, gt.playerData.uid)

	--是否不是房主建房
	if enterRoomMsgTbl.kDeskCreatedType and enterRoomMsgTbl.kDeskCreatedType == 0 then
		gt.CreateRoomFlag = true
	else
		gt.CreateRoomFlag = false
	end

	self.m_StartGameButtonPos = enterRoomMsgTbl.kStartGameButtonPos

	-- 断线重连提示
	self.node_top = cc.CSLoader:createNode("top_nodePlayScene.csb")
	self:addChild(self.node_top,1000)
	self.node_top:setPosition(cc.p(gt.winCenter.x,720))

	self.NodeTop_dot = gt.seekNodeByName(self.node_top, "Node_dot")
	self.NodeTop_dot:setVisible(false)

	self.Img_dot = {}
	for i =1, 3 do
		self.Img_dot[i] = gt.seekNodeByName(self.node_top, "Img_dot"..i)
		self.Img_dot[i]:setVisible(false)
	end

	-- self:playSelectSeatAni()

	-- 接收消息分发函数
	gt.registerEventListener("MJSceneAddText",self,self.top)
	gt.registerEventListener("ENDGAME", self, self.addAction11_9_node_tmp)

	gt.socketClient:registerMsgListener(gt.GC_ROOM_CARD, self, self.onRcvRoomCard)
	gt.socketClient:registerMsgListener(gt.GC_ENTER_ROOM, self, self.onRcvEnterRoom)
	gt.socketClient:registerMsgListener(gt.GC_ADD_PLAYER, self, self.onRcvAddPlayer)
	gt.socketClient:registerMsgListener(gt.GC_REMOVE_PLAYER, self, self.onRcvRemovePlayer)
	gt.socketClient:registerMsgListener(gt.GC_SYNC_ROOM_STATE, self, self.onRcvSyncRoomState)
	gt.socketClient:registerMsgListener(gt.GC_READY, self, self.onRcvReady)
	gt.socketClient:registerMsgListener(gt.GC_OFF_LINE_STATE, self, self.onRcvOffLineState)
	gt.socketClient:registerMsgListener(gt.GC_ROUND_STATE, self, self.onRcvRoundState)
	gt.socketClient:registerMsgListener(gt.GC_START_GAME, self, self.onRcvStartGame)
	gt.socketClient:registerMsgListener(gt.GC_TURN_SHOW_MJTILE, self, self.onRcvTurnShowMjTile)
	gt.socketClient:registerMsgListener(gt.GC_SYNC_SHOW_MJTILE, self, self.onRcvSyncShowMjTile)
	gt.socketClient:registerMsgListener(gt.GC_MAKE_DECISION, self, self.onRcvMakeDecision)
	gt.socketClient:registerMsgListener(gt.GC_GANG_AFTER_CHI_PENG, self, self.onRcvGangAfterChiPeng)
	gt.socketClient:registerMsgListener(gt.GC_SYNC_MAKE_DECISION, self, self.onRcvSyncMakeDecision)
	gt.socketClient:registerMsgListener(gt.GC_CHAT_MSG, self, self.onRcvChatMsg)
	gt.socketClient:registerMsgListener(gt.GC_ROUND_REPORT, self, self.onRcvRoundReport)
	gt.socketClient:registerMsgListener(gt.GC_FINAL_REPORT, self, self.onRcvFinalReport)
    gt.socketClient:registerMsgListener(gt.GC_PIAO_MSG, self, self.onRcvPiao)
    gt.socketClient:registerMsgListener(gt.GC_PIAO_NUM_MSG, self, self.onRevPiaoNumMes)
    gt.socketClient:registerMsgListener(gt.GC_TOAST, self, self.onRcvToast)
    
	gt.registerEventListener(gt.EventType.BACK_MAIN_SCENE, self, self.backMainSceneEvt)
	gt.registerEventListener(gt.EventType.RELOGIN_WHEN_ERROR, self, self.reloginWhenError)


	gt.socketClient:registerMsgListener(gt.GC_START_DECISION, self, self.onRcvStartDecision)
	gt.socketClient:registerMsgListener(gt.GC_SYNC_START_PLAYER_DECISION, self, self.onRcvSyncStartDecision)
	gt.socketClient:registerMsgListener(gt.GC_SYNC_BAR_TWOCARD, self, self.onRcvSyncBarTwoCard)
	--海底捞月
	gt.socketClient:registerMsgListener(gt.CG_SYNC_HAIDI, self, self.onHaidiRcvMakeDescision)
	--展示海底牌
	gt.socketClient:registerMsgListener(gt.CG_TURN_HAIDI, self, self.showHaidiInLayer)

	-- 断线重连
	gt.socketClient:registerMsgListener(gt.GC_LOGIN, self, self.onRcvLogin)

	-- 跑马灯
	--gt.socketClient:registerMsgListener(gt.GC_MARQUEE, self, self.onRcvMarquee)

	-- 扎鸟
	gt.socketClient:registerMsgListener(gt.GC_ZHANIAO, self, self.onRcvZhaNiao)

	gt.socketClient:registerMsgListener(gt.GC_LOGIN_SERVER, self, self.onRcvLoginServer)

	-- 同步用户分数
	gt.socketClient:registerMsgListener(gt.GC_UPDATE_SCORE, self, self.onRcvUpdateScore)

	-- 定位返回经纬度
	-- gt.socketClient:registerMsgListener(gt.CG_LONGITUDE_LATITUDE, self, self.PlayerLocationInformation)

	--可支对消息
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_ZHIDUI, self, self.onRcvZhiDui)

	gt.socketClient:registerMsgListener(gt.GC_LOGIN_GATE, self, self.onRcvLoginGate)

	gt.socketClient:registerMsgListener(gt.GC_SELECT_SEAT, self, self.onRcvSelectSeat)

	-- 收到视频邀请
	gt.socketClient:registerMsgListener(gt.RECEIVE_VIDEO_INVITATION, self, self.onRcvReceiveVideoInvitation)

	-- 视频邀请忙线中
	gt.socketClient:registerMsgListener(gt.INBUSY_VIDEO_INVITATION, self, self.onRcvBusyVideoInvitation)

	-- 视频已连线
	gt.socketClient:registerMsgListener(gt.ONLINE_VIDEO_INVITATION, self, self.onRcvOnlineVideoInvitation)

	-- 关闭视频
	gt.socketClient:registerMsgListener(gt.SHUTDOWN_VIDEO_INVITATION, self, self.onRcvShutdownVideoInvitation)

	-- 查看是否为vip防作弊房间
	gt.socketClient:registerMsgListener(gt.UPDATE_USER_VIP_INFO, self, self.onRcvUpdateUserVipInfo)

	gt.registerEventListener("EVENT_CANCLE_HU", self, self.onCancleHu)
	
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",
								handler(self, self.onEnterBackground))
	eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
	local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
								handler(self, self.onEnterForeground))
	eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)


end

function MJScene:onEnterBackground()
end

function MJScene:onEnterForeground()
	gt.dump(self.roomPlayers)

	if self.FinalReportFlag then
		for i = 1, 4 do
			if self.m_clockLabel[i] then
			    self.m_clockLabel[i]:setString("")
			    self.m_clockLabel[i]:setVisible(false)
				self.m_TimeProgress[i]:setPercentage(0)
				self.m_TimeProgress[i]:stopAllActions()
				self.clockSprite[i]:setVisible(false)
		        if self._time[i] then
		            gt.scheduler:unscheduleScriptEntry(self._time[i])
		            self._time[i] = nil
		        end
				cc.UserDefault:getInstance():setIntegerForKey("ClockTime"..i, 0)
			end
		end
	else
		if self.roomPlayers then
			local roomPlayer = self.roomPlayers[self.turnSeatIdx]
			if roomPlayer then
				self:setClockTime(roomPlayer)
			end
		end
	end
end

function MJScene:top()
	if self.node_top then 
		self.node_top:setPosition(cc.p(gt.winCenter.x,720))
		self.node_top:stopAllActions()
		self.node_top:runAction(cc.MoveTo:create(0.3,cc.p(gt.winCenter.x,720-43)))
		self:dynamicTopTipsShow(true)
	end
end

function MJScene:removetop()
	if self.node_top then
		self.node_top:stopAllActions()
		self.node_top:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.MoveTo:create(0.5,cc.p(gt.winCenter.x,720))
		,cc.CallFunc:create(function(sender)
			self:dynamicTopTipsShow(false)
		end)))
	end
end

function MJScene:dynamicTopTipsShow(isShow)
	local PointsCount = 2
 	local setPoints = function()
 		PointsCount = PointsCount + 1

 		if PointsCount > 4 then
 			PointsCount = 1
 		end

 		if PointsCount == 1 then
 			--self.loginConnect:setString("")
			for i = 1, 3 do
				self.Img_dot[i]:setVisible(false)
			end
 		elseif PointsCount == 2 then
 			--self.loginConnect:setString(".")
			self.Img_dot[1]:setVisible(true)
			for i = 2, 3 do
				self.Img_dot[i]:setVisible(false)
			end
 		elseif PointsCount == 3 then
 			--self.loginConnect:setString("..")
			for i = 1, 2 do
				self.Img_dot[i]:setVisible(true)
			end
			for i = 3, 3 do
				self.Img_dot[i]:setVisible(false)
			end
 		elseif PointsCount == 4 then
 			--self.loginConnect:setString("......")
			for i =1, 3 do
				self.Img_dot[i]:setVisible(true)
			end
 		end
	end

	if isShow then
		if self.dynamicTopTipsSchedulerEntry == nil then
			self.Img_dot[1]:setVisible(true)
			for i = 2, 3 do
				self.Img_dot[i]:setVisible(false)
			end
			self.NodeTop_dot:setVisible(true)
			self.dynamicTopTipsSchedulerEntry = gt.scheduler:scheduleScriptFunc(setPoints, 0.3, false)
		end
	else
		self.NodeTop_dot:setVisible(false)
 		if self.dynamicTopTipsSchedulerEntry then
 			gt.scheduler:unscheduleScriptEntry(self.dynamicTopTipsSchedulerEntry)
 			self.dynamicTopTipsSchedulerEntry = nil
 		end
	end
end

function MJScene:setPlayInfo(_state, _playerCount)
	-- 玩法类型
	local playTypeDesc = ""
	self.playType = _state
	if self.playType == 100001 then
		gt.createType = 1
		playTypeDesc = "推倒胡"
		self.csType=false
		self.numPlayer = 4
		gt.totalPlayerNum = 4
	elseif self.playType == 100002 then
		gt.createType = 2
		playTypeDesc = "扣点点"
		self.csType=false 
		self.numPlayer = 4
		gt.totalPlayerNum = 4
	elseif self.playType == 100004 then
		gt.createType = 3
		playTypeDesc = "立四"
		self.csType=false
		self.numPlayer = 4
		gt.totalPlayerNum = 4
	elseif self.playType == 100005 then
		gt.createType = 4
		playTypeDesc = "晋中"
		self.csType=false
		self.numPlayer = 4
		gt.totalPlayerNum = 4
	elseif self.playType == 100003 then
		gt.createType = 5
		playTypeDesc = "运城贴金"
		self.csType=false
		self.numPlayer = 4
		gt.totalPlayerNum = 4
	elseif self.playType == 100006 then
		gt.createType = 6
		playTypeDesc = "拐三角"
		self.csType=false
		self.numPlayer = 3
		gt.totalPlayerNum = 3
    elseif self.playType == 100008 then
		gt.createType = 7
		playTypeDesc = "硬三嘴"
		self.csType=false
		self.numPlayer = 4
		gt.totalPlayerNum = 4	
    elseif self.playType == 100009 then
		gt.createType = 8
		playTypeDesc = "洪洞王牌"
		self.csType=false
		self.numPlayer = 4
		gt.totalPlayerNum = 4	
    elseif self.playType == 100010 then
		gt.createType = 9
		playTypeDesc = "一门牌"
		self.csType=false
		self.numPlayer = 4
		gt.totalPlayerNum = 4	
	elseif self.playType == 100012 then
		gt.createType = 10
		playTypeDesc = "二人扣点点"
		self.csType=false
		self.numPlayer = 2
		gt.totalPlayerNum = 2
	elseif self.playType == 100013 then
		gt.createType = 11
		playTypeDesc = "三人扣点点"
		self.csType=false
		self.numPlayer = 3
		gt.totalPlayerNum = 3
	elseif self.playType == 100014 then
		gt.createType = 12
		playTypeDesc = "二人推倒胡"
		self.csType=false
		self.numPlayer = 2
		gt.totalPlayerNum = 2
	elseif self.playType == 100015 then
		gt.createType = 13
		playTypeDesc = "三人推倒胡"
		self.csType=false
		self.numPlayer = 3
		gt.totalPlayerNum = 3
	elseif self.playType == 102005 then
		gt.createType = 14
		playTypeDesc = "二人晋中"
		self.csType=false
		self.numPlayer = 2
		gt.totalPlayerNum = 2
	elseif self.playType == 103005 then
		gt.createType = 15
		playTypeDesc = "三人晋中"
		self.csType=false
		self.numPlayer = 3
		gt.totalPlayerNum = 3
	elseif self.playType == 102008 then
		gt.createType = 16
		playTypeDesc = "二人硬三嘴"
		self.csType=false
		self.numPlayer = 2
		gt.totalPlayerNum = 2
	elseif self.playType == 103008 then
		gt.createType = 17
		playTypeDesc = "三人硬三嘴"
		self.csType=false
		self.numPlayer = 3
		gt.totalPlayerNum = 3
	elseif self.playType == 102009 then
		gt.createType = 18
		playTypeDesc = "二人洪洞王牌"
		self.csType=false
		self.numPlayer = 2
		gt.totalPlayerNum = 2
	elseif self.playType == 103009 then
		gt.createType = 19
		playTypeDesc = "三人洪洞王牌"
		self.csType=false
		self.numPlayer = 3
		gt.totalPlayerNum = 3
	elseif self.playType == 102010 then
		gt.createType = 20
		playTypeDesc = "二人一门牌"
		self.csType=false
		self.numPlayer = 2
		gt.totalPlayerNum = 2
	elseif self.playType == 103010 then
		gt.createType = 21
		playTypeDesc = "三人一门牌"
		self.csType=false
		self.numPlayer = 3
		gt.totalPlayerNum = 3
	elseif self.playType == 100016 then
		gt.createType = 22
		playTypeDesc = "忻州扣点点"
		self.csType=false 
		self.numPlayer = 4
		gt.totalPlayerNum = 4
	elseif self.playType == 100017 then
		gt.createType = 23
		playTypeDesc = "临汾撵中子"
		self.csType=false 
		self.numPlayer = 4
		gt.totalPlayerNum = 4
	elseif self.playType == 100018 then 
		gt.createType = 23
		playTypeDesc = "陵川靠八张"
		self.csType=false 
		self.numPlayer = 4
		gt.totalPlayerNum = 4
	end

	local function playerCountText(playerCount )
		if playerCount == 2 then
			return "二人"
		elseif playerCount == 3 then
			return "三人" 
		end
		return ""
	end 

	if _playerCount then
		self.numPlayer = _playerCount
		gt.totalPlayerNum = _playerCount
		if self.playType < 100012 or (self.playType > 100015 and self.playType < 102005) then
			playTypeDesc = playerCountText(_playerCount)..playTypeDesc
		end
	end

	--人数
	if gt.totalPlayerNum == 4 then
		self.playersType = 4
	elseif gt.totalPlayerNum == 3 then
		self.playersType = 3
	elseif gt.totalPlayerNum == 2 then
		self.playersType = 2
	end

	gt.log("------------------------------------------self.playersType", self.playersType)
	
	-- 设置不同人数 出牌显示的每行个数和位置
	if self.playersType == 2 then
		mjTilePerLine[2] = {}

		mjTilePerLine[2][1] = {}
		mjTilePerLine[2][2] = {}
		mjTilePerLine[2][3] = {}
		mjTilePerLine[2][4] = {}

		mjTilePerLine[2][1].deviationX = -17
		mjTilePerLine[2][2].deviationX = 0
		mjTilePerLine[2][3].deviationX = 25
		mjTilePerLine[2][4].deviationX = -185

		mjTilePerLine[2][1].deviationY = 26
		mjTilePerLine[2][2].deviationY = 0
		mjTilePerLine[2][3].deviationY = 130
		mjTilePerLine[2][4].deviationY = 0

		mjTilePerLine[2][1].lineCount = 10
		mjTilePerLine[2][2].lineCount = 16
		mjTilePerLine[2][3].lineCount = 10
		mjTilePerLine[2][4].lineCount = 16
	elseif self.playersType == 3 then
		mjTilePerLine[3] = {}

		mjTilePerLine[3][1] = {}
		mjTilePerLine[3][2] = {}
		mjTilePerLine[3][3] = {}
		mjTilePerLine[3][4] = {}

		mjTilePerLine[3][1].deviationX = 100
		mjTilePerLine[3][2].deviationX = 80
		mjTilePerLine[3][3].deviationX = -90
		mjTilePerLine[3][4].deviationX = -91

		mjTilePerLine[3][1].deviationY = -50
		mjTilePerLine[3][2].deviationY = 0
		mjTilePerLine[3][3].deviationY = 50
		mjTilePerLine[3][4].deviationY = 0

		mjTilePerLine[3][1].lineCount = 11
		mjTilePerLine[3][2].lineCount = 11
		mjTilePerLine[3][3].lineCount = 11
		mjTilePerLine[3][4].lineCount = 11
	else
		mjTilePerLine[4] = {}

		mjTilePerLine[4][1] = {}
		mjTilePerLine[4][2] = {}
		mjTilePerLine[4][3] = {}
		mjTilePerLine[4][4] = {}

		mjTilePerLine[4][1].deviationX = 0
		mjTilePerLine[4][2].deviationX = 0
		mjTilePerLine[4][3].deviationX = 0
		mjTilePerLine[4][4].deviationX = 0

		mjTilePerLine[4][1].deviationY = 0
		mjTilePerLine[4][2].deviationY = 0
		mjTilePerLine[4][3].deviationY = 0
		mjTilePerLine[4][4].deviationY = 0

		mjTilePerLine[4][1].lineCount = 6
		mjTilePerLine[4][2].lineCount = 6
		mjTilePerLine[4][3].lineCount = 6
		mjTilePerLine[4][4].lineCount = 6
	end

	return playTypeDesc
end

function MJScene:getAppVersion()
	if device.platform == "windows" then
		return 11
	end

	if device.platform == "ios" then
		return 10
	end
	
	local luaBridge = nil
	local ok, appVersion = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		ok, appVersion = luaBridge.callStaticMethod("AppController", "getVersionName")
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		ok, appVersion = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")
	end

	local data = string.split(appVersion, ".")

	local versionNumber = 0

	if data[1] then
		versionNumber = versionNumber + tonumber(data[1])*10
	end

	if data[2] then
		versionNumber = versionNumber + tonumber(data[2])
	end

	return versionNumber
end

function MJScene:getAppVersionShow()
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

function MJScene:setRoomInfoBtn(_type)
	if _type == 1 then
		self.roomInfoBtn:setContentSize(cc.size(209, 77))
		self.mjTypeLabel:setVisible(false)
		self.Text_5:setVisible(false)
	else
		if self.roomInfoBtn:getContentSize().height == 77 then
			self.roomInfoBtn:setContentSize(cc.size(209, 200))
			self.mjTypeLabel:setVisible(true)
			self.Text_5:setVisible(true)
		else
			self.roomInfoBtn:setContentSize(cc.size(209, 77))
			self.mjTypeLabel:setVisible(false)
			self.Text_5:setVisible(false)
		end
	end
end

function MJScene:onIsVideoPermittedResult(result)
	gt.log("---------------------onIsVideoPermittedResult")
	if tonumber(result) == 1 then
	end
end

function MJScene:onCloseVideoResult(result)
	gt.log("---------------------onCloseVideoResult")
	self.playVideoPanel:setVisible(false)
	self.videoingImg:setVisible(false)

	-- local msgToSend = {}
	-- msgToSend.m_msgId = gt.SHUTDOWN_VIDEO_INVITATION
	-- msgToSend.m_reqUserId = gt.playerData.uid
	-- msgToSend.m_userId = gt.receiveUserId
	-- 	gt.log("-------------gt.receiveUserId5", gt.receiveUserId)

	-- -- msgToSend.m_strUUID = gt.socketClient:getPlayerUUID()
	-- gt.socketClient:sendMessage(msgToSend)

	self.countCloseVideo = 1
	self.isOnVideo = false
end
function MJScene:onOffLineCloseVideoResult()
	self:getLuaBridge()
	if gt.isIOSPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "OffLineCloseVideo", {})
	elseif gt.isAndroidPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "OffLineCloseVideo", nil,"()V")
	end
end
function MJScene:onRcvToast(msgTbl)
	gt.log("-----------------------------------------------888111111111111")
	if self.total_count ~= nil then
	gt.log("-----------------------------------------------888222222222222")
		return
	end
	self.toastMsgTbl = msgTbl
	self.total_count = 1;
    self.updateToastSchedule = gt.scheduler:scheduleScriptFunc(handler(self, self.updateToast), 10, false)
end

function MJScene:updateToast(delta)
	gt.log("-----------------------------------------------8883333333333333333")
	if self.total_count >= 5 then
		self.total_count = nil
        gt.scheduler:unscheduleScriptEntry(self.updateToastSchedule)
        return
	end
	gt.log("-----------------------------------------------888444444444444444")
	self.total_count = self.total_count + 1
	Toast.showToast(self, self.toastMsgTbl.m_MessageList[1], 2)
end

--是否是房主
function MJScene:isRoomCreateUserId(createUserId, UserId)
	if createUserId == UserId then
		return true
	else
		return false
	end

	return false
end
	
function MJScene:showPosition()
	local Node_selectseat = gt.seekNodeByName(self.rootNode, "Node_selectseat")
	
	gt.log("------------------gt.createType", gt.createType)
	self.PositionBtn = {}
	if gt.createType == 6 or gt.createType == 11 or gt.createType == 13 or gt.createType == 15  or gt.createType == 17  or gt.createType == 19  or gt.createType == 21 then
			self.PositionBtn[4] = gt.seekNodeByName(Node_selectseat, "Position4_Btn")
			self.PositionBtn[4]:addClickEventListener(function(sender)
				local msgToSend = {}
				msgToSend.kMId = gt.CG_SELECT_SEAT
				msgToSend.kUserId = gt.playerData.uid
				msgToSend.kPos = sender:getTag() - 1
				gt.socketClient:sendMessage(msgToSend)
			end)
			self.PositionBtn[1] = gt.seekNodeByName(Node_selectseat, "Position1_Btn")
			self.PositionBtn[1]:addClickEventListener(function(sender)
				local msgToSend = {}
				msgToSend.kMId = gt.CG_SELECT_SEAT
				msgToSend.kUserId = gt.playerData.uid
				msgToSend.kPos = sender:getTag() - 1
				gt.socketClient:sendMessage(msgToSend)
			end)
			self.PositionBtn[2] = gt.seekNodeByName(Node_selectseat, "Position2_Btn")
			self.PositionBtn[2]:addClickEventListener(function(sender)
				local msgToSend = {}
				msgToSend.kMId = gt.CG_SELECT_SEAT
				msgToSend.kUserId = gt.playerData.uid
				msgToSend.kPos = sender:getTag() - 1
				gt.socketClient:sendMessage(msgToSend)
			end)
			self.PositionBtn[3] = gt.seekNodeByName(Node_selectseat, "Position3_Btn")
			self.PositionBtn[3]:setVisible(false)
	elseif gt.createType == 10 or gt.createType == 12 or gt.createType == 14 or gt.createType == 16 or gt.createType == 18 or gt.createType == 20 then
			self.PositionBtn[4] = gt.seekNodeByName(Node_selectseat, "Position4_Btn")
			self.PositionBtn[4]:addClickEventListener(function(sender)
				local msgToSend = {}
				msgToSend.kMId = gt.CG_SELECT_SEAT
				msgToSend.kUserId = gt.playerData.uid
				msgToSend.kPos = sender:getTag() - 1
				gt.socketClient:sendMessage(msgToSend)
			end)
			self.PositionBtn[1] = gt.seekNodeByName(Node_selectseat, "Position1_Btn")
			self.PositionBtn[1]:addClickEventListener(function(sender)
				local msgToSend = {}
				msgToSend.kMId = gt.CG_SELECT_SEAT
				msgToSend.kUserId = gt.playerData.uid
				msgToSend.kPos = sender:getTag() - 1
				gt.socketClient:sendMessage(msgToSend)
			end)
			self.PositionBtn[3] = gt.seekNodeByName(Node_selectseat, "Position3_Btn")
			self.PositionBtn[3]:setVisible(false)
			self.PositionBtn[2] = gt.seekNodeByName(Node_selectseat, "Position2_Btn")
			self.PositionBtn[2]:setVisible(false)
	else
		for i = 1, 4 do
			self.PositionBtn[i] = gt.seekNodeByName(Node_selectseat, "Position"..i.."_Btn")
			self.PositionBtn[i]:addClickEventListener(function(sender)
				local msgToSend = {}
				msgToSend.kMId = gt.CG_SELECT_SEAT
				msgToSend.kUserId = gt.playerData.uid
				msgToSend.kPos = sender:getTag() - 1
				gt.socketClient:sendMessage(msgToSend)
			end)
		end
	end
end

function MJScene:showPositionBtn(roomPlayer)
	-- if gt.createType == 6 then
	-- 	if roomPlayer.seatIdx == 3 then
	-- 		self.PositionBtn[roomPlayer.displaySeatIdx]:setVisible(false)
	-- 	end
	-- 	self.PositionBtn[4]:setVisible(false)
	-- 	self.PositionBtn[1]:setVisible(false)
	-- 	self.PositionBtn[2]:setVisible(false)
	-- elseif gt.createType == 10 then
	-- 	self.PositionBtn[4]:setVisible(false)
	-- 	self.PositionBtn[1]:setVisible(false)
	-- end
end

function MJScene:setVideoInfo()
	gt.log(debug.traceback())
	for i = 1, 3 do
		local nameTxt = gt.seekNodeByName(self.rootNode, "Txt_name"..i)
		nameTxt:setString("")
		local playvideoBtn = gt.seekNodeByName(self.rootNode, "Btn_playvideo"..i)
		playvideoBtn:setEnabled(false)
		gt.log("--------------------playvideoBtn:setEnabled(false)")
	end
	self.videoRoomPlayers = {}
	for i, v in pairs(self.roomPlayers) do
		gt.dump(v)
		gt.log("---------------------v.uid", v.uid)
		gt.log("---------------------gt.playerData.uid", gt.playerData.uid)
		if v.uid ~= gt.playerData.uid then
			self.videoRoomPlayers[v.uid] = v
		end
	end

	local index = 1
	for i, v in pairs(self.videoRoomPlayers) do
		gt.dump(v)
		local nameTxt = gt.seekNodeByName(self.rootNode, "Txt_name"..index)
		gt.log("--------------------v.nickname", v.nickname)
		gt.log("--------------------v.uid", v.uid)
		gt.log("--------------------self.deskId", self.deskId)
		nameTxt:setString(v.nickname)
		-- nameTxt:setString(tostring(v.uid))
        local IsSendForbidVideo = cc.UserDefault:getInstance():getIntegerForKey("IsSendForbidVideo"..self.deskId, 0)
		gt.log("--------------------self.videoRoomPlayers[v.uid].m_videoPermission", self.videoRoomPlayers[v.uid].m_videoPermission)
		gt.log("--------------------v.uid", v.uid)
		gt.log("--------------------IsSendForbidVideo", IsSendForbidVideo)
		if v.m_videoPermission == 1 and IsSendForbidVideo == 1 then
			local playvideoBtn = gt.seekNodeByName(self.rootNode, "Btn_playvideo"..index)
			playvideoBtn:setTag(v.uid)
			playvideoBtn:setEnabled(true)
			gt.log("--------------------playvideoBtn:setEnabled(true)")
		end
		index = index + 1
	end
end

function MJScene:onRcvReceiveVideoInvitation(msgTbl)
	gt.log("收到视频邀请")
	-- dump(msgTbl)
		gt.log("----------------------------self.isOnVideo", self.isOnVideo)
	if self.isOnVideo then
        --告知服务器，正在视频中
		local msgToSend = {}
		msgToSend.kMId = gt.INBUSY_VIDEO_INVITATION
		msgToSend.kReqUserId = msgTbl.kReqUserId
		msgToSend.kUserId = msgTbl.kUserId
		-- gt.receiveUserId = msgTbl.m_userId
		gt.log("-------------gt.receiveUserId1", gt.receiveUserId)
		-- msgToSend.m_strUUID = gt.socketClient:getPlayerUUID()
		gt.socketClient:sendMessage(msgToSend)
    else
    	self.isOnVideo = true
		local msgToSend = {}
		msgToSend.kMId = gt.ONLINE_VIDEO_INVITATION
		msgToSend.kReqUserId = msgTbl.kReqUserId
		msgToSend.kUserId = msgTbl.kUserId
		gt.receiveUserId = msgTbl.kUserId
		gt.log("-------------gt.receiveUserId2", gt.receiveUserId)
		-- msgToSend.m_strUUID = gt.socketClient:getPlayerUUID()
		gt.socketClient:sendMessage(msgToSend)
		self.videoingImg:setVisible(true)

    	local channelName = msgTbl.kReqUserId.."_"..msgTbl.kUserId
		local isShowLocalVideoFrame = false
		self:getLuaBridge()
		if gt.isIOSPlatform() then
			-- gt.soundEngine:stopAll()
			local ok, ret = self.luaBridge.callStaticMethod("AppController", "startVideo", {channelName = channelName, isShowLocalVideoFrame = isShowLocalVideoFrame})
		elseif gt.isAndroidPlatform() then
			gt.log("-------------channelName1", channelName)
			local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "startVideo", {channelName, isShowLocalVideoFrame},"(Ljava/lang/String;Z)V")
			gt.log("-------------channelName2", channelName)
		end
	end
end
function MJScene:onRcvBusyVideoInvitation(msgTbl)
	gt.log("视频邀请忙线中")
	gt.dump(msgTbl)

	--dump(self.roomPlayers)
	--FLOG("Recieve SKYEYE_INBUSY_VIDEO_INVITATION");
            -- --对方正在视频中，提示用户
            -- CMD_C_SEND_VIDEO_INVITATION *inviteInfo = (CMD_C_SEND_VIDEO_INVITATION *)data;
            -- videoUserId = inviteInfo->wInviteeUser;
            -- --FLOG("Recieve SKYEYE_INBUSY_VIDEO_INVITATION ,wInviteeUser:"+utility::toString(videoUserId));
            
            -- GamePlayer* pPlayer = getPlayerByUserID(inviteInfo->wInviteeUser);
            -- if (!pPlayer)
            -- {
            --     return;
            -- }
            -- else
            -- {
            --     WidgetFun::setVisible(this,"CheckingVideo_Busy",true);
            --     std::string reminderText;
            --     char reminderText_str[200];
            --     sprintf(reminderText_str,"%s 正在视频中，请稍候再试",pPlayer->GetNickName().c_str());
            --     reminderText = utility::toString(reminderText_str);
            --     cocos2d::Node* pTxt = WidgetFun::getChildWidget(this,"CheckingVideo_Busy_Note");
            --     WidgetFun::setText(pTxt, reminderText.c_str());
            -- }

            if self.videoRoomPlayers[msgTbl.kUserId] == nil then
            	return
            else
				dump(self.videoRoomPlayers[msgTbl.kUserId])
    			-- Toast.showToast(self, self.videoRoomPlayers[msgTbl.m_userId].nickname..tostring(msgTbl.m_userId).."正在视频中，请稍候再试", 2)
    			Toast.showToast(self, self.videoRoomPlayers[msgTbl.kUserId].nickname.."正在视频中，请稍候再试", 2)
            end

            -- --去掉视频连线等待提示
            -- cocos2d::Node* AnimateNode = WidgetFun::getChildWidget(this, "VideoWaitingAnimateNode");
            -- AnimateNode->removeAllChildren();

end
function MJScene:onRcvOnlineVideoInvitation(msgTbl)
	gt.log("视频已连线")
	gt.dump(msgTbl)
	--对方视频通道已建立，加入该用户的channel
    self.isOnVideo = true
    -- ASSERT(dataSize==sizeof(CMD_C_SEND_VIDEO_INVITATION));
    -- if (dataSize!=sizeof(CMD_C_SEND_VIDEO_INVITATION))
    --     return;
    -- CMD_C_SEND_VIDEO_INVITATION *inviteInfo = (CMD_C_SEND_VIDEO_INVITATION *)data;
    -- videoUserId = inviteInfo->wInviteeUser;
    --FLOG("Recieve SKYEYE_ONLINE_VIDEO_INVITATION ,wInviteeUser:"+utility::toString(videoUserId));
    
	gt.receiveUserId = msgTbl.kUserId
		gt.log("-------------gt.receiveUserId3", gt.receiveUserId)
    local channelName = gt.playerData.uid.."_"..msgTbl.kUserId

    self.setvideoImg:setVisible(false)
	self.playVideoPanel:setVisible(true)
	-- self.videoingImg:setVisible(true)

	local isShowLocalVideoFrame = true
	self:getLuaBridge()
	if gt.isIOSPlatform() then
		-- gt.soundEngine:stopAll()
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "startVideo", {channelName = channelName, isShowLocalVideoFrame = isShowLocalVideoFrame})
	elseif gt.isAndroidPlatform() then
		gt.log("-------------channelName1", channelName)
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "startVideo", {channelName, isShowLocalVideoFrame},"(Ljava/lang/String;Z)V")
		gt.log("-------------channelName2", channelName)
	end
    -- JniFun::startVideo(channelName, TRUE);
		gt.log("-------------startVideo")
    
    if device.platform == "windows" then
    	local videocloseBtn = gt.seekNodeByName(self.rootNode, "Btn_videoclose")
    	videocloseBtn:setVisible(true)
		gt.addBtnPressedListener(videocloseBtn, function()
			self:onCloseVideoResult()
		end)
	else
		self:getLuaBridge()
		if gt.isIOSPlatform() then
			self.luaBridge.callStaticMethod("AppController", "registerCloseVideoHandler", {scriptHandler = handler(self, self.onCloseVideoResult)})
		elseif gt.isAndroidPlatform() then
			self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerCloseVideoHandler", {handler(self, self.onCloseVideoResult)}, "(I)V")
		end
	end

    self.countCloseVideo = 0
	self.scheduleCloseVideoHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.CloseVideo), 0.5, false)

    -- --去掉视频连线等待提示
    -- cocos2d::Node* AnimateNode = WidgetFun::getChildWidget(this, "VideoWaitingAnimateNode");
    -- AnimateNode->removeAllChildren();
end
function MJScene:CloseVideo( )
		gt.log("----------------------------CloseVideo")
	if self.countCloseVideo == 1 then
		if self.scheduleCloseVideoHandler then
			gt.scheduler:unscheduleScriptEntry(self.scheduleCloseVideoHandler)
			self.scheduleCloseVideoHandler = nil
		end
		gt.log("----------------------------SHUTDOWN_VIDEO_INVITATION")
		local msgToSend = {}
		msgToSend.kMId = gt.SHUTDOWN_VIDEO_INVITATION
		msgToSend.kReqUserId = gt.playerData.uid
		msgToSend.kUserId = gt.receiveUserId
		gt.log("-------------gt.receiveUserId4", gt.receiveUserId)

		-- msgToSend.m_strUUID = gt.socketClient:getPlayerUUID()
		gt.socketClient:sendMessage(msgToSend)
    	self.countCloseVideo = 0

	 	-- local setSoundEngine = function()
	 	-- 	if self.setSoundEngineScheduler then
	 	-- 		gt.scheduler:unscheduleScriptEntry(self.setSoundEngineScheduler)
	 	-- 		self.setSoundEngineScheduler = nil
	 	-- 	end

			-- -- gt.soundEngine:stopAll()
			-- gt.log("-------------音效引擎")
			-- -- -- 音效引擎
			-- -- -- gt.soundEngine = require("app/Sound"):create()
			-- gt.soundEngine:lazyInit()

			-- -- local soundEftPercent = cc.UserDefault:getInstance():getIntegerForKey("Sound_Eft_Percent", 100)
			-- -- self.soundEffectVolume = soundEftPercent

			-- -- local musicPercent = cc.UserDefault:getInstance():getIntegerForKey("Music_Percent", 100)
			-- -- self.musicVolume = musicPercent

			-- gt.soundEngine:resumeAllSound()

			-- gt.soundEngine:playMusic("bgm2", true)
	 	-- end
	  --   self.setSoundEngineScheduler = gt.scheduler:scheduleScriptFunc(setSoundEngine, 5, false)
	end
end
function MJScene:onRcvShutdownVideoInvitation(msgTbl)
	gt.log("关闭视频")
	--dump(msgTbl)
	--发起者关闭视频，可以离开channel，隐藏“视频中”标识
    self.isOnVideo = false

	self.videoingImg:setVisible(false)

	self:getLuaBridge()
	if gt.isIOSPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "leaveVideo")
	elseif gt.isAndroidPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "leaveVideo", nil, "()V")
	end
   -- JniFun::leaveVideo();

    -- videoUserId = 0;
    -- WidgetFun::setVisible(this,"CheckingVideo_Recording",false);
    
    -- --释放cocos音频资源，再延时5秒调用音频
    -- SoundFun::Instance().releaseAudioResource();
    -- cocos2d::Director::getInstance()->getScheduler()->schedule(CC_SCHEDULE_SELECTOR(XZDDGameScence::delayPlayMusic), this, 0, 0, 5.0f, false);
end
function MJScene:onRcvUpdateUserVipInfo(msgTbl)
	gt.log("查看是否为vip防作弊房间")
	-- msgTbl.m_userId
	-- msgTbl.m_strGPS
	-- msgTbl.m_VideoPermit
	--FLOG("Recieve SKYEYE_UPDATE_USER_VIP_INFO");
            --效验消息
            -- ASSERT(dataSize==sizeof(CMD_C_USER_UPDATE_VIP_INFO));
            -- if (dataSize!=sizeof(CMD_C_USER_UPDATE_VIP_INFO))
            --     return;
            
            -- CMD_C_USER_UPDATE_VIP_INFO *usersInfo = (CMD_C_USER_UPDATE_VIP_INFO *)data;=

	local GPSTable = string.split(msgTbl.kStrGPS, ",")
	if GPSTable[1] and self.mapRoomPlayers[msgTbl.kUserId] then
	    self.mapRoomPlayers[msgTbl.kUserId].userLanitude = GPSTable[1]
	end
	if GPSTable[2] and self.mapRoomPlayers[msgTbl.kUserId] then
	    self.mapRoomPlayers[msgTbl.kUserId].userLongitude = GPSTable[2]
	end

    if self.roomPlayers[msgTbl.kUserId] then
	    self.roomPlayers[msgTbl.kUserId].m_videoPermission = msgTbl.kVideoPermit
	end

	gt.log("--------------------msgTbl.userId1", msgTbl.kUserId)
    if self.unSeatRoomPlayers[msgTbl.kUserId] then
	gt.log("--------------------msgTbl.userId2", msgTbl.kUserId)
    	gt.dump(msgTbl)
	    self.unSeatRoomPlayers[msgTbl.kUserId].m_videoPermission = msgTbl.kVideoPermit
	end
    	gt.dump(self.unSeatRoomPlayers)

	self:setVideoInfo()
    --         --更新视频权限状态的显示
    --         iPlayer->upPlayerState();       
    
            -- for (int i = 0;i<MAX_PLAYER;i++)
            -- {
            --     XZDDPlayer*	iPlayer = m_pPlayer[i];
            --     if(iPlayer)
            --     {
            --         tagUserInfo *info = iPlayer->GetUserInfo();
            --         if(!info)
            --             continue;
                    
            --         for(int j=0; j<MAX_PLAYER;j++)
            --         {
            --             if(info->dwUserID == usersInfo->dwUserIds[j])
            --             {
            --                 info->enableVideo = usersInfo->wEnableVideo[j];
                            
            --                 --纵坐标
            --                 memcpy(info->szUserLongitude, usersInfo->szLongitude[j],LEN_USER_GPS);
            --                 info->szUserLongitude[CountArray(info->szUserLongitude)-1]=0;
                            
            --                 --横坐标
            --                 memcpy(info->szUserLanitude, usersInfo->szLantitude[j],LEN_USER_GPS);
            --                 info->szUserLanitude[CountArray(info->szUserLanitude)-1]=0;
                            
            --                 break;
            --             }
            --         }
                    
            --         --更新视频权限状态的显示
            --         iPlayer->upPlayerState();
            --     }
            -- }
end

--更新视频权限状态的显示
function MJScene:udatepPlayerState()

end

--上传GPS
function MJScene:UploadGpsInformation( )
	local infos = Utils.getLocationInfo()

	local msgToSend = {}
	msgToSend.kMId = gt.UPLOAD_GPS_INFORMATION
	msgToSend.kUserId = gt.playerData.uid
	-- msgToSend.m_strUUID = gt.socketClient:getPlayerUUID()
	msgToSend.kStrGPS = tostring(infos.longitude or 0)..","..tostring(infos.latitue or 0)
	gt.socketClient:sendMessage(msgToSend)

	gt.dumploglogin("-------------------------------UploadGpsInformation")
	gt.dumploglogin(msgToSend.kStrGPS)

	if self.mapRoomPlayers[gt.playerData.uid] then
	    self.mapRoomPlayers[gt.playerData.uid].userLanitude = infos.longitude
	    self.mapRoomPlayers[gt.playerData.uid].userLongitude = infos.latitue
	end
end

--取消胡牌
function MJScene:onCancleHu()
	--显示决策按钮
	local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
	decisionBtnNode:setVisible(true)
end

--显示能胡哪些牌
--card    点击的牌，int类型，个位是牌值，十位是花色
function MJScene:showHuCards(card)
	gt.log("显示能胡哪些牌")
	gt.dump(self.showHuCardsList)
	if card == nil then return end

	if self.showHuCardsList == nil or next(self.showHuCardsList) == nil then
		return
	end

	if self.showHuCardsPanel == nil then
		self.showHuCardsPanel = gt.seekNodeByName(csbNode,"Panel_hu_list")
		self.showHuCardsImage = gt.seekNodeByName(csbNode,"Image_hu_list")
	end

	gt.log("胡张显示 =========")
	--dump(self.showHuCardsList)

	if self.showHuCardsList ~= nil and next(self.showHuCardsList) then
		self.hulist = {}
		for i,v in pairs(self.showHuCardsList) do
			if v.kOutTile == card then
				self.hulist = v.kTingKou
				break
			end
		end

		if self.hulist == nil or #self.hulist == 0 then return end

		if #self.hulist > 0 then
			--先清理
			self.showHuCardsPanel:removeAllChildren()
			self.showHuCardsPanel:setVisible(true)
			self.showHuCardsImage:setVisible(true)
			self.showHuCardsPanel:setZOrder(999)
			self.showHuCardsImage:setZOrder(998)
		else
			self.showHuCardsPanel:setVisible(false)
			self.showHuCardsImage:setVisible(false)
		end
		-- local width = self.showHuCardsPanel:getContentSize().width
		-- local listtest = {}
		-- for i = 1, 17 do
		-- 	table.insert(listtest, self.hulist[i])
		-- end

		if #self.hulist > 0 and #self.hulist <= 17 then
			local width = 72*#self.hulist < 110 and 110 or 72*#self.hulist
			width = width == 144 and 160 or width
			local height = 80
			self.showHuCardsPanel:setContentSize(cc.size(width, height))
			self.showHuCardsImage:setContentSize(cc.size(width-36, height+30))
			for i, v in pairs(self.hulist) do
				gt.log("能胡哪张："..v)
				local mColor = math.modf(v/10)
				local mNum = v%10
				local mjTileName = Utils.getMJTileResName(4, mColor, mNum, self.isHZLZ, 1) --获取图片
				local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)  --创建精灵
				mjTileSpr:setScale(0.6)
				local mjInfo = {mjColor = mColor, mjNumber = mNum}

				-- 添加耗子牌标识
				if self.HaoZiCards then
					for i,card in ipairs(self.HaoZiCards) do
						if mColor == card._color and mNum == card._number then
							self:addMouseMark(mjTileSpr)	
						end		
					end
				end

				local surplusMjCount = self:surplusMjCount(mjInfo)
				local surplusMjCountSpr = cc.Sprite:createWithSpriteFrameName("sx_img_tingcount"..surplusMjCount..".png")  --创建精灵
				surplusMjCountSpr:setScale(2)
				mjTileSpr:addChild(surplusMjCountSpr)
				surplusMjCountSpr:setPosition(cc.p(mjTileSpr:getContentSize().width/2+13, mjTileSpr:getContentSize().height-5))

				self.showHuCardsPanel:addChild(mjTileSpr)
				mjTileSpr:setPosition(width*i/(#self.hulist+1), 36)
			end
		elseif #self.hulist > 17 then
			local lineCount = 0
			if #self.hulist%2 == 0 then
				lineCount = math.floor(#self.hulist/2)
			else
				lineCount = math.ceil(#self.hulist/2)
			end
			local width = 72*lineCount
			local height = 180
			self.showHuCardsPanel:setContentSize(cc.size(width, height))
			self.showHuCardsImage:setContentSize(cc.size(width-36, height+30))
			for i, v in pairs(self.hulist) do
				gt.log("能胡哪张："..v)
				local mColor = math.modf(v/10)
				local mNum = v%10
				local mjTileName = Utils.getMJTileResName(4, mColor, mNum, self.isHZLZ, 1) --获取图片
				local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)  --创建精灵
				mjTileSpr:setScale(0.6)
				local mjInfo = {mjColor = mColor, mjNumber = mNum}
				local surplusMjCount = self:surplusMjCount(mjInfo)

				-- 添加耗子牌标识
				if self.HaoZiCards then
					for i,card in ipairs(self.HaoZiCards) do
						if mColor == card._color and mNum == card._number then
							self:addMouseMark(mjTileSpr)	
						end		
					end
				end
				
				local surplusMjCountSpr = cc.Sprite:createWithSpriteFrameName("sx_img_tingcount"..surplusMjCount..".png")  --创建精灵
				surplusMjCountSpr:setScale(2)
				mjTileSpr:addChild(surplusMjCountSpr)
				surplusMjCountSpr:setPosition(cc.p(mjTileSpr:getContentSize().width/2+13, mjTileSpr:getContentSize().height-5))

				self.showHuCardsPanel:addChild(mjTileSpr)
				if i <= lineCount then
					mjTileSpr:setPosition(width*i/(lineCount+1), 134)
				else
					if #self.hulist%2 == 1 then
						mjTileSpr:setPosition(width*(i%lineCount)/(lineCount+1), 36)
					else
						mjTileSpr:setPosition(width*(i%lineCount+1)/(lineCount+1), 36)
					end
				end
			end
		end
	end
end

--显示能胡哪些牌
--已经听牌，点击查看胡牌按钮
function MJScene:showTingHuCards()
	gt.log("显示能胡哪些牌")
	gt.dump(self.hulist)

	if self.hulist ~= nil and next(self.hulist) then
		if self.showHuCardsPanel == nil then
			self.showHuCardsPanel = gt.seekNodeByName(csbNode,"Panel_hu_list")
			self.showHuCardsImage = gt.seekNodeByName(csbNode,"Image_hu_list")
		end

		if #self.hulist > 0 then
			--先清理
			self.showHuCardsPanel:removeAllChildren()
			self.showHuCardsPanel:setVisible(true)
			self.showHuCardsImage:setVisible(true)
			self.showHuCardsPanel:setZOrder(999)
			self.showHuCardsImage:setZOrder(998)
		else
			self.showHuCardsPanel:setVisible(false)
			self.showHuCardsImage:setVisible(false)
		end

		if #self.hulist > 0 and #self.hulist <= 17 then
			local width = 72*#self.hulist < 110 and 110 or 72*#self.hulist
			width = width == 144 and 160 or width
			local height = 80
			self.showHuCardsPanel:setContentSize(cc.size(width, height))
			self.showHuCardsImage:setContentSize(cc.size(width-36, height+30))
			for i, v in pairs(self.hulist) do
				-- gt.log("能胡哪张："..v)
				local mColor = math.modf(v/10)
				local mNum = v%10
				local mjTileName = Utils.getMJTileResName(4, mColor, mNum, self.isHZLZ, 1) --获取图片
				local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName) --创建精灵
				mjTileSpr:setScale(0.6)
				local mjInfo = {mjColor = mColor, mjNumber = mNum}

					-- 添加耗子牌标识
					if self.HaoZiCards then
						for i,card in ipairs(self.HaoZiCards) do
							if mColor == card._color and mNum == card._number then
								self:addMouseMark(mjTileSpr)	
							end		
						end
					end
					
				local surplusMjCount = self:surplusMjCount(mjInfo)
				local surplusMjCountSpr = cc.Sprite:createWithSpriteFrameName("sx_img_tingcount"..surplusMjCount..".png") --创建精灵
				surplusMjCountSpr:setScale(2)
				mjTileSpr:addChild(surplusMjCountSpr)
				surplusMjCountSpr:setPosition(cc.p(mjTileSpr:getContentSize().width/2+13, mjTileSpr:getContentSize().height-5))

				self.showHuCardsPanel:addChild(mjTileSpr)
				mjTileSpr:setPosition(width*i/(#self.hulist+1), 36)
			end
		elseif #self.hulist > 17 then
			local lineCount = 0
			if #self.hulist%2 == 0 then
				lineCount = math.floor(#self.hulist/2)
			else
				lineCount = math.ceil(#self.hulist/2)
			end
			local width = 72*lineCount
			local height = 180
			self.showHuCardsPanel:setContentSize(cc.size(width, height))
			self.showHuCardsImage:setContentSize(cc.size(width-36, height+30))
			for i, v in pairs(self.hulist) do
				gt.log("能胡哪张："..v)
				local mColor = math.modf(v/10)
				local mNum = v%10
				local mjTileName = Utils.getMJTileResName(4, mColor, mNum, self.isHZLZ, 1) --获取图片
				local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)  --创建精灵
				mjTileSpr:setScale(0.6)
				local mjInfo = {mjColor = mColor, mjNumber = mNum}
				local surplusMjCount = self:surplusMjCount(mjInfo)

				-- 添加耗子牌标识
				if self.HaoZiCards then
					for i,card in ipairs(self.HaoZiCards) do
						if mColor == card._color and mNum == card._number then
							self:addMouseMark(mjTileSpr)	
						end		
					end
				end
					
				local surplusMjCountSpr = cc.Sprite:createWithSpriteFrameName("sx_img_tingcount"..surplusMjCount..".png")  --创建精灵
				surplusMjCountSpr:setScale(2)
				mjTileSpr:addChild(surplusMjCountSpr)
				surplusMjCountSpr:setPosition(cc.p(mjTileSpr:getContentSize().width/2+13, mjTileSpr:getContentSize().height-5))

				self.showHuCardsPanel:addChild(mjTileSpr)
				if i <= lineCount then
					mjTileSpr:setPosition(width*i/(lineCount+1), 134)
				else
					if #self.hulist%2 == 1 then
						mjTileSpr:setPosition(width*(i%lineCount)/(lineCount+1), 36)
					else
						mjTileSpr:setPosition(width*(i%lineCount+1)/(lineCount+1), 36)
					end
				end
			end
		end
	end
end

--隐藏能胡哪些牌
function MJScene:hideHuCards()
	gt.log("隐藏能胡哪些牌")
	if self.showHuCardsPanel == nil then
		self.showHuCardsPanel = gt.seekNodeByName(self.csbNode,"Panel_hu_list")
		self.showHuCardsImage = gt.seekNodeByName(self.csbNode,"Image_hu_list")
	end
	self.showHuCardsPanel:setVisible(false)
	self.showHuCardsImage:setVisible(false)
end

--处理支对消息
function MJScene:onRcvZhiDui(msgTbl)
	gt.log("收到支对消息")
	-- --dump(msgTbl)

	-- --移除显示的4张牌
	-- if self.zhiDuiBg then
	-- 	self.zhiDuiBg:removeFromParent()
	-- 	self.zhiDuiBg = nil
	-- end
	-- if self.zhiDuiCardList ~= nil 
	-- 	and #self.zhiDuiCardList > 0 then
	-- 	for i=1, #self.zhiDuiCardList do
	-- 		if self.zhiDuiCardList[i] then
	-- 			self.zhiDuiCardList[i]:removeFromParent()
	-- 			self.zhiDuiCardList[i] = nil
	-- 		end
	-- 	end
	-- 	self.zhiDuiCardList = {}
	-- end

	-- --显示支对、过这俩按钮
	-- local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn") --显示所有的按键决策
	-- decisionBtnNode:setVisible(true)

	-- for _, decisionBtn in ipairs(decisionBtnNode:getChildren()) do
	-- 	decisionBtn:setVisible(false)
	-- end

	-- local zhiDuiBtn = gt.seekNodeByName(decisionBtnNode, "Btn_decision_20")
	-- zhiDuiBtn:setVisible(true)
	-- local passBtn = gt.seekNodeByName(decisionBtnNode, "Btn_decision_0")
	-- passBtn:setVisible(true)

	-- --如果点的是支对，显示需要选择的支对牌，点击牌后发送消息
	-- gt.addBtnPressedListener(zhiDuiBtn, function(sender)
	-- 	gt.log("点击支对按钮，显示需要选择的支对牌")
	-- 	local thinkInfo = msgTbl.m_think[1]
	-- 	if thinkInfo[1] == 20 then
	-- 		local zhiCardInfo = thinkInfo[2]
	-- 		local showMjEatTable = {} 			--要显示的吃的牌
	-- 		for _, m in pairs(zhiCardInfo) do
	-- 			table.insert(showMjEatTable, {m[1], m[2]})
	-- 		end

	-- 		self.zhiDuiBg = cc.Scale9Sprite:create("images/otherImages/tipsbg.png")
	-- 		self.zhiDuiBg:setContentSize(cc.size(#showMjEatTable * 2 * 100 + #zhiCardInfo * 25, zhiDuiBtn:getContentSize().height))
	-- 		local menu = cc.Menu:create()
	-- 		local pos = 0
	-- 		local mjWidth = 0
	-- 		-- --dump(showMjEatTable)
	-- 		local mjTileSpr = gt.seekNodeByName(zhiDuiBtn, "Spr_mjTile")
			-- for i, mjNumber in pairs(showMjEatTable) do
			-- 	--dump(mjNumber)
			-- 	pos = pos + 1
			-- 	for j = 1, 2 do
			-- 		local mjTileName = Utils.getMJTileResName(4, mjNumber[1], mjNumber[2], self.isHZLZ) --获取图片
			-- 		local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)  --创建精灵
			-- 		if tonumber(mjNumber[j]) == tonumber(msgTbl.m_number) then
			-- 			mjTileSpr:setColor(cc.c3b(255,255,0))
			-- 		end

	-- 				local menuItem = cc.MenuItemSprite:create(mjTileSpr,mjTileSpr) --创建菜单项
	-- 				menuItem:setTag(i)
	-- 				menuItem:retain()
	-- 				table.insert(self.zhiDuiCardList, menuItem)

	-- 				local function menuCallBack(i, sender)
	-- 					gt.log("支对 111111 点击的牌 ="..i)
	-- 					local chooseId = 1
	-- 					local unChooseId = 2
	-- 					for m, eat in pairs(showMjEatTable) do
	-- 						if m == i then
	-- 							chooseId = m
	-- 						else
	-- 							unChooseId = m
	-- 						end
	-- 					end

	-- 					--移除显示的4张牌
	-- 					if self.zhiDuiBg then
	-- 						self.zhiDuiBg:removeFromParent()
	-- 						self.zhiDuiBg = nil
	-- 					end
	-- 					if self.zhiDuiCardList ~= nil 
	-- 						and #self.zhiDuiCardList > 0 then
	-- 						for i=1, #self.zhiDuiCardList do
	-- 							if self.zhiDuiCardList[i] then
	-- 								self.zhiDuiCardList[i]:removeFromParent()
	-- 								self.zhiDuiCardList[i] = nil
	-- 							end
	-- 						end
	-- 						self.zhiDuiCardList = {}
	-- 					end
	-- 					--隐藏决策按钮
	-- 					decisionBtnNode:setVisible(false)
	-- 					for _, decisionBtn in ipairs(decisionBtnNode:getChildren()) do
	-- 						decisionBtn:setVisible(false)
	-- 					end
	-- 					--发送出牌消息
	-- 					local msgToSend = {}
	-- 					msgToSend.m_msgId = gt.CG_PLAYER_DECISION
	-- 					msgToSend.m_type = 20
	-- 					msgToSend.m_think = {{showMjEatTable[chooseId][1], showMjEatTable[chooseId][2]}}
	-- 					gt.socketClient:sendMessage(msgToSend)

	-- 					self.isPlayerShow = true
	-- 					gt.log("发送支对选择牌，self.isPlayerShow="..tostring(self.isPlayerShow))
	-- 				end
	-- 				menuItem:registerScriptTapHandler(menuCallBack)

	-- 				menuItem:setPosition(cc.p(mjWidth  + (pos - 1) * 10, self.zhiDuiBg:getContentSize().height / 2))
	-- 				menu:addChild(menuItem)

	-- 				mjWidth = mjWidth + mjTileSpr:getContentSize().width
	-- 			end
	-- 		end
	-- 		self.zhiDuiBg:addChild(menu)
	-- 		if pos == 1 then
	-- 			menu:setPosition(self.zhiDuiBg:getContentSize().width * 0.5 - mjWidth * 0.5 + mjTileSpr:getContentSize().width * 0.5 ,0)
	-- 		elseif pos == 2 then
	-- 			menu:setPosition(self.zhiDuiBg:getContentSize().width * 0.5 - mjWidth * 0.5 + mjTileSpr:getContentSize().width * 0.4 ,0)
	-- 		else
	-- 			menu:setPosition(self.zhiDuiBg:getContentSize().width * 0.5 - mjWidth * 0.5 + mjTileSpr:getContentSize().width * 0.3 ,0)
	-- 		end
	-- 		sender:addChild(self.zhiDuiBg , -10, 5)
	-- 		self.zhiDuiBg:setPosition(0,self.zhiDuiBg:getContentSize().height * 1.5)
	-- 	end
	-- end)

	-- gt.addBtnPressedListener(passBtn, function(sender)
	-- 	gt.log("点击过牌按钮，隐藏决策按钮，玩家可以出牌")
	-- 	for _, decisionBtn in ipairs(decisionBtnNode:getChildren()) do
	-- 		decisionBtn:setVisible(false)
	-- 	end
	-- end)
end

   
function MJScene:onRcvLoginServer(msgTbl)
	gt.log("收到登录服务器消息 ============== ")
	--dump(msgTbl)

	-- 去掉转圈
	gt.removeLoadingTips()

	--登录服务器时间
	gt.loginServerTime = msgTbl.kServerTime or os.time()
	--登录本地时间
	gt.loginLocalTime = os.time()

    gt.connecting = false

	-- 设置开始游戏状态
	gt.socketClient:setIsStartGame(true)
	gt.socketClient:setIsCloseHeartBeat(false)
	
	if self.gangAfterChi then
		self.gangAfterChi:destroy()
		self.gangAfterChi = nil
	end

	if self.removetop then
		self:removetop()
	end

	-- if gt.isShowOfflineTips == nil then
	-- 	Toast.showToast(self, "重新连接服务器成功!", 2)
	-- else
	-- 	gt.isShowOfflineTips = nil
	-- end

	if msgTbl.kState == 0  or msgTbl.kState == 4 then
		Toast.showToast(self, "游戏已经结束", 2)
		gt.CreateRoomFlag = false
		gt.dispatchEvent(gt.EventType.BACK_MAIN_SCENE)
	end
end

function MJScene:getPiaoNum(num)
	local msgToSend = {}
	msgToSend.kMId = gt.CG_PIAO_MSG
	msgToSend.kPosition = self.playerSeatIdx-1
	msgToSend.kPiao_count = num-1
	gt.socketClient:sendMessage(msgToSend)
    self.piaoBtns:setVisible(false)
    -- local playBtnsNode = gt.seekNodeByName(self.rootNode, "Node_playBtns")
	if  self.playType == 12 then
		local messBtn = gt.seekNodeByName(self.rootNode, "Btn_message")
	    messBtn:setVisible(true)
	end
end
function MJScene:onRevPiaoNumMes(msgTbl)
	gt.log("收到onRevPiaoNumMes消息 ================= ")
	--dump(msgTbl)

	local roundstate = gt.seekNodeByName(self.rootNode,"Node_roundState")
	roundstate:setVisible(true)
	self.Image_tilesCount:setVisible(true)
    if self.piaoNumTextsTable then
    	local piaoNode=gt.seekNodeByName(self.rootNode,"Node_piao")
    	local piaoBtns=gt.seekNodeByName(self.rootNode,"Node_piao_btns")
    	if not piaoBtns:isVisible() then
           piaoBtns:setVisible(false)
    	end
    else
    	self.piaoNode=gt.seekNodeByName(self.csbNode,"Node_piao")
	    self.piaoNode:setVisible(true)
	    self.piaoBtns=gt.seekNodeByName(self.piaoNode,"Node_piao_btns")
	    self.piaoBtns:setVisible(false)
	    self.piaoNumTexts=gt.seekNodeByName(self.piaoNode,"Node_piao_num")
	    self.piaoNumTextsTable={}
	    for i = 1, 4 do
	    	local piaoNumText=gt.seekNodeByName(self.piaoNumTexts,"Num_piao_"..i)
	    	piaoNumText:setString("")
	    	table.insert(self.piaoNumTextsTable,piaoNumText)
	    end
    end
	    if #MJScene.chenzhouPlayType.piao~=0 then
	    	MJScene.chenzhouPlayType.piao={}
	    end
        
    	for i,piao_num in ipairs(msgTbl.kPiao) do
    	if piao_num ~=0 then
    	   self.piaoNumTextsTable[self.roomPlayers[i].displaySeatIdx]:setString("飘" ..piao_num .."分")
        else
           self.piaoNumTextsTable[self.roomPlayers[i].displaySeatIdx]:setString("不飘")
        end
           table.insert(MJScene.chenzhouPlayType.piao,piao_num)
        end
end

--服务器返回gate登录
function MJScene:onRcvLoginGate( msgTbl )
	--dump( msgTbl )

	gt.socketClient:setPlayerKeyAndOrder(msgTbl.kStrKey, msgTbl.kUMsgOrder)

	local msgToSend = {}
	msgToSend.kMId = gt.CG_LOGIN_SERVER
	msgToSend.kSeed = gt.loginSeed
	msgToSend.kId = gt.m_id
	local catStr = tostring(gt.loginSeed)
	msgToSend.kMd5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	gt.socketClient:sendMessage(msgToSend)
end

function MJScene:onRcvPiao(msgTbl)
	gt.log("收到飘消息 ================= ")
	--dump(msgTbl)

    --飘
    self.piaoNode=gt.seekNodeByName(self.csbNode,"Node_piao")
    self.piaoNode:setVisible(true)
    self.piaoBtns=gt.seekNodeByName(self.piaoNode,"Node_piao_btns")
    self.piaoBtns:setVisible(true)
    self.piaoNumTexts=gt.seekNodeByName(self.piaoNode,"Node_piao_num")
    self.piaoNumTextsTable={}
    	for i = 1, 4 do
			local piaoBtn = gt.seekNodeByName(self.piaoBtns, "Btn_piao" .. i)
			gt.addBtnPressedListener(piaoBtn,function ()
		        self:getPiaoNum(i)
	    	end)
	    	local piaoNumText=gt.seekNodeByName(self.piaoNumTexts,"Num_piao_"..i)
	    	piaoNumText:setString("")
	    	table.insert(self.piaoNumTextsTable,piaoNumText)
	    end
	--如果是飘而且人数4人则显示飘的按钮
	if self.piaoFlag and #self.roomPlayers==4 then
	   self.piaoNode:setVisible(true)
       local roundstate = gt.seekNodeByName(self.rootNode,"Node_roundState")
       roundstate:setVisible(false)
	   self.Image_tilesCount:setVisible(false)
	end
end
function MJScene:playYuYinAnimation()
	local action = nil
	local yuyinNode, action = gt.createCSAnimation("huatong.csb")
	action:play("huatong", true)
	yuyinNode:setPosition(cc.p(display.cx, display.cy))
	self:addChild(yuyinNode, 1000)
	self.m_yuyinNode = yuyinNode
end

function MJScene:stopYuYinAnimation()
	if self.m_yuyinNode then
		self:removeChild(self.m_yuyinNode)
	end
end

function MJScene:getLuaBridge()
	if self.luaBridge then
		return
	end

	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end
end

function MJScene:setDynamicStartBtn(msgTbl)
	gt.log(debug.traceback())
	gt.log("--------------self.playerSeatIdx", self.playerSeatIdx)
	if self.playerSeatIdx and self.playerSeatIdx > 0 and self.playerSeatIdx < 5 then
		--动态开局
		gt.log("-------------------table.nums(self.roomPlayers)", table.nums(self.roomPlayers))
			--显示开始游戏按钮
		if msgTbl.kStartGameButtonPos then
			if self.playerSeatIdx == msgTbl.kStartGameButtonPos + 1 then
				if msgTbl.kStartGameButtonPos < 4 then
					--2～4人随时开局，请开始游戏
					self:setDynamicStartTips(3)
					self.dynamicStartBtn:setVisible(true)
					local inviteFriendBtn = gt.seekNodeByName(self.rootNode, "Btn_inviteFriend")
					inviteFriendBtn:setPositionX(490)

					local readyPlayNode = gt.seekNodeByName(self.rootNode, "Node_readyPlay")
					if readyPlayNode:isVisible() then
						self.dynamicStartBtn:setPositionX(790)
					else
						self.dynamicStartBtn:setPositionX(640)
					end
				end
			else
				if msgTbl.kStartGameButtonPos < 4 then
					--等待房主开始游戏
					self:setDynamicStartTips(2)
					self.dynamicStartBtn:setVisible(false)
					self.dynamicStartBtn:setPositionX(640)
					local inviteFriendBtn = gt.seekNodeByName(self.rootNode, "Btn_inviteFriend")
					inviteFriendBtn:setPositionX(640)
				else
					--等待玩家进入
					self:setDynamicStartTips(1)
					self.dynamicStartBtn:setVisible(false)
					self.dynamicStartBtn:setPositionX(640)
					local inviteFriendBtn = gt.seekNodeByName(self.rootNode, "Btn_inviteFriend")
					inviteFriendBtn:setPositionX(640)
				end
			end
		end
	end
end

function MJScene:dynamicStartTipsShow(isShow)
	local PointsCount = 2
 	local setPoints = function()
 		PointsCount = PointsCount + 1

 		if PointsCount > 7 then
 			PointsCount = 1
 		end

 		if PointsCount == 1 then
 			--self.loginConnect:setString("")
			for i = 1, 6 do
				self.Label_dot[i]:setVisible(false)
			end
 		elseif PointsCount == 2 then
 			--self.loginConnect:setString(".")
			self.Label_dot[1]:setVisible(true)
			for i = 2, 6 do
				self.Label_dot[i]:setVisible(false)
			end
 		elseif PointsCount == 3 then
 			--self.loginConnect:setString("..")
			for i = 1, 2 do
				self.Label_dot[i]:setVisible(true)
			end
			for i = 3, 6 do
				self.Label_dot[i]:setVisible(false)
			end
 		elseif PointsCount == 4 then
 			--self.loginConnect:setString("...")
			for i = 1, 3 do
				self.Label_dot[i]:setVisible(true)
			end
			for i = 4, 6 do
				self.Label_dot[i]:setVisible(false)
			end
 		elseif PointsCount == 5 then
 			--self.loginConnect:setString("....")
			for i = 1, 4 do
				self.Label_dot[i]:setVisible(true)
			end
			for i = 5, 6 do
				self.Label_dot[i]:setVisible(false)
			end
 		elseif PointsCount == 6 then
 			--self.loginConnect:setString(".....")
			for i = 1, 5 do
				self.Label_dot[i]:setVisible(true)
			end
			for i = 6, 6 do
				self.Label_dot[i]:setVisible(false)
			end
 		elseif PointsCount == 7 then
 			--self.loginConnect:setString("......")
			for i =1, 6 do
				self.Label_dot[i]:setVisible(true)
			end
 		end
	end

	if isShow then
		if self.dynamicStartDotSchedulerEntry == nil then
			self.Label_dot[1]:setVisible(true)
			for i = 2, 6 do
				self.Label_dot[i]:setVisible(false)
			end
			self.Node_dot:setVisible(true)
			self.dynamicStartDotSchedulerEntry = gt.scheduler:scheduleScriptFunc(setPoints, 0.5, false)
		end
	else
		self.Node_dot:setVisible(false)
 		if self.dynamicStartDotSchedulerEntry then
 			gt.scheduler:unscheduleScriptEntry(self.dynamicStartDotSchedulerEntry)
 			self.dynamicStartDotSchedulerEntry = nil
 		end
	end
end

function MJScene:setDynamicStartTips(index)
	gt.log(debug.traceback())
	gt.log("----------------setDynamicStartTips", index)
	for i = 1 ,4 do
		self.Label_tips[i]:setVisible(i == index)
	end
	if index == 3 then
		self.Node_dot:setPositionX(850)
	elseif index == 4 then
		local Image_logo = gt.seekNodeByName(self.rootNode, "Image_logo")
		Image_logo:setVisible(false)
		if cc.UserDefault:getInstance():getIntegerForKey("tipsTime", 0) == 0 then
			gt.log("----------------tipsTime")
			cc.UserDefault:getInstance():setIntegerForKey("tipsTime", os.time())
		end

		self.tipsTime = 15 - (os.time() - cc.UserDefault:getInstance():getIntegerForKey("tipsTime", os.time()))
		gt.log("----------------self.tipsTime", self.tipsTime)
		if self.tipsTime > 0 then
	    	self.tipsTimeSchedulerEntry = gt.scheduler:scheduleScriptFunc(function (  )
				self.tipsTime = self.tipsTime - 1
				local tipsTimeLabel = gt.seekNodeByName(self.rootNode, "Label_tipsTime")

				self.tipsTime = 15 - (os.time() - cc.UserDefault:getInstance():getIntegerForKey("tipsTime", 0))

				tipsTimeLabel:setString((self.tipsTime >= 0 and self.tipsTime or 0).."秒")

				if self.tipsTime <= 0 then
					if self.tipsTimeSchedulerEntry then
						gt.scheduler:unscheduleScriptEntry(self.tipsTimeSchedulerEntry)
						self.tipsTimeSchedulerEntry = nil
						cc.UserDefault:getInstance():setIntegerForKey("tipsTime", 0)
					end
				end
	    	end, 1, false)
	    end

		local tipsTimeLabel = gt.seekNodeByName(self.rootNode, "Label_tipsTime")
		tipsTimeLabel:setString((self.tipsTime >= 0 and self.tipsTime or 0).."秒")
		tipsTimeLabel:setVisible(true)

		self.Node_dot:setPositionX(760)
	else
		self.Node_dot:setPositionX(800)
	end
	self:dynamicStartTipsShow(true)
end

function MJScene:onRcvSelectSeat(msgTbl)
	gt.log("---------------------------------------onRcvSelectSeat", msgTbl.kMId)
	gt.dump(msgTbl)

    -- self.test:runAction(cc.Sequence:create(cc.FadeTo:create(1, 255),cc.FadeTo:create(1, 255), cc.FadeTo:create(2, 0)))

	-- self.chutaiAnimate:play("run", false)

	if msgTbl and type(msgTbl) == "table" and msgTbl.kPos < 4 then
		gt.log("---------------------------------------msgTbl.kId", msgTbl.kId)
		gt.log("---------------------------------------msgTbl.kPos", msgTbl.kPos)
		gt.dump(self.unSeatRoomPlayers)
		if msgTbl.kId and msgTbl.kPos then
			self.roomPlayers[msgTbl.kPos + 1] = self.unSeatRoomPlayers[msgTbl.kId]
			msgTbl.kUserId = msgTbl.kId
			self:roomRemoveUnSeatPlayers(msgTbl)
			self.roomPlayers[msgTbl.kPos + 1].readyState = 1

			--自己坐下方向转动
			if msgTbl.kId == gt.playerData.uid then
				if self.Label_tips[4] then
					self.Label_tips[4]:setVisible(false)
					self:dynamicStartTipsShow(false)

					local tipsTimeLabel = gt.seekNodeByName(self.rootNode, "Label_tipsTime")
					tipsTimeLabel:setVisible(false)

					local Image_logo = gt.seekNodeByName(self.rootNode, "Image_logo")
					Image_logo:setVisible(true)
				end
				self.playerSeatIdx = msgTbl.kPos + 1
				gt.playerSeatIdx = self.playerSeatIdx
				self.roomPlayers[msgTbl.kPos + 1].seatIdx = self.playerSeatIdx
				
				-- 逻辑座位和显示座位偏移量(从0编号开始)
				local seatOffset = (self.playerFixDispSeat) - msgTbl.kPos
				self.seatOffset = seatOffset
					gt.log("---------------------------------------self.roomPlayers[msgTbl.kPos + 1].displaySeatIdx", self.roomPlayers[msgTbl.kPos + 1].displaySeatIdx)
				self:updatePlayer(gt.playerData.uid)
				-- 房间添加自己玩家
				self:roomAddPlayer(self.roomPlayers[msgTbl.kPos + 1])
				self:positionRotation(msgTbl)
				for i = 1, #self.PositionBtn do
					gt.log("---------------------------------------#self.PositionBtn", #self.PositionBtn)
					if self.PositionBtn[i] then
						self.PositionBtn[i]:setVisible(false)
					end
				end
				local readySignSpr = gt.seekNodeByName(self.rootNode, "Spr_readySign_" .. self.roomPlayers[msgTbl.kPos + 1].displaySeatIdx)
				readySignSpr:setVisible(true)

				if table.nums(self.roomPlayers) >= 4 then
					self.delayTime = 2
				else
					self.delayTime = 0
				end
				
				if self.playerSeatIdx ~= 1 then
					local backBtn = gt.seekNodeByName(self.rootNode, "Btn_back")
					--backBtn:setEnabled(false)
				end

	            self:playSelectSeatAni(self.playerSeatIdx)
				local messBtn = gt.seekNodeByName(self.rootNode, "Btn_message")
			    messBtn:setVisible(true)

				if gt.isAppStoreInReview == false then
			   		self.yuyinBtn:setVisible(true)
				end
			else
				self.roomPlayers[msgTbl.kPos + 1].seatIdx = msgTbl.kPos + 1

				local roomPlayer = self.roomPlayers[msgTbl.kPos + 1]

				-- 显示座位编号(二人转转 4 1 ／ 三人转转4 1 3)
				-- if self.playersType == 2 then
				-- 	if roomPlayer.seatIdx == 1 then
				-- 		roomPlayer.displaySeatIdx = 4 - self.seatOffset <= 0 and 4 or 3
				-- 	elseif roomPlayer.seatIdx == 2 then
				-- 		roomPlayer.displaySeatIdx = 4 - self.seatOffset == 1 and 4 or 1
				-- 	end
				-- elseif self.playersType == 3 then
				-- 	if roomPlayer.seatIdx == 1 then
				-- 		roomPlayer.displaySeatIdx = 4 - self.seatOffset <= 0 and 4 or 3
				-- 	elseif roomPlayer.seatIdx == 2 then
				-- 		roomPlayer.displaySeatIdx = 4 - self.seatOffset == 1 and 4 or 1
				-- 	elseif roomPlayer.seatIdx == 3 then
				-- 		roomPlayer.displaySeatIdx = 4 - self.seatOffset == 1 and 4 or 1
				-- 	end
				-- else
					roomPlayer.displaySeatIdx = (msgTbl.kPos + self.seatOffset) % 4 == 0 and 4 or (msgTbl.kPos + self.seatOffset) % 4
				-- end

				gt.log("---------------------------房间添加玩家1", msgTbl.kPos)
				gt.log("---------------------------房间添加玩家2", self.seatOffset)
				gt.log("---------------------------房间添加玩家3", roomPlayer.displaySeatIdx)
				gt.log("---------------------------msgTbl.kId", msgTbl.kId)
				gt.log("---------------------------gt.playerData.uid", gt.playerData.uid)
				self.PositionBtn[roomPlayer.displaySeatIdx]:setVisible(false)

				-- 房间添加其他玩家
				self:roomAddPlayer(roomPlayer)
			end

			if self.m_Greater2CanStart == 1 then
				self:setDynamicStartBtn(msgTbl)
			end
		end
	else
		Toast.showToast(self, "座位已有人，请重新选座", 2)
	end
end

function MJScene:unregisterAllMsgListener()
	gt.removeTargetEventListenerByType(self,"MJSceneAddText")
	gt.removeTargetEventListenerByType(self,"ENDGAME")
	gt.socketClient:unregisterMsgListener(gt.GC_ROOM_CARD)
	gt.socketClient:unregisterMsgListener(gt.GC_ENTER_ROOM)
	gt.socketClient:unregisterMsgListener(gt.GC_ADD_PLAYER)
	gt.socketClient:unregisterMsgListener(gt.GC_REMOVE_PLAYER)
	gt.socketClient:unregisterMsgListener(gt.GC_SYNC_ROOM_STATE)
	gt.socketClient:unregisterMsgListener(gt.GC_READY)
	gt.socketClient:unregisterMsgListener(gt.GC_OFF_LINE_STATE)
	gt.socketClient:unregisterMsgListener(gt.GC_ROUND_STATE)
	gt.socketClient:unregisterMsgListener(gt.GC_START_GAME)
	gt.socketClient:unregisterMsgListener(gt.GC_TURN_SHOW_MJTILE)
	gt.socketClient:unregisterMsgListener(gt.GC_SYNC_SHOW_MJTILE)
	gt.socketClient:unregisterMsgListener(gt.GC_MAKE_DECISION)
	gt.socketClient:unregisterMsgListener(gt.GC_GANG_AFTER_CHI_PENG)
	gt.socketClient:unregisterMsgListener(gt.GC_SYNC_MAKE_DECISION)
	gt.socketClient:unregisterMsgListener(gt.GC_CHAT_MSG)
	gt.socketClient:unregisterMsgListener(gt.GC_ROUND_REPORT)
	gt.socketClient:unregisterMsgListener(gt.GC_FINAL_REPORT)
	gt.socketClient:unregisterMsgListener(gt.GC_START_DECISION)
	gt.socketClient:unregisterMsgListener(gt.GC_SYNC_START_PLAYER_DECISION)
	gt.socketClient:unregisterMsgListener(gt.GC_SYNC_BAR_TWOCARD)

	gt.socketClient:unregisterMsgListener(gt.CG_SYNC_HAIDI)
	gt.socketClient:unregisterMsgListener(gt.CG_TURN_HAIDI)

	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN)
    
	gt.socketClient:unregisterMsgListener(gt.GC_MARQUEE)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_SERVER)
    gt.socketClient:unregisterMsgListener(gt.GC_PIAO_MSG)
    gt.socketClient:unregisterMsgListener(gt.GC_PIAO_NUM_MSG)
    
	gt.socketClient:unregisterMsgListener(gt.CG_LONGITUDE_LATITUDE)

	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_GATE)

	gt.socketClient:unregisterMsgListener(gt.GC_SELECT_SEAT)
	gt.socketClient:unregisterMsgListener(gt.GC_TOAST)

	gt.socketClient:unregisterMsgListener(gt.RECEIVE_VIDEO_INVITATION)
	gt.socketClient:unregisterMsgListener(gt.INBUSY_VIDEO_INVITATION)
	gt.socketClient:unregisterMsgListener(gt.ONLINE_VIDEO_INVITATION)
	gt.socketClient:unregisterMsgListener(gt.SHUTDOWN_VIDEO_INVITATION)
	gt.socketClient:unregisterMsgListener(gt.UPDATE_USER_VIP_INFO)

	-- 注销监听
	if self.schedulerEntry then
		gt.scheduler:unscheduleScriptEntry(self.schedulerEntry)
		self.schedulerEntry = nil
	end

	if self.updateToastSchedule then
		gt.scheduler:unscheduleScriptEntry(self.updateToastSchedule)
		self.updateToastSchedule = nil
	end	
end

-- 断线重连,走一次登录流程
function MJScene:reLogin()
	local accessToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Access_Token" )
	local refreshToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token" )
	local openid 		= cc.UserDefault:getInstance():getStringForKey( "WX_OpenId" )

	local unionid 		= cc.UserDefault:getInstance():getStringForKey( "WX_Uuid" )
	local sex 			= cc.UserDefault:getInstance():getStringForKey( "WX_Sex" )
	local nickname 		= gt.wxNickName--cc.UserDefault:getInstance():getStringForKey( "WX_Nickname" )
	local headimgurl 	= cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl" )

	local msgToSend = {}
	msgToSend.kMId = gt.CG_LOGIN
	msgToSend.kPlate = "wechat"
	msgToSend.kAccessToken = accessToken
	msgToSend.kRefreshToken = refreshToken
	msgToSend.kOpenId = openid
	msgToSend.kSeverID = gt.serverId
	msgToSend.kUuid = unionid
	msgToSend.kSex = tonumber(sex)
	msgToSend.kNikename = nickname
	msgToSend.kImageUrl = headimgurl

	local catStr = string.format("%s%s%s%s", openid, accessToken, refreshToken, unionid)
	msgToSend.kMd5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	gt.socketClient:sendMessage(msgToSend)
end

function MJScene:onRcvLogin(msgTbl)
	gt.log("首条登录消息应答 =============== ")
	--dump(msgTbl)

	gt.socketClient:savePlayCount(msgTbl.kTotalPlayNum)

	if msgTbl.kErrorCode == 5 then
		-- 去掉转圈
		gt.removeLoadingTips()
		require("client/game/dialog/NoticeTips"):create("提示",	"您在"..msgTbl.kErrorMsg.."中登录或已创建房间，需要退出或解散房间后再此登录。", nil, nil, true)
		return
	end

	-- 如果有进入此函数则说明token,refreshtoken,openid是有效的,可以记录.
	-- if self.needLoginWXState == 0 then
	-- 	-- 重新登录,因此需要全部保存一次
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token", self.m_accessToken )
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Refresh_Token", self.m_refreshToken )
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_OpenId", self.m_openid )

	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token_Time", os.time() )
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Refresh_Token_Time", os.time() )
	-- elseif self.needLoginWXState == 1 then
	-- 	-- 无需更改
	-- 	-- ...
	-- elseif self.needLoginWXState == 2 then
	-- 	-- 需更改accesstoken
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token", self.m_accessToken )
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token_Time", os.time() )
	-- end


	gt.loginSeed = msgTbl.kSeed

	-- gt.GateServer.ip = msgTbl.m_gateIp
	-- gt.GateServer.ip = tostring(msgTbl.m_gateIp)
	-- 源代码
	-- gt.GateServer.ip = gt.curServerIp
	-- gt.GateServer.port = tostring(msgTbl.m_gatePort)
	-- 更改代码，测试服务端切换高防非高防ip
	gt.GateServer.ip = msgTbl.kGateIp
	gt.GateServer.port = tostring(msgTbl.kGatePort)

	gt.m_id = msgTbl.kId

	if msgTbl.kTotalPlayNum ~= nil then
		self:savePlayCount(msgTbl.kTotalPlayNum)
	else
		gt.log("onRcvLogin playCount = nil")
	end

	gt.log("gt.GateServer ip = " .. gt.GateServer.ip .. ", port = " .. gt.GateServer.port)
	gt.socketClient:close()
	gt.log("关闭socket 222222")
	gt.log("MJScene, GateServer, 建立socket连接, serverIp = "..gt.GateServer.ip..", serverPort = "..gt.GateServer.port..", isBlock = true")
	gt.socketClient:connect(gt.GateServer.ip, gt.GateServer.port, true)
	local msgToSend = {}
	msgToSend.kMId = gt.CG_LOGIN_GATE
	msgToSend.kStrUserUUID = gt.socketClient:getPlayerUUID()
	gt.socketClient:sendMessage(msgToSend)
end

function MJScene:savePlayCount(count)
	local name = gt.name_s .. count .. gt.name_e
	cc.UserDefault:getInstance():setStringForKey("yoyo_name", name)
end

function MJScene:onNodeEvent(eventName)
	if "enter" == eventName then
		-- 计算更新当前时间倒计时
		local curTimeStr = os.date("%X", os.time())
		local timeSections = string.split(curTimeStr, ":")
		local secondTime = tonumber(timeSections[3])
		self.updateTimeCD = 60 - secondTime
		self:updateCurrentTime()

		self:updateBattery()

		-- 触摸事件
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		listener:registerScriptHandler(handler(self, self.onTouchCancel), cc.Handler.EVENT_TOUCH_CANCELLED)
		local eventDispatcher = self.playMjLayer:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.playMjLayer)

		-- 逻辑更新定时器
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 30, false)

		gt.soundEngine:playMusic("bgm2", true)

		local function onEvent1(event)
	    end
	    self._listener = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT", onEvent1)
	    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	    eventDispatcher:addEventListenerWithFixedPriority(self._listener, 1)
	 	local function onEvent2(event)
 			gt.resume_time = 1
 			--如果鼠标正在拖动，将牌放回原来的位置 不出牌
			if self.isTouchBegan then
				if self.chooseMjTile and self.chooseMjTile.mjTileSpr and self.playMjLayer then
					self.chooseMjTile.mjTileSpr:setPosition(self.mjTileOriginPos)
					self.playMjLayer:reorderChild(self.chooseMjTile.mjTileSpr, self.mjTileOriginPos.y)
				end

				self.isTouchBegan = false
				self.isTouchMoved = false
			end
	    end
	    self.foregroundEvent = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT", onEvent2)
	    eventDispatcher:addEventListenerWithFixedPriority(self.foregroundEvent, 1)
	
	    self.ChatLog = {}

	    -- if CC_SHOW_FPS then
	    --     cc.Director:getInstance():setDisplayStats(true)
	    -- end
	elseif "exit" == eventName then
		gt.removeTargetEventListenerByType(self, gt.EventType.BACK_MAIN_SCENE)
		gt.removeTargetEventListenerByType(self, gt.EventType.RELOGIN_WHEN_ERROR)
		local eventDispatcher = self.playMjLayer:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self.playMjLayer)

		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		if self.updateToastSchedule then
			gt.scheduler:unscheduleScriptEntry(self.updateToastSchedule)
			self.updateToastSchedule = nil
		end	

		-- 屏蔽掉音效的update
		if self.voiceUrlScheduleHandler then
			gt.scheduler:unscheduleScriptEntry(self.voiceUrlScheduleHandler)
			self.voiceUrlScheduleHandler = nil
		end

		gt.soundEngine:playMusic("bgm1", true)

		if self.scheduleSendVideoHandler then
			gt.scheduler:unscheduleScriptEntry(self.scheduleSendVideoHandler)
			self.scheduleSendVideoHandler = nil
		end
				
		if self.schedulerEntry then
 			gt.scheduler:unscheduleScriptEntry(self.schedulerEntry)
 			self.schedulerEntry = nil
 		end

		if self.scheduleCloseVideoHandler then
			gt.scheduler:unscheduleScriptEntry(self.scheduleCloseVideoHandler)
			self.scheduleCloseVideoHandler = nil
		end
		
		if self.playScheduler then
 			gt.scheduler:unscheduleScriptEntry(self.playScheduler)
 			self.playScheduler = nil
 		end

 		if self.setRoomInfoScheduler then
 			gt.scheduler:unscheduleScriptEntry(self.setRoomInfoScheduler)
 			self.setRoomInfoScheduler = nil
 		end

		if self.chutaiSchedulerEntry then
 			gt.scheduler:unscheduleScriptEntry(self.chutaiSchedulerEntry)
			self.chutaiSchedulerEntry = nil
 		end
		
		if self.positionTurnSchedulerEntry then
 			gt.scheduler:unscheduleScriptEntry(self.positionTurnSchedulerEntry)
 			self.positionTurnSchedulerEntry = nil
 		end

		if self.timerWriteLogScheduler then
			gt.scheduler:unscheduleScriptEntry(self.timerWriteLogScheduler)
			self.timerWriteLogScheduler = nil
		end

		if self.scheduleSendMjTileHandler then
			gt.scheduler:unscheduleScriptEntry(self.scheduleSendMjTileHandler)
			self.scheduleSendMjTileHandler = nil
		end

		if self.dynamicStartDotSchedulerEntry then
			gt.scheduler:unscheduleScriptEntry(self.dynamicStartDotSchedulerEntry)
			self.dynamicStartDotSchedulerEntry = nil
		end

		if self.dynamicTopTipsSchedulerEntry then
			gt.scheduler:unscheduleScriptEntry(self.dynamicTopTipsSchedulerEntry)
			self.dynamicTopTipsSchedulerEntry = nil
		end
	
		if self.tipsTimeSchedulerEntry then
			gt.scheduler:unscheduleScriptEntry(self.tipsTimeSchedulerEntry)
			self.tipsTimeSchedulerEntry = nil
		end
	
		if self.readyPlay then
			if self.readyPlay.scheduleHandler1 then
				gt.scheduler:unscheduleScriptEntry(self.readyPlay.scheduleHandler1)
				self.readyPlay.scheduleHandler1 = nil
			end
			if self.readyPlay.scheduleHandler2 then
				gt.scheduler:unscheduleScriptEntry(self.readyPlay.scheduleHandler2)
				self.readyPlay.scheduleHandler2 = nil
			end
		end

		if self.caidai then self.caidai:stopAllActions() end

        --关闭视频
		self:onRcvShutdownVideoInvitation()

        --关闭gps
		self:getLuaBridge()
		if gt.isIOSPlatform() then
			local ok, ret = self.luaBridge.callStaticMethod("AppController", "closeMap")
		elseif gt.isAndroidPlatform() then
			local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "closeMap",nil,"()V")
		end

		for i = 1, 4 do
			if self._time[i] then
	            gt.scheduler:unscheduleScriptEntry(self._time[i])
	            self._time[i] = nil
	        end
	    end

	    -- if CC_SHOW_FPS then
	    --     cc.Director:getInstance():setDisplayStats(false)
	    -- end
	end
end

-- start --
--------------------------------
-- @class function
-- @description 接收游戏桌面跑马灯消息
-- @param msgTbl 消息体
-- end --
function MJScene:onRcvPlaySeceneCSMarquee(msgTbl)
	gt.log("收到跑马灯消息 =============== ")
	--dump(msgTbl)

	if gt.isIOSPlatform() and gt.isInReview then
		local str_des = gt.getLocationString("LTKey_0048")
		self.marqueeMsg:showMsg(str_des, 3)
	else
		self.marqueeMsg:showMsg(msgTbl.kStr, 3)
	end
end

function MJScene:onTouchBegan(touch, event)
    if gt.connecting then
        return false
    end

	if self.touchFlag then
		return false
	end

	self.touchFlag = true

	if self.RoundStart == false then
		self.touchFlag = false
		return false
	end

	if self.showTingHuCardsFlag then
		self.showTingHuCardsFlag = false
		self.showHuCardsPanel:removeAllChildren()
		self.showHuCardsPanel:setVisible(false)
		self.showHuCardsImage:setVisible(false)
		self.touchFlag = false
		return false
	end

	gt.log("MJScene:onTouchBegan ======== isPlayerShow = "..tostring(self.isPlayerShow)..", isPlayerDecision="..tostring(self.isPlayerDecision))
	-- if self.isTouchBegan then
	-- 	gt.log("MJScene:onTouchBegan 111111 ")
	-- 	return false
	-- end
	-- if not self.isPlayerShow or self.isPlayerDecision then
	-- 	gt.log("MJScene:onTouchBegan 222222 isPlayerShow = "..tostring(self.isPlayerShow)..", isPlayerDecision="..tostring(self.isPlayerDecision))
	-- 	return false
	-- end
	if self.isTing and not self.isPlayerShow then
		gt.log("MJScene:onTouchBegan 333333 ")
		return
	end
	self.touchMjTile, self.mjTileIdx = self:touchPlayerMjTiles(touch)
	if not self.touchMjTile or (self.isTing and (self.mjTileIdx ~= #self.roomPlayers[self.playerSeatIdx].holdMjTiles)) then
		gt.log("MJScene:onTouchBegan 444444 self.touchMjTile = "..tostring(self.touchMjTile))
		self.touchFlag = false
		return false
	end
	-- 听操作除听得牌其它牌不可点
	local roomPlayer = self.roomPlayers[self.playerSeatIdx]
	self.tingFlag = false
	if roomPlayer.m_ting and #roomPlayer.m_ting > 0 then
		gt.log("听操作除听得牌其它牌不可点")
		local hasCard = false
		for _, tingCard in ipairs(roomPlayer.m_ting) do
			gt.log("---------------tingCard[1]", tingCard[1])
			gt.log("---------------tingCard[2]", tingCard[2])
			if tingCard[1] == self.touchMjTile.mjColor and tingCard[2] == self.touchMjTile.mjNumber then
				hasCard = true
				break
			end
		end
		if not hasCard or not self.isPlayerShow or self.isPlayerDecision then
			gt.log("MJScene:onTouchBegan 555555 ")
			self.touchFlag = false
			return false
		end

		self.tingFlag = true
	end

	gt.log("当前牌 " .. self.playType .. " " .. tostring(self.curTypeIsGang))
	if self.playType == gt.RoomType.ROOM_ZHUANZHUAN then
		local roomPlayer = self.roomPlayers[self.playerSeatIdx]
		if not roomPlayer then
			gt.log("MJScene:onTouchBegan 666666 ")
			self.touchFlag = false
			return false
		end

		if self.curTypeIsGang == true then
			gt.log("MJScene:onTouchBegan 777777 ")
			self.touchFlag = false
			return false
		end
	end

	-- 记录原始位置
	-- self.playMjLayer:reorderChild(self.touchMjTile.mjTileSpr, gt.winSize.height)

  	local mjTilePos = cc.p(self.touchMjTile.mjTileSpr:getPosition())
	if roomPlayer.displaySeatIdx == 1 then
		self.playMjLayer:reorderChild(self.touchMjTile.mjTileSpr, (gt.winSize.height - mjTilePos.x - mjTilePos.y))
	else
		self.playMjLayer:reorderChild(self.touchMjTile.mjTileSpr, (gt.winSize.height + mjTilePos.x - mjTilePos.y))
	end
	self.chooseMjTile = self.touchMjTile
	self.chooseMjTileIdx = self.mjTileIdx
	self.mjTileOriginPos = cc.p(self.touchMjTile.mjTileSpr:getPosition())
	self.touchMjTile.mjTileSpr.pos = cc.p(self.touchMjTile.mjTileSpr:getPosition())
	self.preTouchPoint = self.playMjLayer:convertTouchToNodeSpace(touch)
	self.isTouchMoved = false
	-- self.isTouchBegan = true

	return true
end

function MJScene:onTouchMoved(touch, event)
	gt.log("MJScene:onTouchMoved ======== ")
	local touchPoint = self.playMjLayer:convertTouchToNodeSpace(touch)

	if not self.isTouchBegan and (self.isPlayerShow == true and self.isPlayerDecision == false) then
		if self.chooseMjTile ~= nil 
			and self.chooseMjTile.mjTileSpr ~= nil
			and self.chooseMjTile.mjTileSpr.setPosition ~= nil 
			and touchPoint ~= nil then
			self.chooseMjTile.mjTileSpr:setPosition(touchPoint)
			gt.log("---------self.chooseMjTile.mjTileSpr")
			self.isTouchMoved = true
		end
	end
end

function MJScene:onTouchCancel(touch, event)
	gt.log("MJScene:onTouchCancel ======== ")
	self:onTouchEnded(touch, event)
end

function MJScene:onTouchEnded(touch, event)
	gt.log("MJScene:onTouchEnded ======== ")
	self.touchFlag = false
	local isShowMjTile = false

	-- if self.isTouchMoved and not isShowMjTile then
	if self.isTouchMoved then
		gt.log("self.isTouchMoved and not isShowMjTile")
		gt.dump(self.chooseMjTile.mjTileSpr.pos)
		-- 放回原来的位置,不出牌
		-- self.chooseMjTile.mjTileSpr:setPosition(self.mjTileOriginPos)
		self.chooseMjTile.mjTileSpr:setPosition(self.chooseMjTile.mjTileSpr.pos)
		self.playMjLayer:reorderChild(self.chooseMjTile.mjTileSpr, (gt.winSize.height - self.mjTileOriginPos.y))
	end

	-- 拖拽出牌
	local touchPoint = self.playMjLayer:convertTouchToNodeSpace(touch)
	if cc.pDistanceSQ(self.preTouchPoint, touchPoint) > 1000 then
		if not self.isTouchBegan and (self.isPlayerShow == true and self.isPlayerDecision == false) then
			-- 拖拽距离大于20判断为拖动
			local roomPlayer = self.roomPlayers[self.playerSeatIdx]
			local limitPosY = roomPlayer.mjTilesReferPos.outStart.y - 220
			if touchPoint.y > limitPosY then
				-- 拖动位置大于上限认为出牌
				isShowMjTile = true
			end
		end
	else
		-- 点击麻将牌
		-- 点中弹出
		if self.chooseMjTile ~= self.preClickMjTile then
			local mjTilePos = cc.p(self.chooseMjTile.mjTileSpr:getPosition())
			-- local moveAction = cc.MoveTo:create(0.05, cc.p(mjTilePos.x, mjTilePos.y + 26))
			-- self.chooseMjTile.mjTileSpr:runAction(moveAction)
			self.chooseMjTile.mjTileSpr:setPosition(cc.p(mjTilePos.x, mjTilePos.y + 26))

			self:updateOutCardColor(self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber, true)
			-- 上一次点中的复位
			if self.preClickMjTile then
				mjTilePos = cc.p(self.preClickMjTile.mjTileSpr:getPosition())
				-- local moveAction = cc.MoveTo:create(0.05, cc.p(mjTilePos.x, mjTilePos.y - 26 < 65 and 65 or mjTilePos.y - 26))
				-- self.preClickMjTile.mjTileSpr:runAction(moveAction)
				self.preClickMjTile.mjTileSpr:setPosition(cc.p(mjTilePos.x, mjTilePos.y - 26 < 65 and 65 or mjTilePos.y - 26))
			end
		else
			local mjTilePos = cc.p(self.chooseMjTile.mjTileSpr:getPosition())
			if mjTilePos.y == 65 then
				self.chooseMjTile.mjTileSpr:setPosition(cc.p(mjTilePos.x, mjTilePos.y + 26))
			else
				self.chooseMjTile.mjTileSpr:setPosition(cc.p(mjTilePos.x, mjTilePos.y - 26 < 65 and 65 or mjTilePos.y - 26))
			end

			self:updateOutCardColor(self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber, true)
		end

		if gt.playTypeClick and gt.playTypeClick == 2 then
		    -- 判断双击
			if self.preClickMjTile and self.preClickMjTile == self.chooseMjTile then
				isShowMjTile = true
			end
		else
			isShowMjTile = true
		end

		self.preClickMjTile = self.chooseMjTile
	end

	if self.isTouchBegan then
		gt.log("MJScene:onTouchBegan 111111 ")
		if self.chooseMjTile.mjTileSpr:getPositionY() == 91 then
			self.chooseMjTile.mjTileSpr:setPositionY(65)
		end
		return false
	end

	if not self.isPlayerShow or self.isPlayerDecision then
		gt.log("MJScene:onTouchBegan 222222 isPlayerShow = "..tostring(self.isPlayerShow)..", isPlayerDecision="..tostring(self.isPlayerDecision))
		-- if self.chooseMjTile.mjTileSpr:getPositionY() == 91 then
		-- 	self.chooseMjTile.mjTileSpr:setPositionY(65)
		-- end
		return false
	end

	if self.m_isTingPai == 1 then
		self.m_tingState = true
	else
		self.m_tingState = false
		if self.playType ~= 100009 and self.playType ~= 102009 and self.playType ~= 103009 then
			-- 耗子牌不能手动打出去
			if self.HaoZiCards then
				for i,card in ipairs(self.HaoZiCards) do
					if self.chooseMjTile.mjColor == card._color and self.chooseMjTile.mjNumber == card._number then
						isShowMjTile = false
					end
				end
			end
		else
			if isShowMjTile then
				-- 洪洞王牌耗子牌选择是否打出去
				if self.HaoZiCards then
					for i,card in ipairs(self.HaoZiCards) do
						if self.chooseMjTile.mjColor == card._color and self.chooseMjTile.mjNumber == card._number then
							local NoticeTips = require("client/game/dialog/NoticeTips"):create("提示","是否打出王牌？", 
							function( )
								if self.tingFlag == true then
								    --查看胡牌按钮
									local tinghuBtn = gt.seekNodeByName(self.rootNode, "Btn_tinghu")
									tinghuBtn:setVisible(true)
								end
							
								local isNeedKouPai = false      --是否需要倒扣牌
								gt.log("--------------------self.playType", self.playType)
								gt.log("--------------------self.isBeingTing", self.isBeingTing)

								-- 发送出牌消息
								local msgToSend = {}
								msgToSend.kMId = gt.CG_SHOW_MJTILE
								-- 出牌标识
								msgToSend.kType = 1
								msgToSend.kThink = {}
								if self.tingSendMessageFlag then
									msgToSend.kType = 7
									self.tingSendMessageFlag = false
									self.m_tingState = true

									local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
									selfDrawnDcsNode:setVisible(false)

									local roomPlayer = self.roomPlayers[self.playerSeatIdx]
									for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
										gt.log("牌置灰，不可出 222222")
										mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
									end

									self:clearHoldMjTilesData()
									
									roomPlayer.m_ting = {}
									if self.m_tingCards and next(self.m_tingCards) then
										for _, tingCard in ipairs(self.m_tingCards) do
											table.insert(roomPlayer.m_ting, {tingCard[1], tingCard[2]})
										end			
									end

									if self.playType ~= 100009 and self.playType ~= 102009 and self.playType ~= 103009 then
										--需要扣牌
										isNeedKouPai = true
									end
								else
									if self.playType ~= gt.RoomType.ROOM_CHANGSHA and self.playType ~= 4 and self.playType ~= 5 and self.playType ~= 9 then
										if msgToSend.kType == 3 then
											msgToSend.kType = 4
										elseif msgToSend.kType == 4 then
											msgToSend.kType = 8
										end
									end
								end
								gt.log("-------------------self.chooseMjTile.mjColor", self.chooseMjTile.mjColor)
								gt.log("-------------------self.chooseMjTile.mjNumber", self.chooseMjTile.mjNumber)
								local think_temp = {tonumber(self.chooseMjTile.mjColor),tonumber(self.chooseMjTile.mjNumber)}
								table.insert(msgToSend.kThink,think_temp)
								gt.socketClient:sendMessage(msgToSend)

						        gt.soundEngine:playEffect("common/card_drop_down", false, true, "mp3")

								self:updateOutCardColor(self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber, false)

								self.isPlayerShow = false
								self.preClickMjTile = nil
								-- 停止倒计时音效
								if self.playCDAudioID then
									gt.soundEngine:stopEffect(self.playCDAudioID)
									self.playCDAudioID = nil
								end

								--隐藏支对决策按钮
								local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
								for _, decisionBtn in ipairs(decisionBtnNode:getChildren()) do
									decisionBtn:setVisible(false)
								end
								if self.zhiDuiBg then
									self.zhiDuiBg:removeFromParent()
									self.zhiDuiBg = nil
								end

								-- 把牌先打出去
								self:addAlreadyOutMjTiles(self.playerSeatIdx, self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber, false, isNeedKouPai)

								-- 显示出的牌箭头标识
								self:showOutMjtileSign(self.playerSeatIdx)
								--先打出牌
								local  mj_color = self.chooseMjTile.mjColor
								local  mj_number = self.chooseMjTile.mjNumber	
								local roomPlayer = self.roomPlayers[self.playerSeatIdx]		
								if self.playType == 100004 and self.isBeingTing then 
									--如果是立四玩法，且当前是听牌这一手，则移除立四手牌中的已出牌
									gt.log("如果是立四玩法，且当前是听牌这一手，则移除立四手牌中的已出牌")
									local isLisiRemove = false  
									for i = #roomPlayer.lisiMjTiles, 1, -1 do
										local mjTile = roomPlayer.lisiMjTiles[i]
										if mjTile.mjColor == mj_color and mjTile.mjNumber == mj_number then
											mjTile.mjTileSpr:removeFromParent()
											table.remove(roomPlayer.lisiMjTiles, i)
											isLisiRemove = true
											break
										end
									end
									if not isLisiRemove then
										local mjTile = roomPlayer.lisiMjTiles[self.chooseMjTileIdx]
										if mjTile and mjTile.mjTileSpr then
											mjTile.mjTileSpr:removeFromParent()
											table.remove(roomPlayer.lisiMjTiles, self.chooseMjTileIdx)
										end
									end
								else
									--如果不是立四，或者是立四而未听牌，移除普通手牌
									gt.log("如果不是立四，或者是立四而未听牌，移除普通手牌")
									local isRemove = false
									if self.playMjLayer:getChildByName("holdMjNode") then
										self.holdMjNode:removeAllChildren()
									end
									--dump(roomPlayer.holdMjTiles)
									for i = #roomPlayer.holdMjTiles, 1, -1 do
										local mjTile = roomPlayer.holdMjTiles[i]
										if mjTile.mjColor == mj_color and mjTile.mjNumber == mj_number then
											-- mjTile.mjTileSpr:removeFromParent()
											table.remove(roomPlayer.holdMjTiles, i)
											isRemove = true
											break
										end
									end
									--dump(roomPlayer.holdMjTiles)
									for i = #roomPlayer.holdMjTiles, 1, -1 do
										local mjTile = roomPlayer.holdMjTiles[i]
										if mjTile.mjTileSpr then
											self:updateMjTileToPlayer(mjTile.mjTileSpr)
										end
									end
									if not isRemove then
										if self.playMjLayer:getChildByName("holdMjNode") then
											self.holdMjNode:removeAllChildren()
										end
										local mjTile = roomPlayer.holdMjTiles[self.chooseMjTileIdx]
										if mjTile and mjTile.mjTileSpr then
											gt.log("从手牌中移除打出去的牌 ======== ")
											--dump(mjTile)
											-- mjTile.mjTileSpr:removeFromParent()
											table.remove(roomPlayer.holdMjTiles, self.chooseMjTileIdx)
										end
										for i = #roomPlayer.holdMjTiles, 1, -1 do
											local mjTile = roomPlayer.holdMjTiles[i]
											if mjTile.mjTileSpr then
												self:updateMjTileToPlayer(mjTile.mjTileSpr)
											end
										end
									end
								end

								if not isNeedKouPai then
									gt.soundManager:PlayCardSound(gt.playerData.sex, mj_color, mj_number)
								end

								if self.playType == 100004 then
									self:showLisiMjTile()
								end
								
								self:sortPlayerMjTiles()

								if self:checkRightCradNum() == false then
									gt.log("--------gt.socketClient:reloginServer1")
									gt.socketClient:reloginServer()
									self.isTouchBegan = false
									self.isTouchMoved = false
									return
								end

								if self.AppVersion and self.AppVersion > 10 then
									local function update( )
										if self.scheduleSendMjTileHandler then
											gt.scheduler:unscheduleScriptEntry(self.scheduleSendMjTileHandler)
											self.scheduleSendMjTileHandler = nil
										end
										gt.dumplog(msgToSend)
										gt.dumplog(self.roomPlayers)
									end
									self.scheduleSendMjTileHandler = gt.scheduler:scheduleScriptFunc(handler(self, update), 0.5, false)
								end
								self.isTouchBegan = false
							end, 
							function( )
								self.isTouchBegan = false
							end, false)

							return
						NoticeTips:setYesNoLoadTextures()
						end
					end
				end
			end
		end
	end

	if self.tingSendMessageFlag == true then
		--显示能胡哪些牌
		local mjChoose = self.chooseMjTile.mjColor..self.chooseMjTile.mjNumber
		self:showHuCards(tonumber(mjChoose))
	end

	self.isTouchBegan = true

	if isShowMjTile then
		-- 优化直接出牌
		-- -- 显示出的牌
		-- self:addAlreadyOutMjTiles(self.playerSeatIdx, self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber)
		-- -- 显示出的牌箭头标识
		-- self:showOutMjtileSign(self.playerSeatIdx)
		
		-- self:showMjTileAnimation(self.playerSeatIdx, cc.p(self.chooseMjTile.mjTileSpr:getPositionX(),self.chooseMjTile.mjTileSpr:getPositionY()), self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber,function()
		-- 	end)
		if self.tingFlag == true then
		    --查看胡牌按钮
			local tinghuBtn = gt.seekNodeByName(self.rootNode, "Btn_tinghu")
			tinghuBtn:setVisible(true)
		end
	
		local isNeedKouPai = false      --是否需要倒扣牌
		gt.log("--------------------self.playType", self.playType)
		gt.log("--------------------self.isBeingTing", self.isBeingTing)

		-- 发送出牌消息
		local msgToSend = {}
		msgToSend.kMId = gt.CG_SHOW_MJTILE
		-- 出牌标识
		msgToSend.kType = 1
		msgToSend.kThink = {}
		if self.tingSendMessageFlag then
			msgToSend.kType = 7
			self.tingSendMessageFlag = false
			self.m_tingState = true

			local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
			selfDrawnDcsNode:setVisible(false)

			local roomPlayer = self.roomPlayers[self.playerSeatIdx]
			for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
				gt.log("牌置灰，不可出 222222")
				mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
			end

			self:clearHoldMjTilesData()
			
			roomPlayer.m_ting = {}
			if self.m_tingCards and next(self.m_tingCards) then
				for _, tingCard in ipairs(self.m_tingCards) do
					table.insert(roomPlayer.m_ting, {tingCard[1], tingCard[2]})
				end			
			end

			if self.playType ~= 100009 and self.playType ~= 102009 and self.playType ~= 103009 then
				--需要扣牌
				isNeedKouPai = true
			end
		else
			if self.playType ~= gt.RoomType.ROOM_CHANGSHA and self.playType ~= 4 and self.playType ~= 5 and self.playType ~= 9 then
				if msgToSend.kType == 3 then
					msgToSend.kType = 4
				elseif msgToSend.kType == 4 then
					msgToSend.kType = 8
				end
			end
		end
		gt.log("-------------------self.chooseMjTile.mjColor", self.chooseMjTile.mjColor)
		gt.log("-------------------self.chooseMjTile.mjNumber", self.chooseMjTile.mjNumber)
		local think_temp = {tonumber(self.chooseMjTile.mjColor),tonumber(self.chooseMjTile.mjNumber)}
		table.insert(msgToSend.kThink,think_temp)
		gt.socketClient:sendMessage(msgToSend)
		-- gt.dumplog(msgToSend)
		-- gt.dumplog(self.roomPlayers)

        gt.soundEngine:playEffect("common/card_drop_down", false, true, "mp3")

		self:updateOutCardColor(self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber, false)

		self.isPlayerShow = false
		self.preClickMjTile = nil
		-- 停止倒计时音效
		if self.playCDAudioID then
			gt.soundEngine:stopEffect(self.playCDAudioID)
			self.playCDAudioID = nil
		end

		--隐藏支对决策按钮
		local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
		for _, decisionBtn in ipairs(decisionBtnNode:getChildren()) do
			decisionBtn:setVisible(false)
		end
		if self.zhiDuiBg then
			self.zhiDuiBg:removeFromParent()
			self.zhiDuiBg = nil
		end
        -- gt.dumplog("~~~~~~~~~~~~~打出牌前~~~~~~~~~~~~~~")
		-- 把牌先打出去
		self:addAlreadyOutMjTiles(self.playerSeatIdx, self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber, false, isNeedKouPai)

		-- 显示出的牌箭头标识
		self:showOutMjtileSign(self.playerSeatIdx)
		--先打出牌
		local  mj_color = self.chooseMjTile.mjColor
		local  mj_number = self.chooseMjTile.mjNumber	
		local roomPlayer = self.roomPlayers[self.playerSeatIdx]		
		if self.playType == 100004 and self.isBeingTing then 
			--如果是立四玩法，且当前是听牌这一手，则移除立四手牌中的已出牌
			gt.log("如果是立四玩法，且当前是听牌这一手，则移除立四手牌中的已出牌")
			local isLisiRemove = false  
			for i = #roomPlayer.lisiMjTiles, 1, -1 do
				local mjTile = roomPlayer.lisiMjTiles[i]
				if mjTile.mjColor == mj_color and mjTile.mjNumber == mj_number then
					mjTile.mjTileSpr:removeFromParent()
					table.remove(roomPlayer.lisiMjTiles, i)
					isLisiRemove = true
					break
				end
			end
			if not isLisiRemove then
				local mjTile = roomPlayer.lisiMjTiles[self.chooseMjTileIdx]
				if mjTile and mjTile.mjTileSpr then
					mjTile.mjTileSpr:removeFromParent()
					table.remove(roomPlayer.lisiMjTiles, self.chooseMjTileIdx)
				end
			end
		else
			--如果不是立四，或者是立四而未听牌，移除普通手牌
			gt.log("如果不是立四，或者是立四而未听牌，移除普通手牌")
			local isRemove = false
			if self.playMjLayer:getChildByName("holdMjNode") then
				self.holdMjNode:removeAllChildren()
			end
			--dump(roomPlayer.holdMjTiles)
			for i = #roomPlayer.holdMjTiles, 1, -1 do
				local mjTile = roomPlayer.holdMjTiles[i]
				if mjTile.mjColor == mj_color and mjTile.mjNumber == mj_number then
					-- mjTile.mjTileSpr:removeFromParent()
					table.remove(roomPlayer.holdMjTiles, i)
					isRemove = true
					break
				end
			end
			--dump(roomPlayer.holdMjTiles)
			for i = #roomPlayer.holdMjTiles, 1, -1 do
				local mjTile = roomPlayer.holdMjTiles[i]
				if mjTile.mjTileSpr then
					self:updateMjTileToPlayer(mjTile.mjTileSpr)
				end
			end
			if not isRemove then
				if self.playMjLayer:getChildByName("holdMjNode") then
					self.holdMjNode:removeAllChildren()
				end
				local mjTile = roomPlayer.holdMjTiles[self.chooseMjTileIdx]
				if mjTile and mjTile.mjTileSpr then
					gt.log("从手牌中移除打出去的牌 ======== ")
					--dump(mjTile)
					-- mjTile.mjTileSpr:removeFromParent()
					table.remove(roomPlayer.holdMjTiles, self.chooseMjTileIdx)
				end
				for i = #roomPlayer.holdMjTiles, 1, -1 do
					local mjTile = roomPlayer.holdMjTiles[i]
					if mjTile.mjTileSpr then
						self:updateMjTileToPlayer(mjTile.mjTileSpr)
					end
				end
			end
		end

  --       gt.dumplog("打出牌后 打出去的牌数据")
		-- gt.dumplog(roomPlayer.outMjTiles)


  --       gt.dumplog("打出牌后 手牌数据")
		-- gt.dumplog(roomPlayer.holdMjTiles)
		if not isNeedKouPai then
			gt.soundManager:PlayCardSound(gt.playerData.sex, mj_color, mj_number)
		end

		if self.playType == 100004 then
			self:showLisiMjTile()
		end
		
		self:sortPlayerMjTiles()

		if self:checkRightCradNum() == false then
			gt.log("--------gt.socketClient:reloginServer1")
			gt.socketClient:reloginServer()
			self.isTouchBegan = false
			self.isTouchMoved = false
			return
		end

		if self.AppVersion and self.AppVersion > 10 then
			local function update( )
				if self.scheduleSendMjTileHandler then
					gt.scheduler:unscheduleScriptEntry(self.scheduleSendMjTileHandler)
					self.scheduleSendMjTileHandler = nil
				end
				gt.dumplog(msgToSend)
				gt.dumplog(self.roomPlayers)
			end
			self.scheduleSendMjTileHandler = gt.scheduler:scheduleScriptFunc(handler(self, update), 0.5, false)
		end

		-- 删除停牌标志
		-- self:removeTingLayer( )
		-- 把牌先打出去
		-- self:addAlreadyOutMjTiles(self.playerSeatIdx, self.chooseMjTile.mjColor, self.chooseMjTile.mjNumber)
		-- -- 显示出的牌箭头标识
		-- self:showOutMjtileSign(self.playerSeatIdx)
		-- -- 玩家持有牌中去除打出去的牌
		-- local mj_color = self.chooseMjTile.mjColor
		-- local mj_number = self.chooseMjTile.mjNumber
		-- local roomPlayer = self.roomPlayers[self.playerSeatIdx]
		-- for i = #roomPlayer.holdMjTiles, 1, -1 do
		-- 	local mjTile = roomPlayer.holdMjTiles[i]
		-- 	if mjTile.mjColor == mj_color and mjTile.mjNumber == mj_number then
		-- 		mjTile.mjTileSpr:removeFromParent()
		-- 		table.remove(roomPlayer.holdMjTiles, i)
		-- 		break
		-- 	end
		-- end
		-- gt.soundManager:PlayCardSound(gt.playerData.sex, mj_color, mj_number)
		-- self:sortPlayerMjTiles()
		
		-- if self:checkRightCradNum() == false then
		-- 	gt.log("--------gt.socketClient:reloginServer1")
		-- 	gt.socketClient:reloginServer()
		-- 	self.isTouchBegan = false
		-- 	self.isTouchMoved = false
		-- 	return
		-- end
	end
	self.isTouchBegan = false
end

function MJScene:playCardEffect(_spr)
	-- local tintby = cc.TintTo:create(0.5, 255, 255, 0)
	-- local tintTo = cc.TintTo:create(0.5, 255, 255, 255)
	-- local sequence = cc.Sequence:create(tintby, tintTo)
	-- local repeatForever = cc.RepeatForever:create(sequence)
	-- _spr:runAction(repeatForever)
	_spr:setColor(cc.c3b(243,243,10))
end

function MJScene:stopCardEffect(_spr)
	_spr:setColor(cc.WHITE)
	-- _spr:stopAllActions()
end

-- 刷新所有同样的牌颜色
function MJScene:updateOutCardColor(_color, _number, _isChange)
	for i, roomPlayer in pairs(self.roomPlayers) do
		if roomPlayer then
			if roomPlayer.outMjTiles then
				table.foreach(roomPlayer.outMjTiles, function(k, mjTile)
					if mjTile and mjTile.mjTileSpr then
						if mjTile.mjColor == _color and mjTile.mjNumber == _number and _isChange then
							-- mjTile.mjTileSpr:setColor(destColor)
							self:playCardEffect(mjTile.mjTileSpr)
						else
							-- mjTile.mjTileSpr:setColor(cc.WHITE)
							self:stopCardEffect(mjTile.mjTileSpr)
						end
					end
				end)
			end

			if roomPlayer.mjTilePungs then
				table.foreach(roomPlayer.mjTilePungs, function(k, mjTile)
					if mjTile and mjTile.groupNode then
						table.foreach(mjTile.groupNode:getChildren(), function(m, spr)
							if mjTile.mjColor == _color and mjTile.mjNumber == _number and _isChange then
								-- spr:setColor(destColor)
								self:playCardEffect(spr)
							else
								-- spr:setColor(cc.WHITE)
								self:stopCardEffect(spr)
							end
						end)
					end
				end)
			end

			if roomPlayer.mjTileNians then
				table.foreach(roomPlayer.mjTileNians, function(k, mjTile)
					if mjTile and mjTile.groupNode then
						table.foreach(mjTile.groupNode:getChildren(), function(m, spr)
							if mjTile.mjColor == _color and mjTile.mjNumber == _number and _isChange then
								-- spr:setColor(destColor)
								self:playCardEffect(spr)
							else
								-- spr:setColor(cc.WHITE)
								self:stopCardEffect(spr)
							end
						end)
					end
				end)
			end

			if roomPlayer.mjTileEat then
				table.foreach(roomPlayer.mjTileEat, function(k, mjTile)
					for i = 1, 3 do
						local tab = mjTile[i]
						local color = tab[3]
						local number = tab[1]
						if mjTile and mjTile.groupNode then
							local spr = mjTile.groupNode:getChildByTag(i)
							if spr then
								if color == _color and number == _number and _isChange then
									-- spr:setColor(destColor)
									self:playCardEffect(spr)
								else
									-- spr:setColor(cc.WHITE)
									self:stopCardEffect(spr)
								end
							end
						end
					end
				end)
			end
		end
	end

	-- 听后打出相同的牌  另一张置灰
	if self.m_isTingPai == 1 and not _isChange then
		local roomPlayer = self.roomPlayers[self.playerSeatIdx]
		for index, mjTile in ipairs(roomPlayer.holdMjTiles) do
			mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
		end
	end	
end

function MJScene:update(delta)
	self.updateTimeCD = self.updateTimeCD - delta
	if self.updateTimeCD <= 0 then
		self.updateTimeCD = 60
		self:updateCurrentTime()
	end

	-- 更新倒计时
	-- self:playTimeCDUpdate(delta)

	self.updateBatteryTime = self.updateBatteryTime + delta
	if self.updateBatteryTime >= 180 then
		self:updateBattery()
		self.updateBatteryTime = 0
	end

	-- if self.timerNum > 10 then
	-- 	return
	-- end
	-- 定位
	-- 	self.checkLocationTime = self.checkLocationTime + 1
	-- 	if self.checkLocationTime > self.locationMaxTime then
	-- 		-- Utils.locAction()
	-- 		self.checkLocationTime = 0
	-- 	else
	-- 		-- 发消息取位置
	-- 		if self.checkLocationTime % 180 == 0 then
	-- 			self.timerNum = self.timerNum + 1
	-- 			local infos = Utils.getLocationInfo()
	-- 			if ((infos.latitue == 0 and infos.longitude == 0) and self.timerNum == 10) or ((infos.latitue ~= 0 or infos.longitude ~= 0) and self.locationNum < 1) then
	-- 				-- require("client/game/dialog/NoticeTips"):create("提示", infos.latitue.."位置"..infos.longitude, nil, nil, true)
	-- 				-- 给服务器发消息 设置一个值  第二次不发 记录一个秒数  超过10秒取不到 表示玩家没给权限定位
	-- 				self.locationNum = self.locationNum + 1
	-- 				local msgToSend = {}
	-- 				msgToSend.m_msgId = gt.GC_LONGITUDE_LATITUDE
	-- 				msgToSend.m_longitue = tostring(infos.latitue)
	-- 				msgToSend.m_latitude = tostring(infos.longitude)
	-- 				gt.socketClient:sendMessage(msgToSend)
	-- 			end
	-- 		end
	-- end
	-- -- 如果不是13或者14张牌,直接重新登录
	-- if self:checkRightCradNum() == 2 and self.flushCardNumFlag == true then
	-- 	self.flushCardNumFlag = false
	-- 	gt.socketClient.isCheckNet = false
	-- 	-- 心跳时间稍微长一些,等待重新登录消息返回
	-- 	gt.socketClient.heartbeatCD = gt.socketClient.heatTime
	-- 	-- 监测网络状况下,心跳回复超时发送重新登录消息
	-- 	gt.socketClient:reloginServer()
	-- end
end

-- function MJScene:checkNoStart()
-- 	local isStart = true
-- 	local readySignNode = gt.seekNodeByName(self.rootNode, "Node_readySign")
-- 	for i = 1, 4 do
-- 		local readySignSpr = gt.seekNodeByName(readySignNode, "Spr_readySign_" .. i)
-- 		if not readySignSpr:isVisible() then
-- 			isStart = false
-- 		end
-- 	end
	
-- end

function MJScene:onRcvUpdateScore(msgTbl)
	gt.log("收到更新分数消息")
	--dump(msgTbl)

	if not msgTbl.kScore or #msgTbl.kScore ~= 4 then
		return false
	end
	local totalScore = 0
	for seatIdx, score in ipairs(msgTbl.kScore) do
		local roomPlayer = self.roomPlayers[seatIdx]
		if roomPlayer and roomPlayer.scoreLabel then
			roomPlayer.score = score
			roomPlayer.scoreLabel:setString(tostring(roomPlayer.score))
			totalScore = totalScore + score
		end
	end
	if totalScore ~= 4000 then
		require("client/game/dialog/NoticeTips"):create("提示", "分数结算错误,请联系客服!", nil, nil, true)
	end
end

function MJScene:initPaoMaDeng()
	-- 跑马灯
	local marqueeNode = gt.seekNodeByName(self.rootNode, "Node_marquee")
	local marqueeMsg = require("client/tools/MarqueeMsg"):create()
	marqueeNode:addChild(marqueeMsg)
	self.marqueeMsg = marqueeMsg
	if gt.marqueeMsgTemp then
		self.marqueeMsg:showMsg(gt.marqueeMsgTemp)
		self.marqueeMsg:setVisible(true)
		marqueeNode:setOpacity(90)
		marqueeNode:setVisible(true)
	end
end

function MJScene:onRcvMarquee(msgTbl)
	gt.log("收到跑马灯消息 222 ================= ")
	--dump(msgTbl)

	if gt.isIOSPlatform() and gt.isInReview then
		local str_des = gt.getLocationString("LTKey_0048")
		self.marqueeMsg:showMsg(str_des)
	else
		self.marqueeMsg:showMsg(msgTbl.kStr)
		gt.marqueeMsgTemp = msgTbl.kStr
		self.marqueeMsg:setVisible(true)
		local marqueeNode = gt.seekNodeByName(self.rootNode, "Node_marquee")
		marqueeNode:setOpacity(90)
		marqueeNode:setVisible(true)
	end
end

function MJScene:initWifi()
	local Node_Wifi = gt.seekNodeByName(self.rootNode, "Node_WIFI")
	-- wifi信号
	local FileNode_wifi = gt.seekNodeByName(Node_Wifi, "FileNode_wifi")
	local wifiNode, wifiAction = gt.createCSAnimation("Wifi.csb")
	wifiNode:setAnchorPoint( 0.5, 0 )
	wifiNode:setScale(1)

	self.wifiAction = wifiAction
	self.wifiNode = wifiNode
	FileNode_wifi:addChild(wifiNode)

	self:updateWifi()
end

function MJScene:updateWifi()
	local signalStatus = ""
	-- if Utils.checkVersion(1, 0, 17) then
	if gt.isIOSPlatform() then
		signalStatus = self:getStaticMethod("getInternetStatus")
	elseif gt.isAndroidPlatform() then
		signalStatus = self:getStaticMethod("getCurrentNetworkType")
	end
	if signalStatus == "WiFi" then
		signalStatus = "WIFI"
	end
	-- else
	-- 	signalStatus = self:getStaticMethod("getDeviceSignalStatus")
	-- end
	
	-- gt.log("updateWifi signalStatus = " .. signalStatus)
	if signalStatus == "WIFI" then
		local signalLevel = tonumber(self:getStaticMethod("getDeviceSignalLevel"))
		if signalLevel >= 0 and signalLevel <= 3 then
			self.wifiAction:play("wifi" .. signalLevel, true)
			self.wifiNode:setScale(0.5)
		end
	else
		local signalLevel = 4
		if gt.isAndroidPlatform() then
			signalLevel = tonumber(self:getStaticMethod("getDeviceNoWifiLevel"))
		elseif gt.isIOSPlatform() then
			signalLevel = tonumber(self:getStaticMethod("getDeviceSignalLevel"))
		end
		if signalStatus == "Not" then
			signalLevel = 0
		end
		if signalLevel >= 0 and signalLevel <= 4 then
			self.wifiAction:play("mobile" .. (tonumber(signalLevel) + 1), true)
			self.wifiNode:setScale(1.0)
		end
	end
end

function MJScene:updateBattery()
	local dianliangLabel = gt.seekNodeByName(self.csbNode, "Label_dianliang")
	local battery = self:getStaticMethod("getDeviceBattery")
	if battery ~= "" then
		dianliangLabel:setString(string.format("%d", tonumber(battery)).."%")
	else
		dianliangLabel:setString("0%")
	end
end

function MJScene:getStaticMethod(methodName)
	local ok = ""
	local result = ""
	if gt.isIOSPlatform() then
		ok, result = self.luaBridge.callStaticMethod("AppController", methodName)
	elseif gt.isAndroidPlatform() then
		ok, result = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", methodName, nil, "()Ljava/lang/String;")
	end
	return result
end

-- 检查手牌是否低于13张牌
function MJScene:checkRightCradNum()
	local roomPlayer = self.roomPlayers[self.playerSeatIdx]
	if not roomPlayer then -- 还未开始
		return 0
	end
	if not roomPlayer.holdMjTiles then
		return 0
	end
	-- --dump( roomPlayer )
	-- 玩家持有牌
	local holdNum = #roomPlayer.holdMjTiles
	-- 碰
	local pengNum = (#roomPlayer.mjTilePungs)*3
	-- 粘
	local nianNum = (#roomPlayer.mjTileNians)*2
	-- 明杠
	local mingGamgNum = (#roomPlayer.mjTileBrightBars)*3
	-- 暗杠
	local anGang = (#roomPlayer.mjTileDarkBars)*3
	-- 吃
	local chiNum = (#roomPlayer.mjTileEat)*3
	-- 明补
	local mingBuNum = (#roomPlayer.mjTileBrightBu)*3
	-- 暗补
	local anBuNum = (#roomPlayer.mjTileDarkBu)*3
	-- gt.log("===========手牌数量",holdNum,pengNum,mingGamgNum,anGang,chiNum,mingBuNum,anBuNum)
	local totalNum = holdNum+pengNum+nianNum+mingGamgNum+anGang+chiNum+mingBuNum+anBuNum
	-- gt.log("========总数量",totalNum)

	-- if totalNum==13 or totalNum==14 then
	-- 	return 1 -- 只有13或者14张牌才正确
	-- end

	return totalNum
end

-- start --
--------------------------------
-- @class function
-- @description 接收房卡信息
-- @param msgTbl 消息体
-- end --
function MJScene:onRcvRoomCard(msgTbl)
	gt.log("接收房卡信息")
	--dump(msgTbl)

	gt.playerData.roomCardsCount = {msgTbl.kCard1, msgTbl.kCard2, msgTbl.kCard3, msgTbl.kDiamondNum or 0}
	gt.dispatchEvent("REFRESH_FANGKA")
end

-- start --
--------------------------------
-- @class function
-- @description 进入房间
-- @param msgTbl 消息体
-- end --
function MJScene:onRcvEnterRoom(msgTbl)
	gt.log("-----------------------进入房间")
	--dump(msgTbl)

	--是否是房主
	gt.isCreateUserId = self:isRoomCreateUserId(msgTbl.kCreateUserId, gt.playerData.uid)

	-- --是否不是房主建房
	-- if msgTbl.m_deskCreatedType and msgTbl.m_deskCreatedType == 0 then
	-- 	gt.CreateRoomFlag = true
	-- else
	-- 	gt.CreateRoomFlag = false
	-- end
	self.isduanxian = true
	gt.dispatchEvent("EVT_CLOSE_FINAL_REPORT")
	
	gt.removeLoadingTips()

	self.isAutoOutTile = false

	self.playMjLayer:removeAllChildren()
	self:playerEnterRoom(msgTbl)

	self.chutaiShowFlag = true
end

-- start --
-------------------------------
-- @class function
-- @description 接收房间添加玩家消息
-- @param msgTbl 消息体
-- end --
function MJScene:onRcvAddPlayer(msgTbl)
	gt.log("收到添加玩家消息")
	gt.dump(msgTbl)
	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
	end

	-- 封装消息数据放入到房间玩家表中
	local roomPlayer = {}
	roomPlayer.uid = msgTbl.kUserId
	roomPlayer.nickname = msgTbl.kNike
	roomPlayer.headURL = string.sub(msgTbl.kFace, 1, string.lastString(msgTbl.kFace, "/")) .. "96"
	roomPlayer.sex = msgTbl.kSex
	roomPlayer.ip  = msgTbl.kIp
	roomPlayer.m_videoPermission  = msgTbl.kVideoPermission
	roomPlayer.m_userGps  = msgTbl.kUserGps
	
	-- 服务器位置从0开始
	-- 客户端位置从1开始
	roomPlayer.seatIdx = msgTbl.kPos + 1
	-- 显示座位编号(二人转转 4 1 ／ 三人转转4 1 3)
	gt.log("--------------------self.playersType", self.playersType)
	gt.log("--------------------roomPlayer.seatIdx", roomPlayer.seatIdx)
	-- if self.playersType == 2 then
	-- 	if roomPlayer.seatIdx == 1 then
	-- 		roomPlayer.displaySeatIdx = 4 - self.seatOffset <= 0 and 4 or 3
	-- 	elseif roomPlayer.seatIdx == 2 then
	-- 		roomPlayer.displaySeatIdx = 4 - self.seatOffset == 1 and 4 or 1
	-- 	else
	-- 		roomPlayer.displaySeatIdx = 4
	-- 	end
	-- elseif self.playersType == 3 then
	-- 	if self.playerSeatIdx == 1 then
	-- 		if roomPlayer.seatIdx == 2 then
	-- 			roomPlayer.displaySeatIdx = 1
	-- 		elseif roomPlayer.seatIdx == 3 then
	-- 			roomPlayer.displaySeatIdx = 3
	-- 		end
	-- 	elseif self.playerSeatIdx == 2 then
	-- 		if roomPlayer.seatIdx == 3 then
	-- 			roomPlayer.displaySeatIdx = 1
	-- 		elseif roomPlayer.seatIdx == 1 then
	-- 			roomPlayer.displaySeatIdx = 3
	-- 		end
	-- 	elseif self.playerSeatIdx == 3 then
	-- 		if roomPlayer.seatIdx == 1 then
	-- 			roomPlayer.displaySeatIdx = 1
	-- 		elseif roomPlayer.seatIdx == 2 then
	-- 			roomPlayer.displaySeatIdx = 3
	-- 		end
	-- 	end
	-- else
		gt.log("-----------------------------msgTbl.m_pos", msgTbl.kPos)
		gt.log("-----------------------------self.seatOffset", self.seatOffset)
		roomPlayer.displaySeatIdx = (msgTbl.kPos + self.seatOffset) % 4 == 0 and 4 or (msgTbl.kPos + self.seatOffset) % 4
	-- end
	gt.log("--------------------roomPlayer.displaySeatIdx", roomPlayer.displaySeatIdx)
	roomPlayer.readyState = msgTbl.kReady
	roomPlayer.score = msgTbl.kScore

	if msgTbl.kPos < 4 then
		gt.log("-----------------------------roomPlayer.uid2", msgTbl.kPos)
	gt.dump(msgTbl)
		self:roomRemoveUnSeatPlayers(msgTbl)
		gt.log("-----------------------------roomPlayer.uid3", msgTbl.kPos)
	gt.dump(msgTbl)
		-- for i = 1, #self.unSeatRoomPlayersIdx do
		-- 	if self.unSeatRoomPlayersIdx[i] == msgTbl.m_userId then
		-- 		self.unSeatRoomPlayers[self.unSeatRoomPlayersIdx[i]].unSeatIdx = i
		-- 		self:roomAddUnSeatPlayer(self.unSeatRoomPlayers[self.unSeatRoomPlayersIdx[i]])
		-- 	end
		-- end
		gt.log("-----------------------------roomPlayer.uid1", msgTbl.kPos)
	    -- 房间添加玩家
		self:roomAddPlayer(roomPlayer)

		local Node_selectseat = gt.seekNodeByName(self.rootNode, "Node_selectseat")
		gt.seekNodeByName(Node_selectseat, "Position"..roomPlayer.displaySeatIdx.."_Btn"):setVisible(false)
		-- 添加入缓冲
		-- self.roomPlayersByUid[roomPlayer.uid] = roomPlayer
		-- self:setVideoInfo()
	else
		gt.log("-----------------------------roomPlayer.uid2", msgTbl.kPos)
		gt.log("-----------------------------add roomPlayer.uid", roomPlayer.uid)
		gt.dump(roomPlayer)
		-- 添加入缓冲
		self.unSeatRoomPlayers[roomPlayer.uid] = roomPlayer
		local addUnSeatRoomPlayerFlag = true
		for i = 1, #self.unSeatRoomPlayersIdx do
			if self.unSeatRoomPlayersIdx[i] == roomPlayer.uid then
				addUnSeatRoomPlayerFlag = false
				break
			end
		end
		if addUnSeatRoomPlayerFlag == true then 
			table.insert(self.unSeatRoomPlayersIdx, roomPlayer.uid)
		end
		for i = 1, #self.unSeatRoomPlayersIdx do
			if self.unSeatRoomPlayersIdx[i] == roomPlayer.uid then
				self.unSeatRoomPlayers[self.unSeatRoomPlayersIdx[i]].unSeatIdx = i
				self:roomAddUnSeatPlayer(self.unSeatRoomPlayers[self.unSeatRoomPlayersIdx[i]])
			end
		end
	end

	if roomPlayer.uid ~= gt.playerData.uid then
		self.videoRoomPlayers[roomPlayer.uid] = roomPlayer.uid
	end

	self.mapRoomPlayers[roomPlayer.uid] = roomPlayer
	if roomPlayer.m_userGps and roomPlayer.m_userGps ~= "" then
		local GPSTable = string.split(msgTbl.kUserGps, ",")
	    self.mapRoomPlayers[roomPlayer.uid].userLanitude = GPSTable[1]
	    self.mapRoomPlayers[roomPlayer.uid].userLongitude = GPSTable[2]
	end
end

--当前玩家选牌时，其他玩家位置变换
function MJScene:updatePlayer(uid)

	local function removeUser( seatIdx )
		gt.log("----------------------------seatIdx", seatIdx)
		local roomPlayer = self.roomPlayers[seatIdx]
		if roomPlayer then
			gt.log("----------------------------roomPlayer.displaySeatIdx", roomPlayer.displaySeatIdx)
			-- 隐藏玩家信息
			local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displaySeatIdx)
			playerInfoNode:setVisible(false)

			-- 隐藏玩家准备手势
			local readySignNode = gt.seekNodeByName(self.rootNode, "Node_readySign")
			local readySignSpr = gt.seekNodeByName(readySignNode, "Spr_readySign_" .. roomPlayer.displaySeatIdx)
			readySignSpr:setVisible(false)
		    
			-- 取消头像下载监听
			local headSpr = gt.seekNodeByName(playerInfoNode, "Spr_head")
			self.playerHeadMgr:detach(headSpr)
		end

		-- -- 去除数据
		-- self.roomPlayers[seatIdx] = nil
	end


	gt.log("----------------------------self.playersType", self.playersType)
	for i = 1, self.playersType do
		gt.log("----------------------------removei1", i)
		if self.roomPlayers[i] then
		gt.log("----------------------------removei2", i)
			if self.roomPlayers[i].uid ~= uid then
		gt.log("----------------------------removei3", i)
				removeUser(self.roomPlayers[i].seatIdx)
				
		gt.log("----------------------------remove5", self.roomPlayers[i].displaySeatIdx)
			end
		end
	end

	for i = 1, self.playersType do
		gt.log("----------------------------addi1", i)
		if self.roomPlayers[i] then
		gt.log("----------------------------addi2", i)
			if self.roomPlayers[i].uid ~= uid then
		gt.log("----------------------------addi3", i)
				-- if self.playersType == 2 then
				-- 	if self.roomPlayers[i].seatIdx == 1 then
				-- 		self.roomPlayers[i].displaySeatIdx = 4 - self.seatOffset == 0 and 4 or 3
				-- 	elseif self.roomPlayers[i].seatIdx == 2 then
				-- 		self.roomPlayers[i].displaySeatIdx = 4 - self.seatOffset == 1 and 4 or 1
				-- 	end
				-- elseif self.playersType == 3 then
				-- 	if self.playerSeatIdx == 1 then
				-- 		if self.roomPlayers[i].seatIdx == 2 then
				-- 			self.roomPlayers[i].displaySeatIdx = 1
				-- 		elseif self.roomPlayers[i].seatIdx == 3 then
				-- 			self.roomPlayers[i].displaySeatIdx = 3
				-- 		end
				-- 	elseif self.playerSeatIdx == 2 then
				-- 		if self.roomPlayers[i].seatIdx == 3 then
				-- 			self.roomPlayers[i].displaySeatIdx = 1
				-- 		elseif self.roomPlayers[i].seatIdx == 1 then
				-- 			self.roomPlayers[i].displaySeatIdx = 3
				-- 		end
				-- 	elseif self.playerSeatIdx == 3 then
				-- 		if self.roomPlayers[i].seatIdx == 1 then
				-- 			self.roomPlayers[i].displaySeatIdx = 1
				-- 		elseif self.roomPlayers[i].seatIdx == 2 then
				-- 			self.roomPlayers[i].displaySeatIdx = 3
				-- 		end
				-- 	end
				-- else
					self.roomPlayers[i].displaySeatIdx = (self.roomPlayers[i].seatIdx - 1 + self.seatOffset) % 4 == 0 and 4 or (self.roomPlayers[i].seatIdx - 1 + self.seatOffset) % 4
				-- end
		gt.log("----------------------------add5", self.roomPlayers[i].displaySeatIdx)
				self:roomAddPlayer(self.roomPlayers[i])
			end
		end
	end

	-- self:setVideoInfo()
end

-- start --
--------------------------------
-- @class function
-- @description 初始化玩家信息
-- @param msgTbl 消息体
-- end --
function MJScene:clearPlayers()
	gt.log("----------------clearPlayers")
	for i = 1, 4 do
		-- 隐藏玩家信息
		local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. i)
		playerInfoNode:setVisible(false)

		-- 取消头像下载监听
		local headSpr = gt.seekNodeByName(playerInfoNode, "Spr_head")
		self.playerHeadMgr:detach(headSpr)

		-- 隐藏玩家准备手势
		local readySignSpr = gt.seekNodeByName(self.rootNode, "Spr_readySign_" .. i)
		readySignSpr:setVisible(false)

		-- 显示选座按钮
		local Node_selectseat = gt.seekNodeByName(self.rootNode, "Node_selectseat")
		gt.seekNodeByName(Node_selectseat, "Position"..i.."_Btn"):setVisible(true)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 从房间移除一个玩家
-- @param msgTbl 消息体
-- end --
function MJScene:onRcvRemovePlayer(msgTbl)
	if msgTbl.kPos == 4 then
		self:roomRemoveUnSeatPlayers(msgTbl)
		if self.m_Greater2CanStart == 1 then
			if msgTbl.kUserId == gt.playerData.uid then
				-- 动态开局退出房间
				gt.dispatchEvent(gt.EventType.BACK_MAIN_SCENE)
  		 		gt.dynamicStartQuickRoom = true
			end
		end
		return
	end
	gt.log("收到从房间移除一个玩家消息 ============= 1")
	if self.FinalReportFlag then
		gt.log("收到从房间移除一个玩家消息 ============= 2")
		return
	end
	gt.log("收到从房间移除一个玩家消息 ============= 3")
	--dump(msgTbl)

	gt.gameStart = false
	self.RoundStart = false

	-- self.hasRoomPlayerBeRemoved = true

	gt.log("移除玩家" .. msgTbl.kPos)
	local seatIdx = msgTbl.kPos + 1
	local roomPlayer = self.roomPlayers[seatIdx]
	-- 隐藏玩家信息
	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displaySeatIdx)
	playerInfoNode:setVisible(false)

	-- 取消头像下载监听
	local headSpr = gt.seekNodeByName(playerInfoNode, "Spr_head")
	self.playerHeadMgr:detach(headSpr)

	-- 隐藏玩家准备手势
	local readySignSpr = gt.seekNodeByName(self.rootNode, "Spr_readySign_" .. roomPlayer.displaySeatIdx)
	readySignSpr:setVisible(false)

	gt.log("----------------------roomPlayer.displaySeatIdx", roomPlayer.displaySeatIdx)
	gt.log("----------------------self.selectedseat", self.selectedseat)
	if self.selectedseat == false then
		-- 显示选座按钮
		local Node_selectseat = gt.seekNodeByName(self.rootNode, "Node_selectseat")
		gt.seekNodeByName(Node_selectseat, "Position"..roomPlayer.displaySeatIdx.."_Btn"):setVisible(true)
	end
    
	-- 去除数据
	self.roomPlayers[seatIdx] = nil
	self.mapRoomPlayers[roomPlayer.uid] = nil
	-- self:setVideoInfo()

	-- 动态开局提示和按钮状态
	if self.m_Greater2CanStart == 1 then
		self:setDynamicStartBtn(msgTbl)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 断线重连
-- end --
function MJScene:onRcvSyncRoomState(msgTbl)
	gt.log("收到断线重连消息 ================ ")

	self.touchFlag = false

	if self.roundReport then
		self.roundReport:setDisplay(false)
	end

	gt.dump(msgTbl)
	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
		gt.dumplog(self.roomPlayers)
	end

	if self.gangAfterChi then
		self.gangAfterChi:destroy()
		self.gangAfterChi = nil
	end
	
	if msgTbl.kState == 1 then
		-- 等待状态
		return
	end

    --start game
    if msgTbl.kState==2 then
    	--消失4个背景 移动头像位置 出现话筒的背景 
	    -- self.player_2:setPosition(cc.p(990,580.98))
		--self.player_4:setPosition(cc.p(150.28,215.64))
		-- self.player_4:setPosition(cc.p(92.15,215.64))
		-- self.yuyinPos_4:setPosition(cc.p(-442.10,-111.11))
		-- self.yuyinPos_2:setPosition(cc.p(241.1,243.14))
		-- self.playerChatBg_4:setPosition(cc.p(139.93, 208.98))

	 --    self.bg1:setVisible(false)
	 --    self.bg2:setVisible(false)
	 --    self.bg3:setVisible(false)
	 --    self.bg4:setVisible(false)
		--座位方向图隐藏
	    if self.positionTurnAnimateNode then
		    local turnPosLayerSpr = gt.seekNodeByName(self.csbNode,"Spr_turnPosLayer")
		    turnPosLayerSpr:setVisible(true)
			self.positionTurnAnimateNode:removeFromParent()
			self.positionTurnAnimateNode = nil
		end

		self.chutaiShowFlag = true

   		self:setVideoInfo()
    end

	self.pung = true
	self.m_isZhaNiao = false
	self.isAutoOutTile = false
	self.hasHuPaiDecision = false

	if self.showHuCardsPanel then
		self.showHuCardsPanel:setVisible(false)
		self.showHuCardsImage:setVisible(false)
	end

	-- 断线重连后,当前所选牌,索引等需要清理掉
	self.chooseMjTile 		= nil
	self.chooseMjTileIdx 	= nil
	self.preClickMjTile = nil
	
	self.huAnimationTime = 0

	--断线重连后，是否自动出牌
	if msgTbl.kITing and msgTbl.kITing[self.playerSeatIdx] == 3 then
		self.m_tingState = true
	else
		self.m_tingState = false
	end

	-- 断线重连后,如果听牌，记录可以胡的牌
	if msgTbl.kITingHuCard and next(msgTbl.kITingHuCard) then
		if self.hulist == nil  then
			self.hulist = {}
		end
		for i = 1, #msgTbl.kITingHuCard do
			self.hulist[i] = msgTbl.kITingHuCard[i][1]*10 + msgTbl.kITingHuCard[i][2]
		end
	    --查看胡牌按钮
		local tinghuBtn = gt.seekNodeByName(self.rootNode, "Btn_tinghu")
		tinghuBtn:setVisible(true)
		local seatIdx = msgTbl.kPos + 1
		local roomPlayer = self.roomPlayers[self.playerSeatIdx]
		if roomPlayer then
			roomPlayer.m_ting = msgTbl.kITingHuCard
		end
	end

	-- 隐藏等待界面元素
	local readyPlayNode = gt.seekNodeByName(self.rootNode, "Node_readyPlay")
	readyPlayNode:setVisible(false)
	self.dynamicStartBtn:setVisible(false)


	--退出房间按钮
	local outRoomBtn = gt.seekNodeByName(self.rootNode, "Btn_outRoom")
	outRoomBtn:setEnabled(false)

	-- 游戏开始后隐藏准备标识
	self:hidePlayersReadySign()
	local readyBtn = gt.seekNodeByName(self.rootNode, "Btn_ready")
	readyBtn:setVisible(false)
    
	-- 显示轮转座位标识
	local turnPosLayerSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosLayer")
	-- turnPosLayerSpr:setTexture("res/images/otherImages/turn_pos_bg_new.png")
    -- turnPosLayerSpr:setVisible(true)
	-- -- 显示游戏中按钮
	-- local playBtnsNode = gt.seekNodeByName(self.rootNode, "Node_playBtns")
	-- playBtnsNode:setVisible(true)
	-- if  self.playType == 12 then
	-- 	local messBtn = gt.seekNodeByName(playBtnsNode, "Btn_message")
	--     messBtn:setVisible(true)
	-- end

    self.messageBtn:setVisible(true)
	if gt.isAppStoreInReview == false then
   		self.yuyinBtn:setVisible(true)
	end

	local Node_dabao = gt.seekNodeByName(self.rootNode, "Node_dabao")
	local Image_logo = gt.seekNodeByName(self.rootNode, "Image_logo")

	self.playMjLayer:setVisible(true)

	gt.log("断线重连,记录耗子牌")
	--dump(msgTbl)
	if msgTbl.kHunCard and #msgTbl.kHunCard > 0  then
		-- if not self.HaoZiCards then
			self.HaoZiCards = {}
		-- end
		--首先判断是不是有耗子牌
		local ishavaHaozi = false
		for k,v in pairs(msgTbl.kHunCard) do
			local color = v[1]
			local number = v[2]
			if color ~= 0 and number ~= 0 then
				ishavaHaozi = true
				break
			end
		end
		Node_dabao:setVisible(ishavaHaozi)
		Image_logo:setVisible(not ishavaHaozi)
		local Spr_mjTileList = self:haoziListInCardTable(Node_dabao,2)
		if ishavaHaozi then
			cc.SpriteFrameCache:getInstance():addSpriteFrames("images/create_room_new.plist")
		end
		for k,v in ipairs(msgTbl.kHunCard) do
			local color = v[1]
			local number = v[2]

			if color ~= 0 and number ~= 0 then
				local mjTileName = Utils.getMJTileResName(4, color, number, self.isHZLZ)
				gt.log("麻将精灵图片＝＝"..mjTileName.."---index == "..k)
				-- Spr_mjTileList[k]._Spr_bg:setVisible(true)
				-- local imgfile = ""
				-- if gt.createType == 2 or gt.createType == 8 then
				-- 	imgfile = "sx_txt_table_mouse.png"
				-- elseif gt.createType == 5 then
				-- 	imgfile = "sx_txt_table_jin.png"
				-- end
				-- gt.log("------------------imgfile", imgfile)
				-- Spr_mjTileList[k]._Spr_name:ignoreContentAdaptWithSize(true)
				-- Spr_mjTileList[k]._Spr_name:loadTexture(imgfile,1)
				-- Spr_mjTileList[k]._Spr_name:setVisible(true)
				Spr_mjTileList[k]._Spr_mjTile:setVisible(true)
				Spr_mjTileList[k]._Spr_mjTile:initWithSpriteFrameName(mjTileName)
				self:addMouseMark(Spr_mjTileList[k]._Spr_mjTile, true)
			end
		end
		if #msgTbl.kHunCard == 2 then
			Spr_mjTileList[1]._Spr_mjTile:setPositionX(-25)
			Spr_mjTileList[2]._Spr_mjTile:setPositionX(25)
		end
		--记录耗子牌
		for k,v in pairs(msgTbl.kHunCard) do
			local color = v[1]
			local number = v[2]
			if color ~= 0 and number ~= 0 then
				local temp = {_color = color,_number = number}
				table.insert(self.HaoZiCards,temp)
			end
		end
		--dump(self.HaoZiCards)
	end

	if msgTbl.kPos then
		-- 显示当前出牌座位标示
		local seatIdx = msgTbl.kPos + 1
		self:setTurnSeatSign(seatIdx)
		-- if self.playerSeatIdx == seatIdx then
			local roomPlayer = self.roomPlayers[seatIdx]
			self:setClockTime(roomPlayer)
		-- end
		-- if seatIdx == self.playerSeatIdx then
		-- 	-- 玩家选择出牌
		-- 	self.isPlayerShow = false
		-- end
	end
    -- 牌局状态,剩余牌
	local roundStateNode = gt.seekNodeByName(self.rootNode, "Node_roundState")
	local remainTilesLabel = gt.seekNodeByName(roundStateNode, "Label_remainTiles")
	remainTilesLabel:setString(tostring(msgTbl.kDCount))

	self.Image_tilesCount:setVisible(true)
    self.Label_tilesCount:setString(tostring(msgTbl.kDCount).."张")
	
	-- 庄家座位号
	self.bankerSeatIdx = msgTbl.kZhuang + 1

	self.playMjLayer:removeAllChildren()
	
	--手牌麻将节点
	self.holdMjNode = cc.Node:create()
	self.playMjLayer:addChild(self.holdMjNode)
	self.holdMjNode:setName("holdMjNode")
	self.holdMjNode:setPosition(cc.p(0,0))

	-- 其他玩家牌
	for seatIdx = 1, 4 do
		local roomPlayer = self.roomPlayers[seatIdx]
		if roomPlayer then
			-- 庄家标识
			local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displaySeatIdx)
			local bankerSignSpr = gt.seekNodeByName(playerInfoNode, "Spr_bankerSign")
			local tingSignSpr = gt.seekNodeByName(playerInfoNode, "spr_ting")
			roomPlayer.isBanker = false
			bankerSignSpr:setVisible(false)
			if self.bankerSeatIdx == seatIdx then
				roomPlayer.isBanker = true
				bankerSignSpr:setVisible(true)
			end
			gt.log("听牌标识_begin＝＝")
			--dump(msgTbl)
			--dump(roomPlayer)
			gt.log("听牌标识_end")

			-- 玩家持有牌
			roomPlayer.holdMjTiles = {}
			-- 玩家持有立四手牌
			roomPlayer.lisiMjTiles = {}      
			-- 玩家已出牌
			roomPlayer.outMjTiles = {}
			-- 碰
			roomPlayer.mjTilePungs = {}
			-- 粘
			roomPlayer.mjTileNians = {}
			-- 明杠
			roomPlayer.mjTileBrightBars = {}
			-- 暗杠
			roomPlayer.mjTileDarkBars = {}
			-- 吃
			roomPlayer.mjTileEat = {}
			-- 明补
			roomPlayer.mjTileBrightBu = {}
			-- 暗补
			roomPlayer.mjTileDarkBu = {}

			-- 麻将放置参考点
			roomPlayer.mjTilesReferPos = self:setPlayerMjTilesReferPos(roomPlayer.displaySeatIdx)
			-- 剩余持有牌数量
			gt.log("--------------------剩余持有牌数量seatIdx", seatIdx)
			gt.log("--------------------self.playerSeatIdx", self.playerSeatIdx)
			roomPlayer.mjTilesRemainCount = msgTbl.kCardCount[seatIdx]
			gt.log("--------------------roomPlayer.mjTilesRemainCount", roomPlayer.mjTilesRemainCount)
			if roomPlayer.seatIdx == self.playerSeatIdx then
				if self.playType == 100004 then
					--如果是立四玩法，解析立四手牌
					for _, v in ipairs(msgTbl.kMySuoCard) do
						self:addLisiMjTileToPlayer(v[1], v[2])
						gt.log("添加立四手牌 111111")
					end
					--显示立四牌
					self:showLisiMjTile()
				end
				if self.playMjLayer:getChildByName("holdMjNode") then
					self.holdMjNode:removeAllChildren()
				end
				--玩家持有牌
				if msgTbl.kMyCard then
					for _, v in ipairs(msgTbl.kMyCard) do
						if v[1] ~= 0 and v[2] ~= 0 then
							self:addMjTileToPlayer(v[1], v[2])
						end
					end
					-- 根据花色大小排序并重新放置位置
					self:sortPlayerMjTiles()
				end
			else
				gt.log("-----------------------------------roomPlayer.mjTilesReferPos")
				--dump(roomPlayer.mjTilesReferPos)
				local mjTilesReferPos = roomPlayer.mjTilesReferPos
				local mjTilePos = mjTilesReferPos.holdStart
				if roomPlayer.mjTilesRemainCount == nil then roomPlayer.mjTilesRemainCount = 0 end
				local maxCount = roomPlayer.mjTilesRemainCount + 1
				for i = 1, maxCount do
					local mjTileName = string.format("tbgs_%d.png", roomPlayer.displaySeatIdx)
					local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
					mjTileSpr:setPosition(mjTilePos)
					self.playMjLayer:addChild(mjTileSpr, (gt.winSize.height - mjTilePos.y))
					-- if roomPlayer.displaySeatIdx == 1 then
					-- 	self.playMjLayer:addChild(mjTileSpr, (gt.winSize.height - mjTilePos.x - mjTilePos.y))
					-- else
					-- 	self.playMjLayer:addChild(mjTileSpr, (gt.winSize.height + mjTilePos.x - mjTilePos.y))
					-- end
					mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)

					local mjTile = {}
					mjTile.mjTileSpr = mjTileSpr
					table.insert(roomPlayer.holdMjTiles, mjTile)

					-- 隐藏多产生的牌
					if i > roomPlayer.mjTilesRemainCount then
						mjTileSpr:setVisible(false)
					end
				end
			end

			tingSignSpr:setVisible(false)
			if msgTbl.kTingState then
				if msgTbl.kTingState[seatIdx] == 1 then
					tingSignSpr:setVisible(true)
					if self.playerSeatIdx == seatIdx then
						for index, mjTile in ipairs(roomPlayer.holdMjTiles) do
							mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
						end
					else
						for index, mjTile in ipairs(roomPlayer.holdMjTiles) do
							mjTile.mjTileSpr:setColor(cc.c3b(130,130,130))
						end
					end
				else
					tingSignSpr:setVisible(false)
				end
			end

			if msgTbl.kScore and roomPlayer.scoreLabel then
				local score = msgTbl.kScore[seatIdx]
				if score then
					gt.log("seatIdx = " .. seatIdx .. ", score = " .. score)
					roomPlayer.score = score
					roomPlayer.scoreLabel:setString(tostring(roomPlayer.score))
				end
			end

			-- 服务器座次编号
			local turnPos = seatIdx - 1
			--需要听扣的牌序号
			local kouCardList = {}
			if msgTbl.kKouCount ~= nil then
				kouCardList = msgTbl.kKouCount
			end
			gt.log("需要听扣的牌序号")
			--dump(kouCardList)
			-- 已出牌
			local outMjTilesAry = msgTbl["kOCard" .. turnPos]
			if outMjTilesAry then
				for i=1, #outMjTilesAry do
					if kouCardList[turnPos+1] + 1 == i then
						if self.playType ~= 100009 and self.playType ~= 102009 and self.playType ~= 103009 then
							--如果需要听扣，则扣牌
							self:addAlreadyOutMjTiles(seatIdx, outMjTilesAry[i][1], outMjTilesAry[i][2], false, true)
						else
							--如果需要听扣，则扣牌
							self:addAlreadyOutMjTiles(seatIdx, outMjTilesAry[i][1], outMjTilesAry[i][2], false, false)
						end
					else
						self:addAlreadyOutMjTiles(seatIdx, outMjTilesAry[i][1], outMjTilesAry[i][2])
					end
				end
			end

			-- 暗杠
			local darkBarArray = msgTbl["kACard" .. turnPos]
			if darkBarArray then
				for _, v in ipairs(darkBarArray) do
					self:addMjTileBar(seatIdx, v[1], v[2], false)
				end
			end

			-- 明杠
			local brightBarArray = msgTbl["kMCard" .. turnPos]
			local brightBarArrayFirePos = msgTbl["kMCardFirePos" .. turnPos]
			if brightBarArray then
				for i, v in ipairs(brightBarArray) do
					gt.log("------------------i", i)
					gt.log("-------------------brightBarArrayFirePos[i]", brightBarArrayFirePos[i])
					self:addMjTileBar(seatIdx, v[1], v[2], true, brightBarArrayFirePos[i])
				end
			end

			-- 碰
			local pungArray = msgTbl["kPCard" .. turnPos]
			local pungArrayFirePos = msgTbl["kPCardFirePos" .. turnPos]
			if pungArray then
				for i, v in ipairs(pungArray) do
					gt.log("------------------i", i)
					gt.log("-------------------pungArrayFirePos[i]", pungArrayFirePos[i])
					self:addMjTilePung(seatIdx, v[1], v[2], false, pungArrayFirePos[i])
				end
			end

			--支对
			local zhiArray = msgTbl["kZhiCard" .. turnPos]
			gt.log("断线重连后的支对")
			--dump(zhiArray)
			if zhiArray then
				for _, v in ipairs(zhiArray) do
					self:addMjTileZhiDui(seatIdx, v[1], v[2])
				end
			end

			--吃
			local eatArray = msgTbl["kECard" .. turnPos]
			if eatArray then
				local eatTable = {}
				local group1 = {}
				local group2 = {}
				local group3 = {}
				local group4 = {}
				for i, v in ipairs(eatArray) do
					local endTag = nil
					if i <= 3 then
						table.insert(group1,{v[2],1,v[1]}) --牌号，手中牌标识，颜色
						if i == 3 then
							table.insert(eatTable,group1)
							table.insert(roomPlayer.mjTileEat,group1)
						end
					elseif i > 3 and i <= 6 then
						table.insert(group2,{v[2],1,v[1]})
						if i == 6 then
							table.insert(eatTable,group2)
							table.insert(roomPlayer.mjTileEat,group2)
						end
					elseif i > 6 and i <= 9  then
						table.insert(group3,{v[2],1,v[1]})
						if i == 9 then
							table.insert(eatTable,group3)
							table.insert(roomPlayer.mjTileEat,group3)
						end
					elseif i > 9 and i <= 12  then
						table.insert(group4,{v[2],1,v[1]})
						if i == 12 then
							table.insert(eatTable,group4)
							table.insert(roomPlayer.mjTileEat,group4)
						end
					end
				end

				for j, eatTile in pairs(eatTable) do
					roomPlayer.mjTileEat[j].groupNode = self:pungBarReorderMjTiles(seatIdx, eatTile[1][3], eatTile)
				end
			end
		end
	end
	self.pung = false

	if gt.isAppStoreInReview == false then
		self.yuyinBtn:setVisible(true)
	end

	if self.startMjTileAnimation ~= nil then
		self.startMjTileAnimation:stopAllActions()
		self.startMjTileAnimation:removeFromParent()
		self.startMjTileAnimation = nil
	end

	-- 这里开始验证牌数量是否为13或者14
	self.flushCardNumFlag = true

	-- 转运按钮
	-- local zhuanyunBtn = gt.seekNodeByName(self.rootNode, "Btn_zhuanyun")
	-- zhuanyunBtn:setVisible(true)
	-- 极速连接按钮
	-- local quickconnectBtn = gt.seekNodeByName(self.rootNode, "Btn_quickconnect")
	-- quickconnectBtn:setVisible(true)

	if self.AppVersion and self.AppVersion > 10 then
	    gt.dumplog("断线重连后 手牌信息")
		gt.dumplog(self.roomPlayers[msgTbl.kPos])
	end
end
-- start --
--------------------------------
-- @class function
-- @description 玩家准备手势
-- @param msgTbl 消息体
-- end --
function MJScene:onRcvReady(msgTbl)
	gt.log("收到玩家准备手势消息 ================ ")
	gt.dump(msgTbl)

	local seatIdx = msgTbl.kPos + 1
	gt.log("----------self.playerSeatIdx", self.playerSeatIdx)
	gt.log("----------seatIdx", seatIdx)
    if self.playerSeatIdx == seatIdx then
    	self:callbackNextReady()
    end

	self:playerGetReady(seatIdx)
end

-- start --
--------------------------------
-- @class function
-- @description 玩家在线标识
-- @param msgTbl 消息体
-- end --
function MJScene:onRcvOffLineState(msgTbl)
	gt.log("收到玩家在线标识消息 =============== ")
	gt.dump(msgTbl)
	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
	end

	local seatIdx = msgTbl.kPos + 1
	local roomPlayer = self.roomPlayers[seatIdx]
	-- local m_IP=msgTbl.m_ip
	if roomPlayer then
		local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displaySeatIdx)
		gt.log("--------------------------------roomPlayer.displaySeatIdx", roomPlayer.displaySeatIdx)
		-- -- 离线标示
		-- if msgTbl.m_flag == 0 then
		-- 	-- 掉线了
		-- 	if self.offLine[roomPlayer.displaySeatIdx] then
		-- 		self.offLine[roomPlayer.displaySeatIdx] = true
		-- 	end
		-- 	self.headSpr[roomPlayer.displaySeatIdx] = gt.createShaderState(self.headSpr[roomPlayer.displaySeatIdx], true)
		-- elseif msgTbl.m_flag == 1 then
		-- 	-- 回来了
		-- 	if self.offLine[roomPlayer.displaySeatIdx] then
		-- 		self.offLine[roomPlayer.displaySeatIdx] = false
		-- 	end
		-- 	self.headSpr[roomPlayer.displaySeatIdx] = gt.createShaderState(self.headSpr[roomPlayer.displaySeatIdx], false)
		-- 	if msgTbl.m_ip then
	 --           roomPlayer.ip= m_IP
		-- 	end
		-- end
		-- 离线标示
		local offLineSignSpr = gt.seekNodeByName(playerInfoNode, "Spr_offLineSign")
		if msgTbl.kFlag == 0 then
			-- 掉线了
			-- if self.offLine[roomPlayer.displaySeatIdx] then
				self.offLine[roomPlayer.displaySeatIdx] = true
			-- end
			offLineSignSpr:setVisible(true)
	        -- //正在查看本机视频的用户处于离线状态，则自动断掉视频
	        -- XZDDGameScence::Instance().leaveRemoteVideoChecking();
	        gt.log("-----------------self.isVipRoom1", self.isVipRoom)
			if self.isVipRoom then
	        gt.log("-----------------self.isVipRoom2", self.isVipRoom)
	        	self:onOffLineCloseVideoResult()
	        	self:onCloseVideoResult()
			end
		elseif msgTbl.kFlag == 1 then
			-- 回来了
			-- if self.offLine[roomPlayer.displaySeatIdx] then
				self.offLine[roomPlayer.displaySeatIdx] = false
			-- end
			offLineSignSpr:setVisible(false)
			-- if msgTbl.m_ip then
	  --          roomPlayer.ip= m_IP
			-- end
		end
	end
end

-- start --
--------------------------------
-- @class function
-- @description 开启地图
-- end --
function MJScene:startGameMap()
    local hasGpsUserCount = 0
    local name_1 = ""
    local lan_1 = ""
    local long_1 = ""
    
    local name_2 = ""
    local lan_2 = ""
    local long_2 = ""
    
    local name_3 =" "
    local lan_3 = ""
    local long_3 = ""
    
    local name_4 = ""
    local lan_4 = ""
    local long_4 = ""
    
    local noGpsUserCount = 0
    local noGPS_name_1=""
    local noGPS_name_2=""
    local noGPS_name_3=""
    local noGPS_name_4=""
    
    local index = 1
	for i, v in pairs(self.mapRoomPlayers) do
	    gt.log("------------------------self.mapRoomPlayers")

	    if v.userLanitude == nil and v.userLongitude == nil and v.m_userGps and v.m_userGps ~= "" then
			local GPSTable = string.split(v.m_userGps, ",")
		    v.userLanitude = GPSTable[1]
		    v.userLongitude = GPSTable[2]
		end

		if v then
			index = index + 1
			v.userLanitude = (v.userLanitude == nil or v.userLanitude == "") and 0 or v.userLanitude
			v.userLongitude = (v.userLongitude == nil or v.userLongitude == "") and 0 or v.userLongitude
			-- v.userLongitude = v.userLongitude + index*0.1

			if v.userLanitude == nil or v.userLongitude == nil or v.userLanitude == "" or v.userLongitude == ""
				or v.userLanitude == 0 or v.userLongitude == 0 then
	        	gt.log("------------------------noGpsUserCount")
                noGpsUserCount = noGpsUserCount + 1
                if noGpsUserCount == 1 then
                	noGPS_name_1 = v.nickname
                elseif noGpsUserCount == 2 then
                	noGPS_name_2 = v.nickname
                elseif noGpsUserCount == 3 then
                	noGPS_name_3 = v.nickname
                elseif noGpsUserCount == 4 then
                	noGPS_name_4 = v.nickname
                end
	        else
	        	gt.log("------------------------hasGpsUserCount")
	        	hasGpsUserCount = hasGpsUserCount + 1
	            if hasGpsUserCount == 1 then
	                name_1 = v.nickname
	                lan_1 = v.userLongitude
	                long_1 = v.userLanitude
	            elseif hasGpsUserCount == 2 then
	                name_2 = v.nickname
	                lan_2 = v.userLongitude
	                long_2 = v.userLanitude
	            elseif hasGpsUserCount == 3 then
	                name_3= v.nickname
	                lan_3 = v.userLongitude
	                long_3 = v.userLanitude
	            elseif hasGpsUserCount == 4 then
	                name_4 = v.nickname
	                lan_4 = v.userLongitude
	                long_4 = v.userLanitude
	            end
			end
		end
	end
    
    local checkMapNotice=""
    if noGpsUserCount > 0 then
        checkMapNotice = string.format("%s|%s|%s|%s 未提供GPS地图位置", noGPS_name_1, noGPS_name_2, noGPS_name_3, noGPS_name_4)
    end
    
    local checkMapUrl = ""
    local checkMapUrl = gt.getUrlEncryCode(string.format(gt.CheckMapUrl, name_1, long_1, lan_1,name_2, long_2, lan_2,name_3, long_3, lan_3,name_4, long_4, lan_4), gt.playerData.uid)
    

    gt.log("-----------------checkMapUrl", checkMapUrl)
    gt.log("-----------------checkMapNotice", checkMapNotice)
	self:getLuaBridge()
	if gt.isIOSPlatform() then
		local ok = self.luaBridge.callStaticMethod("AppController", "NativeStartMap", {mapUrl = checkMapUrl, notice = checkMapNotice})
	elseif gt.isAndroidPlatform() then
		local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "NativeStartMap", {checkMapUrl, checkMapNotice}, "(Ljava/lang/String;Ljava/lang/String;)V")
	end
end

-- start --
--------------------------------
-- @class function
-- @description 当前局数/最大局数量
-- @param msgTbl 消息体
-- end --
function MJScene:onRcvRoundState(msgTbl)
	-- 牌局状态,剩余牌
	gt.log("收到牌局状态,剩余牌局消息 ================")
	--dump(msgTbl)

	--隐藏播放互动动画节点
	-- local hudongAction = gt.seekNodeByName(self.rootNode, "Node_hudong")
	-- if hudongAction ~= nil then
	-- 	hudongAction:hide()
	-- end

	gt.gameStart = true
	self.RoundStart = true

	gt.curCircle = msgTbl.kCurCircle + 1

    cc.UserDefault:getInstance():setIntegerForKey("curCircle"..gt.deskId, gt.curCircle)

	self.m_curCircle = msgTbl.kCurCircle + 1

	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
		gt.dumplog(self.roomPlayers)
	end

	local roundStateNode = gt.seekNodeByName(self.rootNode, "Node_roundState")
	roundStateNode:setVisible(false)
	local remainTilesLabel = gt.seekNodeByName(roundStateNode, "Label_remainRounds")
	remainTilesLabel:setString(string.format("%d/%d", (msgTbl.kCurCircle + 1), msgTbl.kCurMaxCircle))

	--局数
	local roundCountLabel = gt.seekNodeByName(self.rootNode, "Label_roundCount")
	roundCountLabel:setString(string.format("%d/%d局", (msgTbl.kCurCircle + 1), msgTbl.kCurMaxCircle))

	self.m_numberMark = (msgTbl.kCurCircle + 1)
end

-- start --
--------------------------------
-- @class function
-- @description 游戏开始
-- @param msgTbl 消息体
-- end --
function MJScene:onRcvStartGame(msgTbl)
	gt.log("收到游戏开始消息 ============== ")
	--dump(msgTbl)

	self.KouPaiData = {}

	self.isPlayerShow = false

	if gt.isAppStoreInReview then
			local money = cc.UserDefault:getInstance():getIntegerForKey("money"..tostring(gt.playerData.uid), 0)
			if self.flag == 1 then
			if self.feeType and self.feeType == 0 then
	  			if gt.isCreateUserId then
					money = money - 3
	  			end
			elseif self.feeType and self.feeType == 1 then
				money = money - 1
			end
		elseif self.flag == 2 then
			if self.feeType and self.feeType == 0 then
	  			if gt.isCreateUserId then
					money = money - 6
	  			end
			elseif self.feeType and self.feeType == 1 then
				money = money - 2
			end
		end
			cc.UserDefault:getInstance():setIntegerForKey("money"..tostring(gt.playerData.uid), money)
	end

	if self.m_Greater2CanStart == 1 then
	end


	gt.log("gameCont...................",msgTbl.kGamePlayerCount)
	self.m_gamePlayerCount = msgTbl.kGamePlayerCount
	if self.m_curCircle == nil or self.m_curCircle == 1 then
		if self.m_Greater2CanStart == 1 then
	        --动态开局刷新玩家信息
			self:setRoomplayers(msgTbl)
	        --动态开局提示和按钮状态
			-- self:setDynamicStartBtn(msgTbl)
			self:dynamicStartTipsShow(false)
	   		require("client/game/dialog/NoticeTips"):create("提示", "房主已开始游戏，当前"..msgTbl.kGamePlayerCount.."人参与。\n动态开局房间的座位由系统自动安排。", nil, nil, true)
	    end
		-- gt.dumplog("clear")
	 	local setRoomInfo = function()
	 		if self.setRoomInfoScheduler then
	 			gt.scheduler:unscheduleScriptEntry(self.setRoomInfoScheduler)
	 			self.setRoomInfoScheduler = nil
	 		end
			self:setRoomInfoBtn(1)
	 	end
	    self.setRoomInfoScheduler = gt.scheduler:scheduleScriptFunc(setRoomInfo, 10, false)
	end
	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
		gt.dumplog(self.roomPlayers)
	end

	gt.gameStart = true

	self:setVideoInfo()

	if self.m_curCircle and self.m_curCircle == 1 then
		cc.Device:vibrate(1)

		gt.soundEngine:playEffect("common/game_start", false, true)
	end

	self.selfDrawnDecisionFlag = 1

	--退出房间按钮
	local outRoomBtn = gt.seekNodeByName(self.rootNode, "Btn_outRoom")
	outRoomBtn:setEnabled(false)

	local readyPlayNode = gt.seekNodeByName(self.rootNode, "Node_readyPlay")
	readyPlayNode:setVisible(false)
	self.dynamicStartBtn:setVisible(false)

	self:initStart(msgTbl)
	self.playMjLayer:setVisible(false)

 	local play = function()
 		if self.playScheduler then
 			gt.scheduler:unscheduleScriptEntry(self.playScheduler)
 			self.playScheduler = nil
 		end
		self:gameStartAnimation(msgTbl)
 	end
 	
    self.playScheduler = gt.scheduler:scheduleScriptFunc(play, self.delayTime, false)
end

--动态开局开始游戏刷新数据
function MJScene:setRoomplayers(msgTbl)
	gt.log("------------------setRoomplayers")

	gt.log("------------------self.playType", self.playType)
	local playTypeDesc = self:setPlayInfo(self.playType, msgTbl.kGamePlayerCount)
    self.mjTypeLabel:setString("玩法:"..playTypeDesc)

	local function removeUser( seatIdx )
		gt.log("----------------------------seatIdx", seatIdx)
		local roomPlayer = self.roomPlayers[seatIdx]
		if roomPlayer then
			gt.log("----------------------------roomPlayer.displaySeatIdx", roomPlayer.displaySeatIdx)
			-- 隐藏玩家信息
			local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displaySeatIdx)
			playerInfoNode:setVisible(false)

			-- 隐藏玩家准备手势
			local readySignNode = gt.seekNodeByName(self.rootNode, "Node_readySign")
			local readySignSpr = gt.seekNodeByName(readySignNode, "Spr_readySign_" .. roomPlayer.displaySeatIdx)
			readySignSpr:setVisible(false)
		    
			-- 取消头像下载监听
			local headSpr = gt.seekNodeByName(playerInfoNode, "Spr_head")
			self.playerHeadMgr:detach(headSpr)
		end
	end

	gt.log("----------------------------self.playersType", self.playersType)
	for i = 1, 4 do
		gt.log("----------------------------removei1", i)
		if self.roomPlayers[i] then
		gt.log("----------------------------removei2", i)
			-- if self.roomPlayers[i].uid ~= uid then
		gt.log("----------------------------removei3", i)
				removeUser(self.roomPlayers[i].seatIdx)
				
		gt.log("----------------------------remove5", self.roomPlayers[i].displaySeatIdx)
			-- end
		end
	end

	--刷新玩家位置
	local tempRoomPlayers = {}
    for i = 1, 4 do
    	if self.roomPlayers[i] ~= nil then
		    for j = 1, 4 do
		    	if msgTbl.kPosUserid[j] ~= nil then
		    		if tonumber(self.roomPlayers[i].uid) == tonumber(msgTbl.kPosUserid[j]) then
		    			tempRoomPlayers[j] = self.roomPlayers[i]
		    			tempRoomPlayers[j].seatIdx = j
		    			if tonumber(gt.playerData.uid) == tonumber(self.roomPlayers[i].uid) then
		    				gt.log("------gt.playerData.uid", gt.playerData.uid)
		    				gt.log("------j", j)
			    			self.playerSeatIdx = j
			    			self.playerFixDispSeat = 4
							self.seatOffset = self.playerFixDispSeat - (j - 1)
			    		end
		    		end
		    	end
		    end
    	end
    end

	for i = 1, 4 do
		if tempRoomPlayers[i] then
			tempRoomPlayers[i].displaySeatIdx = (i - 1 + self.seatOffset) % 4 == 0 and 4 or (i - 1 + self.seatOffset) % 4
		end
	end

    self.roomPlayers = tempRoomPlayers

    gt.log("--------------------setRoomplayers")
    gt.dump(self.roomPlayers)

	for i = 1, self.playersType do
		gt.log("----------------------------addi1", i)
		if self.roomPlayers[i] then
		gt.log("----------------------------addi2", i)
			-- if self.roomPlayers[i].uid ~= uid then
		gt.log("----------------------------addi3", i)

		-- self.roomPlayers[i].displaySeatIdx = (self.roomPlayers[i].seatIdx - 1 + self.seatOffset) % 4 == 0 and 4 or (self.roomPlayers[i].seatIdx - 1 + self.seatOffset) % 4

		gt.log("----------------------------add5", self.roomPlayers[i].displaySeatIdx)
				self:roomAddPlayer(self.roomPlayers[i])
			-- end
		end
	end

	local turnPosBgSpr = gt.seekNodeByName(self.csbNode,"Spr_turnPosBg")
	turnPosBgSpr:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("sx_img_table_turntable"..self.playerSeatIdx..".png"))
	local dataTable = {}
	 dataTable.kPos = self.playerSeatIdx - 1
	self:positionRotation(dataTable)
end

--检测是否是同ip
function MJScene:checkHasEqualIP( )
    local bEqualIdx = {}
    local bFind = false
    for i = 1, 4 do
        table.insert(bEqualIdx, false)
    end

    local list = {}
    for i=1, 4 do
    	if self.roomPlayers[i] ~= nil then
    		table.insert(list, {self.roomPlayers[i].uid, self.roomPlayers[i].nickname, self.roomPlayers[i].ip})
    	end
    end

    for idx = 1, 4 do
        local userItem = self.roomPlayers[idx]

        if nil == userItem or userItem.uid == gt.playerData.uid or userItem.ip == nil then
        else
			if self.AppVersion and self.AppVersion > 10 then
		        if userItem and userItem.ip == nil then
					gt.dumplog("ip:"..idx..",".."nil")
		        else
					gt.dumplog("ip:"..idx..","..userItem.ip)
		        end
		    end
            for cnt = idx + 1, 4 do
                local tmpUserItem = self.roomPlayers[cnt]
                if tmpUserItem ~= nil and tmpUserItem.uid ~= gt.playerData.uid then
                    local ip_1 = userItem.ip
                    local ip_2 = tmpUserItem.ip
                    if ip_1 ~= nil and ip_2 ~= nil and ip_1 == ip_2 then
                        bEqualIdx[idx] = true
                        bEqualIdx[cnt] = true
                        bFind = true
                    end
                end
            end
            if bFind then
                break
            end
        end
    end

    local firstStr = ""
    local secondStr = ""
    for i = 1, 4 do
        if bEqualIdx[i] == true then
            if secondStr == "" then
                secondStr = self.roomPlayers[i].nickname
            else
                if firstStr ~= nil then
                    firstStr = firstStr .. ","
                end
                firstStr = firstStr .. self.roomPlayers[i].nickname
            end
        end
    end
    if firstStr ~= "" then
    	-- local txt = secondStr .. firstStr .. "IP相同"
        local msg = secondStr .. firstStr .. "IP相同"
        for i = 1, 4 do
        	if list[i] then
	        	msg = msg.."\nID:"..list[i][1]..",IP:"..list[i][3]
	        	-- txt = txt..",ID:"..list[i][1]..",IP:"..list[i][3]
	        end
        end
        -- local txt = "room_no:"..self.roomID..", message:"..txt
        -- self:uploadText(txt)
		require("client/game/dialog/NoticeForSystemTips"):create(msg, 24)
    end
end

function MJScene:uploadText(text)
	-- local xhr = cc.XMLHttpRequest:new()
	-- xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	-- local tempUrl = string.format(gt.uploadTextUrl, text)
	-- local postUploadTextURL = gt.getUrlEncryCode(tempUrl, gt.playerData.uid)
	-- gt.log("------------postUploadTextURL", postUploadTextURL)
	-- xhr:open("GET", postUploadTextURL)
	-- --xhr:setRequestHeader("text", "text")
	-- local function onResp()
	-- 	if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	-- 		local response = xhr.response
	-- 		require("cjson")
	-- 		local respJson = json.decode(response)
	-- 		gt.log("------------postUploadTextURL", postUploadTextURL)
	-- 		dump(respJson)
	-- 		if respJson.errno == 0 then
	-- 		else
	-- 		end
	-- 	elseif xhr.readyState == 1 and xhr.status == 0 then
	-- 	end
	-- 	xhr:unregisterScriptHandler()
	-- end
	-- xhr:registerScriptHandler(onResp)
	-- xhr:send()
end

--检测相同ip
function MJScene:checkSameIp()
	if gt.totalPlayerNum == 2 then return end
	
	--显示同一ip提示
    local oneSameIp = {}      --与第一个玩家相同ip的玩家昵称列表 nickname
    local twoSameIp = {}      --与第二个玩家相同ip的玩家昵称列表 nickname
    local threeSameIp = {}      --与第三个玩家相同ip的玩家昵称列表 nickname

    for i=2, 4 do
    	if self.roomPlayers[i] ~= nil then
    		--dump(self.roomPlayers[i])
    		if self.roomPlayers[i].ip == self.roomPlayers[1].ip then
    			table.insert(oneSameIp, self.roomPlayers[i].nickname)
    		end
    	end
    end

    table.insert(oneSameIp, self.roomPlayers[1].nickname)
    table.insert(twoSameIp, self.roomPlayers[2].nickname)
    table.insert(threeSameIp, self.roomPlayers[3].nickname)

    --如果与第一个玩家同ip的人数少于2人，继续判断
    if #oneSameIp < 3 then
	    for i=3, 4 do
	    	if self.roomPlayers[i] ~= nil then
	    		--dump(self.roomPlayers[i])
	    		if self.roomPlayers[i].ip == self.roomPlayers[2].ip then
	    			table.insert(twoSameIp, self.roomPlayers[i].nickname)
	    		end
	    	end
	    end
	end

	--如果与第二个玩家同ip的人数少于1人，继续判断
	if #twoSameIp < 2 then
		if self.roomPlayers[3] ~= nil and self.roomPlayers[4] ~= nil then
			if self.roomPlayers[3].ip == self.roomPlayers[4].ip then
				table.insert(threeSameIp, self.roomPlayers[4].nickname)
			end
		end
	end

	gt.log("测试相同IP")
	--dump(oneSameIp)
	--dump(twoSameIp)
	--dump(threeSameIp)

	local txt = ""
	if #oneSameIp > 1 then
		for i=1, #oneSameIp do
			if i == 1 then
				txt = txt..oneSameIp[1]
			elseif i == #oneSameIp then
				txt = txt..","..oneSameIp[#oneSameIp].." 为相同ip"
			else
				txt = txt..","..oneSameIp[i]
			end
		end
	end
	if #twoSameIp > 1 then
		for i=1, #twoSameIp do
			if i == 1 then
				txt = txt..twoSameIp[1]
			elseif i == #twoSameIp then
				txt = txt..","..twoSameIp[#twoSameIp].." 为相同ip"
			else
				txt = txt..","..twoSameIp[i]
			end
		end
	end
	if #threeSameIp > 1 then
		for i=1, #threeSameIp do
			if i == 1 then
				txt = txt..threeSameIp[1]
			elseif i == #threeSameIp then
				txt = txt..","..threeSameIp[#threeSameIp].." 为相同ip"
			else
				txt = txt..","..threeSameIp[i]
			end
		end
	end
	if txt ~= "" then
		require("client/game/dialog/NoticeForSystemTips"):create(txt)
	end
	-- local sameIpNode = gt.seekNodeByName(self.rootNode, "Node_Same_Ip")
	-- if txt == "" then
	-- 	sameIpNode:setVisible(false)
	-- else
	-- 	sameIpNode:setZOrder(20000000000)
	-- 	local txtNode = gt.seekNodeByName(sameIpNode, "Text_6")
	-- 	local position = cc.p(sameIpNode:getPosition())
	-- 	local callFunc1 = cc.CallFunc:create(function(sender)
	-- 		sameIpNode:setPosition(position.x,position.y + 200)
	-- 		sameIpNode:setVisible(true)
	-- 		txtNode:setString(txt)
	-- 	end)
	-- 	local moveTo = cc.MoveTo:create(2, cc.p(position.x, position.y))
	-- 	local delayTime = cc.DelayTime:create(3)
	-- 	local moveTo1 = cc.MoveTo:create(2, cc.p(position.x, position.y + 600))
	-- 	local sequence = cc.Sequence:create(callFunc1,moveTo,delayTime,moveTo1)
	-- 	sameIpNode:runAction(sequence)
	-- end
end

function MJScene:setClockTime(roomPlayer)
	gt.log(debug.traceback())

	if self.FinalReportFlag then
		return
	end

	if roomPlayer == nil then
		return
	end

	for i = 1, 4 do
		if self.m_clockLabel[i] then
		    self.m_clockLabel[i]:setString("")
		    self.m_clockLabel[i]:setVisible(false)
			self.m_TimeProgress[i]:setPercentage(0)
			self.m_TimeProgress[i]:stopAllActions()
			self.clockSprite[i]:setVisible(false)
	        if self._time[i] then
	            gt.scheduler:unscheduleScriptEntry(self._time[i])
	            self._time[i] = nil
	        end
	    end
	end
	
	for i = 1, 4 do
		gt.log("------------roomPlayer.displaySeatIdx1", roomPlayer.displaySeatIdx)
		if i == roomPlayer.displaySeatIdx then
		gt.log("------------roomPlayer.displaySeatIdx2", cc.UserDefault:getInstance():getIntegerForKey("ClockTime"..i, 0))
			local clockTime = 0
			if cc.UserDefault:getInstance():getIntegerForKey("ClockTime"..i, 0) == 0 then
				clockTime = 60
			else
		gt.log("------------os.time()", os.time())
				clockTime = 60 - (os.time() - cc.UserDefault:getInstance():getIntegerForKey("ClockTime"..i, 0))
			end
		gt.log("------------setIntegerForKey", os.time() - (clockTime < 0 and 0 or clockTime))
			-- cc.UserDefault:getInstance():setIntegerForKey("ClockTime"..i, os.time() - clockTime)

		gt.log("------------clockTime", clockTime)
			self.m_clockLabel[i]:setVisible(true)
			self.m_clockLabel[i]:setString(tostring(clockTime < 0 and 0 or clockTime))
			self:setGameClock(i, clockTime <= 0 and 0.1 or clockTime)
			if cc.UserDefault:getInstance():getIntegerForKey("ClockTime"..i, 0) == 0 then
				cc.UserDefault:getInstance():setIntegerForKey("ClockTime"..i, os.time())
			end
		else
			if self.m_clockLabel[i] then
			    self.m_clockLabel[i]:setString("")
			    self.m_clockLabel[i]:setVisible(false)
	    		self.m_TimeProgress[i]:setPercentage(0)
	    		self.m_TimeProgress[i]:stopAllActions()
	    		self.clockSprite[i]:setVisible(false)
	            if self._time[i] then
	                gt.scheduler:unscheduleScriptEntry(self._time[i])
	                self._time[i] = nil
	            end
				cc.UserDefault:getInstance():setIntegerForKey("ClockTime"..i, 0)
			end
		end
	end
end


function MJScene:setHoldMjTilesTing()
	if self.tingCards == nil and self.tingCards.seatIdx == nil then
		return
	end
	local roomPlayer = self.roomPlayers[self.tingCards.seatIdx]
	if roomPlayer == nil then
		return
	end

	if (next(self.tingCards) ~= nil) then
		roomPlayer.m_ting = {}
		for index, mjTile in ipairs(roomPlayer.holdMjTiles) do
			local hasCard = false
			for _, tingCard in ipairs(self.tingCards) do
				if tingCard[1] == mjTile.mjColor and tingCard[2] == mjTile.mjNumber then
					-- if msgTbl.m_flag == 0 then
						
					-- else
						hasCard = true
					-- end
					break
				end
			end

			for _, tingCard in ipairs(self.tingCards) do
				table.insert(roomPlayer.m_ting, {tingCard[1], tingCard[2]})
			end

			if hasCard then
				if self.playType == 100004 and self.isBeingTing then
					--如果是立四玩法，且当前听牌了，普通手牌置灰
					mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
				else
					gt.log("牌置白，可出")
					--dump(mjTile)
					mjTile.mjTileSpr:setColor(cc.WHITE)
				end
			else
				gt.log("牌置灰，不可出 111111")
				--dump(mjTile)
				mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
			end
		end

		if self.playType == 100004 then
			--如果是立四玩法，需要检测立四手牌哪些可出
			for index, mjTile in ipairs(roomPlayer.lisiMjTiles) do
				local hasCard = false
				for _, tingCard in ipairs(self.tingCards) do
					if tingCard[1] == mjTile.mjColor and tingCard[2] == mjTile.mjNumber then
						-- if msgTbl.m_flag == 0 then
							
						-- else
							hasCard = true
						-- end
						break
					end
				end

				if hasCard then
					gt.log("牌置白，可出")
					--dump(mjTile)
					mjTile.mjTileSpr:setColor(cc.WHITE)
				else
					gt.log("牌置灰，不可出 111111")
					--dump(mjTile)
					mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
				end
			end
		end
	else
		for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
			gt.log("牌置灰，不可出 222222")
			--dump(mjTile)
			mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
		end
	end
end

function MJScene:setHoldMjTilesGuo()
	gt.log("------------------------guo")
	gt.dump(self.tingCards)
	if self.tingCards == nil and self.tingCards.seatIdx == nil then
		return
	end
	local roomPlayer = self.roomPlayers[self.tingCards.seatIdx]
	gt.dump(roomPlayer.holdMjTiles)
	if roomPlayer == nil then
		return
	end

	if (next(self.tingCards) ~= nil) then
		roomPlayer.m_ting = {}
		for index, mjTile in ipairs(roomPlayer.holdMjTiles) do
			gt.log("牌置白，可出")
			--dump(mjTile)
			mjTile.mjTileSpr:setColor(cc.WHITE)
		end
	end

	if self.showHuCardsPanel then
		self.showHuCardsPanel:setVisible(false)
		self.showHuCardsImage:setVisible(false)
	end

	self:clearHoldMjTilesData()
end

function MJScene:clearHoldMjTilesData()
	local roomPlayer = self.roomPlayers[self.tingCards.seatIdx]
	if roomPlayer then
		roomPlayer.m_ting = {}
	end
	self.tingCards = {}
	self.tingCards.seatIdx = 0
end

-- start --
--------------------------------
-- @class function
-- @description 通知玩家出牌
-- @param msgTbl 消息体
-- end --
function MJScene:onRcvTurnShowMjTile(msgTbl)
	gt.log("收到通知玩家出牌消息 ===============")
	gt.dump(msgTbl)
	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
		gt.dumplog(self.roomPlayers)
	end

	self.curTypeIsGang = false	

	-- self.isBeingTing = false
	-- gt.log("听牌 666666 isBeingTing="..tostring(self.isBeingTing))

	-- --是否不是房主建房
	-- if msgTbl.m_deskCreatedType and msgTbl.m_deskCreatedType == 0 then
	-- 	gt.CreateRoomFlag = true
	-- else
	-- 	gt.CreateRoomFlag = false
	-- end

	-- 牌局状态,剩余牌
	local roundStateNode = gt.seekNodeByName(self.rootNode, "Node_roundState")
	local remainTilesLabel = gt.seekNodeByName(roundStateNode, "Label_remainTiles")
	remainTilesLabel:setString(tostring(msgTbl.kDCount))

	self.Image_tilesCount:setVisible(true)
    self.Label_tilesCount:setString(tostring(msgTbl.kDCount).."张")

	local seatIdx = msgTbl.kPos + 1
	-- 当前出牌座位
	self:setTurnSeatSign(seatIdx)

	gt.log("-------------------------------seatIdx", seatIdx)
	gt.log("-------------------------------self.playerSeatIdx", self.playerSeatIdx)

	-- 出牌倒计时
	self:playTimeCDStart(msgTbl.kTime)
	local roomPlayer = self.roomPlayers[seatIdx]
	if roomPlayer == nil then
		return
	end
	-- 该玩家是否杠过（0-没杠过，1-杠过了）
	roomPlayer.m_gang = msgTbl.kGang

	self.turnSeatIdx  = seatIdx

	if self.chutaiShowFlag == true then
		self:setClockTime(roomPlayer)
	end

	if seatIdx == self.playerSeatIdx then
		--记录玩家可胡牌
		if msgTbl.kTingChuKou ~= nil and next(msgTbl.kTingChuKou) ~= nil then
			self.showHuCardsList = {}
			self.showHuCardsList = msgTbl.kTingChuKou
			if msgTbl.kTing == 1 then
				self.hulist = self.showHuCardsList[1].kTingKou
			end
		end

		-- 轮到玩家出牌
		self.isPlayerShow = true
		self.m_isTingPai = msgTbl.kTing
		if msgTbl.kTing == 1 then
			if (next(msgTbl.kTingCards) ~= nil) then
				roomPlayer.m_ting = {}
				for index, mjTile in ipairs(roomPlayer.holdMjTiles) do
					local hasCard = false
					for _, tingCard in ipairs(msgTbl.kTingCards) do
						if tingCard[1] == mjTile.mjColor and tingCard[2] == mjTile.mjNumber then
							if msgTbl.kFlag == 0 then
								
							else
								hasCard = true
							end
							break
						end
					end

					if hasCard then
						if self.playType == 100004 and self.isBeingTing then
							--如果是立四玩法，且当前听牌了，普通手牌置灰
							if self.playerSeatIdx == seatIdx then
								mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
							else
								mjTile.mjTileSpr:setColor(cc.c3b(130,130,130))
							end
						else
							gt.log("牌置白，可出")
							--dump(mjTile)
							mjTile.mjTileSpr:setColor(cc.WHITE)
						end
					else
						gt.log("牌置灰，不可出 111111")
						--dump(mjTile)
						if self.playerSeatIdx == seatIdx then
							mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
						else
							mjTile.mjTileSpr:setColor(cc.c3b(130,130,130))
						end
					end
				end

				for _, tingCard in ipairs(msgTbl.kTingCards) do
					table.insert(roomPlayer.m_ting, {tingCard[1], tingCard[2]})
				end

				if self.playType == 100004 then
					--如果是立四玩法，需要检测立四手牌哪些可出
					for index, mjTile in ipairs(roomPlayer.lisiMjTiles) do
						local hasCard = false
						for _, tingCard in ipairs(msgTbl.kTingCards) do
							if tingCard[1] == mjTile.mjColor and tingCard[2] == mjTile.mjNumber then
								if msgTbl.kFlag == 0 then
									
								else
									hasCard = true
								end
								break
							end
						end

						if hasCard then
							gt.log("牌置白，可出")
							--dump(mjTile)
							mjTile.mjTileSpr:setColor(cc.WHITE)
						else
							gt.log("牌置灰，不可出 111111")
							--dump(mjTile)
							mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
						end
					end
				end
			else
		 		self.isTing = true
				for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
					gt.log("牌置灰，不可出 222222")
					--dump(mjTile)
					if self.playerSeatIdx == seatIdx then
						mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
					else
						mjTile.mjTileSpr:setColor(cc.c3b(130,130,130))
					end
				end
			end
		end

		if (next(msgTbl.kTingCards) ~= nil) then
			self.tingCards = clone(msgTbl.kTingCards)
			self.tingCards.seatIdx = seatIdx
			self.m_tingCards = msgTbl.kTingCards
		end

		-- 摸牌
		if msgTbl.kFlag == 0 then
        	gt.soundEngine:playEffect("common/pjbutton", false, true)
			-- 添加牌放在末尾
			local mjTilesReferPos = roomPlayer.mjTilesReferPos
			local mjTilePos = mjTilesReferPos.holdStart
			mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, #roomPlayer.holdMjTiles))
			mjTilePos = cc.pAdd(mjTilePos, cc.p(25, 0))

			if self.playType == 100004 then
				--如果是立四玩法，手牌位置要根据当前立四手牌数量来取位置
				-- mjTilePos = cc.pAdd(mjTilePos, cc.p(345, 0))
				local lisiNum = #roomPlayer.lisiMjTiles
				mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, lisiNum))
				mjTilePos = cc.pAdd(mjTilePos, cc.p(25, 0))
			end
			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("通知玩家出牌----摸牌放末尾")
			end
			local mjTile = self:addMjTileToPlayer(msgTbl.kColor, msgTbl.kNumber)
			mjTile.mjTileSpr:setPosition(mjTilePos)
			self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height - mjTilePos.y))
			mjTile.mjTileSpr:setOpacity(0.0)
			local action = cc.FadeIn:create(0.3)
			mjTile.mjTileSpr:runAction(action)

			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("通知玩家出牌----这里是自己添加手牌后的数据")
				gt.dumplog(roomPlayer)
			end
		else
			self:sortPlayerMjTiles(true)
		end
		gt.log("玩家摸牌")
		local decisionTypes = {}
		if msgTbl.kThink then
			gt.log("摸牌类型")
			for _,value in ipairs(msgTbl.kThink) do
				local think_m_type = value[1]
				local think_m_cardList = {}
				think_m_cardList = value[2]
				gt.log("m_type = " .. think_m_type)
				gt.log("m_playType = " .. self.playType)

				if think_m_type == 2 then
					-- 胡
					local decisionData = {}
					decisionData.flag = 2
					decisionData.mjColor = msgTbl.kColor
					decisionData.mjNumber = msgTbl.kNumber
					table.insert(decisionTypes,decisionData)
					gt.log("胡")
				end
				if think_m_type == 3 then
					-- 暗杠
					local decisionData = {}
					decisionData.flag = 3
					decisionData.cardList = {}
					for _,v in ipairs(think_m_cardList) do
						local card = {}
						card.mjColor = v[1]
						card.mjNumber = v[2]
						card.flag = 3
						table.insert(decisionData.cardList,card)
					end
					table.insert(decisionTypes,decisionData)
					gt.log("暗杠")
				end
				if think_m_type == 4 then
					-- 明杠
					self.curTypeIsGang = true

					local decisionData = {}
					decisionData.flag = 4
					decisionData.cardList = {}
					for _,v in ipairs(think_m_cardList) do
						local card = {}
						card.mjColor = v[1]
						card.mjNumber = v[2]
						card.flag = 4
						table.insert(decisionData.cardList,card)
					end
					table.insert(decisionTypes,decisionData)
					gt.log("明杠")
				end
				if think_m_type == 7 then
					-- 听
					gt.log("--------------------------------self.isBeingTing1")
					-- self.isBeingTing = true     --当前处于刚听牌这一手
					gt.log("听牌 111111 isBeingTing="..tostring(self.isBeingTing))
					local decisionData = {}
					decisionData.flag = 7
					decisionData.cardList = {}
					for _,v in ipairs(think_m_cardList) do
						local card = {}
						card.mjColor = v[1]
						card.mjNumber = v[2]
						card.flag = 7
						table.insert(decisionData.cardList,card)
					end
					table.insert(decisionTypes,decisionData)
					gt.log("听")
				end
				if think_m_type == 10 then
					-- 暗杠听
					gt.log("--------------------------------self.isBeingTing2")
					-- self.isBeingTing = true     --当前处于刚听牌这一手
					gt.log("听牌 222222 isBeingTing="..tostring(self.isBeingTing))
					local decisionData = {}
					decisionData.flag = 10
					decisionData.cardList = {}
					for _,v in ipairs(think_m_cardList) do
						local card = {}
						card.mjColor = v[1]
						card.mjNumber = v[2]
						card.flag = 10
						table.insert(decisionData.cardList,card)
					end
					table.insert(decisionTypes,decisionData)
					gt.log("暗杠听")
				end
				if think_m_type == 11 then
					-- 明杠听
					gt.log("--------------------------------self.isBeingTing3")
					-- self.isBeingTing = true     --当前处于刚听牌这一手
					gt.log("听牌 333333 isBeingTing="..tostring(self.isBeingTing))
					local decisionData = {}
					decisionData.flag = 11
					decisionData.cardList = {}
					for _,v in ipairs(think_m_cardList) do
						local card = {}
						card.mjColor = v[1]
						card.mjNumber = v[2]
						card.flag = 11
						table.insert(decisionData.cardList,card)
					end
					table.insert(decisionTypes,decisionData)
					gt.log("明杠听")
				end
			end					
		end
		gt.log("自动出牌1")
		--dump(msgTbl)
		if #msgTbl.kThink == 0 and msgTbl.kNumber ~= 0 then
			if self.m_tingState and msgTbl.kTing == 1 then
				--一次性定时器
				self.autoPlaySchedule = gt.scheduler:scheduleScriptFunc(function(delta)
					gt.scheduler:unscheduleScriptEntry(self.autoPlaySchedule)
					self.autoPlaySchedule = nil

					gt.log("自动出牌")
					self.isAutoOutTile = true
					for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
						if _ ~= #roomPlayer.holdMjTiles then
							if self.playerSeatIdx == seatIdx then
								mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
							else
								mjTile.mjTileSpr:setColor(cc.c3b(130,130,130))
							end
						end
					end				
					self.isPlayerDecision = false
					self.isPlayerShow = false
					self.chooseMjTileIdx = #roomPlayer.holdMjTiles
					self.chooseMjTile = roomPlayer.holdMjTiles[self.chooseMjTileIdx]

					local msgToSend = {}
					msgToSend.kMId = gt.CG_SHOW_MJTILE
					msgToSend.kType = 1
					msgToSend.kThink = {}
					table.insert(msgToSend.kThink, {tonumber(msgTbl.kColor), tonumber(msgTbl.kNumber)})
					gt.socketClient:sendMessage(msgToSend)
					if self.AppVersion and self.AppVersion > 10 then
						gt.dumplog(msgToSend)
						gt.dumplog(self.roomPlayers)
					end
        			gt.soundEngine:playEffect("common/card_drop_down", false, true, "mp3")
					return true	
				end, 0.3, false)
			end	
		end
		
		-- 按钮排列
		if #decisionTypes > 0 then
			-- 自摸类型决策
			self.isPlayerDecision = true

			local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
			gt.log("---------------------------------------自摸类型决策", self.selfDrawnDecisionFlag)
			if self.selfDrawnDecisionFlag and self.selfDrawnDecisionFlag == 1 then
				selfDrawnDcsNode:setVisible(false)
				self.selfDrawnDecisionFlag = 2
			else
				selfDrawnDcsNode:setVisible(true)
			end

			for _, decisionBtn in ipairs(selfDrawnDcsNode:getChildren()) do
				local nodeName = decisionBtn:getName()
				if nodeName == "Btn_decisionPass" then
					-- 过,漏胡提示
					local m_canHu = false
					gt.log("决策按钮是否有胡牌 111 ========")
					--dump(decisionTypes)
					for idx, decisionData in ipairs(decisionTypes) do
						if decisionData.flag == 2 then
							m_canHu = true
						end
					end
					if (self.playType == 100004 or self.playType == 100003) and m_canHu then
						--如果是立四玩法，隐藏过牌按钮
						gt.log("自摸时，如果是立四玩法，隐藏过牌按钮")
						decisionBtn:setVisible(false)
					else
						decisionBtn:setVisible(true)
					end
					-- 设置不存在的索引值
					decisionBtn:setTag(0)
					gt.addBtnPressedListener(decisionBtn, function()
						gt.dumplog("----------------点过1")
						local function passDecision()
							self.isPlayerDecision = false
							self.curTypeIsGang = false
							self.isBeingTing = false
							self.isAutoOutTile = false

							local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
							selfDrawnDcsNode:setVisible(false)
							-- 删除弹出框（杠）
							self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BAR)
							-- 删除弹出框（补）
							self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BU)
							-- 删除弹出框（听）
							self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_TING)
						end
						-- 过,漏胡提示
						local m_canHu = false
						gt.log("决策按钮是否有胡牌 111 ========")
						if self.tingSendMessageFlag == true then
							self:setHoldMjTilesGuo()
						end
						self.tingSendMessageFlag = false
						--dump(decisionTypes)
						for idx, decisionData in ipairs(decisionTypes) do
							if decisionData.flag == 2 then
								m_canHu = true
							end
						end
						if m_canHu == true then
							require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
								gt.getLocationString("LTKey_0043"), passDecision)
						else
							passDecision()
						end
					end)
				else
					decisionBtn:setVisible(false)
				end
			end

			local decisionBtn_pass = gt.seekNodeByName(selfDrawnDcsNode, "Btn_decisionPass")
			local beginPos = cc.p(decisionBtn_pass:getPosition())
			local btnSpace = decisionBtn_pass:getContentSize().width * 3

			local btn_presentList = {}
			for idx, decisionData in ipairs(decisionTypes) do
				local decisionBtn = nil
				if decisionData.flag == 2 then
					-- 胡
					decisionBtn = gt.seekNodeByName(selfDrawnDcsNode, "Btn_decisionWin")
					local mjTileSpr = gt.seekNodeByName(decisionBtn, "Spr_mjTile")
					if mjTileSpr then
						if decisionData.mjColor==0 and decisionData.mjNumber==0 then
							mjTileSpr:setVisible( false )
						else
							-- mjTileSpr:setSpriteFrame(string.format("p4s%d_%d.png", decisionData.mjColor, decisionData.mjNumber))
							mjTileSpr:removeAllChildren()
							mjTileSpr:setSpriteFrame(Utils.getMJTileResName(4, decisionData.mjColor, decisionData.mjNumber,self.isHZLZ))

							gt.log("----------------------self.HaoZiCards")
							gt.log("----------------------decisionData.mjColor", decisionData.mjColor)
							gt.log("----------------------decisionData.mjNumber", decisionData.mjNumber)
							gt.dump(self.HaoZiCards)
							-- 添加耗子牌标识
							if self.HaoZiCards then
								for i,card in ipairs(self.HaoZiCards) do
									if decisionData.mjColor == card._color and decisionData.mjNumber == card._number then
							gt.log("----------------------self:addMouseMark(mjTileSpr, true)")
										self:addMouseMark(mjTileSpr, true)	
									end		
								end
							end
						end
					end
					-- 胡的显示优先级为1
					table.insert(btn_presentList,{2,decisionBtn})
				elseif decisionData.flag == 3 or decisionData.flag == 4 then
					gt.log("--------------------gang1")
					-- 明暗杠
					local btn_bar_name = "Btn_decisionBar"
					decisionBtn = gt.seekNodeByName(selfDrawnDcsNode, btn_bar_name)
					local isExistBarBtn = false
					for _,v in ipairs(btn_presentList) do
					gt.log("--------------------gang2")
						-- 杠的显示优先级为3
						if v[1] == 3 then
					gt.log("--------------------gang3")
							isExistBarBtn = true
							break
						end
					end
					if not isExistBarBtn then
					gt.log("--------------------gang4")
						table.insert(btn_presentList,{3,decisionBtn})
					end
					-- 显示杠胡牌
					local mjTileSpr = gt.seekNodeByName(decisionBtn, "Spr_mjTile")
					if mjTileSpr then
					gt.log("--------------------gang5")
						if #decisionData.cardList == 1 then
							mjTileSpr:setSpriteFrame(Utils.getMJTileResName(4, decisionData.cardList[1].mjColor, decisionData.cardList[1].mjNumber,self.isHZLZ))
							mjTileSpr:setVisible(true)
						else
							mjTileSpr:setVisible(false)
						end
					end
				elseif decisionData.flag == 7 or decisionData.flag == 10 or decisionData.flag == 11 then
					-- 听牌
					local btn_bar_name = nil
					if decisionData.flag == 10 or decisionData.flag == 11 then
						btn_bar_name = "Btn_decisionBarTing"
					else
						btn_bar_name = "Btn_decisionTing"
					end
					decisionBtn = gt.seekNodeByName(selfDrawnDcsNode, btn_bar_name)
					table.insert(btn_presentList,{1,decisionBtn})
					local mjTileSpr = gt.seekNodeByName(decisionBtn, "Spr_mjTile")
					if mjTileSpr then
						if #decisionData.cardList == 1 then
							mjTileSpr:setSpriteFrame(Utils.getMJTileResName(4, decisionData.cardList[1].mjColor, decisionData.cardList[1].mjNumber,self.isHZLZ))
							mjTileSpr:setVisible(true)
						else
							mjTileSpr:setVisible(false)
						end
					end
				end

				decisionBtn:setVisible(true)
				decisionBtn:setTag(idx)

				-- 可杠
				if decisionData.flag == 3 or decisionData.flag == 4 or decisionData.flag == 10 or decisionData.flag == 11 then
					gt.log("--------------------gang6")
					if #decisionData.cardList == 1 then
					gt.log("--------------------gang7")
						gt.addBtnPressedListener(decisionBtn, function(sender)
							self.isPlayerDecision = false

							local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
							selfDrawnDcsNode:setVisible(false)

							-- 删除弹出框（杠）
							self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BAR)
							-- 删除弹出框（补）
							self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BU)
							-- 删除弹出框（听）
							self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_TING)
							-- 发送消息
							local btnTag = sender:getTag()
							local decisionData = decisionTypes[sender:getTag()]
							local msgToSend = {}
							msgToSend.kMId = gt.CG_SHOW_MJTILE
							msgToSend.kType = decisionData.flag
							msgToSend.kThink = {}
							local think_temp = {decisionData.cardList[1].mjColor,decisionData.cardList[1].mjNumber}
							table.insert(msgToSend.kThink,think_temp)
							gt.socketClient:sendMessage(msgToSend)
							if self.AppVersion and self.AppVersion > 10 then
								gt.dumplog(msgToSend)
								gt.dumplog(self.roomPlayers)
							end
							-- if decisionData.flag == 7 or decisionData.flag == 10 or decisionData.flag == 11 then
							--     --查看胡牌按钮
							-- 	local tinghuBtn = gt.seekNodeByName(self.rootNode, "Btn_tinghu")
							-- 	tinghuBtn:setVisible(true)
							-- end
						end)
					else
						gt.addBtnPressedListener(decisionBtn, function(sender)
							self.isPlayerDecision = false
							local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
							selfDrawnDcsNode:setVisible(false)							
							-- 删除弹出框（杠）
							self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BAR)
							-- 删除弹出框（补）
							self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BU)
							-- 删除弹出框（听）
							self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_TING)
							-- add new
							local flimLayer = nil
							if decisionData.flag == 3 or decisionData.flag == 4 or decisionData.flag == 10 or decisionData.flag == 11 then
								flimLayer = self:createFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BAR,decisionData.cardList)
								self:addChild(flimLayer,MJScene.ZOrder.FLIMLAYER,MJScene.TAG.FLIMLAYER_BAR)

								flimLayer:setIgnoreAnchorPointForPosition(false)
								flimLayer:setAnchorPoint(0.5,0)
								local pos_x = 0
								if decisionBtn:getPositionX()+flimLayer:getContentSize().width/2 > gt.winSize.width then
									flimLayer:setPositionX(gt.winSize.width-flimLayer:getContentSize().width/2)
								elseif decisionBtn:getPositionX()-flimLayer:getContentSize().width/2 < 0 then
									flimLayer:setPositionX(flimLayer:getContentSize().width/2)
								else

								flimLayer:setPositionX(decisionBtn:getPositionX())
								end
								flimLayer:setPositionY(decisionBtn:getPositionY()+flimLayer:getContentSize().height/2)
							end
						end)
					end
				elseif decisionData.flag == 7 then
					gt.addBtnPressedListener(decisionBtn, function(sender)
						local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
						selfDrawnDcsNode:setVisible(true)

						local decisionBarTingBtn = gt.seekNodeByName(self.rootNode, "Btn_decisionBarTing")
						decisionBarTingBtn:setVisible(false)
						
						local decisionTingBtn = gt.seekNodeByName(self.rootNode, "Btn_decisionTing")
						decisionTingBtn:setVisible(false)
						
						local decisionBarBtn = gt.seekNodeByName(self.rootNode, "Btn_decisionBar")
						decisionBarBtn:setVisible(false)
						
						local decisionWinBtn = gt.seekNodeByName(self.rootNode, "Btn_decisionWin")
						decisionWinBtn:setVisible(false)
						
						local decisionPassBtn = gt.seekNodeByName(self.rootNode, "Btn_decisionPass")
						decisionPassBtn:setVisible(true)
						decisionPassBtn:setPositionX(1050)

						self.isPlayerDecision = false

						self.tingSendMessageFlag = true

						self:setHoldMjTilesTing()
					end)
				else
					gt.log("--------------------gang8")
					gt.addBtnPressedListener(decisionBtn, function(sender)
						self.isPlayerDecision = false
						self.isPlayerShow = false

						local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
						selfDrawnDcsNode:setVisible(false)

						-- 删除弹出框（杠）
						self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BAR)
						-- 删除弹出框（补）
						self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BU)
						-- 删除弹出框（听）
						self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_TING)

						-- 发送消息
						local btnTag = sender:getTag()
						local decisionData = decisionTypes[sender:getTag()]
						local msgToSend = {}
						msgToSend.kMId = gt.CG_SHOW_MJTILE
						msgToSend.kType = decisionData.flag
						gt.log("发送决策消息 111111 === "..decisionData.flag)
						msgToSend.kThink = {}
						local think_temp = {decisionData.mjColor,decisionData.mjNumber}
						if decisionData.mjColor~=0 or decisionData.mjNumber~=0 then
							table.insert(msgToSend.kThink,think_temp)
						end
						gt.socketClient:sendMessage(msgToSend)
						if self.AppVersion and self.AppVersion > 10 then
							gt.dumplog(msgToSend)
							gt.dumplog(self.roomPlayers)
						end
					end)
				end
			end

					gt.log("--------------------gang9")
			local decisionBtn = gt.seekNodeByName(self.rootNode, "Btn_decisionPass")
			table.insert(btn_presentList,{4,decisionBtn})
			-- 根据显示优先级进行排序
			table.sort(btn_presentList, function(a, b)
				return a[1] < b[1]
			end)
			-- 根据排序好的优先级进行显示按钮
			local beginPos = {x = 385, y = 215}
			local btnSpace = 190
			for _,v in ipairs(btn_presentList) do
					gt.log("--------------------gang10", v[1])
				beginPos = cc.p(beginPos.x + btnSpace , beginPos.y)
				v[2]:setPosition(beginPos)
			end
		else
			if self.selfDrawnDecisionFlag and self.selfDrawnDecisionFlag == 1 then
				self.selfDrawnDecisionFlag = 3
			end
		end
	else
		-- 摸牌
		if self.AppVersion and self.AppVersion > 10 then
			gt.dumplog("通知玩家出牌----其他玩家出牌")
		end
		if msgTbl.kFlag == 0 then
			local mjTilesReferPos = roomPlayer.mjTilesReferPos
			local mjTilePos = mjTilesReferPos.holdStart
			mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, roomPlayer.mjTilesRemainCount))
			roomPlayer.mjTilesRemainCount = roomPlayer.mjTilesRemainCount + 1
			local vv = roomPlayer.holdMjTiles[roomPlayer.mjTilesRemainCount].mjTileSpr
			if vv then
				vv:setVisible(true)
				local dn = self.playerSeatIdx-seatIdx
				if dn == 2 or dn == -2 then
					vv:setPosition( cc.pAdd(mjTilePos,cc.p(-15,0)) )
				elseif dn == -1 or dn == 3 then
					vv:setPosition( cc.pAdd(mjTilePos,cc.p(-5,25)) )
				elseif dn == 1 or dn == -3 then
					vv:setPosition( cc.pAdd(mjTilePos,cc.p(-5,-15)) )
				end
			end
		end
		if self.selfDrawnDecisionFlag and self.selfDrawnDecisionFlag == 1 then
			self.selfDrawnDecisionFlag = 3
		end
		if self.AppVersion and self.AppVersion > 10 then
			gt.dumplog("通知玩家出牌----这里是其他玩家添加手牌后的数据")
			gt.dumplog(roomPlayer)
		end
	end
end

-- start --
--------------------------------
-- @class function
-- @description 广播玩家出牌
-- end --
function MJScene:onRcvSyncShowMjTile(msgTbl)
	gt.log("广播玩家出牌消息" .. msgTbl.kType .. " Seat" .. msgTbl.kPos .. " playerSeat" .. self.playerSeatIdx)
	--dump(msgTbl)
	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
		gt.dumplog(self.roomPlayers)
	end

	if msgTbl.kPos < 0 or msgTbl.kPos > 3 then
        return
	end

	if self.roomPlayers[msgTbl.kPos + 1] and self.roomPlayers[msgTbl.kPos + 1].displaySeatIdx then
		self.curShowSeatIdx = self.roomPlayers[msgTbl.kPos + 1].displaySeatIdx
	end

	self.curTypeIsGang = false
	-- do return end

	if msgTbl.kErrorCode ~= 0 then
		gt.socketClient:reloginServer()
		return
	end

	--隐藏胡牌提示
	self:hideHuCards()

	-- 座位号（1，2，3，4）
	local seatIdx = msgTbl.kPos + 1
	local roomPlayer = self.roomPlayers[seatIdx]

	if roomPlayer == nil then
		return
	end
	if msgTbl.kType == 2 then
		-- 自摸胡
		self:showAllMjTilesWhenWin(seatIdx, msgTbl.kCardCount, msgTbl.kCardValue, msgTbl.kColor, msgTbl.kNumber)
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.SELF_DRAWN_WIN, msgTbl.kHu)
	elseif msgTbl.kType == 1 then
		-- 显示出的牌
		if self.startMjTileAnimation ~= nil then
			self.startMjTileAnimation:stopAllActions()
			self.startMjTileAnimation:removeFromParent()
			self.startMjTileAnimation = nil
		end

		local mjTilesReferPos = roomPlayer.mjTilesReferPos
		-- if mjTilesReferPos == nil then
		-- 	gt.log("--------gt.socketClient:reloginServer1")
		-- 	gt.socketClient:reloginServer()			
		-- end

		local mjTilePos = mjTilesReferPos.holdStart
		local realpos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, roomPlayer.mjTilesRemainCount))
		local isNeedKouPai = false      --是否需要倒扣牌
		if msgTbl.kFlag ~= nil and msgTbl.kFlag == 5 and self.playType ~= 100009 and self.playType ~= 102009 and self.playType ~= 103009 then
			--需要扣牌
			isNeedKouPai = true
		end
		if seatIdx ~= self.playerSeatIdx then
			--其他人出的牌
			if (next(msgTbl.kThink) ~= nil) then
					if self.AppVersion and self.AppVersion > 10 then
						gt.dumplog("广播玩家出牌--这里是其他玩家出牌的消息----1")
					end
					self.isBeingTing = false
					local  mj_color = msgTbl.kThink[1][1]
					local  mj_number = msgTbl.kThink[1][2]
					-- 显示出的牌
					self:addAlreadyOutMjTiles(seatIdx, mj_color, mj_number, false, isNeedKouPai)
					-- 显示出的牌箭头标识
					self:showOutMjtileSign(seatIdx)

        			gt.soundEngine:playEffect("common/card_drop_down", false, true, "mp3")
					self:showMjTileAnimation(seatIdx, realpos, mj_color, mj_number,function()
					end, isNeedKouPai)
					if self.AppVersion and self.AppVersion > 10 then
						gt.dumplog("广播玩家出牌--这里是其他玩家出牌的消息----2")
						gt.dumplog(roomPlayer)
					end
			end
		else
			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("广播玩家出牌--这里是自己出牌的消息----1")
			end
			--自己出的牌
			if (next(msgTbl.kThink) ~= nil) then
				local  mj_color = msgTbl.kThink[1][1]
				local  mj_number = msgTbl.kThink[1][2]
				if self.chooseMjTile == nil or self.isTrusteeship then
					-- 显示出的牌
					self:addAlreadyOutMjTiles(seatIdx, mj_color, mj_number, false, isNeedKouPai)
					-- 显示出的牌箭头标识
					self:showOutMjtileSign(seatIdx)
					if self.isTrusteeship then
						-- 隐藏决策
						local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
						selfDrawnDcsNode:setVisible(false)
						self.isPlayerShow = false
					end
				else
					-- 前端主动出牌时，打完牌就操作了，不需要等应答消息，只有在自动出牌时才显示出的牌
					if self.isAutoOutTile then
						self:addAlreadyOutMjTiles(seatIdx, mj_color, mj_number, nil, isNeedKouPai)
						-- 显示出的牌箭头标识
						self:showOutMjtileSign(seatIdx)
						
						-- self:showMjTileAnimation(seatIdx, cc.p(self.chooseMjTile.mjTileSpr:getPositionX(),self.chooseMjTile.mjTileSpr:getPositionY()), mj_color, mj_number,function()
						-- end, isNeedKouPai)
					end
				end
				if self.AppVersion and self.AppVersion > 10 then
					gt.dumplog("广播玩家出牌--这里是自己出牌的消息----2")
					gt.dumplog(roomPlayer)
				end
			end
		end

		if seatIdx == self.playerSeatIdx then
			-- 前端主动出牌时，打完牌就操作了，不需要等应答消息，只有在自动出牌时才持有牌中去除打出去的牌
			if next(msgTbl.kThink) ~= nil and self.isAutoOutTile then
				local  mj_color = msgTbl.kThink[1][1]
				local  mj_number = msgTbl.kThink[1][2]				
				if self.playType == 100004 and self.isBeingTing then 
					--如果是立四玩法，且当前是听牌这一手，则移除立四手牌中的已出牌
					gt.log("如果是立四玩法，且当前是听牌这一手，则移除立四手牌中的已出牌")
					local isLisiRemove = false
					for i = #roomPlayer.lisiMjTiles, 1, -1 do
						local mjTile = roomPlayer.lisiMjTiles[i]
						if mjTile.mjColor == mj_color and mjTile.mjNumber == mj_number then
							mjTile.mjTileSpr:removeFromParent()
							table.remove(roomPlayer.lisiMjTiles, i)
							isLisiRemove = true
							break
						end
					end
					if not isLisiRemove then
						local mjTile = roomPlayer.lisiMjTiles[self.chooseMjTileIdx]
						if mjTile and mjTile.mjTileSpr then
							mjTile.mjTileSpr:removeFromParent()
							table.remove(roomPlayer.lisiMjTiles, self.chooseMjTileIdx)
						end
					end
				else
					--如果不是立四，或者是立四而未听牌，移除普通手牌
					gt.log("如果不是立四，或者是立四而未听牌，移除普通手牌")
					local isRemove = false
					if self.playMjLayer:getChildByName("holdMjNode") then
						self.holdMjNode:removeAllChildren()
					end
					for i = #roomPlayer.holdMjTiles, 1, -1 do
						local mjTile = roomPlayer.holdMjTiles[i]
						if mjTile.mjColor == mj_color and mjTile.mjNumber == mj_number then
							-- mjTile.mjTileSpr:removeFromParent()
							table.remove(roomPlayer.holdMjTiles, i)
							isRemove = true
							break
						end
					end
					for i = #roomPlayer.holdMjTiles, 1, -1 do
						local mjTile = roomPlayer.holdMjTiles[i]
						if mjTile.mjTileSpr then
							self:updateMjTileToPlayer(mjTile.mjTileSpr)
						end
					end
					if not isRemove then
						if self.playMjLayer:getChildByName("holdMjNode") then
							self.holdMjNode:removeAllChildren()
						end
						local mjTile = roomPlayer.holdMjTiles[self.chooseMjTileIdx]
						if mjTile and mjTile.mjTileSpr then
							gt.log("从手牌中移除打出去的牌 ======== ")
							--dump(mjTile)
							-- mjTile.mjTileSpr:removeFromParent()
							table.remove(roomPlayer.holdMjTiles, self.chooseMjTileIdx)
						end
						for i = #roomPlayer.holdMjTiles, 1, -1 do
							local mjTile = roomPlayer.holdMjTiles[i]
							if mjTile.mjTileSpr then
								self:updateMjTileToPlayer(mjTile.mjTileSpr)
							end
						end
					end
				end
				gt.soundManager:PlayCardSound(roomPlayer.sex, mj_color, mj_number)
			end
			-- if not isNeedKouPai then
			-- gt.soundManager:PlayCardSound(roomPlayer.sex, mj_color, mj_number)
			-- end
			self:showLisiMjTile()
			self:sortPlayerMjTiles()
		else
			if roomPlayer.mjTilesRemainCount ~= nil
				and roomPlayer.holdMjTiles[roomPlayer.mjTilesRemainCount] ~= nil
				and roomPlayer.holdMjTiles[roomPlayer.mjTilesRemainCount].mjTileSpr then
					gt.log("---------------roomPlayer.mjTilesRemainCount", roomPlayer.mjTilesRemainCount)
				roomPlayer.holdMjTiles[roomPlayer.mjTilesRemainCount].mjTileSpr:setVisible(false)
				roomPlayer.mjTilesRemainCount = roomPlayer.mjTilesRemainCount - 1
				if (next(msgTbl.kThink) ~= nil) then
					local  mj_color = msgTbl.kThink[1][1]
					local  mj_number = msgTbl.kThink[1][2]
					-- dj revise
					gt.log("播放出牌声音 bbbbbb")
					if not isNeedKouPai then
						gt.soundManager:PlayCardSound(roomPlayer.sex, mj_color, mj_number)
					end
				end
			end
		end

		-- 记录出牌的上家
		self.preShowSeatIdx = seatIdx

		
	elseif msgTbl.kType == 3 then
		-- 暗杠
		gt.log("     暗杠     ")
		if (next(msgTbl.kThink) ~= nil) then
			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("广播玩家出牌--这里是暗杠牌的消息----1")
			end
			local  mj_color = msgTbl.kThink[1][1]
			local  mj_number = msgTbl.kThink[1][2]
			self:addMjTileBar(seatIdx, mj_color, mj_number, false)
			self:hideOtherPlayerMjTiles(seatIdx, true, false)
			self:showDecisionAnimation(seatIdx, MJScene.DecisionType.DARK_BAR)

			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("广播玩家出牌--这里是暗杠牌的消息----2")
				gt.dumplog(roomPlayer)
			end
		end
	elseif msgTbl.kType == 4 then
		-- 碰转明杠
		gt.log("     明杠     ")
		if (next(msgTbl.kThink) ~= nil) then
			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("广播玩家出牌--这里是明杠牌的消息----1")
			end
			local  mj_color = msgTbl.kThink[1][1]
			local  mj_number = msgTbl.kThink[1][2]
			self:changePungToBrightBar(seatIdx, mj_color, mj_number)
			self:showDecisionAnimation(seatIdx, MJScene.DecisionType.BRIGHT_BAR)

			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("广播玩家出牌--这里是明杠牌的消息----2")
				gt.dumplog(roomPlayer)
			end
		end
	elseif msgTbl.kType == 7 then
		-- 暗补
		gt.log("     听     ")
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.TING)
		if self.AppVersion and self.AppVersion > 10 then
			gt.dumplog("广播玩家出牌--这里是听牌的消息")
			gt.dumplog(roomPlayer)
		end
	elseif msgTbl.kType == 10 then
		-- 暗杠
		gt.log("     暗杠听     ")
		if (next(msgTbl.kThink) ~= nil) then
			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("广播玩家出牌--这里是暗杠听牌的消息----1")
			end
			local  mj_color = msgTbl.kThink[1][1]
			local  mj_number = msgTbl.kThink[1][2]
			self:addMjTileBar(seatIdx, mj_color, mj_number, false)
			self:hideOtherPlayerMjTiles(seatIdx, true, false)
			self:showDecisionAnimation(seatIdx, MJScene.DecisionType.TING)
			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("广播玩家出牌--这里是暗杠听牌的消息----2")
				gt.dumplog(roomPlayer)
			end
		end
	elseif msgTbl.kType == 11 then
		-- 碰转明杠
		
		if (next(msgTbl.kThink) ~= nil) then
			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("广播玩家出牌--这里是碰转明杠牌的消息----1")
			end
			local  mj_color = msgTbl.kThink[1][1]
			local  mj_number = msgTbl.kThink[1][2]
			self:changePungToBrightBar(seatIdx, mj_color, mj_number)
			self:showDecisionAnimation(seatIdx, MJScene.DecisionType.TING)
			if self.AppVersion and self.AppVersion > 10 then
				gt.dumplog("广播玩家出牌--这里是碰转明杠牌的消息----2")
				gt.dumplog(roomPlayer)
			end
		end
	end
	if msgTbl.kType == 7 or msgTbl.kType == 10 or msgTbl.kType == 11 or msgTbl.kType == 12 then
		-- 听标识
		-- local setPos = self:getDisplaySeat(seatIdx)
		local roomPlayer = self.roomPlayers[seatIdx]
		local setPos = roomPlayer.displaySeatIdx
		for i=1,4 do
			local nodePlayerInfo = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. i)
			local spr_ting = gt.seekNodeByName(nodePlayerInfo, "spr_ting")
			if setPos == i then
				spr_ting:setVisible(true)
			end
		end
		for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
			if _ ~= #roomPlayer.holdMjTiles then
				if self.playerSeatIdx == seatIdx then
					mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
				else
					mjTile.mjTileSpr:setColor(cc.c3b(130,130,130))
				end
			end
		end
	end

	if seatIdx == self.playerSeatIdx then
		if self.AppVersion and self.AppVersion > 10 then
		    gt.dumplog("自己出牌时 牌的信息")
			gt.dumplog(roomPlayer)
		end
   	end

	if seatIdx ~= self.playerSeatIdx then
		if self.AppVersion and self.AppVersion > 10 then
		    gt.dumplog("其他玩家出的牌")
			gt.dumplog(roomPlayer.outMjTiles)
		end
   	end
end

-- start --
--------------------------------
-- @class function
-- @description 服务器广播玩家起手胡牌
-- end --
function MJScene:onRcvSyncStartDecision(msgTbl)
	gt.log("广播玩家起手胡牌消息 =================")
	--dump(msgTbl)

	local seatIdx = msgTbl.kPos + 1
	if msgTbl.kType == 1 then
		-- 缺一色
		self:showStartDecisionAnimation(seatIdx, MJScene.StartDecisionType.TYPE_QUEYISE, msgTbl.kCard)
	elseif msgTbl.kType == 2 then
		-- 板板胡
		self:showStartDecisionAnimation(seatIdx, MJScene.StartDecisionType.TYPE_BANBANHU, msgTbl.kCard)
	elseif msgTbl.kType == 3 then
		-- 大四喜
		self:showStartDecisionAnimation(seatIdx, MJScene.StartDecisionType.TYPE_DASIXI, msgTbl.kCard)
	elseif msgTbl.kType == 4 then
		-- 六六顺
		self:showStartDecisionAnimation(seatIdx, MJScene.StartDecisionType.TYPE_LIULIUSHUN, msgTbl.kCard)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 广播玩家杠2张牌
-- end --
function MJScene:onRcvSyncBarTwoCard(msgTbl)
	gt.log("收到玩家杠2张牌消息 ================ ")
	--dump(msgTbl)

	local seatIdx = msgTbl.kPos + 1
	-- 是否自摸（0:没有 1：自摸）
	local flag = msgTbl.kFlag
	-- 如果胡了则不需要展示
	if flag == 1 then
		return
	end
	-- 显示杠后两张牌
	self:showBarTwoCardAnimation(seatIdx,msgTbl.kCard)
end

-- start --
--------------------------------
-- @class function
-- @description 展示杠两张牌
-- end --
function MJScene:showBarTwoCardAnimation(seatIdx,cardList)
	local roomPlayer = self.roomPlayers[seatIdx]

	-- local mjTileName = string.format("p4s%d_%d.png", 2, 2)
	local mjTileName = Utils.getMJTileResName(4, 2, 2,self.isHZLZ)
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	local width_oneMJ = mjTileSpr:getContentSize().width
	local width = 30+mjTileSpr:getContentSize().width*(#cardList)
	local height = 24+mjTileSpr:getContentSize().height
	-- 添加半透明底
	local image_bg = ccui.ImageView:create()
	image_bg:loadTexture("images/otherImages/laoyue_bg.png")
	image_bg:setScale9Enabled(true)
	image_bg:setCapInsets(cc.rect(10,10,1,1))
	image_bg:setContentSize(cc.size(width,height))
	image_bg:setAnchorPoint(cc.p(0.5,0.5))
	self.rootNode:addChild(image_bg,MJScene.ZOrder.HAIDILAOYUE)
	image_bg:setScale(0)

	local curPos = self:getHuPosition(roomPlayer.displaySeatIdx)
	image_bg:setPosition(curPos)

	-- 添加两个麻将
	for _,v in pairs(cardList) do
		-- local mjSprName = string.format("p4s%d_%d.png", v[1], v[2])
		local mjSprName = Utils.getMJTileResName(4, v[1], v[2], self.isHZLZ)
		local image_mj = ccui.Button:create()
		image_mj:loadTextures(mjSprName,mjSprName,"",ccui.TextureResType.plistType)
    	image_mj:setAnchorPoint(cc.p(0,0))
    	image_mj:setPosition(cc.p(15+width_oneMJ*(_-1), 10))
   		image_bg:addChild(image_mj)
	end

	for idx, data in pairs(cardList) do
		self:discardsOneCard(seatIdx, data[1], data[2])
	end

	-- 播放动画
	local scaleToAction = cc.ScaleTo:create(0.2, 1)
	local easeBackAction = cc.EaseBackOut:create(scaleToAction)
	local present_delayTime = cc.DelayTime:create(1.5)
	local fadeOutAction = cc.FadeOut:create(0.5)
	local callFunc_dontPresent = cc.CallFunc:create(function(sender)
		-- 播放完后隐藏
		sender:setVisible(false)
	end)
	local callFunc_present_first = cc.CallFunc:create(function(sender)
		-- 打出第一张牌
		gt.log("打出第一张牌")
		for idx,data in pairs(cardList) do
			if 1 == idx then
   				-- self:discardsOneCard(seatIdx,data[1], data[2])
   				break
   			end
		end
	end)
	local delayTime_f_s = cc.DelayTime:create(0.7)
	local callFunc_present_second = cc.CallFunc:create(function(sender)
		-- 打出第二张牌
		gt.log("打出第二张牌")
		for idx,data in pairs(cardList) do
			if 2 == idx then
   				-- self:discardsOneCard(seatIdx,data[1], data[2])
   				break
   			end
		end
	end)
	local callFunc_remove = cc.CallFunc:create(function(sender)
		-- 播放完后移除
		sender:removeFromParent()
	end)
	local seqAction = cc.Sequence:create(easeBackAction, present_delayTime, fadeOutAction, callFunc_dontPresent,
		callFunc_present_first, delayTime_f_s, callFunc_present_second,callFunc_remove)
	image_bg:runAction(seqAction)

end

function MJScene:discardsOneCard(seatIdx,mjColor,mjNumber)
	gt.log("播放出牌声音 aaaaaa")
	local roomPlayer = self.roomPlayers[seatIdx]
	
	-- local mjTilesReferPos = roomPlayer.mjTilesReferPos
	-- local mjTilePos = mjTilesReferPos.holdStart
	-- local realpos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, roomPlayer.mjTilesRemainCount))
	-- 显示出的牌
	self:addAlreadyOutMjTiles(seatIdx, mjColor, mjNumber)
	-- 显示出的牌箭头标识
	self:showOutMjtileSign(seatIdx)

	-- 记录出牌的上家
	self.preShowSeatIdx = seatIdx

	-- dj revise
	gt.soundManager:PlayCardSound(roomPlayer.sex, mjColor, mjNumber)
end

-- start --
--------------------------------
-- @class function
-- @description 显示玩家开局胡牌动画,比如 1-缺一色 2-板板胡 3-大四喜 4-六六顺
-- @param seatIdx 座位索引
-- @param decisionType 决策类型
-- end --
function MJScene:showStartDecisionAnimation(seatIdx, decisionType, showCard)
	-- 接炮胡，自摸胡，明杠，暗杠，碰文件后缀
	local decisionSuffixs = {1, 4, 2, 2, 3}
	local decisionSfx = {"queyise", "banbanhu", "sixi", "liuliushun"}
	-- 显示决策标识
	local roomPlayer = self.roomPlayers[seatIdx]
	local decisionSignSpr = cc.Sprite:createWithSpriteFrameName(string.format("tile_cs_%s.png", decisionSfx[decisionType]))
	decisionSignSpr:setPosition(roomPlayer.mjTilesReferPos.showMjTilePos)
	self.rootNode:addChild(decisionSignSpr, MJScene.ZOrder.DECISION_SHOW)
	-- 标识显示动画
	decisionSignSpr:setScale(0)
	local scaleToAction = cc.ScaleTo:create(0.2, 1)
	local easeBackAction = cc.EaseBackOut:create(scaleToAction)
	local fadeOutAction = cc.FadeOut:create(0.5)
	local callFunc = cc.CallFunc:create(function(sender)
		-- 播放完后移除
		sender:removeFromParent()
	end)
	local seqAction = cc.Sequence:create(easeBackAction, fadeOutAction, callFunc)
	decisionSignSpr:runAction(seqAction)

	-- 展示起手胡牌型
	local copyNum = 1
	if decisionType == MJScene.StartDecisionType.TYPE_QUEYISE then
		copyNum = 1
	elseif decisionType == MJScene.StartDecisionType.TYPE_BANBANHU then
		copyNum = 1
	elseif decisionType == MJScene.StartDecisionType.TYPE_DASIXI then
		copyNum = 4
	elseif decisionType == MJScene.StartDecisionType.TYPE_LIULIUSHUN then
		copyNum = 3
	end

	local groupNode = cc.Node:create()
	groupNode:setCascadeOpacityEnabled( true )
	groupNode:setPosition( roomPlayer.mjTilesReferPos.showMjTilePos )
	self.playMjLayer:addChild(groupNode)

	local mjTilesReferPos = roomPlayer.mjTilesReferPos

	-- --dump( showCard )
	-- local demoSpr = cc.Sprite:createWithSpriteFrameName( string.format("p%ds%d_%d.png", roomPlayer.displaySeatIdx, 1, 1) )
	local demoSpr = cc.Sprite:createWithSpriteFrameName( Utils.getMJTileResName(roomPlayer.displaySeatIdx, 1, 1, self.isHZLZ) )
	local tileWidthX = 0
	local tileWidthY = 0
	if roomPlayer.displaySeatIdx == 1 then
		tileWidthX = 0
		tileWidthY = mjTilesReferPos.outSpaceH.y--demoSpr:getContentSize().height
	elseif roomPlayer.displaySeatIdx == 2 then
		tileWidthX = -demoSpr:getContentSize().width
		tileWidthY = 0
	elseif roomPlayer.displaySeatIdx == 3 then
		tileWidthX = 0
		tileWidthY = -mjTilesReferPos.outSpaceH.y--demoSpr:getContentSize().height
	elseif roomPlayer.displaySeatIdx == 4 then
		tileWidthX = demoSpr:getContentSize().width
		tileWidthY = 0
	end

	-- 服务器返回消息
	local totalWidthX = (#showCard)*tileWidthX
	local totalWidthY = (#showCard)*tileWidthY
	for i,v in ipairs(showCard) do
		-- local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displaySeatIdx, v[1], v[2])
		local mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, v[1], v[2], self.isHZLZ)
		local mjTileSpr = cc.Sprite:createWithSpriteFrameName( mjTileName )
		mjTileSpr:setPosition( cc.p(tileWidthX*(i-1),tileWidthY*(i-1)) )
		groupNode:addChild( mjTileSpr, (gt.winSize.height - mjTileSpr:getPositionY()) )
	end
	groupNode:setPosition( cc.pAdd( roomPlayer.mjTilesReferPos.showMjTilePos, cc.p(-totalWidthX/2,-totalWidthY/2) ) )

	-- 显示3s,渐隐消失
	local delayTime = cc.DelayTime:create(3)
	local fadeOutAction = cc.FadeOut:create(2)
	local callFunc = cc.CallFunc:create(function(sender)
		sender:removeFromParent()
	end)
	groupNode:runAction(cc.Sequence:create(delayTime, fadeOutAction, callFunc))

	-- dj revise
	gt.log("播放打牌声音 222222")
	gt.soundManager:PlaySpeakSound(roomPlayer.sex, decisionSfx[decisionType])
end

-- start --
--------------------------------
-- @class function
-- @description 游戏开始玩家起始胡牌决策(计算积分而已),发牌前执行
-- end --
function MJScene:onRcvStartDecision(msgTbl)
	gt.log("起手决策和耗子牌消息 ===========")
	--dump(msgTbl)
	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
		gt.dumplog(self.roomPlayers)
	end

	local seatIdx = msgTbl.kPos + 1
	local roomPlayer = self.roomPlayers[seatIdx]

	local Node_dabao = gt.seekNodeByName(self.rootNode, "Node_dabao")
	local Image_logo = gt.seekNodeByName(self.rootNode, "Image_logo")
	
	self.HaoZiCards = nil
	if #msgTbl.kHaoZiCards > 0 then
		gt.log("打宝显示的宝牌", #msgTbl.kHaoZiCards)
		--dump(msgTbl)
		--2017-3-3 shenyongzhen
		if self.HaoZiCards then
			self.HaoZiCards = nil
		end
		if msgTbl.kType == 1 then -- 打宝
			--显示耗子牌
			-- Node_dabao:setVisible(true)
			-- Spr_mjTile:setVisible(true)
			-- cc.SpriteFrameCache:getInstance():addSpriteFrames("images/create_room_new.plist")
			
			-- local color = msgTbl.m_HaoZiCards[#msgTbl.m_HaoZiCards][1]
			-- local number = msgTbl.m_HaoZiCards[#msgTbl.m_HaoZiCards][2]
			-- local mjTileName = Utils.getMJTileResName(4, color, number, self.isHZLZ)
			-- Spr_mjTile:initWithSpriteFrameName(mjTileName)
			-- --2017-3-3 shenyongzhen
			-- if not self.HaoZiCards then
			-- 	self.HaoZiCards = {_color = color,_number = number}	
			-- 	gt.log("耗子牌222")
			-- 	--dump(self.HaoZiCards)
			-- end
			-- self:sortPlayerMjTiles()
			if not self.HaoZiCards then
				self.HaoZiCards = {}
			end
			-- 如果是扣点点玩法，带耗子牌
			Node_dabao:setVisible(true)
			Image_logo:setVisible(false)
			local Spr_mjTileList = self:haoziListInCardTable(Node_dabao,2)
			gt.log("你猜")
			--dump(Spr_mjTileList)
			cc.SpriteFrameCache:getInstance():addSpriteFrames("images/create_room_new.plist")
			for k,v in ipairs(msgTbl.kHaoZiCards) do
				local color = v[1]
				local number = v[2]
				local mjTileName = Utils.getMJTileResName(4, color, number, self.isHZLZ)
				-- Spr_mjTileList[k]._Spr_bg:setVisible(true)
				-- local imgfile = ""
				-- if gt.createType == 2 or gt.createType == 8 then
				-- 	imgfile = "sx_txt_table_mouse.png"
				-- elseif gt.createType == 5 then
				-- 	imgfile = "sx_txt_table_jin.png"
				-- end
				gt.log("------------------mjTileName", mjTileName)
				-- Spr_mjTileList[k]._Spr_name:ignoreContentAdaptWithSize(true)
				-- Spr_mjTileList[k]._Spr_name:loadTexture(imgfile,1)
				-- Spr_mjTileList[k]._Spr_name:setVisible(true)
				Spr_mjTileList[k]._Spr_mjTile:setVisible(true)
				Spr_mjTileList[k]._Spr_mjTile:initWithSpriteFrameName(mjTileName)
				self:addMouseMark(Spr_mjTileList[k]._Spr_mjTile,true)
				--2017-3-3 shenyongzhen
				local templist = {_color = color,_number = number}	
				table.insert(self.HaoZiCards,templist)
			end
			if #msgTbl.kHaoZiCards == 2 then
				Spr_mjTileList[1]._Spr_mjTile:setPositionX(-25)
				Spr_mjTileList[2]._Spr_mjTile:setPositionX(25)
			end
			gt.log("耗子牌222")
			--dump(self.HaoZiCards)
			self:sortPlayerMjTiles()
		end
	else
		Node_dabao:setVisible(false)
		Image_logo:setVisible(true)
	end
	local decisionTypes = {}
	local decisionData = {}
	if #msgTbl.kThink > 0 then
		if msgTbl.kThink[1][1] == 2 then
			decisionData.flag = 2
			-- gt.log("打包发过来的宝", #msgTbl.m_think, msgTbl.m_think[1][#msgTbl.m_think[1]][1], msgTbl.m_think[1][#msgTbl.m_think[1]][2])
			--dump(msgTbl.m_think)
			decisionData.mjColor = msgTbl.kThink[1][#msgTbl.kThink[1]][1][1]
			decisionData.mjNumber = msgTbl.kThink[1][#msgTbl.kThink[1]][1][2]
			table.insert(decisionTypes,decisionData)
			gt.log("胡", decisionData.mjColor, decisionData.mjNumber)	
		end
	end
	gt.log("11111", decisionData.mjColor, decisionData.mjNumber)
	--dump(decisionData)
	if #decisionTypes > 0 then
		-- 自摸类型决策
		gt.log("2222222222")
		self.isPlayerDecision = true

		local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
		selfDrawnDcsNode:setVisible(true)

		for _, decisionBtn in ipairs(selfDrawnDcsNode:getChildren()) do
			local nodeName = decisionBtn:getName()
			if nodeName == "Btn_decisionPass" then
				gt.log("点击的是过牌按钮 ======= ")
				-- 设置不存在的索引值
				decisionBtn:setTag(0)
				gt.addBtnPressedListener(decisionBtn, function()
					gt.dumplog("----------------点过2")
					local function passDecision()
						self.isBeingTing = false
						self.isPlayerDecision = false
						self.curTypeIsGang = false
						self.isAutoOutTile = false

						local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
						selfDrawnDcsNode:setVisible(false)
						-- 删除弹出框（杠）
						self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BAR)
						-- 删除弹出框（补）
						self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BU)
						-- 删除弹出框（听）
						self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_TING)

						local msgToSend = {}
						msgToSend.kMId = gt.CG_PLAYER_DECISION
						msgToSend.kType = 0
						gt.log("发送过牌 =========")
						msgToSend.kThink = {{decisionData.mjColor, decisionData.mjNumber}}
						gt.socketClient:sendMessage(msgToSend)						
					end
					-- 过,漏胡提示
					local m_canHu = false
					gt.log("决策按钮是否有胡牌 222222 ========")
					--dump(decisionTypes)
					for idx, decisionData in ipairs(decisionTypes) do
						if decisionData.flag == 2 then
							m_canHu = true
						end
					end
					if m_canHu == true then
						require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
							gt.getLocationString("LTKey_0043"), passDecision)
					else
						passDecision()
					end
				end)
			else
				decisionBtn:setVisible(false)
			end
		end

		local decisionBtn_pass = gt.seekNodeByName(selfDrawnDcsNode, "Btn_decisionPass")
		local beginPos = cc.p(decisionBtn_pass:getPosition())
		local btnSpace = decisionBtn_pass:getContentSize().width * 3

		local btn_presentList = {}
		gt.log("3333333333")
		for idx, decisionData in ipairs(decisionTypes) do
			local decisionBtn = nil
			gt.log("444444444444")
			if decisionData.flag == 2 then
				-- 胡
				gt.log("555555555555")
				decisionBtn = gt.seekNodeByName(selfDrawnDcsNode, "Btn_decisionWin")
				decisionBtn:setVisible(true)
			    -- 响应决策按键事件
				gt.addBtnPressedListener(decisionBtn, function(sender)
					self.isPlayerDecision = false
					self.isShowEat = false

					-- 隐藏决策按键
					selfDrawnDcsNode:setVisible(false)
					-- 发送决策消息
					local msgToSend = {}

					msgToSend.kMId = gt.CG_PLAYER_DECISION
					msgToSend.kType = 2
					gt.log("发送胡牌 111111")
					msgToSend.kThink = {{decisionData.mjColor, decisionData.mjNumber}}
					gt.socketClient:sendMessage(msgToSend)
				end)		

				local mjTileSpr = gt.seekNodeByName(decisionBtn, "Spr_mjTile")
				if mjTileSpr then
					if decisionData.mjColor==0 and decisionData.mjNumber==0 then
						mjTileSpr:setVisible( false )
					else
						-- mjTileSpr:setSpriteFrame(string.format("p4s%d_%d.png", decisionData.mjColor, decisionData.mjNumber))
						mjTileSpr:setSpriteFrame(Utils.getMJTileResName(4, decisionData.mjColor, decisionData.mjNumber,self.isHZLZ))

						-- 添加耗子牌标识
						if self.HaoZiCards then
							for i,card in ipairs(self.HaoZiCards) do
								if decisionData.mjColor == card._color and decisionData.mjNumber == card._number then
									self:addMouseMark(mjTileSpr, true)	
								end		
							end
						end
					end
				end
				-- 杠的显示优先级为1
				table.insert(btn_presentList,{1,decisionBtn})
			end
		end
	end
end
-- 起手胡,过之外的按钮
function MJScene:createStartHuDecisionMenu()
	local startDecisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_start_decisionBtn")
	local startDecisionBtnPass = gt.seekNodeByName(startDecisionBtnNode, "Btn__start_decision_0") -- 胡
    startDecisionBtnNode:setLocalZOrder(MJScene.ZOrder.DECISION_NEW)
	local btnSize = gt.seekNodeByName(startDecisionBtnNode, "Btn_start_decision_1"):getContentSize()
	local btnSpace = btnSize.width * 1.5
	local btnPos = cc.p(startDecisionBtnPass:getPositionX()-btnSpace, startDecisionBtnPass:getPositionY())

	for i,v in ipairs(self.m_startDecisionTypes) do
		local decisionBtn = gt.seekNodeByName(startDecisionBtnNode, "Btn_start_decision_" .. v[1])
		decisionBtn:setTag( v[1] )
		decisionBtn.myDate = v

		decisionBtn:setVisible(true)
		decisionBtn:setPosition(btnPos)

		btnPos = cc.pAdd(btnPos, cc.p(-btnSpace, 0))

		-- 响应决策按键事件
		gt.addBtnPressedListener(decisionBtn, function(sender)
			local recvData = sender.myDate
			local sendType = sender:getTag()

			if sendType == 1 or sendType == 2 then -- 缺一色 ,板板胡直接发送
				self:onSendMSg66( sendType, recvData[2] )
			elseif sendType == 3 then -- 大四喜,如果有2个或者以上才需要点出二级菜单
				if #recvData[2] >= 2 then
					-- 需要弹出二级菜单
					self:createStartDecisionFlimLayer( 3, recvData[2], sender:getPositionX(), sender:getPositionY() )
				else
					self:onSendMSg66( sendType, recvData[2] )
				end
			elseif sendType == 4 then -- 六六顺,如果有3个以上的,需要选择2个
				if #recvData[2] >= 3 then
					-- 需要弹出二级菜单
					self:createStartDecisionFlimLayer( 4, recvData[2], sender:getPositionX(), sender:getPositionY() )
				else
					self:onSendMSg66( sendType, recvData[2] )
				end
			end
		end)
	end
end

function MJScene:createStartDecisionFlimLayer(flimLayerType,cardList, posx, posy)
	-- 如果已经存在了显示层,那么看是否已经是相同类型
	if self.m_startFlimLayer then
		if self.m_startFlimLayer.flimLayerType == flimLayerType then
			return
		else
			self.m_startFlimLayer:removeFromParent()
			self.m_startFlimLayer = nil
		end
	end

	-- 一个麻将
	-- local mjTileName = string.format("p4s%d_%d.png", 2, 2)
	local mjTileName = Utils.getMJTileResName(4, 2, 2, self.isHZLZ)
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	local width_oneMJ = mjTileSpr:getContentSize().width

	local space_gang = 20
	local width = 60+mjTileSpr:getContentSize().width*4*(#cardList)+space_gang*(#cardList-1)
	local height = 50+mjTileSpr:getContentSize().height

	local flimLayer = cc.LayerColor:create(cc.c4b(85, 85, 85, 0), width, height)
	flimLayer:setContentSize(cc.size(width,height))

	-- 添加半透明底
	gt.log("添加半透明底")
	local image_bg = ccui.ImageView:create()
	image_bg:loadTexture("images/otherImages/laoyue_bg.png")
	image_bg:setScale9Enabled(true)
	image_bg:setCapInsets(cc.rect(10,10,1,1))
	image_bg:setContentSize(cc.size(width-20,height))
	image_bg:setAnchorPoint(cc.p(0,0))
	flimLayer:addChild(image_bg)

	local function onTouchBegan(touch, event)
		return true
	end

	local cardNum = 3 -- 一组有几个麻将要显示
	if flimLayerType == 3 then -- 四喜
		cardNum = 4
	elseif flimLayerType == 4 then -- 六六顺
		cardNum = 3
	end

	table.sort(cardList,function(a, b)
		return a[2] < b[2]
	end)

	-- 记录所有的显示的牌
	self.allStartButton = {}

	-- 创建麻将
	for idx,value in ipairs(cardList) do
		local mjColor = value[1]
		local mjNumber = value[2]

		-- local mjSprName = string.format("p4s%d_%d.png", mjColor, mjNumber)
		local mjSprName = Utils.getMJTileResName( 4, mjColor, mjNumber, self.isHZLZ)
		for i=1,cardNum do
			local button = ccui.Button:create()
			table.insert( self.allStartButton, button )
			button:loadTextures(mjSprName,mjSprName,"",ccui.TextureResType.plistType)
			button:setTouchEnabled(true)
    		button:setAnchorPoint(cc.p(0,0))
    		button:setPosition(cc.p(30+space_gang*(idx-1)+width_oneMJ*(i-1)+width_oneMJ*4*(idx-1), 20))
   			button:setTag( flimLayerType )
   			button.myDate = value
   			button.myIndex = cardNum + (idx-1)*cardNum
   			flimLayer:addChild(button)

    		local function touchEvent(ref, type)
       			if type == ccui.TouchEventType.ended then
					if ref:getTag() == 4 then -- 六六顺,需要选择两组才可以出牌
						if self.startDecisionTypeLiuliushun then
							if ref.isChoose == true then -- 如果已经选择了,那么显示回去颜色
								local curIndex = math.floor((ref.myIndex-1) / 3)
								for k=1,3 do
									self.allStartButton[curIndex*3+k].isChoose = false
									self.allStartButton[curIndex*3+k]:setColor( cc.c3b(255,255,255) )
								end

								local detTab = {} -- 没被点击的
								for i,v in ipairs(self.startDecisionTypeLiuliushun) do
									if v[1] == ref.myDate[1] and v[2] == ref.myDate[2] then
										-- ...
									else
										table.insert( detTab, v )
									end
								end
								self.startDecisionTypeLiuliushun = detTab
							else
								local curIndex = math.floor((ref.myIndex-1) / 3)
								for k=1,3 do
									self.allStartButton[curIndex*3+k].isChoose = true
									self.allStartButton[curIndex*3+k]:setColor( cc.c3b(255,0,0) )
								end
								table.insert( self.startDecisionTypeLiuliushun, ref.myDate )

								if #self.startDecisionTypeLiuliushun == 2 then -- 需要给服务器发送消息
									self:onSendMSg66( 4, self.startDecisionTypeLiuliushun )
									self.startDecisionTypeLiuliushun = nil
								end
							end
						else
							self.startDecisionTypeLiuliushun = {}
							local curIndex = math.floor((ref.myIndex-1) / 3)
							for k=1,3 do
								self.allStartButton[curIndex*3+k].isChoose = true
								self.allStartButton[curIndex*3+k]:setColor( cc.c3b(255,0,0) )
							end
							table.insert( self.startDecisionTypeLiuliushun, ref.myDate )
						end
					elseif ref:getTag() == 3 then -- 四喜
						self:onSendMSg66( 3, {ref.myDate} )
					end
       		 	end
  	  		end
   	 		button:addTouchEventListener(touchEvent)
		end
	end

	self:addChild(flimLayer,MJScene.ZOrder.FLIMLAYER,MJScene.TAG.FLIMLAYER_BAR)
	flimLayer:ignoreAnchorPointForPosition(false)
	flimLayer:setAnchorPoint(0.5,0)
	local pos_x = 0
	if posx+flimLayer:getContentSize().width/2 > gt.winSize.width then
		flimLayer:setPositionX(gt.winSize.width-flimLayer:getContentSize().width/2)
	elseif posx-flimLayer:getContentSize().width/2 < 0 then
		flimLayer:setPositionX(flimLayer:getContentSize().width/2)
	else
		flimLayer:setPositionX(posx)
	end
	flimLayer:setPositionY(posy+flimLayer:getContentSize().height/2)

	self.m_startFlimLayer = flimLayer
	self.m_startFlimLayer.flimLayerType = flimLayerType -- 3四喜,4六六顺
end

function MJScene:onSendMSg66( cartType, cardarray )
	self.isPlayerDecision = false
	-- 隐藏决策按键
	local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_start_decisionBtn")
	decisionBtnNode:setVisible(false)
	-- 隐藏第二层
	if self.m_startFlimLayer then
		self.m_startFlimLayer:removeFromParent()
		self.m_startFlimLayer = nil
	end

	local msgToSend = {}
	msgToSend.kMId = gt.CG_START_PLAYER_DECISION
	msgToSend.kType = cartType
	msgToSend.kCard = cardarray
	--dump( msgToSend )
	gt.socketClient:sendMessage(msgToSend)
end

-- start --
--------------------------------
-- @class function
-- @description 通知玩家决策
-- end --
function MJScene:onRcvMakeDecision(msgTbl)
	gt.log("通知玩家决策")
	--dump(msgTbl)
	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
		gt.dumplog(self.roomPlayers)
	end
--msgTbl.m_think = {{6, {{3,4},{3,5}}}}
--msgTbl.m_think = {{6, {{3,4},{3,5}}}, {6, {{3,7}, {3,8}}}  }
--msgTbl.m_think = {{6, {{3,4},{3,5}}}, {6, {{3,7}, {3,8}}}, {6, {{3,5},{3,7}}}   }

	self.isShowEat = false

	if msgTbl.kFlag == 1 then
		-- 玩家决策
		self.isPlayerDecision = true

		-- 决策倒计时
		self:playTimeCDStart(msgTbl.kTime)


		-- 玩家决策
		local decisionTypes = msgTbl.kThink --玩家决策类型
		-- 最后加入决策"过"选项
		--table.insert(decisionTypes, 0)  --插入过类型
		local pass = {0,{}}
		table.insert(decisionTypes, pass)
		-- 显示对应的决策按键
		local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn") --显示所有的按键决策
		decisionBtnNode:setVisible(true)

		for _, decisionBtn in ipairs(decisionBtnNode:getChildren()) do
			decisionBtn:setVisible(false)
		end

		local btn_presentList = {}

		local Btn_decision_0 = gt.seekNodeByName(decisionBtnNode, "Btn_decision_0")
		Btn_decision_0:setVisible(true)
		local startPosX = Btn_decision_0:getPositionX()
		local posY = Btn_decision_0:getPositionY()

		local noSame = {}
		for i, v in ipairs(decisionTypes) do
			local isExist = false
			table.foreach(noSame, function(k, m)
				if m[1] == v[1] then
					isExist = true
					return false
				end
			end)
			if not isExist then
				table.insert(noSame, v)
			end
		end
		local posTag = #noSame
		--dump(noSame)
		local Btn_decision_visible_flag = true
		for i, v in ipairs(noSame) do
			-- 1-出牌 2-胡，3-暗杠 4-明杠，5-碰，6-吃，7-听、8-吃听、9-碰听、10-暗杠听、11-明杠听、20-硬扣、21-不硬扣
			local m_type = nil
			-- gt.log("显示决策按钮：v[1]="..v[1])
			if v[1] == 0 then
				-- if self.playType ~= 100004 then
				-- 	--如果是立四玩法，没有过牌按钮
					m_type = 0
				-- end
			elseif v[1] == 2 then
				m_type = 1
			elseif v[1] == 3 or v[1] == 4 then
				m_type = 2
			elseif v[1] == 5 then
				m_type = 3
			elseif v[1] == 6 then
				m_type = 4
			elseif v[1] == 8 then
				m_type = 5
			elseif v[1] == 9 then
				m_type = 6
			elseif v[1] == 7 or v[1] == 10 or v[1] == 11 then
				m_type = 7
			elseif v[1] == 12 then
				--粘听
				m_type = 12
			elseif v[1] == 20 then
				m_type = 21
			elseif v[1] == 21 then
				m_type = 22
			end
			posTag = posTag - 1
			-- gt.log("Btn_decision_" .. m_type .. " is show")
			local decisionBtn = gt.seekNodeByName(decisionBtnNode, "Btn_decision_" .. m_type)
			if decisionBtn:getChildByTag(5) then
				decisionBtn:getChildByTag(5):removeFromParent()
			end
			decisionBtn:setTag(v[1])
			decisionBtn:setVisible(true)

			if m_type == 7 then    --听
				table.insert(btn_presentList, {1 , decisionBtn})
			elseif m_type == 3 then    --碰
				table.insert(btn_presentList, {3 , decisionBtn})
			elseif m_type == 2  then    --杠
				table.insert(btn_presentList, {2 , decisionBtn})
			elseif m_type == 1 then    --胡
				table.insert(btn_presentList, {4 , decisionBtn})
			elseif m_type == 21 then    --硬扣
				table.insert(btn_presentList, {5 , decisionBtn})
			elseif m_type == 22 then    --不硬扣
				table.insert(btn_presentList, {6 , decisionBtn})
			end

			if m_type == 21 or m_type == 22 then
				Btn_decision_visible_flag = false
			end

			gt.log("如果是立四玩法，且已听牌，隐藏过牌按钮，playType = "..self.playType..", btnName = "..decisionBtn:getName())
			local isCanHu = false
			gt.log("决策按钮是否有胡牌 mmm ========")
			--dump(decisionTypes)
			for idx, decisionData in ipairs(decisionTypes) do
				if decisionData[1] == 2 then
					isCanHu = true
				end
			end
			if (self.playType == 100004 or self.playType == 100003) and isCanHu and decisionBtn:getName() == "Btn_decision_0" then
				--如果是立四玩法，隐藏过牌按钮
				gt.log("别人点碰杠时，如果是立四玩法，隐藏过牌按钮")
				decisionBtn:setVisible(false)
			end

			local x = startPosX - posTag * (Btn_decision_0:getContentSize().width - 20) * 2
			decisionBtn:setPosition(cc.p(startPosX - posTag * (Btn_decision_0:getContentSize().width - 20) * 2, posY))
            
			-- 显示要碰，杠，胡的牌
			local mjTileSpr = gt.seekNodeByName(decisionBtn, "Spr_mjTile")
			if mjTileSpr then
				-- mjTileSpr:setSpriteFrame(string.format("p4s%d_%d.png", msgTbl.m_color, msgTbl.m_number))
				local decisionData = {}
				if #msgTbl.kThink > 0 then
					if msgTbl.kThink[1][1] == 2 then
						decisionData.mjColor = msgTbl.kThink[1][#msgTbl.kThink[1]][1][1]
						decisionData.mjNumber = msgTbl.kThink[1][#msgTbl.kThink[1]][1][2]
					else
						decisionData.mjColor = msgTbl.kColor
						decisionData.mjNumber = msgTbl.kNumber
					end
				end
				mjTileSpr:setSpriteFrame(Utils.getMJTileResName(4, decisionData.mjColor, decisionData.mjNumber, self.isHZLZ))
			end

			-- 响应决策按键事件
			gt.addBtnPressedListener(decisionBtn, function(sender)
				-- 过,漏胡提示
				local m_canHu = false
				gt.log("决策按钮是否有胡牌 222 ========")
				--dump(decisionTypes)
				for idx, decisionData in ipairs(decisionTypes) do
					if decisionData[1] == 2 then
						m_canHu = true
					end
				end
				local function makeDecision(decisionType, m_type)
					self.isPlayerDecision = false
					self.isShowEat = false

					-- 不隐藏决策按键
					local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
					decisionBtnNode:setVisible(false)
					local tempThink = {{msgTbl.kColor,msgTbl.kNumber}}
					if decisionType == 0 and m_canHu == true  then
						gt.dumplog("----------------点过3")
						--如果点击的是过，且当前有能胡牌，二次确认弹窗
						require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
							gt.getLocationString("LTKey_0043"), passDecision, nil, nil, nil, true,tempThink)
					else
						-- 发送决策消息
						local msgToSend = {}

						msgToSend.kMId = gt.CG_PLAYER_DECISION
						msgToSend.kType = decisionType
						gt.log("点击决策按钮 type = "..decisionType)
						
						msgToSend.kThink = {{msgTbl.kColor,msgTbl.kNumber}}
						gt.socketClient:sendMessage(msgToSend)

						if self.AppVersion and self.AppVersion > 10 then
							gt.dumplog("点击了决策按钮,决策消息:")
							gt.dumplog(msgToSend)
						end
					end
				end

				local decisionType = sender:getTag()
				if decisionType == 6 or decisionType == 8 then  --吃牌
					if self.isShowEat then
						return
					end
					local showMjEatTable = {} --要显示的吃的牌
					local oriMjEatTable = {}
					for _, m in pairs(decisionTypes) do
						if m[1] == decisionType then
							table.insert(showMjEatTable, {m[2][1][2], msgTbl.kNumber, m[2][2][2]})
							table.insert(oriMjEatTable, m[2])
						end
					end
					local function sendEatMssage(eats)
						self.isPlayerDecision = false --决策标识为false
						self.isShowEat = false
						-- 隐藏决策按键
						local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
						decisionBtnNode:setVisible(false)

						-- 发送决策消息
						local msgToSend = {}
						msgToSend.kMId = gt.CG_PLAYER_DECISION 
						msgToSend.kType = decisionType
						gt.log("发送决策消息 111111 decisionType = "..decisionType)
						msgToSend.kThink = eats -- wxg msgTbl.m_color又是哪里来的?
						gt.socketClient:sendMessage(msgToSend)
					end

					gt.log("showMjEatTable:" .. #showMjEatTable)
					if #showMjEatTable == 1 then -- 如果只有一个吃,则直接向服务器发送吃的消息
						gt.log("showMjEatTable2")
						sendEatMssage(oriMjEatTable[1])
					else -- 多个吃,需要列出来,供玩家选择
						gt.log("showMjEatTable3")
						local eatBg = cc.Scale9Sprite:create("images/otherImages/tipsbg.png")
						eatBg:setContentSize(cc.size(#showMjEatTable * 3 * mjTileSpr:getContentSize().width + #showMjEatTable * 25, decisionBtn:getContentSize().height))
						local menu = cc.Menu:create()

						local pos = 0
						local mjWidth = 0

						for i, mjNumber in pairs(showMjEatTable) do
							pos = pos + 1
							for j = 1, 3 do
								-- local mjTileName = string.format("p4s%d_%d.png", msgTbl.m_color, mjNumber[j]) --获取图片
								local mjTileName = Utils.getMJTileResName(4, msgTbl.kColor, mjNumber[j], self.isHZLZ) --获取图片
								local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)  --创建精灵
								if tonumber(mjNumber[j]) == tonumber(msgTbl.kNumber) then
									mjTileSpr:setColor(cc.c3b(255,255,0))
								end

								local menuItem = cc.MenuItemSprite:create(mjTileSpr,mjTileSpr) --创建菜单项
								menuItem:setTag(i)

								local function menuCallBack(i, sender)
									local result = nil
									for m, eat in pairs(showMjEatTable) do
										if m == i then
											result = oriMjEatTable[m]
										end
									end
									sendEatMssage(result)
								end
								menuItem:registerScriptTapHandler(menuCallBack)

								menuItem:setPosition(cc.p(mjWidth  + (pos - 1) * 10, eatBg:getContentSize().height / 2))
								menu:addChild(menuItem)

								mjWidth = mjWidth + mjTileSpr:getContentSize().width
							end
						end
						eatBg:addChild(menu)
						if pos == 1 then
							menu:setPosition(eatBg:getContentSize().width * 0.5 - mjWidth * 0.5 + mjTileSpr:getContentSize().width * 0.5 ,0)
						elseif pos == 2 then
							menu:setPosition(eatBg:getContentSize().width * 0.5 - mjWidth * 0.5 + mjTileSpr:getContentSize().width * 0.4 ,0)
						else
							menu:setPosition(eatBg:getContentSize().width * 0.5 - mjWidth * 0.5 + mjTileSpr:getContentSize().width * 0.3 ,0)
						end
						sender:addChild(eatBg , -10, 5)
						eatBg:setPosition(0,eatBg:getContentSize().height * 1.5)
					end
					self.isShowEat = true
				elseif decisionType == 2 then
					for _, m in pairs(decisionTypes) do
						if m[1] == 2 then
							self.isPlayerDecision = false
							-- 隐藏决策按键
							local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
							decisionBtnNode:setVisible(false)
							-- 发送决策消息
							local msgToSend = {}
							msgToSend.kMId = gt.CG_PLAYER_DECISION
							gt.log("发送决策消息 222222 decisionType = "..decisionType)
							msgToSend.kType = decisionType
							msgToSend.kThink = m[2]
							gt.socketClient:sendMessage(msgToSend)

							gt.log("发送决策消息 胡:"..decisionType)
							if self.AppVersion and self.AppVersion > 10 then
								gt.dumplog("点击了胡的按钮,决策消息:")
								gt.dumplog(msgToSend)
							end
						end
					end
				elseif decisionType == 20 then
					for _, m in pairs(decisionTypes) do
						if m[1] == 20 then
							self.isPlayerDecision = false
							-- 隐藏决策按键
							local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
							decisionBtnNode:setVisible(false)
							-- 发送决策消息
							local msgToSend = {}
							msgToSend.kMId = gt.CG_SHOW_MJTILE
							gt.log("发送决策消息 222222 decisionType = "..m[1])
							msgToSend.kType = decisionType
							msgToSend.kThink = m[2]
							gt.socketClient:sendMessage(msgToSend)
							if self.AppVersion and self.AppVersion > 10 then
								gt.dumplog("点击了硬扣按钮,,决策消息:")
								gt.dumplog(msgToSend)
								gt.dumplog(self.roomPlayers)
							end
						end
					end
				elseif decisionType == 21 then
					for _, m in pairs(decisionTypes) do
						if m[1] == 21 then
							self.isPlayerDecision = false
							-- 隐藏决策按键
							local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
							decisionBtnNode:setVisible(false)
							-- 发送决策消息
							local msgToSend = {}
							msgToSend.kMId = gt.CG_SHOW_MJTILE
							gt.log("发送决策消息 222222 decisionType = "..m[1])
							msgToSend.kType = decisionType
							msgToSend.kThink = m[2]
							gt.socketClient:sendMessage(msgToSend)
							if self.AppVersion and self.AppVersion > 10 then
								gt.dumplog("点击了不硬扣按钮,,决策消息:")
								gt.dumplog(msgToSend)
								gt.dumplog(self.roomPlayers)
							end
						end
					end
				else
					makeDecision(decisionType, 0)
				end

			end)
		end
		Btn_decision_0:setVisible(Btn_decision_visible_flag)

		if Btn_decision_visible_flag == true then
			table.insert(btn_presentList, {7, Btn_decision_0})
		end

		-- 根据显示优先级进行排序
		table.sort(btn_presentList, function(a, b)
			return a[1] < b[1]
		end)
		-- 根据排序好的优先级进行显示按钮
		local beginPos = {x = 385, y = 215}
		local btnSpace = 190
		for _,v in ipairs(btn_presentList) do
			gt.log("----------------v[1]",v[1])
			gt.log("----------------_",_)
			beginPos = cc.p(beginPos.x + btnSpace , beginPos.y)
			v[2]:setPosition(beginPos)
		end

	end
end

function MJScene:onRcvGangAfterChiPeng(msgTbl)
	gt.log("收到吃碰后杠消息")

	if self.gangAfterChi then
		self.gangAfterChi:destroy()
		self.gangAfterChi = nil
	end

	--dump(msgTbl)
	self.hasHuPaiDecision = false
	local cardOperates = msgTbl.kCard
	for _, opers in pairs(cardOperates) do
		if opers then
			local operTypes = opers[2]
			for k, v in pairs(operTypes) do
				if v then
					if v[1] == 2 then
						self.hasHuPaiDecision = true
						break
					end
				end
			end
		end
	end
	-- self.hasHuPaiDecision = true

	local roomPlayer = self.roomPlayers[msgTbl.kPos + 1]
	self.gangAfterChi = require("app/views/GangAfterChi"):create(roomPlayer, msgTbl, self)
	self:addChild(self.gangAfterChi, MJScene.ZOrder.GANG_AFTER_CHI_PENG)
end

-- start --
--------------------------------
-- @class function
-- @description 广播决策结果
-- end --
function MJScene:onRcvSyncMakeDecision(msgTbl)
	gt.log("广播决策结果 ===========")
	gt.dump(msgTbl)
	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
		gt.dumplog(self.roomPlayers)
	end

	gt.log("------------------------------------------哈哈走到了这里 1")
	self.curTypeIsGang = false

	if msgTbl.kErrorCode ~= 0 then
		return
	end

	-- 防止多个人同时选择吃碰杠
	gt.log("------------------------------------------哈哈走到了这里 2")
	-- 如果两人都能胡牌 则跳过此处理
	if self.hasHuPaiDecision == true then
		gt.log("我也可以胡牌，一炮多响")
		-- do return end
	else
		if self.gangAfterChi then
			self.gangAfterChi:destroy()
			self.gangAfterChi = nil
		end
	end

	gt.log("------------------------------------------哈哈走到了这里 3")
	-- 隐藏决策按键
	local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
	if decisionBtnNode:isVisible() == true then
		local isCanHuFlag = false
		for _, decisionBtn in ipairs(decisionBtnNode:getChildren()) do
			if  decisionBtn:getName() == "Btn_decision_1" then
				if decisionBtn:isVisible() == true then
					isCanHuFlag = true
					break
				end

			end
		end

		if isCanHuFlag == true then -- 有胡
			for _, decisionBtn in ipairs(decisionBtnNode:getChildren()) do
				 if decisionBtn:getName() == "Btn_decision_0" or decisionBtn:getName() == "Btn_decision_1" then
					decisionBtn:setVisible(true)
				else
					decisionBtn:setVisible(false)
				end
			end
		end

		if isCanHuFlag == false then
			self.isPlayerDecision = false

			decisionBtnNode:setVisible( false )
		end

	end

	gt.log("------------------------------------------哈哈走到了这里 4")

	if msgTbl.kThink ~= 0 then -- 吃,碰,杠,胡
		if self.startMjTileAnimation ~= nil then
			self.startMjTileAnimation:stopAllActions()
			self.startMjTileAnimation:removeFromParent()
			self.startMjTileAnimation = nil
			-- self:addAlreadyOutMjTiles(self.preShowSeatIdx, self.startMjTileColor, self.startMjTileNumber, true)
		end
	end
	
	local seatIdx = msgTbl.kPos + 1
	gt.log("------------------------------------------哈哈走到了这里")
	if msgTbl.kThink[1] == 2 then
		-- 接炮胡m_hu
		local hu_color = msgTbl.kThink[#msgTbl.kThink][1][1]
		local hu_number = msgTbl.kThink[#msgTbl.kThink][1][2]
		self:showAllMjTilesWhenWin(seatIdx, msgTbl.kCardCount, msgTbl.kCardValue, hu_color, hu_number, msgTbl.kHucard2_color, msgTbl.kHucard2_number, true)
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.TAKE_CANNON_WIN, msgTbl.kHu)
	elseif msgTbl.kThink[1] == 3 or  msgTbl.kThink[1] == 4 then
		-- 明杠
		self:addMjTileBar(seatIdx, msgTbl.kColor, msgTbl.kNumber, true)
		-- 杠牌动画
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.BRIGHT_BAR)
		-- 隐藏持有牌中打出的牌
		self:hideOtherPlayerMjTiles(seatIdx, true, true)
		-- 移除上家打出的牌
		self:removePreRoomPlayerOutMjTile(msgTbl.kColor, msgTbl.kNumber)
	elseif msgTbl.kThink[1] == 5 then
		-- 碰牌
		self:addMjTilePung(seatIdx, msgTbl.kColor, msgTbl.kNumber, true)
		-- 碰牌动画
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.PUNG)

		-- 隐藏持有牌中打出的牌
		self:hideOtherPlayerMjTiles(seatIdx, false)

		-- 移除上家打出的牌
		self:removePreRoomPlayerOutMjTile(msgTbl.kColor, msgTbl.kNumber)
	elseif msgTbl.kThink[1] == 6 then
		local eatGroup = {}
		table.insert(eatGroup,{msgTbl.kThink[2][1][2], 0, msgTbl.kColor})
		table.insert(eatGroup,{msgTbl.kNumber, 1, msgTbl.kColor})
		table.insert(eatGroup,{msgTbl.kThink[2][2][2], 0, msgTbl.kColor})
		--table.sort(eatGroup, function(a, b)
			--return a[1] < b[1]
		--end)

		-- 吃牌
		local roomPlayer = self.roomPlayers[seatIdx]
		table.insert(roomPlayer.mjTileEat, eatGroup)

		roomPlayer.mjTileEat[#roomPlayer.mjTileEat].groupNode = self:pungBarReorderMjTiles(seatIdx, msgTbl.kColor, eatGroup)
		-- 吃牌动画
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.EAT)

		-- 隐藏持有牌中打出的牌
		self:hideOtherPlayerMjTiles(seatIdx, false)
		-- 移除上家打出的牌
		self:removePreRoomPlayerOutMjTile(msgTbl.kColor, msgTbl.kNumber)
	elseif msgTbl.kThink[1] == 8 then
		local eatGroup = {}
		table.insert(eatGroup,{msgTbl.kThink[2][1][2], 0, msgTbl.kColor})
		table.insert(eatGroup,{msgTbl.kNumber, 1, msgTbl.kColor})
		table.insert(eatGroup,{msgTbl.kThink[2][2][2], 0, msgTbl.kColor})
		local roomPlayer = self.roomPlayers[seatIdx]
		table.insert(roomPlayer.mjTileEat, eatGroup)

		roomPlayer.mjTileEat[#roomPlayer.mjTileEat].groupNode = self:pungBarReorderMjTiles(seatIdx, msgTbl.kColor, eatGroup)
		-- 吃牌动画
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.TING)

		-- 隐藏持有牌中打出的牌
		self:hideOtherPlayerMjTiles(seatIdx, false)
		-- 移除上家打出的牌
		self:removePreRoomPlayerOutMjTile(msgTbl.kColor, msgTbl.kNumber)
	elseif msgTbl.kThink[1] == 9 then
		-- 碰听
		self:addMjTilePung(seatIdx, msgTbl.kColor, msgTbl.kNumber)
		-- 碰牌动画
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.TING)

		-- 隐藏持有牌中打出的牌
		self:hideOtherPlayerMjTiles(seatIdx, false)
		-- 移除上家打出的牌
		self:removePreRoomPlayerOutMjTile(msgTbl.kColor, msgTbl.kNumber)
	elseif msgTbl.kThink[1] == 10 or  msgTbl.kThink[1] == 11 then
		-- 明杠听，暗杠听
		self:addMjTileBar(seatIdx, msgTbl.kColor, msgTbl.kNumber, true)
		-- 杠牌动画
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.TING)

		-- 隐藏持有牌中打出的牌
		self:hideOtherPlayerMjTiles(seatIdx, true, true)
		-- 移除上家打出的牌
		self:removePreRoomPlayerOutMjTile(msgTbl.kColor, msgTbl.kNumber)
	elseif msgTbl.kThink[1] == 12 then
		gt.log("粘听")
		--粘听
		self:addMjTileNian(seatIdx, msgTbl.kColor, msgTbl.kNumber)
		-- 碰牌动画
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.TING)

		-- 隐藏持有牌中打出的牌
		self:hideOtherPlayerMjTiles(seatIdx, false)
		-- 移除上家打出的牌
		self:removePreRoomPlayerOutMjTile(msgTbl.kColor, msgTbl.kNumber)
	elseif msgTbl.kThink[1] == 20 then
		gt.log("支对消息")
		self:addMjTileZhiDui(seatIdx, msgTbl.kColor, msgTbl.kNumber)
		-- 碰牌动画
		self:showDecisionAnimation(seatIdx, MJScene.DecisionType.TING)
		-- 隐藏持有牌中打出的牌
		self:hideOtherPlayerMjTiles(seatIdx, false)
		-- 移除上家打出的牌
		self:removePreRoomPlayerOutMjTile(msgTbl.kColor, msgTbl.kNumber)
		--玩家可出牌
		-- self.isPlayerShow = true
	end

	if msgTbl.kThink[1] == 8 
		or msgTbl.kThink[1] == 9 
		or msgTbl.kThink[1] == 10 
		or msgTbl.kThink[1] == 11
		or msgTbl.kThink[1] == 12 then
		-- 听标识
		-- local setPos = self:getDisplaySeat(seatIdx)
		local roomPlayer = self.roomPlayers[seatIdx]
		local setPos = roomPlayer.displaySeatIdx
		for i=1,4 do
			local nodePlayerInfo = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. i)
			local spr_ting = gt.seekNodeByName(nodePlayerInfo, "spr_ting")
			if setPos == i then
				spr_ting:setVisible(true)
			end
		end
		for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
			if _ ~= #roomPlayer.holdMjTiles then
				if self.playerSeatIdx == seatIdx then
					mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
				else
					mjTile.mjTileSpr:setColor(cc.c3b(130,130,130))
				end
			end
		end		
	end

	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog("别的玩家碰杠胡后 手牌信息")
		gt.dumplog(self.roomPlayers[self.playerSeatIdx].holdMjTiles)   

		gt.dumplog("别的玩家碰杠胡后 出牌信息")
		gt.dumplog(self.roomPlayers[self.playerSeatIdx].outMjTiles)

		gt.dumplog("别的玩家碰杠胡后 亮牌信息")
		gt.dumplog(self.roomPlayers[seatIdx])	
	end

end

function MJScene:onRcvChatMsg(msgTbl)
	gt.log("收到聊天消息")
	--dump(msgTbl)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("images/EmotionOut.plist")
	if msgTbl.kType == 5 then -- 互动动画类型
		-- m_userId -- 说话人的id(即接受)
		-- m_pos  -- 说话人的位置(发起者)
		-- m_id -- 互动表情类型
		-- m_msg -- 接受互动人的id
		local sendRoomPlayer = self.roomPlayers[msgTbl.kPos + 1]
		local receiveRoomPlayer = nil  --发送互动的玩家

  		table.foreach(self.roomPlayers, function(i, v)
			if v.uid == tonumber(msgTbl.kMsg) then
				receiveRoomPlayer = v
				return true
			end
  		end)

		-- local aniNames = {{"ani_diujidan_0.csb","ani_diujidan_1.csb","ani_diujidan_2.csb"}, 
		-- 				  {"ani_songhua_1.csb","ani_songhua_2.csb","ani_songhua_3.csb"}}
		-- local sendPlayerNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. sendRoomPlayer.displaySeatIdx)
		-- local receivePlayerNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. receiveRoomPlayer.displaySeatIdx)

		-- local sendNodePos = sendPlayerNode:convertToWorldSpace(cc.p(0.5, 0.5))
		-- local receiveNodePos = receivePlayerNode:convertToWorldSpace(cc.p(0.5, 0.5))
		-- if sendRoomPlayer.uid == gt.playerData.uid then  --发送者为自己
		-- 	local feiNode, feiAni = gt.createCSAnimation("animation/"..aniNames[msgTbl.m_id][1])
		-- 	local completeFunc = cc.CallFunc:create(function()
		-- 			feiNode:stopAllActions()
		-- 			feiNode:removeFromParent(true)
					
		-- 			local boNode, boAni = gt.createCSAnimation("animation/"..aniNames[msgTbl.m_id][2])
		-- 			boNode:setPosition(cc.p(receiveNodePos.x, receiveNodePos.y))
		-- 			self:addChild(boNode, MJScene.ZOrder.CHAT)
		-- 			boAni:gotoFrameAndPlay(0, false)
		-- 			boNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function(sender)
		-- 				sender:stopAllActions()
		-- 				sender:removeFromParent(true)
		-- 			end)))
		-- 		end)
		-- 	local time = 0.8
		-- 	if receiveRoomPlayer.displaySeatIdx == 3 then
		-- 		time = 0.3
		-- 	end
		-- 	local moveAni = cc.MoveTo:create(time, cc.p(receiveNodePos.x, receiveNodePos.y))
		-- 	feiNode:runAction(cc.Sequence:create(moveAni, completeFunc))
		-- 	feiAni:gotoFrameAndPlay(0, true)
		-- 	self:addChild(feiNode, MJScene.ZOrder.CHAT)
		-- 	feiNode:setPosition(cc.p(sendNodePos.x, sendNodePos.y))
		-- elseif receiveRoomPlayer.uid == gt.playerData.uid then --接受者方才播放
		-- 	local playingNode, playingAni = gt.createCSAnimation("animation/"..aniNames[msgTbl.m_id][3])
		-- 	self:addChild(playingNode, MJScene.ZOrder.CHAT)
		-- 	playingNode:setPosition(gt.winCenter)
		-- 	playingAni:gotoFrameAndPlay(0, false)
		-- 	playingNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender)
		-- 		sender:stopAllActions()
		-- 		sender:removeFromParent(true)
		-- 	end)))
		-- end


		local aniNames = {{"hudong1/hua01.png", "hudong1/hudong1.csb"},
		{"hudong2/shou-03.png", "hudong2/hudong2.csb"},
		{"hudong3/001.png", "hudong3/hudong3.csb"},
		{"hudong4/bomb_01.png", "hudong4/hudong4.csb"}}

		local sendPlayerNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. sendRoomPlayer.displaySeatIdx)
		local receivePlayerNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. receiveRoomPlayer.displaySeatIdx)

		local sendNodePos = sendPlayerNode:convertToWorldSpace(cc.p(0.5, 0.5))
		local receiveNodePos = receivePlayerNode:convertToWorldSpace(cc.p(0.5, 0.5))
		local x = 0
		local y = 0 
		if receiveRoomPlayer.displaySeatIdx == 3 then
			x = 100
		elseif receiveRoomPlayer.displaySeatIdx == 2 then
			x = 100
			if msgTbl.kId > 1 and msgTbl.kId < 4 then
				y = -50
			end
		elseif receiveRoomPlayer.displaySeatIdx == 1 then
			x = -40
		end
		if sendRoomPlayer.uid == gt.playerData.uid then  --发送者为自己
			gt.log("--------------------aniNames[msgTbl.m_id][1]", aniNames[msgTbl.kId][1])
			if msgTbl.kId == 2 then
				gt.log("--------------------aniNames[msgTbl.m_id][2]", aniNames[msgTbl.kId][2])
				local boNode, boAni = gt.createCSAnimation("animation/biaoqing/"..aniNames[msgTbl.kId][2])
				boNode:setPosition(cc.p(receiveNodePos.x+x, receiveNodePos.y+y))
				self:addChild(boNode, MJScene.ZOrder.CHAT)
				-- boAni:gotoFrameAndPlay(0, false)
				boAni:play("run", false)
				boNode:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function(sender)
					sender:stopAllActions()
					sender:removeFromParent(true)
				end)))
			else
				local feiSpr = cc.Sprite:create("animation/biaoqing/"..aniNames[msgTbl.kId][1])
				local completeFunc = cc.CallFunc:create(function()
						feiSpr:stopAllActions()
						feiSpr:removeFromParent(true)
						
						local boNode, boAni = gt.createCSAnimation("animation/biaoqing/"..aniNames[msgTbl.kId][2])
						boNode:setPosition(cc.p(receiveNodePos.x+x, receiveNodePos.y+y))
						self:addChild(boNode, MJScene.ZOrder.CHAT)
						boAni:gotoFrameAndPlay(0, false)
						boNode:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function(sender)
							sender:stopAllActions()
							sender:removeFromParent(true)
						end)))
					end)
				local time = 0.8
				if receiveRoomPlayer.displaySeatIdx == 3 then
					time = 0.3
				end
				local moveAni = cc.MoveTo:create(time, cc.p(receiveNodePos.x+x, receiveNodePos.y+y))
				feiSpr:runAction(cc.Sequence:create(moveAni, completeFunc))
				-- feiAni:gotoFrameAndPlay(0, true)
				self:addChild(feiSpr, MJScene.ZOrder.CHAT)
				feiSpr:setPosition(cc.p(sendNodePos.x+x, sendNodePos.y))
			end
		elseif receiveRoomPlayer.uid == gt.playerData.uid then --接受者方才播放
			local btnSender = gt.seekNodeByName(self.rootNode, "Txt_ChatSender")
			btnSender:setText("\""..sendRoomPlayer.nickname.."\"馈赠给你的表情")
			btnSender:setVisible(true)
			local playingNode, playingAni = gt.createCSAnimation("animation/biaoqing/"..aniNames[msgTbl.kId][2])
			playingNode:setScale(2)
			self:addChild(playingNode, MJScene.ZOrder.CHAT)
			playingNode:setPosition(gt.winCenter)
			playingAni:gotoFrameAndPlay(0, false)
			playingNode:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function(sender)
				sender:stopAllActions()
				sender:removeFromParent(true)
				btnSender:setVisible(false)
			end)))
		end
	elseif msgTbl.kType == 4 then
		--语音
		gt.soundEngine:pauseAllSound()
		gt.log("暂停音乐 222222")
		require("cjson")

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
		elseif gt.isAndroidPlatform() then
			local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "playVoice", {curUrl}, "(Ljava/lang/String;)V")
		end

		self.yuyinChatNode:setVisible(true)
		self.rootNode:reorderChild(self.yuyinChatNode, 110)

		local seatIdx = msgTbl.kPos + 1
		for i = 1, 4 do
			local chatBgImg = gt.seekNodeByName(self.yuyinChatNode, "Image_" .. i)
			chatBgImg:setVisible(false)
		end
		local roomPlayer = self.roomPlayers[seatIdx]
		if roomPlayer == nil then 
			gt.log("--------gt.socketClient:reloginServer1")
			gt.socketClient:reloginServer()				
			return
		end
		local chatBgImg = gt.seekNodeByName(self.yuyinChatNode, "Image_" .. roomPlayer.displaySeatIdx)
		chatBgImg:setVisible(true)
		self.yuyinChatNode:stopAllActions()
		local fadeInAction = cc.FadeIn:create(0.5)
		local delayTime = cc.DelayTime:create(videoTime or 5)
		local fadeOutAction = cc.FadeOut:create(0.5)
		local callFunc = cc.CallFunc:create(function(sender)
			if not self.isRecording then
				sender:setVisible(false)
				gt.soundEngine:resumeAllSound()
				gt.log("恢复音乐 333333")
			end
		end)
		self.yuyinChatNode:runAction(cc.Sequence:create(fadeInAction, delayTime, fadeOutAction, callFunc))
	else
		local chatBgNode = gt.seekNodeByName(self.rootNode, "Node_chatBg")
		chatBgNode:setVisible(true)
		local seatIdx = msgTbl.kPos + 1
		for i = 1, 4 do
			local chatBgImg = gt.seekNodeByName(chatBgNode, "Img_playerChatBg_" .. i)
			chatBgImg:setVisible(false)
		end
		local roomPlayer = self.roomPlayers[seatIdx]
		local chatBgImg = gt.seekNodeByName(chatBgNode, "Img_playerChatBg_" .. roomPlayer.displaySeatIdx)
		chatBgImg:setVisible(true)
		local emojiImg = gt.seekNodeByName(chatBgNode, "Image_Emoji_" .. roomPlayer.displaySeatIdx)
		emojiImg:setVisible(false)
		local msgLabel = gt.seekNodeByName(chatBgImg, "Label_msg")
		local emojiSpr = gt.seekNodeByName(chatBgImg, "Spr_emoji")
		local isTextMsg = false
		if msgTbl.kType == gt.ChatType.FIX_MSG then
			emojiImg:setVisible(false)
			local  talk = {}
			local chat = roomPlayer.nickname .. "说：" .. gt.getLocationString("LTKey_0028_" .. msgTbl.kId)
			talk.content = chat
			talk.abstract = gt.getLocationString("LTKey_0028_" .. msgTbl.kId)
			if #self.ChatLog > 49 then
				table.remove(self.ChatLog,1)
			end
			table.insert(self.ChatLog,talk) 
			if msgTbl.kId==100 then
			   msgLabel:setString("抱歉,刚接了个电话")
			else
			   msgLabel:setString(gt.getLocationString("LTKey_0028_" .. msgTbl.kId))   
			end
			isTextMsg = true

			-- dj revise
			gt.soundManager:PlayFixSound(roomPlayer.sex, msgTbl.kId)
			if self.animationNode then
				chatBgNode:removeChild(self.animationNode)
			end
			-- if roomPlayer.sex == 1 then
			-- 	-- 男性
			-- 	gt.soundEngine:playEffect("man/fix_msg_" .. msgTbl.m_id)
			-- else
			-- 	-- 女性
			-- 	gt.soundEngine:playEffect("woman/fix_msg_" .. msgTbl.m_id)
			-- end
		elseif msgTbl.kType == gt.ChatType.INPUT_MSG then
			emojiImg:setVisible(false)
			msgLabel:setString(msgTbl.kMsg)
			isTextMsg = true
			if #self.ChatLog > 49 then
				table.remove(self.ChatLog,1)
			end
			local talk =  {}
			local chat = roomPlayer.nickname .. "说：" ..  msgTbl.kMsg
			talk.content = chat
			talk.abstract = msgTbl.kMsg
			table.insert(self.ChatLog,talk) 
			if self.animationNode then
				chatBgNode:removeChild(self.animationNode)
			end
		elseif msgTbl.kType == gt.ChatType.EMOJI then
			gt.log("播放动画表情 =========== ")
			chatBgImg:setVisible(false)

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
			gt.log("EmotionName:" .. picStr)
			local animationStr = "res/animation/biaoqing/"..picStr.."/".. picStr .. ".csb"
			gt.log("---------------animationStr", animationStr)
			local animationNode, animationAction = gt.createCSAnimation(animationStr)
			gt.log("---------------animationStr", animationStr)
			animationAction:play("run", false)
			gt.log("---------------animationStr", animationStr)
			animationNode:setPosition(emojiImg:getPosition())
			self.animationNode = animationNode
			self.animationAction = animationAction
			-- animationNode:setScale(0.6)
			chatBgNode:addChild(animationNode)
			
			-- local chatBgNode_delayTime = cc.DelayTime:create(3)
			-- local chatBgNode_callFunc = cc.CallFunc:create(function(sender)
			-- 	chatBgNode:removeChild(animationNode)
			-- 	display.removeSpriteFrames("biaoqingbao/biaoqing.plist","biaoqingbao/biaoqing.png")
			-- end)
			-- local chatBgNode_Sequence = cc.Sequence:create(chatBgNode_delayTime, 
			-- 											 chatBgNode_callFunc)
			-- chatBgNode:runAction(chatBgNode_Sequence)

			
			isTextMsg = false
		elseif msgTbl.kType == gt.ChatType.VOICE_MSG then
		end

		msgLabel:setVisible(isTextMsg)
		emojiSpr:setVisible(not isTextMsg)
		local chatBgSize = chatBgImg:getContentSize()
		local bgWidth = chatBgSize.width
		if isTextMsg then
			local labelSize = msgLabel:getContentSize()
			bgWidth = labelSize.width + 30
			msgLabel:setPositionX(bgWidth * 0.5)
		else
			local emojiSize = emojiSpr:getContentSize()
			bgWidth = emojiSize.width + 50
			emojiSpr:setPositionX(bgWidth * 0.5)
		end
		chatBgImg:setContentSize(cc.size(bgWidth, chatBgSize.height))

		chatBgNode:stopAllActions()
		local fadeInAction = cc.FadeIn:create(0.5)
		local delayTime = cc.DelayTime:create(1)
		local fadeOutAction = cc.FadeOut:create(0.5)
		local callFunc = cc.CallFunc:create(function(sender)
			sender:setVisible(false)
		end)
		chatBgNode:runAction(cc.Sequence:create(fadeInAction, delayTime, fadeOutAction, callFunc))
	end
end

function MJScene:callbackNextReady( )
	gt.log("-----------------------callbackNextReady")
	local backBtn = gt.seekNodeByName(self.rootNode, "Btn_back")
	--backBtn:setEnabled(false)

	local allDelayTimy = self.reportDelayTime -- 需要延迟的时间,如果存在海底牌,需要将海底牌展示结束方可
	if self.haveHaidiPai then
		allDelayTimy = allDelayTimy + self.haidCardShowTime
	end
	if self.m_isZhaNiao then
		allDelayTimy = allDelayTimy + self.m_zhaNiaoTime
	end
	allDelayTimy = allDelayTimy + self.huAnimationTime
	
	-- 显示准备按钮
	local readyBtn = gt.seekNodeByName(self.rootNode, "Btn_ready")
	readyBtn:setVisible(true)

	-- 停止未完成动作
	if self.startMjTileAnimation ~= nil then
		self.startMjTileAnimation:stopAllActions()
		self.startMjTileAnimation:removeFromParent()
		self.startMjTileAnimation = nil
	end

	-- csw 11-14 
	self.haoziGang = false
	-- csw 11-14 

	-- 停止倒计时音效
	self.playTimeCD = nil
	--如果有耗子牌，把存储的耗子牌重置了
	if self.HaoZiCards then
		self.HaoZiCards = nil
		gt.log("耗子牌重置")
	end
	-- 移除所有麻将
	self.playMjLayer:removeAllChildren()

	-- 玩家准备手势隐藏
	-- self:hidePlayersReadySign()

	-- 隐藏座次标识
	local turnPosLayerSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosLayer")
	-- turnPosLayerSpr:setTexture("res/images/otherImages/turn_pos_bg_new.png")
	-- turnPosLayerSpr:setVisible(false)

	-- 隐藏牌局状态
	local roundStateNode = gt.seekNodeByName(self.rootNode, "Node_roundState")
	roundStateNode:setVisible(false)
	self.Image_tilesCount:setVisible(false)

	-- 隐藏倒计时
	self.playTimeCDLabel:setVisible(false)

	-- 隐藏出牌标识
	self.outMjtileSignNode:setVisible(false)

	-- 隐藏决策
	local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
	decisionBtnNode:setVisible(false)

	local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
	selfDrawnDcsNode:setVisible(false)

	local nodeDabao = gt.seekNodeByName(self.rootNode, "Node_dabao")
	nodeDabao:setVisible(false)

	local Image_logo = gt.seekNodeByName(self.rootNode, "Image_logo")
	Image_logo:setVisible(true)

	-- 听标识
	for i=1,4 do
		local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. i)
		local tingSignSpr = gt.seekNodeByName(playerInfoNode, "spr_ting")
		tingSignSpr:setVisible(false)
	end
end

function MJScene:onRcvRoundReport(msgTbl)
	gt.log("收到单局结算消息")


	--print("num................",self.m_gamePlayerCount)

	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)

		gt.dumplog(self.roomPlayers)
	end
	
	self.chutaiShowFlag = false
	self.RoundStart = false

	for i = 1, 4 do
		if self.m_clockLabel[i] then
		    self.m_clockLabel[i]:setString("")
		    self.m_clockLabel[i]:setVisible(false)
			self.m_TimeProgress[i]:setPercentage(0)
			self.m_TimeProgress[i]:stopAllActions()
			self.clockSprite[i]:setVisible(false)
	        if self._time[i] then
	            gt.scheduler:unscheduleScriptEntry(self._time[i])
	            self._time[i] = nil
	        end
			cc.UserDefault:getInstance():setIntegerForKey("ClockTime"..i, 0)
		end
	end
	
	local roomPlayer = self.roomPlayers[1]
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	if mjTilesReferPos then
		for i = 1, self.playersType do
			local seatIdx = i
			local roundResult = msgTbl.kWin[seatIdx]
			if not(roundResult == 1 or roundResult == 2 or roundResult == 4 or roundResult == 8 or roundResult == 9 or roundResult == 10) then
				-- 输了(没胡或者点炮)
				local tileList = {}
				for i, v in ipairs(msgTbl["kArray" .. (i - 1)]) do
					if v[1] == 4 then
						table.insert(tileList, v)
					else
						table.insert(tileList, v)
					end
				end

				local finalList = {}
				
				if self.isHZLZ == true then
					for _, v in ipairs(tileList) do
						if v[1] == 4 and v[2] == 5 then
							table.insert(finalList,1, v)
						else
							table.insert(finalList, v)
						end
					end
				else
					finalList = tileList
				end
				gt.log("-----------------------showAllMjTilesWhenWin")
				self:showAllMjTilesWhenWin(seatIdx, #finalList, finalList)
			end
		end
	end

	self.showHuCardsList  = {}

	local curRoomPlayers = {}
	curRoomPlayers = self:copyTab(self.roomPlayers)

	local function callbackFinal( )
		if self.finalReport then
			self.finalReport:setVisible(true)
			self.finalReport:playAnimation()
		end
	end

	local function callbackNext( )
		gt.log("-----------------------callbackNext")

		if self.finalReport then
			self.finalReport:setVisible(true)
			self.finalReport:playAnimation()
		end
		
		local backBtn = gt.seekNodeByName(self.rootNode, "Btn_back")

		local allDelayTimy = self.reportDelayTime -- 需要延迟的时间,如果存在海底牌,需要将海底牌展示结束方可
		if self.haveHaidiPai then
			allDelayTimy = allDelayTimy + self.haidCardShowTime
		end
		if self.m_isZhaNiao then
			allDelayTimy = allDelayTimy + self.m_zhaNiaoTime
		end
		allDelayTimy = allDelayTimy + self.huAnimationTime
		
		-- 显示准备按钮
		local readyBtn = gt.seekNodeByName(self.rootNode, "Btn_ready")
		readyBtn:setVisible(true)

		-- 停止未完成动作
		if self.startMjTileAnimation ~= nil then
			self.startMjTileAnimation:stopAllActions()
			self.startMjTileAnimation:removeFromParent()
			self.startMjTileAnimation = nil
		end

		-- 停止倒计时音效
		self.playTimeCD = nil
		--如果有耗子牌，把存储的耗子牌重置了
		if self.HaoZiCards then
			self.HaoZiCards = nil
			gt.log("耗子牌重置")
		end
	

		-- 移除所有麻将
		self.playMjLayer:removeAllChildren()
		self.stateFlag = false

		-- 玩家准备手势隐藏
		-- self:hidePlayersReadySign()

		-- 下一局开局动话延迟时间
		self.delayTime = 0
		
		-- 隐藏座次标识
		local turnPosLayerSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosLayer")
		-- turnPosLayerSpr:setTexture("res/images/otherImages/turn_pos_bg_new.png")
		-- turnPosLayerSpr:setVisible(false)

		-- 隐藏牌局状态
		local roundStateNode = gt.seekNodeByName(self.rootNode, "Node_roundState")
		roundStateNode:setVisible(false)
		self.Image_tilesCount:setVisible(false)

		-- 隐藏倒计时
		self.playTimeCDLabel:setVisible(false)

		-- 隐藏出牌标识
		self.outMjtileSignNode:setVisible(false)

		-- 隐藏决策
		local decisionBtnNode = gt.seekNodeByName(self.rootNode, "Node_decisionBtn")
		decisionBtnNode:setVisible(false)

		local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
		selfDrawnDcsNode:setVisible(false)

		local nodeDabao = gt.seekNodeByName(self.rootNode, "Node_dabao")
		nodeDabao:setVisible(false)

		local Image_logo = gt.seekNodeByName(self.rootNode, "Image_logo")
		Image_logo:setVisible(true)

		-- 听标识
		for i=1,4 do
			local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. i)
			local tingSignSpr = gt.seekNodeByName(playerInfoNode, "spr_ting")
			tingSignSpr:setVisible(false)
		end
	end

	self.stateFlag = true
	-- 弹出局结算界面
	local rulsData = {}
	rulsData.m_state = self.playType
	rulsData.playTypes = self.m_playtype

	msgTbl.kZhuangPos = self.bankerSeatIdx
	
		-- csw 11 -25 
		gt.dump(msgTbl)
		gt.log("收到结算————————————————————————————————")
		local hu = false
		if self.roomPlayers and msgTbl then
			for seatIdx, roomPlayer in ipairs(self.roomPlayers) do
				local ishu=  msgTbl.kWin[seatIdx]
				if ishu == 1 or ishu == 2 or ishu == 4 or ishu == 8 or ishu == 9 or ishu == 10 then
					hu = true
					break
				end
			end
		end

		gt.log("ishu",hu)
		self.isduanxian = false -- 控制断线 后小结算面板 影响总结算面板的显示
		if hu then 
			-- 借用
			self.__hupai = true
			local node =  gt.seekNodeByName(self.rootNode, "Node_dabao")	
			node:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
				if msgTbl.kEnd == 0 then -- 不是最后一局
		
					if self.roundReport == nil then
						self.roundReport = require("client/game/majiang/RoundReport"):create(callbackFinal, callbackNext, self.roomPlayers, self.playerSeatIdx, msgTbl, msgTbl.kEnd, self.isHZLZ)
						self:addChild(self.roundReport, MJScene.ZOrder.ROUND_REPORT)
					else
						self.roundReport:updata(self.roomPlayers, self.playerSeatIdx, msgTbl, msgTbl.kEnd, self.isHZLZ)
						self.roundReport:setDisplay(true)
					end
			
				else
					if self.roundReport == nil then
						self.roundReport = require("client/game/majiang/RoundReport"):create(callbackFinal, callbackNext, curRoomPlayers, self.playerSeatIdx, msgTbl, msgTbl.kEnd, self.isHZLZ)
						self:addChild(self.roundReport, MJScene.ZOrder.ROUND_REPORT)
					else
						self.roundReport:updata(curRoomPlayers, self.playerSeatIdx, msgTbl, msgTbl.kEnd, self.isHZLZ)
						self.roundReport:setDisplay(true)
					end
				end

			end)))
		else

		-- csw 11 -25
			self.__hupai = false
			if msgTbl.kEnd == 0 then -- 不是最后一局
				if self.roundReport == nil then
					self.roundReport = require("client/game/majiang/RoundReport"):create(callbackFinal, callbackNext, self.roomPlayers, self.playerSeatIdx, msgTbl, msgTbl.kEnd, self.isHZLZ)
					self:addChild(self.roundReport, MJScene.ZOrder.ROUND_REPORT)
				else
					self.roundReport:updata(self.roomPlayers, self.playerSeatIdx, msgTbl, msgTbl.kEnd, self.isHZLZ)
					self.roundReport:setDisplay(true)
				end
			else
				if self.roundReport == nil then
					self.roundReport = require("client/game/majiang/RoundReport"):create(callbackFinal, callbackNext, curRoomPlayers, self.playerSeatIdx, msgTbl, msgTbl.kEnd, self.isHZLZ)
					self:addChild(self.roundReport, MJScene.ZOrder.ROUND_REPORT)
				else
					self.roundReport:updata(curRoomPlayers, self.playerSeatIdx, msgTbl, msgTbl.kEnd, self.isHZLZ)
					self.roundReport:setDisplay(true)
				end
			end

		end

	-- end
	-- self.showReportScheduler = gt.scheduler:scheduleScriptFunc(showReport, 1, false)
-- 	self.lastRound = false
		
	--csw 11-13 

	if self.haoziGang then 
		self:addAction11_9_node(1,4000)
	end

	
		
	self.haoziGang = false
        
	--csw 11-13 

    --查看胡牌按钮
	local tinghuBtn = gt.seekNodeByName(self.rootNode, "Btn_tinghu")
	tinghuBtn:setVisible(false)
end

function MJScene:copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
end

function MJScene:onRcvFinalReport(msgTbl)
	self.FinalReportFlag = true
  	gt.CreateRoomFlag = false
	gt.log("收到最终结算消息")
	--dump(msgTbl)

	

	for i = 1, 4 do
		if self.m_clockLabel[i] then
		    self.m_clockLabel[i]:setString("")
		    self.m_clockLabel[i]:setVisible(false)
			self.m_TimeProgress[i]:setPercentage(0)
			self.m_TimeProgress[i]:stopAllActions()
			self.clockSprite[i]:setVisible(false)
	        if self._time[i] then
	            gt.scheduler:unscheduleScriptEntry(self._time[i])
	            self._time[i] = nil
	        end
			cc.UserDefault:getInstance():setIntegerForKey("ClockTime"..i, 0)
		end
	end

	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
		gt.dumplog(self.roomPlayers)
	end

	if self.timerWriteLogScheduler then
		gt.scheduler:unscheduleScriptEntry(self.timerWriteLogScheduler)
		self.timerWriteLogScheduler = nil
	end

	msgTbl.kBaseScore = self.baseScore
	msgTbl.kMaxCircle = self.roundMaxCount
	self.lastRound = true
	local curRoomPlayers = {}
	curRoomPlayers = self:copyTab(self.roomPlayers)

	local allDelayTimy = self.reportDelayTime+0.5
	-- 如果是海底牌的话,最后一局,需要多等1.5秒,然后展示总结算
	if self.haveHaidiPai then
		allDelayTimy = allDelayTimy + self.haidCardShowTime
	end
	if self.m_isZhaNiao then
		allDelayTimy = allDelayTimy + self.m_zhaNiaoTime
	end
	allDelayTimy = allDelayTimy + self.huAnimationTime
	allDelayTimy = 0


	if self.__hupai then 
		allDelayTimy = 1
	else
		allDelayTimy = 0
	end
	local delayTime = cc.DelayTime:create( allDelayTimy )
	local callFunc = cc.CallFunc:create(function(sender)
	    -- 弹出总结算界面
		self.finalReport = require("client/game/majiang/FinalReport"):create(curRoomPlayers, msgTbl, self.isSport, self)
		self:addChild(self.finalReport, MJScene.ZOrder.REPORT)
		if self.roundReport == nil then
			self.finalReport:setVisible(false)
		else
			if self.roundReport:isVisible() then
				self.finalReport:setVisible(false)
			else
				self.finalReport:setVisible(true)
			end
		end
		if self.isduanxian then 
			self.finalReport:setVisible(true)
		end
 	end)

	local seqAction = cc.Sequence:create(delayTime, callFunc)
	self:runAction(seqAction)

    --查看胡牌按钮
	local tinghuBtn = gt.seekNodeByName(self.rootNode, "Btn_tinghu")
	tinghuBtn:setVisible(false)
end

-- 扎鸟
function MJScene:onRcvZhaNiao(msgTbl)
	-- Lint m_end_pos //从哪里播放鸟飞动画
	-- array{
	--     int m_pos;//鸟飞的位置
	--     cardvalue m_card;//鸟牌
	-- }

	-- 屏蔽二三人转转的抓鸟玩法
	if self.playersType == 2 then
		do return end
	end

	gt.log("onRcvZhaNiao")
	self.m_isZhaNiao = true
	self.m_zhaNiaoTime = 3.5
	local curRoomPlayers = {}
	curRoomPlayers = self:copyTab(self.roomPlayers)
	local layer = cc.Layer:create()
	local delayTime = cc.DelayTime:create(1.5)
	local callFunc = cc.CallFunc:create(function(sender)
		-- --dump(msgTbl.m_bird_infos)
		table.foreach(msgTbl.kBird_infos, function(i, bird)
			local seatIdx = bird[1] + 1
			local card = bird[2]

			-- 可飞空 但是仍然需要显示牌
			local sprite = self:addAlreadyOutMjTilesByCopy(
				msgTbl.
				_pos + 1, card[1], card[2], curRoomPlayers[msgTbl.kEnd_pos + 1])
			sprite:setColor(cc.c3b(243,243,10))

			if seatIdx > 0 then
				local roomPlayer = curRoomPlayers[seatIdx]
				if roomPlayer == nil then
					do return end
				end

				local displaySeatIdx = roomPlayer.displaySeatIdx
				gt.log("displaySeatIdx = " , displaySeatIdx)
				local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. displaySeatIdx)
				self:birdFly(layer, display.cx, display.cy, playerInfoNode:getPositionX(), playerInfoNode:getPositionY())
			end
		end)
	end)
	local seqAction = cc.Sequence:create(delayTime, callFunc)
	layer:runAction(seqAction)

	local csbNode = nil
	local action = nil
	local actionName = nil
	if self.playType == 6 then
		csbNode, action = gt.createCSAnimation("zhama.csb")
		actionName = "zhama"
		csbNode:setPosition(cc.p(gt.winCenter.x, 300))
	else
		csbNode, action = gt.createCSAnimation("zhuaniao.csb")
		actionName = "zhuaniao"
	end
	action:play(actionName, false)
	self:addChild(csbNode)
	self:addChild(layer)
end

function MJScene:birdFly(layer, x, y, ex, ey)
	local x = x
	local y = y
	local ex = ex
	local ey = ey + 50
	local time = 0.6
	local scale = 0.5
	
    local bird = cc.Sprite:create("res/images/otherImages/niao.png")
    bird:setScale(scale)
    bird:setPosition(cc.p(x, y))
    local function birdCallback()
    	bird:removeFromParent()

    	local birdFly, action = gt.createCSAnimation("effect/BirdFly.csb")
    	action:play("run", false)
    	birdFly:setPosition(cc.p(ex, ey))
    	birdFly:setScale(2.5)
    	layer:addChild(birdFly)

    	local delayTime = cc.DelayTime:create(action:getEndFrame() / 60)
		local callFunc = cc.CallFunc:create(function(sender)
			sender:removeFromParent()
		end)
		local seqAction = cc.Sequence:create(delayTime, callFunc)
		birdFly:runAction(seqAction)
    end
    local action = cc.MoveTo:create(time, cc.p(ex, ey))
    local callFunc = cc.CallFunc:create(birdCallback)
	local seqAction = cc.Sequence:create(action, callFunc)
    bird:runAction(seqAction)
    layer:addChild(bird, 1000)

    local emitter = cc.ParticleSystemQuad:create("res/particles/Flower.plist")
    emitter:setPosition(cc.p(x, y))
	local function flowerCallback()
    	emitter:removeFromParent()
    end
    local action = cc.MoveTo:create(time, cc.p(ex, ey))
    local callFunc = cc.CallFunc:create(flowerCallback)
	local seqAction = cc.Sequence:create(action, callFunc)
    emitter:runAction(seqAction)
    layer:addChild(emitter, 999)
    return true
end
-- start --
--------------------------------
-- @class function
-- @description 更新当前时间
-- end --   
function MJScene:updateCurrentTime()
	local timeLabel = gt.seekNodeByName(self.rootNode, "Label_time")
    timeLabel:setString(os.date("%H:%M"))
end

-- start --
--------------------------------
-- @class function
-- @description 房间清空未选座玩家
-- @param roomPlayer 玩家信息
-- end --
function MJScene:roomClearUnSeatPlayers()
	gt.log("房间清空未选座玩家")
	
	self.unSeatRoomPlayers = {}
	self.unSeatRoomPlayersIdx = {}

	for i = 1, 4 do
		-- 隐藏玩家信息
		local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_unSeatPlayerInfo_" .. i)
		playerInfoNode:setVisible(false)

		-- 取消头像下载监听
		local headSpr = gt.seekNodeByName(playerInfoNode, "Spr_head")
		self.playerHeadMgr:detach(headSpr)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 房间添加未选座玩家
-- @param roomPlayer 玩家信息
-- end --
function MJScene:roomAddUnSeatPlayer(roomPlayer)
	gt.log("房间添加未选座玩家")
	gt.dump(roomPlayer)

	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_unSeatPlayerInfo_" .. roomPlayer.unSeatIdx)
	playerInfoNode:setVisible(true)
	-- 头像
	local headSpr = gt.seekNodeByName(playerInfoNode, "Spr_head")
	local headFrameBtn = gt.seekNodeByName(playerInfoNode, "Btn_headFrame")
	self.playerHeadMgr:attach(headSpr, headFrameBtn, roomPlayer.uid, roomPlayer.headURL, roomPlayer.sex, true)
	
	-- 昵称
	local nicknameLabel = gt.seekNodeByName(playerInfoNode, "Label_nickname")

	-- 名字只取四个字,并且清理掉其中的空格
	local nickname = string.gsub(roomPlayer.nickname," ","")
	nickname = string.gsub(nickname,"　","")
	nicknameLabel:setString(nickname)

	-- 点击头像显示信息
	local headFrameBtn = gt.seekNodeByName(playerInfoNode, "Btn_headFrame")
	headFrameBtn:setTag(roomPlayer.uid)
	headFrameBtn:addClickEventListener(handler(self, self.showUnSeatPlayerInfo))

	self.mapRoomPlayers[roomPlayer.uid] = roomPlayer
 end

-- start --
--------------------------------
-- @class function
-- @description 房间移除未选座玩家
-- @param roomPlayer 玩家信息
-- end --
function MJScene:roomRemoveUnSeatPlayers(msgTbl)
	gt.log("房间移除未选座玩家")
	gt.dump(msgTbl)
	gt.dump(self.unSeatRoomPlayers)
	local function roomRemoveUnSeatPlayer(m_userId)
	gt.log("----------m_userId1", m_userId)
		local roomPlayer = self.unSeatRoomPlayers[m_userId]
	gt.dump(roomPlayer)
		if roomPlayer then
	gt.log("----------m_userId2", m_userId)
			-- 隐藏玩家信息
			local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_unSeatPlayerInfo_" .. roomPlayer.unSeatIdx)
			playerInfoNode:setVisible(false)

			-- 取消头像下载监听
			local headSpr = gt.seekNodeByName(playerInfoNode, "Spr_head")
			self.playerHeadMgr:detach(headSpr)
		end
	end

	for i = 1, 4 do
		if self.unSeatRoomPlayersIdx[i] then
			roomRemoveUnSeatPlayer(self.unSeatRoomPlayersIdx[i])
		end
	end
	-- 去除数据
	self.unSeatRoomPlayers[msgTbl.kUserId] = nil
	for i = 1, #self.unSeatRoomPlayersIdx do
		if self.unSeatRoomPlayersIdx[i] == msgTbl.kUserId then
			gt.log("----------i", i)
			table.remove(self.unSeatRoomPlayersIdx, i)
		end
	end

	for i = 1, #self.unSeatRoomPlayersIdx do
		self.unSeatRoomPlayers[self.unSeatRoomPlayersIdx[i]].unSeatIdx = i
		self:roomAddUnSeatPlayer(self.unSeatRoomPlayers[self.unSeatRoomPlayersIdx[i]])
	end
end

-- start --
--------------------------------
-- @class function
-- @description 房间添加玩家
-- @param roomPlayer 玩家信息
-- end --
function MJScene:roomAddPlayer(roomPlayer)
	gt.log("房间添加玩家")
	gt.dump(roomPlayer)
	gt.log("----------------------self.seatOffset", self.seatOffset)
	gt.log("----------------------roomPlayer.displaySeatIdx", roomPlayer.displaySeatIdx)
	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displaySeatIdx)
	playerInfoNode:setVisible(true)
	-- 头像
	local headSpr = gt.seekNodeByName(playerInfoNode, "Spr_head")
	local headFrameBtn = gt.seekNodeByName(playerInfoNode, "Btn_headFrame")
	self.headSpr[roomPlayer.displaySeatIdx] = self.playerHeadMgr:attach(headSpr, headFrameBtn, roomPlayer.uid, roomPlayer.headURL, roomPlayer.sex, true)
	

	self.clockSprite[roomPlayer.displaySeatIdx] = gt.seekNodeByName(playerInfoNode, "Sprite_clock")
	self.clockSprite[roomPlayer.displaySeatIdx]:setVisible(false)
	self.m_clockFrameSprite[roomPlayer.displaySeatIdx] = cc.Sprite:createWithSpriteFrameName("sx_img_head_frame.png")

	if self.m_TimeProgress[roomPlayer.displaySeatIdx] then
		self.m_TimeProgress[roomPlayer.displaySeatIdx]:removeFromParent()
		self.m_TimeProgress[roomPlayer.displaySeatIdx] = nil
	end
	self.m_TimeProgress[roomPlayer.displaySeatIdx] = cc.ProgressTimer:create(self.m_clockFrameSprite[roomPlayer.displaySeatIdx])
	 :addTo(self.clockSprite[roomPlayer.displaySeatIdx])
     :setReverseDirection(true)
     :setScaleX(-1)
     :setAnchorPoint(ccp(0.5,0.5))
     :setPosition(cc.p(self.clockSprite[roomPlayer.displaySeatIdx]:getContentSize().width/2, self.clockSprite[roomPlayer.displaySeatIdx]:getContentSize().height/2))
     :setVisible(false)
     :stopAllActions()
     :setPercentage(0)

	-- self.m_clockMaskSprite[roomPlayer.displaySeatIdx] = cc.Sprite:create("res/images/otherImages/common_trans.png")
	-- -- self.m_clockMaskSprite[roomPlayer.displaySeatIdx] = cc.Sprite:createWithSpriteFrameName("sx_img_head_mask.png")
	-- :addTo(headFrameBtn)
 --    :setAnchorPoint(ccp(0,0))

    self.m_clockLabel[roomPlayer.displaySeatIdx] = gt.seekNodeByName(playerInfoNode, "Label_clock")
    self.m_clockLabel[roomPlayer.displaySeatIdx]:setString("")
    self.m_clockLabel[roomPlayer.displaySeatIdx]:setVisible(false)

    if self._time[roomPlayer.displaySeatIdx] then
        gt.scheduler:unscheduleScriptEntry(self._time[roomPlayer.displaySeatIdx])
        self._time[roomPlayer.displaySeatIdx] = nil
    end

	-- 昵称
	local nicknameLabel = gt.seekNodeByName(playerInfoNode, "Label_nickname")
	-- 名字只取四个字,并且清理掉其中的空格
	local nickname = string.gsub(roomPlayer.nickname," ","")
	nickname = string.gsub(nickname,"　","")
	-- nicknameLabel:setString(gt.checkName(nickname))
	nicknameLabel:setString(nickname)
	-- nicknameLabel:setString(roomPlayer.seatIdx)

	-- 积分
	local scoreLabel = gt.seekNodeByName(playerInfoNode, "Label_score")
	scoreLabel:setString(tostring(roomPlayer.score))
	roomPlayer.scoreLabel = scoreLabel
	-- 离线标示
	local offLineSignSpr = gt.seekNodeByName(playerInfoNode, "Spr_offLineSign")
	offLineSignSpr:setVisible(false)
	-- 庄家
	local bankerSignSpr = gt.seekNodeByName(playerInfoNode, "Spr_bankerSign")
	bankerSignSpr:setVisible(false)
	-- 听标识
	local tingSignSpr = gt.seekNodeByName(playerInfoNode, "spr_ting")
	tingSignSpr:setVisible(false)
	-- 点击头像显示信息
	local headFrameBtn = gt.seekNodeByName(playerInfoNode, "Btn_headFrame")
	headFrameBtn:setTag(roomPlayer.seatIdx)
	headFrameBtn:addClickEventListener(handler(self, self.showPlayerInfo))
    
	-- 添加入缓冲
	self.roomPlayers[roomPlayer.seatIdx] = roomPlayer
	-- self:setVideoInfo()

	gt.log("--------------------roomPlayer.readyState", roomPlayer.readyState)
	-- 准备标示
	if roomPlayer.readyState == 1 then
		self:playerGetReady(roomPlayer.seatIdx)
		gt.log("--------------------roomPlayer.uid", roomPlayer.uid)
		gt.log("--------------------gt.playerData.uid", gt.playerData.uid)
		if roomPlayer.uid == gt.playerData.uid then
			gt.log("--------------------roomPlayer.uid == gt.playerData.uid")
			self.selectedseat = true
		end
	end

	-- 如果已经四个人了,隐藏微信分享按钮,显示聊天,设置按钮
	local playerCount = 0
	for k, v in pairs(self.roomPlayers) do
		if v.seatIdx == 1 then	
			self.m_fangzhuPos = k
		end
		if v then
			playerCount = playerCount + 1
		end
	end
	-- if playerCount == self.numPlayer then
	-- 	local readyPlayNode = gt.seekNodeByName(self.rootNode, "Node_readyPlay")
	-- 	readyPlayNode:setVisible(false)
	-- end
 end

-- start --
--------------------------------
-- @class function
-- @description 玩家自己进入房间
-- @param msgTbl 消息体
-- end --

function MJScene:playerEnterRoom(msgTbl)
	gt.log("玩家进入房间 =============== ")

	gt.dump(msgTbl)
	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(msgTbl)
	end
	self:clearPlayers()
	-- 房间中的玩家
	self.roomPlayers = {} --用座位号作为Index存储用户
	-- 房间中清空未入坐的玩家
	self:roomClearUnSeatPlayers()
	self.roomPlayersByUid = {}   --用uid作为Index存储用户
	-- 玩家自己放入到房间玩家中
	local roomPlayer = {}
	roomPlayer.uid = gt.playerData.uid
	roomPlayer.nickname = gt.playerData.nickname
	roomPlayer.headURL = gt.playerData.headURL
	roomPlayer.sex = gt.playerData.sex
	roomPlayer.ip = msgTbl.kUserIp--gt.playerData.ip
	roomPlayer.seatIdx = msgTbl.kPos + 1
	-- 玩家座位显示位置
	roomPlayer.displaySeatIdx = 4
	roomPlayer.readyState = msgTbl.kReady
	roomPlayer.score = msgTbl.kScore
	roomPlayer.createUserId = msgTbl.kCreateUserId
	roomPlayer.m_videoPermission  = msgTbl.kVideoPermission
	roomPlayer.m_userGps  = msgTbl.kUserGps

	gt.headURL = roomPlayer.headURL
	gt.nickname = roomPlayer.nickname
	
	--显示方位
	self:showPosition()

	-- 添加入缓冲
	self.unSeatRoomPlayers[roomPlayer.uid] = roomPlayer
	local addUnSeatRoomPlayerFlag = true
	for i = 1, #self.unSeatRoomPlayersIdx do
		if self.unSeatRoomPlayersIdx[i] == roomPlayer.uid then
			addUnSeatRoomPlayerFlag = false
			break
		end
	end
	if addUnSeatRoomPlayerFlag == true then 
		table.insert(self.unSeatRoomPlayersIdx, roomPlayer.uid)
	end
	for i = 1, #self.unSeatRoomPlayersIdx do
		if self.unSeatRoomPlayersIdx[i] == roomPlayer.uid then
			self.unSeatRoomPlayers[self.unSeatRoomPlayersIdx[i]].unSeatIdx = i
			self:roomAddUnSeatPlayer(self.unSeatRoomPlayers[self.unSeatRoomPlayersIdx[i]])
		end
	end
	-- self.roomPlayersByUid[roomPlayer.uid] = roomPlayer
	self:setVideoInfo()

	-- 房间编号
	self.roomID = msgTbl.kDeskId
	gt.log("----------------------------------玩家进入房间roomPlayer.seatIdx", roomPlayer.seatIdx)
	-- 玩家座位编号
	self.playerSeatIdx = roomPlayer.seatIdx
	gt.playerSeatIdx = self.playerSeatIdx
	-- 玩家显示固定座位号
	self.playerFixDispSeat = 4
	gt.log("----------------------------------self.seatIdx", roomPlayer.seatIdx)
	-- 逻辑座位和显示座位偏移量(从0编号开始)
	local seatOffset = self.playerFixDispSeat - msgTbl.kPos
	if self.seatOffset == nil then
		self.seatOffset = 0
	end
	if seatOffset > 0 then
		self.seatOffset = seatOffset
	end
	-- 旋转座次标识
	local turnPosLayerSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosLayer")
	-- turnPosLayerSpr:setTexture("res/images/otherImages/turn_pos_bg_new.png")
	-- turnPosLayerSpr:setVisible(true)
	-- turnPosLayerSpr:setRotation(-seatOffset * 90)
	-- turnPosLayerSpr:setRotation(-((self.seatOffset) * 90))
	-- for _, turnPosTipSpr in ipairs(turnPosLayerSpr:getChildren()) do
	-- 	turnPosTipSpr:setVisible(false)
	-- 	-- turnPosTipSpr:setRotation(-seatOffset * 90)
	-- end
	for i = 1, 4 do
		gt.seekNodeByName(turnPosLayerSpr, "Spr_turnPosTip_" .. i):setVisible(false)
	end
	
	--座位方向图隐藏
    if self.positionTurnAnimateNode then
	    local turnPosLayerSpr = gt.seekNodeByName(self.csbNode,"Spr_turnPosLayer")
	    turnPosLayerSpr:setVisible(true)
		self.positionTurnAnimateNode:removeFromParent()
		self.positionTurnAnimateNode = nil
	end

	-- 玩家出牌类型
	self.isPlayerShow = false
	self.isPlayerDecision = false
	self.isTing = false
	--是否处于听牌这一手
	self.isBeingTing = false
	gt.log("听牌 444444 isBeingTing=",tostring(self.isBeingTing))

	if roomPlayer.readyState == 0 then
		-- 未准备显示准备按钮
		local readyBtn = gt.seekNodeByName(self.rootNode, "Btn_ready")
		readyBtn:setVisible(true)
	end

	local readyPlayNode = gt.seekNodeByName(self.rootNode, "Node_readyPlay")
	readyPlayNode:setVisible(true)

	--退出房间按钮
	local outRoomBtn = gt.seekNodeByName(self.rootNode, "Btn_outRoom")
	outRoomBtn:setEnabled(true)

	-- if roomPlayer.createUserId == gt.playerData.uid then
	-- 	self.readyPlay:setDimissRoomVisible(true)
	-- 	self.isCreateUser = true
	-- else
	-- 	self.readyPlay:setDimissRoomVisible(false)
	-- 	self.isCreateUser = false
	-- end

	if msgTbl.kPos < 4 then
		gt.log("----------------test1")
		if self.Label_tips[4] then
		gt.log("----------------test2")
			self.Label_tips[4]:setVisible(false)
			self:dynamicStartTipsShow(false)

			local tipsTimeLabel = gt.seekNodeByName(self.rootNode, "Label_tipsTime")
			tipsTimeLabel:setVisible(false)

			local Image_logo = gt.seekNodeByName(self.rootNode, "Image_logo")
			Image_logo:setVisible(true)
		end
	
		self.roomPlayers[msgTbl.kPos + 1] = self.unSeatRoomPlayers[roomPlayer.uid]
		msgTbl.kUserId = gt.playerData.uid
		self:roomRemoveUnSeatPlayers(msgTbl)

		-- self.roomPlayers[msgTbl.m_pos + 1] = self.roomPlayersByUid[roomPlayer.uid]

		-- if self.playersType == 2 then
		-- 		if self.roomPlayers[msgTbl.m_pos + 1].seatIdx == 1 then
		-- 			self.roomPlayers[msgTbl.m_pos + 1].displaySeatIdx = 4 - self.seatOffset <= 0 and 4 or 3
		-- 		elseif self.roomPlayers[msgTbl.m_pos + 1].seatIdx == 2 then
		-- 			self.roomPlayers[msgTbl.m_pos + 1].displaySeatIdx = 4 - self.seatOffset == 1 and 4 or 1
		-- 		end
		-- elseif self.playersType == 3 then
		-- 	if self.playerSeatIdx == 1 then
		-- 		if self.roomPlayers[msgTbl.m_pos + 1].seatIdx == 2 then
		-- 			self.roomPlayers[msgTbl.m_pos + 1].displaySeatIdx = 1
		-- 		elseif self.roomPlayers[msgTbl.m_pos + 1].seatIdx == 3 then
		-- 			self.roomPlayers[msgTbl.m_pos + 1].displaySeatIdx = 3
		-- 		end
		-- 	elseif self.playerSeatIdx == 2 then
		-- 		if self.roomPlayers[msgTbl.m_pos + 1].seatIdx == 3 then
		-- 			self.roomPlayers[msgTbl.m_pos + 1].displaySeatIdx = 1
		-- 		elseif self.roomPlayers[msgTbl.m_pos + 1].seatIdx == 1 then
		-- 			self.roomPlayers[msgTbl.m_pos + 1].displaySeatIdx = 3
		-- 		end
		-- 	elseif self.playerSeatIdx == 3 then
		-- 		if self.roomPlayers[msgTbl.m_pos + 1].seatIdx == 1 then
		-- 			self.roomPlayers[msgTbl.m_pos + 1].displaySeatIdx = 1
		-- 		elseif self.roomPlayers[msgTbl.m_pos + 1].seatIdx == 2 then
		-- 			self.roomPlayers[msgTbl.m_pos + 1].displaySeatIdx = 3
		-- 		end
		-- 	end
		-- else
			self.roomPlayers[msgTbl.kPos + 1].displaySeatIdx = (self.roomPlayers[msgTbl.kPos + 1].seatIdx - 1 + self.seatOffset) % 4 == 0 and 4 or (self.roomPlayers[msgTbl.kPos + 1].seatIdx - 1 + self.seatOffset) % 4
		-- end

		-- self:updatePlayer(gt.playerData.uid)
		-- 房间添加自己玩家
		self:roomAddPlayer(self.roomPlayers[msgTbl.kPos + 1])
		self:positionRotation(msgTbl)
		local Node_selectseat = gt.seekNodeByName(self.rootNode, "Node_selectseat")
		for i = 1, 4 do
			gt.seekNodeByName(Node_selectseat, "Position"..i.."_Btn"):setVisible(false)
		end
		if gt.isAppStoreInReview == false then
	   		self.yuyinBtn:setVisible(true)
		end
		self.messageBtn:setVisible(true)
	end
	self.mapRoomPlayers[roomPlayer.uid] = roomPlayer

	--动态开局提示和按钮状态
	if self.m_Greater2CanStart == 1 then
		if msgTbl.kStartButtonAppear then
			if msgTbl.kStartButtonAppear == 0 then
				self:setDynamicStartBtn(msgTbl)
			else
				self.dynamicStartBtn:setVisible(false)
				local readyPlayNode = gt.seekNodeByName(self.rootNode, "Node_readyPlay")
				readyPlayNode:setVisible(false)
			end
		end
	end
end

--选座方位旋转
function MJScene:positionRotation(msgTbl)
	gt.log("---------------------------------self.playerFixDispSeat", self.playerFixDispSeat)
	-- 玩家显示固定座位号
	self.playerFixDispSeat = 4
	-- 逻辑座位和显示座位偏移量(从0编号开始)
	local seatOffset = self.playerFixDispSeat - msgTbl.kPos
	self.seatOffset = seatOffset
	gt.log("---------------------------------msgTbl.kPos", msgTbl.kPos)
	gt.log("---------------------------------self.seatOffset", self.seatOffset)
	-- 旋转座次标识
	local turnPosLayerSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosLayer")
	-- turnPosLayerSpr:setTexture("res/images/otherImages/turn_pos_bg_new.png")
	-- turnPosLayerSpr:setVisible(true)
	gt.log("---------------------------------seatOffset", seatOffset)
	-- turnPosLayerSpr:setRotation(-((self.seatOffset) * 90))
	self.rotationFlag = true

	for i = 1, 4 do
		local index = (i + self.seatOffset)%4
		if index == 0 then index = 4 end
		gt.log("-------------------i", i)
		gt.log("-------------------index", index)
		local Spr_turnPosTip = gt.seekNodeByName(turnPosLayerSpr, "Spr_turnPosTip_"..i)
		Spr_turnPosTip:setPosition(MJScene.positionTip["positionTip"..index].x, MJScene.positionTip["positionTip"..index].y)
   		Spr_turnPosTip:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("sx_table_directBg"..index.."_position"..i..".png"))
	end

	-- for _, turnPosTipSpr in ipairs(turnPosLayerSpr:getChildren()) do
	-- 	turnPosTipSpr:setVisible(false)
	-- 	turnPosTipSpr:setRotation(-seatOffset * 90)
	-- end
end

-- start --
--------------------------------
-- @class function
-- @description 发送玩家准备请求消息
-- end --
function MJScene:readyBtnClickEvt()
	local readyBtn = gt.seekNodeByName(self.rootNode, "Btn_ready")
	readyBtn:setVisible(false)

	local msgToSend = {}
	msgToSend.kMId = gt.CG_READY
	msgToSend.kPos = self.playerSeatIdx - 1
	gt.socketClient:sendMessage(msgToSend)
end

-- start --
--------------------------------
-- @class function
-- @description 玩家进入准备状态
-- @param seatIdx 座次
-- end --
function MJScene:playerGetReady(seatIdx)
	local roomPlayer = self.roomPlayers[seatIdx]
    
    if roomPlayer then
		-- 显示玩家准备手势
		local readySignNode = gt.seekNodeByName(self.rootNode, "Node_readySign")
		local readySignSpr = gt.seekNodeByName(readySignNode, "Spr_readySign_" .. roomPlayer.displaySeatIdx)
		readySignSpr:setVisible(true)

		-- 玩家本身
		if seatIdx == self.playerSeatIdx then
			-- 隐藏准备按钮
			-- local readyBtn = gt.seekNodeByName(self.rootNode, "Btn_ready")
			-- readyBtn:setVisible(false)
			
	        -- 隐藏牌局状态
		    local roundStateNode = gt.seekNodeByName(self.rootNode, "Node_roundState")
		    roundStateNode:setVisible(false)
		    self.Image_tilesCount:setVisible(false)
			-- 隐藏微信分享按钮
			-- 隐藏解散房间按钮
			-- 如果是房主隐藏解散房间按钮
			-- local readyPlayNode = gt.seekNodeByName(self.rootNode, "Node_readyPlay")
			-- readyPlayNode:setVisible(false)
		end
	end
end

-- start --
--------------------------------
-- @class function
-- @description 隐藏所有玩家准备手势标识
-- end --
function MJScene:hidePlayersReadySign()
	for i = 1, 4 do
		local readySignNode = gt.seekNodeByName(self.rootNode, "Node_readySign")
		local readySignSpr = gt.seekNodeByName(readySignNode, "Spr_readySign_" .. i)
		readySignSpr:setVisible(false)
	end
end
--开局初始化
function MJScene:initStart(msgTbl)
	self:onRcvSyncRoomState(msgTbl)

	self.isAutoOutTile = false

    self.copyRoomPlayers = self:copyTab(self.roomPlayers)

    for seatIdx, roomPlayer in pairs(self.roomPlayers) do
    	roomPlayer.m_ting = nil
    end
end
-- 游戏开始动画
function MJScene:gameStartAnimation(msgTbl)
	-- 玩家准备手势隐藏
	self:hidePlayersReadySign()

	--座位方向图隐藏
    if self.positionTurnAnimateNode then
		self.positionTurnAnimateNode:removeFromParent()
		self.positionTurnAnimateNode = nil
	end

	--方位动画隐藏
    if self.SelectSeatSpr then
		self.SelectSeatSpr:removeFromParent()
		self.SelectSeatSpr = nil
	end

	-- 播放开局动画
	local chutaiAnimateNode, chutaiAnimate = gt.createCSAnimation("chutai.csb")
	local mahjong_table = gt.seekNodeByName(self.rootNode, "mahjong_table")
	self.rootNode:addChild(chutaiAnimateNode, MJScene.ZOrder.CHUTAIANIMATE)
	chutaiAnimateNode:setPosition(cc.p(mahjong_table:getContentSize().width/2,mahjong_table:getContentSize().height/2))
	chutaiAnimate:play("animation0", false)

	-- 动画屏蔽层
 	local dialog = gt.createMaskLayer(0)
 	chutaiAnimateNode:addChild(dialog)

 	self.chutaiSchedulerEntry = nil
 	local chutaiAnimateResult = function()
 		if self.chutaiSchedulerEntry then
		    local turnPosLayerSpr = gt.seekNodeByName(self.csbNode,"Spr_turnPosLayer")
		    turnPosLayerSpr:setVisible(true)

		    gt.log("-------------------------------------chutaiAnimateResult")
 			gt.scheduler:unscheduleScriptEntry(self.chutaiSchedulerEntry)
 			self.chutaiSchedulerEntry = nil
			chutaiAnimateNode:removeFromParent()

			--隐藏播放互动动画节点
			-- local hudongAction = gt.seekNodeByName(self.rootNode, "Node_hudong")
			-- if hudongAction then
			-- 	hudongAction:hide()
			-- end
			if self.readyPlay ~= nil and self.readyPlay.playingNode ~= nil then
				self.readyPlay.playingNode:stopAllActions()
				self.readyPlay.playingNode:removeFromParent()
				self.readyPlay.playingNode = nil
			end

			-- self:onRcvSyncRoomState(msgTbl)

			-- self.isAutoOutTile = false
			--开始游戏  放开语音按钮
			if gt.isAppStoreInReview == false then
		   		self.yuyinBtn:setVisible(true)
			end

			--调整位置 消失4个背景  
			self.yuyinPos_4:setPosition(cc.p(-442.10,-111.11))
			self.yuyinPos_2:setPosition(cc.p(241.1,243.14))

		 --    self.copyRoomPlayers = self:copyTab(self.roomPlayers)

		    -- local Node_dabao = gt.seekNodeByName(self.rootNode, "Node_dabao")

		 --    gt.log("听牌 555555 isBeingTing="..tostring(self.isBeingTing))
		 --    for seatIdx, roomPlayer in pairs(self.roomPlayers) do
		 --    	roomPlayer.m_ting = nil
		 --    end

			local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
			if self.selfDrawnDecisionFlag == 2 then
				selfDrawnDcsNode:setVisible(true)
				self.selfDrawnDecisionFlag = nil
			end

		    gt.log("-------------------------------------self.chutaiShowFlag")
			self.chutaiShowFlag = true

			local roomPlayer = self.roomPlayers[msgTbl.kZhuang + 1]
			if roomPlayer then
				self:setClockTime(roomPlayer)
			end

	        -- 转运按钮
			-- local zhuanyunBtn = gt.seekNodeByName(self.rootNode, "Btn_zhuanyun")
			-- zhuanyunBtn:setVisible(true)
			
			-- 极速连接按钮
			-- local quickconnectBtn = gt.seekNodeByName(self.rootNode, "Btn_quickconnect")
			-- quickconnectBtn:setVisible(true)

			local backBtn = gt.seekNodeByName(self.rootNode, "Btn_back")
			backBtn:setEnabled(true)

		 	-- self:checkHasEqualIP()

			self.RoundStart = true

			self.playMjLayer:setVisible(true)
 		end
 	end

	local backBtn = gt.seekNodeByName(self.rootNode, "Btn_back")
	--backBtn:setEnabled(false)

    -- 转运按钮
	-- local zhuanyunBtn = gt.seekNodeByName(self.rootNode, "Btn_zhuanyun")
	-- zhuanyunBtn:setVisible(false)
	
	-- 极速连接按钮
	-- local quickconnectBtn = gt.seekNodeByName(self.rootNode, "Btn_quickconnect")
	-- quickconnectBtn:setVisible(false)

	self.chutaiSchedulerEntry = gt.scheduler:scheduleScriptFunc(chutaiAnimateResult, 2.5, false)
end

-- start --
--------------------------------
-- @class function
-- @description 显示玩家具体信息面板
-- @param sender
-- end --
function MJScene:showUnSeatPlayerInfo(sender)
	local senderTag = sender:getTag()

	local roomPlayer = self.unSeatRoomPlayers[senderTag]
	if not roomPlayer then
		return
	end

	roomPlayer.roomCardsCount = gt.playerData.roomCardsCount

	local UserCenter = require("client/game/common/UserCenter"):create(roomPlayer, true)
	self:addChild(UserCenter, MJScene.ZOrder.PLAYER_INFO_TIPS)
end

-- start --
--------------------------------
-- @class function
-- @description 显示玩家具体信息面板
-- @param sender
-- end --
function MJScene:showPlayerInfo(sender)
	local senderTag = sender:getTag()
	local roomPlayer = self.roomPlayers[senderTag]
	if not roomPlayer then
		return
	end
	-- self.juliTab
	-- 取点击人的位置信息  跟自己的位置计算出一个距离 
	-- if self.juliTab[roomPlayer.displaySeatIdx] then
	-- 	local UserInfo = require("app/views/UserInfo"):create(roomPlayer, self.juliTab[roomPlayer.displaySeatIdx])
	-- 	self:addChild(UserInfo, MJScene.ZOrder.PLAYER_INFO_TIPS)
	-- else
	gt.log("点击玩家头像，roomPlayer")
	--dump(roomPlayer)
	roomPlayer.roomCardsCount = gt.playerData.roomCardsCount

	if roomPlayer.uid == gt.playerData.uid then
		local UserCenter = require("client/game/common/UserCenter"):create(roomPlayer, true)
		self:addChild(UserCenter, MJScene.ZOrder.PLAYER_INFO_TIPS)
	else
		local UserInfo = require("client/game/majiang/UserInfo"):create(roomPlayer)
		self:addChild(UserInfo, MJScene.ZOrder.PLAYER_INFO_TIPS)
	end
	-- end
end

-- start --
--------------------------------   
-- @class function
-- @description 设置玩家麻将基础参考位置
-- @param displaySeatIdx 显示座位编号
-- @return 玩家麻将基础参考位置
-- end --
function MJScene:setPlayerMjTilesReferPos(displaySeatIdx)
	local mjTilesReferPos = {}

	local playNode = gt.seekNodeByName(self.rootNode, "Node_play")
	local mjTilesReferNode = gt.seekNodeByName(playNode, "Node_playerMjTiles_" .. displaySeatIdx)

	-- 持有牌数据
	local mjTileHoldSprF = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileHold_1")
	local mjTileHoldSprS = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileHold_2")

	mjTilesReferPos.holdStart = cc.p(mjTileHoldSprF:getPosition())
	gt.log("手牌基础位置 111111 ============= ")
	--dump(mjTilesReferPos.holdStart)
	mjTilesReferPos.holdSpace = cc.pSub(cc.p(mjTileHoldSprS:getPosition()), cc.p(mjTileHoldSprF:getPosition()))

	-- 打出牌数据
	local mjTileOutSprF = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileOut_1")
	local mjTileOutSprS = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileOut_2")
	local mjTileOutSprT = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileOut_3")

	local mjTileOutSprFPositionX = mjTileOutSprF:getPositionX() + mjTilePerLine[self.playersType][displaySeatIdx].deviationX
	local mjTileOutSprSPositionX = mjTileOutSprS:getPositionX() + mjTilePerLine[self.playersType][displaySeatIdx].deviationX
	local mjTileOutSprTPositionX = mjTileOutSprT:getPositionX() + mjTilePerLine[self.playersType][displaySeatIdx].deviationX

	local mjTileOutSprFPositionY = mjTileOutSprF:getPositionY() + mjTilePerLine[self.playersType][displaySeatIdx].deviationY
	local mjTileOutSprSPositionY = mjTileOutSprS:getPositionY() + mjTilePerLine[self.playersType][displaySeatIdx].deviationY
	local mjTileOutSprTPositionY = mjTileOutSprT:getPositionY() + mjTilePerLine[self.playersType][displaySeatIdx].deviationY

	mjTilesReferPos.outStart = cc.p(mjTileOutSprFPositionX, mjTileOutSprFPositionY)
	mjTilesReferPos.outSpaceH = cc.pSub(cc.p(mjTileOutSprSPositionX, mjTileOutSprSPositionY), cc.p(mjTileOutSprFPositionX, mjTileOutSprFPositionY))
	mjTilesReferPos.outSpaceV = cc.pSub(cc.p(mjTileOutSprTPositionX, mjTileOutSprTPositionY), cc.p(mjTileOutSprFPositionX, mjTileOutSprFPositionY))

	-- 碰，杠牌数据
	local mjTileGroupPanel = gt.seekNodeByName(mjTilesReferNode, "Panel_mjTileGroup")
	local groupMjTilesPos = {}
	for _, groupTileSpr in ipairs(mjTileGroupPanel:getChildren()) do
		table.insert(groupMjTilesPos, cc.p(groupTileSpr:getPosition()))
	end

    --手持牌数据
	mjTilesReferPos.groupMjTilesPos = groupMjTilesPos
	mjTilesReferPos.groupStartPos = cc.p(mjTileGroupPanel:getPosition())
	local groupSize = mjTileGroupPanel:getContentSize()
	if displaySeatIdx == 1 then
		mjTilesReferPos.groupSpace = cc.p(-34, groupSize.height + 32)
		-- mjTilesReferPos.groupSpace = cc.p(0, 0)
	elseif displaySeatIdx == 3 then
		mjTilesReferPos.groupSpace = cc.p(-34, groupSize.height + 32)
		-- mjTilesReferPos.groupSpace = cc.p(0, 0)
		mjTilesReferPos.groupSpace.y = -mjTilesReferPos.groupSpace.y
	elseif displaySeatIdx == 2 then
		mjTilesReferPos.groupSpace = cc.p(groupSize.width - 8, 0)
		mjTilesReferPos.groupSpace.x = -mjTilesReferPos.groupSpace.x
	else
		mjTilesReferPos.groupSpace = cc.p(groupSize.width + 1, 0)
	end

	-- 胡牌显示坐标
	if displaySeatIdx == 1 then
		mjTilesReferPos.m_huSpace = cc.p( groupMjTilesPos[2].x-groupMjTilesPos[3].x-2, groupMjTilesPos[2].y-groupMjTilesPos[3].y+5)
	elseif displaySeatIdx == 3 then
		mjTilesReferPos.m_huSpace = cc.p( groupMjTilesPos[2].x-groupMjTilesPos[1].x-2, groupMjTilesPos[2].y-groupMjTilesPos[1].y-5)
	else
		mjTilesReferPos.m_huSpace = cc.p( groupMjTilesPos[2].x-groupMjTilesPos[1].x, groupMjTilesPos[2].y-groupMjTilesPos[1].y)
	end

	-- 当前出牌展示位置
	local showMjTileNode = gt.seekNodeByName(mjTilesReferNode, "Node_showMjTile")
	mjTilesReferPos.showMjTilePos = cc.p(showMjTileNode:getPosition())

	return mjTilesReferPos
end

-- start --
--------------------------------
-- @class function
-- @description 设置座位编号标识
-- @param seatIdx 座位编号
-- end --
function MJScene:setTurnSeatSign(seatId)
	gt.log("----------------------setTurnSeatSignseatId", seatId)
	-- local seatIdx = self:getDisplaySeat(seatId)
	local seatIdx = seatId
	gt.log("----------------------seatIdx1", seatIdx)
	-- seatIdx = 1
	-- gt.log("UI中的对象" .. "Spr_turnPosTip_" .. seatIdx)
	-- 显示轮到的玩家座位标识
	local turnPosLayerSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosLayer")
	-- turnPosLayerSpr:setTexture("res/images/otherImages/turn_pos_bg_new.png")
	-- turnPosLayerSpr:setVisible(true)
	-- 显示当前座位标识
	local turnPosTipSpr1 = gt.seekNodeByName(turnPosLayerSpr, "Spr_turnPosTip_" .. seatIdx)
	turnPosTipSpr1:show()
	gt.log("----------------------self.preTurnSeatIdx", self.preTurnSeatIdx)
	if self.preTurnSeatIdx and self.preTurnSeatIdx ~= seatIdx then
		-- 隐藏上次座位标识
		local turnPosTipSpr2 = gt.seekNodeByName(turnPosLayerSpr, "Spr_turnPosTip_" .. self.preTurnSeatIdx)
		turnPosTipSpr2:hide()
	end
	gt.log("----------------------seatIdx2", seatIdx)
	self.preTurnSeatIdx = seatIdx
end

-- start --
--------------------------------
-- @class function
-- @description 出牌倒计时
-- @param
-- @param
-- @param
-- @return
-- end --
function MJScene:playTimeCDStart(timeDuration)
	self.playTimeCD = timeDuration

	self.isVibrateAlarm = false
	self.playTimeCDLabel:setVisible(true)
	self.playTimeCDLabel:setString(tostring(timeDuration))
end

-- start --
--------------------------------
-- @class function
-- @description 更新出牌倒计时
-- @param delta 定时器周期
-- end --
function MJScene:playTimeCDUpdate(delta)
	if not self.playTimeCD then
		return
	end

	self.playTimeCD = self.playTimeCD - delta
	if self.playTimeCD < 0 then
		self.playTimeCD = 0
	end
	if (self.isPlayerShow or self.isPlayerDecision) and self.playTimeCD <= 3 and not self.isVibrateAlarm then
		-- 剩余3s开始播放警报声音+震动一下手机
		self.isVibrateAlarm = true

		-- 播放声音
		self.playCDAudioID = gt.soundEngine:playEffect("common/timeup_alarm")

		-- 震动提醒
		cc.Device:vibrate(1)
	end
	local timeCD = math.ceil(self.playTimeCD)
	self.playTimeCDLabel:setString(tostring(timeCD))
end

-- update --
--------------------------------
-- @class function
-- @description 给玩家更新牌
-- @param mjColor
-- @param mjNumber
-- end --
function MJScene:updateMjTileToPlayer(mjTileSpr)
	-- gt.log("给玩家发牌：color="..mjColor..", number="..mjNumber)
	-- if mjColor <= 0 or mjNumber <= 0 then
	-- 	gt.log("收到非法牌型：给玩家发牌：color="..mjColor..", mjNumber="..mjNumber)
	-- 	return
	-- end
	-- -- local mjTileName = string.format("p%db%d_%d.png", self.playerFixDispSeat, mjColor, mjNumber)
	-- local mjTileName = Utils.getMJTileResName( self.playerFixDispSeat, mjColor, mjNumber, self.isHZLZ, 1)
	-- gt.log("addMjTileToPlayer=="..mjTileName)
	-- local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	mjTileSpr:retain()
	-- self.playMjLayer:addChild(mjTileSpr)
	self.holdMjNode:addChild(mjTileSpr)

	-- 添加耗子牌标识
	if self.HaoZiCards then
		for i,card in ipairs(self.HaoZiCards) do
			if mjColor == card._color and mjNumber == card._number then
				self:addMouseMark(mjTileSpr)	
			end		
		end
	end
	-- local roomPlayer = self.roomPlayers[self.playerSeatIdx]
	-- local mjTile = {}
	-- mjTile.mjTileSpr = mjTileSpr
	-- mjTile.mjColor = mjColor
	-- mjTile.mjNumber = mjNumber
	-- table.insert(roomPlayer.holdMjTiles, mjTile)
	-- return mjTile
end

-- start --
--------------------------------
-- @class function
-- @description 给玩家发牌
-- @param mjColor
-- @param mjNumber
-- end --
function MJScene:addMjTileToPlayer(mjColor, mjNumber)
	gt.log("给玩家发牌：color="..mjColor..", number="..mjNumber)
	if mjColor <= 0 or mjNumber <= 0 then
		gt.log("收到非法牌型：给玩家发牌：color="..mjColor..", mjNumber="..mjNumber)
		return
	end
	-- local mjTileName = string.format("p%db%d_%d.png", self.playerFixDispSeat, mjColor, mjNumber)
	local mjTileName = Utils.getMJTileResName( self.playerFixDispSeat, mjColor, mjNumber, self.isHZLZ, 1)
	gt.log("addMjTileToPlayer=="..mjTileName)
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	mjTileSpr:retain()
	-- self.playMjLayer:addChild(mjTileSpr)
	self.holdMjNode:addChild(mjTileSpr)

	-- 添加耗子牌标识
	if self.HaoZiCards then
		for i,card in ipairs(self.HaoZiCards) do
			if mjColor == card._color and mjNumber == card._number then
				self:addMouseMark(mjTileSpr)	
			end		
		end
	end
	gt.log("-------------------------self.playerSeatIdx", self.playerSeatIdx)
	local roomPlayer = self.roomPlayers[self.playerSeatIdx]
	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber
	table.insert(roomPlayer.holdMjTiles, mjTile)
	return mjTile
end

-- start --
--------------------------------
-- @class function
-- @description 添加立四手牌
-- @param mjColor
-- @param mjNumber
-- end --
function MJScene:addLisiMjTileToPlayer(mjColor, mjNumber)
	gt.log("给玩家发立四牌：color="..mjColor..", number="..mjNumber)
	if mjColor <= 0 or mjNumber <= 0 then
		gt.log("收到非法牌型：color="..mjColor..", mjNumber="..mjNumber)
		return
	end
	local mjTileName = Utils.getMJTileResName( self.playerFixDispSeat, mjColor, mjNumber, self.isHZLZ, 1)
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	self.playMjLayer:addChild(mjTileSpr)

	local roomPlayer = self.roomPlayers[self.playerSeatIdx]
	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber
	table.insert(roomPlayer.lisiMjTiles, mjTile)

	return mjTile
end

--显示立四手牌
function MJScene:showLisiMjTile()
	local roomPlayer = self.roomPlayers[self.playerSeatIdx]
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.holdStart
	gt.log("显示立四手牌")
	--dump(roomPlayer.lisiMjTiles)
	for k, mjTile in ipairs(roomPlayer.lisiMjTiles) do
		mjTile.mjTileSpr:stopAllActions()
		mjTile.mjTileSpr:setPosition(mjTilePos)
		mjTile.mjTileSpr:setColor(cc.c3b(180,180,180))
		gt.log("立四手牌位置 ================ ")
		--dump(mjTilePos)
		mjTile.mjTileSpr:setOpacity(255)
		self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height - mjTilePos.y))
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 玩家麻将牌根据花色，编号重新排序
-- end --
function MJScene:sortPlayerMjTiles(isPeng)
	gt.log(debug.traceback())
	local roomPlayer = self.roomPlayers[self.playerSeatIdx]
	gt.log("对手牌重新排序 ================ "..self.playerSeatIdx)
	--dump(roomPlayer.holdMjTiles)
	if roomPlayer.holdMjTiles == nil then
		return
	end
	-- if self.m_tingState then
	-- 	--如果已经听牌，末尾牌是刚摸的，需要从手牌中去掉末尾牌
	-- 	table.remove(roomPlayer.holdMjTiles, #roomPlayer.holdMjTiles)
	-- end
	-- 按照花色分类
	local colorsMjTiles = {}
	table.sort(roomPlayer.holdMjTiles, function(a, b)
		return tonumber(a.mjColor) < tonumber(b.mjColor)
	end)

	-- gt.log("当前持牌")
	-- --dump(roomPlayer.holdMjTiles)

	local colorsMjTiles = {}
	for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
		if not colorsMjTiles[mjTile.mjColor] then
			colorsMjTiles[mjTile.mjColor] = {}
		end
		table.insert(colorsMjTiles[mjTile.mjColor], mjTile)
	end

	-- gt.log("花色排序后")
	-- --dump(colorsMjTiles)

	-- 同花色从小到大排序
	local transMjTiles = {}
	for _, sameColorMjTiles in pairs(colorsMjTiles) do
		table.sort(sameColorMjTiles, function(a, b)
			return a.mjNumber < b.mjNumber
		end)
		for _, mjTile in pairs(sameColorMjTiles) do
			if mjTile.mjColor ~= 4 then
				table.insert(transMjTiles, mjTile)
			end
		end
	end
	for _, sameColorMjTiles in pairs(colorsMjTiles) do
		for _, mjTile in pairs(sameColorMjTiles) do
			if mjTile.mjColor == 4 then
				table.insert(transMjTiles, mjTile)
			end
		end
	end

	-- 棋牌全部正序排完，对红中癞子做特殊处理
	local finalMjTiles = {}
	if self.isHZLZ == true then
		for _, mjTile in ipairs(transMjTiles) do
			if mjTile.mjColor == 4 and mjTile.mjNumber == 5 then -- 红中
				table.insert(finalMjTiles, 1, mjTile)
			else
				table.insert(finalMjTiles, mjTile)
			end
		end
	else
		finalMjTiles = transMjTiles
	end

	-- gt.log("最终排序")
	-- --dump(finalMjTiles)

	-- 重新放置位置
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.holdStart 
	gt.log("手牌位置 111111")
	--dump(mjTilePos)
	gt.log("手牌位置 222222")
	--dump(mjTilesReferPos.holdSpace)
	local maxHoldNum = 13    --起手正常手牌数量
	if self.playType == 100004 then
		--如果是立四玩法，手牌位置要根据当前立四手牌数量来取位置
		local lisiNum = #roomPlayer.lisiMjTiles
		-- mjTilePos.x = mjTilesReferPos.holdStart.x + lisiNum*mjTilesReferPos.holdSpace.x + 20
		-- mjTilePos = cc.pAdd(mjTilesReferPos.holdStart, cc.p(345, 0))
		-- gt.log("如果是立四玩法，手牌位置要根据当前立四手牌数量来取位置，mjTilesReferPos.holdStart.x = "..mjTilesReferPos.holdStart.x..", lisiNum = "..lisiNum..", mjTilesReferPos.holdSpace.x = "..mjTilesReferPos.holdSpace.x)
		

		mjTilePos = cc.pAdd(mjTilesReferPos.holdStart, cc.pMul(mjTilesReferPos.holdSpace, lisiNum))
		mjTilePos = cc.pAdd(mjTilePos, cc.p(25, 0))

		-- 如果是立四，正常手牌数量是13减去立四手牌
		maxHoldNum = 13 - #roomPlayer.lisiMjTiles
	end
	gt.log("排序后手牌长度："..#finalMjTiles)
	--dump(finalMjTiles)
	--  如果是耗子牌，放在手牌的最左边 2017-3-4 shenyongzhen
	if self.HaoZiCards then
		gt.log("耗子牌，排序")
		for i,card in ipairs(self.HaoZiCards) do
			for i,v in ipairs(finalMjTiles) do
				if v.mjColor == card._color and v.mjNumber == card._number then
					table.remove(finalMjTiles,i)
					table.insert(finalMjTiles,1,v)
					self:addMouseMark(v.mjTileSpr)	
				end		
			end
		end
	end

	gt.log("-------------------isPeng", isPeng)
	--这是绘制牌牌
	for k, mjTile in ipairs(finalMjTiles) do
		if mjTile.mjTileSpr ~= nil then
			mjTile.mjTileSpr:stopAllActions()
			mjTile.mjTileSpr:setPosition(mjTilePos)
			if isPeng and k == #finalMjTiles then
				mjTile.mjTileSpr:setPositionX(mjTile.mjTileSpr:getPositionX() + 10)
			end
			mjTile.mjTileSpr:setOpacity(255)
			-- self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height - mjTilePos.y))
			if roomPlayer.displaySeatIdx == 1 then
				self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height - mjTilePos.x - mjTilePos.y))
			else
				self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height + mjTilePos.x - mjTilePos.y))
			end
			mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
			if k == maxHoldNum then -- 如果手里有14张得话，那么说明是庄家
				mjTilePos = cc.pAdd(mjTilePos, cc.p(25, 0))
			end
		end
	end
	-- roomPlayer.holdMjTiles = transMjTiles
	roomPlayer.holdMjTiles = finalMjTiles
end
-- start --
--------------------------------
-- @class function
-- @description 玩家麻将牌根据花色，编号重新排序
-- end --
function MJScene:setSortPlayerMjTiles(PlayerMjTiles)
    -- 按照花色分类
    local colorsMjTiles = {}
    table.sort(PlayerMjTiles, function(a, b)
        return tonumber(a[1]) < tonumber(b[1])
    end)

    local colorsMjTiles = {}
    for _, mjTile in ipairs(PlayerMjTiles) do
        if not colorsMjTiles[mjTile[1]] then
            colorsMjTiles[mjTile[1]] = {}
        end
        table.insert(colorsMjTiles[mjTile[1]], mjTile)
    end

    -- 同花色从小到大排序
    local transMjTiles = {}
    for _, sameColorMjTiles in pairs(colorsMjTiles) do
        table.sort(sameColorMjTiles, function(a, b)
            return a[2] < b[2]
        end)
        for _, mjTile in pairs(sameColorMjTiles) do
            if mjTile[1] ~= 4 then
                table.insert(transMjTiles, mjTile)
            end
        end
    end
    for _, sameColorMjTiles in pairs(colorsMjTiles) do
        for _, mjTile in pairs(sameColorMjTiles) do
            if mjTile[1] == 4 then
                table.insert(transMjTiles, mjTile)
            end
        end
    end

    -- 棋牌全部正序排完，对红中癞子做特殊处理
    local finalMjTiles = {}
    if self.isHZLZ == true then
        for _, mjTile in ipairs(transMjTiles) do
            if mjTile[1] == 4 and mjTile[2] == 5 then -- 红中
                table.insert(finalMjTiles, 1, mjTile)
            else
                table.insert(finalMjTiles, mjTile)
            end
        end
    else
        finalMjTiles = transMjTiles
    end

    --  如果是耗子牌，放在手牌的最左边 2017-3-4 shenyongzhen
    if self.HaoZiCards then
        gt.log("耗子牌，排序")
        for i,card in ipairs(self.HaoZiCards) do
            for i,v in ipairs(finalMjTiles) do
                if v[1] == card._color and v[2] == card._number then
                    table.remove(finalMjTiles,i)
                    table.insert(finalMjTiles,1,v)
                    self:addMouseMark(v.mjTileSpr)    
                end        
            end
        end
    end

    return finalMjTiles
end

-- start --
--------------------------------
-- @class function
-- @description 玩家麻将牌根据花色，编号重新排序
-- end --
function MJScene:setSortPlayerMjTiles(PlayerMjTiles)
	-- 按照花色分类
	local colorsMjTiles = {}
	table.sort(PlayerMjTiles, function(a, b)
		return tonumber(a[1]) < tonumber(b[1])
	end)

	local colorsMjTiles = {}
	for _, mjTile in ipairs(PlayerMjTiles) do
		if not colorsMjTiles[mjTile[1]] then
			colorsMjTiles[mjTile[1]] = {}
		end
		table.insert(colorsMjTiles[mjTile[1]], mjTile)
	end

	-- 同花色从小到大排序
	local transMjTiles = {}
	for _, sameColorMjTiles in pairs(colorsMjTiles) do
		table.sort(sameColorMjTiles, function(a, b)
			return a[2] < b[2]
		end)
		for _, mjTile in pairs(sameColorMjTiles) do
			if mjTile[1] ~= 4 then
				table.insert(transMjTiles, mjTile)
			end
		end
	end
	for _, sameColorMjTiles in pairs(colorsMjTiles) do
		for _, mjTile in pairs(sameColorMjTiles) do
			if mjTile[1] == 4 then
				table.insert(transMjTiles, mjTile)
			end
		end
	end

	-- 棋牌全部正序排完，对红中癞子做特殊处理
	local finalMjTiles = {}
	if self.isHZLZ == true then
		for _, mjTile in ipairs(transMjTiles) do
			if mjTile[1] == 4 and mjTile[2] == 5 then -- 红中
				table.insert(finalMjTiles, 1, mjTile)
			else
				table.insert(finalMjTiles, mjTile)
			end
		end
	else
		finalMjTiles = transMjTiles
	end

	--  如果是耗子牌，放在手牌的最左边 2017-3-4 shenyongzhen
	if self.HaoZiCards then
		gt.log("耗子牌，排序")
		for i,card in ipairs(self.HaoZiCards) do
			for i,v in ipairs(finalMjTiles) do
				if v[1] == card._color and v[2] == card._number then
					table.remove(finalMjTiles,i)
					table.insert(finalMjTiles,1,v)
					self:addMouseMark(v.mjTileSpr)	
				end		
			end
		end
	end

	return finalMjTiles
end

-- start --
--------------------------------
-- @class function
-- @description 选中玩家麻将牌
-- @return 选中的麻将牌
-- end --
function MJScene:touchPlayerMjTiles(touch)
	local roomPlayer = self.roomPlayers[self.playerSeatIdx]
	if roomPlayer == nil or roomPlayer.holdMjTiles == nil then
		return
	end
	for idx, mjTile in ipairs(roomPlayer.holdMjTiles) do
		if mjTile and mjTile.mjTileSpr then
			local touchPoint = mjTile.mjTileSpr:convertTouchToNodeSpace(touch)
			local mjTileSize = mjTile.mjTileSpr:getContentSize()
			local mjTileRect = cc.rect(0, 0, mjTileSize.width, mjTileSize.height)
			if cc.rectContainsPoint(mjTileRect, touchPoint) then
				if self.playType == 100004 and self.isBeingTing then
					--如果是立四且是听牌这一手，普通手牌不可点击
					gt.log("如果是立四且是听牌这一手，普通手牌不可点击")
					return nil
				else
					gt.soundEngine:playEffect("common/audio_card_click")
					return mjTile, idx
				end
			end
		end
	end

	if self.playType == 100004 then
		if not self.isBeingTing then
			--如果未听牌，立四手牌不能点击
			gt.log("如果未听牌，立四手牌不能点击")
			return nil
		end
		-- 如果是立四玩法，且听牌了，可点击
		for idx, mjTile in ipairs(roomPlayer.lisiMjTiles) do
			local touchPoint = mjTile.mjTileSpr:convertTouchToNodeSpace(touch)
			local mjTileSize = mjTile.mjTileSpr:getContentSize()
			local mjTileRect = cc.rect(0, 0, mjTileSize.width, mjTileSize.height)
			if cc.rectContainsPoint(mjTileRect, touchPoint) then
				gt.soundEngine:playEffect("common/audio_card_click")
				return mjTile, idx
			end
		end
	end

	return nil
end

-- start --
--------------------------------
-- @class function
-- @description 显示已出牌
-- @param seatIdx 座位号
-- @param mjColor 麻将花色
-- @param mjNumber 麻将编号
-- @param isNeedKouPai 是否要扣牌
-- end --
function MJScene:addAlreadyOutMjTiles(seatIdx, mjColor, mjNumber, isHide, isNeedKouPai)
	-- self.isBeingTing = false
	-- 添加到已出牌列表
	local roomPlayer = self.roomPlayers[seatIdx]
	if not roomPlayer then
		return false
	end

	if self.AppVersion and self.AppVersion > 10 then
		gt.dumplog(roomPlayer)
	end
	
	-- local mjTileSpr = cc.Sprite:createWithSpriteFrameName(string.format("p%ds%d_%d.png", roomPlayer.displaySeatIdx, mjColor, mjNumber))
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(Utils.getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber, self.isHZLZ, 2))
	if isNeedKouPai then
		--如果需要扣牌，则扣牌
		local mjTileName = string.format("tdbgs_%d.png", roomPlayer.displaySeatIdx)
		mjTileSpr:initWithSpriteFrameName(mjTileName)
		if self.KouPaiData == nil then
			self.KouPaiData = {}
		end
		if self.playerSeatIdx ~= seatIdx then
			self.KouPaiData[seatIdx] = {}
			self.KouPaiData[seatIdx].mjColor = mjColor
			self.KouPaiData[seatIdx].mjNumber = mjNumber
		end
	end
	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber
	if roomPlayer.outMjTiles == nil then
		roomPlayer.outMjTiles = {}
	end
	table.insert(roomPlayer.outMjTiles, mjTile)

	-- 玩家已出牌缩小
	if self.playerSeatIdx == seatIdx then
		-- mjTileSpr:setScale(0.66)
	end

	--对家牌改成正向后，需要将牌缩小
	-- if roomPlayer.displaySeatIdx == 2 then
	-- 	mjTileSpr:setScale(0.8)
	-- end

	-- if isHide then
	-- 	mjTileSpr:setVisible( false )
	-- end
	--*****贴金专用****---- 2017-3-15
	local function addJinKuang()
		local imgfile = ""
		local scale = 1
		gt.log("出牌加金框 =="..self.playerSeatIdx)
		--dump(roomPlayer)
		if  self.playerSeatIdx == seatIdx or roomPlayer.displaySeatIdx == 2 then
			imgfile = "sx_img_table_jin_li.png"
			scale = 1.5
		elseif  roomPlayer.displaySeatIdx == 1 or roomPlayer.displaySeatIdx == 3 then	
			imgfile = "sx_img_table_jin_heng.png"
		end

		local imgkuang = mjTile.mjTileSpr:getChildByName("img_table_jinkuang")
		if not imgkuang then
			imgkuang = ccui.ImageView:create()		
			-- imgkuang:setAnchorPoint(0,0)
			imgkuang:setName("img_table_jinkuang")
			mjTile.mjTileSpr:addChild(imgkuang)		
		end
		if imgkuang then
			imgkuang:setScale(scale)
			if roomPlayer.displaySeatIdx == 3 then
				imgkuang:setFlippedX(true)
			end
			imgkuang:loadTexture(imgfile,1)
			imgkuang:setPosition(mjTile.mjTileSpr:getContentSize().width/2,mjTile.mjTileSpr:getContentSize().height/2)
		end
	end
	if gt.createType == 5 then
		for i,v in ipairs(self.HaoZiCards) do
			if mjColor == v._color and mjNumber == v._number then
				addJinKuang()
			end	
		end
	end
	--*****贴金专用**** end---- 

	if roomPlayer.mjTilesReferPos == nil then
		-- 麻将放置参考点
		roomPlayer.mjTilesReferPos = self:setPlayerMjTilesReferPos(roomPlayer.displaySeatIdx)
	end
	-- 显示已出牌
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.outStart

	-- if self.playersType == 2 then
	-- 	--设置2人玩法的已出牌初始位置
	-- 	mjTilePerLine = 15
	-- 	if roomPlayer.displaySeatIdx == 4 then
	-- 		mjTilePos.x = 410
	-- 	else
	-- 		mjTilePos.x = 410 + 0.66 * 55 * (mjTilePerLine - 1.5)
	-- 	end
	-- end

	-- if self.playersType == 3 then
	-- 	if roomPlayer.displaySeatIdx == 4 then
	-- 		mjTilePos.x = 410
	-- 	end
	-- end 

	if roomPlayer.displaySeatIdx == 1 then
		mjTileSpr:setScale(0.8)
	elseif roomPlayer.displaySeatIdx == 2 then
		mjTileSpr:setScale(0.7)
	elseif roomPlayer.displaySeatIdx == 3 then
		mjTileSpr:setScale(0.8)
	elseif roomPlayer.displaySeatIdx == 4 then
		mjTileSpr:setScale(0.8)
	end

	-- gt.log( roomPlayer.displaySeatIdx .. "打出的麻将牌位置" .. mjTilePos.x .. mjTilePos.y)
	-- local lineCount = math.ceil(#roomPlayer.outMjTiles / 10) - 1
	-- local lineIdx = #roomPlayer.outMjTiles - lineCount * 10 - 1
	local lineCount = math.ceil(#roomPlayer.outMjTiles / mjTilePerLine[self.playersType][roomPlayer.displaySeatIdx].lineCount) - 1
	local lineIdx = #roomPlayer.outMjTiles - lineCount * mjTilePerLine[self.playersType][roomPlayer.displaySeatIdx].lineCount - 1
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))
	mjTileSpr:setPosition(mjTilePos)
	if roomPlayer.displaySeatIdx == 1 then
		self.playMjLayer:addChild(mjTileSpr, (gt.winSize.height - mjTilePos.x - mjTilePos.y))
	else
		self.playMjLayer:addChild(mjTileSpr, (gt.winSize.height + mjTilePos.x - mjTilePos.y))
	end
	return mjTileSpr
end
-- 目前只有在扎鸟中用到了
function MJScene:addAlreadyOutMjTilesByCopy(seatIdx, mjColor, mjNumber, roomPlayer, isHide)
	-- 添加到已出牌列表
	-- local mjTileSpr = cc.Sprite:createWithSpriteFrameName(string.format("p%ds%d_%d.png", roomPlayer.displaySeatIdx, mjColor, mjNumber))
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(Utils.getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber, self.isHZLZ))
	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber
	table.insert(roomPlayer.outMjTiles, mjTile)

	-- 玩家已出牌缩小
	if self.playerSeatIdx == seatIdx or 2 then
		-- mjTileSpr:setScale(0.66)
	end

	if isHide then
		mjTileSpr:setVisible( false )
	end

	-- 显示已出牌
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.outStart
	-- local lineCount = math.ceil(#roomPlayer.outMjTiles / 10) - 1
	-- local lineIdx = #roomPlayer.outMjTiles - lineCount * 10 - 1
	local lineCount = math.ceil(#roomPlayer.outMjTiles / mjTilePerLine[self.playersType][roomPlayer.displaySeatIdx].lineCount) - 1
	local lineIdx = #roomPlayer.outMjTiles - lineCount * mjTilePerLine[self.playersType][roomPlayer.displaySeatIdx].lineCount - 1
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))
	mjTileSpr:setPosition(mjTilePos)
	if roomPlayer.displaySeatIdx == 1 then
		self.playMjLayer:addChild(mjTileSpr, (gt.winSize.height - mjTilePos.x - mjTilePos.y))
	else
		self.playMjLayer:addChild(mjTileSpr, (gt.winSize.height + mjTilePos.x - mjTilePos.y))
	end
	return mjTileSpr
end

function MJScene:updateOutMjTilesPosition(seatIdx)
	local roomPlayer = self.roomPlayers[seatIdx]
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.outStart
	for k, v in pairs(roomPlayer.outMjTiles) do
		-- 显示已出牌
		-- local lineCount = math.ceil(k / 10) - 1
		-- local lineIdx = k - lineCount * 10 - 1
		local lineCount = math.ceil(k / mjTilePerLine[self.playersType][roomPlayer.displaySeatIdx].lineCount) - 1
		local lineIdx = k - lineCount * mjTilePerLine[self.playersType][roomPlayer.displaySeatIdx].lineCount - 1
		local tilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
		tilePos = cc.pAdd(tilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))
		v.mjTileSpr:setPosition(tilePos)

		-- self.playMjLayer:reorderChild(v.mjTileSpr, (gt.winSize.height - tilePos.y))
		if roomPlayer.displaySeatIdx == 1 then
			self.playMjLayer:reorderChild(v.mjTileSpr, (gt.winSize.height - tilePos.x - tilePos.y))
		else
			self.playMjLayer:reorderChild(v.mjTileSpr, (gt.winSize.height + tilePos.x - tilePos.y))
		end
	end
end

-- start --
--------------------------------
-- @class function
-- @description 移除上家被下家，杠打出的牌
-- end --
function MJScene:removePreRoomPlayerOutMjTile(color, number)
	-- 移除上家打出的牌
	if self.preShowSeatIdx then
		local roomPlayer = self.roomPlayers[self.preShowSeatIdx]
		for i = #roomPlayer.outMjTiles, 1, -1 do
			local outMjTile = roomPlayer.outMjTiles[i]
			if outMjTile.mjColor == color and outMjTile.mjNumber == number then
				outMjTile.mjTileSpr:removeFromParent()
				table.remove(roomPlayer.outMjTiles, i)
				self:updateOutMjTilesPosition(self.preShowSeatIdx)
				break
			end
		end

		-- 隐藏出牌标识箭头
		self.outMjtileSignNode:setVisible(false)
		if self.outMjtileSignNodeAction then
			self.outMjtileSignNode:stopAction(self.outMjtileSignNodeAction)
		end
	end
end

-- start --
--------------------------------
-- @class function
-- @description 显示指示出牌标识箭头动画
-- @param seatIdx 座次
-- end --
function MJScene:showOutMjtileSign(seatIdx)
	local roomPlayer = self.roomPlayers[seatIdx]
	local endIdx = #roomPlayer.outMjTiles
	local outMjTile = roomPlayer.outMjTiles[endIdx]
	if self.outMjtileSignNodeAction then
		self.outMjtileSignNode:stopAction(self.outMjtileSignNodeAction)
	end
	self.outMjtileSignNode:setVisible(true)
	self.outMjtileSignNode:setPosition(cc.p(outMjTile.mjTileSpr:getPositionX(), outMjTile.mjTileSpr:getPositionY() + 33))
	
	self.outMjtileSignNodeAction = cc.RepeatForever:create(
		cc.Sequence:create(
			cc.CallFunc:create(function()
				self.outMjtileSignNode:setOpacity(255)
			end),
			cc.MoveBy:create(0.5, cc.p(0, 25)),
			cc.MoveBy:create(0.5, cc.p(0, -25)),
			cc.FadeTo:create(0.5, 180),
			cc.FadeTo:create(0.5, 255)
		)
	)
	self.outMjtileSignNode:runAction(self.outMjtileSignNodeAction)
end

-- start --
--------------------------------
-- @class function
-- @description 隐藏碰，杠牌
-- @param seatIdx 座次
-- @param isBar 杠
-- @param isBrightBar 明杠
-- end --
function MJScene:hideOtherPlayerMjTiles(seatIdx, isBar, isBrightBar)
	if seatIdx == self.playerSeatIdx then
		return
	end

	-- 持有牌隐藏已经碰杠牌
	-- 碰2张
	local mjTilesCount = 2
	if isBar then
		-- 明杠3张
		mjTilesCount = 3
		-- 暗杠4张
		if not isBrightBar then
			mjTilesCount = 4
		end
	end
	local roomPlayer = self.roomPlayers[seatIdx]
	local idx = roomPlayer.mjTilesRemainCount - mjTilesCount + 1
	for i = 1, mjTilesCount do
		local mjTile = roomPlayer.holdMjTiles[idx]
		if mjTile then
			mjTile.mjTileSpr:setVisible(false)
		end

		idx = idx + 1
	end

	roomPlayer.mjTilesRemainCount = roomPlayer.mjTilesRemainCount - mjTilesCount
end

-- start --
--------------------------------
-- @class function
-- @description 碰牌
-- @param seatIdx 座位编号
-- @param mjColor 麻将牌花色
-- @param mjNumber 麻将牌编号
-- end --
function MJScene:addMjTilePung(seatIdx, mjColor, mjNumber, isPeng, firePos)
	local roomPlayer = self.roomPlayers[seatIdx]
	local pungData = {}
	pungData.mjColor = mjColor
	pungData.mjNumber = mjNumber
	table.insert(roomPlayer.mjTilePungs, pungData)

	pungData.groupNode = self:pungBarReorderMjTiles(seatIdx, mjColor, mjNumber, nil, nil, nil, nil, isPeng, firePos)
end

-- start --
--------------------------------
-- @class function
-- @description 粘牌
-- @param seatIdx 座位编号
-- @param mjColor 麻将牌花色
-- @param mjNumber 麻将牌编号
-- end --
function MJScene:addMjTileNian(seatIdx, mjColor, mjNumber)
	local roomPlayer = self.roomPlayers[seatIdx]
	local pungData = {}
	pungData.mjColor = mjColor
	pungData.mjNumber = mjNumber
	table.insert(roomPlayer.mjTileNians, pungData)

	pungData.groupNode = self:pungBarReorderMjTiles(seatIdx, mjColor, mjNumber, false, false, true)
end

-- start --
--------------------------------
-- @class function
-- @description 支对
-- @param seatIdx 座位编号
-- @param mjColor 麻将牌花色
-- @param mjNumber 麻将牌编号
-- end --
function MJScene:addMjTileZhiDui(seatIdx, mjColor, mjNumber)
	local roomPlayer = self.roomPlayers[seatIdx]
	local pungData = {}
	pungData.mjColor = mjColor
	pungData.mjNumber = mjNumber
	table.insert(roomPlayer.mjTileNians, pungData)
	pungData.groupNode = self:pungBarReorderMjTiles(seatIdx, mjColor, mjNumber, false, false, false, true)
end


-- start --
--------------------------------
-- @class function
-- @description 杠牌
-- @param seatIdx 座位编号
-- @param mjColor 麻将牌花色
-- @param mjNumber 麻将牌编号
-- @param isBrightBar 明杠或者暗杠
-- end --
function MJScene:addMjTileBar(seatIdx, mjColor, mjNumber, isBrightBar, firePos)
	local roomPlayer = self.roomPlayers[seatIdx]

	-- 加入到列表中
	local barData = {}
	barData.mjColor = mjColor
	barData.mjNumber = mjNumber
	if isBrightBar then
		-- 明杠
		table.insert(roomPlayer.mjTileBrightBars, barData)
	else
		-- 暗杠
		table.insert(roomPlayer.mjTileDarkBars, barData)
	end

	-- csw 11-14
	gt.log("暗杠________")
	if self.HaoZiCards then 
		if self.isKdd then
			if gt.playerData.uid == roomPlayer.uid then 
				for i , card in pairs(self.HaoZiCards) do
					if mjColor == card._color and mjNumber == card._number then
						self.haoziGang = true
						gt.log("四个耗子_____________")
					end
				end
			end
		end
	end
	-- csw 11-14



	--dump(barData)
	barData.groupNode = self:pungBarReorderMjTiles(seatIdx, mjColor, mjNumber, true, isBrightBar, nil, nil, nil, firePos)
end


-- start --
--------------------------------
-- @class function
-- @description 补牌
-- @param mjColor 麻将牌花色
-- @param seatIdx 座位编号
-- @param mjNumber 麻将牌编号
-- @param isBrightBar 明补或者暗补
-- end --
function MJScene:addMjTileBu(seatIdx, mjColor, mjNumber, isBrightBu)
	local roomPlayer = self.roomPlayers[seatIdx]
     
	-- 加入到列表中
	local barData = {}
	barData.mjColor = mjColor
	barData.mjNumber = mjNumber
	if isBrightBu then
		-- 明补
		table.insert(roomPlayer.mjTileBrightBu, barData)
	else
		-- 暗补
		table.insert(roomPlayer.mjTileDarkBu, barData)
	end

	barData.groupNode = self:pungBarReorderMjTiles(seatIdx, mjColor, mjNumber, true, isBrightBu)
end

-- start --
--------------------------------
-- 胡牌之后,牌应该推到
-- end --
-- self:showAllMjTilesWhenWin(seatIdx, msgTbl.m_cardCount, msgTbl.m_cardValue, msgTbl.m_color, msgTbl.m_number)

function MJScene:showAllMjTilesWhenWin(seatIdx, m_cardCount, m_cardValue, m_color, m_number, m_color2, m_number2, isJiepaohu)
	gt.log("胡牌后推牌：seatIdx = "..seatIdx)
	gt.dump(m_cardValue)
	local roomPlayer = self.roomPlayers[seatIdx]
	if roomPlayer == nil then
		return
	end
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	-- 显示碰杠牌
	local groupMjTilesPos = mjTilesReferPos.groupMjTilesPos
	local space = cc.p(groupMjTilesPos[2].x - groupMjTilesPos[1].x, groupMjTilesPos[2].y - groupMjTilesPos[1].y)
	local groupNode = cc.Node:create()
	if roomPlayer.displaySeatIdx == 1 or roomPlayer.displaySeatIdx == 3 then
		groupNode:setPosition(mjTilesReferPos.holdStart)
	else
		groupNode:setPosition(mjTilesReferPos.groupStartPos)
		self.playMjLayer:addChild(groupNode)
	end

	if isJiepaohu then
		-- 移除上家打出的牌
		self:removePreRoomPlayerOutMjTile(m_color, m_number)
	end

	--扣点点，没有选择“暗杠可见”，摊牌时，暗杠应该亮开
	self.DarkBarsShow = false
	for i = 1, #self.m_playtype do
		if self.m_playtype[i] == 18 then
			self.DarkBarsShow = true
		end
	end
	if self.playType == 100002 and not self.DarkBarsShow then
		if roomPlayer.mjTileDarkBars then
			table.foreach(roomPlayer.mjTileDarkBars, function(k, mjTile)
				gt.dump(mjTile)
				local mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, mjTile.mjColor, mjTile.mjNumber, self.isHZLZ)
				if mjTile and mjTile.groupNode then
					table.foreach(mjTile.groupNode:getChildren(), function(m, spr)
						if m == 4 then
							spr:setSpriteFrame(mjTileName)
						end
					end)
				end
			end)
		end
	end

	local cardList = {}
	for i, mjTile in ipairs(m_cardValue) do
		if mjTile[1] == 4 then
			-- table.insert(cardList, 1, mjTile)
			table.insert(cardList, mjTile)
		else
			table.insert(cardList, mjTile)
		end
	end

	local cardListFlag = false
	local finalList = {}
	if self.isHZLZ == true then
		gt.log("红中胡牌")
		for _, mjTile in ipairs(cardList) do
			if isJiepaohu then
				table.insert(finalList, mjTile)
			else
				if (mjTile[1] ~= m_color or mjTile[2] ~= m_number) or cardListFlag == true then
					-- if mjTile[1] == 4 and mjTile[2] == 5 then
					-- 	table.insert(finalList, 1, mjTile)
					-- else
						table.insert(finalList, mjTile)
					-- end
				elseif mjTile[1] == m_color and mjTile[2] == m_number then
					cardListFlag = true
				end
			end
		end
		--dump(finalList)
		gt.log("以上是排序完成")
	else
		gt.log("只是胡牌")
		for _, mjTile in ipairs(cardList) do
			if isJiepaohu then
				table.insert(finalList, mjTile)
			else
				if (mjTile[1] ~= m_color or mjTile[2] ~= m_number) or cardListFlag == true then
					-- if mjTile[1] == 4 and mjTile[2] == 5 then
					-- 	table.insert(finalList, 1, mjTile)
					-- else
						table.insert(finalList, mjTile)
					-- end
				elseif mjTile[1] == m_color and mjTile[2] == m_number then
					cardListFlag = true
				end
			end
		end
	end

	--打个补丁，全球人胡牌的时候胡的牌会显示到外面
	if #finalList <= 1 and roomPlayer.displaySeatIdx == 1 then
		groupNode:setPosition(cc.p(groupNode:getPositionX(), groupNode:getPositionY() - 50))
	end

	-- 所有手牌
	local setPos = groupMjTilesPos[1]
	gt.log("----------------------------------------------setPos.x", setPos.x)
	gt.log("----------------------------------------------setPos.y", setPos.y)
	if roomPlayer.displaySeatIdx == 1 or roomPlayer.displaySeatIdx == 3 then
		setPos = mjTilesReferPos.holdStart
	gt.log("----------------------------------------------mjTilesReferPos.holdStart.x", mjTilesReferPos.holdStart.x)
	gt.log("----------------------------------------------mjTilesReferPos.holdStart.y", mjTilesReferPos.holdStart.y)
	end

	if roomPlayer.displaySeatIdx == 3 then
		setPos.x = setPos.x + 23
		setPos.y = setPos.y + 40
	elseif roomPlayer.displaySeatIdx == 1 then
		setPos.x = setPos.x + 13
		setPos.y = setPos.y - 40
	end

	-- if roomPlayer.displaySeatIdx == 1 then
	-- 	setPos.x = setPos.x + 35
	-- 	setPos.y = setPos.y - 30
	-- end 
	-- for i,mjTile in ipairs(roomPlayer.holdMjTiles) do

	if roomPlayer.displaySeatIdx ~= 4 then
		gt.log("---------------roomPlayer.uid", roomPlayer.uid)
		finalList = self:setSortPlayerMjTiles(finalList)
	end

	local scale = 1.4
	-- for i,mjTile in ipairs(cardList) do
	for i,mjTile in ipairs(finalList) do
		-- local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displaySeatIdx, mjTile[1], mjTile[2])
		local mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, mjTile[1], mjTile[2], self.isHZLZ)
		local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)

		if roomPlayer.displaySeatIdx == 1 or roomPlayer.displaySeatIdx == 3 then
			-- self.playMjLayer:addChild(mjTileSpr, -setPos.y)
			if roomPlayer.displaySeatIdx == 1 then
				self.playMjLayer:addChild(mjTileSpr, (- setPos.x - setPos.y))
			elseif roomPlayer.displaySeatIdx == 3 then
				self.playMjLayer:addChild(mjTileSpr, (setPos.x - setPos.y))
			end
		else
			groupNode:addChild(mjTileSpr, -setPos.y)
		end

		-- 自己推倒牌时,牌放大
		if seatIdx == self.playerSeatIdx then
			local scalePos = cc.p(roomPlayer.mjTilesReferPos.m_huSpace.x * scale, roomPlayer.mjTilesReferPos.m_huSpace.y)
			mjTileSpr:setScale(scale)
			mjTileSpr:setPosition(cc.p(setPos.x + 20, setPos.y + 16))
			setPos = cc.pAdd(setPos, scalePos)
		else
			mjTileSpr:setPosition(setPos)
			setPos = cc.pAdd(setPos, roomPlayer.mjTilesReferPos.m_huSpace)
		end

		--自己对门的牌应该缩小，如果是2人的，对门座位是1，如果是4人的，对门座位是2
		if roomPlayer.displaySeatIdx == 2 then 
			mjTileSpr:setScale(0.66)
		end

		-- 添加耗子牌标识
		if self.HaoZiCards then
			for i,card in ipairs(self.HaoZiCards) do
				if mjTile[1] == card._color and mjTile[2] == card._number then
					self:addMouseMark(mjTileSpr, true, roomPlayer.displaySeatIdx)	
				end		
			end
		end
	end

	-- 胡两张牌时m_color2和m_number2有值
	local cards = {}
	if m_color and m_color ~= 0 and m_number and m_number ~= 0 then
		table.insert(cards, {m_color, m_number})
	end
	if m_color2 and m_color2 ~= 0 and m_number2 and m_number2 ~= 0 then
		table.insert(cards, {m_color2, m_number2})
	end

	local offsetPos = cc.p(0, 0)
	if roomPlayer.displaySeatIdx == 1 then
		offsetPos = cc.p(0-2, 20)
	elseif roomPlayer.displaySeatIdx == 2 then
		offsetPos = cc.p(-10, 0)
	elseif roomPlayer.displaySeatIdx == 3 then
		offsetPos = cc.p(0-2, -20)
	elseif roomPlayer.displaySeatIdx == 4 then
		offsetPos = cc.p(15, 0)
	end
	if seatIdx == self.playerSeatIdx then
		offsetPos = cc.p(35, 16)
	end
	setPos = cc.pAdd(setPos, offsetPos)

	local index = 0
	for k, v in pairs(cards) do
		if v[1] > 0 and v[1] < 5 then
			-- local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displaySeatIdx, v[1], v[2])
			local mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, v[1], v[2], self.isHZLZ)
			local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
			if seatIdx == self.playerSeatIdx then
				mjTileSpr:setScale(scale)
			end
			local offsetSize = cc.p(0, 0)
			if roomPlayer.displaySeatIdx == 1 then
				offsetSize.y = mjTileSpr:getContentSize().height * mjTileSpr:getScaleY()
			elseif roomPlayer.displaySeatIdx == 2 then
				offsetSize.x = -mjTileSpr:getContentSize().width * mjTileSpr:getScaleX()
			elseif roomPlayer.displaySeatIdx == 3 then
				offsetSize.y = -mjTileSpr:getContentSize().height * mjTileSpr:getScaleY()
			elseif roomPlayer.displaySeatIdx == 4 then
				offsetSize.x = mjTileSpr:getContentSize().width * mjTileSpr:getScaleX()
			end
			setPos = cc.pAdd(setPos, cc.p(offsetSize.x*index,offsetSize.y*index))
			mjTileSpr:setPosition(setPos)
			mjTileSpr:setColor(cc.c3b(243, 243, 10))
			if roomPlayer.displaySeatIdx == 1 or roomPlayer.displaySeatIdx == 3 then
				-- self.playMjLayer:addChild(mjTileSpr, -setPos.y)
				if roomPlayer.displaySeatIdx == 1 then
					self.playMjLayer:addChild(mjTileSpr, (- setPos.x - setPos.y))
				elseif roomPlayer.displaySeatIdx == 3 then
					self.playMjLayer:addChild(mjTileSpr, (setPos.x - setPos.y))
				end
			else
				groupNode:addChild(mjTileSpr, -setPos.y)
			end
			-- 添加耗子牌标识
			if self.HaoZiCards then
				for i,card in ipairs(self.HaoZiCards) do
					if v[1] == card._color and v[2] == card._number then
						self:addMouseMark(mjTileSpr, true)	
					end		
				end
			end
			index = index + 1
			--自己对门的牌应该缩小，如果是2人的，对门座位是1，如果是4人的，对门座位是2
			if roomPlayer.displaySeatIdx == 2 then 
				mjTileSpr:setScale(0.66)
			end
		end
	end

	-- 移除立着的牌
	for i, mjTile in ipairs(roomPlayer.holdMjTiles) do
		if mjTile.mjTileSpr then
			mjTile.mjTileSpr:removeFromParent()
		end
	end
	if self.playType == 100004 then
		-- 如果是立四，移除站立的立四手牌
		if #roomPlayer.lisiMjTiles > 0 then
			for i, mjTile in ipairs(roomPlayer.lisiMjTiles) do
				if mjTile.mjTileSpr then
					mjTile.mjTileSpr:removeFromParent()
				end
			end
		end
	end
end


-- start --
--------------------------------
-- @class function
-- @description 碰杠重新排序麻将牌,显示碰杠
-- @param seatIdx
-- @param mjColor
-- @param mjNumber
-- @param isBar
-- @param isBrightBar
-- @return
-- end --
function MJScene:pungBarReorderMjTiles(seatIdx, mjColor, mjNumber, isBar, isBrightBar, isNian, isZhiDui, isPeng, firePos)
	gt.log(debug.traceback())
	-- gt.log("显示碰杠牌，seatIdx="..seatIdx..", mjColor="..mjColor..", mjNumber="..mjNumber..", isBar="..tostring(isBar)..", isBrightBar="..tostring(isBrightBar)..", isNian="..tostring(isNian)..", isZhiDui="..tostring(isZhiDui))
	local roomPlayer = self.roomPlayers[seatIdx]
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	-- 显示碰杠牌
	local groupMjTilesPos = mjTilesReferPos.groupMjTilesPos
	local groupNode = cc.Node:create()
	groupNode:setPosition(mjTilesReferPos.groupStartPos)
	self.playMjLayer:addChild(groupNode)
	local mjTilesCount = 3
	if isBar then
		mjTilesCount = 4
	end
	if isNian then
		mjTilesCount = 2
	end
	if isZhiDui then
		mjTilesCount = 2
	end
	for i = 1, mjTilesCount do
		local mjTileName = nil

		if isBar and not isBrightBar then
			if self:isAnGangKeJian() then
				gt.log("暗杠可见")
				--如果是自己暗杠，显示一张牌
				if i <= 3 then
					-- 暗杠前三张牌扣着
					if roomPlayer.displaySeatIdx == 1 or roomPlayer.displaySeatIdx == 3 then
						mjTileName = string.format("tdbgsgang_%d.png", roomPlayer.displaySeatIdx)
					else
						mjTileName = string.format("tdbgs_%d.png", roomPlayer.displaySeatIdx)
					end
				else
					if type(mjNumber) == "number"  then
						mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber, self.isHZLZ)
					else
						mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, tonumber(mjColor), tonumber(mjNumber[i][1]), self.isHZLZ)
					end
				end
			else
				--暗杠，自己的明一张，别人的全扣
				if seatIdx == self.playerSeatIdx then
					--如果是自己暗杠，显示一张牌
					if i <= 3 then
						-- 暗杠前三张牌扣着
						if roomPlayer.displaySeatIdx == 1 or roomPlayer.displaySeatIdx == 3 then
							mjTileName = string.format("tdbgsgang_%d.png", roomPlayer.displaySeatIdx)
						else
							mjTileName = string.format("tdbgs_%d.png", roomPlayer.displaySeatIdx)
						end
					else
						if type(mjNumber) == "number"  then
							mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber, self.isHZLZ)
						else
							mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, tonumber(mjColor), tonumber(mjNumber[i][1]), self.isHZLZ)
						end
					end
				else
					--如果不是自己暗杠，所有牌都显示成扣着的
					if roomPlayer.displaySeatIdx == 1 or roomPlayer.displaySeatIdx == 3 then
						mjTileName = string.format("tdbgsgang_%d.png", roomPlayer.displaySeatIdx)
					else
						mjTileName = string.format("tdbgs_%d.png", roomPlayer.displaySeatIdx)
					end
				end
			end

		elseif isZhiDui then
			--支对，自己的全明，别人的全扣
			if seatIdx == self.playerSeatIdx then
				if type(mjNumber) == "number"  then
					mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber, self.isHZLZ)
				else
					mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, tonumber(mjColor), tonumber(mjNumber[i][1]), self.isHZLZ)
				end
			else
				if roomPlayer.displaySeatIdx == 1 or roomPlayer.displaySeatIdx == 3 then
					mjTileName = string.format("tdbgsgang_%d.png", roomPlayer.displaySeatIdx)
				else
					mjTileName = string.format("tdbgs_%d.png", roomPlayer.displaySeatIdx)
				end
			end
		else
			if type(mjNumber) == "number"  then
				mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber, self.isHZLZ)
			else
				mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, tonumber(mjColor), tonumber(mjNumber[i][1]), self.isHZLZ)
			end
		end

		-- if isBar and not isBrightBar and i <= 3 then
		-- 	-- 暗杠前三张牌扣着
		-- 	mjTileName = string.format("tdbgs_%d.png", roomPlayer.displaySeatIdx)
		-- else
		-- 	if type(mjNumber) == "number"  then
		-- 		-- mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displaySeatIdx, mjColor, mjNumber)
		-- 		mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber, self.isHZLZ)
		-- 	else
		-- 		-- mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displaySeatIdx, tonumber(mjColor), tonumber(mjNumber[i][1]))
		-- 		mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, tonumber(mjColor), tonumber(mjNumber[i][1]), self.isHZLZ)
		-- 	end
		-- end
		if not string.find(mjTileName, "0") then
			local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
			mjTileSpr:setPosition(groupMjTilesPos[i])
			mjTileSpr:setTag(i)
			if not isBar and not isZhiDui and roomPlayer.displaySeatIdx == 2 then
				--如果是对门玩家的牌,且不是杠和支对，改成正的牌之后要缩小
				-- mjTileSpr:setScale(0.66)
			end
			if isBar and isBrightBar and roomPlayer.displaySeatIdx == 2 then
				--如果是对门明杠，明杠的牌缩小
				-- mjTileSpr:setScale(0.66)
			end
			-- if roomPlayer.displaySeatIdx == 2 then
			-- 	mjTileSpr:setScale(0.66)
			-- end
			if roomPlayer.displaySeatIdx == 1 then
				mjTileSpr:setScale(0.8)
			elseif roomPlayer.displaySeatIdx == 2 then
				mjTileSpr:setScale(0.66)
			elseif roomPlayer.displaySeatIdx == 3 then
				mjTileSpr:setScale(0.8)
			end
			gt.log("-----------isBrightBar", isBrightBar)
			if i == 4 and not isBrightBar then
				-- 添加耗子牌标识
				if self.HaoZiCards then
					for i,card in ipairs(self.HaoZiCards) do
						if tonumber(mjColor) == card._color and tonumber(mjNumber) == card._number then
							self:addMouseMark(mjTileSpr, true, roomPlayer.displaySeatIdx)	
						end		
					end
				end
			elseif isBrightBar then
				-- 添加耗子牌标识
				if self.HaoZiCards then
					for i,card in ipairs(self.HaoZiCards) do
						if tonumber(mjColor) == card._color and tonumber(mjNumber) == card._number then
							self:addMouseMark(mjTileSpr, true, roomPlayer.displaySeatIdx)	
						end		
					end
				end
			elseif not isBar then
				-- 添加耗子牌标识
				if self.HaoZiCards then
					for i,card in ipairs(self.HaoZiCards) do
						if tonumber(mjColor) == card._color and tonumber(mjNumber) == card._number then
							self:addMouseMark(mjTileSpr, true, roomPlayer.displaySeatIdx)	
						end		
					end
				end
			end
			groupNode:addChild(mjTileSpr)
		end
		-- 碰牌箭头
		-- roomPlayer.displaySeatIdx self.curShowSeatIdx
		gt.log("-----------------firePos", firePos)
		if firePos ~= nil then
			-- if self.playersType == 2 then
			-- 	if roomPlayer.seatIdx == 1 then
			-- 		self.curShowSeatIdx = 4 - self.seatOffset <= 0 and 4 or 3
			-- 	elseif roomPlayer.seatIdx == 2 then
			-- 		self.curShowSeatIdx = 4 - self.seatOffset == 1 and 4 or 1
			-- 	end
			-- elseif self.playersType == 3 then
			-- 	if self.playerSeatIdx == 1 then
			-- 		if roomPlayer.seatIdx == 2 then
			-- 			self.curShowSeatIdx = 1
			-- 		elseif roomPlayer.seatIdx == 3 then
			-- 			self.curShowSeatIdx = 3
			-- 		end
			-- 	elseif self.playerSeatIdx == 2 then
			-- 		if roomPlayer.seatIdx == 3 then
			-- 			self.curShowSeatIdx = 1
			-- 		elseif roomPlayer.seatIdx == 1 then
			-- 			self.curShowSeatIdx = 3
			-- 		end
			-- 	elseif self.playerSeatIdx == 3 then
			-- 		if roomPlayer.seatIdx == 1 then
			-- 			self.curShowSeatIdx = 1
			-- 		elseif roomPlayer.seatIdx == 2 then
			-- 			self.curShowSeatIdx = 3
			-- 		end
			-- 	end
			-- else
				self.curShowSeatIdx = (firePos + self.seatOffset) % 4 == 0 and 4 or (firePos + self.seatOffset) % 4
			-- end
		end
		gt.log("--------------------self.seatOffset", self.seatOffset)
		gt.log("--------------------roomPlayer.displaySeatIdx", roomPlayer.displaySeatIdx)
		gt.log("--------------------self.curShowSeatIdx", self.curShowSeatIdx)
		if self.curShowSeatIdx ~= nil and roomPlayer.displaySeatIdx ~= self.curShowSeatIdx then
			local SpriteFrameName = "sx_img_table_direction"..roomPlayer.displaySeatIdx.."_"..self.curShowSeatIdx..".png"
			local directionSpr = cc.Sprite:createWithSpriteFrameName(SpriteFrameName)
			if roomPlayer.displaySeatIdx == 4 then
				if isBar and isBrightBar then
					groupNode:addChild(directionSpr)
					directionSpr:setPosition(cc.p(82, 70))
				elseif not isBar then
					groupNode:addChild(directionSpr)
					directionSpr:setPosition(cc.p(82, 55))
				end
			elseif roomPlayer.displaySeatIdx == 3 then
				if isBrightBar then
					groupNode:addChild(directionSpr)
					directionSpr:setPosition(cc.p(30, 77))
				elseif not isBar then
					groupNode:addChild(directionSpr)
					directionSpr:setPosition(cc.p(33, 65))
				end
			elseif roomPlayer.displaySeatIdx == 2 then
				if isBrightBar then
					groupNode:addChild(directionSpr)
					directionSpr:setPosition(cc.p(54, 56))
				elseif not isBar then
					groupNode:addChild(directionSpr)
					directionSpr:setPosition(cc.p(54, 46))
				end
			elseif roomPlayer.displaySeatIdx == 1 then
				if isBrightBar then
					groupNode:addChild(directionSpr)
					directionSpr:setPosition(cc.p(43, 65))
				elseif not isBar then
					groupNode:addChild(directionSpr)
					directionSpr:setPosition(cc.p(40, 50))
				end
			end
		end
	end
	mjTilesReferPos.groupStartPos = cc.pAdd(mjTilesReferPos.groupStartPos, mjTilesReferPos.groupSpace)
	if roomPlayer.displaySeatIdx == 4 or roomPlayer.displaySeatIdx == 2 then
		mjTilesReferPos.holdStart = cc.pAdd(mjTilesReferPos.holdStart, mjTilesReferPos.groupSpace)
	end
	mjTilesReferPos.holdStart = mjTilesReferPos.holdStart
	gt.log("手牌基础位置 222222 ============= ")
	--dump(mjTilesReferPos.holdStart)

	-- 更新持有牌显示位置
	if seatIdx == self.playerSeatIdx then
		-- 玩家自己
		-- 碰2张
		local mjTilesCount = 2
		if isBar then
			-- 明杠3张
			mjTilesCount = 3
			-- 暗杠4张
			if not isBrightBar then
				mjTilesCount = 4
			end
		end
		if isNian then
			mjTilesCount = 1
		end
		if isZhiDui then
			mjTilesCount = 2
		end
		gt.log("吃碰杠粘支对时，更新持有牌数量："..mjTilesCount)
		if type(mjNumber) == "number" then
			gt.log("碰杠去牌 111111")
			if not self.pung then
				local filterMjTilesCount = 0
				local transMjTiles = {}
				if self.playType == 100004 then
					-- 如果是立四玩法，检测立四手牌中是否有这张牌，如果有，删之
					gt.log("立四手牌长度："..#roomPlayer.lisiMjTiles)
					local tempList = {}      --临时表
					for i, mjTile in ipairs(roomPlayer.lisiMjTiles) do
						gt.log("碰杠后从立四手牌中去牌，filterMjTilesCount="..filterMjTilesCount..", mjTilesCount="..mjTilesCount)
						if filterMjTilesCount < mjTilesCount and mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
							gt.log("碰杠后从立四手牌中去牌 111")
							mjTile.mjTileSpr:removeFromParent()
							-- table.remove(roomPlayer.lisiMjTiles, i)
							filterMjTilesCount = filterMjTilesCount + 1
						else
							-- 保存其它牌
							table.insert(tempList, mjTile)
						end
					end
					roomPlayer.lisiMjTiles = tempList
					for i, mjTile in ipairs(roomPlayer.holdMjTiles) do
						if filterMjTilesCount < mjTilesCount and mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
							mjTile.mjTileSpr:removeFromParent()
							filterMjTilesCount = filterMjTilesCount + 1
						else
							-- 保存其它牌,去除碰杠牌
							table.insert(transMjTiles, mjTile)
						end
					end
				else
					if self.playMjLayer:getChildByName("holdMjNode") then
						self.holdMjNode:removeAllChildren()
					end
					for i, mjTile in ipairs(roomPlayer.holdMjTiles) do
						if filterMjTilesCount < mjTilesCount and mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
							-- mjTile.mjTileSpr:removeFromParent()
							filterMjTilesCount = filterMjTilesCount + 1
						else
							-- 保存其它牌,去除碰杠牌
							table.insert(transMjTiles, mjTile)
						end
					end
				end

				-- for i, mjTile in ipairs(roomPlayer.holdMjTiles) do
				-- 	if filterMjTilesCount < mjTilesCount and mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
				-- 		mjTile.mjTileSpr:removeFromParent()
				-- 		filterMjTilesCount = filterMjTilesCount + 1
				-- 	else
				-- 		if self.playType == 100004 then
				-- 			-- 如果是立四玩法，检测立四手牌中是否有这张牌，如果有，删之
				-- 			for i, mjTile in ipairs(roomPlayer.lisiMjTiles) do
				-- 				if filterMjTilesCount < mjTilesCount and mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
				-- 					mjTile.mjTileSpr:removeFromParent()
				-- 					table.remove(roomPlayer.lisiMjTiles, i)
				-- 					filterMjTilesCount = filterMjTilesCount + 1
				-- 				end
				-- 			end
				-- 		end
				-- 		-- 保存其它牌,去除碰杠牌
				-- 		table.insert(transMjTiles, mjTile)
				-- 	end
				-- end
				
				roomPlayer.holdMjTiles = transMjTiles
				for i = #roomPlayer.holdMjTiles, 1, -1 do
					local mjTile = roomPlayer.holdMjTiles[i]
					if mjTile.mjTileSpr then
						self:updateMjTileToPlayer(mjTile.mjTileSpr)
					end
				end
				gt.log("碰杠后手牌数量 ============= "..#roomPlayer.holdMjTiles)
				--dump(roomPlayer.holdMjTiles)
			end
		else
			gt.log("碰杠去牌 222222")
			local removeTable = {}
			local num = 3
			if isNian then
				num = 2
			end
			if isZhiDui then
				--支对去2张
				num = 2
			end
			for j = 1, num do
				if tonumber(mjNumber[j][2]) ~= tonumber(1) then
					table.insert(removeTable, {mjNumber[j][1], mjNumber[j][3]})
				end
			end

			-- 已移除队列
			if self.playMjLayer:getChildByName("holdMjNode") then
				self.holdMjNode:removeAllChildren()
			end
			local hasRemoved = {}
			if #removeTable > 0 then
				for i, mjTile in ipairs(roomPlayer.holdMjTiles) do
					if mjTile.mjNumber == removeTable[1][1] and  mjTile.mjColor == removeTable[1][2] then
						-- mjTile.mjTileSpr:removeFromParent()
						table.remove(roomPlayer.holdMjTiles, i)
						table.insert(hasRemoved, mjTile)
						break
					end
				end
				for i, mjTile in ipairs(roomPlayer.holdMjTiles) do
					if mjTile.mjNumber == removeTable[2][1] and mjTile.mjColor == removeTable[2][2] then
						-- mjTile.mjTileSpr:removeFromParent()
						table.remove(roomPlayer.holdMjTiles, i)
						table.insert(hasRemoved, mjTile)
						break
					end
				end
			end
			for i = #roomPlayer.holdMjTiles, 1, -1 do
				local mjTile = roomPlayer.holdMjTiles[i]
				if mjTile.mjTileSpr then
					self:updateMjTileToPlayer(mjTile.mjTileSpr)
				end
			end
		end

		-- 如果是立四玩法，重新摆放立四牌位置
		if self.playType == 100004 then
			--显示立四牌
			self:showLisiMjTile()
		end

		-- 重新排序现持有牌
		self:sortPlayerMjTiles(isPeng)
	else
		local mjTilesReferPos = roomPlayer.mjTilesReferPos
		local mjTilePos = mjTilesReferPos.holdStart
		for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
			mjTile.mjTileSpr:setPosition(mjTilePos)
			-- self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height - mjTilePos.y))
			-- if roomPlayer.displaySeatIdx == 1 then
			-- 	self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height - mjTilePos.x - mjTilePos.y))
			-- else
			-- 	self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height + mjTilePos.x - mjTilePos.y))
			-- end
			mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
		end
	end

	return groupNode
end

-- start --
--------------------------------
-- @class function
-- @description 自摸碰变成明杠
-- @param seatIdx
-- @param mjColor
-- @param mjNumber
-- end --
function MJScene:changePungToBrightBar(seatIdx, mjColor, mjNumber)
	gt.log("-------------------changePungToBrightBar")
	local roomPlayer = self.roomPlayers[seatIdx]
	if seatIdx == self.playerSeatIdx then
		if self.playMjLayer:getChildByName("holdMjNode") then
			self.holdMjNode:removeAllChildren()
		end
		for i, mjTile in ipairs(roomPlayer.holdMjTiles) do
			if mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
				-- mjTile.mjTileSpr:removeFromParent()
				table.remove(roomPlayer.holdMjTiles, i)
				break
			end
		end
		for i = #roomPlayer.holdMjTiles, 1, -1 do
			local mjTile = roomPlayer.holdMjTiles[i]
			if mjTile.mjTileSpr then
				self:updateMjTileToPlayer(mjTile.mjTileSpr)
			end
		end
		if self.playType == 100004 then 
			--如果是立四玩法，且当前是听牌这一手，则移除立四手牌中的已出牌
			gt.log("如果是立四玩法，则移除立四手牌中的已出牌")
			local isLisiRemove = false
			for i, mjTile in ipairs(roomPlayer.lisiMjTiles) do
				if mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
					mjTile.mjTileSpr:removeFromParent()
					table.remove(roomPlayer.lisiMjTiles, i)
					break
				end
			end
		end
	else
		roomPlayer.holdMjTiles[roomPlayer.mjTilesRemainCount].mjTileSpr:setVisible(false)
		roomPlayer.mjTilesRemainCount = roomPlayer.mjTilesRemainCount - 1
	end

	-- 查找碰牌
	local brightBarData = nil
	for i, pungData in ipairs(roomPlayer.mjTilePungs) do
		if pungData.mjColor == mjColor and pungData.mjNumber == mjNumber then
			-- 从碰牌列表中删除
			brightBarData = pungData
			table.remove(roomPlayer.mjTilePungs, i)
			break
		end
	end

	self:showLisiMjTile()
	self:sortPlayerMjTiles()

	-- 添加到明杠列表
	if brightBarData then
		-- 加入杠牌第4个牌
		local mjTilesReferPos = roomPlayer.mjTilesReferPos
		local groupMjTilesPos = mjTilesReferPos.groupMjTilesPos
		-- local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displaySeatIdx, mjColor, mjNumber)
		local mjTileName = Utils.getMJTileResName(roomPlayer.displaySeatIdx, mjColor, mjNumber, self.isHZLZ)
		local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
		mjTileSpr:setPosition(groupMjTilesPos[4])
		-- if roomPlayer.displaySeatIdx == 2 then
		-- 	mjTileSpr:setScale(0.66)
		-- end
		if roomPlayer.displaySeatIdx == 1 then
			mjTileSpr:setScale(0.8)
		elseif roomPlayer.displaySeatIdx == 2 then
			mjTileSpr:setScale(0.66)
		elseif roomPlayer.displaySeatIdx == 3 then
			mjTileSpr:setScale(0.8)
		end
		brightBarData.groupNode:addChild(mjTileSpr)
		table.insert(roomPlayer.mjTileBrightBars, brightBarData)
		if self.curShowSeatIdx ~= nil and roomPlayer.displaySeatIdx ~= self.curShowSeatIdx then
			--杠牌箭头
			local SpriteFrameName = "sx_img_table_direction"..roomPlayer.displaySeatIdx.."_"..self.curShowSeatIdx..".png"
			local directionSpr = cc.Sprite:createWithSpriteFrameName(SpriteFrameName)
			brightBarData.groupNode:addChild(directionSpr)
			if roomPlayer.displaySeatIdx == 4 then
				directionSpr:setPosition(cc.p(82, 52))
			elseif roomPlayer.displaySeatIdx == 3 then
				directionSpr:setPosition(cc.p(39, 68))
			elseif roomPlayer.displaySeatIdx == 2 then
				directionSpr:setPosition(cc.p(54, 51))
			elseif roomPlayer.displaySeatIdx == 1 then
				directionSpr:setPosition(cc.p(31, 68))
			end
		end
	end

	-- 重置牌的颜色
	if roomPlayer.mjTileBrightBars then
		table.foreach(roomPlayer.mjTileBrightBars, function(k, mjTile)
			if mjTile and mjTile.groupNode then
				table.foreach(mjTile.groupNode:getChildren(), function(m, spr)
					self:stopCardEffect(spr)
				end)
			end
		end)
	end
end

function MJScene:getHuName(_type)
	local namelist = {
		"hu",
		"haohuaqixiaodui",
		"qixiaodui",
		"qingyise",
		"jiangjianghu",
		"pengpenghu",
		"quanqiuren",
		"gangshangkaihua",
		"gangshangpao",
		"haidilaoyue",
		"haidipao",
		"qiangganghu",
		"hu",
		"shuanghaohuaqixiaodui",
		"tianhu",
		"dihu",
	}
	return namelist[_type]
end

function MJScene:getHuTime(_type)
	local timelist = {
		85,
		100,
		95,
		95,
		90,
		96,
		100,
		100,
		95,
		100,
		100,
		95,
		85,
		95,
		85,
		85,
	}
	return (timelist[_type] or 85) / 60
end

function MJScene:getHuPosition(_displaySeatIdx)
	local cy = 480
	local poslist = {
		cc.p(display.cx + 330, cy - 100),
		cc.p(display.cx, cy + 80),
		cc.p(display.cx - 250, cy - 100),
		cc.p(display.cx, cy - 280),
	}
	return poslist[_displaySeatIdx]
end

function MJScene:getChiPosition(_displaySeatIdx)
	local poslist = {
		cc.p(display.cx + 330, display.cy - 100),
		cc.p(display.cx, display.cy + 80),
		cc.p(display.cx - 250, display.cy - 100),
		cc.p(display.cx, display.cy - 280),
	}
	return poslist[_displaySeatIdx]
end


function MJScene:setAnchorPosition(_node, _displaySeatIdx)
	if _displaySeatIdx == 1 then
		_node:setAnchorPoint(1, 0.5)
	elseif _displaySeatIdx == 2 then
		_node:setAnchorPoint(0.5, 1)
	elseif _displaySeatIdx == 3 then
		_node:setAnchorPoint(0, 0.5)
	elseif _displaySeatIdx == 4 then
		_node:setAnchorPoint(0.5, 0)
	end
end

function MJScene:addHuEffect(_sprite, _action, _name, _type)
	if not self.m_huEffect then
		self.m_huEffect = {}
	end
	if #self.m_huEffect > 1 then
		self.huAnimationTime = self.huAnimationTime + self:getHuTime(_type)
	end
	-- getAnimationInfo
	table.insert(self.m_huEffect, {sprite = _sprite, action = _action, name = _name})
end

function MJScene:playHuEffect(_groupNode)
	if #self.m_huEffect > 0 then
		local action = self.m_huEffect[1].action
		local name = self.m_huEffect[1].name
		local sprite = self.m_huEffect[1].sprite
		if action then
			sprite:setVisible(true)
			action:play(name, false)
		end
		local delayTime2 = 3
		if action then
			delayTime2 = action:getEndFrame() / 60
		end
		local delayTime = cc.DelayTime:create(delayTime2)
		local callFunc = cc.CallFunc:create(function(sender)
			sender:removeFromParent()
			table.remove(self.m_huEffect, 1)
			self:playHuEffect(_groupNode)
		end)
		sprite:runAction(cc.Sequence:create(delayTime, callFunc))
	end
end

function MJScene:playEffect(_name, pos)
	local decisionSignSpr, action = gt.createCSAnimation("animation/" .. _name .. ".csb")
	action:play(_name, false)
	decisionSignSpr:setPosition(pos)
	local delayTime = cc.DelayTime:create(action:getEndFrame() / 60)
	local callFunc = cc.CallFunc:create(function(sender)
		sender:removeFromParent()
	end)
	local seqAction = cc.Sequence:create(delayTime, callFunc)
	decisionSignSpr:runAction(seqAction)
	return decisionSignSpr
end

-- start --
--------------------------------
-- @class function
-- @description 显示玩家接炮胡，自摸胡，明杠，暗杠，碰动画显示
-- @param seatIdx 座位索引
-- @param decisionType 决策类型
-- end --
function MJScene:showDecisionAnimation(seatIdx, decisionType, huCard)
	-- 接炮胡，自摸胡，明杠，暗杠，碰文件后缀
	local decisionSuffixs = {1, 4, 2, 2, 3, 5}
	local decisionSfx = {"hu", "zimo", "gang", "angang", "peng", "chi", "ting"}
	local animationNameSfx = {"hu", "zimo", "gang", "gang", "peng", "chi", "ting"}
	-- 显示决策标识
	local roomPlayer = self.roomPlayers[seatIdx]
	local decisionSignSpr = nil
	local action = nil
	decisionSignSpr = self:playEffect(animationNameSfx[decisionType], self:getHuPosition(roomPlayer.displaySeatIdx))
	decisionSignSpr:setScale(0.7)
	self.rootNode:addChild(decisionSignSpr, MJScene.ZOrder.DECISION_SHOW)

	if decisionType == 1 or decisionType == 2 then
		if not roomPlayer.isFirstHu then -- 没有胡过
			roomPlayer.isFirstHu = 1
		else
			roomPlayer.isFirstHu = roomPlayer.isFirstHu + 1
		end
	end
	-- dj revise
	gt.log("播放打牌声音  111111")
	gt.soundManager:PlaySpeakSound(roomPlayer.sex, decisionSfx[decisionType], roomPlayer)
end

-- start --
--------------------------------
-- @class function
-- @description 显示出牌动画
-- @param seatIdx 座次
-- end --
function MJScene:showMjTileAnimation(seatIdx, startPos, mjColor, mjNumber, cbFunc, isNeedKouPai)
	gt.log("显示出牌动画")
	local mjTilePos = startPos

	local roomPlayer = self.roomPlayers[seatIdx]
	local rotateAngle = {-90, 180, 90, 0}

	-- local mjTileName = string.format("p4s%d_%d.png", mjColor, mjNumber)
	local mjTileName = Utils.getMJTileResName(4, mjColor, mjNumber, self.isHZLZ, 1)
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	if isNeedKouPai then
		--如果需要扣牌，则扣牌
		local mjTileName = "tdbgs_4.png"
		mjTileSpr:initWithSpriteFrameName(mjTileName)
		mjTileSpr:setScale(1.6)
	end
	-- mjTileSpr:setScale(1.6)
	local outlineSpr = cc.Sprite:create("images/otherImages/showMjTileFrame.png")
	-- outlineSpr:setScale(0.85)
	local outCardNode = cc.Node:create()
	outCardNode:addChild(outlineSpr)
	outCardNode:addChild(mjTileSpr)
	self.rootNode:addChild(outCardNode, 98)

	self.startMjTileAnimation = outCardNode
	self.startMjTileColor = mjColor
	self.startMjTileNumber	= mjNumber

	-- outCardNode:setPosition(mjTilePos)
	outCardNode:setPosition(roomPlayer.mjTilesReferPos.showMjTilePos)
	local totalTime = 0.05
	local moveToAc_1 = cc.MoveTo:create(totalTime, roomPlayer.mjTilesReferPos.showMjTilePos)
	local rotateToAc_1 = cc.ScaleTo:create(totalTime, 1)

	local delayTime = cc.DelayTime:create(0.8)

	if seatIdx == 4 then
		-- gt.log("我就是我！")
		delayTime = cc.DelayTime:create(2)
	end


	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.outStart	
	local mjTilesCount = #roomPlayer.outMjTiles + 1
	local lineCount = math.ceil(mjTilesCount / mjTilePerLine[self.playersType][roomPlayer.displaySeatIdx].lineCount) - 1
	local lineIdx = mjTilesCount - lineCount * mjTilePerLine[self.playersType][roomPlayer.displaySeatIdx].lineCount - 1
	local lineCount = math.ceil(mjTilesCount / 10) - 1
	local lineIdx = mjTilesCount - lineCount * 10 - 1
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))

	local moveToAc_2 = cc.MoveTo:create(totalTime, mjTilePos)
	local rotateToAc_2 = cc.ScaleTo:create(totalTime, 1.0)

	local callFunc = cc.CallFunc:create(function(sender)
		sender:removeFromParent()
		self.startMjTileAnimation = nil
		cbFunc()
		gt.log("出牌动画播放完毕，移除牌")
	end)
	outCardNode:runAction(cc.Sequence:create(cc.Spawn:create(moveToAc_1, rotateToAc_1),
										delayTime,
										-- cc.Spawn:create(moveToAc_2, rotateToAc_2),
										callFunc))
end

function MJScene:reset()
	-- 玩家手势隐藏
	self:hidePlayersReadySign()

	self.playMjLayer:removeAllChildren()
end

function MJScene:reloginWhenError(eventType, errmsg)
	gt.log("收到错误需要重连的消息==================")
	local seatCount = 0
	local allCount = 0
	local curId = gt.playerData.uid
	local curTime = os.date()
	local deskId = self.roomID
	local curCircle = 0
	local hasSeat = false
	local pai = ""

	if gt.gameStart then
		gt.log("=====================开始游戏了")
		curCircle = self.m_curCircle
		for i = 1, 4 do
			local roomPlayer = self.roomPlayers[i]
			if roomPlayer ~= nil then
				seatCount = seatCount + 1
				if roomPlayer.uid == gt.playerData.uid then
					hasSeat = true
					if roomPlayer.holdMjTiles and roomPlayer.holdMjTiles ~= nil and type(roomPlayer.holdMjTiles) == "table" then
						-- 手牌
					   	for i, v in pairs(roomPlayer.holdMjTiles) do
					   		pai = pai..tostring(v.mjColor)..tostring(v.mjNumber)..","
						end
					end
					pai = pai..",碰："
					if roomPlayer.mjTilePungs and roomPlayer.mjTilePungs ~= nil and type(roomPlayer.mjTilePungs) == "table" then
						-- 碰牌
						for i, v in pairs(roomPlayer.mjTilePungs) do
							pai = pai..tostring(v.mjColor)..tostring(v.mjNumber)..","
						end
					end
					pai = pai..",明杠："
					if roomPlayer.mjTileBrightBars and roomPlayer.mjTileBrightBars ~= nil and type(roomPlayer.mjTileBrightBars) == "table" then
						-- 明杠牌
						for i, v in pairs(roomPlayer.mjTileBrightBars) do
							pai = pai..tostring(v.mjColor)..tostring(v.mjNumber)..","
						end
					end
					pai = pai..",暗杠："
					if roomPlayer.mjTileDarkBars and roomPlayer.mjTileDarkBars ~= nil and type(roomPlayer.mjTileDarkBars) == "table" then
						-- 暗杠牌
						for i, v in pairs(roomPlayer.mjTileDarkBars) do
							pai = pai..tostring(v.mjColor)..tostring(v.mjNumber)..","
						end
					end
				end
			end
		end
	else
		gt.log("=====================未开始游戏")
		for i = 1, 4 do
			local roomPlayer = self.roomPlayers[i]
			if roomPlayer ~= nil then
				seatCount = seatCount + 1
				if roomPlayer.uid == gt.playerData.uid then
					hasSeat = true
				end
			end
		end
	end

	gt.log("=====================游戏所有人")
	for k, v in pairs(self.roomPlayers) do
		allCount = allCount + 1
	end

	gt.log("=====================这里开始收集消息")
	gt.log("user_id:"..curId)
	gt.log("seatCount:"..seatCount)
	gt.log("time:"..curTime)
	gt.log("roomId:"..deskId)
	gt.log("curCircle:"..curCircle)
	gt.log("allCount:"..allCount)
	gt.log("hasSeat:"..tostring(hasSeat))
	local basic = tostring(os.time())..",user:"..curId..",seat_count:"..seatCount..",room_no:"..deskId..",round:"..curCircle..",all_count:"..allCount..",hasSeat:"..tostring(hasSeat)..",time:"..curTime
	gt.log("basic:"..basic..", pai:"..pai)
	gt.log("errmsg:", errmsg)
	gt.log("================这里结束收集消息=================")
	if buglyReportLuaException then
        buglyReportLuaException(tostring(basic..",pai:"..pai), errmsg)
    end

    local log = {}
    log.basic = basic
    log.pai = pai
    log.errmsg = errmsg
	if self.AppVersion and self.AppVersion > 10 then
	    gt.dumplog(log)
	end

    -- gt.isShowOfflineLoading = false
    -- gt.isShowOfflineTips = false
	-- gt.socketClient:reloginServer()
end

function MJScene:backMainSceneEvt(eventType, isRoomCreater, roomID)
	if self.playerHeadMgr then
		self.playerHeadMgr:clear()
	end
	-- 事件回调
	gt.removeTargetAllEventListener(self)
	-- 消息回调
	if self["unregisterAllMsgListener"] then
		self:unregisterAllMsgListener()
	end

	local function onMainScene()
		local mainScene = require("client/game/majiang/MainScene"):create(false, isRoomCreater, roomID, self.m_numberMark)
		cc.Director:getInstance():replaceScene(mainScene)
		if isRoomCreater ~= nil then
			if gt.CreateRoomFlag == false or gt.isCreateUserId == false then
				if gt.clubId == nil or tonumber(gt.clubId) == 0 then
					Toast.showToast(mainScene, "您已退出该房间", 2)
				end
			end
		end
	end
	-- Utils.cleanMWAction()

	-- if isRoomCreater and roomID then -- 返回大厅
	-- 	onMainScene()
	-- else
	-- 	if  not self.roomPlayers[1] then
	-- 		onMainScene()
	-- 	elseif self.roomPlayers[1].displaySeatIdx == 4 or (not isRoomCreater and roomID) then
	-- 		onMainScene()
	-- 	else
	-- 		require("client/game/dialog/NoticeTipsCommon"):create(2, "房主：" .. self.roomPlayers[self.m_fangzhuPos].nickname .. "已经解散房间" .. self.roomID .. "，请加入新的房间", onMainScene)
	-- 	end 
	-- end

	onMainScene()
end

function MJScene:createFlimLayer(flimLayerType,cardList)
	-- 一个麻将
	-- local mjTileName = string.format("p4s%d_%d.png", 2, 2)
	local mjTileName = Utils.getMJTileResName(4, 2, 2, self.isHZLZ)
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	local width_oneMJ = mjTileSpr:getContentSize().width
	local space_gang = 20
	local width = 30+mjTileSpr:getContentSize().width*4*(#cardList)+space_gang*(#cardList-1)
	local height = 24+mjTileSpr:getContentSize().height

	local flimLayer = cc.LayerColor:create(cc.c4b(85, 85, 85, 0), width, height)
	flimLayer:setContentSize(cc.size(width,height))
	local function onTouchBegan(touch, event)
		return true
	end

	-- 添加半透明底
	local image_bg = ccui.ImageView:create()
	image_bg:loadTexture("images/otherImages/laoyue_bg.png")
	image_bg:setScale9Enabled(true)
	image_bg:setCapInsets(cc.rect(10,10,1,1))
	image_bg:setContentSize(cc.size(width,height))
	image_bg:setAnchorPoint(cc.p(0,0))
	flimLayer:addChild(image_bg)

	if flimLayerType ~= MJScene.FLIMTYPE.FLIMLAYER_TING then
		gt.log("MJScene:createFlimLayer 11")
		-- 创建麻将
		for idx,value in ipairs(cardList) do
			local flag = value.flag
			local mjColor = value.mjColor
			local mjNumber = value.mjNumber

			-- local mjSprName = string.format("p4s%d_%d.png", mjColor, mjNumber)
			local mjSprName = Utils.getMJTileResName(4, mjColor, mjNumber, self.isHZLZ)
			for i=1,4 do
				local button = ccui.Button:create()
				button:loadTextures(mjSprName,mjSprName,"",ccui.TextureResType.plistType)
				button:setTouchEnabled(true)
	    		button:setAnchorPoint(cc.p(0,0))
	    		button:setPosition(cc.p(15+space_gang*(idx-1)+width_oneMJ*(i-1)+width_oneMJ*4*(idx-1), 10))
	   			button:setTag(idx)
	   			flimLayer:addChild(button)

	    		local function touchEvent(ref, type)
	       			if type == ccui.TouchEventType.ended then
	        		 	self.isPlayerDecision = false

						local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
						selfDrawnDcsNode:setVisible(false)

						-- 发送消息
						local cardData = cardList[ref:getTag()]
						local msgToSend = {}
						msgToSend.kMId = gt.CG_SHOW_MJTILE
						msgToSend.kType = cardData.flag
						msgToSend.kThink = {}
						local think_temp = {cardData.mjColor,cardData.mjNumber}
						table.insert(msgToSend.kThink,think_temp)
						gt.socketClient:sendMessage(msgToSend)
						if self.AppVersion and self.AppVersion > 10 then
							gt.dumplog(msgToSend)
							gt.dumplog(self.roomPlayers)
						end

						-- 删除弹出框（杠）
						self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BAR)
						-- 删除弹出框（补）
						self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BU)
						-- 删除弹出框（听）
						self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_TING)
	       		 	end
	  	  		end
	   	 		button:addTouchEventListener(touchEvent)
			end
		end
	else
		-- 创建麻将
		gt.log("MJScene:createFlimLayer 22")
		for idx,value in ipairs(cardList) do
			gt.log("MJScene:createFlimLayer 33")
			local flag = value.flag
			local mjColor = value.mjColor
			local mjNumber = value.mjNumber

			-- local mjSprName = string.format("p4s%d_%d.png", mjColor, mjNumber)
			local mjSprName = Utils.getMJTileResName(4, mjColor, mjNumber, self.isHZLZ)
			local button = ccui.Button:create()
			button:loadTextures(mjSprName,mjSprName,"",ccui.TextureResType.plistType)
			button:setTouchEnabled(true)
    		button:setAnchorPoint(cc.p(0,0))
    		button:setPosition(cc.p(15+space_gang*(idx-1)+width_oneMJ*(idx-1)+width_oneMJ*4*(idx-1), 10))
   			button:setTag(idx)
   			flimLayer:addChild(button)
   			gt.log("MJScene:createFlimLayer 44")

    		local function touchEvent(ref, type)
       			if type == ccui.TouchEventType.ended then
        		 	self.isPlayerDecision = false

					local selfDrawnDcsNode = gt.seekNodeByName(self.rootNode, "Node_selfDrawnDecision")
					selfDrawnDcsNode:setVisible(false)

					
					-- 发送消息
					local cardData = cardList[ref:getTag()]
					local msgToSend = {}
					msgToSend.kMId = gt.CG_SHOW_MJTILE
					msgToSend.kType = cardData.flag
					msgToSend.kThink = {}
					local think_temp = {cardData.mjColor,cardData.mjNumber}
					table.insert(msgToSend.kThink,think_temp)
					gt.socketClient:sendMessage(msgToSend)
					if self.AppVersion and self.AppVersion > 10 then
						gt.dumplog(msgToSend)
						gt.dumplog(self.roomPlayers)
					end

					-- 删除弹出框（杠）
					self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BAR)
					-- 删除弹出框（补）
					self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_BU)
					-- 删除弹出框（听）
					self:removeFlimLayer(MJScene.FLIMTYPE.FLIMLAYER_TING)
       		 	end
  	  		end
   	 		button:addTouchEventListener(touchEvent)
		end
	end
	return flimLayer
end

function MJScene:removeFlimLayer(flimLayerType)
	local child = self:getChildByTag(MJScene.TAG.FLIMLAYER_BAR)

	if flimLayerType == MJScene.FLIMTYPE.FLIMLAYER_BAR then
		child = self:getChildByTag(MJScene.TAG.FLIMLAYER_BAR)
	elseif flimLayerType == MJScene.FLIMTYPE.FLIMLAYER_BU then
		child = self:getChildByTag(MJScene.TAG.FLIMLAYER_BU)
	elseif flimLayerType == MJScene.FLIMTYPE.FLIMLAYER_TING then
		child = self:getChildByTag(MJScene.TAG.FLIMLAYER_TING)
	else

	end

	if not child then
		return
	end

	child:removeFromParent()

end

--------------------------------
-- @class function
-- @description 显示海底捞月
-- @param isShow 显示标志
-- end --
function MJScene:LaoYueNodeVisible(isShow)
	-- body
	local laoYueNode = gt.seekNodeByName(self.rootNode, "Node_Laoyue")
	if(isShow)then
		self.rootNode:reorderChild(laoYueNode, MJScene.ZOrder.HAIDILAOYUE)
		laoYueNode:setVisible(true)
		local yaoBtn = gt.seekNodeByName(laoYueNode, "Btn_yao")
		local guoBtn = gt.seekNodeByName(laoYueNode, "Btn_guo")
		gt.addBtnPressedListener(yaoBtn, function ( )
			laoYueNode:setVisible(false)
			self.isPlayerDecision = false
			local msgToSend = {}
			msgToSend.kMId = gt.CG_CHOOSE_HAIDI
			msgToSend.kFlag = 1
			gt.socketClient:sendMessage(msgToSend)

		end)
		gt.addBtnPressedListener(guoBtn, function ( )
			laoYueNode:setVisible(false)
			self.isPlayerDecision = false
			local msgToSend = {}
			msgToSend.kMId = gt.CG_CHOOSE_HAIDI
			msgToSend.kFlag = 0
			gt.socketClient:sendMessage(msgToSend)
		end)
	else
		if laoYueNode ~= nil then
			laoYueNode:setVisible(false)
		end
	end
end

-- @class function
-- @description 通知玩家决策海底捞月
-- @param msgTbl
-- end --
function MJScene:onHaidiRcvMakeDescision(msgTbl)
	-- body
	local seatIdx = msgTbl.kPos + 1
	self:setTurnSeatSign(seatIdx)
	

	if seatIdx == self.playerSeatIdx then
		-- 玩家决策
		self.isPlayerDecision = true
		self:LaoYueNodeVisible(true)
	else
		self:LaoYueNodeVisible(false)
	end

end

function MJScene:showHaidiInLayer(msgTbl)
	self.isPlayerDecision = true
	self.haveHaidiPai = true
	local dipaiNode = gt.seekNodeByName(self.rootNode, "Node_HaidiPai")
	dipaiNode:setVisible( true )
	local spr = gt.seekNodeByName(dipaiNode, "Sprite_pai")
	-- spr:setSpriteFrame(string.format("p4s%d_%d.png", msgTbl.m_color, msgTbl.m_number))
	spr:setSpriteFrame(Utils.getMJTileResName(4, msgTbl.kColor, msgTbl.kNumber, self.isHZLZ))

	self:stopAllActions()
	local delayTime = cc.DelayTime:create(self.haidCardShowTime)
	local callFunc = cc.CallFunc:create(function(sender)
		-- if self.roundReportMsg then
			self.isPlayerDecision = false
			self.haveHaidiPai = false
			dipaiNode:setVisible( false )
			-- self:onRcvRoundReport(self.roundReportMsg)
		-- end
	end)

	local seqAction = cc.Sequence:create(delayTime, callFunc)
	self:runAction(seqAction)
end

function MJScene:startAudio()
	--测试录音
	gt.log("开始录音 ============== ")
	self.isRecording = true
	self:getLuaBridge()
	if gt.isIOSPlatform() then
		-- local ok, ret = self.luaBridge.callStaticMethod("AppController", "startVoice",
		-- 		{recodePath = gt.audioPath})
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "startVoice")
	elseif gt.isAndroidPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "startVoice",nil,"()Z")
	end

end

function MJScene:stopAudio()
	--停止录音
	gt.log("停止录音 ============== ")
	self.isRecording = false
	self:getLuaBridge()
	if gt.isIOSPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "stopVoice")
	elseif gt.isAndroidPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "stopVoice",nil,"()Z")
	end

	local getUrl = function ()
		-- body
		self:getLuaBridge()
		local ok, ret
		if gt.isIOSPlatform() then
			ok, ret = self.luaBridge.callStaticMethod("AppController", "getVoiceUrl")
			gt.log("the ret is .." ..tostring(ret))
		elseif gt.isAndroidPlatform() then
			ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getVoiceUrl", nil, "()Ljava/lang/String;")
			gt.log("the ret is .." .. ret)
		end

		if string.len(ret) > 0 and self.checkVoiceUrlType then
			gt.log("_______the ret is .." .. ret)

			self.checkVoiceUrlType = false

			--获得到地址上传给服务器
			local msgToSend = {}
			msgToSend.kMId = gt.CG_CHAT_MSG
			msgToSend.kType = 4 -- 语音聊天
			msgToSend.kMusicUrl = ret
			gt.socketClient:sendMessage(msgToSend)

			gt.scheduler:unscheduleScriptEntry(self.voiceUrlScheduleHandler)
			self.voiceUrlScheduleHandler = nil
		end
	end
	gt.log("------------------- start check voice url")
	self.checkVoiceUrlType = true
	if self.voiceUrlScheduleHandler then
		gt.scheduler:unscheduleScriptEntry(self.voiceUrlScheduleHandler)
		self.voiceUrlScheduleHandler = nil
	end
	self.voiceUrlScheduleHandler = gt.scheduler:scheduleScriptFunc(getUrl, 1/60, false)

end

function MJScene:cancelAudio()
	self:getLuaBridge()
	if gt.isIOSPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "cancelVoice")
	elseif gt.isAndroidPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "cancelVoice",nil,"()Z")
	end
end

function MJScene:getMJTileResName()
	local resName = ""

	return resName
end

-- seatIdx: 1~4 的数值　
function MJScene:getDisplaySeat(seatIdx)
	gt.log("获取实际座位：self.playersType = "..self.playersType)

	local displaySeatIdx = 1
	-- 当前出牌座位
	-- if self.playersType == 2 then
	-- 	if self.playerSeatIdx == 1 then
	-- 		if seatIdx == 2 then
	-- 			displaySeatIdx = 1
	-- 		else
	-- 			displaySeatIdx = 4
	-- 		end
	-- 	elseif self.playerSeatIdx == 2 then
	-- 		if seatIdx == 2 then
	-- 			displaySeatIdx = 4
	-- 		else
	-- 			displaySeatIdx = 1
	-- 		end
	-- 	end
	-- elseif self.playersType == 3 then
	-- 	if self.playerSeatIdx == 1 then
	-- 		if seatIdx == 1 then
	-- 			displaySeatIdx = 4
	-- 		elseif seatIdx == 2 then
	-- 			displaySeatIdx = 1
	-- 		elseif seatIdx == 3 then
	-- 			displaySeatIdx = 3
	-- 		end
	-- 	elseif self.playerSeatIdx == 2 then
	-- 		if seatIdx == 1 then
	-- 			displaySeatIdx = 3
	-- 		elseif seatIdx == 2 then
	-- 			displaySeatIdx = 4
	-- 		else
	-- 			displaySeatIdx = 1
	-- 		end
	-- 	elseif self.playerSeatIdx == 3 then
	-- 		if seatIdx == 1 then
	-- 			displaySeatIdx = 1
	-- 		elseif seatIdx == 2 then
	-- 			displaySeatIdx = 3
	-- 		else
	-- 			displaySeatIdx = 4
	-- 		end
	-- 	end
	-- else
	-- 	-- displaySeatIdx = seatIdx
	-- 	local realSeat = (seatIdx+self.seatOffset+gt.totalPlayerNum)%4
	--   	if realSeat == 0 then
	--   		realSeat = 4
	--   	end
	--   	displaySeatIdx = realSeat
	-- end

	-- if self.playersType == 2 then
	-- 	if seatIdx == 1 then
	-- 		displaySeatIdx = 4 - self.seatOffset <= 0 and 4 or 3
	-- 	elseif seatIdx == 2 then
	-- 		displaySeatIdx = 4 - self.seatOffset == 1 and 4 or 1
	-- 	end
	-- elseif self.playersType == 3 then
	-- 	if self.playerSeatIdx == 1 then
	-- 		if roomPlayer.seatIdx == 2 then
	-- 			displaySeatIdx = 1
	-- 		elseif roomPlayer.seatIdx == 3 then
	-- 			displaySeatIdx = 3
	-- 		end
	-- 	elseif self.playerSeatIdx == 2 then
	-- 		if roomPlayer.seatIdx == 3 then
	-- 			displaySeatIdx = 1
	-- 		elseif roomPlayer.seatIdx == 1 then
	-- 			displaySeatIdx = 3
	-- 		end
	-- 	elseif self.playerSeatIdx == 3 then
	-- 		if roomPlayer.seatIdx == 1 then
	-- 			displaySeatIdx = 1
	-- 		elseif roomPlayer.seatIdx == 2 then
	-- 			displaySeatIdx = 3
	-- 		end
	-- 	end
	-- else
		displaySeatIdx = (seatIdx - 1 + self.seatOffset) % 4  == 0 and 0 or (seatIdx - 1 + self.seatOffset) % 4
	-- end
	-- displaySeatIdx = 3

	gt.log("getDisplaySeat  self.playerSeatIdx=" .. self.playerSeatIdx .. ", seatIdx=" .. seatIdx .. ", displaySeatIdx=" .. displaySeatIdx)
	return displaySeatIdx
end
function MJScene:addMouseMark(mjTileSpr, isPublic, displaySeatIdx)
	local imgname = "img_table_mouse"
	local imgfile = ""
	-- if gt.createType == 2 or gt.createType == 8 then
		imgfile = "sx_img_table_mouse.png"
	-- elseif gt.createType == 5 then
	-- 	imgfile = "sx_img_table_jin.png"
	-- end
	if mjTileSpr and not mjTileSpr:getChildByName(imgname) then
		local imgtablemouse = ccui.ImageView:create(imgfile,1)
		imgtablemouse:setName(imgname)
		local mjsize = mjTileSpr:getContentSize()
		local tablemousesize = imgtablemouse:getContentSize()
		if isPublic == true then
			imgtablemouse:setScale(0.66)
			if displaySeatIdx == 3 then
				imgtablemouse:setPosition(mjsize.width - tablemousesize.width/2 - 13, mjsize.height - tablemousesize.height + 8 )
				imgtablemouse:setRotation(90)
				imgtablemouse:setScale(0.5)
			elseif displaySeatIdx == 1 then
				imgtablemouse:setPosition(mjsize.width - tablemousesize.width/2 - 43, mjsize.height - tablemousesize.height + 22)
				imgtablemouse:setRotation(-90)
				imgtablemouse:setScale(0.5)
			else
				imgtablemouse:setPosition(mjsize.width - tablemousesize.width/2 - 2, mjsize.height - tablemousesize.height + 17)
			end
		else
			imgtablemouse:setPosition(mjsize.width - tablemousesize.width/2 - 2, mjsize.height - tablemousesize.height-1)
		end
		mjTileSpr:addChild(imgtablemouse)
	end
end
function MJScene:haoziListInCardTable(node,count)
	local mjTileList = {}
	for k = 1 ,count do
		local Spr_mjTile = gt.seekNodeByName(node, "Spr_mjTile"..k)
		-- local Spr_bg = gt.seekNodeByName(node, "Img_bg"..k)
		-- local Spr_name = gt.seekNodeByName(node, "Image_name"..k)
		Spr_mjTile:setVisible(false)
		-- Spr_bg:setVisible(false)
		-- Spr_name:setVisible(false)
		mjTileList[k] = { _Spr_mjTile = Spr_mjTile, _Spr_bg = Spr_bg ,_Spr_name = Spr_name }
	end
	return mjTileList
end
--是否有暗杠可见
function MJScene:isAnGangKeJian()
	for k,v in pairs(self.m_playtype) do
		if v == gt.PLAYTYPE.PT_AnGangKeJian then
			return true
		end
	end
	return false
end

-----------------------
--截取字符串
--@return 按需截取字符串成多段等长度的
function MJScene:getCutString(sName,nShowCount)
    if sName == nil or nShowCount == nil then
        return
    end
    local sStr = sName
    local tCode = {}
    local tName = {}
    local nLenInByte = #sStr
    local nWidth = 0
    for i=1,nLenInByte do
        local curByte = string.byte(sStr, i)
        local byteCount = 0
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
            table.insert(tCode,1)
        end
    end
    
    local _len = 0
    local strArr = {}
    local count = 1
    sName = ""
    for i=1,#tName do
        sName = sName .. tName[i]
        _len = _len + tCode[i]
        if _len >= nShowCount * count then
            count = count + 1
            table.insert(strArr, sName)
            sName = ""
        elseif i == #tName then
        	table.insert(strArr, sName)
        end
    end
    return strArr
end

--计算可胡的牌剩余的数量
function MJScene:surplusMjCount(mjInfo)
	local surplusMjCount = 0
	gt.log("-----------------------self.playerSeatIdx", self.playerSeatIdx)
	for i = 1, 4 do
		local roomPlayer = self.roomPlayers[i]

		if roomPlayer then	
			if i == self.playerSeatIdx then
				-- 手持牌
				if roomPlayer.holdMjTiles then
					for i, v in pairs(roomPlayer.holdMjTiles) do
						if mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
							surplusMjCount = surplusMjCount + 1
						end
					end
				end
			end

			local outMjTilesFlag = false
		    -- 已出牌
		    if roomPlayer.outMjTiles then
				for i, v in pairs(roomPlayer.outMjTiles) do
					if mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
						surplusMjCount = surplusMjCount + 1
						outMjTilesFlag = true
					end
				end
			end
			if outMjTilesFlag then
				if self.KouPaiData then
					for i, v in pairs(self.KouPaiData) do
						if v.mjColor and v.mjNumber and mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
							surplusMjCount = surplusMjCount - 1
						end
					end
				end
				if surplusMjCount < 0 then
					surplusMjCount = 0
				end
			end

			-- 碰牌
			if roomPlayer.mjTilePungs then
				for i, v in pairs(roomPlayer.mjTilePungs) do
					if mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
						surplusMjCount = surplusMjCount + 3
					end
				end
			end

			-- 粘牌
			if roomPlayer.mjTileNians then
				for i, v in pairs(roomPlayer.mjTileNians) do
					if mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
						surplusMjCount = surplusMjCount + 2
					end
				end
			end

			-- 明杠牌
			if roomPlayer.mjTileBrightBars then
				for i, v in pairs(roomPlayer.mjTileBrightBars) do
					if mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
						surplusMjCount = surplusMjCount + 4
					end
				end
			end

			if self.DarkBarsShow then
				-- 暗杠牌
				if roomPlayer.mjTileDarkBars then
					for i, v in pairs(roomPlayer.mjTileDarkBars) do
						if mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
							surplusMjCount = surplusMjCount + 4
						end
					end
				end
			else
				if i == self.playerSeatIdx then
					-- 暗杠牌
					if roomPlayer.mjTileDarkBars then
						for i, v in pairs(roomPlayer.mjTileDarkBars) do
							if mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
								surplusMjCount = surplusMjCount + 4
							end
						end
					end
				end
			end

			-- 吃牌
			if roomPlayer.mjTileEat then
				for i, v in pairs(roomPlayer.mjTileEat) do
					if mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
						surplusMjCount = surplusMjCount + 3
					end
				end
			end

			-- 明补牌
			if roomPlayer.mjTileBrightBu then
				for i, v in pairs(roomPlayer.mjTileBrightBu) do
					if mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
						surplusMjCount = surplusMjCount + 4
					end
				end
			end

			-- 暗补牌
			if roomPlayer.mjTileDarkBu then
				for i, v in pairs(roomPlayer.mjTileDarkBu) do
					if mjInfo.mjColor == v.mjColor and mjInfo.mjNumber == v.mjNumber then
						surplusMjCount = surplusMjCount + 4
					end
				end
			end
		end
	end

	return 4 - surplusMjCount < 0 and 0 or 4 - surplusMjCount
end

--播放选座动画
function MJScene:playSelectSeatAni(_playerSeatIdx)
	local SelectSeatSpr = cc.Sprite:createWithSpriteFrameName("sx_img_animation".._playerSeatIdx..".png")  --创建精灵
	self.csbNode:addChild(SelectSeatSpr, 999)
	SelectSeatSpr:setScale(0.1)
	SelectSeatSpr:setOpacity(0)
	SelectSeatSpr:setPosition(cc.p(640, 400))

	gt.soundManager:PlayPositionSound(gt.wxSex, _playerSeatIdx)
	local ScaleTo = cc.ScaleTo:create(1, 1)
	local FadeTo = cc.FadeTo:create(1, 255)
	local moveTo = cc.MoveTo:create(1, cc.p(640, 600))
    local showAni = cc.Spawn:create(ScaleTo, FadeTo, moveTo)
    SelectSeatSpr:runAction(cc.Sequence:create(showAni, 
    	cc.FadeTo:create(1, 255), 
    	cc.FadeTo:create(2, 0),
    	cc.CallFunc:create(function()
			local backBtn = gt.seekNodeByName(self.rootNode, "Btn_back")
			backBtn:setEnabled(true)
		end)
		))
    self.SelectSeatSpr = SelectSeatSpr

	if _playerSeatIdx == 1 then
		return
	end

	local playerSeatIdx = _playerSeatIdx - 1
    local turnPosLayerSpr = gt.seekNodeByName(self.csbNode,"Spr_turnPosLayer")
    turnPosLayerSpr:setVisible(false)

 	local stop = function()
 		if self.positionTurnSchedulerEntry then
 			gt.scheduler:unscheduleScriptEntry(self.positionTurnSchedulerEntry)
 			self.positionTurnSchedulerEntry = nil
    		local turnPosBgSpr = gt.seekNodeByName(self.csbNode, "Spr_turnPosBg")
 			turnPosBgSpr:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("sx_img_table_turntable".._playerSeatIdx..".png"))
 			local gamelogospr = cc.Sprite:createWithSpriteFrameName("sx_img_gamelogo.png")
 			if self.positionTurnAnimateNode then
	 			self.positionTurnAnimateNode:addChild(gamelogospr)
	 			gamelogospr:setPosition(cc.p(self.positionTurnAnimateNode:getContentSize().width/2,
	 			self.positionTurnAnimateNode:getContentSize().height/2-5))
				gamelogospr:setOpacity(0)
			    gamelogospr:runAction(cc.FadeTo:create(2, 255))
			end
 		end
 	end

	local positionTurnAnimateNode, positionTurnAnimate = gt.createCSAnimation("res/animation/PositionTurn/"..playerSeatIdx.."/PositionTurn"..playerSeatIdx..".csb")
	local mahjong_table = gt.seekNodeByName(self.rootNode, "mahjong_table")
	self.rootNode:addChild(positionTurnAnimateNode, 999)
	positionTurnAnimateNode:setPosition(cc.p(mahjong_table:getContentSize().width/2,400))
	positionTurnAnimate:play("run", false)
	self.positionTurnAnimateNode = positionTurnAnimateNode

    self.positionTurnSchedulerEntry = gt.scheduler:scheduleScriptFunc(stop, 0.8, false)
end

-- 设置计时器
function MJScene:setGameClock(displaySeatIdx, _time)
	local time = clone(_time)
	gt.log("---------time", time)
    -- GameLayer.super.setGameClock(self,chair,id,time)
    -- local viewid = self:GetClockViewID()
    -- if viewid and viewid ~= yl.INVALID_CHAIR then
        local progress = self.m_TimeProgress[displaySeatIdx]
        if progress ~= nil then
            if self._time[displaySeatIdx] then
                gt.scheduler:unscheduleScriptEntry(self._time[displaySeatIdx])
                self._time[displaySeatIdx] = nil
            end
            if time == 0.1 then
                if self.m_clockFrameSprite and self.m_clockFrameSprite[displaySeatIdx] then
	            	self.m_clockFrameSprite[displaySeatIdx]:setColor(cc.c3b(255,0,0))
                end
	        end

            time = time - 0.5
            -- local r = 0
            -- local g = 255
            -- local b = 0
           -- local idx = 255/time*2
            local max = time
            self._time[displaySeatIdx] = gt.scheduler:scheduleScriptFunc(function()
				if time == 3 then
			        gt.soundEngine:playEffect("common/timeup_alarm", false, true, "mp3")
			    end
        
                time = time - 0.5
                if time%1 == 0 then
                	if self.m_clockLabel and self.m_clockLabel[displaySeatIdx] then
                    	self.m_clockLabel[displaySeatIdx]:setString(time)
                	end
                end
                local tmp = time/max
                if time <= 0 then
                    if self._time[displaySeatIdx] then
                        gt.scheduler:unscheduleScriptEntry(self._time[displaySeatIdx])
                        self._time[displaySeatIdx] = nil
                    end
                end
                local g = 255 * tmp
                local r = 255 - g
                local b = 0
                if g <= 0 then g = 0 end
                if r >= 255 then r = 255 end
                if self.m_clockFrameSprite and self.m_clockFrameSprite[displaySeatIdx] then
                    self.m_clockFrameSprite[displaySeatIdx]:setColor(cc.c3b(r,g,b))
                end
				self.clockSprite[displaySeatIdx]:setVisible(true)
            end,0.5,false)
            progress:setPercentage((60-_time)/60*100)
            progress:setVisible(true)
            gt.log("----------_time", _time)
            progress:runAction(cc.Sequence:create(cc.ProgressFromTo:create(_time, (60-_time)/60*100, 100), cc.CallFunc:create(function()
                -- progress:setVisible(false)
                progress:stopAllActions()
            end)))
        end
    -- end
end

-- 定位
-- function MJScene:PlayerLocationInformation(msgTbl)
-- 	local playerDistanceTab = {}
-- 	gt.location = msgTbl.m_datas
-- 	local setPlayerId = nil
-- 	local seatIdx = 1
-- 	local othersPos = {}
-- 	for k,v in pairs(gt.location) do
-- 		seatIdx = v.m_pos + 1
-- 		if self.playerSeatIdx ~= seatIdx then
-- 			local pos = v
-- 			pos.nickname = self.roomPlayers[seatIdx].nickname
-- 			table.insert(othersPos, pos)
-- 		end
-- 	end

-- 	local tempDistance = 0
-- 	local minDistance = 400

-- 	if self.playersType == 2 then
-- 		minDistance = -1
-- 	elseif self.playersType == 3 then
-- 		minDistance = 100
-- 	end

-- 	local index = 1
-- 	while index < #othersPos do
-- 		tempDistance = tempDistance + Utils.getDistance(othersPos[index].m_latitude, othersPos[index].m_longitue, othersPos[index+1].m_latitude, othersPos[index+1].m_longitue)
-- 		index = index + 1
-- 	end

-- 	if minDistance > 0 then
-- 		if tempDistance <=  minDistance then
-- 			-- playerDistanceTab 中的人离得都进	
-- 		else
-- 			tempDistance = 0
-- 			index = 1
-- 			while index <= #othersPos do

-- 				if index < #othersPos then
-- 					tempDistance = Utils.getDistance(othersPos[index].m_latitude, othersPos[index].m_longitue, othersPos[index+1].m_latitude, othersPos[index+1].m_longitue)
-- 					if tempDistance <= 100 then
-- 						-- othersPos[index].nickname  othersPos[index+1].nickname 离得近
-- 						break
-- 					end
-- 				else
-- 					tempDistance = Utils.getDistance(othersPos[index].m_latitude, othersPos[index].m_longitue, othersPos[1].m_latitude, othersPos[1].m_longitue)
-- 					if tempDistance <= 100 then
-- 						-- othersPos[index].nickname  othersPos[1].nickname 离得近

-- 					end
-- 				end
-- 				index = index + 1
-- 			end
-- 		end
-- 	end

-- end



-- csw 11-13

function MJScene:addAction11_9_node_tmp(_,type,card_type)
	self:addAction11_9_node(type,card_type)
end

function MJScene:addAction11_9_node(_type,num)

	-- 1 特殊牌型
	-- 2 连输八场
	-- 3 完成场次
	-- 4 大赢家
		-- cardType  特殊牌型 牌值
	if self.shz and _type == 1 then return end

	if _type == 1 then 
		if #self.roomPlayers ~= 4 then return end
	end

	gt.log("_type................",_type,num)

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local PublishURL = gt.getLucky
	if num then 
		PublishURL = PublishURL.."&type=".._type.."&card_type[]="..num.."&play_type="..tonumber(self.playType).."&"
	else
		PublishURL = PublishURL.."&type=".._type.."&"
	end
	PublishURL = gt.getUrlEncryCode(PublishURL,gt.playerData.uid)
	gt.log("url....",PublishURL)
	xhr:open("GET", PublishURL)
	local function onResp()
		local runningScene = display.getRunningScene()
		gt.log("name...............",runningScene.name)
	   	if runningScene and runningScene.name == "MJScene" then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	            local response = xhr.response
	            local respJson = require("cjson").decode(response)
	            	gt.log("_type................1",_type,num)
	            gt.dump(respJson)

	     		if respJson.errno == 0 then
	     				
	     				local complete = false
	     				if respJson.data.lucky_cards and #respJson.data.lucky_cards.list>0 then 
	     					for i = 1 , #respJson.data.lucky_cards.list do 
	     						if tonumber(respJson.data.lucky_cards.list[i].total_count) == tonumber(respJson.data.lucky_cards.list[i].count) then complete = true break end
	     					end
	     				end
	     				if respJson.data.even_tasks and #respJson.data.even_tasks.list > 0 then
	     					complete = true
	     				end


	     				if (respJson.data.even_tasks and #respJson.data.even_tasks.list > 0) or (respJson.data.lucky_cards and #respJson.data.lucky_cards.list>0) then 

	     					if  self.caidai and complete then
	     						self.caidai:stopAllActions()
	     						self.caidai:setVisible(true)
	     						local action = cc.CSLoader:createTimeline("yanhua.csb")
	     						self.caidai:runAction(action)
	     						action:gotoFrameAndPlay(0,false)
	     						action:setFrameEventCallFunc(function(frameEventName)
								local name = frameEventName:getEvent()
									gt.log("name...........",name)
									if name == "_end" then
										self.caidai:setVisible(false)
										if respJson.data.even_tasks and #respJson.data.even_tasks.list > 0 then 
											for i = 1 ,#respJson.data.even_tasks.list do
					     				        -- -- 财神普惠
					 							local Activity_node = require("client/game/activity/Activity_node"):create(respJson.data.even_tasks.list[i])
				      							self:addChild(Activity_node,81)
					     					end
										end
										if respJson.data.lucky_cards and #respJson.data.lucky_cards.list>0 then 
												for i = 1 , #respJson.data.lucky_cards.list do
						     				       --------gt运卡
							     					local Activity_node1 = require("client/game/activity/lucky_node"):create(respJson.data.lucky_cards.list[i],"P")
							     					self:addChild(Activity_node1,81)
								     			end

										end
									end
								end)
	     					else
	     						if respJson.data.even_tasks then 
	     						for i = 1 ,#respJson.data.even_tasks.list do
		     				        -- -- 财神普惠
		 							local Activity_node = require("client/game/activity/Activity_node"):create(respJson.data.even_tasks.list[i])
	      							self:addChild(Activity_node,81)
		     					end
		     					end
		     					if respJson.data.lucky_cards then 
		     					for i = 1 , #respJson.data.lucky_cards.list do
		     				       --------gt运卡
			     					local Activity_node1 = require("client/game/activity/lucky_node"):create(respJson.data.lucky_cards.list[i],"P")
			     					self:addChild(Activity_node1,81)
				     			end
				     			end
	     					end

	     				end
		     			

	 			else
	                Toast.showToast(self, respJson.errmsg, 2)
	            end
			elseif xhr.readyState == 1 and xhr.status == 0 then
				gt.log("err_______________")
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()


	 -- -- 财神普惠
	 -- local Activity_node = require("app/views/Activity_node"):create()
  --    self:addChild(Activity_node,81)
     




end


return MJScene