
local gt = cc.exports.gt

local ClubCommitApplyTips = class("ClubCommitApplyTips", function()
	return gt.createMaskLayer()
end)

function ClubCommitApplyTips:ctor(callback)
	self.callback = callback
	self:setName("ClubCommitApplyTips")

	local csbNode = cc.CSLoader:createNode("ClubCommitApplyTips.csb")
	csbNode:setAnchorPoint(cc.p(0.5,0.5))
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	if tipsText then
		local tipsLabel = gt.seekNodeByName(csbNode, "Label_notice")
		tipsLabel:setString(tipsText)
		if fontSize then
			self.fontSize = fontSize
			tipsLabel:setFontSize(fontSize)
		end
	end
	
	local enterBtn = gt.seekNodeByName(csbNode, "Btn_enter")
	gt.addBtnPressedListener(enterBtn, function()
        self:onBack()
        self:removeFromParent()
	end)

	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS)
	end
end

function ClubCommitApplyTips:onBack()
 	if self.callback then
 		self.callback()
 	end
end

return ClubCommitApplyTips

