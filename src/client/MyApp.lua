require("cocos/init")
require("cocos/framework/init")

require("client/tools/UtilityTools")
require("client/config/StringUtil")
require("client/tools/Toast")



local gt = cc.exports.gt
local MyApps = class("MyApps", cc.load("mvc").AppBase)

function MyApps:ctor()
	gt.setRandomSeed()
	if device.platform ~= "windows" and device.platform ~= "mac" then
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",
									handler(self, self.onEnterBackground))
		eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
		local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
									handler(self, self.onEnterForeground))
		eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)
	end


	-- 音效引擎
	gt.soundEngine = require("client/tools/Sound"):create()

	cc.Device:setKeepScreenOn(true)
end

function MyApps:run()
	if device.platform ~= "windows" and device.platform ~= "mac" then
	    local newAppVersion = gt.getAppVersion()
	    local oldAppVersion = cc.UserDefault:getInstance():getIntegerForKey("AppVersion", 0)

	    if newAppVersion > oldAppVersion then
			local writePath = cc.FileUtils:getInstance():getWritablePath()
			self:removefile(writePath .. "src_hyl")
			self:removefile(writePath .. "src_et")
			self:removefile(writePath .. "res")



			
			-- os.remove(writePath .. "project.manifest")
			-- os.remove(writePath .. "version.manifest")
			-- os.remove(writePath .. "version.manifest.upd")
			-- os.remove(writePath .. "project.manifest.upd")
			
			-- package.loaded["client.MyApp"] = nil
			-- package.loaded["client/tools/UtilityTools"] = nil
			-- package.loaded["client/config/StringUtil"] = nil
			-- package.loaded["client/tools/Toast"] = nil

	    end

   		cc.UserDefault:getInstance():setIntegerForKey("AppVersion", newAppVersion)
	end

	--require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "initFile", nil, "()Z")
	
	gt.log("news_________")
	local loginScene = require("client/game/common/LogoScene"):create()
	cc.Director:getInstance():replaceScene(loginScene)

	-- if gt.localVersion then
	-- 	local loginScene = require("app/views/LoginScene"):create()
	-- 	cc.Director:getInstance():replaceScene(loginScene)
	-- else
	-- 	local updateScene = require("app/views/UpdateScene"):create()
	-- 	cc.Director:getInstance():runWithScene(updateScene)
	-- end

	-- -- 30s启动Lua垃圾回收器
	-- gt.scheduler:scheduleScriptFunc(function(delta)
	-- 	local preMem = collectgarbage("count")
	-- 	-- 调用lua垃圾回收器
	-- 	for i = 1, 3 do
	-- 		collectgarbage("collect")
	-- 	end
	-- 	local curMem = collectgarbage("count")
	-- 	gt.log(string.format("Collect lua memory:[%d] cur cost memory:[%d]", (curMem - preMem), curMem))
	-- 	local luaMemLimit = 30720
	-- 	if curMem > luaMemLimit then
	-- 		gt.log("Lua memory limit exceeded!")
	-- 	end
	-- end, 30, false)


end


function MyApps:onEnterBackground()
	gt.soundEngine:pauseAllSound()
end

function MyApps:onEnterForeground()
	gt.soundEngine:resumeAllSound()


	--gt.log("time.....",os.date("%H"))

	-- 发送心跳，判断链接是否已经断开
	if gt.socketClient then
		
		gt.resume_time = 1
		gt.socketClient:sendHeartbeat(true)
	end
end

function MyApps:removefile(path)
	local function exists(path)
	    return cc.FileUtils:getInstance():isDirectoryExist(path)
	end

	local function rmdir(path)
	    gt.dumploglogin("path", path)
	    if exists(path) then
	    	gt.dumploglogin("exists", path)
	        local function _rmdir(path)
	            local iter, dir_obj = lfs.dir(path)
	         
	            while true do
	                local dir = iter(dir_obj)
	            	
	                if dir == nil then break end
	            	
	                if dir ~= "." and dir ~= ".." then
	                    local curDir = ""

					    if device.platform == "windows" then
					    	curDir = path.."\\"..dir
					    else
					    	curDir = path.."/"..dir
					    end

		            	

	                    local mode = lfs.attributes(curDir, "mode") 
		            	
	                    if mode == "directory" then
						    if device.platform == "windows" then
		                        _rmdir(curDir.."\\")
						    else
		                        -- _rmdir(curDir.."/")
		                        _rmdir(curDir)
						    end
	                    elseif mode == "file" then
	                        local result = os.remove(curDir)
	                    end
	                end
	            end
	            local success, des = lfs.rmdir(path)
	 
	            if des then print(des) end
	            return success
	        end
	        _rmdir(path)
	    end
	    return true
	end

	rmdir(path)
end

return MyApps
