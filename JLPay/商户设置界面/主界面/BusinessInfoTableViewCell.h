//
//  BusinessInfoTableViewCell.h
//  JLPay
//
//  Created by jielian on 15/11/19.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessInfoTableViewCell : UITableViewCell

/* 设置头像图片 */
- (void) setHeadImage:(UIImage*)headImage;

/* 设置登陆用户名 */
- (void) setUserId:(NSString*)userId;

/* 设置商户名 */
- (void) setBusinessName:(NSString*)businessName;

/* 设置商户编号 */
- (void) setBusinessNo:(NSString *)businessNo;

@end
