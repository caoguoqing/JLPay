//
//  MaskView.m
//  JLPay
//
//  Created by jielian on 15/11/6.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "MaskView.h"
#import "ScannerImageView.h"


static CGFloat fHeightOfScannerView = 200.0;
static CGFloat fInset = 20.0;


@interface MaskView()
{
    CGFloat scannerViewWidth ;
    CGFloat scannerViewHeight;
}

@property (nonatomic, strong) ScannerImageView* scannerView; // 扫码框



@end



@implementation MaskView


/* 停止网格动画 */
- (void) stopImageAnimation {
    [self.scannerView stopImageAnimation];
}


#pragma mask ---- 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        scannerViewWidth = frame.size.width - fInset*2;
        scannerViewHeight = fHeightOfScannerView;
        // 重置frame
        CGFloat borderWidth = (frame.size.height - fHeightOfScannerView)/2.0;
        CGFloat actualWidth = frame.size.width - fInset*2 + borderWidth*2;
//        CGFloat x = -(borderWidth - fInset);
//        self.frame = CGRectMake(x, frame.origin.y, <#CGFloat width#>, <#CGFloat height#>)
        CGRect newFrame = frame;
        newFrame.origin.x = -(borderWidth - fInset);
        newFrame.size.width = actualWidth;
        self.frame = newFrame;
        
//        self.bounds = CGRectMake(0, 0, actualWidth, frame.size.height);
//        self.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
        
        // 边框
        self.layer.borderWidth = borderWidth;
        self.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;

        [self addSubview:self.scannerView];
    }
    return self;
}

#pragma mask ---- 加载子视图
- (void)layoutSubviews {
    
    CGRect frame = CGRectMake((self.bounds.size.width - scannerViewWidth)/2.0, (self.bounds.size.height - scannerViewHeight)/2.0, scannerViewWidth, scannerViewHeight);
    [self.scannerView setFrame:frame];
}


#pragma mask ---- getter
- (ScannerImageView *)scannerView {
    if (_scannerView == nil) {
        _scannerView = [[ScannerImageView alloc] initWithFrame:CGRectZero];
    }
    return _scannerView;
}

@end
