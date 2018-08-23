
local gt = cc.exports.gt
--玩法类型(与服务器保持一致)
gt.PLAYTYPE = {
	PT_UNDEFINE =0,
	PT_NEEDTING = 1,	--报听
	PT_NEEDWIND = 2,	--带风
	PT_ZIMOHU	= 3,	--只可自摸和
	PT_QINGYISEJIAFAN = 4,	--清一色加番
	PT_YITIAOLONGJIAFAN = 5, --一条龙加番
	PT_ZHUOHAOZI = 6,	--随机耗子
	PT_ShuangHaoZi = 45, -- 双耗子
	PT_GUOHU_ZHIKE_ZIMO = 7, -- 过胡只可自摸
	PT_QIANGGANGHU = 8, -- 抢杠胡
	PT_GANG_BUSUIHU = 9, -- 荒庄不荒杠
	PT_WEITING_GANG_BUSUANFEN = 10, -- 未上听杠不算分
	PT_YIPAO_DUOXIANG = 11,  --一炮多响

	PT_TingPaiKeGang = 12, -- 听牌可杠
	PT_QiXiaoDui = 13, -- 七小对
	PT_ZhiYouHuPaiWanJiaGangSuanFen = 14, -- 杠随胡家
	PT_FengYiSe = 15, -- 风一色
	PT_QingYiSe = 16, -- 清一色，不是清一色加番
	PT_CouYiSe = 17, -- 凑一色

	PT_AnGangKeJian = 18,-- 暗杠可见

	 ----- 做贴金新增小选项
	PT_ShiSanYao = 19, -- 十三幺
	PT_YiTiaoLong = 20, -- 一条龙
	PT_SiJin = 21, -- 4金
	PT_BaJin = 22, -- 8金
	PT_WeiShangJinZheZhiKeZiMo = 23, -- 上金少者只可自摸

	PT_BianKaDiao = 24, -- 2017-3-14: 推倒胡补充小选项：边卡吊 

	PT_YingBaZhang = 50, --硬八张
	PT_GaoFen = 54, --高分(平胡5分）
	PT_HongZhongHaoZi = 55, --红中癞子

	--扣点点
	PT_DanHaoZiFeng = 49, --风耗子

	--硬三嘴
	PT_ZhuangJiaYiFen = 28, -- 庄加加2分
	PT_ZhuangSuanFen = 46, --暗杠可见

	PT_MAX = 31, -- 用于 GameOptionSet
	--一门牌
	PT_Shuye = 39 ,	--数页
	PT_HuangZhuanLunZhuang = 52, --荒庄轮庄

	--洪洞王牌
	PT_Queliangmen = 34, -- 色牌
	PT_Mianpeng = 48 ,	--免碰
    
    --忻州扣点点
	PT_QueYiMeng = 53, --缺一门


	-- 这俩常量定的数太大了
	PT_xiaoHu = 10001, --小胡玩法、也用于显示“平胡”字样
	PT_daHu = 10002, --
}