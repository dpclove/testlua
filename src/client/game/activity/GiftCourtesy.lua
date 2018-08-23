
local gt = cc.exports.gt

local GiftCourtesy = class("GiftCourtesy", function()
	return gt.createMaskLayer()
end)

local giftCourtesyBtnPosY = {320, 510, 415, 415}

function GiftCourtesy:ctor(bindcoin)
	local csbNode = cc.CSLoader:createNode("GiftCourtesy.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.csbNode = csbNode
	--bing = not bing
	self.sendIdentifyingCodeTime = cc.UserDefault:getInstance():getStringForKey("IdentifyingCodeTime"..tostring(gt.playerData.uid), 0)

	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	
	gt.seekNodeByName(self, "Img_goldNumber"):setString(bindcoin or 6)

	-- 返回按键
	local closeBtn = gt.seekNodeByName(self, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		if bind  then 
			cc.UserDefault:getInstance():setIntegerForKey("Activity_type",5)
		else
			cc.UserDefault:getInstance():setIntegerForKey("Activity_type",1)
		end
		self:removeFromParent()
	end)

	self:init()

	self:giftCourtesyType()
    self:runtimeScheduler()

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	self.customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
								handler(self, self.onEnterForeground))
	eventDispatcher:addEventListenerWithFixedPriority(self.customListenerFg, 1)

	-- 马上，来自北京的电话010-86391991将会告知您【验证码】，请注意接听。
	-- 如果60s后，无法收到短信验证码，请点击【电话验证码】，及时收听来自北京的电话。


end


function GiftCourtesy:addBtnPressedListener(btn, listener, sfxType, scale)
	if not btn or not listener then
		return
	end
	local time = 0 
	btn:addClickEventListener(function(sender)

		if math.abs(os.clock() - time) > 2 then
			time = os.clock()
			listener(sender)
			gt.soundEngine:playEffect("common/audio_button_click", false)
		end
	end)

	if not scale then
		scale = -0.1
	end
	if scale then
		btn:setPressedActionEnabled(true)
		btn:setZoomScale(scale)
	end
end

function GiftCourtesy:init()

	if gt.isbind then 
		gt.seekNodeByName(self.csbNode, "Node_1"):setVisible(false)
		gt.seekNodeByName(self.csbNode, "Text_3"):setVisible(true)
	end

end

local CardType = {
1003,-- => "七小对",  --                                                                      
1004,-- => "豪华七小对",                                                                    
1006,-- => "一条龙",                                                                        
1007,-- => "十三幺",                                                                        
1027,-- => "清龙",      --                                                                    
1028,-- => "清七对",     --                                                                   
1029,-- => "字一色",                                                                        
1030,-- => "清豪华七小对",  --                                                                
1055,-- => "楼上楼",                                                                        
2000,-- => "-111分",                                                                        
3000,-- => "+111分",                                                                        
4000-- => "金暗杠",   
}
function GiftCourtesy:share(money,coin,id,desc)

	-- 新的快捷语音 
	-- 碰杠胡 特效小

	--杠碰胡过

	local name = gt.nickname or ""
	money =  money or 0
	coin = coin or 0
	id = id or 0

	if self.type then 
		self.type = tonumber(self.type)
	end

	local str = "好运来"
	if tonumber(self.type) == 1 or tonumber(self.type) == 2 then 
		str = str.."-幸运卡"
	elseif tonumber(self.type) == 200 then 
		if tonumber(self.CardType) == 1003 then 
		str = str.."-七小对"
		elseif tonumber(self.CardType) == 1004 then 
		str = str.."-豪华七小对"
		elseif tonumber(self.CardType) == 1006 then 
		str = str.."-一条龙"
		elseif tonumber(self.CardType) == 1007 then 
		str = str.."-十三幺"
		elseif tonumber(self.CardType) == 1027 then 
		str = str.."-清龙"
		elseif tonumber(self.CardType) == 1028 then 
		str = str.."-清七对"
		elseif tonumber(self.CardType) == 1029 then 
		str = str.."-字一色"
		elseif tonumber(self.CardType) == 1030 then 
		str = str.."-清豪华七小对"
		elseif tonumber(self.CardType) == 1055 then 
		str = str.."-楼上楼"
		elseif tonumber(self.CardType) == 2000 or tonumber(self.CardType) == 3000 then 
		str = str.."-正负111分"
		elseif tonumber(self.CardType) == 4000 then 
		str = str.."-金暗杠"
		end
	elseif tonumber(self.type) == 100 then 
		str = str.."-普惠奖"
	end

	local url = gt.HTTP_WEB_SHAER.."follow.html?name="..name.."&card="..str.."&money="..money.."&coin="..coin.."&desc="..desc.."&task_id="..id.."&"
	local str2 = "我获得了"..desc..",戳这里领奖！！！"
	local str1 = "每月10万元福利天天送,天天好运来,天天有福利"
	Utils.shareURLToHY(url,str2,str1)


end

function GiftCourtesy:onNodeEvent(eventName)
	gt.log("eventName",eventName)
	if "exit" == eventName then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.customListenerFg)

		if self.sendedtimetxtScheduler then
			gt.log("close______________")
 			gt.scheduler:unscheduleScriptEntry(self.sendedtimetxtScheduler)
 			self.sendedtimetxtScheduler = nil
 		end

	end
end

function GiftCourtesy:onEnterForeground()
    self:runtimeScheduler()
end

function GiftCourtesy:numBtnPressed(senderBtn)
	if self.NumberBtnType == 1 then
		local numberString = self.phoneNumberTxtInput:getString()

		if string.len(numberString) == 11 then
			return
		end

		local btnTag = senderBtn:getTag()

		numberString = numberString .. tostring(btnTag)

		self.phoneNumberTxtInput:setString(numberString)
	elseif self.NumberBtnType == 2 then
		local numberString = self.identifyingcodeTxtInput:getString()

		if string.len(numberString) == 4 then
			return
		end

		local btnTag = senderBtn:getTag()

		numberString = numberString .. tostring(btnTag)

		self.identifyingcodeTxtInput:setString(numberString)
	end
end

function GiftCourtesy:phoneNumberBind()
    gt.log("------------------------inviteID", inviteID)
    --提交邀请码
    Utils.commitInvite(inviteID, runScene, function( errno, msg )
		local RunningScene = cc.Director:getInstance():getRunningScene()
        Toast.showToast(RunningScene, msg, 2)
	    if errno == 0 then
            self:closeLayer()
        end
    end)	
end

--绑定手机号
function GiftCourtesy:giftCourtesyType()
	-- 输入类型
	self.NumberBtnType = 1

	-- 手机号最大输入11个数字
	self.phoneInputMaxCount = 11

	-- 验证码最大输入4个数字
	self.identifyingcodeInputMaxCount = 4

	-- 手机号
	self.phoneNumberBtn = gt.seekNodeByName(self.csbNode, "Btn_phoneNumber")
	self.phoneNumberTxtInput = gt.seekNodeByName(self.csbNode, "Txt_phoneNumberInput")
	-- 验证码
	self.identifyingcodeBtn = gt.seekNodeByName(self.csbNode, "Btn_identifyingcode")
	self.identifyingcodeTxtInput = gt.seekNodeByName(self.csbNode, "Txt_identifyingcodeInput")

	-- 手机号按钮
	self.phoneNumberBtn:addClickEventListener(function(sender)
		self.NumberBtnType = 1
		self.inputImg:setVisible(true)
		self.bindBtn:setVisible(false)
		-- self.phoneNumberBtn:setTouchEnabled(false)
		self.phoneNumberBtn:setBright(false)
		-- self.identifyingcodeBtn:setTouchEnabled(true)
		self.identifyingcodeBtn:setBright(true)
	end)

	-- 验证码按钮
	self.identifyingcodeBtn:addClickEventListener(function(sender)
		self.NumberBtnType = 2
		self.inputImg:setVisible(true)
		self.bindBtn:setVisible(false)
		-- self.phoneNumberBtn:setTouchEnabled(true)
		self.phoneNumberBtn:setBright(true)
		-- self.identifyingcodeBtn:setTouchEnabled(false)
		self.identifyingcodeBtn:setBright(false)
	end)

	-- 数字按键
	for i = 0, 9 do
		local numBtn = gt.seekNodeByName(self.csbNode, "Btn_num_" .. i)  --遍历数字按键
		numBtn:setTag(i)  --设置标记为0-9
		gt.addBtnPressedListener( numBtn, handler(self,self.numBtnPressed))--添加点击事件
	end

    -- 删除按键
	local delBtn = gt.seekNodeByName(self.csbNode, "Btn_del")
	gt.addBtnPressedListener(delBtn, function()
		if self.NumberBtnType == 1 then
			local numberString = self.phoneNumberTxtInput:getString()
			if string.len(numberString) == 1 then
				self.phoneNumberTxtInput:setString("")
			else
				self.phoneNumberTxtInput:setString(string.sub(numberString, 1, string.len(numberString) - 1))
			end
		elseif self.NumberBtnType == 2 then
			local numberString = self.identifyingcodeTxtInput:getString()
			if string.len(numberString) == 1 then
				self.identifyingcodeTxtInput:setString("")
			else
				self.identifyingcodeTxtInput:setString(string.sub(numberString, 1, string.len(numberString) - 1))
			end
		end
	end)

	-- 确定按钮
	local enterBtn = gt.seekNodeByName(self.csbNode, "Btn_enter")
	gt.addBtnPressedListener(enterBtn, function()

		self.inputImg:setVisible(false)
		self.bindBtn:setVisible(true)
	end)


	-- 获取验证码
	self.getIdentifyingcodeBtn = gt.seekNodeByName(self.csbNode, "Btn_getIdentifyingcode1")
	gt.addBtnPressedListener(self.getIdentifyingcodeBtn, function()
		if self.phoneNumberTxtInput:getString() == "" then
               Toast.showToast(self, "请输入手机号码", 2)
		else
			self:setIdentifyingCode(self.phoneNumberTxtInput:getString(),1)
			self.inputImg:setVisible(false)
			self.bindBtn:setVisible(true)
		end
	end)
	self.getIdentifyingcodeBtn1 = gt.seekNodeByName(self.csbNode, "Btn_getIdentifyingcode2")
	gt.addBtnPressedListener(self.getIdentifyingcodeBtn1, function()
		if self.phoneNumberTxtInput:getString() == "" then
               Toast.showToast(self, "请输入手机号码", 2)
		else
			self:setIdentifyingCode(self.phoneNumberTxtInput:getString(),2)
			self.inputImg:setVisible(false)
			self.bindBtn:setVisible(true)
		end
	end)
	self.getIdentifyingcodeBtn:setEnabled(true)

	--发送验证码倒计时
	self.sendedtimetxt = gt.seekNodeByName(self.csbNode, "txt_sendedtime")
	self.sendedtimetxt:setVisible(false)
	self.sendedtimetxt1 = gt.seekNodeByName(self.csbNode, "txt_sendedtime1")
	self.sendedtimetxt1:setVisible(false)
	
	-- 输入按钮
	self.inputImg = gt.seekNodeByName(self.csbNode, "Img_input")
	self.inputImg:setVisible(false)


	-- 绑定按钮
	self.bindBtn = gt.seekNodeByName(self.csbNode, "Btn_bind")
	self.bindBtn:setVisible(true)
	gt.addBtnPressedListener(self.bindBtn, function()
		if self.phoneNumberTxtInput:getString() == "" then
            Toast.showToast(self, "请输入手机号码", 2)

        elseif self.identifyingcodeTxtInput:getString() == "" then
            Toast.showToast(self, "请输入验证码", 2)
        else
			self:setbindMobile(self.phoneNumberTxtInput:getString(), self.identifyingcodeTxtInput:getString())
			self.inputImg:setVisible(false)
			self.bindBtn:setVisible(true)
			gt.seekNodeByName(self.csbNode, "text_phone"):setVisible(false)
			gt.seekNodeByName(self.csbNode, "text_mes"):setVisible(false)
		end
	end)
end

function GiftCourtesy:setIdentifyingCode(mobile,_type)

	local phoneText= gt.seekNodeByName(self.csbNode, "text_phone")
	local mesText = gt.seekNodeByName(self.csbNode, "text_mes")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON

	local IdentifyingCodeURL = ""
	if _type == 2 then 
		gt.log("csw-------mobile")
		gt.log(gt.bindMobile)
		gt.log(mobile)
		IdentifyingCodeURL = gt.getUrlEncryCode(string.format(gt.identifyingCode1, mobile), gt.playerData.uid)
	else
	    IdentifyingCodeURL = gt.getUrlEncryCode(string.format(gt.identifyingCode, mobile), gt.playerData.uid)
	end
	xhr:open("GET", IdentifyingCodeURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local response = xhr.response
            local respJson = require("cjson").decode(response)
            gt.dump(respJson)
            if respJson.errno == 0 then
                gt.dump(respJson)
                if _type == 1 then phoneText:setVisible(false) mesText:setVisible(true) end
                if _type == 2 then mesText:setVisible(false) phoneText:setVisible(true) end
                cc.UserDefault:getInstance():setStringForKey("IdentifyingCodeTime"..tostring(gt.playerData.uid), os.time())
                self:runtimeScheduler()
            else
                Toast.showToast(self, respJson.errmsg, 2)
            end
		elseif xhr.readyState == 1 and xhr.status == 0 then
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function GiftCourtesy:setbindMobile(mobile, code)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local bindMobileURL = gt.getUrlEncryCode(string.format(gt.bindMobile, mobile, code), gt.playerData.uid)
	xhr:open("GET", bindMobileURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local response = xhr.response
            local respJson = require("cjson").decode(response)
            if respJson.errno == 0 then
                gt.dump(respJson)
				self:removeFromParent()
				require("client/game/dialog/NoticeTipsCommon"):create(2, respJson.data.message, function ( )
					local runningScene = cc.Director:getInstance():getRunningScene()
					if runningScene.refreshMoney then
						runningScene:refreshMoney()
					end
					if runningScene.setShareGiftBtn then
						runningScene:setShareGiftBtn()
					end
				end)
            else
                Toast.showToast(self, respJson.errmsg, 2)
            end
		elseif xhr.readyState == 1 and xhr.status == 0 then
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function GiftCourtesy:runtimeScheduler()
	self.sendIdentifyingCodeTime = cc.UserDefault:getInstance():getStringForKey("IdentifyingCodeTime"..tostring(gt.playerData.uid), 0)
	self.sendedtime = 60 - (os.time() - self.sendIdentifyingCodeTime)

	if self.sendedtime <= 0 then
		return
	end
	self.getIdentifyingcodeBtn1:setEnabled(false)
    self.getIdentifyingcodeBtn:setEnabled(false)
    self.sendedtimetxt:setVisible(true)
    self.sendedtimetxt:setString(self.sendedtime.."S")
    self.sendedtimetxt1:setVisible(true)
    self.sendedtimetxt1:setString(self.sendedtime.."S")

 	local runtime = function()
		if self.sendedtime  == nil then
	 		if self.sendedtimetxtScheduler then
	 			gt.scheduler:unscheduleScriptEntry(self.sendedtimetxtScheduler)
	 			self.sendedtimetxtScheduler = nil
	 		end
	 	else
	 		self.sendedtime = self.sendedtime - 1
	    	self.sendedtimetxt:setString(self.sendedtime.."S")
	    	self.sendedtimetxt1:setString(self.sendedtime.."S")
	    	if self.sendedtime <=0 then
	            self.getIdentifyingcodeBtn:setEnabled(true)
	            self.getIdentifyingcodeBtn1:setEnabled(true)
	            self.sendedtimetxt:setVisible(false)
	            self.sendedtimetxt1:setVisible(false)
	            cc.UserDefault:getInstance():setStringForKey("IdentifyingCodeTime"..tostring(gt.playerData.uid), 0)
		 		if self.sendedtimetxtScheduler then
		 			gt.scheduler:unscheduleScriptEntry(self.sendedtimetxtScheduler)
		 			self.sendedtimetxtScheduler = nil
		 		end
		 	end
		end
 	end
 	
 	gt.log("-----------------gt.scheduler")

	if self.sendedtimetxtScheduler then
		gt.scheduler:unscheduleScriptEntry(self.sendedtimetxtScheduler)
		self.sendedtimetxtScheduler = nil
	end

    self.sendedtimetxtScheduler = gt.scheduler:scheduleScriptFunc(runtime, 1, false)
end

return GiftCourtesy