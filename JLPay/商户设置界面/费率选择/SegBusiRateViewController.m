//
//  SegBusiRateViewController.m
//  JLPay
//
//  Created by jielian on 16/3/2.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SegBusiRateViewController.h" // 多商户
#import "PullListSegView.h"
#import "Define_Header.h"
#import "ChooseButton.h"
#import "PublicInformation.h"
#import "KVNProgress+CustomConfiguration.h"
#import "Masonry.h"
#import "ModelBusinessInfoSaved.h"
#import "HTTPRequestFeeBusiness.h"
#import "SQLRequestAreas.h"
#import "ModelRateInfoSaved.h"
#import "RateChooseViewController.h"
#import "VMRateTypes.h"

static NSString* const kKVOBusiRateTypeSelected = @"rateTypeSelected";
static NSString* const kKVOBusiProvinceNameSelected = @"provinceNameSelected";
static NSString* const kKVOBusiCityNameSelected = @"cityNameSelected";
static NSString* const kKVOBusiBusinessNameSelected = @"businessNameSelected";


@interface SegBusiRateViewController ()
<UIAlertViewDelegate>
{
    UIColor* lightBlue;
}
@property (nonatomic, strong) PullListSegView* pullSegView;

// 费率
@property (nonatomic, strong) UILabel* rateTitle;
@property (nonatomic, strong) ChooseButton* rateButton;
@property (nonatomic, strong) UILabel* labelRateSavedPre;
@property (nonatomic, strong) UILabel* labelRateSavedDesc;
// 省
@property (nonatomic, strong) UILabel* provinceTitle;
@property (nonatomic, strong) ChooseButton* provinceButton;
@property (nonatomic, strong) UILabel* labelProvinceSavedPre;
@property (nonatomic, strong) UILabel* labelProvinceSavedDesc;
// 市
@property (nonatomic, strong) UILabel* cityTitle;
@property (nonatomic, strong) ChooseButton* cityButton;
@property (nonatomic, strong) UILabel* labelCitySavedPre;
@property (nonatomic, strong) UILabel* labelCitySavedDesc;
// 商户
@property (nonatomic, strong) UILabel* businessTitle;
@property (nonatomic, strong) ChooseButton* businessButton;
@property (nonatomic, strong) UILabel* labelBusinessSavedPre;
@property (nonatomic, strong) UILabel* labelBusinessSavedDesc;


// 保存|清除
@property (nonatomic, strong) UIButton* savingButton;
@property (nonatomic, strong) UIButton* clearingButton;

@property (nonatomic, strong) HTTPRequestFeeBusiness* businessHttp;
@property (nonatomic, strong) SQLRequestAreas* sqlAreas;
@property (nonatomic, strong) VMRateTypes* rateTypes;

@end

@implementation SegBusiRateViewController




#pragma mask 1 IBAction
- (IBAction) clickToChooseRate:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    [sender turningDirection:YES];
    self.pullSegView.tableView.dataSource = (id)self.rateTypes;
    self.pullSegView.tableView.delegate = (id)self.rateTypes;
    [self.pullSegView showAnimation];
}

- (IBAction) clickToChooseProvince:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    [sender turningDirection:YES];
    [self requestProvinces];
}

- (IBAction) clickToChooseCity:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    if (!self.sqlAreas.provinceNameSelected) {
        [PublicInformation makeCentreToast:@"请先选择'省'"];
        return;
    }
    [sender turningDirection:YES];
    [self requestCitiesOnProvinceCode:self.sqlAreas.provinceCodeSelected];
}

- (IBAction) clickToChooseBusiness:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    
    if (!self.rateTypes.rateTypeSelected) {
        [PublicInformation makeCentreToast:@"请先选择'费率'"];
        return;
    }
    if (!self.sqlAreas.provinceNameSelected) {
        [PublicInformation makeCentreToast:@"请先选择'省'"];
        return;
    }
    if (!self.sqlAreas.cityNameSelected) {
        [PublicInformation makeCentreToast:@"请先选择'市'"];
        return;
    }
    [self requestBusinessesOnRateCode:self.rateTypes.rateValueSelected andAreaCode:self.sqlAreas.cityCodeSelected];
}

- (IBAction) clickToSaveBusinessInfo:(UIButton*)sender {
    if (!self.rateTypes.rateTypeSelected) {
        [PublicInformation makeCentreToast:@"未选择费率类型,请先选择'费率'"];
        return;
    }
    if (!self.sqlAreas.provinceNameSelected) {
        [PublicInformation makeCentreToast:@"未选择省份,请先选择'省份'"];
        return;
    }
    if (!self.sqlAreas.cityNameSelected) {
        [PublicInformation makeCentreToast:@"未选择市,请先选择'市'"];
        return;
    }
    if (!self.businessHttp.businessNameSelected) {
        [PublicInformation makeCentreToast:@"未选择商户,请先选择'商户'"];
        return;
    }
    
    if ([ModelBusinessInfoSaved beenSaved]) {
        [ModelBusinessInfoSaved clearSaved];
    }
    [ModelBusinessInfoSaved savingBusinessInfoWithRateType:self.rateTypes.rateTypeSelected
                                              provinceName:self.sqlAreas.provinceNameSelected
                                              provinceCode:self.sqlAreas.provinceCodeSelected
                                                  cityName:self.sqlAreas.cityNameSelected
                                                  cityCode:self.sqlAreas.cityCodeSelected
                                              businessName:self.businessHttp.businessNameSelected
                                              businessCode:self.businessHttp.businessCodeSelected
                                              terminalCode:self.businessHttp.terminalCodeSelected];
    [PublicInformation makeToast:@"保存费率信息成功!"];
    [self updateRateInfoDisplayed];
    // 多费率|多商户 只能选其一
    if ([ModelRateInfoSaved beenSaved]) {
        [ModelRateInfoSaved clearSaved];
    }
}
- (IBAction) clickToClearSavedBusinessInfo:(UIButton*)sender {
    if ([ModelBusinessInfoSaved beenSaved]) {
        [ModelBusinessInfoSaved clearSaved];
        [self updateRateInfoDisplayed];
        [PublicInformation makeToast:@"已清空保存的费率信息!"];
    } else {
        [PublicInformation makeToast:@"没有已保存的费率信息!"];
    }
}

#pragma mask 1 KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kKVOBusiRateTypeSelected]) {
        [self.rateButton setTitle:self.rateTypes.rateTypeSelected forState:UIControlStateNormal];
        [self.rateButton turningDirection:NO];
        [self.pullSegView hiddenAnimation];
    }
    else if ([keyPath isEqualToString:kKVOBusiProvinceNameSelected]) {
        [self.provinceButton setTitle:self.sqlAreas.provinceNameSelected forState:UIControlStateNormal];
        [self.provinceButton turningDirection:NO];
        [self.pullSegView hiddenAnimation];
    }
    else if ([keyPath isEqualToString:kKVOBusiCityNameSelected]) {
        [self.cityButton setTitle:self.sqlAreas.cityNameSelected forState:UIControlStateNormal];
        [self.cityButton turningDirection:NO];
        [self.pullSegView hiddenAnimation];
    }
    else if ([keyPath isEqualToString:kKVOBusiBusinessNameSelected]) {
        [self.businessButton setTitle:self.businessHttp.businessNameSelected forState:UIControlStateNormal];
        [self.businessButton turningDirection:NO];
        [self.pullSegView hiddenAnimation];
    }
}


#pragma mask 3 private interface: 数据申请
// -- 查询省信息
- (void) requestProvinces
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress show];
    });
    NameWeakSelf(wself);
    [self.sqlAreas requestAreasOnCode:@"156" onSucBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });
        wself.pullSegView.tableView.dataSource = (id)wself.sqlAreas;
        wself.pullSegView.tableView.delegate = (id)wself.sqlAreas;
        [wself.pullSegView showAnimation];
    } onErrBlock:^(NSError *error) {
        [wself.provinceButton turningDirection:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showErrorWithStatus:[error localizedDescription] duration:2];
        });
    }];
}
// -- 查询市信息
- (void) requestCitiesOnProvinceCode:(NSString*)provinceCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress show];
    });
    NameWeakSelf(wself);
    [self.sqlAreas requestAreasOnCode:provinceCode onSucBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });
        wself.pullSegView.tableView.dataSource = (id)wself.sqlAreas;
        wself.pullSegView.tableView.delegate = (id)wself.sqlAreas;
        [wself.pullSegView showAnimation];
    } onErrBlock:^(NSError *error) {
        [wself.cityButton turningDirection:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showErrorWithStatus:[error localizedDescription] duration:2];
        });
    }];
}
// -- 查询商户信息
- (void) requestBusinessesOnRateCode:(NSString*)rateCode andAreaCode:(NSString*)areaCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress show];
    });
    NameWeakSelf(wself);
    [self.businessHttp requestFeeBusinessOnFeeType:rateCode areaCode:areaCode onSucBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });
        wself.pullSegView.tableView.dataSource = (id)self.businessHttp;
        wself.pullSegView.tableView.delegate = (id)self.businessHttp;
        [wself.pullSegView showAnimation];
    } onErrBlock:^(NSError *error) {
        [wself.businessButton turningDirection:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showErrorWithStatus:[error localizedDescription] duration:2];
        });
    }];
}


#pragma mask 2 private interface: 界面布局

// -- 重新布局下拉展示视图
- (void) reframePullListViewLayonButton:(UIButton*)button {
    CGRect frame = button.frame;
    frame.origin.x += 10;
    frame.origin.y += frame.size.height + 5.f;
    frame.size.width -= 10*2;
    [self.pullSegView setFrame:frame];
}
// -- label的长度
- (CGFloat) textWidthOfLabel:(UILabel*)label {
    return  [label.text sizeWithAttributes:[NSDictionary dictionaryWithObject:label.font forKey:NSFontAttributeName]].width;
}


// -- 更新保存信息提示:
- (void) updateRateInfoDisplayed {
    if ([ModelBusinessInfoSaved beenSaved]) {
        self.labelRateSavedDesc.text = [ModelBusinessInfoSaved rateTypeSelected];
        self.labelProvinceSavedDesc.text = [ModelBusinessInfoSaved provinceName];
        self.labelCitySavedDesc.text = [ModelBusinessInfoSaved cityName];
        self.labelBusinessSavedDesc.text = [ModelBusinessInfoSaved businessName];
    } else {
        self.labelRateSavedDesc.text = @"无";
        self.labelProvinceSavedDesc.text = @"无";
        self.labelCitySavedDesc.text = @"无";
        self.labelBusinessSavedDesc.text = @"无";
    }
}


#pragma mask 4 getter
// 下拉显示列表
- (PullListSegView *)pullSegView {
    if (!_pullSegView) {
        _pullSegView = [[PullListSegView alloc] init];
    }
    return _pullSegView;
}
// 费率
- (ChooseButton *)rateButton {
    if (!_rateButton) {
        _rateButton = [[ChooseButton alloc] initWithFrame:CGRectZero];
        _rateButton.layer.borderColor = lightBlue.CGColor;
        _rateButton.layer.borderWidth = 0.7;
        _rateButton.nomalColor = lightBlue;
        _rateButton.selectedColor = [UIColor colorWithWhite:0.7 alpha:0.8];
        _rateButton.chooseButtonType = ChooseButtonTypeRect;
        [_rateButton setTitle:@"费率" forState:UIControlStateNormal];
        [_rateButton setTitleColor:lightBlue forState:UIControlStateNormal];
        [_rateButton addTarget:self action:@selector(clickToChooseRate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rateButton;
}
// 省份
- (ChooseButton *)provinceButton {
    if (!_provinceButton) {
        _provinceButton = [[ChooseButton alloc] initWithFrame:CGRectZero];
        _provinceButton.layer.borderColor = lightBlue.CGColor;
        _provinceButton.layer.borderWidth = 0.7;
        _provinceButton.nomalColor = lightBlue;
        _provinceButton.selectedColor = [UIColor colorWithWhite:0.7 alpha:0.8];
        _provinceButton.chooseButtonType = ChooseButtonTypeRect;
        [_provinceButton setTitle:@"省份" forState:UIControlStateNormal];
        [_provinceButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateNormal];
        [_provinceButton addTarget:self action:@selector(clickToChooseProvince:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _provinceButton;
}
// 城市
- (ChooseButton *)cityButton {
    if (!_cityButton) {
        _cityButton = [[ChooseButton alloc] initWithFrame:CGRectZero];
        _cityButton.layer.borderColor = lightBlue.CGColor;
        _cityButton.layer.borderWidth = 0.7;
        _cityButton.nomalColor = lightBlue;
        _cityButton.selectedColor = [UIColor colorWithWhite:0.7 alpha:0.8];
        _cityButton.chooseButtonType = ChooseButtonTypeRect;
        [_cityButton setTitle:@"市" forState:UIControlStateNormal];
        [_cityButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateNormal];
        [_cityButton addTarget:self action:@selector(clickToChooseCity:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cityButton;
}
// 商户
- (ChooseButton *)businessButton {
    if (!_businessButton) {
        _businessButton = [[ChooseButton alloc] initWithFrame:CGRectZero];
        _businessButton.layer.borderColor = lightBlue.CGColor;
        _businessButton.layer.borderWidth = 0.7;
        _businessButton.nomalColor = lightBlue;
        _businessButton.selectedColor = [UIColor colorWithWhite:0.7 alpha:0.8];
        _businessButton.chooseButtonType = ChooseButtonTypeRect;
        [_businessButton setTitle:@"商户" forState:UIControlStateNormal];
        [_businessButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateNormal];
        [_businessButton addTarget:self action:@selector(clickToChooseBusiness:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _businessButton;
}


// 保存按钮
- (UIButton *)savingButton {
    if (!_savingButton) {
        _savingButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_savingButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_savingButton setTitle:@"保存" forState:UIControlStateNormal];
        [_savingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_savingButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateHighlighted];
        [_savingButton addTarget:self action:@selector(clickToSaveBusinessInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _savingButton;
}
// 清除按钮
- (UIButton *)clearingButton {
    if (!_clearingButton) {
        _clearingButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_clearingButton setBackgroundColor:[UIColor grayColor]];
        [_clearingButton setTitle:@"清除" forState:UIControlStateNormal];
        [_clearingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_clearingButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:0.9] forState:UIControlStateHighlighted];
        [_clearingButton addTarget:self action:@selector(clickToClearSavedBusinessInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearingButton;
}

// 标题
- (UILabel *)rateTitle {
    if (!_rateTitle) {
        _rateTitle = [UILabel new];
        _rateTitle.text = @"费率";
        _rateTitle.textColor = lightBlue;
    }
    return _rateTitle;
}
- (UILabel *)provinceTitle{
    if (!_provinceTitle) {
        _provinceTitle = [UILabel new];
        _provinceTitle.text = @"省";
        _provinceTitle.textColor = lightBlue;
    }
    return _provinceTitle;
}
- (UILabel *)cityTitle {
    if (!_cityTitle) {
        _cityTitle = [UILabel new];
        _cityTitle.text = @"市";
        _cityTitle.textColor = lightBlue;
    }
    return _cityTitle;
}
- (UILabel *)businessTitle {
    if (!_businessTitle) {
        _businessTitle = [UILabel new];
        _businessTitle.text = @"商户";
        _businessTitle.textColor = lightBlue;
    }
    return _businessTitle;
}

// 显示保存信息
- (UILabel *)labelRateSavedPre {
    if (!_labelRateSavedPre) {
        _labelRateSavedPre = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelRateSavedPre.text = @"已保存费率:";
        _labelRateSavedPre.textColor = lightBlue;
    }
    return _labelRateSavedPre;
}
- (UILabel *)labelRateSavedDesc {
    if (!_labelRateSavedDesc) {
        _labelRateSavedDesc = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelRateSavedDesc.text = @"无";
        _labelRateSavedDesc.textColor = lightBlue;
    }
    return _labelRateSavedDesc;
}

- (UILabel *)labelProvinceSavedPre {
    if (!_labelProvinceSavedPre) {
        _labelProvinceSavedPre = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelProvinceSavedPre.text = @"已保存省:";
        _labelProvinceSavedPre.textColor = lightBlue;
    }
    return _labelProvinceSavedPre;
}
- (UILabel *)labelProvinceSavedDesc {
    if (!_labelProvinceSavedDesc) {
        _labelProvinceSavedDesc = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelProvinceSavedDesc.text = @"无";
        _labelProvinceSavedDesc.textColor = lightBlue;
    }
    return _labelProvinceSavedDesc;
}
- (UILabel *)labelCitySavedPre {
    if (!_labelCitySavedPre) {
        _labelCitySavedPre = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelCitySavedPre.text = @"已保存市:";
        _labelCitySavedPre.textColor = lightBlue;
    }
    return _labelCitySavedPre;
}
- (UILabel *)labelCitySavedDesc {
    if (!_labelCitySavedDesc) {
        _labelCitySavedDesc = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelCitySavedDesc.text = @"无";
        _labelCitySavedDesc.textColor = lightBlue;
    }
    return _labelCitySavedDesc;
}
- (UILabel *)labelBusinessSavedPre {
    if (!_labelBusinessSavedPre) {
        _labelBusinessSavedPre = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelBusinessSavedPre.text = @"已保存商户:";
        _labelBusinessSavedPre.textColor = lightBlue;
    }
    return _labelBusinessSavedPre;
}
- (UILabel *)labelBusinessSavedDesc {
    if (!_labelBusinessSavedDesc) {
        _labelBusinessSavedDesc = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelBusinessSavedDesc.text = @"无";
        _labelBusinessSavedDesc.textColor = lightBlue;
    }
    return _labelBusinessSavedDesc;
}

- (HTTPRequestFeeBusiness *)businessHttp {
    if (!_businessHttp) {
        _businessHttp = [[HTTPRequestFeeBusiness alloc] init];
    }
    return _businessHttp;
}
- (SQLRequestAreas *)sqlAreas {
    if (!_sqlAreas) {
        _sqlAreas = [[SQLRequestAreas alloc] init];
    }
    return _sqlAreas;
}
- (VMRateTypes *)rateTypes {
    if (!_rateTypes) {
        _rateTypes = [[VMRateTypes alloc] init];
    }
    return _rateTypes;
}

#pragma mask 0 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initialProperties];
    [self loadSubViews];
    [self relayoutSubViews];
    [self updateRateInfoDisplayed];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateRateInfoDisplayed];
    RateChooseViewController* viewC = (RateChooseViewController*)self.parentViewController;
    viewC.canChangeViewController = YES;
    [self addKVOs];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKVOs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) addKVOs {
    [self.rateTypes addObserver:self forKeyPath:kKVOBusiRateTypeSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.sqlAreas addObserver:self forKeyPath:kKVOBusiProvinceNameSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.sqlAreas addObserver:self forKeyPath:kKVOBusiCityNameSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.businessHttp addObserver:self forKeyPath:kKVOBusiBusinessNameSelected options:NSKeyValueObservingOptionNew context:nil];

}
- (void) removeKVOs {
    [self.rateTypes removeObserver:self forKeyPath:kKVOBusiRateTypeSelected];
    [self.sqlAreas removeObserver:self forKeyPath:kKVOBusiProvinceNameSelected];
    [self.sqlAreas removeObserver:self forKeyPath:kKVOBusiCityNameSelected];
    [self.businessHttp removeObserver:self forKeyPath:kKVOBusiBusinessNameSelected];
}


- (void) loadSubViews {
    [self.view addSubview:self.rateTitle];
    [self.view addSubview:self.rateButton];
    [self.view addSubview:self.labelRateSavedPre];
    [self.view addSubview:self.labelRateSavedDesc];
    
    [self.view addSubview:self.provinceTitle];
    [self.view addSubview:self.provinceButton];
    [self.view addSubview:self.labelProvinceSavedDesc];
    [self.view addSubview:self.labelProvinceSavedPre];
    
    [self.view addSubview:self.cityTitle];
    [self.view addSubview:self.cityButton];
    [self.view addSubview:self.labelCitySavedDesc];
    [self.view addSubview:self.labelCitySavedPre];
    
    [self.view addSubview:self.businessTitle];
    [self.view addSubview:self.businessButton];
    [self.view addSubview:self.labelBusinessSavedPre];
    [self.view addSubview:self.labelBusinessSavedDesc];
    
    [self.view addSubview:self.savingButton];
    [self.view addSubview:self.clearingButton];
    
    [self.view addSubview:self.pullSegView];
}

- (void) relayoutSubViews {
    CGRect frame = self.view.bounds;
    
    NameWeakSelf(wself);
    
    CGFloat maxVerticalInset = 15.f;
    CGFloat minVerticalInset = 4.f;
    
    CGFloat maxHorizontalInset = 25.f;
    CGFloat minHorizontalInset = 15.f;
    
    CGFloat buttonBigHeight = 40;
    
    CGFloat labelBigHeight = 35;
    CGFloat labelLittleHeight = 16;
    
    CGFloat provinceWidth = (frame.size.width - maxHorizontalInset*2 - minHorizontalInset)/2.f;
    
    // 重置文本字体大小
    CGSize maxLabelSize = CGSizeMake(10, labelBigHeight);
    CGSize minLabelSize = CGSizeMake(10, labelLittleHeight);
    CGFloat titleScale = 0.6;
    CGFloat savedScale = 1.f;
    
    self.rateTitle.font = [UIFont boldSystemFontOfSize:[PublicInformation resizeFontInSize:maxLabelSize andScale:titleScale]];
    self.provinceTitle.font = [UIFont boldSystemFontOfSize:[PublicInformation resizeFontInSize:maxLabelSize andScale:titleScale]];
    self.cityTitle.font = [UIFont boldSystemFontOfSize:[PublicInformation resizeFontInSize:maxLabelSize andScale:titleScale]];
    self.businessTitle.font = [UIFont boldSystemFontOfSize:[PublicInformation resizeFontInSize:maxLabelSize andScale:titleScale]];
    
    self.labelProvinceSavedDesc.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelProvinceSavedPre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelCitySavedDesc.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelCitySavedPre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelRateSavedDesc.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelRateSavedPre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelBusinessSavedDesc.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelBusinessSavedPre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    
    // 费率
    [self.rateTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(frame.size.width - maxHorizontalInset*2, labelBigHeight));
        make.top.equalTo(wself.view.mas_top);
        make.left.equalTo(wself.view.mas_left).offset(maxHorizontalInset);
    }];
    [self.rateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(frame.size.width - maxHorizontalInset*2, buttonBigHeight));
        make.top.equalTo(wself.rateTitle.mas_bottom);
        make.left.equalTo(wself.rateTitle.mas_left);
    }];
    [self.labelRateSavedPre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([wself textWidthOfLabel:wself.labelRateSavedPre]);
        make.height.mas_equalTo(labelLittleHeight);
        make.top.equalTo(wself.rateButton.mas_bottom).offset(minVerticalInset);
        make.left.equalTo(wself.rateButton.mas_left);
    }];
    [self.labelRateSavedDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(labelLittleHeight);
        make.width.mas_equalTo(frame.size.width - maxHorizontalInset - [wself textWidthOfLabel:wself.labelRateSavedPre]);
        make.left.equalTo(wself.labelRateSavedPre.mas_right);
        make.top.equalTo(wself.labelRateSavedPre.mas_top);
    }];
    
    // 省
    [self.provinceTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(provinceWidth, labelBigHeight));
        make.top.equalTo(wself.labelRateSavedDesc.mas_bottom);
        make.left.equalTo(wself.view.mas_left).offset(maxHorizontalInset);
    }];
    [self.provinceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(provinceWidth, buttonBigHeight));
        make.top.equalTo(wself.provinceTitle.mas_bottom);
        make.left.equalTo(wself.provinceTitle.mas_left);
    }];
    [self.labelProvinceSavedPre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([wself textWidthOfLabel:wself.labelProvinceSavedPre] + 2);
        make.height.mas_equalTo(labelLittleHeight);
        make.top.equalTo(wself.provinceButton.mas_bottom).offset(minVerticalInset);
        make.left.equalTo(wself.provinceButton.mas_left);
    }];
    [self.labelProvinceSavedDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(labelLittleHeight);
        make.left.equalTo(wself.labelProvinceSavedPre.mas_right);
        make.top.equalTo(wself.labelProvinceSavedPre.mas_top);
        make.right.equalTo(wself.provinceButton.mas_right);
    }];
    
    // 市
    [self.cityTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(provinceWidth, labelBigHeight));
        make.top.equalTo(wself.provinceTitle.mas_top);
        make.left.equalTo(wself.provinceTitle.mas_right).offset(minHorizontalInset);
    }];
    [self.cityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(provinceWidth, buttonBigHeight));
        make.top.equalTo(wself.cityTitle.mas_bottom);
        make.left.equalTo(wself.cityTitle.mas_left);
    }];
    [self.labelCitySavedPre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([wself textWidthOfLabel:wself.labelCitySavedPre] + 2);
        make.height.mas_equalTo(labelLittleHeight);
        make.top.equalTo(wself.cityButton.mas_bottom).offset(minVerticalInset);
        make.left.equalTo(wself.cityButton.mas_left);
    }];
    [self.labelCitySavedDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(labelLittleHeight);
        make.left.equalTo(wself.labelCitySavedPre.mas_right);
        make.top.equalTo(wself.labelCitySavedPre.mas_top);
        make.right.equalTo(wself.cityButton.mas_right);
    }];
    
    // 商户
    [self.businessTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(frame.size.width - maxHorizontalInset*2, labelBigHeight));
        make.top.equalTo(wself.labelProvinceSavedPre.mas_bottom);
        make.left.equalTo(wself.labelProvinceSavedPre.mas_left);
    }];
    [self.businessButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(frame.size.width - maxHorizontalInset*2, buttonBigHeight));
        make.top.equalTo(wself.businessTitle.mas_bottom);
        make.left.equalTo(wself.businessTitle.mas_left);
    }];
    [self.labelBusinessSavedPre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([wself textWidthOfLabel:wself.labelBusinessSavedPre] + 2);
        make.height.mas_equalTo(labelLittleHeight);
        make.top.equalTo(wself.businessButton.mas_bottom).offset(minVerticalInset);
        make.left.equalTo(wself.businessButton.mas_left);
    }];
    [self.labelBusinessSavedDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(labelLittleHeight);
        make.left.equalTo(wself.labelBusinessSavedPre.mas_right);
        make.top.equalTo(wself.labelBusinessSavedPre.mas_top);
        make.right.equalTo(wself.businessButton.mas_right);
    }];
    
    
    // 清除，保存
    [self.clearingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(provinceWidth, buttonBigHeight));
        make.top.equalTo(wself.labelBusinessSavedPre.mas_bottom).offset(maxVerticalInset + minVerticalInset);
        make.left.equalTo(wself.rateButton.mas_left);
    }];
    [self.savingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(wself.clearingButton);
        make.top.equalTo(wself.clearingButton.mas_top);
        make.left.equalTo(wself.clearingButton.mas_right).offset(minHorizontalInset);
    }];
    
}

- (void) initialProperties {
    lightBlue = [PublicInformation colorForHexInt:0x292421];
}
@end
