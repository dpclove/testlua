local base = require("client.game.poker.baseView")

local koudi = class("koudi",base)

local _scheduler = gt.scheduler

local GamesjLogic =  gt.include("ddzCard.GamesjLogic")

function koudi:init(m,...)

	

	local run = self:findNodeByName("run")
	local buf = {...}
	self.node_buf = {}
	local nodes = self:findNodeByName("Image_1")
	self._di_pai_node = self:findNodeByName("dipai")
	self._di_pai_node:setVisible(true)
	table.insert(self.node_buf,nodes)
	for  i =1 , 7 do
		local node = nodes:clone()
		if gt.addNode(self:findNodeByName("Panel_1"),node) then 
			node:setPosition(cc.p(nodes:getPositionX()+i*60 , nodes:getPositionY() ))
			table.insert(self.node_buf,node)
		end
	end

	run:stopAllActions()
	run:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()


		self:action(m,buf)

	end)))

end


function koudi:action(m,args)
	--m = yl.switch_card(m)
	local i = 0
	local time = 0
	local times = 0
	local bool = true
	local isrun = false

	if  args[1] == true then 
    	gt.soundEngine:Poker_playEffect("sj_sound/koudi.mp3")
    else
    	gt.soundEngine:Poker_playEffect("sj_sound/banker_b.mp3")
 	end
 	local idx = 0
	if self._delaytime then   _scheduler:unscheduleScriptEntry(self._delaytime) self._delaytime  = nil end

		local move_buf = {}
		self._delaytime = _scheduler:scheduleScriptFunc(function(dt)

			if bool then 
				i = i + 1
				local node = self.node_buf[i]
				if node then 
					local function FlipSpriteCallback()
						node:loadTexture("poker_ddz/"..gt.tonumber(m[i])..".png")
						if GamesjLogic:GetCardValue(m[i]) == 5 or GamesjLogic:GetCardValue(m[i]) == 10 or GamesjLogic:GetCardValue(m[i]) == 13 then 
							table.insert(move_buf,node)
						end
					    local action = CCOrbitCamera:create(0.1, 1, 0, 270, 90, 0, 0)
					    node:runAction(cc.Sequence:create(action, cc.DelayTime:create(0.1) , cc.CallFunc:create(function()
					    		
					    	if i == #self.node_buf then
						    	if  args[1] == true then 
							    	self._di_pai_node:setVisible(false)
							    	local text = self:findNodeByName("timer_kou")
							    	text:setVisible(true)
							    	gt.dump(args,"line____63")
							    	text:getChildByName("AtlasLabel"):setString(args[2])
							    	text:getChildByName("AtlasLabel_0"):setString(args[3])
							    	
							 	end
							 	isrun = true
						    end


					    end)))
					end

				    local action = CCOrbitCamera:create(0.1, 1, 0, 0, 90, 0, 0)
				    node:runAction(cc.Sequence:create(  action, cc.CallFunc:create(FlipSpriteCallback)))

				end
			end

		    if isrun then 
		    	bool = false
		    	if idx == 2 then 
			    	for  x = 1 , #self.node_buf do
			    		if self.node_buf[x] and (GamesjLogic:GetCardValue(m[x]) == 5 or GamesjLogic:GetCardValue(m[x]) == 10 or GamesjLogic:GetCardValue(m[x]) == 13) then 
			    			self.node_buf[x]:runAction(cc.MoveTo:create(0.1,cc.p(self.node_buf[x]:getPositionX(),self.node_buf[x]:getPositionY()+30)))
			    		end
			    	end
			    end
			    idx = idx + 1
		    	time = time+ dt
		    	
		    	if time >= 5 then 
		    		if self._delaytime then   _scheduler:unscheduleScriptEntry(self._delaytime) self._delaytime  = nil end 
		    		gt.dispatchEvent("show_result_min")
		    		self:removeFromParent()
		    		
		    	end
		    end
		    times = times + dt 
		    if times >= 8 then 
		    	if self._delaytime then   _scheduler:unscheduleScriptEntry(self._delaytime) self._delaytime  = nil end 
		    	gt.dispatchEvent("show_result_min")
		    	self:removeFromParent()
		    end
		end,0.2,false)

end

function koudi:enter()

end

function koudi:exit()
	-- for i  = 1 , #self.node_buf do
	-- if self.node_buf[i] and not tolua.isnull(self.node_buf[i]) then 
	-- self.node_buf[i]:stopAllActions()
	-- end
	-- end

	if self._delaytime then   _scheduler:unscheduleScriptEntry(self._delaytime) self._delaytime  = nil end
end

return koudi