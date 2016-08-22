//
//  BitmapMaker.h
//  JLPay
//
//  Created by jielian on 16/7/22.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface BitmapMaker : NSObject

@property (nonatomic, assign) NSInteger bmpWidth;

@property (nonatomic, assign) NSInteger bmpHeight;

@property (nonatomic, assign) NSInteger bmpTotalSize;

- (unsigned char* ) bmpFromView:(UIView*)view;
- (UIImage*) imageForView:(UIView*)view ;

@end
