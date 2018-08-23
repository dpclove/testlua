

local sjScene = class("sjScene",gt.include("baseGame"))
local sjCardSprite = gt.include("ddzCard.sjCardSprite")
local sjCardNode = gt.include("ddzCard.sjCardNode")

local GamesjLogic =  gt.include("ddzCard.GamesjLogic")

local mai_di = gt.include("view.mai_di")

local log = gt.log
local _scheduler = gt.scheduler
local TIME = 0


function sjScene:switch_bg(i)

	gt.log("switch_________",i)

end
local ptChat = {cc.p(675.53,666.87),cc.p(121.91,554.35),cc.p(118.33,329.33),cc.p(1158.80,551.59)}


function sjScene:disrupt(m)


	self._run = true

	for i = 1, #m.mNewSeatUserId do
		if m.mNewSeatUserId[i] == gt.playerData.uid then 
			self.UsePos = (i - 1)
		end
	end
	--self.tmp_time = os.time()
	self.tong:setVisible(true)
	local pos = self:findNodeByName("tong_node1")
	local time = 0.5
	for i = 1, gt.GAME_PLAYER do
		self.m_flagReady[i]:setVisible(false)
		self.nodePlayer[i]:stopAllActions()
		self.nodePlayer[i]:setPosition(cc.p(self.buf_posX[i],self.buf_posY[i]) )
		self.nodePlayer[i]:setScale(0.65)
		self.nodePlayer[i]:runAction(cc.Sequence:create(  cc.Spawn:create( cc.MoveTo:create(time,cc.p(pos:getPositionX(),pos:getPositionY())) , cc.ScaleTo:create(time,0.1) )  , cc.CallFunc:create(function()
			 self.tong:setVisible(false)
			 self.nodePlayer[i]:setVisible(false)
			 if i == gt.GAME_PLAYER then
			 	self._disrupt:stopAllActions()
			 	self._disrupt:setVisible(true)
			 	self:ActionText(false)
			 	self:ActionText(true)

			 	local act = cc.CSLoader:createTimeline("Disrupt.csb")
				act:gotoFrameAndPlay(0, false)
				self._disrupt:runAction(act)
				act:setFrameEventCallFunc(function(frameEventName)
					local name = frameEventName:getEvent()

					if name == "_end" then 
						self:PlaySound("sj_sound/tong.mp3")
						--self._disrupt:getChildByName( "Node" ):runAction(cc.RepeatForever:create( cc.Sequence:create(cc.RotateTo:create(0.01,10),cc.RotateTo:create(0.01,0),cc.RotateTo:create(0.01,-10),cc.RotateTo:create(0.01,0))))	
						self._disrupt:getChildByName( "Node" ):stopAllActions()
						self:Rote(self._disrupt:getChildByName( "Node" ),0.03)

					end
					if name == "end" then 
						self._disrupt:setVisible(false)
						self._disrupt:getChildByName( "Node" ):stopAllActions()
						self:ActionText(false)
						self.tong:setVisible(true)
						for j = 1, gt.GAME_PLAYER do
							--self.buf_pos
							self.nodePlayer[j]:getChildByName("infobg"):setVisible(j==gt.MY_VIEWID)
							self.nodePlayer[j]:getChildByName("icon1"):setVisible(j~=gt.MY_VIEWID)
							self.nodePlayer[j]:getChildByName("icon1"):setLocalZOrder(8)
							self.nodePlayer[j]:stopAllActions()
							self.nodePlayer[j]:setScale(0.1)
							self.nodePlayer[j]:setPosition(cc.p(pos:getPositionX(),pos:getPositionY()))
							self.nodePlayer[j]:setVisible(true)
							self.nodePlayer[j]:runAction(cc.Sequence:create(  cc.Spawn:create( cc.MoveTo:create(time,cc.p(self.buf_posX[j],self.buf_posY[j])) , cc.ScaleTo:create(time,0.65) )  , cc.CallFunc:create(function()
										if j == gt.GAME_PLAYER then 
											self.tong:setVisible(false)
											self._run = false
											if self.sendcard_m then 
												self:send_card(self.sendcard_m)
												--gt.log("os.tiime.......",os.time() - self.tmp_time)
											end
										end

								end)))
						end
					end
				end)

			 end

		end)))

	end

end

function sjScene:show_result(even,m)



	self.result_node:setVisible(false)
	local btn1 = self:findNodeByName("Button_1",self.result_node)
	local btn2 = self:findNodeByName("Button_2",self.result_node)
	local node = self.result_node	

	m = m or self._result_min

	if not m then return end

	gt.log("_____________________________A")
	gt.dump(m)

	if m.kMId == gt.MSG_S_2_C_SHUANGSHENG_BC_DRAW_RESULT then -- 小结算
		btn1:loadTextureNormal(m.kFinish == 1 and "ddz/look_result.png" or "ddz/next.png")
		btn1:loadTexturePressed(m.kFinish == 1 and "ddz/look_result_d.png" or "ddz/nexts.png")
		btn1:loadTextureDisabled(m.kFinish == 1 and "ddz/look_result_d.png" or "ddz/nexts.png")


		gt.setOnViewClickedListeners(btn1,function()
			
			if m.kFinish == 1 or self.kFinish then 
				self:show_result(nil,self.result_max)
			else
				self:onStartGame()
				self:OnResetView()
			end

		end)


		for i = 1 , gt.GAME_PLAYER do
			self.m_UserHead[self:getTableId(i-1)].score:setString(m.kTotleScore[i])
		end

		local fun = function()
			if m.kType == 0 then 
				return "庄家升"..(m.kNextCard or "err").. "级"
			elseif m.kType == 1 then 
				return "闲家升"..(m.kNextCard or "err").. "级"
			elseif m.kType == 2 then 
				return "闲家上庄"
			else
				return ""
			end
		end

		node:getChildByName("t1"):setString("房号 : "..(self.data.kDeskId or "err"))
		node:getChildByName("t2"):setString(self.result_jushi.."局")
		node:getChildByName("t3"):setString("闲家总得分 : "..(m.kGetTotleScore or "err"))
		node:getChildByName("t4"):setString("闲家扣底得分 : "..(m.kBaseScore or "err"))
		node:getChildByName("t5"):setString(fun())
		node:getChildByName("t6"):setString("下轮打"..(m.kUpDate[m.kNextZhuangPos%2+1] or "err"))

		self:addResult_data(node,m)


		
	else
		btn1:loadTextureNormal("ddz/r_exit.png") -- 返回大厅
		btn1:loadTexturePressed("ddz/r_exit_d.png")
		btn1:loadTextureDisabled("ddz/r_exit_d.png")

	


		self:addResult_data(node,m)

		node:getChildByName("t1"):setVisible(false)
		node:getChildByName("t2"):setVisible(false)
		node:getChildByName("t3"):setVisible(false)
		node:getChildByName("t4"):setVisible(false)
		node:getChildByName("t5"):setVisible(false)
		node:getChildByName("t6"):setVisible(false)
		
		gt.setOnViewClickedListeners(btn1,function()

			self:onExitRoom()

		end)

	end


	gt.setOnViewClickedListeners(btn2,function()

		local fileName = "sharewx.png" 
		       cc.utils:captureScreen(function(succeed, outputFile)  
		           if succeed then  
		             local winSize = cc.Director:getInstance():getWinSize()  
		               Utils.shareImageToWX( outputFile, 849, 450, 32 )
		           else  
		              
		           end  
		       end, fileName)  


		end)

	gt.log("result_node___________________")
	self.result_node:setVisible(true)
	self.result_node:setScale(0.1)
	self.result_node:runAction(cc.ScaleTo:create(0.2, 1))

end

function sjScene:addResult_data(node,m)


	gt.dump(m,"130_line")

	for i = 1 , gt.GAME_PLAYER do
		local id = self:getTableId(i-1)
		
		local p = self:findNodeByName("plyer"..id,node)
		
		p:getChildByName("name"):setString(m.kNikes[i] or "")
		p:getChildByName("ID"):setString(m.kUserIds[i] or "")

		if self.data.kPlaytype[3] == 1 and m.kMId == gt.MSG_S_2_C_SHUANGSHENG_BC_DRAW_RESULT and id ~= gt.MY_VIEWID then 
			p:getChildByName("name"):setVisible(false)
			p:getChildByName("ID"):setVisible(false)
		else
			p:getChildByName("name"):setVisible(true)
			p:getChildByName("ID"):setVisible(true)
		end
		
		if id == gt.MY_VIEWID then 
			p:loadTexture("sjScene/trsult_p_bg.png")
		end

		if m.kScore[i] >= 0 then 
			p:getChildByName("score1"):setString("+"..(m.kScore[i] or 0 ))
			p:getChildByName("score1"):setColor(cc.c3b(197, 75, 32))
		else
			p:getChildByName("score1"):setString(m.kScore[i] or 0)

			p:getChildByName("score1"):setColor(cc.c3b(4,82,137))
		end

		if not m.kFinish then 
			node:getChildByName("max"):setVisible(true)
			node:getChildByName("shibai"):setVisible(false)
			node:getChildByName("shengli"):setVisible(false)

		else
			node:getChildByName("max"):setVisible(false)

			if id == gt.MY_VIEWID then 
				if m.kScore[i] then 
					node:getChildByName("shibai"):setVisible(m.kScore[i] < 0)
					node:getChildByName("shengli"):setVisible(m.kScore[i] >= 0)
				end
			end
		end

	end
	

	for i = 1, gt.GAME_PLAYER do
		
		local id = self:getTableId(i-1)
		local p = self:findNodeByName("plyer"..id,node)
		p:removeChildByTag(i)
		local icon = p:getChildByName("icon")
		icon:setVisible(true)
		if self.data.kPlaytype[3] == 0 or ( self.data.kPlaytype[3] == 1 and  id == gt.MY_VIEWID ) or m.kMId ~= gt.MSG_S_2_C_SHUANGSHENG_BC_DRAW_RESULT then 
			icon:setTexture("addz_new/touxiang_moren.png")
			local url = m.kHeadUrls[i]
			local iamge = gt.imageNamePath(url)
			local _node = cc.Sprite:create("addz_new/touxiang_moren.png")
			_node:retain()
		  	if iamge then
	  		 	local spr  = gt.clippingImage(iamge,_node,false)
				_node:release()
				if gt.addNode(p,spr) then 
					spr:setPosition(cc.p(icon:getPositionX(),icon:getPositionY()))
					icon:setVisible(false)
					spr:setTag(i)
				end
		  	else
			  	if type(url) ~= nil and  string.len(url) > 10 then
			  		local function callback(args)
			      		if args.done  and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self then
			      			local spr  = gt.clippingImage(iamge,_node,false)
							_node:release()
							if gt.addNode(p,spr) then 
								spr:setPosition(cc.p(icon:getPositionX(),icon:getPositionY()))
								icon:setVisible(false)
								spr:setTag(i)
							end
						end
			        end    
				    gt.downloadImage(url,callback)	
				  	
				end
			end

		else
			icon:setTexture("sjScene/p_icon1.png")
		end
	end

end

function sjScene:result_min(m)


	--self:show_log("result_min___________________")
	self._result_min = m
	self.kWinnerPos = m.kWinnerPos
	if m.kWinnerPos ~= 4 then 

		self:stopAllActions()
		self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()

				-- if m.kWinnerPos % 2 ~=  m.kZhuangPos % 2 then 
				-- 	self:PlaySound("sj_sound/koudi.mp3")
				-- elseif m.kWinnerPos  % 2 == m.kZhuangPos  % 2 then
				-- 	self:PlaySound("sj_sound/banker_b.mp3")
				-- end
				local node = require("client/game/poker/view/koudi"):create(m.kBaseCards    ,(m.kWinnerPos%2 ~= m.kZhuangPos%2)  ,m.kBaseTimes    ,m.kBaseScore)
				node:setName("_KOUDI_")
				gt.addNode(self,node)

			end)))
	else
		self:show_result()
	end

end



function sjScene:GameResult(m)
	gt.socketClient:unregisterMsgListener(gt.GC_REMOVE_PLAYER)
	self.result_max = m 
	self:switch_result()
	local time = 1.5 
	if self.kWinnerPos  == 4 then 
	

		if self._delaytime1 then   _scheduler:unscheduleScriptEntry(self._delaytime1) self._delaytime1  = nil end
		self._delaytime1 = _scheduler:scheduleScriptFunc(function()
		if self._delaytime1 then   _scheduler:unscheduleScriptEntry(self._delaytime1) self._delaytime1  = nil end

			if  not self.result_node:isVisible() then self:show_result(nil,self.result_max) end


		end,time,false)
	end
end

function sjScene:init(args)

	gt.gameType = "sj"
	self:room_info(args)
	self:initNode()
	self:addPlayer()


	self:findNodeByName("Text_16"):setString("v:5")

	--self.tmp_time = 0

	gt.log("pos...........",self.UsePos)

	--local buf = {}


-- 	- "<var>" = { 
-- [LUA-print] -     "kCurrGrade"      = 11 
-- [LUA-print] -     "kGradeCard" = { 
-- [LUA-print] -         1 = 11 
-- [LUA-print] -         2 = 6 
-- [LUA-print] -     } 
-- [LUA-print] -     "kHandCards" = { 
-- [LUA-print] -         1  = 6 
-- [LUA-print] -         2  = 7 
-- [LUA-print] -         3  = 8 
-- [LUA-print] -         4  = 9 
-- [LUA-print] -         5  = 9 
-- [LUA-print] -         6  = 10 
-- [LUA-print] -         7  = 11 
-- [LUA-print] -         8  = 12 
-- [LUA-print] -         9  = 13 
-- [LUA-print] -         10 = 33 
-- [LUA-print] -         11 = 34 
-- [LUA-print] -         12 = 35 
-- [LUA-print] -         13 = 36 
-- [LUA-print] -         14 = 37 
-- [LUA-print] -         15 = 24 
-- [LUA-print] -         16 = 25 
-- [LUA-print] -         17 = 26 
-- [LUA-print] -         18 = 34 
-- [LUA-print] -         19 = 35 
-- [LUA-print] -         20 = 37 
-- [LUA-print] -         21 = 42 
-- [LUA-print] -         22 = 54 
-- [LUA-print] -         23 = 57 
-- [LUA-print] -         24 = 3 
-- [LUA-print] -         25 = 61 
-- [LUA-print] -         26 = 0 
-- [LUA-print] -         27 = 0 
-- [LUA-print] -         28 = 0 
-- [LUA-print] -         29 = 0 
-- [LUA-print] -         30 = 0 
-- [LUA-print] -         31 = 0 
-- [LUA-print] -         32 = 0 
-- [LUA-print] -         33 = 0 
-- [LUA-print] -     } 
-- [LUA-print] -     "kHandCardsCount" = 25 
-- [LUA-print] -     "kMId"            = 62200 
-- [LUA-print] -     "kOutTime"        = 10 
-- [LUA-print] -     "kPos"            = 2 
-- [LUA-print] -     "kTotleScore" = { 
-- [LUA-print] -         1 = 0 
-- [LUA-print] -         2 = 0 
-- [LUA-print] -         3 = 0 
-- [LUA-print] -         4 = 0 
-- [LUA-print] -     } 
-- [LUA-print] -     "kZhuangPos"      = 4 
-- [LUA-print] - } 

	-- local m = {}

	-- -- for i = 1, 13 do
	-- -- 	table.insert(buf,i)
	-- -- end

	-- -- for i = 33, 44 do
	-- -- 	table.insert(buf,i)
	-- -- end
	-- local buf = {6,7,8,9,9,10,11,12,13,33,34,35,36,37,24,25,26,34,35,37,42,54,57,3,61}
	-- --local buf = {57,3,61}

	-- buf = GamesjLogic:SortCardList(buf,#buf)

	-- buf = GamesjLogic:SortCardListUp(buf,#buf)
	-- gt.dump(buf)

	-- local kGradeCard = {11,6}
	-- m.kCurrGrade = 11
	-- m.kGradeCard = kGradeCard
	-- m.kHandCards = buf
	-- m.kHandCardsCount = 25
	-- m.kMId = 62200
	-- m.kOutTime = 10
	-- m.kPos = 2
	-- m.kZhuangPos = 4

	-- self:send_card(m)

	--gt.dump(buf)
	--self.m_cardControl:setVisible(true)
	-- self.liangzhu:setVisible(true)
	--self.m_tabNodeCards[gt.MY_VIEWID]:updatesjCardNode(buf, true, true)

end


function sjScene:notice_push_card(m)


	log("广播出牌____________________")
	--kSoundType -1：默认不处理 0：啪 1：大你/管上 2：主杀




	if m.kCurrScore ~= 0 then 

		local delayTime = 0.1
		if m.kGetTotleScore >= 80 and self.banker_pos ~= -1 and self.po_runs then 
			delayTime = 1
			self.po_runs= false
			self.po_node:stopAllActions()
			self.po_node:setVisible(true)
			local node_run = cc.CSLoader:createTimeline("runAction/po_run.csb")
			self.po_node:getChildByName("Sprite"):setTexture(self.UsePos % 2 == self.banker_pos %2 and "sjScene/po1.png" or "sjScene/po2.png")
			self.po_node:runAction(node_run)
			node_run:gotoFrameAndPlay(0, false)
		end

		self:PlaySound("sj_sound/xjdf.mp3")
		local num_node = self:findNodeByName("AtlasLabel")
		num_node:setPosition(cc.p(gt.winCenter.x,gt.winCenter.y+50))
		num_node:setVisible(false)
		num_node:setString(m.kCurrScore)
		num_node:setScale(2)
		num_node:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function() num_node:setVisible(true) end) ,cc.ScaleTo:create(0.1,1), cc.DelayTime:create(0.5), cc.Spawn:create( cc.ScaleTo:create(0.5,0.1), cc.MoveTo:create(0.5,cc.p(167,670))),  cc.CallFunc:create(function()
			num_node:setVisible(false)
			local run_node = self:findNodeByName("FileNode_1")
			run_node:setVisible(true)
			local act = cc.CSLoader:createTimeline("runAction/add_run.csb")
			act:gotoFrameAndPlay(0, false)
			run_node:runAction(act)
			act:setFrameEventCallFunc(function(frameEventName)

				local name = frameEventName:getEvent()
				gt.log("name.........",name)
				if name == "_end" then 
					run_node:setVisible(false)
					self:game_info(nil,nil,m.kGetTotleScore)

					for i = 1 , 25 do
						self._node:removeChildByName("SCORE_"..i)
					end
					for i = 1 , m.kScoreCardsCount do -- 10 张
						
						if  i <= 10 then
							if i == 1 then 
								self.nodes = self:findNodeByName("score_card1")
								self.nodes:setVisible(true)
								self.nodes:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
							else
								local node = self.nodes:clone()
								if gt.addNode(self._node,node) then
									node:setName("SCORE_"..i)
									node:setPosition(cc.p(self.nodes:getPositionX() + (i - 1) * 31 ,self.nodes:getPositionY()))
									node:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
								end
							end
						elseif i > 10 and i <= 20 then 
							if i == 11 then 
								self.nodes = self:findNodeByName("score_card2")
								self.nodes:setVisible(true)
								self.nodes:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
							else
								local node = self.nodes:clone()
								if gt.addNode(self._node,node) then
									node:setName("SCORE_"..i)
									node:setPosition(cc.p(self.nodes:getPositionX() + (i - 11) * 31,self.nodes:getPositionY()))
									node:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
								end
							end
						else
							if i == 21 then 
								self.nodes = self:findNodeByName("score_card3")
								self.nodes:setVisible(true)
								self.nodes:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
							else
								local node = self.nodes:clone()
								if gt.addNode(self._node,node) then
									node:setName("SCORE_"..i)
									node:setPosition(cc.p(self.nodes:getPositionX() + (i - 21) * 31 ,self.nodes:getPositionY()))
									node:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
								end
							end
						end
					end

				end

			end)
			
		end)))


	end
	

	local tmp = {}
    for i = 1 , m.kOutCardsCount do
    	table.insert(tmp,m.kOutCards[i])
    end

 	local sound_run = self:findNodeByName("sound_run")
 	local __time = 0.15

    if m.kSoundType == 1 then
    	self:PlaySound("sj_sound/push_card.mp3")
		sound_run:stopAllActions()
		sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
			self:PlaySound("sj_sound/dani.mp3")
			end)))
		
	elseif m.kSoundType == 2 then 
			self.bi:stopAllActions()
			self.___node = cc.CSLoader:createTimeline("runAction/bi_run.csb")	
	        self.bi:runAction(self.___node)
	        self.bi:setVisible(true)
	        self.___node:gotoFrameAndPlay(0,false) 
	        
	       	local pos = cc.p(self:findNodeByName("card_"..self:getTableId(m.kPos)):getPositionX(),self:findNodeByName("card_"..self:getTableId(m.kPos)):getPositionY())

	       	local center = #tmp * 0.5
	       	local idx = 0 
	       	if self:getTableId(m.kPos) == gt.MY_VIEWID then
	       		idx = 21
	       	elseif self:getTableId(m.kPos) == 1 then
	       		idx = 22
	       	end 
       	  	local xxx = 1 
	        if self:getTableId(m.kPos)== 2 then 
	        	xxx = 1
	        	idx = 12
	        elseif self:getTableId(m.kPos) == 4 then 
	        	xxx = -1
	        end

	        self.bi:setPosition( cc.p( pos.x + (center*sjCardNode.CARD_X_DIS*0.45 -23+ idx)*xxx ,pos.y-15 ) )
		self:PlaySound("sj_sound/push_card.mp3")
		sound_run:stopAllActions()
		sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
			self:PlaySound("sj_sound/bi.mp3")
			end)))

	elseif m.kSoundType == 0 then 
		self:PlaySound("sj_sound/push_card.mp3")
	end

   


    if m.kTurnStart == 1 then  --0：不是第一个玩家， 1：是第一个出牌
    	self.m_tabCurrentCards = tmp
  		if #tmp == 1 and GamesjLogic:GetCardColors(tmp[1]) == 100 then 
  			self:PlaySound("sj_sound/push_card.mp3")
  			sound_run:stopAllActions()
			sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
			self:PlaySound("sj_sound/diao.mp3")
			end)))
  		elseif #tmp == 2 and GamesjLogic:GetCardColors(tmp[1]) == 100 and GamesjLogic:GetCardColors(tmp[2]) == 100 and GamesjLogic:GetCardValue(tmp[1]) == GamesjLogic:GetCardValue(tmp[2]) then 
  			
  			self:PlaySound("sj_sound/push_card.mp3")
  			sound_run:stopAllActions()
			sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
			self:PlaySound("sj_sound/yiduidiao.mp3")
			end)))
  		end
  		if m.kPos ~= self.UsePos and m.kResultOutCardsCount ==0 then 
  			self.m_tabNodeCards[gt.MY_VIEWID]:select_card_effect(tmp)
  		end
   	end
   -- self._kTurnOver = m.kTurnOver == 1 --0：未结束，1：结束

   	if m.kTurnOver == 1 then 
   		self.m_tabCurrentCards = {}
   		self.m_tabNodeCards[gt.MY_VIEWID]:select_card_effect()
   		self:KillGameClock()
   		if self._delaytime then   _scheduler:unscheduleScriptEntry(self._delaytime) self._delaytime  = nil end
   		local time = m.kNextPos == 4 and 3 or ( m.kNextPos == self.UsePos and 1.5 or 1 )
		self._delaytime = _scheduler:scheduleScriptFunc(function()
				self.max_card = {}
				if self._delaytime then   _scheduler:unscheduleScriptEntry(self._delaytime) self._delaytime  = nil end
				self:gameClock(m.kNextPos)
    			self.push_card:setVisible(m.kNextPos == self.UsePos)
    			if m.kNextPos == self.UsePos then 
			    	self:onSelectedCards(self.xuanpoker)
			    end
				-- for i = 1, gt.GAME_PLAYER do
				-- 	local node = self.m_outCardsControl:getChildByTag(i)
				-- 	if node then 
				-- 		node:stopAllActions()
				-- 		node:runAction(cc.Sequence:create(cc.ScaleTo:create(1,0.1) , cc.CallFunc:create(function()
				-- 			node:setVisible(false)
				-- 			self.max_card = {}
				-- 		end)))
				-- 	end
				-- end
				self.m_outCardsControl:removeAllChildren()
		end,time,false)
	else
		self:gameClock(m.kNextPos)
    	self.push_card:setVisible(m.kNextPos == self.UsePos)
    	if m.kNextPos == self.UsePos then 
	    	self:onSelectedCards(self.xuanpoker)
	    end
   	end


	local func = function() 

		if self.kSelectCard ~= 64 then 
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self.kSelectCard)
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self.kSelectCard+100)
			
		end
		if self.data.kPlaytype[4] == 1  then 
	   		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(2,true)
	   	end


	    for i = 1 , #buf do
	    	if GamesjLogic:GetCardValue(buf[i]) == 14 then 
	    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(14,true)
	    	end
	    	if GamesjLogic:GetCardValue(buf[i]) == 15 then 
	    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(15,true)
	    	end
	    	if self._zhu == GamesjLogic:GetCardValue(buf[i]) then 
	    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self._zhu,true)
	    	end
	    end

	    self.m_tabNodeCards[gt.MY_VIEWID]:reSortCards()

	end
	

    if m.kPos == self.UsePos then 
    	if m.kCurrBig ~= 4 then
	    	gt.log("big_______________")
	    	for i = 1 , gt.GAME_PLAYER do
	    		if  self.max_card[i] then 
	    			gt.log("mai_card.......",i,self.max_card[i])
					self.max_card[i]:show_max(i == self:getTableId(m.kCurrBig))
				end
			end		
		end

		if m.kTurnStart == 1 then



			self.shuaipai:stopAllActions()
			self.shuaipai:setVisible(false)

			local cardType, zhus =  GamesjLogic:GetCardType2(tmp,self.kSelectCard)
			if type(cardType) ~= "number" then
				for k , y in pairs(cardType) do
				

					if (k == 100 or k == 101)  then 
						
						if GamesjLogic:GetCardColors( tmp[1] ) == 100 then 

							


							self:PlaySound("sj_sound/push_card.mp3")
				  			sound_run:stopAllActions()
							sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
							self:PlaySound("sj_sound/"..#tmp..".mp3")
							end)))

						else
		

							self:PlaySound("sj_sound/push_card.mp3")
				  			sound_run:stopAllActions()
							sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
							self:PlaySound("sj_sound/"..k.."_"..y.."_".. GamesjLogic:GetCardValue(tmp[1]) ..".mp3")
							end)))

						end
					elseif k == 102 then
						-- self.___node = cc.CSLoader:createTimeline("runAction/tulaji_run.csb")	
				  --       self.tuolaji:runAction(self.___node)
				  --       self.tuolaji:setVisible(true)
				  --       self.___node:gotoFrameAndPlay(0,false)


						-- self:PlaySound("sj_sound/tuolaji.mp3")
					elseif k == 103  then

						local pos = cc.p(self:findNodeByName("card_"..3):getPositionX()-50,self:findNodeByName("card_"..3):getPositionY())
						local center = #tmp * 0.5
						local scale = 0.6
						self.___node = cc.CSLoader:createTimeline("runAction/shuai_run.csb")	
				        self.shuaipai:runAction(self.___node)
				        self.shuaipai:setVisible(true)
				        self.___node:gotoFrameAndPlay(0,false)
				        self.shuaipai:setPosition(cc.p( pos.x + (center)*sjCardNode.CARD_X_DIS*scale-23 ,pos.y-15 ))
						


						self:PlaySound("sj_sound/push_card.mp3")
			  			sound_run:stopAllActions()
						sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
						self:PlaySound("sj_sound/shuai.mp3")
						end)))


					end

				

				end
			end


		end


		if m.kNextPos == 4 then 
			tmp = GamesjLogic:SortCardList(tmp,#tmp,true)
	    	tmp = yl.add_switch_card(tmp)
			local vec = self.m_tabNodeCards[self:getTableId(m.kPos)]:outCard(tmp)
			self:outCardEffect(self:getTableId(m.kPos), tmp, vec, self:getTableId(m.kCurrBig),m.kTurnStart == 1)
		end

		if m.kResultOutCardsCount ~= 0 then -- 甩牌失败
			self:stopAllActions()
			self:findNodeByName("shuaipai"):setVisible(true)
        	self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        			self:findNodeByName("shuaipai"):setVisible(false)
        			local handCards = self.m_tabNodeCards[gt.MY_VIEWID]:getHandCards()
        			local count = #handCards
        			gt.log("cont___________",count)
        			local tmp = {}
        			if type(self.__sel) ~= "table" then 
					    for i = 1, m.kOutCardsCount do
							handCards[count + i] = m.kOutCards[i]
							tmp[i] = m.kOutCards[i]
						end
					else
						for i = 1, #self.__sel do
							handCards[count + i] = self.__sel[i]
							tmp[i] = self.__sel[i]
						end
					end
					if m.kTurnStart == 1 then  --0：不是第一个玩家， 1：是第一个出牌
    					self.m_tabCurrentCards = tmp
    				end

					gt.log("handCards",#handCards)
					self.m_tabNodeCards[gt.MY_VIEWID]:addCards(tmp, handCards,true)


					self:add_stars(handCards)

        			tmp = {}
        			for i = 1, m.kResultOutCardsCount do
        				table.insert(tmp,m.kResultOutCards[i])
        			end
        			tmp = GamesjLogic:SortCardList(tmp,#tmp,true)
        			tmp = yl.add_switch_card(tmp)
        			local vec = self.m_tabNodeCards[self:getTableId(m.kPos)]:outCard(tmp)
        			self:outCardEffect(self:getTableId(m.kPos), tmp, vec, self:getTableId(m.kCurrBig),m.kTurnStart == 1)

        		end)))
		end


	end



    -- 出牌消息
    if m.kPos ~= self.UsePos and #tmp > 0 then
        self:outCardEffect(self:getTableId(m.kPos), tmp, nil, self:getTableId(m.kCurrBig),m.kTurnStart == 1)
      
        if m.kResultOutCardsCount ~= 0 then -- 甩牌失败
        	self:findNodeByName("shuaipai"):setVisible(true)
        	self:stopAllActions()
        --	self:show_log("nextpos:"..m.kNextPos..",UsePos:"..self.UsePos)
        	if m.kNextPos == self.UsePos then 
        		self.push_card:setVisible(false)
        		 self._clock[gt.MY_VIEWID]:setVisible(false)
        	end
        	
        	self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        	--		self:show_log("nextpos:"..m.kNextPos..",UsePos:"..self.UsePos)
        			if m.kNextPos == self.UsePos then 
		        		self.push_card:setVisible(true)
		        		 self._clock[gt.MY_VIEWID]:setVisible(true)
		        	end
        			self:findNodeByName("shuaipai"):setVisible(false)
        			tmp = {}
        			for i = 1, m.kResultOutCardsCount do
        				table.insert(tmp,m.kResultOutCards[i])
        			end
        			tmp = GamesjLogic:SortCardList(tmp,#tmp,true)
        			gt.log("tmp..........",#tmp)

        			if m.kTurnStart == 1 then  --0：不是第一个玩家， 1：是第一个出牌
    					self.m_tabCurrentCards = tmp
    					
    					self.m_tabNodeCards[gt.MY_VIEWID]:select_card_effect(tmp)
    				end

        			self:outCardEffect(self:getTableId(m.kPos), tmp, nil, self:getTableId(m.kCurrBig),m.kTurnStart == 1)

        		end)))
        end
    end



end

function sjScene:show_log(_,m)

	local log = self:findNodeByName("log")

	if log and  m then 
		log:setString(m)
	end

end

function sjScene:shareWx() -- 1604788

	--self.m_btnInvite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.9),cc.ScaleTo:create(0.1,1)))
	local a = self.data.kPlaytype

	local b = ""

	if a[1] == 1 then 
		b = b .. ",底分:1"
	elseif a[1] == 2 then 
		b = b .. ",底分:2"
	elseif a[1] == 3 then 
		b = b .. ",底分:3"
	end

	local c = ""
	if a[4] == 1 then 
		c = c .. ",2是常主"
	end

	local d = ""
	if a[3] == 1 then 
		d = d .. ",防作弊场"
	end

	local e = ""
	if a[2] == 1 then 
		e = e .. ",开始随机主"
	elseif a[2] == 2 and a[4] == 1 then
		e = e .. ",从3开始"
	elseif a[2] == 2 and a[4] == 0 then 
		e = e .. ",从2开始"
	end

	-- local man = ""
	-- if a[6] == 3 then 
	-- 	man = "，满3人开局"
	-- elseif a[6] == 6 then 
	-- 	man = "，满6人开局"
	-- end
	local f = ""
	if self.data.kFlag == 1 then
		f = f .. "3局"
	elseif self.data.kFlag == 2 then 
		f = f .. "5局"
	elseif self.data.kFlag == 3 then
		f = f .. "7局"
	end

	-- local ptpye = ""
	-- if a[7] == 1 then 
	-- 	ptpye = ",轮流叫地主"
	-- elseif a[7] == 0 then
	-- 	ptpye = ",赢家叫地主"
	-- end 

	-- local tipai = ""
	-- if a[1] ~= 3 then 
	-- 	if a[8] == 1 then 
	-- 		tipai = ",可踢和回踢"
	-- 	end
	-- end



	local txt = "升级"..(string.len(self.data.kDeskId) == 6 and "房号：" or "文娱馆桌号：")..(self.data.kDeskId)..b.."，缺"..self:get_num()

	-- local tifengding = ""
	-- if a[1] == 3 and a[10] == 1 then
	-- 	tifengding = ",踢和回踢算入封顶"
	-- end

	

	local g = ""
	if self.data.kGpsLimit == 1 then 
		g = g.."，【相邻位置禁止进入房间】"
	end

	local ruleText = f..b..c..d..e..g

    local url = string.format(gt.HTTP_INVITE, gt.nickname, self.Player[gt.MY_VIEWID].url, self.data.kDeskId, (string.len(self.data.kDeskId) == 6 and "房号：" or "文娱馆桌号：")..(self.data.kDeskId).."，升级，"..ruleText)
   	

    gt.log(txt)
    gt.log("_____________________\n")
    gt.log(ruleText)

	Utils.shareURLToHY(url,txt,ruleText,function(ok)
		if ok == 0 then 
		 Toast.showToast(self, "分享成功", 2)
		end

		end)


end

function sjScene:ShowUserChat1(viewid,time)


	time = tonumber(time) or 30

	self._voice[viewid]:setVisible(true)
	self._voice_node[viewid]:setVisible(true)
	self._voice_nodes[viewid] = cc.CSLoader:createTimeline("yy.csb")
	self._voice_node[viewid]:runAction(self._voice_nodes[viewid])
	self._voice_nodes[viewid]:gotoFrameAndPlay(0,true)
	self._voice[viewid]:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
		
			self._voice_node[viewid]:stopAllActions()
			self._voice_node[viewid]:setVisible(false)
			self._voice[viewid]:setVisible(false)
			table.remove(self.voiceList, 1)
			if #self.voiceList <= 0 then
				gt.soundEngine:resumeAllSound()
				gt.log("恢复音乐 333333")
			end
	
	end)))

end


function sjScene:add_stars(buf)


	if type(buf) ~= "table" then return end

	if self.kSelectCard ~= 64 then 
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self.kSelectCard)
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self.kSelectCard+100)
		
	end
	if self.data.kPlaytype[4] == 1  then 
   		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(2,true)
   	end


    for i = 1 , #buf do
    	if GamesjLogic:GetCardValue(buf[i]) == 14 then 
    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(14,true)
    	end
    	if GamesjLogic:GetCardValue(buf[i]) == 15 then 
    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(15,true)
    	end
    	if self._zhu == GamesjLogic:GetCardValue(buf[i]) then 
    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self._zhu,true)
    	end
    end

    self.m_tabNodeCards[gt.MY_VIEWID]:reSortCards()

end


-- 本地 pos 值
function sjScene:outCardEffect(outViewId, outCards, vecCards, maxPos,is)

	is = is or false -- 是第一家出牌

	self.m_outCardsControl:removeChildByTag(outViewId)
    local holder = cc.Node:create()
    self.m_outCardsControl:addChild(holder)
    holder:setTag(outViewId)

    --self.buf_card[outViewId] = holder

	if #outCards == 0 then return end

	
		self.tuolaji:stopAllActions()
		self.tuolaji:setVisible(false)
		self.shuaipai:stopAllActions()
		self.shuaipai:setVisible(false)


	 	local sound_run = self:findNodeByName("sound_run")
	 	local __time = 0.15


		gt.log("getcard__________________________________")
		local cardType, zhus =  GamesjLogic:GetCardType2(outCards,self.kSelectCard)
		if type(cardType) ~= "number" then
			for k , y in pairs(cardType) do
				-- local Q_SINGLE      = 100
				-- local Q_DOUBLE      = 101
				-- local Q_DOUBLE_LINE = 102
				-- local Q_SHUAI       = 103
				-- 0 方片
				-- 16 梅花
				-- 32 红桃
				-- 48 黑桃
				-- 64 王

				if (k == 100 or k == 101) and is  then 
					
					if GamesjLogic:GetCardColors( outCards[1] ) == 100 then 


						self:PlaySound("sj_sound/push_card.mp3")
			  			sound_run:stopAllActions()
						sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
						self:PlaySound("sj_sound/"..#outCards..".mp3")
						end)))

					else
	

						self:PlaySound("sj_sound/push_card.mp3")
			  			sound_run:stopAllActions()
						sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
						self:PlaySound("sj_sound/"..k.."_"..y.."_".. GamesjLogic:GetCardValue(outCards[1]) ..".mp3")
						end)))


					end
				elseif k == 102 then
					self.___node = cc.CSLoader:createTimeline("runAction/tulaji_run.csb")	
			
			        self.tuolaji:runAction(self.___node)
			        self.tuolaji:setVisible(true)
			        self.___node:gotoFrameAndPlay(0,false)
					

					self:PlaySound("sj_sound/push_card.mp3")
		  			sound_run:stopAllActions()
					sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
					self:PlaySound("sj_sound/tuolaji.mp3")
					end)))

				elseif k == 103 and is then

					local pos = holder:convertToNodeSpace(cc.p(self:findNodeByName("card_"..outViewId):getPositionX(),self:findNodeByName("card_"..outViewId):getPositionY()))
					local center = #outCards * 0.5
					local scale = 0.6
					self.___node = cc.CSLoader:createTimeline("runAction/shuai_run.csb")	
			        self.shuaipai:runAction(self.___node)
			        self.shuaipai:setVisible(true)
			     
			        self.___node:gotoFrameAndPlay(0,false)

			        local xxx = 1 
			        if outViewId == 2 then 
			        	xxx = 1
			        elseif outViewId == 4 then 
			        	xxx = -1
			        end

			        self.shuaipai:setPosition(cc.p( pos.x + ((center)*sjCardNode.CARD_X_DIS*scale-23)*xxx ,pos.y-15 ))
			        if outViewId == 1 or outViewId == 3 then 
			        	self.shuaipai:setPosition(cc.p( pos.x  ,pos.y-15 ))

			        end
					


					self:PlaySound("sj_sound/push_card.mp3")
		  			sound_run:stopAllActions()
					sound_run:runAction(cc.Sequence:create(cc.DelayTime:create(__time), cc.CallFunc:create(function()
					self:PlaySound("sj_sound/shuai.mp3")
					end)))

				end

				gt.log("k.............",k)

			end
		end
	


	outCards = yl.add_switch_card(outCards)
	


    local scale = 0.6
    local tmp_card = nil
    local center = #outCards * 0.5
	if outViewId ~= self:getTableId(self.UsePos) then 

		
	    local buf = {}

	    gt.log("@outCards",#outCards)
		outCards = GamesjLogic:SortCardLists(outCards)
		gt.log("@outCards",#outCards)


	    local pos = holder:convertToNodeSpace(cc.p(self:findNodeByName("card_"..outViewId):getPositionX(),self:findNodeByName("card_"..outViewId):getPositionY()))

	  
	    gt.log("oucard____________")
	    gt.dump(outCards)



		for i = 1, #outCards do 
			local spr = sjCardSprite:createCard(outCards[i])
			if gt.addNode(holder,spr) then
				spr:showCardBack(false)
				spr:setScale(scale)
				spr:stopAllActions()

				gt.log("ccccccccard,",outCards[i])

				if outCards[i] > 100 then outCards[i] = outCards[i] - 100 end 

				if GamesjLogic:GetCardColors(outCards[i]) == 100 then 
					spr:add__stat(1)

					if (self.kSelectCard ~= 64 and self.kSelectCard == outCards[i]) then 
						gt.log(".......s")
						spr:add__stat(2)
					end
				end



				-- local tmpss = outCards[i] + 100

				-- if GamesjLogic:GetCardColors(tmpss) == 100 then 
				-- 	spr:add__stat(1)

				-- 	if (self.kSelectCard ~= 64 and self.kSelectCard == tmpss) then 
				-- 		gt.log(".......z")
				-- 		spr:add__stat(2)
				-- 	end
				-- end


				spr:runAction(cc.Sequence:create( cc.Spawn:create( cc.ScaleTo:create(0.1,scale+0.2),  cc.FadeOut:create(0.1)  ) , cc.Spawn:create( cc.ScaleTo:create(0.1,scale),  cc.FadeIn:create(0.1)  ) ))
				if outViewId == 1 then 
					local num = #outCards
					local center = math.ceil(num/2)
					local tmpPos  = 0
					if num % 2 == 0 then tmpPos = -10 end
					spr:setPosition(cc.p( pos.x + (i-center)*sjCardNode.CARD_X_DIS*scale + tmpPos ,pos.y-15 ))
					if i == #outCards then self.max_card[1] = spr end
				elseif outViewId == 2 then 
					local tmp = pos.x - (#outCards-1)*sjCardNode.CARD_X_DIS*scale
					spr:setPosition(cc.p(pos.x+(i-1)*sjCardNode.CARD_X_DIS*scale-10,pos.y))
					if i == #outCards then self.max_card[2] = spr end
				elseif outViewId == 4 then 
					if i == #outCards then self.max_card[4] = spr end
					local idx = #outCards - i
					spr:setPosition(cc.p(pos.x-(idx-1)*sjCardNode.CARD_X_DIS*scale-20,pos.y))
				end
			

			end
		end
		
	else
		

	   
	    
    	
	    if #vecCards == 0 then 


	    	for i = 1 , #outCards do
			    local controlSize = self.m_outCardsControl:getContentSize()
			    local targetPos = holder:convertToNodeSpace(cc.p(controlSize.width * 0.5, controlSize.height * 0.45))
			    local pos = cc.p((i - center) * sjCardNode.CARD_X_DIS * scale + targetPos.x, targetPos.y)
	    	

		    	local spr = sjCardSprite:createCard(outCards[i])	
		    	if i == #outCards then self.max_card[3] = spr end

				if gt.addNode(holder,spr) then 
					spr:showCardBack(false)
					spr:setScale(scale)
					spr:stopAllActions()
					spr:runAction(cc.Sequence:create( cc.Spawn:create( cc.ScaleTo:create(0.1,scale+0.2),  cc.FadeOut:create(0.1)  ) , cc.Spawn:create( cc.ScaleTo:create(0.1,scale),  cc.FadeIn:create(0.1)  ) ))
					spr:setPosition(cc.p(pos.x,pos.y))
				end
			end
	    else

			for k,v in pairs(vecCards) do

			    local controlSize = self.m_outCardsControl:getContentSize()
			    local targetPos = holder:convertToNodeSpace(cc.p(controlSize.width * 0.5-10, controlSize.height * 0.45))
			    local pos = cc.p((k - center) * sjCardNode.CARD_X_DIS * scale + targetPos.x, targetPos.y)
			   
			    v:retain()
			    v:removeFromParent()
			    holder:addChild(v)
			    v:release()
			    v:setPositionX(targetPos.x)
			    v:showCardBack(false)
				
				v:setLocalZOrder(k)

			  

				if k == #vecCards then self.max_card[3] = v end
			   
			    
			    local moveTo = cc.MoveTo:create(0.2, pos)
			    local spa = cc.Spawn:create(moveTo , cc.Sequence:create(cc.ScaleTo:create(0.05, 2),cc.ScaleTo:create(0.15, scale)  ,cc.CallFunc:create(function()


			    	end) , cc.DelayTime:create(0.1), cc.CallFunc:create(function()

			 
			    	end)))
			    v:stopAllActions()
			    v:runAction(spa)

			end

		end

	end


	if maxPos then 

		for k ,y in pairs(self.max_card) do
			gt.log("maxPos......",maxPos)
			gt.log("k......s",k)
			if maxPos == k then 
				if y and not tolua.isnull(y) then gt.log("ok__________-") y:show_max(true) end
			else
				if y  and not tolua.isnull(y) then gt.log("ok__________-") y:show_max(false) end
			end
		end
	end


	for i = 1 , gt.GAME_PLAYER do
		local node  = self.m_outCardsControl:getChildByTag(i)
		if node then node:setLocalZOrder(i) end
	end



end



function sjScene:onSelectedCards(selectCards)

	self.xuanpoker = selectCards
	gt.log("......sel",#selectCards)

	gt.dump(selectCards)

	if #selectCards == 0 then self.push_card:setEnabled(false) return end

	local outCards = self.m_tabCurrentCards  -- 但前出牌
    local outCount = #outCards
    local selectCount = #selectCards

    local selectType = nil

   	local handCard = self.m_tabNodeCards[gt.MY_VIEWID]:getHandCards()

   	gt.dump(outCards)

   	self.push_card:setEnabled(GamesjLogic:CompareCard(outCards,selectCards,handCard,self.kSelectCard) == 1 )
    
    

end

function sjScene:send_push_card()
	self.xuanpoker = {}
	self.m_tabNodeCards[gt.MY_VIEWID]:select_card_effect()
	local sel = self.m_tabNodeCards[gt.MY_VIEWID]:getSelectCards() 
	gt.dump(sel)
	if #sel == 0 then return end
	self.push_card:setVisible(false)
	sel = yl.add_switch_card(sel)
	self.__sel = sel
	local vec = self.m_tabNodeCards[gt.MY_VIEWID]:outCard(sel,false)
	self:outCardEffect(gt.MY_VIEWID, sel, vec)
	sel = yl.switch_card(sel)
	local m = {}
	m.kMId = gt.MSG_C_2_S_SHUANGSHENG_OUT_CARDS
	m.kPos = self.UsePos 
	m.kOutCardsCount = #sel
	m.kOutCards = sel

	gt.socketClient:sendMessage(m)

end



function sjScene:switch_result()
	self.kFinish = true
	local btn1 = self:findNodeByName("Button_1",self.result_node)
	
	btn1:loadTextureNormal( "ddz/look_result.png")
	btn1:loadTexturePressed( "ddz/look_result_d.png")
	btn1:loadTextureDisabled( "ddz/look_result_d.png")

end


function sjScene:change_card(m)  -- 亮主结束 -- 买底

	--m.kZhuangPos
	-- m.kSelectCard
	self._disrupt:getChildByName( "Node" ):stopAllActions()
	self._disrupt:stopAllActions()
	self._disrupt:setVisible(false)
	self:ActionText(false)
	self.tong:setVisible(false)

	self.kSelectCard = m.kSelectCard
	gt.kSelectCard = self.kSelectCard
	self:findNodeByName("qingzhuangda"):setVisible(false)
	self:findNodeByName("duifangda"):setVisible(false)
	self:findNodeByName("wofangda"):setVisible(false)
	self.liangzhu:setVisible(false)
	local bool = self.kSelectCard == 64
	self.banker_pos = m.kZhuangPos

	self.gameinfo:getChildByName("Text_1"):setColor( self.banker_pos%2 == self.UsePos%2 and cc.c3b(255,210,101) or cc.c3b(255,255,255) )
	self.gameinfo:getChildByName("Text_2"):setColor( self.banker_pos%2 ~= self.UsePos%2 and cc.c3b(255,210,101) or cc.c3b(255,255,255) )

	--self:show_log("z:"..m.kZhuangPos.." u:"..self.UsePos)

	if bool then 
		self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
		self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d6.png")
	end

	if  m.kZhuangPos ==  self.UsePos then 
		--if not bool then 
			self:PlaySound("sj_sound/mai1.mp3")
		--end
		local buf = GamesjLogic:SortCardList(m.kBaseCards,#m.kBaseCards,true)
		self._mai_di:getChildByTag(1):init(buf,self.UsePos,m.kOutTime,m.kSelectCard)
		self._mai_di:setVisible(true)
	else
		--if not bool then
			self:PlaySound("sj_sound/mai2.mp3")
		--end
		self.maidi:setVisible(false)
		self.maidi:stopAllActions()
		self.maidi:setPosition(self.m_flagReady[self:getTableId( m.kZhuangPos ) ]:getPosition())
		self.___node1 = cc.CSLoader:createTimeline("runAction/mai_run.csb")	
        self.maidi:runAction(self.___node1)
        self.maidi:setVisible(true)
        self.___node1:gotoFrameAndPlay(0,true) 
		
		self:ActionText5(true,m.kOutTime)
	end



	for i = 1 , gt.GAME_PLAYER do 
		self["lz"..i]:stopAllActions()
		for x = 1 , 2 do
			self["lz"..i]:getChildByName("x"..x):setVisible(false)
		end
		if self.banker_pos ~= -1 and self.banker_pos ~= 4 then 
			if i == self:getTableId(self.banker_pos) then
				if not self.m_UserHead[i].banker:isVisible() then 
					self.m_UserHead[i].banker:setVisible(true)
					self.m_UserHead[i].banker:stopAllActions()
					local z = cc.CSLoader:createTimeline("runAction/banker_run.csb")	
					self.m_UserHead[i].banker:runAction(z)
					z:gotoFrameAndPlay(0,false)
				end
			else
				self.m_UserHead[i].banker:setVisible(false)
			end
		end
	end


	self.fz:stopAllActions()
	self.fz:setVisible(false)


	if self.m_tabNodeCards[gt.MY_VIEWID].m_bDispatching and self.my_card then 
		self.m_tabNodeCards[gt.MY_VIEWID]:removeAllCards()
		self.m_tabNodeCards[gt.MY_VIEWID]:updatesjCardNode(self.my_card, true, false)		
		self.my_card = nil
	end

	local func = function() 
		self.m_tabNodeCards[gt.MY_VIEWID]:add_star()
		if m.kSelectCard ~= 64 then 
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard)
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard+100)
		end
		if self.data.kPlaytype[4] == 1  then 
	   		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(2,true)
	   	end

    	
    	self.m_tabNodeCards[gt.MY_VIEWID]:add_star(14,true)
    	
    	self.m_tabNodeCards[gt.MY_VIEWID]:add_star(15,true)
    	
    	
    	self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self._zhu,true)
    	
	    

	    self.m_tabNodeCards[gt.MY_VIEWID]:reSortCards()

	end
	func()

	


end

function sjScene:mai_di_result(m)
	--[[
		
		kPos				//盖底牌玩家位置
		kFlag;				//埋底是否成功，0：失败，1：成功
		kHandCardsCount;		//手牌数量
		kHandCards[33];		//玩家手牌

	]]
	
	if m.kFlag == 1 then 
		self.maidi:setVisible(false)
		self.maidi:stopAllActions()
		self:ActionText5(false)
		if m.kPos == self.UsePos then
			local buf = {}
			for i = 1, m.kHandCardsCount do 
				table.insert(buf,m.kHandCards[i])
				gt.log("value.............", GamesjLogic:GetCardLogicValue( m.kHandCards[i] ))
			end
			buf = yl.add_switch_card(buf)
			self.m_tabNodeCards[gt.MY_VIEWID]:removeAllCards()
			self.m_tabNodeCards[gt.MY_VIEWID]:updatesjCardNode(buf, true, false)
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star()
			self.kSelectCard = m.kSelectCard
			gt.kSelectCard = self.kSelectCard
			if m.kSelectCard ~= 64 then 
				--for i = 1, m.kHandCardsCount do 
					--if m.kSelectCard == m.kHandCards[i] then 
						self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard)
						self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard+100)
					--end
				--end
			end
			if self.data.kPlaytype[4] == 1  then 
		   		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(2,true)
		   	end
		    for i = 1 , #buf do
		    	if GamesjLogic:GetCardValue(buf[i]) == 14 then 
		    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(14,true)
		    	end
		    	if GamesjLogic:GetCardValue(buf[i]) == 15 then 
		    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(15,true)
		    	end
		    	if self._zhu == GamesjLogic:GetCardValue(buf[i]) then 
		    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self._zhu,true)
		    	end
		    end
		  	self.m_tabNodeCards[gt.MY_VIEWID]:reSortCards()

		end
	else
		if m.kPos == self.UsePos then 
			Toast.showToast(display.getRunningScene(), "埋底失败！", 2)
			gt.socketClient:close()
		end
	end

	

end

function sjScene:game_start(m)
	TIME = m.kOutTime
	if m.kPos == self.UsePos then 
		self.push_card:setVisible(true)
	end
	self:gameClock(m.kPos)
	self:removeChildByName("_KOUDI_" )
	self:findNodeByName("qingzhuangda"):setVisible(false)
	self:findNodeByName("duifangda"):setVisible(false)
	self:findNodeByName("wofangda"):setVisible(false)
	self.liangzhu:setVisible(false)
	self:ActionText5(false)
	self.maidi:setVisible(false)
	self.maidi:stopAllActions()
	self:hide_mai_di_node()
	self.fz:setVisible(false)
	self.fz:stopAllActions()
	self._disrupt:getChildByName( "Node" ):stopAllActions()
	self._disrupt:setVisible(false)
	self:ActionText(false)
	self.tong:setVisible(false)

	for i = 1 , gt.GAME_PLAYER do 
		self["lz"..i]:stopAllActions()
		for x = 1 , 2 do
			self["lz"..i]:getChildByName("x"..x):setVisible(false)
		end
		if self.banker_pos ~= -1 and self.banker_pos ~= 4 then 
			if i == self:getTableId(self.banker_pos) then
				if not self.m_UserHead[i].banker:isVisible() then 
					self.m_UserHead[i].banker:setVisible(true)
					self.m_UserHead[i].banker:stopAllActions()
					local z = cc.CSLoader:createTimeline("runAction/banker_run.csb")	
					self.m_UserHead[i].banker:runAction(z)
					z:gotoFrameAndPlay(0,false)
				end
			else
				self.m_UserHead[i].banker:setVisible(false)
			end
		end
	end

end


function sjScene:KillGameClock()
	if self._time then
        _scheduler:unscheduleScriptEntry(self._time)
        self._time = nil
    end

    for i = 1 ,gt.GAME_PLAYER do
    	self._clock[i]:stopAllActions()
       	self._clock[i]:setVisible(false)
    end

end

function sjScene:gameClock(id, time)
	time = time or TIME

	if not id then return end
	if id < 0 or id > 3 then return end
	local i = self:getTableId(id)
	if not i or i == 21 then return end
	if not self._clock[i] or not self._clock then return end
	self._clock[i]:stopAllActions()
	self._clock[i]:setRotation(0)
	--self.call_score[i]:setVisible(false)
	gt.log("clock....",id,i,time)
	self:KillGameClock()
	self.m_outCardsControl:removeChildByTag(i)
	self._clock[i]:getChildByName("time"):setString(time)
	self._clock[i]:setVisible(true)
	self._time = _scheduler:scheduleScriptFunc(function()
		time = time - 1
		self._clock[i]:getChildByName("time"):setString(time)
		if time == 2 then 
			
			self:PlaySound("sound_res/ddz/clock.mp3")
			self._clock[i]:runAction( cc.RepeatForever:create( cc.Sequence:create(cc.RotateTo:create(0.01,10),cc.RotateTo:create(0.01,0),cc.RotateTo:create(0.01,-10),cc.RotateTo:create(0.01,0))))

		end
		if time <= 0 then 
			time = 0
			if self._time then
		        _scheduler:unscheduleScriptEntry(self._time)
		        self._time = nil
		    end
		    self._clock[i]:getChildByName("time"):setString(time)
		end
	end,1,false)

end


function sjScene:hide_mai_di_node(  )
	self._mai_di:setVisible(false)
end

function sjScene:room_info(m)

	
	self:switch_bg(cc.UserDefault:getInstance():getIntegerForKey(tostring(gt.playerData.uid).."bgType"..gt.gameType, 1))

	self.play_num = self:findNodeByName("t2",self._room_info)
	self.play_num:setString("0 / 0")
	self:findNodeByName("t1",self._room_info):setString(m.kPlaytype[10]~= 0 and "xxxxxx" or m.kDeskId)
	self:findNodeByName("t3",self._room_info):setString(m.kPlaytype[4] == 1 and "2是常主" or "2不是常主")
	self:findNodeByName("t4",self._room_info):setString(m.kPlaytype[1].."分")
	self:findNodeByName("t5",self._room_info):setString(m.kPlaytype[2] == 1 and "开始随机主" or "从3开始")
	gt._changzhu = self.data.kPlaytype[4] == 1 

	self:findNodeByName("game_info"):getChildByName("Text_4"):setString(m.kPlaytype[10]~= 0 and "xxxxxx" or m.kDeskId)
	self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(false)
	
	self:findNodeByName("chat"):setVisible(m.kPlaytype[3] ~= 1)
	self:findNodeByName("voice"):setVisible(m.kPlaytype[3] ~= 1)
	

end

function sjScene:initNode()



	self.kWinnerPos = 4
	self.kFinish = false
	self._run = false 
	self.banker_pos = -1
	self.clour = -1
	gt._changzhus = 0
	self.kSelectCard = 64
	self.max_card = {}
	self.xuanpoker = {}
	self.result_jushi = "0/0"
	self.m_tabCurrentCards = {}

	self.m_UserChat = {}

	self.m_UserChatView = {}
	self.player_num = {}

	self.tmp_zhus = {}
	for i = 1 , 5 do
		table.insert(self.tmp_zhus , -1)
	end

	self.tuolaji = self:findNodeByName("tuolaji_run")
	:setVisible(false)
	self.shuaipai = self:findNodeByName("shuaipai_run")
	:setVisible(false)
	self.bi = self:findNodeByName("bi_run")
	:setVisible(false)
	self.maidi = self:findNodeByName("maidi_run")
	:setVisible(false)
	self.fz = self:findNodeByName("fz_run")
	:setVisible(false)

	self.tong = self:findNodeByName("tong")
	:setVisible(false)

	self.btnSender = self:findNodeByName("Txt_ChatSender")
	self.btnSender:setVisible(false)

	self.po_node = self:findNodeByName("po_run")
	:setVisible(false)

	self._disrupt = self:findNodeByName("disrupt")
	:setVisible(false)



	

	for i =1 , #gt.poker_node_sj do
        cc.Director:getInstance():getTextureCache():addImage(gt.poker_node_sj[i]) 
    end

   

    self._zhu = -1
	local node  = self._node
	self.m_btnInvite = self:findNodeByName("btnInvite")
	self.ready = self:findNodeByName("ready")
	local upMenu = node:getChildByName("up_btn")
	upMenu:setLocalZOrder(2001)
	local menu = node:getChildByName("upmenu")
	menu:setLocalZOrder(2000)
	menu:setVisible(false)


	self.result_node = cc.CSLoader:createNode("resultsNode_sj.csb")
	self.result_node:setAnchorPoint(cc.p(0.5,0.5))
	self.result_node:setPosition(gt.winCenter)
	self.result_node:setVisible(false)
	gt.addNode(self,self.result_node,2002)

	local bools = true

	local r_info = self:findNodeByName("small_bg")
	:setVisible(false)
	gt.setOnViewClickedListeners(upMenu,function()
		if self.result then return end

		menu:setVisible(bools)
		if bools then upMenu:loadTexture("sjScene/set1.png") else upMenu:loadTexture("sjScene/set.png") end
		bools = not bools

		end)

	gt.setOnViewClickedListener(node:getChildByName("bg"),function()
		r_info:setVisible(false)
		if self.playerInfo then self.playerInfo:setVisible(false) end
		if not bools then
			menu:setVisible(bools)
			if bools then upMenu:loadTexture("sjScene/set1.png") else upMenu:loadTexture("sjScene/set.png") end
			bools = not bools
		end
		--log("here____________!!!!!!")
		self.UserInfo:setVisible(false)
	end)

	--self:findNodeByName("log"):setString(self.data.kDeskId)

	gt.setOnViewClickedListeners(self:findNodeByName("Image_1",menu),function()
			
			self:exitRoom(self.gameBegin)
		end)

	gt.setOnViewClickedListeners(self:findNodeByName("Image_2",menu),function()
			
			if not gt.isCreateUserId and not self.gameBegin  then -- and 游戏没开始
				self:exitRoom(false)
			else
				self:exitRoom(true)
			end
		end)

	gt.setOnViewClickedListeners(self:findNodeByName("Image_3",menu),function() --setting
		
		if self:getChildByName("_settinr_node_") then self:getChildByName("_settinr_node_"):removeFromParent() end
		local settingPanel = require("client/game/majiang/Setting"):create(self)
		
		if gt.addNode(self,settingPanel,18) then settingPanel:setName("_settinr_node_") end
	end)

	gt.setOnViewClickedListeners(self:findNodeByName("chat"),function() --setting

		local chatPanel = require("client/game/majiang/ChatPanel"):create(false,self.data.kPlaytype[3])
		self:addChild(chatPanel, 100)

	
			
	end)


	self.liangzhu = self:findNodeByName("liangzhu")
					:setVisible(false)



	self._count = 0	
	self:renovate_huase()
	for i = 1 , 5 do
		self["_l"..i] = self:findNodeByName("l"..i)
		self["_l"..i]:setVisible(false)
		gt.setOnViewClickedListeners(self["_l"..i],function() --setting

			gt.log("laingzhu__________________")
			 -- 	kPos				//玩家位置
				-- kSelectCardCount;     	//玩家报主牌的张数
				-- kSselectCard;			//玩家报主的牌

				-- local ac = function(i)
				-- 	self.fz:stopAllActions()
				-- 	self.fz:setVisible(true)
				-- 	local node =cc.CSLoader:createTimeline("runAction/fz_run.csb")	
				-- 	self.fz:runAction(node)
				-- 	self.fz:setPosition(cc.p(self["lz"..i]:getChildByName("x1"):getPositionX()+5,self["lz"..i]:getChildByName("x1"):getPositionY()))
				-- 	node:gotoFrameAndPlay(0,false)
				-- end


				self._count = self._count + 1

				--if _count > 2 then return end

				-- local fun = function()
				-- 	for i = 0 , gt.GAME_PLAYER - 1 do 
				-- 		if i ~= self.UsePos then 
				-- 			if self.liang_buf[i] ~= 0 then 
				-- 				ac(gt.MY_VIEWID)
				-- 				return true  -- 
				-- 			end
				-- 		end
				-- 	end
				-- 	return false
				-- end

				
		

				-- if i == 2 then 																	
				-- 	if _count == 1 then -- 亮主  or 反主                                      -- 反主                 -- 亮主
				-- 		self:PlaySound(self.hei == 1 and "sj_sound/htl.mp3" or ( fun() and "sj_sound/htf.mp3" or "sj_sound/htl.mp3")  )
				-- 	elseif _count == 2 then   --  加固 
				-- 		self:PlaySound(self.hei == 1 and "sj_sound/htjg.mp3" or "sj_sound/htjg.mp3") 
				-- 		ac(gt.MY_VIEWID)
				-- 	end
				-- 	for ii = 1 , gt.GAME_PLAYER do 

				-- 		self["lz"..ii]:setVisible(ii == gt.MY_VIEWID)
				-- 		if ii == gt.MY_VIEWID then 
				-- 		if self.hei == 1 then 
				-- 			self["lz"..ii]:getChildByName("x"..4):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..4):loadTexture("sjScene/h1.png")
				-- 		elseif self.hei == 2 then 
				-- 			self["lz"..ii]:getChildByName("x"..3):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..3):loadTexture("sjScene/h1.png")
				-- 			self["lz"..ii]:getChildByName("x"..4):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..4):loadTexture("sjScene/h1.png")
				-- 		end
				-- 	end
				-- 	end
				-- elseif i == 3 then 
				-- 	if _count == 1 then -- 亮主  or 反主                                      -- 反主                 -- 亮主
				-- 		self:PlaySound(self.hong == 1 and "sj_sound/h_tl.mp3" or ( fun() and "sj_sound/h_tf.mp3" or "sj_sound/h_tl.mp3")  )
				-- 	elseif _count == 2 then   --  加固 
				-- 		self:PlaySound(self.hong == 1 and "sj_sound/h_tjg.mp3" or "sj_sound/h_tjg.mp3") 
				-- 		ac(gt.MY_VIEWID)
				-- 	end
				-- 	for ii = 1 , gt.GAME_PLAYER do 
				-- 		self["lz"..ii]:setVisible(ii == gt.MY_VIEWID)
				-- 		if ii == gt.MY_VIEWID then 
				-- 		if self.hong == 1 then 
				-- 			self["lz"..ii]:getChildByName("x"..4):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..4):loadTexture("sjScene/h2.png")
				-- 		elseif self.hong == 2 then 
				-- 			self["lz"..ii]:getChildByName("x"..3):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..3):loadTexture("sjScene/h2.png")
				-- 			self["lz"..ii]:getChildByName("x"..4):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..4):loadTexture("sjScene/h2.png")
				-- 		end
				-- 	end
				-- 	end
				-- elseif i == 4 then
				-- 	if _count == 1 then -- 亮主  or 反主                                      -- 反主                 -- 亮主
				-- 		self:PlaySound(self.hua == 1 and "sj_sound/hl.mp3" or ( fun() and "sj_sound/hf.mp3" or "sj_sound/hl.mp3")  )
				-- 	elseif _count == 2 then   --  加固 
				-- 		self:PlaySound(self.hua == 1 and "sj_sound/hjg.mp3" or "sj_sound/hjg.mp3") 
				-- 		ac(gt.MY_VIEWID)
				-- 	end
				-- 	for ii = 1 , gt.GAME_PLAYER do 
				-- 		self["lz"..ii]:setVisible(ii == gt.MY_VIEWID)
				-- 		if ii == gt.MY_VIEWID then 
				-- 		if self.hua == 1 then 
				-- 			self["lz"..ii]:getChildByName("x"..4):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..4):loadTexture("sjScene/h3.png")
				-- 		elseif self.hua == 2 then 
				-- 			self["lz"..ii]:getChildByName("x"..3):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..3):loadTexture("sjScene/h3.png")
				-- 			self["lz"..ii]:getChildByName("x"..4):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..4):loadTexture("sjScene/h3.png")
				-- 		end
				-- 	end
				-- 	end
				-- elseif i == 5 then 
				-- 	if _count == 1 then -- 亮主  or 反主                                      -- 反主                 -- 亮主
				-- 		self:PlaySound(self.pian == 1 and "sj_sound/pl.mp3" or ( fun() and "sj_sound/pf.mp3" or "sj_sound/pl.mp3")  )
				-- 	elseif _count == 2 then   --  加固 
				-- 		self:PlaySound(self.pian == 1 and "sj_sound/pjg.mp3" or "sj_sound/pjg.mp3") 
				-- 		ac(gt.MY_VIEWID)
				-- 	end
				-- 	for ii = 1 , gt.GAME_PLAYER do 
				-- 		self["lz"..ii]:setVisible(ii == gt.MY_VIEWID)
				-- 		if ii == gt.MY_VIEWID then 
				-- 		if self.pian == 1 then 
				-- 			self["lz"..ii]:getChildByName("x"..4):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..4):loadTexture("sjScene/h4.png")
				-- 		elseif self.pian == 2 then 
				-- 			self["lz"..ii]:getChildByName("x"..3):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..3):loadTexture("sjScene/h4.png")
				-- 			self["lz"..ii]:getChildByName("x"..4):setVisible(true)
				-- 			self["lz"..ii]:getChildByName("x"..4):loadTexture("sjScene/h4.png")
				-- 		end
				-- 		end
				-- 	end
				-- elseif i == 1 then 
					
				-- end


				local call = function()
					self.clour = GamesjLogic:GetCardColor(self.tmp_zhus[i])
					if i==5 then return (self.pian > 2 and 2 or self.pian) elseif i ==4 then return (self.hua >2 and 2 or self.hua) elseif i==3 then return (self.hong >2 and 2 or self.hong) elseif i ==2 then return (self.hei >2 and 2 or self.hei) end
				end
				
				if i ~= 1 then 
					if self.tmp_zhus[i] and  self.tmp_zhus[i] > 100 then self.tmp_zhus[i] = self.tmp_zhus[i] - 100 end
				else
					if self.tmp_zhu > 100 then self.tmp_zhu = self.tmp_zhu - 100 end
				end
				--self.m_tabNodeCards[gt.MY_VIEWID]:add_star()
				self.liangzhu:getChildByName("l"..i):setVisible(false)
				local m = {}
				m.kMId = gt.MSG_C_2_S_SHUANGSHENG_SELECT_ZHU
				m.kPos = self.UsePos
				m.kSelectCardCount = i == 1 and 2 or call()
				m.kSelectCard = i == 1 and self.tmp_zhu or self.tmp_zhus[i]
				m.kCount = self._count
				gt.socketClient:sendMessage(m)
				if i == 1 and GamesjLogic:GetCardLogicValue(self.tmp_zhu) == 17 then 
					self.liangzhu:getChildByName("l1"):setVisible(false)
					
				else
					self._action = true
					self.liangzhu:getChildByName("l1"):setVisible(false)
					--self:PlaySound("sj_sound/fwz.mp3")
				end
				

				-- if m.kSelectCardCount == 1 then 
				-- 	self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard)
				-- elseif m.kSelectCardCount == 2 then 

				-- 	if m.kSelectCard ~= 64 then 
				-- 		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard)
				-- 		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard+100)
				-- 	else
				-- 		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self._zhu,true)
				-- 	end
				-- end


				-- for i = 1 , gt.GAME_PLAYER do 
				-- 	self["lz"..i]:setVisible(i == gt.MY_VIEWID)

				-- 	for x = 1 , m.kSelectCardCount do
				-- 		self["lz"..i]:getChildByName("x"..x):setVisible(true)
				-- 		self["lz"..i]:getChildByName("x"..x):loadTexture("poker_sj/"..gt.tonumber(m.kSelectCard)..".png")
				-- 	end
				-- end
				-- self["lz"..self:getTableId(self.UsePos)]:stopAllActions()
				-- local scale = self["lz"..self:getTableId(m.kPos)]:getScale()
				-- self["lz"..self:getTableId(self.UsePos)]:runAction(cc.Sequence:create( cc.Spawn:create( cc.ScaleTo:create(0.1,scale+0.2),  cc.FadeOut:create(0.1)  ) , cc.Spawn:create( cc.ScaleTo:create(0.1,scale),  cc.FadeIn:create(0.1)  ) ))

				for i =1 , 5 do
					self.liangzhu:getChildByName("l"..i):setVisible(false)
				end

				if m.kSelectCardCount == 2 then 
					for i =2 , 5 do
						self.liangzhu:getChildByName("l"..i):setVisible(false)
					end
					if GamesjLogic:GetCardLogicValue( m.kSelectCard ) == 16 then 
						if not self.wamg2 then 
							self.liangzhu:getChildByName("l1"):setVisible(false)
							self._return1 = true
						end
						-- self:PlaySound("sj_sound/fwz.mp3")
						-- ac(gt.MY_VIEWID)
						-- for i = 1 , gt.GAME_PLAYER do 

						-- 	self["lz"..i]:setVisible(i == gt.MY_VIEWID)
						-- 	if i == gt.MY_VIEWID then 
						-- 		self["lz"..i]:getChildByName("x"..4):setVisible(true)
						-- 		self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h0.png")
						-- 	end
							
						-- end
					elseif GamesjLogic:GetCardLogicValue( m.kSelectCard ) == 17 then 
						self.liangzhu:getChildByName("l1"):setVisible(false)
						self._return = true
						-- self:PlaySound("sj_sound/fwz.mp3")
						-- ac(gt.MY_VIEWID)
						-- for i = 1 , gt.GAME_PLAYER do 
						-- 	self["lz"..i]:setVisible(i == gt.MY_VIEWID)
						-- 	if i == gt.MY_VIEWID then 
						-- 		self["lz"..i]:getChildByName("x"..4):setVisible(true)
						-- 		self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h00.png")
						-- 	end
							
						-- end
					else 
						self._return2 = true
					end
					self.liangzhu:getChildByName("tx_pian"):setColor(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
					self.liangzhu:getChildByName("tx_pian"):enableGlow(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
					self.liangzhu:getChildByName("tx_hua"):setColor(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
					self.liangzhu:getChildByName("tx_hua"):enableGlow(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
					self.liangzhu:getChildByName("tx_hong"):setColor(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
					self.liangzhu:getChildByName("tx_hong"):enableGlow(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
					self.liangzhu:getChildByName("tx_hei"):setColor(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
					self.liangzhu:getChildByName("tx_hei"):enableGlow(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))

				elseif m.kSelectCardCount == 1 then 

					if self.pian == 1  then 
						self.liangzhu:getChildByName("l5"):setVisible(false)
						self.liangzhu:getChildByName("tx_pian"):setColor(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
						self.liangzhu:getChildByName("tx_pian"):enableGlow(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
					end

					if self.hua == 1  then 
						self.liangzhu:getChildByName("l4"):setVisible(false)
						self.liangzhu:getChildByName("tx_hua"):setColor(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
						self.liangzhu:getChildByName("tx_hua"):enableGlow(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))

					end

					if self.hong == 1  then 
						self.liangzhu:getChildByName("l3"):setVisible(false)
						self.liangzhu:getChildByName("tx_hong"):setColor(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
						self.liangzhu:getChildByName("tx_hong"):enableGlow(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
					end

					if self.hei == 1  then 
						self.liangzhu:getChildByName("l2"):setVisible(false)
						self.liangzhu:getChildByName("tx_hei"):setColor(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
						self.liangzhu:getChildByName("tx_hei"):enableGlow(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
					end
					self._return5 = true
					
				end
				self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self._zhu,true)
				self.m_tabNodeCards[gt.MY_VIEWID]:bDispatching()

				

		end,0.1)
	end


	
	gt.setOnViewClickedListeners(self.ready,function()
		
		self:onStartGame()
		self:OnResetView()

		end)

	
	gt.setOnViewClickedListeners(self.m_btnInvite,function()
		
			self:shareWx()
		
		end)



	self.m_flagReady = {}
	self._clock = {}
	self.head_hui  = {}
	self.nodePlayer = {}
	self._voice = {}
	self._voice_node = {}
	self._voice_nodes = {}
	self.Player = {}
	self.m_UserHead = {}
	self.m_tabNodeCards = {}
	self.urlName = {}
	self.liang_buf = {}
	self.buf_posX ={}
	self.buf_posY ={}
	for i = 1 , gt.GAME_PLAYER do
		self.player_num[i] = false
		self.liang_buf[i-1] = 0
		self.Player[i] = {}
		self.Player[i].name = ""
		self.Player[i].score = nil
		self.Player[i].url = nil
		self.Player[i].sex = nil
		self.Player[i].id = nil
		self.Player[i].ip= nil
		self.Player[i].pos= ""..","..""
		self.Player[i].Coins= nil
		self.Player[i]._pos = nil

		self.m_flagReady[i] = self:findNodeByName("ok_"..i)
		:setVisible(false)



		self._clock[i] = self:findNodeByName("clock_"..i)
		:setVisible(false)

	

		self.head_hui[i] = self:findNodeByName("zanli_"..i)
		:setVisible(false)

		self.nodePlayer[i] = self:findNodeByName("player_"..i)
		self.nodePlayer[i]:setVisible(false)

		self.nodePlayer[i]:getChildByName("icon1"):setVisible(false)
		self.nodePlayer[i]:getChildByName("icon1"):setLocalZOrder(9)

		self.buf_posX[i] = self.nodePlayer[i]:getPositionX()
		self.buf_posY[i] = self.nodePlayer[i]:getPositionY()

		

		self.m_UserHead[i] = {}
		--昵称
		self.m_UserHead[i].name =  self:findNodeByName("name",self.nodePlayer[i])
								
		--金币
		self.m_UserHead[i].score =  self:findNodeByName("score",self.nodePlayer[i])
	
		self.m_UserHead[i].head = nil
		
       	self.m_UserHead[i].banker = self.nodePlayer[i]:getChildByName("banker")
       	self.m_UserHead[i].banker:setVisible(false)
       	self.m_UserHead[i].banker:setLocalZOrder(10)
       
    --     self.m_UserChatView[i] = display.newSprite((i<= gt.MY_VIEWID and "game_chat_s0.png" or "game_chat_s1.png")	,{scale9 = true ,capInsets=cc.rect(30, 14, 46, 20)})
				-- :setAnchorPoint(i<= gt.MY_VIEWID  and cc.p(0,0.5) or cc.p(1,0.5))
				-- :move(ptChat[i])
				-- :setVisible(false)
				-- :addTo(self._node)


		-- self._voice[i] = self:findNodeByName("voice_"..i)
		-- 		:setVisible(false)
		-- 		:move(ptChat[i])

		-- self._voice_node[i] = self:findNodeByName("FileNode_"..i)
		-- 					:setVisible(false)
		-- 					:move(ptChat[i].x,ptChat[i].y+2)



		local times = 0

		gt.setOnViewClickedListener(self.nodePlayer[i]:getChildByName("bg"),function()




			-- if os.time() - times < 1 then 

			-- 	local scene = display.getRunningScene() if scene then Toast.showToast(scene, "操作频繁稍后重试！", 1) end
			-- else
			-- 	times = os.time()
				self:PlaySound("sound_res/cli.mp3")
				self:showPlayerinfo(i)
			--end

			end,0.2)


   		-- if self.data.kPlaytype[3] == 1 and i ~= gt.MY_VIEWID then 
   		-- 	self.nodePlayer[i]:getChildByName("infobg"):setVisible(false)
   		-- end


	    self.m_UserChatView[i] = display.newSprite((i<= gt.MY_VIEWID and "game_chat_s0.png" or "game_chat_s1.png")	,{scale9 = true ,capInsets=cc.rect(30, 14, 46, 20)})
			:setAnchorPoint(i<= gt.MY_VIEWID  and cc.p(0,0.5) or cc.p(1,0.5))
			:move(ptChat[i])
			:setVisible(false)
			:addTo(self._node)

		-- self.m_UserChatView[i]:setPositionY(self.m_UserChatView[i]:getPositionY())
		self._voice[i] = self:findNodeByName("voice_"..i)
		self._voice[i]:setVisible(false)
		self._voice[i]:setScaleX(0.5)
		self._voice[i]:setScaleY(0.75)
		local offsetX = 70
		local offsetY = 70
		if i == 1 then
			offsetX = 75
			offsetY = 0
		elseif i == 4 then
			offsetX = -75
			offsetY = 70
		else
			offsetX = 70
			offsetY = 70
		end
		self._voice[i]:setPositionX(self.m_UserChatView[i]:getPositionX() + offsetX)
		self._voice[i]:setPositionY(self.m_UserChatView[i]:getPositionY() - offsetY)
		self._voice_node[i] = self:findNodeByName("yy" .. i)
		:setVisible(false)
		self._voice_node[i]:setPosition(self._voice[i]:getPositionX(),self._voice[i]:getPositionY() + 2)
		if i == 1 or i == 3 then
			self._voice_node[i]:setRotation(180)
		end


		self["lz"..i] = self:findNodeByName("Image__"..i) -- 亮主的牌
		:setVisible(false)


	end


	self.push_card = self:findNodeByName("push_card")
	:setVisible(false)
	:setEnabled(false)

	gt.setOnViewClickedListeners(self.push_card,function()
	--	self:show_log("push_card")
		self.push_card:setEnabled(false)
		self:send_push_card()
		
	end)


	self.text5 = self:findNodeByName("mai_di_text")
	:setVisible(false)

	self.gameinfo = self:findNodeByName("game_info")
	:setVisible(false)

	self._room_info = self:findNodeByName("room_info")
	

	self._info = self:findNodeByName("info")
	gt.setOnViewClickedListeners(self._info,function()

			-- local room_info = require("client/game/poker/view/roomInfo"):create(self.data,self.result_jushi)
			-- gt.addNode(self,room_info, 101)
			local m = self.data
			self:findNodeByName("t1",r_info):setString("房间号："..(m.kPlaytype[10]~= 0 and "xxxxxx" or m.kDeskId))
			self:findNodeByName("t7",r_info):setString(m.kPlaytype[4] == 1 and "2是常主" or "2不是常主")
			self:findNodeByName("t3",r_info):setString("底分："..m.kPlaytype[1].."分")
			self:findNodeByName("t2",r_info):setString(m.kPlaytype[2] == 1 and "随机主" or "从3开始")

			self:findNodeByName("t5",r_info):setVisible(m.kPlaytype[3] == 1)
			self:findNodeByName("t6",r_info):setVisible(m.kGpsLimit == 1)
			self:findNodeByName("t4",r_info):setString("局数："..(self.result_jushi or "0 / 0"))
			r_info:setVisible(true)

		end)

    -- 扑克牌
    self.m_outCardsControl = self:findNodeByName( "outcards_control" )

    self.m_tabNodeCards[gt.MY_VIEWID] = sjCardNode:createEmptysjCardNode(gt.MY_VIEWID)
    self.m_cardControl = self:findNodeByName( "cards_control" )
    self.m_tabNodeCards[gt.MY_VIEWID]:setPosition(  cc.p(667, 90) )
    self.m_tabNodeCards[gt.MY_VIEWID]:setListener(self)
    gt.log("self.m_tabNodeCards[gt.MY_VIEWID]",self.m_tabNodeCards[gt.MY_VIEWID])
    if gt.addNode(self.m_cardControl,self.m_tabNodeCards[gt.MY_VIEWID]) then 
    	
    end
   	self.m_cardControl:setVisible(false)

   	self._mai_di = self:findNodeByName( "mai_di_node" )
   	self._mai_di:setVisible(false)
   	gt.addNode(self._mai_di,mai_di:create(),3000,1)



 --   	local textspr = cc.Sprite:create()
 --   	self:addChild(textspr)


 --   	local tmpspr = textspr

	-- textspr:removeFromParent()

	-- gt.log(tostring(tolua.isnull(tmpspr)))

   	local node = self:findNodeByName("timer")
	if node then node:setString(os.date("%H:%M")) gt.log("time————") end
	self.__time = _scheduler:scheduleScriptFunc(function()
		if node then node:setString(os.date("%H:%M")) end

		-- gt.log(tostring(tolua.isnull(tmpspr)))

		-- gt.log(tolua.type(tmpspr))

	end,1,false)


	local UserInfo = require("client/game/majiang/UserInfo"):create()
	self.UserInfo = UserInfo
	self:addChild(UserInfo,1000)

	self.UserInfo:setVisible(false)

end

function sjScene:showPlayerinfo(i)

	if self.data.kPlaytype[3] == 1 then local scene = display.getRunningScene() if scene then Toast.showToast(scene, "当前防作弊房间，禁止查看玩家信息！", 1) return end end 
	if i < 0 or i > gt.GAME_PLAYER then return end
	gt.log("iiiii ==" , i)
	gt.log("self.Player[i].id=====", self.Player[i].id)
	if self.Player[i].id and self.UserInfo.init then
		self.UserInfo:init(self.Player[i])
	end

end

function sjScene:ActionText5(bool,time)

	log("text5___________",bool)

	self.text5:setVisible(bool)
	local _time = time 
	if not bool then

		if self.___action then
			_scheduler:unscheduleScriptEntry(self.___action)
			self.___action = nil
		end
	else
		self.text5:getChildByName("clock"):getChildByName("time"):setString(_time)
		if self.___action then
			_scheduler:unscheduleScriptEntry(self.___action)
			self.___action = nil
		end
		for j = 1 , 3 do self.text5:getChildByName("dian_"..j):setVisible(false)  end
		if self.___action then
			_scheduler:unscheduleScriptEntry(self.___action)
			self.___action = nil
		end
		local i = 0
		self.___action = _scheduler:scheduleScriptFunc(function()
			i = i +1 
			_time = _time - 0.5
			
			if _time % 1 == 0 then 
				if _time == 2 then 
					self.text5:getChildByName("clock"):stopAllActions()
					self:PlaySound("sound_res/ddz/clock.mp3")
					self.text5:getChildByName("clock"):runAction(cc.RepeatForever:create( cc.Sequence:create(cc.RotateTo:create(0.01,10),cc.RotateTo:create(0.01,0),cc.RotateTo:create(0.01,-10),cc.RotateTo:create(0.01,0))))	
				end
				
				if _time >= 0 then 
					self.text5:getChildByName("clock"):getChildByName("time"):setString(_time)
				end
			end
			if i == 4 then i = 1 for j = 1 , 3 do self.text5:getChildByName("dian_"..j):setVisible(false)  end end
			self.text5:getChildByName("dian_"..i):setVisible(true)
		end,0.5,false)	
	end

end

function sjScene:ActionText(bool,time)

	

	self._disrupt:getChildByName("sand"):setVisible(bool)
	local _time = time 
	if not bool then

		if self.____action then
			_scheduler:unscheduleScriptEntry(self.____action)
			self.____action = nil
		end
	else
	
		if self.____action then
			_scheduler:unscheduleScriptEntry(self.____action)
			self.____action = nil
		end
		for j = 1 , 3 do self._disrupt:getChildByName("sand"):getChildByName("dian_"..j):setVisible(false)  end
		if self.____action then
			_scheduler:unscheduleScriptEntry(self.____action)
			self.____action = nil
		end
		local i = 0
		self.____action = _scheduler:scheduleScriptFunc(function()
			i = i +1 
			
			if i == 4 then i = 1 for j = 1 , 3 do self._disrupt:getChildByName("sand"):getChildByName("dian_"..j):setVisible(false)  end end
			self._disrupt:getChildByName("sand"):getChildByName("dian_"..i):setVisible(true)
		end,1,false)	
	end

end


function sjScene:bao_zhu(m)

	--[[
	 kPos;					//叫主玩家
    kSelectZhu;				//玩家叫主的牌
    kSelectZhuCount;			//玩家叫主的张数

	]]

	gt.log("baozhu______________________result")

	self.liang_buf[m.kPos] = m.kCount 

	--if m.kPos ~= self.UsePos then 


		for i = 1 , gt.GAME_PLAYER do 
			self["lz"..i]:setVisible(i == self:getTableId(m.kPos))
			for x = 1 , m.kSelectZhuCount do
				self["lz"..i]:getChildByName("x"..x):setVisible(true)
				self["lz"..i]:getChildByName("x"..x):loadTexture("poker_sj/"..gt.tonumber(m.kSelectZhu)..".png")
			end
		end
		local scale = self["lz"..self:getTableId(m.kPos)]:getScale()
		self["lz"..self:getTableId(m.kPos)]:stopAllActions()
		self["lz"..self:getTableId(m.kPos)]:runAction(cc.Sequence:create( cc.Spawn:create( cc.ScaleTo:create(0.1,scale+0.2),  cc.FadeOut:create(0.1)  ) , cc.Spawn:create( cc.ScaleTo:create(0.1,scale),  cc.FadeIn:create(0.1)  ) ))

		local ac = function(x)
			self.fz:stopAllActions()
			self.fz:setVisible(true)
			local node =cc.CSLoader:createTimeline("runAction/fz_run.csb")	
			self.fz:runAction(node)
			node:gotoFrameAndPlay(0,false)
			self.fz:setPosition(cc.p(self["lz"..x]:getPositionX(),self["lz"..x]:getPositionY()))
		end

		local fun = function()
			for i = 0 , gt.GAME_PLAYER - 1 do 
				if i ~= m.kPos then 
					if self.liang_buf[i] ~= 0 then 
						ac(self:getTableId(m.kPos))
						return true  -- 
					end
				end
			end
			return false
		end

		local func = function()
			if GamesjLogic:GetCardColor(m.kSelectZhu) == 64 then 
				return 1 
			elseif GamesjLogic:GetCardColor(m.kSelectZhu) == 0 then 
				return 5
			elseif GamesjLogic:GetCardColor(m.kSelectZhu) == 16 then 
				return 4
			elseif GamesjLogic:GetCardColor(m.kSelectZhu) == 32 then 
				return 3
			elseif GamesjLogic:GetCardColor(m.kSelectZhu) == 48 then 
				return 2
			end
		end
		local j = func()

		gt.log("iiii.....",j,m.kSelectZhu)
		gt.log(self:getTableId(m.kPos))

		if j == 2 then 	
		gt.log("iiii.....1",j)																
			if m.kCount == 1 then -- 亮主  or 反主                                      -- 反主                 -- 亮主
				self:PlaySound(m.kSelectZhuCount == 1 and "sj_sound/htl.mp3" or ( fun() and "sj_sound/htf.mp3" or "sj_sound/htl.mp3")  )
			elseif m.kCount == 2 and m.kSelectZhuCount == 2 then   --  加固 
				self:PlaySound(m.kSelectZhuCount == 1 and "sj_sound/htjg.mp3" or "sj_sound/htjg.mp3") 
				ac(self:getTableId(m.kPos))
			end
			for i = 1 , gt.GAME_PLAYER do 
				self["lz"..i]:setVisible(i == self:getTableId(m.kPos))
				if i == self:getTableId(m.kPos) then 
					if m.kSelectZhuCount == 1 then 
						gt.log("1_________________")
						self["lz"..i]:getChildByName("x"..4):setVisible(true)
						self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h1.png")
						self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
						self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d1.png")
					elseif m.kSelectZhuCount == 2 then 
						self["lz"..i]:getChildByName("x"..3):setVisible(true)
						self["lz"..i]:getChildByName("x"..3):loadTexture("sjScene/h1.png")
						self["lz"..i]:getChildByName("x"..4):setVisible(true)
						self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h1.png")
						self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
						self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d1.png")
					end
					
				end
			end
		elseif j == 3 then 
			gt.log("iiii.....2",j)
			if m.kCount == 1 then -- 亮主  or 反主                                      -- 反主                 -- 亮主
				self:PlaySound(m.kSelectZhuCount == 1 and "sj_sound/h_tl.mp3" or ( fun() and "sj_sound/h_tf.mp3" or "sj_sound/h_tl.mp3")  )
			elseif m.kCount == 2 and m.kSelectZhuCount == 2 then   --  加固 
				self:PlaySound(m.kSelectZhuCount == 1 and "sj_sound/h_tjg.mp3" or "sj_sound/h_tjg.mp3") 
				ac(self:getTableId(m.kPos))
			end
			for i = 1 , gt.GAME_PLAYER do 
				self["lz"..i]:setVisible(i == self:getTableId(m.kPos))
				if i == self:getTableId(m.kPos) then 
				if m.kSelectZhuCount == 1 then 
					gt.log("1_________________2")
					self["lz"..i]:getChildByName("x"..4):setVisible(true)
					self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h2.png")
					self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
					self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d2.png")
				elseif m.kSelectZhuCount == 2 then 
					self["lz"..i]:getChildByName("x"..3):setVisible(true)
					self["lz"..i]:getChildByName("x"..3):loadTexture("sjScene/h2.png")
					self["lz"..i]:getChildByName("x"..4):setVisible(true)
					self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h2.png")
					self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
					self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d2.png")
				end
				
				end
			end
		elseif j == 4 then
			gt.log("iiii.....3",j)
			if m.kCount == 1 then -- 亮主  or 反主                                      -- 反主                 -- 亮主
				self:PlaySound(m.kSelectZhuCount == 1 and "sj_sound/hl.mp3" or ( fun() and "sj_sound/hf.mp3" or "sj_sound/hl.mp3")  )
			elseif m.kCount == 2 and m.kSelectZhuCount == 2 then   --  加固 
				self:PlaySound(m.kSelectZhuCount == 1 and "sj_sound/hjg.mp3" or "sj_sound/hjg.mp3") 
				ac(self:getTableId(m.kPos))
			end
			for i = 1 , gt.GAME_PLAYER do 
				self["lz"..i]:setVisible(i == self:getTableId(m.kPos))
				if i == self:getTableId(m.kPos) then 
				if m.kSelectZhuCount == 1 then 
					gt.log("1_________________3")
					self["lz"..i]:getChildByName("x"..4):setVisible(true)
					self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h3.png")
					self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
					self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d3.png")
				elseif m.kSelectZhuCount == 2 then 
					self["lz"..i]:getChildByName("x"..3):setVisible(true)
					self["lz"..i]:getChildByName("x"..3):loadTexture("sjScene/h3.png")
					self["lz"..i]:getChildByName("x"..4):setVisible(true)
					self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h3.png")
					self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
					self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d3.png")
				end
				
				end
			end
		elseif j == 5 then 
			gt.log("iiii.....4",j)
			if m.kCount == 1 then -- 亮主  or 反主                                      -- 反主                 -- 亮主
				self:PlaySound(m.kSelectZhuCount == 1 and "sj_sound/pl.mp3" or ( fun() and "sj_sound/pf.mp3" or "sj_sound/pl.mp3")  )
			elseif m.kCount == 2 and m.kSelectZhuCount == 2 then   --  加固 
				self:PlaySound(m.kSelectZhuCount == 1 and "sj_sound/pjg.mp3" or "sj_sound/pjg.mp3") 
				ac(self:getTableId(m.kPos))
			end
			for i = 1 , gt.GAME_PLAYER do 
				self["lz"..i]:setVisible(i == self:getTableId(m.kPos))
				gt.log("i",i,self:getTableId(m.kPos))
				if i == self:getTableId(m.kPos) then 
					gt.log("m.kCount",m.kCount)
				if m.kSelectZhuCount == 1 then 
					gt.log("1_________________2")
					self["lz"..i]:getChildByName("x"..4):setVisible(true)
					self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h4.png")
					self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
					self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d4.png")
				elseif m.kSelectZhuCount == 2 then 
					self["lz"..i]:getChildByName("x"..3):setVisible(true)
					self["lz"..i]:getChildByName("x"..3):loadTexture("sjScene/h4.png")
					self["lz"..i]:getChildByName("x"..4):setVisible(true)
					self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h4.png")
					self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
					self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d4.png")
				end
				
				end
			end
		elseif j == 1 then 
			self:PlaySound("sj_sound/fwz.mp3")
			ac(self:getTableId(m.kPos))
		end



		self.m_tabNodeCards[gt.MY_VIEWID]:add_star()
		if m.kSelectZhuCount == 2 then 
			for i =2 , 5 do
				self.liangzhu:getChildByName("l"..i):setVisible(false)
			end
			if GamesjLogic:GetCardLogicValue( m.kSelectZhu ) == 16 then 
				if not self.wamg2 then 
					self.liangzhu:getChildByName("l1"):setVisible(false)
					self._return1 = true
				end
				for i = 1 , gt.GAME_PLAYER do 
					self["lz"..i]:setVisible(i == self:getTableId(m.kPos))
					if i == self:getTableId(m.kPos) then 
						self["lz"..i]:getChildByName("x"..4):setVisible(true)
						self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h0.png")
						self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
						self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d5.png")
					end
				end
			elseif GamesjLogic:GetCardLogicValue( m.kSelectZhu ) == 17 then 
				
				self.liangzhu:getChildByName("l1"):setVisible(false)
				self._return = true
				for i = 1 , gt.GAME_PLAYER do 
					self["lz"..i]:setVisible(i == self:getTableId(m.kPos))
					if i == self:getTableId(m.kPos) then 
						self["lz"..i]:getChildByName("x"..4):setVisible(true)
						self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h00.png")
						self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
						self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d6.png")
					end
				end
			else
				self._return2 = true
			end
			self.liangzhu:getChildByName("tx_pian"):setColor(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
			self.liangzhu:getChildByName("tx_pian"):enableGlow(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			self.liangzhu:getChildByName("tx_hua"):setColor(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
			self.liangzhu:getChildByName("tx_hua"):enableGlow(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			self.liangzhu:getChildByName("tx_hong"):setColor(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
			self.liangzhu:getChildByName("tx_hong"):enableGlow(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			self.liangzhu:getChildByName("tx_hei"):setColor(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
			self.liangzhu:getChildByName("tx_hei"):enableGlow(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			if m.kSelectZhu ~= 64 then 
				self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectZhu)
				self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectZhu+100)
			else
				self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self._zhu,true)
			end
			
		elseif m.kSelectZhuCount == 1 then 
			gt.log("self.pian",self.pian,self.hua,self.hong,self.hei)
			if self.pian == 1 then 
				self.liangzhu:getChildByName("l5"):setVisible(false)
				self.liangzhu:getChildByName("tx_pian"):setColor(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
				self.liangzhu:getChildByName("tx_pian"):enableGlow(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			end
			if self.hua == 1 then 
				self.liangzhu:getChildByName("l4"):setVisible(false)
				self.liangzhu:getChildByName("tx_hua"):setColor(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
				self.liangzhu:getChildByName("tx_hua"):enableGlow(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			end
			if self.hong == 1 then 
				
				gt.log("cae______________")
				self.liangzhu:getChildByName("l3"):setVisible(false)
				self.liangzhu:getChildByName("tx_hong"):setColor(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
				self.liangzhu:getChildByName("tx_hong"):enableGlow(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			end
			if self.hei == 1  then 
				
				self.liangzhu:getChildByName("l2"):setVisible(false)
				self.liangzhu:getChildByName("tx_hei"):setColor(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
				self.liangzhu:getChildByName("tx_hei"):enableGlow(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			end
			self._return5 = true
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectZhu)
			
		end

		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self._zhu,true)

		if m.kPos ~= self.UsePos then 
			self._action = false
		end
		self.m_tabNodeCards[gt.MY_VIEWID]:bDispatching()

end

function sjScene:fan_zhu( m )
	
end

function sjScene:OnResetView()
	self.my_card = nil
	self.result_node:setVisible(false)
	self.po_runs= true
	self.kWinnerPos = 4
	self.po_node:stopAllActions()
	self.po_node:setVisible(false)
	self.banker_pos =  -1
	for i = 1 , gt.GAME_PLAYER do 
		self["lz"..i]:stopAllActions()
		self["lz"..i]:setVisible(false)
		for x = 1 , 4 do
			self["lz"..i]:getChildByName("x"..x):setVisible(false)
		end
		--self.nodePlayer[i]:stopAllActions()
		self.nodePlayer[i]:setScale(0.65)
		self.nodePlayer[i]:setPosition(cc.p(self.buf_posX[i],self.buf_posY[i]) )
	end
	self:removeChildByName("_KOUDI_")
	self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(false)
	for i = 1, gt.GAME_PLAYER do
		--self.m_flagReady[i]:setVisible(false)
		if i <= 3 then 
			self:findNodeByName("score_card"..i):setVisible(false)
		end

		self.m_UserHead[i].banker:setVisible(false)
		self.m_UserHead[i].banker:stopAllActions()
		
	end

	self:findNodeByName("qingzhuangda"):setVisible(false)
	self:findNodeByName("duifangda"):setVisible(false)
	self:findNodeByName("wofangda"):setVisible(false)

	self.clour = -1
	for i = 1 , 25 do
		self._node:removeChildByName("SCORE_"..i)
	end
	self._return = false
	self._return1 = false
	self._return2 = false
	self._return5 = false
	self._action = false
	--self.m_btnInvite:setVisible(false)
	self.ready:setVisible(false)

	self.ready:setPositionX(self.m_btnInvite:getPositionX())
	self.m_cardControl:setVisible(true)

	self:renovate_huase()
	self:ActionText5(false)


	self.tuolaji:setVisible(false)
	self.tuolaji:stopAllActions()
	self.shuaipai:setVisible(false)
	self.shuaipai:stopAllActions()
	self.bi:setVisible(false)
	self.bi:stopAllActions()
	self.maidi:setVisible(false)
	self.maidi:stopAllActions()
	self.fz:setVisible(false)
	self.fz:stopAllActions()
	-- self._disrupt:stopAllActions()

	-- for k , y in pairs(self._disrupt:getChildren()) do


	-- 	gt.log("cccccccccccccccccccc")

	-- 	gt.log(y:getName())


	-- end

	self._disrupt:getChildByName( "Node" ):stopAllActions()
	self._disrupt:setVisible(false)
	self.tong:setVisible(false)
	self:ActionText(false)


end

function sjScene:send_card(m)
	
	self.sendcard_m = m
	if self._run then return end
	self.sendcard_m = nil


	self._result_min = nil
	for i = 1 , gt.GAME_PLAYER do

		if self.data.kPlaytype[3] == 1 then 
			self.nodePlayer[i]:getChildByName("infobg"):setVisible(i==gt.MY_VIEWID)
			self.nodePlayer[i]:getChildByName("icon1"):setVisible(i~=gt.MY_VIEWID)
			self.nodePlayer[i]:getChildByName("icon1"):setLocalZOrder(8)
		end

		self.m_UserHead[self:getTableId(i-1)].score:setString(m.kTotleScore[i])
		self.m_flagReady[i]:setVisible(false)
	end
	self._disrupt:stopAllActions()
	self:OnResetView()
	self:stopAllActions()
	self._count = 0
	self.m_btnInvite:setVisible(false) 
	self.gameBegin = true
	
	gt.log("seng_card____________")
	gt.dump(m)


	local buf = {}

	--self:show_log("kHandCardsCount:"..m.kHandCardsCount)

	for i = 1 , m.kHandCardsCount do
    	buf[i] = m.kHandCards[i]
    end
    buf = yl.add_switch_card(buf)
    self.my_card = buf

    self.liangzhu:setVisible(true)
    self:action_room_info(true,true)
    self._zhu = m.kCurrGrade

   
    self.m_tabNodeCards[gt.MY_VIEWID]:updatesjCardNode(buf, true, true)
    
    if self.data.kPlaytype[4] == 1  then 
   		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(2,true)
   	end


    for i = 1 , #buf do
    	--gt.log("GetCardValue.........",GamesjLogic:GetCardValue(buf[i]))
    	if GamesjLogic:GetCardValue(buf[i]) == 14 then 
    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(14,true)
    	end
    	if GamesjLogic:GetCardValue(buf[i]) == 15 then 
    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(15,true)
    	end
    end

   	gt._changzhus = self._zhu
   	self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kCurrGrade,true)


   	--send_card 

   
    if m.kZhuangPos ~= 4 then 
    	for i = 1 , gt.GAME_PLAYER do 
			self.m_UserHead[i].banker:setVisible(i == self:getTableId(m.kZhuangPos))
			self.m_UserHead[i].banker:stopAllActions()
			local z = cc.CSLoader:createTimeline("runAction/banker_run.csb")	
			self.m_UserHead[i].banker:runAction(z)
			z:gotoFrameAndPlay(0,false) 
		end
		

		for i = 1 , gt.GAME_PLAYER do
			if self:getTableId(self.UsePos) % 2 ~= self:getTableId(m.kZhuangPos) % 2 then  --- 2  - 4 
				self:findNodeByName("duifangda"):setVisible(true)
				self:findNodeByName("duifangda"):getChildByName("num"):loadTexture("sjScene/"..GamesjLogic:get_card_string(self._zhu)..".png")
			elseif self:getTableId(self.UsePos) % 2 == self:getTableId(m.kZhuangPos) % 2 then -- 1 -- 3 
				self:findNodeByName("wofangda"):setVisible(true)
				self:findNodeByName("wofangda"):getChildByName("num"):loadTexture("sjScene/"..GamesjLogic:get_card_string(self._zhu)..".png")
			end
		end
		self:PlaySound("sj_sound/qingzhu.mp3")
		self.banker_pos = m.kZhuangPos
	else
		

		
		self:PlaySound("sj_sound/qingz.mp3")
		self:findNodeByName("qingzhuangda"):setVisible(true)
		self:findNodeByName("qingzhuangda"):getChildByName("num"):loadTexture("sjScene/"..GamesjLogic:get_card_string(self._zhu)..".png")
	
    end
    self:game_info(m.kGradeCard[ self.UsePos>1 and self.UsePos-2+1 or self.UsePos+1 ] ,m.kGradeCard[ 1 - (self.UsePos>1 and self.UsePos-2 or self.UsePos) + 1 ],0)
end

function sjScene:action_room_info(bool,isAction)

	if bool then 
		isAction = isAction or false
		if isAction then 
			self._room_info:stopAllActions()
			self._room_info:runAction(cc.Sequence:create( cc.Spawn:create( cc.MoveTo:create(0.5,cc.p(self._info:getPositionX(),self._info:getPositionY())),cc.ScaleTo:create(1,0.1) ) ,cc.CallFunc:create(function()
					self._room_info:setVisible(false)
					self._info:setVisible(true)
					self.gameinfo:setVisible(true)

				end)))
		else
			self._room_info:setVisible(false)
			self._info:setVisible(true)
			self.gameinfo:setVisible(true)
		end
	else
		self._room_info:setVisible(true)
		self._info:setVisible(false)
		self.gameinfo:setVisible(false)
	end

end

function sjScene:game_info(a,b,c)


	if a then self.gameinfo:getChildByName("Text_1"):setString("我方打："..GamesjLogic:get_card_string(a))  if self.banker_pos ~= -1 then  self.gameinfo:getChildByName("Text_1"):setColor( self.banker_pos%2 == self.UsePos%2 and cc.c3b(255,210,101) or cc.c3b(255,255,255) ) else self.gameinfo:getChildByName("Text_1"):setColor(cc.c3b(255,255,255)) end end
	if b then self.gameinfo:getChildByName("Text_2"):setString("对方打："..GamesjLogic:get_card_string(b)) if self.banker_pos ~= -1 then  self.gameinfo:getChildByName("Text_2"):setColor( self.banker_pos%2 ~= self.UsePos%2 and cc.c3b(255,210,101) or cc.c3b(255,255,255) ) else self.gameinfo:getChildByName("Text_2"):setColor(cc.c3b(255,255,255)) end end
	if c then self.gameinfo:getChildByName("Text_3"):setString(c) end

end



function sjScene:renovate_huase(clour)
	
	if type(clour) == "table" then 
		local n5 = 0
		local n1 = 0
		local n2 = 0
		local n3 = 0
		local n4 = 0
		local num = 0
		local num1 = 0
		self.pian = 0
		self.hua = 0
		self.hong = 0
		self.hei = 0
		self.tmp_zhu = -1
		self.wamg1 = false
		self.wamg2 = false
		self.tmp_zhus = {}
		for i = 1 , 5 do
			table.insert(self.tmp_zhus , -1)
		end

		
		for i =1 , #clour do
			local CardValue = GamesjLogic:GetCardValue(clour[i])

			if GamesjLogic:GetCardColor(clour[i]) == 0 then 
	            n5 = n5 + 1
	            
	            if self._zhu == CardValue and not self._return and not self._return1 and not self._return2 then 
	            	self.pian = self.pian  + 1
	            	self.tmp_zhus[5] = clour[i]
	            	if ( not self._return5 or self.pian == 2) and (self.clour == GamesjLogic:GetCardColor(clour[i]) or self.clour == -1 ) then 
						self.liangzhu:getChildByName("l5"):setVisible(true)
					end
				end
				if self._return then self.liangzhu:getChildByName("l5"):setVisible(false) end
	        elseif GamesjLogic:GetCardColor(clour[i]) == 16 then
	            n1 = n1 + 1
	            
	            if self._zhu == CardValue and not self._return and not self._return1 and not self._return2 then 
	            	self.hua = self.hua + 1
	            	self.tmp_zhus[4] = clour[i]
	            	if ( not self._return5 or self.hua == 2 ) and (self.clour == GamesjLogic:GetCardColor(clour[i]) or self.clour == -1 ) then 
						self.liangzhu:getChildByName("l4"):setVisible(true)
					end
				end
				if self._return then self.liangzhu:getChildByName("l4"):setVisible(false) end
	        elseif GamesjLogic:GetCardColor(clour[i]) == 32 then
	            n2 = n2 + 1
	           
	            if self._zhu == CardValue and not self._return and not self._return1 and not self._return2 then 
	            	self.hong = self.hong + 1
	            	self.tmp_zhus[3] = clour[i]
	            	if (not self._return5 or self.hong == 2 ) and (self.clour == GamesjLogic:GetCardColor(clour[i]) or self.clour == -1 ) then 
	            		
						self.liangzhu:getChildByName("l3"):setVisible(true)
					end
					
				end
				if self._return then self.liangzhu:getChildByName("l3"):setVisible(false) end
	        elseif GamesjLogic:GetCardColor(clour[i]) == 48 then
	            n3 = n3 + 1
	            if self._zhu == CardValue and not self._return and not self._return1 and not self._return2 then 
	            	self.hei = self.hei + 1
	            	self.tmp_zhus[2] = clour[i]
	            	if ( not self._return5 or self.hei == 2 ) and (self.clour == GamesjLogic:GetCardColor(clour[i]) or self.clour == -1 ) then 
						self.liangzhu:getChildByName("l2"):setVisible(true)
					end
				end
				if self._return then self.liangzhu:getChildByName("l2"):setVisible(false) end
	        elseif GamesjLogic:GetCardColor(clour[i]) == 64 then
	            n4 = n4 + 1
	           
	            if GamesjLogic:GetCardLogicValue(clour[i]) == 16 then 
		        	num = num + 1
		        end
		        if GamesjLogic:GetCardLogicValue(clour[i]) == 17  then 
		        	num1= num1 + 1
		        end
		       
		     	if (num == 2 or num1 == 2) and not self._action then  -- self._action 自己不能反自己
					
					if num == 2 and not self._return1 and not self._return then
						gt.log("clour....1...",clour[i])
						self.tmp_zhu = 78
						self.wamg1 = true
						self.liangzhu:getChildByName("l1"):setVisible(true)
					end
					if self._return then self.liangzhu:getChildByName("l1"):setVisible(false) end
					if num1 == 2 and not self._return then 
						gt.log("clour....2...",clour[i])
						self.tmp_zhu = 79
						self.wamg2 = true
						self.liangzhu:getChildByName("l1"):setVisible(true)
					end
				end
	        end

			
	    end

		self.liangzhu:getChildByName("tx_hei"):setVisible(n3~=0)
		self.liangzhu:getChildByName("tx_hei"):setString(n3)
		self.liangzhu:getChildByName("tx_hei"):setColor(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
		self.liangzhu:getChildByName("tx_hei"):enableGlow(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))

		self.liangzhu:getChildByName("tx_hong"):setVisible(n2~=0)
		self.liangzhu:getChildByName("tx_hong"):setString(n2)
		self.liangzhu:getChildByName("tx_hong"):setColor(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
		self.liangzhu:getChildByName("tx_hong"):enableGlow(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))

		self.liangzhu:getChildByName("tx_hua"):setVisible(n1~=0)
		self.liangzhu:getChildByName("tx_hua"):setString(n1)
		self.liangzhu:getChildByName("tx_hua"):setColor(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
		self.liangzhu:getChildByName("tx_hua"):enableGlow(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))

		self.liangzhu:getChildByName("tx_pian"):setVisible(n5~=0)
		self.liangzhu:getChildByName("tx_pian"):setString(n5)
		self.liangzhu:getChildByName("tx_pian"):setColor(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
		self.liangzhu:getChildByName("tx_pian"):enableGlow(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))

		self.liangzhu:getChildByName("tx_wang"):setVisible(n4~=0)
		self.liangzhu:getChildByName("tx_wang"):setString(n4)
		self.liangzhu:getChildByName("tx_wang"):setColor(self.liangzhu:getChildByName("l1"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
		self.liangzhu:getChildByName("tx_wang"):enableGlow(self.liangzhu:getChildByName("l1"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
		




	else
		self.liangzhu:setVisible(false)
		self.liangzhu:getChildByName("tx_hei"):setVisible(false)
		self.liangzhu:getChildByName("tx_hong"):setVisible(false)
		self.liangzhu:getChildByName("tx_hua"):setVisible(false)
		self.liangzhu:getChildByName("tx_pian"):setVisible(false)
		self.liangzhu:getChildByName("tx_wang"):setVisible(false)

		self.liangzhu:getChildByName("tx_hei") :setString(0)
		self.liangzhu:getChildByName("tx_hong"):setString(0)
		self.liangzhu:getChildByName("tx_hua") :setString(0)
		self.liangzhu:getChildByName("tx_pian"):setString(0)
		self.liangzhu:getChildByName("tx_wang"):setString(0)

		self.pian = 0
		self.hua = 0
		self.hong = 0
		self.hei = 0
		self.tmp_zhu = -1
		self.wamg1 = false
		self.wamg2 = false
		self.tmp_zhus = {}
		for i = 1 , 5 do
			table.insert(self.tmp_zhus , -1)
		end
		for i =1 , 5 do
			self.liangzhu:getChildByName("l"..i):setVisible(false)
		end
	end

end


function sjScene:onStartGame()

	local msgToSend = {}
	msgToSend.kMId = gt.CG_READY
	msgToSend.kPos = self.UsePos
	gt.dumplog(msgToSend)
	gt.socketClient:sendMessage(msgToSend)
	self.m_flagReady[gt.MY_VIEWID]:setVisible(true) 
	self.ready:setVisible(false)
	self.ready:setPositionX(self.m_btnInvite:getPositionX())
	
end

function sjScene:off_line(args)
	self.head_hui[self:getTableId(args.kPos)]:setVisible(0 == args.kFlag)
end
function sjScene:RcvReady(m)

	gt.dump(m)
	
	if m.kPos == self.UsePos then 
		self:OnResetView()

		self.ready:setVisible(false)
		self.ready:setPositionX(self.m_btnInvite:getPositionX())
	end
	self.m_flagReady[self:getTableId(m.kPos)]:setVisible(true) 

end

function sjScene:addPlayer(args)
	
	log("addplayer______________________s")

	if not args then  -- init user

		local pos = self:getTableId(self.UsePos)
		self.player_num[pos] = true
		
		log("pos..",pos)
		self.m_UserHead[pos].score:setString(self.data.kScore)
		self.Player[pos].sex = gt.userSex
		
		self.m_flagReady[pos]:setVisible(self.data.kReady == 1)
		if self.data.kReady == 1 then 
			self.ready:setPositionX(self.m_btnInvite:getPositionX())
		end
		self.ready:setVisible(self.data.kReady ~= 1)
		self.nodePlayer[pos]:setVisible(true)
		gt.log(gt.wxNickName)
		self.Player[pos].score = self.data.kScore
		self.Player[pos].name = gt.wxNickName
		self.Player[pos].score = self.data.kScore
		self.Player[pos].id = gt.playerData.uid
		self.Player[pos].ip = self.data.kUserIp
		self.Player[pos].Coins = self.data.kCoins
		self.Player[pos].pos= self.data.kUserGps
		self.Player[pos].name = gt.wxNickName
		self.Player[pos]._pos = pos
		--self.m_UserHead[pos].name:setString(self.Player[pos].id)
		self.m_UserHead[pos].name:setString(gt.wxNickName)
		
		local url 	= cc.UserDefault:getInstance():getStringForKey( "WX_ImageUrl","" )
		self.Player[pos].url = url
		local icon = self.nodePlayer[pos]:getChildByName("icon")
		self.urlName[pos] = string.gsub(url, "[/.:+]", "")
		local iamge = gt.imageNamePath(url)
		local _node = display.newSprite("sjScene/icon.png")
		_node:retain()
	  	if iamge then
			self.m_UserHead[pos].head = gt.clippingImage(iamge,_node,false)
			_node:release()
			if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
			if gt.addNode(self.nodePlayer[pos],self.m_UserHead[pos].head) then 
				self.m_UserHead[pos].head:setName(self.urlName[pos])
				self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
				self.m_UserHead[pos].head:setLocalZOrder(7)
			end

	  	else

		  	if type(url) ~= nil and  string.len(url) > 10 then
		  		local function callback(args)
		      		if args.done  and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self then
		      			
						self.m_UserHead[pos].head = gt.clippingImage(args.image,_node,false)
						_node:release()
						if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
						if gt.addNode(self.nodePlayer[pos],self.m_UserHead[pos].head) then
							self.m_UserHead[pos].head:setName(self.urlName[pos])
							self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
							self.m_UserHead[pos].head:setLocalZOrder(7)
						end
					end
		        end
			    
			    gt.downloadImage(url,callback)	
			  	
			end
	  	end

	else
		
		local pos = self:getTableId(args.kPos)
		self.player_num[pos] = true
		gt.log("adds.....",pos)
		--self.m_UserHead[pos].score:setString(args.kScore)
		self.Player[pos].sex = args.kSex
		
		self.Player[pos].id = args.kUserId
		self.Player[pos].ip = args.kIp
		self.Player[pos].score = args.kScore
		self.Player[pos].Coins = args.kCoins
		self.Player[pos].pos= args.kUserGps
		self.m_flagReady[pos]:setVisible(args.kReady==1)
		
		self.nodePlayer[pos]:setVisible(true)
		self.Player[pos].name = args.kNike
		self.m_UserHead[pos].name:setString(args.kNike)
		--self.m_UserHead[pos].name:setString(args.kUserId)
		self.Player[pos].url = args.kFace
		self.Player[pos].score = args.kScore
		self.Player[pos]._pos = pos
		self.head_hui[pos]:setVisible(not args.kOnline)
	
		
		local url 	= self.Player[pos].url
		local icon = self.nodePlayer[pos]:getChildByName("icon")
		local iamge = gt.imageNamePath(url)
		self.urlName[pos] = string.gsub(url, "[/.:+]", "")
		local _node = display.newSprite("sjScene/icon.png")
		_node:retain()
	  	if iamge then
			self.m_UserHead[pos].head = gt.clippingImage(iamge,_node,false)
			_node:release()
			if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
			if gt.addNode(self.nodePlayer[pos],self.m_UserHead[pos].head) then 
				self.m_UserHead[pos].head:setName(self.urlName[pos])
				self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
				self.m_UserHead[pos].head:setLocalZOrder(7)
			end

	  	else
	  		
	  		 	if type(url) ~= nil and  string.len(url) > 10 then
			
		  		local function callback(args)
		      		if args.done and display.getRunningScene() and display.getRunningScene().name == "pokerScene" and self then
		      			self.m_UserHead[pos].head = gt.clippingImage(args.image,_node,false)
		      			_node:release()
						if self.nodePlayer[pos]:getChildByName(self.urlName[pos]) and self.nodePlayer[pos] then self.nodePlayer[pos]:getChildByName(self.urlName[pos]):removeFromParent() end
						if gt.addNode(self.nodePlayer[pos],self.m_UserHead[pos].head) then 
							self.m_UserHead[pos].head:setName(self.urlName[pos])
							self.m_UserHead[pos].head:setPosition(icon:getPositionX(),icon:getPositionY())
							self.m_UserHead[pos].head:setLocalZOrder(7)
						end
					end
		        end
			   	
			    gt.downloadImage(url,callback)	
			  	
			end

	  	end

	end
	log("addplayer______________________")

end

--显示聊天
function sjScene:ShowUserChat(viewid ,message,msg)
	if message and #message > 0 then
		gt.log("message=================")
		gt.dump(message)
		--self.m_GameChat:showGameChat(false) --设置聊天不可见，要显示私有房的邀请按钮（如果是房卡模式）
		--取消上次
		if self.m_UserChat[viewid] then
			self.m_UserChat[viewid]:stopAllActions()
			self.m_UserChat[viewid]:removeFromParent()
			self.m_UserChat[viewid] = nil
		end

		if msg then
			-- local _tpye = 10 - msg.kId + 1
			local _tpye = msg.kId
			gt.log("_toye_____message",_tpye)
				
			if self.Player[viewid].sex == 1 then 
				self:PlaySound("sj_sound/chat/".._tpye..".mp3")
			else
				self:PlaySound("sj_sound/chat/".._tpye..".mp3")
			end
		end

		--创建label
		local limWidth = 20*12
		local labCountLength = cc.Label:createWithSystemFont(message,"Arial", 18)  
		if labCountLength:getContentSize().width > limWidth then
			self.m_UserChat[viewid] = cc.Label:createWithSystemFont(message,"Arial", 18, cc.size(limWidth, 0))
		else
			self.m_UserChat[viewid] = cc.Label:createWithSystemFont(message,"Arial", 18)
		end
		if self.m_UserChat[viewid] then
			self.m_UserChat[viewid]:setColor(cc.c3b(51,51,51))
		end
		self.m_UserChat[viewid]:addTo(self._node)

		gt.log("viewid==============",viewid)
		local offsetX = 25
		if viewid == 4 then
			offsetX = -20
		end

		if viewid > gt.MY_VIEWID then 

				self.m_UserChat[viewid]:move(ptChat[viewid].x + offsetX,  ptChat[viewid].y)
					:setAnchorPoint( cc.p(1, 0.5) )
					:setLocalZOrder(1002)

				
		else
				self.m_UserChat[viewid]:move(ptChat[viewid].x + offsetX,  ptChat[viewid].y)
					:setAnchorPoint( cc.p(0, 0.5) )
					:setLocalZOrder(1002)
		end
		--改变气泡大小
		-- self.m_UserChatView[viewid]:setContentSize(self.m_UserChat[viewid]:getContentSize().width + 27, self.m_UserChat[viewid]:getContentSize().height + 20)
		self.m_UserChatView[viewid]:setContentSize(self.m_UserChat[viewid]:getContentSize().width + 28, self.m_UserChat[viewid]:getContentSize().height + 10)
			:setVisible(true)
		--动作
		self.m_UserChat[viewid]:runAction(cc.Sequence:create(
						cc.DelayTime:create(3),
						cc.CallFunc:create(function()
							self.m_UserChatView[viewid]:setVisible(false)
							self.m_UserChat[viewid]:removeFromParent()
							self.m_UserChat[viewid]=nil
						end)
				))
	end
end


function sjScene:onRcvChatMsg(msgTbl)
	gt.log("收到聊天消息")
	--dump(msgTbl)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("images/EmotionOut.plist")
	if msgTbl.kType == 5 then -- 互动动画类型
		
	local sendRoomPlayer = self.Player[self:getTableId(msgTbl.kPos)]
	-- sendRoomPlayer.displaySeatIdx = self:getTableId(msgTbl.kPos) 


	local receiveRoomPlayer = nil  --发送互动的玩家
		-- local temp1 = 1
		-- local temp2 = 1
		sendRoomPlayer.displaySeatIdx = self:getTableId(msgTbl.kPos)

  		table.foreach(self.Player, function(i, v)
  			if v.id == tonumber(msgTbl.kUserId) then
  				-- sendRoomPlayer.displaySeatIdx = i
  				sendRoomPlayer.displaySeatIdx = i
  				-- gt.log("sendRoomPlayer.displaySeatIdx====================1111111",sendRoomPlayer.displaySeatIdx)
  			end
  			if v.id == tonumber(msgTbl.kMsg) then
				receiveRoomPlayer = v
				receiveRoomPlayer.displaySeatIdx = i
  				return true
  			end
  		end)

  		if not receiveRoomPlayer.displaySeatIdx then
  			return
  		end
  		if not sendRoomPlayer.displaySeatIdx then
  			return
  		end
		-- sendRoomPlayer.temp1 = temp1
		-- receiveRoomPlayer.temp2 = temp2
  -- 		gt.log("sendRoomPlayer.displaySeatIdx=", sendRoomPlayer.temp1)
		-- gt.log("  receiveRoomPlayer.displaySeatIdx=" ,receiveRoomPlayer.temp2)

		local aniNames = {{"hudong1/hua01.png", "hudong1.csb", "common/hudong1"},
		{"hudong2/zuanshi01.png", "hudong2.csb", "common/hudong2"},
		{"hudong3/kiss01.png", "hudong3.csb", "common/hudong3"},
		{"hudong5/jinbi01.png", "hudong5.csb", "common/hudong5"}}

		gt.dump(sendRoomPlayer)
		gt.dump(receiveRoomPlayer)


		-- local sendPlayerNode = self:findNodeByName("player_" .. sendRoomPlayer.temp1)
		-- local receivePlayerNode = self:findNodeByName("player_" .. receiveRoomPlayer.temp2)
		local sendPlayerNode = self:findNodeByName("biaoqing_" .. sendRoomPlayer.displaySeatIdx)
		local receivePlayerNode = self:findNodeByName("biaoqing_" .. receiveRoomPlayer.displaySeatIdx)
		receivePlayerNode:setVisible(true)
		local sendNodePos = cc.p(sendPlayerNode:getPositionX(),sendPlayerNode:getPositionY())
		local receiveNodePos = cc.p(receivePlayerNode:getPositionX(),receivePlayerNode:getPositionY())
		gt.dump(gt.playerData)
		if sendRoomPlayer.id == gt.playerData.uid then  --发送者为自己
		
			if receiveRoomPlayer.id ~= gt.playerData.uid then
			
				local feiSpr = cc.Sprite:create("animation/"..aniNames[msgTbl.kId][1])
				if  msgTbl.kId == 4 then 
				feiSpr:setScale(0.7)
				end
				local completeFunc = cc.CallFunc:create(function()
						feiSpr:stopAllActions()
						feiSpr:removeFromParent(true)
						
						local boNode, boAni = gt.createCSAnimation("animation/"..aniNames[msgTbl.kId][2])

						local num = 0 
						if  msgTbl.kId == 2 then 
							num = 10
						end
						if  msgTbl.kId == 4 then 
						boNode:setScale(0.7)
						end

						gt.log("msgTbl.kId____________",msgTbl.kId)

						
						boNode:setPosition(cc.p(receiveNodePos.x+num, receiveNodePos.y))
						self:addChild(boNode, 1000)
						boAni:gotoFrameAndPlay(0, false)
						if aniNames[msgTbl.kId][3] then
							gt.soundEngine:playEffect(aniNames[msgTbl.kId][3], false, true)
						end
						boAni:setFrameEventCallFunc(function(frameEventName)
						   	local name = frameEventName:getEvent()
						   	gt.log("name======...............",name)
							if name == "_end" then
							   	boNode:stopAllActions()
							   	boNode:removeFromParent()
						   	end
						end)
						-- boNode:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function(sender)
						-- 	sender:stopAllActions()
						-- 	sender:removeFromParent(true)
						-- end)))
					end)
				local time = 0.8
				if receiveRoomPlayer.displaySeatIdx == 3 then
					time = 0.3
				end
				-- local moveAni = cc.MoveTo:create(time, cc.p(receiveNodePos.x+x, receiveNodePos.y+y))
				local moveAni = cc.MoveTo:create(time, cc.p(receiveNodePos.x, receiveNodePos.y))

				

				feiSpr:runAction(cc.Sequence:create(moveAni, completeFunc))
				-- feiAni:gotoFrameAndPlay(0, true)
				self:addChild(feiSpr, 1000)
				-- feiSpr:setPosition(cc.p(sendNodePos.x+x, sendNodePos.y))

				feiSpr:setPosition(cc.p(sendNodePos.x, sendNodePos.y))
			end
			
		else
		if receiveRoomPlayer.id == gt.playerData.uid then --接受者方才播放
			-- local btnSender = self:findNodeByName("Txt_ChatSender")
			-- gt.log("sendRoomPlayer.name===",sendRoomPlayer.name)
			-- gt.dump(sendRoomPlayer)
			self.btnSender:setText("\"".. sendRoomPlayer.name.."\"馈赠给你的表情")
			self.btnSender:setVisible(true)
			local playingNode, playingAni = gt.createCSAnimation("animation/"..aniNames[msgTbl.kId][2])
			playingNode:setScale(2)
			if msgTbl.kId == 4 then 
				playingNode:setScale(1.3)
			end
			self:addChild(playingNode, 1000)
			playingNode:setPosition(gt.winCenter)
			playingAni:gotoFrameAndPlay(0, false)
			if aniNames[msgTbl.kId][3] then
				gt.soundEngine:playEffect(aniNames[msgTbl.kId][3], false, true)
			end

			self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function(sender)
				self.btnSender:setVisible(false)
			end)))
			playingAni:setFrameEventCallFunc(function(frameEventName)
			   	local name = frameEventName:getEvent()
			   	gt.log("name======...............",name)
				if name == "_end" then
				   	playingNode:stopAllActions()
				   	playingNode:removeFromParent()
			   	end
			end)

			-- playingNode:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function(sender)
			-- 	sender:stopAllActions()
			-- 	sender:removeFromParent(true)
			-- 	self.btnSender:setVisible(false)
			-- end)))
		else
			local feiSpr = cc.Sprite:create("animation/"..aniNames[msgTbl.kId][1])
			if  msgTbl.kId == 4 then 
				feiSpr:setScale(0.7)
				end
				local completeFunc = cc.CallFunc:create(function()
						feiSpr:stopAllActions()
						feiSpr:removeFromParent(true)
						
						local boNode, boAni = gt.createCSAnimation("animation/"..aniNames[msgTbl.kId][2])
						-- boNode:setPosition(cc.p(receiveNodePos.x+x, receiveNodePos.y+y))

						local num = 0 
						if  msgTbl.kId == 2 then 
							num = 10
						end
						if msgTbl.kId == 4 then 
							boNode:setScale(0.7)
						end

						boNode:setPosition(cc.p(receiveNodePos.x+num, receiveNodePos.y))
						self:addChild(boNode, 1000)
						boAni:gotoFrameAndPlay(0, false)
						if aniNames[msgTbl.kId][3] then
							gt.soundEngine:playEffect(aniNames[msgTbl.kId][3], false, true)
						end
						-- boNode:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function(sender)
						-- 	sender:stopAllActions()
						-- 	sender:removeFromParent(true)
						-- end)))
						boAni:setFrameEventCallFunc(function(frameEventName)
						   	local name = frameEventName:getEvent()
						   	gt.log("name======...............",name)
							if name == "_end" then
							   	boNode:stopAllActions()
							   	boNode:removeFromParent()
						   	end
						end)
					end)
				local time = 0.8
				if receiveRoomPlayer.displaySeatIdx == 3 then
					time = 0.3
				end
				
				-- local moveAni = cc.MoveTo:create(time, cc.p(receiveNodePos.x+x, receiveNodePos.y+y))
				local moveAni = cc.MoveTo:create(time, cc.p(receiveNodePos.x, receiveNodePos.y))
				feiSpr:runAction(cc.Sequence:create(moveAni, completeFunc))
				-- feiAni:gotoFrameAndPlay(0, true)
				self:addChild(feiSpr, 1000)
				-- feiSpr:setPosition(cc.p(sendNodePos.x+x, sendNodePos.y))
				feiSpr:setPosition(cc.p(sendNodePos.x, sendNodePos.y))
		end

	end
	elseif msgTbl.kType == 4 then
		--语音
		
		-- gt.log("暂停音乐 222222")
		-- require("cjson")

		-- local videoTime = 0
		-- local num1,num2 = string.find(msgTbl.kMusicUrl, "\\")
		-- if not num2 or num2 == nil then
		-- 	Toast.showToast(self, "语音文件错误", 2)
		-- 	return
		-- end
		-- local curUrl = string.sub(msgTbl.kMusicUrl,1,num2-1)
		-- videoTime = string.sub(msgTbl.kMusicUrl,num2+1)
		-- gt.log("the play voide url is .." , curUrl)
		-- gt.log("the play voide videoTime is .." , videoTime)



		-- self:getLuaBridge()
		-- if gt.isIOSPlatform() then
		-- 	local ok = self.luaBridge.callStaticMethod("AppController", "playVoice", {voiceUrl = curUrl})
		-- 	-- self:ShowUserChat1(self:getTableId(msgTbl.kPos),videoTime)
		-- elseif gt.isAndroidPlatform() then
		
		-- 	local ok = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "playVoice", {curUrl}, "(Ljava/lang/String;)V")
		-- 	-- self:ShowUserChat1(self:getTableId(msgTbl.kPos),videoTime)
		-- end
		self:startVoiceSchedule(msgTbl)
		
	else
		local chatBgNode = self.nodePlayer[self:getTableId(msgTbl.kPos)]
		local _node = self:findNodeByName("player_"..self:getTableId(msgTbl.kPos))
		
		local chatBgNode1 = self:findNodeByName("icon",_node)

		
	
		if msgTbl.kType == gt.ChatType.FIX_MSG then
			--emojiImg:setVisible(false)
			self:ShowUserChat(self:getTableId(msgTbl.kPos),gt.getLocationString("LTKey_0000" .. msgTbl.kId),msgTbl)
		
		elseif msgTbl.kType == gt.ChatType.INPUT_MSG then
		
			self:ShowUserChat(self:getTableId(msgTbl.kPos),msgTbl.kMsg)
		elseif msgTbl.kType == gt.ChatType.EMOJI then
			gt.log("播放动画表情 =========== ")
			--chatBgImg:setVisible(false)

			if self.animationNode then
				chatBgNode:removeChild(self.animationNode)
			end
			local picStr = string.sub(msgTbl.kMsg,1,10)
			gt.log("EmotionName 111111:" .. picStr)
			if picStr == "biaoqing1." then
				picStr = "biaoqing01"
			elseif picStr == "biaoqing2." then
				picStr = "biaoqing02"
			elseif picStr == "biaoqing3." then
				picStr = "biaoqing03"
			elseif picStr == "biaoqing4." then
				picStr = "biaoqing04"
			elseif picStr == "biaoqing5." then
				picStr = "biaoqing05"
			elseif picStr == "biaoqing6." then
				picStr = "biaoqing06"
			elseif picStr == "biaoqing7." then
				picStr = "biaoqing07"
			elseif picStr == "biaoqing8." then
				picStr = "biaoqing08"
			elseif picStr == "biaoqing9." then
				picStr = "biaoqing09"
			end
			local animationStr = "res/animation/biaoqing/".. picStr .. ".csb"
			gt.log("animationStr===",animationStr)
			local animationNode, animationAction = gt.createCSAnimation(animationStr)
			animationAction:play("run", true)
			self.animationNode = animationNode
			self.animationAction = animationAction
			
			local chat_head_action = self:findNodeByName("chat_head_action_" .. self:getTableId(msgTbl.kPos))
			chat_head_action:stopAllActions()
			chat_head_action:removeAllChildren()
			gt.addNode(chat_head_action,animationNode)
			local chatBgNode_delayTime = cc.DelayTime:create(3)
			local chatBgNode_callFunc = cc.CallFunc:create(function(sender)
				chat_head_action:stopAllActions()
				chat_head_action:removeAllChildren()
			end)
			local chatBgNode_Sequence = cc.Sequence:create(chatBgNode_delayTime,chatBgNode_callFunc)
			chat_head_action:runAction(chatBgNode_Sequence)



			-- local animationStr = "res/animation/biaoqing/"..picStr.."/".. picStr .. ".csb"
			-- local animationStr = "res/animation/biaoqing/".. picStr .. ".csb"
			-- local animationNode, animationAction = gt.createCSAnimation(animationStr)
			-- animationAction:play("run", false)
			-- local icon = self.nodePlayer[self:getTableId(msgTbl.kPos)]:getChildByName("icon")
			-- animationNode:setPosition(cc.p(icon:getPositionX(),icon:getPositionY()))
			-- self.animationNode = animationNode
			-- self.animationAction = animationAction
			
			-- animationNode:setLocalZOrder(21)
			-- if chatBgNode:getChildByName("__BIAOQING___") then chatBgNode:getChildByName("__BIAOQING___"):removeFromParent() end
			-- chatBgNode:addChild(animationNode)
			-- animationNode:setName("__BIAOQING___")
			-- local chatBgNode_delayTime = cc.DelayTime:create(3)
			-- local chatBgNode_callFunc = cc.CallFunc:create(function(sender)
			-- 	if chatBgNode:getChildByName("__BIAOQING___") then chatBgNode:getChildByName("__BIAOQING___"):removeFromParent() end
			-- 	display.removeSpriteFrames("biaoqingbao/biaoqing.plist","biaoqingbao/biaoqing.png")
			-- end)
			-- local chatBgNode_Sequence = cc.Sequence:create(chatBgNode_delayTime, 
			-- 											 chatBgNode_callFunc)
			-- chatBgNode1:runAction(chatBgNode_Sequence)
		elseif msgTbl.kType == gt.ChatType.VOICE_MSG then
		end

	
	end
end

--房间人数  
function sjScene:get_num()
	local idx = 0
	for i = 1 , gt.GAME_PLAYER do
		if self.player_num[i] then
			idx = idx + 1
		end
	end

	return (4-idx)
end

function sjScene:removePlayer(args)

	gt.dumplog(args)
	if args and args.kPos ~= 21 and args.kPos then 
		self.nodePlayer[self:getTableId(args.kPos)]:setVisible(false)
		self.player_num[self:getTableId(args.kPos)]	= false
		self.m_flagReady[self:getTableId(args.kPos)]:setVisible(false)
		
		if args.kPos == self.UsePos then self:onExitRoom("房间已解散！") end
	end
end



function sjScene:renovate(msg)
	gt.dumplog(msg)
	
	gt.log("刷新局数______________")
	

	if msg.kCurCircle > 0 then self.m_btnInvite:setVisible(false)  self.gameBegin = true self.ready:setPositionX(self.m_btnInvite:getPositionX()) end
	self.result_jushi = msg.kCurCircle.." / "..msg.kCurMaxCircle

	local node = self:findNodeByName("room_info")
	self.m_atlasCount = self:findNodeByName("t2",node)

	if self.m_atlasCount and msg.kCurCircle and msg.kCurMaxCircle then self.m_atlasCount:setString(self.result_jushi) end

end


function sjScene:off_line_data_sj(m)
	
	log("off_________________________",self.UsePos)
	
	self:stopAllActions()

	TIME = m.kOutTime
	self:findNodeByName("qingzhuangda"):setVisible(false)
	self:findNodeByName("duifangda"):setVisible(false)
	self:findNodeByName("wofangda"):setVisible(false)
	

	self._disrupt:stopAllActions()
	self._disrupt:getChildByName( "Node" ):stopAllActions()
	self._disrupt:setVisible(false)
	self.tong:setVisible(false)
	self:ActionText(false)
	self:action_room_info(true)
	self.fz:stopAllActions()
	self.fz:setVisible(false)
	self.po_node:stopAllActions()
	self.po_node:setVisible(false)
	self:ActionText5(false)
	self.maidi:setVisible(false)
	self.maidi:stopAllActions()
	self.liangzhu:setVisible(false)

	self.max_card = {} 

	for i = 1 , gt.GAME_PLAYER do 
		self.nodePlayer[i]:getChildByName("icon1"):setVisible(false)
		self["lz"..i]:setVisible(i == self:getTableId( m.kSelectCardPos))
		self["lz"..i]:stopAllActions()
		for x = 1 , 4 do
			self["lz"..i]:getChildByName("x"..x):setVisible(false)
		end
		self.nodePlayer[i]:stopAllActions()
		self.nodePlayer[i]:setScale(0.65)
		self.nodePlayer[i]:setPosition(cc.p(self.buf_posX[i],self.buf_posY[i]) )
		gt.log("m,,,,,,,,",self.data.kPlaytype[3])
		if self.data.kPlaytype[3] == 1 and i ~= gt.MY_VIEWID then 
			self.nodePlayer[i]:getChildByName("icon1"):setVisible(true)
			self.nodePlayer[i]:getChildByName("infobg"):setVisible(false)
			gt.log("i_________________________")
		end
	end
	self.fz:setVisible(false)
	self.fz:stopAllActions()

	self.m_btnInvite:setVisible(false)
	self:ActionText5(false)
	self._zhu = m.kCurrGrade
	gt._changzhus = self._zhu

	self.kSelectCard = m.kSelectCard
	gt.kSelectCard = m.kSelectCard



	self.po_runs = m.kGetTotleScore < 80 

	

	for i = 1 , gt.GAME_PLAYER do 
		self.m_flagReady[i]:setVisible(false)
		self.m_UserHead[i].banker:stopAllActions()
		self.m_UserHead[i].banker:setVisible(false)
		if m.kZhuangPos  ~= 4 then 
			self.banker_pos = m.kZhuangPos
			self.m_UserHead[i].banker:setVisible(i == self:getTableId(m.kZhuangPos))
			local z = cc.CSLoader:createTimeline("runAction/banker_run.csb")	
			self.m_UserHead[i].banker:runAction(z)
			z:gotoFrameAndPlay(0,false) 

		end
	end
	
	self:game_info(m.kGradeCard[ self.UsePos>1 and self.UsePos-2+1 or self.UsePos+1 ] ,m.kGradeCard[ 1 - (self.UsePos>1 and self.UsePos-2 or self.UsePos) + 1 ],m.kGetTotleScore)

	local buf = {}
	self.m_cardControl:setVisible(true)
	for i = 1, m.kHandCardsCount do 
		table.insert(buf,m.kHandCards[i])
	end

	gt.log("buf________________")

	gt.dump(buf)

	buf = yl.add_switch_card(buf)
	self.my_card = buf
	gt.dump(buf)
	self.m_tabNodeCards[gt.MY_VIEWID]:removeAllCards()
	self.m_tabNodeCards[gt.MY_VIEWID]:updatesjCardNode(buf, true, false)
	self.m_tabNodeCards[gt.MY_VIEWID]:add_star()
	

	local func = function() 

		if m.kSelectCard ~= 64 then 
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard)
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard+100)
			
		end
		if self.data.kPlaytype[4] == 1  then 
	   		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(2,true)
	   	end


	    for i = 1 , #buf do
	    	if GamesjLogic:GetCardValue(buf[i]) == 14 then 
	    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(14,true)
	    	end
	    	if GamesjLogic:GetCardValue(buf[i]) == 15 then 
	    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(15,true)
	    	end
	    	if self._zhu == GamesjLogic:GetCardValue(buf[i]) then 
	    		self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self._zhu,true)
	    	end
	    end

	    self.m_tabNodeCards[gt.MY_VIEWID]:reSortCards()

	end
	func()
    self.m_outCardsControl:removeAllChildren()


    for i = 1 , 25 do
		self._node:removeChildByName("SCORE_"..i)
	end


    for i = 1 , m.kScoreCardsCount do -- 10 张
								
		if  i <= 10 then
			if i == 1 then 
				self.nodes = self:findNodeByName("score_card1")
				self.nodes:setVisible(true)
				self.nodes:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
			else
				local node = self.nodes:clone()
				if gt.addNode(self._node,node) then
					node:setName("SCORE_"..i)
					node:setPosition(cc.p(self.nodes:getPositionX() + (i - 1) * 31 ,self.nodes:getPositionY()))
					node:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
				end
			end
		elseif i > 10 and i <= 20 then 
			if i == 11 then 
				self.nodes = self:findNodeByName("score_card2")
				self.nodes:setVisible(true)
				self.nodes:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
			else
				local node = self.nodes:clone()
				if gt.addNode(self._node,node) then
					node:setName("SCORE_"..i)
					node:setPosition(cc.p(self.nodes:getPositionX() + (i - 11) * 31 ,self.nodes:getPositionY()))
					node:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
				end
			end
		else
			if i == 21 then 
				self.nodes = self:findNodeByName("score_card3")
				self.nodes:setVisible(true)
				self.nodes:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
			else
				local node = self.nodes:clone()
				if gt.addNode(self._node,node) then
					node:setName("SCORE_"..i)
					node:setPosition(cc.p(self.nodes:getPositionX() + (i - 21) * 31 ,self.nodes:getPositionY()))
					node:loadTexture("poker_ddz/"..gt.tonumber(m.kScoreCards[i])..".png")
				end
			end
		end
	end



	local fun_zhu = function(bool)

			local func = function()
				if GamesjLogic:GetCardColor(m.kSelectCard) == 64 then 
					return 1 
				elseif GamesjLogic:GetCardColor(m.kSelectCard) == 0 then 
					return 5
				elseif GamesjLogic:GetCardColor(m.kSelectCard) == 16 then 
					return 4
				elseif GamesjLogic:GetCardColor(m.kSelectCard) == 32 then 
					return 3
				elseif GamesjLogic:GetCardColor(m.kSelectCard) == 48 then 
					return 2
				end
				return nil
			end
			local j = func()
			gt.log("j..........",j)
			--GamesjLogic:GetCardLogicValue( m.kSelectZhu ) == 17
			
				if j and j ~= 1 then 
					if m.kSelectCardCount ~= 0 then 
						for i = 1 , gt.GAME_PLAYER do 
							self["lz"..i]:setVisible(i == self:getTableId(m.kSelectCardPos))
							if i == self:getTableId(m.kSelectCardPos) then 
								if m.kSelectCardCount == 1 then 
									gt.log("1_________________",i,"sjScene/h"..tostring(j-1)..".png")
									self["lz"..i]:getChildByName("x"..4):setVisible(true)
									self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h"..tostring(j-1)..".png")
									self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
									self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d"..tostring(j-1)..".png")
								elseif m.kSelectCardCount == 2 then 
									gt.log("1_________________22222222",i,"sjScene/h"..tostring(j-1)..".png")
									self["lz"..i]:getChildByName("x"..3):setVisible(true)
									self["lz"..i]:getChildByName("x"..3):loadTexture("sjScene/h"..tostring(j-1)..".png")
									self["lz"..i]:getChildByName("x"..4):setVisible(true)
									self["lz"..i]:getChildByName("x"..4):loadTexture("sjScene/h"..tostring(j-1)..".png")
									self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
									self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d"..tostring(j-1)..".png")
								end

								if bool then 
									for h= 1 , m.kSelectCardCount do 
										self["lz"..i]:getChildByName("x"..h):setVisible(true)
										self["lz"..i]:getChildByName("x"..h):loadTexture("poker_sj/"..gt.tonumber(m.kSelectCard)..".png")
									end
								end
							end
						end
					end
				else
					if m.kSelectCardCount == 2 and m.kSelectCardValue ~= 0 then 
						for i = 1 , gt.GAME_PLAYER do 
							self["lz"..i]:setVisible(i == self:getTableId(m.kSelectCardPos))

							if i == self:getTableId(m.kSelectCardPos) then 
								self["lz"..i]:getChildByName("x"..4):setVisible(true)
								self["lz"..i]:getChildByName("x"..4):loadTexture(m.kSelectCardValue == 78 and "sjScene/h0.png" or "sjScene/h00.png")
								self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
								self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture(m.kSelectCardValue == 78 and "sjScene/d5.png" or "sjScene/d5.png")
								gt.log("c______________")
							end
							if bool then 
								for h= 1 , m.kSelectCardCount do 
									self["lz"..i]:getChildByName("x"..h):setVisible(true)
									self["lz"..i]:getChildByName("x"..h):loadTexture("poker_sj/"..gt.tonumber(m.kSelectCard)..".png")
								end
							end
						end
					end
				end
			if m.kSelectCardCount == 0 then
				self:findNodeByName("game_info"):getChildByName("Image_4"):setVisible(true)
				self:findNodeByName("game_info"):getChildByName("Image_4"):loadTexture("sjScene/d6.png")
			end

	end




	if m.kStatus == 1 or m.kStatus == 2 or m.kStatus == 3 then  -- 亮主

		self.liangzhu:setVisible(true)
		self.m_tabNodeCards[gt.MY_VIEWID]:bDispatching()
		self.m_tabNodeCards[gt.MY_VIEWID]:add_star()

		-- if m.kSelectCardCount == 1 and GamesjLogic:GetCardLogicValue(m.kSelectCard) == 17 then 
		-- 	self.liangzhu:getChildByName("l1"):setVisible(false)
			
		-- else
		-- 	self._action = true
		-- 	self.liangzhu:getChildByName("l1"):setVisible(false)
		-- 	--self:PlaySound("sj_sound/fwz.mp3")
		-- end

		
		self._action = m.kSelectCardPos == self.UsePos
		

		if m.kSelectCardCount == 2 then 
			for i =2 , 5 do
				self.liangzhu:getChildByName("l"..i):setVisible(false)
			end
			if GamesjLogic:GetCardLogicValue( m.kSelectCard ) == 16 then 
				if not self.wamg2 then 
					self.liangzhu:getChildByName("l1"):setVisible(false)
					self._return1 = true
				end
				
			elseif GamesjLogic:GetCardLogicValue( m.kSelectCard ) == 17 then 
				
				self.liangzhu:getChildByName("l1"):setVisible(false)
				self._return = true
			else
				self._return2 = true
			end
			self.liangzhu:getChildByName("tx_pian"):setColor(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
			self.liangzhu:getChildByName("tx_pian"):enableGlow(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			self.liangzhu:getChildByName("tx_hua"):setColor(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
			self.liangzhu:getChildByName("tx_hua"):enableGlow(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			self.liangzhu:getChildByName("tx_hong"):setColor(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
			self.liangzhu:getChildByName("tx_hong"):enableGlow(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			self.liangzhu:getChildByName("tx_hei"):setColor(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
			self.liangzhu:getChildByName("tx_hei"):enableGlow(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			if m.kSelectCard ~= 64 then 
				self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard)
				self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard+100)
			else
				self.m_tabNodeCards[gt.MY_VIEWID]:add_star(self._zhu,true)
			end
			
		elseif m.kSelectCardCount == 1 then 
			gt.log("self.pian",self.pian,self.hua,self.hong,self.hei)
			if self.pian == 1 then 
				self.liangzhu:getChildByName("l5"):setVisible(false)
				self.liangzhu:getChildByName("tx_pian"):setColor(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
				self.liangzhu:getChildByName("tx_pian"):enableGlow(self.liangzhu:getChildByName("l5"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			end
			if self.hua == 1 then 
				self.liangzhu:getChildByName("l4"):setVisible(false)
				self.liangzhu:getChildByName("tx_hua"):setColor(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
				self.liangzhu:getChildByName("tx_hua"):enableGlow(self.liangzhu:getChildByName("l4"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			end
			if self.hong == 1 then 
				
				gt.log("cae______________")
				self.liangzhu:getChildByName("l3"):setVisible(false)
				self.liangzhu:getChildByName("tx_hong"):setColor(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
				self.liangzhu:getChildByName("tx_hong"):enableGlow(self.liangzhu:getChildByName("l3"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			end
			if self.hei == 1  then 
				
				self.liangzhu:getChildByName("l2"):setVisible(false)
				self.liangzhu:getChildByName("tx_hei"):setColor(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(255,255,255) or cc.c3b(59,59,59))
				self.liangzhu:getChildByName("tx_hei"):enableGlow(self.liangzhu:getChildByName("l2"):isVisible() and cc.c3b(102,45,26) or cc.c3b(135,135,135))
			end
			self._return5 = true
			self.m_tabNodeCards[gt.MY_VIEWID]:add_star(m.kSelectCard)
			
		end


		self.m_tabNodeCards[gt.MY_VIEWID]:bDispatching()
		
		
		fun_zhu(true)

	elseif m.kStatus == 4 then -- 埋底

		self.fz:stopAllActions()
		self.fz:setVisible(false)
		self.liangzhu:setVisible(false)
		if  m.kHandCardsCount == 25 then 
			self:ActionText5(true,m.kOutTime)
		else
			local buf = {}
			for i = 1, m.kHandCardsCount do 
				table.insert(buf,m.kHandCards[i])
			end
			buf = yl.add_switch_card(buf)

			buf = GamesjLogic:SortCardList(buf,#buf,true)
			self._mai_di:getChildByTag(1):init(buf,self.UsePos,10,m.kSelectCard)
			self._mai_di:setVisible(true)

		end
		--self:show_log("z:"..m.kZhuangPos.." u:"..self.UsePos)
		if m.kZhuangPos ~= self.UsePos then 


			self.maidi:setVisible(false)
			self.maidi:stopAllActions()
			self.maidi:setPosition(self.m_flagReady[self:getTableId( m.kZhuangPos ) ]:getPosition())
			self.___node1 = cc.CSLoader:createTimeline("runAction/mai_run.csb")	
	        self.maidi:runAction(self.___node1)
	        self.maidi:setVisible(true)
	        self.___node1:gotoFrameAndPlay(0,true) 
	    end


	    fun_zhu(false)

	else -- 出牌
		
		fun_zhu(false)
		self.liangzhu:setVisible(false)

		--self:show_log("kOutCardPos:"..m.kOutCardPos..",UsePos:"..self.UsePos)
		self.push_card:setVisible(m.kOutCardPos == self.UsePos)
	    self:gameClock(m.kOutCardPos)
	    self.fz:stopAllActions()
		self.fz:setVisible(false)


	   	local koutCard = {}

	   	table.insert(koutCard,m.kOutCards0)
	   	table.insert(koutCard,m.kOutCards1)
	   	table.insert(koutCard,m.kOutCards2)
	   	table.insert(koutCard,m.kOutCards3)

	    for i = 1 , gt.GAME_PLAYER do
	    	local card = {}
	    	local vec = nil
	    	gt.log("self:getTableId(i-1)",self:getTableId(i-1))
	    	for j = 1, m.kOutCardsCount[i] do
			    table.insert(card,koutCard[i][j])
			end
			if (i-1) == self.UsePos then 
				
				local handCards = self.m_tabNodeCards[gt.MY_VIEWID]:getHandCards()
        		local count = #handCards
			    for x = 1, m.kOutCardsCount[i] do
					handCards[count + x] = card[x]
				end
				card = yl.add_switch_card(card)
				handCards = yl.add_switch_card(handCards)

				gt.dump(card)
				gt.dump(handCards)

				self.m_tabNodeCards[gt.MY_VIEWID]:addCards(card, handCards,true)

				func()
				vec = self.m_tabNodeCards[self:getTableId(i-1)]:outCard(card,true)
				self.m_tabNodeCards[gt.MY_VIEWID]:reSortCards()
				
			end
			if m.kFirstOutPos + 1 == i then  
				self.m_tabCurrentCards = card
				if (i-1) ~= self.UsePos then 
					
					self.m_tabNodeCards[gt.MY_VIEWID]:select_card_effect(card)
				end
			end
			gt.log("outcard_______",card)
			self:outCardEffect(self:getTableId(i-1), card, vec ,self:getTableId( m.kCurrBig),m.kFirstOutPos + 1 == i)
	    end



	end

end


function sjScene:onNodeEvent(eventName)
	log("enter_______",eventName)
	if "enter" == eventName then
		
	elseif "exit" == eventName or "cleanup" == eventName then 

		self:remove_Self()	

	end
end


function sjScene:remove_Self()
	
	for i =1 , #gt.poker_node_sj do
        cc.Director:getInstance():getTextureCache():removeTextureForKey(gt.poker_node_sj[i]) 
        
    end
    if self._delaytime1 then   _scheduler:unscheduleScriptEntry(self._delaytime1) self._delaytime1  = nil end
    self:KillGameClock()
    self:ActionText(false)
    if 	self.__time then _scheduler:unscheduleScriptEntry(self.__time) self.__time = nil end	
    if self._delaytime then   _scheduler:unscheduleScriptEntry(self._delaytime) self._delaytime  = nil end
    self:ActionText5(false)

end

return sjScene