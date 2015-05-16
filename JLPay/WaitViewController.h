//
//  WaitViewController.h
//  JLPay
//
//  Created by jielian on 15/4/17.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitViewController : UIViewController
{
    NSTimer *countDownTimer;
    int secondsCountDown;
    
    UILabel *timeLab;
    
    UIView *backView;
    UIView *falseView;
}
@property(nonatomic,retain)NSString *errorString;
@property(nonatomic,assign)int resultType;

@property(nonatomic,strong)NSString *pinstr;

@end
