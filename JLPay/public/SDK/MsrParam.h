//
//  MsrParam
//  MisPosClient
//
//  Created by 陈嘉祺 on 15-1-5.
//  Copyright (c) 2015年 xinocom. All rights reserved.
//

#ifndef MisPosClient_MsrParam_h
#define MisPosClient_MsrParam_h
    
/// 密钥长度
typedef enum {
    LEN_SINGLE = 0x01,     //!< 单倍长
    LEN_DOUBLE = 0x02,     //!< 双倍长
} EU_KEY_LENGTH;

/// 加密方式
typedef enum {
    ENCRYPT_KEK = 0x00,     //!< KEK加密
    ENCRYPT_MAINKEY = 0x01, //!< 原主钥加密
} EU_ENCRYPT_METHOD;

/// 密钥索引号
typedef enum {
    KEY_IND_0 = 0x00,       //!< 索引0
    KEY_IND_1,              //!< 索引1
    KEY_IND_2,              //!< 索引2
    KEY_IND_3,              //!< 索引3
    KEY_IND_4,              //!< 索引4
    KEY_IND_5,              //!< 索引5
    KEY_IND_6,              //!< 索引6
    KEY_IND_7,              //!< 索引7
    KEY_IND_8,              //!< 索引8
    KEY_IND_9,              //!< 索引9
} EU_KEY_INDEX;

/// MAC算法
typedef enum {
    MACALG_UBC = 0x00,     //!< UBC算法
    MACALG_X99,            //!< X99/X919
    MACALG_EBC,            //!< EBC算法
} EU_MAC_EU_ALG;
    
// 读卡类型
typedef enum {
    READ_TRACK = 0x01,      //!< 读取磁道信息
    IC_PRESENT = 0x02,       //!< 检查IC是否在位
    COMBINED = (0x01 | 0x02)
} EU_READCARD_TYPE;
    
// 读卡模式
typedef enum {
    READ_TRACK_2 = 0x02,        //!< 第二磁道数据
    READ_TRACK_4 = 0x04,        //!< 第三磁道数据
    READ_TRACK_COMBINED = (0x02 | 0x04)
} EU_READCARD_MODE;
    
// 主账号屏蔽模式
typedef enum {
    READ_NOMASK = 0x00,       //!< 主账号不屏蔽显示
    READ_MASK = 0x01,      //!< 账号屏蔽显示
} EU_READCARD_PANMASK;

// IC公钥设置操作
typedef enum {
    IC_KEY_CLEARALL = 0x01,     //!< 清除全部公钥
    IC_KEY_ADD = 0x02,          //!< 增加一个公钥
    IC_KEY_DEL = 0x03,          //!< 删除一个公钥
    IC_KEY_LIST = 0x04,         //!< 读取公钥列表
    IC_KEY_READ = 0x05,         //!< 读取指定公钥
} EU_ICKEY_ACTION;

/// AID设置操作
typedef enum {
    IC_AID_CLEARALL = 0x01,     //!< 清除全部AID
    IC_AID_ADD = 0x02,          //!< 增加一个AID
    IC_AID_DEL = 0x03,          //!< 删除一个AID
    IC_AID_LIST = 0x04,         //!< 读取AID列表
    IC_AID_READ = 0x05,         //!< 读取指定AID
} EU_ICAID_ACTION;
    
/// 电子现金交易指示器
typedef enum {
    ECASH_FORBIT = 0x00,       //!< 不支持
    ECASH_PERMIT = 0x01,        //!< 支持
} EU_ECASH_TRADE;
    
/// PBOC流程指示
typedef enum {
    PBOC_FULL = 0x01,           //!< 读应用数据
    PBOC_PART = 0x01,           //!< 第一次密文生成
} EU_PBOC_FLOW;

/// IC卡操作是否联机
typedef enum {
    ONLINE_NO = 0x00,           //!< 不强制联机
    ONLINE_YES = 0x01,          //!< 强制联机
} EU_IC_ONLINE;

/// 交易类型
typedef enum {
	FUNC_BALANCE ,			//!< 查询
	//消费类
	FUNC_SALE,				//!< 消费
	//预授权类
	FUNC_PREAUTH,				//!< 预授权
	FUNC_AUTHSALE,				//!< 预授权完成请求
	FUNC_AUTHSALEOFF,			//!< 预授权完成通知
	FUNC_AUTHSETTLE,			//!< 预授权结算
	FUNC_ADDTO_PREAUTH,			//!< 追加预授权
	//退货类
	FUNC_REFUND ,				//!< 退货
	//撤销类
	FUNC_VOID_SALE,			//!< 消费撤销
	FUNC_VOID_AUTHSALE,			//!< 预授权完成撤销
	FUNC_VOID_AUTHSETTLE,		//!< 结算撤销
	FUNC_VOID_PREAUTH,			//!< 预授授权撤销
	FUNC_VOID_REFUND,			//!< 撤销退货
	//离线类
	FUNC_OFFLINE,				//!< 离线结算
	FUNC_ADJUST,				//!< 结算调整
	//电子钱包类
	FUNC_EP_LOAD,				//!< EP圈存
	FUNC_EP_PURCHASE,			//!< EP消费
	FUNC_CASH_EP_LOAD,			//!< 现金充值圈存     
	FUNC_NOT_BIND_EP_LOAD,		//!< 非指定帐户圈存 
	//分期类
	FUNC_INSTALMENT,			//!< 分期付款
	FUNC_VOID_INSTALMENT,		//!< 撤销分期
	//积分类
	FUNC_BONUS_IIS_SALE,		//!< 发卡行积分消费
	FUNC_VOID_BONUS_IIS_SALE,	//!< 撤销发卡行积分消费
	FUNC_BONUS_ALLIANCE,		//!< 联盟积分消费
	FUNC_VOID_BONUS_ALLIANCE,	//!< 撤销联盟积分消费
	FUNC_ALLIANCE_BALANCE,		//!< 联盟积分查询
	FUNC_ALLIANCE_REFUND,		//!< 联盟积分退货
	FUNC_INTEGRALSIGNIN,		//收银员积分签到
	//电子现金类
	FUNC_QPBOC,					//!< 快速消费
	FUNC_EC_PURCHASE,			//!< 电子现金消费
	FUNC_EC_LOAD,				//!< 电子现金指定账户圈存
	FUNC_EC_LOAD_CASH,			//!< 电子现金圈存现金
	//FUNC_EC_LOAD_NOT_BIND,		//!< 电子现金圈存非指定账户
	FUNC_EC_NOT_BIND_OUT,		//电子现金非指定账户圈存转出
	FUNC_EC_NOT_BIND_IN,		//电子现金非指定账户转入
	FUNC_EC_VOID_LOAD_CASH,		//!< 电子现金圈存现金撤销
	FUNC_EC_REFUND,				//!< 电子现金脱机退货
	FUNC_EC_BALANCE,			//!< 电子现金余额查询
	//无卡类
	FUNC_APPOINTMENT_SALE,		//!< 无卡预约消费
	FUNC_VOID_APPOINTMENT_SALE,	//!< 撤销无卡预约消费
	//磁条充值类
	FUNC_MAG_LOAD_CASH,			//!< 磁条预付费卡现金充值
	FUNC_MAG_LOAD_ACCOUNT,		//!< 磁条预付费卡账户充值
	//手机芯片类
	FUNC_PHONE_SALE,			//!< 手机芯片消费
	FUNC_VOID_PHONE_SALE,		//!< 撤销手机芯片消费
	FUNC_REFUND_PHONE_SALE,		//!< 手机芯片退货
	FUNC_PHONE_PREAUTH,			//!< 手机芯片预授权
	FUNC_VOID_PHONE_PREAUTH,	//!< 撤销手机芯片预授权
	FUNC_PHONE_AUTHSALE,		//!< 手机芯片预授权完成
	FUNC_PHONE_AUTHSALEOFF,		//!< 手机芯片完成通知
	FUNC_VOID_PHONE_AUTHSALE,	//!< 撤销手机完成请求
	FUNC_PHONE_BALANCE,			//!< 手机芯片余额查询
	//订购类
	FUNC_ORDER_SALE,			//!< 订购消费
	FUNC_VOID_ORDER_SALE,		//!< 订购消费撤销
	FUNC_ORDER_PREAUTH,			//!< 订购预授权
	FUNC_VOID_ORDER_PREAUTH,	//!< 订购预授权撤销
	FUNC_ORDER_AUTHSALE,		//!< 订购预授权完成
	FUNC_VOID_ORDER_AUTHSALE,	//!< 订购预授权完成撤销
	FUNC_ORDER_AUTHSALEOFF,		//!< 订购预授权完成通知
	FUNC_ORDER_REFUND,			//!< 订购退货
	//其他
	FUNC_EMV_SCRIPE,			//!< EMV脚本结果通知
	FUNC_EMV_REFUND,			//!< EMV脱机退货
	FUNC_PBOC_LOG,				//!< 读PBOC日志
	FUNC_LOAD_LOG,				//!< 读圈存日志
	FUNC_REVERSAL,				//!< 冲正
	FUNC_TC,
	FUNC_SETTLE,				//!< 结算
    
	COUNTTRANSTYPECOUNT
} EU_TRADE_TYPE;

/// 是否联机成功
typedef enum  {
    ONLINE_SUCC = 0x00,             //!> 联机成功
    ONLINE_FAIL = 0x01,             //!> 联机未成功
} EU_ONLINE_RESULT;

/// 关机选项
typedef enum {
    CLOSE_POWEROFF = 0x01,          //!> 关机
    CLOSE_SUSPEND = 0x02,             //!> 休眠
} EU_CLOSE_ACTION;

/// 升级请求状态
typedef enum {
    UPREQ_START = 0X01,             //!> 升级开始
    UPREQ_DOING = 0x02,             //!> 升级中
    UPREQ_FINISH = 0x03,            //!> 结束
} EU_UPGRADE_REQ;

#endif
