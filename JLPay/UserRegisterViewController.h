//
//  UserRegisterViewController.h
//  JLPay
//
//  Created by jielian on 15/8/6.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserRegisterViewController : UIViewController

@property (nonatomic, strong) UILabel* areaLabel;                   // 显示地名的标签
/*
 * 注册类型
 *  0: 新增注册(默认)
 *  1: 修改审核(未审核通过的)
 *  2: 修改信息(已审核通过的)
 */
@property (nonatomic, assign) int packageType;
// 默认数据字典: 当注册类型为1时带回
//@property (nonatomic, retain) NSDictionary* defaultInfo;
@end
