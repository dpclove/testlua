
local playback = class("ddzScene",function()
	return cc.Layer:create()
	end)

local CardSprite = gt.include("ddzCard.CardSprite")
local CardsNode = gt.include("ddzCard.CardsNode")

local GameLogic =  gt.include("ddzCard.GameLogic")
local GameLaiziLogic =  gt.include("ddzCard.GameLaiziLogic")

local  log = gt.log

local tabCardPosition = 
    {
        cc.p(148.77+54.66, 546.62),
        cc.p(667, 90),
        cc.p(1129.90+54.66, 546.62)
    }
-- local actionPos = {
-- 	cc.p(413+70,396),
-- 	cc.p(650,480),
-- 	cc.p(870-50,396)
-- }
local actionPos = {
	cc.p(413+70-80,396),
	cc.p(650,480),
	cc.p(870+80,396)
}

function playback:getTableId(seatId)



	if not self.UsePos then return end

	if seatId >=gt.GAME_PLAYER or seatId < 0 then return gt.INVALID_CHAIR end
	local id = (gt.MY_VIEWID - self.UsePos + seatId)%gt.GAME_PLAYER
	if id == 0 then	id = gt.GAME_PLAYER end
	
	return id

end

function playback:findNodeByName(name, parent)
	
	parent = parent or self._node 
	
	return gt.seekNodeByName(parent,name)
end

function playback:ctor(replayData)

	gt.SCENE_TYPE = "VIDEO" 
	gt.MY_VIEWID = 2
	gt.GAME_PLAYER = 3
	self.UsePos = replayData.kPos
	self.data = replayData.kOper
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	local csbNode = cc.CSLoader:createNode("play_back.csb")
	self:addChild(csbNode)
	self._node  = csbNode

	self.isPause = false
	self.m_bLastCompareRes = false
	self.m_tabLastCards = {} 
	self.curReplayStep = 0
	self.quickStartTime = 0
	self.showDelayTime = 0
	self:init(replayData)

	local optBtnsSpr = gt.seekNodeByName(csbNode, "Spr_optBtns")
	optBtnsSpr:setLocalZOrder(10)
	-- 播放按键
	local playBtn = gt.seekNodeByName(optBtnsSpr, "Btn_play")
	--playBtn:setVisible(false)
	self.playBtn = playBtn
	-- 暂停
	self.playBtn:setTouchEnabled (false)
	playBtn:setBright(false)
	local pauseBtn = gt.seekNodeByName(optBtnsSpr, "Btn_pause")
	self.pauseBtn = pauseBtn
	gt.addBtnPressedListener(playBtn, function()
		gt.log("1")
		self:setPause(false)
	end)
	gt.addBtnPressedListener(pauseBtn, function()
		gt.log("2")
		self:setPause(true)
	end)
	-- 退出
	local exitBtn = gt.seekNodeByName(optBtnsSpr, "Btn_exit")
	gt.addBtnPressedListener(exitBtn, function()
		gt.isShowReplay = false
		self:removeFromParent()
	end)
	-- 后退
	local preBtn = gt.seekNodeByName(optBtnsSpr, "Btn_pre")
	if preBtn then
		gt.addBtnPressedListener(preBtn, function()
			self:preRound()
		end)
	end
	-- 前进
	local nextBtn = gt.seekNodeByName(optBtnsSpr, "Btn_next")
	if nextBtn then
		gt.addBtnPressedListener(nextBtn, function()
			self:nextRound()
		end)
	end

	self:updateProgress()

end


function playback:init(m)






    self.bomb = self:findNodeByName("bomb")
    
    self.rocket = self:findNodeByName("rocket")
    self.plane = self:findNodeByName("plane")
    self.sunzi = self:findNodeByName("sunzi")
    self.sandaiyi = self:findNodeByName("sandaiyi")
    self.sidaier = self:findNodeByName("sidaier")
    self.liandui = self:findNodeByName("liandui")
    self.sandaiyidui = self:findNodeByName("sandaiyidui")
    self.sanzhang = self:findNodeByName("sanzhang")
	



	for i =1 , #gt.poker_node do
        cc.Director:getInstance():getTextureCache():addImage(gt.poker_node[i])
        cc.Director:getInstance():getTextureCache():addImage(gt.poker_node1[i])
    end

	local node = self:findNodeByName("game_info")

	self:findNodeByName("room_id",node):setString(m.kDeskId)
	self:findNodeByName("num",node):setString(m.kCurCircle.."/"..m.kMaxCircle)
	self:findNodeByName("t3",node):setString("底注:"..m.kPlaytype[4])

	local di_card_node = nil
	self._type = m.kPlaytype[1]
	if m.kPlaytype[1] == 3 then ---- 临汾去俩二
		gt.card_num_max = 20
		gt.card_num = 16
		gt.di_card = 4
		self:findNodeByName("t2",node):setString("倍数:"..1)
		di_card_node = self:findNodeByName("card_d_1111")
		log("jingdia______________________2",#di_card_node:getChildren())
	elseif m.kPlaytype[1] == 2 then --癞子 
		gt.card_num_max = 21
		gt.card_num = 17
		gt.di_card = 4
		self:findNodeByName("t2",node):setString("叫分:"..m.kZhuangScore)
		di_card_node = self:findNodeByName("card_d_1111")
		log("jingdia______________________1")
	else -- 经典
		gt.card_num = 17
		gt.card_num_max = 20
		gt.di_card = 3
		self:findNodeByName("t2",node):setString("叫分:"..m.kZhuangScore)
		di_card_node = self:findNodeByName("card_d")
		log("jingdia______________________")
	end
	self:findNodeByName("f_zuibi"):setVisible(m.kPlaytype[5] == 1)
	self:findNodeByName( "type"):loadTexture("ddz/ddz_type"..m.kPlaytype[1]..".png")
	self:findNodeByName("fengd_b"):loadTexture("ddz/play_type"..m.kPlaytype[3]..".png")
	di_card_node:setVisible(true)
	for i = 1, gt.di_card do
		gt.log("iiiiiiiiiiiii",i,di_card_node:getChildByName("card_d_"..i))
		gt.log(#di_card_node:getChildren())

		di_card_node:getChildByName("card_d_"..i):loadTexture("poker_ddz1/"..gt.tonumber(m.kRestCard[i])..".png")
	end
	gt.three_bomb  =  m.kPlaytype[9] == 1 
	self.m_UserHead = {}
	self.nodePlayer = {}
	self.call_score = {}
	self.m_tabNodeCards = {}
	self.m_tabSpAlarm = {}
	self.m_tabCardCount  = {}
	self.Player = {}
    self.m_cardControl = self:findNodeByName("card_control")
    self.m_outCardsControl = self:findNodeByName("outcards_control")
    self.m_tabCardCount[1] = self.m_cardControl:getChildByName("AtlasLabel_1")
    self.m_tabCardCount[1]:setLocalZOrder(20)
    self.m_tabCardCount[3] = self.m_cardControl:getChildByName("AtlasLabel_3")
    self.m_tabCardCount[3]:setLocalZOrder(20)

	for i = 1 , gt.GAME_PLAYER do

    	self.call_score[i] = self:findNodeByName("x"..i)
    	:setVisible(false)
    	self.Player[i] = {}
		self.nodePlayer[i] = self:findNodeByName("player_"..i)
		self.nodePlayer[i]:setVisible(false)
		self.Player[i].sex = nil
		self.m_UserHead[i] = {}
		--昵称
		self.m_UserHead[i].name = self.nodePlayer[i]:getChildByName("name")
		-- self.m_UserHead[i].card1 = self.nodePlayer[i]:getChildByName("card1")				
		-- self.m_UserHead[i].card2 = self.nodePlayer[i]:getChildByName("card2")
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
        self.m_tabSpAlarm[i] = self.m_cardControl:getChildByName("alarm_" .. i)
	end



	self.card_buf = {}

	self.buf = {}
	self.m = m
	for i = 1, gt.GAME_PLAYER do 

		local tmp = m["kCard"..(i-1)]
		
		-- for j = 1 ,#tmp do
		-- 	log("j...........",tmp[j])
		-- end

		local chair = i - 1
	    local viewId = self:getTableId(chair)
	    self.buf[viewId] = tmp
	    self.card_buf[viewId] = tmp
	    local cards = {}
	    local count = #tmp
	    if gt.MY_VIEWID == viewId then
	       
	        for j = 1, count do
	            table.insert(cards, tmp[j])
	        end
	        self.PokerNum = count
	        cards = GameLogic:SortCardList(cards, count, 0)

	        if viewId == self:getTableId(m.kZhuang) then 
    			local bug = self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:getChildren()
		    	for i =  1  , #bug do 
		    		if i == #bug then
		    	 	local spr = cc.Sprite:create("ddz/dizhu_i.png")
		    	 	spr:setAnchorPoint(cc.p(1,1))
		    	 	if spr then 
		    	 		bug[i]:addChild(spr)
		    	 		spr:setPosition(cc.p(153,234))
		    	 	end
		    	 	end
		    	end

	        end

	    else
	        cards = self:emptyCardList(count)
	        for j = 1 , count do
	            local card_node = self.nodePlayer[viewId]:getChildByName("card"..j)
	        	card_node:setVisible(true)
	        	card_node:loadTexture("poker_ddz/"..gt.tonumber(tmp[j])..".png")

	        end

	        if viewId == self:getTableId(m.kZhuang)  then 

	        	local spr = cc.Sprite:create("ddz/dizhu_i.png")
	    	 	spr:setAnchorPoint(cc.p(1,1))
	    	 	if spr then 
	    	 		self.nodePlayer[viewId]:getChildByName("card"..count):addChild(spr)
	    	 		spr:setPosition(cc.p(153,234))
	    	 	end
	        

	        end

	    end
	    self.m_tabNodeCards[viewId]:updateCardsNode(cards, (viewId == gt.MY_VIEWID), false)
		
	    self.bankerViewId = self:getTableId(m.kZhuang)

		local pos = self:getTableId(i-1)
		if pos == self:getTableId(m.kZhuang) then 
			self.m_UserHead[pos].maozi:loadTexture("ddz/dizhu_m.png")
		else
			self.m_UserHead[pos].maozi:loadTexture("ddz/pingmin_m.png")
		end
		self.m_UserHead[pos].score:setString(gt.csw_app_store and "ID:"..m.kUserid[i] or m.kScore[i])
		self.nodePlayer[pos]:setVisible(true)
		self.m_UserHead[pos].maozi:setVisible(true)	
		self.m_UserHead[pos].name:setString(m.kNike[i])
		self.Player[pos].sex = m.kSex[i]
		--kImageUrl
		gt.log("downImage_____________")

		local url 	= m.kImageUrl[i]
		local icon = self.nodePlayer[pos]:getChildByName("icon")
		-- local iamge = gt.imageNamePath(url)
	 --  	if iamge then
		-- 		icon:loadTexture(iamge)
	 --  	else
	 --  		 if type(url) ~= nil and  string.len(url) > 10 then
		--   		local function callback(args)
		--       		if args.done  and self then
		--       			icon:loadTexture(args.image)
		-- 			end
		--         end
		-- 	    gt.downloadImage(url,callback)		
		-- 	end
	 --  	end

	 --  	if self._type == 3 then 
	 --  		local t_node = self.nodePlayer[pos]:getChildByName("t_icon")
	 --  		if m.kTipai[i] == 1 or  m.kTipai[i] == 2 then 
	 --  			t_node:setVisible(true)
	 --  			t_node:loadTexture("ddz/r_t.png")
	 --  		elseif  m.kTipai[i] == 3 then 
	 --  			t_node:setVisible(true)
	 --  			t_node:loadTexture("ddz/r_h.png")
	 --  		else
	 --  			t_node:setVisible(false)
	 --  		end
	 --  	end
		icon:setVisible(false)

	end



end

function playback:onCountChange( count, cardsNode, isOutCard ) -- biandong
    isOutCard = isOutCard or false
    local viewId = cardsNode.m_nViewId
    gt.log("viewId....",viewId)
    local node = self:findNodeByName("r_shegnli_"..viewId)
    if nil ~= self.m_tabCardCount[viewId] then
    	if node then node:setVisible(false) end
    	self.m_tabCardCount[cardsNode.m_nViewId]:setVisible(true)
        self.m_tabCardCount[cardsNode.m_nViewId]:setString(count)
    end

    if count == 0 then 
    	if node then node:setVisible(true) end
    	if viewId ~= 2 then 
    		self.m_tabCardCount[viewId]:setVisible(false)
    	end
    end

    if count <= 2 and nil ~= self.m_tabSpAlarm[viewId] and isOutCard then -- 报警
        -- local param = self:getAnimationParam()
        -- param.m_fDelay = 0.1
        -- param.m_strName = "alarm_key"
        -- local animate = self:getAnimate(param)
        -- local rep = cc.RepeatForever:create(animate)
        -- self.m_tabSpAlarm[viewId]:runAction(rep)
        -- self.m_tabSpAlarm[viewId]:setVisible(true)
        -- -- 音效
        --self:PlaySound( "sound_res/ddz/common_alert.wav" )
    end
end



function playback:emptyCardList(num)

	local buf = {}
	for i = 1, num do
		buf[i] = 0
	end

	return buf
end

function playback:preRound()
	self.quickStartTime = os.time()
	self.curReplayStep = self.curReplayStep - 3 
	if self.curReplayStep <= 0 then self.curReplayStep = 1 end


	local card = {}
	for i = 1 , gt.GAME_PLAYER  do
		self.m_outCardsControl:removeChildByTag(i)
	end
    




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

	self:doAction()

end

function playback:nextRound()
	self.quickStartTime = os.time()
	self.curReplayStep = self.curReplayStep + 3 
	if self.curReplayStep >= #self.data then self.curReplayStep = #self.data end
	for i = 1 , gt.GAME_PLAYER  do
		self.m_outCardsControl:removeChildByTag(i)
	end

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
	self:doAction()
end


function playback:setPause(bool)
	self.isPause = bool
	self.playBtn:setTouchEnabled ( bool)
	self.playBtn:setBright( bool)
	self.pauseBtn:setTouchEnabled(not  bool)
	self.pauseBtn:setBright(not bool)
end


function playback:updateProgress()

	gt.log("------------------------------updateProgress1", self.curReplayStep)
	local amount = #self.data
	if amount == nil or self.curReplayStep == nil then
		return false
	end
	gt.log("------------------------------updateProgress2", amount)
	
	local updateSlider = gt.seekNodeByName(self._node, "Slider_update")
	updateSlider:setLocalZOrder(10)
	updateSlider:setVisible(true)
	local percent = self.curReplayStep/amount*100
	gt.log("---------------percent", percent)
	-- if percent == 100 then 
	-- 	self:findNodeByName("r_shegnli_"..self:getTableId( self.data[#self.data][1] ) ):setVisible(true)
	-- else
	-- 	for i=1,3 do
	-- 		self:findNodeByName("r_shegnli_"..i):setVisible(false)
	-- 	end
	-- end
	updateSlider:setPercent(percent)
end


function playback:update(delta)
	if  self.isPause  then
		return
	end

	if self.curReplayStep == #self.data then  return end

	if os.time() - self.quickStartTime < 1.5 then -- 如果已经有2s没有触摸快进/快退按钮了,那么可以播放自动录像了

		return
	end

	

	self.showDelayTime = self.showDelayTime + delta
	if self.showDelayTime > 1.5 then
		self.showDelayTime = 0
		self.curReplayStep = self.curReplayStep + 1
		if self.curReplayStep >= #self.data then 
			self.curReplayStep = #self.data
		end
		gt.log("_________________________?")
		self:doAction()
	end
end

function playback:onNodeEvent(eventName)
	if "enter" == eventName then
		-- local listener = cc.EventListenerTouchOneByOne:create()
		-- listener:setSwallowTouches(true)
		-- listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		-- local eventDispatcher = self:getEventDispatcher()
		-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)



		-- 逻辑更新定时器
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		---eventDispatcher:removeEventListenersForTarget(self)

		for i =1 , #gt.poker_node do
	        cc.Director:getInstance():getTextureCache():removeTextureForKey(gt.poker_node[i]) 
	        cc.Director:getInstance():getTextureCache():removeTextureForKey(gt.poker_node1[i]) 
	    end

		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end



-- 出牌效果
-- @param[outViewId]        出牌视图id
-- @param[outCards]         出牌数据
-- @param[vecCards]         扑克精灵
function playback:outCardEffect(outViewId, outCards, vecCards,cards,buf)

	local controlSize = self.m_outCardsControl:getContentSize()

    -- 移除出牌
    self.m_outCardsControl:removeChildByTag(outViewId)
    local holder = cc.Node:create()
    self.m_outCardsControl:addChild(holder)
    holder:setTag(outViewId)

   -- self:compareWithLastCards(outCards, outViewId,self._type)

    local outCount = #outCards
    -- 计算牌型
	local cardType = -1
    local qulaier = {}
    local _ = 0






    qulaier,_ = GameLaiziLogic:GetCardType1(outCards,outCount,self._type)
    for k ,v in pairs(qulaier) do
        cardType = k 
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
        targetPos = holder:convertToNodeSpace(cc.p(controlSize.width * 0.5, controlSize.height * 0.42+65))
    elseif 1 == outViewId then
        center = 0
        holder:setAnchorPoint(cc.p(0, 0.5))
        targetPos = holder:convertToNodeSpace(cc.p(controlSize.width * 0.33-20, controlSize.height * 0.58+75))
    elseif 3 == outViewId then
        center = outCount
        holder:setAnchorPoint(cc.p(1, 0.5))
        targetPos = holder:convertToNodeSpace(cc.p(controlSize.width * 0.67+20, controlSize.height * 0.58+75))
    end
    log("vecCards______________",#vecCards)
    for k,v in pairs(vecCards) do
    	-- log("c____")
     --    v:retain()
     --    v:removeFromParent()
     --    holder:addChild(v)
     --    v:release()

     --    v:showCardBack(false)
     --    local pos = cc.p((k - center) * CardsNode.CARD_X_DIS * scale + targetPos.x, targetPos.y)
     --    gt.log(pos.x,pos.y)
     --    local moveTo = cc.MoveTo:create(0.3, pos)
     --    local spa = cc.Spawn:create(moveTo, cc.ScaleTo:create(0.3, scale))
     --    v:stopAllActions()
     --    v:runAction(spa)

     	v:retain()
        v:removeFromParent()
        holder:addChild(v)
        v:release()

        v:showCardBack(false)
        local pos = cc.p((k - center) * CardsNode.CARD_X_DIS * scale + targetPos.x, targetPos.y)
        gt.log(pos.x,pos.y)
        local moveTo = cc.MoveTo:create(0.2, pos)
        local spa = cc.Spawn:create(moveTo , cc.Sequence:create(cc.ScaleTo:create(0.05, 2),cc.ScaleTo:create(0.15, scale) ,cc.DelayTime:create(0.2) ,cc.CallFunc:create(function()

        		-- if k == 1 then 
        		-- 	self:PlaySound("sound_res/ddz/push_card.mp3")
        		-- end

        	end) , cc.DelayTime:create(0.1), cc.CallFunc:create(function()

       --  		if k == #vecCards then 
       --  			if GameLogic.CT_SINGLE == cardType then
				   --      -- 音效
				   --      local poker = yl.POKER_VALUE[outCards[1]]
				   --      if nil ~= poker then
				   --        self:_playSound(outViewId,poker .. ".mp3") 
				   --      end
				   --  elseif GameLogic.CT_DOUBLE == cardType then

				   --      local poker = yl.POKER_VALUE[outCards[1]]
				   --      if nil ~= poker then
				   --           self:_playSound(outViewId,poker .. "_.mp3") 
				   --      end
				   --  else
			     
			    --         -- 音效
			    --       --  if cardType == 5  or cardType == 12 then 
			    --         --	self:_playSound(outViewId, "type" .. cardType .. ".wav")
			    --       --  else
			    --         	self:_playSound(outViewId, "type" .. cardType .. ".mp3")
			    --     	--end
			    --     end

			    -- end
			    if k == #vecCards then 
        			self:PlaySound("sound_res/ddz/push_card.mp3")
        		end

        	end)))
        v:stopAllActions()
        v:runAction(spa)

        log("vvvvvv",v,#vecCards)

    	if self.bankerViewId == outViewId  and k == #vecCards then 
    		v:removeAllChildren()	
    	 	local spr = cc.Sprite:create("ddz/dizhu_i.png")
    	 	spr:setAnchorPoint(cc.p(1,1))
    	 	if spr then 
    	 		v:addChild(spr)
    	 		spr:setPosition(cc.p(153,234))
    	 	end
    	end

	end


	for x = 1 ,gt.GAME_PLAYER do
		local id = self:getTableId(x-1)
		local card = cards[x]
		if id == 1 then 
	        for j = 1 , 21 do
	            local card_node = self.nodePlayer[id]:getChildByName("card"..j)
	        	card_node:setVisible(false)
	        	
	        end
	       
	        gt.log("card_____________________",#card)
	        for i = 1 , #card do
	        	local card_node = self.nodePlayer[id]:getChildByName("card"..i)
	        	card_node:setVisible(true)
	        	card_node:loadTexture("poker_ddz/"..gt.tonumber(card[i])..".png")
	        	if self.bankerViewId == id and i == #card then 
	        		local spr = cc.Sprite:create("ddz/dizhu_i.png")
		    	 	spr:setAnchorPoint(cc.p(1,1))
		    	 	if spr then 
		    	 		card_node:addChild(spr)
		    	 		spr:setPosition(cc.p(153,234))
		    	 	end
	        	end
	        end
	        local cards = self:emptyCardList(#card)
	        self.m_tabNodeCards[id]:updateCardsNode(cards, (id == gt.MY_VIEWID), false)      
	    elseif id == 2 then 
	    	gt.log("card_____________________2",#card)
	       	self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:removeAllChildren()
	       	local cards = GameLogic:SortCardList(card, #card, 0)
	       	self.m_tabNodeCards[id]:updateCardsNode(cards, (id == gt.MY_VIEWID), false)

	        if self.bankerViewId == id then 
    			local bug = self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:getChildren()
		    	for i =  1  , #bug do 
		    		if i == #bug then
		    	 	local spr = cc.Sprite:create("ddz/dizhu_i.png")
		    	 	spr:setAnchorPoint(cc.p(1,1))
		    	 	if spr then 
		    	 		bug[i]:addChild(spr)
		    	 		spr:setPosition(cc.p(153,234))
		    	 	end
		    	 	end
		    	end
	        end
	    elseif id == 3 then
    		for j = 1 , 21 do
	            local card_node = self.nodePlayer[id]:getChildByName("card"..j)
	        	card_node:setVisible(false)
	        	
	        end
	        gt.log("card_____________________3",#card)
	        for i = 1 , #card do
	        	local card_node = self.nodePlayer[id]:getChildByName("card"..i)
	        	card_node:setVisible(true)
	        	card_node:loadTexture("poker_ddz/"..gt.tonumber(card[i])..".png")
	        	if self.bankerViewId == id and i == #card then 
	        		local spr = cc.Sprite:create("ddz/dizhu_i.png")
		    	 	spr:setAnchorPoint(cc.p(1,1))
		    	 	if spr then 
		    	 		card_node:addChild(spr)
		    	 		spr:setPosition(cc.p(153,234))
		    	 	end
	        	end

	        end
	        local cards = self:emptyCardList(#card)
	        self.m_tabNodeCards[id]:updateCardsNode(cards, (id == gt.MY_VIEWID), false)
	    end
	end

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


    log("## 出牌类型")
    log(cardType)
    log("## 出牌类型")
 

    -- 牌型音效
    local bCompare = false
    if GameLogic.CT_SINGLE == cardType then
        --音效
        local poker = yl.POKER_VALUE[outCards[1]]
        if nil ~= poker then
          self:_playSound(outViewId,poker .. ".mp3") 
        end 
    elseif GameLogic.CT_DOUBLE == cardType then

        local poker = yl.POKER_VALUE[outCards[1]]
        if nil ~= poker then
             self:_playSound(outViewId,poker .. "_.mp3") 
        end
    else
       
            -- 音效
           
        			if GameLogic.CT_SINGLE == cardType then
				        -- 音效
				        local poker = yl.POKER_VALUE[outCards[1]]
				        if nil ~= poker then
				          self:_playSound(outViewId,poker .. ".mp3") 
				        end
				    elseif GameLogic.CT_DOUBLE == cardType then

				        local poker = yl.POKER_VALUE[outCards[1]]
				        if nil ~= poker then
				             self:_playSound(outViewId,poker .. "_.mp3") 
				        end
				    else
			     
			            -- 音效
			          --  if cardType == 5  or cardType == 12 then 
			            --	self:_playSound(outViewId, "type" .. cardType .. ".wav")
			          --  else
			            	self:_playSound(outViewId, "type" .. cardType .. ".mp3")
			        	--end
			        end

	
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




    -- 牌型动画/牌型音效
    if GameLogic.CT_THREE_LINE == cardType then             -- 飞机
   
        self:PlaySound("sound_res/ddz/common_plane.mp3")
        self.___node = cc.CSLoader:createTimeline("plane.csb")	
        self.plane:runAction(self.___node)
        self.plane:setVisible(true)
        self.___node:gotoFrameAndPlay(0,false)
    elseif GameLogic.CT_BOMB_CARD == cardType then          -- 炸弹

        self:PlaySound( "sound_res/ddz/common_bomb.mp3" ) 
        
        self.___node = cc.CSLoader:createTimeline("bomb.csb")	
        self.bomb:runAction(self.___node)
        self.bomb:setVisible(true)
        self.___node:gotoFrameAndPlay(0,false)
    elseif GameLogic.CT_MISSILE_CARD == cardType then       -- 火箭

   
        self:PlaySound("sound_res/ddz/common_bomb.mp3")
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

    self:updateProgress()
end


function playback:_playSound(id,str)

	if self.Player[id].sex == 2 then
		self:PlaySound("sound_res/ddz/w/"..str)
	else
		self:PlaySound("sound_res/ddz/m/"..str)
	end
end

function playback:PlaySound(path)
	if path then 
		gt.soundEngine:Poker_playEffect(path,false)
	end
end

-- 扑克对比
-- @param[cards]        当前出牌
-- @param[outView]      出牌视图id
function playback:compareWithLastCards( cards, outView,landType)
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

--[[
	
	 29 = {
     1 = 1 -- 位置
     2 = 0 -- 0 不出 1 出牌
     3 = 0 -- 倍数（非临汾没用）
     4 = { -- 出牌 牌值
     }
 }
]]
function playback:doAction(num)

	if not self.data then return  end

	if not self.data[self.curReplayStep] then return end
	local m = self.data[self.curReplayStep]
	local pos = self:getTableId(m[1])
	self.call_score[pos]:setVisible(false)
	if m[2] == 1 and #m[4] > 0 then 




	    if self.curReplayStep == 1 then 
	    	local outViewId = pos

    		if outViewId == 2 then 
    				local card = {}
    				for i = 1, #m[4] do
    					table.insert(card,m[4][i])
    				end
    				for i = 1, #m[5][m[1]+1] do
    					table.insert(card,m[5][m[1]+1][i])
    				end

    				gt.log("card_____________________dddddddddddddddddddddddd2",#card)
			       	self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:removeAllChildren()
			       	local cards = GameLogic:SortCardList(card, #card, 0)
			       	self.m_tabNodeCards[outViewId]:updateCardsNode(cards, (outViewId == gt.MY_VIEWID), false)

			        if self.bankerViewId == outViewId then 
		    			local bug = self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:getChildren()
				    	for i =  1  , #bug do 
				    		if i == #bug then
				    	 	local spr = cc.Sprite:create("ddz/dizhu_i.png")
				    	 	spr:setAnchorPoint(cc.p(1,1))
				    	 	if spr then 
				    	 		bug[i]:addChild(spr)
				    	 		spr:setPosition(cc.p(153,234))
				    	 	end
				    	 	end
				    	end
			        end


    		elseif outViewId == 1 or outViewId == 3 then 
    				local card = {}
    				for i = 1, #m[4] do
    					table.insert(card,m[4][i])
    				end
    				for i = 1, #m[5][m[1]+1] do
    					table.insert(card,m[5][m[1]+1][i])
    				end
    				for j = 1 , 21 do
			            local card_node = self.nodePlayer[outViewId]:getChildByName("card"..j)
			        	card_node:setVisible(false)
			        	
			        end
			       
			        gt.log("card_____________________dddddddddddddddddddddddddd",#card)
			        for i = 1 , #card do
			        	local card_node = self.nodePlayer[outViewId]:getChildByName("card"..i)
			        	card_node:setVisible(true)
			        	card_node:loadTexture("poker_ddz/"..gt.tonumber(card[i])..".png")
			        	if self.bankerViewId == outViewId and i == #card then 
			        		local spr = cc.Sprite:create("ddz/dizhu_i.png")
				    	 	spr:setAnchorPoint(cc.p(1,1))
				    	 	if spr then 
				    	 		card_node:addChild(spr)
				    	 		spr:setPosition(cc.p(153,234))
				    	 	end
			        	end
			        end
			        local cards = self:emptyCardList(#card)
			        self.m_tabNodeCards[outViewId]:updateCardsNode(cards, (outViewId == gt.MY_VIEWID), false)      
    		end
	   
		end


		local vec = self.m_tabNodeCards[pos]:outCard(m[4],false)
		self:outCardEffect(pos, m[4], vec,m[5],m[5][m[1]+1])

	else
		self:_playSound(pos,"pass" .. math.random(0, 1) .. ".mp3")
		self.call_score[pos]:setVisible(true)
		self.m_outCardsControl:removeChildByTag(pos)
	end

	if self._type == 3 and m[3] then 
		local node = self:findNodeByName("game_info")
		self:findNodeByName("t2",node):setString("倍数:"..m[3])
	end

end

function playback:addCard(_tpye) -- bug  未完



	if self.curReplayStep <= 3 then 

		if _tpye == 1 then 

			for x = 1 ,gt.GAME_PLAYER do
				if x == 1 then 
			        for j = 1 , 21 do
			            local card_node = self.nodePlayer[x]:getChildByName("card"..j)
			        	card_node:setVisible(false)
			        	
			        end
			        local card = self.card_buf[1]
			        gt.log("card_____________________",#card)
			        for i = 1 , #card do
			        	local card_node = self.nodePlayer[x]:getChildByName("card"..i)
			        	card_node:setVisible(true)
			        	card_node:loadTexture("poker_ddz/"..gt.tonumber(card[i])..".png")
			        	if self.bankerViewId == x and i == #card then 
			        		local spr = cc.Sprite:create("ddz/dizhu_i.png")
				    	 	spr:setAnchorPoint(cc.p(1,1))
				    	 	if spr then 
				    	 		card_node:addChild(spr)
				    	 		spr:setPosition(cc.p(153,234))
				    	 	end
			        	end
			        end
			        local cards = self:emptyCardList(#card)
			        self.m_tabNodeCards[x]:updateCardsNode(cards, (x == gt.MY_VIEWID), false)
			       
			    elseif x == 2 then 
		    		local card = self.card_buf[2]
			       	self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:removeAllChildren()
			       	local cards = GameLogic:SortCardList(card, #card, 0)
			       	self.m_tabNodeCards[x]:updateCardsNode(cards, (x == gt.MY_VIEWID), false)

			        if self.bankerViewId == x then 
		    			local bug = self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:getChildren()
				    	for i =  1  , #bug do 
				    		if i == #bug then
				    	 	local spr = cc.Sprite:create("ddz/dizhu_i.png")
				    	 	spr:setAnchorPoint(cc.p(1,1))
				    	 	if spr then 
				    	 		bug[i]:addChild(spr)
				    	 		spr:setPosition(cc.p(153,234))
				    	 	end
				    	 	end
				    	end
			        end
				      
			    elseif x == 3 then
		    		local card = self.card_buf[3]
		    		for j = 1 , 21 do
			            local card_node = self.nodePlayer[x]:getChildByName("card"..j)
			        	card_node:setVisible(false)
			        	
			        end

			        for i = 1 , #card do
			        	local card_node = self.nodePlayer[x]:getChildByName("card"..i)
			        	card_node:setVisible(true)
			        	card_node:loadTexture("poker_ddz/"..gt.tonumber(card[i])..".png")
			        	if self.bankerViewId == x and i == #card then 
			        		local spr = cc.Sprite:create("ddz/dizhu_i.png")
				    	 	spr:setAnchorPoint(cc.p(1,1))
				    	 	if spr then 
				    	 		card_node:addChild(spr)
				    	 		spr:setPosition(cc.p(153,234))
				    	 	end
			        	end

			        end
			        local cards = self:emptyCardList(#card)
			        self.m_tabNodeCards[x]:updateCardsNode(cards, (x == gt.MY_VIEWID), false)
				end
			end
		else
			local buf = {}
			for i = 1 , self.curReplayStep do
				local t = self.data[i]
				buf[self:getTableId(t[1])] = t[5]
			end



		end
	else
		local buf = {}
		for i = self.curReplayStep - 2 , self.curReplayStep do
			local t = self.data[i]
			buf[self:getTableId(t[1])] = t[5]
		end
		for x = 1 ,gt.GAME_PLAYER do
			if x == 1 then 
		        for j = 1 , 21 do
		            local card_node = self.nodePlayer[x]:getChildByName("card"..j)
		        	card_node:setVisible(false)
		        	
		        end
		        local card = buf[1]
		        gt.log("card_____________________",#card)
		        for i = 1 , #card do
		        	local card_node = self.nodePlayer[x]:getChildByName("card"..i)
		        	card_node:setVisible(true)
		        	card_node:loadTexture("poker_ddz/"..gt.tonumber(card[i])..".png")
		        	if self.bankerViewId == x and i == #card then 
		        		local spr = cc.Sprite:create("ddz/dizhu_i.png")
			    	 	spr:setAnchorPoint(cc.p(1,1))
			    	 	if spr then 
			    	 		card_node:addChild(spr)
			    	 		spr:setPosition(cc.p(153,234))
			    	 	end
		        	end
		        end
		        local cards = self:emptyCardList(#card)
		        self.m_tabNodeCards[x]:updateCardsNode(cards, (x == gt.MY_VIEWID), false)
		       
		    elseif x == 2 then 
	    		local card = buf[2]
		       	self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:removeAllChildren()
		       	local cards = GameLogic:SortCardList(card, #card, 0)
		       	self.m_tabNodeCards[x]:updateCardsNode(cards, (x == gt.MY_VIEWID), false)

		        if self.bankerViewId == x then 
	    			local bug = self.m_tabNodeCards[gt.MY_VIEWID].m_cardsHolder:getChildren()
			    	for i =  1  , #bug do 
			    		if i == #bug then
			    	 	local spr = cc.Sprite:create("ddz/dizhu_i.png")
			    	 	spr:setAnchorPoint(cc.p(1,1))
			    	 	if spr then 
			    	 		bug[i]:addChild(spr)
			    	 		spr:setPosition(cc.p(153,234))
			    	 	end
			    	 	end
			    	end
		        end
			      
		    elseif x == 3 then
	    		local card = buf[3]
	    		for j = 1 , 21 do
		            local card_node = self.nodePlayer[x]:getChildByName("card"..j)
		        	card_node:setVisible(false)
		        	
		        end

		        for i = 1 , #card do
		        	local card_node = self.nodePlayer[x]:getChildByName("card"..i)
		        	card_node:setVisible(true)
		        	card_node:loadTexture("poker_ddz/"..gt.tonumber(card[i])..".png")
		        	if self.bankerViewId == x and i == #card then 
		        		local spr = cc.Sprite:create("ddz/dizhu_i.png")
			    	 	spr:setAnchorPoint(cc.p(1,1))
			    	 	if spr then 
			    	 		card_node:addChild(spr)
			    	 		spr:setPosition(cc.p(153,234))
			    	 	end
		        	end

		        end
		        local cards = self:emptyCardList(#card)
		        self.m_tabNodeCards[x]:updateCardsNode(cards, (x == gt.MY_VIEWID), false)
			end
		end
	end

end

return playback