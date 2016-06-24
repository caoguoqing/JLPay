//
//  ImageMaterialCapCell.m
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ImageMaterialCapCell.h"
#import "Masonry.h"
#import "Define_Header.h"
#import "DottedBorderButton.h"

@implementation ImageMaterialCapCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.addButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger countInLine = 3;
    CGFloat inset = 5.f;
    CGFloat viewHeight = (self.frame.size.width - 15 * 2 - inset * (countInLine - 1)) / countInLine;
    
    for (UIView* view in self.imgViewListCaptured) {
        [self addSubview:view];
    }
    
    CGRect frame = CGRectMake(15, inset, viewHeight, viewHeight);

    for (int i = 0; i < self.imgViewListCaptured.count; i++) {
        UIImageView* imgView = [self.imgViewListCaptured objectAtIndex:i];
        
        frame.origin.x = 15 + i%countInLine * (inset + viewHeight);
        frame.origin.y = inset + i/countInLine * (inset + viewHeight);
        [imgView setFrame:frame];
    }
    
    frame.origin.x = 15 + self.imgViewListCaptured.count%countInLine * (inset + viewHeight);
    frame.origin.y = inset + self.imgViewListCaptured.count/countInLine * (inset + viewHeight);
    [self.addButton setFrame:frame];
        
}

# pragma mask 4 getter
- (DottedBorderButton *)addButton {
    if (!_addButton) {
        _addButton = [[DottedBorderButton alloc] init];
        _addButton.backgroundColor = [UIColor colorWithHex:0xecf0f1 alpha:1];
        UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addition_lightGray"]];
        [_addButton addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_addButton.mas_centerX);
            make.centerY.equalTo(_addButton.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(37, 37));
        }];
    }
    return _addButton;
}
- (NSMutableArray *)imgViewListCaptured {
    if (!_imgViewListCaptured) {
        _imgViewListCaptured = [NSMutableArray array];
    }
    return _imgViewListCaptured;
}

- (CAShapeLayer *)dottedLineLayer {
    if (!_dottedLineLayer) {
        _dottedLineLayer = [CAShapeLayer layer];
    }
    return _dottedLineLayer;
}

@end
