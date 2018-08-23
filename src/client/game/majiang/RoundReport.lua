
local gt = cc.exports.gt

local Utils = require("client/tools/Utils")
local MJScene=require("client/game/majiang/MJScene")
local RoundReport = class("RoundReport", function()
	return cc.Layer:create()
end)

-- csw 11 - 14 

local CardType = {
1003,-- => "七小对",  --                                                                      
1004,-- => "豪华七小对",                                                                    
1006,-- => "一条龙",                                                                        
1007,-- => "十三幺",                                                                        
1027,-- => "清龙",      --                                                                    
1028,-- => "清七对",     --                                                                   
1029,-- => "字一色",                                                                        
1030,-- => "清豪华七小对",  --                                                                
1055,-- => "楼上楼",                                                                        
2000,-- => "-111分",                                                                        
3000,-- => "+111分",                                                                        
4000-- => "金暗杠",   
}

-- csw 11 - 14 

function RoundReport:ctor(callbackFinal, callbackNext, roomPlayers, playerSeatIdx, rptMsgTbl, isLast, isHZLZ)
	gt.log("单局结算 =================== ")
	gt.dump(rptMsgTbl)
	self:retain()

	self.callbackFinal = callbackFinal
	self.callbackNext = callbackNext

	
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("RoundReport.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
	self.rootNode:retain()

	local roomId=gt.seekNodeByName(csbNode,"Label_room_Id")
	local playType=gt.seekNodeByName(csbNode,"Label_room_type")
	roomId:setString("房号 ".. cc.UserDefault:getInstance():getStringForKey("roomId"))
	
    -- local roomTime=gt.seekNodeByName(csbNode,"Label_Time")
    -- local date=os.date("%Y-%m-%d %H:%M:%S")
    -- roomTime:setString(date)
    --分享
 --    local btn_share=gt.seekNodeByName(csbNode,"Btn_round_share")
 --    gt.addBtnPressedListener(btn_share,function ()
 --    	btn_share:setEnabled(false)
	-- 	self:screenshotShareToWX()
 --    end)
 --    if gt.isInReview == true then
	-- 	btn_share:setVisible(false)
	-- else
	-- 	btn_share:setVisible(true)
	-- end

	-- 结束标题
	self.reportTitleNode = gt.seekNodeByName(csbNode, "Node_reportTitle")
	self.reportTitleNode:retain()
	for _, reportTitleSpr in ipairs(self.reportTitleNode:getChildren()) do
		reportTitleSpr:setVisible(false)
	end
	gt.seekNodeByName(self.reportTitleNode, "Image_bg"):setVisible(true)
	
	-- 按钮屏蔽层
	self.BtnLayer = gt.seekNodeByName(csbNode, "BtnLayer")
	self.BtnLayer:retain()

	self.playerSeatIdx = playerSeatIdx

	-- 开始下一局
	self.startGameBtn = gt.seekNodeByName(csbNode, "Btn_startGame")
	self.startGameBtn:retain()
	gt.addBtnPressedListener(self.startGameBtn, function()
		self:setVisible(false)
		self.BtnLayer:setVisible(false)

		self.startGameBtn:setEnabled(false)
		callbackNext()
		local msgToSend = {}
		msgToSend.kMId = gt.CG_READY
		msgToSend.kPos = self.playerSeatIdx - 1
		gt.socketClient:sendMessage(msgToSend)
	end)

	-- 结束界面
	self.endGameBtn = gt.seekNodeByName(csbNode, "Btn_endGame")
	self.endGameBtn:retain()
	gt.addBtnPressedListener(self.endGameBtn, function()
		self:setVisible(false)
		self.BtnLayer:setVisible(false)
		callbackFinal()
	end)

	self:updata(roomPlayers, playerSeatIdx, rptMsgTbl, isLast, isHZLZ)
end

function RoundReport:updata(roomPlayers, playerSeatIdx, rptMsgTbl, isLast, isHZLZ)
	local function localCallbackNext( )
		self:setVisible(false)
		self.BtnLayer:setVisible(false)
		self.startGameBtn:setEnabled(false)
		self.callbackNext()

		local msgToSend = {}
		msgToSend.kMId = gt.CG_READY
		msgToSend.kPos = self.playerSeatIdx - 1
		gt.socketClient:sendMessage(msgToSend)
	end

	local function localCallbackFinal( )
		self:setVisible(false)
		self.BtnLayer:setVisible(false)
		self.callbackFinal()
	end

	local RoundReportDetail = require("client/game/majiang/RoundReportDetail"):create(localCallbackFinal, localCallbackNext, roomPlayers, playerSeatIdx, rptMsgTbl, isLast, isHZLZ)
	self:addChild(RoundReportDetail)

	self.playerSeatIdx = playerSeatIdx
	if rptMsgTbl.kResult == 2 then
		-- 流局
		local reportTitleSpr = gt.seekNodeByName(self.reportTitleNode, "Spr_liujuTitle")
		reportTitleSpr:setVisible(true)
		gt.soundEngine:playEffect("common/audio_liuju")
	else
		local roundResult = rptMsgTbl.kWin[playerSeatIdx]
		if roundResult == 1 or roundResult == 2 or roundResult == 4 or roundResult == 8 or roundResult == 9 or roundResult == 10 then
			-- 赢了(自摸胡或者接炮)
			local reportTitleSpr = gt.seekNodeByName(self.reportTitleNode, "Spr_winTitle")
			reportTitleSpr:setVisible(true)
			gt.soundEngine:playEffect("common/audio_win")
		else
			-- 输了(没胡或者点炮)
			local reportTitleSpr = gt.seekNodeByName(self.reportTitleNode, "Spr_loseTitle")
			reportTitleSpr:setVisible(true)
			gt.soundEngine:playEffect("common/audio_lose")			
		end
	end

	MJScene.chenzhouPlayType.jinniao[2] = 0

	local m_hucardsTable={rptMsgTbl.kHucards1,rptMsgTbl.kHucards2,rptMsgTbl.kHucards3,rptMsgTbl.kHucards4}
	-- local m_huWayTable = {rptMsgTbl.m_huWay1, rptMsgTbl.m_huWay2, rptMsgTbl.m_huWay3, rptMsgTbl.m_huWay4}
	-- 默认隐藏
	for i = 1, 4 do
		local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. i)
		playerReportNode:setVisible(false)
	end

	-- 布局排布：起始位置，间隔
	local layoutStartPos = cc.p(0,0)
	local vSpace = 0
	if #roomPlayers == 2 then
		vSpace = 120
	elseif #roomPlayers == 3 then
		vSpace = 60
	else
		vSpace = 0
	end

	local birdlist = {0, 0, 0, 0} 
	--耗子牌显示
	local nodeBao = gt.seekNodeByName(self.rootNode, "Node_dabao")
	local Spr_mjTileList = {}
	for k = 1 ,2 do
		local Spr_mjTile = gt.seekNodeByName(nodeBao, "Spr_mjTile"..k)
		Spr_mjTile:setVisible(false)
		Spr_mjTileList[k] = { _Spr_mjTile = Spr_mjTile }
	end
	if rptMsgTbl.kHunCard and #rptMsgTbl.kHunCard > 0 then
		local ishaveHaozi = false
		for k,v in pairs(rptMsgTbl.kHunCard) do
			local color = v[1]
			local number = v[2]
			if color ~= 0 and number ~= 0 then
				ishaveHaozi = true
				break
			end
		end
		-- nodeBao:setVisible(ishaveHaozi)
		nodeBao:setVisible(false)
		for k,v in pairs(rptMsgTbl.kHunCard) do
			local color = v[1]
			local number = v[2]
			if color ~= 0 and number ~= 0 then
				local mjTileName = Utils.getMJTileResName(4, color, number, false)
				-- local imgfile = ""
				-- if gt.createType == 2 then
				-- 	imgfile = "sx_txt_table_mouse.png"
				-- elseif gt.createType == 5 then
				-- 	imgfile = "sx_txt_table_jin.png"
				-- end
				-- Spr_mjTileList[k]._Spr_name:ignoreContentAdaptWithSize(true)
				-- Spr_mjTileList[k]._Spr_name:loadTexture(imgfile,1)
				-- Spr_mjTileList[k]._Spr_name:setVisible(true)
				Spr_mjTileList[k]._Spr_mjTile:setVisible(true)
				Spr_mjTileList[k]._Spr_mjTile:setSpriteFrame(mjTileName)
				self:addMouseMark(Spr_mjTileList[k]._Spr_mjTile)
			end
		end
		if #rptMsgTbl.kHunCard == 2 then
			Spr_mjTileList[1]._Spr_mjTile:setPositionX(-25)
			Spr_mjTileList[2]._Spr_mjTile:setPositionX(25)
		end
	end

	for i = 1, 4 do
		local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. i)
		playerReportNode:setVisible(false)
	end
	
	local playerNum = #roomPlayers   --玩家人数
	-- 具体信息
	for seatIdx, roomPlayer in ipairs(roomPlayers) do
		print("----------------------roomPlayer.seatIdx", roomPlayer.seatIdx)
		print("----------------------roomPlayer.displaySeatIdx", roomPlayer.displaySeatIdx)
		if seatIdx < 5 then
			local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. roomPlayer.displaySeatIdx)

			if playerReportNode then
				playerReportNode:setVisible(true)
				-- playerReportNode:setPosition(layoutStartPos.x, layoutStartPos.y-(roomPlayer.seatIdx-1)*vSpace)
				-- 昵称
				-- local nicknameLabel = gt.seekNodeByName(playerReportNode, "Label_nickname")
				-- nicknameLabel:setString(roomPlayer.nickname)--(gt.checkName(roomPlayer.nickname))

				local detailLabel = gt.seekNodeByName(playerReportNode, "Label_detail")
				local detailTxt = ""
				local roundResult = rptMsgTbl.kWin[roomPlayer.seatIdx]
				if roundResult == 1 then
					detailTxt = "自摸胡 "
				elseif roundResult == 2 then
					detailTxt = "接炮 "
				elseif roundResult == 3 then
					detailTxt = "点炮 "
				elseif roundResult == 8 then
					detailTxt = "明杠开花 "
				elseif roundResult == 9 then
					detailTxt = "自摸（暗杠开花） "
				elseif roundResult == 10 then
					detailTxt = "自摸（明杠开花） "
				end

		        local roundResult = rptMsgTbl["kHu" .. roomPlayer.seatIdx]
		        gt.log("测试胡牌类型文字 ============")
		        gt.dump(roundResult)
				for i = 1, #roundResult do

					local key = roundResult[i]
					local value = MJRules.HuPaiType[key]
					if value then
                        if tonumber(key) == 1058 then
                            detailTxt = detailTxt..value.."X"..rptMsgTbl.kYbPiao[roomPlayer.seatIdx].." "
                        else
                            detailTxt = detailTxt..value.." "
                        end
					end	   
				end

				if rptMsgTbl.kAgang[roomPlayer.seatIdx] > 0 then
					detailTxt = string.format("%s暗杠X%d ", detailTxt, rptMsgTbl.kAgang[roomPlayer.seatIdx])
				end
				if rptMsgTbl.kMgang[roomPlayer.seatIdx] > 0 then
					detailTxt = string.format("%s明杠X%d ", detailTxt, rptMsgTbl.kMgang[roomPlayer.seatIdx])
				end
				if rptMsgTbl.kDgang[roomPlayer.seatIdx] > 0 then
					detailTxt = string.format("%s点杠X%d ", detailTxt, rptMsgTbl.kDgang[roomPlayer.seatIdx])
				end

				-- X番
				local regionScoreLabel = gt.seekNodeByName(playerReportNode, "Label_regionScore")
				regionScoreLabel:setString(string.format("%d番", math.abs(rptMsgTbl.kScore[roomPlayer.seatIdx])))

				-- 杠分
				local gangScore = rptMsgTbl.kGangScore[roomPlayer.seatIdx] or 0
				local gangScoreLabel = gt.seekNodeByName(playerReportNode, "Label_gang_score")
				if gangScore >= 0 then
					gangScoreLabel:setString("+"..tostring(gangScore))
				else
					gangScoreLabel:setString(tostring(gangScore))
				end	
				
				-- 胡分
				local huScore = rptMsgTbl.kHuScore[roomPlayer.seatIdx] or 0
				local huLabel = gt.seekNodeByName(playerReportNode, "Label_hu")
				local huScoreLabel = gt.seekNodeByName(playerReportNode, "Label_hu_score")
				if huScore >= 0 then
					huScoreLabel:setString("+"..tostring(huScore))
					-- huLabel:setColor(cc.c3b(255, 165, 0))
					-- huScoreLabel:setColor(cc.c3b(255, 165, 0))
				else
					huScoreLabel:setString(tostring(huScore))
					-- huLabel:setColor(cc.c3b(30, 144, 255))
					-- huScoreLabel:setColor(cc.c3b(30, 144, 255))
				end	

				--金分
				if roomPlayer.seatIdx == 1 then
					local jinLabel = gt.seekNodeByName(playerReportNode, "Label_jinpai")
					if gt.createType == 5 then	
						jinLabel:setVisible(true)
					else
						jinLabel:setVisible(false)
					end
				end
				local jinScore = 0
				local jinScoreLabel = gt.seekNodeByName(playerReportNode, "Label_jinpai_score")
				if gt.createType == 5 then			
					jinScore = rptMsgTbl.kJinScore[roomPlayer.seatIdx] or 0
					jinScoreLabel:setVisible(true)
					jinScoreLabel:setString(tostring(jinScore))	
				else
					jinScoreLabel:setVisible(false)	
				end

				-- 积分
				local totalScore = gangScore + huScore + jinScore
				-- csw 11-14
				if tonumber(roomPlayer.uid) == tonumber(gt.playerData.uid) then 
					-- if totalScore == 111 then 
					-- 	gt.dispatchEvent("ENDGAME",1,2000) -- 少一个类型
					-- elseif totalScore == -111 then
					-- 	gt.dispatchEvent("ENDGAME",1,4000) -- 少一个类型
					-- end
					for i = 1, #roundResult do
						local key = roundResult[i]
						for j = 1 , #CardType do
							if key == CardType[j] then
								gt.dispatchEvent("ENDGAME",1,key) -- 少一个类型
							end
						end
					end
				end
				-- csw 11-14
				local scoreLabel = gt.seekNodeByName(playerReportNode, "Label_score")
				if totalScore >= 0 then
					scoreLabel:setString("+"..tostring(totalScore))
					-- scoreLabel:setColor(cc.c3b(255, 165, 0))
				else
					scoreLabel:setString(tostring(totalScore))
					-- scoreLabel:setColor(cc.c3b(30, 144, 255))
				end
				-- scoreLabel:setString(tostring(rptMsgTbl.m_score[roomPlayer.seatIdx]+ or 0))

				--番数
				local fanLabel = gt.seekNodeByName(playerReportNode, "Label_fanshu")
				local fanNum = huScore
				if fanNum < 0 then
					fanNum = - fanNum
				end
				local fanText = fanNum.."番"
				fanLabel:setString(fanText)

				-- 更新积分
				roomPlayer.score = roomPlayer.score + rptMsgTbl.kScore[roomPlayer.seatIdx]
				roomPlayer.scoreLabel:setString(tostring(roomPlayer.score))

				--设置胡法文字
		    	detailLabel:setString(detailTxt)
		    end
		    -- if playerNum == 2 then
				if i == roomPlayer.displaySeatIdx then
					playerReportNode:setVisible(true)
				end
			-- end
		end
	end

	-- if playerNum == 4 then
	-- 	--4人的都显示
	-- 	for i = 1, 4 do
	-- 		local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. i)
	-- 		playerReportNode:setVisible(true)
	-- 	end
	-- elseif playerNum == 3 then
	-- 	--3人的隐藏1行
	-- 	for i = 1, 4 do
	-- 		local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. i)
	-- 		playerReportNode:setVisible(true)
	-- 		if i == 4 then
	-- 			playerReportNode:setVisible(false)
	-- 		end
	-- 	end
	-- elseif playerNum == 2 then
		-- --2人的隐藏2行
		-- for i = 1, 4 do
		-- 	local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. i)
		-- 	playerReportNode:setVisible(true)
		-- 	if  i == 3 or i == 4 then
		-- 		playerReportNode:setVisible(false)
		-- 	end
		-- end
	-- end

	--飘的数量为空
    MJScene.chenzhouPlayType.piao={}

	if isLast==0 then
		-- 不是最后一局
		self.startGameBtn:setVisible( true )
		self.endGameBtn:setVisible( false )
	elseif isLast==1 then
		-- 最后一局
		self.startGameBtn:setVisible( false )
		self.endGameBtn:setVisible( true )
	end

end

function RoundReport:addMouseMark(mjTileSpr)
	local imgname = "img_table_mouse"
	local imgfile = ""
	if gt.createType == 2 or gt.createType == 8 then
		imgfile = "sx_img_table_mouse.png"
	elseif gt.createType == 5 then
		imgfile = "sx_img_table_jin.png"
	end
	if not mjTileSpr:getChildByName(imgname) then
		local imgtablemouse = ccui.ImageView:create(imgfile,1)
		imgtablemouse:setName(imgname)
		local mjsize = mjTileSpr:getContentSize()
		local tablemousesize = imgtablemouse:getContentSize()
		imgtablemouse:setScale(0.7)
		imgtablemouse:setPosition(mjsize.width - tablemousesize.width/2 - 2,mjsize.height - tablemousesize.height + 17)
		mjTileSpr:addChild(imgtablemouse)
	end
end

-- function RoundReport:screenshotShareToWX()
-- 	local layerSize = self.rootNode:getContentSize()
-- 	local screenshot = cc.RenderTexture:create(gt.winSize.width, gt.winSize.height)
-- 	screenshot:begin()
-- 	self.rootNode:visit()
-- 	screenshot:endToLua()

-- 	local screenshotFileName = string.format("wx-%s.jpg", os.date("%Y-%m-%d_%H:%M:%S", os.time()))
-- 	screenshot:saveToFile(screenshotFileName, cc.IMAGE_FORMAT_JPEG, false)

-- 	self.shareImgFilePath = cc.FileUtils:getInstance():getWritablePath() .. screenshotFileName
-- 	self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
-- end

function RoundReport:setDisplay(status)
	self:setVisible(status)
	self.BtnLayer:setVisible(status)
	self.startGameBtn:setEnabled(status)
end

-- function RoundReport:update()
-- 	if self.shareImgFilePath and cc.FileUtils:getInstance():isFileExist(self.shareImgFilePath) then
-- 		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
-- 		-- local share_Btn = gt.seekNodeByName(self.rootNode, "Btn_round_share")
-- 		-- share_Btn:setEnabled(true)
-- 		local shareImgFilePath = self.shareImgFilePath
-- 		Utils.shareImageToWX( shareImgFilePath, handler(self, self.pushShareCodeImage) )
-- 		self.shareImgFilePath = nil
-- 	end
-- end
function RoundReport:pushShareCodeImage(authCode)
	gt.log("===================HY", authCode, type(authCode))
end
function RoundReport:onNodeEvent(eventName)
	if "enter" == eventName then
		-- local listener = cc.EventListenerTouchOneByOne:create()
		-- listener:setSwallowTouches(true)
		-- listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		-- local eventDispatcher = self:getEventDispatcher()
		-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
	end
end

-- function RoundReport:onTouchBegan(touch, event)
-- 	return true
-- end
return RoundReport

