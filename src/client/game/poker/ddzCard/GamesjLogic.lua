--[[--
¶·µØÖ÷ÓÎÏ·Âß¼­
2016.6
]]
local GamesjLogic = {}

GamesjLogic._CardData = { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, -- ·½¿é
                        0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, -- Ã·»¨
                        0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, -- ºìÌÒ
                        0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, -- ºÚÌÒ
                        0x4E, 0x4F } -- Ð¡Íõ,´óÍõ

GamesjLogic.GAME_PLAYER         = 3    -- ÓÎÏ·ÈËÊý
GamesjLogic.CARD_COUNT_NORMAL   = 17   -- ³£¹æÅÆÊý
GamesjLogic.CARD_COUNT_MAX      = 20   -- ×î´óÅÆÊý
GamesjLogic.CARD_FULL_COUNT     = 54   -- È«ÅÆÊýÄ¿

-- ÆË¿ËÀàÐÍ
GamesjLogic.CT_ERROR            = 0    -- ´íÎóÀàÐÍ
GamesjLogic.CT_SINGLE           = 1    -- µ¥ÅÆÀàÐÍ
GamesjLogic.CT_DOUBLE           = 2    -- ¶ÔÅÆÀàÐÍ
GamesjLogic.CT_THREE            = 3    -- ÈýÌõÀàÐÍ
GamesjLogic.CT_SINGLE_LINE      = 4    -- µ¥Á¬ÀàÐÍ
GamesjLogic.CT_DOUBLE_LINE      = 5    -- ¶ÔÁ¬ÀàÐÍ
GamesjLogic.CT_THREE_LINE       = 6    -- ÈýÁ¬ÀàÐÍ
GamesjLogic.CT_THREE_TAKE_ONE   = 7    -- Èý´øÒ»µ¥
GamesjLogic.CT_THREE_TAKE_TWO   = 8    -- Èý´øÒ»¶Ô
GamesjLogic.CT_FOUR_TAKE_ONE    = 9    -- ËÄ´øÁ½µ¥
GamesjLogic.CT_FOUR_TAKE_TWO    = 10   -- ËÄ´øÁ½¶Ô
GamesjLogic.CT_BOMB_CARD        = 11   -- Õ¨µ¯ÀàÐÍ
GamesjLogic.CT_MISSILE_CARD     = 12   -- »ð¼ýÀàÐÍ
GamesjLogic.WUSHUN              = 13


--[[
-- 扑克类型
GamesjLogic.CT_ERROR            = 0    -- 错误类型
GamesjLogic.CT_SINGLE           = 1    -- 单牌类型
GamesjLogic.CT_DOUBLE           = 2    -- 对牌类型
GamesjLogic.CT_THREE            = 3    -- 三条类型
GamesjLogic.CT_SINGLE_LINE      = 4    -- 单连类型
GamesjLogic.CT_DOUBLE_LINE      = 5    -- 对连类型
GamesjLogic.CT_THREE_LINE       = 6    -- 三连类型
GamesjLogic.CT_THREE_TAKE_ONE   = 7    -- 三带一单
GamesjLogic.CT_THREE_TAKE_TWO   = 8    -- 三带一对
GamesjLogic.CT_FOUR_TAKE_ONE    = 9    -- 四带两单
GamesjLogic.CT_FOUR_TAKE_TWO    = 10   -- 四带两对
GamesjLogic.CT_BOMB_CARD        = 11   -- 炸弹类型
GamesjLogic.CT_MISSILE_CARD     = 12   -- 火箭类型


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



local Q_SINGLE      = 100
local Q_DOUBLE      = 101
local Q_DOUBLE_LINE = 102
local Q_SHUAI       = 103


local log = gt.log

function GamesjLogic:log(...)
	--log(...)
end

-- ´´½¨¿ÕÆË¿ËÊý×é1a
function GamesjLogic:emptyCardList( count )
    local tmp = {}
    for i = 1, count do
        tmp[i] = 0
    end
    return tmp
end

function GamesjLogic:get_card_string(a)
    if a == 1 then 
        return "A"
    elseif a == 11 then 
        return "J"
    elseif a == 12 then 
        return "Q"
    elseif a == 13 then 
        return "K"
    else
        return a
    end
end

--扑克排序
function GamesjLogic:SortCardLists(cbCardData)

    local cbCardCount = #cbCardData
    
        local buf = {}
        local buf1 = {}
        local tmp = {}
        cbCardData = self:SortCardList(cbCardData,cbCardCount)

        gt.log("ppppppppppppp")

        for i = 1 ,cbCardCount do
            tmp[i] = true
            if  self:GetCardValue(cbCardData[i]) == 14 or self:GetCardValue(cbCardData[i]) ==15  then    --- 选双王
                table.insert(buf,cbCardData[i])
                tmp[i] = false
            end
        end

        if gt._changzhu then --- 剩下的主牌

            for i = 1 ,cbCardCount do
                if self:GetCardValue(cbCardData[i]) == gt._changzhus and gt._changzhus ~= 64 and  self:GetCardValue(cbCardData[i]) ~=2 then   --- 选 打几的主
                    table.insert(buf,cbCardData[i])
                    tmp[i] = false
                end
            end


        else
            for i = 1 ,cbCardCount do
                if self:GetCardValue(cbCardData[i]) == gt._changzhus and gt._changzhus ~= 64  then   --- 选 打几的主
                    table.insert(buf,cbCardData[i])
                    tmp[i] = false
                end
            end

        end

        for i = 1 ,cbCardCount do
            if (gt._changzhu and self:GetCardValue(cbCardData[i]) == 2) then --- 选 2长主
                table.insert(buf,cbCardData[i])
                tmp[i] = false
            end
        end


        if gt._changzhu then --- 剩下的主牌

            for i = 1 ,cbCardCount do

                if gt._changzhus ~= 64 and self:GetCardColor(cbCardData[i]) == self:GetCardColor(gt._changzhus) and self:GetCardValue(cbCardData[i]) ~= gt._changzhus  and self:GetCardValue(cbCardData[i]) ~= 2  then 
                    table.insert(buf,cbCardData[i])
                    tmp[i] = false
                end
            end

        else

            for i = 1 ,cbCardCount do

                if gt._changzhus ~= 64 and self:GetCardColor(cbCardData[i]) == self:GetCardColor(gt._changzhus) and self:GetCardValue(cbCardData[i]) ~= gt._changzhus then 
                    table.insert(buf,cbCardData[i])
                    tmp[i] = false
                end
            end
        end
       
        for i = 1 ,cbCardCount do
            if tmp[i] then
                table.insert(buf1,cbCardData[i])
            end
        end

    
        local cb = {}
        for i = 1 , #buf do
            
            table.insert(cb,buf[i])
        end

        for i = 1, #buf1 do
            table.insert(cb,buf1[i])
        end



        return cb
    
    
end


-- »ñÈ¡ÓàÊý
function GamesjLogic:mod(a, b)
    return a - math.floor(a/b)*b
end

-- »ñÈ¡ÕûÊý
function GamesjLogic:ceil(a, b)
    return math.ceil(a/b) - 1
end

-- »ñÈ¡ÅÆÖµ(1-15)
function GamesjLogic:GetCardValue(nCardData)
    --return bit:_and(nCardData, 0X0F)    -- ÊýÖµÑÚÂë
    --gt.log("nCardData",nCardData)
    if nCardData then 
    	if nCardData > 100 then nCardData = nCardData -100 end
    	--gt.log("nCardData11",nCardData)
	    return yl.POKER_VALUE[nCardData]
	end
end

-- »ñÈ¡»¨É«(1-5)
function GamesjLogic:GetCardColor(nCardData)
    --return bit:_and(nCardData, 0XF0)    --»¨É«ÑÚÂë
    if nCardData then 
    	if nCardData > 100 then nCardData = nCardData -100 end
    	return yl.POKER_COLOR[nCardData]
	end
end

-- Âß¼­ÅÆÖµ(´óÐ¡Íõ¡¢2¡¢A¡¢K¡¢Q)
function GamesjLogic:GetCardLogicValue(nCardData) --bbb

    if nCardData == 64 then return -100 end

    local nCardValue = self:GetCardValue(nCardData)
    local nCardColor = self:GetCardColor(nCardData)
    if nCardColor == 0x40 then
    	
        return nCardValue + 2
    end
    if nCardValue then
    	
    	return nCardValue < 2 and (nCardValue + 13) or nCardValue
	end
end

-- »ñÈ¡ÅÆÐò 0x4F´óÍõ 0x4EÐ¡Íõ nilÅÆ±³ 
function GamesjLogic:GetCardIndex(nCardData)
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
function GamesjLogic:SortCardList(cbCardData, cbCardCount, cbSortType)


    cbSortType = cbSortType or false
    cbCardData = yl.switch_card(cbCardData)
    
    for i = 1 , cbCardCount do  
        for j = i + 1 , cbCardCount do 
            local num = self:GetCardColor(cbCardData[i]) *10 + self:GetCardLogicValue(cbCardData[i]) 
            local num1 = self:GetCardColor(cbCardData[j]) *10 + self:GetCardLogicValue(cbCardData[j]) 
            if num1 > num then 
                local tmp = cbCardData[i]
                 cbCardData[i] = cbCardData[j]
                 cbCardData[j] = tmp 
            end
        end
    end
    if not cbSortType then 
        cbCardData = yl.add_switch_card(cbCardData)
    end



    return cbCardData


end





--»ñÈ¡´ÓÐ¡µ½´óµÄÅÅÐò
function GamesjLogic:SortCardListUp(cbCardData, cbCardCount)
	cbCardData = self:SortCardList(cbCardData, cbCardCount,true)
	
	local tempList = {}
	for i=#cbCardData,1 ,-1 do
		table.insert(tempList,cbCardData[i])
	end
	return tempList
end 

--Ä³ÅÆÎ»ÖÃ
function GamesjLogic:GetOneCardIndex(cbCardData,nCardData)
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
function GamesjLogic:GetAddIndex(cbCardData,nCardData)
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
function GamesjLogic:AddOneCard(cbCardData,nCardData,index)
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
function GamesjLogic:RemoveOneCard(cbCardData,index)
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
function GamesjLogic:AnalysebCardData2(cbCardData, cbCardCount) --aaa
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
        local cbLogicValue = self:GetCardValue(cbCardData[i])*10 + self:GetCardColor(cbCardData[i])
        local j = i+1
        while j <= cbCardCount do
            local cbLogicValue2 = self:GetCardValue(cbCardData[j])*10 + self:GetCardColor(cbCardData[j])
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
		
			for k=1,cbSameCount do
				cbCardDatas[cbSameCount][index*cbSameCount+k] = cbCardData[i+k-1] -- 
			end
		end 
        i = i + cbSameCount
    end

 

    return cbCardDatas
end


--·ÖÎöÓÐÐòÆË¿Ë
function GamesjLogic:AnalysebCardData1(cbCardData, cbCardCount) --aaa
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
function GamesjLogic:AnalysebCardData(cbCardData, cbCardCount) --aaa
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



function GamesjLogic:AnalysebCardData3()
end


function GamesjLogic:GetCardColors(card)
	
	

	if GamesjLogic:GetCardValue(card) == 14 or GamesjLogic:GetCardValue(card) == 15 or GamesjLogic:GetCardValue(card) == gt._changzhus or (gt._changzhu and GamesjLogic:GetCardValue(card) == 2) or (  gt.kSelectCard ~= 64 and self:GetCardColor(card) == self:GetCardColor( gt.kSelectCard) ) then 
		
		return 100
	else
		return self:GetCardColor(card)
	end

end

function GamesjLogic:GetCardType2(cards,kSelectCard)



-- local Q_SINGLE      = 100
-- local Q_DOUBLE      = 101
-- local Q_DOUBLE_LINE = 102
-- local Q_SHUAI       = 103
	
		-- body

	cards = yl.switch_card(cards)

	local buf = {}
	local lenbuf = 0
	local tbuf
	local card
	if #cards ~= 0 then
		card = self:SortCardListUp(cards,#cards,0)
	else
		return 0
	end



	gt.log("cardType________return1")


	gt.dump(cards)

	for i = 1 , #cards - 1 do
	
		if self:GetCardColors(cards[i]) ~= self:GetCardColors(cards[i+1]) then gt.log("ewruen_____") return 0 end
	end	

	gt.log("cardType________return2")

	local zhu = 0
	local num = #cards
	if num == 1 then 
		buf[Q_SINGLE] = GamesjLogic:GetCardColors(card[1])
		zhu =  #self:select_zhu(cards,kSelectCard) 
	elseif num == 2 then 
		
		if GamesjLogic:GetCardColors(card[1]) == GamesjLogic:GetCardColors(card[2]) then 
			if GamesjLogic:GetCardValue(card[1]) == GamesjLogic:GetCardValue(card[2]) and GamesjLogic:GetCardColor(card[1]) == GamesjLogic:GetCardColor(card[2]) then
				buf[Q_DOUBLE] = GamesjLogic:GetCardColors(card[1])
			else
				buf[Q_SHUAI] = GamesjLogic:GetCardColors(card[1])
			end
		end
		zhu =  #self:select_zhu(cards,kSelectCard) 
	elseif self:is_tuolaiji(card) then 
		gt.log("3-__________---------")
		buf[Q_DOUBLE_LINE] = GamesjLogic:GetCardColors(card[1])
		zhu =  #self:select_zhu(cards,kSelectCard) 
	else
		gt.log("4-__________---------")
		buf[Q_SHUAI] = GamesjLogic:GetCardColors(card[1])
		zhu =  #self:select_zhu(cards,kSelectCard) 
	end

	return buf , zhu
end

function GamesjLogic:select_zhu( handcard,kSelectCard )
	local buf = {}
	for i = 1 , #handcard do
		if GamesjLogic:GetCardValue(handcard[i]) == 14 or GamesjLogic:GetCardValue(handcard[i]) == 15 or GamesjLogic:GetCardValue(handcard[i]) == gt._changzhus or (gt._changzhu and GamesjLogic:GetCardValue(handcard[i]) == 2) 
			or (  kSelectCard ~= 64 and self:GetCardColor(handcard[i]) == self:GetCardColor(kSelectCard) ) then 
			table.insert(buf,handcard[i])
		end
	end
	return buf
end


function GamesjLogic:screne(res,tbuf,selectbuf,outbuf)

        for k , y in pairs(res) do

             if CardColor ~= y then return 0 end  -- 色值相同
             if k == Q_SINGLE then 
             elseif k == Q_DOUBLE then 
                 if tbuf[2][2] ~= -1 then --  提示可选
                     if selectbuf[2][2] == -1 then return 0 end
                 end 
             elseif k == Q_DOUBLE_LINE then
                 if tbuf[2][#outCard] ~= -1 then 
                     if selectbuf[2][#outCard] == -1 then return 0 end

                 else
                     local t = 0
                     for i = 1, #tbuf[2] do 
                         if tbuf[2][i] ~= -1 then 
                             t = t+ 1
                         end
                     end
                     local t1 = 0
                     for i = 1, #selectbuf[2] do
                         if selectbuf[2][i] ~= -1 then 
                             t1 = t1 + 1
                         end
                     end
                     gt.log("t____________")
                     gt.log(t)
                     gt.log(t1)
                     if t1 ~= t then return 0 end
                 end 
             elseif k == Q_SHUAI then 
                 gt.log("shuai_______________________________")
                 local t = 0
                 for i = 1, #outbuf[2] do 
                     if outbuf[2][i] ~= -1 then 
                         t = t+ 1
                     end
                 end
                 local t1 = 0
                 for i = 1, #tbuf[2] do
                     if tbuf[2][i] ~= -1 then 
                         t1 = t1 + 1
                     end
                 end
                 local t2 = 0
                 for i = 1, #selectbuf[2] do
                     if selectbuf[2][i] ~= -1 then 
                         t2 = t2 + 1
                     end
                 end
                 gt.log(t)
                 gt.log(t1)
                 gt.log(t2)
                 if t ~= 0 then 
                     if t1 >= t then -- 手牌对子 大于 出牌的对子
                         if t2 ~= t then return 0 end
                     else
                         if t2 ~= t1 then return 0 end
                     end
                 end

             end
            end

        return 1
end


function GamesjLogic:find_tulaji(selectbuf,kSelectCard)


    local bufs = {}
      
    for i = 1, #selectbuf[2] do
        if selectbuf[2][i] ~= -1 then 

            if   self:GetCardLogicValue(selectbuf[2][i])   ~=   self:GetCardLogicValue(kSelectCard) and self:GetCardLogicValue(selectbuf[2][i]) ~=14 and self:GetCardLogicValue(selectbuf[2][i]) ~= 15 then
     
                if i % 2 == 1  then 
                    table.insert(bufs, self:GetCardLogicValue(selectbuf[2][i]) )
                end
            end
        end
    end


   

    for i = 1 , #bufs do
        for j = i + 1 ,#bufs do
            if bufs[i] > bufs[j] then 
                local tmp = bufs[i]
                bufs[i] = bufs[j]
                bufs[j] = tmp
            end
        end
    end

    local buf = bufs
    
    gt.dump(buf)

    local idx = 1
    local num = 1
   

    for i = 1 , #buf -1 do
      
        if (buf[i] + 1 == buf[i+1] and buf[i] ~= self:GetCardLogicValue(kSelectCard) and buf[i+1] ~= self:GetCardLogicValue(kSelectCard)) or 
         (buf[i] + 2 == buf[i+1] and kSelectCard ~= 64 and buf[i] + 1 == self:GetCardLogicValue(kSelectCard) and buf[i] ~= self:GetCardLogicValue(kSelectCard) and buf[i+1] ~= self:GetCardLogicValue(kSelectCard) )then 
            idx = idx + 1
        else
            idx = 1 
        end
        
        if idx > num then 
            num  = idx
        end
    end
    

    gt.log("num.......,",num)

    return #buf , num

end


function GamesjLogic:CompareCard(outCard,selectCard,handcard,kSelectCard)



	outCard = yl.switch_card(outCard)
	selectCard = yl.switch_card(selectCard)
	handcard = yl.switch_card(handcard)

	gt.dump(outCard)
	gt.dump(selectCard)

	if kSelectCard > 100 then kSelectCard = kSelectCard - 100 end

	if type(outCard) ~= "table" or type(selectCard) ~= "table" then return 0 end
	gt.log("select__________")
	
	if #outCard == 0 then 
		local res = self:GetCardType2(selectCard,kSelectCard)
		if type(res) == "table" then 
			return 1
		else
			gt.log("return_____")
			return 0
		end
	else
		gt.log("res____________1")
		local res ,num = self:GetCardType2(outCard,kSelectCard)
		if type(res) == "number" then return 0 end
		if #outCard ~=  #selectCard then return 0 end
		
		gt.log("res____________",gt._changzhus)
		gt.dump(res)

		local buf = {} -- 选出 手牌中与出牌同花色的牌 
		
		--GamesjLogic:GetCardValue(card) == gt._changzhus
		for i = 1 , #handcard do
			if GamesjLogic:GetCardColors(handcard[i]) == self:GetCardColors(outCard[1]) then 
				table.insert(buf,handcard[i])
			end
		end
		buf = self:SortCardListUp(buf,#buf,0) -- >小->大

		gt.dump(buf)

		selectCard = self:SortCardListUp(selectCard,#selectCard,0) -- >小->大
		outCard = self:SortCardListUp(outCard,#outCard,0) -- >小->大

		local tbuf = self:AnalysebCardData2(buf,#buf) --- 手牌
		local selectbuf = self:AnalysebCardData2(selectCard,#selectCard)
		local outbuf = self:AnalysebCardData2(outCard,#outCard)

		gt.log("cardType________",#buf,#outCard)

		if #buf >= #outCard then

			local sel ,num1 = self:GetCardType2(selectCard,kSelectCard)

			gt.log("c________________")
			if type(sel) == "number" then return 0 end -- h花色是否相同


			local cardType = 0
			local CardColor  = 0
			for l, z in pairs(sel) do
				cardType = l 
				CardColor = z
			end

			gt.dump(res)

			gt.dump(tbuf)
			gt.dump(selectbuf)
			gt.dump(outbuf)

			for k , y in pairs(res) do
				gt.log("CardColor....",k)
				gt.log("CardColor....",y)
				if CardColor ~= y then return 0 end  -- 色值相同
				if k == Q_SINGLE then 
				elseif k == Q_DOUBLE then 
					if tbuf[2][2] ~= -1 then --  提示可选
						if selectbuf[2][2] == -1 then return 0 end
					end	
				elseif k == Q_DOUBLE_LINE then
					if tbuf[2][#outCard] ~= -1 then 
						if selectbuf[2][#outCard] == -1 then return 0 end
                        local num0 = #outCard*0.5
                        gt.log("xuan________1222222")
                        local num,num1 =  self:find_tulaji(tbuf,kSelectCard)
                        gt.log("xuan_____________-")
                        local num2,num3 =  self:find_tulaji(selectbuf,kSelectCard)
                        gt.log("t____________")
                        gt.log("手牌",num1)
                        gt.log("选择",num3)
                        gt.log("出牌",num0)
                        if num1 >= num0 then 
                            if num3 ~= num0 then return 0 end
                        else
                            if num3 ~= num1 then return 0 end
                        end

					else
						local t = 0
						for i = 1, #tbuf[2] do 
							if tbuf[2][i] ~= -1 then 
								t = t+ 1
							end
						end
						local t1 = 0
						for i = 1, #selectbuf[2] do
							if selectbuf[2][i] ~= -1 then 
								t1 = t1 + 1
							end
						end
						if t1 ~= t then return 0 end
					end 
				elseif k == Q_SHUAI then 
					gt.log("shuai_______________________________")
					local t = 0
					for i = 1, #outbuf[2] do 
						if outbuf[2][i] ~= -1 then 
							t = t+ 1
						end
					end
					local t1 = 0
					for i = 1, #tbuf[2] do
						if tbuf[2][i] ~= -1 then 
							t1 = t1 + 1
						end
					end
					local t2 = 0
					for i = 1, #selectbuf[2] do
						if selectbuf[2][i] ~= -1 then 
							t2 = t2 + 1
						end
					end
					gt.log(t) -- 出牌
					gt.log(t1) -- 手牌
					gt.log(t2) -- 选择的 
					if t ~= 0 then 
						if t1 >= t then -- 手牌对子 大于 出牌的对子
							if t2 < t then return 0 end

                            local n1 ,n2 = self:find_tulaji(outbuf,kSelectCard)
                            if n2 > 1 then 
                                local num0 = n2
                                local num,num1 =  self:find_tulaji(tbuf,kSelectCard)
                                local num2,num3 =  self:find_tulaji(selectbuf,kSelectCard)
                                if num1 >= num0 then 
                                    if num3 < num0 then return 0 end
                                else
                                    if num3 ~= num1 then return 0 end
                                end
                            end
						else
							if t2 ~= t1 then return 0 end
						end
					end

				end
			end

           -- if self:screne(res,tbuf,selectbuf,outbuf) == 0 then return 0 end

		else

			local idx  = {}
			for i = 1, #selectCard do
				if self:GetCardColors(selectCard[i]) == self:GetCardColors(outCard[1]) then 
					table.insert(idx,selectCard[i])
				end
			end
			gt.log("vde_______________",#idx)
			gt.log("vde_______________",#buf)

			if #idx ~= #buf then return 0 end
		end	

	


		

		
		
	end

	return 1

end



function GamesjLogic:get_auto_selcet_card( outCard , selectCard , handcard )


	
end

function GamesjLogic:is_tuolaiji(cards)

	local num = #cards
	if num % 2 == 1 then 
		gt.log("retrn3")
		return false
	end
	local clour = self:GetCardColors(cards[1])
	for i = 1 , num do
		if clour ~= self:GetCardColors(cards[i]) then 
			gt.log("retrn2")
			return false
		end
	end


	local buf = {}
	for i = 1 , num do
		if self:GetCardValue(cards[i]) == 14 or self:GetCardValue(cards[i]) == 15 then return false end
		if i %2 == 0 then 
			if self:GetCardValue(cards[i]) == self:GetCardValue(cards[i-1]) and  self:GetCardColor(cards[i]) == self:GetCardColor(cards[i-1]) then 
				table.insert(buf,cards[i])
			else
				gt.log("retrn1")
				return false
			end
		end
	end



	gt.log("#######",#buf)

	for i = 1 , #buf -1 do
		
		if self:GetCardLogicValue(buf[i]) + 1 ~= self:GetCardLogicValue(buf[i+1])  then
		
			if gt._changzhus ~= 0 then 
				if self:GetCardLogicValue(buf[i]) + 1 ~= gt._changzhus or  gt._changzhus + 1 ~= self:GetCardLogicValue(buf[i+1]) then 
					gt.log("retrn4")
					return false
				end
			end
	
		end
	end

	return true

end


function  GamesjLogic:LzFeiji(card,buf)

	if card[2][#buf-4] ~= -1 and card[3][3] ~= -1 then 

		--for 

	end

	--if card[3][3]

end


-- 花牌不能 做2 and  3 
function GamesjLogic:is(buf)
	if GamesjLogic:GetCardLogicValue(buf)== 15 or GamesjLogic:GetCardLogicValue(buf)== 3 or  GamesjLogic:GetCardLogicValue(buf)== 16 or  GamesjLogic:GetCardLogicValue(buf)== 17 then
		return false
	else
		return true
	end
end

function GamesjLogic:feiji(tbuf,card,_type)

	local buf = {}
	local lenbuf = 0
	
	local t = {}
	for i = 1 , card -3 do
		if i % 3 == 1 then
			table.insert(t,GamesjLogic:GetCardLogicValue(tbuf[3][i]))
		end
	end
	table.insert(t,GamesjLogic:GetCardLogicValue(tbuf[2][2]))

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
	-- 	buf[CT_THREE_LINE] = GamesjLogic:GetCardLogicValue(tbuf[3][1])
	-- elseif self:isLzFeiji(tbuf,card-3) == 1 then
	-- 	lenbuf = card/3
	-- 	if GamesjLogic:GetCardLogicValue(tbuf[3][card-3]) == 14 then
	-- 		buf[CT_THREE_LINE] = 15 - card/3
	-- 	else
	-- 		buf[CT_THREE_LINE] = GamesjLogic:GetCardLogicValue(tbuf[3][1])
	-- 	end
	-- end

	return buf , lenbuf
end

function GamesjLogic:liandui(tbuf,card)
	local buf = {}
	local lenbuf = 0

	local t = {}
	for i = 1 , card -2 do
		if i % 2 == 1 then
			table.insert(t,GamesjLogic:GetCardLogicValue(tbuf[2][i]))
		end
	end
	table.insert(t,GamesjLogic:GetCardLogicValue(tbuf[1][1]))

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

function GamesjLogic:shunzi(tbuf,card)
	local buf = {}
	local lenbuf = 0
	if GamesjLogic:GetCardLogicValue(tbuf[1][card-1]) <= 14 then
		if self:isLzSunzi(tbuf,card-1) == 2 then
			lenbuf = card
			buf[CT_SINGLE_LINE] = GamesjLogic:GetCardLogicValue(tbuf[1][1])
		elseif self:isLzSunzi(tbuf,card-1) == 1 then
			lenbuf = card
			if GamesjLogic:GetCardLogicValue(tbuf[1][card-1]) == 14 then
				if card ~= 12 then
					buf[CT_SINGLE_LINE] = 15 - card
				else
					lenbuf = 0	
				end
			else
				buf[CT_SINGLE_LINE] = GamesjLogic:GetCardLogicValue(tbuf[1][1])
			end
		end
	end
	return buf , lenbuf
end

-- 1 card 手牌结构
-- 2 num 上家出顺子长
-- 3 balue 上家顺子最小值
function GamesjLogic:findLzSunzi(card,num,value,tishiBuf) --iii


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

function GamesjLogic:findDaipai(shoupai,num,tmp)

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

function GamesjLogic:findDaipai_two(shoupai,num,tmp)

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

function GamesjLogic:findLzfj(card,num,value,buf,shoupai)
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
									res,res1 = self:find1(t[i+3]+1,card)
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
									res,res1 = self:find1(t[i]-1,card)
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
									res,res1 = self:find1(t[tmp]-1,card)
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
									res,res1 = self:find1(t[tmp]+1,card) 
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
									res,res1 =self:find1(t[tmp]+1,card)
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
									res,res1 = self:find1(t[i+3]+1,card)
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
									res,res1 = self:find1(t[i]-1,card)
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
									res,res1 = self:find1(t[tmp]-1,card)
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

function GamesjLogic:findLzfj_two(card,num,value,buf,shoupai)
	
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
									gt.log("abcd_______1")
									if not self:findDaipai_two(shoupai,num,cards1) then cards1 = {} end

									-- for l = 1 , num do
									-- 	table.insert(cards1,card[1][l])
									-- end

								elseif a == num -2  then
									res,res1 = self:find1(t[i+3]+1,card)
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
									res,res1 = self:find1(t[i]-1,card)
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
									res,res1 = self:find1(t[tmp]-1,card)
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
									res,res1 = self:find1(t[tmp]+1,card) 
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
									res,res1 =self:find1(t[tmp]+1,card)
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
									res,res1 = self:find1(t[i+3]+1,card)
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
									res,res1 = self:find1(t[i]-1,card)
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
									res,res1 = self:find1(t[tmp]-1,card)
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

	    --end

		--print("fj_____________",#buf)
	

	end

end

function GamesjLogic:findLzLd(card,num,value,buf)




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



	t = {}
	for i = idx , #tbuf do
		table.insert(t,tbuf[i])
		--print("cardNum..",self:GetCardLogicValue(tbuf[i]))
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
								self:log("ccccccc",value)
								res = self:find(t[i+2]+1,card,value)
								if res ~= -1 then
									
									for x = j , 2*num +j -2 -1 do
										table.insert(cards2,t[x])
									
									end
									table.insert(cards2,res)
									table.insert(cards2,card[5][1])
								end
								res = self:find(t[i]-1,card,value)
								if res ~= -1 then
									for x = j , 2*num +j -2 -1 do
										table.insert(cards3,t[x])
									end
									table.insert(cards3,res)
									table.insert(cards3,card[5][1])
	 							end
							end
						elseif b == 1 then
							tmp = i
							
							if a + b == num -2 then
								
								res = self:find(t[tmp]-1,card,value)
								
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
						if b == 0 then
							tmp = i
							b = b + 1 
							if a + b == num -2 then
								res = self:find(t[tmp]+1,card,value)
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
								res = self:find(t[tmp]+1,card,value)
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
								res = self:find(t[i+2]+1,card,value)
								if res ~= -1 then
									
									for x = j , 2*num +j -2 -1 do
										table.insert(cards8,t[x])
										
									end
									table.insert(cards8,res)
									table.insert(cards8,card[5][1])
									
								end
								res = self:find(t[i]-1,card,value)
								if res ~= -1 then
									for x = j , 2*num +j -2 -1 do
										table.insert(cards9,t[x])
										
									end
									table.insert(cards9,res)
									table.insert(cards9,card[5][1])
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

	local t_buf = {}

	table.insert(t_buf,cards1)
	table.insert(t_buf,cards2)
	table.insert(t_buf,cards3)
	table.insert(t_buf,cards4)
	table.insert(t_buf,cards5)
	table.insert(t_buf,cards6)
	table.insert(t_buf,cards7)
	table.insert(t_buf,cards8)
	table.insert(t_buf,cards9)
	table.insert(t_buf,cards10)
	table.insert(t_buf,cards11)



	if #cards1 ~= 0 then table.insert(buf,cards1) self:log("#cards1",#cards1) end
	if #cards2 ~= 0 then table.insert(buf,cards2) self:log("#cards2",#cards2) end
	if #cards3 ~= 0 then table.insert(buf,cards3) self:log("#cards3",#cards3) end
	if #cards4 ~= 0 then table.insert(buf,cards4) self:log("#cards4",#cards4) end
	if #cards5 ~= 0 then table.insert(buf,cards5) self:log("#cards5",#cards5) end
	if #cards6 ~= 0 then table.insert(buf,cards6) self:log("#cards6",#cards6) end
	if #cards7 ~= 0 then table.insert(buf,cards7) self:log("#cards7",#cards7) end
	if #cards8 ~= 0 then table.insert(buf,cards8) self:log("#cards8",#cards8) end
	if #cards9 ~= 0 then table.insert(buf,cards9) self:log("#cards9",#cards9) end
	if #cards10 ~= 0 then table.insert(buf,cards10) end
	if #cards11 ~= 0 then table.insert(buf,cards11) end
	

	

end





function GamesjLogic:find1(num,card)

	local buf = card[2]
	for i =1 , #buf do
		if i % 2 == 1 then
		if self:GetCardLogicValue(buf[i]) ~= 3 and self:GetCardLogicValue(buf[i]) ~= 15 then
			
			if self:GetCardLogicValue(buf[i]) == self:GetCardLogicValue(num) then
				return buf[i] ,buf[i+1]
			end
		end
		end
	end
	return -1,-1

end


function GamesjLogic:find(num,card,min_num)
	
	local buf = card[1]
	--gt.dump(buf)
	--print("card[1]",#buf)
	self:log("min_num",min_num)
	for i =1 , #buf do
		if self:GetCardLogicValue(buf[i]) ~= 3 and self:GetCardLogicValue(buf[i]) ~= 15 and buf[i] ~= -1 and
			self:GetCardLogicValue(buf[i]) ~= 16 and self:GetCardLogicValue(buf[i]) ~= 17 then
			self:log("min_num",min_num,self:GetCardLogicValue(buf[i]))
			if self:GetCardLogicValue(buf[i]) == self:GetCardLogicValue(num) and min_num < self:GetCardLogicValue(buf[i]) then ---GetCardLogicValue
				return buf[i]
			end
		end
	end

	return -1
end


function GamesjLogic:isLzLiandui(buf,num) --4

	local res = 0
	local idx = 0
	for i =1 ,num -2 do
		if i % 2 == 1 then
			local  n = GamesjLogic:GetCardLogicValue(buf[2][i+2]) - GamesjLogic:GetCardLogicValue(buf[2][i])
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

function GamesjLogic:isLzSunzi(buf,num)

	local res = 0
	local idx = 0
	for i =1 ,num -1 do
		local  n = GamesjLogic:GetCardLogicValue(buf[1][i+1]) - GamesjLogic:GetCardLogicValue(buf[1][i])
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

function GamesjLogic:isLzFeiji(buf,num)

	local res = 0
	local idx = 0
	for i =1 ,num -3 do -- 6 -3 = 3
		if i % 3 == 1 then
			local  n = GamesjLogic:GetCardLogicValue(buf[3][i+3]) - GamesjLogic:GetCardLogicValue(buf[3][i])
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

function GamesjLogic:isfeiji(buf,num)
	
	for i = 1, num -3 do --6
		if i % 3 == 1 then
			
			if GamesjLogic:GetCardLogicValue(buf[3][i]) + 1 == GamesjLogic:GetCardLogicValue(buf[3][i+3]) and  GamesjLogic:GetCardLogicValue(buf[3][num])<=14 then
			else
				return false
			end
			
		end
	end
	gt.log("true_____________")
	return true
end

function GamesjLogic:isfeijis(buf,num)
	
	for i = 1, num -3 do --6
		if i % 3 == 1 then
			
			if GamesjLogic:GetCardLogicValue(buf[3][i]) + 1 == GamesjLogic:GetCardLogicValue(buf[3][i+3]) and  GamesjLogic:GetCardLogicValue(buf[3][num])<=14 then
			else
				gt.log("false__________s")
				return false
			end
			
		end
	end
	gt.log("true_____________")
	return true
end

function GamesjLogic:isLiandui(buf,num)
	
	for i = 1, num -2 do
		if i % 2 == 1 then
			if GamesjLogic:GetCardLogicValue(buf[2][i]) + 1 == GamesjLogic:GetCardLogicValue(buf[2][i+2]) and  GamesjLogic:GetCardLogicValue(buf[2][num])<=14 then
			else
				return false
			end
		end
	end
	return true
end

function GamesjLogic:isShunzi(buf,num)
	
	for i =1 ,num -1 do
		if GamesjLogic:GetCardLogicValue(buf[1][i]) +1 == GamesjLogic:GetCardLogicValue(buf[1][i+1]) and  GamesjLogic:GetCardLogicValue(buf[1][i+1])<=14 then
		else
			return false
		end
	end
	return true
end

function GamesjLogic:Verification_missile(card)


	self:log("card>>>>",#card)

	if card[2] == 0x4F and card[1] == 0x4E then
        return true
    end
	if card[1] == 0x4F and card[2] == 0x4E then
       	return true
    end
    return false

end

function GamesjLogic:auto_sunzi(_cbHandCard)

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
function GamesjLogic:getMaxCardType1(_cbHandCard,_cbFirstCard,landType,isfunc) --tishi 

	
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

	local card , num = GamesjLogic:GetCardType1(cbFirstCard, #cbFirstCard,landType) -- 返回牌型 上家出的牌
 	
 	
 	local tagAnalyseResult = self:AnalysebCardData1(cbHandCard,#cbHandCard) -- 找出扑克结构选择的牌

 	if tagAnalyseResult[5][1] == 18 and #_cbHandCard  == 1 then -- 有一张牌是癞子
 		return buf
 	end

 	
 	
 	
	for key ,value in pairs(card) do 
		local bool = false	
		gt.log("key.......",key)
		if key == 100 then -- 100.... 上家没有出牌
			
			local shouPaibuf , len = GamesjLogic:GetCardType1(cbHandCard, #cbHandCard,landType) -- 返回手牌牌型 自己的牌

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
			if landType == 1 then
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
			gt.log("c____________")

			--if isfunc then 
				if tagAnalyseResult[5][1] == -1 then
					if #cbFirstCard == 5 then -- 3 dai 1
						local fj = self:sandaiyi(tagAnalyseResult)
						self:compareFeiji1(fj,value,num*3,buf,tagAnalyseResult)
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
				else
					if #cbFirstCard == 5 then -- 3 dai 1
						gt.log("s____________")
						local fj = self:sandaiyi1(tagAnalyseResult,value,num*3,buf)
						--self:compareFeiji1_s(fj,value,num*3,buf,tagAnalyseResult)
					else -- 飞机
						-- local fj, fj1 ,fj2 = self:findfj(tagAnalyseResult)

						-- gt.log("ss_______",#fj)
						-- gt.log("ss_______",#fj1)
						-- gt.log("ss_______",#fj2)
						-- if #fj >= num*3  then

						-- 	self:compareFeiji3(fj,value,num*3,buf,tagAnalyseResult)
						-- end
						-- if #fj1 >= num*3 then
						-- 	self:compareFeiji3(fj1,value,num*3,buf,tagAnalyseResult)
						-- end
						-- if #fj2 >= num*3  then
						-- 	self:compareFeiji3(fj2,value,num*3,buf,tagAnalyseResult)
						-- end
					end

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
					if tagAnalyseResult[3][i] ~= -1 then
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
					end
					if self:GetCardLogicValue(tagAnalyseResult[3][3]) == 3 then
						
						
						if landType == 3 then 
							if not isfunc then
								table.insert(buf,{tagAnalyseResult[3][1],tagAnalyseResult[3][2]})
							end
						else
						
							local colorValue = yl.POKER_COLOR[tagAnalyseResult[3][1]] + yl.POKER_COLOR[tagAnalyseResult[3][3]]
							if colorValue == 32 or colorValue == 64 then
								if not isfunc then
									table.insert(buf,{tagAnalyseResult[3][1],tagAnalyseResult[3][3]})
								end
							end
							

							local colorValue = yl.POKER_COLOR[tagAnalyseResult[3][2]] + yl.POKER_COLOR[tagAnalyseResult[3][3]]
							if colorValue == 32 or colorValue == 64 then
								table.insert(buf,{tagAnalyseResult[3][2],tagAnalyseResult[3][3]})
							end


							local colorValue = yl.POKER_COLOR[tagAnalyseResult[3][1]] + yl.POKER_COLOR[tagAnalyseResult[3][2]]
							if colorValue == 32 or colorValue == 64 then
								table.insert(buf,{tagAnalyseResult[3][2],tagAnalyseResult[3][1]})
							end

						end
						
					end
					if self:GetCardLogicValue(tagAnalyseResult[4][4]) == 3 and not isfunc then

						--if landType == 3 then 
							if not isfunc then
								table.insert(buf,{tagAnalyseResult[4][1],tagAnalyseResult[4][2]})
								table.insert(buf,{tagAnalyseResult[4][3],tagAnalyseResult[4][4]})
							end
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
						if self:GetCardLogicValue(tagAnalyseResult[4][i]) ~= 3 then
							if isfunc then
								if #_cbHandCard == 4 then
									table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3]})
								end
							else
								table.insert(buf,{tagAnalyseResult[4][i],tagAnalyseResult[4][i+1],tagAnalyseResult[4][i+2],tagAnalyseResult[4][i+3]})
							end
						end
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


function GamesjLogic:find_THREE(card,value,buf)




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


function GamesjLogic:find_THREE_LINE(fj, fj1 ,fj2,num,value,buf)

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

function GamesjLogic:compare(buf,value,num,buf1)
	
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
	  function GamesjLogic:compareFeiji1_s(buf,value,num,buf1,tagAnalyseResult,

]]

function GamesjLogic:sandaiyi1( card ,value,num,buf1)
	
	local t = {}
	--local buf = {}


	local func = function(buf)
		gt.log("buf.....csw.",#buf)
		gt.dump(buf)
		local cards = {} 
		local j = 0
		local k = 1
		local x = 1
		if card[2][2*num/3] ~= -1  then
			for i = 1, #buf do
				if i % 3 == 1 then
				if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 then
					for j = i , num + i - 1  do
						if j % 3 == 1 then
							table.insert(cards,buf[j])
							table.insert(cards,buf[j+1])
							table.insert(cards,buf[j+2])
						end
					end 
					for x = 1 , 2*num/3 do
						table.insert(cards,card[2][x])
					end
					table.insert(buf1,cards)
					cards = {}
				end 
				x = 1
				end
			end
		end 

		if card[1][1] ~= -1 and self:is(card[1][1]) and card[5][1] ~= -1 and  card[2][2*num/3-2] ~= -1 then 
			cards = {}
			for i = 1, #buf do
				if i % 3 == 1 then
				if self:GetCardLogicValue(buf[i]) > value and #buf - i >= num -1 then
					for j = i , num + i - 1  do
						if j % 3 == 1 then
							table.insert(cards,buf[j])
							table.insert(cards,buf[j+1])
							table.insert(cards,buf[j+2])
						end
					end 
					for x = 1 , 2*num/3 -2 do
						table.insert(cards,card[1][x])
					end
					table.insert(cards,card[1][1])
					table.insert(cards,card[5][1])
					table.insert(buf1,cards)
					cards = {}
				end 
				x = 1
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
		if self:GetCardLogicValue(card[2][i]) ~= 15 then  --~= 2
			table.insert(ts,card[2][i])
		end
	end
	end

	for i = 1 , #card[3] do
		if card[3][i] ~= -1 then
		if i %3 ~= 0 then
			if self:GetCardLogicValue(card[3][i]) ~= 15 then  --~= 2
				table.insert(ts,card[3][i])
			end
		end
	end
	end

	for i = 1 , #card[4] do
		if card[4][i] ~= -1 then
		if i %4 ~= 0 and  i %3 ~= 0  then
			if self:GetCardLogicValue(card[4][i]) ~= 15 then  --~= 2
				table.insert(ts,card[4][i])
			end
		end
	end
	end


	local tmp  = self:SortCardListUp(ts,#ts,0) -- 升序


	for i =1 , #tmp do
		if i % 2 == 1 then
			if self:GetCardLogicValue(tmp[i]) > value and self:is(self:GetCardLogicValue(tmp[i])) and #tmp >=4	 then  
				if i == 1 then 
					table.insert(buf1,{tmp[i],tmp[i+1],tmp[i+2],tmp[i+3],card[5][1]})
				else
					table.insert(buf1,{tmp[i],tmp[i+1],tmp[i-1],tmp[i-2],card[5][1]})
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

function GamesjLogic:sandaiyi(card)
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

function GamesjLogic:findfj(card) 

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

function GamesjLogic:compareFeiji1(buf,value,num,buf1,tagAnalyseResult)
	

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

function GamesjLogic:compareFeiji1_s(buf,value,num,buf1,tagAnalyseResult,type)
	

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

function GamesjLogic:compareFeiji2(buf,value,num,buf1,tagAnalyseResult)
	

	local card = {} 
	local j = 0
	local k = 1
	local x = 1

	local daipai = 0

	for i = 1 ,#tagAnalyseResult[2] do
		if tagAnalyseResult[2][i] == -1 then
			break
		end
		daipai = daipai + 1
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
					while k <= num/3*2 do
							table.insert(card,tagAnalyseResult[2][k])
							k = k + 1 
							
					end
					table.insert(buf1,card)
					card = {}
				end 
			k = 1
			end
		end

	end 
	-- print("buf1............."..#buf1[1])
	-- print("buf1............."..#buf1[2])

end


function GamesjLogic:compareFeiji3(buf,value,num,buf1,tagAnalyseResult)
	

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

function GamesjLogic:compareFeiji(buf,value,num,buf1,tagAnalyseResult)
	

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

function GamesjLogic:findld(card) 

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

function GamesjLogic:findShunzi(card) --ppp

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
function GamesjLogic:getMaxCardType(cbHandCard,cbFirstCard) --tishi 

	local tagAnalyseResult = self:AnalysebCardData(cbHandCard,#cbHandCard) -- 找出扑克结构
	cbFirstCard = self:SortCardListUp(cbFirstCard,#cbFirstCard,0) -- >小->大
	local cbFirstType = GamesjLogic:GetCardType(cbFirstCard, #cbFirstCard) -- 返回牌型 上家出的牌

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
	if cbFirstType == GamesjLogic.CT_MISSILE_CARD then
		return tagSearchCardResult
	end
	
	if cbFirstType == GamesjLogic.CT_BOMB_CARD then
		if tagAnalyseResult[1][4] > 0 then
			if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][4][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],4)
				cbResultCard = {tagAnalyseResult[2][4][1],tagAnalyseResult[2][4][2],tagAnalyseResult[2][4][3],tagAnalyseResult[2][4][4]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end
		end 
		if tagAnalyseResult[1][3] > 0 then
			if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
				if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) ~=  3 and 
					GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) ~= 15 then
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
		if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][4][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
			tagSearchCardResult[1] = 1
			table.insert(tagSearchCardResult[2],4)
			cbResultCard = {tagAnalyseResult[2][4][1],tagAnalyseResult[2][4][2],tagAnalyseResult[2][4][3],tagAnalyseResult[2][4][4]}
			table.insert(tagSearchCardResult[3],cbResultCard)
			return tagSearchCardResult
		end
	end 
	if tagAnalyseResult[1][3] > 0 then
		if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
			if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) ~=  3 and 
					GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) ~= 15 then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],4)
				cbResultCard = {tagAnalyseResult[2][3][1],tagAnalyseResult[2][3][2],tagAnalyseResult[2][3][3],tagAnalyseResult[2][5][1]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end 
		end
	end
	
	if cbFirstType == GamesjLogic.CT_THREE_TAKE_ONE then
		if tagAnalyseResult[1][2] > 0 then
			if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][2][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
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
	elseif cbFirstType == GamesjLogic.CT_DOUBLE_LINE then
		if (tagAnalyseResult[1][2]+1)*2 >= #cbFirstCard then
			return tagSearchCardResult
		end
	elseif cbFirstType == GamesjLogic.CT_SINGLE_LINE then
		return tagSearchCardResult
	elseif cbFirstType == GamesjLogic.CT_DOUBLE then
		if tagAnalyseResult[1][2] > 0 then
			if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][2][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],2)
				cbResultCard = {tagAnalyseResult[2][2][1],tagAnalyseResult[2][2][2]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end
		end 
		if tagAnalyseResult[1][1] > 0 then
			if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][1][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],2)
				cbResultCard = {tagAnalyseResult[2][1][1],tagAnalyseResult[2][5][1]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end
		end 
		if tagAnalyseResult[1][3] > 0 then
			if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],2)
				cbResultCard = {tagAnalyseResult[2][3][1],tagAnalyseResult[2][3][2]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end
		end 
	elseif cbFirstType == GamesjLogic.CT_SINGLE then
		if tagAnalyseResult[1][1] > 0 then
			if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][1][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
				tagSearchCardResult[1] = 1
				table.insert(tagSearchCardResult[2],1)
				cbResultCard = {tagAnalyseResult[2][1][1]}
				table.insert(tagSearchCardResult[3],cbResultCard)
				return tagSearchCardResult
			end
			if tagAnalyseResult[1][2] > 0 then
				if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][2][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
					tagSearchCardResult[1] = 1
					table.insert(tagSearchCardResult[2],1)
					cbResultCard = {tagAnalyseResult[2][2][1]}
					table.insert(tagSearchCardResult[3],cbResultCard)
					return tagSearchCardResult
				end
			end 
			if tagAnalyseResult[1][3] > 0 then
				if GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][3][1]) > GamesjLogic:GetCardLogicValue(cbFirstCard[1]) then
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
function GamesjLogic:CompareCard1(cbFirstCard,cbHandCard,landType)

	if cbHandCard and #cbHandCard == 2 then
		if self:GetCardLogicValue(cbHandCard[2]) + self:GetCardLogicValue(cbHandCard[1]) == 33 and 
			math.abs(self:GetCardLogicValue(cbHandCard[2]) - self:GetCardLogicValue(cbHandCard[1]))==1 then
			return 1
		end
	end

	--print("CompareCard1...............")
	local buf = self:getMaxCardType1(cbHandCard,cbFirstCard,landType,true)

	gt.log("#buf............s",#buf,#cbHandCard)
	if #buf == 1 then
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

--»ñÈ¡ÀàÐÍ
function GamesjLogic:GetCardType(cbCardData, cbCardCount,cardNum) --aaa
    --¼òµ¥ÅÆÐÍ
    if cbCardCount == 0 then        --¿ÕÅÆ
        return GamesjLogic.CT_ERROR
    elseif cbCardCount == 1 then    --µ¥ÅÆ
		if cbCardData[1] == 0x43 then
			return GamesjLogic.CT_ERROR
		end 
        return GamesjLogic.CT_SINGLE
    elseif cbCardCount == 2 then    --¶ÔÅÆ»ð¼ý
        if cbCardData[2] == 0x4F and cbCardData[1] == 0x4E then
            return GamesjLogic.CT_MISSILE_CARD
        end
		if cbCardData[1] == 0x4F and cbCardData[2] == 0x4E then
            return GamesjLogic.CT_MISSILE_CARD
        end
		if GamesjLogic:GetCardLogicValue(cbCardData[1]) == 18 then
			if cbCardData[2] == 0x4F or cbCardData[2] == 0x4E or GamesjLogic:GetCardLogicValue(cbCardData[2]) == 15 or 
				GamesjLogic:GetCardLogicValue(cbCardData[2]) == 3 then
				return GamesjLogic.CT_ERROR
			end
		end 
		if GamesjLogic:GetCardLogicValue(cbCardData[2]) == 18 then
			if cbCardData[1] == 0x4F or cbCardData[1] == 0x4E or GamesjLogic:GetCardLogicValue(cbCardData[1]) == 15 then
				return GamesjLogic.CT_ERROR
			end
		end 
        if GamesjLogic:GetCardLogicValue(cbCardData[1]) == GamesjLogic:GetCardLogicValue(cbCardData[2]) then
			if GamesjLogic:GetCardLogicValue(cbCardData[1]) == 3 then
				local colorValue = yl.POKER_COLOR[cbCardData[1]] + yl.POKER_COLOR[cbCardData[2]]
				if colorValue == 32 or colorValue == 64 then
					return GamesjLogic.CT_BOMB_CARD
				end
			end
            return GamesjLogic.CT_DOUBLE
        end
		if GamesjLogic:GetCardLogicValue(cbCardData[1]) == 18 or  GamesjLogic:GetCardLogicValue(cbCardData[2]) == 18 then
            return GamesjLogic.CT_DOUBLE
        end
    elseif cbCardCount == 3 then    --3ÕÅ
    	if GamesjLogic:GetCardLogicValue(cbCardData[1]) == 3 then
    		return GamesjLogic.CT_ERROR
    	end
    	local tagAnalyseResult = {}
   		tagAnalyseResult = GamesjLogic:AnalysebCardData1(cbCardData, cbCardCount)
   		if tagAnalyseResult[5][1] ~= -1 then

   			if tagAnalyseResult[2][2] == -1 then
   				return GamesjLogic.CT_ERROR
   			else
   				if cardNum and cardNum == 3 then
   					return GamesjLogic.CT_THREE
   				else
   					return GamesjLogic.CT_ERROR
   				end
   			end

   		else

	    	if GamesjLogic:GetCardLogicValue(cbCardData[1]) == GamesjLogic:GetCardLogicValue(cbCardData[2]) and
	    		 GamesjLogic:GetCardLogicValue(cbCardData[1]) == GamesjLogic:GetCardLogicValue(cbCardData[3])  and
	    		cardNum and cardNum == 3 then
	    		 return GamesjLogic.CT_THREE
	    	else
	    		 return GamesjLogic.CT_ERROR
	    	end
	    	return GamesjLogic.CT_ERROR
	    end
    end


    local tagAnalyseResult = {}
    tagAnalyseResult = GamesjLogic:AnalysebCardData(cbCardData, cbCardCount)
    --ËÄÅÆÅÐ¶Ï
    if tagAnalyseResult[1][4] > 0 then
		for i,v in ipairs(tagAnalyseResult[2][4]) do
			if GamesjLogic:GetCardLogicValue(v) == 3 then
				return GamesjLogic.CT_ERROR
			end
		end 
        if tagAnalyseResult[1][4] == 1 and cbCardCount == 4 then
            return GamesjLogic.CT_BOMB_CARD
        end
        if tagAnalyseResult[1][4] == 1 and cbCardCount == 6 then
            return GamesjLogic.CT_FOUR_TAKE_ONE
        end
        if tagAnalyseResult[1][4] == 1 and cbCardCount == 8 then
            return GamesjLogic.CT_ERROR
        end
        return GamesjLogic.CT_ERROR
    end
	--ÓÐñ®×ÓµÄÈýÅÆ
	if tagAnalyseResult[1][5] > 0  then--Ä¬ÈÏÖ»ÓÐÒ»¸öñ®×ÓµÄËã·¨Âß¼­
		if tagAnalyseResult[1][3] > 0 then 
			if tagAnalyseResult[1][3] == 1 and cbCardCount == 4 then
				local cbCard = tagAnalyseResult[2][3][1]
				if GamesjLogic:GetCardLogicValue(cbCard) == 3 then
					return GamesjLogic.CT_THREE_TAKE_ONE
				end
				if GamesjLogic:GetCardLogicValue(cbCard) == 15 then
					return GamesjLogic.CT_ERROR
				end
				return GamesjLogic.CT_BOMB_CARD
			end
			if tagAnalyseResult[1][3] == 1 and cbCardCount == 6 then
				return GamesjLogic.CT_FOUR_TAKE_ONE
			end
			
			local tempCardList = {}
			for k,v in ipairs(tagAnalyseResult[2][2]) do
				if GamesjLogic:GetCardLogicValue(v) ~= 15  then
					table.insert(tempCardList,v)
				end 
			end
			
			for k,v in ipairs(tagAnalyseResult[2][3]) do
				if GamesjLogic:GetCardLogicValue(v) ~= 15 then
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
				local last = GamesjLogic:GetCardLogicValue(sortList[i])
				local pre = GamesjLogic:GetCardLogicValue(sortList[i+1])
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
					return GamesjLogic.CT_ERROR
				end 
				local tempValue = (tagAnalyseResult[1][2]-1)*2 + tagAnalyseResult[1][1] +(tagAnalyseResult[1][3] -threeCount)*3
				if threeCount +1 == (tagAnalyseResult[1][2]-1)*2 + tagAnalyseResult[1][1] +
					(tagAnalyseResult[1][3] -threeCount)*3 then
					return GamesjLogic.CT_THREE_TAKE_ONE
				end
			end
						
			return GamesjLogic.CT_ERROR
		end
	end 
    --ÈýÅÆÅÐ¶Ï
    if tagAnalyseResult[1][3] > 0 then
        if tagAnalyseResult[1][3] > 1 then
            local cbCard = tagAnalyseResult[2][3][1]
            local cbFirstLogicValue = GamesjLogic:GetCardLogicValue(cbCard)
            if cbFirstLogicValue >= 15 then
                return GamesjLogic.CT_ERROR
            end
            for i=2,tagAnalyseResult[1][3] do
                local cbCard = tagAnalyseResult[2][3][(i-1)*3+1]
                local cbNextLogicValue = GamesjLogic:GetCardLogicValue(cbCard)
                if cbFirstLogicValue ~= cbNextLogicValue+i-1 then
                    return GamesjLogic.CT_ERROR
                end
            end
        elseif cbCardCount == 3 then
            return GamesjLogic.CT_THREE
        end
        if tagAnalyseResult[1][3]*3 == cbCardCount then
           return GamesjLogic.CT_THREE_LINE
        end
        if tagAnalyseResult[1][3]*4 == cbCardCount then
           return GamesjLogic.CT_THREE_TAKE_ONE
        end
        if tagAnalyseResult[1][3]*5 == cbCardCount  and tagAnalyseResult[1][2] == tagAnalyseResult[1][3] then
           return GamesjLogic.CT_ERROR
        end
        return GamesjLogic.CT_ERROR
    end
	
	--Á½ÕÅñ®×ÓËã·¨
	if tagAnalyseResult[1][5] > 0  then--Ä¬ÈÏÖ»ÓÐÒ»¸öñ®×ÓµÄËã·¨Âß¼­
		if tagAnalyseResult[1][2] > 0 then
			if tagAnalyseResult[1][2] == 1 and cbCardCount == 3 then
				return GamesjLogic.CT_THREE
			end
			if tagAnalyseResult[1][2] == 1 and cbCardCount == 4 then
				return GamesjLogic.CT_THREE_TAKE_ONE
			end
			
			if tagAnalyseResult[1][2] >= 2 then
				local tempCardList = {}
				for k,v in ipairs(tagAnalyseResult[2][2]) do
					if GamesjLogic:GetCardLogicValue(v) ~= 15  then
						table.insert(tempCardList,v)
					end 
				end
				
				for k,v in ipairs(tagAnalyseResult[2][1]) do
					if GamesjLogic:GetCardLogicValue(v) ~= 15 then
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
					local last = GamesjLogic:GetCardLogicValue(sortList[i])
					local pre = GamesjLogic:GetCardLogicValue(sortList[i+1])
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
						return GamesjLogic.CT_DOUBLE_LINE
					end 
				end
			end
		end 
	end 
	
    --Á½ÕÅÅÐ¶Ï
    if tagAnalyseResult[1][2] >= 3 then
        local cbCard = tagAnalyseResult[2][2][1]
        local cbFirstLogicValue = GamesjLogic:GetCardLogicValue(cbCard)
        if cbFirstLogicValue >= 15 then
            return GamesjLogic.CT_ERROR
        end
        for i=2,tagAnalyseResult[1][2] do
            local cbCard = tagAnalyseResult[2][2][(i-1)*2+1]
            local cbNextLogicValue = GamesjLogic:GetCardLogicValue(cbCard)
            if cbFirstLogicValue ~= cbNextLogicValue+i-1 then
                return GamesjLogic.CT_ERROR
            end
        end
        if tagAnalyseResult[1][2]*2 == cbCardCount then
            return GamesjLogic.CT_DOUBLE_LINE
        end
        return GamesjLogic.CT_ERROR
    end
    --µ¥ÕÅÅÐ¶Ï
    if tagAnalyseResult[1][1] >= 5 and tagAnalyseResult[1][1] == cbCardCount then
        local cbCard = tagAnalyseResult[2][1][1]
        local cbFirstLogicValue = GamesjLogic:GetCardLogicValue(cbCard)
        if cbFirstLogicValue >= 15 then
            return GamesjLogic.CT_ERROR
        end
        for i=2,tagAnalyseResult[1][1] do
            local cbCard = tagAnalyseResult[2][1][i]
            local cbNextLogicValue = GamesjLogic:GetCardLogicValue(cbCard)
            if cbFirstLogicValue ~= cbNextLogicValue+i-1 then
                return GamesjLogic.CT_ERROR
            end
        end
        return GamesjLogic.CT_SINGLE_LINE
    end
	
	--ñ®×Óµ¥ÅÆ
	local tempCount = 0
	if tagAnalyseResult[1][5] > 0  then--Ä¬ÈÏÖ»ÓÐÒ»¸öñ®×ÓµÄËã·¨Âß¼­
		if tagAnalyseResult[1][1] >= 4 and  tagAnalyseResult[1][1] +1 == cbCardCount then
			local cbCard = tagAnalyseResult[2][1][1]
			local cbFirstLogicValue = GamesjLogic:GetCardLogicValue(cbCard)
			if cbFirstLogicValue >= 15 then
				return GamesjLogic.CT_ERROR
			end
			for i=2,tagAnalyseResult[1][1] do
				local cbCard = tagAnalyseResult[2][1][i]
				local cbNextLogicValue = GamesjLogic:GetCardLogicValue(cbCard)
				if cbFirstLogicValue ~= cbNextLogicValue+i-1 + tempCount then
					if cbFirstLogicValue == cbNextLogicValue+i  and tempCount < 1 then
						tempCount = tempCount +1
					else
						return GamesjLogic.CT_ERROR
					end 
				end
			end
			return GamesjLogic.CT_SINGLE_LINE
		end
	end 

	if cbCardCount == 6 then
		if GamesjLogic:GetCardLogicValue(cbCardData[1]) == 3 then
    		return GamesjLogic.CT_ERROR
    	end
    	local tagAnalyseResult = {}
   		tagAnalyseResult = GamesjLogic:AnalysebCardData1(cbCardData, cbCardCount)
   		if tagAnalyseResult[5][1] ~= -1 then
   			if tagAnalyseResult[3][3] == -1 or  tagAnalyseResult[2][2] == -1 then
   				return GamesjLogic.CT_ERROR
   			else
   				if cardNum and cardNum == 6 then
   					return GamesjLogic.CT_THREE_LINE
   				else
   					return GamesjLogic.CT_ERROR
   				end
   			end
   		else
    		if GamesjLogic:GetCardLogicValue(cbCardData[1]) == GamesjLogic:GetCardLogicValue(cbCardData[2]) and
    		 GamesjLogic:GetCardLogicValue(cbCardData[1]) == GamesjLogic:GetCardLogicValue(cbCardData[3])  and
    		 GamesjLogic:GetCardLogicValue(cbCardData[4]) == GamesjLogic:GetCardLogicValue(cbCardData[5])  and 
    		  GamesjLogic:GetCardLogicValue(cbCardData[4]) == GamesjLogic:GetCardLogicValue(cbCardData[6]) and 
    		  math.abs(GamesjLogic:GetCardLogicValue(cbCardData[1]) -GamesjLogic:GetCardLogicValue(cbCardData[4])) == 1 and
    		cardNum and cardNum == 6 then
    		 return GamesjLogic.CT_THREE_LINE
    		else
    			return GamesjLogic.CT_ERROR
    		end

    	end
    elseif cbCardCount == 9 then
    	if GamesjLogic:GetCardLogicValue(cbCardData[1]) == 3 then
    		return GamesjLogic.CT_ERROR
    	end
    	local tagAnalyseResult = {}
   		tagAnalyseResult = GamesjLogic:AnalysebCardData1(cbCardData, cbCardCount)
   		if tagAnalyseResult[5][1] ~= -1 then
   			if tagAnalyseResult[3][6] == -1 or  tagAnalyseResult[2][2] == -1 then
   				return GamesjLogic.CT_ERROR
   			else
   				local buf = {GamesjLogic:GetCardLogicValue(tagAnalyseResult[3][6]) , GamesjLogic:GetCardLogicValue(tagAnalyseResult[3][3]),GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][2])}
   				local cards = GamesjLogic:paixun(buf)
   				if cards[1] + 1 == cards[2] and cards[1] + 2 == cards[3] then
	   				if cardNum and cardNum == 9 then
	   					return GamesjLogic.CT_THREE_LINE
	   				else
	   					return GamesjLogic.CT_ERROR
	   				end
   				else
   					return GamesjLogic.CT_ERROR
   				end
   			end
   		else
   			if tagAnalyseResult[3][9] == -1 then 
   				return GamesjLogic.CT_THREE_LINE
   			else
   			    if GamesjLogic:GetCardLogicValue(tagAnalyseResult[3][9]) -1 ==GamesjLogic:GetCardLogicValue(tagAnalyseResult[3][6]) and
   			    	GamesjLogic:GetCardLogicValue(tagAnalyseResult[3][9]) -2 == GamesjLogic:GetCardLogicValue(tagAnalyseResult[3][3]) then

   			    	if cardNum and cardNum == 9 then
   			    		return GamesjLogic.CT_THREE_LINE
   			    	else
   			    		return GamesjLogic.CT_ERROR
   			    	end
   			    else
   			    	return GamesjLogic.CT_ERROR
   			    end
   			end
   		end
    elseif cbCardCount == 12 then

    elseif cbCardCount == 15 then

    end
    return GamesjLogic.CT_ERROR
end

function GamesjLogic:paixun(buf)
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
function GamesjLogic:SearchOutCard(cbHandCardData,cbHandCardCount,cbTurnCardData,cbTurnCardCount) 
    -- print("³öÅÆËÑË÷")
    -- for i=1,cbTurnCardCount do
    --     print("Ç°¼ÒÆË¿Ë " .. GamesjLogic:GetCardLogicValue(cbTurnCardData[i]))
    -- end
    -- for i=1,cbHandCardCount do
    --     print("ÏÂ¼ÒÆË¿Ë " .. GamesjLogic:GetCardLogicValue(cbHandCardData[i]))
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
    local cbCardData = GamesjLogic:SortCardList(cbHandCardData, cbHandCardCount, 0)
    local cbCardCount = cbHandCardCount
    --³öÅÆ·ÖÎö
    local cbTurnOutType = GamesjLogic:GetCardType(cbTurnCardData, cbTurnCardCount) -- 分析 上轮 牌型
    if cbTurnOutType == GamesjLogic.CT_ERROR then --´牌型错误
        --print("ÉÏ¼ÒÎª¿Õ")
        --ÊÇ·ñÒ»ÊÖ³öÍê
        if GamesjLogic:GetCardType(cbCardData, cbCardCount) ~= GamesjLogic.CT_ERROR  then
            cbResultCardCount[cbResultCount] = cbCardCount
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount] = cbCardData
            cbResultCount = cbResultCount+1
            tagSearchCardResult[2] = cbResultCardCount
            tagSearchCardResult[3] = cbResultCard
        end
        --Èç¹û×îÐ¡ÅÆ²»ÊÇµ¥ÅÆ£¬ÔòÌáÈ¡
        local cbSameCount = 1
        if cbCardCount > 1 and (GamesjLogic:GetCardLogicValue(cbCardData[cbCardCount]) == GamesjLogic:GetCardLogicValue(cbCardData[cbCardCount-1])) then
            cbSameCount = 2
            cbResultCard[cbResultCount] = {}
            cbResultCard[cbResultCount][1] = cbCardData[cbCardCount]
            local cbCardValue = GamesjLogic:GetCardLogicValue(cbCardData[cbCardCount])
            local i = cbCardCount - 1
            while i >= 1 do
                if GamesjLogic:GetCardLogicValue(cbCardData[i]) == cbCardValue then
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
            local tagSearchCardResult1 = GamesjLogic:SearchSameCard(cbCardData, cbCardCount, 0, 1)
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
            local tagSearchCardResult1 = GamesjLogic:SearchSameCard(cbCardData, cbCardCount, 0, 2)
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
            local tagSearchCardResult1 = GamesjLogic:SearchSameCard(cbCardData, cbCardCount, 0, 3)
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
        local tagSearchCardResult2 = GamesjLogic:SearchTakeCardType(cbCardData, cbCardCount, 0, 3, 1)
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
        local tagSearchCardResult3 = GamesjLogic:SearchTakeCardType(cbCardData, cbCardCount, 0, 3, 2)
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
        local tagSearchCardResult4 = GamesjLogic:SearchLineCardType(cbCardData, cbCardCount, 0, 1, 0)
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
        local tagSearchCardResult5 = GamesjLogic:SearchLineCardType(cbCardData, cbCardCount, 0, 2, 0)
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
        local tagSearchCardResult6 = GamesjLogic:SearchLineCardType(cbCardData, cbCardCount, 0, 3, 0)
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
        local tagSearchCardResult7 = GamesjLogic:SearchThreeTwoLine(cbCardData, cbCardCount)
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
            local tagSearchCardResult1 = GamesjLogic:SearchSameCard(cbCardData, cbCardCount, 0, 4)
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
    elseif cbTurnOutType == GamesjLogic.CT_SINGLE or cbTurnOutType == GamesjLogic.CT_DOUBLE or cbTurnOutType == GamesjLogic.CT_THREE then
        --单牌、对牌、三条
        local cbReferCard = cbTurnCardData[1]
        local cbSameCount = 1
        if cbTurnOutType == GamesjLogic.CT_DOUBLE then
            cbSameCount = 2
        elseif cbTurnOutType == GamesjLogic.CT_THREE then
            cbSameCount = 3
        end
        local tagSearchCardResult21 = GamesjLogic:SearchSameCard(cbCardData, cbCardCount, cbReferCard, cbSameCount)
        cbResultCount = tagSearchCardResult21[1]
        cbResultCount = cbResultCount + 1 
        cbResultCardCount = tagSearchCardResult21[2]
        tagSearchCardResult[2] = cbResultCardCount
        cbResultCard = tagSearchCardResult21[3]
        tagSearchCardResult[3] = cbResultCard
        tagSearchCardResult[1] = cbResultCount - 1 
		

    elseif cbTurnOutType == GamesjLogic.CT_SINGLE_LINE or cbTurnOutType == GamesjLogic.CT_DOUBLE_LINE or cbTurnOutType == GamesjLogic.CT_THREE_LINE then
        --µ¥Á¬¡¢¶ÔÁ¬¡¢ÈýÁ¬
        local cbBlockCount = 1
        if cbTurnOutType == GamesjLogic.CT_DOUBLE_LINE then
            cbBlockCount = 2
        elseif cbTurnOutType == GamesjLogic.CT_THREE_LINE then
            cbBlockCount = 3
        end
        local cbLineCount = cbTurnCardCount/cbBlockCount
        local tagSearchCardResult31 = GamesjLogic:SearchLineCardType(cbCardData, cbCardCount, cbTurnCardData[1], cbBlockCount, cbLineCount)
        cbResultCount = tagSearchCardResult31[1]
        cbResultCount = cbResultCount + 1
        cbResultCardCount = tagSearchCardResult31[2]
        tagSearchCardResult[2] = cbResultCardCount
        cbResultCard = tagSearchCardResult31[3]
        tagSearchCardResult[3] = cbResultCard
        tagSearchCardResult[1] = cbResultCount - 1

    elseif cbTurnOutType == GamesjLogic.CT_THREE_TAKE_ONE or cbTurnOutType == GamesjLogic.CT_THREE_TAKE_TWO then
        --Èý´øÒ»µ¥¡¢Èý´øÒ»¶Ô
        if cbCardCount >= cbTurnCardCount then
            if cbTurnCardCount == 4 or cbTurnCardCount == 5 then
                local cbTakeCardCount = (cbTurnOutType == GamesjLogic.CT_THREE_TAKE_ONE) and 1 or 2
                local tagSearchCardResult41 = GamesjLogic:SearchTakeCardType(cbCardData, cbCardCount, cbTurnCardData[3], 3, cbTakeCardCount)
                cbResultCount = tagSearchCardResult41[1]
                cbResultCount = cbResultCount + 1
                cbResultCardCount = tagSearchCardResult41[2]
                tagSearchCardResult[2] = cbResultCardCount
                cbResultCard = tagSearchCardResult41[3]
                tagSearchCardResult[3] = cbResultCard
                tagSearchCardResult[1] = cbResultCount - 1
            else
                local cbBlockCount = 3
                local cbLineCount = cbTurnCardCount/(cbTurnOutType==GamesjLogic.CT_THREE_TAKE_ONE and 4 or 5)
                local cbTakeCardCount = cbTurnOutType==GamesjLogic.CT_THREE_TAKE_ONE and 1 or 2

                --ËÑË÷Á¬ÅÆ
                local cbTmpTurnCard = cbTurnCardData
                cbTmpTurnCard = GamesjLogic:SortOutCardList(cbTmpTurnCard,cbTurnCardCount)
                local tmpSearchResult = GamesjLogic:SearchLineCardType(cbCardData,cbCardCount,cbTmpTurnCard[1],cbBlockCount,cbLineCount)
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
                    local removeResult = GamesjLogic:RemoveCard(tmpSearchResult[3][cbResultIndex],tmpSearchResult[2][cbResultIndex],cbTmpCardData,cbTmpCardCount)
                    cbTmpCardData = removeResult[2]
                    cbTmpCardCount = cbTmpCardCount - tmpSearchResult[2][cbResultIndex]
                    --·ÖÎöÅÆ
                    local TmpResult = GamesjLogic:AnalysebCardData(cbTmpCardData,cbTmpCardCount)
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

    elseif cbTurnOutType == GamesjLogic.CT_FOUR_TAKE_ONE or cbTurnOutType == GamesjLogic.CT_FOUR_TAKE_TWO then
        --ËÄ´øÁ½µ¥¡¢ËÄ´øÁ½Ë«
        local cbTakeCardCount = (cbTurnOutType == GamesjLogic.CT_FOUR_TAKE_ONE) and 1 or 2
        local cbTmpTurnCard = GamesjLogic:SortOutCardList(cbTurnCardData,cbTurnCardCount)
        local tagSearchCardResult51 = GamesjLogic:SearchTakeCardType(cbCardData, cbCardCount, cbTmpTurnCard[1], 4, cbTakeCardCount)
        cbResultCount = tagSearchCardResult51[1]
        cbResultCount = cbResultCount + 1
        cbResultCardCount = tagSearchCardResult51[2]
        tagSearchCardResult[2] = cbResultCardCount
        cbResultCard = tagSearchCardResult51[3]
        tagSearchCardResult[3] = cbResultCard
        tagSearchCardResult[1] = cbResultCount - 1
    end

    --ËÑË÷Õ¨µ¯
    if (cbCardCount >= 4 and cbTurnOutType ~= GamesjLogic.CT_MISSILE_CARD) then
        local cbReferCard = 0
        if cbTurnOutType == GamesjLogic.CT_BOMB_CARD then
            cbReferCard = cbTurnCardData[1]
        end
        --ËÑË÷Õ¨µ¯
        local tagSearchCardResult61 = GamesjLogic:SearchSameCard(cbCardData,cbCardCount,cbReferCard,4)
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
    if (cbTurnOutType ~= GamesjLogic.CT_MISSILE_CARD) and (cbCardCount >= 2) and (cbCardData[1]==0x4F and cbCardData[2]==0x4E) then
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
function GamesjLogic:SearchSameCard(cbHandCardData, cbHandCardCount, cbReferCard, cbSameCardCount)
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
    local cbCardData = GamesjLogic:SortCardList(cbHandCardData, cbHandCardCount, 0)
    local cbCardCount = cbHandCardCount
    --·ÖÎö½á¹¹
    local tagAnalyseResult = GamesjLogic:AnalysebCardData(cbCardData, cbCardCount)
    --dump(tagAnalyseResult, "tagAnalyseResult", 6)
    local cbReferLogicValue = (cbReferCard == 0 and 0 or GamesjLogic:GetCardLogicValue(cbReferCard))
    local cbBlockIndex = cbSameCardCount
    while cbBlockIndex <= 4 do
        for i=1,tagAnalyseResult[1][cbBlockIndex] do
            local cbIndex = (tagAnalyseResult[1][cbBlockIndex]-i)*cbBlockIndex+1
            local cbNowLogicValue = GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][cbBlockIndex][cbIndex])
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
function GamesjLogic:SearchTakeCardType(cbHandCardData, cbHandCardCount, cbReferCard, cbSameCount, cbTakeCardCount)
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
    local cbCardData = GamesjLogic:SortCardList(cbHandCardData, cbHandCardCount, 0)
    local cbCardCount = cbHandCardCount
    
    local sameCardResult = {}
    sameCardResult = GamesjLogic:SearchSameCard(cbCardData, cbCardCount, cbReferCard, cbSameCount)
    local cbSameCardResultCount = sameCardResult[1]

    if cbSameCardResultCount > 0 then
        --·ÖÎö½á¹¹
        local tagAnalyseResult = GamesjLogic:AnalysebCardData(cbCardData, cbCardCount)
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
                    if GamesjLogic:GetCardLogicValue(sameCardResult[3][i][1]) ~= GamesjLogic:GetCardLogicValue(tagAnalyseResult[2][j][cbIndex]) then
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
function GamesjLogic:SearchLineCardType(cbHandCardData, cbHandCardCount, cbReferCard, cbBlockCount, cbLineCount)
    --½á¹ûÊýÄ¿
    local cbResultCount = 1
    --ÆË¿ËÊýÄ¿
    local cbResultCardCount = {}
    --½á¹ûÆË¿Ë
    local cbResultCard = {}
    --ËÑË÷½á¹û
    local tagSearchCardResult = {cbResultCount-1,cbResultCardCount,cbResultCard}
    --ÅÅÐòÆË¿Ë
    local cbCardData = GamesjLogic:SortCardList(cbHandCardData, cbHandCardCount, 0)
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
        if (GamesjLogic:GetCardLogicValue(cbReferCard)-cbLessLineCount) >= 2 then
            cbReferIndex = GamesjLogic:GetCardLogicValue(cbReferCard)-cbLessLineCount+1+1
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
    local Distributing = GamesjLogic:AnalysebDistributing(cbCardData, cbCardCount)
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
                            cbResultCard[cbResultCount][cbCount] = GamesjLogic:MakeCardData(cbIndex,5-cbColorIndex-1)
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
                        cbResultCard[cbResultCount][cbCount] = GamesjLogic:MakeCardData(cbIndex,5-cbColorIndex-1)
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
                        cbResultCard[cbResultCount][cbCount] = GamesjLogic:MakeCardData(1,5-cbColorIndex-1)
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
function GamesjLogic:SearchThreeTwoLine(cbHandCardData, cbHandCardCount)
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
    local cbCardData = GamesjLogic:SortCardList(cbHandCardData, cbHandCardCount, 0)
    local cbCardCount = cbHandCardCount

    local cbTmpResultCount = 0

    --ËÑË÷Á¬ÅÆ
    local tmpSearchResult = GamesjLogic:SearchLineCardType(cbHandCardData,cbHandCardCount,0,3,0)
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
                    local removeResult= GamesjLogic:RemoveCard(tmpSearchResult[3][i],cbNeedDelCount,tmpSearchResult[3][i],tmpSearchResult[2][i])
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
                local removeResult1= GamesjLogic:RemoveCard(tmpSearchResult[3][i],tmpSearchResult[2][i],cbTmpCardData,cbTmpCardCount)
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
                        local removeResult= GamesjLogic:RemoveCard(tmpSearchResult[3][i],cbNeedDelCount,tmpSearchResult[3][i],tmpSearchResult[2][i])
                        tmpSearchResult[3][i] = removeResult[2]
                        tmpSearchResult[2][i] = tmpSearchResult[2][i] - cbNeedDelCount

                        --ÖØÐÂÉ¾³ýÁ¬ÅÆ
                        for temp=1,#cbHandCardData do
                            cbTmpCardData[temp] = cbHandCardData[temp]
                        end
                        local removeResult2= GamesjLogic:RemoveCard(tmpSearchResult[3][i],tmpSearchResult[2][i],cbTmpCardData,cbTmpCardCount)
                        cbTmpCardData = removeResult2[2]
                        cbTmpCardCount = cbTmpCardCount - tmpSearchResult[2][i]
                    end
                end
                if flag2 == true then
                    flag2 = false
                    --·ÖÎöÅÆ
                    local TmpResult = {}
                    TmpResult = GamesjLogic:AnalysebCardData(cbTmpCardData, cbTmpCardCount)
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
function GamesjLogic:AnalysebDistributing(cbCardData, cbCardCount)
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
            local cbCardColor = GamesjLogic:GetCardColor(cbCardData[i])
            local cbCardValue = GamesjLogic:GetCardValue(cbCardData[i])
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
function GamesjLogic:MakeCardData(cbValueIndex,cbColorIndex)
    --print("¹¹ÔìÆË¿Ë " ..bit:_or(bit:_lshift(cbColorIndex,4),cbValueIndex)..",".. GamesjLogic:GetCardLogicValue(bit:_or(bit:_lshift(cbColorIndex,4),cbValueIndex)))
    return bit:_or(bit:_lshift(cbColorIndex,4),cbValueIndex)
end

---É¾³ýÆË¿Ë
function GamesjLogic:RemoveCard(cbRemoveCard, cbRemoveCount, cbCardData, cbCardCount)
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
function GamesjLogic:SortOutCardList(cbCardData,cbCardCount)
    local resultCardData = {}
    local resultCardCount = 0
    --»ñÈ¡ÅÆÐÍ
    local cbCardType = GamesjLogic:GetCardType(cbCardData,cbCardCount)
    if cbCardType == GamesjLogic.CT_THREE_TAKE_ONE or cbCardType == GamesjLogic.CT_THREE_TAKE_TWO then
        --·ÖÎöÅÆ
        local AnalyseResult = {}
        AnalyseResult = GamesjLogic:AnalysebCardData(cbCardData,cbCardCount)

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
       
    elseif cbCardType == GamesjLogic.CT_FOUR_TAKE_ONE or cbCardType == GamesjLogic.CT_FOUR_TAKE_TWO then
        --·ÖÎöÅÆ
        local AnalyseResult = {}
        AnalyseResult = GamesjLogic:AnalysebCardData(cbCardData,cbCardCount)

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


return GamesjLogic