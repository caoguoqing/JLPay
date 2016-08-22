//
//  VMSignUpManager.h
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSignUpDataSource.h"
#import <UIKit/UIKit.h>

@class HTTPInstance;
@class RACSignal;
@class RACCommand;
@class VMSignUpPhotoPicker;
@class VMSignUpPhotoBrowser;
@class VMPhoneChecking;
@class VMSignUpHttpRequest;

@interface VMSignUpManager : NSObject <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

+ (instancetype) sharedInstance;

/* 重置数据源 */
- (void) resetDataSource;

/* 生成新的cmd给'下一步'按钮 */
- (RACCommand*) newCommandForInputsCheckingOnCurIndex;

@property (nonatomic, weak) UIViewController* superVC;                  /* vm对应的ViewC: 用于加载子选项界面 */

@property (nonatomic, assign) NSInteger seperatedIndex;                 /* 对应注册界面的分离步骤 */

@property (nonatomic, strong) MSignUpDataSource* signUpInputs;          /* 数据源: 外部仅读取 */

# pragma mask : 响应点击事件的信号

@property (nonatomic, strong) RACSignal* sigChooseArea;                 /* 省市选择信号 */

@property (nonatomic, strong) RACSignal* sigTakePhoto;                  /* 拍照信号 */

@property (nonatomic, strong) RACSignal* sigChooseBank;                 /* 银行选择 */

@property (nonatomic, strong) RACSignal* sigChooseBankBranch;           /* 选择银行分支行 */

# pragma mask : private properties

@property (nonatomic, strong) VMSignUpHttpRequest* signUpHttpRequest;   /* 注册http */

@property (nonatomic, strong) VMSignUpPhotoPicker* photoPicker;         /* 照片采集器 */

@property (nonatomic, strong) VMSignUpPhotoBrowser* photoBrowser;       /* 照片浏览器 */

@property (nonatomic, strong) VMPhoneChecking* phoneChecking;           /* 手机验证 */



@end
