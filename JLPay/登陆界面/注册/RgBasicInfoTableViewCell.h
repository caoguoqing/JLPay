//
//  RgBasicInfoTableViewCell.h
//  TestForRegister
//
//  Created by jielian on 15/8/17.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol RgBasicInfoTableViewCellDelegate <NSObject>
// 文本框输入完要将输入的数据带回
- (void) textBeInputedInCellTitle:(NSString*)textTitle inputedText:(NSString*)text;


@end



@interface RgBasicInfoTableViewCell : UITableViewCell
@property (nonatomic, assign) BOOL mustBeInputed;
@property (nonatomic, weak) id<RgBasicInfoTableViewCellDelegate> cellDelegate;

// 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
           andNeededInputFlag:(BOOL)flag;

// 获取输入的值
- (NSString*) textInputed ;

// 设置标题
- (void) setTitleText:(NSString*)text;
// 设置文本输入框提示信息
- (void) setTextPlaceholder:(NSString*)placeholder;
// 设置密码模式
- (void) setSecureEntry:(BOOL)yesOrNo;
// 设置文本框的值
- (void) setText:(NSString*)text;


// 判断是否正在输入
- (BOOL) isTextEditing;
// 取消输入动作
- (void) endingTextEditing;
@end
