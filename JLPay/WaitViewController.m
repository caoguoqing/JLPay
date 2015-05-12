//
//  WaitViewController.m
//  JLPay
//
//  Created by jielian on 15/4/17.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "WaitViewController.h"
#import "TCP/TcpClientService.h"
#import "GroupPackage8583.h"
#import "Unpacking8583.h"
#import "Define_Header.h"
#import "Toast+UIView.h"
#import "QianPiViewController.h"



@interface WaitViewController ()<wallDelegate,managerToCard>

@end

@implementation WaitViewController
@synthesize resultType;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    //数据上送中，请稍后
    self.view.backgroundColor=[UIColor whiteColor];//[UIColor colorWithRed:0.92 green:0.93 blue:0.98 alpha:1.0];
    self.errorString=@"";
    
    //数据上传整个界面
    backView=[[UIView alloc] initWithFrame:self.view.bounds];
    backView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:backView];
    
    
    [self falseMethod];
    
    falseView.hidden=YES;
    
    UIImageView *upImg=[[UIImageView alloc] initWithFrame:CGRectMake((320-60)/2, (self.view.frame.size.height-240)/2, 60, 60)];
    upImg.image=[UIImage imageNamed:@"icon.png"];
    [backView addSubview:upImg];
    
    UIImageView *downImg=[[UIImageView alloc] initWithFrame:CGRectMake(10, (self.view.frame.size.height-240)/2+60+10, 300, 120)];
    downImg.image=[UIImage imageNamed:@"trading_bg.png"];
    [backView addSubview:downImg];
    downImg.userInteractionEnabled=YES;
    
    UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, 300, 30)];
    titleLab.text=@"数据上送中请稍候...";
    titleLab.font = [UIFont systemFontOfSize:18.0f];
    titleLab.textColor=[UIColor blackColor];
    titleLab.backgroundColor=[UIColor clearColor];
    titleLab.textAlignment=NSTextAlignmentCenter;
    [downImg addSubview:titleLab];
    
    UIImageView *lineImg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 40,     self.view.frame.size.width
                                                                       -20, 1)];
    lineImg.image=[UIImage imageNamed:@"line2.png"];
    [downImg addSubview:lineImg];
    
    
    UILabel *timeInfoLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 300, 25)];
    timeInfoLab.text=@"倒计时";
    timeInfoLab.font = [UIFont systemFontOfSize:16.0f];
    timeInfoLab.textColor=[UIColor darkGrayColor];
    timeInfoLab.backgroundColor=[UIColor clearColor];
    timeInfoLab.textAlignment=NSTextAlignmentCenter;
    [downImg  addSubview:timeInfoLab];
    
    timeLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 75, 300, 35)];
    timeLab.text=@"60秒";
    timeLab.font = [UIFont systemFontOfSize:18.0f];
    timeLab.textColor=[UIColor redColor];
    timeLab.backgroundColor=[UIColor clearColor];
    timeLab.textAlignment=NSTextAlignmentCenter;
    [downImg  addSubview:timeLab];
    
    //倒计时开始
    [NSThread detachNewThreadSelector:@selector(startTimer) toTarget:self withObject:nil];
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark--------------------------------------失败后的界面
-(void)falseMethod{
    falseView=[[UIView alloc] initWithFrame:self.view.bounds];
    falseView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:falseView];
    
    UIImageView *upImg=[[UIImageView alloc] initWithFrame:CGRectMake((    self.view.frame.size.width
                                                                      -60)/2, (    self.view.frame.size.height-240)/2-20, 60, 60)];
    upImg.image=[UIImage imageNamed:@"icon.png"];
    [falseView addSubview:upImg];
    
    UIImageView *downImg=[[UIImageView alloc] initWithFrame:CGRectMake(10, (    self.view.frame.size.height-240)/2+60, 300, 120)];
    downImg.image=[UIImage imageNamed:@"trading_bg.png"];
    [falseView addSubview:downImg];
    downImg.userInteractionEnabled=YES;
    
    UIImageView *falseImag=[[UIImageView alloc] initWithFrame:CGRectMake((300-50)/2, 15, 50, 50)];
    falseImag.image=[UIImage imageNamed:@"fail.png"];
    [downImg addSubview:falseImag];
    
    UILabel *falseLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 85, 300, 30)];
    falseLab.tag=2345;
    falseLab.text=[NSString stringWithFormat:@"失败原因:%@",self.errorString];
    falseLab.numberOfLines = 0;
    falseLab.font = [UIFont systemFontOfSize:18.0f];
    falseLab.textColor=[UIColor blackColor];
    falseLab.backgroundColor=[UIColor clearColor];
    falseLab.textAlignment=NSTextAlignmentCenter;
    [downImg  addSubview:falseLab];
    
    
    UIButton *continueBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    continueBtn.frame=CGRectMake((    self.view.frame.size.width
                                  -120)/2, (    self.view.frame.size.height-240)/2+60+140, 120, 40);
    [continueBtn setBackgroundImage:[UIImage imageNamed:@"swipe_continue_normal.png"] forState:UIControlStateNormal];
    [continueBtn setBackgroundImage:[UIImage imageNamed:@"swipe_continue_pressed.png"] forState:UIControlStateHighlighted];
    [continueBtn setTitle:@"重新刷卡" forState:UIControlStateNormal];
    continueBtn.backgroundColor = [UIColor redColor];
    [continueBtn addTarget:self action:@selector(continueTrackMethod) forControlEvents:UIControlEventTouchUpInside];
    [falseView addSubview:continueBtn];
    
}

-(void)falseTheLabel{
    UILabel *label=(UILabel *)[self.view viewWithTag:2345];
    label.text=[NSString stringWithFormat:@"失败原因:%@",self.errorString];
}


/**
 *    继续刷卡
 */
-(void)continueTrackMethod{
    [self.navigationController popToRootViewControllerAnimated:YES];
}



#pragma mark--------------------------------------------定时器设置
-(void)timeStart{
    secondsCountDown = 60;//60秒倒计时
    
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}
-(void)timeFireMethod{
    secondsCountDown--;
    timeLab.text=[NSString stringWithFormat:@"%d秒",secondsCountDown];
    
    if (secondsCountDown == 55) {
        [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 consume:self.pinstr] IP:Current_IP PORT:Current_Port Delegate:self method:@"cousume"];
        
    }
    if(secondsCountDown==0){
        [countDownTimer invalidate];
        //未接收到短信验证码？重新获取
        if (self.resultType == 1) {
            self.errorString=@"连接超时,消费失败";
        }else if(self.resultType == 2){
            self.errorString=@"连接超时,查询失败";
        }
        self.errorString=@"连接超时,消费失败";
        
        backView.hidden=YES;
        falseView.hidden=NO;
        [self falseTheLabel];
    }
}

-(void)startTimer{
    [self timeStart];
}

#pragma mark--------------------------------------------walldelegate

-(void)receiveGetData:(NSString *)data method:(NSString *)str{
    //[app_delegate dismissWaitingView];
    if ([str isEqualToString:@"cousume"]) {
        NSLog(@"消费数据接收======%@",data);
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            //[self.view makeToast:@"消费失败"];
            self.errorString=@"连接超时,消费失败";
            backView.hidden=YES;
            falseView.hidden=NO;
            [self falseTheLabel];
        }
    }
    //IC卡消费
    else if ([str isEqualToString:@"blue_cousume"]){
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            //[self.view makeToast:@"消费失败"];
            self.errorString=@"连接超时,消费失败";
            backView.hidden=YES;
            falseView.hidden=NO;
            [self falseTheLabel];
        }
    }
    //磁条卡查询
    else if ([str isEqualToString:@"balancesearch"]) {
        NSLog(@"查询数据接收======%@",data);
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
            
        }else{
            self.errorString=@"连接超时,查询失败";
            backView.hidden=YES;
            falseView.hidden=NO;
            [self falseTheLabel];
        }
    }
    //IC卡查询
    else if ([str isEqualToString:@"blue_balancesearch"]){
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
            
        }else{
            self.errorString=@"连接超时,查询失败";
            backView.hidden=YES;
            falseView.hidden=NO;
            [self falseTheLabel];
        }
    }
    //消费冲正
    else if ([str isEqualToString:@"cousumereturn"]) {
        NSLog(@"消费冲正数据接收======%@",data);
        
        [self.view makeToast:@"撤销结束"];
        self.resultType=333;
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }
    }
}

-(void)falseReceiveGetDataMethod:(NSString *)str{
    
    //NSLog(@"err====%@",err);
}


#pragma mark--------------------------------------------managerToCard

-(void)managerToCardState:(NSString *)type  isSuccess:(BOOL)state method:(NSString *)metStr{
    
    //消费
    if ([metStr isEqualToString:@"cousume"]) {//self.resultType == 1
        NSLog(@"state======%d",state);
        NSLog(@"消费type====%@,metStr====%@",type,metStr);
        if (state) {
            [countDownTimer invalidate];
            
            NSLog(@"*****************消费成功*****************");
            //            [self.view makeToast:type];
            QianPiViewController  *qianpi=[[QianPiViewController alloc] init];
            [qianpi qianpiType:1];
            [qianpi getCurretnLiushui:[PublicInformation returnLiushuiHao]];
            [qianpi leftTitle:[PublicInformation returnMoney]];
            
            //            [self presentViewController:qianpi animated:YES completion:nil];
            
            [self.navigationController pushViewController:qianpi animated:YES];
            
            
            
        }else{
            [countDownTimer invalidate];
            self.errorString=type;
            //[self.view makeToast:type];
            backView.hidden=YES;
            falseView.hidden=NO;
            [self falseTheLabel];
            //消费冲正
            //[self consumerReturnMethod];
        }
    }
    //IC卡消费
    else if ([metStr isEqualToString:@"blue_cousume"]){
        if (state) {
            [countDownTimer invalidate];
            //[self.view makeToast:type];
            //            QianPiViewController  *qianpi=[[QianPiViewController alloc] init];
            //            [qianpi qianpiType:1];
            //            [qianpi getCurretnLiushui:[PublicInformation returnLiushuiHao]];
            //            [qianpi leftTitle:[PublicInformation returnMoney]];
            //            [self.navigationController pushViewController:qianpi animated:YES];
        }else{
            [countDownTimer invalidate];
            self.errorString=type;
            //[self.view makeToast:type];
            backView.hidden=YES;
            falseView.hidden=NO;
            [self falseTheLabel];
            //消费冲正
            //[self consumerReturnMethod];
        }
    }
    //消费冲正
    else if ([metStr isEqualToString:@"cousumereturn"]){//self.resultType == 333
        NSLog(@"消费冲正type====%@,metStr====%@",type,metStr);
        
    }
    //查询
    else if([metStr isEqualToString:@"balancesearch"]){
        NSLog(@"余额查询type====%@,metStr====%@",type,metStr);
        //余额查询
        if (state) {
            [countDownTimer invalidate];
            //[self.view makeToast:type];
            //            SearchMoneyViewController *searchMoneyVc=[[SearchMoneyViewController alloc] init];
            //            [self.navigationController pushViewController:searchMoneyVc animated:YES];
        }else{
            self.errorString=type;
            //[self.view makeToast:type];
            backView.hidden=YES;
            falseView.hidden=NO;
            [self falseTheLabel];
        }
    }//blue_balancesearch
    //IC卡余额查询
    else if([metStr isEqualToString:@"blue_balancesearch"]){
        if (state) {
            //            [countDownTimer invalidate];
            //            SearchMoneyViewController *searchMoneyVc=[[SearchMoneyViewController alloc] init];
            //            [self.navigationController pushViewController:searchMoneyVc animated:YES];
        }else{
            self.errorString=type;
            backView.hidden=YES;
            falseView.hidden=NO;
            [self falseTheLabel];
        }
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
