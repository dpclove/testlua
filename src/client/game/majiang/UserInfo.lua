

local gt = cc.exports.gt
local star = cc.exports.star

local UserInfo = class("UserInfo", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function UserInfo:ctor()
	
	-- 注册节点事件
	
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("images/public_ui.plist")

	local csbNode1 = cc.CSLoader:createNode("UserInfo.csb")
	csbNode1:setVisible(false)
	csbNode1:setPosition(gt.winCenter)
	local csbNode = cc.CSLoader:createNode("UserInfo_self.csb")
	csbNode:setVisible(false)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self:addChild(csbNode1)

	self.csbNode1 = csbNode1

	self.csbNode = csbNode
	self:setVisible(false)
end


function UserInfo:init(playerData)


	local node = nil
	self:setVisible(true)
	
	if playerData.id == gt.playerData.uid then 
		self.csbNode:setVisible(true)
		self.csbNode1:setVisible(false)
		node = self.csbNode
	else
		self.csbNode:setVisible(false)
		self.csbNode1:setVisible(true)
		node = self.csbNode1
	end


	local csbNode = node

	-- 昵称
	local nicknameLabel = gt.seekNodeByName(csbNode, "Label_nickname")
	nicknameLabel:setString(playerData.name)
	-- ID
	local uidLabel = gt.seekNodeByName(csbNode, "Label_uid")
	uidLabel:setString("ID: " .. playerData.id)

	-- ip
	local ipLabel = gt.seekNodeByName(csbNode, "Label_ip")
	if playerData.ip then
		ipLabel:setString("IP: " .. playerData.ip)
		if playerData.ip == "" then 
			ipLabel:setVisible(false)
		end
	else
		ipLabel:setString("IP: 未获取")
	end


	-- local coinBtn = gt.seekNodeByName(csbNode, "Btn_coin")
	-- coinBtn:setTitleText(gt.playerData.roomCardsCount[2])
	if gt.isAppStoreInReview and playerData.id ~= gt.playerData.uid then
		local money = cc.UserDefault:getInstance():getIntegerForKey("money"..tostring(playerData.id), 0)
		if playerData.roomCardsCount[2] > money then
			money = playerData.roomCardsCount[2]
		end
		cc.UserDefault:getInstance():setIntegerForKey("money"..tostring(gt.playerData.id), money)
		coinBtn:setTitleText(money)
	end



	if playerData.id ~= gt.playerData.uid then
		local hudong1Btn = gt.seekNodeByName(csbNode, "Btn_hudong1")
		local hudong2Btn = gt.seekNodeByName(csbNode, "Btn_hudong2")
		local hudong3Btn = gt.seekNodeByName(csbNode, "Btn_hudong3")
		local hudong4Btn = gt.seekNodeByName(csbNode, "Btn_hudong4")
		if playerData.id == gt.playerData.uid then
			hudong1Btn:hide()
			hudong2Btn:hide()
			hudong3Btn:hide()
			hudong4Btn:hide()
		else
			local function btnsListener(sender, evt)
				local msgToSend = {}
				msgToSend.kMId = gt.CG_CHAT_MSG -- 互动动画协议
				msgToSend.kType =  5 -- 5代表互动动画
				msgToSend.kId = sender:getTag()
				msgToSend.kMsg = tostring(playerData.id)
				gt.socketClient:sendMessage(msgToSend) 
				self:setVisible(false)
			end
			hudong1Btn:setTag(1)
			hudong2Btn:setTag(2)
			hudong3Btn:setTag(3)
			hudong4Btn:setTag(4)
			gt.addBtnPressedListener(hudong1Btn, btnsListener)
			gt.addBtnPressedListener(hudong2Btn, btnsListener)
			gt.addBtnPressedListener(hudong3Btn, btnsListener)
			gt.addBtnPressedListener(hudong4Btn, btnsListener)
		end
	end
	-- local headLayout = gt.seekNodeByName(csbNode, "Head_layout")
	-- local headSpr = gt.seekNodeByName(headLayout, "Spr_head")

	local data = playerData.url
	  -- local data = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"
	
	gt.log("data____________")
	gt.log(data)

	for i = 1, gt.GAME_PLAYER do

		

		if node:getChildByName("__ICON___"..i) and playerData._pos ~= i then 
			
			node:getChildByName("__ICON___"..i):setVisible(false)
		end
		if playerData._pos == i then 
			if  not node:getChildByName("__ICON___"..i) then
				if data and type(data) ~= nil and  string.len(data) > 10 then
					gt.log("_____down___________")
					local icon = node:getChildByName("icon")
				
				  	if iamge then
				  		local _node = display.newSprite("zy_zjh/icon.png")
						local head = gt.clippingImage(iamge,_node,false)
						head:setPosition(icon:getPositionX(),icon:getPositionY())
						if gt.addNode(node,head) then 
							icon:setVisible(false)
							head:setName("__ICON___"..playerData._pos)
						end

				  	else
				  		gt.log("else________")
				  		local function callback(args)
				      		if self and args.done  then
				      			local _node = display.newSprite("zy_zjh/icon.png")
				      			local head = gt.clippingImage(args.image,_node,false)
				      			head:setPosition(icon:getPositionX(),icon:getPositionY())
								if gt.addNode(node,head) then 
									icon:setVisible(false)
									head:setName("__ICON___"..playerData._pos)
								end
							end
				        end
					    local url = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"
					    url = data
					    gt.downloadImage(url,callback)	
				  	end
				
				end
				
			else
				
				node:getChildByName("icon"):setVisible(false)
				node:getChildByName("__ICON___"..i):setVisible(true)

			end
		end
	end


end


function UserInfo:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		--listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
	end
end

function UserInfo:onTouchBegan(touch, event)
	return true
end

function UserInfo:onTouchEnded(touch, event)

	self:setVisible(false)

end

--star
function UserInfo:showStarMJ(node, starLevel, offset, starScale, starOffset)
	local path = "res/animation/Star/Star"..starLevel..".csb"
	if cc.FileUtils:getInstance():isFileExist(path) then
		local animationNode, animationNoAni = gt.createCSAnimation(path)
		animationNode:setAnchorPoint(cc.p(0.5, 0))
		gt.log("-----------offset", offset)

		local animationNodeOffset = 18
		if starLevel == 3 then
			animationNode:setPositionX(animationNode:getPositionX() + 4)
			if starOffset then
				animationNode:setPositionY(offset/2 + animationNodeOffset + starOffset)
			else
				animationNode:setPositionY(offset/2 + animationNodeOffset)
			end
		elseif starLevel == 4 then
			animationNodeOffset = 8
			if starOffset then
				animationNode:setPositionY(offset/2 + animationNodeOffset + starOffset)
			else
				animationNode:setPositionY(offset/2 + animationNodeOffset)
			end
		elseif starLevel == 5 then
			animationNodeOffset = 8
			starScale = starScale*3/4
			if starOffset then
				animationNode:setPositionY(offset/2 + animationNodeOffset + starOffset)
			else
				animationNode:setPositionY(offset/2 + animationNodeOffset)
			end
		else
			if starOffset then
				animationNode:setPositionY(offset/2 + animationNodeOffset + starOffset)
			else
				animationNode:setPositionY(offset/2 + animationNodeOffset)
			end
		end
		if starScale then
			animationNode:setScale(starScale)
		end
		node:addChild(animationNode)
		animationNoAni:play("run", true)
	end
end

function UserInfo:showStarLevelMJ(node, starLevel, m_fScale, scale, starScale, starOffset)
	local animationNodeSclae = 80
	local x = 0
	local y = - node:getParent():getContentSize().height
	if starLevel == 3 then
		x = - 4
	elseif starLevel == 4 then
		y = y + 10
	elseif starLevel == 5 then
		animationNodeSclae = 60
	end
	if node:getParent():getParent():getChildByName("node") then
		node:getParent():getParent():removeChildByName("node")
	end
	local path = "res/animation/StarLevel/StarLevel"..starLevel.."/StarLevel"..starLevel..".csb"
	if cc.FileUtils:getInstance():isFileExist(path) then
		local starNode
		if starLevel >= 3 then
			local animationNode, animationNoAni = gt.createCSAnimation(path)
			animationNode:setAnchorPoint(cc.p(0.5, 0.5))
			animationNode:setPosition(cc.p(node:getParent():getPositionX() + x, node:getParent():getPositionY() + y))
			node:getParent():getParent():addChild(animationNode, 999)
			animationNode:setName("node")
			if scale then
				animationNode:setScale(node:getContentSize().width/animationNodeSclae*m_fScale*scale)
			else
				animationNode:setScale(node:getContentSize().width/animationNodeSclae*m_fScale)
			end
			animationNoAni:play("run", true)
			starNode = animationNode
		else
			local csbNode = cc.CSLoader:createNode(path)
			csbNode:setAnchorPoint(cc.p(0.5, 0.5))
			csbNode:setPosition(cc.p(node:getParent():getPositionX() + x, node:getParent():getPositionY() + y))
			node:getParent():getParent():addChild(csbNode, 999)
			csbNode:setName("node")
			starNode = csbNode
		end

		self:showStarMJ(starNode, starLevel, node:getParent():getContentSize().height, starScale, starOffset)
	end
end

function UserInfo:showStarLevelMJNoClipping(node, starLevel, offset, starScale, starOffset)
	local animationNodeSclae = 80
	if starLevel == 5 then
		animationNodeSclae = 60
	end
	local path = "res/animation/StarLevel/StarLevel"..starLevel.."/StarLevel"..starLevel..".csb"
	if cc.FileUtils:getInstance():isFileExist(path) then
		if node:getChildByName("node") then
			node:removeChildByName("node")
		end
		local starNode
		if starLevel >= 3 then
			local animationNode, animationNoAni = gt.createCSAnimation(path)
			animationNode:setAnchorPoint(cc.p(0.5, 0.5))
			if starLevel == 4 then
				offset = 10
			else
				offset = 0
			end
			animationNode:setPosition(cc.p(node:getParent():getContentSize().width/2, node:getParent():getContentSize().height/2 + offset))
			node:getParent():addChild(animationNode, 999)
			animationNode:setName("node")
			animationNode:setScale(node:getParent():getContentSize().width/animationNodeSclae)
			animationNoAni:play("run", true)
			starNode = animationNode
		else
			local csbNode = cc.CSLoader:createNode(path)
			csbNode:setAnchorPoint(cc.p(0.5, 0.5))
			csbNode:setPosition(cc.p(node:getParent():getContentSize().width/2, node:getParent():getContentSize().height/2))
			node:getParent():addChild(csbNode, 999)
			csbNode:setName("node")
			starNode = csbNode
		end

		self:showStarMJ(starNode, starLevel, node:getParent():getContentSize().height, starScale, starOffset)
	end
end

return UserInfo


