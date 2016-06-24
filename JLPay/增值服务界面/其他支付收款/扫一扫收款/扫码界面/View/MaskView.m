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
    BOOL animating;
}

@property (nonatomic, strong) ScannerImageView* scannerView; // 扫码框
@property (nonatomic, strong) UILabel* labelNotice;

@end



@implementation MaskView

/* 启动网格动画 */
- (void) startImageAnimation {
    if (!animating) {
        [self.scannerView startImageAnimation];
        animating = YES;
    }
}
/* 停止网格动画 */
- (void) stopImageAnimation {
    if (animating) {
        [self.scannerView stopImageAnimation];
        animating = NO;
    }
}

/* 动效 */
- (BOOL) isImageAnimating {
    return animating;
}

/* 获取摄入框的size */
- (CGSize) sizeOfScannerView {
    CGSize size = CGSizeMake(0, 0);
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    size.width = screenW - fInset*2;
    size.height = fHeightOfScannerView;
    return size;
}


#pragma mask ---- 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        animating = NO;
        scannerViewWidth = frame.size.width - fInset*2;
        scannerViewHeight = fHeightOfScannerView;
        // 重置frame
        CGFloat borderWidth = (frame.size.height - fHeightOfScannerView)/2.0;
        CGFloat actualWidth = frame.size.width - fInset*2 + borderWidth*2;
        CGRect newFrame = frame;
        newFrame.origin.x = -(borderWidth - fInset);
        newFrame.origin.y = 0;
        newFrame.size.width = actualWidth;

        // 边框
        UIView* backView = [[UIView alloc] initWithFrame:newFrame];
        backView.layer.borderWidth = borderWidth;
        backView.layer.borderColor = [UIColor colorWithWhite:0.05 alpha:0.7].CGColor;
        [self addSubview:backView];

        // 加载扫描框
        newFrame.origin.x = (self.bounds.size.width - scannerViewWidth)/2.0;
        newFrame.origin.y = (self.bounds.size.height - scannerViewHeight)/2.0;
        newFrame.size.width = scannerViewWidth;
        newFrame.size.height = scannerViewHeight;
        [self.scannerView setFrame:newFrame];
        [self addSubview:self.scannerView];
        
        // 加载提示标签
        newFrame.origin.x -= fInset;
        newFrame.origin.y += newFrame.size.height + fInset;
        newFrame.size.width = frame.size.width;
        newFrame.size.height = 15;
        [self.labelNotice setFrame:newFrame];
        [self addSubview:self.labelNotice];
        [self bringSubviewToFront:self.labelNotice];
    }
    return self;
}

#pragma mask ---- 加载子视图
- (void)layoutSubviews {
    CGRect frame = CGRectMake((self.bounds.size.width - scannerViewWidth)/2.0,
                              (self.bounds.size.height - scannerViewHeight)/2.0,
                              scannerViewWidth,
                              scannerViewHeight);
    [self.scannerView setFrame:frame];
}


#pragma mask ---- getter
- (ScannerImageView *)scannerView {
    if (_scannerView == nil) {
        _scannerView = [[ScannerImageView alloc] initWithFrame:CGRectZero];
    }
    return _scannerView;
}
- (UILabel *)labelNotice {
    if (_labelNotice == nil) {
        _labelNotice = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelNotice.text = @"将条形码放入扫描框内，即可自动扫描";
        _labelNotice.textColor = [UIColor whiteColor];
        _labelNotice.textAlignment = NSTextAlignmentCenter;
        _labelNotice.font = [UIFont systemFontOfSize:16];
    }
    return _labelNotice;
}

@end
