//
//  VMSignUpPhotoPicker.m
//  JLPay
//
//  Created by jielian on 16/7/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMSignUpPhotoPicker.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>

@implementation VMSignUpPhotoPicker

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.superVC = viewController;
    }
    return self;
}

- (void)pickingOnFinished:(void (^)(UIImage *))finishedPicking {
    self.pickedImage = finishedPicking;
    
    NameWeakSelf(wself);
    [self.superVC.view addSubview:self.progressHud];
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] ||
        [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.progressHud showNormalWithText:nil andDetailText:nil];
        });
        [self.superVC presentViewController:wself.imgPickerVC animated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.progressHud hideOnCompletion:^{
                    [wself.progressHud removeFromSuperview];
                }];
            });

        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.progressHud showWarnWithText:@"相机无法拍照,请排查故障!" andDetailText:nil onCompletion:^{
                if (wself.pickedImage) {
                    wself.pickedImage(nil);
                }
                [wself.progressHud removeFromSuperview];
            }];
        });
    }
}

# pragma mask 2 UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (self.pickedImage) {
        self.pickedImage(image);
    }
    [self.imgPickerVC dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.pickedImage) {
        self.pickedImage(nil);
    }
    [self.imgPickerVC dismissViewControllerAnimated:YES completion:^{
        
    }];
}


# pragma mask 4 getter

- (RACSignal *)sigPhotoPicking {
    if (!_sigPhotoPicking) {
        @weakify(self);
        _sigPhotoPicking = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self pickingOnFinished:^(UIImage *imagePicked) {
                [subscriber sendNext:imagePicked];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }
    return _sigPhotoPicking;
}

- (UIImagePickerController *)imgPickerVC {
    if (!_imgPickerVC) {
        _imgPickerVC = [[UIImagePickerController alloc] init];
        _imgPickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imgPickerVC.delegate = self;
    }
    return _imgPickerVC;
}

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.superVC.view];
        
    }
    return _progressHud;
}



@end
