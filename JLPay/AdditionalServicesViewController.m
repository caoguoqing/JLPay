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

#define InsetOfSubViews             6.f                 // 第一个子视图(滚动视图)跟后续子视图组的间隔


@interface AdditionalServicesViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
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
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titlesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    myCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        return nil;
    }
    NSString* key = [self.titlesArray objectAtIndex:indexPath.row];
    [cell setImage:[UIImage imageNamed:[self.imageNamesDict valueForKey:key]]];
    if (![key isEqualToString:@"添加"]) {
        [cell setText:key];
    } else {
        [cell setText:nil];
    }
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
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
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.view.bounds.size.width - 0.5*6)/3.0;
    return CGSizeMake(width, width);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.5, 0.5, 0.5, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.5*2;
}

#pragma mask ------ UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1 animations:^{
//        cell.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }];
    NSLog(@"点击了单元格..........[%@]",[self.titlesArray objectAtIndex:indexPath.row]);
    [self.view makeToast:@"功能正在建设中,请关注版本更新..."];
    
}






- (void)viewDidLoad {
    [super viewDidLoad];
    // 标题颜色设置为红色
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
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
    

}



#pragma mask ::: getter & setter 
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        CGFloat headerHeight = self.view.bounds.size.width * 305.0/712.0;
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, headerHeight + 8.0);
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
        [_titlesArray addObject:@"信用卡还款"];
        [_titlesArray addObject:@"余额查询"];
        [_titlesArray addObject:@"转账汇款"];
        [_titlesArray addObject:@"手机充值"];
        [_titlesArray addObject:@"支付宝充值"];
        [_titlesArray addObject:@"财付通充值"];
        [_titlesArray addObject:@"游戏点卡充值"];
        [_titlesArray addObject:@"交通罚款"];
        [_titlesArray addObject:@"添加"];

    }
    return _titlesArray;
}
- (NSMutableDictionary *)imageNamesDict {
    if (_imageNamesDict == nil) {
        _imageNamesDict = [[NSMutableDictionary alloc] init];
        [_imageNamesDict setValue:@"03_07" forKey:@"信用卡还款"];
        [_imageNamesDict setValue:@"03_12" forKey:@"余额查询"];
        [_imageNamesDict setValue:@"03_09" forKey:@"转账汇款"];
        [_imageNamesDict setValue:@"03_18" forKey:@"手机充值"];
        [_imageNamesDict setValue:@"03_20" forKey:@"支付宝充值"];
        [_imageNamesDict setValue:@"03_23" forKey:@"财付通充值"];
        [_imageNamesDict setValue:@"03_28" forKey:@"游戏点卡充值"];
        [_imageNamesDict setValue:@"03_29" forKey:@"交通罚款"];
        [_imageNamesDict setValue:@"jia" forKey:@"添加"];

    }
    return _imageNamesDict;
}

@end
