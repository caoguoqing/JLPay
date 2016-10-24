//
//  DeviceConnectViewController.h
//  JLPay
//
//  Created by jielian on 16/9/5.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceConnectViewController : UIViewController

- (instancetype) initWithConnected:(void (^) (void))connectedBlock
                        orCanceled:(void (^) (void))canceledBlock;

@end
