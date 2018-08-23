--[[
	商城界面
	2017_05_31  zhangzhongbin
]]
local gt = cc.exports.gt

local ShoppingLayer = class("ShoppingLayer", function()
    return gt.createMaskLayer()
end)

-- ShoppingLayer.CB_ZUANSHI = 1
-- ShoppingLayer.CB_JINBI = 2
-- ShoppingLayer.CB_COIN_BUY = 3 --金币购买按钮tag
-- ShoppingLayer.CB_GOLD_BUY = 9 --淘金券
ShoppingLayer.CB_RETURN = 15
ShoppingLayer.CB_SELECTPAYRETURN = 16
-- ShoppingLayer.cb_EXCHNAG = 20
ShoppingLayer.CB_JINBI = 1

function ShoppingLayer:ctor( scene )
    if gt.isIOSPlatform() then
        self.luaBridge = require("cocos/cocos2d/luaoc")
    elseif gt.isAndroidPlatform() then
        self.luaBridge = require("cocos/cocos2d/luaj")
    end

        -- gt.dispatchEvent(gt.EventType.REFRESH_CARD_COUNT, 100)
	self._scene = scene
	--注册触摸事件
    -- ExternalFun.registerTouchEvent(self, true)

    local csbNode = cc.CSLoader:createNode("ShoppingLayer.csb")
    csbNode:setAnchorPoint(0.5, 0.5)
    csbNode:setPosition(gt.winCenter)
    self:addChild(csbNode)

    self.rootNode = csbNode

    -- 注册节点事件
    self:registerScriptHandler(handler(self, self.onNodeEvent))

    self.m_imgBg = gt.seekNodeByName(csbNode, "m_imgBg")
    self.m_imgBg:getParent():reorderChild(self.m_imgBg, 3)

  

    self.chargeTypeBtn = {}
    self.chargeType = 1
    self.chargeType1Btn = gt.seekNodeByName(csbNode, "Btn_chargeType1")
    self.chargeType1Btn:setTag(1)
    self.chargeType1Btn:addClickEventListener(function(sender)
        gt.soundEngine:playEffect("common/audio_button_click", false)
        self.chargeTypeBtn[1]:setTouchEnabled(false)
        self.chargeTypeBtn[1]:setBright(false)
        self.chargeTypeBtn[2]:setTouchEnabled(true)
        self.chargeTypeBtn[2]:setBright(true)
        self.chargeType = sender:getTag()
        self.Panel_1:setVisible(true)
        self.Panel_2:setVisible(false)
        self:requestPrice()
    end)
    table.insert(self.chargeTypeBtn, self.chargeType1Btn)

    self.chargeType2Btn = gt.seekNodeByName(csbNode, "Btn_chargeType2")
    self.chargeType2Btn:setTag(2)
    self.chargeType2Btn:setVisible(false)
    self.chargeType2Btn:addClickEventListener(function(sender)
        gt.soundEngine:playEffect("common/audio_button_click", false)
        self.chargeTypeBtn[1]:setTouchEnabled(true)
        self.chargeTypeBtn[1]:setBright(true)
        self.chargeTypeBtn[2]:setTouchEnabled(false)
        self.chargeTypeBtn[2]:setBright(false)
        self.chargeType = sender:getTag()
        self.Panel_1:setVisible(false)
        self.Panel_2:setVisible(true)
        self:requestPrice()
    end)
    table.insert(self.chargeTypeBtn, self.chargeType2Btn)

    self.Panel_1 = gt.seekNodeByName(csbNode, "Panel_1")
    self.Panel_1:setVisible(true)
    self.Panel_2 = gt.seekNodeByName(csbNode, "Panel_2")
    self.Panel_2:setVisible(false)
    self.chargeTypeBtn[1]:setTouchEnabled(false)
    self.chargeTypeBtn[1]:setBright(false)
    self.chargeTypeBtn[2]:setTouchEnabled(true)
    self.chargeTypeBtn[2]:setBright(true)

    --关闭按钮
    local btn = self.m_imgBg:getChildByName("m_btnClose")
    btn:setTag(ShoppingLayer.CB_RETURN)
    gt.addBtnPressedListener(btn, function()
        self:removeFromParent()
    end)


    self.lblSXMJCoin = gt.seekNodeByName(csbNode, "Txt_coin")

    if gt.isAppStoreInReview then
        btnTransfer:setVisible(false)
    end 

    self.btnConfirm = gt.seekNodeByName(csbNode, "Btn_confirm")
    gt.addBtnPressedListener(self.btnConfirm, function()
        if self.lblSXMJCoin and self.lblSXMJCoin:getString() == "0" then
            Toast.showToast(self, "可导入的金币为 0", 2)
        else
            self:requestImportSXMJCoin()
        end
    end)

    self.btnCancel = gt.seekNodeByName(csbNode, "Btn_cancel")
    gt.addBtnPressedListener(self.btnCancel, function()
        self.panelTransfer:setVisible(false)
    end)

    local btnSuccessClose = gt.seekNodeByName(csbNode, "Btn_success_close")
    gt.addBtnPressedListener(btnSuccessClose, function()
        self.panelSuccess:setVisible(false)
    end)

 --    --钻石和金币node
 --    self._zuanshiNode = self.sp_bg:getChildByName("zuanshiNode")
 --    self._jinbiNode = self.sp_bg:getChildByName("jinbiNode")

 --    self._btZuanShi = self.sp_bg:getChildByName("zuanshi")
 --    self._btZuanShi:setTag(ShoppingLayer.CB_ZUANSHI)
 --    self._btZuanShi:addTouchEventListener(btncallback)
 --    self._btJinBi = self.sp_bg:getChildByName("jinbi")
 --    self._btJinBi:setTag(ShoppingLayer.CB_JINBI)
 --    self._btJinBi:addTouchEventListener(btncallback)
	
	-- self._exchangeBtn = self.sp_bg:getChildByName("exchange")
	-- self._exchangeBtn:setTag(ShoppingLayer.cb_EXCHNAG)
	-- self._exchangeBtn:addTouchEventListener(btncallback)

 --    --升级维护
 --    cc.Sprite:create("Shop/icon_UpgradeMaintenance.png")
 --    :setAnchorPoint(1,1)
 --    :addTo(self._btZuanShi )
 --    :move(self._btZuanShi:getContentSize().width,
 --     self._btZuanShi:getContentSize().height)    

 --    --钻石购买按钮
 --    self._goldBtn = {}
 --    local btn
 --    for i = 0, 5 do
 --        btn = self._zuanshiNode:getChildByName("zuan_ditu_" .. tostring(i + 1)):getChildByName("buy")
 --        btn:setTag(ShoppingLayer.CB_GOLD_BUY + i)
 --        btn:setSwallowTouches(true)
 --        btn:addTouchEventListener(btncallback)
 --        table.insert(self._goldBtn, btn)
 --    end
 
    --金币购买按钮
    for i = 0, 5 do
        local btn = self.m_imgBg:getChildByName("Panel_1"):getChildByName("Node"..(i + 1)):getChildByName("m_btn")
        btn:setTag(ShoppingLayer.CB_JINBI + i)
        btn:addTouchEventListener(handler(self, self.onTouchPageHandler))
    end

    --房卡购买按钮
    for i = 0, 2 do
        gt.log("----------------test")
        local btn = self.m_imgBg:getChildByName("Panel_2"):getChildByName("Node"..(i + 1)):getChildByName("m_btn")
        btn:setTag(ShoppingLayer.CB_JINBI + i)
        btn:addTouchEventListener(handler(self, self.onTouchPageHandler))
    end

    self:requestPrice()
 --    --加载动画
 --    local call = cc.CallFunc:create(function()
 --        self:setVisible(true)
 --    end)
 --    local scale = cc.ScaleTo:create(0.2, 1.0)
 --    self.m_actShowAct = cc.Sequence:create(call, scale)
 --    ExternalFun.SAFE_RETAIN(self.m_actShowAct)

 --    local scale1 = cc.ScaleTo:create(0.2, 0.0001)
 --    local call1 = cc.CallFunc:create(function( )
 --        self:setVisible(false)
 --    end)
 --    self.m_actHideAct = cc.Sequence:create(scale1, call1)
 --    ExternalFun.SAFE_RETAIN(self.m_actHideAct)
 --    self:onChangeNode(ShoppingLayer.CB_JINBI)
end

function ShoppingLayer:onNodeEvent(eventName)
    if "exit" == eventName then
        if self.scheduler then
            gt.scheduler:unscheduleScriptEntry(self.scheduler)
            self.scheduler = nil
        end
    end
end

function ShoppingLayer:onTouchPageHandler(sender, eventType)
    gt.log("--------------sender:getTag()", sender:getTag())
    local btnPanel = self.m_imgBg:getChildByName("Panel_"..self.chargeType):getChildByName("Node"..sender:getTag()):getChildByName("m_btn")
    if eventType == ccui.TouchEventType.began then
        btnPanel:setScale(0.9)
    elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
        btnPanel:setScale(1)
        local data = {}
        data.ID = sender:getTag()
        if gt.isAppStoreInReview then
            Charge.buy(data.ID)
        else
            self:onPayment(data)
        end
    end
end

-- 支付弹窗
function ShoppingLayer:onPayment(data)
    gt.log("Payment======")
    -- 判断是否安装微信客户端
    local isWXAppInstalled = false
    if gt.isIOSPlatform() then
        local ok, ret = self.luaBridge.callStaticMethod("AppController", "isWXAppInstalled")
        isWXAppInstalled = ret
    elseif gt.isAndroidPlatform() then
        local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "isWXAppInstalled", nil, "()Z")
        isWXAppInstalled = ret
    end

    -- local quitBtn = gt.seekNodeByName(self.rootNode, "quit_btn")
    -- self:onQuitBtn(quitBtn)

    -- -- 微信
    -- local weChatBtn = gt.seekNodeByName(self.rootNode, "we_chat_btn")
    -- self.weChatBtn = weChatBtn
    -- self.schedulerEntry = nil
    -- -- 定时器   2秒内不能连续点击微信按钮
    -- local unpause = function ()
    --     if self.schedulerEntry then
    --         gt.scheduler:unscheduleScriptEntry(self.schedulerEntry)
    --         self.schedulerEntry = nil
    --         self.weChatBtn:setTouchEnabled(true)
    --     end
    -- end

    -- gt.addBtnPressedListener(weChatBtn, function()
        -- weChatBtn:setTouchEnabled(false)
        -- self.schedulerEntry = gt.scheduler:scheduleScriptFunc(unpause, 2, false)
        -- 判断是否安装了微信
        if not isWXAppInstalled and (gt.isAndroidPlatform() or
            (gt.isIOSPlatform() and not gt.isInReview)) then
            require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0031"), nil, nil, true)
            return          
        end 
        -- 调微信支付接口
        gt.log("调微信支付")
        self:onPay(data, "1")
    -- end)        

    -- -- 支付宝
    -- local alipayBtn = gt.seekNodeByName(self.rootNode, "alipay_btn")
    -- alipayBtn:setVisible(false)
    -- alipayBtn:setTouchEnabled(false)
    -- gt.addBtnPressedListener(alipayBtn, function()
    --     -- 调支付宝支付接口
    --     -- self:onPay("ZFB")
    -- end)
end

-- 调支付接口
function ShoppingLayer:onPay(data, payType)
    -- local unionid = gt.playerData.unionid  -- 玩家唯一id
    local uid = gt.playerData.uid  -- 玩家id
    -- local gameType = 10001         -- 游戏类型
    local payType = payType          -- (支付方式-ZFB 微信 -WX)
    -- local payMoney = data.money    -- 消费金额
    self.moneyId = data.ID      -- 商品id
    -- local buyCount = data.Price    -- 购买数量
    -- local send = data.Give_Di      -- 赠送数量
    local time = os.time()
    local serverCode = "hunan_db"
    local catStr = string.format("%s%s%s%s%s%s%s%s%s%s", unionid, uid, gameType, payType, payMoney, self.moneyId, buyCount, send, time, serverCode)
    local token = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local refreshTokenURL = string.format(gt.payUrl, self.chargeType, self.moneyId, payType)

    gt.log("------------------------refreshTokenURL"..refreshTokenURL)
    
    xhr:open("POST", gt.getUrlEncryCode(refreshTokenURL, uid))

    local function onResp()
        gt.log("--------------------------xhr.readyState"..xhr.readyState)
        gt.log("--------------------------xhr.response"..xhr.response)
        gt.dump(xhr.readyState)
        local runningScene = display.getRunningScene()
        if runningScene and runningScene.name == "MainScene" and runningScene:getChildByName("ShoppingLayer") then
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                -- if self.schedulerEntry then 
                    local response = xhr.response
                    local respJson = require("cjson").decode(response)
                    if respJson.errno == 0 then
                        gt.dump(respJson)
                        local order = respJson.data.unified_order
                        local partnerId = order.partnerid
                        local prepayId = order.prepayid
                        local nonceStr = order.noncestr
                        local timeStamp = tostring(order.timestamp)
                        local package = order.wxpackage
                        local sign = order.sign

                        local wx_pay = order.appid
                        if gt.isIOSPlatform() then
                            local ok = self.luaBridge.callStaticMethod("AppController", "jumpToBizPayMore", {partnerId = partnerId,prepayId = prepayId,nonceStr = nonceStr,timeStamp = timeStamp,package = package,sign = sign,wx_pay = wx_pay})
                            self.luaBridge.callStaticMethod("AppController", "registerPayResultHandler", {scriptHandler = handler(self, self.onPayResult)})
                        elseif gt.isAndroidPlatform() then
                            local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "jumpToBizPayMore", {partnerId,prepayId,nonceStr,timeStamp,package,sign, wx_pay},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
                            self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerPayResultHandler", {handler(self, self.onPayResult)}, "(I)V")
                        end
                    else
                        self.scheduler = gt.scheduler:scheduleScriptFunc(function(delta)
                            gt.scheduler:unscheduleScriptEntry(self.scheduler)
                            Toast.showToast(self, respJson.errmsg, 2)
                        end, 0.1, false)
                    end

                -- end
            elseif xhr.readyState == 1 and xhr.status == 0 then
                -- 本地网络连接断开
                require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
            end
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onResp)
    xhr:send()
end

function ShoppingLayer:onPayResult(result)
    if tonumber(result) == -2 then
        self.scheduler = gt.scheduler:scheduleScriptFunc(function(delta)
            gt.scheduler:unscheduleScriptEntry(self.scheduler)
            Toast.showToast(self, "支付失败，请重新尝试", 2)
        end, 0.1, false)
    else
        self.scheduler = gt.scheduler:scheduleScriptFunc(function(delta)
            gt.scheduler:unscheduleScriptEntry(self.scheduler)
            if self.chargeType == 1 then
                Toast.showToast(self, "金币购买成功，如无更新请点击刷新按钮", 2)
                local addMoney = self.datatable[self.moneyId].diamond + self.datatable[self.moneyId].coins
                gt.dispatchEvent(gt.EventType.REFRESH_CARD_COUNT, addMoney)
            elseif self.chargeType == 2 then
                Toast.showToast(self, "房卡充值成功，请到分销后台->文娱馆查看", 2)
            end
        end, 0.1, false)
    end
end

function ShoppingLayer:onChangeNode( tag )
	if tag == ShoppingLayer.CB_JINBI then
		self._zuanshiNode:setVisible(false)
        self._zuanshiNode:setTouchEnabled(false)
        self._zuanshiNode:setSwallowTouches(false)

		self._jinbiNode:setVisible(true)
        self._jinbiNode:setTouchEnabled(true)
        self._jinbiNode:setSwallowTouches(true)

		self._btZuanShi:setEnabled(true)
		self._btJinBi:setEnabled(false)
	elseif tag == ShoppingLayer.CB_ZUANSHI then
		self._zuanshiNode:setVisible(true)
        self._zuanshiNode:setTouchEnabled(true)
        self._zuanshiNode:setSwallowTouches(true)

		self._jinbiNode:setVisible(false)
        self._jinbiNode:setTouchEnabled(false)
        self._jinbiNode:setSwallowTouches(false)

		self._btZuanShi:setEnabled(false)
		self._btJinBi:setEnabled(true)
	end
end

-- function ShoppingLayer:showLayer( var )
-- 	local ani = nil
--     if var then
--         ani = self.m_actShowAct
--         self:requestPrice()
--     else 
--         ani = self.m_actHideAct
--     end

--     if nil ~= ani then
--         self.sp_bg_node:stopAllActions()
--         self.sp_bg_node:runAction(ani)
--     end
-- end

function ShoppingLayer:onTouchBegan(touch, event)
    return self:isVisible()
end

function ShoppingLayer:onTouchEnded(touch, event)
    local pos = touch:getLocation() 
    local sp_bg = self.sp_bg_node
    pos = sp_bg:convertToNodeSpace(pos)
    local rec = cc.rect(0, 0, sp_bg:getContentSize().width, sp_bg:getContentSize().height)
    if false == cc.rectContainsPoint(rec, pos) then
        --self:showLayer(false)
    end
end

function ShoppingLayer:requestPrice()
    self.Panel_1:setVisible(false)
    self.Panel_2:setVisible(false)

    gt.log("c_____________")

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    
    xhr:open("POST", gt.getUrlEncryCode(string.format(gt.shoppingConfig, self.chargeType), gt.playerData.uid))
    gt.log(gt.getUrlEncryCode(string.format(gt.shoppingConfig, self.chargeType), gt.playerData.uid))

    local function onResp()
        local runningScene = display.getRunningScene()
        if runningScene and runningScene.name == "MainScene" and runningScene:getChildByName("ShoppingLayer") then
            gt.dump(xhr.readyState)
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                local response = xhr.response
                local respJson = require("cjson").decode(response)
                if respJson.errno == 0 then
                    gt.dump(respJson)
                    local rechargeList = respJson.data.rechargeList
                    self.datatable = {}
                    if self.chargeType == 1 then
                        for i = 1, #rechargeList do
                            local item = {}
                            item.money = rechargeList[i].money
                            item.diamond = rechargeList[i].diamond
                            item.coins = rechargeList[i].coins
                            table.insert(self.datatable, item)
                        end
                        if gt.isAppStoreInReview then
                            self.datatable[1].money = 6
                            self.datatable[1].diamond = 6
                            self.datatable[2].money = 18
                            self.datatable[2].diamond = 18
                            self.datatable[3].money = 30
                            self.datatable[3].diamond = 30
                            self.datatable[4].money = 60
                            self.datatable[4].diamond = 60
                            self.datatable[5].money = 98
                            self.datatable[5].diamond = 98
                            self.datatable[6].money = 298
                            self.datatable[6].diamond = 298
                        end
                        for i = 1, #self.datatable do
                            -- local yuanText = gt.seekNodeByName(self.rootNode, "m_text"..i)
                            local yuanText = gt.seekNodeByName(self.rootNode,"m_text_title"..i)
                            yuanText:setString(self.datatable[i].money.."元礼包")
                            -- local moneyText = gt.seekNodeByName(self.rootNode, "m_text"..i.."_note")
                            local moneyText = gt.seekNodeByName(self.rootNode,"m_text_desc"..i)
                            moneyText:setString(self.datatable[i].diamond.."金币".."赠"..self.datatable[i].coins)
                            if gt.isAppStoreInReview then
                                coinsText:setVisible(false)
                            end
                        end
                       self.Panel_1:setVisible(true)
                    elseif self.chargeType == 2 then
                        for i = 1, #rechargeList do
                            local item = {}
                            item.money = rechargeList[i].money
                            item.diamond = rechargeList[i].diamond
                            item.coins = rechargeList[i].coins
                            item.ratio = rechargeList[i].ratio
                            item.single = rechargeList[i].single
                            table.insert(self.datatable, item)
                        end
                        local panel = gt.seekNodeByName(self.rootNode, "Panel_2")
                        for i = 1, #self.datatable do
                            local node = gt.seekNodeByName(panel, "Node"..i)

                            local cardCountLabel = gt.seekNodeByName(node, "Label_cardCount")
                            cardCountLabel:setString(self.datatable[i].diamond.."张")

                            local discountLabel = gt.seekNodeByName(node, "Label_discount")
                            discountLabel:setString("赠"..self.datatable[i].coins.."张")

                            local discountPercentageLabel = gt.seekNodeByName(node, "Label_discountPercentage")
                            discountPercentageLabel:setString("返"..self.datatable[i].ratio)
                            
                            local cardMoneyAllLabel = gt.seekNodeByName(node, "Label_cardMoneyAll")
                            cardMoneyAllLabel:setString(self.datatable[i].money.."元礼包")

                            local cardMoneyEachLabel = gt.seekNodeByName(node, "Label_cardMoneyEach")
                            cardMoneyEachLabel:setString("每张"..self.datatable[i].single.."元")
                        end
                        self.Panel_2:setVisible(true)
                    end
                    if gt.isAppStoreInReview == false then
                        if respJson.data.status and respJson.data.status == 0 then
                            self.chargeType2Btn:setVisible(false)
                        else
                            self.chargeType2Btn:setVisible(true)
                        end
                        
                    end 

                    gt.log("ccccc____________")
                end

            elseif xhr.readyState == 1 and xhr.status == 0 then
                -- 本地网络连接断开
                require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
            end  
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onResp)
    xhr:send()
end

function ShoppingLayer:requestSXMJCoin()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = gt.getUrlEncryCode(gt.sxmjCoin, gt.playerData.uid)
    xhr:open("GET", url)
    gt.log(url)
    local function onResp()
        local runningScene = display.getRunningScene()
        if runningScene and runningScene.name == "MainScene" and runningScene:getChildByName("ShoppingLayer") then
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                local response = xhr.response
                local respJson = require("cjson").decode(response)
                if respJson.errno == 0 then
                    if tonumber(respJson.data.gold) <= 0 then
                        self.lblSXMJCoin:setString("0")
                    else
                        self.lblSXMJCoin:setString(tostring(respJson.data.gold))
                    end
                    
                else
                    Toast.showToast(self, respJson.errmsg, 2)
                end
            elseif xhr.readyState == 1 and xhr.status == 0 then
                -- 本地网络连接断开
                require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
            end  
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onResp)
    xhr:send()
end

function ShoppingLayer:requestImportSXMJCoin()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = gt.getUrlEncryCode(gt.sxmjCoinImport, gt.playerData.uid)
    xhr:open("GET", url)
    gt.log(url)
    local function onResp()
        local runningScene = display.getRunningScene()
        if runningScene and runningScene.name == "MainScene" and runningScene:getChildByName("ShoppingLayer") then
            gt.dump(xhr.readyState)
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                local response = xhr.response
                local respJson = require("cjson").decode(response)
                if respJson.errno == 0 then
                    self.lblSXMJCoin:setString("0")
                    self.panelSuccess:setVisible(true)
                else
                    Toast.showToast(self, respJson.errmsg, 2)
                end
            elseif xhr.readyState == 1 and xhr.status == 0 then
                -- 本地网络连接断开
                require("client/game/dialog/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
            end  
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onResp)
    xhr:send()
end

function ShoppingLayer:onBack()
    -- if self.scheduleHandler then
    --     gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
    -- end 
    self:removeFromParent()
end

return ShoppingLayer