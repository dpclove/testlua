
local gt = cc.exports.gt

local ClubPersonalCenter = class("ClubPersonalCenter", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function ClubPersonalCenter:ctor(playerData)
	gt.log("点击进入的")
	gt.dump(playerData)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("ClubPersonalCenter.csb")
	csbNode:setAnchorPoint(cc.p(0.5, 0.5))
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
 
	-- 头像
	local headSpr = gt.seekNodeByName(csbNode, "Spr_head")
	
	-- playerHeadMgr:attach(headSpr, parent, playerData.user_id, playerData.avatar, nil, nil, 100, true)
	-- playerHeadMgr:setScale(1.15)
	-- self:addChild(playerHeadMgr)

	self._remove = true

    local ispath = gt.imageNamePath(playerData.avatar)
    local icon = headSpr
    if ispath then
       local _node = display.newSprite("icon1.png")
       local image = gt.clippingImage(ispath,_node,false)
       
       csbNode:addChild(image)
       icon:setVisible(false)
       image:setPosition(icon:getPositionX(),icon:getPositionY())
    else
		

		if playerData.avatar ~= "" and  type(playerData.avatar) == "string" and string.len(playerData.avatar) >10 and display.getRunningScene() and display.getRunningScene().name == "MainScene" then
			local function callback(args)
				if self._remove  and self then
					if args.done then 
						gt.log("down________________")
						local _node = display.newSprite("icon1.png")
						local head = gt.clippingImage(args.image,_node,false)
						csbNode:addChild(head)
						
						icon:setVisible(false)
						head:setPosition(icon:getPositionX(),icon:getPositionY())
					end
				end
			end
			gt.downloadImage(playerData.avatar, callback)
		end
			
    end         

	-- 昵称
	local nicknameLabel = gt.seekNodeByName(csbNode, "Label_nickName")
	nicknameLabel:setString(playerData.name)
	-- ID
	local uidLabel = gt.seekNodeByName(csbNode, "Label_uid")
	uidLabel:setString("ID:" .. playerData.user_id)

	-- ip
	local ipLabel = gt.seekNodeByName(csbNode, "Label_ip")
	if playerData.ip then
		ipLabel:setString("IP:" .. playerData.ip)
	else
		ipLabel:setString("IP:未获取")
	end

	-- 单局最高分
	local scoreLabel = gt.seekNodeByName(csbNode, "Label_score")
	scoreLabel:setString("近10场单局最高分："..(playerData.score or ""))

	-- 胜率
	local winrateLabel = gt.seekNodeByName(csbNode, "Label_winrate")
	winrateLabel:setString("近10场胜率："..((playerData.win_rate or 0)*100).."%")
end

function ClubPersonalCenter:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		self._remove = false
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)

	end
end

function ClubPersonalCenter:onTouchBegan(touch, event)
	return true
end

function ClubPersonalCenter:onTouchEnded(touch, event)
	self._remove = false
	self:removeFromParent()
end

return ClubPersonalCenter