

-- Author csw
-- DATE  2017-12-6


package.loaded["client/message/MessageInit"] = nil
require("client/message/MessageInit")

-- https://fir.im/szpandroid --测试包
--http://apk.haoyunlaiyule2.com/laoA.apk
--[[
	
//public static final String APP_ID = "wx36201a74410db977";  -- 新
    public static final String APP_ID = "wx967c70b95c2bbfce"; -- 老

acc:judian_tec@outlook.com
pwd:Flat,Start123
账号：  769529509@qq.com  密码：  Zzb1314520
	
--Thank you. We have uploaded a new screenshot.（谢谢您.我们已经上传了一个新的截图。）
--Free version of the game, Later we will submit a new version to Apple App Store(游戏版本免费,之后我们会向苹果App Store提交新的版本).
--We connected to an IPv6 network app can run normally（我们连接到一个IPv6网络APP可以正常运行）
--Please uninstall the old version, then install this version, or install this version on the new iphone. Please forgive us for the inconvenience（请卸载旧版本，然后安装此版本，或在新手机上安装此版本。对您带来不便请谅解）
---APP startup and login background map is the same, please wait for app to start, app will automatically log on，Please forgive us for the inconvenience.(APP启动与登录背景图是一样的，请等待APP启动，App会自动登录，对您带来不便请谅解).
--chaoh@illuminargroup.com
--1242 2208     2048-2732
BB8C0244-64E7-47E8-BF09-9FF6AD7BB31C
-- http://chy.zjhsaler.haoyunlaiyule1.com/index.html

dev@uzhu.com.cn
uzhu@fir2015

]]


local baseGame = class("baseGame",function()
	return display.newScene("pokerScene") 
end)

local gt = cc.exports.gt

local Update_idx = gt.Update_idx or 1

gt._scheduler = cc.Director:getInstance():getScheduler()
local _scheduler = gt._scheduler
function baseGame:ctor(args)
	gt.curCircle = 0
	--是否正在录音
	self.isRecording = false
	self.PlayerNN = {}
	self.playersDataNN = {}
	local name = self.class.__cname 
	gt.log("----name----")
	gt.log(name)

	if not name then return end

	

	if name == "zjhScene" then
	    gt.gameType = "zjh" 
		if args.kPlaytype[7] and args.kPlaytype[7] ==  8 then 
			name = name..args.kPlaytype[7] ..".csb"
			gt.MY_VIEWID          = 5
			gt.GAME_PLAYER         = 8
		else
			name = name..".csb"
			gt.MY_VIEWID          = 3
			gt.GAME_PLAYER         = 5
		end
		gt.soundEngine:stopMusic()
	elseif name == "nnScene" then
		gt.gameType = "nn" 
		name = name..".csb"
		if args.kPlaytype[6] == 6 then 
			gt.GAME_PLAYER = 6
		elseif args.kPlaytype[6] == 10 then
			gt.GAME_PLAYER = 10
		end
		gt.MY_VIEWID = gt.GAME_PLAYER

		self.guancha = (args.kIsLookOn == 1)

		gt.soundEngine:stopMusic()
	elseif name == "ddzScene" then
		gt.gameType = "ddz" 
		name = name..".csb"
		gt.MY_VIEWID = 2
		gt.GAME_PLAYER = 3
		gt.soundEngine:playMusic_poker("sound_res/ddz/bg_zc.wav",true)
	elseif name == "sjScene" then
		gt.gameType = "sj" 
		name = name..".csb"
		gt.MY_VIEWID = 3
		gt.GAME_PLAYER = 4
		gt.soundEngine:playMusic_poker("sj_sound/bg.mp3",true)
	elseif name == "PlayScenePK" then
		gt.gameType = "sde" 
		name = "PlayScene.csb"
		gt.GAME_PLAYER = 5
		gt.MY_VIEWID = 1
	elseif name == "PlaySceneSdy" then
		gt.gameType = "sdy" 
		name = "PlaySceneSdy.csb"
		gt.GAME_PLAYER = 4
		gt.MY_VIEWID = 1
	elseif name == "PlaySceneWuRen" then --五人百分
		gt.gameType = "wrbf" 
		name = "PlaySceneWuRen.csb"
		gt.GAME_PLAYER = 5
		gt.MY_VIEWID = 1
	end


	self.data = args
	self.baginName = self.data.kNike
	

	self.id1 = 0
	self.id2 = 0

	if not gt.soundEngine.Poker_playEffect then 
		package.loaded["client/tools/Sound"] = nil
		gt.soundEngine = require("client/tools/Sound"):create()
	end

	gt.clubId = args.kClubId or 0
	self.UsePos = args.kPos 
	self.baseScore = args.kCellscore
	gt.log("name.............",name, self.UsePos)
	self._node = cc.CSLoader:createNode(name)
	:setName("Poker_node")
	:addTo(self)

	self:_initData(args)
	if args.kState == 102 then 
		self:_Scale(self._node)
	end
	if self.init then self:init(args) end
	self:addVoice()
	self:_addEventListener()
	if self.onNodeEvent then self:registerScriptHandler(handler(self, self.onNodeEvent)) end

  	
  	if device.platform ~= "windows" then
		self.eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		self.customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",
			   handler(self, self.onEnterBackground))
		self.eventDispatcher:addEventListenerWithFixedPriority(self.customListenerBg, 1)
	  
		self.customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
			   handler(self, self.onEnterForeground))
		self.eventDispatcher:addEventListenerWithFixedPriority(self.customListenerFg, 1)

		

	end



end

function baseGame:onEnterBackground()
	if display.getRunningScene() and display.getRunningScene().name == "pokerScene" and gt.gameType ~= "nn" then--and gt.gameType ~= "sde" then 
	--if display.getRunningScene() and display.getRunningScene().name == "pokerScene" and (gt.gameType == "zjh" or gt.gameType = "ddz") then
		--self.__time = os.time()
	--	gt.socketClient:reloginServer()
		gt.socketClient:close()
	end

end

function baseGame:onEnterForeground()



	if display.getRunningScene() and display.getRunningScene().name == "pokerScene" and gt.gameType ~= "nn" then

		gt.socketClient:reloginServer()
	end
	if self.chongZhiJiaoPai2 then self:chongZhiJiaoPai2() end
end

function baseGame:chongZhiJiaoPai2() end

function baseGame:_Scale(node,num)
	gt._scale(node,num)
end

function baseGame:_initData(args)
	
	self.gameBegin = false
	self.palyerPos = {}
	gt.isCreateUserId = self:isRoomCreateUserId(args.kCreateUserId, gt.playerData.uid)

	--是否不是房主建房
	if args.kDeskCreatedType and args.kDeskCreatedType == 0 then
		gt.CreateRoomFlag = true
	else
		gt.CreateRoomFlag = false
	end
	yl.GAMEDATA = {}
	--self.play_type = args.kPlaytype
	if self.data.kState == 102 then
		args = args.kPlaytype
		if args then for i = 1 , 3 do yl.GAMEDATA[i] = i end for i = 4 , #args + 3  do yl.GAMEDATA[i] = tonumber(args[i-3]) end end
		self.applyDimissRoom = require("client/game/poker/view/ApplyDismissRoomPoker"):create(nil, self.UsePos+1)
	elseif self.data.kState == 103 then
		yl.GAMEDATA = args.kPlaytype
		self.applyDimissRoom = require("client/game/poker/view/ApplyDismissRoomPokerNN"):create(nil, self.UsePos+1)
	elseif self.data.kState == 101 then
		self.applyDimissRoom = require("client/game/poker/view/ApplyDismissRoomPoker"):create(nil, self.UsePos+1,args.kPlaytype[5])
	elseif self.data.kState == 106 then
		self.applyDimissRoom = require("client/game/poker/view/ApplyDismissRoomPoker"):create(nil, self.UsePos+1,args.kPlaytype[3])
	else
		self.applyDimissRoom = require("client/game/poker/view/ApplyDismissRoomPoker"):create(nil, self.UsePos+1,args.kPlaytype[5])
	end
	if self.applyDimissRoom then 
		self:addChild(self.applyDimissRoom, 17)
	end
		
end

--是否是房主
function baseGame:isRoomCreateUserId(createUserId, UserId)
	return createUserId == UserId
end
	

function baseGame:isClubCreate(createUserId, UserId)

	return (createUserId == UserId) and ( string.len(self.data.kDeskId) ~= 6 )

end

function baseGame:reLogin()
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
	gt.dumplog(msgToSend)
	gt.socketClient:sendMessage(msgToSend)
end

function baseGame:onRcvLogin(msgTbl)
	gt.log("首条登录消息应答 ===============111 ")

	gt.socketClient:savePlayCount(msgTbl.kTotalPlayNum)

	if msgTbl.kErrorCode == 5 then
		-- 去掉转圈
		gt.removeLoadingTips()
		require("client/game/dialog/NoticeTips"):create("提示",	"您在"..msgTbl.kErrorMsg.."中登录或已创建房间，需要退出或解散房间后再此登录。", nil, nil, true)
		return
	end

	gt.dispatchEvent("_APPLY_DIMISS_ROOM_")
	

	if Update_idx == 1 then 

		if gt.init_wx then 
			
			gt.init_wx("wxed1b16d09a53460c")
				-- if gt.getAppVersion() == 61 then
				-- 	gt.init_wx("wxed1b16d09a53460c")
				-- else
				-- 	gt.init_wx("wx36201a74410db977")
				-- end

		else
			self:setUpdateVersion()
		end
	end



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

	gt.GateServer.ip = msgTbl.kGateIp
	gt.GateServer.port = tostring(msgTbl.kGatePort)

	gt.m_id = msgTbl.kId

	
	gt.socketClient:close()
	gt.socketClient:connect(gt.GateServer.ip, gt.GateServer.port, true)
	local msgToSend = {}
	msgToSend.kMId = gt.CG_LOGIN_GATE
	msgToSend.kStrUserUUID = gt.socketClient:getPlayerUUID()
	gt.dumplog(msgToSend)
	gt.socketClient:sendMessage(msgToSend)
end


function baseGame:remove_id(uid)

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

function baseGame:getLastUserId()
	local data = cc.UserDefault:getInstance():getStringForKey("UserIdList", require("cjson").encode({}))
	local dataList = json.decode(data)

	return dataList[1] or 0
end

function baseGame:removeUserIdLastLoginTime(userId)
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



function baseGame:reloginWhenError(_,m)
	
	local err = gt.err_dump(m)
	local  err_text  = self:findNodeByName("err")
	gt.log("err...........",err)
	if err ~= "" and err_text then 
		err_text:setLocalZOrder(5555)
		err_text:setVisible(true)
		err_text:setString(err)
	end
end

function baseGame:onRcvLoginServer(msgTbl)
	gt.log("收到登录服务器消息 ============== 11111")
	
	-- 去掉转圈
	gt.removeLoadingTips()

	--登录服务器时间
	gt.loginServerTime = msgTbl.kServerTime or os.time()
	--登录本地时间
	gt.loginLocalTime = os.time() 

	gt.connecting = false

	-- 设置开始游戏状态
	gt.socketClient:setIsStartGame(true)
	gt.socketClient:setIsCloseHeartBeat(false)
	
	if gt.isShowOfflineTips == nil then
		Toast.showToast(self, "重新连接服务器成功", 2)
		--self._node:getChildByName("Text_36"):setString("")
	else
		gt.isShowOfflineTips = nil
	end


	if self.removeAllPlayer then self:removeAllPlayer() end

	if msgTbl.kState == 0  or msgTbl.kState == 4 then
		self:removeListener()
		gt.CreateRoomFlag = false
		local mainScene = require("client/game/majiang/MainScene"):create()
		cc.Director:getInstance():replaceScene(mainScene)
		Toast.showToast(mainScene, "游戏已经结束", 2)
	end
end
--服务器返回gate登录
function baseGame:onRcvLoginGate( msgTbl )
	--dump( msgTbl )
	gt.socketClient:setPlayerKeyAndOrder(msgTbl.kStrKey, msgTbl.kUMsgOrder)
	local msgToSend = {}
	msgToSend.kMId = gt.CG_LOGIN_SERVER
	msgToSend.kSeed = gt.loginSeed
	msgToSend.kId = gt.m_id
	local catStr = tostring(gt.loginSeed)
	msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	gt.dumplog(msgToSend)
	gt.socketClient:sendMessage(msgToSend)
end



function baseGame:_addEventListener()

	gt.registerEventListener("hide_mai_di", self, self.hide_mai_di_node)
	gt.registerEventListener("show_result_min", self, self.show_result)

	gt.registerEventListener("show_log", self, self.show_log)
	
	--gt.registerEventListener(gt.EventType.BACK_MAIN_SCENE, self, self.onExitRoom)
	gt.registerEventListener(gt.EventType.RELOGIN_WHEN_ERROR, self, self.reloginWhenError)
	gt.socketClient:registerMsgListener(gt.GC_LOGIN, self, self.onRcvLogin)
	gt.socketClient:registerMsgListener(gt.GC_LOGIN_SERVER, self, self.onRcvLoginServer)
	gt.socketClient:registerMsgListener(gt.GC_LOGIN_GATE, self, self.onRcvLoginGate)

	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_DISRUPT,self,self.disrupt)

	-- gt.socketClient:registerMsgListener(gt.SUB_S_GAME_START,self,self.gameStart)
	-- gt.socketClient:registerMsgListener(gt.SUB_S_ADD_SCORE,self,self.addScore)
	-- gt.socketClient:registerMsgListener(gt.SUB_S_LOOK_CARD,self,self.lookCard)
	-- gt.socketClient:registerMsgListener(gt.SUB_S_COMPARE_CARD,self,self.compareCard)
	-- gt.socketClient:registerMsgListener(gt.SUB_S_AUTO_COMPARE_CARD,self,self.auto_compareCard)
	-- gt.socketClient:registerMsgListener(gt.SUB_S_GIVE_UP,self,self.giveUp)
	-- gt.socketClient:registerMsgListener(gt.SUB_S_GAME_END,self,self.gameEnd)
	-- gt.socketClient:registerMsgListener(gt.SUB_S_BEGIN_BUTTON,self,self.beginBtn)
	-- gt.socketClient:registerMsgListener(gt.SUB_S_AUTO_SCORE_RESULT,self,self.autoScore)
	-- gt.socketClient:registerMsgListener(gt.SUB_S_SCORE_LUN,self,self.GameLayerRefreshlunshu)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_READY_TIME_REMAIN,self,self.clock_time)
	gt.socketClient:registerMsgListener(gt.MSG_S_C_MAIXIA,self,self.mai_xiao)
	gt.socketClient:registerMsgListener(gt.MSG_S_C_MAIDA,self,self.mai_da)
	gt.socketClient:registerMsgListener(gt.MSG_S_C_MAIRESULT,self,self.mai_result)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_S_POKER_GAME,self,self.GameData)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_POKER_GAME_END_RESULT,self,self.GameResult)

	gt.socketClient:registerMsgListener(gt.GC_ADD_PLAYER,self,self.addPlayer)
	gt.socketClient:registerMsgListener(gt.GC_REMOVE_PLAYER,self,self.removePlayer)
	gt.socketClient:registerMsgListener(gt.GC_ENTER_ROOM, self, self.onRcvEnterRoom)
	gt.socketClient:registerMsgListener(gt.GC_CHAT_MSG, self, self.onRcvChatMsg)
	gt.socketClient:registerMsgListener(gt.GC_DISMISS_ROOM, self, self.RcvExitRoom)
	gt.socketClient:registerMsgListener(gt.GC_QUIT_ROOM, self, self.RcvLeaveRoom)
	gt.socketClient:registerMsgListener(gt.GC_READY, self, self.RcvReady)
	gt.socketClient:registerMsgListener(gt.GC_OFF_LINE_STATE,self,self.off_line)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_VIP_INFO,self,self.renovate)
	gt.socketClient:registerMsgListener(gt.MH_MSG_S_2_C_USER_DESK_COMMAND,self, self.RcvDate)
	gt.socketClient:registerMsgListener(gt.MSG_C_2_S_POKER_RECONNECT,self,self.off_line_data)

	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_DDZ_RECON,self,self.off_line_data_ddz)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_S_POKER_GAME_DDZ,self,self.GameData_ddz)

	-- nn 坑货  server 老吴 乱改消息
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_ADD_ROOM_SEAT_DOWN, self, self.onAddRoomSeatDown)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_LOOKON_PLAYER_FULL, self, self.onNNLookonPlayerFull)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_NIUNIU_RECON,self,self.off_line_data_nn)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_NIUNIU_DRAW_RESULT,self,self.gameend_nn)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_NIUNIU_START_GAME,self,self.game_start)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_NIUNIU_SELECT_ZHUANG,self,self.qiangzhuang)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_NIUNIU_NOIFY_QIANG_ZHUNG,self,self.noifyqiangzhuang)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_NIUNIU_ADD_SCORE,self,self.addScore_nn)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_NIUNIU_OPEN_CARD,self,self.sendCard_nn)

	

	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SHUANGSHENG_SEND_CARDS,self,self.send_card)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SHUANGSHENG_NOTICE_SELECT_ZHU,self,self.bao_zhu)
	
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SHUANGSHENG_NOTICE_FAN_ZHU,self,self.fan_zhu)
	
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SHUANGSHENG_NOTICE_BASE_INFO,self,self.change_card)
	
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SHUANGSHENG_BC_GAME_STARE,self,self.game_start)
	
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SHUANGSHENG_BC_OUT_CARDS_RESULT,self,self.notice_push_card)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SHUANGSHENG_BC_DRAW_RESULT,self,self.result_min)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SHUANGSHENG_RECON,self,self.off_line_data_sj)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SHUANGSHENG_BASE_CARDS,self,self.mai_di_result)





	--gt.socketClient:registerMsgListener(gt.MSG_S_2_C_ADD_ROOM_SEAT_DOWN, self, self.sit_result)

	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_SEND_CARDS, self, self.onRcvCards)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_RECV_SCORE, self, self.onRcvScore)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_SHOW_LASTCARDS, self, self.onRcvLastCard)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_BASE_CARD_R, self, self.onRcvBaseCard)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_SELECT_MAIN_R, self, self.onRcvSelectMain)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_SELECT_FRIEND_BC, self, self.onRcvSelectFriend)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_OUT_CARD_BC, self, self.onRcvOutCard)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_DRAW_RESULT_BC, self, self.onRcvRoundReport)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_SCORE_105, self, self.onRcv105Score)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_RECON, self, self.onRcvReconect)
	gt.socketClient:registerMsgListener(gt.MSG_C_2_S_SANDAER_SCORE_105_RESULT, self, self.onRcvScoreResult)

	------------------------3打1消息 start
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAYI_SEND_CARDS, self, self.onRcvCards)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAYI_SELECT_SCORE_R, self, self.onRcvScore)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAYI_BASE_CARD_AND_SELECT_MAIN_N, self, self.onRcvLastCard)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAYI_BASE_CARD_R, self, self.onRcvBaseCard)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAYI_SELECT_MAIN_R, self, self.onRcvSelectMain)
	--gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAER_SELECT_FRIEND_BC, self, self.onRcvSelectFriend)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAYI_OUT_CARD_BC, self, self.onRcvOutCard)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAYI_DRAW_RESULT_BC, self, self.onRcvRoundReport)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAYI_SCORE_105, self, self.onRcv105Score)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_SANDAYI_RECON, self, self.onRcvReconect)
	gt.socketClient:registerMsgListener(gt.MSG_C_2_S_SANDAYI_SCORE_105_RESULT, self, self.onRcvScoreResult)
	------------------------3打1消息 end


	gt.registerEventListener("_back_room_", self, self.onExitRoom)
	gt.registerEventListener("_show_max_result_", self, self.showFinalEvt)


	--五人百分 消息 监听
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SEND_CARDS, self, self.onRcvCards)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_RECV_SCORE, self, self.onRcvScore)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SHOW_LASTCARDS, self, self.onRcvLastCard)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_BASE_CARD_R, self, self.onRcvBaseCard)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SELECT_MAIN_R, self, self.onRcvSelectMain)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SELECT_FRIEND_BC, self, self.onRcvSelectFriend)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_OUT_CARD_BC, self, self.onRcvOutCard)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_DRAW_RESULT_BC, self, self.onRcvRoundReport)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SCORE_105, self, self.onRcv105Score)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_RECON, self, self.onRcvReconect)
	gt.socketClient:registerMsgListener(gt.MSG_C_2_S_WURENBAIFEN_SCORE_105_RESULT, self, self.onRcvScoreResult)
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_ZHUANG_JIAO_PAI_BC, self, self.onRcvJiaoPaiSelect)--广播交牌
	gt.socketClient:registerMsgListener(gt.MSG_S_2_C_WURENBAIFEN_JIAO_PAI_RESULT, self, self.onRcvJiaoPaiResult)--闲家选择后，广播 交牌结果
end

function baseGame:onRcvEnterRoom(args)

	gt.log("enter_room____________________")
	self.data = args
	self.baginName = self.data.kNike
	self.UsePos = args.kPos

	if self.data.kState == 103 then
		self.guancha = (args.kIsLookOn == 1)
	end
	if self.data.kState == 107 then 
		self:addUser(args)
	elseif self.data.kState == 109 then
		self:addUser(args)
	elseif self.data.kState == 110 then
		self:addUser(args)
	end
	self:addPlayer()

end

function baseGame:removeListener()
	-- 播放背景音乐
	gt.soundEngine:playMusic("bgm1", true)
		
	yl.GAMEDATA = {}
	-- gt.gameType = nil
	if device.platform ~= "windows" then
		self.eventDispatcher:removeEventListener(self.customListenerFg)
		self.eventDispatcher:removeEventListener(self.customListenerBg)
	end
	
	-- voicelist
	if self.voiceListListener then
		gt.scheduler:unscheduleScriptEntry(self.voiceListListener)
		self.voiceListListener = nil
	end

	if self.remove_Self then self:remove_Self() end
	gt.log("removemsg____")
	

	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_SERVER)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_GATE)

	-- gt.socketClient:unregisterMsgListener(gt.SUB_S_GAME_START)
	-- gt.socketClient:unregisterMsgListener(gt.SUB_S_ADD_SCORE)
	-- gt.socketClient:unregisterMsgListener(gt.SUB_S_LOOK_CARD) 
	-- gt.socketClient:unregisterMsgListener(gt.SUB_S_COMPARE_CARD)
	-- gt.socketClient:unregisterMsgListener(gt.SUB_S_AUTO_COMPARE_CARD)
	-- gt.socketClient:unregisterMsgListener(gt.SUB_S_GIVE_UP)
	-- gt.socketClient:unregisterMsgListener(gt.SUB_S_GAME_END)
	-- gt.socketClient:unregisterMsgListener(gt.SUB_S_BEGIN_BUTTON)
	-- gt.socketClient:unregisterMsgListener(gt.SUB_S_AUTO_SCORE_RESULT)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_S_POKER_GAME)

	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_DISRUPT)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_C_MAIDA)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_C_MAIXIA)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_C_MAIRESULT)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_READY_TIME_REMAIN)
	gt.socketClient:unregisterMsgListener(gt.GC_ADD_PLAYER)
	gt.socketClient:unregisterMsgListener(gt.GC_REMOVE_PLAYER)
 	gt.socketClient:unregisterMsgListener(gt.GC_ENTER_ROOM)
	gt.socketClient:unregisterMsgListener(gt.GC_CHAT_MSG)
	gt.socketClient:unregisterMsgListener(gt.GC_DISMISS_ROOM)
	gt.socketClient:unregisterMsgListener(gt.GC_QUIT_ROOM)
	gt.socketClient:unregisterMsgListener(gt.GC_READY)
	gt.socketClient:unregisterMsgListener(gt.GC_OFF_LINE_STATE)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_VIP_INFO)
	gt.socketClient:unregisterMsgListener(gt.MH_MSG_S_2_C_USER_DESK_COMMAND)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_POKER_GAME_END_RESULT)
	gt.socketClient:unregisterMsgListener(gt.MSG_C_2_S_POKER_RECONNECT)


	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_DDZ_RECON)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_S_POKER_GAME_DDZ)

	-- nn 坑货  server 老吴 乱改消息
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_LOOKON_PLAYER_FULL)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_ADD_ROOM_SEAT_DOWN)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_NIUNIU_RECON)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_NIUNIU_DRAW_RESULT)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_NIUNIU_START_GAME)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_NIUNIU_SELECT_ZHUANG)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_NIUNIU_NOIFY_QIANG_ZHUNG)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_NIUNIU_ADD_SCORE)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_NIUNIU_OPEN_CARD)


	gt.removeTargetAllEventListener(self)


	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SHUANGSHENG_SEND_CARDS)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SHUANGSHENG_NOTICE_SELECT_ZHU)
	
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SHUANGSHENG_NOTICE_FAN_ZHU)

	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SHUANGSHENG_NOTICE_BASE_INFO)

	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SHUANGSHENG_BC_GAME_STARE)

	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SHUANGSHENG_BC_OUT_CARDS_RESULT)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SHUANGSHENG_BC_DRAW_RESULT)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SHUANGSHENG_RECON)

	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SHUANGSHENG_BASE_CARDS)


	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SANDAER_SEND_CARDS)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SANDAER_RECV_SCORE)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SANDAER_SHOW_LASTCARDS)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SANDAER_BASE_CARD_R)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SANDAER_SELECT_MAIN_R)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SANDAER_SELECT_FRIEND_BC)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SANDAER_OUT_CARD_BC)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SANDAER_DRAW_RESULT_BC)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SANDAER_SCORE_105)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_SANDAER_RECON)
	gt.socketClient:unregisterMsgListener(gt.MSG_C_2_S_SANDAER_SCORE_105_RESULT)

	--五人百分消息移除
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SEND_CARDS)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_RECV_SCORE)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SHOW_LASTCARDS)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_BASE_CARD_R)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SELECT_MAIN_R)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SELECT_FRIEND_BC)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_OUT_CARD_BC)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_DRAW_RESULT_BC)
	-- gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_SCORE_105)
	gt.socketClient:unregisterMsgListener(gt.MSG_S_2_C_WURENBAIFEN_RECON)
	-- gt.socketClient:unregisterMsgListener(gt.MSG_C_2_S_WURENBAIFEN_SCORE_105_RESULT)
end




function baseGame:RcvDate(args)
	gt.log("x_____________x")
	gt.dumplog(args)
	if args.kCommandType == 1 then  -- 显示开始按钮
		self:disBeginBtn(args.kStartButtonPos,args.kNike)
	end

end

function baseGame:RcvExitRoom(msgTbl)

	gt.log("ReadyPlay 创建房间者解散房间 ================= ")
	gt.dumplog(msgTbl)
	gt.isCreateUserId = false
	if msgTbl.kErrorCode == 1 then
		self:removeListener()
		if gt.gameType == "nn" then
			self:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.3),
				cc.CallFunc:create(function()
				local mainScene = require("client/game/majiang/MainScene"):create()
				cc.Director:getInstance():replaceScene(mainScene)
				Toast.showToast(mainScene, msgTbl.kApply.."解散了房间", 2)
			end)))
		else
			local mainScene = require("client/game/majiang/MainScene"):create()
			cc.Director:getInstance():replaceScene(mainScene)
			Toast.showToast(mainScene, msgTbl.kApply.."解散了房间", 2)
		end
	else
		-- 游戏中玩家申请解散房间
		gt.dispatchEvent(gt.EventType.APPLY_DIMISS_ROOM, msgTbl)
	end

end

function baseGame:RcvLeaveRoom(args)
	gt.dumplog(args)
	if args.kErrorCode == 0 then 
		self:removeListener()
		local mainScene = require("client/game/majiang/MainScene"):create()
		cc.Director:getInstance():replaceScene(mainScene)
		Toast.showToast(mainScene, "您已退出该房间", 2)
	end
end

function baseGame:onExitRoom(str)
	gt.CreateRoomFlag = false
	self:removeListener()
	if str 	== "_back_room_"  then str = nil end
	local mainScene = require("client/game/majiang/MainScene"):create()
	cc.Director:getInstance():replaceScene(mainScene)
	if str then Toast.showToast(mainScene,str, 2) end
end

-- bool 游戏是否开始 是能能退出房间
function baseGame:exitRoom(bool)

	local msg = {}
	if bool then 
	
		if not  self.gameBegin then 
			if gt.csw_app_store then 
				local msgToSend = {}
				msgToSend.kMId = gt.CG_DISMISS_ROOM
				msgToSend.kPos = self.UsePos or -1
				gt.dumplog(msgToSend)
				gt.socketClient:sendMessage(msgToSend)
			else
		  		require("client/game/dialog/NoticeTips"):create(
							gt.getLocationString("LTKey_0011"),
							gt.getLocationString("LTKey_0012"),
							function()
								local msgToSend = {}
								msgToSend.kMId = gt.CG_DISMISS_ROOM
								msgToSend.kPos = self.UsePos or -1
								gt.dumplog(msgToSend)
								gt.socketClient:sendMessage(msgToSend)
								--gt.CopyText(" ")
							end)
		  	end
		else

			if gt.csw_app_store then 
				local msgToSend = {}
				msgToSend.kMId = gt.CG_DISMISS_ROOM
				msgToSend.kPos = self.UsePos or -1
				gt.dumplog(msgToSend)
				gt.socketClient:sendMessage(msgToSend)
			else
				if self.data.kState == 103 and self.guancha then
					msg.kMId = gt.CG_QUIT_ROOM
					msg.kPos = self.UsePos or -1
					gt.dumplog(msg)
				    gt.socketClient:sendMessage(msg)
				else
				  require("client/game/dialog/NoticeTips"):create(
								gt.getLocationString("LTKey_0011"),
								gt.getLocationString("LTKey_0012_1"),
								function()
									local msgToSend = {}
									msgToSend.kMId = gt.CG_DISMISS_ROOM
									msgToSend.kPos = self.UsePos or -1
									gt.dumplog(msgToSend)
									gt.socketClient:sendMessage(msgToSend)
									--gt.CopyText(" ")
								end)
				end

			end

		end

	else


			msg.kMId = gt.CG_QUIT_ROOM
			msg.kPos = self.UsePos or -1
			gt.dumplog(msg)
		    gt.socketClient:sendMessage(msg)
		

	end
	
end



function baseGame:GetMeChairID()
	return self.UsePos
end

function baseGame:getTableId(seatId)

	if not self.UsePos then return end

	if seatId >=gt.GAME_PLAYER or seatId < 0 then return gt.INVALID_CHAIR end
	local id = (gt.MY_VIEWID - self.UsePos + seatId)%gt.GAME_PLAYER
	if id == 0 then	id = gt.GAME_PLAYER end
	
	return id

end

function baseGame:SwitchViewChairID(id)
	if not id or id == 21 or id == gt.INVALID_CHAIR then return gt.INVALID_CHAIR end
	return self:getTableId(id)
end

function baseGame:getTableIdNN(seatId)

	-- gt.log("------------self.UsePos", self.UsePos)
	-- gt.log("------------seatId", seatId)
	-- gt.log("------------gt.GAME_PLAYER", gt.GAME_PLAYER)
	-- gt.log("------------gt.INVALID_CHAIR", gt.INVALID_CHAIR)
	-- gt.log("------------gt.MY_VIEWID", gt.MY_VIEWID)

	if not self.UsePos then return end

	if seatId >= gt.GAME_PLAYER or seatId < 0 then return gt.INVALID_CHAIR end
	local UsePos
	if gt.MY_VIEWID == self.UsePos then 
		UsePos = -1
	else
		if seatId == self.UsePos then
			UsePos = gt.MY_VIEWID + seatId
		elseif seatId < self.UsePos then
			UsePos = -1
		elseif seatId > self.UsePos then
			UsePos = 0
		end
	end
	local id = (gt.MY_VIEWID - UsePos + seatId)%gt.GAME_PLAYER
	if id == 0 then	id = gt.GAME_PLAYER end
	
	gt.log("------------id", id)

	return id

end

function baseGame:SwitchViewChairIDNN(id)
	if not id or id == 21 or id == gt.INVALID_CHAIR then return gt.INVALID_CHAIR end
	return self:getTableIdNN(id)
end

--播放音效
function baseGame:PlaySound(path,loop)
  	
  	loop = loop or false
  	--gt.soundEngine:playEffect("common/audio_button_click", false)
	if path then  return gt.soundEngine:Poker_playEffect(path,loop) end

end

function baseGame:playMusic(path,iboll)

	if path then gt.soundEngine:playMusic_poker(path,iboll) end
end

function baseGame:playYuYinAnimation()
	self.m_yuyinNode:setVisible(true)
	local action = cc.CSLoader:createTimeline("huadong.csb")
	self.m_yuyinNode:runAction(action)
	action:gotoFrameAndPlay(0,true)
end

function baseGame:stopYuYinAnimation()
	if self.m_yuyinNode then
		self.m_yuyinNode:setVisible(false)
		self.m_yuyinNode:stopAllActions()
	end
end

function baseGame:getLuaBridge()
	if self.luaBridge then
		return
	end

	if device.platform == "ios" then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif device.platform == "android" then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end
end


function baseGame:startAudio()

	--测试录音
	self.isRecording = true
	if self.voiceList ~= nil and #self.voiceList > 0 then
		self.voiceList[1][2] = 2----被打断了
	end	
	
	self:getLuaBridge()
	if device.platform == "ios" then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "startVoice")
	elseif device.platform == "android" then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "startVoice",nil,"()Z")
	end

end

function baseGame:stopAudio()
	--停止录音
	self.isRecording = false
	if self.voiceList ~= nil and #self.voiceList > 0 then
		self.voiceList[1][2] = 0
	end
	self:getLuaBridge()
	if device.platform == "ios" then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "stopVoice")
	elseif device.platform == "android" then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "stopVoice",nil,"()Z")
		
	end
	local function getUrl() 		-- body
		local ok, ret
		if device.platform == "ios" then
			ok, ret = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "getVoiceUrl")
		elseif device.platform == "android" then
			ok, ret = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "getVoiceUrl", nil, "()Ljava/lang/String;")
		end
			
		if not ret then return  end
		if ret ~= nil and string.len(ret) > 0 and self.checkVoiceUrlType then
			self.checkVoiceUrlType = false
			gt.log(ret)
			--获得到地址上传给服务器
			local msgToSend = {}
			msgToSend.kMId = gt.CG_CHAT_MSG
			msgToSend.kType = 4 -- 语音聊天
			msgToSend.kMusicUrl = ret
			gt.socketClient:sendMessage(msgToSend)

			_scheduler:unscheduleScriptEntry(self.voiceUrlScheduleHandler)
			self.voiceUrlScheduleHandler = nil
		end
	end
	self.checkVoiceUrlType = true
	if self.voiceUrlScheduleHandler then
		gt._scheduler:unscheduleScriptEntry(self.voiceUrlScheduleHandler)
		self.voiceUrlScheduleHandler = nil
	end
	self.voiceUrlScheduleHandler = gt._scheduler:scheduleScriptFunc(getUrl, 1/60, false)

end

function baseGame:cancelAudio()
	self:getLuaBridge()
	if device.platform == "ios" then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "cancelVoice")
	elseif device.platform == "android" then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "cancelVoice",nil,"()Z")
	end

	self.isRecording = false
	if self.voiceList ~= nil and #self.voiceList > 0 then
		self.voiceList[1][2] = 0----重新开始播放
	end
end



function baseGame:addVoice()


	local node = self:findNodeByName("voice")
	if not node then return end
	-- if self.data.kPlaytype[5] == 1 and gt.gameType == "ddz"  then 

	-- else
		self.m_yuyinNode = cc.CSLoader:createNode("huadong.csb")
							:move(display.center)
							:addTo(self._node)
							:setLocalZOrder(1000)
							:setVisible(false)
					
	


		self.yuyinBtn  = node
		self.schedulerEntry = nil
	 	local unpause = function()
	 		if self.schedulerEntry then
	 			_scheduler:unscheduleScriptEntry(self.schedulerEntry)
	 			self.schedulerEntry = nil
	 			self.yuyinBtn:setTouchEnabled(true)
	 		end
	 	end
 	--end
		-- 正式包点击语音按钮回调函数
	local function touchEvent(sender,eventType)
	    
	   	if self.data.kPlaytype[5] == 1 and (gt.gameType == "ddz" or gt.gameType == "sde" or gt.gameType == "sdy" or gt.gameType == "wrbf") then 
	   		Toast.showToast(display.getRunningScene(), "防作弊房间中，禁止发送语音!", 1)
	   		return 
	   	end


        if eventType == ccui.TouchEventType.began then
    		--调用新语音
	          gt.soundEngine:pauseAllSound()
	           self:playYuYinAnimation()
	           self:startAudio()

        elseif eventType == ccui.TouchEventType.moved then
	        if self.yuyinCancle then
	        elseif math.abs(sender:getTouchBeganPosition().y - sender:getTouchMovePosition().y) >= 30 then
			    if self.m_yuyinNode then 
	        		self.m_yuyinNode:setVisible(false)
					self.m_yuyinNode:stopAllActions()
	        	end
	        	
			    self.yuyinCancle=display.newSprite("yuyin2.png")
	            self.yuyinCancle:setPosition(cc.p(632,362.92))
	            if self.yuyinCancle then 
	            	self:addChild(self.yuyinCancle,1000)
	        	end
	        end

        elseif eventType == ccui.TouchEventType.ended then
        	-- 防止乱点
        	self.yuyinBtn:setTouchEnabled(false)
        	self.schedulerEntry = _scheduler:scheduleScriptFunc(unpause, 1, false)
        	gt.soundEngine:resumeAllSound()
        	self:stopYuYinAnimation()
	    	self:stopAudio()
            if self.yuyinCancle then 
	            self.yuyinCancle:removeFromParent()
			    self.yuyinCancle=nil
	        end
        elseif eventType == ccui.TouchEventType.canceled then
        	self:stopYuYinAnimation()
          	gt.soundEngine:resumeAllSound()
		    self:cancelAudio()
            if self.yuyinCancle then 
			    self.yuyinCancle:removeFromParent()
			    self.yuyinCancle=nil
	        end

        end
    end

    node:addTouchEventListener(touchEvent)

end

function baseGame:findNodeByName(name, parent)
	
	parent = parent or self._node 
	
	if tolua.isnull(parent) then return end

	return gt.seekNodeByName(parent,name)
end


--[[
	
	local list = {}
    for i=1, gt.GAME_PLAYER do
    	if self.roomPlayers[i] ~= nil and self.roomPlayers[i].uid ~= gt.playerData.uid then
    		table.insert(list, {self.roomPlayers[i].uid, self.roomPlayers[i].nickname, self.roomPlayers[i].ip})
    	end
    end

    table.sort(list, function(first, second)
    	return first[3] > second[3]
    end)

    local msg = ""
    local curIp = ""
    local sameIpCount = 0
    local msg_all = ""
    for idex = 1, #list do
    	if list[idex].ip ~= curIp then
    		--这里是下一个不相等的IP了
    		if sameIpCount > 1 then
    			--这里是有相同IP
    			msg_all = msg_all..msg.." IP相同,"
    		end
    		msg = ""
    		sameIpCount = 0
    		curIp = list[idex].ip
    	end
    	msg = msg..list[idex].nickname .. "("..list[idex].ip.."),"
    	sameIpCount = sameIpCount + 1
    end

    --这里需要最后一段的IP
    if sameIpCount > 1 then
    	msg_all = msg_all..msg.." IP相同"
    end

]]



-- 加载帧动画
-- @param[format]   帧文件名字format格式
-- @param[start]    起始索引
-- @param[count]    帧数量
-- @param[key]      动画key
-- @param[resType]  资源类型( 1:plist合图、2:单图)
function baseGame:loadAnimationFromFrame( format, start, count, key, resType)
    local animation = cc.Animation:create()
    if nil == animation then
        return
    end
    resType = resType or 1

    local nBegin = start
    local nEnd = start + count

    for i = nBegin, nEnd do

        local buf = string.format(format, i)
        if 2 == resType then
            if cc.FileUtils:getInstance():isFileExist(buf) then
                animation:addSpriteFrameWithFile(buf)
            end
        else
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(buf)
            if nil ~= frame then
                animation:addSpriteFrame(frame)
            end
        end        
    end

    cc.AnimationCache:getInstance():addAnimation(animation, key)
end


-- 获取动画
-- @param[param]    动画参数
function baseGame:getAnimate( param )
    local animation = cc.AnimationCache:getInstance():getAnimation(param.m_strName)
    if nil == animation then
        return nil
    end

    -- 设置参数
    if param.m_bResetParam then
        animation:setDelayPerUnit(param.m_fDelay)
        animation:setRestoreOriginalFrame(param.m_bRestore)
    end
    return cc.Animate:create(animation)
end

function baseGame:m_removeAnimation(name)
	if name then
	 	cc.AnimationCache:getInstance():removeAnimation(name)
	end
end


function baseGame:getAnimationParam()
    return
    {
        -- 动画名称
        m_strName = "",
        -- 是否重置动画参数
        m_bResetParam = true,
        -- 每帧持续时间
        m_fDelay = 0,
        -- 是否恢复到第一帧
        m_bRestore = true,
    }
end


function baseGame:Rote(node,time)
	time = time or 0.01
	if node and not tolua.isnull(node) then 
		node:stopAllActions()
		node:runAction(cc.RepeatForever:create( cc.Sequence:create(cc.RotateTo:create(time,10),cc.RotateTo:create(time,0),cc.RotateTo:create(time,-10),cc.RotateTo:create(time,0))))	
	end

end

--voicelist
function baseGame:startVoiceSchedule(msgTbl)
	if self.voiceList == nil then
		self.voiceList = {}
	end
	table.insert(self.voiceList, {msgTbl, 0})
	gt.log("ddzScene:playVoice")
	gt.dump(self.voiceList)
	if self.voiceListListener == nil then
		self.voiceListListener = gt.scheduler:scheduleScriptFunc(handler(self, self.playVoice), 1, false)
	end
end

--voicelist
function baseGame:playVoice()

	if self.voiceList ~= nil and #self.voiceList > 0 then
		--语音
		gt.soundEngine:pauseAllSound()
		gt.log("暂停音乐 222222")
		require("cjson")

		local msgTbl = self.voiceList[1][1]
		local status = self.voiceList[1][2]
		if status == 0 then---未播放
			self.voiceList[1][2] = 1----播放中

			local videoTime = 0
			local num1,num2 = string.find(msgTbl.kMusicUrl, "\\")
			if not num2 or num2 == nil then
				Toast.showToast(self, "语音文件错误", 2)
				return
			end
			local curUrl = string.sub(msgTbl.kMusicUrl,1,num2-1)
			videoTime = string.sub(msgTbl.kMusicUrl,num2+1)
			


			self:getLuaBridge()
			if gt.isIOSPlatform() then
				local ok = self.luaBridge.callStaticMethod("AppController", "playVoice", {voiceUrl = curUrl})
				self:ShowUserChat1(self:getTableId(msgTbl.kPos),videoTime)
			elseif gt.isAndroidPlatform() then
				local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "playVoice", {curUrl}, "(Ljava/lang/String;)V")
				self:ShowUserChat1(self:getTableId(msgTbl.kPos),videoTime)
			end
		end
	end
end

function baseGame:setUpdateVersion(_callback)
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



return baseGame