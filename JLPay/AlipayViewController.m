//
//  AlipayViewController.m
//  JLPay
//
//  Created by jielian on 15/5/27.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "AlipayViewController.h"
#import "CustPayViewController.h"

@implementation AlipayViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title  = @"支付宝支付";
    self.navigationController.navigationBarHidden = NO;

}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CustPayViewController* viewController = segue.destinationViewController;
    viewController.navigationController.navigationBarHidden = YES;
}

@end
