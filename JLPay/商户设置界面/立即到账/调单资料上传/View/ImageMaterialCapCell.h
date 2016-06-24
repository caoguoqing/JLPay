//
//  ImageMaterialCapCell.h
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DottedBorderButton.h"


@interface ImageMaterialCapCell : UITableViewCell

@property (nonatomic, strong) DottedBorderButton* addButton;

@property (nonatomic, strong) NSMutableArray* imgViewListCaptured;

@property (nonatomic, strong) CAShapeLayer* dottedLineLayer;

@end
