
local gt = cc.exports.gt

local NoticeForSystemTips = class("NoticeForSystemTips", function()
	return gt.createMaskLayer()
end)

function NoticeForSystemTips:ctor(tipsText, fontSize)
	self:setName("NoticeForSystemTips")

	local csbNode = cc.CSLoader:createNode("NoticeForSystemTips.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	if tipsText then
		local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
		tipsLabel:setString(tipsText)
		if fontSize then
			self.fontSize = fontSize
			tipsLabel:setFontSize(fontSize)
		end
	end
	
	local okBtn = gt.seekNodeByName(csbNode, "Btn_ok")
	gt.addBtnPressedListener(okBtn, function()
        self:onBack()
	end)

	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS)
	end
end

function NoticeForSystemTips:onBack()
	self:removeFromParent()
end

return NoticeForSystemTips

