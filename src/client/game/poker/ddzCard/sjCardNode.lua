--

--
local sjCardSprite = gt.include("ddzCard.sjCardSprite")
local GamesjLogic = gt.include("ddzCard.GamesjLogic")


local CARD_X_POS = 0
--横向间隔
local CARD_X_DIS = 48 -- 56
--纵向间隔
local CARD_Y_DIS = 25

local ANI_BEGIN = 0.3 -- 发牌等待时间
--弹出动画
local CARD_SHOOT_TIME = 0.2
--弹回动画
local CARD_BACK_TIME = 0.2
--弹出距离
local CARD_SHOOT_DIS = 20
--最低叠放层级
local MIN_DRAW_ORDER = 0
--最高叠放层级
local MAX_DRAW_ORDER = 20
--过滤模式
local kHIGHEST = 1
local kLOWEST = 2
--拖动方向
local kMoveNull = 0
local kMoveToLeft = 1
local kMoveToRight = 2
-- 自己扑克尺寸
local CARD_SHOW_SCALE = 1
-- 非自己扑克尺寸
local CARD_HIDE_SCALE = 0.45
-- 亮牌尺寸
local CARD_LEFT_SCALE = 0.5





local function ANI_RATE( var )
	return var * ANI_BEGIN
end

local sjCardNode = class("sjCardNode", cc.Node)
sjCardNode.CARD_X_DIS = CARD_X_DIS
sjCardNode.CARD_Y_DIS = CARD_Y_DIS

function sjCardNode:ctor()

	--扑克管理
	self.m_mapCard = {}
	self.m_vecCard = {}
	--扑克数据
	self.m_cardsData = {}
	self.m_cardsHolder = nil

	--视图id
	self.m_nViewId = 21
	--是否可点击
	self.m_bClickable = false
	--是否发牌
	self.m_bDispatching = false
	--提示出牌
	self.m_bSuggested = false

	------
	-- 扑克操控

	--开始点击位置
	self.m_beginTouchPoint = cc.p(0,0)
	--开始点击选牌
	self.m_beginSelectCard = nil
	--结束点击选牌
	self.m_endSelectCard = nil
	--是否拖动
	self.m_bDragCard = false
	--是否触摸
	self.m_bTouched = false
	--拖动方向
	self.m_dragMoveDir = kMoveNull

	--选牌管理
	self.m_mapSelectedCards = {}
	--拖动选择
	self.m_mapDragSelectCards = {}
	--选择扑克
	self.m_tSelectCards = {}

	--回调监听
	self.m_pSelectedListener = nil
	-- 扑克操控
	------

	if gt.SCENE_TYPE == "VIDEO" then 
		CARD_SHOW_SCALE = 0.7
		CARD_HIDE_SCALE = 0.38
		-- CARD_X_DIS = 66
		-- sjCardNode.CARD_X_DIS = CARD_X_DIS 
	else
		CARD_SHOW_SCALE = 1
		CARD_HIDE_SCALE = 0.45
		yl.registerTouchEvent(self)
	end
	

end

function sjCardNode:createEmptysjCardNode(viewId)
	local node = sjCardNode.new()
	if nil ~= node and node:init() then

		node.m_nViewId = viewId
		node.m_bClickable = (viewId == gt.MY_VIEWID)
		node:addCardsHolder()

		return node
	end
	return nil
end


function sjCardNode:setListener( pNode )
	self.m_pSelectedListener = pNode
end

function sjCardNode:onExit()
	self:removeAllCards()

	self.m_pSelectedListener = nil
end


function sjCardNode:onTouchBegan(touch, event)
	if false == self:isVisible() or false == self.m_bClickable or true == self.m_bDispatching  then
		return false
	end
	local location = touch:getLocation()

	self.m_endSelectCard = nil
	self.m_bDragCard = false
	self.m_beginTouchPoint = self:convertToNodeSpace(location)
	self.m_beginSelectCard = self:filterCard(kHIGHEST, location)
	if nil ~= self.m_beginSelectCard 
		and nil ~= self.m_beginSelectCard.getCardData then
		--选牌效果
		gt.soundEngine:Poker_playEffect("sound_res/ddz/touch_my_card.wav")
		self.m_beginSelectCard:showSelectEffect(true)
		gt.log("getCardData,,,,,,,,,,,,,",self.m_beginSelectCard:getCardData())
		self.m_mapSelectedCards[self.m_beginSelectCard:getCardData()] = self.m_beginSelectCard
	
	end
	self.m_bTouched = (self.m_beginSelectCard ~= nil)
	return true
end

function sjCardNode:onTouchMoved(touch, event)
	if true == self.m_bTouched then
		local location = touch:getLocation()

		self.m_endSelectCard = self:filterCard(kHIGHEST, location)
		self.m_bDragCard = true
		local touchRect = self:makeTouchRect(self:convertToNodeSpace(location))

		--筛选在触摸区域内的卡牌
		local mapTouchCards = self:inTouchAreaCards(touchRect)

		--过滤有效卡牌,选择叠放最高
		if type(mapTouchCards) ~= "table" or 0 == table.nums(mapTouchCards) then
			return
		end

		if nil ~= self.m_endSelectCard 
			and nil ~= self.m_endSelectCard.getCardData then			
			--拖动选择
			if false == self.m_endSelectCard:getCardDragSelect() then
				self.m_endSelectCard:showSelectEffect(true)
				self.m_endSelectCard:setCardDragSelect(true)
				if nil ~= self.m_beginSelectCard and self.m_beginSelectCard:getCardData() ~= self.m_endSelectCard:getCardData() then
					self.m_mapDragSelectCards[self.m_endSelectCard:getCardData()] = self.m_endSelectCard
				end
			end
		end

		--剔除不在触摸区域内，但已选择的卡牌
		for k,v in pairs(self.m_mapDragSelectCards) do
			local tmpCard = mapTouchCards[k]
			if nil == tmpCard then
				self.m_mapDragSelectCards[k]:setCardDragSelect(false)
				self.m_mapDragSelectCards[k]:showSelectEffect(false)
				self.m_mapDragSelectCards[k] = nil
			end
		end	
	end
end

function sjCardNode:select_card_effect(clour)

	--if 1 == 1 then return end



	if not clour then 
		for k , y in pairs(self.m_mapCard) do
			if y then 
				y:getChildByTag(4):setVisible(false)
			end
		end
	elseif type(clour) == "table" then 
		if #clour == 0 then return end
		local idx = {}
		for i = 1 ,#self.m_cardsData do
			if GamesjLogic:GetCardColors(self.m_cardsData[i]) == GamesjLogic:GetCardColors(clour[1])  then 
				table.insert(idx,self.m_cardsData[i])
			end
		end

		for k , y in pairs(self.m_mapCard) do
			if y then 
				y:getChildByTag(4):setVisible(false)
			end
		end


		for k , y in pairs(self.m_mapCard) do
			if y and not tolua.isnull(y) and y.setCardShoot then 
				y:setCardShoot(true)
			end
		end
		self.m_mapSelectedCards = {}
		self.m_mapDragSelectCards = {}
		self:dragCards(self.m_mapCard)

		if #idx >= #clour then -- 等于唯一可出
			for i = 1 ,#self.m_cardsData do
				if GamesjLogic:GetCardColors(self.m_cardsData[i]) ~= GamesjLogic:GetCardColors(clour[1])  then 
					local card = self.m_mapCard[self.m_cardsData[i]]
					if card then card:getChildByTag(4):setVisible(true)  end
					card = self.m_mapCard[ self.m_cardsData[i] >100 and self.m_cardsData[i]-100 or self.m_cardsData[i] + 100]
					if card then card:getChildByTag(4):setVisible(true)  end
				end
			end

			if #idx == #clour then 
				gt.dump(idx)
				self:suggestShootCards(idx)
			end



		elseif #idx ~= 0 then
			self:suggestShootCards(idx)
		end
	end

end

function sjCardNode:onTouchEnded(touch, event)
	if true == self.m_bTouched then
		local location = touch:getLocation()

		self.m_endSelectCard = self:filterCard(kHIGHEST, location)


		if false == self.m_bDragCard then
			if nil ~= self.m_endSelectCard 
				and nil ~= self.m_endSelectCard.getCardData then
				self.m_endSelectCard:setCardDragSelect(true)

				if nil ~= self.m_beginSelectCard
					and nil ~= self.m_beginSelectCard.getCardData
					and self.m_beginSelectCard:getCardData() ~= self.m_endSelectCard:getCardData() then
					self.m_mapSelectedCards[self.m_endSelectCard:getCardData()] = self.m_endSelectCard

				end
			end
			
		end

		--选牌效果
		if nil ~= self.m_beginSelectCard then
			self.m_beginSelectCard:showSelectEffect(false)
		end

	end

	if not self.m_bTouched then 
		local bool = false
		for k , y in pairs(self.m_mapCard) do
			if y and not tolua.isnull(y) and y.setCardShoot then 
				y:setCardShoot(true)
			end
			bool = true
		end
		if bool then 
			self.m_mapSelectedCards = {}
			self.m_mapDragSelectCards = {}
			self:dragCards(self.m_mapCard)
		end
		
	else

		local vecSelectCard = self:filterDragSelectCards(self.m_bTouched)

		self:dragCards(vecSelectCard)

	end

	-- if true == self.m_bSuggested then
	-- 	self.m_bSuggested = (0 ~= table.nums(self.m_mapSelectedCards))
	-- end
	self.m_beginSelectCard = nil
    self.m_endSelectCard = nil
    self.m_bDragCard = false
    self.m_bTouched = false



end




function sjCardNode:onTouchCancelled(touch, event)
end

-- 更新
-- @param[cards] 新的扑克数据
-- @param[isShowCard] 是否显示正面
-- @param[bAnimation] 是否动画效果
-- @param[pCallBack] 更新回调
function sjCardNode:updatesjCardNode( cards, isShowCard, bAnimation, pCallBack) -- ppp
	if type(cards) ~= "table"  then
		return
	end



	local m_cardsData = cards
	local m_cardCount = #cards
	bAnimation = bAnimation or false
	isShowCard = isShowCard or false

	if 0 == m_cardCount then
		gt.log("count = 0")
		return
	end	

	self.off_line = false

	self.m_bAddCards = false
	self.m_bDispatching = true

	self:removeAllCards()
	self:reSetCards()
	self.m_cardsData = m_cardsData
	self.m_cardsCount = m_cardCount
	--print("cars......."..self.m_cardsCount)
	self.m_bShowCard = isShowCard

	--转换为相对于自己的中间位置
	local winSize = cc.Director:getInstance():getWinSize()
	local centerPos = cc.p(winSize.width * 0.5, 0)

	centerPos = cc.p(self:convertToNodeSpace(centerPos).x,0)
	

	local mapKey = 0
	local m_cardsHolder = self.m_cardsHolder

	-- if 1 == self.m_nViewId then
	-- 	toPos = self:convertToNodeSpace(cc.p(winSize.width * 0.3, winSize.height * 0.5))
	-- elseif 2 == self.m_nViewId then
	-- 	toPos = self:convertToNodeSpace(cc.p(winSize.width * 0.7, winSize.height * 0.5))
	-- end

	--创建扑克

	for i = 1, m_cardCount do
		local tmpSp = sjCardSprite:createCard(m_cardsData[i])
		m_cardsHolder:addChild(tmpSp)
		mapKey = m_cardsData[i]
		tmpSp:setPosition(centerPos)
		tmpSp:setDispatched(false)
		tmpSp:showCardBack(true)		
		self.m_mapCard[mapKey] = tmpSp
	end

	--运行动画
	if ((3 == self.m_nViewId) or (1 == self.m_nViewId) or (gt.MY_VIEWID == self.m_nViewId)) and (true == bAnimation) then
		self:arrangeAllCards(bAnimation, pCallBack)
	else
		self:arrangeAllCards(bAnimation, pCallBack)
	end
end



-- 加牌
function sjCardNode:addCards( addCards, handCards )
	if type(addCards) ~= "table"  then
		return
	end

	--gt.log("addcards>>>>>>",#addCards)

	local tmpcount = #handCards
	self.m_cardsData = handCards	
	if tmpcount > 25 then
		print("超出最大牌数")
		return
	end

	gt.dump(self.m_mapCard)

	--转换为相对于自己的中间位置
	local winSize = cc.Director:getInstance():getWinSize()
	local centerPos = cc.p(winSize.width * 0.5, winSize.height * 0.4)
	centerPos = self:convertToNodeSpace(centerPos)
	local mapKey
	for i = 1, #addCards do
		local tmpSp = sjCardSprite:createCard(addCards[i])
		tmpSp:setPosition(centerPos)
		tmpSp:setDispatched(false)
		tmpSp:showCardBack(true)
		self.m_cardsHolder:addChild(tmpSp)
		
		mapKey = addCards[i]
		
		gt.log("mapKey.....",mapKey)
		if not self.m_mapCard[mapKey] then
			self.m_mapCard[mapKey] = tmpSp
		else
			if mapKey >= 100 then 
				self.m_mapCard[mapKey-100] = tmpSp
			else
				self.m_mapCard[mapKey+100] = tmpSp
			end
		end
	end


	self:reSortCards()
	self.m_cardsCount = tmpcount
	

	
end

function sjCardNode:getSprCard()
	return self.m_mapCard
end

function sjCardNode:bDispatching()
	if not self.m_bDispatching then 
		local carddatas  = GamesjLogic:SortCardList(self.m_cardsData, #self.m_cardsData)

		local buf = self:sort(carddatas)

		local cen = math.ceil(#buf/2)
		local winSize = cc.Director:getInstance():getWinSize()
		local p = self:convertToNodeSpace(cc.p(winSize.width * 0.5, 0)) 
		for x = 1 , #buf do
			local pos = cc.p(p.x+(x - cen) * CARD_X_DIS,0)
			local tmpcard = self.m_mapCard[buf[x]]
			tmpcard:setLocalZOrder(x)
			tmpcard:setPosition(pos)
		end
		if nil ~= self.m_pSelectedListener and nil ~= self.m_pSelectedListener.renovate_huase then
			self.m_pSelectedListener:renovate_huase(buf)
		end
	end
end

-- 出牌
-- @param[cards] 	 	出牌
-- @param[bNoSubCount]	不减少牌数
-- @return 需要移除的牌精灵
function sjCardNode:outCard( cards, bNoSubCount )
	bNoSubCount = bNoSubCount or false
	if type(cards) ~= "table"  then
		return
	end

	cards = self:sort(cards)
	local vecOut = {}
	local outCount = #cards
	local handCount = self.m_cardsCount
	local m_cardsHolder = self.m_cardsHolder

	local bOutOk = false
	local haveCardData = self.m_nViewId == gt.MY_VIEWID

	if 0 ~= handCount and haveCardData then
		
		self.m_bDispatching = true
		for k,v in pairs(cards) do
            local removeIdx = nil
            for k1,v1 in pairs(self.m_cardsData) do            
                if v == v1 then
                    removeIdx = k1
                end
            end
            if nil ~= removeIdx then
                table.remove(self.m_cardsData, removeIdx)
            else
            	for k1,v1 in pairs(self.m_cardsData) do            
	                if v == v1+100 then
	                    removeIdx = k1
	                end
	            end
	            if nil ~= removeIdx then
                	table.remove(self.m_cardsData, removeIdx)
                else
                	for k1,v1 in pairs(self.m_cardsData) do            
		                if v == v1 - 100 then
		                    removeIdx = k1
		                end
		            end
		            if nil ~= removeIdx then
                		table.remove(self.m_cardsData, removeIdx)
                	end
            	end
            end
        end
        self.m_cardsCount = #self.m_cardsData


		for i = 1, outCount do
			local tag = cards[i]
			local tmpSp = m_cardsHolder:getChildByTag(tag)

			if nil ~= tmpSp then
				table.insert(vecOut, tmpSp)
			else
				if tag >= 100 then
					tag = tag-100
					local tmpSp = m_cardsHolder:getChildByTag(tag)
					if nil ~= tmpSp then
						table.insert(vecOut, tmpSp)
					end
				elseif tag < 100 then 
					tag = tag+100
					local tmpSp = m_cardsHolder:getChildByTag(tag)
					if nil ~= tmpSp then
						table.insert(vecOut, tmpSp)
					end
				end
			end
			--if tag > 100 then tag = tag - 100 end
			gt.log("tag..........",tag)
			self.m_mapCard[tag] = nil
		end
		bOutOk = true
		self:reSortCards(self.m_cardsCount)
		
	end

	if not bOutOk then
		for i = 1, outCount do
			local cbCardData = cards[i] or 0
			local tmpSp = sjCardSprite:createCard(cbCardData)
			tmpSp:setPosition(CARD_X_DIS, 0)
			tmpSp:showCardBack(true)
			m_cardsHolder:addChild(tmpSp)
			table.insert(vecOut, tmpSp)
		end
	end

	--清除选中
	for k,v in pairs(self.m_mapSelectedCards) do 
		v:showSelectEffect(false)
		v:setCardDragSelect(false)
		v:setPositionY(0)
		
	end
	for k,v in pairs(self.m_mapDragSelectCards) do 
		v:showSelectEffect(false)
		v:setCardDragSelect(false)
		v:setPositionY(0)

	end

	for k , y in pairs(self.m_mapCard) do
		if y and not tolua.isnull(y) and y.setCardShoot then 
			y:setCardShoot(true)
		end
	end

	self.m_mapSelectedCards = {}
	self.m_mapDragSelectCards = {}
	self:dragCards(self.m_mapCard)
	self.m_tSelectCards = {}
	self.m_bSuggested = false




	return vecOut
end



-- 结算显示
-- @param[cards] 实际扑克数据
function sjCardNode:showLeftCards( cards )

end

function sjCardNode:reSet()
	self:dragCards(self:filterDragSelectCards(false))
end

-- 重置
function sjCardNode:reSetCards(bool)
	self.m_beginSelectCard = nil
	self.m_endSelectCard = nil

	self:dragCards(self:filterDragSelectCards(false))
	self.m_mapSelectedCards = {}
	self.m_mapDragSelectCards = {}

	self.m_bSuggested = false
end

-- 提示弹出
-- @param[cards] 提示牌
function sjCardNode:suggestShootCards( cards )
	if type(cards) ~= "table"  then
		return
	end



	if false == self.m_bTouched then
		self.m_beginSelectCard = nil
		self.m_endSelectCard = nil
	end

	--if false == self.m_bSuggested then
		local count = #cards
		for i = 1, count do
			local cbCardData = cards[i]
			local tmp = self.m_mapCard[cbCardData]
			if nil ~= tmp then
				gt.log("cbCardData...ssss",cbCardData)
				tmp:setCardDragSelect(true)
				self.m_mapSelectedCards[cbCardData] = tmp
			else

				if cbCardData > 100 then 
					cbCardData = cbCardData - 100
				else
					cbCardData = cbCardData + 100
				end

				tmp = self.m_mapCard[cbCardData]
				if tmp then
					tmp:setCardDragSelect(true)
					gt.log("cbCardData...",cbCardData)
					self.m_mapSelectedCards[cbCardData] = tmp
				end
			end
		end
		self:dragCards(self:filterDragSelectCards(false))
--	end
	--self.m_bSuggested = not self.m_bSuggested
end


function sjCardNode:getSelectCards()
	return self.m_tSelectCards
end

function sjCardNode:getHandCards(  )
	return self.m_cardsData
end

--
function sjCardNode:addCardsHolder(  )
	if nil == self.m_cardsHolder then
		self.m_cardsHolder = cc.Node:create();
		self:addChild(self.m_cardsHolder);
	end
end

function sjCardNode:removeAllCards()

	for i = 1, #self.m_cardsData do
		local cardtmp = self.m_mapCard[self.m_cardsData[x]]
		if cardtmp then 
			cardtmp:stopAllActions()
		end
	end

	self.m_mapCard = {}
	self.m_vecCard = {}
	if nil ~= self.m_cardsHolder then
		self.m_cardsHolder:removeAllChildren();
	end

	self.m_cardsData = {}
end

function sjCardNode:add_star( data ,isChangzhu)


	gt.log("star____________",data)



	if not data then 
		for i = 1 ,#self.m_cardsData do
			if GamesjLogic:GetCardValue(self.m_cardsData[i]) ~= 14 and  GamesjLogic:GetCardValue(self.m_cardsData[i]) ~= 15 then 
				if gt._changzhu then 
					if  GamesjLogic:GetCardValue(self.m_cardsData[i]) ~= 2 then 
						local card = self.m_mapCard[self.m_cardsData[i]]
						card:add__stat()
					end
				else
					local card = self.m_mapCard[self.m_cardsData[i]]
					card:add__stat()
				end
			end
		end
		
	else
		
		if isChangzhu then 

			for i = 1 ,#self.m_cardsData do
				
				if data == GamesjLogic:GetCardValue(self.m_cardsData[i]) then 
					local card = self.m_mapCard[self.m_cardsData[i]]
					if card then if data == 14 or data ==  15 then card:add__stat(2)   else card:add__stat(1)   end end
					local card1 = self.m_mapCard[self.m_cardsData[i]+100]
					if card1 then if data == 14 or data ==  15 then card:add__stat(2)  else card:add__stat(1) end end
					
				end
			end

		

		else
			local tmp = 0
			for i = 1 ,#self.m_cardsData do
				if data == self.m_cardsData[i] and GamesjLogic:GetCardValue(data) ~= 14 and  GamesjLogic:GetCardValue(data) ~= 15 then 
					local card = self.m_mapCard[data]
					tmp = data
					if card then
						card:add__stat(2)
					end			
				end
				
			end

			for i = 1 ,#self.m_cardsData do
				if tmp ~= self.m_cardsData[i] then 
					if GamesjLogic:GetCardColor(data) == GamesjLogic:GetCardColor(self.m_cardsData[i]) then 
						local card = self.m_mapCard[self.m_cardsData[i]]
						card:add__stat(1)
						local card1 = self.m_mapCard[self.m_cardsData[i]+100]
						if card1 then 	
							card1:add__stat(1)
						end
					end

					if GamesjLogic:GetCardValue(data) == GamesjLogic:GetCardValue(self.m_cardsData[i]) then 
						local card = self.m_mapCard[self.m_cardsData[i]]
						card:add__stat(1)
						local card1 = self.m_mapCard[self.m_cardsData[i]+100]
						if card1 then 	
							card1:add__stat(1)
						end
					end

				end
			end
		end
		
	end

end


function sjCardNode:sort(carddatas)


		local buf = {}
							

		local buf1 = {}
		for x = 1 , #carddatas do
			
			local cardtmp = self.m_mapCard[carddatas[x]]
			if cardtmp then 
				if cardtmp:get_card_star() == 2 then 
					table.insert(buf1,carddatas[x])
				end
			else
				local tmp = 0
				if carddatas[x] >= 100 then 
					tmp = carddatas[x]-100
					cardtmp = self.m_mapCard[tmp]
				else
					tmp = carddatas[x]+100
					cardtmp = self.m_mapCard[tmp]
				end
				if cardtmp then 
					
					if cardtmp:get_card_star() == 2  then 
					
						table.insert(buf1,tmp)
					end
				end
			end
		end
		buf1 = GamesjLogic:SortCardLists(buf1)


		local buf2 = {}
		for x = 1 , #carddatas do
			
			local cardtmp = self.m_mapCard[carddatas[x]]
			if cardtmp then 
				if cardtmp:get_card_star() == 1 then 
					table.insert(buf2,carddatas[x])
				end
			else
				local tmp = 0
				if carddatas[x] >= 100 then 
					tmp = carddatas[x]-100
					cardtmp = self.m_mapCard[tmp]
				else
					tmp = carddatas[x]+100
					cardtmp = self.m_mapCard[tmp]
				end
				if cardtmp then 
					
					if cardtmp:get_card_star() == 1  then 
					
						table.insert(buf2,tmp)
					end
				end
			end
		end
		buf2 = GamesjLogic:SortCardLists(buf2)



		local buf3 = {}

		for x = 1 , #carddatas do
			local cardtmp = self.m_mapCard[carddatas[x]]
			if cardtmp then 
				if cardtmp:get_card_star() == 0  then 
					table.insert(buf3,carddatas[x])
				end
			else
				local tmp = 0
				if carddatas[x] >= 100 then 
					tmp = carddatas[x]-100
					cardtmp = self.m_mapCard[tmp]
				else
					tmp = carddatas[x]+100
					cardtmp = self.m_mapCard[tmp]
				end
				if cardtmp then 
					
					if cardtmp:get_card_star() == 0  then 
					
						table.insert(buf3,tmp)
					end
				end
			end
		end



		for i = 1 , #buf1 do
			table.insert(buf,buf1[i])
		end

		for i = 1 , #buf2 do
			table.insert(buf,buf2[i])
		end

		for i = 1 , #buf3 do
			table.insert(buf,buf3[i])
		end

	return buf

end


function sjCardNode:SortCarddata(card)

	for i = 1, #card do
		for j = i + 1, #card do
			if card[j] > card[i] then 
				local tmp = card[j]
				card[j] = card[i]
				card[i] = tmp
			end
		end
	end

	--gt.dump(card)
	return card
end

function sjCardNode:arrangeAllCards( showAnimation, pCallBack ,bankerCardDatd)
	local idx = 0
	
	if showAnimation then
		
		local count = self.m_cardsCount
		local cards = self.m_cardsData
		local winSize = cc.Director:getInstance():getWinSize()
		local p = self:convertToNodeSpace(cc.p(winSize.width * 0.5, 0))
		gt.log("count............",count)
		if gt.MY_VIEWID == self.m_nViewId then
	
			local center = 12
			

			for i = 1, count do
				local cardData = cards[i]
				
				local tmp = self.m_mapCard[cardData]
				gt.log("i_______________,",i)
				gt.log(cardData)
				if nil ~= tmp then

					tmp:setLocalZOrder(i)					
					tmp:showSelectEffect(false)
					
					local pos = cc.p(p.x,0)

					tmp:stopAllActions()
					tmp:setPosition(pos)
					tmp:setDispatched(true)
					tmp:showCardBack(false)
					tmp:setVisible(false)
					tmp:setScale(CARD_SHOW_SCALE)

					local spa =cc.CallFunc:create(function()
						tmp:setVisible(true)
						gt.soundEngine:Poker_playEffect("sound_res/ddz/touch_my_card.wav")
						if i == count then
							self.m_bDispatching = false	

							local carddatas  = GamesjLogic:SortCardList(self.m_cardsData, #self.m_cardsData)
							
							local buf = self:sort(carddatas)
							
							
							gt.dump(buf)

							local cen = math.ceil(#buf/2)
							local p = self:convertToNodeSpace(cc.p(winSize.width * 0.5, 0)) 
							for x = 1 , #buf do
								local pos = cc.p(p.x+(x - cen) * CARD_X_DIS,0)
								local tmpcard = self.m_mapCard[buf[x]]
								tmpcard:setLocalZOrder(x)
							
								tmpcard:setPosition(pos)
							end
							
						end

						
						local buf = {}
						for j = 1, i do
							buf[j] = self.m_cardsData[j]
						end
						local carddata  = GamesjLogic:SortCardList(buf, #buf)
						local buf = self:sort(carddata)
						carddata = buf
						center = math.ceil(#carddata/2)
						local clour = {}
						for x = 1 , #carddata do
							local pos = cc.p(p.x+(x - center) * CARD_X_DIS,0)
							local tmpcard = self.m_mapCard[carddata[x]]
							tmpcard:setLocalZOrder(x)
							tmpcard:setPosition(pos)
							table.insert(clour,carddata[x])
						end
						if nil ~= self.m_pSelectedListener and nil ~= self.m_pSelectedListener.renovate_huase then
							self.m_pSelectedListener:renovate_huase(clour)
						end
					end)

					tmp:runAction(cc.Sequence:create(cc.DelayTime:create(ANI_RATE(idx))  , spa))
					idx = idx + 1
				end
			end
		else
			
		end
	else
		
	end
end




function sjCardNode:reSortCards(count) 
	local count = self.m_cardsCount
	local cards = self.m_cardsData

	gt.log("csw_____22",self.m_nViewId)
	--布局
	if gt.MY_VIEWID == self.m_nViewId then
	
		

		local carddatas  = GamesjLogic:SortCardList(self.m_cardsData, #self.m_cardsData)
		
		local buf = self:sort(carddatas)

		local cen = math.ceil(#buf/2)
		gt.log("cen____________111111111",#buf)
		local winSize = cc.Director:getInstance():getWinSize()
		local p = self:convertToNodeSpace(cc.p(winSize.width * 0.5, 0)) 


		for x = 1 , #buf do
			local pos = cc.p(p.x+(x - cen) * CARD_X_DIS,0)
		
			local tmpcard = self.m_mapCard[buf[x]]

			if tmpcard then 

				tmpcard:stopAllActions()
				tmpcard:setDispatched(true)
				tmpcard:showCardBack(false)
				tmpcard:setLocalZOrder(x)
				tmpcard:setPosition(pos)
				
			else
				tmpcard = self.m_mapCard[  buf[x] > 100 and buf[x] -100 or buf[x] +100 ] 
				if tmpcard then 
					tmpcard:stopAllActions()
					tmpcard:setDispatched(true)
					tmpcard:showCardBack(false)
					tmpcard:setLocalZOrder(x)
					tmpcard:setPosition(pos)
					gt.log("x1...",pos.x)

				end
			end
			if x == #buf then self.m_bDispatching = false end
		end

	else
	
		--变动通知
		if nil ~= self.m_pSelectedListener and nil ~= self.m_pSelectedListener.onCountChange then
			self.m_pSelectedListener:onCountChange( self.m_cardsCount, self)
		end
	end
end

function sjCardNode:getcardsCount()
	

	--return 2
	return self.m_cardsCount

end

function sjCardNode:set_CardShoot(card,bool)
	if v and bool ~= nil and type(card) == "table" then 
		for k,v in pairs(card) do
	 		v:setCardShoot(bool)
	 	end
	end
end


function sjCardNode:dragCards( vecCard )
	if type(vecCard) ~= "table"  then
		return
	end


	for k,v in pairs(vecCard) do

		if tolua.isnull(v) then
			vecCard[k] = nil
		else
			local pos = cc.p(v:getPositionX(), v:getPositionY())
			v:stopAllActions()
			
			if not v:getCardShoot() then
				local shoot = cc.MoveTo:create(CARD_SHOOT_TIME,cc.p(pos.x,CARD_SHOOT_DIS))
	            v:runAction(shoot)
	            v:setCardShoot(true)
	          
	          
	            self.m_mapSelectedCards[v:getCardData()] = v
	           
	        else
	        	
	        	local shoot = cc.MoveTo:create(CARD_SHOOT_TIME,cc.p(pos.x,0))
	            v:runAction(shoot)
	            v:setCardShoot(false)
	          
	           
	            self.m_mapSelectedCards[v:getCardData()] = nil
			end
		end
	end

	local tmpShow = (gt.MY_VIEWID == self.m_nViewId) and false or not self.m_bShowCard
	local vecChildren = self.m_cardsHolder:getChildren()
	for k,v in pairs(vecChildren) do
		v:showCardBack(tmpShow)
		v:setCardDragSelect(false)
		v:showSelectEffect(false)
	end

	self.m_tSelectCards = {}
	for k,v in pairs(self.m_mapSelectedCards) do
		if nil ~= v and nil ~= v.getCardData then
			table.insert(self.m_tSelectCards, v:getCardData())
		end		
	end
	self.m_tSelectCards = GamesjLogic:SortCardList(self.m_tSelectCards, #self.m_tSelectCards, true)
	
	if nil ~= self.m_pSelectedListener and nil ~= self.m_pSelectedListener.onSelectedCards then
		self.m_pSelectedListener:onSelectedCards(self.m_tSelectCards, bool)
	end

	

	self.m_mapDragSelectCards = {}
end



--触摸操控
function sjCardNode:filterCard(flag, touchPoint)
	local tmpSel = {}
	local idx = 0
	gt.dump(self.m_mapCard)
	for k,v in pairs(self.m_mapCard) do
		if tolua.isnull(v) then 
			gt.log("type...........",tolua.type(v))
			gt.dump(self.m_mapCard)
			-- if not self.off_line then 
			-- 	self.off_line = true
			-- 	gt.socketClient:close()
			-- end
			self.m_mapCard[k] = nil
		else
			if not v:getChildByTag(4):isVisible() then 
				local locationInNode = v:convertToNodeSpace(touchPoint)
				local rec = cc.rect(0, 0, v:getContentSize().width, v:getContentSize().height)
				if cc.rectContainsPoint(rec, locationInNode) then
			        table.insert(tmpSel, v)
			    end
			end
			idx = idx + 1
		end
		
	end

	if 0 == #tmpSel then
		return nil
	end

	table.sort(tmpSel,function( a,b )
		return a:getLocalZOrder() < b:getLocalZOrder()
	end)

	if kHIGHEST == flag then
		return tmpSel[#tmpSel] , dix
	else
		return tmpSel[1] , idx
	end
end

function sjCardNode:inTouchAreaCards( touchRect )
	local tmpMap = {}
	for k,v in pairs(self.m_mapCard) do
		if tolua.isnull(v) then
			self.m_mapCard[k] = nil
		else
			local locationInNode = cc.p(v:getPositionX(), v:getPositionY())
			local anchor = v:getAnchorPoint()
			local tmpSize = v:getContentSize()

			local ori = cc.p(locationInNode.x - tmpSize.width * anchor.x, locationInNode.y - tmpSize.height * anchor.y)
			local rect = cc.rect(ori.x, ori.y, tmpSize.width , tmpSize.height)
			if cc.rectIntersectsRect(rect, touchRect) and nil ~= v.getCardData then
		        tmpMap[v:getCardData()] = v
		    end
		end
			 
	end

	return self:filterDragSelectCards(true, tmpMap, true)
end

function sjCardNode:makeTouchRect( endTouch )
	local movePoint = endTouch
	local m_beginTouchPoint = self.m_beginTouchPoint

	--判断拖动方向(左右)
	local toRight = (m_beginTouchPoint.x < movePoint.x) and true or false
	--判断拖动方向(上下)
	local toTop = (m_beginTouchPoint.y < movePoint.y) and true or false
	self.m_dragMoveDir = (toRight == true) and kMoveToRight or kMoveToLeft

	if toRight and toTop then
		return cc.rect(m_beginTouchPoint.x, m_beginTouchPoint.y, movePoint.x - m_beginTouchPoint.x, movePoint.y - m_beginTouchPoint.y)
	elseif toRight and not toTop then
		return cc.rect(m_beginTouchPoint.x, movePoint.y, movePoint.x - m_beginTouchPoint.x, m_beginTouchPoint.y - movePoint.y)
	elseif not toRight and toTop then
		return cc.rect(movePoint.x, m_beginTouchPoint.y, m_beginTouchPoint.x - movePoint.x, movePoint.y - m_beginTouchPoint.y)
	elseif not toRight and not toTop then
		return cc.rect(movePoint.x, movePoint.y, m_beginTouchPoint.x - movePoint.x, m_beginTouchPoint.y - movePoint.y)
	end
	return cc.rect(0, 0, 0, 0)
end



function sjCardNode:filterDragSelectCards( bFilter, cards, bMap)
	local lowOrder = self:getLowOrder()
	local hightOrder = self:getHightOrder()
	bMap = bMap or false

	--过滤对象
	local tmpMap = {}
	if nil == cards or type(cards) ~= "table" or 0 == table.nums(cards) then
		--合并
		for k,v in pairs(self.m_mapSelectedCards) do
			if nil ~= v and nil ~= v.getCardData then
				gt.log("v.getCardData",v.getCardData)
				tmpMap[v:getCardData()] = v
			end			
		end
		for k,v in pairs(self.m_mapDragSelectCards) do
			if nil ~= v and nil ~= v.getCardData then
				gt.log("v.getCardData",v.getCardData)
				tmpMap[v:getCardData()] = v
			end	
		end
	else
		tmpMap = cards
	end

	gt.dump(tmpMap)

	local tmp = {}
	if bMap then
		if bFilter then
			for k,v in pairs(tmpMap) do
				if v:getLocalZOrder() >= lowOrder and v:getLocalZOrder() <= hightOrder then
					tmp[v:getCardData()] = v
				end			
			end
		else
			for k,v in pairs(tmpMap) do
				tmp[v:getCardData()] = v
			end
		end
	else
		if bFilter then
			for k,v in pairs(tmpMap) do
				if v:getLocalZOrder() >= lowOrder and v:getLocalZOrder() <= hightOrder then
					table.insert(tmp, v)
				end			
			end
		else
			for k,v in pairs(tmpMap) do
				table.insert(tmp, v)
			end
		end
	end	
	return tmp
end

function sjCardNode:getLowOrder()
	local beginOrder = (self.m_beginSelectCard ~= nil) and self.m_beginSelectCard:getLocalZOrder() or MIN_DRAW_ORDER
	local endOrder = nil
	if nil ~= self.m_endSelectCard then
		endOrder = self.m_endSelectCard:getLocalZOrder()
	end
	if kMoveToLeft == self.m_dragMoveDir then
		endOrder = endOrder or MIN_DRAW_ORDER
	else
		endOrder = endOrder or MAX_DRAW_ORDER
	end
	return math.min(beginOrder, endOrder)
end

function sjCardNode:getHightOrder()
	local beginOrder = (self.m_beginSelectCard ~= nil) and self.m_beginSelectCard:getLocalZOrder() or MIN_DRAW_ORDER
	local endOrder = nil
	if nil ~= self.m_endSelectCard then
		endOrder = self.m_endSelectCard:getLocalZOrder()
	end
	if kMoveToLeft == self.m_dragMoveDir then
		endOrder = endOrder or MAX_DRAW_ORDER
	else
		endOrder = endOrder or MIN_DRAW_ORDER
	end
	return math.max(beginOrder, endOrder)
end
--触摸操控

return sjCardNode