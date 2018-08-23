
local gt = cc.exports.gt

local PlayerHeadManager = class("PlayerHeadManager", function()
	return cc.Node:create()
end)

function PlayerHeadManager:ctor()
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	self.headImageObservers = {}

	self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
end

function PlayerHeadManager:onNodeEvent(eventName)
	if "exit" == eventName then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function PlayerHeadManager:update(delta)
	if self.headImageObservers == nil then
		self.headImageObservers = {}
	end
	local transObservers = {}
	local curTime = os.time()
	for i, observerData in ipairs(self.headImageObservers) do		
		if cc.FileUtils:getInstance():isFileExist(observerData.imgFileName) and (curTime-observerData.startTime)>2 and not tolua.isnull(observerData.headSpr) then
			observerData.headSpr:setTexture(observerData.imgFileName)
			observerData.headURL = string.gsub(observerData.headURL, "/0", "/96")
			if observerData.isFlushImage then
				cc.UserDefault:getInstance():setStringForKey(observerData.imgFileName, observerData.headURL)
			end
		else
			table.insert(transObservers, observerData)
		end
	end
	self.headImageObservers = transObservers
end

function PlayerHeadManager:attach(headSpr, parent, playerUID, headURL, sex, isIntable, _contentSize, defaultHeadImage, headFile)
	if isIntable == nil then
		isIntable = false
	end

	if tolua.isnull(headSpr) then return end

	local contentSize = 66
	if _contentSize then
		contentSize = _contentSize
	end

	sex = sex or 1
	if defaultHeadImage == nil then
		if sex == 1 then
			headSpr:setTexture("sd/common/public_img_head_bg.png")
			if isIntable then
				headSpr:setTexture("sd/common/sx_img_head_bg.png")
			end
		else
			headSpr:setTexture("sd/common/public_img_head_bg.png")
			if isIntable then
				headSpr:setTexture("sd/common/sx_img_head_bg.png")
			end
		end
	else
		if headFile then
			headSpr:setTexture(headFile)
		end
	end

	-- if playerUID == 1000000 then
	-- 	headURL = "http://wx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTI81d57tTDDl4dWpD4KxHVRicpCI9eb3zpicvlJe0ibLLZnZNgcmzAhuayjtTbwMibVOCrwsy4sjjoERg/96"
	-- end

	-- if playerUID == 1000009 then
	-- 	headURL = "http://wx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTIGxmSX1ohOc9Stnic7KA9lDfDaKuhW5xnyndicgrjGCaHm4LsqicBmibJJ9PfpjFcp0IxcBkGQv5aLBA/96"
	-- end

	-- print("=========",headSpr,playerUID,headURL)
	if not headSpr or not headURL or string.len(headURL) == 0 then
		return
	end

	local imgFileName = string.format("head_img_%d.png", playerUID)

	local observerData = {}
	observerData.headSpr = headSpr
	observerData.imgFileName = imgFileName
	observerData.headURL = string.gsub(headURL, "/0", "/96")
	observerData.isFlushImage = false

	gt.log("----------------------observerData.imgFileName", observerData.imgFileName)
	if cc.FileUtils:getInstance():isFileExist(observerData.imgFileName) then
		observerData.headSpr:setTexture(observerData.imgFileName)
		gt.log("------------------创建裁剪玩家头像1")
	    --创建裁剪玩家头像
		local HeadLayout = nil
	    if parent then
	    	HeadLayout = parent
	    else
	    	HeadLayout = headSpr:getParent()
	    end
		headSpr:retain()
		headSpr:removeFromParentAndCleanup(false)
		-- HeadLayout:addChild(headSpr)
		-- headSpr = cc.Sprite:create("res/images/otherImages/head_bg.png")
		gt.createClipHead(headSpr, HeadLayout, contentSize)
		headSpr:release()
		return headSpr
	else
		if string.sub(observerData.headURL, 1, 4) ~= "http" then
			if defaultHeadImage == nil then
					sex = sex or 1
					if sex == 1 then
						headSpr:setTexture("sd/common/public_img_head_bg.png")
						if isIntable then
							headSpr:setTexture("sd/common/sx_img_head_bg.png")
						end
					else
						headSpr:setTexture("sd/common/public_img_head_bg.png")
						if isIntable then
							headSpr:setTexture("sd/common/sx_img_head_bg.png")
						end
					end
			else
				if headFile then
					headSpr:setTexture(headFile)
				end
			end
			gt.log("------------------创建裁剪玩家头像2")
		    --创建裁剪玩家头像
			local HeadLayout = nil
		    if parent then
		    	HeadLayout = parent
		    else
		    	HeadLayout = headSpr:getParent()
		    end
			headSpr:retain()
			headSpr:removeFromParentAndCleanup(false)
			-- headSpr = cc.Sprite:create("res/images/otherImages/head_bg.png")
			gt.createClipHead(headSpr, HeadLayout, contentSize)
			-- HeadLayout:setPositionY(HeadLayout:getPositionY())
			headSpr:release()	
			return headSpr
		end
	end

	table.insert(self.headImageObservers, observerData)

	-- 当前头像不存在或者头像更新,重新下载
	observerData.startTime = os.time()
	cc.UtilityExtension:httpDownloadImage(observerData.headURL, playerUID)
	observerData.isFlushImage = true

	gt.log("------------------创建裁剪玩家头像3")
    --创建裁剪玩家头像
	local HeadLayout = nil
	if parent then
    	HeadLayout = parent
    else
    	HeadLayout = headSpr:getParent()
    end
	headSpr:retain()
	headSpr:removeFromParentAndCleanup(false)
	gt.createClipHead(headSpr, HeadLayout, contentSize)
	headSpr:release()

	return headSpr
end

function PlayerHeadManager:detach(headSpr)
	for i, observerData in ipairs(self.headImageObservers) do
		if observerData.headSpr == headSpr then
			table.remove(self.headImageObservers, i)
			break
		end
	end
end

function PlayerHeadManager:clear()
	self.headImageObservers = {}
end

return PlayerHeadManager

