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

@interface QianPiViewController ()
@property (strong,nonatomic)  MyView *drawView;
@property (assign,nonatomic)  BOOL buttonHidden;
@property (assign,nonatomic)  BOOL widthHidden;
@end

@implementation QianPiViewController
@synthesize uploadImage;
@synthesize exchangeTypeStr;
@synthesize qianpitype;
@synthesize currentLiushuiStr;
@synthesize lastLiushuiStr;


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
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"parenttabbar.png"] forBarMetrics:UIBarMetricsDefault];
    //隐藏navigationController
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //隐藏状态栏
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (isHiddenType == 0) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"parenttabbar.png"] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.hidden=YES;
        //显示状态栏
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        //显示navigationController
    }else{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"parenttabbar.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        //显示状态栏
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        //显示navigationController
    }
    
}


//保存线条颜色
static NSMutableArray *colors;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isHiddenType=0;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"parenttabbar.png"] forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor=[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    appdeletate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //设置应用程序的状态栏到指定的方向
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
    //view旋转
//    [self.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    
    UIView *titleView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    titleView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:titleView];
    
    //￥
    //撤销支付
    UILabel *managerLab=[[UILabel alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
    managerLab.text=@"￥";
    managerLab.font = [UIFont systemFontOfSize:16.0f];
    managerLab.textColor=[UIColor darkGrayColor];
    managerLab.backgroundColor=[UIColor clearColor];
    [titleView  addSubview:managerLab];
    
    UILabel *consumerLab=[[UILabel alloc] initWithFrame:CGRectMake(35, 5, 120, 40)];
    consumerLab.text=self.exchangeTypeStr;
    consumerLab.font = [UIFont systemFontOfSize:20.0f];
    consumerLab.textColor=[UIColor colorWithRed:0.98 green:0.54 blue:0.04 alpha:1.0];
    consumerLab.backgroundColor=[UIColor clearColor];
    [titleView  addSubview:consumerLab];
    //消费-电子签名
    UILabel *exchangeLab=[[UILabel alloc] initWithFrame:CGRectMake((Screen_Width-120)/2, 15, 40, 20)];
    exchangeLab.text=@"消费-";
    exchangeLab.font = [UIFont systemFontOfSize:16.0f];
    exchangeLab.textColor=[UIColor darkGrayColor];
    exchangeLab.backgroundColor=[UIColor clearColor];
    [titleView  addSubview:exchangeLab];
    
    UILabel *signLab=[[UILabel alloc] initWithFrame:CGRectMake((Screen_Width-120)/2+40, 5, 80, 40)];
    signLab.text=@"电子签名";
    signLab.font = [UIFont systemFontOfSize:20.0f];
    signLab.textColor=[UIColor darkGrayColor];
    signLab.backgroundColor=[UIColor clearColor];
    [titleView  addSubview:signLab];
    
    //捷联通
    
    UILabel *renrenLab=[[UILabel alloc] initWithFrame:CGRectMake(Screen_Width-120, 10, 80, 30)];
    renrenLab.text=@"捷联通";
    renrenLab.font = [UIFont systemFontOfSize:16.0f];
    renrenLab.textColor=[UIColor blackColor];
    renrenLab.backgroundColor=[UIColor clearColor];
    renrenLab.textAlignment=NSTextAlignmentRight;
    [titleView  addSubview:renrenLab];
    
    //横线
    UILabel *lineLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 48, Screen_Width, 2)];
    lineLab.backgroundColor=[UIColor colorWithRed:0.98 green:0.54 blue:0.04 alpha:1.0];
    [titleView  addSubview:lineLab];
    
    
    returnView=[[UIView alloc] initWithFrame:CGRectMake(10, 50, Screen_Width-20, Screen_Height-90)];
    returnView.backgroundColor=[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [self.view addSubview:returnView];
    returnView.userInteractionEnabled=YES;
    
    colors=[[NSMutableArray alloc]initWithObjects:[UIColor blackColor], nil];
    //CGRect viewFrame=returnView.frame;
    self.buttonHidden=YES;
    self.widthHidden=YES;
    self.drawView=[[MyView alloc]initWithFrame:CGRectMake(0, 0, returnView.frame.size.width, returnView.frame.size.height)];
    [self.drawView setBackgroundColor:[UIColor whiteColor]];
    [returnView addSubview: self.drawView];
    //[returnView sendSubviewToBack:self.drawView];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //流水号
    UILabel *sortLab=[[UILabel alloc] initWithFrame:CGRectMake((returnView.frame.size.width-150)/2, (returnView.frame.size.height-40)/2, 150, 40)];
    sortLab.text=self.currentLiushuiStr;
    sortLab.font = [UIFont systemFontOfSize:40.0f];
    sortLab.textColor=[UIColor blackColor];
    sortLab.backgroundColor=[UIColor redColor];
    sortLab.textAlignment=NSTextAlignmentCenter;
    [returnView  addSubview:sortLab];
    
    
    UIButton*againBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    againBtn.frame=CGRectMake((Screen_Width-100*2-40)/2,Screen_Height-40,100,40);
    againBtn.backgroundColor=[UIColor whiteColor];
    [againBtn setTitle:@"重新签名" forState:UIControlStateNormal];
    [againBtn addTarget:self action:@selector(againMethod) forControlEvents:UIControlEventTouchUpInside];
    [againBtn setBackgroundImage:[UIImage imageNamed:@"resign_normal.png"] forState:UIControlStateNormal];
    [againBtn setBackgroundImage:[UIImage imageNamed:@"resign_pressed.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:againBtn];
    
    
    UIButton*requireBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    requireBtn.frame=CGRectMake((Screen_Width-100*2-40)/2+100+40,Screen_Height-40,100,40);
    requireBtn.backgroundColor=[UIColor whiteColor ];
    [requireBtn setTitle:@"确认" forState:UIControlStateNormal];
    [requireBtn addTarget:self action:@selector(requireSignMethod) forControlEvents:UIControlEventTouchUpInside];
    [requireBtn setBackgroundImage:[UIImage imageNamed:@"sign_ok_normal.png"] forState:UIControlStateNormal];
    [requireBtn setBackgroundImage:[UIImage imageNamed:@"sign_ok_pressed.png"] forState:UIControlStateHighlighted];
    
    [self.view addSubview:requireBtn];
    
    
    newVersionVi=[[NewVersionView alloc] initWithFrame:[UIScreen mainScreen].bounds info:@"签名成功" textHidden:YES];
    newVersionVi.backgroundColor=[UIColor clearColor];
//    [newVersionVi setTransform:CGAffineTransformMakeRotation(M_PI/2)];
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
    //先截图
    self.uploadImage=[self getNormalImage:returnView];
    [self exchange];
    //[self chatUploadImage];
}

#pragma mark ----------------屏幕截图
//获取当前屏幕内容
- (UIImage *)getNormalImage:(UIView *)view{
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    UIGraphicsBeginImageContextWithOptions((CGSizeMake(height, width)), NO, 1.0);
    //UIGraphicsBeginImageContext(CGSizeMake(width, height));
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
//    [self newVersionMethod];
}

-(void)newVersionMethod{
    
    [newVersionVi removeFromSuperview];
    //[self.view removeFromSuperview];
    //状态栏旋转
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    isHiddenType=1;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //[appdeletate returnApplocation];
    PosInformationViewController *posInformationVc=[[PosInformationViewController alloc] init];
    posInformationVc.posImg=self.uploadImage;
    [posInformationVc liushuiNum:self.currentLiushuiStr time:[PublicInformation formatCompareDate] lastliushuinum:self.lastLiushuiStr];
    [self.navigationController pushViewController:posInformationVc animated:YES];
//    [self presentViewController:posInformationVc animated:YES completion:nil];
    
    /*
     self.navigationController.navigationBar.hidden=NO;
     [newVersionVi removeFromSuperview];
     [self.view removeFromSuperview];
     //状态栏旋转
     [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
     [self.navigationController popToRootViewControllerAnimated:YES];
     */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
