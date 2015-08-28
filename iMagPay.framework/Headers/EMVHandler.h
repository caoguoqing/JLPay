//
//  EMVHandler.h
//  Version 1.4.5
//

#import <string.h>
#import "SwipeHandler.h"
#import "Settings.h"
#import "EMVListener.h"
#import "EMVParam.h"

@interface EMVHandler:SwipeHandler {
    id<EMVListener> mEMVDelegete;
}

@property(nonatomic, retain) id<EMVListener> mEMVListener;

-(void)setShowAPDU:(BOOL)showAPDU;

-(BOOL)isShowAPDU;

-(BOOL)isRunning;

-(void)cancel;

-(int)getStatus;

-(void)setMessage:(NSString*)msg;
-(NSString*)getMessage;

-(int)emvProcess:(EMVParam*)param;

-(NSString*)icReset;

-(int)process;

-(void)icOff;

-(void)setTLVData:(unsigned short)tag :(NSString*)data;

-(NSString*)getTLVData:(unsigned short)tag;

-(NSString*)getScriptResult;

-(int)onSelectApp:(NSMutableArray*)apps;

-(BOOL)onReadData;

-(NSString*)onReadPin:(PIN_TYPE)type :(int)ucPinTryCnt;

-(EMVResponse*)onSubmitData;

-(void)onConfirmData;

-(void)onReversalData;
//V3.3 Add by zhengwei.2015.7.16
//返回55域,必须包含0x9F03
-(NSString *)getIcField55;
//返回指定TAG的55域
-(NSString *)getIcField55:(unsigned short[])tags;
//IC卡序列号
-(NSString *)getIcSeq;
//IC卡Pan
-(NSString *)getIcPan;
//IC卡2磁道
-(NSString *)getICTrack2Data;

-(NSString *)getICEncryptedTrack2Data;

-(BOOL)isAutoRead;

-(void)setAutoRead:(BOOL)isAutoRead;
//失效日期
-(NSString *)getIcExpDate;
//生效日期
-(NSString *)getIcEffDate;
//V3.3 Add end
@end