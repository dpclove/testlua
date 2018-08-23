
local gt = cc.exports.gt

local Utils = require("client/tools/Utils")
require("client/config/MJRules")

local PlayManager = class("PlayManager")

-- shuffle洗牌，cut切牌，deal发牌，sort理牌，draw摸牌，play打出，discard弃牌
-- local mjTilePerLine = 6

PlayManager.positionTip = {
    --东，南，西，北
    positionTip1 = { x = 122, y = 40},
    positionTip2 = { x = 187, y = 79},
    positionTip3 = { x = 122, y = 127},
    positionTip4 = { x = 51, y = 79},
}

local mjTilePerLine = {}

function PlayManager:ctor(rootNode, paramTbl)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("images/changshamjbtn.plist")
	gt.log("录像消息 ============ ")
	gt.dump(paramTbl)
	
	self.rootNode = rootNode
    -- local turnbg=gt.seekNodeByName(self.rootNode,"Spr_turnPosBg")
    -- turnbg:setVisible(false)
	-- 房间号
	self.roomID = paramTbl.roomID
    self.gameMark=true
    self.isHZLZ = false
	-- 玩法类型
	self.playType = paramTbl.m_state
	gt.log("玩法类型："..self.playType)

	self.createType = 1
	if self.playType == 100001 then
		self.createType = 1
		self.numPlayer = 4
	elseif self.playType == 100002 then
		self.createType = 2
		self.numPlayer = 4
	elseif self.playType == 100004 then
		self.createType = 3
		self.numPlayer = 4
	elseif self.playType == 100005 then
		self.createType = 4
		self.numPlayer = 4
	elseif self.playType == 100003 then
		self.createType = 5
		self.numPlayer = 4
	elseif self.playType == 100006 then
		self.createType = 6
		self.numPlayer = 3
	elseif self.playType == 100008 then
		self.createType = 7
		self.numPlayer = 4
	elseif self.playType == 100009 then
		self.createType = 8
		self.numPlayer = 4
	elseif self.playType == 100010 then
		self.createType = 9
		self.numPlayer = 4
	elseif self.playType == 100012 then
		self.createType = 10
		self.numPlayer = 2
	elseif self.playType == 100013 then
		self.createType = 11
		self.numPlayer = 3
	elseif self.playType == 100014 then
		self.createType = 12
		self.numPlayer = 2
	elseif self.playType == 100015 then
		self.createType = 13
		self.numPlayer = 3
	elseif self.playType == 102005 then
		self.createType = 14
		self.numPlayer = 2
	elseif self.playType == 103005 then
		self.createType = 15
		self.numPlayer = 3
	elseif self.playType == 102008 then
		self.createType = 16
		self.numPlayer = 2
	elseif self.playType == 103008 then
		self.createType = 17
		self.numPlayer = 3
	elseif self.playType == 102009 then
		self.createType = 18
		self.numPlayer = 2
	elseif self.playType == 103009 then
		self.createType = 19
		self.numPlayer = 3
	elseif self.playType == 102010 then
		self.createType = 20
		self.numPlayer = 2
	elseif self.playType == 103010 then
		self.createType = 21
		self.numPlayer = 3
	elseif self.playType == 100018 then 
		self.createType = 22
		self.numPlayer = 4
	end
	self.playTypestr = string.sub(MJRules.Rules[self.playType].name,2)

	-- self.playersType = paramTbl.m_playtype[#paramTbl.m_playtype] or 4
	self.playersType = self.numPlayer or 4
	local realType = paramTbl.m_playtype
	self.playTypeList = paramTbl.m_playtype
	-- for i,v in ipairs(realType) do
	-- 	if v == 1 then
	-- 		playTypeDesc = playTypeDesc .. " 三七夹"
	-- 	elseif v == 2 then
	-- 		playTypeDesc = playTypeDesc .. " 飘胡不限色和幺九"
	-- 	elseif v == 3 then
	-- 		playTypeDesc = playTypeDesc .. " 三清点五"
	-- 	elseif v == 4 then
	-- 		playTypeDesc = playTypeDesc .. " 未上听包三家"
	-- 	elseif v == 6 then
	-- 		playTypeDesc = playTypeDesc .. " 点炮一家赔"
	-- 	end
	-- end

	-- gt.log("playTypeDesc = " .. playTypeDesc)
	-- local arrStr={}
	-- for p_str in string.gmatch(playTypeDesc, "%S+") do
	--     table.insert(arrStr,p_str)
 --    end
    
	-- local newStrType=""
	-- local newStrDes=""
	-- for i,v in ipairs(arrStr) do
 --    	    if i==1 then
 --    	    	newStrType=v
 --    	    else
 --    		newStrDes=newStrDes .." "..v
 --    	    end
 --        end
	-- self.playTypeDesc = newStrDes
 --    self.playTypestr=newStrType


	-- 玩家显示固定座位号
	self.playerDisplayIdx = 4
	self.playerSeatIdx = paramTbl.playerSeatIdx
	self.zhuangIdx = paramTbl.m_zhuang

	-- if self.playersType == 2 then
	-- 	mjTilePerLine = 6
	-- elseif self.playersType == 3 then
	-- 	mjTilePerLine = 6
	-- else
	-- 	mjTilePerLine = 6
	-- end

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
	--玩法大类型
	self.m_state = paramTbl.m_state

	--耗子牌记录
	self.haoziCard = paramTbl.haoziCard

	-- 头像下载管理器
	local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
	self.rootNode:addChild(playerHeadMgr)
	self.playerHeadMgr = playerHeadMgr

	self:initUI()
end

function PlayManager:initUI()
	-- 隐藏玩家麻将参考位置
	local playNode = gt.seekNodeByName(self.rootNode, "Node_play")
	playNode:setVisible(false)

	-- 房间号
	local roomIDLabel = gt.seekNodeByName(self.rootNode, "Label_roomID")
	roomIDLabel:setString(string.format("%d",self.roomID))
    -- 玩法类型
	local playTypeDesc = ""
	-- if self.playType == 100001 then
	-- 	playTypeDesc = "推倒胡"
	-- elseif self.playType == 100002 then
	-- 	playTypeDesc = "扣点点"
	-- elseif self.playType == 100004 then
	-- 	playTypeDesc = "立四"
	-- elseif self.playType == 100005 then
	-- 	playTypeDesc = "晋中"
	-- elseif self.playType == 100003 then
	-- 	playTypeDesc = "运城贴金"
	-- elseif self.playType == 100006 then
	-- 	playTypeDesc = "拐三角"
	-- elseif self.playType == 100012 then
	-- 	playTypeDesc = "扣点点"
 --    elseif self.playType == 100008 then
	-- 	playTypeDesc = "硬三嘴"
 --    elseif self.playType == 100009 then
	-- 	playTypeDesc = "洪洞王牌"
 --    elseif self.playType == 100010 then
	-- 	playTypeDesc = "一门牌"
	-- end
	playTypeDesc = Utils.getplayName(self.playType)
	local realType = self.playTypeList
	gt.log("玩法标题 ===========")
	gt.dump(realType)
    --2107-3-1 syz 添加
    local lineflag = 1
    playTypeDesc = playTypeDesc .. " "
    -- for i,_type in ipairs(realType) do
    -- 	if MJRules.Rules[_type] then
    -- 		lineflag = lineflag + 1
    -- 		playTypeDesc = playTypeDesc .. MJRules.Rules[_type].name .. " "
	 		-- playTypeDesc = string.gsub(playTypeDesc, ",", "")
	   --  	if lineflag%2 == 0 then
	   --  		playTypeDesc = playTypeDesc.."\n"
	   --  	end
    -- 	end   	
    -- end
	-- 玩法描述
	local Label_mjType = gt.seekNodeByName(self.rootNode, "Label_mjType")
	Label_mjType:setString(playTypeDesc)
	
 --    --麻将类型说明
 --    self.Label_mjType=gt.seekNodeByName(self.rootNode,"Label_mjType")
 --    self.Label_mjType:setString(self.playTypestr)
 --    self.Label_mjType:show()

	-- local wanfaNode = gt.seekNodeByName(self.rootNode,"Node_wanfa")
 --    wanfaNode:setZOrder(100000)
 --    local Label_mjType = gt.seekNodeByName(self.rootNode,"Label_mjType")
 --    local wanfaStr = self.playTypestr..": "
 --    for i=1, #self.playTypeList do
 --    	if i == 1 then
 --    		local firstWanfa = MJRules.Rules[self.playTypeList[1]].name
 --    		firstWanfa = string.sub(firstWanfa, 2)
 --    		wanfaStr = wanfaStr .. firstWanfa
 --    	elseif MJRules.Rules[self.playTypeList[i]] ~= nil then
 --    		wanfaStr = wanfaStr .. MJRules.Rules[self.playTypeList[i]].name
 --    	end
 --    end
 --    gt.log("=====wanfaStr:"..wanfaStr.."  len:" .. string.len(wanfaStr))
 --    local showMore = gt.seekNodeByName(self.rootNode, "Btn_more")
 --    local arrowSp = gt.seekNodeByName(self.rootNode, "Spr_arrow")
 --    showMore:hide()
 --    arrowSp:hide()
 --    local showStrArr = self:getCutString(wanfaStr,25) -- 最多3行
 --    dump(showStrArr)
 --    Label_mjType:setString(wanfaStr)
 --    local count = 1
 --    local moreStr = showStrArr[count]
 --    if #showStrArr > 1 then
 --    	showMore:show()
 --    	arrowSp:show()
 --    	Label_mjType:setString(moreStr)
 --    	local bgImg = gt.seekNodeByName(self.rootNode, "Img_wanfa")
 --    	local isNext = true --标记是否有剩余的字符串
 --    	gt.addBtnPressedListener(showMore, function ()
 --    		if isNext then
 --    			count = #showStrArr
 --    			isNext = false
 --    			arrowSp:setFlippedY(true)
 --    			for i=2,#showStrArr do
 --    				moreStr = moreStr.."\n"..showStrArr[i]
 --    			end
 --    		else
 --    			count = 1
 --    			isNext = true
 --    			arrowSp:setFlippedY(false)
 --    			moreStr = showStrArr[1]
 --    		end
 --    		Label_mjType:setContentSize(cc.size(550, 30+(count-1)*30))
 --    		Label_mjType:setString(moreStr)
 --    		bgImg:setContentSize(cc.size(600, 50+(count-1)*30))
 --    	end)
 --    end


	-- 麻将层
	local playMjLayer = cc.Layer:create()
	self.rootNode:addChild(playMjLayer, gt.PlayZOrder.MJTILES_LAYER)
	self.playMjLayer = playMjLayer

	-- -- 出的牌标识动画
	-- local outMjtileSignNode, outMjtileSignAnime = gt.createCSAnimation("animation/OutMjtileSign.csb")
	-- outMjtileSignAnime:play("run", true)
	-- outMjtileSignNode:setVisible(false)
	-- self.rootNode:addChild(outMjtileSignNode, gt.PlayZOrder.OUTMJTILE_SIGN)
	-- self.outMjtileSignNode = outMjtileSignNode
	
	-- 出的牌标识动画
	local outMjtileSignNode = cc.Sprite:createWithSpriteFrameName("sx_img_play_biaoji.png")
	outMjtileSignNode:setVisible(false)
	self.rootNode:addChild(outMjtileSignNode, gt.PlayZOrder.OUTMJTILE_SIGN)
	self.outMjtileSignNode = outMjtileSignNode
   

	-- 逻辑座位和显示座位偏移量(从0编号开始)
		print("-------------------self.playerDisplayIdx", self.playerDisplayIdx)
		print("-------------------self.playerSeatIdx", self.playerSeatIdx)
	local seatOffset = self.playerDisplayIdx - self.playerSeatIdx + 1
	self.seatOffset = seatOffset
	local turnPosLayerSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosLayer")
	
		print("-------------------self.seatOffset", self.seatOffset)
	for i = 1, 4 do
		local index = (i + self.seatOffset)%4
		if index == 0 then index = 4 end
		print("-------------------i", i)
		print("-------------------index", index)
		local Spr_turnPosTip = gt.seekNodeByName(turnPosLayerSpr, "Spr_turnPosTip_"..i)
		Spr_turnPosTip:setPosition(PlayManager.positionTip["positionTip"..index].x, PlayManager.positionTip["positionTip"..index].y)
   		Spr_turnPosTip:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("sx_table_directBg"..index.."_position"..i..".png"))
	end

	-- 旋转座次标识,座次方位和显示对应
	if self.gameMark then
		-- local turnPosBgSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosLayer")
		-- turnPosBgSpr:show()
  --     	for _, turnPosSpr in ipairs(turnPosBgSpr:getChildren()) do
	 --     	turnPosSpr:setVisible(false)
  --     	end
   --    	for i=1, 4 do
			-- local turnPosSpr = gt.seekNodeByName(turnPosBgSpr, "Spr_turnPos_" .. i)
			-- local fadeOut = cc.FadeOut:create(0.8)
			-- local fadeIn = cc.FadeIn:create(0.8)
			-- local seqAction = cc.Sequence:create(fadeOut, fadeIn)
			-- turnPosSpr:runAction(cc.RepeatForever:create(seqAction))
   --    	end
		for i=1,4 do
			local turnPosTipSpr = gt.seekNodeByName(turnPosLayerSpr, "Spr_turnPosTip_" .. i)
			local fadeOut = cc.FadeOut:create(0.8)
			local fadeIn = cc.FadeIn:create(0.8)
			local seqAction = cc.Sequence:create(fadeOut, fadeIn)
			turnPosTipSpr:runAction(cc.RepeatForever:create(seqAction))
			gt.seekNodeByName(turnPosLayerSpr, "Spr_turnPosTip_" .. i):setVisible(false)
		end
	else   
		-- local turnPosBgSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosBg_none")
		-- turnPosBgSpr:setVisible(true)
	 --    turnPosBgSpr:setRotation(-seatOffset * 90)
  --      	for _, turnPosSpr in ipairs(turnPosBgSpr:getChildren()) do
	 --      	turnPosSpr:setVisible(false)
  --      	end
	end

	-- 隐藏决策条
	for i=1, 4 do
		local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. i)
		local Node_ReplayBtn = gt.seekNodeByName(playerInfoNode,"Node_ReplayBtn")
		if Node_ReplayBtn ~= nil then
			Node_ReplayBtn:setVisible(false)
		end
	end

	--规则按钮
	local ruleBtn = gt.seekNodeByName(self.rootNode, "Btn_rule")
	gt.addBtnPressedListener(ruleBtn, function()
		gt.dump(self.playTypeList)
		local layer = require("app/views/RuleIntroduction"):create(self.playTypeList, self.createType)
		self.rootNode:addChild(layer, 1000)
		if cc.PLATFORM_OS_IPAD == gt.targetPlatform then
			layer:setPosition(0, -gt.winSize.height/8.6)
		end
	end)
end

-- start --
--------------------------------
-- @class function
-- @description 房间添加玩家
-- @param playerData 玩家数据
-- end --
function PlayManager:roomAddPlayer(roomPlayer)
	-- 玩家自己
	roomPlayer.isOneself = false
	if roomPlayer.seatIdx == self.playerSeatIdx then
		roomPlayer.isOneself = true
	end
	-- 显示索引
	-- roomPlayer.displayIdx = (roomPlayer.seatIdx + self.seatOffset - 1) % 4 + 1
	gt.log("当前玩法转转 ； " .. self.playersType .. " 我的座位" .. self.playerSeatIdx .. "此玩家的seatIdx = ".. roomPlayer.seatIdx)
	-- gt.log("录像测试，人数："..self.playersType)
	-- if self.playersType == 2 or self.m_state == 100012 then
	-- 	if roomPlayer.seatIdx == self.playerSeatIdx then
	-- 		roomPlayer.displayIdx = 4
	-- 	else
	-- 		roomPlayer.displayIdx = 2
	-- 	end
	-- elseif self.playersType == 3 or self.m_state == 100006 then
	-- 	if self.playerSeatIdx == 1 then
	-- 		if roomPlayer.seatIdx == 2 then
	-- 			roomPlayer.displayIdx = 1
	-- 		elseif roomPlayer.seatIdx == 3 then
	-- 			roomPlayer.displayIdx = 3
	-- 		else
	-- 			roomPlayer.displayIdx = 4
	-- 		end
	-- 	elseif self.playerSeatIdx == 2 then
	-- 		if roomPlayer.seatIdx == 3 then
	-- 			roomPlayer.displayIdx = 1
	-- 		elseif roomPlayer.seatIdx == 1 then
	-- 			roomPlayer.displayIdx = 3
	-- 		else
	-- 			roomPlayer.displayIdx = 4
	-- 		end
	-- 	elseif self.playerSeatIdx == 3 then
	-- 		if roomPlayer.seatIdx == 1 then
	-- 			roomPlayer.displayIdx = 1
	-- 		elseif roomPlayer.seatIdx == 2 then
	-- 			roomPlayer.displayIdx = 3
	-- 		else
	-- 			roomPlayer.displayIdx = 4
	-- 		end
	-- 	end
	-- else
		roomPlayer.displayIdx = (roomPlayer.seatIdx + self.seatOffset - 2) % 4 + 1
	-- end
	
	-- gt.log("显示 ： " ..  roomPlayer.displayIdx)
	-- 玩家信息
	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displayIdx)
	playerInfoNode:setVisible(true)
	-- 头像
	roomPlayer.headURL = string.sub(roomPlayer.headURL, 1, string.lastString(roomPlayer.headURL, "/")) .. "96"
	local headSpr = gt.seekNodeByName(playerInfoNode, "Spr_head")
	local headFrameBtn = gt.seekNodeByName(playerInfoNode, "Btn_headFrame")
	self.playerHeadMgr:attach(headSpr, headFrameBtn, roomPlayer.uid, roomPlayer.headURL, roomPlayer.sex, true)
	-- 昵称
	local nicknameLabel = gt.seekNodeByName(playerInfoNode, "Label_nickname")
	nicknameLabel:setString(roomPlayer.nickname)
	-- 积分
	local scoreLabel = gt.seekNodeByName(playerInfoNode, "Label_score")
	scoreLabel:setString(tostring(roomPlayer.score))
	roomPlayer.scoreLabel = scoreLabel
	-- 离线标示
	-- local offLineSignSpr = gt.seekNodeByName(playerInfoNode, "Spr_offLineSign")
	-- offLineSignSpr:setVisible(false)
	-- 庄家
	local bankerSignSpr = gt.seekNodeByName(playerInfoNode, "Spr_bankerSign")
	bankerSignSpr:setVisible(false)
	print("-------------self.zhuangIdx", self.zhuangIdx)
	local bankerSeatIdx = self.zhuangIdx + 1
	if bankerSeatIdx == roomPlayer.seatIdx then
		bankerSignSpr:setVisible(true)
	end
	-- 听
	local tingSpr = gt.seekNodeByName(playerInfoNode, "spr_ting")
	tingSpr:setVisible(false)

	-- 玩家持有牌
	roomPlayer.holdMjTiles = {}
	-- 玩家立四牌
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
	--吃
	roomPlayer.mjTileEat = {}
	-- 明补
	roomPlayer.mjTileBrightBu = {}
	-- 暗补
	roomPlayer.mjTileDarkBu = {}
	-- 麻将放置参考点
	roomPlayer.mjTilesReferPos = self:getPlayerMjTilesReferPos(roomPlayer.displayIdx)

	-- 添加入缓冲
	if not self.roomPlayers then
		self.roomPlayers = {}
	end
	self.roomPlayers[roomPlayer.seatIdx] = roomPlayer
end

-- start --
--------------------------------
-- @class function
-- @description 设置座位编号标识
-- @param seatIdx 座位编号
-- end --
function PlayManager:setTurnSeatSign(seatId)
	-- local seatIdx = self:getDisplaySeat(seatId)
	local seatIdx = seatId
	if seatIdx == 5 then
		seatIdx = 1
	end
	gt.log("getDisplaySeat:========="..seatIdx)
	-- 显示轮到的玩家座位标识
	if self.gameMark then
		-- local turnPosBgSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosBg")
		-- turnPosBgSpr:setVisible(true)
	 --     -- 显示当先座位标识
	 --    local turnPosSpr = gt.seekNodeByName(turnPosBgSpr, "Spr_turnPos_" .. seatIdx)
	 --    turnPosSpr:setVisible(true)
	 --    if self.preTurnSeatIdx and self.preTurnSeatIdx ~= seatIdx then
		-- -- 隐藏上次座位标识
		-- 	local turnPosSpr = gt.seekNodeByName(turnPosBgSpr, "Spr_turnPos_" .. self.preTurnSeatIdx)
		-- 	turnPosSpr:setVisible(false)
		-- end
		-- self.preTurnSeatIdx = seatIdx

		local turnPosLayerSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosLayer")
		-- 显示当先座位标识
		local turnPosTipSpr1 = gt.seekNodeByName(turnPosLayerSpr, "Spr_turnPosTip_" .. seatIdx)
		turnPosTipSpr1:show()
		if self.preTurnSeatIdx and self.preTurnSeatIdx ~= seatIdx then
			-- 隐藏上次座位标识
			local turnPosTipSpr2 = gt.seekNodeByName(turnPosLayerSpr, "Spr_turnPosTip_" .. self.preTurnSeatIdx)
			turnPosTipSpr2:hide()
		end
		self.preTurnSeatIdx = seatIdx
	else
		-- local turnPosBgSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosBg_none")
		-- turnPosBgSpr:setVisible(true)
		-- -- 显示当先座位标识
		-- local turnPosSpr = gt.seekNodeByName(turnPosBgSpr, "Spr_turnPos_" .. seatIdx)
		-- turnPosSpr:setVisible(true)
		-- if self.preTurnSeatIdx and self.preTurnSeatIdx ~= seatIdx then
		-- -- 隐藏上次座位标识
		-- 	local turnPosSpr = gt.seekNodeByName(turnPosBgSpr, "Spr_turnPos_" .. self.preTurnSeatIdx)
		-- 	turnPosSpr:setVisible(false)
		-- end
		-- self.preTurnSeatIdx = seatIdx
	end
end
function PlayManager:addPiaoNum()
	local seatIdxs={}
	for i=1,4 do
		table.insert(seatIdxs,self.roomPlayers[i].displayIdx)
	end
	return seatIdxs
end
function PlayManager:drawMjTile(seatIdx, mjColor, mjNumber)
	local roomPlayer = self.roomPlayers[seatIdx]
	if roomPlayer == nil then
		gt.log("seatIdx:" .. seatIdx .. " has not data !")
		return 
	end

	-- 添加牌放在末尾
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.holdStart
	if #roomPlayer.lisiMjTiles > 0 then
		mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, #roomPlayer.lisiMjTiles))
		mjTilePos = cc.pAdd(mjTilePos, cc.p(25, 0))
	end
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, #roomPlayer.holdMjTiles))
	mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.drawSpace)

	local mjTile = self:addMjTile(roomPlayer, mjColor, mjNumber)
	mjTile.mjTileSpr:setPosition(mjTilePos)
	self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height - mjTilePos.y))
end

-- 清理掉所有出的牌
function PlayManager:cleanMjFormLayer()

	-- 隐藏决策条
	for i=1, 4 do
		local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. i)
		local Node_ReplayBtn = gt.seekNodeByName(playerInfoNode,"Node_ReplayBtn")
		if Node_ReplayBtn ~= nil then
			Node_ReplayBtn:setVisible(false)
		end
	end

	self.playMjLayer:removeAllChildren()

	self.outMjtileSignNode:setVisible(false)
    if self.gameMark then
   --  	local turnPosBgSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosBg")
	  --   for _, turnPosSpr in ipairs(turnPosBgSpr:getChildren()) do
			-- turnPosSpr:setVisible(false)
	  --   end
    else
   --  	local turnPosBgSpr = gt.seekNodeByName(self.rootNode, "Spr_turnPosBg_none")
   --  	turnPosBgSpr:setVisible(true)
	  --   for _, turnPosSpr in ipairs(turnPosBgSpr:getChildren()) do
			-- turnPosSpr:setVisible(false)
	  --   end
    end
end

-- start --
--------------------------------
-- @class function
-- @description 给玩家添加牌
-- @param seatIdx 座位号
-- @param mjColor 花色
-- @param mjNumber 编号
-- end --
function PlayManager:addMjTile(roomPlayer, mjColor, mjNumber)
	-- local roomPlayer = self.roomPlayers[seatIdx]

	local mjTileName = ""
	if roomPlayer.isOneself then
		-- 玩家自己
		-- mjTileName = string.format("p%db%d_%d.png", roomPlayer.displayIdx, mjColor, mjNumber)
		mjTileName = Utils.getMJTileResName(roomPlayer.displayIdx, mjColor, mjNumber, self.isHZLZ, 1)
	else
		if roomPlayer.isHidden then
			-- 持有牌隐藏
			mjTileName = string.format("tbgs_%d.png", roomPlayer.displayIdx)
		else
			-- mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displayIdx, mjColor, mjNumber)
			mjTileName = Utils.getMJTileResName(roomPlayer.displayIdx, mjColor, mjNumber,self.isHZLZ)
		end
	end
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	--对家牌改成正向后，需要将牌缩小
	if roomPlayer.displayIdx == 2 then
		mjTileSpr:setScale(0.72)
	end
	self.playMjLayer:addChild(mjTileSpr)

	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber

	-- 添加金牌／耗子牌标志
	if self.haoziCard ~= nil then
		for j, v in ipairs(self.haoziCard) do
			if v[1] == mjTile.mjColor and v[2] == mjTile.mjNumber then
				local iconImgName = "sx_img_table_mouse.png"
				local tagName = "img_table_mouse"
				if self.m_state == 100003 then  --贴金
					iconImgName = "sx_img_table_jin.png"
					tagName = "img_table_jin"
				end
				local imgtablemouse = ccui.ImageView:create(iconImgName,1)
				imgtablemouse:setName(tagName)
				local mjsize = mjTileSpr:getContentSize()
				local tablemousesize = imgtablemouse:getContentSize()
				mjTileSpr:addChild(imgtablemouse)
				if roomPlayer.displayIdx == 1 then
					imgtablemouse:setRotation(-90)	
					imgtablemouse:setScale(0.66)
					imgtablemouse:setPosition(tablemousesize.width/2+12,tablemousesize.height+12)
				elseif roomPlayer.displayIdx == 3 then
					imgtablemouse:setRotation(90)
					imgtablemouse:setScale(0.66)
					imgtablemouse:setPosition(mjsize.width- tablemousesize.width/2-15,mjsize.height - tablemousesize.height/2-10)
				elseif roomPlayer.displayIdx == 2 then
					imgtablemouse:setScale(0.66)
					imgtablemouse:setPosition(mjsize.width- tablemousesize.width/2,mjsize.height - tablemousesize.height/2)
				else
					imgtablemouse:setPosition(mjsize.width - tablemousesize.width/2,mjsize.height - tablemousesize.height+3)
				end
			end
		end
	end
	
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
function PlayManager:addLisiMjTile(roomPlayer, mjColor, mjNumber)
	gt.log("给玩家发立四牌：color="..mjColor..", number="..mjNumber)
	if mjColor <= 0 or mjNumber <= 0 then
		gt.log("收到非法牌型：color="..mjColor..", mjNumber="..mjNumber)
		return
	end
	local mjTileName = Utils.getMJTileResName(roomPlayer.displayIdx, mjColor, mjNumber, self.isHZLZ,1)
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	self.playMjLayer:addChild(mjTileSpr)

	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber
	if #roomPlayer.lisiMjTiles < 4 then
		table.insert(roomPlayer.lisiMjTiles, mjTile)
	else
		table.insert(roomPlayer.holdMjTiles, mjTile)
	end

	return mjTile
end

-- start --
--------------------------------
-- @class function
-- @description 出牌
-- @param
-- @param
-- @param
-- @return
-- end --
function PlayManager:playOutMjTile(seatIdx, mjColor, mjNumber)
	gt.log("out:seatIdx======"..seatIdx)
	local roomPlayer = self.roomPlayers[seatIdx]

	-- 持有牌删除对应麻将
	self:removeHoldMjTiles(roomPlayer, mjColor, mjNumber, 1)

	-- 显示出牌动画
	-- self:showOutMjTileAnimation(roomPlayer, mjColor, mjNumber, function()
		-- -- 添加出牌
		-- self:outMjTile(roomPlayer, mjColor, mjNumber)

		-- -- 显示出牌标识
		-- self:showOutMjtileSign(roomPlayer)
	-- end)

	-- 添加出牌
	self:outMjTile(roomPlayer, mjColor, mjNumber)

	-- 显示出牌标识
	self:showOutMjtileSign(roomPlayer)

	-- 记录出牌的上家
	self.prePlaySeatIdx = seatIdx

	-- dj revise
	gt.soundManager:PlayCardSound(roomPlayer.sex, mjColor, mjNumber)
end

-- 快速出牌,屏蔽出牌动画
function PlayManager:playOutMjTileQuick(seatIdx, mjColor, mjNumber)
	local roomPlayer = self.roomPlayers[seatIdx]

	-- 持有牌删除对应麻将
	self:removeHoldMjTiles(roomPlayer, mjColor, mjNumber, 1)

	-- 添加出牌
	self:outMjTile(roomPlayer, mjColor, mjNumber)

	-- 显示出牌标识
	self:showOutMjtileSign(roomPlayer)

	-- 记录出牌的上家
	self.prePlaySeatIdx = seatIdx
end

-- start --
--------------------------------
-- @class function
-- @description 显示用户的海底牌
-- @param seatIdx 座位索引
-- end --
function PlayManager:showHaidiDecision(seatIdx,isQuick)
	-- if isQuick then
	-- 	local roomPlayer = self.roomPlayers[seatIdx]
	-- 	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displayIdx)
	-- 	local Node_ReplayBtn = gt.seekNodeByName(playerInfoNode,"Node_haidiBtn")
	-- 	Node_ReplayBtn:setVisible(false)
	-- 	return
	-- end

	-- local roomPlayer = self.roomPlayers[seatIdx]
	-- local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displayIdx)
	-- self.rootNode:reorderChild(playerInfoNode, 200)
	-- local Node_ReplayBtn = gt.seekNodeByName(playerInfoNode,"Node_haidiBtn")
	-- Node_ReplayBtn:setVisible(true)
end

-- start --
--------------------------------
-- @class function
-- @description 用户海底要
-- @param seatIdx 座位索引
-- end --
function PlayManager:decisionHaidiResult(seatIdx,isChoose,isQuick)
	-- if isQuick then
	-- 	local roomPlayer = self.roomPlayers[seatIdx]
	-- 	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displayIdx)
	-- 	local Node_ReplayBtn = gt.seekNodeByName(playerInfoNode,"Node_haidiBtn")
	-- 	Node_ReplayBtn:setVisible(false)
	-- 	return
	-- end

	-- local roomPlayer = self.roomPlayers[seatIdx]
	-- local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displayIdx)
	-- self.rootNode:reorderChild(playerInfoNode, 200)
	-- local Node_ReplayBtn = gt.seekNodeByName(playerInfoNode,"Node_haidiBtn")

	-- local node
	-- if isChoose == true then -- 海底要
	-- 	node = gt.seekNodeByName(Node_ReplayBtn,"Imgml1")
	-- else
	-- 	node = gt.seekNodeByName(Node_ReplayBtn,"Imgml2")
	-- end

	-- --添加手势测试
	-- local replayGesture = ccui.ImageView:create()
 --    replayGesture:loadTexture("images/otherImages/replayGesture.png")
 --    replayGesture:setPosition(cc.p(node:getPositionX(),node:getPositionY()-25) )
 --    Node_ReplayBtn:addChild(replayGesture,300)

 --    local  sc2 = cc.ScaleBy:create(0.3,0.65)
 --    local  sc3 = cc.EaseInOut:create(sc2, 0.3)
 --    local  sc2_back = sc3:reverse()
 --    local function stopAction()
 --        replayGesture:stopAllActions()
 --        replayGesture:removeFromParent()
 --        Node_ReplayBtn:setVisible(false)
 --    end

 --    local callfunc = cc.CallFunc:create(stopAction)
 --    replayGesture:runAction( cc.Sequence:create(sc3, callfunc))
end

function PlayManager:showHaidiResult( mjColor, mhNumber, isQuick )
	if isQuick then
		local dipaiNode = gt.seekNodeByName(self.rootNode, "Node_HaidiPai")
		dipaiNode:setVisible( false )
		return
	end
	local dipaiNode = gt.seekNodeByName(self.rootNode, "Node_HaidiPai")
	dipaiNode:setVisible( true )
	local spr = gt.seekNodeByName(dipaiNode, "Sprite_pai")
	-- spr:setSpriteFrame(string.format("p4s%d_%d.png", mjColor, mhNumber))
	spr:setSpriteFrame(Utils.getMJTileResName(4, mjColor, mhNumber, self.isHZLZ))

	dipaiNode:stopAllActions()
	local delayTime = cc.DelayTime:create(1.5)
	local callFunc = cc.CallFunc:create(function(sender)
		dipaiNode:setVisible( false )
	end)

	local seqAction = cc.Sequence:create(delayTime, callFunc)
	dipaiNode:runAction(seqAction)
end
-- 扎鸟
function PlayManager:showZhanniao(birdInfo, isQuick, huPos)

	-- 屏蔽二三人转转的抓鸟玩法
	if self.playersType == 2 then --or self.playersType == 3 then
		do return end
	end
	
	if isQuick then
		self.m_isZhaNiao = true
		self.m_zhaNiaoTime = 3.5
		local curRoomPlayers = {}
		curRoomPlayers = self.roomPlayers

		-- 规则： 抓鸟胡牌玩家huPos（得牌1,5,9) 逆时针得牌2，6｜3，7｜4，8
		table.foreach(birdInfo, function(i, brid)

			-- dump(birdInfo)

			local seatIdx = math.floor( (brid[2] + huPos) % 4 + 0.5 ) -- 服务器没有值,所以暂时强制设定为1
			if seatIdx == 0 then
				seatIdx = 4
			end
			local card = brid

			local huPlayer = curRoomPlayers[huPos + 1]
			local sprite = self:addAlreadyOutMjTilesByCopy(
				huPos + 1, tonumber(card[1]), tonumber(card[2]), huPlayer)
			sprite:setColor(cc.c3b(243,243,10))
		end)

		return
	end
	
	self.m_isZhaNiao = true
	self.m_zhaNiaoTime = 3.5
	local curRoomPlayers = {}
	curRoomPlayers = self.roomPlayers
	local layer = cc.Layer:create()
	local delayTime = cc.DelayTime:create(2)
	local callFunc = cc.CallFunc:create(function(sender)
		-- dump(birdInfo)
		table.foreach(birdInfo, function(i, brid)
			local seatIdx = math.floor( (brid[2] + huPos) % 4 + 0.5 ) -- 服务器没有值,所以暂时强制设定为1
			if seatIdx == 0 then
				seatIdx = 4
			end
			-- gt.log("seatIdx = " .. seatIdx)
			local card = brid

			local huPlayer = curRoomPlayers[huPos + 1]
			local sprite = self:addAlreadyOutMjTilesByCopy(
				huPos + 1, tonumber(card[1]), tonumber(card[2]), huPlayer)
			sprite:setColor(cc.c3b(243,243,10))

			local roomPlayer = curRoomPlayers[seatIdx]
			if roomPlayer == nil then
				do return end
			end

			local displaySeatIdx = roomPlayer.displayIdx
			local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. displaySeatIdx)
			self:birdFly(layer, display.cx, display.cy, playerInfoNode:getPositionX(), playerInfoNode:getPositionY())

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
	self.playMjLayer:addChild(csbNode)
	self.playMjLayer:addChild(layer)
end
-- 扎鸟配套的动画
function PlayManager:addAlreadyOutMjTilesByCopy(seatIdx, mjColor, mjNumber, roomPlayer, isHide)
	-- 添加到已出牌列表
	-- local mjTileSpr = cc.Sprite:createWithSpriteFrameName(string.format("p%ds%d_%d.png", roomPlayer.displayIdx, mjColor, mjNumber))
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(Utils.getMJTileResName(roomPlayer.displayIdx, mjColor, mjNumber, self.isHZLZ))
	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber
	table.insert(roomPlayer.outMjTiles, mjTile)

	-- 玩家已出牌缩小
	-- if self.playerSeatIdx == seatIdx then
	-- 	mjTileSpr:setScale(0.66)
	-- end

	if isHide then
		mjTileSpr:setVisible( false )
	end

	-- 显示已出牌
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.outStart

	if self.playersType == 3 then
		if roomPlayer.displayIdx == 4 then
			mjTilePos.x = 410
		end
	end

	if roomPlayer.displayIdx == 1 then
		mjTileSpr:setScale(0.8)
	elseif roomPlayer.displayIdx == 2 then
		mjTileSpr:setScale(0.7)
	elseif roomPlayer.displayIdx == 3 then
		mjTileSpr:setScale(0.8)
	elseif roomPlayer.displayIdx == 4 then
		mjTileSpr:setScale(0.8)
	end

	local lineCount = math.ceil(#roomPlayer.outMjTiles / mjTilePerLine[self.playersType][roomPlayer.displayIdx].lineCount) - 1
	local lineIdx = #roomPlayer.outMjTiles - lineCount * mjTilePerLine[self.playersType][roomPlayer.displayIdx].lineCount - 1
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))
	mjTileSpr:setPosition(mjTilePos)
	if roomPlayer.displayIdx == 1 then
		self.playMjLayer:reorderChild(mjTileSpr, (gt.winSize.height - mjTilePos.x - mjTilePos.y))
	else
		self.playMjLayer:reorderChild(mjTileSpr, (gt.winSize.height + mjTilePos.x - mjTilePos.y))
	end
	return mjTileSpr
end
-- 鸟飞的动画
function PlayManager:birdFly(layer, x, y, ex, ey)
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
-- @description 显示用户的决策
-- @param seatIdx 座位索引
-- @param decisionList 决策的类型列表
-- end --
function PlayManager:showMakeDecision(seatIdx,decisionList,isQuick)
	-- gt.log("显示ssss用户决策 " .. seatIdx)
	-- if isQuick then
	-- 	local roomPlayer = self.roomPlayers[seatIdx]
	-- 	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displayIdx)
	-- 	local Node_ReplayBtn = gt.seekNodeByName(playerInfoNode,"Node_ReplayBtn")
	-- 	Node_ReplayBtn:setVisible(false)
	-- 	return
	-- end

	-- local roomPlayer = self.roomPlayers[seatIdx]
	-- local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displayIdx)
	-- self.rootNode:reorderChild(playerInfoNode, 200)
	-- local Node_ReplayBtn = gt.seekNodeByName(playerInfoNode,"Node_ReplayBtn")
	-- Node_ReplayBtn:setVisible(true)
	-- -- 隐藏所有的按钮
	-- for i=1,6 do
	-- 	local node1 = gt.seekNodeByName(Node_ReplayBtn,string.format("Imgml%d",i))
	-- 	node1:setVisible(false)

	-- 	local node2 = gt.seekNodeByName(Node_ReplayBtn,string.format("Imgml%d",i*10+1))
	-- 	node2:setVisible(false)

	-- end

	-- for i=1,6 do
	-- 	local node1 = gt.seekNodeByName(Node_ReplayBtn,"Imgml"..i)
	-- 	local node2 = gt.seekNodeByName(Node_ReplayBtn,string.format("Imgml%d",i*10+1))
	-- 	node2:setVisible(true)
	-- 	for _,v in ipairs(decisionList) do
	-- 		if v == i then
	-- 			node1:setVisible(true)
	-- 			node2:setVisible(false)
	-- 		end
	-- 	end
	-- end
end

-- start --
--------------------------------
-- @class function
-- @description 用户选择决策
-- @param seatIdx 座位索引
-- @param decisionList 决策的类型
-- end --
function PlayManager:decisionResult(seatIdx,decisionIndex,isQuick)
	-- gt.log("其他玩家决--策 " .. decisionIndex)
	-- if isQuick then
	-- 	local roomPlayer = self.roomPlayers[seatIdx]
	-- 	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displayIdx)
	-- 	local Node_ReplayBtn = gt.seekNodeByName(playerInfoNode,"Node_ReplayBtn")
	-- 	Node_ReplayBtn:setVisible(false)
	-- 	return
	-- end

	-- local roomPlayer = self.roomPlayers[seatIdx]
	-- local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. roomPlayer.displayIdx)
	-- self.rootNode:reorderChild(playerInfoNode, 200)
	-- local Node_ReplayBtn = gt.seekNodeByName(playerInfoNode,"Node_ReplayBtn")

	-- local node
	-- for i=1,6 do
	-- 	local node1 = gt.seekNodeByName(Node_ReplayBtn,"Imgml"..i)
	-- 	if i == decisionIndex then
	-- 		node = node1
	-- 		break
	-- 	end
	-- end

	-- --添加手势测试
	-- local replayGesture = ccui.ImageView:create()
 --    replayGesture:loadTexture("images/otherImages/replayGesture.png")
 --    replayGesture:setPosition(cc.p(node:getPositionX(),node:getPositionY()-25) )
 --    Node_ReplayBtn:addChild(replayGesture,300)

 --    local  sc2 = cc.ScaleBy:create(0.3,0.65)
 --    local  sc3 = cc.EaseInOut:create(sc2, 0.3)
 --    local  sc2_back = sc3:reverse()
 --    local function stopAction()
 --        replayGesture:stopAllActions()
 --        replayGesture:removeFromParent()
 --        Node_ReplayBtn:setVisible(false)
 --    end

 --    local callfunc = cc.CallFunc:create(stopAction)
 --    replayGesture:runAction( cc.Sequence:create(sc3, callfunc))
end

-- start --
--------------------------------
-- @class function
-- @description 添加已出牌
-- @param seatIdx 座位号
-- @param mjColor 花色
-- @param mjNumber 编号
-- end --
function PlayManager:outMjTile(roomPlayer, mjColor, mjNumber)
	-- 添加到已出牌
	-- local roomPlayer = self.roomPlayers[seatIdx]

	-- local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displayIdx, mjColor, mjNumber)
	print("--------------roomPlayer.displayIdx", roomPlayer.displayIdx)
	local mjTileName = Utils.getMJTileResName(roomPlayer.displayIdx, mjColor, mjNumber,self.isHZLZ, 2)
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	local mjTile = {}
	mjTile.mjTileSpr = mjTileSpr
	mjTile.mjColor = mjColor
	mjTile.mjNumber = mjNumber
	
	table.insert(roomPlayer.outMjTiles, mjTile)

	-- 缩小玩家已出牌
	if roomPlayer.isOneself then
		-- mjTileSpr:setScale(0.66)
	end

	--对家牌改成正向后，需要将牌缩小
	-- if roomPlayer.displayIdx == 2 then
	-- 	mjTileSpr:setScale(0.8)
	-- end

	-- 显示已出牌
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.outStart

	-- if self.playersType == 3 then
	-- 	if roomPlayer.displayIdx == 4 then
	-- 		mjTilePos.x = 410
	-- 	end
	-- end

	if roomPlayer.displayIdx == 1 then
		mjTileSpr:setScale(0.8)
	elseif roomPlayer.displayIdx == 2 then
		mjTileSpr:setScale(0.7)
	elseif roomPlayer.displayIdx == 3 then
		mjTileSpr:setScale(0.8)
	elseif roomPlayer.displayIdx == 4 then
		mjTileSpr:setScale(0.8)
	end

	gt.log("-----------------self.playersType", self.playersType)
	gt.log("-----------------roomPlayer.displayIdx", roomPlayer.displayIdx)
	gt.dump(mjTilePerLine)
	local lineCount = math.ceil(#roomPlayer.outMjTiles / mjTilePerLine[self.playersType][roomPlayer.displayIdx].lineCount) - 1
	local lineIdx = #roomPlayer.outMjTiles - lineCount * mjTilePerLine[self.playersType][roomPlayer.displayIdx].lineCount - 1
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))
	mjTileSpr:setPosition(mjTilePos)
	-- self.playMjLayer:addChild(mjTileSpr, (gt.winSize.height - mjTilePos.y))

	if roomPlayer.displayIdx == 1 then
		self.playMjLayer:addChild(mjTileSpr, (gt.winSize.height - mjTilePos.x - mjTilePos.y))
	else
		self.playMjLayer:addChild(mjTileSpr, (gt.winSize.height + mjTilePos.x - mjTilePos.y))
	end

	--添加金牌边框
	self:addJinKuangMjSpr(roomPlayer.displayIdx, mjTile)
end

-- start --
--------------------------------
-- @class function
-- @description 碰牌
-- @param seatIdx 座位编号
-- @param mjColor 花色
-- @param mjNumber 编号
-- end --
function PlayManager:addMjTilePung(seatIdx, mjColor, mjNumber)
	local roomPlayer = self.roomPlayers[seatIdx]

	local pungData = {}
	pungData.mjColor = mjColor
	pungData.mjNumber = mjNumber
	table.insert(roomPlayer.mjTilePungs, pungData)

	pungData.groupNode = self:pungBarReorderMjTiles(roomPlayer, mjColor, mjNumber, false)
end

-- start --
--------------------------------
-- @class function
-- @description 粘牌
-- @param seatIdx 座位编号
-- @param mjColor 麻将牌花色
-- @param mjNumber 麻将牌编号
-- end --
function PlayManager:addMjTileNian(seatIdx, mjColor, mjNumber)
	local roomPlayer = self.roomPlayers[seatIdx]

	local pungData = {}
	pungData.mjColor = mjColor
	pungData.mjNumber = mjNumber
	table.insert(roomPlayer.mjTileNians, pungData)

	pungData.groupNode = self:pungBarReorderMjTiles(roomPlayer, mjColor, mjNumber, false, false, true)
end

-- start --
--------------------------------
-- @class function
-- @description 支对
-- @param seatIdx 座位编号
-- @param mjColor 麻将牌花色
-- @param mjNumber 麻将牌编号
-- end --
function PlayManager:addMjTileZhiDui(seatIdx, mjColor, mjNumber)
	local roomPlayer = self.roomPlayers[seatIdx]

	local pungData = {}
	pungData.mjColor = mjColor
	pungData.mjNumber = mjNumber
	table.insert(roomPlayer.mjTileNians, pungData)

	pungData.groupNode = self:pungBarReorderMjTiles(roomPlayer, mjColor, mjNumber, false, false, false, true)
end

-- start --
--------------------------------
-- @class function
-- @description 杠牌
-- @param seatIdx 座位编号
-- @param mjColor 花色
-- @param mjNumber 编号
-- @param isBrightBar 明杠或者暗杠
-- end --
function PlayManager:addMjTileBar(seatIdx, mjColor, mjNumber, isBrightBar)

	if self.playType == 3 or self.playType == 4 or self.playType == 5 or self.playType == 9 then
		-- 长沙麻将里面杠之后回出牌，需要记录此值
		self.prePlaySeatIdx = seatIdx
	end

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

	barData.groupNode = self:pungBarReorderMjTiles(roomPlayer, mjColor, mjNumber, true, isBrightBar)
end

function PlayManager:getPlayerMjTilesReferPos(displayIdx)
	local mjTilesReferPos = {}

	local playNode = gt.seekNodeByName(self.rootNode, "Node_play")
	local mjTilesReferNode = gt.seekNodeByName(playNode, "Node_playerMjTiles_" .. displayIdx)

	-- 持有牌数据
	local mjTileHoldSprF = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileHold_1")
	local mjTileHoldSprS = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileHold_2")
	mjTilesReferPos.holdStart = cc.p(mjTileHoldSprF:getPosition())
	mjTilesReferPos.holdSpace = cc.pSub(cc.p(mjTileHoldSprS:getPosition()), cc.p(mjTileHoldSprF:getPosition()))

	-- 摸牌偏移
	local drawSpaces = {{x = -7,	y = 25},
						{x = 0,	y = 0},
						{x = -5,	y = -25},
						{x = 0,	y = 0}}
	mjTilesReferPos.drawSpace = drawSpaces[displayIdx]

	-- 打出牌数据
	local mjTileOutSprF = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileOut_1")
	local mjTileOutSprS = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileOut_2")
	local mjTileOutSprT = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileOut_3")

	local mjTileOutSprFPositionX = mjTileOutSprF:getPositionX() + mjTilePerLine[self.playersType][displayIdx].deviationX
	local mjTileOutSprSPositionX = mjTileOutSprS:getPositionX() + mjTilePerLine[self.playersType][displayIdx].deviationX
	local mjTileOutSprTPositionX = mjTileOutSprT:getPositionX() + mjTilePerLine[self.playersType][displayIdx].deviationX

	local mjTileOutSprFPositionY = mjTileOutSprF:getPositionY() + mjTilePerLine[self.playersType][displayIdx].deviationY
	local mjTileOutSprSPositionY = mjTileOutSprS:getPositionY() + mjTilePerLine[self.playersType][displayIdx].deviationY
	local mjTileOutSprTPositionY = mjTileOutSprT:getPositionY() + mjTilePerLine[self.playersType][displayIdx].deviationY

	mjTilesReferPos.outStart = cc.p(mjTileOutSprFPositionX, mjTileOutSprFPositionY)
	mjTilesReferPos.outSpaceH = cc.pSub(cc.p(mjTileOutSprSPositionX, mjTileOutSprSPositionY), cc.p(mjTileOutSprFPositionX, mjTileOutSprFPositionY))
	mjTilesReferPos.outSpaceV = cc.pSub(cc.p(mjTileOutSprTPositionX, mjTileOutSprTPositionY), cc.p(mjTileOutSprFPositionX, mjTileOutSprFPositionY))

	-- -- 打出牌数据
	-- local mjTileOutSprF = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileOut_1")
	-- local mjTileOutSprS = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileOut_2")
	-- local mjTileOutSprT = gt.seekNodeByName(mjTilesReferNode, "Spr_mjTileOut_3")
	-- mjTilesReferPos.outStart = cc.p(mjTileOutSprF:getPosition())
	-- mjTilesReferPos.outSpaceH = cc.pSub(cc.p(mjTileOutSprS:getPosition()), cc.p(mjTileOutSprF:getPosition()))
	-- mjTilesReferPos.outSpaceV = cc.pSub(cc.p(mjTileOutSprT:getPosition()), cc.p(mjTileOutSprF:getPosition()))

	-- 碰，杠牌数据
	local mjTileGroupPanel = gt.seekNodeByName(mjTilesReferNode, "Panel_mjTileGroup")
	local groupMjTilesPos = {}
	for _, groupTileSpr in ipairs(mjTileGroupPanel:getChildren()) do
		table.insert(groupMjTilesPos, cc.p(groupTileSpr:getPosition()))
	end
	mjTilesReferPos.groupMjTilesPos = groupMjTilesPos
	mjTilesReferPos.groupStartPos = cc.p(mjTileGroupPanel:getPosition())
	local groupSize = mjTileGroupPanel:getContentSize()
	if displayIdx == 1 then
		mjTilesReferPos.groupSpace = cc.p(0-40, groupSize.height + 38)
	elseif displayIdx == 3 then
		mjTilesReferPos.groupSpace = cc.p(0-40, groupSize.height + 38)
		mjTilesReferPos.groupSpace.y = -mjTilesReferPos.groupSpace.y
	else
		mjTilesReferPos.groupSpace = cc.p(groupSize.width + 8, 0)
		if displayIdx == 2 then
			mjTilesReferPos.groupSpace.x = -mjTilesReferPos.groupSpace.x
		end
	end

	-- 当前出牌展示位置
	local showMjTileNode = gt.seekNodeByName(mjTilesReferNode, "Node_showMjTile")
	mjTilesReferPos.showMjTilePos = cc.p(showMjTileNode:getPosition())

	return mjTilesReferPos
end

--------------------------------
--设置耗子牌

-- start --
--------------------------------
-- @class function
-- @description 玩家麻将牌根据花色，编号重新排序
-- end --
function PlayManager:sortHoldMjTiles(roomPlayer)
	-- local roomPlayer = self.roomPlayers[seatIdx]

	-- 玩家持有牌不能看,不用排序
	if not roomPlayer.isHidden then
		-- 按照花色分类
		local colorsMjTiles = {}
		local colorsLisiMjTiles = {}
		for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
			if not colorsMjTiles[mjTile.mjColor] then
				colorsMjTiles[mjTile.mjColor] = {}
			end
			table.insert(colorsMjTiles[mjTile.mjColor], mjTile)
		end
		for _, mjTile in ipairs(roomPlayer.lisiMjTiles) do
			if not colorsLisiMjTiles[mjTile.mjColor] then
				colorsLisiMjTiles[mjTile.mjColor] = {}
			end
			table.insert(colorsLisiMjTiles[mjTile.mjColor], mjTile)
		end
		-- dump(colorsLisiMjTiles)

		-- 同花色从小到大排序
		local transMjTiles = {}
		local transLisiMjTiles = {}
		for _, sameColorMjTiles in pairs(colorsMjTiles) do
			table.sort(sameColorMjTiles, function(a, b)
				return a.mjNumber < b.mjNumber
			end)
			for _, mjTile in ipairs(sameColorMjTiles) do
				if mjTile.mjColor == 4 then
					-- table.insert(transMjTiles, 1, mjTile)
					table.insert(transMjTiles, mjTile)
				else
					table.insert(transMjTiles, mjTile)
				end
			end
		end
		for _, sameColorMjTiles in pairs(colorsLisiMjTiles) do
			table.sort(sameColorMjTiles, function(a, b)
				return a.mjNumber < b.mjNumber
			end)
			for _, mjTile in ipairs(sameColorMjTiles) do
				if mjTile.mjColor == 4 then
					-- table.insert(transMjTiles, 1, mjTile)
					table.insert(transLisiMjTiles, mjTile)
				else
					table.insert(transLisiMjTiles, mjTile)
				end
			end
		end
		-- dump(transLisiMjTiles)

		-- 对红中癞子这类牌做处理
		local finalMjTiles = {}
		local finalLisiMjTiles = {}
		if self.isHZLZ == true then
			for _, mjTile in ipairs(transMjTiles) do
				if mjTile.mjColor == 4 and mjTile.mjNumber == 5 then
					table.insert(finalMjTiles, 1, mjTile)
				else
					table.insert(finalMjTiles, mjTile)
				end
			end
			for _, mjTile in ipairs(transLisiMjTiles) do
				if mjTile.mjColor == 4 and mjTile.mjNumber == 5 then
					table.insert(finalLisiMjTiles, 1, mjTile)
				else
					table.insert(finalLisiMjTiles, mjTile)
				end
			end
		else
			finalMjTiles = transMjTiles
			finalLisiMjTiles = transLisiMjTiles
		end
		-- dump(finalLisiMjTiles)

		
		-- roomPlayer.holdMjTiles = transMjTiles
		roomPlayer.holdMjTiles = finalMjTiles
		roomPlayer.lisiMjTiles = finalLisiMjTiles
		gt.dump(roomPlayer.lisiMjTiles)
	end

	--显示立四牌
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.holdStart

	if #roomPlayer.lisiMjTiles > 0 then
		-- local lisiNum = #roomPlayer.lisiMjTiles
		
		gt.dump(roomPlayer.lisiMjTiles)
		for k, mjTile in ipairs(roomPlayer.lisiMjTiles) do
			mjTile.mjTileSpr:stopAllActions()
			mjTile.mjTileSpr:setPosition(mjTilePos)
			gt.log("立四牌位置信息")
			gt.dump(mjTilePos)
			self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height - mjTilePos.y))
			mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
			-- mjTilePos = cc.pAdd(mjTilesReferPos.holdStart, cc.pMul(mjTilesReferPos.holdSpace, lisiNum))
		end
		mjTilePos = cc.pAdd(mjTilePos, cc.p(25, 0))
	end

	--如果是耗子／贴金 类型，将耗子牌放到前面来展示
	for i, mjTile in ipairs(roomPlayer.holdMjTiles) do
		if self.haoziCard ~= nil then
			for j, v in ipairs(self.haoziCard) do
				if mjTile.mjColor == self.haoziCard[j][1] and mjTile.mjNumber == self.haoziCard[j][2] then
					table.remove(roomPlayer.holdMjTiles, i)
					table.insert(roomPlayer.holdMjTiles, 1, mjTile)
					-- if self.m_state ~= 100003 then
					-- 	local iconImgName = "sx_img_table_mouse.png"
					-- 	local tagName = "img_table_mouse"
					-- 	-- if self.m_state == 100003 then  --贴金
					-- 	-- 	iconImgName = "sx_img_table_jin.png"
					-- 	-- 	tagName = "img_table_jin"
					-- 	-- end
					-- 	local imgtablemouse = ccui.ImageView:create(iconImgName,1)
					-- 	imgtablemouse:setName(tagName)
					-- 	local mjsize = mjTile.mjTileSpr:getContentSize()
					-- 	local tablemousesize = imgtablemouse:getContentSize()
					-- 	imgtablemouse:setPosition(mjsize.width - tablemousesize.width/2,mjsize.height - tablemousesize.height)
					-- 	mjTile.mjTileSpr:addChild(imgtablemouse)
					-- end
				end
			end
		end
	end

	--更新剩余牌摆放位置
	for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
		mjTile.mjTileSpr:setPosition(mjTilePos)
		if roomPlayer.displayIdx == 1 then
			self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height - mjTilePos.x - mjTilePos.y))
		else
			self.playMjLayer:reorderChild(mjTile.mjTileSpr, (gt.winSize.height + mjTilePos.x - mjTilePos.y))
		end
		mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.holdSpace)
	end
end

function PlayManager:removeHoldMjTiles(roomPlayer, mjColor, mjNumber, mjTilesCount)
	if roomPlayer == nil then
		gt.log("roomPlayer is null !")
		return 
	end
	local transMjTiles = {}
	local count = 0
	for _, mjTile in ipairs(roomPlayer.holdMjTiles) do
		if roomPlayer.isHidden then
			if count < mjTilesCount then
				mjTile.mjTileSpr:removeFromParent()
				count = count + 1
			else
				table.insert(transMjTiles, mjTile)
			end
		else
			if count < mjTilesCount and mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
				mjTile.mjTileSpr:removeFromParent()
				count = count + 1
			else
				-- 保存其它牌
				table.insert(transMjTiles, mjTile)
			end
		end
	end
	--立四处理
	count = 0
	local lisiTransMjTiles = {}
	for _, mjTile in ipairs(roomPlayer.lisiMjTiles) do
		if roomPlayer.isHidden then
			if count < mjTilesCount then
				mjTile.mjTileSpr:removeFromParent()
				count = count + 1
			else
				table.insert(lisiTransMjTiles, mjTile)
			end
		else
			if count < mjTilesCount and mjTile.mjColor == mjColor and mjTile.mjNumber == mjNumber then
				mjTile.mjTileSpr:removeFromParent()
				count = count + 1
			else
				-- 保存其它牌
				table.insert(lisiTransMjTiles, mjTile)
			end
		end
	end
	roomPlayer.holdMjTiles = transMjTiles
	roomPlayer.lisiMjTiles = lisiTransMjTiles

	self:sortHoldMjTiles(roomPlayer)
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
function PlayManager:pungBarReorderMjTiles(roomPlayer, mjColor, mjNumber, isBar, isBrightBar, isNian, isZhiDui)
	-- local roomPlayer = self.roomPlayers[seat]
	local groupNode = nil
	-- if self.playType ~= gt.RoomType.ROOM_CHANGSHA and self.playType ~= 4 and self.playType ~= 5 and self.playType ~= 9 then
	if false then
		--应该只走底下的else，暂时写成这样
		if type(roomPlayer) == "number" then
			roomPlayer = self.roomPlayers[roomPlayer]
		end

		gt.log("录像显示碰杠 111======== 玩家是："..roomPlayer.displayIdx)

		local mjTilesReferPos = roomPlayer.mjTilesReferPos
		-- 显示碰杠牌
		local groupMjTilesPos = mjTilesReferPos.groupMjTilesPos
		groupNode = cc.Node:create()
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
			-- local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displayIdx, mjColor, mjNumber)
			gt.log("录像吃碰杠 ： roomPlayer.displayIdx="..roomPlayer.displayIdx..", mjColor="..mjColor..", mjNumber="..mjNumber..", self.isHZLZ="..tostring(self.isHZLZ))
			local mjTileName = Utils.getMJTileResName(roomPlayer.displayIdx, mjColor, mjNumber,self.isHZLZ)
			if isBar and not isBrightBar and i <= 3 then
				-- 暗杠前三张牌扣着
				if roomPlayer.displayIdx == 1 or roomPlayer.displayIdx == 3 then
					mjTileName = string.format("tdbgsgang_%d.png", roomPlayer.displayIdx)
				else
					mjTileName = string.format("tdbgs_%d.png", roomPlayer.displayIdx)
				end
			end
			local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
			mjTileSpr:setPosition(groupMjTilesPos[i])
			-- if tonumber(roomPlayer.displayIdx) == 2 then
				--如果是对门玩家的牌,改成正的牌之后要缩小
				gt.log("如果是对门玩家的牌,改成正的牌之后要缩小 111")
				-- mjTileSpr:setScale(0.66)
			-- end
			if tonumber(roomPlayer.displayIdx) == 1 then
				mjTileSpr:setScale(0.8)
			elseif tonumber(roomPlayer.displayIdx) == 2 then
				mjTileSpr:setScale(0.66)
			elseif tonumber(roomPlayer.displayIdx) == 3 then
				mjTileSpr:setScale(0.8)
			end
			-- if isBar and isBrightBar and roomPlayer.displaySeatIdx == 2 then
			-- 	--如果是对门明杠，明杠的牌缩小
			-- 	mjTileSpr:setScale(0.66)
			-- end
			groupNode:addChild(mjTileSpr)
		end
		mjTilesReferPos.groupStartPos = cc.pAdd(mjTilesReferPos.groupStartPos, mjTilesReferPos.groupSpace)
		mjTilesReferPos.holdStart = cc.pAdd(mjTilesReferPos.holdStart, mjTilesReferPos.groupSpace)

		-- 更新持有牌
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
			mjTilesCount = 2
		end
		if isZhiDui then
			mjTilesCount = 2
		end
		self:removeHoldMjTiles(roomPlayer, mjColor, mjNumber, mjTilesCount)
	else
		local isEat = false
		if type(roomPlayer) == "number" then
			roomPlayer = self.roomPlayers[roomPlayer]
			isEat = true
		end

		gt.log("录像显示碰杠 222======== 玩家是："..roomPlayer.displayIdx)

		local mjTilesReferPos = roomPlayer.mjTilesReferPos
		-- 显示碰杠牌
		local groupMjTilesPos = mjTilesReferPos.groupMjTilesPos
		groupNode = cc.Node:create()
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
		if isEat == true then
			for i = 1, mjTilesCount do
				-- local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displayIdx, mjColor, mjNumber[i][1])
				local mjTileName = Utils.getMJTileResName(roomPlayer.displayIdx, mjColor, mjNumber[i][1],self.isHZLZ)
				local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
				mjTileSpr:setPosition(groupMjTilesPos[i])
				-- if tonumber(roomPlayer.displayIdx) == 2 then
				-- 	--如果是对门玩家的牌,改成正的牌之后要缩小
				-- 	gt.log("如果是对门玩家的牌,改成正的牌之后要缩小 222")
				-- 	mjTileSpr:setScale(0.66)
				-- end
				if tonumber(roomPlayer.displayIdx) == 1 then
					mjTileSpr:setScale(0.8)
				elseif tonumber(roomPlayer.displayIdx) == 2 then
					mjTileSpr:setScale(0.66)
				elseif tonumber(roomPlayer.displayIdx) == 3 then
					mjTileSpr:setScale(0.8)
				end
				groupNode:addChild(mjTileSpr)
			end
			mjTilesReferPos.groupStartPos = cc.pAdd(mjTilesReferPos.groupStartPos, mjTilesReferPos.groupSpace)
			mjTilesReferPos.holdStart = cc.pAdd(mjTilesReferPos.holdStart, mjTilesReferPos.groupSpace)

			-- 更新持有牌
			self:removeHoldMjTiles(roomPlayer, mjColor, mjNumber[1][1], 1)
			self:removeHoldMjTiles(roomPlayer, mjColor, mjNumber[3][1], 1)
		else
			gt.log("录像显示碰杠 333======== 玩家是："..roomPlayer.displayIdx)
			for i = 1, mjTilesCount do
				-- local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displayIdx, mjColor, mjNumber)
				local mjTileName = Utils.getMJTileResName(roomPlayer.displayIdx, mjColor, mjNumber, self.isHZLZ)
				if isBar and not isBrightBar and i <= 3 then
					-- 暗杠前三张牌扣着
					if roomPlayer.displayIdx == 1 or roomPlayer.displayIdx == 3 then
						mjTileName = string.format("tdbgsgang_%d.png", roomPlayer.displayIdx)
					else
						mjTileName = string.format("tdbgs_%d.png", roomPlayer.displayIdx)
					end
				end
				local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
				mjTileSpr:setPosition(groupMjTilesPos[i])
				-- if tonumber(roomPlayer.displayIdx) == 2 then
				-- 	--如果是对门玩家的牌,改成正的牌之后要缩小
				-- 	gt.log("如果是对门玩家的牌,改成正的牌之后要缩小 333")
				-- 	mjTileSpr:setScale(0.66)
				-- end
				if tonumber(roomPlayer.displayIdx) == 1 then
					mjTileSpr:setScale(0.8)
				elseif tonumber(roomPlayer.displayIdx) == 2 then
					mjTileSpr:setScale(0.66)
				elseif tonumber(roomPlayer.displayIdx) == 3 then
					mjTileSpr:setScale(0.8)
				end
				groupNode:addChild(mjTileSpr)
			end
			mjTilesReferPos.groupStartPos = cc.pAdd(mjTilesReferPos.groupStartPos, mjTilesReferPos.groupSpace)
			if roomPlayer.displayIdx == 2 or roomPlayer.displayIdx == 4 then
				mjTilesReferPos.holdStart = cc.pAdd(mjTilesReferPos.holdStart, mjTilesReferPos.groupSpace)
			end

			-- 更新持有牌
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
				mjTilesCount = 2
			end
			if isZhiDui then
				mjTilesCount = 2
			end
			self:removeHoldMjTiles(roomPlayer, mjColor, mjNumber, mjTilesCount)
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
function PlayManager:changePungToBrightBar(seatIdx, mjColor, mjNumber)

	if self.playType == 3 or self.playType == 4 or self.playType == 5 or self.playType == 9 then
		-- 长沙麻将里面杠之后回出牌，需要记录此值
		self.prePlaySeatIdx = seatIdx
	end

	local roomPlayer = self.roomPlayers[seatIdx]
	gt.log("录像显示自摸碰变成明杠 ======== 玩家是："..roomPlayer.displayIdx)
	-- 从持有牌中移除
	self:removeHoldMjTiles(roomPlayer, mjColor, mjNumber, 1)

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

	-- 添加到明杠列表
	if brightBarData then
		-- 加入杠牌第4个牌
		local mjTilesReferPos = roomPlayer.mjTilesReferPos
		local groupMjTilesPos = mjTilesReferPos.groupMjTilesPos
		-- local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displayIdx, mjColor, mjNumber)
		local mjTileName = Utils.getMJTileResName(roomPlayer.displayIdx, mjColor, mjNumber, self.isHZLZ)
		local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
		mjTileSpr:setPosition(groupMjTilesPos[4])
		-- if tonumber(roomPlayer.displayIdx) == 2 then
		-- 	--如果是对门玩家的牌,改成正的牌之后要缩小
		-- 	gt.log("如果是对门玩家的牌,改成正的牌之后要缩小 444")
		-- 	mjTileSpr:setScale(0.66)
		-- end
		if tonumber(roomPlayer.displayIdx) == 1 then
			mjTileSpr:setScale(0.8)
		elseif tonumber(roomPlayer.displayIdx) == 2 then
			mjTileSpr:setScale(0.66)
		elseif tonumber(roomPlayer.displayIdx) == 3 then
			mjTileSpr:setScale(0.8)
		end
		brightBarData.groupNode:addChild(mjTileSpr)
		table.insert(roomPlayer.mjTileBrightBars, brightBarData)
	end
end

function PlayManager:updateOutMjTilesPosition(seatIdx)
	local roomPlayer = self.roomPlayers[seatIdx]
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.outStart

	-- if self.playersType == 3 then
	-- 	if roomPlayer.displayIdx == 4 then
	-- 		mjTilePos.x = 410
	-- 	end
	-- end

	for k, v in pairs(roomPlayer.outMjTiles) do
		-- 显示已出牌
		local lineCount = math.ceil(k / mjTilePerLine[self.playersType][roomPlayer.displayIdx].lineCount) - 1
		local lineIdx = k - lineCount * mjTilePerLine[self.playersType][roomPlayer.displayIdx].lineCount - 1
		-- local lineCount = math.ceil(#roomPlayer.outMjTiles / mjTilePerLine) - 1
		-- local lineIdx = #roomPlayer.outMjTiles - lineCount * mjTilePerLine - 1
		local tilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
		tilePos = cc.pAdd(tilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))
		v.mjTileSpr:setPosition(tilePos)
		if roomPlayer.displayIdx == 1 then
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
function PlayManager:removePrePlayerOutMjTile(color, number)
	-- gt.log("要移除的牌" .. color .. ":" .. number .. ", self.prePlaySeatIdx = " .. self.prePlaySeatIdx)
	-- 移除上家打出的牌
	if self.prePlaySeatIdx then
		local roomPlayer = self.roomPlayers[self.prePlaySeatIdx]
		for i = #roomPlayer.outMjTiles, 1, -1 do
			local outMjTile = roomPlayer.outMjTiles[i]
			if outMjTile.mjColor == color and outMjTile.mjNumber == number then
				outMjTile.mjTileSpr:removeFromParent()
				table.remove(roomPlayer.outMjTiles, i)
				self:updateOutMjTilesPosition(self.prePlaySeatIdx)
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
-- @description 显示玩家接炮胡，自摸胡，明杠，暗杠，碰动画显示
-- @param seatIdx 座位索引
-- @param decisionType 决策类型
-- end --
function PlayManager:showDecisionAnimation(seatIdx, decisionType)
	-- gt.log("当前录像玩法" .. self.playType .. " 玩家" .. seatIdx .. " 可决策" .. decisionType)
	-- if self.playType == gt.RoomType.ROOM_CHANGSHA or self.playType == 4 or self.playType == 5 or self.playType == 9 then
	if true then
		if self.playType == 9 then
			if decisionType == 7 then
				decisionType = 3
			elseif decisionType == 8 then
				decisionType = 4
			end
		end
		-- 接炮胡，自摸胡，明杠，暗杠，碰文件后缀
		local decisionSuffixs = {1, 4, 2, 2, 3, 5, 6, 6}
		local decisionSfx = {"hu", "zimo", "gang", "gang", "peng" ,"chi", "buzhang", "buzhang" }
		-- 显示决策标识
		local roomPlayer = self.roomPlayers[seatIdx]
		print(debug.traceback())
		local decisionSignSpr = cc.Sprite:createWithSpriteFrameName(string.format("decision_sign_cs_%d.png", decisionSuffixs[decisionType]))

		if decisionSignSpr == nil then
           return
		end
		
		decisionSignSpr:setPosition(roomPlayer.mjTilesReferPos.showMjTilePos)
		self.rootNode:addChild(decisionSignSpr, gt.PlayZOrder.DECISION_SHOW)
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

		-- 播放全屏动画
		if decisionType == gt.DecisionType.BRIGHT_BAR then
			if not self.brightBarAnimateNode then
				local brightBarAnimateNode, brightBarAnimate = gt.createCSAnimation("animation/BrightBar.csb")
				self.brightBarAnimateNode = brightBarAnimateNode
				self.brightBarAnimate = brightBarAnimate
				self.rootNode:addChild(brightBarAnimateNode, gt.PlayZOrder.MJBAR_ANIMATION)
			end
			self.brightBarAnimate:play("run", false)
		elseif decisionType == gt.DecisionType.DARK_BAR then
			if not self.darkBarAnimateNode then
				local darkBarAnimateNode, darkBarAnimate = gt.createCSAnimation("animation/DarkBar.csb")
				self.darkBarAnimateNode = darkBarAnimateNode
				self.darkBarAnimate = darkBarAnimate
				self.rootNode:addChild(darkBarAnimateNode, gt.PlayZOrder.MJBAR_ANIMATION)
			end
			self.darkBarAnimate:play("run", false)
		end

		-- dj revise
		gt.soundManager:PlaySpeakSound(roomPlayer.sex, decisionSfx[decisionType])
		-- -- 播放音效
		-- if roomPlayer.sex == 1 then
		-- 	-- 男性
		-- 	gt.soundEngine:playEffect(string.format("changsha/man/%s", decisionSfx[decisionType]))
		-- else
		-- 	-- 女性
		-- 	gt.soundEngine:playEffect(string.format("changsha/woman/%s", decisionSfx[decisionType]))
		-- end
	else
		gt.log("转转")
		local roomPlayer = self.roomPlayers[seatIdx]

		if decisionType == 7 then
			decisionType = 3
		end
		if decisionType == 8 then
			decisionType = 4
		end
		-- 接炮胡，自摸胡，明杠，暗杠，碰文件后缀
		local decisionSuffixs = {1, 4, 2, 2, 3}
		local decisionSfx = {"hu", "zimo", "gang", "angang", "peng"}
		-- 显示决策标识
		local decisionSignSpr = cc.Sprite:createWithSpriteFrameName(string.format("decision_sign_%d.png", decisionSuffixs[decisionType]))
		decisionSignSpr:setPosition(roomPlayer.mjTilesReferPos.showMjTilePos)
		self.rootNode:addChild(decisionSignSpr, gt.PlayZOrder.DECISION_SHOW)
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

		-- 播放全屏动画
		if decisionType == gt.DecisionType.BRIGHT_BAR then
			if not self.brightBarAnimateNode then
				local brightBarAnimateNode, brightBarAnimate = gt.createCSAnimation("animation/BrightBar.csb")
				self.brightBarAnimateNode = brightBarAnimateNode
				self.brightBarAnimate = brightBarAnimate
				self.rootNode:addChild(brightBarAnimateNode, gt.PlayZOrder.MJBAR_ANIMATION)
			end
			self.brightBarAnimate:play("run", false)
		elseif decisionType == gt.DecisionType.DARK_BAR then
			if not self.darkBarAnimateNode then
				local darkBarAnimateNode, darkBarAnimate = gt.createCSAnimation("animation/DarkBar.csb")
				self.darkBarAnimateNode = darkBarAnimateNode
				self.darkBarAnimate = darkBarAnimate
				self.rootNode:addChild(darkBarAnimateNode, gt.PlayZOrder.MJBAR_ANIMATION)
			end
			self.darkBarAnimate:play("run", false)
		end

		-- dj revise
		gt.soundManager:PlaySpeakSound(roomPlayer.sex, decisionSfx[decisionType])

		-- -- 播放音效
		-- if roomPlayer.sex == 1 then
		-- 	-- 男性
		-- 	gt.soundEngine:playEffect(string.format("man/%s", decisionSfx[decisionType]))
		-- else
		-- 	-- 女性
		-- 	gt.soundEngine:playEffect(string.format("woman/%s", decisionSfx[decisionType]))
		-- end
	end
end

-- start --
--------------------------------
-- @class function
-- @description 展示杠两张牌
-- end --
function PlayManager:showBarTwoCardAnimation(seatIdx,cardList,isQuick)
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
	self.rootNode:addChild(image_bg,gt.PlayZOrder.HAIDILAOYUE)
	image_bg:setScale(0)
	-- 设置坐标位置
	local  m_curPos_x = 1
	local  m_curPos_y = 1
	if roomPlayer.displayIdx == 1 or roomPlayer.displayIdx == 3 then
		m_curPos_x = roomPlayer.mjTilesReferPos.holdStart.x
		m_curPos_y = roomPlayer.mjTilesReferPos.showMjTilePos.y
	elseif roomPlayer.displayIdx == 2 or roomPlayer.displayIdx == 4 then
		m_curPos_x = roomPlayer.mjTilesReferPos.showMjTilePos.x
		m_curPos_y = roomPlayer.mjTilesReferPos.showMjTilePos.y
	end

	-- image_bg:setPosition(roomPlayer.mjTilesReferPos.showMjTilePos)
	image_bg:setPosition(cc.p(m_curPos_x,m_curPos_y))

	-- 添加两个麻将
	-- gt.log("添加两个麻将")
	gt.dump(cardList)
	for _,v in pairs(cardList) do
		-- gt.log("88888888888")
		gt.log(v[1])
		gt.log(v[2])
		-- local mjSprName = string.format("p4s%d_%d.png", v[1], v[2])
		local mjSprName = Utils.getMJTileResName(4, v[1], v[2],self.isHZLZ)
		local image_mj = ccui.Button:create()
		image_mj:loadTextures(mjSprName,mjSprName,"",ccui.TextureResType.plistType)
    	image_mj:setAnchorPoint(cc.p(0,0))
    	image_mj:setPosition(cc.p(15+width_oneMJ*(_-1), 10))
   		image_bg:addChild(image_mj)
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
		for idx,data in pairs(cardList) do
			if 1 == idx then
   				self:discardsOneCard(seatIdx,data[1], data[2])
   				break
   			end
		end
	end)
	local delayTime_f_s = cc.DelayTime:create(0.7)
	local callFunc_present_second = cc.CallFunc:create(function(sender)
		-- 打出第二张牌
		for idx,data in pairs(cardList) do
			if 2 == idx then
   				self:discardsOneCard(seatIdx,data[1], data[2])
   				break
   			end
		end
	end)
	local callFunc_remove = cc.CallFunc:create(function(sender)
		-- 播放完后移除
		sender:removeFromParent()
	end)

	if isQuick then
		-- 快进快退
		self:discardsOneCard(seatIdx,cardList[1][1], cardList[1][2])
		self:discardsOneCard(seatIdx,cardList[2][1], cardList[2][2])
		image_bg:removeFromParent()
	else
		local seqAction = cc.Sequence:create(easeBackAction, present_delayTime, fadeOutAction, callFunc_dontPresent,
			callFunc_present_first, delayTime_f_s, callFunc_present_second,callFunc_remove)
		image_bg:runAction(seqAction)
	end
end

function PlayManager:discardsOneCard(seatIdx,mjColor,mjNumber)
	local roomPlayer = self.roomPlayers[seatIdx]
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.holdStart

	-- 显示出的牌
	self:outMjTile(roomPlayer, mjColor, mjNumber)
	-- 显示出的牌箭头标识
	self:showOutMjtileSign(roomPlayer)

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
function PlayManager:showStartDecisionAnimation(seatIdx, decisionType, showCard)
	-- 接炮胡，自摸胡，明杠，暗杠，碰文件后缀
	local decisionSuffixs = {1, 4, 2, 2, 3}
	local decisionSfx = {"queyise", "banbanhu", "sixi", "liuliushun"}
	-- 显示决策标识
	local roomPlayer = self.roomPlayers[seatIdx]
	local decisionSignSpr = cc.Sprite:createWithSpriteFrameName(string.format("tile_cs_%s.png", decisionSfx[decisionType]))
	decisionSignSpr:setPosition(roomPlayer.mjTilesReferPos.showMjTilePos)
	self.rootNode:addChild(decisionSignSpr, gt.PlayZOrder.DECISION_SHOW)
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
	if decisionType == gt.StartDecisionType.TYPE_QUEYISE then
		copyNum = 1
	elseif decisionType == gt.StartDecisionType.TYPE_BANBANHU then
		copyNum = 1
	elseif decisionType == gt.StartDecisionType.TYPE_DASIXI then
		copyNum = 4
	elseif decisionType == gt.StartDecisionType.TYPE_LIULIUSHUN then
		copyNum = 3
	end

	local groupNode = cc.Node:create()
	groupNode:setCascadeOpacityEnabled( true )
	groupNode:setPosition( roomPlayer.mjTilesReferPos.showMjTilePos )
	self.playMjLayer:addChild(groupNode)

	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	-- local demoSpr = cc.Sprite:createWithSpriteFrameName(string.format("p%ds%d_%d.png", roomPlayer.displayIdx, 1, 1))
	local demoSpr = cc.Sprite:createWithSpriteFrameName(Utils.getMJTileResName(roomPlayer.displayIdx, 1, 1,self.isHZLZ))
	local tileWidthX = 0
	local tileWidthY = 0
	if roomPlayer.displayIdx == 1 then
		tileWidthX = 0
		tileWidthY = mjTilesReferPos.outSpaceH.y--demoSpr:getContentSize().height
	elseif roomPlayer.displayIdx == 2 then
		tileWidthX = -demoSpr:getContentSize().width
		tileWidthY = 0
	elseif roomPlayer.displayIdx == 3 then
		tileWidthX = 0
		tileWidthY = -mjTilesReferPos.outSpaceH.y--demoSpr:getContentSize().height
	elseif roomPlayer.displayIdx == 4 then
		tileWidthX = demoSpr:getContentSize().width
		tileWidthY = 0
	end

	-- -- 自己测试走这里
	-- local totalWidthX = (#showCard*copyNum)*tileWidthX
	-- local totalWidthY = (#showCard*copyNum)*tileWidthY
	-- for i,v in ipairs(showCard) do
	-- 	for j=1,copyNum do
	-- 		local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displaySeatIdx, v[1], v[2])
	-- 		local mjTileSpr = cc.Sprite:createWithSpriteFrameName( mjTileName )
	-- 		mjTileSpr:setPosition( cc.p(tileWidthX*(j-1)+(i-1)*copyNum*tileWidthX,tileWidthY*(j-1)+(i-1)*copyNum*tileWidthY) )
	-- 		groupNode:addChild( mjTileSpr, (gt.winSize.height - mjTileSpr:getPositionY()) )
	-- 	end
	-- end
	-- groupNode:setPosition( cc.pAdd( roomPlayer.mjTilesReferPos.showMjTilePos, cc.p(-totalWidthX/2,-totalWidthY/2) ) )

	-- 服务器返回消息
	local totalWidthX = (#showCard)*tileWidthX
	local totalWidthY = (#showCard)*tileWidthY

	for i,v in ipairs(showCard) do
		-- local mjTileName = string.format("p%ds%d_%d.png", roomPlayer.displayIdx, v[1], v[2])
		local mjTileName = Utils.getMJTileResName(roomPlayer.displayIdx, v[1], v[2],self.isHZLZ)
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

	-- 播放音效,没有资源,暂时用暗杠来代替
	-- dj revise
	gt.soundManager:PlaySpeakSound(roomPlayer.sex, decisionSfx[decisionType])
	-- if roomPlayer.sex == 1 then
	-- 	-- 男性
	-- 	gt.soundEngine:playEffect(string.format("changsha/man/%s", decisionSfx[decisionType]))
	-- else
	-- 	-- 女性
	-- 	gt.soundEngine:playEffect(string.format("changsha/woman/%s", decisionSfx[decisionType]))
	-- end
end

-- -- start --
-- --------------------------------
-- -- @class function
-- -- @description 显示指示出牌标识箭头动画
-- -- @param seatIdx 座次
-- -- end --
-- function PlayManager:showOutMjtileSign(roomPlayer)
-- 	-- local roomPlayer = self.roomPlayers[seatIdx]
-- 	local endIdx = #roomPlayer.outMjTiles
-- 	local outMjTile = roomPlayer.outMjTiles[endIdx]
-- 	self.outMjtileSignNode:setVisible(true)
-- 	self.outMjtileSignNode:setPosition(outMjTile.mjTileSpr:getPosition())
-- end

-- start --
--------------------------------
-- @class function
-- @description 显示指示出牌标识箭头动画
-- @param seatIdx 座次
-- end --
function PlayManager:showOutMjtileSign(roomPlayer)
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
-- @description 显示出牌动画
-- @param seatIdx 座次
-- end --
function PlayManager:showOutMjTileAnimation(roomPlayer, mjColor, mjNumber, cbFunc)
	local rotateAngle = {-90, 180, 90, 0}

	-- local mjTileName = string.format("p4s%d_%d.png", mjColor, mjNumber)
	local mjTileName = Utils.getMJTileResName(4, mjColor, mjNumber,self.isHZLZ)
	local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
	self.rootNode:addChild(mjTileSpr, 98)

	-- 出牌位置
	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.holdStart
	if #roomPlayer.lisiMjTiles > 0 then
		mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, #roomPlayer.lisiMjTiles))
		mjTilePos = cc.pAdd(mjTilePos, cc.p(25, 0))
	end
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.holdSpace, #roomPlayer.holdMjTiles))
	mjTilePos = cc.pAdd(mjTilePos, mjTilesReferPos.drawSpace)
	mjTileSpr:setPosition(mjTilePos)
	mjTileSpr:setRotation(rotateAngle[roomPlayer.displayIdx])
	local moveToAc_1 = cc.MoveTo:create(0.3, roomPlayer.mjTilesReferPos.showMjTilePos)
	local rotateToAc_1 = cc.RotateTo:create(0.3, 0)
	local scaleTO_1 = cc.ScaleTo:create( 0.3, 1.3 )

	local delayTime = cc.DelayTime:create(1.3)

	local mjTilesReferPos = roomPlayer.mjTilesReferPos
	local mjTilePos = mjTilesReferPos.outStart

	-- if self.playersType == 3 then
	-- 	if roomPlayer.displayIdx == 4 then
	-- 		mjTilePos.x = 410
	-- 	end
	-- end

	local mjTilesCount = #roomPlayer.outMjTiles + 1
	local lineCount = math.ceil(mjTilesCount / mjTilePerLine[self.playersType][roomPlayer.displayIdx].lineCount) - 1
	local lineIdx = mjTilesCount - lineCount * mjTilePerLine[self.playersType][roomPlayer.displayIdx].lineCount - 1
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceV, lineCount))
	mjTilePos = cc.pAdd(mjTilePos, cc.pMul(mjTilesReferPos.outSpaceH, lineIdx))


	local moveToAc_2 = cc.MoveTo:create(0.3, mjTilePos)
	local rotateToAc_2 = cc.RotateTo:create(0.15, rotateAngle[roomPlayer.displayIdx])
	local callFunc = cc.CallFunc:create(function(sender)
		sender:removeFromParent()

		cbFunc()
	end)

	-- 渐隐消失

	mjTileSpr:runAction(cc.Sequence:create(cc.Spawn:create( cc.Spawn:create(moveToAc_1,scaleTO_1), rotateToAc_1),
										delayTime,
										-- cc.Spawn:create(moveToAc_2, rotateToAc_2),
										cc.FadeOut:create( 0.5 ),
										callFunc));
end

-- seatIdx: 1~4 的数值　
function PlayManager:getDisplaySeat(seatIdx)
	-- 由于会旋转，所以重新处理
	gt.log("传入" .. self.playerSeatIdx .. " " .. seatIdx.."  self.playersType:==" .. self.playersType)

	local displaySeatIdx = 1
	-- 当前出牌座位
	if self.playersType == 2 then
		if self.playerSeatIdx == 1 then
			if seatIdx == 2 then
				displaySeatIdx = 3
			end
		elseif self.playerSeatIdx == 2 then
			if seatIdx == 1 then
				displaySeatIdx = 4
			else
				displaySeatIdx = 2
			end
		end
	elseif self.playersType == 3 then
		if self.playerSeatIdx == 1 then
			if seatIdx == 2 then
				displaySeatIdx = 2
			elseif seatIdx == 3 then
				displaySeatIdx = 4
			end
		elseif self.playerSeatIdx == 2 then
			if seatIdx == 3 then
				displaySeatIdx = 3
			elseif seatIdx == 1 then
				displaySeatIdx = 1
			else
				displaySeatIdx = 2
			end
		elseif self.playerSeatIdx == 3 then
			if seatIdx == 1 then
				displaySeatIdx = 4
			elseif seatIdx == 2 then
				displaySeatIdx = 2
			else
				displaySeatIdx = 3
			end
		end
	else
		displaySeatIdx = seatIdx
	end
	-- gt.log("当前玩家" .. self.playerSeatIdx .. " " .. seatIdx .. " 返回" .. displaySeatIdx)
	return displaySeatIdx
end

--------------------------
--已出牌金牌标志
function PlayManager:addJinKuangMjSpr(seatIdx, mjTile)
	if self.haoziCard ~= nil and self.m_state == 100003 then
		for j,v in ipairs(self.haoziCard) do
			if v[1] == mjTile.mjColor and v[2] == mjTile.mjNumber then
				local imgfile = ""
				gt.log("出牌加金框 =="..seatIdx.." "..mjTile.mjColor.." ".. mjTile.mjNumber)
				if seatIdx == 1 or seatIdx == 3 then
					imgfile = "sx_img_table_jin_heng.png"
				elseif seatIdx == 4 or seatIdx == 2 then	
					imgfile = "sx_img_table_jin_li.png"
				end

				local imgkuang = mjTile.mjTileSpr:getChildByName("img_table_jinkuang")
				if not imgkuang then
					imgkuang = ccui.ImageView:create()		
					imgkuang:setAnchorPoint(0.5,0.5)
					imgkuang:setName("img_table_jinkuang")
					mjTile.mjTileSpr:addChild(imgkuang)		
				end
				if imgkuang then
					imgkuang:loadTexture(imgfile,1)
					local mjSize = mjTile.mjTileSpr:getContentSize()
					local imgSize = imgkuang:getContentSize()
					imgkuang:setPosition(mjSize.width/2, mjSize.height/2+3)
					if seatIdx == 1 then
						imgkuang:setScale(0.90)
					elseif seatIdx == 3 then
						imgkuang:setFlippedX(true)
						imgkuang:setScale(0.90)
					else
						imgkuang:setScale(1.5)
					end
				end
			end
		end
	end
end


-----------------------
--截取字符串
--@return 截取需要显示的字符串成多段
function PlayManager:getCutString(sName,nShowCount)
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
        local byteCount = 0;
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

return PlayManager

