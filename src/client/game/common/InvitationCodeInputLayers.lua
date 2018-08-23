
local gt = cc.exports.gt

local InvitationCodeInputLayers = class("InvitationCodeInputLayers", function()
	return gt.createMaskLayer()
end)

function InvitationCodeInputLayers:ctor()
	local csbNode = cc.CSLoader:createNode("InvitationCodeInputLayers.csb")
	--csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	-- 最大输入6个数字
	self.inputMaxCount = 6
	-- 数字文本
	self.inputNumLabels = {}
	self.curInputIdx = 1
	for i = 1, self.inputMaxCount do
		local numLabel = gt.seekNodeByName(csbNode, "Img_num_" .. i)
		numLabel:setVisible(false)
		self.inputNumLabels[i] = numLabel
	end

	-- 数字按键
	for i = 0, 9 do
		local numBtn = gt.seekNodeByName(csbNode, "Btn_num_" .. i)  --遍历数字按键
		numBtn:setTag(i)  --设置标记为0-9
		-- numBtn:addClickEventListener(handler(self, self.numBtnPressed))  --添加点击事件
		gt.addBtnPressedListener( numBtn, handler(self,self.numBtnPressed))
	end

	-- 重置按键
	local resetBtn = gt.seekNodeByName(csbNode, "Btn_reset")
	gt.addBtnPressedListener(resetBtn, function()
		for i = self.inputMaxCount, 1 , -1 do
			local numLabel = gt.seekNodeByName(csbNode, "Img_num_" .. i)
			numLabel:setVisible(false)
			--numLabel:setString("")
		end
		self.curInputIdx = 1  --光标设置在第一位
	end)

   -- 删除按键
	local delBtn = gt.seekNodeByName(csbNode, "Btn_del")
	gt.addBtnPressedListener(delBtn, function()
		for i = self.curInputIdx - 1, 1 , -1 do
			if self.curInputIdx - 1  >= 1 then
				local numLabel = gt.seekNodeByName(csbNode, "Img_num_" .. i)
				numLabel:setVisible(false)
				--numLabel:setString("")
				self.curInputIdx = self.curInputIdx - 1
			end
			break
		end
	end)

	-- 关闭按键
	local closeBtn = gt.seekNodeByName(csbNode, "close")
	gt.addBtnPressedListener(closeBtn, function()

		self:removeFromParent()
	end)
	--closeBtn:setVisible(true)

	-- gt.socketClient:registerMsgListener(gt.GC_JOIN_ROOM, self, self.onRcvInvitationCodeInputLayer)

	for i = 1 , 3 do
		self["node_"..i] = gt.seekNodeByName(csbNode, "Node_status"..i)
		if i == 2 then self["node_"..i]:setVisible(true) else self["node_"..i]:setVisible(false) end
	end


	gt.addBtnPressedListener(gt.seekNodeByName(csbNode, "bind_btn"), function()


        local runScene = cc.Director:getInstance():getRunningScene()
        gt.log("------------------------inviteID", inviteID)
        --提交邀请码
        Utils.commitInvite(self.inviteID, runScene, function( errno, msg )
			local RunningScene = cc.Director:getInstance():getRunningScene()
            Toast.showToast(RunningScene, msg, 2)
		    if errno == 0 then
	            self:closeLayer()
	        end
        end)
		
	end)

end

function InvitationCodeInputLayers:numBtnPressed(senderBtn)
	if self.curInputIdx == 7 then
		return
	end
	local btnTag = senderBtn:getTag()
	gt.log("current tag:",btnTag)
	local numLabel = self.inputNumLabels[self.curInputIdx]
	numLabel:loadTexture("join_room/"..btnTag..".png")
	numLabel:setTag(btnTag)
	numLabel:setVisible(true)
	gt.log(self.curInputIdx)
	gt.log(#self.inputNumLabels)
	if self.curInputIdx >= #self.inputNumLabels then
		local inviteID = 0
		local tmpAry = {100000, 10000, 1000, 100, 10, 1}
		for i = 1, self.inputMaxCount do
			local inputNum = tonumber(self.inputNumLabels[i]:getTag())
			inviteID = inviteID + inputNum * tmpAry[i]
		end
		self.inviteID = inviteID

		local xhr = cc.XMLHttpRequest:new()
		xhr:retain()
		xhr.timeout = 30 -- 设置超时时间
		xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
		local url = string.format(gt.chaxun, tostring(inviteID))
		gt.log(url)
		xhr:open("GET", gt.getUrlEncryCode(url, gt.playerData.uid))
		xhr:registerScriptHandler( function( )
			if xhr.readyState == 4 and xhr.status == 200 then
		       -- require("cjson")
		        local jstable = require("cjson").decode(xhr.response)
		        if type(jstable) == "table" then
		            gt.dump(jstable)
		            local errno = jstable["errno"]
		            local msg = jstable["errmsg"]
		            if errno ~= 0 then
		                for i =1 , 3 do
			        		if i == 3 then 
			        			self["node_"..i]:setVisible(true)
			        			

			        		else
			        			self["node_"..i]:setVisible(false)
			        		end
			        	end
		                return
		            end
		            local data = jstable["data"]
		        	local name = data.nickname or "nil"
		        	local id = data.user_id or "nil"
		        	for i =1 , 3 do
		        		if i == 1 then 
		        			self["node_"..i]:setVisible(true)
		        			gt.seekNodeByName(self["node_"..i],"Text_1"):setString("昵称："..name)
		        			gt.seekNodeByName(self["node_"..i],"Text_2"):setString("ID："..id)
		        			gt.seekNodeByName(self["node_"..i],"Text_3"):setString("邀请码："..tostring(inviteID))
		        		else
		        			self["node_"..i]:setVisible(false)
		        		end
		        	end
		        end
		    end
		    xhr:unregisterScriptHandler()
		end )
		xhr:send()

	end
	self.curInputIdx = self.curInputIdx + 1
end

function InvitationCodeInputLayers:closeLayer()
	gt.dispatchEvent("refreshMoney")
    self:removeFromParent()
end

function InvitationCodeInputLayers:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
	end
end

function InvitationCodeInputLayers:onTouchBegan(touch, event)
	return true
end

return InvitationCodeInputLayers

