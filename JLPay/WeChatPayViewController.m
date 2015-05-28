//
//  WeChatPayViewController.m
//  JLPay
//
//  Created by jielian on 15/5/27.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "WeChatPayViewController.h"
#import "CustPayViewController.h"

@implementation WeChatPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title  = @"微信支付";
    self.navigationController.navigationBarHidden = NO;
    
    
//    self.navigationItem.leftBarButtonItem   = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"jia"] style:UIBarButton target:<#(id)#> action:<#(SEL)#>];
    

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    CustPayViewController* viewController = segue.destinationViewController;
    CustPayViewController* viewController   = segue.sourceViewController;
    viewController.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden       = YES;
    
}

@end
