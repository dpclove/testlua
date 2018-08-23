
local gt = cc.exports.gt

local NoticeTipsShareDownload = class("NoticeTipsShareDownload", function()
	return gt.createMaskLayer()
end)

function NoticeTipsShareDownload:ctor(NoticeTipsType, tipsText, callbackdownload, callbackshareWX, callbacksharePYQ)
	self:setName("NoticeTipsShareDownload")

	local csbNode = cc.CSLoader:createNode("NoticeTipsShareDownload.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
	tipsLabel:setString(tipsText)
	
	-- 微信好友
	local shareWXBtn = gt.seekNodeByName(csbNode, "Btn_shareWX")
	gt.addBtnPressedListener(shareWXBtn, function()
    	if callbackshareWX then
			callbackshareWX()
		end
	end)

	-- 分享朋友圈
	local sharePYQBtn = gt.seekNodeByName(csbNode, "Btn_sharePYQ")
	gt.addBtnPressedListener(sharePYQBtn, function()
    	if callbacksharePYQ then
			callbacksharePYQ()
		end
	end)

	-- 下载最新版
	local downloadnewversionBtn = gt.seekNodeByName(csbNode, "Btn_downloadnewversion")
	gt.addBtnPressedListener(downloadnewversionBtn, function()
    	if callbackdownload then
			callbackdownload()
		end
	end)

	-- 直接下载
	local downloadimmediatBtn = gt.seekNodeByName(csbNode, "Btn_downloadimmediate")
	gt.addBtnPressedListener(downloadimmediatBtn, function()
    	if callbackdownload then
			callbackdownload()
		end
	end)

	local xiaoshouSpr = gt.seekNodeByName(csbNode, "Spr_xiaoshou")

	local share1Node = gt.seekNodeByName(csbNode, "Node_share1")
	local share2Node = gt.seekNodeByName(csbNode, "Node_share2")
	local share3Node = gt.seekNodeByName(csbNode, "Node_share3")
	
	if NoticeTipsType == 0 then
		share1Node:setVisible(true)
		share2Node:setVisible(false)
		share3Node:setVisible(false)
		xiaoshouSpr:setVisible(false)
	elseif NoticeTipsType == 1 then
		share1Node:setVisible(false)
		share2Node:setVisible(true)
		share3Node:setVisible(false)
		xiaoshouSpr:setVisible(true)

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
	elseif NoticeTipsType == 2 then
		share1Node:setVisible(false)
		share2Node:setVisible(false)
		share3Node:setVisible(true)
		xiaoshouSpr:setVisible(true)

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
	end

	local closeBtn = gt.seekNodeByName(share1Node, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:getParent():removeFromParent()
	end)

	local closeBtn = gt.seekNodeByName(share2Node, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:getParent():removeFromParent()
	end)

	local closeBtn = gt.seekNodeByName(share3Node, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:removeFromParent()
	end)
end

return NoticeTipsShareDownload

