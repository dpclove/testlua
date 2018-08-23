
local gt = cc.exports.gt
local Utils = cc.exports.Utils
local GameLog = class("GameLog", function()
	return gt.createMaskLayer()
end)

------------
--param msgTbl ：msgTBl战绩服务器数据
function GameLog:ctor()
	self.GameLogMsgTbl = {}

	local dataTable = gt.getFileList()

	-- fileList = "1000000_547094_1.testlog,1000000_547094_2.testlog,1000000_547094_3.testlog,1000000_547094_4.testlog,1000000_547094_5.testlog"
	-- fileList = "/data/data/com.coolplaystore.haoyunlaipublic/files/.um,/data/data/com.coolplaystore.haoyunlaipublic/files/umeng_it.cache,/data/data/com.coolplaystore.haoyunlaipublic/files/.umeng,/data/data/com.coolplaystore.haoyunlaipublic/files/.imprint,/data/data/com.coolplaystore.haoyunlaipublic/files/version.manifest.upd,/data/data/com.coolplaystore.haoyunlaipublic/files/head_img_1000064.png,/data/data/com.coolplaystore.haoyunlaipublic/files/1000064_246329_1.testlog,"

	local fileListTable = {}

	for i = 1, #dataTable do
		if string.sub(dataTable[i].filePath, string.len(dataTable[i].filePath) - 6, string.len(dataTable[i].filePath)) == "testlog" then
			local filePath = string.gsub(dataTable[i].filePath, ".testlog", "")
			table.insert(fileListTable, filePath)
		end
	end

	for i = 1, #fileListTable do
		local itemTable = string.split(fileListTable[i], "_")
		local item = {}
		item.flieName = fileListTable[i]..".testlog"
		fileListTable[i] = fileListTable[i]..".testlog"
		if itemTable[2] then
			item.deskId = itemTable[2]
		end
		if itemTable[3] then
			item.roundIndex = itemTable[3]
		end
		if itemTable[4] then
			item.time = itemTable[4]
		end
		item.createTime = os.time()+i
		table.insert(self.GameLogMsgTbl, item)
	end

	-- for  i = 1, 32 do
	-- 	local item = {}
	-- 	item.deskId = i*10000
	-- 	item.roundIndex = i
	-- 	item.createTime = os.time()+i
	-- 	table.insert(self.GameLogMsgTbl, item)
	-- end

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    
	local csbNode = cc.CSLoader:createNode("GameLogDetail.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

	local function removeFile( path )
	    io.writefile(path, "")
	    if device.platform == "windows" then
	        os.remove(string.gsub(path, '/', '\\'))
	    else
	        cc.FileUtils:getInstance():removeFile( path )
	    end
	end

	--清除记录
	local clearBtn = gt.seekNodeByName(csbNode, "Button_clear")
	clearBtn:setVisible(false)
	gt.addBtnPressedListener(clearBtn, function()
		local fileListTable = string.split(fileList, ",")
		for i = 1, #fileListTable do
			removeFile(fileListTable[i])
		end
		self:onRcvGameLog({})
	end)

	-- 返回按钮
	local backBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(backBtn, function()
		-- 移除界面,返回主界面
		self:removeFromParent()
	end)

	self:onRcvGameLog(self.GameLogMsgTbl)
end

function GameLog:onNodeEvent(eventName)
	if "enter" == eventName then
		-- 触摸事件
		-- local listener = cc.EventListenerTouchOneByOne:create()
		-- listener:setSwallowTouches(true)
		-- listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		-- local eventDispatcher = self:getEventDispatcher()
		-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		-- 移除触摸事件
		--local eventDispatcher = self:getEventDispatcher()
		--eventDispatcher:removeEventListenersForTarget(self)
	end
end

function GameLog:onTouchBegan(touch, event)
	return true
end


function GameLog:sendHistoryOne(sender, eventType)
	local msgToSend = {}
	msgToSend.m_msgId = gt.CG_HISTORY_ONE
	local data = self.GameLogMsgTbl.m_data[sender:getTag()]
	msgToSend.m_time = data.m_time
	msgToSend.m_userId = gt.playerData.uid  --玩家自己id
	gt.dump(self.GameLogMsgTbl[sender:getTag()])
	msgToSend.m_pos = self.GameLogMsgTbl[sender:getTag()].m_userid[1]  --房主id
	msgToSend.m_deskId = data.m_deskId
	gt.socketClient:sendMessage(msgToSend)
	self.m_sender = sender
	gt.showLoadingTips("读取数据中")
end

function GameLog:onRcvGameLog(msgTbl)
	gt.dump(msgTbl)
	if self.historyListVw == nil then
		self.historyListVw = gt.seekNodeByName(self.rootNode, "ListVw_content")
	end
	-- local emptyLabel = gt.seekNodeByName(self.rootNode, "Text_tip_noData")
	if #msgTbl == 0 then
		--没有战绩
		-- emptyLabel:show()
		self.historyListVw:removeAllItems()
	else
		-- emptyLabel:hide()
		-- 显示战绩列表
		for i, cellData in ipairs(msgTbl) do
			local historyItem = self:createHistoryItem(i, cellData)
			self.historyListVw:pushBackCustomItem(historyItem)
		end
	end
end

-- start --
--------------------------------
-- @class function
-- @description 创建战绩条目
-- @param cellData 条目数据
-- end --
function GameLog:createHistoryItem(tag, cellData)
	local cellNode = cc.CSLoader:createNode("GameLogDetailCell.csb")

	local content = "房号"..(cellData.deskId or "空").."_"..(cellData.roundIndex or "0").."局"..(cellData.time or "0")
	--..os.date("%Y-%m-%d_%H:%M:%S", cellData.createTime)
	
	-- 房间号
	local GamelogInfoLabel = gt.seekNodeByName(cellNode, "Label_GamelogInfo")
	GamelogInfoLabel:setString(content)
	
	local filePath = cellData.flieName

	local WritablePath = cc.FileUtils:getInstance():getWritablePath()

	local fileName = string.sub(filePath, string.len(WritablePath) + 1, string.len(filePath))

	local UpLoadButton = gt.seekNodeByName(cellNode, "Button_UpLoad")
	gt.addBtnPressedListener(UpLoadButton, function(sender)
	gt.log("----------filePath", filePath)

	gt.log("----------fileName", fileName)

		if gt.isIOSPlatform() then
			self.luaBridge = require("cocos/cocos2d/luaoc")
		elseif gt.isAndroidPlatform() then
			self.luaBridge = require("cocos/cocos2d/luaj")
		end
		if gt.isIOSPlatform() then
			local ok = self.luaBridge.callStaticMethod("AppController", "uploadFile", {filePath = filePath, fileName = fileName})
		elseif gt.isAndroidPlatform() then
			local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "uploadFile", {filePath, fileName}, "(Ljava/lang/String;Ljava/lang/String;)V")
		end
	end)

	local cellSize = cellNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(cellNode)
	-- cellItem:addClickEventListener(handler(self, self.sendHistoryOne))

	return cellItem
end

return GameLog

