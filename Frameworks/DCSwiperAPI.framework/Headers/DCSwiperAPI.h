//
//  DCSwiperAPI.h
//  DCSwiperAPI
//
//  Created by dc on 16/1/6.
//  Copyright © 2016年 dc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define  ERROR_OK 0
#define  ERROR_FAIL_CONNECT_DEVICE 0x0001
#define  ERROR_FAIL_GET_KSN  0x0002
#define  ERROR_FAIL_READCARD 0x0003
#define  ERROR_FAIL_ENCRYPTPIN 0x0004
#define  ERROR_FAIL_GETMAC     0x0005
#define  ERROR_FAIL_TIMEOUT   0x0006
#define  ERROR_FAIL_MCCARD   0x0007
#define  ERROR_FAIL_DATA          0x0008
#define  ERROR_FAIL_NEEDIC      0x0009

typedef enum
{
    STATE_ACTIVE = 0,
    STATE_IDLE = 1,
    STATE_BUSY = 2,
    STATE_UNACTIVE = -1
}DeviceBlueState;

typedef enum
{
    card_mc = 1,        //磁条卡
    card_ic = 2,        //IC卡
    card_all = 3        //银行卡
}cardType;              //银行卡类型

@protocol DCSwiperAPIDelegate <NSObject>

@optional


//扫描设备结果
-(void)onFindBlueDevice:(NSDictionary *)dic;


//连接设备结果
-(void)onDidConnectBlueDevice:(NSDictionary *)dic;


//失去连接到设备
-(void)onDisconnectBlueDevice:(NSDictionary *)dic;


//读取ksn结果
-(void)onDidGetDeviceKsn:(NSDictionary *)dic;

//更新主密钥回调
-(void)onDidUpdateMasterKey:(int)retCode;

//更新工作密钥回调
-(void)onDidUpdateKey:(int)retCode;

-(void)onDetectCard;

//读取卡信息结果
-(void)onDidReadCardInfo:(NSDictionary *)dic;



//加密Pin结果
-(void)onEncryptPinBlock:(NSString *)encPINblock;


//mac计算结果
-(void)onDidGetMac:(NSString *)strmac;


-(void)onResponse:(int)type :(int)status;

//取消交易
-(void)onDidCancelCard;

@end


@interface DCSwiperAPI : NSObject
{
    int intDeviceBlueState;
}

@property(nonatomic) id<DCSwiperAPIDelegate> delegate;
@property (nonatomic) BOOL isConnectBlue;
@property (nonatomic, retain) NSDictionary *dicCurrect;
@property(nonatomic) cardType  currentCardType;

/*
 SDK初始化
 */
+(instancetype)shareInstance;


/*
 搜索蓝牙设备
 */
-(void)scanBlueDevice;


/*
 停止扫描蓝牙
 */
-(void)stopScanBlueDevice;

/*
 连接蓝牙设备
 */

-(BOOL)connectBlueDevice:(NSDictionary *)dic;

/*
 断开蓝牙设备
 */
-(void)disConnect;

/*
 获取ksn编号,
 */

-(void)getDeviceKsn;

/*
 写入主密钥
 */
-(void)updateMasterKey:(NSString *)key;


/*
 写入工作密钥
 密钥指：签到之后，后台下发的三组
 PINKey、（32位密钥 + 8位checkValue = 40位）
 MACKey) （16位密钥 + 8位checkValue = 24位）
 */

-(void)updateKey:(NSDictionary *)keyDic;


/*
 (读磁条卡、IC卡需使用同一接口，app代码无需做刷卡类型区分。
 需返回数据：
 1. 磁卡：卡号（明）、track2（密）、track3（可选）等
 2.IC卡：卡号（明）、track2（密）、track3（可选）、IC卡标识、icdata（55)
 type:消费类型
        2: 消费
        3: 撤销
        4: 查余
 */

-(void)readCard:(int)type  money:(double)dbmoney;


/*
 加密pin
 */
-(void)encryptPin:(NSString *)Pin;


/*
 计算mac
 (消费与查余额时 macdata 位数不同，所以接口对于传入参数的位数最好不要做限制，​若有需要，sdk自行补位）
 */
-(void)getMacValue:(NSString *)data;


//取消交易
-(void)cancelCard;


@end
