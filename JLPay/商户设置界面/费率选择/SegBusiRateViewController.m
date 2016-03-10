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

@interface SegBusiRateViewController ()
<UIAlertViewDelegate>
{
    NSInteger iTagAlertForProvince;
    NSInteger iTagAlertForCity;
    NSInteger iTagAlertForBusiness;
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


// 获取的省、市的临时列表
@property (nonatomic, strong) NSArray* provincesRequsted;
@property (nonatomic, strong) NSArray* citiesRequested;
@property (nonatomic, strong) NSArray* businessesRequested;

// -- 已选择的费率、省、市
@property (nonatomic, strong) NSString* rateTypeSelected;
@property (nonatomic, strong) NSString* provinceNameSelected;
@property (nonatomic, strong) NSString* cityNameSelected;
@property (nonatomic, strong) NSString* businessNameSelected;
@property (nonatomic, strong) NSString* terminalCodeSelected;

@property (nonatomic, strong) HTTPRequestFeeBusiness* businessHttp;

@end

@implementation SegBusiRateViewController

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
    [self requestProvinces];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateRateInfoDisplayed];
    RateChooseViewController* viewC = (RateChooseViewController*)self.parentViewController;
    viewC.canChangeViewController = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    iTagAlertForProvince = 10;
    iTagAlertForCity = 11;
    iTagAlertForBusiness = 12;
    lightBlue = [PublicInformation colorForHexInt:0x292421];
}

#pragma mask 1 IBAction
- (IBAction) clickToChooseRate:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    [sender turningDirection:YES];
    
    NSArray* rates = [ModelBusinessInfoSaved allRateTypes];
//    [self.pullSegView setDataSouces:rates];
    NameWeakSelf(wself);
//    [self.pullSegView showForSelection:^(NSInteger selectedIndex) {
//        wself.rateTypeSelected = [rates objectAtIndex:selectedIndex];
//        [sender setTitle:wself.rateTypeSelected forState:UIControlStateNormal];
//        [sender turningDirection:NO];
//    }];
}

- (IBAction) clickToChooseProvince:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    [sender turningDirection:YES];
    NameWeakSelf(wself);

//    if (self.provincesRequsted) {
//        [self.pullSegView setDataSouces:[self provinceNamesOnRequested]];
//        [self.pullSegView showForSelection:^(NSInteger selectedIndex) {
//            [sender turningDirection:NO];
//            NSString* curProvinceSelected = [wself provinceNameAtIndex:selectedIndex];
//            // 只有选择了不同的省才更新市列表、省标题
//            if (![curProvinceSelected isEqualToString:wself.provinceNameSelected]) {
//                // 更新按钮标题
//                wself.provinceNameSelected = curProvinceSelected;
//                [sender setTitle:curProvinceSelected forState:UIControlStateNormal];
//                // 更新市
//                [wself.cityButton setTitle:@"市" forState:UIControlStateNormal];
//                wself.cityNameSelected = nil;
//                wself.citiesRequested = nil;
//                // 并重新查询市
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [wself requestCitiesOnProvinceCode:[wself provinceCodeOnName:curProvinceSelected]];
//                });
//            }
//        }];
//    } else {
//        [self alertForNullProvinces];
//    }
    
}

- (IBAction) clickToChooseCity:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    if (!self.provinceNameSelected) {
        [PublicInformation makeCentreToast:@"请先选择'省'"];
        return;
    }

    [sender turningDirection:YES];
    NameWeakSelf(wself);
//    if (self.citiesRequested) {
//        [self.pullSegView setDataSouces:[self cityNamesOnRequested]];
//        [self.pullSegView showForSelection:^(NSInteger selectedIndex) {
//            [sender turningDirection:NO];
//            NSString* curCityName = [wself cityNameAtIndex:selectedIndex];
//            if (![curCityName isEqualToString:wself.cityNameSelected]) {
//                wself.cityNameSelected = curCityName;
//                [sender setTitle:curCityName forState:UIControlStateNormal];
//                // 并申请商户数据
//                NSString* rateCode = [ModelBusinessInfoSaved rateValueOnRateType:wself.rateTypeSelected];
//                NSString* cityCode = [wself cityCodeOnName:curCityName];
//                [wself requestBusinessesOnRateCode:rateCode andAreaCode:cityCode onSucBlock:^{
//                    [wself reframePullListViewLayonButton:wself.businessButton];
//                    [wself.businessButton turningDirection:YES];
//                    [wself.pullSegView setDataSouces:[wself businessNamesOnRequested]];
//                    [wself.pullSegView showForSelection:^(NSInteger selectedIndex) {
//                        [wself.businessButton turningDirection:NO];
//                        wself.businessNameSelected = [wself businessNameAtIndex:selectedIndex];
//                        wself.terminalCodeSelected = [wself terminalCodeAtIndex:selectedIndex];
//                        [wself.businessButton setTitle:wself.businessNameSelected forState:UIControlStateNormal];
//                    }];
//                } onErrBlock:^{
//                    
//                }];
//
//            }
//        }];
//    } else {
//        [self alertForNullCities];
//    }
}

- (IBAction) clickToChooseBusiness:(ChooseButton*)sender {
    [self reframePullListViewLayonButton:sender];
    
    if (!self.rateTypeSelected) {
        [PublicInformation makeCentreToast:@"请先选择'费率'"];
        return;
    }
    if (!self.provinceNameSelected) {
        [PublicInformation makeCentreToast:@"请先选择'省'"];
        return;
    }
    if (!self.cityNameSelected) {
        [PublicInformation makeCentreToast:@"请先选择'市'"];
        return;
    }
    
    NameWeakSelf(wself);
//    if (self.businessesRequested) {
//        [sender turningDirection:YES];
//        [self.pullSegView setDataSouces:[self businessNamesOnRequested]];
//        [self.pullSegView showForSelection:^(NSInteger selectedIndex) {
//            [sender turningDirection:NO];
//            wself.businessNameSelected = [wself businessNameAtIndex:selectedIndex];
//            wself.terminalCodeSelected = [wself terminalCodeAtIndex:selectedIndex];
//            [sender setTitle:wself.businessNameSelected forState:UIControlStateNormal];
//        }];
//    } else {
//        [self alertForNullBusinesses];
//    }

}

- (IBAction) clickToSaveBusinessInfo:(UIButton*)sender {
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
    if (!self.businessNameSelected) {
        [PublicInformation makeCentreToast:@"未选择商户,请先选择'商户'"];
        return;
    }
    
    if ([ModelBusinessInfoSaved beenSaved]) {
        [ModelBusinessInfoSaved clearSaved];
    }
    [ModelBusinessInfoSaved savingBusinessInfoWithRateType:self.rateTypeSelected
                                              provinceName:self.provinceNameSelected
                                              provinceCode:[self provinceCodeOnName:self.provinceNameSelected]
                                                  cityName:self.cityNameSelected
                                                  cityCode:[self cityCodeOnName:self.cityNameSelected]
                                              businessName:self.businessNameSelected
                                              businessCode:[self businessCodeOnName:self.businessNameSelected]
                                              terminalCode:self.terminalCodeSelected];
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
// -- 提示: 无商户,是否重新查询商户
- (void) alertForNullBusinesses {
    [PublicInformation alertCancle:@"取消"
                             other:@"重新查询"
                             title:@"查无商户数据"
                           message:@"是否重新查询可用的商户信息?"
                               tag:iTagAlertForBusiness
                          delegate:self];
}

// -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        if (alertView.tag == iTagAlertForProvince) {
//            [self requestProvinces];
//        }
//        else if (alertView.tag == iTagAlertForCity) {
//            NSString* provinceNameSelected = [self.provinceButton titleForState:UIControlStateNormal];
//            [self requestCitiesOnProvinceCode:[self provinceCodeOnName:provinceNameSelected]];
//        }
//        else if (alertView.tag == iTagAlertForBusiness) {
//            NameWeakSelf(wself);
//            NSString* rateCode = [ModelBusinessInfoSaved rateValueOnRateType:self.rateTypeSelected];
//            NSString* cityCode = [self cityCodeOnName:self.cityNameSelected];
//            [self requestBusinessesOnRateCode:rateCode andAreaCode:cityCode onSucBlock:^{
//                [wself.businessButton turningDirection:YES];
//                [wself.pullSegView setDataSouces:[wself businessNamesOnRequested]];
//                [wself.pullSegView showForSelection:^(NSInteger selectedIndex) {
//                    [wself.businessButton turningDirection:NO];
//                    wself.businessNameSelected = [wself businessNameAtIndex:selectedIndex];
//                    wself.terminalCodeSelected = [wself terminalCodeAtIndex:selectedIndex];
//                    [wself.businessButton setTitle:wself.businessNameSelected forState:UIControlStateNormal];
//                }];
//            } onErrBlock:^{
//                
//            }];
//        }
//    }
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

#pragma mask 3 model

// -- 省名数组
- (NSArray*) provinceNamesOnRequested {
    NSMutableArray* provinceNames = [NSMutableArray array];
    for (NSDictionary* province in self.provincesRequsted) {
        [provinceNames addObject:[province objectForKey:kSQLAreaName]];
    }
    return provinceNames;
}
- (NSString*) provinceNameAtIndex:(NSInteger)index {
    NSString* provinceName = [[self.provincesRequsted objectAtIndex:index] objectForKey:kSQLAreaName];
    return [PublicInformation clearSpaceCharAtLastOfString:provinceName];
}
- (NSString*) provinceCodeOnName:(NSString*)provinceName {
    NSString* provinceCode = nil;
    for (NSDictionary* province in self.provincesRequsted) {
        if ([[province objectForKey:kSQLAreaName] hasPrefix:provinceName]) {
            provinceCode = [province objectForKey:kSQLAreaCode];
            break;
        }
    }
    return provinceCode;
}
// -- 市名数组
- (NSArray*) cityNamesOnRequested {
    NSMutableArray* cityNames = [NSMutableArray array];
    for (NSDictionary* city in self.citiesRequested) {
        [cityNames addObject:[city objectForKey:kSQLAreaName]];
    }
    return cityNames;
}
- (NSString*) cityNameAtIndex:(NSInteger)index {
    NSString* cityName = [[self.citiesRequested objectAtIndex:index] objectForKey:kSQLAreaName];
    return [PublicInformation clearSpaceCharAtLastOfString:cityName];
}
- (NSString*) cityCodeOnName:(NSString*)cityName {
    NSString* cityCode = nil;
    for (NSDictionary* city in self.citiesRequested) {
        if ([[city objectForKey:kSQLAreaName] hasPrefix:cityName]) {
            cityCode = [city objectForKey:kSQLAreaCode];
            break;
        }
    }
    return cityCode;
}

// 商户
- (NSArray*) businessNamesOnRequested {
    NSMutableArray* businessNames = [NSMutableArray array];
    for (NSDictionary* businessNode in self.businessesRequested) {
        [businessNames addObject:[businessNode objectForKey:kFeeBusinessBusinessName]];
    }
    return businessNames;
}
- (NSString*) businessNameAtIndex:(NSInteger)index {
    return [[self.businessesRequested objectAtIndex:index] objectForKey:kFeeBusinessBusinessName];
}
- (NSString*) businessCodeOnName:(NSString*)businessName {
    NSString* businessCode = nil;
    for (NSDictionary* business in self.businessesRequested) {
        if ([[business objectForKey:kFeeBusinessBusinessName] isEqualToString:businessName]) {
            businessCode = [business objectForKey:kFeeBusinessBusinessNum];
            break;
        }
    }
    return businessCode;
}
- (NSString*) terminalCodeAtIndex:(NSInteger)index {
    return [[self.businessesRequested objectAtIndex:index] objectForKey:kFeeBusinessTerminalNum];
}
- (NSString*) terminalCodeOnBusinessName:(NSString*)businessName {
    NSString* terminalCode = nil;
    for (NSDictionary* business in self.businessesRequested) {
        if ([[business objectForKey:kFeeBusinessBusinessName] isEqualToString:businessName]) {
            terminalCode = [business objectForKey:kFeeBusinessTerminalNum];
            break;
        }
    }
    return terminalCode;
}


#pragma mask 3 private interface
// -- 查询省信息
- (void) requestProvinces
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress show];
    });
    NameWeakSelf(wself);
    [SQLRequestAreas requestAreasOnCode:@"156" onSucBlock:^(NSArray *areas)  {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });
        wself.provincesRequsted = [areas copy];
    } onErrBlock:^(NSError *error) {
        
    }];
}
// -- 查询市信息
- (void) requestCitiesOnProvinceCode:(NSString*)provinceCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress show];
    });
    NameWeakSelf(wself);
    [SQLRequestAreas requestAreasOnCode:provinceCode onSucBlock:^(NSArray *areas)  {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });
        wself.citiesRequested = [areas copy];
    } onErrBlock:^(NSError *error) {
    }];
}
// -- 查询商户信息
- (void) requestBusinessesOnRateCode:(NSString*)rateCode andAreaCode:(NSString*)areaCode
                          onSucBlock:(void (^) (void))sucBlock
                          onErrBlock:(void (^) (void))errBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress show];
    });
    NameWeakSelf(wself);
    [self.businessHttp requestFeeBusinessOnFeeType:rateCode areaCode:areaCode onSucBlock:^(NSArray *businessInfos) {
        
        if (businessInfos && businessInfos.count > 0) {
            wself.businessesRequested = [businessInfos copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
            });
            sucBlock();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showErrorWithStatus:@"查无商户数据\n请重新选择'费率'或'地区'!" duration:2];
            });
            wself.businessNameSelected = nil;
            errBlock();
        }
    } onErrBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showErrorWithStatus:@"查询商户列表信息失败,请重试!" duration:2];
        });
        wself.businessesRequested = nil;
        errBlock();
    }];
}


#pragma mask 4 getter
// 下拉显示列表
- (PullListSegView *)pullSegView {
    if (!_pullSegView) {
//        _pullSegView = [[PullListSegView alloc] initWithDataSource:[ModelBusinessInfoSaved allRateTypes]];
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


@end
