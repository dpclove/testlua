


-- headSpr 为 image 类型 
-- 下载头像适用

local gt = cc.exports.gt

local PlayerHeadManager = class("PlayerHeadManager", function()
	return cc.Node:create()
end)

function PlayerHeadManager:ctor()
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	self._exit = true
	self.spr_tag_buf = {}
end

function PlayerHeadManager:onNodeEvent(eventName)
	if "exit" == eventName then
		self._exit = false
	end
end


function PlayerHeadManager:attach(headSpr, headURL, args)

	args = args or false
	
	if not headSpr or not headURL or string.len(headURL) == 0 then
		return
	end
	if tolua.isnull(headSpr) then return end
	self:delete(headSpr)
	self.spr_tag_buf[headSpr] = headURL

	

	local imgFileName = gt.imageNamePath(headURL)
	if imgFileName then
		if  args then 
			local _node = cc.Sprite:create(args.icon)
			if _node then 
				_node:retain()
				local head = gt.clippingImage(imgFileName,_node,false)
				if tolua.isnull(_node) then return end
				_node:release()
				if gt.addNode(headSpr:getParent(), head , args.zorder  ) then 
					headSpr:setVisible(false)
					head:setName("___ICON__IMAGE___")
					head:setPosition(headSpr:getPositionX(),headSpr:getPositionY())
				end
			end
		else
			headSpr:loadTexture(imgFileName)
		end
		
	else

		local function callback(a)
			
  			if self._exit and self and a.done and headSpr and self.spr_tag_buf[headSpr] == headURL then
  				
	  			if  args then 
					local _node = cc.Sprite:create(args.icon)
					if _node then 
						_node:retain()
						local head = gt.clippingImage(a.image,_node,false)
						if tolua.isnull(_node) then return end
						_node:release()
						if gt.addNode(headSpr:getParent(), head , args.zorder  ) then 
							headSpr:setVisible(false)
							head:setName("___ICON__IMAGE___")
							head:setPosition(headSpr:getPositionX(),headSpr:getPositionY())
						end
					end
				else
					
	  				headSpr:loadTexture(a.image)	
	  			end
			end
	    end   
		
    	gt.downloadImage(headURL,callback)	
	
	end

end

function PlayerHeadManager:delete(headSpr)
	if tolua.isnull(headSpr) or tolua.isnull(headSpr:getParent()) then return end
	headSpr:getParent():removeChildByName("___ICON__IMAGE___")
	headSpr:loadTexture("sd/common/sx_img_head_bg.png")
end

return PlayerHeadManager

