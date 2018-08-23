
local gt = cc.exports.gt

local UserCenter = class("UserCenter", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function UserCenter:ctor(playerData, bgHide)
	gt.log("点击进入的")
	gt.dump(playerData)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	--cc.SpriteFrameCache:getInstance():addSpriteFrames("images/public_ui.plist")

	local csbNode = cc.CSLoader:createNode("UserCenter.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
 
	if bgHide then
		local bokehImg = gt.seekNodeByName(csbNode, "Img_bokeh")
		if bokehImg then
			bokehImg:setVisible(false)
		end
	end

	if gt.isAppStoreInReview then
		local bokehImg = gt.seekNodeByName(csbNode, "Img_bokeh")
		if bokehImg then
			bokehImg:setVisible(false)
		end
	end





	local data = playerData.headURL
	local headSpr =  gt.seekNodeByName(csbNode, "icon")
	if type(data) ~= nil and  string.len(data) > 10 then
		local iamge = gt.imageNamePath(data)
		headSpr:setVisible(false)

	  	if iamge then
	  		local _node = display.newSprite("zy_zjh/icon.png")
			local head = gt.clippingImage(iamge,_node,false)
			csbNode:addChild(head)
			head:setName("U__ICON___M")
			head:setPosition(headSpr:getPositionX(),headSpr:getPositionY())
	  	else
	  		local function callback(args)
	      		if self and args.done then
					local _node = display.newSprite("zy_zjh/icon.png")
					local head = gt.clippingImage(args.image,_node,false)
					csbNode:addChild(head)
					head:setName("U__ICON___M")
					head:setPosition(headSpr:getPositionX(),headSpr:getPositionY())
				end
	        end
		    local url = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"
		    url = data
		    gt.downloadImage(url,callback)	
	  	end
	else
		headSpr:setVisible(true)
	end

	-- 头像
	-- local headSpr = gt.seekNodeByName(csbNode, "Spr_head")
	-- local parent = gt.seekNodeByName(csbNode, "Head_layout")
	-- gt.log("headId: ========== ",playerData.headURL)
	--headSpr:setTexture(string.format("%shead_img_%d.png", cc.FileUtils:getInstance():getWritablePath(), playerData.uid))

	-- local str = string.format("%shead_img_%d.png", cc.FileUtils:getInstance():getWritablePath(), playerData.uid)
	-- if cc.FileUtils:getInstance():isFileExist(str) then
 --       headSpr:setTexture(str)
 --    else
	--    headSpr:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("public_img_head_bg.png"))
 --    end
	-- local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
	-- playerHeadMgr:attach(headSpr, parent, playerData.uid, playerData.headURL, nil, nil, 100)
	-- self:addChild(playerHeadMgr)
	-- local scale = 96 / headSpr:getContentSize().width
	-- headSpr:setScale(scale)
	-- 性别
	-- local sexSpr = gt.seekNodeByName(csbNode, "Spr_sex")
	-- -- 默认男
	-- local sexFrameName = "sx_sex_male"
	-- if playerData.sex == 2 then
	-- 	-- 女
	-- 	sexFrameName = "sx_sex_female"
	-- end
	-- sexSpr:setSpriteFrame(sexFrameName .. ".png")

	-- 昵称
	local nicknameLabel = gt.seekNodeByName(csbNode, "Label_nickname")
	nicknameLabel:setString(playerData.nickname)
	-- ID
	local uidLabel = gt.seekNodeByName(csbNode, "Label_uid")
	uidLabel:setString("ID: " .. playerData.uid)

	-- ip
	local ipLabel = gt.seekNodeByName(csbNode, "Label_ip")
	if playerData.ip then

		gt.log("ip.....",playerData.ip)

		ipLabel:setString("IP: " .. playerData.ip)
		if playerData.ip == "" then 
ipLabel:setVisible(false)
		end
	else
		ipLabel:setString("IP: 未获取")
	end

	local coinBtn = gt.seekNodeByName(csbNode, "Btn_coin")
	coinBtn:setTitleText(playerData.roomCardsCount[2])
	if gt.isAppStoreInReview then
		local money = cc.UserDefault:getInstance():getIntegerForKey("money"..tostring(gt.playerData.uid), 0)
		if playerData.roomCardsCount[2] > money then
			money = playerData.roomCardsCount[2]
		end
		cc.UserDefault:getInstance():setIntegerForKey("money"..tostring(gt.playerData.uid), money)
		coinBtn:setTitleText(money)
	end

	local coinPlus = gt.seekNodeByName(csbNode, "Btn_plus")
	local coinIcon = gt.seekNodeByName(csbNode, "Btn_coin_icon")

	if playerData.uid ~= gt.playerData.uid then
		coinBtn:setVisible(false)
		coinIcon:setVisible(false)
	end 

	if not bgHide and gt.isAppStoreInReview == false then
		local function btnsListener(sender, evt)
			if gt.isAppStoreInReview then
				return
			end

			self:removeFromParent()
			local commitinvite = cc.UserDefault:getInstance():getIntegerForKey("InvitationCode"..tostring(gt.playerData.uid), 0)
			if commitinvite ~= 1 then
				local runningScene = cc.Director:getInstance():getRunningScene()
				if runningScene then
					local bindlayer = require("client/game/common/InvitationCodeInputLayers"):create()
					runningScene:addChild(bindlayer, 999)
				end
			else
				
				local runningScene = cc.Director:getInstance():getRunningScene()
				if runningScene then
					local shoppingLayer = require("client/game/common/ShoppingLayer"):create(runningScene)
	 				shoppingLayer:setName("ShoppingLayer")
					runningScene:addChild(shoppingLayer, 5)
				end
			end

			
		end

		gt.addBtnPressedListener(coinBtn, btnsListener)
		gt.addBtnPressedListener(coinPlus, btnsListener)
		gt.addBtnPressedListener(coinIcon, btnsListener)
	else
		coinPlus:setVisible(false)
	end

	gt.addBtnPressedListener(gt.seekNodeByName(csbNode, "Button_22"), function()

		self:removeFromParent()

		end)

	-- local distance = gt.seekNodeByName(csbNode, "distance")
	-- if playerData.displaySeatIdx and (playerData.displaySeatIdx ~= 4) and value then
	-- 	distance:setVisible(true)
	-- 	if value == -1 then
	-- 		distance:setString("未能获取到此玩家的位置信息")
	-- 	else
	-- 		distance:setString("距离:大约" .. value .. "米")
	-- 	end
	-- else
	-- 	distance:setVisible(false)
	-- end
	-- 互动按钮
	-- local rengdanBtn = gt.seekNodeByName(csbNode, "Btn_rengdan")
	-- local songhua = gt.seekNodeByName(csbNode, "Btn_xianhua")
	-- if playerData.uid == gt.playerData.uid then
	-- 	rengdanBtn:hide()
	-- 	songhua:hide()
	-- else
	-- 	local function btnsListener(sender, evt)
	-- 		local msgToSend = {}
	-- 		msgToSend.m_msgId = gt.CG_CHAT_MSG -- 互动动画协议
	-- 		msgToSend.m_type =  5 -- 5代表互动动画
	-- 		msgToSend.m_id = sender:getTag()
	-- 		msgToSend.m_msg = tostring(playerData.uid)
	-- 		self:removeFromParent()
	-- 		gt.socketClient:sendMessage(msgToSend) 
	-- 	end
	-- 	rengdanBtn:setTag(1)
	-- 	songhua:setTag(2)
	-- 	gt.addBtnPressedListener(rengdanBtn, btnsListener)
	-- 	gt.addBtnPressedListener(songhua, btnsListener)
	-- end
end

function UserCenter:onNodeEvent(eventName)
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

function UserCenter:onTouchBegan(touch, event)
	return true
end

function UserCenter:onTouchEnded(touch, event)
	self:removeFromParent()
end

return UserCenter