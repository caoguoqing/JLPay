//
//  AdditionalServicesViewController.m
//  JLPay
//
//  Created by jielian on 15/5/18.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//


/* ### 增值服务界面 ### */

#import "AdditionalServicesViewController.h"

#define InsetOfSubViews             6.f                 // 第一个子视图(滚动视图)跟后续子视图组的间隔


@interface AdditionalServicesViewController ()
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIScrollView *dynamicScrollView;
@end

@implementation AdditionalServicesViewController

@synthesize contentScrollView       = _contentScrollView;
@synthesize dynamicScrollView       = _dynamicScrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // 加载主界面视图的 scrollView
    [self initContentScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) initContentScrollView {
    CGFloat visibalHeight           = self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height;   // 可视区域的高度
    CGFloat cellHeight              = visibalHeight / 4.3;                      // 按钮组的单元格高度
    CGFloat cellWidth               = self.view.bounds.size.width / 3.0;        // 按钮组的单元格宽度
    CGFloat y_subViews              = 0;                                        // subViews 的起始y左边点
    CGFloat x_subViews              = 0;                                        // subViews 的起始x左边点
    
    CGRect frame                    = CGRectMake(0, 0, self.view.bounds.size.width, visibalHeight);
    self.contentScrollView          = [[UIScrollView alloc] initWithFrame:frame];
    
    
    // 初始 scrollView 的 size ，后续动态增加了 subviews 后需要更新
    self.contentScrollView.contentSize  = CGSizeMake(self.view.bounds.size.width, 0);
    
    
    // 在 contentScrollView 中添加子 scrollView.....
    //      子 scrollView 里面的图片都是从服务器获取的，包括数据，所以，最好给对应的每个功能以加载网页的方式实现
    self.dynamicScrollView          = [[DynamicScrollView alloc] initWithFrame:CGRectMake(x_subViews, y_subViews, self.view.bounds.size.width, cellHeight * 1.3)];
    [self.contentScrollView addSubview:self.dynamicScrollView];
    // update contentSize.height after adding dynamicScrollView
    self.contentScrollView.contentSize  = CGSizeMake(self.contentScrollView.contentSize.width, self.contentScrollView.contentSize.height + cellHeight * 1.3);
    
    
    y_subViews += cellHeight * 1.3 + InsetOfSubViews + 0.3;
    // 添加 功能按钮组.....
    // 功能用 userDefault 保存,实现动态的维护,包括删除、添加
    
    
    /////////////////////////////////////   1---- 临时添加 按钮组的  方法，后续要扩展为动态添加
    NSArray * imageNames            = [NSArray arrayWithObjects:@"03_07", @"03_12", @"03_09", @"03_18", @"03_20", @"03_23", @"03_28", @"03_29", nil];
    NSArray * buttonNames           = [NSArray arrayWithObjects:@"信用卡还款",
                                                                @"余额查询",
                                                                @"转账汇款",
                                                                @"手机充值",
                                                                @"支付宝充值",
                                                                @"财付通充值",
                                                                @"游戏点卡充值",
                                                                @"交通罚款", nil];
    self.contentScrollView.contentSize  = CGSizeMake(self.contentScrollView.contentSize.width, self.contentScrollView.contentSize.height + cellHeight);
    for (int i = 0; i<imageNames.count; i++) {
        FunctionButton *button          = [[FunctionButton alloc] initWithFrame:CGRectMake(x_subViews, y_subViews, cellWidth, cellHeight)];
        [button setImageViewWith:[imageNames objectAtIndex:i]];
        [button setLabelNameWith:[buttonNames objectAtIndex:i]];
        [self.contentScrollView addSubview:button];
        
        
        if (x_subViews >= cellWidth * 2.0) {
            x_subViews                  = 0;
            y_subViews                  += cellHeight;
            self.contentScrollView.contentSize  = CGSizeMake(self.contentScrollView.contentSize.width, self.contentScrollView.contentSize.height + cellHeight);
        } else {
            x_subViews                  += cellWidth;
        }
        
        
    }
    ///////                                  2 -- 添加完了功能按钮后要添加 "+" 按钮

    AdditionalButton* addButton         = [[AdditionalButton alloc] initWithFrame:CGRectMake(x_subViews, y_subViews, cellWidth, cellHeight)];
    [self.contentScrollView addSubview:addButton];
    /////////////////////////////////////
    
    
    
    [self.view addSubview:self.contentScrollView];
}




@end
