//
//  VMDispatchUpload.h
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HTTPInstance.h"

@class RACCommand;
@class MDispatchOrderDetail;

@interface VMDispatchUpload : NSObject
<UITableViewDelegate, UITableViewDataSource>

- (void) modelsOnRACCommands ;

@property (nonatomic, strong) MDispatchOrderDetail* originDispatchDetail;

@property (nonatomic, strong) RACCommand* commandDispatchUpload;

@property (nonatomic, strong) RACCommand* commandImgPicker;

@property (nonatomic, strong) NSArray* titlesOfCell;

@property (nonatomic, assign) NSInteger imgCount;
@property (nonatomic, strong) NSMutableArray* imagesPicked;
@property (nonatomic, copy) UIImage* signedImage;

@property (nonatomic, strong) HTTPInstance* httpUpload;

@property (nonatomic, copy) void (^ pushQianPiVCBlock) (UIViewController* viewC);

@end
