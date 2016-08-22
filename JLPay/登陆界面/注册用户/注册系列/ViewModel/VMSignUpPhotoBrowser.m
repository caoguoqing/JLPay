//
//  VMSignUpPhotoBrowser.m
//  JLPay
//
//  Created by jielian on 16/7/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMSignUpPhotoBrowser.h"

@implementation VMSignUpPhotoBrowser

- (instancetype)initWithPhoto:(UIImage *)image {
    self = [super init];
    if (self) {
        self.photoBrowsered = image;
    }
    return self;
}

- (void)showWithDone:(browserDone)done orDelete:(browserDelete)deleteBlock {
    self.doneBlock = done;
    self.deleteBlock = deleteBlock;
    
    [self.superVC presentViewController:self.photoBrowserVC animated:YES completion:^{
        
    }];
}


# pragma mask 2 AJPhotoBrowserDelegate
- (void)photoBrowser:(AJPhotoBrowserViewController *)vc deleteWithIndex:(NSInteger)index {
    if (self.deleteBlock) {
        self.deleteBlock(index);
    }
    [self.photoBrowserVC dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)photoBrowser:(AJPhotoBrowserViewController *)vc didDonePhotos:(NSArray *)photos {
    if (self.doneBlock) {
        self.doneBlock();
    }
    [self.photoBrowserVC dismissViewControllerAnimated:YES completion:^{
        
    }];
}



# pragma mask 4 getter

- (AJPhotoBrowserViewController *)photoBrowserVC {
    if (!_photoBrowserVC) {
        _photoBrowserVC = [[AJPhotoBrowserViewController alloc] initWithPhotos:@[self.photoBrowsered]];
        _photoBrowserVC.delegate = self;
    }
    return _photoBrowserVC;
}

@end
