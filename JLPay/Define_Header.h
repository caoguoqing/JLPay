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



// 自定义键盘的高度
#define CustomKeyboardHeight            216.0
// 数据库文件 - 全国地名及代码
#define DBFILENAME_AREACODE             @"test.db"


// 日志打印选项: 打印(1);不打印(0);
#define NeedPrintLog                    1


#define app_delegate  (AppDelegate*)([UIApplication sharedApplication].delegate)
#define Screen_Width  [UIScreen mainScreen].bounds.size.width
#define Screen_Height  [UIScreen mainScreen].bounds.size.height

/* 
 * 环境: 
 * 1: 生产环境(1),
 * 0: 内网测试62,
 * 5: 内网测试50
 * 7: 内网测试72
 * 9: 外网测试62
 */
#define TestOrProduce                   1
// 设置,用来判断是否设置环境ip
#define Setting_Ip @"settingip"
#define Setting_Port @"settingport"
// 环境:8585报文上送的环境
#define Current_IP    [PublicInformation settingIp]
#define Current_Port  [PublicInformation settingPort]//8182//9182    ,测试ip：211.90.22.167；9181
// 环境:HTTP协议的ip配置
#define Tcp_IP  @"tcpip"
#define Tcp_Port @"tcpport"


/*************[交易类型]**************/
#define TranType                    @"TranType"
#define TranType_Consume            @"190000"                           // 消费 同8583 bit3域值
#define TranType_ConsumeRepeal      @"280000"                           // 消费撤销
#define TranType_Chongzheng         @"TranType_Chongzheng"              // 冲正交易
#define TranType_TuiHuo             @"200000"                           // 退货交易
#define TranType_DownMainKey        @"TranType_DownMainKey"             // 下载主密钥
#define TranType_DownWorkKey        @"TranType_DownWorkKey"             // 下载工作密钥
#define TranType_BatchUpload        @"TranType_BatchUpload"             // 披上送，IC卡交易完成后上送
#define TranType_Repay              @"TranType_Repay_"                  // 信用卡还款
#define TranType_Transfer           @"TranType_Transfer_"               // 转账汇款

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
// 账号 -- 保存标记
#define NeedSavingUserID @"NeedSavingUserID"
// 密码
#define UserPW  @"userPW"
// 密码 -- 保存标记
#define NeedSavingUserPW @"NeedSavingUserPW"
// 密码 -- 显示全文本标记
#define NeedDisplayUserPW @"NeedDisplayUserPW"
// 邮箱
#define Business_Email @"commEmail"
// 操作员号
#define Manager_Number @"001"
// 费率 - key; 值为int{0,1,2,3};
#define Key_RateOfPay   @"Key_RateOfPay"


/*************[设备操作相关的参数:]**************/
// 厂商设备类型
#define DeviceType                  @"DeviceType"               
#define DeviceType_JHL_A60          @"A60音频刷卡头A"
#define DeviceType_JHL_M60          @"M60蓝牙刷卡器"
#define DeviceType_RF_BB01          @"蓝牙刷卡头"
#define DeviceType_JLpay_TY01       @"JLpay蓝牙刷卡器"


/* ------------------------------ 信息字典: 商户绑定设备的信息
 *  KeyInfoDictOfBindedDeviceType           - 设备类型
 *  KeyInfoDictOfBindedDeviceIdentifier     - 设备id
 *  KeyInfoDictOfBindedDeviceSNVersion      - 设备SN
 *  KeyInfoDictOfBindedTerminalNum          - 终端号
 *  KeyInfoDictOfBindedBussinessNum         - 商户号
   ------------------------------*/
#define KeyInfoDictOfBinded                     @"KeyInfoDictOfBinded"          // 字典
#define KeyInfoDictOfBindedDeviceType           @"KeyInfoDictOfBindedDeviceType"
#define KeyInfoDictOfBindedDeviceIdentifier     @"KeyInfoDictOfBindedDeviceIdentifier"
#define KeyInfoDictOfBindedDeviceSNVersion      @"KeyInfoDictOfBindedDeviceSNVersion"
#define KeyInfoDictOfBindedTerminalNum          @"KeyInfoDictOfBindedTerminalNum"
#define KeyInfoDictOfBindedBussinessNum         @"KeyInfoDictOfBindedBussinessNum"


// 设备操作的等待超时时间
#define DeviceWaitingTime           20                          

////IC卡 SN序列号
//#define Blue_Device_SN @"4800006472"
//
////蓝牙卡头 CSN
//#define Blue_Device_CSN @"bluecsn"
//#define Blue_IC_PiciNmuber @"000001"
//
////公钥下载 tlv
//#define BlueIC_GongyaoLoad_TLV @"gongyaotlv"
////参数下载 tlv
//#define BlueIC_ParameterLoad_TLV @"parametertlv"
//
//#define Blue_Suppay_Content @"014643B2343BC0204C4068ABCE98A630"
//#define Blue_Main_Key @"00000000000000000000000000000000"
//
////bbpos和蓝牙卡头公用
//#define BlueIC55_Information @"55info"





// 文件名: 8583报文域值属性字典
#define FileNameISO8583FieldsAttri  @"newisoconfig"

/*************[保存的 原交易信息]**************/

// 消费成功的金额,方便撤销支付
#define  SuccessConsumerMoney       @"successmoney"
// 原交易流水号,消费交易的流水号
#define  Last_Exchange_Number       @"lastnumber"
// 3,交易处理码                 -- 跟上一笔交易保持一致  Processing Code
#define  LastF03_ProcessingCode     @"LastProcessingCode_F03__"
// 11,流水号 bcd 6           -- 跟上一笔交易保持一致    System Trace
#define  LastF11_SystemTrace        @"LastSystemTrace_F11__"
// 22,服务点输入方式码         -- 跟上一笔交易保持一致    Service Entry Code
#define  LastF22_ServiceEntryCode   @"LastServiceEntryCode_F22__"
// 37,原交易参考号
#define  LastF37_ReferenceNum       @"LastF37_ReferenceNum__"
// 41 终端号
#define  LastF41_TerminalNo         @"LastF41_TerminalNo__"
// 42 商户号
#define  LastF42_BussinessNo        @"LastF42_BussinessNo__"
// 60,                         -- 跟上一笔交易保持一致   Reserved Private
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
// F22:   服务点输入方式
#define Service_Entry_22    @"Service_Entry_22_"
// F23:   芯片卡序列号
#define ICCardSeq_23    @"ICCardSeq_23_"
// F35:   二磁道数据
#define Two_Track_Data @"trackdata"
// F36:   三磁道数据
#define F36_ThreeTrackData      @"F36_ThreeTrackData_"

// F37:   检索参考号
#define Reference_Number_37 @"Reference_Number_37_"
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
//#define Main_Work_key [PublicInformation getMainSecret]

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


// 8583报文配置
#define TPDU @"6000060000"
#define HEADER @"600100310000"



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


/*************[注册审核未通过:响应配置信息]**************/
#define  RESIGN_mchntNm                 @"RESIGN_mchntNm"
#define  RESIGN_userName                @"RESIGN_userName"
#define  RESIGN_passWord                @"RESIGN_passWord"
#define  RESIGN_identifyNo              @"RESIGN_identifyNo"
#define  RESIGN_telNo                   @"RESIGN_telNo"
#define  RESIGN_speSettleDs             @"RESIGN_speSettleDs"
#define  RESIGN_settleAcct              @"RESIGN_settleAcct"
#define  RESIGN_settleAcctNm            @"RESIGN_settleAcctNm"
#define  RESIGN_areaNo                  @"RESIGN_areaNo"
#define  RESIGN_addr                    @"RESIGN_addr"
#define  RESIGN_ageUserName             @"RESIGN_ageUserName"
#define  RESIGN_mail                    @"RESIGN_mail"
#define  RESIGN_03                      @"RESIGN_03"
#define  RESIGN_06                      @"RESIGN_06"
#define  RESIGN_08                      @"RESIGN_08"
#define  RESIGN_09                      @"RESIGN_09"

#endif
