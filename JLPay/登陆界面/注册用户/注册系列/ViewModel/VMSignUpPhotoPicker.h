//
//  VMSignUpPhotoPicker.h
//  JLPay
//
//  Created by jielian on 16/7/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD+CustomSate.h"

@class RACSignal;

@interface VMSignUpPhotoPicker : NSObject <UIImagePickerControllerDelegate>


- (instancetype)initWithViewController:(UIViewController*)viewController;       /* 初始化 */

@property (nonatomic, strong) RACSignal* sigPhotoPicking;                       /* 执行拍照的信号 */

@property (nonatomic, weak) UIViewController* superVC;


# pragma mask : private properties

@property (nonatomic, strong) UIImagePickerController* imgPickerVC;


@property (nonatomic, copy) void (^ pickedImage) (UIImage* image);

@end
