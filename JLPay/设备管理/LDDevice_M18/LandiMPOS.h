//
//  LandiMPOS.h
//  LDReader
//
//  Created by huangzq on 14-6-11.
//  Copyright (c) 2014年 landi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDCommon.h"

@interface LandiMPOS : NSObject

/**
 *	@brief	获取LandiMpos的控制类，所有的接口都是在这个类实现的
 *
 *	@return	MPOS控制类
 */
+ (id) getInstance;


/**
 *	@brief	查询设备
 *
 *	@param 	timeout 	查询超时
 *	@param 	searchOneDeviceCB 	查询到一个设备回调
 *	@param 	searchCompleteCB 	查询设备完成回调
 *
 *	@return	void
 */
- (void) startSearchDev:(NSInteger)timeout
   searchOneDeviceBlcok:(onSearchOneDeviceCB)searchOneDeviceCB completeBlock:(onSearchCompleteCB)searchCompleteCB;

/**
 *	@brief	停止查询设备
 *
 *	@return	void
 */
- (void) stopSearchDev;

/**
 *	@brief	打开设备
 *
 *	@param 	identifier 	设备识别码
 *	@param 	channel 	设备的通讯通道
 *	@param 	mode 	通讯的模式
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) openDevice:(NSString *)identifier channel:(LDE_CHANNEL)channel mode:(LDE_COMMUNICATIONMODE)mode
       successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	关闭设备
 *
 *	@return	void
 */
- (void) closeDevice;


/**
 *	@brief	是否连接
 *
 *	@return	设备是否连接
 */
- (BOOL)isConnectToDevice;

/**
 *	@brief	获取设备日期时间
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) getDateTime:(onNSDataCB)successCB failedBlock:(onErrorCB)failedCB;


/**
 *	@brief	日志打开方式的选择
 *
 *	@param 	logState 	打开哪种日志的选项
 *
 *	@return	void
 */
- (void) switchLog:(LDE_LOGSTATE)logState;


/**
 *	@brief	获取设备电量
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) getDeviceElectricity:(onLDE_BatteryLevelCB)successCB failedBlock:(onErrorCB)failedCB;


/**
 *	@brief	获取设备信息
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) getDeviceInfo:(onGetDeviceCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	获取产品序列号
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) getProductSN:(onNSStringCB)successCB failedBlock:(onErrorCB)failedCB;


/**
 *	@brief	获取批次号和流水号
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) getBatchNOANDSerialNO:(onGetBNSNCB)successCB failedBlock:(onErrorCB)failedCB;

- (void) setSearialNO:(NSString *)searialNO successCB:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

- (void) setBatchNO:(NSString *)batchlNO successCB:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;


/**
 *	@brief	取消指令发送接口
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) cancelCMD:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;


/**
 *	@brief	获取LIB库的版本号
 *
 *	@return	LIB库的版本号
 */
- (NSString *) getLibVersion;


/**
 *	@brief	在设备端显示文本
 *
 *	@param 	text 	需要显示的文本
 *	@param 	row 	显示行号
 *	@param 	col 	显示列号
 *	@param 	timeout 	显示时间
 *	@param 	clearflag 	是否清屏
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) displayLines:(NSString*)text Row:(NSUInteger)row Col:(NSUInteger)col Timeout:(int)timeout ClearScreen:(LDE_CLEARFLAG)clearflag
         successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	查询主密钥
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) querryMKeyInfo:(onQueryMKeyCB)successCB failedBlock:(onErrorCB)failedCB;


/**
 *	@brief	导入密钥
 *
 *	@param 	keyData 	导入密钥的数据
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) loadKey:(LFC_LoadKey *)keyData
    successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	等待刷、插卡
 *
 *  @param 	text        标题行
 *	@param 	timeout 	等待超时
 *	@param 	cardType 	卡类型
 *	@param 	moneyNum 	消费金额
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) waitingCard:(NSString *)text timeOut:(int)timeout CheckCardTp:(LDE_SUPPORTCARDTYPE)cardType moneyNum:(NSString*)moneyNum
        successBlock:(onLDE_CardTypeCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	等待刷、插卡,带过程消息，用于M15
 *
 *  @param 	text        标题行
 *	@param 	timeout 	等待超时
 *	@param 	cardType 	卡类型
 *	@param 	moneyNum 	消费金额
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) waitingCard:(NSString *)text timeOut:(int)timeout CheckCardTp:(LDE_SUPPORTCARDTYPE)cardType moneyNum:(NSString *)moneyNum successBlock:(onLDE_CardTypeCB)successCB progressMsg:(onNSStringCB)onMsg failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	获取PAN
 *
 *	@param 	isCipher 	是否加密
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) getPAN:(LDE_PANDATATYPE)isCipher successCB:(onNSStringCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	获取磁道信息
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) getTrackData:(LDE_TRACKTYPE)isEncrypt successCB:(onQueryTrackCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	获取密码
 *
 *	@param 	inputPIN 	输入密码的所需信息
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) inputPin:(LFC_GETPIN*)inputPIN
     successBlock:(onNSStringCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	添加AID
 *
 *	@param 	aid 	AID信息
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) AddAid:(NSString *)aid
   successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	添加公钥
 *
 *	@param 	pubKey 	公钥信息
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) addPubKey:(NSString *)pubKey
      successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	清空AID
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) clearAids:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	清空公钥
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) clearPubKey:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	开始PBOC交易
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) startPBOC:(LFC_EMVTradeInfo*) tradeInfo trackInfoSuccess:(onLFEMVProgressCB)trackInfoSuccess failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	继续PBOC交易
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) continuePBOC:(LFC_GETPIN*) tradeInfo successBlock:(onLFEMVStartCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	联机交易后请求数据
 *
 *	@param 	complete 	联机交易的信息
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) onlineDataProcess:(LFC_EMVOnlineData *)onLineData
              successBlock:(onEMVTradeResultCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	停止PBOC交易
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) PBOCStop:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	QPBOC消费
 *
 *	@param 	tradeInfo 	交易信息元素
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) QpbocPurchase:(LFC_EMVTradeInfo *)tradeInfo successBlock:(onEMVTradeResultCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	QPBOC取流水
 *
 *	@param 	recordId 	流水记录号
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) QpbocGetOneRecord:(Byte)recordId successBlock:(onQPBOCReadRecord)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	QPBOC删除流水
 *
 *	@param 	recordType 	流水
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) QpbocDelOneRecord:(LDE_QPBOCRECORDTYPE)recordType successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	QPBOC读取流水个数
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) QpbocGetRecordNums:(onNSStringCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	QPBOC删除所有流水
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) QpbocDelAllRecords:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	计算MAC
 *
 *	@param 	macData 	需要计算的MAC数据
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) calculateMac:(NSString*)macData
         successBlock:(onNSStringCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	进入固件更新模式
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) enterFirmwareUpdateMode:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	开始固件更新
 *
 *	@param 	filePath 	固件存放的路径
 *	@param 	downloadCompleteCB 	下载固件完成回调
 *	@param 	downloadProgressCB 	固件更新进度回调
 *	@param 	downloadErrorCB 	固件更新失败回调
 *
 *	@return	void
 */
- (void) updateFirmware:(NSString*)filePath
          completeBlock:(onVoidCB)downloadCompleteCB
          progressBlock:(onDownloadProcessCB)downloadProgressCB
             errorBlock:(onDownloadErrCB)downloadErrorCB;
/**
 *	@brief	初始化打印机
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) resetPrinter:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	取打印机状态
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) getPrinterStatue:(onLDE_PrinterStatusCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	单行打印文本
 *
 *  @param 	text        打印的文本
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) printText:(NSString *)text successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	多联打印文本
 *
 *  @param 	times               几联
 *  @param 	printContent        打印的文本,每行为LDC_PrintLineStu对象
 *	@param 	successCB           成功回调
 *	@param 	failedCB            失败回调
 *
 *	@return	void
 */
- (void) printText:(OneByeInt)times withPrintContent:(NSArray *)printContent successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB ;

/**
 *	@brief	打印点阵图片
 *
 *  @param 	offsetDot            打印位置偏移
 *  @param 	dotHigh              点阵高度
 *  @param 	dotLength            点阵宽度
 *  @param 	printContent        打印点阵数据，点阵数据量在1.5K以内
 *	@param 	successCB           成功回调
 *	@param 	failedCB            失败回调
 *
 *	@return	void
 */
- (void) printDot:(int)offsetDot andDotHigh:(int)dotHigh andDotLength:(int)dotLength andDotData:(NSData *)dotData successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	打印BMP图片
 *
 *  @param 	offsetDot           打印位置偏移
 *  @param 	zoom                图片放大倍数
 *  @param 	printContent        BMP图片数据，数据量在1.5K以内
 *	@param 	successCB           成功回调
 *	@param 	failedCB            失败回调
 *
 *	@return	void
 */
- (void) printBmp:(int)offsetDot andZoom:(Byte)zoom andBmpData:(NSData*)bmpData successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	设置终端参数
 *
 *  @param 	terminalPara        终端参数
 *	@param 	successCB           成功回调
 *	@param 	failedCB            失败回调
 *
 *	@return	void
 */
-(void) setTerminalParam:(LDC_TerminalBasePara *)terminalPara successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief	获取终端参数
 *
 *	@param 	successCB           成功回调
 *	@param 	failedCB            失败回调
 *
 *	@return	void
 */
-(void) getTerminalParam:(onLDC_TerminalBaseParaCB)successCB failedBlock:(onErrorCB)failedCB;
/**
 *	@brief ICC1 下电
 *
 *	@param 	 apduCmd 	APDU指令
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) sendApduICC:(LDE_ICC_SLOT_TYPE) iccSlot withApduCmd:(NSString *)apduCmd successBlock:(onNSStringCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief ICC1 下电
 *
 *	@param 	 apduCmd 	APDU指令
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) powerUpICC:(LDE_ICC_SLOT_TYPE) iccSlot  successBlock:(onNSStringCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief ICC1 下电
 *
 *	@param 	 apduCmd 	APDU指令
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) powerDownICC:(LDE_ICC_SLOT_TYPE)iccSlot successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 显示二维码
 *
 *	@param 	 qrcode 	二维码
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) displayQrcode:(NSString*)qrcode timeOut:(Byte)timeOut successBlock:(onVoidCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 启动手写签名
 *
 *	@param 	specialCode 特征码
  *	@param 	timeOut 	超时
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) startUserSign:(NSString *)specialCode timeOut:(Byte)timeOut successBlock:(onNSStringCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 加密明文pin,仅对音频类无密码键盘设备
 *
 *	@param 	clearPin    明文的pin
 *	@param 	pan         卡号
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) encClearPIN:(NSString *)clearPin withPan:(NSString *)pan successBlock:(onNSStringCB)successCB failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 创建文件
 *
 *	@param 	fileName    文件名最大11个字符
 *	@param 	recordLen   记录长度
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) createFile:(NSString *)fileName
       andRecordLen:(int)recordLen
       successBlock:(onVoidCB)successCB
        failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 删除文件
 *
 *	@param 	fileName    文件名最大11个字符
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) DelFile:(NSString *)fileName
    successBlock:(onVoidCB)successCB
     failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 增加记录
 *
 *	@param 	fileName    文件名最大11个字符
 *	@param 	recordContent   记录长度
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) addFileRecord:(NSString *)fileName
             andRecord:(NSData *)recordContent
          successBlock:(onVoidCB)successCB
           failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 增加记录
 *
 *	@param 	fileName    文件名最大11个字符
 *	@param 	recordContent   记录长度
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) replaseFileRecord:(NSString *)fileName
             andRecordId:(int)recordId
             andRecord:(NSData *)recordContent
          successBlock:(onVoidCB)successCB
           failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 获取文件的记录个数
 *
 *	@param 	fileName    文件名最大11个字符
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) GetFileRecordNums:(NSString *)fileName
          successBlock:(onNSStringCB)successCB
           failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 删除文件记录
 *
 *	@param 	fileName    文件名最大11个字符
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) DelFileRecord:(NSString *)fileName
           andRecordId:(int)recordId
              successBlock:(onVoidCB)successCB
               failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 读取文件记录
 *
 *	@param 	fileName    文件名最大11个字符
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) GetFileRecord:(NSString *)fileName
           andRecordId:(int)recordId
          successBlock:(onNSDataCB)successCB
           failedBlock:(onErrorCB)failedCB;

/**
 *	@brief 激活M1卡
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) M1Active:(onActiveM1CardCB)successCB
          failedBlock:(onErrorCB)failedCB;

/**
 *	@brief M1卡片认证
 *
 *	@param 	key         认证密钥 6个字节 12个BCD字符
 *	@param 	blockNo   块号
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) M1Auth:(NSString *) key
          BlockNo:(Byte)blockNo
        WithKeyType:(LDE_M1KEYTYPE)keyType
          successCB:(onVoidCB)successCB
        failedBlock:(onErrorCB)failedCB;

/**
 *	@brief M1读取块数据
 *
 *	@param 	blockNo   块号
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) M1ReadBlock:(Byte)blockNo
               successCB:(onNSStringCB)successCB
             failedBlock:(onErrorCB)failedCB;

/**
 *	@brief M1写入块数据
 *
 *	@param 	blockData  块数据16个字节 32个BCD字符
 *	@param 	blockNo   块号
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) M1WriteBlock:(Byte)blockNo
                BlockData:(NSString *)blockData
                successCB:(onVoidCB)successCB
              failedBlock:(onErrorCB)failedCB;

/**
 *	@brief M1增量操作
 *
 *	@param 	data       加上的数值
 *	@param 	blockNo   块号
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) M1IncreBlock:(Byte)blockNo
                 WithData:(unsigned int)data
                successCB:(onVoidCB)successCB
              failedBlock:(onErrorCB)failedCB;

/**
 *	@brief M1减量操作
 *
 *	@param 	data       减去的数值
 *	@param 	blockNo   块号
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) M1DecreBlock:(Byte)blockNo
                 WithData:(unsigned int)data
                successCB:(onVoidCB)successCB
              failedBlock:(onErrorCB)failedCB;

/**
 *	@brief M1下电
 *
 *	@param 	successCB 	成功回调
 *	@param 	failedCB 	失败回调
 *
 *	@return	void
 */
- (void) M1CardPowerOff:(onVoidCB)successCB
                failedBlock:(onErrorCB)failedCB;
@end
