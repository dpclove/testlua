
local gt = cc.exports.gt

local HelpScene = class("HelpScene", function()
	return gt.createMaskLayer()
end)
local btnTable = {}
btnTable[1] = {"res/addz_new/btn_sj_intro_s.png","res/addz_new/btn_sj_intro_s.png","res/addz_new/btn_sj_intro.png"}
btnTable[2] = {"res/addz_new/btn_ddz_intro_s.png","res/addz_new/btn_ddz_intro_s.png","res/addz_new/btn_ddz_intro.png"}
btnTable[3] = {"res/addz_new/btn_szp_intro_s.png","res/addz_new/btn_szp_intro_s.png","res/addz_new/btn_szp_intro.png"}
btnTable[4] = {"res/addz_new/btn_nn_intro_s.png","res/addz_new/btn_nn_intro_s.png","res/addz_new/btn_nn_intro.png"}
btnTable[5] = {"res/addz_new/btn_sde_intro_s.png","res/addz_new/btn_sde_intro_s.png","res/addz_new/btn_sde_intro.png"}
btnTable[6] = {"res/sdy/createroomSdy/sandayiselect_p.png","res/sdy/createroomSdy/sandayiselect_p.png","res/sdy/createroomSdy/sandayiselect.png"}
btnTable[7] = {"res/wurenbaifen/btn_wrbf_2.png","res/wurenbaifen/btn_wrbf_2.png","res/wurenbaifen/btn_wrbf_1.png"}


function HelpScene:ctor()
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



	---------------------------------------

	self.chargeType = 1
    self.shopBtns = {}
    --[[
    for i=1,5 do
        local shopBtn = gt.seekNodeByName(csbNode, "wanfabtn_" .. i)
        shopBtn:setTouchEnabled(true)
        shopBtn:setSwallowTouches(true)
        shopBtn:setTag(i)
        gt.addBtnPressedListener(shopBtn,function ()
                gt.soundEngine:playEffect("common/audio_button_click", false)
                self.shopType = i
                self.chargeType = shopBtn:getTag()
                for i = 1, #self.shopBtns do
                    self.shopBtns[i]:setTouchEnabled(i ~= self.shopType)
                    self.shopBtns[i]:setBright(i ~= self.shopType)
                    local Panel = gt.seekNodeByName(self.csbNode, "Text_CS_des_" .. i)
                    Panel:setVisible(i == self.shopType)
                end
            end)
        shopBtn:setPressedActionEnabled(false)
        table.insert(self.shopBtns,shopBtn)
    end
    ]]
    

    local node = gt.seekNodeByName(csbNode, "wanfabtn_1")
    self.btnList = {}
	self.wanfa_listview = gt.seekNodeByName(csbNode, "wanfa_listview")
	self.wanfa_listview:setScrollBarEnabled(false)

	for i=1,7 do
		
		local shopBtn = node:clone()

		local cellSize = shopBtn:getContentSize()
		local cellItem = ccui.Widget:create()
		shopBtn:setTouchEnabled(true)
		cellItem:setSwallowTouches(false)
		cellItem:setTag(i)
		cellItem:setContentSize(cc.size(cellSize.width, cellSize.height + 20))

		shopBtn:loadTextures(btnTable[i][1], btnTable[i][2], btnTable[i][3])
		-- gt.setOnViewClickedListener(cellItem,function ()
		gt.addBtnPressedListener(shopBtn,function ()
			gt.log("----sss----")
			gt.soundEngine:playEffect("common/audio_button_click", false)
			self.shopType = i
			self.chargeType = cellItem:getTag()
			for i = 1, #self.shopBtns do
				self.shopBtns[i]:getChildByName("shopBtn"):setTouchEnabled(i ~= self.shopType)
				self.shopBtns[i]:getChildByName("shopBtn"):setBright(i ~= self.shopType)
				local Panel = gt.seekNodeByName(self.csbNode, "Text_CS_des_" .. i)
				Panel:setVisible(i == self.shopType)
			end
		end)
		shopBtn:setPosition(120, 50)
		cellItem:addChild(shopBtn)
		shopBtn:setName("shopBtn")
		shopBtn:setPressedActionEnabled(false)
        table.insert(self.shopBtns,cellItem)
		self.wanfa_listview:pushBackCustomItem(cellItem)
		-- return cellItem

        -- shopBtn:setTouchEnabled(true)
        -- shopBtn:setSwallowTouches(true)
        -- shopBtn:setTag(i)
        -- shopBtn:loadTextures(btnTable[i][1], btnTable[i][2], btnTable[i][3])
        -- gt.addBtnPressedListener(shopBtn,function ()
        --         gt.soundEngine:playEffect("common/audio_button_click", false)
        --         self.shopType = i
        --         self.chargeType = shopBtn:getTag()
        --         for i = 1, #self.shopBtns do
        --             self.shopBtns[i]:setTouchEnabled(i ~= self.shopType)
        --             self.shopBtns[i]:setBright(i ~= self.shopType)
        --             local Panel = gt.seekNodeByName(self.csbNode, "Text_CS_des_" .. i)
        --             Panel:setVisible(i == self.shopType)
        --         end
        --     end)
        -- shopBtn:setPressedActionEnabled(false)
        -- table.insert(self.shopBtns,shopBtn)
		-- self.wanfa_listview:pushBackCustomItem(shopBtn)


		
		-- return cellItem

	end
	node:setVisible(false)

	--默认显示第一个按钮
    if self.shopBtns and self.shopBtns[self.chargeType] then
        self.shopBtns[self.chargeType]:getChildByName("shopBtn"):setTouchEnabled(false)
        self.shopBtns[self.chargeType]:getChildByName("shopBtn"):setBright(false)
    end


	---------------------------------------



	-- --向左箭头
	-- local arrow1Btn = gt.seekNodeByName(self, "Btn_arrow1")
	-- gt.addBtnPressedListener(arrow1Btn, function()
	-- 		local isJump = false  --是否是临界点，不能通过scroll滚动太多页数
	-- 			self.currIdx = self.currIdx - 1
	-- 			if self.currIdx < 0 then
	-- 				self.currIdx = 0
	-- 				isJump = true
	-- 			end
	-- 		gt.log("self.currIdx: ======== ".. self.currIdx)
	-- 		if isJump then
	-- 			self.pageListView:setCurrentPageIndex(self.currIdx)
	-- 		else
	-- 			self.pageListView:scrollToPage(self.currIdx)
	-- 		end
	-- 		self:updatePageNode(self.currIdx)
	-- end)
	
	-- --向右箭头
	-- local arrow2Btn = gt.seekNodeByName(self, "Btn_arrow2")
	-- gt.addBtnPressedListener(arrow2Btn, function()
	-- 		local isJump = false  --是否是临界点，不能通过scroll滚动太多页数
	-- 			self.currIdx = self.currIdx + 1
	-- 			if self.currIdx >= self.maxNum then
	-- 				self.currIdx = self.maxNum - 1
	-- 				isJump = true
	-- 			end
	-- 		if isJump then
	-- 			self.pageListView:setCurrentPageIndex(self.currIdx)
	-- 		else
	-- 			self.pageListView:scrollToPage(self.currIdx)
	-- 		end
	-- 		self:updatePageNode(self.currIdx)
		
	-- end)
	
	-- 返回按键
	local backBtn = gt.seekNodeByName(self, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
		self:removeFromParent()
	end)

	-- self:initPageListView()
end

function HelpScene:initPageListView()
	self.mahjongType = 1  				--默认大玩法为推倒胡
	self.mahjongTypeCount = 2 		    --大玩法数量
	self.mahjongTypeBtns = {}  			--大玩法按钮集合

	self.mahjongTypeTable = { 1, 2 ,3}

	local pageButtonImageName = {
			{
				"res/playrules/playrules_btn1_normal.png", "res/playrules/playrules_btn1_selected.png",
			},
			{
				"res/playrules/playrules_btn2_normal.png", "res/playrules/playrules_btn2_selected.png",
			},
			{

				"res/playrules/playrules_btn.3_normal.png", "res/playrules/playrules_btn3_selected.png",
			},
	}
	local pageButtonPosition = {
		{x = 140, y = 436},
		{x = 140, y = 336},
		{x = 140, y = 236},
	}
	self.maxNum 		= 1 --最大页数
	self.currIdx 		= 0 --当前页数
	self.paddingMaxTime = 5 -- 切换的间隔时间
	self.paddingTime 	= 0 --计时时间
	self.pageListView 	= gt.seekNodeByName(self.csbNode, "PageView_List")
	self.pageNode 		= gt.seekNodeByName(self.csbNode, "Node_page")
	self.pageNode:setVisible(false)
	self.pageListView:setSwallowTouches(true)
	local listSize = self.pageListView:getContentSize()
	self.mahjongTypeBtnCount = 0
	local pageList = { 3 }
	local _node = gt.seekNodeByName(self.csbNode, "Node_page")
	gt.seekNodeByName(_node, "Image"):loadTexture("dt_create_changetypetext.png",ccui.TextureResType.plistType)
	for i = 1, self.maxNum do
		self.pageWidget = ccui.Layout:create()
		self.pageWidget:setTouchEnabled(true)
		self.pageWidget:setSwallowTouches(false)
		self.pageWidget:setContentSize(cc.size(255,500))
		self.pageWidget:addTouchEventListener(handler(self, self.onTouchPageHandler))

    	for j = 1, pageList[i] do
    		self.mahjongTypeBtnCount = self.mahjongTypeBtnCount + 1

	    	local Index = self.mahjongTypeTable[self.mahjongTypeBtnCount]
			local mahjongTypeBtn = ccui.Button:create(pageButtonImageName[Index][1], pageButtonImageName[Index][1], pageButtonImageName[Index][2])
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