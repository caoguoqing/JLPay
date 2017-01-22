//
//  Smit.h
//  smitsdk
//
//  Created by smit on 15/7/14.
//  Copyright (c) 2015年 smit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

enum{
    SMIT_TASK_NONE=0x00,
    SMIT_TASK_CONNECT_BY_BLUETOOTH,
    SMIT_TASK_CONNECT_BY_AUDIO,

    SMIT_MSG_TYPE_MPOS = 0x1000,
    SMIT_MSG_TYPE_SERVER,
    SMIT_MSG_TYPE_ERROR,
    SMIT_MSG_TYPE_NONE,      // 在通用请求中使用，用于区分是否在通用函数中找到对应的msgType
    
    //mpos type
    SMIT_MSG_TYPE_MPOS_GET_RAND = 0x2000,
    SMIT_MSG_TYPE_MPOS_EXTERNAL_AUTH,
    SMIT_MSG_TYPE_MPOS_DEVICE_INFO,
    SMIT_MSG_TYPE_MPOS_FIRMWARE_INFO,
    SMIT_MSG_TYPE_MPOS_FIRMWARE_STM32_INFO,
    SMIT_MSG_TYPE_MPOS_FIRMWARE_THK88_INFO,
    SMIT_MSG_TYPE_MPOS_READ_MAG,
    SMIT_MSG_TYPE_MPOS_SYNC_WKEY,
    SMIT_MSG_TYPE_MPOS_GET_PIN_INFO,
    SMIT_MSG_TYPE_MPOS_READ_IC,
    SMIT_MSG_TYPE_MPOS_READ_BLUETOOTH_VERSION,
    SMIT_MSG_TYPE_MPOS_CANCEL_TRADE,
    SMIT_MSG_TYPE_MPOS_READ_MAG_IC,
    SMIT_MSG_TYPE_MPOS_READ_MAG_TIMEOUT,
    SMIT_MSG_TYPE_MPOS_READ_MAG_ERROR,
    SMIT_MSG_TYPE_MPOS_READ_IC_ERROR,
    
    
    //external mpos type
    SMIT_MSG_TYPE_EX_DP_CLEAR_SCREEN = 0x2200,
    SMIT_MSG_TYPE_EX_DP_SET_DISPLAY_MODE,
    SMIT_MSG_TYPE_EX_DP_SET_REFRESH_MODE,
    SMIT_MSG_TYPE_EX_DP_SET_CURSOR_POSITION,
    SMIT_MSG_TYPE_EX_DP_GET_CURSOR_POSITION,
    SMIT_MSG_TYPE_EX_DP_GET_LCD_ATTRIBUTE,
    SMIT_MSG_TYPE_EX_DP_DISPLAY_BITMAP,
    SMIT_MSG_TYPE_EX_DP_DRAW_HORIZONTAL_LINE,
    SMIT_MSG_TYPE_EX_DP_DRAW_RECTANGLE,
    SMIT_MSG_TYPE_EX_DP_REFRESH,
    SMIT_MSG_TYPE_EX_DP_SET_BACKLIGHT,
    SMIT_MSG_TYPE_EX_DP_GET_FONT_SIZE,
    SMIT_MSG_TYPE_EX_DP_SET_FONT_COLOUR,
    SMIT_MSG_TYPE_EX_DP_DISPLAY_STRING,
    SMIT_MSG_TYPE_EX_DP_DISPLAY_BATTERY_LEVEL,
    
    SMIT_MSG_TYPE_EX_KEY_VALUE_WITHOUT_TIMEOUT,
    SMIT_MSG_TYPE_EX_KEY_VALUE_WITH_TIMEOUT,
    SMIT_MSG_TYPE_EX_KEY_INPUT_STRING,
    SMIT_MSG_TYPE_EX_FILE_OPEN,
    SMIT_MSG_TYPE_EX_FILE_CLOSE,
    SMIT_MSG_TYPE_EX_FILE_READ,
    SMIT_MSG_TYPE_EX_FILE_WRITE,
    SMIT_MSG_TYPE_EX_FILE_MOVE_RECORD_POINTER,
    SMIT_MSG_TYPE_EX_FILE_GET_LENGTH,
    SMIT_MSG_TYPE_EX_FILE_DELETE,
    SMIT_MSG_TYPE_EX_FILE_WHETHER_EXIST,
    SMIT_MSG_TYPE_EX_FILE_RENAME,
    SMIT_MSG_TYPE_EX_FILE_GET_RECORD_POSITION,
    SMIT_MSG_TYPE_EX_FILE_GET_USAGE_STATE,
    
    SMIT_MSG_TYPE_EX_MAG_OPEN,
    SMIT_MSG_TYPE_EX_MAG_CLOSE,
    SMIT_MSG_TYPE_EX_MAG_READ_ASYMMETRIC,
    SMIT_MSG_TYPE_EX_MAG_READ_AUTHENTICATION,
    SMIT_MSG_TYPE_EX_MAG_READ_SYMMETRIC,
    
    SMIT_MSG_TYPE_EX_IC_SET_TYPE,
    SMIT_MSG_TYPE_EX_IC_CHECK,
    SMIT_MSG_TYPE_EX_IC_POWER_ON,
    SMIT_MSG_TYPE_EX_IC_POWER_OFF,
    SMIT_MSG_TYPE_EX_IC_COMMUNICATION,
    
    SMIT_MSG_TYPE_EX_NFC_SET_TYPE,
    SMIT_MSG_TYPE_EX_NFC_POWER_ON,
    SMIT_MSG_TYPE_EX_NFC_POWER_OFF,
    SMIT_MSG_TYPE_EX_NFC_COMMUNICATION,
    
    SMIT_MSG_TYPE_EX_SR_READ_DEVICE_INFO,
    SMIT_MSG_TYPE_EX_SR_GET_RANDOM,
    SMIT_MSG_TYPE_EX_SR_DEVICE_AUTH,
    SMIT_MSG_TYPE_EX_SR_UPDATE_PUBKEY_ONLINE,
    SMIT_MSG_TYPE_EX_SR_EXTERNAL_AUTH,
    SMIT_MSG_TYPE_EX_SR_UPDATE_SECRET_KEY,
    SMIT_MSG_TYPE_EX_SR_FILL_PUBLIC_KEY,
    SMIT_MSG_TYPE_EX_SR_CREATE_SECRET_KEY,
    SMIT_MSG_TYPE_EX_SR_WRITE_DEVICE_INFO,
    
    SMIT_MSG_TYPE_EX_PW_INPUT_SYMMETRIC,
    SMIT_MSG_TYPE_EX_PW_LOAD_MAIN_KEY,
    SMIT_MSG_TYPE_EX_PW_ENCRYPT_DECRYPT,
    SMIT_MSG_TYPE_EX_PW_CALCULATE_MAC,
    SMIT_MSG_TYPE_EX_PW_LOAD_WORK_KEY,
    SMIT_MSG_TYPE_EX_PW_INPUT_RSA,
    SMIT_MSG_TYPE_EX_PW_INPUT_TWO_CLASS,
    
    SMIT_MSG_TYPE_EX_PRINT_INITIALIZATION,
    SMIT_MSG_TYPE_EX_PRINT_GET_STATUS,
    SMIT_MSG_TYPE_EX_PRINT_PAPER_FEED,
    SMIT_MSG_TYPE_EX_PRINT_SET_FONT_LIBRARY,
    SMIT_MSG_TYPE_EX_PRINT_SET_VERTICAL_SPACING,
    SMIT_MSG_TYPE_EX_PRINT_SET_CONCENTRATION,
    SMIT_MSG_TYPE_EX_PRINT_SET_FONT,
    SMIT_MSG_TYPE_EX_PRINT,
    
    SMIT_MSG_TYPE_EX_PBOC_SET_PUBLIC_KEY,
    SMIT_MSG_TYPE_EX_PBOC_SET_AID,
    SMIT_MSG_TYPE_EX_PBOC_SET_TRADE_ATTRIBUTE,
    SMIT_MSG_TYPE_EX_PBOC_SET_SIMPLE_PROCESS,
    SMIT_MSG_TYPE_EX_PBOC_SET_STANDARD_PROCESS,
    SMIT_MSG_TYPE_EX_PBOC_SET_SECOND_AUTH,
    SMIT_MSG_TYPE_EX_PBOC_QPBOC_PROCESS,
    SMIT_MSG_TYPE_EX_PBOC_GET_FIELD_DATA,
    
    SMIT_MSG_TYPE_EX_TM_BEEPER,
    SMIT_MSG_TYPE_EX_TM_LED_FLASHING,
    SMIT_MSG_TYPE_EX_TM_SCAN,
    SMIT_MSG_TYPE_EX_TM_SET_TIME_DATE,
    SMIT_MSG_TYPE_EX_TM_GET_TIME_DATE,
    SMIT_MSG_TYPE_EX_TM_SET_PARAMETER,
    SMIT_MSG_TYPE_EX_TM_GET_PARAMETER,
    SMIT_MSG_TYPE_EX_TM_CANCEL_RESET,  // 2252
    SMIT_MSG_TYPE_EX_TM_GET_FIRMWARE_INFO,
    
    SMIT_MSG_TYPE_EX_DECRYPT_TRACK_DATA,
    SMIT_MSG_TYPE_EX_ENCRYPT_PIN_DATA,
    SMIT_MSG_TYPE_EX_ENCRYPT_PIN_WITH_PAN,
    
    SMIT_MSG_TYPE_CD_SEND_DATA,
    SMIT_MSG_TYPE_CD_CHAR_STATUS,
    SMIT_MSG_TYPE_CD_CURSOR_STATUS,
    SMIT_MSG_TYPE_CD_CURSOR_MOVE,
    SMIT_MSG_TYPE_CD_INIT,
    SMIT_MSG_TYPE_CD_CLEAR,
    SMIT_MSG_TYPE_CD_CURSOR_CLEAR,
    
    SMIT_MSG_TYPE_EX_MAG_REOPEN,// new add
    SMIT_MSG_TYPE_EX_INPUT_PIN,// new add
    SMIT_MSG_TYPE_EX_UPLOAD_PIN,// new add
    SMIT_MSG_TYPE_EX_INPUT_PIN_CANCEL,// new add
    SMIT_MSG_TYPE_EX_TIMEOUT,// new add
    SMIT_MSG_TYPE_READ_ALL_CARD,//new add
    SMIT_MSG_TYPE_SMKEY_ENCRYPT_DATA,//new add
    SMIT_MSG_TYPE_UPDATE_PUBLIC_KEY_ONLINE,// new add
    SMIT_MSG_TYPE_GET_TSK,// new add
    SMIT_MSG_TYPE_UPDATE_MAIN_KEY,// new add
    SMIT_MSG_TYPE_DISPLAY_PAN,// new add
    SMIT_MSG_TYPE_KEY_DELETE,// new add
    
    //server type
    SMIT_MSG_TYPE_SERVER_LOGIN = 0x3000,
    SMIT_MSG_TYPE_SERVER_REGISTER,
    SMIT_MSG_TYPE_SERVER_FIND_PASSWORD,
    
    SMIT_MSG_TYPE_SERVER_DEVICE_AUTH,
    SMIT_MSG_TYPE_SERVER_GET_RANDOM,
    SMIT_MSG_TYPE_SERVER_EXTERNAL_AUTH,
    SMIT_MSG_TYPE_SERVER_UPDATE_KEY_ONLINE,
    
    SMIT_MSG_TYPE_SERVER_GET_PLATFORM_NUMBER,
    SMIT_MSG_TYPE_SERVER_CARD_CONSUME,
    SMIT_MSG_TYPE_SERVER_GET_RECORD_LIST,
    SMIT_MSG_TYPE_SERVER_GET_RECORD_DETAIL,
    SMIT_MSG_TYPE_SERVER_SIGNATURE,
    SMIT_MSG_TYPE_SERVER_RETURN_ICDATA,
    
    SMIT_MSG_TYPE_SERVER_GET_MSG_INFO,
    SMIT_MSG_TYPE_SERVER_GET_MSG_LIST,
    SMIT_MSG_TYPE_SERVER_MSG_MARK_AS_READ,
    
    SMIT_MSG_TYPE_SERVER_GET_UPDATE_STATUS,
    SMIT_MSG_TYPE_SERVER_UPDATE_FIRMWARE,
    
    SMIT_MSG_TYPE_SERVER_COMMODITY_ADD,
    SMIT_MSG_TYPE_SERVER_COMMODITY_DELETE,
    SMIT_MSG_TYPE_SERVER_COMMODITY_MODIFY,
    SMIT_MSG_TYPE_SERVER_COMMODITY_SEARCH,
    SMIT_MSG_TYPE_SERVER_COMMODITY_GET_ALL,
    SMIT_MSG_TYPE_SERVER_COMMODITY_INFO,
    
    SMIT_MSG_TYPE_SERVER_UPLOAD,
    SMIT_MSG_TYPE_SERVER_UPLOAD_FINISH,
    SMIT_MSG_TYPE_SERVER_DOWNLOAD_REQUEST,
    SMIT_MSG_TYPE_SERVER_DOWNLOAD,
    
    SMIT_MSG_TYPE_SERVER_VERIFY_CODE,
    SMIT_MSG_TYPE_SERVER_AMOUNTS_AND_RATES,
    SMIT_MSG_TYPE_SERVER_UPDATE_PASSWORD,
    SMIT_MSG_TYPE_SERVER_DELETE_FILE,
    SMIT_MSG_TYPE_SERVER_GET_HELP,
    SMIT_MSG_TYPE_SERVER_GET_LINK,
    SMIT_MSG_TYPE_SERVER_GET_MY_INFO,
    SMIT_MSG_TYPE_SERVER_UPDATE_PHOTO,
    SMIT_MSG_TYPE_SERVER_DEVICE_AUTH_COMMON,
    SMIT_MSG_TYPE_SERVER_GET_DEVICES,
    SMIT_MSG_TYPE_SERVER_BIND_DEVICE,
    SMIT_MSG_TYPE_SERVER_UNBIND_DEVICE,
    
    //all type
    SMIT_MSG_TYPE_LOGIN = 0x4000,
    SMIT_MSG_TYPE_DEVICE_INFO,
    SMIT_MSG_TYPE_EXTERNAL_AUTH,
    SMIT_MSG_TYPE_DEVICE_AUTH,
    SMIT_MSG_TYPE_SYNC_WKEY,
    SMIT_MSG_TYPE_READ_MAG,
    SMIT_MSG_TYPE_GET_PIN_INFO,
    SMIT_MSG_TYPE_READ_IC,
    SMIT_MSG_TYPE_GET_IC_PIN,
    SMIT_MSG_TYPE_CONSUME_ONLINE,
    SMIT_MSG_TYPE_CONSUME_SIGNATURE,
    
    SMIT_MSG_TYPE_CANCEL_TRADE,
    SMIT_MSG_TYPE_TRADE_TIMEOUT,
    SMIT_MSG_TYPE_TRADE_ERROR,
    
    SMIT_MSG_TYPE_IC_BACK_DATA,
    SMIT_MSG_TYPE_GET_FIRMWARE_INFO,
    SMIT_MSG_TYPE_UPDATE_FIRMWARE,
    SMIT_MSG_TYPE_UPDATE_SCHEDULE,
    SMIT_MSG_TYPE_SYNC_WKEY_FROM_SERVER,
    SMIT_MSG_TYPE_READ_CARD,
    SMIT_MSG_TYPE_GET_BUSINESS_LIB_VERSION,
    SMIT_MSG_TYPE_UPDATE_FIRMWARE_SET_STATUS,
    SMIT_MSG_TYPE_GET_DEVICE_VOLTAGE,
    SMIT_MSG_TYPE_READ_IC_PART_DATA,
    SMIT_MSG_TYPE_READ_IC_PIN_PAN,
    SMIT_MSG_TYPE_READ_FLASH_DATA,
    SMIT_MSG_TYPE_RESET_MPOS,
    SMIT_MSG_TYPE_GET_DOL_TAG_VALUE,
    
    //BBPOS
    SMIT_MSG_TYPE_BBPOS_DEVICE_INFO = 0x5000,
    SMIT_MSG_TYPE_BBPOS_AUTH,
    SMIT_MSG_TYPE_BBPOS_CHECK_CARD,
    SMIT_MSG_TYPE_BBPOS_START_EMV,
    SMIT_MSG_TYPE_BBPOS_SET_AMOUNT,
    SMIT_MSG_TYPE_BBPOS_CANCEL_SET_AMOUNT,
    SMIT_MSG_TYPE_BBPOS_CANCEL_SELECT_APPLICATION,
    SMIT_MSG_TYPE_BBPOS_START_PIN_ENTRY,
    SMIT_MSG_TYPE_BBPOS_BYPASS_PIN_ENTRY,
    SMIT_MSG_TYPE_BBPOS_SEND_PIN_ENTRY,
    SMIT_MSG_TYPE_BBPOS_CANCEL_PIN_ENTRY,
    SMIT_MSG_TYPE_BBPOS_SEND_FINAL_CONFIRM_RESULT,
    SMIT_MSG_TYPE_BBPOS_CANCEL_CHECK_CARD,
    SMIT_MSG_TYPE_BBPOS_SET_READ_CARD_MODE,
    SMIT_MSG_TYPE_BBPOS_SELECT_APPLICATION,
    SMIT_MSG_TYPE_BBPOS_GET_EMV_CARD_DATA,
    SMIT_MSG_TYPE_BBPOS_GET_EMV_CARD_NUMBER,
    SMIT_MSG_TYPE_BBPOS_GET_MAGSTRIPE_CARD_NUMBER,
    SMIT_MSG_TYPE_BBPOS_ENCRYPT_DATA,
    
    // xuelianbao Bluetooth mpos
    SMIT_MSG_TYPE_XLCARD_EXTERNAL_AUTH = 0x6000,
    SMIT_MSG_TYPE_XLCARD_DEVICE_AUTH,
    SMIT_MSG_TYPE_XLCARD_GET_TSK,
    SMIT_MSG_TYPE_XLCARD_READ_GAS_CARD,
    SMIT_MSG_TYPE_XLCARD_WRITE_GAS_CARD,
    SMIT_MSG_TYPE_XLCARD_VERIFY_GAS_CARD,
    SMIT_MSG_TYPE_XLCARD_GET_RANDOM,
    SMIT_MSG_TYPE_XLCARD_SYNC_AUTH_KEY,
    SMIT_MSG_TYPE_XLCARD_DETECT_GAS_CARD,
    
    SMIT_MSG_TYPE_XLBUSCARD_INIT,
    SMIT_MSG_TYPE_XLBUSCARD_RECORD_QUERY,
    SMIT_MSG_TYPE_XLBUSCARD_CHECK,
    SMIT_MSG_TYPE_XLBUSCARD_RECHARGE_REQUEST,
    SMIT_MSG_TYPE_XLBUSCARD_RECHARGE,
    SMIT_MSG_TYPE_XLBUSCARD_SET_COMMUNICATION_TYPE,
    
    
    // 其他类型命令
    SMIT_MSG_TYPE_CASHIER_DESK_SET_AMOUNT = 0x7000,
    SMIT_MSG_TYPE_CASHIER_DESK_SET_CHARACTER,
    SMIT_MSG_TYPE_CASHIER_DESK_CLEAR,
};

enum{
    SMIT_CODE_SUCCESS=0x00,
    SMIT_CODE_FAIL,
    SMIT_CODE_PARAM_ERROR,
    SMIT_CODE_NOT_CONNECTED,
    SMIT_CODE_TIMEOUT,
    SMIT_CODE_TRADE_ERROR,
    SMIT_CODE_CANCELED,
};

enum{
    SMIT_DEVICE_TYPE_OLD=0x00,
    SMIT_DEVICE_TYPE_NEW,
};

enum{
    SMIT_ENCRYPT_MODE_PLAIN=0x00,
    SMIT_ENCRYPT_MODE_FIXED,
    SMIT_ENCRYPT_MODE_DYNAMIC,
};
enum{
    SMIT_COMMUNICATION_MODE_NONE=0x00,
    SMIT_COMMUNICATION_MODE_BLUETOOTH,
    SMIT_COMMUNICATION_MODE_AUDIO,
};
enum{
    SMIT_WORK_MODE_ALL = 0x01,
    SMIT_WORK_MODE_BBPOS,            //兼容BBPOS接口模式
    SMIT_WORK_MODE_3RD,              //第三方模式
    SMIT_WORK_MODE_EX_MPOS,
    SMIT_TEST_MODE_EX_MPOS,
    SMIT_WORK_MODE_ONLY_MPOS,
    SMIT_WORK_MODE_ONLY_SERVER,
    SMIT_WORK_MODE_XLCARD,
};

enum{
    SMIT_AUTH_TYPE_AUTO = 0x00,
    SMIT_AUTH_TYPE_MANUAL,
};

enum{
    SMIT_CARD_TYPE_MAG = 1,
    SMIT_CARD_TYPE_IC=2,
    SMIT_CARD_TYPE_NFC=3
};



@protocol SmitDelegate <NSObject>

@optional
-(void)onFoundDevice:(NSDictionary*)device all:(NSArray*)devices;
-(void)onScanFinished:(NSArray*)devices;
-(void)onDeviceConnected;
-(void)onDeviceDisconnected;
-(void)onResponse:(int)msgType data:(id)data code:(int)code frame:(NSString*)frame;
-(void)onConnectFailed;
-(void)headsetPluggIn;
-(void)headsetPullOut;
@end

@protocol SmitDeviceDelegate <NSObject>

@optional
-(void)onBTConnected;
@end

@interface Smit : NSObject

@property (nonatomic,strong) id<SmitDelegate> delegate;
@property (nonatomic,strong) id<SmitDeviceDelegate> smitDeviceDelegate;
@property (nonatomic,assign) BOOL isConnected;



-(id)initWithData:(NSString*)initData;

-(id)initWithEncryptMode:(int)encryptMode key:(NSString*)key;
-(id)initWithEncryptMode:(int)encryptMode key:(NSString*)key workMode:(int)workMode ;
-(id)initWithEncryptMode:(int)encryptMode key:(NSString*)key workMode:(int)workMode authType:(int)authType;
-(id)initWithEncryptMode:(int)encryptMode key:(NSString*)key workMode:(int)workMode authType:(int)authType  isNewProtocol:(BOOL)newProtocol;
-(void)setEncryptMode:(int)encrypteMode key:(NSString*)key;
-(void)setDeviceType:(int)deviceType;
-(void)scan;
-(void)scan:(int)timeout;
-(void)stopScan;
-(void) connect:(NSDictionary*)device;
-(void) connectPeripheral:(CBPeripheral*)peripheral;
/**
 *  Is bluetooth connected
 *
 *  @return YES:connected,NO:havn't connected.
 */
-(BOOL)isBTConnect;
-(void)disconnect;
-(NSString*)exec:(int) msgType params: (NSString*) params;


-(void)initAudio;
-(int)startAudio;
-(int)stopAudio;
-(void) connectByAudio;
-(BOOL)hasHeadset;
-(void)adjustVolume:(float)volume;

-(NSString*)getVersion;


-(NSString*)decryptData:(NSString*)data withKey:(NSString*)key;

-(void)setWriteGap:(double)writeGap;
-(void)setFrameSize:(int)frameSize;

-(void)setReRequest:(BOOL)isReRequest delay:(double)delay timeout:(NSTimeInterval)timeout;
@end