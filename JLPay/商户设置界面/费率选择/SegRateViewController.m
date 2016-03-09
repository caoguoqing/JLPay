//
//  SegRateViewController.m
//  JLPay
//
//  Created by jielian on 16/3/2.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SegRateViewController.h" // 多费率
#import "PullListSegView.h"
#import "Define_Header.h"
#import "ChooseButton.h"
#import "HttpRequestAreas.h"
#import "ModelRateInfoSaved.h"
#import "PublicInformation.h"
#import "KVNProgress+CustomConfiguration.h"
#import "Masonry.h"
#import "ModelBusinessInfoSaved.h"
#import "RateChooseViewController.h"


@interface SegRateViewController ()
<UIAlertViewDelegate>
{
    NSInteger iTagAlertForProvince;
    NSInteger iTagAlertForCity;
    UIColor* segmentTintColor;
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

// 保存|清除
@property (nonatomic, strong) UIButton* savingButton;
@property (nonatomic, strong) UIButton* clearingButton;


// 获取的省、市的临时列表
@property (nonatomic, strong) NSArray* provincesRequsted;
@property (nonatomic, strong) NSArray* citiesRequested;

// -- 已选择的费率、省、市
@property (nonatomic, strong) NSString* rateTypeSelected;
@property (nonatomic, strong) NSString* provinceNameSelected;
@property (nonatomic, strong) NSString* cityNameSelected;

@property (nonatomic, strong) HttpRequestAreas* http;


@end

@implementation SegRateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self initialProperties];
    [self loadSubViews];
    [self relayoutSubViews];
    [self updateRateInfoDisplayed];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestingProvinces];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateRateInfoDisplayed];
    RateChooseViewController* parentVC = (RateChooseViewController*)self.parentViewController;
    parentVC.canChangeViewController = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.http terminateRequesting];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) initialProperties {
    iTagAlertForProvince = 10;
    iTagAlertForCity = 11;
    segmentTintColor = [PublicInformation colorForHexInt:0x292421];
}

#pragma mask 1 IBAction
- (IBAction) clickToChooseRate:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    NSArray* aaa = [ModelRateInfoSaved allRateTypes];
    [self.pullSegView setDataSouces:aaa];
    NameWeakSelf(wself);
    [sender turningDirection:YES];
    [self.pullSegView showForSelection:^(NSInteger selectedIndex) {
        wself.rateTypeSelected = [aaa objectAtIndex:selectedIndex];
        [wself.rateButton setTitle:wself.rateTypeSelected forState:UIControlStateNormal];
        [sender turningDirection:NO];
    }];
}
- (IBAction) clickToChooseProvince:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    NameWeakSelf(wself);
    if (self.provincesRequsted) {
        NSArray* provinceNames = [self provinceNamesInList];
        [self.pullSegView setDataSouces:provinceNames];
        [sender turningDirection:YES];
        [self.pullSegView showForSelection:^(NSInteger selectedIndex) {
            [sender turningDirection:NO];

            NSString* curProvince = [sender titleForState:UIControlStateNormal];
            if (![curProvince isEqualToString:[provinceNames objectAtIndex:selectedIndex]]) {
                wself.provinceNameSelected = [provinceNames objectAtIndex:selectedIndex];
                [sender setTitle:wself.provinceNameSelected forState:UIControlStateNormal];
                // 更新市按钮
                [wself.cityButton setTitle:@"市" forState:UIControlStateNormal];
                wself.cityNameSelected = nil;
                // 查询对应的市列表
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [wself requestingCitiesOnProvinceCode:[wself provinceCodeForName:wself.provinceNameSelected]];
                });
            }
        }];
        
    } else {
        [self alertForNullProvinces];
    }
}
- (IBAction) clickToChooseCity:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    if (!self.provinceNameSelected) {
        [PublicInformation makeCentreToast:@"请先选择'省'"];
        return;
    }
    
    NameWeakSelf(wself);
    if (self.citiesRequested) {
        NSArray* cityNames = [self cityNamesInList];
        [self.pullSegView setDataSouces:cityNames];
        [sender turningDirection:YES];
        [self.pullSegView showForSelection:^(NSInteger selectedIndex) {
            [sender turningDirection:NO];
            wself.cityNameSelected = [cityNames objectAtIndex:selectedIndex];
            [sender setTitle:wself.cityNameSelected forState:UIControlStateNormal];
        }];
    } else {
        [self alertForNullCities];
    }
}

- (IBAction) clickToSaveRateInfo:(UIButton*)sender {
    if (!self.rateTypeSelected) {
        [PublicInformation makeCentreToast:@"未选择费率类型,请先选择'费率'"];
        return;
    }
    if (!self.provinceNameSelected) {
        [PublicInformation makeCentreToast:@"未选择省份,请先选择'省份'"];
        return;
    }
    if (!self.cityNameSelected) {
        [PublicInformation makeCentreToast:@"未选择市,请先选择'市'"];
        return;
    }

    if ([ModelRateInfoSaved beenSaved]) {
        [ModelRateInfoSaved clearSaved];
    }
    [ModelRateInfoSaved savingRateInfoWithRateType:self.rateTypeSelected
                                      provinceName:self.provinceNameSelected
                                      provinceCode:[self provinceCodeForName:self.provinceNameSelected]
                                          cityName:self.cityNameSelected
                                          cityCode:[self cityCodeForName:self.cityNameSelected]];
    [PublicInformation makeToast:@"保存费率信息成功!"];
    [self updateRateInfoDisplayed];
    // 多费率|多商户 只能选其一
    if ([ModelBusinessInfoSaved beenSaved]) {
        [ModelBusinessInfoSaved clearSaved];
    }
}
- (IBAction) clickToClearSavedRateInfo:(UIButton*)sender {
    if ([ModelRateInfoSaved beenSaved]) {
        [ModelRateInfoSaved clearSaved];
        [self updateRateInfoDisplayed];
        [PublicInformation makeToast:@"已清空保存的费率信息!"];
    } else {
        [PublicInformation makeToast:@"没有已保存的费率信息!"];
    }
}


#pragma mask 2 model
// -- 省名列表: 从省列表中解析
- (NSArray*) provinceNamesInList {
    NSMutableArray* provinceNames = [NSMutableArray array];
    for (NSDictionary* provinceNode in self.provincesRequsted) {
        [provinceNames addObject:[provinceNode objectForKey:kHttpAreaName]];
    }
    return provinceNames;
}
// -- 市名列表: 从市列表中解析
- (NSArray*) cityNamesInList {
    NSMutableArray* cityNames = [NSMutableArray array];
    for (NSDictionary* cityNode in self.citiesRequested) {
        [cityNames addObject:[cityNode objectForKey:kHttpAreaName]];
    }
    return cityNames;
}
// --
- (NSString*) provinceCodeForName:(NSString*)provinceName {
    NSString* provinceCode = nil;
    for (NSDictionary* node in self.provincesRequsted) {
        if ([provinceName isEqualToString:[node objectForKey:kHttpAreaName]]) {
            provinceCode = [node objectForKey:kHttpAreaCode];
            break;
        }
    }
    return provinceCode;
}
- (NSString*) cityCodeForName:(NSString*)cityName {
    NSString* cityCode = nil;
    for (NSDictionary* node in self.citiesRequested) {
        if ([cityName isEqualToString:[node objectForKey:kHttpAreaName]]) {
            cityCode = [node objectForKey:kHttpAreaCode];
            break;
        }
    }
    return cityCode;
}

#pragma mask 2 private interface

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

// -- 申请省数据
- (void) requestingProvinces {
    [self.http terminateRequesting];
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress show];
    });
    NameWeakSelf(wself);
    [self.http requestAreasOnCode:@"156" onSucBlock:^(NSArray *areas) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });
        wself.provincesRequsted = [areas copy];
    } onErrBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showErrorWithStatus:@"查询省数据失败,请重试!" duration:2];
        });
        wself.provincesRequsted = nil;
    }];
}
// -- 申请市数据
- (void) requestingCitiesOnProvinceCode:(NSString*)provinceCode {
    [self.http terminateRequesting];
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress show];
    });
    NameWeakSelf(wself);
    [self.http requestAreasOnCode:provinceCode onSucBlock:^(NSArray *areas) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });
        wself.citiesRequested = [areas copy];
    } onErrBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showErrorWithStatus:@"查询省数据失败,请重试!" duration:2];
        });
        wself.citiesRequested = nil;
    }];
}

// -- 提示: 无省份,是否重新查询
- (void) alertForNullProvinces {
    [PublicInformation alertCancle:@"取消"
                             other:@"重新查询"
                             title:@"查无省份数据"
                           message:@"是否重新查询可用的省份信息?"
                               tag:iTagAlertForProvince
                          delegate:self];
}
// -- 提示: 无市,判断是否查询了省;是否重新查询市
- (void) alertForNullCities {
    [PublicInformation alertCancle:@"取消"
                             other:@"重新查询"
                             title:@"查无市数据"
                           message:@"是否重新查询可用的市信息?"
                               tag:iTagAlertForCity
                          delegate:self];
}

// -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == iTagAlertForProvince) {
            [self requestingProvinces];
        }
        else if (alertView.tag == iTagAlertForCity) {
            NSString* provinceNameSelected = [self.provinceButton titleForState:UIControlStateNormal];
            [self requestingCitiesOnProvinceCode:[self provinceCodeForName:provinceNameSelected]];
        }
    }
}

// -- 更新保存信息提示:
- (void) updateRateInfoDisplayed {
    if ([ModelRateInfoSaved beenSaved]) {
        self.labelRateSavedDesc.text = [ModelRateInfoSaved rateTypeSelected];
        self.labelProvinceSavedDesc.text = [ModelRateInfoSaved provinceName];
        self.labelCitySavedDesc.text = [ModelRateInfoSaved cityName];
    } else {
        self.labelRateSavedDesc.text = @"无";
        self.labelProvinceSavedDesc.text = @"无";
        self.labelCitySavedDesc.text = @"无";
    }
}


#pragma mask 4 getter
// 下拉显示列表
- (PullListSegView *)pullSegView {
    if (!_pullSegView) {
        _pullSegView = [[PullListSegView alloc] initWithDataSource:[ModelRateInfoSaved allRateTypes]];
    }
    return _pullSegView;
}
// 费率
- (ChooseButton *)rateButton {
    if (!_rateButton) {
        _rateButton = [[ChooseButton alloc] initWithFrame:CGRectZero];
        _rateButton.layer.borderWidth = 0.7;
        _rateButton.layer.borderColor = segmentTintColor.CGColor;
        _rateButton.nomalColor = segmentTintColor;
        _rateButton.selectedColor = [UIColor colorWithWhite:0.7 alpha:0.8];
        _rateButton.chooseButtonType = ChooseButtonTypeRect;
        [_rateButton setTitle:@"费率" forState:UIControlStateNormal];
        [_rateButton setTitleColor:segmentTintColor forState:UIControlStateNormal];
        [_rateButton addTarget:self action:@selector(clickToChooseRate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rateButton;
}
// 省份
- (ChooseButton *)provinceButton {
    if (!_provinceButton) {
        _provinceButton = [[ChooseButton alloc] initWithFrame:CGRectZero];
        _provinceButton.layer.borderWidth = 0.7;
        _provinceButton.layer.borderColor = segmentTintColor.CGColor;
        _provinceButton.nomalColor = segmentTintColor;
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
        _cityButton.layer.borderWidth = 0.7;
        _cityButton.layer.borderColor = segmentTintColor.CGColor;
        _cityButton.nomalColor = segmentTintColor;
        _cityButton.selectedColor = [UIColor colorWithWhite:0.7 alpha:0.8];
        _cityButton.chooseButtonType = ChooseButtonTypeRect;
        [_cityButton setTitle:@"市" forState:UIControlStateNormal];
        [_cityButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateNormal];
        [_cityButton addTarget:self action:@selector(clickToChooseCity:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cityButton;
}



// 保存按钮
- (UIButton *)savingButton {
    if (!_savingButton) {
        _savingButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_savingButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_savingButton setTitle:@"保存" forState:UIControlStateNormal];
        [_savingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_savingButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateHighlighted];
        [_savingButton addTarget:self action:@selector(clickToSaveRateInfo:) forControlEvents:UIControlEventTouchUpInside];
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
        [_clearingButton addTarget:self action:@selector(clickToClearSavedRateInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearingButton;
}

// 标题
- (UILabel *)rateTitle {
    if (!_rateTitle) {
        _rateTitle = [UILabel new];
        _rateTitle.text = @"费率";
        _rateTitle.textColor = segmentTintColor;
    }
    return _rateTitle;
}
- (UILabel *)provinceTitle{
    if (!_provinceTitle) {
        _provinceTitle = [UILabel new];
        _provinceTitle.text = @"省";
        _provinceTitle.textColor = segmentTintColor;
    }
    return _provinceTitle;
}
- (UILabel *)cityTitle {
    if (!_cityTitle) {
        _cityTitle = [UILabel new];
        _cityTitle.text = @"市";
        _cityTitle.textColor = segmentTintColor;
    }
    return _cityTitle;
}

// 显示保存信息
- (UILabel *)labelRateSavedPre {
    if (!_labelRateSavedPre) {
        _labelRateSavedPre = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelRateSavedPre.text = @"已保存费率:";
        _labelRateSavedPre.textColor = segmentTintColor;
    }
    return _labelRateSavedPre;
}
- (UILabel *)labelRateSavedDesc {
    if (!_labelRateSavedDesc) {
        _labelRateSavedDesc = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelRateSavedDesc.text = @"无";
        _labelRateSavedDesc.textColor = segmentTintColor;
    }
    return _labelRateSavedDesc;
}

- (UILabel *)labelProvinceSavedPre {
    if (!_labelProvinceSavedPre) {
        _labelProvinceSavedPre = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelProvinceSavedPre.text = @"已保存省:";
        _labelProvinceSavedPre.textColor = segmentTintColor;
    }
    return _labelProvinceSavedPre;
}
- (UILabel *)labelProvinceSavedDesc {
    if (!_labelProvinceSavedDesc) {
        _labelProvinceSavedDesc = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelProvinceSavedDesc.text = @"无";
        _labelProvinceSavedDesc.textColor = segmentTintColor;
    }
    return _labelProvinceSavedDesc;
}
- (UILabel *)labelCitySavedPre {
    if (!_labelCitySavedPre) {
        _labelCitySavedPre = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelCitySavedPre.text = @"已保存市:";
        _labelCitySavedPre.textColor = segmentTintColor;
    }
    return _labelCitySavedPre;
}
- (UILabel *)labelCitySavedDesc {
    if (!_labelCitySavedDesc) {
        _labelCitySavedDesc = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelCitySavedDesc.text = @"无";
        _labelCitySavedDesc.textColor = segmentTintColor;
    }
    return _labelCitySavedDesc;
}

- (HttpRequestAreas *)http {
    if (!_http) {
        _http = [[HttpRequestAreas alloc] init];
    }
    return _http;
}


#pragma mask 5 layout subviews 
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
    
    self.labelProvinceSavedDesc.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelProvinceSavedPre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelCitySavedDesc.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelCitySavedPre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelRateSavedDesc.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    self.labelRateSavedPre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:minLabelSize andScale:savedScale]];
    
    
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
    
    // 清除，保存
    [self.clearingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(provinceWidth, buttonBigHeight));
        make.top.equalTo(wself.labelCitySavedDesc.mas_bottom).offset(maxVerticalInset + minVerticalInset);
        make.left.equalTo(wself.rateButton.mas_left);
    }];
    [self.savingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(wself.clearingButton);
        make.top.equalTo(wself.clearingButton.mas_top);
        make.left.equalTo(wself.clearingButton.mas_right).offset(minHorizontalInset);
    }];
    
}


@end
