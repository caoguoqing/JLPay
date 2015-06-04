//
//  TerminalParamSetViewController.m
//  JLPay
//
//  Created by jielian on 15/4/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "TerminalParamSetViewController.h"


static const char *PosLib_GetStr(NSString *str)
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data=[str dataUsingEncoding: enc];
    return (const char *)[data bytes];
}

@interface TerminalParamSetViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtShopid;
@property (weak, nonatomic) IBOutlet UITextField *txtDeviceid;
@property (weak, nonatomic) IBOutlet UITextField *txtManufacturerID;
@property (weak, nonatomic) IBOutlet UITextField *txtTPDU;


@end

@implementation TerminalParamSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.txtShopid.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"shop_id"];
    self.txtDeviceid.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"device_id"];
    self.txtManufacturerID.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"ManufacturerID"];
    self.txtTPDU.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"TPDU"];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.txtShopid resignFirstResponder];
    [self.txtDeviceid resignFirstResponder];
    [self.txtManufacturerID resignFirstResponder];
    [self.txtTPDU resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
}
- (void)keyboardHide:(NSNotification *)notf
{
    NSLog(@"1111");

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    
    if(textField==self.txtShopid) {
        [self.txtShopid resignFirstResponder];
        [self.txtDeviceid becomeFirstResponder];
    } else if(textField==self.txtDeviceid) {
        [self.txtDeviceid resignFirstResponder];
        [self.txtManufacturerID becomeFirstResponder];
    } else if(textField==self.txtManufacturerID) {
        [self.txtManufacturerID resignFirstResponder];
        [self.txtTPDU becomeFirstResponder];
    } else if(textField==self.txtTPDU) {
        [self.txtTPDU resignFirstResponder];
    }

    
    return YES;
}

- (IBAction)goSave:(id)sender
{
    [self.txtShopid resignFirstResponder];
    [self.txtDeviceid resignFirstResponder];
    [self.txtManufacturerID resignFirstResponder];
    [self.txtTPDU resignFirstResponder];
    
    if ([self.txtShopid.text length] > 15) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的商户号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([self.txtDeviceid.text length] > 8) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的终端号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([self.txtManufacturerID.text length] > 10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的厂商ID" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([self.txtTPDU.text length] > 10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的TPDU" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.txtShopid.text forKey:@"shop_id"];
    [[NSUserDefaults standardUserDefaults] setObject:self.txtDeviceid.text forKey:@"device_id"];
    [[NSUserDefaults standardUserDefaults] setObject:self.txtManufacturerID.text forKey:@"ManufacturerID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.txtTPDU.text forKey:@"TPDU"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    PosLib_SetPublicParam(PosLib_GetStr(self.txtShopid.text)
//                          , PosLib_GetStr(self.txtDeviceid.text)
//                          , PosLib_GetStr(self.txtManufacturerID.text)
//                          , PosLib_GetStr(self.txtTPDU.text));
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardShow:(NSNotification *)notf
{
    NSDictionary *userInfo = notf.userInfo;
    
    CGRect keyboardFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
    
    CGRect textFrame = self.txtShopid.frame;
    
    if (CGRectGetMaxY(textFrame) >= CGRectGetMinY(keyboardFrame)) {
        
        CGFloat y = CGRectGetMinY(keyboardFrame) - CGRectGetMaxY(textFrame);
        CGRect frame = self.view.frame;
        frame.origin.y = y;
        
        self.view.frame = frame;
    }
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
    //    self.tabBarController.tabBar.hidden = YES;
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
