//
//  HttpUploadT0Card.h
//  JLPay
//
//  Created by jielian on 15/12/30.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HttpUploadT0Card;
@protocol HttpUploadT0CardDelegate <NSObject>

- (void) didUploadedSuccess;
- (void) didUploadedFail:(NSString*)failMessage;

@end


@interface HttpUploadT0Card : NSObject

+ (instancetype) sharedInstance;

- (void) uploadCardNo:(NSString*)cardNo
       cardHolderName:(NSString*)cardHolderName
            cardPhoto:(UIImage*)cardImage
           onDelegate:(id<HttpUploadT0CardDelegate>)delegate;

- (void) terminateUpload;

@end
