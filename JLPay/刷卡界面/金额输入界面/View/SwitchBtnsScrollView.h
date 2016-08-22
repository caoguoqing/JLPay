//
//  SwitchBtnsScrollView.h
//  JLPay
//
//  Created by jielian on 16/7/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString* const SwitchBtnsSwipe = @"刷卡交易";
static NSString* const SwitchBtnsAlipay = @"支付宝消费";
static NSString* const SwitchBtnsWechat = @"微信消费";


@interface SwitchBtnsScrollView : UIScrollView

- (void) switchToPage:(NSInteger)page;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) NSMutableArray* switchItemBtns;               /* 切换按钮组 */

@end
