//
//  CustPayViewController.m
//  JLPay
//
//  Created by jielian on 15/5/15.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "CustPayViewController.h"

#define ImageForBrand   @"logo"                                     // 商标图片
#define NameForBrand    @"捷联通"                                    // 商标名字



@interface CustPayViewController ()
@property (nonatomic, strong) UILabel   *acountOfMoney;             // 金额显示标签栏
@property (nonatomic, assign) CGFloat    money;                     // 金额
@end

@implementation CustPayViewController
@synthesize acountOfMoney               = _acountOfMoney;
@synthesize money                       = _money;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    _acountOfMoney                      = [[UILabel alloc] initWithFrame:CGRectZero];
    _money                              = 0.0;
    
   
    [self addSubViews];
}

/* 金额值的 setter 方法 */
- (void)setMoney:(CGFloat)money {
    if (_money != money) {
        _money                          = money;
        _acountOfMoney.text             = [NSString stringWithFormat:@"%.02f", _money];
    }
}

/*************************************
 * 功  能 : CustPayViewController 的子控件加载;
 *          - 图标          UIImageView + UILabel
 *          - 金额显示框     UILabel
 *          - 数字按键组     UIButtons
 *          - 其他支付按钮   UIButtons
 *          - 刷卡按钮       UIButton
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) addSubViews {
    CGFloat numFontSize                 = 26.0;
    CGFloat statusBarHeight             = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat visibleHeight               = self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height - statusBarHeight;
    CGFloat  bornerWith                 = 1.0;

    
    // 图标          3/8/3.3
    CGFloat littleHeight                = visibleHeight * (3.0/8.0/3.3);
    CGFloat littleHeight_2              = littleHeight * 0.8;
    CGRect  frame                       = CGRectMake((self.view.bounds.size.width - littleHeight_2*3)/2,
                                         0 + statusBarHeight + (littleHeight - littleHeight_2)/2.0,
                                         littleHeight_2*3,
                                         littleHeight_2);
    UIImageView *imageView              = [[UIImageView alloc] initWithFrame:frame];
    imageView.image                     = [UIImage imageNamed:ImageForBrand];

    [self.view addSubview:imageView];
    
    
    // 金额显示框     1/8
    CGFloat bigHeight                   = visibleHeight * 1.0/8.0;
    frame.origin.x                      = 0 + bornerWith;
    frame.origin.y                      += littleHeight + bornerWith - (littleHeight - littleHeight_2)/2.0;
    frame.size.width                    = self.view.bounds.size.width - bornerWith*2;
    frame.size.height                   = bigHeight - bornerWith * 2;
    UIView  *moneyView                  = [[UIView alloc] initWithFrame:frame];
    moneyView.backgroundColor           = [UIColor colorWithWhite:0.7 alpha:0.5];
    [self.view addSubview:moneyView];
    
    // moneyLabel
    CGRect innerFrame                   = CGRectMake(0, 0, frame.size.width - 40, frame.size.height);
    self.acountOfMoney.frame            = innerFrame;
    self.acountOfMoney.text             = [NSString stringWithFormat:@"%.02f", self.money];
    self.acountOfMoney.textAlignment    = NSTextAlignmentRight;
    self.acountOfMoney.font             = [UIFont boldSystemFontOfSize:35];
    [moneyView addSubview:self.acountOfMoney];
    
    // moneyImageView ...............
    CGRect moneySymbolFrame             = CGRectMake(innerFrame.origin.x + innerFrame.size.width + 5.0, frame.size.height/2.0, frame.size.height/4.0/4.0 * 3.0, frame.size.height/4.0);
    UILabel *moneySymbolLabel           = [[UILabel alloc] initWithFrame:moneySymbolFrame];
    moneySymbolLabel.text               = @"￥";
    moneySymbolLabel.font               = [UIFont systemFontOfSize:15];
    [moneyView addSubview:moneySymbolLabel];
    
    // 数字按键组     4/8
    NSArray * numbers                   = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@".",@"0",@"-",nil];
    frame.origin.y                      += bigHeight - bornerWith;
    frame.size.width                    = self.view.bounds.size.width/3.0;
    frame.size.height                   = bigHeight;
    int index                           = 0;
    for (int i = 0; i<4; i++) {
        frame.origin.x                  = 0.0;
        if (i == 3) {
            frame.origin.y              -= 0.6;
        }

        for (int j = 0; j<3; j++) {
            // frame 都已经准备好，可以直接装填数字按钮组了
            
            /////////// testing...
            if (i == 3 && j == 2) {
                DeleteButton * button   = [[DeleteButton alloc] initWithFrame:frame];
                button.layer.borderWidth    = 0.3;
                button.layer.borderColor    = [UIColor colorWithWhite:0.8 alpha:0.5].CGColor;
                
                [self.view addSubview:button];
            } else {
                
                UIButton *button            = [[UIButton alloc] initWithFrame:frame];
                [button setTitle:[numbers objectAtIndex:index] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button.titleLabel.font      = [UIFont boldSystemFontOfSize:numFontSize];
                button.layer.borderWidth    = 0.3;
                button.layer.borderColor    = [UIColor colorWithWhite:0.8 alpha:0.5].CGColor;
                
                [self.view addSubview:button];
            }
            

            /////////////////////
            
            index++;
            frame.origin.x              += frame.size.width;
        }
        frame.origin.y                  += bigHeight;
    }
    
    // 支付宝按钮   3/8/3.3
    frame.origin.x                      = 0 + bornerWith;
    frame.origin.y                      += bornerWith;
    frame.size.width                    = self.view.bounds.size.width/2.0 - bornerWith*2;
    frame.size.height                   = littleHeight - bornerWith*2;
    OtherPayButton *alipayButton        = [[OtherPayButton alloc] initWithFrame:frame];

    // 添加 action ..........................
    

    
    [alipayButton setImageViewWithName:@"zfb"];
    [alipayButton setLabelNameWithName:@"支付宝支付"];
    [self.view addSubview:alipayButton];
    
    // 微信按钮
    frame.origin.x                      += self.view.bounds.size.width/2.0;
    OtherPayButton *weChatButton        = [[OtherPayButton alloc] initWithFrame:frame];
    // 添加 action ..........................
    [weChatButton setImageViewWithName:@"wx"];
    [weChatButton setLabelNameWithName:@"微信支付"];
    [self.view addSubview:weChatButton];
    
    // 刷卡按钮       3/8/3.3 * 1.3
    CGFloat newBornerWith               = 2.0;
    frame.origin.x                      = 0 + newBornerWith;
    frame.origin.y                      += frame.size.height + bornerWith + newBornerWith;
    frame.size.width                    = self.view.bounds.size.width - newBornerWith*2;
    frame.size.height                   = littleHeight * 1.3 - newBornerWith*2;
    UIButton *brushButton               = [[UIButton alloc] initWithFrame:frame];
    brushButton.layer.cornerRadius      = 8.0;
    brushButton.backgroundColor         = [UIColor redColor];
    [brushButton setTitle:@"开始刷卡" forState:UIControlStateNormal];
    [brushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    brushButton.titleLabel.font         = [UIFont boldSystemFontOfSize:32];
    // 添加 action ..........................
    [brushButton addTarget:self action:@selector(beginBrush:) forControlEvents:UIControlEventTouchDown];
    [brushButton addTarget:self action:@selector(toBrush:) forControlEvents:UIControlEventTouchUpInside];
    [brushButton setSelected:YES];
    [self.view addSubview:brushButton];

    
}

/*************************************
 * 功  能 : 刷卡按钮的点击动画效果;
 * 参  数 :
 *          (id)sender                发起转场动作的按钮：放大、缩小
 * 返  回 : 无
 *************************************/
- (IBAction) toBrush:(UIButton*)sender {
    sender.transform = CGAffineTransformMakeScale(1.0/0.99, 1.0/0.99);
    self.money += 1;
}
- (IBAction)beginBrush:(UIButton*)sender {
    sender.transform = CGAffineTransformMakeScale(0.99, 0.99);
}


#pragma mark - Navigation
/*************************************
 * 功  能 : 刷卡界面转场协议方法;
 * 参  数 :
 *          (UIStoryboardSegue *)segue  转场句柄
 *          (id)sender                  发起转场动作的控件
 * 返  回 :
 *          NSInteger                 section 的个数
 *************************************/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
