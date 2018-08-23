-- Creator ArthurSong
-- Create Time 2016/1/29

local gt = cc.exports.gt

require("client/message/MessageInit")
require("socket")
local bit = require("client/message/bit")
-- local loginStrategy = require("app/LoginIpStrategy")
local SocketClient = class("SocketClient")

function SocketClient:ctor()
	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end

	-- 随机函数种子
	math.randomseed(os.time())
	
	-- 加载消息打包库
	local msgPackLib = require("client/message/MessagePack")
	msgPackLib.set_number("integer")
	msgPackLib.set_string("string")
	msgPackLib.set_array("without_hole")
	self.msgPackLib = msgPackLib

	self:initSocketBuffer()

	-- 注册消息逻辑处理函数回调
	self.rcvMsgListeners = {}

	-- 收发消息超时
	self.timeDuration = 0

	-- 是否已经弹出网络错误提示
	self.isPopupNetErrorTips = false

	-- 登录到服务器标识
	self.isStartGame = false

	-- 断线重连开关heartbeat
	self.closeHeartBeat = true

	self.isReconnectFlag = false

	self.netWorkChangeFlag = false

	gt.resume_time = 8
	gt.connecting = false

	-- 发送心跳时间
	self.heartbeatCD = 4
	-- 心跳回复时间间隔
	-- 上一次时间间隔
	self.lastReplayInterval = 0
	-- 当前时间间隔
	self.curReplayInterval = 0

	-- 登录状态,有三次自动重连的机会	
	-- self.loginReconnectNum = 0
	
	-- 用于消息头数据
	self.playerUUID = ""
	self.playerKeyOnGate = ""
	self.playerMsgOrder = 0

	-- 检测是否有网络最大时间(秒)
	self.checkInternetMaxTime = 0.5
	-- 检测是否有网络时间
	self.checkInternetTime = self.checkInternetMaxTime
	-- 上次网络状态, 当前网络状态
	self.internetLastStatus = ""
	self.internetCurStatus = ""

	self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)

	-- self.scheduleCheckNetWork = gt.scheduler:scheduleScriptFunc(handler(self, self.updateNetWork), 1, false)
	
	gt.registerEventListener(gt.EventType.NETWORK_ERROR, self, self.networkErrorEvt)
end

function SocketClient:initSocketBuffer()
	-- 发送消息缓冲
	self.sendMsgCache = {}
	self.sendingBuffer = ""
	self.remainSendSize = 0
	
	-- 接收消息
	self.recvingBuffer = ""
	self.remainRecvSize = 12 --剩余多少数据没有接受完毕,2:头部字节数
	self.recvState = "Head"

end

-- start --
--------------------------------
-- @class function
-- @description 和指定的ip/port服务器建立socket链接
-- @param serverIp 服务器ip地址
-- @param serverPort 服务器端口号
-- @param isBlock 是否阻塞
-- @return socket链接创建是否成功
-- end --
function SocketClient:connect(serverIp, serverPort, isBlock)
	--print(debug.traceback())

	if not serverIp or not serverPort then
		gt.log("建立socket连接, serverIp or serverPort is false ")
		-- gt.dumploglogin("serverIp not or serverPort not "..(serverIp or "null")..(serverPort or "null"))
		return false
	end

	gt.log("建立socket连接, serverIp = "..serverIp..", serverPort = "..serverPort..", isBlock = "..tostring(isBlock))

	-- if display.getRunningScene() and display.getRunningScene().name == "pokerScene" and display.getRunningScene():getChildByName("Poker_node"):getChildByName("err") then 
	-- 	display.getRunningScene():getChildByName("Poker_node"):getChildByName("err"):setVisible(true)
	-- 	display.getRunningScene():getChildByName("Poker_node"):getChildByName("err"):setString("建立socket连接, serverIp = "..serverIp..", serverPort = "..serverPort)
	-- end

	self:initSocketBuffer()

	gt.curServerIp = serverIp        --当前ip
	
	-- self.serverIp = serverIp
	self.serverPort = serverPort
	self.isBlock = isBlock

	gt.log("the ip is .." .. serverIp .. "the port is .. " .. serverPort)

	-- tcp 协议 socket
	local tcpConnection, errorInfo = self:getTcp(serverIp)
 	if not tcpConnection then
 		gt.log(string.format("建立socket连接, Connect failed when creating socket | %s", errorInfo))
		-- gt.dispatchEvent(gt.EventType.NETWORK_ERROR, errorInfo)
		-- gt.dumploglogin("serverIp "..(serverIp or "null"))
		return false
	end
	self.tcpConnection = tcpConnection
	tcpConnection:setoption("tcp-nodelay", true)
	-- 和服务器建立tcp链接
	tcpConnection:settimeout(isBlock and 5 or 0)
	local connectCode, errorInfo = tcpConnection:connect(serverIp, serverPort)
	if connectCode == 1 then
		self.isConnectSucc = true
		self.isReconnectFlag = false
		gt.log("Socket connect success!")
	else
		-- gt.dumploglogin("Socket Connect failed "..(serverIp or "null")..(serverPort or "null"))
		gt.log(string.format("Socket %s Connect failed | %s", (isBlock and "Blocked" or ""), errorInfo))
		-- gt.dispatchEvent(gt.EventType.NETWORK_ERROR, errorInfo)
		return false
	end
	self.curIpState = nil
	self.tcpConnection:settimeout(0)
	
	return true
end

function SocketClient:getTcp(host)
	gt.log("SocketClient getTcp host = "..host)
	local isipv6_only = false
	local addrinfo, err = socket.dns.getaddrinfo(host)
	gt.log("获取ipv6 ============ ")
--	dump(addrinfo)
	if addrinfo ~= nil and #addrinfo > 0 then
		for i,v in ipairs(addrinfo) do
			if v.family == "inet6" then
				isipv6_only = true;
				break
			end
		end
	end
	-- dump(socket.dns.getaddrinfo(host))
--	print("isipv6_only", isipv6_only)
	if isipv6_only then
		return socket.tcp6()
	else
		return socket.tcp()
	end

	-- return socket.tcp()
end

function SocketClient:connectResume()

	-- 不用管当前是什么状态 什么scene  只要断掉都走重连
	if self.isReconnectFlag == false then
		if not self.isResumeFlag then
			self.isResumeFlag = true
			secure.manager:request()
		else
			secure.manager:nextState()
		end
	end

	return true
end



-- start --
--------------------------------
-- @class function
-- @description 关闭socket链接
-- end --
function SocketClient:close()
	--print(debug.traceback())
	gt.log("关闭socket链接")
	self.isStartGame = false
	if self.tcpConnection then
		self.tcpConnection:close()
	end
	self.tcpConnection = nil
	self.isConnectSucc = false
	self.sendMsgCache = {}

	self.isPopupNetErrorTips = false
end


local function timerWriteLog( )
	if gt.timerWriteLog then
		gt.timerWriteLog()
	end
end


-- start --
--------------------------------
-- @class function
-- @description 发送消息放入到缓冲,非真正的发送
-- @param msgTbl 消息体
-- end --
function SocketClient:sendMessage(msgTbl)
	if msgTbl.kMId ~= 61008	then
		--非心跳消息才打印日志
		gt.log("发送消息 ============== ", msgTbl.kMId)
		gt.dump(msgTbl)
		--gt.dumplog(msgTbl)
	end
	
	-- test
	-- if msgTbl.kMId and (msgTbl.kMId == 1 or msgTbl.kMId == 170 or msgTbl.kMId == 11) then
		-- if gt.dumploglogin then
			-- gt.dumploglogin("------------msgTbl.kMId"..msgTbl.kMId)
			-- gt.dumploglogin(msgTbl)
		-- end
	-- end

	-- if msgTbl.kMId and msgTbl.kMId == 15  then
		-- if gt.dumploglogin then
			-- gt.dumploglogin("------------msgTbl.kMId"..msgTbl.kMId)
		-- end
	-- end

	self.kMId = msgTbl.kMId

	-- 打包成messagepack格式
	-- 打包消息实体
	local packMsgData    = self.msgPackLib.pack(msgTbl)
	local time = socket.gettime() -- test

	-- local str  = ""
	-- for i = 1 , string.len(packMsgData) do
	-- 	str = str .. string.format("%04X",tonumber(string.byte(packMsgData, i, i))).."\n"
	-- end
	-- gt.log(str)
	-- gt.log("len....",string.len(packMsgData))
   	packMsgData = cc.UtilityExtension:EncryptMessageBody(packMsgData,string.len(packMsgData))
   	--12-7
   	-- print("加密消息实体耗时 ms:",(socket.gettime() - time)*1000,"消息id",msgTbl.kMId) -- test
	-- gt.dumploglogin("加密消息实体耗时 ms:"..((socket.gettime() - time)*1000).."消息id"..msgTbl.kMId)
   	-- packMsgData = cc.UtilityExtension:DecryptMessageBody(packMsgData, string.len(packMsgData))
	local packMsgEntity  = string.char(1) .. packMsgData --1字节标志此消息为经过pack过的
	local msgEntityLen   = string.len(packMsgEntity)
	local msgEntityLenHi = string.char(math.floor(msgEntityLen / 256))
	local msgEntityLenLow= string.char(msgEntityLen % 256)
	
	-- 打包消息头
	local packMsgHead  = self.msgPackLib.pack(self:getMessageHead(packMsgData))
	local time = socket.gettime() -- test
	packMsgHead = cc.UtilityExtension:EncryptMessageBody(packMsgHead,string.len(packMsgHead))
	-- 12-7
	-- print("加密消息头耗时 ms:",(socket.gettime() - time)*1000,"消息id",msgTbl.kMId) -- test
	-- gt.dumploglogin("加密消息头耗时 ms:"..((socket.gettime() - time)*1000).."消息id"..msgTbl.kMId)
	local msgHeadLen   = string.len(packMsgHead)
	local msgHeadLenHi = string.char(math.floor(msgHeadLen / 256))
	local msgHeadLenLow= string.char(msgHeadLen % 256)
	
	local msgTotalLen   = msgHeadLen + 2 + msgEntityLen + 2	--需要各加两个字节的长度长
	local msgTotalLenHi = string.char(math.floor(msgTotalLen / 256))
	local msgTotalLenLow= string.char(msgTotalLen % 256)
	
	local curTime 	= os.time()
	local time 		= self:luaToCByInt(curTime)
	local msgId 	= self:luaToCByInt(msgTbl.kMId * ((curTime % 10000) + 1))
	
	local checksum 	= self:getCheckSum(time .. msgId .. msgHeadLenLow .. msgHeadLenHi .. packMsgHead .. msgEntityLenLow .. msgEntityLenHi .. packMsgEntity)

	local msgToSend = msgTotalLenLow .. msgTotalLenHi .. checksum .. time .. msgId .. msgHeadLenLow .. msgHeadLenHi .. packMsgHead .. msgEntityLenLow .. msgEntityLenHi .. packMsgEntity

	-- 放入到消息缓冲
	table.insert(self.sendMsgCache, msgToSend)
end


function SocketClient:getCheckSum(time)
	local crc = self:CRC(time, 8)
	return self:luaToCByShort(crc)
end

function SocketClient:luaToCByShort(value)
	return string.char(value % 256) .. string.char(math.floor(value / 256))
end

function SocketClient:luaToCByInt(value)
	local lowByte1 = string.char(self:getInt(((value / 256) / 256) / 256))		
	local lowByte2 = string.char(self:getInt(((value / 256) / 256) % 256))
	local lowByte3 = string.char(self:getInt((value / 256) % 256))
	local lowByte4 = string.char(self:getInt(value % 256))
	return lowByte4 .. lowByte3 .. lowByte2 .. lowByte1
end

function SocketClient:getInt(x)
	if x <= 0 then
	   return math.ceil(x)
	end

	if math.ceil(x) == x then
	   x = math.ceil(x);
	else
	   x = math.ceil(x) - 1;
	end

	return x;
end

function SocketClient:CRC(data, length)
    local sum = 65535
    for i = 1, length do
        local d = string.byte(data, i)    -- get i-th element, like data[i] in C
        sum = self:ByteCRC(sum, d)
    end
    return sum
end

function SocketClient:ByteCRC(sum, data)
    -- sum = sum ~ data
    local sum = bit:_xor(sum, data)
    for i = 0, 3 do     -- lua for loop includes upper bound, so 7, not 8
        -- if ((sum & 1) == 0) then
        if (bit:_and(sum, 1) == 0) then
            sum = sum / 2
        else
            -- sum = (sum >> 1) ~ 0xA001  -- it is integer, no need for string func
            sum = bit:_xor((sum / 2), 0x70B1)
        end
    end
    return sum
end
-- start --
--------------------------------
-- @class function
-- @description 发送消息
-- @param msgTbl 消息表结构体
-- end --
function SocketClient:send()
	if not self.isConnectSucc or not self.tcpConnection then
		-- 链接未建立
		--gt.log("发送失败，socket链接未建立")
		return false
	end

	if #self.sendMsgCache <= 0 then
		return true
	end
	
	local sendSize = 0
	local errorInfo = ""
	local sendSizeWhenError = 0
	if self.remainSendSize > 0 then --还有剩余的数据没有发送完毕，接着发送
		local totalSize = string.len(self.sendingBuffer)
		local beginPos = totalSize - self.remainSendSize + 1
		sendSize, errorInfo, sendSizeWhenError = self.tcpConnection:send(self.sendingBuffer, beginPos)
	else
		self.sendingBuffer = self.sendMsgCache[1]
		self.remainSendSize = string.len(self.sendingBuffer)
		sendSize, errorInfo, sendSizeWhenError = self.tcpConnection:send(self.sendingBuffer)
	end
	
	if errorInfo == nil then 
		self.remainSendSize = self.remainSendSize - sendSize
		if self.remainSendSize == 0 then  --说明已经发送完毕
			table.remove(self.sendMsgCache, 1)  --移除第一个
			self.sendingBuffer = ""
		end
	else

		-- gt.dumploglogin("--------------errorInfo1"..(sendSizeWhenError or ""))
		-- gt.dumploglogin("--------------errorInfo"..(errorInfo or ""))
		-- gt.dumploglogin("--------------errorInfo"..(self.remainSendSize or ""))
		if errorInfo == "timeout" then --由于是异步socket，并且timeout为0，luasocket则会立即返回不会继续等待socket可写事件
		-- gt.dumploglogin("--------------errorInfo2")
			if sendSizeWhenError ~= nil and sendSizeWhenError > 0 then
		-- gt.dumploglogin("--------------errorInfo3")
				self.remainSendSize = self.remainSendSize - sendSizeWhenError

				--gt.log("Send time out. Had sent size:" .. sendSizeWhenError)
			end
		else
		-- gt.dumploglogin("--------------errorInfo4")
			--gt.log("Send failed errorInfo:" .. errorInfo)
		
			return false
		end
	end
		
	return true
end

function SocketClient:receive()
	if not self.isConnectSucc or not self.tcpConnection then
		-- 链接未建立
		--gt.log("接收失败，socket链接未建立")
		return
	end
	
	local messageQueue = {}
	self:receiveMessage(messageQueue)
	
	if #messageQueue <= 0 then
		return
	end

	--gt.log("Recv meesage package:" .. #messageQueue)
	
	for i,v in ipairs(messageQueue) do
		self:dispatchMessage(v)
	end
end

function SocketClient:receiveMessage(messageQueue)
	if self.remainRecvSize <= 0 then
		return true
	end

	local recvContent,errorInfo,otherContent = self.tcpConnection:receive(self.remainRecvSize)
	if errorInfo ~= nil then
		if errorInfo == "timeout" then --由于timeout为0并且为异步socket，不能认为socket出错
			if otherContent ~= nil and #otherContent > 0 then
				self.recvingBuffer = self.recvingBuffer .. otherContent
				self.remainRecvSize = self.remainRecvSize - #otherContent

			--	gt.log("recv timeout, but had other content. size:" .. #otherContent)
			end
			
			return true
		else	--发生错误，这个点可以考虑重连了，不用等待heartbeat
			
			return false
		end
	end
	
	local contentSize = #recvContent
	self.recvingBuffer = self.recvingBuffer .. recvContent
	self.remainRecvSize = self.remainRecvSize - contentSize

--	gt.log("success recv size:" .. contentSize ..  "   remainRecvSize is:" .. self.remainRecvSize)
	-- gt.log("打印接收消息 ================== ")
	-- dump(recvContent)

	if self.remainRecvSize > 0 then	--等待下次接收
		return true
	end
	
	if self.recvState == "Head" then
		self.remainRecvSize = string.byte(self.recvingBuffer, 2) * 256 + string.byte(self.recvingBuffer, 1)
		self.recvingBuffer = ""
		self.recvState = "Body"
	--	gt.log("Need recv body size:" .. self.remainRecvSize)
	elseif self.recvState == "Body" then
		local Data = string.sub(self.recvingBuffer, 2, -1) --跳过packet字节
		--gt.log("---------------string.len(Data)", string.len(Data))
		local time = socket.gettime() -- test
   		Data = cc.UtilityExtension:DecryptMessageBody(Data, string.len(Data))
   	   

		local messageData = self.msgPackLib.unpack(Data)	
		 --12-7
   		-- print("解密消息Body耗时 ms:",(socket.gettime() - time)*1000,"消息id",messageData.kMId) -- test
   		-- gt.dumploglogin("解密消息Body耗时 ms:"..((socket.gettime() - time)*1000).."消息id"..messageData.kMId)
		table.insert(messageQueue, messageData)

		self.remainRecvSize = 12  --下个包头
		self.recvingBuffer = ""
		self.recvState = "Head"
	end

	--继续接数据包
	--如果有大量网络包发送给客户端可能会有掉帧现象，但目前不需要考虑，解决方案可以1.设定总接收时间2.收完body包就不在继续接收了
	return self:receiveMessage(messageQueue)
end

-- start --
--------------------------------
-- @class function
-- @description 注册msgId消息回调
-- @param msgId 消息号
-- @param msgTarget
-- @param msgFunc 回调函数
-- end --
function SocketClient:registerMsgListener(msgId, msgTarget, msgFunc)
	-- if not msgTarget or not msgFunc then
	-- 	return
	-- end

	
	


	self.rcvMsgListeners[msgId] = {msgTarget, msgFunc}
end

-- start --
--------------------------------
-- @class function
-- @description 注销msgId消息回调
-- @param msgId 消息号
-- end --
function SocketClient:unregisterMsgListener(msgId)
	self.rcvMsgListeners[msgId] = nil
end

-- start --
--------------------------------
-- @class function
-- @description 分发消息
-- @param msgTbl 消息表结构
-- end --
function SocketClient:dispatchMessage(msgTbl)
	if msgTbl.kMId ~= 61009 then 
		gt.log("收到消息_______________",msgTbl.kMId)
		gt.dump(msgTbl)
		-- gt.dumplog(msgTbl)
	end
	local rcvMsgListener = self.rcvMsgListeners[msgTbl.kMId]
	--gt.log("dispatch message id = " .. tostring(msgTbl.m_msgId))
	if rcvMsgListener then
		rcvMsgListener[2](rcvMsgListener[1], msgTbl)
		-- test
		-- if msgTbl.m_msgId and (msgTbl.m_msgId == 2 or msgTbl.m_msgId == 171 or msgTbl.m_msgId == 12) then
			-- if gt.dumploglogin then
				-- gt.dumploglogin("------------msgTbl.m_msgId"..msgTbl.m_msgId)
				-- gt.dumploglogin(msgTbl)
			-- end
		-- end
		-- if msgTbl.m_msgId and msgTbl.m_msgId == 16  then
			-- if gt.dumploglogin then
				-- gt.dumploglogin("------------msgTbl.m_msgId"..msgTbl.m_msgId)
			-- end
		-- end
	else
	--	gt.log("Could not handle Message " .. tostring(msgTbl.m_msgId))
		return false
	end

	return true
end

function SocketClient:setIsStartGame(isStartGame)
	self.isStartGame = isStartGame

	-- self.loginReconnectNum = 0

	-- 心跳消息回复
	self:registerMsgListener(gt.GC_HEARTBEAT, self, self.onRcvHeartbeat)
end


function  SocketClient:setIsCloseHeartBeat( isCloseHeartBeat )
	-- body

	gt.resume_time = 8

	self.heartbeatCD = 4

	self.closeHeartBeat = isCloseHeartBeat
end

-- start --
--------------------------------
-- @class function
-- @description 向服务器发送心跳
-- @param isCheckNet 检测和服务器的网络连接
-- end --
function SocketClient:sendHeartbeat(isCheckNet)
	

	if not self.isStartGame then
		return
	end
	
	if self.serverPort == nil then
	--	print("==================心跳包的IP， PORT", gt.curServerIp..",")
	else 
	--	print("==================心跳包的IP， PORT", gt.curServerIp..","..self.serverPort)
	end

	local msgTbl = {}
	msgTbl.kMId = gt.CG_HEARTBEAT

	if not self.closeHeartBeat then
		self:sendMessage(msgTbl)
		-- gt.log("发送心跳 ============ isCheckNet = "..tostring(isCheckNet))
	end

	self.curReplayInterval = 0

	

	self.isCheckNet = isCheckNet
	-- gt.log("发送心跳 ============ isCheckNet = "..tostring(isCheckNet))
	if isCheckNet then
		-- 防止重复发送心跳,直接进入等待回复状态
		self.heartbeatCD = -1
	end
end

-- start --
--------------------------------
-- @class function
-- @description 服务器回复心跳
-- @param msgTbl
-- end --
function SocketClient:onRcvHeartbeat(msgTbl)
	--gt.log("收到心跳应答 =============== ")
	-- dump(msgTbl)

	self.heartbeatCD = 4
	self.lastReplayInterval = self.curReplayInterval
end

-- start --
--------------------------------
-- @class function
-- @description 获取上一次心跳回复时间间隔用来判断网络信号强弱
-- @return 上一次心跳回复时间间隔
-- end --
function SocketClient:getLastReplayInterval()
	return self.lastReplayInterval
end

function SocketClient:updateNetWork( delta )
	-- 检测网络
	

end

function SocketClient:checkIsInternet(delta)
	if not self.isStartGame then
		return true
	end

	self.checkInternetTime = self.checkInternetTime - delta
	if self.checkInternetTime < 0 then
		self.checkInternetTime = self.checkInternetMaxTime
		local ok = false
		-- 保存上一次状态
		self.internetLastStatus = self.internetCurStatus
		if gt.isIOSPlatform() then
			-- 获取新的状态
			ok, self.internetCurStatus = self.luaBridge.callStaticMethod(
				"AppController", "getInternetStatus", nil)
		elseif gt.isAndroidPlatform() then
			ok, self.internetCurStatus = self.luaBridge.callStaticMethod(
				"org/cocos2dx/lua/AppActivity", "getCurrentNetworkType", nil, "()Ljava/lang/String;")
		end
		if self.internetLastStatus == "Not" and self.internetCurStatus ~= "Not" then
			self.curReplayInterval = gt.resume_time
			gt.removeLoadingTips()
			gt.log("已获取网络,重新登录!")
			-- gt.dumploglogin("已获取网络,重新登录!")
		end
		if self.internetLastStatus ~= "Not" and self.internetCurStatus == "Not" then
			gt.removeLoadingTips()
			gt.showLoadingTips(gt.getLocationString("LTKey_0001"))
			gt.log("请检查网络!")
			-- gt.dumploglogin("请检查网络!")
			return false
		end
	end
	-- 当上一次状态为空, 则保留上一次状态
	if self.internetCurStatus == "Not" then
		return false
	end
	return true
end

function SocketClient:update(delta)

	

	local isInternet = self:checkIsInternet(delta)
	if not isInternet then
		return false
	end

	self:send()
	self:receive()

	if self.isStartGame then
		if self.heartbeatCD >= 0 then
			-- 登录服务器后开始发送心跳消息
			self.heartbeatCD = self.heartbeatCD - delta
			if self.heartbeatCD < 0 then
				-- 发送心跳
				self:sendHeartbeat(true)
				self._time = socket.gettime()
			end
		else
			-- 心跳回复时间间隔
			self.curReplayInterval = self.curReplayInterval + delta
			if self.isCheckNet and self.curReplayInterval > gt.resume_time then
				gt.resume_time = 6

				self.isCheckNet = false
				-- 心跳时间稍微长一些,等待重新登录消息返回
				self.heartbeatCD = 4
				-- 监测网络状况下,心跳回复超时发送重新登录消息
				self.netWorkChangeFlag = true
				self.isReconnectFlag = false
				self:reloginServer()
			
			end
			if self._time then 
				local time = math.ceil( (socket.gettime()-self._time) *1000 )
				if self.delayed_time then 
					self:delayed_time(time)
				end
			else
				if self.delayed_time then 
					self:delayed_time()
				end
			end
		end
	end
end

function SocketClient:delayed_time(time)

	if display.getRunningScene() and display.getRunningScene().name == "pokerScene" and display.getRunningScene():getChildByName("Poker_node"):getChildByName("int")  then 
		local node = display.getRunningScene():getChildByName("Poker_node"):getChildByName("int")
		if time then 
			if time >= 999 then time = 999 end
			if time <= 60 then 
				node:setColor(cc.c3b(0,255,0))
			elseif time  > 60 and time <= 100 then 
				node:setColor(cc.c3b(255,255,0))	
			else	
				node:setColor(cc.c3b(255,0,0))
			end
			node:setString(time.."ms")
			node:setVisible(true)
		else
			node:setVisible(false)
		end
	end

end

function SocketClient:reloginServer()
	gt.removeLoadingTips()
	
	local scene = display.getRunningScene()
	if scene and scene.name then
		if scene.name ~= "MainScene" and scene.name ~= "MJScene" then 
			gt.showLoadingTips(gt.getLocationString("LTKey_0050"))
		elseif scene.name == "MainScene" then 
			gt.dispatchEvent("MainSceneAddText")
		elseif scene.name == "MJScene" then 
			gt.dispatchEvent("MJSceneAddText")
		end
	end

	gt.connecting = true

	self.closeHeartBeat = true
	
	-- 链接关闭重连
	self:close()
	self.serverPort = gt.LoginServer.port
	return self:connectResume()
end

function SocketClient:SendRelogin( )
	-- body
	-- 发送重联消息
	local runningScene = display.getRunningScene()
	if runningScene and runningScene.reLogin then
		runningScene:reLogin()
	end
end

function SocketClient:networkErrorEvt(eventType, errorInfo)
	gt.log("networkErrorEvt errorInfo:" .. errorInfo)

	if self.isPopupNetErrorTips then
		return
	end

	if self.isStartGame then
		return
	end

	local tipInfoKey = "LTKey_0047"
	if errorInfo == "connection refused" then
		-- 连接被拒提示服务器维护中
		tipInfoKey = "LTKey_0002"
	end
	
	
	

	self.isPopupNetErrorTips = true
	require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString(tipInfoKey),
		function()
			self.isPopupNetErrorTips = false
			gt.removeLoadingTips()
			gt.log("去掉转圈  555555 ===============")

			if errorInfo == "timeout" then
				-- 检测网络连接
				self:sendHeartbeat(true)
				gt.log("发送心跳 链接已断开 333333 ")
			end
		end, nil, true)
end


-- 进行一些必须的善后处理,更包的时候,再把清理定时器等拿到这个函数内
function SocketClient:clearSocket()
	
	-- 登录状态,有三次自动重连的机会
	-- self.loginReconnectNum = 0
end


function SocketClient:getMessageHead(messageEntity)
	-- 对包体产生随机数，以便生成md5
	local msgEntityLen = string.len(messageEntity)
	local beginPos = 0
	local endPos = 0
	
	if msgEntityLen > 0 then
		beginPos = math.random(msgEntityLen)
	end
	
	endPos = beginPos
	local remainLen = msgEntityLen - beginPos
	if remainLen > 0 then
		endPos = beginPos + math.random(math.min(128, remainLen))
	end
	
	local md5 = ""
	if beginPos > 0 and endPos >= beginPos then
		local stringMd5 = ""
		for i = beginPos, endPos, 1 do
			local tmp = tonumber(string.byte(messageEntity, i))
			stringMd5 = stringMd5 .. string.format("%02X", tmp)
		end
		md5 = cc.UtilityExtension:generateMD5(stringMd5, string.len(stringMd5))
	else
		beginPos = 0
		endPos   = 0
	end

	if self.playerKeyOnGate == nil or self.playerMsgOrder == nil then
		local data = {}
		local uid = cc.UserDefault:getInstance():getIntegerForKey("User_Id", gt.playerData.uid or 0)
		data.uid = uid
		data.m_msgId = self.m_msgId
		local runningScene = display.getRunningScene()
	   	if runningScene and runningScene.name then
			data.name = runningScene.name
			local ReLoginNoticeTips = require("client/game/dialog/NoticeTipsReLogin"):create(data)
			runningScene:addChild(ReLoginNoticeTips, 666)
	   	end
	end
	
	-- print("11111self.playerMsgOrder:",self.playerMsgOrder)
	self.playerMsgOrder = self.playerMsgOrder + 1
	-- print("2222self.playerMsgOrder:",self.playerMsgOrder)
	local msgHeadData = {}
	msgHeadData.kMId = gt.CG_VERIFY_HEAD
	msgHeadData.kUserId    = self.playerUUID
	msgHeadData.kStart    = beginPos
	msgHeadData.kEnd      = endPos
	msgHeadData.kPwd       = md5
	msgHeadData.kAuthKey = self.playerKeyOnGate
	msgHeadData.kSequence    = self.playerMsgOrder
	-- print("2222msgHeadData.m_lMsgOrder :",msgHeadData.m_lMsgOrder)
	return msgHeadData
end

function SocketClient:setPlayerUUID(playerUUID)
	self.playerUUID = playerUUID
end

function SocketClient:getPlayerUUID()
	return self.playerUUID
end

function SocketClient:setPlayerKeyAndOrder(keyOnGate, msgOrder)
	self.playerKeyOnGate = keyOnGate
	self.playerMsgOrder  = msgOrder
end

function SocketClient:onGetIPSucceed(ipstate)
	local name = ipstate:getName() == nil and "" or ipstate:getName()
	local ip = ipstate:getIP() == nil and "" or ipstate:getIP()
	local port = ipstate:getPort() == nil and "" or ipstate:getPort()
	secure.log("Socket 建立连接， SocketClient:onGetIPSucceed name 1:"..name..", ip:"..ip.. " request success")
	
		secure.log("Socket 建立连接， SocketClient:onGetIPSucceed name 2:"..name..", ip:"..ip.. ", port:" .. port.. " request success")
		self.serverIp = secure.manager:getIP()
		self.serverPort = secure.manager:getPort()
		local result = self:connect(self.serverIp, self.serverPort, self.isBlock)
		if not result then
			self:reloginServer()
			return
		end
		self:SendRelogin()
	
end

function SocketClient:onGetIPFailed(ipstate)

	local ip = ""
	local port = 0
	if gt.release then 
		--ip = "poker.haoyunlaiyule2.com"
		ip = "antizypk.ttcdn.cn"
		port = 17141
	else
		ip = "101.201.104.28"

		port = 18201

	end
	-- gt.dumploglogin("http error_____________")
	
		self.serverIp = ip
		self.serverPort = port
		local result = self:connect(self.serverIp, self.serverPort, self.isBlock)
		if not result then
			self:reloginServer()
			return
		end
		self:SendRelogin()
	
end

-- function SocketClient:getSecureIP(unionid, succeedCall, failedCall)
-- 	print("===========================这里是初始化manager, getSecureIP")
-- 	self.getIPSucceedCall = succeedCall
-- 	self.getIPFailedCall = failedCall
-- 	require("app/secure/init")
-- 	secure.manager:init({uuid=unionid, succeedCall=handler(self, self.onGetIPSucceed), failedCall=handler(self, self.onGetIPFailed)})
-- 	secure.manager:request()
-- end

function SocketClient:getSecureIP(unionid)
	require("client/message/init")
	secure.manager:init({uuid=unionid, succeedCall=handler(self, self.onGetIPSucceed), failedCall=handler(self, self.onGetIPFailed)})
end

function SocketClient:savePlayCount(count)
	if count then
		require("client/message/init")
		secure.manager:savePlayCount(count)
	end
end

function SocketClient:setLoginLog()
    --测试
	gt.log("------------------------登陆判断有文件就上传")
	if cc.FileUtils:getInstance():isFileExist(cc.FileUtils:getInstance():getWritablePath().."testlogin.txt") then
		local filePath = cc.FileUtils:getInstance():getWritablePath().."testlogin.txt"
		local fileName = (gt.playerData.uid or "").."testlogin.txt"

		if gt.isIOSPlatform() then
			self.luaBridge = require("cocos/cocos2d/luaoc")
		elseif gt.isAndroidPlatform() then
			self.luaBridge = require("cocos/cocos2d/luaj")
		end
		gt.log("------------------------uploadFile")
		if gt.isIOSPlatform() then
			-- local ok = self.luaBridge.callStaticMethod("AppController", "uploadFile", {url = gt.getUrlEncryCode(gt.uploadLog, gt.playerData.uid), filePath = filePath, fileName = fileName})
		elseif gt.isAndroidPlatform() then
			local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "uploadFile", {filePath, fileName}, "(Ljava/lang/String;Ljava/lang/String;)V")
		end
	end
end

return SocketClient