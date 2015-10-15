//
//  TextFieldCell.h
//  JLPay
//
//  Created by jielian on 15/10/12.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextLabelCell;
@protocol TextFieldCellDelegate <NSObject>
@required
// 完成文本的输入
- (void) tableViewCell:(id)cell didInputedText:(NSString*)text;
@end






@interface TextFieldCell : UITableViewCell
// 数据源协议
@property (nonatomic, retain) id<TextFieldCellDelegate>delegate;

// 标题
@property (nonatomic, assign) NSString* title;
// 提示文本
@property (nonatomic, assign) NSString* placeHolder;
// 密码标志
@property (nonatomic, assign) BOOL secureTextEntry;
// 必输标识
@property (nonatomic, assign) BOOL mustInput;

// 文本
- (NSString*)text;

@end
