
local gt = cc.exports.gt

local NoticeUpdateTipsClub = class("NoticeUpdateTipsClub", function()
	return gt.createMaskLayer()
end)

function NoticeUpdateTipsClub:ctor(data, callback)
	self:setName("NoticeUpdateTipsClub")

	local csbNode = cc.CSLoader:createNode("NoticeUpdateTipsClub.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	self.rootNode = csbNode
   	self.okFunc = okFunc
   	self.m_time = 0

	if data.force_upgrade == 1 then
		local cancelBtn = gt.seekNodeByName(csbNode, "Btn_cancel")
		cancelBtn:setVisible(false)
		local okBtn = gt.seekNodeByName(csbNode, "Btn_ok")
		okBtn:setPositionX(0)
	end

	if titleText then
		local titleLabel = gt.seekNodeByName(csbNode, "Label_title")
		titleLabel:setString(titleText)
	end

	if data.upgrade_hints then
		local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
		tipsLabel:setString(data.upgrade_hints)
	end
	
	local okBtn = gt.seekNodeByName(csbNode, "Btn_ok")
	gt.addBtnPressedListener(okBtn, function()
		local url = data.newest_download_url

		if gt.isIOSPlatform() then
			self.luaBridge = require("cocos/cocos2d/luaoc")
		elseif gt.isAndroidPlatform() then
			self.luaBridge = require("cocos/cocos2d/luaj")
		end
		if gt.isIOSPlatform() then
			local ok = self.luaBridge.callStaticMethod("AppController", "openWebURL", {webURL = url})
		elseif gt.isAndroidPlatform() then
			local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "openWebURL", {url}, "(Ljava/lang/String;)V")
		end
	end)

	local cancelBtn = gt.seekNodeByName(csbNode, "Btn_cancel")
	gt.addBtnPressedListener(cancelBtn, function()
		callback()
		self:onBack()
	end)

	local arrowSpr = gt.seekNodeByName(csbNode, "Spr_arrow")
	
    local updateNodeAction = cc.RepeatForever:create(
		cc.Sequence:create(
			cc.MoveBy:create(0.5, cc.p(0, 15)),
			cc.MoveBy:create(0.5, cc.p(0, -15))
		)
	)

	arrowSpr:runAction(updateNodeAction)

	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, 999)
	end
end

function NoticeUpdateTipsClub:update()
	-- local curTime = os.time()
	-- if curTime - self.m_onMainSceneTime > 3 then
		
	-- end
	self.m_time = self.m_time + 1
	if self.m_time < 3 then
		self.m_backMainTips:setString( (3-self.m_time) .."秒后自动回到大厅" )
	else
		if self.okFunc then
			self.okFunc()
		end
		self:onBack()
	end
end

function NoticeUpdateTipsClub:onBack()
	self:removeFromParent()
end

return NoticeUpdateTipsClub

