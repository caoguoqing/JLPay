//
//  JLActivity.h
//  TestForCustomActivity
//
//  Created by jielian on 15/6/16.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLActivity : UIView

- (id) initWithFrame:(CGRect)frame;
- (BOOL) isAnimating;
- (void) startAnimating;
- (void) stopAnimating;

@end
