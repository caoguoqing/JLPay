//
//  CustPayViewController.m
//  JLPay
//
//  Created by jielian on 15/5/15.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "CustPayViewController.h"
#import "JHNconnect.h"
#import "Define_Header.h"
#import "DisplayMoneyText.h"
#import "Define_Header.h"



#define ImageForBrand   @"logo"                                             // 商标图片
#define NameForBrand    @"捷联通"                                            // 商标名字



@interface CustPayViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong) UILabel           *acountOfMoney;             // 金额显示标签栏
@property (nonatomic)         NSString*         money;                      // 金额
@property (nonatomic, strong) NSMutableArray    *moneyArray;                // 模拟金额栈：保存历史金额
@property (strong,nonatomic)  JHNconnect        *JHNCON;                    // 通讯入口
@property (nonatomic, strong) DisplayMoneyText* moneyStr;                   // 用来收集数字按钮点击的金额计算的类

@end

@implementation CustPayViewController
@synthesize acountOfMoney               = _acountOfMoney;
@synthesize money                       = _money;
@synthesize moneyArray                  = _moneyArray;
@synthesize moneyStr                    = _moneyStr;



- (void)viewDidLoad {
    [super viewDidLoad];
    _acountOfMoney                      = [[UILabel alloc] initWithFrame:CGRectZero];
    _moneyArray                         = [[NSMutableArray alloc] init];
    _moneyStr                           = [[DisplayMoneyText alloc] init];
    _money                              = [_moneyStr money];

   
    [self addSubViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.JHNCON ==NULL)
        self.JHNCON = [JHNconnect shareView];
    
    self.navigationController.navigationBarHidden = YES;
    
    // 检测并打开设备
//    AppDelegate* delegate           = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    if (![delegate.device isConnected]) {
//    }
//    [delegate.device  open];

    [super viewWillAppear:animated];
}


/* 金额值的 setter 方法 */
- (void)setMoney:(NSString*)money {
    if (![_money isEqualToString: money]) {
        _money                          = money;
        _acountOfMoney.text             = _money;
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
    CGFloat numFontSize                 = 30.0;
    CGFloat statusBarHeight             = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat visibleHeight               = self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height - statusBarHeight;
    CGFloat  bornerWith                 = 0.5;

    
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
    moneyView.backgroundColor           = [UIColor colorWithRed:180.0/255.0 green:188.0/255.0 blue:194.0/255.0 alpha:1.0];
    [self.view addSubview:moneyView];
    
    // moneyLabel
    CGRect innerFrame                   = CGRectMake(0, 0, frame.size.width - 40, frame.size.height);
    self.acountOfMoney.frame            = innerFrame;
    self.acountOfMoney.text             = @"0.00";
    self.acountOfMoney.textAlignment    = NSTextAlignmentRight;
    self.acountOfMoney.font             = [UIFont boldSystemFontOfSize:37];
    [moneyView addSubview:self.acountOfMoney];
    
    // moneyImageView ...............
    CGRect moneySymbolFrame             = CGRectMake(innerFrame.origin.x + innerFrame.size.width + 5.0, frame.size.height/2.0, frame.size.height/4.0/4.0 * 3.0, frame.size.height/4.0);
    UILabel *moneySymbolLabel           = [[UILabel alloc] initWithFrame:moneySymbolFrame];
    moneySymbolLabel.text               = @"￥";
    moneySymbolLabel.font               = [UIFont systemFontOfSize:15];
    [moneyView addSubview:moneySymbolLabel];
    
    // 数字按键组     4/8
    NSArray * numbers                   = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@".",@"0",@"delete",nil];
    frame.origin.y                      += bigHeight - bornerWith;
    frame.size.width                    = self.view.bounds.size.width/3.0;
    frame.size.height                   = bigHeight;
    NSInteger index                     = 0;
    for (int i = 0; i<4; i++) {
        frame.origin.x                  = 0.0;
        if (i == 3) {
            frame.origin.y              -= 0.6;
        }
        for (int j = 0; j<3; j++) {
            // frame 都已经准备好，可以直接装填数字按钮组了
            id button;
            /////////// testing...
            // “撤销”按钮
            if (i == 3 && j == 2) {
                button                                          = [[DeleteButton alloc] initWithFrame:frame];
                ((DeleteButton*)button).layer.borderWidth       = 0.3;
                ((DeleteButton*)button).layer.borderColor       = [UIColor colorWithWhite:0.8 alpha:0.5].CGColor;
                [(DeleteButton*)button  addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
                [(DeleteButton*)button  addTarget:self action:@selector(touchUpDelete:) forControlEvents:UIControlEventTouchUpInside];
                [(DeleteButton*)button  addTarget:self action:@selector(touchUpOut:) forControlEvents:UIControlEventTouchUpOutside];
                // 给撤销按钮添加一个长按事件:将金额清零,金额栈也清0
                UILongPressGestureRecognizer *longPress         = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressButtonOfDelete:)];
                longPress.minimumPressDuration                  = 0.8;
                [(DeleteButton*)button addGestureRecognizer:longPress];
                // addSubview
                [self.view addSubview:button];
            }
            // 数字按钮
            else {
                button                                          = [[UIButton alloc] initWithFrame:frame];
                [button setTitle:[numbers objectAtIndex:index] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                ((UIButton*)button).titleLabel.font             = [UIFont boldSystemFontOfSize:numFontSize];
                ((UIButton*)button).layer.borderWidth           = 0.3;
                ((UIButton*)button).layer.borderColor           = [UIColor colorWithWhite:0.8 alpha:0.5].CGColor;
                [(UIButton*)button  addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
                [(UIButton*)button  addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
                [(UIButton*)button  addTarget:self action:@selector(touchUpOut:) forControlEvents:UIControlEventTouchUpOutside];
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
    [alipayButton addTarget:self action:@selector(clickToWeAlipay:) forControlEvents:UIControlEventTouchUpInside];
    [alipayButton addTarget:self action:@selector(touchDownSimple:) forControlEvents:UIControlEventTouchDown];
    [alipayButton addTarget:self action:@selector(touchOutSimple:) forControlEvents:UIControlEventTouchUpOutside];

    [alipayButton setImageViewWithName:@"zfb"];
    [alipayButton setLabelNameWithName:@"支付宝支付"];
    [self.view addSubview:alipayButton];
    
    // 微信按钮
    frame.origin.x                      += self.view.bounds.size.width/2.0;
    OtherPayButton *weChatButton        = [[OtherPayButton alloc] initWithFrame:frame];
    // 添加 action ..........................
    [weChatButton setImageViewWithName:@"wx"];
    [weChatButton setLabelNameWithName:@"微信支付"];
    [weChatButton addTarget:self action:@selector(clickToWeChat:) forControlEvents:UIControlEventTouchUpInside];
    [weChatButton addTarget:self action:@selector(touchDownSimple:) forControlEvents:UIControlEventTouchDown];
    [weChatButton addTarget:self action:@selector(touchOutSimple:) forControlEvents:UIControlEventTouchUpOutside];

    [self.view addSubview:weChatButton];
    
    // 刷卡按钮       3/8/3.3 * 1.3
    CGFloat newBornerWith               = 2.0;
    frame.origin.x                      = 0 + newBornerWith;
    frame.origin.y                      += frame.size.height + bornerWith + newBornerWith;
    frame.size.width                    = self.view.bounds.size.width - newBornerWith*2;
    frame.size.height                   = littleHeight * 1.3 - newBornerWith*2;
    UIButton *brushButton               = [[UIButton alloc] initWithFrame:frame];
    brushButton.layer.cornerRadius      = 8.0;
    brushButton.backgroundColor         = [UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:75.0/255.0 alpha:1.0];
    [brushButton setTitle:@"开始刷卡" forState:UIControlStateNormal];
    [brushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    brushButton.titleLabel.font         = [UIFont boldSystemFontOfSize:32];
    // 添加 action
    [brushButton addTarget:self action:@selector(beginBrush:) forControlEvents:UIControlEventTouchDown];
    [brushButton addTarget:self action:@selector(toBrushClick:) forControlEvents:UIControlEventTouchUpInside];
    [brushButton addTarget:self action:@selector(outBrush:) forControlEvents:UIControlEventTouchUpOutside];

    [brushButton setSelected:YES];
    [self.view addSubview:brushButton];

    
}


- (IBAction) outBrush:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
}
- (IBAction) beginBrush:(UIButton*)sender {
    sender.transform                    = CGAffineTransformMakeScale(0.98, 0.98);
}

- (IBAction) touchDown:(UIButton*)sender {
    sender.transform                    = CGAffineTransformMakeScale(0.99, 0.99);
    sender.backgroundColor              = [UIColor colorWithWhite:0.7 alpha:0.5];
}

#pragma mask  ---- 数字按钮组的点击事件
- (IBAction) touchUp:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    sender.backgroundColor              = [UIColor clearColor];
    // 要计算属性值：金额：money
    [self plusNumberIntoMoney: sender];
    // 更新金额
    self.money                          = [[self.moneyStr money] copy];
    // 新的金额追加到栈中
    if (![self.money isEqualToString:[self.moneyArray lastObject]]) {
        [self.moneyArray addObject:self.money];
    }
}


#pragma mask  ---- 撤销按钮的点击事件
- (IBAction) touchUpDelete:(DeleteButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    sender.backgroundColor              = [UIColor clearColor];
    // 将栈顶金额弹出丢弃，并取新的栈顶金额
    self.money                          = [self pullMoneyStack];
    
    // 更新金额到计算金额中
    [self.moneyStr setNewMoneyString:self.money];
}


- (IBAction) touchUpOut:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    sender.backgroundColor              = [UIColor clearColor];
}

- (IBAction) touchDownSimple:(UIButton*)sender {
    sender.transform                    = CGAffineTransformMakeScale(0.97, 0.97);
}
- (IBAction) touchUpSimple:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
}
- (IBAction) touchOutSimple:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
}


#pragma mark   -----微信支付的跳转
- (IBAction) clickToWeChat:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    UIStoryboard* storyboard            = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewController    = [storyboard instantiateViewControllerWithIdentifier:@"weChatPay"];
    [self.navigationController pushViewController:viewController animated:YES];
    
}


#pragma mark   -----支付宝支付跳转
- (IBAction) clickToWeAlipay:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    UIStoryboard* storyboard            = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewController    = [storyboard instantiateViewControllerWithIdentifier:@"alipayPay"];
    [self.navigationController pushViewController:viewController animated:YES];
}



#pragma mark   -----保存金额数据
/*************************************
 * 功  能 : 将确认的金额保存到本地配置文件;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
-(void)saveConsumerMoney {
    // 保存的是字符串型的金额
    [[NSUserDefaults standardUserDefaults] setValue:self.money forKey:Consumer_Money];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark  ------跳转刷卡界面
/*************************************
 * 功  能 : 刷卡按钮的点击事件:跳转到刷卡界面;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (IBAction)toBrushClick:(UIButton *)sender {
    sender.transform                    = CGAffineTransformIdentity;

    UIStoryboard *storyboard            = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *viewcon           = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
    
    AppDelegate* delegate               = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![delegate.device isConnected])
    {
        UIAlertView * alter             = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请连接设备!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alter.delegate                  = self;
        [alter show];
    }else
    {
        [self saveConsumerMoney];
        [self.navigationController pushViewController:viewcon animated:YES];
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.message isEqualToString:@"请连接设备!"]) {
        NSLog(@"点击了   alertView");
        AppDelegate* delegate           = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate.device  open];
    }
}



/*************************************
 * 功  能 : 将金额栈的最上面的金额弹出;
 *************************************/
- (NSString*) pullMoneyStack {
    NSString* money;
    if (self.moneyArray.count > 1) {
        [self.moneyArray removeLastObject];
    } else {
        [self.moneyArray removeLastObject];
        [self.moneyArray addObject:@"0.00"];
    }
    money                               = [[self.moneyArray lastObject] copy];
    return  money;
}


/*************************************
 * 功  能 : 撤销按钮的长按事件;清除所有金额；
 * 参  数 :
 * 返  回 :
 *************************************/
- (IBAction)longPressButtonOfDelete:(UILongPressGestureRecognizer*)sender {
    [self.moneyArray removeAllObjects];
    self.money                          = @"0.00";
    [self.moneyStr setNewMoneyString:self.money];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        sender.view.transform           = CGAffineTransformIdentity;
        sender.view.backgroundColor     = [UIColor clearColor];
    }
}


/*************************************
 * 功  能 : 将按钮的对应的数字或小数点计算到money属性中;
 * 参  数 :
 *          (UIButton*)sender         被点击的按钮
 * 返  回 : 无
 *************************************/
- (void) plusNumberIntoMoney: (UIButton*)button {
    // 小数点
    if ([button.titleLabel.text isEqualToString:@"."]) {
        [self.moneyStr setDot];
    }
    // 纯数字
    else {
        [self.moneyStr addNumber:button.titleLabel.text];
    }
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
