//
//  MsrResult.h
//  MisPosClient
//
//  Created by 陈嘉祺 on 15-1-6.
//  Copyright (c) 2015年 xinocom. All rights reserved.
//

#ifndef MisPosClient_MsrResult_h
#define MisPosClient_MsrResult_h

// SESSION消息
typedef enum {
    SESSION_UNKNOWN = 0,               //!> 未知状态
    SESSION_SCAN_START = 10,           //!> 蓝牙搜索开始
    SESSION_SCAN_STOP,                 //!> 蓝牙搜索结束
    SESSION_CONN_FAIL,                 //!> 蓝牙连接失败
    SESSION_CONN_VALID,                //!> 连接合法设备
    SESSION_CONN_INVALID,              //!> 连接非法设备
    SESSION_DISCONNECT,                //!> 断开连接
    SESSION_KEK_DOWNLOAD = 100,        //!> KEK下载
    SESSION_MKEY_DOWNLOAD,             //!> 主密钥下载
    SESSION_WKEY_DOWNLOAD,             //!> 工作密钥下载
    SESSION_SELECT_PIN,                //!> 密钥选择
    SESSION_INPUT_PIN,                 //!> 密码输入
    SESSION_CALC_MAC,                  //!> MAC计算
    SESSION_PIN_ENCRYPT,                //!> PIN加密
    SESSION_OPEN_CARD = 110,            //!> 开启读卡器
    SESSION_READ_CARD,                 //!> 读磁条卡
    SESSION_SET_ICKEY,                 //!> 设置IC公钥
    SESSION_SET_AID,                   //!> 设置AID
    SESSION_SET_ATTRIB,                //!> 设置交易属性
    SESSION_SET_DATA,                  //!> 设置交易数据
    SESSION_START_EMV,                 //!> 开始IC交易流程
    SESSION_IC_REAUTH,                 //!> IC二次授权
    SESSION_END_EMV,                   //!> 结束IC交易流程
    SESSION_GET_DEVINFO = 120,         //!> 读取设备信息
    SESSION_GET_RANDNUM,               //!> 获取随机数
    SESSION_SET_PARAM,                 //!> 设置商终号
    SESSION_GET_PARAM,                 //!> 读取商终号
    SESSION_BEEP,                      //!> 蜂鸣器
    SESSION_SET_DATETIME,              //!> 设置时间日期
    SESSION_GET_DATETIME,              //!> 获取时间日期
    SESSION_RESET,                     //!> 取消/复位操作
    SESSION_CLOSE_DEVICE,              //!> 关闭设备
    SESSION_UPGRADE,                   //!> 升级应用/固件
} EU_POS_SESSION;

/// 返回结果
typedef enum {
    RET_NULL = 0,
    
    RET_FAIL = -1,                 //!> 未知错误
    RET_FAIL_STX = -2,             //!> STX字段出错
    RET_FAIL_LEN = -3,             //!> LEN字段出错
    RET_FAIL_PATH = -4,            //!> PATH字段出错
    RET_FAIL_TYPE = -5,            //!> TYPE字段出错
    RET_FAIL_ID  = -6,             //!> ID不一致
    RET_FAIL_ETX = -7,             //!> ETX字段出错
    RET_FAIL_LRC = -8,             //!> LRC字段出错
    // 响应码错误返回
    RET_FAIL_CMD = -11,            //!> 指令码不支持
    RET_FAIL_PARAM = -12,          //!> 参数错误
    RET_FAIL_LENGTH = -13,         //!> 可变数据域长度错误
    RET_FAIL_FORMAT = -14,         //!> 帧格式错误
    RET_FAIL_GETLRC = -15,         //!> LRC错误
    RET_FAIL_OTHER = -16,          //!> 其他
    RET_FAIL_TIMEOUT = -17,        //!> 超时
    RET_FAIL_STATUS = -18,         //!> 返回当前状态
    RET_FAIL_PACKAGE = -21,        //!> 接收错误
    // 数据返回出错
    RET_FAIL_WKEY = -100,           //!> 组包失败: 工作密钥
    RET_FAIL_OPENCARD = -101,       //!> 组包失败: 开启读卡器
    RET_FAIL_SETICKEY = -102,       //!> 组包失败: 设置IC卡KEY
    RET_FAIL_SETAID = -103,         //!> 组包失败: 设置AID参数
    RET_FAIL_ICCODE = -104,         //!> 组包失败: 设置IC卡属性
    RET_FAIL_ICDATA = -105,         //!> 组包失败: 设置IC卡数据
    RET_FAIL_EMV_START = -106,      //!> 组包失败: 开始IC卡标准流程
    RET_FAIL_EMV_END = -107,        //!> 组包失败: 结束IC卡标准流程
    RET_FAIL_GET_DEVINFO = -108,    //!> 组包失败: 获取设备信息
    RET_FAIL_SETPARAM = -109,
    RET_FAIL_SETDATETIME = -110,    //!> 组包失败: 设置时间
    RET_FAIL_UPGRADE = -111,        //!> 组包失败: 升级
    RET_FAIL_PINENCRYPT = -112,     //!> 组包失败: PIN加密
   
    RET_TIMEOUT = -200,             //!> 超时
    RET_VERSION_NULL = -201,        //!> 版本号为空
    RET_VERSION_ERR = -202,         //!> 版本号比较失败
    RET_FILE_NOT_FOUND = -203,      //!> 文件找不到
    
    RET_PACKAGE = 10,               //!> 组包中...
    RET_USER_CANCEL = 20,           //!> 用户取消
    
    RET_RESULT = 100,               //!> 大于则有结果返回
    RET_KEK_DOWNLOAD,              //!> KEK下载
    RET_MKEY_DOWNLOAD,             //!> 主密钥下载
    RET_WKEY_DOWNLOAD,             //!> 工作密钥下载
    RET_SELECT_KEY,                //!> 密钥选择
    RET_INPUT_PIN,                 //!> 密码输入
    RET_CALC_MAC,                  //!> MAC计算
    RET_PIN_ENCRYPT,                //!> PIN加密
    RET_OPEN_CARD = 110,            //!> 开启读卡器
    RET_READ_CARD,                 //!> 读磁条卡
    RET_SET_ICKEY,                 //!> 设置IC公钥
    RET_SET_AID,                   //!> 设置AID
    RET_SET_ATTRIB,                //!> 设置交易属性
    RET_SET_DATA,                  //!> 设置交易数据
    RET_START_EMV,                 //!> 开始IC交易流程
    RET_IC_REAUTH,                 //!> IC二次授权
    RET_END_EMV,                   //!> 结束IC交易流程
    RET_GET_DEVINFO = 120,          //!> 读取设备信息
    RET_GET_RANDNUM,               //!> 获取随机数
    RET_SET_PARAM,                 //!> 设置商终号
    RET_GET_PARAM,                 //!> 读取商终号
    RET_BEEP,                      //!> 蜂鸣器
    RET_SET_DATETIME,              //!> 设置时间日期
    RET_GET_DATETIME,              //!> 获取时间日期
    RET_RESET,                     //!> 取消/复位操作
    RET_CLOSE_DEVICE,              //!> 关闭设备
    RET_UPGRADE,                   //!> 升级应用/固件
    RET_UPGRADE_FINISH,               //!> 升级结束
    RET_VERSION,                    //!> 版本比较成功
} EU_POS_RESULT;

//////////////////////////////////////////////////////////////////////////
#define MSR_DATETIME_SIZE               14  // 时间长度
#define MSR_PINBLOCK_SIZE               8   // PINBLOCK长度
#define MSR_MAC_SIZE                    8   // MAC长度
#define MSR_ACCOUNT_SIZE                19  // 主账号长度
#define MSR_PERIOD_SIZE                 4   // 有效期
#define MSR_SERVICECODE_SIZE            3   // 服务代码
#define MSR_TRACK_2_DATA_SIZE           19  // 二磁加密数据
#define MSR_TRACK_3_DATA_SIZE           52  // 二磁加密数据
#define MSR_SN_SIZE                     15  // SN号长度
#define MSR_VERSION_SIZE                24  // 版本号
#define MSR_DEVINFO_SIZE                32  // 厂商自定义信息
#define MSR_RANDNUM_SIZE                8   // 随机数
#define MSR_SHOPID_SIZE                 15  // 商户号
#define MSR_DEVID_SIZE                  8   // 终端号
#define MSR_UPRET_SIZE                  2   // 响应码
#define MSR_CHECKSUM_SIZE               20  // 校验值

/// 简单结果返回
typedef enum {
    RESP_UNKNOWN = 0xFF,                //!> 未知错误
    RESP_SUCC = 0x00,                   //!> 成功
    RESP_FAIL = 0x01,                   //!> 失败
} EU_MSR_RESP;

/// 结果返回: 开启读卡器
typedef enum {
    RESP_OPENCARD_UNKNOWN = 0xFF,       //!> 未知错误
    RESP_OPENCARD_USERCANCEL = 0x00,    //!> 用户取消操作
    RESP_OPENCARD_FINISH = 0x01,        //!> 刷卡结束
    RESP_OPENCARD_INSERT = 0x02,        //!> IC 卡已插入
} EU_MSR_OPENCARD_RESP;

/// 响应读卡方式
typedef enum {
    RESP_READCARD_SUCC = 0x00,          //!> 成功
    RESP_READCARD_FAIL = 0xFF,          //!> 失败
} EU_MSR_READCARD_RESP;

/// EMV执行结果
typedef enum {
    RESP_EMV_SUCC = 0x00,          //!> 成功
    RESP_EMV_ACCEPT = 0x01,        //!> 交易接受
    RESP_EMV_REJECT = 0x02,        //!> 交易拒绝
    RESP_EMV_ONLINE = 0x03,        //!> 联机
    RESP_EMV_FAIL = 0xFF,          //!> 交易失败
    RESP_EMV_FALLBACK = 0xFE,      //!> 回退
} EU_MSR_EMV_RESP;

/// EMV-密码提示
typedef enum {
    PIN_EMV_NOREQ = 0x00,          //!> 无要求
    PIN_EMV_REQ = 0x01,            //!> 要求后续流程输入联机PIN
} EU_MSR_EMV_PIN;

typedef enum {
    RESP_REAUTH_UNKNOWN = 0x00,         //!> 未知错误
    RESP_REAUTH_ACCEPT = 0x01,          //!> 交易授受
    RESP_REAUTH_REJECT = 0x04,          //!> 二次授权交易拒绝
    RESP_REAUTH_FAIL = 0xFF,            //!> 交易失败
} EU_MSR_REAUTH_RESP;

typedef enum {
    DEVSTAT_DEFAULT = 0xFF,             //!> 默认初始状态
    DEVSTAT_WKEYIN = 0x00,              //!> 工作密钥已灌装
    DEVSTAT_MKEYIN = 0x01,              //!> 主密钥已灌装
    DEVSTAT_KEKMOD = 0x02,              //!> KEK已修改
} EU_MSR_DEVSTAT;

typedef enum {
    UPSTAT_BEGIN = 0x00,                //!> 升级开始
    UPSTAT_DOING = 0x00,                //!> 升级中
    UPSTAT_END = 0x01,                  //!> 升级结束
} EU_MSR_UPGRADE_STAT;

/// 返回按键类型
typedef enum {
    KEYTYPE_OK = 0x00,                  //!< 确认键
    KEYTYPE_CANCEL = 0x06,              //!< 取消键
} EU_MSR_KEYTYPE;
///////////////////////////////////////////////////////////////////////////////////////////
/// 密码输入
typedef struct __tag_input_pin {
    EU_MSR_KEYTYPE keyType;             //!> 返回的功能键(0x00 确认键, 0x06 取消键)
    unsigned char pwdLen;            //!> 输入密码长度(0 表示是按了功能键，比如按了 enter 键或者取消键\r\n4-12 表示输入的密码长度)
    unsigned char pPinblock[MSR_PINBLOCK_SIZE];  //!> 加密后的PINBLOCK
} ST_INPUT_PIN;

// 计算MAC
typedef struct __tag_calc_mac {
    unsigned char szMac[MSR_MAC_SIZE];           //!> MAC地址
} ST_CALC_MAC;

// PIN加密
typedef struct __tag_pin_encrypt {
    unsigned char pPinblock[MSR_PINBLOCK_SIZE];           //!> 加密后的PINBLOCK
} ST_PIN_ENCRYPT;

// 读磁条卡
typedef struct __tag_read_card {
    EU_MSR_READCARD_RESP resp;                      //!> 响应的读卡方式
    char szAccount[MSR_ACCOUNT_SIZE + 1];           //!> 主账号
    char szPeriod[MSR_PERIOD_SIZE + 1];             //!> 有效期
    char szServiceCode[MSR_SERVICECODE_SIZE + 1];   //!> 服务代码
    unsigned char cTrack2Size;                      //!> 二磁道长度
    unsigned char cTrack3Size;                      //!> 三磁道长度
    unsigned char szTrack2data[MSR_TRACK_2_DATA_SIZE + 1];   //!> 二磁道数据
    unsigned int nTrack2Length;                              //!> 二磁道数据长度
    unsigned char szTrack3data[MSR_TRACK_3_DATA_SIZE + 1];   //!> 三磁道数据
    unsigned int nTrack3Length;                              //!> 三磁道数据长度
} ST_READ_CARD;

/// IC卡交易流程开始
typedef struct __tag_start_emv {
    EU_MSR_EMV_RESP resp;                           //!> 执行结果
    EU_MSR_EMV_PIN pinReq;                          //!> 联机PIN输入指示
} ST_START_EMV;

/// 获取设备信息
typedef struct __tag_get_devinfo {
    char szSN[MSR_SN_SIZE + 1];                     //!> SN号
    EU_MSR_DEVSTAT status;                            //!> 设备个人化状态
    char szVer[MSR_VERSION_SIZE + 1];               //!> 版本号
    char szInfo[MSR_DEVINFO_SIZE + 1];              //!> 厂商自定义信息
} ST_GET_DEVINFO;

/// 获取随机数
typedef struct __tag_get_randnum {
    unsigned char szRandNum[MSR_RANDNUM_SIZE + 1];           //!> 随机数
} ST_GET_RANDNUM;

/// 获取商终号
typedef struct __tag_get_param {
    char szShopid[MSR_SHOPID_SIZE + 1];             //!> 商户号
    char szDevid[MSR_DEVID_SIZE + 1];               //!> 终端号
} ST_GET_PARAM;

/// 获取时间
typedef struct __tag_get_datetime {
    char *szDatetime[MSR_DATETIME_SIZE];            //!> 日期+时间(格式: YYYYMMDDHHMMSS, 长度14位，以0x00结尾)
} ST_GET_DATETIME;

/// 升级
typedef struct __tag_upgrade {
    EU_MSR_UPGRADE_STAT stat;                       //!> 响应状态
    char szCode[MSR_UPRET_SIZE + 1];                //!> 响应码
    char szCRC[MSR_CHECKSUM_SIZE + 1];              //!> 校验码
} ST_UPGRADE;

#endif
