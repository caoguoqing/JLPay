//
//  IPSetViewController.m
//  JLPay
//
//  Created by jielian on 15/4/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "IPSetViewController.h"

@interface IPSetViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtHost;

@property (weak, nonatomic) IBOutlet UITextField *txtPort;

@end

@implementation IPSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.txtHost.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"host"];
    self.txtPort.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"port"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.txtHost resignFirstResponder];
    [self.txtPort resignFirstResponder];

}


- (IBAction)goSave:(id)sender {
    
    [self.txtHost resignFirstResponder];
    [self.txtPort resignFirstResponder];
    
    if ([self.txtHost.text length] > 16) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的IP地址" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.txtPort.text.intValue<0 || self.txtPort.text.intValue>65536) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的端口号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /* 注意:::: 暂时不允许修改服务器IP和PORT */
//    [[NSUserDefaults standardUserDefaults] setObject:self.txtHost.text forKey:@"host"];
//    [[NSUserDefaults standardUserDefaults] setObject:self.txtPort.text forKey:@"port"];
//    
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    PosLib_SetPostCenterParam([self.txtHost.text UTF8String], self.txtPort.text.intValue, 0);
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)hideTabBar {
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    UIView *contentView;
    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    else
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + self.tabBarController.tabBar.frame.size.height);
    self.tabBarController.tabBar.hidden = YES;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self hideTabBar];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.tabBarController.tabBar.hidden = NO;
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
