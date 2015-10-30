//
//  QRCodeButtonView.h
//  JLPay
//
//  Created by jielian on 15/10/30.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QRCodeButtonView;
@protocol QRCodeButtonViewDelegate <NSObject>
@required
/* 点击事件回调 */
- (void) didSelectedView:(QRCodeButtonView*)QRCodeView;
@end


@interface QRCodeButtonView : UIView

@property (nonatomic, weak) id<QRCodeButtonViewDelegate> delegate;

@property (nonatomic, strong) UIImage* image; // 图片
@property (nonatomic, assign) NSString* title; // 标题

@end
