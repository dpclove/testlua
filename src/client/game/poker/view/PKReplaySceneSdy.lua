

local gt = cc.exports.gt

local PKReplaySceneSdy = class("PKReplaySceneSdy", function()
	return cc.Layer:create()
end)


PKReplaySceneSdy.ColorType = {
    -- 大小王
    KING                = 0x40,
    -- 黑桃
    HEITAO              = 0x30,
    -- 红桃
    HONGTAO             = 0x20,
    -- 梅花
    MEIHUA              = 0x10,
    -- 方片
    FANGPIAN            = 0x00
}


function PKReplaySceneSdy:is_changzhu(card)



    if card == 2 or card == 18 or card == 34 or card == 50 then 
        if self:checkColors(card) == self.MainColor then 
            return true
        end
    end
    return false
end


function PKReplaySceneSdy:checkColor(card)
    if self.isChangZhu then
        if card >= 78 or card == 2 or card == 18 or card == 34 or card == 50 then
            --大小王和四个2
            return PKReplaySceneSdy.ColorType.KING
        elseif card >= 49 and card <= 61 then
            --黑桃
            return PKReplaySceneSdy.ColorType.HEITAO
        elseif card >= 33 and card <= 45 then
            --红桃
            return PKReplaySceneSdy.ColorType.HONGTAO
        elseif card >= 17 and card <= 29 then
            --梅花
            return PKReplaySceneSdy.ColorType.MEIHUA
        elseif card >= 1 and card <= 13 then
            --方片
            return PKReplaySceneSdy.ColorType.FANGPIAN
        end
    else
        if card >= 78 then
            --大小王
            return PKReplaySceneSdy.ColorType.KING
        elseif card >= 49 and card <= 61 then
            --黑桃
            return PKReplaySceneSdy.ColorType.HEITAO
        elseif card >= 33 and card <= 45 then
            --红桃
            return PKReplaySceneSdy.ColorType.HONGTAO
        elseif card >= 17 and card <= 29 then
            --梅花
            return PKReplaySceneSdy.ColorType.MEIHUA
        elseif card >= 1 and card <= 13 then
            --方片
            return PKReplaySceneSdy.ColorType.FANGPIAN
        end
    end
end


function PKReplaySceneSdy:checkColors(card)

      if card >= 78 then
            --大小王
            return PKReplaySceneSdy.ColorType.KING
        elseif card >= 49 and card <= 61 then
            --黑桃
            return PKReplaySceneSdy.ColorType.HEITAO
        elseif card >= 33 and card <= 45 then
            --红桃
            return PKReplaySceneSdy.ColorType.HONGTAO
        elseif card >= 17 and card <= 29 then
            --梅花
            return PKReplaySceneSdy.ColorType.MEIHUA
        elseif card >= 1 and card <= 13 then
            --方片
            return PKReplaySceneSdy.ColorType.FANGPIAN
        end

end
--手牌排序
function PKReplaySceneSdy:sortCards(handcards, MainCard)
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
    
    if MainCard == PKReplaySceneSdy.ColorType.HEITAO then
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
    elseif MainCard == PKReplaySceneSdy.ColorType.HONGTAO then
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
    elseif MainCard == PKReplaySceneSdy.ColorType.MEIHUA then
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
    elseif MainCard == PKReplaySceneSdy.ColorType.FANGPIAN then
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

function PKReplaySceneSdy:ctor(replayData)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	gt.dump(replayData)
	self.replayStepsData = replayData.kOper
    
	-- 加载界面资源
	local csbNode = cc.CSLoader:createNode("PKReplaySceneSdy.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

	self.isPause = false

	-- 播放按键
	local playBtn = gt.seekNodeByName(self.rootNode, "Btn_play")
	-- 暂停
	local pauseBtn = gt.seekNodeByName(self.rootNode, "Btn_pause")

	gt.addBtnPressedListener(playBtn, function()
		self:setPause(false)
        playBtn:setTouchEnabled(false)
        playBtn:setBright(false)
        pauseBtn:setTouchEnabled(true)
        pauseBtn:setBright(true)
	end)
	gt.addBtnPressedListener(pauseBtn, function()
		self:setPause(true)
        playBtn:setTouchEnabled(true)
        playBtn:setBright(true)
        pauseBtn:setTouchEnabled(false)
        pauseBtn:setBright(false)
	end)

	-- 退出
	local exitBtn = gt.seekNodeByName(self.rootNode, "Btn_back")
	gt.addBtnPressedListener(exitBtn, function()
        gt.isShowReplay = false
		self:removeFromParent()
	end)

	-- 后退
--[[	
    local preBtn = gt.seekNodeByName(self.rootNode, "Btn_pre")
	if preBtn then
		gt.addBtnPressedListener(preBtn, function()
			--self:preRound()
            self:removeFromParent()
		end)
	end
	-- 前进
	local nextBtn = gt.seekNodeByName(self.rootNode, "Btn_next")
	if nextBtn then
		gt.addBtnPressedListener(nextBtn, function()
			self:nextRound()
		end)
	end
    ]]--

    self.isChangZhu = false
    if replayData.kPlaytype[2] == 1 then
        self.isChangZhu = true
    end


	-- 快进或者快退的步数
	self.quickStepNum	= 8
	-- 点击快进/快退开始的时间
	self.quickStartTime = 0
    
	-- 暂停中
    self.isPause = false
    --是否结束
    self.isReplayFinish = false

	self.curReplayStep = 1
	self.showDelayTime = 2

    --庄家座位号
    self.zhuangPos = replayData.kZhuang

	-- 玩家座位编号
	self.playerSeatIdx = 0

    -- 玩家底牌
	self.lastCards = {}
    --玩家埋底
    self.maidiCards = {}
    --主牌
    self.mainCard = 0
    --副庄的牌
    self.fuzhuangCard = 0

    for i=1, #replayData.kUserid do
        if replayData.kUserid[i] == gt.playerData.uid then
            self.playerSeatIdx = i
            break
        end
    end


    local playerHeadMgr = gt.include("view/PlayerHeadManager"):create()
    self.rootNode:addChild(playerHeadMgr)
    self.playerHeadMgr = playerHeadMgr

	self.playerFixDispSeat = 4
    -- 逻辑座位和显示座位偏移量(从0编号开始)
    local seatOffset = self.playerFixDispSeat - replayData.kPos

	self.seatOffset = seatOffset
    
    self:inidUI(replayData)
end

function PKReplaySceneSdy:inidUI(replayData)
    -- 播放按键
	local playBtn = gt.seekNodeByName(self.rootNode, "Btn_play")
	-- 暂停
	local pauseBtn = gt.seekNodeByName(self.rootNode, "Btn_pause")
    
    playBtn:setTouchEnabled(false)
    playBtn:setBright(false)
    pauseBtn:setTouchEnabled(true)
    pauseBtn:setBright(true)

    for i=1, self.playerFixDispSeat do
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
	    local Img_banker = gt.seekNodeByName(playerNode, "Img_banker")
	    local Img_fuzhuang = gt.seekNodeByName(playerNode, "Img_fuzhuang")
        Img_banker:setVisible(false)
        Img_fuzhuang:setVisible(false)
    end

    -- 播放结束文字
	local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
    Text_desc:setVisible(false)

	-- 房间号
	local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
	local Text_roomid = gt.seekNodeByName(Node_leftInfo, "Text_roomid")
	Text_roomid:setString(tostring(replayData.kDeskId))

    --局数
	local Text_jushu = gt.seekNodeByName(Node_leftInfo, "Text_jushu")
	Text_jushu:setString(tostring(replayData.kCurCircle) .. "/" ..tostring(replayData.kMaxCircle))

    --叫分
	local Text_jiaofen = gt.seekNodeByName(Node_leftInfo, "Text_jiaofen")
	Text_jiaofen:setString("叫分:" .. tostring(replayData.kZhuangScore))

    --得分
	local Text_defen = gt.seekNodeByName(Node_leftInfo, "Text_defen")
	Text_defen:setString("得分:0")


    for i=1, self.playerFixDispSeat do
        local seatIdx = (i-1 + self.seatOffset) % self.playerFixDispSeat + 1


	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
	    local Text_name = gt.seekNodeByName(playerNode, "Text_name")
        Text_name:setString(replayData.kNike[i])
	    local Text_name = gt.seekNodeByName(playerNode, "Text_score")
        Text_name:setString(replayData.kScore[i])


        local headSpr =  gt.seekNodeByName(playerNode, "Sprite_head")

        
        self.playerHeadMgr:attach(headSpr, replayData.kImageUrl[i], nil, nil, true)


        local Node_handCards = gt.seekNodeByName(playerNode, "Node_handCards")
        local handcards = {}
        -- if seatIdx == 1 then
        --     handcards = replayData.kCard0
        -- elseif seatIdx == 2 then
        --     handcards = replayData.kCard1
        -- elseif seatIdx == 3 then
        --     handcards = replayData.kCard2
        -- elseif seatIdx == 4 then
        --     handcards = replayData.kCard3
        -- elseif seatIdx == 5 then
        --     handcards = replayData.kCard4
        -- end
        
        handcards = replayData["kCard"..(i-1)]

        for j=1, #handcards do
	        local card = ccui.ImageView:create()
	        card:loadTexture("res/sd/pk/" .. handcards[j] .. ".png")
            Node_handCards:addChild(card)
            card:setScale(0.3)
            card:setPosition(cc.p(-120 + j*20,0))
            if seatIdx == 1 then
                card:setScale(1)
                card:setPosition(cc.p(-330 + j*60,0))
            end
        end
    end
end

function PKReplaySceneSdy:addImage(headSpr,args)
    args = args or false
    local imgFileName = gt.imageNamePath(headURL)
    local observerData = {}
    observerData.headSpr = headSpr
    observerData.imgFileName = imgFileName
    observerData.headURL = string.gsub(headURL, "/0", "/96")

    if imgFileName then

        if  args then 
            local _node = cc.Sprite:create(args.icon)
            if _node then 
                _node:retain()
                local head = gt.clippingImage(imgFileName,_node,false)
                _node:release()
                if gt.addNode(observerData.headSpr:getParent(), head , args.zorder  ) then 
                    observerData.headSpr:setVisible(false)
                    head:setPosition(observerData.headSpr:getPositionX(),observerData.headSpr:getPositionY())
                end
            end
        else
            observerData.headSpr:loadTexture(observerData.imgFileName)
        end
    else
        local function callback(a)
            if self and self._exit and  a.done then

                if  args then 
                    local _node = cc.Sprite:create(args.icon)
                    if _node then 
                        _node:retain()
                        local head = gt.clippingImage(a.image,_node,false)
                        _node:release()
                        if gt.addNode(observerData.headSpr:getParent(), head , args.zorder  ) then 
                            observerData.headSpr:setVisible(false)
                            head:setPosition(observerData.headSpr:getPositionX(),observerData.headSpr:getPositionY())
                        end
                    end
                else
                    headSpr:loadTexture(a.iamge)    
                end

            end
        end    
        gt.downloadImage(headURL,callback)  
    end

end

function PKReplaySceneSdy:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
        gt.soundEngine:playMusic("pkdesk/bgm", true)
		-- 逻辑更新定时器
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)

		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function PKReplaySceneSdy:onTouchBegan(touch, event)
	return true
end

-- 快推的话,原理是将牌恢复到最初始状态
-- 然后快速行进到当前状态
function PKReplaySceneSdy:preRound()
    self.curReplayStep = self.curReplayStep - 5
    if self.curReplayStep < 1 then
       self.curReplayStep = 1
    end
	self.quickStartTime = os.time()
end

-- 快速回合播放
function PKReplaySceneSdy:nextRound()
	-- -- 如果暂停或者已经结束,是否需要回退
    self.curReplayStep = self.curReplayStep + 5
    if self.curReplayStep > #self.replayStepsData then
       self.curReplayStep = #self.replayStepsData
    end
	self.quickStartTime = os.time()
end

function PKReplaySceneSdy:doAction( curReplayStep )
    local oper =  self.replayStepsData[curReplayStep]
    if oper[2] == 2 then
       gt.log("叫分")
       self:qiangZhuang(oper)
    elseif oper[2] == 3 then
        gt.log("选主")
        self.MainColor = oper[4][1]
        gt.log("=======好东西" .. self.MainColor)
        self:xuanZhu(oper)

    elseif oper[2] == 4 then
        gt.log("埋底")
        self:maiDi(oper)
    elseif oper[2] == 5 then
        gt.log("选副庄")
        --self:xuanFuZhuang(oper)
    elseif oper[2] == 6 then
        gt.log("出牌")
        self:chuPai(oper)
    --elseif oper[2] == 7 then
        --gt.log("结束")
        --self:onFinish(oper)
    elseif oper[2] == 8 then
        gt.log("结束")
        self:onFinish(oper)
        
    end
    
	self.curReplayStep = self.curReplayStep + 1
end

function PKReplaySceneSdy:update(delta)
    if self.isPause or self.isReplayFinish then
		return
	end
    if os.time() - self.quickStartTime < 2 then -- 如果已经有2s没有触摸快进/快退按钮了,那么可以播放自动录像了
		return
	end
    self.showDelayTime = self.showDelayTime + delta
	if self.showDelayTime > 1.5 then
		self.showDelayTime = 0

		self:doAction( self.curReplayStep )
	end
end

function PKReplaySceneSdy:setPause(isPause)
    self.isPause =  isPause
end

function PKReplaySceneSdy:updateCurrentTime()
end

function PKReplaySceneSdy:qiangZhuang(oper)
    
    local seatIdx = (oper[1] + self.seatOffset) % self.playerFixDispSeat + 1
	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
	local Img_score = gt.seekNodeByName(playerNode, "Img_score")
    Img_score:setVisible(true)
	local Text_jiaofen = gt.seekNodeByName(playerNode, "Text_jiaofen")
    if oper[3] < 60 then
        Text_jiaofen:setString("不叫")
    else
        Text_jiaofen:setString(oper[3])
    end
    gt.soundEngine:playEffect("pkdesk/" .. tostring(oper[3]))
    self.lastCards = nil
    self.lastCards = {}
    for i=1, 6 do
        table.insert(self.lastCards, oper[4][i])
    end
end

function PKReplaySceneSdy:xuanZhu(oper)
    for i=1, self.playerFixDispSeat do
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
	    local Img_score = gt.seekNodeByName(playerNode, "Img_score")
        Img_score:setVisible(false)
    end

    local seatIdx = (self.zhuangPos + self.seatOffset) % self.playerFixDispSeat + 1
	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
	local Img_banker = gt.seekNodeByName(playerNode, "Img_banker")
    Img_banker:setVisible(true)

	local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
	local Image_zhupai = gt.seekNodeByName(Node_leftInfo, "Image_zhupai")
    Image_zhupai:setVisible(true)

    gt.log("===============也不知道是啥" .. oper[4][1])

    if oper[4][1] == 48 then
          Image_zhupai:loadTexture("res/sd/desk/zhupai1.png")
    elseif oper[4][1] == 32 then
          Image_zhupai:loadTexture("res/sd/desk/zhupai2.png")
    elseif oper[4][1] == 16 then
          Image_zhupai:loadTexture("res/sd/desk/zhupai3.png")
    elseif oper[4][1] == 0 then
          Image_zhupai:loadTexture("res/sd/desk/zhupai4.png")
    end
    
    local _posX = 60

    for i=1, self.playerFixDispSeat do
        local seatIdx = (i-1 + self.seatOffset) % self.playerFixDispSeat + 1
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
        local Node_handCards = gt.seekNodeByName(playerNode, "Node_handCards")
        Node_handCards:removeAllChildren()

        local handcards = {}
        if i - 1 == self.zhuangPos then
            handcards = oper[5][i]
            for j=1, 6 do
                table.insert(handcards, self.lastCards[j]) 
            end
        else
            handcards = oper[5][i]
        end
        handcards =  self:sortCards(handcards, self.MainColor)
        local startPos1 = -#handcards/2 * 60
        local startPos2 = -#handcards/2 * 20
        for j=1, #handcards do
	        local card = ccui.ImageView:create()
	        card:loadTexture("res/sd/pk/" .. handcards[j] .. ".png")
            Node_handCards:addChild(card)
            card:setScale(0.3)
            card:setPosition(cc.p(startPos2 + j*20,0))

            if seatIdx == 3 and #handcards == 18 then
                card:setPosition(cc.p(startPos2 + j*20 + 50,0))
            end

            if seatIdx == 2 and #handcards == 18 then
                card:setPosition(cc.p(startPos2 + j*20 - 70,0))
            end

            if seatIdx == 4 and #handcards == 18 then
                card:setPosition(cc.p(startPos2 + j*20 + 70,0))
            end



            if seatIdx == 1 then
                local _pianyiX = 0
                if #handcards == 18 then
                    _posX = 50
                    _pianyiX = 100
                end
                card:setScale(1)
                card:setPosition(cc.p(startPos1 + j*_posX + _pianyiX,0))
            end

            if self:checkColor(handcards[j]) == self.MainColor or self:checkColor(handcards[j]) == PKReplaySceneSdy.ColorType.KING then
                 local star = ccui.ImageView:create()
                 star:loadTexture("res/sd/desk/star.png")
                 card:addChild(star)
                 star:setPosition(cc.p(25, 30))
                 if self.isChangZhu and self:is_changzhu(handcards[j]) then 
                    local star = ccui.ImageView:create()
                    star:loadTexture("res/sd/desk/star.png")
                    card:addChild(star)
                    star:setPosition(cc.p(25, 60))
                end
            end

        end
    end

    --底牌
	local Node_dipai = gt.seekNodeByName(self.rootNode, "Node_dipai")
    for i=1, 6 do
	    local card = ccui.ImageView:create()
	    card:loadTexture("res/sd/pk/" .. self.lastCards[i] .. ".png")
        Node_dipai:addChild(card)
        card:setPosition(cc.p(15 * i - 15, 0))
        card:setScale(0.2)
    end
end

function PKReplaySceneSdy:maiDi(oper)
    local seatIdx = (self.zhuangPos + self.seatOffset) % self.playerFixDispSeat + 1
	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
	local Img_banker = gt.seekNodeByName(playerNode, "Img_banker")
    Img_banker:setVisible(true)

    for i=1, self.playerFixDispSeat do
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
	    local Img_score = gt.seekNodeByName(playerNode, "Img_score")
        Img_score:setVisible(false)
    end
    local seatIdx = (oper[1] + self.seatOffset) % self.playerFixDispSeat + 1
    self.maidiCards = nil
    self.maidiCards = {}
    for i=1, #oper[4] do
        table.insert(self.maidiCards, oper[4][i])
    end

    --底牌
	local Node_dipai = gt.seekNodeByName(self.rootNode, "Node_dipai")
    Node_dipai:removeAllChildren()
    for i=1, 6 do
	    local card = ccui.ImageView:create()
	    card:loadTexture("res/sd/pk/" .. self.lastCards[i] .. ".png")
        Node_dipai:addChild(card)
        card:setPosition(cc.p(15 * i - 15, 0))
        card:setScale(0.2)
    end

	local Node_maidi = gt.seekNodeByName(self.rootNode, "Node_maidi")
    Node_maidi:removeAllChildren()
    for i=1, 6 do
	    local card = ccui.ImageView:create()
	    card:loadTexture("res/sd/pk/" .. self.maidiCards[i] .. ".png")
        Node_maidi:addChild(card)
        card:setPosition(cc.p(15 * i - 15, 0))
        card:setScale(0.2)
    end
    --埋底结束跟新手牌
    for i=1, self.playerFixDispSeat do
        local seatIdx = (i-1 + self.seatOffset) % self.playerFixDispSeat + 1
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
        local Node_handCards = gt.seekNodeByName(playerNode, "Node_handCards")
        Node_handCards:removeAllChildren()
        local handcards = oper[5][i]
        handcards = self:sortCards(handcards, self.MainColor)
        local startPos1 = -#handcards/2 * 60
        local startPos2 = -#handcards/2 * 20
        for j=1, #handcards do
	        local card = ccui.ImageView:create()
	        card:loadTexture("res/sd/pk/" .. handcards[j] .. ".png")
            Node_handCards:addChild(card)
            card:setScale(0.3)
            card:setPosition(cc.p(startPos2 + j*20,0))
            if seatIdx == 1 then
                card:setScale(1)
                card:setPosition(cc.p(startPos1 + j*60,0))
            end

            if self:checkColor(handcards[j]) == self.MainColor or self:checkColor(handcards[j]) == PKReplaySceneSdy.ColorType.KING then
                 local star = ccui.ImageView:create()
                 star:loadTexture("res/sd/desk/star.png")
                 card:addChild(star)
                 star:setPosition(cc.p(25, 30))
                 if self.isChangZhu and self:is_changzhu(handcards[j]) then 
                    local star = ccui.ImageView:create()
                    star:loadTexture("res/sd/desk/star.png")
                    card:addChild(star)
                    star:setPosition(cc.p(25, 60))
                end
            end

        end
    end
end

function PKReplaySceneSdy:xuanFuZhuang(oper)
    local seatIdx = (self.zhuangPos + self.seatOffset) % self.playerFixDispSeat + 1
	local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
	local Img_banker = gt.seekNodeByName(playerNode, "Img_banker")
    Img_banker:setVisible(true)
    
    local zhuangpos = (self.zhuangPos + self.seatOffset) % self.playerFixDispSeat + 1
    local fuzhuangpos = (oper[3] + self.seatOffset) % self.playerFixDispSeat + 1
	local playerNodefuzhuang = gt.seekNodeByName(self.rootNode, "Node_player" .. fuzhuangpos)
	local Img_fuzhuang = gt.seekNodeByName(playerNodefuzhuang, "Img_fuzhuang")
    Img_fuzhuang:setVisible(true)
    if fuzhuangpos == fuzhuangpos then
       Img_banker:setPosition(cc.p(-5,55))
    else
         Img_banker:setPosition(cc.p(35,55))
    end
    for i=1, self.playerFixDispSeat do
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
	    local Img_score = gt.seekNodeByName(playerNode, "Img_score")
        Img_score:setVisible(false)
    end
	local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
	local Img_duijia = gt.seekNodeByName(Node_leftInfo, "Img_duijia")
    Img_duijia:setVisible(true)
	Img_duijia:loadTexture("res/sd/pkSmall/" .. oper[4][1] .. ".png")
end

function PKReplaySceneSdy:chuPai(oper)
    for i=1, self.playerFixDispSeat do
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
	    local Img_score = gt.seekNodeByName(playerNode, "Img_score")
        Img_score:setVisible(false)
    end
    local tmp = nil
    for i=1, self.playerFixDispSeat do
        local seatIdx = (i-1 + self.seatOffset) % self.playerFixDispSeat + 1
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
        if oper[1] == (i-1) then
	        local Node_outCard = gt.seekNodeByName(playerNode, "Node_outCard")
            tmp = Node_outCard
	        local card = ccui.ImageView:create()
	        card:loadTexture("res/sd/pk/" .. oper[4][1] .. ".png")
            Node_outCard:addChild(card)
            card:setScale(0.4)
        end
    end
    for i=1, self.playerFixDispSeat do
        local seatIdx = (i-1 + self.seatOffset) % self.playerFixDispSeat + 1
	    local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. seatIdx)
        local Node_handCards = gt.seekNodeByName(playerNode, "Node_handCards")
        Node_handCards:removeAllChildren()
        local handcards = oper[5][i]
        handcards = self:sortCards(handcards, self.MainColor)
        local startPos1 = -#handcards/2 * 60
        local startPos2 = -#handcards/2 * 20
        for j=1, #handcards do
	        local card = ccui.ImageView:create()
	        card:loadTexture("res/sd/pk/" .. handcards[j] .. ".png")
            Node_handCards:addChild(card)
            card:setScale(0.3)
            card:setPosition(cc.p(startPos2 + j*20,0))
            if seatIdx == 1 then
                card:setScale(1)
                card:setPosition(cc.p(startPos1 + j*60,0))
            end

            if self:checkColor(handcards[j]) == self.MainColor or self:checkColor(handcards[j]) == PKReplaySceneSdy.ColorType.KING then
                 local star = ccui.ImageView:create()
                 star:loadTexture("res/sd/desk/star.png")
                 card:addChild(star)
                 star:setPosition(cc.p(25, 30))
                 if self.isChangZhu and self:is_changzhu(handcards[j]) then 
                    local star = ccui.ImageView:create()
                    star:loadTexture("res/sd/desk/star.png")
                    card:addChild(star)
                    star:setPosition(cc.p(25, 60))
                end
            end

        end
    end
    if #oper[4] > 1 then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
            for i=1, self.playerFixDispSeat do
	            local playerNode = gt.seekNodeByName(self.rootNode, "Node_player" .. i)
	            local Node_outCard = gt.seekNodeByName(playerNode, "Node_outCard")
                Node_outCard:removeAllChildren()
            end
        end)))
    end
    if oper[3] > 0 then
	    local Node_leftInfo = gt.seekNodeByName(self.rootNode, "Node_leftInfo")
	    local Text_defen = gt.seekNodeByName(Node_leftInfo, "Text_defen")
	    Text_defen:setString("得分:" .. tostring(oper[3]))
    end

       --播放声音
    if oper[6] ~= -1 then 
        gt.soundEngine:playEffect("pkdesk/pia")
        if oper[6]  == 1 then
           gt.soundEngine:playEffect("pkdesk/diaozhu")
        elseif oper[6]  == 2 then
           gt.soundEngine:playEffect("pkdesk/guanshang")
        elseif oper[6]  == 3 then
           gt.soundEngine:playEffect("pkdesk/dani")
        elseif oper[6] == 4 then
             gt.soundEngine:playEffect("pkdesk/bi")
           if tmp then 
              
               local Node_action = tmp
               local biNode, biAnime = gt.createCSAnimation("runAction/bi_run.csb")  
               Node_action:stopAllActions()
               Node_action:removeChildByName("_BI_")
               Node_action:addChild(biNode)
               biNode:setName("_BI_")
               biAnime:gotoFrameAndPlay(0, false)
               self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function(sender)
                   Node_action:stopAllActions()
                  Node_action:removeChildByName("_BI_")
               end)))
         end
        elseif oper[6] == 5 then

           gt.soundEngine:playEffect("pkdesk/gaibi")
            if tmp then 
           local Node_action = tmp
           local gaibiNode, gaibiAnime = gt.createCSAnimation("gaibiAction.csb")
           Node_action:stopAllActions()
           Node_action:removeChildByName("_GAI_BI_")
             gaibiNode:setName("_GAI_BI_")
           Node_action:addChild(gaibiNode)
           gaibiAnime:gotoFrameAndPlay(0, false)
           self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function(sender)
               Node_action:stopAllActions()
               Node_action:removeChildByName("_GAI_BI_")
           end)))
       end
        elseif oper[6]  == 8 then
            gt.soundEngine:playEffect("pkdesk/dianpai")
        elseif oper[6] == -2 then
            gt.soundEngine:playEffect("pkcard/" .. oper[4][1] or "")
        end
    end



end

function PKReplaySceneSdy:onFinish(oper)
    self.isReplayFinish = true
    
    -- 播放结束文字
	local Text_desc = gt.seekNodeByName(self.rootNode, "Text_desc")
    Text_desc:setVisible(true)
    if oper[1] == -1 then
        Text_desc:setString("战绩播放结束!")
    elseif oper[1] == 2 then
        Text_desc:setString("闲家得分破105,战绩播放结束!")
    end
end

return PKReplaySceneSdy

