//
//  VMSignUpPhotoBrowser.h
//  JLPay
//
//  Created by jielian on 16/7/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AJPhotoBrowserViewController.h"


@interface VMSignUpPhotoBrowser : NSObject <AJPhotoBrowserDelegate>

typedef void (^ browserDone) (void);                                            /* 完成 */
typedef void (^ browserDelete) (NSInteger index);                               /* 删除 */


- (instancetype) initWithPhoto:(UIImage*)image;

/* 显示照片;并回调 */
- (void) showWithDone:(browserDone)done orDelete:(browserDelete)deleteBlock;

@property (nonatomic, weak) UIViewController* superVC;



# pragma mask : private properties

@property (nonatomic, copy) UIImage* photoBrowsered;


@property (nonatomic, strong) AJPhotoBrowserViewController* photoBrowserVC;

@property (nonatomic, copy) browserDone doneBlock;
@property (nonatomic, copy) browserDelete deleteBlock;


@end
