
local gt = cc.exports.gt
require("client/config/MJRules")

local ClubNotice = class("ClubNotice", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

-- 需要替换的颜色数组
local changeColorList = {"#7F7F7F","#391B0A"}
function ClubNotice:ctor(clubData)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("ClubNotice.csb")
	csbNode:setAnchorPoint(cc.p(0.5, 0.5))
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

	--会长头像
	local headSpr = gt.seekNodeByName(csbNode, "Spr_head")
	local headLayout = gt.seekNodeByName(csbNode, "Head_layout")
	local playerHeadMgr = require("client/tools/PlayerHeadManager"):create()
	playerHeadMgr:attach(headSpr, headLayout, clubData.owner_id, clubData.avatar, nil, nil, 100, true)
	self:addChild(playerHeadMgr)
	
	-- 会长名字
	local nickNameLabel = gt.seekNodeByName(csbNode, "Label_nickName")
	nickNameLabel:setString(clubData.owner_name)

	-- 公会公告
	local noticeLabel = gt.seekNodeByName(csbNode, "Label_notice")
	noticeLabel:setString(clubData.notice)

	-- 确定按钮
	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:Remove()
	end)
end

function ClubNotice:Remove()
	self:removeFromParent()
end

function ClubNotice:onNodeEvent(eventName)
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

function ClubNotice:onTouchBegan(touch, event)
	return true
end

function ClubNotice:onTouchEnded(touch, event)
	-- local bg = gt.seekNodeByName(self.rootNode, "Img_bg")
	-- if bg then
	-- 	local point = bg:convertToNodeSpace(touch:getLocation())
	-- 	local rect = cc.rect(0, 0, bg:getContentSize().width, bg:getContentSize().height)
	-- 	if not cc.rectContainsPoint(rect, cc.p(point.x, point.y)) then
			self:removeFromParent()
	-- 	end
	-- end
end

-- 替换字色 (colorlist:需要替换的颜色数组)
function ClubNotice:changeColor(text,colorlist)
	local index = 1
	local i = 1
	local mText = text
	local len = #mText
	-- gt.log(" 替换字色")
	-- gt.log("Info 11 "..mText)
	while i <= len do
		local chr = string.byte(mText, i)
		if chr == string.byte("#") then
			local color_str = string.sub(mText, i, i + 6)
			mText = string.gsub(mText,color_str,colorlist[index])
			index = index + 1
		end 
		i = i + 1
	end
	-- gt.log("Info  22 "..mText)
	return mText
end
return ClubNotice



