//
//  AdditionalServicesViewController.m
//  JLPay
//
//  Created by jielian on 15/5/18.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//


/* ### 增值服务界面 ### */

#import "AdditionalServicesViewController.h"
#import "PublicInformation.h"
#import "myCollectionCell.h"
#import "Toast+UIView.h"
#import "OtherPayCollectViewController.h"
#import "DeviceManager.h"
#import "TransDetailsViewController.h"
#import "DynamicScrollView.h"

#import "AdditionalCollectionLayout.h"

#define InsetOfSubViews             6.f                 // 第一个子视图(滚动视图)跟后续子视图组的间隔


@interface AdditionalServicesViewController ()
<
    UICollectionViewDataSource,
    UICollectionViewDelegate
>
@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, strong) NSMutableDictionary* imageNamesDict;
@property (nonatomic, strong) NSMutableArray* titlesArray;
@end


NSString* cellIdentifier = @"cellIdentifier";
NSString* headerIdentifier = @"headerIdentifier";

@implementation AdditionalServicesViewController
@synthesize collectionView = _collectionView;
@synthesize imageNamesDict = _imageNamesDict;
@synthesize titlesArray = _titlesArray;



#pragma mask ------ UICollectionViewDataSource
/* section 个数 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
/* item个数: 每个section中 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titlesArray.count;
}
/* 每个item的数据源设置 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    myCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:(NSString*)CellItemIdentifier forIndexPath:indexPath];
    
    NSString* key = [self.titlesArray objectAtIndex:indexPath.row];
    [cell setImage:[UIImage imageNamed:[self.imageNamesDict valueForKey:key]]];
    if (![key isEqualToString:@"添加"]) {
        [cell setTitle:key];
    } else {
        [cell setTitle:nil];
    }
    return cell;
}
/* 头视图设置 */
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView* headerOrFooterView = nil;
    NSLog(@"========[%s],kind = [%@]",__func__, kind);
    if ([kind isEqualToString:SupplementaryIdentifier]) {
        headerOrFooterView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SupplementaryIdentifier forIndexPath:indexPath];
        UIImageView* supplementaryImageView = [[UIImageView alloc] init];
        supplementaryImageView.image = [UIImage imageNamed:@"01_03"];
        supplementaryImageView.bounds = headerOrFooterView.bounds;
        supplementaryImageView.center = CGPointMake(headerOrFooterView.bounds.size.width/2.0, headerOrFooterView.bounds.size.height/2.0);
        [headerOrFooterView addSubview:supplementaryImageView];

    }
    else if ([kind isEqualToString:SupplementaryIdentifierStay]) {
        headerOrFooterView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SupplementaryIdentifierStay forIndexPath:indexPath];
        headerOrFooterView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    }
    
    return headerOrFooterView;
}


#pragma mask ------ UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
/* cell 的点击事件 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    myCollectionCell* cell = (myCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell.title isEqualToString:PayCollectTypeAlipay]) {
        // 校验设备绑定
        if (![DeviceManager deviceIsBinded]) {
            [self alertForMessage:@"设备未绑定，请先绑定设备"];
        } else {
            [self.navigationController pushViewController:[self payCollectionViewControllerWithType:PayCollectTypeAlipay] animated:YES];
        }
    }
    else if ([cell.title isEqualToString:PayCollectTypeWeChatPay]) {
        // 校验设备绑定
        if (![DeviceManager deviceIsBinded]) {
            [self alertForMessage:@"设备未绑定，请先绑定设备"];
        } else {
            [self.navigationController pushViewController:[self payCollectionViewControllerWithType:PayCollectTypeWeChatPay] animated:YES];
        }
    }
    else if ([cell.title isEqualToString:@"明细查询"]){
        // 校验设备绑定
        if (![DeviceManager deviceIsBinded]) {
            [self alertForMessage:@"设备未绑定，请先绑定设备"];
        } else {
            [self.navigationController pushViewController:[self transDetailsViewControllerWithPlatform:NameTradePlatformOtherPay] animated:YES];
        }

    }
}

#pragma mask ---- PRIVATE INTERFACE
/* 获取第三方收款的界面 */
- (OtherPayCollectViewController*) payCollectionViewControllerWithType:(NSString*)type {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OtherPayCollectViewController* payCollectVC = [storyBoard instantiateViewControllerWithIdentifier:@"otherPayVC"];
    [payCollectVC setPayCollectType:type];
    return payCollectVC;
}

/* 交易明细界面 */
- (TransDetailsViewController*) transDetailsViewControllerWithPlatform:(NSString*)platform {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TransDetailsViewController* payCollectVC = [storyBoard instantiateViewControllerWithIdentifier:@"transDetailsVC"];
    [payCollectVC setTradePlatform:platform];
    return payCollectVC;
}

/* 弹窗 */
- (void) alertForMessage:(NSString*)message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}


#pragma mask ---- 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置 title 的字体颜色
    UIColor *color                  = [UIColor redColor];
    NSDictionary *dict              = [NSDictionary dictionaryWithObject:color  forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationController.navigationBar.tintColor = color;

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.collectionView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat naviAndStatusHeight = [PublicInformation heightOfNavigationAndStatusInVC:self];
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    self.collectionView.frame = CGRectMake(0, naviAndStatusHeight, self.view.bounds.size.width, self.view.bounds.size.height - naviAndStatusHeight - tabBarHeight);
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    UIBarButtonItem* backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToLastViewController)];
    [self.navigationItem setBackBarButtonItem:backBarButton];

}
- (void) backToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mask ::: getter & setter 
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        AdditionalCollectionLayout* flowLayout = [[AdditionalCollectionLayout alloc] init];
        
        CGFloat heightNaviAndStatus = [PublicInformation heightOfNavigationAndStatusInVC:self];
        CGFloat heightTabBar = self.tabBarController.tabBar.frame.size.height;
        CGRect frame = CGRectMake(0, heightNaviAndStatus, self.view.frame.size.width, self.view.frame.size.height - heightNaviAndStatus - heightTabBar);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        
        [_collectionView registerClass:[myCollectionCell class] forCellWithReuseIdentifier:(NSString*)CellItemIdentifier];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SupplementaryIdentifier];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SupplementaryIdentifierStay];
        
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
    }
    return _collectionView;
}
- (NSMutableArray *)titlesArray {
    if (_titlesArray == nil) {
        _titlesArray = [[NSMutableArray alloc] init];
        [_titlesArray addObject:PayCollectTypeAlipay];
        [_titlesArray addObject:PayCollectTypeWeChatPay];
        [_titlesArray addObject:@"明细查询"];
    }
    return _titlesArray;
}
- (NSMutableDictionary *)imageNamesDict {
    if (_imageNamesDict == nil) {
        _imageNamesDict = [[NSMutableDictionary alloc] init];
        [_imageNamesDict setValue:@"03_20" forKey:(NSString*)PayCollectTypeAlipay];
        [_imageNamesDict setValue:@"wxPay" forKey:(NSString*)PayCollectTypeWeChatPay];
        [_imageNamesDict setValue:@"03_12" forKey:@"明细查询"];
    }
    return _imageNamesDict;
}

@end
