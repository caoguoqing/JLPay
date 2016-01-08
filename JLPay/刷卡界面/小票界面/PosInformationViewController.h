//
//  PosInformationViewController.h
//  PosN38Universal
//
//  Created by work on 14-9-15.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface PosInformationViewController : UIViewController

@property(nonatomic,retain)UIImage *posImg;

@property(nonatomic,retain)UIImage *scrollAllImg;

@property (nonatomic, strong) NSDictionary* transInformation;


@end
