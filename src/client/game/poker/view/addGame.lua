local addGame = class("addGame",function()

	return cc.Layer:create()

end)

--[[

Lint  kErrorCode;  //错误代码:0成功
	Lint  kFeeType;      //付费类型
	Lint  kCostFee;        //消耗费用
	Lint  kCurCircle;     //当前局数
	Lint  kMaxCircle;    //最大局数
   std::vector<UserNikeAndPhoto>   kRoomUser;   //房间用户
   
   struct  UserNikeAndPhoto
	{
	Lstring    kNike;           //用户名
	Lstring    kHeadUrl;        //头像
	};

]]


function addGame:ctor(mes)

	gt.removeLoadingTips()

	local node = cc.CSLoader:createNode("addGame.csb")
	self:addChild(node)
	--node:setPosition(gt.winCenter)


	local exit = node:getChildByName("Button_1")


	node:getChildByName("num"):setString(mes.kMaxCircle-mes.kCurCircle)
	node:getChildByName("player"):setString(#mes.kRoomUser)
	node:getChildByName("score"):setString(mes.kCostFee)

	local _url = {}
	for i = 1, #mes.kRoomUser do

		local name = node:getChildByName("Text_"..i)
		name:setVisible(true)
		name:setString(mes.kRoomUser[i].kNike)
		local id = node:getChildByName("id_"..i)
		id:setString("ID:"..(mes.kRoomUser[i].kid or "nil"))
		id:setVisible(true)
		node:getChildByName("header_"..i):setVisible(true)

		_url[i] = mes.kRoomUser[i].kHeadUrl
		local ispath = gt.imageNamePath(_url[i])
		gt.log("i.............",i)
	    local icon = node:getChildByName("icon_"..i)
	    icon:setVisible(true)

	    if icon then
		    if ispath then
		       
		        local _node = display.newSprite("dismiss_room/icon.png")
		       
		        local image = gt.clippingImage(ispath,_node,false)
		       -- image:setScale(1.43)
		       	icon:setVisible(false)
		        node:addChild(image)
		       
		        image:setPosition(icon:getPositionX(),icon:getPositionY())
		    else
				if _url[i] ~= "" and  type(_url[i]) == "string" and string.len(_url[i]) >10 then
					local function callback(args)
						if args.done then 
							local _node = display.newSprite("dismiss_room/icon.png")
						local head = gt.clippingImage(args.image,_node,false)
						node:addChild(head)
						icon:setVisible(false)
						head:setPosition(icon:getPositionX(),icon:getPositionY())
						end
					end
					gt.downloadImage(_url[i], callback)
				end
		    end
		end

	end

	gt.addBtnPressedListener(exit, function()

		self:removeFromParent()

		end)



	gt.addBtnPressedListener(node:getChildByName("not"), function()

		self:removeFromParent()

		end)



	gt.addBtnPressedListener(node:getChildByName("ok"), function()

		gt.dispatchEvent("addGame")

		gt.showLoadingTips(gt.getLocationString("LTKey_0070"))
		--self:removeFromParent()

		end)



end


return addGame