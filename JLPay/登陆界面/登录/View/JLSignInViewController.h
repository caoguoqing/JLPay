//
//  JLSignInViewController.h
//  CustomViewMaker
//
//  Created by 冯金龙 on 16/5/31.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface JLSignInViewController : UIViewController


- (instancetype) initWithLoginFinished:(void (^) (void))finishedBlock onCanceled:(void (^) (void))cancelBlock;



@end
