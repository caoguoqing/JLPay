//
//  TextLabelCell.h
//  JLPay
//
//  Created by jielian on 15/10/13.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


#define HEIGHT_LABEL_CELL   50



@interface TextLabelCell : UITableViewCell

// 标题
@property (nonatomic, strong) NSString* title;
// 提示文本
@property (nonatomic, strong) NSString* placeHolder;
// 必输标识
@property (nonatomic, assign) BOOL mustInput;


@end
