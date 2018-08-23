

local gt = cc.exports.gt

local ReplayLayer = class("ReplayLayer", function()
	return cc.Layer:create()
end)

function ReplayLayer:ctor(replayData)
	gt.dump(replayData)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	print("--------------------------replayData")
	gt.dump(replayData)
	self.replayStepsData = replayData.kOper
    
	-- 加载界面资源
	local csbNode = cc.CSLoader:createNode("ReplayLayer.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

    local explainNode = gt.seekNodeByName(csbNode,"Node_explain")
    explainNode:setZOrder(999)

	-- 二三人转转需求
	for i = 1, 4 do
		local playerNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo_" .. i)
		self.rootNode:reorderChild(playerNode, 999)
		playerNode:setVisible(false)
	end
    
	-- local roundStateNode = gt.seekNodeByName(self.rootNode, "Node_roundState")
	-- local remainTilesLabel = gt.seekNodeByName(roundStateNode, "Label_remainRounds")
	-- remainTilesLabel:setString(string.format("%d/%d", (replayData.m_curCircle + 1), replayData.m_maxCircle))

	-- 容错处理，默认1
	self.playerSeatIdx = 1
	for seatIdx, uid in ipairs(replayData.kUserid) do
		if gt.playerData.uid == uid then
			self.playerSeatIdx = seatIdx
			break
		end
	end
  
	if not replayData.kState then
		replayData.kState = 1
	end

	self.playType = replayData.kState


	--耗子牌显示节点
	local Node_dabao  = gt.seekNodeByName(csbNode, "Node_dabao")
	local Image_logo = gt.seekNodeByName(csbNode, "Image_logo")

	local Spr_mjTile1 = gt.seekNodeByName(Node_dabao, "Spr_mjTile1")
	local Spr_mjTile2 = gt.seekNodeByName(Node_dabao, "Spr_mjTile2")
	Node_dabao:hide()
	Image_logo:show()
	Spr_mjTile1:hide()
	Spr_mjTile2:hide()

	self.haoziCard = nil
	--从第一步操作中取出数据判断是否有耗子牌或者贴近牌
	local haoziData = replayData.kOper[1]
	gt.dump(haoziData)
	if haoziData[2] == 70 then
		self.haoziCard = haoziData[3]
		Node_dabao:show()
		Image_logo:hide()
		cc.SpriteFrameCache:getInstance():addSpriteFrames("images/create_room_new.plist")
		Spr_mjTile1:show()
		local mjTileName1 = Utils.getMJTileResName(4, self.haoziCard[1][1], self.haoziCard[1][2], false)
		Spr_mjTile1:initWithSpriteFrameName(mjTileName1)
		self:addMouseMark(Spr_mjTile1)
		if #self.haoziCard > 1 then
			Spr_mjTile1:setPositionX(-25)
			Spr_mjTile2:show()
			local mjTileName2 = Utils.getMJTileResName(4, self.haoziCard[2][1], self.haoziCard[2][2], false)
			Spr_mjTile2:initWithSpriteFrameName(mjTileName2)
			Spr_mjTile2:setPositionX(25)
			self:addMouseMark(Spr_mjTile2)
		end
		gt.log("self.m_state:"..replayData.kState)
		if replayData.kState == 100003 then  -- 贴金
			Img_name1:loadTexture("sx_txt_table_jin.png",ccui.TextureResType.plistType)
			Img_name2:loadTexture("sx_txt_table_jin.png",ccui.TextureResType.plistType)
			Img_name1:setContentSize(cc.size(20,19))
			Img_name2:setContentSize(cc.size(20,19))
		end
	else
		Node_dabao:hide()
		Image_logo:show()
	end

	local paramTbl = {}
	paramTbl.roomID 		= replayData.kDeskId
	paramTbl.m_state 		= replayData.kState
	paramTbl.playerSeatIdx 	= self.playerSeatIdx
	paramTbl.m_playtype 	= replayData.kPlaytype
	paramTbl.m_zhuang 		= replayData.kZhuang
	paramTbl.haoziCard  	= self.haoziCard
	gt.dump( paramTbl.m_playtype )
	self.playManager = require("client/game/majiang/PlayManager"):create(self.rootNode, paramTbl)

	self.m_text_progress = gt.seekNodeByName(csbNode, "Text_progress")
	self.m_text_progress:setVisible(false)

	self:initRoomPlayersData(replayData)
	self.replayData = replayData

	if self.playerSeatIdx < 5 then
	    local turnPosBgSpr = gt.seekNodeByName(csbNode,"Spr_turnPosBg")
	    turnPosBgSpr:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("sx_img_table_turntable"..self.playerSeatIdx..".png"))
	end

	-- 更新打牌时间
	-- self.time_now = 1469700778
	self.time_now = replayData.kTime
	self.holdTime = 0
	self:updateCurrentTime()
	

	self.isPause = false
	local optBtnsSpr = gt.seekNodeByName(csbNode, "Spr_optBtns")
	optBtnsSpr:setLocalZOrder(10)
	-- 播放按键
	local playBtn = gt.seekNodeByName(optBtnsSpr, "Btn_play")
	playBtn:setVisible(false)
	self.playBtn = playBtn
	-- 暂停
	local pauseBtn = gt.seekNodeByName(optBtnsSpr, "Btn_pause")
	self.pauseBtn = pauseBtn
	gt.addBtnPressedListener(playBtn, function()
		self:setPause(false)
	end)
	gt.addBtnPressedListener(pauseBtn, function()
		self:setPause(true)
	end)
	-- 退出
	local exitBtn = gt.seekNodeByName(optBtnsSpr, "Btn_exit")
	gt.addBtnPressedListener(exitBtn, function()
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

	-- 快进或者快退的步数
	self.quickStepNum	= 8
	-- 点击快进/快退开始的时间
	self.quickStartTime = 0

	--飘
	if self.playType==12 then
		if  #self.replayStepsData~=0 then
			local seatIdxT = self.playManager:addPiaoNum()
		    local piaoNode=gt.seekNodeByName(self.rootNode,"Node_piao")
		    local piaoTexts=gt.seekNodeByName(piaoNode,"Node_piao_num")
		    if  self.replayStepsData[1][2] == 63 then
                for i=1,4 do
		    	local piaoText = gt.seekNodeByName(piaoTexts, "Num_piao_" .. seatIdxT[i])
		    		if  self.replayStepsData[1][3][i] then
				    	if self.replayStepsData[1][3][i][2]~=0 then
				    	   piaoText:setString("飘".. self.replayStepsData[1][3][i][2] .."分")
				    	else
						   piaoText:setString("不飘")
					    end
				    end
		        end
		    end
		end
    end
end

function ReplayLayer:addMouseMark(mjTileSpr)
	local imgname = "img_table_mouse"
	local imgfile = ""
	if self.playType == 100002 or self.playType == 100009 then
		imgfile = "sx_img_table_mouse.png"
	elseif self.playType == 100003 then
		imgfile = "sx_img_table_jin.png"
	end
	if not mjTileSpr:getChildByName(imgname) then
		local imgtablemouse = ccui.ImageView:create(imgfile,1)
		imgtablemouse:setName(imgname)
		local mjsize = mjTileSpr:getContentSize()
		local tablemousesize = imgtablemouse:getContentSize()
		imgtablemouse:setScale(0.66)
		imgtablemouse:setPosition(mjsize.width - tablemousesize.width/2,mjsize.height - tablemousesize.height + 18)
		mjTileSpr:addChild(imgtablemouse)
	end
end

function ReplayLayer:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

		-- 逻辑更新定时器
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)

		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function ReplayLayer:onTouchBegan(touch, event)
	return true
end

-- 快推的话,原理是将牌恢复到最初始状态
-- 然后快速行进到当前状态
function ReplayLayer:preRound()
	-- -- 如果暂停或者已经结束,是否需要回退
	-- if self.isPause or self.isReplayFinish then
	-- 	return
	-- end

	if self.curReplayStep <= 1 then
		return
	end

	self.quickStartTime = os.time()

	-- 计算回退到何步骤
	local wihldReplayStep = self.curReplayStep - self.quickStepNum
	if wihldReplayStep < 0 then
		wihldReplayStep = 0
	end

	-- 清理桌面上的牌
	self.playManager:cleanMjFormLayer()
	self:initRoomPlayersData(self.replayData)
	-- 步数设置为1
	self.curReplayStep = 1

	for i=1,wihldReplayStep do
		if not self.isReplayFinish then
			self:doAction( self.curReplayStep, true, true )
		end
	end
end

-- 快速回合播放
function ReplayLayer:nextRound()
	-- -- 如果暂停或者已经结束,是否需要回退
	-- if self.isPause or self.isReplayFinish then
	-- 	return
	-- end
	self.quickStartTime = os.time()

	for i=1,self.quickStepNum do
		if not self.isReplayFinish then
			self:doAction( self.curReplayStep, true )
		end
	end
end

function ReplayLayer:doAction( curReplayStep, isQuick, isPre )
	local replayStepData = self.replayStepsData[curReplayStep]

	gt.log("录像回放   doAction ============= ")
	gt.dump(replayStepData)

	-- 快进快退时不展示杠之后的牌
	if not isQuick then
		-- 如果展示杠后的两张牌则需要3秒
		if replayStepData[2] == 18 then
			self.showDelayTime = -2
		end
	end

	local seatIdx = replayStepData[1] + 1

	local optType = replayStepData[2]
	local mjColor = replayStepData[3][1] and replayStepData[3][1][1] or 0	
	local mjNumber = replayStepData[3][1] and replayStepData[3][1][2] or 0

	gt.log("录像回放   mjNumber = "..mjNumber)

	if self.playType ~= gt.RoomType.ROOM_CHANGSHA and self.playType ~= 4 and self.playType ~= 5 then
		if optType == 11 then -- 明补自己
			optType = 4
		elseif optType == 12 then -- 明补别人
			optType = 6
		elseif optType == 13 then -- 暗补
			optType = 3
		end
	end
	gt.log("录像回放 seatIdx = " .. seatIdx .. ", optType = " .. optType)
	if optType == 1 then
		-- 摸牌
		self.playManager:drawMjTile(seatIdx, mjColor, mjNumber)
	elseif optType == 2 then
		-- 出牌
		if not isQuick then
			self.playManager:playOutMjTile(seatIdx, mjColor, mjNumber)
		else
			self.playManager:playOutMjTileQuick(seatIdx, mjColor, mjNumber)
		end
		--将显示座位号移到这里来进行特殊情况处理，避免造成数据读取错误	
		if seatIdx ~= 101 then   --公共牌，不发给任何玩家
			gt.log("newSeatIdx: == "..seatIdx .. "  m_state:"..self.playType.."  playerSeatIdx:"..self.playerSeatIdx)
			self.playManager:setTurnSeatSign(seatIdx)
		end

	elseif optType == 3 then
		-- 暗杠
		self.playManager:addMjTileBar(seatIdx, mjColor, mjNumber, false)

		if not isQuick then
			self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.DARK_BAR)
		end
	elseif optType == 4 then
		gt.log("---------------------------自摸明杠")
		-- 自摸明杠
		self.playManager:changePungToBrightBar(seatIdx, mjColor, mjNumber)

		if not isQuick then
			self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.BRIGHT_BAR)
		end
	elseif optType == 5 then
		-- 碰
		self.playManager:addMjTilePung(seatIdx, mjColor, mjNumber)

		if not isQuick then
			self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.PUNG)
		end

		self.playManager:removePrePlayerOutMjTile(mjColor, mjNumber)
	elseif optType == 72 then
		-- 粘听
		self.playManager:addMjTileNian(seatIdx, mjColor, mjNumber)

		-- if not isQuick then
		-- 	self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.PUNG)
		-- end

		self.playManager:removePrePlayerOutMjTile(mjColor, mjNumber)
	elseif optType == 73 then
		-- 支对
		self.playManager:addMjTileZhiDui(seatIdx, mjColor, mjNumber)

		-- if not isQuick then
		-- 	self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.PUNG)
		-- end

		self.playManager:removePrePlayerOutMjTile(mjColor, mjNumber)
	elseif optType == 6 then
		-- 别人打的牌,自己可以明杠之
		self.playManager:removePrePlayerOutMjTile(mjColor, mjNumber)
		self.playManager:addMjTileBar(seatIdx, mjColor, mjNumber, true)

		if not isQuick then
			self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.BRIGHT_BAR)
		end

	elseif optType == 7 then
		-- 接炮胡
		self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.TAKE_CANNON_WIN)
	elseif optType == 8 then
		-- 自摸胡
		self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.SELF_DRAWN_WIN)
	elseif optType == 9 then
		-- 流局
	elseif optType == 10 then
		-- 吃
		local eatGroup = {}
		table.insert(eatGroup,{replayStepData[3][1][2], 0, replayStepData[3][1][1]})
		table.insert(eatGroup,{replayStepData[3][2][2], 0, replayStepData[3][1][1]})
		table.insert(eatGroup,{replayStepData[3][3][2], 1, replayStepData[3][1][1]})

		self.playManager:pungBarReorderMjTiles(seatIdx, replayStepData[3][1][1], eatGroup)

		if not isQuick then
			self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.EAT)
		end
		self.playManager:removePrePlayerOutMjTile(replayStepData[3][2][1], replayStepData[3][2][2])
	elseif optType == 11 then
		-- 明补自己
		self.playManager:changePungToBrightBar(seatIdx, mjColor, mjNumber)
		if not isQuick then
			self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.BRIGHT_BU)
		end
	elseif optType == 12 then
		-- 明补他人
		self.playManager:removePrePlayerOutMjTile(mjColor, mjNumber)
		self.playManager:addMjTileBar(seatIdx, mjColor, mjNumber, true)
		if not isQuick then
			self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.BRIGHT_BU)
		end
	elseif optType == 13 then
		-- 暗补
		self.playManager:addMjTileBar(seatIdx, mjColor, mjNumber, false)
		if not isQuick then
			self.playManager:showDecisionAnimation(seatIdx, gt.DecisionType.DARK_BU)
		end
	elseif optType == 14 then
		-- 缺一色小胡
		-- 快退时不显示起手胡
		if isPre ~= true then
			self.playManager:showStartDecisionAnimation(seatIdx, optType-13, replayStepData[3])
		end
	elseif optType == 15 then
		-- 板板胡小胡
		if isPre ~= true then
			self.playManager:showStartDecisionAnimation(seatIdx, optType-13, replayStepData[3])
		end
	elseif optType == 16 then
		-- 四喜小胡
		if isPre ~= true then
			self.playManager:showStartDecisionAnimation(seatIdx, optType-13, replayStepData[3])
		end
	elseif optType == 17 then
		-- 六六顺小胡
		if isPre ~= true then
			self.playManager:showStartDecisionAnimation(seatIdx, optType-13, replayStepData[3])
		end
	elseif optType == 18 then
		-- 显示杠后两张牌
		self.playManager:showBarTwoCardAnimation(seatIdx,replayStepData[3],isQuick)
	elseif optType == 21 then
		-- 玩家思考
		local thinkList = replayStepData[3]
		if thinkList then
			local thinktype = {}
			for i,v in ipairs(thinkList) do
				local desType = v[2]
				if self.playType ~= gt.RoomType.ROOM_CHANGSHA and self.playType ~= 4 and self.playType ~= 5 then
					if desType == 7 then
						desType = 3
					elseif desType == 8 then
						desType = 4
					end
				end

				if desType == 2 then
					-- 胡
					table.insert(thinktype,5)
				elseif desType == 5 then
					-- 碰
					table.insert(thinktype,2)
				elseif desType == 6 then
					-- 吃
					table.insert(thinktype,1)
				elseif desType == 7 or desType == 8 then
					-- 补
					table.insert(thinktype,4)
				elseif desType == 3 or desType == 4 then
					-- 杠
					table.insert(thinktype,3)
				elseif desType == 9 then
					-- 过 海底牌的时候
				end
			end
			table.insert(thinktype,6)
			self.playManager:showMakeDecision(seatIdx,thinktype,isQuick)
		end
	elseif optType == 22 then
		-- 玩家思考结果
		local thinkOpt = replayStepData[3][1][2]
		local userChooseDecisionType
		if self.playType ~= gt.RoomType.ROOM_CHANGSHA and self.playType ~= 4 and self.playType ~= 5 then
			if thinkOpt == 7 then
				thinkOpt = 3
			elseif thinkOpt == 8 then
				thinkOpt = 4
			end
		end
		if thinkOpt == 2 then
			-- 胡
			userChooseDecisionType = 5
		elseif thinkOpt == 5 then
			-- 碰
			userChooseDecisionType = 2
		elseif thinkOpt == 6 then
			-- 吃
			userChooseDecisionType = 1
		elseif thinkOpt == 7 or thinkOpt == 8 then
			-- 补
			userChooseDecisionType = 4
		elseif thinkOpt == 3 or thinkOpt == 4 then
			-- 杠
			userChooseDecisionType = 3
		elseif thinkOpt == 9 then
			-- 过 还底牌的时候
			userChooseDecisionType = 6
		elseif thinkOpt == 20 then
			-- 补张 （中 发 赖子）
			userChooseDecisionType = 4
		elseif thinkOpt == 21 then
			-- 过  不要不要啦(中 发 赖子）
			userChooseDecisionType = 6
		elseif thinkOpt == 99 then
			-- 点了过
			userChooseDecisionType = 6
		else
			-- 都认为是点了过
			userChooseDecisionType = 6
		end
		self.playManager:decisionResult(seatIdx,userChooseDecisionType,isQuick)
	elseif optType == 53 then -- 海底提示
		self.playManager:showHaidiDecision(seatIdx,isQuick)
	elseif optType == 54 then -- 海底要
		self.playManager:decisionHaidiResult(seatIdx,true,isQuick)
	elseif optType == 55 then -- 海底过
		self.playManager:decisionHaidiResult(seatIdx,false,isQuick)
	elseif optType == 56 then -- 海底牌展示
		self.playManager:showHaidiResult( replayStepData[3][1][1], replayStepData[3][1][2], isQuick )
	elseif optType == 61 then -- 扎鸟
		self.playManager:showZhanniao(replayStepData[3], isQuick, replayStepData[1])
	end

	self.curReplayStep = self.curReplayStep + 1
	if self.curReplayStep > #self.replayStepsData then
		self.isReplayFinish = true
		self.curReplayStep = #self.replayStepsData
	end
	self:updateProgress()
end

function ReplayLayer:updateProgress()
	gt.log("------------------------------updateProgress1", self.curReplayStep)
	local amount = #self.replayStepsData
	if amount == nil or self.curReplayStep == nil then
		return false
	end
	gt.log("------------------------------updateProgress2", amount)
	-- local number = string.format("%0" .. string.len(amount) .. "d", self.curReplayStep)
	-- self.m_text_progress:setString("进度:" .. number .. "/" .. amount)
	-- self.m_text_progress:setLocalZOrder(10)

	local updateSlider = gt.seekNodeByName(self.rootNode, "Slider_update")
	updateSlider:setLocalZOrder(10)
	updateSlider:setVisible(true)
	local percent = self.curReplayStep/amount*100
	gt.log("---------------percent", percent)
	updateSlider:setPercent(percent)
end

function ReplayLayer:update(delta)
	if self.isPause or self.isReplayFinish then
		return
	end

	if os.time() - self.quickStartTime < 2 then -- 如果已经有2s没有触摸快进/快退按钮了,那么可以播放自动录像了
		return
	end

	self.holdTime = self.holdTime + delta
	--self:updateCurrentTime()

	self.showDelayTime = self.showDelayTime + delta
	if self.showDelayTime > 1.5 then
		self.showDelayTime = 0

		self:doAction( self.curReplayStep )
	end
end

function ReplayLayer:initRoomPlayersData(replayData)
	for seatIdx, uid in ipairs(replayData.kUserid) do
		local roomPlayer = {}
		roomPlayer.seatIdx = seatIdx
		-- if replayData.m_state == 100006 and seatIdx > 2 then --拐三角，2号座位不上人
		-- 	roomPlayer.seatIdx = seatIdx + 1
		-- elseif replayData.m_state == 100012 and seatIdx > 1 then --拐三角，1号位不坐人
		-- 	roomPlayer.seatIdx = seatIdx + 1
		-- end
		roomPlayer.uid = uid
		roomPlayer.nickname = replayData.kNike[seatIdx]
		roomPlayer.headURL = replayData.kImageUrl[seatIdx]
		roomPlayer.sex = replayData.kSex[seatIdx]
		roomPlayer.score = replayData.kScore[seatIdx]

		self.playManager:roomAddPlayer(roomPlayer)

		if replayData.kState == 100004 and seatIdx == self.playerSeatIdx then
			for _, v in ipairs(replayData["kCard" .. (seatIdx - 1)]) do
				self.playManager:addLisiMjTile(roomPlayer, v[1], v[2])
			end
		else
			for _, v in ipairs(replayData["kCard" .. (seatIdx - 1)]) do
				self.playManager:addMjTile(roomPlayer, v[1], v[2])
			end
		end
		if replayData.kState == 100002 and self.haoziCard ~= nil then
			roomPlayer.haoziCard = self.haoziCard
		end
		self.playManager:sortHoldMjTiles(roomPlayer)
	end

	self.curReplayStep = 1
	self.showDelayTime = 2
	self.isReplayFinish = false
	self:updateProgress()
end

function ReplayLayer:setPause(isPause)
	self.isPause = isPause

	self.pauseBtn:setVisible(not isPause)
	self.playBtn:setVisible(isPause)
end

function ReplayLayer:updateCurrentTime()
	local presentTime = math.ceil(self.time_now)
    local timeTbl = os.date("*t", presentTime)
	local timeLabel = gt.seekNodeByName(self, "Label_time")
	-- 时:分
	timeLabel:setString(string.format("%02d-%02d %02d:%02d", timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min))
end

return ReplayLayer

