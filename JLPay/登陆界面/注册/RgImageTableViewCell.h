//
//  ImageTableViewCell.h
//  TestForRegister
//
//  Created by jielian on 15/8/20.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RgImageTableViewCellDelegate ;


@interface RgImageTableViewCell : UITableViewCell
@property (nonatomic, assign) id<RgImageTableViewCellDelegate>delegate;

// 设置标题
- (void) setLabelTitle:(NSString*)text;
- (NSString*)labelTitle;

// 设置背景图
- (void) setBackgroundImage:(UIImage*)image ;
@end

@protocol RgImageTableViewCellDelegate <NSObject>
// 协议:delegate 去相册获取图片
- (void) imageCell:(RgImageTableViewCell*)imageCell loadingImageAtCellTitle:(NSString*)textTitle;
@end