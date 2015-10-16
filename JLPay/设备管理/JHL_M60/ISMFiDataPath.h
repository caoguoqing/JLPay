//
//  ISMFiDataPath.h
//   深圳锦弘霖蓝牙模块
//
//  Created by  gjh 2015/03/10.
//
//


#import "ISDataPath.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface ISMFiDataPath : ISDataPath
@property (nonatomic,strong,readonly) NSString *protocolString;

- (void)setProtocolString:(NSString *)protocolString withAccessory:(EAAccessory *)accessory;

@end
