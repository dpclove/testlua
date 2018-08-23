
local ApplyDismissRoomPokerNN = class("ApplyDismissRoomPokerNN", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function ApplyDismissRoomPokerNN:ctor(roomPlayers, playerSeatIdx)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	self.roomPlayers = roomPlayers
	self.playerSeatIdx = playerSeatIdx
	self._exit = true
	self:setVisible(false)
	self._sche_time = {}
	self._sche_url = {}
	self.urlName = {}
	-- 注册解散房间事件
	gt.registerEventListener(gt.EventType.APPLY_DIMISS_ROOM, self, self.dismissRoomEvt)

	gt.registerEventListener( "_APPLY_DIMISS_ROOM_", self,self.delete)
end

function ApplyDismissRoomPokerNN:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
		
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
		gt.removeTargetAllEventListener(self)
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		for i = 1, 6 do
			if self._sche_url[pos] then  _scheduler:unscheduleScriptEntry(self._sche_url[pos])  self._sche_url[pos] = nil end 
		end
		self._exit = false
		-- 事件回调
		gt.removeTargetAllEventListener(self)
	end
end

function ApplyDismissRoomPokerNN:onTouchBegan(touch, event)
	if not self:isVisible() then
		return false
	end

	return true
end

-- start --
--------------------------------
-- @class function
-- @description 更新解散房间倒计时
-- end --
function ApplyDismissRoomPokerNN:update(delta)
	if not self.rootNode or not self.dimissTimeCD then
		return
	end

	self.dimissTimeCD = self.dimissTimeCD - delta
	if self.dimissTimeCD < 0 then
		self.dimissTimeCD = 0
	end

	if self.dimissTimeCD == 0 then
		if self.forceOut == nil then
			self.forceOut = true
			--self.dimissTimeCD = 10
			gt.seekNodeByName(self.rootNode, "Btn_agree"):setVisible(false)
			gt.seekNodeByName(self.rootNode, "Btn_refuse"):setVisible(false)
			--gt.seekNodeByName(self.rootNode, "Img_self_waiting"):setVisible(true)
			gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		end
	end

	local timeCD = math.ceil(self.dimissTimeCD)
	local dismissTimeCDLabel = gt.seekNodeByName(self.rootNode, "Label_dismissCD")
	dismissTimeCDLabel:setString(tostring(timeCD).."秒")

	-- if self.forceOut and self.dimissTimeCD == 0 then
	-- 	gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)

	-- 	gt.seekNodeByName(self.rootNode, "Node_normal"):setVisible(false)
	-- 	-- gt.seekNodeByName(self.rootNode, "Node_forceOut"):setVisible(true)

	-- 	-- local Btn_forceOut = gt.seekNodeByName(self.rootNode, "Btn_forceOut")
	-- 	-- gt.addBtnPressedListener(Btn_forceOut, function()
	-- 	-- 	gt.log("===========================forceOut click")
	-- 	-- 	gt.CreateRoomFlag = false
	-- 	-- 	gt.dispatchEvent(gt.EventType.BACK_MAIN_SCENE)
	-- 	-- end)
	-- end
end

-- start --
--------------------------------
-- @class function
-- @description 接收解散房间消息事件ReadyPlay接收消息以事件方式发送过来
-- @param eventType
-- @param msgTbl
-- end --
function ApplyDismissRoomPokerNN:dismissRoomEvt(eventType, msgTbl)
	self:setVisible(true)

	if msgTbl.kErrorCode == 0 then
		-- 等待操作中
		if not self.rootNode then
			local csbNode = cc.CSLoader:createNode("ApplyDismissRoomPokerNN.csb")
			csbNode:setPosition(gt.winCenter)
			self:addChild(csbNode)
			self.rootNode = csbNode

			local agreeBtn = gt.seekNodeByName(self.rootNode, "Btn_agree")
			-- 同意
			agreeBtn:setTag(1)
			gt.addBtnPressedListener(agreeBtn, handler(self, self.buttonClickEvt))

			local refuseBtn = gt.seekNodeByName(self.rootNode, "Btn_refuse")
			-- 拒绝
			refuseBtn:setTag(2)
			gt.addBtnPressedListener(refuseBtn, handler(self, self.buttonClickEvt))

			-- 倒计时初始化
			self.dimissTimeCD = msgTbl.kTime
			local dismissTimeCDLabel = gt.seekNodeByName(self.rootNode, "Label_dismissCD")
			dismissTimeCDLabel:setString(tostring(self.dimissTimeCD).."秒")
		end
		
		local applyUserLable = gt.seekNodeByName(self.rootNode, "lbl_apply_user")
		applyUserLable:setString(msgTbl.kApply)
		local agreeBtn = gt.seekNodeByName(self.rootNode, "Btn_agree")
		local refuseBtn = gt.seekNodeByName(self.rootNode, "Btn_refuse")
		local waiting = gt.seekNodeByName(self.rootNode, "Img_self_waiting")
		agreeBtn:setVisible(true)
		refuseBtn:setVisible(true)
		--waiting:setVisible(false)
		if msgTbl.kFlag ~= 0 then
			-- 隐藏操作按钮
			agreeBtn:setVisible(false)
			refuseBtn:setVisible(false)
			if waiting then 
				waiting:setVisible(true)
			end
		end
		--local contentLabel = gt.seekNodeByName(self.rootNode, "Label_content")
		--local contentString = ""
		-- if msgTbl.m_flag == 0 then
		-- 	-- 等待同意或者拒绝
		-- 	contentString = gt.getLocationString("LTKey_0022", msgTbl.m_apply)
		-- else
		-- 	-- 已经同意或者拒绝
		-- 	contentString = gt.getLocationString("LTKey_0023", msgTbl.m_apply)

		-- 	-- 隐藏操作按钮
		-- 	local agreeBtn = gt.seekNodeByName(self.rootNode, "Btn_agree")
		-- 	local refuseBtn = gt.seekNodeByName(self.rootNode, "Btn_refuse")
		-- 	agreeBtn:setVisible(false)
		-- 	refuseBtn:setVisible(false)
		-- end
		-- contentLabel:setString(contentString)
		
		gt.dump(msgTbl)
		cc.SpriteFrameCache:getInstance():addSpriteFrames("images/public_ui.plist")
		for i = 1, 10 do
			local parent = gt.seekNodeByName(self.rootNode, "Panel"..i)
			if parent then 
			parent:setVisible(false)
			gt.seekNodeByName(parent, "Img_mask"):setVisible(false)
		end
			local player_name = gt.seekNodeByName(parent, "lbl_name_player")
			player_name:setVisible(false)
			local player_status = gt.seekNodeByName(parent, "lbl_status_player")
			player_status:setVisible(false)
			local headSpr = gt.seekNodeByName(parent, "Sprite")
			headSpr:setVisible(false)
			gt.seekNodeByName(parent, "Text_ID"):setVisible(false)
		end
		local index = 1
		for _, v in ipairs(msgTbl.kAgree) do
			local parent = gt.seekNodeByName(self.rootNode, "Panel"..index)
			if parent then 
			parent:setVisible(true)
		end
			local player_name = gt.seekNodeByName(parent, "lbl_name_player")
			player_name:setVisible(true)
			player_name:setString(v)
			local player_status = gt.seekNodeByName(parent, "lbl_status_player")
			player_status:setVisible(true)
			player_status:setString("同意")
			player_status:setColor(cc.c3b(86,184,47))

			local headSpr = gt.seekNodeByName(parent, "Sprite")
			headSpr:setVisible(true)
			local headUrl = msgTbl.kAgreeHeadUrl[index]
			if headUrl ~= ""  and string.len(headUrl)>10 then
				self:addIcon(headUrl,index)
			else
				headSpr:removeAllChildren()
			end
			local id = gt.seekNodeByName(parent, "Text_ID")
			id:setVisible(true)
			gt.log("index_______",index,msgTbl.kAgreeUserId[index])
			id:setString("ID:"..msgTbl.kAgreeUserId[index])

			

			index = index + 1
		end
		for _, v in ipairs(msgTbl.kWait) do
			local parent = gt.seekNodeByName(self.rootNode, "Panel"..index)
			if parent then 
			parent:setVisible(true)
		end
			local player_name = gt.seekNodeByName(parent, "lbl_name_player")
			player_name:setVisible(true)
			player_name:setString(v)
			local player_status = gt.seekNodeByName(parent, "lbl_status_player")
			player_status:setVisible(true)
			player_status:setString("等待中")
			player_status:setColor(cc.c3b(112,50,21))

			local headSpr =  gt.seekNodeByName(parent, "Sprite")
			headSpr:setVisible(true)
			local headUrl = msgTbl.kWaitHeadUrl[index-#msgTbl.kAgreeHeadUrl]
			if headUrl ~= "" and string.len(headUrl)>10 then
				self:addIcon(headUrl,index)
			else
				headSpr:removeAllChildren()
			end
			local id = gt.seekNodeByName(parent, "Text_ID")
			id:setVisible(true)
			gt.log("index_______s",index,msgTbl.kWaitUserId[index-#msgTbl.kAgreeHeadUrl])
			id:setString("ID:"..msgTbl.kWaitUserId[index-#msgTbl.kAgreeHeadUrl])

			

			index = index + 1
		end

		-- for _ , in pairs(msgTbl.kWaitUserId) do

		-- 	local id = gt.seekNodeByName(self.rootNode, "Text_ID".._)

		-- end

		gt.m_userId = msgTbl.kUserId
	elseif msgTbl.kErrorCode == 2 then
		-- 三个人同意，解散成功
		gt.CreateRoomFlag = false
		local noticeString = "经玩家【%s】，【%s】，【%s】同意，房间解散成功"
		local agreeNum = #msgTbl.kAgree

		if agreeNum < 3 then
			noticeString = "经玩家【%s】，【%s】同意，房间解散成功"
		end

		if( _G.next({unpack(msgTbl.kAgree)}) ) then
			noticeString = string.format(noticeString, unpack(msgTbl.kAgree))
		end
		local runningScene = cc.Director:getInstance():getRunningScene()
		if runningScene then
			gt.log("remove____________")
			runningScene:removeChildByName("NoticeTipsCommon")
		end
		require("client/game/dialog/NoticeTipsCommon"):create(2,
			noticeString,
			function()
				self:setVisible(false)
			end)
	elseif msgTbl.kErrorCode == 3 then
		-- 时间到，解散成功
		gt.CreateRoomFlag = false
		local runningScene = cc.Director:getInstance():getRunningScene()
		if runningScene then
			gt.log("remove____________")
			runningScene:removeChildByName("NoticeTipsCommon")
		end
		require("client/game/dialog/NoticeTipsCommon"):create(2,
			gt.getLocationString("LTKey_0044"),
			function()
				self:setVisible(false)
			end)
	elseif msgTbl.kErrorCode == 4 then
		-- 有一个人拒绝，解散失败
		local runningScene = cc.Director:getInstance():getRunningScene()
		if runningScene then
			gt.log("remove____________")
			runningScene:removeChildByName("NoticeTipsCommon")
		end
		require("client/game/dialog/NoticeTipsCommon"):create(2,
			gt.getLocationString("LTKey_0026", msgTbl.kRefuse),
			function()
				if not self.rootNode then
					self:setVisible(false)
				else
					local agreeBtn = gt.seekNodeByName(self.rootNode, "Btn_agree")
					if not agreeBtn:isVisible() then
						self:setVisible(false)
					end
				end
			end)
		gt.m_userId = 0
	end

	if msgTbl.kErrorCode ~= 0 then
		if self.rootNode then
			self.rootNode:removeFromParent()
			self.rootNode = nil
		end
	end
end

function ApplyDismissRoomPokerNN:addIcon(url,pos)
	local _scheduler = gt.scheduler
	local image = gt.imageNamePath(url)
	local parent = gt.seekNodeByName(self.rootNode, "Panel"..pos)
	local icon =  gt.seekNodeByName(parent, "Sprite")
	
  	if image then
  		local _name = string.gsub(url, "[/.:+]", "")
  		local _node = display.newSprite("res/dismiss_room_nn/icon.png")
		local head = gt.clippingImage(image,_node,false)
		
		if parent:getChildByName(_name) and parent then parent:getChildByName(_name):removeFromParent() end
		icon:addChild(head)
		head:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)
  	else
	  	if type(url) ~= nil and  string.len(url) > 10 then
			local _name = string.gsub(url, "[/.:+]", "")
	  		local function callback(args)
	      		if args.done and self and self._exit then

					local _node = display.newSprite("res/dismiss_room_nn/icon.png")
					local head = gt.clippingImage(args.image,_node,false)
					if parent:getChildByName(_name) and parent then parent:getChildByName(_name):removeFromParent() end
					icon:addChild(head)
					head:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)
				end
	        end
		    
		    gt.downloadImage(url,callback)	
		  	
		end
  	end
end


function ApplyDismissRoomPokerNN:delete()

	if self:isVisible() then
		self:setVisible(false)
	end

end

function ApplyDismissRoomPokerNN:buttonClickEvt(sender)
	local agreeBtn = gt.seekNodeByName(self.rootNode, "Btn_agree")
	local refuseBtn = gt.seekNodeByName(self.rootNode, "Btn_refuse")
	agreeBtn:setVisible(false)
	refuseBtn:setVisible(false)

	local msgToSend = {}
	msgToSend.kMId = gt.CG_APPLY_DISMISS
	msgToSend.kPos = self.playerSeatIdx - 1
	msgToSend.kFlag = sender:getTag()
	gt.socketClient:sendMessage(msgToSend)
end

return ApplyDismissRoomPokerNN

