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


//上传电子单的接口
#define kServerNewURL @"http://122.0.64.115:8080/pos/"//@"http://192.168.1.106:8080/pos/"//@"http://122.0.64.115:8080/pos/"//@"http://122.0.64.115/pos/"

// 自定义键盘的高度
#define CustomKeyboardHeight            216.0


// 8583报文配置
#define TPDU @"6000060000"
#define HEADER @"600100310000"

#define app_delegate  (AppDelegate*)([UIApplication sharedApplication].delegate)
#define Screen_Width  [UIScreen mainScreen].bounds.size.width
#define Screen_Height  [UIScreen mainScreen].bounds.size.height

// 环境:正式(1),62(0),50(5)
#define TestOrProduce      1
// 设置,用来判断是否设置环境ip
#define Setting_Ip @"settingip"
#define Setting_Port @"settingport"
// 环境:8585报文上送的环境
#define Current_IP    [PublicInformation settingIp]
#define Current_Port  [PublicInformation settingPort]//8182//9182    ,测试ip：211.90.22.167；9181
// HTTP协议的ip配置
#define Tcp_IP  @"tcpip"
#define Tcp_Port @"tcpport"



/*************[Notification 变量声明区]**************/
#define Noti_CardSwiped_Success         @"Noti_CardSwiped_Success"      // 读卡
#define Noti_CardSwiped_Fail            @"Noti_CardSwiped_Fail"
#define Noti_TransSale_Success          @"Noti_TransSale_Success"       // 刷卡消费
#define Noti_TransSale_Fail             @"Noti_TransSale_Fail"
#define Noti_WorkKeyWriting_Success     @"Noti_WorkKeyWriting_Success"  // 写工作密钥
#define Noti_WorkKeyWriting_Fail        @"Noti_WorkKeyWriting_Fail"

/*************[交易类型]**************/
#define TranType                    @"TranType"
#define TranType_Consume            @"TranType_Consume"                 // 消费
#define TranType_ConsumeRepeal      @"TranType_ConsumeRepeal"           // 消费撤销
#define TranType_Chongzheng         @"TranType_Chongzheng"              // 冲正交易
#define TranType_DownMainKey        @"TranType_DownMainKey"             // 下载主密钥
#define TranType_DownWorkKey        @"TranType_DownWorkKey"             // 下载工作密钥

/*************[卡片类型:用来标记刷卡是读芯片还是磁条]**************/
#define CardTypeIsTrack             @"CardTypeIsTrack"                  // 值:YES(磁条)/NO(芯片)



/*************[商户相关的参数:]**************/

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

// 费率 - key; 值为int{0,1,2,3};
#define Key_RateOfPay   @"Key_RateOfPay"


/*************[设备操作相关的参数:]**************/

// 厂商设备类型
#define DeviceType                  @"DeviceType"               
// 锦宏霖音频A60
#define DeviceType_JHL_A60          @"音频刷卡头A60"
// 锦宏霖蓝牙M60
#define DeviceType_JHL_M60          @"手持(蓝牙)刷卡器M60"
// 已绑定的设备de ID
#define DeviceIDOfBinded            @"DeviceIDOfBinded"
// 选择设备连接的终端号配置的key   -- useless
#define SelectedTerminalNum         @"SelectedTerminalNum"      
// 选择设备连接的SN号的key       -- useless
#define SelectedSNVersionNum        @"SelectedSNVersionNum"     
/*
 * 绑定de设备信息列表:
 *      deviceType
 *      terminalNum
 *      SNVersion
 *      identifier
 */
#define BindedDeviceList            @"BindedDeviceList"
// 设备操作的等待超时时间
#define DeviceWaitingTime           20                          

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




/*************[保存的 原交易信息]**************/

//消费成功的金额,方便撤销支付
#define  SuccessConsumerMoney       @"successmoney"
//原交易流水号,消费交易的流水号
#define  Last_Exchange_Number       @"lastnumber"
//3,交易处理码                 -- 跟上一笔交易保持一致  Processing Code
#define  LastF03_ProcessingCode     @"LastProcessingCode_F03__"
//11,流水号 bcd 6           -- 跟上一笔交易保持一致    System Trace
#define  LastF11_SystemTrace        @"LastSystemTrace_F11__"
//22,服务点输入方式码         -- 跟上一笔交易保持一致    Service Entry Code
#define  LastF22_ServiceEntryCode   @"LastServiceEntryCode_F22__"
//60,                         -- 跟上一笔交易保持一致   Reserved Private
#define  LastF60_Reserved           @"LastReserved_F60__"


/*************[8583 交易使用的配置信息 交易信息]**************/

// F02:   银行卡号
#define Card_Number @"card"
//        获取带星的卡号
#define GetCurrentCard_NotAll @"notallcard"
// F04:   交易输入的金额
#define Consumer_Money @"money"
//        保存撤销金额
#define Save_Return_Money @"renturnmoney"
// F11:   交易流水号，每次交易加1
#define Exchange_Number @"exchangenumber"
// F12:   交易时间
#define Trans_Time_12      @"Trans_Time_12_"
// F13:   交易日期
#define Trans_Date_13      @"Trans_Date_13_"
// F14:   卡片有效期
#define EXP_DATE_14     @"EXP_DATE_14_"
// F23:   芯片卡序列号
#define ICCardSeq_23    @"ICCardSeq_23_"
// F35:   二磁道数据
#define Two_Track_Data @"trackdata"
// F38:   授权码:AUTH NO
#define AuthNo_38       @"AuthNo_38_"
// F44.1:   发卡行标识
#define ISS_NO_44_1         @"ISS_NO_44_1_"
// F44.2:   结算行标识
#define ACQ_NO_44_2         @"ACQ_NO_44_2_"
// F55:   芯片卡数据55域数据
#define ICCData_55      @"ICCData_55_"
// F60.2: 批次号,签到默认6-bcd，从签到中获取
#define Get_Sort_Number @"sortnumber"
//        O_F60.2 原交易签到批次号
#define Last_FldReserved_Number @"fldReserved"

// 参数更新(解密key)
#define DECRYPT_KEY @"31313131313131313232323232323232"

// ----- 暂时没用到 :主密钥
#define Main_Work_key [PublicInformation getMainSecret]

#define IsOrRefresh_MainKey @"refreshkey"
#define Refresh_Later_MainKey @"laterkey"

// 签到获取的pinkey
#define Sign_in_PinKey @"pinkey"
#define Sign_in_MacKey @"mackey"

// 保存本次消费的流水号
#define Current_Liushui_Number @"liushuinumber"

// 消费获取的搜索参考号
#define Consumer_Get_Sort @"cankaohao"

// 主秘钥明文，保存
#define main_key_plain @"mainkeyplain"

// 是否消费
#define Is_Or_Consumer @"isconsumer"

// 初始化终端成功，可以签到
#define Init_Terminal_Success @"initterminal"

// 下载的工作密钥
#define WorkKey @"workkey"

// 签到获取的pinkey
#define Sign_in_PinKey @"pinkey"
#define Sign_in_MacKey @"mackey"

// 签到标志
#define DeviceBeingSignedIn   @"DeviceBeingSignedIn"

// 查询的金额
#define SearchCard_Money @"searchmoney"

// 刷卡记录
#define TheCarcd_Record [PublicInformation returnposCard]//@"cardcord"

// 保存终端号
#define The_terminal_Number @"terminalaaaaa"

// 交易类型
#define ExchangeMoney_Type @"exchangetype"

//缓存卡号信息
#define Save_All_NonCardInfo @"allcardinfo"




/*************[支付宝 相关的参数:]**************/

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
