
local gt = cc.exports.gt


local PKRoundReportSdy = class("PKRoundReportSdy", function()
	return cc.Layer:create()
end)

function PKRoundReportSdy:ctor(roomPlayers, playerSeatIdx, rptMsgTbl, roomid, isLast, localHeadImg, isFangZuobi)
	dump(rptMsgTbl)
	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end	
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("XiaojieLayerSdy.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
    --房间号
	local roomId=gt.seekNodeByName(csbNode,"Text_fanghao")
	roomId:setString("房间号:".. tostring(roomid))

    --房间号
    local Text_jushu=gt.seekNodeByName(csbNode,"Text_jushu")
    Text_jushu:setString("局数:".. rptMsgTbl.kCurCircle .. "/" .. rptMsgTbl.kCurMaxCircle)

    --rptMsgTbl.kCurCircle .. rptMsgTbl.kCurMaxCircle


    --底牌
	local Text_dipai = gt.seekNodeByName(csbNode,"Text_dipai")
    --埋底牌
    local Text_maipai = gt.seekNodeByName(csbNode,"Text_maipai")
    Text_maipai:setVisible(false)
    
	local Node_dipai = gt.seekNodeByName(csbNode,"Node_dipai")
    Node_dipai:setVisible(false)
    local Node_Maipai = gt.seekNodeByName(csbNode,"Node_Maipai")
    Node_Maipai:setVisible(false)
    Text_dipai:setVisible(false)
    --闲家得分
	local Text_xianjia = gt.seekNodeByName(csbNode,"Text_xianjia")
   Text_xianjia:setVisible(false)
    --庄家叫分
	local Text_zhuangjia = gt.seekNodeByName(csbNode,"Text_zhuangjia")
   Text_zhuangjia:setVisible(false)
    --状态
	local Text_status = gt.seekNodeByName(csbNode,"Text_status")
   Text_status:setVisible(false)

    --日期
    local roomDate=gt.seekNodeByName(csbNode,"Text_date")
    local date=os.date("%Y/%m/%d")
    roomDate:setString(date)

    --时间
    local Text_time=gt.seekNodeByName(csbNode,"Text_time")
    local _time=os.date("%H:%M:%S")
    Text_time:setString(_time)
    --分享
    local btn_share=gt.seekNodeByName(csbNode,"Btn_share")
    gt.addBtnPressedListener(btn_share,function ()
    	btn_share:setEnabled(false)
		self:screenshotShareToWX()
    end)

    --标题是结算还是总结算
    local Img_title_xiaojie=gt.seekNodeByName(csbNode,"Img_title_xiaojie")
    local Img_title_zongjie=gt.seekNodeByName(csbNode,"Img_title_zongjie")
    if rptMsgTbl.kIsFinish == 1 or rptMsgTbl.kIsFinish == 2 then
        Img_title_xiaojie:setVisible(false)
        Img_title_zongjie:setVisible(true)
    else
        Img_title_xiaojie:setVisible(true)
        Img_title_zongjie:setVisible(false)

        Node_dipai:setVisible(true)
        Node_Maipai:setVisible(true)
        Text_dipai:setVisible(true)
        Text_maipai:setVisible(true)

        Text_xianjia:setVisible(true)
        Text_zhuangjia:setVisible(true)
        Text_status:setVisible(true)
        Text_xianjia:setString("闲家得分:".. rptMsgTbl.kDefen)
        Text_zhuangjia:setString("庄家叫分:".. rptMsgTbl.kJiaofen)
        Node_dipai:removeAllChildren()
        Node_Maipai:removeAllChildren()
        if rptMsgTbl.kSate == 0 then
            Text_status:setString("提前结束")
        elseif rptMsgTbl.kSate == 1 then
            Text_status:setString("庄家保底")
        elseif rptMsgTbl.kSate == 2 then
            Text_status:setString("闲家未捡分，庄家翻倍")
        elseif rptMsgTbl.kSate == 3 then
            Text_status:setString("闲家未捡分，庄叫分100")
        elseif rptMsgTbl.kSate == 4 then
            Text_status:setString("闲家抠底，闲家翻倍")
        elseif rptMsgTbl.kSate == 5 then
            Text_status:setString("闲家抠底，庄叫分100")
        end
        for i=1, #rptMsgTbl.kBaseCards do
	       local card = ccui.ImageView:create()
	       card:loadTexture("res/sd/pk/" .. rptMsgTbl.kBaseCards[i] .. ".png")
           card:setScale(0.4)
           Node_dipai:addChild(card)
           card:setPosition(cc.p((i-1)*55, 0))
        end
        for i=1, #rptMsgTbl.kBaseCardsMai do
           local card = ccui.ImageView:create()
           card:loadTexture("res/sd/pk/" .. rptMsgTbl.kBaseCardsMai[i] .. ".png")
           card:setScale(0.4)
           Node_Maipai:addChild(card)
           card:setPosition(cc.p((i-1)*55, 0))
        end
    end
    
    -- 头像下载管理器
	local playerHeadMgr = gt.include("view/PlayerHeadManager"):create()
	self.rootNode:addChild(playerHeadMgr)

	local playerNum = #roomPlayers   --玩家人数
    dump(roomPlayers)
	-- 具体信息
	for seatIdx, roomPlayer in ipairs(roomPlayers) do
        print(seatIdx)
		local playerReportNode = gt.seekNodeByName(csbNode, "Node_player" .. seatIdx)

        --头像
		local Sprite_head = gt.seekNodeByName(playerReportNode, "Sprite_head")
        -- 昵称
		local nicknameLabel = gt.seekNodeByName(playerReportNode, "Text_name")

        -- ID
        local Text_id = gt.seekNodeByName(playerReportNode, "Text_id")
        Text_id:setString(tostring(roomPlayer.uid))

        if isFangZuobi and rptMsgTbl.kIsFinish == 0 then
		    nicknameLabel:setVisible(false)
            Text_id:setVisible(false)
            if playerSeatIdx == seatIdx then
	            playerHeadMgr:attach(Sprite_head, roomPlayer.headURL, nil, roomPlayer.sex, true)
            else
                Sprite_head:loadTexture("res/sd/headimg/" .. localHeadImg[seatIdx] ..".jpg")
            end
        else
		    nicknameLabel:setVisible(true)
		    --nicknameLabel:setString( gt.checkName ( roomPlayer.nickname , 5) ) 
            nicknameLabel:setString( tostring(roomPlayer.nickname) ) 
	        playerHeadMgr:attach(Sprite_head, roomPlayer.headURL, nil, roomPlayer.sex, true)
        end
        

        -- 分数
        local TextBMFont_jianScore = gt.seekNodeByName(playerReportNode, "TextBMFont_jianScore")
        local TextBMFont_jiaScore = gt.seekNodeByName(playerReportNode, "TextBMFont_jiaScore")
        if rptMsgTbl.kScore[seatIdx] > 0 then
		    TextBMFont_jianScore:setVisible(false)
		    TextBMFont_jiaScore:setVisible(true)
            TextBMFont_jiaScore:setString("+" .. tostring(rptMsgTbl.kScore[seatIdx]))

            if rptMsgTbl.kIsFinish ~= 1 and  rptMsgTbl.kIsFinish ~= 2 and roomPlayer.uid == gt.playerData.uid then 
                 gt.soundEngine:Poker_playEffect("sound_res/GAME_WIN.wav")
            end
        else
		    TextBMFont_jianScore:setVisible(true)
		    TextBMFont_jiaScore:setVisible(false) 
            TextBMFont_jianScore:setString(tostring(rptMsgTbl.kScore[seatIdx]))

            if rptMsgTbl.kIsFinish ~= 1 and  rptMsgTbl.kIsFinish ~= 2 and roomPlayer.uid == gt.playerData.uid then 
                 gt.soundEngine:Poker_playEffect("sound_res/COMPARE_LOSE.mp3")
            end
        end
        --庄
        local Img_zhuang = gt.seekNodeByName(playerReportNode, "Img_zhuang")

        --庄 底板
        local Img_zhuang_bg = gt.seekNodeByName(playerReportNode, "Img_bk")
        Img_zhuang_bg:loadTexture("res/sdy/jiesuanSdy/itembgbaiSdy.png")

        
        if gt.playerData.uid == roomPlayer.uid then
            Img_zhuang_bg:loadTexture("res/sdy/jiesuanSdy/itembghuangSdy.png")
        end

        --副庄
        local Img_fu = gt.seekNodeByName(playerReportNode, "Img_fu")
        
        Img_zhuang:setVisible(false)
        Img_fu:setVisible(false)
        if rptMsgTbl.kIsFinish == 0 then
            if rptMsgTbl.kZhuangPos == seatIdx-1 then
                Img_zhuang:setVisible(true)
                
            end
            if rptMsgTbl.kFuzhuangPos == seatIdx-1 then
                Img_fu:setVisible(true)
            end
            if rptMsgTbl.kZhuangPos == rptMsgTbl.kFuzhuangPos then
                Img_zhuang:setPosition(cc.p(-10,165))
            end
        end
    end

	-- 开始下一局
	local startGameBtn = gt.seekNodeByName(csbNode, "Btn_nextGame")
	gt.addBtnPressedListener(startGameBtn, function()
		self:removeFromParent()
		local msgToSend = {}
		msgToSend.kMId = gt.CG_READY
		msgToSend.kPos = playerSeatIdx - 1
		gt.socketClient:sendMessage(msgToSend)
	end)

    -- 查看总成绩
	local Btn_showFinal = gt.seekNodeByName(csbNode, "Btn_showFinal")
	gt.addBtnPressedListener(Btn_showFinal, function()
		self:removeFromParent()
		gt.dispatchEvent("_show_max_result_")
	end)

	-- 返回大厅
	local endGameBtn = gt.seekNodeByName(csbNode, "Btn_endGame")
	gt.addBtnPressedListener(endGameBtn, function()
        self:removeFromParent()
		gt.dispatchEvent("_back_room_")
	end)

    if rptMsgTbl.kIsFinish == 1 or rptMsgTbl.kIsFinish == 2 then
        --总结显示返回大厅
		startGameBtn:setVisible( false )
        Btn_showFinal:setVisible(false)
		endGameBtn:setVisible( true )
    else
	    if isLast then
	    	-- 最后一局
	    	startGameBtn:setVisible( false )
	    	endGameBtn:setVisible( false )
            Btn_showFinal:setVisible(true)
	    else
	    	-- 不是最后一局
	    	startGameBtn:setVisible( true )
	    	endGameBtn:setVisible( false )
            Btn_showFinal:setVisible(false)
	    end
    end
end
function PKRoundReportSdy:screenshotShareToWX()
	local layerSize = self.rootNode:getContentSize()
	local screenshot = cc.RenderTexture:create(gt.winSize.width, gt.winSize.height)
	screenshot:begin()
	self.rootNode:visit()
	screenshot:endToLua()

	local screenshotFileName = string.format("wx-%s.jpg", os.date("%Y-%m-%d_%H:%M:%S", os.time()))
	screenshot:saveToFile(screenshotFileName, cc.IMAGE_FORMAT_JPEG, false)

	self.shareImgFilePath = cc.FileUtils:getInstance():getWritablePath() .. screenshotFileName
	self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
end

function PKRoundReportSdy:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
	end
end

function PKRoundReportSdy:onTouchBegan(touch, event)
	return true

end

function PKRoundReportSdy:update()
	if self.shareImgFilePath and cc.FileUtils:getInstance():isFileExist(self.shareImgFilePath) then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		local share_Btn = gt.seekNodeByName(self.rootNode, "Btn_share")
		share_Btn:setEnabled(true)
		local shareImgFilePath = self.shareImgFilePath
		Utils.shareImageToWX( shareImgFilePath, handler(self, self.pushShareCodeImage) )
		self.shareImgFilePath = nil
	end
end

function PKRoundReportSdy:pushShareCodeImage(authCode)
	gt.log("===================HY", authCode, type(authCode))
end
return PKRoundReportSdy

