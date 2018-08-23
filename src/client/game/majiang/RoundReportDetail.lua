
local gt = cc.exports.gt

local Utils = require("client/tools/Utils")
local MJScene=require("client/game/majiang/MJScene")
local RoundReportDetail = class("RoundReportDetail", function()
	return cc.Layer:create()
end)

function RoundReportDetail:ctor(callbackFinal, callbackNext, roomPlayers, playerSeatIdx, rptMsgTbl, isLast, isHZLZ)
	gt.log("单局结算 =================== ")
	gt.dump(rptMsgTbl)
	
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("RoundReportDetail.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

	-- local roomId=gt.seekNodeByName(csbNode,"Label_room_Id")
	-- local playType=gt.seekNodeByName(csbNode,"Label_room_type")
	-- roomId:setString("房号 ".. cc.UserDefault:getInstance():getStringForKey("roomId"))
	
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

	self.playerSeatIdx = playerSeatIdx
	-- 开始下一局
	self.startGameBtn = gt.seekNodeByName(csbNode, "Btn_startGame")
	gt.addBtnPressedListener(self.startGameBtn, function()
		self:removeFromParent()
		callbackNext()
	end)

	-- 结束界面
	self.endGameBtn = gt.seekNodeByName(csbNode, "Btn_endGame")
	gt.addBtnPressedListener(self.endGameBtn, function()
		self:removeFromParent()
		callbackFinal()
	end)

	self:updata(roomPlayers, playerSeatIdx, rptMsgTbl, isLast, isHZLZ)

	-- 关闭按钮
	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:removeFromParent()
	end)
end

function RoundReportDetail:updata(roomPlayers, playerSeatIdx, rptMsgTbl, isLast, isHZLZ)
	self.playerSeatIdx = playerSeatIdx

	MJScene.chenzhouPlayType.jinniao[2] = 0

	local m_hucardsTable={rptMsgTbl.kHucards1,rptMsgTbl.kHucards2,rptMsgTbl.kHucards3,rptMsgTbl.kHucards4}
	-- local m_huWayTable = {rptMsgTbl.m_huWay1, rptMsgTbl.m_huWay2, rptMsgTbl.m_huWay3, rptMsgTbl.m_huWay4}
	-- 默认隐藏
	for i = 1, 4 do
		local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. i)
		playerReportNode:setVisible(false)
	end

	local Spr_mjTileList = {}
	-- for k = 1 ,2 do
	-- 	Spr_mjTileList[k] = { _Spr_mjTile = Spr_mjTile, _Spr_bg = Spr_bg ,_Spr_name = Spr_name }
	-- end
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
	
	-- if rptMsgTbl.m_hunCard and #rptMsgTbl.m_hunCard > 0 then
	-- 	local ishaveHaozi = false
	-- 	for k,v in pairs(rptMsgTbl.m_hunCard) do
	-- 		local color = v[1]
	-- 		local number = v[2]
	-- 		if color ~= 0 and number ~= 0 then
	-- 			ishaveHaozi = true
	-- 			break
	-- 		end
	-- 	end
	-- 	for k,v in pairs(rptMsgTbl.m_hunCard) do
	-- 		local color = v[1]
	-- 		local number = v[2]
	-- 		if color ~= 0 and number ~= 0 then
	-- 			local mjTileName = Utils.getMJTileResName(4, color, number, false)
	-- 			-- local imgfile = ""
	-- 			-- if gt.createType == 2 then
	-- 			-- 	imgfile = "sx_txt_table_mouse.png"
	-- 			-- elseif gt.createType == 5 then
	-- 			-- 	imgfile = "sx_txt_table_jin.png"
	-- 			-- end
	-- 			-- Spr_mjTileList[k]._Spr_name:ignoreContentAdaptWithSize(true)
	-- 			-- Spr_mjTileList[k]._Spr_name:loadTexture(imgfile,1)
	-- 			-- Spr_mjTileList[k]._Spr_name:setVisible(true)
	-- 			Spr_mjTileList[k]._Spr_mjTile:setVisible(true)
	-- 			Spr_mjTileList[k]._Spr_mjTile:setSpriteFrame(mjTileName)
	-- 			self:addMouseMark(Spr_mjTileList[k]._Spr_mjTile)
	-- 		end
	-- 	end
	-- 	if #rptMsgTbl.m_hunCard == 2 then
	-- 		Spr_mjTileList[1]._Spr_mjTile:setPositionX(-25)
	-- 		Spr_mjTileList[2]._Spr_mjTile:setPositionX(25)
	-- 	end
	-- end

	local playerNum = #roomPlayers   --玩家人数
	local roomPlayerIndex = 0
	-- 具体信息
	for seatIdx, roomPlayer in ipairs(roomPlayers) do
		print("----------------------roomPlayer.seatIdx", roomPlayer.seatIdx)
		print("----------------------roomPlayer.displaySeatIdx", roomPlayer.displaySeatIdx)
		if seatIdx < 5 then
			roomPlayerIndex = roomPlayerIndex + 1
			local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. roomPlayerIndex)
			local mjTileNode = gt.seekNodeByName(playerReportNode, "Node_mjTile")
			mjTileNode:removeAllChildren()

			if playerReportNode then
				playerReportNode:setVisible(true)
				-- playerReportNode:setPosition(layoutStartPos.x, layoutStartPos.y-(roomPlayer.seatIdx-1)*vSpace)

				-- 头像
				local Head_layout = gt.seekNodeByName(playerReportNode, "Head_layout")
				local str = string.format("%shead_img_%d.png", cc.FileUtils:getInstance():getWritablePath(), roomPlayer.uid)
				if cc.FileUtils:getInstance():isFileExist(str) then
	   				local headSpr = cc.Sprite:create(str)
	   				headSpr:setPosition(Head_layout:getContentSize().width/2, Head_layout:getContentSize().height/2)
					Head_layout:addChild(headSpr)
					headSpr:setScale(66/headSpr:getContentSize().width)
		        end

                -- 庄
                local bankerImg = gt.seekNodeByName(playerReportNode, "Img_banker")
                if seatIdx == rptMsgTbl.kZhuangPos then
                    bankerImg:setVisible(true)
                else
                    bankerImg:setVisible(false)
                end

				-- 昵称
				local nicknameLabel = gt.seekNodeByName(playerReportNode, "Label_nickname")
				nicknameLabel:setString(roomPlayer.nickname)--(gt.checkName(roomPlayer.nickname))

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
				local scoreLabel = gt.seekNodeByName(playerReportNode, "Label_score")
				if totalScore >= 0 then
					scoreLabel:setString("+"..tostring(totalScore))
					scoreLabel:setColor(cc.c3b(253,96,35))
				else
					scoreLabel:setString(tostring(totalScore))
					scoreLabel:setColor(cc.c3b(79,136,207))
				end

				--番数
				local fanLabel = gt.seekNodeByName(playerReportNode, "Label_fanshu")
				local fanNum = huScore
				if fanNum < 0 then
					fanNum = - fanNum
				end
				local fanText = fanNum.."番"
				fanLabel:setString(fanText)

				-- 持有麻将信息
				local mjTileReferSpr = gt.seekNodeByName(playerReportNode, "Spr_mjTileRefer")
				mjTileReferSpr:setVisible(false)
				local referScale = mjTileReferSpr:getScale()
				local referPos = cc.p(mjTileReferSpr:getPosition())
				local mjTileSize = mjTileReferSpr:getContentSize()
				local referSpace = cc.p(mjTileSize.width * referScale - 6, 0)
				-- 暗杠
				for _, darkBar in ipairs(roomPlayer.mjTileDarkBars) do
					local mjTilePos = cc.p(0, 0)
					for i = 1, 4 do
						local mjTileName = Utils.getMJTileResName(4, darkBar.mjColor, darkBar.mjNumber,isHZLZ)
						if i <= 3 then
							-- 前三张牌显示背面
							mjTileName = "tdbgs_4.png"
							if i == 2 then
								mjTilePos = cc.p(referPos.x, referPos.y + 13)
							end
						end
						local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
						mjTileSpr:setScale(referScale)
						if i <= 3 then
							mjTileSpr:setPosition(referPos)
							referPos = cc.pAdd(referPos, referSpace)
						else
							mjTileSpr:setPosition(mjTilePos)
							-- 添加耗子牌标识
							if rptMsgTbl.kHunCard and #rptMsgTbl.kHunCard > 0 then
								for i, card in ipairs(rptMsgTbl.kHunCard) do
									if darkBar.mjColor == card[1] and darkBar.mjNumber == card[2] then
										self:addMouseMark(mjTileSpr)	
									end		
								end
							end
						end
						mjTileNode:addChild(mjTileSpr)
					end
					referPos.x = referPos.x + 10
				end
				-- 明杠
				for _, brightBar in ipairs(roomPlayer.mjTileBrightBars) do
					local mjTilePos = cc.p(0, 0)
					for i = 1, 4 do
						local mjTileName = Utils.getMJTileResName(4, brightBar.mjColor, brightBar.mjNumber,isHZLZ)
						local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
						mjTileSpr:setScale(referScale)
						if i == 2 then
							mjTilePos = cc.p(referPos.x, referPos.y + 13)
						end
						if i <= 3 then
							mjTileSpr:setPosition(referPos)
							referPos = cc.pAdd(referPos, referSpace)
						else
							mjTileSpr:setPosition(mjTilePos)
						end
						mjTileNode:addChild(mjTileSpr)
						-- 添加耗子牌标识
						if rptMsgTbl.kHunCard and #rptMsgTbl.kHunCard > 0 then
							for i, card in ipairs(rptMsgTbl.kHunCard) do
								if brightBar.mjColor == card[1] and brightBar.mjNumber == card[2] then
									self:addMouseMark(mjTileSpr)	
								end		
							end
						end
					end
					referPos.x = referPos.x + 10
				end
				-- 明补
				for _, brightBar in ipairs(roomPlayer.mjTileBrightBu) do
					local mjTilePos = cc.p(0, 0)
					for i = 1, 4 do
						local mjTileName = Utils.getMJTileResName(4, brightBar.mjColor, brightBar.mjNumber,isHZLZ)
						local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
						mjTileSpr:setScale(referScale)
						if i == 2 then
							mjTilePos = cc.p(referPos.x, referPos.y + 13)
						end
						if i <= 3 then
							mjTileSpr:setPosition(referPos)
							referPos = cc.pAdd(referPos, referSpace)
						else
							mjTileSpr:setPosition(mjTilePos)
						end
						mjTileNode:addChild(mjTileSpr)
						-- 添加耗子牌标识
						if rptMsgTbl.kHunCard and #rptMsgTbl.kHunCard > 0 then
							for i, card in ipairs(rptMsgTbl.kHunCard) do
								if brightBar.mjColor == card[1] and brightBar.mjNumber == card[2] then
									self:addMouseMark(mjTileSpr)	
								end		
							end
						end
					end
					referPos.x = referPos.x + 10
				end
				-- 碰
				for _, pung in ipairs(roomPlayer.mjTilePungs) do
					for i = 1, 3 do
						local mjTileName = Utils.getMJTileResName(4, pung.mjColor, pung.mjNumber,isHZLZ)
						if not string.find(mjTileName, "0") then    --排除非法牌
							local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
							mjTileSpr:setScale(referScale)
							mjTileSpr:setPosition(referPos)
							mjTileNode:addChild(mjTileSpr)
							referPos = cc.pAdd(referPos, referSpace)
							-- 添加耗子牌标识
							if rptMsgTbl.kHunCard and #rptMsgTbl.kHunCard > 0 then
								for i, card in ipairs(rptMsgTbl.kHunCard) do
									if pung.mjColor == card[1] and pung.mjNumber == card[2] then
										self:addMouseMark(mjTileSpr)	
									end		
								end
							end
						end
					end
					referPos.x = referPos.x + 10
				end

				-- 粘
				for _, pung in ipairs(roomPlayer.mjTileNians) do
					for i = 1, 2 do
						local mjTileName = Utils.getMJTileResName(4, pung.mjColor, pung.mjNumber,isHZLZ)
						local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
						mjTileSpr:setScale(referScale)
						mjTileSpr:setPosition(referPos)
						mjTileNode:addChild(mjTileSpr)
						referPos = cc.pAdd(referPos, referSpace)
						-- 添加耗子牌标识
						if rptMsgTbl.kHunCard and #rptMsgTbl.kHunCard > 0 then
							for i, card in ipairs(rptMsgTbl.kHunCard) do
								if pung.mjColor == card[1] and pung.mjNumber == card[2] then
									self:addMouseMark(mjTileSpr)	
								end		
							end
						end
					end
					referPos.x = referPos.x + 10
				end

				--吃牌
				for _, eat in ipairs(roomPlayer.mjTileEat) do
					for i = 1, 3 do
						local mjTileName = Utils.getMJTileResName(4, eat[i][3], eat[i][1],isHZLZ)
						local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
						mjTileSpr:setScale(referScale)
						mjTileSpr:setPosition(referPos)
						mjTileNode:addChild(mjTileSpr)
						referPos = cc.pAdd(referPos, referSpace)
						-- 添加耗子牌标识
						if rptMsgTbl.kHunCard and #rptMsgTbl.kHunCard > 0 then
							for i, card in ipairs(rptMsgTbl.kHunCard) do
								if eat[i][3] == card[1] and eat[i][1] == card[2] then
									self:addMouseMark(mjTileSpr)	
								end		
							end
						end
					end
					referPos.x = referPos.x + 10
				end

				local tileList = {}
				for i, v in ipairs(rptMsgTbl["kArray" .. (seatIdx - 1)]) do
					if v[1] == 4 then
						table.insert(tileList, v)
					else
						table.insert(tileList, v)
					end
				end

				local finalList = {}
				
				if isHZLZ == true then
					for _, v in ipairs(tileList) do
						if v[1] == 4 and v[2] == 5 then
							table.insert(finalList,1, v)
						else
							table.insert(finalList, v)
						end
					end
				else
					finalList = tileList
				end

				self.HaoZiCards = rptMsgTbl.kHunCard
				finalList = self:setSortPlayerMjTiles(finalList)

				-- 持有牌
				for _, v in ipairs(finalList) do
					local mjTileName = Utils.getMJTileResName(4, v[1], v[2], isHZLZ)
					local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
					mjTileSpr:setScale(referScale)
					mjTileSpr:setPosition(referPos)
					mjTileNode:addChild(mjTileSpr)
					-- 添加耗子牌标识
					if rptMsgTbl.kHunCard and #rptMsgTbl.kHunCard > 0 then
						for i, card in ipairs(rptMsgTbl.kHunCard) do
							if v[1] == card[1] and v[2] == card[2] then
								self:addMouseMark(mjTileSpr)	
							end		
						end
					end
					referPos = cc.pAdd(referPos, referSpace)
				end

				-- 胡标识
				local winSignSpr = gt.seekNodeByName(playerReportNode, "Spr_winSign")
				winSignSpr:setVisible(false)

				-- 胡标识
				gt.log("胡标识111", seatIdx, rptMsgTbl.kWin[seatIdx])
				local ishu = rptMsgTbl.kWin[seatIdx]
				if ishu == 1 or ishu == 2 or ishu == 4 or ishu == 8 or ishu == 9 or ishu == 10 then
		           local m_hucard = m_hucardsTable[seatIdx]
		           gt.log("胡标识222", #m_hucard)
						if #m_hucard~= 0 then
							for j,m_hu in ipairs(m_hucard) do
								local mjTileName = Utils.getMJTileResName(4, m_hu[1], m_hu[2],isHZLZ)
								local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
								mjTileSpr:setScale(referScale)
								mjTileSpr:setPosition(referPos.x + 16+60*(j-1),referPos.y)
								mjTileNode:addChild(mjTileSpr)
								-- 添加耗子牌标识
								if rptMsgTbl.kHunCard and #rptMsgTbl.kHunCard > 0 then
									for i, card in ipairs(rptMsgTbl.kHunCard) do
										if m_hu[1] == card[1] and m_hu[2] == card[2] then
											self:addMouseMark(mjTileSpr)	
										end		
									end
								end
								local huSpr = cc.Sprite:create("res/roundReportDetail/roundReportDetail_huBg.png")
								if huSpr then
									huSpr:setAnchorPoint(cc.p(0.5, 0.5))
									huSpr:setPosition(mjTileSpr:getPosition())
									mjTileNode:addChild(huSpr, -1)
								end
						     end
					    end

					-- 胡标识
					winSignSpr:setVisible(true)
				else
					--如果没胡牌，需要显示是否听牌
					local isTing = rptMsgTbl.kTing[seatIdx] or 0
					if isTing == 0 then
						--未上听
						detailTxt = detailTxt.."未上听 "
					else
						--已上听
						detailTxt = detailTxt.."已上听 "
					end
				end

				--设置胡法文字
		    	detailLabel:setString(detailTxt)
		    end

			if i == roomPlayer.displaySeatIdx then
				playerReportNode:setVisible(true)
			end
		end
	end

	if playerNum == 4 then
		--4人的都显示
		for i = 1, 4 do
			local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. i)
			playerReportNode:setVisible(true)
		end
	elseif playerNum == 3 then
		--3人的隐藏1行
		for i = 1, 4 do
			local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. i)
			playerReportNode:setVisible(true)
			if i == 4 then
				playerReportNode:setVisible(false)
			end
		end
	elseif playerNum == 2 then
		--2人的隐藏2行
		for i = 1, 4 do
			local playerReportNode = gt.seekNodeByName(self.rootNode, "Node_playerReport_" .. i)
			playerReportNode:setVisible(true)
			if  i == 3 or i == 4 then
				playerReportNode:setVisible(false)
			end
		end
	end

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

function RoundReportDetail:addMouseMark(mjTileSpr)
	local imgname = "img_table_mouse"
	local imgfile = ""
	imgfile = "sx_img_table_mouse.png"
	
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

-- start --
--------------------------------
-- @class function
-- @description 玩家麻将牌根据花色，编号重新排序
-- end --
function RoundReportDetail:setSortPlayerMjTiles(PlayerMjTiles)
    -- 按照花色分类
    local colorsMjTiles = {}
    table.sort(PlayerMjTiles, function(a, b)
        return tonumber(a[1]) < tonumber(b[1])
    end)

    local colorsMjTiles = {}
    for _, mjTile in ipairs(PlayerMjTiles) do
        if not colorsMjTiles[mjTile[1]] then
            colorsMjTiles[mjTile[1]] = {}
        end
        table.insert(colorsMjTiles[mjTile[1]], mjTile)
    end

    -- 同花色从小到大排序
    local transMjTiles = {}
    for _, sameColorMjTiles in pairs(colorsMjTiles) do
        table.sort(sameColorMjTiles, function(a, b)
            return a[2] < b[2]
        end)
        for _, mjTile in pairs(sameColorMjTiles) do
            if mjTile[1] ~= 4 then
                table.insert(transMjTiles, mjTile)
            end
        end
    end
    for _, sameColorMjTiles in pairs(colorsMjTiles) do
        for _, mjTile in pairs(sameColorMjTiles) do
            if mjTile[1] == 4 then
                table.insert(transMjTiles, mjTile)
            end
        end
    end

    local finalMjTiles = {}
    finalMjTiles = transMjTiles

    --  如果是耗子牌，放在手牌的最左边 2017-3-4 shenyongzhen
    if self.HaoZiCards then
        gt.log("耗子牌，排序")
        for i,card in ipairs(self.HaoZiCards) do
            for i,v in ipairs(finalMjTiles) do
                if v[1] == card[1] and v[2] == card[2] then
                    table.remove(finalMjTiles,i)
                    table.insert(finalMjTiles,1,v)
					local mjTileName = Utils.getMJTileResName(4, v[1], v[2], true)
					local mjTileSpr = cc.Sprite:createWithSpriteFrameName(mjTileName)
                    self:addMouseMark(mjTileSpr)    
                end        
            end
        end
    end

    return finalMjTiles
end

-- function RoundReportDetail:screenshotShareToWX()
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

-- function RoundReportDetail:update()
-- 	if self.shareImgFilePath and cc.FileUtils:getInstance():isFileExist(self.shareImgFilePath) then
-- 		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
-- 		-- local share_Btn = gt.seekNodeByName(self.rootNode, "Btn_round_share")
-- 		-- share_Btn:setEnabled(true)
-- 		local shareImgFilePath = self.shareImgFilePath
-- 		Utils.shareImageToWX( shareImgFilePath, handler(self, self.pushShareCodeImage) )
-- 		self.shareImgFilePath = nil
-- 	end
-- end
function RoundReportDetail:pushShareCodeImage(authCode)
	gt.log("===================HY", authCode, type(authCode))
end
function RoundReportDetail:onNodeEvent(eventName)
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

-- function RoundReportDetail:onTouchBegan(touch, event)
-- 	return true
-- end
return RoundReportDetail

