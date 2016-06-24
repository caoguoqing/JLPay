//
//  VMImgPicker.m
//  JLPay
//
//  Created by jielian on 16/5/24.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMImgPicker.h"
#import "Define_Header.h"

@implementation VMImgPicker

- (void)dealloc {
    JLPrint(@"----------VMImgPicker dealloc---------");
}


- (void) pickImgOnHandleViewC:(DispatchMaterialUploadViewCtr*)handleViewC
                   OnFinished:(void (^) (NSArray* imgs))finished
                     onCancel:(void (^) (void))cancelBlock
{
    [self.imgListPicked removeAllObjects]; // 清空当前的图片组
    self.finishedBlock = finished;
    self.cancelBlock = cancelBlock;
    self.handleViewCtr = handleViewC;
    
    // 弹出选择框
    UIActionSheet* actSheet = [[UIActionSheet alloc] initWithTitle:@"上传调单资料" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"拍照", nil];
    [actSheet showFromTabBar:handleViewC.tabBarController.tabBar];
}



# pragma mask 2 UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"取消"]) {
        if (self.cancelBlock) self.cancelBlock();
    }
    else if ([title isEqualToString:@"从相册选择"]) {
        self.imgPickerVCtr.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self showImgPicker];
    }
    else if ([title isEqualToString:@"拍照"]) {
        self.imgPickerVCtr.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self showImgPicker];
    }
}


# pragma mask 2 UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    [self.imgListPicked addObject:image];
    [self dismissImgPickerAfterPicked];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self.imgListPicked addObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [self dismissImgPickerAfterPicked];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissImgPickerAfterCanceled];
}





# pragma mask 3 action
- (void) showImgPicker {
    [self.handleViewCtr.progressHud showNormalWithText:@"" andDetailText:@""];
    NameWeakSelf(wself);
    [self.handleViewCtr presentViewController:self.imgPickerVCtr animated:YES completion:^{
        [wself.handleViewCtr.progressHud hide:YES];
    }];
}
- (void) dismissImgPickerAfterPicked {
    NameWeakSelf(wself);
    [self.imgPickerVCtr dismissViewControllerAnimated:YES completion:^{
        if (wself.finishedBlock) wself.finishedBlock(wself.imgListPicked);
    }];
}
- (void) dismissImgPickerAfterCanceled {
    NameWeakSelf(wself);
    [self.imgPickerVCtr dismissViewControllerAnimated:YES completion:^{
        if (wself.cancelBlock) wself.cancelBlock();
    }];
}

# pragma mask 4 getter
- (UIImagePickerController *)imgPickerVCtr {
    if (!_imgPickerVCtr) {
        _imgPickerVCtr = [[UIImagePickerController alloc] init];
        _imgPickerVCtr.delegate = self;
    }
    return _imgPickerVCtr;
}

- (NSMutableArray *)imgListPicked {
    if (!_imgListPicked) {
        _imgListPicked = [NSMutableArray array];
    }
    return _imgListPicked;
}

@end
