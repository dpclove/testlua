
local gt = cc.exports.gt

local NoticeTipsCommon = class("NoticeTipsCommon", function()
	return gt.createMaskLayer()
end)

function NoticeTipsCommon:ctor(tipsType, tipsText, okFunc, cancelFunc, schedule)
	
	self:setName("NoticeTipsCommon")



	local csbNode = cc.CSLoader:createNode("NoticeTipsCommon.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	self.rootNode = csbNode
   	self.okFunc = okFunc
   	self.m_onMainSceneTime = os.time()
   	self.m_time = 0

   	local okBtn = gt.seekNodeByName(csbNode, "Btn_ok")
	local cancelBtn = gt.seekNodeByName(csbNode, "Btn_cancel")
	local confirmBtn = gt.seekNodeByName(csbNode, "Btn_confirm")
	--用户需要决策
	if tipsType == 1 then
		okBtn:setVisible(true);
		gt.addBtnPressedListener(okBtn, function()
	        self:onBack()
	    	if okFunc then
				okFunc()
			end
		end)
		cancelBtn:setVisible(true)
		gt.addBtnPressedListener(cancelBtn, function()
			self:onBack()
	    	if cancelFunc then
				cancelFunc()
			end
		end)
		confirmBtn:setVisible(false)
	else--只是提示
		okBtn:setVisible(false);
		cancelBtn:setVisible(false)
		confirmBtn:setVisible(true)
		gt.addBtnPressedListener(confirmBtn, function()
	        self:onBack()
	    	if okFunc then
				okFunc()
			end
		end)
	end

	if tipsText then
		local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
		tipsLabel:setString(tipsText)
	end
    
	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS)
	end

	if schedule then
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 1, false)
	end
	gt.log("NoticeTipsCommon ctor")
end

function NoticeTipsCommon:update()
	-- local curTime = os.time()
	-- if curTime - self.m_onMainSceneTime > 3 then
		
	-- end
	self.m_time = self.m_time + 1
	if self.m_time < 3 then
		--self.m_backMainTips:setString( (3-self.m_time) .."秒后自动回到大厅" )
	else
		if self.okFunc then
			self.okFunc()
		end
		self:onBack()
	end
end

function NoticeTipsCommon:onBack()
	if self.scheduleHandler then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end	
	self:removeFromParent()
end

return NoticeTipsCommon

