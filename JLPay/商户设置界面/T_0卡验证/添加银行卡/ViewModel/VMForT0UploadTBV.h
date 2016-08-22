//
//  VMForT0UploadTBV.h
//  JLPay
//
//  Created by jielian on 16/7/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UITableView.h>
#import "MT0CardUploadItems.h"
#import "VMSignUpPhotoPicker.h"
#import "VMSignUpPhotoBrowser.h"



@interface VMForT0UploadTBV : NSObject <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) UIViewController* superVC;

@property (nonatomic, copy) NSString* cardType;

@property (nonatomic, copy) NSString* cardNo;

@property (nonatomic, copy) NSString* userName;

@property (nonatomic, copy) NSString* userId;

@property (nonatomic, copy) NSString* mobilePhone;

@property (nonatomic, copy) UIImage* imagePicked;


@property (nonatomic, strong) MT0CardUploadItems* items;

@property (nonatomic, strong) VMSignUpPhotoPicker* photoPicker;         /* 照片采集器 */

@property (nonatomic, strong) VMSignUpPhotoBrowser* photoBrowser;       /* 照片浏览器 */


@end
