local gt = cc.exports.gt

local SelectGame = class("SelectGame", function()
	return gt.createMaskLayer()
end)

function SelectGame:ctor(deskType, parent)
	self.csbNode = cc.CSLoader:createNode("SelectGame.csb")
	self.csbNode:setAnchorPoint(0.5,0.5)
	self.csbNode:setPosition(gt.winCenter)
	self:addChild(self.csbNode)


	local animation_pos = cc.p(115,127)

	local text = gt.seekNodeByName(self.csbNode,"Sprite_1")
 	self.text = text
	
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	local sj_btn = gt.seekNodeByName(self.csbNode, "sj_btn")
	gt.addBtnPressedListener(sj_btn,function ()
		-- local selectGameLayer = require("client/game/majiang/CreateRoom"):create(function ( )
  --   		self:removeFromParent()
		-- end)
		-- selectGameLayer:setName("CreateRoom")
		-- self:addChild(selectGameLayer)
		-- self:addChild(require("client/game/majiang/CreateRoom"):create())
		self:hide()
		gt.addNode(self,require("client/game/poker/view/createRoom"):create())
	end)
	-- local particle = cc.ParticleSystemQuad:create("res/animation/szp/NewParticle_1.plist")
 --    particle:setPosition(animation_pos)
 --    sj_btn:addChild(particle)



    local szp_btn = gt.seekNodeByName(self.csbNode, "szp_btn")
	gt.addBtnPressedListener(szp_btn,function ()
		-- local selectGameLayer = require("client/game/majiang/CreateRoom"):create(function ( )
  --   		self:removeFromParent()
		-- end)
		-- selectGameLayer:setName("CreateRoom")
		-- self:addChild(selectGameLayer)
		self:hide()
		self:addChild(require("client/game/majiang/CreateRoom"):create())
	end)
	--3打2
	local sde_btn = gt.seekNodeByName(self.csbNode, "sde_btn")
   	-- ddzbtn:setEnabled(false)
   	local particle = cc.ParticleSystemQuad:create("res/animation/szp/NewParticle_1.plist")
    particle:setPosition(animation_pos)
    sde_btn:addChild(particle)

	gt.addBtnPressedListener(sde_btn,function ()
		self:hide()
		self:addChild(require("client/game/poker/view/SanDaErCreateRoom"):create())
	end)

	--3打1
	local sdy_btn = gt.seekNodeByName(self.csbNode, "sdy_btn")
   	-- ddzbtn:setEnabled(false)
   	local particle = cc.ParticleSystemQuad:create("res/animation/szp/NewParticle_1.plist")
    particle:setPosition(animation_pos)
    sdy_btn:addChild(particle)
	gt.addBtnPressedListener(sdy_btn,function ()
		self:hide()
		self:addChild(require("client/game/poker/view/SanDaYiCreateRoom"):create())
	end)

	gt.addBtnPressedListener(gt.seekNodeByName(self.csbNode, "czm_btn"),function ()
		Toast.showToast(self, "该功能尚未开放，敬请期待...", 1)
	end)

	--5人百分
	local wrbf_btn = gt.seekNodeByName(self.csbNode, "wrbf_btn")
   	-- ddzbtn:setEnabled(false)
   	local particle = cc.ParticleSystemQuad:create("res/animation/szp/NewParticle_1.plist")
    particle:setPosition(animation_pos)
    wrbf_btn:addChild(particle)
	gt.addBtnPressedListener(wrbf_btn,function ()
		Toast.showToast(self, "该功能尚未开放，敬请期待...", 1)
	end)

	gt.addBtnPressedListener(gt.seekNodeByName(self.csbNode, "jqqd_btn"),function ()
		Toast.showToast(self, "该功能尚未开放，敬请期待...", 1)
	end)
	
	--五人百分按钮
	gt.addBtnPressedListener(gt.seekNodeByName(self.csbNode, "wrbf_btn"),function ()
		self:hide()
		self:addChild(require("client/game/poker/view/CreateRoomWuren"):create())
	end)

	local particle = cc.ParticleSystemQuad:create("res/animation/szp/NewParticle_1.plist")
    particle:setPosition(cc.p(200, 200))
    gt.seekNodeByName(self.csbNode, "sde_btn"):addChild(particle)

 --    local createroomSZPGrayImg = gt.seekNodeByName(self.csbNode, "Img_createroomSZPGray")
 --    local createroomSZPLightImg = gt.seekNodeByName(self.csbNode, "Img_createroomSZPLight")

	-- local animationcount = 1
	-- local function SZPScheduler( )
	-- 	if animationcount == 1 then
	-- 		animationcount = 2
-- 	else
	-- 		animationcount = 1
	-- 	end
	-- 	if animationcount == 1 then
	-- 		createroomSZPGrayImg:setVisible(false)
	-- 		createroomSZPLightImg:setVisible(true)
	-- 	else
	-- 		createroomSZPGrayImg:setVisible(true)
	-- 		createroomSZPLightImg:setVisible(false)
	-- 	end
	-- end
    -- self.SZPScheduler = gt.scheduler:scheduleScriptFunc(handler(self, SZPScheduler), 1, false)

    local particle = cc.ParticleSystemQuad:create("res/animation/szp/NewParticle_1.plist")
    particle:setPosition(cc.p(150, 240))
    szp_btn:addChild(particle)

    local nn_btn = gt.seekNodeByName(self.csbNode, "nn_btn")
	gt.addBtnPressedListener(nn_btn,function ()
		-- local selectGameLayer = require("client/game/majiang/CreateRoomNN"):create(function ( )
  --   		self:removeFromParent()
		-- end)
		-- selectGameLayer:setName("CreateRoomNN")
		-- self:addChild(selectGameLayer)

		self:hide()
		self:addChild(require("client/game/majiang/CreateRoomNN"):create())
	end)

	local playingNode, playingAni = gt.createCSAnimation("res/animation/createroomNN/createroomNN.csb")
	playingAni:play("run", true)
	--playingNode:setPosition(animation_pos)
	playingNode:setPosition(cc.p(115,147))
	nn_btn:addChild(playingNode)

    local ddz_btn = gt.seekNodeByName(self.csbNode, "ddz_btn")
   -- ddzbtn:setEnabled(false)
   -- local particle = cc.ParticleSystemQuad:create("res/animation/szp/NewParticle_1.plist")
   --  particle:setPosition(animation_pos)
   --  ddz_btn:addChild(particle)
	gt.addBtnPressedListener(ddz_btn,function ()
		self:hide()
		self:addChild(require("client/game/poker/view/createRoomddz"):create())
	end)

    --关闭按钮
    local Closebtn = gt.seekNodeByName(self.csbNode, "m_btnClose")
	gt.addBtnPressedListener(Closebtn,function ()
    	self:removeFromParent()
	end)
end

function SelectGame:show_text()
	

	for k , y in pairs(self.csbNode:getChildren()) do
		if not tolua.isnull(y) then
			y:setVisible(true)
		end

	end

end

function SelectGame:hide()
	for k , y in pairs(self.csbNode:getChildren()) do
		if not tolua.isnull(y) then
			y:setVisible(false)
		end

	end
end


function SelectGame:onNodeEvent(eventName)
	if "enter" == eventName then
		gt.registerEventListener("show_text", self, self.show_text)
	elseif "exit" == eventName then
		gt.removeTargetAllEventListener(self)
		if self.SZPScheduler then
			gt.scheduler:unscheduleScriptEntry(self.SZPScheduler)
			self.SZPScheduler = nil
		end
	end
end

return SelectGame