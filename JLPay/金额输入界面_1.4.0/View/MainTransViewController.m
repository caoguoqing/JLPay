//
//  MainTransViewController.m
//  CustomViewMaker
//
//  Created by jielian on 16/9/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MainTransViewController.h"
#import "MTVC_screenView.h"
#import "MTVC_keybordView.h"
#import "TriScrollSegmentView.h"
#import "Masonry.h"
#import <RESideMenu.h>
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "VMMainVCDataSource.h"
#import "MViewSwitchManager.h"
#import "MTransMoneyCache.h"
#import "VMTransChecking.h"
#import "MTVC_modelTransTypeKeys.h"
#import "MTVC_vmLoginAtBack.h"


@interface MainTransViewController ()

@property (nonatomic, strong) MTVC_screenView*  screenView;

@property (nonatomic, strong) MTVC_keybordView* keybordView;

@property (nonatomic, strong) TriScrollSegmentView* triSwitchView;

@property (nonatomic, strong) UILabel* transTypeNoteLabel;

@property (nonatomic, strong) UIBarButtonItem* userBarBtn;

@property (nonatomic, strong) UIBarButtonItem* billListBarBtn;

/* 背景图层 */
@property (nonatomic, strong) CAGradientLayer* backGradientLayer;

/* 自动登录专用 */
@property (nonatomic, strong) MTVC_vmLoginAtBack* vmAutoLogin;

@end




@implementation MainTransViewController

# pragma mask 1 IBAction

/* 点击了菜单按钮 */
- (IBAction) clickedUserBarBtn:(UIBarButtonItem*)sender {
    UIViewController* parentVC = [self parentViewController];
    if ([parentVC isKindOfClass:[RESideMenu class]]) {
        RESideMenu* sideMenu = (RESideMenu*)parentVC;
        [sideMenu presentLeftMenuViewController];
    }
    else if ([[parentVC parentViewController] isKindOfClass:[RESideMenu class]]) {
        RESideMenu* sideMenu = (RESideMenu*)[parentVC parentViewController];
        [sideMenu presentLeftMenuViewController];
    }
}

/* 点击了清单按钮 */
- (IBAction) clickedListBarBtn:(UIBarButtonItem*)sender {
    if (![[VMMainVCDataSource dataSource] logined]) {
        // 去登录
        [[MViewSwitchManager manager] gotoLogin];
    } else {
        // 跳转交易明细界面
        [[MViewSwitchManager manager] gotoBillList];
    }
}

/* 点击了设备绑定按钮 */
- (IBAction) clickedDeviceBindedBtn:(id)sender {
    [[MViewSwitchManager manager] gotoDeviceBinding];
}

/* 点击了结算方式切换按钮 */
- (IBAction) clickedSettleSwitchBtn:(id)sender {
    NameWeakSelf(wself);
    [[VMMainVCDataSource dataSource] doswitchSettlementTypeWithVC:self onFinished:^{
        [wself reloadDatas];
    }];
}


# pragma mask 3 界面布局

- (void) addKVOs {
    @weakify(self);
    RAC(self.screenView.moneyLabel, text) = [RACObserve([MTransMoneyCache sharedMoney], curMoneyUniteYuan) map:^id(id value) {
        return [NSString stringWithFormat:@"￥%.02lf", [value floatValue]];
    }];
    
    [RACObserve([VMMainVCDataSource dataSource], settleType) subscribeNext:^(id x) {
        @strongify(self);
        [self.screenView.settlementSwitchBtn setTitle:x forState:UIControlStateNormal];
    }];
    
    RAC(self.screenView.settlementSwitchBtn, enabled) = RACObserve([VMMainVCDataSource dataSource], canSwitchSettlementType);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"商户收款";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [PublicInformation newBarItemWithNullTitle];
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDatas];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 所有界面退出都会回来本主界面
    if ((![[VMMainVCDataSource dataSource] logined]) && self.vmAutoLogin.canAutoLogin ) {
        [self.vmAutoLogin doLoginAtBackOnLoginSuccess:^{
            [[MViewSwitchManager manager] refrashMainViewControllerDatas];
        } onLoginError:^(NSError *error) {
            
        }];
    }
}

- (void) loadSubviews {
    [self.view.layer addSublayer:self.backGradientLayer];
    [self.view addSubview:self.screenView];
    [self.view addSubview:self.keybordView];
    [self.view addSubview:self.triSwitchView];
    [self.view addSubview:self.transTypeNoteLabel];
    [self.navigationItem setLeftBarButtonItem:self.userBarBtn];
    [self.navigationItem setRightBarButtonItem:self.billListBarBtn];
}

/* 重新加载界面数据 */
- (void) reloadDatas {
    VMMainVCDataSource* datasource = [VMMainVCDataSource dataSource];
    [datasource refrashData];
    self.screenView.deviceConnectBtn.hidden = !datasource.needBindDevice;
    
    
    CGFloat textFontSize = [NSString resizeFontAtHeight:self.screenView.businessLabel.bounds.size.height scale:0.7];
    self.screenView.businessLabel.attributedText = [NSAttributedString stringWithAwesomeText:[NSString stringWithIconType:IFTypeShop]
                                                                                 awesomeFont:[UIFont iconFontWithSize:textFontSize]
                                                                                awesomeColor:[UIColor colorWithHex:0x99cccc alpha:1]
                                                                                        text:datasource.businessName
                                                                                    textFont:[UIFont boldSystemFontOfSize:textFontSize]
                                                                                   textColor:[UIColor whiteColor]
                                                                             awesomeLocation:FAwesomeLocation_left];
    
    textFontSize = [NSString resizeFontAtHeight:self.screenView.settlementSwitchBtn.bounds.size.height scale:0.6];
    self.screenView.deviceBtnAttriTitle = [NSAttributedString stringWithLeftAwesomeText:[NSString fontAwesomeIconStringForEnum:FAChainBroken]
                                                                    leftAwesomeFont:[UIFont fontAwesomeFontOfSize:textFontSize - 1]
                                                                   leftAwesomeColor:[UIColor colorWithHex:0xffcc00 alpha:1]
                                                                   rightAwesomeText:[NSString stringWithIconType:IFTypeRightTri]
                                                                   rightAwesomeFont:[UIFont iconFontWithSize:textFontSize - 1]
                                                                  rightAwesomeColor:[UIColor colorWithHex:0xffcc00 alpha:1]
                                                                               text:@"去绑定设备"
                                                                           textFont:[UIFont boldSystemFontOfSize:textFontSize]
                                                                          textColor:[UIColor colorWithHex:0xffcc00 alpha:1]];


}

- (void) layoutSubviews {
    CGFloat triSwitchVHeight = self.view.frame.size.height * 1/6.5;
    CGFloat inset = [UIScreen mainScreen].bounds.size.width * 15/320.f;
    CGFloat noteLabelHeight = [UIScreen mainScreen].bounds.size.height * 20/568.f;
    self.screenView.layer.cornerRadius = inset;
    
    CGFloat keyBordVHeight = (self.view.frame.size.height - triSwitchVHeight - 64) * 0.5;
    
    __weak typeof(self) wself = self;
    
    [self.triSwitchView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(triSwitchVHeight);
    }];
    self.triSwitchView.itemSize = CGSizeMake(self.view.frame.size.width * 0.5, triSwitchVHeight * 0.6);
    
    [self.transTypeNoteLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(noteLabelHeight);
    }];
    self.transTypeNoteLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:noteLabelHeight scale:0.5]];
    
    [self.keybordView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(wself.triSwitchView.mas_top);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(keyBordVHeight);
    }];
    
    [self.screenView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wself.view.mas_top).offset(64 + inset);
        make.bottom.mas_equalTo(wself.keybordView.mas_top).offset(- inset);
        make.left.mas_equalTo(wself.view.mas_left).offset(inset);
        make.right.mas_equalTo(wself.view.mas_right).offset(- inset);
    }];
}



# pragma mask 4 getter 

- (MTVC_screenView *)screenView {
    if (!_screenView) {
        _screenView = [[MTVC_screenView alloc] init];
        _screenView.moneyLabel.textColor = [UIColor whiteColor];
        _screenView.backgroundColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        [_screenView.settlementSwitchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_screenView.settlementSwitchBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        _screenView.settlementSwitchBtn.switchLabel.text = [NSString stringWithIconType:IFTypeExchange];
        _screenView.settlementSwitchBtn.switchLabel.textColor = [UIColor colorWithHex:0x99cccc alpha:1];
        _screenView.businessLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        
        [_screenView.deviceConnectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_screenView.deviceConnectBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        [_screenView.deviceConnectBtn addTarget:self action:@selector(clickedDeviceBindedBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_screenView.settlementSwitchBtn addTarget:self action:@selector(clickedSettleSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _screenView;
}

- (MTVC_keybordView *)keybordView {
    if (!_keybordView) {
        _keybordView = [[MTVC_keybordView alloc] initWithClickedBlock:^(NSInteger number) {
            MTransMoneyCache* moneyCache = [MTransMoneyCache sharedMoney];
            switch (number) {
                case MTVC_keybordNumClear:
                {
                    [moneyCache resetMoneyToZero];
                }
                    break;
                case MTVC_keybordNumDel:
                {
                    [moneyCache removeLastBitNumber];
                }
                    break;
                case MTVC_keybordNum0:
                {
                    [moneyCache appendLastBitNumber:0];
                }
                    break;
                default:
                {
                    [moneyCache appendLastBitNumber:number];
                }
                    break;
            }
        }];
        _keybordView.backgroundColor = [UIColor clearColor];
        _keybordView.numBtnBackColor = [UIColor colorWithHex:0x27384b alpha:1];
        _keybordView.numBtnTextColor = [UIColor whiteColor];
        _keybordView.inset = 8;
    }
    return _keybordView;
}

- (TriScrollSegmentView *)triSwitchView {
    if (!_triSwitchView) {
        _triSwitchView = [[TriScrollSegmentView alloc] initWithSegInfos:[MTVC_modelTransTypeKeys model].transTypeList
                                                     andMidItemCliecked:^{
                                                         if (![[VMMainVCDataSource dataSource] logined]) {
                                                             [[MViewSwitchManager manager] gotoLogin];
                                                         } else {
                                                             NSDictionary* midNode = [[MTVC_modelTransTypeKeys model].transTypeList objectAtIndex:_triSwitchView.curSegIndex];
                                                             NSString* midTitle = [midNode objectForKey:kTransTypeTitleKey];
                                                             
                                                             if ([midTitle isEqualToString:(NSString*)kTransTypeNameJLPay]) {
                                                                 [VMTransChecking mposTransCheckingAndHandling];
                                                             }
                                                             else if ([midTitle isEqualToString:(NSString*)kTransTypeNameWechatPay]) {
                                                                 [PublicInformation makeCentreToast:@"敬请期待，即将开通!"];
                                                                 //[VMTransChecking wechatPayCheckingAndHandling];
                                                             }
                                                             else if ([midTitle isEqualToString:(NSString*)kTransTypeNameAlipay]) {
                                                                 [PublicInformation makeCentreToast:@"敬请期待，即将开通!"];
                                                             }
                                                         }
                                                         
        }];
        
        _triSwitchView.layer.masksToBounds = NO;
        _triSwitchView.backCircleColor = [UIColor colorWithHex:0x27384b alpha:1];
        _triSwitchView.backgroundColor = [UIColor clearColor];

    }
    return _triSwitchView;
}

- (UILabel *)transTypeNoteLabel {
    if (!_transTypeNoteLabel) {
        _transTypeNoteLabel = [UILabel new];
        _transTypeNoteLabel.text = @"滑动可切换交易方式";
        _transTypeNoteLabel.textColor = [UIColor colorWithWhite:1 alpha:0.9];
        _transTypeNoteLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _transTypeNoteLabel;
}

- (UIBarButtonItem *)userBarBtn {
    if (!_userBarBtn) {
        UIButton* userBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [userBtn setTitle:[NSString fontAwesomeIconStringForEnum:FACog] forState:UIControlStateNormal];
        userBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:25 scale:1]];
        [userBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [userBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        [userBtn addTarget:self action:@selector(clickedUserBarBtn:) forControlEvents:UIControlEventTouchUpInside];
        _userBarBtn = [[UIBarButtonItem alloc] initWithCustomView:userBtn];
    }
    return _userBarBtn;
}

- (UIBarButtonItem *)billListBarBtn {
    if (!_billListBarBtn) {
        UIButton* billListBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [billListBtn setTitle:[NSString fontAwesomeIconStringForEnum:FABarChartO] forState:UIControlStateNormal];
        billListBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:25 scale:0.8]];
        [billListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [billListBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        [billListBtn addTarget:self action:@selector(clickedListBarBtn:) forControlEvents:UIControlEventTouchUpInside];
        _billListBarBtn = [[UIBarButtonItem alloc] initWithCustomView:billListBtn];
    }
    return _billListBarBtn;
}

- (CAGradientLayer *)backGradientLayer {
    if (!_backGradientLayer) {
        _backGradientLayer = [CAGradientLayer layer];
        _backGradientLayer.frame = self.view.bounds;
        _backGradientLayer.colors = @[(__bridge id)[UIColor colorWithHex:0xeeeeee alpha:1].CGColor,
                                      (__bridge id)[UIColor colorWithHex:0x99cccc alpha:1].CGColor,
                                      (__bridge id)[UIColor colorWithHex:0xeeeeee alpha:1].CGColor];
        _backGradientLayer.locations = @[@0, @0.75, @1];
        _backGradientLayer.startPoint = CGPointMake(0.5, 0);
        _backGradientLayer.endPoint = CGPointMake(0.5, 1);
    }
    return _backGradientLayer;
}

- (MTVC_vmLoginAtBack *)vmAutoLogin {
    if (!_vmAutoLogin) {
        _vmAutoLogin = [[MTVC_vmLoginAtBack alloc] init];
    }
    return _vmAutoLogin;
}


@end
