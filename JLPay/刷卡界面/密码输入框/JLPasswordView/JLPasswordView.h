//
//  JLPasswordView.h
//  TestForJLPasswordView
//
//  Created by jielian on 16/8/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLPasswordView : UIViewController


+ (void) showAfterClickedSure:(void (^) (NSString* password))sureBlock
                     orCancel:(void (^) (void))cancelBlock;


@end
