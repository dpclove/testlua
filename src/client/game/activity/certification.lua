local certification = class("certification",function()

	return gt.createMaskLayer()
	end)


function certification:ctor()

	local node = cc.CSLoader:createNode("shiming.csb")
	node:setPosition(gt.winCenter)
	self:addChild(node)

	self.name = gt.seekNodeByName(node, "name")
	self.id = gt.seekNodeByName(node, "num")

	self.name:addEventListener(handler(self, self.onEditboxUserName))
	self.id:addEventListener(handler(self, self.onEditboxUserid))

	gt.addBtnPressedListener(gt.seekNodeByName(node, "Button_3"),function()
			

			local idx = 1

			if string.len(self.name:getString())%3 == 0  and string.len(self.name:getString())  >= 6 and string.len(self.id:getString()) == 18 then 
				for i = 1 , string.len(self.name:getString()) do
					if i%3 == 1 and i + 2 <= string.len(self.name:getString()) and string.byte(string.sub(self.name:getString(),i,i+2)) >= 128 and string.byte(string.sub(self.name:getString(),i,i+2)) <= 255 then idx = idx + 1 end
				end
				if 88 ==  string.byte(string.sub(self.id:getString(),17,18)) or string.byte(string.sub(self.id:getString(),17,18)) == 120 or (string.byte(string.sub(self.id:getString(),17,18)) >=48 and string.byte(string.sub(self.id:getString(),17,18)) <= 57) then
					for i = 1 , string.len(self.id:getString()) do if i + 2 <= string.len(self.id:getString()) and string.byte(string.sub(self.id:getString(),i,i+1)) >=48 and string.byte(string.sub(self.id:getString(),i,i+1)) <= 57 then idx = idx + 1 end end
				end
			end 

			if idx == 17 + string.len(self.name:getString())/3 then 
		  		self:removeFromParent()
	    	else
			  	Toast.showToast(display.getRunningScene(), "请输入正确的个人信息", 2)
			end

		end)


	gt.addBtnPressedListener(gt.seekNodeByName(node, "Button_2"),function()

		self:removeFromParent()

	end)

end


function certification:onEditboxUserName(sender, eventType)


	if eventType == ccui.TextFiledEventType.attach_with_ime then
   
   
    elseif eventType == ccui.TextFiledEventType.detach_with_ime then
      
    elseif eventType == ccui.TextFiledEventType.insert_text then
        gt.log("TextFiledEventType.insert_text")

    elseif eventType == ccui.TextFiledEventType.delete_backward then
        gt.log("TextFiledEventType.delete_backward")

    end

end


function certification:onEditboxUserid(sender, eventType)
	

	if eventType == ccui.TextFiledEventType.attach_with_ime then
       
    elseif eventType == ccui.TextFiledEventType.detach_with_ime then
       
    elseif eventType == ccui.TextFiledEventType.insert_text then
        gt.log("insert_text")




    elseif eventType == ccui.TextFiledEventType.delete_backward then

        gt.log("delete")
    end

end

return certification