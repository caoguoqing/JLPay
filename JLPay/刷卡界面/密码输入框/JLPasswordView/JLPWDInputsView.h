//
//  JLPWDInputsView.h
//  TestForJLPasswordView
//
//  Created by jielian on 16/8/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLPWDInputsView : UIView

@property (nonatomic, strong) UIButton* sureBtn;

@property (nonatomic, strong) UIButton* cancelBtn;

@property (nonatomic, strong) UILabel* titleLabel;

@property (nonatomic, strong) UIView* seperatedLine1;

@property (nonatomic, strong) UIView* seperatedLine2;

@property (nonatomic, strong) UIView* seperatedLine3;

@property (nonatomic, strong) NSArray* pinLabels;

@property (nonatomic, copy) NSString* pinInputs;


@end
