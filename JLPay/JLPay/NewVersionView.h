//
//  NewVersionView.h
//  SchoolChat
//
//  Created by work on 14-6-4.
//  Copyright (c) 2014年 ggwl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewVersionView : UIView

@property(nonatomic,retain)UIView *backVi;
@property(nonatomic,retain)UILabel *informInfo;
@property(nonatomic,retain)UILabel *informationLab;
@property(nonatomic,retain)UIButton *requireBtn;
@property(nonatomic,retain)UIButton *closedBtn;

@property(nonatomic,retain)UITextField *passwordStr;
@property(nonatomic,retain)UIButton *passwordBtn;

- (id)initWithFrame:(CGRect)frame info:(NSString *)information textHidden:(BOOL)hidden;

-(void)refresh;
@end
