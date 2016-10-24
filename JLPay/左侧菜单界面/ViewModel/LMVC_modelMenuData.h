//
//  LMVC_modelMenuData.h
//  CustomViewMaker
//
//  Created by jielian on 16/10/10.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MCacheSavedLogin.h"


@interface LMVC_modelMenuData : NSObject
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString* userName;

@property (nonatomic, copy) NSString* businessCode;

@property (nonatomic, assign) BOOL logined;

@property (nonatomic, assign) MCacheSignUpCheckState checkedState;


/* 刷新数据源: 界面也要同时刷新 */
- (void) reloadData;

/* 关闭菜单界面, 并跳转登录 */
- (void) gotoRelogin;

/* 跳转我的商户 */
- (void) gotoMyBusiness;


@end
