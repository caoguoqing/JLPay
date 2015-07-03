//
//  ISDataPath.m
//   深圳锦弘霖蓝牙模块
//
//  Created by  gjh 2015/03/10.
//
//

#import "ISDataPath.h"

@implementation ISDataPath
- (id)init {
    self = [super init];
    if (self) {
        [self internalInit];
    }
    return self;
}

- (void)internalInit {
    
}

- (BOOL)openSession {
    return YES;
}

- (void)closeSession {
    
}

- (NSUInteger)readBytesAvailable {
    return 0;
}

- (NSData *)readData:(NSUInteger)bytesToRead {
    return nil;
}

- (void)writeData:(NSData *)data {
    
}

@end
