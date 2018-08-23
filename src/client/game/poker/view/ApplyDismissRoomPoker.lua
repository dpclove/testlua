
local ApplyDismissRoomPoker = class("ApplyDismissRoomPoker", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function ApplyDismissRoomPoker:ctor(roomPlayers, playerSeatIdx,_tpye)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	self._exit = true
	self.roomPlayers = roomPlayers
	self.playerSeatIdx = playerSeatIdx

	self._type = _tpye
	self:setVisible(false)
	self._sche_time = {}
	self._sche_url = {}
	self.urlName = {}
	-- 注册解散房间事件
	gt.registerEventListener(gt.EventType.APPLY_DIMISS_ROOM, self, self.dismissRoomEvt)

	gt.registerEventListener( "_APPLY_DIMISS_ROOM_", self,self.delete)

end

function ApplyDismissRoomPoker:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
		
	elseif "exit" == eventName then
		self._exit = false
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
		gt.removeTargetAllEventListener(self)
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		for i = 1, 5 do
			if self._sche_url[pos] then  _scheduler:unscheduleScriptEntry(self._sche_url[pos])  self._sche_url[pos] = nil end 
		end
		-- 事件回调
		gt.removeTargetAllEventListener(self)
	end
end

function ApplyDismissRoomPoker:onTouchBegan(touch, event)
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
function ApplyDismissRoomPoker:update(delta)
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
			gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
			--self.dimissTimeCD = 0
			if gt.seekNodeByName(self.rootNode, "Btn_agree") then 
				gt.seekNodeByName(self.rootNode, "Btn_agree"):setVisible(false)
			end
			if gt.seekNodeByName(self.rootNode, "Btn_refuse") then 
				gt.seekNodeByName(self.rootNode, "Btn_refuse"):setVisible(false)
			end
			if gt.seekNodeByName(self.rootNode, "Img_self_waiting") then 
				gt.seekNodeByName(self.rootNode, "Img_self_waiting"):setVisible(true)
			end
		end
	end

	local timeCD = math.ceil(self.dimissTimeCD)
	local dismissTimeCDLabel = gt.seekNodeByName(self.rootNode, "Label_dismissCD")
	dismissTimeCDLabel:setString(tostring(timeCD).."秒")

	-- if self.forceOut and self.dimissTimeCD == 0 then
	-- 	gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)

	-- 	gt.seekNodeByName(self.rootNode, "Node_normal"):setVisible(false)
	-- 	gt.seekNodeByName(self.rootNode, "Node_forceOut"):setVisible(true)

	-- 	local Btn_forceOut = gt.seekNodeByName(self.rootNode, "Btn_forceOut")
	-- 	gt.addBtnPressedListener(Btn_forceOut, function()
	-- 		gt.log("===========================forceOut click")
	-- 		gt.CreateRoomFlag = false
	-- 		gt.dispatchEvent(gt.EventType.BACK_MAIN_SCENE)
	-- 	end)
	-- end
end

--------------------------------
-- @class function
-- @description 接收解散房间消息事件ReadyPlay接收消息以事件方式发送过来
-- @param eventType
-- @param msgTbl
-- end --
function ApplyDismissRoomPoker:dismissRoomEvt(eventType, msgTbl)
	self:setVisible(true)

	if msgTbl.kErrorCode == 0 then
		-- 等待操作中
		if not self.rootNode then
			local str =  "ApplyDismissRoomPoker.csb" 
			if gt.GAME_PLAYER == 8 then 
				str =  "ApplyDismissRoomPokers.csb" 
			elseif  gt.GAME_PLAYER == 3 then
				str =  "ApplyDismissRoomPokers_ddz.csb" 
			elseif gt.GAME_PLAYER == 4 then
				str =  "ApplyDismissRoomPoker_sj.csb" 
			end
			local csbNode = cc.CSLoader:createNode(str)
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
		applyUserLable:setString(self._type == 1 and "xxx" or msgTbl.kApply)
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
		gt.log(gt.GAME_PLAYER)
		cc.SpriteFrameCache:getInstance():addSpriteFrames("images/public_ui.plist")
		for i = 1, gt.GAME_PLAYER do
			gt.log(i)
			local player_name = gt.seekNodeByName(self.rootNode, "lbl_name_player_"..i)
			if player_name then 
				player_name:setVisible(false)
			end
			local player_status = gt.seekNodeByName(self.rootNode, "lbl_status_player_"..i)
			player_status:setVisible(false)
			local headSpr = gt.seekNodeByName(self.rootNode, "Sprite_"..i)
			headSpr:setVisible(false)
			local parent = gt.seekNodeByName(self.rootNode, "Panel"..i)
			if parent then 
				parent:setVisible(false)
			end
			gt.seekNodeByName(self.rootNode, "Text_ID"..i):setVisible(false)
		end
		local index = 1
		for _, v in ipairs(msgTbl.kAgree) do
			local player_name = gt.seekNodeByName(self.rootNode, "lbl_name_player_"..index)
			player_name:setVisible(true)
			player_name:setString(self._type == 1 and  "" or v)
			local player_status = gt.seekNodeByName(self.rootNode, "lbl_status_player_"..index)
			player_status:setVisible(true)
			player_status:setString("同意")
			local bg_s = gt.seekNodeByName(self.rootNode, "Image_"..index)
			if bg_s then 
				bg_s:loadTexture("ddz/jiesan1.png")
			end
			player_status:setColor(cc.c3b(86,184,47))

			local headSpr = gt.seekNodeByName(self.rootNode, "Sprite_"..index)
			headSpr:setVisible(true)
			local parent = gt.seekNodeByName(self.rootNode, "Panel"..index)
			if parent then 
				parent:setVisible(true)
			end
			
			local id = gt.seekNodeByName(self.rootNode, "Text_ID"..index)
			id:setVisible(true)
			gt.log("index_______",index,msgTbl.kAgreeUserId[index])
			id:setString(self._type == 1 and "" or "ID:"..msgTbl.kAgreeUserId[index])
			

			local headUrl = msgTbl.kAgreeHeadUrl[index]
				self:addIcon(headUrl,index)
				--headSpr:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("public_img_head_bg.png"))

			index = index + 1
		end
		for _, v in ipairs(msgTbl.kWait) do

			local player_name = gt.seekNodeByName(self.rootNode, "lbl_name_player_"..index)
			player_name:setVisible(true)
			player_name:setString(self._type == 1 and "" or v)
			local player_status = gt.seekNodeByName(self.rootNode, "lbl_status_player_"..index)
			player_status:setVisible(true)
			player_status:setString("等待中")
			local bg_s = gt.seekNodeByName(self.rootNode, "Image_"..index)
			if bg_s then 
				bg_s:loadTexture("ddz/jiesan.png")
			end
			player_status:setColor(cc.c3b(112,50,21))

			local headSpr =  gt.seekNodeByName(self.rootNode, "Sprite_"..index)
			headSpr:setVisible(true)
			local parent = gt.seekNodeByName(self.rootNode, "Panel"..index)
			if parent then 
				parent:setVisible(true)
			end
		
			local id = gt.seekNodeByName(self.rootNode, "Text_ID"..index)
			id:setVisible(true)
			gt.log("index_______s",index,msgTbl.kWaitUserId[index-#msgTbl.kAgreeHeadUrl])
			id:setString(self._type == 1 and  "" or "ID:"..msgTbl.kWaitUserId[index-#msgTbl.kAgreeHeadUrl])
			

			local headUrl = msgTbl.kWaitHeadUrl[index-#msgTbl.kAgreeHeadUrl]
				self:addIcon(headUrl,index)
				--headSpr:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("public_img_head_bg.png"))
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
		if self._type == 1 then 
			require("client/game/dialog/NoticeTipsCommon"):create(2,
				"有玩家拒绝解散，房间解散失败，游戏继续!",
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
		else
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
		end
		gt.m_userId = 0
	end

	if msgTbl.kErrorCode ~= 0 then
		if self.rootNode then
			self.rootNode:removeFromParent()
			self.rootNode = nil
		end
	end
end

function ApplyDismissRoomPoker:addIcon(url,pos)
		
		local icon =  gt.seekNodeByName(self.rootNode, "Sprite_"..pos)
		local _scheduler = gt.scheduler
		gt.log("addicon___________",self._type)
		if self._type == 1 then 
			if icon.loadTexture then 
				icon:loadTexture("ddz/q.png")
			else
				icon:setTexture("ddz/fangzuobi.png")
			end
		else
			if url ~= ""  and string.len(url)>10 then
				local iamge = gt.imageNamePath(url)
			  	if iamge then
			  		local _name = string.gsub(url, "[/.:+]", "")
			  		local _node = display.newSprite("dismiss_room/icon.png")
					local head = gt.clippingImage(iamge,_node,false)
					
					if self.rootNode:getChildByName(_name) and self.rootNode then self.rootNode:getChildByName(_name):removeFromParent() end
					self.rootNode:addChild(head)
					head:setName(_name)
					head:setPosition(icon:getPositionX(),icon:getPositionY())
					icon:setVisible(false)

			  	else



				  	if type(url) ~= nil and  string.len(url) > 10 then
						local _name = string.gsub(url, "[/.:+]", "")
				  		local function callback(args)
				      		if self._exit and args.done and self and self.rootNode then

								local _node = display.newSprite("dismiss_room/icon.png")
								local head = gt.clippingImage(args.image,_node,false)
								if self.rootNode:getChildByName(_name) and self.rootNode then self.rootNode:getChildByName(_name):removeFromParent() end
								self.rootNode:addChild(head)
								head:setName(_name)
								head:setPosition(icon:getPositionX(),icon:getPositionY())
								icon:setVisible(false)
							end
				        end
					    
					    gt.downloadImage(url,callback)	
					  	
					end

			  -- 		self.urlName[pos] = string.gsub(url, "[/.:+]", "")
					-- local res = cc.UtilityExtension:DownloadImage(url,self.urlName[pos])
					-- if not res then return end
					-- self._sche_time[pos] = 0 

					-- self._sche_url[pos] = _scheduler:scheduleScriptFunc(function(dt)
					-- 		local iamge = cc.FileUtils:getInstance():getWritablePath() .. self.urlName[pos]..".png"
					-- 		if  cc.FileUtils:getInstance():isFileExist(iamge) then
								
					-- 			local _node = display.newSprite("dismiss_room/header.png")
					-- 			local iam = gt.clippingImage(iamge,_node,true)
				
					-- 			if self.rootNode:getChildByName(self.urlName[pos]) and self.rootNode then self.rootNode:getChildByName(self.urlName[pos]):removeFromParent() end
					-- 			self.rootNode:addChild(iam)
					-- 			iam:setName(self.urlName[pos])
					-- 			iam:setPosition(icon:getPositionX(),icon:getPositionY())
					-- 			icon:setVisible(false)
					-- 			if self._sche_url[pos] then  _scheduler:unscheduleScriptEntry(self._sche_url[pos])  self._sche_url[pos] = nil end 
					-- 		else
					-- 			self._sche_time[pos] = self._sche_time[pos] + dt
					-- 			if self._sche_time[pos] >= 10 then if self._sche_url[pos] then  _scheduler:unscheduleScriptEntry(self._sche_url[pos])  self._sche_url[pos] = nil end end
					-- 		end 
					-- 	end,1/60,false)	

			  	end
			 end
		 end

end

function ApplyDismissRoomPoker:delete()

	if self:isVisible() then
		self:setVisible(false)
	end

end

function ApplyDismissRoomPoker:buttonClickEvt(sender)
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

return ApplyDismissRoomPoker

