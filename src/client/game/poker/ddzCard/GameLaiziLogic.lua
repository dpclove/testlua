--[[--
¶·µØÖ÷ÓÎÏ·Âß¼­
2016.6
]]
local GameLaiziLogic = {}

GameLaiziLogic._CardData = { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, -- ·½¿é
                        0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, -- Ã·»¨
                        0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, -- ºìÌÒ
                        0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, -- ºÚÌÒ
                        0x4E, 0x4F } -- Ð¡Íõ,´óÍõ

GameLaiziLogic.GAME_PLAYER         = 3    -- ÓÎÏ·ÈËÊý
GameLaiziLogic.CARD_COUNT_NORMAL   = 17   -- ³£¹æÅÆÊý
GameLaiziLogic.CARD_COUNT_MAX      = 20   -- ×î´óÅÆÊý
GameLaiziLogic.CARD_FULL_COUNT     = 54   -- È«ÅÆÊýÄ¿

-- ÆË¿ËÀàÐÍ
GameLaiziLogic.CT_ERROR            = 0    -- ´íÎóÀàÐÍ
GameLaiziLogic.CT_SINGLE           = 1    -- µ¥ÅÆÀàÐÍ
GameLaiziLogic.CT_DOUBLE           = 2    -- ¶ÔÅÆÀàÐÍ
GameLaiziLogic.CT_THREE            = 3    -- ÈýÌõÀàÐÍ
GameLaiziLogic.CT_SINGLE_LINE      = 4    -- µ¥Á¬ÀàÐÍ
GameLaiziLogic.CT_DOUBLE_LINE      = 5    -- ¶ÔÁ¬ÀàÐÍ
GameLaiziLogic.CT_THREE_LINE       = 6    -- ÈýÁ¬ÀàÐÍ
GameLaiziLogic.CT_THREE_TAKE_ONE   = 7    -- Èý´øÒ»µ¥
GameLaiziLogic.CT_THREE_TAKE_TWO   = 8    -- Èý´øÒ»¶Ô
GameLaiziLogic.CT_FOUR_TAKE_ONE    = 9    -- ËÄ´øÁ½µ¥
GameLaiziLogic.CT_FOUR_TAKE_TWO    = 10   -- ËÄ´øÁ½¶Ô
GameLaiziLogic.CT_BOMB_CARD        = 11   -- Õ¨µ¯ÀàÐÍ
GameLaiziLogic.CT_MISSILE_CARD     = 12   -- »ð¼ýÀàÐÍ
GameLaiziLogic.WUSHUN              = 13


--[[
-- 扑克类型
GameLogic.CT_ERROR            = 0    -- 错误类型
GameLogic.CT_SINGLE           = 1    -- 单牌类型
GameLogic.CT_DOUBLE           = 2    -- 对牌类型
GameLogic.CT_THREE            = 3    -- 三条类型
GameLogic.CT_SINGLE_LINE      = 4    -- 单连类型
GameLogic.CT_DOUBLE_LINE      = 5    -- 对连类型
GameLogic.CT_THREE_LINE       = 6    -- 三连类型
GameLogic.CT_THREE_TAKE_ONE   = 7    -- 三带一单
GameLogic.CT_THREE_TAKE_TWO   = 8    -- 三带一对
GameLogic.CT_FOUR_TAKE_ONE    = 9    -- 四带两单
GameLogic.CT_FOUR_TAKE_TWO    = 10   -- 四带两对
GameLogic.CT_BOMB_CARD        = 11   -- 炸弹类型
GameLogic.CT_MISSILE_CARD     = 12   -- 火箭类型


]]

local CT_ERROR = 0
local CT_SINGLE = 1
local CT_DOUBLE =  2
local CT_THREE =3
local CT_SINGLE_LINE = 4
local CT_DOUBLE_LINE = 5
local CT_THREE_LINE = 6
local CT_THREE_TAKE_TWO = 8
local CT_THREE_TAKE_ONE= 7
local CT_FOUR_TAKE_TWO = 10
local CT_FOUR_TAKE_ONE = 9
local CT_BOMB_CARD= 11
local CT_MISSILE_CARD = 12

local log = gt.log

function GameLaiziLogic:log(...)
	log(...)
end

-- ´´½¨¿ÕÆË¿ËÊý×é1a
function GameLaiziLogic:emptyCardList( count )
    local tmp = {}
    for i = 1, count do
        tmp[i] = 0
    end
    return tmp
end

-- »ñÈ¡ÓàÊý
function GameLaiziLogic:mod(a, b)
    return a - math.floor(a/b)*b
end

-- »ñÈ¡ÕûÊý
function GameLaiziLogic:ceil(a, b)
    return math.ceil(a/b) - 1
end

-- »ñÈ¡ÅÆÖµ(1-15)
function GameLaiziLogic:GetCardValue(nCardData)
    --return bit:_and(nCardData, 0X0F)    -- ÊýÖµÑÚÂë
    if not nCardData then return nil end
    return yl.POKER_VALUE[nCardData]
end

-- »ñÈ¡»¨É«(1-5)
function GameLaiziLogic:GetCardColor(nCardData)
    --return bit:_and(nCardData, 0XF0)    --»¨É«ÑÚÂë
    if not nCardData  then return nil end
    return yl.POKER_COLOR[nCardData]
end

-- Âß¼­ÅÆÖµ(´óÐ¡Íõ¡¢2¡¢A¡¢K¡¢Q)
function GameLaiziLogic:GetCardLogicValue(nCardData) --bbb

    local nCardValue = self:GetCardValue(nCardData)
    local nCardColor = self:GetCardColor(nCardData)
    if nCardColor == 0x40 then
    	
        return nCardValue + 2
    end
    if nCardValue then
 
    	return nCardValue <= 2 and (nCardValue + 13) or nCardValue
	end
end

-- »ñÈ¡ÅÆÐò 0x4F´óÍõ 0x4EÐ¡Íõ nilÅÆ±³ 
function GameLaiziLogic:GetCardIndex(nCardData)
    if nCardData == 0x4E then
       return 53
    elseif nCardData == 0x4F then
       return 54
    elseif nCardData == nil then
       return 55
    end
    local nCardValue = self:GetCardValue(nCardData)
    local nCardColor = self:GetCardColor(nCardData)
    nCardColor = bit:_rshift(nCardColor, 4)
    return nCardColor * 13 + nCardValue
end

--排序
function GameLaiziLogic:SortCardList(cbCardData, cbCardCount, cbSortType)
    local cbSortValue = {}
    for i=1,cbCardCount do
        local value = self:GetCardLogicValue(cbCardData[i])
        table.insert(cbSortValue, i, value)
    end
    if cbSortType == 0 then --
        for i=1,cbCardCount-1 do
            for j=1,cbCardCount-1 do
                if (cbSortValue[j] < cbSortValue[j+1]) or (cbSortValue[j] == cbSortValue[j+1] and cbCardData[j] < cbCardData[j+1]) then
                    local temp = cbSortValue[j]
                    cbSortValue[j] = cbSortValue[j+1]
                    cbSortValue[j+1] = temp
                    local temp2 = cbCardData[j]
                    cbCardData[j] = cbCardData[j+1]
                    cbCardData[j+1] = temp2
                end
            end
        end
    end
    return cbCardData
end

--»ñÈ¡´ÓÐ¡µ½´óµÄÅÅÐò
function GameLaiziLogic:SortCardListUp(cbCardData, cbCardCount)
	cbCardData = self:SortCardList(cbCardData, cbCardCount,0)
	
	local tempList = {}
	for i=#cbCardData,1 ,-1 do
		table.insert(tempList,cbCardData[i])
	end
	return tempList
end 

--Ä³ÅÆÎ»ÖÃ
function GameLaiziLogic:GetOneCardIndex(cbCardData,nCardData)
    local index = 1
    local value = self:GetCardLogicValue(nCardData)
    local i = 1
    while i <= #cbCardData do
        if nCardData == cbCardData[i] then
            index = i
            break
        end
        i = i + 1
    end
    return index
end

--²åÈëÎ»ÖÃ
function GameLaiziLogic:GetAddIndex(cbCardData,nCardData)
    local index = #cbCardData+1
    local value = self:GetCardLogicValue(nCardData)
    local i = 1
    while i <= #cbCardData do
        local value2 = self:GetCardLogicValue(cbCardData[i])
        if (value > value2) or (value == value2 and nCardData > cbCardData[i])  then
            index = i
            break
        end
        i = i + 1
    end
    --print("²åÈëÎ»ÖÃ:".. value ..",".. index)
    return index
end

--²åÈëÒ»ÕÅÅÆ
function GameLaiziLogic:AddOneCard(cbCardData,nCardData,index)
    local cardDatas = {}
    local total = #cbCardData+1
    for i=1,total-1 do
        cardDatas[i] = cbCardData[i]
    end
    for i=total,index+1,-1 do
        cardDatas[i] = cardDatas[i-1]
    end
    cardDatas[index] = nCardData
    return cardDatas
end

--É¾³ýÒ»ÕÅÅÆ
function GameLaiziLogic:RemoveOneCard(cbCardData,index)
    local cardDatas = {}
    local total = #cbCardData-1
    for i=1,index-1 do
        cardDatas[i] = cbCardData[i]
    end
    for i=index,total do
        cardDatas[i] = cbCardData[i+1]
    end
    return cardDatas
end

--·ÖÎöÓÐÐòÆË¿Ë
function GameLaiziLogic:AnalysebCardData2(cbCardData, cbCardCount) --aaa
    --ÏàÍ¬¸öÊý
   -- print("AnalysebCardData________________")
    local cbBlockCount = {0,0,0,0,0}
    --ÏàÍ¬µÄÅÆ
    local cbCardDatas = {{-1},{-1},{-1},{-1},{-1}}

    for i = 1 , 5 do
    	for j =1 , 20 do
    		cbCardDatas[i][j] = -1
    	end
	end
    local i = 1
  
    while i <= cbCardCount do
        local cbSameCount = 1
        local cbLogicValue = self:GetCardLogicValue(cbCardData[i])
        local j = i+1
        while j <= cbCardCount do
            local cbLogicValue2 = self:GetCardLogicValue(cbCardData[j])
            if cbLogicValue ~= cbLogicValue2 then
                break
            end
            cbSameCount = cbSameCount + 1
            j = j + 1
        end
       -- print("cbSameCount................."..cbSameCount)
		if cbLogicValue == 18 then
			
				cbCardDatas[5][1] = cbCardData[cbCardCount]
		
		else
			cbBlockCount[cbSameCount] = cbBlockCount[cbSameCount] + 1
			local index = cbBlockCount[cbSameCount] - 1
			--print("index____________"..index)
			for k=1,cbSameCount do
				cbCardDatas[cbSameCount][index*cbSameCount+k] = cbCardData[i+k-1] -- 
			end
		end 
        i = i + cbSameCount
    end

 

    return cbCardDatas
end


--·ÖÎöÓÐÐòÆË¿Ë
function GameLaiziLogic:AnalysebCardData1(cbCardData, cbCardCount) --aaa
    --ÏàÍ¬¸öÊý
   
    local cbBlockCount = {0,0,0,0,0}
    --ÏàÍ¬µÄÅÆ
    local cbCardDatas = {{-1},{-1},{-1},{-1},{-1}}

    for i = 1 , 5 do
    	for j =1 , 20 do
    		cbCardDatas[i][j] = -1
    	end
	end
    local i = 1
  
    while i <= cbCardCount do
        local cbSameCount = 1
        local cbLogicValue = self:GetCardLogicValue(cbCardData[i])
        local j = i+1
        while j <= cbCardCount do
            local cbLogicValue2 = self:GetCardLogicValue(cbCardData[j])
            if cbLogicValue ~= cbLogicValue2 then
                break
            end
            cbSameCount = cbSameCount + 1
            j = j + 1
        end
       
		if cbLogicValue == 18 then
			
				cbCardDatas[5][1] = cbCardData[cbCardCount]
		
		else
			cbBlockCount[cbSameCount] = cbBlockCount[cbSameCount] + 1
			local index = cbBlockCount[cbSameCount] - 1
			--print("index____________"..index)
			for k=1,cbSameCount do
				cbCardDatas[cbSameCount][index*cbSameCount+k] = cbCardData[i+k-1] -- 
			end
		end 
        i = i + cbSameCount
    end

 

    return cbCardDatas
end

--·ÖÎöÓÐÐòÆË¿Ë
function GameLaiziLogic:AnalysebCardData(cbCardData, cbCardCount) --aaa
    --ÏàÍ¬¸öÊý
    local cbBlockCount = {0,0,0,0,0}
    --ÏàÍ¬µÄÅÆ
    local cbCardDatas = {{},{},{},{},{}}
    local i = 1
    while i <= cbCardCount do
        local cbSameCount = 1
        local cbLogicValue = self:GetCardLogicValue(cbCardData[i])
        local j = i+1
        while j <= cbCardCount do
            local cbLogicValue2 = self:GetCardLogicValue(cbCardData[j])
            if cbLogicValue ~= cbLogicValue2 then
                break
            end
            cbSameCount = cbSameCount + 1
            j = j + 1
        end
        if cbSameCount > 4 then
            --print("Õâ¶ùÓÐ´íÎó")
            return
        end
		if cbLogicValue == 18 then
			cbBlockCount[5] = cbBlockCount[5] + 1
			local index = cbBlockCount[5] - 1
			for k=1,cbSameCount do
				cbCardDatas[5][index*5+k] = cbCardData[i+k-1]
			end
		else
			cbBlockCount[cbSameCount] = cbBlockCount[cbSameCount] + 1
			local index = cbBlockCount[cbSameCount] - 1
			for k=1,cbSameCount do
				cbCardDatas[cbSameCount][index*cbSameCount+k] = cbCardData[i+k-1]
			end
		end 
       
        
        i = i + cbSameCount
    end
    --·ÖÎö½á¹¹
    local tagAnalyseResult = {cbBlockCount,cbCardDatas}
    return tagAnalyseResult
end

--  num 剩余手牌
function GameLaiziLogic:GetCardType1(cards,num,landType)
	gt.log(">?>>>>>>>>>>>>>>>>>>>")
	-- body
	local buf = {}
	local lenbuf = 0
	
	

	local card 
	local tbuf
	if #cards ~= 0 then
		card = self:SortCardListUp(cards,#cards,0)
		tbuf = GameLaiziLogic:AnalysebCardData2(card,#card)
	else
		buf[100] = -1
		lenbuf = -1
		return buf,lenbuf
	end
	gt.log("GameLaiziLogic:GetCardLogicValue(card[#card])===",GameLaiziLogic:GetCardLogicValue(card[#card]))
	if GameLaiziLogic:GetCardLogicValue(card[#card]) ~= 18 then 
		if #card == 1 then
			
			buf[CT_SINGLE] = GameLaiziLogic:GetCardLogicValue(card[1])  -- key 类型 value 最小点数
		elseif #card == 2 then
		
			if card[2] == 0x4F and card[1] == 0x4E then
	            buf[CT_MISSILE_CARD] = GameLaiziLogic:GetCardLogicValue(card[1])
	        end
			if card[1] == 0x4F and card[2] == 0x4E then
	           	buf[CT_MISSILE_CARD] = GameLaiziLogic:GetCardLogicValue(card[1])
	        end
	        if landType ~= 1  then
		        if GameLaiziLogic:GetCardLogicValue(card[1]) == GameLaiziLogic:GetCardLogicValue(card[2]) then
					if GameLaiziLogic:GetCardLogicValue(card[1]) == 3 then
						if landType == 2  then -- 带花
							if gt.three_bomb then
								local colorValue = yl.POKER_COLOR[card[1]] + yl.POKER_COLOR[card[2]]
								if colorValue == 32 or colorValue == 64 then
									buf[CT_BOMB_CARD] = 1
								else
									buf[CT_DOUBLE] = GameLaiziLogic:GetCardLogicValue(card[1]) -- 
								end
							else
								buf[CT_BOMB_CARD] = 1
							end
						else
							buf[CT_BOMB_CARD] = 1
						end
					elseif GameLaiziLogic:GetCardLogicValue(card[1]) == 15 then
						if landType == 3 then
							 buf[CT_BOMB_CARD] = 2
						else
							buf[CT_DOUBLE] = GameLaiziLogic:GetCardLogicValue(card[1]) -- 
						end
					else
						buf[CT_DOUBLE] = GameLaiziLogic:GetCardLogicValue(card[1]) -- 
					end
		        end
	    	else
	    		if GameLaiziLogic:GetCardLogicValue(card[1]) == GameLaiziLogic:GetCardLogicValue(card[2]) then
	    			buf[CT_DOUBLE] = GameLaiziLogic:GetCardLogicValue(card[1]) -- 
	    		end
	    	end
	    elseif #card == 3 then
	    	if landType == 3 then
		    	if num and num == 3 and GameLaiziLogic:GetCardLogicValue(card[1]) == GameLaiziLogic:GetCardLogicValue(card[2]) and 
		    	GameLaiziLogic:GetCardLogicValue(card[1]) == GameLaiziLogic:GetCardLogicValue(card[3]) and GameLaiziLogic:GetCardLogicValue(card[1]) ~= 3 then
		    		 buf[CT_THREE] = GameLaiziLogic:GetCardLogicValue(card[1])
		    		 lenbuf = 1 
		    	end
		    else
		    	if GameLaiziLogic:GetCardLogicValue(card[1]) == GameLaiziLogic:GetCardLogicValue(card[2]) and 
		    		GameLaiziLogic:GetCardLogicValue(card[1]) == GameLaiziLogic:GetCardLogicValue(card[3]) then
		    		buf[CT_THREE] = GameLaiziLogic:GetCardLogicValue(card[1])
		    		lenbuf = 1 
		    	end
	    	end
	    elseif #card == 4 then
	    	
	    	if tbuf[4][4] ~= -1 then
	    		if landType == 2 then-- and GameLaiziLogic:GetCardLogicValue(card[1]) ~= 3 then
	    			gt.log("here___________come")
	    			buf[CT_BOMB_CARD] = GameLaiziLogic:GetCardLogicValue(card[1])
	    		elseif landType ~= 2 then
	    			buf[CT_BOMB_CARD] = GameLaiziLogic:GetCardLogicValue(card[1])
	    		end

	    	elseif tbuf[3][3] ~=-1 and tbuf[1][1] ~= -1  then
	    		lenbuf = 1 
	    		buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][3])
	    	elseif tbuf[3][3] ~=-1 and self:GetCardLogicValue(tbuf[3][3]) == 15 and tbuf[5][1] ~= -1 then
	    		buf[CT_THREE_TAKE_ONE] = 15
	    	end
	    elseif #card == 5 then
	    	
	    	if tbuf[1][5] ~= -1 then
	    	
	    		if(self:isShunzi(tbuf,5)) then
	    			
	    			lenbuf = 5
	    			buf[CT_SINGLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[1][1])
	    		end
	    	end
	    	if landType == 1 or landType == 2 then
	    		if tbuf[3][3] ~= -1 and tbuf[2][2] ~= -1 then
	    			
	    			buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][3])
	    			lenbuf = 1
	    		end
	    		
	    	end
	    elseif #card == 6 then
	    	
	    	if tbuf[1][6] ~= -1 then -- 顺子
	    		if(self:isShunzi(tbuf,6)) then
	    			lenbuf = 6
	    			buf[CT_SINGLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[1][1])
	    		end
	    	elseif tbuf[4][4] ~= -1 then -- 四代二
	   
	    		buf[CT_FOUR_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[4][4])
	    	elseif tbuf[2][6] ~= -1 then -- 连队
	    		if(self:isLiandui(tbuf,6)) then
	    			lenbuf = 3
	    			buf[CT_DOUBLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][1])
	    			gt.log("liandui_____c",GameLaiziLogic:GetCardLogicValue(tbuf[2][1]))
	    		end
	    	elseif tbuf[3][6] ~= -1 then -- 三连
	    		if num and self:isfeiji(tbuf,#card) and num ==6 then
	    			lenbuf = 2
	    			buf[CT_THREE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    		end
	    	end
	    	if landType == 1 then
	    		if tbuf[3][6] ~= -1 then -- 三连
	    			if self:isfeiji(tbuf,#card) then
	    				buf[CT_THREE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    				lenbuf = 2
	    			end
	    		end
	    	end
	    elseif #card == 7 then
	    	
	    	if tbuf[1][7] ~= -1 then -- 顺子
	    		if(self:isShunzi(tbuf,7)) then
	    			lenbuf = 7
	    			buf[CT_SINGLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[1][1])
	    		end
	    	end
	    elseif #card == 8 then
	    	
	    	if tbuf[1][8] ~= -1 then -- 顺子
	    		
	    		if(self:isShunzi(tbuf,8)) then
	    			lenbuf = 8
	    			buf[CT_SINGLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[1][1])
	    		end
	    	elseif tbuf[2][8] ~= -1 then
	    		
	    		if(self:isLiandui(tbuf,8)) then
	    			lenbuf = 4
	    			buf[CT_DOUBLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][1])
	    		end
	    	elseif tbuf[3][6] ~= -1 then
	    		
	    		if self:isfeiji(tbuf,6) then
	    			lenbuf = 2
	    			buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    		end
	    	end
	    	if landType == 1 then 

	    		if tbuf[4][4] ~= -1 and tbuf[2][4] ~= -1 then
	    			buf[CT_FOUR_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[4][4])

	    		end
	    	end
	    	if  landType == 2 then 
	    		gt.log("tbuf[3][3]",tbuf[3][3])
	    		gt.log("tbuf[2][4]",tbuf[2][4])
	    		gt.log("tbuf[5][1]",tbuf[5][1])
	    		if tbuf[3][3] ~= -1 and tbuf[2][4] ~= -1 and tbuf[5][1] ~= -1  then
	    			buf[CT_FOUR_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][3])
	    		end
	    		if tbuf[4][4] ~= -1 and tbuf[2][2] ~= -1 and tbuf[5][1] ~= -1 and tbuf[1][1] ~= -1  then
	    			buf[CT_FOUR_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[4][4])
	    		end

	    		if tbuf[4][4] ~= -1 and tbuf[2][4] ~= -1 then
	    			buf[CT_FOUR_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[4][4])

	    		end
	    	end
	    elseif #card == 9 then
	    	
	    	if tbuf[1][9] ~= -1 then -- 顺子
	    		if(self:isShunzi(tbuf,9)) then
	    			lenbuf = 9
	    			buf[CT_SINGLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[1][1])
	    		end
	    	elseif  tbuf[3][9] ~= -1 then -- 三连
	    		if num and self:isfeiji(tbuf,#card) and num ==9 then
	    			lenbuf = 3
	    			buf[CT_THREE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    		end
	    	end
	    	if landType == 1 then
	    		if tbuf[3][9] ~= -1 and self:isfeiji(tbuf,#card) then
	    			buf[CT_THREE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    			lenbuf = 3
	    		end
	    	end
	    elseif #card == 10 then
	    	
	    	if tbuf[1][10] ~= -1 then -- 顺子
	    		if(self:isShunzi(tbuf,10)) then
	    			lenbuf = 10
	    			buf[CT_SINGLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[1][1])
	    		end
	    	elseif tbuf[2][10] ~= -1 then
	    		if(self:isLiandui(tbuf,10)) then
	    			lenbuf = 5
	    			buf[CT_DOUBLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][1])
	    		end
	    	end
	    	if landType == 1 or landType == 2 then
	    		if tbuf[3][6] ~= -1 and tbuf[2][4] ~= -1 and self:isfeiji(tbuf,#card-4) then --10000
	    			buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    			lenbuf = 2
	    		end
	    	end
	    elseif #card == 11 then
	    	
	    	if tbuf[1][11] ~= -1 then -- 顺子
	    		if(self:isShunzi(tbuf,11)) then
	    			lenbuf = 11
	    			buf[CT_SINGLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[1][1])
	    		end
	    	end
	    elseif #card == 12 then
	    	
	    	if tbuf[1][12] ~= -1 then -- 顺子
	    		if(self:isShunzi(tbuf,12)) then
	    			lenbuf = 12
	    			buf[CT_SINGLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[1][1])
	    		end
	    	elseif tbuf[2][12] ~= -1 then
	    		if(self:isLiandui(tbuf,12)) then
	    			lenbuf = 6
	    			buf[CT_DOUBLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][1])
	    		end
	    	elseif  tbuf[3][12] ~= -1 then -- 三连
	    		if num and self:isfeiji(tbuf,#card) and num ==12 then
	    			lenbuf = 4
	    			buf[CT_THREE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])

	    		elseif self:isfeiji(tbuf,9) then
	    			lenbuf = 3
	    			buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    		elseif self:isfeiji_12(tbuf,#card) then
	    			lenbuf = 3
	    			buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][4])
	    		end
	    	elseif tbuf[3][9] ~= -1 then
	    		if self:isfeiji(tbuf,9) then
	    			lenbuf = 3
	    			buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    		end
	    	end
	    	if landType == 1 then
	    		if tbuf[3][12] ~= -1 and self:isfeiji(tbuf,#card) then
	    			buf[CT_THREE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    			lenbuf = 4
	    		end
	    	end
	    elseif #card == 14 then
	    	if tbuf[2][14] ~= -1 then
	    		if(self:isLiandui(tbuf,14)) then
	    			lenbuf = 7
	    			buf[CT_DOUBLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][1])
	    		end
	    	end 
	    elseif #card ==15 then
	    	if  tbuf[3][15] ~= -1 then -- 三连
	    		if num and self:isfeiji(tbuf,#card) and num ==15 then
	    			lenbuf = 5
	    			buf[CT_THREE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    		end
	    	end

			gt.log("飞机带队————————————")
	    	if landType == 1 or landType == 2 then
	    		gt.log("飞机带队————————————1",tbuf[3][9])
	    		gt.log("飞机带队————————————1",tbuf[2][6])
	    		if tbuf[3][9] ~= -1 and tbuf[2][6] ~= -1 and self:isfeijis(tbuf,#card-6) then --10000
	    			gt.log("飞机带队————————————2")
	    			buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    			lenbuf = 3
	    		end
	    	end
	    elseif #card == 16 or #card == 18 or #card == 20  then

	    	if tbuf[2][#card] ~= -1 then
	    		if self:isLiandui(tbuf,#card) then
	    			lenbuf = #card *0.5
	    			buf[CT_DOUBLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][1])
	    		end
	    	end 
	    	if  #card == 16  then
	    		if tbuf[3][12] ~= -1 then
		    		if self:isfeiji(tbuf,12) then
		    			lenbuf = 4
		    			buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
		    		end
	    		end
	    	end
	    	if  #card == 20 then
	    		if tbuf[3][15] ~= -1 then
		    		if self:isfeiji(tbuf,15) then
		    			lenbuf = 5
		    			buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
		    		end
	    		end
	    	end
	    	if landType == 1 or landType == 2 then
	    		if tbuf[3][12] ~= -1 and tbuf[2][8] ~= -1 and self:isfeiji(tbuf,#card-8) then --10000
	    			buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	    			lenbuf = 4
	    		end
	    	end
		end

	else
		if #card == 1 then
			if num and num == 1 then
				buf[CT_SINGLE] = GameLaiziLogic:GetCardLogicValue(card[1])
			end
		elseif #card == 2 then
			--print("GameLaiziLogic:GetCardLogicValue(card[1])"..GameLaiziLogic:GetCardLogicValue(card[1]))
			if  GameLaiziLogic:GetCardLogicValue(card[1]) ~= 3 and  GameLaiziLogic:GetCardLogicValue(card[1]) ~= 15 and 
				GameLaiziLogic:GetCardLogicValue(card[1]) ~= 16 and GameLaiziLogic:GetCardLogicValue(card[1]) ~= 17 then
					 buf[CT_DOUBLE] = GameLaiziLogic:GetCardLogicValue(card[1])
			end
		elseif #card == 3 then

			if tbuf[2][2] ~= -1 and GameLaiziLogic:GetCardLogicValue(tbuf[2][2]) ~= 15 and GameLaiziLogic:GetCardLogicValue(tbuf[2][2]) ~= 3 then
				if num and num == 3 then
					 buf[CT_THREE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][2])
				end
			end
		elseif #card == 4 then
			if tbuf[3][3] ~= -1 and GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) ~= 15 and GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) ~= 3 then
				buf[CT_BOMB_CARD] = GameLaiziLogic:GetCardLogicValue(card[1])
			elseif tbuf[2][2] ~= -1 and  GameLaiziLogic:GetCardLogicValue(tbuf[2][2]) ~= 15 and GameLaiziLogic:GetCardLogicValue(tbuf[2][2]) ~= 3 then 
				buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][2])
				lenbuf = 1
			end
		elseif #card == 5 then -- weiwan
			if tbuf[1][#card-1] ~= -1 then
				buf ,lenbuf = self:shunzi(tbuf,#card)
			end

			if tbuf[3][3] ~= -1 and tbuf[1][1] ~= -1 and tbuf[5][1] ~= -1 and self:is(tbuf[1][1]) then 
    			buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][3])
    			lenbuf = 1
    		end
    		if tbuf[2][4] ~= -1 and tbuf[5][1] ~= -1 and self:is(tbuf[2][4]) then 
    			buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[2][2])
    			lenbuf = 1
    			
    		end
    		if tbuf[2][4] ~= -1 and tbuf[5][1] ~= -1 then 
    			if self:is(tbuf[2][4]) then 
	    			buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[2][4])
	    			lenbuf = 1
	    		elseif self:is(tbuf[2][2]) then 
	    			buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[2][2])
	    			lenbuf = 1
   				end
    		end
    		
    		--gt.log("c___s____w")
		elseif #card == 6 then
			if tbuf[1][#card-1] ~= -1 then
				buf ,lenbuf = self:shunzi(tbuf,#card)
			elseif tbuf[3][3] ~= -1 and self:is(tbuf[3][3]) then -- 4dai2
				buf[CT_FOUR_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][3])
			elseif tbuf[2][4] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1]) then -- 连对
				buf ,lenbuf = self:liandui(tbuf,#card)
				-- 不做3张 不带处理 单做 4带2 处理
			-- elseif tbuf[3][3] ~= -1 and tbuf[2][2] ~= -1 and self:is(tbuf[2][2]) then
			-- 	if self:GetCardLogicValue(tbuf[3][3]) - self:GetCardLogicValue(tbuf[2][2]) == 1 and num then

			-- 	end
			end
		elseif #card == 7 then
			if tbuf[1][#card-1] ~= -1 then
				buf ,lenbuf = self:shunzi(tbuf,#card)
			end
		elseif #card == 8 then
			
			if tbuf[1][#card-1] ~= -1 then
				
				buf ,lenbuf = self:shunzi(tbuf,#card)
			elseif tbuf[2][#card-2] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1]) then
				
				buf ,lenbuf = self:liandui(tbuf,#card)
			elseif tbuf[3][6] ~= -1 then
				
				if self:isfeiji(tbuf,6) then
					lenbuf = 2
					buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
				end
--			elseif tbuf[3][3] ~= -1 and tbuf[2][2] ~= -1 and self:is(tbuf[2][2]) then
--				gt.log("====================飞机1")
--				local a = GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) - GameLaiziLogic:GetCardLogicValue(tbuf[2][2]) -- dnf
--				if a == -1 then
--					lenbuf = 2
--					buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
--				elseif a == 1 then
--					lenbuf = 2
--					buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][1])
--				end
--                if tbuf[2][4] ~= -1 and self:is(tbuf[2][4]) then
--                    gt.log("====================飞机2")
--				    local a = GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) - GameLaiziLogic:GetCardLogicValue(tbuf[2][4]) -- dnf
--				    if a == -1 then
--					    lenbuf = 2
--					    buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
--				    elseif a == 1 then
--					    lenbuf = 2
--					    buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][4])
--				    end
--                end
			end
			if  landType == 2 then 
	    		gt.log("tbuf[3][3]",tbuf[3][3])
	    		gt.log("tbuf[2][4]",tbuf[2][4])
	    		gt.log("tbuf[5][1]",tbuf[5][1])

	    		if tbuf[3][3] ~= -1 and tbuf[2][4] ~= -1 and tbuf[5][1] ~= -1 and self:is(tbuf[3][3]) then
                    gt.log("===================1= 4带2 ")
	    			buf[CT_FOUR_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][3])
	    		end
	    		if tbuf[4][4] ~= -1 and tbuf[2][2] ~= -1 and tbuf[5][1] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1]) then
                gt.log("===================2= 4带2 ")
	    			buf[CT_FOUR_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[4][4])
	    		end

	    		if tbuf[4][4] ~= -1 and tbuf[2][4] ~= -1 then
                gt.log("===================3= 4带2 ")
	    			buf[CT_FOUR_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[4][4])

	    		end
	    	end
            --飞机的判断挪到4带2的后边，还需要加一个判断，带的是两个三的情况，self:is(tbuf[2][2])返回的是false
            if tbuf[3][3] ~= -1 then
				
                --if GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) == 4 then  --如果3连是4的情况，tbuf[2][2]，只能是3，不走self:is(tbuf[2][2])
                
                --end
                if tbuf[2][2] ~= -1 and self:is(tbuf[2][2]) then
                    gt.log("====================飞机1")
                    local a = GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) - GameLaiziLogic:GetCardLogicValue(tbuf[2][2]) -- dnf
				    if a == -1 then
					    lenbuf = 2
					    buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
				    elseif a == 1 then
					    lenbuf = 2
					    buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][1])
				    end
                end

				
                if tbuf[2][4] ~= -1 and self:is(tbuf[2][4]) then
                    gt.log("====================飞机2")
				    local a = GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) - GameLaiziLogic:GetCardLogicValue(tbuf[2][4]) -- dnf
				    if a == -1 then
					    lenbuf = 2
					    buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
				    elseif a == 1 then
					    lenbuf = 2
					    buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[2][4])
				    end
                end
            end
		elseif #card == 9 then
			gt.log("9_______________",num)
			if tbuf[1][#card-1] ~= -1 then
				buf ,lenbuf = self:shunzi(tbuf,#card)
			end
			if tbuf[3][6] ~= -1 and tbuf[2][2] ~= -1 and self:is(tbuf[2][2]) and num and num == 9 then
				buf , lenbuf = self:feiji(tbuf,#card,1)
				gt.log("ok________________")
			end
		elseif #card == 10 then
			if tbuf[1][#card-1] ~= -1 then
				buf ,lenbuf = self:shunzi(tbuf,#card)
			elseif tbuf[2][#card-2] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1]) then
				buf ,lenbuf = self:liandui(tbuf,#card)
			elseif tbuf[3][#card-4] ~= -1 and self:isfeiji(tbuf,#card-4) and tbuf[2][2] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1]) then -- 飞机 花牌做带
				gt.log("ok______________")
				buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
				lenbuf = 2
			elseif tbuf[3][3] ~= -1  and tbuf[2][6] ~= -1 then -- 花牌做飞机 带

				local bool = false
				for i = 1, 6 do
					if i % 2 == 1 then 
						if math.abs( GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) - GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) )== 1 then 
							if GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) > GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) then 
								buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][3])
								lenbuf = 2
								bool = true
							end
						end
					end
				end
				if not bool then 
					for i = 1, 6 do
						if i % 2 == 1 then 
							if math.abs( GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) - GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) )== 1 then 
								if GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) < GameLaiziLogic:GetCardLogicValue(tbuf[3][3]) then 
									buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[2][i])
									lenbuf = 2
								end
							end
						end
					end
				end

			end

		elseif #card == 11 then
			if tbuf[1][#card-1] ~= -1 then
				buf ,lenbuf = self:shunzi(tbuf,#card)
			end
		elseif #card == 12 then
			if tbuf[1][#card-1] ~= -1 then
				buf ,lenbuf = self:shunzi(tbuf,#card)
			elseif  tbuf[2][#card-2] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1])  then
				buf ,lenbuf = self:liandui(tbuf,#card)

			elseif tbuf[3][#card-6] ~= -1 and tbuf[2][2] ~= -1 and self:is(tbuf[2][2]) then -- 飞机 花牌做飞机 
				buf , lenbuf = self:feiji(tbuf,#card-3,2,tbuf[2][2])
				
				if lenbuf == 0 and tbuf[2][4] ~= -1 then 
					buf , lenbuf = self:feiji(tbuf,#card-3,2,tbuf[2][4])
				end
				gt.log("here________")
			elseif tbuf[3][#card-3] ~= -1 and self:isfeiji(tbuf,#card-3) then -- 飞机 花牌做带
				lenbuf = (#card-3)/3
				buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
			elseif tbuf[3][#card-3] ~= -1 and tbuf[2][2] ~= -1 and self:is(tbuf[2][2]) and num and num == #card then -- 三连
				buf , lenbuf = self:feiji(tbuf,#card,1)
			end
		elseif #card == 14 then
			if  tbuf[2][#card-2] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1])  then
				buf ,lenbuf = self:liandui(tbuf,#card)
			end
		elseif #card == 15 then
			gt.log("card————————————",#card)
			if tbuf[3][12] ~= -1 and tbuf[2][2] ~= -1 and self:is(tbuf[2][2]) and num and num == 15 then
				buf , lenbuf = self:feiji(tbuf,#card,1)
			elseif tbuf[3][6] ~= -1  and tbuf[2][8] ~= -1 then -- 花牌做飞机 带 -ccc   
	    		local tmp = {}
	    		for i = 1, 6 do
	    			gt.log("cccccccccccc",GameLaiziLogic:GetCardLogicValue(tbuf[3][i]))
	    			table.insert(tmp,tbuf[3][i])
	    		end

	    		tmp = self:SortCardListUp(tmp,#tmp,0) -- 升序
	    		
	    		if GameLaiziLogic:GetCardLogicValue(tmp[4]) - GameLaiziLogic:GetCardLogicValue(tmp[1]) == 1 then 

					local bool = false
					for i = 1, 8 do
						if i % 2 == 1 then 
							if math.abs( GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) - GameLaiziLogic:GetCardLogicValue(tbuf[3][4]) )== 1 then 
								gt.log("csw__________c")
								if GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) > GameLaiziLogic:GetCardLogicValue(tbuf[3][4]) and GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) <= 14 then 
									gt.log("csw__________c1")
									buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
									lenbuf = 3
									bool = true
								end
							end
						end
					end
					if not bool then 
						for i = 1, 8 do
							if i % 2 == 1 then 
								gt.log("csw_______c2",GameLaiziLogic:GetCardLogicValue(tbuf[2][i]))
								if math.abs( GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) - GameLaiziLogic:GetCardLogicValue(tbuf[3][1]) )== 1 and GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) ~= 3  then 
									if GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) < GameLaiziLogic:GetCardLogicValue(tbuf[3][1]) then 
										buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[2][i])
										lenbuf = 3
									end
								end
							end
						end
					end
				elseif GameLaiziLogic:GetCardLogicValue(tmp[4]) - GameLaiziLogic:GetCardLogicValue(tmp[1]) == 2 then 
					gt.log("buf__ccc",GameLaiziLogic:GetCardLogicValue(tmp[4]))
					for i = 1, 8 do 
						if i% 2 == 1 then 
							gt.log("buf__c",i,GameLaiziLogic:GetCardLogicValue(tmp[4]) - GameLaiziLogic:GetCardLogicValue(tbuf[2][i]))
							if GameLaiziLogic:GetCardLogicValue(tmp[4]) - GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) == 1 then 
								buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tmp[1])
								lenbuf = 3
							end
						end
					end

				end
			elseif  tbuf[3][9] ~= -1  and tbuf[2][4] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1]) then -- 飞机 花牌做带
				if self:isfeiji(tbuf,9) then 
					buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
					lenbuf = 3
				end
			
			end
		elseif #card == 16 then
			if  tbuf[2][#card-2] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1])  then
				buf ,lenbuf = self:liandui(tbuf,#card)
			end


			if tbuf[3][#card-7] ~= -1 and tbuf[2][2] ~= -1 and self:is(tbuf[2][2]) then -- 飞机 花牌做飞机 
				buf , lenbuf = self:feiji(tbuf,#card-4,2,tbuf[2][2])
				if lenbuf ==  0 and tbuf[2][4] ~= -1 then 
					buf , lenbuf = self:feiji(tbuf,#card-4,2,tbuf[2][4])
				end



			end
			if tbuf[3][#card-4] ~= -1 and self:isfeiji(tbuf,#card-4) then -- 飞机 花牌做带
				lenbuf = (#card-4)/3
				buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
			end

		elseif #card == 18 then
			if  tbuf[2][#card-2] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1])  then
				buf ,lenbuf = self:liandui(tbuf,#card)
			end
		elseif #card == 20 then
			if  tbuf[2][#card-2] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1])  then
				buf ,lenbuf = self:liandui(tbuf,#card)
			end

			if tbuf[3][#card-8] ~= -1 and tbuf[2][2] ~= -1 and self:is(tbuf[2][2]) then -- 飞机 花牌做飞机 
				buf , lenbuf = self:feiji(tbuf,#card-5,2,tbuf[2][2])
				if lenbuf ==  0 and tbuf[2][4] ~= -1 then 
					buf , lenbuf = self:feiji(tbuf,#card-4,2,tbuf[2][4])
				end
			end
			if tbuf[3][#card-5] ~= -1 and self:isfeiji(tbuf,#card-5) then -- 飞机 花牌做带
				lenbuf = (#card-5)/3
				buf[CT_THREE_TAKE_ONE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
			end

			if tbuf[3][9] ~= -1  and tbuf[2][10] ~= -1 then -- 花牌做飞机 带 -ccc   
	    		local tmp = {}
	    		for i = 1, 9 do
	    			table.insert(tmp,tbuf[3][i])
	    		end
	    		if  self:isfeiji(tmp,9)  then 

					local bool = false
					for i = 1, 10 do
						if i % 2 == 1 then 
							if math.abs( GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) - GameLaiziLogic:GetCardLogicValue(tbuf[3][9]) )== 1 then 
								if GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) > GameLaiziLogic:GetCardLogicValue(tbuf[3][9]) and GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) <= 14 then 
									buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
									lenbuf = 3
									bool = true
								end
							end
						end
					end
					if not bool then 
						for i = 1, 10 do
							if i % 2 == 1 then 
								if math.abs( GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) - GameLaiziLogic:GetCardLogicValue(tbuf[3][1]) )== 1 and GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) ~= 3  then 
									if GameLaiziLogic:GetCardLogicValue(tbuf[2][i]) < GameLaiziLogic:GetCardLogicValue(tbuf[3][1]) then 
										buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[2][i])
										lenbuf = 3
									end
								end
							end
						end
					end
				end
			end
			if  tbuf[3][12] ~= -1  and tbuf[2][6] ~= -1 and tbuf[1][1] ~= -1 and self:is(tbuf[1][1]) then -- 飞机 花牌做带
				local tmp = {}
	    		for i = 1, 12 do
	    			table.insert(tmp,tbuf[3][i])
	    		end

				if self:isfeiji(tmp,12) then 
					buf[CT_THREE_TAKE_TWO] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
					lenbuf = 4
				end

			end


		end
	end

	local null = false


	for k , y in pairs(buf) do
		null = true
	end

	if not null then
		buf[CT_ERROR] = 0
		lenbuf = -1
	end
	



	
	return buf,lenbuf


end

function  GameLaiziLogic:LzFeiji(card,buf)

	if card[2][#buf-4] ~= -1 and card[3][3] ~= -1 then 

		--for 

	end

	--if card[3][3]

end


-- 花牌不能 做2 and  3 
function GameLaiziLogic:is(buf)
	if GameLaiziLogic:GetCardLogicValue(buf)== 15 or GameLaiziLogic:GetCardLogicValue(buf)== 3 or  GameLaiziLogic:GetCardLogicValue(buf)== 16 or  GameLaiziLogic:GetCardLogicValue(buf)== 17 then
		return false
	else
		return true
	end
end

function GameLaiziLogic:feiji(tbuf,card,_type,cardvalue)

	local buf = {}
	local lenbuf = 0
	
	local t = {}
	for i = 1 , card -3 do
		if i % 3 == 1 then
			table.insert(t,GameLaiziLogic:GetCardLogicValue(tbuf[3][i]))
		end
	end
	if _type == 1 then 
		table.insert(t,GameLaiziLogic:GetCardLogicValue(tbuf[2][2]))
	else
		table.insert(t,GameLaiziLogic:GetCardLogicValue(cardvalue))
	end

	for i = 1 , #t do
		for j =i+1, #t do
			if t[i] < t[j] then
				local n = t[i]
				t[i] = t[j]
				t[j] = n
			end 
		end
	end
	if t[1] <=14 then
		for i = 1 , #t -1 do
			if t[i] - 1 ~= t[i+1] then
				return buf, lenbuf
			end
		end
		lenbuf = card/3
		if _type == 1 then
			buf[CT_THREE_LINE] = t[#t]
		elseif _type == 2  then
			buf[CT_THREE_TAKE_ONE] = t[#t]	
		end
	end


	-- if self:isLzFeiji(tbuf,card-3) == 2  then
	-- 	lenbuf = card/3
	-- 	buf[CT_THREE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	-- elseif self:isLzFeiji(tbuf,card-3) == 1 then
	-- 	lenbuf = card/3
	-- 	if GameLaiziLogic:GetCardLogicValue(tbuf[3][card-3]) == 14 then
	-- 		buf[CT_THREE_LINE] = 15 - card/3
	-- 	else
	-- 		buf[CT_THREE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[3][1])
	-- 	end
	-- end

	return buf , lenbuf
end

function GameLaiziLogic:liandui(tbuf,card)
	local buf = {}
	local lenbuf = 0

	local t = {}
	for i = 1 , card -2 do
		if i % 2 == 1 then
			table.insert(t,GameLaiziLogic:GetCardLogicValue(tbuf[2][i]))
		end
	end
	table.insert(t,GameLaiziLogic:GetCardLogicValue(tbuf[1][1]))

	for i = 1 , #t do
		for j =i+1, #t do
			if t[i] < t[j] then
				local n = t[i]
				t[i] = t[j]
				t[j] = n
			end 
		end
	end
	if t[1] <=14 then
		for i = 1 , #t -1 do
			if t[i] - 1 ~= t[i+1] then
				return buf, lenbuf
			end
		end
		lenbuf = card*0.5
		buf[CT_DOUBLE_LINE] = t[#t]
	end
	return buf, lenbuf
end

function GameLaiziLogic:shunzi(tbuf,card)
	local buf = {}
	local lenbuf = 0
	if GameLaiziLogic:GetCardLogicValue(tbuf[1][card-1]) <= 14 then
		if self:isLzSunzi(tbuf,card-1) == 2 then
			lenbuf = card
			buf[CT_SINGLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[1][1])
		elseif self:isLzSunzi(tbuf,card-1) == 1 then
			lenbuf = card
			if GameLaiziLogic:GetCardLogicValue(tbuf[1][card-1]) == 14 then
				if card ~= 12 then
					buf[CT_SINGLE_LINE] = 15 - card
				else
					lenbuf = 0	
				end
			else
				buf[CT_SINGLE_LINE] = GameLaiziLogic:GetCardLogicValue(tbuf[1][1])
			end
		end
	end
	return buf , lenbuf
end

-- 1 card 手牌结构
-- 2 num 上家出顺子长
-- 3 balue 上家顺子最小值
function GameLaiziLogic:findLzSunzi(card,num,value,tishiBuf) --iii


	if value + num - 1 == 14 then return end
	
	local t = {}
	local buf = {}
	for i = 1 ,#card[1] do
		if card[1][i] ~= -1  then
			if self:GetCardLogicValue(card[1][i]) < 15 then 
				table.insert(t,card[1][i])
			end
		end
	end
	for i = 2 , 4 do
		for j =1 , #card[i] do	
		if 	card[i][j] ~= -1 then
			if j%i == 1 then
				if self:GetCardLogicValue(card[i][j]) ~= 15 then  --~= 2
					table.insert(t,card[i][j])
				end
			end	
		end
		end
	end
	
	buf = self:SortCardListUp(t,#t,0) -- 升序

	local idx = 100

	for i = 1 , #buf do
		log(self:GetCardLogicValue(buf[i]))
	end

	for i = 1 ,#buf do
		if self:GetCardLogicValue(buf[i]) >value  then
			idx = i 
			break
		end
	end
	log("idx.....",idx,value)
	t = {}
	for i = idx , #buf do
		table.insert(t,buf[i])
		log("t[i]",self:GetCardLogicValue(buf[i]))
	end

	log(#t)
	
	

	local cards = {}

	local j = 0
	local a = 0
	local b = 0
	local exit = false 
	
	for j = 1 , #t do -- =6    #t = 12
	  	a = 0 
	  	b = 0
	  	--log("max_____")
	  	cards = {}
			for i = j , #t -1 do  -- 1 , 3 
				if i == #t -1 then
					exit = true
				end
				if t[i+1] ~= nil then
					--if i == 3 then log("333", self:GetCardLogicValue(t[i+1])) end
					if self:GetCardLogicValue(t[i]) + 1 == self:GetCardLogicValue(t[i+1]) then
						--log("aaaaaaaaaaaaaaaaaaaaaa",self:GetCardLogicValue(t[i]))

						a = a + 1
						if b == 1 then
							if a + b == num -2 then
								cards = {}
								for x = j , j+num-2 do
									
									table.insert(cards,t[x])
									
								end
								table.insert(cards,card[5][1])
								
								break
							end
						elseif b == 0 then
							
							if a +b == num -1 then
								cards = {}
								for x = j , j+num-1 do
								
									table.insert(cards,t[x])
									
								end
								
								break
							end
							if a +b == num -2 then
								cards = {}
								for x = j , j+num-2 do
									
									table.insert(cards,t[x])
								end
								table.insert(cards,card[5][1])
								
								break
							end
						end
					elseif self:GetCardLogicValue(t[i])+2 == self:GetCardLogicValue(t[i+1]) then
						---log("bbbbbbbbbbbbbbbbbbbbbbbbbbbb")
						if b == 1 then

							if a + b == num -2 then
								cards = {}
								for x = j , j+num -2 do
								
									table.insert(cards,t[x])
								end
								table.insert(cards,card[5][1])
								
							end
							break
						elseif b == 0 then
							b = b + 1

							if a +b == num -2 then
								cards = {}
								for x = j , j+num-2 do
								
									table.insert(cards,t[x])
								end
								table.insert(cards,card[5][1])
								
								break
							end
						else
							break
						end
					else
						if b == 1 then
							if a + b == num -2 then
								cards = {}
								for x = j , j+num-2 do
								
									table.insert(cards,t[x])
								end
								table.insert(cards,card[5][1])
								
							end
						elseif b == 0 then
							if a +b == num -1 then
								cards = {}
								for x = j , j+num-1 do
								
									table.insert(cards,t[x])
								end
								
							end
						end
						break
					end
				end
			end
			if exit then
				if b == 1 then
					if a + b == num -2 then
						cards = {}
						for x = j , j+num-2 do
						
							table.insert(cards,t[x])
						end
						table.insert(cards,card[5][1])
						--print("_____3")
					end
				elseif b == 0 then
					
					if a +b == num -1 then
						cards = {}
						for x = j , j+num-1 do
						
							table.insert(cards,t[x])
							--print("_____2")
						end
						
					end
					if a + b == num -2 then
						cards = {}
						for x = j , j+num-2 do
						
							table.insert(cards,t[x])
						end
						table.insert(cards,card[5][1])
						--print("_____1")
					end
				end
			end

			if #cards ~= 0 then
				table.insert(tishiBuf,cards)
			end

		end

end

function GameLaiziLogic:findDaipai(shoupai,num,tmp)

	--if card then
		for i = 1 , #shoupai do
			--print("shoupai..........",yl.PokerId[shoupai[i]],self:GetCardLogicValue(shoupai[i]))
		end
		for i = 1 , #tmp do
			--print("tmp.......",yl.PokerId[tmp[i]],self:GetCardLogicValue(tmp[i]))
		end
		local len = 3*num + num
		if #shoupai >= len then
			for i = 1 , #shoupai do
				local insert = true
				for j =1 , #tmp do
					--if self:GetCardLogicValue(shoupai[i])+yl.POKER_COLOR[shoupai[i]] == self:GetCardLogicValue(tmp[j])+yl.POKER_COLOR[tmp[j]] then
					--if shoupai[i] == tmp[j] then
					if yl.PokerId[shoupai[i]] == yl.PokerId[tmp[j]] then
						insert = false
						break
					end
				end
				if insert then
					table.insert(tmp,shoupai[i])
					--print("insert_____________________",self:GetCardLogicValue(shoupai[i]))
				end
				if #tmp == len then
					return true
				end
			end
			return false
		else
			return false	
		end

end

function GameLaiziLogic:findDaipai_two(shoupai,num,tmp)

	--if card then
		-- for i = 1 , #shoupai do
		-- 	print("shoupai..........",yl.PokerId[shoupai[i]],self:GetCardLogicValue(shoupai[i]))
		-- end
		-- for i = 1 , #tmp do
		-- 	print("tmp.......",yl.PokerId[tmp[i]],self:GetCardLogicValue(tmp[i]))
		-- end
		local len =  num*2
		local idx = 0 
		if #shoupai >= len then
			for i = 1 , #shoupai do
				
					local insert = true
					for j =1 , #tmp do
						--if self:GetCardLogicValue(shoupai[i])+yl.POKER_COLOR[shoupai[i]] == self:GetCardLogicValue(tmp[j])+yl.POKER_COLOR[tmp[j]] then
						--if shoupai[i] == tmp[j] then
						if yl.PokerId[shoupai[i]] == yl.PokerId[tmp[j]] then
							insert = false
							break
						end
					end
					if insert then
						table.insert(tmp,shoupai[i])
						idx = idx + 1
						--print("insert_____________________",self:GetCardLogicValue(shoupai[i]))
					end
					if idx == len then
						return true
					end
				
			end
			gt.log("return___2")
			return false
		else
			gt.log("return___1")
			return false	
		end

end

function GameLaiziLogic:findLzfj(card,num,value,buf,shoupai)
	--print("num/.............",num)
	if num == 1 then

		-- local tb = {}
		-- if  card[1][1] ~= -1 or  card[2][1] ~= -1 then

		-- 	for i = 1 , #card[3] do
		-- 		print("tb____________________")
		-- 		tb = {}
		-- 		if card[3][i] ~= -1 then
		-- 			if i % 3 == 1 then
		-- 			print("self:GetCardLogicValue(card[3][i])"..self:GetCardLogicValue(card[3][i]))
		-- 			print("value"..value)
		-- 			if self:GetCardLogicValue(card[3][i]) > value and (card[1][1] ~= -1 or card[2][1]) ~= -1 then
		-- 				print("???????????????????????")
						--这有个 BUG
		-- 				if card[1][1] ~= -1 then
		-- 					table.insert(buf,{card[3][i],card[1][1],card[3][i+1],card[3][i+2]})
		-- 				else
		-- 					table.insert(buf,{card[3][i],card[2][1],card[3][i+1],card[3][i+2]})
		-- 				end
		-- 			end
		-- 			end
		-- 		end
		-- 	end
		-- end

		for i = 1 ,#card[2] do
			if card[2][i] ~= -1 then
				if i % 2 == 1 then
				
					if  self:GetCardLogicValue(card[2][i]) > value and self:GetCardLogicValue(card[2][i]) >3 and  self:GetCardLogicValue(card[2][i]) <15 then

						local tmp = {}
						table.insert(tmp,card[2][i])
						table.insert(tmp,card[2][i+1])
						table.insert(tmp,card[5][1])
						if self:findDaipai(shoupai,num,tmp) then
							table.insert(buf,tmp)
						else

						end
						
					end
					
				end
			end
		end
		
	elseif num == 2 then
		for i = 1 ,#card[2] do
			if i% 2 == 1 then
			if card[2][i] ~= -1 then
			if self:GetCardLogicValue(card[2][i]) ~= 3 and self:GetCardLogicValue(card[2][i]) ~= 15 then
				if self:GetCardLogicValue(card[2][i]) > value then
					for j = 1 , #card[3] do
						if j % 3 ==  1 then
						if self:GetCardLogicValue(card[2][i]) + 1  == self:GetCardLogicValue(card[3][j]) and self:GetCardLogicValue(card[3][j]) <15 and self:GetCardLogicValue(card[2][i]) >3
						and self:GetCardLogicValue(card[2][i]) >value then -- 3>2
							local pos = -1
							for x = 1 , #card[2] do
								if x ~= i then
									pos = x 
									break
								end
							end

							if pos % 2 == 0 then -- 如果 x = 1 pos = 2 
								pos = pos + 1 
							end
							if card[1][2] ~= -1 then
								table.insert(buf,{card[2][i],card[3][j],card[1][2],card[1][1],card[2][i+1],card[3][j+1],card[3][j+2],card[5][1]})
							elseif pos ~= -1 then
								table.insert(buf,{card[2][i],card[3][j],card[2][pos],card[1][pos+1],card[2][i+1],card[3][j+1],card[3][j+2],card[5][1]})
							end
						elseif self:GetCardLogicValue(card[2][i]) -1  == self:GetCardLogicValue(card[3][j])  and self:GetCardLogicValue(card[3][j])> value 
						and self:GetCardLogicValue(card[2][i]) < 15 then --3<2
							local pos = -1
							for x = 1 , #card[2] do
								if x ~= i then
									pos = x 
									break
								end
							end
							if pos % 2 == 0 then -- 如果 x = 1 pos = 2 
								pos = pos + 1 
							end
							if card[1][2] ~= -1 then
								table.insert(buf,{card[2][i],card[3][j],card[1][2],card[1][1],card[2][i+1],card[3][j+1],card[3][j+2],card[5][1]})
							elseif pos ~= -1 then
								table.insert(buf,{card[2][i],card[3][j],card[2][pos],card[1][pos+1],card[2][i+1],card[3][j+1],card[3][j+2],card[5][1]})
							end
						end
						end
					end
				end
			end
			end
			end
		end
	else

		--if card[1][num] ~= -1 then

		local t = {}   
		local tbuf = {}
		
		local cards1 = {}
		local cards2 = {}
		local cards3 = {}
		local cards4 = {}
		local cards5 = {}
		local cards6 = {}
		local cards7 = {}
		local cards8 = {}
		local cards9 = {}
		local cards10 = {}	

		for i = 1 , #card[3] do
			
			if card[3][i] ~= -1 then
				if self:GetCardLogicValue(card[3][i]) ~= 15 then  --~= 2
					table.insert(t,card[3][i])
				end
			end
		end

		for i = 1 , #card[4] do
			if card[4][i] ~= -1 then
				if i %4 ~= 0 then
					if self:GetCardLogicValue(card[4][i]) ~= 15 then  --~= 2
						table.insert(t,card[4][i])
					end
				end
			end
		end


		
		tbuf = self:SortCardListUp(t,#t,0) -- 升序


		local idx = 100
		for i = 1 ,#tbuf do
			if self:GetCardLogicValue(tbuf[i]) >value  then
				idx = i 
				break
			end
		end
		t = {}
		for i = idx , #tbuf do
			table.insert(t,tbuf[i])
		end


	
		

		

		local j = 0
		local a = 0
		local b = 0
		local tmp = 0
		local res = -1
		local res1 = -1
		--print("abcd__________________")
		for j = 1 , #t do -- 8
		  	a = 0 
		  	b = 0
		  	if j % 3 == 1 then
		  	
				for i = j , #t -3 do -- 2  

					if i % 3 == 1 then
						if self:GetCardLogicValue(t[i]) + 1 == self:GetCardLogicValue(t[i+3]) then
							--print("if1____________")
							a = a + 1
							if b == 0 then
								if a == num -1 then
									for x = j , 3*num+j -1 do
										table.insert(cards1,t[x])
									end
										
									if not self:findDaipai(shoupai,num,cards1) then cards1 = {} end

									-- for l = 1 , num do
									-- 	table.insert(cards1,card[1][l])
									-- end

								elseif a == num -2  then
									res,res1 = self:find1(self:GetCardLogicValue(t[i+3])+1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											
											table.insert(cards2,t[x])
										end
										table.insert(cards2,res)
										table.insert(cards2,res1)
										table.insert(cards2,card[5][1])

										if not self:findDaipai(shoupai,num,cards2) then cards2 = {} end
										-- for l = 1 , num do
										-- table.insert(cards2,card[1][l])
										-- end
									end
									res,res1 = self:find1(self:GetCardLogicValue(t[i])-1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											
											table.insert(cards3,t[x])
										end
										table.insert(cards3,res)
										table.insert(cards3,res1)
										table.insert(cards3,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards3,card[1][l])
										-- end
										if not self:findDaipai(shoupai,num,cards3) then cards3 = {} end
									end
								end
							elseif b == 1 then
								tmp = i
								--print("a+b:::",a+b,"num：：：",num)
								if a + b == (num -2) then
									res,res1 = self:find1(self:GetCardLogicValue(t[tmp])-1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											
											table.insert(cards4,t[x])
										end
										table.insert(cards4,res)
										table.insert(cards4,res1)
										table.insert(cards4,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards4,card[1][l])
										-- end
										if not self:findDaipai(shoupai,num,cards4) then cards4 = {} end
									end
								end
							end

						elseif self:GetCardLogicValue(t[i]) + 2 == self:GetCardLogicValue(t[i+3]) then
							--print("if2____________")
							if b == 0 then
								tmp = i
								b = b + 1 
								if a + b == num -2 then
									res,res1 = self:find1(self:GetCardLogicValue(t[tmp])+1,card) 
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											
											table.insert(cards5,t[x])
										end
										table.insert(cards5,res)
										table.insert(cards5,res1)
										table.insert(cards5,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards5,card[1][l])
										-- end
										if not self:findDaipai(shoupai,num,cards5) then cards5 = {} end
									end
								end
							else
								if a +b == num - 2 then
									res,res1 =self:find1(self:GetCardLogicValue(t[tmp])+1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											table.insert(cards6,t[x])
										end
										table.insert(cards6,res)
										table.insert(cards6,res1)
										table.insert(cards6,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards6,card[1][l])
										-- end
										if not self:findDaipai(shoupai,num,cards6) then cards6 = {} end
									end
								end
							end
						else
							--print("if3____________")
							if b == 0 then
								if a == num -1 then
									for x = j , 3*num+j -1 do
										table.insert(cards7,t[x])
									end
									-- for l = 1 , num do
									-- 	table.insert(cards7,card[1][l])
									-- end
									if not self:findDaipai(shoupai,num,cards7) then cards7 = {} end
								elseif a == num -2  then
									gt.log("bug___________")
									gt.log(t[i+3])
									gt.log(self:GetCardLogicValue(t[i+3])+1)
									gt.dump(card)
									res,res1 = self:find1(self:GetCardLogicValue(t[i+3])+1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											table.insert(cards8,t[x])
										end
										table.insert(cards8,res)
										table.insert(cards8,res1)
										table.insert(cards8,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards8,card[1][l])
										-- end
										if not self:findDaipai(shoupai,num,cards8) then cards8 = {} end
									end
									res,res1 = self:find1(self:GetCardLogicValue(t[i])-1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											table.insert(cards9,t[x])
										end
										table.insert(cards9,res)
										table.insert(cards9,res1)
										table.insert(cards9,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards9,card[1][l])
										-- end
										if not self:findDaipai(shoupai,num,cards9) then cards9 = {} end
									end
								end
							elseif b == 1 then
								if a + b == num -2 then
									res,res1 = self:find1(self:GetCardLogicValue(t[tmp])-1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											table.insert(cards10,t[x])
										end
										table.insert(cards10,res)
										table.insert(cards10,res1)
										table.insert(cards10,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards10,card[1][l])
										-- end
										if not self:findDaipai(shoupai,num,cards10) then cards10 = {} end
									end
								end
							end
							break
						end
					end
				end
			end
			
		end

		if #cards1 ~= 0 then table.insert(buf,cards1) end
		if #cards2 ~= 0 then table.insert(buf,cards2) end
		if #cards3 ~= 0 then table.insert(buf,cards3) end
		if #cards4 ~= 0 then table.insert(buf,cards4) end
		if #cards5 ~= 0 then table.insert(buf,cards5) end
		if #cards6 ~= 0 then table.insert(buf,cards6) end
		if #cards7 ~= 0 then table.insert(buf,cards7) end
		if #cards8 ~= 0 then table.insert(buf,cards8) end
		if #cards9 ~= 0 then table.insert(buf,cards9) end
		if #cards10 ~= 0 then table.insert(buf,cards10) end

	    --end

		--print("fj_____________",#buf)
	

	end

end

function GameLaiziLogic:findLzfj_two(card,num,value,buf,shoupai)
	
	if num == 1 then

		for i = 1 ,#card[2] do
			if card[2][i] ~= -1 then
				if i % 2 == 1 then
				
					if  self:GetCardLogicValue(card[2][i]) > value and self:GetCardLogicValue(card[2][i]) >3 and  self:GetCardLogicValue(card[2][i]) <15 then

						local tmp = {}
						table.insert(tmp,card[2][i])
						table.insert(tmp,card[2][i+1])
						table.insert(tmp,card[5][1])
						if self:findDaipai_two(shoupai,num,tmp) then
							table.insert(buf,tmp)
						else

						end
						
					end
					
				end
			end
		end
		
	elseif num == 2 then
		for i = 1 ,#card[2] do
			if i% 2 == 1 then
			if card[2][i] ~= -1 then
			if self:GetCardLogicValue(card[2][i]) ~= 3 and self:GetCardLogicValue(card[2][i]) ~= 15 then
				if self:GetCardLogicValue(card[2][i]) > value then
					for j = 1 , #card[3] do
						if j % 3 ==  1 then
						if self:GetCardLogicValue(card[2][i]) + 1  == self:GetCardLogicValue(card[3][j]) and self:GetCardLogicValue(card[3][j]) <15 and self:GetCardLogicValue(card[2][i]) >3
						and self:GetCardLogicValue(card[2][i]) >value then -- 3>2
							local pos = -1
							local buf_d = {}
							for x = 1 , #card[2] do
								if x ~= i then
									table.insert(buf_d,card[2][x])
								end
							end

							

							if #buf_d >=4 then 
								table.insert(buf,{card[2][i],card[3][j],buf_d[1],buf_d[2],buf_d[3],buf_d[4],card[2][i+1],card[3][j+1],card[3][j+2],card[5][1]})
							end


							


						elseif self:GetCardLogicValue(card[2][i]) -1  == self:GetCardLogicValue(card[3][j])  and self:GetCardLogicValue(card[3][j])> value 
						and self:GetCardLogicValue(card[2][i]) < 15 then --3<2
							local pos = -1
							local buf_d = {}
							for x = 1 , #card[2] do
								if x ~= i then
									table.insert(buf_d,card[2][x])
								end
							end
							
							if #buf_d >=4 then 
								table.insert(buf,{card[2][i],card[3][j],buf_d[1],buf_d[2],buf_d[3],buf_d[4],card[2][i+1],card[3][j+1],card[3][j+2],card[5][1]})
							end

							
						end
						end
					end
				end
			end
			end
			end
		end
	else

		--if card[1][num] ~= -1 then

		local t = {}   
		local tbuf = {}
		
		local cards1 = {}
		local cards2 = {}
		local cards3 = {}
		local cards4 = {}
		local cards5 = {}
		local cards6 = {}
		local cards7 = {}
		local cards8 = {}
		local cards9 = {}
		local cards10 = {}	

		for i = 1 , #card[3] do
			
			if card[3][i] ~= -1 then
				if self:GetCardLogicValue(card[3][i]) ~= 15 then  --~= 2
					table.insert(t,card[3][i])
				end
			end
		end

		for i = 1 , #card[4] do
			if card[4][i] ~= -1 then
				if i %4 ~= 0 then
					if self:GetCardLogicValue(card[4][i]) ~= 15 then  --~= 2
						table.insert(t,card[4][i])
					end
				end
			end
		end


		
		tbuf = self:SortCardListUp(t,#t,0) -- 升序


		local idx = 100
		for i = 1 ,#tbuf do
			if self:GetCardLogicValue(tbuf[i]) >value  then
				idx = i 
				break
			end
		end
		t = {}
		for i = idx , #tbuf do
			table.insert(t,tbuf[i])
		end


	
		

		

		local j = 0
		local a = 0
		local b = 0
		local tmp = 0
		local res = -1
		local res1 = -1
		--print("abcd__________________")
		for j = 1 , #t do -- 8
		  	a = 0 
		  	b = 0
		  	if j % 3 == 1 then
		  	
				for i = j , #t -3 do -- 2  

					if i % 3 == 1 then
						if self:GetCardLogicValue(t[i]) + 1 == self:GetCardLogicValue(t[i+3]) then
							--print("if1____________")
							a = a + 1
							if b == 0 then
								if a == num -1 then
									for x = j , 3*num+j -1 do
										table.insert(cards1,t[x])
									end
									gt.log("abcd_______1")
									if not self:findDaipai_two(shoupai,num,cards1) then cards1 = {} end

									-- for l = 1 , num do
									-- 	table.insert(cards1,card[1][l])
									-- end

								elseif a == num -2  then
									res,res1 = self:find1(self:GetCardLogicValue(t[i+3])+1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											
											table.insert(cards2,t[x])
										end
										table.insert(cards2,res)
										table.insert(cards2,res1)
										table.insert(cards2,card[5][1])
										gt.log("abcd_______2")
										if not self:findDaipai_two(shoupai,num,cards2) then cards2 = {} end
										-- for l = 1 , num do
										-- table.insert(cards2,card[1][l])
										-- end
									end
									res,res1 = self:find1(self:GetCardLogicValue(t[i])-1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											
											table.insert(cards3,t[x])
										end
										table.insert(cards3,res)
										table.insert(cards3,res1)
										table.insert(cards3,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards3,card[1][l])
										-- end
										gt.log("abcd_______3")
										if not self:findDaipai_two(shoupai,num,cards3) then cards3 = {} end
									end
								end
							elseif b == 1 then
								tmp = i
								--print("a+b:::",a+b,"num：：：",num)
								if a + b == (num -2) then
									res,res1 = self:find1(self:GetCardLogicValue(t[tmp])-1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											
											table.insert(cards4,t[x])
										end
										table.insert(cards4,res)
										table.insert(cards4,res1)
										table.insert(cards4,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards4,card[1][l])
										-- end
										gt.log("abcd_______4")
										if not self:findDaipai_two(shoupai,num,cards4) then cards4 = {} end
									end
								end
							end

						elseif self:GetCardLogicValue(t[i]) + 2 == self:GetCardLogicValue(t[i+3]) then
							--print("if2____________")
							if b == 0 then
								tmp = i
								b = b + 1 
								if a + b == num -2 then
									res,res1 = self:find1(self:GetCardLogicValue(t[tmp])+1,card) 
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											
											table.insert(cards5,t[x])
										end
										table.insert(cards5,res)
										table.insert(cards5,res1)
										table.insert(cards5,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards5,card[1][l])
										-- end
										gt.log("abcd_______5")
										if not self:findDaipai_two(shoupai,num,cards5) then cards5 = {} end
									end
								end
							else
								if a +b == num - 2 then
									res,res1 =self:find1(self:GetCardLogicValue(t[tmp])+1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											table.insert(cards6,t[x])
										end
										table.insert(cards6,res)
										table.insert(cards6,res1)
										table.insert(cards6,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards6,card[1][l])
										-- end
										gt.log("abcd_______6")
										if not self:findDaipai_two(shoupai,num,cards6) then cards6 = {} end
									end
								end
							end
						else
							--print("if3____________")
							if b == 0 then
								if a == num -1 then
									for x = j , 3*num+j -1 do
										table.insert(cards7,t[x])
									end
									-- for l = 1 , num do
									-- 	table.insert(cards7,card[1][l])
									-- end
									gt.log("abcd_______8")
									if not self:findDaipai_two(shoupai,num,cards7) then cards7 = {} end
								elseif a == num -2  then
									res,res1 = self:find1(self:GetCardLogicValue(t[i+3])+1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											table.insert(cards8,t[x])
										end
										table.insert(cards8,res)
										table.insert(cards8,res1)
										table.insert(cards8,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards8,card[1][l])
										-- end
										gt.log("abcd_______9")
										if not self:findDaipai_two(shoupai,num,cards8) then cards8 = {} end
									end
									res,res1 = self:find1(self:GetCardLogicValue(t[i])-1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											table.insert(cards9,t[x])
										end
										table.insert(cards9,res)
										table.insert(cards9,res1)
										table.insert(cards9,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards9,card[1][l])
										-- end
										gt.log("abcd_______10")
										if not self:findDaipai_two(shoupai,num,cards9) then cards9 = {} end
									end
								end
							elseif b == 1 then
								if a + b == num -2 then
									res,res1 = self:find1(self:GetCardLogicValue(t[tmp])-1,card)
									if res ~= -1 then
										for x = j , 3*num +j -3 -1 do
											table.insert(cards10,t[x])
										end
										table.insert(cards10,res)
										table.insert(cards10,res1)
										table.insert(cards10,card[5][1])
										-- for l = 1 , num do
										-- table.insert(cards10,card[1][l])
										-- end
										gt.log("abcd_______11")
										if not self:findDaipai_two(shoupai,num,cards10) then cards10 = {} end
									end
								end
							end
							break
						end
					end
				end
			end
			
		end


	if #cards1 ~= 0 then table.insert(buf,cards1) end
	if #cards2 ~= 0 then table.insert(buf,cards2) end
	if #cards3 ~= 0 then table.insert(buf,cards3) end
	if #cards4 ~= 0 then table.insert(buf,cards4) end
	if #cards5 ~= 0 then table.insert(buf,cards5) end
	if #cards6 ~= 0 then table.insert(buf,cards6) end
	if #cards7 ~= 0 then table.insert(buf,cards7) end
	if #cards8 ~= 0 then table.insert(buf,cards8) end
	if #cards9 ~= 0 then table.insert(buf,cards9) end
	if #cards10 ~= 0 then table.insert(buf,cards10) end
	

		
		-- if #cards1 ~= 0 and #cards1 == num* 5 then table.insert(buf,cards1) end
		-- if #cards2 ~= 0 and #cards2 == num* 5 then table.insert(buf,cards2) end
		-- if #cards3 ~= 0 and #cards3 == num* 5 then table.insert(buf,cards3) end
		-- if #cards4 ~= 0 and #cards4 == num* 5 then table.insert(buf,cards4) end
		-- if #cards5 ~= 0 and #cards5 == num* 5 then table.insert(buf,cards5) end
		-- if #cards6 ~= 0 and #cards6 == num* 5 then table.insert(buf,cards6) end
		-- if #cards7 ~= 0 and #cards7 == num* 5 then table.insert(buf,cards7) end
		-- if #cards8 ~= 0 and #cards8 == num* 5 then table.insert(buf,cards8) end
		-- if #cards9 ~= 0 and #cards9 == num* 5 then table.insert(buf,cards9) end
		-- if #cards10 ~= 0 and #cards10 == num* 5 then table.insert(buf,cards10) end

	    --end

		--print("fj_____________",#buf)
	

	end

end

function GameLaiziLogic:findLzLd(card,num,value,buf)




	local t = {}
	local tbuf = {}



	for i = 1 , #card[2] do
		if card[2][i] ~= -1 then
			if self:GetCardLogicValue(card[2][i]) ~= 15 then  --~= 2
				table.insert(t,card[2][i])
			end
		end
	end

	for i = 1 , #card[3] do
		if card[3][i] ~= -1 then
			if i %3 ~= 0 then
				if self:GetCardLogicValue(card[3][i]) ~= 15 then  --~= 2
					table.insert(t,card[3][i])
				end
			end
		end
	end

	for i = 1 , #card[4] do
		if card[4][i] ~= -1 then
			if i %4 ~= 0 and  i %3 ~= 0  then
				if self:GetCardLogicValue(card[4][i]) ~= 15 then  --~= 2
					table.insert(t,card[4][i])
				end
			end
		end
	end


	
	tbuf = self:SortCardListUp(t,#t,0) -- 升序


	gt.log("balue........",value,#tbuf)

	local idx = 100
	for i = 1 ,#tbuf do
		gt.log("self:GetCardLogicValue(tbuf[i])",self:GetCardLogicValue(tbuf[i]))
		if self:GetCardLogicValue(tbuf[i]) >value  then
			idx = i 
			break
		end
	end

	gt.log("idx........c",idx)

	t = {}
	for i = idx , #tbuf do
		table.insert(t,tbuf[i])
		gt.log("cardNum..",self:GetCardLogicValue(tbuf[i]))
	end
	gt.log("num-____________",num)

	for i  =1  , #t do
		gt.log("y............",t[i])
	end
	

	local cards1 = {}
	local cards2 = {}
	local cards3 = {}
	local cards4 = {}
	local cards5 = {}
	local cards6 = {}
	local cards7 = {}
	local cards8 = {}
	local cards9 = {}
	local cards10 = {}
	local cards11 = {}
	local cards12 = {}
	local cards13 = {}

	local j = 0
	local a = 0
	local b = 0
	
	local tmp = 0
	local res = -1
	for j = 1 , #t do -- 4
	  	a = 0 
	  	b = 0
	  	
	  	if j % 2 == 1 then
	  
			for i = j , #t -2 do -- 2  
		
				if i % 2 == 1 then
					if self:GetCardLogicValue(t[i]) + 1 == self:GetCardLogicValue(t[i+2]) then
						gt.log("1____________",self:GetCardLogicValue(t[i]),i)
						a = a + 1
						if b == 0 then
							if a == num -1 then
								self:log("insert________________")
								if #cards1 == 0 then 
									for x = j , 2*num+j -1 do
										table.insert(cards1,t[x])
									end
								elseif #cards11 == 0 then 
									for x = j , 2*num+j -1 do
										table.insert(cards11,t[x])
									end
								end
								
							elseif a == num -2  then
								self:log("ccccccc",value,#t,i)
								
								if self:GetCardLogicValue(t[i+2]) then
									gt.log("num_____csw____",self:GetCardLogicValue(t[i+2]),i)
									res = self:find(self:GetCardLogicValue(t[i+2])+1,card,value)
									if res ~= -1 then
										
										if  #cards2 == 0 then 

											for x = j , 2*num +j -2 -1 do
												table.insert(cards2,t[x])
											
											end
											table.insert(cards2,res)
											table.insert(cards2,card[5][1])
										elseif #cards12 == 0 then 

											for x = j , 2*num +j -2 -1 do
												table.insert(cards12,t[x])
											
											end
											table.insert(cards12,res)
											table.insert(cards12,card[5][1])
										end

									end
								end
								if self:GetCardLogicValue(t[i+6-2*num]) then 
								
									res = self:find(self:GetCardLogicValue(t[i+6-2*num])-1,card,value)
									if res ~= -1 then

										if #cards3 == 0 then 

											for x = j , 2*num +j -2 -1 do
												table.insert(cards3,t[x])
											end
											table.insert(cards3,res)
											table.insert(cards3,card[5][1])
										elseif #cards13 == 0 then
											for x = j , 2*num +j -2 -1 do
												table.insert(cards13,t[x])
											end
											table.insert(cards13,res)
											table.insert(cards13,card[5][1])
										end
		 							end
		 						end
							end
						elseif b == 1 then
							tmp = i
							
							if a + b == num -2 then
								
								res = self:find(self:GetCardLogicValue(t[tmp])-1,card,value)
								
								if res ~= -1 then
									for x = j , 2*num +j -2 -1 do
										table.insert(cards4,t[x])
										
									end
									
									table.insert(cards4,res)
									table.insert(cards4,card[5][1])
								end
							end
						end
					elseif self:GetCardLogicValue(t[i]) + 2 == self:GetCardLogicValue(t[i+2]) then
						gt.log("2____________",self:GetCardLogicValue(t[i]),i)
						if b == 0 then
							tmp = i
							b = b + 1 
							if a + b == num -2 then
								res = self:find(self:GetCardLogicValue(t[tmp])+1,card,value)
								if res ~= -1 then
									for x = j , 2*num +j -2 -1 do
										table.insert(cards5,t[x])
										
									end
									table.insert(cards5,res)
									table.insert(cards5,card[5][1])
								end
							end
						else
							if a +b == num - 2 then
								res = self:find(self:GetCardLogicValue(t[tmp])+1,card,value)
								if res ~= -1 then
									for x = j , 2*num +j -2 -1 do
										table.insert(cards6,t[x])
										
									end
									
									table.insert(cards6,res)
									table.insert(cards6,card[5][1])
								end
							end
						end
					else

						if b == 0 then
							if a == num -1 then
								
								for x = j , 2*num+j -1 do
									table.insert(cards7,t[x])
								end
				
							elseif a == num -2  then
								gt.log("BUG___________")
								gt.log(self:GetCardLogicValue(t[i+2])+1)
								gt.log(t[i+2])
								gt.log("num_____csw____s",self:GetCardLogicValue(t[i+2]),i)
								res = self:find(self:GetCardLogicValue(t[i+2])+1,card,value)
								if res ~= -1 then
									gt.log("out_______________________")
									for x = j , 2*num +j -2 -1 do
										table.insert(cards8,t[x])
										
									end
									table.insert(cards8,res)

									cards8 = self:SortCardListUp(cards8,#cards8,0)
									
									for xx = 1 , #cards8 -1 do 
										gt.log("awd__________",self:GetCardLogicValue(cards8[xx]))
										if self:GetCardLogicValue(cards8[xx]) + 1 < self:GetCardLogicValue(cards8[xx+1]) then cards8 = {} end
									end
									if #cards8 ~= 0 then 
										table.insert(cards8,card[5][1])
									end
									
								end
								res = self:find(self:GetCardLogicValue(t[i])-1,card,value)
								if res ~= -1 then
									for x = j , 2*num +j -2 -1 do
										table.insert(cards9,t[x])
										
									end
									table.insert(cards9,res)


									cards9 = self:SortCardListUp(cards9,#cards9,0)

									for xx = 1 , #cards9 -1 do 
										if self:GetCardLogicValue(cards9[xx]) + 1 < self:GetCardLogicValue(cards9[xx+1])  then cards9 = {} end
									end
									if #cards9 ~= 0 then 
										table.insert(cards9,card[5][1])
									end

								
	 							end
							end
						elseif b == 1 then
							-- if a + b == num -2 then
							-- 	res = self:find(t[tmp]-1,card)
							-- 	if res ~= -1 then
							-- 		for x = j , 2*num +j -2 -1 do
							-- 			table.insert(cards10,tbuf[x])
										
							-- 		end
									
							-- 		table.insert(cards10,res)
							-- 		table.insert(cards10,card[5][1])
							-- 	end
							-- end
						end
						break
					end
				end
			end
		
		end
	end	

	-- for i= 1 , 11 do
	-- 	for j = i + 1 , 11 do
	-- 		if ["card"..i] == ["card"..j] then 
	-- 			["card"..j] = {}
	-- 		end
	-- 	end
	-- end

	-- local t_buf = {}

	-- table.insert(t_buf,cards1)
	-- table.insert(t_buf,cards2)
	-- table.insert(t_buf,cards3)
	-- table.insert(t_buf,cards4)
	-- table.insert(t_buf,cards5)
	-- table.insert(t_buf,cards6)
	-- table.insert(t_buf,cards7)
	-- table.insert(t_buf,cards8)
	-- table.insert(t_buf,cards9)
	-- table.insert(t_buf,cards10)
	-- table.insert(t_buf,cards11)



	if #cards1 ~= 0 then table.insert(buf,cards1) self:log("#cards1",#cards1) end
	if #cards2 ~= 0 then table.insert(buf,cards2) self:log("#cards2",#cards2) end
	if #cards3 ~= 0 then table.insert(buf,cards3) self:log("#cards3",#cards3) end
	if #cards4 ~= 0 then table.insert(buf,cards4) self:log("#cards4",#cards4) end
	if #cards5 ~= 0 then table.insert(buf,cards5) self:log("#cards5",#cards5) end
	if #cards6 ~= 0 then table.insert(buf,cards6) self:log("#cards6",#cards6) end
	if #cards7 ~= 0 then table.insert(buf,cards7) self:log("#cards7",#cards7) end
	if #cards8 ~= 0 then table.insert(buf,cards8) self:log("#cards8",#cards8) end
	if #cards9 ~= 0 then table.insert(buf,cards9) self:log("#cards9",#cards9) end
	if #cards10 ~= 0 then table.insert(buf,cards10) self:log("#cards10",#cards9) end
	if #cards11 ~= 0 then table.insert(buf,cards11) self:log("#cards11",#cards9) end

	if #cards12 ~= 0 then table.insert(buf,cards12) self:log("#cards12",#cards12) end
	if #cards13 ~= 0 then table.insert(buf,cards13) self:log("#cards13",#cards13) end
	

	gt.dump(buf)

	gt.log("#buf......here.....",#buf)

end





function GameLaiziLogic:find1(num,card)

	local buf = card[2]
	for i =1 , #buf do
		if i % 2 == 1 then
		if self:GetCardLogicValue(buf[i]) ~= 3 and self:GetCardLogicValue(buf[i]) ~= 15 then
			
			if self:GetCardLogicValue(buf[i]) == num then
				return buf[i] ,buf[i+1]
			end
		end
		end
	end
	return -1,-1

end


function GameLaiziLogic:find(num,card,min_num) --- come!
	
	local buf = card[1]




	gt.log("num________",num,min_num)
	--print("card[1]",#buf)
		
	gt.log(self:GetCardLogicValue(buf[1]))
	for i =1 , #buf do
		if self:GetCardLogicValue(buf[i]) ~= 3 and self:GetCardLogicValue(buf[i]) ~= 15 and buf[i] ~= -1 and
			self:GetCardLogicValue(buf[i]) ~= 16 and self:GetCardLogicValue(buf[i]) ~= 17 then
		
			if self:GetCardLogicValue(buf[i]) == num and min_num < self:GetCardLogicValue(buf[i]) then ---GetCardLogicValue
				return buf[i]
			end
		end
	end
	gt.log("return ___________   -1")
	return -1
end


function GameLaiziLogic:isLzLiandui(buf,num) --4

	local res = 0
	local idx = 0
	for i =1 ,num -2 do
		if i % 2 == 1 then
			local  n = GameLaiziLogic:GetCardLogicValue(buf[2][i+2]) - GameLaiziLogic:GetCardLogicValue(buf[2][i])
			if n > res then
				res = n
			end
			if n == 2 then
				idx = idx +1
			end
		end
	end
	if idx >1 then
		res = -1
	end
	return res 
end

function GameLaiziLogic:isLzSunzi(buf,num)

	local res = 0
	local idx = 0
	for i =1 ,num -1 do
		local  n = GameLaiziLogic:GetCardLogicValue(buf[1][i+1]) - GameLaiziLogic:GetCardLogicValue(buf[1][i])
		if n > res then
			res = n
		end
		if n == 2 then
			idx = idx +1
		end
	end
	if idx >1 then
		res = -1
	end
	return res 
end

function GameLaiziLogic:isLzFeiji(buf,num)

	local res = 0
	local idx = 0
	for i =1 ,num -3 do -- 6 -3 = 3
		if i % 3 == 1 then
			local  n = GameLaiziLogic:GetCardLogicValue(buf[3][i+3]) - GameLaiziLogic:GetCardLogicValue(buf[3][i])
			if n > res then
				res = n
			end
			if n == 2 then
				idx = idx +1
			end
		end
	end
	if idx >1 then
		res = -1
	end
	return res 
end
--判断全是三张一样无单张情况
function GameLaiziLogic:isfeiji_12(buf,num)
	local ishave = true
	for i = 4, num -3 do --6
		if i % 3 == 1 then
			if GameLaiziLogic:GetCardLogicValue(buf[3][i]) + 1 == GameLaiziLogic:GetCardLogicValue(buf[3][i+3]) and  GameLaiziLogic:GetCardLogicValue(buf[3][num])<=14 then
			else
				return false
			end
			
		end
	end
	
	return true
end


function GameLaiziLogic:isfeiji(buf,num)
	
	for i = 1, num -3 do --6
		if i % 3 == 1 then
			
			if GameLaiziLogic:GetCardLogicValue(buf[3][i]) + 1 == GameLaiziLogic:GetCardLogicValue(buf[3][i+3]) and  GameLaiziLogic:GetCardLogicValue(buf[3][num])<=14 then
			else
				return false
			end
			
		end
	end
	gt.log("true_____________")
	return true
end

function GameLaiziLogic:isfeijis(buf,num)
	
	for i = 1, num -3 do --6
		if i % 3 == 1 then
			
			if GameLaiziLogic:GetCardLogicValue(buf[3][i]) + 1 == GameLaiziLogic:GetCardLogicValue(buf[3][i+3]) and  GameLaiziLogic:GetCardLogicValue(buf[3][num])<=14 then
			else
				gt.log("false__________s")
				return false
			end
			
		end
	end
	gt.log("true_____________")
	return true
end

function GameLaiziLogic:isLiandui(buf,num)
	
	for i = 1, num -2 do
		if i % 2 == 1 then
			if GameLaiziLogic:GetCardLogicValue(buf[2][i]) + 1 == GameLaiziLogic:GetCardLogicValue(buf[2][i+2]) and  GameLaiziLogic:GetCardLogicValue(buf[2][num])<=14 then
			else
				return false
			end
		end
	end
	return true
end

function GameLaiziLogic:isShunzi(buf,num)
	
	for i =1 ,num -1 do
		if GameLaiziLogic:GetCardLogicValue(buf[1][i]) +1 == GameLaiziLogic:GetCardLogicValue(buf[1][i+1]) and  GameLaiziLogic:GetCardLogicValue(buf[1][i+1])<=14 then
		else
			return false
		end
	end
	return true
end

function GameLaiziLogic:Verification_missile(card)


	self:log("card>>>>",#card)

	if card[2] == 0x4F and card[1] == 0x4E then
        return true
    end
	if card[1] == 0x4F and card[2] == 0x4E then
       	return true
    end
    return false

end

function GameLaiziLogic:auto_sunzi(_cbHandCard)

	local cbHandCard = self:SortCardListUp(_cbHandCard,#_cbHandCard,0) -- >小->大
	local tagAnalyseResult = self:AnalysebCardData1(cbHandCard,#cbHandCard) -- 找出扑克结构选择的牌
	local buf = {}
	if tagAnalyseResult[5][1] == -1 then
		local n ,_sz , n1, __sz = self:findShunzi(tagAnalyseResult)
		-- if n >= num then
		-- 	self:compare(_sz,value,num,buf)
		-- end
		-- if n1 >= num then
		-- 	self:compare(__sz,value,num,buf)
		-- end
		buf = _sz
	else
		for i = #_cbHandCard ,5 ,-1 do
			self:findLzSunzi(tagAnalyseResult,i,2,buf)
			if #buf~= 0 then break end 
		end
		self:log("type--____",type(buf[1]))
		gt.dump(buf)
		if not buf[1] then return buf end
		return buf[1]
	end

	return buf
end

-- @param[cbHandCard]    手牌数据
-- @param[cbFirstCard]   出牌数据
function GameLaiziLogic:getMaxCardType1(_cbHandCard,_cbFirstCard,landType,isfunc) --tishi 

	
	isfunc = isfunc or false

	self:log(tostring(isfunc))

	local buf = {}
	local zhddan = true

	if #_cbHandCard == 0 then
		return buf
	end


	local cbHandCard 
	local cbFirstCard
	cbHandCard = self:SortCardListUp(_cbHandCard,#_cbHandCard,0) -- >小->大

	if #_cbFirstCard ~= 0 then 
		cbFirstCard = self:SortCardListUp(_cbFirstCard,#_cbFirstCard,0) -- >小->大
	else
		cbFirstCard = {}
	end

	self:log("cbFirstCard",#cbFirstCard)

	local card , num = GameLaiziLogic:GetCardType1(cbFirstCard, #cbFirstCard,landType) -- 返回牌型 上家出的牌

    
    --[[ 暂时注释，上家出即是3带1，又是4带2，下家只能出3带1，移除4带2的标识
    --上家出的牌，即是飞机又是4带2，按飞机算，移除4带2数据
    --深拷贝一个 card
    local cardCopy = {}
    for key, var in pairs(card) do
        cardCopy[key] = var
    end

    local _isfeiji = false;
    local _is4dai2 = false;
    --判断即是飞机又是4带2
    for key, var in pairs(cardCopy) do
        if key == CT_THREE_TAKE_TWO then
            _isfeiji = true;
        end
        if key == CT_FOUR_TAKE_TWO then
            _is4dai2 = true;
        end
    end
    --即是飞机又是4带2，移除4带2
    if _isfeiji and _is4dai2 then
        local _index = -1
        for key, var in pairs(cardCopy) do
            _index = _index + 1
            if key == CT_FOUR_TAKE_TWO then
                table.remove(cardCopy, key)
            end
        end
    end
    
 	]]--
 	local tagAnalyseResult = self:AnalysebCardData1(cbHandCard,#cbHandCard) -- 找出扑克结构选择的牌

 	if tagAnalyseResult[5][1] == 18 and #_cbHandCard  == 1 then -- 有一张牌是癞子
 		return buf
 	end

 	
 	
 	for key ,value in pairs(card) do 
	--for key ,value in pairs(cardCopy) do 
		local bool = false	
		gt.log("key.......",key)
		if key == 100 then -- 100.... 上家没有出牌
			
			local shouPaibuf , len = GameLaiziLogic:GetCardType1(cbHandCard, #cbHandCard,landType) -- 返回手牌牌型 自己的牌

			for k , y in pairs(shouPaibuf) do
				self:log("k.....",k)
				if k ~= 0 and k ~= 100 then -- 一把出完
					self:log("insert_____________",#buf)
					bool = true
					table.insert(buf,cbHandCard)
				else
					if landType == 1 then 
						for i = 1 , 4 do
							for j = 1 , #tagAnalyseResult[i] do
								if tagAnalyseResult[i][j] ~= -1 then
									if j % i == 0 then
										if i == 1 then
											table.insert(buf,{tagAnalyseResult[i][j]})
										elseif i == 2 then
											table.insert(buf,{tagAnalyseResult[i][j],tagAnalyseResult[i][j-1]})
										elseif i == 3 then
											table.insert(buf,{tagAnalyseResult[i][j],tagAnalyseResult[i][j-2],tagAnalyseResult[i][j-1]})
										elseif i == 4 then
											table.insert(buf,{tagAnalyseResult[i][j],tagAnalyseResult[i][j-3],tagAnalyseResult[i][j-2],tagAnalyseResult[i][j-1]})
										end 
									end
								end
							end
						end
					else
						local tbuf = {}
						for i = 1 , 4 do
							for j = 1 , #tagAnalyseResult[i] do
								if tagAnalyseResult[i][j] ~= -1 then
									if j % i == 0 then
										if i == 1 then
											table.insert(buf,{tagAnalyseResult[i][j]})
										elseif i == 2 then
											if self:GetCardLogicValue(tagAnalyseResult[i][j]) ~= 3 then 
												table.insert(buf,{tagAnalyseResult[i][j],tagAnalyseResult[i][j-1]})
											else
												table.insert(tbuf,{tagAnalyseResult[i][j],tagAnalyseResult[i][j-1]})
											end
										elseif i == 3 then
											table.insert(buf,{tagAnalyseResult[i][j],tagAnalyseResult[i][j-2],tagAnalyseResult[i][j-1]})
										elseif i == 4 then
											if #tbuf > 0 then 
												table.insert(buf,tbuf)
											end
											table.insert(buf,{tagAnalyseResult[i][j],tagAnalyseResult[i][j-3],tagAnalyseResult[i][j-2],tagAnalyseResult[i][j-1]})
										end 
									end
								end
							end
						end
					end
				end
			end

		elseif key == CT_SINGLE then
			
			for i =1 , 4 do
				for j =1 , #tagAnalyseResult[i] do
					if tagAnalyseResult[i][j] ~= -1 then
						if self:GetCardLogicValue(tagAnalyseResult[i][j]) > value then
							if j % i == 0 then
								table.insert(buf,{tagAnalyseResult[i][j]})
							end
						end
					end
				end
			end
			if isfunc then
				if #_cbHandCard ~= 1 then
					buf = {}
				end
			end
		elseif key == CT_DOUBLE then
			
				if tagAnalyseResult[5][1] == -1 then
					if landType ~= 3 then
						for i = 2 ,4 do
							for j = 1 , #tagAnalyseResult[i] do
								if tagAnalyseResult[i][j] ~= -1 then
								self:log(self:GetCardLogicValue(tagAnalyseResult[i][j]))
								self:log(value)
								self:log("csw___________________4.00")
								if self:GetCardLogicValue(tagAnalyseResult[i][j]) > value then
									if j % i == 1 then
										table.insert(buf,{tagAnalyseResult[i][j],tagAnalyseResult[i][j+1]})
										self:log("insert_______4.00",#buf)
									end
								end
								end
							end
						end
					else
						for i = 2 ,4 do
							for j = 1 , #tagAnalyseResult[i] do
								if tagAnalyseResult[i][j] ~= -1   then
								if self:GetCardLogicValue(tagAnalyseResult[i][j]) > value and self:GetCardLogicValue(tagAnalyseResult[i][j]) ~= 15 then
									if j % i == 1 then
										table.insert(buf,{tagAnalyseResult[i][j],tagAnalyseResult[i][j+1]})
									end
								end
								end
							end
						end

					end
				else
					for i = 2 ,4 do
						for j = 1 , #tagAnalyseResult[i] do
							if tagAnalyseResult[i][j] ~= -1 then
								if self:GetCardLogicValue(tagAnalyseResult[i][j]) > value then
									if j % i == 1 then
										table.insert(buf,{tagAnalyseResult[i][j],tagAnalyseResult[i][j+1]})
									end
								end
							end
						end
					end
					for i =1, #tagAnalyseResult[1] do
						if tagAnalyseResult[1][i] ~= -1   then
						if self:GetCardLogicValue(tagAnalyseResult[1][i]) > value and self:GetCardLogicValue(tagAnalyseResult[1][i])~=3 and self:GetCardLogicValue(tagAnalyseResult[1][i])<15 then
							--print("self:GetCardLogicValue(tagAnalyseResult[i][j])"..self:GetCardLogicValue(tagAnalyseResult[1][i]))
							table.insert(buf,{tagAnalyseResult[1][i],tagAnalyseResult[5][1]})
						end
						end
					end
					gt.log("buf_______________c",#buf)
				end
				if isfunc then
					if #_cbHandCard ~= 2 then
						buf = {}
						self:log("nil____________")
					end
				end
		elseif key == CT_THREE then
			if landType == 1 or landType == 2 then
				self:find_THREE(tagAnalyseResult,value,buf)
			end
			if isfunc then
				if #_cbHandCard ~= 3 then
					buf = {}
				end
			end
		elseif key == CT_SINGLE_LINE then
		
			if tagAnalyseResult[5][1] == -1 then
				local n ,_sz , n1, __sz = self:findShunzi(tagAnalyseResult)
				if n >= num then
					self:compare(_sz,value,num,buf)
				end
				if n1 >= num then
					self:compare(__sz,value,num,buf)
				end
			else
				self:findLzSunzi(tagAnalyseResult,num,value,buf)
			end
		
		elseif key == CT_DOUBLE_LINE then
			if tagAnalyseResult[5][1] == -1 then
				local ld, ld1 ,ld2 = self:findld(tagAnalyseResult)
				if #ld*0.5 >= num then
					self:compare(ld,value,num*2,buf)
					gt.log("111111")
				end
				if #ld1*0.5 >= num then
					self:compare(ld1,value,num*2,buf)
					gt.log("222222")
				end
				if #ld2*0.5 >= num then
					self:compare(ld2,value,num*2,buf)
					gt.log("333333")
				end
			else
				gt.log("liandui___________________")
				self:findLzLd(tagAnalyseResult,num,value,buf)
			end
		elseif key == CT_THREE_LINE then
			-- 不做处理 
			if landType == 1 or landType == 2 then
				local fj, fj1 ,fj2 = self:findfj(tagAnalyseResult)
				self:find_THREE_LINE(fj, fj1 ,fj2,num,value,buf)
			end
		elseif key == CT_THREE_TAKE_ONE then --nonono
			if tagAnalyseResult[5][1] == -1 then

				if #cbFirstCard == 4 then -- 3 dai 1
					local fj = self:sandaiyi(tagAnalyseResult)
					self:compareFeiji(fj,value,num*3,buf,tagAnalyseResult)
			
				else -- 飞机
					local fj, fj1 ,fj2 = self:findfj(tagAnalyseResult)
					--print("fj........."..#fj)
					if #fj >= num*3  then
						
						self:compareFeiji(fj,value,num*3,buf,tagAnalyseResult)
					end
					if #fj1 >= num*3 then
						
						self:compareFeiji(fj1,value,num*3,buf,tagAnalyseResult)
					end
					if #fj2 >= num*3  then
						
						self:compareFeiji(fj2,value,num*3,buf,tagAnalyseResult)
					end
				end
			else
				
				if #cbFirstCard == 4 then -- 3 dai 1
					
					local fj = self:sandaiyi(tagAnalyseResult)
					self:compareFeiji(fj,value,num*3,buf,tagAnalyseResult)
				else
					local fj, fj1 ,fj2 = self:findfj(tagAnalyseResult)
					if #fj >= num*3  then
						
						self:compareFeiji(fj,value,num*3,buf,tagAnalyseResult)
					end
					if #fj1 >= num*3 then
						
						self:compareFeiji(fj1,value,num*3,buf,tagAnalyseResult)
					end
					if #fj2 >= num*3  then
						
						self:compareFeiji(fj2,value,num*3,buf,tagAnalyseResult)
					end
				end
				self:findLzfj(tagAnalyseResult,num,value,buf,cbHandCard)
			end
		elseif key == CT_THREE_TAKE_TWO then --nonono
			if landType == 3 then return end
			gt.log("c____________s",#cbFirstCard,num)

			--if isfunc then 
				if tagAnalyseResult[5][1] == -1 then
					--if #cbFirstCard == num*5 then 
						if #cbFirstCard == 5 then -- 3 dai 1
							local fj = self:sandaiyi(tagAnalyseResult)
							self:compareThreeTakeTwo(fj,value,num*3,buf,tagAnalyseResult)
						else -- 飞机
							local fj, fj1 ,fj2 = self:findfj(tagAnalyseResult)

							if #fj >= num*3  then
								self:compareFeiji2(fj,value,num*3,buf,tagAnalyseResult)
							end
							if #fj1 >= num*3 then
								self:compareFeiji2(fj1,value,num*3,buf,tagAnalyseResult)
							end
							if #fj2 >= num*3  then
								self:compareFeiji2(fj2,value,num*3,buf,tagAnalyseResult)
							end
						end
					--end
				else

					--if #cbFirstCard == num*5 then 

						if #cbFirstCard == 5 then -- 3 dai 1
							gt.log("s____________")
							self:sandaiyi1(tagAnalyseResult,value,num*3,buf,isfunc)
							--self:compareFeiji1_s(fj,value,num*3,buf,tagAnalyseResult)



							if isfunc then 
								if #buf == 2 then 
									local tmp = buf[1]
									buf = {}
									table.insert(buf,tmp)
								end
							end



							gt.log("s____________",#buf)
						else -- 飞机

							local bufs = {}
							for i = 1 , #tagAnalyseResult[2] do
								if tagAnalyseResult[2][i] ~= -1 then 
									table.insert(bufs,tagAnalyseResult[2][i])
								end
							end
							for i = 1 , #tagAnalyseResult[3] do
								if tagAnalyseResult[3][i] ~= -1 then 
									if i %3 ~= 0 then 
										table.insert(bufs,tagAnalyseResult[3][i])
									end
								end
							end
							for i = 1 , #tagAnalyseResult[4] do
								if tagAnalyseResult[4][i] ~= -1 then 
									if i % 4  == 1 then 
										table.insert(bufs,tagAnalyseResult[4][i])
										table.insert(bufs,tagAnalyseResult[4][i+1])
									end
								end
							end
							self:findLzfj_two(tagAnalyseResult,num,value,buf,bufs)

							if isfunc then 
								if #buf == 2 then 
									local tmp = buf[1]
									buf = {}
									table.insert(buf,tmp)
								end
							end

						end
					--end
					
				end
			--else
				
			--end
		elseif key == CT_FOUR_TAKE_ONE then
				
				for i = 1 , #tagAnalyseResult[4] do
					if tagAnalyseResult[4][i] ~= -1 then
					if i % 4 == 1 then
					if self:GetCardLogicValue(tagAnalyseResult[4][i]) > value then
						if tagAnalyseResult[1][2] ~= - 1 then
							table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[1][1],tagAnalyseResult[1][2],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3]})
						elseif  tagAnalyseResult[2][2] ~=-1 then
							table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[2][1],tagAnalyseResult[2][2],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3]})
						elseif  tagAnalyseResult[3][2] ~= -1 then
							table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[3][1],tagAnalyseResult[3][2],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3]})
						end
					end
					end
					end
				end
				if tagAnalyseResult[5][1] ~= -1 then
					for i = 1 , #tagAnalyseResult[3] do
						if tagAnalyseResult[3][i] ~= -1 then
						if i % 3 == 1 then 
							if self:GetCardLogicValue(tagAnalyseResult[3][i]) > value and self:GetCardLogicValue(tagAnalyseResult[3][i]) ~= 15 and self:GetCardLogicValue(tagAnalyseResult[3][i]) ~=3 then
								if tagAnalyseResult[1][2] ~= - 1 then
									table.insert(buf,{tagAnalyseResult[3][i],tagAnalyseResult[1][1],tagAnalyseResult[1][2],tagAnalyseResult[5][1],tagAnalyseResult[3][i+1],tagAnalyseResult[3][i+2]})
								elseif  tagAnalyseResult[2][2] ~=-1 then
									table.insert(buf,{tagAnalyseResult[3][i],tagAnalyseResult[2][1],tagAnalyseResult[2][2],tagAnalyseResult[5][1],tagAnalyseResult[3][i+1],tagAnalyseResult[3][i+2]})
								elseif  tagAnalyseResult[3][2] ~= -1 and self:GetCardLogicValue(tagAnalyseResult[3][2]) < value  then
									table.insert(buf,{tagAnalyseResult[3][i],tagAnalyseResult[3][1],tagAnalyseResult[3][2],tagAnalyseResult[5][1],tagAnalyseResult[3][i+1],tagAnalyseResult[3][i+2]})
								end 
							end
						end
						end
					end
				end
				if isfunc and #buf ~=0  then

					local t = {}
	
					for i = 1 , #buf do
						t[i] = buf[#buf-i+1]
					end



					--print("#######"..#t)

					return t

				end
		elseif key == CT_FOUR_TAKE_TWO  then
			if landType == 3 then return end
			--if tagAnalyseResult[5][1] ~= -1 then  
			for i = 1 , #tagAnalyseResult[4] do
				if tagAnalyseResult[4][i] ~= -1 then
				if i % 4 == 1 then
				if self:GetCardLogicValue(tagAnalyseResult[4][i]) > value then			
					if  tagAnalyseResult[2][4] ~= -1 then
						table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[2][1],tagAnalyseResult[2][2],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3],tagAnalyseResult[2][4],tagAnalyseResult[2][3]})
					elseif  tagAnalyseResult[3][6] ~= -1 then
						table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[3][1],tagAnalyseResult[3][2],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3],tagAnalyseResult[3][4],tagAnalyseResult[3][5]})
					end
				end
				end
				end
			end
			if tagAnalyseResult[5][1] ~= -1 then

				for i = 1 , #tagAnalyseResult[3] do
                    --if tagAnalyseResult[3][i] ~= -1 then
					if tagAnalyseResult[3][i] ~= -1 and self:is(tagAnalyseResult[3][i]) then --添加癞子不能等于2
					if i % 3 == 1 then
					if self:GetCardLogicValue(tagAnalyseResult[3][i]) > value then			
						if  tagAnalyseResult[2][4] ~= -1 then
							table.insert(buf,{tagAnalyseResult[3][i],tagAnalyseResult[2][1],tagAnalyseResult[2][2],tagAnalyseResult[3][i+1],tagAnalyseResult[3][i+2],tagAnalyseResult[5][1],tagAnalyseResult[2][4],tagAnalyseResult[2][3]})
						elseif  tagAnalyseResult[3][6] ~= -1 and i > 6 then
							table.insert(buf,{tagAnalyseResult[3][i],tagAnalyseResult[3][1],tagAnalyseResult[3][2],tagAnalyseResult[3][i+1],tagAnalyseResult[3][i+2],tagAnalyseResult[5][1],tagAnalyseResult[3][4],tagAnalyseResult[3][5]})
						end
					end
					end
					end
				end


				for i = 1 , #tagAnalyseResult[4] do
					if tagAnalyseResult[4][i] ~= -1 then
						if i % 4 == 1 then
							if self:GetCardLogicValue(tagAnalyseResult[4][i]) > value then			
								if  tagAnalyseResult[2][2] ~= -1 and  tagAnalyseResult[1][1] ~= -1 then
									table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[2][1],tagAnalyseResult[2][2],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3],tagAnalyseResult[1][1],tagAnalyseResult[5][1]})
								elseif  tagAnalyseResult[3][3] ~= -1 and  tagAnalyseResult[1][1] ~= -1 then
								 	table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[3][1],tagAnalyseResult[3][2],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3],tagAnalyseResult[1][1],tagAnalyseResult[5][1]})
								end
							end
						end
					end
				end


			end


				if isfunc and #buf ~=0 then

					local t = {}
	
					for i = 1 , #buf do
						t[i] = buf[#buf-i+1]
					end

					return t
					
				end

		elseif key == CT_BOMB_CARD then
			-- 二炸
			if landType == 3 then
				local num = #tagAnalyseResult[2]
				local idx = 1
				for i = 1 , num do
					if tagAnalyseResult[2][i] ~= -1 then
						idx = i
					end
				end
				if idx ~= 1 then
					if self:GetCardLogicValue(tagAnalyseResult[2][idx]) == 15 then
						if value == 1 then
							table.insert(buf,{tagAnalyseResult[2][idx-1],tagAnalyseResult[2][idx]})
						end
					end
				end
			end
			-- 四炸
			for i = 1 , #tagAnalyseResult[4] do
				if tagAnalyseResult[4][i] ~= -1 then
					if self:GetCardLogicValue(tagAnalyseResult[4][i]) > value then
						if i % 4 == 0 then
							table.insert(buf,{tagAnalyseResult[4][i-3],tagAnalyseResult[4][i-1],tagAnalyseResult[4][i-2],tagAnalyseResult[4][i]})
						end
					end
				end
			end
			-- 花炸
			if tagAnalyseResult[5][1] ~= -1 then
				for i = 1 , #tagAnalyseResult[3] do
					if tagAnalyseResult[3][i] ~= -1 then
						if self:GetCardLogicValue(tagAnalyseResult[3][i]) > value and self:GetCardLogicValue(tagAnalyseResult[3][i]) ~= 15 and self:GetCardLogicValue(tagAnalyseResult[3][i]) ~=3 then
							if i % 3 == 0 then
								table.insert(buf,{tagAnalyseResult[5][1],tagAnalyseResult[3][i-1],tagAnalyseResult[3][i-2],tagAnalyseResult[3][i]})
							end
						end
					end
				end
			end
			-- 王
			local num = #tagAnalyseResult[1]
			local idx = 1
			for i = 1 , num do
				if tagAnalyseResult[1][i] ~= -1 then
					idx = i
				end
			end
			if idx ~= 1 then
				
		
				if self:GetCardLogicValue(tagAnalyseResult[1][idx]) -1 ==  self:GetCardLogicValue(tagAnalyseResult[1][idx-1]) and
				 self:GetCardLogicValue(tagAnalyseResult[1][idx]) == 17 then
					table.insert(buf,{tagAnalyseResult[1][idx],tagAnalyseResult[1][idx-1]})
				end
			end

		elseif key == CT_MISSILE_CARD then
			
		end

		self:log("csw___",#buf)
		
		if key ~= CT_BOMB_CARD and key ~= CT_MISSILE_CARD and not bool then -- 炸弹公共 
			if landType == 3 or landType == 2 then -- 3  炸
				if tagAnalyseResult[2][2] ~= -1 or tagAnalyseResult[3][3] ~= -1 or tagAnalyseResult[4][4] ~= -1 then
					if self:GetCardLogicValue(tagAnalyseResult[2][2]) == 3 then
						if landType == 2 then 
							local colorValue = yl.POKER_COLOR[tagAnalyseResult[2][1]] + yl.POKER_COLOR[tagAnalyseResult[2][2]]

							if gt.three_bomb then
								if colorValue == 32 or colorValue == 64 then
									if isfunc then
										if #_cbHandCard == 2 then
											table.insert(buf,{tagAnalyseResult[2][1],tagAnalyseResult[2][2]})
										end
									else
										table.insert(buf,{tagAnalyseResult[2][1],tagAnalyseResult[2][2]})
									end
									
								end
							else
								if isfunc then
									if #_cbHandCard == 2 then
										table.insert(buf,{tagAnalyseResult[2][1],tagAnalyseResult[2][2]})
									end
								else
									table.insert(buf,{tagAnalyseResult[2][1],tagAnalyseResult[2][2]})
								end
							end
						else
							if isfunc then
									if #_cbHandCard == 2 then
										table.insert(buf,{tagAnalyseResult[2][1],tagAnalyseResult[2][2]})
									end
								else
									table.insert(buf,{tagAnalyseResult[2][1],tagAnalyseResult[2][2]})
								end
						end
					end
					if self:GetCardLogicValue(tagAnalyseResult[3][3]) == 3 then
						
						
						if landType == 3 then 
							if not isfunc then
								table.insert(buf,{tagAnalyseResult[3][1],tagAnalyseResult[3][2]})
							end
						else
							if gt.three_bomb then
								local colorValue = yl.POKER_COLOR[tagAnalyseResult[3][1]] + yl.POKER_COLOR[tagAnalyseResult[3][3]]
								if colorValue == 32 or colorValue == 64 then
									if not isfunc then
										table.insert(buf,{tagAnalyseResult[3][1],tagAnalyseResult[3][3]})
									end
								end
								

								local colorValue = yl.POKER_COLOR[tagAnalyseResult[3][2]] + yl.POKER_COLOR[tagAnalyseResult[3][3]]
								if colorValue == 32 or colorValue == 64 then
									if not isfunc then
									table.insert(buf,{tagAnalyseResult[3][2],tagAnalyseResult[3][3]})
									end
								end


								local colorValue = yl.POKER_COLOR[tagAnalyseResult[3][1]] + yl.POKER_COLOR[tagAnalyseResult[3][2]]
								if colorValue == 32 or colorValue == 64 then
									if not isfunc then
									table.insert(buf,{tagAnalyseResult[3][2],tagAnalyseResult[3][1]})
									end
								end
							else
								if not isfunc then
									table.insert(buf,{tagAnalyseResult[3][1],tagAnalyseResult[3][2]})
								end
							end
						end
						
					end
					if self:GetCardLogicValue(tagAnalyseResult[4][4]) == 3 and not isfunc then

						-- if gt.three_bomb then
						-- 	local colorValue = yl.POKER_COLOR[tagAnalyseResult[][1]] + yl.POKER_COLOR[tagAnalyseResult[3][3]]

						-- --if landType == 3 then 
						-- else
						 	if not isfunc then
								table.insert(buf,{tagAnalyseResult[4][1],tagAnalyseResult[4][3]})
								table.insert(buf,{tagAnalyseResult[4][2],tagAnalyseResult[4][4]})
							end
						--end
						-- else
						-- 	local colorValue = yl.POKER_COLOR[tagAnalyseResult[4][1]] + yl.POKER_COLOR[tagAnalyseResult[4][2]]
						-- 	if colorValue == 32 or colorValue == 64 then
						-- 		if not isfunc then
						-- 			table.insert(buf,{tagAnalyseResult[4][1],tagAnalyseResult[4][2]})
						-- 		end
						-- 	end

						-- 	local colorValue = yl.POKER_COLOR[tagAnalyseResult[4][3]] + yl.POKER_COLOR[tagAnalyseResult[4][4]]
						-- 	if colorValue == 32 or colorValue == 64 then
						-- 		if not isfunc then
						-- 			table.insert(buf,{tagAnalyseResult[4][1],tagAnalyseResult[4][2]})
						-- 		end
						-- 	end

						--end
					end
				end
			end
			-- 对2 炸
			if landType == 3 then
				local num = #tagAnalyseResult[2]
				local idx = 1
				for i = 1 , num do
					if tagAnalyseResult[2][i] ~= -1 then
						idx = i
					end
				end
				if idx ~= 1 then
					if self:GetCardLogicValue(tagAnalyseResult[2][idx]) == 15 then
						table.insert(buf,{tagAnalyseResult[2][idx-1],tagAnalyseResult[2][idx]})
					end
				end
			end
			-- 四炸
			for i = 1 , #tagAnalyseResult[4] do
				if tagAnalyseResult[4][i] ~= -1  then
				if i%4 == 1 then
					if landType == 2 then
						--if self:GetCardLogicValue(tagAnalyseResult[4][i]) ~= 3 then
							if isfunc then
								if #_cbHandCard == 4 then
									table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3]})
								end
							else
								table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3]})
							end
						--end
					else
						if isfunc then
							if #_cbHandCard == 4 then
								table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3]})
							end
						else
							table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3]})
						end
					end
				end
				end
			end

			if landType == 2 then
				-- 花4 炸
				if tagAnalyseResult[5][1] ~= -1 then
				for i = 1 , #tagAnalyseResult[3] do
					if tagAnalyseResult[3][i] ~= -1  then
					if i%3 == 1 then
						--print("self:GetCardLogicValue(tagAnalyseResult[3][i])"..self:GetCardLogicValue(tagAnalyseResult[3][i]))
						if isfunc then
							if #_cbHandCard == 4 then
								if self:GetCardLogicValue(tagAnalyseResult[3][i]) ~= 3  and self:GetCardLogicValue(tagAnalyseResult[3][i]) ~= 15 then
									table.insert(buf,{tagAnalyseResult[3][i],tagAnalyseResult[3][i+1],tagAnalyseResult[3][i+2],tagAnalyseResult[5][1]})
								end
							end
						else
							if self:GetCardLogicValue(tagAnalyseResult[3][i]) ~= 3  and self:GetCardLogicValue(tagAnalyseResult[3][i]) ~= 15 then
								table.insert(buf,{tagAnalyseResult[3][i],tagAnalyseResult[3][i+1],tagAnalyseResult[3][i+2],tagAnalyseResult[5][1]})
							end
						end
					end
					end
				end
				end
			end


			--王炸
			local num = #tagAnalyseResult[1]
			local idx = 1
			for i = 1 , num do
				if tagAnalyseResult[1][i] ~= -1 then
					idx = i
				end
			end
			if idx ~= 1 then
				if self:GetCardLogicValue(tagAnalyseResult[1][idx]) -1 ==  self:GetCardLogicValue(tagAnalyseResult[1][idx-1]) and
				 self:GetCardLogicValue(tagAnalyseResult[1][idx]) == 17 then
					table.insert(buf,{tagAnalyseResult[1][idx],tagAnalyseResult[1][idx-1]})
				end
			end

		end
		self:log("csw___3",#buf)
	end

	local t = {}
	self:log("csw___1",#buf)
	for i = 1 , #buf do
		t[i] = buf[#buf-i+1]
	end

	--print("#buf::::::::::::::",#buf)


	gt.log("#buf::::::::::::::",#buf)

	--gt.dump(buf)

	return t

end

-- 查找三张


function GameLaiziLogic:find_THREE(card,value,buf)




	for i = 1 , #card[3] do
		if card[3][i] ~= -1 then
			if i % 3 == 1 then

			if self:GetCardLogicValue(card[3][i]) > value then
				table.insert(buf,{card[3][i],card[3][i+1],card[3][i+2]})
			end
			end
		end
	end

	if card[5][1] ~= -1 then 
		for i = 1 , #card[2] do
			if card[2][i] ~= -1 then
				if i % 2 == 1 then
				if self:GetCardLogicValue(card[2][i]) > value then
					table.insert(buf,{card[2][i],card[2][i+1],card[5][1]})
				end
				end
			end
		end
	end

	for i = 1 , #card[4] do
		if i % 4 ~= 0 then
			if i %4 == 1 then
			if card[4][i] ~= -1 then
				if self:GetCardLogicValue(card[4][i]) > value then
					table.insert(buf,{card[4][i],card[4][i+1],card[4][i+2],card[4][i+3]})
				end
			end
			end
		end
	end
	
end


function GameLaiziLogic:find_THREE_LINE(fj, fj1 ,fj2,num,value,buf)

	num = num * 3
	self:log("num______c",num)
	local tbuf = {}
	for i = 1, #fj do
		if i % 3 == 1 then
			if  self:GetCardLogicValue(fj[i]) > value and i + num -1 <= #fj then
				self:log("i",i)
				--table.insert(buf,{fj[i],fj[i+1],fj[i+2]})
				for j = i , num + i -1 do
					--if j % 3 == 1 then 
						self:log("add_________",self:GetCardLogicValue(fj[j]),j)
						table.insert(tbuf,fj[j])
					--end
				end
				self:log("adds__________-")
				table.insert(buf,tbuf)
			end 

		end
	end
	tbuf = {}
	for i = 1, #fj1 do
		if i % 3 == 1 then
		if  self:GetCardLogicValue(fj1[i]) > value and i + num -1 <= #fj1 then
			for j = i , num + i -1 do
				table.insert(tbuf,fj[j])
			end
			table.insert(buf,tbuf)
		end 
		end
	end
	tbuf = {}
	for i = 1, #fj2 do
		if i % 3 == 1 then
		if  self:GetCardLogicValue(fj2[i]) > value and i + num -1 <= #fj2 then
			for j = i , num + i -1 do
				table.insert(tbuf,fj[j])
			end
			table.insert(buf,tbuf)
		end 
		end
	end

end

function GameLaiziLogic:compare(buf,value,num,buf1)
	
	local idx = 1
	for i = 1, #buf  do
	
		if  self:GetCardLogicValue(buf[i]) == self:GetCardLogicValue(buf[i+1]) and self:GetCardLogicValue(buf[i]) == self:GetCardLogicValue(buf[i+2]) then
			idx = 3
			break
		elseif self:GetCardLogicValue(buf[i]) == self:GetCardLogicValue(buf[i+1])  then
			idx = 2
			break
		else 
			idx = 1
			break
		end
	end
	local T = 1
	if idx == 1 then
		T = 0
	end
	gt.log("#######",#buf)
	gt.log("num,........",num)
	local card = {}
	for i = 1, #buf do                                -- 10    1      6
		if i % idx == T then
			gt.log("iii",i)
			if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num - 1 then
				for j = i , num + i -1 do
					table.insert(card,buf[j])
				end 
			
				table.insert(buf1,card)
				card = {}
			end 
		end
	end

	gt.log("buf1......",#buf1)

end


--[[
	  fj,value,num*3,buf,tagAnalyseResult)
	  local fj = self:sandaiyi1(tagAnalyseResult,value,num*3,buf)
	  function GameLaiziLogic:compareFeiji1_s(buf,value,num,buf1,tagAnalyseResult,

]]

function GameLaiziLogic:sandaiyi1( card ,value,num,buf1,isfunc)
	
	local t = {}
	--local buf = {}

	local tmp_buf = buf1

	local func = function(buf)
		gt.log("buf.....csw.",#buf)
		gt.dump(buf)
		local cards = {} 
		local j = 0
		local k = 1
		
		if card[2][2] ~= -1  then
			for i = 1, #buf do
				if i % 3 == 1 then
				if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 and self:GetCardLogicValue(buf[i]) ~= 15 then
					for j = i , num + i - 1  do
						if j % 3 == 1 then
							table.insert(cards,buf[j])
							table.insert(cards,buf[j+1])
							table.insert(cards,buf[j+2])
						end
					end 
					for x = 1 , 2 do
						table.insert(cards,card[2][x])
					end
					table.insert(buf1,cards)
					cards = {}
				end 
				
				end
			end
		end 

		if card[1][1] ~= -1 and self:is(card[1][1]) and card[5][1] ~= -1 then 
			cards = {}
			for i = 1, #buf do
				if i % 3 == 1 then
				if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 and self:GetCardLogicValue(buf[i]) ~= 15 then
					for j = i , num + i - 1  do
						if j % 3 == 1 then
							table.insert(cards,buf[j])
							table.insert(cards,buf[j+1])
							table.insert(cards,buf[j+2])
						end
					end 
					
					table.insert(cards,card[1][1])
					table.insert(cards,card[5][1])
					table.insert(buf1,cards)
					cards = {}
				end 
				
				end
			end
		end

	end






	for i = 1 , #card[3] do
		if card[3][i] ~= -1 then
			--if self:GetCardLogicValue(card[3][i]) ~= 15 then  --~= 2
				table.insert(t,card[3][i])
			--end
		end
	end
	func(t)

	
	t = {}
	local ts = {}
	for i = 1 , #card[2] do

		if card[2][i] ~= -1 then
		--if self:GetCardLogicValue(card[2][i]) ~= 15 then  --~= 2
			table.insert(ts,card[2][i])
		--end
	end
	end

	for i = 1 , #card[3] do
		if card[3][i] ~= -1 then
		if i %3 ~= 0 then
			--if self:GetCardLogicValue(card[3][i]) ~= 15 then  --~= 2
				table.insert(ts,card[3][i])
			--end
		end
	end
	end

	for i = 1 , #card[4] do
		if card[4][i] ~= -1 then
		if i %4 ~= 0 and  i %3 ~= 0  then
			--if self:GetCardLogicValue(card[4][i]) ~= 15 then  --~= 2
				table.insert(ts,card[4][i])
			--end
		end
	end
	end


	local tmp  = self:SortCardListUp(ts,#ts,0) -- 升序


	for i =1 , #tmp do
		if i % 2 == 1 then
			if self:GetCardLogicValue(tmp[i]) > value and self:is(self:GetCardLogicValue(tmp[i])) and #tmp >=4  then  
				if i == 1  then 
					gt.log("1________________________")
					if self:GetCardLogicValue(tmp[i]) ~= 15 then 
						table.insert(buf1,{tmp[i],tmp[i+1],tmp[i+2],tmp[i+3],card[5][1]})
					end
				else
					gt.log("2________________________")
					if self:GetCardLogicValue(tmp[i]) ~= 15 then 
						table.insert(buf1,{tmp[i],tmp[i+1],tmp[i-1],tmp[i-2],card[5][1]})
					end
				end
			end
		end
	end


	t = {}
	for i = 1 , #card[4] do
		if card[4][i] ~= -1 then
			if i %4 ~= 0 then
				--if self:GetCardLogicValue(card[4][i]) ~= 15 then  --~= 2
					table.insert(t,card[4][i])
				--end
			end
		end
	end
	func(t)

	

	-- buf = self:SortCardListUp(t,#t,0) -- 升序
	-- return buf 

end

function GameLaiziLogic:sandaiyi(card)
	local t = {}
	local buf = {}


	for i = 1 , #card[3] do
		if card[3][i] ~= -1 then
			--if self:GetCardLogicValue(card[3][i]) ~= 15 then  --~= 2
				table.insert(t,card[3][i])
			--end
		end
	end
	-- if card[5][1] ~= -1 then 
	-- 	for i = 1 , #card[2] do
	-- 		if card[2][i] ~= -1 then
	-- 			--if self:GetCardLogicValue(card[3][i]) ~= 15 then  --~= 2
	-- 				table.insert(t,card[2][i])
	-- 			--end
	-- 		end
	-- 	end
	-- end

	for i = 1 , #card[4] do
		if card[4][i] ~= -1 then
			if i %4 ~= 0 then
				--if self:GetCardLogicValue(card[4][i]) ~= 15 then  --~= 2
					table.insert(t,card[4][i])
				--end
			end
		end
	end

	buf = self:SortCardListUp(t,#t,0) -- 升序

	
	return buf 


end

function GameLaiziLogic:findfj(card) 

	local t = {}
	local buf = {}


	-- for i = 1 , #card[2] do
		
	-- 	if card[2][i] ~= -1 then
	-- 		if self:GetCardLogicValue(card[2][i]) ~= 15 and self:is(self:GetCardLogicValue(card[2][i])) then  --~= 2
	-- 			table.insert(t,card[2][i])
	-- 		end
	-- 	end
	-- end
	
	for i = 1 , #card[3] do
		
		if card[3][i] ~= -1 then
			if self:GetCardLogicValue(card[3][i]) ~= 15 then  --~= 2
				table.insert(t,card[3][i])
			end
		end
	end

	for i = 1 , #card[4] do
		if card[4][i] ~= -1 then
			if i %4 ~= 0 then
				if self:GetCardLogicValue(card[4][i]) ~= 15 then  --~= 2
					table.insert(t,card[4][i])
				end
			end
		end
	end


	buf = self:SortCardListUp(t,#t,0) -- 升序

	self:log("a_______________-")
	for i = 1 , #buf do
		self:log(self:GetCardLogicValue(buf[i]))
	end

	
	local num = 3
	local _sz = {}
	local __sz = {}
	local ___sz = {}
	local i = 0
	local tmp = 0
	local isbreak = false
	while i<= #buf do 
		i = i +1
		if i % 3 == 1 then
		for j = i +1 ,#buf do
			if j %3 == 1 then -- 1 3 5 7
			if self:GetCardLogicValue(buf[i]) + (j-i)/3 == self:GetCardLogicValue(buf[j]) then	
			--if buf[i] + (j -i)/3 == buf[j] then
				num = num + 3
				tmp = i
				
				if j+2 == #buf then -- 找到最后 没有不同
					
					isbreak = true
				else
					isbreak = false
				end
				
			else
				
				if num >= 6 then
					if #_sz == 0 then
						for x =tmp , num + tmp -1 do
							table.insert(_sz,buf[x])
						end
					elseif #__sz == 0 then
						for x =tmp , num + tmp -1 do
							table.insert(__sz,buf[x])
						end
					elseif #___sz == 0 then
						for x =tmp , num + tmp -1 do
							table.insert(___sz,buf[x])
						end
					end
				end
				i = j -1
				num = 3
				break
			end
			end
		end
		end
	
		if num >= 6 and isbreak then
			if #_sz == 0 then
				for x =tmp , num + tmp -1 do
					table.insert(_sz,buf[x])
				end
			elseif #__sz == 0 then
				
				for x =tmp , num + tmp -1 do
					table.insert(__sz,buf[x])
				end
			elseif #___sz == 0 then
				for x =tmp , num + tmp -1 do
					table.insert(___sz,buf[x])
				end
			end
			break
		end

	end
	gt.log("feijin___________")



	gt.dump(_sz)

	gt.dump(___sz)
	gt.dump(__sz)

	return _sz , __sz ,___sz
	--return #_sz , _sz , #__sz , __sz 

end



function GameLaiziLogic:compareThreeTakeTwo(buf,value,num,buf1,tagAnalyseResult)
	

	local card = {} 
	local j = 0
	local k = 1
	local x = 1
	-- gt.log("tagAnalyseResult============")
	-- gt.dump(tagAnalyseResult)
	local tempValue = 0
	-- if tagAnalyseResult[2][2*num/3] ~= -1  then
	if (tagAnalyseResult[2][2] ~= -1 ) or 
		(tagAnalyseResult[2][2*num/3] == -1 and tagAnalyseResult[3][1] ~= -1 and tagAnalyseResult[3][4] ~= -1) then
		for i = 1, #buf do
			if i % 3 == 1 then
			if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 then
				if tagAnalyseResult[2][2] == -1 and tagAnalyseResult[3][4] ~= -1 then
					for x = 1 , 2*num/3 do
						table.insert(card,tagAnalyseResult[3][x])
						if tempValue == 0 then
							tempValue = self:GetCardLogicValue(tagAnalyseResult[3][x])
						end
					end
				end
				for j = i , num + i - 1  do
					if j % 3 == 1 then
						if tempValue == 0 or (tempValue ~= 0 and tempValue ~=  self:GetCardLogicValue(buf[j])) then
							table.insert(card,buf[j])
							table.insert(card,buf[j+1])
							table.insert(card,buf[j+2])
						end
					end
				end 
				for x = 1 , 2*num/3 do
					if tagAnalyseResult[2][x] ~= -1 then
						table.insert(card,tagAnalyseResult[2][x])
					end
				end

				table.insert(buf1,card)
				card = {}
			end 
			x = 1
			end
		end
	end 
	-- gt.log("buf1==========")
	-- gt.dump(buf1)

end

function GameLaiziLogic:compareFeiji1(buf,value,num,buf1,tagAnalyseResult)
	

	local card = {} 
	local j = 0
	local k = 1
	local x = 1
	if tagAnalyseResult[2][2*num/3] ~= -1  then
		for i = 1, #buf do
			if i % 3 == 1 then
			if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 then
				for j = i , num + i - 1  do
					if j % 3 == 1 then
							
							table.insert(card,buf[j])
							table.insert(card,buf[j+1])
							table.insert(card,buf[j+2])
					end
				end 
				for x = 1 , 2*num/3 do
					table.insert(card,tagAnalyseResult[2][x])
				end
				table.insert(buf1,card)
				card = {}
			end 
			x = 1
			end
		end
	end 


end

function GameLaiziLogic:compareFeiji1_s(buf,value,num,buf1,tagAnalyseResult,type)
	

	local card = {} 
	local j = 0
	local k = 1
	local x = 1
	if tagAnalyseResult[2][2*num/3] ~= -1  then
		for i = 1, #buf do
			if i % 3 == 1 then
			if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 then
				for j = i , num + i - 1  do
					if j % 3 == 1 then
							
							table.insert(card,buf[j])
							table.insert(card,buf[j+1])
							table.insert(card,buf[j+2])
					end
				end 
				for x = 1 , 2*num/3 do
					table.insert(card,tagAnalyseResult[2][x])
				end
				table.insert(buf1,card)
				card = {}
			end 
			x = 1
			end
		end
	end 


end

function GameLaiziLogic:compareFeiji2(buf,value,num,buf1,tagAnalyseResult)
	

	local card = {} 
	local j = 0
	local k = 0
	local x = 1

	local daipai = 0

	for i = 1 ,#tagAnalyseResult[2] do
		if tagAnalyseResult[2][i] == -1 then
			break
		end
		daipai = daipai + 1
	end

	local daipai1 = 0
	for i = 1 ,#tagAnalyseResult[3] do
		if tagAnalyseResult[3][i] == -1 then
			break
		end
		daipai1 = daipai1 + 1
	end

	
	if daipai/2 >= num/3 then
		
		for i = 1, #buf do
			
			if i % 3 == 1 then
				if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 then
					
					for j = i , num + i - 1  do
						
						if j % 3 == 1 then
							
							table.insert(card,buf[j])
							table.insert(card,buf[j+1])
							table.insert(card,buf[j+2])
						end
						
					end 
					if #card == num then 

						for i = 1, num/3*2 do
							table.insert(card,tagAnalyseResult[2][i])
							k = k  + 1
						end
					end
					table.insert(buf1,card)
					card = {}
					k = 0
				end 
			end
		end
	elseif daipai/2 + daipai1/3 - num/3 >= num/3 then 
		gt.log("ok__________________-")

		for i = 1, #buf do
			
			if i % 3 == 1 then
				if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 then
				
					local tmpcard= {}
					for j = i , num + i - 1  do
						
						if j % 3 == 1 then
							
							table.insert(card,buf[j])
							table.insert(card,buf[j+1])
							table.insert(card,buf[j+2])

							table.insert(tmpcard,buf[j])
							table.insert(tmpcard,buf[j+1])
							table.insert(tmpcard,buf[j+2])
						end
						
					end 
					gt.log("#card.........k",#card)
					if #card == num then 


						for i = 1, daipai do
							table.insert(card,tagAnalyseResult[2][i])
							k = k  + 1
						end


						for o = 1 , #tagAnalyseResult[3] do
							if tagAnalyseResult[3][o] ~= -1 and o%3 ~= 0 then 
								local bool = false
								for x = 1 , #tmpcard do

									if self:GetCardLogicValue(tmpcard[x]) == self:GetCardLogicValue(tagAnalyseResult[3][o]) then
										bool  = true
									end
								end
								if not bool then 
									table.insert(card,tagAnalyseResult[3][o])
									k = k + 1 
									if k == num/3*2 then break end
								end
							end
						end

						table.insert(buf1,card)
						card = {}
						k = 0
				
					end
					
				end		
			end
		end


	end 
	-- print("buf1............."..#buf1[1])
	-- print("buf1............."..#buf1[2])

end


function GameLaiziLogic:compareFeiji3(buf,value,num,buf1,tagAnalyseResult)
	

	local card = {} 
	local j = 0
	local k = 1
	local x = 1

	

	local daipai1 = 0
	local daipai = 0
	local tmp = {}
	for i = 1 ,#tagAnalyseResult[1] do
		if tagAnalyseResult[1][i] ~= -1 and  self:is(tagAnalyseResult[1][i]) then
			daipai1 = daipai1 + 1
			table.insert(tmp,tagAnalyseResult[1][i])
		end
	end

	for i = 1 ,#tagAnalyseResult[2] do
		if tagAnalyseResult[2][i] == -1 then
			break
		end
		daipai = daipai + 1
	end

	if daipai + daipai1 >= num/3 then
		
		for i = 1, #buf do
			
			if i % 3 == 1 then
				if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 then
					
					for j = i , num + i - 1  do
						
						if j % 3 == 1 then
							
							table.insert(card,buf[j])
							table.insert(card,buf[j+1])
							table.insert(card,buf[j+2])

						end
						
					end 
	
				end
			end
		end
		gt.log("card------",#card)
		if daipai1 == 0 then 
			for i = 1 , num do
				table.insert(card,tagAnalyseResult[2][i])
				gt.log("card------1",#card)
			end
		else
			for i = 1 , num/3 -1 do
				table.insert(card,tagAnalyseResult[2][i])
				table.insert(card,tagAnalyseResult[2][i+1])
				gt.log("card------2",#card)
			end
			table.insert(card,tmp[1])
			table.insert(card,tagAnalyseResult[5][1])
			gt.log("card------3",#card)
		end

		for i = 1, #card do
			gt.log("card___csw",card[i])
		end

		table.insert(buf1,card)

	end 




	gt.log("buf__csw___",#buf1)
	

end

function GameLaiziLogic:compareFeiji(buf,value,num,buf1,tagAnalyseResult)
	

	local card = {} 
	local j = 0
	local k = 1
	local x = 1

	

	local daipai = 0

	for i = 1 ,#tagAnalyseResult[1] do
			if tagAnalyseResult[1][i] == -1 then
				break
			end
			daipai = daipai + 1
	end

	for i = 1 ,#tagAnalyseResult[2] do
		if tagAnalyseResult[2][i] == -1 then
			break
		end
		daipai = daipai + 1
	end


	if daipai >= num/3 then
		
		for i = 1, #buf do
			
			if i % 3 == 1 then
				if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 then
					
					for j = i , num + i - 1  do
						
						if j % 3 == 1 then
							
							table.insert(card,buf[j])
							table.insert(card,buf[j+1])
							table.insert(card,buf[j+2])
						end
						
					end 
					while k <= num/3 do
							if tagAnalyseResult[1][k] ~= -1   then
								table.insert(card,tagAnalyseResult[1][k])
							else--if tagAnalyseResult[2][k] ~= -1 and self:GetCardLogicValue(buf[i]) ~= self:GetCardLogicValue(tagAnalyseResult[2][k])  then
								table.insert(card,tagAnalyseResult[2][x])
								x = x +1
							end
							k = k + 1 
					end
					table.insert(buf1,card)
					card = {}
				end 
			k = 1
			end
		end

	end 
	

end

function GameLaiziLogic:findld(card) 

	local t = {}
	local buf = {}

	for i = 1 , #card[2] do

		if card[2][i] ~= -1 then
		if self:GetCardLogicValue(card[2][i]) ~= 15 then  --~= 2
			table.insert(t,card[2][i])
		end
	end
	end

	for i = 1 , #card[3] do
		if card[3][i] ~= -1 then
		if i %3 ~= 0 then
			if self:GetCardLogicValue(card[3][i]) ~= 15 then  --~= 2
				table.insert(t,card[3][i])
			end
		end
	end
	end

	for i = 1 , #card[4] do
		if card[4][i] ~= -1 then
		if i %4 ~= 0 and  i %3 ~= 0  then
			if self:GetCardLogicValue(card[4][i]) ~= 15 then  --~= 2
				table.insert(t,card[4][i])
			end
		end
	end
	end


	buf = self:SortCardListUp(t,#t,0) -- 升序

	--local buf = card
	local num = 2
	local _sz = {}
	local __sz = {}
	local ___sz = {}
	local i = 0
	local tmp = 0
	local isbreak = false
	while i<= #buf do 
		i = i +1
		if i % 2 == 1 then
		for j = i +1 ,#buf do
			if j %2 == 1 then -- 1 3 5 7
			if self:GetCardLogicValue(buf[i]) + (j-i)*0.5 == self:GetCardLogicValue(buf[j]) then	
			--if buf[i] + (j -i)*0.5 == buf[j] then
				num = num + 2
				tmp = i
				
				if j+1 == #buf then -- 找到最后 没有不同
					isbreak = true
				else
					isbreak = false
				end
				
			else
				
				if num >= 6 then
					if #_sz == 0 then
						for x =tmp , num + tmp -1 do
							table.insert(_sz,buf[x])
						end
					elseif #__sz == 0 then
						for x =tmp , num + tmp -1 do
							table.insert(__sz,buf[x])
						end
					elseif #___sz == 0 then
						for x =tmp , num + tmp -1 do
							table.insert(___sz,buf[x])
						end
					end
				end
				i = j -1
				num = 2
				break
			end
			end
		end
		end
	
		if num >= 6 and isbreak then
			if #_sz == 0 then
				for x =tmp , num + tmp -1 do
					table.insert(_sz,buf[x])
				end
			elseif #__sz == 0 then
				
				for x =tmp , num + tmp -1 do
					table.insert(__sz,buf[x])
				end
			elseif #___sz == 0 then
				for x =tmp , num + tmp -1 do
					table.insert(___sz,buf[x])
				end
			end
			break
		end

	end



	return _sz , __sz ,___sz

end

function GameLaiziLogic:findShunzi(card) --ppp

	local t = {}
	local buf = {}
	for i = 1 ,#card[1] do
		if card[1][i] ~= -1  then
			if self:GetCardLogicValue(card[1][i]) ~= 15 then 
				table.insert(t,card[1][i])
			end
		end
	end
	for i = 2 , 4 do
		for j =1 , #card[i] do	
		if 	card[i][j] ~= -1 then
			if j%i == 1 then
				if self:GetCardLogicValue(card[i][j]) ~= 15 then  --~= 2
					table.insert(t,card[i][j])
				end
			end	
		end
		end
	end

	buf = self:SortCardListUp(t,#t,0) -- 升序
	
	--local card = {1,2,4,5,6,7,8,9,11,12}

	local num = 1
	local _sz = {}
	local __sz = {}
	local i = 0
	local tmp = 0
	local isbreak = false
	while i<= #buf do 
		i = i +1
		for j = i +1 ,#buf do
			if self:GetCardLogicValue(buf[i]) + j-i == self:GetCardLogicValue(buf[j]) then	
			--if buf[i] + j -i == buf[j] then
				num = num + 1
				tmp = i
				if j == #buf then -- 找到最后 没有不同
					isbreak = true
				else
					isbreak = false
				end
			else
				if num >= 5 then
					if #_sz == 0 then
						for x =tmp , num + tmp -1 do
							table.insert(_sz,buf[x])
						end
					else
						for x =tmp , num + tmp -1 do
							table.insert(__sz,buf[x])
						end
					end
				end
				i = j - 1
				num = 1
				break
			end
		end

		if num >= 5 and isbreak then
			if #_sz == 0 then
				for x =tmp , num + tmp -1 do
					table.insert(_sz,buf[x])
				end
			else
				for x =tmp , num + tmp -1 do
					table.insert(__sz,buf[x])
				end
			end	
			break
		end

	end


	return #_sz , _sz , #__sz , __sz 

end

--[[
	
	cbHandCard 手牌
	cbFirstCard 上家出的牌
]]
function GameLaiziLogic:getMaxCardType(cbHandCard,cbFirstCard) --tishi 

	local tagAnalyseResult = self:AnalysebCardData(cbHandCard,#cbHandCard) -- 找出扑克结构
	cbFirstCard = self:SortCardListUp(cbFirstCard,#cbFirstCard,0) -- >小->大
	local cbFirstType = GameLaiziLogic:GetCardType(cbFirstCard, #cbFirstCard) -- 返回牌型 上家出的牌

	if tagAnalyseResult[1][5] <= 0 then
		return self:SearchOutCard(cbHandCard, #cbHandCard, cbFirstCard, #cbFirstCard)
	end
	local cbResultCount = 1
    --ÆË¿ËÊýÄ¿
    local cbResultCardCount = {}
    --½á¹ûÆË¿Ë
    local cbResultCard = {}
	--ñ®×ÓÅÆ
	local cbLaiziCard = {}
    --ËÑË÷½á¹û
    local tagSearchCardResult = {cbResultCount-1,cbResultCardCount,cbResultCard}
	local sortList = self:SortCardList(cbHandCard,#cbHandCard,0) -- 大->小
	if sortList[2] == 0x4F and sortList[3] == 0x4E then
		tagSearchCardResult[1] = 1
		table.insert(tagSearchCardResult[2],2)
		cbResultCard = {0x4F,0x4E}
		
		table.insert(tagSearchCardResult[3],cbResultCard)
		return tagSearchCardResult
	end
	if cbFirstType == GameLaiziLogic.CT_MISSILE_CARD then
		return tagSearchCardResult
	end
	
	if cbFirstType == GameLaiziLogic.CT_BOMB_CARD then
		if tagAnalyseResult[1][4] > 0 then
			if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][4][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],4)
				cbResultCard = {tagAnalyseResult[2][4][1],tagAnalyseResult[2][4][2],tagAnalyseResult[2][4][3],tagAnalyseResult[2][4][4]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end
		end 
		if tagAnalyseResult[1][3] > 0 then
			if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
				if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) ~=  3 and 
					GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) ~= 15 then
					tagSearchCardResult[1] = 1
					table.insert(tagSearchCardResult[2],4)
					cbResultCard = {tagAnalyseResult[2][3][1],tagAnalyseResult[2][3][2],tagAnalyseResult[2][3][3],tagAnalyseResult[2][5][1]}
					table.insert(tagSearchCardResult[3],cbResultCard)
					return tagSearchCardResult
				end 
			end
		end
	end
	if tagAnalyseResult[1][4] > 0 then
		if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][4][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
			tagSearchCardResult[1] = 1
			table.insert(tagSearchCardResult[2],4)
			cbResultCard = {tagAnalyseResult[2][4][1],tagAnalyseResult[2][4][2],tagAnalyseResult[2][4][3],tagAnalyseResult[2][4][4]}
			table.insert(tagSearchCardResult[3],cbResultCard)
			return tagSearchCardResult
		end
	end 
	if tagAnalyseResult[1][3] > 0 then
		if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
			if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) ~=  3 and 
					GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) ~= 15 then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],4)
				cbResultCard = {tagAnalyseResult[2][3][1],tagAnalyseResult[2][3][2],tagAnalyseResult[2][3][3],tagAnalyseResult[2][5][1]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end 
		end
	end
	
	if cbFirstType == GameLaiziLogic.CT_THREE_TAKE_ONE then
		if tagAnalyseResult[1][2] > 0 then
			if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][2][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],4)
				if tagAnalyseResult[1][1] > 0 then
					local oneCount = #tagAnalyseResult[2][1]
					cbResultCard = {tagAnalyseResult[2][2][1],tagAnalyseResult[2][2][2],tagAnalyseResult[2][1][oneCount],tagAnalyseResult[2][5][1]}
					table.insert(tagSearchCardResult[3],cbResultCard)
					return tagSearchCardResult
				else
					local oneCount = #tagAnalyseResult[2][2]
					if tagAnalyseResult[1][2] > 1 then
						cbResultCard = {tagAnalyseResult[2][2][1],tagAnalyseResult[2][2][2],tagAnalyseResult[2][2][oneCount],tagAnalyseResult[2][5][1]}
						table.insert(tagSearchCardResult[3],cbResultCard)
						return tagSearchCardResult
					end
				end 
			end
		end
	elseif cbFirstType == GameLaiziLogic.CT_DOUBLE_LINE then
		if (tagAnalyseResult[1][2]+1)*2 >= #cbFirstCard then
			return tagSearchCardResult
		end
	elseif cbFirstType == GameLaiziLogic.CT_SINGLE_LINE then
		return tagSearchCardResult
	elseif cbFirstType == GameLaiziLogic.CT_DOUBLE then
		if tagAnalyseResult[1][2] > 0 then
			if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][2][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],2)
				cbResultCard = {tagAnalyseResult[2][2][1],tagAnalyseResult[2][2][2]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end
		end 
		if tagAnalyseResult[1][1] > 0 then
			if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][1][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],2)
				cbResultCard = {tagAnalyseResult[2][1][1],tagAnalyseResult[2][5][1]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end
		end 
		if tagAnalyseResult[1][3] > 0 then
			if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],2)
				cbResultCard = {tagAnalyseResult[2][3][1],tagAnalyseResult[2][3][2]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end
		end 
	elseif cbFirstType == GameLaiziLogic.CT_SINGLE then
		if tagAnalyseResult[1][1] > 0 then
			if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][1][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],1)
				cbResultCard = {tagAnalyseResult[2][1][1]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end
			if tagAnalyseResult[1][2] > 0 then
				if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][2][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
					tagSearchCardResult[1] = 1
					table.insert(tagSearchCardResult[2],1)
					cbResultCard = {tagAnalyseResult[2][2][1]}
					table.insert(tagSearchCardResult[3],cbResultCard)
					return tagSearchCardResult
				end
			end 
			if tagAnalyseResult[1][3] > 0 then
				if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) > GameLaiziLogic:GetCardLogicValue(cbFirstCard[1]) then
					tagSearchCardResult[1] = 1
					table.insert(tagSearchCardResult[2],1)
					cbResultCard = {tagAnalyseResult[2][3][1]}
					table.insert(tagSearchCardResult[3],cbResultCard)
					return tagSearchCardResult
				end
			end 
		end 
	end
	return tagSearchCardResult
end 

--cbFirstCard 上家的牌
-- cbHandCard 选择的牌
function GameLaiziLogic:CompareCard1(cbFirstCard,cbHandCard,landType)

	if cbHandCard and #cbHandCard == 2 then
		if self:GetCardLogicValue(cbHandCard[2]) + self:GetCardLogicValue(cbHandCard[1]) == 33 and 
			math.abs(self:GetCardLogicValue(cbHandCard[2]) - self:GetCardLogicValue(cbHandCard[1]))==1 then
			return 1
		end
	end

	if cbHandCard and #cbHandCard == 4 then
		local bool = false 
		for i = 1, 3 do
			if self:GetCardLogicValue(cbHandCard[i]) ~= self:GetCardLogicValue(cbHandCard[i+1]) then 
				bool = true
			end
		end
		if not bool then -- 是炸弹
			if cbFirstCard ~= 4 then
				return 1
			else
				bool = false
				for i = 1, 3 do
					if self:GetCardLogicValue(cbFirstCard[i]) ~= self:GetCardLogicValue(cbFirstCard[i+1]) then 
						bool = true
					end
				end
				if not bool then 
					if self:GetCardLogicValue(cbHandCard[1]) > self:GetCardLogicValue(cbFirstCard[1]) then 
						return 1
					end
				end
			end
		end
	end

	if landType == 2 and  #cbHandCard == 2 then

		local card , num = GameLaiziLogic:GetCardType1(cbHandCard, #cbHandCard,landType) -- 返回牌型 上家出的牌
		gt.dump(card)
		if card[CT_BOMB_CARD] == 1 then 
			gt.log("3炸————————————")
			if cbHandCard and #cbHandCard ~= 4 then
				return 1
			elseif cbHandCard and #cbHandCard == 4 then
				local card , num = GameLaiziLogic:GetCardType1(cbHandCard, #cbHandCard,landType) -- 返回牌型 上家出的牌
				if not card[CT_BOMB_CARD] then 
					return 1
				end
			end
		end
	end

	--print("CompareCard1...............")
	local buf = self:getMaxCardType1(cbHandCard,cbFirstCard,landType,true)



	gt.log("#buf............s",#buf,#cbHandCard)
	if #buf == 1 then--or ( #buf == 2 and buf[CT_THREE_TAKE_TWO] and buf[CT_FOUR_TAKE_TWO]  ) then
		local a = buf[1]
		gt.log("#buf............s",#a)
		if #a == #cbHandCard then
			return 1
		else 
			return -1
		end
	else
		return -1
	end

end

--¶Ô±ÈÆË¿Ë
function GameLaiziLogic:CompareCard(cbFirstCard,cbFirstCount,cbNextCard,cbNextCount)
    -- for i=1,cbFirstCount do
    --     print("Ç°¼ÒÆË¿Ë " .. GameLaiziLogic:GetCardLogicValue(cbFirstCard[i]))
    -- end
    -- for i=1,cbNextCount do
    --     print("ÏÂ¼ÒÆË¿Ë " .. GameLaiziLogic:GetCardLogicValue(cbNextCard[i]))
    -- end
	
    local cbNextType = GameLaiziLogic:GetCardType(cbNextCard, cbNextCount)
    local cbFirstType = GameLaiziLogic:GetCardType(cbFirstCard, cbFirstCount)
	
	cbNextCard = self:SortCardListUp(cbNextCard,cbNextCount,0)
	cbFirstCard = self:SortCardListUp(cbFirstCard,cbFirstCount,0)
    if cbNextType == GameLaiziLogic.CT_ERROR then
        return false
    end
    if cbFirstCount == 0 and cbNextType ~= GameLaiziLogic.CT_ERROR then
        return true
    end
    if cbNextType == GameLaiziLogic.CT_MISSILE_CARD then
        return true
    end
    if cbFirstType ~= GameLaiziLogic.CT_BOMB_CARD and cbNextType == GameLaiziLogic.CT_BOMB_CARD then
        return true
    end
    if cbFirstType == GameLaiziLogic.CT_BOMB_CARD and cbNextType ~= GameLaiziLogic.CT_BOMB_CARD then
        return false
    end
    if cbFirstType ~= cbNextType or cbFirstCount ~= cbNextCount then
        return false
    end
    --¿ªÊ¼¶Ô±È
    if (cbNextType == GameLaiziLogic.CT_SINGLE) or (cbNextType == GameLaiziLogic.CT_DOUBLE) or (cbNextType == GameLaiziLogic.CT_THREE) or (cbNextType == GameLaiziLogic.CT_SINGLE_LINE) or (cbNextType == GameLaiziLogic.CT_DOUBLE_LINE) or (cbNextType == GameLaiziLogic.CT_THREE_LINE)  or (cbNextType == GameLaiziLogic.CT_BOMB_CARD) then
       local cbNextLogicValue = GameLaiziLogic:GetCardLogicValue(cbNextCard[1])
       local cbFirstLogicValue = GameLaiziLogic:GetCardLogicValue(cbFirstCard[1])
       return cbNextLogicValue > cbFirstLogicValue
    elseif (cbNextType == GameLaiziLogic.CT_THREE_TAKE_ONE) or (cbNextType == GameLaiziLogic.CT_THREE_TAKE_TWO) then
        local nextResult = GameLaiziLogic:AnalysebCardData(cbNextCard, cbNextCount)
        local firstResult = GameLaiziLogic:AnalysebCardData(cbFirstCard, cbFirstCount)
        local cbNextLogicValue = GameLaiziLogic:GetCardLogicValue(nextResult[2][3][1] or nextResult[2][2][1])
        local cbFirstLogicValue = GameLaiziLogic:GetCardLogicValue(firstResult[2][3][1] or firstResult[2][2][1])
        return cbNextLogicValue > cbFirstLogicValue
    elseif (cbNextType == GameLaiziLogic.CT_FOUR_TAKE_ONE) or (cbNextType == GameLaiziLogic.CT_FOUR_TAKE_TWO) then
        local nextResult = GameLaiziLogic:AnalysebCardData(cbNextCard, cbNextCount)
        local firstResult = GameLaiziLogic:AnalysebCardData(cbFirstCard, cbFirstCount)
        local cbNextLogicValue = GameLaiziLogic:GetCardLogicValue(nextResult[2][4][1] or nextResult[2][3][1])
        local cbFirstLogicValue = GameLaiziLogic:GetCardLogicValue(firstResult[2][4][1] or firstResult[2][3][1])
        return cbNextLogicValue > cbFirstLogicValue
    end
    return false
end

--»ñÈ¡ÀàÐÍ
function GameLaiziLogic:GetCardType(cbCardData, cbCardCount,cardNum) --aaa
	gt.log(">>>>>>>>???????????????????")
    --¼òµ¥ÅÆÐÍ
    if cbCardCount == 0 then        --¿ÕÅÆ
        return GameLaiziLogic.CT_ERROR
    elseif cbCardCount == 1 then    --µ¥ÅÆ
		if cbCardData[1] == 0x43 then
			return GameLaiziLogic.CT_ERROR
		end 
        return GameLaiziLogic.CT_SINGLE
    elseif cbCardCount == 2 then    --¶ÔÅÆ»ð¼ý
        if cbCardData[2] == 0x4F and cbCardData[1] == 0x4E then
            return GameLaiziLogic.CT_MISSILE_CARD
        end
		if cbCardData[1] == 0x4F and cbCardData[2] == 0x4E then
            return GameLaiziLogic.CT_MISSILE_CARD
        end
		if GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == 18 then
			if cbCardData[2] == 0x4F or cbCardData[2] == 0x4E or GameLaiziLogic:GetCardLogicValue(cbCardData[2]) == 15 or 
				GameLaiziLogic:GetCardLogicValue(cbCardData[2]) == 3 then
				return GameLaiziLogic.CT_ERROR
			end
		end 
		if GameLaiziLogic:GetCardLogicValue(cbCardData[2]) == 18 then
			if cbCardData[1] == 0x4F or cbCardData[1] == 0x4E or GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == 15 then
				return GameLaiziLogic.CT_ERROR
			end
		end 
        if GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == GameLaiziLogic:GetCardLogicValue(cbCardData[2]) then
			if GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == 3 then
				local colorValue = yl.POKER_COLOR[cbCardData[1]] + yl.POKER_COLOR[cbCardData[2]]
				if colorValue == 32 or colorValue == 64 then
					return GameLaiziLogic.CT_BOMB_CARD
				end
			end
            return GameLaiziLogic.CT_DOUBLE
        end
		if GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == 18 or  GameLaiziLogic:GetCardLogicValue(cbCardData[2]) == 18 then
            return GameLaiziLogic.CT_DOUBLE
        end
    elseif cbCardCount == 3 then    --3ÕÅ
    	if GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == 3 then
    		return GameLaiziLogic.CT_ERROR
    	end
    	local tagAnalyseResult = {}
   		tagAnalyseResult = GameLaiziLogic:AnalysebCardData1(cbCardData, cbCardCount)
   		if tagAnalyseResult[5][1] ~= -1 then

   			if tagAnalyseResult[2][2] == -1 then
   				return GameLaiziLogic.CT_ERROR
   			else
   				if cardNum and cardNum == 3 then
   					return GameLaiziLogic.CT_THREE
   				else
   					return GameLaiziLogic.CT_ERROR
   				end
   			end

   		else

	    	if GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == GameLaiziLogic:GetCardLogicValue(cbCardData[2]) and
	    		 GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == GameLaiziLogic:GetCardLogicValue(cbCardData[3])  and
	    		cardNum and cardNum == 3 then
	    		 return GameLaiziLogic.CT_THREE
	    	else
	    		 return GameLaiziLogic.CT_ERROR
	    	end
	    	return GameLaiziLogic.CT_ERROR
	    end
    end


    local tagAnalyseResult = {}
    tagAnalyseResult = GameLaiziLogic:AnalysebCardData(cbCardData, cbCardCount)
    --ËÄÅÆÅÐ¶Ï
    if tagAnalyseResult[1][4] > 0 then
		for i,v in ipairs(tagAnalyseResult[2][4]) do
			if GameLaiziLogic:GetCardLogicValue(v) == 3 then
				return GameLaiziLogic.CT_ERROR
			end
		end 
        if tagAnalyseResult[1][4] == 1 and cbCardCount == 4 then
            return GameLaiziLogic.CT_BOMB_CARD
        end
        if tagAnalyseResult[1][4] == 1 and cbCardCount == 6 then
            return GameLaiziLogic.CT_FOUR_TAKE_ONE
        end
        if tagAnalyseResult[1][4] == 1 and cbCardCount == 8 then
            return GameLaiziLogic.CT_ERROR
        end
        return GameLaiziLogic.CT_ERROR
    end
	--ÓÐñ®×ÓµÄÈýÅÆ
	if tagAnalyseResult[1][5] > 0  then--Ä¬ÈÏÖ»ÓÐÒ»¸öñ®×ÓµÄËã·¨Âß¼­
		if tagAnalyseResult[1][3] > 0 then 
			if tagAnalyseResult[1][3] == 1 and cbCardCount == 4 then
				local cbCard = tagAnalyseResult[2][3][1]
				if GameLaiziLogic:GetCardLogicValue(cbCard) == 3 then
					return GameLaiziLogic.CT_THREE_TAKE_ONE
				end
				if GameLaiziLogic:GetCardLogicValue(cbCard) == 15 then
					return GameLaiziLogic.CT_ERROR
				end
				return GameLaiziLogic.CT_BOMB_CARD
			end
			if tagAnalyseResult[1][3] == 1 and cbCardCount == 6 then
				return GameLaiziLogic.CT_FOUR_TAKE_ONE
			end
			
			local tempCardList = {}
			for k,v in ipairs(tagAnalyseResult[2][2]) do
				if GameLaiziLogic:GetCardLogicValue(v) ~= 15  then
					table.insert(tempCardList,v)
				end 
			end
			
			for k,v in ipairs(tagAnalyseResult[2][3]) do
				if GameLaiziLogic:GetCardLogicValue(v) ~= 15 then
					table.insert(tempCardList,v)
				end 
			end
			
			local sortList = self:SortCardList(tempCardList,#tempCardList,0)
			local linkCount = 0
			local doubleCount = 0
			local threeCount = 0
			local count = 1
			local tempLink = 1
			local tempDouble = 1
			local tempThree = 1;
			for i=1,#sortList - 1 do
				local last = GameLaiziLogic:GetCardLogicValue(sortList[i])
				local pre = GameLaiziLogic:GetCardLogicValue(sortList[i+1])
				if math.abs(last- pre) == 0 then
					count = count + 1
				elseif math.abs(last- pre) == 1 then
					tempLink = tempLink + 1
					if count == 2 then
						tempDouble = tempDouble + 1
					elseif count == 3 then
						tempThree = tempThree + 1
					end
					count = 0
					if tempLink > linkCount then
						linkCount = tempLink
					end
					if tempDouble > doubleCount then
						doubleCount = tempDouble
					end
					if tempThree > threeCount then
						threeCount = tempThree
					end
				else
					if tempLink > linkCount then
						linkCount = tempLink
					end
					if tempDouble > doubleCount then
						doubleCount = tempDouble
					end
					if tempThree > threeCount then
						threeCount = tempThree
					end
					tempLink = 1
				end
			end
			
			if threeCount + doubleCount == linkCount then
				if (threeCount +1)*3 == #tagAnalyseResult[2][1] + #tagAnalyseResult[2][2] + #tagAnalyseResult[2][3]+
					#tagAnalyseResult[2][4] + #tagAnalyseResult[2][5] then
					return GameLaiziLogic.CT_ERROR
				end 
				local tempValue = (tagAnalyseResult[1][2]-1)*2 + tagAnalyseResult[1][1] +(tagAnalyseResult[1][3] -threeCount)*3
				if threeCount +1 == (tagAnalyseResult[1][2]-1)*2 + tagAnalyseResult[1][1] +
					(tagAnalyseResult[1][3] -threeCount)*3 then
					return GameLaiziLogic.CT_THREE_TAKE_ONE
				end
			end
						
			return GameLaiziLogic.CT_ERROR
		end
	end 
    --ÈýÅÆÅÐ¶Ï
    if tagAnalyseResult[1][3] > 0 then
        if tagAnalyseResult[1][3] > 1 then
            local cbCard = tagAnalyseResult[2][3][1]
            local cbFirstLogicValue = GameLaiziLogic:GetCardLogicValue(cbCard)
            if cbFirstLogicValue >= 15 then
                return GameLaiziLogic.CT_ERROR
            end
            for i=2,tagAnalyseResult[1][3] do
                local cbCard = tagAnalyseResult[2][3][(i-1)*3+1]
                local cbNextLogicValue = GameLaiziLogic:GetCardLogicValue(cbCard)
                if cbFirstLogicValue ~= cbNextLogicValue+i-1 then
                    return GameLaiziLogic.CT_ERROR
                end
            end
        elseif cbCardCount == 3 then
            return GameLaiziLogic.CT_THREE
        end
        if tagAnalyseResult[1][3]*3 == cbCardCount then
           return GameLaiziLogic.CT_THREE_LINE
        end
        if tagAnalyseResult[1][3]*4 == cbCardCount then
           return GameLaiziLogic.CT_THREE_TAKE_ONE
        end
        if tagAnalyseResult[1][3]*5 == cbCardCount  and tagAnalyseResult[1][2] == tagAnalyseResult[1][3] then
           return GameLaiziLogic.CT_ERROR
        end
        return GameLaiziLogic.CT_ERROR
    end
	
	--Á½ÕÅñ®×ÓËã·¨
	if tagAnalyseResult[1][5] > 0  then--Ä¬ÈÏÖ»ÓÐÒ»¸öñ®×ÓµÄËã·¨Âß¼­
		if tagAnalyseResult[1][2] > 0 then
			if tagAnalyseResult[1][2] == 1 and cbCardCount == 3 then
				return GameLaiziLogic.CT_THREE
			end
			if tagAnalyseResult[1][2] == 1 and cbCardCount == 4 then
				return GameLaiziLogic.CT_THREE_TAKE_ONE
			end
			
			if tagAnalyseResult[1][2] >= 2 then
				local tempCardList = {}
				for k,v in ipairs(tagAnalyseResult[2][2]) do
					if GameLaiziLogic:GetCardLogicValue(v) ~= 15  then
						table.insert(tempCardList,v)
					end 
				end
				
				for k,v in ipairs(tagAnalyseResult[2][1]) do
					if GameLaiziLogic:GetCardLogicValue(v) ~= 15 then
						table.insert(tempCardList,v)
					end 
				end
				
				local sortList = self:SortCardList(tempCardList,#tempCardList,0)
				local linkCount = 0
				local doubleCount = 0
				local oneCount = 0
				local count = 0
				local tempLink = 1
				local tempDouble = 1
				local tempOne = 0;
				for i=1,#sortList - 1 do
					local last = GameLaiziLogic:GetCardLogicValue(sortList[i])
					local pre = GameLaiziLogic:GetCardLogicValue(sortList[i+1])
					if math.abs(last- pre) == 0 then
						count = count + 1
					elseif math.abs(last- pre) == 1 then
						tempLink = tempLink + 1
						if tempLink > linkCount then
							linkCount = tempLink
						end
					end
				end
				
				if cbCardCount == linkCount*2 then
					if #sortList +1 == cbCardCount then
						return GameLaiziLogic.CT_DOUBLE_LINE
					end 
				end
			end
		end 
	end 
	
    --Á½ÕÅÅÐ¶Ï
    if tagAnalyseResult[1][2] >= 3 then
        local cbCard = tagAnalyseResult[2][2][1]
        local cbFirstLogicValue = GameLaiziLogic:GetCardLogicValue(cbCard)
        if cbFirstLogicValue >= 15 then
            return GameLaiziLogic.CT_ERROR
        end
        for i=2,tagAnalyseResult[1][2] do
            local cbCard = tagAnalyseResult[2][2][(i-1)*2+1]
            local cbNextLogicValue = GameLaiziLogic:GetCardLogicValue(cbCard)
            if cbFirstLogicValue ~= cbNextLogicValue+i-1 then
                return GameLaiziLogic.CT_ERROR
            end
        end
        if tagAnalyseResult[1][2]*2 == cbCardCount then
            return GameLaiziLogic.CT_DOUBLE_LINE
        end
        return GameLaiziLogic.CT_ERROR
    end
    --µ¥ÕÅÅÐ¶Ï
    if tagAnalyseResult[1][1] >= 5 and tagAnalyseResult[1][1] == cbCardCount then
        local cbCard = tagAnalyseResult[2][1][1]
        local cbFirstLogicValue = GameLaiziLogic:GetCardLogicValue(cbCard)
        if cbFirstLogicValue >= 15 then
            return GameLaiziLogic.CT_ERROR
        end
        for i=2,tagAnalyseResult[1][1] do
            local cbCard = tagAnalyseResult[2][1][i]
            local cbNextLogicValue = GameLaiziLogic:GetCardLogicValue(cbCard)
            if cbFirstLogicValue ~= cbNextLogicValue+i-1 then
                return GameLaiziLogic.CT_ERROR
            end
        end
        return GameLaiziLogic.CT_SINGLE_LINE
    end
	
	--ñ®×Óµ¥ÅÆ
	local tempCount = 0
	if tagAnalyseResult[1][5] > 0  then--Ä¬ÈÏÖ»ÓÐÒ»¸öñ®×ÓµÄËã·¨Âß¼­
		if tagAnalyseResult[1][1] >= 4 and  tagAnalyseResult[1][1] +1 == cbCardCount then
			local cbCard = tagAnalyseResult[2][1][1]
			local cbFirstLogicValue = GameLaiziLogic:GetCardLogicValue(cbCard)
			if cbFirstLogicValue >= 15 then
				return GameLaiziLogic.CT_ERROR
			end
			for i=2,tagAnalyseResult[1][1] do
				local cbCard = tagAnalyseResult[2][1][i]
				local cbNextLogicValue = GameLaiziLogic:GetCardLogicValue(cbCard)
				if cbFirstLogicValue ~= cbNextLogicValue+i-1 + tempCount then
					if cbFirstLogicValue == cbNextLogicValue+i  and tempCount < 1 then
						tempCount = tempCount +1
					else
						return GameLaiziLogic.CT_ERROR
					end 
				end
			end
			return GameLaiziLogic.CT_SINGLE_LINE
		end
	end 

	if cbCardCount == 6 then
		if GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == 3 then
    		return GameLaiziLogic.CT_ERROR
    	end
    	local tagAnalyseResult = {}
   		tagAnalyseResult = GameLaiziLogic:AnalysebCardData1(cbCardData, cbCardCount)
   		if tagAnalyseResult[5][1] ~= -1 then
   			if tagAnalyseResult[3][3] == -1 or  tagAnalyseResult[2][2] == -1 then
   				return GameLaiziLogic.CT_ERROR
   			else
   				if cardNum and cardNum == 6 then
   					return GameLaiziLogic.CT_THREE_LINE
   				else
   					return GameLaiziLogic.CT_ERROR
   				end
   			end
   		else
    		if GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == GameLaiziLogic:GetCardLogicValue(cbCardData[2]) and
    		 GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == GameLaiziLogic:GetCardLogicValue(cbCardData[3])  and
    		 GameLaiziLogic:GetCardLogicValue(cbCardData[4]) == GameLaiziLogic:GetCardLogicValue(cbCardData[5])  and 
    		  GameLaiziLogic:GetCardLogicValue(cbCardData[4]) == GameLaiziLogic:GetCardLogicValue(cbCardData[6]) and 
    		  math.abs(GameLaiziLogic:GetCardLogicValue(cbCardData[1]) -GameLaiziLogic:GetCardLogicValue(cbCardData[4])) == 1 and
    		cardNum and cardNum == 6 then
    		 return GameLaiziLogic.CT_THREE_LINE
    		else
    			return GameLaiziLogic.CT_ERROR
    		end

    	end
    elseif cbCardCount == 9 then
    	if GameLaiziLogic:GetCardLogicValue(cbCardData[1]) == 3 then
    		return GameLaiziLogic.CT_ERROR
    	end
    	local tagAnalyseResult = {}
   		tagAnalyseResult = GameLaiziLogic:AnalysebCardData1(cbCardData, cbCardCount)
   		if tagAnalyseResult[5][1] ~= -1 then
   			if tagAnalyseResult[3][6] == -1 or  tagAnalyseResult[2][2] == -1 then
   				return GameLaiziLogic.CT_ERROR
   			else
   				local buf = {GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[3][6]) , GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[3][3]),GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][2])}
   				local cards = GameLaiziLogic:paixun(buf)
   				if cards[1] + 1 == cards[2] and cards[1] + 2 == cards[3] then
	   				if cardNum and cardNum == 9 then
	   					return GameLaiziLogic.CT_THREE_LINE
	   				else
	   					return GameLaiziLogic.CT_ERROR
	   				end
   				else
   					return GameLaiziLogic.CT_ERROR
   				end
   			end
   		else
   			if tagAnalyseResult[3][9] == -1 then 
   				return GameLaiziLogic.CT_THREE_LINE
   			else
   			    if GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[3][9]) -1 ==GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[3][6]) and
   			    	GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[3][9]) -2 == GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[3][3]) then

   			    	if cardNum and cardNum == 9 then
   			    		return GameLaiziLogic.CT_THREE_LINE
   			    	else
   			    		return GameLaiziLogic.CT_ERROR
   			    	end
   			    else
   			    	return GameLaiziLogic.CT_ERROR
   			    end
   			end
   		end
    elseif cbCardCount == 12 then

    elseif cbCardCount == 15 then

    end
    return GameLaiziLogic.CT_ERROR
end

function GameLaiziLogic:paixun(buf)
	-- body
	for i = 1 ,i<#buf do
		for j  =i+1 ,j<#buf do
			if buf[i]>buf[j] then
				local t = buf[i]
				buf[i] = buf[j]
				buf[j] = t
			end
		end
	end
	return buf
end

--³öÅÆËÑË÷
function GameLaiziLogic:SearchOutCard(cbHandCardData,cbHandCardCount,cbTurnCardData,cbTurnCardCount) 
    -- print("³öÅÆËÑË÷")
    -- for i=1,cbTurnCardCount do
    --     print("Ç°¼ÒÆË¿Ë " .. GameLaiziLogic:GetCardLogicValue(cbTurnCardData[i]))
    -- end
    -- for i=1,cbHandCardCount do
    --     print("ÏÂ¼ÒÆË¿Ë " .. GameLaiziLogic:GetCardLogicValue(cbHandCardData[i]))
    -- end
	cbTurnCardData = self:SortCardListUp(cbTurnCardData,#cbTurnCardData)
	
    --½á¹ûÊýÄ¿
    local cbResultCount = 1
    --ÆË¿ËÊýÄ¿
    local cbResultCardCount = {}
    --½á¹ûÆË¿Ë
    local cbResultCard = {}
    --ËÑË÷½á¹û
    local tagSearchCardResult = {cbResultCount-1,cbResultCardCount,cbResultCard}
    --排序
    local cbCardData = GameLaiziLogic:SortCardList(cbHandCardData, cbHandCardCount, 0)
    local cbCardCount = cbHandCardCount
    --³öÅÆ·ÖÎö
    local cbTurnOutType = GameLaiziLogic:GetCardType(cbTurnCardData, cbTurnCardCount) -- 分析 上轮 牌型
    if cbTurnOutType == GameLaiziLogic.CT_ERROR then --´牌型错误
        --print("ÉÏ¼ÒÎª¿Õ")
        --ÊÇ·ñÒ»ÊÖ³öÍê
        if GameLaiziLogic:GetCardType(cbCardData, cbCardCount) ~= GameLaiziLogic.CT_ERROR  then
            cbResultCardCount[cbResultCount] = cbCardCount
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount] = cbCardData
            cbResultCount = cbResultCount+1
            tagSearchCardResult[2] = cbResultCardCount
            tagSearchCardResult[3] = cbResultCard
        end
        --Èç¹û×îÐ¡ÅÆ²»ÊÇµ¥ÅÆ£¬ÔòÌáÈ¡
        local cbSameCount = 1
        if cbCardCount > 1 and (GameLaiziLogic:GetCardLogicValue(cbCardData[cbCardCount]) == GameLaiziLogic:GetCardLogicValue(cbCardData[cbCardCount-1])) then
            cbSameCount = 2
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount][1] = cbCardData[cbCardCount]
            local cbCardValue = GameLaiziLogic:GetCardLogicValue(cbCardData[cbCardCount])
            local i = cbCardCount - 1
            while i >= 1 do
                if GameLaiziLogic:GetCardLogicValue(cbCardData[i]) == cbCardValue then
                    cbResultCard[cbResultCount][cbSameCount] = cbCardData[i]
                    cbSameCount = cbSameCount + 1
                end
                i = i - 1
            end
            cbResultCardCount[cbResultCount] = cbSameCount-1
            cbResultCount = cbResultCount + 1
            tagSearchCardResult[2] = cbResultCardCount
            tagSearchCardResult[3] = cbResultCard
        end
        --µ¥ÅÆ
        local cbTmpCount = 1
        if cbSameCount ~= 2 then
            --print("µ¥ÅÆPan")
            local tagSearchCardResult1 = GameLaiziLogic:SearchSameCard(cbCardData, cbCardCount, 0, 1)
            cbTmpCount = tagSearchCardResult1[1]
            if cbTmpCount > 0 then
                cbResultCardCount[cbResultCount] = tagSearchCardResult1[2][1]
                cbResultCard[cbResultCount] = {}
                cbResultCard[cbResultCount] = tagSearchCardResult1[3][1]
                cbResultCount = cbResultCount + 1
                tagSearchCardResult[2] = cbResultCardCount
                tagSearchCardResult[3] = cbResultCard
            end
        end
        --¶ÔÅÆ
        if cbSameCount ~= 3 then
            local tagSearchCardResult1 = GameLaiziLogic:SearchSameCard(cbCardData, cbCardCount, 0, 2)
            cbTmpCount = tagSearchCardResult1[1]
            if cbTmpCount > 0 then
                cbResultCardCount[cbResultCount] = tagSearchCardResult1[2][1]
                cbResultCard[cbResultCount] = {}
                cbResultCard[cbResultCount] = tagSearchCardResult1[3][1]
                cbResultCount = cbResultCount + 1
                tagSearchCardResult[2] = cbResultCardCount
                tagSearchCardResult[3] = cbResultCard
            end
        end
        --ÈýÌõ
        if cbSameCount ~= 4 then
            local tagSearchCardResult1 = GameLaiziLogic:SearchSameCard(cbCardData, cbCardCount, 0, 3)
            cbTmpCount = tagSearchCardResult1[1]
            if cbTmpCount > 0 then
                cbResultCardCount[cbResultCount] = tagSearchCardResult1[2][1]
                cbResultCard[cbResultCount] = {}
                cbResultCard[cbResultCount] = tagSearchCardResult1[3][1]
                cbResultCount = cbResultCount + 1
                tagSearchCardResult[2] = cbResultCardCount
                tagSearchCardResult[3] = cbResultCard
            end
        end
        --Èý´øÒ»µ¥
        --print("Èý´øÒ»µ¥")
        local tagSearchCardResult2 = GameLaiziLogic:SearchTakeCardType(cbCardData, cbCardCount, 0, 3, 1)
        cbTmpCount = tagSearchCardResult2[1]
        if cbTmpCount > 0 then
            cbResultCardCount[cbResultCount] = tagSearchCardResult2[2][1]
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount] = tagSearchCardResult2[3][1]
            cbResultCount = cbResultCount + 1
            tagSearchCardResult[2] = cbResultCardCount
            tagSearchCardResult[3] = cbResultCard
        end
        --print("Èý´øÒ»¶Ô")
        --Èý´øÒ»¶Ô
        local tagSearchCardResult3 = GameLaiziLogic:SearchTakeCardType(cbCardData, cbCardCount, 0, 3, 2)
        cbTmpCount = tagSearchCardResult3[1]
        if cbTmpCount > 0 then
            cbResultCardCount[cbResultCount] = tagSearchCardResult3[2][1]
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount] = tagSearchCardResult3[3][1]
            cbResultCount = cbResultCount + 1
            tagSearchCardResult[2] = cbResultCardCount
            tagSearchCardResult[3] = cbResultCard
        end
        --µ¥Á¬
        --print("µ¥Á¬")
        local tagSearchCardResult4 = GameLaiziLogic:SearchLineCardType(cbCardData, cbCardCount, 0, 1, 0)
        cbTmpCount = tagSearchCardResult4[1]
        if cbTmpCount > 0 then
            cbResultCardCount[cbResultCount] = tagSearchCardResult4[2][1]
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount] = tagSearchCardResult4[3][1]
            cbResultCount = cbResultCount + 1
            tagSearchCardResult[2] = cbResultCardCount
            tagSearchCardResult[3] = cbResultCard
        end
        --Á¬¶Ô
        --print("Á¬¶Ô")
        local tagSearchCardResult5 = GameLaiziLogic:SearchLineCardType(cbCardData, cbCardCount, 0, 2, 0)
        cbTmpCount = tagSearchCardResult5[1]
        if cbTmpCount > 0 then
            cbResultCardCount[cbResultCount] = tagSearchCardResult5[2][1]
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount] = tagSearchCardResult5[3][1]
            cbResultCount = cbResultCount + 1
            tagSearchCardResult[2] = cbResultCardCount
            tagSearchCardResult[3] = cbResultCard
        end
        --ÈýÁ¬
        --print("ÈýÁ¬")
        local tagSearchCardResult6 = GameLaiziLogic:SearchLineCardType(cbCardData, cbCardCount, 0, 3, 0)
        cbTmpCount = tagSearchCardResult6[1]
        if cbTmpCount > 0 then
            cbResultCardCount[cbResultCount] = tagSearchCardResult6[2][1]
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount] = tagSearchCardResult6[3][1]
            cbResultCount = cbResultCount + 1
            tagSearchCardResult[2] = cbResultCardCount
            tagSearchCardResult[3] = cbResultCard
        end
        --·É»ú
        --print("·É»ú")
        local tagSearchCardResult7 = GameLaiziLogic:SearchThreeTwoLine(cbCardData, cbCardCount)
        cbTmpCount = tagSearchCardResult7[1]
        if cbTmpCount > 0 then
            cbResultCardCount[cbResultCount] = tagSearchCardResult7[2][1]
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount] = tagSearchCardResult7[3][1]
            cbResultCount = cbResultCount + 1
            tagSearchCardResult[2] = cbResultCardCount
            tagSearchCardResult[3] = cbResultCard
        end
        --Õ¨µ¯
        if cbSameCount ~= 5 then
            --print("Õ¨µ¯")
            local tagSearchCardResult1 = GameLaiziLogic:SearchSameCard(cbCardData, cbCardCount, 0, 4)
            cbTmpCount = tagSearchCardResult1[1]
            if cbTmpCount > 0 then
                cbResultCardCount[cbResultCount] = tagSearchCardResult1[2][1]
                cbResultCard[cbResultCount] = {}
                cbResultCard[cbResultCount] = tagSearchCardResult1[3][1]
                cbResultCount = cbResultCount + 1
                tagSearchCardResult[2] = cbResultCardCount
                tagSearchCardResult[3] = cbResultCard
            end
        end
        --»ð¼ý
        --print("ËÑË÷»ð¼ý")
        if (cbCardCount >= 2) and (cbCardData[1]==0x4F and cbCardData[2]==0x4E) then
            cbResultCardCount[cbResultCount] = 2
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount] = {cbCardData[1],cbCardData[2]}
            cbResultCount = cbResultCount + 1
            tagSearchCardResult[2] = cbResultCardCount
            tagSearchCardResult[3] = cbResultCard
        end
        tagSearchCardResult[1] = cbResultCount - 1
        return tagSearchCardResult
    elseif cbTurnOutType == GameLaiziLogic.CT_SINGLE or cbTurnOutType == GameLaiziLogic.CT_DOUBLE or cbTurnOutType == GameLaiziLogic.CT_THREE then
        --单牌、对牌、三条
        local cbReferCard = cbTurnCardData[1]
        local cbSameCount = 1
        if cbTurnOutType == GameLaiziLogic.CT_DOUBLE then
            cbSameCount = 2
        elseif cbTurnOutType == GameLaiziLogic.CT_THREE then
            cbSameCount = 3
        end
        local tagSearchCardResult21 = GameLaiziLogic:SearchSameCard(cbCardData, cbCardCount, cbReferCard, cbSameCount)
        cbResultCount = tagSearchCardResult21[1]
        cbResultCount = cbResultCount + 1 
        cbResultCardCount = tagSearchCardResult21[2]
        tagSearchCardResult[2] = cbResultCardCount
        cbResultCard = tagSearchCardResult21[3]
        tagSearchCardResult[3] = cbResultCard
        tagSearchCardResult[1] = cbResultCount - 1 
		

    elseif cbTurnOutType == GameLaiziLogic.CT_SINGLE_LINE or cbTurnOutType == GameLaiziLogic.CT_DOUBLE_LINE or cbTurnOutType == GameLaiziLogic.CT_THREE_LINE then
        --µ¥Á¬¡¢¶ÔÁ¬¡¢ÈýÁ¬
        local cbBlockCount = 1
        if cbTurnOutType == GameLaiziLogic.CT_DOUBLE_LINE then
            cbBlockCount = 2
        elseif cbTurnOutType == GameLaiziLogic.CT_THREE_LINE then
            cbBlockCount = 3
        end
        local cbLineCount = cbTurnCardCount/cbBlockCount
        local tagSearchCardResult31 = GameLaiziLogic:SearchLineCardType(cbCardData, cbCardCount, cbTurnCardData[1], cbBlockCount, cbLineCount)
        cbResultCount = tagSearchCardResult31[1]
        cbResultCount = cbResultCount + 1
        cbResultCardCount = tagSearchCardResult31[2]
        tagSearchCardResult[2] = cbResultCardCount
        cbResultCard = tagSearchCardResult31[3]
        tagSearchCardResult[3] = cbResultCard
        tagSearchCardResult[1] = cbResultCount - 1

    elseif cbTurnOutType == GameLaiziLogic.CT_THREE_TAKE_ONE or cbTurnOutType == GameLaiziLogic.CT_THREE_TAKE_TWO then
        --Èý´øÒ»µ¥¡¢Èý´øÒ»¶Ô
        if cbCardCount >= cbTurnCardCount then
            if cbTurnCardCount == 4 or cbTurnCardCount == 5 then
                local cbTakeCardCount = (cbTurnOutType == GameLaiziLogic.CT_THREE_TAKE_ONE) and 1 or 2
                local tagSearchCardResult41 = GameLaiziLogic:SearchTakeCardType(cbCardData, cbCardCount, cbTurnCardData[3], 3, cbTakeCardCount)
                cbResultCount = tagSearchCardResult41[1]
                cbResultCount = cbResultCount + 1
                cbResultCardCount = tagSearchCardResult41[2]
                tagSearchCardResult[2] = cbResultCardCount
                cbResultCard = tagSearchCardResult41[3]
                tagSearchCardResult[3] = cbResultCard
                tagSearchCardResult[1] = cbResultCount - 1
            else
                local cbBlockCount = 3
                local cbLineCount = cbTurnCardCount/(cbTurnOutType==GameLaiziLogic.CT_THREE_TAKE_ONE and 4 or 5)
                local cbTakeCardCount = cbTurnOutType==GameLaiziLogic.CT_THREE_TAKE_ONE and 1 or 2

                --ËÑË÷Á¬ÅÆ
                local cbTmpTurnCard = cbTurnCardData
                cbTmpTurnCard = GameLaiziLogic:SortOutCardList(cbTmpTurnCard,cbTurnCardCount)
                local tmpSearchResult = GameLaiziLogic:SearchLineCardType(cbCardData,cbCardCount,cbTmpTurnCard[1],cbBlockCount,cbLineCount)
                cbResultCount2 = tmpSearchResult[1]
                --ÌáÈ¡´øÅÆ
                local bAllDistill = true
                for i=1,cbResultCount2 do
                    local cbResultIndex = cbResultCount2-i+1
                    local cbTmpCardData = {}
                    for i=1,#cbCardData do
                        cbTmpCardData[i] = cbCardData[i]
                    end
                    local cbTmpCardCount = cbCardCount

                    --É¾³ýÁ¬ÅÆ
                    local removeResult = GameLaiziLogic:RemoveCard(tmpSearchResult[3][cbResultIndex],tmpSearchResult[2][cbResultIndex],cbTmpCardData,cbTmpCardCount)
                    cbTmpCardData = removeResult[2]
                    cbTmpCardCount = cbTmpCardCount - tmpSearchResult[2][cbResultIndex]
                    --·ÖÎöÅÆ
                    local TmpResult = GameLaiziLogic:AnalysebCardData(cbTmpCardData,cbTmpCardCount)
                    --ÌáÈ¡ÅÆ
                    local cbDistillCard = {}
                    local cbDistillCount = 0
                    local j = cbTakeCardCount
                    while j <= 4 do
                        if TmpResult[1][j] > 0 then
                            if j == cbTakeCardCount and TmpResult[1][j] >= cbLineCount then
                                local cbTmpBlockCount = TmpResult[1][j]
                                for k=1,j*cbLineCount do
                                    cbDistillCard[k] = TmpResult[2][j][(cbTmpBlockCount-cbLineCount)*j+k]
                                end
                                cbDistillCount = j*cbLineCount
                                break
                            else
                                local k = 1
                                while k <= TmpResult[1][j] do
                                    local cbTmpBlockCount = TmpResult[1][j]
                                    for l=1,cbTakeCardCount do
                                        cbDistillCard[cbDistillCount+l] = TmpResult[2][j][(cbTmpBlockCount-k)*j+l]
                                    end
                                    cbDistillCount = cbDistillCount + cbTakeCardCount
                                    --ÌáÈ¡Íê³É
                                    if (cbDistillCount == cbTakeCardCount*cbLineCount) then
                                        break
                                    end
                                    k = k + 1
                                end
                            end
                        end
                        --ÌáÈ¡Íê³É
                        if (cbDistillCount == cbTakeCardCount*cbLineCount) then
                            break
                        end
                        j = j + 1
                    end
                    --ÌáÈ¡Íê³É
                    if (cbDistillCount == cbTakeCardCount*cbLineCount) then
                        --¸´ÖÆ´øÅÆ
                        local cbCount = tmpSearchResult[2][cbResultIndex]
                        for n=1,cbDistillCount do
                            tmpSearchResult[3][cbResultIndex][cbCount+n] = cbDistillCard[n]
                        end
                        tmpSearchResult[2][cbResultIndex] = tmpSearchResult[2][cbResultIndex] + cbDistillCount
                    else
                        --·ñÔòÉ¾³ýÁ¬ÅÆ
                        bAllDistill = false
                        tmpSearchResult[2][cbResultIndex] = 0
                    end
                end
                --ÕûÀí×éºÏ
                tmpSearchResult[1] = cbResultCount2
                for i=1,tmpSearchResult[1] do
                    if tmpSearchResult[2][i] ~= 0 then
                        tagSearchCardResult[2][cbResultCount] = tmpSearchResult[2][i]
                        tagSearchCardResult[3][cbResultCount] = tmpSearchResult[3][i]
                        cbResultCount = cbResultCount + 1
                    end
                end
                tagSearchCardResult[1] = cbResultCount - 1
            end
        end

    elseif cbTurnOutType == GameLaiziLogic.CT_FOUR_TAKE_ONE or cbTurnOutType == GameLaiziLogic.CT_FOUR_TAKE_TWO then
        --ËÄ´øÁ½µ¥¡¢ËÄ´øÁ½Ë«
        local cbTakeCardCount = (cbTurnOutType == GameLaiziLogic.CT_FOUR_TAKE_ONE) and 1 or 2
        local cbTmpTurnCard = GameLaiziLogic:SortOutCardList(cbTurnCardData,cbTurnCardCount)
        local tagSearchCardResult51 = GameLaiziLogic:SearchTakeCardType(cbCardData, cbCardCount, cbTmpTurnCard[1], 4, cbTakeCardCount)
        cbResultCount = tagSearchCardResult51[1]
        cbResultCount = cbResultCount + 1
        cbResultCardCount = tagSearchCardResult51[2]
        tagSearchCardResult[2] = cbResultCardCount
        cbResultCard = tagSearchCardResult51[3]
        tagSearchCardResult[3] = cbResultCard
        tagSearchCardResult[1] = cbResultCount - 1
    end

    --ËÑË÷Õ¨µ¯
    if (cbCardCount >= 4 and cbTurnOutType ~= GameLaiziLogic.CT_MISSILE_CARD) then
        local cbReferCard = 0
        if cbTurnOutType == GameLaiziLogic.CT_BOMB_CARD then
            cbReferCard = cbTurnCardData[1]
        end
        --ËÑË÷Õ¨µ¯
        local tagSearchCardResult61 = GameLaiziLogic:SearchSameCard(cbCardData,cbCardCount,cbReferCard,4)
        local cbTmpResultCount = tagSearchCardResult61[1]
        for i=1,cbTmpResultCount do
            cbResultCardCount[cbResultCount] = tagSearchCardResult61[2][i]
            tagSearchCardResult[2] = cbResultCardCount
            cbResultCard[cbResultCount] = tagSearchCardResult61[3][i]
            tagSearchCardResult[3] = cbResultCard
            cbResultCount = cbResultCount + 1
        end
        tagSearchCardResult[1] = cbResultCount - 1
    end

    --ËÑË÷»ð¼ý
    if (cbTurnOutType ~= GameLaiziLogic.CT_MISSILE_CARD) and (cbCardCount >= 2) and (cbCardData[1]==0x4F and cbCardData[2]==0x4E) then
        cbResultCardCount[cbResultCount] = 2
        cbResultCard[cbResultCount] = {cbCardData[1],cbCardData[2]}
        cbResultCount = cbResultCount + 1
        tagSearchCardResult[2] = cbResultCardCount
        tagSearchCardResult[3] = cbResultCard
        tagSearchCardResult[1] = cbResultCount - 1
    end

    return tagSearchCardResult
end

--Í¬ÅÆËÑË÷
function GameLaiziLogic:SearchSameCard(cbHandCardData, cbHandCardCount, cbReferCard, cbSameCardCount)
    --½á¹ûÊýÄ¿
    local cbResultCount = 1
    --ÆË¿ËÊýÄ¿
    local cbResultCardCount = {}
    --½á¹ûÆË¿Ë
    local cbResultCard = {}
	--ñ®×ÓÅÆ
	local cbLaiziCard = {}
    --ËÑË÷½á¹û
    local tagSearchCardResult = {cbResultCount-1,cbResultCardCount,cbResultCard}
    --ÅÅÐòÆË¿Ë
    local cbCardData = GameLaiziLogic:SortCardList(cbHandCardData, cbHandCardCount, 0)
    local cbCardCount = cbHandCardCount
    --·ÖÎö½á¹¹
    local tagAnalyseResult = GameLaiziLogic:AnalysebCardData(cbCardData, cbCardCount)
    --dump(tagAnalyseResult, "tagAnalyseResult", 6)
    local cbReferLogicValue = (cbReferCard == 0 and 0 or GameLaiziLogic:GetCardLogicValue(cbReferCard))
    local cbBlockIndex = cbSameCardCount
    while cbBlockIndex <= 4 do
        for i=1,tagAnalyseResult[1][cbBlockIndex] do
            local cbIndex = (tagAnalyseResult[1][cbBlockIndex]-i)*cbBlockIndex+1
            local cbNowLogicValue = GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][cbBlockIndex][cbIndex])
            if cbNowLogicValue > cbReferLogicValue then
                cbResultCardCount[cbResultCount] = cbSameCardCount
                tagSearchCardResult[2] = cbResultCardCount
                cbResultCard[cbResultCount] = {}
                cbResultCard[cbResultCount][1] = tagAnalyseResult[2][cbBlockIndex][cbIndex]
                for i=2,cbBlockIndex do
                    cbResultCard[cbResultCount][i] = tagAnalyseResult[2][cbBlockIndex][cbIndex+i-1]
                end --´Ë´¦ÐÞ¸Ä
                tagSearchCardResult[3] = cbResultCard
                cbResultCount = cbResultCount + 1
            end
        end
        cbBlockIndex = cbBlockIndex + 1
    end
    tagSearchCardResult[1] = cbResultCount - 1
    return tagSearchCardResult
end

--´øÅÆÀàÐÍËÑË÷(Èý´øÒ»£¬ËÄ´øÒ»µÈ)
function GameLaiziLogic:SearchTakeCardType(cbHandCardData, cbHandCardCount, cbReferCard, cbSameCount, cbTakeCardCount)
    --½á¹ûÊýÄ¿
    local cbResultCount = 1
    --ÆË¿ËÊýÄ¿
    local cbResultCardCount = {}
    --½á¹ûÆË¿Ë
    local cbResultCard = {}
    --ËÑË÷½á¹û
    local tagSearchCardResult = {cbResultCount-1,cbResultCardCount,cbResultCard}
    if cbSameCount ~= 3 and cbSameCount ~= 4 then
        return tagSearchCardResult
    end
    if cbTakeCardCount ~= 1 and cbTakeCardCount ~= 2 then
        return tagSearchCardResult
    end
    if (cbSameCount == 4) and (cbHandCardCount < cbSameCount+cbTakeCardCount*2 or cbHandCardCount < cbSameCount+cbTakeCardCount) then
        return tagSearchCardResult
    end
    --ÅÅÐòÆË¿Ë
    local cbCardData = GameLaiziLogic:SortCardList(cbHandCardData, cbHandCardCount, 0)
    local cbCardCount = cbHandCardCount
    
    local sameCardResult = {}
    sameCardResult = GameLaiziLogic:SearchSameCard(cbCardData, cbCardCount, cbReferCard, cbSameCount)
    local cbSameCardResultCount = sameCardResult[1]

    if cbSameCardResultCount > 0 then
        --·ÖÎö½á¹¹
        local tagAnalyseResult = GameLaiziLogic:AnalysebCardData(cbCardData, cbCardCount)
        --ÐèÒªÅÆÊý
        local cbNeedCount = cbSameCount + cbTakeCardCount
        if cbSameCount == 4 then
            cbNeedCount = cbNeedCount + cbTakeCardCount
        end
        --ÌáÈ¡´øÅÆ
        for i=1,cbSameCardResultCount do
            local bMere = false
            local j = cbTakeCardCount
            while j <= 4 do
                local k = 1
                while k <= tagAnalyseResult[1][j]  do
                    --´ÓÐ¡µ½´ó
                    local cbIndex = (tagAnalyseResult[1][j]-k)*j+1
                    if GameLaiziLogic:GetCardLogicValue(sameCardResult[3][i][1]) ~= GameLaiziLogic:GetCardLogicValue(tagAnalyseResult[2][j][cbIndex]) then
                        --¸´ÖÆ´øÅÆ
                        local cbCount = sameCardResult[2][i]
                        for l=1,cbTakeCardCount do
                            sameCardResult[3][i][cbCount+l] = tagAnalyseResult[2][j][cbIndex+l-1]
                        end
                        sameCardResult[2][i] = sameCardResult[2][i] + cbTakeCardCount
                        if sameCardResult[2][i] >= cbNeedCount then
                            --¸´ÖÆ½á¹û
                            cbResultCardCount[cbResultCount] = sameCardResult[2][i]
                            tagSearchCardResult[2] = cbResultCardCount
                            cbResultCard[cbResultCount] = {}
                            cbResultCard[cbResultCount] = sameCardResult[3][i]
                            tagSearchCardResult[3] = cbResultCard
                            cbResultCount = cbResultCount + 1
                            tagSearchCardResult[1] = cbResultCount - 1
                            bMere = true
                            --ÏÂÒ»×éºÏ
                            break
                        end
                    end
                    k = k+1
                end
                if bMere == true then
                    break
                end
                j = j + 1
            end
        end
    end
    tagSearchCardResult[1] = cbResultCount - 1
    return tagSearchCardResult
end

--Á¬ÅÆËÑË÷
function GameLaiziLogic:SearchLineCardType(cbHandCardData, cbHandCardCount, cbReferCard, cbBlockCount, cbLineCount)
    --½á¹ûÊýÄ¿
    local cbResultCount = 1
    --ÆË¿ËÊýÄ¿
    local cbResultCardCount = {}
    --½á¹ûÆË¿Ë
    local cbResultCard = {}
    --ËÑË÷½á¹û
    local tagSearchCardResult = {cbResultCount-1,cbResultCardCount,cbResultCard}
    --ÅÅÐòÆË¿Ë
    local cbCardData = GameLaiziLogic:SortCardList(cbHandCardData, cbHandCardCount, 0)
    local cbCardCount = cbHandCardCount
    --Á¬ÅÆ×îÉÙÊý
    local cbLessLineCount = 0
    if cbLineCount == 0 then
        if cbBlockCount == 1 then
            cbLessLineCount = 5
        elseif cbBlockCount == 2 then
            cbLessLineCount = 3
        else
            cbLessLineCount = 2
        end
    else
        cbLessLineCount = cbLineCount
    end
    --print("Á¬ÅÆ×îÉÙÊý " .. cbLessLineCount)
    local cbReferIndex = 3
    if cbReferCard ~= 0 then
        if (GameLaiziLogic:GetCardLogicValue(cbReferCard)-cbLessLineCount) >= 2 then
            cbReferIndex = GameLaiziLogic:GetCardLogicValue(cbReferCard)-cbLessLineCount+1+1
        end
    end 
    --³¬¹ýA
    if cbReferIndex+cbLessLineCount > 15 then
        return tagSearchCardResult
    end
    --³¤¶ÈÅÐ¶Ï
    if cbHandCardCount < cbLessLineCount*cbBlockCount then
        return tagSearchCardResult
    end
   -- print("ËÑË÷Ë³×Ó¿ªÊ¼µã " .. cbReferIndex)
    local Distributing = GameLaiziLogic:AnalysebDistributing(cbCardData, cbCardCount)
    --ËÑË÷Ë³×Ó
    local cbTmpLinkCount = 0
    local cbValueIndex=cbReferIndex
    local flag = false
    while cbValueIndex <= 13 do
        if cbResultCard[cbResultCount] == nil then
            cbResultCard[cbResultCount] = {}
        end
        if Distributing[2][cbValueIndex][6] < cbBlockCount then
            if cbTmpLinkCount < cbLessLineCount  then
                cbTmpLinkCount = 0
                flag = false
            else
                cbValueIndex = cbValueIndex - 1
                flag = true
            end
        else
            cbTmpLinkCount = cbTmpLinkCount + 1
            if cbLineCount == 0 then
                flag = false
            else
                flag = true
            end
        end
        if flag == true then
            flag = false
            if cbTmpLinkCount >= cbLessLineCount then
                --¸´ÖÆÆË¿Ë
                local cbCount = 0
                local cbIndex=(cbValueIndex-cbTmpLinkCount+1)
                while cbIndex <= cbValueIndex do
                    local cbTmpCount = 0
                    local cbColorIndex=1
                    while cbColorIndex <= 4 do --ÔÚËÄÉ«ÖÐÈ¡Ò»¸ö
                        local cbColorCount = 1
                        while cbColorCount <= Distributing[2][cbIndex][5-cbColorIndex] do
                            cbCount = cbCount + 1
                            cbResultCard[cbResultCount][cbCount] = GameLaiziLogic:MakeCardData(cbIndex,5-cbColorIndex-1)
                            tagSearchCardResult[3][cbResultCount] = cbResultCard[cbResultCount]
                            cbTmpCount = cbTmpCount + 1
                            if cbTmpCount == cbBlockCount then
                                break
                            end
                            cbColorCount = cbColorCount + 1
                        end
                        if cbTmpCount == cbBlockCount then
                            break
                        end
                        cbColorIndex = cbColorIndex + 1
                    end
                    cbIndex = cbIndex + 1
                end
                tagSearchCardResult[2][cbResultCount] = cbCount
                cbResultCount = cbResultCount + 1
                if cbLineCount ~= 0 then
                    cbTmpLinkCount = cbTmpLinkCount - 1
                else
                    cbTmpLinkCount = 0
                end
            end
        end
        cbValueIndex = cbValueIndex + 1
    end

    --ÌØÊâË³×Ó(Ñ°ÕÒA)
    if cbTmpLinkCount >= cbLessLineCount-1 and cbValueIndex == 14 then
        --print("ÌØÊâË³×Ó(Ñ°ÕÒA)")
        if (Distributing[2][1][6] >= cbBlockCount) or (cbTmpLinkCount >= cbLessLineCount) then
            if cbResultCard[cbResultCount] == nil then
                cbResultCard[cbResultCount] = {}
            end
            --¸´ÖÆÆË¿Ë
            local cbCount = 0
            local cbIndex=(cbValueIndex-cbTmpLinkCount)
            while cbIndex <= 13 do
                local cbTmpCount = 0
                local cbColorIndex=1
                while cbColorIndex <= 4 do --ÔÚËÄÉ«ÖÐÈ¡Ò»¸ö
                    local cbColorCount = 1
                    while cbColorCount <= Distributing[2][cbIndex][5-cbColorIndex] do
                        cbCount = cbCount + 1
                        cbResultCard[cbResultCount][cbCount] = GameLaiziLogic:MakeCardData(cbIndex,5-cbColorIndex-1)
                        tagSearchCardResult[3][cbResultCount] = cbResultCard[cbResultCount]

                        cbTmpCount = cbTmpCount + 1
                        if cbTmpCount == cbBlockCount then
                            break
                        end
                        cbColorCount = cbColorCount + 1
                    end
                    if cbTmpCount == cbBlockCount then
                        break
                    end
                    cbColorIndex = cbColorIndex + 1
                end
                cbIndex = cbIndex + 1
            end
            --¸´ÖÆA
            if Distributing[2][1][6] >= cbBlockCount then
                local cbTmpCount = 0
                local cbColorIndex=1
                while cbColorIndex <= 4 do --ÔÚËÄÉ«ÖÐÈ¡Ò»¸ö
                    local cbColorCount = 1
                    while cbColorCount <= Distributing[2][1][5-cbColorIndex] do
                        cbCount = cbCount + 1
                        cbResultCard[cbResultCount][cbCount] = GameLaiziLogic:MakeCardData(1,5-cbColorIndex-1)
                        tagSearchCardResult[3][cbResultCount] = cbResultCard[cbResultCount]

                        cbTmpCount = cbTmpCount + 1
                        if cbTmpCount == cbBlockCount then
                            break
                        end
                        cbColorCount = cbColorCount + 1
                    end
                    if cbTmpCount == cbBlockCount then
                        break
                    end
                    cbColorIndex = cbColorIndex + 1
                end
            end
            tagSearchCardResult[2][cbResultCount] = cbCount
            cbResultCount = cbResultCount + 1
        end
    end
    tagSearchCardResult[1] = cbResultCount - 1
    return tagSearchCardResult
end

--·É»úËÑË÷
function GameLaiziLogic:SearchThreeTwoLine(cbHandCardData, cbHandCardCount)
    --print("·É»úËÑË÷")
    --½á¹ûÊýÄ¿
    local cbSearchCount = 0
    --ÆË¿ËÊýÄ¿
    local cbResultCardCount = {}
    --½á¹ûÆË¿Ë
    local cbResultCard = {}
    --ËÑË÷½á¹û
    local tagSearchCardResult = {cbSearchCount,cbResultCardCount,cbResultCard}
    local tmpSingleWing = {cbSearchCount,cbResultCardCount,cbResultCard}
    local tmpDoubleWing = {cbSearchCount,cbResultCardCount,cbResultCard}

    --ÅÅÐòÆË¿Ë
    local cbCardData = GameLaiziLogic:SortCardList(cbHandCardData, cbHandCardCount, 0)
    local cbCardCount = cbHandCardCount

    local cbTmpResultCount = 0

    --ËÑË÷Á¬ÅÆ
    local tmpSearchResult = GameLaiziLogic:SearchLineCardType(cbHandCardData,cbHandCardCount,0,3,0)
    cbTmpResultCount = tmpSearchResult[1]
    if cbTmpResultCount > 0 then
        --ÌáÈ¡´øÅÆ
        local i = 1
        while i <= cbTmpResultCount do
            local flag = true
            local cbTmpCardData = {}
            local cbTmpCardCount = cbHandCardCount
            --²»¹»ÅÆ
            if cbHandCardCount-tmpSearchResult[2][i] < tmpSearchResult[2][i]/3 then
                local cbNeedDelCount = 3
                while (cbHandCardCount + cbNeedDelCount - tmpSearchResult[2][i]) < (tmpSearchResult[2][i]-cbNeedDelCount)/3 do
                    cbNeedDelCount = cbNeedDelCount + 3
                end
                --²»¹»Á¬ÅÆ
                if (tmpSearchResult[2][i]-cbNeedDelCount)/3 < 2 then
                    flag = false
                else
                    flag = true
                end
                if flag == true then
                    --²ð·ÖÁ¬ÅÆ
                    local removeResult= GameLaiziLogic:RemoveCard(tmpSearchResult[3][i],cbNeedDelCount,tmpSearchResult[3][i],tmpSearchResult[2][i])
                    tmpSearchResult[3][i] = removeResult[2]
                    tmpSearchResult[2][i] = tmpSearchResult[2][i] - cbNeedDelCount
                end
            end
            if flag == true then
                flag = false
                --É¾³ýÁ¬ÅÆ
                for temp=1,#cbHandCardData do
                    cbTmpCardData[temp] = cbHandCardData[temp]
                end
                local removeResult1= GameLaiziLogic:RemoveCard(tmpSearchResult[3][i],tmpSearchResult[2][i],cbTmpCardData,cbTmpCardCount)
                cbTmpCardData = removeResult1[2]
                cbTmpCardCount = cbTmpCardCount - tmpSearchResult[2][i]

                --×éºÏ·É»ú
                local cbNeedCount = tmpSearchResult[2][i]/3
                local cbResultCount = tmpSingleWing[1]+1
                tmpSingleWing[3][cbResultCount] = tmpSearchResult[3][i]
                for j=1,cbNeedCount do
                    tmpSingleWing[3][cbResultCount][tmpSearchResult[2][i]+j] = cbTmpCardData[cbTmpCardCount-cbNeedCount+j]
                end
                tmpSingleWing[2][i] = tmpSearchResult[2][i] + cbNeedCount
                tmpSingleWing[1] = tmpSingleWing[1]+1

                local flag2 = true
                --²»¹»´ø³á°ò
                if cbTmpCardCount < tmpSearchResult[2][i]/3*2 then
                    local cbNeedDelCount = 3
                    while (cbTmpCardCount + cbNeedDelCount - tmpSearchResult[2][i]) < (tmpSearchResult[2][i]-cbNeedDelCount)/3*2 do
                        cbNeedDelCount = cbNeedDelCount + 3
                    end
                    --²»¹»Á¬ÅÆ
                    if (tmpSearchResult[2][i]-cbNeedDelCount)/3 < 2 then
                        flag2 = false
                    else
                        flag2 = true
                    end
                    if flag2 == true then
                        --²ð·ÖÁ¬ÅÆ
                        local removeResult= GameLaiziLogic:RemoveCard(tmpSearchResult[3][i],cbNeedDelCount,tmpSearchResult[3][i],tmpSearchResult[2][i])
                        tmpSearchResult[3][i] = removeResult[2]
                        tmpSearchResult[2][i] = tmpSearchResult[2][i] - cbNeedDelCount

                        --ÖØÐÂÉ¾³ýÁ¬ÅÆ
                        for temp=1,#cbHandCardData do
                            cbTmpCardData[temp] = cbHandCardData[temp]
                        end
                        local removeResult2= GameLaiziLogic:RemoveCard(tmpSearchResult[3][i],tmpSearchResult[2][i],cbTmpCardData,cbTmpCardCount)
                        cbTmpCardData = removeResult2[2]
                        cbTmpCardCount = cbTmpCardCount - tmpSearchResult[2][i]
                    end
                end
                if flag2 == true then
                    flag2 = false
                    --·ÖÎöÅÆ
                    local TmpResult = {}
                    TmpResult = GameLaiziLogic:AnalysebCardData(cbTmpCardData, cbTmpCardCount)
                    --ÌáÈ¡³á°ò
                    local cbDistillCard = {}
                    local cbDistillCount = 0
                    local cbLineCount = tmpSearchResult[2][i]/3
                    local j = 2
                    while j <= 4 do
                        if TmpResult[1][j] > 0 then
                            if (j+1 == 3) and TmpResult[1][j] >= cbLineCount then
                                local  cbTmpBlockCount = TmpResult[1][j]
                                for k=1,j*cbLineCount do
                                    cbDistillCard[k] = TmpResult[2][j][(cbTmpBlockCount-cbLineCount)*j+k]
                                end
                                cbDistillCount = j*cbLineCount
                            else
                                local k = 1
                                while k <= TmpResult[1][j] do
                                    local cbTmpBlockCount = TmpResult[1][j]
                                    for l=1,2 do
                                        cbDistillCard[cbDistillCount+l] = TmpResult[2][j][(cbTmpBlockCount-k)*j+l]
                                    end
                                    cbDistillCount = cbDistillCount + 2

                                    --ÌáÈ¡Íê³É
                                    if cbDistillCount == 2*cbLineCount then
                                        break
                                    end
                                    k = k + 1
                                end
                            end
                        end
                        --ÌáÈ¡Íê³É
                        if cbDistillCount == 2*cbLineCount then
                            break
                        end
                        j = j + 1
                    end
                    
                    --ÌáÈ¡Íê³É
                    if cbDistillCount == 2*cbLineCount then
                        --print("¸´ÖÆÁ½¶Ô")
                        --¸´ÖÆ³á°ò
                        tmpDoubleWing[1] = tmpDoubleWing[1]+1
                        cbResultCount = tmpDoubleWing[1]
                        tmpDoubleWing[3][cbResultCount] = tmpSearchResult[3][i]
                        for n=1,cbDistillCount do
                            tmpDoubleWing[3][cbResultCount][tmpSearchResult[2][i]+n] = cbDistillCard[n]
                        end
                        tmpDoubleWing[2][cbResultCount] = tmpSearchResult[2][i] + cbDistillCount
                    end
                end
            end
            i = i + 1
        end
        --¸´ÖÆ½á¹û
        for m=1,tmpDoubleWing[1] do
            tagSearchCardResult[1] = tagSearchCardResult[1] + 1
            local cbResultCount = tagSearchCardResult[1]
            tagSearchCardResult[3][cbResultCount] = tmpDoubleWing[3][m]
            tagSearchCardResult[2][cbResultCount] = tmpDoubleWing[2][m]
        end
        for m=1,tmpSingleWing[1] do
            tagSearchCardResult[1] = tagSearchCardResult[1] + 1
            local cbResultCount = tagSearchCardResult[1]
            tagSearchCardResult[3][cbResultCount] = tmpSingleWing[3][m]
            tagSearchCardResult[2][cbResultCount] = tmpSingleWing[2][m]
        end
    end
    return tagSearchCardResult
end

--·ÖÎö·Ö²¼
function GameLaiziLogic:AnalysebDistributing(cbCardData, cbCardCount)
    local cbCardCount1 = 0
    local cbDistributing = {}
    for i=1,16 do
        local distributing = {}
        for j=1,6 do
            distributing[j] = 0
        end
        cbDistributing[i] = distributing
    end
    local Distributing = {cbCardCount1,cbDistributing}
    for i=1,cbCardCount do
        if cbCardData[i]~=0 then
            local cbCardColor = GameLaiziLogic:GetCardColor(cbCardData[i])
            local cbCardValue = GameLaiziLogic:GetCardValue(cbCardData[i])
            --·Ö²¼ÐÅÏ¢
            cbCardCount1 = cbCardCount1 + 1
            cbDistributing[cbCardValue][5+1] = cbDistributing[cbCardValue][6]+1
            local color = bit:_rshift(cbCardColor,4) + 1
            cbDistributing[cbCardValue][color] = cbDistributing[cbCardValue][color]+1
        end
    end
    Distributing[1] = cbCardCount1
    Distributing[2] = cbDistributing
    -- print("×ÜÊý£º" .. Distributing[1])
    -- for i=1,15 do
    --     print("Ã¿ÕÅ×ÜÊý£º" .. Distributing[2][i][6])
    -- end
    return Distributing
end

--¹¹ÔìÆË¿Ë
function GameLaiziLogic:MakeCardData(cbValueIndex,cbColorIndex)
    --print("¹¹ÔìÆË¿Ë " ..bit:_or(bit:_lshift(cbColorIndex,4),cbValueIndex)..",".. GameLaiziLogic:GetCardLogicValue(bit:_or(bit:_lshift(cbColorIndex,4),cbValueIndex)))
    return bit:_or(bit:_lshift(cbColorIndex,4),cbValueIndex)
end

---É¾³ýÆË¿Ë
function GameLaiziLogic:RemoveCard(cbRemoveCard, cbRemoveCount, cbCardData, cbCardCount)
    local cbDeleteCount=0
    local cbTempCardData = {}
    for i=1,#cbCardData do
        cbTempCardData[i] = cbCardData[i]
    end
    local result = {false,cbCardData}
    --ÖÃÁãÆË¿Ë
    local i = 1
    while i <= cbRemoveCount do
        local j = 1
        while j < cbCardCount do
            if cbRemoveCard[i] == cbTempCardData[j] then
                cbDeleteCount = cbDeleteCount + 1
                cbTempCardData[j] = 0
                break
            end
            j = j + 1
        end
        i = i + 1
    end
    if cbDeleteCount ~= cbRemoveCount then
        return result
    end
    --ÇåÀíÆË¿Ë
    local cbCardPos=1
    local datas = {}
    for i=1,cbCardCount do
        if cbTempCardData[i] ~= 0 then
            datas[cbCardPos] = cbTempCardData[i]
            cbCardPos = cbCardPos + 1
        end
    end
    result = {true,datas}
    return result
end 

--ÅÅÁÐÆË¿Ë
function GameLaiziLogic:SortOutCardList(cbCardData,cbCardCount)
    local resultCardData = {}
    local resultCardCount = 0
    --»ñÈ¡ÅÆÐÍ
    local cbCardType = GameLaiziLogic:GetCardType(cbCardData,cbCardCount)
    if cbCardType == GameLaiziLogic.CT_THREE_TAKE_ONE or cbCardType == GameLaiziLogic.CT_THREE_TAKE_TWO then
        --·ÖÎöÅÆ
        local AnalyseResult = {}
        AnalyseResult = GameLaiziLogic:AnalysebCardData(cbCardData,cbCardCount)

        resultCardCount = AnalyseResult[1][3]*3
        resultCardData = AnalyseResult[2][3]
        
        for i=4,1,-1 do
            if i ~= 3 then
                if AnalyseResult[1][i] > 0 then
                    for j=1,AnalyseResult[1][i]*i do
                        resultCardData[resultCardCount+j] = AnalyseResult[2][i][j]
                    end
                    resultCardCount = resultCardCount + AnalyseResult[1][i]*i
                end
            end
        end
       
    elseif cbCardType == GameLaiziLogic.CT_FOUR_TAKE_ONE or cbCardType == GameLaiziLogic.CT_FOUR_TAKE_TWO then
        --·ÖÎöÅÆ
        local AnalyseResult = {}
        AnalyseResult = GameLaiziLogic:AnalysebCardData(cbCardData,cbCardCount)

        resultCardCount = AnalyseResult[1][4]*4
        resultCardData = AnalyseResult[2][4]
        
        for i=4,1,-1 do
            if i ~= 3 then
                if AnalyseResult[1][i] > 0 then
                    for j=1,AnalyseResult[1][i]*i do
                        resultCardData[resultCardCount+j] = AnalyseResult[2][i][j]
                    end
                    resultCardCount = resultCardCount + AnalyseResult[1][i]*i
                end
            end
        end
    end
    return resultCardData
end


return GameLaiziLogic