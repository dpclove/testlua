
local gt = cc.exports.gt
local Utils = cc.exports.Utils




-- -- csw 1-15

package.loaded["client/message/MessageInit"] = nil
require("client/message/MessageInit")

-- -- cde 1- 15

-- require("client/tools/EnumConfig")
local MainScene = class("MainScene", function()
	return display.newScene("MainScene")
end)

MainScene.ZOrder = {
	FZ_RECORD 				= 4,
	HISTORY_RECORD			= 5,
	SELECTGAME_ROOM			= 6,
	CREATE_ROOM				= 7,
	JOIN_ROOM				= 8,
 	INVITATION_CODE         = 9,
	PLAYER_INFO_TIPS		= 10,
	TASK_INVITE				= 15,
	CLUB 					= 16,
	CONFIRM					= 30
}


--com.coolplaystore.haoyunlaipubilc


local Update_idx = gt.Update_idx or 1


function MainScene:ctor(isNewPlayer, isRoomCreater, roomID, numberMark, uploadFlag)

	gt.log("scene...name",display.getRunningScene().name)

	self.isNewPlayer = isNewPlayer
 	-- 记录一个全局打了多少把麻将次

 	--记录进入主场景时的房间id
 	self.roomID = roomID
 	
 	--是否开启比赛场
 	self.isOpenSport = false
 	-- 判断是否显示绑定手机页面
 	gt.bindingPhone = "TaskLayer"
	-- 反馈数
 	if not gt.isNumberMark then
 		gt.isNumberMark = 0
 	end
 	gt.isNumberMark = gt.isNumberMark + (numberMark or 0)
	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end
	self.isRoomCreater = isRoomCreater
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	gt.log("mainscene_________________")
	local csbNode = cc.CSLoader:createNode("MainScene.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode


	-- local url = "http://apk.haoyunlaiyule2.com/zy_zjh-release-signed1.4.4Online.apk"

	-- local node  = require("client/game/dialog/UpdateApk"):create(url)
	-- self:addChild(node, gt.CommonZOrder.NOTICE_TIPS+1000)
	

	-- local MainNpc = require("client/game/majiang/MainNpc"):create()
	-- MainNpc:setPosition(cc.p(0,0))
	-- gt.seekNodeByName(csbNode, "Spr_bg"):addChild(MainNpc)
	-- gt.log("npc_________________________________",gt.isAppStoreInReview)
 --    if gt.isAppStoreInReview then
 --    	MainNpc:setVisible(false)
 --    end 
 --    MainNpc:setVisible(false)
	-- 添加热更新公告弹窗
	-- if gt.isViaUpdate2Scene == true then
 --        gt.isViaUpdate2Scene = false
 --        local updateMsg = require("app/views/UpdateMsg"):create()
 --        self:addChild(updateMsg, 100)
 --    end


	-- self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
 --    	Toast.showToast(self, gt.unionid, 10)
	-- end)))




	local playerData = gt.playerData
	-- 断线重连提示
	-- self.node_top = cc.CSLoader:createNode("top_node.csb")
	-- self:addChild(self.node_top,1000)
	-- self.node_top:setPosition(cc.p(gt.winCenter.x,720))
	-- 玩家信息
	local playerInfoNode = gt.seekNodeByName(csbNode, "Node_playerInfo")
	-- 头像
	local headSpr = gt.seekNodeByName(playerInfoNode, "Image1")
	--local parent = gt.seekNodeByName(playerInfoNode, "kuang")

	--点击个人中心
	local centerFrameBtn = gt.seekNodeByName(csbNode, "Panel")



	gt.setOnViewClickedListener(centerFrameBtn, function()
		if gt.csw_app_store then return end
		gt.soundEngine:playEffect("common/audio_button_click", false)
		local UserCenter = require("client/game/common/UserCenter"):create(gt.playerData)
		self:addChild(UserCenter, MainScene.ZOrder.HISTORY_RECORD)
	end)
		
	local data = playerData.headURL
	--data = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"
	if type(data) ~= nil and  string.len(data) > 10 then
		local icon =  headSpr
		local iamge = gt.imageNamePath(data)
		headSpr:setVisible(false)

	  	if iamge then
	  		local _node = display.newSprite("zy_zjh/icon.png")
			local head = gt.clippingImage(iamge,_node,false)
			centerFrameBtn:setLocalZOrder(head:getLocalZOrder()+1)
			playerInfoNode:addChild(head)
			head:setName("__ICON___M")
			head:setPosition(icon:getPositionX(),icon:getPositionY())
	  	else
	  		local function callback(args)
	      		if args.done and self then
					local _node = display.newSprite("zy_zjh/icon.png")
					local head = gt.clippingImage(args.image,_node,false)
					centerFrameBtn:setLocalZOrder(head:getLocalZOrder()+1)
					playerInfoNode:addChild(head)
					head:setName("__ICON___M")
					head:setPosition(icon:getPositionX(),icon:getPositionY())
				end
	        end
		    local url = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"
		    url = data
		    gt.downloadImage(url,callback)	
	  	end
	else
		headSpr:setVisible(true)
	end

	self.id1 = 0
	self.id2 = 0


	gt.setOnViewClickedListener(gt.seekNodeByName(csbNode, "Image_5"), function()
			gt.soundEngine:playEffect("common/audio_button_click", false)
			-- if not self.help_node then  self.help_node  =  cc.CSLoader:createNode("playText.csb") self:addChild(self.help_node, 23) 

			-- gt.setOnViewClickedListener(gt.seekNodeByName(self.help_node, "close"), function()
			-- 	gt.soundEngine:playEffect("common/audio_button_click", false)
			-- 		self.help_node:setVisible(false)
			-- 	end)
			-- else self.help_node:setVisible(true) end
			gt.log("help_______________")
			local helpLayer = require("client/game/poker/view/HelpScene"):create()
			self:addChild(helpLayer, 23)
		end)

	-- local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
	-- playerHeadMgr:attach(headSpr, parent, playerData.uid, playerData.headURL)
	-- gt.headURL = playerData.headURL
	-- self:addChild(playerHeadMgr)
	-- 昵称
	local nicknameLabel = gt.seekNodeByName(playerInfoNode, "Label_nickname")
	-- nicknameLabel:setString(gt.checkName(playerData.nickname,8))

	nicknameLabel:setString(playerData.nickname)
	
	gt.nickname = playerData.nickname
	-- 点击头像显示信息
	-- local headFrameBtn = gt.seekNodeByName(playerInfoNode, "Btn_headFrame")
	-- headFrameBtn:addClickEventListener(function()
	-- 	if gt.isShoppingShow then
	-- 		local UserCenter = require("client/game/common/UserCenter"):create(gt.playerData)
	-- 		self:addChild(UserCenter, MainScene.ZOrder.HISTORY_RECORD)
	-- 	else
	-- 		local UserInfo = require("client/game/majiang/UserInfo"):create(gt.playerData)
	-- 		self:addChild(UserInfo, MainScene.ZOrder.PLAYER_INFO_TIPS)			
	-- 	end
	-- end)




	local refreshCardNum = gt.seekNodeByName(csbNode, "Btn_refreshcoin")
	if gt.isAppStoreInReview then
		refreshCardNum:setVisible(false)
	else
		refreshCardNum:setVisible(true)
	end	
	gt.addBtnPressedListener(refreshCardNum, function()
		self:refreshMoney()
	end)

	refreshCardNum:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
		self:refreshMoney()
	end)))

	
	--切割头像
	-- local headSpr = gt.seekNodeByName(playerInfoNode, "Spr_head")
	-- headSpr:setScale(0.85)
	-- headSpr:removeFromParent(true)
	-- local stencil = cc.Sprite:create("res/images/otherImages/main_avatar_bg.png")
	-- local clipper = cc.ClippingNode:create()
	-- clipper:setStencil(stencil)
	-- clipper:setInverted(false)
	-- clipper:setAlphaThreshold(0)
	-- local x,y = headFrameBtn:getPosition()
	-- local headFrameSize = headFrameBtn:getContentSize()
	-- clipper:setPosition(cc.p(headFrameSize.width/2,headFrameSize.height/2))
	-- clipper:addChild(headSpr)
	-- headFrameBtn:addChild(clipper)

	-- --头像遮罩
	-- local stencil = cc.Sprite:create("res/images/otherImages/main_avatar_bg.png")
	-- local clipper = cc.ClippingNode:create()
	-- clipper:setStencil(stencil)
	-- clipper:setInverted(true)
	-- clipper:setAlphaThreshold(0)
	-- clipper:setScale(0.85)
	-- local x,y = headFrameBtn:getPosition()
	-- local headFrameSize = headFrameBtn:getContentSize()
	-- clipper:setPosition(cc.p(headFrameSize.width/2,headFrameSize.height/2))
	-- headSpr:removeFromParent(false)
	-- clipper:addChild(headSpr)
	-- headSpr:setAnchorPoint(cc.p(0.5,0.5))
	-- local clipperSize = clipper:getContentSize()
	-- headSpr:setPosition(cc.p(clipperSize.width/2,clipperSize.height/2))
	-- headFrameBtn:addChild(clipper)
		





	--centerFrameBtn:setVisible(gt.isShoppingShow)
	--centerFrameBtn:setVisible(false)
	-- centerFrameBtn:addClickEventListener(function()
	-- 	if gt.isShoppingShow then
	-- 		local UserCenter = require("client/game/common/UserCenter"):create()
	-- 		self:addChild(UserCenter, MainScene.ZOrder.HISTORY_RECORD)
	-- 	else
	-- 		local UserInfo = require("client/game/majiang/UserInfo"):create(gt.playerData)
	-- 		self:addChild(UserInfo, MainScene.ZOrder.PLAYER_INFO_TIPS)		
	-- 	end
	-- end)

	--local frameSize = headFrameBtn:getContentSize()
	-- 房卡信息
	-- local roomCardLabel = gt.seekNodeByName(playerInfoNode, "Label_cardInfo")
	--roomCardLabel:setString(gt.getLocationString("LTKey_0004", playerData.roomCardsCount[2], playerData.roomCardsCount[3]))

	if gt.isAppStoreInReview == false then
		--购买金币
	    local Gold_btn1 = gt.seekNodeByName(playerInfoNode, "Gold_btn1")
		gt.addBtnPressedListener(Gold_btn1, function()
			gt.log("c_____!")
			local commitinvite = cc.UserDefault:getInstance():getIntegerForKey("InvitationCode"..tostring(gt.playerData.uid), 0)
			if commitinvite ~= 1 then
				local bindlayer = require("client/game/common/InvitationCodeInputLayers"):create()
				self:addChild(bindlayer, 999)
			else
				local ShoppingLayer = require("client/game/common/ShoppingLayer"):create(self)
				self:addChild(ShoppingLayer, MainScene.ZOrder.HISTORY_RECORD)
				ShoppingLayer:setName("ShoppingLayer")
			end

			

		end)


	    local Gold_btn2 = gt.seekNodeByName(playerInfoNode, "Gold_btn2")
		gt.addBtnPressedListener(Gold_btn2, function()
			gt.log("c_____3")
			local commitinvite = cc.UserDefault:getInstance():getIntegerForKey("InvitationCode"..tostring(gt.playerData.uid), 0)
			if commitinvite ~= 1 then
				local bindlayer = require("client/game/common/InvitationCodeInputLayers"):create()
				self:addChild(bindlayer, 999)
			else
				local ShoppingLayer = require("client/game/common/ShoppingLayer"):create(self)
				self:addChild(ShoppingLayer, MainScene.ZOrder.HISTORY_RECORD)
				ShoppingLayer:setName("ShoppingLayer")
			end
		end)
	else
	    local Gold_btn2 = gt.seekNodeByName(playerInfoNode, "Gold_btn2")
		Gold_btn2:setVisible(false)
	end




	gt.addBtnPressedListener(gt.seekNodeByName(csbNode, "cardNum"), function()
			gt.log("c_____!")
			local commitinvite = cc.UserDefault:getInstance():getIntegerForKey("InvitationCode"..tostring(gt.playerData.uid), 0)
			if commitinvite ~= 1 then
				local bindlayer = require("client/game/common/InvitationCodeInputLayers"):create()
				self:addChild(bindlayer, 999)
			else
				local ShoppingLayer = require("client/game/common/ShoppingLayer"):create(self)
				self:addChild(ShoppingLayer, MainScene.ZOrder.HISTORY_RECORD)
				ShoppingLayer:setName("ShoppingLayer")
			end

			

		end)


	-- 房卡信息
    local ttf_eight = gt.seekNodeByName(playerInfoNode, "Txt_numbereight")
	ttf_eight:setString(playerData.roomCardsCount[2])
	if gt.isAppStoreInReview then
		local money = cc.UserDefault:getInstance():getIntegerForKey("money"..tostring(gt.playerData.uid), 0)
		if playerData.roomCardsCount[2] > money then
			money = playerData.roomCardsCount[2]
		end
		cc.UserDefault:getInstance():setIntegerForKey("money"..tostring(gt.playerData.uid), money)
		ttf_eight:setString(money)
	end
    
    cc.UserDefault:getInstance():setStringForKey("ttf", playerData.roomCardsCount[2])
    cc.UserDefault:getInstance():setStringForKey("diamond",playerData.roomCardsCount[4] )

    gt.money = tonumber(playerData.roomCardsCount[2])



	-- 玩家id信息
	local  label_forID = gt.seekNodeByName(playerInfoNode, "Label_ID")

	gt.log("id....",gt.playerData.uid)

	label_forID:setString( "ID:" .. gt.playerData.uid )

	
	


	--  csw
	--require("app/views/NoticeForGiftCourtesyTipss"):create()
	if gt.isAppStoreInReview == false then
		--self:setGiftCourtesy()
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),
			cc.CallFunc:create(function()
				self:setUpdateVersion()
				self:setpubliset1()
		end)))
		--self:Activity11_9()
	else
		gt.seekNodeByName(self.rootNode,"haoqidai"):setVisible(true)
	end
	--self:adImage()
	self:init()
	
	--self:shimengrenzheng()
	-- csw

	 
	--require("client/game/dialog/NoticeForGiftCourtesyTipss"):create()


	gt.addBtnPressedListener(gt.seekNodeByName(csbNode, "Btn_kf"), function()

		self:get_kefu()


		end)

	-- 创建/返回房间
	-- 加特效
	local createRoomBtn = gt.seekNodeByName(csbNode, "btn_createRoom")
	gt.addBtnPressedListener(createRoomBtn, function()

		if gt.csw_app_store then
			if gt.CreateRoomFlag and gt.isCreateUserId then
					-- 房主返回房间
					-- 发送进入房间消息
					self:onCallback(true)
			else
				self:create_room_appStore()
			end
		else
				if gt.CreateRoomFlag and gt.isCreateUserId then
					-- 房主返回房间
					-- 发送进入房间消息
					self:onCallback(true)
				else
					self:getGPS()
					local selectGameLayer = require("client/game/majiang/SelectGame"):create()
					selectGameLayer:setName("SelectGame")
					self:addChild(selectGameLayer, MainScene.ZOrder.SELECTGAME_ROOM)
				end
		end

	end)

	

	-- 进入房间
	local joinRoomBtn = gt.seekNodeByName(csbNode, "btn_joinRoom")
	gt.addBtnPressedListener(joinRoomBtn, function()

		if gt.CreateRoomFlag and gt.isCreateUserId then
			self:onCallback(true)

		else
			self:getGPS()
			self:onCallback()
		end
	end)

	-- 进入文娱馆
	--local joinClubBtn = gt.seekNodeByName(MainNpc.rootNode, "Btn_joinClub")
	local	joinClubBtn = gt.seekNodeByName(csbNode,"btn_club")
	gt.addBtnPressedListener(joinClubBtn, function()
		self:getClubs()
	end)
	if gt.isAppStoreInReview then
		joinClubBtn:setVisible(false)
	end

	-- -- 在线人数
	-- self.onlinePlayerCountImg = gt.seekNodeByName(MainNpc.rootNode, "Img_onlinePlayerCount")
	-- self.onlinePlayerCountImg:setVisible(false)
	-- self.onlinePlayerCountLabel = gt.seekNodeByName(MainNpc.rootNode, "Label_onlinePlayerCount")
	-- self.onlinePlayerCountLabel:setVisible(false)
	-- if self.onlinePlayerCountImg then
	-- 	self.onlinePlayerCountImg:setVisible(false)
	-- end


	gt.log("mainScene___init_______________")
	
	-- 进入房间
	gt.socketClient:registerMsgListener(gt.GC_ENTER_ROOM, self, self.onRcvEnterRoom)

	local btnBundleNode = gt.seekNodeByName(csbNode, "Node_Buttom")


	--版本号
	gt.versionCodeTxt = gt.v or ""

    --版本号
	local versionCodeTxt = gt.seekNodeByName(self.rootNode, "Txt_versionCode")
	versionCodeTxt:setString(gt.versionCodeTxt)

	-- 退出
	local exitBtn = gt.seekNodeByName(btnBundleNode, "Btn_setting")
	gt.addBtnPressedListener(exitBtn, function()
		local settingPanel = require("client/game/common/SettingMain"):create()
		self:addChild(settingPanel, 666)
	end)
	if (gt.isInReview) then
		exitBtn:setVisible(false)
	else
		exitBtn:setVisible(true)
	end



	-- 商城
	local shoppingMallBtn = gt.seekNodeByName(btnBundleNode, "Btn_shoppingmall")
	gt.addBtnPressedListener(shoppingMallBtn, function()
		gt.log("c_____4")
		local commitinvite = cc.UserDefault:getInstance():getIntegerForKey("InvitationCode"..tostring(gt.playerData.uid), 0)
			if commitinvite ~= 1 then
				local bindlayer = require("client/game/common/InvitationCodeInputLayers"):create()
				self:addChild(bindlayer, 999)
			else
				local ShoppingLayer = require("client/game/common/ShoppingLayer"):create(self)
				self:addChild(ShoppingLayer, MainScene.ZOrder.HISTORY_RECORD)
				ShoppingLayer:setName("ShoppingLayer")
			end
	end)

	-- shoppingMallBtn:setVisible(gt.isShoppingShow)

	-- 好礼
	local GiftCourtesyNode = gt.seekNodeByName(self.rootNode, "NodeGiftCourtesy")
	if gt.isAppStoreInReview then
		GiftCourtesyNode:setVisible(false)
	else
		GiftCourtesyNode:setVisible(true)
	end	

	-- 战绩
	
	local historyBtn = gt.seekNodeByName(btnBundleNode, "Btn_history")
	gt.addBtnPressedListener(historyBtn, function()
		self:poker_zj()
		if gt.removeLog then
			gt.removeLog()
		end
		gt.showLoadingTips("读取数据中")
	end)
	if gt.isInReview == true then
		historyBtn:setVisible(false)
	else
		historyBtn:setVisible(true)
	end
	--战绩未做，先屏蔽掉
	-- historyBtn:setVisible(false)

	local fzBtn = gt.seekNodeByName(btnBundleNode, "Btn_message")
	gt.addBtnPressedListener(fzBtn, function()
		self:sendFZRecordMsg()
	end)
	-- 帮助
	local helpBtn = gt.seekNodeByName(btnBundleNode, "Btn_help")
	gt.addBtnPressedListener(helpBtn, function()
		local helpLayer = require("client/game/majiang/HelpScene"):create()
		self:addChild(helpLayer, 8)
	end)


	-- 活动按钮
	self.m_activityBtn = gt.seekNodeByName(btnBundleNode, "Btn_activity")
	if (gt.isInReview) then
		self.m_activityBtn:setVisible(false)
	else
		self.m_activityBtn:setVisible(false)
	end	
	local freeText = gt.seekNodeByName(btnBundleNode, "free_text")
	freeText:setVisible(false)
	if self.m_activityBtn then
		local drawNum = gt.playerData.luckyDrawNum or 0
		if gt.isNumberMark == 8 and drawNum > 0 then
			if not gt.isSendActivities then
				-- gt.isSendActivities = true
				-- self:sendGetActivities()
			end
		end
		gt.addBtnPressedListener(self.m_activityBtn, function()
			if not gt.isSendActivities then
				gt.isSendActivities = true
				self:sendGetActivities()
			end
		end)
	
		if gt.m_activeID and gt.m_activeID > -1 then
			self.m_activityBtn:setVisible(false)  --隐藏
		else
			self.m_activityBtn:setVisible(false)
		end
	end

	-- 送金币按钮
	self.shareGiftBtn = gt.seekNodeByName(self.rootNode, "Btn_shareGift")
	self.shareGiftBtn:setVisible(false)
	if self.shareGiftBtn then
		gt.addBtnPressedListener(self.shareGiftBtn, function()
       		local GiftCourtesy = require("client/game/activity/GiftCourtesy"):create(self.bindcoin)
			self:addChild(GiftCourtesy, 8)
			GiftCourtesy:setName("GiftCourtesy")
		end)
	end

	-- self:getShareShow()

	local otherMahjong = {"hainan", "guangxi", "fujian", "doudizhu", "paohuzi"}
	local urlSite = {"mahjonghainan", "mahjongguangxi", "mahjongfujian", "ddz", "mahjongsyxm"}
	--隐藏
	-- local otherMahjong = {"sichuan", "more","paohuzi"}
	table.foreach(otherMahjong, function(i, name)
		local button = gt.seekNodeByName(csbNode, "Button_" .. name)
		if button then
			if (gt.isInReview) then
				button:setVisible(false)
			else
				button:setVisible(false)
			end			
			if button:getName() == "Button_sichuan" then
				button:setContentSize(cc.size(147, 102))
			end
			gt.addBtnPressedListener(button, function()
				-- local url = gt.shareWeb
				local url = "http://a.app.qq.com/o/simple.jsp?pkgname=com.xianlai." .. urlSite[i]
				if button:getName() == "Button_sichuan" then
					url = "http://a.app.qq.com/o/simple.jsp?pkgname=com.xianlai.ddz"
				end
				if gt.isIOSPlatform() then
					self.luaBridge = require("cocos/cocos2d/luaoc")
				elseif gt.isAndroidPlatform() then
					self.luaBridge = require("cocos/cocos2d/luaj")
				end
				if gt.isIOSPlatform() then
					local ok = self.luaBridge.callStaticMethod("AppController", "openWebURL",
						{webURL = url})
				elseif gt.isAndroidPlatform() then
					local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "openWebURL",
						{url}, "(Ljava/lang/String;)V")
				end
			end)
		end
	end)

	local bindBtn = gt.seekNodeByName(self.rootNode, "bind")
	gt.addBtnPressedListener(bindBtn, function()
		local commitinvite = cc.UserDefault:getInstance():getIntegerForKey("InvitationCode"..tostring(gt.playerData.uid), 0)
		if commitinvite ~= 1 then
			local bindlayer = require("client/game/common/InvitationCodeInputLayers"):create()
			self:addChild(bindlayer, 999)
		else
			Toast.showToast(self, "您已经绑定邀请码", 2)
		end
	end)

	if gt.isAppStoreInReview == false then
		--是否输入邀请码
	   	local commitinvite = cc.UserDefault:getInstance():getIntegerForKey("InvitationCode"..tostring(gt.playerData.uid), 0)
	   	-- gt.log("-----------------------commitinvite", commitinvite)
		if commitinvite ~= 1 then
			gt.log("-------------------------------是否输入邀请码")
			Utils.requestInvite(commitinvite)
		end
	end

	gt.registerEventListener("refreshMoney",self,self.refreshMoney)
	gt.registerEventListener("MainSceneAddText",self,self.top)
	gt.registerEventListener("f5",self,self.r5_activity)
	-- 注册消息回调
	gt.socketClient:registerMsgListener(gt.GC_LOGIN_SERVER, self, self.onRcvLoginServer)
	gt.socketClient:registerMsgListener(gt.GC_ROOM_CARD, self, self.onRcvRoomCard)
	--gt.socketClient:registerMsgListener(gt.GC_MARQUEE, self, self.onRcvMarquee)
	-- 服务器推送活动信息
	--gt.socketClient:registerMsgListener(gt.GC_LOTTERY, self, self.onRecvLotteryInfo)
	-- 服务器进入游戏自动推送是否有活动
	--gt.socketClient:registerMsgListener(gt.GC_IS_ACTIVITIES, self, self.onRecvIsActivities)

	gt.registerEventListener(gt.EventType.GM_CHECK_HISTORY, self, self.gmCheckHistoryEvt)

	gt.registerEventListener(gt.EventType.REFRESH_CARD_COUNT, self, self.refreshCardsCount)

	gt.registerEventListener(gt.EventType.APPSTORE_REFRESH_CARD_COUNT, self, self.appStoreRefreshMoney)

	gt.socketClient:registerMsgListener(gt.GC_REMOVE_PLAYER, self, self.onRcvRemovePlayer)

	--TEST
  	gt.socketClient:registerMsgListener(gt.GC_TOAST, self, self.onRcvToast)

	-- 断线重连
	gt.socketClient:registerMsgListener(gt.GC_LOGIN, self, self.onRcvLogin)
	gt.socketClient:registerMsgListener(gt.GC_LOGIN_GATE, self, self.onRcvLoginGate)

	-- 推送是否绑定过手机
	-- gt.socketClient:registerMsgListener(gt.CG_USER_EXTERN_INFO, self, self.onUserExternInfo)
	-- gt.socketClient:registerMsgListener(gt.CG_USER_EXTERN_INFO, self, self.onUserExternInfo)
	-- 服务器推送好友进入房间
	-- gt.socketClient:registerMsgListener(gt.GC_ADD_PLAYER, self, self.onFriendJoinRoom)
	if gt.isCheckResVersion and not gt.debugInfo.Update and gt.targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
		self:requestVersion()
	end

	--self:checkFeeback()
	--self:showMoonFreeCard()
	self:setIp()

	self.AppVersion = self:getAppVersion()
	if self.AppVersion > 10 then
		if uploadFlag then
			self:setLoginLog()
		else
			if tonumber(os.date("%d", os.time())%10) == 1 then
				if gt.removeLog then
					gt.removeLog()
				end
			end
		end
	end
	if gt.csw_app_store then
		self:appStore()
	end
	local bg = gt.seekNodeByName(self.rootNode, "Spr_bg")
	local playingNode, playingAni = gt.createCSAnimation("res/animation/girl_action/girl_action.csb")
	playingAni:play("run_action", true)
	local posX = bg:getPositionX() - 320
	local posY = bg:getPositionY() - 60
	playingNode:setPosition(cc.p(posX,posY))
	gt.addNode(bg,playingNode)

end  

function MainScene:create_room_appStore()

				local msgToSend = {}
				msgToSend.kGpsLimit = 0
				msgToSend.kMId = gt.CG_CREATE_ROOM
				msgToSend.kPlayType = {}
				msgToSend.kFlag = 1 --== 1 and 1 or 16 -- (8 or 16) -- 局数 1 代表 8  2 代表 16
				msgToSend.kState =   101        --   炸金花  102，斗地主  101，牛牛    103，
				msgToSend.kFeeType =  1     --（费用类型 ，0:房主付费 1:玩家分摊）
				msgToSend.kDeskType = 0
				msgToSend.kGpsLng = tostring(0)
				msgToSend.kGpsLat = tostring(0)
				msgToSend.kGreater2CanStart = 0

				msgToSend.kPlayType[1] = 1
				msgToSend.kPlayType[2] = 1
				msgToSend.kPlayType[3] = 3
				msgToSend.kPlayType[4] = 5
				msgToSend.kPlayType[5] = 0
				
		
				--msgToSend.kPlayType[13] = 1 
				

				gt.log("创建房间________",self.wanfa)
				gt.dump(msgToSend)
				gt.socketClient:sendMessage(msgToSend)

				gt.showLoadingTips("房间创建中...")

end

function MainScene:appStore()

gt.seekNodeByName(self.rootNode, "bind"):setVisible(false)
gt.seekNodeByName(self.rootNode, "cardNum"):setVisible(false)
gt.seekNodeByName(self.rootNode, "Gold_btn1"):setVisible(false)
gt.seekNodeByName(self.rootNode, "Btn_refreshcoin"):setVisible(false)
gt.seekNodeByName(self.rootNode, "sp_trumpet_bg"):setVisible(false)
gt.seekNodeByName(self.rootNode, "btn_club"):setVisible(false)
gt.seekNodeByName(self.rootNode, "btn_joinRoom"):setPositionY(gt.seekNodeByName(self.rootNode, "btn_joinRoom"):getPositionY()+120)
gt.seekNodeByName(self.rootNode, "btn_createRoom"):setPosition(gt.seekNodeByName(self.rootNode, "btn_joinRoom"):getPositionY()-300,gt.seekNodeByName(self.rootNode, "btn_joinRoom"):getPositionY())
gt.seekNodeByName(self.rootNode, "Node_Buttom"):setVisible(false)
gt.seekNodeByName(self.rootNode, "Image_5"):setVisible(false)
gt.seekNodeByName(self.rootNode, "Spr_bg"):setScaleY(1.2)
gt.seekNodeByName(self.rootNode, "Spr_bg"):setPositionY(gt.seekNodeByName(self.rootNode, "Spr_bg"):getPositionY()-70)
end

function MainScene:poker_zj()

	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_POKER_ROOM_LOG, self, self.onRcvHistoryRecord)
	local m = {}
	m.kMId = 	gt.MSG_C_2_S_POKER_ROOM_LOG
	m.kUserId = gt.playerData.uid
	gt.socketClient:sendMessage(m)

end

function MainScene:getGPS()

	if gt.csw_app_store then return end

	if gt.isIOSPlatform() then
		local ok, ret = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "startTrackLocation")
	elseif gt.isAndroidPlatform() then
		local ok, ret = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "startTrackLocation",nil,"()V")
	end

end

function MainScene:top()
	-- if self.node_top then 
		-- self.node_top:setPosition(cc.p(gt.winCenter.x,720))
		-- self.node_top:stopAllActions()
		-- self.node_top:runAction(cc.MoveTo:create(0.5,cc.p(gt.winCenter.x,720-50)))
		-- gt.seekNodeByName(self.node_top, "Text_1"):setString("网络已断开,正在重新连接...")
		gt.log("--------------------------------LTKey_0058")
		gt.showLoadingTips(gt.getLocationString("LTKey_0058"))
		gt.topFlag = true
	-- end
end

function MainScene:removetop()
	-- if self.node_top then
		-- gt.seekNodeByName(self.node_top, "Text_1"):setString("重新连接服务器成功!")
		-- self.node_top:stopAllActions()
		-- self.node_top:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.MoveTo:create(0.5,cc.p(gt.winCenter.x,720))))
		-- 	gt.log("-------------------------------------gt.sendFZRecordMsgFlag", gt.sendFZRecordMsgFlag)
		-- 	gt.log("-------------------------------------gt.sendFZRecordMsgFlag", self:getChildByName("GiftCourtesy"))
		if self:getChildByName("FZRecord") and gt.sendFZRecordMsgFlag then
			self:getChildByName("FZRecord"):sendFZRecordMsg()
		end
		
		gt.removeLoadingTips()
		gt.topFlag = false
	-- end
end

function MainScene:shimengrenzheng()

	--http://test.api.haoyunlaiyule1.com/user/auth?user_id=112&real_name=1&identity_no=1
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local PublishURL = gt.getUrlEncryCode(gt.upuserDate, gt.playerData.uid)
	PublishURL = PublishURL.."&real_name="
		local function onResp()
		
		local runningScene = display.getRunningScene()
		gt.log(PublishURL)
	   	if runningScene and runningScene.name == "MainScene" then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then

			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()

end

function MainScene:adImage()
	
	local url = "http://static.player.haoyunlaiyule1.com/img/wx_wanjiafuli.jpg"
	--cc.FileUtils:getInstance():setSearchPaths(cc.FileUtils:getInstance():getWritablePath())

	if gt.imageNamePath(url) then
		
		--self.iamgess = gt.imageNamePath(url)

	else
		local call = function(args)
	    	local runningScene = display.getRunningScene()
	    		print("ms................",socket.gettime()- self.time)
				if runningScene and runningScene.name == "MainScene" then
	    		if args.done then
	    		
	    			--self.iamgess = args.iamge
	    			
	    		end
	    	end
    	end
    	self.time = socket.gettime()
    	gt.downloadImage(url,call)
	end

end


function MainScene:init()

	gt.seekNodeByName(self.rootNode,"Image_wechat"):setVisible(false)
	local kuang = gt.seekNodeByName(self.rootNode,"kuang")

	self._stencil  = display.newSprite()
	self._stencil:retain()
	self._stencil:setTextureRect(cc.rect(0,0,380,315))
	local _notifyClip = cc.ClippingNode:create(self._stencil)
						:setAnchorPoint(cc.p(0,0))
						:move(202,182)
	_notifyClip:setInverted(false)
	_notifyClip:addTo(kuang)

	self.node_player = _notifyClip
	self.csw_node = {}

end

function MainScene:Activity11_9()

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local PublishURL = gt.getUrlEncryCode(gt.list, gt.playerData.uid)
	--PublishURL = "http://test.api.haoyunlaiyule1.com/act/index?user_id=454aaaaaa"
	xhr:open("GET", PublishURL)
	local function onResp()
		
		local runningScene = display.getRunningScene()
		gt.log("榜单————————————————————————",runningScene.name)
		gt.log(PublishURL)
	   	if runningScene and runningScene.name == "MainScene" then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	            local response = xhr.response
	            local respJson = require("cjson").decode(response)

	      --        local  ok, respJson = pcall(function()
			    --    return require("cjson").decode(response)
			    -- end)
			    -- if not ok then
			    -- 	return
			    -- end
			    gt.log("--------------------time", os.date("%Y-%m-%d", os.time()))
	            gt.dump(respJson)
	            local buf = {}
				local bufp = {}
	            if respJson.errno == 0 then
	            	self.isbend = respJson.data.is_bind
	            	print("self.isbend,,,,,,,,,,,,,,,",self.isbend)
	            	local num = respJson.data.awards.total_count
	            	local today = os.date("%Y-%m-%d", os.time())
	            	local yesterday = cc.UserDefault:getInstance():getStringForKey(tostring(gt.playerData.uid).."current_day", os.date("%Y-%m-%d", os.time()))
	            	if today ~= yesterday then
	            		cc.UserDefault:getInstance():setIntegerForKey(tostring(gt.playerData.uid).."list_num", 0)
	            	end
	            	local oldNum = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."list_num", 0)
	            	if num > oldNum then -- 新增
	            		if not self.Action_node then 
	            			self.Action_node = cc.CSLoader:createNode("addScore.csb")
	            			self.Action_node:setPosition(cc.p(245,200))
	            			self:addChild(self.Action_node)
	            		end
	            		gt.seekNodeByName(self.Action_node,"AtlasLabel_1"):setString("/"..tostring(num-oldNum))
	            		local act = cc.CSLoader:createTimeline("addScore.csb")
	            		self.Action_node:runAction(act)
	            		act:gotoFrameAndPlay(0,false)
	            	end
	            	cc.UserDefault:getInstance():setStringForKey(tostring(gt.playerData.uid).."current_day", os.date("%Y-%m-%d", os.time()))
	            	cc.UserDefault:getInstance():setIntegerForKey(tostring(gt.playerData.uid).."list_num",num)
	            	if #respJson.data.awards.list == 0 then
	            		gt.seekNodeByName(self.rootNode,"haoqidai"):setVisible(true)
	            	else
	            		gt.seekNodeByName(self.rootNode,"haoqidai"):setVisible(false)
	            	end
	            	-- for i =1 ,#self.csw_node do

	            	-- 	self.csw_nod[i]:removeFromParent() end

	            	-- end
	            	self.node_player:removeAllChildren()
	            	self.csw_node = {}
	                for i = 1, #respJson.data.awards.list do
	                	local id = respJson.data.awards.list[i].user_id
	                	local name = respJson.data.awards.list[i].nick_name
	                	local avatar = respJson.data.awards.list[i].avatar
	                	gt.log("url1..............",avatar)
	                	local url = string.sub(avatar,0,string.len(avatar)-1).."96"
	                	gt.log("url..............",url)
	                	local money = respJson.data.awards.list[i].money
	                	local coin = respJson.data.awards.list[i].coin
	                	local sort = respJson.data.awards.list[i].sort or 1
	                	local value = respJson.data.awards.list[i].value or 0

	                	if not self.node_player then return end
						local node1 = cc.CSLoader:createNode("Image_node_1.csb")
									 :addTo(self.node_player)
                        
                        table.insert(self.csw_node,node1)

					    local icon = gt.seekNodeByName(node1,"icon")
					    local image = gt.imageNamePath(url)
					    if image then 
					    	icon:loadTexture(image)
					    else
					    	
						    local call = function(args)
						    	local runningScene = display.getRunningScene()
		   						if runningScene and runningScene.name == "MainScene" then
						    		if args.done then
						    			icon:loadTexture(args.image)
						    		end
						    	end
					    	end
					    	gt.downloadImage(url,call)
					    end
						local str = value
						if sort == 1 or sort == 2 then
							str = str.."元"
						else
							str = str.."个"
						end
						gt.seekNodeByName(node1,"id"):setString("ID:"..id)
						gt.seekNodeByName(node1,"name"):setString(name)
						gt.seekNodeByName(node1,"addScore"):setString(str)
						-- if str == money then 
						-- 	gt.seekNodeByName(node1,"Text"):setString("话费")
						-- else
						-- 	gt.seekNodeByName(node1,"Text"):setString("金币")
						-- end
						-- 1217
						for i = 1, 3 do
							gt.seekNodeByName(node1,"tipsImage"..i):setVisible(false)
						end
						gt.seekNodeByName(node1,"tipsImage"..sort):setVisible(true)

						buf[i] = node1

						node1:setPositionY(100-107*(i-1))
						bufp[i] = node1:getPositionY()

	                end

	              
	                if #respJson.data.awards.list > 3 then 
	                	local tmp = bufp[1] + 107
	                	if self._gundong then 
	                		gt.scheduler:unscheduleScriptEntry(self._gundong)
	                		self._gundong = nil
	                	end
	                	self._gundong = gt.scheduler:scheduleScriptFunc(function()

							for i = 1 , #buf do
								
								buf[i]:setPositionY(buf[i]:getPositionY()+1)
								if buf[i]:getPositionY() == tmp then 
									buf[i]:setPositionY(bufp[#bufp])
								end
							end

							end,0,false)
	               	end

	            self.tasks = respJson.data.even_tasks

	            local tasks_num = #self.tasks.content 

	            gt.log("csw....",tasks_num)
	            if tasks_num > 1 then 

	            	local day = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."tasks_day", 0)
	            	if tonumber(os.date("%d")) ~= day then 
						cc.UserDefault:getInstance():setIntegerForKey(tostring(gt.playerData.uid).."tasks_day", tonumber(os.date("%d")))
						 -- 弹弹弹 ~  特殊牌型奖：0.5~50元随机红包加随机数额金币    财神普惠将：0.5~50元随机红包只要玩牌就有可能被财神选中哦！
        				 local Activity_node = require("client/game/activity/Activity_node"):create(self.tasks.list[i],self.tasks.content,self.tasks.title)
        				 self:addChild(Activity_node,31)

	            	end
	            else
	            	cc.UserDefault:getInstance():setIntegerForKey(tostring(gt.playerData.uid).."tasks_day", 0)
	            end


	            self.lucky = respJson.data.lucky_cards
	            local lucky_num = #self.lucky.list 
	            local lucky_n =  cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."locky_num", 0)
	           	local  buf = {}
	            for i = 1 , lucky_n do 
	            	buf[i] = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."locky_id"..i, 0)
	            end
	            gt.log("lucky_num",lucky_num)
	            gt.log("lucky_n",lucky_n)
	            for i = 1, lucky_num do
	            	local id = tonumber(self.lucky.list[i].task_id)
	            	local tmp = true
	            	for j = 1, #buf do
	            		if buf[j] == id then 
	            			tmp = false
	            			break
	            		end
	            	end
	            	 gt.log("tmp",tmp)
	            	if tmp then  -- 新id c存起来 弹框

	            		lucky_n = lucky_n + 1
	            		cc.UserDefault:getInstance():setIntegerForKey(tostring(gt.playerData.uid).."locky_num", lucky_n)
	            		cc.UserDefault:getInstance():setIntegerForKey(tostring(gt.playerData.uid).."locky_id"..lucky_n, id)
	            		local lucky_node = require("client/game/activity/lucky_node"):create(self.lucky.list[i],"M")
	            		self:addChild(lucky_node,31)
	            	end

	           	end
	           	if self:getChildByName("GiftCourtesy") then 
		       		self:getChildByName("GiftCourtesy"):removeFromParent()
		       		local GiftCourtesy = require("client/game/activity/GiftCourtesy"):create(self.tasks,self.lucky,self.isbend)
					self:addChild(GiftCourtesy, 8)
					GiftCourtesy:setName("GiftCourtesy")
		       	end

	            else
	                Toast.showToast(self, respJson.errmsg, 2)
	            end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()

end

function MainScene:r5_activity()

    -- if self.Activity11_9 then 
    --     self:Activity11_9()
    -- end

end

function MainScene:getAppVersion()
	if device.platform == "windows" or device.platform == "mac"  then
		return 11
	end

	if device.platform == "ios" then
		return 10
	end
	
	local luaBridge = nil
	local ok, appVersion = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		ok, appVersion = luaBridge.callStaticMethod("AppController", "getVersionName")
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		ok, appVersion = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")
	end

	local data = string.split(appVersion, ".")

	local versionNumber = 0

	if data[1] then
		versionNumber = versionNumber + tonumber(data[1])*10
	end

	if data[2] then
		versionNumber = versionNumber + tonumber(data[2])
	end

	return versionNumber
end

function MainScene:setLoginLog()
    -- 文件上传
	gt.log("------------------------登陆判断有文件就上传")
	if cc.FileUtils:getInstance():isFileExist(cc.FileUtils:getInstance():getWritablePath().."testlogin.txt") then
		local filePath = cc.FileUtils:getInstance():getWritablePath().."testlogin.txt"
		local fileName = (gt.playerData.uid or "").."testlogin.txt"

		if gt.isIOSPlatform() then
			self.luaBridge = require("cocos/cocos2d/luaoc")
		elseif gt.isAndroidPlatform() then
			self.luaBridge = require("cocos/cocos2d/luaj")
		end
		gt.log("------------------------uploadFile")
		if gt.isIOSPlatform() then
			-- local ok = self.luaBridge.callStaticMethod("AppController", "uploadFile", {url = gt.getUrlEncryCode(gt.uploadLog, gt.playerData.uid), filePath = filePath, fileName = fileName})
		elseif gt.isAndroidPlatform() then
			local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "uploadFile", {filePath, fileName}, "(Ljava/lang/String;Ljava/lang/String;)V")
		end
	end
end

--服务器返回gate登录
function MainScene:onRcvLoginGate( msgTbl )
	
	gt.dump( msgTbl )

	gt.socketClient:setPlayerKeyAndOrder(msgTbl.kStrKey, msgTbl.kUMsgOrder)

	local msgToSend = {}
	msgToSend.kMId = gt.CG_LOGIN_SERVER
	msgToSend.kSeed = gt.loginSeed
	msgToSend.kId = gt.m_id
	local catStr = tostring(gt.loginSeed)
	msgToSend.kMd5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	gt.socketClient:sendMessage(msgToSend)
end

-- 进入房间弹窗判断
function MainScene:onCallback(_type)
	if _type then
		gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
		local msgToSend = {}
		msgToSend.kMId = gt.CG_JOIN_ROOM
		msgToSend.kDeskId = roomID
		gt.socketClient:sendMessage(msgToSend)

		gt.dumploglogin("进入房间")
		gt.dumploglogin(msgToSend)
	else
		-- self.isRoomCreater = false
		-- self.createRoomSpr:setVisible(true)
		-- self.backRoomSpr:setVisible(false)
		-- local joinRoomLayer = require("app/views/JoinRoom"):create()
		-- self:addChild(joinRoomLayer, MainScene.ZOrder.JOIN_ROOM)	

		local a = require("client/game/majiang/JoinRoom")
		gt.log("reqire_____",a)
		local joinRoomLayer =a:create()
		joinRoomLayer:setName("JRPanel")
		self:addChild(joinRoomLayer, MainScene.ZOrder.JOIN_ROOM)	
	end
end

-- 断线重连,走一次登录流程
function MainScene:reLogin()
	local accessToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Access_Token" )
	local refreshToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token" )
	local openid 		= cc.UserDefault:getInstance():getStringForKey( "WX_OpenId" )

	local unionid 		= cc.UserDefault:getInstance():getStringForKey( "WX_Uuid" )
	local sex 			= cc.UserDefault:getInstance():getStringForKey( "WX_Sex" )
	local nickname 		= gt.wxNickName--cc.UserDefault:getInstance():getStringForKey( "WX_Nickname" )
	local headimgurl 	= cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl" )


	local call = function()
		local id = gt.get_id()
		if id ~= "" then 
			return tonumber(string.split(id, "|")[1])
		else
			return nil
		end
	end

	local kUserIdSys = call() or 0

	local msgToSend = {}
	msgToSend.kMId = gt.CG_LOGIN
	msgToSend.kPlate = "wechat"
	msgToSend.kAccessToken = accessToken
	msgToSend.kRefreshToken = refreshToken
	msgToSend.kOpenId = openid
	msgToSend.kSeverID = gt.serverId
	msgToSend.kUuid = unionid
	msgToSend.kSex = tonumber(sex)
	msgToSend.kNikename = nickname
	msgToSend.kImageUrl = headimgurl

	msgToSend.kUserId = self:getLastUserId()
	msgToSend.kUserIdSys = kUserIdSys
	msgToSend.kPhoneUUID = gt.get_uuid()
	msgToSend.kDevice = gt.get_devices()
	msgToSend.kAppVersion =  2 
	msgToSend.kOff = 0

	self.id1 = self:getLastUserId()
	self.id2 = kUserIdSys



	local catStr = string.format("%s%s%s%s", openid, accessToken, refreshToken, unionid)
	msgToSend.kMd5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	gt.socketClient:sendMessage(msgToSend)
end

function MainScene:onRcvLogin(msgTbl)
	gt.log("首条登录消息应答 =============== ")
	gt.dump(msgTbl)






	if gt.socketClient.savePlayCount then
		gt.socketClient:savePlayCount(msgTbl.kTotalPlayNum)
	end

	if msgTbl.kErrorCode == 5 then
		-- 去掉转圈
		gt.removeLoadingTips()
		require("client/game/dialog/NoticeTips"):create("提示",	"您在"..msgTbl.kErrorMsg.."中登录或已创建房间，需要退出或解散房间后再此登录。", nil, nil, true)
		return
	end

	if Update_idx == 1 then 
		if gt.init_wx then 
				
				-- if gt.getAppVersion() == 61 then
				-- 	gt.init_wx("wxed1b16d09a53460c")
				-- else
				-- 	gt.init_wx("wx36201a74410db977")
				-- end
				gt.init_wx("wxed1b16d09a53460c")
		else
			self:setUpdateVersion()
		end

	end
	-- 如果有进入此函数则说明token,refreshtoken,openid是有效的,可以记录.
	-- if self.needLoginWXState == 0 then
	-- 	-- 重新登录,因此需要全部保存一次
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token", self.m_accessToken )
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Refresh_Token", self.m_refreshToken )
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_OpenId", self.m_openid )

	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token_Time", os.time() )
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Refresh_Token_Time", os.time() )
	-- elseif self.needLoginWXState == 1 then
	-- 	-- 无需更改
	-- 	-- ...
	-- elseif self.needLoginWXState == 2 then
	-- 	-- 需更改accesstoken
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token", self.m_accessToken )
	-- 	cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token_Time", os.time() )
	-- end



	if Update_idx == 0 then 
		if self.setUserIdList then
			self:setUserIdList(msgTbl.kId)
		end
	end

	if Update_idx == 1 then 
		if self.removeUserIdLastLoginTime and self.id1 and tonumber(self.id1) > 0 then
			self:removeUserIdLastLoginTime(self.id1)
			self.id1 = 0
		end
		if tonumber(self.id2) ~= 0 then 
			self:remove_id(self.id2)
		end
	end



	gt.loginSeed = msgTbl.kSeed

	-- gt.GateServer.ip = msgTbl.m_gateIp
	-- gt.GateServer.ip = tostring(msgTbl.m_gateIp)
	-- 源代码
	-- gt.GateServer.ip = gt.curServerIp
	-- gt.GateServer.port = tostring(msgTbl.m_gatePort)
	-- 更改代码，测试服务端切换高防非高防ip
	gt.GateServer.ip = msgTbl.kGateIp
	gt.GateServer.port = tostring(msgTbl.kGatePort)

	gt.m_id = msgTbl.kId

	if msgTbl.kTotalPlayNum ~= nil then
		if self.savePlayCount then
			self:savePlayCount(msgTbl.kTotalPlayNum)
		end
	else
		gt.log("onRcvLogin playCount = nil")
	end

	-- gt.socketClient:close()

	gt.log("gt.GateServer ip = " .. gt.GateServer.ip .. ", port = " .. gt.GateServer.port)
	gt.socketClient:close()
	gt.log("关闭socket 222222")
	gt.log("MainScene, GameServer, 建立socket连接, serverIp = "..gt.LoginServer.ip..", serverPort = "..gt.LoginServer.port..", isBlock = true")
	gt.socketClient:connect(gt.GateServer.ip, gt.GateServer.port, true)
	local msgToSend = {}
	msgToSend.kMId = gt.CG_LOGIN_GATE
	msgToSend.kStrUserUUID = gt.socketClient:getPlayerUUID()
	gt.socketClient:sendMessage(msgToSend)
end

function MainScene:savePlayCount(count)
	local name = gt.name_s .. count .. gt.name_e
	cc.UserDefault:getInstance():setStringForKey("yoyo_name", name)
end

function MainScene:onNodeEvent(eventName)

	gt.log("eventName............",eventName)

	if "enter" == eventName then

		

		-- if gt.Update_idx == 0 then 

		 	self:setUpdateVersion()
		
		-- end

		if self.isNewPlayer then
			local function callback()
				--self:onUserExternInfo()
			end
			-- 显示新玩家奖励牌提示
			local str_des = string.format("第一次登录送房卡%d张",gt.playerData.roomCardsCount[2])
			if gt.isIOSPlatform() and gt.isInReview then
				str_des = gt.getLocationString("LTKey_0029_1")
			end
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),
				str_des, callback, nil, true)
		end
		-- 逻辑更新定时器
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
		if device.platform ~= "windows" then
			self.eventDispatcher = cc.Director:getInstance():getEventDispatcher()
			self.customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",
				handler(self, self.onEnterBackground))
			self.eventDispatcher:addEventListenerWithFixedPriority(self.customListenerBg, 1)
		
			self.customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
				handler(self, self.onEnterForeground))
			self.eventDispatcher:addEventListenerWithFixedPriority(self.customListenerFg, 1)
		end
		--是否有复制的房间号
		self:CopyRoomId()
		---****释放无用的资源****------
		-- cc.Director:getInstance():purgeCachedData()

		if gt.dynamicStartQuickRoom then
			require("client/game/dialog/NoticeTips"):create("提示", "由于您未及时入座，房主已经开始游戏。", nil, nil, true)
		end

		if gt.clubOnlineUserCount then
			if #gt.clubOnlineUserCount == 0 then
				if self.onlinePlayerCountImg then
					self.onlinePlayerCountImg:setVisible(false)
				end
			else
				local clubOnlineUserCount = 0
				for i = 1, #gt.clubOnlineUserCount do
					clubOnlineUserCount = clubOnlineUserCount + gt.clubOnlineUserCount[i][2] or 0
				end
				if self.onlinePlayerCountImg then
					self.onlinePlayerCountImg:setVisible(true)
				end
				if self.onlinePlayerCountLabel then
					self.onlinePlayerCountLabel:setString(clubOnlineUserCount.."人在线")
				end
			end
		end

		gt.log("---------------------gt.clubId", gt.clubId)
		-- gt.log("---------------------gt.playTypeId", gt.playTypeId)
		if gt.clubId and gt.clubId > 0 then
			gt.showLoadingTips(gt.getLocationString("LTKey_0053"))
			local runningScene = display.getRunningScene()
			if runningScene:getChildByName("ClubLayer") == nil then
				local ClubLayer = require("client/game/club/ClubLayer"):create(gt.clubId)
				ClubLayer:setName("ClubLayer")
				runningScene:addChild(ClubLayer, MainScene.ZOrder.CLUB)
			end
		end
		-- self:upgradeHasCoin()
	elseif "exit" == eventName then
		-- require("app/views/sport/SportManager").getInstance():removeAllPopup()
		if self._gundong then 
    		gt.scheduler:unscheduleScriptEntry(self._gundong)
    		self._gundong = nil
    	end
		if gt.isAppStoreInReview == false then
    		self.__stencil:release()
    		self._stencil:release()
			self._notifyText:stopAllActions()
    	end
    	self._notifyText:stopAllActions()
    	local eventDispatcher = self.rootNode:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self.rootNode)
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)


		if device.platform ~= "windows" then
			self.eventDispatcher:removeEventListener(self.customListenerFg)
			self.eventDispatcher:removeEventListener(self.customListenerBg)
		end

		
	end
end

function MainScene:onEnterBackground()
	gt.socketClient:close()
end

function MainScene:onEnterForeground()
	if self.getGPS then self:getGPS() end
	gt.socketClient:reloginServer()

end

function MainScene:checkMWAction()
	-- local actionMessage = Utils.getMWAction()
 -- 	if actionMessage ~= nil and actionMessage ~= "" then
 -- 		Utils.cleanMWAction()
 -- 		-- gt.log("actionMessage = " .. actionMessage)
	--  	require("cjson")
	--  	local paramTable = json.decode(actionMessage) --string.split("&")

	--  	if paramTable["action"] then
	--  		if paramTable["action"] == "enterroom" then
	--  			self:enterRoom(paramTable)
	--  		elseif paramTable["action"] == "replayhistory" then
	--  			self:replay(paramTable)
	--  		end
	--  	end
	-- end
end

function MainScene:enterRoom( _data )
	if not _data["code"] then
		return
	end

	gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
	--正在进入
	local sequence =  cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
		-- gt.removeLoadingTips()
		local codeStr = _data["code"]
		local codeNum = tonumber(codeStr)
		if codeNum then
			--绑定接收信息
			gt.socketClient:registerMsgListener(gt.GC_JOIN_ROOM, self, self.onRcvJoinRoom)

			self.mwCode = codeNum
			-- 发送进入房间消息
			local msgToSend = {}
			msgToSend.kMId = gt.CG_JOIN_ROOM
			msgToSend.kDeskId = codeNum
			gt.socketClient:sendMessage(msgToSend)

			gt.showLoadingTips(gt.getLocationString("LTKey_0006"))

			gt.dumploglogin("进入房间")
			gt.dumploglogin(msgToSend)
		else
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "房间号错误!", nil, nil, true)
		end
	end))

	self:runAction(sequence)	
end

function MainScene:onRcvJoinRoom(msgTbl)
	if msgTbl.kErrorCode ~= 0 then
		-- 进入房间失败
		gt.removeLoadingTips()
		if msgTbl.kErrorCode == 1 then
			-- 房间人已满
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0018"), nil, nil, true)
		else
			-- 房间不存在
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"),string.format("房间号%s不存在！", self.mwCode), nil, nil, true)
		end
	end
end

function MainScene:update()
	local curTime = os.time()
	if not self.m_lastCheckMWAction or curTime - self.m_lastCheckMWAction > 30 then
		self:checkFeeback()
		self.m_lastCheckMWAction = curTime
	end

	if not self.m_lastUp or curTime - self.m_lastUp > 1 then
		self:checkMWAction()
		self.m_lastUp = curTime
	end
end


function MainScene:checkFeeback()
	--gt.log("checkFeeback")
	-- 反馈条数
	-- local feebackNumber = 0
	-- if gt.isIOSPlatform() then
	-- 	local luaoc = require("cocos/cocos2d/luaoc")
	-- 	local ok, ret = luaoc.callStaticMethod("AppController", "actionUnreadCountFetch", {userId = ""})
	-- 	-- gt.log("IOS反馈数", ret)
	-- 	feebackNumber = ret
	-- elseif gt.isAndroidPlatform() then
	-- 	local luaoj = require("cocos/cocos2d/luaj")
	-- 	local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "actionUnreadCountFetch", {""}, "(Ljava/lang/String;)Ljava/lang/String;")
	-- 	-- gt.log("反馈数", tonumber(ret))
	-- 	feebackNumber = tonumber(ret)
	-- end			
	-- if feebackNumber > 0 then
	-- 	self.m_feedbackBg:setVisible(true)
	-- 	-- gt.log("反馈数的类型", type(feebackNumber))
	-- 	self.m_feedbackNum:setString(feebackNumber)
	-- else
	-- 	self.m_feedbackBg:setVisible(false)
	-- end
end

function MainScene:onRcvLoginServer(msgTbl)
	if msgTbl.kCard2 and msgTbl.kCard3 and msgTbl.kCard2 > 0 and msgTbl.kCard3 > 0 then
		gt.clubId = msgTbl.kCard2
		-- gt.playTypeId = msgTbl.kCard3 or 1
	end

	gt.clubOnlineUserCount = msgTbl.kClubOnlineUserCount or {}
	if #gt.clubOnlineUserCount == 0 then
		if self.onlinePlayerCountImg then
			self.onlinePlayerCountImg:setVisible(false)
		end
	else
		local clubOnlineUserCount = 0
		for i = 1, #gt.clubOnlineUserCount do
			clubOnlineUserCount = clubOnlineUserCount + gt.clubOnlineUserCount[i][2] or 0
		end
		if self.onlinePlayerCountImg then
		    self.onlinePlayerCountImg:setVisible(true)
		end
		if self.onlinePlayerCountLabel then
		    self.onlinePlayerCountLabel:setString(clubOnlineUserCount.."人在线")
		end
	end
	
	if gt.clubId and gt.clubId > 0 then
		gt.showLoadingTips(gt.getLocationString("LTKey_0053"))
		local runningScene = display.getRunningScene()
		if runningScene:getChildByName("ClubLayer") == nil then
			local ClubLayer = require("client/game/club/ClubLayer"):create(gt.clubId)
			ClubLayer:setName("ClubLayer")
			runningScene:addChild(ClubLayer, MainScene.ZOrder.CLUB)
		end
	end

	--登录服务器时间
	gt.loginServerTime = msgTbl.kServerTime or os.time()
	--登录本地时间
	gt.loginLocalTime = os.time()

    gt.connecting = false

	-- 设置开始游戏状态
	gt.socketClient:setIsStartGame(true)
	gt.socketClient:setIsCloseHeartBeat(false)

	-- 去除正在返回游戏提示
	gt.removeLoadingTips()
	
	--Toast.showToast(self, "重新连接服务器成功", 2)
	if self.removetop then
		self:removetop()
	end
	--gt.floatText("重新连接服务器成功")
	if self:getChildByName("JRPanel") ~= nil then
		gt.log("加入房间面板已打开")
		self:getChildByName("JRPanel"):sendAgain()
	else
		gt.log("加入房间面板不存在")
	end
end

-- start --
--------------------------------
-- @class function
-- @description 进入房间消息
-- @param msgTbl 消息体
-- end --
function MainScene:onRcvEnterRoom(msgTbl)
	if self.sportDialog then
		self.sportDialog:destroy()
		self.sportDialog = nil
	end
	
	gt.removeLoadingTips()
	gt.removeTargetEventListenerByType(self,"MainSceneAddText")
	gt.removeTargetEventListenerByType(self,"f5")
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_SERVER)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_SERVER)
	gt.socketClient:unregisterMsgListener(gt.GC_ENTER_ROOM)
	gt.socketClient:unregisterMsgListener(gt.GC_ROOM_CARD)
	-- gt.socketClient:unregisterMsgListener(gt.GC_MARQUEE)
	-- gt.socketClient:unregisterMsgListener(gt.GC_LOTTERY)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN)
	-- gt.socketClient:unregisterMsgListener(gt.GC_ADD_PLAYER)
	gt.socketClient:unregisterMsgListener(gt.CG_USER_EXTERN_INFO)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_GATE)
	gt.socketClient:unregisterMsgListener(gt.GC_TOAST)

	if self.updateToastSchedule then
		gt.scheduler:unscheduleScriptEntry(self.updateToastSchedule)
		self.updateToastSchedule = nil
	end	

	gt.removeTargetAllEventListener(self)


	local playScene = nil 
	gt.log("-----mainScene---msgTbl-----")
	gt.dump(msgTbl)
	if msgTbl.kState == 102 then                ----   炸金花  102，斗地主  101，牛牛    103，
		playScene = require("client/game/poker/zjhScene"):create(msgTbl)
	elseif msgTbl.kState == 103 then   
        playScene = require("client/game/poker/scene/nnScene"):create(msgTbl)
    elseif  msgTbl.kState == 101 then
    	playScene = require("client/game/poker/ddzScene"):create(msgTbl)
   	elseif   msgTbl.kState == 106 then
    	playScene = require("client/game/poker/sjScene"):create(msgTbl)
    elseif msgTbl.kState == 107 then
    	playScene = require("client/game/poker/PlayScenePK"):create(msgTbl)
    elseif msgTbl.kState == 109 then ------------3打1 sdy
    	playScene = require("client/game/poker/PlaySceneSdy"):create(msgTbl)
	elseif msgTbl.kState == 110 then
    	playScene = require("client/game/poker/PlaySceneWuRen"):create(msgTbl)
    end

    gt.log("replase__________",msgTbl.kState)
	cc.Director:getInstance():replaceScene(playScene)
end

function MainScene:onRcvRemovePlayer(msgTbl)
	if not gt.isCreateUserId and gt.playerData.uid == msgTbl.kUserId then
		if msgTbl.kDismissName and msgTbl.kDismissName ~= "" then
			local runningScene = cc.Director:getInstance():getRunningScene()
		 	Toast.showToast(runningScene, "房主"..msgTbl.kDismissName.."解散了房间！", 2)
		end
	end
end

function MainScene:refreshCardsCount(eventType, addMoney)
	gt.log("-----------------------addMoney", addMoney)
	-- 房卡信息
	local ttf_eight = gt.seekNodeByName(self.rootNode, "Txt_numbereight")
	gt.log("-----------------------gt.playerData.roomCardsCount[2]", gt.playerData.roomCardsCount[2])
	gt.money = gt.money + addMoney
	gt.log("-----------------------gt.money", gt.money)
	if ttf_eight then
		ttf_eight:setString(tostring(gt.money))
	end
end

function MainScene:onRcvToast(msgTbl)
	gt.log("-----------------------------------------------888111111111111")
	if self.total_count ~= nil then
	gt.log("-----------------------------------------------888222222222222")
		return
	end
	self.toastMsgTbl = msgTbl
	self.total_count = 1;
    self.updateToastSchedule = gt.scheduler:scheduleScriptFunc(handler(self, self.updateToast), 10, false)
end

function MainScene:updateToast(delta)
	gt.log("-----------------------------------------------8883333333333333333")
	if self.total_count >= 5 then
		self.total_count = nil
        gt.scheduler:unscheduleScriptEntry(self.updateToastSchedule)
        return
	end
	gt.log("-----------------------------------------------888444444444444444")
	self.total_count = self.total_count + 1
	Toast.showToast(self, self.toastMsgTbl.kMessageList[1], 2)
end

-- start --
--------------------------------
-- @class function
-- @description 接收房卡信息
-- @param msgTbl 消息体
-- end --
function MainScene:onRcvRoomCard(msgTbl)
	gt.log("-----roomCardsCount----2-----")

	if not self.rootNode  then return end
	local playerData = gt.playerData
	playerData.roomCardsCount = {msgTbl.kCard1, msgTbl.kCard2, msgTbl.kCard3, msgTbl.kDiamondNum or 0}
	-- 玩家信息
	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo")

	-- 房卡信息
	local ttf_eight = gt.seekNodeByName(playerInfoNode, "Txt_numbereight")
	ttf_eight:setString(playerData.roomCardsCount[2])
	if gt.isAppStoreInReview then
		local money = cc.UserDefault:getInstance():getIntegerForKey("money"..tostring(gt.playerData.uid), 0)
		if playerData.roomCardsCount[2] > money then
			money = playerData.roomCardsCount[2]
		end
		cc.UserDefault:getInstance():setIntegerForKey("money"..tostring(gt.playerData.uid), money)
		ttf_eight:setString(money)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 接收跑马灯消息
-- @param msgTbl 消息体
-- end --
function MainScene:onRcvMarquee(msgTbl)
	-- if gt.isIOSPlatform() and gt.isInReview then
	-- 	local str_des = gt.getLocationString("LTKey_0048")
	-- 	self.marqueeMsg:showMsg(str_des)
	-- else
	-- 	self.marqueeMsg:showMsg(msgTbl.m_str)
	-- 	gt.marqueeMsgTemp = msgTbl.m_str
	-- end
end

function MainScene:gmCheckHistoryEvt(eventType, uid)
	self:sendHistoryRecordMsg(uid)
end

-- -- 好友加入房间
-- function MainScene:onFriendJoinRoom(msgTbl)
-- 	if msgTbl.m_ready >= 3 then
-- 		-- 直接进入房间
-- 		self:onCallback(true)
-- 		return
-- 	end
-- 	local data = {name = msgTbl.m_nike, playerNum = msgTbl.m_ready + 1}
-- 	local joinRoomLayer = require("app/views/JoinRoomPopup"):create("playerJoin", data, function()
-- 		self:onCallback(true)
-- 	end)
-- 	self:addChild(joinRoomLayer, MainScene.ZOrder.JOIN_ROOM)
-- end

function MainScene:onShoppingCallback()
	-- 去个人中心
	local UserCenter = require("client/game/common/UserCenter"):create(true)
	self:addChild(UserCenter, MainScene.ZOrder.HISTORY_RECORD)	
end

-- 请求热更版本
function MainScene:requestVersion()
	local ver_filename  = "version.manifest"
    local remoteVersionUrl = nil
    self.curVersion = nil
    local cpath = cc.FileUtils:getInstance():isFileExist(ver_filename)
    if cpath then
        local fileData = cc.FileUtils:getInstance():getStringFromFile(ver_filename)
       
        local filelist = require("cjson").decode(fileData)
        if filelist then
            remoteVersionUrl = filelist.remoteVersionUrl
            self.curVersion = gt.resVersion
        end
    end
    if remoteVersionUrl == nil then
        -- remoteVersionUrl = "http://www.ixianlai.com/client/version.manifest"
        remoteVersionUrl = gt.upd_ver
    end
    
    if not self.xhr then
	    self.xhr = cc.XMLHttpRequest:new()
	    self.xhr:retain()
	    self.xhr.timeout = 30 -- 设置超时时间
    end
    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    self.xhr:open("GET", remoteVersionUrl.."?v="..tostring(os.time()))
    self.xhr:registerScriptHandler(handler(self,self.onResp))
    self.xhr:send()
end

function MainScene:onResp()
	if not self.xhr then
		return
	end
    if self.xhr.readyState == 4 and (self.xhr.status >= 200 and self.xhr.status < 207) then
        local data = json.decode(self.xhr.response)
        -- if data.version ~= self.curVersion then
        if Utils.checkUpdateVersion(data.version, self.curVersion) then
        	local function ok()
        		gt.socketClient:setIsStartGame(false)
				gt.socketClient:close()
				os.exit()
        		-- self:clearLoadedFiles()
        		-- local updateScene = require("client/game/common/UpdateScene"):create()
        		-- cc.Director:getInstance():replaceScene(updateScene)
        	end
        	require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "您的游戏版本过低，游戏将会关闭，请重新打开进行更新！", ok, nil, true)
        end
    elseif self.xhr.readyState == 1 and self.xhr.status == 0 then
        -- 网络问题,异常断开
        -- require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
    end
    self.xhr:unregisterScriptHandler()
end

function MainScene:clearLoadedFiles()
	for k, v in pairs(package.loaded) do
		if string.sub(k, 1, 7) == "client/" then
			package.loaded[k] = nil
		end 
	end
	gt.log("gt....................",gt.soundEngine,gt.socketClient)
	cc.SpriteFrameCache:getInstance():removeSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeAllTextures()
end

MainScene.isShowMoonFreeCard = false
function MainScene:showMoonFreeCard()
	local isOpenGuoQingActivity = Utils.isOpenGuoQingActivity()
	if not MainScene.isShowMoonFreeCard then
		MainScene.isShowMoonFreeCard = true
		if isOpenGuoQingActivity then
			local dialog = gt.createMaskLayer()
			self:addChild(dialog, 1000)

			local rootNode = ccui.Layout:create()
			rootNode:setPosition(gt.winCenter)
			dialog:addChild(rootNode)

			local moonBg = cc.Sprite:create("images/otherImages/moon_bg.png")
			rootNode:addChild(moonBg)

			local iknowBtn = ccui.Button:create("fangkaxiaobeijing.png","","",1)
			iknowBtn:setPosition(cc.p(585, 273))
			iknowBtn:setOpacity(0)
			iknowBtn:setScale9Enabled(true)
			iknowBtn:setCapInsets(cc.rect(10,10,10,10))
			iknowBtn:setContentSize(cc.size(80, 80))
			rootNode:addChild(iknowBtn)
			iknowBtn:addClickEventListener(function(sender)
				dialog:removeFromParentAndCleanup(true)
			end)
		end
	end
end

function MainScene:onUserExternInfo(msgTbl)
	if msgTbl then
		self.bindPhoneCode = msgTbl.m_bindPhoneCode
		if self.isNewPlayer then
			return
		else

		end
	else

	end
	-- gt.log("弹出绑定框", self.bindPhoneCode)
	if self.bindPhoneCode == 0 then
		local function bindingOkCallback()
			gt.bindingPhone = "TaskLayer"
		end

		local function bindingCallback()
			-- 弹出绑定成功
			local setPhoneDialog = require("app/views/SetPhoneDialog"):create("bindingSuccessNode", bindingOkCallback)
			self:addChild(setPhoneDialog, MainScene.ZOrder.TASK_INVITE)		
		end	

		local setPhoneDialog = require("app/views/SetPhoneDialog"):create("userTipsNode", bindingCallback)
		self:addChild(setPhoneDialog, MainScene.ZOrder.TASK_INVITE)

		gt.bindingPhone = "isSetPhone"
	else

	end
end

function MainScene:onConfirmID()
	local show = cc.UserDefault:getInstance():getIntegerForKey("id_sure", 0)
    self.confirmBtn:setVisible(show ~= 1)
end


-- 解析粘贴板内容弹框提示  --2017-2-23 syz add
function MainScene:CopyRoomId()
	gt.log("function is MainScene:CopyRoomId")
	-- if self.roomID == nil then return end
	-- local copyTxt = gt.getCopyStr()
	-- gt.log("获取粘贴板文本："..gt.getCopyStr())
	-- if copyTxt == nil or copyTxt == "" then
	-- 	return
	-- end

	-- gt.log("是否有好运来字样:"..tostring(string.find(copyTxt, "好运来山西麻将")))

	local RoomID = ""
	-- if string.len(copyTxt) == 6 and type(tonumber(copyTxt)) =="number" then
	-- 	RoomID = copyTxt
	-- elseif string.len(copyTxt) > 6 then
	-- 	--判断粘贴板是否含有好运来山西麻将字样，取[]字符中的数字
	-- 	if string.find(copyTxt, "好运来山西麻将") and string.find(copyTxt,"%[") and string.find(copyTxt,"]") then
	-- 		local a = string.find(copyTxt,"%[")+1
	-- 		local b = string.find(copyTxt,"]")-1
	-- 		RoomID = string.sub(copyTxt,a,b)
	-- 	end	
	-- end

	gt.log("房间号是："..RoomID)
	
	if string.len(RoomID) == 6 and type(tonumber(RoomID)) == "number" then
		gt.log("RoomID = "..RoomID)
		local JoinRoomTipText = string.format("您确定要进入房间 %d 吗？", RoomID)
		require("client/game/dialog/NoticeTips"):create("提示", JoinRoomTipText, 
			function ()
				-- 发送进入房间消息
				local msgToSend = {}
				msgToSend.kMId = gt.CG_JOIN_ROOM
				msgToSend.kDeskId = tonumber(RoomID)
				gt.socketClient:sendMessage(msgToSend)
				gt.dump(msgToSend)
				
				gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
				gt.CopyText(" ")

				gt.dumploglogin("进入房间")
				gt.dumploglogin(msgToSend)
			end,
			function ()
				gt.CopyText(" ")
			end, false)
		gt.log("RoomID"..RoomID)
		self.RoomID = tonumber(RoomID)
	end
end


--统一发送战绩列表请求
function MainScene:sendHistoryRecordMsg(uid)
	gt.socketClient:registerMsgListener(gt.GC_HISTORY_RECORD, self, self.onRcvHistoryRecord)
	local msgToSend = {}
	msgToSend.kMId = gt.CG_HISTORY_RECORD
	msgToSend.kTime = 123456
	if gt.isGM == 1 then
		msgToSend.kUserId = tonumber(uid or 1)
	end
	gt.socketClient:sendMessage(msgToSend)
end

function MainScene:onRcvHistoryRecord(msgTbl)
	gt.removeLoadingTips()
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_POKER_ROOM_LOG)
	gt.socketClient:unregisterMsgListener(gt.GC_HISTORY_RECORD)
	-- if #msgTbl.m_data == 0 then
	-- 	require("client/game/dialog/NoticeTips"):create("提示", "暂无战绩，请邀请小伙伴一起玩吧：)", nil, nil, true)
	-- else
		local historyRecord = require("client/game/majiang/HistoryRecord"):create(msgTbl,self.zj_type)
		self:addChild(historyRecord, MainScene.ZOrder.HISTORY_RECORD)
	-- end
end

function MainScene:sendFZRecordMsg()
	local FZRecord = require("client/game/majiang/FZRecord"):create()
	FZRecord:setName("FZRecord")
	self:addChild(FZRecord, MainScene.ZOrder.FZ_RECORD)
end

function MainScene:setIp()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local IpURL = gt.getUrlEncryCode(gt.setIp, gt.playerData.uid)
	gt.log("----------IpURL", IpURL)
	xhr:open("GET", IpURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			gt.dump(xhr.response)
			
			local ret = require("cjson").decode(xhr.response)
			gt.playerData.ip = ret.data.ip
		elseif xhr.readyState == 1 and xhr.status == 0 then
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end


function MainScene:setpubliset1()

	self:HttpSub(false)
	self:setGiftCourtesy()
	self._notify = gt.seekNodeByName(self.rootNode,"sp_trumpet_bg")

	self.__stencil  = display.newSprite()
					  :setAnchorPoint(cc.p(0,0.5))
	self.__stencil:retain()
	self.__stencil:setTextureRect(cc.rect(0,0,825,55))
	self._notifyClip = cc.ClippingNode:create(self.__stencil)
		:setAnchorPoint(cc.p(0,0.5))
	self._notifyClip:setInverted(false)
	self._notifyClip:move(82,27)
	self._notifyClip:addTo(self._notify)

	self._notifyText = cc.Label:createWithTTF("", "fonts/DFYuanW7-GB2312.ttf", 24)
								:addTo(self._notifyClip)
								:setTextColor(cc.c4b(255,255,255,255))
								:setAnchorPoint(cc.p(0,0.5))
								:enableOutline(cc.c4b(79,48,35,255), 1)

end


function MainScene:test_http()



	local url = gt.getUrlEncryCode(gt.setPublish, gt.playerData.uid)
	local call = function(res,status,data)

		if res and status == 200 then 
			local respJson = require("cjson").decode(data)
			gt.dump(respJson)
		end

	end
	-- 1 = GET 2 = POST
	cc.UtilityExtension:Q_http(url,call,1)

end


--跑马灯更新
function MainScene:onChangeNotify(msg)
	
	if not type(msg) then return end
	self._notifyText:stopAllActions()
	if msg == nil or msg == "" then
		self._notifyText:setString("")
		return
	end
	local msgcolor = cc.c4b(255,255,255,255)
	self._notifyText:setString(msg)
	
	local tmpWidth = self._notifyText:getContentSize().width
	self._notifyText:runAction(
			cc.Sequence:create(
				cc.CallFunc:create(	function()
					self._notifyText:setAnchorPoint(cc.p(0,0.5))
					self._notifyText:move(400,0)
					self._notifyText:setVisible(true)
				end),
				cc.MoveTo:create(16 + (tmpWidth / 172),cc.p(0-tmpWidth,0)),
				cc.CallFunc:create(	function()
					self._notifyText:setPosition(cc.p(0, 0))
					self._notifyText:move(400,0)
					self._notifyText:setString(msg)
					if self.onChangeNotify then 
						self:onChangeNotify(msg)	
					end		
				end)
			)
	)
end

function MainScene:HttpSub(kefu)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local PublishURL = gt.getUrlEncryCode(gt.setPublish, gt.playerData.uid)
	gt.log("------------PublishURL", PublishURL)
	xhr:open("GET", PublishURL)
	local function onResp()
		local runningScene = display.getRunningScene()
	   	if runningScene and runningScene.name == "MainScene" then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) and self then
	            local response = xhr.response
	            local respJson = require("cjson").decode(response)
	           gt.dump(respJson)
	            if respJson.errno == 0 then
	            	gt.publishData = respJson.data
	            	self.kefu_text = respJson.data.customer
	            	if not kefu then
		                local notice1 = respJson.data.notice -- 有/n
		                local notice = respJson.data.tips -- 没/n
		                self.has_task =  respJson.data.has_task
		                gt.isbind =  respJson.data.is_bind
		                if self.shareGiftBtn then
							if gt.isbind then
								self.shareGiftBtn:setVisible(false)
							else
								self.shareGiftBtn:setVisible(true)
							end
						end
		                self.bindcoin =  respJson.data.bind_coin
						self:onChangeNotify(notice)
						self.notice = notice1
						local oldnotice = cc.UserDefault:getInstance():getStringForKey("notice"..tostring(gt.playerData.uid), "")
						if notice1 ~= oldnotice then
							cc.UserDefault:getInstance():setStringForKey("notice"..tostring(gt.playerData.uid), notice1)
							if respJson.data.is_tan and device.platform ~= "mac" and device.platform ~= "windows" then
								if respJson.data.web_url and respJson.data.web_url ~= "" then
									self._PublicNoiceWebViewNode = cc.CSLoader:createNode("PublicNoiceWebView.csb")
									self:addChild(self._PublicNoiceWebViewNode, 999)
									self._PublicNoiceWebViewNode:setPosition(gt.winCenter)

									local closeBtn = gt.seekNodeByName(self._PublicNoiceWebViewNode, "Btn_close")
									gt.addBtnPressedListener(closeBtn, function()
										self._PublicNoiceWebView:removeFromParent()
										self._PublicNoiceWebViewNode:removeFromParent()
									end)

									self._PublicNoiceWebView = ccexp.WebView:create()
									self._PublicNoiceWebView:setPosition(gt.seekNodeByName(self._PublicNoiceWebViewNode , "PanelWebView"):getPosition())
									self._PublicNoiceWebView:setContentSize(1140, 619)

									self._PublicNoiceWebView:loadURL(respJson.data.web_url)
									self._PublicNoiceWebView:setScalesPageToFit(true)

									self._PublicNoiceWebView:setOnShouldStartLoading(function(sender, url)
										return true
									end)
									self._PublicNoiceWebView:setOnDidFinishLoading(function(sender, url)
									end)
									self._PublicNoiceWebView:setOnDidFailLoading(function(sender, url)
									end)
									self._PublicNoiceWebViewNode:addChild(self._PublicNoiceWebView)
								end
							else
							  	local layer = require("client/game/common/PublicNoice"):create(notice1)
							  	self:addChild(layer, 999)
							end
						end
					else
						self:removeChildByName("_KEFU_")
						local node = require("client/game/common/kefu"):create(self.kefu_text)						
						node:setName("_KEFU_")
						self:addChild(node,20)
					end
	            else
	                Toast.showToast(self, respJson.errmsg, 2)
	            end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end


function MainScene:setGiftCourtesy()
	local NodeGiftCourtesy = gt.seekNodeByName(self.rootNode, "Sprite_4")
	local NodePlay = gt.seekNodeByName(self.rootNode, "NodePlay")

	local  noticeBg = gt.seekNodeByName(self.rootNode, "sp_trumpet_bg")

	-- local dian = gt.seekNodeByName(self.rootNode, "Sprite_6")
	-- dian:runAction(cc.RepeatForever:create(cc.Blink:create(1, 1)))

	 --    local action1 = cc.RotateTo:create(1, -30)
	 --    local action2 = cc.RotateTo:create(1, 30)
		-- local seqAction = cc.Sequence:create(action1, action2)
		-- NodePlay:runAction(cc.RepeatForever:create(seqAction))


		-- local SpriteGiftCourtesy = gt.seekNodeByName(self.rootNode, "Sprite_2")

		-- local fadeOut = cc.FadeOut:create(1)
		-- local fadeIn = cc.FadeIn:create(1)
		-- local seqAction = cc.Sequence:create(fadeOut, fadeIn)
		-- SpriteGiftCourtesy:runAction(cc.RepeatForever:create(seqAction))

	local function onTouchEnded(touch, event)

		local noticeRect = cc.rect(0,0,noticeBg:getContentSize().width,noticeBg:getContentSize().height)
		local touchPoint = NodeGiftCourtesy:convertTouchToNodeSpace(touch)
			-- local NodeGiftCourtesySize = NodeGiftCourtesy:getContentSize()
			-- local NodeGiftCourtesyRect = cc.rect(0, 0, NodeGiftCourtesySize.width, NodeGiftCourtesySize.height)
			-- if cc.rectContainsPoint(NodeGiftCourtesyRect, touchPoint) then
			-- 	local node = self:getChildByName("GiftCourtesy") 
			-- 	if node then 
			-- 		node:removeFromParent()
			-- 	end
			-- 	local GiftCourtesy = require("client/game/activity/GiftCourtesy"):create(self.tasks,self.lucky,self.isbend)
			-- 	self:addChild(GiftCourtesy, 8)
			-- 	GiftCourtesy:setName("GiftCourtesy")
			-- end
			if cc.rectContainsPoint(noticeRect,noticeBg:convertTouchToNodeSpace(touch)) then
				if gt.publishData and gt.publishData.is_tan then
					if gt.publishData.web_url and gt.publishData.web_url ~= "" and device.platform ~= "mac" and device.platform ~= "windows" then
						self._PublicNoiceWebViewNode = cc.CSLoader:createNode("PublicNoiceWebView.csb")
						self:addChild(self._PublicNoiceWebViewNode, 999)
						self._PublicNoiceWebViewNode:setPosition(gt.winCenter)

						local closeBtn = gt.seekNodeByName(self._PublicNoiceWebViewNode, "Btn_close")
						gt.addBtnPressedListener(closeBtn, function()
							self._PublicNoiceWebView:removeFromParent()
							self._PublicNoiceWebViewNode:removeFromParent()
						end)

						self._PublicNoiceWebView = ccexp.WebView:create()
						self._PublicNoiceWebView:setPosition(gt.seekNodeByName(self._PublicNoiceWebViewNode , "PanelWebView"):getPosition())
						self._PublicNoiceWebView:setContentSize(1140, 619)

						self._PublicNoiceWebView:loadURL(gt.publishData.web_url)
						self._PublicNoiceWebView:setScalesPageToFit(true)

						self._PublicNoiceWebView:setOnShouldStartLoading(function(sender, url)
							return true
						end)
						self._PublicNoiceWebView:setOnDidFinishLoading(function(sender, url)
						end)
						self._PublicNoiceWebView:setOnDidFailLoading(function(sender, url)
						end)
						self._PublicNoiceWebViewNode:addChild(self._PublicNoiceWebView)
					end
				else
					if self.notice and self.notice ~= "" then 
						local layer = require("client/game/common/PublicNoice"):create(self.notice)
						self:addChild(layer, 999)
					end
				end
			end

--
			--local loction = touch:getLocation()

			-- if loction.y > 220 and loction.y < 550 then 
			-- 	for i = 1, #self.csw_node do 
					
			-- 		local kuang = self.csw_node[i]:getChildByName("bg")
			-- 		if not kuang then return end
			-- 		local kRect = cc.rect(0,0,kuang:getContentSize().width,kuang:getContentSize().height)
			-- 		if cc.rectContainsPoint(kRect,kuang:convertTouchToNodeSpace(touch)) then

						
			-- 			self._webViewNode = cc.CSLoader:createNode("webView.csb")
			-- 			self:addChild(self._webViewNode,31)
			-- 			self._webViewNode:setPosition(gt.winCenter)
					

			-- 			local backBtn = gt.seekNodeByName(self._webViewNode, "Button_1")
			-- 			gt.addBtnPressedListener(backBtn, function()
			-- 				self._webView:removeFromParent()
			-- 				self._webViewNode:removeFromParent()
			-- 			end)

						
			-- 			self._webView = ccexp.WebView:create()

			-- 		    self._webView:setPosition(gt.seekNodeByName(self._webViewNode , "Panel_2"):getPosition())
			-- 		    self._webView:setContentSize(970,  580)
					 
			-- 		    self._webView:loadURL(gt.HTTP_WEB_VIEW)
			-- 		    self._webView:setScalesPageToFit(true)

			-- 		    self._webView:setOnShouldStartLoading(function(sender, url)
			-- 		        return true
			-- 		    end)
			-- 		    self._webView:setOnDidFinishLoading(function(sender, url)
			-- 		    end)
			-- 		    self._webView:setOnDidFailLoading(function(sender, url)
			-- 		    end)
			-- 		    self._webViewNode:addChild(self._webView)	

					
			-- 		end
			-- 	end
			-- end

		return false
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_BEGAN)
	local eventDispatcher = self.rootNode:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.rootNode)
end

--获取加入文娱馆列表
function MainScene:get_kefu()

	if self.kefu_text then 
		self:removeChildByName("_KEFU_")
		local node = require("client/game/common/kefu"):create(self.kefu_text)
		node:setName("_KEFU_")
		self:addChild(node,20)
	else
		self:HttpSub(true)
	end
end

--获取加入文娱馆列表
function MainScene:getClubs()
 	gt.showLoadingTips("读取数据中")
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local getClubsURL = gt.getUrlEncryCode(string.format(gt.getClubs, 1), gt.playerData.uid)
	print("------------getClubsURL", getClubsURL)
	gt.dumploglogin("------------getClubsURL"..getClubsURL)
	xhr:open("GET", getClubsURL)
	local function onResp()
		gt.removeLoadingTips()
		if self then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				gt.dump(xhr.response)
		 		local cjson = require "cjson"
				local ret = cjson.decode(xhr.response)
				if ret.errno == 0 then
					gt.dumploglogin("------------getClubsURLSUCCESS")
					local clubType = 1
					if ret.data.clubs and #ret.data.clubs == 0 then
						clubType = 1
						local runningScene = cc.Director:getInstance():getRunningScene()
						local joinClubLayer = require("client/game/club/JoinClub"):create(clubType)
						joinClubLayer:setName("JoinClub")
						runningScene:addChild(joinClubLayer, MainScene.ZOrder.CREATE_ROOM)
					elseif ret.data.clubs and #ret.data.clubs > 1 then
						clubType = 2
						local runningScene = cc.Director:getInstance():getRunningScene()
						local joinClubLayer = require("client/game/club/JoinClub"):create(clubType, ret.data.clubs)
						joinClubLayer:setName("JoinClub")
						runningScene:addChild(joinClubLayer, MainScene.ZOrder.CREATE_ROOM)
					elseif ret.data.clubs and #ret.data.clubs == 1 then
						gt.showLoadingTips(gt.getLocationString("LTKey_0053"))
						local runningScene = display.getRunningScene()
						if runningScene:getChildByName("ClubLayer") == nil then
							local ClubLayer = require("client/game/club/ClubLayer"):create(ret.data.clubs[1].club_no, true)
							ClubLayer:setName("ClubLayer")
							runningScene:addChild(ClubLayer, MainScene.ZOrder.CLUB)
						end
					end
				else
					require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), ret.errmsg, nil, nil, true)
				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function MainScene:refreshMoney()
	gt.log("refreshMoney___________________")
	if not self.xhr then
	    self.xhr = cc.XMLHttpRequest:new()
	    self.xhr:retain()
	    self.xhr.timeout = 30 -- 设置超时时间
    end

    local function onRespCardNum()
    	if self then
			if not self.xhr then
				return
			end
		    if self.xhr.readyState == 4 and (self.xhr.status >= 200 and self.xhr.status < 207) then
		        local ret = json.decode(self.xhr.response)
		        gt.dump(ret)
		        if ret.errno == 0 then
					gt.log("refreshMoney___________________s")
					gt.dump(gt.playerData.roomCardsCount)
		        	gt.playerData.roomCardsCount[2] = ret.data.coin
					local ttf_eight = gt.seekNodeByName(self.rootNode, "Txt_numbereight")
					gt.money = ret.data.coin
					ttf_eight:setString(tostring(gt.money))
					gt.seekNodeByName(gt.seekNodeByName(self.rootNode, "cardNum"), "Text"):setString(ret.data.diamond or 0)
		        end
		    elseif self.xhr.readyState == 1 and self.xhr.status == 0 then
		        -- 网络问题,异常断开
		        -- require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
		    end
		    self.xhr:unregisterScriptHandler()
		end
	end

    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local refreshGoldUrl = gt.getUrlEncryCode(gt.refreshgold, gt.playerData.uid)
	gt.log("-----------refreshGoldUrl----")
	gt.log(refreshGoldUrl)
    self.xhr:open("GET", refreshGoldUrl)
    self.xhr:registerScriptHandler(onRespCardNum)
    self.xhr:send()
end

--获取送金币是否显示
function MainScene:getShareShow()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local getShareShow = gt.getUrlEncryCode(gt.shareShow, gt.playerData.uid)
	print("------------getShareShow", getShareShow)
	xhr:open("GET", getShareShow)
	local function onResp()
		if self then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				gt.dump(xhr.response)
		 		local cjson = require "cjson"
				local ret = cjson.decode(xhr.response)
				if ret.errno == 0 then
					if ret.data.has_share then
						self.shareGiftBtn:setVisible(true)
					else
						self.shareGiftBtn:setVisible(false)
					end
				else
					require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), ret.errmsg, nil, nil, true)
				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function MainScene:setShareGiftBtn()
	if self.shareGiftBtn then
		self.shareGiftBtn:setVisible(false)
	end
end

function MainScene:receiveShareCoin()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = gt.getUrlEncryCode(gt.shareCoin, gt.playerData.uid)
    gt.log("-------------url", url)
    xhr:open("GET", url)
    local function onResp()
        local runningScene = display.getRunningScene()
        if runningScene and runningScene.name == "MainScene" then
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                local response = xhr.response
                local respJson = require("cjson").decode(response)
                gt.dump(respJson)
                if respJson.errno == 0 then
                	if respJson.data.value > 0 then
						self:refreshMoney()
						local ShareCoin = require("client/game/activity/ShareCoin"):create(respJson.data.desc)
	  					self:addChild(ShareCoin)
	  				end
                else
                    Toast.showToast(self, respJson.errmsg, 2)
                end
            end
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onResp)
    xhr:send()
end

function MainScene:receiveTaskCoin(user_id, task_id)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = gt.getUrlEncryCode(string.format(gt.taskCoin, user_id, task_id), gt.playerData.uid)
    gt.log("-------------url", url)
    xhr:open("GET", url)
    local function onResp()
        local runningScene = display.getRunningScene()
        if runningScene and runningScene.name == "MainScene" then
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                local response = xhr.response
                local respJson = require("cjson").decode(response)
                gt.dump(respJson)
                if respJson.errno == 0 then
					self:refreshMoney()
  					if self.ShareGift then
  						self.ShareGift:removeFromParent()
  						self.ShareGift = nil
  					end
					self.ShareGift = require("client/game/activity/ShareGift"):create()
					self:addChild(self.ShareGift)
					self.ShareGift:setName("ShareGift")
					local ShareCoin = require("client/game/activity/ShareCoin"):create(respJson.data.desc)
  					self:addChild(ShareCoin)
                else
                    Toast.showToast(self, respJson.errmsg, 2)
                end
            end
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onResp)
    xhr:send()
end

function MainScene:setUpdateVersion()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local UpdateVersionURL = gt.getUrlEncryCode(gt.updateVersion,
	(cc.UserDefault:getInstance():getIntegerForKey("User_Id", 0) == 0 
	and "" or tostring(cc.UserDefault:getInstance():getIntegerForKey("User_Id", 0))))
	gt.log("---------UpdateVersionURL", UpdateVersionURL)

	xhr:open("GET", UpdateVersionURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local response = xhr.response
            local respJson = require("cjson").decode(response)
            gt.dump(respJson)
            if respJson.errno == 0 then
				local function callback( )
					if _callback then
						_callback()
					end
				end
                local app_version = respJson.data.app_version
				if app_version.is_upgrade == 1 then
					local data = {}
               		data.newest_download_url = app_version.newest_download_url
					data.force_upgrade = app_version.force_upgrade
					data.upgrade_hints = app_version.upgrade_hints
   					require("client/game/dialog/NoticeUpdateTips"):create(data, callback)
   				else
   					callback()
				end
            else
                Toast.showToast(self, respJson.errmsg, 2)
            end
		elseif xhr.readyState == 1 and xhr.status == 0 then
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end
function MainScene:upgradeHasCoin()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local upgradeHasCoinURL = gt.getUrlEncryCode(gt.upgradeHasCoin, gt.playerData.uid)
	gt.log("------------upgradeHasCoinURL", upgradeHasCoinURL)
	xhr:open("GET", upgradeHasCoinURL)
	local function onResp()
		local runningScene = display.getRunningScene()
	   	if runningScene and runningScene.name == "MainScene" then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	            local response = xhr.response
	            local respJson = require("cjson").decode(response)
	            gt.dump(respJson)
                if respJson.errno == 0 then
					self.NoticeTipsGetCoin = require("client/game/dialog/NoticeTipsGetCoin"):create(respJson.data.desc, function ( )
						self:upgradeGetCoin()
					end)
  					self:addChild(self.NoticeTipsGetCoin)
                end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
			xhr:unregisterScriptHandler()
		end
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function MainScene:upgradeGetCoin()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local upgradeGetCoinURL = gt.getUrlEncryCode(gt.upgradeGetCoin, gt.playerData.uid)
	gt.log("------------upgradeGetCoinURL", upgradeGetCoinURL)
	xhr:open("GET", upgradeGetCoinURL)
	local function onResp()
		local runningScene = display.getRunningScene()
	   	if runningScene and runningScene.name == "MainScene" then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	            local response = xhr.response
	            local respJson = require("cjson").decode(response)
	            gt.dump(respJson)
                if respJson.errno == 0 then
					self:refreshMoney()
					if self.NoticeTipsGetCoin then
						self.NoticeTipsGetCoin:removeFromParent()
						self.NoticeTipsGetCoin = nil
					end
					local ShareCoin = require("client/game/activity/ShareCoin"):create(respJson.data.desc)
  					self:addChild(ShareCoin)
                else
                    Toast.showToast(self, respJson.errmsg, 2)
                end
			elseif xhr.readyState == 1 and xhr.status == 0 then
			end
			xhr:unregisterScriptHandler()
		end
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function MainScene:getAppVersionShow()
	local luaBridge = nil
	local ok, appVersion = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		ok, appVersion = luaBridge.callStaticMethod("AppController", "getVersionName")
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		ok, appVersion = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")
	end

	return appVersion
end

function MainScene:appStoreRefreshMoney()
	gt.log("-----------appStoreRefreshMoney")
	local ttf_eight = gt.seekNodeByName(self.rootNode, "Txt_numbereight")
	local money = cc.UserDefault:getInstance():getIntegerForKey("money"..tostring(gt.playerData.uid), 0)
	gt.log("-----------money", money)
	ttf_eight:setString(tostring(money))
end

function MainScene:setUpdateVersion(_callback)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local UpdateVersionURL = gt.getUrlEncryCode(gt.updateVersion,gt.playerData.uid)
	gt.log("------------UpdateVersionURL", UpdateVersionURL)

	xhr:open("GET", UpdateVersionURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			-- print("------------xhr.response", xhr.response)
            local response = xhr.response
			-- print("------------response", response)
            local respJson = require("cjson").decode(response)
            gt.dump(respJson)
			-- print("------------respJson.errno", respJson.errno)
            if respJson.errno == 0 then
				local function callback( )
					if _callback then 
						_callback()
					end
				end
                local app_version = respJson.data.app_version
				if app_version.is_upgrade == 1 then
					local data = {}
               		data.newest_download_url = app_version.newest_download_url
					data.force_upgrade = app_version.force_upgrade
					data.upgrade_hints = app_version.upgrade_hints
   					require("client/game/dialog/NoticeUpdateTips"):create(data, callback)
   					--require("client/game/dialog/NoticeUpdateTipsClub"):create(data, callback)

   					--local url = data.newest_download_url
   					
   					--local node  = require("client/game/dialog/UpdateApk"):create(url)
					--self:addChild(node, gt.CommonZOrder.NOTICE_TIPS+1000)

   				else
   					--callback()
				end
            else
                Toast.showToast(self, respJson.errmsg, 2)
            end
		elseif xhr.readyState == 1 and xhr.status == 0 then
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end


function MainScene:setUserIdList(userId)
	local data = cc.UserDefault:getInstance():getStringForKey("UserIdList", require("cjson").encode({}))
	local dataList = json.decode(data)

	for i = 1, table.nums(dataList) do
		if tonumber(dataList[i]) == tonumber(userId) then
			table.remove(dataList, i)
			break
		end
	end

	table.insert(dataList, 1, userId)

	cc.UserDefault:getInstance():setStringForKey("UserIdList", require("cjson").encode(dataList))

	if tonumber(string.split(gt.get_id(), "|")[1]) ~= tonumber(userId) then 
		userId = userId .."|"..gt.get_id()
		gt.set_id(userId)
	end

end

function MainScene:remove_id(uid)

	local id = gt.get_id()


	local str = ""
	if id ~= "" then 
		for i = 1 , #string.split(id, "|") do
			if tonumber(string.split(id, "|")[i]) ~= tonumber(uid) then 
				str = str .. string.split(id, "|")[i] .."|"
			end
		end
		gt.set_id(str)
	end

end

function MainScene:getLastUserId()
	local data = cc.UserDefault:getInstance():getStringForKey("UserIdList", require("cjson").encode({}))
	local dataList = json.decode(data)

	return dataList[1] or 0
end

function MainScene:removeUserIdLastLoginTime(userId)
	local data = cc.UserDefault:getInstance():getStringForKey("UserIdList", require("cjson").encode({}))
	local dataList = json.decode(data)

	for i = 1, table.nums(dataList) do
		if tonumber(dataList[i]) == tonumber(userId) then
			table.remove(dataList, i)
			break
		end
	end

	cc.UserDefault:getInstance():setStringForKey("UserIdList", require("cjson").encode(dataList))
end



return MainScene


