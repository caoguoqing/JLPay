//
//  UIAlertController+JLShow.h
//  JLPay
//
//  Created by jielian on 16/7/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (JLShow)

/* 点击事件 */
typedef void (^ clickedIndex) (UIAlertAction* action);


/*
 UIActionSheet
 @param buttons: such as {UIAlertActionStyleDefault:@"取消"}
 */
+ (void) showActSheetWithTitle:(NSString*)title
                       message:(NSString*)message
                        target:(id)target
                 clickedHandle:(clickedIndex)clickedHandle
                       buttons:(NSDictionary*)buttons,...;



@end
