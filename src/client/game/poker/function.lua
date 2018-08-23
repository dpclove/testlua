




local gt = cc.exports.gt

--gt.userSex = 1  


local function isJailBreak()
	if gt.isIOSPlatform() then
	   	local ok , res  = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "isJailBreak" )
	   	return ok and res or "NO"
	end
	return "NO"
end

gt.isJailBreak = isJailBreak

local function init_wx( id )


	local ok = false

	if not id then return false end

	if gt.isAndroidPlatform() then
	  	ok = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "initWx", {id}, "(Ljava/lang/String;)V")
	elseif gt.isIOSPlatform() then
	   	ok = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "init_wx",{wxid = id} )
	end
	-- body

	return ok

end

gt.init_wx = init_wx


local function get_devices()


 	if gt.isIOSPlatform() then
	 	local ok, device = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "iphoneType")
	 	if ok then  return device  else return "nil" end
	 elseif gt.isAndroidPlatform() then
	 	local ok, device = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "getDeivces", nil, "()Ljava/lang/String;")
	 	if ok then return device  else return "nil" end
	 end

end


gt.get_devices = get_devices

local function get_id()

	 if gt.isIOSPlatform() then
	 	gt.log("get___________1")
	 	local ok, id = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "getid")
	 	gt.log("get___________2")
	 	if ok then  return id or "" else return "" end
	 elseif gt.isAndroidPlatform() then
	 	local ok, id = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "getid", nil, "()Ljava/lang/String;")
	 	if ok then return id or "" else return "" end
	 end
	 return ""
	 
end

gt.get_id = get_id


-- set 成功放回 YES or NO
local function set_id(id)

	 if gt.isIOSPlatform() then
	 	gt.log("set___________!")
	 	require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "deleateid")
	 	gt.log("set___________2")
	 	local ok = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "setid", {userid = id} )
	 	if ok then  return true  else return false end
	 elseif gt.isAndroidPlatform() then
	 	local ok ,res  = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "setid", {tostring(id)}, "(Ljava/lang/String;)Z")
	 	if ok then return res  else return false end
	 end
	 return ""
end
gt.set_id = set_id


local function get_uuid()
	 if gt.isIOSPlatform() then
	 	local ok, uuid = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "getIMEI1")
	 	if ok then  return uuid or "" else return "" end
	 elseif gt.isAndroidPlatform() then
	 	local ok, uuid = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "getIMEI1", nil, "()Ljava/lang/String;")
	 	if ok then return uuid or "" else return "" end
	 end
	 return "mac"
end
gt.get_uuid = get_uuid

local function get_dianliang()

	 if gt.isIOSPlatform() then
	 	local ok, dianliang = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "dianliang")
	 	if ok then return dianliang or -1 else return -1 end
	 elseif gt.isAndroidPlatform() then
	 	local ok, dianliang = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "dianliang", nil, "()I")
	 	if ok then return dianliang or -1 else return -1 end
	 end
	 return "mac"
end

gt.get_dianliang = get_dianliang


local function install_apk(name)


	 if gt.isAndroidPlatform() then
	 	require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "install_apk", {name}, "(Ljava/lang/String;)V")
	 end

end

gt.install_apk = install_apk


local function downloadApk(url,name)

	 if gt.isAndroidPlatform() then
	 	require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "downloadApk", {url,name}, "(Ljava/lang/String;Ljava/lang/String;)V")
	 end

end
gt.downloadApk = downloadApk


local function getBytesAndStatus()

	 if gt.isAndroidPlatform() then
	 	local ok ,res = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "getBytesAndStatus", nil, "()Ljava/lang/String;")
	 	gt.log("res......",res)
	 	if ok then 
	 		return string.split(res, "|")[1] , string.split(res, "|")[2] , string.split(res, "|")[3]
	 	else 
	 		return "err"
	 	end
	 end

	 return "err"

end

gt.getBytesAndStatus = getBytesAndStatus



local function clippingImage(imageName, stencilNode,inverted)
	if not imageName or not stencilNode then return false end
	local clippingNode = cc.ClippingNode:create(stencilNode)
	clippingNode:setInverted(inverted) --设置是显示被裁剪的部分，还是显示裁剪。true 显示剩余部分。false显示被剪掉部分

	clippingNode:setAlphaThreshold(0.9)--设置绘制底板的Alpha值为0
	local sprite
	if display.newSprite_http then 
		 sprite = display.newSprite_http(imageName)
	else
		 sprite = display.newSprite(imageName)
	end
	if not sprite then sprite = display.newSprite("icon1.png") cc.FileUtils:getInstance():removeFile(imageName) end 
	local idageR = sprite:getContentSize().width
	local stencilNodeR = stencilNode:getContentSize().width
	sprite:setScale(stencilNodeR/idageR)
	clippingNode:addChild(sprite)
	return clippingNode
end


gt.clippingImage = clippingImage

local function imageNamePath(url)

	if  url == "" or url == nil then return false end
	local name = string.gsub(url, "[/.:+]", "")
 	local fullFileName = cc.FileUtils:getInstance():getWritablePath() .. name..".png"
	if  cc.FileUtils:getInstance():isFileExist(fullFileName) then
		return fullFileName
	else
		return false
	end

end

gt.imageNamePath = imageNamePath


local function is_FileExist(name)

	if name then 
		local fullFileName = cc.FileUtils:getInstance():getWritablePath() .. name
		if  cc.FileUtils:getInstance():isFileExist(fullFileName) then
			return name.."文件存在!"
		else
			return name.."文件不存在!"
		end
	end
end

gt.is_FileExist = is_FileExist


local function include(path)

	if not path then return end
	return require("client/game/poker/"..path)

end

gt.include = include

local function include(moduleName,currentModuleName)

	if not moduleName  then return end

	currentModuleName = currentModuleName or "client/game/poker/"

	return require(currentModuleName..moduleName)

end
gt.include = include


local function _scale(node,num)
	if not node then return end
	num = num or 1 
	node:setScaleX((1280/1334.00)*num)
	node:setScaleY((720/750)*num)
end
gt._scale = _scale

local function downloadImage(url, callback)
	if url == "" or url == nil then return end
	local imgType = math.random()
	if string.len(url)<5 then
		print("图片地址错误 "..url)
		callback({done=false})
		return
		
	end
	--print(string.gsub(url, "[/.:+]", ""))
	local xhr = cc.XMLHttpRequest:new()
	xhr._urlFileName = os.time()
	local name,_ = string.gsub(url, "[/.:+]", "")
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url)
	local function onDownloadImage()
	   
	    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	        local fileData = xhr.response
	        local fullFileName = cc.FileUtils:getInstance():getWritablePath() .. name..".png"
	        --local fullFileName = cc.FileUtils:getInstance():getWritablePath() .. xhr._urlFileName.."."..imgType
	        local file = io.open(fullFileName,"wb")
	        file:write(fileData)
	        --file:close()
	        io.close(file)
	       
	        if io.type(file) == "closed file" then
	        	
	        	callback({done=true, image=fullFileName})
	        else  
	        	log("close_________",io.type(file))
	        	callback({done=false})
	 
	       	end
	       	-- local texture2d = cc.Director:getInstance():getTextureCache():addImage(fullFileName)

	        -- if texture2d then
	        -- 	callback({done=true, image=texture2d,tex = fullFileName})
	       	-- else
	        -- 	callback({done=false})
	        -- end
	       	-- os.remove (fullFileName)
    else
	    	callback({done=false})
	    end
	end
	xhr:registerScriptHandler(onDownloadImage)
	xhr:send()
end
gt.downloadImage = downloadImage

local  function setOnViewClickedListener(view,listener,carom,effect)
	if not carom then
		carom = 0
	end
	
	-- if type(view) == "string" then
	-- 	view = findNodeByName(view, parent)
	-- end
	if not view or type(view) == "string" then
		return
	end
	local effect = effect or "?"
	
	view:setTouchEnabled(true)
	view.lastClickTime = 0
	view.oriScale = view:getScale()
	local viewType = tolua.type(view)
	if string.find(viewType, "ccui%.") then --cocos ui

		view:addTouchEventListener(function(sender, eventType)
			if eventType == 0 then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()-3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale*0.95)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()-3)
					end
				end
			elseif eventType == 2 then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
			

				if math.abs(os.clock() - view.lastClickTime) > carom then
					view.lastClickTime = os.clock()
					--gt.soundEngine:playEffect("common/audio_button_click", false)
					listener(view)
				end
			elseif eventType ~= 1 then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
	        end
		end)
	else -- quick ui 以cc.开头

		view:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
		view:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			if event.name == "began" then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()-3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale*0.95)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()-3)
					end
				end
			elseif event.name == "ended" then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
				
				if math.abs(os.clock() - view.lastClickTime) > carom and cc.rectContainsPoint(view:getCascadeBoundingBox(), cc.p(event.x, event.y)) then
					view.lastClickTime = os.clock()
					--gt.soundEngine:playEffect("common/audio_button_click", false)
					listener(view)
				end
			elseif event.name == "cancelled" then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
	        end
	    	return true
	    end)
	end
end

gt.setOnViewClickedListener = setOnViewClickedListener

local  function setOnViewClickedListeners(view,listener,carom,effect)
	if not carom then
		carom = 0
	end
	
	-- if type(view) == "string" then
	-- 	view = findNodeByName(view, parent)
	-- end
	if not view or type(view) == "string" then
		return
	end
	local effect = effect or "zoom"
	
	view:setTouchEnabled(true)
	view.lastClickTime = 0
	view.oriScale = view:getScale()
	local viewType = tolua.type(view)
	if string.find(viewType, "ccui%.") then --cocos ui

		view:addTouchEventListener(function(sender, eventType)
			if eventType == 0 then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()-3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale*0.95)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()-3)
					end
				end
			elseif eventType == 2 then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
			

				if math.abs(os.clock() - view.lastClickTime) > carom then
					view.lastClickTime = os.clock()
					gt.soundEngine:playEffect("common/audio_button_click", false)
					listener(view)
				end
			elseif eventType ~= 1 then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
	        end
		end)
	else -- quick ui 以cc.开头

		view:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
		view:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			if event.name == "began" then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()-3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale*0.95)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()-3)
					end
				end
			elseif event.name == "ended" then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
				
				if math.abs(os.clock() - view.lastClickTime) > carom and cc.rectContainsPoint(view:getCascadeBoundingBox(), cc.p(event.x, event.y)) then
					view.lastClickTime = os.clock()
					gt.soundEngine:playEffect("common/audio_button_click", false)
					listener(view)
				end
			elseif event.name == "cancelled" then
				if effect == "trans" then
					view:setPositionY(view:getPositionY()+3)
				elseif effect == "zoom" then
					view:setScale(view.oriScale)
				elseif effect == "transinner" then
					for i,v in ipairs(view:getChildren()) do
						v:setPositionY(v:getPositionY()+3)
					end
				end
	        end
	    	return true
	    end)
	end
end

gt.setOnViewClickedListeners = setOnViewClickedListeners

gt.poker_node = {}
gt.poker_node1 = {}
for i = 1 , 56 do
	gt.poker_node[i] = "poker_ddz/"..i..".png"
end

for i = 1 , 56 do
	gt.poker_node1[i] = "poker_ddz1/"..i..".png"
end

gt.poker_node_sj = {}

for i = 1 , 56 do
	gt.poker_node_sj[i] = "poker_sj/"..i..".png"
end


-- addchid node 节点 防止 闪退
local function addNode(parent,child,zorder,tag)
	if parent and not tolua.isnull(parent) and child and not tolua.isnull(child) then 
		if tag then
	        parent:addChild(child, zorder, tag)
	    elseif zorder then
	        parent:addChild(child, zorder)
	    else
	        parent:addChild(child)
    	end
    	return true
	end
	return false
end
gt.addNode = addNode



local function tonumber(num)  -- 10 12 24   (10 12 30) 

	if not num then return end
	local a =  num--tonumber(num, 10)
	
	if a>0 and a <= 13 then --1 - 13
		return a 
	elseif a >13 and a <= 29 then -- 14 - 26
		return (a - 3)
	elseif a >29 and a <= 45 then -- 27 - 39
		return (a - 6)
	elseif a > 45 and a <= 61 then -- 40 - 52
		return (a - 9)
	elseif a == 78 then
		return 53
	elseif a == 79 then
		return 54
	elseif a == 65 then
		return 55
	elseif a == 67 or a == 0 then
		return 56
	else
		return 0
	end
end

gt.tonumber = tonumber



gt.INVALID_CHAIR = 21


--- yl  globale 

cc.exports.yl = {}
local yl = cc.exports.yl


yl.GAMEDATA = {}

-- 逻辑数值
yl.POKER_VALUE = {}
-- 逻辑花色
yl.POKER_COLOR = {}
-- 纹理花色
yl.CARD_COLOR = {}
yl.PokerId = {}

yl.WIDTH = 1280
yl.HEIGHT = 720

local poker_data = 
{
	0x00,
	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, -- 方块 1 - 13
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, -- 梅花 17 - 29
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, -- 红桃 33 - 45
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, -- 黑桃 49 - 61
    0x4E, 0x4F, 0x41, 0x43                                                        -- 大王， 小王 花牌 牌背 78 79 65 67
} 

for k,v in pairs(poker_data) do
	
	if v == 65 then
		yl.POKER_VALUE[v] = 16
		yl.POKER_COLOR[v] = bit._and(v , 0XF0)
		yl.CARD_COLOR[v] = math.floor(v / 16)
	else
		yl.POKER_VALUE[v] = math.mod(v, 16)
		yl.POKER_COLOR[v] = bit._and(v , 0XF0)
		yl.CARD_COLOR[v] = math.floor(v / 16)
	end
	yl.PokerId[v] = k
end

local function add_switch_card( card )
		
	
	for i = 1 , #card do
		for j = i + 1 , #card do
			if card[i] == card[j] then 
				card[j] = card[j] + 100
			end
		end
	end
	
	return card
end
yl.add_switch_card = add_switch_card


local function switch_card(card)

	local tmp = 0 
	local buf = {}
	for i = 1 , #card do
		if card[i] > 100 then 
			tmp = card[i] - 100
		else
			tmp = card[i]
		end
		buf[i] = tmp
	end
	return buf
end
yl.switch_card = switch_card


--注册touch事件
local function registerTouchEvent( node, bSwallow )
	if nil == node then
		return false
	end
	local function onNodeEvent( event )
		gt.log("event.....",event)
		if event == "enter" and nil ~= node.onEnter then
			node:onEnter()
		elseif event == "enterTransitionFinish" then
			--注册触摸
			local function onTouchBegan( touch, event )
				if nil == node.onTouchBegan then
					return false
				end
				return node:onTouchBegan(touch, event)
			end

			local function onTouchMoved(touch, event)
				if nil ~= node.onTouchMoved then
					node:onTouchMoved(touch, event)
				end
			end

			local function onTouchEnded( touch, event )
				if nil ~= node.onTouchEnded then
					node:onTouchEnded(touch, event)
				end       
			end

			local listener = cc.EventListenerTouchOneByOne:create()
			bSwallow = bSwallow or false
			listener:setSwallowTouches(bSwallow)
			node._listener = listener
		    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
		    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
		    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
		    --listener:setSwallowTouches(false)
		    local eventDispatcher = node:getEventDispatcher()
		    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

			if nil ~= node.onEnterTransitionFinish then
				node:onEnterTransitionFinish()
			end
		elseif event == "exitTransitionStart" 
			and nil ~= node.onExitTransitionStart then
			node:onExitTransitionStart()
		elseif event == "exit" and nil ~= node.onExit then	
			if nil ~= node._listener then
				local eventDispatcher = node:getEventDispatcher()
				eventDispatcher:removeEventListener(node._listener)
			end			

			if nil ~= node.onExit then
				node:onExit()
			end
		elseif event == "cleanup" and nil ~= node.onCleanup then
			node:onCleanup()
		end
	end
	node:registerScriptHandler(onNodeEvent)
	return true
end

yl.registerTouchEvent = registerTouchEvent