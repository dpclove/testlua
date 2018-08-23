local CompareView  = class("CompareView",function(config)
		local compareView =  display.newLayer(cc.c4b(0, 0, 0, 100))
    return compareView
end)



function CompareView:onExit()
	
end

function CompareView:ctor(node)

	local this = self
	
	

	local function onNodeEvent(event)  
       if "exit" == event then  
            this:onExit()  
        end  
    end  
  
    self:registerScriptHandler(onNodeEvent)  

 	
	self.node = cc.CSLoader:createNode("Node.csb")
	self:addChild(self.node)
	gt._scale(self.node)
	self.node:setPosition(gt.winCenter)


	self.m_UserInfo = {}

	self.action_num = 0 
	self.m_AniCallBack = nil
end


function CompareView:StopCompareCard()



	self.node:stopAllActions()

	self.node:setVisible(false)
end

function CompareView:getaction_num()

	return self.action_num

end

function CompareView:setaction_num(num)

	self.action_num = num or 0 
end

function CompareView:addIcon(node,data)
	if not data then return end
	if node:getChildByName("__ICON__") then  node:getChildByName("__ICON__"):removeFromParent() end
	if type(data) ~= nil and  string.len(data) > 10 then
		local icon = node:getChildByName("icon")
		local iamge = gt.imageNamePath(data)


	  	if iamge then
	  		local _node = display.newSprite("player/icon.png")
			local head = gt.clippingImage(iamge,_node,false)
			node:addChild(head)
			head:setName("__ICON__")
			head:setPosition(icon:getPositionX(),icon:getPositionY())
	  	else
	  		local function callback(args)
	      		if args.done  then
					local _node = display.newSprite("player/icon.png")
					local head = gt.clippingImage(args.image,_node,false)
					node:addChild(head)
					head:setName("__ICON__")
					head:setPosition(icon:getPositionX(),icon:getPositionY())
				end
	        end
		    local url = "http://wx.qlogo.cn/mmopen/fPpvbA8XFDPE6CRQFytD9MFsSibiasf8iaNKibLfpF6It8yvTULbzrKs0O46sMcr4sm6YhY5xHSoE8TUQmSicOicpWcicmbXlBLdkuH/0"
		    url = data
		    gt.downloadImage(url,callback)	
	  	end
	 end


end



function CompareView:CompareCard(firstuser,seconduser,firstcard,secondcard,bfirstwin,callback)

	self.node:setVisible(true)
	self.action_num = self.action_num  + 1
	self.m_AniCallBack = callback


	self.player1 = self.node:getChildByName("player_1")
	self.player2 = self.node:getChildByName("player_2")


	gt.log("ccc_____________________")

	gt.log(firstuser.url)
	gt.log(seconduser.url)




	self.player1:getChildByName("name"):setString(firstuser.name)
	self.player2:getChildByName("name"):setString(seconduser.name)

	self.player1:getChildByName("score"):setString(firstuser.score)
	self.player2:getChildByName("score"):setString(seconduser.score)

	self.player1:getChildByName("poker"):getChildByName("sikai"):setVisible(false)
	self.player2:getChildByName("poker"):getChildByName("sikai"):setVisible(false)
	self.player2:getChildByName("poker"):getChildByName("Image_41"):setVisible(false)
	self.player1:getChildByName("poker"):getChildByName("Image_41"):setVisible(false)

	self.player1:getChildByName("poker"):loadTexture("l1.png")
			self.player2:getChildByName("poker"):loadTexture("r1.png")
			self.player1:getChildByName("iconhui"):setVisible(false)
			self.player2:getChildByName("iconhui"):setVisible(false)

	self.m_bFirstWin = bfirstwin

	if bfirstwin then
	
		self.player1:getChildByName("poker"):getChildByName("sikai"):setVisible(false)
		self.player2:getChildByName("poker"):getChildByName("sikai"):setVisible(true)
		self.node:getChildByName("Image_7"):loadTexture("node/touming.png")
		self.node:getChildByName("Image_5"):loadTexture("node/shandianbaise.png")

	else
		-- self.player2:getChildByName("iconhui"):setVisible(false)
		-- self.player1:getChildByName("iconhui"):setVisible(true)
		self.player2:getChildByName("poker"):getChildByName("sikai"):setVisible(false)
		self.player1:getChildByName("poker"):getChildByName("sikai"):setVisible(true)
		-- self.player1:getChildByName("poker"):loadTexture("r.png")
		-- self.player2:getChildByName("poker"):loadTexture("l1.png")
		self.node:getChildByName("Image_5"):loadTexture("node/touming.png")
		self.node:getChildByName("Image_7"):loadTexture("node/shandianbaise.png")

	end

	local act = cc.CSLoader:createTimeline("Node.csb")

	self.node:runAction(act)
	act:gotoFrameAndPlay(0, false)

	act:setFrameEventCallFunc(function(frameEventName)
		
		local name = frameEventName:getEvent()
		if name == "shandian" then
			callback(name)
		elseif name == "_end" then 
			self.player2:getChildByName("poker"):getChildByName("Image_41"):setVisible(true)
			self.player1:getChildByName("poker"):getChildByName("Image_41"):setVisible(true)
			if bfirstwin then
        		self.player2:getChildByName("poker"):loadTexture("l.png")
				self.player1:getChildByName("poker"):loadTexture("r1.png")
				self.player1:getChildByName("iconhui"):setVisible(false)
				self.player2:getChildByName("iconhui"):setVisible(true)
				self.player1:getChildByName("poker"):getChildByName("Image_41"):loadTexture("node/w_win.png")
				self.player2:getChildByName("poker"):getChildByName("Image_41"):loadTexture("node/w_lost.png")
        	else
			    self.player1:getChildByName("poker"):loadTexture("r.png")
				self.player2:getChildByName("poker"):loadTexture("l1.png")
				self.player2:getChildByName("iconhui"):setVisible(false)
				self.player1:getChildByName("iconhui"):setVisible(true)
				self.player2:getChildByName("poker"):getChildByName("Image_41"):loadTexture("node/w_win.png")
				self.player1:getChildByName("poker"):getChildByName("Image_41"):loadTexture("node/w_lost.png")
        	end
        --	if not bool then 
		    self.node:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
		    	self:setVisible(false)
		    		self.action_num = self.action_num  - 1
		    		callback(name)
		    	

		    end)))
			--else

		--	end
    	end
	end)


	self:addIcon(self.player1,firstuser.url)
	self:addIcon(self.player2,seconduser.url)

end

function CompareView:FlushEnd()
	
	
end


return CompareView