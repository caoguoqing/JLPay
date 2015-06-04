//
//  PosInformationViewController.h
//  PosN38Universal
//
//  Created by work on 14-9-15.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface PosInformationViewController : UIViewController{
    AppDelegate *appdelegate;
}

@property(nonatomic,retain)UIImage *posImg;

@property(nonatomic,retain)UIImage *scrollAllImg;

@property(nonatomic,retain)NSString* infoLiushuiStr;
@property(nonatomic,retain)NSString *timeStr;
@property(nonatomic,retain)NSString *lastLiushuiStr;


-(void)liushuiNum:(NSString *)num time:(NSString *)ti lastliushuinum:(NSString *)num2;

@end
