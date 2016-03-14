//
//  PullListSegView.h
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullListSegView : UIView

@property (nonatomic, strong) UIColor* tintColor;       // 背景色
@property (nonatomic, strong) UIColor* textColor;       // 字体颜色

@property (nonatomic, strong) UITableView* tableView;

- (void) showAnimation;
- (void) hiddenAnimation;

- (void) showWithCompletion:(void (^) (void))completion;
- (void) hideWithCompletion:(void (^) (void))completion;

@end
