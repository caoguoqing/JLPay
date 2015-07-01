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
    self.view.backgroundColor=[UIColor colorWithRed:0.92 green:0.93 blue:0.98 alpha:1.0];

    
    self.title=@"POS-签购单";
    
    UIButton*leftBackBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    leftBackBtn.frame=CGRectMake(0,0,0,0);
    leftBackBtn.backgroundColor=[UIColor clearColor];
    UIBarButtonItem *backBarBtn=[[UIBarButtonItem alloc] initWithCustomView:leftBackBtn];
    self.navigationItem.leftBarButtonItem=backBarBtn;
    
    UIScrollView *scrollVi=[[UIScrollView alloc] initWithFrame:CGRectMake(10,   // 边界 10
                                                                          0,
                                                                          Screen_Width-20,  // 减去2*边界
                                                                          Screen_Height-50-20)];
    scrollVi.backgroundColor=[UIColor whiteColor];
    // 滚动视图的frame.height不应该由子视图计算得来么
    scrollVi.contentSize=CGSizeMake(Screen_Width-20, 620);
    [self.view addSubview:scrollVi];
    
    // 导航栏右标签按钮
    UIButton*rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame=CGRectMake(0, 7, 80, 30);
    rightBtn.backgroundColor=[UIColor clearColor];
    [rightBtn setBackgroundImage:[PublicInformation imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 44)] forState:UIControlStateNormal];
    [rightBtn setTitle:@"重新上传" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [rightBtn addTarget:self action:@selector(uploadMethod) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.layer.cornerRadius=6;
    rightBtn.layer.masksToBounds = YES;
    rightBtn.layer.borderColor=[UIColor colorWithRed:0.10 green:0.21 blue:0.49 alpha:1.0].CGColor;
    rightBtn.layer.borderWidth=1.0f;
    UIBarButtonItem *againUploadBtn=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=againUploadBtn;
//POS-签购单 商户存根
    UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 0, Screen_Width-30, 30)];
    titleLab.backgroundColor=[UIColor clearColor];
    titleLab.textColor=[UIColor blackColor];
    titleLab.textAlignment=NSTextAlignmentCenter;
    titleLab.font=[UIFont systemFontOfSize:20.0f];
    titleLab.text=@"POS-签购单";
    [scrollVi addSubview:titleLab];
    
    UILabel *titleInfoLab=[[UILabel alloc] initWithFrame:CGRectMake(Screen_Width-25-100, 10, 100, 20)];
    titleInfoLab.backgroundColor=[UIColor clearColor];
    titleInfoLab.textColor=[UIColor blackColor];
    titleInfoLab.textAlignment=NSTextAlignmentRight;
    titleInfoLab.font=[UIFont systemFontOfSize:15.0f];
    titleInfoLab.text=@"商户存根";
    [scrollVi addSubview:titleInfoLab];
    
    UIImageView *lineOneImg=[[UIImageView  alloc] initWithFrame:CGRectMake(5, 29, Screen_Width-30, 1)];
    lineOneImg.image=[UIImage imageNamed:@"tabbar_shadow.png"];
    [scrollVi addSubview:lineOneImg];
    
    //商户名称
    UILabel *businessNameInfoLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 30, Screen_Width-30, 20)];
    businessNameInfoLab.backgroundColor=[UIColor clearColor];
    businessNameInfoLab.textColor=[UIColor blackColor];
    businessNameInfoLab.textAlignment=NSTextAlignmentLeft;
    businessNameInfoLab.font=[UIFont systemFontOfSize:15.0f];
    businessNameInfoLab.text=@"商户名称：";
    [scrollVi addSubview:businessNameInfoLab];
    
    UILabel *businessNameLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 50, Screen_Width-30, 30)];
    businessNameLab.backgroundColor=[UIColor clearColor];
    businessNameLab.textColor=[UIColor blackColor];
    businessNameLab.textAlignment=NSTextAlignmentLeft;
    businessNameLab.font=[UIFont systemFontOfSize:20.0f];
    businessNameLab.text=[PublicInformation returnBusinessName];
    [scrollVi addSubview:businessNameLab];
    
    // 商户编号
    UILabel *businessNumberLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 80, Screen_Width-30, 20)];
    businessNumberLab.backgroundColor=[UIColor clearColor];
    businessNumberLab.textColor=[UIColor blackColor];
    businessNumberLab.textAlignment=NSTextAlignmentLeft;
    businessNumberLab.font=[UIFont systemFontOfSize:15.0f];
    businessNumberLab.text=[NSString stringWithFormat:@"商户号：%@",[PublicInformation returnBusiness]];
    [scrollVi addSubview:businessNumberLab];
    
    // 终端编号
    UILabel *terminalLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 100, Screen_Width-30, 20)];
    terminalLab.backgroundColor=[UIColor clearColor];
    terminalLab.textColor=[UIColor blackColor];
    terminalLab.textAlignment=NSTextAlignmentLeft;
    terminalLab.font=[UIFont systemFontOfSize:15.0f];
    terminalLab.text=[NSString stringWithFormat:@"终端号：%@",[PublicInformation returnTerminal]];
    [scrollVi addSubview:terminalLab];
    
    // 管理员编号
    UILabel *managerNumberLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 120, Screen_Width-30, 20)];
    managerNumberLab.backgroundColor=[UIColor clearColor];
    managerNumberLab.textColor=[UIColor blackColor];
    managerNumberLab.textAlignment=NSTextAlignmentLeft;
    managerNumberLab.font=[UIFont systemFontOfSize:15.0f];
    managerNumberLab.text=[NSString stringWithFormat:@"操作员号：%@",Manager_Number];//Manager_Number
    [scrollVi addSubview:managerNumberLab];
    
    // 分割线
    UIImageView *lineTwoImg=[[UIImageView  alloc] initWithFrame:CGRectMake(5, 139, Screen_Width-30, 1)];
    lineTwoImg.image=[UIImage imageNamed:@"tabbar_shadow.png"];
    [scrollVi addSubview:lineTwoImg];
    
    //发卡行
    UILabel *bankCardLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 140, Screen_Width-30, 20)];
    bankCardLab.backgroundColor=[UIColor clearColor];
    bankCardLab.textColor=[UIColor blackColor];
    bankCardLab.textAlignment=NSTextAlignmentLeft;
    bankCardLab.font=[UIFont systemFontOfSize:15.0f];
    bankCardLab.text=@"发卡行：";
    [scrollVi addSubview:bankCardLab];
    
    // 卡号
    UILabel *swipeCardNumLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 160, Screen_Width-30, 20)];
    swipeCardNumLab.backgroundColor=[UIColor clearColor];
    swipeCardNumLab.textColor=[UIColor blackColor];
    swipeCardNumLab.textAlignment=NSTextAlignmentLeft;
    swipeCardNumLab.font=[UIFont systemFontOfSize:15.0f];
    swipeCardNumLab.text=@"刷卡卡号";
    [scrollVi addSubview:swipeCardNumLab];
    
    UILabel *cardLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 180, Screen_Width-30, 30)];
    cardLab.backgroundColor=[UIColor clearColor];
    cardLab.textColor=[UIColor blackColor];
    cardLab.textAlignment=NSTextAlignmentLeft;
    cardLab.font=[UIFont systemFontOfSize:20.0f];
    cardLab.text=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:GetCurrentCard_NotAll]];
    [scrollVi addSubview:cardLab];
    
    // 交易类型
    UILabel *exchangeTypeLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 210, Screen_Width-30, 20)];
    exchangeTypeLab.backgroundColor=[UIColor clearColor];
    exchangeTypeLab.textColor=[UIColor blackColor];
    exchangeTypeLab.textAlignment=NSTextAlignmentLeft;
    exchangeTypeLab.font=[UIFont systemFontOfSize:15.0f];
    exchangeTypeLab.text=@"交易类型：";
    [scrollVi addSubview:exchangeTypeLab];
    
    UILabel *consumerLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 230, Screen_Width-30, 20)];
    consumerLab.backgroundColor=[UIColor clearColor];
    consumerLab.textColor=[UIColor blackColor];
    consumerLab.textAlignment=NSTextAlignmentLeft;
    consumerLab.font=[UIFont systemFontOfSize:20.0f];
    consumerLab.text=[NSString stringWithFormat:@"%@(S)",[[NSUserDefaults standardUserDefaults] valueForKey:ExchangeMoney_Type]];
    [scrollVi addSubview:consumerLab];
    
    UIImageView *lineThreeImg=[[UIImageView  alloc] initWithFrame:CGRectMake(5, 249, Screen_Width-30, 1)];
    lineThreeImg.image=[UIImage imageNamed:@"tabbar_shadow.png"];
    [scrollVi addSubview:lineThreeImg];
    
//批次号
    UILabel *piciLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 250, Screen_Width-30, 20)];
    piciLab.backgroundColor=[UIColor clearColor];
    piciLab.textColor=[UIColor blackColor];
    piciLab.textAlignment=NSTextAlignmentLeft;
    piciLab.font=[UIFont systemFontOfSize:15.0f];
    piciLab.text=[NSString stringWithFormat:@"批次号：%@",[[NSUserDefaults standardUserDefaults] valueForKey:Get_Sort_Number]];
    [scrollVi addSubview:piciLab];
//
    UILabel *pingzhengLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 270, Screen_Width-30, 20)];
    pingzhengLab.backgroundColor=[UIColor clearColor];
    pingzhengLab.textColor=[UIColor blackColor];
    pingzhengLab.textAlignment=NSTextAlignmentLeft;
    pingzhengLab.font=[UIFont systemFontOfSize:15.0f];
    pingzhengLab.text=[NSString stringWithFormat:@"凭证号：%@",self.infoLiushuiStr];//流水号，self.infoLiushuiStr
    [scrollVi addSubview:pingzhengLab];
//
    UILabel *shouquanmaLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 290, Screen_Width-30, 20)];
    shouquanmaLab.backgroundColor=[UIColor clearColor];
    shouquanmaLab.textColor=[UIColor blackColor];
    shouquanmaLab.textAlignment=NSTextAlignmentLeft;
    shouquanmaLab.font=[UIFont systemFontOfSize:15.0f];
    shouquanmaLab.text=@"授权码：";
    [scrollVi addSubview:shouquanmaLab];
    
    UILabel *timeLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 310, Screen_Width-30, 20)];
    timeLab.backgroundColor=[UIColor clearColor];
    timeLab.textColor=[UIColor blackColor];
    timeLab.textAlignment=NSTextAlignmentLeft;
    timeLab.font=[UIFont systemFontOfSize:15.0f];
    timeLab.text=[NSString stringWithFormat:@"日期/时间：%@",self.timeStr];//self.timeStr
    [scrollVi addSubview:timeLab];
    
    UILabel *cankaoNumberLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 330, Screen_Width-30, 20)];
    cankaoNumberLab.backgroundColor=[UIColor clearColor];
    cankaoNumberLab.textColor=[UIColor blackColor];
    cankaoNumberLab.textAlignment=NSTextAlignmentLeft;
    cankaoNumberLab.font=[UIFont systemFontOfSize:15.0f];
    cankaoNumberLab.text=[NSString stringWithFormat:@"参考号：%@",[PublicInformation stringFromHexString:[PublicInformation returnConsumerSort]]];
    [scrollVi addSubview:cankaoNumberLab];
    
    
    UILabel *moneyInfolab=[[UILabel alloc] initWithFrame:CGRectMake(5, 350, Screen_Width-30, 20)];
    moneyInfolab.backgroundColor=[UIColor clearColor];
    moneyInfolab.textColor=[UIColor blackColor];
    moneyInfolab.textAlignment=NSTextAlignmentLeft;
    moneyInfolab.font=[UIFont systemFontOfSize:15.0f];
    moneyInfolab.text=@"金额(AMOUNT)：";
    [scrollVi addSubview:moneyInfolab];
    
    UILabel *moneyLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 370, Screen_Width-30, 30)];
    moneyLab.backgroundColor=[UIColor clearColor];
    moneyLab.textColor=[UIColor blackColor];
    moneyLab.textAlignment=NSTextAlignmentLeft;
    moneyLab.font=[UIFont systemFontOfSize:20.0f];
    moneyLab.text=[NSString stringWithFormat:@"RMB    %@",[PublicInformation returnConsumerMoney]];//[PublicInformation returnConsumerMoney]
    [scrollVi addSubview:moneyLab];
    
//备注
    UILabel *beizhuLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 400, Screen_Width-30, 20)];
    beizhuLab.backgroundColor=[UIColor clearColor];
    beizhuLab.textColor=[UIColor blackColor];
    beizhuLab.textAlignment=NSTextAlignmentLeft;
    beizhuLab.font=[UIFont systemFontOfSize:15.0f];
    beizhuLab.text=@"备注：";
    [scrollVi addSubview:beizhuLab];
    
    
    float isHeight;
    NSString *lastNum=@"";
    NSString *exchangeTypeStr=[[NSUserDefaults standardUserDefaults] valueForKey:ExchangeMoney_Type];
    if ([exchangeTypeStr isEqualToString:@"撤销支付"]) {
        isHeight=20;
        lastNum=[NSString stringWithFormat:@"原凭证号：%@",self.lastLiushuiStr];
    }else{
        isHeight=0;
        lastNum=@"";
    }
    
    UILabel *yuanpingzhengNumlab=[[UILabel alloc] initWithFrame:CGRectMake(5, 420, Screen_Width-30, isHeight)];
    yuanpingzhengNumlab.backgroundColor=[UIColor clearColor];
    yuanpingzhengNumlab.textColor=[UIColor blackColor];
    yuanpingzhengNumlab.textAlignment=NSTextAlignmentLeft;
    yuanpingzhengNumlab.font=[UIFont systemFontOfSize:15.0f];
    yuanpingzhengNumlab.text=lastNum;//上一次的流水号,撤销支付的时候才有
    [scrollVi addSubview:yuanpingzhengNumlab];
    
    
    UIImageView *lineFourImg=[[UIImageView  alloc] initWithFrame:CGRectMake(5, 419+isHeight, Screen_Width-30, 1)];
    lineFourImg.image=[UIImage imageNamed:@"tabbar_shadow.png"];
    [scrollVi addSubview:lineFourImg];
    
    
    UILabel *signLab=[[UILabel alloc] initWithFrame:CGRectMake(5, 420+isHeight, Screen_Width-30, 20)];
    signLab.backgroundColor=[UIColor clearColor];
    signLab.textColor=[UIColor blackColor];
    signLab.textAlignment=NSTextAlignmentLeft;
    signLab.font=[UIFont systemFontOfSize:15.0f];
    signLab.text=@"签名：";
    [scrollVi addSubview:signLab];
    
    
    UIImageView *signImg=[[UIImageView  alloc] initWithFrame:CGRectMake(5, 440+isHeight, 150, 150)];
//    UIImageView *signImg=[[UIImageView  alloc] initWithFrame:CGRectMake(5, 440+isHeight, Screen_Width-30, 150)];
    signImg.image=posImg;
    [scrollVi addSubview:signImg];
    
    
    UIButton *requireBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    requireBtn.frame=CGRectMake(10, Screen_Height-20-45, [UIScreen mainScreen].bounds.size.width-20, 40);
    [requireBtn setBackgroundImage:[PublicInformation createImageWithColor:[UIColor colorWithRed:0.14 green:0.64 blue:0.17 alpha:1.0]] forState:UIControlStateNormal];
    [requireBtn addTarget:self action:@selector(requireMethod) forControlEvents:UIControlEventTouchUpInside];
    [requireBtn setTitle:@"确定" forState:UIControlStateNormal];
    requireBtn.titleLabel.font=[UIFont systemFontOfSize:20.0f];
    requireBtn.titleLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:requireBtn];
    
    
    self.scrollAllImg=[self getNormalImage:scrollVi];
    scrollVi.frame=CGRectMake(10, 0, Screen_Width-20, Screen_Height-20-50);
//    [self chatUploadImage];
  
}

#pragma mark ----------------屏幕截图
//获取当前屏幕内容
- (UIImage *)getNormalImage:(UIScrollView *)view{
    view.frame=CGRectMake(10, 0, Screen_Width-20, view.contentSize.height);
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
    NSMutableDictionary* headerInfo = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[PublicInformation returnBusiness],
                                                                    [PublicInformation returnBusinessName],
                                                                    [PublicInformation returnConsumerSort],
                                                                    [PublicInformation returnTerminal],
                                                                    [PublicInformation returnMoney],
                                                                    self.timeStr,nil]
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
        
        //NSMutableArray *resultArr=[[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:TheCarcd_Record]];
        NSLog(@"消费前======%@",resultArr);
        
        for (int i=0; i<[resultArr count]; i++) {
            if ([[[resultArr objectAtIndex:i] objectForKey:@"liushui"] isEqualToString:self.infoLiushuiStr]) {
                NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithDictionary:[resultArr objectAtIndex:i]];
                [dic addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:url,@"path", nil]];
                [resultArr replaceObjectAtIndex:i withObject:dic];
            }
        }
        NSLog(@"消费更新图片路径=====%@",resultArr);
        [[NSUserDefaults standardUserDefaults] setObject:resultArr forKey:TheCarcd_Record];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
