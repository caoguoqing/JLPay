//
//  QianPiViewController.m
//  PosN38Universal
//
//  Created by work on 14-8-22.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import "QianPiViewController.h"
#import "MyView.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "PosInformationViewController.h"
#import "Define_Header.h"
#import "PublicInformation.h"
#import "Packing8583.h"

@interface QianPiViewController ()<UIAlertViewDelegate>
@property (strong,nonatomic)  MyView *drawView;
@property (assign,nonatomic)  BOOL buttonHidden;
@property (assign,nonatomic)  BOOL widthHidden;
@property (nonatomic, strong) UILabel* labelForSigning;
@end

@implementation QianPiViewController
@synthesize uploadImage;
@synthesize exchangeTypeStr;
@synthesize qianpitype;
@synthesize currentLiushuiStr;
@synthesize lastLiushuiStr;
@synthesize labelForSigning;


//撤销支付的流水号
-(void)chexiaozhifuliushui:(NSString *)lastliushui{
    self.lastLiushuiStr=lastliushui;
}

-(void)getCurretnLiushui:(NSString *)liushui{
    self.currentLiushuiStr=liushui;
}

-(void)qianpiType:(int)type{
    self.qianpitype=type;
}
-(void)leftTitle:(NSString *)title{
    self.exchangeTypeStr=title;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏navigationController
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //隐藏状态栏
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden=NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

//保存线条颜色
static NSMutableArray *colors;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isHiddenType=0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    appdeletate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // 自定义标题栏
    UIView *titleView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    titleView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:titleView];
    
    CGRect aframe = CGRectMake(20, 15, 20, 20);
    //￥
    UILabel *managerLab=[[UILabel alloc] initWithFrame:aframe];
    managerLab.text=@"￥";
    managerLab.textAlignment = NSTextAlignmentRight;
    managerLab.font = [UIFont boldSystemFontOfSize:16.0f];
    managerLab.textColor=[UIColor darkGrayColor];
    managerLab.backgroundColor=[UIColor clearColor];
    [titleView  addSubview:managerLab];
    // 金额
    aframe.origin.x += aframe.size.width;
    aframe.origin.y = 5;
    aframe.size.width = 100;
    aframe.size.height = 40;
    UILabel *consumerLab=[[UILabel alloc] initWithFrame:aframe];
    consumerLab.text=self.exchangeTypeStr;
    consumerLab.font = [UIFont boldSystemFontOfSize:20.0f];
    consumerLab.textAlignment = NSTextAlignmentLeft;
    consumerLab.textColor=[UIColor colorWithRed:0.98 green:0.54 blue:0.04 alpha:1.0];
    consumerLab.backgroundColor=[UIColor clearColor];
    [titleView  addSubview:consumerLab];
    
    
    // 交易类型
    aframe.origin.x += aframe.size.width;
    aframe.origin.y += 10;
    aframe.size.width = 80;
    aframe.size.height = 20;
    UILabel *exchangeLab=[[UILabel alloc] initWithFrame:aframe];
    if ([[PublicInformation returnTranType] isEqualToString:TranType_Consume]) {
        exchangeLab.text = @"消费";
    } else if ([[PublicInformation returnTranType] isEqualToString:TranType_ConsumeRepeal]) {
        exchangeLab.text = @"消费撤销";
    }
    exchangeLab.textAlignment = NSTextAlignmentRight;
    exchangeLab.font = [UIFont systemFontOfSize:16.0f];
    exchangeLab.textColor=[UIColor darkGrayColor];
    exchangeLab.backgroundColor=[UIColor clearColor];
    [titleView  addSubview:exchangeLab];
    // -电子签名
    aframe.origin.x += aframe.size.width;
    aframe.origin.y = 5;
    aframe.size.width = Screen_Width - aframe.origin.x;
    aframe.size.height = 40;
    UILabel *signLab=[[UILabel alloc] initWithFrame:aframe];
    signLab.text=@"-电子签名";
    signLab.font = [UIFont systemFontOfSize:20.0f];
    signLab.textColor=[UIColor darkGrayColor];
    signLab.backgroundColor=[UIColor clearColor];
    [titleView  addSubview:signLab];
    
    // 签名有效范围
    returnView=[[UIView alloc] initWithFrame:CGRectMake(10, 50, Screen_Width-20, Screen_Height- 50 - 40 - 20)];
    returnView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:returnView];
    returnView.userInteractionEnabled=YES;
    
    colors=[[NSMutableArray alloc]initWithObjects:[UIColor blackColor], nil];
    //CGRect viewFrame=returnView.frame;
    self.buttonHidden=YES;
    self.widthHidden=YES;
    
    // 签名视图
    self.drawView=[[MyView alloc]initWithFrame:CGRectMake(0, 0, returnView.frame.size.width, returnView.frame.size.height)];
    self.drawView.backgroundColor = [UIColor whiteColor];
    [returnView addSubview: self.drawView];
    // Do any additional setup after loading the view, typically from a nib.
    [returnView addSubview:self.labelForSigning];
    
    
    CGFloat midInset = 20.0;
    CGRect frame = CGRectMake(returnView.frame.origin.x,
                              returnView.frame.origin.y + returnView.frame.size.height,
                              (returnView.frame.size.width - midInset)/2.0,
                              50);
    // 重新签名 按钮
    UIButton*againBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    againBtn.frame = frame;
    againBtn.layer.cornerRadius = 8.0;
    againBtn.backgroundColor = [UIColor colorWithRed:90.0/255.0 green:99.f/255.0 blue:110.f/255.0 alpha:1.0];
    [againBtn setTitle:@"重新签名" forState:UIControlStateNormal];
    [againBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [againBtn addTarget:self action:@selector(againMethod) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:againBtn];
    
    
    UIButton*requireBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    // 确定  按钮
    frame.origin.x += frame.size.width + midInset;
    requireBtn.frame = frame;
    requireBtn.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:58.f/255.0 blue:66.f/255.0 alpha:1.0];
    requireBtn.layer.cornerRadius = 8.0;
    [requireBtn setTitle:@"确认" forState:UIControlStateNormal];
    [requireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requireBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [requireBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

    [requireBtn addTarget:self action:@selector(requireSignMethod) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:requireBtn];
    
    
    // -------- 以下无用了
    newVersionVi=[[NewVersionView alloc] initWithFrame:[UIScreen mainScreen].bounds info:@"签名成功" textHidden:YES];
    newVersionVi.backgroundColor=[UIColor clearColor];
    newVersionVi.passwordStr.hidden=YES;
    newVersionVi.closedBtn.hidden=YES;
    [newVersionVi.requireBtn addTarget:self action:@selector(newVersionMethod) forControlEvents:UIControlEventTouchUpInside];
    newVersionVi.userInteractionEnabled=YES;
    [newVersionVi refresh];
    
    
}

-(void)againMethod{
    [self.drawView clear];
}
-(void)requireSignMethod{
    [self.labelForSigning removeFromSuperview];
    //先截图
    self.uploadImage=[self getNormalImage:returnView];
//    [self exchange];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"签名成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:0.2]];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.message isEqualToString:@"签名成功"]) {
        //状态栏旋转
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        isHiddenType=1;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        PosInformationViewController *posInformationVc=[[PosInformationViewController alloc] init];
        posInformationVc.posImg=self.uploadImage;
        
        [posInformationVc setTransInformation:self.transInformation];
        
        // 跳转到小票界面
        [self.navigationController pushViewController:posInformationVc animated:YES];

    }
}

#pragma mark ----------------屏幕截图
//获取当前屏幕内容
- (UIImage *)getNormalImage:(UIView *)view{
    float width = view.frame.size.width;
    float height = view.frame.size.height;
    UIGraphicsBeginImageContextWithOptions((CGSizeMake(width, height)), NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    image=[UIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark ------------签名成功
-(void)exchange{
    [appdeletate.window addSubview:newVersionVi];
}

-(void)newVersionMethod{

    [newVersionVi removeFromSuperview];
    //状态栏旋转
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    isHiddenType=1;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    PosInformationViewController *posInformationVc=[[PosInformationViewController alloc] init];
    posInformationVc.posImg=self.uploadImage;
    
    // 传递交易信息字典
    [posInformationVc setTransInformation:self.transInformation];
    
    // 跳转到小票界面
    [self.navigationController pushViewController:posInformationVc animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mask --- setter & getter
// 请在绿色区域签名
- (UILabel *)labelForSigning {
    if (labelForSigning == nil) {
        labelForSigning = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        labelForSigning.text = @"请在空白区域内签名";
        labelForSigning.textColor = [UIColor blackColor];
        labelForSigning.backgroundColor = [UIColor clearColor];
    }
    return labelForSigning;
}

@end
