//
//  PosInformationViewController.m
//  PosN38Universal
//
//  Created by work on 14-9-15.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//
#define Screen_Height  [UIScreen mainScreen].bounds.size.height
#define Screen_Width  [UIScreen mainScreen].bounds.size.width

#import "PosInformationViewController.h"



@implementation PosInformationViewController





#pragma mask 0 界面布局
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.92 green:0.93 blue:0.98 alpha:1.0];
    self.title = @"POS-签购单";
    [self.navigationItem setRightBarButtonItem:self.doneBarBtn];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]]];
    
    [self loadsSubviews];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.tabBarController.tabBar.hidden = YES;

}

// 简化代码:label可以用同一个产出方式
- (UILabel*) newTextLabelWithText:(NSString*)text
                          inFrame:(CGRect)frame
                        alignment:(NSTextAlignment)textAlignment
                             font:(UIFont*)font
{
    UILabel* textLabel = [[UILabel alloc] initWithFrame:frame];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = text;
    textLabel.textAlignment = textAlignment;
    textLabel.textColor = [UIColor blackColor];
    textLabel.font = font;
    // 设置自动换行
    [textLabel setNumberOfLines:0];
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return textLabel;
}


# pragma mask 3 IBAction

- (IBAction) clickedOnHandleBtn:(UIButton*)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}





# pragma mask 3 布局

/* 布局 */
- (void) loadsSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    

    // 小字体
    UIFont* littleFont = [UIFont systemFontOfSize:10.f];
    NSDictionary* littleTextAttri = [NSDictionary dictionaryWithObject:littleFont forKey:NSFontAttributeName];
    // 中字体
    UIFont* midFont = [UIFont systemFontOfSize:17.f];
    NSDictionary* midTextAttri = [NSDictionary dictionaryWithObject:midFont forKey:NSFontAttributeName];
    // 大字体,加粗
    UIFont* bigFont = [UIFont systemFontOfSize:22.f];
    NSDictionary* bigTextAttri = [NSDictionary dictionaryWithObject:bigFont forKey:NSFontAttributeName];
    // 每组 label 之间的间隔
    CGFloat inset = 5.f;
    // 状态栏+导航栏高度
    CGFloat heightStatus = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat heightNavi = self.navigationController.navigationBar.bounds.size.height;
    
    // 小票是滚动视图
    CGRect frame = CGRectMake(0, heightStatus + heightNavi, self.view.bounds.size.width, self.view.bounds.size.height - heightNavi - heightStatus);

    [self.posScrollView setFrame:frame];
    
    
    JLPrint(@"dangqian交易信息节点M:[%@]",self.transInformation);
#pragma mask : 开始加载滚动视图的子视图


    //POS-签购单 商户存根
    NSString* text = @"POS-签购单";
    frame.origin.y = 0;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    UILabel* textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentCenter font:bigFont];
    [self.posScrollView addSubview:textLabel];
    // 商户存根
    text = @"商户存根";
    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.width = self.posScrollView.bounds.size.width - inset*2;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentRight font:midFont];
    [self.posScrollView addSubview:textLabel];
    // 商户存根 - 英文描述
    text = @"MERCHANT COPY";
    frame.origin.y += frame.size.height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentRight font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 商户名称 - 名
    text = @"商户名称(MERCHANT NAME)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 商户名称 - 值
    text = [PublicInformation returnBusinessName];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [self.posScrollView addSubview:textLabel];
    
    // 商户编号 - 名
    text = @"商户编号(MERCHANT NO)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 商户编号 - 值
    text = [PublicInformation returnBusiness];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 终端编号 - 名 并列
    text = @"终端号(TERMINAL NO)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 终端编号 - 值 并列
    text = [PublicInformation returnTerminal];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 卡号 - 名
    text = @"卡号(CARD NO)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 卡号 - 值
    text = [PublicInformation cuttingOffCardNo:[self.transInformation valueForKey:@"2"]];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [self.posScrollView addSubview:textLabel];
    
    // 交易类型 - 名
    text = @"交易类型(TRANS TYPE)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 交易类型 - 值
    text = [PublicInformation transNameWithCode:[self.transInformation valueForKey:@"3"]];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [self.posScrollView addSubview:textLabel];
    
    // 金额 - 名
    text = @"金额(AMOUNT)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 金额 - 值
    text = @"RMB: ";
    text = [text stringByAppendingString:[PublicInformation dotMoneyFromNoDotMoney:[self.transInformation valueForKey:@"4"]]];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [self.posScrollView addSubview:textLabel];
    
    // 日期/时间 - 名
    text = @"日期/时间(DATE/TIME)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 日期/时间 - 值
    NSMutableString* detailDate = [[NSMutableString alloc] init];
    [detailDate appendString:[[PublicInformation nowDate] substringToIndex:4]];
    [detailDate appendString:@"/"];
    [detailDate appendString:[[self.transInformation valueForKey:@"13"] substringToIndex:2]];
    [detailDate appendString:@"/"];
    [detailDate appendString:[[self.transInformation valueForKey:@"13"] substringFromIndex:2]];
    [detailDate appendString:@" "];
    [detailDate appendString:[[self.transInformation valueForKey:@"12"] substringToIndex:2]];
    [detailDate appendString:@":"];
    [detailDate appendString:[[self.transInformation valueForKey:@"12"] substringWithRange:NSMakeRange(2, 2)]];
    [detailDate appendString:@":"];
    [detailDate appendString:[[self.transInformation valueForKey:@"12"] substringFromIndex:4]];
    text = (NSString*)detailDate;
    
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    
    // 发卡行号 - 名
    text = @"发卡行号(ISS NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 发卡行号 - 值
    NSString* f44 = [PublicInformation stringFromHexString:[self.transInformation valueForKey:@"44"]];
    text = [f44 substringToIndex:f44.length/2];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 收单行号 - 名
    text = @"收单行号(ACQ NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 收单行号 - 值
    text = [f44 substringFromIndex:f44.length/2];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 批次号 - 名
    text = @"批次号(BATCH NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 批次号 - 值
    text = [PublicInformation returnSignSort];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 凭证号 - 名
    text = @"凭证号(VOUCHER NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 凭证号 - 值
    text = [self.transInformation valueForKey:@"11"];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 授权码 - 名
    text = @"授权码(AUTH NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 授权码 - 值
    text = [self.transInformation valueForKey:@"38"];
    if (text == nil || [text isEqualToString:@""]) text = @" ";
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 交易参考号 - 名
    text = @"交易参考号(REFER NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 交易参考号 - 值
    text = [self.transInformation valueForKey:@"37"];
    text = [PublicInformation stringFromHexString:text];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 有效期 - 名
    text = @"有效期(EXP DATE)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 有效期 - 值
    text = [self.transInformation valueForKey:@"14"];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 备注 - 名
    text = @"备注(REFERENCE)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 备注 - 值
    text = @" ";
    frame.origin.y += frame.size.height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    // 持卡人签名 - 名
    text = @"持卡人签名(CARDHOLDER SIGNATURE):";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    // 重置高度:根据文本的长度跟frame.width的比例
    if ([text sizeWithAttributes:midTextAttri].width > frame.size.width) {
        CGFloat sizeWidth = [text sizeWithAttributes:midTextAttri].width;
        int n = (int)(sizeWidth/frame.size.width);
        frame.size.height *= n;
    }
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    // 持卡人签名 - 图片
    frame.origin.y += inset + frame.size.height;
    frame.origin.x = (self.view.frame.size.width - self.elecSignImage.size.width)/2;
    frame.size.width = self.elecSignImage.size.width;
    frame.size.height = self.elecSignImage.size.height;
    UIImageView* imageView = [[UIImageView alloc] initWithImage:self.elecSignImage];
    imageView.frame = frame;
    [self.posScrollView addSubview:imageView];
    
    
    // 描述信息
    text = @"本人确认以上交易,同意将其计入本卡账户.";
    frame.origin.x = 0;
    frame.origin.y += inset + frame.size.height;
    frame.size.width = self.posScrollView.frame.size.width;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 英文描述
    text = @"I ACKNOWLEDGE SATISFATORY RECEIPT OF RELATIVE GOODS/SERVICES.";
    frame.origin.y += frame.size.height;
    frame.size.height *= 2.0;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    
    
    frame.origin.y += inset + frame.size.height;
    self.posScrollView.contentSize = CGSizeMake(Screen_Width, frame.origin.y); // 高度要重新定义
    [self.view addSubview:self.posScrollView];
    
}



#pragma mask ::: setter && getter



- (UIScrollView *)posScrollView {
    if (!_posScrollView) {
        _posScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _posScrollView.backgroundColor = [UIColor whiteColor];
        _posScrollView.bounces = NO;
    }
    return _posScrollView;
}

- (UIBarButtonItem *)doneBarBtn {
    if (!_doneBarBtn) {
        _doneBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(clickedOnHandleBtn:)];
    }
    return _doneBarBtn;
}

@end
