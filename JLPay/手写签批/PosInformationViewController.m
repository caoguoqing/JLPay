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
#import "AppDelegate.h"
#import "PublicInformation.h"
#import "ASIHTTPRequest.h"
#import "Define_Header.h"
#import "ASIFormDataRequest.h"
#import "Photo.h"
#import "Toast+UIView.h"
#import "JsonToString.h"


@interface PosInformationViewController ()

@end

@implementation PosInformationViewController
@synthesize posImg;
@synthesize scrollAllImg;
@synthesize infoLiushuiStr;
@synthesize timeStr;
@synthesize lastLiushuiStr;


-(void)liushuiNum:(NSString *)num time:(NSString *)ti lastliushuinum:(NSString *)num2{
    self.timeStr=ti;
    self.infoLiushuiStr=num;
    self.lastLiushuiStr=num2;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    return self;
}


/**
 *    重新上传
 */
-(void)uploadMethod{
    [self chatUploadImage];
}

/**
 *    确定-上传小票图片
*/
-(void)requireMethod{
    [self chatUploadImage];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.92 green:0.93 blue:0.98 alpha:1.0];

    
    self.title=@"POS-签购单";
    // 导航栏的退出按钮置空
    UIButton*leftBackBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    leftBackBtn.frame=CGRectMake(0,0,0,0);
    leftBackBtn.backgroundColor=[UIColor clearColor];
    UIBarButtonItem *backBarBtn=[[UIBarButtonItem alloc] initWithCustomView:leftBackBtn];
    self.navigationItem.leftBarButtonItem=backBarBtn;
    
    // 小字体
    UIFont* littleFont = [UIFont systemFontOfSize:12.f];
    NSDictionary* littleTextAttri = [NSDictionary dictionaryWithObject:littleFont forKey:NSFontAttributeName];
    // 中字体
    UIFont* midFont = [UIFont systemFontOfSize:15.f];
    NSDictionary* midTextAttri = [NSDictionary dictionaryWithObject:midFont forKey:NSFontAttributeName];
    // 大字体,加粗
    UIFont* bigFont = [UIFont boldSystemFontOfSize:20.f];
    NSDictionary* bigTextAttri = [NSDictionary dictionaryWithObject:bigFont forKey:NSFontAttributeName];
    // 每组 label 之间的间隔
    CGFloat inset = 5.f;
    // 按钮高度
    CGFloat buttonHeight = 50.f;
    // navigation 高度
    CGFloat navigationHeigt = self.navigationController.navigationBar.bounds.size.height;
    
    // 小票是滚动视图
    UIScrollView *scrollVi=[[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                          navigationHeigt,
                                                                          self.view.bounds.size.width,
                                                                          self.view.bounds.size.height - navigationHeigt - buttonHeight - inset * 4)];
    scrollVi.backgroundColor=[UIColor whiteColor];
    
    
    
    
    
    // 导航栏右标签按钮
//    UIButton*rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    rightBtn.frame=CGRectMake(0, 7, 80, 30);
//    rightBtn.backgroundColor=[UIColor clearColor];
//    [rightBtn setBackgroundImage:[PublicInformation imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 44)] forState:UIControlStateNormal];
//    [rightBtn setTitle:@"重新上传" forState:UIControlStateNormal];
//    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
//    [rightBtn addTarget:self action:@selector(uploadMethod) forControlEvents:UIControlEventTouchUpInside];
//    rightBtn.layer.cornerRadius=6;
//    rightBtn.layer.masksToBounds = YES;
//    rightBtn.layer.borderColor=[UIColor colorWithRed:0.10 green:0.21 blue:0.49 alpha:1.0].CGColor;
//    rightBtn.layer.borderWidth=1.0f;
//    UIBarButtonItem *againUploadBtn=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
//    self.navigationItem.rightBarButtonItem=againUploadBtn;
    
    //POS-签购单 商户存根
    NSString* text = @"POS-签购单";
    CGRect frame = CGRectMake(0, 0, scrollVi.bounds.size.width, [text sizeWithAttributes:bigTextAttri].height);
    UILabel* textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentCenter font:bigFont];
    [scrollVi addSubview:textLabel];
    // 商户存根
    text = @"商户存根";
    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.width = scrollVi.bounds.size.width - inset*2;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentRight font:midFont];
    [scrollVi addSubview:textLabel];
    // 商户名称 - 名
    text = @"商户名称(MERCHANT NAME)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 商户名称 - 值
    text = [PublicInformation returnBusinessName];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [scrollVi addSubview:textLabel];
    // 商户编号 - 名
    text = @"商户编号(MERCHANT NO)";
    frame.origin.y += inset + frame.size.height;
    frame.size.width /= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 终端编号 - 名 并列
    text = @"终端号(TERMINAL NO)";
    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 商户编号 - 值
    text = [PublicInformation returnBusiness];
    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 终端编号 - 值 并列
    text = [PublicInformation returnTerminal];
    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 卡号 - 名
    text = @"卡号(CARD NO)";
    frame.origin.x = inset;
    frame.origin.y += inset + frame.size.height;
    frame.size.width *= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 卡号 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:GetCurrentCard_NotAll];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [scrollVi addSubview:textLabel];
    // 发卡行号 - 名
    text = @"发卡行号(ISS NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.width /= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 收单行号 - 名
    text = @"收单行号(ACQ NO)";
    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 发卡行号 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:ISS_NO_44_1];
    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 收单行号 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:ACQ_NO_44_2];
    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 交易类型 - 名
    text = @"交易类型(TRANS TYPE)";
    frame.origin.x = inset;
    frame.origin.y += inset + frame.size.height;
    frame.size.width *= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 交易类型 - 值
    text=[[NSUserDefaults standardUserDefaults] valueForKey:ExchangeMoney_Type];
    if ([text isEqualToString:@"消费"]) {
        text = [text stringByAppendingString:@" (SALE)"];
    } else if ([text isEqualToString:@"消费撤销"]) {
        text = [text stringByAppendingString:@" (VOID)"];
    }
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [scrollVi addSubview:textLabel];
    // 批次号 - 名
    text = @"批次号(BATCH NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.width /= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 凭证号 - 名
    text = @"凭证号(VOUCHER NO)";
    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 批次号 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:Get_Sort_Number];
    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 凭证号 - 值
    text = self.infoLiushuiStr;
    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 授权码 - 名
    text = @"授权码(AUTH NO)";
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 日期/时间 - 名
    text = @"日期/时间(DATE/TIME)";
    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 授权码 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:AuthNo_38];
    if (text == nil || [text isEqualToString:@""]) text = @" ";
    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 日期/时间 - 值
    text = self.timeStr;
    frame.origin.x += frame.size.width;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 交易参考号 - 名
    text = @"交易参考号(REFER NO)";
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 有效期 - 名
    text = @"有效期(EXP DATE)";
    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 交易参考号 - 值
    text = [PublicInformation stringFromHexString:[PublicInformation returnConsumerSort]];
    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 有效期 - 值
    text = self.timeStr;
    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 金额 - 名
    text = @"金额(AMOUNT)";
    frame.origin.x = inset;
    frame.origin.y += inset + frame.size.height;
    frame.size.width *= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 金额 - 值
    text = [NSString stringWithFormat:@"RMB: %@",[PublicInformation returnMoney]];;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [scrollVi addSubview:textLabel];

    // 备注 - 名
    text = @"备注(REFERENCE)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 备注 - 值
    text = @" ";
    frame.origin.y += frame.size.height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 持卡人签名 - 名
    text = @"持卡人签名(CARDHOLDER SIGNATURE):";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 持卡人签名 - 图片
    frame.origin.y += inset + frame.size.height;
    frame.size.width /= 2.0;
    frame.size.height = frame.size.width * (posImg.size.height/posImg.size.width);
    UIImageView *signImg=[[UIImageView alloc] initWithFrame:frame];
    signImg.image = posImg;
    [scrollVi addSubview:signImg];

    // 描述信息
    text = @"本人确认以上交易,同意将其计入本卡账户";
    frame.origin.y += inset + frame.size.height;
    frame.size.width *= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 英文描述
    text = @"I ACKNOWLEDGE SATISFATORY RECEIPT OF RELATIVE GOODS/SERVICES";
    frame.origin.y += frame.size.height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    
    
    frame.origin.y += inset + frame.size.height;
    scrollVi.contentSize = CGSizeMake(Screen_Width, frame.origin.y); // 高度要重新定义
    [self.view addSubview:scrollVi];

    
//    NSString *exchangeTypeStr=[[NSUserDefaults standardUserDefaults] valueForKey:ExchangeMoney_Type];
//    lastNum=[NSString stringWithFormat:@"原凭证号(): %@",self.lastLiushuiStr];
 
    
    
    // 确定按钮
    frame.origin.x = inset * 2.0;
    frame.origin.y = scrollVi.frame.origin.y + scrollVi.frame.size.height + inset * 2.0;
    frame.size.width = scrollVi.bounds.size.width - inset * 2.0 * 2.0;
    frame.size.height = buttonHeight;
    UIButton *requireBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    requireBtn.frame = frame;
    requireBtn.layer.cornerRadius = 10.0;
    requireBtn.layer.masksToBounds = YES;
    [requireBtn setBackgroundImage:[PublicInformation createImageWithColor:[UIColor colorWithRed:0.14 green:0.64 blue:0.17 alpha:1.0]] forState:UIControlStateNormal];
    [requireBtn addTarget:self action:@selector(requireMethod) forControlEvents:UIControlEventTouchUpInside];
    [requireBtn setTitle:@"确定" forState:UIControlStateNormal];
    requireBtn.titleLabel.font = bigFont;
    requireBtn.titleLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:requireBtn];
    
    // 将滚动视图的内容装填成图片.jpg
    self.scrollAllImg=[self getNormalImage:scrollVi];
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
    return textLabel;
}



#pragma mark ----------------屏幕截图
//获取当前屏幕内容
- (UIImage *)getNormalImage:(UIScrollView *)view{
    view.frame=CGRectMake(0, 0, view.contentSize.width, view.contentSize.height);
    UIGraphicsBeginImageContextWithOptions(view.contentSize, view.opaque, 1.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    img=[UIImage imageWithData:UIImageJPEGRepresentation(img, 0.5)];
    UIGraphicsEndImageContext();
    return img;
    
}


#pragma mark ------------图片上传
-(void)chatUploadImage{
    NSString* uploadString = [NSString stringWithFormat:@"http://%@:%@/jlagent/UploadImg",
                              [PublicInformation getDataSourceIP],
                              [PublicInformation getDataSourcePort]];

    [NSThread detachNewThreadSelector:@selector(uploadRequestMethod:) toTarget:self withObject:uploadString];
}
/**
 * 签名图片上传接口
 *
 * @param money
 *            消费金额
 * @param trackNum
 *            流水号
 * @param batchNum
 *            批次号
 * @param operatorNum
 *            操作员号
 * @param accountNum
 *            卡号
 * ***/
-(void)uploadRequestMethod:(NSString *)url{
    //起码一张图片
//    NSString *photoStr=[Photo image2String:self.scrollAllImg];
    ASIFormDataRequest *uploadRequest=[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [uploadRequest setShouldAttemptPersistentConnection:YES];
    [uploadRequest setNumberOfTimesToRetryOnTimeout:2];
    [uploadRequest setTimeOutSeconds:30];
    uploadRequest.delegate=self;
    
    /*
     uploadRequstMchntNo	商户编号        15位
     uploadRequestMchntNM	商户名称        不超过100位
     uploadRequestReferNo	交易检索号       12位
     uploadRequestTermNo	终端编号        8位
     uploadRequestAmoumt	交易金额        以分为单位
     uploadRequestTime      请求时间        14位
     */
    [PublicInformation stringFromHexString:[PublicInformation returnConsumerSort]];
    NSString* normalTime = [self formatTime:self.timeStr]; // 2015-07-10 14:38:52  -> 20150710143852
    NSMutableDictionary* headerInfo = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[PublicInformation returnBusiness],
                                                                    [PublicInformation returnBusinessName],
                                                                    [PublicInformation stringFromHexString:[PublicInformation returnConsumerSort]],
                                                                    [PublicInformation returnTerminal],
                                                                    [PublicInformation returnMoney],
                                                                    normalTime,nil]
                                                           forKeys:[NSArray arrayWithObjects:
                                                                    @"uploadRequstMchntNo",
                                                                    @"uploadRequestMchntNM",
                                                                    @"uploadRequestReferNo",
                                                                    @"uploadRequestTermNo",
                                                                    @"uploadRequestAmoumt",
                                                                    @"uploadRequestTime", nil]];
    
    [uploadRequest setRequestHeaders:headerInfo];
    [uploadRequest appendPostData:UIImageJPEGRepresentation(self.scrollAllImg, 1.0)];             // 小票图片data
    
    [uploadRequest setDidFinishSelector:@selector(successLogin:)];  // 接收成功消息
    [uploadRequest setDidFailSelector:@selector(falseLogin:)];      // 接收失败消息
    [uploadRequest setShouldContinueWhenAppEntersBackground:YES];
	[uploadRequest startAsynchronous];                              // 异步发送HTTP请求
}

-(void)successLogin:(ASIHTTPRequest *)successLoginStr{
    [successLoginStr clearDelegatesAndCancel];
    NSDictionary *chatUpLoadDic=[[NSDictionary alloc] initWithDictionary:[JsonToString getAnalysis:successLoginStr.responseString]];
    NSLog(@"chatUpLoadDic===%@",chatUpLoadDic);
    NSLog(@"successLoginStr.responseString===%@",successLoginStr.responseString);

    if ([[chatUpLoadDic objectForKey:@"code"] intValue] == 0) {
        //缓存图片路径
        [self saveImagePathMethod:[chatUpLoadDic objectForKey:@"data"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[app_delegate window] makeToast:@"小票上传成功"];
            // 成功后就退出到root视图界面
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
    
}
-(void)falseLogin:(ASIHTTPRequest *)falseScoreStr{

    NSError *error = [falseScoreStr error];
    if (error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
}

//缓存图片路径
-(void)saveImagePathMethod:(NSString *)url{
    NSString *exchangeTypeStr=[[NSUserDefaults standardUserDefaults] valueForKey:ExchangeMoney_Type];
    //撤销支付
    if ([exchangeTypeStr isEqualToString:@"撤销支付"]) {
        
        NSMutableArray *resultArr=[[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:TheCarcd_Record]];
        //NSLog(@"原始数据====%@",resultArr);
        
        NSMutableArray *newArr=[[NSMutableArray alloc] initWithArray:resultArr];
        
        for (int i=0; i<[resultArr count]; i++) {
            if ([[[newArr objectAtIndex:i] objectForKey:@"liushui"] isEqualToString:self.infoLiushuiStr]) {
                NSLog(@"liushui====%@====%@",[[newArr objectAtIndex:i] objectForKey:@"liushui"],self.lastLiushuiStr);
                NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithDictionary:[newArr objectAtIndex:i]];
                [dic addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:url,@"path", nil]];
                [newArr replaceObjectAtIndex:i withObject:dic];
            }
        }
        NSLog(@"撤销支付=====%@",newArr);
        [[NSUserDefaults standardUserDefaults] setObject:newArr forKey:TheCarcd_Record];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
//刷卡记录包括，(消费记录、撤销支付记录);当前更新pos签购单图片路径
//添加本次消费记录,图片路径
    else{
        
        NSMutableArray *resultArr=[[NSMutableArray alloc] init];
        
        NSMutableArray *allCardArr=[[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:Save_All_NonCardInfo]];
        for (int i=0; i<[allCardArr count]; i++) {
            [resultArr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:[allCardArr objectAtIndex:i]]];
        }
        for (int i=0; i<[resultArr count]; i++) {
            if ([[[resultArr objectAtIndex:i] objectForKey:@"liushui"] isEqualToString:self.infoLiushuiStr]) {
                NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithDictionary:[resultArr objectAtIndex:i]];
                [dic addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:url,@"path", nil]];
                [resultArr replaceObjectAtIndex:i withObject:dic];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:resultArr forKey:TheCarcd_Record];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// 格式化时间成功无任何符号格式
- (NSString*) formatTime:(NSString*)timestr {
    // 2015-07-10 14:38:52  -> 20150710143852
    int length = [timestr length] + 1;
    char* str = (char*)malloc(length);
    char* ctimestr = (char*)malloc(14 + 1);
    memset(str, 0x00, length);
    memcpy(str, [timestr cStringUsingEncoding:NSASCIIStringEncoding], length - 1);
    char* temp = str;
    int index = 0;
    for (int i = 0; i < length - 1; i++) {
        if (*temp < '0' || *temp > '9') {
            temp++;
            continue;
        } else {
            ctimestr[index++] = *temp;
            temp++;
        }
    }
    NSLog(@"14位时间:[%s]", ctimestr);
    NSString* normalTime = [NSString stringWithCString:ctimestr encoding:NSASCIIStringEncoding];
    free(str);
    free(ctimestr);
    return normalTime;
}

@end
