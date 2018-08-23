
local mapView = class("JoinRoom", function()
	return gt.createMaskLayer()
end)



function mapView:ctor(url,_tpye)


	local runningScene = cc.Director:getInstance():getRunningScene()

	if runningScene then
		runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS-1)
	end

	local node = cc.CSLoader:createNode("mapView.csb")
	self:addChild(node)
	node:setPosition(gt.winCenter)

	local map = node:getChildByName("map")


    if _tpye then 
        if   _tpye == 1 then 
            node:getChildByName("Text_1"):setString("抱歉，您无法入座，有已入座玩家与您距离过近!")
        elseif  _tpye == 2 then 
            node:getChildByName("Text_1"):setString("")
        end

    end


	self._webView = ccexp.WebView:create()

    self._webView:setPosition(cc.p(2,2))

    self._webView:setContentSize(724,  358)
    self._webView:setAnchorPoint(cc.p(0,0))
 
    self._webView:loadURL(url)
    self._webView:setScalesPageToFit(false) -- 自动缩放
   

    self._webView:setOnShouldStartLoading(function(sender, url)
        return true
    end)
    self._webView:setOnDidFinishLoading(function(sender, url)
    end)
    self._webView:setOnDidFailLoading(function(sender, url)
    end)

    if not map then return end
    map:addChild(self._webView)	


    gt.addBtnPressedListener(node:getChildByName("Button_1"), function()
        self:removeFromParent()
        end)


end

return mapView