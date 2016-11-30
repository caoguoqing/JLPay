//
//  PosInformationViewController.h
//  PosN38Universal
//
//  Created by work on 14-9-15.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define_Header.h"




@class AppDelegate;

@interface PosInformationViewController : UIViewController


# pragma mask : public
@property (nonatomic, copy) NSDictionary* transInformation;                 /* 交易信息 */

@property (nonatomic, copy) UIImage* elecSignImage;                         /* 签名图片 */



# pragma mask : private
@property (nonatomic, strong) UIScrollView* posScrollView;                  /* 小票视图(滚动视图) */


@property (nonatomic, strong) UIBarButtonItem* doneBarBtn;

@end
