//
//  JLActivitor.h
//  JLPay
//
//  Created by jielian on 15/8/24.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLActivitor : UIView
+ (JLActivitor*) sharedInstance ;
- (BOOL) isAnimating;
- (void) startAnimating;
- (void) stopAnimating;
@end
