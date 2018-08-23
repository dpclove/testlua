local gt = cc.exports.gt

local LogoScene = class("LogoScene", function()
	return display.newScene("LogoScene")
end)


function LogoScene:ctor()
	-- 注册节点事件


	self:registerScriptHandler(handler(self, self.onNodeEvent))
end

function LogoScene:onNodeEvent(eventName)
	if "enter" == eventName then
		local function changeScene()
			local updateScene = require("client/game/common/UpdateScene"):create()
			cc.Director:getInstance():replaceScene(updateScene)
		end

		if gt.isAndroidPlatform() then
			local delayAction = cc.FadeIn:create(1)
			local fadeOutAction = cc.FadeOut:create(1)
			local callFunc = cc.CallFunc:create(function(sender)
				-- 动画播放完毕之后再走这些内容
				changeScene()

				-- 30s启动Lua垃圾回收器
				gt.scheduler:scheduleScriptFunc(function(delta)
					local preMem = collectgarbage("count")
					-- 调用lua垃圾回收器
					for i = 1, 3 do
						collectgarbage("collect")
					end
					local curMem = collectgarbage("count")
					-- gt.log(string.format("Collect lua memory:[%d] cur cost memory:[%d]", (curMem - preMem), curMem))
					local luaMemLimit = 30720
					if curMem > luaMemLimit then
						gt.log("Lua memory limit exceeded!")
					end
				end, 30, false)
			end)
			local seqAction = cc.Sequence:create(delayAction, fadeOutAction, callFunc)
			local logoSpr = cc.Sprite:create("res/background/sx_bg_splash.png")
			logoSpr:runAction(seqAction)
			self:addChild( logoSpr )
			logoSpr:setPosition( display.cx, display.cy )
		else
			-- if gt.localVersion then
			-- 	local loginScene = require("app/views/LoginScene"):create()
			-- 	cc.Director:getInstance():replaceScene(loginScene)
			-- else
			-- 	local updateScene = require("app/views/UpdateScene"):create()
			-- 	cc.Director:getInstance():replaceScene(updateScene)
			-- end
			if gt.isIOSPlatform() then 
				
				local node = cc.CSLoader:createNode("notnet.csb")
				self:addChild(node)
				node:setVisible(false)
				
				local function callback()

					local ok, res =  require("cocos/cocos2d/luaoc").callStaticMethod(
					"AppController", "getInternetStatus", nil)


					if res ==  "Not" then 
							node:setVisible(true)
					else
						node:setVisible(false)
							changeScene()
					end
				end

				callback()
				gt.addBtnPressedListener(gt.seekNodeByName(node,"Button_1"),function()

					callback()

					end)
				gt.addBtnPressedListener(gt.seekNodeByName(node,"exit"),function()

					os.exit()

					end)
			else
				
				changeScene()
			end
		
			-- 30s启动Lua垃圾回收器
			gt.scheduler:scheduleScriptFunc(function(delta)
				local preMem = collectgarbage("count")
				-- 调用lua垃圾回收器
				for i = 1, 3 do
					collectgarbage("collect")
				end
				local curMem = collectgarbage("count")
				-- gt.log(string.format("Collect lua memory:[%d] cur cost memory:[%d]", (curMem - preMem), curMem))
				local luaMemLimit = 30720
				if curMem > luaMemLimit then
					gt.log("Lua memory limit exceeded!")
				end
			end, 30, false)
		end
	end
end

return LogoScene


