//
//  ISControlManager.h
//   深圳锦弘霖蓝牙模块
//
//  Created by  gjh 2015/03/10.
//
//


#import <Foundation/Foundation.h>
typedef enum {
  ISControlManagerTypeEA,
  ISControlManagerTypeCB
}ISControlManagerType;

#define Print_log    0x01
#define SUCESS       0x00
#define FAILD        0x01
#define Revice_MAX_LEN 1024
#define BLUE_MAX_PACKET_SIZE_EP  126  

#define MAIN_KEY_ID  0x01
#define PIN_KEY_ID   0x02
#define TRACK_KEY_ID 0x03
#define MACK_KEY_ID  0x04
#define TRACK_ENCRY_MODEM  0x01  //加密模式

#define GETCARD_CMD  0x12
#define GETTRACK_CMD 0x20
#define GETTRACKDATA_CMD 0x22  //0xE1  用户取消  0xE2 超时退出 E3 IC卡数据处理失败 0xE4 无IC卡参数 0xE5 交易终止 0xE6 操作失败,请重试

#define CHECK_IC    0x24  
#define MAINKEY_CMD  0x34       // 设置主密钥
#define PINBLOCK_CMD 0x36       // 获取密文密钥
#define GETMAC_CMD   0x37       // 获取MAC
#define WORKKEY_CMD  0x38       // 写工作密钥
#define GETSNVERSION 0x40       // 读取SV号
#define GETTERNUMBER 0x41       // 读取终端号
#define WRITETERNUMBER   0x42   // 写终端号
#define YY_GETTRACK_CMD 0xff

#define WriteAidParm   0x33  //AID
#define ClearAidParm   0x3A  //清空AID
#define WriteCpkParm   0x32  //公钥
#define ClearCpkParm   0x39  //清空公钥
#define ProofIcParm    0x23   //二次论证I卡数据
#define BATTERY        0x45   //获取电池电量

#define IC_STATUS      0x13   //判断卡片知否在位
#define IC_SOPEN       0x14   //IC卡打开上电
#define IC_SCLOSE      0x15   //关闭IC卡
#define IC_SWRITE      0x16   //发送APUD

#define MAmount  0x00
//默认超时时间15秒
#define WAIT_TIMEOUT 15

//磁道加密算法，0表示银联标准的只加密后8字节，1/2表示不包含长度补0/F组成8的倍数据加密，3/4表示包含长度补0/F组成8的倍数据加密，5表示尤银特殊加密）
#define TRACK_ENCRY_MODEM   0x04

//密码加密，0表示标准主账号异或加密，1表示不带主账号加密，2尤银特殊加密
#define PASSWORD_ENCRY_MODEM 0x00
#define TRACK_ENCRY_DATA  0x00 //0x00 标准数据回应 0x01 多包数据回应




typedef struct
{
    int iCardtype;				//刷卡卡类型  磁条卡 IC卡
    int iCardmodem;				//刷卡模式
    char TrackPAN[21];				//域2	主帐号
    unsigned char CardValid[5];				//域14	卡有效期
    char szServiceCode[4];			//服务代码
    unsigned char CardSeq[2];				//域23	卡片序列号
    unsigned char szEntryMode[3];			//域22	服务点输入方式
    int      nTrack2Len;                    //2磁道数据大小
    unsigned char szTrack2[40];				//域35	磁道2数据
    int      nEncryTrack2Len;                   //2磁道加密数据大小
    unsigned char szEncryTrack2[40];			//域35	磁道2加密数据	第一个字节为长度
    int      nTrack3Len;                    //3磁道数据大小
    unsigned char szTrack3[108];			//域36	磁道3数据
    int      nEncryTrack3Len;                    //3加密磁道数据大小
    unsigned char szEncryTrack3[108];			//域36	磁道3加密数据
    unsigned char sPIN[13];					//域52	个人标识数据(pind ata)
    int      IccdataLen;
    unsigned char Field55Iccdata[300];			//的55域信息512->300
    unsigned char szAmount[12];			//12个字节金额ASCII码 例如 1元=303030303030303030313030
    int      YyEncrydataLen;
    unsigned char FieldEncrydata[300];			//随机加密数据 //针对客户
    
}FieldTrackData;


typedef struct{
    unsigned char AppName[33];       //本地应用名，以'\x00'结尾的字符串
    unsigned char AID[17];           //应用标志
    unsigned char AidLen;            //AID的长度
    unsigned char SelFlag;           //选择标志( 部分匹配/全匹配)
    unsigned char Priority;          //优先级标志
    unsigned char TargetPer;         //目标百分比数
    unsigned char MaxTargetPer;      //最大目标百分比数
    unsigned char FloorLimitCheck;   //是否检查最低限额
    unsigned char RandTransSel;      //是否进行随机交易选择
    unsigned char VelocityCheck;     //是否进行频度检测
    unsigned long FloorLimit;        //最低限额
    unsigned long Threshold;         //阀值
    unsigned char TACDenial[6];      //终端行为代码(拒绝)
    unsigned char TACOnline[6];      //终端行为代码(联机)
    unsigned char TACDefault[6];     //终端行为代码(缺省)
    unsigned char AcquierId[7];      //收单行标志
    unsigned char dDOL[256];         //终端缺省DDOL   len+data
    unsigned char tDOL[256];         //终端缺省TDOL   len+data
    unsigned char Version[3];        //应用版本
    unsigned char RiskManData[10];   //风险管理数据   len+data
    unsigned char EC_bTermLimitCheck;      //是否支持终端交易限额
    unsigned long EC_TermLimit;            //终端交易限额，
    unsigned char CL_bStatusCheck;         //是否支持qPBOC状态检查
    unsigned long CL_FloorLimit;        //非接触终端最低限额
    unsigned long CL_TransLimit;        //非接触终端交易限额
    unsigned long CL_CVMLimit;          //非接触终端CVM限
    unsigned char TermQuali_byte2;      //交易金额与每个AID限额的判断结果，在刷卡前处理，通过此变量缓存判断结果
}EMV_APPLIST;

typedef struct {
    unsigned char RID[5];            //应用注册服务商ID
    unsigned char KeyID;             //密钥索引
    unsigned char HashInd;           //HASH算法标志
    unsigned char ArithInd;          //RSA算法标志
    unsigned char ModulLen;          //模长度
    unsigned char Modul[248];        //模
    unsigned char ExponentLen;       //指数长度
    unsigned char Exponent[3];       //指数
    unsigned char ExpDate[3];        //有效期(YYMMDD)
    unsigned char CheckSum[20];      //密钥校验和
}EMV_CAPK;

@protocol ISControlManagerDelegate;
@protocol ISControlManagerDeviceList;
@class ISDataPath;

@interface ISControlManager : NSObject
@property (assign,nonatomic,getter = isConnect) BOOL connect;
@property (strong,nonatomic,readonly) NSArray *connectedAccessory;
@property (assign) id<ISControlManagerDelegate> delegate;
@property (assign) id<ISControlManagerDeviceList> deviceList;

- (void)scanDeviceList:(ISControlManagerType)type;
- (void)connectDevice:(ISDataPath *)device;
- (void)disconnectDevice:(ISDataPath *)device;
- (void)disconnectAllDevices;
- (void)stopScaning;
- (void)writeData:(NSData *)data;
- (void)writeData:(NSData *)data withAccessory:(ISDataPath *)accessory;
- (void)cancelWriteData;
+ (id)sharedInstance;

@end

@protocol ISControlManagerDelegate<NSObject>
@optional
- (void)accessoryDidDisconnect;
- (void)accessoryDidConnect:(ISDataPath *)accessory;
- (void)accessoryDidReadData:(ISDataPath *)accessory data:(NSData *)data;
- (void)accessoryDidWriteData:(ISDataPath *)accessory bytes:(int)bytes complete:(BOOL)complete;
- (void)accessoryDidFailToWriteData:(ISDataPath *)accessory error:(NSError *)error;

@end

@protocol ISControlManagerDeviceList<NSObject>
- (void)didGetDeviceList:(NSArray *)devices andConnected:(NSArray *)connectList;
@end
