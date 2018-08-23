
local mai_di = class("mai_di" , function() return cc.Layer:create() end)
local GamesjLogic = gt.include("ddzCard.GamesjLogic")


local kHIGHEST = 1

function mai_di:ctor()

	self.node = cc.CSLoader:createNode("mai_di.csb")
	gt.addNode(self,self.node)
	self.node:setPosition(gt.winCenter)
	yl.registerTouchEvent(self)
	self.m_mapCard = {}
	self.select1 = {}
	self.select2 = {}
	gt.seekNodeByName(self.node,"Button"):setEnabled(false)
	self:setVisible(false)

	local mai_di = self.node:getChildByName("mai_di")
	local card1 = mai_di:getChildByName("Image_1")
	card1:setVisible(false)
	local card2 = mai_di:getChildByName("Image_2")
	card2:setVisible(false)

	self.card_posy1 = math.ceil(card1:getPositionY())
	self.card_posy2 = math.ceil(card2:getPositionY())
	for i = 1 , 33 do

		local cards = nil
		

		if i <= 17 then 
			cards = cc.Sprite:create()
			
			if gt.addNode(mai_di,cards) then 
				cards:setPosition(cc.p(card1:getPositionX()+57*(i-1),card1:getPositionY()))
				cards:setPositionY( self.card_posy1 )
			end

		else
			cards = cc.Sprite:create()
			
			if gt.addNode(mai_di,cards) then 
				cards:setPositionY( self.card_posy2 )
				cards:setPosition(cc.p(card2:getPositionX()+57*(i-18),card2:getPositionY()))
			end
		end
		local hui = cc.Sprite:create("poker_sj/58.png")
		if gt.addNode(cards,hui) then 
			hui:setAnchorPoint(0, 0)
			hui:setPosition(0, 0)
			hui:setVisible(false)
			hui:setTag(3)
		end


		local star = cc.Sprite:create("sjScene/star.png")
		if gt.addNode(cards,star) then 
			star:setAnchorPoint(0,0)
			star:setPosition(10,10)
			star:setVisible(false)
			star:setTag(1)
			if i <= 17 then 
				star:setPosition(10,30)
			end
		end

		

		local star = cc.Sprite:create("sjScene/star.png")
		
		if gt.addNode(cards,star) then 
			star:setAnchorPoint(0,0)
			star:setPosition(10,40)
			star:setVisible(false)
			star:setTag(2)
			if i <= 17 then 
				star:setPosition(10,60)
			end
		end

		

		table.insert(self.m_mapCard,cards)

	end


end

function mai_di:onTouchBegan(touch, event)
	self.select1 = {}
	self.select2 = {}

	local location = touch:getLocation()
	self.m_beginSelectCard = self:filterCard(kHIGHEST, location)
		
		if self.m_beginSelectCard then
			local child = self.m_beginSelectCard:getChildByTag(3)
			child:setVisible(true)
		end



	return 	self:isVisible()

end

function mai_di:onTouchMoved(touch, event)
	local location = touch:getLocation()
	self.m_beginSelectCard = self:filterCard(kHIGHEST, location)
		
	
		if self.m_beginSelectCard then
			local child = self.m_beginSelectCard:getChildByTag(3)
			child:setVisible(true)
		end
	

end

function mai_di:onExit()
	 if self.createSchedule then gt.scheduler:unscheduleScriptEntry(self.createSchedule) self.createSchedule = nil end
end

function mai_di:onTouchEnded(touch, event)
	local location = touch:getLocation()
	self.m_beginSelectCard = self:filterCard(kHIGHEST, location)
	
	
		
		if self.m_beginSelectCard then
			self:move()
		else
			for i = 1 , #self.m_mapCard do
				if i<=17 then 
					self.m_mapCard[i]:setPositionY(self.card_posy1)
				else
					self.m_mapCard[i]:setPositionY(self.card_posy2)
				end
			end
			self:check_select_card()
		end
			
		for k,v in pairs(self.m_mapCard) do
			local child = v:getChildByTag(3)
			child:setVisible(false)
		end
	
end

function mai_di:move(card)

	gt.log("c________________sss")
	local idx = 0
	for i = 1, #self.select1 do
		local card = self.select1[i]
		card:stopAllActions()
		if card:getPositionY() == self.card_posy1 then
			
			card:runAction(cc.Sequence:create( cc.MoveTo:create(0.1,cc.p(card:getPositionX(),self.card_posy1+20)), cc.CallFunc:create(function() 
				self:check_select_card()

			 end)))
		elseif   card:getPositionY() ~= self.card_posy1 then 
			
			card:runAction(cc.Sequence:create( cc.MoveTo:create(0.1,cc.p(card:getPositionX(),self.card_posy1)), cc.CallFunc:create(function() 
				self:check_select_card()

			 end)))
		end
	end

	for i = 1, #self.select2 do
		local card = self.select2[i]
		card:stopAllActions()
		if card:getPositionY() == self.card_posy2 then
			idx = idx + 1
			gt.log("c________________")
			card:runAction(cc.Sequence:create( cc.MoveTo:create(0.1,cc.p(card:getPositionX(),self.card_posy2+20)), cc.CallFunc:create(function() 
				  self:check_select_card()

			 end)))
		elseif card:getPositionY() ~= self.card_posy2 then 
			idx = idx - 1
			card:runAction(cc.Sequence:create( cc.MoveTo:create(0.1,cc.p(card:getPositionX(),self.card_posy2)), cc.CallFunc:create(function() 
					self:check_select_card()

			 end)))
		end
	end


end


function mai_di:check_select_card(  )
	

	self.send_card = {}
	local idx = 0
	for i = 1 , #self.m_mapCard do
		if i <=17 then 
			if self.m_mapCard[i]:getPositionY() == self.card_posy1+20 then 
				idx = idx + 1
				self.send_card[idx] = self._card[i]
			end
		else
			if self.m_mapCard[i]:getPositionY() == self.card_posy2+20 then 
				idx = idx + 1
				self.send_card[idx] = self._card[i]
				
			end
		end
	end

	
	gt.dump(self.send_card)

	gt.seekNodeByName(self.node,"time_0"):setString(#self.send_card)
	
	gt.seekNodeByName(self.node,"Button"):setEnabled(#self.send_card == 8)
	

end

--触摸操控
function mai_di:filterCard(flag, touchPoint)
	local tmpSel = {}
	local idx = 0
	local tmp = nil
	for k,v in pairs(self.m_mapCard) do
		local locationInNode = v:convertToNodeSpace(touchPoint)
		local rec = cc.rect(0, 0, v:getContentSize().width, v:getContentSize().height)
		
		if cc.rectContainsPoint(rec, locationInNode) then
			
	        table.insert(tmpSel, v)
	        if k <=17 then 
	        	idx = 1
	        	--table.insert(self.select1,v)
	        else
	        	idx = 2
	        	--table.insert(self.select2,v)
	        end
	        tmp = v
	       
	    end
	end
	if 0 == #tmpSel then
	
		return nil
	end

	if idx == 1 then 
		table.insert(self.select1,tmp)
	elseif idx == 2 then 
		table.insert(self.select2,tmp)
	end

	table.sort(tmpSel,function( a,b )
		return a:getLocalZOrder() < b:getLocalZOrder()
	end)


	if kHIGHEST == flag then
		return tmpSel[#tmpSel]
	else
		return tmpSel[1]
	end

end

function mai_di:init(m,pos,time,kSelectCard)

	gt.log("pos_______",pos)
	self:setVisible(true)
	gt.seekNodeByName(self.node,"Button"):setEnabled(false)
	gt.seekNodeByName(self.node,"time"):setString(time)
	if self.createSchedule then gt.scheduler:unscheduleScriptEntry(self.createSchedule) self.createSchedule = nil end
	gt.seekNodeByName(self.node,"clock"):stopAllActions()
	local chutaiAnimateResult = function()
		  time = time - 1
		  gt.seekNodeByName(self.node,"time"):setString(time)
		  if time <= 0 then 
		  	 time = 0 
		  	 if self.createSchedule then gt.scheduler:unscheduleScriptEntry(self.createSchedule) self.createSchedule = nil end
		  end
		  if time == 5 then 
		  	  gt.soundEngine:Poker_playEffect("sound_res/ddz/clock.mp3")
		  	  gt.seekNodeByName(self.node,"clock"):runAction(cc.RepeatForever:create( cc.Sequence:create(cc.RotateTo:create(0.01,10),cc.RotateTo:create(0.01,0),cc.RotateTo:create(0.01,-10),cc.RotateTo:create(0.01,0))))	
		  end
	end
	self.createSchedule = gt.scheduler:scheduleScriptFunc(chutaiAnimateResult, 1, false)

	gt.setOnViewClickedListeners(gt.seekNodeByName(self.node,"Button"),function()
			gt.seekNodeByName(self.node,"Button"):setEnabled(false)
			gt.dispatchEvent("hide_mai_di",1)
			self:setVisible(false)
			local m = {}
			m.kMId =  gt.MSG_C_2_S_SHUANGSHENG_BASE_CARDS
			m.kPos = pos
			m.kBaseCardsCount = #self.send_card
			m.kBaseCards = self.send_card
			gt.log("pos_______send",pos)
			gt.socketClient:sendMessage(m)
			if self.createSchedule then gt.scheduler:unscheduleScriptEntry(self.createSchedule) self.createSchedule = nil end
			gt.seekNodeByName(self.node,"clock"):stopAllActions()
		end)

	self._card = m

	local buf = {}

	local tmp = {}

	gt.dump(m)

	gt.log("gt._changzhus.......",gt._changzhus,kSelectCard)

	m = GamesjLogic:SortCardLists(m)
	m = yl.switch_card(m)
	for i = 1 , #self.m_mapCard do 
		self.m_mapCard[i]:getChildByTag(1):setVisible(false)
		self.m_mapCard[i]:getChildByTag(2):setVisible(false)
		self.m_mapCard[i]:getChildByTag(3):setVisible(false)

		if i <= 17 then 
			self.m_mapCard[i]:setPositionY( self.card_posy1 )
		else
			self.m_mapCard[i]:setPositionY( self.card_posy2 )
		end

		tmp[m[i]] = 0

		if ( kSelectCard ~= 64 and m[i] == kSelectCard ) or ( kSelectCard ~= 64 and m[i] == kSelectCard +100 ) or  GamesjLogic:GetCardValue(m[i]) == 14 or  GamesjLogic:GetCardValue(m[i]) == 15 then 
			table.insert( buf , m[i])
			tmp[m[i]] = 2

		elseif GamesjLogic:GetCardValue(m[i]) == 14 or GamesjLogic:GetCardValue(m[i]) == 15 or (gt._changzhu and GamesjLogic:GetCardValue(m[i]) == 2) or 
			(kSelectCard ~= 64 and GamesjLogic:GetCardColor(m[i]) == GamesjLogic:GetCardColor(kSelectCard) ) or 
			(kSelectCard ~= 64 and GamesjLogic:GetCardValue(m[i]) == GamesjLogic:GetCardValue(kSelectCard) ) or 
			(kSelectCard == 64 and GamesjLogic:GetCardValue(m[i]) == GamesjLogic:GetCardValue(gt._changzhus) ) then 
			-- table.insert( buf , m[i])
			-- tmp[m[i]] = 1
		end


	end


	for i = 1 , #self.m_mapCard do 
		

		if ( kSelectCard ~= 64 and m[i] == kSelectCard ) or ( kSelectCard ~= 64 and m[i] == kSelectCard +100 ) or  GamesjLogic:GetCardValue(m[i]) == 14 or  GamesjLogic:GetCardValue(m[i]) == 15 then 
			-- table.insert( buf , m[i])
			-- tmp[m[i]] = 2

		elseif GamesjLogic:GetCardValue(m[i]) == 14 or GamesjLogic:GetCardValue(m[i]) == 15 or (gt._changzhu and GamesjLogic:GetCardValue(m[i]) == 2) or 
			(kSelectCard ~= 64 and GamesjLogic:GetCardColor(m[i]) == GamesjLogic:GetCardColor(kSelectCard) ) or 
			(kSelectCard ~= 64 and GamesjLogic:GetCardValue(m[i]) == GamesjLogic:GetCardValue(kSelectCard) ) or 
			(kSelectCard == 64 and GamesjLogic:GetCardValue(m[i]) == GamesjLogic:GetCardValue(gt._changzhus) ) then 
			table.insert( buf , m[i])
			tmp[m[i]] = 1
		end


	end


	--buf = GamesjLogic:SortCardLists(buf)

	for i = 1 ,#self.m_mapCard do  
		if tmp[m[i]] == 0 then 
			table.insert( buf , m[i])
		end
	end



	self._card = buf

	for i = 1 , #self.m_mapCard do 
		
		for j = 1, tmp[buf[i]] do
			gt.log("value_______",GamesjLogic:GetCardValue(buf[i]))
			if GamesjLogic:GetCardValue(buf[i]) ~= 14 and GamesjLogic:GetCardValue(buf[i]) ~= 15 then
				gt.log("value_______1111",GamesjLogic:GetCardValue(buf[i]))
				self.m_mapCard[i]:getChildByTag(j):setVisible(true)
			end
		end
		
		self.m_mapCard[i]:setTexture("poker_sj/"..gt.tonumber(buf[i])..".png")
	end
	
end

return mai_di