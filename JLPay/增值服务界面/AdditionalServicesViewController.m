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

#define InsetOfSubViews             6.f                 // 第一个子视图(滚动视图)跟后续子视图组的间隔


@interface AdditionalServicesViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    CGFloat insetHorizantol;
}
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

    myCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        return nil;
    }
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
    UICollectionReusableView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                    withReuseIdentifier:headerIdentifier
                                                           forIndexPath:indexPath];
    CGFloat headerHeight = self.view.bounds.size.width * 305.0/712.0;
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, headerHeight)];
    imageView.image = [UIImage imageNamed:@"01_03"];
    [headerView addSubview:imageView];
    return headerView;
}

#pragma mask ------ UICollectionViewDelegateFlowLayout
/* 单个item的尺寸 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (collectionView.frame.size.width - insetHorizantol*2)/ 3.0000;
    return CGSizeMake(width, width);
}
/* 每个section的四维边界 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0, insetHorizantol, 0.0, insetHorizantol);
}
/* item内部视图的边界值 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}
/* section内行间距 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mask ------ UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    myCollectionCell* cell = (myCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell.title isEqualToString:PayCollectTypeAlipay]) {
        OtherPayCollectViewController* payCollectionVC = [self payCollectionViewControllerWithType:PayCollectTypeAlipay];
        [self.navigationController pushViewController:payCollectionVC animated:YES];
    }
    else if ([cell.title isEqualToString:PayCollectTypeWeChatPay]) {
        OtherPayCollectViewController* payCollectionVC = [self payCollectionViewControllerWithType:PayCollectTypeWeChatPay];
        [self.navigationController pushViewController:payCollectionVC animated:YES];
    }
    else {
        [self.view makeToast:@"功能正在建设中,请关注版本更新..."];
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


#pragma mask ----
- (void)viewDidLoad {
    [super viewDidLoad];
    // 标题颜色设置为红色
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    
    // 设置 title 的字体颜色
    UIColor *color                  = [UIColor redColor];
    NSDictionary *dict              = [NSDictionary dictionaryWithObject:color  forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationController.navigationBar.tintColor = color;

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.collectionView];
    insetHorizantol = 1.000000;
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
        CGFloat headerHeight = self.view.bounds.size.width * 305.0/712.0;
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, headerHeight + 8);//insetHorizantol*5);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        [_collectionView registerClass:[myCollectionCell class] forCellWithReuseIdentifier:cellIdentifier];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
    }
    return _collectionView;
}
- (NSMutableArray *)titlesArray {
    if (_titlesArray == nil) {
        _titlesArray = [[NSMutableArray alloc] init];
        [_titlesArray addObject:PayCollectTypeAlipay];
        [_titlesArray addObject:PayCollectTypeWeChatPay];
        [_titlesArray addObject:@"余额查询"];
    }
    return _titlesArray;
}
- (NSMutableDictionary *)imageNamesDict {
    if (_imageNamesDict == nil) {
        _imageNamesDict = [[NSMutableDictionary alloc] init];
        [_imageNamesDict setValue:@"03_20" forKey:(NSString*)PayCollectTypeAlipay];
        [_imageNamesDict setValue:@"wxPay" forKey:(NSString*)PayCollectTypeWeChatPay];
        [_imageNamesDict setValue:@"03_12" forKey:@"余额查询"];
    }
    return _imageNamesDict;
}

@end
