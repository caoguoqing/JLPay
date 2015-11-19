//
//  NormalTableViewCell.h
//  JLPay
//
//  Created by jielian on 15/11/19.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NormalTableViewCell : UITableViewCell

/* 设置cell 的图片 */
- (void) setCellImage:(UIImage*)cellImage;

/* 设置cell 的标题 */
- (void) setCellName:(NSString*)cellName;

@end
