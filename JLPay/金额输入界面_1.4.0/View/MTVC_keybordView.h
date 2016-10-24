//
//  MTVC_keybordView.h
//  CustomViewMaker
//
//  Created by jielian on 16/9/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


/* 数字按钮的索引号 */
typedef enum {
    MTVC_keybordNum1 = 1,
    MTVC_keybordNum2,
    MTVC_keybordNum3,
    MTVC_keybordNum4,
    MTVC_keybordNum5,
    MTVC_keybordNum6,
    MTVC_keybordNum7,
    MTVC_keybordNum8,
    MTVC_keybordNum9,
    MTVC_keybordNumClear,
    MTVC_keybordNum0,
    MTVC_keybordNumDel
} MTVC_keybordNum;



@interface MTVC_keybordView : UIView


- (instancetype) initWithClickedBlock: (void (^) (NSInteger number)) clickedBlock ;


/* 数字按钮背景色 */
@property (nonatomic, copy) UIColor* numBtnBackColor;

/* 数字按钮标题色 */
@property (nonatomic, copy) UIColor* numBtnTextColor;

/* 数字按钮间隔 */
@property (nonatomic, assign) CGFloat inset;

@end
