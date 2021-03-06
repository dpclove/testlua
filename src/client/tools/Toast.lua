
cc.exports.Toast = {}

local function showToast(context,message,delaytime,color)
	if (context == nil) or  (message == nil) or (delaytime<1) then
		return
	end

	local msgtype = type(message)
	if msgtype == "userdata" or msgtype == "table" then
		return
	end

	if message == "" then
		return
	end
	local showMessage = message	
	
	local bg = context:getChildByName("toast_bg")
	local lab = nil
	if bg then
		bg:stopAllActions()
		lab = bg:getChildByName("toast_lab")
		if nil == lab then
			lab = cc.Label:createWithTTF(showMessage, "fonts/round_body.ttf", 24, cc.size(930,0))
			lab:setName("toast_lab")
			
			lab:setTextColor(not color and cc.c4b(255,255,255,255) or color)
			lab:addTo(bg, 999)
		end
		lab:stopAllActions()
		bg:setOpacity(255)
		lab:setOpacity(255)
		bg:runAction(cc.Sequence:create(cc.DelayTime:create(delaytime), 
			cc.Spawn:create(cc.FadeTo:create(0.5,0),cc.CallFunc:create(function()
				lab:runAction(cc.FadeTo:create(0.5,0))
				end)), 
			cc.RemoveSelf:create(true)))		
	else
		bg = ccui.ImageView:create("res/zy_zjh/frame_tips.png")
		bg:setOpacity(0)
		bg:move(gt.winSize.width/2,gt.winSize.height/2)
		bg:addTo(context, 999)
		bg:setName("toast_bg")
		bg:setScale9Enabled(true)
		bg:runAction(cc.Sequence:create(cc.FadeTo:create(0.5,255), 
			cc.DelayTime:create(delaytime), 
			cc.Spawn:create(cc.FadeTo:create(0.5,0),cc.CallFunc:create(function()
				lab:runAction(cc.FadeTo:create(0.5,0))
				end)), 
			cc.RemoveSelf:create(true)))

		lab = gt.createTTFLabel(showMessage, 24)
		lab:setName("toast_lab")
		
		lab:setTextColor(not color and cc.c4b(255,255,255,255) or color)
		lab:addTo(bg, 999)
	end

	if nil ~= lab and nil ~= bg then
		lab:setString(showMessage)
		lab:setTextColor(not color and cc.c4b(255,255,255,255) or color)
		local labSize = lab:getContentSize()		

		if labSize.height < 30 then
			lab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			bg:setContentSize(cc.size(gt.winSize.width, 64))
		else
			lab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
			bg:setContentSize(cc.size(gt.winSize.width, 64 + labSize.height))		
		end
		lab:move(gt.winSize.width * 0.5, bg:getContentSize().height * 0.5)
	end
end

Toast.showToast = showToast

--???????????????toast(fadeto?????????????????????????????????????????????????????????)
local function showToastNoFade(context,message,delaytime,color)
	if (context == nil) or  (message == nil) or (delaytime<1) then
		return
	end

	local msgtype = type(message)
	if msgtype == "userdata" or msgtype == "table" then
		return
	end

	if message == "" then
		return
	end
	local showMessage = message	
	
	local bg = context:getChildByName("toast_bg")
	local lab = nil
	if bg then
		bg:stopAllActions()
		lab = bg:getChildByName("toast_lab")
	else
		bg = ccui.ImageView:create("res/images/otherImages/frame_tips.png")
		bg:move(gt.winSize.width/2,gt.winSize.height/2)
		bg:addTo(context)
		bg:setName("toast_bg")
		bg:setScale9Enabled(true)		

		lab = gt.createTTFLabel(showMessage, 24)
		lab:setName("toast_lab")
		
		lab:setTextColor(not color and cc.c4b(255,255,255,255) or color)
		lab:addTo(bg)
	end

	if nil ~= lab and nil ~= bg then
		lab:setString(showMessage)
		lab:setTextColor(not color and cc.c4b(255,255,255,255) or color)
		bg:runAction(cc.Sequence:create(cc.DelayTime:create(delaytime), cc.RemoveSelf:create(true)))

		local labSize = lab:getContentSize()
		if labSize.height < 30 then
			lab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			bg:setContentSize(cc.size(gt.winSize.width, 64))
		else
			lab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
			bg:setContentSize(cc.size(gt.winSize.width, 64 + labSize.height))		
		end
		lab:move(gt.winSize.width * 0.5, bg:getContentSize().height * 0.5)
	end
end

Toast.showToastNoFade = showToastNoFade