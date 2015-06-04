//
//  NumPayViewController.m
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "NumPayViewController.h"
#import "JHNconnect.h"
#import "Define_Header.h"

@interface NumPayViewController ()
{
    NSTimer *myTimer;
}
@property (strong,nonatomic)JHNconnect *JHNCON;

@end

@implementation NumPayViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    

}
-(void)viewWillAppear:(BOOL)animated
{
    if (self.JHNCON ==NULL)
        self.JHNCON = [JHNconnect shareView];

}


/*
 *   自动补齐金额数值
 *   ----------------------即将被删去或修改为 补充新版本功能；
 */
- (void)change
{
    //无小数点
    if ([_moneyLabel.text rangeOfString:@"."].location == NSNotFound ) {
        _moneyLabel.text=[NSString stringWithFormat:@"%@.00",_moneyLabel.text];
    }else
    {
        //确定小数点后面的位数
        NSInteger length=[_moneyLabel.text length]-([_moneyLabel.text rangeOfString:@"."].location+1);
        if (length >=2) {
            return;
        }else if(length >= 1)
        {
            _moneyLabel.text=[NSString stringWithFormat:@"%@0",_moneyLabel.text];
        }else
        {
            _moneyLabel.text=[NSString stringWithFormat:@"%@00",_moneyLabel.text];
        }
    }
}

/*
 *   按钮点击，改变金额数值
 *   ----------------------即将被删去或修改为 补充新版本功能；
 */
- (IBAction)buttonClick:(UIButton *)sender {
    
//    [myTimer invalidate];
    
    
    NSString *testStr=@"";
    int select=sender.tag;
    //是否包括小数点
    NSRange range = [_moneyLabel.text rangeOfString:@"."];//判断字符串是否包含
    if ( select < 10 ) {
        if ([_moneyLabel.text isEqualToString:@"¥0.00"]) {
            _moneyLabel.text=@"¥";
        }
        //无小数点
        if (range.location ==NSNotFound){//不包含{
            if ([_moneyLabel.text length] >= 6) {
                return;
            }else{
                testStr=[NSString stringWithFormat:@"%d",select];
                _moneyLabel.text=[NSString stringWithFormat:@"%@%@",_moneyLabel.text,testStr];
            }
        }else{
            //有小数点，保留小数点后两位
            if ([_moneyLabel.text length] >= 9){
                return;
            }else{
                //确定小数点后面的位数
                int length=[_moneyLabel.text length]-([_moneyLabel.text rangeOfString:@"."].location+1);
                if (length >= 2) {
                    return;
                }else{
                    _moneyLabel.text=[NSString stringWithFormat:@"%@%@",_moneyLabel.text,[NSString stringWithFormat:@"%d",select]];
                }
            }
            
        }
        
    }
    //小数点
    else if ( select == 10){
        //无小数点
        if (range.location ==NSNotFound){//不包含{
            if ([_moneyLabel.text length] > 6) {
                return;
            }else{
                testStr=@".";
                _moneyLabel.text=[NSString stringWithFormat:@"%@.",_moneyLabel.text];
            }
        }
        //有小数点
        else{
            return;
        }
    }
    //0
    else if ( select == 11){
        if ([_moneyLabel.text isEqualToString:@"¥0.00"]){
            return;
        }
        else{
            //不包含小数点
            if (range.location ==NSNotFound){//不包含{
                if ([_moneyLabel.text length] >= 6) {
                    return;
                }else{
                    _moneyLabel.text=[NSString stringWithFormat:@"%@0",_moneyLabel.text];
                }
            }else{
                //含小数点
                
                int length=[_moneyLabel.text length]-([_moneyLabel.text rangeOfString:@"."].location+1);
                if (length >= 2) {
                    return;
                }else{
                    _moneyLabel.text=[NSString stringWithFormat:@"%@0",_moneyLabel.text];
                }
            }
        }
    }
    // 00
    else if ( select == 12){
        if ([_moneyLabel.text isEqualToString:@"¥0.00"]){
            return;
        }
        else{
            //不包含小数点
            if (range.location ==NSNotFound){//不包含{
                if ([_moneyLabel.text length] >= 5) {
                    return;
                }else{
                    _moneyLabel.text=[NSString stringWithFormat:@"%@00",_moneyLabel.text];
                }
            }else{
                //含小数点
                
                int length=[_moneyLabel.text length]-([_moneyLabel.text rangeOfString:@"."].location+1);
                if (length >= 1) {
                    return;
                }else{
                    _moneyLabel.text=[NSString stringWithFormat:@"%@00",_moneyLabel.text];
                }
            }
        }
    }
    else if ( select == 13){
        if ([_moneyLabel.text isEqualToString:@"¥0.00"]){
            return;
        }
        else if ([_moneyLabel.text length] <= 2) {
            _moneyLabel.text = @"¥0.00";
        }else
        {
            _moneyLabel.text=[_moneyLabel.text substringToIndex:[_moneyLabel.text length]-1];
        }
    }
    
//    myTimer = [NSTimer scheduledTimerWithTimeInterval:waitTime target:self selector:@selector(change) userInfo:nil repeats:NO];

    
}

#pragma mark   -----保存金额数据
-(void)saveConsumerMoney{
    
    NSLog(@"-------%@",[_moneyLabel.text substringFromIndex:1]);
    
    NSString *moneyStr=[NSString stringWithFormat:@"%0.2f",[[_moneyLabel.text substringFromIndex:1] floatValue]];
    [[NSUserDefaults standardUserDefaults] setValue:moneyStr forKey:Consumer_Money];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark  ------跳转刷卡界面
- (IBAction)toBrushClick:(UIButton *)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *viewcon = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
    
    if (![self.JHNCON isConnected])
    {
        UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请连接设备！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        
    }else
    {
        [self saveConsumerMoney];
        [self.navigationController pushViewController:viewcon animated:YES];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*************************************
 * 功  能 : 设置 tableView 的 section 个数;
 * 参  数 :
 *          (UITableView *)tableView  当前表视图
 * 返  回 :
 *          NSInteger                 section 的个数
 *************************************/

@end
