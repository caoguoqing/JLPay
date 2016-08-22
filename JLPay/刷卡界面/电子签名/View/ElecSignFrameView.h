//
//  ElecSignFrameView.h
//  JLPay
//
//  Created by jielian on 16/7/25.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ElecSignView.h"

@interface ElecSignFrameView : UIView

@property (nonatomic, strong) UILabel* keyElementLabel;

@property (nonatomic, strong) ElecSignView* elecSignView;

@end
