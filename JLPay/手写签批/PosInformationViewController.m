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

@property (nonatomic, strong) UIButton* sureButton;
@property (nonatomic, strong) UIProgressView* progressView;
@end


@implementation PosInformationViewController
@synthesize uploadRequest = _uploadRequest;
@synthesize activitor = _activitor;
@synthesize progressView = _progressView;
@synthesize sureButton = _sureButton;
@synthesize posImg;
@synthesize scrollAllImg;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    return self;
}


/* 重新上传 */
-(void)uploadMethod{
    [self chatUploadImage];
}


- (IBAction) touchDown:(UIButton*)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
        [sender setEnabled:NO];
    });
}
- (IBAction) touchOut:(UIButton*)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        sender.transform = CGAffineTransformIdentity;
        [sender setEnabled:YES];
    });
}
/* 确定按钮-上传小票图片 */
-(IBAction) requireMethod:(UIButton*)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        sender.transform = CGAffineTransformIdentity;
    });
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
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 终端编号 - 值 并列
    text = [PublicInformation returnTerminal];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];

    // 卡号 - 名
    text = @"卡号(CARD NO)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 卡号 - 值
    text = [PublicInformation cuttingOffCardNo:[self.transInformation valueForKey:@"2"]];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [scrollVi addSubview:textLabel];

    // 交易类型 - 名
    text = @"交易类型(TRANS TYPE)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 交易类型 - 值
    text = [PublicInformation transNameWithCode:[self.transInformation valueForKey:@"3"]];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [scrollVi addSubview:textLabel];

    // 金额 - 名
    text = @"金额(AMOUNT)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 金额 - 值
    text = @"RMB: ";
    text = [text stringByAppendingString:[PublicInformation dotMoneyFromNoDotMoney:[self.transInformation valueForKey:@"4"]]];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [scrollVi addSubview:textLabel];

    // 日期/时间 - 名
    text = @"日期/时间(DATE/TIME)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
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
    [scrollVi addSubview:textLabel];
    

    // 发卡行号 - 名
    text = @"发卡行号(ISS NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 发卡行号 - 值
    NSString* f44 = [PublicInformation stringFromHexString:[self.transInformation valueForKey:@"44"]];
    text = [f44 substringToIndex:f44.length/2];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];

    // 收单行号 - 名
    text = @"收单行号(ACQ NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 收单行号 - 值
    text = [f44 substringFromIndex:f44.length/2];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    
    // 批次号 - 名
    text = @"批次号(BATCH NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 批次号 - 值
    text = [[NSUserDefaults standardUserDefaults] valueForKey:Get_Sort_Number];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];

    // 凭证号 - 名
    text = @"凭证号(VOUCHER NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 凭证号 - 值
    text = [self.transInformation valueForKey:@"11"];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    
    // 授权码 - 名
    text = @"授权码(AUTH NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 授权码 - 值
    text = [self.transInformation valueForKey:@"38"];
    if (text == nil || [text isEqualToString:@""]) text = @" ";
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];
    
    // 交易参考号 - 名
    text = @"交易参考号(REFER NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 交易参考号 - 值
    text = [self.transInformation valueForKey:@"37"];
    text = [PublicInformation stringFromHexString:text];

    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [scrollVi addSubview:textLabel];

    // 有效期 - 名
    text = @"有效期(EXP DATE)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [scrollVi addSubview:textLabel];
    // 有效期 - 值
    text = [self.transInformation valueForKey:@"14"];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
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
    
    // 进度条
    frame.origin.x = 0;//inset * 10;
    frame.origin.y = scrollVi.frame.origin.y + scrollVi.frame.size.height;
    frame.size.width = scrollVi.bounds.size.width ;//- inset*10 * 2;
    frame.size.height = inset*2;
    [self.progressView setFrame:frame];
    [self.view addSubview:self.progressView];

    // 确定按钮
    frame.origin.x = inset * 2.0;
    frame.origin.y = scrollVi.frame.origin.y + scrollVi.frame.size.height + inset * 2.0;
    frame.size.width = scrollVi.bounds.size.width - inset * 2.0 * 2.0;
    frame.size.height = buttonHeight;
    [self.sureButton setFrame:frame];
    [self.view addSubview:self.sureButton];
    
    // 将滚动视图的内容装填成图片.jpg
    self.scrollAllImg = [self getNormalImage:scrollVi];
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
/*** 签名图片上传接口 ***/
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
    NSMutableDictionary* headerInfo = [[NSMutableDictionary alloc] init];
    [headerInfo setValue:[PublicInformation returnBusiness] forKey:@"uploadRequstMchntNo"];
    [headerInfo setValue:[PublicInformation returnBusinessName] forKey:@"uploadRequestMchntNM"];
    [headerInfo setValue:[PublicInformation stringFromHexString:[self.transInformation valueForKey:@"37"]] forKey:@"uploadRequestReferNo"];
    [headerInfo setValue:[PublicInformation stringFromHexString:[self.transInformation valueForKey:@"41"]] forKey:@"uploadRequestTermNo"];
    [headerInfo setValue:[self.transInformation valueForKey:@"4"] forKey:@"uploadRequestAmoumt"];
    
    NSMutableString* requestTime = [[NSMutableString alloc] init];
    [requestTime appendString:[[PublicInformation nowDate] substringToIndex:4]];
    [requestTime appendString:[self.transInformation valueForKey:@"13"]];
    [requestTime appendString:[self.transInformation valueForKey:@"12"]];
    [headerInfo setValue:requestTime forKey:@"uploadRequestTime"];
    
    [self.uploadRequest setRequestHeaders:headerInfo];
    // 小票图片data
    NSData* imageData = UIImageJPEGRepresentation(self.scrollAllImg, 1.0);
    NSLog(@"上传小票的大小:[%ud]",imageData.length);
    [self.uploadRequest appendPostData:imageData];
    // 同步发送HTTP请求
	[self.uploadRequest startAsynchronous];
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.activitor startAnimating];
    });
}

// HTTP 请求成功
-(void)successLogin:(ASIHTTPRequest *)successLoginStr{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.activitor stopAnimating];
        [self.sureButton setEnabled:YES];
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
//        [self.activitor stopAnimating];
        [self.sureButton setEnabled:YES];
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
        
        [_uploadRequest setUploadProgressDelegate:self.progressView];
    }
    return _uploadRequest;
}

- (JLActivity *)activitor {
    if (_activitor == nil) {
        _activitor = [[JLActivity alloc] init];
    }
    return _activitor;
}
- (UIProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    }
    return _progressView;
}
- (UIButton *)sureButton {
    if (_sureButton == nil) {
        _sureButton = [[UIButton alloc] init];
        _sureButton.layer.cornerRadius = 10.0;
        [_sureButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_sureButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        [_sureButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_sureButton addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [_sureButton addTarget:self action:@selector(requireMethod:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _sureButton;
}

@end
