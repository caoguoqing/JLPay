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
#import "Define_Header.h"
#import "ASIFormDataRequest.h"
#import "Toast+UIView.h"
#import "JsonToString.h"
#import "MBProgressHUD.h"

static NSString* const kKVOImageUploaded = @"imageUploaded";

@interface PosInformationViewController ()<ASIHTTPRequestDelegate>
@property (nonatomic, strong) ASIFormDataRequest *uploadRequest;

@property (nonatomic, assign) BOOL imageUploaded;

@property (nonatomic, strong) UIButton* buttonReupload;
@property (nonatomic, strong) UIButton* buttonUploadDone;
@property (nonatomic, strong) UIProgressView* progressView;
@end


@implementation PosInformationViewController
@synthesize uploadRequest = _uploadRequest;
@synthesize progressView = _progressView;
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
    [self uploadRequestMethod];
}

#pragma mark ------------图片上传

/*** 签名图片上传接口 ***/
-(void)uploadRequestMethod {
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
    [self.uploadRequest appendPostData:imageData];
    // 同步发送HTTP请求
    [self.uploadRequest startAsynchronous];
}

/* HTTP回调: 响应成功 */
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *chatUpLoadDic=[[NSDictionary alloc] initWithDictionary:[JsonToString getAnalysis:request.responseString]];
    
    if ([[chatUpLoadDic objectForKey:@"code"] intValue] == 0) {
        self.imageUploaded = YES;
        [PublicInformation makeToast:@"小票上传成功"];
    }else{
        self.imageUploaded = NO;
        [PublicInformation makeToast:@"小票上传失败，请稍后重试"];
    }
    [request clearDelegatesAndCancel];
    self.uploadRequest = nil;

}
/* HTTP回调: 响应失败 */
- (void)requestFailed:(ASIHTTPRequest *)request {
    self.imageUploaded = NO;
    [request clearDelegatesAndCancel];
    self.uploadRequest = nil;
    [PublicInformation makeToast:@"网络异常，请检查网络后重新上传"];
}



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
    // 进度条高度
    CGFloat heightProgress = 2.f;
    
    // 小票是滚动视图
    UIScrollView *scrollVi=[[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                          heightStatus + heightNavi + heightProgress,
                                                                          self.view.bounds.size.width,
                                                                          self.view.bounds.size.height - heightNavi - heightStatus - heightProgress)];
    scrollVi.backgroundColor=[UIColor whiteColor];
    scrollVi.bounces = NO;
    
#pragma mask : 开始加载滚动视图的子视图
    CGRect frame = CGRectMake(0, heightStatus + heightNavi, scrollVi.bounds.size.width, heightProgress);

    // 进度条
    [self.progressView setFrame:frame];
    [self.view addSubview:self.progressView];

    //POS-签购单 商户存根
    NSString* text = @"POS-签购单";
    frame.origin.y = 0;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
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
    text = [PublicInformation returnSignSort];
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
    
    // 将滚动视图的内容装填成图片.jpg
    self.scrollAllImg = [self getNormalImage:scrollVi];
}

#pragma mask 1 KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kKVOImageUploaded]) {
        if (self.imageUploaded) {
            self.buttonUploadDone.enabled = YES;
            self.buttonReupload.enabled = NO;
        } else {
            self.buttonReupload.enabled = YES;
            self.buttonUploadDone.enabled = NO;
        }
    }
}

#pragma mask 0 界面布局
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.92 green:0.93 blue:0.98 alpha:1.0];
    self.title=@"POS-签购单";
    
    self.imageUploaded = NO;
    
    // 导航栏的退出按钮置空
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.buttonReupload]];
    
    // 导航栏添加"完成"按钮
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.buttonUploadDone]];
    
    [self addObserver:self forKeyPath:kKVOImageUploaded options:NSKeyValueObservingOptionNew context:nil];
    
    [self loadsSubviews];
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.imageUploaded) {
        [self uploadRequestMethod];
    }
}
// 视图退出,要取消
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.uploadRequest clearDelegatesAndCancel];
    self.uploadRequest = nil;
    [self removeObserver:self forKeyPath:kKVOImageUploaded];
}

/* 检查上传结果并退出 */
- (void) checkUploadedAndPopView {
    if (self.imageUploaded) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [PublicInformation makeCentreToast:@"小票未上传,请上传小票!"];
    }
}
// -- 重新上传小票
- (IBAction) reuploadStubImage:(id)sender {
    if (self.imageUploaded) {
        [PublicInformation makeToast:@"小票已成功上传"];
    } else {
        [self uploadRequestMethod];
    }
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




#pragma mask ::: setter && getter
- (ASIFormDataRequest *)uploadRequest {
    if (_uploadRequest == nil) {
        NSString* uploadString = [NSString stringWithFormat:@"http://%@:%@/jlagent/UploadImg",
                                  [PublicInformation getServerDomain],
                                  [PublicInformation getHTTPPort]];
        NSURL* url = [NSURL URLWithString:uploadString];
        _uploadRequest = [[ASIFormDataRequest alloc] initWithURL:url];
        [_uploadRequest setShouldAttemptPersistentConnection:YES];
        [_uploadRequest setNumberOfTimesToRetryOnTimeout:3];
        [_uploadRequest setTimeOutSeconds:20];
        [_uploadRequest setDelegate:self];
        
        [_uploadRequest setUploadProgressDelegate:self.progressView];
    }
    return _uploadRequest;
}
- (UIProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
        _progressView.progressTintColor = [PublicInformation returnCommonAppColor:@"green"];
    }
    return _progressView;
}
- (UIButton *)buttonReupload {
    if (_buttonReupload == nil) {
        NSString* buttonTitle = @"重新上传";
        CGFloat fontSize = 17.f;
        CGSize titleSize = [buttonTitle sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName]];
        _buttonReupload = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, titleSize.height)];
        [_buttonReupload setTitle:buttonTitle forState:UIControlStateNormal];
        [_buttonReupload setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_buttonReupload setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_buttonReupload setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_buttonReupload.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        _buttonReupload.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_buttonReupload addTarget:self action:@selector(reuploadStubImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonReupload;
}
- (UIButton *)buttonUploadDone {
    if (_buttonUploadDone == nil) {
        NSString* buttonTitle = @"完成";
        CGFloat fontSize = 17.f;
        CGSize titleSize = [buttonTitle sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName]];
        _buttonUploadDone = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, titleSize.height)];
        [_buttonUploadDone setTitle:buttonTitle forState:UIControlStateNormal];
        [_buttonUploadDone setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_buttonUploadDone setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_buttonUploadDone setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_buttonUploadDone.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        _buttonUploadDone.titleLabel.textAlignment = NSTextAlignmentRight;
        [_buttonUploadDone addTarget:self action:@selector(checkUploadedAndPopView) forControlEvents:UIControlEventTouchUpInside];
        _buttonUploadDone.enabled = NO;
    }
    return _buttonUploadDone;
}

@end
