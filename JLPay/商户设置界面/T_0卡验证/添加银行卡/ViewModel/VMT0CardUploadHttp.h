//
//  MT0CardUploadHttp.h
//  JLPay
//
//  Created by jielian on 16/7/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class RACCommand;

@interface VMT0CardUploadHttp : NSObject

@property (nonatomic, copy) NSString* cardType;

@property (nonatomic, copy) NSString* userName;

@property (nonatomic, copy) NSString* cardNo;

@property (nonatomic, copy) NSString* userId;

@property (nonatomic, copy) NSString* mobilePhone;

@property (nonatomic, copy) UIImage* imageUploaded;

@property (nonatomic, strong) RACCommand* cmdUploading;

@end
