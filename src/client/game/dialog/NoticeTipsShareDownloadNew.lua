
local gt = cc.exports.gt

local NoticeTipsShareDownloadNew = class("NoticeTipsShareDownloadNew", function()
	return gt.createMaskLayer()
end)

function NoticeTipsShareDownloadNew:ctor(tipsText, callbackdownload)
	self:setName("NoticeTipsShareDownloadNew")

	local csbNode = cc.CSLoader:createNode("NoticeTipsShareDownloadNew.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	gt.log("-----------------tipsText", tipsText)
	local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
	tipsLabel:setString(tipsText)
	
	-- 直接下载
	local downloadimmediatBtn = gt.seekNodeByName(csbNode, "Btn_downloadimmediate")
	gt.addBtnPressedListener(downloadimmediatBtn, function()
    	if callbackdownload then
			callbackdownload()
		end
	end)

	local xiaoshouSpr = gt.seekNodeByName(csbNode, "Spr_xiaoshou")

	local NodeAction = cc.RepeatForever:create(
		cc.Sequence:create(
			cc.CallFunc:create(function()
				xiaoshouSpr:setOpacity(255)
			end),
			cc.MoveBy:create(0.5, cc.p(0, 25)),
			cc.MoveBy:create(0.5, cc.p(0, -25)),
			cc.FadeTo:create(0.5, 180),
			cc.FadeTo:create(0.5, 255)
		)
	)
	xiaoshouSpr:runAction(NodeAction)

	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:removeFromParent()
	end)
end

return NoticeTipsShareDownloadNew

