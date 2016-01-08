//
//  SubAndDetailLabelCell.h
//  JLPay
//
//  Created by jielian on 15/12/29.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//


// -- 颜色
typedef enum {
    EnumSubTextColorGray        = 0x1e1e1e,
    EnumSubTextColorGreen       = 0x35b029,
    EnumSubTextColorRed         = 0xeb454b,
    EnumSubTextColorDarkBlue    = 0x2f353d
} EnumSubTextColor;


#import <UIKit/UIKit.h>

@interface SubAndDetailLabelCell : UITableViewCell

- (void) setLeftText:(NSString*)text;
- (void) setRightText:(NSString*)text;
- (void) setSubText:(NSString*)text;

- (void) setSubText:(NSString*)text color:(EnumSubTextColor)enumColor;


@end
