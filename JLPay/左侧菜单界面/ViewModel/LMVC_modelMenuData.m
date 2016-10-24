//
//  LMVC_modelMenuData.m
//  CustomViewMaker
//
//  Created by jielian on 16/10/10.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "LMVC_modelMenuData.h"
#import <NSString+FontAwesome.h>
#import <UIFont+FontAwesome.h>
#import "NSString+Formater.h"
#import "LMVC_menuCell.h"
#import <RESideMenu.h>
#import "LeftMenuViewController.h"
#import "MainTransViewController.h"
#import "MViewSwitchManager.h"


static NSString* const kLMVC_MenuTitleDeviceBinding     = @"绑定设备";
static NSString* const kLMVC_MenuTitleBusinessSwitch    = @"商户切换";
static NSString* const kLMVC_MenuTitleMyCardCheck       = @"我的卡包";
static NSString* const kLMVC_MenuTitlePinExchange       = @"修改密码";
static NSString* const kLMVC_MenuTitleAssistance        = @"帮助与关于";




@interface LMVC_modelMenuData()

@property (nonatomic, strong) NSMutableArray* iconTypeList;

@property (nonatomic, strong) NSMutableArray* titleList;

@end



@implementation LMVC_modelMenuData


/* 跳转: 登录 */
- (void)gotoRelogin {
    RESideMenu* sideMenu = (RESideMenu*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    LeftMenuViewController* leftMenu = (LeftMenuViewController*)[sideMenu leftMenuViewController];
    MainTransViewController* mainVC = (MainTransViewController*)[[(UINavigationController*)[sideMenu contentViewController] viewControllers] firstObject];
    
    /* 先清空缓存 */
    [MCacheSavedLogin cache].userName = nil;
    /* 重新刷新界面数据 */
    [mainVC reloadDatas];
    [leftMenu reloadDatas];
    /* 退出菜单界面 */
    [sideMenu hideMenuViewController];
    /* 执行跳转 */
    [[MViewSwitchManager manager] gotoLogin];
}

/* 跳转: 绑定设备 */
- (void) gotoDeviceConnect {
    [self hideSideMenuViewController];
    [[MViewSwitchManager manager] gotoDeviceBinding];
}

/* 跳转: 商户切换 */
- (void) gotoMoreBusinessOrRate {
    [self hideSideMenuViewController];
    [[MViewSwitchManager manager] gotoBusinessSwitch];
}

/* 跳转: 我的卡包 */
- (void) gotoMyCreditCardChecking {
    [self hideSideMenuViewController];
    [[MViewSwitchManager manager] gotoMyCreditcardChecking];
}

/* 跳转: 修改密码 */
- (void) gotoExchangePassword {
    [self hideSideMenuViewController];
    [[MViewSwitchManager manager] gotoPasswordExchanging];
}

/* 跳转: 帮助与关于 */
- (void) gotoAssistance {
    [self hideSideMenuViewController];
    [[MViewSwitchManager manager] gotoAssistance];
}

/* 跳转我的商户 */
- (void) gotoMyBusiness {
    [self hideSideMenuViewController];
    [[MViewSwitchManager manager] gotoMyBusiness];
}



/* 退出菜单界面 */
- (void) hideSideMenuViewController {
    [(RESideMenu*)[MViewSwitchManager mainViewController] hideMenuViewController];
}




/* 刷新数据 */
- (void)reloadData {
    [self.iconTypeList removeAllObjects];
    [self.titleList removeAllObjects];
    
    MCacheSavedLogin* loginCache = [MCacheSavedLogin cache];
    self.logined = loginCache.logined;
    self.userName = self.logined ? loginCache.userName : @"(未登录)";
    self.businessCode = (self.logined && loginCache.checkedState != MCacheSignUpCheckStateCheckRefused) ? loginCache.businessCode : nil;
    self.checkedState = loginCache.checkedState;
    
    // 绑定设备
    [self.iconTypeList addObject:@(FALink)];
    [self.titleList addObject:kLMVC_MenuTitleDeviceBinding];
    
    // 登录成功
    if (self.logined) {
        // 多商户
        if (loginCache.N_business_enable || loginCache.N_fee_enable) {
            [self.iconTypeList addObject:@(FAUsers)];
            [self.titleList addObject:kLMVC_MenuTitleBusinessSwitch];
        }
        //  卡验证
        if (loginCache.T_0_enable) {
            [self.iconTypeList addObject:@(FACreditCard)];
            [self.titleList addObject:kLMVC_MenuTitleMyCardCheck];
        }
        
    }
    // 登录失败 (都可以显示,但不能跳转)
    else {
        // 多商户
        [self.iconTypeList addObject:@(FAUsers)];
        [self.titleList addObject:kLMVC_MenuTitleBusinessSwitch];
        //  卡验证
        [self.iconTypeList addObject:@(FACreditCard)];
        [self.titleList addObject:kLMVC_MenuTitleMyCardCheck];

    }
    
    // 修改密码
    [self.iconTypeList addObject:@(FAUnlockAlt)];
    [self.titleList addObject:kLMVC_MenuTitlePinExchange];
    
    // 帮助与关于
    [self.iconTypeList addObject:@(FAQuestionCircle)];
    [self.titleList addObject:kLMVC_MenuTitleAssistance];
    
}

# pragma mask UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* title = [self.titleList objectAtIndex:indexPath.row];
    
    if ([[MCacheSavedLogin cache] logined]) {
        /* 绑定设备 */
        if ([title isEqualToString:kLMVC_MenuTitleDeviceBinding]) {
            [self gotoDeviceConnect];
        }
        /* 多商户多费率 */
        else if ([title isEqualToString:kLMVC_MenuTitleBusinessSwitch]) {
            [self gotoMoreBusinessOrRate];
        }
        /* 卡验证 */
        else if ([title isEqualToString:kLMVC_MenuTitleMyCardCheck]) {
            [self gotoMyCreditCardChecking];
        }
        /* 修改密码 */
        else if ([title isEqualToString:kLMVC_MenuTitlePinExchange]) {
            [self gotoExchangePassword];
        }
        /* 帮助与关于 */
        else if ([title isEqualToString:kLMVC_MenuTitleAssistance]) {
            [self gotoAssistance];
        }
    } else {
        if ([title isEqualToString:kLMVC_MenuTitleAssistance]) {
            /* 帮助与关于 */
            [self gotoAssistance];
        }
        else {
            /* 登录 */
            [self gotoRelogin];
        }
    }
    
}


# pragma mask  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.iconTypeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMVC_menuCell* cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    if (!cell) {
        cell = [[LMVC_menuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"menuCell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.iconLabel.text = [NSString fontAwesomeIconStringForEnum:[[self.iconTypeList objectAtIndex:indexPath.row] integerValue]];
    cell.titleLabel.text = [self.titleList objectAtIndex:indexPath.row];
    
    cell.iconLabel.font = [UIFont fontAwesomeFontOfSize:18];
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    
    return cell;
}




- (instancetype)init {
    self = [super init];
    if (self) {
        [self reloadData];
    }
    return self;
}


# pragma mask 4 getter
- (NSMutableArray *)iconTypeList {
    if (!_iconTypeList) {
        _iconTypeList = [NSMutableArray array];
    }
    return _iconTypeList;
}

- (NSMutableArray *)titleList {
    if (!_titleList) {
        _titleList = [NSMutableArray array];
    }
    return _titleList;
}

@end
