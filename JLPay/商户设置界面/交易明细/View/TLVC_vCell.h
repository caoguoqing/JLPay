//
//  TLVC_vCell.h
//  CPPay
//
//  Created by jielian on 2016/12/26.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLVC_vCell : UITableViewCell

# pragma mask : public properties

/* 标题 */
@property (nonatomic, strong) UILabel* titleLabel;
/* sub标题 */
@property (nonatomic, strong) UILabel* subTitleLabel;
/* 内容 */
@property (nonatomic, strong) UILabel* contextLabel;
/* sub内容 */
@property (nonatomic, strong) UILabel* subContextLabel;
/* 状态 */
@property (nonatomic, strong) UILabel* stateLabel;


# pragma mask : private properties

/* 承载视图 */
@property (nonatomic, strong) UIView* bearView;
/* 更多 */
@property (nonatomic, strong) UILabel* moreLabel;


@end
