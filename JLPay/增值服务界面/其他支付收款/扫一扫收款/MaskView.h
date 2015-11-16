//
//  MaskView.h
//  JLPay
//
//  Created by jielian on 15/11/6.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaskView : UIView

/* 动效 */
- (BOOL) isImageAnimating;

/* 启动网格动画 */
- (void) startImageAnimation;

/* 停止网格动画 */
- (void) stopImageAnimation;

/* 获取摄入框的size */
- (CGSize) sizeOfScannerView;

@end
