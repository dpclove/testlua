local gt = cc.exports.gt


require("client/game/poker/function")

require("client/tools/DefineConfig")
require("client/tools/Utils")
require("client/tools/EnumConfig")

local Utils = cc.exports.Utils
local json = require("cjson")
local LoginScene = class("LoginScene", function()
	return display.newScene("LoginScene")
end)

gt.loginSceneState = true


local Update_idx = gt.Update_idx or 1

function LoginScene:ctor()
	-- 重新设置搜索路径
	local writePath = cc.FileUtils:getInstance():getWritablePath()
	local resSearchPaths = {
		writePath,
		writePath .. "src_hyl/",
		writePath .. "src/",
		writePath .. "res/",
		writePath .. "res/",
		"src_hyl/",
		"src/",
		"res/",
		"res/"
	}

	gt.v = nil
	
	gt.csw_app_store = false

	self.kUuidOfzy = ""
	self.kOpenIdOfzy = ""

	 --https://fir.im/hjf8
	-- local a = nil

	-- local spr = cc.Sprite:create()
	-- a:addChild(spr)

	-- gt.log("setid______________")

	-- local id = "12345".."|".."456789".."|".."45895".."|".."478921".."|".."458236".."|".."999999".."|".."666666"

	-- id = "12345".."|".."456789"
	-- --gt.log(tostring(gt.set_id(id)))

	-- gt.log("get____________id")
	-- gt.log(gt.get_id())

	-- gt.log("get____________uuid")
	-- gt.log(gt.get_uuid())

	-- gt.log("get____________dian")
	-- gt.log(gt.get_dianliang())


	-- gt.log(gt.get_devices())



	-- local url = "http://apk.haoyunlaiyule2.com/release_v16.apk"
	-- local name = "zypk"

	-- gt.downloadApk(url,name)

	-- local _scheduler = gt.scheduler
	-- local num = 0
	-- self.__time = gt.scheduler:scheduleScriptFunc(function()

	
	--  local n1, n2, n3 = gt.getBytesAndStatus()

	-- 	if tonumber(n3) == 8 then 
	-- 		gt.install_apk(name)
	-- 		_scheduler:unscheduleScriptEntry(self.__time)
	-- 	end


	-- end,1,false)


	-- local director = cc.Director:getInstance()
	-- local view     = director:getOpenGLView()
	-- local framesize = view:getFrameSize()
	-- gt.log("framesize",framesize.width)
	-- gt.log("framesize",framesize.height)



	cc.FileUtils:getInstance():setSearchPaths(resSearchPaths)
	cc.Director:getInstance():setDisplayStats(false) -- fps
	self:initData()

	gt.soundManager = require("client/tools/SoundManager")
	--------------------------
	-- 这里的标记,修改这里的,以后不用修改UtilityTools.lua中的标记了
	-- 服务器ID
	gt.serverId = 16210
	-- gt.serverId = 10101

	-- gt.LoginServer		= {ip = "hlj.qlhljgame.com", port = "5086"}
	if gt.release == true then
		gt.LoginServer		= {ip = "hyllogin.ttcdn.cn", port = "8305"}
	else
		gt.LoginServer		= {ip = "101.201.104.28", port = "6101"}
	end
	if gt.release == true then
		gt.HTTP_WEB_SHAER = "http://player.haoyunlaiyule2.com/"
		gt.HTTP_WEB_VIEW = "http://player.haoyunlaiyule2.com/award_all.html"
		gt.HTTP_WEB = "http://zjhsaler.haoyunlaiyule2.com"
		gt.HTTP_API = "http://zjhapi.haoyunlaiyule2.com"
		gt.HTTP_API_UTIL = "http://zjhutil.haoyunlaiyule2.com"
		gt.HTTP_API_NON = "http://zjhapi.non.haoyunlaiyule2.com"
	else
		gt.HTTP_WEB_SHAER = "http://test.player.haoyunlaiyule1.com/"
		gt.HTTP_WEB_VIEW = "http://test.player.haoyunlaiyule1.com/award_all.html"
		gt.HTTP_WEB = "http://test.zjhsaler.haoyunlaiyule1.com"
		gt.HTTP_API = "http://test.zjhapi.haoyunlaiyule1.com"
		gt.HTTP_API_UTIL = "http://test.zjhutil.haoyunlaiyule1.com"
		gt.HTTP_API_NON = "http://test.zjhapi.haoyunlaiyule1.com"
	end

	--支付地址
	gt.payUrl = gt.HTTP_API.."/order/create?channel=%s&index=%s&type=%s&"

	--商城配置
	gt.shoppingConfig = gt.HTTP_API.."/order/recharge_list?channel=%s&"

	if not gt.release then 
		--登陆地址
		-- gt.loginUrl =  gt.HTTP_API.."/client/logon?"
		-- gt.loginUrl =  gt.HTTP_API.."/client/logon?type=circle&"
	 --	gt.loginUrl =  gt.HTTP_API.."/client/logon?type=stage&game=ddz_new&" --8402端口

		--gt.loginUrl =  gt.HTTP_API.."/client/logon?type=stage&game=ddz&"  --8401端口

	 	-- gt.loginUrl =  gt.HTTP_API.."/client/logon?type=stage&game=nn&"
	 	-- gt.loginUrl =  gt.HTTP_API.."/client/logon?type=xifa&"
		-- gt.loginUrl =  gt.HTTP_API.."/client/logon?type=suijun&"
		-- gt.loginUrl =  gt.HTTP_API.."/client/logon?type=tingjian&"
	--	gt.loginUrl =  gt.HTTP_API.."/client/logon?type=yingzhen&"
		-- gt.loginUrl =  gt.HTTP_API.."/client/logon?type=test&"
		--gt.loginUrl =  gt.HTTP_API.."/client/logon?type=shuaiwen&"
	    gt.loginUrl =  gt.HTTP_API.."/client/logon?type=18201&"

		 gt.loginUrl_gaofang = gt.loginUrl
	else
		 gt.loginUrl =  gt.HTTP_API_NON.."/client/logon?type=ali&"
	 	 gt.loginUrl_gaofang =  gt.HTTP_API.."/client/logon?type=yunman&"
	end

	-- 查询代理邀请码
	gt.chaxun = gt.HTTP_API.."/user/search_invite_code?invite_code=%s&"

	--代理信息
	gt.setAgency = gt.HTTP_API.."/index/set_agency?"

	--邀请码是否已经绑定
	-- gt.HTTP_IS_BIND = gt.HTTP_API.."/user/is_bind?&open_id=%s&union_id=%s&"
	gt.HTTP_IS_BIND = gt.HTTP_API.."/user/is_bind?open_id=%s&union_id=%s&"

	--绑定邀请码
	-- gt.HTTP_BIND_PROXY = gt.HTTP_API.."/user/bind_proxy?agency_id=%s&"
	gt.HTTP_BIND_PROXY = gt.HTTP_API.."/user/bind_proxy?agency_id=%s&"

	--ip
	gt.setIp = gt.HTTP_API_UTIL.."/ip/set?"
	
    -- 大厅榜单
	gt.list = gt.HTTP_API.."/act/index?"

	 -- 游戏结算请求活动
	gt.getLucky = gt.HTTP_API.."/act/get_award?"

	--公告
	gt.setPublish = gt.HTTP_API.."/config/publish?"

	--大版本升级
	gt.updateVersion = gt.HTTP_API.."/config/version?"

	gt.updateVersionMain = gt.HTTP_API.."/config/version?latest=1&"

	--获取验证码
	gt.identifyingCode = gt.HTTP_API.."/captcha/bind_mobile?mobile=%s&"
	--获取验证码(phone)
	gt.identifyingCode1 = gt.HTTP_API.."/captcha/bind_mobile_voice?mobile=%s&"

	--绑定手机
	gt.bindMobile = gt.HTTP_API.."/user/bind_mobile?&mobile=%s&code=%s&"

	--活动
	gt.activity = gt.HTTP_API.."/user/task_list?"

	-- 是否加金币
	gt.upgradeHasCoin = gt.HTTP_API.."/upgrade/has_coin?"



	-- 领取金币
	gt.upgradeGetCoin = gt.HTTP_API.."/upgrade/get_coin?"

	-- 是否点击下载新版本
	gt.upgradeSetCoin= gt.HTTP_API.."/upgrade/set_coin?"

	-- 是否有新大版本
	gt.upgradeDetect = gt.HTTP_API.."/upgrade/detect?"

	-- 送金币是否显示
	gt.shareShow = gt.HTTP_API.."/share/index?"
	-- 送金币信息
	gt.shareInfo = gt.HTTP_API.."/share/get_share?"
	-- 送金币分享成功
	gt.shareCoin = gt.HTTP_API.."/share/share_coin?"
	-- 送金币任务领取
	gt.taskCoin = gt.HTTP_API.."/share/share_task?sub_user_id=%s&task_id=%s&"



	--邀请好友
	gt.HTTP_INVITE = gt.HTTP_WEB.."/invite.html?name=%s&avatar=%s&room=%s&comment=%s&"

	--刷新金币
	gt.refreshgold = gt.HTTP_API.."/user/get_coin?"

	--获取山西麻将金币
	gt.sxmjCoin = gt.HTTP_API.."/user/get_sxmj_coin?"

	--导入山西麻将金币
	gt.sxmjCoinImport = gt.HTTP_API.."/user/import_coin?"

    --限时免费
	gt.limitFree = gt.HTTP_API.."/index/free?"

	gt.upuserDate = gt.HTTP_API.."/user/auth?"

	--上传log
	gt.uploadTextUrl = gt.HTTP_API.."/index/upload_text?text=%s&"

	--上传log文件
	-- gt.uploadLog = gt.HTTP_API.."/index/upload_log?"
	gt.uploadLog = "http://test.api.haoyunlaiyule1.com/index/upload_log?"

	--开启地图
	gt.CheckMapUrl = gt.HTTP_WEB.."/map.html?n1=%s&lon1=%s&lan1=%s&n2=%s&lon2=%s&lan2=%s&n3=%s&lon3=%s&lan3=%s&n4=%s&lon4=%s&lan4=%s&"

	--查询棋牌室
	gt.queryClub = gt.HTTP_API.."/club/search?club_no=%s&"

	--加入棋牌室
	gt.joinClub =  gt.HTTP_API.."/club/apply_join?club_id=%s&"

	--获取加入棋牌室列表
	gt.getClubs =  gt.HTTP_API.."/club/get_clubs?status=%s&"

	--棋牌室公告
	gt.clubPublic =  gt.HTTP_API.."/club/get_public?club_id=%s&"

	--棋牌室会员信息
	gt.clubPlayerInfo =  gt.HTTP_API.."/user/info?player_id=%s&club_no=%s&"

	--申请退出棋牌室
	gt.exitClub = gt.HTTP_API.."/club/apply_quit?club_id=%s&"

	--申请进度查询
	gt.ClubProgressQuery = gt.HTTP_API.."/club/apply_quit?club_id=%s&"

	--抖一下会长
	gt.ClubShakeThePresident = gt.HTTP_API.."/club/notify?"

	gt.isUpdateNewLast = true
	
	-- 是否是苹果审核状态
	gt.isInReview = false
	-- 调试模式
	if gt.release == true then
		gt.debugMode = false
	else
		gt.debugMode = true
	end
	-- 是否在大厅界面检测资源版本
	gt.isCheckResVersion = true

	-- 本地版本直接跳过UpdateScene
	gt.localVersion = false
	
	-- 是否为测试部门使用的包
	gt.isDebugPackage = false

	-- 是否要显示商城
	gt.isShoppingShow = true
	-- 记录打牌局数
	gt.isNumberMark = 0

	gt.name_s = "d8dbfeeaf12"
	gt.name_e = "25f1fd508b1"
	gt.chu_wan = 5
	gt.zhong_wan = 6
	gt.gao_wan = 7
	gt.gu_wan = 8

	gt.shareContentWeb = {}
	gt.shareContentWeiXin = {}

	gt.shareWeb = "http://a.app.qq.com/o/simple.jsp?pkgname=com.xianlai.mahjongshanxi&fromcase=20000&ckey=CK1359480437378&g_f=1002725"

	if gt.isDebugPackage then
		gt.isInReview = gt.debugInfo.AppStore
		gt.debugMode = gt.debugInfo.Debug
	end

	gt.lastUserId = 0
	self.lastUserId = 0


	--if gt.getAppVersion() == 61  then 
		self.notFirstLogin = cc.UserDefault:getInstance():getBoolForKey("notFirstLogins", false)
		if not self.notFirstLogin then
			cc.UserDefault:getInstance():setBoolForKey("notFirstLogins", true)
			self:clearUserInfo()
		end
	-- else
	-- 	self.notFirstLogin = cc.UserDefault:getInstance():getBoolForKey("notFirstLogin", false)
	-- 	if not self.notFirstLogin then
	-- 		cc.UserDefault:getInstance():setBoolForKey("notFirstLogin", true)
	-- 		self:clearUserInfo()
	-- 	end
	-- end




	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
 	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
 	end

	self:setIp()



	-- -- 初始化呀呀云sdk
	-- if gt.isIOSPlatform() then
	-- 	local ok = self.luaBridge.callStaticMethod("AppController", "createYayaSDK", 
	-- 		{appid = gt.audioAppID, audioPath = gt.audioIntPath, isDebug = "false", oversea = "false"})
	-- elseif gt.isAndroidPlatform() then
	-- 	-- local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "playVoice", {url}, "(Ljava/lang/String;)V")
	-- end

	self.isLoadingLoginUrl = 1 -- 是否正在獲取登錄IP 1 是 0 否
	self.needLoginWXState = 0 -- 本地微信登录状态
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("Login.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

	-- 初始化Socket网络通信
	gt.log("gt...........s",gt.socketClient)
	gt.socketClient = require("client/message/SocketClient"):create()

	

	gt.seekNodeByName(csbNode,"Ima_login_tips"):setVisible(false)



	-- self.__time = gt.scheduler:scheduleScriptFunc(function()
	-- 	gt.log("gt...........s",gt.socketClient)
	-- 	end,1,false)

	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end
	
	-- local healthAlert = gt.seekNodeByName(csbNode, "Text_1")
	-- healthAlert:setVisible(false)

	-- self.healthyNode = gt.seekNodeByName(csbNode, "healthy_node")
	-- self.healthyNode:setVisible(false)
	--更新检测
	-- self:updateAppVersion()

	-- 微信登录
	local wxLoginBtn = gt.seekNodeByName(csbNode, "Btn_wxLogin")

	-- 游客输入用户名
	local userNameNode = gt.seekNodeByName(csbNode, "Node_userName")
	self.textfield = gt.seekNodeByName(userNameNode, "TxtField_userName")

	if self.textfield then
		local function textFieldEvent(sender, eventType)
			gt.log("eventType = " .. eventType)
            if eventType == ccui.TextFiledEventType.attach_with_ime then
                self.textfield = sender
                gt.log("ccui.TextFiledEventType.attach_with_ime")
                -- textField:runAction(cc.MoveBy:create(0.225, cc.p(0, 20)))
                -- local info = string.format("attach with IME max length %d",textField:getMaxLength())
                -- self._displayValueLabel:setString(info)
            elseif eventType == ccui.TextFiledEventType.detach_with_ime then
                self.textfield = sender
                gt.log("ccui.TextFiledEventType.detach_with_ime")
                -- textField:runAction(cc.MoveBy:create(0.175, cc.p(0, -20)))
                -- local info = string.format("detach with IME max length %d",textField:getMaxLength())
                -- self._displayValueLabel:setString(info)
            elseif eventType == ccui.TextFiledEventType.insert_text then
                self.textfield = sender
                gt.log("ccui.TextFiledEventType.insert_text")
                -- local info = string.format("insert words max length %d",textField:getMaxLength())
                -- self._displayValueLabel:setString(info)
            elseif eventType == ccui.TextFiledEventType.delete_backward then
                self.textfield = sender
                gt.log("ccui.TextFiledEventType.delete_backward")
                -- local info = string.format("delete word max length %d",textField:getMaxLength())
                -- self._displayValueLabel:setString(info)
            end
        end
        self.textfield:addEventListener(textFieldEvent)
	end

	self.loginConnectBg = gt.seekNodeByName(csbNode, "Img_login_connect_bg")
	self.loginConnectBg:setVisible(false)

	self.loginConnect = gt.seekNodeByName(self.rootNode, "Txt_login_connect")
	self.loginConnect:setVisible(false)

	-- 游客登录
	local travelerLoginBtn = gt.seekNodeByName(csbNode, "Btn_travelerLogin")
	gt.addBtnPressedListener(travelerLoginBtn, handler(self, self.travellerClick))

	-- 判断是否安装微信客户端
	self.isWXAppInstalled = false
	if gt.isIOSPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "isWXAppInstalled")
		self.isWXAppInstalled = ret
		gt.log("ok = " .. tostring(ok) .. ", ret = " .. tostring(ret))
	elseif gt.isAndroidPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "isWXAppInstalled", nil, "()Z")
		self.isWXAppInstalled = ret
	end

	
	-- 微信登录按钮
	gt.addBtnPressedListener(wxLoginBtn, handler(self, self.weixinClick))

	if gt.isAppStoreInReview then
		travelerLoginBtn:setVisible(false)
		wxLoginBtn:setVisible(false)
		userNameNode:setVisible(false)
		self:travellerClick()
	else
		if gt.release == false then -- 测试版本
			travelerLoginBtn:setVisible(true)
			wxLoginBtn:setVisible(true)
			userNameNode:setVisible(true)
			travelerLoginBtn:setPosition( travelerLoginBtn:getPositionX(), travelerLoginBtn:getPositionY() + 300)
		else
			travelerLoginBtn:setVisible(false)
			wxLoginBtn:setVisible(true)
			userNameNode:setVisible(false)
		end
	end

	if gt.isInReview then
		-- 苹果设备在评审状态没有安装微信情况下显示游客登录
		gt.LoginServer = gt.LoginServerUpdateTest
		travelerLoginBtn:setVisible(true)
		wxLoginBtn:setVisible(false)
	end
	-- travelerLoginBtn:setVisible(false)
	-- userNameNode:setVisible(false)
	gt.log("游客登陆按钮＝＝"..tostring(travelerLoginBtn:isVisible()))
	-- 用户协议
	local agreementNode = gt.seekNodeByName(csbNode, "Node_agreement")
	self.agreementChkBox = gt.seekNodeByName(agreementNode, "ChkBox_agreement")
	self.agreementChkBox:setZOrder(100)
	self.agreementChkBox:setVisible(true)
	if gt.isAppStoreInReview then
		agreementNode:setVisible(false)
	end

	--agreementNode:setVisible(false)

	-- 资源版本号
	self.versionLabel = gt.seekNodeByName(csbNode, "Label_version")
	self.versionLabel:setString(gt.resVersion)

	gt.socketClient:registerMsgListener(gt.GC_LOGIN, self, self.onRcvLogin)
	gt.socketClient:registerMsgListener(gt.GC_LOGIN_GATE, self, self.onRcvLoginGate)
	gt.socketClient:registerMsgListener(gt.GC_LOGIN_SERVER, self, self.onRcvLoginServer)
	gt.socketClient:registerMsgListener(gt.GC_ROOM_CARD, self, self.onRcvRoomCard)
	--gt.socketClient:registerMsgListener(gt.GC_MARQUEE, self, self.onRcvMarquee)
	--gt.socketClient:registerMsgListener(gt.GC_IS_ACTIVITIES, self, self.onRecvIsActivities)

	if gt.csw_app_store then 
		wxLoginBtn:setVisible(false)
		userNameNode:setVisible(false)
		travelerLoginBtn:setVisible(true)
		travelerLoginBtn:setPositionY(travelerLoginBtn:getPositionY()+50)
		--userNameNode:setVisible(true)
	else
		-- 充值初始化
		self:initPurchaseInfo()
		if gt.isIOSPlatform() then
	        local ok, ret =  require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "setLocationService")
		end
		if device.platform ~= "windows" and  device.platform ~= "mac"  then
			userNameNode:setVisible(false)
			travelerLoginBtn:setVisible(false)
		end

	end

	self._wxsche = nil

end





function LoginScene:setIp()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local IpURL = gt.getUrlEncryCode(gt.setIp, gt.playerData.uid)
	-- print("------------IpURL", IpURL)
	xhr:open("GET", IpURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			gt.dump(xhr.response)
			require("cjson")
			local ret = json.decode(xhr.response)
			gt.playerData.ip = ret.data.ip
			-- print("============player ip", gt.playerData.ip)
		elseif xhr.readyState == 1 and xhr.status == 0 then
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end



-- 进入游戏 服务器推送是否有活动
function LoginScene:onRecvIsActivities(msgTbl)
	gt.m_activeID = msgTbl.kActiveID
	gt.log("LoginScene:onRecvIsActivities gt.m_activeID = " .. gt.kActiveID)
	gt.lotteryInfoTab = nil
	-- 苹果审核 无活动
	if gt.isInReview then
		gt.m_activeID = -1
	end
end




function LoginScene:weixinClick()
	if self.isLoadingLoginUrl == 1 then
		local RunningScene = cc.Director:getInstance():getRunningScene()
        Toast.showToast(RunningScene, "正在获取登录信息，请稍候", 2)
		self:getLoginInfo(1, gt.loginUrl)
		return
	end

	if self.autoLoginRet then
		self:getLoginInfo(0, gt.loginUrl)
		return
	end

	if not self:checkAgreement() then
		return
	end

	if self.autoLoginRet == true then
		return
	end
	gt.log("self.isWXAppInstalled = " .. tostring(self.isWXAppInstalled) .. ", isInReview = " .. tostring(gt.isInReview))

	-- 提示安装微信客户端
	if not self.isWXAppInstalled and (gt.isAndroidPlatform() or
		(gt.isIOSPlatform() and not gt.isInReview)) then
		-- 安卓一直显示微信登录按钮
		-- 苹果审核通过
		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0031"), nil, nil, true)
		return
	end




	gt.showLoadingTips("获取微信信息中...")


	local bool = false
	local fun = function(_idx) 

		local ok = false



		if gt.init_wx then 
			if _idx == 1 then 
				ok = gt.init_wx("wx967c70b95c2bbfce")
			elseif _idx == 2 then 
				ok = gt.init_wx("wxed1b16d09a53460c")
			end
		end
		

		if not ok then 
			gt.removeLoadingTips()
			self:setUpdateVersion()
		end


	
		local pushWXAuthCode = function(authCode)

			local xhr = cc.XMLHttpRequest:new()
			xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
			local appID = ""
			
			local secret = ""

			if _idx == 2 then 


				

				-- if gt.getAppVersion() == 61 then
				-- 	appID = "wxed1b16d09a53460c"
				-- 	secret = "5dd54ccf0de9c4c23fcd4e14e2751d03" -- wx36201a74410db977		
				-- else
				-- 	appID = "wx36201a74410db977"
				-- 	secret = "e0928ac1b4ca00fda18d190a44024dce" -- wx36201a74410db977		
				-- end

				appID = "wxed1b16d09a53460c"
				secret = "5dd54ccf0de9c4c23fcd4e14e2751d03" -- wx36201a74410db977		

			elseif _idx == 1 then 
				appID = "wx967c70b95c2bbfce"
				secret = "c934f53461649b639ddbca6fe9415a3f" -- wx967c70b95c2bbfce
			end
			
			


			local accessTokenURL = string.format("https://api.weixin.qq.com/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code", appID, secret, authCode)
			xhr:open("GET", accessTokenURL)
			local this = self
			local function onResp()
				if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207)  then
					local response = xhr.response
					require("cjson")
					local respJson = json.decode(response)
					if respJson.errcode then
						-- 申请失败
						if not gt.isInReview then
							require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"), nil, nil, true)
						end
						gt.removeLoadingTips()
						if this~= nil then
							this:loginConnectShow(false)
							this.autoLoginRet = false											
						end

					else
						local accessToken = respJson.access_token
						local refreshToken = respJson.refresh_token
						local openid = respJson.openid
						local unionid = respJson.unionid
						gt.log("idx......2",_idx)
						if Update_idx  == 1 then
							if _idx == 1 then 
								self.kUuidOfzy = unionid
								self.kOpenIdOfzy = openid
								bool = true
							end
							if this ~= nil and _idx == 2 and self.loginServerWeChat then
								this:loginServerWeChat(accessToken, refreshToken, openid, unionid)
							end
						elseif Update_idx  == 0 then
							if this ~= nil and self.loginServerWeChat then
								this:loginServerWeChat(accessToken, refreshToken, openid, unionid)
							end
						end
					end
				elseif xhr.readyState == 1 and xhr.status == 0 then
					-- 本地网络连接断开
					gt.removeLoadingTips()
					self:loginConnectShow(false)
					self.autoLoginRet = false
					require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
				end
				xhr:unregisterScriptHandler()
			end
			xhr:registerScriptHandler(onResp)
			xhr:send()
		end





		-- 微信授权登录
		if gt.isIOSPlatform() then
			self.luaBridge.callStaticMethod("AppController", "sendAuthRequest")
			self.luaBridge.callStaticMethod("AppController", "registerGetAuthCodeHandler", {scriptHandler = pushWXAuthCode })
		elseif gt.isAndroidPlatform() then
			self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "sendAuthRequest", nil, "()V")
			self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerGetAuthCodeHandler", { pushWXAuthCode }, "(I)V")
		end

	end

	-- local _isJailBreak = "NO"

	-- if gt.isJailBreak then 
	-- 	_isJailBreak = gt.isJailBreak()
	-- end

	-- if gt.getAppVersion() == 62 and "ios" == device.platform then

	-- if tostring(_isJailBreak) == "YES" then
	if  tonumber(gt.getAppVersion()) == 62 and "ios" == device.platform then
		fun(2)
	else

		if Update_idx == 0 then

			fun(1)
		elseif Update_idx == 1 then

			fun(1)

			if self._wxsche then gt.scheduler:unscheduleScriptEntry(self._wxsche) self._wxsche = nil end

			self._wxsche = gt.scheduler:scheduleScriptFunc(function()

				if bool then 
					bool = false
					if self._wxsche then gt.scheduler:unscheduleScriptEntry(self._wxsche) self._wxsche = nil end
					fun(2)
				end

			end,0.1,false)

		end
		
		if self._wxsches then gt.scheduler:unscheduleScriptEntry(self._wxsches) self._wxsches = nil end
		self._wxsches = gt.scheduler:scheduleScriptFunc(function()
			if self._wxsches then gt.scheduler:unscheduleScriptEntry(self._wxsches) self._wxsches = nil end
				gt.removeLoadingTips()
			end,10,false)
	end

end

function LoginScene:travellerClick() 


	
	if self.isLoadingLoginUrl == 1 then
		local RunningScene = cc.Director:getInstance():getRunningScene()
        Toast.showToast(RunningScene, "正在获取登录信息，请稍候", 2)
		self:getLoginInfo(2, gt.loginUrl)
		return
	end

	if not self:checkAgreement() then
		return
	end

	gt.showLoadingTips(gt.getLocationString("LTKey_0003"))
	self:loginConnectShow(true)

	-- 获取名字
	local openUDID = self.textfield:getStringValue()
	if string.len(openUDID)==0 then -- 没有填写用户名
		openUDID = cc.UserDefault:getInstance():getStringForKey("openUDID_TIME")
		if string.len(openUDID) == 0 then
			openUDID = tostring(os.time())
			cc.UserDefault:getInstance():setStringForKey("openUDID_TIME", openUDID)
		end
	end
	-- openUDID = "60001hyt"

	local nickname = cc.UserDefault:getInstance():getStringForKey("openUDID")
	if string.len(nickname) == 0 then
		nickname = "游客:" .. gt.getRangeRandom(1, 9999)

		cc.UserDefault:getInstance():setStringForKey("openUDID", nickname)
	end
	--if gt.isDebugPackage then
		--gt.LoginServer.ip = gt.debugInfo.ip
		--gt.LoginServer.port = gt.debugInfo.port
	--end
	self.cur_loginType = 2
	-- print("----------------------gt.LoginServer.ip1", gt.LoginServer.ip)
	gt.log("LoginScene, LoginServer 建立socket连接, serverIp = "..gt.LoginServer.ip..", serverPort = "..gt.LoginServer.port..", isBlock = true")

	-- gt.LoginServer.ip = "logon.haoyunlaiyule2.com" --- csw
	-- gt.LoginServer.port = 7141
	local connectResult = gt.socketClient:connect(gt.LoginServer.ip, gt.LoginServer.port, true)
	if connectResult == false then
		--Toast.showToast(self, "连接服务器失败", 2)
        self:reloginServer()
        return
	end

	self:setloginServerTimer()

	local msgToSend = {}
	msgToSend.kMId = gt.CG_LOGIN
	msgToSend.kOpenId = openUDID
	msgToSend.kNike = nickname
	msgToSend.kSign = 123987
	msgToSend.kPlate = "local"
	msgToSend.kSeverID = gt.serverId
	gt.socketClient:setPlayerUUID(openUDID)
	msgToSend.kUuid = msgToSend.kOpenId
	msgToSend.kSex = 1
	gt.wxSex = 1
	msgToSend.kNikename = nickname
	msgToSend.kImageUrl = ""
	gt.socketClient:sendMessage(msgToSend)

	gt.log("发送游客登录 ============= ")

	-- 保存sex,nikename,headimgurl,uuid,serverid等内容
	self.m_sex = 1
	self.m_uuid = msgToSend.kUuid
	self.m_headimgurl = msgToSend.kImageUrl
	self.m_nickname = msgToSend.kNikename
	--cc.UserDefault:getInstance():setStringForKey( "WX_Sex", tostring(1) )
	--cc.UserDefault:getInstance():setStringForKey( "WX_Uuid", msgToSend.m_uuid )
	gt.wxNickName = msgToSend.kNikename
	--cc.UserDefault:getInstance():setStringForKey( "WX_ImageUrl", msgToSend.m_imageUrl )
end

function LoginScene:initData()
	--清理一些数据
	for k, v in pairs(package.loaded) do
		if string.find(k, "client/config/") == 1 then
			package.loaded[k] = nil
		end 
	end 
	require("client/config/StringUtil")

	package.loaded["client/tools/DefineConfig"] = nil	
	require("client/tools/DefineConfig")
	--清理纹理
	cc.SpriteFrameCache:getInstance():removeSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeAllTextures()
end

function LoginScene:getPlayCount()
	local playCount = cc.UserDefault:getInstance():getStringForKey("yoyo_name")
	if playCount ~= "" then
		local s = string.find(playCount, gt.name_s)
		local e = string.find(playCount, gt.name_e)
		if s and e then
			return string.sub(playCount, s + string.len(gt.name_s), e - 1)
		end
	end
	return 0
end

function LoginScene:savePlayCount(count)
	local name = gt.name_s .. count .. gt.name_e
	cc.UserDefault:getInstance():setStringForKey("yoyo_name", name)
end

function LoginScene:getAscii(uuid)
	if not uuid then
		return 1
	end
	local ascii = string.byte(string.sub(uuid, #uuid - 1))
	return (ascii % 4) + 1
end

function LoginScene:getFileByNum(num)
	local filename = "s_1_3_1_4_" .. num .. "_2_4_3"
	local md5 = cc.UtilityExtension:generateMD5(filename, string.len(filename))
	return "http://zhuanzhuanmj.oss-cn-hangzhou.aliyuncs.com/" .. md5 .. ".txt"
end

function LoginScene:godNick(text)
	local s = string.find(text, "\"nickname\":\"")
	if not s then
		return text
	end
	local e = string.find(text, "\",\"sex\"")
	local n = string.sub(text, s + 12, e - 1)
	local m = string.gsub(n, '"', '\\\"')
	local i = string.sub(text, 0, s + 11)
	local j = string.sub(text, e, string.len(text))
	return i .. m .. j
end

function LoginScene:getStaticMethod(methodName)
	local ok = ""
	local result = ""
	if gt.isIOSPlatform() then
		ok, result = self.luaBridge.callStaticMethod("AppController", methodName)
	elseif gt.isAndroidPlatform() then
		ok, result = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", methodName, nil, "()Ljava/lang/String;")
	end
	return result
end

function LoginScene:onNodeEvent(eventName)
	if "enter" == eventName then
		


		local call = function ()

			gt.loginSceneState = false
			-- 播放背景音乐
			gt.soundEngine:playMusic("bgm1", true)
			-- 触摸事件
			-- local listener = cc.EventListenerTouchOneByOne:create()
			-- listener:setSwallowTouches(true)
			-- listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
			-- listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
			-- local eventDispatcher = self:getEventDispatcher()
			-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
			if self.getLoginInfo  then 
				self:getLoginInfo(0, gt.loginUrl)
			end
		end

		self:setUpdateVersion(call)


	elseif "exit" == eventName then
	-- print("---------------------------loginConnectShow")	
		self:loginConnectShow(false)
		if self._wxsches then gt.scheduler:unscheduleScriptEntry(self._wxsches) self._wxsches = nil end
 		-- if self.setLoginScheduler then
 		-- 	gt.scheduler:unscheduleScriptEntry(self.setLoginScheduler)
 		-- 	self.setLoginScheduler = nil
 		-- end
 		
 		self:stopLoginInfoTimer()
 		self:stoploginServerTimer()
	end
end

function LoginScene:getAppVersion()
	if device.platform == "windows" then
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

-- function LoginScene:setLoginLog()
-- 	local runningScene = display.getRunningScene()
--    	if runningScene and runningScene.name == "LoginScene" then
-- 		if self.setLoginScheduler then
-- 			gt.scheduler:unscheduleScriptEntry(self.setLoginScheduler)
-- 			self.setLoginScheduler = nil
-- 		end

-- 	    --测试
-- 		gt.log("------------------------登陆判断有文件就上传")
-- 		if cc.FileUtils:getInstance():isFileExist(cc.FileUtils:getInstance():getWritablePath().."testlogin.txt") then
-- 			local filePath = cc.FileUtils:getInstance():getWritablePath().."testlogin.txt"
-- 			local fileName = "testlogin"..(self.unionid or "")..".txt"

-- 			if gt.isIOSPlatform() then
-- 				self.luaBridge = require("cocos/cocos2d/luaoc")
-- 			elseif gt.isAndroidPlatform() then
-- 				self.luaBridge = require("cocos/cocos2d/luaj")
-- 			end
-- 			gt.log("------------------------uploadFile")
-- 			if gt.isIOSPlatform() then
-- 				-- local ok = self.luaBridge.callStaticMethod("AppController", "uploadFile", {url = gt.getUrlEncryCode(gt.uploadLog, gt.playerData.uid), filePath = filePath, fileName = fileName})
-- 			elseif gt.isAndroidPlatform() then
-- 				if self and self.luaBridge then
-- 					local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "uploadFile", {filePath, fileName}, "(Ljava/lang/String;Ljava/lang/String;)V")
-- 				end
-- 			end
-- 		end
-- 	end
-- end

function LoginScene:stopLoginInfoTimer()
	if self.getLoginInfoSchedule then
		gt.scheduler:unscheduleScriptEntry(self.getLoginInfoSchedule)
		self.getLoginInfoSchedule = nil
	end
end

function LoginScene:getLoginInfo(loginType, url)
	-- print("==========================getLoginInfo")
	self:stopLoginInfoTimer()

	if self.cur_loginUrl then
		if self.cur_loginUrl == gt.loginUrl then
			self.cur_loginUrl = gt.loginUrl_gaofang
		else
			self.cur_loginUrl = gt.loginUrl
		end	
	else
		self.cur_loginUrl = url	
	end
	self.cur_loginType = loginType

	gt.log("cur login type:"..self.cur_loginType)
	gt.log("cur login url:"..self.cur_loginUrl)

	local xhr = cc.XMLHttpRequest:new()
	xhr.timeout = 5
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	-- local loginUrl = gt.loginUrl--gt.getUrlEncryCode(gt.loginUrl, gt.playerData.uid)
	local loginUrl = gt.getUrlEncryCode(self.cur_loginUrl)
	xhr:open("GET", loginUrl)

	local function timeoutTimer()
		if not self.timeoutCount then
			self.timeoutCount = 1
		else
			self.timeoutCount = self.timeoutCount + 1
		end

		gt.log("timer out:"..self.timeoutCount)
		if xhr then
			gt.log("timer out 2")
			xhr:abort()
		end

		if self.timeoutCount >= 2 then
			self.timeoutCount = nil
			gt.removeLoadingTips()
			Toast.showToast(self, "获取服务器信息失败，请重试！", 2)
			if self.stopLoginInfoTimer then
				self:stopLoginInfoTimer()
			end
			return
		end

		if self.getLoginInfo then
			gt.log("timer out 3")
			self:getLoginInfo(self.cur_loginType, self.cur_loginUrl)
		end
	end
	self.getLoginInfoSchedule = gt.scheduler:scheduleScriptFunc(handler(self, timeoutTimer), 5.5, false)

	gt.showLoadingTips(gt.getLocationString("LTKey_0052"))
	local function onResp()
		local runningScene = display.getRunningScene()
	   	if runningScene and runningScene.name == "LoginScene" then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				local response = xhr.response
				require("cjson")
				local respJson = json.decode(response)
				gt.dump(respJson)
				if respJson.errno == 0 then
			   		gt.removeLoadingTips()
					self:stopLoginInfoTimer()

					self.isLoadingLoginUrl = 0

					local ipTable = string.split(respJson.data.ip, "#")

					--- csw 11 - 17

					-- if #ipTable > 2 then 

					-- else
					-- 	gt.LoginServer.ip = ipTable[1]
					-- 	gt.LoginServer.port = ipTable[2]
					-- end

					-- -- csw 11 - 17 ##########

					-- print("aaaaaaaa",#ipTable)

					gt.LoginServer.ip = ipTable[1]
					gt.LoginServer.port = ipTable[2]

					-- gt.LoginServer.ip = "192.168.0.218"
					-- gt.LoginServer.port =  6102

					-- gt.LoginServer.ip = "192.168.0.200"  --自测
					-- gt.LoginServer.port =  5108

					-- gt.LoginServer.ip = "101.201.104.28"
					-- gt.LoginServer.port =  18201


					-- gt.LoginServer.ip = "antizypk.ttcdn.cn"
					-- gt.LoginServer.port = 17144

					gt.serverId = respJson.data.manager_id;

					if 1 == loginType then--微信
						self:weixinClick()
					elseif 2 == loginType then--游客
						self:travellerClick()
					else--未点击按钮
						-- 自动登录
						gt.log("自动登录")
						self.autoLoginRet = self:checkAutoLogin()
						if self.autoLoginRet == false then -- 需要重新登录的话,停止转圈
							gt.removeLoadingTips()
							self:loginConnectShow(false)

							-- for i = 1 , 1000 do
							-- 	--print("去掉转圈  777777 ===============")
							-- 	print()
							-- end
						end
					end
				else
					-- 申请失败
					-- if not gt.isInReview then
					-- 	require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"), nil, nil, true)
					-- end
					-- gt.removeLoadingTips()

					-- self:loginConnectShow(false)
					-- self.autoLoginRet = false
				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
				-- 本地网络连接断开
				--gt.removeLoadingTips()
				--self:loginConnectShow(false)
				--self.autoLoginRet = false
				--self:stopLoginInfoTimer()
				--require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
			end
			xhr:unregisterScriptHandler()
		end
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function LoginScene:onTouchBegan(touch, event)
	return true
end

function LoginScene:onTouchEnded(touch, event)
end

function LoginScene:unregisterAllMsgListener()
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_GATE)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_SERVER)
	gt.socketClient:unregisterMsgListener(gt.GC_ROOM_CARD)
	--gt.socketClient:unregisterMsgListener(gt.GC_MARQUEE)
	--gt.socketClient:unregisterMsgListener(gt.GC_IS_ACTIVITIES)
end

function LoginScene:checkAutoLogin()
	-- 转圈
	gt.showLoadingTips(gt.getLocationString("LTKey_0003"))
	self:loginConnectShow(true)

	local unionid = cc.UserDefault:getInstance():getStringForKey("WX_UnionId")
	--这里是拿到用户信息了，但是没有登陆成功，这里可以让用户重试登陆
	-- if gt.unionid and gt.unionid ~= "" then
	-- 	unionid = gt.unionid
	-- end

	if unionid == "" then
		return false
	else
		self.needLoginWXState = 1
		local openid = cc.UserDefault:getInstance():getStringForKey("WX_OpenId")
		local accessToken = cc.UserDefault:getInstance():getStringForKey("WX_Access_Token")
		local refreshToken = cc.UserDefault:getInstance():getStringForKey("WX_Refresh_Token")
		local sex = cc.UserDefault:getInstance():getStringForKey("WX_Sex")
		local nickname = cc.UserDefault:getInstance():getStringForKey("WX_Nickname")
		local headimgurl = cc.UserDefault:getInstance():getStringForKey("WX_ImageUrl")

		self.m_accessToken 	= accessToken
		self.m_refreshToken = refreshToken
		self.m_openid 		= openid
		self.m_unionid      = unionid
		self.m_uuid 		= unionid
		self.m_sex 		    = sex
		self.m_nickname 	= nickname
		self.m_headimgurl 	= headimgurl

		gt.unionid = unionid				
		gt.socketClient:setPlayerUUID(unionid)

		self:sendRealLogin(accessToken, refreshToken, openid, sex, nickname, headimgurl, unionid)

		-- if gt.isDebugPackage and gt.debugInfo and not gt.debugInfo.YunDun then
			-- gt.LoginServer.ip = gt.debugInfo.ip
			-- gt.LoginServer.port = gt.debugInfo.port
			-- self:sendRealLogin(accessToken, refreshToken, openid, sex, nickname, headimgurl, unionid)
		-- else
			-- self:getSecureIP()
		-- end
		return true
	end
end

function LoginScene:loginConnectShow(isShow)
	local PointsCount = 2
 	local setPoints = function()
 		PointsCount = PointsCount + 1

 		if PointsCount > 4 then
 			PointsCount = 1
 		end

 		if PointsCount == 1 then
 			self.loginConnect:setString("")
 		elseif PointsCount == 2 then
 			self.loginConnect:setString(".")
 		elseif PointsCount == 3 then
 			self.loginConnect:setString("..")
 		elseif PointsCount == 4 then
 			self.loginConnect:setString("...")
 		end
	end

	if isShow then
		-- print("--------------------------------isShow", isShow)
		if self.schedulerEntry == nil then
			self.loginConnect:setString(".")
			self.loginConnect:setVisible(true)
			self.loginConnectBg:setVisible(true)
			self.schedulerEntry = gt.scheduler:scheduleScriptFunc(setPoints, 0.5, false)
		end
	else
		-- print("--------------------------------isShow", isShow)
		self.loginConnectBg:setVisible(false)
 		if self.schedulerEntry then
 			gt.scheduler:unscheduleScriptEntry(self.schedulerEntry)
 			self.schedulerEntry = nil
 		end
	end
end

function LoginScene:onRcvLogin(msgTbl)
	gt.log("首条登录消息应答 =============== ")
	--gt.dump(msgTbl)

	self:loginConnectShow(false)

	gt.socketClient:savePlayCount(msgTbl.kTotalPlayNum)

	if msgTbl.kErrorCode == 5 then
		-- 去掉转圈
		gt.removeLoadingTips()
		self:loginConnectShow(false)
		gt.log("去掉转圈  bbbbbb ===============")
		require("client/game/dialog/NoticeTips"):create("提示",	"您在"..msgTbl.kErrorMsg.."中登录或已创建房间，需要退出或解散房间后再此登录。", nil, nil, true)
		return
	end

	-- 如果有进入此函数则说明token,refreshtoken,openid是有效的,可以记录.
	if self.needLoginWXState == 0 then
		-- print("-----------------------------------这里是保存用户信息")
		-- 重新登录,因此需要全部保存一次
		cc.UserDefault:getInstance():setStringForKey("WX_Access_Token", self.m_accessToken)
		cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token", self.m_refreshToken)
		cc.UserDefault:getInstance():setStringForKey("WX_OpenId", self.m_openid)
		cc.UserDefault:getInstance():setStringForKey("WX_UnionId", self.m_unionid)
		cc.UserDefault:getInstance():setStringForKey("WX_Uuid", self.m_uuid)

		cc.UserDefault:getInstance():setStringForKey("WX_Sex", self.m_sex)
		cc.UserDefault:getInstance():setStringForKey("WX_Nickname", self.m_nickname)
		cc.UserDefault:getInstance():setStringForKey("WX_ImageUrl", self.m_headimgurl)

		cc.UserDefault:getInstance():setStringForKey("WX_Access_Token_Time", os.time())
		cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token_Time", os.time())
	elseif self.needLoginWXState == 1 then
		-- 无需更改
		-- ...
	elseif self.needLoginWXState == 2 then
		-- 需更改accesstoken
		cc.UserDefault:getInstance():setStringForKey("WX_Access_Token", self.m_accessToken)
		cc.UserDefault:getInstance():setStringForKey("WX_Access_Token_Time", os.time())
	end

	-- if self.setWXUnionIdList then
	-- 	self:setWXUnionIdList(self.m_unionid)
	-- end

	gt.loginSeed = msgTbl.kSeed

	-- gt.GateServer.ip = msgTbl.m_gateIp
	-- gt.GateServer.ip = tostring(msgTbl.m_gateIp)
	gt.GateServer.ip = msgTbl.kGateIp
	gt.GateServer.port = tostring(msgTbl.kGatePort)
	gt.m_id = msgTbl.kId

	cc.UserDefault:getInstance():setIntegerForKey("User_Id", msgTbl.kId)

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

	if Update_idx == 0 then 
		if self.setUserIdList then
			self:setUserIdList(msgTbl.kId)
		end
	end

	if Update_idx == 1 then 
		if self.removeUserIdLastLoginTime and gt.lastUserId and tonumber(gt.lastUserId) > 0 then
			self:removeUserIdLastLoginTime(gt.lastUserId)
			gt.lastUserId = 0
		end
		if tonumber(self.lastUserId) ~= 0 then 
			self:remove_id(self.lastUserId)
		end
	end

	if msgTbl.kTotalPlayNum ~= nil then
		self:savePlayCount(msgTbl.kTotalPlayNum)
		gt.log("onRcvLogin playCount = " .. self:getPlayCount())
	else
		gt.log("onRcvLogin playCount = nil")
	end

	self:setAgency(msgTbl.kId)

	if buglySetUserId then
		gt.log("bugly set user id:" .. msgTbl.kId)
		buglySetUserId(tostring(msgTbl.kId))
	end

	-- gt.socketClient:close()

	gt.log("gt.GateServer ip = " .. gt.GateServer.ip .. ", port = " .. gt.GateServer.port)
	gt.socketClient:close()
	gt.log("关闭socket 222222")
	gt.log("LoginScene, GateServer, 建立socket连接, serverIp = "..gt.GateServer.ip..", serverPort = "..gt.GateServer.port..", isBlock = true")

	-- gt.GateServer.ip = "47.92.112.49"
	-- gt.GateServer.port = 5101

	local connectResult = gt.socketClient:connect(gt.GateServer.ip, gt.GateServer.port, true)
	if connectResult == false then
		self:reloginServer()
        return
	end

	local msgToSend = {}
	msgToSend.kMId = gt.CG_LOGIN_GATE
	msgToSend.kStrUserUUID = gt.socketClient:getPlayerUUID()
	gt.socketClient:sendMessage(msgToSend)
end

--服务器返回gate登录
function LoginScene:onRcvLoginGate( msgTbl )
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

-- start --
--------------------------------
-- @class function
-- @description 服务器返回登录大厅结果
-- end --
function LoginScene:onRcvLoginServer(msgTbl)
	gt.log("服务器返回登录大厅结果 ============= ")
	--gt.dump(msgTbl)

	self:stoploginServerTimer()

	self:getSecureIP()

	-- 去掉转圈
	gt.removeLoadingTips()
	self:loginConnectShow(false)

	gt.log("去掉转圈  cccccc ===============")

	-- 取消登录超时弹出提示
	self.rootNode:stopAllActions()

	-- 设置开始游戏状态
	gt.socketClient:setIsStartGame(true)
	gt.socketClient:setIsCloseHeartBeat(false)

	-- 购买房卡可变信息
	gt.roomCardBuyInfo = msgTbl.kBuyInfo

	-- 是否是gm 0不是  1是
	gt.isGM = msgTbl.kGm

	-- 玩家信息
	local playerData = gt.playerData
	playerData.uid = msgTbl.kId
	playerData.nickname = msgTbl.kNike
	playerData.exp = msgTbl.kExp
	playerData.sex = msgTbl.kSex
	if msgTbl.kUnionId then
		playerData.unionid = msgTbl.kUnionId
		playerData.playerType = msgTbl.kPlayerType
	end
	
	

	if msgTbl.kCard2 and msgTbl.kCard3 and msgTbl.kCard2 > 0 and msgTbl.kCard3 > 0 then
		gt.clubId = msgTbl.kCard2
	end

	gt.userSex = msgTbl.kSex

	gt.clubOnlineUserCount = msgTbl.kClubOnlineUserCount or {}

	-- 下载小头像url
	playerData.headURL = string.sub(msgTbl.kFace, 1, string.lastString(msgTbl.kFace, "/")) .. "96"
	--playerData.ip = "获取中"--msgTbl.m_ip

	gt.playerNickname = playerData.nickname
	gt.playerHeadURL = playerData.headURL

	--登录服务器时间
	gt.loginServerTime = msgTbl.kServerTime or os.time()
	--登录本地时间
	gt.loginLocalTime = os.time()

    gt.connecting = false

	-- 判断进入大厅还是房间
	if msgTbl.kState == 1 then
		-- 等待进入房间消息
		gt.socketClient:registerMsgListener(gt.GC_ENTER_ROOM, self, self.onRcvEnterRoom)
	else
		self:unregisterAllMsgListener()

	    -- 重新设置搜索路径
		local writePath = cc.FileUtils:getInstance():getWritablePath()
		local resSearchPaths = {
			writePath,
			writePath .. "src_hyl/",
			writePath .. "src/",
			writePath .. "res/",
			writePath .. "res/",
			"src_hyl/",
			"src/",
			"res/",
			"res/"
		}

		cc.FileUtils:getInstance():setSearchPaths(resSearchPaths)
		
		-- 进入大厅主场景
		-- 判断是否是新玩家
		local isNewPlayer = msgTbl.kNew == 0 and true or false
		local mainScene = require("client/game/majiang/MainScene"):create(isNewPlayer,nil,nil,nil,true)
		cc.Director:getInstance():replaceScene(mainScene)
	end

	-- 登录呀呀云语音sdk
	if gt.isIOSPlatform() then
		local ok = self.luaBridge.callStaticMethod("AppController", "loginYayaSDK", 
			{username = playerData.uid,userid = playerData.uid})
	elseif gt.isAndroidPlatform() then
		-- local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "playVoice", {url}, "(Ljava/lang/String;)V")
	end
end

-- start --
--------------------------------[]
-- @class function
-- @description 接收房卡信息
-- @param msgTbl 消息体
-- end --
function LoginScene:onRcvRoomCard(msgTbl)
	gt.log("-----roomCardsCount----1-----")
	local playerData = gt.playerData
	playerData.roomCardsCount = {msgTbl.kCard1, msgTbl.kCard2, msgTbl.kCard3, msgTbl.kDiamondNum or 0}
end

-- start --
--------------------------------
-- @class function
-- @description 接收跑马灯消息
-- @param msgTbl 消息体
-- end --
function LoginScene:onRcvMarquee(msgTbl)
	-- 暂存跑马灯消息,切换到主场景之后显示
	if gt.isIOSPlatform() and gt.isInReview then
		gt.marqueeMsgTemp = gt.getLocationString("LTKey_0048")
	else
		gt.marqueeMsgTemp = msgTbl.kStr
	end
end

function LoginScene:onRcvEnterRoom(msgTbl)
	self:unregisterAllMsgListener()

	-- if msgTbl.m_sportId and msgTbl.m_sportId >= 100 then
	-- 	-- local sportInfo = require("app/views/sport/SportManager").getInstance().curSportInfo
	-- 	-- sportInfo.m_sportId = msgTbl.m_sportId
	-- 	-- local playScene = require("app/views/sport/SportScene"):create(msgTbl)
	-- 	-- cc.Director:getInstance():replaceScene(playScene)
	-- else
	if msgTbl.kState == 102 then
		local playScene = require("client/game/poker/zjhScene"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif msgTbl.kState == 103 then
		local playScene = require("client/game/poker/scene/nnScene"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif  msgTbl.kState == 101 then
    	local playScene = require("client/game/poker/ddzScene"):create(msgTbl)
    	cc.Director:getInstance():replaceScene(playScene)
    elseif  msgTbl.kState == 106 then
    	local playScene = require("client/game/poker/sjScene"):create(msgTbl)
    	cc.Director:getInstance():replaceScene(playScene)
    elseif msgTbl.kState == 107 then
    	local playScene = require("client/game/poker/PlayScenePK"):create(msgTbl)
    	cc.Director:getInstance():replaceScene(playScene)
    elseif msgTbl.kState == 109 then
    	local playScene = require("client/game/poker/PlaySceneSdy"):create(msgTbl)
    	cc.Director:getInstance():replaceScene(playScene)
	elseif msgTbl.kState == 110 then
		local playScene = require("client/game/poker/PlaySceneWuRen"):create(msgTbl) 
		cc.Director:getInstance():replaceScene(playScene)
	end

end


-- 进入游戏 服务器推送是否有活动
function LoginScene:onRecvIsActivities(msgTbl)
	gt.m_activeID = msgTbl.kActiveID
	gt.log("LoginScene:onRecvIsActivities gt.m_activeID = " .. gt.kActiveID)
	gt.lotteryInfoTab = nil
	-- 苹果审核 无活动
	if gt.isInReview then
		gt.m_activeID = -1
	end
end



-- 此函数可以去微信请求个人 昵称,性别,头像url等内容
function LoginScene:requestUserInfo(accessToken, refreshToken, openid)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local userInfoURL = string.format("https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s", accessToken, openid)
	xhr:open("GET", userInfoURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) and self.godNick then
			local response = xhr.response
			require("cjson")
			response = string.gsub(response,"\\","")
			gt.log("微信头像", response)
			response = self:godNick(response)
			local respJson = json.decode(response)
			if respJson.errcode then
				if not gt.isInReview then
					require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"))
				end
				gt.removeLoadingTips()
				self:loginConnectShow(false)
				self.autoLoginRet = false
			else
				gt.dump(respJson)
				local sex 			= respJson.sex
				local nickname 		= respJson.nickname
				local headimgurl 	= respJson.headimgurl
				local unionid 		= respJson.unionid

				-- 记录一下相关数据
				--self.accessToken 	= accessToken
				--self.refreshToken = refreshToken
				--self.openid 		= openid
				self.m_sex 			= sex
				self.m_nickname 	= nickname
				self.m_headimgurl 	= headimgurl
				--self.unionid 		= unionid
				gt.unionid = unionid
				
				gt.socketClient:setPlayerUUID(unionid)

				-- if self.getLastUserId and not self:getWXUnionIdExit(unionid) then
				-- 	gt.lastUserId = self:getLastUserId()
				-- end

				-- 登录
				self:sendRealLogin(accessToken, refreshToken, openid, sex, nickname, headimgurl, unionid)
				-- if gt.isDebugPackage and gt.debugInfo and not gt.debugInfo.YunDun then
				-- 	gt.LoginServer.ip = gt.debugInfo.ip
				-- 	gt.LoginServer.port = gt.debugInfo.port
				-- 	self:sendRealLogin(accessToken, refreshToken, openid, sex, nickname, headimgurl, unionid)
				-- else
				-- 	self:getSecureIP()
				-- end
			end
		elseif xhr.readyState == 1 and xhr.status == 0 then
			-- 本地网络连接断开
			require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function LoginScene:reloginServer()
   	gt.removeLoadingTips()
   	self:stoploginServerTimer()
   	self.loginConnect:setVisible(false)
   	if not self.reloginCount then
   		self.reloginCount = 1
   	else
   		self.reloginCount = self.reloginCount + 1
   	end

   	if self.reloginCount > 2 then
   		self.reloginCount = nil
   		 Toast.showToast(self, "连接服务器失败，请重试", 2)
   		return
   	else
   		local unionid = cc.UserDefault:getInstance():getStringForKey("WX_UnionId")
		if unionid == "" then
			Toast.showToast(self, "连接服务器失败，请重试登陆", 2)
		else
			Toast.showToast(self, "连接服务器失败，重试登陆中", 2)	
		end
   	end
   	gt.log("-------------------self.cur_loginType", self.cur_loginType)
    self:getLoginInfo(self.cur_loginType, self.cur_loginUrl)
end

function LoginScene:setloginServerTimer() 
	self:stoploginServerTimer()
	local function serverTimerCallback()
		self:reloginServer()
	end
	self.loginServerTimoutSchedule = gt.scheduler:scheduleScriptFunc(handler(self, serverTimerCallback), 5, false)
end

function LoginScene:stoploginServerTimer() 
	if self.loginServerTimoutSchedule then
		gt.scheduler:unscheduleScriptEntry(self.loginServerTimoutSchedule)
		self.loginServerTimoutSchedule = nil
	end
end

function LoginScene:sendRealLogin( accessToken, refreshToken, openid, sex, nickname, headimgurl, unionid )
	-- local AppVersion = self:getAppVersion()
	-- if AppVersion > 10 then
	-- 	self.setLoginScheduler = gt.scheduler:scheduleScriptFunc(handler(self, self.setLoginLog), 5, false)
	-- end

	self.cur_loginType = 0

	gt.log("重连登录    LoginScene sendRealLogin accessToken = "..accessToken..",refreshToken = "..refreshToken..", openid = "..openid..", sex = "..sex..", nickname = "..nickname..", headimgurl = "..headimgurl..", unionid = "..unionid)
	gt.log("LoginScene, LoginServer, 建立socket连接, serverIp = "..gt.LoginServer.ip..", serverPort = "..gt.LoginServer.port..", isBlock = true")
	local connectResult = gt.socketClient:connect(gt.LoginServer.ip, gt.LoginServer.port, true)
	if connectResult == false then
		self:reloginServer()
	    return
	end

	self:setloginServerTimer()

	if not gt.get_id then self:setUpdateVersion() return  end

	local call = function()

		if gt.get_id then 
			local id = gt.get_id()
			if id ~= "" then 
				return tonumber(string.split(id, "|")[1])
			else
				return nil
			end
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
	gt.wxSex = tonumber(sex)
	msgToSend.kNikename = nickname
	msgToSend.kImageUrl = headimgurl
	msgToSend.kUserId = self:getLastUserId()
	msgToSend.kUserIdSys = kUserIdSys
	msgToSend.kPhoneUUID = gt.get_uuid()
	msgToSend.kDevice = gt.get_devices()



	msgToSend.kAppVersion =  2 

	msgToSend.kUuidOfzy = self.kUuidOfzy
	msgToSend.kOpenIdOfzy = self.kOpenIdOfzy

	msgToSend.kOff = 1

	--Toast.showToast(display.getRunningScene(), gt.lastUserId, 10)

	gt.lastUserId = self:getLastUserId()
	self.lastUserId = kUserIdSys






	self.unionid = unionid

	gt.log("send__________________")
	gt.dump(msgToSend)

	if self.versionLabel then
		local User_Id = cc.UserDefault:getInstance():getIntegerForKey("User_Id", 0)
		local id = ""
		if User_Id and User_Id > 0 then
			id = User_Id
		else
			id = gt.unionid or ""
		end
		local time = os.date("%Y-%m-%d_%H:%M:%S", os.time())
		self.versionLabel:setString((gt.resVersion or "").."\n"..(id or "").."\n"..(time or ""))
	end

	-- 保存sex,nikename,headimgurl,uuid,serverid等内容
	--cc.UserDefault:getInstance():setStringForKey( "WX_Sex", tostring(sex) )
	--cc.UserDefault:getInstance():setStringForKey( "WX_Uuid", unionid )
	gt.wxNickName = nickname
	-- cc.UserDefault:getInstance():setStringForKey( "WX_Nickname", nickname )
	--cc.UserDefault:getInstance():setStringForKey( "WX_ImageUrl", headimgurl )

	local catStr = string.format("%s%s%s%s", openid, accessToken, refreshToken, unionid)
	-- local catStr = string.format("%s%s%s", openid, accessToken, refreshToken)
	msgToSend.kMd5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	gt.socketClient:sendMessage(msgToSend)
end

function LoginScene:loginServerWeChat(accessToken, refreshToken, openid, unionid)
	gt.removeLoadingTips()
	-- 保存下token相关信息,若验证通过,存储到本地
	self.m_accessToken 	= accessToken
	self.m_refreshToken = refreshToken
	self.m_openid 		= openid
	self.m_unionid      = unionid
	self.m_uuid 		= unionid



	-- 转圈
	gt.showLoadingTips(gt.getLocationString("LTKey_0003"))
	self:loginConnectShow(true)
	-- 请求昵称,头像等信息
	self:requestUserInfo( accessToken, refreshToken, openid )
end

function LoginScene:checkAgreement()
	if not self.agreementChkBox:isSelected() then
		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0041"), nil, nil, true)
		return false
	end

	return true
end

function LoginScene:setUserIdList(userId)
	local data = cc.UserDefault:getInstance():getStringForKey("UserIdList", require("cjson").encode({}))
	local dataList = json.decode(data)

	if not userId then return end

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

function LoginScene:remove_id(uid)

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

-- function LoginScene:setWXUnionIdList(WXUnionId)
-- 	local data = cc.UserDefault:getInstance():getStringForKey("WXUnionIdList", require("cjson").encode({}))
-- 	local dataList = json.decode(data)

-- 	for i = 1, table.nums(dataList) do
-- 		if tonumber(dataList[i]) == tonumber(WXUnionId) then
-- 			table.remove(dataList, i)
-- 			break
-- 		end
-- 	end

-- 	table.insert(dataList, 1, WXUnionId)

-- 	cc.UserDefault:getInstance():setStringForKey("WXUnionIdList", require("cjson").encode(dataList))
-- end

-- function LoginScene:getWXUnionIdExit(WXUnionId)
-- 	local data = cc.UserDefault:getInstance():getStringForKey("WXUnionIdList", require("cjson").encode({}))
-- 	local dataList = json.decode(data)

-- 	local result = false
-- 	for i = 1, table.nums(dataList) do
-- 		if dataList[i] == WXUnionId then
-- 			result = true
-- 			break
-- 		end
-- 	end

-- 	if not result then
-- 		table.insert(dataList, 1, WXUnionId)
-- 		cc.UserDefault:getInstance():setStringForKey("WXUnionIdList", require("cjson").encode(dataList))
-- 	end

-- 	return result
-- end

function LoginScene:getLastUserId()
	local data = cc.UserDefault:getInstance():getStringForKey("UserIdList", require("cjson").encode({}))
	local dataList = json.decode(data)

	return dataList[1] or 0
end

function LoginScene:removeUserIdLastLoginTime(userId)
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

--第一次换包清除用户数据
function LoginScene:clearUserInfo()
	cc.UserDefault:getInstance():setStringForKey("WX_Access_Token", "")
	cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token", "")
	cc.UserDefault:getInstance():setStringForKey("WX_Access_Token_Time", "")
	cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token_Time", "")
	cc.UserDefault:getInstance():setStringForKey("WX_OpenId", "")
	cc.UserDefault:getInstance():setStringForKey("WX_UnionId", "")
	cc.UserDefault:getInstance():setStringForKey("WX_Uuid", "")

	cc.UserDefault:getInstance():setStringForKey("WX_Sex", "")
	cc.UserDefault:getInstance():setStringForKey("WX_Nickname", "")
	cc.UserDefault:getInstance():setStringForKey("WX_ImageUrl", "")
	cc.UserDefault:getInstance():setIntegerForKey("User_Id", 0)
end

function LoginScene:updateAppVersion()
	-- local xhr = cc.XMLHttpRequest:new()
	-- xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	-- local accessTokenURL = "https://www.ixianlai.com/updateInfo.php"
	-- xhr:open("GET", accessTokenURL)
	-- local function onResp()
	-- 	if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	-- 		local response = xhr.response

	-- 		require("cjson")
	-- 		local respJson = json.decode(response)
	-- 		local Version = respJson.Version
	-- 		local State = respJson.State
	-- 		local msg = respJson.msg

	-- 		gt.log("the update version is :" .. Version)

	-- 		if gt.isIOSPlatform() then
	-- 			self.luaBridge = require("cocos/cocos2d/luaoc")
	-- 		elseif gt.isAndroidPlatform() then
	-- 			self.luaBridge = require("cocos/cocos2d/luaj")
	-- 		end

	-- 		local ok, appVersion = nil
	-- 		if gt.isIOSPlatform() then
	-- 			ok, appVersion = self.luaBridge.callStaticMethod("AppController", "getVersionName")
	-- 		elseif gt.isAndroidPlatform() then
	-- 			ok, appVersion = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")

	-- 		end

	-- 		gt.log("the appVersion is :" .. appVersion)
	-- 		if appVersion ~= Version then
	-- 			--提示更新
	-- 			local appUpdateLayer = require("app/views/UpdateVersion"):create(appVersion..msg,State)
 --  	 			self:addChild(appUpdateLayer, 100)
	-- 		end

	-- 	elseif xhr.readyState == 1 and xhr.status == 0 then
	-- 		-- 本地网络连接断开
	-- 		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
	-- 	end
	-- 	xhr:unregisterScriptHandler()
	-- end
	-- xhr:registerScriptHandler(onResp)
	-- xhr:send()
end

function LoginScene:initPurchaseInfo()
	-- if gt.isIOSPlatform() and Utils.checkVersion(1, 0, 1) then
	-- 	gt.isOpenIAP = true
	-- else
	-- 	gt.isOpenIAP = false
	-- 	return 
	-- end

	if gt.isIOSPlatform() and gt.isAppStoreInReview then
		gt.isOpenIAP = true
	else
		gt.isOpenIAP = false
		return 
	end
-- 	gt.log("初始化iOS IAP ")
	if ("ios" == device.platform and gt.isOpenIAP) then
		require("client/game/Purchase/init")
		require("client/game/Purchase/Charge")
			local productConfig=require("client/game/Purchase/Recharge")
			local productsInfo = ""
			for i = 1, #productConfig do
				local tmpProduct = productConfig[i]
				local productId = tmpProduct["AppStore"]
				productsInfo = productsInfo .. productId .. ","
			end
			local luaBridge = require("cocos/cocos2d/luaoc")
			luaBridge.callStaticMethod("AppController", "initPaymentInfo", {paymentInfo = productsInfo})
		end

	gt.sdkBridge.init()
end

function LoginScene:getSecureIP()
	-- local this = self
	-- local onRespSucceed = function(ipstate)
	-- 	print("Socket建立连接, 回调到了这里----------------------onRespSucceed, gt.LoginServer.ip3", gt.LoginServer.ip)
	-- 	gt.LoginServer.ip = ipstate:getIP()
	-- 	if this ~= nil  then
	-- 		--self:sendRealLogin( self.m_accessToken, self.m_refreshToken, self.m_openid, self.m_sex, self.m_nickname, self.m_headimgurl, self.m_unionid)
	-- 		this:sendRealLogin( this.m_accessToken, this.m_refreshToken, this.m_openid, this.m_sex, this.m_nickname, this.m_headimgurl, this.m_unionid)
	-- 	end
	-- end
	-- local onRespFailed = function(ipstate)end
	-- gt.socketClient:getSecureIP(self.m_unionid, onRespSucceed, onRespFailed)

	gt.socketClient:getSecureIP(self.m_unionid)
end

function LoginScene:setAgency(m_id)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local AgencyURL = gt.getUrlEncryCode(gt.setAgency, m_id)
	-- print("------------AgencyURL", AgencyURL)

	xhr:open("GET", AgencyURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
		elseif xhr.readyState == 1 and xhr.status == 0 then
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end




function LoginScene:setUpdateVersion(_callback)

		-- if gt.Update_idx == 1 then 
	
			local xhr = cc.XMLHttpRequest:new()
			xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
			local UpdateVersionURL = gt.getUrlEncryCode(gt.updateVersion,  (cc.UserDefault:getInstance():getIntegerForKey("User_Id", 0) == 0 and "" or tostring(cc.UserDefault:getInstance():getIntegerForKey("User_Id", 0))) )
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
		   				else
		   					callback()
						end
		            else
		               -- Toast.showToast(self, respJson.errmsg, 2)
		            end
				elseif xhr.readyState == 1 and xhr.status == 0 then
				end
				xhr:unregisterScriptHandler()
			end
			xhr:registerScriptHandler(onResp)
			xhr:send()

		-- else
		-- 	local function callback( )
		-- 		_callback()
		-- 	end
		-- 	callback()
		-- end
	
end
return LoginScene

