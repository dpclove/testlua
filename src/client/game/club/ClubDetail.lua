
local gt = cc.exports.gt

local ClubDetail = class("ClubDetail", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function ClubDetail:ctor(clubData, callback)
	gt.log("点击进入的")
	gt.dump(clubData)
	self.callback = callback
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("ClubDetail.csb")
	csbNode:setAnchorPoint(cc.p(0.5, 0.5))
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
 
	-- 文娱馆名称
	local clubNameLabel = gt.seekNodeByName(csbNode, "Label_clubName")
	clubNameLabel:setString(clubData.club_name)
	
	--会长头像
	local headSpr = gt.seekNodeByName(csbNode, "Spr_head")
	local headLayout = gt.seekNodeByName(csbNode, "Head_layout")
	local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
	playerHeadMgr:attach(headSpr, headLayout, clubData.user_id, clubData.avatar, nil, nil, 100, true)
	self:addChild(playerHeadMgr)
	
	-- 会长名字
	local nickNameLabel = gt.seekNodeByName(csbNode, "Label_nickName")
	nickNameLabel:setString("会长："..(clubData.nickname or "null"))

	--在线人数
	local onlineCountLabel = gt.seekNodeByName(csbNode, "Label_onlineCount")
	onlineCountLabel:setString("0 人在线")

	local clubOnlineUserCount = gt.clubOnlineUserCount or {}
	for i = 1, #clubOnlineUserCount do
		if clubOnlineUserCount[i][1] and clubOnlineUserCount[i][1] == clubData.club_no then
			onlineCountLabel:setString((clubOnlineUserCount[i][2] or 0).." 人在线")
		end
	end
	
	-- 会友数量
	local plyerCountLabel = gt.seekNodeByName(csbNode, "Label_plyerCount")
	plyerCountLabel:setString(clubData.user_count.." 名会友")

	-- 房费支付类型
	local payTypeLabel = gt.seekNodeByName(csbNode, "Label_payType")
	payTypeLabel:setString(clubData.feeType)

	-- 退出文娱馆
	local exitBtn = gt.seekNodeByName(csbNode, "Btn_exit")
	gt.addBtnPressedListener(exitBtn, function()
		require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "是否确定退出文娱馆？ 退出后再进入的话，需要会长审核通过。",
		function()
			self:getExitClub(clubData.club_no)
		end)
	end)

	-- 关闭按钮
	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
        self:removeFromParent()
	end)
end

function ClubDetail:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
	end
end

function ClubDetail:getExitClub(clubId)
	gt.log("----------------getExitClub1")
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local getExitClubURL = gt.getUrlEncryCode(string.format(gt.exitClub, clubId), gt.playerData.uid)
	print("------------getExitClubURL", getExitClubURL)
	xhr:open("GET", getExitClubURL)
	local function onResp()
		if self then
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				gt.dump(xhr.response)
		 		local cjson = require "cjson"
				local ret = cjson.decode(xhr.response)
				if ret.errno == 0 then
					local runningScene = cc.Director:getInstance():getRunningScene()
				 	Toast.showToast(runningScene, "您已退出文娱馆！", 2)
				 	if self.callback then
				 		self.callback()
				 	end

					local runningScene = cc.Director:getInstance():getRunningScene()
					local JoinClub = runningScene:getChildByName("JoinClub")
					if JoinClub then
				 		JoinClub:removeFromParent()
					end

				 	self:removeFromParent()
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

function ClubDetail:onTouchBegan(touch, event)
	return true
end

function ClubDetail:onTouchEnded(touch, event)
	self:removeFromParent()
end

return ClubDetail