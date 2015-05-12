//
//  PosLib.h
//  mposClient
//
//  Created by 陈嘉祺 on 14-12-9.
//  Copyright (c) 2014年 xinocom. All rights reserved.
//

/*
//SDK使用说明

//第一步，初始化SDK
//第二步，注册SDK回调函数
//第三步，调用交易请求函数
//第四步，在回调函数中，判断类型返回，获取返回结果
 
static void PosLibResponce(void *userData,
                           EU_MSR_SESSION sessionType,
                           EU_MSR_RESULT responceCode,
                           const void *retPtr,
                           unsigned int retSize)
{
    printf("PosLibResponce sessionType: %d responceCode: %d",sessionType,responceCode);
    if (sessionType == SESSION_GET_DATETIME
        && responceCode == RET_GET_DATETIME) {
        printf("POS current datetime: %s", GetDatetimeResp()->szDatetime);
    }
    ....
}

void testSDK()
{
    //第一步，初始化SDK
    PosLib_Init();

    //第二步，注册SDK回调函数
    PosLib_SetDelegate(NULL, PosLibResponce);
 
    // 获取POS当前时间
    GetDatetime();
}
*/

///////////////////////////////////////////////////////////////////////////////////////////////
#ifndef ___POSLIB_H___
#define ___POSLIB_H___

#include "MsrParam.h"
#include "MsrResult.h"

#ifdef __cplusplus
extern "C"{
#endif


typedef struct _PosLib PosLib;

/// PosLib的回调接口原型
/**
 * @param userData      用户自定义的数据指针，原值返回
 * @param sessionType   请求类型
 * @param responceCode  请求结果，或设备变更后的状态
 **/
typedef void (*PosLibResponseFunc)(void *userData,
                                        EU_POS_SESSION sessionType,
                                        EU_POS_RESULT responceCode);
 
    typedef void (*PosLibUpdateFunc)();
    
    /// 获取当前SESSION
    EU_POS_SESSION PosLib_GetCurrentSessionType();
    
    /// 初始化SDK
    int PosLib_Init();
    
    /// 注册回调接口
    /**
     * @param userData          用户自定义的数据指针，SDK在调用回调函数时会原值返回userData指针，可以为NULL
     * @param PosLibResponce    SDK回调函数，SDK有状态变化时，会调用该回调函数
     **/
    int PosLib_SetDelegate(void *userData, PosLibResponseFunc PosLibRespFunc);
    
    /// 开始蓝牙搜索
    int PosLib_Scan();
    
    /// 获取蓝牙设备列表
    const char *PosLib_GetDevList();
    
    /// 蓝牙连接指定设备
    /**
     * @param device            蓝牙设备名称
     * @see PosLib_Scan, PosLib_Disconnect
     */
    int connectPos(const char *pszUUID);
    
    /// 断开当前蓝牙连接
    int disconnectPos();

    /// 获取设备状态
    /**
     * @return  -1表示设备未连接，0表示设备已连接
     **/
    int PosLib_DeviceState();

    /// 设置蓝牙读取超时
    /**
     * @param second            [IN]    超时时间(单位:秒)
     * @return －1表示设置失败
     */
    int PosLib_SetTimeout(int second);
    
    /// 获取SDK版本号
    const char *PosLib_GetVersion();
    
    int PosLib_Test();
    
    /// UTF－8转换为GBK编码数据
    const char *PosLib_GetStr(NSString *);
    
    int PosLib_Asc2Hex (unsigned char* pszBcdBuf, const unsigned char* pszAsciiBuf, int nLen, char cType);
    
    int PosLib_Hex2Asc (unsigned char* pszAsciiBuf, const unsigned char* pszBcdBuf, int nLen, char cType);

    ///////////////////////////////////////////////////////////////////////////////
    
    /// KEK下载请求
    /**
     * @param len       [IN]    KEK长度
     * @param kekD1     [IN]    KEK密文1
     * @param kekD2     [IN]    KEK密文2
     * @param kvc       [IN]    校验值
     * @return int      小于0，表示蓝牙未准备好
     * @see LoadMainKey, LoadWorkKey, SetKeyIndex
     */
    int LoadKek(EU_KEY_LENGTH len, unsigned char *kekD1, unsigned char *kekD2, unsigned char *kvc);
    
    /// 获取KEK下载请求结果
    /**
     * @return EU_MSR_RESP         返回结果
     */
    EU_MSR_RESP LoadKekResp();
    
    /// 主密钥下载请求
    /**
     * @param method    [IN]    加密方式
     * @param index     [IN]    主密钥索引
     * @param len       [IN]    主密钥长度
     * @param kekD1     [IN]    KEK密文1
     * @param kekD2     [IN]    KEK密文2
     * @param kvc       [IN]    校验值
     * @return int      小于0，表示蓝牙未准备好
     * @see LoadKek, LoadWorkKey, SetKeyIndex
     */
    int LoadMainKey(EU_ENCRYPT_METHOD method, EU_KEY_INDEX index, EU_KEY_LENGTH len
                    , unsigned char *kekD1, unsigned char *kekD2, unsigned char *kvc);
    
    /// 获取主密钥下载请求结果
    /**
     * @return EU_MSR_RESP         返回结果
     */
    EU_MSR_RESP LoadMainKeyResp();
    
    /// 工作密钥下载请求
    /**
     * @param index     [IN]    密钥索引
     * @param len       [IN]    密钥长度
     * @param pKeystr   [IN]    工作密钥域缓冲区
     * @param nKeylen   [IN]    工作密钥域长度
     * @return int      小于0，表示蓝牙未准备好
     * @see LoadKek, LoadMainKey, SetKeyIndex
     */
    int LoadWorkKey(EU_KEY_INDEX index, EU_KEY_LENGTH len, unsigned char *pKeystr, unsigned int nKeylen);
    
    /// 获取工作密钥下载请求结果
    /**
     * @return EU_MSR_RESP         返回结果
     */
    EU_MSR_RESP LoadWorkKeyResp();

    /// 密钥选择请求
    /**
     * @param index     [IN]    密钥索引
     * @return int      小于0，表示蓝牙未准备好
     * @see LoadKek, LoadMainKey, LoadWorkKey
     */
    int SetKeyIndex(EU_KEY_INDEX index);
    
    /// 获取密钥选择请求结果
    /**
     * @return EU_MSR_RESP         返回结果
     */
    EU_MSR_RESP SetKeyIndexResp();
    
    /// 密码输入请求
    /**
     * @param maxlen   [IN]    输入密码的最大长度
     * @param timeout  [IN]    超时时间
     * @param pszPan   [IN]    主账号
     * @return int      小于0，表示蓝牙未准备好
     */
    int InputPin(unsigned char maxlen, unsigned char timeout, const char *pszPan);
    
    /// 获取密码输入请求结果
    /**
     * @return ST_INPUT_PIN         返回结果
     */
    ST_INPUT_PIN *InputPinResp();
    
    /// MAC计算请求
    /**
     * @param func      [IN]    mac算法
     * @param pData     [IN]    待计算的报文缓冲区
     * @param nDatalen   [IN]   报文长度
     * @return int      小于0，表示蓝牙未准备好
     */
    int CalcMac(EU_MAC_EU_ALG macAlg, unsigned char *pData, unsigned short nDatalen);
    
    /// 获取MAC计算请求结果
    /**
     * @return ST_CALC_MAC         返回结果
     */
    ST_CALC_MAC *CalcMacResp();
    
    /// PIN加密请求
    /**
     * @param pData         [IN]    输入密码数据
     * @param nDatalen      [IN]    密码数据长度
     * @param pszCardNo     [IN]    卡号(不超过19位)
     * @return int      小于0，表示蓝牙未准备好
     */
    int PinEncrypt(unsigned char *pData, unsigned short nDatalen, const char *pszCardNo);
    
    /// 获取PIN加密请求结果
    /**
     * @return ST_PIN_ENCRYPT         返回结果
     */
    ST_PIN_ENCRYPT *PinEncryptResp();
    
    /// 开启读卡器请求
    /**
     * @param pszTradeDes   [IN]    交易类型描述，比如  消费，余额查询
     * @param pszAmt        [IN]    交易金额
     * @param timeout       [IN]    超时时间
     * @param type          [IN]    读卡类型
     * @param pszMsg        [IN]    下位机显示的信息(如果为空，将根据交易类型描述和交易金额进行显示)
     * @return int      小于0，表示蓝牙未准备好
     * @see ReadMagcard
     */
    int OpenCardReader(const char *pszTradeDes, const char *pszAmt
                       , unsigned char timeout, EU_READCARD_TYPE type, const char *pszMsg);
    
    /// 获取开启读卡器请求结果
    /**
     * @return EU_MSR_OPENCARD_RESP         返回结果
     */
    EU_MSR_OPENCARD_RESP OpenCardResp();
    
    /// 读磁条卡请求
    /**
     * @param mode      [IN]    要读取的卡磁道
     * @param hide      [IN]    主账号屏蔽模式
     * @return int      小于0，表示蓝牙未准备好
     */
    int ReadMagcard(EU_READCARD_MODE mode, EU_READCARD_PANMASK hide);
    
    /// 获取读磁条卡请求结果
    /**
     * @return ST_READ_CARD         返回结果
     */
    ST_READ_CARD *ReadMagcardResp();
    
    /// 设置IC卡公钥请求
    /**
     * @param action       [IN]    执行的动作
     * @param pTLV      [IN]    公钥信息
     * @param nSize     [IN]    公钥信息长度
     * @return int      小于0，表示蓝牙未准备好
     */
    int ICPublicKeyManage(EU_ICKEY_ACTION action, const char *pTLV, unsigned int nSize);
    
    /// 获取设置IC卡公钥请求结果
    /**
     * @param pnLength  [INOUT] 返回结果长度
     * @return char*         返回结果内容
     */
    char *ICPublicKeyManageResp(unsigned int *pnLength);
    
    /// 设置AID参数请求
    /**
     * @param action       [IN]    执行的动作
     * @param pTLV      [IN]    AID信息
     * @param nSize     [IN]    AID信息长度
     * @return int      小于0，表示蓝牙未准备好
     */
    int ICAidManage(EU_ICAID_ACTION action, const char *pTLV, unsigned int nSize);
    
    /// 获取设置AID参数请求结果
    /**
     * @param pnLength  [INOUT] 返回结果长度
     * @return char*         返回结果内容
     */
    char *ICAidManageResp(unsigned int *pnLength);
    
    /// 设置IC交易属性请求
    /**
     * @param pTLV      [IN]    交易属性信息
     * @param nSize     [IN]    信息长度
     * @return int      小于0，表示蓝牙未准备好
     */
    int GetEmvAttrib(const char *pTLV, unsigned int nSize);
    
    /// 获取设置IC交易属性请求结果
    /**
     * @param pnLength  [INOUT] 返回结果长度
     * @return char*         返回结果内容
     */
    char *GetEmvAttribResp(unsigned int *pLength);
    
    /// 设置IC交易数据请求
    /**
     * @param pTLV      [IN]    交易数据信息
     * @param nSize     [IN]    信息长度
     * @return int      小于0，表示蓝牙未准备好
     */
    int GetEmvData(const char *pTLV, unsigned int nSize);
    
    /// 获取设置IC交易数据请求结果
    /**
     * @param pnLength  [INOUT] 返回结果长度
     * @return char*         返回结果内容
     */
    char *GetEmvDataResp(unsigned int *pnLength);
    
    /// IC标准流程请求
    /**
     * @param authAmount    [IN]    授权金额，以分为单位
     * @param otherAmount   [IN]    其他金额，以分为单位
     * @param type          [IN]    交易类型
     * @param ecash         [IN]    是否允许电子现金
     * @param pboc          [IN]    下位机EMV执行程度
     * @param online        [IN]    是否强制联机
     * @return int      小于0，表示蓝牙未准备好
     */
    int StartEmv(int authAmount, int otherAmount, EU_TRADE_TYPE type
                 , EU_ECASH_TRADE ecash, EU_PBOC_FLOW pboc, EU_IC_ONLINE online);
    
    /// 获取IC标准流程请求结果
    /**
     * @return ST_START_EMV         返回结果
     */
    ST_START_EMV *StartEmvResp();
    
    /// IC二次授权请求
    /**
     * @param result    [IN]    是否联机成功
     * @param pTLV      [IN]    交易数据信息
     * @param nSize     [IN]    信息长度
     * @return int      小于0，表示蓝牙未准备好
     */
    int EmvDealOnlineRsp(EU_ONLINE_RESULT result, const char *pTLV, unsigned int nSize);
    
    /// 获取IC二次授权请求结果
    /**
     * @return EU_MSR_REAUTH_RESP         返回结果
     */
    EU_MSR_REAUTH_RESP EmvDealOnlineRspResp();
    
    /// IC交易流程结束请求
    /**
     * @return int      小于0，表示蓝牙未准备好
     */
    int EndEmv();
    
    /// 读取设备信息请求
    /**
     * @return int      小于0，表示蓝牙未准备好
     */
    int ReadPosInfo();
    
    /// 获取读取设备信息请求结果
    /**
     * @return ST_GET_DEVINFO         返回结果
     */
    ST_GET_DEVINFO * ReadPosInfoResp();
    
    /// 获取随机数请求
    /**
     * @return int      小于0，表示蓝牙未准备好
     */
    int GetRandomNum();
    
    /// 获取随机数请求结果
    /**
     * @return ST_GET_RANDNUM         返回结果
     */
    ST_GET_RANDNUM *GetRandomNumResp();
    
    /// 设置商终号请求
    /**
     * @param pszShop    [IN]    商户号(最大长度15位，以0x00结尾)
     * @param pszDevice  [IN]    终端号(最大长度15位，以0x00结尾)
     * @return int      小于0，表示蓝牙未准备好
     */
    int SetMTCode(const char *pszShop, const char *pszDevice);
    
    /// 获取商终号请求请求
    /**
     * @return int      小于0，表示蓝牙未准备好
     */
    int GetMTCode();
    
    /// 获取商终号请求结果
    /**
     * @return ST_GET_PARAM         返回结果
     */
    ST_GET_PARAM *GetMTCodeResp();
    
    /// 蜂鸣器
    /**
     * @param times     [IN]    蜂鸣次数
     * @param freq      [IN]    蜂鸣频率(单位:hz)
     * @param duration  [IN]    每次蜂鸣时间(单位:ms)
     * @param step      [IN]    两次蜂鸣时间间隔(单位:ms)
     * @return int      小于0，表示蓝牙未准备好
     */
    int Beep(unsigned short times, unsigned short freq, unsigned short duration, unsigned short step);
   
    /// 设置时间请求
    /**
     * @param pszDatetime     [IN]    日期时间(格式: YYYYMMDDHHMMSS, 长度14位，以0x00结尾)
     * @return int      小于0，表示蓝牙未准备好
     */
    int SetDatetime(const char *pszDatetime);
    
    /// 获取时间请求
    /**
     * @return int      小于0，表示蓝牙未准备好
     */
    int GetDatetime();
    
    /// 获取时间请求结果
    /**
     * @return ST_GET_DATETIME         返回结果
     */
    ST_GET_DATETIME *GetDatetimeResp();
   
    /// 取消/复位操作请求
    /**
     * @return int      小于0，表示蓝牙未准备好
     */
    int ResetPos();
    
    /// 获取取消/复位操作请求结果
    /**
     * @return EU_MSR_RESP         返回结果
     */
    EU_MSR_RESP ResetPosResp();
    
    /// 关闭设备请求
    /**
     * @param option    [IN]    指示关机或休眠
     * @return int      小于0，表示蓝牙未准备好
     */
    int PoweroffPos(EU_CLOSE_ACTION action);
    
    /// 升级设备
    /**
     * @param pUpgradeFilename  [IN]    升级文件存储的路径
     * @return int      小于0，表示蓝牙未准备好
     */
    int UpdatePos(const char *pUpgradeFilename);
    
    /// 获取升级文件大小
    unsigned int PosLib_GetUpgradeLength();
    
    /// 获取升级进度
    unsigned int PosLib_GetUpgradePos();
    
    /// 上位机取消
    void PosLib_Cancel();
    
#ifdef __cplusplus
}
#endif

#endif