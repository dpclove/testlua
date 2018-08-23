
local gt = cc.exports.gt

local NoticeUpdateTips = class("NoticeUpdateTips", function()
	return gt.createMaskLayer()
end)

function NoticeUpdateTips:ctor(data, callback)
	self:setName("NoticeUpdateTips")

	local csbNode = cc.CSLoader:createNode("NoticeUpdateTips.csb")
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
		titleLabel:setVisible(false)
	end

	if data.upgrade_hints then
		local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
		gt.log("data...............",data.upgrade_hints)
		tipsLabel:setString(data.upgrade_hints)
		tipsLabel:setVisible(false)
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
			local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "removeApk", {"zypk"}, "(Ljava/lang/String;)Z")
			local runningScene = cc.Director:getInstance():getRunningScene()
			if runningScene then
				local node  = require("client/game/dialog/UpdateApk"):create(url)
				runningScene:addChild(node, gt.CommonZOrder.NOTICE_TIPS+1000)
			end
		end
	end)

	local cancelBtn = gt.seekNodeByName(csbNode, "Btn_cancel")
	gt.addBtnPressedListener(cancelBtn, function()
		callback()
		self:onBack()
	end)
    
	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS+999)
	end
end

function NoticeUpdateTips:update()
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

function NoticeUpdateTips:onBack()
	self:removeFromParent()
end

return NoticeUpdateTips

