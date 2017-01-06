//
//  SmitTY.h
//  SMPay
//
//  Created by smit on 16/4/26.
//  Copyright © 2016年 smit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Smit.h"
enum{
    DEVICE_STATUS_NONE_LIB=0,
    AUDIO_DEVICE_IN_LIB=1,
    AUDIO_DEVICE_OUT_LIB=2,
    BLE_POWER_OFF_LIB=3,
    BLE_DEVICE_SCAN_LIB=4,
    BLE_DEVICE_CONNECT_LIB=5,
    BLE_DEVICE_DISCONNECT_LIB=6
};


@protocol SmitTYDelegate <NSObject>

@optional
/**
 *  返回扫描到的蓝牙设备
 *
 *  @param device 蓝牙设备
 */
- (void)onDiscoverDevice:(CBPeripheral*)device;
/**
 *  设备已连接回调
 *
 *  @param isSuccess YES表示已连接
 */
- (void)onConnectedDevice:(BOOL)isSuccess;
/**
 *  设备断开回调
 *
 *  @param isSuccess YES表示已断开
 */
- (void)onDisConnectedDevice:(BOOL)isSuccess;

-(void)onResponse:(int)msgType data:(id)data code:(int)code;
-(void)onConnectFailed;
/**
 *  返回设备SN
 *
 *  @param sn 设备sn号
 */
- (void)onReceiveDeviceSN:(NSString *)sn;
/**
 *  获取刷卡后返回的数据
 *
 *  @param data NSDictionary 中包含：
 errorCode：错误码
 cardType：00磁条卡  01 IC卡
 cardNo：卡号
 trace2：二磁道明文
 trace3: 三磁道明文
 encTrace2: 二磁道密文
 encTrace3: 三磁道密文
 expiryData: 卡片有效期
 icSeq：IC卡序列号（IC卡）
 icData：IC卡55域数据报文（IC卡）
 encPpin：卡片加密密码（此key是带键盘MPOS返回，无键盘此字断不存在或者无值）
 */
- (void)onReadCard:(NSDictionary *)data;


/**
 *  返回确认交易结果
 *
 *  @param isSuccess 是否成功
 */
- (void)onConfirmTransaction:(BOOL)isSuccess;


/**
 *  获取用MACkey加密后的数据
 *
 *  @param mac 8字节的加密数据
 */
- (void)onGetMacWithMKIndex:(NSString *)mac;


/**
 *  是否成功更新密钥
 *
 *  @param isSuccess 是否成功更新工作密钥,成功：1，失败：0
 */
- (void)onUpdateWorkingKey:(NSArray *)isSuccess;


/**
 *  设备PINBlock结果
 *
 *  @param block  NSDictionary 结构数据
 *  status :  状态码
 *  en_pin :  PinBlock密文
 */
- (void)onPinBlock:(NSDictionary *)block;

@end


@interface SmitTY : NSObject
/**
 *  Scan bluetooth device
 */
-(void)scan;
/**
 *  Stop scan bluetooth device
 */
-(void)stopScan;

/**
 *  连接设备,可通过回调接口onConnectedDevice获取连接结果
 *
 *  @param device 蓝牙为设备名,其他为NULL
 *
 *  @return 无
 */
-(BOOL)connectDevice:(NSString *)device;
/**
 *  断开设备
 */
- (void)disconnectDevice;
/**
 *  是否已连接设备
 *
 *  @return 连接状态
 */
- (int)isConnected;

/**
 *  返回API版本信息
 *
 *  @return API版本信息
 */
- (NSString *)getVersion;
/**
 *  取消当前操作
 */
- (void)cancel;


/**
 *  更新工作密钥（磁道密钥、密码密钥、mac密钥三组密钥）.可通过回调接口onUpdateWorkingKey获取更新工作密钥结果
 *
 *  @param TDK 磁道工作密钥密文，20字节(16+4)，nil表示不用写入，当密钥为单倍长8+4时，将前八个字节复制一遍拼成16，然后+4.
 *  @param PIK PIN工作密钥密文，20字节，nil表示不用写入，当密钥为单倍长8+4时，将前八个字节复制一遍拼成16，然后+4.
 *  @param MAK MAC工作密钥密文，20字节，nil表示不用写入，当密钥为单倍长8+4时，将前八个字节复制一遍拼成16，然后+4.(mac补8字节0，然后加4位校验码)
 *
 *  @return NSArray 按参数顺序返回更新是否成功结果 1表示成功，0表示不成功
 */
- (NSArray *)updateWorkingKey:(NSString *)TDK PIK:(NSString *)PIK MAK:(NSString *)MAK;
/**
 *  获取外部读卡器设备SN号.回调onReceiveDeviceSN
 *
 *  @return SN号
 */
- (NSString *)getDeviceSN;

/**
 *  计算mac.可通过回调接口onGetMacWithMKIndex获取计算的结果
 *
 *  @param MKIndex 密钥索引，保留，暂未使用
 *  @param message 用于计算mac的数据
 *
 *  @return Mac值以及随机数
 */
- (NSDictionary *)getMacWithMKIndex:(int)MKIndex Message:(NSString *)message;

/**
 *  刷卡
 *
 *  @param amount       金额 注：传入金额的时候注意不要传小数点，如果想要传1.50则写入"150"
 *  @param tradeType    交易类型 (例如：0x00 代表消费，0x31代表查询余额)
 *  @param swipeTimeOut 交易超时时间
 *
 *  @return 无,通过回调接口onReadCard获取刷卡返回结果
 */
- (NSDictionary *)readCard:(NSString *)amount
                 TradeType:(Byte)tradeType
                   timeout:(int)swipeTimeOut;


/**
 *  无键盘蓝牙刷卡头计算PinBlock，并接收设备返回数据
 *
 *  @param type        PIN Block格式(P1)
                       0 :请求带主账号的PIN Block
                       1 :请求不带主账号的PIN Block
                       2 :自定义 PIN Block格式
 *  @param random      0~16字节随机数，固件不支持随机数则传nil
 *  @param pinBlockStr 传入的密码
 *
 *  @return 设备PINBlock结果.回调onPinBlock:Random:
 */
- (NSDictionary *)getEncPinblock:(NSInteger)type
                          Random:(NSString *)random
                      SourceData:(NSString *)pinBlockStr;



/**
 *  标准接触 IC 卡交易响应处理
 *
 *  @param data (14 字节长度的字符串,“响应码” +“发卡行认证数据” )
 *
 *  @return 回调onConfirmTransaction
 */
- (BOOL)confirmTradeResponse:(NSData *)data;


@property (nonatomic,strong) id<SmitTYDelegate> delegate;
@property (nonatomic,strong) Smit* smit;
@end
