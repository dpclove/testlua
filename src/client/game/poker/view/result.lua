local result = class("result",function()
	return gt.createMaskLayer()
end)


local BTN_SHARE = 24

function result:ctor(_type,data)

	local screenshotFileName = "sharewx.png"

	if cc.FileUtils:getInstance():isFileExist(screenshotFileName) then 
		os.remove(screenshotFileName)
	end
	self:registerScriptHandler(handler(self,self.onNodeEvent))
	if _type == "zjh" then
		self:zjh(data)
	elseif _type == "nn" then
		self:nn(data)
	end

end

function result:zjh(data)
	local str  = "resultsNodes.csb"
	if gt.GAME_PLAYER == 5 then 
		str  = "resultsNode.csb"
	else
		str  = "resultsNodes.csb"
	end

	self.result_node = cc.CSLoader:createNode(str)
	self.result_node:setAnchorPoint(0.5, 0.5)
	self.result_node:setPosition(gt.winCenter)
	self:addChild(self.result_node)
	--self.result_node:setPosition(gt.winCenter)
	self.result_node:setName("__ZJH_RESULT__")


	  local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end

	    -- 分享按钮
    local btn = self.result_node:getChildByName("Button_2")
    btn:setTag(BTN_SHARE)
    btn:addTouchEventListener(btncallback)


end

function result:nn(data)

	self.result_node = cc.CSLoader:createNode("resultsNodeNN.csb")
	self.result_node:setAnchorPoint(0.5, 0.5)
	self.result_node:setPosition(gt.winCenter)
	self:addChild(self.result_node)
	self.result_node:setName("NN_RESULT")

	local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end

	-- 分享按钮
    local btn = self.result_node:getChildByName("Btn_share")
    btn:setTag(BTN_SHARE)
    btn:addTouchEventListener(btncallback)
	btn:setPressedActionEnabled(true)
	btn:setZoomScale(-0.1)
end

function result:OnButtonClickedEvent( tag,ref )
	if tag == BTN_SHARE then 
		 gt.soundEngine:Poker_playEffect("sound_res/cli.mp3",false)
		self:shareImage()
	end
end

function result:shareImage()

	   local fileName = "sharewx.png"

 
       cc.utils:captureScreen(function(succeed, outputFile)  
           if succeed then  
             local winSize = cc.Director:getInstance():getWinSize()  
               Utils.shareImageToWX( outputFile, 849, 450, 32 )
           else  
              
           end  
       end, fileName)  

end

function result:shareWxImage()



	local layerSize = self.result_node:getContentSize()
	local screenshot = cc.RenderTexture:create(gt.winSize.width, gt.winSize.height,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)
	screenshot:begin()
	self.result_node:visit()
	screenshot:endToLua()



	local screenshotFileName = string.format("wx-%s.jpg", os.date("%Y-%m-%d_%H:%M:%S", os.time()))
	screenshot:saveToFile(screenshotFileName, cc.IMAGE_FORMAT_JPEG, false)

	self.shareImgFilePath = cc.FileUtils:getInstance():getWritablePath() .. screenshotFileName
	
	self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
end

function result:update()

	if self.shareImgFilePath and cc.FileUtils:getInstance():isFileExist(self.shareImgFilePath) then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		gt.log("ok____")
		local shareImgFilePath = self.shareImgFilePath
		Utils.shareImageToWX( shareImgFilePath, 849, 450, 32 )
		self.shareImgFilePath = nil
	

	end
end


function result:onNodeEvent(eventName)
	
	if "enter" == eventName then
	elseif "exit" == eventName or "cleanup" == eventName then

		gt.log("exit)____________________")
		if self.shareImgFilePath  then
			gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
			self.shareImgFilePath = nil
		end

	end


end

--[[

1.断线重连后，一直显示“欢迎进入游戏”
2.不能动态加入
3.战绩分享图为空
4.3人在牌局中，结果显示了4人，最后结算图，有一个人的id为空，分数为0
5.点击个人头像，需要弹出个人资料页
6.遇到几次到下一局时，无法开局发牌，但是其他玩家已经发牌了，可能是在别人点下一局时，自己电话，回来之后就这样了。
7.最后一局，没有出现小结算面板，直接弹战绩图

]]


return result