
local gt = cc.exports.gt

local Setting = class("Setting", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

function Setting:ctor(scene)
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("Setting.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
	local num = 3
	gt.playTypeClick = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."playTypeClick", 2)
	if gt.gameType == "nn" then
		gt.bgType = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, 1)
	elseif gt.gameType == "zjh" then 
		gt.bgType = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, 1)
	elseif gt.gameType == "ddz" then 
		num = 3
		gt.bgType = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, 1)
	elseif gt.gameType == "sde" then 
		num = 3
		gt.bgType = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, 2)
	elseif  gt.gameType == "sdy" then 
		num = 3
		gt.bgType = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, 2)
	elseif gt.gameType == "wrbf" then 
		num = 3
		gt.bgType = cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, 2)
	end

	for i = 1 , num do
		 gt.seekNodeByName(csbNode, "shiyong_"..i):setVisible(false)
		if gt.gameType == "sde" then
			gt.seekNodeByName(csbNode, "shiyong_"..i):setVisible(gt.bgType==i)
		elseif gt.gameType == "sdy" then
			gt.seekNodeByName(csbNode, "shiyong_"..i):setVisible(gt.bgType==i)
		elseif gt.gameType == "wrbf" then
			gt.seekNodeByName(csbNode, "shiyong_"..i):setVisible(gt.bgType==i)
		end
	end

	-- 出牌
	local singleClickCb = gt.seekNodeByName(csbNode, "Cb_singleClick")
	local doubleClickCb = gt.seekNodeByName(csbNode, "Cb_doubleClick")

	if gt.playTypeClick == 1 then
		singleClickCb:setSelected(true)
		doubleClickCb:setSelected(false)
	elseif gt.playTypeClick == 2 then
		singleClickCb:setSelected(false)
		doubleClickCb:setSelected(true)
	end

	singleClickCb:addEventListener(function(senderBtn, eventType)
		singleClickCb:setSelected(true)
		doubleClickCb:setSelected(false)
		gt.playTypeClick = 1
		cc.UserDefault:getInstance():setIntegerForKey(tostring(gt.playerData.uid).."playTypeClick", gt.playTypeClick)
	end)
	doubleClickCb:addEventListener(function(sender, eventType)
		singleClickCb:setSelected(false)
		doubleClickCb:setSelected(true)
		gt.playTypeClick = 2
		cc.UserDefault:getInstance():setIntegerForKey(tostring(gt.playerData.uid).."playTypeClick", gt.playTypeClick)
	end)

	self.bgTypeBtns = {}
	if gt.gameType == "nn" or gt.gameType == "zjh" then
		gt.seekNodeByName(csbNode, "Btn_bgType1"):setPositionX(-150)
		gt.seekNodeByName(csbNode, "Btn_bgType2"):setPositionX(150)
	end
	-- 桌布
	for i = 1, num do
		local bgTypeBtn = gt.seekNodeByName(csbNode, "Btn_bgType" .. i)
		if gt.gameType == "ddz" then 
			local str = "ddz/btn_bb"..i..".png"
			bgTypeBtn:loadTextureNormal(str) 
			bgTypeBtn:loadTexturePressed(str)
			bgTypeBtn:loadTextureDisabled("ddz/btn_bb"..i.."s.png")
			bgTypeBtn:setVisible(true)

		elseif gt.gameType == "nn" or gt.gameType == "zjh" then 
			local str = "nn/btn_bb"..i.."NN.png"
			bgTypeBtn:loadTextureNormal(str) 
			bgTypeBtn:loadTexturePressed(str)
			bgTypeBtn:loadTextureDisabled("nn/btn_bb"..i.."sNN.png")
			bgTypeBtn:setVisible(i ~= 3)

		elseif gt.gameType == "sde" then
			bgTypeBtn:loadTextureNormal( "sd/desk/bg"..i..".png" )
			bgTypeBtn:loadTexturePressed( "sd/desk/bg"..i..".png" )
			bgTypeBtn:loadTextureDisabled( "sd/desk/bg"..i..".png" )
		elseif gt.gameType == "sdy" then
			bgTypeBtn:loadTextureNormal( "sd/desk/bg"..i..".png" )
			bgTypeBtn:loadTexturePressed( "sd/desk/bg"..i..".png" )
			bgTypeBtn:loadTextureDisabled( "sd/desk/bg"..i..".png" )
		elseif gt.gameType == "wrbf" then
			bgTypeBtn:loadTextureNormal( "sd/desk/bg"..i..".png" )
			bgTypeBtn:loadTexturePressed( "sd/desk/bg"..i..".png" )
			bgTypeBtn:loadTextureDisabled( "sd/desk/bg"..i..".png" )
			
		end
		gt.addBtnPressedListener(bgTypeBtn,function ()


				gt.bgType = i
				for j = 1, num do
					
					self.bgTypeBtns[j]:setTouchEnabled(j ~= gt.bgType)
					self.bgTypeBtns[j]:setBright(j ~= gt.bgType)
					if gt.gameType == "sde" then
						gt.seekNodeByName(csbNode, "shiyong_"..j):setVisible(j==i)
					elseif gt.gameType == "sdy" then
						gt.seekNodeByName(csbNode, "shiyong_"..j):setVisible(j==i)
					elseif gt.gameType == "wrbf" then
						gt.seekNodeByName(csbNode, "shiyong_"..j):setVisible(j==i)
					end
					
				end
				if scene.switch_bg then  scene:switch_bg(i) end
				cc.UserDefault:getInstance():setIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, gt.bgType)
			
				

    	end)



    	table.insert(self.bgTypeBtns, bgTypeBtn)
		self.bgTypeBtns[i]:setTouchEnabled(i ~= gt.bgType)
		self.bgTypeBtns[i]:setBright(i ~= gt.bgType)
	end

	-- 音效调节
	local soundEftSlider = gt.seekNodeByName(csbNode, "Slider_soundEffect")
	local soundEftPercent = gt.soundEngine:getMusicVolume()
	soundEftPercent = math.floor(soundEftPercent)
	soundEftSlider:setPercent(soundEftPercent)
	soundEftSlider:addEventListener(function(sender, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local soundEftPercent = soundEftSlider:getPercent()
			gt.soundEngine:setMusicVolume(soundEftPercent)
		end
	end)

	-- 音乐调节
	local musicSlider = gt.seekNodeByName(csbNode, "Slider_music")
	local musicPercent = gt.soundEngine:getSoundEffectVolume()
	musicPercent = math.floor(musicPercent)
	musicSlider:setPercent(musicPercent)
	musicSlider:addEventListener(function(sender, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local musicPercent = musicSlider:getPercent()
			gt.soundEngine:setSoundEffectVolume(musicPercent)
		end
	end)

	-- 关闭按钮
	local closeBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(closeBtn, function()
		self:removeFromParent()
	end)

	-- if gt.gameType ~= "mj" then 
	-- 	-- musicSlider:setPositionY(musicSlider:getPositionY()-100)
	-- 	-- soundEftSlider:setPositionY(soundEftSlider:getPositionY()-100)
	-- 	-- gt.seekNodeByName(csbNode, "Image_1"):setPositionY(gt.seekNodeByName(csbNode, "Image_1"):getPositionY() - 100 )


	-- 	gt.seekNodeByName(csbNode, "Cb_singleClick"):setVisible(false)
	-- 	gt.seekNodeByName(csbNode, "Cb_doubleClick"):setVisible(false)
	-- 	gt.seekNodeByName(csbNode, "Image_2"):setVisible(false)
	-- 	--gt.seekNodeByName(csbNode, "Image_3"):setVisible(false)
	-- 	for i = 3, 3 do
	-- 		gt.seekNodeByName(csbNode, "Btn_bgType"..i):setVisible(false)
	-- 	end

	-- end


	if gt.gameType == "sj"  then 
		for i = 1, 3 do
			local bgTypeBtn = gt.seekNodeByName(csbNode, "Btn_bgType" .. i)
			bgTypeBtn:setVisible(false)
		end

		soundEftSlider:setPositionY(soundEftSlider:getPositionY()-50)
		musicSlider:setPositionY(musicSlider:getPositionY()-50)
		gt.seekNodeByName(csbNode, "Image_1"):setPositionY(gt.seekNodeByName(csbNode, "Image_1"):getPositionY() - 50 )

	end
	
	-- 经典 新潮 沙滩 文字在三打二，三打一，五人百分显示，其它隐藏
	local Text_jingdian = gt.seekNodeByName(csbNode, "Text_jingdian")
	local Text_xinchao = gt.seekNodeByName(csbNode, "Text_xinchao")
	local Text_shatan = gt.seekNodeByName(csbNode, "Text_shatan")
	if gt.gameType == "sde" or gt.gameType == "sdy" or gt.gameType == "wrbf" then
		Text_jingdian:setVisible(true)
		Text_xinchao:setVisible(true)
		Text_shatan:setVisible(true)
	else
		Text_jingdian:setVisible(false)
		Text_xinchao:setVisible(false)
		Text_shatan:setVisible(false)
	end


end

function Setting:choosePlayTypeEvt(senderBtn, eventType)
	local btnTag = senderBtn:getTag()
	if self.languageTpye ~= btnTag then
		local playTypeChkBox = gt.seekNodeByName(self.rootNode, "ChkBox_playType_" .. self.languageTpye)
		playTypeChkBox:setSelected(false)
		self.languageTpye = btnTag
	else
		local playTypeChkBox = gt.seekNodeByName(self.rootNode, "ChkBox_playType_" .. self.languageTpye)
		playTypeChkBox:setSelected(true)
	end

	-- 保存选择的语言
	cc.UserDefault:getInstance():setIntegerForKey("Language_type2",self.languageTpye)
	cc.UserDefault:getInstance():flush()
end

function Setting:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
	end
end

function Setting:onTouchBegan(touch, event)
	return true
end

function Setting:onTouchEnded(touch, event)
	local bg = gt.seekNodeByName(self.rootNode, "Img_bg")
	if bg then
		local point = bg:convertToNodeSpace(touch:getLocation())
		local rect = cc.rect(0, 0, bg:getContentSize().width, bg:getContentSize().height)
		if not cc.rectContainsPoint(rect, cc.p(point.x, point.y)) then
			self:removeFromParent()
		end
	end
end

return Setting
