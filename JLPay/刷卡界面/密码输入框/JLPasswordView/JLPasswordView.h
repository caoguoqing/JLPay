//
//  JLPasswordView.h
//  TestForJLPasswordView
//
//  Created by jielian on 16/8/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLPasswordView : UIView


+ (void) showWithDoneClicked:(void (^) (NSString* password))doneBlock
             orCancelClicked:(void (^) (void))cancelBlock;

+ (void)hidden;

    
    
@end
