
	
local gt  = cc.exports.gt
local kefu = class("kefu",function()

	 return gt.createMaskLayer()
end)

function kefu:ctor(m)


	local csbNode = cc.CSLoader:createNode("kefu.csb")

	--gt.log("ccccc",csbNode,self)

	self:addChild(csbNode)
	--csbNode:setPosition(cc.p(0.6,0.5))


	local text = gt.seekNodeByName(csbNode, "Text_3")
	local weiXinKefu = ""
	if text then 

		local str = ""
		for i = 1 , #m do
			gt.log("m_________-")
			local tmp = "客服"..": "..m[i]
			weiXinKefu = m[i]
			str = str..tmp.."\n".."\n".."\n"
			-- str = str..tmp.."\n"
		end
		text:setString(str)
		
	end

	for i = 1 , 1 do 

		gt.addBtnPressedListener(csbNode:getChildByName("fuzhi_"..i), function ()
			-- local str = (i == 1 and "18853975009" or "18631553798")
			local str = weiXinKefu
			gt.log(str)
			gt.CopyText(str)
			require("client/game/dialog/NoticeTips"):create(
				"打开微信",
				"微信号已复制,请打开微信,添加朋友,粘贴微信号", function () 
						print("-------------------------点击打开微信")
						if gt.isIOSPlatform() then
							self.luaBridge = require("cocos/cocos2d/luaoc")
						elseif gt.isAndroidPlatform() then
							self.luaBridge = require("cocos/cocos2d/luaj")
						end

						if gt.isIOSPlatform() then
							local ok, ret = self.luaBridge.callStaticMethod("AppController", "openWXApp")
						elseif gt.isAndroidPlatform() then
							local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "openWXApp", nil, "()V")
						end
						-- body
					end, nil, true, nil, nil, nil, true, true)
		end)

	end

	local close = gt.seekNodeByName(csbNode, "close")

	gt.addBtnPressedListener(close, function()

		self:removeFromParent()


		end)

	local text_tip = gt.seekNodeByName(csbNode, "Text_2_0")
	if text_tip then
		text_tip:setVisible(false)
	end

end

return kefu