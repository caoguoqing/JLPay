//
//  ViewModelQRImageMaker.h
//  JLPay
//
//  Created by jielian on 15/11/3.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ViewModelQRImageMaker : NSObject

+ (UIImage*) imageForQRCode:(NSString*)QRCode;

@end
