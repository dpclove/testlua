
local gt = cc.exports.gt

local NoticeTipsGetCoin = class("NoticeTipsGetCoin", function()
	return gt.createMaskLayer()
end)

function NoticeTipsGetCoin:ctor( tipsText, callback )
	self:setName("NoticeTipsGetCoin")

	local csbNode = cc.CSLoader:createNode("NoticeTipsGetCoin.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
	tipsLabel:setString(tipsText)
	
	local getCoinBtn = gt.seekNodeByName(csbNode, "Btn_getCoin")
	gt.addBtnPressedListener(getCoinBtn, function()
    	if callback then
			callback()
		end
	end)

	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:removeFromParent()
	end)

end

return NoticeTipsGetCoin

