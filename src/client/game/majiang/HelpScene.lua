
local gt = cc.exports.gt

local HelpScene = class("HelpScene", function()
	return gt.createMaskLayer()
end)

function HelpScene:ctor()

	--	 这个文件没有用 不要看
	gt.log("___________________")

	local csbNode = cc.CSLoader:createNode("HelpScene.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.csbNode = csbNode

	if gt.isAppStoreInReview then
		local bokehImg = gt.seekNodeByName(csbNode, "Img_bokeh")
		if bokehImg then
			bokehImg:setVisible(false)
		end
	end

	--向左箭头
	local arrow1Btn = gt.seekNodeByName(self, "Btn_arrow1")
	gt.addBtnPressedListener(arrow1Btn, function()
			local isJump = false  --是否是临界点，不能通过scroll滚动太多页数
				self.currIdx = self.currIdx - 1
				if self.currIdx < 0 then
					self.currIdx = 0
					isJump = true
				end
			gt.log("self.currIdx: ======== ".. self.currIdx)
			if isJump then
				self.pageListView:setCurrentPageIndex(self.currIdx)
			else
				self.pageListView:scrollToPage(self.currIdx)
			end
			self:updatePageNode(self.currIdx)
	end)
	
	--向右箭头
	local arrow2Btn = gt.seekNodeByName(self, "Btn_arrow2")
	gt.addBtnPressedListener(arrow2Btn, function()
			local isJump = false  --是否是临界点，不能通过scroll滚动太多页数
				self.currIdx = self.currIdx + 1
				if self.currIdx >= self.maxNum then
					self.currIdx = self.maxNum - 1
					isJump = true
				end
			if isJump then
				self.pageListView:setCurrentPageIndex(self.currIdx)
			else
				self.pageListView:scrollToPage(self.currIdx)
			end
			self:updatePageNode(self.currIdx)
		
	end)
	
	-- 返回按键
	local backBtn = gt.seekNodeByName(self, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
		self:removeFromParent()
	end)

	self:initPageListView()
end

--调webView
function HelpScene:onWebView()
	local scrollX = 0
	local scrollY = 0
	local url = "http://baidu.com"
	-- local item = gt.seekNodeByName(self.csbNode, "Text_CS_des_1")
	-- scrollX = item:getPositionX()
	-- scrollY = item:getPositionY()	
    --local winSize = cc.Director:getInstance():getVisibleSize()
    self._webView = ccexp.WebView:create()
    self._webView:setPosition(gt.winCenter)
    self._webView:setContentSize(1280,  720)
	-- local refreshTokenURL = string.format(self.site .. url .. "?" .. "unionid=%s&serverCode=%s&playerType=%s", self.unionid, self.serverCode, self.playerType)

    gt.log("个人请求", url)
    self._webView:loadURL(url)
    self._webView:setScalesPageToFit(true)

    self._webView:setOnShouldStartLoading(function(sender, url)
        return true
    end)
    self._webView:setOnDidFinishLoading(function(sender, url)
    end)
    self._webView:setOnDidFailLoading(function(sender, url)
    end)
    self:addChild(self._webView)	
    -- return self._webView
end

function HelpScene:initPageListView()
	self.mahjongType = 4  				--默认大玩法为推倒胡
	self.mahjongTypeCount = 9 		    --大玩法数量
	self.mahjongTypeBtns = {}  			--大玩法按钮集合

	self.mahjongTypeTable = { 4, 5, 9, 8, 1, 2, 3, 6, 7,10,11 }

	local pageButtonImageName = {
			{
				"dt_create_yingsanzui_btn_1.png", "dt_create_yingsanzui_btn_2.png",
			},
			{
				"dt_create_yimenpai_btn_1.png", "dt_create_yimenpai_btn_2.png",
			},
			{
				"dt_create_hongdongwangpai_btn_1.png", "dt_create_hongdongwangpai_btn_2.png",
			},
			{
				"dt_create_tuidaohu_btn_1.png", "dt_create_tuidaohu_btn_2.png",
			},
			{
				"dt_create_koudian_btn_1.png", "dt_create_koudian_btn_2.png",
			},
			{
				"dt_create_jinzhong_btn_1.png", "dt_create_jinzhong_btn_2.png",
			},
			{
				"dt_create_guaisanjiao_btn_1.png", "dt_create_guaisanjiao_btn_2.png",
			},
			{
				"dt_create_xinzhoukoudian_btn_1.png", "dt_create_xinzhoukoudian_btn_2.png",
			},
			{
				"dt_create_linfennianzhongzi_btn_1.png", "dt_create_linfennianzhongzi_btn_2.png",
			},
			{
				"dt_create_kaobazhang_btn_1.png", "dt_create_kaobazhang_btn_2.png",
			},
			{
				"zjh1.png", "zjh.png",
			},
	}
	local pageButtonPosition = {
		{x = 125, y = 436},
		{x = 125, y = 336},
		{x = 125, y = 236},
		{x = 125, y = 136},
		{x = 125, y = 436},
		{x = 125, y = 336},
		{x = 125, y = 236},
		{x = 125, y = 136},
		{x = 125, y = 436},
		{x = 125, y = 336},
		{x = 125, y = 236},
	}
	self.maxNum 		= 3 --最大页数
	self.currIdx 		= 0 --当前页数
	self.paddingMaxTime = 5 -- 切换的间隔时间
	self.paddingTime 	= 0 --计时时间
	self.pageListView 	= gt.seekNodeByName(self.csbNode, "PageView_List")
	self.pageNode 		= gt.seekNodeByName(self.csbNode, "Node_page")
	self.pageListView:setSwallowTouches(true)
	local listSize = self.pageListView:getContentSize()
	self.mahjongTypeBtnCount = 0
	local pageList = { 5, 4, 3 }
	for i = 1, self.maxNum do
		self.pageWidget = ccui.Layout:create()
		self.pageWidget:setTouchEnabled(true)
		self.pageWidget:setSwallowTouches(false)
		self.pageWidget:setContentSize(cc.size(255,500))
		self.pageWidget:addTouchEventListener(handler(self, self.onTouchPageHandler))
		gt.log("add_______________-")
    	for j = 1, pageList[i] do
    		self.mahjongTypeBtnCount = self.mahjongTypeBtnCount + 1
	    	local mahjongTypeBtn = ccui.Button:create()
	    	local Index = self.mahjongTypeTable[self.mahjongTypeBtnCount]
	    	gt.dump(self.mahjongTypeTable)
	    	gt.log("Index...",Index)
			mahjongTypeBtn:loadTextures(pageButtonImageName[Index][1], pageButtonImageName[Index][1], pageButtonImageName[Index][2], ccui.TextureResType.plistType)
			mahjongTypeBtn:setPosition(cc.p(pageButtonPosition[self.mahjongTypeBtnCount].x, pageButtonPosition[self.mahjongTypeBtnCount].y))
			mahjongTypeBtn:setTouchEnabled(true)
			mahjongTypeBtn:setTag(Index)
			self.pageWidget:addChild(mahjongTypeBtn)
			mahjongTypeBtn:addTouchEventListener(handler(self, self.onTouchPageHandler))

	    	mahjongTypeBtn:setPressedActionEnabled(false)
	    	table.insert(self.mahjongTypeBtns, mahjongTypeBtn)
	    	self.mahjongTypeBtns[self.mahjongTypeBtnCount]:setTouchEnabled(Index ~= self.mahjongType)
			self.mahjongTypeBtns[self.mahjongTypeBtnCount]:setBright(Index ~= self.mahjongType)
			local desCSText = gt.seekNodeByName(self.csbNode, "Text_CS_des_" .. self.mahjongTypeBtnCount)
        	desCSText:setVisible(self.mahjongTypeBtnCount == self.mahjongType)
    	end
		self.pageListView:addPage(self.pageWidget)
	end
	self.pageListView:scrollToPage(self.currIdx)

	self:updatePageNode(self.currIdx)
end

function HelpScene:updatePageNode(currentPageIdx)
	if self.pageDots == nil then
		self.pageDots = {}
		local totalWidth = (self.maxNum - 1) * 103
		local firstPosX = -totalWidth*0.34
		for i=1, self.maxNum do
			local pDot = cc.Sprite:createWithSpriteFrameName("dt_create_dotbg.png")
			table.insert(self.pageDots, pDot)
			pDot:setScale(1.2)
			pDot:setAnchorPoint(cc.p(0.5,0.5))
			firstPosX = firstPosX + 35
			pDot:setPosition(cc.p(firstPosX,0))
			self.pageNode:addChild(pDot)
			local dotChoosedImg = cc.Sprite:createWithSpriteFrameName("dt_create_dot.png")
			pDot:addChild(dotChoosedImg)
			dotChoosedImg:setPosition(cc.p(10,10))
			dotChoosedImg:setName("dotChoosedImg")
		end
	end
	for i, dot in ipairs(self.pageDots) do
		local choosedImg = dot:getChildByName("dotChoosedImg")
		if choosedImg then
			choosedImg:hide()
			if i == (currentPageIdx + 1) then
				choosedImg:show()
			end
		end
	end
end

function HelpScene:onTouchPageHandler(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		self.touchBeganPos = sender:getTouchBeganPosition()
	elseif eventType == ccui.TouchEventType.moved then
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self.touchEndedPos = sender:getTouchEndPosition()
		if math.abs(self.touchEndedPos.x - self.touchBeganPos.x) >= 10 then
			local isJump = false  --是否是临界点，不能通过scroll滚动太多页数
			if self.touchBeganPos.x < self.touchEndedPos.x then
				self.currIdx = self.currIdx - 1
				if self.currIdx < 0 then
					self.currIdx = 0
					isJump = true
				end
			else
				self.currIdx = self.currIdx + 1
				if self.currIdx >= self.maxNum then
					self.currIdx = self.maxNum - 1
					isJump = true
				end
			end
			gt.log("self.currIdx: ======== ".. self.currIdx)
			if isJump then
				self.pageListView:setCurrentPageIndex(self.currIdx)
			else
				self.pageListView:scrollToPage(self.currIdx)
			end
			self:updatePageNode(self.currIdx)
		else
			if sender:getTag() > 0 then
				gt.soundEngine:playEffect("common/audio_button_click", false)
				self.mahjongType = sender:getTag()

				for i = 1, #self.mahjongTypeBtns do
					self.mahjongTypeBtns[i]:setTouchEnabled(self.mahjongTypeTable[i] ~= self.mahjongType)
					self.mahjongTypeBtns[i]:setBright(self.mahjongTypeTable[i] ~= self.mahjongType)
					local desCSText = gt.seekNodeByName(self.csbNode, "Text_CS_des_" .. i)
					desCSText:setVisible(i == self.mahjongType)
				end
			end
    	end
	end
end

return HelpScene