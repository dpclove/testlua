
local gt = cc.exports.gt

local Utils = require("client/tools/Utils")
local MainNpc = class("MainNpc", function()
	return cc.Layer:create()
end)

function MainNpc:ctor()
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("MainNpc.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
end

return MainNpc

