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
@property (nonatomic, strong) UILabel* labelNotice;

@end



@implementation MaskView

/* 启动网格动画 */
- (void) startImageAnimation {
    [self.scannerView startImageAnimation];
}
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
        CGRect newFrame = frame;
        newFrame.origin.x = -(borderWidth - fInset);
        newFrame.size.width = actualWidth;
        self.frame = newFrame;

        // 边框
        self.layer.borderWidth = borderWidth;
        self.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor;

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
        _labelNotice.font = [UIFont systemFontOfSize:13];
    }
    return _labelNotice;
}

@end
