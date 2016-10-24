//
//  ChangePinViewController.h
//  JLPay
//
//  Created by jielian on 15/8/5.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePinViewController : UIViewController

- (instancetype) initWithChangeFinished:(void (^) (void))finishedBlock
                             orCanceled:(void (^) (void))canceledBlock;

@end
