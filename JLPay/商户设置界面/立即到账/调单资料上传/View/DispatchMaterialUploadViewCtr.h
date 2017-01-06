//
//  DispatchMaterialUploadViewCtr.h
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD+CustomSate.h"
#import "VMDispatchUpload.h"

@class VMImgPicker;
@interface DispatchMaterialUploadViewCtr : UIViewController

@property (nonatomic, copy) VMDispatchUpload* dispatchUploader;

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) UIButton* uploadBtn;

@property (nonatomic, strong) VMImgPicker* imgPicker;



@end
