--
-- Author: zhong
-- Date: 2016-06-27 11:36:40
--
local sjCardSprite = class("sjCardSprite", cc.Sprite)

--纹理宽高
-- local CARD_WIDTH = 163.77
-- local CARD_HEIGHT = 210

-- local CARD_WIDTH = 157.7
-- local CARD_HEIGHT = 225

-- local CARD_WIDTH = 153
-- local CARD_HEIGHT = 218

local CARD_WIDTH = 131
local CARD_HEIGHT = 184

local BACK_Z_ORDER = 2

------
--set/get
function sjCardSprite:setDispatched( var )

	self.m_bDispatched = var;
end

function sjCardSprite:getDispatched(  )
	if nil ~= self.m_bDispatched then
		return self.m_bDispatched;
	end
	return false
end

function sjCardSprite:getCardData()
	return self.m_cardData
end

--拖动选择
function sjCardSprite:setCardDragSelect( var )
	self.m_bDragSelect = var
end

function sjCardSprite:getCardDragSelect()
	return self.m_bDragSelect
end

--弹出
function sjCardSprite:setCardShoot( var )
	self.m_bShoot = var
end

function sjCardSprite:getCardShoot()
	return self.m_bShoot
end
------

function sjCardSprite:ctor(data)
	self.m_cardData = 0
	self.m_cardValue = 0
	self.m_cardColor = 0
	self.m_bDispatched = false
	self.m_bDragSelect = false
	self.m_bShoot = false
	self.m_nCardWidth = 0
	self.m_nCardHeight = 0
	--print("data"..data)
	
	--self._node = cc.Sprite:create(yl.poker_node[data])
	
	--return self._node
end

function sjCardSprite:add__stat(num)


	if num == 1 then 
		self:getChildByTag(1):setVisible(true)
	elseif num == 2 then
		self:getChildByTag(2):setVisible(true)
		self:getChildByTag(1):setVisible(true)
	else
		self:getChildByTag(2):setVisible(false)
		self:getChildByTag(1):setVisible(false)
	end
end

function sjCardSprite:get_card_star()
	
	local idx = 0
	for i = 1 , 2 do
		if self:getChildByTag(i):isVisible() then 
			idx = idx + 1
		end
	end

	return idx

end

--创建卡牌
function sjCardSprite:createCard(cbCardData, tagParam)
	
	local tmp = cbCardData

	if cbCardData > 100 then cbCardData = cbCardData -100 end
	local carddata = gt.tonumber(cbCardData)


	local sp = sjCardSprite.new()
	tagParam = tagParam or {}
	sp.m_nCardWidth = tagParam._width or CARD_WIDTH
	sp.m_nCardHeight = tagParam._height or CARD_HEIGHT

	sp.m_strCardFile = tagParam._file or gt.poker_node_sj[carddata]

	
	
	local tex = cc.Director:getInstance():getTextureCache():getTextureForKey(sp.m_strCardFile)


	if nil ~= sp and nil ~= tex and sp:initWithTexture(tex, tex:getContentSize()) then
		sp.m_cardData = tmp;
		sp.m_cardValue = yl.POKER_VALUE[cbCardData] --math.mod(cbCardData, 16)--bit:_and(cbCardData, 0x0F)
		sp.m_cardColor = yl.CARD_COLOR[cbCardData] --math.floor(cbCardData / 16)--bit:_rshift(bit:_and(cbCardData, 0xF0), 4)

		self.m_bShoot = false

		sp:updateSprite();
		--扑克背面
		sp:createBack();
		local star = cc.Sprite:create("sjScene/star.png")
		if gt.addNode(sp,star) then 
			star:setAnchorPoint(0,0)
			if cbCardData == 78 or cbCardData == 79 then 
				star:setPosition(-1000,-1000)
			else
				star:setPosition(10,10)
			end
			star:setVisible(false)
			star:setTag(1)
		end
		local star = cc.Sprite:create("sjScene/star.png")

		if gt.addNode(sp,star) then 

			star:setAnchorPoint(0,0)
			if cbCardData == 78 or cbCardData == 79 then 
				star:setPosition(-1000,-1000)
			else
				star:setPosition(10,38)
			end
			star:setVisible(false)
			star:setTag(2)
		end
		


		local max = cc.Sprite:create("sjScene/max.png")
		if gt.addNode(sp,max) then 
			max:setAnchorPoint(1,0)
			max:setPosition(130,2)
			max:setVisible(false)
			max:setTag(3)
		end	

		local hui =cc.Sprite:create("poker_sj/58.png")
		if gt.addNode(sp,hui) then 
			local cardSize = sp:getContentSize();
			hui:setPosition(cardSize.width * 0.5, cardSize.height * 0.5)
			hui:setVisible(false)
			hui:setTag(4)
		end

		return sp;
	end

	gt.dispatchEvent("show_log",tmp)

	return nil;
end


function sjCardSprite:show_max(is)
	if self and self:getChildByTag(3) then 
		
		self:getChildByTag(3):setVisible(is)
	end
end


--设置卡牌数值
function sjCardSprite:setCardValue( cbCardData )
	
	self.m_cardData = cbCardData
	self.m_cardValue = yl.POKER_VALUE[cbCardData]  --math.mod(cbCardData, 16) --bit:_and(cbCardData, 0x0F)
	self.m_cardColor = yl.CARD_COLOR[cbCardData]  --math.floor(cbCardData / 16) --bit:_rshift(bit:_and(cbCardData, 0xF0), 4)
	local carddata = gt.tonumber(cbCardData)
	self:updateSprite(carddata)
end

--更新纹理资源
function sjCardSprite:updateSprite(data)
	local m_cardData = self.m_cardData
	local m_cardValue = self.m_cardValue
	local m_cardColor = self.m_cardColor
	local c_width = self.m_nCardWidth
	local c_height = self.m_nCardHeight
	if not m_cardData then return end
	self.tmpx =15
	self.tmpy = 22
    
	
	self:setTag(m_cardData)
	
	if data then
		local tex = cc.Director:getInstance():getTextureCache():getTextureForKey(gt.poker_node[data])
		self:initWithTexture(tex, tex:getContentSize())
	end
	local rect = cc.rect(0,0,c_width,c_height)
	-- if m_cardData ~= 0 then
	-- print("更新纹理资源________________"..m_cardData)
	
	-- end
	-- local rect = cc.rect((m_cardValue - 1) * c_width, m_cardColor * c_height, c_width, c_height);
	-- if 0 ~= m_cardData then
	-- 	  rect = cc.rect((m_cardValue - 1) * c_width, m_cardColor * c_height, c_width, c_height);
	-- 	if 0x4F == m_cardData then
	-- 		rect = cc.rect(0, 4 * c_height, c_width, c_height);
	-- 	elseif 0x4E == m_cardData then
	-- 		rect = cc.rect(c_width, 4 * c_height, c_width, c_height);
	-- 	elseif 0x43 == m_cardData then
	-- 		rect = cc.rect(c_width*3, 4 * c_height, c_width, c_height);
	-- 	elseif 0x41 == m_cardData then
	-- 		rect = cc.rect(c_width*2, 4 * c_height, c_width, c_height);
	-- 	end
	-- else
	-- 	--使用背面纹理区域
	-- 	rect = cc.rect(3 * c_width+self.tmpx, 4 * c_height+self.tmpy, c_width+self.tmpx, c_height+self.tmpy);
	-- end
	self:setTextureRect(rect)

end

--显示扑克背面
function sjCardSprite:showCardBack( var )

	if nil ~= self.m_spBack then
		self.m_spBack:setVisible(var);
	end	
end

--扑克选择效果
function sjCardSprite:showSelectEffect(bSelect)
	local c_width = self.m_nCardWidth
	local c_height = self.m_nCardHeight
	if nil == self.m_pMask then
		self.m_pMask = cc.Sprite:create("poker_sj/58.png")
		if nil ~= self.m_pMask then
			self.m_pMask:setColor(cc.BLACK)
			self.m_pMask:setOpacity(100)
			local cardSize = self:getContentSize();
			self.m_pMask:setPosition(cardSize.width * 0.5, cardSize.height * 0.5)
			--self.m_pMask:setTextureRect(cc.rect(2 * c_width+self.tmpx, 4 * c_height+self.tmpy, c_width+self.tmpx, c_height+self.tmpy))
			--self.m_pMask:setPosition(c_width * 0.5+self.tmpx-7, c_height * 0.5+self.tmpy-10)
			self:addChild(self.m_pMask)
		end
	end
	if nil ~= self.m_pMask then
		self.m_pMask:setVisible(bSelect)
	end	
end

--创建背面
function sjCardSprite:createBack()
	--local c_width = self.m_nCardWidth
	--local c_height = self.m_nCardHeight

	--local tex = cc.Director:getInstance():getTextureCache():getTextureForKey(self.m_strCardFile);
	--纹理区域
	--local rect = cc.rect(2 * c_width, 4 * c_height, c_width, c_height);

	local cardSize = self:getContentSize();
   -- local m_spBack = cc.Sprite:createWithTexture(tex, rect);
    local m_spBack = cc.Sprite:create("poker_sj/56.png")
    m_spBack:setPosition(cardSize.width * 0.5, cardSize.height * 0.5);
    m_spBack:setVisible(false);
    self:addChild(m_spBack);
    m_spBack:setLocalZOrder(BACK_Z_ORDER);
    self.m_spBack = m_spBack;
end

return sjCardSprite