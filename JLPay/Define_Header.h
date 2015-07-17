//
//  Define_Header.h
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#ifndef JLPay_Define_Header_h
#define JLPay_Define_Header_h

#import "AppDelegate.h"
#import "PublicInformation.h"

#define app_delegate  (AppDelegate *)[UIApplication sharedApplication].delegate


//上传电子单的接口
#define kServerNewURL @"http://122.0.64.115:8080/pos/"//@"http://192.168.1.106:8080/pos/"//@"http://122.0.64.115:8080/pos/"//@"http://122.0.64.115/pos/"



// 8583报文配置
#define TPDU @"6000060000"
#define HEADER @"600100310000"


/*************[notification 变量声明区]**************/
#define Noti_CardSwiped_Success         @"Noti_CardSwiped_Success"      // 读卡
#define Noti_CardSwiped_Fail            @"Noti_CardSwiped_Fail"
#define Noti_TransSale_Success          @"Noti_TransSale_Success"       // 刷卡消费
#define Noti_TransSale_Fail             @"Noti_TransSale_Fail"
#define Noti_WorkKeyWriting_Success     @"Noti_WorkKeyWriting_Success"  // 写工作密钥
#define Noti_WorkKeyWriting_Fail        @"Noti_WorkKeyWriting_Fail"
/*************[notification 变量声明区]**************/

/*************[交易类型]**************/
#define TranType                    @"TranType"
#define TranType_Consume            @"TranType_Consume"                 // 消费
#define TranType_ConsumeRepeal      @"TranType_ConsumeRepeal"           // 消费撤销
#define TranType_Chongzheng         @"TranType_Chongzheng"              // 冲正交易
#define TranType_DownMainKey        @"TranType_DownMainKey"             // 下载主密钥
#define TranType_DownWorkKey        @"TranType_DownWorkKey"             // 下载工作密钥
/*************[交易类型]**************/

/*************[卡片类型:用来标记刷卡是读芯片还是磁条]**************/
#define CardTypeIsTrack             @"CardTypeIsTrack"                  // 值:YES(磁条)/NO(芯片)



#pragma mask ==========================商户相关的参数
// 终端号，商户号,商户名称
#define Terminal_Number @"terminal"
#define Business_Number @"business"
#define Business_Name @"businessname"
// 终端个数
#define Terminal_Count @"termCount"
// 终端号列表-数组
#define Terminal_Numbers @"terminals"
// 账号
#define UserID  @"userID"
// 密码
#define UserPW  @"userPW"
// 邮箱
#define Business_Email @"commEmail"

// 操作员号
#define Manager_Number @"001"


#pragma mask ==========================设备操作相关的参数
#define DeviceType                  @"DeviceType"               // 厂商设备类型
#define DeviceType_JHL_A60          @"锦宏霖音频刷卡头A60"       // 锦宏霖音频A60
#define DeviceType_JHL_M60          @"锦宏霖手持(蓝牙)刷卡器M60"       // 锦宏霖蓝牙M60


#define SelectedTerminalNum         @"SelectedTerminalNum"      // 选择设备连接的终端号配置的key   -- useless
#define SelectedSNVersionNum        @"SelectedSNVersionNum"     // 选择设备连接的SN号的key       -- useless


/* 
 * 绑定de设备信息列表:
 *      terminalNum
 *      SNVersion
 *      identifier
 */
#define BindedDeviceList            @"BindedDeviceList"

#define DeviceWaitingTime           20                          // 设备操作的等待超时时间

// 自定义键盘的高度
#define CustomKeyboardHeight            216.0                           




//IC卡 SN序列号
#define Blue_Device_SN @"4800006472"//@"4800006472"//csn=====@"0800040270000023"//

//蓝牙卡头 CSN
#define Blue_Device_CSN @"bluecsn"

#define Blue_IC_PiciNmuber @"000001"

//公钥下载 tlv
#define BlueIC_GongyaoLoad_TLV @"gongyaotlv"
//参数下载 tlv
#define BlueIC_ParameterLoad_TLV @"parametertlv"

#define Blue_Suppay_Content @"014643B2343BC0204C4068ABCE98A630"
#define Blue_Main_Key @"00000000000000000000000000000000"

//bbpos和蓝牙卡头公用
#define BlueIC55_Information @"55info"


//签到获取的pinkey
#define Sign_in_PinKey @"pinkey"

#define Sign_in_MacKey @"mackey"



//消费获取的搜索参考号
#define Consumer_Get_Sort @"cankaohao"


//主秘钥明文，保存
#define main_key_plain @"mainkeyplain"


//交易流水号，每次交易加1
#define Exchange_Number @"exchangenumber"

//是否消费
#define Is_Or_Consumer @"isconsumer"

//批次号,签到默认6-bcd，从签到中获取
//#define Every_Sort_Number @"000000"
#define Get_Sort_Number @"sortnumber"



//初始化终端成功，可以签到
#define Init_Terminal_Success @"initterminal"

//交易输入的金额
#define Consumer_Money @"money"


/*************[保存的 原交易信息]**************/
//消费成功的金额,方便撤销支付
#define SuccessConsumerMoney @"successmoney"

//原交易流水号,消费交易的流水号
#define Last_Exchange_Number @"lastnumber"

//3,交易处理码                 -- 跟上一笔交易保持一致  Processing Code
#define  LastF03_ProcessingCode     @"LastProcessingCode_F03__"
//11,流水号 bcd 6           -- 跟上一笔交易保持一致    System Trace
#define  LastF11_SystemTrace        @"LastSystemTrace_F11__"
//22,服务点输入方式码         -- 跟上一笔交易保持一致    Service Entry Code
#define  LastF22_ServiceEntryCode   @"LastServiceEntryCode_F22__"
//60,                         -- 跟上一笔交易保持一致   Reserved Private
#define  LastF60_Reserved           @"LastReserved_F60__"



#define app_delegate  (AppDelegate*)([UIApplication sharedApplication].delegate)
#define Screen_Width  [UIScreen mainScreen].bounds.size.width
#define Screen_Height  [UIScreen mainScreen].bounds.size.height

#define Current_IP    [PublicInformation settingIp]
#define Current_Port  [PublicInformation settingPort]//8182//9182    ,测试ip：211.90.22.167；9181

#define Tcp_IP  @"tcpip"
#define Tcp_Port @"tcpport"

#define Setting_Ip @"settingip"
#define Setting_Port @"settingport"

//参数更新(解密key)
#define DECRYPT_KEY @"31313131313131313232323232323232"

//签到(主密钥)
#define Main_Work_key [PublicInformation getMainSecret]

//@"D4A372400FDCAB7A4817643301CF9E6C"

#define IsOrRefresh_MainKey @"refreshkey"
#define Refresh_Later_MainKey @"laterkey"


//C678E939CD3811BE8C8FAC526A2CF20A

#define WorkKey @"workkey"

//签到获取的pinkey
#define Sign_in_PinKey @"pinkey"
#define Sign_in_MacKey @"mackey"

//消费获取的搜索参考号
#define Consumer_Get_Sort @"cankaohao"

//主秘钥明文，保存
#define main_key_plain @"mainkeyplain"



//交易流水号，每次交易加1
#define Exchange_Number @"exchangenumber"

//是否消费
#define Is_Or_Consumer @"isconsumer"

//批次号,签到默认6-bcd，从签到中获取
//#define Every_Sort_Number @"000000"
#define Get_Sort_Number @"sortnumber"

// 签到标志
#define DeviceBeingSignedIn   @"DeviceBeingSignedIn"

//初始化终端成功，可以签到
#define Init_Terminal_Success @"initterminal"

//交易输入的金额
#define Consumer_Money @"money"

//消费成功的金额,方便撤销支付
#define SuccessConsumerMoney @"successmoney"

//原交易流水号,消费交易的流水号
#define Last_Exchange_Number @"lastnumber"
// 原交易签到批次号
#define Last_FldReserved_Number @"fldReserved"

//保存撤销金额
#define Save_Return_Money @"renturnmoney"

//缓存卡号信息
#define Save_All_NonCardInfo @"allcardinfo"


//银行卡号
#define Card_Number @"card"
//二磁道数据
#define Two_Track_Data @"trackdata"
// 芯片卡数据55域数据
#define ICCData_55      @"ICCData_55_"
// 芯片卡序列号
#define ICCardSeq_23    @"ICCardSeq_23_"

//查询的金额
#define SearchCard_Money @"searchmoney"

//刷卡记录
#define TheCarcd_Record [PublicInformation returnposCard]//@"cardcord"

//保存终端号
#define The_terminal_Number @"terminalaaaaa"


//保存本次消费的流水号
#define Current_Liushui_Number @"liushuinumber"

//获取带星的卡号
#define GetCurrentCard_NotAll @"notallcard"

//交易类型
#define ExchangeMoney_Type @"exchangetype"


//保存撤销金额
#define Save_Return_Money @"renturnmoney"

//缓存卡号信息
#define Save_All_NonCardInfo @"allcardinfo"


#pragma mark=============================================支付宝

//支付宝二维码串
#define ErWeiMaChuan @"erweimachuan"
//支付宝扫码输入金额
#define ZhifubaoSaomaMoney @"saomamoney"
//支付宝订单号
#define ZhiFuBaoOrderNumber @"ordernumber"
//支付宝查询

//支付宝查询流水号
#define Zhifubao_search_liushui @"zhifubaosearchliushui"
//支付宝账号
#define Zhifubao_Number @"zhifubaonumber"
//支付宝查询订单号
#define Zhifubao_Search_Order @"searchorder"


//支付宝条码支付，缓存消费记录
#define ZhifubaoTiaomaRecord @"zhifubaotiaomarecord"


//支付宝订单号状态切换(条码、扫码成功 state=1；撤销、退款 state=0)
#define ZhifubaoDingdanState @"dingdanstate"

//支付宝撤销流水号\支付宝退款
#define ZhifubaoChexiaoLiushui @"chexiaoliushui"

//支付宝撤销\退款,账号

//支付宝撤销\退款,订单号
#define ZhifubaoChexiaoDingdanNum @"chexiaodingdannumber"

//支付宝撤销\退款,撤销金额
#define ZhifubaoChexiaoMoney @"chexiaomoney"

//支付宝pos小票中得 商户名称
#define Zhifubao_Merchant @"zhifubaomerchant"

//14域，卡有效期
#define Card_DeadLineTime @"deadline"


#endif
