
local gt = cc.exports.gt
local Utils = cc.exports.Utils

local FinalReport = class("FinalReport", function()
	return gt.createMaskLayer()--cc.Layer:create()
end)

function FinalReport:ctor(roomPlayers, rptMsgTbl, isSport, parent)
	gt.log("--------------------------roomPlayers")
	gt.dump(roomPlayers)
	self.isSport = isSport
	self.parent = parent

	cc.SpriteFrameCache:getInstance():addSpriteFrames("images/public_ui.plist")
	-- 注册节点事件
	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end	
	
	self:registerScriptHandler(handler(self,self.onNodeEvent))
	local csbNode = cc.CSLoader:createNode("FinalReport.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
	local roomId=gt.seekNodeByName(csbNode,"Label_room_Id")
	local playType=gt.seekNodeByName(csbNode,"Label_room_type")
	roomId:setString("房号:".. cc.UserDefault:getInstance():getStringForKey("roomId"))
	if self.isSport then
		roomId:setVisible(false)
	end
	playType:setString(cc.UserDefault:getInstance():getStringForKey("playType"))

	local lbl_cell_score = gt.seekNodeByName(csbNode, "lbl_cell_score")
	lbl_cell_score:setString("底分:"..rptMsgTbl.kBaseScore)

	local lbl_cell_score = gt.seekNodeByName(csbNode, "lbl_draw_limit")
	lbl_cell_score:setString("局数:"..rptMsgTbl.kMaxCircle)

	local lbl_create_user = gt.seekNodeByName(csbNode, "Label_create_user")
	if rptMsgTbl.kCreatorNike and rptMsgTbl.kCreatorNike ~= nil then
		lbl_create_user:setString("房主:"..rptMsgTbl.kCreatorNike)
	else
		lbl_create_user:setVisible(false)
	end

	local endTime = gt.seekNodeByName(csbNode, "lbl_end_time")
	local endT = os.date("%m-%d %H:%M", rptMsgTbl.kTime / 1000)
	if endT ~= nil then
		endTime:setString(endT.."结束")
	end

	local roomTime=gt.seekNodeByName(csbNode,"Label_Time")
    local date=os.date("%Y-%m-%d %H:%M:%S")
    roomTime:setString(date)

	local cannonMaxCount = 0
	for i, v in ipairs(rptMsgTbl.kBomb) do
		for j, v_d in ipairs(rptMsgTbl.kDbomb) do
			if i == j then
				local curCannon = v+v_d
				if curCannon > cannonMaxCount then
					cannonMaxCount = curCannon
				end
			end
		end
	end


	-- 大赢家
	local scoreMaxCount = 0
	local scoreMinCount = 0
	for i, v in ipairs(rptMsgTbl.kGold) do
		if v > scoreMaxCount then
			scoreMaxCount = v
		end
		if v < scoreMinCount then
			scoreMinCount = v
		end
	end





	-- 默认隐藏
	for i = 1, 4 do
    	local playerReportNode = gt.seekNodeByName(csbNode, "Panel_" .. i)
		playerReportNode:setVisible(false)
	end

	-- table.remove(roomPlayers, 3)
	-- table.remove(roomPlayers, 3)

	-- 布局排布：起始位置，间隔
	local layoutStartPos = cc.p(gt.seekNodeByName(csbNode, "Panel_1"):getPosition())
	local hSpace = 0
	if #roomPlayers == 2 then
		layoutStartPos = cc.p(282,layoutStartPos.y)
		hSpace = 470
	elseif #roomPlayers == 3 then
		layoutStartPos = cc.p(160,layoutStartPos.y)
		hSpace = 380
	else
		hSpace = 260
	end
    
    local _end = true
   	local tmpScore = 0
	-- print("当前玩家数量 ： ", #roomPlayers)

    for seatIdx, roomPlayer in ipairs(roomPlayers) do
    	if seatIdx < 5 then
	    	local playerReportNode = gt.seekNodeByName(csbNode, "Panel_" .. seatIdx)
			playerReportNode:setVisible(true)
			-- 重新布局
			playerReportNode:setPosition(layoutStartPos.x+(seatIdx-1)*hSpace, layoutStartPos.y)
			-- 玩家信息
			local playerInfoNode = gt.seekNodeByName(playerReportNode, "Img_frame")
			-- 头像
			local Head_layout = gt.seekNodeByName(playerInfoNode, "Head_layout")
			local str = string.format("%shead_img_%d.png", cc.FileUtils:getInstance():getWritablePath(), roomPlayer.uid)
			if cc.FileUtils:getInstance():isFileExist(str) then
   				local headSpr = cc.Sprite:create(str)
   				headSpr:setPosition(Head_layout:getContentSize().width/2, Head_layout:getContentSize().height/2)
				Head_layout:addChild(headSpr)
				headSpr:setScale(135/headSpr:getContentSize().width)
	        end
			-- 昵称
			local nicknameLabel = gt.seekNodeByName(playerInfoNode, "Label_nickname")
			nicknameLabel:setString(roomPlayer.nickname)
			-- uid
			local uidLabel = gt.seekNodeByName(playerInfoNode, "Label_uid")
			uidLabel:setString(roomPlayer.uid)

			local seatDirection = gt.seekNodeByName(playerInfoNode, "Img_seat")
			seatDirection:loadTexture("statistic/direction_"..seatIdx..".png")

			-- -- 最佳炮手
			-- local bestCannoneerSpr = gt.seekNodeByName(playerReportNode, "Spr_bestCannoneer")
			-- bestCannoneerSpr:setVisible(false)
			-- if cannonMaxCount ~= 0 and cannonMaxCount == rptMsgTbl.m_bomb[seatIdx]+rptMsgTbl.m_dbomb[seatIdx] then
			-- 	bestCannoneerSpr:setVisible(true)
			-- end

			-- 大赢家
			local bigWinnerSpr = gt.seekNodeByName(playerReportNode, "Img_big_winner")
			bigWinnerSpr:setVisible(false)
			if scoreMaxCount ~= 0 and scoreMaxCount == rptMsgTbl.kGold[seatIdx] then
				bigWinnerSpr:setVisible(true)
				self.uid = roomPlayer.uid
				gt.log("--------------------------self.uid", self.uid)
			end

			-- local tuHaoSpr = gt.seekNodeByName(playerReportNode, "Img_tuhao")
			-- tuHaoSpr:setVisible(false)
			-- if scoreMinCount ~= 0 and scoreMinCount == rptMsgTbl.m_gold[seatIdx] then
			-- 	tuHaoSpr:setVisible(true)
			-- end

			-- 房主
			-- local spr_homeOwner = gt.seekNodeByName(playerReportNode, "Sprite_houseOwner")
			-- spr_homeOwner:setVisible(false)

			-- if 1 == roomPlayer.seatIdx and (not self.isSport) then
			-- 	-- 0号位置是房主
			-- 	spr_homeOwner:setVisible(true)
			-- end

	    	--local playerReportNode = gt.seekNodeByName(csbNode, "Node_playerReport_" .. seatIdx)
	  --   	local Node_resultDes_zz = gt.seekNodeByName(playerReportNode, "Node_resultDes_zz")
			-- local Node_resultDes_cs = gt.seekNodeByName(playerReportNode, "Node_resultDes_cs")
			-- Node_resultDes_cs:setVisible(true)
			-- Node_resultDes_zz:setVisible(false)

	        --显示解散人
			local applyDismissImg = gt.seekNodeByName(playerReportNode, "Img_applyDismiss")
			applyDismissImg:setVisible(false)
			if gt.m_userId and gt.m_userId > 0 then
				if tonumber(roomPlayer.uid) == tonumber(gt.m_userId) then
					applyDismissImg:setVisible(true)
					_end = false
				end
			end
			-- csw 是否正常大结算  
			if tonumber(roomPlayer.uid) == tonumber(gt.playerData.uid) then 
					if tonumber(rptMsgTbl.kGold[seatIdx]) < 0 then
						local num = cc.UserDefault:getInstance():getIntegerForKey("lose_num", 0)
						num = num  + 1
						cc.UserDefault:getInstance():setIntegerForKey("lose_num", num)
					else
						cc.UserDefault:getInstance():setIntegerForKey("lose_num", 0)
					end
				tmpScore = tonumber(rptMsgTbl.kGold[seatIdx])
			end
			-- csw 是否正常大结算  
	        -- 总成绩
	        --local imgBg = gt.seekNodeByName(playerReportNode,"Image_player"..seatIdx.."_bg")
			local totalScoreLabel = gt.seekNodeByName(playerInfoNode, "Label_totalScore")
			if rptMsgTbl.kGold[seatIdx] > 0 then
				totalScoreLabel:setString("+"..tostring(rptMsgTbl.kGold[seatIdx]))
				totalScoreLabel:setColor(cc.c3b(255, 67, 1))
				--totalScoreLabel:enableOutline(cc.c3b(255,255,67,1), 3) 
			else
				totalScoreLabel:setString(tostring(rptMsgTbl.kGold[seatIdx]))
				totalScoreLabel:setColor(cc.c3b(86, 184, 47))
			end
		end
		-- local imgTotal = gt.seekNodeByName(imgBg,"Image_total")
		-- if bigWinnerSpr:isVisible()==false then
		-- 	totalScoreLabel:setPositionX(imgBg:getContentSize().width/2)
		-- 	imgTotal:setPositionX(imgBg:getContentSize().width/2)
		-- end		
		-- local imgMinus = gt.seekNodeByName(imgBg, "Image_minus")
		-- if tonumber(rptMsgTbl.m_gold[seatIdx]) >=0 then
		-- 	imgMinus:setVisible(false)
		-- else
		-- 	imgMinus:setVisible(true)
		-- 	local posx = totalScoreLabel:getPositionX() - totalScoreLabel:getContentSize().width*0.5
		-- 	imgMinus:setPositionX(posx)
		-- end

    end
 	gt.log("是否正常结束。。....",_end)
    if _end then 
		-- csw 是否正常大结算  
		local MaxLose = cc.UserDefault:getInstance():getIntegerForKey("lose_num", 0)
		gt.log("连输局。。。",MaxLose)
		if MaxLose == 8 then  -- l；连输8局
			cc.UserDefault:getInstance():setIntegerForKey("lose_num", 0)
			gt.dispatchEvent("ENDGAME",2) -- 连输8局
		end
		gt.dispatchEvent("ENDGAME",3)  -- 游戏场次 
		if tmpScore == 111 then 
			gt.dispatchEvent("ENDGAME",1,3000) -- 少一个类型
		elseif tmpScore == -111 then 
			gt.dispatchEvent("ENDGAME",1,2000) -- 少一个类型
		end
		gt.log("self.uid__________",self.uid,gt.playerData.uid)
		if self.uid and self.uid == gt.playerData.uid then -- d大赢家
			gt.dispatchEvent("ENDGAME",4) 
		end
		-- csw 是否正常大结算  	
	end

	-- for seatIdx, roomPlayer in ipairs(roomPlayers) do
	-- 	local playerReportNode = gt.seekNodeByName(csbNode, "Panel_" .. seatIdx)
	-- 	-- 玩家信息

	-- 	-- 描述信息根节点
	-- 	local Node_resultDes_zz = gt.seekNodeByName(playerReportNode, "Node_resultDes_zz")
	-- 	local Node_resultDes_cs = gt.seekNodeByName(playerReportNode, "Node_resultDes_cs")
	-- 	Node_resultDes_cs:setVisible(true)
	-- 	Node_resultDes_zz:setVisible(false)
	-- 	-- 判断房间类型
	-- 	gt.log("房间类型")
	-- 	if gt.roomType == gt.RoomType.ROOM_CHANGSHA then
	-- 		gt.log("长沙麻将finalReport")
	-- 		-- 长沙麻将
	-- 		Node_resultDes_zz:setVisible(false)
	-- 		Node_resultDes_cs:setVisible(true)

	-- 		-- 大胡自摸
	-- 		local selfDrawnCountBigLabel = gt.seekNodeByName(Node_resultDes_cs, "Label_selfDrawn_big_count")
	-- 		selfDrawnCountBigLabel:setString(tostring(rptMsgTbl.m_dzimo[seatIdx]))

	-- 		-- 小胡自摸
	-- 		local selfDrawnCountSmallLabel = gt.seekNodeByName(Node_resultDes_cs, "Label_selfDrawn_small_count")
	-- 		selfDrawnCountSmallLabel:setString(tostring(rptMsgTbl.m_zimo[seatIdx]))

	-- 		-- 大胡点炮
	-- 		local takeCannonCountBigLabel = gt.seekNodeByName(Node_resultDes_cs, "Label_takeCannonCount_big")
	-- 		takeCannonCountBigLabel:setString(tostring(rptMsgTbl.m_dbomb[seatIdx]))

	-- 		-- 小胡点炮
	-- 		local takeCannonCountSmallLabel = gt.seekNodeByName(Node_resultDes_cs, "Label_takeCannonCount_small")
	-- 		takeCannonCountSmallLabel:setString(tostring(rptMsgTbl.m_bomb[seatIdx]))

	-- 		-- 大胡接炮
	-- 		local cannonCount_big = gt.seekNodeByName(Node_resultDes_cs, "Label_cannonCount_big")
	-- 		cannonCount_big:setString(tostring(rptMsgTbl.m_dwin[seatIdx]))

	-- 		-- 小胡接炮
	-- 		local cannonCount_small = gt.seekNodeByName(Node_resultDes_cs, "Label_cannonCount_small")
	-- 		cannonCount_small:setString(tostring(rptMsgTbl.m_win[seatIdx]))
	-- 	else
	-- 		gt.log("转转麻将finalReport")
	-- 		-- 转转麻将
	-- 		Node_resultDes_zz:setVisible(true)
	-- 		Node_resultDes_cs:setVisible(false)

	-- 		-- 自摸次数
	-- 		local selfDrawnCountLabel = gt.seekNodeByName(Node_resultDes_zz, "Label_selfDrawnCount")
	-- 		selfDrawnCountLabel:setString(tostring(rptMsgTbl.m_zimo[seatIdx]))

	-- 		-- 接炮次数
	-- 		local takeCannonCountLabel = gt.seekNodeByName(Node_resultDes_zz, "Label_takeCannonCount")
	-- 		takeCannonCountLabel:setString(tostring(rptMsgTbl.m_win[seatIdx]))

	-- 		-- 点炮次数
	-- 		local cannonCountLabel = gt.seekNodeByName(Node_resultDes_zz, "Label_cannonCount")
	-- 		cannonCountLabel:setString(tostring(rptMsgTbl.m_bomb[seatIdx]))

	-- 		-- 暗杠次数
	-- 		local darkBarCountLabel = gt.seekNodeByName(Node_resultDes_zz, "Label_darkBarCount")
	-- 		darkBarCountLabel:setString(tostring(rptMsgTbl.m_agang[seatIdx]))

	-- 		-- 明杠次数
	-- 		local brightBarCountLabel = gt.seekNodeByName(Node_resultDes_zz, "Label_brightBarCount")
	-- 		brightBarCountLabel:setString(tostring(rptMsgTbl.m_mgang[seatIdx]))
	-- 	end

	-- 	-- -- 总成绩
	-- 	-- local totalScoreLabel = gt.seekNodeByName(playerReportNode, "Label_totalScore")
	-- 	-- totalScoreLabel:setString(tostring(rptMsgTbl.m_gold[seatIdx]))
	-- end

	-- 返回游戏大厅
	local backBtn = gt.seekNodeByName(csbNode, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
		gt.dispatchEvent(gt.EventType.BACK_MAIN_SCENE)
	end)

	local backMall = gt.seekNodeByName(csbNode, "Btn_mall")
	gt.addBtnPressedListener(backMall, function()
		gt.log("---------backMall")
		--删除登录测试文件
		-- if gt.removeFileLogin then
		-- 	gt.removeFileLogin()
		-- end

		gt.dispatchEvent(gt.EventType.BACK_MAIN_SCENE)
	end)

	-- if self.isSport then
	-- 	backBtn:setVisible(false)
	-- end

	-- 分享
	local shareBtn = gt.seekNodeByName(csbNode, "Btn_share")
	gt.addBtnPressedListener(shareBtn, function()
		shareBtn:setEnabled(false)
		self:screenshotShareToWX()
	end)

	if self.isSport then
		shareBtn:setVisible(false)
	end

	if gt.isAppStoreInReview then
		shareBtn:setVisible(false)
	else
		shareBtn:setVisible(true)
	end

	-- 请求玩家抽奖次数
	-- if gt.isNumberMark < 8 then
	-- 	gt.log("发送玩家抽奖消息")
	-- 	local msgToSend = {}
	-- 	msgToSend.m_msgId = gt.CG_LUCKY_DRAW_NUM
	-- 	gt.socketClient:sendMessage(msgToSend)
	-- end

	gt.registerEventListener("EVT_CLOSE_FINAL_REPORT", self, self.onCloseFinalReport)
end

function FinalReport:playAnimation()
	gt.log("--------------------------gt.playerData.uid", gt.playerData.uid)
	if self.uid and self.uid == gt.playerData.uid then
		gt.soundEngine:playEffect("common/player_victory", false, true)
		gt.log("--------------------------gt.playerData.uid", gt.playerData.uid)
		local playingNode, playingAni = gt.createCSAnimation("res/animation/diaojinbi/diaojinbi.csb")
		playingAni:play("run", true)
		playingNode:setPosition(gt.winCenter)
		self.parent:addChild(playingNode, gt.PlayZOrder.MJBAR_ANIMATION)

		local delayTime = cc.DelayTime:create(playingAni:getEndFrame() / 60)
		local callFunc = cc.CallFunc:create(function(sender)
			sender:removeFromParent()
		end)
		local seqAction = cc.Sequence:create(delayTime, callFunc)
		playingNode:runAction(seqAction)
	end
end

function FinalReport:screenshotShareToWX()
	local layerSize = self.rootNode:getContentSize()
	local screenshot = cc.RenderTexture:create(gt.winSize.width, gt.winSize.height)
	screenshot:begin()
	self.rootNode:visit()
	screenshot:endToLua()

	local screenshotFileName = string.format("wx-%s.jpg", os.date("%Y-%m-%d_%H:%M:%S", os.time()))
	screenshot:saveToFile(screenshotFileName, cc.IMAGE_FORMAT_JPEG, false)

	self.shareImgFilePath = cc.FileUtils:getInstance():getWritablePath() .. screenshotFileName
	self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
	print("--------------------Screenshot name:", self.shareImgFilePath)
end

function FinalReport:update()
	if self.shareImgFilePath and cc.FileUtils:getInstance():isFileExist(self.shareImgFilePath) then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		local shareBtn = gt.seekNodeByName(self.rootNode, "Btn_share")
		shareBtn:setEnabled(true)

		local shareImgFilePath = self.shareImgFilePath
		print("--------------------Screenshot share:", shareImgFilePath)
		Utils.shareImageToWX( shareImgFilePath, 849, 450, 32 )
		self.shareImgFilePath = nil
	end
end

function FinalReport:onNodeEvent(eventName)
	if "enter" == eventName then
		-- local listener = cc.EventListenerTouchOneByOne:create()
		-- listener:setSwallowTouches(true)
		-- listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		-- local eventDispatcher = self:getEventDispatcher()
		-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		gt.removeTargetEventListenerByType(self, "EVT_CLOSE_FINAL_REPORT")
		
	end
end

function FinalReport:onTouchBegan(touch, event)
	return true
end

function FinalReport:onCloseFinalReport()
	self:removeFromParent()
end


return FinalReport


