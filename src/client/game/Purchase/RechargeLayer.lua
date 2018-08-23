--
-- Author: liu yang
-- Date: 2017-02-08 15:36:34
--
local gt = cc.exports.gt
local RechargeConfig = gt.getRechargeConfig()--gt.getRechargeCfg()

local RechargeLayer = class("RechargeLayer", function()
	return gt.createMaskLayer()
end)

function RechargeLayer:ctor()
	self.itemCount = 3
	self.itemsLimitState = {}
	self:checkItemLimitState()
end

--检测商品限购状态
function RechargeLayer:checkItemLimitState()
	if not self.xhr then
        self.xhr = cc.XMLHttpRequest:new()
        -- mt.xhr:retain()
        self.xhr.timeout = 10 -- 设置超时时间
    end
    gt.log("RechargeConfig")

    -- local productIdList = RechargeConfig[1]["AppStore"] .. ":" .. RechargeConfig[2]["AppStore"] .. ":" .. RechargeConfig[3]["AppStore"]
	local productIdList = ""
    for i,cfg in ipairs(RechargeConfig) do
    	productIdList = productIdList..cfg.AppStore
    	--如果是最后一个的话，不需要添加“:”
    	if i == #RechargeConfig  then 
    		break
    	end
    	productIdList = productIdList..":"
    end
	gt.dump(productIdList)
	--arg1:需要请求的地址 arg2:serverCode arg3:玩家id arg4:商品id集合（分隔符：“:”）arg5: 购买方式(IOS,ZFB,WX) 
	local checkUrl = string.format("%s?serverCode=%s&userId=%s&productNumbers=%s&payWay=%s", gt.checkLimitUrl, gt.serverCode, gt.playerData.uid, productIdList, gt.sdkBridge.payWay)
    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    self.xhr:open("POST", checkUrl)
    gt.log("checkUrl=="..checkUrl)
    self.xhr:registerScriptHandler(handler(self, self.initLayer))
    self.xhr:send()
end

function RechargeLayer:initLayer()
	gt.log("--------init layer:")
	-- self.xhr:unregisterScriptHandler()
	if self.xhr.readyState == 4 and (self.xhr.status >= 200 and self.xhr.status < 207) then
		
		local response = require("cjson").decode(self.xhr.response)
		gt.dump(response, "----验证结果")
		if response.code == 0 then
			gt.dump(response.data, "---------require succeed")
			local data = response.data
			for j = 1, self.itemCount do
				local tmpPId = RechargeConfig[j]["AppStore"]
				if data[tmpPId] then
					gt.log("--------state, index:" .. data[tmpPId] .. "," .. j)
					self.itemsLimitState[j] = data[tmpPId]
				end
			end

			self:checkRequestComplete()
		elseif response.code == "-1" then
			self:checkItemLimitState()
		end
		
	elseif self.xhr.readyState == 1 and self.xhr.status == 0 then
		self:checkItemLimitState()
	end
end

--检测请求是否完成
function RechargeLayer:checkRequestComplete()
	local checkComplete = true
	for i = 1, self.itemCount do
		if not self.itemsLimitState[i] then
			checkComplete = false
			break
		end
	end

	gt.log("-------checkRequestComplete:" .. tostring(checkComplete))
	if checkComplete then
		if not self.isInitComplete then
			self.rootNode = gt.createCSNode("RechargeShop.csb")
			self.rootNode:setAnchorPoint(0.5,0.5)
			self.rootNode:setPosition(gt.winCenter)
			self:addChild(self.rootNode)

			self.curSelItem = 1

			self.isInitComplete = true
			self:registerButtonsEvent()
			self:initPurchaseInfo()
		end
		self:initBaseInfo()
		self:selectItem(self.curSelItem)

		
	end
end

function RechargeLayer:initBaseInfo()
	gt.log("function is initBaseInfo")
	self.itemList = {}
	for i = 1, self.itemCount do
		local tmpItem = gt.seekNodeByName(self.rootNode, "item" .. i)
		local tmpItemTitle = tmpItem:getChildByName("item" .. i .. "Title")
		local tmpItemCost = tmpItem:getChildByName("item" .. i .. "Cost")
		local tmpItemSel = tmpItem:getChildByName("item" .. i .. "Sel")
		local tmpItemLimit = gt.seekNodeByName(tmpItem, "item" .. i .. "Limited")


		local tmpItemConfig = RechargeConfig[i]

		tmpItemSel:setVisible(false)
		tmpItemLimit:setVisible(false)
		tmpItemTitle:setString(tmpItemConfig["Title"])
		tmpItemCost:setString(tmpItemConfig["CostValue"])

		local tmpItemInfo = {}
		tmpItemInfo.SelIcon = tmpItemSel
		tmpItemInfo.limitIcon = tmpItemLimit
		self.itemList[i] = tmpItemInfo

		gt.addTouchEventListener(tmpItem, function()
			self:selectItem(i)
		end, nil, 0)
	end

end

function RechargeLayer:registerButtonsEvent()
	gt.log("function is RechargeLayer:registerButtonsEvent")
	self.closeBtn = gt.seekNodeByName(self.rootNode, "closeBtn")
	gt.addBtnPressedListener(self.closeBtn, function()
		self:closeLayer()
	end)

	self.buyBtn = gt.seekNodeByName(self.rootNode, "buyBtn")
	gt.addBtnPressedListener(self.buyBtn, function()
		self:buy()
	end)
end

function RechargeLayer:selectItem(index)
	self.curSelItem = index
	for i = 1, self.itemCount do
		local tmpItem = self.itemList[i]
		if tmpItem  then 			
			if self.itemsLimitState[i] == "purchasable" then
				tmpItem.limitIcon:setVisible(false)
			else
				tmpItem.limitIcon:setVisible(true)
			end
			if i == self.curSelItem then
				tmpItem.SelIcon:setVisible(true)
			else
				tmpItem.SelIcon:setVisible(false)
			end
		end	
	end
	if self.itemsLimitState[self.curSelItem] == "purchasable" then
		self:enableBuyBtn()
	else 
		self:disableBuyBtn()	
	end

	local curItemConfig = RechargeConfig[self.curSelItem]
	local itemDes = gt.seekNodeByName(self.rootNode, "itemDes")
	itemDes:setString(curItemConfig["Description"])

	local itemCost = gt.seekNodeByName(self.rootNode, "itemCostValue")
	itemCost:setString(curItemConfig["CostValue"])
end

function RechargeLayer:disableBuyBtn()
	if not self.buyBtn then
		self.buyBtn = gt.seekNodeByName(self.rootNode, "buyBtn")
	end

	self.buyBtn:setTouchEnabled(false)
	self.buyBtn:setBright(false)
end

function RechargeLayer:enableBuyBtn()
	if not self.buyBtn then
		self.buyBtn = gt.seekNodeByName(self.rootNode, "buyBtn")
	end

	self.buyBtn:setTouchEnabled(true)
	self.buyBtn:setBright(true)
end

function RechargeLayer:refreshShopState()
	gt.log("refreshShopState")
	self:checkItemLimitState()
end

function RechargeLayer:closeLayer()
	gt.removeTargetEventListenerByType(self, gt.EventType.PURCHASE_SUCCESS)

	self:removeAllChildren()
	self:removeFromParent()
end

function RechargeLayer:buy()
	gt.log("function is buy")
	
	gt.registerEventListener(gt.EventType.PURCHASE_SUCCESS, self, self.refreshShopState)
	-- local function call()
		gt.log("----buy item:" .. self.curSelItem)
		Charge.buy(self.curSelItem)
	-- end
	-- self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(call)))
end
function RechargeLayer:initPurchaseInfo( )
	-- local productConfig=require("client/game/Purchase/Recharge")
	-- local productsInfo = ""
	-- for i = 1, #productConfig do
	-- 	local tmpProduct = productConfig[i]
	-- 	local productId = tmpProduct["AppStore"]
	-- 	productsInfo = productsInfo .. productId .. ","
	-- end
	-- local luaBridge = require("cocos/cocos2d/luaoc")
	-- luaBridge.callStaticMethod("AppController", "initPaymentInfo", {paymentInfo = productsInfo})
	
end
return RechargeLayer