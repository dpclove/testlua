
local gt  = cc.exports.gt


local lucky_node = class("lucky_node",function()
 	return gt.createMaskLayer()
 end)

function lucky_node:ctor(data1,scene)

	local csbNode = cc.CSLoader:createNode("lucky_node.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	if scene == "M" then 
		gt.seekNodeByName(csbNode,"luckyCardBg_1"):loadTexture("Activity11-9/luckyCardBg.png")
	elseif scene == "P" then 
		gt.seekNodeByName(csbNode,"luckyCardBg_1"):loadTexture("Activity11-9/addLuckyBg.png")
	end

	local num = data1.total_count
	if data1.type == 1 then -- 大赢家
		if scene == "M" then 
			gt.seekNodeByName(csbNode,"Text"):setString("请在规定时间内，完成"..num.."次大赢家->\n然后您可在好礼->幸运卡中领取红包、话费、金币")
			gt.seekNodeByName(csbNode,"Text_19"):setVisible(false)
			gt.seekNodeByName(csbNode,"Text_20"):setVisible(false)
			gt.seekNodeByName(csbNode,"Text"):setVisible(true)
		elseif scene == "P" then 

			local tmp = data1.total_count - data1.count 
			if tmp > 0 then 
				gt.seekNodeByName(csbNode,"Text"):setVisible(true)
				gt.seekNodeByName(csbNode,"Text_19"):setVisible(false)
				gt.seekNodeByName(csbNode,"Text_20"):setVisible(false)
				gt.seekNodeByName(csbNode,"Text"):setString("大赢家次数+1，还差"..tmp.."次，加油")
				gt.seekNodeByName(csbNode,"luckyCardBg_1"):loadTexture("Activity11-9/addLuckyBg.png")
			else
				gt.seekNodeByName(csbNode,"Text"):setVisible(false)
				gt.seekNodeByName(csbNode,"Text_19"):setVisible(true)
				gt.seekNodeByName(csbNode,"Text_20"):setVisible(true)
				gt.seekNodeByName(csbNode,"Text_19"):setString(num.."次大赢家")
				gt.seekNodeByName(csbNode,"Text_20"):setString("您可在好礼->幸运卡中领取红包、话费、金币")
				gt.seekNodeByName(csbNode,"luckyCardBg_1"):loadTexture("Activity11-9/wancheng.png")
			end
		end
		gt.seekNodeByName(csbNode,"Image_1"):loadTexture("Activity11-9/win.png")
		gt.seekNodeByName(csbNode,"Text_6"):setVisible(false)
		gt.seekNodeByName(csbNode,"Text_3"):setString(num)
		gt.seekNodeByName(csbNode,"Text_3"):setVisible(true)
	elseif data1.type == 2 then -- 打够场次
		if scene == "M" then 
			gt.seekNodeByName(csbNode,"Text_19"):setVisible(false)
			gt.seekNodeByName(csbNode,"Text_20"):setVisible(false)
			gt.seekNodeByName(csbNode,"Text"):setVisible(true)
			gt.seekNodeByName(csbNode,"Text"):setString("请在规定时间内，完成"..num.."次游戏->\n然后您可在好礼->幸运卡中领取红包、话费、金币")
		elseif scene == "P" then 
			local tmp = data1.total_count - data1.count 
			if tmp > 0 then 
				gt.seekNodeByName(csbNode,"Text"):setVisible(true)
				gt.seekNodeByName(csbNode,"Text_19"):setVisible(false)
				gt.seekNodeByName(csbNode,"Text_20"):setVisible(false)
				gt.seekNodeByName(csbNode,"Text"):setString("游戏场次+1，还差"..tmp.."场，加油")
				gt.seekNodeByName(csbNode,"luckyCardBg_1"):loadTexture("Activity11-9/addLuckyBg.png")
			else
				gt.seekNodeByName(csbNode,"Text"):setVisible(false)
				gt.seekNodeByName(csbNode,"Text_19"):setVisible(true)
				gt.seekNodeByName(csbNode,"Text_20"):setVisible(true)
				gt.seekNodeByName(csbNode,"Text_19"):setString("已打够"..num.."场")
				gt.seekNodeByName(csbNode,"Text_20"):setString("您可在好礼->幸运卡中领取红包、话费、金币")
				gt.seekNodeByName(csbNode,"luckyCardBg_1"):loadTexture("Activity11-9/wancheng.png")
			end
		

		end
		gt.seekNodeByName(csbNode,"Image_1"):loadTexture("Activity11-9/chang.png")
		gt.seekNodeByName(csbNode,"Text_6"):setVisible(true)
		gt.seekNodeByName(csbNode,"Text_6"):setString(num)
		gt.seekNodeByName(csbNode,"Text_3"):setVisible(false)
	end
 	-- gt.seekNodeByName(csbNode,"Text_4"):setString(data1.money)
 	-- gt.seekNodeByName(csbNode,"Text_5"):setString(data1.coin)
 	--1217
 	gt.seekNodeByName(csbNode,"Text_4_5"):setString(data1.desc or "")

	gt.seekNodeByName(csbNode,"guang"):runAction(cc.RepeatForever:create(cc.RotateBy:create(1,70)))
	local str = "起："..data1.start_time.."\n止："..data1.end_time
				gt.seekNodeByName(csbNode, "time"):setString(str)

    local closeBtn = gt.seekNodeByName(self, "close")

    local act = cc.CSLoader:createTimeline("lucky_node.csb")
	csbNode:runAction(act)
	act:gotoFrameAndPlay(0,true)

	gt.addBtnPressedListener(closeBtn, function()
		gt.seekNodeByName(csbNode,"guang"):stopAllActions()
		csbNode:stopAllActions()
		self:removeFromParent()
		
	end)




end



return lucky_node
