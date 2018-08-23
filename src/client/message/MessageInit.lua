
local gt = cc.exports.gt

gt.CG_LOGIN					= 61001
gt.GC_LOGIN					= 61002
gt.CG_RECONNECT				= 61003
gt.CG_LOGIN_SERVER			= 61004
gt.GC_LOGIN_SERVER			= 61005
gt.GC_ROOM_CARD				= 61006
gt.GC_MARQUEE				= 61007
gt.CG_HEARTBEAT				= 61008
gt.GC_HEARTBEAT				= 61009
gt.CG_REQUEST_NOTICE		= 61010
gt.GC_REQUEST_NOTICE		= 61011
gt.CG_CREATE_ROOM			= 61012
gt.GC_CREATE_ROOM			= 61013
gt.CG_JOIN_ROOM				= 61014
gt.GC_JOIN_ROOM				= 61015
gt.MSG_C_2_S_JOIN_ROOM_CHECK =62063
gt.MSG_S_2_C_JOIN_ROOM_CHECK =62064
gt.CG_QUIT_ROOM				= 61016
gt.GC_QUIT_ROOM				= 61017
gt.CG_DISMISS_ROOM			= 61018
gt.GC_DISMISS_ROOM			= 61019
gt.CG_APPLY_DISMISS			= 61020
gt.CG_CREATE_ROOM_FZ		= 61021
gt.GC_ENTER_ROOM			= 61022
gt.GC_ADD_PLAYER			= 61023
gt.GC_REMOVE_PLAYER			= 61024
gt.CG_SELECT_SEAT			= 61025
gt.GC_SELECT_SEAT			= 61026
gt.GC_SYNC_ROOM_STATE		= 61027
gt.CG_READY					= 61028
gt.GC_READY					= 61029
gt.CG_START_GAME			= 61030
gt.GC_OFF_LINE_STATE		= 61031
gt.GC_ROUND_STATE			= 61032
gt.GC_START_GAME			= 61033
gt.GC_TURN_SHOW_MJTILE		= 61034
gt.CG_SHOW_MJTILE			= 61035
gt.GC_SYNC_SHOW_MJTILE		= 61036
gt.GC_MAKE_DECISION			= 61037
gt.CG_PLAYER_DECISION		= 61038
gt.GC_SYNC_MAKE_DECISION	= 61039
gt.CG_CHAT_MSG				= 61040
gt.GC_CHAT_MSG				= 61041
gt.GC_ROUND_REPORT			= 61042
-- gt.GC_START_DECISION		= 65
gt.GC_START_DECISION		= 61043     --耗子牌显示消息 
gt.CG_START_PLAYER_DECISION	= 61044
gt.GC_SYNC_START_PLAYER_DECISION= 61045
gt.GC_SYNC_BAR_TWOCARD      = 61046
gt.CG_SYNC_HAIDI			= 61047
gt.CG_CHOOSE_HAIDI			= 61048
gt.CG_TURN_HAIDI			= 61049
gt.GC_FINAL_REPORT			= 61050
gt.CG_HISTORY_RECORD		= 61051
gt.GC_HISTORY_RECORD		= 61052
gt.CG_REPLAY				= 61053
gt.GC_REPLAY				= 61054
gt.CG_SHARE_REPLAY			= 61055
gt.GC_SHARE_REPLAY			= 61056
gt.CG_SHARE_BTN				= 61057
gt.GC_SHARE_BTN				= 61058
gt.GC_GET_VIDEO				= 61059
gt.GC_CHARGE_DIAMOND        = 61060
gt.GC_PURCHASE              = 61061
gt.GC_PLAYER_TYPE           = 61062
gt.CG_COUPONS_EXCHANGE      = 61063 --点击兑换礼券
gt.GC_COUPONS_EXCHANGE      = 61064
gt.CG_COUPONS_EXCHANGE_RECORD  = 61065 --查看兑换礼券列表
gt.GC_COUPONS_EXCHANGE_RECORD  = 61066 
gt.CG_GIFT_EXCHANGE         = 61067  --礼券兑换状态是否成功
gt.GC_GIFT_EXCHANGE         = 61068

gt.GC_GANG_AFTER_CHI_PENG   = 61069 --长沙麻将杠了之后没有人胡可以吃和碰通知
gt.CG_GANG_MAKE_DECISION    = 61070 --长沙麻将杠了之后没有人胡可以吃和碰通知后的决策

gt.CG_GET_TASK_LIST   		= 61071 --获取任务列表请求
gt.GC_GET_TASK_LIST    		= 61072 --获取任务列表回复
gt.CG_FINISH_TASK   		= 61073 --完成任务请求
gt.GC_FINISH_TASK    		= 61074 --完成任务回复

gt.CG_FIND_INVITE_PLAYER   	= 61075 --获取玩家信息
gt.GC_FIND_INVITE_PLAYER    = 61076 --返回玩家信息
gt.CG_GET_INVITE_INFO   	= 61077 --获取邀请信息
gt.GC_GET_INVITE_INFO    	= 61078 --返回邀请信息
gt.CG_INVITE_OK   			= 61079 --绑定邀请者
gt.GC_INVITE_OK    			= 61080 --绑定邀请者结果
gt.CG_SHARE_GAME    		= 61081 --玩家通过微信分享了游戏
gt.CG_LUCKY_DRAW_NUM        = 61082 -- 请求玩家抽奖次数
gt.GC_LUCKY_DRAW_NUM        = 61083 -- 服务器推送玩家抽奖次数

gt.GC_MOON_FREE_FANGKA        = 61084 -- 中秋节送礼券活动服务器推送获奖玩家信息

gt.GC_ZHANIAO				= 61085 -- 扎鸟

-- 转盘抽奖相关
gt.GC_LOTTERY				= 61086  -- 服务器推送活动相关信息
gt.CG_GET_GETLOTTERY		= 61087  -- 玩家请求抽奖
gt.GC_RET_GETLOTTERY		= 61088  -- 服务器返回此次抽奖结果
gt.CG_SAVE_PHONENUM			= 61089  -- 客户端请求写入电话号码
gt.GC_SAVE_PHONENUM			= 61090  -- 服务器返回写入电话号码结果
gt.CG_GET_GETLOTTERYRESULT	= 61091 -- 玩家请求自己的抽奖结果
gt.GC_GET_GETLOTTERYRESULT	= 61092 -- 服务器返回玩家抽奖结果
gt.GC_IS_ACTIVITIES			= 61093 -- 服务器推送是否有活动
gt.CG_GET_ACTIVITIES		= 61094 -- 客户端请求活动信息 返回94号指令

gt.CG_HISTORY_ONE = 61095 -- 客户端请求单把(8局)数据
gt.GC_HISTORY_ONE = 61096-- 服务器推送单把数据

gt.CG_UPDATE_SCORE = 61097 -- 客户端请求分数
gt.GC_UPDATE_SCORE = 61098 -- 服务器返回分数

gt.GC_LONGITUDE_LATITUDE = 61099 -- 请求经纬度
gt.CG_LONGITUDE_LATITUDE = 61100-- 返回经纬度

gt.CG_FZ_RECORD = 61101
gt.GC_FZ_RECORD = 61102

-- gt.GC_TIPS = 170 -- 服务器统一推送所有提示协议
gt.CG_FZ_DISMISS = 61103
gt.GC_FZ_DISMISS = 61104


gt.GC_GET_PHONE_VLDCODE = 61105  --请求获得手机号验证码
gt.CG_GET_PHONE_VLDCODE = 61106  --返回手机号验证码
gt.GC_BIND_PHONE_CODE = 61107   --请求 绑定手机
gt.CG_BIND_PHONE_CODE = 61108   --回复 绑定手机
gt.CG_USER_EXTERN_INFO = 61109  --玩家扩展信息，登陆完成后会带这个消息

gt.CG_PIAO_MSG = 61110--请求飘信息           
gt.GC_PIAO_MSG = 61111--返回飘的信息
gt.GC_PIAO_NUM_MSG = 61112 --断线重连飘的信息

gt.MSG_S_2_C_ZHIDUI = 61113	 --玩家支队



gt.CG_LOGIN_GATE			= 61114 --客户端登录Gate
gt.GC_LOGIN_GATE			= 61115 --Gate回客户端登录消息
gt.CG_VERIFY_HEAD           = 61116

gt.GC_TOAST           		= 61117--服务端群发消息

--文娱馆  301--350
gt.CG_ENTER_CLUB			= 61130    --进入文娱馆
gt.GC_CLUB_SCENE			= 61131    --文娱馆界面内容

gt.CG_LEAVE_CLUB			= 61132    --离开文娱馆   
gt.GC_LEAVE_CLUB			= 61133    --离开文娱馆

gt.CG_SWITCH_PLAY_SCENE		= 61134    --文娱馆界面切换玩法
gt.GC_SWITCH_PLAY_SCENE		= 61135    --文娱馆界面切换玩法内容

gt.GC_CLUB_DESK_INFO		= 61138    --刷新文娱馆桌子信息
gt.GC_CLUB_DESK_PLAYERINFO  = 61139    --文娱馆桌子信息

--防作弊模块
gt.IS_VIP_ROOM               = 61118 --查看是否为vip防作弊房间
gt.SEND_VIDEO_INVITATION     = 61119 --发起视频邀请
gt.RECEIVE_VIDEO_INVITATION  = 61120 --收到视频邀请
gt.INBUSY_VIDEO_INVITATION   = 61121 --视频邀请忙线中
gt.ONLINE_VIDEO_INVITATION   = 61122--视频已连线
gt.SHUTDOWN_VIDEO_INVITATION = 61123 --关闭视频
gt.UPLOAD_GPS_INFORMATION    = 61124--上传GPS坐标
gt.UPLOAD_VIDEO_PERMISSION   = 61125--上传视频是否允许
gt.UPDATE_USER_VIP_INFO      = 61126 --查看是否为vip防作弊房间





---  poker message
gt.MH_MSG_S_2_C_USER_DESK_COMMAND = 61200


gt.MSG_S_2_S_POKER_GAME  = 62010 --   -- 游戏消息 -- zjh 

gt.MSG_S_2_S_POKER_GAME_DDZ  = 62101 --   -- 游戏消息

gt.MSG_C_2_S_POKER_GAME_MESSAGE = 62001 -- 
gt.MSG_S_2_C_VIP_INFO 			= 61032  -- 刷新局数
gt.MSG_S_2_C_POKER_GAME_END_RESULT=62002 -- 大结算
gt.SUB_S_GAME_START           =  61030 -- 开始游戏

gt.MSG_C_S_MAIXIA = 62013
gt.MSG_S_C_MAIXIA = 62014
gt.MSG_S_C_MAIDA  = 62015
gt.MSG_S_C_MAIRESULT = 62016

gt.MSG_YINGSANZHANG_S_2_C_LUN = 111
gt.MSG_C_2_S_POKER_RECONNECT = 62007


gt.SUB_S_AUTO_COMPARE_CARD    =113
gt.SUB_C_FINISH_FLASH 		  = 112
gt.SUB_S_LOOK_CARD            = 107
gt.SUB_C_LOOK_CARD            = 108

gt.SUB_S_COMPARE_CARD         = 109
gt.SUB_C_COMPARE_CARD         = 110

gt.SUB_S_GIVE_UP              = 105
gt.SUB_C_GIVE_UP              = 106

gt.SUB_S_AUTO_ADDSCORE        = 101
gt.SUB_C_AUTO_ADDSCORE        = 102

gt.SUB_S_ADD_SCORE            = 62012
gt.SUB_C_ADD_SCORE            = 104



gt.SUB_S_GAME_END             = 0
gt.SUB_S_BEGIN_BUTTON         = 0 
gt.SUB_S_AUTO_SCORE_RESULT    = 0 
gt.SUB_S_SCORE_LUN            = 0

gt.MSG_C_2_S_CLUB_MASTER_RESET_ROOM = 61152     --文娱馆会长申请解散房间
gt.MSG_S_2_C_CLUB_MASTER_RESET_ROOM = 61153     --服务器返回申请解散房间结果

gt.MSG_S_2_C_READY_TIME_REMAIN = 62062 -- 空闲状态 剩余倒计时
gt.MH_MSG_C_2_S_QUERY_ROOM_GPS_LIMIT = 61150 --//查询房间的GPS距离限制配置信息
gt.MH_MSG_S_2_C_QUERY_ROOM_GPS_LIMIT_RET = 61151 --//返回房间的GPS距离限制配置信息 
gt.MSG_C_2_S_POKER_ROOM_LOG = 62003 --//查询战绩 
gt.MSG_S_2_C_POKER_ROOM_LOG = 62004 -- //服务端返回战绩记录-match

gt.MSG_S_2_C_DDZ_RECON  = 62103 -- 断线重连


-- nn  
gt.MSG_S_2_C_LOOKON_PLAYER_FULL = 62065 -- 服务器广播给观战玩家，是否游戏座位已满
gt.MSG_C_2_S_ADD_ROOM_SEAT_DOWN = 62066 -- 客户端发送观战状态下入座
gt.MSG_S_2_C_ADD_ROOM_SEAT_DOWN = 62067 -- 服务器返回观战玩家入座结果

gt.MSG_S_2_C_NIUNIU_RECON = 62079 -- 断线重连
gt.MSG_S_2_C_NIUNIU_DRAW_RESULT = 62078 -- 小结算



--//牛牛：服务器返回发牌、亮牌消息
gt.MSG_S_2_C_NIUNIU_OPEN_CARD = 62076




--  //牛牛：玩家请求发牌、亮牌消息
gt.MSG_C_2_S_NIUNIU_OPEN_CARD = 62075






--  //牛牛：玩家下注消息

gt.MSG_C_2_S_NIUNIU_ADD_SCROE = 62073

    --kScore  //玩家下注分数






  --//牛牛：服务器返回玩家下注消息

gt.MSG_S_2_C_NIUNIU_ADD_SCORE = 62074

--    kPos  //玩家位置

  --  kScore  //玩家下注分数






 -- //牛牛：服务器发送游戏开始消息

gt.MSG_S_2_C_NIUNIU_START_GAME = 62077

--    kZhuangPos  //庄家位置

--    kScoreTimes  //玩家选庄分数




 -- //牛牛：玩家看牌抢庄消息
gt.MSG_C_2_S_NIUNIU_SELECT_ZHUANG = 62071
-- kQiangScore = 0,1,2,3

--  //牛牛：服务器返回玩家看牌选庄的结果
gt.MSG_S_2_C_NIUNIU_SELECT_ZHUANG = 62072
-- kPos //抢庄玩家位置
-- kPlayerHandCard //4张手牌，最有一个0，扣着
-- kPlayerStatus //每个位置上玩家是否参与游戏 0：不参与 1：参与

gt.MSG_S_2_C_NIUNIU_NOIFY_QIANG_ZHUNG = 62080              --抢庄通知
-- kPos : 0 - 5 叫分位置
-- kQiangScore:  0 - 3 叫的分数





gt.MSG_S_2_C_DOUDIZHU_JOIN_CLUB_ROOM_ANONYMOUS = 62104-- , //文娱馆匿名加入房间


--[[
	
// 客户端请求每局   MSG_C_2_S_POKER_MATCH_LOG=62005,  
kTime, --时间 
kUserId,--用户id
kPos,--用户位置
kDeskId，--桌号

//服务器返回  MSG_S_2_C_POKER_MATCH_LOG=62006,
kFlag，  --游戏类型
kData=  --数组，里面是每一局的信息
{
kTime，--时间
kUserCount， --用户数3
kScore，   --数组，每个人的分数
kVideoId， --一个值，用来请求回放内容

}

]]


gt.MSG_C_2_S_POKER_MATCH_LOG = 62005

gt.MSG_S_2_C_POKER_MATCH_LOG = 62006


--[[
	
	
//客户端请求单局回放内容   MSG_C_2_S_POKER_REQUEST_VIDEO_ID=62105,          //客户端请求回放
Lstring		kVideoId;   


//服务器返回回放内容   MSG_S_2_C_POKER_RESPOND_VIDEO_ID=62106,         //服务器返回回放内容
kZhuang           --庄
kDeskId           --桌号
kCurCircle        --当前局数
kMaxCircle        --最大局数
kState            --玩法类型，斗地主
kScore            --数组，分数
kUserid           --数组，用户id
kNike             --数组，昵称
kSex              --数组，性别
kImageUrl         --数组，头像
kTime             --时间
kPlaytype         --玩法
kOper             --数组，每一步操作 （数组每个元素还是数组1-操作，2-用户pos，3牌值
kCard             --数组，3，每个人初始的手牌
kBankerCard       --底牌

	
]]

gt.MSG_C_2_S_POKER_REQUEST_VIDEO_ID=62105

gt.MSG_S_2_C_POKER_RESPOND_VIDEO_ID=62106



gt.MSG_S_2_C_POKER_WAIT_JOIN_ROOM = 62222

--[[
	kMaxmax = 最大人数
	kcurrent = 当前 （包括自己 最大== kMaxmax）
	kTime = 倒计时时间
]]

gt.MSG_C_2_S_POKER_EXIT_WAIT = 62223
--[[
	
	kClubId = ...
]]

gt.MSG_S_2_C_POKER_EXIT_WAIT = 62224
--[[
	
	kErrorCode == 0 成功
]]









--三打二消息
gt.MSG_S_2_C_SANDAER_SEND_CARDS = 62250 -- 发牌

gt.MSG_S_2_C_SANDAER_RECV_SCORE = 62252 -- 收到服务器叫分
gt.MSG_C_2_S_SANDAER_SELECT_SCORE = 62253 -- 向服务器发送叫分

gt.MSG_S_2_C_SANDAER_SHOW_LASTCARDS = 62254 --叫分结束发底牌

gt.MSG_C_2_S_SANDAER_SELECT_MAIN = 62255  --向服务器发送选主
gt.MSG_S_2_C_SANDAER_SELECT_MAIN_R = 62256 --收到服务器选主结果

gt.MSG_C_2_S_SANDAER_BASE_CARD = 62257 --向服务器发送埋底
gt.MSG_S_2_C_SANDAER_BASE_CARD_R = 62258 --服务器返回埋底结果

gt.MSG_C_2_S_SANDAER_SELECT_FRIEND = 62259 -- 向服务器发送选副庄家
gt.MSG_S_2_C_SANDAER_SELECT_FRIEND_BC = 62260 -- 收到服务器副庄家回复

gt.MSG_C_2_S_SANDAER_OUT_CARD = 62261  --玩家出牌
gt.MSG_S_2_C_SANDAER_OUT_CARD_BC = 62262  --出牌返回

gt.MSG_S_2_C_SANDAER_RECON = 62263 --断线重连数据

gt.MSG_S_2_C_SANDAER_DRAW_RESULT_BC = 62264 --服务器发送结算

gt.MSG_S_2_C_SANDAER_SCORE_105 = 62265 --闲家得分超过105

gt.MSG_C_2_S_SANDAER_SCORE_105_RET = 62266 --闲家得分超过105,向服务器发送玩家选择

gt.MSG_C_2_S_SANDAER_SCORE_105_RESULT = 62267 --闲家得分超过105,收到玩家选择



--三打一消息
gt.MSG_S_2_C_SANDAYI_SEND_CARDS = 62300 -- 发牌

gt.MSG_S_2_C_SANDAYI_SELECT_SCORE_R = 62302 -- 收到服务器叫分
gt.MSG_C_2_S_SANDAYI_SELECT_SCORE = 62303 -- 向服务器发送叫分

gt.MSG_S_2_C_SANDAYI_BASE_CARD_AND_SELECT_MAIN_N = 62304 --叫分结束发底牌

gt.MSG_C_2_S_SANDAYI_SELECT_MAIN = 62305  --向服务器发送选主
gt.MSG_S_2_C_SANDAYI_SELECT_MAIN_R = 62306 --收到服务器选主结果

gt.MSG_C_2_S_SANDAYI_BASE_CARD = 62307 --向服务器发送埋底
gt.MSG_S_2_C_SANDAYI_BASE_CARD_R = 62308 --服务器返回埋底结果

--3打1不需要
--gt.MSG_C_2_S_SANDAER_SELECT_FRIEND = 62259 -- 向服务器发送选副庄家
--gt.MSG_S_2_C_SANDAER_SELECT_FRIEND_BC = 62260 -- 收到服务器副庄家回复

gt.MSG_C_2_S_SANDAYI_OUT_CARD = 62309  --玩家出牌
gt.MSG_S_2_C_SANDAYI_OUT_CARD_BC = 62310  --出牌返回

gt.MSG_S_2_C_SANDAYI_RECON = 62311 --断线重连数据

gt.MSG_S_2_C_SANDAYI_DRAW_RESULT_BC = 62312 --服务器发送结算

gt.MSG_S_2_C_SANDAYI_SCORE_105 = 62313 --闲家得分超过105

gt.MSG_C_2_S_SANDAYI_SCORE_105_RET = 62314 --闲家得分超过105,向服务器发送玩家选择

gt.MSG_C_2_S_SANDAYI_SCORE_105_RESULT = 62315 --闲家得分超过105,收到玩家选择

--五人百分 消息
gt.MSG_S_2_C_WURENBAIFEN_SEND_CARDS = 62350 -- 发牌

gt.MSG_S_2_C_WURENBAIFEN_RECV_SCORE = 62352 -- 收到服务器叫分
gt.MSG_C_2_S_WURENBAIFEN_SELECT_SCORE = 62353 -- 向服务器发送叫分


gt.MSG_S_2_C_WURENBAIFEN_SHOW_LASTCARDS = 62354 --叫分结束发底牌  S->C 服务器通知玩家拿底牌，并选主花色

gt.MSG_C_2_S_WURENBAIFEN_SELECT_MAIN = 62355  --向服务器发送选主
gt.MSG_S_2_C_WURENBAIFEN_SELECT_MAIN_R = 62356 --收到服务器选主结果

gt.MSG_C_2_S_WURENBAIFEN_BASE_CARD = 62357 --向服务器发送埋底
gt.MSG_S_2_C_WURENBAIFEN_BASE_CARD_R = 62358 --服务器返回埋底结果

gt.MSG_C_2_S_WURENBAIFEN_SELECT_FRIEND = 62359 -- 向服务器发送选副庄家
gt.MSG_S_2_C_WURENBAIFEN_SELECT_FRIEND_BC = 62360 -- 收到服务器副庄家回复

gt.MSG_C_2_S_WURENBAIFEN_OUT_CARD = 62361  --玩家出牌
gt.MSG_S_2_C_WURENBAIFEN_OUT_CARD_BC = 62362  --出牌返回

gt.MSG_S_2_C_WURENBAIFEN_RECON = 62363 --断线重连数据

gt.MSG_S_2_C_WURENBAIFEN_DRAW_RESULT_BC = 62364 --服务器发送结算

gt.MSG_S_2_C_WURENBAIFEN_SCORE_105 = 62365 --闲家得分超过105

gt.MSG_C_2_S_WURENBAIFEN_SCORE_105_RET = 62366 --闲家得分超过105,向服务器发送玩家选择

gt.MSG_C_2_S_WURENBAIFEN_SCORE_105_RESULT = 62367 --闲家得分超过105,



gt.MSG_C_2_S_WURENBAIFEN_ZHUANG_JIAO_PAI = 62368 --庄家 客户端选择交牌

gt.MSG_S_2_C_WURENBAIFEN_ZHUANG_JIAO_PAI_BC = 62369 --服务端广播 庄家 交牌

gt.MSG_C_2_S_WURENBAIFEN_XIAN_SELECT_JIAO_PAI = 62370 --非庄家 客户端选择 庄家交牌申请

gt.MSG_S_2_C_WURENBAIFEN_JIAO_PAI_RESULT = 62371 --服务端广播 庄家交牌最后结果


--//S->C 服务器给每个玩家发牌
 gt.MSG_S_2_C_SHUANGSHENG_SEND_CARDS = 62200

 --//S->C 服务器通知玩家报主
 gt.MSG_S_2_C_SHUANGSHENG_NOTICE_SELECT_ZHU = 62213

 --//C->S 玩家报主操作
 gt.MSG_C_2_S_SHUANGSHENG_SELECT_ZHU = 62202

 --//S->C 服务器通知玩家反主
 gt.MSG_S_2_C_SHUANGSHENG_NOTICE_FAN_ZHU = 62203

 --//C->S 玩家反主操作
 gt.MSG_C_2_S_SHUANGSHENG_FAN_ZHU = 62204

-- //S->C 服务器通知玩家拿底牌,当前庄家，主花色等信息
 gt.MSG_S_2_C_SHUANGSHENG_NOTICE_BASE_INFO = 62205

 --//C->S 玩家盖底牌操作
 gt.MSG_C_2_S_SHUANGSHENG_BASE_CARDS = 62206

 --//S->C 买地成功
 gt.MSG_S_2_C_SHUANGSHENG_BASE_CARDS = 62216

 --//S->C 服务器广播游戏开始，开始出牌
 gt.MSG_S_2_C_SHUANGSHENG_BC_GAME_STARE = 62207

 --//C->S 玩家出牌操
 gt.MSG_C_2_S_SHUANGSHENG_OUT_CARDS = 62208

 --//S->C 服务器广播玩家出牌结果
 gt.MSG_S_2_C_SHUANGSHENG_BC_OUT_CARDS_RESULT = 62209

 --//S->C 服务器广播小结算
 gt.MSG_S_2_C_SHUANGSHENG_BC_DRAW_RESULT = 62210

 --//S->C 服务器发送断线重连消息
 gt.MSG_S_2_C_SHUANGSHENG_RECON = 62211


 
 -- 防作弊 打乱顺序
 gt.MSG_S_2_C_DISRUPT   = 62212


