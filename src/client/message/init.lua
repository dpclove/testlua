
cc.exports.secure = {
	log = true,
	-- managers = {"fanghu", "fangyu", "ddos"},
	managers = {"fanghu", "fangyu"},
	fanghu = {servername = "shanxi1"},
	ddos = {ip = "hyltwo.ttcdn.cn"}
}

local function log(msg, ...)
	
end
secure.log = log

secure.manager = require("client/message/manager"):getInstance()