local gt  = cc.exports.gt


local Activity_node = class("Activity_node",function()
 	return gt.createMaskLayer()
 end)


function Activity_node:ctor(args,str,time)

    local csbNode = cc.CSLoader:createNode("Activity_node.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter.x+28,gt.winCenter.y)
	self:addChild(csbNode)

	local total = gt.seekNodeByName(csbNode,"total")
	local total1 = gt.seekNodeByName(csbNode,"total1")
	local node = gt.seekNodeByName(csbNode, "hongbao_3")
	if str and time then 
		total:setVisible(false)
		total1:setVisible(false)
		node:setVisible(false)
		gt.seekNodeByName(csbNode,"Text_8"):setVisible(true)
		gt.seekNodeByName(csbNode,"Text_1"):setString(time)
		gt.seekNodeByName(csbNode,"Text_2"):setString(str[1])
		gt.seekNodeByName(csbNode,"Text_3"):setString(str[2])
		gt.seekNodeByName(csbNode,"Text_4"):setString(str[3])
	elseif not str and not time then 
		
		gt.seekNodeByName(csbNode,"Text_8"):setVisible(false)
		total:setVisible(true)
		total1:setVisible(true)
		node:setVisible(true)
		local act = cc.CSLoader:createTimeline("Activity_node.csb")
		csbNode:runAction(act)
		act:gotoFrameAndPlay(0,false)
		self._act = act
		act:setFrameEventCallFunc(function(frameEventName)
			local name = frameEventName:getEvent()
			if name == "_end" then
				local action = cc.CSLoader:createTimeline("xingxing.csb")
				gt.seekNodeByName(csbNode,"FileNode_1"):runAction(action)
				action:gotoFrameAndPlay(0,true)
				self.action = action
			end

			end)
		if args.type == 100 then -- 8连输
			total:setString("财神普惠奖，随机奖励")
		elseif args.type == 200 then -- 特殊牌型
			total:setString(args.card_name.."，随机奖励")
		end
		if (args.money_text ~= "" or args.cash_text ~= "" ) and args.coin_text ~= "" then
			gt.seekNodeByName(csbNode,"Text_5"):setString(args.money_text ~= "" and args.money_text or args.cash_text)
			gt.seekNodeByName(csbNode,"Text_6"):setString("+")
			gt.seekNodeByName(csbNode,"Text_7"):setString(args.coin_text)
		else
			if args.money_text == "" then
				gt.seekNodeByName(csbNode,"Text_5"):setString(args.cash_text ~= "" and args.cash_text or args.coin_text)
			else
				gt.seekNodeByName(csbNode,"Text_5"):setString(args.money_text ~= "" and args.money_text or args.coin_text)
			end
		end
	 end

	local Node = gt.seekNodeByName(csbNode,"mao")

	 local action1 = cc.RotateTo:create(1, -10)
	    local action2 = cc.RotateTo:create(1, 10)
		local seqAction = cc.Sequence:create(action1, action2)
		Node:runAction(cc.RepeatForever:create(seqAction))

	


	 local closeBtn = gt.seekNodeByName(csbNode, "close")
		gt.addBtnPressedListener(closeBtn, function()
			Node:stopAllActions()
			gt.seekNodeByName(csbNode,"FileNode_1"):stopAllActions()
			csbNode:stopAllActions()
			self:removeFromParent()
	end)

end

function Activity_node:_exit()




end


return Activity_node