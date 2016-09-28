//
//  DC_mposView.h
//  JLPay
//
//  Created by jielian on 16/9/6.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


/* 状态值定义 */
typedef NS_ENUM(NSInteger, DC_VIEW_STATE) {
    DC_VIEW_STATE_WAITTING,
    DC_VIEW_STATE_DONE,
    DC_VIEW_STATE_WRONG
};




@interface DC_mposView : UIView

/* 重新扫描 */
@property (nonatomic, strong) UIButton* reScanBtn;

/* 绑定设备 */
@property (nonatomic, strong) UIButton* bindBtn;

/* 设备列表视图 */
@property (nonatomic, strong) UITableView* devicesTBV;

/* 状态文本标签 */
@property (nonatomic, strong) UILabel* stateTextLab;

/* 状态icon标签 */
@property (nonatomic, strong) UILabel* stateIconLab;

/* 状态值: 控制icon */
@property (nonatomic, assign) DC_VIEW_STATE state;

@end
