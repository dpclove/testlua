
local gt = cc.exports.gt
require("client/config/MJRules")

local PublicNoice = class("PublicNoice", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

-- 需要替换的颜色数组
local changeColorList = {"#7F7F7F","#391B0A"}
function PublicNoice:ctor(desc)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("PublicNoice.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
	local bg = gt.seekNodeByName(csbNode, "Img_bg")
	


	--desc = "新版好运来,好快,福利好多,好刺激! \n还有精彩活动，期待您的参与!!! 查看详情,请点击'好礼'图标."


	local text = gt.seekNodeByName(csbNode, "Label_notice")


	text:setString(desc)

	-- local playdeclist = {}
	
	-- table.insert(playdeclist,desc)

	-- local list = playdeclist
	-- gt.dump(list)	
	-- local agreementScrollVw = gt.seekNodeByName(bg, "ScrollView")
	-- local scrollVwSize = agreementScrollVw:getContentSize()
	-- local labelList = gt.createRichLabelEx(list,scrollVwSize.width-50)
	-- local posY = 0
 --    if scrollVwSize.height > labelList:getContentSize().height then
 --        posY = scrollVwSize.height
 --    else
 --         posY = labelList:getContentSize().height  
 --    end
 --    labelList:setPosition(30, posY)
 --    -- labelList:setPosition(scrollVwSize.width * 0.5, scrollVwSize.height - 30)
 --    local labelSize = labelList:getContentSize() 
	-- agreementScrollVw:addChild(labelList)


	---agreementScrollVw:setInnerContainerSize(cc.rect(0,0,20,20))
	
	-- 关闭按钮
	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:Remove()
	end)
end

function PublicNoice:Remove()
	self:removeFromParent()
end

function PublicNoice:onNodeEvent(eventName)
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

function PublicNoice:onTouchBegan(touch, event)
	return true
end

function PublicNoice:onTouchEnded(touch, event)
	local bg = gt.seekNodeByName(self.rootNode, "Img_bg")
	if bg then
		local point = bg:convertToNodeSpace(touch:getLocation())
		local rect = cc.rect(0, 0, bg:getContentSize().width, bg:getContentSize().height)
		if not cc.rectContainsPoint(rect, cc.p(point.x, point.y)) then
			self:removeFromParent()
		end
	end
end

-- 替换字色 (colorlist:需要替换的颜色数组)
function PublicNoice:changeColor(text,colorlist)
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
return PublicNoice



