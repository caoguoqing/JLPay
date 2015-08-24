//
//  RgAddrTableViewCell.m
//  TestForRegister
//
//  Created by jielian on 15/8/20.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "RgAddrTableViewCell.h"



@interface RgAddrTableViewCell()<UITextViewDelegate>
@property (nonatomic, strong) UIButton* btnProvince;    // 省份
@property (nonatomic, strong) UIButton* btnCity;    // 市
@property (nonatomic, strong) UIButton* btnAreaOrCountry;   // 区/县
@property (nonatomic, strong) UITextView* txtViewDetailAddr;    // 详细地址
@property (nonatomic, strong) UILabel* labTitle;        // 标题
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) int tagProvince;
@property (nonatomic) int tagCity;
@property (nonatomic) int tagArea;

@end


@implementation RgAddrTableViewCell
@synthesize btnProvince = _btnProvince;
@synthesize btnCity = _btnCity;
@synthesize btnAreaOrCountry = _btnAreaOrCountry;
@synthesize txtViewDetailAddr = _txtViewDetailAddr;
@synthesize labTitle = _labTitle;

#pragma mask ---- public interface
// 判断是否正在输入
- (BOOL) isTextEditing {
    return [self.txtViewDetailAddr isFirstResponder];
}
// 取消输入动作
- (void) endingTextEditing {
    [self.txtViewDetailAddr resignFirstResponder];
}
// 设置省份
- (void) setProvince:(NSString*)province {
    [self.btnProvince setTitle:province forState:UIControlStateNormal];
}
- (NSString *)province {
    if ([self.btnProvince.titleLabel.text isEqualToString:@"省份"]) {
        return nil;
    }
    return self.btnProvince.titleLabel.text;
}
// 设置市
- (void) setCity:(NSString*)city {
    [self.btnCity setTitle:city forState:UIControlStateNormal];
}
- (NSString *)city {
    if ([self.btnCity.titleLabel.text isEqualToString:@"市"]) {
        return nil;
    }
    return self.btnCity.titleLabel.text;
}
// 设置区/县
- (void) setArea:(NSString*)area {
    [self.btnAreaOrCountry setTitle:area forState:UIControlStateNormal];
}
- (NSString *)area {
    if ([self.btnAreaOrCountry.titleLabel.text isEqualToString:@"区/县"]) {
        return nil;
    }
    return self.btnAreaOrCountry.titleLabel.text;
}
// 详细地址
- (NSString*) detailPlace {
    return self.txtViewDetailAddr.text;
}

- (IBAction) touchToChoosePlace:(UIButton*)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addrCell:choosePlaceInType:)]) {
        if (sender.tag == self.tagProvince) {
            [self.delegate addrCell:self choosePlaceInType:0];
        } else if (sender.tag == self.tagCity) {
            if ([self.btnProvince.titleLabel.text isEqualToString:@"省份"]) {
                [self alertViewShowWithMessage:@"请先选择省份"];
                return;
            }
            [self.delegate addrCell:self choosePlaceInType:1];
        } else if (sender.tag == self.tagArea) {
            if ([self.btnCity.titleLabel.text isEqualToString:@"市"]) {
                [self alertViewShowWithMessage:@"请先选择市"];
                return;
            }
            [self.delegate addrCell:self choosePlaceInType:2];
        }
    }
}

#pragma mask ---- UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text && textView.text.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(addrCell:inputedDetailPlace:)]) {
            [self.delegate addrCell:self inputedDetailPlace:textView.text];
        }
    }
}

#pragma mask ---- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.fontSize = 15.0;
        self.tagProvince = 23;
        self.tagCity = 43;
        self.tagArea = 11;
        [self.contentView addSubview:self.btnProvince];
        [self.contentView addSubview:self.btnCity];
        [self.contentView addSubview:self.btnAreaOrCountry];
        [self.contentView addSubview:self.txtViewDetailAddr];
        [self.contentView addSubview:self.labTitle];
    }
    return self;
}
- (void)layoutSubviews {
    CGFloat inset = 5.0;
    CGFloat midInset = inset * 3;
    CGFloat rightInset = inset * 2;
    CGFloat widthBtn = (self.frame.size.width - inset - inset*2 * 3 - rightInset - inset*2)/3.0;
    
    // 标记 *
    CGRect frame = CGRectMake(inset, inset, inset*2, self.frame.size.height/3.0 - inset*2);
    [self.contentView addSubview:[self newLabelInputFlagWithFrame:frame]];
    // 省份按钮
    frame.origin.x += frame.size.width;
    frame.size.width = widthBtn;
    self.btnProvince.frame = frame;
    // 标记 *
    frame.origin.x += frame.size.width + inset;
    frame.size.width = inset*2;
    [self.contentView addSubview:[self newLabelInputFlagWithFrame:frame]];
    // 城市按钮
    frame.origin.x += frame.size.width;
    frame.size.width = widthBtn;
    self.btnCity.frame = frame;
    // 标记 *
    frame.origin.x += frame.size.width + inset;
    frame.size.width = inset*2;
    [self.contentView addSubview:[self newLabelInputFlagWithFrame:frame]];
    // 区/县按钮
    frame.origin.x += frame.size.width;
    frame.size.width = widthBtn;
    self.btnAreaOrCountry.frame = frame;
    // 标记 *
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset*2;
    frame.size.width = inset*2;
    frame.size.height = self.frame.size.height - frame.origin.y - inset;
    [self.contentView addSubview:[self newLabelInputFlagWithFrame:frame]];
    // 标题
    frame.origin.x += frame.size.width;
    frame.size.width = self.frame.size.width/4.0;
    self.labTitle.frame = frame;
    // 文本输入框
    frame.origin.x += frame.size.width + midInset;
    frame.size.width = self.frame.size.width - frame.origin.x - rightInset;
    self.txtViewDetailAddr.frame = frame;
}
// 新建一个 * label
- (UILabel*) newLabelInputFlagWithFrame:(CGRect)frame {
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.text = @"*";
    label.textColor = [UIColor redColor];
    return label;
}

#pragma mask ---- private interface
- (void) alertViewShowWithMessage:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


#pragma mask ---- getter & setter
- (UIButton *)btnProvince {
    if (_btnProvince == nil) {
        _btnProvince = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnProvince setBackgroundColor:[UIColor orangeColor]];
        [_btnProvince setTitle:@"省份" forState:UIControlStateNormal];
        _btnProvince.layer.cornerRadius = 5.0;
        _btnProvince.layer.shadowOffset = CGSizeMake(2, 2);
        _btnProvince.layer.shadowOpacity = 1;
        _btnProvince.layer.shadowColor = [UIColor blackColor].CGColor;
        _btnProvince.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
        _btnProvince.tag = self.tagProvince;
        [_btnProvince addTarget:self action:@selector(touchToChoosePlace:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnProvince;
}
- (UIButton *)btnCity {
    if (_btnCity == nil) {
        _btnCity = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnCity setBackgroundColor:[UIColor orangeColor]];
        [_btnCity setTitle:@"市" forState:UIControlStateNormal];
        _btnCity.layer.cornerRadius = 5.0;
        _btnCity.layer.shadowOffset = CGSizeMake(2, 2);
        _btnCity.layer.shadowOpacity = 1;
        _btnCity.layer.shadowColor = [UIColor blackColor].CGColor;
        _btnCity.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
        _btnCity.tag = self.tagCity;
        [_btnCity addTarget:self action:@selector(touchToChoosePlace:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCity;
}
- (UIButton *)btnAreaOrCountry {
    if (_btnAreaOrCountry == nil) {
        _btnAreaOrCountry = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnAreaOrCountry setBackgroundColor:[UIColor orangeColor]];
        [_btnAreaOrCountry setTitle:@"区/县" forState:UIControlStateNormal];
        _btnAreaOrCountry.layer.cornerRadius = 5.0;
        _btnAreaOrCountry.layer.shadowOffset = CGSizeMake(2, 2);
        _btnAreaOrCountry.layer.shadowOpacity = 1;
        _btnAreaOrCountry.layer.shadowColor = [UIColor blackColor].CGColor;
        _btnAreaOrCountry.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
        _btnAreaOrCountry.tag = self.tagArea;
        [_btnAreaOrCountry addTarget:self action:@selector(touchToChoosePlace:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _btnAreaOrCountry;
}
- (UITextView *)txtViewDetailAddr {
    if (_txtViewDetailAddr == nil) {
        _txtViewDetailAddr = [[UITextView alloc] initWithFrame:CGRectZero];
        _txtViewDetailAddr.layer.cornerRadius = 5.0;
        _txtViewDetailAddr.layer.masksToBounds = YES;
        _txtViewDetailAddr.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _txtViewDetailAddr.layer.borderWidth = 0.5;
        _txtViewDetailAddr.font = [UIFont systemFontOfSize:self.fontSize];
        [_txtViewDetailAddr setDelegate:self];

    }
    return _txtViewDetailAddr;
}
- (UILabel *)labTitle {
    if (_labTitle == nil) {
        _labTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _labTitle.font = [UIFont systemFontOfSize:self.fontSize];
        _labTitle.text = @"详细地址";
    }
    return _labTitle;
}

@end
