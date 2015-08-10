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
#import "JLActivity.h"


@interface PosInformationViewController ()
@property (nonatomic, strong) ASIFormDataRequest *uploadRequest;
@property (nonatomic, strong) JLActivity* activitor;
@end

@implementation PosInformationViewController
@synthesize uploadRequest = _uploadRequest;
@synthesize activitor = _activitor;
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
    // 按钮高度
    CGFloat buttonHeight = 50.f;
    
    // 小票是滚动视图
    UIScrollView *scrollVi=[[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          self.view.bounds.size.width,
                                                                          self.view.bounds.size.height - buttonHeight - inset * 4)];
    scrollVi.backgroundColor=[UIColor whiteColor];
    scrollVi.bounces = NO;
    
    #pragma mask : 开始加载滚动视图的子视图
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
    // 商户存根 - 英文描述
    text = @"MERCHANT COPY";
    frame.origin.y += frame.size.height;
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
//    frame.size.width /= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 商户编号 - 值
    text = [PublicInformation returnBusiness];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    
    // 终端编号 - 名 并列
    text = @"终端号(TERMINAL NO)";
//    frame.origin.x += frame.size.width;
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 终端编号 - 值 并列
    text = [PublicInformation returnTerminal];
//    frame.origin.x += frame.size.width;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 卡号 - 名
    text = @"卡号(CARD NO)";
//    frame.origin.x = inset;
    frame.origin.y += inset + frame.size.height;
//    frame.size.width *= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 卡号 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:GetCurrentCard_NotAll];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [scrollVi addSubview:textLabel];
    // 交易类型 - 名
    text = @"交易类型(TRANS TYPE)";
    //    frame.origin.x = inset;
    frame.origin.y += inset + frame.size.height;
    //    frame.size.width *= 2.0;
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
    
    // 金额 - 名
    text = @"金额(AMOUNT)";
    //    frame.origin.x = inset;
    frame.origin.y += inset + frame.size.height;
    //    frame.size.width *= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 金额 - 值
    text = [NSString stringWithFormat:@"RMB: %@",[PublicInformation returnMoney]];;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [scrollVi addSubview:textLabel];

    // 日期/时间 - 名
    text = @"日期/时间(DATE/TIME)";
    //    frame.origin.x += frame.size.width;
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 日期/时间 - 值
    text = self.timeStr;
    //    frame.origin.x += frame.size.width;
    //    frame.size.width *= 2.0;
    frame.origin.y += frame.size.height;
    //    frame.size.width *= 2.0/3.0;
    
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    

    // 发卡行号 - 名
    text = @"发卡行号(ISS NO)";
    frame.origin.y += frame.size.height + inset;
//    frame.size.width /= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 发卡行号 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:ISS_NO_44_1];
//    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 收单行号 - 名
    text = @"收单行号(ACQ NO)";
    //    frame.origin.x += frame.size.width;
    frame.origin.y += frame.size.height + inset;
    //    frame.size.width /= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 收单行号 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:ACQ_NO_44_2];
//    frame.origin.x += frame.size.width;
    frame.origin.y += frame.size.height;
    //    frame.size.width /= 2.0;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    
    
    
    
    
    // 批次号 - 名
    text = @"批次号(BATCH NO)";
    frame.origin.y += frame.size.height + inset;
//    frame.size.width /= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 批次号 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:Get_Sort_Number];
//    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    // 凭证号 - 名
    text = @"凭证号(VOUCHER NO)";
    frame.origin.y += frame.size.height + inset;
    //    frame.size.width /= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    //    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 凭证号 - 值
    text = self.infoLiushuiStr;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
//    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    
    
    // 授权码 - 名
    text = @"授权码(AUTH NO)";
//    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 授权码 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:AuthNo_38];
    if (text == nil || [text isEqualToString:@""]) text = @" ";
//    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
//    frame.size.width *= 2.0/3.0;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    
    
    // 交易参考号 - 名
    text = @"交易参考号(REFER NO)";
//    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
//    frame.size.width = scrollVi.bounds.size.width/2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 交易参考号 - 值
    text = [PublicInformation stringFromHexString:[PublicInformation returnConsumerSort]];
//    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    
    // 有效期 - 名
    text = @"有效期(EXP DATE)";
    frame.origin.y += frame.size.height + inset;
    //    frame.size.width = scrollVi.bounds.size.width/2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;

    //    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 有效期 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:EXP_DATE_14]; // yymm
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
//    frame.origin.x += frame.size.width;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
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
    // 重置高度:根据文本的长度跟frame.width的比例
    if ([text sizeWithAttributes:midTextAttri].width > frame.size.width) {
        CGFloat sizeWidth = [text sizeWithAttributes:midTextAttri].width;
        int n = (int)(sizeWidth/frame.size.width);
        frame.size.height *= n;
//        if (sizeWidth % frame.size.width > 0) {
//            
//        }
    }
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
    text = @"本人确认以上交易,同意将其计入本卡账户.";
    frame.origin.y += inset + frame.size.height;
    frame.size.width *= 2.0;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 英文描述
    text = @"I ACKNOWLEDGE SATISFATORY RECEIPT OF RELATIVE GOODS/SERVICES.";
    frame.origin.y += frame.size.height;
    frame.size.height *= 2.0;
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
    [requireBtn setBackgroundImage:[PublicInformation createImageWithColor:[UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:75.0/255.0 alpha:1.0]] forState:UIControlStateNormal];
    [requireBtn addTarget:self action:@selector(requireMethod) forControlEvents:UIControlEventTouchUpInside];
    [requireBtn setTitle:@"确定" forState:UIControlStateNormal];
    [requireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requireBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [requireBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    requireBtn.titleLabel.font = bigFont;
    [self.view addSubview:requireBtn];
    
    // 将滚动视图的内容装填成图片.jpg
    self.scrollAllImg=[self getNormalImage:scrollVi];
    [self.view addSubview:self.activitor];
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

// 视图退出,要取消
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.activitor stopAnimating];
    self.activitor = nil;
    [self.uploadRequest clearDelegatesAndCancel];
    self.uploadRequest = nil;
}


#pragma mark ----------------屏幕截图
//获取当前屏幕内容
- (UIImage *)getNormalImage:(UIScrollView *)view{
    CGRect oldFrame = view.frame;
    view.frame = CGRectMake(0, 0, view.contentSize.width, view.contentSize.height);
    CGSize size = CGSizeMake(view.frame.size.width, view.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, view.opaque, 1.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    img=[UIImage imageWithData:UIImageJPEGRepresentation(img, 0.5)];
    UIGraphicsEndImageContext();
    view.frame = oldFrame;
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
    [self.uploadRequest setDelegate:self];
    
    /*
     uploadRequstMchntNo	商户编号        15位
     uploadRequestMchntNM	商户名称        不超过100位
     uploadRequestReferNo	交易检索号       12位
     uploadRequestTermNo	终端编号        8位
     uploadRequestAmoumt	交易金额        以分为单位
     uploadRequestTime      请求时间        14位
     */
    NSMutableDictionary* headerInfo = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[PublicInformation returnBusiness],
                                                                    [PublicInformation returnBusinessName],
                                                                    [PublicInformation stringFromHexString:[PublicInformation returnConsumerSort]],
                                                                    [PublicInformation returnTerminal],
                                                                    [PublicInformation returnMoney],
                                                                    [self formatTime:self.timeStr], // 2015-07-10 14:38:52  -> 20150710143852
                                                                        nil]
                                                           forKeys:[NSArray arrayWithObjects:
                                                                    @"uploadRequstMchntNo",
                                                                    @"uploadRequestMchntNM",
                                                                    @"uploadRequestReferNo",
                                                                    @"uploadRequestTermNo",
                                                                    @"uploadRequestAmoumt",
                                                                    @"uploadRequestTime", nil]];
    
    [self.uploadRequest setRequestHeaders:headerInfo];
    [self.uploadRequest appendPostData:UIImageJPEGRepresentation(self.scrollAllImg, 1.0)];             // 小票图片data
	[self.uploadRequest startAsynchronous];                           // 同步发送HTTP请求
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activitor startAnimating];
    });
}

// HTTP 请求成功
-(void)successLogin:(ASIHTTPRequest *)successLoginStr{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activitor stopAnimating];
    });
    [successLoginStr clearDelegatesAndCancel];
    self.uploadRequest = nil;
    NSDictionary *chatUpLoadDic=[[NSDictionary alloc] initWithDictionary:[JsonToString getAnalysis:successLoginStr.responseString]];

    if ([[chatUpLoadDic objectForKey:@"code"] intValue] == 0) {
        //缓存图片路径
        dispatch_async(dispatch_get_main_queue(), ^{
            [[app_delegate window] makeToast:@"小票上传成功"];
            // 成功后就退出到root视图界面
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"小票上传失败，请稍后重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
    
}
// HTTP 请求失败
-(void)falseLogin:(ASIHTTPRequest *)falseScoreStr{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activitor stopAnimating];
    });
    [falseScoreStr clearDelegatesAndCancel];
    self.uploadRequest = nil;
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
    int length = (int)[timestr length] + 1;
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


#pragma mask ::: setter && getter
- (ASIFormDataRequest *)uploadRequest {
    if (_uploadRequest == nil) {
        NSString* uploadString = [NSString stringWithFormat:@"http://%@:%@/jlagent/UploadImg",
                                  [PublicInformation getDataSourceIP],
                                  [PublicInformation getDataSourcePort]];
        NSURL* url = [NSURL URLWithString:uploadString];
        _uploadRequest = [[ASIFormDataRequest alloc] initWithURL:url];
        [_uploadRequest setShouldAttemptPersistentConnection:YES];
        [_uploadRequest setNumberOfTimesToRetryOnTimeout:2];
        [_uploadRequest setTimeOutSeconds:30];
        [_uploadRequest setDidFinishSelector:@selector(successLogin:)];  // 接收成功消息
        [_uploadRequest setDidFailSelector:@selector(falseLogin:)];      // 接收失败消息
        [_uploadRequest setShouldContinueWhenAppEntersBackground:YES];
    }
    return _uploadRequest;
}

- (JLActivity *)activitor {
    if (_activitor == nil) {
        _activitor = [[JLActivity alloc] init];
    }
    return _activitor;
}

@end
