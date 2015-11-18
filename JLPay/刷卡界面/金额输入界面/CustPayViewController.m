//
//  CustPayViewController.m
//  JLPay
//
//  Created by jielian on 15/5/15.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "CustPayViewController.h"
#import "Define_Header.h"
#import "MoneyCalculated.h"
#import "BrushViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeleteButton.h"


#define ImageForBrand   @"logo"                                             // 商标图片


@interface CustPayViewController ()<UIAlertViewDelegate, CBCentralManagerDelegate>
{
    BOOL blueToothPowerOn;  // 蓝牙打开状态标记
    CBCentralManager* blueManager; // 蓝牙设备操作入口
}
@property (nonatomic, strong) UILabel           *acountOfMoney;             // 金额显示标签栏
@property (nonatomic)         NSString*         money;                      // 金额
@property (nonatomic, strong) MoneyCalculated*  moneyCalculated;            // 更新的金额计算类
@end

@implementation CustPayViewController
@synthesize acountOfMoney               = _acountOfMoney;
@synthesize money                       = _money;
@synthesize moneyCalculated             = _moneyCalculated;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
    UIBarButtonItem* backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToLastViewController)];
    [self.navigationItem setBackBarButtonItem:backBarButton];
    
    blueToothPowerOn = NO;
    blueManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}
- (void) backToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    // 修改标题栏的字体颜色
    UIColor* color = [UIColor redColor];
    NSDictionary* textAttri = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = textAttri;
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 重新扫描设备
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

#pragma mask ---- CBCentrolManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        blueToothPowerOn = YES;
    } else {
        blueToothPowerOn = NO;
    }
}


#pragma mask ::: 数字按键组的分割线
- (void) drawLineInRect : (CGRect)rect {
    CGFloat lineWidth = 0.5;
    CGFloat horizontalWidth = rect.size.width;  // 水平
    CGRect frame = CGRectMake(rect.origin.x, rect.origin.y, horizontalWidth, lineWidth);
    // 横线
    for (int i = 0; i < 5; i++) {
        UIView* line = [[UIView alloc] initWithFrame:frame];
        line.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
        frame.origin.y += rect.size.height/4.0;
        if (i == 4) {
            frame.origin.y -= frame.size.height;
        }
        [self.view addSubview:line];
    }
    frame.origin.y = rect.origin.y;
    frame.size.width = lineWidth;
    frame.size.height = rect.size.height;
    // 竖线
    for (int j = 0; j < 4; j++) {
        UIView* line = [[UIView alloc] initWithFrame:frame];
        line.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
        frame.origin.x += rect.size.width/3.0;
        [self.view addSubview:line];
    }
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
    // 向金额对象压入输入的数字
    self.money = [self.moneyCalculated moneyByAddedNumber:sender.titleLabel.text];
}


#pragma mask  ---- 撤销按钮的点击事件
- (IBAction) touchUpDelete:(DeleteButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    sender.backgroundColor              = [UIColor clearColor];
    // 获取撤销后的上一次输入的金额
    self.money = [self.moneyCalculated moneyByRevoked];
}

/*************************************
 * 功  能 : 撤销按钮的长按事件;清除所有金额；
 * 参  数 :
 * 返  回 :
 *************************************/
- (IBAction)longPressButtonOfDelete:(UILongPressGestureRecognizer*)sender {
    while (YES) {
        self.money = [self.moneyCalculated moneyByRevoked];
        if ([self.money isEqualToString:@"0.00"]) {
            break;
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        sender.view.transform           = CGAffineTransformIdentity;
        sender.view.backgroundColor     = [UIColor clearColor];
    }
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



#pragma mark  ------点击了刷卡按钮: 跳转刷卡界面
/*************************************
 * 功  能 : 刷卡按钮的点击事件:跳转到刷卡界面;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (IBAction)toBrushClick:(UIButton *)sender {
    sender.transform = CGAffineTransformIdentity;
    if ([self.money floatValue] < 0.0001) {
        [self alertShow:@"请输入金额!"];
        return;
    }
    
    if (!blueToothPowerOn) {
        [self alertShow:@"手机蓝牙未打开,请打开蓝牙"];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BrushViewController *viewcon = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
    [viewcon setStringOfTranType:TranType_Consume];
    [viewcon setSFloatMoney:self.money];
    [viewcon setSIntMoney:[self sIntMoneyOfFloatMoney:self.money]];
    
    
    // 保存的是字符串型的金额 ----- 暂时无用了
    [[NSUserDefaults standardUserDefaults] setValue:self.money forKey:Consumer_Money];
    [[NSUserDefaults standardUserDefaults] setValue:TranType_Consume forKey:TranType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 跳转
    [self.navigationController pushViewController:viewcon animated:YES];
    
    // 重置金额
    self.money = @"0.00";
    self.moneyCalculated = nil;
}



#pragma mask ::: 自定义返回上层界面按钮的功能
- (IBAction) backToPreVC :(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*************************************
 * 功  能 : 重新计算数字按钮组的文本的高度跟button高度的比例;
 *          - 新的比例用 2/3 来计算
 * 参  数 :
 * 返  回 :
 *************************************/
- (CGFloat)resizeFontWithButton: (UIButton*)button inFrame: (CGRect) frame {
    CGFloat resize = 0.0;
    NSDictionary* textAttri = [NSDictionary dictionaryWithObject:button.titleLabel.font forKey:NSFontAttributeName];
    CGSize size = [button.titleLabel.text sizeWithAttributes:textAttri];
    // 重置:设置字体的高度占 label 的高度的 2/3
    resize = 2.0 * frame.size.height / (3.0 * size.height);
    return resize;
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
    // 数字按钮组的字体大小
    CGFloat numFontSize                 = 30.0;
    CGFloat statusBarHeight             = [[UIApplication sharedApplication] statusBarFrame].size.height;
    // 视图的有效高度
    CGFloat visibleHeight               = self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height - statusBarHeight;
    // 分割线宽度
    CGFloat  bornerWith                 = 1;
    
    
    // 重新排版的各子视图的宽、高
    CGFloat inset                       = 5.0;
    
    // 数字按钮宽度
    CGFloat numBtnWidth                 = self.view.bounds.size.width/3.0;
    // 金额显示框的高度:固定高度
    CGFloat displayMoneyHeight          = numBtnWidth * 3.0/4.0 * 3.0/4.0;
    
    CGSize  logoImgSize                  = [UIImage imageNamed:ImageForBrand].size;
    CGFloat logoImgWidth                = self.view.bounds.size.width / 2.0;
    CGFloat logoImgHeight               = logoImgWidth * logoImgSize.height/logoImgSize.width;
    // logo imageView高度
    CGFloat logoImgViewHeight           = (visibleHeight - displayMoneyHeight*4)/3.0;
    if (logoImgViewHeight < logoImgHeight + inset*2.0) {
        logoImgViewHeight = logoImgHeight + inset*2.0;
    }
    
    // 刷卡按钮的高度
    CGFloat swipeBtnHeight = displayMoneyHeight;
    // 数字按钮高度
    CGFloat numBtnHeight = displayMoneyHeight;
    
    if (numBtnWidth * 5 + inset * 2 + bornerWith > visibleHeight - logoImgViewHeight - displayMoneyHeight) {
        numBtnHeight = (visibleHeight - logoImgViewHeight - displayMoneyHeight - bornerWith - inset*2)/5.0;
        if (numBtnHeight < 60.0) {
            swipeBtnHeight = 60.0;
            numBtnHeight = (numBtnHeight * 5.0 - 60.0)/4.0;
        }
    }
    
    // 图标
    CGRect  frame                       = CGRectMake((self.view.bounds.size.width - logoImgWidth)/2,
                                                     0 + statusBarHeight + (logoImgViewHeight - logoImgHeight)/2.0,
                                                     logoImgWidth,
                                                     logoImgHeight);
    UIImageView *imageView              = [[UIImageView alloc] initWithFrame:frame];
    imageView.image                     = [UIImage imageNamed:ImageForBrand];
    [self.view addSubview:imageView];
    
    // 金额显示框
    frame.origin.x                      = 0 + bornerWith;
    frame.origin.y                      += frame.size.height+ (logoImgViewHeight - logoImgHeight)/2.0 + bornerWith;
    frame.size.width                    = self.view.bounds.size.width - bornerWith*2;
    frame.size.height                   = displayMoneyHeight;
    UIView  *moneyView                  = [[UIView alloc] initWithFrame:frame];
    moneyView.backgroundColor           = [UIColor colorWithRed:180.0/255.0 green:188.0/255.0 blue:194.0/255.0 alpha:1.0];
    [self.view addSubview:moneyView];
    // moneyLabel
    CGRect innerFrame                   = CGRectMake(0, 0, frame.size.width - 45, frame.size.height);
    self.acountOfMoney.frame            = innerFrame;
    self.acountOfMoney.text             = @"0.00";
    self.acountOfMoney.textAlignment    = NSTextAlignmentRight;
    CGSize fontSize = [self.acountOfMoney.text sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:37] forKey:NSFontAttributeName]];
    // 金额字体大小占 frame 高度的 2/3
    self.acountOfMoney.font             = [UIFont boldSystemFontOfSize: (innerFrame.size.height*2.0/3.0 / fontSize.height * 37)];
    
    
    
    [moneyView addSubview:self.acountOfMoney];
    // moneyImageView 金额符号Label : 字体大小为金额字体大小的 3/4, 因为字体为汉字，显示要比英文字母高一点，所以将y降低一个 inset，高度也减少一个 inset
    innerFrame.origin.x                 += innerFrame.size.width + inset;
    innerFrame.origin.y                 += inset;
    innerFrame.size.width               = frame.size.width - innerFrame.origin.x;
    innerFrame.size.height              -= inset;
    UILabel *moneySymbolLabel           = [[UILabel alloc] initWithFrame:innerFrame];
    moneySymbolLabel.text               = @"￥";
    moneySymbolLabel.textAlignment      = NSTextAlignmentLeft;
    moneySymbolLabel.font               = [UIFont boldSystemFontOfSize:(innerFrame.size.height*2.0/3.0 / fontSize.height * 37)/4.0*3.0];
    [moneyView addSubview:moneySymbolLabel];
    
    // 数字按键组     4/8
    NSArray * numbers                   = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@".",@"0",@"delete",nil];
    frame.origin.x                      = 0;
    frame.origin.y                      += frame.size.height + bornerWith*2.0;
    frame.size.width                    = numBtnWidth;
    frame.size.height                   = numBtnHeight;
    CGRect numbersFrame                 = CGRectMake(frame.origin.x, frame.origin.y, self.view.bounds.size.width, numBtnHeight*4.0);
    NSInteger index                     = 0;
    for (int i = 0; i<4; i++) {
        frame.origin.x                  = 0.0;
        for (int j = 0; j<3; j++) {
            // frame 都已经准备好，可以直接装填数字按钮组了
            id button;
            // “撤销”按钮
            if (i == 3 && j == 2) {
                button                                          = [[DeleteButton alloc] initWithFrame:frame];
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
                ((UIButton*)button).titleLabel.font             = [UIFont boldSystemFontOfSize:numFontSize * [self resizeFontWithButton:button inFrame:frame]];
                [(UIButton*)button  addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
                [(UIButton*)button  addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
                [(UIButton*)button  addTarget:self action:@selector(touchUpOut:) forControlEvents:UIControlEventTouchUpOutside];
                [self.view addSubview:button];
            }
            /////////////////////
            
            index++;
            frame.origin.x              += frame.size.width;
        }
        frame.origin.y                  += numBtnHeight;
    }
    // 分割线
    [self drawLineInRect:numbersFrame];
    
    
    
    // 刷卡按钮       3/8/3.3 * 1.3
    frame.origin.x                      = 0 + inset;
    frame.origin.y                      += (visibleHeight - frame.origin.y + statusBarHeight - swipeBtnHeight)/2.0;
    frame.size.width                    = self.view.bounds.size.width - inset*2;
    frame.size.height                   = swipeBtnHeight;
    UIButton *brushButton               = [[UIButton alloc] initWithFrame:frame];
    brushButton.layer.cornerRadius      = 8.0;
    brushButton.backgroundColor         = [UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:75.0/255.0 alpha:1.0];
    [brushButton setTitle:@"开始刷卡" forState:UIControlStateNormal];
    [brushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [brushButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [brushButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    brushButton.titleLabel.font         = [UIFont boldSystemFontOfSize:32];
    // 添加 action
    [brushButton addTarget:self action:@selector(beginBrush:) forControlEvents:UIControlEventTouchDown];
    [brushButton addTarget:self action:@selector(toBrushClick:) forControlEvents:UIControlEventTouchUpInside];
    [brushButton addTarget:self action:@selector(outBrush:) forControlEvents:UIControlEventTouchUpOutside];
    
    [brushButton setSelected:YES];
    [self.view addSubview:brushButton];
}


// 简化代码:简单的弹窗提示
- (void) alertShow: (NSString*) msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 小数点型金额转换为整型金额
- (NSString*) sIntMoneyOfFloatMoney:(NSString*)floatMoney {
    NSString* sIntMoney = nil;
    NSString* sInt = [floatMoney substringToIndex:[floatMoney rangeOfString:@"."].location];
    NSString* sFloat = [floatMoney substringFromIndex:[floatMoney rangeOfString:@"."].location + 1];
    sIntMoney = [NSString stringWithFormat:@"%012d",sInt.intValue * 100 + sFloat.intValue];
    return sIntMoney;
}



#pragma mask --- setter & getter
- (MoneyCalculated *)moneyCalculated {
    if (_moneyCalculated == nil) {
        _moneyCalculated = [[MoneyCalculated alloc] initWithLimit:6];   // 金额限制在6位
    }
    return _moneyCalculated;
}
/* 金额值的 setter 方法 */
- (void)setMoney:(NSString*)money {
    if (![_money isEqualToString: money]) {
        _money                          = money;
        _acountOfMoney.text             = _money;
    }
}
- (UILabel *)acountOfMoney {
    if (_acountOfMoney == nil) {
        _acountOfMoney = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _acountOfMoney;
}

@end
