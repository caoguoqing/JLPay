//
//  VMImgPicker.h
//  JLPay
//
//  Created by jielian on 16/5/24.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DispatchMaterialUploadViewCtr.h"

@interface VMImgPicker : NSObject
<UIImagePickerControllerDelegate, UIActionSheetDelegate>

- (void) pickImgOnHandleViewC:(DispatchMaterialUploadViewCtr*)handleViewC
                   OnFinished:(void (^) (NSArray* imgs))finished
                     onCancel:(void (^) (void))cancelBlock;


# pragma mask : private

@property (nonatomic, strong) UIImagePickerController* imgPickerVCtr;

@property (nonatomic, strong) NSMutableArray* imgListPicked;

@property (nonatomic, weak) DispatchMaterialUploadViewCtr* handleViewCtr;

@property (nonatomic, copy) void (^ finishedBlock) (NSArray* imgs);

@property (nonatomic, copy) void (^ cancelBlock) (void);

@end
