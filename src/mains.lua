cc.FileUtils:getInstance():setPopupNotify(false)

local writePath = cc.FileUtils:getInstance():getWritablePath()
local resSearchPaths = {
	writePath,
	writePath .. "src_hyl/",
	writePath .. "src/",
	writePath .. "res/",
	writePath .. "res/",
	"src_hyl/",
	"src/",
	"res/",
	"res/"
}
cc.FileUtils:getInstance():setSearchPaths(resSearchPaths)

require "config"
require "cocos.init"


local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local function isIOSPlatform()
	return (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform)
end

local function isAndroidPlatform()
	return cc.PLATFORM_OS_ANDROID == targetPlatform
end

local function getAppVersion()

	local luaBridge = nil
	local ok, appVersion = nil
	if isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		ok, appVersion = luaBridge.callStaticMethod("AppController", "getVersionName")
	elseif isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		ok, appVersion = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")
	end

	local versionNumber = 0
	if isIOSPlatform() then
		versionNumber = tonumber(appVersion)
	elseif isAndroidPlatform() then
		local data = string.split(appVersion, ".")

		if data[1] then
			versionNumber = versionNumber + tonumber(data[1])*10
		end

		if data[2] then
			versionNumber = versionNumber + tonumber(data[2])
		end
	end

	return versionNumber
end


local function removefile(path)
	local function exists(path)
	    return cc.FileUtils:getInstance():isDirectoryExist(path)
	end

	local function rmdir(path)
	   
	    if exists(path) then
	    	
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


local function remove()


	if isIOSPlatform() or  isAndroidPlatform() then

		local newAppVersion = getAppVersion()
	    local oldAppVersion = cc.UserDefault:getInstance():getIntegerForKey("AppVersion", 0)

	    if newAppVersion > oldAppVersion then
			local writePath = cc.FileUtils:getInstance():getWritablePath()
			removefile(writePath .. "src_hyl")
			removefile(writePath .. "src_et")
			removefile(writePath .. "res")
			
			os.remove(writePath .. "project.manifest")
			os.remove(writePath .. "version.manifest")
			os.remove(writePath .. "version.manifest.upd")
			os.remove(writePath .. "project.manifest.upd")

	    end

   		cc.UserDefault:getInstance():setIntegerForKey("AppVersion", newAppVersion)

	end


end



local function main()


	-- local url = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"

	-- cc.UtilityExtension:DownloadImage(url,cc.UtilityExtension:generateMD5(url,string.len(url)))

	--print(-1%5)

	--print(string.byte(1))

	-- local FileName = cc.FileUtils:getInstance():getWritablePath() .. "Q.apk"

	-- local url = "http://apk.haoyunlaiyule2.com/add_sj.apk" 



	--cc.UtilityExtension:down_file(url,FileName)


	remove()

	--p--rint(cc.UtilityExtension:get_schedule())



    require("client.MyApp"):create():run()


end

cc.exports.__G__TRACKBACK__ = function (errorMessage)
    if buglyReportLuaException then
        buglyReportLuaException(tostring(errorMessage), debug.traceback())
    end

    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
