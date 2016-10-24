//
//  LMVC_logoutButton.h
//  CustomViewMaker
//
//  Created by jielian on 16/10/9.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMVC_logoutButton : UIButton

@property (nonatomic, assign) BOOL logined;

@property (nonatomic, strong) UILabel* iconLabel;

@property (nonatomic, strong) UILabel* logoutLabel;

@end
