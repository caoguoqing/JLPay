//
//  MoreBusinessOrRateVC.m
//  JLPay
//
//  Created by jielian on 16/8/24.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MoreBusinessOrRateVC.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import "NaviTitleViewPullDownChoose.h"
#import "LaydownNaviTableViewChoose.h"
#import "ChooseBusinessOrRateVC.h"
#import "ModelBusinessInfoSaved.h"
#import "ModelRateInfoSaved.h"

#import "VMDataSourceForMoreBusiOrRateVC.h"


@interface MoreBusinessOrRateVC() <UIGestureRecognizerDelegate>

/* 标题按钮: 切换多商户、多费率 */
@property (nonatomic, strong) NaviTitleViewPullDownChoose* busiOrRateChooseTitleBtn;

/* 下拉表视图: 提供多商户、多费率选项 */
@property (nonatomic, strong) LaydownNaviTableViewChoose* titleTypesChooseView;

/* 提示: 已保存\未保存信息 */
@property (nonatomic, strong) UILabel* noteLabSavedOrNot;

/* 字体库图标: 保存\未保存 */
@property (nonatomic, strong) UILabel* iconSaved;
@property (nonatomic, strong) UILabel* iconNotSaved;

/* 标签: 商户 (if enable more business) */
@property (nonatomic, strong) UILabel* labBusiness;

/* 标签: 费率 */
@property (nonatomic, strong) UILabel* labRate;

/* 标签: 地区 */
@property (nonatomic, strong) UILabel* labProvinceAndCity;


/* 按钮: 重新设置 */
@property (nonatomic, strong) UIButton* btnReset;
/* 按钮: 清除历史保存 */
@property (nonatomic, strong) UIButton* btnClear;
/* 提示: 商户\费率 de 有效条件 */
@property (nonatomic, strong) UILabel* noteLabEffective;


/* --- data source --- */
@property (nonatomic, strong) VMDataSourceForMoreBusiOrRateVC* dataSourceForB_R;


@property (nonatomic, copy) void (^ finishedBlock) (void);
@property (nonatomic, copy) void (^ canceledBlock) (void);

@end




@implementation MoreBusinessOrRateVC


- (void) addKVOs {
    @weakify(self);
    /* 多选时才能点击 */
    RAC(self.busiOrRateChooseTitleBtn, enabled) = RACObserve(self.dataSourceForB_R, moreBusinessesAndRates);
    
    /* 切换了类型: 收起下拉显示表、切换按钮方向 */
    [[RACObserve(self.dataSourceForB_R, typeSelected) delay:0] subscribeNext:^(NSString* typeSelected) {
        @strongify(self);
        [self.busiOrRateChooseTitleBtn setTitle:typeSelected forState:UIControlStateNormal];
        self.busiOrRateChooseTitleBtn.downPulled = YES;
        [self.titleTypesChooseView hide];
        
        [self.view setNeedsUpdateConstraints];
        [self.view updateConstraintsIfNeeded];
        [UIView animateWithDuration:0.2 animations:^{
            @strongify(self);
            [self.view layoutIfNeeded];
        }];
    }];
    
    /* icon */
    RAC(self.iconSaved, hidden) = [RACObserve(self.dataSourceForB_R, hasSavedBusiOrRate) map:^id(id value) {
        return @(![value boolValue]);
    }];
    
    RAC(self.iconNotSaved, hidden) = RACObserve(self.dataSourceForB_R, hasSavedBusiOrRate);
    
    /* note */
    RAC(self.noteLabSavedOrNot, text) = [RACObserve(self.dataSourceForB_R, hasSavedBusiOrRate) map:^NSString* (NSNumber* saved) {
        @strongify(self);
        NSString* type = [self.dataSourceForB_R.typeSelected substringToIndex:2];
        if (saved.boolValue) {
            return [NSString stringWithFormat:@"已保存%@信息:", type];
        } else {
            return [NSString stringWithFormat:@"未选择%@,如需指定%@,请重新设置!", type, type];
        }
    }];
    
    /* effective text: 
        -- updated by 2017/01/06 : 多商户设置在T+0和T+1都有效,所以去掉提示
     */
//    RAC(self.noteLabEffective, text) = [RACObserve(self.dataSourceForB_R, typeSelected) map:^NSString* (NSString* typeSelected) {
//        return [NSString stringWithFormat:@"温馨提示: 仅结算类型为T+1时,设置的%@有效!", [typeSelected substringToIndex:2]];
//    }];
    
    RAC(self.btnClear, hidden) = [RACObserve(self.dataSourceForB_R, hasSavedBusiOrRate) map:^id(id value) {
        return @(![value boolValue]);
    }];
    
    RAC(self.labBusiness, text) = RACObserve(self.dataSourceForB_R, businessNameSaved);
    RAC(self.labRate, text) = RACObserve(self.dataSourceForB_R, rateNameSaved);
    RAC(self.labProvinceAndCity,text) = [RACSignal combineLatest:@[RACObserve(self.dataSourceForB_R, provinceNameSaved), RACObserve(self.dataSourceForB_R, cityNameSaved)]
                                                          reduce:^id(NSString* province, NSString* city){
                                                              if (province && province.length > 0 && city && city.length > 0) {
                                                                  return [NSString stringWithFormat:@"%@/%@", province, city];
                                                              } else {
                                                                  return nil;
                                                              }
    }];
    
    RAC(self.labBusiness, hidden) = [RACObserve(self.dataSourceForB_R, hasSavedBusiOrRate) map:^id(id value) {
        @strongify(self);
        if ([self.dataSourceForB_R.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
            return @(![value boolValue]);
        } else {
            return @(YES);
        }
    }];
    RAC(self.labRate, hidden) = [RACObserve(self.dataSourceForB_R, hasSavedBusiOrRate) map:^id(id value) {
        return @(![value boolValue]);
    }];
    RAC(self.labProvinceAndCity, hidden) = [RACObserve(self.dataSourceForB_R, hasSavedBusiOrRate) map:^id(id value) {
        return @(![value boolValue]);
    }];
    
    
    RAC(self.labRate, font) = [RACObserve(self.dataSourceForB_R, typeSelected) map:^id(NSString* typeSelected) {
        if ([typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
            return [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:34 scale:0.6]];
        } else {
            return [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:34 scale:0.8]];
        }
    }];
    
    
}

# pragma mask 2 IBAction

- (IBAction) clieckedTitleView:(NaviTitleViewPullDownChoose*)titleView {
    if (titleView.downPulled) {
        [self.titleTypesChooseView show];
    } else {
        [self.titleTypesChooseView hide];
    }
    titleView.downPulled = !titleView.downPulled;
}
- (IBAction) tapGes:(UITapGestureRecognizer*)ges {
    self.busiOrRateChooseTitleBtn.downPulled = YES;
    [self.titleTypesChooseView hide];
}

- (IBAction) clickedResetBtn:(UIButton*)sender {
    ChooseBusinessOrRateVC* chooseBusiOrRateVC = [[ChooseBusinessOrRateVC alloc] initWithNibName:nil bundle:nil];
    chooseBusiOrRateVC.vmBRsaver.lastBusiOrRateInfo.typeSelected = self.dataSourceForB_R.dataSource.typeSelected;
    
    NameWeakSelf(wself);
    chooseBusiOrRateVC.doneWithSaved = ^ {
        wself.dataSourceForB_R.dataSource.typeSelected = wself.dataSourceForB_R.dataSource.typeSelected;
    };
    
    [self.navigationController pushViewController:chooseBusiOrRateVC animated:YES];
}

- (IBAction) clickedClearBtn:(UIButton*)sender {
    NSString* title;
    NSString* message;
    if ([self.dataSourceForB_R.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
        title = @"确定要清除保存的商户信息?";
        message = [NSString stringWithFormat:@"[%@]\n[%@]\n[%@/%@]", self.dataSourceForB_R.businessNameSaved, self.dataSourceForB_R.rateNameSaved, self.dataSourceForB_R.provinceNameSaved, self.dataSourceForB_R.cityNameSaved];
    } else {
        title = @"确定要清除保存的费率信息?";
        message = [NSString stringWithFormat:@"[%@]\n[%@/%@]", self.dataSourceForB_R.rateNameSaved, self.dataSourceForB_R.provinceNameSaved, self.dataSourceForB_R.cityNameSaved];
    }
    
    [UIAlertController showAlertWithTitle:title message:message target:self clickedHandle:^(UIAlertAction *action) {
        if ([action.title isEqualToString:@"清除"]) {
            if ([self.dataSourceForB_R.typeSelected isEqualToString:MB_R_Type_moreRates]) {
                [ModelRateInfoSaved clearSaved];
                self.dataSourceForB_R.dataSource.typeSelected = MB_R_Type_moreRates; //refresh
            }
            else if ([self.dataSourceForB_R.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
                [ModelBusinessInfoSaved clearSaved];
                self.dataSourceForB_R.dataSource.typeSelected = MB_R_Type_moreBusinesses;
            }
        }
    } buttons:@{@(UIAlertActionStyleCancel):@"取消"},@{@(UIAlertViewStyleDefault):@"清除"}, nil];
}


/* 退出界面 */
- (IBAction) clickedCancelBtn:(id)sender {
    NameWeakSelf(wself);
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (wself.canceledBlock) {
            wself.canceledBlock();
        }
    }];
}

# pragma mask 3 UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view class] != [UITableView class]) {
        return NO;
    } else {
        return YES;
    }
}


# pragma mask 4 生命周期 & 布局

- (instancetype)initWithSelectFinished:(void (^)(void))finishedBlock orCanceled:(void (^)(void))canceledBlock {
    self = [super init];
    if (self) {
        self.finishedBlock = finishedBlock;
        self.canceledBlock = canceledBlock;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xeeeeee alpha:1];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    [self.navigationItem setTitleView:self.busiOrRateChooseTitleBtn];
    [self addKVOs];
    [self loadSubviews];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    self.tabBarController.tabBar.hidden = YES;
    
}

- (void) loadSubviews {
    [self.navigationItem setLeftBarButtonItem:[self newCancelBarBtn]];
    [self.view addSubview:self.noteLabSavedOrNot];
    [self.view addSubview:self.iconSaved];
    [self.view addSubview:self.iconNotSaved];
    [self.view addSubview:self.labBusiness];
    [self.view addSubview:self.labRate];
    [self.view addSubview:self.labProvinceAndCity];
    [self.view addSubview:self.btnReset];
    [self.view addSubview:self.btnClear];
    [self.view addSubview:self.noteLabEffective];
    
    [self.view addSubview:self.titleTypesChooseView];
    
    
    CGFloat heightBtn = 44;
    CGFloat heightLabel = 34;
    
    self.noteLabSavedOrNot.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:heightLabel scale:0.5]];
    self.noteLabEffective.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:heightLabel scale:0.38]];
    self.labBusiness.font = [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:heightLabel scale:0.8]];
    self.labProvinceAndCity.font = [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:heightLabel scale:0.6]];
    self.btnReset.layer.cornerRadius = heightBtn * 0.5;
    self.btnReset.titleLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:heightBtn scale:0.45]];
    self.btnClear.titleLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:heightBtn scale:0.4]];
    self.iconSaved.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:heightLabel scale:0.5]];
    self.iconNotSaved.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:self.view.frame.size.width * 0.4 scale:1]];
}



- (void)updateViewConstraints {
    
    CGFloat insetTop = 20;
    CGFloat heightBtn = 44;
    CGFloat heightLabel = 34;
    
    NameWeakSelf(wself);
    [self.btnReset mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wself.view.mas_centerY);
        make.height.mas_equalTo(heightBtn);
        make.centerX.mas_equalTo(wself.view.mas_centerX);
        make.width.mas_equalTo(wself.view.mas_width).multipliedBy(0.78);
    }];
    
    [self.btnClear mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wself.btnReset.mas_bottom).offset(4);
        make.height.mas_equalTo(wself.btnReset.mas_height);
        make.left.right.mas_equalTo(wself.btnReset);
    }];
    
    [self.noteLabEffective mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(wself.view.mas_bottom).offset(- heightBtn);
        make.height.mas_equalTo(heightLabel);
        make.left.right.mas_equalTo(wself.view);
    }];
    
    CGSize labelSize = [self.noteLabSavedOrNot.text resizeAtHeight:heightLabel scale:0.8];
    [self.noteLabSavedOrNot mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(wself.view.mas_centerX);
        make.width.mas_equalTo(labelSize.width);
        make.top.mas_equalTo(64 + insetTop);
        make.height.mas_equalTo(heightLabel);
    }];
    
    [self.iconSaved mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.noteLabSavedOrNot.mas_left).offset(/*- heightLabel * 0.5 - 5*/0);
        make.centerY.mas_equalTo(wself.noteLabSavedOrNot.mas_centerY);
        make.width.height.mas_equalTo(heightLabel);
    }];
    
    [self.iconNotSaved mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(wself.view.mas_centerX).priorityLow();
        make.centerY.mas_equalTo(wself.view.mas_centerY).multipliedBy(0.5).offset((64 + 20) * 0.5);
        make.height.mas_equalTo([UIScreen mainScreen].bounds.size.width * 0.4);
        make.width.mas_equalTo(wself.iconNotSaved.mas_height);
    }];
    
    [self.labRate mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(wself.view.mas_centerY).multipliedBy(0.5).offset((64 + 20) * 0.5);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(heightLabel);
    }];
    
    [self.labBusiness mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(wself.labRate.mas_top).offset(-5);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(heightLabel);
    }];
    
    [self.labProvinceAndCity mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wself.labRate.mas_bottom).offset(5);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(heightLabel);
    }];

    [super updateViewConstraints];
}


# pragma mask 4 getter

- (NaviTitleViewPullDownChoose *)busiOrRateChooseTitleBtn {
    if (!_busiOrRateChooseTitleBtn) {
        _busiOrRateChooseTitleBtn = [[NaviTitleViewPullDownChoose alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        _busiOrRateChooseTitleBtn.downLabel.textColor = [UIColor whiteColor];
        _busiOrRateChooseTitleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_busiOrRateChooseTitleBtn setTitle:@"多商户设置" forState:UIControlStateNormal];
        [_busiOrRateChooseTitleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_busiOrRateChooseTitleBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.7] forState:UIControlStateHighlighted];
        [_busiOrRateChooseTitleBtn addTarget:self action:@selector(clieckedTitleView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _busiOrRateChooseTitleBtn;
}

- (LaydownNaviTableViewChoose *)titleTypesChooseView {
    if (!_titleTypesChooseView) {
        _titleTypesChooseView = [[LaydownNaviTableViewChoose alloc] initWithSuperView:self.view];
        _titleTypesChooseView.dataTableView.delegate = self.dataSourceForB_R;
        _titleTypesChooseView.dataTableView.dataSource = self.dataSourceForB_R;
        _titleTypesChooseView.dataTableView.separatorInset = UIEdgeInsetsZero;
        _titleTypesChooseView.dataTableView.layoutMargins = UIEdgeInsetsZero;
        
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        tapGes.delegate = self;
        [_titleTypesChooseView addGestureRecognizer:tapGes];
    }
    return _titleTypesChooseView;
}

- (VMDataSourceForMoreBusiOrRateVC *)dataSourceForB_R {
    if (!_dataSourceForB_R) {
        _dataSourceForB_R = [[VMDataSourceForMoreBusiOrRateVC alloc] init];
    }
    return _dataSourceForB_R;
}

- (UILabel *)noteLabSavedOrNot {
    if (!_noteLabSavedOrNot) {
        _noteLabSavedOrNot = [UILabel new];
        _noteLabSavedOrNot.textAlignment = NSTextAlignmentCenter;
        _noteLabSavedOrNot.textColor = [UIColor grayColor];
    }
    return _noteLabSavedOrNot;
}

- (UILabel *)iconSaved {
    if (!_iconSaved) {
        _iconSaved = [UILabel new];
        _iconSaved.textAlignment = NSTextAlignmentCenter;
        _iconSaved.textColor = [UIColor colorWithHex:HexColorTypeGreen alpha:1];
        _iconSaved.text = [NSString fontAwesomeIconStringForEnum:FAFloppyO];
    }
    return _iconSaved;
}
- (UILabel *)iconNotSaved {
    if (!_iconNotSaved) {
        _iconNotSaved = [UILabel new];
        _iconNotSaved.textAlignment = NSTextAlignmentCenter;
        _iconNotSaved.textColor = [UIColor colorWithHex:0xa9b7b7 alpha:1];
        _iconNotSaved.text = [NSString fontAwesomeIconStringForEnum:FAExclamationCircle];
    }
    return _iconNotSaved;
}

- (UILabel *)labBusiness {
    if (!_labBusiness) {
        _labBusiness = [UILabel new];
        _labBusiness.textAlignment = NSTextAlignmentCenter;
        _labBusiness.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        _labBusiness.numberOfLines = 0;
        _labBusiness.minimumScaleFactor = 0.3;
        _labBusiness.adjustsFontSizeToFitWidth = YES;
    }
    return _labBusiness;
}

- (UILabel *)labRate {
    if (!_labRate) {
        _labRate = [UILabel new];
        _labRate.textAlignment = NSTextAlignmentCenter;
        _labRate.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _labRate;
}

- (UILabel *)labProvinceAndCity {
    if (!_labProvinceAndCity) {
        _labProvinceAndCity = [UILabel new];
        _labProvinceAndCity.textAlignment = NSTextAlignmentCenter;
        _labProvinceAndCity.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _labProvinceAndCity;
}

- (UIButton *)btnReset {
    if (!_btnReset) {
        _btnReset = [UIButton new];
        [_btnReset setTitle:@"重新设置" forState:UIControlStateNormal];
        [_btnReset setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnReset setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.7] forState:UIControlStateHighlighted];
        _btnReset.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        [_btnReset addTarget:self action:@selector(clickedResetBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnReset;
}

- (UIButton *)btnClear {
    if (!_btnClear) {
        _btnClear = [UIButton new];
        [_btnClear setTitle:@"清除历史保存" forState:UIControlStateNormal];
        [_btnClear setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnClear setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.7] forState:UIControlStateHighlighted];
        [_btnClear addTarget:self action:@selector(clickedClearBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnClear;
}

- (UILabel *)noteLabEffective {
    if (!_noteLabEffective) {
        _noteLabEffective = [UILabel new];
        _noteLabEffective.textAlignment = NSTextAlignmentCenter;
        _noteLabEffective.textColor = [UIColor grayColor];
    }
    return _noteLabEffective;
}

- (UIBarButtonItem*) newCancelBarBtn {
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [cancelBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAHome] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:25 scale:1]];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(clickedCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
}

@end
