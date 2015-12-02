//
//  BusinessInfoTableViewCell.m
//  JLPay
//
//  Created by jielian on 15/11/19.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "BusinessInfoTableViewCell.h"
#import "PublicInformation.h"

@interface BusinessInfoTableViewCell()

@property (nonatomic, strong) UIImageView* headImageView;   // 头像图片
@property (nonatomic, strong) UILabel* labelUserId; // 登录名标签
@property (nonatomic, strong) UILabel* labelBusinessName; // 商户名标签
@property (nonatomic, strong) UILabel* labelBusinessNo; // 商户号标签

@end

@implementation BusinessInfoTableViewCell


#pragma mask ---- PUBLIC INTERFACE
/* 设置头像图片 */
- (void) setHeadImage:(UIImage*)headImage {
    [self.headImageView setImage:headImage];
}

/* 设置登陆用户名 */
- (void) setUserId:(NSString*)userId {
    [self.labelUserId setText:userId];
}

/* 设置商户名 */
- (void) setBusinessName:(NSString*)businessName {
    [self.labelBusinessName setText:businessName];
}

/* 设置商户编号 */
- (void) setBusinessNo:(NSString *)businessNo {
    [self.labelBusinessNo setText:businessNo];
}



#pragma mask ---- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        self.backgroundColor = [PublicInformation returnCommonAppColor:@"red"];
        [self addSubview:self.headImageView];
        [self addSubview:self.labelUserId];
        [self addSubview:self.labelBusinessName];
        [self addSubview:self.labelBusinessNo];
    }
    return self;
}

#pragma mask ---- 加载子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat insetImageTop = 6.0;
    CGFloat insetImageLeft = 15.0;
    CGFloat insetLabelBig = 1.0;
    CGFloat insetLabelLit = 1.0;
    CGFloat insetLabelTop = 10.0;

    CGFloat heightLabelLit = (self.frame.size.height - insetLabelBig - insetLabelLit - insetLabelTop*2) * 2.0/7.0;
    CGFloat heightLabelBig = heightLabelLit * 3.0/2.0;
    
    CGFloat heightImage = self.frame.size.height - insetImageTop * 2;
    CGFloat widthLabel = self.frame.size.width - insetImageLeft * 2 - heightImage - 35/* 为AccessoryDisclosure预留 */;
    
    CGRect frame = CGRectMake(insetImageLeft, insetImageTop, heightImage, heightImage);
    // 头像图片
    [self.headImageView setFrame:frame];
    self.headImageView.layer.cornerRadius = frame.size.width / 2.0;
    
    // 登录名
    frame.origin.x += frame.size.width + insetImageLeft;
    frame.origin.y = insetLabelTop;
    frame.size.width = widthLabel;
    frame.size.height = heightLabelBig;
    [self.labelUserId setFrame:frame];
    [self.labelUserId setFont:[self newFontForHeight:frame.size.height]];
    
    // 商户名
    frame.origin.y += frame.size.height + insetLabelBig;
    frame.size.height = heightLabelLit;
    [self.labelBusinessName setFrame:frame];
    [self.labelBusinessName setFont:[self newFontForHeight:frame.size.height]];
    
    // 商户号
    frame.origin.y += frame.size.height + insetLabelLit;
    [self.labelBusinessNo setFrame:frame];
    [self.labelBusinessNo setFont:[self newFontForHeight:frame.size.height]];
}

#pragma mask ---- PRIVATE INTERFACE
/* 根据高度计算适应的 UIFont */
- (UIFont*) newFontForHeight:(CGFloat)height {
    CGFloat testFontSize = 20;
    CGSize testSize = [@"test" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:testFontSize]
                                                                              forKey:NSFontAttributeName]];
    
    CGFloat newFontSize = height / testSize.height * testFontSize;
    return [UIFont systemFontOfSize:newFontSize];
}


#pragma mask ---- getter
- (UIImageView *)headImageView {
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headImageView.backgroundColor = [UIColor whiteColor];
        _headImageView.image = [UIImage imageNamed:@"01_01"];
    }
    return _headImageView;
}

/* 登陆名 */
- (UILabel *)labelUserId {
    if (_labelUserId == nil) {
        _labelUserId = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelUserId.textColor = [UIColor whiteColor];
        _labelUserId.textAlignment = NSTextAlignmentLeft;
    }
    return _labelUserId;
}
/* 商户名 */
- (UILabel *)labelBusinessName {
    if (_labelBusinessName == nil) {
        _labelBusinessName = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelBusinessName.textColor = [UIColor whiteColor];
        _labelBusinessName.textAlignment = NSTextAlignmentLeft;
    }
    return _labelBusinessName;
}
/* 商户号 */
- (UILabel *)labelBusinessNo {
    if (_labelBusinessNo == nil) {
        _labelBusinessNo = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelBusinessNo.textColor = [UIColor whiteColor];
        _labelBusinessNo.textAlignment = NSTextAlignmentLeft;
    }
    return _labelBusinessNo;
}

@end
