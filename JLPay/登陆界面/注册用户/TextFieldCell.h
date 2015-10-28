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

#define HEIGHT_FIELD_CELL   50

@interface TextFieldCell : UITableViewCell
// 数据源协议
@property (nonatomic, retain) id<TextFieldCellDelegate>delegate;

// 标题
@property (nonatomic, assign) NSString* title;
// 提示文本
@property (nonatomic, assign) NSString* placeHolder;
// 输入的文本
@property (nonatomic, assign) NSString* textInputed;
// 密码标志
@property (nonatomic, assign) BOOL secureTextEntry;
// 必输标识
@property (nonatomic, assign) BOOL mustInput;
// 长度限制
@property (nonatomic, assign) NSInteger lengthLimit;

// 文本
- (NSString*)text;
// 激活输入
- (void) startInput;

@end
