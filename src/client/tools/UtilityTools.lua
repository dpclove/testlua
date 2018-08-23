-- Creator ArthurSong
-- Create Time 2015/8/21


cc.exports.gt = {
	layersStack = {},
	eventsListener = {},
	playerData = {},

	-- 苹果平台在审核状态,显示游客登录按钮
	isInReview = false,

	csw_app_store = false,

	-- 调试模式
	debugMode = true,
	-- 本地版本直接跳过UpdateScene
	-- 测试服务器
	localVersion = true,
	
	-- 是否为测试部门使用的包
	isDebugPackage = false,

	-- debug模式状态表
	debugInfo ={ip = "101.201.104.28", port = "6101"},

	fontNormal = "res/fonts/DFYuanW7-GB2312.ttf",
	winSize = cc.Director:getInstance():getWinSize(),
	scheduler = cc.Director:getInstance():getScheduler(),
	targetPlatform = cc.Application:getInstance():getTargetPlatform(),

	-- 遮挡层透明度值
	MASK_LAYER_OPACITY			= 85,

	audioAppID = "1001086", --"1000975",
	-- 语音路径
	audioPath = cc.FileUtils:getInstance():getWritablePath().."xiongmao.amr",
	-- 语音初始化路径
	audioIntPath = cc.FileUtils:getInstance():getWritablePath(),
	gameType = "mj"

}
gt.winCenter = cc.p(gt.winSize.width * 0.5, gt.winSize.height * 0.5)

local _print = false
if cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() or  cc.PLATFORM_OS_MAC == cc.Application:getInstance():getTargetPlatform() then
	_print = true
end


local function isIOSPlatform()
	return (cc.PLATFORM_OS_IPHONE == gt.targetPlatform) or (cc.PLATFORM_OS_IPAD == gt.targetPlatform)
end
gt.isIOSPlatform = isIOSPlatform

local function isAndroidPlatform()
	return cc.PLATFORM_OS_ANDROID == gt.targetPlatform
end
gt.isAndroidPlatform = isAndroidPlatform

-- start --
--------------------------------
-- @class function pushLayer
-- @description 用于界面有压栈层关系处理
-- @param layer 要压入的层
-- @param visible 当前层是否需要隐藏,默认是隐藏
-- @param zorder 压入层z值
-- @param rootLayer 压入层要加入到的父层
-- @return
-- end --
local function pushLayer(layer, visible, rootLayer, zorder)
	local layersStack = gt.layersStack
	local curLayer = layersStack[#layersStack]
	if curLayer and not visible then
		curLayer:setVisible(false)
	end

	-- 插入到栈顶
	table.insert(layersStack, layer)

	local zorder = zorder or 1
	if rootLayer then
		rootLayer:addChild(layer, zorder)
	else
		local runningScene = display.getRunningScene()
		if runningScene then
			runningScene:addChild(layer, zorder)
		end
	end
end
gt.pushLayer = pushLayer

-- start --
--------------------------------
-- @class function popLayer
-- @description 弹出当前层,从父节点移除,调用lua的destroy析构函数
-- @return
-- end --
local function popLayer()
	local layersStack = gt.layersStack
	if #layersStack > 0 then
		-- 从栈顶移除
		local layer = table.remove(layersStack, #layersStack)
		if layer then
			layer:removeFromParent(true)
			if layer.destroy then
				layer:destroy()
			end
		end

		-- 显示栈顶层
		local curLayer = layersStack[#layersStack]
		if curLayer then
			curLayer:setVisible(true)
		end
	end
end
gt.popLayer = popLayer

-- start --
--------------------------------
-- @class function registerEventListener
-- @description 注册事件回调
-- @param eventType 事件类型
-- @param target 实例
-- @param method 方法
-- @return
-- gt.registerEventListener(2, self, self.eventLis)
-- end --
local function registerEventListener(eventType, target, method)
	if not eventType or not target or not method then
		return
	end

	local eventsListener = gt.eventsListener
	local listeners = eventsListener[eventType]
	if not listeners then
		-- 首次添加eventType类型事件，新建消息存储列表
		listeners = {}
		eventsListener[eventType] = listeners
	else
		-- 检查重复添加
		for _, listener in ipairs(listeners) do
			if listener[1] == target and listener[2] == method then
				return
			end
		end
	end
	-- 加入到事件列表中
	local listener = {target, method}
	table.insert(listeners, listener)
end
gt.registerEventListener = registerEventListener

-- start --
--------------------------------
-- @class function dispatchEvent
-- @description 分发eventType事件
-- @param eventType 事件类型
-- @param ... 调用者传递的参数
-- @return
-- end --
local function dispatchEvent(eventType, ...)
	if not eventType then
		return
	end
	local listeners = gt.eventsListener[eventType] or {}
	for _, listener in ipairs(listeners) do
		-- 调用注册函数
		print("dispatch_eventType=="..tostring(eventType))
		listener[2](listener[1], eventType, ...)
	end
end
gt.dispatchEvent = dispatchEvent

-- start --
--------------------------------
-- @class function removeTargetEventListenerByType
-- @description 移除target注册的事件
-- @param target self
-- @param eventType 消息类型
-- @return
-- end --
local function removeTargetEventListenerByType(target, eventType)
	if not target or not eventType then
		return
	end

	-- 移除target的注册的eventType类型事件
	local listeners = gt.eventsListener[eventType] or {}
	for i, listener in ipairs(listeners) do
		if listener[1] == target then
			table.remove(listeners, i)
		end
	end
end
gt.removeTargetEventListenerByType = removeTargetEventListenerByType

-- start --
--------------------------------
-- @class function removeTargetAllEventListener
-- @description 移除target的注册的全部事件
-- @param target self
-- @return
-- end --
local function removeTargetAllEventListener(target)
	if not target then
		return
	end

	-- 移除target注册的全部事件
	for _, listeners in pairs(gt.eventsListener) do
		for i, listener in ipairs(listeners) do
			if listener[1] == target then
				table.remove(listeners, i)
			end
		end
	end
end
gt.removeTargetAllEventListener = removeTargetAllEventListener

-- start --
--------------------------------
-- @class function removeAllEventListener
-- @description 移除全部消息注册回调
-- @return
-- end --
local function removeAllEventListener()
	gt.eventsListener = {}
end
gt.removeAllEventListener = removeAllEventListener

-- start --
--------------------------------
-- @class function
-- @description 加载csb文件,遍历查找Label和Button设置设定的语言文本
-- @param csbFileName 文件名称
-- @return 创建的节点
-- end --
local function createCSNode(csbFileName, isScale)
	local csbNode = cc.CSLoader:createNode(csbFileName)

	if isScale then
		csbNode:setScale(gt.scaleFactor)
	end

	-- 检查是否符合规定写法名称Label_xxx_key Txt_xxx_key
	local function setSpecifyLabelString(labelName, specifyLable)
		local subStrs = string.split(labelName, "_")
		local prefix = subStrs[1]
		local suffix = subStrs[#subStrs]
		if prefix == "Label" or prefix == "Txt" then
			local strKey = "LTKey_" .. suffix
			local ltString = gt.getLocationString(strKey)
			if ltString ~= strKey then
				-- 本地语言字符串存在设置文本
				specifyLable:setString(ltString)
			end
		end
	end

	-- 遍历节点
	local function travelLabelNode(rootNode)
		if not rootNode then
			return
		end

		local nodeName = rootNode:getName()
		setSpecifyLabelString(nodeName, rootNode)

		local children = rootNode:getChildren()
		if not children or #children == 0 then
			return
		end
		for _, childNode in ipairs(children) do
			travelLabelNode(childNode)
		end

		return
	end

	-- travelLabelNode(csbNode)

	return csbNode
end
gt.createCSNode = createCSNode

-- start --
--------------------------------
-- @class function createCSAnimation
-- @description 创建csb文件编辑的动画
-- @param csbFileName 文件路径名称
-- @return node, action 创建的节点和动画
-- end --
local function createCSAnimation(csbFileName, isScale)
	local csbNode = cc.CSLoader:createNode(csbFileName)
	local action = cc.CSLoader:createTimeline(csbFileName)
	csbNode:runAction(action)
	if isScale then
		csbNode:setScale(gt.scaleFactor)
	end
	return csbNode, action
end
gt.createCSAnimation = createCSAnimation

-- start --
--------------------------------
-- @class function seekNodeByName
-- @description 深度遍历查找节点
-- @param rootNode 根节点
-- @param nodeName 查找节点名称
-- @return 查找到的节点
-- end --
local function seekNodeByName(rootNode, name)
	if not rootNode or not name then
		return nil
	end

	if rootNode:getName() == name then
		return rootNode
	end

	local children = rootNode:getChildren()
	if not children or #children == 0 then
		return nil
	end
	for i, parentNode in ipairs(children) do
		local childNode = seekNodeByName(parentNode, name)
		if childNode then
			return childNode
		end
	end

	return nil
end
gt.seekNodeByName = seekNodeByName

local function showLoadingTips(tipsText)
	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		local loadingTips = runningScene:getChildByName("LoadingTips")
		if loadingTips then
			loadingTips:show(tipsText)
			return
		end
	end

	require("client/game/common/LoadingTips"):create(tipsText)
end
gt.showLoadingTips = showLoadingTips

local function removeLoadingTips()
	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		local loadingTips = runningScene:getChildByName("LoadingTips")
		if loadingTips then
			loadingTips:removeFromParent()
		end
	end
end
gt.removeLoadingTips = removeLoadingTips

local function showLoadingFZRecordTips(tipsText)
	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		local loadingTips = runningScene:getChildByName("LoadingFZRecordTips")
		if loadingTips then
			loadingTips:show(tipsText)
			return
		end
	end

	require("client/game/common/LoadingFZRecordTips"):create(tipsText)
end
gt.showLoadingFZRecordTips = showLoadingFZRecordTips

local function removeLoadingFZRecordTips()
	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		local loadingTips = runningScene:getChildByName("LoadingFZRecordTips")
		if loadingTips then
			loadingTips:removeFromParent()
		end
	end
end
gt.removeLoadingFZRecordTips = removeLoadingFZRecordTips

-- start --
--------------------------------
-- @class function
-- @description 获取节点的世界坐标
-- @param node 节点
-- @return 世界坐标
-- end --
local function getWorldPos(node)
	if not node:getParent() then
		return cc.p(node:getPosition())
	end

	local nodeList = {}
	while node do
		-- 遍历节点,存储所有父节点
		table.insert(nodeList, node)
		node = node:getParent()
	end
	-- 移除Scene节点/世界坐标是基于Scene节点
	table.remove(nodeList, #nodeList)

	local worldPosition = cc.p(0, 0)
	for i, node in ipairs(nodeList) do
		local nodePosition = cc.p(node:getPosition())
		local idx = i + 1
		if idx <= #nodeList then
			-- 累加父节点锚点相对位置
			local parentNode = nodeList[idx]
			local parentSize = parentNode:getContentSize()
			local parentAnchor = parentNode:getAnchorPoint()
			local anchorPosition = cc.p(parentSize.width * parentAnchor.x, parentSize.height * parentAnchor.y)
			local subPosition = cc.pSub(nodePosition, anchorPosition)
			worldPosition = cc.pAdd(worldPosition, subPosition)
		else
			-- +最后父节点位置
			worldPosition = cc.pAdd(worldPosition, nodePosition)
		end
	end

	return worldPosition
end
gt.getWorldPos = getWorldPos

-- start --
--------------------------------
-- @class function
-- @description 创建ttfLabel
-- @param text 文本内容
-- @param fontSize 字体大小
-- @param font 字体名称
-- @return ttfLabel
-- end --
local function createTTFLabel(text, fontSize, font)
	text = text or ""
	font = font or gt.fontNormal
	fontSize = fontSize or 18

	local ttfConfig = {}
	ttfConfig.fontFilePath = font
	ttfConfig.fontSize = fontSize
	local ttfLabel = cc.Label:createWithTTF(ttfConfig, text, cc.TEXT_ALIGNMENT_LEFT)

	return ttfLabel
end
gt.createTTFLabel = createTTFLabel

-- start --
--------------------------------
-- @class function
-- @description 文本描边颜色outline
-- @param ttfLabel 要被设置描边的文本控件
-- @param color cc.c4b颜色
-- @param size int像素Size
-- @return
-- end --
local function setTTFLabelStroke(ttfLabel, color, size)
	if not ttfLabel then
		return
	end

	color = color or cc.c4b(27, 27, 27, 255)
	size = size or 1

	ttfLabel:enableOutline(color, size)
end
gt.setTTFLabelStroke = setTTFLabelStroke

-- start --
--------------------------------
-- @class function
-- @description 文本阴影
-- @param ttfLabel 要被设置阴影的文本控件
-- @param color cc.c4b颜色
-- @param offset Size偏移量cc.size(2, -2)
-- @return
-- end --
local function setTTFLabelShadow(ttfLabel, color, offset)
	if not ttfLabel then
		return
	end

	ttfLabel:enableShadow(color, offset, 0)
end
gt.setTTFLabelShadow = setTTFLabelShadow

-- start --
--------------------------------
-- @class function
-- @description 统一打印日志
-- @param msg 日志信息
-- @return
-- end --
local function log(msg, ...)
	if not _print then return end
	
	if not msg then return end
	msg = msg .. " "
	local args = {...}
	for i,v in ipairs(args) do
		msg = msg .. tostring(v) .. " "
	end
	--print(os.date("%Y-%m-%d %H:%M:%S") .. "------lua log:" .. msg)
	--print(msg)
	--print(msg)
	
	
	-- -- 01 02 09 10 19 32 16 
	-- if device.platform == "mac" then 
	-- 	print(msg)
	-- else
	-- require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "androidLog" ,{ tostring(msg) },"(Ljava/lang/String;)V")
	-- end
	-- llog(msg)

	if gt.isAndroidPlatform() then
		require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "androidLog" ,{ tostring(msg) },"(Ljava/lang/String;)V")
	else
		print(msg)
	end

end
gt.log = log


local function android_log(msg,...)

	if msg == nil then
		return
	end
	
	msg = msg .. " "
	local args = {...}
	for i,v in ipairs(args) do
		msg = msg .. tostring(v) .. " "
	end

	require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "androidLog" ,{ msg },"(Ljava/lang/String;)V")

end
gt.a_log = android_log

local function setLogPanelVisible(isVisible)
	-- debug模式屏幕日志信息
	if not gt.logDetailPanel then
		local logDetailPanel = gt.createCSNode("LogPanel.csb")
		logDetailPanel:retain()
		local viewSize = logDetailPanel:getContentSize()
		logDetailPanel:setAnchorPoint(0, 0.5)
		logDetailPanel:setPosition(0, gt.winSize.height * 0.5)
		local scrollView = gt.seekNodeByName(logDetailPanel, "SclVw_log")
		scrollView:setSwallowTouches(false)
		gt.logDetailPanel = logDetailPanel
		gt.logHeight = viewSize.height
	end

	if not gt.logDetailPanel:getParent() then
		local runningScene = display.getRunningScene()
		if runningScene then
			runningScene:addChild(gt.logDetailPanel, 69)
		end
	end

	gt.logDetailPanel:setVisible(isVisible)
end
gt.setLogPanelVisible = setLogPanelVisible

-- start --
--------------------------------
-- @class function
-- @description 用当前时间反置设置随机数种子
-- @return
-- end --
local function setRandomSeed()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
end
gt.setRandomSeed = setRandomSeed

-- start --
--------------------------------
-- @class function
-- @description 获取 [minVar, maxVar] 区间随机值
-- @param minVar 最小值
-- @param maxVar 最大值
-- @return 区间随机值
-- end --
local function getRangeRandom(minVar, maxVar)
	if minVar == maxVar then
		return minVar
	end

	return math.floor((math.random() * 1000000)) % (maxVar - minVar + 1) + minVar
end
gt.getRangeRandom = getRangeRandom

-- start --
--------------------------------
-- @class function
-- @description 重载cocos提供的弧度转换角度
-- @param radian 弧度
-- @return 角度
-- end --
function math.radian2angle(radian)
	return radian * 57.29577951
end

-- start --
--------------------------------
-- @class function
-- @description 重载cocos提供的角度转换弧度
-- @param angle 角度
-- @return 弧度
-- end --
function math.angle2radian(angle)
	return angle * 0.01745329252
end

function string.lastString(input, pattern)
	local idx = 1
	local saveIdx = nil
	while true do
		idx = string.find(input, pattern, idx)
		if idx == nil then
			break
		else
			saveIdx = idx
			idx = idx + 1
		end
	end

	return saveIdx
end


-- start --
--------------------------------
-- @class function
-- @description 震动节点
-- @param node 震动节点
-- @param time 持续时间
-- @param originPos 节点原始位置,为了防止多次shake后节点位置错位
-- @return
-- end --
local function shakeNode(node, time, originPos, offset)
	local duration = 0.03
	if not offset then
		offset = 6
	end
	-- 一个震动耗时4个duration左,复位,右,复位
	-- 同时左右和上下震动
	local times = math.floor(time / (duration * 4))
	local moveLeft = cc.MoveBy:create(duration, cc.p(-offset, 0))
	local moveLReset = cc.MoveBy:create(duration, cc.p(offset, 0))
	local moveRight = cc.MoveBy:create(duration, cc.p(offset, 0))
	local moveRReset = cc.MoveBy:create(duration, cc.p(-offset, 0))
	local horSeq = cc.Sequence:create(moveLeft, moveLReset, moveRight, moveRReset)
	local moveUp = cc.MoveBy:create(duration, cc.p(0, offset))
	local moveUReset = cc.MoveBy:create(duration, cc.p(0, -offset))
	local moveDown = cc.MoveBy:create(duration, cc.p(0, -offset))
	local moveDReset = cc.MoveBy:create(duration, cc.p(0, offset))
	local verSeq = cc.Sequence:create(moveUp, moveUReset, moveDown, moveDReset)
	node:runAction(cc.Sequence:create(cc.Repeat:create(cc.Spawn:create(horSeq, verSeq), times), cc.CallFunc:create(function()
		node:setPosition(originPos)
	end)))
end
gt.shakeNode = shakeNode

-- start --
--------------------------------
-- @class function
-- @description 给BUTTON注册触屏事件
-- @param btn 注册按钮
-- @param listener 注册事件回调
-- @param sfxType DefineConfig里面gt.BtnSfxType定义
-- @param scale 相对放缩值1.0+scale
-- end --
local function addBtnPressedListener(btn, listener, sfxType, scale)
	if not btn or not listener then
		return
	end

	btn:addClickEventListener(function(sender)
		listener(sender)

		-- 点击音效
		--[[
		local btnSfxTbl = {"default", "back", "close", "tab", "get", "use", "intensify"}
		if not sfxType then
			sfxType = gt.BtnSfxType.DEFAULT
		end
		local btnSfxName = btnSfxTbl[sfxType]
		if not btnSfxName then
			btnSfxName = btnSfxTbl[1]
		end
		btnSfxName = "btn_" .. btnSfxName
		Sound.playEffect(btnSfxName)
		--]]
		gt.soundEngine:playEffect("common/audio_button_click", false)
	end)

	if not scale then
		scale = -0.1
	end
	if scale then
		-- local traceback = string.split(debug.traceback("", 2), "\n")
		-- print("addBtnPressedListener from: " .. string.trim(traceback[3]))
		-- 点击放缩
		btn:setPressedActionEnabled(true)
		btn:setZoomScale(scale)
	end
end
gt.addBtnPressedListener = addBtnPressedListener


-- start --
--------------------------------
-- @class function
-- @description 创建shader
-- @param shaderName 名称
-- @return 创建的shaderState
-- end --
local function createShaderState(imageview, isgray)
	-- 默认vert  
	local vertDefaultSource = "\n"..  
	                           "attribute vec4 a_position; \n" ..  
	                           "attribute vec2 a_texCoord; \n" ..  
	                           "attribute vec4 a_color; \n"..                                                      
	                           "#ifdef GL_ES  \n"..  
	                           "varying lowp vec4 v_fragmentColor;\n"..  
	                           "varying mediump vec2 v_texCoord;\n"..  
	                           "#else                      \n" ..  
	                           "varying vec4 v_fragmentColor; \n" ..  
	                           "varying vec2 v_texCoord;  \n"..  
	                           "#endif    \n"..  
	                           "void main() \n"..  
	                           "{\n" ..  
	                            "gl_Position = CC_PMatrix * a_position; \n"..  
	                           "v_fragmentColor = a_color;\n"..  
	                           "v_texCoord = a_texCoord;\n"..  
	                           "}"
	-- 置灰frag  
	local pszGrayShader = "#ifdef GL_ES \n" ..  
	                          "precision mediump float; \n" ..  
	                            "#endif \n" ..  
	                            "varying vec4 v_fragmentColor; \n" ..  
	                            "varying vec2 v_texCoord; \n" ..  
	                            "void main(void) \n" ..  
	                            "{ \n" ..  
	                            "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..  
	                            "float gray = dot(c.rgb, vec3(0.299, 0.587, 0.114)); \n" ..  
	                            "gl_FragColor.xyz = vec3(gray); \n"..  
	                            "gl_FragColor.w = c.w; \n"..  
	                            "}"
	-- 移除置灰frag  
	local pszRemoveGrayShader = "#ifdef GL_ES \n" ..  
	        "precision mediump float; \n" ..  
	        "#endif \n" ..  
	        "varying vec4 v_fragmentColor; \n" ..  
	        "varying vec2 v_texCoord; \n" ..  
	        "void main(void) \n" ..  
	        "{ \n" ..  
	        "gl_FragColor = texture2D(CC_Texture0, v_texCoord); \n" ..  
	        "}"

    local pProgram = nil
	if isgray then
    	pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszGrayShader)
	else
    	pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszRemoveGrayShader)
	end  
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)  
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)  
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)  
    pProgram:link()  
    pProgram:updateUniforms()  
  
    -- ImageView  
    -- imageview:getVirtualRenderer():getSprite():setGLProgram(pProgram) 
    imageview:setGLProgram(pProgram)  

	return imageview
end
gt.createShaderState = createShaderState

-- start --
--------------------------------
-- @class function
-- @description 弹出panel节点的动画效果
-- @param panel 要进行动画展示的节点
-- @return
-- end --
local function popupPanelAnimation(panel, cbFunc)
	assert(panel, "panel should not be nil.")
	local nowScale = panel:getScale()
	panel:setScale(0)
	local action = cc.ScaleTo:create(0.2, nowScale)
	action = cc.EaseBackOut:create(action)
	if not cbFunc then
		panel:runAction(action)
	else
		local callFunc = cc.CallFunc:create(cbFunc)
		local seqAction = cc.Sequence:create(action, callFunc)
		panel:runAction(seqAction)
	end
end
gt.popupPanelAnimation = popupPanelAnimation

-- start --
--------------------------------
-- @class function
-- @description 隐藏panel节点的动画效果，同时remove掉panel所在的父节点
-- @param panel 要进行动画隐藏效果的节点
-- @param parentMaskLayer 要进行remove操作的panel的父节点
-- @return
-- end --
local function removePanelAnimation(panel, parentMaskLayer, isHide)
	assert(panel and parentMaskLayer, "panel and parentMaskLayer should not be nil.")
	local action = cc.ScaleTo:create(0.2, 0)
	action = cc.EaseBackIn:create(action)
	local sequence = cc.Sequence:create(action, cc.CallFunc:create(function()
		if isHide then
			parentMaskLayer:setVisible(false)
		else
			parentMaskLayer:removeFromParent(true)
		end
	end))
	panel:runAction(sequence)
end
gt.removePanelAnimation = removePanelAnimation

-- start --
--------------------------------
-- @class function
-- @description 创建触摸屏蔽层
-- @param opacity 触摸屏的透明图
-- @return 屏蔽层
-- end --
local function createMaskLayer(opacity)
	if not opacity then
		-- 用默认透明度
		opacity = gt.MASK_LAYER_OPACITY
	end

	local maskLayer = cc.LayerColor:create(cc.c4b(85, 85, 85, opacity), gt.winSize.width, gt.winSize.height)
	-- local function onTouchBegan(touch, event)
	-- 	print("touche__________begin")
	-- 	return true
	-- end
	-- local listener = cc.EventListenerTouchOneByOne:create()
	-- listener:setSwallowTouches(true)
	-- listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	-- local eventDispatcher = maskLayer:getEventDispatcher()
	-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, maskLayer)

	return maskLayer
end
gt.createMaskLayer = createMaskLayer

-- start --
--------------------------------
-- @class function
-- @description 获取蒙版剪切精灵
-- @param sprFrameName 需要剪切图片的名称
-- @param isCircle 圆形或者矩形,默认是矩形
-- @return
-- end --
local function getMaskClipSprite(sprFrameName, isCircle, frameAdapt)
	local frameSpr = cc.Sprite:createWithSpriteFrameName(sprFrameName)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("images/ui/icon/icon_mask.plist")
	local maskName = "rect_icon_mask.png"
	if isCircle then
		maskName = "circle_icon_mask.png"
	end
	local clipMaskSpr = cc.Sprite:createWithSpriteFrameName(maskName)
	local maskSize = clipMaskSpr:getContentSize()
	if frameAdapt then
		local frameSize = frameSpr:getContentSize()
		frameSpr:setScale(maskSize.width / frameSize.width)
	end
	frameSpr:setPosition(maskSize.width * 0.5, maskSize.height * 0.5)
	clipMaskSpr:setPosition(maskSize.width * 0.5, maskSize.height * 0.5)
	local renderTexture = cc.RenderTexture:create(maskSize.width, maskSize.height)
	clipMaskSpr:setBlendFunc(cc.blendFunc(gl.ZERO, gl.SRC_ALPHA))
	renderTexture:begin()
	frameSpr:visit()
	clipMaskSpr:visit()
	renderTexture:endToLua()
	local clipSpr = cc.Sprite:createWithTexture(renderTexture:getSprite():getTexture())
	clipSpr:setScaleY(-1)
	return clipSpr
end
gt.getMaskClipSprite = getMaskClipSprite

-- start --
--------------------------------
-- @class function
-- @description 创建扫光动态效果精灵
-- @param targetSpr 目标精灵
-- @param lightSpr 光柱精灵
-- @return 扫光动态效果精灵
-- end --
local function createTraverseLightSprite(targetSpr, lightSpr)
	targetSpr:removeFromParent()
	targetSpr:setPosition(0, 0)
	lightSpr:removeFromParent()
	lightSpr:setPosition(0, 0)
	local clippingNode = cc.ClippingNode:create()
	clippingNode:setStencil(targetSpr)
	clippingNode:setAlphaThreshold(0)

	local contentSize = targetSpr:getContentSize()
	clippingNode:addChild(targetSpr:clone())
	lightSpr:setPosition(-contentSize.width * 0.5,0)
	clippingNode:addChild(lightSpr)

	local moveAction = cc.MoveTo:create(1, cc.p(contentSize.width, 0))
	local delayTime = cc.DelayTime:create(1)
	local callFunc = cc.CallFunc:create(function(sender)
		sender:setPosition(-contentSize.width, 0)
	end)
	local sequenceAction = cc.Sequence:create(moveAction, delayTime, callFunc)
	local repeatAction = cc.RepeatForever:create(sequenceAction)
	lightSpr:runAction(repeatAction)

	return clippingNode
end
gt.createTraverseLightSprite = createTraverseLightSprite

-- start --
--------------------------------
-- @class function
-- @description 是否在屏幕上显示,遍历父节点有隐藏的情况
-- @return false:隐藏 true:显示
-- end --
local function isDisplayVisible(node)
	while node do
		if not node:isVisible() then
			return false
		end

		node = node:getParent()
	end

	return true
end
gt.isDisplayVisible = isDisplayVisible

-- start --
--------------------------------
-- @class function
-- @description 为避免货币位数过多导致显示不下，修改数字格式
-- @param num 要换算的数字，应为数字型
-- @return 1,000,000及以上的数字显示以K为单位换算后的字符串，1,000,000以下仍返回原值
-- end --
local function convertNumberForShort(num)
	assert(type(num) == "number", "the parameter should be numeric.")
	if num < 1000000 then
		return num
	else
		return math.floor(num * 0.001) .. "K"
	end
end
gt.convertNumberForShort = convertNumberForShort

-- start --
--------------------------------
-- @class function
-- @description 将时间以"HH:MM:SS"或者"MM:SS"的格式返回，不满两位填充0
-- @param deltaTime 要被转化的时间，以秒为单位；应为数字型，正负数皆可
-- @return 格式化的时间，字符串形式
-- end --
local function convertTimeSpanToString(deltaTime)
	assert(type(deltaTime) == "number", "the parameter should be numeric.")

	-- 那必须先四舍五入取整，否则会出现 -00：00：00 的情况
	deltaTime = math.round(deltaTime)

	local timeConversion = 60

	local timePrefix = ""
	if deltaTime < 0 then
		timePrefix = "-"
		deltaTime = -deltaTime
	end

	local hStr = math.floor(deltaTime / (timeConversion * timeConversion))
	deltaTime = deltaTime - timeConversion * timeConversion * hStr
	local mStr = math.floor(deltaTime / timeConversion)
	local sStr = math.floor(deltaTime - timeConversion * mStr)

	if hStr == 0 then
		return string.format("%s%02s:%02s", timePrefix, mStr, sStr)
	end

	return string.format("%s%02s:%02s:%02s", timePrefix, hStr, mStr, sStr)
end
gt.convertTimeSpanToString = convertTimeSpanToString

-- start --
--------------------------------
-- @class function
-- @description 将本地时间以字符串的格式返回
-- @param deltaTime 目标时间与当前本地时间的差值。单位秒，正数为未来，负数为过去
-- @return 格式化的时间，字符串形式，AM/PM+HH:MM:SS
-- end --
local function getLocalTimeSpanStr(deltaTime)
	if not deltaTime then deltaTime = 0 end

	local targetTime = os.time() + deltaTime
	local timeTbl = os.date("*t", targetTime)

	if timeTbl.hour > 12 then
		return string.format("PM %02d:%02d:%02d", timeTbl.hour - 12, timeTbl.min, timeTbl.sec)
	else
		return string.format("AM %02d:%02d:%02d", timeTbl.hour, timeTbl.min, timeTbl.sec)
	end
end
gt.getLocalTimeSpanStr = getLocalTimeSpanStr

local function dump_value_(v)
	if type(v) == "string" then
		v = "\"" .. v .. "\""
	end
	return tostring(v)
end

function dump(value, desciption, nesting)
	-- if 1 == 1 then return end
	if not _print then return end
	
	-- if 1 == 1 then return end
	if type(nesting) ~= "number" then nesting = 6 end

	local lookupTable = {}
	local result = {}

	local traceback = string.split(debug.traceback("", 2), "\n")
	gt.log("dump from: " .. string.trim(traceback[3]))

	local function dump_(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
		elseif lookupTable[tostring(value)] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
		else
			lookupTable[tostring(value)] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
			else
				result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = dump_value_(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					dump_(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end
	dump_(value, desciption, "- ", 1)

	for i, line in ipairs(result) do
		gt.log(line)
	end
end
gt.dump = dump


local function err_dump(value, desciption, nesting)
	

	if not gt.DEBUG then return "" end

	

	if type(nesting) ~= "number" then nesting = 6 end

	local lookupTable = {}
	local result = {}

	local traceback = string.split(debug.traceback("", 2), "\n")
	gt.log("dump from: " .. string.trim(traceback[3]))

	local function dump_(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
		elseif lookupTable[tostring(value)] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
		else
			lookupTable[tostring(value)] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
			else
				result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = dump_value_(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					dump_(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end
	dump_(value, desciption, "- ", 1)

	local a = ""
	for i, line in ipairs(result) do
		--gt.log(line)
		a = a..line
	end
	print("aaaaaaa",a)
	return a

end
gt.err_dump = err_dump


local function dump1(value, desciption, nesting)
	if not _print then return end
	

	if type(nesting) ~= "number" then nesting = 6 end

	local lookupTable = {}
	local result = {}

	local traceback = string.split(debug.traceback("", 2), "\n")
	gt.log("dump from: " .. string.trim(traceback[3]))

	local function dump_(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
		elseif lookupTable[tostring(value)] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
		else
			lookupTable[tostring(value)] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
			else
				result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = dump_value_(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					dump_(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end
	dump_(value, desciption, "- ", 1)

	for i, line in ipairs(result) do
		gt.log(line)
	end
end
gt.dump1 = dump1


local function dumplog(value, desciption, nesting)

	
	-- if 1 == 1 then return end
	if not _print then return end

	if type(nesting) ~= "number" then nesting = 6 end

	local lookupTable = {}
	local result = {}

	local traceback = string.split(debug.traceback("", 2), "\n")
	gt.log("dump from: " .. string.trim(traceback[3]))

	local function dump_(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
		elseif lookupTable[tostring(value)] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
		else
			lookupTable[tostring(value)] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
			else
				result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = dump_value_(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					dump_(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end


	if gt.curCircle == nil or gt.curCircle == 0 then

		return
	end

	gt.uploadFileName = (gt.playerData.uid or "0").."_"..(gt.deskId or "0").."_"..(gt.curCircle or "0").."_"..(os.date("%m-%d-%H", os.time()) or "0")..".testlog"

	if value == nil then
		gt.openFile("a")
		gt.upFile("nil")
		-- dump_(value, desciption, "- ", 1)
	-- elseif value == "clear" then
	-- 	gt.openFile("w")
	-- 	gt.upFile("clear")
	else
		dump_(value, desciption, "- ", 1)
		gt.openFile("a")
		gt.upFile(os.date("%Y-%m-%d_%H:%M:%S", os.time())..",".. (gt.playerData.uid or "gt.playerData.uid")..","..(gt.playerSeatIdx or "gt.playerSeatIdx"))
		local content = ""
		for i, line in ipairs(result) do
			-- content = content..line.."\n"
			gt.upFile(line)
		end
	end
	-- gt.closeFile()
	gt.log("inst_________________")
	table.insert(gt.timerWriteLogTable, gt.uploadtext)
end
gt.dumplog = dumplog


local function dumplog_nn(value, desciption, nesting)
	if true then return end
	if type(nesting) ~= "number" then nesting = 6 end

	local lookupTable = {}
	local result = {}

	local traceback = string.split(debug.traceback("", 2), "\n")
	gt.log("dump from: " .. string.trim(traceback[3]))

	local function dump_(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
		elseif lookupTable[tostring(value)] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
		else
			lookupTable[tostring(value)] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
			else
				result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = dump_value_(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					dump_(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end


	if gt.curCircle == nil or gt.curCircle == 0 then
		return
	end

	gt.uploadFileName = (gt.playerData.uid or "0").."_"..(gt.deskId or "0").."_"..(gt.curCircle or "0").."_"..(os.date("%m-%d-%H", os.time()) or "0")..".testlog"

	if value == nil then
		gt.openFile("a")
		gt.upFile("nil")
		-- dump_(value, desciption, "- ", 1)
	-- elseif value == "clear" then
	-- 	gt.openFile("w")
	-- 	gt.upFile("clear")
	else
		dump_(value, desciption, "- ", 1)
		gt.openFile("a")
		gt.upFile(os.date("%Y-%m-%d_%H:%M:%S", os.time())..",".. (gt.playerData.uid or "gt.playerData.uid"))
		local content = ""
		for i, line in ipairs(result) do
			-- content = content..line.."\n"
			gt.upFile(line)
		end
	end
	-- gt.closeFile()
	gt.log("inst_________________")
	table.insert(gt.timerWriteLogTable, gt.uploadtext)
end
gt.dumplog_nn = dumplog_nn

local function createDirectory(directory)
 --    --判断路径是否存在
	-- if cc.FileUtils:getInstance():isDirectoryExist(directory) == false then
 --        --创建目录
	-- 	cc.FileUtils:getInstance():createDirectory(directory)
	-- end
end
gt.createDirectory = createDirectory

-- local function writeFileLog(_content)
-- 	local _filePath = cc.FileUtils:getInstance():getWritablePath()..(gt.uploadFileName or "gt.uploadFileName.testlog")
--     if gt.isIOSPlatform() then
--         local luaBridge = require("cocos/cocos2d/luaoc")
--         local ok = luaBridge.callStaticMethod("AppController", "writeFileLog", {filePath = _filePath, content = _content})
--     elseif gt.isAndroidPlatform() then
--         local luaBridge = require("cocos/cocos2d/luaj")
--         local ok = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "writeFileLog", {_filePath, _content}, "(Ljava/lang/String;Ljava/lang/String;)V")
--     end
-- end
-- gt.writeFileLog = writeFileLog

gt.timerWriteLogTable = {}

local function openFile(type)
	gt.uploadtext = ""
	--gt.log("--------------testlog.txt", cc.FileUtils:getInstance():getWritablePath()..gt.uploadFileName)
	gt.file = io.open(cc.FileUtils:getInstance():getWritablePath()..gt.uploadFileName, type)
	gt.fileOpen = true
end
gt.openFile = openFile

local function upFile(_line)
	gt.uploadtext = gt.uploadtext.._line.."\n"
	-- assert(gt.file)
end
gt.upFile = upFile

local function closeFile()
	gt.file:write(gt.uploadtext)
	gt.file:close()
	gt.fileOpen = false
end
gt.closeFile = closeFile

--开定时器写log文件
local function timerWriteLog()
	if gt.timerWriteLogTable and #gt.timerWriteLogTable > 0 then
		if gt.file and gt.fileOpen then
			gt.file:write(gt.timerWriteLogTable[1])
			table.remove(gt.timerWriteLogTable, 1)
			gt.file:close()
			gt.fileOpen = false
		else
			gt.openFile("a")
			if gt.file and gt.timerWriteLogTable and gt.timerWriteLogTable[1] then
				gt.file:write(gt.timerWriteLogTable[1])
				table.remove(gt.timerWriteLogTable, 1)
				gt.file:close()
				gt.fileOpen = false
			end
		end
	end
end
gt.timerWriteLog = timerWriteLog

--删除log文件
local function removeLog()
	if gt.getFileList then
		local fileListTable = gt.getFileList()

		local function removeFile( path )
		    io.writefile(path, "")
		    if device.platform == "windows" or device.platform == "mac" then
		        os.remove(string.gsub(path, '/', '\\'))
		    else
		        cc.FileUtils:getInstance():removeFile( path )
		    end
		end

		if fileListTable and #fileListTable > 64  then
			for i = 64 + 1, #fileListTable do
				if fileListTable[i].filePath and fileListTable[i].filePath ~= "" then
					removeFile(fileListTable[i].filePath)
				end
			end
		end
	end
end
gt.removeLog = removeLog

local function readFile()
	local file = io.open("testlog.txt","r")
	gt.log("----------readFile")
	local data = ""
	local data = file:read("*a")
	-- for l in file:lines() do
	--   data = data..l.."\n"
	-- end
	file:close()
	gt.log(data)
	gt.postUploadText(data)
end
gt.readFile = readFile

local function uploadLogFile(fileName)
	local path = cc.FileUtils:getInstance():getWritablePath()..gt.uploadFileName
	
	if cc.FileUtils:getInstance():isFileExist(path) then
		local param = path
		local url = gt.getUrlEncryCode(gt.uploadLog, gt.playerData.uid)
		local uploader = CurlAsset:createUploader(url,param)
		gt.log("------------uploadLog1")
		if uploader then
		gt.log("------------uploadLog2")
			uploader:addToFileForm("test_log",param,"text/plain")
			uploader:uploadFile(function(sender, ncode, msg)
				gt.log("------------uploadLog3")
				local ok, datatable = pcall(function()
						gt.log("------------uploadLog4")
						return cjson.decode(msg)
				end)
				if ok then
					if datatable.errno == 0 then
						-- cc.FileUtils:getInstance():removeDirectory(path)
						return true
					else
						return false
					end
				end
			end)
		end
	end
	return false
end
gt.uploadLogFile = uploadLogFile

local function getFileList()
	local function getAppVersion()
		if device.platform == "windows" or device.platform == "mac"then
			return 11
		end

		if device.platform == "ios" then
			return 10
		end
		
		local luaBridge = nil
		local ok, appVersion = nil
		if gt.isIOSPlatform() then
			luaBridge = require("cocos/cocos2d/luaoc")
			ok, appVersion = luaBridge.callStaticMethod("AppController", "getVersionName")
		elseif gt.isAndroidPlatform() then
			luaBridge = require("cocos/cocos2d/luaj")
			ok, appVersion = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")
		end

		local data = string.split(appVersion, ".")

		local versionNumber = 0

		if data[1] then
			versionNumber = versionNumber + tonumber(data[1])*10
		end

		if data[2] then
			versionNumber = versionNumber + tonumber(data[2])
		end

		return versionNumber
	end

	local AppVersion = getAppVersion()
	if AppVersion <= 10 then
		return {}
	end

	local _directory = cc.FileUtils:getInstance():getWritablePath()

	local _fileList = ""

	-- _fileList = "1000000_547094_1.testlog,1000000_547094_2.testlog,1000000_547094_3.testlog,1000000_547094_4.testlog,1000000_547094_5.testlog##4,5,3,1,2"

    if gt.isIOSPlatform() then
        -- local luaBridge = require("cocos/cocos2d/luaoc")
        -- local ok, fileList = luaBridge.callStaticMethod("AppController", "getFileList", {directory = _directory})
        
        -- _fileList = fileList
    elseif gt.isAndroidPlatform() then
        local luaBridge = require("cocos/cocos2d/luaj")
        local ok, fileList = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getFileList", {_directory}, "(Ljava/lang/String;)Ljava/lang/String;")

        _fileList = fileList
    end

	local fileLogTable = {}

	local dataTable = string.split(_fileList, "##")

	local filePathTable = {}

	local filetimeTable = {}

	if dataTable[1] then
		filePathTable = string.split(dataTable[1], ",")
	end

	if dataTable[2] then
		filetimeTable = string.split(dataTable[2], ",")
	end

	for i = 1, #filePathTable do
		local item = {}
		item.filePath = filePathTable[i]
		item.time = (filetimeTable[i] or 0)
		table.insert(fileLogTable, item)
	end

	local fileListTable = {}

	for i = 1, #fileLogTable do
		if string.sub(fileLogTable[i].filePath, string.len(fileLogTable[i].filePath) - 6, string.len(fileLogTable[i].filePath)) == "testlog" then
			table.insert(fileListTable, fileLogTable[i])
		end
	end

	table.sort(fileListTable, function(a, b)
		return tonumber(a.time or 0) > tonumber(b.time or 0)
	end)

    return fileListTable
end
gt.getFileList = getFileList

local function getAppVersion()
	local luaBridge = nil
	local ok, appVersion = nil
	if gt.isIOSPlatform() then
		luaBridge = require("cocos/cocos2d/luaoc")
		ok, appVersion = luaBridge.callStaticMethod("AppController", "getVersionName")
	elseif gt.isAndroidPlatform() then
		luaBridge = require("cocos/cocos2d/luaj")
		ok, appVersion = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")
	end

	local versionNumber = 0
	if gt.isIOSPlatform() then
		versionNumber = tonumber(appVersion)
	elseif gt.isAndroidPlatform() then
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
gt.getAppVersion = getAppVersion

local function dumploglogin(value, desciption, nesting)

	if value then return end
	if type(nesting) ~= "number" then nesting = 6 end

	local lookupTable = {}
	local result = {}

	local traceback = string.split(debug.traceback("", 2), "\n")
	gt.log("dump from: " .. string.trim(traceback[3]))

	local function dump_(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
		elseif lookupTable[tostring(value)] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
		else
			lookupTable[tostring(value)] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
			else
				result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = dump_value_(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					dump_(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end

	if value == nil then
		gt.openFileLogin("a")
		gt.upFileLogin("nil")
		dump_(value, desciption, "- ", 1)
	elseif value == "clear" then
		gt.openFileLogin("w")
		gt.upFileLogin("clear")
	else
		dump_(value, desciption, "- ", 1)
		gt.openFileLogin("a")
		gt.upFileLogin(os.date("%Y-%m-%d_%H:%M:%S", os.time())..",".. (gt.playerData.uid or "gt.playerData.uid")..","..(gt.playerSeatIdx or "gt.playerSeatIdx"))
		for i, line in ipairs(result) do
			gt.upFileLogin(line)
		end
	end
	gt.closeFileLogin()
end
gt.dumploglogin = dumploglogin

local function openFileLogin(type)
	gt.uploadtext = ""
	gt.filelogin = io.open(cc.FileUtils:getInstance():getWritablePath().."testlogin.txt", type)
end
gt.openFileLogin = openFileLogin

local function upFileLogin(_line)
	gt.uploadtext = gt.uploadtext.._line.."\n"
	assert(gt.filelogin)
end
gt.upFileLogin = upFileLogin

local function closeFileLogin()
	gt.filelogin:write(gt.uploadtext)
	gt.filelogin:close()
end
gt.closeFileLogin = closeFileLogin

local function readFileLogin()
	local file = io.open(cc.FileUtils:getInstance():getWritablePath().."testlogin.txt","r")
	gt.log("----------readFileLogin")
	local data = ""
	local data = file:read("*a")
	file:close()
	gt.log(data)
	gt.postUploadText(data)
end
gt.readFileLogin = readFileLogin

local function removeFileLogin()
	if cc.FileUtils:getInstance():isFileExist(cc.FileUtils:getInstance():getWritablePath().."testlogin.txt") then
		cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():getWritablePath().."testlogin.txt")
	end
end
gt.removeFileLogin = removeFileLogin

-- local function uploadLogFileLogin()
-- 	local path = cc.FileUtils:getInstance():getWritablePath().."/testlogin.txt"
	
-- 	if cc.FileUtils:getInstance():isFileExist(path) then
-- 		local param = path
-- 		local url = gt.getUrlEncryCode(gt.uploadLog, gt.playerData.uid)
-- 		local uploader = CurlAsset:createUploader(url,param)
-- 		gt.log("------------uploadLog1")
-- 		if uploader then
-- 		gt.log("------------uploadLog2")
-- 			uploader:addToFileForm("test_log",param,"text/plain")
-- 			uploader:uploadFile(function(sender, ncode, msg)
-- 				gt.log("------------uploadLog3")
-- 				local ok, datatable = pcall(function()
-- 						gt.log("------------uploadLog4")
-- 						return cjson.decode(msg)
-- 				end)
-- 				if ok then
-- 					print("errno..............."..datatable.errno)
-- 					if datatable.errno == 0 then
-- 						cc.FileUtils:getInstance():removeDirectory(path)
-- 						return true
-- 					else
-- 						return false
-- 					end
-- 				end
-- 			end)
-- 		end
-- 	end
-- 	return false
-- end
-- gt.uploadLogFileLogin = uploadLogFileLogin

--检查昵称，如果超过 len 长度，剩下的用省略号表示
local function checkName( str ,len)
	local retStr = ""
	local num = 0
	local lenInByte = #str
	local x = 1
	local length = len or 12
	for i=1,lenInByte do
		i = x
	    local curByte = string.byte(str, x)
	    local byteCount = 1;
	    if curByte>0 and curByte<=127 then
	        byteCount = 1
	    elseif curByte>127 and curByte<240 then
	        byteCount = 3
	    elseif curByte>=240 and curByte<=247 then
	        byteCount = 4
	    end
	    local curStr = string.sub(str, i, i+byteCount-1)
	    retStr = retStr .. curStr
	    x = x + byteCount
	    if x >= lenInByte then
	    	return retStr
	    end
	    num = num + 1
	    if num >= length then
	    	return retStr.."..."
	    end
    end

    return retStr
end
gt.checkName = checkName
-- start --
--------------------------------
-- @class function floatText
-- @description 浮动文本
-- @param content 内容
-- @return
-- end --
gt.golbalZOrder = 10000
local function floatText(content)
	if not content or content == "" then
		return
	end

	local offsetY = 20
	local rootNode = cc.Node:create()
	rootNode:setPosition(cc.p(gt.winCenter.x, gt.winCenter.y - offsetY))

	local bg = cc.Scale9Sprite:create("res/images/otherImages/frame_tips.png")
	local capInsets = cc.size(200, 5)
	local textWidth = bg:getContentSize().width - capInsets.width * 2
	bg:setScale9Enabled(true)
	bg:setCapInsets(cc.rect(capInsets.width, capInsets.height, bg:getContentSize().width - capInsets.width, bg:getContentSize().height - capInsets.height))
	bg:setAnchorPoint(cc.p(0.5, 0.5))
	bg:setGlobalZOrder(gt.golbalZOrder)
	gt.golbalZOrder = gt.golbalZOrder + 1
	rootNode:addChild(bg)

	local ttfConfig = {}
	ttfConfig.fontFilePath = gt.fontNormal
	ttfConfig.fontSize = 38
	local ttfLabel = cc.Label:createWithTTF(ttfConfig, content)
	ttfLabel:setGlobalZOrder(gt.golbalZOrder)
	gt.golbalZOrder = gt.golbalZOrder + 1
	ttfLabel:setTextColor(cc.YELLOW)
	ttfLabel:setAnchorPoint(cc.p(0.5, 0.5))
	rootNode:addChild(ttfLabel)

	if ttfLabel:getContentSize().width > textWidth then
		bg:setContentSize(cc.size(bg:getContentSize().width + (ttfLabel:getContentSize().width - textWidth), bg:getContentSize().height))
	end
	
	local action = cc.Sequence:create(
		cc.MoveBy:create(0.8, cc.p(0, 120)),
		cc.CallFunc:create(function()
			rootNode:removeFromParent(true)
		end)
	)
	cc.Director:getInstance():getRunningScene():addChild(rootNode)
	rootNode:runAction(action)

end
gt.floatText = floatText

local function getDDHHMMSS(time)
	local day = math.floor(time/86400000)
	local hour = math.floor(time%86400000/3600000)
	local minute = math.floor(time%86400000%3600000/60000)
	local second = math.floor(time%86400000%3600000%60000/1000)
	local ret = {day, hour, minute, second}
    return ret
end
gt.getDDHHMMSS = getDDHHMMSS

--创建富文本
--传入list，以及单个label的限制长度
--返回label 的列表
local function createRichLabel(list,length)
    if length == nil then
        length = 960
    end
    local richText = ccui.RichText:create()
    richText:getAnchorPoint()
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(cc.size(length,10))
    richText:retain()
    for i = 1,#list do
        if list[i] ~= nil then
            --主要用于广播面版显示vip铭牌
            if list[i].ele_type == "spri" and list[i].ele_spri ~= nil then
                local re = ccui.RichElementCustomNode:create(i,list[i].color,255,list[i].ele_spri)
                richText:pushBackElement(re)
            else
                local re = ccui.RichElementText:create(i,list[i].color,255,list[i].text,"",list[i].size)
                richText:pushBackElement(re)
            end
        end
    end
    richText:setLocalZOrder(99)
    return richText
end
gt.createRichLabel = createRichLabel

--创建富文本 2017-3-1 shenyongzhen add
--传入list，以及单个label的限制长度
--返回label 的列表
local function createRichLabelEx(list,length)
    if length == nil then
        length = 960
    end
    local rootNode = ccui.Layout:create()
    rootNode:setAnchorPoint(0,1)  --Layout锚点设置跟layout位置有关，与layout上的子控件位置无关
    -- rootNode:setBackGroundColorType(1)
    -- rootNode:setColor(cc.c3b(0,255,0))
	local richtextlist = {}
    local totalHeight = 0  --总高度
    local space = 5        --每个文字条目的间距
    dump(list)
    for i = 1 ,#list do
    	if list[i] then

		    local txt = require("client/tools/RichTextEx"):create()
		    txt:setAnchorPoint(0,1)
			txt:setText(list[i])--("<#333><30>[世界]<#800><24>你好。欢迎各位牌友。<#333><30>[工会]<#800><24>一起玩山西麻将")
			txt:formatText()
			local size = txt:getContentSize()
		    local height = math.ceil(size.width / length) * size.height + space
			-- 多行模式要同时设置 ignoreContentAdaptWithSize(false) 和 contentSize
			txt:setMultiLineMode(true)	-- 这行其实就是 ignoreContentAdaptWithSize(false)
			txt:setContentSize(length, height)
			totalHeight = totalHeight + height 
			rootNode:addChild(txt)
			richtextlist[#richtextlist+1] ={_txt = txt,_height=height} 
    	end
    end
    rootNode:setContentSize(length,totalHeight)
    local posy = 0
    --从下往上排列，文字
    for j = #richtextlist, 1 , -1 do
    	posy = posy + richtextlist[j]._height
    	richtextlist[j]._txt:setPositionY(posy)
    	
    end
    return rootNode
end
gt.createRichLabelEx = createRichLabelEx


--复制和粘贴功能 --2017-2-23 syz add
local function isCopyText()
	return true
end
gt.isCopyText = isCopyText
--复制内容到剪贴板
local function CopyText(labString)
	if not labString or string.len(labString) ==0 then return end
	if  gt.isCopyText() then
		gt.log("labString = "..labString)
		if gt.isIOSPlatform() then
			local luaBridge = require("cocos/cocos2d/luaoc")
			luaBridge.callStaticMethod("AppController", "copyStr",{copystr = labString})
		elseif gt.isAndroidPlatform() then
			local luaBridge = require("cocos/cocos2d/luaj")
			luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "copyStr",{labString})
		end
	end
end
gt.CopyText = CopyText
--获取剪贴板内容
local function getCopyStr()
	gt.log("function is getCopyStr")
	local ok, ret
	if gt.isCopyText() then
		if gt.isIOSPlatform() then
			local luaBridge = require("cocos/cocos2d/luaoc")
			ok, ret = luaBridge.callStaticMethod("AppController", "getCopyStr")
		elseif gt.isAndroidPlatform() then
			local luaBridge = require("cocos/cocos2d/luaj")
			ok, ret = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getClipText", nil, "()Ljava/lang/String;")
		end
	end
	local labString = ret
	if labString == nil or string.len(labString) == 0 then
		labString = ""
	end
	if string.len(labString) > 0 then
		gt.log("labString = "..labString)
	end
	return labString
end
gt.getCopyStr = getCopyStr
-- 带子结点控件点击事件（子结点同时缩放）
local function addTouchEventListener(btn, listener, sfxType, scale)
	if not btn or not listener then
		return
	end

	if not scale then
		scale = -0.1
	end

	local oriScale = btn:getScale()

	btn:addTouchEventListener(function(uiwidget, eventType)
		if eventType == 0 then
			btn:runAction(cc.ScaleTo:create(0.05, oriScale+scale))
			return true
		end

		if eventType == 2 then
			btn:runAction(cc.ScaleTo:create(0.05, oriScale))
			listener(uiwidget)
		end

		if eventType == 3 then
			btn:runAction(cc.ScaleTo:create(0.05, oriScale))
		end
	end)

end
gt.addTouchEventListener = addTouchEventListener
--******ios iap ****------
local function getBundleID()
	if not gt.gameBundleId then
		if gt.isIOSPlatform() and Utils.checkVersion(1, 0, 1) then 
			local luaBridge = require("cocos/cocos2d/luaoc")
			local ok, bundleId = luaBridge.callStaticMethod("AppController", "getBundleID")

			gt.gameBundleId = bundleId
	    end 
	end
	-- gt.gameBundleId = "com.xianlai.mahjonghntwo"
	return gt.gameBundleId
end
gt.getBundleID = getBundleID

local function getRechargeConfig()
	gt.log("function is getRechargeCfg ")
	local rechargeConfig = nil

	-- local bundleId = gt.getBundleID()  
	-- if bundleId == "com.longxing.shanxi" then
		rechargeConfig = require("client/game/Purchase/Recharge")
	-- elseif bundleId == "com.xianlai.mahjonghnone" then
	-- 	rechargeConfig = require("client/game/Purchase/Recharge_ZZ")
	-- elseif bundleId == "com.xianlai.mahjongsy" then
	-- 	rechargeConfig = require("client/game/Purchase/Recharge_SY")
	-- end

	return rechargeConfig
end
gt.getRechargeConfig = getRechargeConfig

local function checkIAPState()
	if gt.isIOSPlatform() and Utils.checkVersion(1, 0, 1)  then 
		gt.isOpenIAP = true
	else
		gt.isOpenIAP = false
	end

	return gt.isOpenIAP
end
gt.checkIAPState = checkIAPState
--发货完成，结束支付SDK
local function finishDeliver(transactionid)
	if gt.isIOSPlatform() and Utils.checkVersion(1, 0, 1)  then 
		local luaBridge = require("cocos/cocos2d/luaoc")
		local ok, bundleId = luaBridge.callStaticMethod("AppController", "finishDeliver",{transactionId = transactionid})
    end
end
gt.finishDeliver = finishDeliver

--创建裁剪玩家头像
local function createClipHead( spRender, HeadLayout, limitWidth )
	-- if spRender:getContentSize().width > limitWidth then
		local m_fScale = limitWidth / spRender:getContentSize().width
		spRender:setScale(m_fScale)
	-- end

	-- --创建裁剪
	-- local strClip = "res/images/otherImages/head_bg.png"
	-- local clipSp = nil
	-- local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(strClip)
	-- if nil ~= frame then
	-- 	clipSp = cc.Sprite:createWithSpriteFrame(frame)
	-- else
	-- 	clipSp = cc.Sprite:create(strClip)
	-- end

	-- if nil ~= clipSp then
		-- --裁剪
		-- local clip = cc.ClippingNode:create()
		-- clip:setStencil(clipSp)
		-- clip:setAlphaThreshold(0)
		-- clip:setInverted(false)
		-- clip:addChild(spRender)
		-- spRender:setPosition(cc.p(clip:getContentSize().width/2,clip:getContentSize().height/2))
		-- local selfSize = HeadLayout:getContentSize()
		-- clip:setAnchorPoint(cc.p(0, 0))
		-- clip:setPosition(cc.p(selfSize.width * 0.5, selfSize.height * 0.5))
		-- HeadLayout:addChild(clip)
		-- clip:setPositionY(clip:getPositionY())

		spRender:getTexture():setAntiAliasTexParameters()

		local DrawNode = cc.DrawNode:create()
		local NodeRound = gt.drawNodeRoundRect(DrawNode, {x = 0, y = 0, width = limitWidth, height = limitWidth}, 0, 4, cc.c4f(0, 0, 0, 1), cc.c4f(0, 0, 0, 1))
		
		NodeRound:addChild(spRender)
		spRender:setPosition(cc.p(NodeRound:getContentSize().width/2,-NodeRound:getContentSize().height/2))
		-- spRender:setPosition(cc.p(NodeRound:getContentSize().width/2,NodeRound:getContentSize().height/2))
		-- spRender:setPosition(cc.p(31.5,-31.5))
		local selfSize = HeadLayout:getContentSize()
		NodeRound:setAnchorPoint(cc.p(0.5, 0.5))
		-- NodeRound:setAnchorPoint(cc.p(0, 0))
		NodeRound:setPosition(cc.p(selfSize.width * 0.5, selfSize.height * 0.5+NodeRound:getContentSize().height))
		-- NodeRound:setPosition(cc.p(selfSize.width * 0.5, selfSize.height * 0.5))
		-- NodeRound:setPosition(cc.p(0, NodeRound:getContentSize().height))
		HeadLayout:addChild(NodeRound,999)

		-- return spBg
	-- end

	return nil
end
gt.createClipHead = createClipHead


-- 传入DrawNode对象，画圆角矩形
local function drawNodeRoundRect(drawNode, rect, borderWidth, radius, color, fillColor)
    -- segments表示圆角的精细度，值越大越精细
    local segments    = 100
    local origin      = cc.p(rect.x, rect.y)
    local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
    local points      = {}

    local pClip = CCClippingNode:create()
      
    pClip:setInverted(false) --设置是否反向，将决定画出来的圆是透明的还是黑色的  
    pClip:setAnchorPoint(ccp(0, 0))

    -- 算出1/4圆
    local coef     = math.pi / 2 / segments
    local vertices = {}

    for i=0, segments do
    local rads = (segments - i) * coef
    local x    = radius * math.sin(rads)
    local y    = radius * math.cos(rads)

    table.insert(vertices, cc.p(x, y))
    end

    local tagCenter      = cc.p(0, 0)
    local minX           = math.min(origin.x, destination.x)
    local maxX           = math.max(origin.x, destination.x)
    local minY           = math.min(origin.y, destination.y)
    local maxY           = math.max(origin.y, destination.y)
    local dwPolygonPtMax = (segments + 1) * 4
    local pPolygonPtArr  = {}

    -- 左上角
    tagCenter.x = minX + radius;
    tagCenter.y = maxY - radius;

    for i=0, segments do
	    local x = tagCenter.x - vertices[i + 1].x
	    local y = tagCenter.y + vertices[i + 1].y

	    local point = {}

	    -- table.insert(point, x)

	    -- table.insert(point, y)

	    point.x = x
	    point.y = y

	    table.insert(pPolygonPtArr, point)
    end

    -- 右上角
    tagCenter.x = maxX - radius;
    tagCenter.y = maxY - radius;

    for i=0, segments do
	    local x = tagCenter.x + vertices[#vertices - i].x
	    local y = tagCenter.y + vertices[#vertices - i].y

	    local point = {}

	    -- table.insert(point, x)

	    -- table.insert(point, y)

	    point.x = x
	    point.y = y

	    table.insert(pPolygonPtArr, point)
    end

    -- 右下角
    tagCenter.x = maxX - radius;
    tagCenter.y = minY + radius;

    for i=0, segments do
	    local x = tagCenter.x + vertices[i + 1].x
	    local y = tagCenter.y - vertices[i + 1].y

	    local point = {}

	    -- table.insert(point, x)

	    -- table.insert(point, y)

	    point.x = x
	    point.y = y

	    table.insert(pPolygonPtArr, point)
    end

    -- 左下角
    tagCenter.x = minX + radius;
    tagCenter.y = minY + radius;

    for i=0, segments do
	    local x = tagCenter.x - vertices[#vertices - i].x
	    local y = tagCenter.y - vertices[#vertices - i].y

	    local point = {}

	    -- table.insert(point, x)

	    -- table.insert(point, y)

	    point.x = x
	    point.y = y

	    table.insert(pPolygonPtArr, point)
    end

    if fillColor == nil then
        fillColor = cc.c4f(0, 0, 0, 255)
    end

    drawNode:clear()
    drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, borderWidth, color)

    -- drawNode:setPosition(ccp(0, 0))  

    pClip:setStencil(drawNode)
	-- pClip:setAlphaThreshold(0)

    -- pClip:addChild(drawNode, 1)
    pClip:setContentSize(cc.size(rect.width, rect.height)) 

    -- CC_SAFE_DELETE_ARRAY(vertices)
    -- CC_SAFE_DELETE_ARRAY(pPolygonPtArr)

    return pClip 
end
gt.drawNodeRoundRect = drawNodeRoundRect

local function getUrlEncryCode( _src, _uid )
	if _src == nil or not _src then
		return "http//"
	end

	local src = ""
	if _uid then
		src = _src.."user_id=".._uid
	end

	local platform_name = device.platform
	if platform_name == "windows"  then
		platform_name = "android"
	end

	if platform_name == "mac"  then
		platform_name = "ios"
	end
	
	if _uid then
		src = src.."&device_type="..platform_name.."&app_name=zjh"
	else
		src = _src.."device_type="..platform_name.."&app_name=zjh"
	end

	-- if device.platform ~= "android"  then
	-- 	return src
	-- end

	local keySalt = "mohe!#$#!2017#$!$#appauthprivatekey"

	local function callback(result)
		return result
	end

    if gt.isIOSPlatform() then
		local srcTable = string.split( src, "?" )

		local content = srcTable[1].."?"

		local param = srcTable[2]

		local url = ""
		local function callback(result)
			if type(result) == "string" and "" ~= result then
				local ret = require("cjson").decode(result)
				url = ret.url
				src = url
			end
		end

		-- g_var(PLATFORM[plat]).getUrlEncryCode(content, param, keySalt, callback)

		-- return url

	    -- local paramtab = {_content = content, _param = param, _keySalt = keySalt, scriptHandler = callback}
	    -- local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"get_urlEncryCode", paramtab)
	    -- print("---------------------------ok", ok)
	    -- print("---------------------------ret", ret)
	    -- if not ok then
	    --     local msg = "luaoc error:" .. ret
	    --     print(msg)  
	    --     return 0, msg   
	    -- else 
	    --     print(ret)
	    --     return ret
	    -- end

        local luaBridge = require("cocos/cocos2d/luaoc")
        local ok, url = luaBridge.callStaticMethod("AppController", "getEncryptUrl", {_content = content, _param = param, _keySalt = keySalt, scriptHandler = callback})
    elseif gt.isAndroidPlatform() then
        local luaBridge = require("cocos/cocos2d/luaj")
        local ok, url = luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getEncryptUrl", {src, keySalt}, "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
        src = url
    end

    return src
end
gt.getUrlEncryCode = getUrlEncryCode

local function postUploadText(text)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local postUploadTextURL = gt.getUrlEncryCode(gt.uploadTextUrl, gt.playerData.uid)
	
	xhr:open("POST", postUploadTextURL)
	xhr:setRequestHeader("text", "text")
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response
			local respJson = require("cjson").decode(response)
			
			dump(respJson)
			if respJson.errno == 0 then
			else
			end
		elseif xhr.readyState == 1 and xhr.status == 0 then
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end
gt.postUploadText = postUploadText

-- 翻牌动画
local function flopAnimation( node, image, callback )
	local function FlipSpriteComplete()
		if callback then
			callback()
		end
	end

	local function FlipSpriteCallback()
		node:setTexture(image)
	    local action = CCOrbitCamera:create(0.1, 1, 0, 270, 90, 0, 0)
	    node:runAction(cc.Sequence:create(action, cc.CallFunc:create(FlipSpriteComplete)))
	end

	if image == "poker/56.png" then
		return
	end

    local action = CCOrbitCamera:create(0.1, 1, 0, 0, 90, 0, 0)
    local callback = FlipSpriteCallback
    node:runAction(cc.Sequence:create(action, cc.CallFunc:create(FlipSpriteCallback)))
end

gt.flopAnimation = flopAnimation

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
--- 只适用新发布的包 并且平台底层有该方法

--[[

()V                             参数：无，返回值：无
(I)V                            参数：int，返回值：无
(Ljava/lang/String;)Z           参数：字符串，返回值：布尔值
(IF)Ljava/lang/String;          参数：整数、浮点数，返回值：字符串

]]


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
	 	local ok, id = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "getid")
	 	if ok then  return id  else return "" end
	 elseif gt.isAndroidPlatform() then
	 	local ok, id = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "getid", nil, "()Ljava/lang/String;")
	 	if ok then return id  else return "" end
	 end
	 return ""
	 
end

gt.get_id = get_id


-- set 成功放回 YES or NO
local function set_id(id)

	 if gt.isIOSPlatform() then
	 	require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "deleateid")
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
	 	if ok then  return uuid  else return "" end
	 elseif gt.isAndroidPlatform() then
	 	local ok, uuid = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "getIMEI1", nil, "()Ljava/lang/String;")
	 	if ok then return uuid  else return "" end
	 end
	 return "mac"
end
gt.get_uuid = get_uuid

local function get_dianliang()

	 if gt.isIOSPlatform() then
	 	local ok, dianliang = require("cocos/cocos2d/luaoc").callStaticMethod("AppController", "dianliang")
	 	if ok then return dianliang  else return -1 end
	 elseif gt.isAndroidPlatform() then
	 	local ok, dianliang = require("cocos/cocos2d/luaj").callStaticMethod("org/cocos2dx/lua/AppActivity", "dianliang", nil, "()I")
	 	if ok then return dianliang  else return -1 end
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


