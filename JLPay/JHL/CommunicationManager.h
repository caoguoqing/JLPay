//
//  CommunicationManagerBase.h
//
//
//

#import <Foundation/Foundation.h>
#import "CommunicationCallBack.h"

@interface CommunicationManager : NSObject
+(CommunicationManager*)sharedInstance;
+(NSString*)getLibVersion;
// 设备插拔实时监测
-(void)startDetecting;
-(void)stopDetecting;

-(int)openDevice;
-(int)exchangeData:(NSData*)data timeout:(long)timeout cb:(id<CommunicationCallBack>) cb;
-(int)cancelExchange;
-(void)closeDevice;
-(void)closeResource;
-(BOOL)isConnected;
@end
