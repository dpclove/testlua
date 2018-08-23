local gt = cc.exports.gt

local PlaySceneWuRen = class("PlaySceneWuRen", gt.include("baseGame"))

PlaySceneWuRen.__index = PlaySceneWuRen

PlaySceneWuRen.ZOrder = {
	MJTABLE						= 1,
	PLAYER_INFO					= 2,
	MJTILES						= 6,
	OUTMJTILE_SIGN				= 7,
	DECISION_BTN				= 8,
	DECISION_SHOW				= 9,
	PLAYER_INFO_TIPS			= 10,
	REPORT						= 16,
	DISMISS_ROOM				= 17,
	SETTING						= 18,
	CHAT						= 20,
	MJBAR_ANIMATION				= 21,
	FLIMLAYER           	    = 16,
	HAIDILAOYUE					= 23,
	GANG_AFTER_CHI_PENG			= 15,
    
	OVER_SCORE              = 65,-- 满分结束
	ROUND_REPORT				= 66 ,-- 单局结算界面显示在总结算界面之上
	DECISION_NEW                = 67,
	MOON_FREE_CARD              = 80,-- 中秋节免费送房卡活动弹框
}

PlaySceneWuRen.ColorType = {
	-- 大小王
	KING				= 0x40,
	-- 黑桃
	HEITAO				= 0x30,
	-- 红桃
	HONGTAO				= 0x20,
	-- 梅花
	MEIHUA				= 0x10,
	-- 方片
	FANGPIAN			= 0x00
}

local ptChat = {cc.p(131,199.52+120),cc.p(1164,527+120),cc.p(870,670+120),cc.p(527,670+120),cc.p(131,527+120)}
local _scheduler = gt._scheduler
local p_idx = 97

function PlaySceneWuRen:switch_bg(i)
        i = i or 1
     self:findNodeByName("Img_bk"):loadTexture("sd/desk/bb"..i..".png")
end

function PlaySceneWuRen:init(enterRoomMsgTbl)
	gt.log("进入桌子界面 =========PlaySceneWuRen======== ")
	dump(enterRoomMsgTbl)
	-- local csbNode = gt.createCSAnimation("PlayScene.csb")
    
    self:findNodeByName("Text_39"):setString("v:1")
    
    self:switch_bg(cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgTypewrbf", 2))

    if cc.UserDefault:getInstance():getIntegerForKey("_SETTING_", 1) == 1 then 
        cc.UserDefault:getInstance():setIntegerForKey("_SETTING_", 0)
        if self:getChildByName("_settinr_node_") then self:getChildByName("_settinr_node_"):removeFromParent() end
        local settingPanel = require("client/game/majiang/Setting"):create(self)
        settingPanel:setName("_settinr_node_")
        self:addChild(settingPanel, 17)
    end

	-- csbNode:setAnchorPoint(0.5, 0.5)
	-- csbNode:setPosition(gt.winCenter)
	-- self:addChild(csbNode)
    self.rootNode = self._node
    --======公用数据======
    --玩家总人数
	self.numPlayer = 5
    --叫分的玩家位置
    self.kNextSelectScorePos = 0
    --叫的分数
    self.MaxSelectScore = 0

    --自己的手牌
    self.holdCards = {}
    
    --自己的手牌值
    self.holdCardsNum = {}

    --庄家座位号
    self.zhuangPos = 0
    
    --是否在埋底
    self.isMaiDi = false

	--选副庄家的牌
    self.selectZhuangNum = 0

    --玩家选的主牌
    self.MainColor = 0
    --当前出牌的玩家
    self.turnPos = 0;

    self.playerFixDispSeat = 5
    self.roomPlayers = {}
    self.tmp_player = {}
    self.tmp_ready = {}
    self.gz_card = {}
    self.tmp_maidi_card = {}
   
    --底分
    self.isDiFen = 1
    if enterRoomMsgTbl.kPlaytype[1] == 1 then
    elseif enterRoomMsgTbl.kPlaytype[1] == 2 then
        self.isDiFen = 2
    elseif enterRoomMsgTbl.kPlaytype[1] == 3 then
        self.isDiFen = 3
    end

    -- 2是否是常主
    self.isChangZhu = false
    if enterRoomMsgTbl.kPlaytype[2] == 1 then
        self.isChangZhu = true
    end

    --选副庄是否含10
    self.isHan10 = false
    if enterRoomMsgTbl.kPlaytype[4] == 1 then
        self.isHan10 = true
    end
    --同ip是否能进入
    self.tongIPs = false
    if enterRoomMsgTbl.kGpsLimit == 1 then
        self.tongIPs = true
    end

    --是否是防作弊房间
    self.isFangZuobi = false
    if enterRoomMsgTbl.kPlaytype[5] == 1 then
        self.isFangZuobi = true
    end

    --是否是闲家扣抵
    self.xianKouDi = false
    if enterRoomMsgTbl.kPlaytype[6] == 1 then
        self.xianKouDi = true
    end

    --是否交牌 0不交 1. 8分  2. 12分  
    self.isJiaoPai = 0
    if enterRoomMsgTbl.kPlaytype[7] == 0 then
        self.isJiaoPai = 0
    elseif enterRoomMsgTbl.kPlaytype[7] == 1 then
        self.isJiaoPai = 8
    elseif enterRoomMsgTbl.kPlaytype[7] == 2 then
        self.isJiaoPai = 12
    end

    self.isGuanZhan = false
    if enterRoomMsgTbl.kAllowLookOn == 1 then self.isGuanZhan = true end
    self.isRenYiFen = false
    if enterRoomMsgTbl.kPlaytype[8] == 1 then self.isRenYiFen = true end

    -- 每轮第一个玩家出的牌
    self.roundFirstCard = -1

    --上一轮玩家出的牌
    self.preRoundCards = {}
    --本轮玩家出的牌
    self.curRoundCards = {}

    --满105结束使用
    self.isOneHaveChild = false

    --游戏是否结束,0未结束,1结束
    self.isGameOver = 0

    --底牌
    self.lastCards = {}

    -- 断线重连后,当前所选牌,索引等需要清理掉
	self.chooseCard = nil
	self.chooseCardIdx = nil
	self.preClickCard = nil
    self.isCanTouch = false
    --选中中的按钮
    self.xuanZhuangBtn = {}

    --出牌时候选择的牌
    self.selectCard = 0
    --本轮出最大牌的人
    self.curBigpos = 0
    --当前局数
    self.curDeskCount = 0
     --埋底中的牌
    self.maidiCards = {}
     --底分
    self.difen = enterRoomMsgTbl.kPlaytype[1]
    --最大局数
    self.maxDeskCount = enterRoomMsgTbl.kMaxCircle
    --房间号
    self.roomid = enterRoomMsgTbl.kDeskId
    
    --本地倒计时时间
    self.timeNumber = 0
    self.timeJiaopai = 0

    self.jiaoPaiOneVisible = 0

    --105倒计时
    -- self.release105Time = -1

    --防作弊房间玩家头像
    self.localHeadImg = {}
    --总结数据
    self.zongjieData = {}
    self.first_game = true

   -- 头像下载管理器
	local playerHeadMgr = gt.include("view/PlayerHeadManager"):create()
	self.rootNode:addChild(playerHeadMgr)
	self.playerHeadMgr = playerHeadMgr
    
    self.m_UserChatView ={}
    self.m_UserChat = {}
    self._voice = {}
    self._voice_node = {}
    self._voice_nodes = {}
    for i = 1, 5 do 
        self.gz_card[i] = {}
        local node =  gt.seekNodeByName(self.rootNode, "Node_player" .. i)
        gt.seekNodeByName(node, "Img_ready"):setVisible(false)
        self.m_UserChatView[i] = display.newSprite((i ~= 2 and "game_chat_s0.png" or "game_chat_s1.png")    ,{scale9 = true ,capInsets=cc.rect(30, 14, 46, 20)})
            :setAnchorPoint(i ~= 2  and cc.p(0,0.5) or cc.p(1,0.5))
            :move(ptChat[i])
            :setVisible(false)
            :addTo(self._node)


        self.m_UserChatView[i]:setPositionY(self.m_UserChatView[i]:getPositionY()-120)

        self._voice[i] = self:findNodeByName("voice_"..i)
                :setVisible(false)
        self._voice[i]:setScaleX(0.5)
        self._voice[i]:setScaleY(0.75)
        self._voice[i]:setPositionY(self._voice[i]:getPositionY()+10)
        self._voice_node[i] = self:findNodeByName("FileNode_"..i)
                    :setVisible(false)
      
        self._voice_node[i]:setPosition(self._voice[i]:getPositionX(),self._voice[i]:getPositionY() + 2)
        if i == 2 then
            self._voice_node[i]:setRotation(180)
        end
        for j = 1 , 10 do
            self.gz_card[i][j] = nil
        end
    end


    self:initBind(enterRoomMsgTbl)



    self.p_g = self:findNodeByName("guanzhan_text")
    self.p_g:setVisible(enterRoomMsgTbl.kAllowLookOn == 0)
    self:findNodeByName("guancha"):setVisible(enterRoomMsgTbl.kAllowLookOn ~= 0)


	-- 玩家进入房间
    gt.log("----------enterRoomMsgTbl----")
    gt.dump(enterRoomMsgTbl)
    self.sit_btn  = self:findNodeByName("sit_btn")
    if enterRoomMsgTbl.kIsLookOn == 1 then 
        gt.setOnViewClickedListeners(self.sit_btn ,function()
            local m = {}
            m.kMId = 62066
            m.kDeskId =  enterRoomMsgTbl.kDeskId
            gt.socketClient:sendMessage(m)

        end)
        self.is_sit = false
        self:findNodeByName( "Btn_chat" ):setVisible(false)
        self:findNodeByName( "voice" ):setVisible(false)
    else
        self.sit_btn:setVisible(false)
        self:findNodeByName("guancha"):setVisible(false)
        self.is_sit = true

        self:playerEnterRoom(enterRoomMsgTbl)
        self.p_g:setVisible(false)
    end
  

    if self.UsePos == 5 or self.UsePos == 21 then 
        self.playerSeatIdx = 1
        self.seatOffset = 5
    end


    local node = self:findNodeByName("_time")
    if node then node:setString(os.date("%H:%M")) end
    self.__time = _scheduler:scheduleScriptFunc(function()
        
        if node then node:setString(os.date("%H:%M")) end

      -- spr1:loadTexture("bg1.png")
      

    end,1,false)

    self:chongZhiJiaoPai2()
end

function PlaySceneWuRen:addUser(m)

    if m.kIsLookOn == 1 then return end
    for seatIdx = 1 , 5  do
        local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
        playerInfoNode:setVisible(false)
        local readySignSpr = gt.seekNodeByName(playerInfoNode, "Img_ready")
        readySignSpr:setVisible(false)
        self.roomPlayers[seatIdx] = nil


  
        local Img_offline = gt.seekNodeByName(playerInfoNode, "Img_offline")
        Img_offline:setVisible(false)
   

    end

    self:playerEnterRoom( m )
    self:onStartGame()
    gt.dump(self.tmp_player,"self.tmp_player")

    for k , y in pairs(self.tmp_player) do
        self:addPlayer(y)
    end

    for k , y in pairs(self.tmp_ready) do
        self:RcvReady(y)
    end
  
end

function PlaySceneWuRen:onAddRoomSeatDown(m)
    gt.log("111111111111111")
    gt.dump(m)

    if m.kErrorCode == 0 then 
        self.p_g:setVisible(false)
        self.is_sit = true
        -- self:findNodeByName( "Btn_chat" ):setVisible(self.data.kPlaytype[5]==0)
        -- self:findNodeByName( "voice" ):setVisible(self.data.kPlaytype[5]==0)

        self:findNodeByName( "Btn_chat" ):setVisible(true)
        self:findNodeByName( "voice" ):setVisible(true)

        self.sit_btn:setVisible(false)
        self:findNodeByName("guancha"):setVisible(false)
    elseif m.kErrorCode == 1 then 
        self.p_g:setVisible(false)
        self.Btn_ready:setVisible(false)
        Toast.showToast(self, "入座失败，人数已满！", 2)
    elseif m.kErrorCode == 9  or m.kErrorCode == 10 then 
        Toast.showToast(self, "入座失败,玩家距离过近！",2)
    else 
        Toast.showToast(self, "入座失败：错误码："..(m.kErrorCode or "null"), 2)
    end
end

-- function PlaySceneWuRen:is_sit_show(m)
--     self.sit_btn:setVisible(m.kErrorCode == 0)
-- end

function PlaySceneWuRen:initBind(enterRoomMsgTbl)
    --右上角按钮和菜单  
	local Btn_showButton = gt.seekNodeByName(self.rootNode, "Btn_showButton")
    local Sprite_menuBG = gt.seekNodeByName(self.rootNode, "Sprite_menuBG")
    local Btn_closeButton = gt.seekNodeByName(self.rootNode, "Btn_closeButton")
    local Btn_back = gt.seekNodeByName(self.rootNode, "Btn_back")
    local Btn_exit = gt.seekNodeByName(self.rootNode, "Btn_exit")
    local Btn_set = gt.seekNodeByName(self.rootNode, "Btn_set")
    local Btn_chat = gt.seekNodeByName(self.rootNode, "Btn_chat")
    local Btn_voice = gt.seekNodeByName(self.rootNode, "voice")

    -- if self.isFangZuobi then
    --       Btn_chat:setTouchEnabled(false)
    --       Btn_chat:setBright(false)
    --       Btn_voice:setTouchEnabled(false)
    --       Btn_voice:setBright(false)
    -- else
    --       Btn_chat:setTouchEnabled(true)
    --       Btn_chat:setBright(true)
    --       Btn_voice:setTouchEnabled(true)
    --       Btn_voice:setBright(true)
    -- end

    --初始化位置
    local posX = Btn_showButton:getPositionX()
    local posY = Btn_showButton:getPositionY()
    --打开菜单栏
    gt.addBtnPressedListener(Btn_showButton, function()
        Btn_showButton:setVisible(false)
        Sprite_menuBG:setVisible(true)
        Btn_closeButton:setVisible(true)
        Btn_back:setVisible(true)
        Btn_exit:setVisible(true)
        Btn_set:setVisible(true)
        Btn_closeButton:setPosition(cc.p(posX, posY))
        Btn_exit:setPosition(cc.p(posX, posY - 84))
        Btn_back:setPosition(cc.p(posX, posY - 84*2))
        Btn_set:setPosition(cc.p(posX, posY - 84*3))
        -- if enterRoomMsgTbl.kPos ~= 0 and self.curDeskCount == 0 then
        --     Btn_exit:setVisible(false)
        --     Btn_back:setPosition(cc.p(posX, posY - 84))
        --     Btn_set:setPosition(cc.p(posX, posY - 84*2))
        -- end
    end)
    --点击关闭菜单栏
    gt.addBtnPressedListener(Btn_closeButton, function()
        Btn_closeButton:setPosition(cc.p(posX, posY))
        Btn_back:setPosition(cc.p(posX, posY))
        Btn_set:setPosition(cc.p(posX, posY))
        Btn_showButton:setVisible(true)
        Sprite_menuBG:setVisible(false)
        Btn_closeButton:setVisible(false)
        Btn_back:setVisible(false)
        Btn_exit:setVisible(false)
        Btn_set:setVisible(false)
    end)
    --点击返回按钮
    gt.addBtnPressedListener(Btn_back, function()
        self:exitRoom( (self.gameBegin and self.is_sit) )
    end) 
    --点击设置按钮

    gt.addBtnPressedListener(Btn_set, function()
        if self:getChildByName("_settinr_node_") then self:getChildByName("_settinr_node_"):removeFromParent() end
        local settingPanel = require("client/game/majiang/Setting"):create(self)
        settingPanel:setName("_settinr_node_")
        self:addChild(settingPanel, 17)

    end)


    gt.setOnViewClickedListener(self.rootNode:getChildByName("Img_bk"),function()
        local Img_showDipai = gt.seekNodeByName(self.rootNode, "Img_showDipai")
        Img_showDipai:setVisible(false)
        local Image_deskinfo = gt.seekNodeByName(self.rootNode, "Image_deskinfo")
        Image_deskinfo:setVisible(false)
        Btn_closeButton:setPosition(cc.p(posX, posY))
        Btn_back:setPosition(cc.p(posX, posY))
        Btn_set:setPosition(cc.p(posX, posY))
        Btn_showButton:setVisible(true)
        Sprite_menuBG:setVisible(false)
        Btn_closeButton:setVisible(false)
        Btn_back:setVisible(false)
        Btn_exit:setVisible(false)
        Btn_set:setVisible(false)

    end)
    gt.addBtnPressedListener(Btn_exit, function()
        if  not self.is_sit then 
            self:exitRoom( string.len(self.data.kDeskId) == 6 and  gt.isCreateUserId or false)
        else
            if (not gt.isCreateUserId and not self.gameBegin) then -- and 游戏没开始
                self:exitRoom(false)
            else
                self:exitRoom(true)
            end
        end

    end) 
    --点击聊天按钮
    gt.addBtnPressedListener(Btn_chat, function()
        if self.data.kPlaytype[5] == 1 then Toast.showToast(self, "防作弊房间禁止发送消息!", 2) return end
    	local chatPanel = require("client/game/majiang/ChatPanel"):create(false,self.data.kPlaytype[5])
        self:addChild(chatPanel, PlaySceneWuRen.ZOrder.CHAT)
    end) 
    -- --点击语音按钮
    -- gt.addBtnPressedListener(Btn_voice, function()
    -- end)
    --准备按钮
    self.Btn_ready = gt.seekNodeByName(self.rootNode, "Btn_ready")
    gt.addBtnPressedListener(self.Btn_ready, function()
        self:onStartGame()
    end)
    --分享好友
    self.Btn_friend = gt.seekNodeByName(self.rootNode, "Btn_friend")
    self.Btn_friend:setVisible(true)
    gt.addBtnPressedListener(self.Btn_friend, function()
        self:shareWx()
    end)
    --房间号
    self.Text_fanghaoAndJushu = gt.seekNodeByName(self.rootNode, "Text_fanghaoAndJushu")
	self.Text_fanghaoAndJushu:setString(string.format("%d",enterRoomMsgTbl.kDeskId))

    --叫分按钮以及绑定
    self.NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_jiaofen")
    self.Btn_bujiao = gt.seekNodeByName(self.NodePlayerMyself, "Btn_bujiao")
    self.Btn_70 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_70")
    self.Btn_75 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_75")
    self.Btn_80 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_80")
    self.Btn_85 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_85")
    self.Btn_90 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_90")
    self.Btn_95 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_95")
    self.Btn_100 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_100")
    gt.addBtnPressedListener(self.Btn_bujiao, function()
        self:sendScoreToServer(0)
    end)
    gt.addBtnPressedListener(self.Btn_70, function()
        self:sendScoreToServer(70)
    end)
    gt.addBtnPressedListener(self.Btn_75, function()
        self:sendScoreToServer(75)
    end)
    gt.addBtnPressedListener(self.Btn_80, function()
        self:sendScoreToServer(80)
    end)
    gt.addBtnPressedListener(self.Btn_85, function()
        self:sendScoreToServer(85)
    end)
    gt.addBtnPressedListener(self.Btn_90, function()
        self:sendScoreToServer(90)
    end)
    gt.addBtnPressedListener(self.Btn_95, function()
        self:sendScoreToServer(95)
    end)
    gt.addBtnPressedListener(self.Btn_100, function()
        self:sendScoreToServer(100)
    end)

    -- 麻将层
	local NodeMyself = gt.seekNodeByName(self.rootNode, "Node_player1")
    self.playMjLayer = gt.seekNodeByName(NodeMyself, "Layer_handCards")
    
    --埋底按钮
    local Node_maidi = gt.seekNodeByName(self.rootNode, "Node_maidi")
    local Btn_maiDI = gt.seekNodeByName(Node_maidi, "Btn_maiDI")
    gt.addBtnPressedListener(Btn_maiDI, function()
        self:maiDiToServer()
    end)

    --选主
    local Img_zhu = gt.seekNodeByName(self.rootNode, "Img_zhu")
    local Btn_hei = gt.seekNodeByName(Img_zhu, "Btn_hei")
    local Btn_hong = gt.seekNodeByName(Img_zhu, "Btn_hong")
    local Btn_mei = gt.seekNodeByName(Img_zhu, "Btn_mei")
    local Btn_fang = gt.seekNodeByName(Img_zhu, "Btn_fang")
    gt.addBtnPressedListener(Btn_hei, function()
        self:selectMain(PlaySceneWuRen.ColorType.HEITAO)
    end)
    gt.addBtnPressedListener(Btn_hong, function()
        self:selectMain(PlaySceneWuRen.ColorType.HONGTAO)
    end)
    gt.addBtnPressedListener(Btn_mei, function()
        self:selectMain(PlaySceneWuRen.ColorType.MEIHUA)
    end)
    gt.addBtnPressedListener(Btn_fang, function()
        self:selectMain(PlaySceneWuRen.ColorType.FANGPIAN)
    end)
    
    --选副庄家
    local Node_xuanzhuang = gt.seekNodeByName(self.rootNode, "Node_xuanzhuang")

    -- local Img_clock_0 = gt.seekNodeByName(Node_xuanzhuang, "Img_clock_0") --闹钟pic
    -- local Text_clockNum = gt.seekNodeByName(Img_clock_0, "Text_clockNum") --闹钟
    -- Text_clockNum:setString()
    self.timeNumber = 15


    local Btn_xuanZhuangOK = gt.seekNodeByName(Node_xuanzhuang, "Btn_xuanZhuangOK")
    gt.addBtnPressedListener(Btn_xuanZhuangOK, function()
        gt.log("点击按钮")
        self:selectZhuangJia()
    end)
    local Btn_F10 = gt.seekNodeByName(Node_xuanzhuang, "Btn_F10")
    local Btn_FJ = gt.seekNodeByName(Node_xuanzhuang, "Btn_FJ")
    local Btn_FQ = gt.seekNodeByName(Node_xuanzhuang, "Btn_FQ")
    local Btn_FK = gt.seekNodeByName(Node_xuanzhuang, "Btn_FK")
    local Btn_FA = gt.seekNodeByName(Node_xuanzhuang, "Btn_FA")
    Btn_F10:setTag(10)
    Btn_FJ:setTag(11)
    Btn_FQ:setTag(12)
    Btn_FK:setTag(13)
    Btn_FA:setTag(1)
    
    local Btn_M10 = gt.seekNodeByName(Node_xuanzhuang, "Btn_M10")
    local Btn_MJ = gt.seekNodeByName(Node_xuanzhuang, "Btn_MJ")
    local Btn_MQ = gt.seekNodeByName(Node_xuanzhuang, "Btn_MQ")
    local Btn_MK = gt.seekNodeByName(Node_xuanzhuang, "Btn_MK")
    local Btn_MA = gt.seekNodeByName(Node_xuanzhuang, "Btn_MA")
    Btn_M10:setTag(26)
    Btn_MJ:setTag(27)
    Btn_MQ:setTag(28)
    Btn_MK:setTag(29)
    Btn_MA:setTag(17)
    
    local Btn_H10 = gt.seekNodeByName(Node_xuanzhuang, "Btn_H10")
    local Btn_HJ = gt.seekNodeByName(Node_xuanzhuang, "Btn_HJ")
    local Btn_HQ = gt.seekNodeByName(Node_xuanzhuang, "Btn_HQ")
    local Btn_HK = gt.seekNodeByName(Node_xuanzhuang, "Btn_HK")
    local Btn_HA = gt.seekNodeByName(Node_xuanzhuang, "Btn_HA")
    Btn_H10:setTag(42)
    Btn_HJ:setTag(43)
    Btn_HQ:setTag(44)
    Btn_HK:setTag(45)
    Btn_HA:setTag(33)

    local Btn_HE10 = gt.seekNodeByName(Node_xuanzhuang, "Btn_HE10")
    local Btn_HEJ = gt.seekNodeByName(Node_xuanzhuang, "Btn_HEJ")
    local Btn_HEQ = gt.seekNodeByName(Node_xuanzhuang, "Btn_HEQ")
    local Btn_HEK = gt.seekNodeByName(Node_xuanzhuang, "Btn_HEK")
    local Btn_HEA = gt.seekNodeByName(Node_xuanzhuang, "Btn_HEA")
    Btn_HE10:setTag(58)
    Btn_HEJ:setTag(59)
    Btn_HEQ:setTag(60)
    Btn_HEK:setTag(61)
    Btn_HEA:setTag(49)
    
    local Btn_King = gt.seekNodeByName(Node_xuanzhuang, "Btn_King")
    local Btn_Queen = gt.seekNodeByName(Node_xuanzhuang, "Btn_Queen")
    Btn_King:setTag(79)
    Btn_Queen:setTag(78)

    table.insert(self.xuanZhuangBtn, Btn_F10)
    table.insert(self.xuanZhuangBtn, Btn_FJ)
    table.insert(self.xuanZhuangBtn, Btn_FQ)
    table.insert(self.xuanZhuangBtn, Btn_FK)
    table.insert(self.xuanZhuangBtn, Btn_FA)

    table.insert(self.xuanZhuangBtn, Btn_M10)
    table.insert(self.xuanZhuangBtn, Btn_MJ)
    table.insert(self.xuanZhuangBtn, Btn_MQ)
    table.insert(self.xuanZhuangBtn, Btn_MK)
    table.insert(self.xuanZhuangBtn, Btn_MA)    
    
    table.insert(self.xuanZhuangBtn, Btn_H10)
    table.insert(self.xuanZhuangBtn, Btn_HJ)
    table.insert(self.xuanZhuangBtn, Btn_HQ)
    table.insert(self.xuanZhuangBtn, Btn_HK)
    table.insert(self.xuanZhuangBtn, Btn_HA)

    table.insert(self.xuanZhuangBtn, Btn_HE10)
    table.insert(self.xuanZhuangBtn, Btn_HEJ)
    table.insert(self.xuanZhuangBtn, Btn_HEQ)
    table.insert(self.xuanZhuangBtn, Btn_HEK)
    table.insert(self.xuanZhuangBtn, Btn_HEA)

    table.insert(self.xuanZhuangBtn, Btn_King)
    table.insert(self.xuanZhuangBtn, Btn_Queen )
    gt.addBtnPressedListener(Btn_F10, function()
        self.selectZhuangNum = 10
        self:refreshBtn(1)
    end)
    gt.addBtnPressedListener(Btn_FJ, function()
        self.selectZhuangNum = 11
        self:refreshBtn(2)
    end)
    gt.addBtnPressedListener(Btn_FQ, function()
        self.selectZhuangNum = 12
        self:refreshBtn(3)
    end)
    gt.addBtnPressedListener(Btn_FK, function()
        self.selectZhuangNum = 13
        self:refreshBtn(4)
    end)
    gt.addBtnPressedListener(Btn_FA, function()
        self.selectZhuangNum = 1
        self:refreshBtn(5)
    end)
    gt.addBtnPressedListener(Btn_M10, function()
        self.selectZhuangNum = 26
        self:refreshBtn(6)
    end)
    gt.addBtnPressedListener(Btn_MJ, function()
        self.selectZhuangNum = 27
        self:refreshBtn(7)
    end)
    gt.addBtnPressedListener(Btn_MQ, function()
        self.selectZhuangNum = 28
        self:refreshBtn(8)
    end)
    gt.addBtnPressedListener(Btn_MK, function()
        self.selectZhuangNum = 29
        self:refreshBtn(9)
    end)
    gt.addBtnPressedListener(Btn_MA, function()
        self.selectZhuangNum = 17
        self:refreshBtn(10)
    end)
    gt.addBtnPressedListener(Btn_H10, function()
        self.selectZhuangNum = 42
        self:refreshBtn(11)
    end)
    gt.addBtnPressedListener(Btn_HJ, function()
        self.selectZhuangNum = 43
        self:refreshBtn(12)
    end)
    gt.addBtnPressedListener(Btn_HQ, function()
        self.selectZhuangNum = 44
        self:refreshBtn(13)
    end)
    gt.addBtnPressedListener(Btn_HK, function()
        self.selectZhuangNum = 45
        self:refreshBtn(14)
    end)
    gt.addBtnPressedListener(Btn_HA, function()
        self.selectZhuangNum = 33
        self:refreshBtn(15)
    end)
    gt.addBtnPressedListener(Btn_HE10, function()
        self.selectZhuangNum = 58
        self:refreshBtn(16)
    end)
    gt.addBtnPressedListener(Btn_HEJ, function()
        self.selectZhuangNum = 59
        self:refreshBtn(17)
    end)
    gt.addBtnPressedListener(Btn_HEQ, function()
        self.selectZhuangNum = 60
        self:refreshBtn(18)
    end)
    gt.addBtnPressedListener(Btn_HEK, function()
        self.selectZhuangNum = 61
        self:refreshBtn(19)
    end)
    gt.addBtnPressedListener(Btn_HEA, function()
        self.selectZhuangNum = 49
        self:refreshBtn(20)
    end)
    gt.addBtnPressedListener(Btn_King, function()
        self.selectZhuangNum = 79
        self:refreshBtn(21)
    end)
    gt.addBtnPressedListener(Btn_Queen, function()
        self.selectZhuangNum = 78
        self:refreshBtn(22)
    end)
    --副庄家的牌
    local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
    local Img_duijia = gt.seekNodeByName(Node_leftInfo, "Img_duijia")
    Img_duijia:setVisible(false)
    --当前分数
    self.Text_score  = gt.seekNodeByName(Node_leftInfo, "Text_score")
    self.Text_score:setString("0")

    --出牌按钮
    local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
    Btn_chupai:setVisible(false)
    gt.addBtnPressedListener(Btn_chupai, function()
        self:sendCardToServer()
    end)
    --上一轮出的牌
    local Btn_preRound = gt.seekNodeByName(self.rootNode, "Btn_preRound")
    gt.addBtnPressedListener(Btn_preRound, function()
        self:showPreRoundCards()
    end)

    -- --105按钮点击事件
    -- local Node_105ReleaseDesk = gt.seekNodeByName(self.rootNode, "Node_105ReleaseDesk")
    -- local Btn_jieshu = gt.seekNodeByName(Node_105ReleaseDesk, "Btn_jieshu")
    -- local Btn_jixu = gt.seekNodeByName(Node_105ReleaseDesk, "Btn_jixu")
    -- gt.addBtnPressedListener(Btn_jieshu, function()
    --     local msgToSend = {}
	-- 	msgToSend.kMId = gt.MSG_C_2_S_WURENBAIFEN_SCORE_105_RET
	-- 	msgToSend.kPos = self.playerSeatIdx - 1
    --     msgToSend.kAgree = 1
	-- 	gt.socketClient:sendMessage(msgToSend)
    -- end)
    -- gt.addBtnPressedListener(Btn_jixu, function()
    --     local msgToSend = {}
	-- 	msgToSend.kMId = gt.MSG_C_2_S_WURENBAIFEN_SCORE_105_RET
	-- 	msgToSend.kPos = self.playerSeatIdx - 1
    --     msgToSend.kAgree = 0
	-- 	gt.socketClient:sendMessage(msgToSend)
    -- end)

    --桌子信息
    local Btn_deskinfo = gt.seekNodeByName(self.rootNode, "Btn_deskinfo")
    local Image_deskinfo = gt.seekNodeByName(self.rootNode, "Image_deskinfo")
    
    local Text_Text_info = gt.seekNodeByName(Image_deskinfo, "Text_info") --大信息块
    local info  = ""

    local room = "房间号:" .. tostring(enterRoomMsgTbl.kDeskId)
    info = info .. room .. "\n"
    local difen = "底分:" .. tostring(self.isDiFen)
    info = info .. difen .. "\n"
    local changzhu = ""
    if self.isChangZhu then
        changzhu = "2是常主"
    else  
        changzhu = "2不是常主"  
    end
    info = info .. changzhu .. "\n"

    local xianglin = ""
    if self.tongIPs then
        xianglin = "相邻位置禁止进入"
    else
        xianglin = "相邻位置可以进入"
    end
    info = info .. xianglin .. "\n"

    local hanshi = ""
    if self.isHan10 then
        hanshi = "选副庄含10" 
    else
        hanshi = "选副庄不含10"
    end
    info = info .. hanshi .. "\n"

    local gankou = ""
    if self.xianKouDi then
        gankou = "闲家干扣"
    end
    if gankou == "" then
    else
        info = info .. gankou .. "\n"
    end

    local jiaofen = ""
    if self.isJiaoPai == 0 then
        jiaofen = "庄家不交牌"
    elseif self.isJiaoPai == 8 or self.isJiaoPai == 12 then
        jiaofen = "交牌扣"..self.isJiaoPai .. "分"
    end
    info = info .. jiaofen .. "\n"
    
    local fangzuobi = ""
    if self.isFangZuobi then
        fangzuobi = "开启防作弊"
    end
    if fangzuobi == "" then
    else
        info = info .. fangzuobi .. "\n"
    end

    local guanzhan = ""
    if self.isGuanZhan then
        guanzhan = "允许观战"
    else
        guanzhan = "不允许观战"
    end  
    info = info .. guanzhan .. "\n"

    local renyifen = ""
    if self.isRenYiFen then
        renyifen = "任意叫分都可选主花牌为副庄"
    end 
    if renyifen == "" then
    else
        info = info .. renyifen .. "\n"
    end

    Text_Text_info:setString(info)


    gt.addBtnPressedListener(Btn_deskinfo, function()
        -- Image_deskinfo:setVisible(true)
        if Image_deskinfo:isVisible() then 
            Image_deskinfo:setVisible(false)
        else
            Image_deskinfo:setVisible(true)
        end
    end)

    --底牌按钮
    local Btn_dipai = gt.seekNodeByName(self.rootNode, "Btn_dipai")
    local Img_showDipai = gt.seekNodeByName(self.rootNode, "Img_showDipai")
    gt.addBtnPressedListener(Btn_dipai, function()
        if #self.lastCards > 0 then
            Img_showDipai:removeAllChildren()
            Img_showDipai:setVisible(true)
            self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function()
                Img_showDipai:setVisible(false)
            end)))
            for i=1, #self.lastCards do
	            local card = ccui.ImageView:create()
	            card:loadTexture("res/sd/pk/" .. self.lastCards[i] .. ".png")
                Img_showDipai:addChild(card)
                card:setScale(0.35)
                card:setPosition(cc.p((i-1)*70 + 65, 50))
            end
        end
    end)

    self.Btn_ready:setVisible(false)

     --防作弊房间
    local Text_fangzhubi = gt.seekNodeByName(self.rootNode, "Text_fangzhubi")
    if self.isFangZuobi and self.curDeskCount == 0 then
        Text_fangzhubi:setVisible(true)
    else
        Text_fangzhubi:setVisible(false)
    end

    self:resetScene()
end

function PlaySceneWuRen:unregisterAllMsgListener()
	gt.socketClient:unregisterMsgListener(gt.GC_ADD_PLAYER)
	gt.socketClient:unregisterMsgListener(gt.GC_REMOVE_PLAYER)
	gt.socketClient:unregisterMsgListener(gt.GC_ENTER_ROOM)
	gt.socketClient:unregisterMsgListener(gt.GC_START_GAME)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SEND_CARDS)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_RECV_SCORE)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SHOW_LASTCARDS)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_BASE_CARD_R)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SELECT_MAIN_R)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SELECT_FRIEND_BC)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_OUT_CARD_BC)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_DRAW_RESULT_BC)
	gt.socketClient:unregisterMsgListener(gt.GC_READY)
	gt.socketClient:unregisterMsgListener(gt.GC_SYNC_ROOM_STATE)
	gt.socketClient:unregisterMsgListener(gt.GC_OFF_LINE_STATE)
	gt.socketClient:unregisterMsgListener(gt.GC_ROUND_STATE)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SCORE_105)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_RECON)
	gt.socketClient:unregisterMsgListener(gt.MSG_C_2_S_WURENBAIFEN_SCORE_105_RESULT)
	gt.socketClient:unregisterMsgListener(gt.GC_DISMISS_ROOM)
	gt.socketClient:unregisterMsgListener(gt.GC_QUIT_ROOM)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_GATE)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_SERVER)

	-- 注销监听
	if self.schedulerEntry then
		gt.scheduler:unscheduleScriptEntry(self.schedulerEntry)
		self.schedulerEntry = nil
	end		
end

--点击准备走
function PlaySceneWuRen:onStartGame()

    if self.UsePos > 4 or self.UsePos < 0 then return end

    local msgToSend = {}
    msgToSend.kMId = gt.CG_READY
    msgToSend.kPos = self.UsePos
    gt.dumplog(msgToSend)
    gt.socketClient:sendMessage(msgToSend)
    
    local roomPlayer = self.roomPlayers[self.playerSeatIdx]
    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. roomPlayer.displaySeatIdx )

    self.Btn_ready:setVisible(false)

end

function PlaySceneWuRen:onNodeEvent(eventName)
    gt.log("eventName.....",eventName)
	if "enter" == eventName then
		-- 触摸事件
		local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(false)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		listener:registerScriptHandler(handler(self, self.onTouchCancel), cc.Handler.EVENT_TOUCH_CANCELLED)
		local eventDispatcher = self.playMjLayer:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.playMjLayer)
        
		-- 逻辑更新定时器
        self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 1.0, false)
        self.scheduleHandler1 = gt.scheduler:scheduleScriptFunc(handler(self, self.update1), 1.0, false)
        self.ChatLog = {}
        
		gt.soundEngine:playMusic("pkdesk/bgm", true)
	elseif "exit" == eventName then
        gt.log("exit_______________")
        self:chongZhiJiaoPai2()

        if  self.__time then _scheduler:unscheduleScriptEntry(self.__time) self.__time = nil end
        if self._DelayTime then _scheduler:unscheduleScriptEntry(self._DelayTime) self._DelayTime = nil end 
        if self._DelayTime1 then _scheduler:unscheduleScriptEntry(self._DelayTime1) self._DelayTime1 = nil end 
        gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
        gt.scheduler:unscheduleScriptEntry(self.scheduleHandler1)
        if self.schedulerEntry then
            gt.scheduler:unscheduleScriptEntry(self.schedulerEntry)
            self.schedulerEntry = nil 
        end

        local NoticeJiaoPai = gt.seekNodeByName(self.rootNode, "Notice_jiaopai2")
        NoticeJiaoPai:setVisible(false)
        self.btn_agree = gt.seekNodeByName(NoticeJiaoPai, "btn_agree")
        self.btn_disagree = gt.seekNodeByName(NoticeJiaoPai, "btn_disagree")
        self.btn_agree:setTouchEnabled(true)
        self.btn_agree:setBright(true)
        self.btn_disagree:setTouchEnabled(true)
        self.btn_disagree:setBright(true)


        gt.removeTargetEventListenerByType(self, gt.EventType.BACK_MAIN_SCENE)
        self:stopAllActions()
        self.Text_score:stopAllActions()
        local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")   
        gt.seekNodeByName(Node_leftInfo, "Img_duijia"):stopAllActions()
        gt.seekNodeByName(self.rootNode, "Node_flyAction"):stopAllActions()
        for i = 1, 5 do 
            self._voice[i]:stopAllActions()
            if self.m_UserChat[i]  and not tolua.isnull(self.m_UserChat[i]) and self.m_UserChat[i].stopAllActions then
            self.m_UserChat[i]:stopAllActions() end
        end  
        for i = 1, #self.holdCards do
            if self.holdCards[i] then 
                self.holdCards[i]:stopAllActions()
            end
        end
        
	end
end

   
-- function PlaySceneWuRen:onRcvLoginServer(msgTbl)
-- 	gt.log("收到登录服务器消息 ============== ")
-- 	dump(msgTbl)

-- 	-- 去掉转圈
-- 	gt.removeLoadingTips()

-- 	--登录服务器时间
-- 	gt.loginServerTime = msgTbl.m_serverTime or os.time()
-- 	--登录本地时间
-- 	gt.loginLocalTime = os.time() 

-- 	-- 设置开始游戏状态
-- 	gt.socketClient:setIsStartGame(true)
-- 	gt.socketClient:setIsCloseHeartBeat(false)
-- 	gt.floatText("重新连接服务器成功")
-- end
-- --服务器返回gate登录
-- function PlaySceneWuRen:onRcvLoginGate( msgTbl )
--     gt.log("服务器返回gate登录")
-- 	dump( msgTbl )

-- 	gt.socketClient:setPlayerKeyAndOrder(msgTbl.m_strKey, msgTbl.m_uMsgOrder)

-- 	local msgToSend = {}
-- 	msgToSend.m_msgId = gt.CG_LOGIN_SERVER
-- 	msgToSend.m_seed = gt.loginSeed
-- 	msgToSend.m_id = gt.m_id
-- 	local catStr = tostring(gt.loginSeed)
-- 	msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
-- 	gt.socketClient:sendMessage(msgToSend)
-- end

function PlaySceneWuRen:unregisterAllMsgListener()

	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_GATE)	
end

-- -- 断线重连,走一次登录流程
-- function PlaySceneWuRen:reLogin()
-- 	local accessToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Access_Token" )
-- 	local refreshToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token" )
-- 	local openid 		= cc.UserDefault:getInstance():getStringForKey( "WX_OpenId" )

-- 	local unionid 		= cc.UserDefault:getInstance():getStringForKey( "WX_Uuid" )
-- 	local sex 			= cc.UserDefault:getInstance():getStringForKey( "WX_Sex" )
-- 	local nickname 		= gt.wxNickName--cc.UserDefault:getInstance():getStringForKey( "WX_Nickname" )
-- 	local headimgurl 	= cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl" )

-- 	local msgToSend = {}
-- 	msgToSend.kMId = gt.CG_LOGIN
-- 	msgToSend.m_plate = "wechat"
-- 	msgToSend.m_accessToken = accessToken
-- 	msgToSend.m_refreshToken = refreshToken
-- 	msgToSend.m_openId = openid
-- 	msgToSend.m_severID = gt.serverId
-- 	msgToSend.m_uuid = unionid
-- 	msgToSend.m_sex = tonumber(sex)
-- 	msgToSend.m_nikename = nickname
-- 	msgToSend.m_imageUrl = headimgurl

-- 	local catStr = string.format("%s%s%s%s", openid, accessToken, refreshToken, unionid)
-- 	msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
-- 	gt.socketClient:sendMessage(msgToSend)
-- end

-- function PlaySceneWuRen:onRcvLogin(msgTbl)
-- 	gt.log("首条登录消息应答 =============== ")
-- 	dump(msgTbl)

-- 	gt.socketClient:savePlayCount(msgTbl.m_totalPlayNum)

-- 	if msgTbl.m_errorCode == 5 then
-- 		-- 去掉转圈
-- 		gt.removeLoadingTips()
-- 		require("app/views/NoticeTips"):create("提示",	"您在"..msgTbl.m_errorMsg.."中登录或已创建房间，需要退出或解散房间后再此登录。", nil, nil, true)
-- 		return
-- 	end

-- 	-- 如果有进入此函数则说明token,refreshtoken,openid是有效的,可以记录.
-- 	if self.needLoginWXState == 0 then
-- 		-- 重新登录,因此需要全部保存一次
-- 		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token", self.m_accessToken )
-- 		cc.UserDefault:getInstance():setStringForKey( "WX_Refresh_Token", self.m_refreshToken )
-- 		cc.UserDefault:getInstance():setStringForKey( "WX_OpenId", self.m_openid )

-- 		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token_Time", os.time() )
-- 		cc.UserDefault:getInstance():setStringForKey( "WX_Refresh_Token_Time", os.time() )
-- 	elseif self.needLoginWXState == 1 then
-- 		-- 无需更改
-- 		-- ...
-- 	elseif self.needLoginWXState == 2 then
-- 		-- 需更改accesstoken
-- 		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token", self.m_accessToken )
-- 		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token_Time", os.time() )
-- 	end


-- 	gt.loginSeed = msgTbl.m_seed

-- 	-- gt.GateServer.ip = msgTbl.m_gateIp
-- 	-- gt.GateServer.ip = tostring(msgTbl.m_gateIp)
-- 	gt.GateServer.ip = gt.curServerIp
-- 	gt.GateServer.port = tostring(msgTbl.m_gatePort)
-- 	gt.m_id = msgTbl.m_id

-- 	if msgTbl.m_totalPlayNum ~= nil then
-- 		self:savePlayCount(msgTbl.m_totalPlayNum)
-- 	else
-- 		gt.log("onRcvLogin playCount = nil")
-- 	end

-- 	gt.log("gt.GateServer ip = " .. gt.GateServer.ip .. ", port = " .. gt.GateServer.port)
-- 	gt.socketClient:close()
-- 	gt.log("关闭socket 222222")
-- 	gt.socketClient:connect(gt.GateServer.ip, gt.GateServer.port, true)
-- 	local msgToSend = {}
-- 	msgToSend.m_msgId = gt.CG_LOGIN_GATE
-- 	msgToSend.m_strUserUUID = gt.socketClient:getPlayerUUID()
-- 	gt.socketClient:sendMessage(msgToSend)
-- end


-- start --
--------------------------------
-- @class function
-- @description 接收跑游戏桌面马灯消息
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:onRcvPlaySeceneCSMarquee(msgTbl)
	gt.log("收到跑马灯消息 =============== ")
	dump(msgTbl)

	if gt.isIOSPlatform() and gt.isInReview then
		local str_des = gt.getLocationString("LTKey_0048")
		self.marqueeMsg:showMsg(str_des, 3)
	else
		self.marqueeMsg:showMsg(msgTbl.kStr, 3)
	end
end

-- start --
-------------------------------
-- @class function
-- @description 接收房间添加玩家消息
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:addPlayer(msgTbl)

    if not msgTbl then return end

    self.tmp_player[msgTbl.kPos] = msgTbl

	gt.log("onRcvAddPlayer收到添加玩家消息")
	gt.dump(msgTbl)

	-- 封装消息数据放入到房间玩家表中
	local roomPlayer = {}
	roomPlayer.uid = msgTbl.kUserId
	roomPlayer.nickname = msgTbl.kNike
	roomPlayer.headURL = string.sub(msgTbl.kFace, 1, string.lastString(msgTbl.kFace, "/")) .. "96"
	roomPlayer.sex = msgTbl.kSex
	roomPlayer.ip  = msgTbl.kIp
	
	-- 服务器位置从0开始
	-- 客户端位置从1开始

    if not self.seatOffset then  
        self.seatOffset = self.playerFixDispSeat - msgTbl.kPos
    end

	roomPlayer.seatIdx = msgTbl.kPos + 1
	roomPlayer.displaySeatIdx = (msgTbl.kPos + self.seatOffset) % 5 + 1
	roomPlayer.readyState = msgTbl.kReady
	roomPlayer.score = msgTbl.kScore

    local displaySeatIdx = (msgTbl.kPos + self.seatOffset) % 5 + 1
    local Node_player = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
    local Img_offline = gt.seekNodeByName(Node_player, "Img_offline")
    Img_offline:setVisible(not msgTbl.kOnline)
    
    gt.seekNodeByName(Node_player, "Img_ready"):setVisible(msgTbl.kReady == 1)


	-- 房间添加玩家
	self:roomAddPlayer(roomPlayer)
end

-- start --
--------------------------------
-- @class function
-- @description 从房间移除一个玩家
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:removePlayer(msgTbl)
	gt.log("收到从房间移除一个玩家消息 ============= ",self.isGameOver)
	dump(msgTbl)
    -- 去除数据
    
    self.tmp_ready[msgTbl.kPos + 1] = nil
    self.tmp_player[msgTbl.kPos] = nil
  
    if self.isGameOver == 0 then 
	    gt.log("移除玩家" .. msgTbl.kPos)
	    local seatIdx = msgTbl.kPos + 1
	    local roomPlayer = self.roomPlayers[seatIdx]
        if roomPlayer then 
    	    -- 隐藏玩家信息
    	    local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_player" .. roomPlayer.displaySeatIdx)
    	    playerInfoNode:setVisible(false)
	        local headSpr = gt.seekNodeByName(playerInfoNode, "Sprite_head")
	        --self.playerHeadMgr:detach(headSpr)
    	    self.roomPlayers[seatIdx] = nil
        end

        if msgTbl.kPos == self.UsePos   then 
            local str = ""
            if msgTbl.kOutType == 1 then 
                str = "游戏已结束！"
            elseif msgTbl.kOutType == 3 then 
                str = "游戏以开始！"
            elseif  msgTbl.kOutType == 2 then 
                str = "您已退出房间！"
            elseif msgTbl.kOutType == 0 then 
                str = "默认类型！"
            end
            self:onExitRoom(str)

        end
    end
end

-- start --
--------------------------------
-- @class function
-- @description 房间添加玩家
-- @param roomPlayer 玩家信息
-- end --
function PlaySceneWuRen:roomAddPlayer(roomPlayer)
	gt.log("房间添加玩家",roomPlayer.displaySeatIdx)
	   
    gt.dump(roomPlayer)

	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_player" .. roomPlayer.displaySeatIdx)
	playerInfoNode:setVisible(true)
	-- 头像
	local headSpr = gt.seekNodeByName(playerInfoNode, "Sprite_head")

    gt.log("create________",tostring(self.is_sit))

    local nicknameLabel = gt.seekNodeByName(playerInfoNode, "Text_name")
    local scoreLabel = gt.seekNodeByName(playerInfoNode, "Text_score")
    if roomPlayer.seatIdx > 0 and roomPlayer.seatIdx < 6 then 
    	-- 昵称
        local nickname = string.gsub(roomPlayer.nickname," ","")
        nickname = string.gsub(nickname,"　","")
        nicknameLabel:setString(gt.checkName(nickname))

        scoreLabel:setString(tostring(roomPlayer.score))
        roomPlayer.scoreLabel = scoreLabel

    end

    if not self.is_sit then
        if self:isClubCreate(self.data.kCreateUserId, gt.playerData.uid)  then 
            self.playerHeadMgr:attach(headSpr, roomPlayer.headURL, nil, roomPlayer.sex, true)
            scoreLabel:setVisible(true)
            nicknameLabel:setVisible(true)
        else
            if self.isFangZuobi then
                scoreLabel:setVisible(false)
                nicknameLabel:setVisible(false)
                self.localHeadImg[roomPlayer.seatIdx] = (self.roomid % 10) + roomPlayer.seatIdx
                headSpr:loadTexture("res/sd/headimg/" .. self.localHeadImg[roomPlayer.seatIdx] ..".jpg")
            else
                scoreLabel:setVisible(true)
                nicknameLabel:setVisible(true)
                self.playerHeadMgr:attach(headSpr, roomPlayer.headURL, nil, roomPlayer.sex, true)
            end
        end
       
    else
        if roomPlayer.seatIdx > 0 and roomPlayer.seatIdx < 6 then 
            if self.isFangZuobi then
                gt.log("roomPlayer.seatIdx...",roomPlayer.seatIdx , self.playerSeatIdx)
                if roomPlayer.seatIdx == self.playerSeatIdx  then
                    if roomPlayer.headURL ~= "" then
                        self.playerHeadMgr:attach(headSpr, roomPlayer.headURL, nil, roomPlayer.sex, true)
                    end
                else
                    self.localHeadImg[roomPlayer.seatIdx] = (self.roomid % 10) + roomPlayer.seatIdx
                    headSpr:loadTexture("res/sd/headimg/" .. self.localHeadImg[roomPlayer.seatIdx] ..".jpg")
                end
                scoreLabel:setVisible(false)
                nicknameLabel:setVisible(false)
            else
                 self.playerHeadMgr:attach(headSpr, roomPlayer.headURL, nil, roomPlayer.sex, true)
            end
        end

    end



	-- 离线标示
	--local offLineSignSpr = gt.seekNodeByName(playerInfoNode, "Spr_offLineSign")
	--offLineSignSpr:setVisible(false)
	-- 庄家
	--local bankerSignSpr = gt.seekNodeByName(playerInfoNode, "Spr_bankerSign")
	--bankerSignSpr:setVisible(false)

	-- 添加入缓冲
    
    if roomPlayer.seatIdx > 0 and roomPlayer.seatIdx < 6 then 
       
    -- 点击头像显示信息
        local headFrameBtn = gt.seekNodeByName(playerInfoNode, "Btn_head")
        headFrameBtn:setTag(roomPlayer.seatIdx)
        headFrameBtn:addClickEventListener(handler(self, self.showPlayerInfo))
    
	    self.roomPlayers[roomPlayer.seatIdx] = roomPlayer
    end

   

	-- 准备标示
	if roomPlayer.readyState == 1 then
		self:playerGetReady(roomPlayer.seatIdx)
	end
    if roomPlayer.readyState == 0 and roomPlayer.seatIdx == self.playerSeatIdx then
		-- 未准备显示准备按钮
		-- local readyBtn = gt.seekNodeByName(self.rootNode, "Btn_ready")
		-- readyBtn:setVisible(self.is_sit)
	end
	-- 如果已经四个人了,隐藏微信分享按钮,显示聊天,设置按钮
	local playerCount = 0
	for k, v in pairs(self.roomPlayers) do
		if v then
			playerCount = playerCount + 1
		end
	end
	if playerCount == self.numPlayer then
	end
 end

 -- start --
--------------------------------
-- @class function
-- @description 进入房间
-- @param msgTbl 消息体
-- end --
-- function PlaySceneWuRen:onRcvEnterRoom(msgTbl)
-- 	gt.log("进入房间")
-- 	dump(msgTbl)

-- 	gt.dispatchEvent("EVT_CLOSE_FINAL_REPORT")
	
-- 	gt.removeLoadingTips()
-- 	self:playerEnterRoom(msgTbl)
--     -- 显示局数
-- end


-- start --
--------------------------------
-- @class function
-- @description 玩家自己进入房间
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:playerEnterRoom(msgTbl)
	gt.log("玩家进入房间 =============== ")
	dump(msgTbl)
	-- 房间中的玩家
	self.roomPlayers = {}
	-- 玩家自己放入到房间玩家中
	local roomPlayer = {}
	roomPlayer.uid = gt.playerData.uid
	roomPlayer.nickname = gt.playerData.nickname
	roomPlayer.headURL = gt.playerData.headURL
	roomPlayer.sex = gt.playerData.sex
	roomPlayer.ip = gt.playerData.ip
    --玩家座位号
	roomPlayer.seatIdx = msgTbl.kPos + 1

    -- 玩家座位显示位置
	roomPlayer.displaySeatIdx = 1

	roomPlayer.readyState = msgTbl.kReady
	roomPlayer.score = msgTbl.kScore

	

	-- 房间编号
	self.roomID = msgTbl.kDeskId
	-- 玩家座位编号
	self.playerSeatIdx = roomPlayer.seatIdx
	-- 玩家显示固定座位号
	self.playerFixDispSeat = 5
	-- 逻辑座位和显示座位偏移量(从0编号开始)
	local seatOffset = self.playerFixDispSeat - msgTbl.kPos
	self.seatOffset = seatOffset

    -- 添加玩家自己
    self:roomAddPlayer(roomPlayer)

	if roomPlayer.readyState == 0 then
		-- 未准备显示准备按钮
		-- local readyBtn = gt.seekNodeByName(self.rootNode, "Btn_ready")
		-- readyBtn:setVisible(self.is_sit)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 玩家进入准备状态
-- @param seatIdx 座次
-- end --
function PlaySceneWuRen:playerGetReady(seatIdx)
	local roomPlayer = self.roomPlayers[seatIdx]
    
 --   if not roomPlayer then return end
    gt.dump(self.roomPlayers)

	-- 显示玩家准备手势

	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. roomPlayer.displaySeatIdx )
	local readySignSpr = gt.seekNodeByName(playerNode, "Img_ready")
	readySignSpr:setVisible(true)

    

	-- 玩家本身
	if seatIdx == self.playerSeatIdx then
		-- 隐藏准备按钮
		local readyBtn = gt.seekNodeByName(self.rootNode, "Btn_ready")
		readyBtn:setVisible(false)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 游戏开始
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:onRcvStartGame(msgTbl)
	gt.log("收到游戏开始消息 ============== ")
	dump(msgTbl)

	self:onRcvSyncRoomState(msgTbl)
end

-- start --
--------------------------------
-- @class function
-- @description 当前局数/最大局数量
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:renovate(msgTbl)
	-- 牌局状态,剩余牌
	gt.log("收到牌局状态,剩余牌局消息 ================")
	dump(msgTbl)
    --局数

    if msgTbl.kPlaytype[5]==1 then
        -- self:findNodeByName( "Btn_chat" ):setTouchEnabled(false)
        self:findNodeByName( "Btn_chat" ):setBright(false)
        -- self:findNodeByName( "voice" ):setTouchEnabled(false)
        self:findNodeByName( "voice" ):setBright(false)
    end

    self.curDeskCount = msgTbl.kCurCircle
    if self.curDeskCount > 0 then
        self.gameBegin = true
        self.Btn_friend:setVisible(false)
	    local Text_fanghaoAndJushu = gt.seekNodeByName(self.rootNode, "Text_fanghaoAndJushu")
	    Text_fanghaoAndJushu:setString(string.format("%d/%d", (msgTbl.kCurCircle), msgTbl.kCurMaxCircle))
        self.Btn_friend:setVisible(false)
    end
        --防作弊房间
    local Text_fangzhubi = gt.seekNodeByName(self.rootNode, "Text_fangzhubi")
    if self.isFangZuobi and self.curDeskCount == 0 then
        Text_fangzhubi:setVisible(true)
    else
        Text_fangzhubi:setVisible(false)
    end
end



function PlaySceneWuRen:chongZhiJiaoPai2()
    self.jiaoPaiOneVisible = 0
    self.timeJiaopai = 15
    local NoticeJiaoPai = gt.seekNodeByName(self.rootNode, "Notice_jiaopai2")
    NoticeJiaoPai:setVisible(false)
    self.btn_agree = gt.seekNodeByName(NoticeJiaoPai, "btn_agree")
    self.btn_disagree = gt.seekNodeByName(NoticeJiaoPai, "btn_disagree")
    self.btn_agree:setTouchEnabled(true)
    self.btn_agree:setBright(true)
    self.btn_disagree:setTouchEnabled(true)
    self.btn_disagree:setBright(true)
end

-- start --
--------------------------------
-- @class function
-- @description 服务器发牌
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:onRcvCards(msgTbl,bool)
    gt.log("收到发牌消息 ================")
    dump(msgTbl)
    if  self.first_game then 
        self:PlaySound("sfx/sound_nn/GAME_SELECTBANKER.mp3")
    end

    self.first_game = false
    self.p_g:setVisible(false)
    if not bool then 
        self.isGameOver = 0
        self:removeChildByName("__XIAOJIESUAN__")
        self:resetScene()
    end

    if self.UsePos == 5 or self.UsePos == 21 then 
        self.playerSeatIdx = 1
    end

    local look = 0 -- 0 
    if msgTbl.kHandCards[1] == 0 then 
        self.is_sit = false
        look = 1 
        local data = msgTbl["kClubAllHandCards"..1-1]
        if data and data[1] ~= 0 then 
            look = 2
        end
    else
        self.is_sit = true
    end
    local NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_player1")
    gt.seekNodeByName(NodePlayerMyself, "Layer_handCards"):setVisible(self.is_sit)
    self.Btn_friend:setVisible(false)

     --防作弊房间
    local Text_fangzhubi = gt.seekNodeByName(self.rootNode, "Text_fangzhubi")
    Text_fangzhubi:setVisible(false)

    self.kNextSelectScorePos = msgTbl.kNextSelectScorePos
    self.turnPos = self.kNextSelectScorePos
    local seatInx = (self.turnPos + self.seatOffset) % 5 + 1
    self.timeNumber = 15
    

    
     --描述文字
    local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
    Text_desc:setVisible(false)
    --隐藏玩家准备手势,显示时钟
    for i = 1, 5 do
        local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i )
        local readySignSpr = gt.seekNodeByName(playerNode, "Img_ready")
        local Img_clock = gt.seekNodeByName(playerNode, "Img_clock")
        local jiaofen =  gt.seekNodeByName(playerNode, "Img_score")
        
        if jiaofen then
            jiaofen:setVisible(false)
        end
        readySignSpr:setVisible(false)
        if i == seatInx then
            Img_clock:setVisible(true)
        else
            Img_clock:setVisible(false)
        end
    end


    if look == 0  then
        self.isCanTouch = true
        self.gameBegin = true
        local NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_player1")
        local Layer_handCards = gt.seekNodeByName(NodePlayerMyself, "Layer_handCards")
        local size = Layer_handCards:getContentSize()
        local startposX = size.width/2 -msgTbl.kHandCardsCount/2 * p_idx + 5 --25
        local posY = size.height/2
        --发牌动画
        local time = 0.1
        local Layer_handCardAction = gt.seekNodeByName(NodePlayerMyself, "Layer_handCardAction")
        Layer_handCards:removeAllChildren()
        self.NodePlayerMyself:setVisible(false)
        self.holdCards = nil
        self.holdCards = {}
        
        self.holdCardsNum = self:sortCards(msgTbl.kHandCards, PlaySceneWuRen.ColorType.HEITAO)
        gt.log("------self.holdCardsNum-----1469----")
        gt.dump(msgTbl.kHandCards)
        gt.dump(self.holdCardsNum)
        if msgTbl.kPos + 1 == self.playerSeatIdx then
            for i = 1, #self.holdCardsNum do
                if Layer_handCards then
                    local card = ccui.ImageView:create()
                    card:loadTexture("res/sd/pk/" .. self.holdCardsNum[i] .. ".png")
                    Layer_handCards:addChild(card)
                    card:setPosition(cc.p(startposX + i*p_idx, posY))
                    card:setTag(self.holdCardsNum[i])
                    table.insert(self.holdCards, card)
                    card:setVisible(false)
                    local time = 0
                    if i == 5 or i == 6 then
                        time = 0.1
                    elseif i == 4 or i == 7 then
                        time = 0.4
                    elseif i == 3 or i == 8 then
                        time = 0.7
                    elseif i == 2 or i == 9 then
                        time = 1.1
                    elseif i == 1 or i == 10 then
                        time = 1.5
                    end
		    card:runAction(cc.Sequence:create(cc.DelayTime:create(time), cc.Show:create(), cc.CallFunc:create(function()

                        -- if i == #self.holdCardsNum then 
                        --     gt.soundEngine:stopEffect(self._send_card_)
                        -- end

                        if i % 2 == 1 then
                            self:PlaySound("sound_res/ddz/send_card.mp3")
                        end

                        end)))
                end
             end
           
             self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
                  --叫分按钮显示
                 
                  if self.kNextSelectScorePos == self.playerSeatIdx-1 then
                      self.NodePlayerMyself:setVisible(self.is_sit)
                       --描述文字
                      local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
                      Text_desc:setVisible(false)
                    
                    if self.MaxSelectScore == 70 then
                        self:btnZhiHui(self.Btn_70)
                    elseif self.MaxSelectScore == 75 then
                        self:btnZhiHui(self.Btn_70, self.Btn_75)
                    elseif self.MaxSelectScore == 80 then
                        self:btnZhiHui(self.Btn_70, self.Btn_75, self.Btn_80)
                    elseif self.MaxSelectScore == 85 then
                        self:btnZhiHui(self.Btn_70, self.Btn_75, self.Btn_80, self.Btn_85)
                    elseif self.MaxSelectScore == 90 then
                        self:btnZhiHui(self.Btn_70, self.Btn_75, self.Btn_80, self.Btn_85, self.Btn_90)
                        gt.log("kongzhiu_________________")
                    elseif self.MaxSelectScore == 95 then
                        self:btnZhiHui(self.Btn_70, self.Btn_75, self.Btn_80, self.Btn_85, self.Btn_90, self.Btn_95)
                    elseif self.MaxSelectScore == 100 then
                        self:btnZhiHui(self.Btn_70, self.Btn_75, self.Btn_80, self.Btn_85, self.Btn_90, self.Btn_95, self.Btn_100)
                    end
                else
                      if self.NodePlayerMyself then
                        self.NodePlayerMyself:setVisible(false)
                      end
                        --描述文字
                      local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
                      if Text_desc then
                         Text_desc:setVisible(true)
                         Text_desc:setString("等待其他玩家叫分")
                      end
                  end
            end)))
        end
    else
        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
        Text_desc:setVisible(true)
        Text_desc:setString("等待其他玩家叫分")
        for i = 1 , 5  do
            local node = self:findNodeByName("Image_"..i)
            local card = nil
            if look == 2 then card = self:sortCards(msgTbl[ "kClubAllHandCards"..(i-1) ], PlaySceneWuRen.ColorType.HEITAO) end
            for j = 1 , msgTbl.kHandCardsCount do
                local p = i == 1 and  p_idx or 21
                p = i == 2 and -p or p
                local z = i == 2 and (11-j) or j 
                local n = node:clone()
                n:setVisible(true)
                n:setPositionX(node:getPositionX() - 15 + (j-1)*p )
                self:findNodeByName("FileNode"):addChild(n)
                n:setLocalZOrder(z)
                if look == 2 then 
                    n:loadTexture("res/sd/pk/" ..  card[j] .. ".png")
                    n:setTag(1000+ tonumber(card[j]))
                else
                    n:setTag(0)
                    n:loadTexture("sd/pk/lord_card_selected.png")
                end
                self.gz_card[i][j] = n
            end
        end

    end


    if msgTbl.kTotleScore then 

        for i = 1, 5 do
            local seat = ((i-1) + self.seatOffset) % 5 + 1
            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seat)
            local Text_score =  gt.seekNodeByName(playerNode, "Text_score")
            if msgTbl.kTotleScore[i] then 
                Text_score:setString(tostring(msgTbl.kTotleScore[i]))
            end
        end

    end

end

-- start --
--------------------------------
-- @class function
-- @description 向服务器发送玩家叫的分数
-- @param msgTbl 消息体
-- end --

function PlaySceneWuRen:btnZhiHui(...)
	for k , btn in pairs {...} do
		if not tolua.isnull(btn) then
			btn:setTouchEnabled(false)
            btn:setBright(false)
		end
	end
end

function PlaySceneWuRen:sendScoreToServer(score)
    gt.log("发送叫分 ====WuRen============" .. score)

    local fun = function()
        local msgToSend = {}
    	msgToSend.kMId = gt.MSG_C_2_S_WURENBAIFEN_SELECT_SCORE
    	msgToSend.kPos = self.playerSeatIdx-1
    	msgToSend.kSelecScore = score
    	gt.socketClient:sendMessage(msgToSend)
    end

    if tonumber(score) == 100 then 
        require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "是否确认叫100分？", fun, nil)
    else
        fun()
    end
end

function PlaySceneWuRen:sendZJiaoPaiToServer(num)
    gt.log("庄家 发送 交牌请求 ====WuRen============" .. num)
    local msgToSend = {}
	msgToSend.kMId = gt.MSG_C_2_S_WURENBAIFEN_ZHUANG_JIAO_PAI  --庄家发送交牌协议号
	msgToSend.kPos = self.playerSeatIdx-1
	msgToSend.kAgree = num
	gt.socketClient:sendMessage(msgToSend)
end

function PlaySceneWuRen:sendXJiaoPaiToServer(num)  
    gt.log("闲家 发送 交牌请求 ====WuRen============" .. num)
    local msgToSend = {}
	msgToSend.kMId = gt.MSG_C_2_S_WURENBAIFEN_XIAN_SELECT_JIAO_PAI  --闲家发送交牌协议号
	msgToSend.kPos = self.playerSeatIdx-1
	msgToSend.kAgree = num
	gt.socketClient:sendMessage(msgToSend)
end

-- start --
--------------------------------
-- @class function
-- @description 收到服务器叫分
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:onRcvScore(msgTbl)
    gt.log("收到叫分结果 ================")
	dump(msgTbl)
    gt.soundEngine:playEffect("pkdesk/" .. msgTbl.kSelelctScore)
    self.kNextSelectScorePos = msgTbl.kNextSelectScorePos
    self.timeNumber = 15
    self.turnPos = self.kNextSelectScorePos
       --叫分按钮显示
    if self.kNextSelectScorePos == self.playerSeatIdx-1 then
        self.NodePlayerMyself:setVisible(self.is_sit)
        
        --描述文字
        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
        Text_desc:setVisible(false)
         --叫分按钮以及绑定
        self.NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_jiaofen")
        local Btn_bujiao = gt.seekNodeByName(self.NodePlayerMyself, "Btn_bujiao")
        local Btn_70 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_70")
        local Btn_75 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_75")
        local Btn_80 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_80")
        local Btn_85 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_85")
        local Btn_90 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_90")
        local Btn_95 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_95")
        local Btn_100 = gt.seekNodeByName(self.NodePlayerMyself, "Btn_100")
        if msgTbl.kCurrMaxScore == 70 then
            self:btnZhiHui(Btn_70)
        elseif msgTbl.kCurrMaxScore == 75 then
            self:btnZhiHui(Btn_70, Btn_75)
        elseif msgTbl.kCurrMaxScore == 80 then
            self:btnZhiHui(Btn_70, Btn_75, Btn_80)
        elseif msgTbl.kCurrMaxScore == 85 then
            self:btnZhiHui(Btn_70, Btn_75, Btn_80, Btn_85)
        elseif msgTbl.kCurrMaxScore == 90 then
            self:btnZhiHui(Btn_70, Btn_75, Btn_80, Btn_85, Btn_90)
        elseif msgTbl.kCurrMaxScore == 95 then
            self:btnZhiHui(Btn_70, Btn_75, Btn_80, Btn_85, Btn_90, Btn_95)
        end

        if not self.is_sit then 
              --描述文字
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(true)
            Text_desc:setString("等待其他玩家叫分")
        end

    else
        self.NodePlayerMyself:setVisible(false)
        --描述文字
        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
        Text_desc:setVisible(true)
        Text_desc:setString("等待其他玩家叫分")
    end
    local seatInx = (self.turnPos + self.seatOffset) % 5 + 1
    --显示时钟
    for i=1, 5 do
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
        local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
        if i == seatInx then
            Img_clock:setVisible(true)
        else
            Img_clock:setVisible(false)
        end
    end

    --显示叫的分数
	local displaySeatIdx = (msgTbl.kPos + self.seatOffset) % 5 + 1
	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
    local Img_score =  gt.seekNodeByName(playerNode, "Img_score")
    local Text_jiaofen =  gt.seekNodeByName(playerNode, "Text_jiaofen")
    Img_score:setVisible(true)
    if msgTbl.kSelelctScore == 0 then
        Text_jiaofen:setString("不叫")
    else
        Text_jiaofen:setString(tostring(msgTbl.kSelelctScore))
    end

end

-- start --
--------------------------------
function PlaySceneWuRen:xuanZhuCard(msgTbl)
    --叫分结束，发底牌后，选主阶段。
    gt.log("---------xuanzhuCard-----选庄 card ------")
    gt.dump(msgTbl)

    local NoticeJiaoPai = gt.seekNodeByName(self.rootNode, "Notice_jiaopai1")
        NoticeJiaoPai:setVisible(false)

    local displaySeatIdx = (msgTbl.kZhuangPos + self.seatOffset) % 5 + 1

    if self._DelayTime1 then _scheduler:unscheduleScriptEntry(self._DelayTime1) self._DelayTime1 = nil end
    self._DelayTime1 = _scheduler:scheduleScriptFunc(function()
    if self._DelayTime1 then _scheduler:unscheduleScriptEntry(self._DelayTime1) self._DelayTime1 = nil end     
        for i=1, #self.holdCards do
            self.holdCards[i]:setPositionY(110)
            self.holdCards[i]:setColor(cc.WHITE)
        end

        if msgTbl.kZhuangPos == self.playerSeatIdx - 1 then
            --描述文字
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(false)
            
            --选主图标
            local Img_zhu = gt.seekNodeByName(self.rootNode, "Img_zhu")
            Img_zhu:setVisible(self.is_sit)
            local heinum = 0
            local hongnum = 0
            local meinum = 0
            local fangnum = 0
            
            local Img_hei = gt.seekNodeByName(Img_zhu, "Img_hei")
            local Img_hong = gt.seekNodeByName(Img_zhu, "Img_hong")
            local Img_mei = gt.seekNodeByName(Img_zhu, "Img_mei")
            local Img_fang = gt.seekNodeByName(Img_zhu, "Img_fang")


            local Img_zhu = gt.seekNodeByName(self.rootNode, "Img_zhu")
            local Btn_hei = gt.seekNodeByName(Img_zhu, "Btn_hei")
            local Btn_hong = gt.seekNodeByName(Img_zhu, "Btn_hong")
            local Btn_mei = gt.seekNodeByName(Img_zhu, "Btn_mei")
            local Btn_fang = gt.seekNodeByName(Img_zhu, "Btn_fang")

            for i = 1, #self.holdCardsNum do
                if self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.HEITAO then
                    heinum = heinum + 1
                elseif self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.HONGTAO then
                    hongnum = hongnum + 1
                elseif self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.MEIHUA then
                    meinum = meinum + 1
                elseif self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.FANGPIAN then
                    fangnum = fangnum + 1
                end
            end
            Btn_hei:setVisible(heinum>0)
            if heinum > 0 then
                Img_hei:setVisible(true)
            else
                Img_hei:setVisible(false)
            end

            Btn_hong:setVisible(hongnum>0)
            if hongnum > 0 then
                Img_hong:setVisible(true)
            else
                Img_hong:setVisible(false)
            end

            Btn_mei:setVisible(meinum>0)
            if meinum > 0 then
                Img_mei:setVisible(true)
            else
                Img_mei:setVisible(false)
            end
            Btn_fang:setVisible(fangnum>0)
            if fangnum > 0 then
                Img_fang:setVisible(true)
            else
                Img_fang:setVisible(false)
            end

            local Text_hei = gt.seekNodeByName(Img_zhu, "Text_hei")
            if Text_hei then
                Text_hei:setString(tostring(heinum))
            end

            local Text_hong = gt.seekNodeByName(Img_zhu, "Text_hong")
            if Text_hong then
                Text_hong:setString(tostring(hongnum))
            end

            local Text_mei = gt.seekNodeByName(Img_zhu, "Text_mei")
            if Text_mei then
                Text_mei:setString(tostring(meinum))
            end

            local Text_fang = gt.seekNodeByName(Img_zhu, "Text_fang")
            if Text_fang then
                Text_fang:setString(tostring(fangnum))
            end
            
            if not self.is_sit then --描述文字
                local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
                Text_desc:setVisible(true)
                Text_desc:setString("等待庄家定主")
            end

            if not  self.is_sit then
                --描述文字
                local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
                Text_desc:setVisible(true)
                Text_desc:setString("等待庄家定主")
            
                local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
                local outcard = gt.seekNodeByName(playerNode, "Node_outCard")
                if outcard:getChildByName("__xipai__") then
                    outcard:removeChildByName("__xipai__")
                end
                local xipaiNode, xipaiAnime = gt.createCSAnimation("runAction/mai_run.csb")
                outcard:addChild(xipaiNode)
                xipaiNode:setName("__xipai__")
                if displaySeatIdx == 3 or displaySeatIdx == 4 then
                    xipaiNode:setPosition(cc.p(0,20))
                elseif displaySeatIdx == 2 then 
                    xipaiNode:setPosition(cc.p(-60,20))
                elseif displaySeatIdx == 5 then 
                    xipaiNode:setPosition(cc.p(80,20))
                elseif  displaySeatIdx == 1 then 
                    xipaiNode:setPosition(cc.p(0,10))
                end
                xipaiAnime:gotoFrameAndPlay(0, true)
            end
        else
            --描述文字
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(true)
            Text_desc:setString("等待庄家定主")

            Toast.showToast(self,"有闲家拒绝交牌，游戏继续",2)
    
            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
            local outcard = gt.seekNodeByName(playerNode, "Node_outCard")
            gt.log("----xipsii-----")
            if outcard:getChildByName("__xipai__") then
                gt.log("---1-----")
                outcard:removeChildByName("__xipai__")
            end
            local xipaiNode, xipaiAnime = gt.createCSAnimation("runAction/mai_run.csb")
            outcard:addChild(xipaiNode)
            xipaiNode:setName("__xipai__")
            if displaySeatIdx == 3 or displaySeatIdx == 4 then
                xipaiNode:setPosition(cc.p(0,20))
            elseif displaySeatIdx == 2 then 
                xipaiNode:setPosition(cc.p(-60,20))
            elseif displaySeatIdx == 5 then 
                xipaiNode:setPosition(cc.p(80,20))
            elseif  displaySeatIdx == 1 then 
                xipaiNode:setPosition(cc.p(0,10))
            end
            xipaiAnime:gotoFrameAndPlay(0, true)
        end
    end,0.8,false)
end

-- @class function
-- @description 收到服务器叫分
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:onRcvLastCard(msgTbl)
    gt.log("叫分结束发底牌 ================")
	dump(msgTbl)
    if self._DelayTime then _scheduler:unscheduleScriptEntry(self._DelayTime) self._DelayTime = nil end
    self._DelayTime = _scheduler:scheduleScriptFunc(function()
        if self._DelayTime then _scheduler:unscheduleScriptEntry(self._DelayTime) self._DelayTime = nil end     
        self.zhuangPos = msgTbl.kZhuangPos
        self.NodePlayerMyself:setVisible(false)
        self.turnPos = self.zhuangPos
        self.timeNumber = 15
    	local displaySeatIdx = (msgTbl.kZhuangPos + self.seatOffset) % 5 + 1
        for i = 1, 5 do
    		local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
            local jiaofen =  gt.seekNodeByName(playerNode, "Img_score")
            local Img_banker = gt.seekNodeByName(playerNode, "Img_banker")
            local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
            if displaySeatIdx == i then
                Img_banker:setVisible(true)
                Img_clock:setVisible(true)
                --播放动画
                if displaySeatIdx == 1 then
                    Img_banker:setPosition(cc.p(570, 250))
                elseif displaySeatIdx == 2 then
                    Img_banker:setPosition(cc.p(-575, -75))
                elseif displaySeatIdx == 3 then
                    Img_banker:setPosition(cc.p(-180, -280))
                elseif displaySeatIdx == 4 then
                    Img_banker:setPosition(cc.p(160, -280))
                elseif displaySeatIdx == 5 then
                    Img_banker:setPosition(cc.p(570, -70))
                end
    			local moveto = cc.MoveTo:create(0.5, cc.p(35, 55))
                Img_banker:runAction(cc.Sequence:create(moveto, cc.CallFunc:create(function(sender)
                    Img_banker:setVisible(false)
                    local Node_banker = gt.seekNodeByName(playerNode, "Node_banker")
                    local zhuangNode, zhuangAnime = gt.createCSAnimation("runAction/banker_run.csb")
                    Node_banker:addChild(zhuangNode)
                    zhuangAnime:gotoFrameAndPlay(0, false)
                end)))
                self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function(sender)
                    local Node_banker = gt.seekNodeByName(playerNode, "Node_banker")
                    Node_banker:stopAllActions()
                    Node_banker:removeAllChildren()
                    Img_banker:setVisible(true)
                end)))
            else
                Img_banker:setVisible(false)
                Img_clock:setVisible(false)
            end
            if jiaofen then
                jiaofen:setVisible(false)
            end
    	end
        --叫的最大分
        local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
        local Text_maxjiaofen = gt.seekNodeByName(Node_leftInfo, "Text_maxjiaofen")
        Text_maxjiaofen:setString(tostring(msgTbl.kMaxSelectScore))
        self.MaxSelectScore = msgTbl.kMaxSelectScore
         --底牌动画
        local Node_dipai = gt.seekNodeByName(self.rootNode, "Node_dipai")

        for i = 1  , 4 do 
            local card1 = Node_dipai:getChildByTag(1)
            local card2 = Node_dipai:getChildByTag(2)
            local card3 = Node_dipai:getChildByTag(3)
            local card4 = Node_dipai:getChildByTag(4)


           if card1 then card1:stopAllActions() end
           if card2 then card2:stopAllActions() end
           if card3 then card3:stopAllActions() end
           if card4 then card4:stopAllActions() end

           Node_dipai:removeChildByTag(i) 

        end


        for i=1, 4 do
            local card = ccui.ImageView:create()
    	    card:loadTexture("res/sd/pk/lord_card_selected.png")
            card:setScale(0.1)
            Node_dipai:addChild(card)
            card:setTag(i)
            card:setPosition(cc.p(-35, 190))
        end


        if msgTbl.kZhuangPos == self.playerSeatIdx - 1 then
            --庄家底牌动画
            local card1 = Node_dipai:getChildByTag(1)
            local card2 = Node_dipai:getChildByTag(2)
            local card3 = Node_dipai:getChildByTag(3)
            local card4 = Node_dipai:getChildByTag(4)
            local moveto2 = cc.MoveTo:create(0.5, cc.p(-5, 190))
            local moveto3 = cc.MoveTo:create(0.5, cc.p(25, 190))
            local moveto4 = cc.MoveTo:create(0.5, cc.p(55, 190))

            local scaleto1 = cc.ScaleTo:create(0.5, 0.2)
            local scaleto2 = cc.ScaleTo:create(0.5, 0.2)
            local scaleto3 = cc.ScaleTo:create(0.5, 0.2)
            local scaleto4 = cc.ScaleTo:create(0.5, 0.2)

            local moveto5 = cc.MoveTo:create(0.5, cc.p(-180, 0))
            local moveto6 = cc.MoveTo:create(0.5, cc.p(-60, 0))
            local moveto7 = cc.MoveTo:create(0.5, cc.p(60, 0))
            local moveto8 = cc.MoveTo:create(0.5, cc.p(180, 0))

            card1:stopAllActions()
            card2:stopAllActions()
            card3:stopAllActions()
            card4:stopAllActions()

            card1:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.Spawn:create(scaleto1, moveto5)))
            card2:runAction(cc.Sequence:create(moveto2, cc.Spawn:create(scaleto2, moveto6)))
            card3:runAction(cc.Sequence:create(moveto3, cc.Spawn:create(scaleto3, moveto7)))
            card4:runAction(cc.Sequence:create(moveto4, cc.Spawn:create(scaleto4, moveto8),cc.CallFunc:create(function(sender)
                Node_dipai:removeAllChildren()
                local NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_player1")


                if msgTbl.kHandCards then 
                    self.holdCardsNum = msgTbl.kHandCards
                else
                    for i = 1, msgTbl.kBaseCardsCount do
                        table.insert(self.holdCardsNum, msgTbl.kBaseCards[i])
                    end
                end



                self.holdCardsNum = self:sortCards(self.holdCardsNum, PlaySceneWuRen.ColorType.HEITAO)
                
                local Layer_handCards = gt.seekNodeByName(NodePlayerMyself, "Layer_handCards")
                Layer_handCards:removeAllChildren()
                local size = Layer_handCards:getContentSize()
                local startposX = size.width/2 - #self.holdCardsNum/2 * 60
                local posY = size.height/2
                self.holdCards = nil
                self.holdCards = {}
                for i = 1, #self.holdCardsNum do
                    if Layer_handCards then
    	                local card = ccui.ImageView:create()
    	                card:loadTexture("res/sd/pk/" .. self.holdCardsNum[i] .. ".png")
                        Layer_handCards:addChild(card)
                        card:setPosition(cc.p(startposX + i*60, posY))
                        card:setTag(self.holdCardsNum[i])
    	        		table.insert(self.holdCards, card)
                    end
    	        end
                for i=1, #self.holdCards do
                    for j=1, msgTbl.kBaseCardsCount do
                        if self.holdCards[i]:getTag() == msgTbl.kBaseCards[j] then
                            self.holdCards[i]:setPositionY(130)
                            self.holdCards[i]:setColor(cc.c3b(200,200,200))
                        end
                    end
                end
            end)))
        else
            --其余玩家发底牌动画
            local card1 = Node_dipai:getChildByTag(1)
            local card2 = Node_dipai:getChildByTag(2)
            local card3 = Node_dipai:getChildByTag(3)
            local card4 = Node_dipai:getChildByTag(4)
            local moveto2 = cc.MoveTo:create(0.5, cc.p(-5, 190))
            local moveto3 = cc.MoveTo:create(0.5, cc.p(25, 190))
            local moveto4 = cc.MoveTo:create(0.5, cc.p(55, 190))

            local scaleto1 = cc.ScaleTo:create(0.5, 0.05)
            local scaleto2 = cc.ScaleTo:create(0.5, 0.05)
            local scaleto3 = cc.ScaleTo:create(0.5, 0.05)
            local scaleto4 = cc.ScaleTo:create(0.5, 0.05)

            local positionX = 0
            local positionY = 0
            if displaySeatIdx == 2 then
                positionX = 560
                positionY = 120
            elseif displaySeatIdx == 3 then
                positionX = 160
                positionY = 335
            elseif displaySeatIdx == 4 then
                positionX = -180
                positionY = 335
            elseif displaySeatIdx == 5 then
                positionX = -585
                positionY = 120
            end

            local moveto5 = cc.MoveTo:create(0.5, cc.p(positionX + 10, positionY))
            local moveto6 = cc.MoveTo:create(0.5, cc.p(positionX + 20, positionY))
            local moveto7 = cc.MoveTo:create(0.5, cc.p(positionX + 30, positionY))
            local moveto8 = cc.MoveTo:create(0.5, cc.p(positionX + 40, positionY))

            card1:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.Spawn:create(scaleto1, moveto5)))
            card2:runAction(cc.Sequence:create(moveto2, cc.Spawn:create(scaleto2, moveto6)))
            card3:runAction(cc.Sequence:create(moveto3, cc.Spawn:create(scaleto3, moveto7)))
            card4:runAction(cc.Sequence:create(moveto4, cc.Spawn:create(scaleto4, moveto8),cc.CallFunc:create(function(sender)
                Node_dipai:removeAllChildren()
            end)))

        end

        --叫分结束，发底牌后，插入  是否交牌的弹窗。交牌结束后，进入下边的发底牌。
        self:stopAllActions()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), 
            cc.CallFunc:create(function(sender)
                for i=1, #self.holdCards do
                    self.holdCards[i]:setPositionY(110)
                    self.holdCards[i]:setColor(cc.WHITE)
                end
            
                if msgTbl.kZhuangPos == self.playerSeatIdx - 1 then
                    --描述文字
                    local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
                    Text_desc:setVisible(false)
                    --选主图标
                    -- local Img_zhu = gt.seekNodeByName(self.rootNode, "Img_zhu")
                    -- Img_zhu:setVisible(self.is_sit)
                    if self.isJiaoPai == 0 then
                        self:xuanZhuCard(msgTbl)
                    elseif self.jiaoPaiOneVisible == 0 then
                        --弹出交牌提示框  Notice_jiaopai1
                        gt.log("---ddddd-----")
                        local NoticeJiaoPai = gt.seekNodeByName(self.rootNode, "Notice_jiaopai1")
                        self.timeJiaopai = 15
                        NoticeJiaoPai:setVisible(self.is_sit)

                        local Text_koufen = gt.seekNodeByName(NoticeJiaoPai, "Text_koufen")
                        Text_koufen:setString("本局扣分: "..self.isJiaoPai .. "分")

                        local Text_daojishi = gt.seekNodeByName(NoticeJiaoPai, "Text_daojishi") --倒计时15秒
                        if self.timeJiaopai_rec then
                            self.timeJiaopai = self.timeJiaopai_rec
                            Text_daojishi:setString(tostring(self.timeJiaopai))
                        end
                        -- Text_daojishi:setString("15")

                        local btn_jiaopai = gt.seekNodeByName(NoticeJiaoPai, "btn_jiaopai")
                        gt.addBtnPressedListener(btn_jiaopai, function()
                            NoticeJiaoPai:setVisible(false)
                            self:sendZJiaoPaiToServer(1)  --同意发 1
                            --选择交牌  发消息给服务器。
                            -- 收到消息后， 其他玩家显示弹窗， 庄家申请交牌，是否同意。
                        end)
            
                        local btn_bujiaopai = gt.seekNodeByName(NoticeJiaoPai, "btn_bujiaopai")
                        gt.addBtnPressedListener(btn_bujiaopai, function()
                            NoticeJiaoPai:setVisible(false)
                            self:sendZJiaoPaiToServer(0)  --不同意发 0
                            self:xuanZhuCard(msgTbl)
                            --拒绝交牌  继续游戏。
                            --谈个 toast 小弹窗。 有玩家拒绝交牌，游戏继续。
                        end)

                        if self.timeJiaopai_rec and self.timeJiaopai_rec < 1 then 
                            NoticeJiaoPai:setVisible(false)
                        end

                        if not self.is_sit then --描述文字
                            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
                            Text_desc:setVisible(true)
                            Text_desc:setString("等待庄家定主")
                        end

                    elseif self.jiaoPaiOneVisible == 1 then --庄家已申请。
                        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
                        Text_desc:setVisible(true)
                        Text_desc:setString("等待闲家决定交牌结果")
                    else
                        local NoticeJiaoPai = gt.seekNodeByName(self.rootNode, "Notice_jiaopai1")
                        NoticeJiaoPai:setVisible(false)
                        self:xuanZhuCard(msgTbl)
                    end
                else
                    if self.jiaoPaiOneVisible == 1 then --闲家 弹出 弹窗 jiaopai2 
                        self:onRcvJiaoPaiSelect(msgTbl)
                    else
                        --描述文字
                        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
                        Text_desc:setVisible(true)
                        if self.isJiaoPai == 0 then 
                            Text_desc:setString("等待庄家定主")
                        else
                            Text_desc:setString("等待庄家选择是否交牌")
                        end
                    
                        local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
                        local outcard = gt.seekNodeByName(playerNode, "Node_outCard")
                        if outcard:getChildByName("__xipai__") then
                            outcard:removeChildByName("__xipai__")
                        end
                        local xipaiNode, xipaiAnime = gt.createCSAnimation("runAction/mai_run.csb")
                        xipaiNode:setName("__xipai__")
                        outcard:addChild(xipaiNode)
                        if displaySeatIdx == 3 or displaySeatIdx == 4 then
                            xipaiNode:setPosition(cc.p(0,20))
                        elseif displaySeatIdx == 2 then 
                            xipaiNode:setPosition(cc.p(-60,20))
                        elseif displaySeatIdx == 5 then 
                            xipaiNode:setPosition(cc.p(80,20))
                        end
                        xipaiAnime:gotoFrameAndPlay(0, true)
                    end
                end
        end)))
    end,0.3,false)
end

function PlaySceneWuRen:onRcvJiaoPaiSelect(msgTbl) --交牌 选择
    gt.log("--------onRcvJiaoPaiSelect----")
    gt.dump(msgTbl)
    --庄家 不 弹这个弹窗
    --弹出交牌提示框  Notice_jiaopai2
    if msgTbl.kZhuangPos == self.playerSeatIdx - 1 then
        if msgTbl.kJiaoPaiRequest == 2 or msgTbl.kJiaoPaiRequest == 0 then --庄家拒绝
            local NoticeJiaoPai = gt.seekNodeByName(self.rootNode, "Notice_jiaopai1")
            NoticeJiaoPai:setVisible(false)
            self:xuanZhuCard(msgTbl)
        else 
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(true)
            Text_desc:setString("等待闲家决定交牌结果")
        end
    else
        if msgTbl.kJiaoPaiRequest == 2 or msgTbl.kJiaoPaiRequest == 0 then --庄家拒绝
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(true)
            Text_desc:setString("等待庄家定主")
        else
            local NoticeJiaoPai = gt.seekNodeByName(self.rootNode, "Notice_jiaopai2")
            NoticeJiaoPai:setVisible(self.is_sit)

            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(false)
            Text_desc:setString("")
    
            -- local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            -- Text_desc:setVisible(true)
            -- Text_desc:setString("等待其他闲家决定交牌结果")
        
            local Text_dec = gt.seekNodeByName(NoticeJiaoPai, "Text_dec")
            Text_dec:setString("同意人数 1/5")

            self.timeJiaopai = 15
        
            local Text_daojishi = gt.seekNodeByName(NoticeJiaoPai, "Text_daojishi") --倒计时15秒
            Text_daojishi:setString(tostring(self.timeJiaopai))
        
            
            self.btn_agree = gt.seekNodeByName(NoticeJiaoPai, "btn_agree")
            gt.addBtnPressedListener(self.btn_agree, function()
                -- NoticeJiaoPai:setVisible(false)

                self.btn_agree:setTouchEnabled(false)
                self.btn_agree:setBright(false)

                self.btn_disagree:setTouchEnabled(false)
                self.btn_disagree:setBright(false)

                self:sendXJiaoPaiToServer(1)  --闲家 同意庄家 交牌 1
                --选择交牌  发消息给服务器。
                -- 收到消息后， 其他玩家显示弹窗， 庄家申请交牌，是否同意。
            end)
        
            self.btn_disagree = gt.seekNodeByName(NoticeJiaoPai, "btn_disagree")
            gt.addBtnPressedListener(self.btn_disagree, function()

                self.btn_agree:setTouchEnabled(false)
                self.btn_agree:setBright(false)

                self.btn_disagree:setTouchEnabled(false)
                self.btn_disagree:setBright(false)

                NoticeJiaoPai:setVisible(false)
                self:sendXJiaoPaiToServer(0)  --闲家不同意庄家交牌发 0
                --拒绝交牌  继续游戏。
                --谈个 toast 小弹窗。 有玩家拒绝交牌，游戏继续。  
            end)
        end
    end
end

function PlaySceneWuRen:onRcvJiaoPaiResult(msgTbl) --广播 庄家 结果
    --广播 交牌结果，
    gt.log("--onRcvJiaoPaiResult---广播 交牌结果，--")
    gt.dump(msgTbl)
    local agreePer = 0
    local jujuePer = false
    for i=1, #msgTbl.kAgree do
        gt.log("---i----",i)
        gt.log(msgTbl.kAgree[i])
        if msgTbl.kAgree[i] == 1 then
            agreePer = agreePer + 1
        elseif msgTbl.kAgree[i] == 0 then
            jujuePer = true
        end
    end
    if jujuePer then --有人拒绝，继续游戏
        gt.seekNodeByName(self.rootNode, "Notice_jiaopai2"):setVisible(false)
        self:xuanZhuCard(msgTbl)
    else
        if msgTbl.kZhuangPos == self.playerSeatIdx - 1 then
        else
            local NoticeJiaoPai = gt.seekNodeByName(self.rootNode, "Notice_jiaopai2")
            local Text_dec = gt.seekNodeByName(NoticeJiaoPai, "Text_dec")
            Text_dec:setString("同意人数 ".. agreePer .."/5")
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(false)
            Text_desc:setString("")
        end
    end
end

--触摸事件
function PlaySceneWuRen:onTouchBegan(touch, event)

	return true
end

function PlaySceneWuRen:inTouchAreaCards(idx)

    if self.tmp_idx == idx then 
        return false
    end
    self.tmp_idx = idx
    return true

end

function PlaySceneWuRen:onTouchMoved(touch, event)
    if not self.isMaiDi then 

        local touchCard, cardIndex = self:touchPlayerCards(touch)
        if not touchCard then
            
            return false
        end
        for i=1, #self.holdCards do 
            
            if i == cardIndex and self:inTouchAreaCards(i) then
                self.selectCard = 0
                for i = 1, #self.holdCards do
                    if not tolua.isnull(self.holdCards[i]) then 
                        self.holdCards[i]:setPositionY(110)
                    end
                end
                if not tolua.isnull(self.holdCards[i]) then
                    if self.holdCards[i]:getPositionY() == 110 then
                        self.holdCards[i]:setPositionY(130)
                        self.selectCard = touchCard:getTag()
                    else
                        self.holdCards[i]:setPositionY(110)
                    end
                end

                local notHandCards = self:checkHolds()
                local isTouchSelectCard = true
                local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
                if self.selectCard > 0 then
                    for i=1, #notHandCards do
                        if self.selectCard == notHandCards[i] then
                            isTouchSelectCard = false
                            break
                        end
                    end
                else
                    isTouchSelectCard = false
                end
                if isTouchSelectCard then
                    Btn_chupai:setTouchEnabled(true)
                    Btn_chupai:setBright(true)
                else
                    Btn_chupai:setTouchEnabled(false)
                    Btn_chupai:setBright(false)
                end

            end
        end

 
    end
end

function PlaySceneWuRen:onTouchCancel(touch, event)
	self:onTouchEnded(touch, event);
end

function PlaySceneWuRen:onTouchEnded(touch, event)
    --隐藏上轮的牌
    local Node_preRoundCard = gt.seekNodeByName(self.rootNode, "Node_preRoundCard")
    Node_preRoundCard:setVisible(false)
    
    --右上角按钮和菜单  
	local Btn_showButton = gt.seekNodeByName(self.rootNode, "Btn_showButton")
    local Sprite_menuBG = gt.seekNodeByName(self.rootNode, "Sprite_menuBG")
    local Btn_closeButton = gt.seekNodeByName(self.rootNode, "Btn_closeButton")
    local Btn_back = gt.seekNodeByName(self.rootNode, "Btn_back")
    local Btn_exit = gt.seekNodeByName(self.rootNode, "Btn_exit")
    local Btn_set = gt.seekNodeByName(self.rootNode, "Btn_set")
    if Btn_showButton then
        --初始化位置
        local posX = Btn_showButton:getPositionX()
        local posY = Btn_showButton:getPositionY()
        --点击关闭菜单栏
        if Btn_closeButton then
            Btn_closeButton:setPosition(cc.p(posX, posY))
            Btn_closeButton:setVisible(false)
        end
        if Btn_back then
            Btn_back:setPosition(cc.p(posX, posY))
            Btn_back:setVisible(false)
        end
        if Btn_set then
            Btn_set:setPosition(cc.p(posX, posY))
            Btn_set:setVisible(false)
        end
        if Sprite_menuBG then
           Sprite_menuBG:setVisible(false)
        end
        if Btn_exit then
           Btn_exit:setVisible(false)
        end
        Btn_showButton:setVisible(true)
    end

	local touchCard, cardIndex = self:touchPlayerCards(touch)
    if not touchCard then
        print("touch is nil")
        return false
    end

    --埋底多选
    if self.isMaiDi then
        for i=1, #self.maidiCards do          
            if i== cardIndex then
                if self.maidiCards[i] then
                    if self.maidiCards[i]:getPositionY() == 110 then
                        self.maidiCards[i]:setPositionY(130)
                    else
                        self.maidiCards[i]:setPositionY(110)
                    end
                end
            end
        end

        local count = 0
        for i = 1, #self.maidiCards do
            if self.maidiCards[i] then
                if self.maidiCards[i]:getPositionY() > 110 then
	            	count = count + 1
                end
            end
        end
        local Node_maidi = gt.seekNodeByName(self.rootNode, "Node_maidi")
        local Text_maidi = gt.seekNodeByName(Node_maidi, "Text_maidi")
        if Text_maidi then
            Text_maidi:setString("请选择4张底牌,已选 " .. count .. " 张")
        end
        local Btn_maiDI = gt.seekNodeByName(Node_maidi, "Btn_maiDI")
        if Btn_maiDI then
            if count  ~= 4 then
                Btn_maiDI:setTouchEnabled(false)
                Btn_maiDI:setBright(false)
            else
                Btn_maiDI:setTouchEnabled(true)
                Btn_maiDI:setBright(true)
            end
        end
    else
	gt.soundEngine:Poker_playEffect("sound_res/ddz/touch_my_card.wav")
        if self.chooseCardIdx ~= cardIndex then
            self.selectCard = 0
            for i=1, #self.holdCards do
                if self.holdCards[i] then
                    if i== cardIndex then
                        self.holdCards[i]:setPositionY(130)
                        self.selectCard = touchCard:getTag()
                    else
                        self.holdCards[i]:setPositionY(110)
                    end
                end
            end
        else
            self.selectCard = 0
            for i=1, #self.holdCards do
                if self.holdCards[i] then
                    if i== cardIndex then
                        if self.holdCards[i]:getPositionY() == 110 then
                            self.holdCards[i]:setPositionY(130)
                            self.selectCard = touchCard:getTag()
                        else
			    self.selectCard = 0
                            self.holdCards[i]:setPositionY(110)
                        end
                    else
                        self.holdCards[i]:setPositionY(110)
                    end
                end
            end
        end
        local notHandCards = self:checkHolds()
        local isTouchSelectCard = true
        local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
        if self.selectCard > 0 then
            for i=1, #notHandCards do
                if self.selectCard == notHandCards[i] then
                    isTouchSelectCard = false
                    break
                end
            end
        else
            isTouchSelectCard = false
        end
        if isTouchSelectCard then
            Btn_chupai:setTouchEnabled(true)
            Btn_chupai:setBright(true)
        else
            Btn_chupai:setTouchEnabled(false)
            Btn_chupai:setBright(false)
        end
    end
    self.chooseCardIdx = cardIndex
   
end

-- start --
--------------------------------
-- @class function
-- @description 选中玩家麻将牌
-- @return 选中的麻将牌
-- end --
function PlaySceneWuRen:touchPlayerCards(touch)
    local cards = {}
    if self.isMaiDi then
        cards = self.maidiCards
    else
        cards = self.holdCards
    end
    local temp = {}
    local j = 1
    for i = #self.holdCards, 1, -1 do
        temp[j] = cards[i]
        j = j + 1
    end
	for idx, card in ipairs(temp) do
		if card and not tolua.isnull(card) then
			local touchPoint = card:convertTouchToNodeSpace(touch)
			local cardSize = card:getContentSize()
			local cardRect = cc.rect(0, 0, cardSize.width, cardSize.height)
			if cc.rectContainsPoint(cardRect, touchPoint) then
				return card, #cards - idx + 1
			end
		end
	end
	return nil
end

-- start --
--------------------------------
-- @class function
-- @description 发送埋底的牌给服务器
-- @return 
-- end --
function PlaySceneWuRen:maiDiToServer()

    local msgToSend = {}
	msgToSend.kMId = gt.MSG_C_2_S_WURENBAIFEN_BASE_CARD
	msgToSend.kPos = self.playerSeatIdx-1
	msgToSend.kBaseCardsCount = 4
	msgToSend.kBaseCards = {}
    local Node_maidi = gt.seekNodeByName(self.rootNode, "Node_maidi")
	local Layer_maidiHandCards = gt.seekNodeByName(Node_maidi, "Layer_maidiHandCards")
    local size = Layer_maidiHandCards:getContentSize()
    for i = 1, #self.maidiCards do
        if self.maidiCards[i]:getPositionY() > size.height/2 then
	    	table.insert(msgToSend.kBaseCards, self.maidiCards[i]:getTag())
	    self.tmp_maidi_card = {}
            table.insert(self.tmp_maidi_card, self.maidiCards[i]:getTag())
        end
    end
    if #msgToSend.kBaseCards == 4 then
	    gt.socketClient:sendMessage(msgToSend)
    else
		require("client/game/dialog/NoticeTips"):create("提示", "请选择四张底牌", nil, nil, true)
    end
end

--埋底返回
function PlaySceneWuRen:onRcvBaseCard(msgTbl)
    gt.log("埋底结束返回")
    dump(msgTbl)
    self.turnPos = self.zhuangPos
    self.timeNumber = 15
    for i = 1, 5 do
		local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
        if self.rootNode then
            --显示时钟
            local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
            if Img_clock then
                if ((self.turnPos + self.seatOffset) % 5 + 1) == i then
                    Img_clock:setVisible(true)
                else
                    Img_clock:setVisible(false)
                end
            end
        end
	end

    if self.zhuangPos == self.playerSeatIdx - 1 then
	if msgTbl.kBaseCards then 
            self.tmp_maidi_card = {}
            for i = 1, 4  do 
                table.insert(self.tmp_maidi_card, msgTbl.kBaseCards[i])
            end
        end
        --描述文字
        self.lastCards = msgTbl.kBaseCards
        local Btn_dipai = gt.seekNodeByName(self.rootNode, "Btn_dipai")
        Btn_dipai:setVisible(self.is_sit)
        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
        if Text_desc then
            Text_desc:setVisible(false)
        end

        self.playMjLayer:removeAllChildren();
        self.holdCards = nil;
        self.holdCards = {}
        self.holdCardsNum = nil
        self.holdCardsNum = {}
        local NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_player1")
        local Node_maidi = gt.seekNodeByName(self.rootNode, "Node_maidi")
        if Node_maidi then
            Node_maidi:setVisible(false)
        end

        for i = 1, msgTbl.kHandCardsCount do
	        table.insert(self.holdCardsNum, msgTbl.kHandCards[i])
	    end

        self.holdCardsNum = self:sortCards(self.holdCardsNum, self.MainColor)
        
        local Layer_handCards = gt.seekNodeByName(NodePlayerMyself, "Layer_handCards")
        local size = Layer_handCards:getContentSize()
        local startposX = size.width/2 - #self.holdCardsNum/2 * p_idx
        local posY = size.height/2
        Layer_handCards:removeAllChildren()
        self.holdCards = nil
        self.holdCards = {}
        for i = 1, #self.holdCardsNum do
            if Layer_handCards then
	            local card = ccui.ImageView:create()
	            card:loadTexture("res/sd/pk/" .. self.holdCardsNum[i] .. ".png")
                Layer_handCards:addChild(card)
                card:setPosition(cc.p(startposX + i*p_idx, posY))
                card:setTag(self.holdCardsNum[i])
	    		table.insert(self.holdCards, card)
                if self:checkColor(self.holdCardsNum[i]) == self.MainColor or self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.KING then
                     local star = ccui.ImageView:create()
                     star:loadTexture("res/sd/desk/star.png")
                     card:addChild(star)
                     star:setPosition(cc.p(25, 30))
		     if self.isChangZhu and self:is_changzhu(self.holdCardsNum[i]) then 
                        local star = ccui.ImageView:create()
                        star:loadTexture("res/sd/desk/star.png")
                        card:addChild(star)
                        star:setPosition(cc.p(25, 60))
                    end
                 end
            end
	    end
        

        --打开选庄界面
        local Node_xuanzhuang = gt.seekNodeByName(self.rootNode, "Node_xuanzhuang")
        Node_xuanzhuang:setVisible(self.is_sit)
        local Btn_F10 = gt.seekNodeByName(Node_xuanzhuang, "Btn_F10")
        local Btn_FJ = gt.seekNodeByName(Node_xuanzhuang, "Btn_FJ")
        local Btn_FQ = gt.seekNodeByName(Node_xuanzhuang, "Btn_FQ")
        local Btn_FK = gt.seekNodeByName(Node_xuanzhuang, "Btn_FK")
        local Btn_FA = gt.seekNodeByName(Node_xuanzhuang, "Btn_FA")
        
        local Btn_M10 = gt.seekNodeByName(Node_xuanzhuang, "Btn_M10")
        local Btn_MJ = gt.seekNodeByName(Node_xuanzhuang, "Btn_MJ")
        local Btn_MQ = gt.seekNodeByName(Node_xuanzhuang, "Btn_MQ")
        local Btn_MK = gt.seekNodeByName(Node_xuanzhuang, "Btn_MK")
        local Btn_MA = gt.seekNodeByName(Node_xuanzhuang, "Btn_MA")
        
        local Btn_H10 = gt.seekNodeByName(Node_xuanzhuang, "Btn_H10")
        local Btn_HJ = gt.seekNodeByName(Node_xuanzhuang, "Btn_HJ")
        local Btn_HQ = gt.seekNodeByName(Node_xuanzhuang, "Btn_HQ")
        local Btn_HK = gt.seekNodeByName(Node_xuanzhuang, "Btn_HK")
        local Btn_HA = gt.seekNodeByName(Node_xuanzhuang, "Btn_HA")

        local Btn_HE10 = gt.seekNodeByName(Node_xuanzhuang, "Btn_HE10")
        local Btn_HEJ = gt.seekNodeByName(Node_xuanzhuang, "Btn_HEJ")
        local Btn_HEQ = gt.seekNodeByName(Node_xuanzhuang, "Btn_HEQ")
        local Btn_HEK = gt.seekNodeByName(Node_xuanzhuang, "Btn_HEK")
        local Btn_HEA = gt.seekNodeByName(Node_xuanzhuang, "Btn_HEA")
        
        local Btn_King = gt.seekNodeByName(Node_xuanzhuang, "Btn_King")
        local Btn_Queen = gt.seekNodeByName(Node_xuanzhuang, "Btn_Queen")
        Btn_F10:setVisible(true)
        Btn_FJ:setVisible(true)
        Btn_FQ:setVisible(true)
        Btn_FK:setVisible(true)
        Btn_FA:setVisible(true)
        
        Btn_M10:setVisible(true)
        Btn_MJ:setVisible(true)
        Btn_MQ:setVisible(true)
        Btn_MK:setVisible(true)
        Btn_MA:setVisible(true)
        
        Btn_H10:setVisible(true)
        Btn_HJ:setVisible(true)
        Btn_HQ:setVisible(true)
        Btn_HK:setVisible(true)
        Btn_HA:setVisible(true)
        
        Btn_HE10:setVisible(true)
        Btn_HEJ:setVisible(true)
        Btn_HEQ:setVisible(true)
        Btn_HEK:setVisible(true)
        Btn_HEA:setVisible(true)
        
        Btn_King:setVisible(true)
        Btn_Queen:setVisible(true)
        -- 选牌不含10
        if msgTbl.kPokerTen == 0  then
            Btn_F10:setVisible(false)
            Btn_M10:setVisible(false)
            Btn_H10:setVisible(false)
            Btn_HE10:setVisible(false)
        end
	
	for i=1, #self.holdCardsNum do
            for j=1, #self.xuanZhuangBtn do
                if self.holdCardsNum[i] == self.xuanZhuangBtn[j]:getTag() then
                    self.xuanZhuangBtn[j]:setColor(cc.c3b(233,215,140))
                end
            end
        end
	
        if self.isRenYiFen then
            if self.MaxSelectScore < 100 then
                Btn_King:setColor(cc.c3b(50,50,50))
                Btn_Queen:setColor(cc.c3b(50,50,50))
            end
	    
        elseif self.MaxSelectScore < 100 then
            if self.MainColor == PlaySceneWuRen.ColorType.FANGPIAN then
                Btn_F10:setColor(cc.c3b(50,50,50))
                Btn_FJ:setColor(cc.c3b(50,50,50))
                Btn_FQ:setColor(cc.c3b(50,50,50))
                Btn_FK:setColor(cc.c3b(50,50,50))
                Btn_FA:setColor(cc.c3b(50,50,50))
            elseif self.MainColor == PlaySceneWuRen.ColorType.MEIHUA then
                Btn_M10:setColor(cc.c3b(50,50,50))
                Btn_MJ:setColor(cc.c3b(50,50,50))
                Btn_MQ:setColor(cc.c3b(50,50,50))
                Btn_MK:setColor(cc.c3b(50,50,50))
                Btn_MA:setColor(cc.c3b(50,50,50))
            elseif self.MainColor == PlaySceneWuRen.ColorType.HONGTAO then
                Btn_H10:setColor(cc.c3b(50,50,50))
                Btn_HJ:setColor(cc.c3b(50,50,50))
                Btn_HQ:setColor(cc.c3b(50,50,50))
                Btn_HK:setColor(cc.c3b(50,50,50))
                Btn_HA:setColor(cc.c3b(50,50,50))
            elseif self.MainColor == PlaySceneWuRen.ColorType.HEITAO then
                Btn_HE10:setColor(cc.c3b(50,50,50))
                Btn_HEJ:setColor(cc.c3b(50,50,50))
                Btn_HEQ:setColor(cc.c3b(50,50,50))
                Btn_HEK:setColor(cc.c3b(50,50,50))
                Btn_HEA:setColor(cc.c3b(50,50,50))
            end
            
            Btn_King:setColor(cc.c3b(50,50,50))
            Btn_Queen:setColor(cc.c3b(50,50,50))
        end
      
        for i = 1, #self.xuanZhuangBtn do
        -- if i == 1 or i == 2 or i ==5 then 
        -- self.xuanZhuangBtn[i]:setColor(cc.c3b(50,50,50)) end
            if self:checkColor(self.xuanZhuangBtn[i]:getTag()) == self.MainColor or 
                self:checkColor(self.xuanZhuangBtn[i]:getTag()) == PlaySceneWuRen.ColorType.KING then

                local star = ccui.ImageView:create()
                star:loadTexture("res/sd/desk/star.png")
                self.xuanZhuangBtn[i]:addChild(star)
                star:setPosition(cc.p(120, 185))
                star:setScale(1.5)
                if self.isChangZhu and self:is_changzhu(self.xuanZhuangBtn[i]:getTag()) then 
                    local star = ccui.ImageView:create()
                    star:loadTexture("res/sd/desk/star.png")
                    self.xuanZhuangBtn[i]:addChild(star)
                    star:setPosition(cc.p(120, 140))
                    star:setScale(1.5)              
                end
            end
        end

        if not self.is_sit then 
             --描述文字
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(true)
            Text_desc:setString("等待其他玩家选庄")
        end
        gt.soundEngine:playEffect("pkdesk/qingduijia")

    else
        gt.soundEngine:playEffect("pkdesk/dengdaiduijia")
           --描述文字
        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
        Text_desc:setVisible(true)
        Text_desc:setString("等待其他玩家选庄")
    end



    if self.gz_card[self.zhuangPos+1][1] and self.gz_card[self.zhuangPos+1][1]:getTag() ~= 0 then 

        local holdCardsNum = {}
        for i = 1, msgTbl.kHandCardsCount do
            table.insert(holdCardsNum, msgTbl.kHandCards[i])
        end

        holdCardsNum = self:sortCards(holdCardsNum, self.MainColor)


        for i= 1 , #self.gz_card[self.zhuangPos+1] do
            if self.gz_card[self.zhuangPos+1][i] then 
                self.gz_card[self.zhuangPos+1][i]:removeFromParent()
                self.gz_card[self.zhuangPos+1][i] = nil
            end
        end
        gt.dump(holdCardsNum)

        for i = 1, #holdCardsNum do
            local node = self:findNodeByName("Image_"..(self.zhuangPos+1))
            local n = node:clone()
            n:setVisible(true)

            local p = self.zhuangPos+1 == 1 and  p_idx or 21
            p = self.zhuangPos+1 == 2 and -p or p
            local z = self.zhuangPos+1 == 2 and (11-i) or i 
            n:setLocalZOrder(z)
            n:setPositionX(node:getPositionX()+ (i-1)*p)
            self:findNodeByName("FileNode"):addChild(n)
            n:loadTexture("res/sd/pk/" ..  holdCardsNum[i] .. ".png")

          
            if self:checkColor(holdCardsNum[i]) == self.MainColor or self:checkColor(holdCardsNum[i]) == PlaySceneWuRen.ColorType.KING then
                local star = ccui.ImageView:create()
                star:loadTexture("res/sd/desk/star.png")
                n:addChild(star)
                star:setPosition(cc.p(25, 30))
		if self.isChangZhu and self:is_changzhu( self.holdCardsNum[i] ) then 
                        local star = ccui.ImageView:create()
                        star:loadTexture("res/sd/desk/star.png")
                        card:addChild(star)
                        star:setPosition(cc.p(25, 60))
                    end
            end
            self.gz_card[self.zhuangPos+1][i] = n
            self.gz_card[self.zhuangPos+1][i]:setTag(1000+tonumber(holdCardsNum[i]))
        end
    end

end

--选主牌
function PlaySceneWuRen:selectMain(colorType)
    gt.log("----wuren----选主-----")
    gt.dump(self.holdCardsNum)
    local msgToSend = {}
	msgToSend.kMId = gt.MSG_C_2_S_WURENBAIFEN_SELECT_MAIN
	msgToSend.kPos = self.playerSeatIdx-1
	msgToSend.kSelectMainColor = colorType
	gt.socketClient:sendMessage(msgToSend)
end

--选主牌返回
function PlaySceneWuRen:onRcvSelectMain(msgTbl)
    gt.log("选主返回---wuren---")
    gt.dump(self.holdCardsNum)
    gt.dump(msgTbl)
    local Img_zhu = gt.seekNodeByName(self.rootNode, "Img_zhu")
    Img_zhu:setVisible(false)
    self.MainColor = msgTbl.kSelectMainColor
    --主牌图标
    local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
    local Image_zhupai = gt.seekNodeByName(Node_leftInfo, "Image_zhupai")
    Image_zhupai:setVisible(false)
    local zhupai = ccui.ImageView:create()
    if msgTbl.kSelectMainColor == PlaySceneWuRen.ColorType.HEITAO then
          gt.soundEngine:playEffect("pkdesk/hei")
          Image_zhupai:loadTexture("res/sd/desk/zhupai1.png")
          zhupai:loadTexture("res/sd/desk/zhupai1.png")
    elseif msgTbl.kSelectMainColor == PlaySceneWuRen.ColorType.HONGTAO then
          gt.soundEngine:playEffect("pkdesk/hong")
          Image_zhupai:loadTexture("res/sd/desk/zhupai2.png")
          zhupai:loadTexture("res/sd/desk/zhupai2.png")
    elseif msgTbl.kSelectMainColor == PlaySceneWuRen.ColorType.MEIHUA then
          gt.soundEngine:playEffect("pkdesk/mei")
          Image_zhupai:loadTexture("res/sd/desk/zhupai3.png")
          zhupai:loadTexture("res/sd/desk/zhupai3.png")
    elseif msgTbl.kSelectMainColor == PlaySceneWuRen.ColorType.FANGPIAN then
          gt.soundEngine:playEffect("pkdesk/fang")
          Image_zhupai:loadTexture("res/sd/desk/zhupai4.png")
          zhupai:loadTexture("res/sd/desk/zhupai4.png")
    end
    --播放选主动画
    local Node_flyAction = gt.seekNodeByName(self.rootNode, "Node_flyAction")
    Node_flyAction:addChild(zhupai)
    Node_flyAction:setPosition(gt.winCenter)
    local moveto = cc.MoveTo:create(0.6, cc.p(144, 590))
    Node_flyAction:runAction(cc.Sequence:create(moveto, cc.CallFunc:create(function() 
        Node_flyAction:removeAllChildren()
	    local flowerNode, flowerAnime = gt.createCSAnimation("flowerSplash.csb")
        Node_flyAction:addChild(flowerNode)
        flowerAnime:gotoFrameAndPlay(0, false)

        gt.soundEngine:playEffect("pkdesk/zhanshizhufu")

        local scaleTo = cc.ScaleTo:create(0.5, 1.0)
        Image_zhupai:setVisible(true)
        Image_zhupai:setScale(0.1)
        Image_zhupai:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), scaleTo))
    end)))
    

    self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function()
        Node_flyAction:removeAllChildren()
        if self.zhuangPos == self.playerSeatIdx - 1 then
              --描述文字
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(false)
            gt.soundEngine:playEffect("pkdesk/qingmaidi")
            
            self.timeNumber = 15
            local Node_maidi = gt.seekNodeByName(self.rootNode, "Node_maidi")
            local Btn_maiDI = gt.seekNodeByName(Node_maidi, "Btn_maiDI")
            Node_maidi:setVisible(self.is_sit)
            Btn_maiDI:setTouchEnabled(false)
            Btn_maiDI:setBright(false)
            local Text_maidi = gt.seekNodeByName(Node_maidi, "Text_maidi")
            Text_maidi:setString("请选择4张底牌,已选 0 张")
            --显示埋底的layer
            local Layer_maidiHandCards = gt.seekNodeByName(Node_maidi, "Layer_maidiHandCards")
            Layer_maidiHandCards:removeAllChildren()
            local size = Layer_maidiHandCards:getContentSize()
            local startposX = size.width/2 - #self.holdCardsNum/2 * 60
            local posY = size.height/2
            self.maidiCards = nil
            self.maidiCards = {}
            gt.log("-------self.holdCardsNum-------")
            gt.dump(self.holdCardsNum)
            for i = 1, #self.holdCardsNum do
                if Layer_maidiHandCards then
                 local card = ccui.ImageView:create()
                 card:loadTexture("res/sd/pk/" .. self.holdCardsNum[i] .. ".png")
                 Layer_maidiHandCards:addChild(card)
                 card:setPosition(cc.p(startposX + i*60, posY))
                 card:setTag(self.holdCardsNum[i])
                 if self:checkColor(self.holdCardsNum[i]) == self.MainColor or self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.KING then
                     local star = ccui.ImageView:create()
                     star:loadTexture("res/sd/desk/star.png")
                     card:addChild(star)
                     star:setPosition(cc.p(25, 30))
		     if self.isChangZhu and self:is_changzhu(self.holdCardsNum[i]) then 
                        local star = ccui.ImageView:create()
                        star:loadTexture("res/sd/desk/star.png")
                        card:addChild(star)
                        star:setPosition(cc.p(25, 60))
                    end
                 end
 	        	table.insert(self.maidiCards, card)
                end
             end
            if not self.is_sit then 
                local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
                Text_desc:setVisible(true)
                Text_desc:setString("等待其他玩家埋底")
            end
        else
            --描述文字
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(true)
            Text_desc:setString("等待庄家埋底")
        end

        self.isMaiDi = true
    end)))
    
    gt.log("----self.holdCardsNum-----")
    gt.dump(self.holdCardsNum)

    gt.log("---self.MainColor--")
    gt.dump(self.MainColor)

    self.holdCardsNum = self:sortCards(self.holdCardsNum, self.MainColor)

    gt.log("----2----self.holdCardsNum ---")
    gt.dump(self.holdCardsNum)
    
    local NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_player1")
    local Layer_handCards = gt.seekNodeByName(NodePlayerMyself, "Layer_handCards")
    Layer_handCards:removeAllChildren()
    local size = Layer_handCards:getContentSize()
    local posx =  self.zhuangPos == self.playerSeatIdx - 1 and 60 or p_idx
    local startposX = size.width/2 - #self.holdCardsNum/2 * posx
    local posY = size.height/2
    self.holdCards = nil
    self.holdCards = {}
    for i = 1, #self.holdCardsNum do
        if Layer_handCards then
         local card = ccui.ImageView:create()
         card:loadTexture("res/sd/pk/" .. self.holdCardsNum[i] .. ".png")
            Layer_handCards:addChild(card)
            card:setPosition(cc.p(startposX + i*posx, posY))
            card:setTag(self.holdCardsNum[i])
            if self:checkColor(self.holdCardsNum[i]) == self.MainColor or self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.KING then
                local star = ccui.ImageView:create()
                star:loadTexture("res/sd/desk/star.png")
                card:addChild(star)
                star:setPosition(cc.p(25, 30))
		if self.isChangZhu and self:is_changzhu(self.holdCardsNum[i]) then 
                        local star = ccui.ImageView:create()
                        star:loadTexture("res/sd/desk/star.png")
                        card:addChild(star)
                        star:setPosition(cc.p(25, 60))
                    end
            end
 		table.insert(self.holdCards, card)
        end
     end

    if self.gz_card[1][1] and self.gz_card[1][1]:getTag() ~= 0 then 
        local buf = {}
       
        for i = 1, 5 do
            buf[i] = {}
            for j = 1 , 10 do
                local cardV = self.gz_card[i][j]:getTag() - 1000
                table.insert(buf[i],cardV)
            end
            buf[i] = self:sortCards(buf[i], self.MainColor)
        end

        for i = 1, 5 do
            for j = 1 , 10 do
                self.gz_card[i][j]:loadTexture("res/sd/pk/" .. buf[i][j] .. ".png")     
                self.gz_card[i][j]:setTag(buf[i][j]+ 1000)
            end
        end



        for i = 1, 5 do
            for j = 1 , 10 do
                if self.gz_card[i][j] and not tolua.isnull(self.gz_card[i][j]) then 
                    local cardV = self.gz_card[i][j]:getTag() - 1000
                    if self:checkColor(cardV) == self.MainColor or self:checkColor(cardV) == PlaySceneWuRen.ColorType.KING then
                        local star = ccui.ImageView:create()
                        star:loadTexture("res/sd/desk/star.png")
                        self.gz_card[i][j]:addChild(star)
                        star:setPosition(cc.p(25, 30))
			if self.isChangZhu and self:is_changzhu(cardV) then 
                        local star = ccui.ImageView:create()
                        star:loadTexture("res/sd/desk/star.png")
                        self.gz_card[i][j]:addChild(star)
                        star:setPosition(cc.p(25, 60))
                    end
                    end
                end
            end
        end

    end

    self.turnPos = self.zhuangPos
    self.timeNumber = 15
    for i = 1, 5 do
        local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
        --显示时钟
        local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
        if ((self.turnPos + self.seatOffset) % 5 + 1) == i then
            Img_clock:setVisible(true)
        else
            Img_clock:setVisible(false)
        end
    end
end

function PlaySceneWuRen:selectZhuangJia()
    gt.log("选庄家")
    if self.selectZhuangNum > 0 then
        local msgToSend = {}
	    msgToSend.kMId = gt.MSG_C_2_S_WURENBAIFEN_SELECT_FRIEND
	    msgToSend.kPos = self.playerSeatIdx-1
	    msgToSend.kSelectFriendCard = self.selectZhuangNum
	    gt.socketClient:sendMessage(msgToSend)
    else
		require("client/game/dialog/NoticeTips"):create("提示", "请选择副庄家", nil, nil, true)
    end
end

--选副庄家回复
function PlaySceneWuRen:onRcvSelectFriend(msgTbl)
    gt.log("选庄家返回")
    dump(msgTbl)
	self.isMaiDi = false
    --描述文字
    local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
    Text_desc:setVisible(false)

    --关闭选庄界面
    local Node_xuanzhuang = gt.seekNodeByName(self.rootNode, "Node_xuanzhuang")
    Node_xuanzhuang:setVisible(false)
    self.turnPos = msgTbl.kNextOutCardPos

    --副庄家的牌
    local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
    local Img_duijia = gt.seekNodeByName(Node_leftInfo, "Img_duijia")
    Img_duijia:setVisible(false)
	Img_duijia:loadTexture("res/sd/pkSmall/" .. msgTbl.kSelectFriendCard .. ".png")

    local fuzhuang = ccui.ImageView:create()
	fuzhuang:loadTexture("res/sd/pkSmall/" .. msgTbl.kSelectFriendCard .. ".png")

    --播放选副庄家动画
    local Node_flyAction = gt.seekNodeByName(self.rootNode, "Node_flyAction")
    Node_flyAction:removeAllChildren()
    Node_flyAction:addChild(fuzhuang)
    Node_flyAction:setPosition(gt.winCenter)
    local moveto = cc.MoveTo:create(0.6, cc.p(200, 590))
    Node_flyAction:runAction(cc.Sequence:create(moveto, cc.CallFunc:create(function() 
        Node_flyAction:removeAllChildren()
	    local flowerNode, flowerAnime = gt.createCSAnimation("flowerSplash.csb")
        Node_flyAction:addChild(flowerNode)
        flowerAnime:gotoFrameAndPlay(0, false)
    
        gt.soundEngine:playEffect("pkdesk/zhanshizhufu")

        local scaleTo = cc.ScaleTo:create(0.5, 1.0)
        Img_duijia:setVisible(true)
        Img_duijia:setScale(0.1)
        Img_duijia:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), scaleTo))
    end)))
    
    self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function()
        Node_flyAction:removeAllChildren()
         --显示时钟
        self.timeNumber = 15
	    local FirendZhuangPos = (msgTbl.kFirendZhuangPos + self.seatOffset) % 5 + 1
        for i = 1, 5 do
	    	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
            local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
            local Img_fuzhuang =  gt.seekNodeByName(playerNode, "Img_fuzhuang")
            if ((self.turnPos + self.seatOffset) % 5 + 1) == i then
                Img_clock:setVisible(true)
            else
                Img_clock:setVisible(false)
            end
           

            if FirendZhuangPos == i and msgTbl.kFirendZhuangPos < 5 then
                Img_fuzhuang:setVisible(true)
               
                if msgTbl.kFirendZhuangPos == self.zhuangPos then
                    gt.log("设置坐标")
                    local Img_banker =  gt.seekNodeByName(playerNode, "Img_banker")
                    Img_banker:setPosition(cc.p(-5,55))
                    Img_banker:setVisible(true)
                end
            else
                
                Img_fuzhuang:setVisible(false)
            end
            -- if not self.is_sit then 
            --     Img_fuzhuang:setVisible(msgTbl.kFirendZhuangPos == i)
            -- end
	    end
        
        --如果下一个出牌的人是我自己,显示出牌按钮
        local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
        if self.turnPos == self.playerSeatIdx - 1 then
            
            Btn_chupai:setVisible(self.is_sit)
            Btn_chupai:setTouchEnabled(false)
            Btn_chupai:setBright(false)
        else
            Btn_chupai:setVisible(false)
        end
        
        local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
        self.Text_yufen = gt.seekNodeByName(Node_leftInfo, "Text_yufen")
        self.Text_yufen:setString(tostring(100))

        --删除本轮出的牌
        for i=1, 5 do 
	        local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
            local out = gt.seekNodeByName(playerNode, "Node_outCard")
            out:stopAllActions()
            out:removeAllChildren()
        end
	self.roundFirstCard = 0 

        local notHandCards = self:checkHolds()
        local isTouchSelectCard = false
        local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
        if self.selectCard > 0 then
            isTouchSelectCard = true
            for i=1, #notHandCards do
                if self.selectCard == notHandCards[i] then
                    
                    isTouchSelectCard = false
                    break
                end
            end
        else
            
            isTouchSelectCard = false
        end
        if isTouchSelectCard then
            Btn_chupai:setTouchEnabled(true)
            Btn_chupai:setBright(true)
        else
            Btn_chupai:setTouchEnabled(false)
            Btn_chupai:setBright(false)
        end
    end)))
end

function PlaySceneWuRen:sendCardToServer() --todo
    gt.log("出牌")
    self.timeNumber = 15
    if self.selectCard > 0 then
	local index = 0;
        for i=1, #self.holdCardsNum do
            if self.selectCard == self.holdCardsNum[i] then
                index = i
                break
            end
        end
        
        if index == 0  then 
            require("client/game/dialog/NoticeTips"):create("提示", "出牌不合法", nil, nil, true)
            return
        end

        for i=1, 1 do 
            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
            local out = gt.seekNodeByName(playerNode, "Node_outCard")
            out:removeAllChildren()
        end

        local msgToSend = {}
	    msgToSend.kMId = gt.MSG_C_2_S_WURENBAIFEN_OUT_CARD
	    msgToSend.kPos = self.playerSeatIdx - 1
	    msgToSend.kOutCard = self.selectCard
	    gt.socketClient:sendMessage(msgToSend)
	    local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
        Btn_chupai:setVisible(false)

        

        local displaySeatIdx = 1
        local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
        local outCard = gt.seekNodeByName(playerNode, "Node_outCard")
        local card = ccui.ImageView:create()
        card:loadTexture("res/sd/pk/" .. self.selectCard .. ".png")
        outCard:addChild(card)
        card:setScale(0.5)
        self._outcard = card


        if index > 0 then
            table.remove(self.holdCardsNum, index)
            self.holdCardsNum = self:sortCards(self.holdCardsNum, self.MainColor)
        
            local Layer_handCards = gt.seekNodeByName(playerNode, "Layer_handCards")
            local size = Layer_handCards:getContentSize()
            local startposX = size.width/2 - #self.holdCardsNum/2 * p_idx
            local posY = size.height/2
            Layer_handCards:removeAllChildren()
            self.holdCards = nil
            self.holdCards = {}
            for i = 1, #self.holdCardsNum do
                if Layer_handCards then
                    local card = ccui.ImageView:create()
                    card:loadTexture("res/sd/pk/" .. self.holdCardsNum[i] .. ".png")
                    Layer_handCards:addChild(card)
                    card:setPosition(cc.p(startposX + i*p_idx, posY))
                    card:setTag(self.holdCardsNum[i])
                    table.insert(self.holdCards, card)
                        if self:checkColor(self.holdCardsNum[i]) == self.MainColor or self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.KING then
                            local star = ccui.ImageView:create()
                            star:loadTexture("res/sd/desk/star.png")
                            card:addChild(star)
                            star:setPosition(cc.p(25, 30))
                            if self.isChangZhu and self:is_changzhu(self.holdCardsNum[i]) then 
                            local star = ccui.ImageView:create()
                            star:loadTexture("res/sd/desk/star.png")
                            card:addChild(star)
                            star:setPosition(cc.p(25, 60))
                        end
                    end
                end
            end   
        end
        self.selectCard = 0
    else
		require("client/game/dialog/NoticeTips"):create("提示", "请选择出牌", nil, nil, true)
    end
end

function PlaySceneWuRen:onRcvOutCard(msgTbl)
    gt.log("出牌消息")
    dump(msgTbl)
    self.timeNumber = 15
    local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
    Btn_chupai:setVisible(false)
    --隐藏上轮的牌
    local Node_preRoundCard = gt.seekNodeByName(self.rootNode, "Node_preRoundCard")
    Node_preRoundCard:setVisible(false)

    --重置手牌位置
    self.chooseCardIdx = nil
    --for i=1, #self.holdCards do
    --    self.holdCards[i]:setPositionY(110)
    --end

    if msgTbl.kPos == self.playerSeatIdx - 1 then
        if msgTbl.kMode == -1 then
			require("client/game/dialog/NoticeTips"):create("提示", "出牌不合法", nil, nil, true)
	    	gt.socketClient:close()
            return
        end
    end
    
    --本轮出的牌
    self.curRoundCards = msgTbl.kOutCardArray
    -- 本轮第一个出牌的人
    if msgTbl.kTurnStart == 1 then
        self.roundFirstCard = msgTbl.kOutCard
    end
    
    -- if msgTbl.kPos == self.UsePos then 
    --     self.selectCard = 0
    -- end

    if msgTbl.kTurnOver == 1 then self.roundFirstCard = 0 end

    local notHandCards = self:checkHolds()
    local isTouchSelectCard = false
    local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
    if self.selectCard > 0 then
        isTouchSelectCard = true
        for i=1, #notHandCards do
            if self.selectCard == notHandCards[i] then
                
                isTouchSelectCard = false
                break
            end
        end
    else
        
        isTouchSelectCard = false
    end
    if isTouchSelectCard then
        Btn_chupai:setTouchEnabled(true)
        Btn_chupai:setBright(true)
    else
        Btn_chupai:setTouchEnabled(false)
        Btn_chupai:setBright(false)
    end
    --删除本轮出的牌
    for i=2, 5 do 
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
        local out = gt.seekNodeByName(playerNode, "Node_outCard")
        out:removeAllChildren()
    end
    
    for i=1, #self.curRoundCards do
        if self.curRoundCards[i] > 0 then
	        local displaySeatIdx = ((i-1) + self.seatOffset) % 5 + 1
	        local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
            local outCard = gt.seekNodeByName(playerNode, "Node_outCard")
		    local card
            if  not self.is_sit then 
                card = ccui.ImageView:create()
                card:loadTexture("res/sd/pk/" .. self.curRoundCards[i] .. ".png")
                outCard:addChild(card)
                card:setScale(0.5)
            else
                if displaySeatIdx ~= 1  then
                    gt.log("add——————————————————————")
                    card = ccui.ImageView:create()
                    card:loadTexture("res/sd/pk/" .. self.curRoundCards[i] .. ".png")
                    outCard:addChild(card)
                    card:setScale(0.5)
                else
                    card = self._outcard
                end
            end
            if not tolua.isnull(card) then 
                if card:getChildByName("_MAX_") then
                    card:removeChildByName("_MAX_")
                end
            end
            if msgTbl.kCurrBig == i-1 and not tolua.isnull(card) then
                local max = ccui.ImageView:create()
                max:loadTexture("res/sd/desk/max.png")
                max:setName("_MAX_")
                card:addChild(max)
                max:setPosition(cc.p(122, 28))
            end
            if not self.is_sit and (i-1) == msgTbl.kPos  then 
                if self.gz_card[displaySeatIdx][msgTbl.kHandCardCount[displaySeatIdx]+1] and  not tolua.isnull(self.gz_card[displaySeatIdx][msgTbl.kHandCardCount[displaySeatIdx]+1]) and self._node then
                    if self.gz_card[displaySeatIdx][msgTbl.kHandCardCount[displaySeatIdx]+1]:getTag() == 0 then 
                        self.gz_card[displaySeatIdx][msgTbl.kHandCardCount[displaySeatIdx]+1]:removeFromParent()
                        self.gz_card[displaySeatIdx][msgTbl.kHandCardCount[displaySeatIdx]+1] = nil
                        if displaySeatIdx == 1 then 
                            local index = msgTbl.kHandCardCount[displaySeatIdx]
                            if index > 0 and index ~= 10 then
                                for j = 1 , index do
                                    local node = self.gz_card[displaySeatIdx][j]
                                    if node then node:setPositionX(node:getPositionX()+44) end
                                end
                            end
                        end
                    else
                        
                        local idx = 1
                        gt.log("iiiiiii.....",i)
                        gt.log("displaySeatIdx....",displaySeatIdx)
                        gt.log("self.curRoundCards[i].....",self.curRoundCards[i])

                        --for x = 1, 10 do 
                        --    if not tolua.isnull(self.gz_card[displaySeatIdx][x]) then 
                        --        gt.log("allcard______data.......",self.gz_card[displaySeatIdx][x]:getTag() - 1000)
                        --    end
                        --end

                        for x = 1, msgTbl.kHandCardCount[displaySeatIdx]+1 do

                            gt.log("card______data.......",self.gz_card[displaySeatIdx][x]:getTag() - 1000)

                            if self.gz_card[displaySeatIdx][x] and self.gz_card[displaySeatIdx][x]:getTag()-1000 ~= self.curRoundCards[i] then 
                               self.gz_card[displaySeatIdx][idx]:loadTexture("res/sd/pk/" .. (self.gz_card[displaySeatIdx][x]:getTag()-1000) .. ".png")
                               self.gz_card[displaySeatIdx][idx]:setTag(self.gz_card[displaySeatIdx][x]:getTag())
                               idx = idx + 1
                            end
                        end
                        self.gz_card[displaySeatIdx][msgTbl.kHandCardCount[displaySeatIdx]+1]:removeFromParent()
                        self.gz_card[displaySeatIdx][msgTbl.kHandCardCount[displaySeatIdx]+1] = nil

                        if displaySeatIdx == 1 then 
                            local index = msgTbl.kHandCardCount[displaySeatIdx]
                            if index > 0 and index ~= 10 then
                                for j = 1 , index do
                                    local node = self.gz_card[displaySeatIdx][j]
                                    if node then node:setPositionX(node:getPositionX()+44) end
                                end
                            end
                        end

                       
                    end
                end 
            end
        end

    end




	local displaySeatIdx = (msgTbl.kPos + self.seatOffset) % 5 + 1
	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
    

    --播放声音
    if msgTbl.kSoundType ~= -1 then 
        gt.soundEngine:playEffect("pkdesk/pia")
        if msgTbl.kSoundType == 1 then
           gt.soundEngine:playEffect("pkdesk/diaozhu")
        elseif msgTbl.kSoundType == 2 then
           gt.soundEngine:playEffect("pkdesk/guanshang")
        elseif msgTbl.kSoundType == 3 then
           gt.soundEngine:playEffect("pkdesk/dani")
        elseif msgTbl.kSoundType == 4 then
           gt.soundEngine:playEffect("pkdesk/bi")
           local Node_action = gt.seekNodeByName(playerNode, "Node_action")
           local biNode, biAnime = gt.createCSAnimation("runAction/bi_run.csb")  
           Node_action:stopAllActions()
           Node_action:removeAllChildren()
           Node_action:addChild(biNode)
           biAnime:gotoFrameAndPlay(0, false)
           self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function(sender)
               Node_action:stopAllActions()
               Node_action:removeAllChildren()
           end)))
        elseif msgTbl.kSoundType == 5 then
           gt.soundEngine:playEffect("pkdesk/gaibi")
           local Node_action = gt.seekNodeByName(playerNode, "Node_action")
           local gaibiNode, gaibiAnime = gt.createCSAnimation("gaibiAction.csb")
           Node_action:stopAllActions()
           Node_action:removeAllChildren()
           Node_action:addChild(gaibiNode)
           gaibiAnime:gotoFrameAndPlay(0, false)
           self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function(sender)
               Node_action:stopAllActions()
               Node_action:removeAllChildren()
           end)))
	   elseif msgTbl.kSoundType == 8 then
            gt.soundEngine:playEffect("pkdesk/dianpai")
        else
            if msgTbl.kTurnStart == 1 then
                gt.soundEngine:playEffect("pkcard/" .. msgTbl.kOutCard)
            end
        end
    end
    --出牌删除手牌
    if msgTbl.kPos == self.playerSeatIdx - 1 then
        local index = 0;
        for i=1, #self.holdCardsNum do
            if msgTbl.kOutCard == self.holdCardsNum[i] then
                index = i
                break
            end
        end
        if index > 0 then
            table.remove(self.holdCardsNum, index)
            self.holdCardsNum = self:sortCards(self.holdCardsNum, self.MainColor)
        
            local Layer_handCards = gt.seekNodeByName(playerNode, "Layer_handCards")
            local size = Layer_handCards:getContentSize()
            local startposX = size.width/2 - #self.holdCardsNum/2 * p_idx
            local posY = size.height/2
            Layer_handCards:removeAllChildren()
            self.holdCards = nil
            self.holdCards = {}
            for i = 1, #self.holdCardsNum do
                if Layer_handCards then
	                local card = ccui.ImageView:create()
	                card:loadTexture("res/sd/pk/" .. self.holdCardsNum[i] .. ".png")
                    Layer_handCards:addChild(card)
                    card:setPosition(cc.p(startposX + i*p_idx, posY))
                    card:setTag(self.holdCardsNum[i])
	        		table.insert(self.holdCards, card)
                    if self:checkColor(self.holdCardsNum[i]) == self.MainColor or self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.KING then
                        local star = ccui.ImageView:create()
                        star:loadTexture("res/sd/desk/star.png")
                        card:addChild(star)
                        star:setPosition(cc.p(25, 30))
                        if self.isChangZhu and self:is_changzhu(self.holdCardsNum[i]) then 
                            local star = ccui.ImageView:create()
                            star:loadTexture("res/sd/desk/star.png")
                            card:addChild(star)
                            star:setPosition(cc.p(25, 60))
                        end
                    end
                end
            end
            gt.log("-----最后一手牌--1---")
            if msgTbl.kPos == self.UsePos and self.UsePos >=0 and self.UsePos <5 then  -- 最后一手牌
                gt.log("-----最后一手牌--2---")
                    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player1" )
                    local outCard = gt.seekNodeByName(playerNode, "Node_outCard")
                    outCard:removeAllChildren()
                    local card = ccui.ImageView:create()
                    card:loadTexture("res/sd/pk/" .. msgTbl.kOutCard .. ".png")
                    outCard:addChild(card)
                    card:setScale(0.5)
                    self._outcard = card
                
                    -- for x = 1 , 5 do 
                    --     if ((x-1) + self.seatOffset) % 5 + 1 == 1 then
                    --         gt.log(msgTbl.kCurrBig)
                    --         if msgTbl.kCurrBig == x-1 and not tolua.isnull(card) then
                    --             local max = ccui.ImageView:create()
                    --             max:loadTexture("res/sd/desk/max.png")
                    --             card:addChild(max)
                    --             max:setPosition(cc.p(122, 28))
                    --         end
                    --     end
                    -- end

                end
            end
        end
       
        local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
        Btn_chupai:setVisible(false)
        -- 本轮最后一个出牌的人
        if msgTbl.kTurnOver == 1 then
        for i = 1, 5 do
            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
                --显示时钟
            local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
                
            Img_clock:setVisible(false)
                
        end

        if not tolua.isnull(self._outcard) then 
            for x = 1 , 5 do 
                if ((x-1) + self.seatOffset) % 5 + 1 == 1 then
                    if msgTbl.kCurrBig == x-1  then
                        local max = ccui.ImageView:create()
                        max:loadTexture("res/sd/desk/max.png")
                        self._outcard:removeAllChildren()
                        self._outcard:addChild(max)
                        max:setPosition(cc.p(122, 28))
                    end
                end
            end
        end

        self._outcard = nil

        self.roundFirstCard = 0
        --上一轮出的牌
        self.preRoundCards = msgTbl.kPrevOutCard
        self.curBigpos = msgTbl.kCurrBig
        
        --剩余的分数
        local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
        self.Text_yufen = gt.seekNodeByName(Node_leftInfo, "Text_yufen")
        self.Text_yufen:setString(tostring(msgTbl.kLeftoverScore))

        --播放语音
        if msgTbl.kThisTurnScore > 0 then
            gt.soundEngine:playEffect("pkdesk/xianjiadefen")

            --播放得分动画
	    	local label = gt.createTTFLabel("+" .. tostring(msgTbl.kThisTurnScore), 50)
            label:setColor(cc.c3b(255,255,0))
            local Node_flyAction = gt.seekNodeByName(self.rootNode, "Node_flyAction")
            Node_flyAction:addChild(label)
            Node_flyAction:setPosition(gt.winCenter)
            local moveto = cc.MoveTo:create(0.5, cc.p(196, 660))
            Node_flyAction:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), moveto, cc.CallFunc:create(function() 
                Node_flyAction:removeAllChildren()
                
	            local flowerNode, flowerAnime = gt.createCSAnimation("flowerSplash.csb")
                Node_flyAction:addChild(flowerNode)
                flowerAnime:gotoFrameAndPlay(0, false)

                gt.soundEngine:playEffect("pkdesk/zhanshizhufu")

                -- 显示当前得分
                local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
                self.Text_score  = gt.seekNodeByName(Node_leftInfo, "Text_score")
                if self.Text_score then
                    self.Text_score:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function() 
                        Node_flyAction:removeAllChildren()
                        self.Text_score:setString(tostring(msgTbl.kTotleScore))
                    end)))
                end

                --出过的分牌
                local Node_scoreCards = gt.seekNodeByName(self.rootNode, "Node_scoreCards")
                if Node_scoreCards then
                    Node_scoreCards:removeAllChildren()
                    for i = 1, #msgTbl.kScoreCards do
                        if msgTbl.kScoreCards[i] > 0 then
	                        local card = ccui.ImageView:create()
	                        card:loadTexture("res/sd/pk/" .. msgTbl.kScoreCards[i] .. ".png")
                            Node_scoreCards:addChild(card)
                            if i > 6 then
                                card:setPosition(cc.p((i-7)*165, -230))
                            else
                                card:setPosition(cc.p((i-1)*165, 0))
                            end
                        end
                    end
	            end 
            end)))
        end
        
        local _time = msgTbl.kNextPos == 5 and 3 or ( msgTbl.kNextPos == self.UsePos and 0.7 or 0.5 )

        --延时1秒删除手牌,并显示出牌按钮
        self:runAction(cc.Sequence:create(cc.DelayTime:create(_time), cc.CallFunc:create(function()

            --删除本轮出的牌
            for i=1, 5 do 
	            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
                local out = gt.seekNodeByName(playerNode, "Node_outCard")
                out:removeAllChildren()
            end
            
            self.turnPos = msgTbl.kNextPos  
            self.timeNumber = 15
            
            --如果下一个出牌的人是我自己,显示出牌按钮
            local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
            if self.turnPos == self.playerSeatIdx - 1 then
                Btn_chupai:setVisible(self.is_sit)
                --Btn_chupai:setTouchEnabled(false)
                --Btn_chupai:setBright(false)
            end
            for i = 1, 5 do
	        	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
                --显示时钟
                local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
                if ((self.turnPos + self.seatOffset) % 5 + 1) == i then
                    Img_clock:setVisible(true)
                else
                    Img_clock:setVisible(false)
                end
	        end
        end)))
    else
        self.turnPos = msgTbl.kNextPos  
        self.timeNumber = 15
        
        --如果下一个出牌的人是我自己,显示出牌按钮
        local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
        if self.turnPos == self.playerSeatIdx - 1 then
            Btn_chupai:setVisible(self.is_sit)
            if not isTouchSelectCard then 
                for i = 1 , #self.holdCardsNum do
                    if not tolua.isnull(self.holdCardsNum[i]) then 
                        self.holdCardsNum[i]:setPositionY(110)
                    end
                end
            end
	end
        for i = 1, 5 do
	    	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
            --显示时钟
            local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
            if ((self.turnPos + self.seatOffset) % 5 + 1) == i then
                Img_clock:setVisible(true)
            else
                Img_clock:setVisible(false)
            end
	    end
    end

    for i=1, #self.holdCards do
        self.holdCards[i]:setColor(cc.WHITE)
    end
    -- 出牌的时候检测能出哪些牌,不能出的牌置灰
    if self.turnPos == self.playerSeatIdx - 1 then
        if msgTbl.kTurnOver ~= 1 then
            local notHandCards = self:checkHolds()
            for i=1, #self.holdCards do
                for j=1, #notHandCards do
                    if self.holdCards[i]:getTag() == notHandCards[j] then
                        self.holdCards[i]:setColor(cc.c3b(200,200,200))
                    end
                end
            end
        end
    end
end

--手牌排序
function PlaySceneWuRen:sortCards(handcards, MainCard)
    local heitaoCards = {}
    local hongtaoCards = {}
    local meihuacards = {}
    local fangkuaicards = {}
    local maincards = {}
    local allcards = {}
    for i=1, #handcards do
        if self.isChangZhu then
            if handcards[i] >= 78 or handcards[i] == 2 or handcards[i] == 18 or handcards[i] == 34 or handcards[i] == 50 then
                --存储大小王和四个2
		if self:checkColors(handcards[i]) == MainCard then
                    handcards[i] = handcards[i] * 100
                end
                if handcards[i] >= 78 and  handcards[i] < 100 then 
                    handcards[i] = handcards[i] * 100
                end
		    	table.insert(maincards, handcards[i])
            elseif handcards[i] >= 49 and handcards[i] <= 61 then
                --存储黑桃
		    	table.insert(heitaoCards, handcards[i])
            elseif handcards[i] >= 33 and handcards[i] <= 45 then
                --存储红桃
		    	table.insert(hongtaoCards, handcards[i])
            elseif handcards[i] >= 17 and handcards[i] <= 29 then
                --存储梅花
		    	table.insert(meihuacards, handcards[i])
            elseif handcards[i] >= 1 and handcards[i] <= 13 then
                --存储方片
		    	table.insert(fangkuaicards, handcards[i])
            end
        else
        
            if handcards[i] >= 78 then
                --存储大小王
		    	table.insert(maincards, handcards[i])
            elseif handcards[i] >= 49 and handcards[i] <= 61 then
                --存储黑桃
		    	table.insert(heitaoCards, handcards[i])
            elseif handcards[i] >= 33 and handcards[i] <= 45 then
                --存储红桃
		    	table.insert(hongtaoCards, handcards[i])
            elseif handcards[i] >= 17 and handcards[i] <= 29 then
                --存储梅花
		    	table.insert(meihuacards, handcards[i])
            elseif handcards[i] >= 1 and handcards[i] <= 13 then
                --存储方片
		    	table.insert(fangkuaicards, handcards[i])
            end
        end
    end
    table.sort(maincards, function(a, b)
        return a>b
    end)
    table.sort(heitaoCards, function(a, b)
        return a>b
    end)
    table.sort(hongtaoCards, function(a, b)
        return a>b
    end)
    table.sort(meihuacards, function(a, b)
        return a>b
    end)
    table.sort(fangkuaicards, function(a, b)
        return a>b
    end)

    if heitaoCards[#heitaoCards] == 49 then
        local A = 49
        table.remove(heitaoCards, #heitaoCards)
        table.insert(heitaoCards, 1, A)

    end
    if hongtaoCards[#hongtaoCards] == 33 then
        local A = 33
        table.remove(hongtaoCards, #hongtaoCards)
        table.insert(hongtaoCards, 1, A)

    end
    if meihuacards[#meihuacards] == 17 then
        local A = 17
        table.remove(meihuacards, #meihuacards)
        table.insert(meihuacards, 1, A)

    end
         
    if fangkuaicards[#fangkuaicards] == 1 then
        local A = 1
        table.remove(fangkuaicards, #fangkuaicards)
        table.insert(fangkuaicards, 1, A)
    end
    
    if MainCard == PlaySceneWuRen.ColorType.HEITAO then
        for i=1, #maincards do
            table.insert(allcards, maincards[i])
        end   
        for i=1, #heitaoCards do
            table.insert(allcards, heitaoCards[i])
        end   
        for i=1, #hongtaoCards do
            table.insert(allcards, hongtaoCards[i])
        end   
        for i=1, #meihuacards do
            table.insert(allcards, meihuacards[i])
        end   
        for i=1, #fangkuaicards do
            table.insert(allcards, fangkuaicards[i])
        end
    elseif MainCard == PlaySceneWuRen.ColorType.HONGTAO then
        for i=1, #maincards do
            table.insert(allcards, maincards[i])
        end    
        for i=1, #hongtaoCards do
            table.insert(allcards, hongtaoCards[i])
        end    
        for i=1, #heitaoCards do
            table.insert(allcards, heitaoCards[i])
        end 
        for i=1, #meihuacards do
            table.insert(allcards, meihuacards[i])
        end   
        for i=1, #fangkuaicards do
            table.insert(allcards, fangkuaicards[i])
        end
    elseif MainCard == PlaySceneWuRen.ColorType.MEIHUA then
        for i=1, #maincards do
            table.insert(allcards, maincards[i])
        end     
        for i=1, #meihuacards do
            table.insert(allcards, meihuacards[i])
        end     
        for i=1, #heitaoCards do
            table.insert(allcards, heitaoCards[i])
        end  
        for i=1, #hongtaoCards do
            table.insert(allcards, hongtaoCards[i])
        end
        for i=1, #fangkuaicards do
            table.insert(allcards, fangkuaicards[i])
        end
    elseif MainCard == PlaySceneWuRen.ColorType.FANGPIAN then
        for i=1, #maincards do
            table.insert(allcards, maincards[i])
        end  
        for i=1, #fangkuaicards do
            table.insert(allcards, fangkuaicards[i])
        end     
        for i=1, #heitaoCards do
            table.insert(allcards, heitaoCards[i])
        end  
        for i=1, #hongtaoCards do
            table.insert(allcards, hongtaoCards[i])
        end  
        for i=1, #meihuacards do
            table.insert(allcards, meihuacards[i])
        end 
    end
    for i = 1 , #allcards do
        if allcards[i] > 100 then 
           allcards[i] =  allcards[i] / 100
        end
    end
    return allcards
end


function PlaySceneWuRen:onRcvRoundReport(msgTbl)
    gt.log("收到小结结算消息")
    dump(msgTbl)
    self:chongZhiJiaoPai2()
    local delayTime = cc.DelayTime:create(2.5)
	local callFunc = cc.CallFunc:create(function(sender)
        --   self._run = false
        self:resetScene()
        if msgTbl.kIsFinish == 1 then -- 非正常结束解散 == 1 or == 0
        else
            local isLast = false
            if  self.curDeskCount == self.maxDeskCount then
               isLast = true
            end
               --endgameJiaopai_wuren
            local roundReport = gt.include("view/WRBFRoundReport"):create(self.roomPlayers, self.playerSeatIdx, msgTbl, self.roomid, isLast, self.localHeadImg, self.isFangZuobi,self.xianKouDi)
            self:addChild(roundReport, PlaySceneWuRen.ZOrder.ROUND_REPORT)
            roundReport:setName("__XIAOJIESUAN__")
            local Text_fanghaoAndJushu = gt.seekNodeByName(self.rootNode, "Text_fanghaoAndJushu")
            gt.seekNodeByName(roundReport,"jushu"):setString("局数:"..Text_fanghaoAndJushu:getString())
            gt.seekNodeByName(roundReport,"difen"):setString("底分："..(self.data.kPlaytype[1] or "err"))
        end
	end)
    
    if msgTbl.kIsFinish == 0 then 
        if self.is_sit then
                        -- 赢得 状态
                    -- DIPAI_ZHUANG_JIAOPAI = 1,                               //庄家交牌,提前结束
                    -- DIPAI_ZHUANG_WIN = 2,                                     //庄家保底
                    -- DIPAI_ZHUANG_WIN_XIAN_SCORE0 =3,           //庄家保底 光头
                    -- DIPAI_XIAN_WIN = 4                                             //闲家抠底
            if msgTbl.kWuRenBaiFenOverState == 1 then --庄家交牌

            elseif msgTbl.kWuRenBaiFenOverState == 2 then --庄家保底 
                gt.soundEngine:Poker_playEffect("sj_sound/banker_b.mp3")
            elseif msgTbl.kWuRenBaiFenOverState == 3 then --庄家保底  光头
                gt.soundEngine:playEffect("pkdesk/guangtou")
            elseif msgTbl.kWuRenBaiFenOverState == 4 then --闲家抠底 
                -- gt.soundEngine:playEffect("pkdesk/guangtou")
                gt.soundEngine:playEffect("pkdesk/fdz")
            end
        end
        
    end
    -- if msgTbl.kSate == 1 or msgTbl.kSate == 2 or msgTbl.kSate == 3 then 
    --     if msgTbl.kSate == 2 then 
    --         gt.soundEngine:playEffect("pkdesk/guangtou")
    --     else
    --         gt.soundEngine:Poker_playEffect("sj_sound/banker_b.mp3")
    --     end
    -- end

    -- if msgTbl.kSate == 4 or msgTbl.kSate == 5 then 
    --     gt.soundEngine:playEffect("pkdesk/fdz")
    -- end

        -- 设置分数
    for i = 1, 5 do
        local seat = ((i-1) + self.seatOffset) % 5 + 1
        local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seat)
        local Text_score =  gt.seekNodeByName(playerNode, "Text_score")
        Text_score:setString(tostring(msgTbl.kTotleScore[i]))
    end

    if  not self.is_sit then
        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
        Text_desc:setVisible(true)
        Text_desc:setString("等待其他玩家准备")
        return
    end
  
    self.game_finish = msgTbl.kIsFinish
    self._run = true
	local seqAction = cc.Sequence:create(delayTime, callFunc)
    self:findNodeByName("DelayTime_node"):runAction(seqAction)
end

function PlaySceneWuRen:chongLianXianJia(num, jiaoAgree, kPos, kZhuang, time)  --(self.jiaoPaiOneVisible, jiaoAgree, msgTbl.kPos, msgTbl.kZhuang)
    gt.log("------num------")
    gt.log(num)
    if num == 0 then   --弹jiaopai2
        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
        Text_desc:setVisible(true)
        Text_desc:setString("等待庄家选择是否交牌")
    elseif num == 1 then  --庄家申请后，闲家退出后重进的时间  需要弹出 jiaopai2
        local zijiPos = kPos + 1
             -- if jiaoAgree[zijiPos] == -1 then --闲家 未选择
            local agreePer = 0
            for i=1, #jiaoAgree do
                if jiaoAgree[i] == 1 then
                    agreePer = agreePer + 1
                end
            end

            local NoticeJiaoPai = gt.seekNodeByName(self.rootNode, "Notice_jiaopai2")
            NoticeJiaoPai:setVisible(true)
    
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(true)
            Text_desc:setString(" ")
        
            local Text_dec = gt.seekNodeByName(NoticeJiaoPai, "Text_dec")
            Text_dec:setString("同意人数 "..agreePer.."/5")
    
            local Text_daojishi = gt.seekNodeByName(NoticeJiaoPai, "Text_daojishi") --倒计时15秒
            Text_daojishi:setString(tostring(time))
        
            self.btn_agree = gt.seekNodeByName(NoticeJiaoPai, "btn_agree")
            gt.addBtnPressedListener(self.btn_agree, function()
                -- NoticeJiaoPai:setVisible(false)
                self.btn_agree:setTouchEnabled(false)
                self.btn_agree:setBright(false)

                self.btn_disagree:setTouchEnabled(false)
                self.btn_disagree:setBright(false)

                self:sendXJiaoPaiToServer(1)  --闲家 同意庄家 交牌 1
                Text_desc:setString("等待其他闲家决定交牌结果")
                --选择交牌  发消息给服务器。
                -- 收到消息后， 其他玩家显示弹窗， 庄家申请交牌，是否同意。
            end)
        
            self.btn_disagree = gt.seekNodeByName(NoticeJiaoPai, "btn_disagree")
            gt.addBtnPressedListener(self.btn_disagree, function()
                NoticeJiaoPai:setVisible(false)

                self:sendXJiaoPaiToServer(0)  --闲家不同意庄家交牌发 0
                Text_desc:setString("等待庄家定主")
                --拒绝交牌  继续游戏。
                --谈个 toast 小弹窗。 有玩家拒绝交牌，游戏继续。  
            end)

            if jiaoAgree[zijiPos] == 1 then --闲家已经同意
                self.btn_agree:setTouchEnabled(false)
                self.btn_agree:setBright(false)

                self.btn_disagree:setTouchEnabled(false)
                self.btn_disagree:setBright(false)
            end
    else
        self:chongZhiJiaoPai2()
        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
        Text_desc:setVisible(true)
        Text_desc:setString("等待庄家定主")
    end
end

function PlaySceneWuRen:GameResult(m)
    m.kIsFinish = 1
    self.isGameOver = 1
    self:chongZhiJiaoPai2()
    if self.game_finish == 1 then 
        gt.log("弹出总结")
        -- local roundReport = gt.include("view/WRBFRoundReport"):create(self.roomPlayers, self.playerSeatIdx, m, self.roomid, true, self.localHeadImg, self.isFangZuobi)
        -- self:addChild(roundReport, PlaySceneWuRen.ZOrder.ROUND_REPORT)

        gt.log("弹出总结")
        local roundReport = gt.include("view/PKRoundReport"):create(self.roomPlayers, self.playerSeatIdx, m, self.roomid, true, self.localHeadImg, self.isFangZuobi)
        self:addChild(roundReport, PlaySceneWuRen.ZOrder.ROUND_REPORT)
        local Text_fanghaoAndJushu = gt.seekNodeByName(self.rootNode, "Text_fanghaoAndJushu")
        gt.seekNodeByName(roundReport,"jushu"):setString("局数："..Text_fanghaoAndJushu:getString())
        gt.seekNodeByName(roundReport,"difen"):setString("底分："..(self.data.kPlaytype[1] or "err"))

    else
        self.zongjieData = m

        if not self._run then 

            if self:getChildByName("__XIAOJIESUAN__")  and self:getChildByName("__XIAOJIESUAN__"):isVisible()  then 
                local csbNode = self:getChildByName("__XIAOJIESUAN__")
                -- 开始下一局
                local startGameBtn = gt.seekNodeByName(csbNode, "Btn_nextGame")
                -- 查看总成绩
                local Btn_showFinal = gt.seekNodeByName(csbNode, "Btn_showFinal")
                -- 返回大厅
                local endGameBtn = gt.seekNodeByName(csbNode, "Btn_endGame")

                startGameBtn:setVisible(false)
                Btn_showFinal:setVisible(true)
                endGameBtn:setVisible(false)
            else
                -- local roundReport = gt.include("view/WRBFRoundReport"):create(self.roomPlayers, self.playerSeatIdx, m, self.roomid, true, self.localHeadImg, self.isFangZuobi)
                -- self:addChild(roundReport, PlaySceneWuRen.ZOrder.ROUND_REPORT)

                local roundReport = gt.include("view/PKRoundReport"):create(self.roomPlayers, self.playerSeatIdx, m, self.roomid, true, self.localHeadImg, self.isFangZuobi)
                self:addChild(roundReport, PlaySceneWuRen.ZOrder.ROUND_REPORT)
                local Text_fanghaoAndJushu = gt.seekNodeByName(self.rootNode, "Text_fanghaoAndJushu")
                gt.seekNodeByName(roundReport,"jushu"):setString("局数："..Text_fanghaoAndJushu:getString())
                gt.seekNodeByName(roundReport,"difen"):setString("底分："..(self.data.kPlaytype[1] or "err"))
            end
        end
    end
end

function PlaySceneWuRen:showFinalEvt(eventType)
    gt.log("显示总结")
    self:chongZhiJiaoPai2()
	-- local roundReport = gt.include("view/WRBFRoundReport"):create(self.roomPlayers, self.playerSeatIdx, self.zongjieData, self.roomid, true, self.localHeadImg, self.isFangZuobi)
    -- self:addChild(roundReport, PlaySceneWuRen.ZOrder.ROUND_REPORT)
    
    local roundReport = gt.include("view/PKRoundReport"):create(self.roomPlayers, self.playerSeatIdx, self.zongjieData, self.roomid, true, self.localHeadImg, self.isFangZuobi)
        self:addChild(roundReport, PlaySceneWuRen.ZOrder.ROUND_REPORT)
        local Text_fanghaoAndJushu = gt.seekNodeByName(self.rootNode, "Text_fanghaoAndJushu")
        gt.seekNodeByName(roundReport,"jushu"):setString("局数："..Text_fanghaoAndJushu:getString())
        gt.seekNodeByName(roundReport,"difen"):setString("底分："..(self.data.kPlaytype[1] or "err"))
end

function PlaySceneWuRen:resetScene(bool)
    self.roundFirstCard  = 0
    self.timeJiaopai_rec = nil
    self.timeJiaopai = 14
    self.MaxSelectScore = 0
    self._run = false
    self.isMaiDi = false
    -- 刚进入房间,隐藏玩家信息节点
    local Node_preRoundCard = gt.seekNodeByName(self.rootNode, "Node_preRoundCard")
    Node_preRoundCard:setVisible(false)
    self.NodePlayerMyself:setVisible(false)
     local Img_zhu = gt.seekNodeByName(self.rootNode, "Img_zhu")
    Img_zhu:setVisible(false)
    local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
    Btn_chupai:setTouchEnabled(false)
    Btn_chupai:setBright(false)

    self.timeNumber = 0

    local Node_maidi = gt.seekNodeByName(self.rootNode, "Node_maidi")

    self:findNodeByName("DelayTime_node"):stopAllActions()
    
    local maidi_clock = gt.seekNodeByName(Node_maidi, "Img_clock")

    maidi_clock:stopAllActions() maidi_clock:setRotation(0)
	for i = 1, 5 do
		local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
        local jiaofen =  gt.seekNodeByName(playerNode, "Img_score")
        local Img_banker =  gt.seekNodeByName(playerNode, "Img_banker")
        local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
        local Img_liaotian =  gt.seekNodeByName(playerNode, "Img_liaotian")
        local Img_ready =  gt.seekNodeByName(playerNode, "Img_ready")
        local Node_banker =  gt.seekNodeByName(playerNode, "Node_banker")
        local Img_fuzhuang =  gt.seekNodeByName(playerNode, "Img_fuzhuang")
       -- local Img_offline =  gt.seekNodeByName(playerNode, "Img_offline")
        local Node_preCard =  gt.seekNodeByName(Node_preRoundCard, "Node_preCard" .. i)


        local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
        
        gt.soundEngine:stopEffect(self._soundid) Img_clock:stopAllActions() Img_clock:setRotation(0) 

        Node_preCard:removeAllChildren()

        for j = 1 , 10 do 

            if self.gz_card[i][j] and  not tolua.isnull(self.gz_card[i][j]) and self._node then
                self.gz_card[i][j]:removeFromParent()

            end
            self.gz_card[i][j] = nil
        end

       

        if jiaofen then
            jiaofen:setVisible(false)
        end
        if Img_banker then
            Img_banker:setVisible(false)
            Img_banker:setPosition(cc.p(35, 55))
        end
        if Img_clock then
            Img_clock:setVisible(false)
        end
        if Img_liaotian then
            Img_liaotian:setVisible(false)
        end
        if Img_ready and not bool then
            Img_ready:setVisible(false)
        end
        if Node_banker then
            Node_banker:removeAllChildren()
        end
        if Img_fuzhuang then
            Img_fuzhuang:setVisible(false)
        end
        -- if Img_offline then
        --     Img_offline:setVisible(false)
        -- end
	end
    self.preRoundCards = nil
    self.preRoundCards = {}
    self.curRoundCards = nil
    self.curRoundCards = {}
    -- 移除所有麻将
	self.playMjLayer:removeAllChildren()
    local Node_scoreCards = gt.seekNodeByName(self.rootNode, "Node_scoreCards")
    Node_scoreCards:removeAllChildren()
    for i = 1, 5 do
		local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
        local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
        Img_clock:setVisible(false)
        local Node_outCard =  gt.seekNodeByName(playerNode, "Node_outCard")
        Node_outCard:removeAllChildren()
	end
    --移除解散房间
    local Node_ReleseDesk1 = gt.seekNodeByName(self.rootNode, "Node_ReleseDesk1")
    local Node_ReleseDesk2 = gt.seekNodeByName(self.rootNode, "Node_ReleseDesk2")
    Node_ReleseDesk1:removeAllChildren()
    Node_ReleseDesk1:removeAllChildren()

    --隐藏埋底
    local Node_maidi = gt.seekNodeByName(self.rootNode, "Node_maidi")
    Node_maidi:setVisible(false)
    --隐藏105
    local Node_105ReleaseDesk = gt.seekNodeByName(self.rootNode, "Node_105ReleaseDesk")
    Node_105ReleaseDesk:setVisible(false)
    local Text_status = gt.seekNodeByName(Node_105ReleaseDesk, "Text_status")
    Text_status:setString("同意结束人数 0/5")
    local Btn_jieshu = gt.seekNodeByName(Node_105ReleaseDesk, "Btn_jieshu")
    local Btn_jixu = gt.seekNodeByName(Node_105ReleaseDesk, "Btn_jixu")
    gt.log("设置按钮状态")
    Btn_jieshu:setTouchEnabled(true)
    Btn_jieshu:setBright(true)
    Btn_jixu:setTouchEnabled(true)
    Btn_jixu:setBright(true)

    --出牌按钮
    local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
    Btn_chupai:setVisible(false)

    --叫分按钮
    if self.Btn_bujiao then
        self.Btn_bujiao:setTouchEnabled(true)
        self.Btn_bujiao:setBright(true)
    end
    if self.Btn_70 then
        self.Btn_70:setTouchEnabled(true)
        self.Btn_70:setBright(true)
    end
    if self.Btn_75 then
        self.Btn_75:setTouchEnabled(true)
        self.Btn_75:setBright(true)
    end
    if self.Btn_80 then
        self.Btn_80:setTouchEnabled(true)
        self.Btn_80:setBright(true)
    end
    if self.Btn_85 then
        self.Btn_85:setTouchEnabled(true)
        self.Btn_85:setBright(true)
    end
    if self.Btn_90 then
        self.Btn_90:setTouchEnabled(true)
        self.Btn_90:setBright(true)
    end
    if self.Btn_95 then
        self.Btn_95:setTouchEnabled(true)
        self.Btn_95:setBright(true)
    end
    if self.Btn_100 then
        self.Btn_100:setTouchEnabled(true)
        self.Btn_100:setBright(true)
    end
    --选庄的牌
    if #self.xuanZhuangBtn then
        for i=1, #self.xuanZhuangBtn do
             self.xuanZhuangBtn[i]:setColor(cc.WHITE)
		self.xuanZhuangBtn[i]:removeAllChildren()
        end
    end
    local Node_xuanzhuang = gt.seekNodeByName(self.rootNode, "Node_xuanzhuang")
    local Img_select = gt.seekNodeByName(Node_xuanzhuang, "Img_select")
    Img_select:setVisible(false)
    local Text_xuanZhuangDesc = gt.seekNodeByName(Node_xuanzhuang, "Text_xuanZhuangDesc")
    Text_xuanZhuangDesc:setVisible(false)

    --主牌图标
    local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
    local Image_zhupai = gt.seekNodeByName(Node_leftInfo, "Image_zhupai")
    local Img_duijia = gt.seekNodeByName(Node_leftInfo, "Img_duijia")
    self.Text_score  = gt.seekNodeByName(Node_leftInfo, "Text_score")
    self.Text_yufen = gt.seekNodeByName(Node_leftInfo, "Text_yufen")
    local Text_maxjiaofen = gt.seekNodeByName(Node_leftInfo, "Text_maxjiaofen")
    Image_zhupai:setVisible(false)
    Img_duijia:setVisible(false) 
    self.Text_score:setString("0")
    self.Text_yufen:setString("100")
    Text_maxjiaofen:setString("0")
    --描述文字
    local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
    Text_desc:setVisible(false)
    
    local Btn_dipai = gt.seekNodeByName(self.rootNode, "Btn_dipai")
    Btn_dipai:setVisible(false)
    self.holdCards = {}
    self:stopAllActions()

end

-- start --
--------------------------------
-- @class function
-- @description 玩家准备手势
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:RcvReady(msgTbl)
	gt.log("收到玩家准备手势消息 ================ ")
	dump(msgTbl)
    
    if  not msgTbl then return end
    self.isGameOver = 0

	local seatIdx = msgTbl.kPos + 1
    
    if msgTbl.kPos == self.UsePos then 
        self:removeChildByName("__XIAOJIESUAN__")
        self:resetScene(true)
    end

    self.tmp_ready[seatIdx] = msgTbl

	self:playerGetReady(seatIdx)

    local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
    if Node_leftInfo then
        self.Text_score  = gt.seekNodeByName(Node_leftInfo, "Text_score")
        self.Text_score:setString("0")
    end
    local Node_scoreCards = gt.seekNodeByName(self.rootNode, "Node_scoreCards")
    if Node_scoreCards then
        Node_scoreCards:removeAllChildren()
    end
    for i = 1, 5 do
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
        --隐藏时钟
        local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
        Img_clock:setVisible(false)
	end
end

function PlaySceneWuRen:checkColor(card)
    if self.isChangZhu then
        if card >= 78 or card == 2 or card == 18 or card == 34 or card == 50 then
            --大小王和四个2
            return PlaySceneWuRen.ColorType.KING
        elseif card >= 49 and card <= 61 then
            --黑桃
            return PlaySceneWuRen.ColorType.HEITAO
        elseif card >= 33 and card <= 45 then
            --红桃
            return PlaySceneWuRen.ColorType.HONGTAO
        elseif card >= 17 and card <= 29 then
            --梅花
            return PlaySceneWuRen.ColorType.MEIHUA
        elseif card >= 1 and card <= 13 then
            --方片
            return PlaySceneWuRen.ColorType.FANGPIAN
        end
    else
        if card >= 78 then
            --大小王
            return PlaySceneWuRen.ColorType.KING
        elseif card >= 49 and card <= 61 then
            --黑桃
            return PlaySceneWuRen.ColorType.HEITAO
        elseif card >= 33 and card <= 45 then
            --红桃
            return PlaySceneWuRen.ColorType.HONGTAO
        elseif card >= 17 and card <= 29 then
            --梅花
            return PlaySceneWuRen.ColorType.MEIHUA
        elseif card >= 1 and card <= 13 then
            --方片
            return PlaySceneWuRen.ColorType.FANGPIAN
        end
    end
end

function PlaySceneWuRen:checkColors(card)

      if card >= 78 then
            --大小王
            return PlaySceneWuRen.ColorType.KING
        elseif card >= 49 and card <= 61 then
            --黑桃
            return PlaySceneWuRen.ColorType.HEITAO
        elseif card >= 33 and card <= 45 then
            --红桃
            return PlaySceneWuRen.ColorType.HONGTAO
        elseif card >= 17 and card <= 29 then
            --梅花
            return PlaySceneWuRen.ColorType.MEIHUA
        elseif card >= 1 and card <= 13 then
            --方片
            return PlaySceneWuRen.ColorType.FANGPIAN
        end

end
-- 检测手牌能出什牌
function PlaySceneWuRen:checkHolds()
    gt.log("检查出牌")
    local color = self:checkColor(self.roundFirstCard)
    local notTouchHands = {}
    -- 第一个人出的是主牌
    if self.MainColor == color or color == self.ColorType.KING then
        --是否有主牌
        local isHaveMainCard = false
        for i=1, #self.holdCardsNum do
            local handColor = self:checkColor(self.holdCardsNum[i])
            if handColor == self.MainColor or handColor == self.ColorType.KING then
                isHaveMainCard = true
                break
            end
        end
        --手上有主牌,存储不是主牌的牌
        if isHaveMainCard then
            for i=1, #self.holdCardsNum do
                local handColor = self:checkColor(self.holdCardsNum[i])
                if handColor ~= self.MainColor and handColor ~= self.ColorType.KING then
                    table.insert(notTouchHands, self.holdCardsNum[i])
                end
            end
        else
            -- 手上没有主牌了,都可出
        end
    else
        -- 第一个人出的是副牌
        -- 手上是否有这个花色的副牌
        local isHaveFuCard = false
        for i=1, #self.holdCardsNum do
            local handColor = self:checkColor(self.holdCardsNum[i])
            if handColor == color then
                isHaveFuCard = true
                break
            end
        end
        --手上有这个花色的副牌,存储不是这个花色的所有牌
        if isHaveFuCard then
            for i=1, #self.holdCardsNum do
                local handColor = self:checkColor(self.holdCardsNum[i])
                if handColor ~= color then
                    table.insert(notTouchHands, self.holdCardsNum[i])
                end
            end
        else
            -- 手上没有这个花色的副牌牌了,都可出
        end
    end
    return notTouchHands
end

-- start --
--------------------------------
-- @class function
-- @description 断线重连
-- end --
function PlaySceneWuRen:onRcvSyncRoomState(msgTbl)
	gt.log("收到断线重连消息 ================ ")
	dump(msgTbl)
end

-- start --
--------------------------------
-- @class function
-- @description 玩家在线标识
-- @param msgTbl 消息体
-- end --
function PlaySceneWuRen:off_line(msgTbl)
	gt.log("收到玩家在线标识消息 =============== ")
    dump(msgTbl)
    
      --玩家在入座时，在线离线数据没有及时更新
      if self.tmp_player and self.tmp_player ~= {} then
        if msgTbl.kFlag == 1 then
            self.tmp_player[msgTbl.kPos].kOnline = true
        else
            self.tmp_player[msgTbl.kPos].kOnline = false
        end
    end

    if msgTbl.kPos == self.playerSeatIdx-1 then
	    gt.removeLoadingTips()
    end
    local displaySeatIdx = (msgTbl.kPos + self.seatOffset) % 5 + 1
	local Node_player = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
    local Img_offline = gt.seekNodeByName(Node_player, "Img_offline")
    if msgTbl.kFlag == 1 then
        Img_offline:setVisible(false)
    else
        Img_offline:setVisible(true)
    end
end

function PlaySceneWuRen:showPreRoundCards()
    gt.log("显示上轮牌")

    if #self.preRoundCards == 5 then
        if self.preRoundCards[1] == 0 and self.preRoundCards[2] == 0 and self.preRoundCards[3] == 0 and self.preRoundCards[4] == 0 and self.preRoundCards[5] == 0 then
            self.preRoundCards = nil
            self.preRoundCards = {}
        end
    end
    if not self.preRoundCards then
        return
    end 
    local Node_preRoundCard = gt.seekNodeByName(self.rootNode, "Node_preRoundCard")
    Node_preRoundCard:setVisible(false)
    if #self.preRoundCards > 0 then
        Node_preRoundCard:setVisible(true)
        for i=1, 5 do 
            local displaySeatIdx = (i - 1 + self.seatOffset) % 5 + 1
	        local Node_preCard = gt.seekNodeByName(Node_preRoundCard, "Node_preCard" .. displaySeatIdx)
            Node_preCard:removeAllChildren()
        end 
        for i=1, 5 do 
            if self.preRoundCards[i] > 0 then
                local displaySeatIdx = (i - 1 + self.seatOffset) % 5 + 1
	            local Node_preCard = gt.seekNodeByName(Node_preRoundCard, "Node_preCard" .. displaySeatIdx)
                local card = ccui.ImageView:create()
	            card:loadTexture("res/sd/pk/" .. self.preRoundCards[i] .. ".png")
                Node_preCard:addChild(card)
                card:setScale(0.6)
            end
        end
        --[[
		self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function()
            if not self.curRoundCards then
                return
            end 
            for i=1, 5 do 
                local displaySeatIdx = (i - 1 + self.seatOffset) % 5 + 1
	            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
                local outCard = gt.seekNodeByName(playerNode, "Node_outCard")
                outCard:removeAllChildren()
            end 
            for i=1, 5 do 
                if self.curRoundCards[i] > 0 then
                    local displaySeatIdx = (i - 1 + self.seatOffset) % 5 + 1
	                local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
                    local outCard = gt.seekNodeByName(playerNode, "Node_outCard")
                    outCard:removeAllChildren()
                    local card = ccui.ImageView:create()
	                card:loadTexture("res/sd/pk/" .. self.curRoundCards[i] .. ".png")
                    outCard:addChild(card)
                    card:setScale(0.6)
                end
            end 
        end)))]]--
    end
end

function PlaySceneWuRen:onRcv105Score(msgTbl)
    gt.log("收到得分超过105消息")
    dump(msgTbl)
    
    gt.soundEngine:playEffect("pkdesk/po")

	local displaySeatIdx = (self.curBigpos + self.seatOffset) % 5 + 1
	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
    
    local Node_action = gt.seekNodeByName(playerNode, "Node_action")
    local poNode, poAnime = gt.createCSAnimation("poAction.csb")
    Node_action:stopAllActions()
    Node_action:removeAllChildren()
    Node_action:addChild(poNode)
    poAnime:gotoFrameAndPlay(0, false)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function(sender)
        Node_action:stopAllActions()
        Node_action:removeAllChildren()
    end)))
    -- local Node_105ReleaseDesk = gt.seekNodeByName(self.rootNode, "Node_105ReleaseDesk")
    -- Node_105ReleaseDesk:setVisible(self.is_sit)
    -- self.release105Time = 15
    
--     local Text_105 = gt.seekNodeByName(Node_105ReleaseDesk, "Text_105")
--     Text_105:setString("闲家得分" ..(msgTbl.kScore - self.MaxSelectScore) .. ",已破牌,是否提前结束本局?")
    
--     local Btn_jieshu = gt.seekNodeByName(Node_105ReleaseDesk, "Btn_jieshu")
--     local Btn_jixu = gt.seekNodeByName(Node_105ReleaseDesk, "Btn_jixu")
--     gt.log("设置按钮状态11111")
--     Btn_jieshu:setTouchEnabled(true)
--     Btn_jieshu:setBright(true)
--     Btn_jixu:setTouchEnabled(true)
--     Btn_jixu:setBright(true)
end

function PlaySceneWuRen:onRcvScoreResult(msgTbl)
--     gt.log("收到105玩家选择状态")
--     dump(msgTbl)
--     local Node_105ReleaseDesk = gt.seekNodeByName(self.rootNode, "Node_105ReleaseDesk")
--     local Text_status = gt.seekNodeByName(Node_105ReleaseDesk, "Text_status")
    
--     local Btn_jieshu = gt.seekNodeByName(Node_105ReleaseDesk, "Btn_jieshu")
--     local Btn_jixu = gt.seekNodeByName(Node_105ReleaseDesk, "Btn_jixu")

--     local count = 0
--     local isJixu = false
--     for i=1, 5 do
--         if msgTbl.kAgree[i] > 0 then
--             count = count + 1
--         end
--         if msgTbl.kAgree[i] == 0  then
--             isJixu = true
--             break
--         end
--         if msgTbl.kAgree[i] ~= -1 and i == self.playerSeatIdx  then
--             --隐藏按钮
--             Btn_jieshu:setTouchEnabled(false)
--             Btn_jieshu:setBright(false)
--             Btn_jixu:setTouchEnabled(false)
--             Btn_jixu:setBright(false)
--         end
--     end
--     Text_status:setString("同意结束人数 " .. count .."/5")
--     if isJixu then
--         Node_105ReleaseDesk:setVisible(false)
--         self.release105Time = -1
--         self.timeNumber = 10
--          Toast.showToast(self,"有玩家拒绝提前结束游戏，请继续游戏",2)
--     end
end

--断线重连
function PlaySceneWuRen:onRcvReconect(msgTbl)
    gt.log("收到断线重连数据消息---playSceneWuRen---")
    self.first_game = false
    self.p_g:setVisible(false)
    self.isGameOver = 0
    self.sit_btn:setVisible(false)
    
    self:resetScene()

    if self:getChildByName("__XIAOJIESUAN__") then self:removeChildByName("__XIAOJIESUAN__") end
    
    if self.UsePos == 5 or self.UsePos == 21 then 
        self.playerSeatIdx = 1
        self.seatOffset = 5
    end

    self.Btn_friend:setVisible(false)
    self.Btn_ready:setVisible(false)

    self.is_sit = (self.UsePos <=4 and self.UsePos >=0)

    self:findNodeByName( "Btn_chat" ):setVisible(self.is_sit )
    self:findNodeByName( "voice" ):setVisible(self.is_sit )

    -- self:findNodeByName( "Btn_chat" ):setVisible(self.is_sit and self.data.kPlaytype[5]==0)
    -- self:findNodeByName( "voice" ):setVisible(self.is_sit and self.data.kPlaytype[5]==0)
    if self.data.kPlaytype[5]==1 then
        -- self:findNodeByName( "Btn_chat" ):setTouchEnabled(false)
        self:findNodeByName( "Btn_chat" ):setBright(false)
        -- self:findNodeByName( "voice" ):setTouchEnabled(false)
        self:findNodeByName( "voice" ):setBright(false)
    end

 


    local NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_player1")
    gt.seekNodeByName(NodePlayerMyself, "Layer_handCards"):setVisible(self.is_sit)


    -- dump(msgTbl)
    self.MaxSelectScore = msgTbl.kMaxselectscore
    --防作弊房间
    local Text_fangzhubi = gt.seekNodeByName(self.rootNode, "Text_fangzhubi")
    Text_fangzhubi:setVisible(false)
     --隐藏玩家准备手势
    for i = 1, 5 do
	     local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i )
	     local readySignSpr = gt.seekNodeByName(playerNode, "Img_ready")
	     readySignSpr:setVisible(false)
    end
    gt.log("---msgTbl.kState---")
    gt.log(msgTbl.kState)
    if msgTbl.kState == 2  then -- 叫分
        -- if  self.is_sit then 
            local msgTb = {}
    	    msgTb.kNextSelectScorePos = msgTbl.kCurPos
    	    msgTb.kIs2ChangZhu = 0
            msgTb.kHandCardsCount = msgTbl.kHandCardCount
            msgTb.kHandCards = msgTbl.kHandCards
            msgTb.kPos = msgTbl.kPos

            self:onRcvCards(msgTb,true)
        -- end
        --         --显示叫的分数
        for i=1, #msgTbl.kScore do
            local displaySeatIdx = ((i-1) + self.seatOffset) % 5 + 1
            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
            local Img_score =  gt.seekNodeByName(playerNode, "Img_score")
            local Text_jiaofen =  gt.seekNodeByName(playerNode, "Text_jiaofen")
            Img_score:setVisible(false)
            if msgTbl.kScore[i] ~= -1 then
                gt.log("add_score_____________")
                Img_score:setVisible(true)
                if msgTbl.kScore[i] == 0 then
                    Text_jiaofen:setString("不叫")
                else
                    Text_jiaofen:setString(tostring(msgTbl.kScore[i]))
                end
            end
        end

        
    elseif msgTbl.kState == 3 then -- 选主
        gt.log("------bbb-----")
        gt.log(msgTbl.kJiaoPaiState)
        gt.log(msgTbl.kTimeJiaoPaiRequest)
        local msgTb = {}
        self.zhuangPos = msgTbl.kZhuang
        msgTb.kZhuangPos = msgTbl.kZhuang
        local basecard = {}
        msgTb.kMaxSelectScore = msgTbl.kMaxselectscore
        self.holdCardsNum = nil
        self.holdCardsNum = {}
        for i=1, msgTbl.kHandCardCount do
            table.insert(self.holdCardsNum, msgTbl.kHandCards[i])
        end

        for i = 11, 14 do
            if msgTbl.kHandCards[i] > 0 then
                table.insert(basecard, msgTbl.kHandCards[i])
            end
        end

        if msgTbl.kJiaoPaiState == 0 then --默认 闲家应该显示--等待庄家选择是否交牌
            self.jiaoPaiOneVisible = 0
            if msgTbl.kTimeJiaoPaiRequest - 1 <= 0 then
                self.timeJiaopai_rec = 0
            else
                self.timeJiaopai_rec = msgTbl.kTimeJiaoPaiRequest - 1  --庄家时间-倒计时
            end 
        elseif msgTbl.kJiaoPaiState == 1 then --庄家已申请  庄家-提示等待闲家 选择  闲家-提示jiaopai2 并且倒计时
            self.jiaoPaiOneVisible = 1
            if msgTbl.kTimeJiaoPaiRespone - 1 <= 0 then
                self.timeJiaopai = 0
            else
                self.timeJiaopai = msgTbl.kTimeJiaoPaiRespone - 1  --庄家申请后，闲家退出后重进的时间。
            end
        elseif msgTbl.kJiaoPaiState == 2 then --已完成，所有人同意
            self.jiaoPaiOneVisible = 2
        elseif msgTbl.kJiaoPaiState == 3 then --申请超时
            self.jiaoPaiOneVisible = 3
        elseif msgTbl.kJiaoPaiState == 4 then --闲家已拒绝
            self.jiaoPaiOneVisible = 4
        elseif msgTbl.kJiaoPaiState == 5 then --结束状态
            self.jiaoPaiOneVisible = 5
        elseif msgTbl.kJiaoPaiState == 6 then -- 交牌结束 -- 选庄
            self.jiaoPaiOneVisible = 6
        end

        gt.log("-----#basecard========--")
        gt.dump(basecard)

        if self.zhuangPos ~= self.UsePos then 
            local displaySeatIdx = (self.zhuangPos + self.seatOffset) % 5 + 1
            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
            local outcard = gt.seekNodeByName(playerNode, "Node_outCard")
            if outcard:getChildByName("__xipai__") then
                outcard:removeChildByName("__xipai__")
            end
            local xipaiNode, xipaiAnime = gt.createCSAnimation("runAction/mai_run.csb")
            outcard:addChild(xipaiNode)
            xipaiNode:setName("__xipai__")
            local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
            Text_desc:setVisible(true)
            Text_desc:setString("等待庄家定主")
            if displaySeatIdx == 3 or displaySeatIdx == 4 then
                xipaiNode:setPosition(cc.p(0,20))
            elseif displaySeatIdx == 2 then 
                xipaiNode:setPosition(cc.p(-60,20))
            elseif displaySeatIdx == 5 then 
                xipaiNode:setPosition(cc.p(80,20))
            elseif  displaySeatIdx == 1 then 
                xipaiNode:setPosition(cc.p(0,10))
            end
            xipaiAnime:gotoFrameAndPlay(0, true)

            self.timeNumber = 15
            for i = 1, 5 do
                local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)  --显示时钟
                local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
                if displaySeatIdx == i then
                    Img_clock:setVisible(true)
                else
                    Img_clock:setVisible(false)
                end
            end
            

        end

        if #basecard > 0 then
            msgTb.kBaseCards = basecard
            msgTb.kBaseCardsCount = 4
            msgTb.kHandCards = msgTbl.kHandCards
            self:onRcvLastCard(msgTb)
            gt.log("c______________")
        else
            gt.log("b______________",self.MainColor)
            self.holdCardsNum = self:sortCards(self.holdCardsNum, self.MainColor)
    
            local NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_player1")
            local Layer_handCards = gt.seekNodeByName(NodePlayerMyself, "Layer_handCards")
            Layer_handCards:removeAllChildren()
            local size = Layer_handCards:getContentSize()
            local startposX = size.width/2 - #self.holdCardsNum/2 * 60
            local posY = size.height/2
            self.holdCards = nil
            self.holdCards = {}
            for i = 1, #self.holdCardsNum do
                if Layer_handCards then
                 local card = ccui.ImageView:create()
                 card:loadTexture("res/sd/pk/" .. self.holdCardsNum[i] .. ".png")
                    Layer_handCards:addChild(card)
                    card:setPosition(cc.p(startposX + i*60, posY))
                    card:setTag(self.holdCardsNum[i])
 	        	    table.insert(self.holdCards, card)
                end
            end
            -- 需要 状态。。
            
            if not (self.isJiaoPai == 0) then
                local jiaoAgree = msgTbl.kJiaoPaiAgreeStatus
                self:chongLianXianJia(self.jiaoPaiOneVisible, jiaoAgree, msgTbl.kPos, msgTbl.kZhuang, msgTbl.kTimeJiaoPaiRespone) --处理 闲家 问题
            end
        end

    elseif msgTbl.kState == 4 then -- 埋底
        self.isCanTouch = true
        self.zhuangPos = msgTbl.kZhuang
        local msgTb = {}
        msgTb.kSelectMainColor = msgTbl.kMainColor
        self.holdCardsNum = nil
        self.holdCardsNum = {}
        for i=1, #msgTbl.kHandCards do
            table.insert(self.holdCardsNum, msgTbl.kHandCards[i])
        end
 	    self.tmp_maidi_card = {}
        for i = 1, 4  do 
            table.insert(self.tmp_maidi_card, msgTbl.kBaseCards[i])
        end
        self:onRcvSelectMain(msgTb)
        if self.zhuangPos ~= self.UsePos then 
        local displaySeatIdx = (self.zhuangPos + self.seatOffset) % 5 + 1
    
        local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
        local outcard = gt.seekNodeByName(playerNode, "Node_outCard")
        if outcard:getChildByName("__xipai__") then
            outcard:removeChildByName("__xipai__")
        end
        local xipaiNode, xipaiAnime = gt.createCSAnimation("runAction/mai_run.csb")
        outcard:addChild(xipaiNode)
        xipaiNode:setName("__xipai__")
        local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
        Text_desc:setVisible(true)
        Text_desc:setString("等待庄家埋底")
        if displaySeatIdx == 3 or displaySeatIdx == 4 then
            xipaiNode:setPosition(cc.p(0,20))
        elseif displaySeatIdx == 2 then 
            xipaiNode:setPosition(cc.p(-60,20))
        elseif displaySeatIdx == 5 then 
            xipaiNode:setPosition(cc.p(80,20))
        elseif  displaySeatIdx == 1 then 
            xipaiNode:setPosition(cc.p(0,10))
        end
        xipaiAnime:gotoFrameAndPlay(0, true)
              
        end
    elseif msgTbl.kState == 5 then -- 选庄
        self.isCanTouch = true
        self.zhuangPos = msgTbl.kZhuang
        self.MainColor = msgTbl.kMainColor

        self.holdCardsNum = nil
        self.holdCardsNum = {}

        for i=1, msgTbl.kHandCardCount do
            table.insert(self.holdCardsNum, msgTbl.kHandCards[i])
        end
        self.holdCardsNum = self:sortCards(self.holdCardsNum, self.MainColor)
    
        local NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_player1")
        local Layer_handCards = gt.seekNodeByName(NodePlayerMyself, "Layer_handCards")
        Layer_handCards:removeAllChildren()
        local size = Layer_handCards:getContentSize()
        local startposX = size.width/2 - #self.holdCardsNum/2 * p_idx
        local posY = size.height/2
        self.holdCards = nil
        self.holdCards = {}
        for i = 1, #self.holdCardsNum do
            if Layer_handCards then
             local card = ccui.ImageView:create()
             card:loadTexture("res/sd/pk/" .. self.holdCardsNum[i] .. ".png")
                Layer_handCards:addChild(card)
                card:setPosition(cc.p(startposX + i*p_idx, posY))
                card:setTag(self.holdCardsNum[i])
 	    	    table.insert(self.holdCards, card)
                if self:checkColor(self.holdCardsNum[i]) == self.MainColor or self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.KING then
                     local star = ccui.ImageView:create()
                     star:loadTexture("res/sd/desk/star.png")
                     card:addChild(star)
                     star:setPosition(cc.p(25, 30))
		     if self.isChangZhu and self:is_changzhu(self.holdCardsNum[i] )then 
                        local star = ccui.ImageView:create()
                        star:loadTexture("res/sd/desk/star.png")
                        card:addChild(star)
                        star:setPosition(cc.p(25, 60))
                    end
                end
            end
        end

        local msgTb = {}
        msgTb.kHandCardsCount = msgTbl.kHandCardCount
        msgTb.kHandCards = msgTbl.kHandCards
        self:onRcvBaseCard(msgTb)
	    self.isMaiDi = true
    elseif msgTbl.kState == 6 then -- 出牌
	    self.isMaiDi = false
        self.isCanTouch = true
        self.zhuangPos = msgTbl.kZhuang
        self.MainColor = msgTbl.kMainColor
        self.turnPos = msgTbl.kCurPos
        self.timeNumber = 15
        
        self.holdCardsNum = nil
        self.holdCardsNum = {}

        for i=1, msgTbl.kHandCardCount do
            table.insert(self.holdCardsNum, msgTbl.kHandCards[i])
        end
        self.holdCardsNum = self:sortCards(self.holdCardsNum, self.MainColor)
    
        local NodePlayerMyself = gt.seekNodeByName(self.rootNode, "Node_player1")
        local Layer_handCards = gt.seekNodeByName(NodePlayerMyself, "Layer_handCards")
        Layer_handCards:removeAllChildren()
        local size = Layer_handCards:getContentSize()
        local startposX = size.width/2 - #self.holdCardsNum/2 * p_idx
        local posY = size.height/2
        self.holdCards = nil
        self.holdCards = {}
        for i = 1, #self.holdCardsNum do
            if Layer_handCards then
             local card = ccui.ImageView:create()
             card:loadTexture("res/sd/pk/" .. self.holdCardsNum[i] .. ".png")
                Layer_handCards:addChild(card)
                card:setPosition(cc.p(startposX + i*p_idx, posY))
                card:setTag(self.holdCardsNum[i])
 	    	    table.insert(self.holdCards, card)
                if self:checkColor(self.holdCardsNum[i]) == self.MainColor or self:checkColor(self.holdCardsNum[i]) == PlaySceneWuRen.ColorType.KING then
                     local star = ccui.ImageView:create()
                     star:loadTexture("res/sd/desk/star.png")
                     card:addChild(star)
                     star:setPosition(cc.p(25, 30))
		     gt.log("self.holdCardsNum[i]...",self.holdCardsNum[i])
                     if self.isChangZhu and self:is_changzhu(self.holdCardsNum[i] ) then 
                        local star = ccui.ImageView:create()
                        star:loadTexture("res/sd/desk/star.png")
                        card:addChild(star)
                        star:setPosition(cc.p(25, 60))
                    end
                 end
            end
        end
        
        for i = 1, 5 do
		    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
            --显示时钟
            local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")
            if ((self.turnPos + self.seatOffset) % 5 + 1) == i then
                Img_clock:setVisible(true)
            else
                Img_clock:setVisible(false)
            end
	    end
        self.curRoundCards = msgTbl.kOutCard
        self.preRoundCards = msgTbl.kPrevOutCard
        for i=1, 5 do 
            if self.curRoundCards[i] > 0 then
                local displaySeatIdx = (i - 1 + self.seatOffset) % 5 + 1
	            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. displaySeatIdx)
                local outCard = gt.seekNodeByName(playerNode, "Node_outCard")
                local card = ccui.ImageView:create()
	            card:loadTexture("res/sd/pk/" .. self.curRoundCards[i] .. ".png")
                outCard:addChild(card)
                card:setScale(0.5)

                if msgTbl.kCurrBig == i-1 and not tolua.isnull(card) then
                    local max = ccui.ImageView:create()
                    max:loadTexture("res/sd/desk/max.png")
                    card:addChild(max)
                    max:setPosition(cc.p(122, 28))
                end

            end
        end 
        --出过的分牌
        local Node_scoreCards = gt.seekNodeByName(self.rootNode, "Node_scoreCards")
        if Node_scoreCards then
            Node_scoreCards:removeAllChildren()
            for i = 1, #msgTbl.kScoreCards do
                if msgTbl.kScoreCards[i] > 0 then
	                local card = ccui.ImageView:create()
	                card:loadTexture("res/sd/pk/" .. msgTbl.kScoreCards[i] .. ".png")
                    Node_scoreCards:addChild(card)
                    if i > 6 then
                        card:setPosition(cc.p((i-7)*165, -230))
                    else
                        card:setPosition(cc.p((i-1)*165, 0))
                    end
                end
            end
        end
        self.roundFirstCard = msgTbl.kOutCard[msgTbl.kFirstPos+1]
        --如果下一个出牌的人是我自己,显示出牌按钮
        local Btn_chupai = gt.seekNodeByName(self.rootNode, "Btn_chupai")
        if self.turnPos == self.playerSeatIdx - 1 then
            Btn_chupai:setVisible(self.is_sit)
            Btn_chupai:setTouchEnabled(false)
            Btn_chupai:setBright(false)
            -- 出牌的时候检测能出哪些牌,不能出的牌置灰
            if msgTbl.kFirstPos < 5 and msgTbl.kOutCard[msgTbl.kFirstPos+1] > 0  then
                local notHandCards = self:checkHolds()
                for i=1, #self.holdCards do
                    for j=1, #notHandCards do
                        if self.holdCards[i]:getTag() == notHandCards[j] then
                            self.holdCards[i]:setColor(cc.c3b(200,200,200))
                        end
                    end
                end
            end
        
        else
            Btn_chupai:setVisible(false)
        end
        
        --副庄家的牌
        local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
        local Img_duijia = gt.seekNodeByName(Node_leftInfo, "Img_duijia")
	    Img_duijia:loadTexture("res/sd/pkSmall/" .. msgTbl.kFuzhuangCard .. ".png")
        Img_duijia:setVisible(true)
    end





    local look = 0 -- 0 
    if msgTbl.kHandCards[1] == 0 then 
        self.is_sit = false
        look = 1 
        local data = msgTbl["kClubAllHandCards"..1-1]
        if data[1] ~= 0 then 
            look = 2
        end
    else
        self.is_sit = true
    end
    self.gameBegin = look == 0
    gt.log("off_____________",msgTbl.kMainColor,msgTbl.kState)

    if look ~= 0 then 
        local main =  ( msgTbl.kState == 2 or msgTbl.kState == 3 ) and   PlaySceneWuRen.ColorType.HEITAO or msgTbl.kMainColor 
        for i = 1 , 5  do
            local node = self:findNodeByName("Image_"..i)
            local card = {} if look == 2 then  card = self:sortCards(msgTbl[ "kClubAllHandCards"..(i-1)],main) end
            for j = 1 , msgTbl.kHandCardsCountArr[i] do
                local p = i == 1 and  p_idx or 21
                p = i == 2 and -p or p
                local z = i == 2 and (11-j) or j 
                local n = node:clone()
                n:setVisible(true)
                n:setPositionX(node:getPositionX() - 15 + (j-1)*p )
                self:findNodeByName("FileNode"):addChild(n)
                n:setLocalZOrder(z)
                if look == 2 then 
                    n:loadTexture("res/sd/pk/" ..  card[j] .. ".png")
                    n:setTag(1000+tonumber(card[j]))
                    if msgTbl.kState == 5 or msgTbl.kState == 6 or msgTbl.kState == 4  then 
                        if self:checkColor(card[j]) == main then
                            local star = ccui.ImageView:create()
                            star:loadTexture("res/sd/desk/star.png")
                            n:addChild(star)
                            star:setPosition(cc.p(25, 30))
			            if self.isChangZhu and self:is_changzhu(card[j]) then 
                                local star = ccui.ImageView:create()
                                star:loadTexture("res/sd/desk/star.png")
                                card:addChild(star)
                                star:setPosition(cc.p(25, 60))
                            end
                        end
                    end
                else
                    n:setTag(0)
                    n:loadTexture("sd/pk/lord_card_selected.png")
                end
               
                self.gz_card[i][j] = n
            end
        end

        local index = msgTbl.kHandCardsCountArr[1]
        if index > 0 and index ~= 10 then
            for j = 1 , index do
                local node = self.gz_card[1][j]
                if node then node:setPositionX(node:getPositionX()+44*(10-index)) end
            end
        end

    end

     --庄显示
     if msgTbl.kState > 2 then
          local displaySeatIdx = (self.zhuangPos + self.seatOffset) % 5 + 1
          for i = 1, 5 do
	         	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
             
              local Img_banker = gt.seekNodeByName(playerNode, "Img_banker")
              if Img_banker then
                  if displaySeatIdx == i then
                      Img_banker:setVisible(true)
                  else
                      Img_banker:setVisible(false)
                  end
              end
          end
     end
    --副庄是自己显示
    if msgTbl.kFuzhuangPos == self.playerSeatIdx - 1 then
        local playerNodemyself = gt.seekNodeByName(self.rootNode, "Node_player1")
        local Img_fuzhuang =  gt.seekNodeByName(playerNodemyself, "Img_fuzhuang")
        Img_fuzhuang:setVisible(true)
        if self.zhuangPos == msgTbl.kFuzhuangPos then
            local Img_banker =  gt.seekNodeByName(playerNodemyself, "Img_banker")
            Img_banker:setPosition(cc.p(-5, 55))
        end
    end

    if not self.is_sit then 
       
         for i = 1, 5 do
            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
            
            local Img_fuzhuang =  gt.seekNodeByName(playerNode, "Img_fuzhuang")
            
            Img_fuzhuang:setVisible(msgTbl.kFuzhuangPos == i-1)
            
        end


    end

    --庄是我自己,显示查看底牌按钮
    if self.zhuangPos == self.playerSeatIdx - 1 and msgTbl.kState > 4 then
		local Btn_dipai = gt.seekNodeByName(self.rootNode, "Btn_dipai")
        Btn_dipai:setVisible(self.is_sit)
        self.lastCards = msgTbl.kBaseCards
    end
    -- 显示当前得分
    local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
    self.Text_score  = gt.seekNodeByName(Node_leftInfo, "Text_score")
    if self.Text_score then
        self.Text_score:setString(tostring(msgTbl.kMonoy))
    end
    if msgTbl.kState > 2 then
        --叫的最大分
        local Text_maxjiaofen = gt.seekNodeByName(Node_leftInfo, "Text_maxjiaofen")
        Text_maxjiaofen:setString(tostring(msgTbl.kMaxselectscore))
    end

    --剩余的分数
    self.Text_yufen = gt.seekNodeByName(Node_leftInfo, "Text_yufen")
    self.Text_yufen:setString(tostring(msgTbl.kLeftoverScore))

    --主牌图标
    if msgTbl.kState > 3 then
        local Image_zhupai = gt.seekNodeByName(Node_leftInfo, "Image_zhupai")
        Image_zhupai:setVisible(true)
        if msgTbl.kMainColor == PlaySceneWuRen.ColorType.HEITAO then
              Image_zhupai:loadTexture("res/sd/desk/zhupai1.png")
        elseif msgTbl.kMainColor == PlaySceneWuRen.ColorType.HONGTAO then
              Image_zhupai:loadTexture("res/sd/desk/zhupai2.png")
        elseif msgTbl.kMainColor == PlaySceneWuRen.ColorType.MEIHUA then
              Image_zhupai:loadTexture("res/sd/desk/zhupai3.png")
        elseif msgTbl.kMainColor == PlaySceneWuRen.ColorType.FANGPIAN then
              Image_zhupai:loadTexture("res/sd/desk/zhupai4.png")
        end
    end
end

-- function PlaySceneWuRen:TipOkEvent(eventType, msgTbl)
--     if msgTbl.code == 1 then
--         --是否开局
--         gt.log("发送解散房间消息")
-- 		local msgToSend = {}
-- 		msgToSend.m_msgId = gt.CG_DISMISS_ROOM
-- 		msgToSend.m_pos = self.playerSeatIdx - 1
-- 		gt.socketClient:sendMessage(msgToSend)
--     end
-- end

function PlaySceneWuRen:onRcvDisMissRoom(msgTbl)
    gt.log("收到解散房间消息")
    dump(msgTbl)
    if msgTbl.kErrorCode == 1 then
		-- 游戏未开始解散成功
            self:backMainScene(false)
    else
        if self.isOneHaveChild then
            local Node_ReleseDesk2 = gt.seekNodeByName(self.rootNode, "Node_ReleseDesk2")
	        local PKRoundOver = gt.include("view/DisMissRoom"):create(self.roomPlayers, self.playerSeatIdx, msgTbl)
	        Node_ReleseDesk2:addChild(PKRoundOver)
            local Node_ReleseDesk1 = gt.seekNodeByName(self.rootNode, "Node_ReleseDesk1")
            Node_ReleseDesk1:removeAllChildren()
            self.isOneHaveChild = false
        else
            local Node_ReleseDesk1 = gt.seekNodeByName(self.rootNode, "Node_ReleseDesk1")
	        local PKRoundOver = gt.include("view/DisMissRoom"):create(self.roomPlayers, self.playerSeatIdx, msgTbl)
	        Node_ReleseDesk1:addChild(PKRoundOver)
            local Node_ReleseDesk2 = gt.seekNodeByName(self.rootNode, "Node_ReleseDesk2")
            Node_ReleseDesk2:removeAllChildren()
            self.isOneHaveChild = true
        end
    end
end

function PlaySceneWuRen:RemoveNode_ReleseDesk(eventType, msgTbl)
    
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        
        local Node_ReleseDesk1 = gt.seekNodeByName(self.rootNode, "Node_ReleseDesk1")
        local Node_ReleseDesk2 = gt.seekNodeByName(self.rootNode, "Node_ReleseDesk2")
   
        Node_ReleseDesk1:removeAllChildren()
        Node_ReleseDesk2:removeAllChildren()
    end)))
end

function PlaySceneWuRen:savePlayCount(count)
	local name = gt.name_s .. count .. gt.name_e
	cc.UserDefault:getInstance():setStringForKey("yoyo_name", name)
end

function PlaySceneWuRen:backMainScene(isRoomCreater)
    -- 事件回调
	gt.removeTargetAllEventListener(self)
	-- 消息回调
	-- if self["unregisterAllMsgListener"] then
	-- 	self:unregisterAllMsgListener()
	-- end
    isRoomCreater = false
	local mainScene = require("app/views/MainScene"):create(false, isRoomCreater, self.roomid, self.curDeskCount)
	cc.Director:getInstance():replaceScene(mainScene)
end

function PlaySceneWuRen:is_changzhu(card)



    if card == 2 or card == 18 or card == 34 or card == 50 then 
        if self:checkColors(card) == self.MainColor then 
            return true
        end
    end
    return false
end
-- start -- 
--------------------------------
-- @class function
-- @description 返回大厅
-- end --
function PlaySceneWuRen:onRcvQuitRoom(msgTbl)
	gt.removeLoadingTips()

	if msgTbl.kErrorCode == 0 then
        if self.playerSeatIdx == 1 then
            self:backMainScene(true)
        else
            self:backMainScene(false)
        end
	else
		-- 提示返回大厅失败
		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0045"), nil, nil, true)
	end
end

function PlaySceneWuRen:backMainSceneEvt(eventType)
    self:backMainScene(false)
end

function PlaySceneWuRen:refreshBtn(index)
    
    gt.log(index)
    gt.log("------index----")
    gt.log( self.MaxSelectScore )
    gt.log(self:checkColor(self.selectZhuangNum) )
    gt.log(self.MainColor)
    if self.isRenYiFen then
        if (index == 21 or index == 22) and self.MaxSelectScore < 100 then
            return
        end
    elseif (self:checkColor(self.selectZhuangNum) == self.MainColor or self:checkColor(self.selectZhuangNum) == PlaySceneWuRen.ColorType.KING) and self.MaxSelectScore < 100 then
        local Node_xuanzhuang = gt.seekNodeByName(self.rootNode, "Node_xuanzhuang")
        local Text_xuanZhuangDesc = gt.seekNodeByName(Node_xuanzhuang, "Text_xuanZhuangDesc")
        gt.seekNodeByName(Node_xuanzhuang, "Img_select"):setVisible(false)
        Text_xuanZhuangDesc:setVisible(true)
        Text_xuanZhuangDesc:setString("您未叫到100分，不能选择主花色牌和大小王为副庄家。")
        return
    end
    
    local Node_xuanzhuang = gt.seekNodeByName(self.rootNode, "Node_xuanzhuang")
    local Text_xuanZhuangDesc = gt.seekNodeByName(Node_xuanzhuang, "Text_xuanZhuangDesc")
    Text_xuanZhuangDesc:setVisible(false)
    for i=1, #self.holdCardsNum do
        print(self.selectZhuangNum)
        print(self.holdCardsNum[i])
       if self.selectZhuangNum == self.holdCardsNum[i] then
            Text_xuanZhuangDesc:setVisible(true)
 	        Text_xuanZhuangDesc:setString("选这张牌的话,您将选自己为副庄家。")
          break
      end
    end

    for i =1 , #self.tmp_maidi_card do
        if self.selectZhuangNum == self.tmp_maidi_card[i] then 
            local Node_xuanzhuang = gt.seekNodeByName(self.rootNode, "Node_xuanzhuang")
            local Text_xuanZhuangDesc = gt.seekNodeByName(Node_xuanzhuang, "Text_xuanZhuangDesc")
            Text_xuanZhuangDesc:setVisible(true)
            Text_xuanZhuangDesc:setString("选择的牌已埋底，如果选择它将选择自己为副庄家。")
       end
    end

    if #self.xuanZhuangBtn then
        for i=1, #self.xuanZhuangBtn do
            if self.xuanZhuangBtn[i] then
                if i == index then
                    local Img_select = gt.seekNodeByName(Node_xuanzhuang, "Img_select")
                    Img_select:setVisible(self.is_sit)
                    local btnposx = self.xuanZhuangBtn[i]:getPositionX()
                    local btnposy = self.xuanZhuangBtn[i]:getPositionY()
                    Img_select:setPosition(cc.p(btnposx, btnposy))
                end
            end
        end
    end
end

function PlaySceneWuRen:update(delta)
    if self.timeNumber > 0 then
        self.timeNumber = self.timeNumber - 1
        local seatIdx = (self.turnPos + self.seatOffset) % 5 + 1
        
		local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" ..seatIdx)
        local Img_clock =  gt.seekNodeByName(playerNode, "Img_clock")

        if self.timeNumber > 3 then 
            gt.soundEngine:stopEffect(self._soundid) Img_clock:stopAllActions() Img_clock:setRotation(0)
        end

        if self.timeNumber == 3 then   self:Rote(Img_clock) self._soundid = self:PlaySound("sfx/sound_nn/CLOCK.mp3") end
        local Text_clockNum = gt.seekNodeByName(Img_clock, "Text_clockNum")
        if Text_clockNum then
            Text_clockNum:setString(tostring(self.timeNumber))
        end

        local Node_maidi = gt.seekNodeByName(self.rootNode, "Node_maidi")
        if Node_maidi:isVisible() then
            local maidi_clock = gt.seekNodeByName(Node_maidi, "Img_clock")
            if self.timeNumber > 3 then 
            maidi_clock:stopAllActions() maidi_clock:setRotation(0)
            gt.soundEngine:stopEffect(self._soundid) end
            if self.timeNumber == 3 then   self:Rote(maidi_clock) self._soundid = self:PlaySound("sfx/sound_nn/CLOCK.mp3") end
            local Text_maidiclockNum = gt.seekNodeByName(maidi_clock, "Text_clockNum")
            if Text_maidiclockNum then
                Text_maidiclockNum:setString(tostring(self.timeNumber))
            end
        end

        local Node_xuanzhuang = gt.seekNodeByName(self.rootNode, "Node_xuanzhuang")
        if Node_xuanzhuang:isVisible() then
            local Img_clock_0 = gt.seekNodeByName(Node_xuanzhuang, "Img_clock_0")
            if self.timeNumber > 3 then 
            Img_clock_0:stopAllActions() Img_clock_0:setRotation(0)
            gt.soundEngine:stopEffect(self._soundid) end
            if self.timeNumber == 3 then   self:Rote(Img_clock_0) self._soundid = self:PlaySound("sfx/sound_nn/CLOCK.mp3") end
            local Text_clockNum = gt.seekNodeByName(Img_clock_0, "Text_clockNum")
            if Text_clockNum then
                Text_clockNum:setString(tostring(self.timeNumber))
            end
        end
        
    end
    -- if self.release105Time > 0 then
    --     self.release105Time = self.release105Time - 1
	-- 	local Node_105ReleaseDesk = gt.seekNodeByName(self.rootNode, "Node_105ReleaseDesk")
	-- 	local Text_jiushuTime = gt.seekNodeByName(Node_105ReleaseDesk, "Text_jiushuTime")
    --     Text_jiushuTime:setString(tostring(self.release105Time))
    -- elseif self.release105Time == 0 then
    --     self.release105Time = self.release105Time -1
    --     local msgToSend = {}
	-- 	msgToSend.kMId = gt.MSG_C_2_S_WURENBAIFEN_SCORE_105_RET
	-- 	msgToSend.kPos = self.playerSeatIdx - 1
    --     msgToSend.kAgree = 0
	-- 	gt.socketClient:sendMessage(msgToSend)
    -- else

    -- end
end

function PlaySceneWuRen:update1(delta)
    if self.timeJiaopai > 0 then
        self.timeJiaopai = self.timeJiaopai - 1
        local NoticeJiaoPai = gt.seekNodeByName(self.rootNode, "Notice_jiaopai1")
        if NoticeJiaoPai:isVisible() then
            local Text_daojishi = gt.seekNodeByName(NoticeJiaoPai, "Text_daojishi") --倒计时15秒
            if Text_daojishi then
                Text_daojishi:setString(tostring(self.timeJiaopai))
            end
        end

        local NoticeJiaoPai_2 = gt.seekNodeByName(self.rootNode, "Notice_jiaopai2")
        if NoticeJiaoPai_2:isVisible() then
            local Text_daojishi = gt.seekNodeByName(NoticeJiaoPai_2, "Text_daojishi") --倒计时15秒
            if Text_daojishi then
                Text_daojishi:setString(tostring(self.timeJiaopai))
            end
        end
    end
end

--聊天
function PlaySceneWuRen:onRcvChatMsg(msgTbl)
	gt.log("收到聊天消息")
	dump(msgTbl)
end

--点击玩家头像信息
function PlaySceneWuRen:showPlayerInfo(sender)
    if not self.is_sit then return end

    if self.isFangZuobi then
        Toast.showToast(self, "当前防作弊房间,禁止查看玩家信息!", 2)
    else
	    local senderTag = sender:getTag()
	    local roomPlayer = self.roomPlayers[senderTag]
	    if not roomPlayer then
	    	return
	    end
        gt.log("点击玩家头像，roomPlayer")
        dump(roomPlayer)
        local PKPlayerHeadInfo =  gt.include("view/PKPlayerHeadInfo"):create(roomPlayer , self.playerSeatIdx)
        self:addChild(PKPlayerHeadInfo, PlaySceneWuRen.ZOrder.PLAYER_INFO_TIPS)
    end
end


function PlaySceneWuRen:shareWx() -- 1604788
    local a = self.data.kPlaytype

    local ruleText = ""

    if self.data.kFlag == 1 then
         ruleText = ruleText .. "8局，"
    elseif self.data.kFlag == 2 then 
        ruleText = ruleText .. "12局，"
    elseif self.data.kFlag == 3 then 
        ruleText = ruleText .. "20局，"
    end
   
    local txt = "五人百分,"..(string.len(self.data.kDeskId) == 6 and "房号：" or "文娱馆桌号：")..(self.data.kDeskId).."，缺"..self:get_num().."，"

    ruleText = ruleText .. (a[1].."分场")..(a[2] == 1 and "，2是常主"or "")..(a[4] == 1 and "，对家要牌含10" or "").. 
    (a[6] == 1 and "，闲家干抠" or "") .. 
    (a[7] == 0 and "，庄家不交牌" or "") .. (a[7] == 1 and "，交牌8分" or "") .. (a[7] == 2 and  "，交牌12分" or "") ..
    (a[8] == 1 and "，任意叫分都可选主花牌为副庄" or "")..
    (a[5] == 1 and "，五人百分专属防作弊场" or "")..(self.data.kAllowLookOn == 1 and ", 允许观战" or "") .. (self.data.kClubOwerLookOn == 1 and "，允许会长明牌观战" or "")

    if self.data.kGpsLimit == 1 then 
        ruleText = ruleText.."，【相邻位置禁止进入房间】"
    end

    local url = string.format(gt.HTTP_INVITE, gt.nickname, gt.playerData.headURL, self.data.kDeskId, (string.len(self.data.kDeskId) == 6 and "房号：" or "文娱馆桌号：")..(self.data.kDeskId).."，五人百分，"..ruleText)
    
    gt.log(url)
    gt.log(txt)
    Utils.shareURLToHY(url,txt,ruleText,function(ok) if ok == 0 then  Toast.showToast(self, "分享成功", 2) end end)

end

function PlaySceneWuRen:get_num()
    local playerCount = 0
    for k, v in pairs(self.roomPlayers) do
        if v then
            playerCount = playerCount + 1
        end
    end
    return 5 - playerCount
end

function PlaySceneWuRen:onNNLookonPlayerFull(m)
    self.sit_btn:setVisible(m.kErrorCode == 0)
end


function PlaySceneWuRen:onRcvChatMsg(msgTbl)
    gt.log("收到聊天消息")
    if msgTbl.kPos < 0 or msgTbl.kPos > 4 then
        return
    end
    --dump(msgTbl)
    -- cc.SpriteFrameCache:getInstance():addSpriteFrames("images/EmotionOut.plist")
    if msgTbl.kType == 5 then -- 互动动画类型

        local fromid = msgTbl.m_pos
        local toid = msgTbl.m_id
        local startposx = 0
        local startposy = 0
        local endposx = 0
        local endposy = 0

        local startseat = (msgTbl.kPos + self.seatOffset) % 5 + 1
        local endseat = (msgTbl.kId + self.seatOffset) % 5 + 1
        --给自己发不处理
        if startseat == endseat then
            return
        end
        if startseat == 1 then
            startposx = 70
            startposy = 125
        elseif startseat == 2 then
            startposx = 1215
            startposy = 480
        elseif startseat == 3 then
            startposx = 820
            startposy = 660
        elseif startseat == 4 then
            startposx = 480
            startposy = 660
        elseif startseat == 5 then
            startposx = 70
            startposy = 450
        end
        if endseat == 1 then
            endposx = 70
            endposy = 125
        elseif endseat == 2 then
            endposx = 1215
            endposy = 480
        elseif endseat == 3 then
            endposx = 820
            endposy = 660
        elseif endseat == 4 then
            endposx = 480
            endposy = 660
        elseif endseat == 5 then
            endposx = 70
            endposy = 450
        end
        local Node_headAction = gt.seekNodeByName(self.rootNode, "Node_headAction")          
        Node_headAction:stopAllActions()
        Node_headAction:removeAllChildren()
        local icon = ccui.ImageView:create()
        local actionfile = ""
        local music = ""
        if msgTbl.kMsg == "1" then
            icon:loadTexture("res/sd/animation/hudong1/hua07.png")
            actionfile = "hudong1.csb"
            music = "flower"
        elseif msgTbl.kMsg == "2" then
            icon:loadTexture("res/sd/animation/hudong2/zuanshi07.png")
            actionfile = "hudong2.csb"
            music = "diamond"
        elseif msgTbl.kMsg == "3" then
            icon:loadTexture("res/sd/animation/hudong3/kiss03.png")
            actionfile = "hudong3.csb"
            music = "kiss"
        elseif msgTbl.kMsg == "4" then
            icon:loadTexture("res/sd/animation/hudong5/jinbi03.png")
            actionfile = "hudong4.csb"
            music = "money"
	elseif msgTbl.kMsg == "5" then
            icon:loadTexture("res/sd/animation/hudong6/0000_1.png")
            actionfile = "hudong6.csb"
            music = "tea"
        elseif msgTbl.kMsg == "6" then
            icon:loadTexture("res/sd/animation/hudong7/004.png")
            actionfile = "hudong7.csb"
            music = "good"	
        end
        Node_headAction:addChild(icon)
        Node_headAction:setPosition(cc.p(startposx, startposy))
        local movoto = cc.MoveTo:create(0.8, cc.p(endposx, endposy))
        Node_headAction:runAction(cc.Sequence:create(movoto, cc.CallFunc:create(function()
            Node_headAction:removeAllChildren()
            local actionNode, actionAnime = gt.createCSAnimation(actionfile)
            Node_headAction:addChild(actionNode)
            actionAnime:gotoFrameAndPlay(0, false)
            gt.soundEngine:playEffect("pkdesk/" .. music)
        end)))


    elseif msgTbl.kType == 4 then
        self:startVoiceSchedule(msgTbl)
    else

        local seatIdx = msgTbl.kPos + 1
        local roomPlayer = self.roomPlayers[seatIdx]
        if not roomPlayer then
            return
        end

        local chatBgNode = gt.seekNodeByName(self.rootNode, "Node_player" .. roomPlayer.displaySeatIdx)

      --  local chatBgNode = self.nodePlayer[self:getTableId(msgTbl.kPos)]
       
        
        if msgTbl.kType == gt.ChatType.FIX_MSG then
            self:ShowUserChat(roomPlayer.displaySeatIdx,gt.getLocationString("LTKey_sdr" .. msgTbl.kId),msgTbl)
        elseif msgTbl.kType == gt.ChatType.INPUT_MSG then
        
            self:ShowUserChat(roomPlayer.displaySeatIdx,msgTbl.kMsg)
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
            gt.log("animationStr===",animationStr,roomPlayer.displaySeatIdx)
            local animationNode, animationAction = gt.createCSAnimation(animationStr)
            animationAction:play("run", true)
            self.animationNode = animationNode
            self.animationAction = animationAction
            

            local chat_head_action = self:findNodeByName("chat_head_action_" .. roomPlayer.displaySeatIdx)
            chat_head_action:stopAllActions()
            chat_head_action:removeAllChildren()
            gt.addNode(chat_head_action,animationNode)
            local chatBgNode_delayTime = cc.DelayTime:create(3)
            local chatBgNode_callFunc = cc.CallFunc:create(function(sender)
                if not tolua.isnull(chat_head_action)  then 
                    chat_head_action:stopAllActions()
                    chat_head_action:removeAllChildren()
                end
            end)
            local chatBgNode_Sequence = cc.Sequence:create(chatBgNode_delayTime,chatBgNode_callFunc)
            chat_head_action:runAction(chatBgNode_Sequence)
        elseif msgTbl.kType == gt.ChatType.VOICE_MSG then
        end

    
    end
end


--显示聊天
function PlaySceneWuRen:ShowUserChat(viewid ,message,msg)
    if message and #message > 0 then
        --self.m_GameChat:showGameChat(false) --设置聊天不可见，要显示私有房的邀请按钮（如果是房卡模式）
        --取消上次
        if self.m_UserChat[viewid] then
            self.m_UserChat[viewid]:stopAllActions()
            self.m_UserChat[viewid]:removeFromParent()
            self.m_UserChat[viewid] = nil
        end

        if msg then
            local _tpye = msg.kId
            self:PlaySound("sound_sde/".._tpye..".mp3")
        end

        gt.log("message_____",message)


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
        if viewid == 2 then 

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

function PlaySceneWuRen:ShowUserChat1(viewid,time)
    time = tonumber(time) or 30

    self._voice[viewid]:setVisible(true)
    self._voice[viewid]:stopAllActions()
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

return PlaySceneWuRen