//
//  NewVersionView.m
//  SchoolChat
//
//  Created by work on 14-6-4.
//  Copyright (c) 2014年 ggwl. All rights reserved.
//

#import "NewVersionView.h"
#import "PublicInformation.h"

@implementation NewVersionView

@synthesize informInfo;
@synthesize informationLab;
@synthesize requireBtn;
@synthesize closedBtn;
@synthesize backVi;
@synthesize passwordStr;
@synthesize passwordBtn;


- (id)initWithFrame:(CGRect)frame info:(NSString *)information textHidden:(BOOL)hidden
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha=0.8;
        self.backgroundColor=[UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1.0];
        
        backVi=[[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width-280)/2, (self.bounds.size.height-160)/2, 280, 180)];
        backVi.backgroundColor=[UIColor blackColor];
        backVi.layer.cornerRadius=6;
        backVi.layer.masksToBounds = YES;
        [self addSubview:backVi];
        
        informInfo=[[UILabel alloc] initWithFrame:CGRectMake(5, 5, 270, 30)];
        informInfo.font=[UIFont systemFontOfSize:18.0f];
        informInfo.text=@"提示";
        informInfo.textColor=[UIColor whiteColor];
        informInfo.backgroundColor=[UIColor clearColor];
        //informInfo.textColor=[UIColor colorWithRed:0.30 green:0.49 blue:0.74 alpha:1.0];
        informInfo.textAlignment=NSTextAlignmentLeft;
        [backVi addSubview:informInfo];
        
        informationLab=[[UILabel alloc] initWithFrame:CGRectMake(10, 40, 250, 30)];
        informationLab.font=[UIFont systemFontOfSize:17.0f];
        informationLab.backgroundColor=[UIColor clearColor];
        informationLab.textAlignment=NSTextAlignmentLeft;
        informationLab.text=information;
        informationLab.numberOfLines=0;
        [backVi addSubview:informationLab];
        informationLab.textColor=[UIColor whiteColor];
        
        passwordBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        passwordBtn.frame=CGRectMake(0, 80, 280, 40);
        [passwordBtn setBackgroundImage:[PublicInformation createImageWithColor:[UIColor colorWithRed:0.95 green:0.97 blue:0.99 alpha:1.0]] forState:UIControlStateNormal];
        passwordBtn.layer.borderColor=[UIColor colorWithRed:0.98 green:0.54 blue:0.03 alpha:1.0].CGColor;
        passwordBtn.layer.borderWidth=3.0f;
        passwordBtn.layer.cornerRadius=6;
        passwordBtn.layer.masksToBounds = YES;
        [backVi addSubview:passwordBtn];
        
        passwordStr=[[UITextField alloc] initWithFrame:CGRectMake(2, 2, 276, 36)];
        passwordStr.font=[UIFont systemFontOfSize:20.0f];
        //[passwordStr becomeFirstResponder];
        passwordStr.text=@"";
        passwordStr.secureTextEntry=YES;
        passwordStr.autocapitalizationType = UITextAutocapitalizationTypeNone;
        passwordStr.returnKeyType = UIReturnKeyDone;
        passwordStr.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        passwordStr.textAlignment=NSTextAlignmentLeft;
        passwordStr.borderStyle = UITextBorderStyleNone;
        //passwordStr.keyboardType=UIKeyboardTypeNumberPad;
        passwordStr.clearButtonMode = UITextFieldViewModeAlways;
        [passwordBtn addSubview:passwordStr];
        
        if (hidden) {
           passwordBtn.frame=CGRectMake(0, 0, 0, 0);
            passwordBtn.hidden=YES;
            passwordStr.hidden=YES;
        }else{
          passwordBtn.frame=CGRectMake(0, 80, 280, 40);
            passwordBtn.hidden=NO;
            passwordStr.hidden=NO;
        }//(0, 80, 280, 40)
        
        requireBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        requireBtn.frame=CGRectMake(5, 80+passwordBtn.frame.size.height+10, 265/2, 40);
        [requireBtn setBackgroundImage:[PublicInformation createImageWithColor:[UIColor colorWithRed:0.95 green:0.97 blue:0.99 alpha:1.0]] forState:UIControlStateNormal];
        [requireBtn setTitle:@"确定" forState:UIControlStateNormal];
        [requireBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [requireBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0f]];
        [backVi addSubview:requireBtn];
        
        closedBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        closedBtn.frame=CGRectMake(265/2+10, 80+passwordBtn.frame.size.height+10, 265/2, 40);
        [closedBtn setBackgroundImage:[PublicInformation createImageWithColor:[UIColor colorWithRed:0.95 green:0.97 blue:0.99 alpha:1.0]] forState:UIControlStateNormal];
        [closedBtn setTitle:@"取消" forState:UIControlStateNormal];
        [closedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [closedBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0f]];
//        [photoBtn addTarget:self action:@selector(photoMethod) forControlEvents:UIControlEventTouchUpInside];
        [backVi addSubview:closedBtn];
        backVi.frame=CGRectMake((self.bounds.size.width-280)/2, (self.bounds.size.height-(80+passwordBtn.frame.size.height+10+40+10))/2, 280, 80+passwordBtn.frame.size.height+10+40+10);
    }
    return self;
}

-(void)refresh{
    informInfo.textAlignment=NSTextAlignmentCenter;
    informationLab.textAlignment=NSTextAlignmentCenter;
    requireBtn.frame=CGRectMake((280-265/2)/2, 80+passwordBtn.frame.size.height+10, 265/2, 40);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
