//
//  ImageViewCell.h
//  JLPay
//
//  Created by 冯金龙 on 15/10/15.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEIGHT_IMAGEVIEW_CELL   200


@interface ImageViewCell : UITableViewCell

// 标题
@property (nonatomic, assign) NSString* title;
// 图片
@property (nonatomic, strong) UIImage* imageDisplay;



@end
